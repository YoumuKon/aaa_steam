local shewei_active = fk.CreateSkill {
  name = "#steam__shewei_active"
}

Fk:loadTranslationTable {
  ["#steam__shewei_active"] = "摄威",
}

shewei_active:addEffect("active", {
  card_num = 1,
  target_num = 0,
  interaction = UI.ComboBox {choices = { "recast", "Top" }},
  expand_pile = function (self, player)
    return player:getCardIds("j")
  end,
  card_filter = function(self, player, to_select, selected)
    return #selected == 0
  end,
})

return shewei_active
