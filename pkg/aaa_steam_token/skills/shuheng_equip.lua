local skill = fk.CreateSkill {
  name = "#steam_shuheng_equip_skill",
  attached_equip = "steam_shuheng_equip",
}

Fk:loadTranslationTable{
  ["#steam_shuheng_equip_skill"] = "拳经三问",
  [":#steam_shuheng_equip_skill"] = "每轮限三次，你造成或受到伤害时，可以摸两张牌再弃置两张牌",
}

skill:addEffect(fk.DamageCaused, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(skill.name) and player:usedSkillTimes(skill.name, Player.HistoryRound) < 3
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(2, skill.name)
    if not player.dead then
      player.room:askToDiscard(player, {
        min_num = 2,
        max_num = 2,
        skill_name = skill.name,
        include_equip = true,
        cancelable = false,
      })
    end
  end,
})

skill:addEffect(fk.DamageInflicted, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(skill.name) and player:usedSkillTimes(skill.name, Player.HistoryRound) < 3
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(2, skill.name)
    if not player.dead then
      player.room:askToDiscard(player, {
        min_num = 2,
        max_num = 2,
        skill_name = skill.name,
        include_equip = true,
        cancelable = false,
      })
    end
  end,
})

return skill
