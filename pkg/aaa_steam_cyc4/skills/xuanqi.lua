local skel = fk.CreateSkill {
  name = "steam__xuanqi",
}

Fk:loadTranslationTable{
  ["steam__xuanqi"] = "喧起",
  [":steam__xuanqi"] = "出牌阶段限一次，你可以拼点，赢家将手牌摸至四张并与输家谋弈；赢家视为对输家使用【决斗】。",
  --若你赢了至少两次，剥夺对方下回合的出【杀】次数。

  ["#steam__xuanqi"] = "喧起：与一名角色拼点，拼点赢家将手牌摸至四张并与输家谋弈；谋弈赢家视为对输家使用【决斗】",
  ["steam__xuanqi-zhanyi"] = "战意飙升",
  ["steam__xuanqi-zhuanzhu"] = "专注盯防", 
  ["steam__xuanqi-zhengmian"] = "正面硬刚", 
  ["steam__xuanqi-raohou"] = "绕后偷袭",
  [":steam__xuanqi-zhanyi"] = "若对方正面硬刚，你赢；若对方绕后偷袭，你输。",
  [":steam__xuanqi-zhuanzhu"] = "若对方绕后偷袭，你赢；若对方正面硬刚，你输。", 
  [":steam__xuanqi-zhengmian"] = "若对方专注盯防，你赢；若对方战意飙升，你输。", 
  [":steam__xuanqi-raohou"] = "若对方战意飙升，你赢；若对方专注盯防，你输。",


  ["$steam__xuanqi1"] = "情绪在这里没有意义。",
  ["$steam__xuanqi2"] = "信念会打乱你的步调。",
  ["$steam__xuanqi3"] = "用你的武器告诉我，你是谁。",
}

local U = require "packages.utility.utility"

---@param player ServerPlayer
--嚣灭连招的杀
local xiaomieSlash = function (player)
  player.room:notifySkillInvoked(player, "steam__xiaomie", "offensive")
  player:broadcastSkillInvoke("steam__xiaomie", math.random(2,3))
  if player.dead then return end
  local x = 0
  x = x + #player:getTableMark("@steam__xiaomie")
  player.room:setPlayerMark(player, "@steam__xiaomie", 0)
  local name = x == 4 and "ice__slash" or "slash"
  local slash = Fk:cloneCard(name)
  slash.skillName = "steam__xiaomie"
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
    skill_name = "steam__xiaomie",
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
  player.room:notifySkillInvoked(player, "steam__xiaomie", "negative")
  player:broadcastSkillInvoke("steam__xiaomie", 1)
  player:addMark("steam__xiaomie_lose-turn", 1)
  if player:isNude() or player.dead or x == 0 then return false end
  if player:getMark("steam__xiaomie_lose-turn") == 1 then
    local _, dat = player.room:askToUseActiveSkill(player, {
      skill_name = "steam__xiaomie_active",
      prompt = "#steam__xiaomie-exclu",
      no_indicate = true,
      cancelable = true,
    })
    if dat then
      player.room:recastCard(dat.cards, player, "steam__xiaomie")
      if #dat.cards == x then
        return true
      else
        return false
      end
    else
      return false
    end
  else
    return false
  end
end

