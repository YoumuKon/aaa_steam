local skel = fk.CreateSkill {
  name = "steam__longquanguibu",
  tags = {Skill.Compulsory},
}

Fk:loadTranslationTable{
  ["steam__longquanguibu"] = "龙犬诡步",
  [":steam__longquanguibu"] = "锁定技，你每发动两个武将牌上的其他技能，便重置其中一个，然后获得〖穿屋〗直到回合结束。",

  ["#steam__longquanguibu-choice"] = "龙犬诡步：重置一个技能",
  ["$steam__longquanguibu1"] = "龙犬咬不松口！",
  ["$steam__longquanguibu2"] = "我会重掌战局！",
}

skel:addEffect(fk.AfterSkillEffect, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    local skill = data.skill
    local name = (skill:getSkeleton() or skill).name
    if target == player and player:hasSkill(skel.name) and skill and skill.name ~= skel.name
     and not skill.is_delay_effect and not name:startsWith("#") then
      local skills = Fk.generals[player.general]:getSkillNameList(true)
      if table.contains(skills, name) then return true end
      if player.deputyGeneral ~= "" then
        skills = Fk.generals[player.deputyGeneral]:getSkillNameList(true)
        return table.contains(skills, name)
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local mark = player:getMark(skel.name)
    local skill = data.skill
    local skillName = (skill:getSkeleton() or skill).name
    if mark == 0 then
      room:setPlayerMark(player, skel.name, skillName)
    elseif mark ~= skillName then
      player:broadcastSkillInvoke(skel.name)
      room:notifySkillInvoked(player, skel.name)
      room:setPlayerMark(player, skel.name, 0)
      local choice = room:askToChoice(player, {
        choices = {mark, skillName}, skill_name = skel.name, prompt = "#steam__longquanguibu-choice", detailed = true
      })
      player:setSkillUseHistory(choice)
      if not player:hasSkill("steam__chuanwu", true, true) then
        room:handleAddLoseSkills(player, "steam__chuanwu")
        player.tag[skel.name] = true
      end
    end
  end,
})

skel:addEffect(fk.TurnEnd, {
  priority = 0.99, -- 要求比穿屋时机晚
  mute = true,
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    return player.tag[skel.name]
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    player.tag[skel.name] = nil
    player.room:handleAddLoseSkills(player, "-steam__chuanwu")
  end,
})


return skel
