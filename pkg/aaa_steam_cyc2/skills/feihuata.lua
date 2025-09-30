local skel = fk.CreateSkill {
  name = "steam__feihuata",
}

Fk:loadTranslationTable{
  ["steam__feihuata"] = "飞花挞",
  [":steam__feihuata"] = "轮次开始时，你可以将一张红色牌当【乐不思蜀】对自己使用，然后摸一张牌。",

  ["#steam__feihuata-card"] = "飞花挞：你可以将一张红色牌当【乐不思蜀】对自己使用，再摸一张牌",

  ["$steam__feihuata1"] = "梦呀，真高兴你和我在一起。",
  ["$steam__feihuata2"] = "梦呀，你和我在一起很安全的。",
}

skel:addEffect(fk.RoundStart, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(skel.name) and not player:isNude()
    and not player:hasDelayedTrick("indulgence") and not table.contains(player.sealedSlots, "JudgeSlot")
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local ids = table.filter(player:getCardIds("he"), function (id)
      if Fk:getCardById(id).color == Card.Red then
        local card = Fk:cloneCard("indulgence")
        card:addSubcard(id)
        card.skillName = skel.name
        return not player:prohibitUse(card) and not player:isProhibited(player, card)
      end
    end)
    local cards = room:askToCards(player, {
      min_num = 1, max_num = 1, skill_name = skel.name, include_equip = true, pattern = tostring(Exppattern{ id = ids }),
      prompt = "#steam__feihuata-card"
    })
    if #cards > 0 then
      event:setCostData(self, { cards = cards })
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local card = Fk:cloneCard("indulgence")
    card:addSubcard(event:getCostData(self).cards[1])
    card.skillName = skel.name
    room:useCard{from = player, tos = {player}, card = card}
    if not player.dead then
      player:drawCards(1, skel.name)
    end
  end,
})



return skel
