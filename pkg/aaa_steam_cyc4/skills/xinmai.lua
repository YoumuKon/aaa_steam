local xinmai = fk.CreateSkill {
  name = "steam__xinmai",
}

Fk:loadTranslationTable{
  ["steam__xinmai"] = "心霾",
  [":steam__xinmai"] = "当你受到伤害后，你可以令场上的一张【浮雷】立即判定一次，然后你获得判定牌。",

  ["#steam__xinmai-choose"] = "心霾：你可以令场上一张【浮雷】立即判定一次并获得判定牌",

  ["$steam__xinmai1"] = "请赶快离开，拜托了！",
  ["$steam__xinmai2"] = "别过来！",
}

xinmai:addEffect(fk.Damaged, {
  anim_type = "control",
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(xinmai.name) and
      table.find(player.room.alive_players, function (p)
        return p:hasDelayedTrick("floating_thunder")
      end)
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local targets = table.filter(room.alive_players, function (p)
      return p:hasDelayedTrick("floating_thunder")
    end)
    local to = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = targets,
      skill_name = xinmai.name,
      prompt = "#steam__xinmai-choose",
      cancelable = true,
    })
    if #to > 0 then
      event:setCostData(self, {tos = to})
      return true
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local to = event:getCostData(self).tos[1]
    local cards = table.filter(to:getCardIds("j"), function (id)
      return Fk:getCardById(id).name == "floating_thunder" or
        (to:getVirtualEquip(id) and to:getVirtualEquip(id).name == "floating_thunder")
    end)
    local id = cards[1]
    if #cards > 1 then
      id = room:askToChooseCard(player, {
        target = to,
        flag = { card_data = {{ "floating_thunder", cards }} },
        skill_name = xinmai.name,
      })
    end
    local card = to:getVirtualEquip(id)
    if card == nil then
      card = Fk:getCardById(id)
    end
    local effect_data = CardEffectData:new {
      card = card,
      to = to,
      tos = { to },
      extra_data = {
        steam__xinmai = player,
      },
    }
    room:doCardEffect(effect_data)
  end,
})

xinmai:addEffect(fk.FinishJudge, {
  mute = true,
  is_delay_effect = true,
  can_trigger = function (self, event, target, player, data)
    if data.reason == "floating_thunder" and data.card and player.room:getCardArea(data.card) == Card.Processing then
      local use_event = player.room.logic:getCurrentEvent():findParent(GameEvent.CardEffect)
      return use_event and use_event.data.extra_data and use_event.data.extra_data.steam__xinmai == player and
        not player.dead
    end
  end,
  on_use = function (self, event, target, player, data)
    player.room:moveCardTo(data.card, Card.PlayerHand, player, fk.ReasonJustMove, xinmai.name, nil, true, player)
  end,
})

return xinmai
