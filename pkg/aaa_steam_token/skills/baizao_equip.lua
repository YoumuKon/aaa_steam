local skill = fk.CreateSkill {
  name = "steam_baizao_equip_skill&",
  attached_equip = "steam_baizao_equip",
}

Fk:loadTranslationTable{
  ["steam_baizao_equip_skill&"] = "家常小炒",
  [":steam_baizao_equip_skill&"] = "出牌阶段各限一次，你可以弃置一张基本/非基本牌，然后摸一张<a href=':steam__isElement'>属性牌</a>/<a href=':steam__isEdible'>可食用牌</a>。"..
  "此牌离开你的装备区后销毁。",
  ["#steam_baizao_equip_skill&"] = "家常小炒：请根据选择提示弃牌，然后获得一张对应的牌。",

  ["steam_baizao_equip1"] = "弃基本牌，获得属性牌",
  ["steam_baizao_equip2"] = "弃非基本牌，获得可食用牌",
}

---@param card Card
---@return boolean
--根据设计师给出的名单，穷举出的可食用牌牌表
local isEdible = function (card)
  local list = {"peach", "analeptic", "drugs", "duel", "snatch", "savage_assault", "amazing_grace", "god_salvation", "wooden_ox"}
  return card.sub_type == Card.SubtypeOffensiveRide or card.sub_type == Card.SubtypeDefensiveRide
  or table.contains(list, card.trueName)
end

---@param card Card
---@return boolean
--检索牌名中是否出现属性字眼，判断属性牌与否
local isElement = function (card)
  if card.is_damage_card then
    return string.find(Fk:translate(""..card.name, "zh_CN"), "火") ~= nil or
    string.find(Fk:translate(""..card.name, "zh_CN"), "雷") ~= nil or
    string.find(Fk:translate(""..card.name, "zh_CN"), "冰") ~= nil or
    string.find(Fk:translate(""..card.name, "zh_CN"), "水") ~= nil
  end
  return false
end

skill:addEffect("active", {
  prompt = function (self, player, selected_cards, selected_targets)
    return "#steam_baizao_equip_skill&"
  end,
  interaction = function(self, player)
    local all_choices = {"steam_baizao_equip1", "steam_baizao_equip2"}
    local choices = table.simpleClone(all_choices)
    if table.contains(player:getTableMark("steam__baizao_equip-phase"), 1) then table.removeOne(choices, "steam_baizao_equip1") end
    if table.contains(player:getTableMark("steam__baizao_equip-phase"), 2) then table.removeOne(choices, "steam_baizao_equip2") end
    if #choices > 0 then
      return UI.ComboBox { choices = choices , all_choices = all_choices}
    end
  end,
  card_num = 1,
  target_num = 0,
  can_use = function(self, player)
    return #player:getTableMark("steam__baizao_equip-phase") < 2 and not player:isNude()
  end,
  card_filter = function (self, player, to_select, selected)
    if not self.interaction.data then return end
    return #selected == 0 and ((self.interaction.data == "steam_baizao_equip1" and Fk:getCardById(to_select).type == Card.TypeBasic) 
    or (self.interaction.data == "steam_baizao_equip2" and Fk:getCardById(to_select).type ~= Card.TypeBasic))
    and not player:prohibitDiscard(Fk:getCardById(to_select)) and Fk:getCardById(to_select).name ~= "steam_baizao_equip"
  end,
  target_filter = Util.FalseFunc,
  on_use = function(self, room, effect)
    local player = effect.from
    local card = effect.cards
    if self.interaction.data == "steam_baizao_equip1" then
      room:addTableMarkIfNeed(player, "steam__baizao_equip-phase", 1)
    elseif self.interaction.data == "steam_baizao_equip2" then
      room:addTableMarkIfNeed(player, "steam__baizao_equip-phase", 2)
    end
    room:throwCard(card, skill.name, player, player)
    if player.dead then return end
    local cardb = {}
    local pileToSearch = table.simpleClone(room.draw_pile)
    table.insertTable(pileToSearch, room.discard_pile)
    if self.interaction.data == "steam_baizao_equip1" then
      cardb = table.filter(pileToSearch, function(id) return isElement(Fk:getCardById(id)) end)
      if #cardb > 0 then
        room:obtainCard(player, {table.random(cardb, 1)}, true, fk.ReasonJustMove, player, skill.name)
      end
    elseif self.interaction.data == "steam_baizao_equip2" then
      cardb = table.filter(pileToSearch, function(id) return isEdible(Fk:getCardById(id)) end)
      if #cardb > 0 then
        room:obtainCard(player, {table.random(cardb, 1)}, true, fk.ReasonJustMove, player, skill.name)
      end
    end
  end,
})

skill:addLoseEffect(function (self, player, is_start)
  player.room:setPlayerMark(player, "steam__baizao_equip-phase", 0)
end)

return skill
