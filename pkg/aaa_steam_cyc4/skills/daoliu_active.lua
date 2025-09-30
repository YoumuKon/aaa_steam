local daoliu_active = fk.CreateSkill {
  name = "#steam__daoliu_active"
}

Fk:loadTranslationTable {
  ["#steam__daoliu_active"] = "导流",
}

daoliu_active:addEffect("active", {
  card_num = 1,
  target_num = 1,
  expand_pile = function (self, player)
    return self.cards
  end,
  card_filter = function(self, player, to_select, selected)
    return #selected == 0 and table.contains(self.cards, to_select)
  end,
  target_filter = function (self, player, to_select, selected, selected_cards, card, extra_data)
    return #selected == 0 and #selected_cards == 1 and
      to_select:canUseTo(Fk:getCardById(selected_cards[1]), to_select)
  end,
})

return daoliu_active
