local skel = fk.CreateSkill {
  name = "steam__dinghan",
}

Fk:loadTranslationTable{
  ["steam__dinghan"] = "定汉",
  [":steam__dinghan"] = "当你成为其他角色使用锦囊牌的目标时，若此牌牌名未被记录，则记录之并取消此目标；回合开始时，你可以移除或随机增加一种锦囊牌的牌名记录。",

  ["@$steam__dinghan"] = "定汉",
  ["steam__dinghan_addRecord"] = "随机增加牌名",
  ["steam__dinghan_removeRecord"] = "移除牌名",

  ["$steam__dinghan1"] = "杀身有地，报国有时。",
  ["$steam__dinghan2"] = "益国之事，虽死弗避。",
}

skel:addEffect(fk.TargetConfirming, {
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    if target ~= player or not player:hasSkill(skel.name) then
      return false
    end

    return data.from ~= player and
      data.card.type == Card.TypeTrick and
      data.card.trueName ~= "raid_and_frontal_attack" and
      not table.contains(player:getTableMark("@$steam__dinghan"), data.card.trueName)
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    player.room:addTableMark(player, "@$steam__dinghan", data.card.trueName)
    data:cancelCurrentTarget()
  end,
})

skel:addEffect(fk.TurnStart, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(skel.name)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room

    local dinghanRecord = player:getTableMark("@$steam__dinghan")
    local allTricksName = {}
    for _, id in ipairs(Fk:getAllCardIds()) do
      local card = Fk:getCardById(id)
      if card.type == Card.TypeTrick and not card.is_derived and not table.contains(dinghanRecord, card.trueName) then
        table.insertIfNeed(allTricksName, card.trueName)
      end
    end

    local choices, cardName = {"Cancel"}, nil
    if #allTricksName > 0 then
      table.insert(choices, 1, "steam__dinghan_addRecord")
    end
    if #dinghanRecord > 0 then
      table.insert(choices, 2, "steam__dinghan_removeRecord")
    end
    local choice = room:askToChoice(player, { choices = choices, skill_name = skel.name})

    if choice == "Cancel" then return false end
    if choice == "steam__dinghan_addRecord" then
      cardName = table.random(allTricksName)
    else
      cardName = room:askToChoice(player, { choices = dinghanRecord, skill_name = skel.name})
    end
    event:setCostData(self, { choice = choice, cardName = cardName })
    return true
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local costData = event:getCostData(self)
    if costData.choice == "steam__dinghan_addRecord" then
      room:addTableMark(player, "@$steam__dinghan", costData.cardName)
    else
      room:removeTableMark(player, "@$steam__dinghan", costData.cardName)
    end
  end,
})

return skel
