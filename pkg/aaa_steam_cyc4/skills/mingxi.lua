local mingxi = fk.CreateSkill {
  name = "steam__mingxi",
  tags = { Skill.Hidden },
}

Fk:loadTranslationTable{
  ["steam__mingxi"] = "冥息",
  [":steam__mingxi"] = "隐匿技，当你登场后，你获得〖执义〗；每个〖执义〗令你的攻击范围+1。你受到伤害时，失去一个〖执义〗防止之。",

  ["#steam__mingxi-choice"] = "冥息：失去一个“执义”，防止你受到的伤害",

  ["$steam__mingxi1"] = "真是危险呢，这也要我出马？",
  ["$steam__mingxi2"] = "任务简报都是废纸，我清楚你要干什么。",
}

local U = require "packages.utility.utility"

mingxi:addEffect(U.GeneralAppeared, {
  anim_type = "special",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(mingxi.name)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(player, "steam__zhiyi1", "basic")
    room:handleAddLoseSkills(player, "steam__zhiyi1")
  end,
})

mingxi:addEffect("atkrange", {
  correct_func = function(self, from, to)
    if from:hasSkill(mingxi.name) then
      return #table.filter(from:getSkillNameList(), function (name)
        return Fk:translate(name, "zh_CN") == "执义"
      end)
    end
  end,
})

mingxi:addEffect(fk.DetermineDamageInflicted, {
  anim_type = "defensive",
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(mingxi.name) and
      table.find(player:getSkillNameList(), function (name)
        return Fk:translate(name, "zh_CN") == "执义"
      end)
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local skill = ""
    local skills = table.filter(player:getSkillNameList(), function (name)
      return Fk:translate(name, "zh_CN") == "执义"
    end)
    local result = room:askToCustomDialog(player, {
      skill_name = mingxi.name,
      qml_path = "packages/utility/qml/ChooseSkillBox.qml",
      extra_data = {
        skills, 1, 1, "#steam__mingxi-choice",
      },
    })
    if result == "" then
      skill = table.random(skills)
    else
      skill = json.decode(result)[1]
    end
    room:handleAddLoseSkills(player, "-"..skill)
    data:preventDamage()
  end,
})

return mingxi
