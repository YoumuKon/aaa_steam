local extension = Package("aaa_steam_3design")
extension.extensionName = "aaa_steam"

local U = require "packages.utility.utility"
local RUtil = require "packages.aaa_fenghou.utility.rfenghou_util"
local DIY = require "packages.diy_utility.diy_utility"

Fk:loadTranslationTable{
  ["aaa_steam_3design"] = "三设吧赛选",
  ["steam3d"] = "三设",
}

local ruanxian = General:new(extension, "steam__ruanxian", "qun", 3, 3, General.Male)
local malong = General:new(extension, "steam__malong", "jin", 4, 4, General.Male)
local zhaozhi = General:new(extension, "steam__zhaozhi", "shu", 3, 3, General.Male)
local Darwin = General:new(extension, "steam__Darwin", "west", 3, 3, General.Male)
local leitongwulan = General:new(extension, "steam__leitongwulan", "shu", 4, 4, General.Male)
local zerong = General:new(extension, "steam__zerong", "qun", 4, 4, General.Male)
local zerong2 = General:new(extension, "steam__zerong2", "qun", 4, 4, General.Male) --这个是切形态用的
zerong2.total_hidden = true
local zangba = General:new(extension, "steam__zangba", "wei", 4, 4, General.Male)
local gongbenwuzang = General:new(extension, "steam__gongbenwuzang", "west", 4, 4, General.Male)
local sunba = General:new(extension, "steam__sunba", "wu", 4, 4, General.Male)
local Karna = General:new(extension, "steam__Karna", "west", 4, 4, General.Male)
local tengyin = General:new(extension, "steam__tengyin", "wu", 3, 4, General.Male)

local function AddWinAudio(general)
  local Win = fk.CreateActiveSkill{ name = general.name.."_win_audio" }
  Win.package = extension
  Fk:addSkill(Win)
end

local sixian = fk.CreateTriggerSkill{
  name = "steam__sixian",
  anim_type = "offensive",
  events = {fk.GameStart},
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) 
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
      local cards = {}
      table.insertTable(cards, room:getCardsFromPileByRule("slash|.|.|.|.|."))
      table.insertTable(cards, room:getCardsFromPileByRule("jink|.|.|.|.|."))
      table.insertTable(cards, room:getCardsFromPileByRule("peach|.|.|.|.|."))
      table.insertTable(cards, room:getCardsFromPileByRule("analeptic|.|.|.|.|."))
    if #cards == 4 then
      for _, id in ipairs(cards) do
        room:setCardMark(Fk:getCardById(id), "@@steam__sixian1", 1)
      end
      player:addToPile("steam__sixian_music", cards, true, self.name)
    end
  end,

  refresh_events = {fk.AfterCardsMove},
  can_refresh = function(self, event, target, player, data)
    for _, move in ipairs(data) do
      if move.toArea == Card.DiscardPile then
        for _, info in ipairs(move.moveInfo) do
          return Fk:getCardById(info.cardId):getMark("@@steam__sixian1") > 0 
        end
      end
    end
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    for _, move in ipairs(data) do
      for _, info in ipairs(move.moveInfo) do
        room:setCardMark(Fk:getCardById(info.cardId), "@@steam__sixian1", 0)
      end
    end
  end,
}
local qingtan = fk.CreateViewAsSkill{
  name = "steam__qingtan",
  mute = true,
  anim_type = "switch",
  prompt = "#steam__qingtan-viewas",
  pattern = "slash,jink,peach,analeptic|.|.|.|.|.",
  interaction = function()
  local all_names = {"slash","jink","peach","analeptic"}
  local names = U.getViewAsCardNames(Self, "steam__qingtan", all_names)
  for _, id in ipairs (all_names) do
    if Self:getMark("steam__qingtan_"..id.."-turn") > 0 then
      table.removeOne(names, id)
    end
   end
    if #names > 0 then
      return UI.ComboBox { choices = names, all_choices = all_names }
    end
  end,
  card_filter = Util.FalseFunc,
  view_as = function(self, cards)
    if not self.interaction.data then return end
    local card = Fk:cloneCard(self.interaction.data)
    card.skillName = self.name
    return card
  end,
  before_use = function(self, player, use)
    local room = player.room
    player:broadcastSkillInvoke(self.name, 1)
    room:setPlayerMark(player, "steam__qingtan_"..self.interaction.data.."-turn", 1)
    local x = 0
    if self.interaction.data == "slash" then 
      x = 1
    elseif self.interaction.data == "jink" then 
      x = 2
    elseif self.interaction.data == "peach" then 
      x = 3
    elseif self.interaction.data == "analeptic" then 
      x = 4
    end
    if x == 0 then return end
    local cards = room:askForCard(player, x, x, false, self.name, false, ".|.|.|steam__sixian_music", "#steam__qingtan-invoke:::"..x, "steam__sixian_music")
    for _, id in ipairs(cards) do
      if Fk:getCardById(id):getMark("@@steam__sixian1") == 1 then
      room:setCardMark(Fk:getCardById(id), "@@steam__sixian1", 0)
      else
      room:setCardMark(Fk:getCardById(id), "@@steam__sixian1", 1)
    end
    end
    if #table.filter(player:getPile("steam__sixian_music"), function(id)
      return Fk:getCardById(id):getMark("@@steam__sixian1") == 0 end) == 1
    and
    table.find(player:getPile("steam__sixian_music"), function(id) 
      return Fk:getCardById(id):getMark("@@steam__sixian1") == 0
      and Fk:getCardById(id).trueName == self.interaction.data end) then 
        if self.interaction.data == "slash" then 
          player:broadcastSkillInvoke(self.name, 2)
        elseif self.interaction.data == "jink" then 
          player:broadcastSkillInvoke(self.name, 3)
        elseif self.interaction.data == "peach" then 
          player:broadcastSkillInvoke(self.name, 4)
        elseif self.interaction.data == "analeptic" then 
          player:broadcastSkillInvoke(self.name, 5)
        end
      player:drawCards(1, self.name)
      use.extraUse = true
    else
      player:broadcastSkillInvoke(self.name, 6)
      return ""
    end
    end,
  enabled_at_play = function(self, player)
    local all_names = {"slash","jink","peach","analeptic"}
    local names = U.getViewAsCardNames(player, "steam__qingtan", all_names)
    for _, id in ipairs (all_names) do
      if player:getMark("steam__qingtan_"..id.."-turn") > 0 then
        table.removeOne(names, id)
      end
     end
     for _, name in ipairs(names) do
      local to_use = Fk:cloneCard(name)
      if not to_use.skill:canUse(player, to_use, {bypass_times = true , bypass_distances = true}) 
      or player:prohibitUse(to_use) then
      table.removeOne(names, name)
      end
    end
    return #names > 0 and #player:getPile("steam__sixian_music") == 4
  end,
  enabled_at_response = function(self, player, res)
    local all_names = {"slash","jink","peach","analeptic"}
    local names = U.getViewAsCardNames(player, "steam__qingtan", all_names)
    for _, id in ipairs (all_names) do
      if player:getMark("steam__qingtan_"..id.."-turn") > 0 then
        table.removeOne(names, id)
      end
     end
     for _, name in ipairs(names) do
      local to_use = Fk:cloneCard(name)
      return not res and Fk.currentResponsePattern and Exppattern:Parse(Fk.currentResponsePattern):match(to_use) and #player:getPile("steam__sixian_music") == 4
    end
  end,
}
local qingtan_targetmod = fk.CreateTargetModSkill{
  name = "#steam__qingtan_targetmod",
  bypass_times =  function(self, player, skill, scope, card)
    return card and ((skill.trueName == "slash_skill" and scope == Player.HistoryPhase) or (skill.trueName == "analeptic_skill" and scope == Player.HistoryTurn)) 
    and table.contains(card.skillNames, "steam__qingtan")
  end,
  bypass_distances =  function(self, player, skill, card, to)
    return card and table.contains(card.skillNames, "steam__qingtan")
  end,
}
qingtan:addRelatedSkill(qingtan_targetmod)
ruanxian:addSkill(sixian)
ruanxian:addSkill(qingtan)
AddWinAudio(ruanxian)
Fk:loadTranslationTable{
  ["steam__ruanxian"] = "阮咸",
  ["#steam__ruanxian"] = "妙音八达",
  ["cv:steam__ruanxian"] = "张让",
  ["illustrator:steam__ruanxian"] = "恶童",
  ["designer:steam__ruanxian"] = "不能更改",

  ["steam__sixian"] = "四弦",
  [":steam__sixian"] = "锁定技，游戏开始时，你将牌堆中【杀】【闪】【桃】【酒】各一张暗置于武将牌上，称为“弦”。<a href='steam__xian_href'>注释</a>",
  ["steam__qingtan"] = "清弹",
  [":steam__qingtan"] = "每回合每种牌名各限一次，当你需要使用【杀】/【闪】/【桃】/【酒】时，你可以翻面一/二/三/四张“弦”。若仅剩对应牌名的“弦”正面朝上，你摸一张牌并视为使用之（无距离与次数限制）。",
  ["steam__sixian_music"] = "四弦",
  ["@@steam__sixian1"] = "暗弦",
  ["#steam__qingtan-viewas"] = "请选择 清弹 视为使用的基本牌（无距离次数限制，但需要满足技能所示条件，注意，有“暗弦”标记的弦牌处于暗置状态！）",
  ["#steam__qingtan-invoke"] = "清弹：请将 %arg 张“弦”翻面（注意，有“暗弦”标记的弦牌处于暗置状态！）",
  ["steam__xian_href"] = "有“暗弦”标记的弦牌视为处于暗置状态，所有弦开局都添加“暗弦”标记并视为暗置。",

  ["$steam__sixian1"] = "此器四弦十二柱，当奏五音闻九霄！",
  ["$steam__sixian2"] = "此林七友才百斗，当著千文传万世！",
  ["$steam__qingtan1"] = "（开始）宫商角徵羽，尽在一弹一拨之中。",
  ["$steam__qingtan2"] = "（杀）收拨当心画，一声如裂帛！",
  ["$steam__qingtan3"] = "（闪）洛灵凌波步，君子回首顾。",
  ["$steam__qingtan4"] = "（桃）岭南佳果在席，天下美馔失色！",
  ["$steam__qingtan5"] = "（酒）取盆载杜康，杜康与豕，杜康与人！",
  ["$steam__qingtan6"] = "（失败）管短尺黍余，此所以音律不谐也。",
  ["$steam__ruanxian_win_audio"] = "丝竹和鸣，曲水流觞，隐居世外，不为俗世所扰。",
  ["~steam__ruanxian"] = "故友远，草兽偃，杯酒独酌，天年独终...",
} --阮咸

