local skel = fk.CreateSkill {
  name = "steam__hezong",
}

Fk:loadTranslationTable{
  ["steam__hezong"] = "合纵",
  [":steam__hezong"] = "锁定技，因“韬略”使用的牌结算后，若目标角色与本回合上一次指定的不同，你令手牌数较多的一方将X张手牌交给你，然后你将等量张牌交给另一方（X为双方手牌数差值的一半，向上取整）。",

  ["@steam__hezong-turn"] = "合纵",
  ["#steam__hezong-givehand"] = "合纵：请将 %arg 张手牌交给 %dest",
  ["#steam__hezong-give"] = "合纵：请将 %arg 张牌交给 %dest",
}

skel:addEffect(fk.CardUseFinished, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(skel.name) and data.extra_data and data.extra_data.steam__hezong_tos
  end,
  on_cost = function (self, event, target, player, data)
    event:setCostData(self, {tos = data.extra_data.steam__hezong_tos})
    return true
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local tos = table.map(data.extra_data.steam__hezong_tos, Util.Id2PlayerMapper)
    local from, to = tos[1], tos[2]
    if from.dead or to.dead then return end
    if to:getHandcardNum() > from:getHandcardNum() then
      from, to = to, from
    end
    local x = (from:getHandcardNum() - to:getHandcardNum() + 1) // 2
    if x == 0 then return end
    if from ~= player then
      local cards = room:askToCards(from, { min_num = x, max_num = x, include_equip = false, skill_name = skel.name,
      cancelable = false, prompt = "#steam__hezong-givehand::"..player.id..":"..x})
      room:obtainCard(player, cards, false, fk.ReasonGive, from, skel.name)
    end
    if player.dead or to.dead or player:isNude() or to == player then return end
    x = math.min(x, #player:getCardIds("he"))
    room:doIndicate(player, {to})
    room:delay(200)
    local cards = room:askToCards(player, { min_num = x, max_num = x, include_equip = true, skill_name = skel.name,
    cancelable = false, prompt = "#steam__hezong-give::"..to.id..":"..x})
    room:obtainCard(to, cards, false, fk.ReasonGive, player, skel.name)
  end,
})

skel:addEffect(fk.CardUseFinished, {
  can_refresh = function(self, event, target, player, data)
    return player:hasSkill(skel.name, true) and table.contains(data.card.skillNames, "steam__taolue")
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    local tos = data.tos
    if tos and #tos > 0 then
      local old = player:getMark("steam__hezong_to-turn")
      local new = tos[1]
      local newId = new.id
      room:setPlayerMark(player, "@steam__hezong-turn", new.general)
      room:setPlayerMark(player, "steam__hezong_to-turn", newId)
      if old ~= 0 and old ~= newId then
        data.extra_data = data.extra_data or {}
        data.extra_data.steam__hezong_tos = {newId, old}
      end
    end
  end,
})

skel:addLoseEffect(function (self, player, is_death)
  player.room:setPlayerMark(player, "@steam__hezong-turn", 0)
end)

return skel
