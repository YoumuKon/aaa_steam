local skel = fk.CreateSkill {
  name = "steam__shengxin",
  tags = {Skill.Limited},
}

Fk:loadTranslationTable{
  ["steam__shengxin"] = "圣心",
  [":steam__shengxin"] = "限定技，当任一角色进入濒死时，你可以令任意名角色各回复1点体力，因此脱离濒死或回满体力的角色各获得一个〖永恒信仰〗。",
  ["#steam__shengxin-choose"] = "圣心：选择任意名角色回复1点体力，脱离濒死或回满体力的角色获得〖永恒信仰〗。",
  -- 注意，拿的技能可以重复
  ["$steam__shengxin1"] = "",
  ["$steam__shengxin2"] = "",
}

skel:addEffect(fk.EnterDying, {
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(skel.name) then
      return player:usedSkillTimes(skel.name, Player.HistoryGame) == 0
    end
  end,
  on_cost = function (self, event, target, player, data)
    local targets = table.filter(player.room.alive_players, function (p) return p:isWounded() end)
    if #targets == 0 then return false end
    local tos = player.room:askToChoosePlayers(player, {
      targets = targets, min_num = 1, max_num = 999, skill_name = skel.name,
      prompt = "#steam__shengxin-choose",
    })
    if #tos > 0 then
      player.room:sortByAction(tos)
      event:setCostData(self, {tos = tos})
      return true
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local function getSkill(p)
      for loop = 1, 10 do
        local name = loop == 0 and "steam__yonghengxinyang" or "steam"..loop.."__yonghengxinyang"
        if Fk.skills[name] ~= nil and not p:hasSkill(name, true) then
          return name
        end
      end
    end
    for _, to in ipairs(event:getCostData(self).tos) do
      if not to.dead and to:isWounded() then
        local isDying = to.dying
        room:recover { num = 1, skillName = skel.name, who = to, recoverBy = player }
        if not to.dead and (to.maxHp == to.hp or (isDying and not to.dying)) then
          local skill = getSkill(to)
          if skill then room:handleAddLoseSkills(to, skill) end
        end
      end
    end
  end,
})

return skel
