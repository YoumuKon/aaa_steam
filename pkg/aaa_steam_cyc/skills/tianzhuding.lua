local skel = fk.CreateSkill {
  name = "steam__tianzhuding",
  tags = {Skill.Compulsory},
  dynamic_desc = function (self, player, lang)
    local mark = player:getMark("@steam__tianzhuding")
    if mark ~= 0 then
      return "steam__tianzhuding_dyn:" .. mark:gsub(",", ":")
    end
  end,
}

Fk:loadTranslationTable{
  ["steam__tianzhuding"] = "天注定",
  [":steam__tianzhuding"] = "锁定技，游戏开始时，你抽取五个1-4之间的随机数，然后你选择其中一个值赋予以下一项，然后其余数值随机分配给剩余项：体力上限、摸牌阶段额定摸牌数、每轮首次受到伤害后的摸牌数、初始攻击范围、手牌上限加值。",

  [":steam__tianzhuding_dyn"] = "锁定技，游戏开始时，你抽取五个1-4之间的随机数，然后你选择其中一个值赋予以下一项，然后其余数值随机分配给剩余项：体力上限、摸牌阶段额定摸牌数({1})、每轮首次受到伤害后的摸牌数({2})、初始攻击范围({3})、手牌上限加值({4})。",


  ["@steam__tianzhuding"] = "天注定",
  ["steam__tianzhuding1"] = "体力上限",
  ["steam__tianzhuding2"] = "额定摸牌数",
  ["steam__tianzhuding3"] = "受伤摸牌数",
  ["steam__tianzhuding4"] = "攻击范围初值",
  ["steam__tianzhuding5"] = "手牌上限加值",
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

skel:addEffect(fk.GameStart, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(skel.name)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local list = rollDice(5, 4)
    local choice_num = tonumber(room:askToChoice(player, { choices = table.map(list, function(n) return tostring(n) end), skill_name = skel.name}))
    table.removeOne(list, choice_num)
    local options, chosen = {}, {}
    for i = 1, 5 do
      table.insert(options, "steam__tianzhuding".. i)
    end
    local choice_option = room:askToChoice(player, {choices = options, skill_name = skel.name})
    chosen[tonumber(choice_option:sub(-1, -1))] = choice_num

    for i = 1, 5 do
      if chosen[i] == nil then
        local rand = table.remove(list, math.random(1, #list))
        chosen[i] = rand
      end
    end
    local maxHp = table.remove(chosen, 1)
    room:setPlayerMark(player, "@steam__tianzhuding", table.concat(chosen, ","))
    room:changeMaxHp(player, maxHp - player.maxHp)
  end,
})

skel:addEffect(fk.Damaged, {
  anim_type = "masochism",
  can_trigger = function(self, event, target, player, data)
    if player == target and player:getMark("@steam__tianzhuding") ~= 0 then
      return player:getMark("steam__tianzhuding_draw-round") == 0
    end
  end,
  on_use = function(self, event, target, player, data)
    local split = player:getMark("@steam__tianzhuding"):split(",")
    player.room:setPlayerMark(player, "steam__tianzhuding_draw-round", 1)
    player:drawCards(tonumber(split[2]), skel.name)
  end,
})

skel:addEffect(fk.DrawNCards, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    if player == target and player:getMark("@steam__tianzhuding") ~= 0 then
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local split = player:getMark("@steam__tianzhuding"):split(",")
    data.n = tonumber(split[1])
  end,
})


skel:addEffect("maxcards", {
  correct_func = function(self, player)
    local mark = player:getMark("@steam__tianzhuding")
    if mark ~= 0 then
      return tonumber(mark:split(",")[4])
    end
  end,
})


skel:addEffect("atkrange", {
  correct_func = function (self, player, to)
    local mark = player:getMark("@steam__tianzhuding")
    if mark ~= 0 then
      return tonumber(mark:split(",")[3])
    end
  end,
})


return skel
