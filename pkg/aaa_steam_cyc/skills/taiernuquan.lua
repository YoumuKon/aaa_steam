local skel = fk.CreateSkill {
  name = "steam__taiernuquan",
}

Fk:loadTranslationTable{
  ["steam__taiernuquan"] = "胎儿怒拳",
  [":steam__taiernuquan"] = "每回合结束时，你可以失去一个技能，视为使用一张本回合被使用过的伤害牌(无视距离)。若有目标本回合造成过伤害，你获得其一张牌。",

  ["#steam__taiernuquan-lose"] = "胎儿怒拳：请失去一个技能",
  ["#steam__taiernuquan-ask"] = "胎儿怒拳：你可以失去一个技能，视为使用一张本回合被使用过的伤害牌(无视距离)",
}

skel:addEffect(fk.TurnEnd, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(skel.name) then return end
    local skills = player:getSkillNameList()
    if #skills == 0 then return false end
    local names = {}
    player.room.logic:getEventsOfScope(GameEvent.UseCard, 1, function(e)
      local use = e.data
      if use.card.is_damage_card and not use.card.is_passive then
        table.insertIfNeed(names, use.card.name)
      end
    end, Player.HistoryTurn)
    if #names > 0 then
      event:setCostData(self, {names = names, skills = skills})
      return true
    end
  end,
  on_cost = function (self, event, target, player, data)
    local cost_data = event:getCostData(self)
    local use = player.room:askToUseVirtualCard(player, {
      name = cost_data.names, skill_name = skel.name, skip = true, prompt = "#steam__taiernuquan-ask",
      extra_data = {bypass_distances = true, bypass_times = true, extraUse = true},
    })
    if use then
      cost_data.use = use
      local choice = player.room:askToChoice(player, { choices = cost_data.skills, skill_name = skel.name, prompt = "#steam__taiernuquan-lose"})
      cost_data.choice = choice
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cost_data = event:getCostData(self)
    room:handleAddLoseSkills(player, "-"..cost_data.choice)
    local use = table.simpleClone(cost_data.use)
    room:useCard(use)
    if player.dead or not use.tos or #use.tos == 0 then return end
    local caused = {}
    room.logic:getActualDamageEvents(1, function(e) table.insert(caused, e.data.from.id) end)
    local tos = table.filter(use.tos, function (id) return table.contains(caused, id) end)
    if #tos > 0 then
      room:sortByAction(tos)
      for _, to in ipairs(tos) do
        if player.dead then return end
        if not to:isNude() then
          local cid = room:askToChooseCard(player, { target = to, flag = "he", skill_name = skel.name})
          room:obtainCard(player, cid, false, fk.ReasonPrey, player, skel.name)
        end
      end
    end
  end,
})

return skel
