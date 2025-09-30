local skel = fk.CreateSkill {
  name = "steam__zhonglingniudai_lj",
}

Fk:loadTranslationTable{
  ["steam__zhonglingniudai_lj"] = "众灵纽带",
  [":steam__zhonglingniudai_lj"] = "出牌阶段开始时，你可以“<a href='zhengsu_desc'>整肃</a>”。"..
  "<br>☆若你“擂进”成功，你可以视为使用一张无视距离的雷【杀】。",
}

local U = require "packages/utility/utility"

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
    player:broadcastSkillInvoke("steam__zhonglingniudai", math.random(6, 7))
    local choices = {"draw2"}
    if player:isWounded() then table.insert(choices, 1, "recover") end
    local reward = room:askToChoice(player, {
      choices = choices, skill_name = skel.name, prompt = "#steam__zhonglingniudai-reward",
      all_choices = {"draw2", "recover"}
    })
    U.rewardZhengsu(player, player, reward, skel.name)
    if player.dead then return end
    if choice == "zhengsu_leijin" then
      room:askToUseVirtualCard(player, {
        skill_name = skel.name, name = "thunder__slash", extra_data = {bypass_distances = true}
      })
    end
  end,
})

return skel
