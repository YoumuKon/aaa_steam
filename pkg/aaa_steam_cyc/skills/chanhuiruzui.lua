local skel = fk.CreateSkill {
  name = "steam__chanhuiruzui",
  tags = {Skill.Compulsory},
}

local esauMark = "@&steam__corrupted_esau"
local esauName = "steam__corrupted_esau"

Fk:loadTranslationTable{
  ["steam__chanhuiruzui"] = "忏悔汝罪",
  [":steam__chanhuiruzui"] = "锁定技，游戏开始时，或“堕化以扫”抵达你的座次后，将“堕化以扫”置于离你最远的一名角色的武将牌旁。每回合结束时，你判定：若为♠或<font color='red'>♥</font>的2-9，你获得判定牌，“堕化以扫”向你移动一个座次(初始方向随机)，且被抵达的角色需打出一张【闪】，否则受到1点火焰伤害(若为你，改为致命火焰伤害)。",

  ["#steam__chanhuiruzui-jink"] = "忏悔汝罪：你须打出一张【闪】，否则受到 %arg 点火焰伤害！",
  [esauMark] = "堕化以扫",
  ["#steam__chanhuiruzui_move"] = "“堕化以扫”移动至 %to",
}

local easuFunc = {}

-- 移动“堕化以扫”
---@param to ServerPlayer @ 目标
---@param from? ServerPlayer @ 来源，可能没有
easuFunc.changeEsau = function (to, from)
  local room = to.room
  if from then
    from.tag["corrupted_esau_keeper"] = nil
    room:setPlayerMark(from, esauMark, 0)
    room:doIndicate(from, {to})
  end
  to.tag["corrupted_esau_keeper"] = true
  room:setPlayerMark(to, esauMark, {esauName})
  room:sendLog { type = "#steam__chanhuiruzui_move", to = {to.id} , toast = true }

  -- 以下为询问闪
  if to.dead then return end
  local endPoint = to:hasSkill("steam__chanhuiruzui", true) -- 达到终点
  local n = 1
  if endPoint then
    n = math.max(n, to.hp + to.shield)
  end
  local resp = room:askToResponse(to, {
    skill_name = skel.name, pattern = "jink", prompt = "#steam__chanhuiruzui-jink:::"..n, cancelable = true,
  })
  if resp then
    room:responseCard(resp)
  else
    room:damage { to = to, damage = n, skillName = skel.name, damageType = fk.FireDamage }
  end
  if not to.dead and endPoint then
    easuFunc.throwEsau(to)
  end
end

-- 将“堕化以扫”丢到最远
---@param player ServerPlayer @ 来源
easuFunc.throwEsau = function (player)
  local room = player.room
  local from = table.find(room.players, function (p)
    return p.tag["corrupted_esau_keeper"] ~= nil
  end) -- 当前拥有以扫的人，可能没有
  local maxStep = 0 -- 最远步数
  local temp = player.next
  local map = {}
  for i = 1, #room.players - 1 do
    local step = math.min(i, (#room.players - i)) -- 该角色的最短路径步数
    maxStep = math.max(maxStep, step)
    map[step] = map[step] or {}
    table.insert(map[step], temp)
    temp = temp.next
  end
  if map[maxStep] ~= nil then
    local to = table.random(map[maxStep])
    easuFunc.changeEsau(to, from)
    room:doIndicate((from or player), {to})
  end
end

skel:addEffect(fk.GameStart, {
  anim_type = "negative",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(skel.name)
  end,
  on_use = function (self, event, target, player, data)
    easuFunc.throwEsau(player)
  end,
})

skel:addEffect(fk.TurnEnd, {
  anim_type = "negative",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(skel.name)
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local from = table.find(room.players, function (p)
      return p.tag["corrupted_esau_keeper"] ~= nil
    end)
    if from == nil then return end
    local judge = {
      who = player,
      reason = skel.name,
      pattern = ".|2~9|spade,heart",
      skipDrop = true,
    }
    room:judge(judge)
    local cid = judge.card and judge.card:getEffectiveId()
    if cid == nil then return end
    if judge.card:matchPattern(judge.pattern) and not player.dead then
      if room:getCardArea(cid) == Card.Processing then
        room:obtainCard(player, cid, true, fk.ReasonPrey, player, skel.name)
        if player.dead then return end
      end
      local direction = room:getTag("esauDirection")
      if direction == nil then
        direction = table.random({"clockwise", "anticlock"})
        room:setTag("esauDirection", direction)
      end
      local to = from.next
      if direction == "clockwise" then
        to = table.find(room.players, function (p) return p.next == from end) or to
      end
      easuFunc.changeEsau(to, from)
    end
    if room:getCardArea(cid) == Card.Processing then
      room:moveCardTo(cid, Card.DiscardPile, nil, fk.ReasonJudge)
    end
  end,
})

-- 给死亡清除的标记恢复
skel:addEffect(fk.Deathed, {
  can_refresh = function(self, event, target, player, data)
    return target == player and player.tag["corrupted_esau_keeper"]
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:setPlayerMark(player, esauMark, {esauName})
  end,
})


return skel
