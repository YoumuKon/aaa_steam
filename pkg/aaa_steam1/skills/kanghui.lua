local skel = fk.CreateSkill {
  name = "steam__kanghui",
  tags = {Skill.Switch},
}

Fk:loadTranslationTable{
  ["steam__kanghui"] = "康惠",
  [":steam__kanghui"] = "转换技，结束阶段，①你可以令本回合使用过牌的角色各摸一张牌；②你可以令本回合弃置过牌的角色各摸一张牌。",

  ["#steam__kanghui-yang"] = "康惠：你可以令本回合使用过牌的角色各摸一张牌",
  ["#steam__kanghui-yin"] = "康惠：你可以令本回合弃置过牌的角色各摸一张牌",
  ["@steam__kanghui"] = "可摸牌",
  ["steam__kanghui_select"] = "康惠",

  ["$steam__kanghui1"] = "应民之声，势民之根。",
  ["$steam__kanghui2"] = "应势而谋，顺民而为。",
}

skel:addEffect(fk.EventPhaseStart, {
  anim_type = "switch",
  can_trigger = function (self, event, target, player, data)
    return player:hasSkill(skel.name) and target == player and player.phase == Player.Finish
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local tos = {}
    if player:getSwitchSkillState(skel.name) == fk.SwitchYang then
      player.room.logic:getEventsOfScope(GameEvent.UseCard, 1, function(e)
        local use = e.data
        table.insertIfNeed(tos, use.from)
      end, Player.HistoryTurn)
    else
      room.logic:getEventsOfScope(GameEvent.MoveCards, 1, function(e)
        for _, move in ipairs(e.data) do
          if move.from and move.moveReason == fk.ReasonDiscard and table.find(move.moveInfo, function(info)
              return info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip
            end) then
            table.insertIfNeed(tos, move.from)
          end
        end
      end, Player.HistoryTurn)
    end
    tos = table.filter(tos, function(to) return to:isAlive() end)
    if #tos > 0 then
      local prompt = "#steam__kanghui-"..player:getSwitchSkillState(skel.name, false, true)
      local success = room:askToUseActiveSkill(player, { skill_name = "steam__kanghui_select",
      prompt = prompt, extra_data = {steam__kanghui_tos = table.map(tos, Util.IdMapper) } })
      if success then
        room:sortByAction(tos)
        event:setCostData(self, {tos = tos})
        return true
      end
    end
  end,
  on_use = function (self, event, target, player, data)
    local tos = event:getCostData(self).tos ---@type ServerPlayer[]
    for _, to in ipairs(tos) do
      if not to.dead then
        to:drawCards(1, skel.name)
      end
    end
  end,
})

local skel2 = fk.CreateSkill {
  name = "steam__kanghui_select",
}

skel2:addEffect("active", {
  card_num = 0,
  target_num = 0,
  prompt = "#steam__andong",
  card_filter = Util.FalseFunc,
  target_tip = function (self, player, to_select, selected, selected_cards, card, selectable, extra_data)
    if table.contains(self.steam__kanghui_tos or {}, to_select.id) then
      return "@steam__kanghui"
    end
  end,
})


return {skel, skel2}
