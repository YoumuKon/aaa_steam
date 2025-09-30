local skel = fk.CreateSkill {
  name = "steam__nixing",
  tags = {Skill.Compulsory},
}

Fk:loadTranslationTable{
  ["steam__nixing"] = "逆行",
  [":steam__nixing"] = "锁定技，你的摸牌阶段摸牌数和弃牌阶段弃牌数为X（X为当前轮数+1）。回合开始时，交换你摸牌阶段和弃牌阶段的执行顺序。",

  ["@@steam__nixing"] = "逆行:摸弃互换",
  ["#steam__nixing-discard"] = "逆行：你的弃牌阶段被改为弃置 %arg 张手牌",

  ["$steam__nixing1"] = "吾日暮途远，故倒行逆施。",
  ["$steam__nixing2"] = "穷途薄暮，何求？欲拼一死休！",
}

skel:addEffect(fk.DrawNCards, {
  anim_type = "drawcard",
  can_trigger = function (self, event, target, player, data)
    return player:hasSkill(skel.name) and target == player
  end,
  on_use = function(self, event, target, player, data)
    local x = (player.room:getBanner("RoundCount") or 0) + 1
    data.n = x
  end,
})

skel:addEffect(fk.EventPhaseProceeding, {
  anim_type = "negative",
  can_trigger = function (self, event, target, player, data)
    if player:hasSkill(skel.name) and target == player then
      return player.phase == Player.Discard
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local x = (room:getBanner("RoundCount") or 0) + 1
    room:askToDiscard(player, {
      min_num = x, max_num = x, include_equip = false, skill_name = "phase_discard", cancelable = false,
      prompt = "#steam__nixing-discard:::"..x,
    })
  end,
})

skel:addEffect(fk.TurnStart, {
  anim_type = "negative",
  can_trigger = function (self, event, target, player, data)
    return player:hasSkill(skel.name) and target == player
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if player:getMark("@@steam__nixing") == 0 then
      room:setPlayerMark(player, "@@steam__nixing", 1)
      local turn_event = room.logic:getCurrentEvent():findParent(GameEvent.Turn, true)
      if turn_event == nil then return end
      local turn_end = turn_event.data
      for _, phase_data in ipairs(turn_end.phase_table) do
        if phase_data.phase == Player.Draw or phase_data.phase == Player.Discard then
          phase_data.phase = (phase_data.phase == Player.Draw and Player.Discard or Player.Draw)
        end
      end
    else
      room:setPlayerMark(player, "@@steam__nixing", 0)
    end
  end,
})

skel:addLoseEffect(function (self, player, is_death)
  player.room:setPlayerMark(player, "@@steam__nixing", 0)
end)

return skel
