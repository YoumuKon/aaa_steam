local extension = Package("aaa_steam_offcl")
extension.extensionName = "aaa_steam"

local U = require "packages/utility/utility"
local RUtil = require "packages/aaa_fenghou/utility/rfenghou_util"
local DIY = require "packages/diy_utility/diy_utility"

Fk:loadTranslationTable{
  ["aaa_steam_offcl"] = "官！",
  ["steam_miniex"] = "极", -- 搬运小程序登峰造极
  ["steammou"] = "蒸谋",
}




local zhaoxiang = General:new(extension, "steam__zhaoxiang", "han", 4, 4, General.Female)

local fanghun = fk.CreateTriggerSkill{
  name = "steam__fanghun",
  events = {fk.TargetSpecified, fk.TargetConfirmed},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and data.card.trueName == "slash"
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:addPlayerMark(player, "@meiying")
  end,

  on_lose = function (self, player, is_death)
    player.room:setPlayerMark(player, "@meiying", 0)
  end,
}
local fuhan = fk.CreateTriggerSkill{
  name = "steam__fuhan",
  events = {fk.TurnStart},
  frequency = Skill.Limited,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player:getMark("@meiying") > 0 and
      player:usedSkillTimes(self.name, Player.HistoryGame) == 0
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askForSkillInvoke(player, self.name, nil, "#steam__fuhan-invoke")
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local n = player:getMark("@meiying")
    room:setPlayerMark(player, "@meiying", 0)
    room:handleAddLoseSkills(player, "-steam__fanghun")
    if player.dead then return end

    local generals, same_g = {}, {}
    for _, general_name in ipairs(room.general_pile) do
      same_g = Fk:getSameGenerals(general_name)
      table.insert(same_g, general_name)
      same_g = table.filter(same_g, function (g_name)
        local general = Fk.generals[g_name]
        return general.kingdom == "shu" or general.subkingdom == "shu" or general.kingdom == "han" or general.subkingdom == "han"
      end)
      if #same_g > 0 then
        table.insert(generals, table.random(same_g))
      end
    end
    if #generals == 0 then return false end
    generals = table.random(generals, n)

    local skills = {}
    local choices = {}
    for _, general_name in ipairs(generals) do
      local general = Fk.generals[general_name]
      local g_skills = {}
      for _, skill in ipairs(general.skills) do
        if #skill.attachedKingdom == 0 or
          (table.contains(skill.attachedKingdom, "shu") and player.kingdom == "shu") or
          (table.contains(skill.attachedKingdom, "han") and player.kingdom == "han") then
          table.insertIfNeed(g_skills, skill.name)
        end
      end
      for _, s_name in ipairs(general.other_skills) do
        local skill = Fk.skills[s_name]
        if #skill.attachedKingdom == 0 or
          (table.contains(skill.attachedKingdom, "shu") and player.kingdom == "shu") or
          (table.contains(skill.attachedKingdom, "han") and player.kingdom == "han") then
          table.insertIfNeed(g_skills, skill.name)
        end
      end
      table.insertIfNeed(skills, g_skills)
      if #choices == 0 and #g_skills > 0 then
        choices = {g_skills[1]}
      end
    end
    if #choices > 0 then
      local result = player.room:askForCustomDialog(player, self.name,
      "packages/aaa_fenghou/qml/ChooseGeneralSkillsBox.qml", {
        generals, skills, 1, 2, "#steam__fuhan-choice", false
      })
      if result ~= "" then
        choices = json.decode(result)
      end
      room:handleAddLoseSkills(player, table.concat(choices, "|"), nil)
    end
  end,
}
zhaoxiang:addSkill(fanghun)
zhaoxiang:addSkill(fuhan)
Fk:loadTranslationTable{
  ["steam__zhaoxiang"] = "赵襄",
  ["#steam__zhaoxiang"] = "月痕芳影",
  ["illustrator:steam__zhaoxiang"] = "疾速K",

  ["steam__fanghun"] = "芳魂",
  [":steam__fanghun"] = "当你使用【杀】指定目标后或成为【杀】的目标后，你获得1个“梅影”标记。",
  ["steam__fuhan"] = "扶汉",
  [":steam__fuhan"] = "限定技，回合开始时，你可以移去所有“梅影”标记并失去“芳魂”，然后从X张（X为移去“梅影”标记数）汉或蜀汉势力武将牌中选择"..
  "并获得至多两个技能。",

  --["#steam__fanghun"] = "芳魂：弃1枚“梅影”标记发动“龙胆”并摸一张牌",
  --["#steam__fanghun_trigger"] = "芳魂",
  ["@meiying"] = "梅影",
  ["#steam__fuhan-invoke"] = "扶汉：你可以移去“梅影”标记，获得两个蜀汉势力武将的技能！",
  ["#steam__fuhan-choice"] = "扶汉：选择你要获得的至多2个技能",

  ["$steam__fanghun1"] = "凝傲雪之梅为魄，英魂长存，独耀山河万古明！",
  ["$steam__fanghun2"] = "铸凌霜之寒成剑，青锋出鞘，斩尽天下不臣贼！",
  ["$steam__fuhan1"] = "逝者如斯，亘古长流，唯英烈之魂悬北斗而长存！",
  ["$steam__fuhan2"] = "赵氏之女，跪祈诸公勿渡黄泉，暂留人间、佑大汉万年！",
  ["~steam__zhaoxiang"] = "世受国恩，今当以身殉国。",
}




local simazhao = General:new(extension, "steam__simazhao", "jin", 3)
Fk:loadTranslationTable{
  ["steam__simazhao"] = "司马昭",
  ["#steam__simazhao"] = "嘲风开天",
  ["designer:steam__simazhao"] = "先帝",
  ["illustrator:steam__simazhao"] = "鬼画府",
}

local suzhi = fk.CreateTriggerSkill{
  name = "steam__suzhi",
  frequency = Skill.Compulsory,
  mute = true,
  events = {fk.CardUsing, fk.DamageCaused, fk.AfterCardsMove, fk.TurnEnd},
  can_trigger = function(self, event, target, player, data)
    local room = player.room
    if player:hasSkill(self) and player == player.room.current then
      if event == fk.CardUsing then
        return target == player and data.card.type == Card.TypeTrick
      elseif event == fk.DamageCaused then
        return target == player and not data.chain
      elseif event == fk.AfterCardsMove then
        for _, move in ipairs(data) do
          if move.from and move.from ~= player.id and move.moveReason == fk.ReasonDiscard then
            --FIXME:没算同时两名角色弃置牌的情况，鸽
            local from = room:getPlayerById(move.from)
            if from and not (from.dead or from:isNude()) then
              for _, info in ipairs(move.moveInfo) do
                if info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip then
                  self.cost_data = move.from
                  return true
                end
              end
            end
          end
        end
      elseif event == fk.TurnEnd then
        return player:usedSkillTimes(self.name) < 3
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke(self.name)
    if event == fk.TurnEnd then
      room:notifySkillInvoked(player, self.name, "control")
      room:setPlayerMark(player, "@@steam__suzhi_fankui", 1)
      room:handleAddLoseSkills(player, "efengqi__fankui", self.name)
    else
      if event == fk.CardUsing then
        room:notifySkillInvoked(player, self.name, "drawcard")
        player:drawCards(1, self.name)
      elseif event == fk.DamageCaused then
        room:notifySkillInvoked(player, self.name, "offensive")
        room:doIndicate(player.id, {data.to.id})
        data.damage = data.damage + 1
      elseif event == fk.AfterCardsMove then
        room:notifySkillInvoked(player, self.name, "control")
        local card = room:askForCardChosen(player, room:getPlayerById(self.cost_data), "he", self.name)
        room:obtainCard(player.id, card, false, fk.ReasonPrey, player.id, self.name)
      end
    end
  end,
}

local suzhi_delay = fk.CreateTriggerSkill{
  name = "#steam__suzhi_delay",
  mute = true,
  events = {fk.TurnStart},
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:getMark("@@steam__suzhi_fankui") ~= 0
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(player, "@@steam__suzhi_fankui", 0)
    room:handleAddLoseSkills(player, "-efengqi__fankui", suzhi.name)
  end,
}
suzhi:addRelatedSkill(suzhi_delay)

local suzhi_targetmod = fk.CreateTargetModSkill{
  name = "#steam__suzhi_targetmod",
  frequency = Skill.Compulsory,
  bypass_distances = function(self, player, skill, card)
    return card and player:hasSkill(suzhi) and player.phase ~= Player.NotActive and
    card.type == Card.TypeTrick
  end,
}
suzhi:addRelatedSkill(suzhi_targetmod)
simazhao:addSkill(suzhi)
simazhao:addRelatedSkill("efengqi__fankui")

Fk:loadTranslationTable{
  ["steam__suzhi"] = "夙智",
  [":steam__suzhi"] = "锁定技，回合内：1.你造成的伤害+1；2.使用锦囊牌无距离限制且你摸一张牌；3.当其他角色的牌因弃置而置入弃牌堆时，你获得其一张牌。回合结束时，若你本回合触发以上效果不足三次，直到你的下个回合开始，你拥有〖反馈〗。",
  ["@@steam__suzhi_fankui"] = "反馈",
  ["#steam__suzhi_delay"] = "夙智",
  
  ["$steam__suzhi1"] = "敌军势大与否，无碍我自计定施。",
  ["$steam__suzhi2"] = "汝竭力强攻，也只是徒燥军心。",
}

