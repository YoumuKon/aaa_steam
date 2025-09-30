local skel = fk.CreateSkill {
  name = "steam__nuyizengsheng",
  tags = {Skill.Compulsory},
}

Fk:loadTranslationTable{
  ["steam__nuyizengsheng"] = "怒意增生",
  [":steam__nuyizengsheng"] = "锁定技，你摸牌时，改为随机获得等量张黑色牌。你每回合使用的前X张牌：没有距离、次数限制，且首次造成伤害后，你摸一张牌。(X为你的已损体力值)",
}

skel:addEffect(fk.BeforeDrawCard, {
  anim_type = "negative",
  times = function (_, player)
    return math.max(0, player:getLostHp() - player:getMark("steam__nuyizengsheng_used-turn"))
  end,
  can_trigger = function (self, event, target, player, data)
    return player == target and player:hasSkill(skel.name) and data.num and data.num > 0
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local ids = room:getCardsFromPileByRule(".|.|spade,club", data.num)
    if #ids > 0 then
      room:obtainCard(player, ids, false, fk.ReasonJustMove, player, skel.name)
    end
    data.num = 0
    -- data.prevented = true
    return true
  end,
})

skel:addEffect(fk.Damage, {
  anim_type = "offensive",
  can_trigger = function (self, event, target, player, data)
    if target == player and player:hasSkill(skel.name) then
      local useEvent = player.room.logic:getCurrentEvent():findParent(GameEvent.UseCard)
      if useEvent then
        local use = useEvent.data
        return use.card == data.card and use.extra_data and use.extra_data.steam__nuyizengsheng
      end
    end
  end,
  on_use = function (self, event, target, player, data)
    local useEvent = player.room.logic:getCurrentEvent():findParent(GameEvent.UseCard)
    if useEvent == nil then return end
    local use = useEvent.data
    use.extra_data.steam__nuyizengsheng = false
    player:drawCards(1, skel.name)
  end,
})

-- 令无次数限制=不计入次数
skel:addEffect(fk.PreCardUse, {
  can_refresh = function (self, event, target, player, data)
    return target == player and player:getMark("steam__nuyizengsheng_used-turn") < player:getLostHp()
  end,
  on_refresh = function (self, event, target, player, data)
    data.extraUse = true
  end,
})

-- 为我使用的牌计数
skel:addEffect(fk.CardUsing, {
  can_refresh = function (self, event, target, player, data)
    return target == player and player:hasSkill(skel.name, true)
  end,
  on_refresh = function (self, event, target, player, data)
    player.room:addPlayerMark(player, "steam__nuyizengsheng_used-turn")
    if player:getMark("steam__nuyizengsheng_used-turn") <= player:getLostHp() then
      data.extra_data = data.extra_data or {}
      data.extra_data.steam__nuyizengsheng = true
    end
  end,
})

-- 获得技能时更新计数器
skel:addAcquireEffect(function (self, player, is_start)
  if not is_start then
    local n = #player.room.logic:getEventsOfScope(GameEvent.UseCard, 99, function(e)
      local use = e.data
      return use.from == player
    end, Player.HistoryTurn)
    player.room:setPlayerMark(player, "steam__nuyizengsheng_used-turn", n)
  end
end)

skel:addEffect("targetmod", {
  bypass_times = function(self, player, skill, scope, card, to)
    return card and player and player:hasSkill(skel.name) and player:getMark("steam__nuyizengsheng_used-turn") < player:getLostHp()
  end,
  bypass_distances = function(self, player, skill, card, to)
    return card and player and player:hasSkill(skel.name) and player:getMark("steam__nuyizengsheng_used-turn") < player:getLostHp()
  end,
})


return skel
