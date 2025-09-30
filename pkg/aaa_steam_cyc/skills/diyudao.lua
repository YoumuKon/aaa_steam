local skel = fk.CreateSkill {
  name = "steam__diyudao",
  tags = {Skill.Compulsory}
}

Fk:loadTranslationTable{
  ["steam__diyudao"] = "地狱道",
  [":steam__diyudao"] = "锁定技，判定阶段，你改为进行一次【浮雷】判定并获得判定牌。",
}

skel:addEffect(fk.EventPhaseStart, {
  anim_type = "drawcard",
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(skel.name) and player.phase == Player.Judge and not data.phase_end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    data.phase_end = true
    local judge = {
      who = player,
      reason = "floating_thunder",
      pattern = ".|.|spade",
      skipDrop = true,
    }
    room:judge(judge)
    if judge.card.suit == Card.Spade and not player.dead then
      room:damage{
        to = player,
        damage = 1,
        damageType = fk.ThunderDamage,
        skillName = skel.name,
      }
    end
    if room:getCardArea(judge.card) == Card.Processing then
      if not player.dead then
        room:obtainCard(player, judge.card, true, fk.ReasonJustMove, player, skel.name)
      else
        room:moveCardTo(judge.card, Card.DiscardPile, nil, fk.ReasonJudge)
      end
    end
  end,
})



return skel
