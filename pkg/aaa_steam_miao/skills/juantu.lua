local skel = fk.CreateSkill {
  name = "steam__juantu",
}

Fk:loadTranslationTable{
  ["steam__juantu"] = "卷土",
  [":steam__juantu"] = "每回合限一次，一名其他角色于其回合内使用牌时，若其本回合至少使用四张牌，你可以摸四张牌，若如此做，你须移去一个武将牌上的技能并发动之。",

  ["#steam__juantu-invoke"] = "卷土：你可以摸 %arg 张牌，然后移去一个武将牌上的技能并发动之",
  ["#steam__juantu-choice"] = "卷土：请选择一个技能，移去并发动之",

  ["$steam__juantu1"] = "Wer versucht, alles auf einmal festzuhalten, hält am Ende gar nichts mehr fest.（如果你试图一次解决所有问题，那就什么也做不到。）",
}

skel:addEffect(fk.CardUsing, {
  anim_type = "drawcard",
  can_trigger = function (self, event, target, player, data)
    if player:hasSkill(skel.name) and target.phase ~= Player.NotActive and target ~= player and player:usedSkillTimes(skel.name) == 0 then
      return #player.room.logic:getEventsOfScope(GameEvent.UseCard, 4, function(e)
        local use = e.data
        return use.from == target
      end, Player.HistoryTurn) > 3
    end
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    if data["steam__juantu"] ~= nil or room:askToSkillInvoke(player, { skill_name = skel.name, prompt = "#steam__juantu-invoke:::4" }) then
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:drawCards(4, skel.name)
    if player.dead then return end
    local all_choices = {"steam__shanji", "steam__tuique", skel.name}
    local choices = table.filter(all_choices, function (skill)
      return table.contains(player:getSkillNameList(), skill)
    end)
    if #choices == 0 then -- 小心各种奇怪的发动方法
      room:invalidateSkill(player, skel.name, "-turn")
      return
    end
    local skill = room:askToChoice(player, {
      choices = choices, skill_name = skel.name, all_choices = all_choices,
      detailed = true, prompt = "#steam__juantu-choice",
    })
    room:handleAddLoseSkills(player, "-" .. skill)
    local triggerSkill = Fk.skills[skill]---@type TriggerSkill
    if triggerSkill and triggerSkill:isInstanceOf(TriggerSkill) then
      local event_data = {}
      local event_class = triggerSkill.event
      if event_class == fk.CardUsing then -- 伪造data中
        event_data = UseCardData:new(data)
      else
        event_data = PhaseData:new{
          who = player,
          reason = "game_rule",
          phase = player.phase,
        }
      end
      event_data[skel.name] = true
      local event_obj = event_class:new(room, target, event_data)
      triggerSkill:doCost(event_obj, player, player, event_data)
    end
  end,
})



return skel
