local skel = fk.CreateSkill {
  name = "steam__kuangxin",
}

Fk:loadTranslationTable{
  ["steam__kuangxin"] = "狂信",
  [":steam__kuangxin"] = "准备阶段，你可以弃置一张牌。你受到伤害时，可以弃置一张牌，或防止之并失去一个技能。若如此做，你获得一张【无中生有】（若无则摸一张）。",

  ["#steam__kuangxin-discard"] = "狂信：你可以弃置一张牌，获得一张【无中生有】",
  ["steam__kuangxin_discard"] = "弃置一张牌",
  ["steam__kuangxin_lose"] = "防止之并失去技能",
  ["#steam__kuangxin-choice"] = "狂信：你即将受到 %arg 点伤害，你可以选一项，然后获得【无中生有】",
  ["#steam__kuangxin-lose"] = "狂信：失去哪个技能？",
}

skel:addEffect(fk.EventPhaseStart, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(skel.name) and player.phase == Player.Start and not player:isNude()
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local cards = room:askToDiscard(player, {
      min_num = 1, max_num = 1, skill_name = skel.name, include_equip = true,
      prompt = "#steam__kuangxin-discard", skip = true,
    })
    if #cards > 0 then
      event:setCostData(self, { cards = cards })
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:throwCard(event:getCostData(self).cards, skel.name, player, player)
    if player:isAlive() then
      local ids = room:getCardsFromPileByRule("ex_nihilo", 1, "allPiles")
      if #ids > 0 then
        room:obtainCard(player, ids, true, fk.ReasonJustMove, player, skel.name)
      else
        player:drawCards(1, skel.name)
      end
    end
  end,
})

skel:addEffect(fk.DamageInflicted, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(skel.name)
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local all_choices = {"steam__kuangxin_discard", "steam__kuangxin_lose", "Cancel"}
    local choices = table.simpleClone(all_choices)
    local skills = player:getSkillNameList()
    if #skills == 0 then
      table.remove(choices, 2)
    end
    if player:isNude() then
      table.remove(choices, 1)
    end
    if #choices < 2 then return false end
    local choice = room:askToChoice(player, { choices = choices, skill_name = skel.name, prompt = "#steam__kuangxin-choice:::"..data.damage})
    if choice == "Cancel" then return false end
    if choice == "steam__kuangxin_discard" then
      local cards = room:askToDiscard(player, {
        min_num = 1, max_num = 1, skill_name = skel.name, cancelable = false, skip = true,
        prompt = "#steam__kuangxin-discard",
      })
      if #cards == 0 then return false end
      event:setCostData(self, { cards = cards })
      return true
    else
      local skill = room:askToChoice(player, { choices = skills, skill_name = skel.name, prompt = "#steam__kuangxin-lose", detailed = true})
      event:setCostData(self, { skill = skill })
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if event:getCostData(self).cards then
      room:throwCard(event:getCostData(self).cards, skel.name, player, player)
    else
      room:handleAddLoseSkills(player, "-"..event:getCostData(self).skill)
      data:preventDamage()
    end
    if player:isAlive() then
      local ids = room:getCardsFromPileByRule("ex_nihilo", 1, "allPiles")
      if #ids > 0 then
        room:obtainCard(player, ids, true, fk.ReasonJustMove, player, skel.name)
      else
        player:drawCards(1, skel.name)
      end
    end
  end,
})

return skel
