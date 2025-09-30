local skel = fk.CreateSkill {
  name = "steam__kunshou",
}

Fk:loadTranslationTable{
  ["steam__kunshou"] = "困守",
  [":steam__kunshou"] = "出牌阶段，你手牌数不因此变为唯一极值时，你可以失去1点体力并调整手牌数至体力上限，然后你使用的下一张牌不计入次数。",
  ["@@steam__kunshou"] = "困守:不计次数",
}

skel:addEffect(fk.AfterCardsMove, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(skel.name) and player.phase == Player.Play and player.hp > 0 and
     player:getHandcardNum() ~= player.maxHp and data.extra_data then
      for _, move in ipairs(data) do
        if move.skillName == skel.name then
          return false
        end
      end
      return data.extra_data.diy_hand_becomeOnlyMax == player or
      data.extra_data.diy_hand_becomeOnlyMin == player
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    room:loseHp(player, 1, skel.name)
    if player.dead then return end
    local x = player:getHandcardNum() - player.maxHp
    if x > 0 then
      room:askToDiscard(player, {min_num = x, max_num = x, include_equip = false, skill_name = skel.name, cancelable = false})
    elseif x < 0 then
      player:drawCards(-x, skel.name)
    end
    if not player.dead then
      room:setPlayerMark(player, "@@steam__kunshou", 1)
    end
  end,
})

skel:addEffect(fk.PreCardUse, {
  can_refresh = function(self, event, target, player, data)
    return target == player and player:getMark("@@steam__kunshou") ~= 0
  end,
  on_refresh = function(self, event, target, player, data)
    data.extraUse = true
    player.room:setPlayerMark(player, "@@steam__kunshou", 0)
  end,
})

skel:addEffect("targetmod", {
  bypass_times = function(self, player, skill, scope, card, to)
    return card and player:getMark("@@steam__kunshou") ~= 0
  end,
})

skel:addLoseEffect(function (self, player, is_death)
  player.room:setPlayerMark(player, "@@steam__kunshou", 0)
end)

-- 手牌极值检测器
skel:addEffect(fk.AfterCardsMove, {
  can_refresh = function (self, event, target, player, data)
    if player.seat ~= 1 then return false end
    for _, move in ipairs(data) do
      if move.toArea == Player.Hand then return true end
      for _, info in ipairs(move.moveInfo) do
        if info.fromArea == Player.Hand then
          return true
        end
      end
    end
  end,
  on_refresh = function (self, event, target, player, data)
    local room = player.room
    local newMax, newMin = {}, {}
    local minNum, maxNum = 9999, 0

    -- 手牌极值判断
    for _, p in ipairs(room.alive_players) do
      minNum = math.min(minNum, p:getHandcardNum())
      maxNum = math.max(maxNum, p:getHandcardNum())
    end
    for _, p in ipairs(room.alive_players) do
      if p:getHandcardNum() == minNum then
        table.insert(newMin, p)
      end
      if p:getHandcardNum() == maxNum then
        table.insert(newMax, p)
      end
    end
    room:setTag("diy_hand_max", newMax)
    room:setTag("diy_hand_min", newMin)
    local onlyMax, onlyMin = room:getTag("diy_hand_onlyMax"), room:getTag("diy_hand_onlyMin")
    local newOnlyMax = #newMax == 1 and newMax[1] or nil
    local newOnlyMin = #newMin == 1 and newMin[1] or nil
    room:setTag("diy_hand_onlyMax", newOnlyMax)
    room:setTag("diy_hand_onlyMin", newOnlyMin)

    -- 向MoveCardsData注入信息
    data.extra_data = data.extra_data or {}
    if newOnlyMax ~= onlyMax then
      data.extra_data.diy_hand_becomeOnlyMax = newOnlyMax
    end
    if newOnlyMin ~= onlyMin then
      data.extra_data.diy_hand_becomeOnlyMin = newOnlyMin
    end
  end
})

return skel