local zhaoxin = fk.CreateTriggerSkill{
  name = "steam__zhaoxin",
  anim_type = "control",
  events = {fk.Damaged},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and player == target and not player:isKongcheng()
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askForSkillInvoke(player, self.name, nil, "#steam__zhaoxin-ask")
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:showCards(player.player_cards[Player.Hand])
    local targets = table.map(table.filter(room:getOtherPlayers(player, false), function(p)
      return (p:getHandcardNum() <= player:getHandcardNum()) end), Util.IdMapper)
    if #targets > 0 then
      local to = room:getPlayerById(room:askForChoosePlayers(player, targets, 1, 1, "#steam__zhaoxin-choose", self.name, false)[1])
      U.swapHandCards(room, player, player, to, self.name)
    end
  end,
}
simazhao:addSkill(zhaoxin)

Fk:loadTranslationTable{
  ["steam__zhaoxin"] = "昭心",
  [":steam__zhaoxin"] = "当你受到伤害后，你可以展示所有手牌，然后与一名手牌数不大于你的其他角色交换手牌。",
  ["#steam__zhaoxin-ask"] = "昭心：你可以展示所有手牌，然后与一名手牌数不大于你的角色交换手牌",
  ["#steam__zhaoxin-choose"] = "昭心：选择一名手牌数不大于你的角色，与其交换手牌",
  
  ["$steam__zhaoxin1"] = "行明动正，何惧他人讥毁。",
  ["$steam__zhaoxin2"] = "大业之举，岂因宵小而动？",
}

simazhao:addSkill("steam__fuyu")

local panjun = General:new(extension, "steam__panjun", "wu", 3)
local guanwei = fk.CreateTriggerSkill{
  name = "steam__guanwei",
  anim_type = "support",
  events = {fk.EventPhaseEnd},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) and target.phase == Player.Play and not target.dead and
      player:usedSkillTimes(self.name, Player.HistoryTurn) == 0 and not player:isNude() then
      local x = 0
      local suit = nil
      player.room.logic:getEventsOfScope(GameEvent.UseCard, 1, function (e)
        local use = e.data[1]
        if use.from == target.id then
          if suit == nil then
            suit = use.card.suit
          elseif suit ~= use.card.suit then
            x = 0
            return true
          end
          x = x + 1
        end
      end, Player.HistoryTurn)
      return x > 1
    end
  end,
  on_cost = function(self, event, target, player, data)
    local cards = player.room:askForDiscard(player, 1, 1, true, self.name, true, ".", "#steam__guanwei-invoke::"..target.id, true)
    if #cards > 0 then
      self.cost_data = {cards = cards, tos = {target.id}}
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    player.room:throwCard(self.cost_data.cards, self.name, player, player)
    if not target.dead then
      target:drawCards(2, self.name)
      target:gainAnExtraPhase(Player.Play)
    end
  end,
}
panjun:addSkill(guanwei)
local gongqing = fk.CreateTriggerSkill{
  name = "steam__gongqing",
  anim_type = "defensive",
  frequency = Skill.Compulsory,
  events = {fk.DamageInflicted},
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(self) and data.from then
      return data.from:getAttackRange() < 3 and data.damage > 1
    end
  end,
  on_use = function(self, event, target, player, data)
    data.damage = 1
  end,
}
local gongqing2 = fk.CreateTriggerSkill{
  name = "#steam__gongqing_defense",
  anim_type = "defensive",
  priority = 0,
  main_skill = gongqing,
  frequency = Skill.Compulsory,
  events = {fk.DamageInflicted},
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(gongqing) and data.from then
      return data.from:getAttackRange() < 3 and data.damage > 1
    end
  end,
  on_use = function(self, event, target, player, data)
    player:broadcastSkillInvoke(gongqing.name, 2)
    data.damage = 1
  end,
}
gongqing:addRelatedSkill(gongqing2)
panjun:addSkill(gongqing)
Fk:loadTranslationTable{
  ["steam__panjun"] = "潘濬",
  ["#steam__panjun"] = "方严疾恶",
  ["illustrator:steam__panjun"] = "秋呆呆",

  ["steam__guanwei"] = "观微",
  [":steam__guanwei"] = "每回合限一次，一名角色的出牌阶段结束时，若其于此回合内使用过的牌数大于1且这些牌花色均相同或均没有花色，"..
  "你可弃置一张牌。令其摸两张牌，获得一个额外的出牌阶段。",

  ["steam__gongqing"] = "公清",
  [":steam__gongqing"] = "锁定技，当你受到大于1点伤害时，若来源的攻击范围小于3，你将伤害值改为1。",
  ["#steam__guanwei-invoke"] = "观微：你可以弃置一张牌，令 %dest 摸两张牌并执行一个额外的出牌阶段",
  ["#steam__gongqing_defense"] = "公清",

  ["$steam__guanwei1"] = "今日宴请诸位，有要事相商。",
  ["$steam__guanwei2"] = "天下未定，请主公以大局为重。",
  ["$steam__gongqing1"] = "尔辈何故与降虏交善。",
  ["$steam__gongqing2"] = "豪将在外，增兵必成祸患啊！",
  ["~steam__panjun"] = "耻失荆州，耻失荆州啊！",
}



local sunhao = General:new(extension, "steam__sunhao", "wu", 5)
local chouhai = fk.CreateTriggerSkill{
  name = "steam__chouhai",
  anim_type = "drawcard",
  frequency = Skill.Compulsory,
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Start
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local n1, n2 = 0, 0
    for _, p in ipairs(room.alive_players) do
      if p:isWounded() then
        n1 = n1 + 1
      else
        n2 = n2 + 1
      end
    end
    local choices = {"steam__chouhai1:::"..n1, "steam__chouhai2:::"..n2}
    local choice = room:askForChoice(player, choices, self.name)
    choice = choice:split(":")[1]
    room:setPlayerMark(player, "@@"..choice, 1)
    if choice:endsWith("1") then
      player:drawCards(n1, self.name)
    else
      player:drawCards(n2, self.name)
    end
  end,
}
local chouhai_delay = fk.CreateTriggerSkill{
  name = "#steam__chouhai_delay",
  anim_type = "negative",
  frequency = Skill.Compulsory,
  events = {fk.CardUseFinished, fk.DamageInflicted},
  can_trigger = function(self, event, target, player, data)
    if target ~= player or player.dead then return false end
    if event == fk.CardUseFinished then
      return player:getMark("@@steam__chouhai1") ~= 0 and not player:isNude() and
      data.tos and table.find(TargetGroup:getRealTargets(data.tos), function (id)
        return id ~= player.id
      end)
    else
      return player:getMark("@@steam__chouhai2") ~= 0
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if event == fk.CardUseFinished then
      player:broadcastSkillInvoke(chouhai.name, 1)
      room:askForDiscard(player, 1, 1, true, chouhai.name, false)
    else
      player:broadcastSkillInvoke(chouhai.name, 2)
      data.damage = data.damage + 1
    end
  end,

  refresh_events = {fk.TurnStart},
  can_refresh = function (self, event, target, player, data)
    return (player:getMark("@@steam__chouhai1") ~= 0 or player:getMark("@@steam__chouhai2") ~= 0)
    and target == player
  end,
  on_refresh = function (self, event, target, player, data)
    player.room:setPlayerMark(player, "@@steam__chouhai1", 0)
    player.room:setPlayerMark(player, "@@steam__chouhai2", 0)
  end,
}
chouhai:addRelatedSkill(chouhai_delay)
sunhao:addSkill(chouhai)

local kuangshe = fk.CreateTriggerSkill{
  name = "steam__kuangshe$",
  frequency = Skill.Compulsory,
  anim_type = "support",
  events = {fk.GameStart, fk.TurnEnd},
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(self) then return false end
    if event == fk.GameStart then
      return true
    else
      return player:getMark("steam__shezang_record-turn") ~= 0 or player:getMark("steam__jishe_record-turn") ~= 0
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    if event == fk.GameStart then
      for _, p in ipairs(room:getOtherPlayers(player)) do
        if p:isMale() then
          room:handleAddLoseSkills(p, "steam__jishe")
        end
        if p:isFemale() then
          room:handleAddLoseSkills(p, "steam__shezang")
        end
      end
    else
      for _, skill in ipairs({"steam__jishe", "steam__shezang"}) do
        for _, pid in ipairs(player:getTableMark(skill.."_record-turn")) do
          room:doIndicate(player.id, {pid})
          local p = room:getPlayerById(pid)
          room:handleAddLoseSkills(p, "-"..skill)
          if not player.dead then
            room:recover { num = 1, skillName = self.name, who = player, recoverBy = player }
          end
        end
      end
    end
  end,

  -- 死人会清除技能发动记录，只能打mark了
  refresh_events = {fk.AfterSkillEffect},
  can_refresh = function(self, event, target, player, data)
    if not player:hasSkill(self, true) then return false end
    return target and data and (data.name == "steam__jishe" or data.name == "steam__shezang")
  end,
  on_refresh = function (self, event, target, player, data)
    player.room:addTableMarkIfNeed(player, data.name.."_record-turn", target.id)
  end,
}
sunhao:addSkill(kuangshe)

local jishe = fk.CreateActiveSkill{
  name = "steam__jishe",
  anim_type = "drawcard",
  card_num = 0,
  target_num = 0,
  prompt = "#steam__jishe",
  can_use = function(self, player)
    return player:getMaxCards() > 0
  end,
  card_filter = Util.FalseFunc,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    player:drawCards(1, self.name)
    if player.dead then return end
    room:addPlayerMark(player, MarkEnum.MinusMaxCardsInTurn, 1)
  end,
}
local jishe_trigger = fk.CreateTriggerSkill{
  name = "#steam__jishe_trigger",
  anim_type = "control",
  main_skill = jishe,
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(jishe) and player.phase == Player.Finish and player:isKongcheng()
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = table.map(table.filter(room.alive_players, function(p)
      return not p.chained end), Util.IdMapper)
    if #targets == 0 then return end
    local n = player.hp
    local tos = room:askForChoosePlayers(player, targets, 1, n, "#steam__jishe-choose:::"..tostring(n), self.name, true)
    if #tos > 0 then
      room:sortPlayersByAction(tos)
      self.cost_data = {tos = tos}
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    for _, id in ipairs(self.cost_data.tos) do
      local to = room:getPlayerById(id)
      if not to.dead and not to.chained then
        to:setChainState(true)
      end
    end
  end,
}
jishe:addRelatedSkill(jishe_trigger)
sunhao:addRelatedSkill(jishe)

