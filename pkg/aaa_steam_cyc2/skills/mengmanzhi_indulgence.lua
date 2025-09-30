local skill = fk.CreateSkill {
  name = "mengmanzhi__indulgence_skill",
}

skill:addEffect("cardskill", {
  prompt = "#indulgence_skill",
  mod_target_filter = function(self, player, to_select, selected, card, distance_limited)
    return to_select ~= player
  end,
  target_filter = Util.CardTargetFilter,
  target_num = 1,
  on_effect = function(self, room, effect)
    local to = effect.to
    local judge = {
      who = to,
      reason = "indulgence",
      pattern = ".",
    }
    room:judge(judge)
    if judge.card then
      if judge.card.suit == Card.Heart then
        room:recover { num = 1, skillName = self.name, who = to, recoverBy = to, card = effect.card }
      else
        room:setPlayerMark(to, "@@steam__mengmanzhi-turn", 1)
      end
    end
    self:onNullified(room, effect)
  end,
  on_nullified = function(self, room, effect)
    room:moveCards{
      ids = room:getSubcardsByRule(effect.card, { Card.Processing }),
      toArea = Card.DiscardPile,
      moveReason = fk.ReasonUse,
    }
  end,
})

Fk:loadTranslationTable{
  ["mengmanzhi__indulgence_skill"] = "乐不思蜀",
}

return skill
