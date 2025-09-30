local skel = fk.CreateSkill {
  name = "steam__mingzhao",
}

Fk:loadTranslationTable{
  ["steam__mingzhao"] = "冥召",
  [":steam__mingzhao"] = "每个回合开始时，你观看牌堆顶的一张牌。若你没有该类别或该花色的手牌，你可以展示并获得之。",

  ["#steam__mingzhao-watch"] = "冥召：请观看牌堆顶牌",
  ["prey"] = "获得",

  ["$steam__mingzhao1"] = "那米诺比斯",
  ["$steam__mingzhao2"] = "阿娜码去那大嘟",
  ["$steam__mingzhao3"] = "噶~怒夺艾勒梅",
  ["$steam__mingzhao4"] = "多斯达葛干嘟",
}

skel:addEffect(fk.TurnStart, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(skel.name)
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local cards = room:getNCards(1)
    local card = Fk:getCardById(cards[1])
    local choices = {"Cancel"}
    local hand = player.player_cards[Player.Hand]
    if table.every(hand, function (id) return Fk:getCardById(id).suit ~= card.suit end)
     or table.every(hand, function (id) return Fk:getCardById(id).type ~= card.type end) then
      table.insert(choices, 1, "prey")
    end
    local ch = room:askToViewCardsAndChoice(player, {
      cards = cards, choices = choices, skill_name = skel.name, prompt = "#steam__mingzhao-watch",
    })
    if ch ~= "Cancel" then
      room:showCards(cards)
      room:obtainCard(player, cards, true, fk.ReasonJustMove, player, skel.name)
    end
  end,
})

return skel