Fk:loadTranslationTable{
  ["steam__jishe"] = "极奢",
  [":steam__jishe"] = "出牌阶段，若你的手牌上限大于0，你可以摸一张牌，然后本回合你的手牌上限-1；结束阶段，若你没有手牌，你可以横置至多X名角色（X为你的体力值）。",
  ["#steam__jishe"] = "极奢：摸一张牌，本回合你的手牌上限-1",
  ["#steam__jishe_trigger"] = "极奢",
  ["#steam__jishe-choose"] = "极奢：你可以横置至多%arg名角色",
}


local shezang = fk.CreateTriggerSkill{
  name = "steam__shezang",
  anim_type = "drawcard",
  events = {fk.EnterDying},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and (target == player or player.phase ~= Player.NotActive) and
      player:usedSkillTimes(self.name, Player.HistoryRound) == 0
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local suits = {1, 2, 3, 4}
    local cards = {}
    local id = -1
    for i = #room.draw_pile, 1, -1 do
      id = room.draw_pile[i]
      if table.removeOne(suits, Fk:getCardById(id).suit) then
        table.insert(cards, id)
      end
    end
    if #cards > 0 then
      room:moveCards({
        ids = cards,
        to = player.id,
        toArea = Card.PlayerHand,
        moveReason = fk.ReasonJustMove,
        proposer = player.id,
        skillName = self.name,
        moveVisible = true
      })
    end
  end,
}
sunhao:addRelatedSkill(shezang)

Fk:loadTranslationTable{
  ["steam__sunhao"] = "孙皓",
  ["#steam__sunhao"] = "淫刑滥虐",
  ["designer:steam__sunhao"] = "emo公主",

  ["steam__chouhai"] = "仇海",
  [":steam__chouhai"] = "锁定技，准备阶段，你须选一项："..
  "1.摸已受伤角色张牌，对其他角色使用牌后须弃置一张牌，直到你下回合开始；"..
  "2.摸未受伤角色张牌，受到伤害+1直到下回合开始。",
  ["steam__chouhai1"] = "摸 %arg 张牌，对其他角色使用牌时须弃置一张牌，直到你下回合",
  ["steam__chouhai2"] = "摸 %arg 张牌，受到伤害+1直到下回合开始",
  ["@@steam__chouhai1"] = "仇海:弃牌",
  ["@@steam__chouhai2"] = "仇海:加伤",
  ["#steam__chouhai_delay"] = "仇海",

  ["steam__kuangshe"] = "狂奢",
  [":steam__kuangshe"] = "主公技，锁定技，游戏开始时，令其他女性/男性角色获得【奢葬】/【极奢】，其发动过的回合结束时失去之并令你回复1点体力。",

  ["steam__shezang"] = "奢葬",
  [":steam__shezang"] = "每轮限一次，当你进入濒死状态时，或一名角色于你的回合内进入濒死状态时，你可以从牌堆底获得不同花色的牌各一张。",

  ["$steam__chouhai1"] = "哼，树敌三千又如何？",
  ["$steam__chouhai2"] = "不发狂，就灭亡！",
  ["$steam__kuangshe1"] = "这是要我命归黄泉吗？",
  ["$steam__kuangshe2"] = "这就是末世皇帝的不归路！",
  ["$steam__shezang1"] = "陛下以金玉饰思我之情，何不与我共长眠之？",
  ["$steam__shezang2"] = "九幽泉下黄金墓，黄金墓里断肠人。",
  ["~steam__sunhao"] = "命啊！命！",
}


--- 加减谋略值
---@param room Room @ 房间
---@param player ServerPlayer @ 角色
---@param num integer @ 加减值，负为减
local function handleMoulue(room, player, num)
  local n = player:getMark("@mini_moulue") or 0
  local new_n = math.min(math.max(n + num, 0), 5)
  room:setPlayerMark(player, "@mini_moulue", new_n)
  room:sendLog{
    type = num > 0 and "#addMoulue" or "#minusMoulue",
    from = player.id,
    arg = math.abs(num),
    arg2 = new_n,
  }
  room:handleAddLoseSkills(player, player:getMark("@mini_moulue") > 0 and "steam_miniex__miaoji" or "-steam_miniex__miaoji", nil, false, true)
end

Fk:loadTranslationTable{
  ["#addMoulue"] = "%from 加了 %arg 点谋略值，现在的谋略值为 %arg2 点",
  ["#minusMoulue"] = "%from 减了 %arg 点谋略值，现在的谋略值为 %arg2 点",
  ["@mini_moulue"] = "谋略值",
  ["mini_moulue"] = "<b>谋略值：</b><br>谋略值上限为5，有谋略值的角色拥有技能<a href=':steam_miniex__miaoji'>〖妙计〗</a>。",
}

local miaoji = fk.CreateViewAsSkill{
  name = "steam_miniex__miaoji",
  pattern = "dismantlement,nullification,ex_nihilo",
  prompt = "#steam_miniex__miaoji",
  interaction = function()
    local all_names = {["dismantlement"] = 1, ["nullification"] = 3, ["ex_nihilo"] = 3}
    local names = {}
    for name, v in pairs(all_names) do
      if Self:getMark("@mini_moulue") >= v then
        local card = Fk:cloneCard(name)
        if ((Fk.currentResponsePattern == nil and Self:canUse(card) and not Self:prohibitUse(card)) or
            (Fk.currentResponsePattern and Exppattern:Parse(Fk.currentResponsePattern):match(card))) then
          table.insertIfNeed(names, name)
        end
      end
    end
    if #names > 0 then
      return U.CardNameBox { choices = names, all_choices = {"dismantlement", "nullification", "ex_nihilo"} }
    end
  end,
  card_filter = Util.FalseFunc,
  view_as = function(self, cards)
    if not self.interaction.data then return nil end
    local card = Fk:cloneCard(self.interaction.data)
    card.skillName = self.name
    return card
  end,
  before_use = function(self, player, use)
    local names = {["dismantlement"] = 1, ["nullification"] = 3, ["ex_nihilo"] = 3}
    handleMoulue(player.room, player, - names[use.card.trueName])
  end,
  enabled_at_play = function(self, player)
    return player:usedSkillTimes(self.name) == 0
  end,
  enabled_at_response = function(self, player, response)
    if response or player:usedSkillTimes(self.name) > 0 or not Fk.currentResponsePattern then return false end
    local all_names = {["dismantlement"] = 1, ["nullification"] = 3, ["ex_nihilo"] = 3}
    for name, v in pairs(all_names) do
      if player:getMark("@mini_moulue") >= v then
        local card = Fk:cloneCard(name)
        if Exppattern:Parse(Fk.currentResponsePattern):match(card) then
          return true
        end
      end
    end
  end,
}

Fk:loadTranslationTable{
  ["steam_miniex__miaoji"] = "妙计",
  [":steam_miniex__miaoji"] = "每回合限一次，你可以消耗1~3点谋略值，视为使用对应的牌：1.【过河拆桥】；3.【无懈可击】或【无中生有】。",
  ["#steam_miniex__miaoji"] = "消耗1~3点谋略值，视为使用：1.【过河拆桥】；3.【无懈可击】或【无中生有】",
}

local zhugeliang = General:new(extension, "steam_miniex__zhugeliang", "shu", 3)
local sangu = fk.CreateTriggerSkill{
  name = "steam_miniex__sangu",
  events = {fk.TargetConfirmed},
  anim_type = "special",
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and
    player:getMark("@steam_miniex__sangu") > 0 and player:getMark("@steam_miniex__sangu") % 3 == 0
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(player, "@steam_miniex__sangu", 0)
    if player:getMark("@mini_moulue") < 5 then
      handleMoulue(room, player, 3)
    end
    room:askForGuanxing(player, room:getNCards(3), nil, nil, self.name)
  end,

  refresh_events = {fk.TargetConfirmed},
  can_refresh = function(self, event, target, player, data)
    return target == player and player:hasSkill(self)
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:addPlayerMark(player, "@steam_miniex__sangu", 1)
  end,
}

local yanshi = fk.CreateActiveSkill{
  name = "steam_miniex__yanshi",
  anim_type = "drawcard",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == player:getMark("_steam_miniex__yanshi-phase")
  end,
  target_num = 0,
  card_num = function(self)
    return Self:usedSkillTimes(self.name, Player.HistoryPhase) > 0 and 1 or 0
  end,
  card_filter = function(self, to_select, selected_cards)
    return #selected_cards < (Self:usedSkillTimes(self.name, Player.HistoryPhase) > 0 and 1 or 0)
    and not Self:prohibitDiscard(Fk:getCardById(to_select))
  end,
  interaction = function(self)
    local all_choices = {"Top", "Bottom"}
    local choices = table.simpleClone(all_choices)
    table.removeOne(choices, Self:getMark("_steam_miniex__yanshi_record-phase"))
    return UI.ComboBox { choices = choices, all_choices = all_choices }
  end,
  prompt = function(self, selected_cards, selected_targets)
    local choices = {"Top", "Bottom"}
    table.removeOne(choices, Self:getMark("_steam_miniex__yanshi_record-phase"))
    if #choices == 1 then
      return "#steam_miniex__yanshi_only:::" .. choices[1]
    else
      return "#steam_miniex__yanshi_choose"
    end
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local choice = self.interaction.data
    if not choice then return false end
    room:setPlayerMark(player, "_steam_miniex__yanshi_record-phase", choice)
    if #effect.cards > 0 then
      room:throwCard(effect.cards, self.name, player, player)
      if player.dead then return end
    end
    player:drawCards(1, self.name, choice == "Bottom" and "bottom" or "top", "@@steam_miniex__yanshi-inhand-phase")
  end,
}
local yanshi_delay = fk.CreateTriggerSkill{
  name = "#steam_miniex__yanshi_delay",
  refresh_events = {fk.PreCardUse},
  can_refresh = function(self, event, target, player, data)
    return target == player and table.find(Card:getIdList(data.card), function(id)
      return Fk:getCardById(id):getMark("@@steam_miniex__yanshi-inhand-phase") > 0
    end)
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    room:notifySkillInvoked(player, "steam_miniex__yanshi", "special")
    room:addPlayerMark(player, "_steam_miniex__yanshi-phase")
  end,
}
yanshi:addRelatedSkill(yanshi_delay)

