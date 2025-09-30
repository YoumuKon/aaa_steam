local skel = fk.CreateSkill {
  name = "steam__zhijin",
}

Fk:loadTranslationTable{
  ["steam__zhijin"] = "执进",
  -- 当一张牌因使用而置入弃牌堆时，若此牌被抵消过
  [":steam__zhijin"] = "一张即时牌被抵消而置入弃牌堆时，你可用此牌与一名其他角色拼点；若你拼点赢/此牌的使用者不为你，你获得对方的拼点牌/你的拼点牌。若你没赢，你对该角色造成一点伤害，然后此技能在本轮失效。",
  ["#steam__zhijin-choose"] = "执进：你可用此牌与一名其他角色拼点",

  ["$steam__zhijin1"] = "I had a purpose.I wanted to be one of the best basketball players to ever play.and anything else that was outside of that lane，I didn’t have time for.",
  ["$steam__zhijin2"] = "My brain cannot process failure.It will not process failure.",
}

skel:addEffect(fk.AfterCardsMove, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(skel.name) then return false end
    local room = player.room
    local ids = {}
    for _, move in ipairs(data) do
      if move.toArea == Card.DiscardPile and move.moveReason == fk.ReasonUse then
        for _, info in ipairs(move.moveInfo) do
          if room:getCardArea(info.cardId) == Card.DiscardPile then
            table.insert(ids, info.cardId)
          end
        end
      end
    end
    if #ids == 0 then return false end
    ids = player.room.logic:moveCardsHoldingAreaCheck(ids)
    if #ids == 0 then return false end
    local useEvent = room.logic:getCurrentEvent().parent
    if not useEvent then return false end
    if useEvent.event == GameEvent.UseCard then
      -- 延时锦囊并不会触发这个事件
      local get = useEvent.data.from ~= player
      if #useEvent:searchEvents(GameEvent.CardEffect, 1, function(e)
        local effect = e.data
        return effect.isCancellOut and e.parent == useEvent
      end) > 0 then
        event:setCostData(self, {cards = ids, get = get})
        return true
      end
    end
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local targets = table.filter(room.alive_players, function (p)
      return player:canPindian(p, true)
    end)
    if #targets == 0 then return false end
    local cost_data = event:getCostData(self)
    local ids = cost_data.cards
    local tos, cards = room:askToChooseCardsAndPlayers(player, {
      min_card_num = 1, max_card_num = 1, min_num = 1, max_num = 1, targets = targets, skill_name = skel.name,
      pattern = tostring(Exppattern{ id = ids }), prompt = "#steam__zhijin-choose",
      expand_pile = ids, extra_data = {expand_pile = ids}
    })
    if #tos > 0  then
      event:setCostData(self, { tos = tos, cards = cards, get = cost_data.get })
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = event:getCostData(self).tos[1]
    local fromCardId = event:getCostData(self).cards[1]
    local willGet = event:getCostData(self).get
    room:delay(200)
    local pindian = player:pindian({to}, skel.name, Fk:getCardById(fromCardId))
    if not player.dead then
      local win = pindian.results[to].winner == player
      local get = {}
      if win then
        local toCardId = pindian.results[to].toCard:getEffectiveId()
        if toCardId and room:getCardArea(toCardId) == Card.DiscardPile then
          table.insert(get, toCardId)
        end
      end
      if willGet and room:getCardArea(fromCardId) == Card.DiscardPile then
        table.insert(get, fromCardId)
      end
      if #get > 0 then
        room:delay(200)
        room:obtainCard(player, get, true, fk.ReasonJustMove, player, skel.name)
      end
      if not win and not to.dead then
        room:doIndicate(player, {to})
        room:damage { from = player, to = to, damage = 1, skillName = skel.name }
        if player:isAlive() then
          room:invalidateSkill(player, skel.name, "-round")
        end
      end
    end
  end,
})


return skel
