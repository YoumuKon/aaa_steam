local skel = fk.CreateSkill {
  name = "steam__zhonglingniudai_mz",
}

Fk:loadTranslationTable{
  ["steam__zhonglingniudai_mz"] = "众灵纽带",
  [":steam__zhonglingniudai_mz"] = "出牌阶段开始时，你可以“<a href='zhengsu_desc'>整肃</a>”。"..
  "<br>☆若你“鸣止”成功，你可以复原一名角色，其移动场上一张牌。",
}

local U = require "packages.utility.utility"

skel:addEffect(fk.EventPhaseStart, {
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(skel.name) then
      return player.phase == Player.Play
    end
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, { skill_name = skel.name })
  end,
  on_use = function(self, event, target, player, data)
    player:broadcastSkillInvoke("steam__zhonglingniudai", math.random(2))
    U.startZhengsu(player, player, skel.name, "")
  end,
})

skel:addEffect(fk.EventPhaseEnd, {
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(skel.name) then
      return player.phase == Player.Discard and U.checkZhengsu(player, player, skel.name)
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
    event:setCostData(self, {choice = choice})
    return true
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local choice = event:getCostData(self).choice
    player:broadcastSkillInvoke("steam__zhonglingniudai", math.random(8, 9))
    local choices = {"draw2"}
    if player:isWounded() then table.insert(choices, 1, "recover") end
    local reward = room:askToChoice(player, {
      choices = choices, skill_name = skel.name, prompt = "#steam__zhonglingniudai-reward",
      all_choices = {"draw2", "recover"}
    })
    U.rewardZhengsu(player, player, reward, skel.name)
    if player.dead then return end
    if choice == "zhengsu_mingzhi" then
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

return skel