zhugeliang:addSkill(sangu)
zhugeliang:addSkill(yanshi)
zhugeliang:addRelatedSkill(miaoji)

Fk:loadTranslationTable{
  ["steam_miniex__zhugeliang"] = "极诸葛亮",
  ["designer:steam_miniex__zhugeliang"] = "三国杀小程序",

  ["steam_miniex__sangu"] = "三顾",
  [":steam_miniex__sangu"] = "锁定技，每当有三张牌指定你为目标后，你获得3点<a href='mini_moulue'>谋略值</a>，然后你观看牌堆顶的三张牌并将这些牌"..
  "置于牌堆顶或牌堆底。",
  ["@steam_miniex__sangu"] = "三顾",

  ["steam_miniex__yanshi"] = "演势",
  [":steam_miniex__yanshi"] = "出牌阶段限一次，你可从牌堆顶或牌堆底（不可与你此阶段上一次选择的相同）摸一张牌。若你于此阶段使用了此牌，你可弃置一张牌再次发动〖演势〗。",

  ["@@steam_miniex__yanshi-inhand-phase"] = "演势",
  ["#steam_miniex__yanshi_choose"] = "演势：选择从牌堆顶或牌堆底摸一张牌",
  ["#steam_miniex__yanshi_only"] = "演势：弃置一张牌，再从%arg摸一张牌",

  ["$steam_miniex__sangu1"] = "大梦先觉，感三顾之诚，布天下三分。",
  ["$steam_miniex__sangu2"] = "卧龙初晓，铭鱼水之情，托死生之志。",
  ["$steam_miniex__yanshi1"] = "进荆州，取巴蜀，以成峙鼎三分之势。",
  ["$steam_miniex__yanshi2"] = "天下虽多庸饶，亦在隆中方寸之间。",
  ["$steam_miniex__miaoji1"] = "大梦先觉，感三顾之诚，布天下三分。",
  ["$steam_miniex__miaoji2"] = "卧龙初晓，铭鱼水之情，托死生之志。",
  ["~miniex__zhugeliang"] = "君臣鱼水犹昨日，煌煌天命终不归……",
}

local bianyue = General:new(extension, "steam__bianyue", "wei", 3, 3, General.Female)
local bizu = fk.CreateActiveSkill{
  name = "steam__bizu",
  anim_type = "support",
  prompt = function()
    local x = Self:getHandcardNum()
    local tos = {}
    for _, p in ipairs(Fk:currentRoom().alive_players) do
      if p:getHandcardNum() == x then
        table.insert(tos, p.id)
      end
    end
    local mark = Self:getTableMark("steam__bizu_targets-turn")
    if table.find(mark, function(tos2)
      return #tos == #tos2 and table.every(tos, function(pid)
        return table.contains(tos2, pid)
      end)
    end) then
      return "#steam__bizu-active-last"
    else
      return "#steam__bizu-active"
    end
  end,
  card_num = 0,
  target_num = 0,
  can_use = Util.TrueFunc,
  card_filter = Util.FalseFunc,
  target_filter = Util.FalseFunc,
  target_tip = function(self, to_select, selected, selected_cards, card, selectable, extra_data)
    if Fk:currentRoom():getPlayerById(to_select):getHandcardNum() == Self:getHandcardNum() then
      return { {content = "draw1", type = "normal"} }
    end
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local x = player:getHandcardNum()
    local targets = table.filter(room:getAlivePlayers(), function (p)
      return p:getHandcardNum() == x
    end)
    local tos = table.map(targets, Util.IdMapper)
    room:doIndicate(player.id, tos)
    local mark = player:getTableMark("steam__bizu_targets-turn")
    if table.find(mark, function(tos2)
      return #tos == #tos2 and table.every(tos, function(pid)
        return table.contains(tos2, pid)
      end)
    end) then
      room:invalidateSkill(player, self.name, "-turn")
    else
      table.insert(mark, tos)
      room:setPlayerMark(player, "steam__bizu_targets-turn", mark)
    end
    for _, p in ipairs(targets) do
      if p:isAlive() then
        room:drawCards(p, 1, self.name)
      end
    end
  end,
}
local wuxie = fk.CreateTriggerSkill{
  name = "steam__wuxie",
  anim_type = "control",
  events = {fk.EventPhaseEnd},
  can_trigger = function(self, event, target, player, data)
    return player == target and player.phase == Player.Play and player:hasSkill(self)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local tos = room:askForChoosePlayers(player, table.map(room:getOtherPlayers(player, false), Util.IdMapper), 1, 1, 
    "#steam__wuxie-cost", self.name, true)
    if #tos > 0 then
      self.cost_data = {tos = tos}
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(self.cost_data.tos[1])
    local card
    local cards = table.filter(player:getCardIds(Player.Hand), function (id)
      card = Fk:getCardById(id)
      return card.is_damage_card
    end)
    local x = #cards
    if x > 0 then
      table.shuffle(cards)
      room:moveCards{
        ids = cards,
        from = player.id,
        toArea = Card.DrawPile,
        moveReason = fk.ReasonJustMove,
        skillName = self.name,
        drawPilePosition = -1,
        moveVisible = false,
      }
    end
    local y = 0
    if not to.dead then
      cards = table.filter(to:getCardIds(Player.Hand), function (id)
        card = Fk:getCardById(id)
        return card.is_damage_card
      end)
      y = #cards
      if y > 0 then
        table.shuffle(cards)
        room:moveCards{
          ids = cards,
          from = to.id,
          toArea = Card.DrawPile,
          moveReason = fk.ReasonJustMove,
          skillName = self.name,
          drawPilePosition = -1,
          moveVisible = false,
        }
      end
    end
    if player.dead then return false end
    local targets = {}
    if x > y then
      if not player:isWounded() then return false end
      targets = {player.id}
    elseif x == y then
      if player:isWounded() then
        targets = {player.id}
      end
      if not to.dead and to:isWounded() then
        table.insert(targets, to.id)
      end
      if #targets == 0 then return false end
    else
      if to.dead or not to:isWounded() then return false end
      targets = {to.id}
    end
    local tos = room:askForChoosePlayers(player, targets, 1, 1, "#steam__wuxie-recover", self.name, true)
    if #tos > 0 then
      room:recover({
        who = room:getPlayerById(tos[1]),
        num = 1,
        recoverBy = player,
        skillName = self.name
      })
    end
  end,
}
bianyue:addSkill(bizu)
bianyue:addSkill(wuxie)
Fk:loadTranslationTable{
  ["steam__bianyue"] = "卞玥",
  ["#steam__bianyue"] = "暮辉映族",
  ["designer:steam__bianyue"] = "银蛋",
  ["cv:steam__bianyue"] = "关云云月",
  ["illustrator:steam__bianyue"] = "米糊PU",

  ["steam__bizu"] = "庇族",
  [":steam__bizu"] = "出牌阶段，你可以选择手牌数与你相等的所有角色，这些角色各摸一张牌，"..
  "若这些角色与你此前于此回合内发动此技能时选择的角色完全相同，此技能于此回合内无效。",
  ["#steam__bizu-active"] = "发动 庇族，令所有手牌数与你相同的角色各摸一张牌（未重复目标）",
  ["#steam__bizu-active-last"] = "发动 庇族，令所有手牌数与你相同的角色各摸一张牌（技能无效）",

  ["steam__wuxie"] = "无胁",
  [":steam__wuxie"] = "出牌阶段结束时，你可以选择一名其他角色，你与其各将手牌区中的所有伤害类牌随机置于牌堆底，"..
  "你可以令以此法失去牌较多的角色回复1点体力。",
  ["#steam__wuxie-cost"] = "是否发动 无胁，选择一名其他角色，将你与该角色手牌中的所有伤害牌放到牌堆底",
  ["#steam__wuxie-recover"] = "无胁：可以令一名角色回复1点体力",

  ["$steam__bizu1"] = "花既繁于枝，当为众乔灌荫。",
  ["$steam__bizu2"] = "手执金麾伞，可为我族遮风挡雨。",
  ["$steam__wuxie1"] = "一个弱质女流，安能登辇拔剑？",
  ["$steam__wuxie2"] = "主上既亡，我当为生者计。",
  ["~steam__bianyue"] = "空怀悲怆之心，未有杀贼之力……",
}

