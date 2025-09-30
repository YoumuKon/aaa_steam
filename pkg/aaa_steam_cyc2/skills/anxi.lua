local skel = fk.CreateSkill {
  name = "steam__anxi",
}

Fk:loadTranslationTable{
  ["steam__anxi"] = "暗袭",
  [":steam__anxi"] = "出牌阶段限一次，你可以使用一张【杀】/武器牌，然后随机获得一张武器牌/【杀】。",

  ["#steam__anxi"] = "暗袭：使用一张【杀】/武器牌，然后获得另一项",

  ["$steam__anxi1"] = "碾成烂泥！",
  ["$steam__anxi2"] = "入土为安！",
}

skel:addEffect("active", {
  anim_type = "offensive",
  prompt = "#steam__anxi",
  card_num = 1,
  handly_pile = true,
  card_filter = function (self, player, to_select, selected)
    if #selected ~= 0 or not table.contains(player:getHandlyIds(true), to_select) then return false end
    local card = Fk:getCardById(to_select)
    return (card.trueName == "slash" or card.sub_type == Card.SubtypeWeapon)
    and player:canUse(card, {bypass_times = true})
  end,
  target_filter = function (self, player, to, selected, selected_cards)
    if #selected_cards == 0 then return false end
    local card = Fk:getCardById(selected_cards[1])
    return card.skill:targetFilter(player, to, selected, selected_cards, card, {bypass_times = true})
  end,
  feasible = function (self, player, selected, selected_cards)
    if #selected_cards == 1 then
      local card = Fk:getCardById(selected_cards[1])
      return card.skill:feasible(player, selected, selected_cards, card)
    end
  end,
  times = function (self, player)
    return 1 - player:usedSkillTimes(skel.name, Player.HistoryPhase)
  end,
  can_use = function(self, player)
    return player:usedSkillTimes(skel.name, Player.HistoryPhase) == 0
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local card = Fk:getCardById(effect.cards[1])
    local slash = card.trueName == "slash"
    room:useCard{
      from = player,
      tos = effect.tos,
      card = card,
      extraUse = true,
    }
    if not player.dead then
      local pat = slash and ".|.|.|.|.|weapon" or "slash"
      local ids = room:getCardsFromPileByRule(pat, 1, "allPiles")
      if #ids > 0 then
        room:obtainCard(player, ids, true, fk.ReasonJustMove, player, skel.name)
      end
    end
  end,
})

return skel
