local skel = fk.CreateSkill {
  name = "steam__xiaomie",
  tags = {Skill.Combo},
}

Fk:loadTranslationTable{
  ["steam__xiaomie"] = "嚣灭",
  [":steam__xiaomie"] = "<a href='steam__xiaomie_combo-href'>连招技</a>（赢+赢+赢+赢），你视为使用一张拥有前X项效果的【杀】：1目标上限改为X；2无视距离与防具；3.不可响应；"..
  "4.改为冰【杀】。断招时，除非你重铸X张不同类别的牌以保留进度，否则立即施放。（X为当前连段数）",

  ["@steam__xiaomie"] = "嚣灭",
  ["#steam__xiaomie"] = "嚣灭：请视为对至少一名角色使用【杀】！",
  ["#steam__xiaomie-exclu"] = "嚣灭：请重铸进度张牌保留进度，否则立即释放连招！",

  ["steam__xiaomie_combo-href"] = "发动时机：你拼点结果确认时/你“喧起”的谋弈结果确认时/你造成或受到【决斗】的伤害后，<br>发动条件：连招记录的进度和等于四"..
  "<br>特别地：本技能的赢仅指代拼点赢/“喧起”的谋弈赢/造成【决斗】伤害，对应的输（即断招时机）为拼点输/“喧起”的谋弈输/受到【决斗】伤害。",

  ["$steam__xiaomie1"] = "还在思考吗，完美主义者？",
  ["$steam__xiaomie2"] = "不想被波及的话，可以离我远一点。",
  ["$steam__xiaomie3"] = "你希望我用多少时间解决他们？",
}

---@param player ServerPlayer
--嚣灭连招的杀
local xiaomieSlash = function (player)
  player.room:notifySkillInvoked(player, skel.name, "offensive")
  player:broadcastSkillInvoke(skel.name, math.random(2,3))
  if player.dead then return end
  local x = 0
  x = x + #player:getTableMark("@steam__xiaomie")
  player.room:setPlayerMark(player, "@steam__xiaomie", 0)
  local name = x == 4 and "ice__slash" or "slash"
  local slash = Fk:cloneCard(name)
  slash.skillName = skel.name
  local list = table.filter(player.room:getOtherPlayers(player), function (p)
    if x >= 2 then
      return player:canUseTo(slash, p, {bypass_distances = true, bypass_times = true})
    else
      return player:canUseTo(slash, p, {bypass_times = true})
    end
  end)
  if #list == 0 then return end
  local tos = player.room:askToChoosePlayers(player, {
    targets = list,
    min_num = 1,
    max_num = math.min(#list, x),
    skill_name = skel.name,
    prompt = "#steam__xiaomie",
    cancelable = false,
  })
  if #tos > 0 then
    local use 
    if x >= 2 then
      use = { from = player, card = slash, tos = tos, extraUse = true, extra_data = {steam__xiaomie = player,}}
    else
      use = { from = player, card = slash, tos = tos, extraUse = true,}
    end
    if x >= 3 then
      use.disresponsiveList = table.simpleClone(player.room.alive_players)
    end
    player.room:useCard(use)
  end
end

---@param player ServerPlayer
---@return boolean
--嚣灭断招的重铸，返回是或否
local xiaomieKeep = function (player)
  local x =  #player:getTableMark("@steam__xiaomie")
  player.room:notifySkillInvoked(player, skel.name, "negative")
  player:broadcastSkillInvoke(skel.name, 1)
  if player:isNude() or player.dead or x == 0 then return false end
  local _, dat = player.room:askToUseActiveSkill(player, {
    skill_name = "steam__xiaomie_active",
    prompt = "#steam__xiaomie-exclu",
    no_indicate = true,
    cancelable = true,
  })
  if dat then
    player.room:recastCard(dat.cards, player, skel.name)
    if #dat.cards == x then
      return true
    else
      return false
    end
  else
    return false
  end
end

skel:addEffect(fk.TargetSpecified, {
  can_refresh = function (self, event, target, player, data)
    return (data.extra_data or {}).steam__xiaomie == player and not data.to.dead
  end,
  on_refresh = function (self, event, target, player, data)
    data.to:addQinggangTag(data)
  end,
})

skel:addEffect(fk.PindianResultConfirmed, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return (data.from == player or data.to == player) and player:hasSkill(skel.name) and data.winner
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    if data.winner == player then
      if #player:getTableMark("@steam__xiaomie") < 4 then
        player.room:addTableMark(player, "@steam__xiaomie", "<font color=\"yellow\">赢</font>")
      end
      if #player:getTableMark("@steam__xiaomie") >= 4 then
        xiaomieSlash(player)
      end
    elseif data.winner ~= player then
      if not xiaomieKeep(player) then
        xiaomieSlash(player)
      end
    end
  end,
})

skel:addEffect(fk.Damage, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(skel.name) and data.card and data.card.trueName == "duel"
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    if #player:getTableMark("@steam__xiaomie") < 4 then
      player.room:addTableMark(player, "@steam__xiaomie", "<font color=\"yellow\">赢</font>")
    end
    if #player:getTableMark("@steam__xiaomie") >= 4 then
      xiaomieSlash(player)
    end
  end,
})

skel:addEffect(fk.Damaged, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(skel.name) and data.card and data.card.trueName == "duel"
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    if not xiaomieKeep(player) then
      xiaomieSlash(player)
    end
  end,
})

skel:addLoseEffect(function (self, player, is_death)
  player.room:setPlayerMark(player, "@steam__xiaomie", 0)
end)

return skel
