local skel = fk.CreateSkill {
  name = "steam__wansheng",
}

Fk:loadTranslationTable{
  ["steam__wansheng"] = "万乘",
  [":steam__wansheng"] = "轮次技，任意角色的准备阶段，你可指定一名其他角色，然后当前回合内：指定角色的手牌对你可见，且你可将其手牌当你的手牌使用（每回合每种花色各限一次）；当前回合结束时，若指定角色失去的牌数不多于你，重置此技能的次数。",

  ["#steam__wansheng"] = "万乘：你可以使用 %src 的手牌(每牌名限一次)",
  ["#steam__wansheng-choose"] = "万乘：指定一名其他角色，本回合其手牌对你可见且你可使用之",
  ["@[chara]steam__wansheng-turn"] = "万乘→",
  ["@steam__wansheng_suit-turn"] = "万乘",

  ["$steam__wansheng1"] = "",
  ["$steam__wansheng2"] = "",
}

skel:addEffect("viewas", {
  pattern = ".",
  prompt = function (self, player, selected_cards, selected)
    local to = player:getMark("@[chara]steam__wansheng-turn")
    if to ~= 0 then
      return "#steam__wansheng:"..to
    end
    return " "
  end,
  expand_pile = function (self, player)
    local to = Fk:currentRoom():getPlayerById(player:getMark("@[chara]steam__wansheng-turn"))
    if to then
      return to:getCardIds("h")
    end
    return {}
  end,
  card_filter = function (self, player, to_select, selected)
    local to = Fk:currentRoom():getPlayerById(player:getMark("@[chara]steam__wansheng-turn"))
    if to and table.contains(to:getCardIds("h"), to_select) then
      -- 令客户端强制同步锁视
      Fk:filterCard(to_select, to)
      local card = Fk:getCardById(to_select)
      if #selected == 0 and not table.contains(player:getTableMark("@steam__wansheng_suit-turn"), card:getSuitString(true)) then
        if Fk.currentResponsePattern == nil then
          return player:canUse(card) and not player:prohibitUse(card)
        else
          return Exppattern:Parse(Fk.currentResponsePattern):match(card)
        end
      end
    end
  end,
  view_as = function (self, player, cards)
    if #cards ~= 1 then return end
    return Fk:getCardById(cards[1])
  end,
  before_use = function (self, player, use)
    -- 谨慎的检查
    local cid = use.card:getEffectiveId()
    if cid == nil then return "" end
    local to = Fk:currentRoom():getPlayerById(player:getMark("@[chara]steam__wansheng-turn"))
    if not to or not table.contains(to:getCardIds("h"), cid) then return "" end
    player.room:addTableMark(player, "@steam__wansheng_suit-turn", use.card:getSuitString(true))
  end,
  enabled_at_play = function(self, player)
    return player:getMark("@[chara]steam__wansheng-turn") ~= 0
  end,
  enabled_at_response = function(self, player, response)
    if not response and Fk.currentResponsePattern then
      local to = Fk:currentRoom():getPlayerById(player:getMark("@[chara]steam__wansheng-turn"))
      return to and table.find(to:getCardIds("h"), function (id)
        return Exppattern:Parse(Fk.currentResponsePattern):match(Fk:getCardById(id))
      end)
    end
  end,
  times = function (self, player)
    return 1 - player:getMark("steam__wansheng_used-round")
  end,
})

skel:addEffect(fk.EventPhaseStart, {
  --names = "#steam__wansheng_trig",
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    if target.phase ~= Player.Start or not player:hasSkill(skel.name) then return false end
    return player:getMark("steam__wansheng_used-round") == 0
    --player:usedEffectTimes(self.name, Player.HistoryRound) == 0
  end,
  on_cost = function (self, event, target, player, data)
    local targets = player.room:getOtherPlayers(player, false)
    local tos = player.room:askToChoosePlayers(player, {
      min_num = 1, max_num = 1, targets = targets, skill_name = skel.name, prompt = "#steam__wansheng-choose"
    })
    if #tos > 0 then
      event:setCostData(self, {tos = tos})
      return true
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(player, "steam__wansheng_used-round", 1)
    local to = event:getCostData(self).tos[1]
    to:filterHandcards()
    room:setPlayerMark(player, "@[chara]steam__wansheng-turn", to.id)
  end,
})

skel:addEffect(fk.TurnEnd, {
  can_refresh = function (self, event, target, player, data)
    return player:getMark("@[chara]steam__wansheng-turn") ~= 0
  end,
  on_refresh = function (self, event, target, player, data)
    local room = player.room
    local toId = player:getMark("@[chara]steam__wansheng-turn")
    local toNum, myNum = 0, 0
    room.logic:getEventsOfScope(GameEvent.MoveCards, 1, function(e)
      for _, move in ipairs(e.data) do
        local loseNum = #table.filter(move.moveInfo, function (info)
          return info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip
        end)
        if move.from == player then
          myNum = myNum + loseNum
        elseif move.from and move.from.id == toId then
          toNum = toNum + loseNum
        end
      end
      return false
    end, Player.HistoryTurn)
    if toNum <= myNum then
      room:setPlayerMark(player, "steam__wansheng_used-round", 0)
    end
  end,
})

skel:addEffect("visibility", {
  card_visible = function(self, player, card)
    local to = Fk:currentRoom():getPlayerById(player:getMark("@[chara]steam__wansheng-turn"))
    if to and table.contains(to:getCardIds("h"), card.id) then
      return true
    end
  end
})

skel:addLoseEffect(function (self, player, is_death)
  player.room:setPlayerMark(player, "steam__wansheng_used-round", 0)
  player.room:setPlayerMark(player, "@[chara]steam__wansheng-turn", 0)
  player.room:setPlayerMark(player, "@steam__wansheng_suit-turn", 0)
end)

return skel
