local skel = fk.CreateSkill {
  name = "steam__jiuen",
  tags = {Skill.Wake},
}

Fk:loadTranslationTable{
  ["steam__jiuen"] = "救恩",
  [":steam__jiuen"] = "觉醒技，当你进入濒死时，你失去〖厄咒〗并减1点体力上限、回复1点体力，将任意枚因〖厄咒〗获得的标记交给等量其他角色并回复等量的体力，最后你保留的标记全部转化为<a href='steam__jiuen_feng'>“丰”</a>。",

  ["steam__jiuen_active"] = "救恩",
  ["#steam__jiuen-give"] = "救恩：将任意枚〖厄咒〗标记移给其他角色（每名角色限一个）",
  ["#steam__jiuen-marknum"] = "救恩：选择你交给 %dest 【%arg】标记的数量",

  ["#steam__jiuen_draw"] = "救恩",
  [":jiuen_feng"] = "每有1枚「丰」摸牌阶段摸牌数+1。",
  ["@[desc]jiuen_feng"] = "丰",

  ["$steam__jiuen1"] = "",
  ["$steam__jiuen2"] = "",
}

local ezhou_mark = {"@[desc]shencai1si", "@[desc]shencai1chi", "@[desc]shencai1zhang", "@[desc]shencai1tu", "@[desc]shencai1liu"}

skel:addEffect(fk.EnterDying, {
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(skel.name) and target == player and player:usedSkillTimes(skel.name, Player.HistoryGame) == 0
  end,
  can_wake = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:handleAddLoseSkills(player, "-steam__ezhou")
    room:changeMaxHp(player, -1)
    if not player.dead then
      room:recover { num = 1, skillName = skel.name, who = player, recoverBy = player }
    end
    if player.dead then return end
    local chosenTars = {}
    while player:isAlive() and table.find(ezhou_mark, function (s) return player:getMark(s) > 0 end) do
      if table.every(room.alive_players, function (p) return p == player or table.contains(chosenTars, p.id) end) then break end
      local _, dat = room:askToUseActiveSkill(player, {
        skill_name = "steam__jiuen_active", prompt = "#steam__jiuen-give",
        extra_data = {chosenTars = chosenTars}
      })
      if not dat then break end
      local mark = dat.interaction
      local to = dat.targets[1]
      table.insert(chosenTars, to.id)
      room:removePlayerMark(player, mark)
      room:addPlayerMark(to, mark)
      room:recover { num = 1, skillName = skel.name, who = player, recoverBy = player }
    end
    if not player.dead then
      local sum = 0
      for _, s in ipairs(ezhou_mark) do
        local num = player:getMark(s)
        if num > 0 then
          sum = sum + num
          room:setPlayerMark(player, s, 0)
        end
      end
      if sum > 0 then
        room:addPlayerMark(player, "@[desc]jiuen_feng", sum)
      end
    end
  end,
})

skel:addEffect(fk.DrawNCards, {
  mute = true,
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:getMark("@[desc]jiuen_feng") > 0
  end,
  on_use = function(self, event, target, player, data)
    data.n = data.n + player:getMark("@[desc]jiuen_feng")
  end,
})

local skel_active = fk.CreateSkill {
  name = "steam__jiuen_active",
}

skel_active:addEffect("active", {
  card_num = 0,
  target_num = 1,
  card_filter = Util.FalseFunc,
  interaction = function (self, player)
    local all_choices = ezhou_mark
    local choices = table.filter(ezhou_mark, function (s) return player:getMark(s) > 0 end)
    return UI.ComboBox { choices = choices, all_choices = all_choices }
  end,
  target_filter = function (self, player, to_select, selected)
    return #selected == 0 and player ~= to_select
    and (self.chosenTars and not table.contains(self.chosenTars, to_select.id))
  end,
})

return {skel, skel_active}
