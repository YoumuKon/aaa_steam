local skel = fk.CreateSkill {
  name = "steam__kuanlu",
  tags = {Skill.Compulsory},
}

Fk:loadTranslationTable{
  ["steam__kuanlu"] = "宽路",
  [":steam__kuanlu"] = "锁定技，你摸牌前，先卜算双倍数量的牌。",
}

skel:addEffect(fk.BeforeDrawCard, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(skel.name) and target == player and data.num > 0
  end,
  on_use = function(self, event, target, player, data)
    player.room:askToGuanxing(player, { cards = player.room:getNCards(data.num * 2), skill_name = self.name})
  end,
})

return skel
