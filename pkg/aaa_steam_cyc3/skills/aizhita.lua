local skel = fk.CreateSkill {
  name = "steam__aizhita",
  tags = {Skill.Compulsory},
}

Fk:loadTranslationTable{
  ["steam__aizhita"] = "爱之塔",
  [":steam__aizhita"] = "锁定技，每回合你首次造成或受到伤害后，随机<a href='cleanTreasure_href'>擦拭一件宝物</a>！每回合你第二次受到伤害后，来源也随机擦拭一件宝物。",
  -- 首次对自己造成伤害只能触发一次

  ["cleanTreasure_href"] = "若擦拭成功，你可以根据宝物类型执行对应的效果：<br>"..
  "卧龙：对一名角色造成1点火焰伤害。<br>"..
  "凤雏：横置至多三名角色的武将牌。<br>"..
  "水镜：移动场上的一张防具牌。<br>"..
  "玄剑：令一名角色摸一张牌并回复1点体力。",

  ["#ct_wolong"] = "卧龙：对1名角色造成1点火焰伤害",
  ["#ct_pangtong"] = "凤雏：横置至多3名角色的武将牌",
  ["#ct_simahui"] = "水镜：移动场上的一张防具牌",
  ["#ct_xushu"] = "玄剑：令1名角色摸一张牌并回复1点体力",
  ["ct_success"] = "擦拭成功！",
  ["ct_fail"] = "擦拭失败！",
}

---@param player ServerPlayer
local function cleanTreasure (player)
  local room = player.room
  room:delay(1200)
  local skillName = skel.name
  if math.random() < 0.03 then
    room:doAnimate("InvokeSkill", { name = " ", player = player.id, skill_type = "negative" })
    room:doBroadcastNotify("ShowToast", Fk:translate("ct_fail"))
    return
  end
  room:doBroadcastNotify("ShowToast", Fk:translate("ct_success"))
  local choice = table.random({"ct_wolong", "ct_pangtong", "ct_simahui", "ct_xushu"})
  if choice == "ct_wolong" then
    room:doAnimate("InvokeSkill", { name = " ", player = player.id, skill_type = "offensive" })
    local tos = room:askToChoosePlayers(player, {
      min_num = 1, max_num = 1, targets = room.alive_players, skill_name = skillName, prompt = "#ct_wolong",
    })
    if #tos > 0 then
      player:broadcastSkillInvoke(skillName, 2)
      for _, p in ipairs(tos) do
        if not p.dead then
          room:damage{
            from = player,
            to = p,
            damage = 1,
            damageType = fk.FireDamage,
            skillName = skillName,
          }
        end
      end
    end
  elseif choice == "ct_pangtong" then
    room:doAnimate("InvokeSkill", { name = " ", player = player.id, skill_type = "control" })
    local targets = table.filter(room.alive_players, function(p) return not p.chained end)
    if #targets == 0 then return end
    local tos = room:askToChoosePlayers(player, {
      min_num = 1, max_num = 3, targets = targets, skill_name = skillName, prompt = "#ct_pangtong",
    })
    if #tos > 0 then
      for _, p in ipairs(tos) do
        if not p.dead and not p.chained then
          p:setChainState(true)
        end
      end
    end
  elseif choice == "ct_simahui" then
    room:doAnimate("InvokeSkill", { name = " ", player = player.id, skill_type = "defensive" })
    local excludeIds = {}
    for _, p in ipairs(room.alive_players) do
      for _, id in ipairs(p:getCardIds("e")) do
        if Fk:getCardById(id).sub_type ~= Card.SubtypeArmor then
          table.insert(excludeIds, id)
        end
      end
    end
    local targets = room:askToChooseToMoveCardInBoard(player, {
      skill_name = skillName, prompt = "#ct_simahui", cancelable = true, flag = 'e', exclude_ids = excludeIds,
    })
    if #targets ~= 2 then return end
    room:askToMoveCardInBoard(player, {
      skill_name = skillName, target_one = targets[1], target_two = targets[2],
      exclude_ids = excludeIds, flag = "e",
    })
  elseif choice == "ct_xushu" then
    room:doAnimate("InvokeSkill", { name = " ", player = player.id, skill_type = "support" })
    local to = room:askToChoosePlayers(player, {
      min_num = 1, max_num = 1, targets = room.alive_players, skill_name = skillName, prompt = "#ct_xushu",
    })
    if #to > 0 then
      to = to[1]
      to:drawCards(1, skillName)
      if not to.dead and to:isWounded() then
        room:recover({
          who = to,
          num = 1,
          recoverBy = player,
          skillName = skillName
        })
      end
    end
  end
end

skel:addEffect(fk.Damage, {
  anim_type = "control",
  can_trigger = function (self, event, target, player, data)
    if player:hasSkill(skel.name) and target == player then
      if data.to == player then return false end -- 首次对自己造成伤害只能触发一次
      local damageEvents = player.room.logic:getActualDamageEvents(2, function(e) return e.data.from == player end)
      if #damageEvents > 0 and data == damageEvents[1].data then
        event:setCostData(self, {tos = {player} })
        return true
      end
    end
  end,
  on_use = function (self, event, target, player, data)
    cleanTreasure(event:getCostData(self).tos[1])
  end,
})

skel:addEffect(fk.Damaged, {
  anim_type = "negative",
  can_trigger = function (self, event, target, player, data)
    if player:hasSkill(skel.name) and target == player then
      local damageEvents = player.room.logic:getActualDamageEvents(2, function(e) return e.data.to == player end)
      if #damageEvents > 0 and data == damageEvents[1].data then
        event:setCostData(self, {tos = {player} })
        return true
      elseif #damageEvents > 1 and data == damageEvents[2].data then
        if data.from and not data.from.dead then
          event:setCostData(self, {tos = {data.from} })
          return true
        end
      end
    end
  end,
  on_use = function (self, event, target, player, data)
    cleanTreasure(event:getCostData(self).tos[1])
  end,
})

return skel
