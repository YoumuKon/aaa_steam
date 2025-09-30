local skel = fk.CreateSkill {
  name = "steam__lugong",
}

Fk:loadTranslationTable{
  ["steam__lugong"] = "虏功",
  [":steam__lugong"] = "一名武将牌未横置的角色使用唯一目标的伤害牌被抵消时，你可横置其武将牌；一名武将牌已横置的角色成为非伤害牌的唯一目标后，你可重置其武将牌，再对其造成一点伤害。你因此横置或受到伤害后，你摸三张牌。",

  ["#steam__lugong-chain"] = "虏功：你可横置 %src 武将牌",
  ["#steam__lugong-damage"] = "虏功：你可重置 %src ，再对其造成一点伤害",
  ["#steam__lugong-chainself"] = "虏功：你可横置自己，再摸三张牌",
  ["#steam__lugong-damageself"] = "虏功：你可重置自己，对自己造成一点伤害，再摸3牌",
}

skel:addEffect(fk.CardEffectCancelledOut, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(skel.name) and target and not target.dead then
      if not target.chained and data.card.is_damage_card then
        local tos = data.tos
        return #tos == 1 and tos[1] == data.to
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    local prompt = ""
    if target == player then
      prompt = "#steam__lugong-chainself"
    else
      prompt = "#steam__lugong-chain:"..target.id
    end
    if player.room:askToSkillInvoke(player, { skill_name = skel.name, prompt = prompt }) then
      event:setCostData(self, {tos = {target} })
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    target:setChainState(true)
    if target == player and not player.dead then
      player:drawCards(3, skel.name)
    end
  end,
})

skel:addEffect(fk.TargetConfirmed, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(skel.name) and target and not target.dead then
      return target.chained and not data.card.is_damage_card and data:isOnlyTarget(target)
    end
  end,
  on_cost = function(self, event, target, player, data)
    local prompt = ""
    if target == player then
      prompt = "#steam__lugong-damageself"
    else
      prompt = "#steam__lugong-damage:"..target.id
    end
    if player.room:askToSkillInvoke(player, { skill_name = skel.name, prompt = prompt }) then
      event:setCostData(self, {tos = {target} })
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    target:setChainState(false)
    room:damage { from = player, to = target, damage = 1, skillName = skel.name }
    if target == player and not player.dead then
      player:drawCards(3, skel.name)
    end
  end,
})

return skel