local zhangning = General:new(extension, "steam__zhangning", "qun", 3, 3, General.Female)
local tianze = fk.CreateTriggerSkill{
  name = "steam__tianze",
  events = {fk.CardUseFinished, fk.FinishJudge},
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) and target ~= player and data.card.color == Card.Black then
      if event == fk.FinishJudge then
        return true
      else
        if target.dead or target.phase ~= Player.Play or player:isNude() then return false end
        local room = player.room
        local use_event = room.logic:getCurrentEvent():findParent(GameEvent.UseCard, true)
        if use_event == nil then return false end
        local x = target:getMark("steam__tianze_record-turn")
        if x == 0 then
          room.logic:getEventsOfScope(GameEvent.UseCard, 1, function (e)
            local use = e.data[1]
            if use.from == target.id and use.card.color == Card.Black then
              x = e.id
              room:setPlayerMark(target, "steam__tianze_record-turn", x)
              return true
            end
          end, Player.HistoryPhase)
        end
        return x == use_event.id
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    if event == fk.FinishJudge then return true end
    local card = player.room:askForDiscard(player, 1, 1, true, self.name, true, ".|.|spade,club|hand,equip", "#steam__tianze-invoke::"..target.id, true)
    if #card > 0 then
      self.cost_data = card
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke(self.name)
    if event == fk.CardUseFinished then
      room:notifySkillInvoked(player, self.name, "offensive")
      room:doIndicate(player.id, {target.id})
      room:throwCard(self.cost_data, self.name, player, player)
      room:damage{ from = player, to = target, damage = 1, skillName = self.name }
    else
      room:notifySkillInvoked(player, self.name, "drawcard")
      player:drawCards(1, self.name)
    end
  end,
}
local difa = fk.CreateTriggerSkill{
  name = "steam__difa",
  anim_type = "drawcard",
  events = {fk.AfterCardsMove},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) and player:usedSkillTimes(self.name) == 0 and player.phase ~= Player.NotActive then
      local ids = {}
      for _, move in ipairs(data) do
        if move.to == player.id and move.toArea == Card.PlayerHand then
          for _, info in ipairs(move.moveInfo) do
            if table.contains(player:getCardIds("h"), info.cardId) and Fk:getCardById(info.cardId).color == Card.Red then
              table.insertIfNeed(ids, info.cardId)
            end
          end
        end
      end
      if #ids > 0 then
        self.cost_data = ids
        return true
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    local card = player.room:askForDiscard(player, 1, 1, true, self.name, true, tostring(Exppattern{ id = self.cost_data }),
      "#steam__difa-invoke", true)
    if #card > 0 then
      self.cost_data = card
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:throwCard(self.cost_data, self.name, player, player)
    local names = player:getMark("steam__difa_names")
    if type(names) ~= "table" then
      names = U.getAllCardNames("td", true)
      room:setPlayerMark(player, "steam__difa_names", names)
    end
    if #names == 0 then return end
    local name = room:askForChoice(player, names, self.name)
    local cards = room:getCardsFromPileByRule(name, 1, "discardPile")
    if #cards == 0 then
      cards = room:getCardsFromPileByRule(name, 1)
    end
    if #cards > 0 then
      room:obtainCard(player, cards[1], true, fk.ReasonJustMove)
    end
  end,
}
zhangning:addSkill(tianze)
zhangning:addSkill(difa)
Fk:loadTranslationTable{
  ["steam__zhangning"] = "张宁",
  ["#steam__zhangning"] = "大贤后人",
  ["illustrator:steam__zhangning"] = "君桓文化",
  ["steam__tianze"] = "天则",
  [":steam__tianze"] = "当其他角色于其出牌阶段内使用第一张黑色牌结算结束后，你可以弃置一张黑色牌，对其造成1点伤害；"..
  "当其他角色的黑色判定牌生效后，你摸一张牌。",
  ["steam__difa"] = "地法",
  [":steam__difa"] = "每回合限一次，当你于回合内得到红色牌后，你可以弃置其中一张牌，然后选择一种锦囊牌的牌名，从牌堆或弃牌堆获得一张此牌名的牌。",

  ["#steam__tianze-invoke"] = "是否发动 天则，弃置一张黑色牌来对%dest造成1点伤害",
  ["#steam__difa-invoke"] = "是否发动 地法，弃置一张刚得到的红色牌，然后检索一张锦囊牌",

  ["$steam__tianze1"] = "独立而不改，周行而不殆。",
  ["$steam__tianze2"] = "四时变化，日月更替，天之则也。",
  ["$steam__difa1"] = "地之法，土形气形，物因以生。",
  ["$steam__difa2"] = "气行乎地中，其行也因地之势。",
  ["~steam__zhangning"] = "天地之变，畏之非也。",
}






local jikang = General:new(extension, "steam__jikang", "wei", 3)

Fk:loadTranslationTable{
  ["steam__jikang"] = "嵇康",
  ["#steam__jikang"] = "囚牛形琴",
  ["cv:steam__jikang"] = "曹毅",
  ["designer:steam__jikang"] = "emo公主",
  ["illustrator:steam__jikang"] = "太玄工作室",
  ["~steam__jikang"] = "铮然傲骨，焉能阿附恶逆……",
}

-- 为了防止同时机技能互相触发而循环
---@param skill Skill
local SkillEffectTriggerCheck = function (skill)
  if skill:isInstanceOf(TriggerSkill) and type(skill.events) == "table" and table.contains(skill.events, fk.SkillEffect) then
    return false
  end
  return true
end

local juexiang = fk.CreateTriggerSkill{
  name = "steam__juexiang",
  anim_type = "drawcard",
  frequency = Skill.Compulsory,
  events = {fk.SkillEffect}, -- 先封了技能，技能结算后再摸牌，不然插结可以躲过封技能
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and data and data.name ~= self.name
    and data.frequency == Skill.Compulsory and player:hasSkill(data) and data:isPlayerSkill(player)
    and data.visible and not data.global and not data.cardSkill and SkillEffectTriggerCheck(data)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player.room:delay(300)
    player.room:addTableMark(player, "steam__juexiang_skill", data.name)
    room.logic:getCurrentEvent().parent:addExitFunc(function()
      player:drawCards(1, self.name)
    end)
  end,

  refresh_events = {fk.EnterDying},
  can_refresh = function (self, event, target, player, data)
    return target == player and player:getMark("steam__juexiang_skill") ~= 0
  end,
  on_refresh = function (self, event, target, player, data)
    player.room:setPlayerMark(player, "steam__juexiang_skill", 0)
  end,
}
local juexiang_invalidity = fk.CreateInvaliditySkill {
  name = "#steam__juexiang_invalidity",
  invalidity_func = function(self, player, skill)
    return table.contains(player:getTableMark("steam__juexiang_skill"), skill.name)
  end
}
juexiang:addRelatedSkill(juexiang_invalidity)
jikang:addSkill(juexiang)

Fk:loadTranslationTable{
  ["steam__juexiang"] = "绝响",
  [":steam__juexiang"] = "锁定技，当你发动其他锁定技后，令之失效直到你濒死，然后摸一张牌。",
  ["$steam__juexiang1"] = "生死无惧，琴音长存。",
  ["$steam__juexiang2"] = "广陵已失，千古绝响。",
}

local hexian = fk.CreateTriggerSkill{
  name = "steam__hexian",
  anim_type = "drawcard",
  frequency = Skill.Compulsory,
  events = {fk.HpChanged},
  on_use = function(self, event, target, player, data)
    player.room:delay(300)
    if not player:isKongcheng() then
      player.room:askForDiscard(player, 4, 4, false, self.name, false)
    end
    if player:isAlive() then
      player:drawCards(4, self.name)
    end
  end,
}
jikang:addSkill(hexian)

Fk:loadTranslationTable{
  ["steam__hexian"] = "和弦",
  [":steam__hexian"] = "锁定技，当你体力值变化后，须弃置四张手牌并摸四张牌。",
  ["$steam__hexian1"] = "寄情于琴，合于天地。",
  ["$steam__hexian2"] = "悠悠琴音，人人自醉。",
}

local rouxian = fk.CreateTriggerSkill{
  name = "steam__rouxian",
  anim_type = "drawcard",
  frequency = Skill.Compulsory,
  events = {fk.AfterCardsMove},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) and player:isWounded() then
      for _, move in ipairs(data) do
        if move.from == player.id and move.moveReason == fk.ReasonDiscard then
          for _, info in ipairs(move.moveInfo) do
            if info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip then
              if Fk:getCardById(info.cardId).color == Card.Red then
                return true
              end
            end
          end
        end
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    player.room:delay(300)
    player.room:recover { num = 1, skillName = self.name, who = player, recoverBy = player }
  end,
}
jikang:addSkill(rouxian)

Fk:loadTranslationTable{
  ["steam__rouxian"] = "柔弦",
  [":steam__rouxian"] = "锁定技，当你的红色牌被弃置后，若已受伤则回复一点体力。",
  ["$steam__rouxian1"] = "抚琴拨弦，悠然自得。",
  ["$steam__rouxian2"] = "君子以琴会友，以瑟辅人。",
}

local liexian = fk.CreateTriggerSkill{
  name = "steam__liexian",
  anim_type = "offensive",
  frequency = Skill.Compulsory,
  events = {fk.CardRespondFinished , fk.CardUseFinished},
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(self) then
      if data.responseToEvent and data.responseToEvent.from then
        local from = player.room:getPlayerById(data.responseToEvent.from)
        if from and from:isAlive() and from ~= player then
          self.cost_data = {tos = {from.id}}
          return true
        end
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:delay(300)
    local from = room:getPlayerById(data.responseToEvent.from)
    room:loseHp(from, 1, self.name)
    if player:isAlive() then
      room:loseHp(player, 1, self.name)
    end
  end,
}
jikang:addSkill(liexian)

Fk:loadTranslationTable{
  ["steam__liexian"] = "烈弦",
  [":steam__liexian"] = "锁定技，当你响应其他角色的牌后，令其与你各失去一点体力。",
  ["$steam__lisexian1"] = "铮铮琴音，难平我心！",
  ["$steam__liexian2"] = "专政弄权，可识得弦中烈骨？",
}

