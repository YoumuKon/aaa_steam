local qingxi = fk.CreateSkill {
  name = "#aaa_steam_outsider__qingxi_active",
}

qingxi:addEffect("active", {
  interaction = function(self, player)
    return UI.ComboBox{ choices = self.choices, all_choices = self.all_choices }
  end,
  prompt = function(self, player, selected_cards, selected_targets)
    if self.interaction.data then
      return "#aaa_steam_outsider__qingxi-select:::" .. self.interaction.data
    end
    return "#aaa_steam_outsider__qingxi-select:::" .. table.concat(table.map(self.choices, Util.TranslateMapper), "/")
  end,
  card_num = 0,
  card_filter = Util.FalseFunc,
  target_num = 1,
  target_filter = function(self, to_select, selected)
    return #selected == 0
  end,
})

Fk:loadTranslationTable{
  ["#aaa_steam_outsider__qingxi_active"] = "倾袭",
  ["#aaa_steam_outsider__qingxi-select"] = "倾袭：请选择令一名角色%arg一张牌",

  ["discard"] = "弃置",
  ["recast"] = "重铸",
  ["use"] = "使用",
}

return qingxi