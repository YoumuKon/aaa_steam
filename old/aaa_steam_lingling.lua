local extension = Package("aaa_steam_lingling")
extension.extensionName = "aaa_steam"

local U = require "packages/utility/utility"
local LUtil = require "packages/aaa_steam/utility/ling_util"


Fk:loadTranslationTable{
  ["aaa_steam_lingling"] = "伶史",
  ["lingling"] = "伶",
}
--[[
春秋战国：屈原，廉颇，蔺相如，孙膑，商鞅
秦：嬴政，李信，项羽
汉：刘邦，刘彻，王莽，刘秀，韩信，萧何
三国：司马懿，关羽
隋：李密
唐：李白，李隆基，李靖，李世民
五代：李存孝
宋：宗泽，包拯，辛弃疾，范仲淹
明：徐达，陈友谅，郑成功
清：多尔衮，年羹尧，和珅
圣人：庄子

--]]

local zhuangzi = General(extension, "lingling__zhuangzhou", "qun", 3)
local WhoAmI = fk.CreateTriggerSkill{
  name = "lingling__WhoAmI",
  anim_type = "support",
  frequency = Skill.Compulsory,
  priority = {
    [fk.GameStart] = 1,
    [fk.TurnEnd] = 2,
  },
  events = {fk.GameStart, fk.TurnEnd},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) then
      if event == fk.GameStart then
        return true
      elseif event == fk.TurnEnd then
        return target:getMark("@@lingling_me") > 0 and
          not table.contains({target.general, target.deputyGeneral}, "lingling__zhuangzhou") and
          math.random() < 0.5
      end
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    if event == fk.GameStart then
      room:setPlayerMark(player, "@@lingling_me", 1)
    elseif event == fk.TurnEnd then
      local general = target.general
      room:changeHero(target, "lingling__zhuangzhou", false, false, true, false, false)
      for _, p in ipairs(room:getAlivePlayers()) do
        if p:getMark("@@lingling_me") == 0 and table.contains({p.general, p.deputyGeneral}, "lingling__zhuangzhou") then
          room:changeHero(p, general, false, false, true, false, false)
        end
      end
    end
  end,
}
local ButterflyIsMe = fk.CreateTriggerSkill{
  name = "lingling__ButterflyIsMe",
  anim_type = "masochism",
  frequency = Skill.Compulsory,
  events = {fk.Damaged},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player:getMark("@@lingling_me") > 0 and data.from and data.from ~= player
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    room:changeHero(player, data.from.general, false, false, true, false, false)
    room:changeHero(data.from, "lingling__zhuangzhou", false, false, true, false, false)
  end,
}
local IAmButter = fk.CreateTriggerSkill{
  name = "lingling__IAmButter",
  anim_type = "support",
  frequency = Skill.Compulsory,
  events = {fk.TurnEnd},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self)
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    player:drawCards(1, self.name)
    for _, p in ipairs(room:getAlivePlayers()) do
      if not p.dead and p:getMark("@@lingling_me") > 0 then
        p:drawCards(2, self.name)
      end
    end
  end,

  refresh_events = {fk.RoundStart},
  can_refresh = function (self, event, target, player, data)
    return player:hasSkill(self) and player.room:getBanner("RoundCount") > 6
  end,
  on_refresh = function (self, event, target, player, data)
    local room = player.room
    player.dead = true
    player._splayer:setDied(true)
    local deathStruct = {who = player.id}
    local logic = room.logic
    logic:trigger(fk.BeforeGameOverJudge, player, {who = player.id})
    room:sendLogEvent("Death", {to = player.id})
    room:setPlayerProperty(player, "role_shown", true)
    --room:broadcastProperty(player, "dead")
    player.drank = 0
    room:broadcastProperty(player, "drank")
    player.shield = 0
    room:broadcastProperty(player, "shield")
    logic:trigger(fk.GameOverJudge, player, deathStruct)
    logic:trigger(fk.Death, player, deathStruct)
    player:bury()
    logic:trigger(fk.Deathed, player, deathStruct)
    room:changeHero(player, "lingling__butterfly", false, false, false, false, false)
    room:notifySkillInvoked(player, self.name, "big")
  end,
}
zhuangzi:addSkill(WhoAmI)
zhuangzi:addSkill(ButterflyIsMe)
zhuangzi:addSkill(IAmButter)
local butterfly = General(extension, "lingling__butterfly", "qun", 3)
butterfly.total_hidden = true
Fk:loadTranslationTable{
  ["lingling__zhuangzhou"] = "庄子",
  ["lingling__butterfly"] = "蝴蝶",
  ["#lingling__zhuangzhou"] = "天地逍遥",
  ["illustrator:lingling__zhuangzhou"] = "珊瑚虫",
  ["designer:lingling__zhuangzhou"] = "伶",

  ["lingling__WhoAmI"] = "我是谁",
  [":lingling__WhoAmI"] = "游戏开始时，你获得“我”标记。有“我”标记的角色回合结束时，若其不是庄子，其有50%几率变成庄子，然后若存在没有“我”"..
  "标记的庄子，其变成因“蝴蝶是我”变成庄子前的武将。",
  ["lingling__ButterflyIsMe"] = "蝴蝶是我",
  [":lingling__ButterflyIsMe"] = "当你受到伤害后，若你有“我”标记，你将武将变成伤害来源的武将，其变成庄子。",
  ["lingling__IAmButter"] = "我是蝴蝶",
  [":lingling__IAmButter"] = "回合结束时，你摸一张牌，然后有“我”标记的角色摸两张牌。第七轮开始时，你飞走，离开游戏。"..
  "<br><br> <font color = '#a40000'>外忘于物，内忘于我。",
  ["@@lingling_me"] = "我",

  ["$lingling__IAmButter1"] = "飞飞飞飞飞飞飞飞飞飞飞飞飞飞飞飞飞飞飞飞飞飞飞飞~",
  ["$lingling__IAmButter2"] = "飞飞飞飞飞飞飞飞飞飞飞飞飞飞飞飞飞飞飞飞飞飞飞飞~",
}

local heshen = General(extension, "lingling__heshen", "qing", 3)
local sinang = fk.CreateActiveSkill{
  name = "lingling__sinang",
  anim_type = "switch",
  switch_skill_name = "lingling__sinang",
  card_num = 0,
  target_num = 0,
  prompt = function (self)
    local name = Self:getSwitchSkillState(self.name, false) == fk.SwitchYang and "amazing_grace" or "snatch"
    if table.find(Fk:currentRoom().discard_pile, function (id)
      return Fk:getCardById(id).trueName == name
    end) then
      return "#lingling__sinang1:::"..name
    else
      return "#lingling__sinang0:::"..name
    end
  end,
  card_filter = Util.FalseFunc,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    player:drawCards(1, self.name)
    if player.dead or player:isNude() then return end
    local name = player:getSwitchSkillState(self.name, true) == fk.SwitchYang and "amazing_grace" or "snatch"
    local card = Fk:cloneCard(name)
    card.skillName = self.name
    if not table.find(room.alive_players, function (p)
      return player:canUseTo(card, p)
    end) then return end
    local prompt = table.find(room.discard_pile, function (id)
      return Fk:getCardById(id).trueName == name
    end) and 1 or 0
    local success, dat = room:askForUseActiveSkill(player, "lingling__sinang_viewas",
      "#lingling__sinang"..prompt.."-use:::"..name, false)
    if success and dat then
      card:addSubcards(dat.cards)
      room:useCard{
        from = player.id,
        tos = table.map(dat.targets, function(id) return { id } end),
        card = card,
      }
    end
  end,
}
local sinang_viewas = fk.CreateViewAsSkill{
  name = "lingling__sinang_viewas",
  card_filter = function(self, to_select, selected)
    local name = Self:getSwitchSkillState("lingling__sinang", true) == fk.SwitchYang and "amazing_grace" or "snatch"
    if table.find(Fk:currentRoom().discard_pile, function (id)
      return Fk:getCardById(id).trueName == name
    end) then
      return #selected == 0
    else
      return false
    end
  end,
  view_as = function(self, cards)
    local name = Self:getSwitchSkillState("lingling__sinang", true) == fk.SwitchYang and "amazing_grace" or "snatch"
    local card = Fk:cloneCard(name)
    if table.find(Fk:currentRoom().discard_pile, function (id)
      return Fk:getCardById(id).trueName == name
    end) then
      if #cards ~= 1 then return end
      card:addSubcard(cards[1])
    end
    card.skillName = "lingling__sinang"
    return card
  end,
}
local linglong = fk.CreateTriggerSkill{
  name = "lingling__linglong",
  anim_type = "switch",
  switch_skill_name = "lingling__linglong",
  events = {fk.TurnStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self)
  end,
  on_use = function(self, event, target, player, data)
    local mark = "@@lingling__linglong_"..player:getSwitchSkillState(self.name, true, true).."-inhand"
    player:drawCards(1, self.name, "top", mark)
  end,
}
local linglong_filter = fk.CreateFilterSkill{
  name = "#lingling__linglong_filter",
  card_filter = function(self, card, player)
    if table.contains(player:getCardIds("h"), card.id) then
      if card:getMark("@@lingling__linglong_yang-inhand") > 0 then
        return player.phase ~= Player.NotActive
      elseif card:getMark("@@lingling__linglong_yin-inhand") > 0 then
        return player.phase == Player.NotActive
      end
    end
  end,
  view_as = function(self, card)
    return Fk:cloneCard("nullification", card.suit, card.number)
  end,
}
local linglong_maxcards = fk.CreateMaxCardsSkill{
  name = "#lingling__linglong_maxcards",
  exclude_from = function(self, player, card)
    return card:getMark("@@lingling__linglong_yang-inhand") + card:getMark("@@lingling__linglong_yin-inhand") > 0
  end,
}
Fk:addSkill(sinang_viewas)
linglong:addRelatedSkill(linglong_filter)
linglong:addRelatedSkill(linglong_maxcards)
heshen:addSkill(sinang)
heshen:addSkill(linglong)
Fk:loadTranslationTable{
  ["lingling__heshen"] = "和珅",
  ["#lingling__heshen"] = "袖里乾坤",
  ["illustrator:lingling__heshen"] = "珊瑚虫",
  ["designer:lingling__heshen"] = "伶",

  ["lingling__sinang"] = "私囊",
  [":lingling__sinang"] = "转换技，出牌阶段限一次，你可以摸一张牌，然后视为使用①【五谷丰登】②【顺手牵羊】。若弃牌堆有对应牌，则你须用一张牌转化。",
  ["lingling__linglong"] = "玲珑",
  [":lingling__linglong"] = "转换技，回合开始时，你可以摸一张牌，此牌于你①回合内②回合外视为【无懈可击】，且不计入手牌上限。"..
  "<br><br> <font color = '#a40000'>一窝一窝又一窝，十窝八窝千百窝。<br>食尽皇家千钟粟，凤少雀何多。",
  ["#lingling__sinang1"] = "私囊：你可以摸一张牌，然后将一张牌当【%arg】使用",
  ["#lingling__sinang0"] = "私囊：你可以摸一张牌，然后视为使用【%arg】",
  ["#lingling__sinang1-use"] = "私囊：请将一张牌当【%arg】使用",
  ["#lingling__sinang0-use"] = "私囊：请视为使用【%arg】",
  ["lingling__sinang_viewas"] = "私囊",
  ["#lingling__linglong_filter"] = "玲珑",
  ["@@lingling__linglong_yang-inhand"] = "玲珑",
  ["@@lingling__linglong_yin-inhand"] = "玲珑",
}

local niangengyao = General(extension, "lingling__niangengyao", "qing", 4)
local weifu = fk.CreateTriggerSkill{
  name = "lingling__weifu",
  anim_type = "masochism",
  frequency = Skill.Compulsory,
  events = {fk.Damaged},
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(self) then
      if not data.card then
        return table.contains(player:getTableMark("@lingling__weifu"), 4)
      elseif data.card:isVirtual() and #data.card.subcards == 0 then
        return table.contains(player:getTableMark("@lingling__weifu"), 3)
      elseif data.card:isVirtual() and #data.card.subcards > 0 then
        return table.contains(player:getTableMark("@lingling__weifu"), 2)
      elseif not data.card:isVirtual() then
        return table.contains(player:getTableMark("@lingling__weifu"), 1)
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local n = 0
    if not data.card then
      n = 4
    elseif data.card:isVirtual() and #data.card.subcards == 0 then
      n = 3
    elseif data.card:isVirtual() and #data.card.subcards > 0 then
      n = 2
    elseif not data.card:isVirtual() then
      n = 1
    end
    player:drawCards(n, self.name)
  end,

  on_acquire = function (self, player)
    player.room:setPlayerMark(player, "@lingling__weifu", {4, 3, 2, 1})
  end,
  on_lose = function (self, player)
    player.room:setPlayerMark(player, "@lingling__weifu", 0)
  end,
}
local kuiduo = fk.CreateActiveSkill{
  name = "lingling__kuiduo",
  anim_type = "drawcard",
  card_num = 0,
  target_num = 0,
  prompt = "#lingling__kuiduo",
  interaction = function(self)
    local choices = table.map(Self:getTableMark("@lingling__weifu"), function (n)
      return tostring(n)
    end)
    return UI.ComboBox { choices = choices }
  end,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0 and
      player:getMark("@lingling__weifu") ~= 0
  end,
  card_filter = Util.FalseFunc,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    room:removeTableMark(player, "@lingling__weifu", tonumber(self.interaction.data))
    if #room.discard_pile > 0 then
      local n = math.min(2, #room.discard_pile)
      local cards = U.askforChooseCardsAndChoice(player, room.discard_pile, {"OK"}, self.name, "#lingling__kuiduo-prey", nil, n, n)
      room:moveCardTo(cards, Card.PlayerHand, player, fk.ReasonJustMove, self.name, nil, true, player.id)
    end
  end,
}
niangengyao:addSkill(weifu)
niangengyao:addSkill(kuiduo)
Fk:loadTranslationTable{
  ["lingling__niangengyao"] = "年羹尧",
  ["#lingling__niangengyao"] = "年大将军",
  ["illustrator:lingling__niangengyao"] = "珊瑚虫",
  ["designer:lingling__niangengyao"] = "伶",

  ["lingling__weifu"] = "威福",
  [":lingling__weifu"] = "当你受到技能伤害后，你摸四张牌。当你受到虚拟牌伤害后，你摸三张牌。当你受到转化牌伤害后，你摸两张牌。"..
  "当你受到非转化实体牌伤害后，你摸一张牌。",
  ["lingling__kuiduo"] = "揆度",
  [":lingling__kuiduo"] = "出牌阶段限一次，你可以移除〖威福〗的一句描述，然后从弃牌堆获得两张牌。"..
  "<br><br> <font color = '#a40000'>年虽跋扈不臣，罹大谴，其兵法之灵变，实不愧一时名将之称。",
  ["@lingling__weifu"] = "威福",
  ["#lingling__kuiduo"] = "揆度：你可以移除〖威福〗的一句描述，然后从弃牌堆获得两张牌",
  ["#lingling__kuiduo-prey"] = "揆度：从弃牌堆获得两张牌",
}

local duoergun = General(extension, "lingling__duoergun", "qing", 4)
local lixing = fk.CreateTriggerSkill{
  name = "lingling__lixing",
  anim_type = "drawcard",
  frequency = Skill.Compulsory,
  events = {fk.Damage},
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(self) and data.to ~= player then
      return table.find(data.to:getCardIds("h"), function (id)
        return Fk:getCardById(id).trueName == "jink" or Fk:getCardById(id).trueName == "nullification"
      end) and #player.room.logic:getActualDamageEvents(2, function(e)
        return e.data[1].from == player and e.data[1].to ~= player
      end) == 1
    end
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(2, self.name)
  end,
}
local tongwei = fk.CreateActiveSkill{
  name = "lingling__tongwei",
  anim_type = "control",
  card_num = 0,
  target_num = 1,
  prompt = "#lingling__tongwei",
  interaction = function()
    local cards = table.simpleClone(Fk:currentRoom().draw_pile)
    table.insertTable(cards, table.simpleClone(Fk:currentRoom().discard_pile))
    local choices = {}
    for _, name in ipairs({"jink", "nullification"}) do
      if table.find(cards, function (id)
        return Fk:getCardById(id).trueName == name
      end) then
        table.insert(choices, name)
      end
    end
    if #choices == 0 then return end
    return U.CardNameBox { choices = choices, all_choices = {"jink", "nullification"} }
  end,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) < 2 and
      (table.find(Fk:currentRoom().draw_pile, function (id)
        return table.contains({"jink", "nullification"}, Fk:getCardById(id).trueName)
      end) or table.find(Fk:currentRoom().discard_pile, function (id)
        return table.contains({"jink", "nullification"}, Fk:getCardById(id).trueName)
      end))
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, to_select, selected, selected_cards)
    return #selected == 0 and to_select ~= Self.id and
      not table.contains(Self:getTableMark("lingling__tongwei-phase"), to_select)
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    room:addTableMark(player, "lingling__tongwei-phase", target.id)
    local name = self.interaction.data
    local card = room:getCardsFromPileByRule(name, 1, "allPiles")
    if #card == 0 then return end
    room:moveCardTo(card, Card.PlayerHand, target, fk.ReasonJustMove, self.name, nil, true, player.id)
    if target.dead then return end
    room:addPlayerMark(target, "@@lingling__tongwei_"..name, 1)
    if not player.dead then
      room:addTableMark(player, self.name, {target.id, name})
    end
  end,

  on_lose = function (self, player, is_death)
    if is_death then
      local room = player.room
      local mark = player:getTableMark(self.name)
      room:setPlayerMark(player, self.name, 0)
      for _, info in ipairs(mark) do
        local p = room:getPlayerById(info[1])
        if not p.dead then
          dbg()
          room:removePlayerMark(p, "@@lingling__tongwei_"..info[2], 1)
        end
      end
    end
  end,
}
local tongwei_delay = fk.CreateTriggerSkill{
  name = "#lingling__tongwei_delay",
  anim_type = "control",
  events = {fk.CardUseFinished},
  can_trigger = function (self, event, target, player, data)
    return table.find(player:getTableMark("lingling__tongwei"), function (dat)
      return dat[1] == target.id and dat[2] == data.card.trueName
    end) and not target.dead
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    local room = player.room
    room:doIndicate(player.id, {target.id})
    room:setPlayerMark(target, "@@lingling__tongwei_"..data.card.trueName, 0)
    local mark = player:getTableMark("lingling__tongwei")
    for i = #mark, 1, -1 do
      if mark[i][1] == target.id and mark[i][2] == data.card.trueName then
        table.remove(mark, i)
      end
    end
    room:setPlayerMark(player, "lingling__tongwei", mark)
    if not target:isNude() then
      local cards = room:askForCardsChosen(player, target, 1, 2, "he", "lingling__tongwei", "#lingling__tongwei-prey::"..target.id)
      room:moveCardTo(cards, Card.PlayerHand, player, fk.ReasonPrey, "lingling__tongwei", nil, false, player.id)
    end
  end,

  refresh_events = {fk.TurnStart},
  can_refresh = function(self, event, target, player, data)
    return target == player and player:getMark("lingling__tongwei") ~= 0
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    local mark = player:getTableMark("lingling__tongwei")
    room:setPlayerMark(player, "lingling__tongwei", 0)
    for _, info in ipairs(mark) do
      local p = room:getPlayerById(info[1])
      if not p.dead then
        room:removePlayerMark(p, "@@lingling__tongwei_"..info[2], 1)
      end
    end
  end,
}
tongwei:addRelatedSkill(tongwei_delay)
duoergun:addSkill(lixing)
duoergun:addSkill(tongwei)
Fk:loadTranslationTable{
  ["lingling__duoergun"] = "多尔衮",
  ["#lingling__duoergun"] = "墨尔根戴青",
  ["illustrator:lingling__duoergun"] = "珊瑚虫",
  ["designer:lingling__duoergun"] = "伶",

  ["lingling__lixing"] = "厉行",
  [":lingling__lixing"] = "当你每回合首次对其他角色造成伤害后，若其手牌中有【闪】或【无懈可击】，你摸两张牌。",
  ["lingling__tongwei"] = "统围",
  [":lingling__tongwei"] = "出牌阶段限两次，你可以令一名本回合未选择过的其他角色获得一张【闪】或【无懈可击】，直到你下回合开始，"..
  "当其下一次使用同名牌后，你获得其一或两张牌。"..
  "<br><br> <font color = '#a40000'>攻城必克，野战必胜。扫荡贼氛，肃清宫禁。",
  ["#lingling__tongwei"] = "统围：令一名角色获得一张【闪】或【无懈可击】，其下次使用同名牌后你获得其一至两张牌",
  ["@@lingling__tongwei_jink"] = "统围 闪",
  ["@@lingling__tongwei_nullification"] = "统围 无懈可击",
  ["#lingling__tongwei_delay"] = "统围",
  ["#lingling__tongwei-prey"] = "统围：获得 %dest 一至两张牌",
}

