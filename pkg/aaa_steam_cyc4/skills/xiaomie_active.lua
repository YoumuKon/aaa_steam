local skel = fk.CreateSkill {
  name = "steam__xiaomie_active",
}

Fk:loadTranslationTable{
  ["steam__xiaomie_active"] = "嚣灭",
}

skel:addEffect("active", {
  min_card_num = 1,
  target_num = 0,
  card_filter = function(self, player, to_select, selected)
    local x = #player:getTableMark("@steam__xiaomie")
    if #selected < x then
      if #selected == 0 then
        return true
      else
        return not table.find(selected, function (ids) return Fk:getCardById(ids).type == Fk:getCardById(to_select).type end)
      end
    end
  end,
  feasible = function (self, player, selected, selected_cards, card)
    local x = #player:getTableMark("@steam__xiaomie")
    local y = true
    for _, id in ipairs (selected_cards) do
      if table.find(selected_cards, function (ids) return Fk:getCardById(id).type == Fk:getCardById(ids).type and id ~= ids end) then
        y = false
      end
    end
    return #selected_cards == x and y
  end,
})

return skel
