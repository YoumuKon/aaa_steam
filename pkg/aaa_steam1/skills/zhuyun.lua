local skel = fk.CreateSkill {
  name = "steam__zhuyun",
}

Fk:loadTranslationTable{
  ["steam__zhuyun"] = "助运",
  [":steam__zhuyun"] = "一名角色的回合结束时，若此回合包括你在内有至少两名角色失去过牌，你可令其中至多两名角色各摸一张牌；若你因此摸牌，你可与一名角色拼点，且若你拼点赢，重置“攒局”的次数。",

  ["#steam__zhuyun-choose"] = "助运：你可以令至多 2 名失去过牌的角色各摸一张牌",
  ["#steam__zhuyun-pindian"] = "助运：你可以与任一角色拼点，若你赢，重置“攒局”",
}

skel:addEffect(fk.TurnEnd, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(skel.name) then return false end
    local targets = {}
    player.room.logic:getEventsOfScope(GameEvent.MoveCards, 1, function(e)
      for _, move in ipairs(e.data) do
        if move.from then
          for _, info in ipairs(move.moveInfo) do
            if info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip then
              table.insertIfNeed(targets, move.from)
            end
          end
        end
      end
      return false
    end, Player.HistoryTurn)
    if table.contains(targets, player) and #targets > 1 then
      event:setCostData(self, {tos = targets})
      return true
    end
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local targets = (event:getCostData(self) or Util.DummyTable).tos or {}
    local tos = room:askToChoosePlayers(player, {
      targets = targets, min_num = 1, max_num = 2, skill_name = skel.name, prompt = "#steam__zhuyun-choose",
    })
    if #tos > 0 then
      room:sortByAction(tos)
      event:setCostData(self, {tos = tos})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local tos = event:getCostData(self).tos
    if not tos then return end
    for _, p in ipairs(tos) do
      if not p.dead then
        p:drawCards(1, skel.name)
      end
    end
    if table.contains(tos, player) and not player:isKongcheng() then
      local targets = table.filter(room:getOtherPlayers(player, false), function (p) return player:canPindian(p) end)
      if #targets == 0 then return end
      local to = room:askToChoosePlayers(player, {
        targets = targets, min_num = 1, max_num = 1, skill_name = skel.name, prompt = "#steam__zhuyun-pindian"
      })[1]
      if to then
        local pd = player:pindian({to}, skel.name)
        if pd and pd.results[to] and pd.results[to].winner == player then
          player:setSkillUseHistory("steam__zanju", 0, Player.HistoryRound)
        end
      end
    end
  end,
})

return skel
