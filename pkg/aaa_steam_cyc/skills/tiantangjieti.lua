
local pilename = "@[steam_ttjt]"

local skel = fk.CreateSkill {
  name = "steam__tiantangjieti",
  tags = {Skill.Quest},
  derived_piles = pilename,
}

Fk:loadTranslationTable{
  ["steam__tiantangjieti"] = "天堂阶梯", -- Stairway To Heaven
  [":steam__tiantangjieti"] = "使命技，一名角色的回合开始时，你可以视为对你与其使用一张【以逸待劳】，并将弃置的与你武将牌上点数均不同的牌置于你的武将牌上。"..
  "<br>●成功：你武将牌上的牌点数齐全后，你减1点体力上限，获得〖蓄发〗、〖排异〗、〖徐图〗，且你武将牌上的每张牌都将随机变为以下标记之一：“蓄发”、“权”、“资”。",
  --☆蓄发：(OL蒋琬) ☆排异：(标钟会) ☆徐图：OL谋沮授

  ["#steam__tiantangjieti-invoke"] = "天堂阶梯：你可以视为对你和 %src 使用一张【以逸待劳】",
  ["#steam__tiantangjieti-single"] = "天堂阶梯：你可以视为对 %src 使用一张【以逸待劳】",
  [pilename] = "天阶",

  ["$steam__tiantangjieti1"] = "",
  ["$steam__tiantangjieti2"] = "",
}

Fk:addQmlMark{
  name = "steam_ttjt",
  how_to_show = function(name, value, p)
    local pile = p:getPile(pilename)
    local str = #pile .. "/13"
    if #pile > 9 then
      local list = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13}
      for _, id in ipairs(pile) do
        table.removeOne(list, Fk:getCardById(id).number)
      end
      str = "缺" .. table.concat(list, ",")
    end
    return str
  end,
  qml_data = function (name, value, player) -- 从小到大排序
    local pile = player:getPile(pilename)
    table.sort(pile, function (a, b)
      return Fk:getCardById(a).number < Fk:getCardById(b).number
    end)
    return pile
  end,
  qml_path = "packages/utility/qml/ViewPile"
}

skel:addEffect(fk.TurnStart, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(skel.name) and player:getQuestSkillState(skel.name) == nil and
    not target.dead and not player:prohibitUse(Fk:cloneCard("await_exhausted"))
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local card = Fk:cloneCard("await_exhausted")
    card.skillName = skel.name
    local tos = { player }
    table.insertIfNeed(tos, target)
    tos = table.filter(tos, function (p)
      return not player:isProhibited(p, card)
    end)
    if #tos == 0 then return end
    local prompt = "#steam__tiantangjieti-single:" .. tos[1].id
    if target ~= player then
      prompt = "#steam__tiantangjieti-invoke:"..target.id
    end
    if room:askToSkillInvoke(player, { skill_name = skel.name, prompt = prompt }) then
      event:setCostData(self, {tos = tos})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local card = Fk:cloneCard("await_exhausted")
    card.skillName = skel.name
    local tos = event:getCostData(self).tos
    local use = {
      from = player,
      tos = tos,
      card = card,
      extra_data = { steam_ttjt_from = player.id }
    }
    room:useCard(use)
    if not player:hasSkill(skel.name) or #player:getPile(pilename) < 13 then return end
    -- 使命成功
    room:notifySkillInvoked(player, skel.name, "big")
    room:updateQuestSkillState(player, skel.name, false)
    room:changeMaxHp(player, -1)
    if player.dead then return end
    room:handleAddLoseSkills(player, "steam__xufa|steam__paiyi|steam__xutu")
    local pile = table.simpleClone(player:getPile(pilename))
    if #pile == 0 then return end
    local pileinfo = { {"steam_xufa", {}}, {"steam_quan", {}}, {"steam_supplies", {}} }
    local n = 3 -- 徐图至多存3张“资”
    for _, id in ipairs(pile) do
      local rnd = math.random(n)
      local t = pileinfo[rnd][2]
      table.insert(t, id)
      if rnd == 3 and #t > 2 then
        n = 2
      end
    end
    local moves = {}
    for _, info in ipairs(pileinfo) do
      if #info[2] > 0 then
        table.insert(moves, {
          from = player,
          ids = info[2],
          toArea = Card.Processing,
          moveReason = fk.ReasonJustMove,
          skillName = "steam__tiantangjieti_exchange",
        })
      end
    end
    room:moveCards(table.unpack(moves))
    room:delay(100)
    moves = {}
    for _, info in ipairs(pileinfo) do
      if #info[2] > 0 then
        table.insert(moves, {
          to = player,
          ids = info[2],
          toArea = Card.PlayerSpecial,
          moveReason = fk.ReasonJustMove,
          skillName = "steam__tiantangjieti_exchange",
          specialName = info[1],
        })
      end
    end
    room:moveCards(table.unpack(moves))
  end,
})

--- 把以逸待劳弃置的牌置于武将牌上
skel:addEffect(fk.AfterCardsMove, {
  is_delay_effect = true,
  mute = true,
  can_refresh = function(self, event, target, player, data)
    if not player:hasSkill(skel.name, true) then return false end
    local useEvent = player.room.logic:getCurrentEvent():findParent(GameEvent.UseCard)
    if not useEvent then return end
    local use = useEvent.data
    if use.card.name == "await_exhausted" and table.contains(use.card.skillNames, skel.name) then
      return use.extra_data and use.extra_data.steam_ttjt_from == player.id
    end
  end,
  on_refresh = function(self, event, target, player, data)
    local ids = {}
    for _, move in ipairs(data) do
      if move.toArea == Card.DiscardPile and move.moveReason == fk.ReasonDiscard
       and move.skillName and string.find(move.skillName, "await_exhausted") then
        for _, info in ipairs(move.moveInfo) do
          table.insertIfNeed(ids, info.cardId)
        end
      end
    end
    ids = table.filter(ids, function (id) return player.room:getCardArea(id) == Card.DiscardPile end)
    if #ids == 0 then return end
    local exists = {} -- 已经存在的点数
    for _, id in ipairs(player:getPile(pilename)) do
      table.insertIfNeed(exists, Fk:getCardById(id).number)
    end
    local add = table.filter(ids, function (id) -- 筛选哪些牌可以加入
      local num = Fk:getCardById(id).number
      return num > 0 and num < 14 and table.insertIfNeed(exists, num) -- 筛选点数不重复的加入牌
    end)
    if #add > 0 then
      player.room:delay(350)
      player:addToPile(pilename, add, true, skel.name)
    end
  end,
})

skel:addEffect(fk.AfterCardsMove, {-- 防止换牌的移动触发任何技能
  priority = 10,
  can_trigger = function (self, event, target, player, data)
    for _, move in ipairs(data) do
      if move.skillName == "steam__tiantangjieti_exchange" then return true end
    end
  end,
  on_trigger = Util.TrueFunc,
})

return skel
