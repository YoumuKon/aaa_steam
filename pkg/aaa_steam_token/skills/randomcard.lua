local skel = fk.CreateSkill {
  name = "steam_randomcard_skill",
}


skel:addEffect("cardskill", {
  can_use = Util.FalseFunc,
})

skel:addEffect("filter", {
  global = true,
  mute = true,
  card_filter = function(self, card, player)
    return card and card:getMark("steam_randomcard-inhand") ~= 0
  end,
  view_as = function(self, player, card)
    return Fk:cloneCard(card:getMark("steam_randomcard-inhand"), card.suit, card.number)
  end,
})

skel:addEffect(fk.CardUsing, {
  global = true,
  can_refresh = function(self, event, target, player, data)
    if target == player then
      player:filterHandcards()
      if table.find(player:getCardIds("h"), function(id) return Fk:getCardById(id, true).name == "steam_randomcard" end) then
        return true
      end
    end
  end,
  on_refresh = function(self, event, target, player, data)
    for _, id in ipairs (player:getCardIds("h")) do
      if Fk:getCardById(id, true).name == "steam_randomcard" then
        player.room:setCardMark(Fk:getCardById(id), "steam_randomcard-inhand", table.random(Fk:getAllCardNames("bt"), 1)[1])
      end
    end
  end,
})

return skel
