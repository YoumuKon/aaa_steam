local guiyi = fk.CreateSkill {
  name = "steam__guiyi",
  tags = { Skill.Wake },
}

Fk:loadTranslationTable{
  ["steam__guiyi"] = "鬼役",
  [":steam__guiyi"] = "觉醒技，你攻击范围内有角色受到伤害后，你随机获得一张伤害牌，此后，你获得「死士」牌后，"..
  "令此伤害牌永久获得以下一项未拥有的效果：1.每回合结束时你收回此牌；2.每轮限一次，你可以将此牌当【酒】使用；3.失去此牌后你摸两张牌。",

  ["#steam__guiyi-prey"] = "鬼役：获得其中一张牌，你获得「死士」牌后此牌增加额外效果",
  ["@@steam__guiyi"] = "鬼役",
  ["steam__guiyi_upgrade1"] = "每回合结束时收回此牌",
  ["steam__guiyi_upgrade2"] = "每轮限一次，可以将此牌当【酒】使用",
  ["steam__guiyi_upgrade3"] = "失去此牌后你摸两张牌",
  ["#steam__guiyi"] = "鬼役：你可以将此牌当【酒】使用",

  ["$steam__guiyi1"] = "启程吧，去制造更多尸骸。",
  ["$steam__guiyi2"] = "生命枯萎消散，徒留残渣徘徊。",
}

guiyi:addEffect("viewas", {
  mute = true,
  pattern = "analeptic",
  prompt = "#steam__guiyi",
  handly_pile = true,
  card_filter = function(self, player, to_select, selected)
    return #selected == 0 and player:getMark(guiyi.name) == to_select
  end,
  view_as = function(self, player, cards)
    if #cards ~= 1 then return end
    local c = Fk:cloneCard("analeptic")
    c.skillName = guiyi.name
    c:addSubcard(cards[1])
    return c
  end,
  before_use = function (self, player, use)
    player:broadcastSkillInvoke(guiyi.name)
    player.room:notifySkillInvoked(player, "#steam__guiyi_3_trig", "support")
  end,
  enabled_at_play = function (self, player)
    return player:usedEffectTimes(self.name, Player.HistoryRound) == 0 and
      table.contains(player:getTableMark("steam__guiyi_upgrade"), 2) and
      table.find(player:getHandlyIds(), function(id)
        return player:getMark(guiyi.name) == id
      end)
  end,
  enabled_at_response = function (self, player, response)
    return not response and player:usedEffectTimes(self.name, Player.HistoryRound) == 0 and
      table.contains(player:getTableMark("steam__guiyi_upgrade"), 2) and
      table.find(player:getHandlyIds(), function(id)
        return player:getMark(guiyi.name) == id
      end)
  end,
})

guiyi:addEffect(fk.Damaged, {
  anim_type = "big",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(guiyi.name) and
      player:getMark(guiyi.name) == 0
  end,
  can_wake = function(self, event, target, player, data)
    return player:inMyAttackRange(target)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cards = table.filter(room.draw_pile, function (id)
      return Fk:getCardById(id).is_damage_card
    end)
    if #cards == 0 then return end
    local id = table.random(cards)
    room:setPlayerMark(player, guiyi.name, id)
    room:moveCardTo(id, Card.PlayerHand, player, fk.ReasonJustMove, guiyi.name, nil, false, player, "@@steam__guiyi")
  end,
})

guiyi:addEffect(fk.AfterCardsMove, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if player:getMark(guiyi.name) ~= 0 and #player:getTableMark("steam__guiyi_upgrade") < 3 then
      for _, move in ipairs(data) do
        if move.to == player and move.skillName == "steam__hunxiang" then
          return true
        end
      end
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke(guiyi.name)
    room:notifySkillInvoked(player, self.name, "special")
    local choices = table.filter({1, 2, 3}, function (n)
      return not table.contains(player:getTableMark("steam__guiyi_upgrade"), n)
    end)
    choices = table.map(choices, function (n)
      return "steam__guiyi_upgrade"..n
    end)
    local choice = room:askToChoice(player, {
      choices = choices,
      skill_name = guiyi.name,
    })
    room:addTableMark(player, "steam__guiyi_upgrade", tonumber(string.sub(choice, -1)))
  end,
})

guiyi:addEffect(fk.TurnEnd, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return player:getMark(guiyi.name) ~= 0 and table.contains(player:getTableMark("steam__guiyi_upgrade"), 1) and
      table.contains(player.room.discard_pile, player:getMark(guiyi.name))
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke(guiyi.name)
    room:notifySkillInvoked(player, self.name, "drawcard")
    room:moveCardTo(player:getMark(guiyi.name), Card.PlayerHand, player, fk.ReasonJustMove, guiyi.name, nil, true, player)
  end,
})

guiyi:addEffect(fk.AfterCardsMove, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if player:getMark(guiyi.name) ~= 0 and table.contains(player:getTableMark("steam__guiyi_upgrade"), 3) then
      for _, move in ipairs(data) do
        if move.from == player then
          for _, info in ipairs(move.moveInfo) do
            if info.cardId == player:getMark(guiyi.name) and info.fromArea == Card.PlayerHand then
              return true
            end
          end
        end
      end
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke(guiyi.name)
    room:notifySkillInvoked(player, self.name, "drawcard")
    player:drawCards(2, guiyi.name)
  end,
})

return guiyi
