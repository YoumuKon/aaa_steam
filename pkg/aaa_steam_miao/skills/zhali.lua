local skel = fk.CreateSkill {
  name = "steam__zhali",
}

Fk:loadTranslationTable{
  ["steam__zhali"] = "诈立",
  [":steam__zhali"] = "一名角色的准备阶段，当你受到伤害后，你可以弃置X张牌，视为使用一张本回合未被使用过的伤害牌。若你不为主公，且在一回合内以此法使用第三张牌后，你获得“叛附”。（X为此技能本轮发动次数，且至少为1）",

  ["#steam__zhali-discard"] = "诈立：你可以弃置 %arg 张牌，视为使用一张本回合未被使用过的伤害牌",
  ["#steam__zhali-throw"] = "诈立：你可以弃置 %src 的 %arg 张牌，视为使用一张本回合未被使用过的伤害牌",

  ["$steam__zhali1"] = "吾拔剑惊汝，特无心嬉戏耳。", -- 正常发动
  ["$steam__zhali2"] = "若说三声不允，叫你来时有路，去时无门！", -- 正常发动
  ["$steam__zhali3"] = "期运有变，无德让有德，自古皆然！", -- 获得“叛附”
  ["$steam__zhali4"] = "天子为万人主，此昏君何用？可将大位与我！", -- 获得“叛附”
  ["$steam__zhali5"] = "唐皇有甚亏汝？逆贼尚敢复言！", -- 拥有“叛附”时发动
  ["$steam__zhali6"] = "斩草若不除根，恐后复发矣。", -- 拥有“叛附”时发动
}


local on_cost = function(self, event, target, player, data)
  local room = player.room
  local x = math.max(1, player:usedSkillTimes(skel.name, Player.HistoryRound))
  local current = room.current
  if player:hasSkill("steam__panfu") and current.kingdom == player.kingdom then
    if player.room:askToSkillInvoke(player, { skill_name = skel.name, prompt = "#steam__zhali-throw:"..current.id.."::"..x }) then
      local cards = room:askToChooseCards(player, { target = current, min = x, max = x, flag = "he", skill_name = skel.name})
      event:setCostData(self, {tos = {current}, cards = cards})
      return true
    end
  else
    local cards = room:askToDiscard(player, { min_num = x, max_num = x, include_equip = true, skill_name = skel.name,
      cancelable = true, skip = true, prompt = "#steam__zhali-discard:::"..x })
    if #cards > 0 then
      event:setCostData(self, {cards = cards})
      return true
    end
  end
end

local on_use = function(self, event, target, player, data)
  local room = player.room
  room:notifySkillInvoked(player, skel.name, "offensive")
  player:broadcastSkillInvoke(skel.name, player:hasSkill("steam__panfu") and math.random(5, 6) or math.random(1, 2))
  local cost_cards = event:getCostData(self).cards
  local owner = room:getCardOwner(cost_cards[1])
  room:throwCard(cost_cards, skel.name, owner, player)
  if player.dead then return end
  local names = table.filter(Fk:getAllCardNames("bt"), function (name)
    local card = Fk:cloneCard(name)
    card.skillName = skel.name
    return card.is_damage_card and not player:prohibitUse(card) and player:canUse(card)
  end)
  local used = {}
  room.logic:getEventsOfScope(GameEvent.UseCard, 1, function(e)
    local use = e.data
    table.insertIfNeed(used, use.card.trueName)
  end, Player.HistoryTurn)
  names = table.filter(names, function (name)
    return not table.contains(used, Fk:cloneCard(name).trueName)
  end)
  if #names == 0 then return end
  room:askToUseVirtualCard(player, {
    name = names, skill_name = skel.name, cancelable = false, skip = false,
  })
end

skel:addEffect(fk.EventPhaseStart, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(skel.name) then return end
    if target.phase == Player.Start then
      local current = player.room.current
      local x = math.max(1, player:usedSkillTimes(skel.name, Player.HistoryRound))
      if player:hasSkill("steam__panfu") and current.kingdom == player.kingdom then
        return #current:getCardIds("he") >= x
      else
        return #player:getCardIds("he") >= x
      end
    end
  end,
  on_cost = on_cost,
  on_use = on_use,
})

skel:addEffect(fk.Damaged, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(skel.name) then return end
    if target == player then
      local current = player.room.current
      local x = math.max(1, player:usedSkillTimes(skel.name, Player.HistoryRound))
      if player:hasSkill("steam__panfu") and current.kingdom == player.kingdom then
        return #current:getCardIds("he") >= x
      else
        return #player:getCardIds("he") >= x
      end
    end
  end,
  on_cost = on_cost,
  on_use = on_use,
})

--- 若你不为主公，且在一回合内以此法使用第三张牌后，你获得“叛附”
skel:addEffect(fk.CardUseFinished, {
  mute = true,
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(skel.name) and target == player and player.role ~= "lord" and not player:hasSkill("steam__panfu", true) then
      local useEvents = player.room.logic:getEventsOfScope(GameEvent.UseCard, 3, function(e)
        local use = e.data
        return use.from == player and table.contains(data.card.skillNames, skel.name)
      end, Player.HistoryTurn)
      return #useEvents == 3 and useEvents[3].data == data
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:notifySkillInvoked(player, skel.name, "big")
    player:broadcastSkillInvoke(skel.name, math.random(3, 4))
    room:handleAddLoseSkills(player, "steam__panfu")
  end,
})


return skel
