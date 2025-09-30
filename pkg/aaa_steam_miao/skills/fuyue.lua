local skel = fk.CreateSkill {
  name = "steam__fuyue",
  tags = {Skill.Quest},
}

Fk:loadTranslationTable{
  ["steam__fuyue"] = "斧钺",
  [":steam__fuyue"] = "使命技，弃牌阶段开始时，你须将体力或手牌数调整至与另一项相等，然后令一名角色执行你此次调整的手牌或体力变动。"..
  "<br>⬤　成功：结束阶段，你的体力和手牌数均为全场最多，你将“斧钺”删去使命并获得“卤薄”；"..
  "<br>⬤　失败：结束阶段，你的体力值和手牌数均全场最少。",

  ["#steam__fuyue-choose"] = "斧钺：令一名角色执行你此次调整的手牌或体力变动",
  ["#steam__fuyue-choice"] = "斧钺：选择调整你的手牌或体力",

  ["steam__fuyue_draw"] = "摸 %arg 张牌",
  ["steam__fuyue_discard"] = "弃 %arg 张手牌",
  ["steam__fuyue_recover"] = "回复 %arg 点体力",
  ["steam__fuyue_losehp"] = "失去 %arg 点体力",

  ["$steam__fuyue1"] = "兵革羽旄，金鼓旗帜，饰孤之怒尔。",
  ["$steam__fuyue2"] = "倘能效诸兄弟，纵斧钺加身，欢诚甘乐之！",
  ["$steam__fuyue3"] = "羲和揽辔六龙回，卤薄千官泊虎台！",
}

---@param p ServerPlayer
---@param str string
local doFuyue = function (p, str)
  local room = p.room
  local splitter = str:split(":")
  local choice, num = splitter[1], tonumber(splitter[4]) or 0
  if choice:endsWith("draw") then
    p:drawCards(num, skel.name)
  elseif choice:endsWith("discard") then
    room:askToDiscard(p, {min_num = num, max_num = num, include_equip = true, skill_name = skel.name, cancelable = false})
  elseif choice:endsWith("recover") then
    room:recover { num = num, skillName = skel.name, who = p, recoverBy = room.current }
  elseif choice:endsWith("losehp") then
    room:loseHp(p, num, skel.name)
  end
end

skel:addEffect(fk.EventPhaseStart, {
  mute = true,
  can_trigger = function (self, event, target, player, data)
    if player:hasSkill(skel.name) and target == player and player:getQuestSkillState(skel.name) == nil then
      if player.phase == Player.Discard then
        return true
      elseif player.phase == Player.Finish then
        local minHp, maxHp, minHand, maxHand = 9999, 0, 9999, 0
        for _, p in ipairs(player.room.alive_players) do
          minHp = math.min(minHp, p.hp)
          maxHp = math.max(maxHp, p.hp)
          minHand = math.min(minHand, p:getHandcardNum())
          maxHand = math.max(maxHand, p:getHandcardNum())
        end
        return (player.hp == maxHp and player:getHandcardNum() == maxHand)
        or (player.hp == minHp and player:getHandcardNum() == minHand)
      end
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    local room = player.room
    if player.phase == Player.Discard then
      room:notifySkillInvoked(player, skel.name, "control")
      player:broadcastSkillInvoke(skel.name, math.random(2))
      local x = player:getHandcardNum() - player.hp
      if x == 0 then return end
      local choices = {}
      if x > 0 then
        table.insert(choices, "steam__fuyue_discard:::" .. x)
        table.insert(choices, "steam__fuyue_recover:::" .. x)
      else
        table.insert(choices, "steam__fuyue_draw:::" .. -x)
        table.insert(choices, "steam__fuyue_losehp:::" .. -x)
      end
      local choice = room:askToChoice(player, { choices = choices, skill_name = skel.name, "#steam__fuyue-choice"})
      doFuyue(player, choice)
      if not player.dead then
        local tos = room:askToChoosePlayers(player, { targets = room.alive_players, min_num = 1, max_num = 1,
        prompt = "#steam__fuyue-choose", skill_name = skel.name, cancelable = false})
        if #tos > 0 then
          local to = tos[1]
          doFuyue(to, choice)
        end
      end
    else
      local success = table.every(room.alive_players, function (p)
        return p.hp <= player.hp and p:getHandcardNum() <= player:getHandcardNum()
      end)
      -- 同时满足时，优先算成功
      room:updateQuestSkillState(player, skel.name, not success)
      if success then
        room:notifySkillInvoked(player, skel.name, "big")
        player:broadcastSkillInvoke(skel.name, 3)
        room:handleAddLoseSkills(player, "-steam__fuyue|steam__fuyue_copy|steam__lubao")
      end
    end
  end,
})

return skel
