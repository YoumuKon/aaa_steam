
local skels = {}

Fk:loadTranslationTable{
  ["steam__zhiyi"] = "执义",
  [":steam__zhiyi"] = "锁定技，你使用或打出过基本牌的回合结束时，你选择一项：1.视为使用其中一张即时牌；2.摸一张牌。",

  [":steam__zhiyi_inner"] = "锁定技，你使用或打出过{1}的回合结束时，你选择一项：1.视为使用其中一张即时牌；2.摸一张牌。",

  ["#steam__zhiyi-use"] = "执义：视为使用一张%arg，或点“取消”摸一张牌",

  ["$steam__zhiyi1"] = "别急别急，人人有份~",
  ["$steam__zhiyi2"] = "你们很小心脚下呢。不如，抬头看看怎么样？",
}

for index = 1, 30 do
  local zhiyi = fk.CreateSkill {
    name = "steam__zhiyi"..index,
    tags = { Skill.Compulsory },
    dynamic_desc = function (self, player, lang)
      return "steam__zhiyi_inner:"..Fk:translate(player:getMark(self.name), lang)
    end,
  }

  Fk:loadTranslationTable{
    ["steam__zhiyi"..index] = "执义",
    [":steam__zhiyi"..index] = "锁定技，你使用或打出过基本牌的回合结束时，你选择一项：1.视为使用其中一张即时牌；2.摸一张牌。",
  }

  local U = require "packages/utility/utility"

  zhiyi:addEffect(fk.TurnEnd, {
    anim_type = "offensive",
    can_trigger = function(self, event, target, player, data)
      return player:hasSkill(zhiyi.name) and
        (#player.room.logic:getEventsOfScope(GameEvent.UseCard, 1, function(e)
          local use = e.data
          return use.from == player and use.card:getTypeString() == player:getMark(zhiyi.name)
        end, Player.HistoryTurn) > 0 or
        #player.room.logic:getEventsOfScope(GameEvent.RespondCard, 1, function(e)
          local use = e.data
          return use.from == player and use.card:getTypeString() == player:getMark(zhiyi.name)
        end, Player.HistoryTurn) > 0)
    end,
    on_use = function(self, event, target, player, data)
      local room = player.room
      player:broadcastSkillInvoke("steam__zhiyi")
      local type = player:getMark(zhiyi.name)
      if type == "equip" then
        player:drawCards(1, zhiyi.name)
        return
      end

      if player:getMark("steam__zhiyi_"..type.."_cards") == 0 then
        room:setPlayerMark(player, "steam__zhiyi_"..type.."_cards", U.getUniversalCards(room, type[1]))
      end
      local names = {}
      room.logic:getEventsOfScope(GameEvent.UseCard, 1, function(e)
        local use = e.data
        if use.from == player and use.card:getTypeString() == type and use.card.sub_type ~= Card.SubtypeDelayedTrick then
          table.insertIfNeed(names, use.card.name)
        end
      end, Player.HistoryTurn)
      room.logic:getEventsOfScope(GameEvent.RespondCard, 1, function(e)
        local use = e.data
        if use.from == player and use.card:getTypeString() == type and use.card.sub_type ~= Card.SubtypeDelayedTrick then
          table.insertIfNeed(names, use.card.name)
        end
      end, Player.HistoryTurn)

      local cards = table.filter(player:getMark("steam__zhiyi_"..type.."_cards"), function (id)
        return table.contains(names, Fk:getCardById(id).name)
      end)
      if #cards == 0 then
        player:drawCards(1, zhiyi.name)
        return
      end
      local use = room:askToUseRealCard(player,{
        pattern = cards,
        skill_name = zhiyi.name,
        prompt = "#steam__zhiyi-use:::"..type,
        extra_data = {
          expand_pile = cards,
          bypass_times = true,
          extraUse = true
        },
        skip = true,
      })
      if use then
        local card = Fk:cloneCard(use.card.name)
        card.skillName = zhiyi.name
        room:useCard{
          from = player,
          tos = use.tos,
          card = card,
        }
      else
        player:drawCards(1, zhiyi.name)
      end
    end,
  })

  table.insert(skels, zhiyi)
end

return skels
