local skel = fk.CreateSkill {
  name = "steam__siphoning_strike",
}

Fk:loadTranslationTable{
  ["steam__siphoning_strike"] = "汲魂痛击",
  [":steam__siphoning_strike"] = "每回合限一次，你使用【杀】时，可以令之改为按【兵临城下】结算，且亮出牌数+X（X为你本局使用Q点牌的张数）。",

  ["#steam__siphoning_strike-invoke"] = "汲魂痛击：是否将此【杀】改为【兵临城下】？",
  ["@siphoning_strike"] = "汲魂痛击",

  ["$steam__siphoning_strike1"] = "我们即将迎来清算。",
  ["$steam__siphoning_strike2"] = "有些灵魂，注定要燃烧。",
  ["$steam__siphoning_strike3"] = "哈！",
}

skel:addEffect(fk.CardUsing, {
  anim_type = "offensive",
  events = {fk.CardUsing},
  times = function(_, player)
    return 1 - player:usedSkillTimes(skel.name, Player.HistoryTurn)
  end,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(skel.name) and data.card.trueName == "slash" and
      player:usedSkillTimes(skel.name, Player.HistoryTurn) == 0
  end,
  on_cost = function (self, event, target, player, data)
    return player.room:askToSkillInvoke(player, { skill_name = skel.name, prompt = "#steam__siphoning_strike-invoke"})
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    data:changeCard("enemy_at_the_gates")
    data.disresponsiveList = table.simpleClone(room.players)
    local n = player:getMark("@siphoning_strike")
    if n > 0 then
      data.extra_data = data.extra_data or {}
      data.extra_data.num = (data.extra_data.num or 0) + n
    end
  end,
})

skel:addAcquireEffect(function (self, player, is_start)
  local n = #player.room.logic:getEventsOfScope(GameEvent.UseCard, 999, function(e)
    local use = e.data
    return use.card.number == 12 and use.from == player
  end, Player.HistoryGame)
  player.room:setPlayerMark(player, "@siphoning_strike", n)
end)

skel:addLoseEffect(function (self, player, is_death)
  player.room:setPlayerMark(player, "@siphoning_strike", 0)
end)

skel:addEffect(fk.AfterCardUseDeclared, {
  can_refresh = function (self, event, target, player, data)
    return player:hasSkill(skel.name, true) and target == player and data.card.number == 12
  end,
  on_refresh = function (self, event, target, player, data)
    player.room:addPlayerMark(player, "@siphoning_strike")
    player:broadcastSkillInvoke(skel.name, 3)
  end,
})

return skel
