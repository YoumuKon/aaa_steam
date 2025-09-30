local skel = fk.CreateSkill {
  name = "steam__mochen",
}

Fk:loadTranslationTable{
  ["steam__mochen"] = "漠尘",
  [":steam__mochen"] = "你与其他角色于出牌阶段使用的首张目标含对方的牌对方不可响应，且结算后你摸一张牌并蓄谋一张牌。",
  ["#steam__mochen-put"] = "漠尘:你须蓄谋一张牌",

  ["$steam__mochen1"] = "这些东西，不配我拔剑。",
  ["$steam__mochen2"] = "他们甚至不知自己可耻。",
}

local U = require "packages/utility/utility"

skel:addEffect(fk.CardUsing, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(skel.name) and target.phase == Player.Play  then
      if target == player then
        if table.find(data.tos, function (p)
          return p ~= player and not p.dead
        end) then
          local use_events = player.room.logic:getEventsOfScope(GameEvent.UseCard, 2, function (e)
            return e.data.from == player and table.find(e.data.tos, function (p)
              return p ~= player
            end) ~= nil
          end, Player.HistoryPhase)
          return #use_events == 1 and use_events[1].data == data
        end
      else
        if table.contains(data.tos, player) then
          local use_events = player.room.logic:getEventsOfScope(GameEvent.UseCard, 2, function (e)
            return e.data.from == target and table.contains(e.data.tos, player)
          end, Player.HistoryPhase)
          return #use_events == 1 and use_events[1].data == data
        end
      end
    end
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local tos = {}
    if target ~= player then
      tos = {player}
    else
      tos = table.filter(data.tos, function (p)
        return p ~= player
      end)
    end
    if #tos > 0 then
      room:sortByAction(tos)
      event:setCostData(self, {tos = tos})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local tos = event:getCostData(self).tos
    data.disresponsiveList = data.disresponsiveList or {}
    table.insertTableIfNeed(data.disresponsiveList, tos)
    data.extra_data = data.extra_data or {}
    data.extra_data[skel.name] = data.extra_data[skel.name] or {}
    table.insert(data.extra_data[skel.name], player)
  end,
})

skel:addEffect(fk.CardUseFinished, {
  can_trigger = function (self, event, target, player, data)
    return player:hasSkill(skel.name) and table.contains((data.extra_data or {})[skel.name] or {}, player)
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    player:drawCards(1, skel.name)
    if not player:isNude() then
      local cards = player.room:askToCards(player, {
        min_num = 1, max_num = 1, skill_name = skel.name, include_equip = true, cancelable = false,
        prompt = "#steam__mochen-put",
      })
      U.premeditate(player, cards[1], skel.name)
    end
  end,
})

return skel
