local skel = fk.CreateSkill {
  name = "steam__chuanwu",
  tags = {Skill.Compulsory},
}

Fk:loadTranslationTable{
  ["steam__chuanwu"] = "穿屋",
  [":steam__chuanwu"] = "锁定技，当你造成或受到伤害后，你失去你武将牌上前X个技能直到回合结束（X为你的攻击范围），然后摸等同失去技能数张牌。",
}

local spec = {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(skel.name) and player:getAttackRange() > 0 then
      local skills = Fk.generals[player.general]:getSkillNameList(true)
      if player.deputyGeneral ~= "" then
        table.insertTableIfNeed(skills, Fk.generals[player.deputyGeneral]:getSkillNameList(true))
      end
      skills = table.filter(skills, function(s) return player:hasSkill(s, true) end)
      if #skills > 0 then
        event:setCostData(self, {skills = skills})
        return true
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local skills = event:getCostData(self).skills
    local n = math.min(player:getAttackRange(), #skills)
    skills = table.slice(skills, 1, n + 1)
    local mark = player:getTableMark("steam__chuanwu")
    table.insertTable(mark, skills)
    player.room:setPlayerMark(player, "steam__chuanwu", mark)
    player.room:handleAddLoseSkills(player, "-"..table.concat(skills, "|-"))
    player:drawCards(n, skel.name)
  end,
}

skel:addEffect(fk.Damage, spec)
skel:addEffect(fk.Damaged, spec)

skel:addEffect(fk.TurnEnd, {
  is_delay_effect = true,
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return not player.dead and player:getMark("steam__chuanwu") ~= 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local skills = player:getTableMark("steam__chuanwu")
    room:setPlayerMark(player, "steam__chuanwu", 0)
    room:handleAddLoseSkills(player, table.concat(skills, "|"))
  end,
})

return skel