local jizhen = fk.CreateTriggerSkill{
  name = "steam__jizhen",
  mute = true,
  events = {fk.CardUseFinished},
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and data.card and (player:getMark("steam__jizhen2_basic") > 0
    or player:getMark("steam__jizhen2_nonbasic") > 0) and (player:getMark("steam__jizhen1_basic") > 0 or player:getMark("steam__jizhen1_nonbasic") > 0)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local skills = {}
      if not player:hasSkill("steam__malong__paoxiao", true) and player:getMark("steam__jizhen1_basic") > 0 then
        table.insert(skills, "steam__malong__paoxiao")
      end
      if not player:hasSkill("steam__malong__longdan", true) and player:getMark("steam__jizhen2_basic") > 0 then
        table.insert(skills, "steam__malong__longdan")
      end
      if not player:hasSkill("steam__malong__bazhen", true) and player:getMark("steam__jizhen1_nonbasic") > 0 and player:getMark("steam__jizhen2_nonbasic") > 0 then
        table.insert(skills, "steam__malong__bazhen")
      end
      room:setPlayerMark(player, "steam__jizhen1_basic", 0)
      room:setPlayerMark(player, "steam__jizhen1_nonbasic", 0)
      room:setPlayerMark(player, "steam__jizhen2_basic", 0)
      room:setPlayerMark(player, "steam__jizhen2_nonbasic", 0)
      room:setPlayerMark(player, "@steam__jizhen", string.format("%s %s", "~", "~"))
    if #skills > 0 then
      if #skills == 1 then
        player:broadcastSkillInvoke(self.name, math.random(2))
      else
        player:broadcastSkillInvoke(self.name, 3)
      end
      room:handleAddLoseSkills(player, table.concat(skills, "|"), nil, true, false)
    end
  end,

  refresh_events = {fk.CardUseFinished},
  can_refresh = function(self, event, target, player, data)
    return target == player and player:hasSkill(self, true) and data.card
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    if data.card.type == Card.TypeBasic then
      if player:getMark("steam__jizhen1_basic") == 0 and player:getMark("steam__jizhen1_nonbasic") == 0 then
        room:setPlayerMark(player, "steam__jizhen1_basic", 1)
      elseif player:getMark("steam__jizhen2_basic") == 0 and player:getMark("steam__jizhen2_nonbasic") == 0 then
        room:setPlayerMark(player, "steam__jizhen2_basic", 1)
      end
    elseif data.card.type ~= Card.TypeBasic then
      if player:getMark("steam__jizhen1_basic") == 0 and player:getMark("steam__jizhen1_nonbasic") == 0 then
        room:setPlayerMark(player, "steam__jizhen1_nonbasic", 1)
      elseif player:getMark("steam__jizhen2_basic") == 0 and player:getMark("steam__jizhen2_nonbasic") == 0 then
        room:setPlayerMark(player, "steam__jizhen2_nonbasic", 1)
      end
    end
     room:setPlayerMark(player, "@steam__jizhen", string.format("%s %s",
     (player:getMark("steam__jizhen1_basic") > 0 and "咆哮") or (player:getMark("steam__jizhen1_nonbasic") > 0 and "X") or "~",
     (player:getMark("steam__jizhen2_basic") > 0 and "龙胆") or (player:getMark("steam__jizhen2_nonbasic") > 0 and "八阵") or "~"))
  end,

  on_acquire = function (self, player, is_start)
    local room = player.room
    room:setPlayerMark(player, "@steam__jizhen", string.format("%s %s", "~", "~"))
  end,

  on_lose = function (self, player, is_death)
    local room = player.room
    room:setPlayerMark(player, "steam__jizhen1_basic", 0)
    room:setPlayerMark(player, "steam__jizhen1_nonbasic", 0)
    room:setPlayerMark(player, "steam__jizhen2_basic", 0)
    room:setPlayerMark(player, "steam__jizhen2_nonbasic", 0)
    room:setPlayerMark(player, "@steam__jizhen", 0)
  end,
}
local pianxiang = fk.CreateTriggerSkill{
  name = "steam__pianxiang",
  mute = true,
  anim_type = "drawcard",
  events = {fk.TurnEnd},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local skills = table.map(table.filter(player.player_skills, function (s)
      return s:isPlayerSkill(player) and s.visible
    end), Util.NameMapper)
    -- 为了避免删除未发动的技能，故做一下区分（甚至注释部分都能拉神张郃的代码用，神张郃的码佬太强太强）
    local skillToStr = function (list)
      return table.map(list, function (s)
        local skill = Fk.skills[s]
        if (skill.frequency == Skill.Limited or skill.frequency == Skill.Wake) and player:usedSkillTimes(s, Player.HistoryGame) > 0 then
          s = "SteamSkillInvoked:::"..s
        end
        return s
      end)
    end
    local returnSkill = function (list)
      return table.map(list, function (s)
        if s:startsWith("SteamSkillInvoked") then
          s = s:split(":::")[2]
        end
        return s
      end)
    end
    skills = skillToStr(skills)
    local tolose = {}
    tolose = room:askForChoices(player, skills, 1, 999, self.name, "#steam__pianxiang-lose", false)
    local printcard = false
    if table.contains(tolose, "steam__jizhen") or table.contains(tolose, "steam__pianxiang") then
      printcard = true
    end
    tolose = returnSkill(tolose)
    if #tolose > 0 then
      player:broadcastSkillInvoke(self.name, math.random(2))
      room:handleAddLoseSkills(player, "-"..table.concat(tolose, "|-"))
      if not player.dead then
      player:drawCards(#tolose, self.name)
      if printcard then
      local cards = U.getUniversalCards(room, "bt", false)
      local use = U.askForUseRealCard(room, player, cards, nil, self.name, "#steam__pianxiang-ask",
        {expand_pile = cards, bypass_times = true, extraUse = true}, true, false)
      if use then
        player:broadcastSkillInvoke(self.name, 3)
        use = {
          card = Fk:cloneCard(use.card.name),
          from = player.id,
          tos = use.tos,
        }
        use.card.skillName = self.name
        room:useCard(use)
      end
      end
      end
    end
  end,
}

local steam__malong__longdan = fk.CreateViewAsSkill{
  name = "steam__malong__longdan",
  pattern = "slash,jink,peach,analeptic",
  handly_pile = true,
  card_filter = function(self, to_select, selected)
    if #selected ~= 0 then return false end
    local _c = Fk:getCardById(to_select)
    local c
    if _c.trueName == "slash" then
      c = Fk:cloneCard("jink")
    elseif _c.name == "jink" then
      c = Fk:cloneCard("slash")
    elseif _c.name == "peach" then
      c = Fk:cloneCard("analeptic")
    elseif _c.name == "analeptic" then
      c = Fk:cloneCard("peach")
    else
      return false
    end
    return (Fk.currentResponsePattern == nil and c.skill:canUse(Self, c)) or
      (Fk.currentResponsePattern and Exppattern:Parse(Fk.currentResponsePattern):match(c))
  end,
  view_as = function(self, cards)
    if #cards ~= 1 then
      return nil
    end
    local _c = Fk:getCardById(cards[1])
    local c
    if _c.trueName == "slash" then
      c = Fk:cloneCard("jink")
    elseif _c.name == "jink" then
      c = Fk:cloneCard("slash")
    elseif _c.name == "peach" then
      c = Fk:cloneCard("analeptic")
    elseif _c.name == "analeptic" then
      c = Fk:cloneCard("peach")
    end
    c.skillName = self.name
    c:addSubcard(cards[1])
    return c
  end,
}
Fk:loadTranslationTable{
  ["steam__malong__longdan"] = "龙胆",
  [":steam__malong__longdan"] = "你可以将一张【杀】当【闪】、【闪】当【杀】、【酒】当【桃】、【桃】当【酒】使用或打出。",
}

local steam__malong__paoxiao = fk.CreateTriggerSkill{
  name = "steam__malong__paoxiao",
  anim_type = "offensive",
  frequency = Skill.Compulsory,
  events = {fk.DamageCaused, fk.CardEffectCancelledOut},
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if event == fk.CardEffectCancelledOut then
      return player == target and data.card.trueName == "slash" and player:hasSkill(self)
    elseif event == fk.DamageCaused then
      return player == target and data.card and data.card.trueName == "slash" and player.room.logic:damageByCardEffect() and
      player:getMark("@paoxiao-turn") > 0 and player:hasSkill(self)
    end
  end,
  on_use = function(self, event, target, player, data)
    if event == fk.CardEffectCancelledOut then
      player.room:addPlayerMark(player, "@paoxiao-turn")
    elseif event == fk.DamageCaused then
      data.damage = data.damage + player:getMark("@paoxiao-turn")
      player.room:setPlayerMark(player, "@paoxiao-turn", 0)
    end
  end,

  refresh_events = {fk.CardUsing},
  can_refresh = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and
      data.card.trueName == "slash" and player:usedCardTimes("slash") > 1
  end,
  on_refresh = function(self, event, target, player, data)
    player:broadcastSkillInvoke("steam__malong__paoxiao")
    player.room:doAnimate("InvokeSkill", {
      name = "steam__malong__paoxiao",
      player = player.id,
      skill_type = "offensive",
    })
  end,
}
local steam__malong__paoxiao_target = fk.CreateTargetModSkill{
  name = "#steam__malong__paoxiao_target",
  bypass_times = function(self, player, skill, scope)
    return player:hasSkill(steam__malong__paoxiao) and skill.trueName == "slash_skill" and scope == Player.HistoryPhase
  end,
}
steam__malong__paoxiao:addRelatedSkill(steam__malong__paoxiao_target)
Fk:loadTranslationTable{
  ["steam__malong__paoxiao"] = "咆哮",
  [":steam__malong__paoxiao"] = "锁定技，你使用【杀】无次数限制；当你使用的【杀】被抵消后，你本回合下次【杀】造成的伤害+1。",
  ["@paoxiao-turn"] = "咆哮",
}

local steam__malong__bazhen = fk.CreateTriggerSkill{
  name = "steam__malong__bazhen",
  events = {fk.AskForCardUse, fk.AskForCardResponse},
  frequency = Skill.Compulsory,
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and not player:isFakeSkill(self) and
      (data.cardName == "jink" or (data.pattern and Exppattern:Parse(data.pattern):matchExp("jink|0|nosuit|none"))) and
      not player:getEquipment(Card.SubtypeArmor)
      and Fk.skills["#eight_diagram_skill"] ~= nil and Fk.skills["#eight_diagram_skill"]:isEffectable(player)
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askForSkillInvoke(player, self.name, data)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local judgeData = {
      who = player,
      reason = "eight_diagram",
      pattern = ".|.|heart,diamond",
    }
    room:judge(judgeData)

    if judgeData.card.color == Card.Red then
      local card = Fk:cloneCard("jink")
      card.skillName = "eight_diagram"
      card.skillName = "steam__malong__bazhen"
      if event == fk.AskForCardUse then
        if player:prohibitUse(card) then return false end
        data.result = {
          from = player.id,
          card = card,
        }
        if data.eventData then
          data.result.toCard = data.eventData.toCard
          data.result.responseToEvent = data.eventData.responseToEvent
        end
      else
        if player:prohibitResponse(card) then return false end
        data.result = card
      end
      return true
    end
  end
}
Fk:loadTranslationTable{
  ["steam__malong__bazhen"] = "八阵",
  [":steam__malong__bazhen"] = "锁定技，若你没有装备防具，视为你装备着【八卦阵】。",
}

malong:addSkill(jizhen)
malong:addSkill(pianxiang)
malong:addRelatedSkill(steam__malong__paoxiao)
malong:addRelatedSkill(steam__malong__longdan)
malong:addRelatedSkill(steam__malong__bazhen)
AddWinAudio(malong)

Fk:loadTranslationTable{
  ["steam__malong"] = "马隆",
  ["#steam__malong"] = "孤师妙器",
  ["cv:steam__malong"] = "幽蝶化烬",
  ["illustrator:steam__malong"] = "恶童",
  ["designer:steam__malong"] = "亚里士缺德",

  ["steam__jizhen"] = "机阵",
  [":steam__jizhen"] = "锁定技，你每累计使用两张牌后，根据所满足的条件获得对应技能：第一张为基本牌--“咆哮”；第二张为基本牌--“龙胆”；均不为基本牌--“八阵”。",
  ["steam__pianxiang"] = "偏箱",
  [":steam__pianxiang"] = "每回合结束时，你可以失去任意个技能，然后摸等量张牌。若你因此失去“机阵”或“偏箱”，你视为使用一张基本牌或普通锦囊牌。",
  ["@steam__jizhen"] = "机阵",
  ["SteamSkillInvoked"] = "%arg(已发动)",
  ["#steam__pianxiang-lose"] = "偏箱：请失去至少一个技能，摸等量张牌，失去机阵或偏箱则额外视为使用基本牌或普通锦囊牌。",
  ["#steam__pianxiang-ask"] = "偏箱：请使用一张基本牌或普通锦囊牌！",

  ["$steam__jizhen1"] = "云附于地，则知无形。变为翔鸟，其状乃成。",
  ["$steam__jizhen2"] = "风无正形，附之于天。变而为蛇，其意渐玄。",
  ["$steam__jizhen3"] = "（获得两个）鸷鸟击搏，必先翱翔。势凌霄汉，飞禽伏藏。",
  ["$steam__pianxiang1"] = "阔构营，狭垒箱，伏弩齐射，教彼进退两难！",
  ["$steam__pianxiang2"] = "着犀甲，布磁石，诈败诱之，要其有来无回！",
  ["$steam__pianxiang3"] = "（用牌）中原之工巧，蛮儿焉能究其理？",
  ["$steam__malong_win_audio"] = "边患荡除，百姓乐业，用兵得此，善莫大焉！",
  ["$steam__malong__paoxiao"] = "风能鼓动，万物惊焉；蛇能围绕，三军惧焉。",
  ["$steam__malong__longdan"] = "潜则不测，动则无穷。阵形亦然，象名其龙。",
  ["$steam__malong__bazhen"] = "可握则握，可施则施。千变万化，敌莫能知。",
  ["~steam__malong"] = "匹夫！老农逐豕尚不执朽木，况我良将锐士乎！",
} --马隆

--赵直有关结算：称梦角色同时最多存在一个，已有的可以转移，已死亡则下个回合开始可以重新指定

local chengmeng = fk.CreateTriggerSkill{
  name = "steam__chengmeng",
  mute = true,
  events = {fk.BeforeChainStateChange, fk.TurnStart, fk.Damaged, fk.RoundStart},
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player, data)
    local room = player.room
    if not player:hasSkill(self) then return false end
    if event == fk.BeforeChainStateChange then
      return target:getMark("@@chengmeng_lost-round") > 0 and target.chained
    elseif event == fk.TurnStart then
      return not player:isNude() and #table.filter(room.alive_players, function(p)
        return p:getMark("@@chengmeng-round") > 0 end) <= 1
    elseif event == fk.Damaged then
      return target:getMark("@@chengmeng-round") > 0 and table.find(room.alive_players, function(p)
      return p ~= target and p:isWounded() and p.hp == p:getHandcardNum() end)
    else
      return not table.find(player.room.alive_players, function(p) return p:getMark("@@chengmeng-round") > 0 end)
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    if event == fk.BeforeChainStateChange then
      return true
    elseif event == fk.TurnStart then
    local card = room:askForDiscard(player, 1, 1, true, self.name, true, ".|.|heart,diamond", "steam__chengmeng-ask")
    if #card > 0 and #table.filter(room.alive_players, function(p) return p:getMark("@@chengmeng-round") == 0 end) > 0 then
    local to = room:askForChoosePlayers(player, table.map(table.filter(room.alive_players, function(p)
      return p:getMark("@@chengmeng-round") == 0 end), Util.IdMapper), 1, 1,
      "steam__chengmeng-redefine", self.name, true)
    if #to > 0 then
      self.cost_data = to[1]
      return true
      end
    end
    elseif event == fk.Damaged then
    local to = room:askForChoosePlayers(player, table.map(table.filter(room.alive_players, function(p)
      return p ~= target and p:isWounded() and p.hp == p:getHandcardNum() end), Util.IdMapper), 1, 1,
      "steam__chengmeng-recover", self.name, true)
    if #to > 0 then
      self.cost_data = to[1]
      return true
    end
    else
    local to = room:askForChoosePlayers(player, table.map(player.room:getAlivePlayers(), Util.IdMapper), 1, 1, 
    "steam__chengmeng-invoke", self.name, false)
    if #to > 0 then
      self.cost_data = to[1]
      return true
    end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if event == fk.BeforeChainStateChange then
      player:broadcastSkillInvoke(self.name, 4)
      return true
    elseif event == fk.TurnStart then
      player:broadcastSkillInvoke(self.name, 3)
      for _, p in ipairs(room:getAlivePlayers()) do
        if p:getMark("@@chengmeng-round") > 0 then
        room:setPlayerMark(p, "@@chengmeng-round", 0)
        room:setPlayerMark(p, "@@chengmeng_lost-round", 1)
        p:setChainState(true)
        end
      end
      local to = room:getPlayerById(self.cost_data)
      room:setPlayerMark(to, "@@chengmeng-round", 1)
    elseif event == fk.Damaged then
      player:broadcastSkillInvoke(self.name, 2)
      local to = room:getPlayerById(self.cost_data)
      room:recover({
        who = to,
        num = 1,
        recoverBy = player,
        skillName = self.name
      })
    else
      player:broadcastSkillInvoke(self.name, 1)
      local to = room:getPlayerById(self.cost_data)
      room:setPlayerMark(to, "@@chengmeng-round", 1)
    end
  end,
}

local yuexin = fk.CreateActiveSkill{
  name = "steam__yuexin",
  anim_type = "drawcard",
  prompt = "#steam__yuexin-active",
  card_num = 0,
  target_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) < 1
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, to_select, selected, selected_cards)
    return #selected == 0 and not Fk:currentRoom():getPlayerById(to_select):isKongcheng()
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    target:drawCards(target:getHandcardNum(), self.name)
    local x = 0
    if not target:isKongcheng() then
    target:showCards(target.player_cards[target.Hand])
    local ids = {}
    for _, id in ipairs(target.player_cards[target.Hand]) do
      if Fk:getCardById(id).type == Card.TypeBasic then
      table.insert(ids, id)
      end
    end
    if #ids > 0 then
      x = #ids
      room:throwCard(ids, self.name, target, target)
    end
    end
    if x ~= target.hp then
      room:damage{
        from = player,
        to = target,
        damage = 1,
        damageType = fk.FireDamage,
        skillName = self.name,
      }
    end
    end,
}
zhaozhi:addSkill(chengmeng)
zhaozhi:addSkill(yuexin)
Fk:loadTranslationTable{
  ["steam__zhaozhi"] = "赵直",
  ["#steam__zhaozhi"] = "大梦与初",
  ["cv:steam__zhaozhi"] = "官方",
  ["illustrator:steam__zhaozhi"] = "白",
  ["designer:steam__zhaozhi"] = "风尘慰酒",

  ["steam__chengmeng"] = "称梦",
  [":steam__chengmeng"] = "轮次开始时，你可以选择一名角色。本轮你以此法选择的角色受到伤害后，你可以令另一名手牌数与体力值相等的角色回复1点体力。"..
  "一个回合开始时，你可以弃置一张红色牌，变更本轮你以此法选择的角色，然后原角色横置且本轮始终横置。",
  ["steam__yuexin"] = "曰心",
  [":steam__yuexin"] = "出牌阶段限一次，你可以令一名有手牌的角色将手牌数翻倍，然后其展示手牌，弃置其中的基本牌，若弃置牌数不等于其的体力值，你对其造成1点火焰伤害。",

  ["steam__chengmeng-ask"] = "是否发动 称梦，弃置一张红色牌，然后转移“称梦”标记。",
  ["steam__chengmeng-redefine"] = "发动 称梦，请转移“称梦”标记。",
  ["steam__chengmeng-recover"] = "是否发动 称梦，令一名符合条件的角色回复1点体力？",
  ["steam__chengmeng-invoke"] = "发动 称梦，令一名角色获得“称梦”标记。",
  ["@@chengmeng-round"] = "称梦",
  ["@@chengmeng_lost-round"] = "失去称梦",
  ["#steam__yuexin-active"] = "发动 曰心，令一名有手牌的角色翻倍手牌数，然后其弃置所有基本牌并有可能受到你的火焰伤害。",

  ["$steam__chengmeng1"] = "（添加标记）壮、善、智、明、仁，人虽同而性各异。",
  ["$steam__chengmeng2"] = "（回复体力）窥天之道者，天自怜之。",
  ["$steam__chengmeng3"] = "（转移标记）既为命数之咽喉，不受天数之所咎。",
  ["$steam__chengmeng4"] = "（重新横置）梦境渺如水月，难辨其间虚实。",
  ["$steam__yuexin1"] = "常怀敬畏于怪力，不坠清明于乱神。",
  ["$steam__yuexin2"] = "物有其征，日所思之、夜所梦之。",
  ["~steam__zhaozhi"] = "临渊解梦，何如直挂云帆？",
} --赵直

