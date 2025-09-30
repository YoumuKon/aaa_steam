local skel = fk.CreateSkill {
  name = "steam__yizhii",
  tags = {Skill.Compulsory},
}

Fk:loadTranslationTable{
  ["steam__yizhii"] = "意志",-- 重名了
  [":steam__yizhii"] = "锁定技，游戏开始时，将你的座次调整为一号位。每轮你使用第一张牌后，其他角色每回合第一张牌只能使用与此牌颜色相同的牌。",

  ["@steam__yizhii_owner-round"] = "意志",
  ["@steam__yizhii-turn"] = "被意志",

  ["$steam__yizhii1"] = "",
  ["$steam__yizhii2"] = "",
}

skel:addEffect(fk.GameStart, {
  anim_type = "big",
  priority = 1.01,
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(skel.name)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if player.seat == 1 then return end
    local players = table.simpleClone(room.players)
    table.removeOne(players, player)
    table.insert(players, 1, player)
    room:arrangeSeats(players)
    -- 如果没有人进入回合，则修改自己为当前回合者
    if room.logic:getCurrentEvent():findParent(GameEvent.Turn) ~= nil then return end
    room:setCurrent(player)
  end,
})

skel:addEffect(fk.CardUseFinished, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(skel.name) then
      local useEvent = player.room.logic:getEventsOfScope(GameEvent.UseCard, 1, function(e)
        local use = e.data
        return use.from == player
      end, Player.HistoryRound)[1]
      if useEvent then
        return useEvent.data == data
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local color = data.card:getColorString()
    room:setPlayerMark(player, "@steam__yizhii_owner-round", color)
    -- 用于检测其他角色本回合有没有使用第一张牌
    local hasUsed = {}
    room.logic:getEventsOfScope(GameEvent.UseCard, 1, function(e)
      local use = e.data
      table.insertIfNeed(hasUsed, use.from)
    end, Player.HistoryRound)
    local targets = table.filter(room:getOtherPlayers(player, false), function (p)
      return not table.contains(hasUsed, p)
    end)
    if #targets == 0 then return end
    room:doIndicate(player, targets)
    for _, p in ipairs(targets) do
      room:setPlayerMark(p, "@steam__yizhii-turn", color)
    end
  end,
})

skel:addEffect(fk.TurnStart, {
  can_refresh = function (self, event, target, player, data)
    return player:getMark("@steam__yizhii_owner-round") ~= 0
  end,
  on_refresh = function (self, event, target, player, data)
    local room = player.room
    local color = player:getMark("@steam__yizhii_owner-round")
    room:delay(150)
    room:doIndicate(player, room:getOtherPlayers(player))
    for _, p in ipairs(room:getOtherPlayers(player)) do
      room:setPlayerMark(p, "@steam__yizhii-turn", color)
    end
  end,
})

skel:addEffect(fk.CardUsing, {
  can_refresh = function (self, event, target, player, data)
    return target == player and player:getMark("@steam__yizhii-turn") ~= 0
  end,
  on_refresh = function (self, event, target, player, data)
    player.room:setPlayerMark(player, "@steam__yizhii-turn", 0)
  end,
})

skel:addLoseEffect(function (self, player, is_death)
  player.room:setPlayerMark(player, "@steam__yizhii_owner-round", 0)
end)

skel:addEffect("prohibit", {
  prohibit_use = function(self, player, card)
    local color = player:getMark("@steam__yizhii-turn")
    if color ~= 0 then
      return not card:matchVSPattern(".|.|" .. color )
    end
  end,
})

return skel
