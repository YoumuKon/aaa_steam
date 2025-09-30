local skel = fk.CreateSkill {
  name = "steam__jinjizhimen",
  tags = {Skill.Compulsory},
}

Fk:loadTranslationTable{
  ["steam__jinjizhimen"] = "禁忌之门",
  [":steam__jinjizhimen"] = "锁定技，每轮开始时，你获得一张不计入手牌上限的【桃】。若你持有以此法获得的【桃】，你一次性获得或失去至少两张牌后，摸一张牌。",
  ["@@steam__jinjizhimen"] = "禁忌之门",
}

skel:addEffect(fk.RoundStart, {
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(skel.name)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cardInfo = room:getTag("steam__jinjizhimen_peachInfo")
    if cardInfo == nil then
      cardInfo = {}
      for _, card in ipairs(Fk.cards) do
        if card.name == "peach" then
          table.insert(cardInfo, {card.suit, card.number})
        end
      end
      room:setTag("steam__jinjizhimen_peachInfo", cardInfo)
    end
    cardInfo = table.random(cardInfo)
    local card = room:printCard("peach", cardInfo[1], cardInfo[2])
    room:addTableMark(player, "steam__jinjizhimen_record", card.id)
    room:setCardMark(card, "@@steam__jinjizhimen", player.id)
    room:moveCardTo(card, Card.PlayerHand, player, fk.ReasonJustMove, skel.name, nil, true)
  end,
})

skel:addEffect(fk.AfterCardsMove, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(skel.name) and table.find(player:getCardIds("h"), function (id)
      return Fk:getCardById(id):getMark("@@steam__jinjizhimen") == player.id
    end) ~= nil then
      for _, move in ipairs(data) do
        if #move.moveInfo > 1 and ((move.from == player and move.to ~= player) or
          (move.to == player and move.toArea == Card.PlayerHand)) then
          return true
        end
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(1, skel.name)
  end,
})

skel:addEffect("maxcards", {
  exclude_from = function(self, player, card)
    return card and card:getMark("@@steam__jinjizhimen") == player.id and player:hasSkill(skel.name)
  end,
})


return skel
