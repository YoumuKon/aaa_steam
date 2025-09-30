local skel = fk.CreateSkill {
  name = "steam__qiangjue",
}

Fk:loadTranslationTable{
  ["steam__qiangjue"] = "枪诀",
  [":steam__qiangjue"] = "准备阶段，你从<a href='duomingshisanqiang-href'>《夺命十三枪》</a>枪谱中发现两式并分配！(每式使用后失去)",

  ["duomingshisanqiang-href"] = "相思：你使用【杀】指定目标后，可以先视为对其中一名目标使用一张【推心置腹】，若其因此获得红桃牌，此【杀】伤害+1。"..
  "<br>断肠：你使用【杀】指定目标后，可以移除目标角色等同于其技能数张牌至其下回合开始。"..
  "<br>盲龙：你使用【杀】造成伤害后，可以从牌堆中随机获得受伤角色手牌中拥有的花色的牌各一张。"..
  "<br>风流：你获得本式后，将随机一张性别为女的武将作为本回合的副将。"..
  "<br>无双：你使用【杀】的目标上限为3，每少指定一名目标，此【杀】的响应量+1。"..
  "<br>白龙：你使用【杀】造成伤害后，可以弃置你与目标各一张牌，若颜色不同，你视为使用一张【决斗】。"..
  "<br>忘川：你使用【杀】指定目标后，可以弃置其两张牌，令此【杀】伤害-1。"..
  "<br>鲲鹏：你使用【杀】时，你可以令攻击范围内的角色选择是否为你助战→弃置目标一张牌。此【杀】结算后，若造成过伤害，你获得一名拒绝助战的角色一张牌。。"..
  "<br>百鬼夜行：你可以将一张【杀】当多亮出两张牌的【兵临城下】使用。"..
  "<br>寻仇：你使用【杀】指定目标后，可以令其本回合不能使用牌。"..
  "<br>拜将封侯：你获得本式后，将随机一张封侯包中的武将作为本回合的副将。"..
  "<br>抬头：你使用【杀】时，可以摸等同于之点数张牌，然后弃置手牌至四张。"..
  "<br>我命由我不由天：你获得本式后，重铸任意张牌，然后再随机获得其他两式。",

  ["#steam__qiangjue-skillchoice"] = "枪诀：请从发现的三式中选择未选择过的一式。",
  ["#steam__qiangjue-playerchoose"] = "枪诀：请将【%arg】交给一名角色。",
  ["@@godhanxin_generalclear-turn"] = "副将：本回合",--为风流和拜将封侯统一封装副将清除指示物

  ["$steam__qiangjue1"] = "夺命十三枪，始于浩荡天恩，逐百鬼夜行天下无双。",
  ["$steam__qiangjue2"] = "风无声，心如止水，光无影，七剑无衡，海纳百川，浑然一琢！",
}

local all_skills = {
  "godhanxin__xiangsi", -- 相思
  "godhanxin__duanchang", -- 断肠
  "godhanxin__manglong", -- 盲龙
  "godhanxin__fengliu", -- 风流
  "godhanxin__wushuang", -- 无双
  "godhanxin__bailong", -- 白龙
  "godhanxin__wangchuan", -- 忘川
  "godhanxin__kunpeng", -- 鲲鹏
  "godhanxin__baiguiyexing", -- 百鬼夜行
  "godhanxin__xunchou", -- 寻仇
  "godhanxin__baijiangfenghou", -- 拜将封侯
  "godhanxin__taitou", -- 抬头
  "godhanxin__womingyouwo", -- 我命由我不由天
}

skel:addEffect(fk.EventPhaseStart, {
  anim_type = "special",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(skel.name) and player.phase == Player.Start
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    for _ = 1, 2, 1 do
      if player.dead then return end
      local skills = table.filter(all_skills, function(s) return Fk.skills[s] ~= nil end)
      skills = table.random(skills, 3)
      if #skills == 0 then break end
      local choice = room:askToChoice(player, {choices = skills, skill_name = self.name, prompt = "#steam__qiangjue-skillchoice", detailed = true })
      local tos = room:askToChoosePlayers(player, {
        min_num = 1, max_num = 1, targets = room.alive_players, skill_name = skel.name, cancelable = false,
        prompt = "#steam__qiangjue-playerchoose:::" .. choice ,
      })
      local to = tos[1]
      room:handleAddLoseSkills(to, choice)
    end
  end,
})

--- 发动时马上清理
local clear_fast = { "godhanxin__taitou", "godhanxin__fengliu", "godhanxin__baijiangfenghou", "godhanxin__womingyouwo" }

skel:addEffect(fk.AfterSkillEffect, {
  can_refresh = function(self, event, target, player, data)
    if not table.contains(all_skills, data.skill.name) then return false end
    return target == player and target:hasSkill(data.skill.name, true, true) and not table.contains(clear_fast, data.skill.name)
  end,
  on_refresh = function (self, event, target, player, data)
    player.room:handleAddLoseSkills(target, "-"..data.skill.name, nil, false, true)
  end,
})

skel:addEffect(fk.SkillEffect, {
  can_refresh = function(self, event, target, player, data)
    if not table.contains(all_skills, data.skill.name) then return false end
    return target == player and target:hasSkill(data.skill.name, true, true) and table.contains(clear_fast, data.skill.name)
  end,
  on_refresh = function (self, event, target, player, data)
    player.room:handleAddLoseSkills(target, "-"..data.skill.name, nil, false, true)
  end,
})

skel:addEffect(fk.TurnEnd, {
  anim_type = "drawcard",
  can_refresh = function (self, event, target, player, data)
    return player.tag["godhanxin_orgi_deputy"] ~= nil
  end,
  on_refresh = function (self, event, target, player, data)
    local deputy = player.tag["godhanxin_orgi_deputy"]
    player.tag["godhanxin_orgi_deputy"] = nil
    player.room:changeHero(player, deputy, false, true, true, false, false)
  end,
})

return skel