local zhengchenggong = General(extension, "lingling__zhengchenggong", "ming", 4)
local tingzhen = fk.CreateTriggerSkill{
  name = "lingling__tingzhen",
  anim_type = "offensive",
  frequency = Skill.Compulsory,
  events = {fk.CardUsing, fk.CardUseFinished},
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(self) then
      local use_event = player.room.logic:getCurrentEvent()
      if player.room:getBanner("RoundCount") % 2 == 1 then
        return event == fk.CardUsing and data.card.trueName == "slash" and
          #player.room.logic:getEventsOfScope(GameEvent.UseCard, 2, function (e)
            if e.id <= use_event.id and e.id > player:getMark("lingling__bizou_flag") then
              local use = e.data[1]
              return use.from == player.id and use.card.trueName == "slash" and
                player:usedCardTimes(use.card.trueName, Player.HistoryRound) > 0
            end
          end, Player.HistoryRound) == 1
      else
        return event == fk.CardUseFinished and data.card.type == Card.TypeTrick and
          #player.room.logic:getEventsOfScope(GameEvent.UseCard, 2, function (e)
            if e.id <= use_event.id and e.id > player:getMark("lingling__bizou_flag") then
              local use = e.data[1]
              return use.from == player.id and use.card.type == Card.TypeTrick and
                player:usedCardTimes(use.card.trueName, Player.HistoryRound) > 0
            end
          end, Player.HistoryRound) == 1
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local use_event = player.room.logic:getCurrentEvent()
    if event == fk.CardUsing then
      data.additionalDamage = (data.additionalDamage or 0) + 1
      if player:getMark("lingling__tingzhen1") == 0 then
        room:setPlayerMark(player, "lingling__tingzhen1", 1)
        if #room.logic:getEventsOfScope(GameEvent.UseCard, 2, function (e)
          if e.id <= use_event.id then
            local use = e.data[1]
            return use.from == player.id and use.card.trueName == "slash"
          end
        end, Player.HistoryGame) == 1 then
          data.additionalDamage = data.additionalDamage + 1
        end
      end
    elseif event == fk.CardUseFinished then
      room:addPlayerMark(player, MarkEnum.SlashResidue.."-round", 1)
      player:drawCards(2, self.name)
      if player:getMark("lingling__tingzhen2") == 0 and not player.dead then
        room:setPlayerMark(player, "lingling__tingzhen2", 1)
        if #room.logic:getEventsOfScope(GameEvent.UseCard, 2, function (e)
          if e.id <= use_event.id then
            local use = e.data[1]
            return use.from == player.id and use.card.type == Card.TypeTrick
          end
        end, Player.HistoryGame) == 1 then
          player:drawCards(2, self.name)
        end
      end
    end
  end,
}
local bizou = fk.CreateActiveSkill{
  name = "lingling__bizou",
  anim_type = "control",
  card_num = 0,
  target_num = 0,
  prompt = "#lingling__bizou",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local roundCount = room:getBanner("RoundCount")
    roundCount = roundCount + 1
    room:setTag("RoundCount",  roundCount)
    room:doBroadcastNotify("UpdateRoundNum", roundCount)
    room:loseHp(player, 1, self.name)
    if player.dead then return end
    local e = room.logic:getCurrentEvent():findParent(GameEvent.SkillEffect, true)
    room:setPlayerMark(player, "lingling__bizou_flag", e.id)
    player:setCardUseHistory("", 0, Player.HistoryRound)
    local targets = table.filter(room.alive_players, function (p)
      return player:getNextAlive() == p or player:getLastAlive() == p
    end)
    local to = room:askForChoosePlayers(player, table.map(targets, Util.IdMapper), 1, 1,
      "#lingling__bizou-choose", self.name, true)
    if #to > 0 then
      to = room:getPlayerById(to[1])
      room:setPlayerMark(to, MarkEnum.PlayerRemoved.."-turn", 1)
      room:setPlayerMark(to, "@@lingling__bizou-turn", 1)
    end
  end,
}
local bizou_prohibit = fk.CreateProhibitSkill{
  name = "#lingling__bizou_prohibit",
  prohibit_use = function(self, player, card)
    return card and player:getMark("@@lingling__bizou-turn") ~= 0
  end,
  is_prohibited = function(self, from, to, card)
    return card and to:getMark("@@lingling__bizou-turn") ~= 0
  end,
}
local bizou_trigger = fk.CreateTriggerSkill{
  name = "#lingling__bizou_trigger",

  refresh_events = {fk.PreHpRecover, fk.PreHpLost, fk.DamageInflicted},
  can_refresh = function(self, event, target, player, data)
    return target == player and player:getMark("@@lingling__bizou-turn") ~= 0
  end,
  on_refresh = function(self, event, target, player, data)
    if event == fk.DamageInflicted then
      data.damage = 0
    else
      data.num = 0
    end
  end,
}
local weiyuan = fk.CreateTriggerSkill{
  name = "lingling__weiyuan",
  anim_type = "defensive",
  frequency = Skill.Compulsory,
  events = {fk.GameStart},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local n = #table.filter(room.alive_players, function (p)
      return table.find(p:getCardIds("h"), function (id)
        return Fk:getCardById(id).trueName == "jink"
      end)
    end)
    if n > 0 then
      room:changeShield(player, n)
    end
  end,
}
bizou:addRelatedSkill(bizou_prohibit)
bizou:addRelatedSkill(bizou_trigger)
zhengchenggong:addSkill(tingzhen)
zhengchenggong:addSkill(bizou)
zhengchenggong:addSkill(weiyuan)
Fk:loadTranslationTable{
  ["lingling__zhengchenggong"] = "郑成功",
  ["#lingling__zhengchenggong"] = "国姓爷",
  ["designer:lingling__zhengchenggong"] = "伶",
  ["illustrator:lingling__zhengchenggong"] = "珊瑚虫",

  ["lingling__tingzhen"] = "廷震",
  [":lingling__tingzhen"] = "奇数轮内，本轮你使用首张【杀】伤害+1，若为本局游戏首次使用【杀】则再+1。偶数轮内，本轮你使用首张锦囊牌后，"..
  "你摸两张牌且使用【杀】的次数上限+1，若为本局游戏首次使用锦囊牌则再摸两张牌。",
  ["lingling__bizou"] = "避走",
  [":lingling__bizou"] = "出牌阶段限一次，你可以失去1点体力令轮次数+1，本轮你视为未使用牌，然后你可以将一名邻家调离至回合结束。",
  ["lingling__weiyuan"] = "威远",
  [":lingling__weiyuan"] = "游戏开始时，你获得X点护甲（X为手牌中有【闪】的角色数），至多获得4点。"..
  "<br><br> <font color = '#a40000'>孤臣秉孤忠，浩气磅礴留千古；<br>正人扶正气，莫教成败论英雄。",
  ["#lingling__bizou"] = "避走：你可以失去1点体力令轮次数+1，然后可以调离一名邻家",
  ["#lingling__bizou-choose"] = "避走：你可以调离一名邻家至回合结束",
  ["@@lingling__bizou-turn"] = "被调离",
}

local chenyouliang = General(extension, "lingling__chenyouliang", "han", 4)
local henghu = fk.CreateTriggerSkill{
  name = "lingling__henghu",
  anim_type = "support",
  frequency = Skill.Compulsory,
  events = {fk.GameStart},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) then
      local card = table.find(U.prepareDeriveCards(player.room, {{"lingling__warship", Card.Club, 10}}, self.name), function (id)
        return player.room:getCardArea(id) == Card.Void
      end)
      return card and U.canMoveCardIntoEquip(player, card)
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local card = table.find(U.prepareDeriveCards(room, {{"lingling__warship", Card.Club, 10}}, self.name), function (id)
      return room:getCardArea(id) == Card.Void
    end)
    if card then
      room:setCardMark(Fk:getCardById(card), MarkEnum.DestructOutMyEquip, 1)
      room:moveCardIntoEquip(player, card, self.name, true, player.id)
    end
  end,
}
local daohai = fk.CreateTriggerSkill{
  name = "lingling__daohai",
  anim_type = "control",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target ~= player and player:hasSkill(self) and target.phase == Player.Discard and not target.dead and
      player:usedSkillTimes(self.name, Player.HistoryRound) == 0
  end,
  on_cost = function(self, event, target, player, data)
    if player.room:askForSkillInvoke(player, self.name, nil, "#lingling__daohai-invoke::"..target.id) then
      self.cost_data = {tos = {target.id}}
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    player:gainAnExtraPhase(Player.Draw, false)
    if not target.dead then
      target:gainAnExtraPhase(Player.Draw, false)
    end
  end,
}
local daohai_delay = fk.CreateTriggerSkill{
  name = "#lingling__daohai_delay",
  mute = true,
  events = {fk.EventPhaseEnd},
  can_trigger = function(self, event, target, player, data)
    return target.phase == Player.Discard and player:usedSkillTimes("lingling__daohai", Player.HistoryPhase) > 0 and
      #player.room.logic:getEventsOfScope(GameEvent.MoveCards, 1, function(e)
        for _, move in ipairs(e.data) do
          if move.from == target.id and move.moveReason == fk.ReasonDiscard then
            return true
          end
        end
      end, Player.HistoryPhase) == 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    player.room:handleAddLoseSkills(player, "-lingling__daohai", nil, true, false)
  end,
}
local tunjiang = fk.CreateTriggerSkill{
  name = "lingling__tunjiang",
  anim_type = "control",
  events = {fk.EventPhaseEnd},
  can_trigger = function(self, event, target, player, data)
    return target ~= player and player:hasSkill(self) and target.phase == Player.Draw and not target.dead and
      player:usedSkillTimes(self.name, Player.HistoryRound) == 0
  end,
  on_cost = function(self, event, target, player, data)
    if player.room:askForSkillInvoke(player, self.name, nil, "#lingling__tunjiang-invoke::"..target.id) then
      self.cost_data = {tos = {target.id}}
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:gainAnExtraPhase(Player.Discard, false)
    if not target.dead then
      room:setPlayerMark(player, "lingling__tunjiang_using", 1)
      room:setPlayerMark(target, "lingling__tunjiang-tmp", 0)
      target:gainAnExtraPhase(Player.Discard, false)
      room:setPlayerMark(player, "lingling__tunjiang_using", 0)
      local n = target:getMark("lingling__tunjiang-tmp")
      room:setPlayerMark(target, "lingling__tunjiang-tmp", 0)
      if n > 2 then
        room:handleAddLoseSkills(player, "-lingling__tunjiang", nil, true, false)
      end
    end
  end,

  refresh_events = {fk.AfterCardsMove},
  can_refresh = function (self, event, target, player, data)
    return player:getMark("lingling__tunjiang_using") > 0
  end,
  on_refresh = function (self, event, target, player, data)
    local room = player.room
    for _, move in ipairs(data) do
      if move.from and move.moveReason == fk.ReasonDiscard then
        local from = room:getPlayerById(move.from)
        if from.phase == Player.Discard then
          room:addPlayerMark(from, "lingling__tunjiang-tmp", #move.moveInfo)
        end
      end
    end
  end,
}
daohai:addRelatedSkill(daohai_delay)
chenyouliang:addSkill(henghu)
chenyouliang:addSkill(daohai)
chenyouliang:addSkill(tunjiang)
Fk:loadTranslationTable{
  ["lingling__chenyouliang"] = "陈友谅",
  ["#lingling__chenyouliang"] = "九江巨蠹",
  ["designer:lingling__chenyouliang"] = "伶",
  ["illustrator:lingling__chenyouliang"] = "珊瑚虫",

  ["lingling__henghu"] = "横湖",
  [":lingling__henghu"] = "游戏开始时，你将<a href=':lingling__warship'>【大战船】</a>置入宝物栏，当此牌离开你装备区时销毁之。",
  ["lingling__daohai"] = "倒海",
  [":lingling__daohai"] = "每轮限一次，其他角色弃牌阶段开始时，你可以与其各执行一个额外的摸牌阶段，若其该弃牌阶段未弃置牌，你失去此技能。",
  ["lingling__tunjiang"] = "吞江",
  [":lingling__tunjiang"] = "每轮限一次，其他角色摸牌阶段结束时，你可以与其各执行一个额外的弃牌阶段，若其因此弃置至少三张牌，你失去此技能。"..
  "<br><br> <font color = '#a40000'>江汉先英，三楚雄风。",
  ["#lingling__daohai-invoke"] = "倒海：是否与 %dest 各执行一个摸牌阶段？若其弃牌阶段未弃牌则你失去本技能",
  ["#lingling__tunjiang-invoke"] = "吞江：是否与 %dest 各执行一个弃牌阶段？若其此阶段弃置至少三张牌则你失去本技能",
}



local xuda = General(extension, "lingling__xuda", "ming", 4)
local xuexiong = fk.CreateActiveSkill{
  name = "lingling__xuexiong",
  anim_type = "control",
  card_num = 0,
  target_num = 1,
  prompt = "#lingling__xuexiong",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, to_select, selected)
    return #selected == 0 and not table.contains(Self:getTableMark("lingling__xuexiong_record-turn"), to_select)
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    room:addTableMark(player, "lingling__xuexiong_record", target.id)
    room:askForDiscard(target, 3, 3, true, self.name, false)
    if target.dead then return end
    room:addPlayerMark(target, self.name, 1)
  end
}
local xuexiong_delay = fk.CreateTriggerSkill{
  name = "#lingling__xuexiong_delay",
  anim_type = "drawcard",
  events = {fk.TurnStart, fk.TurnEnd},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:getMark("lingling__xuexiong-turn") > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    player:drawCards(player:getMark("lingling__xuexiong-turn"), "lingling__xuexiong")
  end,

  refresh_events = {fk.TurnStart},
  can_refresh = function (self, event, target, player, data)
    return target == player and (player:getMark("lingling__xuexiong") > 0 or #player:getTableMark("lingling__xuexiong_record") > 0)
  end,
  on_refresh = function (self, event, target, player, data)
    local room = player.room
    if player:getMark("lingling__xuexiong") > 0 then
      room:setPlayerMark(player, "lingling__xuexiong-turn", player:getMark("lingling__xuexiong"))
      room:setPlayerMark(player, "lingling__xuexiong", 0)
    end
    if #player:getTableMark("lingling__xuexiong_record") > 0 then
      room:setPlayerMark(player, "lingling__xuexiong_record-turn", player:getMark("lingling__xuexiong_record"))
      room:setPlayerMark(player, "lingling__xuexiong_record", 0)
    end
  end,
}
local mochou = fk.CreateTriggerSkill{
  name = "lingling__mochou",
  anim_type = "offensive",
  events = {fk.EventPhaseEnd},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Play and player:isKongcheng()
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local targets = table.filter(room.alive_players, function (p)
      return player:getNextAlive() == p or player:getLastAlive() == p
    end)
    local to = room:askForChoosePlayers(player, table.map(targets, Util.IdMapper), 1, 1,
      "#lingling__mochou-choose", self.name, true)
    if #to > 0 then
      self.cost_data = {tos = to}
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(self.cost_data.tos[1])
    room:damage{
      from = player,
      to = to,
      damage = 1,
      skillName = self.name,
    }
    if to.dead then return end
    local choices = {"lingling__mochou_damage:"..player.id}
    if not player.dead then
      table.insert(choices, 1, "lingling__mochou_draw:"..player.id)
    end
    local choice = room:askForChoice(to, choices, self.name)
    if choice:startsWith("lingling__mochou_damage") then
      room:damage{
        from = player,
        to = to,
        damage = 1,
        skillName = self.name,
      }
    else
      player:drawCards(2, self.name)
    end
  end,
}
xuexiong:addRelatedSkill(xuexiong_delay)
xuda:addSkill(xuexiong)
xuda:addSkill(mochou)
Fk:loadTranslationTable{
  ["lingling__xuda"] = "徐达",
  ["#lingling__xuda"] = "万里长城",
  ["designer:lingling__xuda"] = "伶",
  ["illustrator:lingling__xuda"] = "珊瑚虫",

  ["lingling__xuexiong"] = "削雄",
  [":lingling__xuexiong"] = "出牌阶段限一次，你可以选择一名上回合未以此法选择过的角色，其弃置三张牌（不足全弃，无牌不弃），且其下回合开始时和"..
  "下回合结束时各摸一张牌。",
  ["lingling__mochou"] = "莫愁",
  [":lingling__mochou"] = "出牌阶段结束时，若你没有手牌，你可以对一名邻家造成1点伤害，然后其选择令你摸两张牌或再受到你造成的1点伤害。"..
  "<br><br> <font color = '#a40000'>百战标奇，六王首功。",
  ["#lingling__xuexiong"] = "削雄：令一名角色弃三张牌，其下回合开始时和下回合结束时各摸一张牌",
  ["#lingling__xuexiong_delay"] = "削雄",
  ["#lingling__mochou-choose"] = "莫愁：你可以对一名邻家造成1点伤害，其选择令你摸两张牌或再受到1点伤害",
  ["lingling__mochou_draw"] = "%src 摸两张牌",
  ["lingling__mochou_damage"] = "%src 再对你造成1点伤害",
}

local xinqiji = General(extension, "lingling__xinqiji", "song", 3)
local shishou = fk.CreateTriggerSkill{
  name = "lingling__shishou",
  anim_type = "offensive",
  events = {fk.TurnEnd},
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(self) then
      local room = player.room
      local phase_judge, phase_play, phase_discard = {}, {}, {}
      room.logic:getEventsOfScope(GameEvent.Phase, 1, function (e)
        if e.data[1] == player then
          if e.data[2] == Player.Judge then
            table.insert(phase_judge, {e.id, e.end_id})
          elseif e.data[2] == Player.Play then
            table.insert(phase_play, {e.id, e.end_id})
          elseif e.data[2] == Player.Discard then
            table.insert(phase_discard, {e.id, e.end_id})
          end
        end
      end, Player.HistoryTurn)
      local n = 0
      if #phase_judge > 0 then
        if #room.logic:getEventsOfScope(GameEvent.Judge, 1, function (e)
          if table.find(phase_judge, function (info)
            return e.id >= info[1] and e.id <= info[2]
          end) then
            local judge = e.data[1]
            return judge.who == player and Fk.all_card_types[judge.reason] ~= nil
          end
        end, Player.HistoryTurn) > 0 then
          n = n + 1
        end
      end
      if #phase_play > 0 then
        if #room.logic:getEventsOfScope(GameEvent.UseCard, 1, function (e)
          if table.find(phase_play, function (info)
            return e.id >= info[1] and e.id <= info[2]
          end) then
            local use = e.data[1]
            return use.from == player.id
          end
        end, Player.HistoryTurn) > 0 then
          n = n + 1
        end
      end
      if #phase_discard > 0 then
        if #room.logic:getEventsOfScope(GameEvent.MoveCards, 1, function (e)
          if table.find(phase_discard, function (info)
            return e.id >= info[1] and e.id <= info[2]
          end) then
            for _, move in ipairs(e.data) do
              if move.from == player.id and move.moveReason == fk.ReasonDiscard then
                return true
              end
            end
          end
        end, Player.HistoryTurn) > 0 then
          n = n + 1
        end
      end
      if n > 0 then
        self.cost_data = n
        return true
      end
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local n = self.cost_data
    local yes = false
    local all_cards = U.getUniversalCards(player.room, "t")
    for i = 1, n, 1 do
      if player.dead then return end
      local cards = table.filter(all_cards, function (id)
        return not table.contains(player:getTableMark("lingling__shishou-turn"), Fk:getCardById(id).name)
      end)
      if #cards == 0 then break end
      local use = U.askForUseRealCard(room, player, cards, nil, self.name, "#lingling__shishou-ask:::"..(n - i + 1),
        {expand_pile = all_cards}, true, true)
      if use then
        local card = Fk:cloneCard(use.card.name)
        card.skillName = self.name
        room:addTableMark(player, "lingling__shishou-turn", card.name)
        room:addTableMark(player, self.name, card.name)
        use = {
          card = card,
          from = player.id,
          tos = use.tos,
        }
        room:useCard(use)
        if use.damageDealt then
          yes = true
        end
      else
        break
      end
    end
    if not player.dead and yes then
      room:askForDiscard(player, 1, 1, true, self.name, false)
    end
  end,

  refresh_events = {fk.TurnStart},
  can_refresh = function(self, event, target, player, data)
    return target == player and player:getMark(self.name) ~= 0
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(player, "lingling__shishou-turn", player:getMark(self.name))
    room:setPlayerMark(player, self.name, 0)
  end,
}
local nanchouSkill = fk.CreateActiveSkill{
  name = "lingling__nanchou__indulgence_skill",
  prompt = "#indulgence_skill",
  can_use = Util.CanUse,
  mod_target_filter = function(self, to_select, selected, user, card, distance_limited)
    return user ~= to_select
  end,
  target_filter = function(self, to_select, selected, _, card, extra_data, player)
    if not Util.TargetFilter(self, to_select, selected, _, card, extra_data, player) then return end
    return #selected == 0 and self:modTargetFilter(to_select, selected, player, card, true)
  end,
  target_num = 1,
  on_effect = function(self, room, effect)
    local to = room:getPlayerById(effect.to)
    local judge = {
      who = to,
      reason = "indulgence",
      pattern = ".|.|spade,club",
    }
    room:judge(judge)
    local result = judge.card
    if result.suit ~= Card.Heart and result.suit ~= Card.Diamond then
      to:skip(Player.Play)
    end
    self:onNullified(room, effect)
  end,
  on_nullified = function(self, room, effect)
    room:moveCards{
      ids = room:getSubcardsByRule(effect.card, { Card.Processing }),
      toArea = Card.DiscardPile,
      moveReason = fk.ReasonUse,
    }
  end,
}
nanchouSkill.cardSkill = true
Fk:addSkill(nanchouSkill)
local nanchou = fk.CreateTriggerSkill{
  name = "lingling__nanchou",
  attached_skill_name = "lingling__nanchou&",

  refresh_events = {fk.PreCardEffect},
  can_refresh = function(self, event, target, player, data)
    return data.to == player.id and table.contains(data.card.skillNames, "lingling__nanchou")
  end,
  on_refresh = function(self, event, target, player, data)
    local card = data.card:clone()
    local c = table.simpleClone(data.card)
    for k, v in pairs(c) do
      card[k] = v
    end
    card.skill = nanchouSkill
    data.card = card
  end,
}
local nanchou_viewas = fk.CreateViewAsSkill{
  name = "lingling__nanchou&",
  anim_type = "control",
  prompt = "#lingling__nanchou&",
  card_filter = function (self, to_select, selected)
    return #selected == 0 and Fk:getCardById(to_select).suit == Card.Diamond
  end,
  view_as = function(self, cards)
    if #cards == 0 then return end
    local card = Fk:cloneCard("indulgence")
    card:addSubcard(cards[1])
    card.skillName = "lingling__nanchou"
    return card
  end,
  enabled_at_response = function (self, player, response)
    return not response
  end,
}
local nanchou_prohibit = fk.CreateProhibitSkill{
  name = "#lingling__nanchou_prohibit",
  is_prohibited = function(self, from, to, card)
    return card and table.contains(card.skillNames, "lingling__nanchou") and not to:hasSkill(nanchou)
  end,
}
nanchou_viewas:addRelatedSkill(nanchou_prohibit)
Fk:addSkill(nanchou_viewas)
xinqiji:addSkill(shishou)
xinqiji:addSkill(nanchou)
Fk:loadTranslationTable{
  ["lingling__xinqiji"] = "辛弃疾",
  ["#lingling__xinqiji"] = "词中之龙",
  ["illustrator:lingling__xinqiji"] = "珊瑚虫",
  ["designer:lingling__xinqiji"] = "伶",

  ["lingling__shishou"] = "试手",
  [":lingling__shishou"] = "回合结束时，你可以依次视为使用X张牌名不同的普通锦囊牌（须与上回合以此法使用的牌名不同），X为你本回合满足"..
  "以下项的次数：判定阶段判定了牌，出牌阶段使用了牌，弃牌阶段弃置了牌。以此法视为使用的牌皆结算后，若你因此造成了伤害，你弃置一张牌。",
  ["lingling__nanchou"] = "难酬",
  [":lingling__nanchou"] = "其他角色可以将<font color='red'>♦</font>牌当【乐不思蜀】对你使用，此【乐不思蜀】判定为"..
  "<font color='red'>♦</font>也无效。"..
  "<br><br> <font color = '#a40000'>醉里挑灯看剑，梦回吹角连营。",
  ["lingling__nanchou&"] = "难酬",
  [":lingling__nanchou&"] = "你可以将<font color='red'>♦</font>牌当【乐不思蜀】对辛弃疾使用，此【乐不思蜀】判定为"..
  "<font color='red'>♦</font>也无效。",
  ["#lingling__shishou-ask"] = "试手：是否视为使用锦囊牌？（还剩%arg张）",
  ["#lingling__nanchou&"] = "难酬：你可以将<font color='red'>♦</font>牌当【乐不思蜀】对辛弃疾使用",
}

