local skel = fk.CreateSkill {
  name = "steam__jishijiunan",
  tags = {Skill.Limited},
}

Fk:loadTranslationTable{
  ["steam__jishijiunan"] = "及时救难",
  [":steam__jishijiunan"] = "限定技，一名角色进入濒死状态时，你可以令其回复体力至上限。若如此做，每回合结束时，其失去1点体力，直到其造成致命伤害。",

  ["@@steam__jishijiunan"] = "及时救难",
  ["#steam__jishijiunan-invoke"] = "及时救难：你可以令 %src 回复体力至上限。但其每回合失去体力，直到造成致命伤害",

  ["$steam__jishijiunan1"] = "好好干活",
  ["$steam__jishijiunan2"] = "证明你的价值吧",
}

skel:addEffect(fk.EnterDying, {
  audio_index = 2,
  can_trigger = function(self, event, target, player, data)
    return player:usedSkillTimes(skel.name, Player.HistoryGame) == 0 and player:hasSkill(skel.name) and not target.dead
  end,
  on_cost = function (self, event, target, player, data)
    if player.room:askToSkillInvoke(player, { skill_name = skel.name, prompt = "#steam__jishijiunan-invoke:"..target.id}) then
      event:setCostData(self, {tos = {target}})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:recover({ who = target, num = target.maxHp - target.hp, recoverBy = player, skillName = skel.name })
    if not target.dead then
      room:setPlayerMark(target, "@@steam__jishijiunan", 1)
    end
  end,
})

skel:addEffect(fk.TurnEnd, {
  is_delay_effect = true,
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return not player.dead and player:getMark("@@steam__jishijiunan") ~= 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    player:broadcastSkillInvoke(skel.name, 1)
    player.room:loseHp(player, 1, skel.name)
  end,
})

skel:addEffect(fk.HpChanged, {
  can_refresh = function (self, event, target, player, data)
    local damage = data.damageEvent
    return player:getMark("@@steam__jishijiunan") ~= 0 and data.num < 0 and damage and damage.from == player
    and target.hp <= 0 and (target.hp + data.shield_lost - data.num) > 0
  end,
  on_refresh = function (self, event, target, player, data)
    player.room:setPlayerMark(player, "@@steam__jishijiunan", 0)
  end,
})

return skel