local ziranxuanze_active = fk.CreateActiveSkill{
  name = "steam__ziranxuanze_active",
  card_num = 0,
  min_target_num = 1,
  max_target_num = 999,
  card_filter = Util.FalseFunc,
  target_filter = function(self, to_select, selected)
    local target = Fk:currentRoom():getPlayerById(to_select)
    if #selected == 0 then
      return true
    else
      for _, id in ipairs(selected) do
        local p = Fk:currentRoom():getPlayerById(id)
        if target.kingdom == p.kingdom then
          return false
        end
      end
      return true
    end
  end,
}
Fk:addSkill(ziranxuanze_active)
local ziranxuanze = fk.CreateTriggerSkill{
  name = "steam__ziranxuanze",
  mute = true,
  anim_type = "special",
  events = {fk.RoundStart},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local _, dat = room:askForUseActiveSkill(player, "steam__ziranxuanze_active", "#steam__ziranxuanze-active", true, nil, false)
    if dat then
      self.cost_data = {tos = dat.targets, choice = dat.interaction}
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local tos = self.cost_data.tos
    room:sortPlayersByAction(tos)
    tos = table.map(tos, Util.Id2PlayerMapper)

    local choices = {}
    local mark = player:getTableMark("@steam__ziranxuanze")
    for _, id in ipairs(mark) do
      table.insertIfNeed(choices, id)
    end
    local result = U.askForJointChoice(tos, choices, self.name,
      "#steam__ziranxuanze_choose")
 
    local x = 0
    local y = 0
    local z = 0
    if not table.contains(mark, "Darwin_rende") then
      x = -1
    end
    if not table.contains(mark, "Darwin_jianxiong") then
      y = -1
    end
    if not table.contains(mark, "Darwin_zhiheng") then
      z = -1
    end
    for _, p in ipairs(tos) do
      local choice = result[p.id]
      if choice == "Darwin_rende" then
        x = x + 1
      elseif choice == "Darwin_jianxiong" then
        y = y + 1
      elseif choice == "Darwin_zhiheng" then
        z = z + 1
      end
    end
    local nochoices = {}
    local min_value --非负值：未被移除；负值：已移除；非负值中最小的选项加入可删除名单 
    if x >= 0 and y >= 0 and z >= 0 then
    min_value = math.min(x, y, z)
    elseif x >= 0 and y >= 0 and z < 0 then
    min_value = math.min(x, y)
    elseif x >= 0 and y < 0 and z >= 0 then
    min_value = math.min(x, z)
    elseif x < 0 and y >= 0 and z >= 0 then
    min_value = math.min(y, z)
    elseif x >= 0 and y < 0 and z < 0 then
    min_value = x
    elseif x < 0 and y >= 0 and z < 0 then
    min_value = y
    elseif x < 0 and y < 0 and z >= 0 then
    min_value = z
    end
    if min_value == x then
      table.insertIfNeed(nochoices, "Darwin_rende")
    end
    if min_value == y then
      table.insertIfNeed(nochoices, "Darwin_jianxiong")
    end
    if min_value == z then
      table.insertIfNeed(nochoices, "Darwin_zhiheng")
    end
    local clear = false
    if player:getMark("@@steam__xungensuyuan1") == 0 and player:getMark("@@steam__xungensuyuan2") == 0 and player:getMark("@@steam__xungensuyuan3") == 0 then
      clear = true --判断一下是否已经有修改寻根溯源的记录，防止寻根溯源同时等于仁德和制衡（问就是二合一了）
    end
    if #mark > 1 and #nochoices > 0 then
    local nochoice = room:askForChoice(player, nochoices, self.name, "#steam__ziranxuanze_remove", false, {"Darwin_rende", "Darwin_jianxiong", "Darwin_zhiheng"})
    if #mark == 3 and nochoice == "Darwin_rende" and clear then
      room:setPlayerMark(player, "@@steam__xungensuyuan1", 1)
    elseif #mark == 3 and nochoice == "Darwin_jianxiong" then
      room:setPlayerMark(player, "@@steam__xungensuyuan2", 1)
    elseif #mark == 3 and nochoice == "Darwin_zhiheng" then
      room:setPlayerMark(player, "@@steam__xungensuyuan3", 1)
    end
    table.removeOne(mark, nochoice)
    room:setPlayerMark(player, "@steam__ziranxuanze", #mark > 0 and mark or 0)
    end
    for _, p in ipairs(tos) do
      local choice = result[p.id]
      if table.contains(mark, choice) then
      if choice == "Darwin_rende" then
        room:handleAddLoseSkills(p, "Darwin_rende", nil, false, true)
      elseif choice == "Darwin_jianxiong" then
        room:handleAddLoseSkills(p, "Darwin_jianxiong", nil, false, true)
      elseif choice == "Darwin_zhiheng" then
        room:handleAddLoseSkills(p, "Darwin_zhiheng", nil, false, true)
      end
      elseif not table.contains(mark, choice) then
        room:handleAddLoseSkills(p, "Darwin_benghuai", nil, false, true)
      end
    end
  end,

  refresh_events = {fk.RoundEnd},
  global = true,
  can_refresh = function(self, event, target, player, data)
    return true
  end,
  on_refresh = function(self, event, target, player, data)
    for _, p in ipairs(player.room:getAlivePlayers()) do
      player.room:handleAddLoseSkills(p, "-Darwin_rende", nil, false, true)
      player.room:handleAddLoseSkills(p, "-Darwin_jianxiong", nil, false, true)
      player.room:handleAddLoseSkills(p, "-Darwin_zhiheng", nil, false, true)
      player.room:handleAddLoseSkills(p, "-Darwin_benghuai", nil, false, true)
    end
  end,

  on_acquire = function (self, player, is_start)
    player.room:setPlayerMark(player, "@steam__ziranxuanze", {"Darwin_rende", "Darwin_jianxiong", "Darwin_zhiheng"})
  end,
  on_lose = function (self, player, is_death)
    local room = player.room
    room:setPlayerMark(player, "@steam__ziranxuanze", 0)
  end,
}
Darwin:addSkill(ziranxuanze)

--设计者的意思是可以获得对应技能或者修改本体效果，考虑到多获得技能又要被神华佗之类的蹭到，就把三个技能的效果耦合了。
local xungensuyuan = fk.CreateActiveSkill{
  name = "steam__xungensuyuan",
  anim_type = "special",
  prompt = function(self)
    if Self:getMark("@@steam__xungensuyuan1") == 1 then
      return "#xungensuyuan_rende"
    elseif Self:getMark("@@steam__xungensuyuan3") == 1 then
      return "#xungensuyuan_zhiheng"
    end
  end,
  interaction = function(self)
    local names = {}
    if Self:getMark("@@steam__xungensuyuan1") == 1 then
      table.insert(names, "xungensuyuan_rende")
    end
    if Self:getMark("@@steam__xungensuyuan3") == 1 then
      table.insert(names, "xungensuyuan_zhiheng")
    end
    if #names > 0 then
    return UI.ComboBox {choices = names}
    end
  end,
  can_use = function(self, player, card, extra_data)
    return 
    (table.find(Fk:currentRoom().alive_players, function(p) return p:getMark("_xungensuyuan_rende-phase") == 0 end) 
    and player:getMark("@@steam__xungensuyuan1") == 1) --仁德部分的判断
    or 
    (player:usedSkillTimes(self.name, Player.HistoryPhase) == 0 and player:getMark("@@steam__xungensuyuan3") == 1) --制衡部分的判断
  end,
  card_filter = function(self, to_select, selected)
    if self.interaction.data == "xungensuyuan_rende" then
      return table.contains(Self:getCardIds("h"), to_select)
  elseif self.interaction.data == "xungensuyuan_zhiheng" then
      return not Self:prohibitDiscard(Fk:getCardById(to_select))
    end
  end,
  target_filter = function(self, to_select, selected)
    return self.interaction.data == "xungensuyuan_rende" and 
      #selected == 0 and to_select ~= Self.id and Fk:currentRoom():getPlayerById(to_select):getMark("_xungensuyuan_rende-phase") == 0
  end,
  feasible = function(self, selected, selected_cards)
    return #selected_cards > 0
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    if self.interaction.data == "xungensuyuan_rende" then
    local cards = effect.cards
    local marks = player:getMark("_xungensuyuan_rende_cards-phase")
    room:moveCardTo(cards, Player.Hand, target, fk.ReasonGive, self.name, nil, false)
    room:addPlayerMark(player, "_xungensuyuan_rende_cards-phase", #cards)
    room:setPlayerMark(target, "_xungensuyuan_rende-phase", 1)
    if marks < 2 and marks + #cards >= 2 then
      cards = U.getUniversalCards(room, "b", false)
      local use = U.askForUseRealCard(room, player, cards, nil, self.name, "#xungensuyuan_rende-ask",
        {expand_pile = cards, bypass_times = false, extraUse = false}, true, true)
      if use then
        use = {
          card = Fk:cloneCard(use.card.name),
          from = player.id,
          tos = use.tos,
        }
        use.card.skillName = self.name
        room:useCard(use)
      end
    end
  elseif self.interaction.data == "xungensuyuan_zhiheng" then
    local hand = player:getCardIds(Player.Hand)
    local more = #hand > 0
    for _, id in ipairs(hand) do
      if not table.contains(effect.cards, id) then
        more = false
        break
      end
    end
    room:throwCard(effect.cards, self.name, player, player)
    if not player.dead then
    room:drawCards(player, #effect.cards + (more and 1 or 0), self.name)
    end
  end
  end,
}
local xungensuyuan_trigger = fk.CreateTriggerSkill{
  name = "#steam__xungensuyuan_trigger",
  anim_type = "masochism",
  events = {fk.Damaged},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player:getMark("@@steam__xungensuyuan2") == 1
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askForSkillInvoke(player, self.name, nil, "#steam__xungensuyuan_jianxiong")
  end,
  on_use = function(self, event, target, player, data)
    if data.card and U.hasFullRealCard(player.room, data.card) then
      player.room:obtainCard(player.id, data.card, true, fk.ReasonJustMove)
    end
    player:drawCards(1, self.name)
  end,
}
xungensuyuan:addRelatedSkill(xungensuyuan_trigger)
Darwin:addSkill(xungensuyuan)

--咨询了一下设计者，他觉得有仁德再获得/不获得都可以，这次先写一个可以重复技能的版本，以观后效
--（暂时没搞明白多个同效果同名称的技能写法，这里就改了四个只能因此获得的技能出来）

local rende = fk.CreateActiveSkill{
  name = "Darwin_rende",
  anim_type = "support",
  min_card_num = 1,
  target_num = 1,
  prompt = "#Darwin_rende",
  card_filter = function(self, to_select, selected)
    return table.contains(Self:getCardIds("h"), to_select)
  end,
  target_filter = function(self, to_select, selected)
    return #selected == 0 and to_select ~= Self.id and Fk:currentRoom():getPlayerById(to_select):getMark("_Darwin_rende-phase") == 0
  end,
  on_use = function(self, room, effect)
    local target = room:getPlayerById(effect.tos[1])
    local player = room:getPlayerById(effect.from)
    local cards = effect.cards
    local marks = player:getMark("_Darwin_rende_cards-phase")
    room:moveCardTo(cards, Player.Hand, target, fk.ReasonGive, self.name, nil, false)
    room:addPlayerMark(player, "_Darwin_rende_cards-phase", #cards)
    room:setPlayerMark(target, "_Darwin_rende-phase", 1)
    if marks < 2 and marks + #cards >= 2 then
      cards = U.getUniversalCards(room, "b", false)
      local use = U.askForUseRealCard(room, player, cards, nil, self.name, "#Darwin_rende-ask",
        {expand_pile = cards, bypass_times = false, extraUse = false}, true, true)
      if use then
        use = {
          card = Fk:cloneCard(use.card.name),
          from = player.id,
          tos = use.tos,
        }
        use.card.skillName = self.name
        room:useCard(use)
      end
    end
  end,
}
local jianxiong = fk.CreateTriggerSkill{
  name = "Darwin_jianxiong",
  anim_type = "masochism",
  events = {fk.Damaged},
  on_use = function(self, event, target, player, data)
    if data.card and U.hasFullRealCard(player.room, data.card) then
      player.room:obtainCard(player.id, data.card, true, fk.ReasonJustMove)
    end
    player:drawCards(1, self.name)
  end,
}
local zhiheng = fk.CreateActiveSkill{
  name = "Darwin_zhiheng",
  anim_type = "drawcard",
  min_card_num = 1,
  target_num = 0,
  prompt = "#Darwin_zhiheng",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  card_filter = function(self, to_select, selected)
    return not Self:prohibitDiscard(Fk:getCardById(to_select))
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local hand = player:getCardIds(Player.Hand)
    local more = #hand > 0
    for _, id in ipairs(hand) do
      if not table.contains(effect.cards, id) then
        more = false
        break
      end
    end
    room:throwCard(effect.cards, self.name, player, player)
    if not player.dead then
      room:drawCards(player, #effect.cards + (more and 1 or 0), self.name)
    end
  end
}
local benghuai = fk.CreateTriggerSkill{
  name = "Darwin_benghuai",
  anim_type = "negative",
  frequency = Skill.Compulsory,
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Finish and
      table.find(player.room.alive_players, function(p) return p.hp < player.hp end)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local choice = room:askForChoice(player, {"loseMaxHp", "loseHp"}, self.name)
    if choice == "loseMaxHp" then
      room:changeMaxHp(player, -1)
    else
      room:loseHp(player, 1, self.name)
    end
  end,
}
Fk:addSkill(rende)
Fk:addSkill(jianxiong)
Fk:addSkill(zhiheng)
Fk:addSkill(benghuai)

Fk:loadTranslationTable{
  ["steam__Darwin"] = "达尔文",
  ["#steam__Darwin"] = "能心演天",
  ["cv:steam__Darwin"] = "暂无",
  ["illustrator:steam__Darwin"] = "豆包AI",
  ["designer:steam__Darwin"] = "abeeabee",

  ["steam__ziranxuanze"] = "自然选择",
  [":steam__ziranxuanze"] = "轮次开始时，你可以令任意名势力各不相同的角色同时选择获得“仁德”，“奸雄”，“制衡”中的一个技能直至本轮结束，若选项数不为1，"..
  "你删除一个本次被选择次数最少的选项，选择此项的角色改为获得“崩坏”直至本轮结束。",
  ["steam__xungensuyuan"] = "寻根溯源",
  [":steam__xungensuyuan"] = "锁定技，你本局首次删除“自然选择”的选项后，本技能视为被删除项对应的技能。",
  ["steam__ziranxuanze_active"] = "自然选择",
  ["#steam__ziranxuanze-active"] = "自然选择：是否选择任意名势力各不相同的角色？",
  ["#steam__ziranxuanze_choose"] = "自然选择：请选择本轮你想获得的一个技能，若你选择的选项被选择次数最少，则改为本轮获得“崩坏”！",
  ["#steam__ziranxuanze_remove"] = "自然选择：请选择本轮被选择次数最少的一个技能选项，移除之！",
  ["@steam__ziranxuanze"] = "",
  ["@@steam__xungensuyuan1"] = "寻根溯源 仁德",
  ["@@steam__xungensuyuan2"] = "寻根溯源 奸雄",
  ["@@steam__xungensuyuan3"] = "寻根溯源 制衡",
  ["#steam__xungensuyuan_trigger"] = "寻根溯源",
  ["xungensuyuan_rende"] = "执行仁德效果",
  ["xungensuyuan_zhiheng"] = "执行制衡效果",
  ["#xungensuyuan_rende"] = "此技能视为仁德，请选择任意张手牌交给一名其他角色，若本阶段你首次因此交出至少两张牌，你可以视为使用有次数限制的基本牌。",
  ["#xungensuyuan_zhiheng"] = "此技能视为制衡，请选择任意张牌弃置，然后摸等量张牌，若你弃置所有手牌，此次摸牌数量+1。",
  ["#xungensuyuan_rende-ask"] = "寻根溯源：你可视为使用一张基本牌",
  ["#steam__xungensuyuan_jianxiong"] = "寻根溯源：此技能视为奸雄，是否发动本技能，收回对你造成伤害的牌（若有），然后摸一张牌？",

  ["Darwin_rende"] = "仁德",
  [":Darwin_rende"] = "出牌阶段每名角色限一次，你可以将任意张手牌交给一名其他角色，每阶段你以此法给出第二张牌时，你可以视为使用一张基本牌。",
  ["#Darwin_rende"] = "仁德：将任意张手牌交给一名角色，若此阶段交出达到两张，你可以视为使用一张基本牌",
  ["#Darwin_rende-ask"] = "仁德：你可视为使用一张基本牌",
  ["Darwin_jianxiong"] = "奸雄",
  [":Darwin_jianxiong"] = "当你受到伤害后，你可以获得对你造成伤害的牌并摸一张牌。",
  ["Darwin_zhiheng"] = "制衡",
  [":Darwin_zhiheng"] = "出牌阶段限一次，你可以弃置任意张牌并摸等量的牌。若你以此法弃置所有手牌，你多摸一张牌。",
  ["#Darwin_zhiheng"] = "制衡：你可以弃置任意张牌并摸等量的牌，若弃置了所有的手牌，多摸一张牌",
  ["Darwin_benghuai"] = "崩坏",
  [":Darwin_benghuai"] = "锁定技，结束阶段，若你不是体力值最小的角色，你选择：1.减1点体力上限；2.失去1点体力。",
  ["loseMaxHp"] = "减1点体力上限",
  ["loseHp"] = "失去1点体力",

} --达尔文

local haolie = fk.CreateActiveSkill{
  name = "steam__3designhaolie",
  mute = true,
  anim_type = "switch",
  switch_skill_name = "steam__3designhaolie",
  card_num = 0,
  target_num = 1,
  prompt = "#steam__3designhaolie",
  can_use = function(self, player)
    return player:getSwitchSkillState(self.name, false) == fk.SwitchYang
  end,
  card_filter = Util.FalseFunc,
  target_filter = function (self, to_select, selected, _, _, _, player)
    if #selected == 0 and to_select ~= player.id then
      return not Fk:currentRoom():getPlayerById(to_select):isKongcheng()
    end
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    player:broadcastSkillInvoke(self.name, math.random(2))
    local id = room:askForCardChosen(player, target, "h", self.name)
    room:throwCard({id}, self.name, target, player)
    local slash = Fk:cloneCard("slash")
    slash.skillName = self.name
    if Fk:getCardById(id).type == Card.TypeBasic and player:canUseTo(slash, target, { bypass_times = true, bypass_distances= true }) then
      room:useCard{
        from = player.id,
        card = slash,
        tos = { { target.id } },
        extraUse = true,
      }
    end
  end,
}

local haolieYin = fk.CreateTriggerSkill{
  name = "#steam__3designhaolieYinin",
  main_skill = haolie,
  mute = true,
  switch_skill_name = "steam__3designhaolie",
  events = {fk.AfterCardsMove},
  can_trigger = function(self, event, target, player, data)
    local current = table.find(player.room.alive_players, function(p) return p.phase ~= Player.NotActive end)
    if player:hasSkill(self) and current then
      for _, move in ipairs(data) do
        if (move.from == player.id and move.to ~= player.id) then
          return not current:isNude() and player:getSwitchSkillState("steam__3designhaolie", false) == fk.SwitchYin
        end
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local current = table.find(player.room.alive_players, function(p) return p.phase ~= Player.NotActive end)
    player:broadcastSkillInvoke("steam__3designhaolie", math.random(3,4))
    player.room:notifySkillInvoked(player, "steam__3designhaolie", "switch", {current.id})
    local id = player.room:askForCardChosen(player, current, "he", self.name)
    player.room:throwCard({id}, self.name, current, player)
  end,
}

haolie:addRelatedSkill(haolieYin)
leitongwulan:addSkill(haolie)

Fk:loadTranslationTable{
  ["steam__leitongwulan"] = "雷铜吴兰",
  ["#steam__leitongwulan"] = "身先酬志",
  ["cv:steam__leitongwulan"] = "文小鸢&小叶子",
  ["illustrator:steam__leitongwulan"] = "豆包ai",
  ["designer:steam__leitongwulan"] = "好孩子系我",

  ["steam__3designhaolie"] = "豪烈", --以牢蝶的直觉来看，估计也是重名好手，当然不能要求可能几年前的东西考虑这个
  [":steam__3designhaolie"] = "转换技，阳：出牌阶段，你可以弃置一名其他角色的一张手牌，若为基本牌，你视为对其使用一张【杀】。"..
  "阴：你失去牌后，你可以弃置当前回合角色的一张牌。",

  ["#steam__3designhaolie"] = "弃置其他角色一张手牌，若为基本牌，你视为对其使用一张【杀】。",
  ["#steam__3designhaolieYinin"] = "豪烈", 

  ["$steam__3designhaolie1"] = "男儿志在功业，逢战当为先锋！",
  ["$steam__3designhaolie2"] = "翼德将军设伏，汝等插翅也难飞！",
  ["$steam__3designhaolie3"] = "汝等用兵，破绽百出！",
  ["$steam__3designhaolie4"] = "壮士断腕，死战以夺生路！",
  ["~steam__leitongwulan"] = "张郃，吾誓杀汝！蛮儿，汝敢！呃啊——",
} --雷铜吴兰

local shenglun = fk.CreateTriggerSkill{
  name = "steam__3design_shenglun",
  anim_type = "offensive",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and (player.phase == Player.Start or player.phase == Player.Finish)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local to = room:askForChoosePlayers(player, table.map(room:getAllPlayers(), Util.IdMapper), 1, 1,
    "steam__3design_shenglun-start", self.name, true)
    if #to > 0 then
    self.cost_data = {tos = to}
    return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if player.general == "steam__zerong" then
      player.general = "steam__zerong2"
      room:broadcastProperty(player, "general")
    elseif player.deputyGeneral == "steam__zerong" then
      player.deputyGeneral = "steam__zerong2"
      room:broadcastProperty(player, "deputyGeneral")
    end
    local first = room:getPlayerById(self.cost_data.tos[1])
    local targets = {first}
    local temp = first.next
    while temp ~= first do
      if not temp.dead then
        table.insert(targets, temp)
      end
      temp = temp.next
    end
    for _, target in ipairs(targets) do
      if not target.dead then
        local choices = {"draw1&turnover","cancel"}
        local choice = room:askForChoice(target, choices, self.name, nil, false, {"draw1&turnover","cancel"})
        if choice == "draw1&turnover" then
          target:drawCards(1, self.name)
          if not target.dead then
            target:turnOver()
          end
        end
      end
    end
  end,
}

zerong:addSkill(shenglun)

local sijie = fk.CreateTriggerSkill{
  name = "steam__3design_sijie",
  mute = true,
  anim_type = "offensive",
  events = {fk.TurnEnd, fk.RoundEnd},
  can_trigger = function(self, event, target, player, data)
    local room = player.room
    if player:hasSkill(self) then
      if event == fk.TurnEnd then
      return #room.logic:getEventsOfScope(GameEvent.MoveCards, 1, function (e)
        for _, move in ipairs(e.data) do
          if move.to == player.id and move.from ~= player.id 
          and (move.toArea == Card.PlayerHand or move.toArea == Card.PlayerEquip) then
            return true
          end
        end
      end, Player.HistoryTurn) > 0
      and #room.logic:getEventsOfScope(GameEvent.MoveCards, 1, function (e)
        for _, move in ipairs(e.data) do
          if move.from == player.id and move.to ~= player.id then
            for _, info in ipairs(move.moveInfo) do
              if info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip then
                return true
              end
            end
          end
        end
      end, Player.HistoryTurn) > 0
    elseif event == fk.RoundEnd then
      return #room.logic:getEventsOfScope(GameEvent.ChangeHp, 1, function(e)
        local damage = e.data[5]
        if damage and damage.from == player then
          return true
        end
        end, Player.HistoryRound) > 0
        and #room.logic:getEventsOfScope(GameEvent.ChangeHp, 1, function(e)
          local damage = e.data[5]
          if damage and damage.to == player then
            return true
          end
        end, Player.HistoryRound) > 0
      end
    end
  end,
  on_cost = function (self, event, target, player, data)
    if event == fk.TurnEnd then
    local success, dat = player.room:askForUseViewAsSkill(player, "steam__3design_sijie_viewas1", "#steam__3design_sijie_viewas1", true, {bypass_times = true})
    if success then
      self.cost_data = dat
      return true
    end
    elseif event == fk.RoundEnd then
    local success, dat = player.room:askForUseViewAsSkill(player, "steam__3design_sijie_viewas2", "#steam__3design_sijie_viewas2", true, {bypass_times = true})
    if success then
      self.cost_data = dat
      return true
    end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if player.general == "steam__zerong2" then
      player.general = "steam__zerong"
      room:broadcastProperty(player, "general")
    elseif player.deputyGeneral == "steam__zerong2" then
      player.deputyGeneral = "steam__zerong"
      room:broadcastProperty(player, "deputyGeneral")
    end
    if event == fk.TurnEnd then
    player:broadcastSkillInvoke(self.name, math.random(2))
    local dat = self.cost_data
    local card = Fk.skills["steam__3design_sijie_viewas1"]:viewAs(dat.cards)
    local use = {from = player.id, tos = table.map(dat.targets, function(p) return {p} end), card = card, extraUse = true}
    room:useCard(use)
    room:setPlayerMark(player, "sijie__tan", 1)
    if player:getMark("sijie__tan") > 0 and player:getMark("sijie__chen") > 0 then
      room:setPlayerMark(player, "@@sijie__chi", 1)
    end
  elseif event == fk.RoundEnd then
    player:broadcastSkillInvoke(self.name, math.random(3,4))
    local dat = self.cost_data
    local card = Fk.skills["steam__3design_sijie_viewas2"]:viewAs(dat.cards)
    local use = {from = player.id, tos = table.map(dat.targets, function(p) return {p} end), card = card, extraUse = true}
    room:useCard(use)
    room:setPlayerMark(player, "sijie__chen", 1)
    if player:getMark("sijie__tan") > 0 and player:getMark("sijie__chen") > 0 then
      room:setPlayerMark(player, "@@sijie__chi", 1)
    end
    end
  end,

  on_lose = function (self, player, is_death)
    local room = player.room
      room:setPlayerMark(player, "sijie__tan", 0)
      room:setPlayerMark(player, "sijie__chen", 0)
      room:setPlayerMark(player, "@@sijie__chi", 0)
  end,
}

local sijie_viewas1 = fk.CreateViewAsSkill{
  name = "steam__3design_sijie_viewas1",
  prompt = "#steam__3design_sijie_viewas1",
  card_num = 1,
  handly_pile = true,
  card_filter = function(self, to_select, selected)
    return #selected == 0
  end,
  view_as = function(self, cards)
    if #cards ~= 1 then return end
    local card = Fk:cloneCard("snatch")
    card:addSubcard(cards[1])
    card.skillName = "steam__3design_sijie"
    return card
  end,
}
local sijie_viewas2 = fk.CreateViewAsSkill{
  name = "steam__3design_sijie_viewas2",
  prompt = "#steam__3design_sijie_viewas2",
  interaction = function()
    local all_names = {}
    for _, id in ipairs (U.getAllCardNames("bt")) do
      if Fk:cloneCard(id).is_damage_card then
        table.insertIfNeed(all_names, id)
      end
    end
    if #all_names > 0 then
    return U.CardNameBox {
      choices = U.getViewAsCardNames(Self, "steam__3design_sijie", all_names),
      all_choices = all_names,
      default_choice = "AskForCardsChosen"
    }
    end
  end,
  card_num = 1,
  handly_pile = true,
  card_filter = function(self, to_select, selected)
    return #selected == 0
  end,
  view_as = function(self, cards)
    if #cards ~= 1 or Fk.all_card_types[self.interaction.data] == nil then return end
    local card = Fk:cloneCard(self.interaction.data)
    card:addSubcard(cards[1])
    card.skillName = "steam__3design_sijie"
    return card
  end,
}
local sijie__doom = fk.CreateProhibitSkill{
  name = "#steam__3design_sijie__doom",
  frequency = Skill.Compulsory,
  is_prohibited = function(self, from, to, card)
    return to:hasSkill(self) and from ~= to and to:getMark("@@sijie__chi") > 0 and
      card and table.contains({"peach"}, card.trueName)
  end,
}
sijie:addRelatedSkill(sijie__doom)
zerong:addSkill(sijie)
Fk:addSkill(sijie_viewas1)
Fk:addSkill(sijie_viewas2)

zerong2:addSkill("steam__3design_shenglun")
zerong2:addSkill("steam__3design_sijie")

AddWinAudio(zerong)
Fk:loadTranslationTable{
  ["steam__zerong"] = "笮融",
  ["#steam__zerong"] = "戮众渡我",
  ["cv:steam__zerong"] = "官方",
  ["illustrator:steam__zerong"] = "biou09",
  ["designer:steam__zerong"] = "不能更改",

  --以牢蝶的直觉来看，这俩以后可能重名
  ["steam__3design_shenglun"] = "生轮", 
  [":steam__3design_shenglun"] = "准备或结束阶段，你可以选择一名角色，自其开始，所有角色依次选择是否摸一张牌并翻面。",
  ["steam__3design_sijie"] = "死劫", 
  [":steam__3design_sijie"] = "①你既获得又失去过牌的回合结束时，你可以将一张牌当【顺手牵羊】使用。②你既造成又受到过伤害的轮次结束时，你可以将一张牌当任意伤害牌使用。"..
  "③若你前两项均执行过，其他角色不能对你使用【桃】。",

  ["steam__3design_shenglun-start"] = "生轮：请选择起点角色，或取消以不发动本技能。", 
  ["draw1&turnover"] = "摸一张牌并翻面", 
  ["steam__3design_sijie_viewas1"] = "死劫",
  ["steam__3design_sijie_viewas2"] = "死劫",
  ["#steam__3design_sijie_viewas1"] = "死劫：请将一张牌当【顺手牵羊】使用。",
  ["#steam__3design_sijie_viewas2"] = "死劫：请将一张牌当任意伤害类牌使用。",
  ["#steam__3design_sijie__doom"] = "死劫",
  ["@@sijie__chi"] = "死劫 加诸己身",

  ["steam__zerong2"] = "笮融",
  ["#steam__zerong2"] = "戮众渡我",
  ["cv:steam__zerong2"] = "官方",
  ["illustrator:steam__zerong2"] = "biou09",
  ["designer:steam__zerong2"] = "不能更改",

  ["$steam__3design_shenglun1"] = "世有因果，心存善念，处处皆极乐。",
  ["$steam__3design_shenglun2"] = "已断三千烦恼丝，不恋尘世黄白物。",
  ["$steam__3design_sijie1"] = "地狱生莲，罹魂做陷，邀君来沐弱水。",
  ["$steam__3design_sijie2"] = "心有欲壑，释迦难掩，何人不怀蛇蝎！",
  ["$steam__3design_sijie3"] = "屠刀剔来血肉盏，佛陀皆赴白骨宴！",
  ["$steam__3design_sijie4"] = "修罗捧琉璃，菩提生血，请君满饮此杯！",
  ["$steam__zerong_win_audio"] = "我佛慈悲，今日始得大自在。",
  ["~steam__zerong"] = "佛！你为何渡人不渡我！",
} --笮融

local hengjiang = fk.CreateTriggerSkill{
  name = "steam__3design_hengjiang",
  anim_type = "control",
  events = {fk.TurnStart},
  can_trigger = function(self, event, target, player, data)
    return target ~= player and player:hasSkill(self)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local n = player.hp
    local targets = {}
    for _, p in ipairs(room:getAlivePlayers()) do
      table.insert(targets, p.id)
    end
    local tos = room:askForChoosePlayers(player, targets, 1, n, "#steam__3design_hengjiang-cost", self.name, true)
    if #tos > 0 then
      self.cost_data = {tos = tos}
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    table.removeOne(self.cost_data.tos, player.id)
    room:doIndicate(player.id, self.cost_data.tos)
    room:setPlayerMark(target, "steam__3design_hengjiang_targets-turn", self.cost_data.tos)
    room:setPlayerMark(target, "steam__3design_hengjiang_tos-turn", player.id)
    room:setPlayerMark(target, "@steam__3design_hengjiang-turn", player.general)
  end,

  refresh_events = {fk.Damaged},
  can_refresh = function(self, event, target, player, data)
    return target == player
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    for _, p in ipairs(room:getAlivePlayers()) do
      local mark = p:getMark("steam__3design_hengjiang_tos-turn")
      if mark ~= 0 and mark == player.id then
        room:setPlayerMark(p, "steam__3design_hengjiang_targets-turn", 0)
        room:setPlayerMark(p, "steam__3design_hengjiang_tos-turn", 0)
        room:setPlayerMark(p, "@steam__3design_hengjiang-turn", 0)
      end
    end
  end,
}
local hengjiang_attackrange = fk.CreateAttackRangeSkill{
  name = "#steam__3design_hengjiang_attackrange",
  without_func = function (self, from, to)
    local mark = from:getMark("steam__3design_hengjiang_targets-turn")
    return mark ~= 0 and table.contains(mark, to.id)
  end,
  within_func = function (self, from, to)
    local mark = from:getMark("steam__3design_hengjiang_tos-turn")
    return mark ~= 0 and mark == to.id
  end,
}
hengjiang:addRelatedSkill(hengjiang_attackrange)
zangba:addSkill(hengjiang)

local judong = fk.CreateTriggerSkill{
  name = "steam__3design_judong",
  anim_type = "masochism",
  events = {fk.Damaged},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if player:isWounded() then
      room:recover({
        who = target,
        num = 1,
        recoverBy = player,
        skillName = self.name
      })
    end
    local skills = table.map(table.filter(player.player_skills, function (s)
      return s:isPlayerSkill(player) and s.visible
    end), Util.NameMapper)
    local skillToStr = function (list)
      return table.map(list, function (s)
        local skill = Fk.skills[s]
        if (skill.frequency == Skill.Limited or skill.frequency == Skill.Wake) and player:usedSkillTimes(s, Player.HistoryGame) > 0 then
          s = "SteamSkillInvoked:::"..s
        end
        return s
      end)
    end
    local returnSkill = function (list)
      return table.map(list, function (s)
        if s:startsWith("SteamSkillInvoked") then
          s = s:split(":::")[2]
        end
        return s
      end)
    end
    skills = skillToStr(skills)
    local tolose = {}
    tolose = room:askForChoices(player, skills, 1, 1, self.name, "#steam__3design_judong-lose", false)
    tolose = returnSkill(tolose)
    local mark = player:getTableMark("steam__3design_judong")
    table.insertTable(mark, tolose)
    player.room:setPlayerMark(player, "steam__3design_judong", mark)
    player.room:handleAddLoseSkills(player, "-"..table.concat(tolose, "|-"), nil, true, false)
  end,
}
local judong_delay = fk.CreateTriggerSkill{
  name = "#steam__3design_judong_delay",
  events = {fk.RoundEnd},
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return not player.dead and player:getMark("steam__3design_judong") ~= 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke("steam__3design_judong")
    room:notifySkillInvoked(player, "steam__3design_judong")
    local skills = player:getTableMark("steam__3design_judong")
    room:setPlayerMark(player, "steam__3design_judong", 0)
    room:handleAddLoseSkills(player, table.concat(skills, "|"), nil, true, false)
  end,
}
judong:addRelatedSkill(judong_delay)
zangba:addSkill(judong)

Fk:loadTranslationTable{
  ["steam__zangba"] = "臧霸",
  ["#steam__zangba"] = "节度青徐",
  ["cv:steam__zangba"] = "官方",
  ["illustrator:steam__zangba"] = "GH",
  ["designer:steam__zangba"] = "好孩子系我",

  ["steam__3design_hengjiang"] = "横江",
  [":steam__3design_hengjiang"] = "其他角色的回合开始时，你可以令X名角色视为在其攻击范围外，然后你视为在其攻击范围内，直至本回合结束或你受到伤害后。X为你的体力值。",
  ["steam__3design_judong"] = "踞东", 
  [":steam__3design_judong"] = "你受到伤害后，你可以回复1点体力，然后你失去一个技能直至本轮结束。",

  ["@steam__3design_hengjiang-turn"] = "横江-之内",
  ["#steam__3design_hengjiang-cost"] = "横江：是否选择任意名角色从当前回合角色的攻击范围内屏蔽？",
  ["#steam__3design_judong-lose"] = "踞东：请选择一个技能失去至本轮结束！",

  ["$steam__3design_hengjiang1"] = "今奉曹公之命，镇卫青徐二州！",
  ["$steam__3design_hengjiang2"] = "有吾在此，定保江表无虞！",
  ["$steam__3design_judong1"] = "霸起泰山，称雄东方！",
  ["$steam__3design_judong2"] = "乱贼何惧，霸自可御之！",
  ["~steam__zangba"] = "陛下若假臣以数万之兵，则可横扫二国，何故？唉……",
} --臧霸

Fk:loadTranslationTable{
  ["PlaceEquip"] = "（装备）置入装备区空栏",
  ["TrueDelay"] = "（延时锦囊）置入判定区",
  ["AsLe"] = "（红色非延时锦囊）当乐不思蜀使用",
  ["AsBing"] = "（黑色非延时锦囊）当兵粮寸断使用",
}

-- 这个宫本还不能写before use，因为会有使用装备牌手突然变长变短的情况！
local steam__ertianyiliu = fk.CreateActiveSkill{
  name = "steam__ertianyiliu",
  prompt = "#steam__ertianyiliu",
  card_num = 1,
  target_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0 --因为需要放牌后判断攻击范围，就不管杀的次数这种事了，搞不好放完有变也不一定
  end,
  interaction = function(self)
    local all_choices = {"PlaceEquip", "TrueDelay", "AsLe", "AsBing"} --装备/兵/乐/真延时
    return UI.ComboBox {choices = all_choices}
  end,
  card_filter = function(self, to_select, selected, player)
    if #selected == 0 and table.contains(player:getCardIds("h"), to_select) then
      local card = Fk:getCardById(to_select, true)
      if self.interaction.data == "PlaceEquip" then
        return card.type == Card.TypeEquip
    elseif self.interaction.data == "TrueDelay" then
        return card.sub_type == Card.SubtypeDelayedTrick
    elseif self.interaction.data == "AsLe" then
        return card.color == Card.Red and card.sub_type ~= Card.SubtypeDelayedTrick
    elseif self.interaction.data == "AsBing" then
        return card.color == Card.Black and card.sub_type ~= Card.SubtypeDelayedTrick
      end
    return true
    end
  end,
  target_filter = function(self, to_select, selected, selected_cards, extra_data, player)
    if #selected == 0 and #selected_cards == 1 then
      local card = Fk:getCardById(selected_cards[1], true)
      local target = Fk:currentRoom():getPlayerById(to_select)
      if to_select ~= Self.id then 
        return false
      else
        if self.interaction.data == "PlaceEquip" then
          return target:hasEmptyEquipSlot(card.sub_type)
        elseif self.interaction.data == "TrueDelay" then
          return not target:isProhibited(target, card)
        elseif self.interaction.data == "AsLe" then
          return not target:isProhibited(target, Fk:cloneCard("indulgence"))
        elseif self.interaction.data == "AsBing" then
          return not target:isProhibited(target, Fk:cloneCard("supply_shortage"))
        end
      return true
      end
    end
  end,
  on_use = function(self, room, effect)
    local target = room:getPlayerById(effect.tos[1])
    local player = room:getPlayerById(effect.from)
    local cards = effect.cards
    if self.interaction.data == "PlaceEquip" then
      room:moveCardTo(cards, Player.Equip, target, fk.ReasonJustMove, self.name, nil, true, effect.from)
    elseif self.interaction.data == "TrueDelay" then
      room:moveCardTo(cards, Player.Judge, target, fk.ReasonJustMove, self.name, nil, true, effect.from)
    elseif self.interaction.data == "AsLe" then
      local card = Fk:cloneCard("indulgence")
      card:addSubcard(cards[1])
      player:addVirtualEquip(card)
      room:moveCardTo(card, Player.Judge, target, fk.ReasonJustMove, self.name, nil, true, effect.from)
    elseif self.interaction.data == "AsBing" then
      local card = Fk:cloneCard("supply_shortage")
      card:addSubcard(cards[1])
      player:addVirtualEquip(card)
      room:moveCardTo(card, Player.Judge, target, fk.ReasonJustMove, self.name, nil, true, effect.from)
    end
    local active = {"PlaceEquip"}
    local color = Fk:getCardById(cards[1]).color
    if self.interaction.data ~= "PlaceEquip" and color == Card.Red then
      active = {"TrueDelay", "AsBing"}
    elseif self.interaction.data ~= "PlaceEquip" and color == Card.Black then
      active = {"TrueDelay", "AsLe"}
    end
    local slash = Fk:cloneCard("slash")
    slash.skillName = self.name
    local max_num = slash.skill:getMaxTargetNum(player, slash)
    local targets = {}
    for _, p in ipairs(room:getAllPlayers()) do
      if player:canUse(slash) and not player:isProhibited(p, slash) and player:inMyAttackRange(p) then
        table.insert(targets, p.id)
      end
    end
  if #targets > 0 then
    local tos = room:askForChoosePlayers(player, targets, 1, max_num, "#steam__ertianyiliu-slash", self.name, false)
    if #tos > 0 then
    local use = {
      from = player.id,
      card = slash,
      tos = table.map(tos, function(id) return {id} end),
      extraUse = false,
      extra_data = { ertianyi = active, nosame = color }  --置入区域，排除颜色
    }
    use.additionalDamage = (use.additionalDamage or 0) + 1
    room:useCard(use)
    end
  end
  end,
  feasible = function (self, selected, selected_cards)
    return #selected_cards == 1 and #selected == 1
  end,
}
local ertianyiliu__2 = fk.CreateActiveSkill{
  name = "ertianyiliu__2",
  card_num = 1,
  target_num = 1,
  interaction = function(self)
    local all_choices
    if self.all_choices_exclu ~= nil then
      all_choices = self.all_choices_exclu --在这一步增加同区域的判断
    else
      all_choices = {"PlaceEquip", "TrueDelay", "AsLe", "AsBing"} --装备/兵/乐/真延时
    end
    return UI.ComboBox {choices = all_choices}
  end,
  card_filter = function(self, to_select, selected, player)
    if #selected == 0 and table.contains(player:getCardIds("h"), to_select) then
      local card = Fk:getCardById(to_select, true)
      if self.nosame ~= nil and card.color == self.nosame then
        return false
    elseif self.interaction.data == "PlaceEquip" then
        return card.type == Card.TypeEquip
    elseif self.interaction.data == "TrueDelay" then
        return card.sub_type == Card.SubtypeDelayedTrick
    elseif self.interaction.data == "AsLe" then
        return card.color == Card.Red and card.sub_type ~= Card.SubtypeDelayedTrick
    elseif self.interaction.data == "AsBing" then
        return card.color == Card.Black and card.sub_type ~= Card.SubtypeDelayedTrick
      end
    return true
    end
  end,
  target_filter = function(self, to_select, selected, selected_cards, extra_data, player)
    if #selected == 0 and #selected_cards == 1 then
      local card = Fk:getCardById(selected_cards[1], true)
      local target = Fk:currentRoom():getPlayerById(to_select)
      if to_select ~= Self.id then 
        return false
      else
        if self.interaction.data == "PlaceEquip" then
          return target:hasEmptyEquipSlot(card.sub_type)
        elseif self.interaction.data == "TrueDelay" then
          return not target:isProhibited(target, card)
        elseif self.interaction.data == "AsLe" then
          return not target:isProhibited(target, Fk:cloneCard("indulgence"))
        elseif self.interaction.data == "AsBing" then
          return not target:isProhibited(target, Fk:cloneCard("supply_shortage"))
        end
      return true
      end
    end
  end,
  on_use = function(self, room, effect)
    local target = room:getPlayerById(effect.tos[1])
    local player = room:getPlayerById(effect.from)
    local cards = effect.cards
    if self.interaction.data == "PlaceEquip" then
      room:moveCardTo(cards, Player.Equip, target, fk.ReasonJustMove, self.name, nil, true, effect.from)
    elseif self.interaction.data == "TrueDelay" then
      room:moveCardTo(cards, Player.Judge, target, fk.ReasonJustMove, self.name, nil, true, effect.from)
    elseif self.interaction.data == "AsLe" then
      local card = Fk:cloneCard("indulgence")
      card:addSubcard(cards[1])
      player:addVirtualEquip(card)
      room:moveCardTo(card, Player.Judge, target, fk.ReasonJustMove, self.name, nil, true, effect.from)
    elseif self.interaction.data == "AsBing" then
      local card = Fk:cloneCard("supply_shortage")
      card:addSubcard(cards[1])
      player:addVirtualEquip(card)
      room:moveCardTo(card, Player.Judge, target, fk.ReasonJustMove, self.name, nil, true, effect.from)
    end
  end,
  feasible = function (self, selected, selected_cards)
    return #selected_cards == 1 and #selected == 1
  end,
}
local steam__ertianyiliu__trigger = fk.CreateTriggerSkill{
  name = "#steam__ertianyiliu__trigger",
  anim_type = "defensive",
  frequency = Skill.Compulsory,
  events = {fk.PreCardEffect},
  can_trigger = function(self, event, target, player, data)
    return data.to == player.id and
      data.card.trueName == "slash" and data.card.skillName == "steam__ertianyiliu" 
      and data.extra_data and data.extra_data.ertianyi and data.extra_data.nosame
      and not (data.unoffsetable or data.disresponsive or
      table.contains(data.unoffsetableList or {}, player.id) or
      table.contains(data.disresponsiveList or {}, player.id))
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    if data.extra_data and data.extra_data.ertianyi and data.extra_data.nosame then
    local success, dat = room:askForUseActiveSkill(player, "ertianyiliu__2",
      "#ertianyiliu__2-invoke", true, {all_choices_exclu = data.extra_data.ertianyi, nosame = data.extra_data.nosame})
      if success and dat then
        return true
      end
    end
    data.unoffsetableList = data.unoffsetableList or {}
    table.insert(data.unoffsetableList, player.id)
  end,


}
Fk:addSkill(ertianyiliu__2)
gongbenwuzang:addSkill(steam__ertianyiliu)
steam__ertianyiliu:addRelatedSkill(steam__ertianyiliu__trigger)
Fk:loadTranslationTable{
  ["steam__gongbenwuzang"] = "宫本武藏",
  ["#steam__gongbenwuzang"] = "剑道浪寻",
  ["cv:steam__gongbenwuzang"] = "王者荣耀",
  ["illustrator:steam__gongbenwuzang"] = "战国修罗魂",
  ["designer:steam__gongbenwuzang"] = "克己盖饭",

  ["steam__ertianyiliu"] = "二天一流",
  [":steam__ertianyiliu"] = "出牌阶段限一次，你可以将一张手牌置入自己场上，视为使用伤害值基数为2的【杀】（有距离次数限制），"..
  "且此【杀】的抵消方式改为目标角色向其的相应区域内置入一张颜色不同的手牌。<a href='steam__ertianyiliu_href'>注释</a>",
  ["steam__ertianyiliu_href"] = "出牌阶段限一次，你可以将一张手牌置入装备区或判定区，视为使用伤害值基数为2的【杀】（有距离次数限制），"..
  "且此【杀】的抵消方式改为目标角色向其的同名区域内置入一张颜色不同的手牌。一名角色以此法置入牌时，可选择将红色/黑色非延时锦囊牌当【乐不思蜀】/【兵粮寸断】置入判定区。",
  ["#steam__ertianyiliu"] = "二天一流：将一张手牌置入你的场上，视为使用【杀】（有距离次数限制但伤害基数为2），<br>抵消方式改为将颜色不同的一张手牌置入其的场上！",

  ["ertianyiliu__2"] = "二天一流",
  ["#steam__ertianyiliu-slash"] = "二天一流：请选择【杀】的目标！",
  ["#steam__ertianyiliu__trigger"] = "二天一流",
  ["#ertianyiliu__2-invoke"] = "二天一流：请将一张颜色不同的手牌置入自己的场上以抵消此【杀】，否则不可抵消！",

  ["$steam__ertianyiliu1"] = "是在下无敌了！",
  ["$steam__ertianyiliu2"] = "今日手感上佳。",
  ["$steam__ertianyiliu3"] = "以为自己有机会去守？又不是回合制游戏",
  ["$steam__ertianyiliu4"] = "太无敌而找不到对手，也是种无敌的忧桑",
  ["~steam__gongbenwuzang"] = "纳尼？",
} --宫本武藏

local steam__3design_xiangjian = fk.CreateTriggerSkill{
  name = "steam__3design_xiangjian",
  events = {fk.EventPhaseEnd},
  can_trigger = function(self, event, target, player, data)
    return target.phase == Player.Play and player:hasSkill(self)
  end,
  on_cost = function(self, event, target, player, data)
    local current = table.find(player.room.alive_players, function(p) return p.phase ~= Player.NotActive end)
    if current and current == player then
      return true
    else
      return player.room:askForSkillInvoke(player, self.name, nil, "#steam__3design_xiangjian-choose::"..target.id)
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local current = table.find(player.room.alive_players, function(p) return p.phase ~= Player.NotActive end)
    for _, p in ipairs(player.room:getOtherPlayers(target)) do
      if not p:isNude() and current then
        local suit = ""
        room.logic:getEventsOfScope(GameEvent.MoveCards, 999, function(e)
          for _, move in ipairs(e.data) do
            if move.toArea == Card.DiscardPile then
              for _, info in ipairs(move.moveInfo) do
                if Fk:getCardById(info.cardId, true).suit == Card.Heart then
                  suit = (suit ~= "" and suit..",heart") or suit.."heart"
                end
                if Fk:getCardById(info.cardId, true).suit == Card.Diamond then
                  suit = (suit ~= "" and suit..",diamond") or suit.."diamond"
                end
                if Fk:getCardById(info.cardId, true).suit == Card.NoSuit then
                  suit = (suit ~= "" and suit..",no_suit") or suit.."no_suit"
                end
                if Fk:getCardById(info.cardId, true).suit == Card.Spade then
                  suit = (suit ~= "" and suit..",spade") or suit.."spade"
                end
                if Fk:getCardById(info.cardId, true).suit == Card.Club then
                  suit = (suit ~= "" and suit..",club") or suit.."club"
                end
              end
            end
          end
        end, Player.HistoryTurn)
       local allsuit = ".|.|^("..suit..")"
       local card = room:askForDiscard(p, 1, 1, true, self.name, true, allsuit, "#steam__3design_xiangjian-discard")
        if #card > 0 and not target.dead then
          local choices = {"xiangjian-turnover","cancel"}
          local choice = room:askForChoice(p, choices, self.name, nil, false, {"xiangjian-turnover","cancel"})
          if choice == "xiangjian-turnover" then
            current:turnOver()
          end
        end
      end
    end
  end,
}
sunba:addSkill(steam__3design_xiangjian)
local steam__3design_chaoai = fk.CreateTriggerSkill{
  name = "steam__3design_chaoai",
  anim_type = "negative",
  events = {fk.Damaged},
  can_trigger = function(self, event, target, player, data)
    local lord = player.room:getLord()
    return player:hasSkill(self) and lord and target == lord
  end,
  on_cost = function(self, event, target, player, data)
    local current = table.find(player.room.alive_players, function(p) return p.phase ~= Player.NotActive end)
    if current and current == player then
      return true
    else
      return player.room:askForSkillInvoke(target, self.name, nil, "#steam__3design_chaoai-choose::"..player.id)
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = target.room
    --[[local skill = Fk.skills["efengqi__fangzhu"]
    skill.cost_data = {tos = {player.id}}
    room:useSkill(target, skill, function()
      return skill:use(event, target, player, data)
    end)]] --可以猜猜这么写会发生什么
    room:notifySkillInvoked(target, "efengqi__fangzhu", "masochism")
    target:broadcastSkillInvoke("efengqi__fangzhu")
    player:turnOver()
    if not player.dead and target:getLostHp() > 0 then
      player:drawCards(target:getLostHp(), "efengqi__fangzhu")
    end
  end,
}
sunba:addSkill(steam__3design_chaoai)
sunba:addRelatedSkill("efengqi__fangzhu")
Fk:loadTranslationTable{
  ["steam__sunba"] = "孙霸",
  ["#steam__sunba"] = "叔子狝束",
  ["cv:steam__sunba"] = "官方",
  ["illustrator:steam__sunba"] = "食茸",
  ["designer:steam__sunba"] = "易大剧",

  ["steam__3design_xiangjian"] = "相煎",
  [":steam__3design_xiangjian"] = "一名角色的出牌阶段结束时，你可令除其外的角色依次可弃置一张当前回合未进入过弃牌堆的花色的牌且可令当前回合角色翻面，若当前回合角色为你，则改为“你须令”。",
  ["steam__3design_chaoai"] = "朝哀", 
  [":steam__3design_chaoai"] = "当主公受到伤害后，其可对你发动“放逐”，若当前回合角色为你，则改为“其须对”。",

  ["#steam__3design_xiangjian-choose"] = "相煎：是否令%dest外的角色弃牌并可以将其翻面？",
  ["#steam__3design_xiangjian-discard"] = "相煎：是否一张当前回合未进入过弃牌堆的花色的牌且可令当前回合角色翻面？",
  ["xiangjian-turnover"] = "令当前回合角色翻面",
  ["#steam__3design_chaoai-choose"] = "朝哀：是否对%dest发动“放逐”？", 

  ["$steam__3design_xiangjian1"] = "我固君子，亦群亦党。",
  ["$steam__3design_xiangjian2"] = "众卿拥立，霸当仁不让。",
  ["$steam__3design_chaoai1"] = " ",
  ["$steam__3design_chaoai2"] = " ",
  ["~steam__sunba"] = "殿陛之争，非胜即死。",
} --孙霸

local steam__jinkaizhizeng = fk.CreateTriggerSkill{
  name = "steam__jinkaizhizeng",
  frequency = Skill.Compulsory,
  events = {fk.RoundStart, fk.RoundEnd, fk.DamageCaused, fk.DamageInflicted},
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(self) then return false end
    local available = false
    for i = 1, 3, 1 do
      if player:getMark("steam__jinkaizhizeng"..i.."-round") ~= "~" then
        available = true
      end
    end
    return event == fk.RoundStart or (event == fk.RoundEnd and player:getMark("@@steam__jinkaizhizeng_last-round") > 0)
    or ((event == fk.DamageCaused or event == fk.DamageInflicted) and target == player and player:usedSkillTimes(self.name, Player.HistoryRound) > 0 and available
    and not (data.extra_data and data.extra_data.jinkaizhizeng and table.contains(data.extra_data.jinkaizhizeng, player.id)))
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if event == fk.RoundStart then
      local choices = {"0", "1", "2"}
      for i = 1, 3, 1 do
        local choice = room:askForChoice(player, choices, self.name, "#steam__jinkaizhizeng-choice")
        if #choice > 0 then
          table.removeOne(choices, choice)
          room:setPlayerMark(player, "steam__jinkaizhizeng"..i.."-round", tonumber(choice))
        end
      end
      room:setPlayerMark(player, "@steam__jinkaizhizeng-round", string.format("%s %s %s",
      (player:getMark("steam__jinkaizhizeng1-round")), (player:getMark("steam__jinkaizhizeng2-round")), (player:getMark("steam__jinkaizhizeng3-round"))))
      if player:getMark("steam__jinkaizhizeng1-round") == 2 then
        player:drawCards(3, self.name)
        room:setPlayerMark(player, "@@steam__jinkaizhizeng_last-round", 1)
      end
    elseif event == fk.RoundEnd then
      player:gainAnExtraTurn(true)
    else
      for i = 1, 3, 1 do
        if player:getMark("steam__jinkaizhizeng"..i.."-round") ~= "~" then
          data.damage = player:getMark("steam__jinkaizhizeng"..i.."-round")
          room:setPlayerMark(player, "steam__jinkaizhizeng"..i.."-round", "~")
          data.extra_data = data.extra_data or {}
          data.extra_data.jinkaizhizeng = data.extra_data.jinkaizhizeng or {}
          table.insert(data.extra_data.jinkaizhizeng, player.id)
          break
        end
      end
      room:setPlayerMark(player, "@steam__jinkaizhizeng-round", string.format("%s %s %s",
      (player:getMark("steam__jinkaizhizeng1-round")), (player:getMark("steam__jinkaizhizeng2-round")), (player:getMark("steam__jinkaizhizeng3-round"))))
      if data.from:getMark("steam__zhanchezhixian-round") == player.id or data.to:getMark("steam__zhanchezhixian-round") == player.id then
        if not player.dead then --本意不会重复触发，在额外数据检测以后在这里也耦一个失去战车之陷~
        player.room:handleAddLoseSkills(player, "-steam__zhanchezhixian", nil, true, false)
        end
      end
    end
  end,

  refresh_events = {fk.TurnStart},
  can_refresh = function (self, event, target, player, data)
    return player:getMark("@@steam__jinkaizhizeng_last-round") > 0 and not player:insideExtraTurn() and target == player
  end,
  on_refresh = function (self, event, target, player, data)
    player.room.logic:getCurrentEvent():shutdown()
  end,
}
local steam__zhanchezhixian = fk.CreateTriggerSkill{
  name = "steam__zhanchezhixian",
  anim_type = "control",
  events = {fk.TurnStart},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) and player:usedSkillTimes(self.name, Player.HistoryRound) == 0 and target ~= player then
      for i = 1, 3, 1 do
        if player:getMark("steam__jinkaizhizeng"..i.."-round") ~= "~" then --排除已经结算的效果
          if player:getMark("steam__jinkaizhizeng"..i.."-round") == 2 then
            return true
          else
            return false
          end
        end
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    --[[local n = 0
    for i = 1, 3, 1 do
      if player:getMark("steam__jinkaizhizeng"..i.."-round") ~= "~" then
        if player:getMark("steam__jinkaizhizeng"..i.."-round") == 2 then
          n = i
          break
        end
      end
    end
    local x = #room.logic:getEventsOfScope(GameEvent.ChangeHp, 999, function(e)
      local damage = e.data[5]
      return damage and damage.to == target
    end, Player.HistoryRound)
    if x >= n then return false end
    room:setPlayerMark(target, "steam__zhanchezhixian-round", (n-x))
    room:setPlayerMark(target, "steam__zhanchezhixian_source-round", player.general)
    room:setPlayerMark(target, "@steam__zhanchezhixian-round", string.format("%s %s",
    (target:getMark("steam__zhanchezhixian-round")), (Fk:translate(target:getMark("steam__zhanchezhixian_source-round")))))]]
    room:setPlayerMark(target, "@steam__zhanchezhixian-round", player.general)
    room:setPlayerMark(target, "steam__zhanchezhixian-round", player.id)
  end,

  refresh_events = {fk.DamageCaused, fk.DamageInflicted},
  can_refresh = function (self, event, target, player, data)
    if target:getMark("steam__zhanchezhixian-round") == player.id and
    not (data.extra_data and data.extra_data.jinkaizhizeng and table.contains(data.extra_data.jinkaizhizeng, player.id)) then
      for i = 1, 3, 1 do
        if player:getMark("steam__jinkaizhizeng"..i.."-round") ~= "~" then
          return true
        end
      end
    end
  end,
  on_refresh = function (self, event, target, player, data)
    --[[player.room:removePlayerMark(target, "steam__zhanchezhixian-round", 1)
    player.room:setPlayerMark(target, "@steam__zhanchezhixian-round", string.format("%s %s",
    (target:getMark("steam__zhanchezhixian-round")), (Fk:translate(target:getMark("steam__zhanchezhixian_source-round")))))
    if target:getMark("steam__zhanchezhixian-round") == 0 then
      data.damage = 2
      player.room:setPlayerMark(target, "steam__zhanchezhixian-round", 0)
      if target:getMark("steam__zhanchezhixian_source-round") == player.general and
       (data.from == player or data.to == player) then
        player.room:setPlayerMark(target, "steam__zhanchezhixian_source-round", 0)
        player.room:setPlayerMark(target, "@steam__zhanchezhixian-round", 0)
        if not player.dead then
        player.room:handleAddLoseSkills(player, "-steam__zhanchezhixian", nil, true, false)
        end
      else
        player.room:setPlayerMark(target, "steam__zhanchezhixian_source-round", 0)
        player.room:setPlayerMark(target, "@steam__zhanchezhixian-round", 0)
      end
    end]]
    player.room:setPlayerMark(target, "steam__zhanchezhixian-round", 0)
    player.room:setPlayerMark(target, "@steam__zhanchezhixian-round", 0)
    for i = 1, 3, 1 do
      if player:getMark("steam__jinkaizhizeng"..i.."-round") ~= "~" then
        data.damage = player:getMark("steam__jinkaizhizeng"..i.."-round")
        player.room:setPlayerMark(player, "steam__jinkaizhizeng"..i.."-round", "~")
        data.extra_data = data.extra_data or {}
        data.extra_data.jinkaizhizeng = data.extra_data.jinkaizhizeng or {}
        table.insert(data.extra_data.jinkaizhizeng, player.id)
        break
      end
    end
    player.room:setPlayerMark(player, "@steam__jinkaizhizeng-round", string.format("%s %s %s",
    (player:getMark("steam__jinkaizhizeng1-round")), (player:getMark("steam__jinkaizhizeng2-round")), (player:getMark("steam__jinkaizhizeng3-round"))))
    if data.from == player or data.to == player then
      if not player.dead then
      player.room:handleAddLoseSkills(player, "-steam__zhanchezhixian", nil, true, false)
      end
    end
  end,
}
Karna:addSkill(steam__jinkaizhizeng)
Karna:addSkill(steam__zhanchezhixian)
Fk:loadTranslationTable{
  ["steam__Karna"] = "迦尔纳",
  ["#steam__Karna"] = "困泽之凰",
  ["cv:steam__Karna"] = "暂无",
  ["illustrator:steam__Karna"] = "未知",
  ["designer:steam__Karna"] = "abeeabee",

  ["steam__jinkaizhizeng"] = "金铠之赠",
  [":steam__jinkaizhizeng"] = "锁定技，轮次开始时，你将0、1、2分配给你此轮第一、二、三次造成或受到伤害的数值。若将2分配给第一次，摸三张牌，此轮最后执行回合。",
  ["steam__zhanchezhixian"] = "战车之陷", 
  [":steam__zhanchezhixian"] = "每轮限一次，其他角色的回合开始时，若你下一次“金铠之赠”数值将为2，可以令其本轮下次造成或受到的伤害也触发你的“金铠之赠”。若由彼此间造成的伤害触发，失去此技能。",

  ["@steam__jinkaizhizeng-round"] = "金铠",
  ["@@steam__jinkaizhizeng_last-round"] = "金铠 最后行动",
  ["#steam__jinkaizhizeng-choice"] = "金铠之赐：请依次选择你此轮第一、二、三次造成或受到伤害的数值！",
  ["@steam__zhanchezhixian-round"] = "车陷",
  ["$steam__jinkaizhizeng1"] = " ",
  ["$steam__jinkaizhizeng2"] = " ",
  ["$steam__zhanchezhixian1"] = " ",
  ["$steam__zhanchezhixian2"] = " ",
  ["~steam__Karna"] = " ",
} --迦尔纳