local zongze = General(extension, "lingling__zongze", "song", 3)
local duhe = fk.CreateActiveSkill{
  name = "lingling__duhe",
  anim_type = "offensive",
  card_num = 1,
  target_num = 1,
  prompt = "#lingling__duhe",
  target_tip = function(self, to_select, selected, selected_cards, _, selectable)
    if not selectable then return end
    if Self:getLastAlive().id == to_select or Self:getNextAlive().id == to_select then
      return "lingling__duhe_tip_1"
    else
      return "lingling__duhe_tip_2"
    end
  end,
  can_use = function (self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  card_filter = function (self, to_select, selected)
    return #selected == 0 and Fk:getCardById(to_select).trueName == "jink"
  end,
  target_filter = function(self, to_select, selected)
    if #selected == 0 then
      if Self:getLastAlive().id == to_select or Self:getNextAlive().id == to_select then
        return not Fk:currentRoom():getPlayerById(to_select):isNude() --and Self:getMark("lingling__duhe2-phase") == 0
      else
        return true --Self:getMark("lingling__duhe1-phase") == 0
      end
    end
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    room:recastCard(effect.cards, player, self.name)
    if target.dead then return end
    if player:getLastAlive() == target or player:getNextAlive() == target then
      --room:setPlayerMark(player, "lingling__duhe2-phase", 1)
      if not player.dead and not target:isNude() and target ~= player then
        local card = room:askForCardChosen(player, target, "he", self.name, "#lingling__duhe-prey::"..target.id)
        room:moveCardTo(card, Card.PlayerHand, player, fk.ReasonPrey, self.name, nil, false, player.id)
      end
    else
      --room:setPlayerMark(player, "lingling__duhe1-phase", 1)
      room:damage{
        from = player,
        to = target,
        damage = 1,
        skillName = self.name,
      }
    end
  end,
}
local duhe_trigger = fk.CreateTriggerSkill{
  name = "#lingling__duhe_trigger",
  anim_type = "masochism",
  frequency = Skill.Compulsory,
  events = {fk.Damaged},
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(duhe)
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local cards = room:getCardsFromPileByRule("jink", 1, "allPiles")
    if #cards > 0 then
      room:moveCardTo(cards, Card.PlayerHand, player, fk.ReasonJustMove, "lingling__duhe", nil, true, player.id)
    end
  end,
}
local shangyou = fk.CreateTriggerSkill{
  name = "lingling__shangyou",
  anim_type = "control",
  events = {fk.TurnEnd},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and not player:isKongcheng() and #player:getTableMark(self.name) < 3
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local success, dat = room:askForUseActiveSkill(player, "lingling__shangyou_active", "#lingling__shangyou-invoke", true)
    if success and dat then
      self.cost_data = {cards = dat.cards, choice = dat.interaction}
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:addTableMark(player, self.name, Util.PhaseStrMapper(self.cost_data.choice))
    room:recastCard(self.cost_data.cards, player, self.name)
    if player.dead then return end
    room:loseHp(player, 1, self.name)
    if player.dead then return end
    local to = player:getLastAlive(true)
    if to == player then return end
    room:swapSeat(player, to)
    if room:askForSkillInvoke(player, self.name, nil, "#lingling__shangyou-ask::"..to.id) then
      to:turnOver()
    end
    if self:triggerable(event, target, player, data) then
      self:doCost(event, target, player, data)
    end
  end,

  refresh_events = {fk.EventPhaseChanging},
  can_refresh = function(self, event, target, player, data)
    return target == player and table.contains(player:getTableMark(self.name), data.to)
  end,
  on_refresh = function(self, event, target, player, data)
    data.to = Player.Play
  end,
}
local shangyou_active = fk.CreateActiveSkill{
  name = "lingling__shangyou_active",
  card_num = 1,
  target_num = 0,
  interaction = function()
    local all_choices = {"phase_judge", "phase_draw", "phase_discard"}
    local choices = table.filter(all_choices, function (s)
      return not table.contains(Self:getTableMark("lingling__shangyou"), Util.PhaseStrMapper(s))
    end)
    return UI.ComboBox {choices = choices, all_choices = all_choices}
  end,
  card_filter = function (self, to_select, selected)
    return #selected == 0 and Fk:getCardById(to_select).trueName == "slash"
  end,
}
duhe:addRelatedSkill(duhe_trigger)
Fk:addSkill(shangyou_active)
zongze:addSkill(duhe)
zongze:addSkill(shangyou)
Fk:loadTranslationTable{
  ["lingling__zongze"] = "宗泽",
  ["#lingling__zongze"] = "日月争光",
  ["illustrator:lingling__zongze"] = "伊达未来",
  ["designer:lingling__zongze"] = "伶",

  ["lingling__duhe"] = "渡河",
  [":lingling__duhe"] = "出牌阶段限一次，你可以重铸一张【闪】，然后对一名与你不相邻的角色造成1点伤害，或获得一名与你相邻的角色一张牌。"..
  "当你受到伤害后，你获得一张【闪】。",
  ["lingling__shangyou"] = "上游",
  [":lingling__shangyou"] = "回合结束时，你可以执行任意次：重铸一张【杀】并失去1点体力，将一个出牌阶段外的阶段（判定阶段、摸牌阶段、弃牌阶段）"..
  "永久变为出牌阶段，然后与上家交换位置，且你可以令其翻面。"..
  "<br><br> <font color = '#a40000'>谁人共挽天河水，尽洗中原犬虏腥。",
  ["#lingling__duhe"] = "渡河：重铸一张【闪】，对一名不相邻角色造成1点伤害，或获得一名相邻角色一张牌",
  ["lingling__duhe_tip_1"] = "获得牌",
  ["lingling__duhe_tip_2"] = "造成伤害",
  ["#lingling__duhe-prey"] = "渡河：获得 %dest 一张牌",
  ["#lingling__duhe_trigger"] = "渡河",
  ["lingling__shangyou_active"] = "上游",
  ["#lingling__shangyou-invoke"] = "上游：是否重铸一张【杀】并失去1点体力，将一个阶段改为出牌阶段并与上家交换位置？",
  ["#lingling__shangyou-ask"] = "上游：是否令 %dest 翻面？",
}

local fanzhongyan = General(extension, "lingling__fanzhongyan", "song", 3)
local mingsi = fk.CreateTriggerSkill{
  name = "lingling__mingsi",
  anim_type = "control",
  events = {fk.TurnEnd},
  can_trigger = function (self, event, target, player, data)
    return player:hasSkill(self) and target:inMyAttackRange(player)
  end,
  on_cost = function (self, event, target, player, data)
    local use = U.askForPlayCard(player.room, player, nil, nil, self.name, "#lingling__mingsi-use", {bypass_times = true}, true)
    if use then
      self.cost_data = use
      return true
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local use = self.cost_data
    use.extraUse = true
    local n = use.card.type == Card.TypeTrick and 2 or 1
    player:drawCards(n, self.name)
    room:useCard(use)
    if target.dead or player.dead then return end
    local yes = #room.logic:getEventsOfScope(GameEvent.UseCard, 1, function(e)
      local u = e.data[1]
      return u.from == target.id and u.card.trueName == use.card.trueName
    end, Player.HistoryTurn) == 0
    if yes then
      use = room:askForUseCard(target, self.name, "slash", "#lingling__mingsi-slash:"..player.id, true,
        {
          bypass_distances = true,
          bypass_times = true,
          must_targets = {player.id},
        })
      if use then
        use.extraUse = true
        room:useCard(use)
      end
    end
  end,
}
local youle = fk.CreateTriggerSkill{
  name = "lingling__youle",
  anim_type = "special",
  frequency = Skill.Compulsory,
  events = {fk.EventPhaseChanging, fk.DrawNCards},
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(self) then
      if event == fk.EventPhaseChanging then
        return data.to == Player.Draw or data.to == Player.Discard
      elseif event == fk.DrawNCards then
        return 2 * #table.filter(player.room.alive_players, function (p)
          return p:isWounded()
        end) < #player.room.alive_players
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    if event == fk.EventPhaseChanging then
      if data.to == Player.Draw then
        data.to = Player.Discard
      elseif data.to == Player.Discard then
        data.to = Player.Draw
      end
    elseif event == fk.DrawNCards then
      data.n = data.n + 1
    end
  end,
}
local youle_maxcards = fk.CreateMaxCardsSkill{
  name = "#youle_maxcards",
  correct_func = function(self, player)
    if player:hasSkill(youle) then
      return 1
    end
  end,
}
youle:addRelatedSkill(youle_maxcards)
fanzhongyan:addSkill(mingsi)
fanzhongyan:addSkill(youle)
Fk:loadTranslationTable{
  ["lingling__fanzhongyan"] = "范仲淹",
  ["#lingling__fanzhongyan"] = "一世之师",
  ["illustrator:lingling__fanzhongyan"] = "珊瑚虫",
  ["designer:lingling__fanzhongyan"] = "伶",

  ["lingling__mingsi"] = "鸣死",
  [":lingling__mingsi"] = "攻击范围内有你的其他角色回合结束时，你可以使用一张牌并摸一张牌（使用锦囊牌则摸两张），若与其本回合使用的牌名称皆不同，"..
  "则其可以对你使用一张【杀】。",
  ["lingling__youle"] = "忧乐",
  [":lingling__youle"] = "你的手牌上限+1。你交换摸牌阶段和弃牌阶段的顺序。若场上受伤角色数少于一半，则摸牌阶段你多摸一张牌。"..
  "<br><br> <font color = '#a40000'>为社稷之固者，莫知范仲淹。",
  ["#lingling__mingsi-use"] = "鸣死：你可以使用一张牌并摸一张牌，使用锦囊牌则摸两张",
  ["#lingling__mingsi-slash"] = "鸣死：是否对 %src 使用一张【杀】？",
}

local baozheng = General(extension, "lingling__baozheng", "song", 4, 4, General.Male)
local shengtang = fk.CreateActiveSkill{
  name = "lingling__shengtang",
  anim_type = "control",
  card_num = 0,
  target_num = 1,
  prompt = "#lingling__shengtang-prompt",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, to_select, selected)
    if #selected == 0 and to_select ~= Self.id then
    local target = Fk:currentRoom():getPlayerById(to_select)
    if target and not target:isKongcheng() then
    for _, cid in ipairs(target:getCardIds('h')) do
      if Self:cardVisible(cid) then
        return false end
      end
      return true
    end
  end
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    local cards ={}
    if #room.draw_pile>0 then
      table.insert(cards,table.random(room.draw_pile,1)[1])
    end
    local cardIds = {}
    if #room.discard_pile>0 then
      table.insert(cards,table.random(room.discard_pile,1)[1])
    end
    local id = table.random(target.player_cards[Player.Hand])
    table.insert(cards, id)
    table.shuffle(cards)
    player:showCards(cards)
    room:delay(500)
    local id2 = room:askForCardChosen(player, target, {
      card_data = {
        { "$Hand", cards }
      }
    }, self.name, "#lingling__shengtang-card")
    if id2 ~= id then
      room:sendLog{
        type = "#lingling__shengtang_bad",
        toast = true,
      }
      room:loseHp(player,1,self.name)
      table.removeOne(cards,id)
      if #cards>0 and player:isAlive() then
      room:moveCardTo(cards, Player.Hand, player, fk.ReasonPrey, self.name, nil, false, player.id)
      end
    else
      room:doIndicate(player.id,{target.id})
      room:sendLog{
        type = "#lingling__shengtang_good",
        toast = true,
      }
      room:setPlayerMark(target,"@@lingling__shengtang_tonot",1)
      room:damage{
        from = player,
        to = target,
        damage = 1,
        skillName = self.name,
        damageType = fk.NormalDamage
      }
    end
  end,
}
local shengtang_trigger = fk.CreateTriggerSkill{
  name = "#lingling__shengtang_trigger",
  refresh_events = {fk.TurnEnd,fk.TargetConfirming},
  can_refresh = function (self, event, target, player, data)
    if target == player and player:getMark("@@lingling__shengtang_tonot")~=0 then
    if event == fk.TargetConfirming then
      return data.card.name == "peach"
    else
    return true 
    end
  end
  end,
  on_refresh = function (self, event, target, player, data)
    local room = player.room
    if event == fk.TargetConfirming then
      AimGroup:cancelTarget(data, player.id)
      return true
    else
    room:setPlayerMark(target,"@@lingling__shengtang_tonot",0)
    --room:setPlayerMark(target,"@@lingling__shengtang_not-turn",1)
    end
  end,
}
--[[local shengtang_prohibit = fk.CreateProhibitSkill{
 name = "#lingling__shengtang_prohibit",
  is_prohibited = function(self, from, to, card)
      return from:getMark("@@lingling__shengtang_not-turn") ~= 0 and card.name == 'peach'
  end,
}--]]
local zhuixiong = fk.CreateTriggerSkill{
  name = "lingling__zhuixiong",
  events = {fk.TurnEnd},
  can_trigger = function (self, event, target, player, data)
    if target == player and player:hasSkill(self) then
      return #player.room.alive_players > 1
    end
  end,
  on_cost = function (self, event, target, player, data)
    return true
  end,
  on_trigger = function (self, event, target, player, data)
    local room = player.room
    local ids = table.map(room.alive_players,Util.IdMapper)
    if #ids>1 then
      local tos = table.random(ids,2)
      local to = room:askForChoosePlayers(player,tos,1,1,"#lingling__zhuixiong-choose",self.name,false,true)
      if #to>0 then
        local mark = player:getTableMark("@@lingling__zhuixiong_guess")
        table.insert(mark,{tos,to[1]})
        room:setPlayerMark(player,"@@lingling__zhuixiong_guess",mark)
      end
    end
  end,
  refresh_events = {fk.Damage,fk.AfterPhaseEnd},
  can_refresh = function (self, event, target, player, data)
    if #player:getTableMark("@@lingling__zhuixiong_guess")>0 then
      if event == fk.AfterPhaseEnd then
        return player.phase == Player.Play
      else
        if target.phase == Player.Play then
      for _, group in ipairs(player:getTableMark("@@lingling__zhuixiong_guess")) do
          if table.contains(group[1],data.from.id) then
            return true
          end
      end
    end
      return false
    end
  end
  end,
  on_refresh = function (self, event, target, player, data)
    local room = player.room
    if event == fk.AfterPhaseEnd then
      room:setPlayerMark(player,"@@lingling__zhuixiong_guess",0)
    else
      local mark = player:getTableMark("@@lingling__zhuixiong_guess")
        for i=#mark,1,-1 do
          if table.contains(mark[i][1],data.from.id) then
            if mark[i][2] == data.from.id then
              room:sendLog{
                type = "#lingling__zhuixiong_good",
                toast = true,
              }
              room:doIndicate(player.id,{data.from.id})
              local choices = {"#lingling__zhuixiong-draw"}
              if data.from:isAlive() and not data.from:isKongcheng() then
                local can = true
                  for _, cid in ipairs(data.from:getCardIds('h')) do
                    if player:cardVisible(cid) then
                      can = false break end
                    end
                    if can == true then
                      table.insertIfNeed(choices,"#lingling__zhuixiong-go")
                    end
                  end
                  table.insertIfNeed(choices,"Cancel")
                  if #choices>0 then
                  local choise = room:askForChoice(player,choices,self.name,"#lingling__zhuixiong-pick::"..data.from.id,false,{"#lingling__zhuixiong-draw","#lingling__zhuixiong-go","Cancel"})
                        if choise == "#lingling__zhuixiong-draw" then
                          room:drawCards(player,2,self.name)
                        elseif choise == "#lingling__zhuixiong-go" then
                          Fk.skills["lingling__shengtang"]:onUse(room, {from = player.id, tos = {data.from.id}})
                        end
                      end
            end
            table.remove(mark,i) 
          end
      end
      if #mark == 0 then
        room:setPlayerMark(player,"@@lingling__zhuixiong_guess",0)
      else
        room:setPlayerMark(player,"@@lingling__zhuixiong_guess",mark)
        end
    end
  end,
}
shengtang:addRelatedSkill(shengtang_trigger)
--shengtang:addRelatedSkill(shengtang_prohibit)
baozheng:addSkill(shengtang)
baozheng:addSkill(zhuixiong)
Fk:loadTranslationTable{
  ["lingling__baozheng"] = "包拯",
  ["#lingling__baozheng"] = "包青天",
  ["designer:lingling__baozheng"] = "伶",
  ["illustrator:lingling__baozheng"] = "珊瑚虫",

  ["lingling__shengtang"] = "升堂",
  [":lingling__shengtang"] = "出牌阶段限一次，你可以将一名手牌对你均不可见的其他角色的随机一张手牌与牌堆和弃牌堆中随机各一张牌混合，然后你猜测哪张牌来自其手牌，若：猜对，你对其造成1点伤害且其成为【桃】的目标时取消之直到其的回合结束；猜错，你失去1点体力并获得其中不为手牌的牌。",
  ["lingling__zhuixiong"] = "追凶",
  [":lingling__zhuixiong"] = "回合结束时，你从随机两名角色中猜测直到你的下个出牌阶段结束，其中哪名角色先于其出牌阶段内造成伤害，若猜对，其造成此伤害后你可以摸两张牌或对其发动“升堂”。"..
  "<br><br> <font color = '#a40000'>关节不到，有阎罗包老。",

  ["#lingling__shengtang-prompt"] = "升堂:将一名其他角色的一张手牌与牌堆顶，弃牌堆各一张牌混合后，猜测哪张来自其手牌",
  ["#lingling__shengtang-card"] = "升堂:选择你认为来自其手牌的一张牌",
  ["@@lingling__shengtang_not-turn"]="被升堂",
  ["#lingling__zhuixiong-choose"]="追凶：猜测他们中哪一位在其出牌阶段内先造成伤害",
  ["#lingling__zhuixiong-pick"]="追凶：凶手是 %dest ！你准备做些什么？",
  ["#lingling__zhuixiong-draw"]="摸两张牌",
  ["#lingling__zhuixiong-go"]="对其发动“升堂”！",
  ["@@lingling__zhuixiong_guess"]="追凶中……",
  ["@@lingling__shengtang_tonot"]="被升堂",
  ["#lingling__shengtang_good"]="今天谁也救不了你！来人！狗头铡伺候！",
  ["#lingling__shengtang_bad"]="此事颇有蹊跷！待本府再细细定夺。",
  ["#lingling__zhuixiong_good"]="天理昭昭！你哪里逃！",
}

local lilongji = General(extension, "lingling__lilongji", "tang", 4)
local shuairong = fk.CreateActiveSkill{
  name = "lingling__shuairong",
  anim_type = "control",
  card_num = 0,
  target_num = 0,
  prompt = "#lingling__shuairong",
  interaction = function()
    return UI.ComboBox { choices = {"2", "4"} }
  end,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    room:doIndicate(player.id, table.map(room.alive_players, Util.IdMapper))
    local num = tonumber(self.interaction.data)
    for _, p in ipairs(room:getAlivePlayers()) do
      if not p.dead then
        local cnum = num - p:getHandcardNum()
        if cnum > 0 then
          local cids = p:drawCards(cnum, self.name)
          if #cids > 2 and not p.dead then
            p:turnOver()
          end
        elseif cnum < 0 then
          cnum = - cnum
          local cids = room:askForDiscard(p, cnum, cnum, false, self.name, false)
          if #cids > 2 and not player.dead then
            player:turnOver()
          end
        end
      end
    end
  end,
}
local cuochong = fk.CreateTriggerSkill{
  name = "lingling__cuochong",
  anim_type = "control",
  events = {fk.TurnedOver},
  can_trigger = function (self, event, target, player, data)
    return player:hasSkill(self) and not target.dead and not target.faceup
  end,
  on_cost = function (self, event, target, player, data)
    local all_choices = {"lingling__cuochong_draw:"..player.id, "lingling__cuochong_discard:"..player.id, "Cancel"}
    local choices = table.simpleClone(all_choices)
    if player:isNude() then
      table.remove(choices, 2)
    end
    local choice = player.room:askForChoice(target, choices, self.name, "#lingling__cuochong-choice:"..player.id, false, all_choices)
    if choice ~= "Cancel" then
      self.cost_data = {choice = choice}
      return true
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    room:doIndicate(target.id, {player.id})
    if self.cost_data.choice:startsWith("lingling__cuochong_draw") then
      player:drawCards(1, self.name)
    else
      room:askForDiscard(player, 1, 1, true, self.name, false)
    end
  end,
}
local bozheng = fk.CreateTriggerSkill{
  name = "lingling__bozheng",
  priority = 2,
  anim_type = "support",
  frequency = Skill.Limited,
  events = {fk.TurnedOver},
  can_trigger = function (self, event, target, player, data)
    return player:hasSkill(self) and not target.dead and not target.faceup and player:usedSkillTimes(self.name, Player.HistoryGame) == 0
  end,
  on_cost = function (self, event, target, player, data)
    if player.room:askForSkillInvoke(player, self.name, nil, "#lingling__bozheng-invoke::"..target.id) then
      self.cost_data = {tos = {target.id}}
      return true
    end
  end,
  on_use = function (self, event, target, player, data)
    target:drawCards(2, self.name)
    if not target.dead then
      target:turnOver()
    end
  end,
}
lilongji:addSkill(shuairong)
lilongji:addSkill(cuochong)
lilongji:addSkill(bozheng)
Fk:loadTranslationTable{
  ["lingling__lilongji"] = "李隆基",
  ["#lingling__lilongji"] = "再开唐统",
  ["designer:lingling__lilongji"] = "伶",
  ["illustrator:lingling__lilongji"] = "伊达未来",

  ["lingling__shuairong"] = "衰荣",
  [":lingling__shuairong"] = "出牌阶段限一次，你可以令所有角色依次将手牌调整至两张或四张。若有角色因此：摸了至少三张牌，其翻面；"..
  "弃置了至少三张牌，你翻面。",
  ["lingling__cuochong"] = "错宠",
  [":lingling__cuochong"] = "当一名角色翻至背面后，其可以令你摸一张牌或弃置一张牌。",
  ["lingling__bozheng"] = "拨正",
  [":lingling__bozheng"] = "限定技，当一名角色翻至背面时，你可以令其翻至正面并摸两张牌。"..
  "<br><br> <font color='#a40000'>巍冠攒叠碧雪花，坐阅山中几岁华。<br>莫把金丹轻点化，正愁生死困安家。</font>",
  ["#lingling__shuairong"] = "衰荣：令所有角色将手牌调整至2或4",
  ["#lingling__shuairong-discard"] = "衰荣：你须弃置 %arg 张牌",
  ["#lingling__cuochong-choice"] = "错宠：你可以令 %src 执行一项",
  ["lingling__cuochong_draw"] = "%src 摸一张牌",
  ["lingling__cuochong_discard"] = "%src 弃置一张牌",
  ["#lingling__bozheng-invoke"] = "拨正：是否令 %dest 翻至正面并摸两张牌？",

  ["$lingling__bozheng1"] = "拨乱世，反诸正，君王者当如是。",
  ["$lingling__bozheng2"] = "至东都，赦天下，神龙易位，再开唐统。",
}

