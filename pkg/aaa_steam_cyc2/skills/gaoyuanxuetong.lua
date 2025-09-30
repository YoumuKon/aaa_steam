local skel = fk.CreateSkill {
  name = "steam__gaoyuanxuetong",
  tags = {Skill.Wake}
}

Fk:loadTranslationTable{
  ["steam__gaoyuanxuetong"] = "高原血统",
  [":steam__gaoyuanxuetong"] = "觉醒技，你杀死角色后，摸一张牌并令武将牌上的所有技能视为未发动过。",

  ["$steam__gaoyuanxuetong1"] = "跟上",
  ["$steam__gaoyuanxuetong2"] = "好好看，好好学",
}

skel:addEffect(fk.Deathed, {
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(skel.name) and player:usedSkillTimes(skel.name, Player.HistoryGame) == 0
  end,
  can_wake = function (self, event, target, player, data)
    return data.killer == player
  end,
  on_use = function (self, event, target, player, data)
    player:drawCards(1, skel.name)
    if player.dead then return end
    local skills = table.simpleClone(Fk.generals[player.general]:getSkillNameList(true))
    if player.deputyGeneral ~= "" then
      table.insertTableIfNeed(skills, Fk.generals[player.deputyGeneral]:getSkillNameList(true))
    end
    skills = table.filter(skills, function(s) return player:hasSkill(s) end)
    if #skills > 0 then
      for _, s in ipairs(skills) do
        player:setSkillUseHistory(s)
      end
    end
  end,
})

return skel
