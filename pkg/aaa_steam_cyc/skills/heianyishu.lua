local skel = fk.CreateSkill {
  name = "steam__heianyishu",
}

Fk:loadTranslationTable{
  ["steam__heianyishu"] = "黑暗艺术",
  [":steam__heianyishu"] = "你失去一张黑色手牌后，可以随机移出其他角色各一张非【影】牌直到下回合开始，并令所有角色各获得一张回合结束时会销毁的【影】。",

  ["$steam__heianyishu_pile"] = "暗艺",
}

local U = require "packages/utility/utility"

skel:addEffect(fk.AfterCardsMove, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(skel.name) then return false end
    for _, move in ipairs(data) do
      if move.from == player and move.skillName ~= "steam__heianyishu_distroy" then
        for _, info in ipairs(move.moveInfo) do
          if info.fromArea == Player.Hand then
            if Fk:getCardById(info.cardId).color == Card.Black then
              return true
            end
          end
        end
      end
    end
  end,
  trigger_times = function (self, event, target, player, data)
    local n = 0
    for _, move in ipairs(data) do
      if move.from == player and move.skillName ~= "steam__heianyishu_distroy" then
        for _, info in ipairs(move.moveInfo) do
          if info.fromArea == Player.Hand then
            if Fk:getCardById(info.cardId).color == Card.Black then
              n = n + 1
            end
          end
        end
      end
    end
    return n
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    for _, p in ipairs(room:getOtherPlayers(player)) do
      local cards = table.filter(p:getCardIds("he"), function(id) return Fk:getCardById(id).trueName ~= "shade" end)
      if #cards > 0 then
        p:addToPile("$steam__heianyishu_pile", table.random(cards), false, skel.name)
      end
    end
    for _, p in ipairs(room:getAlivePlayers()) do
      if not p.dead then
        local cid = U.getShade(room, 1)[1]
        room:obtainCard(p, cid, true, fk.ReasonJustMove, player, skel.name, "steam__heianyishu-inhand")
      end
    end
  end,
})

skel:addEffect(fk.TurnStart, {
  is_delay_effect = true,
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return not player.dead and #player:getPile("$steam__heianyishu_pile") > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    player.room:obtainCard(player, player:getPile("$steam__heianyishu_pile"), false, fk.ReasonJustMove, player, skel.name)
  end,
})

skel:addEffect(fk.TurnEnd, {
  is_delay_effect = true,
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return not player.dead and table.find(player:getCardIds("h"), function (id)
      return Fk:getCardById(id):getMark("steam__heianyishu-inhand") ~= 0
    end)
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local cards = table.filter(player:getCardIds("h"), function(id) return Fk:getCardById(id):getMark("steam__heianyishu-inhand") ~= 0 end)
    if #cards > 0 then
      room:moveCardTo(cards, Card.Void, nil, fk.ReasonJustMove, "steam__heianyishu_distroy")
    end
  end,
})

return skel
