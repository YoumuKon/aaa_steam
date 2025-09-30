local weijing = fk.CreateSkill{
  name = "steam__weijing",
}

Fk:loadTranslationTable{
  ["steam__weijing"] = "卫境",
  [":steam__weijing"] = "每轮限一次，当你需要使用【杀】或【闪】时，你可以视为使用之。（此技能与所有拥有者共享技能发动次数）",

  ["#steam__weijing"] = "卫境：你可以视为使用【杀】或【闪】",
}

weijing:addEffect("viewas", {
  pattern = "slash,jink|0|nosuit",
  prompt = "#weijing",
  interaction = function(self, player)
    local names = player:getViewAsCardNames(weijing.name, {"slash", "jink"})
    return UI.CardNameBox {choices = names, all_choices = {"slash", "jink"}}
  end,
  card_filter = Util.FalseFunc,
  view_as = function(self)
    if not self.interaction.data then return end
    local card = Fk:cloneCard(self.interaction.data)
    card.skillName = weijing.name
    return card
  end,
  times = function (self, player)
    local num, max_num = 0, 0
    for _, cp in ipairs(Fk:currentRoom().players) do
      if cp:hasSkill(weijing.name, true, false) or (not cp.dead and cp:usedSkillTimes(weijing.name, Player.HistoryRound) > 0 and cp:hasSkill(weijing.name, true, true)) then
        max_num = max_num + 1
      end
      num = num + cp:usedSkillTimes(weijing.name, Player.HistoryRound)
    end
    return math.max(max_num - num, 0)
  end,
  enabled_at_play = function(self, player)
    local num, max_num = 0, 0
    for _, cp in ipairs(Fk:currentRoom().players) do
      if cp:hasSkill(weijing.name, true, false) or (not cp.dead and cp:usedSkillTimes(weijing.name, Player.HistoryRound) > 0 and cp:hasSkill(weijing.name, true, true)) then
        max_num = max_num + 1
      end
      num = num + cp:usedSkillTimes(weijing.name, Player.HistoryRound)
    end
    return num < max_num and
      #player:getViewAsCardNames(weijing.name, {"slash"}) > 0
  end,
  enabled_at_response = function(self, player, response)
    local num, max_num = 0, 0
    for _, cp in ipairs(Fk:currentRoom().players) do
      if cp:hasSkill(weijing.name, true, false) or (not cp.dead and cp:usedSkillTimes(weijing.name, Player.HistoryRound) > 0 and cp:hasSkill(weijing.name, true, true)) then
        max_num = max_num + 1
      end
      num = num + cp:usedSkillTimes(weijing.name, Player.HistoryRound)
    end
    return not response and num < max_num and
      #player:getViewAsCardNames(weijing.name, {"slash", "jink"}) > 0
  end,
})

return weijing
