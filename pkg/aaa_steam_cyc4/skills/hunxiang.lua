local hunxiang = fk.CreateSkill {
  name = "steam__hunxiang",
}

Fk:loadTranslationTable{
  ["steam__hunxiang"] = "魂响",
  [":steam__hunxiang"] = "每回合限一次，当你造成或受到伤害后，可以观看对方手牌并将其中随机一张标记为「死士」。" ..
  "当「死士」牌被其使用时，你令此牌无效；其回合结束时，若「死士」牌在牌堆、弃牌堆或任意角色的区域内，你获得之。",

  ["#steam__hunxiang-invoke"] = "魂响：你可以观看 %dest 的手牌，将其中一张牌标记为“死士”",
  ["#CardNullifiedBySkill"] = "由于 %arg 的效果，%from 使用的 %arg2 无效",

  ["$steam__hunxiang1"] = "指尖轻轻一触，意志就会溃散如泥。",
  ["$steam__hunxiang2"] = "我接受你的邀请。",
}

hunxiang:addEffect(fk.Damage, {
  anim_type = "control",
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(hunxiang.name) and
      not data.to:isKongcheng() and player:usedSkillTimes(hunxiang.name, Player.HistoryTurn) == 0
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    if room:askToSkillInvoke(player, {
      skill_name = hunxiang.name,
      prompt = "#steam__hunxiang-invoke::"..data.to.id,
    }) then
      event:setCostData(self, {tos = {data.to}})
      return true
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    room:viewCards(player, { cards = data.to:getCardIds("h"), skill_name = hunxiang.name, prompt = "$ViewCardsFrom:"..data.to.id })
    local cid = table.random(data.to:getCardIds("h"), 1)[1]
    --[[local cid = room:askToChooseCard(player, {
      target = data.to,
      flag = { card_data = { { "$Hand", data.to:getCardIds("h") } } },
      skill_name = hunxiang.name
    })]]
    room:setCardMark(Fk:getCardById(cid), "_steam__hunxiang", { data.to.id, player.id })
    room:addTableMarkIfNeed(data.to, "_steam__hunxiang_now-" .. tostring(player.id), cid)
    room:addTableMarkIfNeed(player, "_steam__hunxiang", data.to.id)
  end,
})

hunxiang:addEffect(fk.Damaged, {
  anim_type = "masochism",
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(hunxiang.name) and
      data.from and not data.from:isKongcheng() and player:usedSkillTimes(hunxiang.name, Player.HistoryTurn) == 0
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    if room:askToSkillInvoke(player, {
      skill_name = hunxiang.name,
      prompt = "#steam__hunxiang-invoke::"..data.from.id,
    }) then
      event:setCostData(self, {tos = {data.from}})
      return true
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    room:viewCards(player, { cards = data.from:getCardIds("h"), skill_name = hunxiang.name, prompt = "$ViewCardsFrom:"..data.from.id })
    local cid = table.random(data.from:getCardIds("h"), 1)[1]
    --[[local cid = room:askToChooseCard(player, {
      target = data.from,
      flag = { card_data = { { "$Hand", data.from:getCardIds("h") } } },
      skill_name = hunxiang.name
    })]]
    room:setCardMark(Fk:getCardById(cid), "_steam__hunxiang", { data.from.id, player.id })
    room:addTableMarkIfNeed(data.from, "_steam__hunxiang_now-" .. tostring(player.id), cid)
    room:addTableMarkIfNeed(player, "_steam__hunxiang", data.from.id)
  end,
})

hunxiang:addEffect(fk.CardUsing, {
  is_delay_effect = true,
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    local mark
    for _, id in ipairs(Card:getIdList(data.card)) do
      if Fk:getCardById(id):getMark("_steam__hunxiang") ~= 0 then
        if not mark then
          mark = Fk:getCardById(id):getMark("_steam__hunxiang")
        elseif mark ~= Fk:getCardById(id):getMark("_steam__hunxiang") then
          return false
        end
      else
        return false
      end
    end
    return mark and mark[1] == target.id and mark[2] == player.id
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:doIndicate(player, { target })
    data.toCard = nil
    data:removeAllTargets()
    room:sendLog{
      type = "#CardNullifiedBySkill",
      from = player.id,
      arg = hunxiang.name,
      arg2 = data.card:toLogString(),
    }
  end,
})

hunxiang:addEffect(fk.TurnEnd, {
  is_delay_effect = true,
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    if target:getMark("_steam__hunxiang_now-" .. player.id) ~= 0 and player:isAlive() then
      for _, id in ipairs(target:getMark("_steam__hunxiang_now-" .. player.id)) do
        if table.contains({
          Card.DrawPile,
          Card.DiscardPile,
          Card.PlayerHand,
          Card.PlayerEquip,
          Card.PlayerJudge,
        }, player.room:getCardArea(id))
        then
          return true
        end
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cards = {}
    local mark = target:getMark("_steam__hunxiang_now-" .. player.id)
    for i = #mark, 1, -1 do
      local id = mark[i]
      if table.contains({
        Card.DrawPile,
        Card.DiscardPile,
        Card.PlayerHand,
        Card.PlayerEquip,
        Card.PlayerJudge,
      }, player.room:getCardArea(id))
        then
        table.remove(mark, i)
        room:setCardMark(Fk:getCardById(id), "_steam__hunxiang", 0)
        table.insert(cards, id)
      end
    end
    room:setPlayerMark(target, "_steam__hunxiang_now-" .. player.id, mark)
    room:obtainCard(player, cards, true, fk.ReasonPrey, player, hunxiang.name)
  end,
})

return hunxiang
