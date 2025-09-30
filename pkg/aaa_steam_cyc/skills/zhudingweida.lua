local skel = fk.CreateSkill {
  name = "steam__zhudingweida",
  tags = {Skill.Compulsory},
}

Fk:loadTranslationTable{
  ["steam__zhudingweida"] = "注定伟大",
  [":steam__zhudingweida"] = "锁定技，每回合限两次，当你获得一张非基本牌后，弃置之，然后随机获得两张基本牌。",
}

skel:addEffect(fk.AfterCardsMove, {
  anim_type = "drawcard",
  times = function (_, player)
    return 2 - player:usedSkillTimes(skel.name)
  end,
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(skel.name) or player:usedSkillTimes(skel.name) > 1 then return false end
    local ids = {}
    for _, move in ipairs(data) do
      if move.toArea == Player.Hand then
        for _, info in ipairs(move.moveInfo) do
          if table.contains(player.player_cards[Player.Hand], info.cardId) and Fk:getCardById(info.cardId).type ~= Card.TypeBasic then
            table.insertIfNeed(ids, info.cardId)
          end
        end
      end
    end
    ids = player.room.logic:moveCardsHoldingAreaCheck(ids)
    if #ids > 0 then
      event:setCostData(self, {cards = ids})
      return true
    end
  end,
  on_trigger = function (self, event, target, player, data)
    local cards = table.simpleClone(event:getCostData(self).cards)
    for _, id in ipairs(cards) do
      if not player:hasSkill(skel.name) or player:usedSkillTimes(skel.name) > 1 then break end
      if table.contains(player.player_cards[Player.Hand], id) and not player:prohibitDiscard(id) then
        self:doCost(event, player, player, id)
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:delay(200)
    room:throwCard(data, skel.name, player, player)
    if not player.dead then
      local ids = room:getCardsFromPileByRule(".|.|.|.|.|basic", 2)
      if #ids > 0 then
        room:obtainCard(player, ids, false, fk.ReasonJustMove, player, skel.name)
      end
    end
  end,
})

return skel
