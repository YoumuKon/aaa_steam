local skill = fk.CreateSkill {
  name = "steam__yanke_card_skill",
}

skill:addEffect("cardskill", {
  mute = true,
  mod_target_filter = Util.TrueFunc,
  target_filter = Util.CardTargetFilter,
  target_num = 1,
  on_effect = function(self, room, effect)
    local to = effect.to
    if not to.dead then
      local skillName = skill.name
      if effect.card and Fk:cloneCard(effect.card.name).is_damage_card then
        skillName = Fk:cloneCard(effect.card.name).skill.name
      end
      room:damage({
        from = effect.from,
        to = to,
        card = effect.card,
        damage = 1,
        skillName = skillName,
      })
    end
  end,
})

Fk:loadTranslationTable{
  ["steam__yanke_card_skill"] = "严恪",
}

return skill
