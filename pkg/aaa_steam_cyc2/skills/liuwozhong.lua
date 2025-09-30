local skel = fk.CreateSkill {
  name = "steam__liuwozhong",
}

Fk:loadTranslationTable{
  ["steam__liuwozhong"] = "流涡种",
  [":steam__liuwozhong"] = "当你回复体力后，若你横置，你可以重置包含你的任意名角色，令其余重置者也回复等量体力。",

  ["#steam__liuwozhong-invoke"] = "流涡种：你可以重置，再重置其他角色，令这些角色回复%arg点体力",
  ["#steam__liuwozhong-choose"] = "流涡种：重置其他角色，令这些角色回复%arg点体力",

  ["$steam__liuwozhong1"] = "安心睡吧，做个好梦。",
  ["$steam__liuwozhong2"] = "别看我，别看我，别看我，别看我，看我呀——",
}

skel:addEffect(fk.HpRecover, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(skel.name) and player.chained
  end,
  on_cost = function (self, event, target, player, data)
    return player.room:askToSkillInvoke(player, { skill_name = self.name, prompt = "#steam__liuwozhong-invoke:::"..data.num })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:setChainState(false)
    if player.dead then return end
    local targets = table.filter(room.alive_players, function(p)
      return p ~= player and p.chained
    end)
    if #targets == 0 then return false end
    local tos = room:askToChoosePlayers(player, {
      min_num = 1, max_num = 99, targets = targets, skill_name = skel.name, prompt = "#steam__liuwozhong-choose:::"..data.num,
    })
    if #tos > 0 then
      room:sortByAction(tos)
      for _, to in ipairs(tos) do
        if not to.dead then
          to:setChainState(false)
          if not to.dead then
            room:recover { num = data.num, skillName = self.name, who = to, recoverBy = player }
          end
        end
      end
    end
  end,
})



return skel
