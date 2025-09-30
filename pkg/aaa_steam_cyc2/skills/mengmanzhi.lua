local skel = fk.CreateSkill {
  name = "steam__mengmanzhi",
  tags = {Skill.Compulsory}
}

Fk:loadTranslationTable{
  ["steam__mengmanzhi"] = "梦满枝",
  [":steam__mengmanzhi"] = "锁定技，【乐不思蜀】对你的判定效果改为：若结果为<font color='red'>♥</font>，你回复1点体力；不为<font color='red'>♥</font>，本回合首个出牌阶段结束后，你再执行一个出牌阶段。",

  ["@@steam__mengmanzhi-turn"] = "梦满枝",

  ["$steam__mengmanzhi1"] = "梦呀，我喜欢和你说话。",
  ["$steam__mengmanzhi2"] = "只有闭上眼睛，才能真正的看见，哈呀——",
}

skel:addEffect(fk.CardEffecting, {
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(skel.name) and target == player and data.card.trueName == "indulgence"
  end,
  on_use = function(self, event, target, player, data)
    data:changeCardSkill("mengmanzhi__indulgence_skill")
  end,
})

skel:addEffect(fk.EventPhaseEnd, {
  can_refresh = function (self, event, target, player, data)
    return target == player and player.phase == Player.Play and player:getMark("@@steam__mengmanzhi-turn") ~= 0
  end,
  on_refresh = function (self, event, target, player, data)
    player.room:setPlayerMark(player, "@@steam__mengmanzhi-turn", 0)
    player:gainAnExtraPhase(Player.Play, skel.name, true)
  end,
})

return skel