local steam__tiguo = fk.CreateTriggerSkill{
  name = "steam__tiguo",
  anim_type = "masochism",
  frequency = Skill.Compulsory,
  events = {fk.TurnEnd},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) then
      return player:getMark("steam__tiguo-turn") > 0
    end
  end,
  on_use = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "steam__tiguo-turn", 1)
    player:gainAnExtraTurn(true)
  end,

  refresh_events = {fk.EnterDying, fk.Death},
  can_refresh = function (self, event, target, player, data)
    if event == fk.EnterDying then
      return target == player and player:hasSkill(self, true) and table.contains(player:getTableMark("@steam__tiguo"), "英")
    else
      return (target.role == "rebel" and #table.filter(player.room.alive_players, function (p) return p.role == "rebel" end) == 0)
      or (target.role == "loyalist" and #table.filter(player.room.alive_players, function (p) return p.role == "loyalist" end) == 0)
      or #player.room.logic:getEventsOfScope(GameEvent.MoveCards, 1, function(e)
        for _, move in ipairs(e.data) do
          if move.toArea == Card.DiscardPile then
            for _, info in ipairs(move.moveInfo) do
              return Fk:getCardById(info.cardId, true).trueName == "peach"
            end
          end
        end
      end, Player.HistoryTurn) > 0
    end
  end,
  on_refresh = function (self, event, target, player, data)
    local room = player.room
    if event == fk.EnterDying then
      player.room:handleAddLoseSkills(player, "-steam__tengyin_yingzi", nil, true, false)
      player.room:removeTableMark(player, "@steam__tiguo", "英")
      player.room:setPlayerMark(player, "steam__tiguo-turn", 1)
    else
      if (target.role == "rebel" and #table.filter(player.room.alive_players, function (p) return p.role == "rebel" end) == 0)
      or (target.role == "loyalist" and #table.filter(player.room.alive_players, function (p) return p.role == "loyalist" end) == 0) then
        player.room:handleAddLoseSkills(player, "-steam__tengyin_shenxing", nil, true, false)
        player.room:removeTableMark(player, "@steam__tiguo", "慎")
        player.room:setPlayerMark(player, "steam__tiguo-turn", 1)
      end
      if #room.logic:getEventsOfScope(GameEvent.MoveCards, 1, function(e)
        for _, move in ipairs(e.data) do
          if move.toArea == Card.DiscardPile then
            for _, info in ipairs(move.moveInfo) do
              return Fk:getCardById(info.cardId, true).trueName == "peach"
            end
          end
        end
      end, Player.HistoryTurn) > 0 then
        player.room:handleAddLoseSkills(player, "-steam__tengyin_guzheng", nil, true, false)
        player.room:removeTableMark(player, "@steam__tiguo", "固")
        player.room:setPlayerMark(player, "steam__tiguo-turn", 1)
      end
    end
  end,

  on_acquire = function (self, player, is_start)
    player.room:setPlayerMark(player, "@steam__tiguo", {"英", "固", "慎"})
    player.room:handleAddLoseSkills(player, "steam__tengyin_yingzi", nil, true, false)
    player.room:handleAddLoseSkills(player, "steam__tengyin_guzheng", nil, true, false)
    player.room:handleAddLoseSkills(player, "steam__tengyin_shenxing", nil, true, false)
  end,

  on_lose = function (self, player, is_death)
    player.room:setPlayerMark(player, "@steam__tiguo", 0)
    player.room:handleAddLoseSkills(player, "-steam__tengyin_yingzi", nil, true, false)
    player.room:handleAddLoseSkills(player, "-steam__tengyin_guzheng", nil, true, false)
    player.room:handleAddLoseSkills(player, "-steam__tengyin_shenxing", nil, true, false)
  end,
}

local steam__tengyin_yingzi = fk.CreateTriggerSkill{
  name = "steam__tengyin_yingzi",
  anim_type = "drawcard",
  frequency = Skill.Compulsory,
  events = {fk.DrawNCards},
  on_use = function(self, event, target, player, data)
    data.n = data.n + 1
  end,
}
local steam__tengyin_yingzi_maxcards = fk.CreateMaxCardsSkill{
  name = "#steam__tengyin_yingzi_maxcards",
  main_skill = steam__tengyin_yingzi,
  fixed_func = function(self, player)
    if player:hasShownSkill(steam__tengyin_yingzi) then
      return player.maxHp
    end
  end
}
local steam__tengyin_guzheng = fk.CreateTriggerSkill{
  name = "steam__tengyin_guzheng",
  anim_type = "support",
  events = {fk.AfterCardsMove},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) and player:usedSkillTimes(self.name, Player.HistoryPhase) < 1 then
      local room = player.room
      local currentplayer = room.current
      if currentplayer and currentplayer.phase <= Player.Finish and currentplayer.phase >= Player.Start then
        local guzheng_pairs = {}
        for _, move in ipairs(data) do
          if move.moveReason == fk.ReasonDiscard and move.toArea == Card.DiscardPile and
          move.from ~= nil and move.from ~= player.id then
            local guzheng_value = guzheng_pairs[move.from] or {}
            for _, info in ipairs(move.moveInfo) do
              if info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip then
                table.insert(guzheng_value, info.cardId)
              end
            end
            guzheng_pairs[move.from] = guzheng_value
          end
        end
        local guzheng_data, ids = {{}, {}}, {}
        for key, value in pairs(guzheng_pairs) do
          if not room:getPlayerById(key).dead and #value > 1 then
            ids = U.moveCardsHoldingAreaCheck(room, table.filter(value, function (id)
              return room:getCardArea(id) == Card.DiscardPile
            end))
            if #ids > 0 then
              table.insert(guzheng_data[1], key)
              table.insert(guzheng_data[2], ids)
            end
          end
        end
        if #guzheng_data[1] > 0 then
          self.cost_data = guzheng_data
          return true
        end
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = self.cost_data[1]
    local card_pack = self.cost_data[2]
    if #targets == 1 then
      if room:askForSkillInvoke(player, self.name, nil, "#steam__tengyin_guzheng-invoke::"..targets[1]) then
        self.cost_data = {tos = targets, cards = card_pack[1]}
        return true
      end
    elseif #targets > 1 then
      local tos = room:askForChoosePlayers(player, targets, 1, 1, "#steam__tengyin_guzheng-choose", self.name)
      if #tos > 0 then
        self.cost_data = {tos = {tos[1]}, cards = card_pack[table.indexOf(targets, tos[1])]}
        return true
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local toId = self.cost_data.tos[1]
    room:doIndicate(player.id, {toId})
    local cards = self.cost_data.cards
    local to_return = table.random(cards, 1)
    local choice = "steam__tengyin_guzheng_no"
    if #cards > 1 then
      to_return, choice = U.askforChooseCardsAndChoice(player, cards, {"steam__tengyin_guzheng_yes", "steam__tengyin_guzheng_no"}, self.name,
      "#steam__tengyin_guzheng-title::" .. toId)
    end
    local moveInfos = {}
    table.insert(moveInfos, {
      ids = to_return,
      to = toId,
      toArea = Card.PlayerHand,
      moveReason = fk.ReasonJustMove,
      proposer = player.id,
      skillName = self.name,
    })
    table.removeOne(cards, to_return[1])
    if choice == "steam__tengyin_guzheng_yes" and #cards > 0 then
      table.insert(moveInfos, {
        ids = cards,
        to = player.id,
        toArea = Card.PlayerHand,
        moveReason = fk.ReasonJustMove,
        proposer = player.id,
        skillName = self.name,
      })
    end
    room:moveCards(table.unpack(moveInfos))
  end,
}
local steam__tengyin_shenxing = fk.CreateActiveSkill{
  name = "steam__tengyin_shenxing",
  anim_type = "drawcard",
  card_num = function(self)
    return math.min(2, Self:usedSkillTimes(self.name, Player.HistoryPhase))
  end,
  target_num = 0,
  prompt = function(self)
    local n = Self:usedSkillTimes(self.name, Player.HistoryPhase)
    if n == 0 then
      return "#steam__tengyin_shenxing-draw"
    else
      return "#steam__tengyin_shenxing:::"..math.min(2, n)
    end
  end,
  can_use = Util.TrueFunc,
  card_filter = function(self, to_select, selected)
    return #selected < math.min(2, Self:usedSkillTimes(self.name, Player.HistoryPhase)) and not Self:prohibitDiscard(Fk:getCardById(to_select))
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    room:throwCard(effect.cards, self.name, player, player)
    if not player.dead then
      player:drawCards(1, self.name)
    end
  end
}
tengyin:addSkill(steam__tiguo)
steam__tengyin_yingzi:addRelatedSkill(steam__tengyin_yingzi_maxcards)
tengyin:addRelatedSkill(steam__tengyin_yingzi)
tengyin:addRelatedSkill(steam__tengyin_guzheng)
tengyin:addRelatedSkill(steam__tengyin_shenxing)

