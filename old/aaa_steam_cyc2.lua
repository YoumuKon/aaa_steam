local extension = Package("aaa_steam_cyc2")
extension.extensionName = "aaa_steam"

local U = require "packages/utility/utility"
local DIY = require "packages/diy_utility/diy_utility"

Fk:loadTranslationTable{
  ["aaa_steam_cyc2"] = "嘭！！",
}






local thresh = General:new(extension, "steam__thresh", "west", 4)
local death_sentence = fk.CreateActiveSkill{
  name = "steam__death_sentence",
  mute = true,
  card_num = 1,
  min_target_num = 0,
  prompt = "#steam__death_sentence",
  can_use = Util.TrueFunc,
  card_filter = function(self, to_select, selected, selected_targets)
    return #selected == 0 and Fk:getCardById(to_select).suit == Card.Club
  end,
  target_filter = function(self, to_select, selected, selected_cards, _, _, player)
    if #selected_cards == 1 then
      local card = Fk:cloneCard("iron_chain")
      card:addSubcard(selected_cards[1])
      card.skillName = self.name
      return player:canUse(card) and card.skill:targetFilter(to_select, selected, selected_cards, card, nil, player)
    end
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    player:broadcastSkillInvoke(self.name, math.random(2))
    if #effect.tos == 0 then
      room:notifySkillInvoked(player, self.name, "drawcard")
      room:recastCard(effect.cards, player, self.name)
    else
      room:notifySkillInvoked(player, self.name, "control")
      room:sortPlayersByAction(effect.tos)
      room:useVirtualCard("iron_chain", effect.cards, player, table.map(effect.tos, Util.Id2PlayerMapper), self.name)
    end
  end,
}
local death_sentence_trigger = fk.CreateTriggerSkill{
  name = "#steam__death_sentence_trigger",
  anim_type = "control",
  events = {fk.AfterCardsMove},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(death_sentence) then
      local dat = {}
      for _, move in ipairs(data) do
        if move.to and player.room:getPlayerById(move.to).chained and move.toArea == Card.PlayerHand then
          dat[move.to] = (dat[move.to] or 0) + #move.moveInfo
        end
      end
      local targets = {}
      for id, count in pairs(dat) do
        if count > 1 then
          table.insertIfNeed(targets, id)
        end
      end
      if #targets > 0 then
        self.cost_data = targets
        return true
      end
    end
  end,
  on_trigger = function (self, event, target, player, data)
    local room = player.room
    local targets = table.simpleClone(self.cost_data)
    for _, id in ipairs(targets) do
      if not player:hasSkill(death_sentence) then return end
      local p = room:getPlayerById(id)
      if not p.dead then
        self:doCost(event, p, player, data)
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    if player.room:askForSkillInvoke(player, "steam__death_sentence", nil, "#steam__death_sentence-invoke::"..target.id) then
      self.cost_data = {tos = {target.id}}
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke("steam__death_sentence", math.random(3, 4))
    player:drawCards(1, "steam__death_sentence")
    if player.dead or target.dead or target:isNude() or (target == player and #player:getCardIds("e") == 0) then return end
    local flag = target == player and "e" or "he"
    local card = room:askForCardChosen(player, target, flag, "steam__death_sentence", "#steam__death_sentence-prey::"..target.id)
    room:moveCardTo(card, Card.PlayerHand, player, fk.ReasonPrey, "steam__death_sentence", nil, false, player.id)
    if player.dead or player:isNude() or target.dead or target == player then return end
    card = room:askForCard(player, 1, 1, true, "steam__death_sentence", false, nil, "#steam__death_sentence-give::"..target.id)
    room:moveCardTo(card, Card.PlayerHand, target, fk.ReasonGive, "steam__death_sentence", nil, false, player.id)
  end,
}
local death_from_below = fk.CreateTriggerSkill{
  name = "steam__death_from_below",
  anim_type = "control",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and target.chained and target ~= player and target.phase == Player.Start and
      player:usedSkillTimes(self.name, Player.HistoryRound) == 0
  end,
  on_cost = function(self, event, target, player, data)
    if player.room:askForSkillInvoke(player, self.name, data, "#steam__death_from_below-invoke::"..target.id) then
      self.cost_data = {tos = {target.id}}
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:drawCards(1, self.name)
    if player.dead or target.dead or not player:canPindian(target) then return end
    local pindian = player:pindian({target}, self.name)
    if player.dead or target.dead then return end
    if pindian.results[target.id].winner == player then
      local choice = room:askForChoice(player, {"right", "left"}, self.name, "#steam__death_from_below-choice::"..target.id)
      room:setPlayerMark(target, "@!steam__"..choice.."-turn", 1)
    elseif room:askForSkillInvoke(player, self.name, nil, "#steam__death_from_below-draw::"..target.id) then
      player:setSkillUseHistory(self.name, 0, Player.HistoryRound)
      target:drawCards(2, self.name)
    end
  end
}
local function distanceTo(from, other, mode)
  mode = mode or "both"
  if other == from then return 0 end
  if from:isRemoved() or other:isRemoved() then
    return -1
  end
  local right = 0
  local temp = from
  local try_time = 10
  for _ = 0, try_time do
    if temp == other then break end
    if not temp.dead and not temp:isRemoved() then
      right = right + 1
    end
    temp = temp.next
  end
  if temp ~= other then
    print("Distance malfunction: start and end does not match.")
  end
  local left = #Fk:currentRoom().alive_players - right - #table.filter(Fk:currentRoom().alive_players, function(p)
    return p:isRemoved()
  end)
  local ret = 0
  if mode == "left" then
    ret = left
  elseif mode == "right" then
    ret = right
  else
    ret = math.min(left, right)
  end

  local status_skills = Fk:currentRoom().status_skills[DistanceSkill] or Util.DummyTable
  for _, skill in ipairs(status_skills) do
    if skill.name ~= "#steam__death_from_below_distance" then
      local fixed = skill:getFixed(from, other)
      local correct = skill:getCorrect(from, other)
      if fixed ~= nil then
        ret = fixed
        break
      end
      ret = ret + (correct or 0)
    end
  end

  if from.fixedDistance[other] then
    ret = from.fixedDistance[other]
  end

  return math.max(ret, 1)