local limiw = General(extension, "lingling__limiw", "qun", 4)
local shidu = fk.CreateViewAsSkill{
  name = "lingling__shidu",
  anim_type = "drawcard",
  pattern = "ex_nihilo",
  prompt = "#lingling__shidu",
  card_filter = function(self, to_select, selected)
    return #selected == 0 and table.contains({"analeptic"}, Fk:getCardById(to_select).trueName)
  end,
  view_as = function(self, cards)
    if #cards ~= 1 then return end
    local card = Fk:cloneCard("ex_nihilo")
    card:addSubcards(cards)
    card.skillName = self.name
    return card
  end,
  enabled_at_response = function (self, player, response)
    return not response
  end,
}
local shidu_trigger = fk.CreateTriggerSkill{
  name = "#lingling__shidu_trigger",
  mute = true,
  frequency = Skill.Compulsory,
  main_skill = shidu,
  events = {fk.DamageCaused, fk.DamageInflicted},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(shidu) and data.damage > 1
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke("lingling__shidu")
    if data.damage > 1 then
      if event == fk.DamageCaused then
        room:notifySkillInvoked(player, "lingling__shidu", "negative")
      else
        room:notifySkillInvoked(player, "lingling__shidu", "defensive")
      end
      data.damage = 1
    else
      --[[if room:askForSkillInvoke(player, "lingling__shidu", nil, "#lingling__shidu-invoke") then
        room:notifySkillInvoked(player, "lingling__shidu", "drawcard")
        local turn_event = player.room.logic:getCurrentEvent():findParent(GameEvent.Turn)
        if turn_event and turn_event.data[1] == player then
          room:setPlayerMark(player, "lingling__shidu-turn", 1)
        end
        room:changeMaxHp(player, -1)
        if not player.dead then
          player:drawCards(2, "lingling__shidu")
        end
      end]]--
    end
  end,
}
local fanfu = fk.CreateTriggerSkill{
  name = "lingling__fanfu",
  mute = true,
  frequency = Skill.Compulsory,
  events = {fk.AfterCardsMove},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) then
      if player.phase ~= Player.NotActive and player.phase ~= Player.Draw then
        for _, move in ipairs(data) do
          if move.to == player.id and move.toArea == Card.PlayerHand and move.skillName ~= self.name then
            return true
          end
        end
      elseif player.phase == Player.NotActive and not player:isNude() then
        for _, move in ipairs(data) do
          if move.from == player.id and move.moveReason ~= fk.ReasonUse and move.moveReason ~= fk.ReasonResonpse and
            not (move.skillName and Fk.skills[move.skillName] and
            table.find(player.room.players, function (p)
              return p:hasSkill(move.skillName, true, true)
            end)) then
            for _, info in ipairs(move.moveInfo) do
              if info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip then
                return true
              end
            end
          end
        end
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke(self.name)
    if player.phase ~= Player.NotActive then
      room:notifySkillInvoked(player, self.name, "drawcard")
      player:drawCards(1, self.name)
    else
      room:notifySkillInvoked(player, self.name, "negative")
      room:askForDiscard(player, 1, 1, true, self.name, false)
    end
  end,
}
local kaicang = fk.CreateActiveSkill{
  name = "lingling__kaicang",
  anim_type = "control",
  card_num = 0,
  target_num = 1,
  prompt = "#lingling__kaicang",
  frequency = Skill.Limited,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryGame) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, to_select, selected, selected_cards)
    local target = Fk:currentRoom():getPlayerById(to_select)
    return #selected == 0 and target:getHandcardNum() > target.hp
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    room:changeMaxHp(player, -1)
    if player.dead or target.dead then return end
    local n = target:getHandcardNum() - target.hp
    if n > 0 then
      local cards = room:askForCardsChosen(player, target, 1, n, "he", self.name, "#lingling__kaicang-ask::"..target.id..":"..n)
      room:moveCards({
        ids = cards,
        from = target.id,
        toArea = Card.DrawPile,
        moveReason = fk.ReasonPut,
        skillName = self.name,
        moveVisible = false,
        drawPilePosition = 1,
      })
    end
    local card = Fk:cloneCard("amazing_grace")
    card.skillName = self.name
    if player:canUse(card) then
      room:useCard({
        from = player.id,
        card = card,
      })
    end
  end,
}
shidu:addRelatedSkill(shidu_trigger)
limiw:addSkill(shidu)
limiw:addSkill(fanfu)
limiw:addSkill(kaicang)
Fk:loadTranslationTable{
  ["lingling__limiw"] = "李密",
  ["#lingling__limiw"] = "为龙为蛇",
  ["designer:lingling__limiw"] = "伶",
  ["illustrator:lingling__limiw"] = "伊达未来",

  ["lingling__shidu"] = "识度",
  --[[[":lingling__shidu"] = "当你造成或受到伤害时，若伤害大于1则减至1，若伤害为1，你可以减1点体力上限并摸两张牌（你回合内限以此法摸牌一次）。"..
  "你可以将【酒】或【桃】当【无中生有】使用。",]]--
  [":lingling__shidu"] = "当你造成或受到伤害时，若伤害大于1则减至1。你可以将【酒】当【无中生有】使用。",
  ["lingling__fanfu"] = "反复",
  [":lingling__fanfu"] = "你回合内，你不因摸牌阶段和此技能获得牌后，你摸一张牌。你回合外，你不因使用打出牌和角色技能失去牌后，你弃置一张牌。",
  ["lingling__kaicang"] = "开仓",
  [":lingling__kaicang"] = "限定技，出牌阶段，你可以减1点体力上限，将一名手牌多于体力的角色至多X张牌置于牌堆顶（X为其手牌与体力的差值），"..
  "然后你视为使用【五谷丰登】。"..
  "<br><br> <font color='#a40000'>君世素贵，当以才学显，何事三卫间哉！",
  ["#lingling__shidu"] = "识度：你可以将【酒】当【无中生有】使用",
  ["#lingling__kaicang"] = "开仓：减1点体力上限，将一名手牌多于体力角色的牌置于牌堆顶，视为使用【五谷丰登】！",
  ["#lingling__kaicang-ask"] = "开仓：选择 %dest 的至多%arg张牌置于牌堆顶",

  ["$lingling__kaicang1"] = "隋主无道，而天有道！",
  ["$lingling__kaicang2"] = "伪施济难之事，欲取扬名之实！",
}

local guanyu = General(extension, "lingling__guanyu", "shu", 4)
local wusheng = fk.CreateViewAsSkill{
  name = "lingling__wusheng",
  anim_type = "offensive",
  prompt = "#lingling__wusheng",
  interaction = function(self)
    local all_names = {"slash", "duel"}
    local names = U.getViewAsCardNames(Self, self.name, all_names)
    if #names > 0 then
      return U.CardNameBox {choices = names, all_choices = all_names}
    end
  end,
  card_filter = function(self, to_select, selected)
    local card = Fk:getCardById(to_select)
    if #selected == 0 and card.color == Card.Red then
      if self.interaction.data == "duel" then
        return card.trueName == "slash"
      else
        return true
      end
    end
  end,
  view_as = function(self, cards)
    if not self.interaction.data or #cards == 0 then return end
    local card = Fk:cloneCard(self.interaction.data)
    card:addSubcard(cards[1])
    card.skillName = self.name
    return card
  end,
}
local wusheng_trigger = fk.CreateTriggerSkill{
  name = "#lingling__wusheng_trigger",
  anim_type = "offensive",
  main_skill = wusheng,
  events = {fk.TurnStart, fk.DamageCaused},
  can_trigger = function(self, event, target, player, data)
    if event == fk.TurnStart then
      return player:hasSkill(wusheng) and target == player and #player.room:getOtherPlayers(player) > 0
    elseif event == fk.DamageCaused then
      local mark = player:getMark("lingling__wusheng")
      if target and type(mark) == "table" then
        return ((target == player and data.to.id == mark[1] and mark[2]) or
          (data.to == player and target.id == mark[1] and mark[3]))
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    if event == fk.TurnStart then
      local to = room:askForChoosePlayers(player, table.map(room:getOtherPlayers(player), Util.IdMapper), 1, 1,
        "#lingling__wusheng-choose", "lingling__wusheng", true)
      if #to > 0 then
        self.cost_data = {tos = to}
        return true
      end
    else
      self.cost_data = nil
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if event == fk.TurnStart then
      local to = room:getPlayerById(self.cost_data.tos[1])
      room:setPlayerMark(player, "lingling__wusheng", {to.id,true,true})
      room:setPlayerMark(player, "@lingling__wusheng", Fk:translate(to.general))
    else
      local mark = player:getMark("lingling__wusheng")
      if (data.to.id == mark[1]) then
        mark[2] = false
      else
        mark[3] = false
      end
      room:setPlayerMark(player, "lingling__wusheng", mark)
      data.damage = data.damage + 1
    end
  end,

  refresh_events = {fk.TurnStart},
  can_refresh = function(self, event, target, player, data)
    return target == player and player:getMark("lingling__wusheng") ~= 0
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(player, "lingling__wusheng", 0)
    room:setPlayerMark(player, "@lingling__wusheng", 0)
    room:setPlayerMark(player, "lingling__wusheng_record", 0)
  end
}
local wusheng_distance = fk.CreateDistanceSkill{
  name = "#lingling__wusheng_distance",
  fixed_func = function(self, from, to)
    if type(from:getMark("lingling__wusheng")) == "table" and from:getMark("lingling__wusheng")[1] == to.id then
      return 1
    end
    if type(to:getMark("lingling__wusheng"))  == "table" and to:getMark("lingling__wusheng")[1] == from.id then
      return 1
    end
  end,
}
local yijue = fk.CreateTriggerSkill{
  name = "lingling__yijue",
  switch_skill_name = "lingling__yijue",
  anim_type = "drawcard",
  frequency = Skill.Compulsory,
  events = {fk.DamageCaused, fk.DamageInflicted},
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(self) then
      if player:getSwitchSkillState(self.name, false) == fk.SwitchYang and event == fk.DamageInflicted then
        return data.damage >= player.hp + player.shield
      elseif player:getSwitchSkillState(self.name, false) == fk.SwitchYin and event == fk.DamageCaused then
        return data.damage >= data.to.hp + data.to.shield
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(2, self.name)
    return true
  end
}
wusheng:addRelatedSkill(wusheng_distance)
wusheng:addRelatedSkill(wusheng_trigger)
guanyu:addSkill(wusheng)
guanyu:addSkill(yijue)
Fk:loadTranslationTable{
  ["lingling__guanyu"] = "关羽",
  ["#lingling__guanyu"] = "以身证道",
  ["illustrator:lingling__guanyu"] = "伊达未来",
  ["designer:lingling__guanyu"] = "伶",

  ["lingling__wusheng"] = "武圣",
  [":lingling__wusheng"] = "你可以将红色牌当【杀】、红色【杀】当【决斗】使用或打出。回合开始时，你可以指定一名其他角色，你与其互相计算距离视为1，"..
  "且下一次互相造成的伤害+1，直到你下回合开始。",
  ["lingling__yijue"] = "义绝",
  [":lingling__yijue"] = "锁定技，转换技，当你①受到②造成致命伤害时，你摸两张牌防止之。"..
  "<br><br> <font color = '#a40000'>先谱炎汉，再读春秋。",
  ["#lingling__wusheng"] = "武圣：你可以将红色牌当【杀】、红色【杀】当【决斗】使用或打出",
  ["#lingling__wusheng_trigger"] = "武圣",
  ["#lingling__wusheng-choose"] = "武圣：选择一名其他角色，你与其互相计算距离视为1、下一次互相造成的伤害+1，直到你下回合开始。",
  ["@lingling__wusheng"] = "武圣",
}


local simayi = General(extension, "lingling__simayi", "wei", 3)
local chaobing = fk.CreateTriggerSkill{
  name = "lingling__chaobing",
  anim_type = "control",
  events = {fk.AskForRetrial, fk.SkillEffect},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) then
      if event == fk.AskForRetrial then
        return not player:isNude()
      elseif event == fk.SkillEffect then
        if target and target ~= player and not table.contains(player:getTableMark("lingling__chaobing-turn"), target.id) and
          target:hasSkill(data, true) and data:isPlayerSkill(target) and not data.name:startsWith("#") then
          player.room:addTableMark(player, "lingling__chaobing-turn", target.id)
          return player:getMark("lingling__chaobing-round") == 0
        end
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    if event == fk.AskForRetrial then
      local card = room:askForCard(player, 1, 1, true, self.name, true, nil,
        "#lingling__chaobing-ask::"..target.id..":"..data.reason)
      if #card > 0 then
        self.cost_data = {cards = card}
        return true
      end
    elseif event == fk.SkillEffect then
      if room:askForSkillInvoke(player, self.name, nil, "#lingling__chaobing-invoke::"..target.id..":"..data.name) then
        self.cost_data = {tos = {target.id}}
        return true
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if event == fk.AskForRetrial then
      local card = Fk:getCardById(self.cost_data.cards[1])
      room:retrial(card, player, data, self.name, true)
    elseif event == fk.SkillEffect then
      room:setPlayerMark(player, "lingling__chaobing-round", 1)
      local judge = {
        who = player,
        reason = self.name,
        pattern = ".|.|spade",
      }
      room:judge(judge)
      if judge.card.suit == Card.Spade then
        room:invalidateSkill(target, data.name, "-turn")
        if data.main_skill then
          room:invalidateSkill(target, data.main_skill.name, "-turn")
        end
        local e = room.logic:getCurrentEvent():findParent(GameEvent.SkillEffect)
        if e and e.data[3].name == data.name then
          e:shutdown()
        end
      end
    end
  end,
}
local langgu = fk.CreateTriggerSkill{
  name = "lingling__langgu",
  anim_type = "control",
  events = {fk.TargetSpecified, fk.TargetConfirmed},
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(self) and data.card.trueName == "slash" then
      if event == fk.TargetSpecified then
        return player:getHandcardNum() <= player.room:getPlayerById(data.to):getHandcardNum()
      elseif event == fk.TargetConfirmed then
        return player:getHandcardNum() <= player.room:getPlayerById(data.from):getHandcardNum()
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    local prompt = "#lingling__langgu-invoke::"..data.to
    if event == fk.TargetConfirmed then
      prompt = "#lingling__langgu-invoke::"..data.from
    end
    return player.room:askForSkillInvoke(player, self.name, nil, prompt)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local judge = {
      who = player,
      reason = self.name,
      pattern = ".|.|spade,club",
      skipDrop = true,
    }
    room:judge(judge)
    if not player.dead and judge.card.color == Card.Black then
      local to
      if event == fk.TargetSpecified then
        to = room:getPlayerById(data.to)
      elseif event == fk.TargetConfirmed then
        to = room:getPlayerById(data.from)
      end
      local choices = {}
      if not to.dead and not to:isNude() and to ~= player then
        table.insert(choices, "lingling__langgu_prey::"..to.id)
      end
      if room:getCardArea(judge.card) == Card.Processing then
        table.insert(choices, "lingling__langgu_get")
      end
      if #choices > 0 then
        local choice = room:askForChoice(player, choices, self.name)
        if choice == "lingling__langgu_get" then
          room:moveCardTo(judge.card, Card.PlayerHand, player, fk.ReasonJustMove, self.name, nil, true, player.id)
        else
          if room:getCardArea(judge.card) == Card.Processing then
            room:moveCardTo(judge.card, Card.DiscardPile, nil, fk.ReasonJudge)
          end
          local card = room:askForCardChosen(player, to, "he", self.name, "#lingling__langgu-prey::"..to.id)
          room:moveCardTo(card, Card.PlayerHand, player, fk.ReasonPrey, self.name, nil, false, player.id)
        end
      end
    else
      room:moveCardTo(judge.card, Card.DiscardPile, nil, fk.ReasonJudge)
    end
  end,
}
simayi:addSkill(chaobing)
simayi:addSkill(langgu)
Fk:loadTranslationTable{
  ["lingling__simayi"] = "司马懿",
  ["#lingling__simayi"] = "洛水无声",
  ["illustrator:lingling__simayi"] = "伊达未来",
  ["designer:lingling__simayi"] = "伶",

  ["lingling__chaobing"] = "朝柄",
  [":lingling__chaobing"] = "当一名角色的判定牌生效前，你可以用一张牌替换之。每轮限一次，其他角色每回合首次发动技能时，你可以判定，"..
  "♠则停止其该技能结算，且其该技能本回合无效。",
  ["lingling__langgu"] = "狼顾",
  [":lingling__langgu"] = "当你使用或被使用【杀】后，若对方手牌不少于你，你可以判定，若为黑色，你获得对方一张牌或判定牌。"..
  "<br><br> <font color = '#a40000'>六朝何事，门户私计。",
  ["#lingling__chaobing-ask"] = "朝柄：你可以用一张牌替换 %dest 的“%arg”判定",
  ["#lingling__chaobing-invoke"] = "朝柄：%dest 发动“%arg”，是否进行判定，若为♠则其技能终止结算且本回合无效",
  ["#lingling__langgu-invoke"] = "狼顾：是否进行判定？若为黑色，你可以获得 %dest 一张牌或获得判定牌",
  ["lingling__langgu_prey"] = "获得 %dest 一张牌",
  ["lingling__langgu_get"] = "获得判定牌",
  ["#lingling__langgu-prey"] = "狼顾：获得 %dest 一张牌",
}

local wangmang = General(extension, "lingling__wangmang", "xin", 4)
local daoxing = fk.CreateTriggerSkill{
  name = "lingling__daoxing",
  priority = 2,
  anim_type = "big",
  frequency = Skill.Compulsory,
  events = {fk.GameStart},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local availablePlayerIds = table.map(table.filter(room.players, function(p) return p.rest > 0 or not p.dead end), Util.IdMapper)
    local disabledPlayerIds = {}
    --[[if room:isGameMode("role_mode") then
      disabledPlayerIds = table.filter(availablePlayerIds, function(pid)
        local p = room:getPlayerById(pid)
        return p.role_shown and p.role == "lord"
      end)
    elseif room:isGameMode("1v2_mode") then
      local seat3Player = table.find(availablePlayerIds, function(pid)
        return room:getPlayerById(pid).seat == 3
      end)
      disabledPlayerIds = { seat3Player }
    end]]--

    local result = room:askForCustomDialog(
      player, self.name,
      "packages/lingling/qml/TaMoBox.qml",
      {
        availablePlayerIds,
        disabledPlayerIds,
        "$lingling__daoxing",
      }
    )
    result = json.decode(result)
    local players = table.simpleClone(room.players)
    for seat, playerId in pairs(result) do
      players[seat] = room:getPlayerById(playerId)
    end
    room.players = players
    local player_circle = {}
    for i = 1, #room.players do
      room.players[i].seat = i
      table.insert(player_circle, room.players[i].id)
    end
    for i = 1, #room.players - 1 do
      room.players[i].next = room.players[i + 1]
    end
    room.players[#room.players].next = room.players[1]
    room.current = room.players[1]
    room:doBroadcastNotify("ArrangeSeats", json.encode(player_circle))
  end,
}
local daoxing_visible = fk.CreateVisibilitySkill{
  name = "#lingling__daoxing_visible",
  frequency = Skill.Compulsory,
  main_skill = daoxing,
  role_visible = function (self, player, target)
    if player:hasSkill(daoxing) and target.role == "rebel" then
      return true
    end
  end,
}
local fanshu = fk.CreateActiveSkill{
  name = "lingling__fanshu",
  anim_type = "offensive",
  frequency = Skill.Limited,
  card_num = 15,
  target_num = 1,
  prompt = "#lingling__fanshu",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryGame) == 0
  end,
  card_filter = function(self, to_select, selected)
    return #selected < 15 and not Self:prohibitDiscard(to_select)
  end,
  target_filter = function(self, to_select, selected, selected_cards)
    return #selected == 0 and to_select ~= Self.id
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    room:throwCard(effect.cards, self.name, player)
    if not target.dead then
      room:damage{
        from = player,
        to = target,
        damage = 3,
        skillName = self.name,
      }
    end
  end,
}
local gengshi = fk.CreateTriggerSkill{
  name = "lingling__gengshi",
  anim_type = "control",
  events = {fk.Damage, fk.Damaged},
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(self)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    --local n = table.find(room.alive_players, function (p)
    --  return p:getHandcardNum() > player:getHandcardNum()
    --end) and 2 or 1
    player:drawCards(1, self.name)
    room.logic:breakTurn()
  end,
}
daoxing:addRelatedSkill(daoxing_visible)
wangmang:addSkill(daoxing)
wangmang:addSkill(fanshu)
wangmang:addSkill(gengshi)
Fk:loadTranslationTable{
  ["lingling__wangmang"] = "王莽",
  ["#lingling__wangmang"] = "倒砌金塔",
  ["illustrator:lingling__wangmang"] = "珊瑚虫",
  ["designer:lingling__wangmang"] = "伶",

  ["lingling__daoxing"] = "倒行",
  [":lingling__daoxing"] = "游戏开始时，反贼的身份对你可见，然后你重新调配所有角色的座次。",
  ["lingling__fanshu"] = "翻书",
  [":lingling__fanshu"] = "限定技，出牌阶段，你可以弃置15张牌，然后对一名其他角色造成3点伤害。",
  ["lingling__gengshi"] = "更始",
  [":lingling__gengshi"] = "当你造成或受到伤害后，你可以摸一张牌，终止一切结算，结束本回合。"..
  "<br><br> <font color = '#a40000'>我不属于这个时代。",
  ["$lingling__daoxing"] = "倒行",
  ["#lingling__fanshu"] = "翻书：你可以弃置15张牌，对一名角色造成3点伤害！",

  ["$lingling__daoxing1"] = "知我罪我，其惟春秋。",
  ["$lingling__daoxing2"] = "遵古复礼，非此不足以安天下。",
  ["$lingling__fanshu1"] = "史书该翻到下一页了。",
  ["$lingling__fanshu2"] = "这一页青史停留得太久了。",
}

local xiaohe = General(extension, "lingling__xiaohe", "han", 3)
local jimou = fk.CreateActiveSkill{
  name = "lingling__jimou",
  anim_type = "control",
  prompt = "#lingling__jimou",
  expand_pile = function(self)
    return Self:getTableMark(self.name)
  end,
  can_use = function (self, player, card, extra_data)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  card_num = 1,
  card_filter = function(self, to_select, selected, player)
    if #selected > 0 then return false end
    local mark = Self:getTableMark(self.name)
    if table.contains(mark, to_select) then
      local name = Fk:getCardById(to_select).name
      local card = Fk:cloneCard(name)
      card.skillName = self.name
      return card.skill:canUse(player, card)
    end
  end,
  target_filter = function(self, to_select, selected, selected_cards, _, _, player)
    if #selected_cards == 0 then return end
    local card = Fk:cloneCard(Fk:getCardById(selected_cards[1]).name)
    card.skillName = self.name
    if #selected == 0 and to_select == Self.id then return end
    return card.skill:targetFilter(to_select, selected, {}, card, {}, player)
  end,
  feasible = function(self, selected, selected_cards, player)
    if #selected_cards == 0 then return end
    local card = Fk:cloneCard(Fk:getCardById(selected_cards[1]).name)
    card.skillName = self.name
    return card.skill:feasible(selected, {}, player, card)
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    local card = Fk:cloneCard(Fk:getCardById(effect.cards[1]).name)
    card.skillName = self.name
    room:useCard{
      from = player.id,
      tos = table.map(effect.tos, function(id) return {id} end),
      card = card,
    }
    if target.dead then return end
    if not player.dead then
      local cards = table.filter(player:getTableMark(self.name), function (id)
        local card2 = Fk:getCardById(id)
        return card2.name ~= card.name and card2.skill:canUse(player, card2, {must_targets = {target.id}})
      end)
      if #cards > 0 then
        local dat = U.askForUseRealCard(room, player, cards, nil, self.name, "#lingling__jimou-use::"..target.id,
          {
            expand_pile = cards,
            bypass_times = true,
            must_targets = {target.id},
          }, true, false)
        if dat then
          local use = {
            card = Fk:cloneCard(dat.card.name),
            from = player.id,
            tos = dat.tos,
            extraUse = true,
          }
          use.card.skillName = self.name
          room:useCard(use)
        end
      end
    end
    if target.dead then return end
    room:addPlayerMark(target, "@lingling__jimou", 1)
    local n = 2 - target:getMark("lingling__jimou-tmp")
    room:setPlayerMark(target, "lingling__jimou-tmp", 0)
    if n > 0 then
      local cards = room:getCardsFromPileByRule("nullification", n, "allPiles")
      if #cards > 0 then
        room:moveCardTo(cards, Card.PlayerHand, target, fk.ReasonJustMove, self.name, nil, true, target.id)
      end
    end
  end,

  on_acquire = function (self, player, is_start)
    local room = player.room
    local cards = table.filter(U.getUniversalCards(room, "t"), function(id)
      local card = Fk:getCardById(id)
      return not card.multiple_targets and card.skill:getMinTargetNum() > 0
    end)
    room:setPlayerMark(player, self.name, cards)
  end,
}
local jimou_delay = fk.CreateTriggerSkill{
  name = "#lingling__jimou_delay",

  refresh_events = {fk.CardEffectCancelledOut, fk.TurnStart},
  can_refresh = function(self, event, target, player, data)
    if event == fk.CardEffectCancelledOut then
      return data.to and data.to == player.id and table.contains(data.card.skillNames, "lingling__jimou")
    elseif event == fk.TurnStart then
      return target == player and player:getMark("@lingling__jimou") > 0
    end
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    if event == fk.CardEffectCancelledOut then
      room:addPlayerMark(player, "lingling__jimou-tmp", 1)
    elseif event == fk.TurnStart then
      room:addPlayerMark(player, MarkEnum.MinusMaxCards.."-turn", player:getMark("@lingling__jimou"))
      room:setPlayerMark(player, "@lingling__jimou", 0)
    end
  end,
}
local nadian = fk.CreateTriggerSkill{
  name = "lingling__nadian",
  anim_type = "drawcard",
  events = {fk.AfterCardsMove, fk.CardUsing},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) then
      if event == fk.AfterCardsMove then
        local room = player.room
        local phase_event = room.logic:getCurrentEvent():findParent(GameEvent.Phase)
        if phase_event == nil or phase_event.data[2] ~= Player.Discard then return end
        local cards = {}
        for _, move in ipairs(data) do
          if move.from and move.from ~= player.id and move.moveReason == fk.ReasonDiscard then
            for _, info in ipairs(move.moveInfo) do
              if Fk:getCardById(info.cardId).type == Card.TypeTrick and table.contains(room.discard_pile, info.cardId) then
                table.insertIfNeed(cards, info.cardId)
              end
            end
          end
        end
        cards = U.moveCardsHoldingAreaCheck(room, cards)
        if #cards > 0 then
          self.cost_data = {cards = cards}
          return true
        end
      elseif event == fk.CardUsing then
        return target ~= player and data.card.trueName == "nullification"
      end
    end
  end,
  on_cost = function (self, event, target, player, data)
    if event == fk.AfterCardsMove then
      return player.room:askForSkillInvoke(player, self.name)
    elseif event == fk.CardUsing then
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    if event == fk.AfterCardsMove then
      player.room:moveCardTo(self.cost_data.cards, Card.PlayerHand, player, fk.ReasonJustMove, self.name, nil, true, player.id)
    elseif event == fk.CardUsing then
      player:drawCards(1, self.name)
    end
  end,
}
jimou:addRelatedSkill(jimou_delay)
xiaohe:addSkill(jimou)
xiaohe:addSkill(nadian)
Fk:loadTranslationTable{
  ["lingling__xiaohe"] = "萧何",
  ["#lingling__xiaohe"] = "开汉首功",
  ["illustrator:lingling__xiaohe"] = "珊瑚虫",
  ["designer:lingling__xiaohe"] = "伶",

  ["lingling__jimou"] = "急谋",
  [":lingling__jimou"] = "出牌阶段限一次，你可以视为对一名其他角色依次使用两张目标为唯一其他角色的牌名不同的普通锦囊牌，结算后其获得X张"..
  "【无懈可击】（X为生效牌数），且其下回合手牌上限-1。",
  ["lingling__nadian"] = "纳典",
  [":lingling__nadian"] = "其他角色于弃牌阶段弃置牌后，你可以获得其中所有锦囊牌。当其他角色使用【无懈可击】时，你摸一张牌。"..
  "<br><br> <font color = '#a40000'>相国人夸佐沛公，收图运饷守关中。<br>不知用蜀为根本，此是兴王第一功。",
  ["#lingling__jimou"] = "急谋：视为对一名角色依次使用两张锦囊，然后其获得生效牌数的【无懈可击】且其下回合手牌上限-1",
  ["#lingling__jimou-use"] = "急谋：再视为对 %dest 使用一张锦囊",
  ["@lingling__jimou"] = "急谋",
}