Fk:loadTranslationTable{
  ["steam__tengyin"] = "滕胤",
  ["#steam__tengyin"] = "叶卷潮秋",
  ["cv:steam__tengyin"] = "官方",
  ["illustrator:steam__tengyin"] = "匪萌十月",
  ["designer:steam__tengyin"] = "狂风159",

  ["steam__tiguo"] = "体国",
  [":steam__tiguo"] = "锁定技，自你获得本技能起，下列一项时机：出现前，你视为拥有对应技能；首次出现的回合结束后，你进行一个额外回合："..
  "<br>你进入濒死状态时--“英姿”；<br>一名角色于一个有【桃】置入弃牌堆的回合内死亡时--“固政”；<br>最后的反贼或最后的忠臣死亡时--“慎行”。",

  ["@steam__tiguo"] = "体国",
  ["steam__tengyin_yingzi"] = "英姿",
  [":steam__tengyin_yingzi"] = "锁定技，摸牌阶段，你多摸一张牌；你的手牌上限等同于你的体力上限。",
  ["steam__tengyin_guzheng"] = "固政",
  [":steam__tengyin_guzheng"] = "每阶段限一次，当其他角色的至少两张牌因弃置而置入弃牌堆后，你可以令其获得其中一张牌，然后你可以获得剩余牌。",
  ["steam__tengyin_shenxing"] = "慎行",
  [":steam__tengyin_shenxing"] = "出牌阶段，你可以弃置X张牌，然后摸一张牌（X为你此阶段发动本技能次数，至多为2）。",

  ["#steam__tengyin_guzheng-invoke"] = "你可以发动固政，令%dest获得其此次弃置的牌中的一张，然后你获得剩余牌",
  ["#steam__tengyin_guzheng-choose"] = "你可以发动固政，令一名角色获得其此次弃置的牌中的一张，然后你获得剩余牌",
  ["#steam__tengyin_guzheng-title"] = "固政：选择一张牌还给 %dest",
  ["steam__tengyin_guzheng_yes"] = "确定，获得剩余牌",
  ["steam__tengyin_guzheng_no"] = "确定，不获得剩余牌",
  ["#steam__tengyin_shenxing-draw"] = "慎行：你可以摸一张牌",
  ["#steam__tengyin_shenxing"] = "慎行：你可以弃置%arg张牌，摸一张牌",

  ["$steam__tiguo1"] = "臣之所谏皆珠玑之言，陛下存疑可遣使观之",
  ["$steam__tiguo2"] = "书上所陈者乃胤耳听眼见，纵斗胆亦不敢妄言。",
  ["$steam__tengyin_yingzi"] = "面如玉，心无尘，如玉树秀于江左王庭。",
  ["$steam__tengyin_guzheng"] = "行无私，思唯国，似扶微之星居于北辰。",
  ["$steam__tengyin_shenxing"] = "国有其弊，上书当陈。",
  ["~steam__tengyin"] = "吴有覆巢之危，皆尔等所赐。",
} --滕胤

