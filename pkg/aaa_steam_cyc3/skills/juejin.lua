local skel = fk.CreateSkill {
  name = "steam__juejin",
  tags = {Skill.Quest},
}

Fk:loadTranslationTable{
  ["steam__juejin"] = "决尽",
  [":steam__juejin"] = "使命技，你可以将任意张牌当无视距离的刺【杀】使用，此牌造成伤害后，你随机获得等量张装备牌并可以使用。"..
  "<br>成功：你杀死一名角色后，视为对自己使用一张伤害致命的【水淹七军】。",

  ["#steam__juejin"] = "决尽：将任意张牌当无视距离的刺【杀】使用",
  ["#steam__juejin-equip"] = "决尽：你可以使用获得的装备牌",
  ["#steam__juejin_delay"] = "决尽",
  ["#steam__juejin_quest"] = "决尽",

  ["$steam__juejin1"] = "嘎啦嘛吐咩！",
  ["$steam__juejin2"] = "那西喏哦那西喏",
  ["$steam__juejin3"] = "撒露娜撒拉开",
  ["$steam__juejin4"] = "卡萨！",
  ["$steam__juejin5"] = "卡萨——",
}

skel:addEffect("viewas", {
  anim_type = "offensive",
  pattern = "slash",
  prompt = "#steam__juejin",
  card_filter = Util.TrueFunc,
  view_as = function (self, player, cards)
    if #cards == 0 then return nil end
    local c = Fk:cloneCard("stab__slash")
    c.skillName = skel.name
    c:addSubcards(cards)
    return c
  end,
  enabled_at_play = function(self, player)
    return player:getQuestSkillState(skel.name) == nil
  end,
  enabled_at_response = function (self, player, response)
    return not response and player:getQuestSkillState(skel.name) == nil
  end,
})

skel:addEffect("targetmod", {
  bypass_distances = function(self, player, skill, card, to)
    return card and table.contains(card.skillNames, skel.name)
  end,
})

skel:addEffect(fk.Damage, {
  is_delay_effect = true,
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(skel.name) and data.card and table.contains(data.card.skillNames, skel.name)
    and #data.card.subcards > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke(skel.name)
    local ids = room:getCardsFromPileByRule(".|.|.|.|.|equip", #data.card.subcards, "allPiles")
    if #ids == 0 then return false end
    room:obtainCard(player, ids, true, fk.ReasonJustMove, player, skel.name)
    while player:isAlive() do
      ids = table.filter(ids, function(id) return table.contains(player.player_cards[Player.Hand], id) end)
      player:filterHandcards()
      local equips = table.filter(ids, function(id) return Fk:getCardById(id).type == Card.TypeEquip end)
      if #equips == 0 then break end
      local use = room:askToUseRealCard(player, {
        pattern = equips, skill_name = skel.name, cancelable = true, prompt = "#steam__juejin-equip", skip = false,
      })
      if not use then break end
    end
  end,
})


skel:addEffect(fk.Deathed, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(skel.name) and data.killer == player
    and player:getQuestSkillState(skel.name) == nil
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke(skel.name)
    room:notifySkillInvoked(player, skel.name, "big")
    room:updateQuestSkillState(player, skel.name, false)
    local card = Fk:cloneCard("drowning")
    card.skillName = skel.name
    room:useCard{from = player, tos = {player}, card = card}
  end,
})

skel:addEffect(fk.DamageCaused, {
  can_refresh = function(self, event, target, player, data)
    return player == data.to and data.card and table.contains(data.card.skillNames, skel.name)
    and data.card.name == "drowning"
  end,
  on_refresh = function (self, event, target, player, data)
    local n = player.hp + player.shield - data.damage
    if n > 0 then
      data:changeDamage(n)
    end
  end,
})


return skel
