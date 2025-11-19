local skel = fk.CreateSkill {
  name = "steam__shiwei_active",
}

Fk:loadTranslationTable{
  ["steam__shiwei_active"] = "誓卫",
}

skel:addEffect("active", {
  card_num = 1,
  target_num = 0,
  interaction = function(self, player)
    return UI.ComboBox {choices = {"steam__shiwei-give", "steam__shiwei-move"}}
  end,
  card_filter = function (self, player, to_select, selected)
    if not self.interaction.data then return end
    if self.interaction.data == "steam__shiwei-give" then
      return #selected == 0
    elseif self.interaction.data == "steam__shiwei-move" then
      return #selected == 0 and Fk:getCardById(to_select).type == Card.TypeEquip and
      Fk:currentRoom():getPlayerById(self.tos):canMoveCardIntoEquip(to_select, false)
    end
  end,
})

return skel