-- 三设10j


local sunwukong = General(extension, "steam3d__sunwukong", "god", 4)
Fk:loadTranslationTable{
  ["steam3d__sunwukong"] = "孙悟空",
  ["#steam3d__sunwukong"] = "心猿仍在",
  ["designer:steam3d__sunwukong"] = "zhengqunheng",
  ["~steam3d__sunwukong"] = "我若走了，谁来降妖...",
}

local yuyutianqi = fk.CreateTriggerSkill{
  name = "steam__yuyutianqi",
  mute = true,
  anim_type = "drawcard",
  events = {fk.EventPhaseChanging},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name)
    and table.contains({Player.Judge, Player.Draw, Player.Discard}, data.to)
  end,
  on_cost = function (self, event, target, player, data)
    return player.room:askForSkillInvoke(player, self.name, nil, "#steam__yuyutianqi-invoke:::"..(Util.PhaseStrMapper(data.to)))
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local n = 0
    room:notifySkillInvoked(player, self.name)
    room:sendLog{
      type = "#PhaseChanged",
      from = player.id,
      arg = Util.PhaseStrMapper(data.to),
      arg2 = "phase_play",
    }
    if data.to == Player.Judge then
      player:broadcastSkillInvoke(self.name, 1)
      for _, p in ipairs(room.alive_players) do
        n = math.max(n, p:getAttackRange())
      end
      if player:getAttackRange() >= n then
        player:drawCards(1, self.name)
      else
        room:setPlayerMark(player, "@steam__yuyutianqi_range", tostring(n))
      end
    elseif data.to == Player.Draw then
      player:broadcastSkillInvoke(self.name, 2)
      for _, p in ipairs(room.alive_players) do
        n = math.max(n, p:getMaxCards())
      end
      if player:getMaxCards() >= n then
        player:drawCards(1, self.name)
      else
        room:setPlayerMark(player, "@steam__yuyutianqi_maxcard", tostring(n))
      end
    elseif data.to == Player.Discard then
      player:broadcastSkillInvoke(self.name, 3)
      for _, p in ipairs(room.alive_players) do
        n = math.max(n, p:getLostHp())
      end
      if player:getLostHp() >= n then
        player:drawCards(1, self.name)
      else
        n = n - player:getLostHp()
        room:loseHp(player, n)
      end
    end
    data.to = Player.Play
  end,
}

