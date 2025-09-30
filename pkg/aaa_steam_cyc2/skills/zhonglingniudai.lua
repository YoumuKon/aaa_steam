local skel = fk.CreateSkill {
  name = "steam__zhonglingniudai",
  dynamic_desc = function (self, player, lang)
    local removed = player:getTableMark("steam__zhonglingniudai_remove")
    if #removed == 0 then return end
    local str = "steam__zhonglingniudai_inner"
    local list = {
      "steam__zhonglingniudai_bz",
      "steam__zhonglingniudai_lj",
      "steam__zhonglingniudai_mz",
      "steam__zhonglingniudai_fail",
    }
    for _, v in ipairs(list) do
      str = str .. ":"
      if not table.contains(removed, v) then
        str = str .. "<br>" .. v .. "_info"
      end
    end
    return str
  end,
}

Fk:loadTranslationTable{
  ["steam__zhonglingniudai"] = "众灵纽带",
  [":steam__zhonglingniudai"] = "出牌阶段开始时，你可以“<a href='zhengsu_desc'>整肃</a>”。"..
  "<br>☆若你“擂进”成功，你可以视为使用一张无视距离的雷【杀】。"..
  "<br>☆若你“变阵”成功，你可以弃置一名其他角色区域内至多两张牌。"..
  "<br>☆若你“鸣止”成功，你可以复原一名角色，其移动场上一张牌。"..
  "<br>☆若你整肃失败，你可以视为对自己使用一张冰【杀】，仍获得整肃奖励。",

  [":steam__zhonglingniudai_inner"] = "出牌阶段开始时，你可以“<a href='zhengsu_desc'>整肃</a>”。"..
  "{1}{2}{3}{4}",

  ["#steam__zhonglingniudai-reward"] = "众灵纽带：请选择整肃奖励！",
  ["#steam__zhonglingniudai-iceslash"] = "众灵纽带：你可以视为对自己使用一张冰【杀】，获得整肃奖励",
  ["#steam__zhonglingniudai-throw"] = "众灵纽带：你可以弃置一名其他角色区域内至多两张牌",
  ["#steam__zhonglingniudai-reset"] = "众灵纽带：复原一名角色，并令其移动场上一张牌",
  ["#steam__zhonglingniudai-move"] = "众灵纽带：请选择两名角色，移动其场上的牌",

  ["$steam__zhonglingniudai1"] = "众灵之力！", -- 开始整肃1
  ["$steam__zhonglingniudai2"] = "喜悦和力量，都在我体内涌动！", -- 开始整肃2
  ["$steam__zhonglingniudai3"] = "叉出去！罚其二十军杖！", -- 整肃失败
  ["$steam__zhonglingniudai4"] = "烈火冲锋！", -- 变阵1
  ["$steam__zhonglingniudai5"] = "山羊之灵！", -- 变阵2
  ["$steam__zhonglingniudai6"] = "赐我力量！", -- 擂进1
  ["$steam__zhonglingniudai7"] = "巨熊之灵！", -- 擂进2
  ["$steam__zhonglingniudai8"] = "赐我强身！", -- 鸣止1
  ["$steam__zhonglingniudai9"] = "野猪之灵！", -- 鸣止2
  ["$steam__zhonglingniudai10"] = "凤凰之灵！", -- 冰杀1
  ["$steam__zhonglingniudai11"] = "赐我寒风！", -- 冰杀2
}

local U = require "packages/utility/utility"

skel:addEffect(fk.EventPhaseStart, {
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(skel.name) then
      return player.phase == Player.Play
    end
  end,
  on_cost = function(self, event, target, player, data)
    event:setCostData(self, { audio_index = math.random(2) })
    return player.room:askToSkillInvoke(player, { skill_name = skel.name })
  end,
  on_use = function(self, event, target, player, data)
    U.startZhengsu(player, player, skel.name, "")
  end,
})

