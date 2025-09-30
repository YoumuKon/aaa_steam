local skel = fk.CreateSkill {
  name = "godhanxin__manglong",
}

Fk:loadTranslationTable{
  ["godhanxin__manglong"] = "盲龙",
  [":godhanxin__manglong"] = "你使用【杀】造成伤害后，你可以从牌堆中随机获得其手牌拥有的花色的牌各一张。",

  ["$godhanxin__manglong"] = "眼见为虚心听则实，第三枪，盲龙！",
}

skel:addEffect(fk.Damage, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(skel.name) and data.card and data.card.trueName == "slash" and
      not data.to:isKongcheng()-- and player.room.logic:damageByCardEffect()
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local suits = {}
    local hand = data.to:getCardIds("h")
    for _, id in ipairs(hand) do
      table.insertIfNeed(suits, Fk:getCardById(id).suit)
    end
    local cards = {}
    local pile = table.simpleClone(room.draw_pile)
    while #suits > 0 and #pile > 0 do
      local id = table.remove(pile, math.random(#pile))
      if table.removeOne(suits, Fk:getCardById(id).suit) then
        table.insert(cards, id)
      end
    end
    if #cards > 0 then
      room:obtainCard(player, cards, false, fk.ReasonJustMove, player, skel.name)
    end
  end,
})



return skel
