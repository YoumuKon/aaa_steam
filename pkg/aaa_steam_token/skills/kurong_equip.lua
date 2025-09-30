local skill = fk.CreateSkill {
  name = "#steam_kurong_equip_skill",
  attached_equip = "steam_kurong_equip",
}

Fk:loadTranslationTable{
  ["#steam_kurong_equip_skill"] = "嫩竹",
  [":#steam_kurong_equip_skill"] = "每轮结束时，此牌攻击范围+1。每轮限一次，你使用牌时，可以弃置一张牌，额外指定一名合法目标。此牌离开装备区后销毁。",

  ["#steam_kurong_equip-target"] = "嫩竹：是否弃置一张牌以增加一个目标？",
}

skill:addEffect(fk.RoundEnd, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(skill.name)
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    player.room:addPlayerMark(player, "@steam_kurong_equip", 1)
  end,
})

skill:addEffect(fk.AfterCardsMove, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if player.dead then return end
    for _, move in ipairs(data) do
      if move.to == player and move.toArea == Card.PlayerEquip then
        for _, info in ipairs(move.moveInfo) do
          return Fk:getCardById(info.cardId).name == skill.attached_equip
        end
      end
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    for _, move in ipairs(data) do
      if move.to == player and move.toArea == Card.PlayerEquip then
        player.room:addPlayerMark(player, "@steam_kurong_equip", 1)
      end
    end
  end,
})

skill:addEffect(fk.AfterCardsMove, {
  mute = true,
  is_delay_effect = true,
  priority = 5,
  can_trigger = function(self, event, target, player, data)
    if player:getMark("@steam_kurong_equip") == 0 then return false end
    for _, move in ipairs(data) do
      for _, info in ipairs(move.moveInfo) do
        if Fk:getCardById(info.cardId).name == "steam_kurong_equip" then
          --多个木马同时移动的情况取其中之一即可，不再做冗余判断
          if info.fromArea == Card.Processing then
            local room = player.room
            --注意到一次交换事件的过程中的两次移动事件都是在一个parent事件里进行的，因此查询到parent事件为止即可
            local move_event = room.logic:getCurrentEvent():findParent(GameEvent.MoveCards, true)
            if not move_event then return end
            local parent_event = move_event.parent
            local move_events = room.logic:getEventsByRule(GameEvent.MoveCards, 1, function (e)
              if e.id >= move_event.id or e.parent ~= parent_event then return false end
              for _, last_move in ipairs(e.data) do
                if last_move.moveReason == fk.ReasonExchange and last_move.toArea == Card.Processing then
                  return true
                end
              end
            end, parent_event.id)
            if #move_events > 0 then
              for _, last_move in ipairs(move_events[1].data) do
                if last_move.moveReason == fk.ReasonExchange then
                  for _, last_info in ipairs(last_move.moveInfo) do
                    if Fk:getCardById(last_info.cardId).name == "steam_kurong_equip" then
                      if last_move.from == player and last_info.fromArea == Card.PlayerEquip then
                        if move.toArea == Card.PlayerEquip then
                          if move.to ~= player then
                            event:setCostData(self, {extra_data = move.to})
                            return true
                          end
                        else
                          event:setCostData(self, nil)
                          return true
                        end
                      end
                    end
                  end
                end
              end
            end
          elseif move.moveReason == fk.ReasonExchange then
            if move.from == player and info.fromArea == Card.PlayerEquip and move.toArea ~= Card.Processing then
              --适用于被修改了移动区域的情况，如销毁，虽然说原则上移至处理区是不应销毁的
              event:setCostData(self, nil)
              return true
            end
          elseif move.from == player and info.fromArea == Card.PlayerEquip then
            if move.toArea == Card.PlayerEquip then
              if move.to ~= player then
                event:setCostData(self, {extra_data = move.to})
                return true
              end
            else
              event:setCostData(self, nil)
              return true
            end
          end
        end
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    --直接每次都按交换处理，如果多个嫩竹的话会出现反向生长的情况，这就不怪我了ヾ(≧▽≦*)o
    if event:getCostData(self) ~= nil then
      local x, y = 0, 0
      x = x + player:getMark("@steam_kurong_equip")
      y = y + event:getCostData(self).extra_data:getMark("@steam_kurong_equip")
      room:setPlayerMark(event:getCostData(self).extra_data, "@steam_kurong_equip", x)
      room:setPlayerMark(player, "@steam_kurong_equip", y)
    else
      room:setPlayerMark(player, "@steam_kurong_equip", 0)
    end
  end
})

skill:addEffect(fk.AfterCardTargetDeclared, {
  anim_type = "control",
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:usedEffectTimes(self.name, Player.HistoryRound) == 0 and player:hasSkill(skill.name) and
    (data.card.type == Card.TypeBasic or data.card:isCommonTrick()) and not player:isNude()
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = data:getExtraTargets()
    local cards = {}
    for _, id in ipairs(player:getCardIds("he")) do
      if not player:prohibitDiscard(id) and
        not (table.contains(player:getEquipments(Card.SubtypeWeapon), id) and Fk:getCardById(id).name == skill.attached_equip) then
        table.insert(cards, id)
      end
    end
    local tos, cards = room:askToChooseCardsAndPlayers(player, {
      min_num = 1,
      max_num = 1,
      min_card_num = 1,
      max_card_num = 1,
      targets = targets,
      pattern = tostring(Exppattern{ id = cards }),
      skill_name = skill.name,
      prompt = "#steam_kurong_equip-target",
      cancelable = true,
      will_throw = true,
    })
    if #tos > 0 and #cards > 0 then
      event:setCostData(self, {tos = tos, cards = cards})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = event:getCostData(self).tos[1]
    room:throwCard(event:getCostData(self).cards, skill.name, player, player)
    if not to.dead then
      data:addTarget(to)
    end
  end,
})

return skill
