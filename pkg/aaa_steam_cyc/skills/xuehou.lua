local skel = fk.CreateSkill {
  name = "steam__xuehou",
}

Fk:loadTranslationTable{
  ["steam__xuehou"] = "血吼",
  [":steam__xuehou"] = "你失去一张红色牌后，可以移出一名角色的一张牌，直到回合结束。",

  ["$steam__xuehou"] = "移出",
  ["#steam__xuehou-choose"] = "血吼：你可以移出一名角色的一张牌，直到回合结束",
}

skel:addEffect(fk.AfterCardsMove, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(self) then return false end
    for _, move in ipairs(data) do
      if move.from == player then
        for _, info in ipairs(move.moveInfo) do
          if info.fromArea == Player.Hand or info.fromArea == Player.Equip then
            if Fk:getCardById(info.cardId).color == Card.Red then
              return true
            end
          end
        end
      end
    end
  end,
  trigger_times = function (self, event, target, player, data)
    local n = 0
    for _, move in ipairs(data) do
      if move.from == player then
        for _, info in ipairs(move.moveInfo) do
          if info.fromArea == Player.Hand or info.fromArea == Player.Equip then
            if Fk:getCardById(info.cardId).color == Card.Red then
              n = n + 1
            end
          end
        end
      end
    end
    return n
  end,
  on_cost = function (self, event, target, player, data)
    local targets = table.filter(player.room.alive_players, function (p) return not p:isNude() end)
    if #targets == 0 then return false end
    local tos = player.room:askToChoosePlayers(player, {
      targets = targets, min_num = 1, max_num = 1,
      prompt = "#steam__xuehou-choose", skill_name = skel.name
    })
    if #tos > 0 then
      event:setCostData(self, {tos = tos})
      return true
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local to = event:getCostData(self).tos[1]
    local cards = room:askToChooseCard(player, { target = to, flag = "he", skill_name = skel.name})
    to:addToPile("$steam__xuehou", cards, false, skel.name)
  end,
})

skel:addEffect(fk.TurnEnd, {
  is_delay_effect = true,
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return #player:getPile("$steam__xuehou") > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    player.room:moveCardTo(player:getPile("$steam__xuehou"), Player.Hand, player, fk.ReasonPrey, skel.name)
  end,
})

return skel
