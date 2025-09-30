local DIY = require "packages/diy_utility/diy_utility"

local skel = fk.CreateSkill {
  name = "steam__anyingtuxi",
  tags = {DIY.ReadySkill},
}

Fk:loadTranslationTable{
  ["steam__anyingtuxi"] = "暗影突袭",
  [":steam__anyingtuxi"] = "<a href='diy_ready_skill'>蓄势技</a>，出牌阶段，你可以展示任意张伤害牌，令一名其他角色可以重复执行：弃置一张牌并弃置一张被展示的同花色牌。最后，你依次对其使用剩余的展示牌。",

  ["#steam__anyingtuxi-discard"] = "暗影突袭：你可以弃置一张牌，并弃置一张同花色的展示牌",
  ["#steam__anyingtuxi"] = "暗影突袭：展示任意张伤害牌，对一名其他角色使用，其可以弃置同花色牌弃置你展示牌",

  ["$steam__anyingtuxi1"] = "刀下生，刀下死！",
  ["$steam__anyingtuxi2"] = "没有机会了！",
}

skel:addEffect("active", {
  anim_type = "big",
  min_card_num = 1,
  target_num = 1,
  prompt = "#steam__anyingtuxi",
  can_use = function(self, player)
    return true
  end,
  card_filter = function (self, player, to_select, selected)
    return Fk:getCardById(to_select).is_damage_card
  end,
  target_filter = function (self, player, to_select, selected)
    return #selected == 0 and to_select ~= player
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local to = effect.tos[1]
    local ids = table.simpleClone(effect.cards)
    player:showCards(ids)
    while not to.dead and not to:isNude() and #ids > 0 do
      local suits = {}
      for _, id in ipairs(ids) do
        table.insertIfNeed(suits, Fk:getCardById(id):getSuitString())
      end
      local discard = room:askToDiscard(to, {
        min_num = 1, max_num = 1, skill_name = skel.name, include_equip = true, pattern = ".|.|"..table.concat(suits, ","),
        skip = true, prompt = "steam__anyingtuxi-discard",
      })
      if #discard == 0 then break end
      local suit = Fk:getCardById(discard[1]).suit
      room:throwCard(discard, skel.name, to, to)
      local same = table.filter(ids, function (id)
        return table.contains(player:getCardIds("h"), id) and Fk:getCardById(id).suit == suit
      end)
      if #same > 0 then
        local cid = room:askToChooseCard(to, { target = player, flag = { card_data = { { "discard", same } } }, skill_name = skel.name})
        room:throwCard(cid, skel.name, player, to)
      end
      ids = table.filter(ids, function (id) return table.contains(player:getCardIds("h"), id) end)
    end
    while not to.dead and #ids > 0 do
      local card = Fk:getCardById(table.remove(ids, 1))
      if not player:prohibitUse(card) and not player:isProhibited(to, card) then
        room:useCard{from = player, tos = {to}, card = card, extraUse = true}
      end
      ids = table.filter(ids, function (id) return table.contains(player:getCardIds("h"), id) end)
    end
  end,
})

return skel
