local skel = fk.CreateSkill {
  name = "steam__tieling",
}

Fk:loadTranslationTable{
  ["steam__tieling"] = "铁令",
  [":steam__tieling"] = "出牌阶段限一次，你可以令一名其他角色视为对你使用一张【决斗】。",

  ["#steam__tieling"] = "铁令：令一名其他角色视为对你使用一张【决斗】",

  ["$steam__tieling1"] = "自投罗网！",
  ["$steam__tieling2"] = "不要背对我！",
}

skel:addEffect("active", {
  anim_type = "offensive",
  prompt = "#steam__tieling",
  card_num = 0,
  target_num = 1,
  card_filter = Util.FalseFunc,
  target_filter = function (self, player, to, selected)
    if #selected > 0 or to == player then return false end
    return to:canUseTo(Fk:cloneCard("duel"), player)
  end,
  times = function (self, player)
    return 1 - player:usedSkillTimes(skel.name, Player.HistoryPhase)
  end,
  can_use = function(self, player)
    return player:usedSkillTimes(skel.name, Player.HistoryPhase) == 0
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local to = effect.tos[1]
    room:useVirtualCard("duel", nil, to, player, skel.name)
  end,
})

return skel
