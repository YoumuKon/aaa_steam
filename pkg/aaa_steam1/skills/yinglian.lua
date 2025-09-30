local DIY = require "packages/diy_utility/diy_utility"

local skel = fk.CreateSkill {
  name = "steam__yinglian",
  --tags = {},
}

Fk:loadTranslationTable{
  ["steam__yinglian"] = "英联",
  [":steam__yinglian"] = "转换技，一名角色的准备阶段，①你可以摸一张牌并交给其一张牌；②其可以摸一张牌并交给你一张牌；③你可以与其各摸一张牌并交换一张牌。周始：令这三名角色各使用一张牌。",

  ["#steam__yinglian-draw"] = "英联：你可以摸一张牌并交给 %src 一张牌",
  ["#steam__yinglian-give"] = "英联：请交给 %src 一张牌",
  ["#steam__yinglian-ex"] = "英联：你可以与 %src 各摸一张牌并交换一张牌",
  ["#steam__yinglian-swap"] = "英联：选择一张牌，与对方交换！",
  ["#steam__yinglian-use"] = "英联：你可以使用一张牌！",
}

skel:addEffect(fk.EventPhaseStart, {
  anim_type = "support",
  can_trigger = function (self, event, target, player, data)
    return player:hasSkill(skel.name) and target.phase == Player.Start and not target.dead
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local index = DIY.getSwitchState(player, skel.name)
    if index == 1 then
      return room:askToSkillInvoke(player, { skill_name = skel.name, prompt = "#steam__yinglian-draw:"..target.id})
    elseif index == 2 then
      return room:askToSkillInvoke(target, { skill_name = skel.name, prompt = "#steam__yinglian-draw:"..player.id})
    elseif index == 3 then
      return room:askToSkillInvoke(player, { skill_name = skel.name, prompt = "#steam__yinglian-ex:"..target.id})
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    room:addTableMark(player, "steam__yinglian_tar", target.id)
    local drawAndGive = function (from, to)
      if from.dead then return end
      from:drawCards(1, skel.name)
      if from.dead or from:isNude() or from == to or to.dead then return end
      local cards = room:askToCards(from, { min_num = 1, max_num = 1, include_equip = true,
      skill_name = skel.name, cancelable = false, prompt = "#steam__yinglian-give:"..to.id})
      room:obtainCard(to, cards, false, fk.ReasonGive, from, skel.name)
    end
    local index = DIY.getSwitchState(player, skel.name)
    if index == 1 then
      drawAndGive(player, target)
    elseif index == 2 then
      drawAndGive(target, player)
    else
      player:drawCards(1, skel.name)
      if target:isAlive() then
        target:drawCards(1, skel.name)
      end
      if player:isAlive() and target:isAlive() and target ~= player and not player:isNude() and not target:isNude() then
        local ret = room:askToJointCards(player, { players = {player, target}, min_num = 1, max_num = 1,
         include_equip = true, skill_name = skel.name, cancelable = false, pattern = ".", prompt = "#steam__yinglian-swap"})
        room:swapCards(player, { {player, ret[player]}, {target, ret[target]} }, skel.name)
      end
    end
    DIY.changeSwitchState(player, skel.name)
  end
})

skel:addAcquireEffect(function (self, player, is_start)
  DIY.setSwitchState(player, self.name, 1, 3)
end)

skel:addLoseEffect(function (self, player, is_death)
  DIY.removeSwitchSkill(player, self.name)
end)

skel:addEffect(DIY.SkillSwitchLoopback, {
  anim_type = "offensive",
  can_trigger = function (self, event, target, player, data)
    return target == player and data.skill.name == skel.name and player:hasSkill(skel.name)
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local tos = player:getTableMark("steam__yinglian_tar")
    if #tos == 0 then return end
    tos = table.map(tos, Util.Id2PlayerMapper)
    if #tos > 3 then tos = table.slice(tos, #tos - 2, #tos + 1) end -- 取最后3名
    room:sortByAction(tos)
    for _, to in ipairs(tos) do
      if not to.dead then
        room:askToPlayCard(to, { skill_name = skel.name, skip = false,
        prompt = "#steam__yinglian-use", extra_data = {bypass_times = true, extraUse = true} })
      end
    end
    room:setPlayerMark(player, "steam__yinglian_tar", 0)
  end,
})

return skel
