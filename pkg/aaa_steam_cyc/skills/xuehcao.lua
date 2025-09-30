local skel = fk.CreateSkill {
  name = "steam__xuehcao",
}

local ret = {}

Fk:loadTranslationTable{
  ["steam__xuehcao"] = "血潮",
  [":steam__xuehcao"] = "出牌阶段，你可以失去1点体力。你每回合首次扣减体力值后，你随机获得一个仅含一个选项的〖执义〗。",
  ["#steam__xuehcao"] = "血潮：你可以失去1点体力",
}

skel:addEffect("active", {
  anim_type = "negative",
  prompt = "#steam__xuehcao",
  card_num = 0,
  target_num = 0,
  card_filter = Util.FalseFunc,
  can_use = function(self, player)
    return player.hp > 0
  end,
  on_use = function(self, room, effect)
    room:loseHp(effect.from, 1, self.name)
  end,
})

skel:addEffect(fk.HpChanged, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(skel.name) and data.num < 0 then
      local first = player.room.logic:getEventsOfScope(GameEvent.ChangeHp, 1, function(e)
        return e.data.who == player and e.data.num < 0
      end, Player.HistoryTurn)[1]
      if first then
        local current = player.room.logic:getCurrentEvent():findParent(GameEvent.ChangeHp, true)
        return current and current.id == first.id
      end
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local choice = table.random({"use", "draw"})
    for i = 1, 30 do
      local name = "steam"..i.."__zhiyi_" .. choice
      if Fk.skills[name] and not player:hasSkill(name, true, true) then
        room:handleAddLoseSkills(player, name)
        break
      end
    end
  end,
})

table.insert(ret, skel)

local zhiyiSpec = {
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self.name) and
    (#player.room.logic:getEventsOfScope(GameEvent.UseCard, 1, function(e)
      local use = e.data
      return use.from == player and use.card.type == Card.TypeBasic
    end, Player.HistoryTurn) > 0 or
    #player.room.logic:getEventsOfScope(GameEvent.RespondCard, 1, function(e)
      local use = e.data
      return use.from == player and use.card.type == Card.TypeBasic
    end, Player.HistoryTurn) > 0)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if self.name:endsWith("draw") then
      player:drawCards(1, self.name)
      return
    end
    local names = {}
    room.logic:getEventsOfScope(GameEvent.UseCard, 1, function(e)
      local use = e.data
      if use.from == player and use.card.type == Card.TypeBasic then
        table.insertIfNeed(names, use.card.name)
      end
    end, Player.HistoryTurn)
    room.logic:getEventsOfScope(GameEvent.RespondCard, 1, function(e)
      local use = e.data
      if use.from == player and use.card.type == Card.TypeBasic then
        table.insertIfNeed(names, use.card.name)
      end
    end, Player.HistoryTurn)
    room:askToUseVirtualCard(player, {
      name = names, skill_name = self.name, cancelable = false,
      extra_data = {
        bypass_distances = true, bypass_times = true,
      }
    })
  end,
}

for i = 1, 30 do
  for _, v in ipairs({"use", "draw"}) do
    local skelZhiyi = fk.CreateSkill {
      name = "steam" .. i .. "__zhiyi_" .. v,
      tags = {Skill.Compulsory},
    }

    skelZhiyi:addEffect(fk.TurnEnd, zhiyiSpec)
    Fk:loadTranslationTable{
      [skelZhiyi.name] = "执义",
      [":"..skelZhiyi.name] = "锁定技，你使用或打出过基本牌的回合结束时，你" ..
      ( v == "use" and "视为使用其中一张。" or "摸一张牌。"),
    }
    table.insert(ret, skelZhiyi)

  end
end

return ret
