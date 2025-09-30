local skel = fk.CreateSkill {
  name = "steam__jijin",
}

Fk:loadTranslationTable{
  ["steam__jijin"] = "疾进",
  [":steam__jijin"] = "弃牌阶段开始时，你可以令一名其他角色指定你的弃牌数；弃牌阶段结束时，你可以令手牌数不大于你本回合弃牌数的任意名角色各弃两张牌。",

  ["#steam__jijin-choose"] = "疾进：选择一名其他角色，令其指定你本阶段弃牌数！",
  ["#steam__jijin-num"] = "疾进：请决定 %src 此次弃牌阶段需要弃置多少手牌！",
  ["#steam__jijin-dsicard"] = "疾进：你可令手牌数不大于 %arg 的任意名角色各弃两张牌",

  ["$steam__jijin1"] = "",
  ["$steam__jijin2"] = "",
}

skel:addEffect(fk.EventPhaseStart, {
  anim_type = "control",
  can_trigger = function (self, event, target, player, data)
    if player:hasSkill(skel.name) and target == player and player.phase == Player.Discard then
      return not player:isKongcheng() and not data.phase_end
        and table.find(player.room.alive_players, function(p) return p ~= player end) ~= nil
    end
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local tos = room:askToChoosePlayers(player, {
      targets = room:getOtherPlayers(player, false),
      min_num = 1, max_num = 1, prompt = "#steam__jijin-choose", skill_name = skel.name
    })
    if #tos > 0 then
      event:setCostData(self, {tos = tos})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    data.phase_end = true
    local to = event:getCostData(self).tos[1]
    local choices = {"0"}
    for i = 1, player:getHandcardNum() do
      table.insert(choices, tostring(i))
    end
    local num = tonumber(room:askToChoice(to, { choices = choices, skill_name = skel.name, prompt = "#steam__jijin-num:"..player.id}))---@type integer
    if num > 0 then
      room:askToDiscard(player, {min_num = num, max_num = num, include_equip = false, skill_name = "phase_discard", cancelable = false})
    end
  end,
})

skel:addEffect(fk.EventPhaseEnd, {
  anim_type = "control",
  can_trigger = function (self, event, target, player, data)
    if player:hasSkill(skel.name) and target == player and player.phase == Player.Discard then
      return true
    end
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local num = 0
    room.logic:getEventsOfScope(GameEvent.MoveCards, 1, function(e)
      for _, move in ipairs(e.data) do
        if move.from == player and move.moveReason == fk.ReasonDiscard then
          for _, info in ipairs(move.moveInfo) do
            if info.fromArea == Card.PlayerHand then
              num = num + 1
            end
          end
        end
      end
      return false
    end, Player.HistoryTurn)
    local targets = table.filter(room.alive_players, function (p)
      return p:getHandcardNum() <= num and not p:isNude()
    end)
    if #targets == 0 then return false end
    local tos = room:askToChoosePlayers(player, {
      targets = targets, min_num = 1, max_num = #targets,
      prompt = "#steam__jijin-dsicard:::"..num, skill_name = skel.name
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
    for _, to in ipairs(tos) do
      if not to:isNude() then
        room:askToDiscard(to, {min_num = 2, max_num = 2, include_equip = true, skill_name = skel.name, cancelable = false})
      end
    end
  end,
})

return skel
