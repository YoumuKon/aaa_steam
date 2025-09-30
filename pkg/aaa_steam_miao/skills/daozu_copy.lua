local skel = fk.CreateSkill {
  name = "steam__daozu_copy",
}

Fk:loadTranslationTable{
  ["steam__daozu_copy"] = "刀俎",
  [":steam__daozu_copy"] = "当你成为其他角色的伤害牌的目标时，你可以失去1点体力，取消自己并视为使用此牌。",
}

skel:addEffect(fk.TargetConfirming, {
 mute = true,
  can_trigger = function (self, event, target, player, data)
    if player:hasSkill(skel.name) and target == player then
      return data.card.is_damage_card and data.from and data.from ~= player
    end
  end,
  on_cost = function (self, event, target, player, data)
    return player.room:askToSkillInvoke(player, { skill_name = skel.name, prompt = "#steam__daozu-ask:::"..data.card:toLogString()})
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    room:notifySkillInvoked(player, "steam__daozu", "offensive")
    player:broadcastSkillInvoke("steam__daozu", math.random(2))
    room:loseHp(player, 1, skel.name)
    data:cancelCurrentTarget()
    if not player.dead then
      room:askToUseVirtualCard(player, {
        name = data.card.name,  skill_name = skel.name, cancelable = false,
      })
    end
  end,
})


return skel