local jixian = fk.CreateTriggerSkill{
  name = "steam__jixian",
  anim_type = "drawcard",
  frequency = Skill.Compulsory,
  events = {fk.AfterCardsMove},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) then
      local ids = {}
      for _, move in ipairs(data) do
        if move.to == player.id and move.toArea == Player.Hand then
          for _, info in ipairs(move.moveInfo) do
            if table.contains(player.player_cards[Player.Hand], info.cardId) then
              if Fk:getCardById(info.cardId).color == Card.Black and Fk:getCardById(info.cardId).type ~= Card.TypeBasic then
                table.insert(ids, info.cardId)
              end
            end
          end
        end
      end
      if #ids > 0 then
        self.cost_data = ids
        return true
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    player.room:delay(300)
    for _, id in ipairs(self.cost_data) do
      player.room:setCardMark(Fk:getCardById(id), "@@steam__jixian-inhand", 1)
      Fk:filterCard(id, player)
    end
  end,

  refresh_events = {fk.PreCardUse},
  can_refresh = function (self, event, target, player, data)
    return table.contains(data.card.skillNames, self.name)
  end,
  on_refresh = function (self, event, target, player, data)
    data.extraUse = true
  end,
}
local jixian_filter = fk.CreateFilterSkill{
  name = "#steam__jixian_filter",
  card_filter = function(self, card, player)
    return card:getMark("@@steam__jixian-inhand") ~= 0
  end,
  view_as = function(self, card)
    local c = Fk:cloneCard("analeptic", card.suit, card.number)
    c.skillName = jixian.name
    return c
  end,
}
jixian:addRelatedSkill(jixian_filter)
local jixian_targetmod = fk.CreateTargetModSkill{
  name = "#steam__jixian_targetmod",
  bypass_times = function(self, player, skill, scope, card)
    return card and table.contains(card.skillNames, jixian.name)
  end,
}
jixian:addRelatedSkill(jixian_targetmod)
jikang:addSkill(jixian)

Fk:loadTranslationTable{
  ["steam__jixian"] = "激弦",
  [":steam__jixian"] = "锁定技，当你获得黑色非基本牌后，令之视为无次数限制的【酒】。",
  ["#steam__jixian_filter"] = "激弦",
  ["@@steam__jixian-inhand"] = "激弦",
  ["$steam__jixian1"] = "一曲广陵散，寄我悠悠心。",
  ["$steam__jixian2"] = "一曲琴音，为我送别。",
}




local simahui = General:new(extension, "steammou__simahui", "qun", 3)

local shoutuWord = {"勤能补拙", "素材局", "上课", "随便赢", "新手教程", "为师带你飞", "谁还想学技能"}
local jianjie = fk.CreateActiveSkill{
  name = "steam__jianjie",
  anim_type = "support",
  card_num = 0,
  min_target_num = 1,
  prompt = "#steam__jianjie",
  card_filter = function(self, to_select, selected)
    return #selected == 0 and Fk:getCardById(to_select).color == Card.Black
    and table.contains(Self.player_cards[Player.Hand], to_select) and table.contains(Self:getHandlyIds(true), to_select)
    and not Self:prohibitDiscard(Fk:getCardById(to_select))
    and Self:getPileNameOfId(to_select) == "zhonghui_quan"
  end,
  target_filter = function(self, to_select, selected)
    return #selected < 2 and Self.id ~= to_select
  end,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    room:sortPlayersByAction(effect.tos)
    local tos = table.map(effect.tos, function(id) return room:getPlayerById(id) end)
    player:chat("收徒")
    if player:usedSkillTimes(self.name, Player.HistoryGame) > 1 then
      player:chat(table.random(shoutuWord))
    end
    for _, to in ipairs(tos) do
      if to:isAlive() then
        local cid
        if player:isAlive() and not to:isNude() then
          cid = room:askForCard(to, 1, 1, true, self.name, true, nil, "#steam__jianjie-give:"..player.id)[1]
        end
        if cid then
          room:obtainCard(player, cid, true, fk.ReasonGive, to.id, self.name)
          if not to.dead and not player.dead then
            local choices = table.filter({"steam__huoji", "efengqi__lianhuan"}, function (name)
              return not to:hasSkill(name, true)
            end)
            if #choices > 0 then
              local skill = room:askForChoice(player, choices, self.name, "#steam__jianjie-choice:"..to.id)
              room:addTableMark(to, "@steam__jianjie", skill)
              room:handleAddLoseSkills(to, skill)
            end
          end
        else
          room:loseHp(to, 1, self.name)
          if to:isAlive() and not to.chained then
            to:setChainState(true)
          end
        end
      end
    end
  end,
}
local jianjie_delay = fk.CreateTriggerSkill{
  name = "#steam__jianjie_delay",
  refresh_events = {fk.TurnEnd},
  can_refresh = function(self, event, target, player, data)
    return target == player and player:getMark("@steam__jianjie") ~= 0
  end,
  on_refresh = function (self, event, target, player, data)
    local room = player.room
    local skills = player:getTableMark("@steam__jianjie")
    room:setPlayerMark(player, "@steam__jianjie", 0)
    room:handleAddLoseSkills(player, "-"..table.concat(skills, "|-"))
  end,
}
jianjie:addRelatedSkill(jianjie_delay)
simahui:addSkill(jianjie)

local huoji = fk.CreateViewAsSkill{
  name = "steam__huoji",
  anim_type = "offensive",
  pattern = "fire_attack",
  prompt = "#steam__huoji",
  handly_pile = true,
  card_filter = function(self, to_select, selected, player)
    return #selected == 0 and Fk:getCardById(to_select).color == Card.Red and table.contains(player:getHandlyIds(), to_select)
  end,
  view_as = function(self, cards)
    if #cards ~= 1 then return end
    local card = Fk:cloneCard("fire_attack")
    card.skillName = self.name
    card:addSubcard(cards[1])
    return card
  end,
}
Fk:addSkill(huoji)
Fk:loadTranslationTable{
  ["steam__huoji"] = "火计",
  [":steam__huoji"] = "你可以将一张红色手牌当【火攻】使用。",
  ["#steam__huoji"] = "火计：你可以将一张红色手牌当【火攻】使用",
  ["$steam__huoji1"] = "此火可助我军大获全胜。",
  ["$steam__huoji2"] = "燃烧吧！",
}
simahui:addRelatedSkill("efengqi__lianhuan")
--[[
local lianhuan = fk.CreateActiveSkill{
  name = "steam__lianhuan",
  mute = true,
  card_num = 1,
  min_target_num = 0,
  prompt = "#steam__lianhuan",
  can_use = function(self, player)
    return not player:isKongcheng()
  end,
  card_filter = function(self, to_select, selected, player)
    return #selected == 0 and Fk:getCardById(to_select).suit == Card.Club and table.contains(player:getHandlyIds(), to_select)
  end,
  target_filter = function(self, to_select, selected, selected_cards, _, _, player)
    if #selected_cards == 1 then
      local card = Fk:cloneCard("iron_chain")
      card:addSubcard(selected_cards[1])
      card.skillName = self.name
      return player:canUse(card) and card.skill:targetFilter(to_select, selected, selected_cards, card, nil, player) and
      not player:prohibitUse(card) and not player:isProhibited(Fk:currentRoom():getPlayerById(to_select), card)
    end
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    player:broadcastSkillInvoke(self.name)
    if #effect.tos == 0 then
      room:notifySkillInvoked(player, self.name, "drawcard")
      room:recastCard(effect.cards, player, self.name)
    else
      room:notifySkillInvoked(player, self.name, "control")
      room:sortPlayersByAction(effect.tos)
      room:useVirtualCard("iron_chain", effect.cards, player, table.map(effect.tos, function(id)
        return room:getPlayerById(id) end), self.name)
    end
  end,
}
Fk:addSkill(lianhuan)
Fk:loadTranslationTable{
  ["steam__lianhuan"] = "连环",
  [":steam__lianhuan"] = "你可以将一张♣手牌当【铁索连环】使用或重铸。",
  ["#steam__lianhuan"] = "连环：你可以将一张♣手牌当【铁索连环】使用或重铸",
  ["$steam__lianhuan1"] = "伤一敌可连其百！",
  ["$steam__lianhuan2"] = "通通连起来吧！",
}
--]]
local badWord = {"我服了", "智商检测", "牢底干啥呢", "你是这个👍", "😅", "幽默", "这是在?", "令人智熄"}
local yinshi = fk.CreateTriggerSkill{
  name = "steam__yinshi",
  anim_type = "defensive",
  frequency = Skill.Compulsory,
  events = {fk.DamageInflicted},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and target == player
    and (data.damageType ~= fk.NormalDamage or (data.card and data.card.type == Card.TypeTrick))
    and #player:getEquipments(Card.SubtypeArmor) == 0
  end,
  on_use = function (self, event, target, player, data)
    if data.from then
      player:chat("$!Egg:"..data.from.id)
      player:chat(table.random(badWord))
    end
    return true
  end,
}
simahui:addSkill(yinshi)

local goodWord = {
  "好", "好好好", "行", "牛的", "有实力的", "精彩", "无与伦比", "优秀", "神人", "天啊", "惊艳", "令人惊叹", "我服了", "天才", "太棒了",
  "神奇", "不可思议",
  "Good", "Great", "Nice", "Wonderful", "Brilliant", "Impressive", "Fantastic", "Unbelievable", "Master", "Terrific", "Oh my God",
  'Jesus crazy',
}
local chenghao = fk.CreateTriggerSkill{
  name = "steam__chenghao",
  anim_type = "drawcard",
  events = {fk.DamageCaused},
  times = function (self)
    return 2 - Self:usedSkillTimes(self.name)
  end,
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and data.damageType ~= fk.NormalDamage and target and not target.dead
    and player:usedSkillTimes(self.name) < 2
  end,
  on_cost = function (self, event, target, player, data)
    if player.room:askForSkillInvoke(player, self.name, nil, "#steam__chenghao-ask:"..target.id) then
      self.cost_data = {tos = {target.id}}
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local str = "6"
    if math.random() < 0.2 then
      str = "六"
    end
    local max = math.min(100, data.damage)
    local list = {}
    for i = 1, max do
      table.insert(list, str)
    end
    str = table.concat(list)
    player:chat(str)
    player:chat(table.random(goodWord).."!")
    target:drawCards(1, self.name)
    for i = 1, max do
      player:chat("$!Flower:"..target.id)
      room:delay(300)
    end
  end,
}
simahui:addSkill(chenghao)