end
local death_from_below_distance = fk.CreateDistanceSkill{
  name = "#steam__death_from_below_distance",
  fixed_func = function(self, from, to)
    if from:getMark("@!steam__right-turn") > 0 then
      return distanceTo(from, to, "right")
    elseif from:getMark("@!steam__left-turn") > 0 then
      return distanceTo(from, to, "left")
    end
  end,
}
death_sentence:addRelatedSkill(death_sentence_trigger)
death_from_below:addRelatedSkill(death_from_below_distance)
thresh:addSkill(death_sentence)
thresh:addSkill(death_from_below)
Fk:loadTranslationTable{
  ["steam__thresh"] = "锤石",
  ["#steam__thresh"] = "魂锁典狱长",
  ["illustrator:steam__thresh"] = "Victor Maury",
  ["designer:steam__thresh"] = "cyc",

  ["steam__death_sentence"] = "死亡判决",
  [":steam__death_sentence"] = "你可以将一张♣牌当【铁索连环】使用或重铸。一名横置角色一次性获得至少两张牌后，你可以摸一张牌并获得其一张牌，"..
  "再交给其一张牌。",
  ["steam__death_from_below"] = "厄运钟摆",
  [":steam__death_from_below"] = "轮次技，其他横置角色的出牌阶段开始时，你可以摸一张牌并与其拼点：若你赢，你令其本回合仅能从一个方向计算距离；"..
  "若你没赢，你可以令其摸两张牌，重置本技能。",
  ["#steam__death_sentence"] = "死亡判决：你可以将一张♣牌当【铁索连环】使用或重铸",
  ["#steam__death_sentence_trigger"] = "死亡判决",
  ["#steam__death_sentence-invoke"] = "死亡判决：是否摸一张牌并获得 %dest 一张牌，然后交给其一张牌？",
  ["#steam__death_sentence-prey"] = "死亡判决：获得 %dest 一张牌",
  ["#steam__death_sentence-give"] = "死亡判决：请交给 %dest 一张牌",
  ["#steam__death_from_below-invoke"] = "厄运钟摆：是否摸一张牌并与 %dest 拼点？",
  ["#steam__death_from_below-choice"] = "厄运钟摆：令 %dest 本回合只能从一个方向计算距离",
  ["#steam__death_from_below-draw"] = "厄运钟摆：是否令 %dest 摸两张牌，你重置此技能？",

  ["$steam__death_sentence1"] = "把他们关起来~", -- (铁索连环)
  ["$steam__death_sentence2"] = "没有人能拯救他们。", -- (铁索连环)
  ["$steam__death_sentence3"] = "没有人可以逃脱~", -- (获得牌)
  ["$steam__death_sentence4"] = "我们要怎样进行这令人愉悦的折磨呢?", -- (获得牌)
  ["$steam__death_from_below1"] = "这边儿~",
  ["$steam__death_from_below2"] = "我们走起来~",
  ["~steam__thresh"] = "我，疯了？很有可能——",
}




