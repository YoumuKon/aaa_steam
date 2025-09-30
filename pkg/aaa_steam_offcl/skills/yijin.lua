local skel = fk.CreateSkill {
  name = "steam__yijin",
  tags = {Skill.Compulsory},
  dynamic_desc = function (self, player, lang)
    local mark = player:getTableMark("steam__yijin_remove")
    local str = "steam__yijin_dyn"
    for i = 1, 4 do
      str = str .. ":" .. (table.contains(mark, "steam__yijin"..i) and "" or "steam__yijin"..i)
    end
    return str
  end,
}

Fk:loadTranslationTable{
  ["steam__yijin"] = "亿金",
  [":steam__yijin"] = "锁定技，游戏开始时，你依次：①摸X张牌（X为你的手牌数且至多为5）；②加1点体力上限；③回复1点体力；④手牌上限+2；出牌阶段开始时，你需删除一项并令一名其他角色执行之，否则或失去1点体力。	",

  [":steam__yijin_dyn"] = "锁定技，游戏开始时，你依次：①{1}；②{2}；③{3}；④{4}；出牌阶段开始时，你需删除一项并令一名其他角色执行之，否则或失去1点体力。	",

  ["steam__yijin1"] = "摸X张牌（X为你的手牌数，至多为5）",
  ["steam__yijin2"] = "加1点体力上限",
  ["steam__yijin3"] = "回复1点体力",
  ["steam__yijin4"] = "手牌上限+2",
  ["#steam__yijin-choose"] = "亿金：令一名其他角色%arg",
  ["steam__yijin_active"] = "亿金",
  ["#steam__yijin-ask"] = "亿金：你须令一名其他角色执行一项，否则你失去1体力",

  ["$steam__yijin1"] = "吾家资巨万，无惜此两贯三钱！",
  ["$steam__yijin2"] = "小儿持金过闹市，哼！杀人何需我多劳！",
  ["$steam__yijin3"] = "普天之下，竟有吾难市之职？", -- 失败掉血
}

local doYijin = function (to, i, from)
  local room = from.room
  if i == 1 then
    local x = math.min(from:getHandcardNum(), 5)
    if x > 0 then
      to:drawCards(x, skel.name)
    end
  elseif i == 2 then
    room:changeMaxHp(to, 1)
  elseif i == 3 then
    room:recover { num = 1, skillName = skel.name, who = to, recoverBy = from }
  else
    room:addPlayerMark(to, MarkEnum.AddMaxCards, 2)
  end
end

skel:addEffect(fk.GameStart, {
  anim_type = "defensive",
  audio_index = {1,2},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(skel.name)
  end,
  on_use = function(self, event, target, player, data)
    for i = 1, 4 do
      if player.dead then return end
      doYijin(player, i, player)
    end
  end,
})

skel:addEffect(fk.EventPhaseStart, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(skel.name) then
      return target == player and player.phase == Player.Play
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local dat
    if #player:getTableMark("steam__yijin_remove") < 4 then
      _, dat = room:askToUseActiveSkill(player, { skill_name = "steam__yijin_active", prompt = "#steam__yijin-ask" })
    end
    if dat then
      local to = dat.targets[1]
      room:notifySkillInvoked(player, skel.name, "support", {to})
      player:broadcastSkillInvoke(skel.name, math.random(2))
      local choice = dat.interaction
      room:addTableMark(player, "steam__yijin_remove", choice)
      doYijin(to, tonumber(choice:sub(-1, -1)), player)
    else
      room:notifySkillInvoked(player, skel.name, "negative")
      player:broadcastSkillInvoke(skel.name, 3)
      room:loseHp(player, 1, skel.name)
    end
  end,
})

local skel_active = fk.CreateSkill {
  name = "steam__yijin_active",
}

skel_active:addEffect("active", {
  card_num = 0,
  target_num = 1,
  interaction = function(self, player)
    local all_choices = {"steam__yijin1", "steam__yijin2", "steam__yijin3", "steam__yijin4"}
    local choices = table.filter(all_choices, function(name)
      return not table.contains(player:getTableMark("steam__yijin_remove"), name)
    end)
    return UI.ComboBox {choices = choices, all_choices = all_choices }
  end,
  prompt = function (self)
    return self.interaction.data and Fk:translate("#steam__yijin-choose:::"..self.interaction.data) or " "
  end,
  card_filter = Util.FalseFunc,
  target_filter = function (self, player, to_select, selected)
    return #selected == 0 and to_select ~= player
  end,
})

skel:addLoseEffect(function (self, player, is_death)
  player.room:setPlayerMark(player, "steam__yijin_remove", 0)
end)

return {skel, skel_active}