Fk:loadTranslationTable{
  ["steammou__simahui"] = "谋司马徽",
  [":steammou__simahui"] = "点赞大师",
  ["designer:steammou__simahui"] = "先帝",

  ["steam__jianjie"] = "荐杰",
  [":steam__jianjie"] = "出牌阶段限一次，你可以令至多两名其他角色选择一项：1.交给你一张牌，你令其获得“火计”或“连环”直至其回合结束；2.失去1体力并横置。",
  ["#steam__jianjie"] = "荐杰：你可以“收徒”，令两名其他角色选择给牌并获得技能，或掉1血",
  ["#steam__jianjie-give"] = "荐杰：交给 %src 一张牌，其令你获得“火计”或“连环”直至你回合结束",
  ["#steam__jianjie-choice"] = "荐杰：令 %src 获得一个技能，直到其回合结束",
  ["@steam__jianjie"] = "荐杰",

  ["steam__yinshi"] = "隐士",
  [":steam__yinshi"] = "锁定技，当你受到属性伤害或锦囊牌造成的伤害时，若你装备区内没有防具牌，防止此伤害。",

  ["steam__chenghao"] = "称好",
  [":steam__chenghao"] = "每回合限两次，当一名角色造成属性伤害时，你可以令其摸一张牌。",
  ["#steam__chenghao-ask"] = "称好：你可以令 %src 摸一张牌",

  ["$steam__jianjie1"] = "二者得一，可安天下。",
  ["$steam__jianjie2"] = "公怀王佐之才，宜择人而仕。",
  ["$steam__jianjie3"] = "二人齐聚，汉室可兴矣。",
  ["$steam__chenghao1"] = "好，很好，非常好。",
  ["$steam__chenghao2"] = "您的话也很好。",
  ["$steam__yinshi1"] = "山野闲散之人，不堪世用。",
  ["$steam__yinshi2"] = "我老啦，会有胜我十倍的人来帮助你。",
  ["~steam__simahui"] = "这似乎……没那么好了……",
}

local fanyufeng = General:new(extension, "steam__fanyufeng", "qun", 3, 3, General.Female)
Fk:loadTranslationTable{
  ["steam__fanyufeng"] = "樊玉凤",
  ["#steam__fanyufeng"] = "红鸾寡宿",
  ["cv:steam__fanyufeng"] = "杨子怡",
  ["illustrator:steam__fanyufeng"] = "匠人绘",
  ["~steam__fanyufeng"] = "醮妇再遇良人难……",
}


local bazhan = fk.CreateActiveSkill{
  name = "steam__bazhan",
  anim_type = "switch",
  switch_skill_name = "steam__bazhan",
  prompt = function ()
    return "#steam__bazhan-"..Self:getSwitchSkillState("steam__bazhan", false, true)
  end,
  target_num = 1,
  card_num = function ()
    return (Self:getSwitchSkillState("steam__bazhan") == fk.SwitchYang) and 2 or 0
  end,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) < 1
  end,
  card_filter = function(self, to_select, selected)
    return #selected < self:getMaxCardNum()
  end,
  target_filter = function(self, to_select, selected, selected_cards)
    local to = Fk:currentRoom():getPlayerById(to_select)
    if Self:getSwitchSkillState("steam__bazhan") == fk.SwitchYin and #to:getCardIds("he") < 2 then
      return false
    end
    return #selected_cards == self:getMaxCardNum() and #selected == 0 and to_select ~= Self.id
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    local isYang = player:getSwitchSkillState(self.name, true) == fk.SwitchYang
    local loser = player

    local check
    if isYang and #effect.cards > 0 then
      check = table.find(effect.cards, function (id) return Fk:getCardById(id).suit == Card.Heart end)
      room:obtainCard(target.id, effect.cards, false, fk.ReasonGive, player.id)
    elseif not isYang and not target:isKongcheng() then
      local cards = room:askForCardsChosen(player, target, 2, 2, "he", self.name)
      check = table.find(cards, function (id) return Fk:getCardById(id).suit == Card.Heart end)
      room:obtainCard(player, cards, false, fk.ReasonPrey, player.id, self.name)
      loser = target
    end
    if not loser.dead and check then
      local card = Fk:cloneCard("analeptic")
      card.skillName = self.name
      room:useCard{
        from = loser.id, tos = {{loser.id}}, card = card, extraUse = true, extra_data = {analepticRecover = true}
      }
    end
  end,
}
fanyufeng:addSkill(bazhan)

Fk:loadTranslationTable{
  ["steam__bazhan"] = "把盏",
  [":steam__bazhan"] = "转换技，出牌阶段限一次，你可以{阳：交给；阴：获得}一名其他角色两张牌；若含<font color='red'>♥</font>牌，令失去牌的角色视为使用回复体力的【酒】。",
  ["#steam__bazhan-yang"] = "把盏（阳）：选择2张手牌，交给一名其他角色",
  ["#steam__bazhan-yin"] = "把盏（阴）：选择一名有至少2张牌的其他角色，获得其2张牌",

  ["$steam__bazhan1"] = "此酒，当配将军。",
  ["$steam__bazhan2"] = "这杯酒，敬于将军。",
}

local jiaoying = fk.CreateTriggerSkill{
  name = "steam__jiaoying",
  events = {fk.AfterCardsMove},
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) then
      for _, move in ipairs(data) do
        if move.from == player.id and move.to and move.to ~= player.id and move.toArea == Card.PlayerHand
        and not player.room:getPlayerById(move.to).dead then
          for _, info in ipairs(move.moveInfo) do
            if info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip then
              return true
            end
          end
        end
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    for _, move in ipairs(data) do
      if move.from == player.id and move.to and move.to ~= player.id and move.toArea == Card.PlayerHand then
        local to = room:getPlayerById(move.to)
        if not to.dead then
          room:addTableMarkIfNeed(to, "steam__jiaoying_from-turn", player.id)
          for _, info in ipairs(move.moveInfo) do
            if info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip then
              local suit = Fk:getCardById(info.cardId):getSuitString(true)
              if suit ~= "log_nosuit" then
                room:addTableMarkIfNeed(to, "@steam__jiaoying-turn", suit)
              end
            end
          end
        end
      end
    end
  end,
}
local jiaoying_delay = fk.CreateTriggerSkill{
  name = "#steam__jiaoying_delay",
  events = {fk.CardUsing},
  frequency = Skill.Compulsory,
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:getMark("@steam__jiaoying-turn") ~= 0
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local targets = player:getTableMark("steam__jiaoying_from-turn")
    room:setPlayerMark(player, "@steam__jiaoying-turn", 0)
    room:setPlayerMark(player, "steam__jiaoying_from-turn", 0)
    for _, p in ipairs(room:getAlivePlayers()) do
      if not p.dead and table.contains(targets, p.id) then
        p:broadcastSkillInvoke(jiaoying.name)
        room:notifySkillInvoked(p, jiaoying.name, "drawcard")
        local x = 5 - p:getHandcardNum()
        if x > 0 then
          p:drawCards(x, jiaoying.name)
        end
      end
    end
  end,
}
local jiaoying_prohibit = fk.CreateProhibitSkill{
  name = "#steam__jiaoying_prohibit",
  prohibit_use = function(self, player, card)
    return table.contains(player:getTableMark("@steam__jiaoying-turn"), card:getSuitString(true))
  end,
}
jiaoying:addRelatedSkill(jiaoying_delay)
jiaoying:addRelatedSkill(jiaoying_prohibit)

fanyufeng:addSkill(jiaoying)

Fk:loadTranslationTable{
  ["steam__jiaoying"] = "醮影",
  ["#steam__jiaoying_delay"] = "醮影",
  [":steam__jiaoying"] = "锁定技，当其他角色获得你的牌后，令其本回合不能使用同花色的牌，直到其本回合下次使用牌，且此时你摸牌至五张。",
  ["@steam__jiaoying-turn"] = "醮影",

  ["$steam__jiaoying1"] = "独酌清醮，霓裳自舞。",
  ["$steam__jiaoying2"] = "醮影倩丽，何人爱怜。",
}

local huaman = General:new(extension, "steam__huaman", "shu", 3, 3, General.Female)
Fk:loadTranslationTable{
  ["steam__huaman"] = "花鬘",
  ["#steam__huaman"] = "折花系君",
  ["cv:steam__huaman"] = "官方",
  ["designer:steam__huaman"] = "辛涟月",
  ["illustrator:steam__huaman"] = "alien",
  
  ["~steam__huaman"] = "战事已定，吾愿终亦得偿……",
}

