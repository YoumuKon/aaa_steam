local shuheng = fk.CreateSkill {
  name = "steam__shuheng",
  tags = {Skill.Compulsory},
}

Fk:loadTranslationTable{
  ["steam__shuheng"] = "枢衡",
  [":steam__shuheng"] = "锁定技，你于防具栏为空时视为装备着<a href=':steam_shuheng_equip'>【拳经三问】</a>。",

  ["$steam__shuheng1"] = "偶尔也要试试拳脚。",
  ["$steam__shuheng2"] = "征蓬未定，甲胄在身。",
}

local shuheng_on_use = function (self, event, target, player, data)
  local room = player.room
  local skill = Fk.skills["#steam_shuheng_equip_skill"]
  player:setSkillUseHistory("#steam_shuheng_equip_skill", player:usedSkillTimes("#steam_shuheng_equip_skill", Player.HistoryRound) + 1, Player.HistoryRound)
  skill:use(event, target, player, data)
end

shuheng:addEffect(fk.DamageCaused, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(shuheng.name) and not player:isFakeSkill(self) 
    and not player:getEquipment(Card.SubtypeArmor) and Fk.skills["#steam_shuheng_equip_skill"] ~= nil and Fk.skills["#steam_shuheng_equip_skill"]:isEffectable(player)
    and player:usedSkillTimes("#steam_shuheng_equip_skill", Player.HistoryRound) < 3
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = shuheng.name,
    })
  end,
  on_use = shuheng_on_use,
})

shuheng:addEffect(fk.DamageInflicted, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(shuheng.name) and not player:isFakeSkill(self) 
    and not player:getEquipment(Card.SubtypeArmor) and Fk.skills["#steam_shuheng_equip_skill"] ~= nil and Fk.skills["#steam_shuheng_equip_skill"]:isEffectable(player)
    and player:usedSkillTimes("#steam_shuheng_equip_skill", Player.HistoryRound) < 3
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = shuheng.name,
    })
  end,
  on_use = shuheng_on_use,
})

return shuheng
