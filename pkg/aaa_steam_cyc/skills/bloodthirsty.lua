local skel = fk.CreateSkill {
  name = "steam__bloodthirsty",
  tags = {Skill.Compulsory},
}

Fk:loadTranslationTable{
  ["steam__bloodthirsty"] = "嗜血",
  [":steam__bloodthirsty"] = "锁定技，摸牌阶段，你改为随机获得三张黑色牌。",
}

skel:addEffect(fk.EventPhaseStart, {
  anim_type = "drawcard",
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(skel.name) and player.phase == Player.Draw and not data.phase_end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    data.phase_end = true
    local ids = room:getCardsFromPileByRule(".|.|spade,club", 3, "allPiles")
    if #ids > 0 then
      room:obtainCard(player, ids, false, fk.ReasonJustMove, player, skel.name)
    end
  end,
})



return skel
