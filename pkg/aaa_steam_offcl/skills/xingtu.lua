local skel = fk.CreateSkill {
  name = "steam__xingtu",
}

Fk:loadTranslationTable{
  ["steam__xingtu"] = "行图",
  [":steam__xingtu"] = "出牌阶段限一次，你可以重铸两张牌，然后你下次使用点数介于两者之间的牌时，摸一张牌，若使用牌与两者点数差相同，重置本阶段使用牌与此技能发动次数。",

  ["#steam__xingtu"] = "行图：重铸两张牌，你下次使用点数介于两者之间的牌时摸一张牌",
  ["@steam__xingtu"] = "行图",
  ["#steam__xingtu_delay"] = "行图",

  ["$steam__xingtu1"] = "考古之郡国、今之州县，为地图一十八篇。",
  ["$steam__xingtu2"] = "水陆之径若绘之以记，则无所忘失。",
}

skel:addEffect("active", {
  anim_type = "drawcard",
  prompt = "#steam__xingtu",
  card_num = 2,
  target_num = 0,
  card_filter = function (self, player, to_select, selected)
    return #selected < 2
  end,
  times = function (self, player)
    return 1 - player:usedSkillTimes(skel.name, Player.HistoryPhase)
  end,
  can_use = function(self, player)
    return player:usedSkillTimes(skel.name, Player.HistoryPhase) == 0
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local cards = effect.cards
    local n1, n2 = Fk:getCardById(cards[1]).number, Fk:getCardById(cards[2]).number
    if n1 > n2 then n1, n2 = n2, n1 end
    room:recastCard(cards, player, skel.name)
    if not player.dead then
      room:setPlayerMark(player, "@steam__xingtu", {n1, n2})
    end
  end,
})

skel:addEffect(fk.CardUsing, {
  anim_type = "drawcard",
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    if not player.dead and player == target then
      local mark = player:getTableMark("@steam__xingtu")
      local num = data.card.number
      if #mark == 2 then
        return num > mark[1] and num < mark[2]
      end
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local mark = player:getTableMark("@steam__xingtu")
    local num = data.card.number
    local n1, n2 = mark[1], mark[2]
    room:setPlayerMark(player, "@steam__xingtu", 0)
    player:drawCards(1, skel.name)
    if math.abs(n1 - num) == math.abs(n2 - num) then
      player:setSkillUseHistory(skel.name, 0, Player.HistoryPhase)
      player:setCardUseHistory("", 0, Player.HistoryPhase)
    end
  end,
})

skel:addLoseEffect(function (self, player, is_death)
  player.room:setPlayerMark(player, "@steam__xingtu", 0)
end)

return skel