skel:addEffect(fk.EventPhaseEnd, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(self) then
      return player.phase == Player.Discard and
      table.find(target:getTableMark("zhengsu_skill-turn"), function (v)
        return v[2] == skel.name and v[1] == player.id
      end)
    end
  end,
  on_cost = function(self, event, target, player, data)
    local choice
    for _, v in ipairs(target:getTableMark("zhengsu_skill-turn")) do
      if v[2] == skel.name and v[1] == player.id then
        choice = v[3]
        break
      end
    end
    if not choice then return false end
    local result =  target:getMark("@" .. choice.. "-turn")
    if result == "zhengsu_failure" then
      choice = "zhengsu_failure"
      if table.contains(player:getTableMark("steam__zhonglingniudai_remove"), "steam__zhonglingniudai_fail") or
        not player.room:askToSkillInvoke(player, { skill_name = skel.name, prompt = "#steam__zhonglingniudai-iceslash"})
      then return false end
    end
    event:setCostData(self, {choice = choice})
    return true
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:notifySkillInvoked(player, skel.name)
    local remove_list, remove = player:getTableMark("steam__zhonglingniudai_remove"), false
    local choice = event:getCostData(self).choice
    if choice == "zhengsu_leijin" then
      player:broadcastSkillInvoke(skel.name, math.random(6, 7))
      remove = table.contains(remove_list, "steam__zhonglingniudai_lj")
    elseif choice == "zhengsu_bianzhen" then
      player:broadcastSkillInvoke(skel.name, math.random(4, 5))
      remove = table.contains(remove_list, "steam__zhonglingniudai_bz")
    elseif choice == "zhengsu_mingzhi" then
      player:broadcastSkillInvoke(skel.name, math.random(8, 9))
      remove = table.contains(remove_list, "steam__zhonglingniudai_mz")
    elseif choice == "zhengsu_failure" then
      player:broadcastSkillInvoke(skel.name, math.random(10, 11))
      room:useVirtualCard("ice__slash", nil, player, player, skel.name, true)
      if player.dead then return end
    end
    -- 执行整肃奖励
    local choices = {"draw2"}
    if player:isWounded() then
      table.insert(choices, 1, "recover")
    end
    local reward = room:askToChoice(player, {
      choices = choices, skill_name = skel.name, prompt = "#steam__zhonglingniudai-reward",
      all_choices = {"draw2", "recover"}
    })
    U.rewardZhengsu(player, player, reward, skel.name)
    if player.dead or remove then return end -- 额外效果是否被移除
    -- 执行额外奖励
    if choice == "zhengsu_leijin" then
      room:askToUseVirtualCard(player, {
        skill_name = skel.name, name = "thunder__slash", extra_data = {bypass_distances = true}
      })
    elseif choice == "zhengsu_bianzhen" then
      local targets = table.filter(room:getOtherPlayers(player, false), function (p) return not p:isAllNude() end)
      if #targets == 0 then return false end
      local tos = room:askToChoosePlayers(player, {
        min_num = 1, max_num = 1, targets = targets, skill_name = skel.name,
        prompt = "#steam__zhonglingniudai-throw",
      })
      if #tos > 0 then
        local to = tos[1]
        local cards = room:askToChooseCards(player, { target = to, min = 1, max = 2, flag = "hej", skill_name = skel.name})
        room:throwCard(cards, skel.name, to, player)
      end
    elseif choice == "zhengsu_mingzhi" then
      local tos = room:askToChoosePlayers(player, {
        min_num = 1, max_num = 1, skill_name = skel.name, targets = room.alive_players, prompt = "#steam__zhonglingniudai-reset",
      })
      if #tos > 0 then
        local to = tos[1]
        to:reset()
        if to.dead then return end
        tos = room:askToChooseToMoveCardInBoard(to, {skill_name = skel.name, prompt = "#steam__zhonglingniudai-move"})
        if #tos > 0 then
          room:askToMoveCardInBoard(to, { target_one = tos[1], target_two = tos[2], skill_name = skel.name})
        end
      end
    end
  end,
})

skel:addLoseEffect(function (self, player, is_death)
  player.room:setPlayerMark(player, "steam__zhonglingniudai_remove", 0)
end)

return skel
