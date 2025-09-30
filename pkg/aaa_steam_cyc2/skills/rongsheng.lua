local skel = fk.CreateSkill {
  name = "steam__rongsheng",
}

Fk:loadTranslationTable{
  ["steam__rongsheng"] = "荣生",
  [":steam__rongsheng"] = "当你受到1点伤害后，可以令一名拥有〖荣生〗的角色摸一张牌。每回合限一次，其他拥有〖荣生〗的角色受到伤害时，你可以防止之并受到同来源的等量普通伤害。",

  ["#steam__rongsheng-draw"] = "荣生：可以令一名拥有〖荣生〗的角色摸一张牌",
  ["#steam__rongsheng-ask"] = "荣生：你可以代替 %dest 受到 %arg 点伤害！",

  ["$steam__rongsheng1"] = "海克斯核心是人类通往荣光的桥梁。",
  ["$steam__rongsheng2"] = "海克斯核心包容万象——包括你的力量。",
}

skel:addEffect(fk.DamageInflicted, {
  anim_type = "support",
  times = function (self, player)
    return 1 - player:usedEffectTimes(self.name)
  end,
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(skel.name) then return false end
    return target ~= player and target:hasSkill(skel.name, true) and not target.dead
    and player:usedEffectTimes(self.name) == 0
  end,
  on_cost = function(self, event, target, player, data)
    if player.room:askToSkillInvoke(player, { skill_name = skel.name, prompt = "#steam__rongsheng-ask::"..target.id..":"..data.damage}) then
      event:setCostData(self, {tos = target})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local num = data.damage
    data:preventDamage()
    room:damage { from = data.from, to = player, damage = num, skillName = skel.name }
  end,
})

skel:addEffect(fk.Damaged, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(skel.name)
  end,
  trigger_times = function (self, event, target, player, data)
    return data.damage
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = table.filter(room.alive_players, function (p) return p:hasSkill(skel.name, true) end)
    local tos = room:askToChoosePlayers(player, { targets = targets, min_num = 1, max_num =1,
     prompt = "#steam__rongsheng-draw", skill_name = skel.name })
    if #tos > 0 then
      event:setCostData(self, {tos = tos})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local to = event:getCostData(self).tos[1]
    to:drawCards(1, skel.name)
  end,
})

return skel
