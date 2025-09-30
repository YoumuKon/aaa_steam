local mogu_active = fk.CreateSkill{
  name = "steam__mogu_active",
}

Fk:loadTranslationTable{
  ["steam__mogu_active"] = "摹骨",
  ["steam__mogu_active_name"] = "%arg [%arg2]",
}

mogu_active:addEffect("viewas", {
  anim_type = "offensive",
  interaction = function(self, player)
    local names = player:getMark("steam__mogu_active_names")
    names = {}
    if self.mogu_list then
      for _, id in ipairs(self.mogu_list) do
        local card = Fk:getCardById(id, true)
        if (card.type == Card.TypeBasic or card:isCommonTrick()) and not card.is_passive then
          names[card.name] = names[card.name] or {}
          table.insertIfNeed(names[card.name], card:getSuitString(true))
        end
      end
    end
    player:setMark("steam__mogu_active_names", names)

    local choices, all_choices = {}, {}
    for name, suits in pairs(names) do
      local _suits = {}
      for _, suit in ipairs(suits) do
        table.insert(_suits, Fk:translate(suit))
      end
      local mogu_active_name = "steam__mogu_active_name:::" .. name.. ":" .. table.concat(_suits, "")
      table.insert(all_choices, mogu_active_name)
      if #_suits > 0 then
        local to_use = Fk:cloneCard(name)
        if player:canUse(to_use) and not player:prohibitUse(to_use) then
          table.insert(choices, mogu_active_name)
        end
      end
    end

    if #choices == 0 then return end
    return UI.ComboBox { choices = choices, all_choices = all_choices }
  end,
  filter_pattern = function (self, player, card_name, selected)
    local suits = {"spade", "heart", "club", "diamond"}
    if self.interaction.data then
      local name = string.split(self.interaction.data, ":")
      suits = table.filter(suits, function (suit)
        return string.find(name[#name], Fk:translate("log_" .. suit)) ~= nil
      end)
      if #suits > 0 then
        return {
          max_num = 1,
          min_num = 1,
          pattern = ".|.|".. table.concat(suits, ","),
        }
      end
    else
      return
    end
  end,
  view_as = function(self, player, cards)
    if #cards ~= 1 or not self.interaction.data then return nil end
    local card = Fk:cloneCard(string.split(self.interaction.data, ":")[4])
    card:addSubcard(cards[1])
    card.skillName = mogu_active.name
    return card
  end,
})

return mogu_active
