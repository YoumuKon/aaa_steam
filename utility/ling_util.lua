
local LUtil = require 'packages/aaa_steam/utility/_base'

local U = require "packages/utility/utility"

--斗地主专属技能
local bahu = fk.CreateTriggerSkill{
  name = "lingling_lord__bahu&",
  anim_type = "drawcard",
  frequency = Skill.Compulsory,
  events = {fk.TurnStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player:usedSkillTimes(self.name, Player.HistoryRound) == 0
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(2, self.name)
  end,
}
local bahu_targetmod = fk.CreateTargetModSkill{
  name = "#lingling_lord__bahu&_targetmod",
  residue_func = function(self, player, skill, scope)
    if player:hasSkill(bahu) and skill.trueName == "slash_skill" and scope == Player.HistoryPhase then
      return 1
    end
  end,
}
bahu:addRelatedSkill(bahu_targetmod)
Fk:addSkill(bahu)
Fk:loadTranslationTable{
  ["lingling_lord__bahu&"] = "跋扈",
  [":lingling_lord__bahu&"] = "锁定技，回合开始时，你摸两张牌；出牌阶段，你可以多使用一张【杀】。",
}

local chengqiang = fk.CreateTriggerSkill{
  name = "lingling_lord__chengqiang&",
  anim_type = "defensive",
  frequency = Skill.Compulsory,
  events = {fk.GameStart},
  can_trigger = function (self, event, target, player, data)
    return player:hasSkill(self) and player.role == "lord"
  end,
  on_use = function (self, event, target, player, data)
    player.room:changeShield(player, 3)
  end,

  refresh_events = {fk.HpChanged, fk.Damaged, fk.Death},
  can_refresh = function (self, event, target, player, data)
    return player:usedSkillTimes(self.name, Player.HistoryGame) > 0
  end,
  on_refresh = function (self, event, target, player, data)
    local room = player.room
    if event == fk.HpChanged and target == player then
      if target and data.reason == "damage" and data.shield_lost > 0 then
        local e = room.logic:getCurrentEvent():findParent(GameEvent.Damage)
        if e then
          local damage = e.data[1]
          damage.extra_data = damage.extra_data or {}
          damage.extra_data.shield_lost = data.shield_lost
        end
      end
    elseif event == fk.Damaged and target == player then
      if data.extra_data and (data.extra_data.shield_lost or 0) > 0 then
        room.logic:getCurrentEvent():shutdown()
      end
    elseif event == fk.Death then
      room:changeShield(player, -3)
    end
  end,
}
Fk:addSkill(chengqiang)
Fk:loadTranslationTable{
  ["lingling_lord__chengqiang&"] = "城墙",
  [":lingling_lord__chengqiang&"] = "游戏开始时获得3点护甲（不触发受到伤害相关的技能），当一名其他角色死亡后失去这些护甲。",
}

local jiayi = fk.CreateViewAsSkill{
  name = "lingling_lord__jiayi&",
  anim_type = "control",
  prompt = "#lingling_lord__jiayi&",
  card_filter = Util.FalseFunc,
  view_as = function(self, cards)
    local card = Fk:cloneCard("sincere_treat")
    card.skillName = "lingling_lord__jiayi"
    return card
  end,
  enabled_at_play = function (self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,

  on_acquire = function (self, player, is_start)
    local room = player.room
    local targets = {}
    room.logic:getActualDamageEvents(1, function(e)
      local damage = e.data[1]
      if damage.from == player then
        table.insertIfNeed(targets, damage.to.id)
      end
    end, Player.HistoryGame)
    room:setPlayerMark(player, self.name, targets)
  end,
}
local jiayi_prohibit = fk.CreateProhibitSkill{
  name = "#lingling_lord__jiayi&_prohibit",
  is_prohibited = function(self, from, to, card)
    return table.contains(card.skillNames, "lingling_lord__jiayi") and
      table.contains(from:getTableMark("lingling_lord__jiayi"), to.id)
  end,
}
local jiayi_trigger = fk.CreateTriggerSkill{
  name = "#lingling_lord__jiayi&_trigger",

  refresh_events = {fk.Damage},
  can_refresh = function (self, event, target, player, data)
    return target == player and player:hasSkill(self, true)
  end,
  on_refresh = function (self, event, target, player, data)
    player.room:addTableMark(player, "lingling_lord__jiayi", data.to.id)
  end,
}
jiayi:addRelatedSkill(jiayi_prohibit)
jiayi:addRelatedSkill(jiayi_trigger)
Fk:addSkill(jiayi)
Fk:loadTranslationTable{
  ["lingling_lord__jiayi&"] = "假意",
  [":lingling_lord__jiayi&"] = "出牌阶段限一次，你可以视为对一名你未对其造成过伤害的其他角色使用【推心置腹】。",
  ["#lingling_lord__jiayi&"] = "假意：视为对一名未对其造成过伤害的角色使用【推心置腹】",
}

local fenbing = fk.CreateTriggerSkill{
  name = "lingling_lord__fenbing&",
  anim_type = "offensive",
  events = {fk.AfterCardTargetDeclared},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and data.card.trueName == "slash" and
      #player.room:getUseExtraTargets(data) > 0 and player:usedSkillTimes(self.name, Player.HistoryTurn) == 0 and
      player.room:getTag("RoundCount") % 2 < 3
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local to = room:askForChoosePlayers(player, room:getUseExtraTargets(data), 1, 1,
      "#lingling_lord__fenbing-invoke:::"..data.card:toLogString(), self.name, true)
    if #to > 0 then
      self.cost_data = {tos = to}
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    table.insert(data.tos, self.cost_data.tos)
  end,
}
Fk:addSkill(fenbing)
Fk:loadTranslationTable{
  ["lingling_lord__fenbing&"] = "分兵",
  [":lingling_lord__fenbing&"] = "前三轮内，每回合限一次，当你使用【杀】指定目标时，你可以额外指定一名目标。",
  ["#lingling_lord__fenbing-invoke"] = "分兵：你可以为%arg额外指定一个目标",
}

---@param player ServerPlayer 获得技能的角色（用于判断hasSkill）
---@param num integer 获得技能数
---@return string[] @返回获得技能名列表，可能为空
LUtil.GetRandomSkills = function (player, num)
  num = num or 1
  local skills = {}
  for _, general in pairs(Fk.generals) do
    if not general.hidden and not general.total_hidden then
      table.insertTableIfNeed(skills, general:getSkillNameList(true))
    end
  end
  skills = table.filter(skills, function (s)
    return not player:hasSkill(s, true)
  end)
  if #skills > 0 then
    return table.random(skills, num)
  end
end

---@param player ServerPlayer 获得预演回合的角色
---@param skillName string 额外回合技能名
LUtil.GainRehearsalTurn = function (player, skillName)
  skillName = skillName or "game_rule"
  local room = player.room
  room:setPlayerMark(player, "@@lingling__RehearsalTurn", 1)
  player:gainAnExtraTurn(true, "lingling__RehearsalTurn")
end
Fk:loadTranslationTable{
  ["@@lingling__RehearsalTurn"] = "预演回合",
}

local RehearsalTurn = fk.CreateTriggerSkill{
  name = "#RehearsalTurn",
  global = true,
  priority = 0.1,
  mute = true,
  events = {fk.TurnEnd},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:getMark("@@lingling__RehearsalTurn") ~= 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local hp_record = player:getMark("lingling__RehearsalTurn")
    if type(hp_record) ~= "table" then return end
    for _, p in ipairs(room:getAlivePlayers()) do
      local p_record = table.find(hp_record, function (sub_record)
        return #sub_record == 2 and sub_record[1] == p.id
      end)
      if p_record then
        p.hp = math.min(p.maxHp, p_record[2])
        room:broadcastProperty(p, "hp")
      end
    end
  end,

  refresh_events = {fk.TurnStart, fk.AfterTurnEnd},
  can_refresh = function(self, event, target, player, data)
    if target == player then
      if event == fk.TurnStart then
        local turn_event = player.room.logic:getCurrentEvent():findParent(GameEvent.Turn, true)
        return turn_event and turn_event.data[1] == player and turn_event.data[2].reason == "lingling__RehearsalTurn"
      elseif event == fk.AfterTurnEnd then
        return true
      end
    end
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    if event == fk.TurnStart then
      local hp_record = {}
      for _, p in ipairs(room.alive_players) do
        table.insert(hp_record, {p.id, p.hp})
      end
      room:setPlayerMark(player, "lingling__RehearsalTurn", hp_record)
    elseif event == fk.AfterTurnEnd then
      room:setPlayerMark(player, "lingling__RehearsalTurn", 0)
      room:setPlayerMark(player, "@@lingling__RehearsalTurn", 0)
    end
  end,
}
Fk:addSkill(RehearsalTurn)


Fk:loadTranslationTable{
  ["#lingling_lord_skill-choice"] = "选择获得其中一项技能",
  ["@$CenterArea"] = "中央区",
  ["$CenterArea"] = "中央区",
}

return LUtil
