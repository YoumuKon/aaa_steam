local DIY = require "packages.diy_utility.diy_utility"

local skel = fk.CreateSkill {
  name = "steam__huanfua",
  tags = {DIY.ReadySkill},
}

Fk:loadTranslationTable{
  ["steam__huanfua"] = "宦浮",
  [":steam__huanfua"] = "蓄势技，出牌阶段，你可以弃置任意张牌，视为对等量名角色使用一张冰【杀】，若目标均受到或均未受到伤害，你摸两张牌。每当你受到1点伤害后，蓄势进度+1。",

  ["#steam__huanfua"] = "宦浮：弃置任意张牌，视为对任意名角色使用冰【杀】",

  ["$steam__huanfua1"] = "",
  ["$steam__huanfua2"] = "",
}

skel:addEffect("active", {
  anim_type = "big",
  prompt = "#steam__huanfua",
  card_filter = function (self, player, to_select, selected)
    return not player:prohibitDiscard(to_select)
  end,
  target_filter = function (self, player, to_select, selected, cards)
    local slash = Fk:cloneCard("ice__slash")
    slash.skillName = skel.name
    return not player:isProhibited(to_select, slash) and #selected < #cards
  end,
  feasible = function (self, player, selected, cards)
    return #selected > 0 and #selected == #cards
  end,
  on_use = function (self, room, effect)
    local player, tos, cards = effect.from, effect.tos, effect.cards
    room:throwCard(cards, skel.name, player, player)
    local slash = Fk:cloneCard("ice__slash")
    slash.skillName = skel.name
    room:sortByAction(tos)
    local use = {
      from = player, tos = tos, card = slash, extraUse = true,
    }
    room:useCard(use)
    if player.dead then return end
    if use.damageDealt then
      local damaged = table.filter(tos, function (p)
        return use.damageDealt[p] ~= nil
      end)
      if #damaged ~= #tos then return end
    end
    player:drawCards(2, skel.name)
  end,
  can_use = function (self, player)
    local slash = Fk:cloneCard("ice__slash")
    slash.skillName = skel.name
    return player:canUse(slash)
  end,
})

skel:addEffect(fk.Damaged, {
  is_delay_effect = true,
  mute = true,
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(skel.name, true) and DIY.isReadying(player, skel.name)
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    DIY.changeReadyProgress(player, skel.name, data.damage, skel.name)
  end,
})

return skel
