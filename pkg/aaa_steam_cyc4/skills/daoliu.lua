local daoliu = fk.CreateSkill {
  name = "steam__daoliu",
}

Fk:loadTranslationTable{
  ["steam__daoliu"] = "导流",
  [":steam__daoliu"] = "前三轮开始时，你获得一张伤害固定为1的【浮雷】并可以令一名角色使用之。这些【浮雷】造成伤害后你摸一张牌，"..
  "进入弃牌堆后你令一名角色使用之。",

  ["#steam__daoliu-choose"] = "导流：令一名角色使用这张【浮雷】",

  ["$steam__daoliu1"] = "加油加油，我能行的！",
  ["$steam__daoliu2"] = "是时候帮助大家了。",
}

daoliu:addEffect(fk.RoundStart, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(daoliu.name) and player.room:getBanner("RoundCount") < 4
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local card = room:printCard("floating_thunder", Card.Spade, 1)
    room:addTableMarkIfNeed(player, daoliu.name, card.id)
    local banner = room:getBanner(daoliu.name) or {}
    table.insertIfNeed(banner, card.id)
    room:setBanner(daoliu.name, banner)
    room:moveCardTo(card, Card.PlayerHand, player, fk.ReasonJustMove, daoliu.name, nil, true, player)
    if not player.dead and table.contains(player:getCardIds("h"), card.id) and
      card.name == "floating_thunder" then
      local targets = table.filter(room.alive_players, function (p)
        return p:canUseTo(card, p)
      end)
      if #targets > 0 then
        local to = room:askToChoosePlayers(player, {
          min_num = 1,
          max_num = 1,
          targets = targets,
          skill_name = daoliu.name,
          prompt = "#steam__daoliu-choose",
          cancelable = true,
        })
        if #to > 0 then
          to = to[1]
          room:useCard{
            from = to,
            tos = {to},
            card = card,
          }
        end
      end
    end
  end,
})

daoliu:addEffect(fk.Damage, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(daoliu.name) and
      data.card and data.skillName == "floating_thunder_skill" and
      table.contains(player:getTableMark(daoliu.name), data.card.id)
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    player:drawCards(1, daoliu.name)
  end,
})

daoliu:addEffect(fk.AfterCardsMove, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(daoliu.name) then
      local ids = {}
      for _, move in ipairs(data) do
        if move.toArea == Card.DiscardPile then
          for _, info in ipairs(move.moveInfo) do
            if table.contains(player:getTableMark(daoliu.name), info.cardId) and
              table.contains(player.room.discard_pile, info.cardId) and
              Fk:getCardById(info.cardId).name == "floating_thunder" and
              table.find(player.room.alive_players, function (p)
                return p:canUseTo(Fk:getCardById(info.cardId), p)
              end) then
              table.insertIfNeed(ids, info.cardId)
            end
          end
        end
      end
      ids = player.room.logic:moveCardsHoldingAreaCheck(ids)
      if #ids > 0 then
        event:setCostData(self, {cards = ids})
        return true
      end
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cards = event:getCostData(self).cards or {}
    while player:hasSkill(daoliu.name) do
      cards = table.filter(cards, function (id)
        return table.contains(room.discard_pile, id) and
          Fk:getCardById(id).name == "floating_thunder" and
          table.find(room.alive_players, function (p)
            return p:canUseTo(Fk:getCardById(id), p)
          end) ~= nil
      end)
      if #cards == 0 then return end
      local success, dat = room:askToUseActiveSkill(player, {
        skill_name = "#steam__daoliu_active",
        prompt = "#steam__daoliu-choose",
        cancelable = false,
        extra_data = {
          cards = cards,
        }
      })
      if not (success and dat) then
        dat = {}
        dat.cards = cards[1]
        dat.targets = table.find(room.alive_players, function (p)
          return p:canUseTo(Fk:getCardById(cards[1]), p)
        end) or player
      end
      room:useCard{
        from = dat.targets[1],
        tos = {dat.targets[1]},
        card = Fk:getCardById(dat.cards[1]),
      }
    end
  end,
})

daoliu:addEffect(fk.PreDamage, {
  can_refresh = function (self, event, target, player, data)
    return player.seat == 1 and data.card and data.skillName == "floating_thunder_skill" and
      table.contains(player.room:getBanner(daoliu.name) or {}, data.card.id)
  end,
  on_refresh = function (self, event, target, player, data)
    data.damage = 1
  end,
})

return daoliu
