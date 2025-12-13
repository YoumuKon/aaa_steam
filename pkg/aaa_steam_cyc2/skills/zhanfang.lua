local skel = fk.CreateSkill {
  name = "steam__zhanfang",
}

Fk:loadTranslationTable{
  ["steam__zhanfang"] = "绽放",
  [":steam__zhanfang"] = "轮次结束时，你可以视为使用一张本轮因〖幻魅〗转化过的牌，你可以改为视为使用本轮所有转化过的牌各一张，然后失去本技能。",

  ["#steam__zhanfang-invoke"] = "绽放：是否继续使用一张牌？继续使用则失去本技能，且后续强制使用剩余牌名。",
  ["@$steam__zhanfang-round"] = "绽放",

  ["$steam__zhanfang1"] = " ",
  ["$steam__zhanfang2"] = " ",
}

skel:addEffect(fk.RoundEnd, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(skel.name) and table.find(player:getTableMark("@$steam__zhanfang-round"), function (str) 
    return #Fk:cloneCard(str):getDefaultTarget(player, {bypass_times = true}) > 0 end) 
  end,
  on_cost = function(self, event, target, player, data)
    local use = player.room:askToUseVirtualCard(player, {
      name = player:getTableMark("@$steam__zhanfang-round"),
      skill_name = skel.name,
      skip = true,
      cancelable = true,
      extra_data = {
        bypass_times = true,
        extraUse = true,
      },
    })
    if use then
      use.extraUse = true
      event:setCostData(self, {extra_data = use})
      return true
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local list = {}
    for _, str in ipairs(player:getTableMark("@$steam__zhanfang-round")) do
      table.insertIfNeed(list, str)
    end
    table.removeOne(list, event:getCostData(self).extra_data.card.trueName)
    room:useCard(event:getCostData(self).extra_data)
    if player.dead or not table.find(list, function (str) 
      return #Fk:cloneCard(str):getDefaultTarget(player, {bypass_times = true}) > 0 end) then return end
    local continue = false
    local use = room:askToUseVirtualCard(player, {
      name = list,
      skill_name = skel.name,
      prompt = "#steam__zhanfang-invoke2",
      cancelable = true,
      extra_data = {
        bypass_times = true,
        extraUse = true,
      },
    })
    if use then
      table.removeOne(list, use.card.trueName)
      continue = true
    end
    while continue and not player.dead do
      if not table.find(list, function (str) 
        return #Fk:cloneCard(str):getDefaultTarget(player, {bypass_times = true}) > 0 end) then break end
      local uses = room:askToUseVirtualCard(player, {
        name = list,
        skill_name = skel.name,
        cancelable = false,
        extra_data = {
          bypass_times = true,
          extraUse = true,
        },
      })
      if uses then
        table.removeOne(list, uses.card.trueName)
      end
    end
    if continue then
      room:handleAddLoseSkills(player, "-"..skel.name)
    end
  end,
})

skel:addEffect(fk.PreCardUse, {
  can_refresh = function (self, event, target, player, data)
    return player:hasSkill(skel.name, true) and #Card:getIdList(data.card) == 1 and not data.card:isConverted() and
    Fk:getCardById(Card:getIdList(data.card)[1], true):getMark("@@steam__huanmei") > 0
  end,
  on_refresh = function (self, event, target, player, data)
    player.room:addTableMarkIfNeed(player, "@$steam__zhanfang-round", data.card.trueName)
  end
})

skel:addLoseEffect(function (self, player, is_death)
  player.room:setPlayerMark(player, "@$steam__zhanfang-round", 0)
end)

return skel
