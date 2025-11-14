local skel = fk.CreateSkill {
  name = "steam__kanshishou",
}

Fk:loadTranslationTable{
  ["steam__kanshishou"] = "看试手",
  [":steam__kanshishou"] = "准备阶段或结束阶段，你可以视为使用一张未以此法使用过的普通锦囊牌，若未造成伤害，本局游戏你的此锦囊牌"..
  "视为【杀】。",

  ["@$steam__kanshishou"] = "看试手",
  ["#steam__kanshishou-ask"] = "看试手：你可以视为使用其中一张牌",
}

local U = require "packages.utility.utility"

skel:addEffect(fk.EventPhaseStart, {
  anim_type = "special",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(skel.name) and (player.phase == Player.Start or player.phase == Player.Finish) and
      table.find(Fk:getAllCardNames("t"), function (name)
        return not table.contains(player:getTableMark("@$steam__kanshishou"), name)
      end)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local cards = table.filter(U.getUniversalCards(room, "t"), function (id)
      return not table.contains(player:getTableMark("@$steam__kanshishou"), Fk:getCardById(id).name)
    end)
    local use = room:askToUseRealCard(player, {
      skill_name = skel.name, prompt = "#steam__kanshishou-ask", skip = true, pattern = cards,
      expand_pile = cards, extra_data = {expand_pile = cards},
    })
    if use then
      event:setCostData(self, {use = use})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local costData = event:getCostData(self).use---@type UseCardDataSpec
    local card = Fk:cloneCard(costData.card.name)
    card.skillName = skel.name
    room:addTableMark(player, "@$steam__kanshishou", card.name)
    player:filterHandcards()
    local use = {
      card = card,
      from = player,
      tos = costData.tos,
    }
    room:useCard(use)
    if not use.damageDealt and not player.dead then
      room:addTableMark(player, skel.name, card.name)
    end
  end,
})

skel:addEffect("filter", {
  anim_type = "offensive",
  card_filter = function(self, to_select, player)
    return table.contains(player:getTableMark(skel.name), to_select.name) and
      table.contains(player:getCardIds("h"), to_select.id)
  end,
  view_as = function(self, _, to_select)
    local card = Fk:cloneCard("slash", to_select.suit, to_select.number)
    card.skillName = skel.name
    return card
  end,
})

return skel