local hanxin = General(extension, "lingling__hanxin", "han", 4)
local dianbing = fk.CreateViewAsSkill{
  name = "lingling__dianbing",
  anim_type = "drawcard",
  pattern = "ex_nihilo",
  prompt = "#lingling__dianbing",
  card_filter = function(self, to_select, selected)
    return #selected == 0 and Fk:getCardById(to_select).trueName == "slash"
  end,
  view_as = function(self, cards)
    if #cards ~= 1 then return end
    local card = Fk:cloneCard("ex_nihilo")
    card.skillName = self.name
    card:addSubcard(cards[1])
    return card
  end,
  enabled_at_response = function(self, player, response)
    return not response
  end,
}
local dianbingExNihiloSkill = fk.CreateActiveSkill{
  name = "lingling__dianbing__ex_nihilo_skill",
  prompt = "#ex_nihilo_skill",
  mod_target_filter = Util.TrueFunc,
  can_use = function(self, player, card)
    return not player:isProhibited(player, card)
  end,
  on_use = function(self, room, cardUseEvent)
    if not cardUseEvent.tos or #TargetGroup:getRealTargets(cardUseEvent.tos) == 0 then
      cardUseEvent.tos = { { cardUseEvent.from } }
    end
  end,
  on_effect = function(self, room, effect)
    local target = room:getPlayerById(effect.to)
    if target.dead then return end
    local cards = target:drawCards(2, "ex_nihilo")
    if target.dead then return end
    if not table.find(cards, function (id)
      return Fk:getCardById(id).trueName == "slash"
    end) then
      room:invalidateSkill(target, "lingling__dianbing", "-turn")
    end
    cards = table.filter(cards, function (id)
      return table.contains(target:getCardIds("h"), id)
    end)
    if not target.dead and #cards > 0 then
      target:showCards(cards)
    end
  end
}
dianbingExNihiloSkill.cardSkill = true
Fk:addSkill(dianbingExNihiloSkill)
local dianbing_trigger = fk.CreateTriggerSkill{
  name = "#lingling__dianbing_trigger",

  refresh_events = {fk.PreCardEffect},
  can_refresh = function(self, event, target, player, data)
    return data.from == player.id and data.card.trueName == "ex_nihilo" and table.contains(data.card.skillNames, "lingling__dianbing")
  end,
  on_refresh = function(self, event, target, player, data)
    local card = data.card:clone()
    local c = table.simpleClone(data.card)
    for k, v in pairs(c) do
      card[k] = v
    end
    card.skill = dianbingExNihiloSkill
    data.card = card
  end,
}
local andu = fk.CreateTriggerSkill{
  name = "lingling__andu",
  events = {fk.EventPhaseEnd},
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Discard
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    if not room.tag[self.name] then
      room:setPlayerMark(player, self.name, U.prepareDeriveCards(room,
        {
          {"slash", Card.NoSuit, 0},
          {"dismantlement", Card.NoSuit, 0},
        }, self.name))
    end
    local use = U.askForUseRealCard(room, player, room.tag[self.name], nil, self.name, "#lingling__andu-use",
      {
        expand_pile = room.tag[self.name],
        bypass_times = true,
      }, true, true)
    if use then
      self.cost_data = use
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local x = 0
    local logic = player.room.logic
    logic:getEventsOfScope(GameEvent.MoveCards, 1, function (e)
      for _, move in ipairs(e.data) do
        if move.from == player.id and move.moveReason == fk.ReasonDiscard and move.skillName == "phase_discard" then
          x = x + #move.moveInfo
          if x > 1 then return true end
        end
      end
      return false
    end, Player.HistoryTurn)
    local use = {
      card = Fk:cloneCard(self.cost_data.card.name),
      from = player.id,
      tos = self.cost_data.tos,
      extraUse = true,
    }
    use.card.skillName = self.name
    room:useCard(use)
    if x > 1 and not player.dead then
      local cards = table.simpleClone(room.tag[self.name])
      table.removeOne(cards, self.cost_data.card.id)
      use = U.askForUseRealCard(room, player, cards, nil, self.name, "#lingling__andu-use",
        {
          expand_pile = cards,
          bypass_times = true,
        }, true, true)
      if use then
        use = {
          card = Fk:cloneCard(use.card.name),
          from = player.id,
          tos = use.tos,
          extraUse = true,
        }
        use.card.skillName = self.name
        room:useCard(use)
      end
    end
  end,
}
dianbing:addRelatedSkill(dianbing_trigger)
hanxin:addSkill(dianbing)
hanxin:addSkill(andu)
Fk:loadTranslationTable{
  ["lingling__hanxin"] = "韩信",
  ["#lingling__hanxin"] = "国士无双",
  ["illustrator:lingling__hanxin"] = "珊瑚虫",
  ["designer:lingling__hanxin"] = "伶",

  ["lingling__dianbing"] = "点兵",
  [":lingling__dianbing"] = "你可以将【杀】当【无中生有】使用，然后展示获得的牌，若其中没有【杀】则此技能本回合无效。",
  ["lingling__andu"] = "暗度",
  [":lingling__andu"] = "弃牌阶段结束时，你可以视为使用一张【杀】或【过河拆桥】，若你本阶段弃置了至少两张牌，则改为你可以依次视为使用"..
  "一张【过河拆桥】和【杀】。"..
  "<br><br> <font color = '#a40000'>昔者韩信将兵，无敌天下，功不世出，略不再见。",
  ["#lingling__dianbing"] = "点兵：你可以将【杀】当【无中生有】使用",
  ["#lingling__andu-use"] = "暗度：你可以视为使用其中一张牌",
}

