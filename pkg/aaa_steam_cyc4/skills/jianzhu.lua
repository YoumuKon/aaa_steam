local jianzhu = fk.CreateSkill{
  name = "steam__jianzhu",
}

Fk:loadTranslationTable{
  ["steam__jianzhu"] = "坚伫",
  [":steam__jianzhu"] = "轮次开始时，你可以弃置任意张牌并选择等量个非武器栏，随机使用对应副类别的牌各一张。"..
  "你的装备区内每有一张以此法使用的牌，你与其他角色计算距离时便+1。",

  ["#steam__jianzhu-invoke"] = "坚伫：弃置任意张牌，随机使用任意张非武器装备牌",
  ["#steam__jianzhu-choice"] = "坚伫：选择要使用的装备牌副类别",

  ["$steam__jianzhu1"] = "走。",
  ["$steam__jianzhu2"] = "你会看到你想要的结果",
}

jianzhu:addEffect(fk.RoundStart, {
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(jianzhu.name) and
      not player:isNude() and
      table.find({
        Card.SubtypeArmor,
        Card.SubtypeDefensiveRide,
        Card.SubtypeOffensiveRide,
        Card.SubtypeTreasure
      }, function (t)
        return #player:getAvailableEquipSlots(t) > 0
      end)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local subtypes = table.filter({
      Card.SubtypeArmor,
      Card.SubtypeDefensiveRide,
      Card.SubtypeOffensiveRide,
      Card.SubtypeTreasure
    }, function (t)
      return #player:getAvailableEquipSlots(t) > 0
    end)
    local cards = room:askToDiscard(player, {
      min_num = 1,
      max_num = #subtypes,
      include_equip = true,
      skill_name = jianzhu.name,
      prompt = "#steam__jianzhu-invoke",
      cancelable = true,
      skip = true,
    })
    if #cards > 0 then
      local choices = room:askToChoices(player, {
        choices = table.map(subtypes, function (t)
          return Util.convertSubtypeAndEquipSlot(t)
        end),
        min_num = #cards,
        max_num = #cards,
        skill_name = jianzhu.name,
        prompt = "#steam__jianzhu-choice",
        cancelable = false,
      })
      event:setCostData(self, {cards = cards, choices = choices})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:throwCard(event:getCostData(self).cards, jianzhu.name, player, player)
    if player.dead then return end
    local subtypes = table.map(event:getCostData(self).choices, function (t)
      return Util.convertSubtypeAndEquipSlot(t)
    end)
    for _, sub_type in ipairs(subtypes) do
      local equips = table.filter(table.connect(room.draw_pile, room.discard_pile), function (id)
        local c = Fk:getCardById(id)
        return c.sub_type == sub_type and player:canUseTo(c, player)
      end)
      if #equips > 0 then
        local id = table.random(equips)
        room:addTableMarkIfNeed(player, jianzhu.name, id)
        room:useCard({
          from = player,
          tos = {player},
          card = Fk:getCardById(id),
        })
        if player.dead then return end
      end
    end
  end,
})

jianzhu:addEffect(fk.AfterCardsMove, {
  can_refresh = function (self, event, target, player, data)
    if #player:getTableMark(jianzhu.name) > 0 then
      for _, move in ipairs(data) do
        if move.from == player or move.to == player then
          return true
        end
      end
    end
  end,
  on_refresh = function (self, event, target, player, data)
    local mark = table.filter(player:getTableMark(jianzhu.name), function (id)
      return table.contains(player:getCardIds("e"), id)
    end)
    player.room:setPlayerMark(player, jianzhu.name, mark)
  end,
})

jianzhu:addEffect("distance", {
  correct_func = function (self, from, to)
    if from:hasSkill(jianzhu.name) then
      return #from:getTableMark(jianzhu.name)
    end
  end,
})

return jianzhu
