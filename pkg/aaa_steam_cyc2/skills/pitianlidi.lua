local pitianlidi = fk.CreateSkill{
  name = "steam__pitianlidi",
}

local spec = { ---@type TrigSkelSpec<fun(self: TriggerSkill, event: DamageEvent, target: ServerPlayer, player: ServerPlayer, data: DamageData):any>
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(pitianlidi.name) and not player:isNude()
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local use = room:askToUseVirtualCard(player, {
      name = "floating_thunder",
      skill_name = pitianlidi.name,
      prompt = "#steam__pitianlidi-invoke",
      cancelable = true,
      card_filter = {
        n = 1,
      },
      skip = true,
    })
    if use then
      event:setCostData(self, { anim_type = event == fk.Damage and "offensive" or "masochism", use = use})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local use = event:getCostData(self).use ---@type UseCardDataSpec
    room:useCard(use)
    room:addCardMark(use.card, "steam__pitianlidi-inarea")
  end,
}
pitianlidi:addEffect(fk.Damage, spec)
pitianlidi:addEffect(fk.Damaged, spec)

pitianlidi:addEffect(fk.Damage, {
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(pitianlidi.name) and data.card and data.card.name == "floating_thunder" then
      return #data.card.subcards > 0 and data.card:getMark("steam__pitianlidi-inarea") > 0
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:setCardMark(data.card, "steam__pitianlidi-inarea", 0)
    room:askToUseVirtualCard(player, {
      name = "slash",
      skill_name = pitianlidi.name,
      prompt = "#steam__pitianlidi-slash:::" .. data.card:toLogString(),
      cancelable = false,
      subcards = Card:getIdList(data.card),
    })
  end,
})
pitianlidi:addEffect(fk.Damage, {
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(pitianlidi.name) and data.card and data.card.name == "floating_thunder" and data.card:getMark("steam__pitianlidi-inarea") > 0 then
      local slash = Fk:cloneCard("slash")
      slash:addSubcards(Card:getIdList(data.card))
      slash.skillName = pitianlidi.name
      return slash:getAvailableTargets(player)[1]
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:setCardMark(data.card, "steam__pitianlidi-inarea", 0)
    room:askToUseVirtualCard(player, {
      name = "slash",
      skill_name = pitianlidi.name,
      prompt = "#steam__pitianlidi-slash:::" .. data.damage,
      cancelable = false,
      subcards = Card:getIdList(data.card),
    })
  end,
})
pitianlidi:addEffect(fk.DetermineDamageCaused, {
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(pitianlidi.name) and data.card and data.card.name == "floating_thunder" and data.card:getMark("steam__pitianlidi-inarea") > 0 then
      return player.room:getOtherPlayers(player, false)[1]
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local liuli = room:askToChoosePlayers(player, {
      targets = room:getOtherPlayers(player, false),
      min_num = 1,
      max_num = 1,
      skill_name = pitianlidi.name,
      prompt = "#steam__pitianlidi-liuli:::" .. data.damage,
      cancelable = false,
    })[1]
    if liuli then
      local damage = data.damage
      data:preventDamage()
      room:damage{
        from = data.from,
        to = liuli,
        damage = damage,
        damageType = data.damageType,
        skillName = data.skillName,
        chain = data.chain,
        card = data.card,
      }
    end
  end
})

Fk:loadTranslationTable{
  ["steam__pitianlidi"] = "劈天雳地",
  [":steam__pitianlidi"] = "当你造成或受到伤害后，你可以将一张牌当【浮雷】使用，此牌：造成伤害后，你将之当【杀】使用；对你造成伤害时，你转移之。",

  ["#steam__pitianlidi-invoke"] = "劈天雳地：你可以将一张牌当【浮雷】使用，此牌造成伤害后，你将之当【杀】使用",
  ["#steam__pitianlidi-slash"] = "劈天雳地：你可以将 %arg 当【杀】使用",
  ["#steam__pitianlidi-liuli"] = "劈天雳地：请将 %arg 点伤害转移给一名其他角色",
}

return pitianlidi