local liubang = General(extension, "lingling__liubang", "han", 4)
table.insert(Fk.lords, "lingling__liubang")
local huabing = fk.CreateTriggerSkill{
  name = "lingling__huabing",
  anim_type = "control",
  events = {fk.TurnEnd},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and
      table.find(player.room:getOtherPlayers(player), function (p)
        return p:getHandcardNum() > 1 and player:getMark("lingling__huabing_record-turn") ~= p.id
      end)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = table.filter(room:getOtherPlayers(player), function (p)
      return p:getHandcardNum() > 1 and player:getMark("lingling__huabing_record-turn") ~= p.id
    end)
    local to = room:askForChoosePlayers(player, table.map(targets, Util.IdMapper), 1, 1,
      "#lingling__huabing-choose", self.name)
    if #to > 0 then
      self.cost_data = {tos = to}
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(self.cost_data.tos[1])
    room:setPlayerMark(to, "@@lingling__huabing", 1)
    room:addTableMark(player, self.name, to.id)
    room:setPlayerMark(player, "lingling__huabing_record", to.id)
    local cards = room:askForCardsChosen(player, to, 2, 2, "h", self.name, "#lingling__huabing-prey::"..to.id)
    room:moveCardTo(cards, Card.PlayerHand, player, fk.ReasonPrey, self.name, nil, false, player.id)
  end,

  refresh_events = {fk.TurnStart},
  can_refresh = function (self, event, target, player, data)
    return target == player and player:getMark("lingling__huabing_record") ~= 0
  end,
  on_refresh = function (self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(player, "lingling__huabing_record-turn", player:getMark("lingling__huabing_record"))
    room:setPlayerMark(player, "lingling__huabing_record", 0)
  end,
}
local huabing_delay = fk.CreateTriggerSkill{
  name = "#huabing_delay",
  anim_type = "control",
  events = {fk.TurnStart},
  can_trigger = function(self, event, target, player, data)
    return table.contains(player:getTableMark("lingling__huabing"), target.id)
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(target, "@@lingling__huabing", 0)
    room:removeTableMark(player, "lingling__huabing", target.id)
    local choices = {"lingling__huabing2::"..target.id}
    if not target.dead then
      table.insert(choices, "lingling__huabing1::"..target.id)
    end
    local choice = room:askForChoice(player, choices, "lingling__huabing")
    if choice[18] == "1" then
      player:drawCards(1, "lingling__huabing")
      if not player.dead and not target.dead and not player:isNude() then
        local cards = {}
        if #player:getCardIds("he") > 2 then
          cards = room:askForCard(player, 3, 3, true, "lingling__huabing", false, nil, "#lingling__huabing-give::"..target.id)
        else
          cards = player:getCardIds("he")
        end
        room:moveCardTo(cards, Card.PlayerHand, target, fk.ReasonGive, "lingling__huabing", nil, false, player.id)
      end
    else
      room:damage{
        from = target,
        to = player,
        damage = 1,
        skillName = "lingling__huabing",
      }
    end
  end,
}
local fengeng = fk.CreateTriggerSkill{
  name = "lingling__fengeng",
  anim_type = "support",
  events = {fk.CardUseFinished},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and target ~= player and (data.card.trueName == "peach" or data.card.trueName == "ex_nihilo") and
      data.card.skill:canUse(player, Fk:cloneCard(data.card.name)) and
      player:getMark("lingling__fengeng_"..data.card.trueName.."-round") == 0 and not player:isNude()
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local cards = table.filter(player:getCardIds("he&"), function (id)
      local card = Fk:cloneCard(data.card.name)
      card.skillName = self.name
      card:addSubcard(id)
      return card.skill:canUse(player, card)
    end)
    local card = room:askForCard(player, 1, 1, true, self.name, true, tostring(Exppattern{ id = cards }),
      "#lingling__fengeng-invoke:::"..data.card.name)
    if #card > 0 then
      self.cost_data = {cards = card}
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(player, "lingling__fengeng_"..data.card.trueName.."-round", 1)
    room:useVirtualCard(data.card.name, self.cost_data.cards, player, player, self.name)
  end,
}
huabing:addRelatedSkill(huabing_delay)
liubang:addSkill(huabing)
liubang:addSkill(fengeng)
Fk:loadTranslationTable{
  ["lingling__liubang"] = "刘邦",
  ["#lingling__liubang"] = "天阶三尺",
  ["illustrator:lingling__liubang"] = "珊瑚虫",
  ["designer:lingling__liubang"] = "伶",

  ["lingling__huabing"] = "画饼",
  [":lingling__huabing"] = "回合结束时，你可以获得一名其他角色两张手牌（不能连续两回合选择同一名角色），然后其下回合开始时你选择："..
  "摸一张牌并交给其三张牌；受到其造成的1点伤害。",
  ["lingling__fengeng"] = "分羹",
  [":lingling__fengeng"] = "每轮各限一次，当其他角色使用【桃】或【无中生有】后，你可以将一张牌当同名牌使用。"..
  "<br><br> <font color = '#a40000'>汉祖之神圣，尧以后一人也。",
  ["#lingling__huabing-choose"] = "画饼：你可以获得一名角色两张手牌，其下回合开始时你选择一项",
  ["#lingling__huabing-prey"] = "画饼：获得 %dest 两张手牌",
  ["@@lingling__huabing"] = "画饼",
  ["#huabing_delay"] = "画饼",
  ["lingling__huabing1"] = "摸一张牌并交给 %dest 三张牌",
  ["lingling__huabing2"] = "%dest 对你造成1点伤害",
  ["#lingling__huabing-give"] = "画饼：请交给 %dest 三张牌",
  ["#lingling__fengeng-invoke"] = "分羹：你可以将一张牌当【%arg】使用",
}

local liuche = General(extension, "lingling__liuche", "han", 4)
--[[local kouluan = fk.CreateTriggerSkill{
  name = "lingling__kouluan",
  anim_type = "special",
  frequency = Skill.Compulsory,
  events = {fk.GameStart},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cards = U.prepareDeriveCards(room, {
      {"savage_assault", Card.Spade, 7}, --{"savage_assault", Card.Spade, 7},
      {"savage_assault", Card.Club, 7}, --{"savage_assault", Card.Club, 7},
      {"savage_assault", Card.Spade, 13}, {"savage_assault", Card.Spade, 13},
    }, self.name)
    for _, id in ipairs(cards) do
      if room:getCardArea(id) == Card.Void then
        table.removeOne(room.void, id)
        table.insert(room.draw_pile, math.random(1, #room.draw_pile // 2), id)
        room:setCardArea(id, Card.DrawPile, nil)
      end
    end
    room:doBroadcastNotify("UpdateDrawPile", tostring(#room.draw_pile))
  end,
}
local jibei = fk.CreateTriggerSkill{
  name = "lingling__jibei",
  mute = true,
  events = {fk.CardUseFinished, fk.AfterCardsMove},
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(self) then return end
    if event == fk.CardUseFinished then
      return data.card.trueName == "savage_assault" and not target.dead
    elseif event == fk.AfterCardsMove then
      for _, move in ipairs(data) do
        if move.toArea == Card.DiscardPile then
          for _, info in ipairs(move.moveInfo) do
            if Fk:getCardById(info.cardId).trueName == "savage_assault" then
              return true
            end
          end
        end
      end
    end
  end,
  on_trigger = function(self, event, target, player, data)
    if event == fk.CardUseFinished then
      self:doCost(event, target, player, data)
    elseif event == fk.AfterCardsMove then
      local i = 0
      for _, move in ipairs(data) do
        if move.toArea == Card.DiscardPile then
          for _, info in ipairs(move.moveInfo) do
            if Fk:getCardById(info.cardId).trueName == "savage_assault" then
              i = i + 1
            end
          end
        end
      end
      for _ = 1, i do
        if not player:hasSkill(self) then break end
        self:doCost(event, target, player, data)
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    if event == fk.CardUseFinished then
      if player.room:askForSkillInvoke(player, self.name, nil, "#lingling__jibei-damage::"..target.id) then
        self.cost_data = {tos = {target.id}}
        return true
      end
    elseif event == fk.AfterCardsMove then
      self.cost_data = nil
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke(self.name)
    if event == fk.CardUseFinished then
      room:notifySkillInvoked(player, self.name, "offensive")
      room:damage{
        from = player,
        to = target,
        damage = 1,
        skillName = self.name,
      }
    elseif event == fk.AfterCardsMove then
      room:notifySkillInvoked(player, self.name, "drawcard")
      player:drawCards(2, self.name)
    end
  end,
}
liuche:addSkill(kouluan)
liuche:addSkill(jibei)]]--
local sishou = fk.CreateActiveSkill{
  name = "lingling__sishou",
  anim_type = "drawcard",
  card_num = 2,
  target_num = 0,
  prompt = "#lingling__sishou",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  card_filter = function (self, to_select, selected)
    return #selected < 2 and not Self:prohibitDiscard(to_select)
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    room:throwCard(effect.cards, self.name, player, player)
    if player.dead then return end
    local ids = {}
    local tag = room:getTag(self.name) or {}
    local dic = {
      ["dismantlement"] = {Card.Spade, 12},
      ["ling__drowning"] = {Card.Spade, 4},
      ["fire_attack"] = {Card.Heart, 3},
      ["duel"] = {Card.Diamond, 1},
    }
    for _, name in ipairs({"dismantlement", "ling__drowning", "fire_attack", "duel"}) do
      local c
      local card = table.filter(tag, function (id)
        return Fk:getCardById(id).name == name and room:getCardArea(id) == Card.Void
      end)
      if #card > 0 then
        c = card[1]
      else
        c = room:printCard(name, dic[name][1], dic[name][2]).id
        table.insert(tag, c)
      end
      table.insert(ids, c)
      room:setCardMark(Fk:getCardById(c), MarkEnum.DestructIntoDiscard, 1)
    end
    room:setTag(self.name, tag)
    room:moveCardTo(ids, Card.PlayerHand, player, fk.ReasonJustMove, self.name, nil, true, player.id, "@@lingling__sishou-inhand")
  end,
}
local sishou_delay = fk.CreateTriggerSkill{
  name = "#lingling__sishou_delay",

  refresh_events = {fk.CardUseFinished},
  can_refresh = function(self, event, target, player, data)
    return target == player and not data.card:isVirtual() and not player.dead and
      table.contains(player.room:getTag("lingling__sishou") or {}, data.card.id)
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    for _, id in ipairs(TargetGroup:getRealTargets(data.tos)) do
      room:addTableMark(player, "lingling__sishou-turn", id)
    end
  end,
}
local sishou_prohibit = fk.CreateProhibitSkill{
  name = "#lingling__sishou_prohibit",
  is_prohibited = function(self, from, to, card)
    return card and #table.filter(from:getTableMark("lingling__sishou-turn"), function (id)
      return id == to.id
    end) > 1
  end,
}
local fengding = fk.CreateTriggerSkill{
  name = "lingling__fengding",
  anim_type = "masochism",
  frequency = Skill.Compulsory,
  events = {fk.Damaged},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self)
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local cards1, cards2 = {}, {}
    room.logic:getEventsByRule(GameEvent.MoveCards, 1, function (e)
      for i = #e.data, 1, -1 do
        local move = e.data[i]
        if move.from and move.moveReason == fk.ReasonDiscard and move.proposer == player.id then
          for j = #move.moveInfo, 1, -1 do
            local info = move.moveInfo[j]
            if (info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip) and
              Fk:getCardById(info.cardId).type ~= Card.TypeBasic then
              if move.from == player.id then
                if #cards1 < 2 and table.contains(room.discard_pile, info.cardId) then
                  table.insertIfNeed(cards1, info.cardId)
                end
              else
                if #cards2 < 2 and table.contains(room.discard_pile, info.cardId) then
                  table.insertIfNeed(cards2, info.cardId)
                end
              end
            end
            if #cards1 > 1 and #cards2 > 1 then
              return true
            end
          end
        end
      end
    end, 1)
    if #cards1 + #cards2 == 0 then return end
    local choice = U.askForChooseCardList(room, player,
      {"lingling__fengding1", "lingling__fengding2"}, {cards1, cards2}, 1, 1, self.name, "#lingling__sishou-ask", false, false)
    local cards = choice[1] == "lingling__fengding1" and cards1 or cards2
    room:moveCardTo(cards, Card.PlayerHand, player, fk.ReasonJustMove, self.name, nil, true, player.id)
  end,
}
sishou:addRelatedSkill(sishou_delay)
sishou:addRelatedSkill(sishou_prohibit)
liuche:addSkill(sishou)
liuche:addSkill(fengding)
Fk:loadTranslationTable{
  ["lingling__liuche"] = "刘彻",
  ["#lingling__liuche"] = "功大威行",
  ["illustrator:lingling__liuche"] = "珊瑚虫",
  ["designer:lingling__liuche"] = "伶",

  --[[["lingling__kouluan"] = "寇乱",
  [":lingling__kouluan"] = "游戏开始时，在牌堆的前面一半额外加入4张【南蛮入侵】。",
  ["lingling__jibei"] = "击北",
  [":lingling__jibei"] = "当一名角色使用【南蛮入侵】结算后，你可以对其造成1点伤害。当一张【南蛮入侵】进入弃牌堆后，你摸两张牌。"..
  "<br><br> <font color = '#a40000'>寇可往，吾亦可往！",
  ["#lingling__jibei-damage"] = "击北：是否对 %dest 造成1点伤害？",
  ["#lingling__jibei-draw"] = "击北：是否摸两张牌？",]]--
  ["lingling__sishou"] = "四狩",
  [":lingling__sishou"] = "出牌阶段限一次，你可以弃置两张牌，获得【过河拆桥】【水淹七军】【火攻】【决斗】各一张，你对同一名角色使用"..
  "“四狩”牌两次后，本回合不能再对其使用牌。",
  ["lingling__fengding"] = "封鼎",
  [":lingling__fengding"] = "当你受到伤害后，你选择获得弃牌堆内最近两张你弃置的：你的非基本牌；其他角色的非基本牌。"..
  "<br><br> <font color = '#a40000'>寇可往，吾亦可往！",
  ["#lingling__sishou"] = "四狩：你可以弃置两张牌，获得【过河拆桥】【水淹七军】【火攻】【决斗】各一张",
  ["@@lingling__sishou-inhand"] = "四狩",
  ["#lingling__sishou-ask"] = "四狩：选择获得的牌",
  ["lingling__fengding1"] = "你弃置的牌",
  ["lingling__fengding2"] = "你弃置其他角色的牌",
}

local liuxiu = General(extension, "lingling__liuxiu", "han", 3)
local qiangyun = fk.CreateTriggerSkill{
  name = "lingling__qiangyun",
  anim_type = "drawcard",
  frequency = Skill.Compulsory,
  events = {fk.DrawNCards},
  on_use = function(self, event, target, player, data)
    local room = player.room
    local n = math.random(6)
    room:sendLog({
      type = "#lingling__liuxiu_random",
      from = player.id,
      arg = n,
      toast = true,
    })
    if (player.hp == 1 or player:getHandcardNum() < 2) and
      room:askForSkillInvoke(player, self.name, nil, "#lingling__qiangyun-change:::"..n) then
      math.randomseed(tonumber(tostring(os.time()):reverse():sub(1, 6)))
      n = math.random(6)
      room:sendLog({
        type = "#lingling__liuxiu_random",
        from = player.id,
        arg = n,
        toast = true,
      })
    end
    data.n = n
  end,
}
local tianxuan = fk.CreateTriggerSkill{
  name = "lingling__tianxuan",
  anim_type = "defensive",
  frequency = Skill.Compulsory,
  events = {fk.DamageInflicted},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and data.damage >= player.hp + player.shield
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local n = math.random(6)
    room:sendLog({
      type = "#lingling__liuxiu_random",
      from = player.id,
      arg = n,
      toast = true,
    })
    if n == 6 and data.from and not data.from.dead then
      room:damage{
        to = data.from,
        damage = 2,
        skillName = self.name,
      }
    end
    if n > 3 then
      return true
    end
  end,
}
liuxiu:addSkill(qiangyun)
liuxiu:addSkill(tianxuan)
Fk:loadTranslationTable{
  ["lingling__liuxiu"] = "刘秀",
  ["#lingling__liuxiu"] = "允冠百王",
  ["illustrator:lingling__liuxiu"] = "珊瑚虫",
  ["designer:lingling__liuxiu"] = "伶",

  ["lingling__qiangyun"] = "强运",
  [":lingling__qiangyun"] = "摸牌阶段，你改为投掷一个6面骰子，然后摸点数张牌，若你体力为1或手牌不多于1则可以重新投掷一次。",
  ["lingling__tianxuan"] = "天选",
  [":lingling__tianxuan"] = "当你受到致命伤害时，你投掷一个6面骰子，若点数大于3则防止之，然后若点数为6则其受到2点无来源伤害。"..
  "<br><br> <font color = '#a40000'>驰驱铜马靖烟尘，命世英雄自有真。",
  ["#lingling__qiangyun-change"] = "强运：点数为%arg，是否要重投一次？",
  ["#lingling__liuxiu_random"] = "%from 掷骰子结果为：%arg",
}


local yingzheng = General(extension, "lingling__yingzheng", "qin", 4)
local julun = fk.CreateTriggerSkill{
  name = "lingling__julun",
  anim_type = "switch",
  events = {fk.TurnStart},
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(self) then
      if table.find(player.room.alive_players, function (p)
        return p.hp == player:getMark("@lingling__julun")
      end) then
        return true
      else
        return table.find(player.room.alive_players, function (p)
          return not p:isWounded() and math.abs(p.hp - player:getMark("@lingling__julun")) == 1
        end)
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local prompt = "#lingling__julun1-invoke:::"..player:getMark("@lingling__julun")
    local targets = table.filter(room.alive_players, function (p)
      return p.hp == player:getMark("@lingling__julun")
    end)
    if #targets == 0 then
      prompt = "#lingling__julun2-invoke:::"..player:getMark("@lingling__julun")
      targets = table.filter(room.alive_players, function (p)
        return not p:isWounded() and math.abs(p.hp - player:getMark("@lingling__julun")) == 1
      end)
    end
    local to = room:askForChoosePlayers(player, table.map(targets, Util.IdMapper), 1, 1, prompt, self.name, true)
    if #to > 0 then
      self.cost_data = {tos = to}
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(self.cost_data.tos[1])
    if to.hp > player:getMark("@lingling__julun") then
      room:changeMaxHp(to, -1)
    elseif to.hp < player:getMark("@lingling__julun") then
      room:changeMaxHp(to, 1)
      if to:isWounded() then
        room:recover{
          who = to,
          num = 1,
          recoverBy = player,
          skillName = self.name,
        }
      end
    end
    if not to.dead then
      room:damage{
        from = player,
        to = to,
        damage = 1,
        skillName = self.name,
      }
    end
    if not player.dead and player:getMark("@lingling__julun") > 0 then
      if player:getMark("@lingling__julun") < 5 then
        room:addPlayerMark(player, "@lingling__julun", 1)
      else
        room:setPlayerMark(player, "@lingling__julun", 3)
      end
    end
  end,

  on_acquire = function (self, player)
    player.room:setPlayerMark(player, "@lingling__julun", 3)
  end,
  on_lose = function (self, player)
    player.room:setPlayerMark(player, "@lingling__julun", 0)
  end,
}
local quche = fk.CreateActiveSkill{
  name = "lingling__quche",
  anim_type = "offensive",
  card_num = 0,
  target_num = 0,
  prompt = "#lingling__quche",
  interaction = function(self)
    local choices = {"draw2"}
    if table.find(Fk:currentRoom().alive_players, function (p)
      return not p:isNude()
    end) then
      table.insert(choices, "discard2")
    end
    return UI.ComboBox {choices = choices}
  end,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = Util.FalseFunc,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    room:doIndicate(player.id, table.map(room.alive_players, Util.IdMapper))
    for _, p in ipairs(room:getAlivePlayers()) do
      if not p.dead then
        if self.interaction.data == "draw2" then
          p:drawCards(2, self.name)
        else
          room:askForDiscard(p, 2, 2, true, self.name, false)
        end
      end
    end
    if self.interaction.data == "draw2" then
      local targets = table.filter(room.alive_players, function (p)
        return table.every(room.alive_players, function (q)
          return p:getHandcardNum() >= q:getHandcardNum()
        end)
      end)
      for _, p in ipairs(room:getAlivePlayers()) do
        if not p.dead then
          if table.contains(targets, p) then
            p:drawCards(1, self.name)
          end
        end
      end
    else
      local targets = table.filter(room.alive_players, function (p)
        return table.every(room.alive_players, function (q)
          return p:getHandcardNum() <= q:getHandcardNum()
        end)
      end)
      for _, p in ipairs(room:getAlivePlayers()) do
        if not p.dead then
          if table.contains(targets, p) then
            room:askForDiscard(p, 1, 1, true, self.name, false)
          end
        end
      end
    end
  end,
}
local quche_delay = fk.CreateTriggerSkill{
  name = "#lingling__quche_delay",
  anim_type = "offensive",
  events = {fk.TurnEnd},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:usedSkillTimes("lingling__quche", Player.HistoryTurn) > 0 and
      table.find(player.room:getOtherPlayers(player), function (p)
        return player:canUseTo(Fk:cloneCard("slash"), p, {bypass_distances = true, bypass_times = true})
      end)
  end,
  on_trigger = function(self, event, target, player, data)
    self.cancel_cost = false
    for i = 1, player:usedSkillTimes("lingling__quche", Player.HistoryTurn) do
      if player.dead or not player:canUse(Fk:cloneCard("slash"), {bypass_distances = true, bypass_times = true}) then return end
      self:doCost(event, target, player, data)
    end
  end,
  on_cost = function(self, event, target, player, data)
    local use = U.askForUseVirtualCard(player.room, player, "slash", nil, "lingling__quche",
      "#lingling__quche-slash", true, true, true, true, nil, true)
    if use then
      self.cost_data = use
      return true
    end
    self.cancel_cost = true
  end,
  on_use = function(self, event, target, player, data)
    player.room:useCard(self.cost_data)
  end,
}
quche:addRelatedSkill(quche_delay)
yingzheng:addSkill(julun)
yingzheng:addSkill(quche)
Fk:loadTranslationTable{
  ["lingling__yingzheng"] = "嬴政",
  ["#lingling__yingzheng"] = "千古祖龙",
  ["illustrator:lingling__yingzheng"] = "珊瑚虫",
  ["designer:lingling__yingzheng"] = "伶",

  ["lingling__julun"] = "巨轮",
  [":lingling__julun"] = "转换技，回合开始时，你可以对一名体力为①3②4③5的角色造成1点伤害。若没有符合条件的角色，且有任意未受伤角色体力与条件"..
  "相差1，你可以先令其执行以下一项使其达到条件再对其发动此技能：减1点体力上限；加1点体力上限并回复1点体力。",
  ["lingling__quche"] = "驱车",
  [":lingling__quche"] = "出牌阶段限一次，你可以选择令所有角色：各摸两张牌，然后手牌最多的角色各摸一张牌；各弃置两张牌，然后手牌最少的角色"..
  "各弃置一张牌。本回合结束时，你视为使用一张无距离限制的【杀】。"..
  "<br><br> <font color = '#a40000'>天崩地坼，掀翻一个世界。",
  ["@lingling__julun"] = "巨轮",
  ["#lingling__julun1-invoke"] = "巨轮：对一名体力为%arg的角色造成1点伤害",
  ["#lingling__julun2-invoke"] = "巨轮：令一名角色调整体力上限和体力值至%arg，对其造成1点伤害",
  ["#lingling__quche"] = "驱车：令所有角色各摸/弃两张牌，手牌数最多/少的角色各摸/弃一张牌",
  ["discard2"] = "弃两张牌",
  ["#lingling__quche_delay"] = "驱车",
  ["#lingling__quche-slash"] = "驱车：视为使用一张无距离限制的【杀】",
}

local quyuan = General(extension, "lingling__quyuan", "chu", 3)
local yuanci = fk.CreateTriggerSkill{
  name = "lingling__yuanci",
  anim_type = "control",
  events = {fk.TurnEnd},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and not target.dead and
      #player.room.logic:getEventsOfScope(GameEvent.UseCard, 1, function (e)
        local use = e.data[1]
        return use.from == target.id and use.card.trueName == "slash"
      end, Player.HistoryTurn) == 0
  end,
  on_cost = function (self, event, target, player, data)
    return player.room:askForSkillInvoke(player, self.name, nil, "#lingling__yuanci-invoke::"..target.id)
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    player:drawCards(1, self.name)
    if player.dead or target.dead or target:isAllNude() or target == player then return end
    room:useVirtualCard("sincere_treat", nil, player, target, self.name)
    if player.dead or target.dead or target:isNude() then return end
    local card = room:askForCard(target, 1, 1, false, self.name, true, "slash", "#lingling__yuanci-show:"..player.id)
    if #card > 0 then
      target:showCards(card)
      if player.dead or target.dead or player:isAllNude() then return end
      room:useVirtualCard("dismantlement", nil, target, player, self.name)
    end
  end,
}
local qiusuo = fk.CreateTriggerSkill{
  name = "lingling__qiusuo",
  anim_type = "special",
  frequency = Skill.Compulsory,
  events = {fk.GameStart},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local skills1, skills2 = {}, {}
    for name, skill in pairs(Fk.skills) do
      if skill ~= self and not skill.attached_equip and not name:endsWith("&") and not name:startsWith("#") and
        string.find(Fk:translate(":"..name, "zh_CN"), "上回合") then
        table.insertIfNeed(skills1, name)
      end
    end
    for name, skill in pairs(Fk.skills) do
      if skill ~= self and not skill.attached_equip and not name:endsWith("&") and not name:startsWith("#") and
        string.find(Fk:translate(":"..name, "zh_CN"), "下回合") then
        table.insertIfNeed(skills2, name)
      end
    end
    local skills = {}
    if #skills1 > 0 then
      table.insert(skills, table.random(skills1))
    end
    if #skills2 > 0 then
      for i = 1, 20, 1 do
        local skill = table.random(skills2)
        if not table.contains(skills, skill) then
          table.insert(skills, skill)
          break
        end
      end
    end
    if #skills > 0 then
      room:handleAddLoseSkills(player, skills, nil, true, false)
    end
  end,
}
quyuan:addSkill(yuanci)
quyuan:addSkill(qiusuo)
Fk:loadTranslationTable{
  ["lingling__quyuan"] = "屈原",
  ["#lingling__quyuan"] = "词悬日月",
  ["illustrator:lingling__quyuan"] = "珊瑚虫",
  ["designer:lingling__quyuan"] = "伶",

  ["lingling__yuanci"] = "怨辞",
  [":lingling__yuanci"] = "本回合未使用过【杀】的角色回合结束时，你可以摸一张牌视为对其使用【推心置腹】，然后其可以展示一张【杀】视为对你使用"..
  "【过河拆桥】。",
  ["lingling__qiusuo"] = "求索",
  [":lingling__qiusuo"] = "游戏开始时，你随机获得一个描述含“上回合”的技能，和一个描述含“下回合”的技能。"..
  "<br><br> <font color = '#a40000'>长太息以掩涕兮，哀民生之多艰。",
  ["#lingling__yuanci-invoke"] = "怨辞：是否摸一张牌，视为对 %dest 使用【推心置腹】？",
  ["#lingling__yuanci-show"] = "怨辞：是否展示一张【杀】，视为对 %src 使用【过河拆桥】？",
}

--
local lianpoz = General(extension, "lingling__lianpoz", "zhao", 4)
local zhuangqi = fk.CreateTriggerSkill{
  name = "lingling__zhuangqi",
  switch_skill_name = "lingling__zhuangqi",
  anim_type = "switch",
  events = {fk.EventPhaseStart, fk.EventPhaseEnd},
  can_trigger = function (self, event, target, player, data)
    if target == player and player:hasSkill(self) and player.phase == Player.Play and not player:isNude() then
      if player:getSwitchSkillState(self.name, false) == fk.SwitchYang then
        return true
      else
        return table.find(player.room.alive_players, function (p)
          return p:isWounded()
        end)
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local cards = table.filter(player:getCardIds("he"), function(id)
      local card = Fk:getCardById(id)
      return (card.trueName == "jink" or (card.type == Card.TypeEquip and card.color == Card.Red)) and not player:prohibitDiscard(id)
    end)
    local targets = room.alive_players
    if player:getSwitchSkillState(self.name, false) == fk.SwitchYin then
      targets = table.filter(room.alive_players, function (p)
        return p:isWounded()
      end)
    end
    local to, card = room:askForChooseCardAndPlayers(player, table.map(targets, Util.IdMapper) , 1, 1, tostring(Exppattern{ id = cards }),
      "#lingling__zhuangqi-"..player:getSwitchSkillState(self.name, false, true), self.name, true, false)
    if #to > 0 and card then
      self.cost_data = {tos = to, cards = {card}}
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(self.cost_data.tos[1])
    room:throwCard(self.cost_data.cards, self.name, player, player)
    if to.dead then return end
    if player:getSwitchSkillState(self.name, true) == fk.SwitchYang then
      room:damage{
        from = player,
        to = to,
        damage = 1,
        skillName = self.name,
      }
    elseif to:isWounded() then
      room:recover{
        who = to,
        num = 1,
        recoverBy = player,
        skillName = self.name,
      }
    end
  end,
}
local jueshuo = fk.CreateTriggerSkill{
  name = "lingling__jueshuo",
  anim_type = "support",
  frequency = Skill.Compulsory,
  events = {fk.CardUsing, fk.AfterAskForCardUse},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) and player.room:getBanner("RoundCount") > 1 then
      local room = player.room
      local round_event = room.logic:getCurrentEvent():findParent(GameEvent.Round, true)
      if round_event == nil then return end
      local start_id, end_id = 0, 0
      room.logic:getEventsByRule(GameEvent.Round, 1, function (e)
        if e.id ~= round_event.id then
          start_id, end_id = e.id, e.end_id
          return true
        end
      end, 1)
      if start_id == 0 then return end
      if event == fk.CardUsing then
        if target == player and data.card.trueName == "slash" then
          return #room.logic:getEventsByRule(GameEvent.UseCard, 1, function (e)
            if e.id <= end_id then
              local use = e.data[1]
              return use.from == player.id and use.card.trueName == "slash"
            end
          end, start_id) > 0
        end
      elseif event == fk.AfterAskForCardUse then
        return target == player and data.cardName == "jink" and data.eventData and
          not (data.result and data.result.from == player.id) and
          player:getMark("lingling__jueshuo_jink-round") > 0
      --[[elseif event == fk.RoundEnd then
        return #room.logic:getEventsOfScope(GameEvent.UseCard, 1, function (e)
          local use = e.data[1]
          return use.from == player.id and use.card.trueName == "peach"
        end, Player.HistoryRound) == 0 and
        #room.logic:getEventsByRule(GameEvent.UseCard, 1, function (e)
          if e.id <= end_id then
            local use = e.data[1]
            return use.from == player.id and use.card.trueName == "peach"
          end
        end, start_id) == 0]]--
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local all_cards = table.simpleClone(room.draw_pile)
    table.insertTable(all_cards, table.simpleClone(room.discard_pile))
    local type = {}
    if event == fk.CardUsing then
      type = {Card.SubtypeWeapon}
    elseif event == fk.AfterAskForCardUse then
      type = {Card.SubtypeArmor}
    --elseif event == fk.RoundEnd then
    --  type = {Card.SubtypeDefensiveRide, Card.SubtypeOffensiveRide}
    end
    local cards = table.filter(all_cards, function (id)
      local card = Fk:getCardById(id)
      return table.contains(type, card.sub_type) and player:canUseTo(card, player)
    end)
    if #cards > 0 then
      room:useCard{
        from = player.id,
        tos = {{player.id}},
        card = Fk:getCardById(table.random(cards)),
      }
    end
  end,

  refresh_events = {fk.AfterAskForCardUse, fk.RoundStart},
  can_refresh = function (self, event, target, player, data)
    if event == fk.AfterAskForCardUse then
      return target == player and data.cardName == "jink" and data.eventData and
        not (data.result and data.result.from == player.id)
    elseif event == fk.RoundStart then
      return player:getMark("lingling__jueshuo_jink") > 0
    end
  end,
  on_refresh = function (self, event, target, player, data)
    local room = player.room
    if event == fk.AfterAskForCardUse then
      room:setPlayerMark(player, "lingling__jueshuo_jink", 1)
    elseif event == fk.RoundStart then
      room:setPlayerMark(player, "lingling__jueshuo_jink", 0)
      room:setPlayerMark(player, "lingling__jueshuo_jink-round", 1)
    end
  end,
}
local fujing = fk.CreateActiveSkill{
  name = "lingling__fujing",
  anim_type = "support",
  frequency = Skill.Limited,
  card_num = 0,
  target_num = 1,
  prompt = "#lingling__fujing",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryGame) == 0 and #player:getCardIds("e") > 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, to_select, selected)
    return #selected == 0
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    local n = #player:getCardIds("e")
    player:throwAllCards("e")
    if target.dead then return end
    target:drawCards(2 * n, self.name)
    if target ~= player and target:isWounded() and not target.dead then
      room:recover{
        who = target,
        num = 1,
        recoverBy = player,
        skillName = self.name,
      }
    end
  end,
}
lianpoz:addSkill(zhuangqi)
lianpoz:addSkill(jueshuo)
lianpoz:addSkill(fujing)
Fk:loadTranslationTable{
  ["lingling__lianpoz"] = "廉颇",
  ["#lingling__lianpoz"] = "老将",
  ["illustrator:lingling__lianpoz"] = "珊瑚虫",
  ["designer:lingling__lianpoz"] = "伶",

  ["lingling__zhuangqi"] = "壮气",
  [":lingling__zhuangqi"] = "转换技，出牌阶段开始时或出牌阶段结束时，你可以弃置一张红色装备牌或【闪】，然后①对一名角色造成1点伤害②回复1点体力。",
  ["lingling__jueshuo"] = "矍铄",
  [":lingling__jueshuo"] = "从第二轮开始，当你使用【杀】时，若你上轮也使用过【杀】，你随机获得一张武器牌并使用。当你放弃使用【闪】时，"..
  "若你上轮也放弃使用过【闪】，你随机获得一张防具牌并使用。",
  --"当你未使用【桃】的轮次结束时，若你上轮也未使用【桃】，你随机获得一张坐骑牌并使用。",
  ["lingling__fujing"] = "负荆",
  [":lingling__fujing"] = "限定技，出牌阶段，你可以弃置装备区所有牌（至少一张），然后令一名角色摸两倍的牌，若不为你，其回复1点体力。"..
  "<br><br> <font color = '#a40000'>引车趋避量诚洪，肉袒将军志亦雄。<br>今日纷纷竞门户，谁将国计置胸中？",
  ["#lingling__zhuangqi-yang"] = "壮气：你可以弃置一张红色装备牌或【闪】，对一名角色造成1点伤害",
  ["#lingling__zhuangqi-yin"] = "壮气：你可以弃置一张红色装备牌或【闪】，令一名角色回复1点体力",
  ["#lingling__fujing"] = "负荆：弃置装备区所有牌，令一名角色摸两倍的牌，若不为你则其回复1点体力",

  ["$lingling__fujing1"] = "君子之德浩如江海，我实在惭愧。",
  ["$lingling__fujing2"] = "鄙贱之人，不知将军宽之至此也！",
}

local linxiangru = General(extension, "lingling__linxiangru", "zhao", 3)
local huanbi = fk.CreateTriggerSkill{
  name = "lingling__huanbi",
  anim_type = "control",
  events = {fk.AfterCardsMove},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) and player:usedSkillTimes(self.name, Player.HistoryTurn) == 0 then
      for _, move in ipairs(data) do
        if move.from and move.to and move.moveReason == fk.ReasonPrey and
          move.proposer == move.to and move.from ~= move.to and
          not player.room:getPlayerById(move.to).dead and
          player:distanceTo(player.room:getPlayerById(move.from)) < 2 then
          return true
        end
      end
    end
  end,
  on_trigger = function(self, event, target, player, data)
    local room = player.room
    local targets = {}
    for _, move in ipairs(data) do
      if move.from and move.to and move.moveReason == fk.ReasonPrey and
        move.proposer == move.to and move.from ~= move.to and
        not room:getPlayerById(move.to).dead and
        player:distanceTo(room:getPlayerById(move.from)) < 2 then
        table.insertIfNeed(targets, move.to)
      end
    end
    room:sortPlayersByAction(targets)
    for _, id in ipairs(targets) do
      if not player:hasSkill(self) or player:usedSkillTimes(self.name, Player.HistoryTurn) > 0 then break end
      local p = room:getPlayerById(id)
      if not p.dead then
        self:doCost(event, p, player, data)
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    if player.room:askForSkillInvoke(player, self.name, nil, "#lingling__huanbi-invoke::"..target.id) then
      self.cost_data = {tos = {target.id}}
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local choice = room:askForChoice(target, {"lingling__huanbi1:"..player.id, "lingling__huanbi2:"..player.id}, self.name)
    if choice[17] == "1" then
      player:drawCards(1, self.name)
      if target.dead then return end
      local moves = {}
      for _, move in ipairs(data) do
        if move.from and move.to == target.id and move.moveReason == fk.ReasonPrey and
          move.proposer == move.to and move.from ~= move.to and
          not room:getPlayerById(move.from).dead then
          local ids = {}
          for _, info in ipairs(move.moveInfo) do
            if table.contains(target:getCardIds("h"), info.cardId) then
              table.insertIfNeed(ids, info.cardId)
            end
          end
          if #ids > 0 then
            table.insert(moves, {
              ids = ids,
              from = move.to,
              to = move.from,
              toArea = Card.PlayerHand,
              moveReason = fk.ReasonGive,
              skillName = self.name,
              proposer = move.to,
              moveVisible = false,
            })
          end
        end
      end
      if #moves > 0 then
        room:moveCards(table.unpack(moves))
      end
    else
      room:askForDiscard(player, 1, 1, true, self.name)
      if player.dead or target.dead or target:isNude() then return end
      if target == player then
        room:askForDiscard(player, 3, 3, true, self.name, false)
      else
        local cards = room:askForCardsChosen(player, target, 3, 3, "he", self.name, "#lingling__huanbi-discard::"..target.id)
        room:throwCard(cards, self.name, target, player)
      end
    end
  end,
}
local zhengci = fk.CreateTriggerSkill{
  name = "lingling__zhengci",
  anim_type = "control",
  events = {fk.Damage, fk.DrawNCards},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) then
      if event == fk.Damage then
        return target and player.room.logic:getActualDamageEvents(1, function(e)
          return e.data[1].from == target
        end)[1].data[1] == data and
          target.hp > data.to.hp and not target.dead and not data.to.dead and not data.to:isNude()
      elseif event == fk.DrawNCards then
        return target == player and player:getMark("lingling__zhengci-turn") == 0
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    if event == fk.Damage then
      return room:askForSkillInvoke(target, self.name, nil, "#lingling__zhengci-invoke::"..data.to.id)
    elseif event == fk.DrawNCards then
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if event == fk.Damage then
      if target == player then
        local turn_event = room.logic:getCurrentEvent():findParent(GameEvent.Turn)
        if turn_event and turn_event.data[1] == player then
          room:setPlayerMark(player, "lingling__zhengci_used", 1)
        end
      end
      room:doIndicate(target.id, {data.to.id})
      local card = room:askForCardChosen(target, data.to, "he", self.name, "#lingling__zhengci-prey::"..data.to.id)
      room:moveCardTo(card, Card.PlayerHand, target, fk.ReasonPrey, self.name, nil, false, target.id)
    elseif event == fk.DrawNCards then
      data.n = data.n + 2
    end
  end,

  refresh_events = {fk.TurnStart},
  can_refresh = function (self, event, target, player, data)
    return target == player and player:getMark("lingling__zhengci_used") > 0
  end,
  on_refresh = function (self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(player, "lingling__zhengci_used", 0)
    room:setPlayerMark(player, "lingling__zhengci-turn", 1)
  end,
}
linxiangru:addSkill(huanbi)
linxiangru:addSkill(zhengci)
Fk:loadTranslationTable{
  ["lingling__linxiangru"] = "蔺相如",
  ["#lingling__linxiangru"] = "凛凛死义",
  ["illustrator:lingling__linxiangru"] = "珊瑚虫",
  ["designer:lingling__linxiangru"] = "伶",

  ["lingling__huanbi"] = "还壁",
  [":lingling__huanbi"] = "每回合限一次，当一名角色获得另一名你与其距离为1以内的角色的牌后，你可以令获得牌的角色选择：你摸一张牌，"..
  "然后其交还获得的牌；你弃置一张牌（无牌则不弃），然后弃置其三张牌。",
  ["lingling__zhengci"] = "正辞",
  [":lingling__zhengci"] = "任意角色每回合首次造成伤害后，若其体力大于受到伤害的角色，其可以获得该角色一张牌。摸牌阶段，若你上回合未如此做，"..
  "你多摸两张牌。"..
  "<br><br> <font color = '#a40000'>最怜恃勇偏轻举，直挟君王冒虎狼。",
  ["#lingling__huanbi-invoke"] = "还壁：是否对 %dest 发动“还壁”，令其选择一项？",
  ["lingling__huanbi1"] = "%src 摸一张牌，你交还你获得的牌",
  ["lingling__huanbi2"] = "%src 弃一张牌，弃置你三张牌",
  ["#lingling__huanbi-discard"] = "还壁：弃置 %dest 三张牌",
  ["#lingling__zhengci-invoke"] = "正辞：是否获得 %dest 一张牌？",
  ["#lingling__zhengci-prey"] = "正辞：获得 %dest 的一张牌",
}

