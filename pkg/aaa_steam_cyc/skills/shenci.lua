local skel = fk.CreateSkill {
  name = "steam__shenci",
  tags = {Skill.Compulsory},
}

Fk:loadTranslationTable{
  ["steam__shenci"] = "神赐",
  [":steam__shenci"] = "锁定技，每回合开始时，若你未装备【护心镜】，你使用一张(进入弃牌堆时销毁)。你失去装备区一张牌后，摸一张牌。",
  -- 若防具栏被废除先恢复之
}

skel:addEffect(fk.TurnStart, {
  anim_type = "defensive",
  can_trigger = function (self, event, target, player, data)
    if not player:hasSkill(skel.name) then return false end
    return not table.find(player:getEquipments(Card.SubtypeArmor), function (id) return Fk:getCardById(id).trueName == "breastplate" end)
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local orig_card = Fk.all_card_types["breastplate"]
    if not orig_card then return end
    local card = room:printCard("breastplate", Card.Club, 1)
    if table.contains(player.sealedSlots, Player.ArmorSlot) then
      room:resumePlayerArea(player, Player.ArmorSlot)
    end
    room:setCardMark(card, MarkEnum.DestructIntoDiscard, 1)
    room:useCard{from = player, tos = {player}, card = card}
  end,
})

skel:addEffect(fk.AfterCardsMove, {
  anim_type = "drawcard",
  can_trigger = function (self, event, target, player, data)
    if not player:hasSkill(skel.name) then return false end
    for _, move in ipairs(data) do
      if move.from == player then
        for _, info in ipairs(move.moveInfo) do
          if info.fromArea == Card.PlayerEquip then
            return true
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
          if info.fromArea == Card.PlayerEquip then
            n = n + 1
          end
        end
      end
    end
    return n
  end,
  on_use = function (self, event, target, player, data)
    player:drawCards(1, skel.name)
  end,
})


return skel