local steam__xizhan = fk.CreateTriggerSkill{
  name = "steam__xizhan",
  anim_type = "offensive",
  events = {fk.TurnStart, fk.EnterDying, fk.AfterCardsMove},
  can_trigger = function(self, event, target, player, data)
    local mark = player:getTableMark("@steam__xizhan")
    if event == fk.TurnStart then
      return player:hasSkill(self) and table.contains(mark, "①") and not target:isAllNude()
    elseif event == fk.EnterDying then
      return player:hasSkill(self) and table.contains(mark, "②") and not target:isAllNude()
    elseif event == fk.AfterCardsMove then
      for _, move in ipairs(data) do
        if move.to and (move.toArea == Player.Hand or move.toArea == Player.Equip) and move.moveReason == fk.ReasonDraw 
        and not player.room:getPlayerById(move.to).dead and not player.room:getPlayerById(move.to):isNude() then
          return player:hasSkill(self) and table.contains(mark, "③")
        end
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    if event == fk.TurnStart then
      return player.room:askForSkillInvoke(player, self.name, nil, "#steam__xizhan1-ask::"..target.id)
    elseif event == fk.EnterDying then
      return player.room:askForSkillInvoke(player, self.name, nil, "#steam__xizhan2-ask::"..target.id)
    elseif event == fk.AfterCardsMove then
      for _, move in ipairs(data) do
        return player.room:askForSkillInvoke(player, self.name, nil, "#steam__xizhan3-ask::"..move.to)
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local analeptic = Fk:cloneCard("analeptic")
    if event == fk.TurnStart then
      room:removeTableMark(player, "@steam__xizhan", "①")
      local card = room:askForCardsChosen(player, target, 1, 1, "he", self.name, "#steam__xizhan_show")
      player:showCards(card)
      if not target.dead then  
        if Fk:getCardById(card[1]).is_damage_card then
          if not target:isProhibited(target, analeptic) then
            analeptic.skillName = self.name
            analeptic:addSubcard(Fk:getCardById(card[1]))
            local use = {
              from = target.id,
              tos = {{target.id}},
              card = analeptic,
              extraUse = true,
            }
            room:useCard(use)
          end
        elseif not target:isNude() then
          local toget = room:askForCardsChosen(player, target, 1, 1, "he", self.name, "#steam__xizhan_toget")
          room:moveCardTo(toget, Card.PlayerHand, player, fk.ReasonPrey, self.name, nil, false, player.id)
        end
      end
    elseif event == fk.EnterDying then
      room:removeTableMark(player, "@steam__xizhan", "②")
      local card = room:askForCardsChosen(player, target, 1, 1, "he", self.name, "#steam__xizhan_show")
      player:showCards(card)
      if not target.dead then
        if Fk:getCardById(card[1]).color == Card.Black then
          if not target:isProhibited(target, analeptic) then
            analeptic.skillName = self.name
            analeptic:addSubcard(Fk:getCardById(card[1]))
            local use = {
              from = target.id,
              tos = {{target.id}},
              card = analeptic,
              extra_data = { analepticRecover = true },
              extraUse = true,
            }
            room:useCard(use)
          end
        elseif not target:isNude() then
          local toget = room:askForCardsChosen(player, target, 1, 1, "he", self.name, "#steam__xizhan_toget")
          room:moveCardTo(toget, Card.PlayerHand, player, fk.ReasonPrey, self.name, nil, false, player.id)
        end   
      end
    elseif event == fk.AfterCardsMove then
      room:removeTableMark(player, "@steam__xizhan", "③")
      for _, move in ipairs(data) do
        local card = room:askForCardsChosen(player, room:getPlayerById(move.to), 1, 1, "he", self.name, "#steam__xizhan_show")
        player:showCards(card)
        if not room:getPlayerById(move.to).dead then
          if Fk:getCardById(card[1]).type == Card.TypeBasic then
            if not room:getPlayerById(move.to):isProhibited(room:getPlayerById(move.to), analeptic) then
              analeptic.skillName = self.name
              analeptic:addSubcard(Fk:getCardById(card[1]))
              local use = {
                from = move.to,
                tos = {{move.to}},
                card = analeptic,
                extraUse = true,
              }
              room:useCard(use)
            end
          elseif not room:getPlayerById(move.to):isNude() then
            local toget = room:askForCardsChosen(player, room:getPlayerById(move.to), 1, 1, "he", self.name, "#steam__xizhan_toget")
            room:moveCardTo(toget, Card.PlayerHand, player, fk.ReasonPrey, self.name, nil, false, player.id)
          end
        end
      end
    end
  end,

  refresh_events = {fk.RoundStart},
  can_refresh = function (self, event, target, player, data)
    return player:hasSkill(self)
  end,
  on_refresh = function (self, event, target, player, data)
    player.room:setPlayerMark(player, "@steam__xizhan", {"①", "②", "③"})
  end,

  on_acquire = function (self, player, is_start)
    player.room:setPlayerMark(player, "@steam__xizhan", {"①", "②", "③"})
  end,

  on_lose = function (self, player, is_death)
    player.room:setPlayerMark(player, "@steam__xizhan", 0)
  end,
}

Fk:loadTranslationTable{
  ["steam__xizhan"] = "嬉战",
  [":steam__xizhan"] = "每轮每项限一次，当一名角色回合开始/濒死/摸牌时，你可以展示其一张牌，若为伤害/黑色/基本牌，其将之当【酒】使用，否则你获得其一张牌。",

  ["@steam__xizhan"] = "嬉战",
  ["#steam__xizhan1-ask"] = "嬉战：是否展示 %dest 一张牌，若为伤害牌，其将之当【酒】使用，否则你获得其一张牌。",
  ["#steam__xizhan2-ask"] = "嬉战：是否展示 %dest 一张牌，若为黑色牌，其将之当【酒】使用，否则你获得其一张牌。",
  ["#steam__xizhan3-ask"] = "嬉战：是否展示 %dest 一张牌，若为基本牌，其将之当【酒】使用，否则你获得其一张牌。",
  ["#steam__xizhan_show"] = "嬉战：请展示其一张牌",
  ["#steam__xizhan_toget"] = "嬉战：请获得其一张牌",

  ["$steam__xizhan1"] = "战场纵非玩乐之所，尔等又能奈我何？",
  ["$steam__xizhan2"] = "哎呀~母亲放心，鬘儿不会捣乱的。",
  ["$steam__xizhan3"] = "嘻嘻，这样才好玩嘛。",
}

local steam__chanyuan = fk.CreateTriggerSkill{
  name = "steam__chanyuan",
  mute = true,
  anim_type = "defensive",
  events = {fk.PreCardEffect},
  can_trigger = function(self, event, target, player, data)
    if data.card.trueName == "slash" and not data.unoffsetable and not data.disresponsive then
    return data.to == player.id and (player.room:getPlayerById(data.from):hasSkill(self) or (player:hasSkill(self) and data.from ~= player.id)) and
      not table.contains(data.unoffsetableList or {}, player.id) and not table.contains(data.disresponsiveList or {}, player.id)
    end
  end,
  on_cost = function(self, event, target, player, data)
    if player.room:getPlayerById(data.from):hasSkill(self) then
      return player.room:askForSkillInvoke(player, self.name, nil, "#steam__chanyuan1-ask::"..data.from)
    elseif player:hasSkill(self) and data.from ~= player.id then
      return player.room:askForSkillInvoke(player, self.name, nil, "#steam__chanyuan2-ask::"..data.from)
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    room:notifySkillInvoked(player, self.name, "defensive")
    player:broadcastSkillInvoke(self.name, math.random(2))
    local cards = room:getCardsFromPileByRule(".|.|club,spade", 1)
    if #cards > 0 then
      if player.room:getPlayerById(data.from):hasSkill(self) then
        room:setPlayerMark(room:getPlayerById(data.from), "@@steam__chanyuan", 1)
      elseif player:hasSkill(self) and data.from ~= player.id then
        room:setPlayerMark(player, "@@steam__chanyuan", 1)
      end
      room:obtainCard(player, cards[1], true, fk.ReasonJustMove, player.id, self.name)
      return true
    end
  end,

  refresh_events = {fk.CardUseFinished},
  can_refresh = function (self, event, target, player, data)
    return player:hasSkill(self, true) and not player:hasSkill(self) and (data.card.trueName == "savage_assault" or data.card.trueName == "duel")
    and player:getMark("@@steam__chanyuan") > 0
  end,
  on_refresh = function (self, event, target, player, data)
    player:broadcastSkillInvoke(self.name, math.random(3, 4))
    player.room:setPlayerMark(player, "@@steam__chanyuan", 0)
    player:drawCards(1, self.name)
    if not target.dead then
      target:drawCards(1, self.name)
    end
  end,
}
local steam__chanyuan_invalidity = fk.CreateInvaliditySkill{
  name = "#steam__chanyuan_invalidity",
  invalidity_func = function(self, from, skill)
    return skill == steam__chanyuan and from:getMark("@@steam__chanyuan") > 0
  end
}

Fk:loadTranslationTable{
  ["steam__chanyuan"] = "缠缘",
  [":steam__chanyuan"] = "你需抵消一名角色的【杀】或一名角色需抵消你的【杀】时，需要响应者可检索一张黑色牌并视为抵消之，然后此技能失效至（【南蛮入侵】或【决斗】结算后，"..
  "你与此【南蛮入侵】或【决斗】的使用者各摸一张牌。）",

  ["@@steam__chanyuan"] = "缠缘失效",
  ["#steam__chanyuan1-ask"] = "缠缘：是否发动 %dest 的缠缘，检索一张黑色牌抵消此【杀】？",
  ["#steam__chanyuan2-ask"] = "缠缘：是否发动缠缘，检索一张黑色牌抵消 %dest 的【杀】？",

  ["$steam__chanyuan1"] = "一战结缘难再许，痛为大义斩此情！",
  ["$steam__chanyuan2"] = "将军处处留情，小女芳心暗许。",
  ["$steam__chanyuan3"] = "象兵便可退敌，何劳本姑娘亲往？",
  ["$steam__chanyuan4"] = "哼！象阵所至，尽皆纷乱之师。",
}

steam__chanyuan:addRelatedSkill(steam__chanyuan_invalidity)
huaman:addSkill(steam__xizhan)
huaman:addSkill(steam__chanyuan)

return extension
