local skel = fk.CreateSkill {
  name = "steam__zhenjue",
  tags = {Skill.Compulsory},
}

Fk:loadTranslationTable{
  ["steam__zhenjue"] = "阵决",
  [":steam__zhenjue"] = "锁定技，当一张牌结算结束进入弃牌堆后，若本回合弃牌堆中红色/黑色牌数量不多于黑色/红色牌，本回合你下一张使用的牌无视次数/距离。若均满足，你摸一张牌（每回合一次）。",

  ["@steam__zhenjue-turn"] = "阵决",
  ["zhenjue_times"] = "次数",
  ["zhenjue_dist"] = "距离",
}

skel:addEffect(fk.AfterCardsMove, {
  anim_type = "offensive",
  events = {fk.AfterCardsMove},
  times = function (_, player) -- 摸牌每回合一次
    return 1 - player:getMark("steam__zhenjue_draw-turn")
  end,
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(skel.name) then
      for _, move in ipairs(data) do
        if move.moveReason == fk.ReasonUse and move.toArea == Card.DiscardPile then
          return true
        end
      end
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local cards = {}
    room.logic:getEventsOfScope(GameEvent.MoveCards, 1, function (e)
      for _, move in ipairs(e.data) do
        if move.toArea == Card.DiscardPile then
          for _, info in ipairs(move.moveInfo) do
            if table.contains(room.discard_pile, info.cardId) then
              table.insertIfNeed(cards, info.cardId)
            end
          end
        end
      end
    end, Player.HistoryTurn)
    local red, black = 0, 0
    for _, cid in ipairs(cards) do
      if Fk:getCardById(cid).color == Card.Red then
        red = red + 1
      elseif Fk:getCardById(cid).color == Card.Black then
        black = black + 1
      end
    end
    if red <= black then
      room:addTableMarkIfNeed(player, "@steam__zhenjue-turn", "zhenjue_times")
    end
    if black <= red then
      room:addTableMarkIfNeed(player, "@steam__zhenjue-turn", "zhenjue_dist")
    end
    if red == black then
      if player:getMark("steam__zhenjue_draw-turn") == 0 then
        room:setPlayerMark(player, "steam__zhenjue_draw-turn", 1)
        player:drawCards(1, skel.name)
      end
    end
  end,
})

skel:addLoseEffect(function (self, player, is_death)
  player.room:setPlayerMark(player, "@steam__zhenjue-turn", 0)
end)

skel:addEffect(fk.PreCardUse, {
  can_refresh = function(self, event, target, player, data)
    return target == player and player:getMark("@steam__zhenjue-turn") ~= 0
  end,
  on_refresh = function(self, event, target, player, data)
    if table.contains(player:getTableMark("@steam__zhenjue-turn"), "zhenjue_times") then
      data.extraUse = true
    end
    player.room:setPlayerMark(player, "@steam__zhenjue-turn", 0)
  end,
})

skel:addEffect("targetmod", {
  bypass_times = function(self, player, skill, scope, card, to)
    return card and table.contains(player:getTableMark("@steam__zhenjue-turn"), "zhenjue_times")
  end,
  bypass_distances = function(self, player, skill, card, to)
    return card and table.contains(player:getTableMark("@steam__zhenjue-turn"), "zhenjue_dist")
  end,
})


return skel
