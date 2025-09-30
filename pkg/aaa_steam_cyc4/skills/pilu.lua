local pilu = fk.CreateSkill{
  name = "steam__pilu",
}

Fk:loadTranslationTable{
  ["steam__pilu"] = "辟路",
  [":steam__pilu"] = "当你受到1点伤害后，你可以重铸一张牌并随机获得一张装备牌。每轮限一次，你使用武器牌后，"..
  "可以摸一张牌并对因此进入你攻击范围内的一名角色造成2点伤害。",

  ["#steam__pilu-invoke"] = "辟路：你可以重铸一张牌，随机获得一张装备牌",
  ["#steam__pilu-choose"] = "辟路：对一名角色造成2点伤害！",

  ["$steam__pilu1"] = "谁因堕落而雀跃？",
  ["$steam__pilu2"] = "你们的伤口会很醒目。",
  ["$steam__pilu3"] = "man！",
}

pilu:addEffect(fk.Damaged, {
  anim_type = "masochism",
  audio_index = 1,
  trigger_times = function(self, event, target, player, data)
    return data.damage
  end,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(pilu.name) and
      not player:isNude()
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local cards = room:askToCards(player, {
      min_num = 1,
      max_num = 1,
      include_equip = true,
      skill_name = pilu.name,
      prompt = "#steam__pilu-invoke",
      cancelable = true,
    })
    if #cards > 0 then
      event:setCostData(self, {cards = cards})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:recastCard(event:getCostData(self).cards, player, pilu.name)
    if player.dead then return end
    local cards = room:getCardsFromPileByRule( ".|.|.|.|.|equip", 1,"allPiles")
    if #cards > 0 then
      room:moveCardTo(table.random(cards), Card.PlayerHand, player, fk.ReasonJustMove, pilu.name, nil, false, player)
    end
  end,
})

pilu:addEffect(fk.CardUseFinished, {
  anim_type = "drawcard",
  audio_index = 2,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(pilu.name) and
      data.card.sub_type == Card.SubtypeWeapon and player:usedEffectTimes(self.name, Player.HistoryRound) == 0
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    player:drawCards(1, pilu.name)
    if player.dead then return end
    local targets = table.filter(room.alive_players, function (p)
      return player:inMyAttackRange(p) and not table.contains(data.extra_data.steam__pilu, p)
    end)
    if #targets > 0 then
      local to = room:askToChoosePlayers(player, {
        min_num = 1,
        max_num = 1,
        targets = targets,
        skill_name = pilu.name,
        prompt = "#steam__pilu-choose",
        cancelable = false,
      })[1]
      player:broadcastSkillInvoke(pilu.name, 3)
      room:damage{
        from = player,
        to = to,
        damage = 2,
        skillName = pilu.name,
      }
    end
  end,
})

pilu:addEffect(fk.PreCardUse, {
  can_refresh = function (self, event, target, player, data)
    return target == player and data.card.sub_type == Card.SubtypeWeapon
  end,
  on_refresh = function (self, event, target, player, data)
    data.extra_data = data.extra_data or {}
    data.extra_data.steam__pilu = table.filter(player.room.alive_players, function (p)
      return player:inMyAttackRange(p)
    end)
  end,
})

return pilu
