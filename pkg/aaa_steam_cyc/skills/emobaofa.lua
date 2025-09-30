local skel = fk.CreateSkill {
  name = "steam__emobaofa",
}

Fk:loadTranslationTable{
  ["steam__emobaofa"] = "恶魔爆发",
  [":steam__emobaofa"] = "你杀死角色时，可以不执行奖惩，改为令〖血倾〗的发动次数+1。",

  ["@steam__emobaofa"] = "恶魔爆发",
  ["#steam__emobaofa-invoke"] = "恶魔爆发：你可以不执行击杀奖惩，改为令〖血倾〗的发动次数+1",
}

skel:addEffect(fk.Death, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(skel.name) and data.killer == player
    and not (data.extra_data and data.extra_data.skip_reward_punish)
  end,
  on_cost = function (self, event, target, player, data)
    return player.room:askToSkillInvoke(player, { skill_name = skel.name, prompt = "#steam__emobaofa-invoke"})
  end,
  on_use = function(self, event, target, player, data)
    data.extra_data = data.extra_data or {}
    data.extra_data.skip_reward_punish = true
    player.room:addPlayerMark(player, "@steam__emobaofa", 1)
  end,
})

return skel
