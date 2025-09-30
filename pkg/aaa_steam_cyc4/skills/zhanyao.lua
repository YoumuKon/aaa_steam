local zhanyao = fk.CreateSkill{
  name = "steam__zhanyao",
  tags = { Skill.Limited },
}

Fk:loadTranslationTable{
  ["steam__zhanyao"] = "绽耀",
  [":steam__zhanyao"] = "限定技，出牌阶段，你可以将场上所有的【浮雷】移至一名角色的判定区内（无视张数限制），每张【浮雷】在造成伤害前不会再移动。",

  ["#steam__zhanyao"] = "绽耀：将场上所有的【浮雷】移至一名角色！",

  ["$steam__zhanyao1"] = "控制好距离——嘿！",
  ["$steam__zhanyao2"] = "有敌人吗？！",
}

zhanyao:addEffect("active", {
  anim_type = "offensive",
  card_num = 0,
  target_num = 1,
  prompt =  "#steam__zhanyao",
  can_use = function (self, player)
    return player:usedSkillTimes(zhanyao.name, Player.HistoryGame) == 0 and
      table.find(Fk:currentRoom().alive_players, function (p)
        return p:hasDelayedTrick("floating_thunder")
      end)
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected)
    if #selected == 0 then
      return not table.contains(to_select.sealedSlots, Player.JudgeSlot)
    end
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    room:setBanner(zhanyao.name, 1)
    for _, p in ipairs(room:getOtherPlayers(target)) do
      if target.dead or table.contains(target.sealedSlots, Player.JudgeSlot) then return end
      if not p.dead and p:hasDelayedTrick("floating_thunder") then
        for _, id in ipairs(p:getCardIds("j")) do
          if table.contains(p:getCardIds("j"), id) then
            local card = p:getVirtualEquip(id)
            if card == nil then
              card = Fk:getCardById(id)
            end
            if card.name == "floating_thunder" then
              room:moveCardTo(card, Card.PlayerJudge, target, fk.ReasonJustMove, zhanyao.name, nil, true, player)
            end
          end
        end
      end
    end
  end,
})

zhanyao:addEffect(fk.BeforeCardsMove, {
  can_refresh = function (self, event, target, player, data)
    if player.seat == 1 and player.room:getBanner(zhanyao.name) then
      for _, move in ipairs(data) do
        if move.toArea == Card.PlayerJudge and move.moveReason == fk.ReasonPut then
          local effect_data = player.room.logic:getCurrentEvent():findParent(GameEvent.CardEffect)
          return effect_data and effect_data.data.card.name == "floating_thunder" and
            not (effect_data.data.to.dead or table.contains(effect_data.data.to.sealedSlots, Player.JudgeSlot))
        end
      end
    end
  end,
  on_refresh = function (self, event, target, player, data)
    for _, move in ipairs(data) do
      if move.toArea == Card.PlayerJudge and move.moveReason == fk.ReasonPut then
        local effect_data = player.room.logic:getCurrentEvent():findParent(GameEvent.CardEffect)
        if effect_data and effect_data.data.card.name == "floating_thunder" and
          not (effect_data.data.to.dead or table.contains(effect_data.data.to.sealedSlots, Player.JudgeSlot)) then
          move.to = effect_data.data.to
        end
      end
    end
  end,
})
return zhanyao
