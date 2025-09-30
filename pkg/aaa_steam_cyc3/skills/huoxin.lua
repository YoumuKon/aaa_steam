local huoxin = fk.CreateSkill {
  name = "steam__huoxin",
}

Fk:loadTranslationTable{
  ["steam__huoxin"] = "惑心",
  [":steam__huoxin"] = "昂扬技，出牌阶段限一次，你可以赠予一张牌；若为<font color='red'>♥</font>️牌，"..
  "则你将手牌替换为其手牌的一份复制（回合结束时换回原手牌）；你使用其中的即时牌结算后，其须对一名目标使用其手牌中的一张同名牌。<br>"..
  "激昂：有角色死亡。",

  ["#SpiritedSkillDesc"] = "#\"<b>昂扬技</b>\"：昂扬技发动后，技能失效直到满足<b>激昂</b>条件。",

  ["#steam__huoxin"] = "惑心",
  ["#steam__huoxin-active"] = "惑心：将一张牌赠予其他角色",
  ["#steam__huoxin-use"] = "惑心：请对其中一名目标角色使用手牌中一张【%arg】",

  ["$steam__huoxin1"] = "血流成河，方不负我倾世的容颜。",
  ["$steam__huoxin2"] = "看你们为我疯魔厮杀，才是这世间最美的风景。",
}

local U = require "packages/utility/utility"

huoxin:addEffect("active", {
  anim_type = "control",
  prompt = "#steam__huoxin-active",
  card_num = 1,
  target_num = 1,
  can_use = function(self, player)
    return player:usedEffectTimes(self.name, Player.HistoryPhase) == 0
  end,
  card_filter = function(self, player, to_select, selected)
    return #selected == 0
  end,
  target_filter = function(self, player, to_select, selected)
    return #selected == 0 and to_select ~= player
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    room:invalidateSkill(player, huoxin.name, nil, huoxin.name)
    local yes = Fk:getCardById(effect.cards[1]).suit == Card.Heart
    U.presentCard(player, target, effect.cards[1], huoxin.name)
    if yes and not player.dead and not target:isKongcheng() then
      local moves = {}
      if not player:isKongcheng() then
        table.insert(moves, {
          from = player,
          to = player,
          ids = player:getCardIds("h"),
          toArea = Card.PlayerSpecial,
          moveReason = fk.ReasonJustMove,
          skillName = huoxin.name,
          specialName = "#steam__huoxin",
          moveVisible = false,
        })
      end
      local cards = {}
      for _, id in ipairs(target:getCardIds("h")) do
        local c = Fk:getCardById(id)
        local new_id = room:printCard(c.name, c.suit, c.number).id
        table.insert(cards, new_id)
        room:addTableMark(player, "steam__huoxin-turn", new_id)
        room:addTableMark(target, "steam__huoxin_info-turn", new_id)
      end
      table.insert(moves, {
        to = player,
        ids = cards,
        toArea = Card.PlayerHand,
        moveReason = fk.ReasonJustMove,
        skillName = huoxin.name,
        moveVisible = false,
      })
      room:moveCards(table.unpack(moves))
    end
  end,
})

huoxin:addEffect(fk.TurnEnd, {
  mute = true,
  is_delay_effect = true,
  can_trigger = function (self, event, target, player, data)
    return target == player and player:getMark("steam__huoxin-turn") ~= 0
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local moves = {}
    if #player:getPile("#steam__huoxin") > 0 then
      table.insert(moves, {
        from = player,
        to = player,
        ids = player:getPile("#steam__huoxin"),
        toArea = Card.PlayerHand,
        moveReason = fk.ReasonJustMove,
        skillName = huoxin.name,
        fromSpecialName = "#steam__huoxin",
        moveVisible = false,
      })
    end
    local cards = table.filter(player:getMark("steam__huoxin-turn"), function (id)
      return table.contains(player:getCardIds("h"), id)
    end)
    if #cards > 0 then
      table.insert(moves, {
        from = player,
        to = player,
        ids = cards,
        toArea = Card.Void,
        moveReason = fk.ReasonJustMove,
        skillName = huoxin.name,
        moveVisible = true,
      })
    end
    if #moves > 0 then
      room:moveCards(table.unpack(moves))
    end
  end,
})

huoxin:addEffect(fk.CardUseFinished, {
  anim_type = "control",
  can_trigger = function (self, event, target, player, data)
    if target == player and
      (data.card.type == Card.TypeBasic or data.card:isCommonTrick()) and #data.tos > 0 and
      table.contains(player:getTableMark("steam__huoxin-turn"), data.card.id) then
      local to = table.find(player.room:getOtherPlayers(player, false), function (p)
        return table.contains(p:getTableMark("steam__huoxin_info-turn"), data.card.id) and not p:isKongcheng()
      end)
      if to and table.find(data.tos, function (p)
        return not p.dead and to:canUseTo(Fk:cloneCard(data.card.trueName), p, { bypass_distances = true, bypass_times = true })
      end) then
        event:setCostData(self, {tos = {to}})
        return true
      end
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local name = data.card.trueName
    local to = event:getCostData(self).tos[1]
    local ids = table.filter(to:getCardIds("h"), function (id)
      return Fk:getCardById(id).trueName == name
    end)
    room:askToUseRealCard(to, {
      skill_name = huoxin.name,
      pattern = ids,
      prompt = "#steam__huoxin-use:::"..name,
      cancelable = #ids == 0,
      extra_data = {
        bypass_times = true,
        extraUse = true,
        exclusive_targets = table.map(data.tos, Util.IdMapper),
      },
    })
  end,
})

huoxin:addEffect(fk.Deathed, {
  late_refresh = true,
  can_refresh = function (self, event, target, player, data)
    return player:hasSkill(huoxin.name, true)
  end,
  on_refresh = function (self, event, target, player, data)
    player.room:validateSkill(player, huoxin.name, nil, huoxin.name)
  end,
})

return huoxin
