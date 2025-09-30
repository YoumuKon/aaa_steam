local skel = fk.CreateSkill {
  name = "steam__qiufeng",
}

Fk:loadTranslationTable{
  ["steam__qiufeng"] = "秋风",
  [":steam__qiufeng"] = "当你使用的伤害牌或普通锦囊牌对唯一目标结算后，若其未被响应，你可以摸一张牌，并视为对本回合未以“秋风”指定过的一名其他角色使用此牌。",
  ["#steam__qiufeng-choose"] = "秋风：选择一名角色，你摸一张牌，并视为对其使用【%arg】",

  ["$steam__qiufeng1"] = "横刀嗤谱牒，唾血向儒宗，青史笑骂皆掷盏。",
  ["$steam__qiufeng2"] = "他年我若为青帝，报与桃花一处开。",
}

skel:addEffect(fk.CardUseFinished, {
  anim_type = "offensive",
  can_trigger = function (self, event, target, player, data)
    if player:hasSkill(skel.name) and target == player and (data.card.is_damage_card or data.card:isCommonTrick()) then
      local tos = data.tos
      if not tos or #tos ~= 1 then return false end
      local room = player.room
      local useEvent = room.logic:getCurrentEvent():findParent(GameEvent.UseCard, true)
      if not useEvent then return false end
      if #useEvent:searchEvents(GameEvent.UseCard, 1, function (e)
        local use = e.data
        local respEvent = use.responseToEvent
        return use.from == tos[1] and respEvent and respEvent.from == player and respEvent.card == data.card
      end) > 0 then return false end
      if #useEvent:searchEvents(GameEvent.RespondCard, 1, function (e)
        local use = e.data
        local respEvent = use.responseToEvent
        return use.from == tos[1] and respEvent and respEvent.from == player and respEvent.card == data.card
      end) > 0 then return false end
      local card = Fk:cloneCard(data.card.name)
      card.skillName = skel.name
      return table.find(room:getOtherPlayers(player, false), function (p)
        return not table.contains(player:getTableMark("steam__qiufengTar-turn"), p.id)
        and player:canUseTo(card, p, {bypass_distances = true, bypass_times = true})
      end) ~= nil
    end
  end,
  on_cost = function (self, event, target, player, data)
    local card = Fk:cloneCard(data.card.name)
    card.skillName = skel.name
    local targets = table.filter(player.room:getOtherPlayers(player, false), function (p)
      return not table.contains(player:getTableMark("steam__qiufengTar-turn"), p.id)
      and player:canUseTo(card, p, {bypass_distances = true, bypass_times = true})
    end)
    local tos = player.room:askToChoosePlayers(player, {
      min_num = 1, max_num = 1 ,targets = targets, skill_name = skel.name,
      prompt = "#steam__qiufeng-choose:::"..data.card.name,
    })
    if #tos > 0 then
      event:setCostData(self, {tos = tos})
      return true
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local to = event:getCostData(self).tos[1]
    room:addTableMark(player, "steam__qiufengTar-turn", to.id)
    player:drawCards(1, skel.name)
    room:useVirtualCard(data.card.name, nil, player, to, skel.name, true)
  end,
})

return skel
