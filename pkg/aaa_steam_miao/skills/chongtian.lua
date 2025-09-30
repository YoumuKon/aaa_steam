local skel = fk.CreateSkill {
  name = "steam__chongtian",
  tags = {Skill.Limited},
}

Fk:loadTranslationTable{
  ["steam__chongtian"] = "冲天",
  [":steam__chongtian"] = "限定技，出牌阶段，若为身份模式，你可以为至少两名角色分发一张额外身份牌，并将此身份牌亮出，其体力值扣减至1以下前须防止之，并弃置额外身份牌或原身份牌，将剩余身份牌作为身份，然后令伤害来源执行被弃置身份牌对应的奖惩。",

  ["@[:]steam__chongtian_rule"] = "额外身份",
  ["steam__chongtian_rule"] = "冲天",
  --（选择2名角色时，按身份2人局发身份牌，即1主1反）
  [":steam__chongtian_rule"] = "冲天发放身份牌时，根据选择的人数，取对应人数身份局的身份牌配置随机发放。"..
  "<br>当一名角色即将被移去身份牌时，若其有唯一的主公身份牌，则其不能移除主公身份牌。"..
  "<br>若游戏结束条件被满足时，存在拥有两张身份牌的角色，其身份牌其中之一属于获胜阵营，其即可获胜。"..
  "<br>仅有内奸存活时，所有内奸均胜利。有多个主公存活时，无法结束游戏。",

  ["#steam__chongtian"] = "冲天：为至少两名角色分发一张额外身份牌",
  ["@steam__chongtian"] = "冲天",
  ["#ChongtianRemove"] = "%from 弃置了 %arg 身份牌",
  ["#ChongtianStillLord"] = "<b>仍有主公存活，无法结束游戏！</b>",
  ["#steam__chongtian-lose"] = "冲天：请丢弃一张身份牌，令伤害来源执行击杀此身份的奖惩",
  ["ChongtianOrigRole"] = "原身份(%arg)",
  ["ChongtianExtraRole"] = "额外身份(%arg)",

  ["$steam__chongtian1"] = "唐去丑口则著黄，明黄当代唐。",
  ["$steam__chongtian2"] = "我欲讨国奸臣，洗涤朝廷，事成不退。",
}

skel:addEffect("active", {
  prompt = "#steam__chongtian",
  frequency = Skill.Limited,
  card_num = 0,
  min_target_num = 2,
  card_filter = Util.FalseFunc,
  target_filter = Util.TrueFunc,
  can_use = function(self, player)
    return player:usedSkillTimes(skel.name, Player.HistoryGame) == 0
    and Fk:currentRoom():isGameMode("role_mode")
  end,
  on_use = function(self, room, effect)
    room:setBanner("@[:]steam__chongtian_rule", "steam__chongtian_rule") -- 开启特殊胜利规则！
    local role_table = room.logic.role_table or Util.DummyTable
    local roles = role_table[#effect.tos]
    if not roles then return end
    roles = table.simpleClone(roles)
    table.shuffle(roles)
    for i, to in ipairs(effect.tos) do
      room:setPlayerMark(to, "@steam__chongtian", roles[i])
    end
  end,
})

--- 游戏结束检测
---@param room Room
---@param victim? ServerPlayer @ 死亡角色，可以没有
local  function winnerCheck(room, victim)
  --- 获得某角色的额外身份
  ---@return string?
  local function extraRole(to)
    local ret = to:getMark("@steam__chongtian")
    if type(ret) == "string" then return ret end
  end
  local winnerRole
  local alive_players = table.filter(room.players, function (p)
    return p ~= victim and not (p.dead and p.rest == 0)
  end)
  -- 没有人存活的话就平局吧
  if #alive_players == 0 then room:gameOver("") return true end
  -- 只剩我了，让我赢呗
  if #alive_players == 1 then winnerRole = alive_players[1].role end
  local alive_roles = {} -- 存活者的所有身份
  local lords = {} -- 存活的主公，存活2主不能结束游戏
  for _, p in ipairs(alive_players) do
    table.insertIfNeed(alive_roles, p.role)
    local exrole = extraRole(p)
    if exrole then
      table.insertIfNeed(alive_roles, exrole)
    end
    if p.role == "lord" or exrole == "lord" then
      table.insertIfNeed(lords, p)
    end
  end

  if not winnerRole then
    -- 先检测内奸胜利，若仅有内奸存活(有一张身份是内奸就算内奸)，则内奸胜利
    if table.every(alive_players, function (p) return p.role == "renegade" or extraRole(p) == "renegade" end) then
      winnerRole = "renegade"
    -- 如果仅有主忠存活，且不存在2主，则主忠胜利
    elseif #lords <= 1 and table.every(alive_players, function (p)
      return p.role == "lord" or extraRole(p) == "lord" or p.role == "loyalist" or extraRole(p) == "loyalist"
     end) then
      winnerRole = "lord+loyalist"
    -- 若没有主公，则反贼胜利
    elseif not table.contains(alive_roles, "lord") then
      winnerRole = "rebel+rebel_chief"
    -- 如果死亡角色为主公，但仍有其他主公存活，发个提示
    elseif victim and (victim.role == "lord" or extraRole(victim) == "lord") then
      room:sendLog{type = "#ChongtianStillLord", toast = true}
    end
  end
  if not winnerRole then return end
  -- 若额外身份符合胜利条件，则将角色身份改为额外身份（如果原本就是主公，就不变了，不然主公没了）
  for _, p in ipairs(alive_players) do
    local exrole = extraRole(p)
    if exrole and string.find(winnerRole, exrole) and not (string.find(winnerRole, "lord") and p.role == "lord") then
      room:setPlayerProperty(p, "role_shown", true)
      room:setPlayerProperty(p, "role", exrole)
    end
  end
  if not string.find(winnerRole, "civilian") then -- 平民混胜利
    winnerRole = winnerRole .. "+civilian"
  end
  room:gameOver(winnerRole)