local yuyutianqi_attackrange = fk.CreateAttackRangeSkill{
  name = "#steam__yuyutianqi_attackrange",
  fixed_func = function (self, player)
    local mark = player:getMark("@steam__yuyutianqi_range")
    if mark ~= 0 and tonumber(mark) then
      return tonumber(mark)
    end
  end,
}
yuyutianqi:addRelatedSkill(yuyutianqi_attackrange)

local yuyutianqi_maxcards = fk.CreateMaxCardsSkill{
  name = "#steam__yuyutianqi_maxcards",
  fixed_func = function(self, player)
    local mark = player:getMark("@steam__yuyutianqi_maxcard")
    if mark ~= 0 and tonumber(mark) then
      return tonumber(mark)
    end
  end
}
yuyutianqi:addRelatedSkill(yuyutianqi_maxcards)

sunwukong:addSkill(yuyutianqi)

Fk:loadTranslationTable{
  ["steam__yuyutianqi"] = "欲与天齐",
  [":steam__yuyutianqi"] = "你可将以下一个阶段改为出牌阶段执行，然后将对应数值调整至与全场最大相同：判定阶段，攻击范围；摸牌阶段，手牌上限；弃牌阶段，已损失体力值。若已为最大，你摸一张牌。",
  ["@steam__yuyutianqi_range"] = "攻击范围",
  ["@steam__yuyutianqi_maxcard"] = "手牌上限",
  ["#PhaseChanged"] = "%from 的 %arg 被改为了 %arg2",
  ["#steam__yuyutianqi-invoke"] = "欲与天齐：你可以将【%arg】改为【出牌阶段】执行",

  ["$steam__yuyutianqi1"] = "一个筋斗云，十万八千里！",
  ["$steam__yuyutianqi2"] = "俺老孙去去就来~",
  ["$steam__yuyutianqi3"] = "嘿嘿，你们几个打累了吧，该俺老孙耍耍了！",
}

local shibitiangao = fk.CreateActiveSkill{
  name = "steam__shibitiangao",
  anim_type = "support",
  mute = true,
  prompt = function (self)
    local player = Self---@type Player
    if player:getMark(self.name.."-phase") ~= 0 or not
    table.find(Fk:currentRoom().alive_players, function (p) return p:getHandcardNum() - player:getHandcardNum() == 1 end)
    and player:getMark(self.name.."-phase") == 0 then
      return "#steam__shibitiangao-less"
    end
    return "#steam__shibitiangao-more"
  end,
  card_num = 0,
  target_num = 1,
  can_use = Util.TrueFunc,
  card_filter = Util.FalseFunc,
  target_filter = function (self, to_select, selected, cards, _, _, player)
    if #selected > 0 then return end
    if table.find(Fk:currentRoom().alive_players, function (p) return p:getHandcardNum() - player:getHandcardNum() == 1 end)
    and player:getMark(self.name.."-phase") == 0 then
      return Fk:currentRoom():getPlayerById(to_select):getHandcardNum() - player:getHandcardNum() == 1
    else
      return player:getHandcardNum() - Fk:currentRoom():getPlayerById(to_select):getHandcardNum() == 1
    end
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    room:notifySkillInvoked(player, self.name)
    local pattern = ""
    if target:getHandcardNum() - player:getHandcardNum() == 1 then
      player:broadcastSkillInvoke(self.name, 1)
      pattern = "duel"
    elseif player:getHandcardNum() - target:getHandcardNum() == 1 then
      player:broadcastSkillInvoke(self.name, 2)
      room:addPlayerMark(player, self.name.."-phase")
      pattern = "peach"
    end
    U.swapHandCards(room, player, player, target, self.name)
    if target:isAlive() and player:isAlive() and player:usedSkillTimes(self.name, Player.HistoryPhase) > 1 then
      local card = Fk:cloneCard(pattern)
      if not target:prohibitUse(card) and not target:isProhibited(player, card) and
      room:askForSkillInvoke(target, self.name, nil, "#shibitiangao-use:"..player.id.."::"..pattern) then
        if pattern == "duel" then
          player:broadcastSkillInvoke(self.name, 3)
        else
          player:broadcastSkillInvoke(self.name, 4)
        end
        room:useVirtualCard(pattern, nil, target, player, self.name)
      end
    end
  end,
}

sunwukong:addSkill(shibitiangao)

Fk:loadTranslationTable{
  ["steam__shibitiangao"] = "试比天高",
  [":steam__shibitiangao"] = "出牌阶段，你可与手牌数比你多1的角色交换手牌。若为本阶段第二及更多次发动，对方可视为对你使用【决斗】。若没有符合条件的角色时，此阶段：“多”改为“少”，【决斗】改为【桃】。",
  ["#steam__shibitiangao"] = "你可以选择一名手牌数比你多1的角色，若没有则选择手牌数比你少1的角色",
  ["#steam__shibitiangao-use"] = "你可以视为对%src使用%arg",
  ["#steam__shibitiangao-more"] = "与手牌数比你多1的角色交换手牌，对方可视为对你使用【决斗】",
  ["#steam__shibitiangao-less"] = "与手牌数比你少1的角色交换手牌，对方可视为对你使用【桃】",

  ["$steam__shibitiangao1"] = "要大就大，要小就小，嘿嘿~",
  ["$steam__shibitiangao2"] = "妖怪，上次让你给溜了，这次你休想逃！",
  ["$steam__shibitiangao3"] = "妖精，看打！",
  ["$steam__shibitiangao4"] = "吃桃，吃桃，嘿嘿，吃桃了~",
}

