local skel = fk.CreateSkill {
  name = "steam__secret_passage",
}

Fk:loadTranslationTable{
  ["steam__secret_passage"] = "秘密通道",
  [":steam__secret_passage"] = "每轮限一次，一名角色的出牌阶段开始时，你可以令其用所有手牌替换牌堆底的四张牌（使用时无次数限制），回合结束时换回。",

  ["#secret_passage-invoke"] = "秘密通道：是否令 %dest 用所有手牌交换牌堆底四张牌，回合结束换回？",
  ["@@steam__secret_passage-inhand-turn"] = "秘密通道",
}

skel:addEffect(fk.EventPhaseStart, {
  anim_type = "drawcard",
  times = function (_, player)
    return 1 - player:usedSkillTimes(skel.name, Player.HistoryRound)
  end,
  can_trigger = function (self, event, target, player, data)
    return player:hasSkill(self) and target.phase == Player.Play and not target.dead and
      player:usedSkillTimes(skel.name, Player.HistoryRound) == 0
  end,
  on_cost = function (self, event, target, player, data)
    if player.room:askToSkillInvoke(player, { skill_name = skel.name, prompt = "#secret_passage-invoke::"..target.id}) then
      event:setCostData(self, {tos = {target}})
      return true
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local info = {target:getCardIds("h"), room:getNCards(4, "bottom")}
    room:setPlayerMark(target, "steam__secret_passage-turn", info)
    local moves = {}
    if #info[1] > 0 then
      table.insert(moves, {
        from = target,
        ids = info[1],
        toArea = Card.DrawPile,
        moveReason = fk.ReasonExchange,
        skillName = skel.name,
        drawPilePosition = -1,
        moveVisible = false,
        proposer = target,
      })
    end
    table.insert(moves, {
      ids = info[2],
      to = target,
      toArea = Card.PlayerHand,
      moveReason = fk.ReasonExchange,
      skillName = skel.name,
      moveVisible = false,
      proposer = target,
      moveMark = "@@steam__secret_passage-inhand-turn",
    })
    room:moveCards(table.unpack(moves))
  end,
})

skel:addEffect(fk.TurnEnd, {
  is_delay_effect = true,
  anim_type = "drawcard",
  can_trigger = function (self, event, target, player, data)
    return player:getMark("steam__secret_passage-turn") ~= 0 and not player.dead
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local info = player:getMark("steam__secret_passage-turn")
    local moves = {}
    local cards = table.filter(info[1], function (id)
      return table.contains(room.draw_pile, id)
    end)
    if #cards > 0 then
      table.insert(moves, {
        ids = cards,
        to = player,
        toArea = Card.PlayerHand,
        moveReason = fk.ReasonExchange,
        skillName = skel.name,
        moveVisible = false,
        proposer = player,
      })
    end
    cards = table.filter(info[2], function (id)
      return table.contains(player:getCardIds("h"), id) and Fk:getCardById(id):getMark("@@steam__secret_passage-inhand-turn") > 0
    end)
    if #cards > 0 then
      table.insert(moves, {
        from = player,
        ids = cards,
        toArea = Card.DrawPile,
        moveReason = fk.ReasonExchange,
        skillName = skel.name,
        drawPilePosition = -1,
        moveVisible = false,
        proposer = player,
      })
    end
    if #moves > 0 then
      room:moveCards(table.unpack(moves))
    end
  end,
})

skel:addEffect(fk.PreCardUse, {
  can_refresh = function (self, event, target, player, data)
    return target == player and data.card:getMark("@@steam__secret_passage-inhand-turn") ~= 0
  end,
  on_refresh = function (self, event, target, player, data)
    data.extraUse = true
  end,
})

skel:addEffect("targetmod", {
  bypass_times = function(self, player, skill, scope, card, to)
    return card and card:getMark("@@steam__secret_passage-inhand-turn") ~= 0
  end,
})

return skel
