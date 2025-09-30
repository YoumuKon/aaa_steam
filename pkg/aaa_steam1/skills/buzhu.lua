local skel = fk.CreateSkill {
  name = "steam__buzhu",
}

Fk:loadTranslationTable{
  ["steam__buzhu"] = "补筑",
  [":steam__buzhu"] = "出牌阶段，你可以弃置任意张可以使用的非装备牌，令一名角色从牌堆获得等量张装备牌，若其有对应的空置装备栏，使用之。",

  ["#steam__buzhu"] = "补筑:弃置任意张可以使用的非装备牌，令一名角色获得等量张装备牌",
  ["#steam__buzhu-use"] = "补筑：请选择一张装备牌使用！",
  ["@@steam__buzhu_card"] = "补筑",
}

skel:addEffect("active", {
  anim_type = "support",
  min_card_num = 1,
  target_num = 1,
  prompt = "#steam__buzhu",
  card_filter = function (self, player, to_select, selected)
    return Fk:getCardById(to_select).type ~= Card.TypeEquip
    and not player:prohibitUse(Fk:getCardById(to_select)) and player:canUse(Fk:getCardById(to_select))
  end,
  target_filter = function (self, player, to_select, selected, selected_cards)
    return #selected == 0 and #selected_cards > 0
  end,
  can_use = function(self, player)
    return not player:isKongcheng()
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local to = effect.tos[1]
    room:throwCard(effect.cards, self.name, player, player)
    if to.dead then return end
    local ids = room:getCardsFromPileByRule(".|.|.|.|.|equip", #effect.cards)
    if #ids == 0 then return end
    room:obtainCard(to, ids, true, fk.ReasonJustMove, player, self.name)
    while to:isAlive() do
      ids = table.filter(ids, function(id)
        return table.contains(to:getCardIds("h"), id)
      end)
      -- stupid filter skill...
      for _, id in ipairs(ids) do
        Fk:filterCard(id, to)
      end
      ids = table.filter(ids, function(id)
        return Fk:getCardById(id).type == Card.TypeEquip and to:canUseTo(Fk:getCardById(id), to)
        and to:hasEmptyEquipSlot(Fk:getCardById(id).sub_type)
      end)
      if #ids == 0 then break end
      local cid = table.random(ids)
      local same = table.filter(ids, function(id)
        return Fk:getCardById(cid).sub_type == Fk:getCardById(id).sub_type
      end)
      if #same > 1 then
        same = room:askToCards(to, {
          min_num = 1, max_num = 1, skill_name = skel.name, cancelable = false, pattern = tostring(Exppattern{ id = same }),
          prompt = "#steam__buzhu-use",
        })
      end
      table.removeOne(ids, same[1])
      room:useCard{from = to, tos = {to}, card = Fk:getCardById(same[1])}
    end
  end,
})



return skel