skel:addEffect("active", {
  mute = true,
  prompt = "#steam__xuanqi",
  max_phase_use_time = 1,
  card_num = 0,
  target_num = 1,
  can_use = function(self, player)
    return not player:isKongcheng() and player:usedSkillTimes(skel.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected, selected_cards)
    return #selected == 0 and to_select ~= player and player:canPindian(to_select)
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    room:notifySkillInvoked(player, skel.name, "offensive")
    player:broadcastSkillInvoke(skel.name, 1)
    --local x = 0
    local pindian = player:pindian({target}, skel.name)
    if player.dead then return end
    if not pindian.results[target].winner then return end
    local firstwin, firstlose
    if pindian.results[target].winner == player then
      firstwin = player
      firstlose = target
    elseif pindian.results[target].winner == target then
      firstwin = target
      firstlose = player
    end
    if firstwin ~= nil and not firstwin.dead then
      --if firstwin == player then x = x + 1 end
      if firstwin:getHandcardNum() < 4 then
        firstwin:drawCards(4 - firstwin:getHandcardNum(), skel.name)
      end
      if firstwin ~= nil and not firstwin.dead and not firstlose.dead then
        --这里不论锏自己赢或者输，都是锏选择防御手段
        local secondwin, secondlose
        player:broadcastSkillInvoke(skel.name, 2)
        local choices = U.doStrategy(room, player, target, { "steam__xuanqi-zhanyi", "steam__xuanqi-zhuanzhu" }, { "steam__xuanqi-zhengmian", "steam__xuanqi-raohou" }, skel.name, 1)
        if (choices[1] == "steam__xuanqi-zhanyi" and choices[2] ~= "steam__xuanqi-zhengmian") or (choices[1] == "steam__xuanqi-zhuanzhu" and choices[2] ~= "steam__xuanqi-raohou") then
          secondwin = player
          secondlose = target
          --偷懒用了直接执行效果，其实没差
          if player:hasSkill("steam__xiaomie") then
            if #player:getTableMark("@steam__xiaomie") < 4 then
              player.room:addTableMark(player, "@steam__xiaomie", "<font color=\"yellow\">赢</font>")
            end
            if #player:getTableMark("@steam__xiaomie") >= 4 then
              xiaomieSlash(player)
            end
          end
        else
          --偷懒用了直接执行效果，其实没差
          secondwin = target
          secondlose = player
          if player:hasSkill("steam__xiaomie") then
            if not xiaomieKeep(player) then
              xiaomieSlash(player)
            end
          end
        end
        --连招技发动后可能会出现击杀，需要判死
        if secondwin ~= nil and not secondwin.dead and not secondlose.dead then
          --if secondwin == player then x = x + 1 end
          local duel = Fk:cloneCard("duel")
          if not secondwin:prohibitUse(duel) and not secondlose:isProhibited(secondwin, duel) then
            player:broadcastSkillInvoke(skel.name, 3)
            local use = room:useVirtualCard("duel", nil, secondwin, secondlose, skel.name)
            --[[local thirdwin, thirdlose
            if use and use.extra_data and use.extra_data.steam__xuanqi then
              if use.extra_data.steam__xuanqi == player then
                thirdwin = player
                thirdlose = target
              elseif use.extra_data.steam__xuanqi == target then
                thirdwin = target
                thirdlose = player
              end
            end
            if thirdwin ~= nil then
              if thirdwin == player then x = x + 1 end
            end]]
          end
        end
      end
    end
    --[[if x >= 2 then
      if not player.dead and not target.dead then
        room:addPlayerMark(player, MarkEnum.SlashResidue.."-phase", 1)
        room:addPlayerMark(target, steam__xuanqi.name, 1)
      end
    end]]
  end,
})

--[[steam__xuanqi:addEffect(fk.EventPhaseStart, {
  anim_type = "control",
  can_refresh = function(self, event, target, player, data)
    return target == player and target.phase == Player.Play and player:getMark(steam__xuanqi.name) ~= 0
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(target, steam__xuanqi.name, 0)
    room:setPlayerMark(target, MarkEnum.SlashResidue.."-phase", target:getMark(MarkEnum.SlashResidue.."-phase") - 1)
  end,
})

steam__xuanqi:addEffect(fk.Damage, {
  can_refresh = function(self, event, target, player, data)
    return data.card and data.card.trueName == "duel" and data.card.skillName == steam__xuanqi.name
  end,
  on_refresh = function (self, event, target, player, data)
    local room = player.room
    local card_event = room.logic:getCurrentEvent():findParent(GameEvent.UseCard)
    if not card_event then return false end
    local use = card_event.data
    use.extra_data = use.extra_data or {}
    use.extra_data.steam__xuanqi = use.extra_data.steam__xuanqi or {}
    use.extra_data.steam__xuanqi = target
  end,
})]]

skel:addEffect(fk.TargetSpecified, {
  can_refresh = function (self, event, target, player, data)
    return (data.extra_data or {}).steam__xiaomie == player and not data.to.dead
  end,
  on_refresh = function (self, event, target, player, data)
    data.to:addQinggangTag(data)
  end,
})


return skel