end

--- 其体力值扣减至1以下前须防止之
skel:addEffect(fk.BeforeHpChanged, {
  is_delay_effect = true,
  mute = true,
  priority = 0.001,
  can_trigger = function (self, event, target, player, data)
    return target == player and player:getMark("@steam__chongtian") ~= 0
    and data.num < 0 and data.num + player.hp < 1
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    data.num = 0
    data.prevented = true
    local role, exrole = player.role, player:getMark("@steam__chongtian")
    local new_role, lose_role, show_role
    -- 如果该角色存在且仅存在一张主公身份牌，且其他角色没有主公身份牌，则其不能移除主公身份牌
    if not (role == "lord" and exrole == "lord") and (role == "lord" or exrole == "lord") and
    table.every(room:getOtherPlayers(player, false), function (p) return p.role ~= "lord" and p:getMark("@steam__chongtian") ~= "lord" end)
    then
      if role == "lord" then
        lose_role = exrole
      else
        lose_role = role
      end
    else
      local choices = {"ChongtianOrigRole:::"..role, "ChongtianExtraRole:::"..exrole}
      lose_role = room:askToChoice(player, {
        choices = choices, skill_name = skel.name, prompt = "#steam__chongtian-lose"
      })
      if lose_role:startsWith("ChongtianOrigRole") then -- 弃原本的身份牌
        lose_role = role
        show_role = true
      else
        lose_role = exrole
      end
    end
    new_role = (lose_role == role) and exrole or role
    room:setPlayerMark(player, "@steam__chongtian", 0)
    room:sendLog{type = "#ChongtianRemove", from = player.id, arg = lose_role, toast = true}
    room:setPlayerProperty(player, "role", new_role)

    -- 检测一下游戏胜利吧！万一赢了呢
    winnerCheck(room)

    -- 为了执行奖惩，暂时将身份改为弃置的身份
    room:setPlayerProperty(player, "role", lose_role)
    local killer = (data.damageEvent or Util.DummyTable).from
    Fk.game_modes[room.settings.gameMode]:deathRewardAndPunish(player, killer)
    room:setPlayerProperty(player, "role", new_role)
    if show_role then -- 如果弃掉原本身份牌，则亮出额外身份牌
      room:setPlayerProperty(player, "role_shown", true)
    end
  end,
})

skel:addEffect(fk.GameOverJudge, {
  is_delay_effect = true,
  mute = true,
  priority = 0.000001, -- 原游戏规则优先级为0，比他早就行
  can_trigger = function (self, event, target, player, data)
    return target == player and player.rest == 0 and player.dead
    -- 若未发放过额外身份，则不修改游戏规则
    and player.room:getBanner("@[:]steam__chongtian_rule") ~= nil
  end,
  on_trigger = function (self, event, target, player, data)
    local room = player.room
    winnerCheck(room, player)

    -- 停止原游戏规则结算
    return true
  end,
})

return skel
