local skel = fk.CreateSkill {
  name = "steam__daozu",
  tags = {Skill.Quest},
}

Fk:loadTranslationTable{
  ["steam__daozu"] = "刀俎",
  [":steam__daozu"] = "使命技，当你成为其他角色的伤害牌的目标时，你可以失去1点体力，取消自己并视为使用此牌。"..
  "<br>⬤　成功：准备阶段，若所有角色均受伤，你将“刀俎”删去使命并获得“斧钺”；"..
  "<br>⬤　失败：放弃发动“刀俎”。",

  ["#steam__daozu-ask"] = "刀俎：你可以失去1点体力，取消你为%arg的目标，并视为使用之",
  ["steam__daozu_copy"] = "刀俎",
  [":steam__daozu_copy"] = "当你成为其他角色的伤害牌的目标时，你可以失去1点体力，取消并视为使用此牌。",

  ["$steam__daozu1"] = "刀俎在前，今欲为耕牛而不可得。",
  ["$steam__daozu2"] = "昧纤钩而食饵，终难逃汤镬。",
  ["$steam__daozu3"] = "尔朱无道，弑君虐民，正英雄立功之会！",
}

skel:addEffect(fk.TargetConfirming, {
  anim_type = "offensive",
  audio_index = {1, 2},
  can_trigger = function (self, event, target, player, data)
    if player:hasSkill(skel.name) and target == player and player:getQuestSkillState(skel.name) == nil then
      return data.card.is_damage_card and data.from and data.from ~= player
    end
  end,
  on_cost = function (self, event, target, player, data)
    if player.room:askToSkillInvoke(player, { skill_name = skel.name, prompt = "#steam__daozu-ask:::"..data.card:toLogString()}) then
      return true
    else
      player.room:updateQuestSkillState(player, skel.name, true)
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    room:loseHp(player, 1, skel.name)
    data:cancelCurrentTarget()
    if not player.dead then
      room:askToUseVirtualCard(player, {
        name = data.card.name,  skill_name = skel.name, cancelable = false,
      })
    end
  end,
})

skel:addEffect(fk.EventPhaseStart, {
  anim_type = "big",
  audio_index = 3,
  can_trigger = function (self, event, target, player, data)
    if player:hasSkill(skel.name) and target == player and player:getQuestSkillState(skel.name) == nil then
      return player.phase == Player.Start and table.every(player.room.alive_players, function (p)
        return p:isWounded()
      end)
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    local room = player.room
    room:updateQuestSkillState(player, skel.name, false)
    room:handleAddLoseSkills(player, "-steam__daozu|steam__daozu_copy|steam__fuyue")
  end,
})

return skel
