
local DIY = require "packages.diy_utility.diy_utility"

local skel = fk.CreateSkill {
  name = "steam__beici",
  tags = {DIY.ReadySkill},
}

Fk:loadTranslationTable{
  ["steam__beici"] = "背刺",
  [":steam__beici"] = "蓄势技，你可以视为使用一张无视距离、防具的刺【杀】，且造成伤害后你摸两张牌。若目标背面向上，则伤害+1，且其因此死亡后，你执行一次主公误杀忠臣的惩罚。",

  ["#steam__beici"] = "背刺：视为使用无视距离、防具的刺【杀】，造成伤害摸2张，对背面朝上角色致命",

  ["$steam__beici"] = "我的双刀，渴了！",
}

skel:addEffect("viewas", {
  anim_type = "offensive",
  pattern = "slash",
  prompt = "#steam__beici",
  card_filter = Util.FalseFunc,
  view_as = function(self)
    local c = Fk:cloneCard("stab__slash")
    c.skillName = skel.name
    return c
  end,
  before_use = function(self, player, use)
    use.extra_data = use.extra_data or {}
    use.extra_data.steam__beici_from = player.id
  end,
  enabled_at_play = function(self, player)
    return true
  end,
  enabled_at_response = function (self, player, response)
    return not response
  end,
})

skel:addEffect("targetmod", {
  bypass_distances = function(self, player, skill, card)
    return card and table.contains(card.skillNames, skel.name)
  end,
})

skel:addEffect(fk.TargetSpecified, {
  mute = true,
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and table.contains(data.card.skillNames, skel.name)
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    data.to:addQinggangTag(data)
  end,
})

skel:addEffect(fk.Damage, {
  mute = true,
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    local effectEvent = player.room.logic:getCurrentEvent():findParent(GameEvent.CardEffect)
    if not player.dead and effectEvent then
      local use = effectEvent.data
      return use.card == data.card and use.extra_data and use.extra_data.steam__beici_from == player.id
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    player:drawCards(2, skel.name)
  end,
})

skel:addEffect(fk.DamageCaused, {
  mute = true,
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    local effectEvent = player.room.logic:getCurrentEvent():findParent(GameEvent.CardEffect)
    if effectEvent then
      local use = effectEvent.data
      return use.card == data.card and use.extra_data and use.extra_data.steam__beici_from == player.id
      and not data.to.faceup
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    data:changeDamage(1)
    data.extra_data = data.extra_data or {}
    data.extra_data.steam__beici_killer = player
  end,
})

skel:addEffect(fk.Death, {
  mute = true,
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    local damage = data.damage
    return damage and damage.extra_data and damage.extra_data.steam__beici_killer == player
    and data.killer == player
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    player:throwAllCards("he", skel.name)
  end,
})


return skel
