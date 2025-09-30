local skel = fk.CreateSkill {
  name = "steam__zhuohun",
}

Fk:loadTranslationTable{
  ["steam__zhuohun"] = "灼魂",
  [":steam__zhuohun"] = "你每回合首次造成或受到伤害后，可以弃置所有手牌并摸三张牌；再次造成或受到伤害后，可以失去所有体力并将体力回复至上限。",

  ["#steam__zhuohun1-invoke"] = "灼魂：是否弃置所有手牌，然后摸三张牌？",
  ["#steam__zhuohun2-invoke"] = "灼魂：是否失去所有体力，然后回复体力至上限？",

  ["$steam__zhuohun1"] = "父亲的武艺，我已掌握大半。",
  ["$steam__zhuohun2"] = "有青龙偃月刀在，小女必胜。",
}

local spec = {
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(skel.name) then
      local times
      for i = 1, 2, 1 do
        local events = player.room.logic:getActualDamageEvents(i, function(e)
          if event.class == fk.Damage then
            return e.data.from == player
          elseif event.class == fk.Damaged then
            return e.data.to == player
          end
        end, Player.HistoryTurn)
        if #events == i and events[i].data == data then
          if i == 1 and table.find(player:getCardIds("h"), function (id)
            return not player:prohibitDiscard(id)
          end) then
            times = 1
          elseif i == 2 and player.hp > 0 then
            times = 2
          end
        end
      end
      if times then
        event:setCostData(self, {times = times, anim_type = times == 1 and "drawcard" or "support" })
        return true
      end
    end
  end,
  on_cost = function (self, event, target, player, data)
    local times = event:getCostData(self).times
    return player.room:askToSkillInvoke(player, { skill_name = skel.name, prompt = "#steam__zhuohun"..times.."-invoke"})
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local times = event:getCostData(self).times
    if times == 1 then
      player:throwAllCards("h")
      if not player.dead then
        player:drawCards(3, skel.name)
      end
    elseif times == 2 then
      room:loseHp(player, player.hp, skel.name)
      if player:isWounded() and not player.dead then
        room:recover{
          who = player,
          num = player.maxHp - player.hp,
          recoverBy = player,
          skillName = skel.name,
        }
      end
    end
  end,
}

skel:addEffect(fk.Damage, {
  can_trigger = spec.can_trigger,
  on_cost = spec.on_cost,
  on_use = spec.on_use,
})

skel:addEffect(fk.Damaged, {
  can_trigger = spec.can_trigger,
  on_cost = spec.on_cost,
  on_use = spec.on_use,
})

return skel
