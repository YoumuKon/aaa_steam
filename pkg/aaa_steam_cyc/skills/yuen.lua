local skel = fk.CreateSkill {
  name = "steam__yuen",
  tags = {Skill.Compulsory},
}

Fk:loadTranslationTable{
  ["steam__yuen"] = "余恩",
  [":steam__yuen"] = "锁定技，游戏开始时，你使用一张【护心镜】(进入弃牌堆时销毁)；你每摸一张牌，便有15%的概率再次使用一张。",
  -- 若防具栏被废除则恢复之
}

local on_use = function (self, event, target, player, data)
    local room = player.room
    local orig_card = Fk.all_card_types["breastplate"]
    if not orig_card then return end
    if table.contains(player.sealedSlots, Player.ArmorSlot) then
      room:resumePlayerArea(player, Player.ArmorSlot)
    end
    -- 同名装备替换会导致装备技能错误卸载
    local throw = table.filter(player:getCardIds("e"), function (id)
      return Fk:getCardById(id).name == "breastplate"
    end)
    if #throw > 0 then
      room:moveCardTo(throw, Card.DiscardPile, nil, fk.ReasonPutIntoDiscardPile, self.name, nil, true, player)
    end
    if player.dead then return end
    local card = room:printCard("breastplate", Card.Club, 1)
    room:setCardMark(card, MarkEnum.DestructIntoDiscard, 1)
    room:useCard{ from = player, tos = {player}, card = card }
    room:delay(500)
  end

skel:addEffect(fk.GameStart, {
  anim_type = "defensive",
  can_trigger = function (self, event, target, player, data)
    return player:hasSkill(skel.name)
  end,
  on_use = on_use,
})

skel:addEffect(fk.AfterCardsMove, {
  anim_type = "defensive",
  can_trigger = function (self, event, target, player, data)
    if not player:hasSkill(skel.name) then return false end
    for _, move in ipairs(data) do
      if move.to == player and move.toArea == Card.PlayerHand then
        for _, info in ipairs(move.moveInfo) do
          if info.fromArea == Card.DrawPile then
            return true
          end
        end
      end
    end
  end,
  on_trigger = function (self, event, target, player, data)
    local n = 0
    for _, move in ipairs(data) do
      if move.to == player and move.toArea == Card.PlayerHand then
        for _, info in ipairs(move.moveInfo) do
          if info.fromArea == Card.DrawPile and math.random() < 0.15 then
            n = n + 1
          end
        end
      end
    end
    for _ = 1, n do
      if not player:hasSkill(skel.name) then break end
      self:doCost(event, target, player, data)
    end
  end,
  on_use = on_use,
})

return skel
