local skel = fk.CreateSkill {
  name = "steam__mengliushang",
  tags = {Skill.Limited},
}

Fk:loadTranslationTable{
  ["steam__mengliushang"] = "梦留殇",
  [":steam__mengliushang"] = "限定技，你进入濒死时，可以摸三张牌，再将至多三张牌置于一名其他角色的武将牌旁。其不能使用与之同花色的牌，且受到伤害后移去其中一张。",

  ["#steam__mengliushang-put"] = "梦留殇：将至多3张牌置于一名其他角色的武将牌旁，其不能使用同花色的牌",
  ["#steam__mengliushang-remove"] = "梦留殇：请移去一张",

  ["$steam__mengliushang1"] = "",
  ["$steam__mengliushang2"] = "",
}

skel:addEffect(fk.EnterDying, {
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(skel.name) and player:usedSkillTimes(skel.name, Player.HistoryGame) == 0
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    player:drawCards(3, skel.name)
    if player.dead or #player:getCardIds("he") < 3 then return end
    local targets = room:getOtherPlayers(player, false)
    local tos, cards = room:askToChooseCardsAndPlayers(player, {
      targets = targets, max_card_num = 3, min_card_num = 0, min_num = 1, max_num = 1, skill_name = skel.name, pattern = ".",
      prompt = "#steam__mengliushang-put", cancelable = true,
    })
    if #tos > 0 and #cards > 0 then
      local to = tos[1]
      to:addToPile(skel.name, cards, true, skel.name)
    end
  end,
})

skel:addEffect(fk.Damaged, {
  is_delay_effect = true,
  mute = true,
  can_trigger = function (self, event, target, player, data)
    return target == player and #player:getPile(skel.name) > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local cid = room:askToChooseCard(player, {
      target = player, skill_name = skel.name, prompt = "#steam__mengliushang-remove",
      flag =  { card_data = { { skel.name, player:getPile(skel.name) } } },
    })
    room:moveCardTo(cid, Card.DiscardPile, nil, fk.ReasonPutIntoDiscardPile, skel.name)
  end,
})

skel:addEffect("prohibit", {
  prohibit_use = function(self, player, card)
    local pile = player:getPile(skel.name)
    if #pile > 0 and card and card.suit ~= Card.NoSuit then
      return table.find(pile, function(id) return Fk:getCardById(id).suit == card.suit end) ~= nil
    end
  end,
})

return skel
