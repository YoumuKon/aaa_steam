local kuangleijianqi = fk.CreateSkill{
  name = "steam__kuangleijianqi",
  tags = { Skill.Combo },
  dynamic_desc = function(self, player)
    local t = {}
    for _ = 1, 5 - player:getMark("steam__kuangleijianqi"), 1 do
      table.insert(t, Fk:translate("card"))
    end
    return "steam__kuangleijianqi-dynamic:" .. table.concat(t, "+")
  end,
}

kuangleijianqi:addLoseEffect(function(self, player, is_death)
  player.room:setPlayerMark(player, "@[combo_eventcounter]steam__kuangleijianqi", {})
  player.room:setPlayerMark(player, kuangleijianqi.name, 0)
end)

Fk:addQmlMark{
  name = "combo_eventcounter",
  how_to_show = function(name, value, player)
    if type(value) == "table" then
      return tostring(#value)
    end
    return "#hidden"
  end,
}

kuangleijianqi:addEffect(fk.CardUseFinished, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(kuangleijianqi.name) and
      data.extra_data and data.extra_data.combo_skill and data.extra_data.combo_skill[kuangleijianqi.name]
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = kuangleijianqi.name,
      prompt = "#steam__kuangleijianqi-invoke:::" .. (player.chained and "#steam__kuangleijianqi_middle" or ""),
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local mark = data.extra_data.steam__kuangleijianqi_datas ---@type table<number, {id: number, tos: ServerPlayer[]}>
    local chained = false
    if player.chained then
      player:setChainState(false)
    end
    for _, e in ipairs(mark) do
      local tos = e.tos
      local players = table.filter(room:getAlivePlayers(true), function(p)
        return table.contains(tos, p)
      end)
      if #players > 0 then
        for _, to in ipairs(players) do
          if to.chained then
            player:drawCards(1, kuangleijianqi.name)
          else
            to:setChainState(true, {
              who = player,
              reason = kuangleijianqi.name,
            })
            if not chained and to ~= player then
              chained = true
            end
          end
        end
      elseif player:isWounded() then
        room:recover{
          who = player,
          num = 1,
          recoverBy = player,
          skillName = kuangleijianqi.name,
        }
      end
    end
    local num = player:getMark(kuangleijianqi.name)
    if not chained then
      if num > 0 then
        room:removePlayerMark(player, kuangleijianqi.name)
      end
    elseif num < 4 and room:askToSkillInvoke(player, {
      skill_name = kuangleijianqi.name,
      prompt = "#steam__kuangleijianqi-delete",
    }) then
      room:addPlayerMark(player, kuangleijianqi.name)
    end
  end
})

kuangleijianqi:addEffect(fk.AfterCardUseDeclared, {
  mute = true,
  can_refresh = function(self, event, target, player, data)
    return target == player and player:hasSkill(kuangleijianqi.name, true)
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    local logic = room.logic
    local turns = logic.event_recorder[GameEvent.Turn]
    local mark = player:getTableMark("@[combo_eventcounter]steam__kuangleijianqi")
    if #mark > 0 and #turns > 2 then
      local previous = mark[#mark] ---@type GameEvent.UseCard
      if previous.id < turns[#turns - 1].id then
        mark = {}
      end
    end
    local current_event = logic:getCurrentEvent() ---@cast current_event GameEvent.UseCard
    table.insert(mark, {
      id = current_event.id,
      card = current_event.data.card,
      tos = current_event.data:getAllTargets(),
    })
    if #mark == (5 - player:getMark(kuangleijianqi.name)) then
      data.extra_data = data.extra_data or {}
      data.extra_data.combo_skill = data.extra_data.combo_skill or {}
      data.extra_data.combo_skill[kuangleijianqi.name] = true
      data.extra_data.steam__kuangleijianqi_datas = mark
      room:setPlayerMark(player, "@[combo_eventcounter]steam__kuangleijianqi", 0)
    else
      room:setPlayerMark(player, "@[combo_eventcounter]steam__kuangleijianqi", mark)
    end
  end
})

kuangleijianqi:addEffect(fk.TurnStart, {
  mute = true,
  can_refresh = function(self, event, target, player, data)
    return player:getMark("@[combo_eventcounter]steam__kuangleijianqi") ~= 0
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    local logic = room.logic
    local mark = player:getTableMark("@[combo_eventcounter]steam__kuangleijianqi")
    mark.current_turn = logic:getCurrentEvent().id
    room:setPlayerMark(player, "@[combo_eventcounter]steam__kuangleijianqi", mark)
  end
})

Fk:loadTranslationTable{
  ["steam__kuangleijianqi"] = "狂雷渐起",
  [":steam__kuangleijianqi"] = "连招技（牌+牌+牌+牌+牌，【当你使用牌时，若你上回合未使用牌，重置此进度】），<br>"..
  "你可以重置武将牌（已重置则跳过），然后依次令连招中牌的每个目标依次横置（已横置则改为你摸一张牌），<br>"..
  "若无存活目标则改为你回复1点体力。<br>"..
  "然后你可以删除此连招技的一个条件，若没有其他角色因此横置，改为你须复原此连招技的一个条件。",

  [":steam__kuangleijianqi-dynamic"] = "连招技（{1}，【当你使用牌时，若你上回合未使用牌，重置此进度】），<br>"..
  "你可以重置武将牌（已重置则跳过），然后依次令连招中牌的每个目标依次横置（已横置则改为你摸一张牌），<br>"..
  "若无存活目标则改为你回复1点体力。<br>"..
  "然后你可以删除此连招技的一个条件，若没有其他角色因此横置，改为你须复原此连招技的一个条件。",
  ["card"] = "牌",

  ["#steam__kuangleijianqi-invoke"] = "狂雷渐起：你可以%arg令连招中牌的每个目标依次横置（已横置则改为你摸一张牌），若无存活目标则改为你回复1点体力",
  ["#steam__kuangleijianqi-delete"] = "狂雷渐起：你可以删除〖狂雷渐起〗的一个条件",

  ["#steam__kuangleijianqi_middle"] = "重置武将牌，<br>然后",

  ["@[combo_eventcounter]steam__kuangleijianqi"] = "狂雷渐起",
}

return kuangleijianqi