local sylas = General:new(extension, "steam__sylas", "west", 4)
local petricite_burst = fk.CreateActiveSkill{
  name = "steam__petricite_burst",
  card_num = 1,
  min_target_num = 0,
  max_target_num = 2,
  prompt = "#steam__petricite_burst",
  interaction = function(self)
    local all_names = U.getAllCardNames("t")
    local names = U.getViewAsCardNames(Self, self.name, all_names, nil, {"iron_chain"})
    if #names > 0 then
      return U.CardNameBox { choices = names, all_choices = all_names }
    end
  end,
  card_filter = function(self, to_select, selected)
    return #selected == 0 and Fk:getCardById(to_select, true).trueName == "iron_chain"
  end,
  target_filter = function (self, to_select, selected, selected_cards, _, _, player)
    if #selected_cards == 1 and self.interaction.data and #selected < 2 then
      local card = Fk:cloneCard(self.interaction.data)
      card.skillName = self.name
      card:addSubcards(selected_cards)
      if card.name == "collateral" or (not card.skill.target_num and not card.multiple_targets) then
        return card.skill:targetFilter(to_select, selected, {}, card, nil, player)
      else
        if Self:canUseTo(card, Fk:currentRoom():getPlayerById(to_select)) then
          if card.multiple_targets then
            return true
          else
            return #selected == 0
          end
        end
      end
    end
  end,
  feasible = function (self, selected, selected_cards)
    if #selected_cards == 1 and self.interaction.data then
      local card = Fk:cloneCard(self.interaction.data)
      card.skillName = self.name
      card:addSubcards(selected_cards)
      if card.name == "collateral" or (not card.skill.target_num and not card.multiple_targets) then
        return card.skill:feasible(selected, {}, Self, card)
      else
        return #selected > 0 and table.every(selected, function (id)
          return Self:canUseTo(card, Fk:currentRoom():getPlayerById(id))
        end)
      end
    end
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local card = Fk:cloneCard(self.interaction.data)
    card.skillName = self.name
    card:addSubcards(effect.cards)
    if self.interaction.data == "collateral" then
      room:useCard{
        from = player.id,
        tos = table.map(effect.tos, function (id) return {id} end),
        card = card,
      }
    elseif #effect.tos > 0 then
      room:sortPlayersByAction(effect.tos)
      room:useVirtualCard(self.interaction.data, effect.cards, player, table.map(effect.tos, Util.Id2PlayerMapper), self.name)
    else
      room:useCard{
        from = player.id,
        card = card,
      }
    end
  end,
}
local petricite_burst_trigger = fk.CreateTriggerSkill{
  name = "#steam__petricite_burst_trigger",
  anim_type = "offensive",
  frequency = Skill.Compulsory,
  events = {fk.CardUseFinished},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(petricite_burst) and
      not (data.card.type == Card.TypeBasic or data.card:isCommonTrick())
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local name = "iron_chain"
    if player:getMark("steam__petricite_burst-turn") ~= 0 then
      name = player:getMark("steam__petricite_burst-turn")
    end
    local card = Fk:cloneCard(name)
    card.skillName = "steam__petricite_burst"
    if player:canUse(card) then
      local use = U.askForUseVirtualCard(room, player, name, nil, "steam__petricite_burst",
        "#steam__petricite_burst-use:::"..name, true)
      if not use then
        player:drawCards(1, "steam__petricite_burst")
      end
    else
      player:drawCards(1, "steam__petricite_burst")
    end
  end,
}
local petricite_burst_filter = fk.CreateFilterSkill{
  name = "#steam__petricite_burst_filter",
  card_filter = function(self, card, player, isJudgeEvent)
    return player:hasSkill(petricite_burst) and card.trueName == "iron_chain" and table.contains(player:getCardIds("h"), card.id)
  end,
  view_as = function(self, card, player)
    return Fk:cloneCard("nullification", card.suit, card.number)
  end,
}
local hijack = fk.CreateActiveSkill{
  name = "steam__hijack",
  anim_type = "control",
  card_num = 0,
  target_num = 1,
  prompt = "#steam__hijack",
  can_use = function(self, player)
    return player:getMark("@@rfenghou_readying:::"..self.name) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, to_select, selected, selected_cards)
    return #selected == 0 and to_select ~= Self.id and not Fk:currentRoom():getPlayerById(to_select):isKongcheng()
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    local cards1 = room:askForCardsChosen(player, target, 1, 3, "h", self.name, "#steam__hijack-show::"..target.id)
    target:showCards(cards1)
    local cards2 = {}
    if #cards1 < 3 then
      cards2 = room:getNCards(3 - #cards1)
      room:moveCardTo(cards2, Card.Processing, nil, fk.ReasonJustMove, self.name, nil, true, player.id)
    end
    local all_cards = table.simpleClone(cards1)
    table.insertTable(all_cards, table.simpleClone(cards2))
    local choices = table.filter(all_cards, function (id)
      local card = Fk:getCardById(id)
      return card.type == Card.TypeBasic or card:isCommonTrick()
    end)
    if #choices > 0 then
      local ids = U.askforChooseCardsAndChoice(player, choices, {"OK"}, self.name, "#steam__hijack-choice", nil, 1, 1, all_cards)
      room:setPlayerMark(player, "steam__petricite_burst-turn", Fk:getCardById(ids[1]).name)
      table.removeOne(all_cards, ids[1])
    end
    room:moveCardTo(all_cards, Card.PlayerHand, player, fk.ReasonPrey, self.name, nil, true, player.id)
  end,
}
hijack.RfenghouReadySkill = true
petricite_burst:addRelatedSkill(petricite_burst_trigger)
petricite_burst:addRelatedSkill(petricite_burst_filter)
sylas:addSkill(petricite_burst)
sylas:addSkill(hijack)
Fk:loadTranslationTable{
  ["steam__sylas"] = "塞拉斯",
  ["#steam__sylas"] = "解脱者",
  ["illustrator:steam__sylas"] = "Victor Maury",
  ["designer:steam__sylas"] = "cyc",

  ["steam__petricite_burst"] = "破敌禁法",
  [":steam__petricite_burst"] = "锁定技，你的实体【铁索连环】仅能视为任意其他普通锦囊牌（最多指定两名目标）。你使用一张非即时牌后，视为使用一张"..
  "【铁索连环】或摸一张牌。",
  ["steam__hijack"] = "其人之道",
  [":steam__hijack"] = "<a href='rfenghou_ready_skill'>蓄势技</a>，出牌阶段，你可以展示牌堆顶与一名其他角色手牌中共计三张牌。"..
  "你选择其中一张即时牌，令本回合〖破敌禁法〗视为使用的牌名改为该牌牌名，然后你获得其余的展示牌。",
  ["#steam__petricite_burst"] = "破敌禁法：将【铁索连环】改为其他普通锦囊牌使用（最多指定两名目标）",
  ["#steam__petricite_burst_trigger"] = "破敌禁法",
  ["#steam__petricite_burst-use"] = "破敌禁法：视为使用【%arg】，或点“取消”摸一张牌",
  ["#steam__petricite_burst_filter"] = "破敌禁法",
  ["@@rfenghou_readying:::steam__hijack"] = "其人之道 蓄势中",
  ["#steam__hijack"] = "其人之道：展示牌堆顶与一名角色手牌共计三张牌，选择其中一张为“破敌禁法”本回合视为牌名，获得其余牌",
  ["#steam__hijack-show"] = "其人之道：展示 %dest 至多三张手牌",
  ["#steam__hijack-choice"] = "其人之道：选择其中一张为“破敌禁法”本回合视为牌名，获得其余牌",

  ["$steam__petricite_burst1"] = "每一环铁链，都在为反抗添砖加瓦！",
  ["$steam__petricite_burst2"] = "阴沟和地牢，再也不会有了！",
  ["$steam__petricite_burst3"] = "欲有建设，必先破坏！",
  ["$steam__hijack1"] = "会还给你的，我保证——",
  ["$steam__hijack2"] = "交出来吧！",
  ["$steam__hijack3"] = "你的就是我的！",
  ["~steam__sylas"] = "终于，不再有墙了…",
}

