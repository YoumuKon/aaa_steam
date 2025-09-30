local skel = fk.CreateSkill {
  name = "steam__spirit_fire",
}

Fk:loadTranslationTable{
  ["steam__spirit_fire"] = "灵魂烈焰",
  [":steam__spirit_fire"] = "出牌阶段限两次，你可以重铸任意张同花色牌，令本回合场上该花色的牌失效。",

  ["#steam__spirit_fire"] = "灵魂烈焰：重铸任意张同花色牌，本回合场上此花色牌失效",
  ["@steam__spirit_fire-turn"] = "魂焰",

  ["$steam__spirit_fire1"] = "有些事必须一直掩埋。",
  ["$steam__spirit_fire2"] = "天空，是无用且垂死的星辰。",
}

skel:addEffect("active", {
  prompt =  "#steam__spirit_fire",
  anim_type = "control",
  min_card_num = 1,
  target_num = 0,
  times = function (self, player)
    return 2 - player:usedSkillTimes(self.name, Player.HistoryPhase)
  end,
  can_use = function (self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) < 2
  end,
  card_filter = function (self, player, to_select, selected)
    if #selected == 0 then
      return true
    else
      return Fk:getCardById(to_select):compareSuitWith(Fk:getCardById(selected[1]))
    end
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local suit = Fk:getCardById(effect.cards[1]):getSuitString(true)
    room:recastCard(effect.cards, player, self.name)
    if not player.dead then
      room:addTableMarkIfNeed(player, "@steam__spirit_fire-turn", suit)
    end
  end,
})

skel:addEffect("invalidity", {
  invalidity_func = function(self, from, skill)
    if (skill:getSkeleton() or Util.DummyTable).attached_equip then
      local ban_suits = {}
      for _, p in ipairs(Fk:currentRoom().alive_players) do
        table.insertTable(ban_suits, p:getTableMark("@steam__spirit_fire-turn"))
      end
      if #ban_suits == 0 then return false end
      local suits = {}
      for _, id in ipairs(from:getCardIds("e")) do
        if Fk:getCardById(id).name == skill:getSkeleton().attached_equip then
          table.insert(suits, Fk:getCardById(id):getSuitString(true))
        end
      end
      return table.find(suits, function (s) return table.contains(ban_suits, s) end) ~= nil
    end
  end
})

return skel
