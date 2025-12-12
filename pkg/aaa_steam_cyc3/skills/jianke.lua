local skel = fk.CreateSkill{
  name = "steam__jianke",
}

Fk:loadTranslationTable{
  ["steam__jianke"] = "坚壳",
  [":steam__jianke"] = "游戏开始时，你获得一张防具牌并可以使用。若你的装备区内有防具牌，你每回合首次被使用伤害牌时摸一张牌；反之，你每回合首次造成或受到伤害时摸一张牌。",

  ["$steam__jianke1"] = " ",
  ["$steam__jianke2"] = " ",
}

local U = require "packages.utility.utility"

--隐藏结算，每种防具牌只有一张
local jianke_list = {
  {"eight_diagram", Card.Spade, 2},
  {"nioh_shield", Card.Club, 2}, 
  {"silver_lion", Card.Club, 1},
  {"vine", Card.Club, 2}, 
  {"breastplate", Card.Club, 1},
  {"dark_armor", Card.Club, 2},
  {"glittery_armor", Card.Club, 2},
  {"night_cloth", Card.Spade, 10}
}

--隐藏结算，每轮获得的防具牌不与上一轮相同
skel:addEffect(fk.GameStart, {
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(skel.name)
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local randomplay = {}
    for _, list in ipairs (jianke_list) do
      if table.contains(Fk.all_card_names, list[1]) and player:getMark(skel.name) ~= list[1] then
        table.insert(randomplay, list)
      end
    end
    if #randomplay > 0 then
      local get = table.filter(U.prepareDeriveCards(room, randomplay, "steam__jianke_list"), function (id)
        return room:getCardArea(id) == Card.Void
      end)
      local deal
      deal = table.random(get, 1)[1]
      room:setCardMark(Fk:getCardById(deal), MarkEnum.DestructOutEquip, 1)
      room:setPlayerMark(player, skel.name, Fk:getCardById(deal).name)
      room:moveCardTo(deal, Card.PlayerHand, player, fk.ReasonJustMove, skel.name, nil, true, player)
      if not player.dead and player:canUse(Fk:getCardById(deal)) and table.contains(player:getCardIds("h"), deal) then
        room:askToUseRealCard(player, {pattern = {deal}, skill_name = skel.name, cancelable = true,})
      end
    end
  end,
})

skel:addEffect(fk.CardUsing, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return data.card.is_damage_card and player:hasSkill(skel.name) and player:getEquipment(Card.SubtypeArmor)
      and player:usedEffectTimes(self.name, Player.HistoryTurn) == 0 and table.contains(data.tos, player)
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    player:drawCards(1, skel.name)
  end,
})

skel:addEffect(fk.DamageCaused, {
  anim_type = "masochism",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(skel.name) and target == player and not player:getEquipment(Card.SubtypeArmor)
    and player:usedEffectTimes(self.name, Player.HistoryTurn) == 0
    and #player.room.logic:getActualDamageEvents(1, function(e) return e.data.from == player end, Player.HistoryTurn) == 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    player:drawCards(1, skel.name)
  end,
})

skel:addEffect(fk.DamageInflicted, {
  anim_type = "masochism",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(skel.name) and target == player and not player:getEquipment(Card.SubtypeArmor)
    and player:usedEffectTimes(self.name, Player.HistoryTurn) == 0
    and #player.room.logic:getActualDamageEvents(1, function(e) return e.data.to == player end, Player.HistoryTurn) == 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    player:drawCards(1, skel.name)
  end,
})

return skel