local janna = General:new(extension, "steam__janna", "west", 3, 3, General.Female)
local tailwind = fk.CreateTriggerSkill{
  name = "steam__tailwind",
  anim_type = "support",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and target.phase == Player.Play and not target:isNude() and not target.dead
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    if target == player then
      if room:askForSkillInvoke(player, self.name, nil, "#steam__tailwind-self") then
        self.cost_data = nil
        return true
      end
    else
      local card = room:askForCard(target, 1, 1, true, self.name, true, nil, "#steam__tailwind-invoke:"..player.id)
      if #card > 0 then
        self.cost_data = {tos = {player.id}, cards = card}
        return true
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if target ~= player then
      room:moveCardTo(self.cost_data.cards, Card.PlayerHand, player, fk.ReasonGive, self.name, nil, false, target.id)
    end
    local judge = {
      who = target,
      reason = self.name,
      pattern = ".",
    }
    room:judge(judge)
    if target.dead then return end
    room:addTableMarkIfNeed(target, "@steam__tailwind-turn", judge.card:getColorString())
    if not player.dead and not player:isNude() then
      local pattern
      if judge.card.color == Card.Red then
        pattern = ".|.|heart,diamond"
      elseif judge.card.color == Card.Black then
        pattern = ".|.|spade,club"
      else
        return
      end
      local card = room:askForCard(player, 1, 1, true, self.name, true, pattern,
        "#steam__tailwind-give::"..target.id..":"..judge.card:getColorString())
      if #card > 0 then
        if target ~= player then
          room:moveCardTo(card, Card.PlayerHand, target, fk.ReasonGive, self.name, nil, false, player.id)
        end
        if not player.dead then
          player:drawCards(1, self.name)
        end
      end
    end
  end,
}
local tailwind_targetmod = fk.CreateTargetModSkill{
  name = "#steam__tailwind_targetmod",
  bypass_distances =  function(self, player, skill, card)
    return card and table.contains(player:getTableMark("@steam__tailwind-turn"), card:getColorString())
  end,
}
local eye_of_storm = fk.CreateTriggerSkill{
  name = "steam__eye_of_storm",
  anim_type = "support",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Discard and not player:isNude() and
      #player.room:getOtherPlayers(player) > 0 and
      not table.find(player.room.alive_players, function (p)
        return p:getMark(self.name) ~= 0
      end)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local success, dat = room:askForUseActiveSkill(player, "steam__eye_of_storm_active", "#steam__eye_of_storm-invoke", true)
    if success and dat then
      self.cost_data = {tos = dat.targets, cards = dat.cards, choice = dat.interaction}
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(self.cost_data.tos[1])
    room:setPlayerMark(to, self.name, self.cost_data.choice)
    player:addToPile("$steam__eye_of_storm", self.cost_data.cards, false, self.name, player.id)
  end,

  refresh_events = {fk.Death},
  can_refresh = function (self, event, target, player, data)
    return target == player and (player:getMark(self.name) ~= 0 or #player:getPile("$steam__eye_of_storm") > 0)
  end,
  on_refresh = function (self, event, target, player, data)
    local room = player.room
    for _, p in ipairs(room:getAlivePlayers()) do
      room:setPlayerMark(p, self.name, 0)
      room:moveCardTo(p:getPile("$steam__eye_of_storm"), Card.DiscardPile, nil, fk.ReasonPutIntoDiscardPile)
    end
  end,
}
local eye_of_storm_trigger = fk.CreateTriggerSkill{
  name = "#steam__eye_of_storm_trigger",
  anim_type = "support",
  events = {fk.TurnEnd},
  can_trigger = function(self, event, target, player, data)
    return player:getMark("steam__eye_of_storm") ~= 0 and
      table.find(player.room.alive_players, function (p)
        return #p:getPile("$steam__eye_of_storm") > 0
      end)
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local p = table.find(room.alive_players, function (p)
      return #p:getPile("$steam__eye_of_storm") > 0
    end)
    if not table.find(room.players, function (q)
      return q:usedSkillTimes("steam__eye_of_storm", Player.HistoryTurn) > 0
    end) then
      p:addToPile("$steam__eye_of_storm", room:getNCards(1), false, "steam__eye_of_storm", player.id)
      if #p:getPile("$steam__eye_of_storm") == 0 then return end
    end
    local to = player:getMark("steam__eye_of_storm") == "right" and p:getNextAlive(true) or p:getLastAlive(true)
    if to == player then
      room:setPlayerMark(player, "steam__eye_of_storm", 0)
      room:moveCardTo(p:getPile("$steam__eye_of_storm"), Card.PlayerHand, player, fk.ReasonJustMove,
        "steam__eye_of_storm", nil, false, player.id)
    else
      to:addToPile("$steam__eye_of_storm", p:getPile("$steam__eye_of_storm"), false, "steam__eye_of_storm", player.id)
    end
  end,
}
local eye_of_storm_active = fk.CreateActiveSkill{
  name = "steam__eye_of_storm_active",
  min_card_num = 1,
  max_card_num = 3,
  target_num = 1,
  interaction = UI.ComboBox { choices = {"right", "left"} },
  card_filter = function (self, to_select, selected)
    return #selected < 3
  end,
  target_filter = function (self, to_select, selected)
    return #selected == 0 and to_select ~= Self.id
  end,
}
tailwind:addRelatedSkill(tailwind_targetmod)
Fk:addSkill(eye_of_storm_active)
eye_of_storm:addRelatedSkill(eye_of_storm_trigger)
janna:addSkill(tailwind)
janna:addSkill(eye_of_storm)
Fk:loadTranslationTable{
  ["steam__janna"] = "迦娜",
  ["#steam__janna"] = "风暴之怒",
  ["illustrator:steam__janna"] = "Jason Chan",
  ["designer:steam__janna"] = "cyc",

  ["steam__tailwind"] = "顺风而行",
  [":steam__tailwind"] = "一名角色的出牌阶段开始时，其可以交给你一张牌并判定（若为你跳过交给流程）：其本回合使用与结果同色的牌无距离限制，"..
  "然后你可以交给其一张与结果同色的牌并摸一张牌。",
  ["steam__eye_of_storm"] = "风暴之眼",
  [":steam__eye_of_storm"] = "弃牌阶段开始时，你可以移出至多三张牌，选择一名其他角色，再选择一个方向。每回合结束时，移出的牌按所选方向向"..
  "该角色移动一个座次（若当前回合角色未发动〖顺风而行〗，将牌堆顶的一张牌加入移出牌中），抵达该角色后，其获得这些牌。",
  ["#steam__tailwind-self"] = "顺风而行：是否进行判定？",
  ["#steam__tailwind-invoke"] = "顺风而行：是否交给 %src 一张牌并进行判定？你本回合使用判定颜色牌无距离限制",
  ["#steam__tailwind-give"] = "顺风而行：是否交给 %dest 一张%arg牌并摸一张牌？",
  ["@steam__tailwind-turn"] = "顺风而行",
  ["steam__eye_of_storm_active"] = "风暴之眼",
  ["#steam__eye_of_storm-invoke"] = "风暴之眼：选择目标角色和方向，将至多三张牌移出游戏，当这些牌抵达其后其获得这些牌",
  ["$steam__eye_of_storm"] = "风暴之眼",
  ["#steam__eye_of_storm_trigger"] = "风暴之眼",

  ["$steam__tailwind1"] = "如你所愿。",
  ["$steam__tailwind2"] = "风啊，带我一程吧。",
  ["$steam__eye_of_storm1"] = "风暴就要来临了——",
  ["$steam__eye_of_storm2"] = "你还以为他只是一阵无害的微风吗？",
  ["~steam__janna"] = "真理之意，与我同在……",
}

local nocturne = General:new(extension, "steam__nocturne", "west", 4)
local getShade = function (room, n)
  local ids = {}
  local name
  if Fk.all_card_types["shade"] then
    name = "shade"
  elseif Fk.all_card_types["rfenghou__shade"] then
    name = "rfenghou__shade"
  end
  assert(name, "服务器未加入【影】！请联系管理员安装“江山如故”或“封侯”包")
  for _, id in ipairs(room.void) do
    if n <= 0 then break end
    if Fk:getCardById(id).name == name then
      room:setCardMark(Fk:getCardById(id), MarkEnum.DestructIntoDiscard, 1)
      table.insert(ids, id)
      n = n - 1
    end
  end
  while n > 0 do
    local card = room:printCard(name, Card.Spade, 1)
    room:setCardMark(card, MarkEnum.DestructIntoDiscard, 1)
    table.insert(ids, card.id)
    n = n - 1
  end
  return ids
end
local shadow_assault = fk.CreateTriggerSkill{
  name = "steam__shadow_assault",
  anim_type = "control",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Start
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local to = room:askForChoosePlayers(player, table.map(room.alive_players, Util.IdMapper), 1, 1,
      "#steam__shadow_assault-choose", self.name, true)
    if #to > 0 then
      self.cost_data = {tos = to}
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(self.cost_data.tos[1])
    room:setPlayerMark(player, self.name, to.id)
    room:moveCardTo(getShade(room, 3), Card.PlayerHand, to, fk.ReasonJustMove, self.name, nil, true, player.id)
  end,

  refresh_events = {fk.TurnStart},
  can_refresh = function (self, event, target, player, data)
    return target == player
  end,
  on_refresh = function (self, event, target, player, data)
    player.room:setPlayerMark(player, self.name, 0)
  end,
}
local shadow_assault_delay = fk.CreateTriggerSkill{
  name = "#steam__shadow_assault_delay",
  anim_type = "negative",
  events = {fk.CardUsing},
  can_trigger = function(self, event, target, player, data)
    return player:getMark("steam__shadow_assault") == target.id and
      table.find(target:getCardIds("h"), function (id)
        return Fk:getCardById(id).trueName == "shade"
      end)
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    local room = player.room
    room:doIndicate(player.id, {target.id})
    local card = table.filter(target:getCardIds("h"), function (id)
      return not target:prohibitDiscard(id)
    end)
    if #card == 0 then return end
    card = table.random(card)
    local yes = Fk:getCardById(card).trueName == "shade"
    room:throwCard(card, "steam__shadow_assault", target, target)
    if yes then
      data.tos = {}
    elseif not target.dead then
      card = table.filter(target:getCardIds("h"), function (id)
        return Fk:getCardById(id).trueName == "shade" and not target:prohibitDiscard(id)
      end)
      if #card > 0 then
        room:throwCard(card, "steam__shadow_assault", target, target)
        if not player.dead then
          player:drawCards(#card, "steam__shadow_assault")
        end
      end
    end
  end,
}
shadow_assault:addRelatedSkill(shadow_assault_delay)
nocturne:addSkill(shadow_assault)
Fk:loadTranslationTable{
  ["steam__nocturne"] = "魔腾",
  ["#steam__nocturne"] = "永恒梦魇",
  ["illustrator:steam__nocturne"] = "Francis Tneh",
  ["designer:steam__nocturne"] = "cyc",

  ["steam__shadow_assault"] = "鬼影重重",
  [":steam__shadow_assault"] = "准备阶段，你可以令一名角色获得三张【影】，直到你下回合开始，当其使用一张牌时，若其拥有【影】，"..
  "其随机弃置一张手牌：若为【影】，你令其使用的牌作废；否则，其弃置所有【影】，你摸等量的牌。",
  ["#steam__shadow_assault-choose"] = "鬼影重重：令一名角色获得三张【影】，其使用牌时随机弃置一张手牌",
  ["#steam__shadow_assault_delay"] = "鬼影重重",

  ["$steam__shadow_assault1"] = "拥抱黑暗吧！",
  ["$steam__shadow_assault2"] = "揭开帷幕！",
  ["~steam__nocturne"] = "哎呀，哎呀，哎吼，吼！",
}



local orianna = General:new(extension, "steam__orianna", "west", 3)
local concerto_of_the_loom = fk.CreateTriggerSkill{
  name = "steam__concerto_of_the_loom",
  anim_type = "special",
  frequency = Skill.Compulsory,
  events = {fk.RoundStart},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) and player.room:getCardArea(player:getMark(self.name)) ~= Card.PlayerEquip then
      local card = Fk:getCardById(player:getMark(self.name))
      return player:canUseTo(card, player)
    end
  end,
  on_use = function (self, event, target, player, data)
    local card = Fk:getCardById(player:getMark(self.name))
    player.room:useCard{
      from = player.id,
      tos = {{player.id}},
      card = card,
    }
  end,

  refresh_events = {fk.BeforeCardsMove},
  can_refresh = function(self, event, target, player, data)
    return player:hasSkill(self, true)
  end,
  on_refresh = function(self, event, target, player, data)
    local cancel_move = {}
    for _, move in ipairs(data) do
      if move.from and move.proposer and move.proposer ~= player.id and move.skillName ~= "rfenghou__wooden_ox_skill" then
        local move_info = {}
        for _, info in ipairs(move.moveInfo) do
          if info.cardId == player:getMark(self.name) and info.fromArea == Card.PlayerEquip then
            if not player.room:getPlayerById(move.from).dead then
              table.insert(cancel_move, info.cardId)
            end
          else
            table.insert(move_info, info)
          end
        end
        move.moveInfo = move_info
      end
    end
  end,

  on_acquire = function (self, player, is_start)
    local room = player.room
    local id = room:printCard("rfenghou__wooden_ox", Card.Diamond, 5).id
    room:setPlayerMark(player, self.name, id)
  end,
}
local concerto_of_the_loom_trigger = fk.CreateTriggerSkill{
  name = "#steam__concerto_of_the_loom_trigger",
  anim_type = "special",
  frequency = Skill.Compulsory,
  events = {fk.EventPhaseStart, fk.SkillEffect},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(concerto_of_the_loom) then
      if event == fk.EventPhaseStart then
        return target == player and player.phase == Player.Start
      elseif event == fk.SkillEffect then
        return data.name == "rfenghou__wooden_ox_skill" and
          table.contains(target:getCardIds("e"), player:getMark("steam__concerto_of_the_loom"))
      end
    end
  end,
  on_use = function (self, event, target, player, data)
    U.skillCharged(player, 1)
  end,
}
local order_defense = fk.CreateTriggerSkill{
  name = "steam__order_defense",
  events = {fk.Damaged},
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and player:getMark("skill_charge") > 0 and not target.dead and
      table.find(player.room.alive_players, function (p)
        return target:distanceTo(p) <= player:getMark("skill_charge") and
          table.contains(p:getCardIds("e"), player:getMark("steam__concerto_of_the_loom"))
      end)
  end,
  on_cost = function(self, event, target, player, data)
    local choices = {}
    for i = 1, math.min(player:getMark("skill_charge"), 2), 1 do
      table.insert(choices, tostring(i))
    end
    table.insert(choices, "Cancel")
    local choice = player.room:askForChoice(player, choices, self.name, "#steam__order_defense-invoke::"..target.id)
    if choice ~= "Cancel" then
      self.cost_data = {tos = {target.id}, choice = tonumber(choice)}
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local n = self.cost_data.choice
    U.skillCharged(player, -n)
    target:drawCards(n, self.name)
  end,

  on_acquire = function (self, player, is_start)
    U.skillCharged(player, 2, 3)
  end,
  on_lose = function (self, player, is_death)
    U.skillCharged(player, -2, -3)
  end,
}
local order_shock_wave = fk.CreateActiveSkill{
  name = "steam__order_shock_wave",
  anim_type = "control",
  card_num = 0,
  target_num = 1,
  prompt = "#steam__order_shock_wave",
  can_use = function(self, player)
    return player:getMark("skill_charge") > 0
  end,
  interaction = UI.ComboBox {choices = {
    "steam__order_shock_wave1",
    "steam__order_shock_wave2",
  }},
  card_filter = Util.FalseFunc,
  target_filter = function(self, to_select, selected)
    if #selected == 0 then
      local p = table.find(Fk:currentRoom().alive_players, function (p)
        return table.contains(p:getCardIds("e"), Self:getMark("steam__concerto_of_the_loom"))
      end)
      if p == nil then return end
      local target = Fk:currentRoom():getPlayerById(to_select)
      if self.interaction.data == "steam__order_shock_wave1" then
        if target:getNextAlive(true) == p or p:getNextAlive(true) == target then
          return p:canMoveCardInBoardTo(target, Self:getMark("steam__concerto_of_the_loom"))
        end
      elseif self.interaction.data == "steam__order_shock_wave2" then
        if #p:getPile("$role_carriage&") > 4 then return end
        return not target:isNude() and p:distanceTo(target) <= 1
      end
    end
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    U.skillCharged(player, -1)
    local target = room:getPlayerById(effect.tos[1])
    if self.interaction.data == "steam__order_shock_wave1" then
      room:moveCardIntoEquip(target, player:getMark("steam__concerto_of_the_loom"), self.name, false, player.id)
    elseif self.interaction.data == "steam__order_shock_wave2" then
      local p = table.find(room.alive_players, function (p)
        return table.contains(p:getCardIds("e"), player:getMark("steam__concerto_of_the_loom"))
      end)
      if p == nil then return end
      local card = room:askForCard(target, 1, 1, true, self.name, false, nil, "#steam__order_shock_wave-ask::"..p.id)
      p:addToPile("$role_carriage&", card, false, self.name)
    end
  end,
}
concerto_of_the_loom:addRelatedSkill(concerto_of_the_loom_trigger)
orianna:addSkill(concerto_of_the_loom)
orianna:addSkill(order_defense)
orianna:addSkill(order_shock_wave)
Fk:loadTranslationTable{
  ["steam__orianna"] = "奥莉安娜",
  ["#steam__orianna"] = "发条魔灵",
  ["illustrator:steam__orianna"] = "Alex Flores",
  ["designer:steam__orianna"] = "cyc",

  ["steam__concerto_of_the_loom"] = "发条协奏",
  [":steam__concerto_of_the_loom"] = "锁定技，轮次开始时，若场上没有【魔偶】（【木牛流马】），你使用一张。【魔偶】被其他角色以发动装备技能"..
  "以外的方式移动时，取消之。准备阶段，或【魔偶】的装备技能被发动后，你的蓄力点+1。",
  ["steam__order_defense"] = "指令:防卫",
  [":steam__order_defense"] = "蓄力技（2/3），与【魔偶】距离X以内的一名角色受到伤害后，你可以消耗至多2蓄力点，令其摸等量张牌（X为蓄力点数）。",
  ["steam__order_shock_wave"] = "指令:冲击波",
  [":steam__order_shock_wave"] = "蓄力技（2/3），出牌阶段，你可以消耗1蓄力点执行以下一项：1.将【魔偶】移动一个座次；2.令【魔偶】距离1以内的"..
  "一名角色将一张牌置入之中。",
  ["#steam__concerto_of_the_loom_trigger"] = "发条协奏",
  ["#steam__order_defense-invoke"] = "指令:防卫：你可以消耗至多2蓄力点，令 %dest 摸牌",
  ["#steam__order_shock_wave"] = "指令:冲击波：消耗1蓄力点执行一项",
  ["steam__order_shock_wave1"] = "将【魔偶】移动一个座次",
  ["steam__order_shock_wave2"] = "令一名角色将一张牌置入【魔偶】",
  ["#steam__order_shock_wave-ask"] = "指令:冲击波：请将一张牌置入 %dest 的【魔偶】",

  ["$steam__concerto_of_the_loom1"] = "我有很犀利的魔偶——",
  ["$steam__concerto_of_the_loom2"] = "我们是一体的——",
  ["$steam__order_defense1"] = "保护——",
  ["$steam__order_defense2"] = "防卫——",
  ["$steam__order_shock_wave1"] = "破坏——",
  ["$steam__order_shock_wave2"] = "掠夺——",
  ["~steam__orianna"] = "（机械音）",
}

local sett = General:new(extension, "steam__sett", "west", 4, 5)
local haymaker = fk.CreateTriggerSkill{
  name = "steam__haymaker",
  anim_type = "defensive",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Finish
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askForSkillInvoke(player, self.name, nil, "#steam__haymaker-invoke")
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:changeMaxHp(player, -1)
    if not player.dead then
      room:changeShield(player, 1)
    end
  end,
}
local haymaker_trigger = fk.CreateTriggerSkill{
  name = "#steam__haymaker_trigger",
  anim_type = "drawcard",
  events = {fk.HpChanged},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(haymaker) and data.reason == "damage" and data.shield_lost > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cards = table.filter(room.draw_pile, function (id)
      return Fk:getCardById(id).is_damage_card
    end)
    if #cards == 0 then return end
    cards = table.random(cards, data.shield_lost)
    room:moveCardTo(cards, Card.PlayerHand, player, fk.ReasonDraw, "steam__haymaker", nil, false, player.id, "@@steam__haymaker-inhand")
  end,

  refresh_events = {fk.PreCardUse},
  can_refresh = function (self, event, target, player, data)
    return target == player and data.card:getMark("@@steam__haymaker-inhand") > 0
  end,
  on_refresh = function (self, event, target, player, data)
    data.extraUse = true
  end,
}
local haymaker_targetmod = fk.CreateTargetModSkill{
  name = "#steam__haymaker_targetmod",
  bypass_times = function(self, player, skill, scope, card, to)
    return card and card:getMark("@@steam__haymaker-inhand") > 0
  end,
}
local show_stopper = fk.CreateTriggerSkill{
  name = "steam__show_stopper",
  anim_type = "control",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Start and
      #player:getAvailableEquipSlots(Card.SubtypeWeapon) > 0 and
      player.room:getCardArea(player:getMark(self.name)) == Card.Void
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local success, dat = room:askForUseActiveSkill(player, "steam__show_stopper_active",
      "#steam__show_stopper-invoke", true, nil, false)
    if success and dat then
      self.cost_data = {tos = dat.targets}
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:loseHp(player, 1, self.name)
    if player.dead then return end
    local to, choices = nil, {}
    if #self.cost_data.tos > 0 then
      to = room:getPlayerById(self.cost_data.tos[1])
      if not table.contains({"blank_shibing", "blank_nvshibing", "hiddenone"}, to.general) then
        table.insert(choices, to.general)
      end
      if not table.contains({"", "blank_shibing", "blank_nvshibing", "hiddenone"}, to.deputyGeneral) then
        table.insertIfNeed(choices, to.deputyGeneral)
      end
    else
      choices = table.random(room.general_pile, 3)
    end
    local choice = ""
    if #choices == 1 then
      choice = choices[1]
    else
      choice = room:askForGeneral(player, choices, 1, true)
    end
    room:setPlayerMark(player, "@steam__show_stopper-turn", { choice, Fk.generals[choice].maxHp })

    if #self.cost_data.tos == 0 then
      table.removeOne(room.general_pile, choice)
      room.logic:getCurrentEvent():findParent(GameEvent.Turn, true):addCleaner(function()
        table.insertIfNeed(room.general_pile, choice)
      end)
    elseif to then
      local gender = Fk.generals[choice].gender
      if to.general == choice then
        room.logic:getCurrentEvent():findParent(GameEvent.Turn, true):addCleaner(function()
          room:changeHero(to, choice, false, false, false, false, true)
        end)
        room:changeHero(to, gender == General.Male and "blank_shibing" or "blank_nvshibing", false, false, false, false, true)
      elseif to.deputyGeneral == choice then
        room.logic:getCurrentEvent():findParent(GameEvent.Turn, true):addCleaner(function()
          room:changeHero(to, choice, false, true, false, false, false)
        end)
        room:changeHero(to, gender == General.Male and "blank_shibing" or "blank_nvshibing", false, true, false, false, false)
      end
    end

    local skillList = {}
    for _, skillName in ipairs(Fk.generals[choice]:getSkillNameList()) do
      local skill = Fk.skills[skillName]
      if string.sub(Fk:getDescription(skillName, "zh_CN"), 7, 12) ~= "技，" and not skill.isHiddenSkill then
        table.insert(skillList, skillName)
      end
    end
    if #skillList > 0 then
      room:setPlayerMark(player, "steam__show_stopper_skills-turn", skillList)
    end
    local card = Fk:getCardById(player:getMark(self.name))
    room:setCardMark(card, MarkEnum.DestructOutMyEquip, 1)
    room:moveCardIntoEquip(player, card.id, self.name, true)
  end,

  refresh_events = {fk.AfterCardsMove},
  can_refresh = function(self, event, target, player, data)
    for _, move in ipairs(data) do
      if move.from == player.id then
        for _, info in ipairs(move.moveInfo) do
          if info.fromArea == Card.PlayerEquip and info.cardId == player:getMark(self.name) then
            return true
          end
        end
      end
    end
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(player, "steam__show_stopper_skills-turn", 0)
    room:setPlayerMark(player, "@steam__show_stopper-turn", 0)
  end,

  on_acquire = function (self, player, is_start)
    local room = player.room
    local leftArm = room:printCard("steam__goddianwei_left_arm").id
    room:setPlayerMark(player, self.name, leftArm)
  end,
}
local show_stopper_delay = fk.CreateTriggerSkill{
  name = "#steam__show_stopper_delay",
  mute = true,
  events = {fk.TurnEnd},
  can_trigger = function(self, event, target, player, data)
    return target == player and table.contains(player:getCardIds("e"), player:getMark("steam__show_stopper"))
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    player.room:moveCardTo(player:getMark("steam__show_stopper"), Card.Void, nil, fk.ReasonJustMove)
  end,
}
local show_stopper_active = fk.CreateActiveSkill{
  name = "steam__show_stopper_active",
  card_num = 0,
  min_target_num = 0,
  max_target_num = 1,
  card_filter = Util.FalseFunc,
  target_filter = function(self, to_select, selected, selected_cards)
    if #selected == 0 and to_select ~= Self.id then
      local target = Fk:currentRoom():getPlayerById(to_select)
      return not table.contains({"blank_shibing", "blank_nvshibing", "hiddenone"}, target.general) or
        not table.contains({"", "blank_shibing", "blank_nvshibing", "hiddenone"}, target.deputyGeneral)
    end
  end,
}
haymaker:addRelatedSkill(haymaker_trigger)
haymaker:addRelatedSkill(haymaker_targetmod)
Fk:addSkill(show_stopper_active)
show_stopper:addRelatedSkill(show_stopper_delay)
sett:addSkill(haymaker)
sett:addSkill(show_stopper)
Fk:loadTranslationTable{
  ["steam__sett"] = "瑟提",
  ["#steam__sett"] = "腕豪",
  ["illustrator:steam__sett"] = "Alex Flores",
  ["designer:steam__sett"] = "cyc",

  ["steam__haymaker"] = "蓄意轰拳",
  [":steam__haymaker"] = "结束阶段，你可以减1点体力上限，获得1点护甲。你失去1点护甲后，摸一张伤害牌，令之不计次数。",
  ["steam__show_stopper"] = "叹为观止",
  [":steam__show_stopper"] = "准备阶段，你可以失去1点体力，然后选择一名其他角色的武将牌或从武将牌堆中发现一张武将牌，将之置入你的武器栏"..
  "（无花色点数，攻击范围为其体力上限，武器技能为其武将牌上的无标签技；替换原装备），本回合结束时复位其武将牌。",
  ["#steam__haymaker-invoke"] = "蓄意轰拳：是否减1点体力上限，获得1点护甲？",
  ["#steam__haymaker_trigger"] = "蓄意轰拳",
  ["@@steam__haymaker-inhand"] = "蓄意轰拳",
  ["steam__show_stopper_active"] = "叹为观止",
  ["#steam__show_stopper-invoke"] = "叹为观止：失去1点体力，选择一名角色的武将牌，或不选角色发现一张武将牌，将之置入你的武器栏，回合结束复位",
  ["@steam__show_stopper-turn"] = "",
  ["#steam__show_stopper_delay"] = "叹为观止",

  ["$steam__haymaker1"] = "准备好，要见血了。",
  ["$steam__haymaker2"] = "想给大哥来一拳？那你可千万别打偏了。",
  ["$steam__show_stopper1"] = "终结技来啦！",
  ["$steam__show_stopper2"] = "给我——砸！",
  ["$steam__show_stopper3"] = "起飞咯！",
  ["$steam__show_stopper4"] = "会很疼的！",
  ["~steam__sett"] = "我要求……重赛……",
}

local leftArm = fk.CreateWeapon{
  name = "&steam__goddianwei_left_arm",
  suit = Card.NoSuit,
  number = 0,
  attack_range = 1,
  dynamic_attack_range = function(self, player)
    if player then
      local mark = player:getTableMark("@steam__show_stopper-turn")
      return #mark == 2 and tonumber(mark[2]) or nil
    end
  end,
  dynamic_equip_skills = function(self, player)
    if player then
      return table.map(player:getTableMark("steam__show_stopper_skills-turn"), Util.Name2SkillMapper)
    end
  end,
}
Fk:loadTranslationTable{
  ["steam__goddianwei_left_arm"] = "左膀",
  ["goddianwei_left_arm"] = "左膀",
  [":steam__goddianwei_left_arm"] = "这是神典韦的左膀，蕴含着【杀】之力。",
}
leftArm.package = extension
Fk:addCard(leftArm)








return extension
