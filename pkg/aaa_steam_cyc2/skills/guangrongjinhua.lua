local skel = fk.CreateSkill {
  name = "steam__guangrongjinhua",
  tags = {Skill.Limited},
}

Fk:loadTranslationTable{
  ["steam__guangrongjinhua"] = "光荣进化",
  [":steam__guangrongjinhua"] = "限定技，出牌阶段，你可以令攻击范围内任意名受到过你伤害的角色各摸一张牌、回复1点体力，且可选择一个技能替换为〖荣生〗。",
  ["#steam__guangrongjinhua"] = "光荣进化：令攻击范围内受到过你伤害的角色摸1牌、回1血、进化！",
  ["#steam__guangrongjinhua-choice"] = "光荣进化：你可以选择你一个技能替换为〖荣生〗",

  ["$steam__guangrongjinhua1"] = "与海克斯的明光化为一体！",
  ["$steam__guangrongjinhua2"] = "进化，如骤雨狂风！",
}

skel:addEffect("active", {
  card_num = 0,
  min_target_num = 1,
  prompt = "#steam__guangrongjinhua",
  card_filter = Util.FalseFunc,
  target_filter = function (self, player, to, selected)
    return player:inMyAttackRange(to) and table.contains(player:getTableMark("steam__guangrongjinhua_record"), to.id)
  end,
  can_use = function(self, player)
    return player:usedSkillTimes(skel.name, Player.HistoryGame) == 0
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    room:sortByAction(effect.tos)
    for _, to in ipairs(effect.tos) do
      to:drawCards(1, skel.name)
      if not to.dead then
        room:recover { num = 1, skillName = skel.name, who = to, recoverBy = player }
      end
      if not to.dead then
        local skills = to:getSkillNameList()
        if #skills > 0 then
          local skill = room:askToChoices(to, { choices = skills, min_num = 0, max_num = 1,
          skill_name = skel.name, prompt = "#steam__guangrongjinhua-choice", detailed = true})[1]
          if skill then
            room:handleAddLoseSkills(to, "-"..skill.."|steam__rongsheng")
          end
        end
      end
    end
  end,
})

skel:addEffect(fk.Damage, {
  can_refresh = function (self, event, target, player, data)
    return target == player and player:hasSkill(skel.name, true)
  end,
  on_refresh = function (self, event, target, player, data)
    player.room:addTableMarkIfNeed(player, "steam__guangrongjinhua_record", data.to.id)
  end,
})

skel:addAcquireEffect(function (self, player, is_start)
  if is_start then return end
  local room = player.room
  local tos = {}
  room.logic:getEventsOfScope(GameEvent.Damage, 1, function(e)
    local damage = e.data
    if damage.from == player then
      table.insertIfNeed(tos, damage.to.id)
    end
  end, Player.HistoryGame)
  room:setPlayerMark(player, "steam__guangrongjinhua_record", tos)
end)

return skel
