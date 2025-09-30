local skel = fk.CreateSkill {
  name = "steam__zhancaochugen",
  tags = {Skill.Compulsory},
}

Fk:loadTranslationTable{
  ["steam__zhancaochugen"] = "斩草除根",
  [":steam__zhancaochugen"] = "锁定技，结束阶段，你获得本回合对攻击范围内距离最远的角色使用过的一张牌。",
  ["#steam__zhancaochugen-get"] = "斩草除根：选择一张牌获得！",

  ["$steam__zhancaochugen1"] = "这把刀是我的最爱…",
  ["$steam__zhancaochugen2"] = "游走于刀尖之上。",
}

skel:addEffect(fk.EventPhaseStart, {
  anim_type = "drawcard",
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(skel.name) and player.phase == Player.Finish
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local ids, max_dist = {}, 0
    for _, p in ipairs(room.alive_players) do
      if player:inMyAttackRange(p) then
        max_dist = math.max(max_dist, player:distanceTo(p))
      end
    end
    if max_dist == 0 then return end
    local targets = table.filter(room.alive_players, function (p)
      return player:inMyAttackRange(p) and player:distanceTo(p) == max_dist
    end)
    if #targets == 0 then return end
    player.room.logic:getEventsOfScope(GameEvent.UseCard, 1, function(e)
      local use = e.data
      if use.tos and table.find(use.tos, function (p)
        return table.contains(targets, p)
      end) then
        table.insertTableIfNeed(ids, Card:getIdList(use.card))
      end
    end, Player.HistoryTurn)
    ids = table.filter(ids, function (id) return room:getCardArea(id) == Card.DiscardPile end)
    if #ids > 0 then
      local cid = room:askToChooseCard(player, {
        target = player, skill_name = skel.name, prompt = "#steam__zhancaochugen-get",
        flag = { card_data = { { skel.name, ids } } }
      })
      room:obtainCard(player, cid, true, fk.ReasonJustMove, player, skel.name)
    end
  end,
})

return skel
