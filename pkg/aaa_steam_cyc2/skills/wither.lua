local skel = fk.CreateSkill {
  name = "steam__wither",
}

Fk:loadTranslationTable{
  ["steam__wither"] = "枯萎",
  [":steam__wither"] = "你造成或受到伤害后，若当前回合角色攻击范围大于0，你可以摸一张牌令之-1直到本回合结束。",

  ["#steam__wither-invoke"] = "枯萎：是否摸一张牌，令 %dest 本回合攻击范围-1？",

  ["$steam__wither1"] = "枯萎！",
  ["$steam__wither2"] = "软弱无力！",
}

local spec = {
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(skel.name) then
      local current = player.room:getCurrent()
      if current and not current.dead and current:getAttackRange() > 0 then
        event:setCostData(self, { tos = {current} })
        return true
      end
    end
  end,
  on_cost = function (self, event, target, player, data)
    return player.room:askToSkillInvoke(player, { skill_name = skel.name, prompt = "#steam__wither-invoke::"..player.room:getCurrent().id  })
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local to = event:getCostData(self).tos[1]
    room:addPlayerMark(to, "steam__wither-turn", 1)
    player:drawCards(1, skel.name)
  end,
}

skel:addEffect(fk.Damage, {
  anim_type = "control",
  can_trigger = spec.can_trigger,
  on_cost = spec.on_cost,
  on_use = spec.on_use,
})

skel:addEffect(fk.Damaged, {
  anim_type = "masochism",
  can_trigger = spec.can_trigger,
  on_cost = spec.on_cost,
  on_use = spec.on_use,
})

skel:addEffect("atkrange", {
  correct_func = function (self, from, to)
    return - from:getMark("steam__wither-turn")
  end,
})

return skel