local sunbin = General(extension, "lingling__sunbin", "qi", 3)
local jianzao = fk.CreateTriggerSkill{
  name = "lingling__jianzao",
  anim_type = "drawcard",
  events = {fk.AfterCardsMove},
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(self) then return end
    for _, move in ipairs(data) do
      if move.from == player.id then
        for _, info in ipairs(move.moveInfo) do
          if info.fromArea == Card.PlayerEquip then
            return true
          end
        end
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:drawCards(2, self.name)
    if player.dead then return end
    local turn_event = room.logic:getCurrentEvent():findParent(GameEvent.Turn)
    if turn_event and turn_event.data[1] == player then
      room:addPlayerMark(player, MarkEnum.SlashResidue.."-turn", 1)
    elseif not player:isNude() then
      U.askForUseRealCard(room, player, player:getCardIds("h&"), ".|.|.|.|.|equip", self.name,
        "#lingling__jianzao-use", nil, false, true)
    end
  end,
}
local weiwei = fk.CreateViewAsSkill{
  name = "lingling__weiwei",
  anim_type = "control",
  pattern = "unexpectation,nullification",
  prompt = "#lingling__weiwei",
  card_filter = function(self, to_select, selected)
    if #selected == 1 then return false end
    local c = Fk:getCardById(to_select)
    local card
    if c.color == Card.Red then
      card = Fk:cloneCard("unexpectation")
    elseif c.color == Card.Black then
      card = Fk:cloneCard("nullification")
    else
      return false
    end
    return (Fk.currentResponsePattern == nil and Self:canUse(card)) or
      (Fk.currentResponsePattern and Exppattern:Parse(Fk.currentResponsePattern):match(card))
  end,
  view_as = function(self, cards)
    if #cards ~= 1 then return end
    local c = Fk:getCardById(cards[1])
    local card
    if c.color == Card.Red then
      card = Fk:cloneCard("unexpectation")
    elseif c.color == Card.Black then
      card = Fk:cloneCard("nullification")
    end
    card.skillName = self.name
    card:addSubcard(cards[1])
    return card
  end,
  before_use = function (self, player, use)
    player.room:setPlayerMark(player, "lingling__weiwei_"..use.card.name.."-turn", 1)
  end,
  after_use = function (self, player, use)
    local room = player.room
    if player.dead or not use.damageDealt or use.card.name ~= "unexpectation" then return end
    local targets = {}
    for _, id in ipairs(TargetGroup:getRealTargets(use.tos)) do
      local p = room:getPlayerById(id)
      local start_id, end_id = 1, 1
      room.logic:getEventsByRule(GameEvent.Turn, 1, function (e)
        if e.data[1] == p then
          start_id, end_id = e.id, e.end_id
          return true
        end
      end, 1)
      if start_id > 1 then
        room.logic:getEventsByRule(GameEvent.Damage, 1, function (e)
          if e.id <= end_id then
            table.insertIfNeed(targets, e.data[1].to)
          end
        end, start_id)
      end
    end
    targets = table.filter(targets, function (p)
      return p:isWounded() and not p.dead
    end)
    if #targets > 0 then
      local to = room:askForChoosePlayers(player, table.map(targets, Util.IdMapper), 1, 1,
        "#lingling__weiwei-recover", self.name, true)
      if #to > 0 then
        room:recover({
          who = room:getPlayerById(to[1]),
          num = 1,
          recoverBy = player,
          skillName = self.name,
        })
      end
    end
  end,
  enabled_at_play = function (self, player)
    return player:getMark("lingling__weiwei_unexpectation-turn") == 0
  end,
  enabled_at_response = function (self, player, response)
    if response or player:isNude() then return end
    for _, name in ipairs({"unexpectation", "nullification"}) do
      if player:getMark("lingling__weiwei_"..name.."-turn") == 0 then
        local card = Fk:cloneCard(name)
        card.skillName = self.name
        if (Fk.currentResponsePattern == nil and player:canUse(card)) or
          (Fk.currentResponsePattern and Exppattern:Parse(Fk.currentResponsePattern):match(card)) then
          return true
        end
      end
    end
  end,
}
sunbin:addSkill(jianzao)
sunbin:addSkill(weiwei)
Fk:loadTranslationTable{
  ["lingling__sunbin"] = "孙膑",
  ["#lingling__sunbin"] = "兵机莫测",
  ["illustrator:lingling__sunbin"] = "珊瑚虫",
  ["designer:lingling__sunbin"] = "伶",

  ["lingling__jianzao"] = "减灶",
  [":lingling__jianzao"] = "当你失去装备区的牌后，你可以摸两张牌，若为你回合内，你本回合使用【杀】的次数上限+1，若为你回合外，"..
  "你可以使用一张装备牌。",
  ["lingling__weiwei"] = "围魏",
  [":lingling__weiwei"] = "每回合各限一次，你可以将红色牌当【出其不意】、黑色牌当【无懈可击】使用，若【出其不意】造成伤害，你可以令一名被目标"..
  "上回合造成伤害的角色回复1点体力。"..
  "<br><br> <font color = '#a40000'>百年家学妙兵机，知彼犹怜己未知。",
  ["#lingling__jianzao-use"] = "减灶：你可以使用一张装备牌",
  ["#lingling__weiwei"] = "围魏：你可以将红色牌当【出其不意】、黑色牌当【无懈可击】使用",
  ["#lingling__weiwei-recover"] = "围魏：你可以令其中一名角色回复1点体力",
}

local shangyang = General(extension, "lingling__shangyang", "qin", 3)
local limus = fk.CreateActiveSkill{
  name = "lingling__limus",
  anim_type = "control",
  card_num = 1,
  target_num = 0,
  prompt = "#lingling__limus",
  can_use = Util.TrueFunc,
  card_filter = function(self, to_select, selected)
    local card = Fk:getCardById(to_select)
    return #selected == 0 and card.suit == Card.Club and
      not Self:isProhibited(Self, Fk:cloneCard("supply_shortage", card.suit, card.number))
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    room:useVirtualCard("supply_shortage", effect.cards, player, player, self.name, true)
    if player.dead then return end
    player:drawCards(2, self.name)
    if player.dead then return end
    if player.maxHp < 6 then
      room:changeMaxHp(player, 1)
    end
    if player:isWounded() and not player.dead then
      room:recover{
        who = player,
        num = 1,
        recoverBy = player,
        skillName = self.name,
      }
    end
  end,
}
local bianfa = fk.CreateViewAsSkill{
  name = "lingling__bianfa",
  anim_type = "control",
  pattern = "nullification",
  prompt = "#lingling__bianfa",
  card_filter = function (self, to_select, selected)
    return #selected == 0 and Fk:getCardById(to_select).type == Card.TypeEquip
  end,
  view_as = function(self, cards)
    if #cards ~= 1 then return end
    local card = Fk:cloneCard("nullification")
    card.skillName = self.name
    card:addSubcard(cards[1])
    return card
  end,
  enabled_at_response = function (self, player, response)
    return not response
  end,
}
local bianfa_trigger = fk.CreateTriggerSkill{
  name = "#lingling__bianfa_trigger",
  anim_type = "control",
  main_skill = bianfa,
  events = {fk.CardEffectCancelledOut},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(bianfa) and #player.room:canMoveCardInBoard() > 0 then
      local turn_event = player.room.logic:getCurrentEvent():findParent(GameEvent.Turn)
      return turn_event and turn_event.data[1] == player
    end
  end,
  on_cost = function (self, event, target, player, data)
    local tos = player.room:askForChooseToMoveCardInBoard(player, "#lingling__bianfa-invoke", self.name, true, nil, false)
    if #tos > 0 then
      self.cost_data = {tos = tos}
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local targets = table.map(self.cost_data.tos, Util.Id2PlayerMapper)
    room:askForMoveCardInBoard(player, targets[1], targets[2], self.name, nil)
  end,
}
bianfa:addRelatedSkill(bianfa_trigger)
shangyang:addSkill(limus)
shangyang:addSkill(bianfa)
Fk:loadTranslationTable{
  ["lingling__shangyang"] = "商鞅",
  ["#lingling__shangyang"] = "尽公图强",
  ["illustrator:lingling__shangyang"] = "珊瑚虫",
  ["designer:lingling__shangyang"] = "伶",

  ["lingling__limus"] = "立木",
  [":lingling__limus"] = "出牌阶段，你可以将一张梅花牌当【兵粮寸断】对你使用，然后你摸两张牌，加1点体力上限并回复1点体力（至多加至6）。",
  ["lingling__bianfa"] = "变法",
  [":lingling__bianfa"] = "你的回合内，当一张牌被抵消后，你可以移动场上一张牌。你可以将装备牌当【无懈可击】使用。"..
  "<br><br> <font color = '#a40000'>法学之巨子，政治家之雄也。",
  ["#lingling__limus"] = "立木：你可以将一张♣牌当【兵粮寸断】对你使用，摸两张牌，加1点体力上限并回复1点体力",
  ["#lingling__bianfa"] = "变法：你可以将装备牌当【无懈可击】使用",
  ["#lingling__bianfa_trigger"] = "变法",
  ["#lingling__bianfa-invoke"] = "变法：你可以移动场上一张牌",
}
-- 五代武将: 李存孝
local licunxiao = General(extension, "lingling__licunxiao", "tang", 4)
local wuqian = fk.CreateTriggerSkill{
  name = "lingling__wuqian",
  anim_type = "offensive",
  events = {fk.TurnStart, fk.AfterCardUseDeclared, fk.CardUseFinished, fk.TargetSpecified, fk.Damage, fk.CardUsing},
  can_trigger = function (self, event, target, player, data)
    if target == player and player:hasSkill(self) then
      if event == fk.TurnStart then
        return true
      elseif data.card and data.card.trueName == "slash" then
        if event == fk.AfterCardUseDeclared then
          return table.find(player:getCardIds("e"), function (id)
            return Fk:getCardById(id).trueName == "hualiu"
          end)
        elseif event == fk.CardUseFinished then
          return table.find(player:getCardIds("e"), function (id)
            return Fk:getCardById(id).trueName == "jueying"
          end)
        elseif event == fk.TargetSpecified then
          return table.find(player:getCardIds("e"), function (id)
            return Fk:getCardById(id).trueName == "zhuahuangfeidian"
          end) and not player.room:getPlayerById(data.to):isNude()
        elseif event == fk.Damage then
          return table.find(player:getCardIds("e"), function (id)
            return Fk:getCardById(id).trueName == "dilu" and not player:prohibitDiscard(id)
          end) and data.to ~= player and not data.to.dead
        elseif event == fk.CardUsing then
          return table.find(player:getCardIds("e"), function (id)
            return Fk:getCardById(id).trueName == "dayuan"
          end)
        end
      end
    end
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    if event == fk.TurnStart then
      return room:askForSkillInvoke(player, self.name, nil, "#lingling__wuqian-invoke")
    elseif event == fk.AfterCardUseDeclared or event == fk.CardUseFinished or event == fk.CardUsing then
      return true
    elseif event == fk.TargetSpecified then
      return room:askForSkillInvoke(player, self.name, nil, "#lingling__wuqian-zhuahuangfeidian::"..data.to)
    elseif event == fk.Damage then
      return room:askForSkillInvoke(player, self.name, nil, "#lingling__wuqian-dilu::"..data.to.id)
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    if event == fk.TurnStart then
      local cards = {}
      for _, id in ipairs(room.draw_pile) do
        local card = Fk:getCardById(id)
        if card.sub_type == Card.SubtypeOffensiveRide or card.sub_type == Card.SubtypeDefensiveRide then
          table.insertIfNeed(cards, id)
        end
      end
      for _, id in ipairs(room.discard_pile) do
        local card = Fk:getCardById(id)
        if card.sub_type == Card.SubtypeOffensiveRide or card.sub_type == Card.SubtypeDefensiveRide then
          table.insertIfNeed(cards, id)
        end
      end
      for _, p in ipairs(room:getOtherPlayers(player)) do
        for _, id in ipairs(p:getCardIds("e")) do
          local card = Fk:getCardById(id)
          if card.sub_type == Card.SubtypeOffensiveRide or card.sub_type == Card.SubtypeDefensiveRide then
            table.insertIfNeed(cards, id)
          end
        end
      end
      if #cards == 0 then return end
      local card = table.random(cards)
      room:moveCardTo(card, Card.PlayerHand, player, fk.ReasonPrey, self.name, nil, true, player.id)
      if player.dead or not table.contains(player:getCardIds("h"), card) then return end
      card = Fk:getCardById(card)
      if player:prohibitUse(card) or player:isProhibited(player, card) then return end
      local yes = table.find(player:getCardIds("e"), function (id)
        local c = Fk:getCardById(id)
        return c.sub_type == card.sub_type and not player:hasEmptyEquipSlot(card.sub_type)
      end)
      room:useCard({
        from = player.id,
        tos = {{player.id}},
        card = card,
      })
      if yes and not player.dead then
        U.askForUseVirtualCard(room, player, "slash", nil, self.name, "#lingling__wuqian-slash", true, true, true, true)
      end
    elseif event == fk.AfterCardUseDeclared then
      data.additionalDamage = (data.additionalDamage or 0) + 1
    elseif event == fk.CardUseFinished then
      player:drawCards(1, self.name)
    elseif event == fk.TargetSpecified then
      local to = room:getPlayerById(data.to)
      local card = room:askForCardChosen(player, to, "he", self.name, "#lingling__wuqian-discard::"..data.to)
      room:throwCard(card, self.name, to, player)
    elseif event == fk.Damage then
      local card = table.find(player:getCardIds("e"), function (id)
        return Fk:getCardById(id).trueName == "dilu" and not player:prohibitDiscard(id)
      end)
      if not card then return end
      room:throwCard(card, self.name, player, player)
      room:doIndicate(player.id, {data.to.id})
      if data.to.dead then return end
      data.to:drawCards(2, self.name)
      if data.to.dead then return end
      data.to:turnOver()
    elseif event == fk.CardUsing then
      data.unoffsetableList = table.map(room.alive_players, Util.IdMapper)
    end
  end,

  refresh_events = {fk.AfterCardsMove},
  can_refresh = function (self, event, target, player, data)
    if player:hasSkill(self, true) then
      for _, move in ipairs(data) do
        if move.from == player.id then
          for _, info in ipairs(move.moveInfo) do
            if info.fromArea == Card.PlayerEquip then
              return true
            end
          end
        end
        if move.to == player.id and move.toArea == Card.PlayerEquip then
          return true
        end
      end
    end
  end,
  on_refresh = function (self, event, target, player, data)
    local room = player.room
    local names = {
      "hualiu", "jueying", "zhuahuangfeidian", "dilu",
      "dayuan", "zixing", "chitu"
    }
    for _, name in ipairs(names) do
      room:setPlayerMark(player, "@@lingling__wuqian_tip_"..name, 0)
    end
    for _, id in ipairs(player:getEquipments(Card.SubtypeOffensiveRide)) do
      local name = Fk:getCardById(id).name
      if table.contains(names, name) then
        room:setPlayerMark(player, "@@lingling__wuqian_tip_"..name, 1)
      end
    end
    for _, id in ipairs(player:getEquipments(Card.SubtypeDefensiveRide)) do
      local name = Fk:getCardById(id).name
      if table.contains(names, name) then
        room:setPlayerMark(player, "@@lingling__wuqian_tip_"..name, 1)
      end
    end
  end,
}
local wuqian_targetmod = fk.CreateTargetModSkill{
  name = "#lingling__wuqian_targetmod",
  main_skill = wuqian,
  bypass_times = function(self, player, skill, scope)
    return player:hasSkill(wuqian) and skill.trueName == "slash_skill" and
      table.find(player:getCardIds("e"), function (id)
        return Fk:getCardById(id).trueName == "zixing"
      end)
  end,
  extra_target_func = function(self, player, skill)
    if player:hasSkill(wuqian) and skill.trueName == "slash_skill" and
      table.find(player:getCardIds("e"), function (id)
        return Fk:getCardById(id).trueName == "chitu"
      end) then
      return 1
    end
  end,
}
wuqian:addRelatedSkill(wuqian_targetmod)
licunxiao:addSkill(wuqian)

-- 唐朝武将: 李白

local lijing = General(extension, "lingling__lijing", "tang", 4)
local shenwuCheck = function (card)
  return (card.trueName == "slash" and card.name ~= "slash") or
    (card.is_damage_card and card.type == Card.TypeTrick) or
    card.sub_type == Card.SubtypeWeapon
end
local shenwu = fk.CreateTriggerSkill{
  name = "lingling__shenwu",
  anim_type = "drawcard",
  frequency = Skill.Compulsory,
  events = {fk.CardUseFinished, fk.TurnEnd},
  can_trigger = function (self, event, target, player, data)
    if not player:hasSkill(self) or player ~= target then return end
    if event == fk.CardUseFinished then
      return shenwuCheck(data.card)
    elseif event == fk.TurnEnd then
      return #player.room.logic:getEventsOfScope(GameEvent.UseCard, 1, function(e)
        local use = e.data[1]
        return use.from == player.id and shenwuCheck(use.card)
      end, Player.HistoryTurn) == 0
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local cids = {}
    if event == fk.CardUseFinished then
      if data.card.trueName == "slash" and data.name ~= "slash" then
        cids = room:getCardsFromPileByRule(".|.|.|.|.|trick")
      elseif data.card.is_damage_card and data.card.type == Card.TypeTrick then
        cids = room:getCardsFromPileByRule(".|.|.|.|.|equip")
      else
        cids = room:getCardsFromPileByRule("slash")
      end
    elseif event == fk.TurnEnd then
      for _, id in ipairs(room.draw_pile) do
        if shenwuCheck(Fk:getCardById(id)) then
          table.insert(cids, id)
        end
      end
      if #cids > 0 then
        cids = table.random(cids, 1)
      end
    end
    if #cids > 0 then
      local moveMark = Fk:getCardById(cids[1]).trueName == "slash" and "@@lingling__shenwu-inhand-turn" or nil
      room:moveCardTo(cids, Card.PlayerHand, player, fk.ReasonJustMove, self.name, nil, true, player.id, moveMark)
    end
  end,

  refresh_events = {fk.PreCardUse},
  can_refresh = function (self, event, target, player, data)
    return target == player and data.card.trueName == "slash" and data.card:getMark("@@lingling__shenwu-inhand-turn") > 0
  end,
  on_refresh = function (self, event, target, player, data)
    data.extraUse = true
  end,
}
local shenwu_targetmod = fk.CreateTargetModSkill{
  name = "#lingling__shenwu_targetmod",
  bypass_times = function (self, player, skill, scope, card, to)
    return card:getMark("@@lingling__shenwu-inhand-turn") > 0
  end
}
local suzhong = fk.CreateTriggerSkill{
  name = "lingling__suzhong",
  mute = true,
  frequency = Skill.Compulsory,
  events = {fk.Deathed},
  can_trigger = function (self, event, target, player, data)
    return player:hasSkill(self) and (target.role == "rebel" or target.role == "loyalist")
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    if target.role == "rebel" then
      room:notifySkillInvoked(player, self.name, "support")
      if player:isWounded() then
        local choice = room:askForChoice(player, {"draw2", "recover"}, self.name)
        if choice == "draw2" then
          player:drawCards(2, self.name)
        else
          room:recover{
            who = player,
            num = 1,
            skillName = self.name,
          }
        end
      else
        player:drawCards(2, self.name)
      end
    else
      room:notifySkillInvoked(player, self.name, "negative")
      local cids = room:askForDiscard(player, 2, 2, true, self.name, true, ".", "#lingling__suzhong-discard")
      if #cids ~= 2 then
        room:loseHp(player, 1, self.name)
      end
    end
  end,
}
shenwu:addRelatedSkill(shenwu_targetmod)
lijing:addSkill(shenwu)
lijing:addSkill(suzhong)
Fk:loadTranslationTable{
  ["lingling__lijing"] = "李靖",
  ["#lingling__lijing"] = "大唐军神",
  ["designer:lingling__lijing"] = "伶",
  ["illustrator:lingling__lijing"] = "伊达未来",

  ["lingling__shenwu"] = "神武",
  [":lingling__shenwu"] = "锁定技，当你使用非普通【杀】后，你随机获得一张锦囊牌。当你使用伤害类锦囊牌后，你随机获得一张装备牌。当你使用武器牌后，"..
  "你随机获得一张【杀】（本回合使用无次数限制）。回合结束时，若你以上三种牌均未使用，你随机获得其中一张。",
  ["lingling__suzhong"] = "夙忠",
  [":lingling__suzhong"] = "锁定技，当一名反贼死亡后，你回复1点体力或摸两张牌。当一名忠臣死亡后，你失去1点体力或弃置两张牌。"..
  "<br><br> <font color='#a40000'>兼资文武，出将入相。</font>",
  ["#lingling__suzhong-discard"] = "夙忠：选择两张牌弃置，或点取消并失去1点体力",
  ["@@lingling__shenwu-inhand-turn"] = "神武",
}

