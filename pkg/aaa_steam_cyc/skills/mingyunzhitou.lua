local DIY = require "packages/diy_utility/diy_utility"

local skel = fk.CreateSkill {
  name = "steam__mingyunzhitou",
}

Fk:loadTranslationTable{
  ["steam__mingyunzhitou"] = "命运之掷",
  [":steam__mingyunzhitou"] = "转换技，准备阶段，或你受到伤害时，你可以掷一枚："..
  "<br>①六面骰，令一名角色重铸区域内一张牌，执行投掷点数次。"..
  "<br>②八面骰，令一名角色随机获得任意张牌名字数之和等于投掷点数的牌。"..
  "<br>③二十面骰，令一名角色随机获得任意张点数和等于投掷点数的牌。",

  ["#steam__mingyunzhitou-recast"] = "命运之掷：请重铸1张牌！（第 %arg 次，共 %arg2 次）",
  ["#steam__mingyunzhitou-choose-recast"] = "命运之掷：令一名角色重铸其区域内一张牌，重复%arg次",
  ["#steam__mingyunzhitou-choose-drawname"] = "命运之掷：令一名角色随机获得任意张牌名字数之和为 %arg 的牌",
  ["#steam__mingyunzhitou-choose-drawnum"] = "命运之掷：令一名角色随机获得任意张牌点数之和为 %arg 的牌",
}

--- 丢一个骰子，默认六面
---@param times? integer @ 丢几次，默认1
---@param max? integer @ 最大值，默认6
---@param min? integer @ 最小值，默认1
---@return integer[] @ 骰子结果数组
local rollDice = function (times, max, min)
  max = max or 6
  min = min or 1
  times = times or 1
  local result = {}
  for _ = 1, times do
    table.insert(result, math.random(max - min + 1) + (min - 1))
  end
  local room = RoomInstance
  if room then
    local cids = {}
    for _, num in ipairs(result) do
      local cid = table.find(room.void, function(id) return
        Fk:getCardById(id).name == "dice" and Fk:getCardById(id).number == num and not table.contains(cids, id)
      end)
      if cid == nil then
        cid = room:printCard("dice", Card.Spade, num).id
      end
      table.insert(cids, cid)
      --- FIXME: 从void区移动到处理区的牌不可见，太逆天了
      room:moveCardTo(cid, Card.DrawPile, nil, fk.ReasonJustMove, "", "", true)
      room:moveCardTo(cid, Card.Processing, nil, fk.ReasonJustMove, "", "", true)
      room:delay(700)
    end
    room:delay(300)
    room:moveCardTo(cids, Card.Void, nil, fk.ReasonJustMove, "", "", true)
  end
  return result
end

--- 令一名角色获得牌名字数/点数之和为num的牌
---@param player ServerPlayer
---@param num integer
---@param byName boolean
local dofateDice = function (player, num, byName)
  local room = player.room
  local pile = table.connect(room.draw_pile, room.discard_pile)
  local map = {}
  for _, cid in ipairs(pile) do
    local n = byName and Fk:translate(Fk:getCardById(cid).trueName, "zh_CN"):len() or Fk:getCardById(cid).number
    if n > 0 and n <= num then
      if map[n] == nil then
        map[n] = {cid}
      else
        table.insert(map[n], cid)
      end
    end
  end
  if next(map) == nil then return end
  local keys = {}
  for k in pairs(map) do
    table.insert(keys, k)
  end
  table.sort(keys)
  -- 算法不会整，穷举得了！
  local get = {}
  for _ = 1, 100 do
    local sum, chosenMap = 0, {}
    while sum < num do
      local fit_key = table.filter(keys, function(k) return k <= (num - sum) and #map[k] > (chosenMap[k] or 0) end)
      if #fit_key == 0 then break end
      local k = table.random(fit_key)
      chosenMap[k] = (chosenMap[k] or 0) + 1
      sum = sum + k
    end
    if sum == num then
      for k, v in pairs(chosenMap) do
        table.insertTable(get, table.random(map[k], v))
      end
      break
    end
  end
  if #get > 0 then
    room:obtainCard(player, get, true, fk.ReasonJustMove, player, skel.name)
  end
end

---@param player ServerPlayer
local on_use = function(self, event, target, player, data)
  local room = player.room
  local index = DIY.getSwitchState(player, skel.name)
  if index == 1 then
    local num = rollDice(1, 6)[1]
    if player.dead then return end
    local tos = room:askToChoosePlayers(player, { targets = room.alive_players, min_num = 1, max_num = 1, skill_name = skel.name,
    prompt = "#steam__mingyunzhitou-choose-recast:::"..num, cancelable = false})
    local to = tos[1]
    for i = 1, num do
      if to.dead or to:isAllNude() then break end
      local cards = to:getCardIds("hej")
      if #cards > 1 then
        local prompt = "#steam__mingyunzhitou-recast:::"..i..":"..num
        if #to:getCardIds("j") == 0 then
          cards = room:askToCards(to, { min_num = 1, max_num = 1, include_equip = true,
          skill_name = skel.name, cancelable = false, prompt = prompt})
        else
          cards = { room:askToChooseCard(to, { target = to, flag = "hej", skill_name = skel.name, prompt = prompt}) }
        end
      end
      room:recastCard(cards, to, skel.name)
    end
  elseif index == 2 then
    local num = rollDice(1, 8)[1]
    local tos = room:askToChoosePlayers(player, { targets = room.alive_players, min_num = 1, max_num = 1, skill_name = skel.name,
    prompt = "#steam__mingyunzhitou-choose-drawname:::"..num, cancelable = false})
    local to = tos[1]
    dofateDice (to, num, true)
  elseif index == 3 then
    local dice = rollDice(2, 10)
    local num = dice[1] + dice[2]
    local tos = room:askToChoosePlayers(player, { targets = room.alive_players, min_num = 1, max_num = 1, skill_name = skel.name,
    prompt = "#steam__mingyunzhitou-choose-drawnum:::"..num, cancelable = false})
    local to = tos[1]
    dofateDice (to, num, false)
  end
  if not player.dead then
    DIY.changeSwitchState(player, skel.name)
  end
end

skel:addEffect(fk.EventPhaseStart, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(skel.name) and target == player then
      return player.phase == Player.Start
    end
  end,
  on_use = on_use,
})

skel:addEffect(fk.DamageInflicted, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(skel.name) and target == player then
      return true
    end
  end,
  on_use = on_use,
})

skel:addAcquireEffect(function (self, player, is_start)
  DIY.setSwitchState(player, skel.name, 1, 3)
end)

skel:addLoseEffect(function (self, player, is_death)
  DIY.removeSwitchSkill(player, skel.name)
end)

return skel
