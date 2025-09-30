local skel = fk.CreateSkill {
  name = "steam__lale",
  tags = {Skill.Compulsory},
}

Fk:loadTranslationTable{
  ["steam__lale"] = "拉了",
  [":steam__lale"] = "锁定技，每轮开始时，你摸一张点数为10的牌。",
}

skel:addEffect(fk.RoundStart, {
  anim_type = "drawcard",
  can_trigger = function (self, event, target, player, data)
    return player:hasSkill(skel.name)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local ids = room:getCardsFromPileByRule(".|10")
    if #ids > 0 then
      room:obtainCard(player, ids, true, fk.ReasonJustMove, player, skel.name)
    end
  end,
})

return skel