--[[

local lucifer = General(extension, "steam3d__lucifer", "west", 4)

local fighttogetherSkill = fk.CreateActiveSkill{
  name = "role__fight_together_skill",
  prompt = "#role__fight_together_skill",
  can_use = Util.CanUse,
  min_target_num = 1,
  max_target_num = 3,
  mod_target_filter = Util.TrueFunc,
  target_filter = Util.TargetFilter,
  on_effect = function(_, room, cardEffectEvent)
    local to = room:getPlayerById(cardEffectEvent.to)
    local choices = {"lvshi__draw1"}
    if to:isWounded() then table.insertIfNeed(choices, "lvshi__heal") end
    local choice = room:askForChoice(to, choices, "role__fight_together", "", false, {"lvshi__heal","lvshi__draw1"})
    if choice == "lvshi__heal" then
      room:recover{who = to, num = 1, recoverBy = room:getPlayerById(cardEffectEvent.from), skillName = "role__fight_together"}
    else
      to:drawCards(1, "role__fight_together")
    end
    to:setChainState(true)
  end,
}

local fighttogether = fk.CreateTrickCard{
  name = "&role__fight_together",
  skill = fighttogetherSkill,
  multiple_targets = true,
  is_derived = true,
}

local enemyAtTheGatesSkill = fk.CreateActiveSkill{
  name = "fire__enemy_at_the_gates_skill",
  target_num = 1,
  target_filter = function(self, to_select, selected, _, _, _, player)
    return #selected == 0 and player.id ~= to_select
  end,
  on_effect = function(self, room, cardEffectEvent)
    local player = room:getPlayerById(cardEffectEvent.from)
    local to = room:getPlayerById(cardEffectEvent.to)
    local cards = {}
    for i = 1, 4, 1 do
      local id = room:getNCards(1)[1]
      table.insert(cards, id)
      room:moveCardTo(id, Card.Processing, nil, fk.ReasonJustMove, "fire__enemy_at_the_gates")
      local card = Fk:getCardById(id)
      if card.trueName == "slash" and not player:prohibitUse(card) and not player:isProhibited(to, card) and to:isAlive() then
        room:useVirtualCard("fire__slash", id, player, to, "fire__enemy_at_the_gates")
      end
    end
    cards = table.filter(cards, function(id) return room:getCardArea(id) == Card.Processing end)
    --room.logic:trigger(TT.ReviewToDiscardPile, player, {cards = cards})
    --cards = table.filter(cards, function(id) return room:getCardArea(id) == Card.Processing end)
    room:moveCardTo(cards, Card.DiscardPile, nil, fk.ReasonPutIntoDiscardPile, "fire__enemy_at_the_gates", nil, true, player.id)
  end,
}

local enemyAtTheGates = fk.CreateTrickCard{
  name = "&fire__enemy_at_the_gates",
  suit = Card.Heart,
  number = 6,
  skill = enemyAtTheGatesSkill,
  is_damage_card = true,
}

fighttogether.package = extension
enemyAtTheGates.package = extension
Fk:addSkill(fighttogetherSkill)
Fk:addCard(fighttogether)
Fk:addSkill(enemyAtTheGatesSkill)
Fk:addCard(enemyAtTheGates)

local sheizhangfangzhu = fk.CreateTriggerSkill{
  name = "sheizhangfangzhu",
  events = {fk.DamageCaused, fk.DamageInflicted},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and data.from
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askForSkillInvoke(data.from, self.name, nil, "#sheizhangfangzhu:"..data.to.id)
  end,
  on_use = function(self, event, target, player, data)
    local n = player:getLostHp()
    local all_choices = {"sheizhangfangzhu1:::"..n, "sheizhangfangzhu2:::"..n}
    local choice = player.room:askForChoice(data.to, all_choices, self.name)
    if choice == all_choices[1] then
      player.room:askForDiscard(data.to, n, n, true, self.name, false)
      player.room:loseHp(data.to, 1, self.name)
    else
      data.to:drawCards(n, self.name)
      data.to:turnOver()
    end
    return true
  end,
}

local sheideyonghu_active = fk.CreateViewAsSkill{
  name = "#sheideyonghu_active",
  card_num = 1,
  card_filter = Util.TrueFunc,
  view_as = function(self, cards)
    if #cards ~= 1 then return end
    local card = Fk:cloneCard("role__fight_together")
    card.skillName = "sheideyonghu"
    card:addSubcards(cards)
    return card
  end,
}

local sheideyonghu = fk.CreateTriggerSkill{
  name = "sheideyonghu",
  anim_type = "offensive",
  events = {fk.RoundStart},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self)
  end,
  on_cost = function (self, event, target, player, data)
    local _, dat = player.room:askForUseActiveSkill(player, "#sheideyonghu_active", "#sheideyonghu-choose", true)
    if dat then
      self.cost_data = {tos = dat.targets, cards = dat.cards}
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:useVirtualCard("role__fight_together", self.cost_data.cards, player, table.map(self.cost_data.tos, Util.Id2PlayerMapper), self.name)
    --未因此回复体力的角色可将一张牌置于牌堆顶
    local targets = table.map(self.cost_data.tos, Util.Id2PlayerMapper)
    targets = table.filter(targets, function (p) return p:getMark("sheideyonghu-recover") == 0 end)
    table.forEach(room.alive_players, function (p) return room:setPlayerMark(p, "sheideyonghu-recover", 0) end)
    local players = table.simpleClone(targets)
    table.removeOne(players, player)
    for _, p in ipairs(targets) do
      local cards = player.room:askForCard(p, 1, 1, true, self.name, true, ".", "#sheideyonghu-put")
      if #cards > 0 then
        room:moveCardTo(cards, Card.DrawPile, nil, fk.ReasonPut, self.name)
      else
        table.removeOne(players, p)
      end
    end
    local n = 0
    for _, p in ipairs(players) do
      n = math.max(n, p:getHandcardNum())
    end
    players = table.filter(players, function (p) return p:getHandcardNum() >= n end)
    local card = Fk:cloneCard("fire__enemy_at_the_gates")
    for _, p in ipairs(players) do
      if p:isAlive() and player:isAlive() and not target:prohibitUse(card) and not target:isProhibited(player, card) then
        room:useVirtualCard("fire__enemy_at_the_gates", nil, p, player, self.name)
      end
    end
  end,

  refresh_events = {fk.HpRecover},
  can_refresh = function(self, event, target, player, data)
    if player:hasSkill(self) then
      local e = player.room.logic:getCurrentEvent():findParent(GameEvent.CardEffect)
      return e and e.data[1].card and e.data[1].card.name == "role__fight_together" and e.data[1].card.skillName == self.name
    end
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:addPlayerMark(target, "sheideyonghu-recover")
  end,
}

Fk:addSkill(sheideyonghu_active)
lucifer:addSkill(sheizhangfangzhu)
lucifer:addSkill(sheideyonghu)

Fk:loadTranslationTable{
  ["steam3d__lucifer"] = "路西法",
  ["#steam3d__lucifer"] = "",
  ["designer:steam3d__lucifer"] = "我来天地正秋风",
  ["sheizhangfangzhu"] = "谁掌放逐",
  [":sheizhangfangzhu"] = "当你造成或受到伤害时，伤害来源可防止之并令受伤角色选择一项：1.弃置X张牌并失去1点体力；2.摸X张牌并翻面（X为你已损失的体力值）。",
  ["sheideyonghu"] = "谁得拥护",
  ["#sheideyonghu_active"] = "谁得拥护",
  [":sheideyonghu"] = "每轮开始时，你可将一张牌当<a href=':role__fight_together'>【勠力同心】</a>使用，此牌结算后，未因此回复体力的角色可依次将一张牌置于牌堆顶，然后其中手牌数最多的其他角色视为对你使用<a href=':fire__enemy_at_the_gates'>火【兵临城下】</a>。",
  ["#sheizhangfangzhu"] = "谁掌放逐：你可以防止对%src的此伤害",
  ["sheizhangfangzhu1"] = "弃置%arg张牌并失去1点体力",
  ["sheizhangfangzhu2"] = "摸%arg张牌并翻面",
  ["#sheideyonghu-choose"] = "你可以将一张牌当【勠力同心】使用",
  ["#sheideyonghu-put"] = "你可以将一张牌置于牌堆顶",

  ["role__fight_together"] = "【勠力同心】",
  [":role__fight_together"] = "锦囊牌<br/><b>时机</b>：出牌阶段<br/><b>目标</b>：一至三名角色<br/><b>效果</b>：目标角色各回复1点体力或摸一张牌，然后横置。",
  ["fire__enemy_at_the_gates"] = "火【兵临城下】",
  [":fire__enemy_at_the_gates"] = "锦囊牌<br/><b>时机</b>：出牌阶段<br/><b>目标</b>：一名其他角色<br/><b>效果</b>：你依次展示牌堆顶四张牌，若为【杀】，你将之当火【杀】对目标使用之；若不为【杀】，将此牌置入弃牌堆。",
}

local eve = General(extension, "steam3d__eve", "west", 3, 3, General.Female)

local wanwusheng = fk.CreateActiveSkill{
  name = "wanwusheng",
  anim_type = "support",
  attached_skill_name = "wanwusheng&",
  card_num = 0,
  target_num = 1,
  prompt = "#wanwusheng",
  max_phase_use_time = 1,
  card_filter = Util.FalseFunc,
  target_filter = function (self, to_select, selected, cards, _, _, player)
    return #selected == 0 and to_select ~= player.id and #ls.gethidecards(Fk:currentRoom():getPlayerById(to_select)) > 0
    and not player:isBuddy(Fk:currentRoom():getPlayerById(to_select))
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    local unvisible = table.random(ls.gethidecards(target))
    room:throwCard(unvisible, self.name, player)
    room:sendLog{
      type = "#wanwusheng-throw",
      from = effect.from,
      arg = Fk:getCardById(unvisible):getColorString(),
      toast = true,
    }
    if player.dead then return end
    local card_data = {}
    for _, p in ipairs(room.alive_players) do
      if p == target then
        table.insert(card_data, {target.general, target:getCardIds("hej")})
      else
        local cards = table.filter(p:getCardIds("hej"), function (id) return target:isBuddy(p) or
          not table.contains(ls.gethidecards(p), id) end)
        table.insert(card_data, {p.general, cards})
      end
    end
    if #card_data == 0 then return end
    local visible = room:askForCardChosen(target, target, { card_data = card_data }, self.name)
    local loseHp = room:getCardOwner(visible) ~= player
    room:throwCard(visible, self.name, player)
    if player.dead then return end
    local cards = {visible, unvisible}
    local pattern = "ex_nihilo"
    if Fk:getCardById(visible).color == Card.Red and Fk:getCardById(unvisible).color == Card.Red then
      pattern = "peach"
    elseif Fk:getCardById(visible).color == Card.Black and Fk:getCardById(unvisible).color == Card.Black then
      pattern = "slash"
    end
    U.askForUseVirtualCard(room, player, pattern, cards, self.name, nil, true, false, false, false)
    if player:isAlive() and loseHp then
      room:loseHp(player, 1, self.name)
    end
  end,

  on_acquire = function(self, player)
    for _, p in ipairs(Fk:currentRoom():getOtherPlayers(player)) do
      if not p:hasSkill("wanwusheng&") then
        Fk:currentRoom():handleAddLoseSkills(p, "wanwusheng&")
      end
    end
  end,
  on_lose = function(self, player)
    for _, p in ipairs(Fk:currentRoom().alive_players) do
      if p:hasSkill("wanwusheng&") then
        Fk:currentRoom():handleAddLoseSkills(p, "-wanwusheng&")
      end
    end
  end,
}

local wanwusheng_get = fk.CreateActiveSkill{
  name = "wanwusheng&",
  anim_type = "control",
  prompt = "#wanwushenga&",
  card_num = 0,
  target_num = 1,
  max_phase_use_time = 1,
  card_filter = Util.FalseFunc,
  target_filter = function (self, to_select, selected, cards, _, _, player)
    return #selected == 0 and to_select ~= player.id and Fk:currentRoom():getPlayerById(to_select):hasSkill("wanwusheng")
    and not table.contains(player:getTableMark("wanwusheng_targets-phase"), to_select)
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    local visible, unvisible
    local loseHp = false
    if player:getMark("shijinguo-phase") > 0 and #player:getCardIds("e") > 0 then
      unvisible = room:askForCard(player, 1, 1, true, self.name, false, ".|.|.|equip", "#shijinguo-equip")[1]
      room:throwCard(unvisible, self.name, player)
    else
      local targets = table.filter(room:getOtherPlayers(target), function (p) return #ls.gethidecards(p) > 0
      and not target:isBuddy(p) end)
      if #targets == 0 then return end
      local tos = room:askForChoosePlayers(target, table.map(targets, Util.IdMapper), 1, 1,
        "#wanwusheng-choose", self.name, false)
      unvisible = table.random(ls.gethidecards(room:getPlayerById(tos[1])))
      room:throwCard(unvisible, self.name, target)
    end
    room:sendLog{
      type = "#wanwusheng-throw",
      from = target.id,
      arg = Fk:getCardById(unvisible):getColorString(),
      toast = true,
    }
    if target.dead then return end
    if target:getMark("shijinguo-phase") > 0 then
      visible = room:getNCards(1)[1]
      room:moveCardTo(visible, Card.DiscardPile, nil, fk.ReasonDiscard, self.name)
    else
      local card_data = {}
      for _, p in ipairs(room.alive_players) do
        if p == target then
          table.insert(card_data, {target.general, target:getCardIds("hej")})
        else
          local cards = table.filter(p:getCardIds("hej"), function (id) return target:isBuddy(p) or
            not table.contains(ls.gethidecards(p), id) end)
          table.insert(card_data, {p.general, cards})
        end
      end
      if #card_data == 0 then return end
      visible = room:askForCardChosen(target, target, { card_data = card_data }, self.name)
      loseHp = room:getCardOwner(visible) ~= player
      room:throwCard(visible, self.name, target)
    end
    if target.dead then return end
    local pattern = "ex_nihilo"
    if Fk:getCardById(visible).color == Card.Red and Fk:getCardById(unvisible).color == Card.Red then
      pattern = "peach"
    elseif Fk:getCardById(visible).color == Card.Black and Fk:getCardById(unvisible).color == Card.Black then
      pattern = "slash"
    end
    U.askForUseVirtualCard(room, target, pattern, {visible, unvisible}, self.name, nil, true, false, false, false)
    if target:isAlive() and loseHp then
      room:loseHp(target, 1, self.name)
    end
  end,
}

local shijinguo = fk.CreateTriggerSkill{
  name = "shijinguo",
  events = {fk.SkillEffect, fk.AfterSkillEffect},
  can_trigger = function(self, event, target, player, data)
    if target ~= player and player:hasSkill(self) and data.name == "wanwusheng&" then
      return event == fk.SkillEffect or target:getMark("shijinguo-phase") > 0 or player:getMark("shijinguo-phase") > 0
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if event == fk.SkillEffect then
      local result = U.askForJointChoice({target, player}, {"execute", "notexecute"}, self.name, "弃置你装备区里一张牌代替不可见的牌；弃置牌堆顶牌代替可见的牌", true)
      if result[target.id] == "execute" and #target:getCardIds("e") > 0 then
        room:addPlayerMark(target, "shijinguo-phase")
      end
      if result[player.id] == "execute" then
        room:addPlayerMark(player, "shijinguo-phase")
      end
    else
      local players = table.filter(room.alive_players, function (p) return p:getMark("shijinguo-phase") > 0 end)
      for _, p in ipairs(players) do
        local cardstomove = {}
        if not p.dead then
          for _, sp in ipairs(room:getOtherPlayers(p)) do
            for _, id in ipairs(sp:getCardIds("ej")) do
              if p:canMoveCardIntoEquip(id, false) then
                table.insertIfNeed(cardstomove, id)
              end
            end
          end
        end
        if #cardstomove > 0 then
          local id = room:askForCardChosen(p, p, { card_data = {{self.name, cardstomove}}}, self.name, "#shijinguo-move")
          U.moveCardIntoEquip(room, p, id, self.name, false, p)
        end
      end
    end
  end,
}

Fk:addSkill(wanwusheng_get)
eve:addSkill(wanwusheng)
eve:addSkill(shijinguo)

Fk:loadTranslationTable{
  ["steam3d__eve"] = "夏娃",
  ["#steam3d__eve"] = "",
  ["designer:steam3d__eve"] = "159",
  ["wanwusheng"] = "万物生",
  [":wanwusheng"] = "每名角色的出牌阶段限一次，其可令你弃置一名角色对你不可见的一张牌，再弃置一名角色你可见的一张牌，然后你根据转化后的颜色将这两张牌当对应牌使用：黑色【杀】；红色【桃】；无色【无中生有】。若这些牌均不在你的区域内，你失去1点体力。",
  ["wanwusheng&"] = "万物生",
  [":wanwusheng&"] = "你可以令夏娃弃置其不可见和可见的牌各一张，然后其根据转化后的颜色将这两张牌当对应牌使用：黑色【杀】；红色【桃】；无色【无中生有】。若这些牌均不在其区域内，其失去1点体力",
  ["#wanwushenga&"] = "你可选择拥有【万物生】的角色，令其弃置其不可见和可见的牌各一张",
  ["#wanwusheng"] = "请选择一名角色，弃置其一张对你不可见的牌",
  ["#wanwusheng-choose"] = "请选择一名角色，弃置其一张对你不可见的牌",
  ["#wanwusheng-throw"] = "%from弃置的不可见牌为%arg",

  ["shijinguo"] = "食禁果",
  [":shijinguo"] = "其他角色发动“万物生”时，其与你同时选择是否执行：其可弃置其装备区内的一张牌代替你不可见的牌，你可弃置牌堆顶牌代替你可见的牌；然后此次“万物生”发动后，选择执行的角色移动场上一张牌到自己区域中。",
  ["execute"] = "执行",
  ["notexecute"] = "不执行",
  ["#shijinguo-equip"] = "食禁果：请选择装备区内的一张牌",
  ["#shijinguo-move"] = "选择场上一张牌移动到自己区域",
}
--]]

local luce = General(extension, "steam3d__luce", "west", 3, 3, General.Agender)
Fk:loadTranslationTable{
  ["steam3d__luce"] = "LUCE",
  ["#steam3d__luce"] = "",
  ["designer:steam3d__luce"] = "abeeabee",
}

local function isPrime(num)
  -- 小于2的数不是质数
  if num < 2 then return false end
  -- 2是最小的质数
  if num == 2 then return true end
  -- 偶数不是质数
  if num % 2 == 0 then return false end
  -- 只检查奇数因子
  for i = 3, math.sqrt(num), 2 do
    if num % i == 0 then
      return false
    end
  end
  return true
end

local function calculate_n(cards)
  -- 标准遍历顺序：黑桃、梅花、方片、红桃
  local color_order = { "spade", "club", "diamond", "heart" }
  local total = #cards  -- 总牌数（可能小于3）
  
  -- 统计各花色出现的次数
  local color_count = {}
  for _, color in ipairs(cards) do
      color_count[color] = (color_count[color] or 0) + 1
  end
  
  -- 核心逻辑：动态处理并记录跳过的花色
  local n, processed, skipped_colors = 0, 0, {}
  for _, color in ipairs(color_order) do
      if processed >= total then break end  -- 已处理完所有牌时终止
      
      local count = color_count[color] or 0
      if count > 0 then
          -- 处理该花色，但不超过剩余可处理数量
          local added = math.min(count, total - processed)
          processed = processed + added
      else
          -- 记录跳过的花色并累加n
          n = n + 2
          table.insert(skipped_colors, color)
      end
  end
  
  return n, skipped_colors
end

local chaoshengzhilu = fk.CreateActiveSkill{
  name = "chaoshengzhilu",
  prompt = "#chaoshengzhilu",
  anim_type = "drawcard",
  target_num = 0,
  card_num = 3,
  card_filter = function(self, to_select, selected, player)
    if #selected == 3 or Fk:currentRoom():getCardArea(to_select) ~= Card.PlayerHand
    or player:prohibitDiscard(to_select) then return false end
    local suits = {"spade", "club", "diamond", "heart"}
    local suit = Fk:getCardById(to_select):getSuitString()
    local cards = table.filter(player:getCardIds("h"),function (id) return not table.contains(selected, id) end)
    for _, s in ipairs(suits) do
      if table.find(cards, function (id) return Fk:getCardById(id):getSuitString() == s end) then
        return suit == s
      end
    end
  end,
  can_use = function(self, player)
    return isPrime(player:getHandcardNum()) and player:getHandcardNum() > 2
  end,
  on_use = function(self, room, effect)
    local from = room:getPlayerById(effect.from)
    local suits = table.map(effect.cards, function (id) return Fk:getCardById(id):getSuitString() end)
    room:throwCard(effect.cards, self.name, from)
    local more, skipped = calculate_n(suits)
    if more > 0 then
      room:drawCards(from, more, self.name)
      local mark = from:getTableMark("@chaoshengzhilu")
      if #mark < 4 then
        for _, suit in ipairs(skipped) do
          if not table.contains(mark, "log_"..suit) then
            table.insert(mark, "log_"..suit)
          end
        end
      end
      room:setPlayerMark(from, "@chaoshengzhilu", mark)
    end
  end
}
luce:addSkill(chaoshengzhilu)

Fk:loadTranslationTable{
  ["chaoshengzhilu"] = "朝圣之路",
  [":chaoshengzhilu"] = "出牌阶段，若你的手牌数为质数，可按花色从黑桃、梅花、方块到红桃的优先顺序弃置三张手牌。每跳过一种花色，你摸两张牌。",
  ["#chaoshengzhilu"] = "请从黑桃、梅花、方块到红桃的优先顺序弃置三张手牌",
  ["@chaoshengzhilu"] = "朝圣之路",
}

local guangzhisuoxiang = fk.CreateTriggerSkill{
  name = "guangzhisuoxiang",
  frequency = Skill.Limited,
  mute = true,
  events = {fk.EventPhaseStart, fk.TurnStart},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) and target == player then
      if event == fk.EventPhaseStart then
        return player.phase == Player.RoundStart and player:usedSkillTimes(self.name, Player.HistoryGame) == 0
      else
        return player:getMark("@$guangzhisuoxiang") ~= 0
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    if event == fk.EventPhaseStart then
      return player.room:askForSkillInvoke(player, self.name)
    else
      local card = Fk:getCardById(player:getMark("@$guangzhisuoxiang")[1])
      local tos = player.room:askForChoosePlayers(player, table.map(player.room.alive_players, Util.IdMapper), 1, 1,
        "#guangzhisuoxiang-choose:::"..card:toLogString(), self.name, true)
      if #tos > 0 then
        self.cost_data = tos[1]
        return true
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if event == fk.EventPhaseStart then
      room:notifySkillInvoked(player, self.name)
      local suits = {}
      local ids = {}
      while true do
        local id = room:getNCards(1)[1]
        local card = Fk:getCardById(id)
        room:moveCardTo(id, Card.Processing, nil, fk.ReasonJustMove, self.name)
        if card.suit == Card.Heart then
          if player.dead then
            table.insert(ids, id)
            break
          end
          room:obtainCard(player.id, id, true, fk.ReasonJustMove, player.id, self.name)
          if table.every(suits, function (suit) return table.contains(player:getTableMark("@chaoshengzhilu"), suit) end) then
            room:addTableMarkIfNeed(player, "@$guangzhisuoxiang", id)
            room:addCardMark(card, "@@guangzhisuoxiang")
          end
          break
        else
          table.insert(ids, id)
          table.insertIfNeed(suits, card:getSuitString(true))
        end
        room:delay(200)
      end
      room:cleanProcessingArea(ids, self.name)
    else
      room:obtainCard(self.cost_data, player:getMark("@$guangzhisuoxiang")[1], true, fk.ReasonJustMove)
    end
  end,
}
luce:addSkill(guangzhisuoxiang)

Fk:loadTranslationTable{
  ["guangzhisuoxiang"] = "光之所向",
  ["@$guangzhisuoxiang"] = "光之所向",
  ["@@guangzhisuoxiang"] = '<font color="#E4D00A">光之所向</b></font>',
  [":guangzhisuoxiang"] = "限定技，准备阶段，你可依次亮出牌堆顶牌直到亮出红桃牌，获得之。若在此牌之前出现的花色均曾被“朝圣之路”跳过，于你每回合开始时均可令一名角色获得此牌。",
  ["#guangzhisuoxiang-choose"] = "光之所向：你可令一名角色获得%arg",

  ["$guangzhisuoxiang1"] = "",
  ["$guangzhisuoxiang2"] = "",
}


















return extension