local libai = General(extension, "lingling__libai", "tang", 3)
local jiushi = fk.CreateViewAsSkill{
  name = "lingling__jiushi",
  pattern = "analeptic",
  anim_type = "special",
  prompt = function (self, selected_cards, selected)
    return "#lingling__jiushi:::"..(Self:getMark("lingling__jiushi-turn") + 2)
  end,
  card_filter = function(self, to_select, selected)
    return #selected < Self:getMark("lingling__jiushi-turn") + 2
  end,
  view_as = function(self, cards)
    if #cards ~= Self:getMark("lingling__jiushi-turn") + 2 then return end
    local card = Fk:cloneCard("analeptic")
    card:addSubcards(cards)
    card.skillName = self.name
    return card
  end,
  before_use = function (self, player, use)
    player.room:addPlayerMark(player, "lingling__jiushi-turn", 1)
  end,
  enabled_at_play = function(self, player)
    if player.phase ~= Player.NotActive then
      return true
    else
      return player:getMark("lingling__jiushi-turn") == 0
    end
  end,
  enabled_at_response = function(self, player, response)
    if response then return end
    if player.phase ~= Player.NotActive then
      return true
    else
      return player:getMark("lingling__jiushi-turn") == 0
    end
  end,
}
local jiushi_trigger = fk.CreateTriggerSkill{
  name = "#lingling__jiushi_trigger",
  anim_type = "drawcard",
  main_skill = jiushi,
  events = {fk.CardUseFinished},
  can_trigger = function (self, event, target, player, data)
      return target == player and player:hasSkill(jiushi) and data.card.name == "analeptic"
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local cards = room:getCardsFromPileByRule(".|.|.|.|.|trick", 1, "allPiles")
    if #cards > 0 then
      room:moveCardTo(cards, Card.PlayerHand, player, fk.ReasonJustMove, "lingling__jiushi", nil, false, player.id)
    end
  end
}
local yaoyue = fk.CreateTriggerSkill{
  name = "lingling__yaoyue",
  anim_type = "drawcard",
  frequency = Skill.Compulsory,
  events = {fk.TurnEnd},
  can_trigger = function (self, event, target, player, data)
    return player:hasSkill(self) and player.drank > 0
  end,
  on_use = function (self, event, target, player, data)
    player:drawCards(3, self.name)
  end,
}
local yaoyue_targetmod = fk.CreateTargetModSkill{
  name = "#lingling__yaoyue_targetmod",
  main_skill = yaoyue,
  bypass_times = function(self, player, skill, scope)
    return player:hasSkill(yaoyue) and skill.trueName == "analeptic_skill" and scope == Player.HistoryTurn and
      player.phase ~= Player.NotActive
  end,
}
local denglou = fk.CreateDistanceSkill{
  name = "lingling__denglou",
  frequency = Skill.Compulsory,
  correct_func = function(self, from, to)
    if to:hasSkill(self) and from:getMark("lingling__denglou-turn") == 0 then
      return 2
    end
  end,
  fixed_func = function (self, from, to)
    if to:hasSkill(self) and from:getMark("lingling__denglou-turn") > 0 then
      return 1
    end
  end,
}
local denglou_record = fk.CreateTriggerSkill{
  name = "#lingling__denglou_record",
  refresh_events = {fk.CardUsing},
  can_refresh = function (self, event, target, player, data)
    return player:hasSkill(self, true) and not target.dead and data.card.type == Card.TypeTrick and
      target:getMark("lingling__denglou-turn") == 0
  end,
  on_refresh = function (self, event, target, player, data)
    player.room:setPlayerMark(target, "lingling__denglou-turn", 1)
  end,
}
jiushi:addRelatedSkill(jiushi_trigger)
yaoyue:addRelatedSkill(yaoyue_targetmod)
denglou:addRelatedSkill(denglou_record)
libai:addSkill(jiushi)
libai:addSkill(yaoyue)
libai:addSkill(denglou)

Fk:loadTranslationTable{
  ["lingling__licunxiao"] = "李存孝",
  ["#lingling__licunxiao"] = "飞虎将军",
  ["designer:lingling__licunxiao"] = "伶",
  ["illustrator:lingling__licunxiao"] = "伊达未来",

  ["lingling__wuqian"] = "无前",
  [":lingling__wuqian"] = "回合开始时，你可以随机从牌堆、弃牌堆、其他角色场上获得一张坐骑牌并使用，若顶替了原坐骑牌，你视为使用一张"..
  "无距离限制的【杀】。若你装备区有：<br>"..
  "+1马：<br>"..
  "【骅骝】，你使用【杀】伤害+1；<br>"..
  "【绝影】，你使用【杀】后摸一张牌；<br>"..
  "【爪黄飞电】，你使用【杀】指定目标后可以弃置其一张牌；<br>"..
  "【的卢】，你使用【杀】对其他角色造成伤害后，你可以弃置此牌，令其摸两张牌并翻面；<br>"..
  "-1马：<br>"..
  "【大宛】，你使用【杀】无法抵消；<br>"..
  "【紫骍】，你使用【杀】无次数限制；<br>"..
  "【赤兔】，你使用【杀】可以额外指定一名目标。"..
  "<br><br> <font color='#a40000'>王不过霸，将不过李。",
  ["#lingling__wuqian-invoke"] = "无前：是否随机获得一张坐骑牌并使用之？",
  ["#lingling__wuqian-slash"] = "无前：你可以视为使用一张无距离限制的【杀】",
  ["#lingling__wuqian-zhuahuangfeidian"] = "无前：是否弃置 %dest 一张牌？",
  ["#lingling__wuqian-discard"] = "无前：弃置 %dest 一张牌",
  ["#lingling__wuqian-dilu"] = "无前：是否弃置【的卢】，令 %dest 摸两张牌并翻面？",
  ["@@lingling__wuqian_tip_hualiu"] = "杀伤害+1",
  ["@@lingling__wuqian_tip_jueying"] = "使用杀摸牌",
  ["@@lingling__wuqian_tip_zhuahuangfeidian"] = "杀弃置目标牌",
  ["@@lingling__wuqian_tip_dilu"] = "杀造成伤害翻面",
  ["@@lingling__wuqian_tip_dayuan"] = "杀无法抵消",
  ["@@lingling__wuqian_tip_zixing"] = "杀无次数限制",
  ["@@lingling__wuqian_tip_chitu"] = "杀额外指定目标",

  ["lingling__libai"] = "李白",
  ["#lingling__libai"] = "谪仙人",
  ["designer:lingling__libai"] = "伶",
  ["illustrator:lingling__libai"] = "珊瑚虫",
  ["lingling__jiushi"] = "酒诗",
  [":lingling__jiushi"] = "你可以将X张牌当【酒】使用（X为此技能本回合已发动次数+2），回合外发动则每回合限一次。当你使用【酒】后，"..
  "你随机获得一张锦囊牌。",
  ["lingling__yaoyue"] = "邀月",
  [":lingling__yaoyue"] = "任意回合结束时若你醉酒，你摸三张牌。你于回合内使用【酒】无次数限制。",
  ["lingling__denglou"] = "登楼",
  [":lingling__denglou"] = "锁定技，本回合未使用锦囊牌的角色计算与你的距离+2，使用过锦囊牌的角色计算与你的距离为1。"..
  "<br><br> <font color='#a40000'>天子呼来不上船，自称臣是酒中仙。</font>",
  ["#lingling__jiushi"] = "酒诗：你可以将%arg张牌当【酒】使用",
  ["#lingling__jiushi_trigger"] = "酒诗",
}

local lixin = General(extension, "lingling__lixin", "qin", 4, 6)
local guozhuang = fk.CreateTriggerSkill{
  name = "lingling__guozhuang",
  mute = true,
  frequency = Skill.Compulsory,
  events = {fk.TurnStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke(self.name)
    if player:isWounded() then
      room:notifySkillInvoked(player, self.name, "drawcard")
      room:recover{
        who = player,
        num = 1,
        recoverBy = player,
        skillName = self.name,
      }
      if not player.dead then
        player:drawCards(2, self.name)
      end
    else
      room:notifySkillInvoked(player, self.name, "negative")
    end
    if not player:isWounded() and not player.dead then
      room:handleAddLoseSkills(player, "-lingling__guozhuang", nil, true, false)
    end
  end,
}
local xingfa = fk.CreateTriggerSkill{
  name = "lingling__xingfa",
  anim_type = "offensive",
  events = {fk.TurnEnd},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:doIndicate(player.id, table.map(room.alive_players, Util.IdMapper))
    for _, p in ipairs(room:getAlivePlayers()) do
      if not p.dead then
        p:drawCards(1, self.name)
      end
    end
    for _, to in ipairs(room:getAlivePlayers()) do
      if not to.dead then
        local other_players = table.filter(room:getOtherPlayers(to, false), function(p) return not p:isRemoved() end)
        local luanwu_targets = table.map(table.filter(other_players, function(p2)
          return table.every(other_players, function(p1)
            return to:distanceTo(p1) >= to:distanceTo(p2)
          end)
        end), Util.IdMapper)
        local use = room:askForUseCard(to, self.name, "slash", "#lingling__xingfa-use", true, {
          bypass_times = true,
          exclusive_targets = luanwu_targets,
        })
        if use then
          if to == player then
            room:setPlayerMark(player, self.name, 0)
          end
          use.extraUse = true
          room:useCard(use)
        else
          if to == player then
            if player:getMark(self.name) > 0 then
              room:handleAddLoseSkills(player, "-lingling__xingfa", nil, true, false)
            else
              room:setPlayerMark(player, self.name, 1)
            end
          end
          room:loseHp(to, 1, self.name)
        end
      end
    end
  end,
}
lixin:addSkill(guozhuang)
lixin:addSkill(xingfa)
Fk:loadTranslationTable{
  ["lingling__lixin"] = "李信",
  ["#lingling__lixin"] = "轻狂少将",
  ["illustrator:lingling__lixin"] = "珊瑚虫",
  ["designer:lingling__lixin"] = "伶",

  ["lingling__guozhuang"] = "果壮",
  [":lingling__guozhuang"] = "回合开始时，若你已受伤，你回复1点体力并摸两张牌，若你未受伤或因此回复至满，你失去此技能。",
  ["lingling__xingfa"] = "兴伐",
  [":lingling__xingfa"] = "回合结束时，你可以令所有角色各摸一张牌，然后所有角色依次选择：对距离最近的另一名角色使用【杀】；失去1点体力。"..
  "若你连续两次选择失去1点体力，你失去此技能。"..
  "<br><br> <font color = '#a40000'>须知少时凌云志，曾许人间第一流。",
  ["#lingling__xingfa-use"] = "兴伐：你需要对距离最近的一名角色使用一张【杀】，否则失去1点体力",
}

local xiangyu = General(extension, "lingling__xiangyu", "chu", 5)
local shenyong = fk.CreateTriggerSkill {
  name = "lingling__shenyong",
  events = {fk.BeforeDrawCard, fk.EventPhaseStart, fk.DamageCaused},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) and target == player then
      if event == fk.BeforeDrawCard then
        return data.skillName == "ex_nihilo" and player.drank > 0
      elseif event == fk.EventPhaseStart then
        return player.phase == Player.Draw
      else
        if data.card and data.card.name == "duel" and not data.chain then
          return player.drank > 0
        end
      end
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if event == fk.EventPhaseStart then 
      local can = {}
      local slash = room:getCardsFromPileByRule("slash",3,"allPiles")
      local wuzhong = room:getCardsFromPileByRule("ex_nihilo",1,"allPiles")
      local jiu = room:getCardsFromPileByRule("analeptic",2,"allPiles")
      local duel = room:getCardsFromPileByRule("duel",1,"allPiles")
      if #slash>2 then
        table.insert(can,"#lingling__shenyong-slash")
      end
      if #duel>0 then
        table.insert(can,"#lingling__shenyong-duel")
      end
      if #wuzhong>0 then
        table.insert(can,"#lingling__shenyong-wuzhong")
      end
      if #jiu>1 then
        table.insert(can,"#lingling__shenyong-jiu")
      end
      if #can>1 then
        local getcards = {}
        local random = table.random(can,2)
        for _, gname in ipairs(random)do
          if gname == "#lingling__shenyong-slash" then
            table.insertTable(getcards,{slash[1],slash[2],slash[3]})
          elseif gname == "#lingling__shenyong-duel" then
            table.insert(getcards,duel[1])
          elseif gname == "#lingling__shenyong-wuzhong"then
            table.insert(getcards,wuzhong[1])
          else
            table.insertTable(getcards,{jiu[1],jiu[2]})
          end
        end
        if #getcards>0 then
          room:sendLog({
            type = "#lingling__xiangyu_random",
            from = player.id,
            arg2 = random[1],
            arg3 = random[2],
            toast = true,
          })
          player.room:moveCards({
            ids = getcards,
            to = player.id,
            toArea = Card.PlayerHand,
            moveReason = fk.ReasonPrey,
            proposer = player.id,
            skillName = self.name,
          })
        end
      else
      room:sendLog({
        type = "#lingling__xiangyu_fail",
        from = player.id,
        toast = true,
      })
    end
      return true
    else
      player.drank = 0
      room:broadcastProperty(player, "drank")
      if event == fk.BeforeDrawCard then
        data.num =data.num+2
      else
        data.damage = data.damage+1
      end
    end
  end,
}
local guaduan = fk.CreateTriggerSkill{
  name = "lingling__guaduan",
  anim_type = "masochism",
  frequency = Skill.Compulsory,
  events = {fk.Damaged},
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(self) and
      table.find(player:getCardIds("h"), function(id)
          return Fk:getCardById(id).trueName == "slash" and not player:prohibitDiscard(id)
      end)
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local cards = table.filter(player:getCardIds("h"), function(id)
      return Fk:getCardById(id).trueName == "slash" and not player:prohibitDiscard(id)
  end)
    room:throwCard(cards, self.name, player, player)
    if not player.dead then
      player:drawCards(math.min(2 * #cards, 4), self.name)
    end
  end,
}
xiangyu:addSkill(shenyong)
xiangyu:addSkill(guaduan)
Fk:loadTranslationTable{
  ["lingling__xiangyu"] = "项羽",
  ["#lingling__xiangyu"] = "千古无二",
  ["illustrator:lingling__xiangyu"] = "漂泊诗人",
  ["designer:lingling__xiangyu"] = "伶",

  ["lingling__shenyong"] = "神勇",
  [":lingling__shenyong"] = "摸牌阶段，你改为从以下项中随机获得不同两项：1.一张【决斗】；2.一张【无中生有】；3.两张【酒】；4.三张【杀】。"..
  "你因【无中生有】摸牌时，若你为醉酒状态，消耗此状态多摸两张牌。你使用【决斗】对目标造成伤害时，若你为醉酒状态，消耗此状态令伤害+1。",
  ["lingling__guaduan"] = "寡断",
  [":lingling__guaduan"] = "当你受到伤害后，你弃置手牌中的【杀】并摸两倍的牌（至多摸四张）。"..
  "<br><br> <font color = '#a40000'>楚虽三户，亡秦必楚。",
  ["#lingling__shenyong-duel"] = "一张【决斗】",
  ["#lingling__shenyong-wuzhong"] = "一张【无中生有】",
  ["#lingling__shenyong-jiu"] = "两张【酒】",
  ["#lingling__shenyong-slash"] = "三张【杀】",
  ["#lingling__xiangyu_random"]="%from 从牌堆中获得了 %arg2 和 %arg3 ",
  ["#lingling__xiangyu_less"]="%from 颓势尽显，只获得了 %arg2 ",
  ["#lingling__xiangyu_fail"]="天欲亡汝！ %from 因牌堆和弃牌堆无法提供所需牌而兵尽粮绝！西楚霸王变王八~ ",
}

local lishimin = General:new(extension, "lingling__lishimin", "tang", 4, 4, General.Male)--
Fk:loadTranslationTable{
    ["lingling__lishimin"] = "李世民",
    ["#lingling__lishimin"] = "龙凤神武",
    ["designer:lingling__lishimin"] = "伶伶",
    ["illustrator:lingling__lishimin"] = "伊达未来",
    ["cv:lingling__lishimin"] = "淼龙哥",
}
local mingshi = fk.CreateViewAsSkill{
    name = "lingling_mingshi",
    mute = true,
    pattern = "peach,slash,jink",
    card_filter = function(self, to_select, selected, player)
        return #selected < 2 and Fk:currentRoom():getCardArea(to_select) == Player.Hand
    end,
    interaction = function(self, player)
        local choices = {}
        for _, name in ipairs({"peach","slash","jink"}) do
            local card = Fk:cloneCard(name)
            if player:getMark("lingling_mingshi_"..name.."-round") == 0 and (((Fk.currentResponsePattern == nil and player:canUse(card)) or
            (Fk.currentResponsePattern and Exppattern:Parse(Fk.currentResponsePattern):match(card)))) then
                table.insertIfNeed(choices, name)
            end
        end
        if #choices == 0 then return false end
        return UI.ComboBox { choices = choices }
    end,
    view_as = function(self, cards)
        if #cards ~= 2 or not self.interaction.data then return nil end
        local c = Fk:cloneCard(self.interaction.data)
        c.skillName = self.name
        c:addSubcards(cards)
        return c
    end,
    before_use = function (self, player, use)
        player.room:notifySkillInvoked(player, self.name, "special")
        if self.interaction.data == "slash" then 
          player:broadcastSkillInvoke(self.name, 1)
        elseif self.interaction.data == "jink" then 
          player:broadcastSkillInvoke(self.name, 2)
        elseif self.interaction.data == "peach" then 
          player:broadcastSkillInvoke(self.name, 3)
        end
    end,
    after_use = function (self, player, use)
        local name = self.interaction.data
        player.room:setPlayerMark(player,"lingling_mingshi_"..name.."-round",1)
        player.room:setPlayerMark(player,"@@lingling_mingshi_"..name.."-round",1)
    end,
    enabled_at_play = function (self, player)
        local choices = {}
        for _, name in ipairs({"peach","slash","jink"}) do
            if player:getMark("lingling_mingshi_"..name.."-round") == 0 then
                table.insertIfNeed(choices, name)
            end
        end
        return #choices > 0
    end,
    enabled_at_response = function (self, player, response)
        if Fk.currentResponsePattern then
            for _, name in ipairs({"peach","slash","jink"}) do
                local card = Fk:cloneCard(name)
                if Exppattern:Parse(Fk.currentResponsePattern):match(card) then
                    if player:getMark("lingling_mingshi_"..name.."-round") == 0 then
                        return true
                    end
                end
            end
        end
    end,
}
local mingshi_trigger = fk.CreateTriggerSkill{
    name = "#lingling_mingshi_trigger",
    refresh_events = {fk.Damage,fk.Damaged,fk.HpRecover,fk.CardRespondFinished},
    can_refresh = function (self, event, target, player, data)
        if event == fk.Damage then
            return target == player and player:getMark("@@lingling_mingshi_slash-round") > 0
        elseif event == fk.Damaged then
            return target == player and player:getMark("@@lingling_mingshi_jink-round") > 0
        elseif event == fk.HpRecover then
            return target == player and player:getMark("@@lingling_mingshi_peach-round") > 0
        elseif event == fk.CardRespondFinished then
            return data.from == player.id and (data.card.trueName == "slash" or data.card.trueName == "jink" or data.card.trueName == "peach")
            and table.contains(data.card.skillNames, "lingling_mingshi")
        end
    end,
    on_refresh = function (self, event, target, player, data)
        local room = player.room
        if event == fk.Damage then
            room:setPlayerMark(player,"@@lingling_mingshi_slash-round",0)
            player:drawCards(3,"lingling_mingshi")
        elseif event == fk.Damaged then
            room:setPlayerMark(player,"@@lingling_mingshi_jink-round",0)
            player:drawCards(3,"lingling_mingshi")
        elseif event == fk.HpRecover then
            room:setPlayerMark(player,"@@lingling_mingshi_peach-round",0)
            player:drawCards(3,"lingling_mingshi")
        elseif event == fk.CardRespondFinished then
            local name = data.card.trueName
            room:setPlayerMark(player,"lingling_mingshi_"..name.."-round",1)
            room:setPlayerMark(player,"@@lingling_mingshi_"..name.."-round",1)
        end

        --[[local choices,all_choices = {},{}
        for _, skill in ipairs(player.player_skills) do
            if skill.frequency == Skill.Limited then
                table.insertIfNeed(all_choices, skill.name)
                if player:usedSkillTimes(skill.name, Player.HistoryGame) > 0 then
                    table.insertIfNeed(choices, skill.name)
                end
            end
        end
        if #choices == #all_choices then
            local skill = table.random(choices)
            player:setSkillUseHistory(skill, 0, Player.HistoryGame)
        end]]
    end,
}
mingshi:addRelatedSkill(mingshi_trigger)
lishimin:addSkill(mingshi)
local duomeng = fk.CreateViewAsSkill{
    name = "lingling_duomeng",
    mute = true,
    frequency = Skill.Limited,
    anim_type = "offensive",
    pattern = "archery_attack",
    card_filter = Util.FalseFunc,
    prompt = "#lingling_duomeng",
    view_as = function(self, cards)
        local c = Fk:cloneCard("archery_attack")
        c.skillName = self.name
        return c
    end,
    enabled_at_play = function (self, player)
        return player:usedSkillTimes(self.name,Player.HistoryGame) == 0
    end,
    before_use = function (self, player, use)
        player.room:notifySkillInvoked(player, self.name, "big")
        player:broadcastSkillInvoke(self.name, 3)
    end,
}
lishimin:addSkill(duomeng)
local dishu = fk.CreateViewAsSkill{
    name = "lingling_dishu",
    mute = true,
    frequency = Skill.Limited,
    anim_type = "offensive",
    pattern = "sincere_treat",
    card_filter = Util.FalseFunc,
    prompt = "#lingling_dishu",
    view_as = function(self, cards)
        local c = Fk:cloneCard("sincere_treat")
        c.skillName = self.name
        return c
    end,
    enabled_at_play = function (self, player)
        return player:usedSkillTimes(self.name,Player.HistoryGame) == 0
    end,
    before_use = function (self, player, use)
        player.room:notifySkillInvoked(player, self.name, "big")
        player:broadcastSkillInvoke(self.name, 3)
    end,
}
lishimin:addSkill(dishu)
local zhenguan = fk.CreateViewAsSkill{
    name = "lingling_zhenguan",
    mute = true,
    frequency = Skill.Limited,
    anim_type = "offensive",
    pattern = "god_salvation",
    card_filter = Util.FalseFunc,
    prompt = "#lingling_zhenguan",
    view_as = function(self, cards)
        local c = Fk:cloneCard("god_salvation")
        c.skillName = self.name
        return c
    end,
    enabled_at_play = function (self, player)
        return player:usedSkillTimes(self.name,Player.HistoryGame) == 0
    end,
    before_use = function (self, player, use)
        player.room:notifySkillInvoked(player, self.name, "big")
        player:broadcastSkillInvoke(self.name, 3)
    end,
}
lishimin:addSkill(zhenguan)
Fk:loadTranslationTable{
    ["lingling_mingshi"] = "命世",
    [":lingling_mingshi"] = "每轮各限一次，你可以将两张手牌当【杀】/【闪】/【桃】使用或打出，则本轮你下一次造成伤害/受到伤害/回复体力后，你摸三张牌。",
    ["@@lingling_mingshi_slash-round"] = "命世 造成伤害",
    ["@@lingling_mingshi_jink-round"] = "命世 受到伤害",
    ["@@lingling_mingshi_peach-round"] = "命世 回复体力",
    ["lingling_duomeng"] = "夺门",
    [":lingling_duomeng"] = "限定技，出牌阶段，你可以视为使用【万箭齐发】。",
    ["#lingling_duomeng"] = "夺门：你可以视为使用【万箭齐发】。",
    ["lingling_dishu"] = "帝术",
    [":lingling_dishu"] = "限定技，出牌阶段，你可以视为使用【推心置腹】。",
    ["#lingling_dishu"] = "帝术：你可以视为使用【推心置腹】。",
    ["lingling_zhenguan"] = "贞观",
    [":lingling_zhenguan"] = "限定技，出牌阶段，你可以视为使用【桃园结义】。"..
    "<br><br> <font color = '#a40000'>尔来一百九十载，天下至今歌舞之。",
    ["#lingling_zhenguan"] = "贞观：你可以视为使用【桃园结义】。",

    ["$lingling_mingshi1"] = "（杀）再奏破阵乐，发兵！",
    ["$lingling_mingshi2"] = "（闪）生死有命，你奈何不了我。",
    ["$lingling_mingshi3"] = "（桃）我想，天命，不该就此作罢。",
    --无语音的台词文本，在限定技播放时作为背景填充
    ["$lingling_duomeng1"] = "丹朱不群，致于四内震耸；今舜兵已随，敢问天下鼎。",
    ["$lingling_duomeng2"] = "非我欲取，实天所与，今不举，何时举?",
    ["$lingling_dishu1"] = "彘子威权，加诸隆重典名，我取其二三，足以治民。",
    ["$lingling_dishu2"] = "神武怡刑，甚害贤惠士亲，我戒之八九，足以衡臣。",
    ["$lingling_zhenguan1"] = "自往五百年，或曰汉光，或说隋文，我之治皆无其上。",
    ["$lingling_zhenguan2"] = "纵观三千载，有时桀纣，有时灾荒，我之民皆无其下。",
    --语音的台词文本，无视与背景文字匹配播放
    ["$lingling_duomeng3"] = "我决定了，今天，只有一个太子！",
    ["$lingling_dishu3"] = "谁在幕后，看清楚了。（提醒语气）",
    ["$lingling_zhenguan3"] = "有平天下之志，更应有，治天下之能。",
}

return extension
