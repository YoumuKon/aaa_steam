local DIY = require "packages/diy_utility/diy_utility"

local skel = fk.CreateSkill {
  name = "steam__zhuiyue",
}

Fk:loadTranslationTable{
  ["steam__zhuiyue"] = "追月",
  [":steam__zhuiyue"] = "转换技，你可以将一张牌当①【酒】②【火攻】③火【杀】使用，并横置此牌的目标；一名角色重置后，你以其为目标的下一张牌无距离、次数限制。",

  ["#steam__zhuiyue"] = "追月：你可以将一张牌当【%arg】使用，并横置此牌目标",

  ["$steam__zhuiyue1"] = "就用你的性命，一雪前耻。",
  ["$steam__zhuiyue2"] = "雪耻旧恨，今日清算。",
}

skel:addAcquireEffect(function (self, player, is_start)
  DIY.setSwitchState(player, self.name, 1, 3)
end)

skel:addLoseEffect(function (self, player, is_death)
  DIY.removeSwitchSkill(player, self.name)
end)

skel:addEffect("viewas", {
  anim_type = "offensive",
  pattern = ".|.|.|.|analeptic,fire_attack,fire__slash",
  prompt = function (self, player)
    local names = {"analeptic", "fire_attack", "fire__slash"}
    local index = DIY.getSwitchState(player, skel.name)
    return "#steam__zhuiyue:::"..names[index]
  end,
  handly_pile = true,
  card_filter = function (self, _, _, selected)
    return #selected == 0
  end,
  view_as = function(self, player, cards)
    if #cards ~= 1 then return end
    local names = {"analeptic", "fire_attack", "fire__slash"}
    local index = DIY.getSwitchState(player, self.name)
    local card = Fk:cloneCard(names[index])
    card.skillName = self.name
    card:addSubcard(cards[1])
    return card
  end,
  before_use = function (self, player, use)
    DIY.changeSwitchState(player, self.name)
  end,
  enabled_at_response = function (self, player, response)
    if response then return end
    local names = {"analeptic", "fire_attack", "fire__slash"}
    local index = DIY.getSwitchState(player, self.name)
    local card = Fk:cloneCard(names[index])
    card.skillName = self.name
    return (Fk.currentResponsePattern == nil and player:canUse(card)) or
      (Fk.currentResponsePattern and Exppattern:Parse(Fk.currentResponsePattern):match(card))
  end,
})

skel:addEffect(fk.CardUsing, {
  is_delay_effect = true,
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and table.contains(data.card.skillNames, skel.name) and data.tos
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    for _, p in ipairs(data.tos) do
      if not p.dead and not p.chained then
        p:setChainState(true)
      end
    end
  end,
})

skel:addEffect(fk.AfterCardTargetDeclared, {
  can_refresh = function(self, event, target, player, data)
    return target == player and data.tos and
      table.find(data.tos, function (p)
        return table.contains(player:getTableMark("steam__zhuiyue"), p.id)
      end)
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    local toIds = table.map(data.tos, Util.IdMapper)
    local mark = player:getTableMark("steam__zhuiyue")
    for i = #mark, 1, -1 do
      if table.contains(toIds, mark[i]) then
        table.remove(mark, i)
      end
    end
    room:setPlayerMark(player, "steam__zhuiyue", mark)
    if not data.extraUse then
      player:addCardUseHistory(data.card.trueName, -1)
      data.extraUse = true
    end
  end,
})

skel:addEffect(fk.ChainStateChanged, {
  can_refresh = function(self, event, target, player, data)
    return player:hasSkill(skel.name) and not target.chained and not target.dead
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:addTableMarkIfNeed(player, "steam__zhuiyue", target.id)
  end,
})

skel:addEffect("targetmod", {
  bypass_distances = function (self, player, skill, card, to)
    return card and to and table.contains(player:getTableMark("steam__zhuiyue"), to.id)
  end,
  bypass_times = function (self, player, skill, scope, card, to)
    return card and to and table.contains(player:getTableMark("steam__zhuiyue"), to.id)
  end,
})


return skel
