local qianju = fk.CreateSkill {
  name = "steamMinshe__qianju",
  tags = { Skill.Compulsory }
}

qianju:addAcquireEffect(function(self, player, is_start)
  if is_start then return end
  local room = player.room
  local holder = { fk.ReasonDiscard, fk.ReasonUse }
  local ret = {}
  room.logic:getEventsByRule(GameEvent.MoveCards, 1, function(e)
    local data = e.data
    for _, move in ipairs(data) do
      if move.from and move.to ~= move.from and table.contains(holder, move.moveReason) then
        for _, info in ipairs(move.moveInfo) do
          if table.contains({ Player.Hand, Player.Equip }, info.fromArea) and room:getCardOwner(info.cardId) ~= move.from then
            ret[move.moveReason] = move.from
            table.removeOne(holder, move.moveReason)
            return #holder == 0
          end
        end
      end
    end
  end, 0)
  for reason, to in pairs(ret) do
    local mark = "@@steamMinshe__qianju_" .. Util.moveReasonMapper(reason)
    room:setPlayerMark(to, mark, 1)
  end
end)
qianju:addLoseEffect(function(self, player, is_death)
  local room = player.room
  if table.find(room.alive_players, function(p)
    return p:hasSkill(qianju.name, true)
  end) then return end
  for _, to in ipairs(room.alive_players) do
    room:setPlayerMark(to, "@@steamMinshe__qianju_reason_use", 0)
    room:setPlayerMark(to, "@@steamMinshe__qianju_reason_discard", 0)
  end
end)

qianju:addEffect(fk.CardUsing, {
  can_refresh = function(self, event, target, player, data)
    if target == player and player:hasSkill(qianju.name) and data.card and data.card.type ~= Card.TypeEquip then
      for _, to in ipairs(data:getAllTargets()) do
        if to:getMark("@@steamMinshe__qianju_reason_use") ~= 0 and to:getMark("@@steamMinshe__qianju_reason_discard") ~= 0 then
          return true
        end
      end
    end
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    room.logic:getCurrentEvent():addExitFunc(function()
      player:drawCards(2, qianju.name)
    end)
  end,
})
qianju:addEffect(fk.AfterCardsMove, {
  can_refresh = function(self, event, target, player, data)
    for _, move in ipairs(data) do
      if move.from == player and move.to ~= player and table.contains({ fk.ReasonDiscard, fk.ReasonUse }, move.moveReason) then
        for _, info in ipairs(move.moveInfo) do
          if table.contains({ Player.Hand, Player.Equip }, info.fromArea) and player.room:getCardOwner(info.cardId) ~= player then
            event:setSkillData(self, "steamMinshe__qianju_reason", Util.moveReasonMapper(move.moveReason))
            return true
          end
        end
      end
    end
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    local mark = "@@steamMinshe__qianju_" .. event:getSkillData(self, "steamMinshe__qianju_reason")
    for _, to in ipairs(room.alive_players) do
      if to == player then
        room:setPlayerMark(to, mark, 1)
      else
        room:setPlayerMark(to, mark, 0)
      end
    end
  end
})
qianju:addEffect("targetmod", {
  bypass_distances = function(self, player, skill, card, to)
    if player:hasSkill(qianju.name) and to:getMark("@@steamMinshe__qianju_reason_discard") ~= 0 and card and card.type ~= Card.TypeEquip then
      return true
    end
  end,
  bypass_times = function(self, player, skill, scope, card, to)
    if player:hasSkill(qianju.name) and to and to:getMark("@@steamMinshe__qianju_reason_use") ~= 0 and card and card.type ~= Card.TypeEquip then
      return true
    end
  end
})

Fk:loadTranslationTable{
  ["steamMinshe__qianju"] = "千驹",
  [":steamMinshe__qianju"] = "锁定技，你对上一名因弃置/使用失去牌的角色使用非装备牌无距离/次数限制，若为同一名角色，此牌结算后你摸两张牌。",

  ["@@steamMinshe__qianju_reason_use"] = "千驹 使用",
  ["@@steamMinshe__qianju_reason_discard"] = "千驹 弃置",
}

return qianju