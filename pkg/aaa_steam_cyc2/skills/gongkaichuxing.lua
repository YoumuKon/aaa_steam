local skel = fk.CreateSkill {
  name = "steam__gongkaichuxing",
}

Fk:loadTranslationTable{
  ["steam__gongkaichuxing"] = "公开处刑",
  [":steam__gongkaichuxing"] = "出牌阶段限一次，你可以将一张非基本牌当【逐近弃远】对攻击范围边缘的一名角色使用。",

  ["#steam__gongkaichuxing"] = "公开处刑：将一张非基本牌当【逐近弃远】对攻击范围边缘的一名角色使用",

  ["$steam__gongkaichuxing1"] = "血流成河！",
  ["$steam__gongkaichuxing2"] = "我亲自动手！",
}

--- 获取攻击范围边缘的角色
---@param player Player
local getAttackRangeEdgePlayers = function (player)
  local room = Fk:currentRoom()
  local maxStep, i = 0, 0
  local temp = player
  local map = {}
  repeat
    i = i + 1
    temp = temp.next
    if player:inMyAttackRange(temp) then
      local step = math.min(i, (#room.alive_players - i)) -- 我到该角色的最近距离
      maxStep = math.max(maxStep, step)
      map[step] = map[step] or {}
      table.insert(map[step], temp)
    end
  until temp == player
  return map[maxStep] or {}
end

skel:addEffect("active", {
  anim_type = "offensive",
  prompt = "#steam__gongkaichuxing",
  card_num = 1,
  target_num = 1,
  card_filter = function (self, player, to_select, selected)
    return #selected == 0 and Fk:getCardById(to_select).type ~= Card.TypeBasic
  end,
  target_filter = function (self, player, to, selected, selected_cards)
    if #selected ~= 0 or #selected_cards ~= 1 or to == player then return false end
    local card = Fk:cloneCard("chasing_near")
    card:addSubcard(selected_cards[1])
    card.skillName = skel.name
    return table.contains(getAttackRangeEdgePlayers(player), to) and player:canUseTo(card, to)
  end,
  times = function (self, player)
    return 1 - player:usedSkillTimes(skel.name, Player.HistoryPhase)
  end,
  can_use = function(self, player)
    return player:usedSkillTimes(skel.name, Player.HistoryPhase) == 0
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local to = effect.tos[1]
    room:useVirtualCard("chasing_near", effect.cards, player, to, skel.name)
  end,
})

return skel
