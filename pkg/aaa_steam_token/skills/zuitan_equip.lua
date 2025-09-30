local skill = fk.CreateSkill {
  name = "steam_zuitan_equip_skill&",
  attached_equip = "steam_zuitan_equip",
}

Fk:loadTranslationTable{
  ["steam_zuitan_equip_skill&"] = "散轶诗简",
  [":steam_zuitan_equip_skill&"] = "每轮限一次，你失去最后的手牌后可以摸一张【酒】。此牌进入弃牌堆后销毁。",
}

skill:addEffect(fk.AfterCardsMove, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    if player.room.logic:getCurrentEvent():findParent(GameEvent.Round, true) == nil then return end
    for _, move in ipairs(data) do
      if move.from and move.from:isKongcheng() and move.from == player and player:hasSkill(skill.name) and 
      player:usedSkillTimes(skill.name, Player.HistoryRound) == 0 then
        for _, info in ipairs(move.moveInfo) do
          if info.fromArea == Card.PlayerHand then
            return true
          end
        end
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local card = player.room:getCardsFromPileByRule("analeptic", 1, "allPiles")
    if #card > 0 then
      player.room:moveCardTo(card, Card.PlayerHand, player, fk.ReasonPrey, skill.name, nil, false, player)
    end
  end,
})

return skill
