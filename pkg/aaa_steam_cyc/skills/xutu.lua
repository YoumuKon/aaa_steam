local pilename = "steam_supplies"

local skel = fk.CreateSkill {
  name = "steam__xutu",
  derived_piles = pilename,
}

Fk:loadTranslationTable{
  ["steam__xutu"] = "徐图",
  [":steam__xutu"] = "每个结束阶段，你将本回合弃牌堆的一张牌与一张“资”交换，然后若“资”花色或点数相同，你分配一张“资”，弃置任意张牌并获得等量“资”，最后移除所有“资”再补至三张。",

  [pilename] = "资",
  ["#steam__xutu-give"] = "徐图：令一名角色获得“资”",
  ["#steam__xutu-discard"] = "徐图：弃置任意张牌获得等量“资”",
  ["#steam__xutu-get"] = "徐图：获得等量“资”",
  ["#steam__xutu-exchange"] = "徐图：将本回合弃牌堆的一张牌与一张“资”交换",
}

Fk:addPoxiMethod{
  name = "steam__xutu",
  prompt = function (data, extra_data)
    return "#steam__xutu-exchange"
  end,
  card_filter = function (to_select, selected, data, extra_data)
    if data and #selected < 2 then
      for _, id in ipairs(selected) do
        for _, v in ipairs(data) do
          if table.contains(v[2], id) and table.contains(v[2], to_select) then
            return false
          end
        end
      end
      return true
    end
  end,
  feasible = function(selected, data)
    return data and #selected == 2
  end,
  default_choice = function(data)
    if not data then return {} end
    local cids = table.map(data, function(v) return v[2][1] end)
    return cids
  end,
}

skel:addEffect(fk.EventPhaseStart, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(skel.name) then return false end
    if target.phase == Player.Finish and #player:getPile(pilename) > 0 then
      local cards = {}
      player.room.logic:getEventsOfScope(GameEvent.MoveCards, 1, function (e)
        for _, move in ipairs(e.data) do
          if move.toArea == Card.DiscardPile then
            for _, info in ipairs(move.moveInfo) do
              if player.room:getCardArea(info.cardId) == Card.DiscardPile then
                table.insertIfNeed(cards, info.cardId)
              end
            end
          end
        end
      end, Player.HistoryTurn)
      if #cards > 0 then
        event:setCostData(self, {cards = cards})
        return true
      end
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local card_data = {
      {pilename, player:getPile(pilename)},
      {"pile_discard", event:getCostData(self).cards},
    }
    local cards = room:askToPoxi(player, {
      poxi_type = skel.name,
      data = card_data,
      cancelable = false,
    })
    if #cards ~= 2 then return end
    local cards1, cards2 = {cards[1]}, {cards[2]}
    if table.contains(player:getPile(pilename), cards[2]) then
      cards1, cards2 = {cards[2]}, {cards[1]}
    end
    room:moveCards({
      ids = cards1,
      from = player,
      toArea = Card.DiscardPile,
      moveReason = fk.ReasonExchange,
      skillName = skel.name,
      proposer = player,
      moveVisible = true,
    },
    {
      ids = cards2,
      to = player,
      toArea = Card.PlayerSpecial,
      specialName = pilename,
      moveReason = fk.ReasonExchange,
      skillName = skel.name,
      proposer = player,
      moveVisible = true,
    })
    if player.dead then return end
    local pile = player:getPile(pilename)
    if #pile > 0 and
      (table.every(pile, function (id)
        return Fk:getCardById(id).number == Fk:getCardById(pile[1]).number
      end) or
      table.every(pile, function (id)
        return Fk:getCardById(id):compareSuitWith(Fk:getCardById(pile[1]))
      end)) then
      --[[
      local to = room:askToChoosePlayers(player, {
        min_num = 1,
        max_num = 1,
        targets = room.alive_players,
        skill_name = skel.name,
        prompt = "#steam__xutu-give",
        cancelable = false,
      })[1]
      room:moveCardTo(player:getPile(pilename), Card.PlayerHand, to, fk.ReasonJustMove, skel.name, nil, true, to)
      --]]
      local tos, give = room:askToChooseCardsAndPlayers(player, {
        min_num = 1,
        max_num = 1,
        min_card_num = 1,
        max_card_num = 1,
        targets = room.alive_players,
        skill_name = skel.name,
        prompt = "#steam__xutu-give",
        cancelable = false,
        expand_pile = pilename,
        pattern = ".|.|.|"..pilename,
      })
      room:moveCardTo(give, Card.PlayerHand, tos[1], fk.ReasonJustMove, skel.name, nil, true, player)
      local rest = #player:getPile(pilename)
      if rest > 0 and not player.dead and not player:isNude() then
        local discards = room:askToDiscard(player, {
          min_num = 1, max_num = rest, include_equip = true, cancelable = true, skill_name = skel.name,
          prompt = "#steam__xutu-discard"
        })
        if #discards > 0 and not player.dead then
          local get = player:getPile(pilename)
          if #get > #discards then
            get = room:askToChooseCards(player, {
              target = player, skill_name = skel.name, prompt = "#steam__xutu-get",
              min = #discards, max = #discards,
              flag = { card_data = { { pilename, get } } }
            })
          end
          if #get > 0 then
            room:moveCardTo(get, Card.PlayerHand, player, fk.ReasonJustMove, skel.name, nil, true, player)
          end
        end
      end
      pile = player:getPile(pilename)
      if #pile > 0 then
        room:moveCardTo(pile, Card.DiscardPile, nil, fk.ReasonPutIntoDiscardPile, skel.name, nil, true)
      end
      if player:hasSkill(skel.name) and #player:getPile(pilename) < 3 then
        player:addToPile(pilename, room:getNCards(3 - #player:getPile(pilename)), true, skel.name)
      end
    end
  end,
})

return skel
