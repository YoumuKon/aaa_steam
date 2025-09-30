local skel = fk.CreateSkill {
  name = "steam__xianzuzhaohuan",
  tags = {Skill.Limited},
}

Fk:loadTranslationTable{
  ["steam__xianzuzhaohuan"] = "先祖召唤",
  [":steam__xianzuzhaohuan"] = "限定技，出牌阶段，你可以减1点体力上限，删去〖众灵纽带〗中带有☆的一句，令一名其他角色获得一个仅有首句与该句的〖众灵纽带〗。",

  ["#steam__xianzuzhaohuan"] = "先祖召唤：减1点体力上限，删去〖众灵纽带〗中带有☆的一句，令一名其他角色获得之",
  ["steam__zhonglingniudai_bz_info"] = "☆若你“变阵”成功，你可以弃置一名其他角色区域内至多两张牌",
  ["steam__zhonglingniudai_lj_info"] = "☆若你“擂进”成功，你可以视为使用一张无视距离的雷【杀】",
  ["steam__zhonglingniudai_mz_info"] = "☆若你“鸣止”成功，你可以复原一名角色，其移动场上一张牌",
  ["steam__zhonglingniudai_fail_info"] = "☆若你整肃失败，你可以视为对自己使用一张冰【杀】，仍获得整肃奖励",

  ["$steam__xianzuzhaohuan1"] = "纷争哺育了弗雷尔卓德！",
  ["$steam__xianzuzhaohuan2"] = "巨龙之灵出窍以后，依然还会长久燃烧！",
}

skel:addEffect("active", {
  card_num = 0,
  target_num = 1,
  prompt = "#steam__xianzuzhaohuan",
  interaction = function (_, player)
    local all_choices = {
      "steam__zhonglingniudai_bz_info",
      "steam__zhonglingniudai_lj_info",
      "steam__zhonglingniudai_mz_info",
      "steam__zhonglingniudai_fail_info",
    }
    local choices = table.filter(all_choices, function(name)
      return not table.contains(player:getTableMark("steam__zhonglingniudai_remove"), name)
    end)
    return UI.ComboBox { choices = choices, all_choices = all_choices }
  end,
  card_filter = Util.FalseFunc,
  target_filter = function (self, player, to_select, selected)
    return #selected == 0 and player ~= to_select and self.interaction.data ~= nil
  end,
  can_use = function(self, player)
    return player:usedSkillTimes(skel.name, Player.HistoryGame) == 0
    and player:hasSkill("steam__zhonglingniudai", true)
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local to = effect.tos[1]
    local choice = self.interaction.data
    if choice == nil then return end
    choice = choice:sub(1, -6)
    assert(Fk.skills[choice])
    room:addTableMark(player, "steam__zhonglingniudai_remove", choice)
    room:changeMaxHp(player, -1)
    room:handleAddLoseSkills(to, choice)
  end,
})

return skel
