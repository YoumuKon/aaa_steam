local skel = fk.CreateSkill {
  name = "steam__dixiaheishi",
  derived_piles = "keeper_showcase",
}

Fk:loadTranslationTable{
  ["steam__dixiaheishi"] = "地下黑市",
  [":steam__dixiaheishi"] = "你没有判定区，改为一个容量为3的展柜。首轮开始时，或展柜清空后，你依次发现三张标准、军争包外的游戏牌，置入展柜。",

  ["keeper_showcase"] = "展柜",
  ["#steam__dixiaheishi2"] = "地下黑市",

  ["#showcase-remove"] = "展柜已超出容量，请移去%arg张",
  ["$Discover"] = "发现",
  ["#showcase-put"] = "请选择一张置入展柜",
}

--- 记录展柜发现池
skel:addAcquireEffect(function (self, player, is_start)
  local room = player.room
  local tag = room:getTag("steam__dixiaheishi_card")
  if tag ~= nil then return end
  local ban_names = {"poker", "pokerr"}
  tag = {}
  for name, card in pairs(Fk.all_card_types) do
    if card.package and not table.contains({"standard_cards", "maneuvering", "standard_ex_cards"}, card.package.name)
     and not table.contains(ban_names, card.name) then
      local suit, number = card.suit, card.number
      if suit == Card.NoSuit then suit = math.random(4) end
      if number < 1 or number > 13 then number = math.random(13) end
      local c = room:printCard(name, suit, number)
      room:setCardMark(c, MarkEnum.DestructIntoDiscard, 1)
      table.insert(tag, c.id)
    end
  end
  room:setTag("steam__dixiaheishi_card", tag)
end)

--- 往展柜塞3牌
---@param player ServerPlayer
local function addToShowcase(player)
  local room = player.room
  local pilename = "keeper_showcase"
  local tag = table.simpleClone(room:getTag("steam__dixiaheishi_card") or Util.DummyTable)
  for _ = 1, 3 do
    if player.dead then break end
    tag = table.filter(tag, function(id) return room:getCardArea(id) == Card.Void end)
    if #tag == 0 then break end
    room:broadcastPlaySound("./packages/moepack/audio/card/male/cent_coin") -- 金币声
    local cid = room:askToChooseCard(player, {
      target = player, skill_name = skel.name, prompt = "#showcase-put",
      flag = { card_data = { { "$Discover", table.random(tag, 3) } } }
    })
    player:addToPile(pilename, cid, true, skel.name)
    -- 移出
    local x = #player:getPile(pilename) - 3
    if x > 0 then
      local throw = room:askToChooseCards(player, {
        target = player, skill_name = skel.name, min = x, max = x, prompt = "#showcase-remove:::" .. x,
        flag = { card_data = { { pilename, player:getPile(pilename) } } }
      })
      room:moveCardTo(throw, Card.DiscardPile, nil, fk.ReasonPutIntoDiscardPile, skel.name, nil, true, player)
    end
  end
end

skel:addEffect(fk.RoundStart, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(skel.name) then
      return player.room:getBanner("RoundCount") == 1
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    addToShowcase(player)
  end,
})

skel:addEffect(fk.AfterCardsMove, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(skel.name) then
      if #player:getPile("keeper_showcase") == 0 then
        for _, move in ipairs(data) do
          if move.from == player then
            if table.find(move.moveInfo, function(info) return info.fromSpecialName == "keeper_showcase" end) then
              return true
            end
          end
        end
      end
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    addToShowcase(player)
  end,
})

-- 这部分别写在onAcquire里，因为会触发事件
skel:addEffect(fk.EventAcquireSkill, {
  can_trigger = function(self, event, target, player, data)
    return target == player and data.skill.name == skel.name and not table.contains(player.sealedSlots, Player.JudgeSlot)
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    player.room:abortPlayerArea(player, Player.JudgeSlot)
  end,
})


return skel
