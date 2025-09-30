local skel = fk.CreateSkill {
  name = "steam__duanbi",
}

Fk:loadTranslationTable{
  ["steam__duanbi"] = "锻币",
  [":steam__duanbi"] = "出牌阶段限一次，你可以令任意名角色依次重铸两张牌，然后若这些牌包含四种花色或花色均相同，你将这些牌作为【无中生有】对一名角色使用。",

  ["#steam__duanbi"] = "锻币：令任意名角色依次重铸两张牌，若含四种花色或花色相同，当【无中生有】使用",
  ["#steam__duanbi-recast"] = "锻币：请重铸两张牌！",
  ["#steam__duanbi-use"] = "锻币：将这些牌作为【无中生有】对一名角色使用",

  ["$steam__duanbi1"] = "收缴故币，以旧铸新，使民有余财。",
  ["$steam__duanbi2"] = "今，若能统一蜀地币制，则利在千秋。",
}

skel:addEffect("active", {
  anim_type = "drawcard",
  prompt = "#steam__duanbi",
  card_num = 0,
  min_target_num = 1,
  card_filter = Util.FalseFunc,
  target_filter = function (self, player, to)
    return not to:isNude()
  end,
  times = function (self, player)
    return 1 - player:usedSkillTimes(skel.name, Player.HistoryPhase)
  end,
  can_use = function(self, player)
    return player:usedSkillTimes(skel.name, Player.HistoryPhase) == 0
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local tos = table.simpleClone(effect.tos)---@type ServerPlayer[]
    room:sortByAction(tos)
    local cards = {}
    for _, to in ipairs(tos) do
      if not to.dead and not to:isNude() then
        local cids = to:getCardIds("he")
        if #cids > 2 then
          cids = room:askToCards(to, { min_num = 2, max_num = 2, include_equip = true,
          skill_name = skel.name, cancelable = false, prompt = "#steam__duanbi-recast"})
        end
        table.insertTableIfNeed(cards, cids)
        room:recastCard(cids, to, skel.name)
      end
    end
    if player.dead then return end
    local suits = {}
    for _, card in ipairs(cards) do
      table.insertIfNeed(suits, Fk:getCardById(card).suit)
    end
    if #suits ~= 4 and #suits ~= 1 then return end
    cards = table.filter(cards, function (id) return room:getCardArea(id) == Card.DiscardPile end)
    if #cards > 0 then
      local card = Fk:cloneCard("ex_nihilo")
      card:addSubcards(cards)
      card.skillName = skel.name
      if player:prohibitUse(card) then return end
      local targets = table.filter(room.alive_players, function (p)
        return not player:isProhibited(p, card)
      end)
      if #targets > 0 then
        tos = room:askToChoosePlayers(player, { targets = targets, min_num = 1, max_num = 1,
        prompt = "#steam__duanbi-use", skill_name = skel.name, cancelable = false})
        room:useCard({ from = player, tos = tos, card = card, extraUse = true  })
      end
    end
  end,
})

return skel
