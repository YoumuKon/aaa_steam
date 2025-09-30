local skel = fk.CreateSkill {
  name = "steam__chuangshiji",
  tags = {Skill.Wake},
}

Fk:loadTranslationTable{
  ["steam__chuangshiji"] = "创世记",
  [":steam__chuangshiji"] = "觉醒技，你进入濒死时，防止你此后的体力流失，然后你弃置区域内的所有牌，再将体力与上限调整至3，最后依次发现X张牌，且可以使用其中任意张装备牌（X为中央区牌数）。",

  ["#steam__chuangshiji-use"] = "创世记：你可以使用其中的装备牌",
  ["@[desc]steam__chuangshiji_mark"] = "创世记",
  [":steam__chuangshiji_mark"] = "防止你的体力流失",
  ["#discover-card"] = "发现一张牌",

  ["$steam__chuangshiji1"] = "",
  ["$steam__chuangshiji2"] = "",
}

-- 从一些牌中三选一
---@param player ServerPlayer
---@param cards integer[]
---@return integer
local discoverCard = function (player, cards)
  player.room:broadcastPlaySound("./packages/moepack/audio/card/male/cent_coin")
  return player.room:askToChooseCard(player, {
    target = player, flag = { card_data = { { "$Discover", table.random(cards, 3) } } },
     skill_name =  skel.name, prompt = "#discover-card"
  })
end

skel:addEffect(fk.EnterDying, {
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(skel.name) and target == player and player:usedSkillTimes(skel.name, Player.HistoryGame) == 0
  end,
  can_wake = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(player, "@[desc]steam__chuangshiji_mark", 1)
    player:throwAllCards("hej", skel.name)
    local x = 3 - player.maxHp
    if x ~= 0 then
      room:changeMaxHp(player, x)
    end
    if player.dead then return end
    x = 3 - player.hp
    if x > 0 then
      room:recover { num = x, skillName = skel.name, who = player, recoverBy = player }
    elseif x < 0 then
      room:loseHp(player, -x, skel.name)
    end
    x = #(room:getBanner("@$CenterArea") or Util.DummyTable)
    local ids = {}
    for _ = 1, x do
      if player.dead or #room.draw_pile == 0 then return end
      local cid = discoverCard(player, room.draw_pile)
      table.insert(ids, cid)
      room:obtainCard(player, cid, true, fk.ReasonJustMove, player, skel.name)
    end
    while player:isAlive() and #ids > 0 do
      ids = table.filter(ids, function(id) return table.contains(player.player_cards[Player.Hand], id) end)
      player:filterHandcards()
      local equips = table.filter(ids, function(id) return Fk:getCardById(id).type == Card.TypeEquip end)
      if #equips == 0 then break end
      local use = room:askToUseRealCard(player, { pattern = equips, skill_name = skel.name,
      prompt = "#steam__chuangshiji-use", skip = false})
      if not use then break end
    end
  end,
})

skel:addEffect(fk.PreHpLost, {
  mute = true,
  is_delay_effect = true,
  can_trigger = function (self, event, target, player, data)
    return target == player and player:getMark("@[desc]steam__chuangshiji_mark") ~= 0
  end,
  on_use = function (self, event, target, player, data)
    data.num = 0
    data.prevented = true
  end,
})

skel:addAcquireEffect(function (self, player, is_start)
  player.room:addSkill("#CenterArea")
end)

return skel
