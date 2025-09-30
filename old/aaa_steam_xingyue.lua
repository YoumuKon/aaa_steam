local extension = Package("aaa_steam_xingyue")
extension.extensionName = "aaa_steam"

local U = require "packages/utility/utility"
local RUtil = require "packages/aaa_fenghou/utility/rfenghou_util"
local DIY = require "packages/diy_utility/diy_utility"

Fk:loadTranslationTable{
  ["aaa_steam_xingyue"] = "星月赛！",
}

local function AddWinAudio(general)
  local Win = fk.CreateActiveSkill{ name = general.name.."_win_audio" }
  Win.package = extension
  Fk:addSkill(Win)
end

local godzhanghe = General:new(extension, "steam__godzhanghe", "god", 4)
for loop = 0, 50, 1 do  --50个应该够用
  local zhenmang = fk.CreateTriggerSkill{
    name = loop == 0 and "steam__zhenmang" or "steam"..loop.."__zhenmang",
    mute = true,
    frequency = Skill.Wake,
    events = {fk.TurnEnd},
    can_trigger = function(self, event, target, player, data)
      return player:hasSkill(self) and player:usedSkillTimes(self.name, Player.HistoryGame) == 0 and
        player.hp > 0 and player:getMark(self.name.."-turn") == 0  --防止因此获得技能时触发
    end,
    can_wake = function(self, event, target, player, data)
      return #player.room.logic:getActualDamageEvents(1, function (e)
        return e.data[1].damageType ~= fk.NormalDamage
      end, Player.HistoryTurn) > 0 or
      #player.room.logic:getEventsOfScope(GameEvent.Dying, 1, Util.TrueFunc,
        Player.HistoryTurn) > 0
    end,
    on_use = function(self, event, target, player, data)
      local room = player.room
      player:broadcastSkillInvoke("steam__zhenmang")
      room:notifySkillInvoked(player, "steam__zhenmang", "special")
      local all_choices, choices = {}, {}
      for i = 1, 2, 1 do
        table.insert(all_choices, "steam__zhenmang_choice"..i)
        if player.hp >= i then
          table.insert(choices, "steam__zhenmang_choice"..i)
        end
      end
      if #choices == 0 then return end
      local choice = room:askForChoice(player, choices, "steam__zhenmang", nil, false, all_choices)
      if choice == "steam__zhenmang_choice1" then
        for i = 1, 50, 1 do
          local name = "steam"..i.."__xuncang"
          if not player:hasSkill(name, true) then
            player:setSkillUseHistory(name, 0, Player.HistoryGame)
            room:handleAddLoseSkills(player, name, nil, true, false)
            break
          end
        end
      elseif choice == "steam__zhenmang_choice2" then
        local skills = {}
        for i = 1, 50, 1 do
          local name = "steam"..i.."__zhenmang"
          if not player:hasSkill(name, true) then
            player:setSkillUseHistory(name, 0, Player.HistoryGame)
            room:setPlayerMark(player, name.."-turn", 1)
            table.insert(skills, name)
          end
          if #skills == 2 then break end
        end
        room:handleAddLoseSkills(player, skills, nil, true, false)
      --elseif choice == "steam__zhenmang_choice3" then
        --player:drawCards(3, "steam__zhenmang")
      end
    end,
  }
  if loop > 0 then
    Fk:addSkill(zhenmang)
  else
    godzhanghe:addSkill(zhenmang)
  end
  Fk:loadTranslationTable{
    ["steam"..loop.."__zhenmang"] = "震莽",
    [":steam"..loop.."__zhenmang"] = "觉醒技，进行过属性伤害或濒死结算的回合结束时，你选择体力值不小于序号的一项："..
    "1.获得一个〖巽苍〗；2.获得两个〖震莽〗。",
  }

  local xuncang = fk.CreateActiveSkill{
    name = loop == 0 and "steam__xuncang" or "steam"..loop.."__xuncang",
    mute = true,
    frequency = Skill.Limited,
    prompt = function ()
      if Self:getMark("steam__xuncang-phase") == 0 then
        return "#steam__xuncang-any"
      else
        return "#steam__xuncang:::"..(Self:getMark("steam__xuncang-phase") - 1)
      end
    end,
    min_card_num = 1,
    max_card_num = function ()
      if Self:getMark("steam__xuncang-phase") == 0 then
        return 999
      else
        return Self:getMark("steam__xuncang-phase") - 1
      end
    end,
    target_num = 1,
    times = function (self)
      return 1 - Self:usedSkillTimes(self.name, Player.HistoryGame)
    end,
    can_use = function(self, player)
      return player:usedSkillTimes(self.name, Player.HistoryGame) == 0 and Self:getMark("steam__xuncang-phase") ~= 1
    end,
    card_filter = function(self, to_select, selected)
      return (Self:getMark("steam__xuncang-phase") == 0 or #selected < Self:getMark("steam__xuncang-phase") - 1) and
        not Self:prohibitDiscard(to_select)
    end,
    target_filter = function(self, to_select, selected, selected_cards)
      return #selected == 0
    end,
    on_use = function(self, room, effect)
      local player = room:getPlayerById(effect.from)
      local target = room:getPlayerById(effect.tos[1])
      player:broadcastSkillInvoke("steam__xuncang")
      room:notifySkillInvoked(player, "steam__xuncang", "offensive")
      room:setPlayerMark(player, "steam__xuncang-phase", #effect.cards)
      room:throwCard(effect.cards, self.name, player)
      if not target.dead then
        room:damage{
          from = player,
          to = target,
          damage = 1,
          damageType = fk.ThunderDamage,
          skillName = self.name,
        }
      end
    end,
  }
  if loop > 0 then
    Fk:addSkill(xuncang)
  else
    godzhanghe:addRelatedSkill(xuncang)
  end
  Fk:loadTranslationTable{
    ["steam"..loop.."__xuncang"] = "巽苍",
    [":steam"..loop.."__xuncang"] = "限定技，出牌阶段，你可以弃置至多X张牌（X本阶段上次弃置数-1），对一名角色造成1点雷电伤害。",
  }
end


local qiongyi = fk.CreateActiveSkill{
  name = "steam__qiongyi",
  card_num = 0,
  target_num = 0,
  prompt = function ()
    return "#steam__qiongyi:::"..Self:getMark("steam__qiongyi_times")
  end,
  card_filter = Util.FalseFunc,
  can_use = function(self, player)
    return #table.filter(player.player_skills, function (s)
      return s:isPlayerSkill(player) and s.visible
    end) >= player:getMark("steam__qiongyi_times")
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local skills = table.map(table.filter(player.player_skills, function (s)
      return s:isPlayerSkill(player) and s.visible
    end), Util.NameMapper)
    -- 为了避免删除未发动的技能，故做一下区分
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
    local min = player:getMark("steam__qiongyi_times")
    local tolose = {}
    if #skills <= min then
      tolose = table.simpleClone(skills)
    else
      tolose = room:askForChoices(player, skills, min, 999, self.name, "#steam__qiongyi-lose:::"..min, false)
    end
    tolose = returnSkill(tolose)
    room:setPlayerMark(player, "steam__qiongyi_times", #tolose + 1)
    if #tolose > 0 then
      room:handleAddLoseSkills(player, "-"..table.concat(tolose, "|-"))
    end
    if player.dead then return end
    room:changeMaxHp(player, 1)
    if player.dead then return end
    skills = table.map(table.filter(player.player_skills, function (s)
      return s:isPlayerSkill(player) and s.visible
    end), Util.NameMapper)
    skills = skillToStr(skills)
    if #skills > 0 then
      tolose = room:askForChoices(player, skills, 1, 1, self.name, "#steam__qiongyi-losetorecover", true)
      if #tolose > 0 then
        tolose = returnSkill(tolose)
        room:handleAddLoseSkills(player, "-"..tolose[1])
        room:recover { num = 1, skillName = self.name, who = player, recoverBy = player }
      end
    end
  end,
}

godzhanghe:addSkill(qiongyi)

--[[
local qiongyi = fk.CreateViewAsSkill{
  name = "steam__qiongyi",
  anim_type = "special",
  pattern = ".",
  prompt = function (self)
    if self.interaction.data then
      local card = Fk:cloneCard(self.interaction.data)
      if card.type == Card.TypeBasic then
        return "#steam__qiongyi-basic:::"..Self:getMark("@steam__qiongyi")[1]
      else
        return "#steam__qiongyi-trick:::"..Self:getMark("@steam__qiongyi")[2]
      end
    end
  end,
  interaction = function(self)
    local all_names = U.getAllCardNames("b")
    if #table.filter(Self.player_skills, function (s)
      return s:isPlayerSkill(Self) and s.visible
    end) >= Self:getMark("@steam__qiongyi")[2] then
      table.insertTable(all_names, U.getAllCardNames("t"))
    end
    local names = U.getViewAsCardNames(Self, self.name, all_names, {}, Self:getTableMark("@$steam__qiongyi"))
    if #names > 0 then
      return U.CardNameBox { choices = names, all_choices = all_names }
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
    room:addTableMark(player, "@$steam__qiongyi", use.card.trueName)
    local mark = player:getMark("@steam__qiongyi")
    local n = mark[1]
    if use.card:isCommonTrick() then
      n = mark[2]
    end
    if n > 0 then
      local skill_names = table.map(table.filter(player.player_skills, function (s)
        return s:isPlayerSkill(player) and s.visible
      end), function (s)
        return s.name
      end)
      local mapper = table.map(skill_names, function (name)
        if (name:startsWith("steam__zhenmang") or name:startsWith("steam__xuncang")) and
          player:usedSkillTimes(name, Player.HistoryGame) > 0 then
          return "√"
        else
          return ""
        end
      end)
      local choices = {}
      for i = 1, #skill_names, 1 do
        table.insert(choices, Util.TranslateMapper(skill_names[i])..mapper[i])
      end
      local choice = room:askForChoices(player, choices, n, n, self.name, "#steam__qiongyi-lose:::"..n, false)
      local skills = {}
      for _, c in ipairs(choice) do
        table.insert(skills, skill_names[table.indexOf(choices, c)])
      end
      room:handleAddLoseSkills(player, "-"..table.concat(skills, "|-"), nil, true, false)
    end
    for i = 1, 3, 1 do
      mark[i] = mark[i] + 1
    end
    room:setPlayerMark(player, "@steam__qiongyi", mark)
  end,
  enabled_at_play = function(self, player)
    return player:getMark("@steam__qiongyi") ~= 0 and
      #table.filter(player.player_skills, function (s)
        return s:isPlayerSkill(player) and s.visible
      end) >= player:getMark("@steam__qiongyi")[1]
  end,
  enabled_at_response = function(self, player, response)
    if Fk.currentResponsePattern == "nullification" then
      if table.contains(Self:getTableMark("@$steam__qiongyi"), "nullification") then return false end
    end
    return not response and player:getMark("@steam__qiongyi") ~= 0 and
      #table.filter(player.player_skills, function (s)
        return s:isPlayerSkill(player) and s.visible
      end) >= player:getMark("@steam__qiongyi")[1]
  end,
}
local qiongyi_trigger = fk.CreateTriggerSkill{
  name = "#steam__qiongyi_trigger",

  refresh_events = {fk.EventAcquireSkill, fk.EventLoseSkill},
  can_refresh = function(self, event, target, player, data)
    return target == player and data == qiongyi
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    if event == fk.EventAcquireSkill then
      room:setPlayerMark(player, "@steam__qiongyi", {0, 1, 2})
      room:handleAddLoseSkills(player, "steam__qiongyi_active&", nil, false, true)
    else
      room:setPlayerMark(player, "@steam__qiongyi", 0)
      room:setPlayerMark(player, "@$steam__qiongyi", 0)
      room:handleAddLoseSkills(player, "-steam__qiongyi_active&", nil, false, true)
    end
  end,
}
local qiongyi_active = fk.CreateActiveSkill{
  name = "steam__qiongyi_active&",
  anim_type = "support",
  card_num = 0,
  target_num = 0,
  prompt = function (self)
    return "#steam__qiongyi_active&:::"..Self:getMark("@steam__qiongyi")[3]
  end,
  can_use = function (self, player)
    return player:hasSkill(qiongyi) and player:getMark("@steam__qiongyi") ~= 0 and
      #table.filter(player.player_skills, function (s)
        return s:isPlayerSkill(player) and s.visible
      end) >= player:getMark("@steam__qiongyi")[3]
  end,
  card_filter = Util.FalseFunc,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    player:broadcastSkillInvoke("steam__qiongyi")
    local skill_names = table.map(table.filter(player.player_skills, function (s)
      return s:isPlayerSkill(player) and s.visible
    end), function (s)
      return s.name
    end)
    local mapper = table.map(skill_names, function (name)
      if (name:startsWith("steam__zhenmang") or name:startsWith("steam__xuncang")) and
        player:usedSkillTimes(name, Player.HistoryGame) > 0 then
        return "√"
      else
        return ""
      end
    end)
    local choices = {}
    for i = 1, #skill_names, 1 do
      table.insert(choices, Util.TranslateMapper(skill_names[i])..mapper[i])
    end
    local n = player:getMark("@steam__qiongyi")[3]
    local choice = room:askForChoices(player, choices, n, n, self.name, "#steam__qiongyi-lose:::"..n, false)
    local skills = {}
    for _, c in ipairs(choice) do
      table.insert(skills, skill_names[table.indexOf(choices, c)])
    end
    room:handleAddLoseSkills(player, "-"..table.concat(skills, "|-"), nil, true, false)
    room:setPlayerMark(player, "@steam__qiongyi", {0, 1, 2})
    room:setPlayerMark(player, "@$steam__qiongyi", 0)
    room:handleAddLoseSkills(player, "-"..table.concat(choice, "|-"), nil, true, false)
  end,
}
qiongyi:addRelatedSkill(qiongyi_trigger)
Fk:addSkill(qiongyi_active)
--]]
Fk:loadTranslationTable{
  ["steam__godzhanghe"] = "神张郃",
  ["#steam__godzhanghe"] = "不坠青云",
  ["designer:steam__godzhanghe"] = "末页",
  ["illustrator:steam__godzhanghe"] = "歪真人",
  ["cv:steam__godzhanghe"] = "末页",

  ["steam__zhenmang"] = "震莽",
  [":steam__zhenmang"] = "觉醒技，进行过属性伤害或濒死结算的回合结束时，你选择体力值不小于序号的一项：1.获得一个〖巽苍〗；"..
  "2.获得两个〖震莽〗。",
  ["steam__zhenmang_choice1"] = "获得一个〖巽苍〗",
  ["steam__zhenmang_choice2"] = "获得两个〖震莽〗",
  ["steam__zhenmang_choice3"] = "摸三张牌",

  ["steam__qiongyi"] = "穹异",
  [":steam__qiongyi"] = "出牌阶段，你可以失去任意个技能（至少0个，须比上一次多），加1点体力上限，你可以再失去一个以回复1点体力。",
  ["#steam__qiongyi"] = "穹异：失去至少%arg个技能，加1点体力上限",
  ["SteamSkillInvoked"] = "%arg(已发动)",
  ["#steam__qiongyi-lose"] = "穹异：请失去至少 %arg 个技能",
  ["#steam__qiongyi-losetorecover"] = "穹异：你可以再失去一个技能以回复1点体力",

  --[":steam__qiongyi"] = "你可以失去『0』/『1』个技能，视为使用一张未以此法使用过的基本牌/普通锦囊牌，令本技能的所有数字加一；出牌阶段，你可以失去『2』个技能，重置本技能的数字和记录。",
  --["#steam__qiongyi-basic"] = "穹异：你可以失去%arg个技能，视为使用一张基本牌！",
  --["#steam__qiongyi-trick"] = "穹异：你可以失去%arg个技能，视为使用一张普通锦囊牌！",
  --["#steam__qiongyi-lose"] = "穹异：请失去%arg个技能（“√”表示该技能已发动过）",
  --["steam__qiongyi_active&"] = "穹异[复原]",
  --[":steam__qiongyi_active&"] = "出牌阶段，你可以失去『2』个技能，重置“穹异”的数字和记录。",
  --["#steam__qiongyi_active&"] = "穹异：你可以失去%arg个技能，重置“穹异”的数字和记录！",
  --["@steam__qiongyi"] = "穹异",
  --["@$steam__qiongyi"] = "穹异",

  ["steam__xuncang"] = "巽苍",
  [":steam__xuncang"] = "限定技，出牌阶段，你可以弃置至多X张牌（X本阶段上次弃置数-1），对一名角色造成1点雷电伤害。",
  ["#steam__xuncang-any"] = "巽苍：你可以弃置任意张牌，对一名角色造成1点雷电伤害",
  ["#steam__xuncang"] = "巽苍：你可以弃置至多%arg张牌，对一名角色造成1点雷电伤害",

  ["$steam__zhenmang1"] = "授我斧钺，锡我彤弓，伐谋为兵，克胜群丑。",
  ["$steam__zhenmang2"] = "按剑则日中见斗，挥戈而曜灵再晡。",
  ["$steam__qiongyi1"] = "悬六合之休咎，着六军之成败。",
  ["$steam__qiongyi2"] = "玄穹彼苍，悉称上天；列缺飞廉，皆兆大横！",
  ["$steam__xuncang1"] = "挥云出塞、乘月渡河，旌旗指敌，荡寇清雠！",
  ["$steam__xuncang2"] = "苍雷注地飞紫星，龙子扰烟呼百灵。",
  ["~steam__godzhanghe"] = "授之者天，成之者运，岂徒人事？",
}

local godzhangxiu = General(extension, "steam__godzhangxiu", "god", 4, 4, General.Male) 

Fk:loadTranslationTable{
  ["steam__godzhangxiu"] = "神张绣", 
  ["#steam__godzhangxiu"] = "贯日白虹",
  ["cv:steam__godzhangxiu"] = "静谦",
  ["illustrator:steam__godzhangxiu"] = "歪道人",
  ["designer:steam__godzhangxiu"] = "静谦",

  ["~steam__godzhangxiu"] = "万般难留，念此生负人良多...",
}

local chefeng = fk.CreateTriggerSkill{
  name = "steam__chefeng",
  anim_type = "special",
  events = {fk.TargetSpecified},
  dynamic_desc = function(self, player)
    local mark = player:getTableMark("@steam__chefeng")
    local first = table.contains(mark, "①") and "1.令此牌额外结算一次" or "<font color=\"gray\">1.令此牌额外结算一次</font>"
    local second = table.contains(mark, "②") and "2.弃置目标角色各两张牌" or "<font color=\"gray\">2.弃置目标角色各两张牌</font>"
    local third = table.contains(mark, "③") and "3.摸三张牌" or "<font color=\"gray\">3.摸三张牌</font>"
    return "一张锦囊牌指定目标后，若你是使用者或目标，你可以选择并删去一项："..first.."；"..second.."；"..third.."。"..
   "然后你获得一个“流影”，且描述中的[]与{}分别为此锦囊牌的花色与本次删去的选项。"
  end,
  can_trigger = function(self, event, target, player, data)
    return data.card and data.card.type == Card.TypeTrick and player:hasSkill(self)
    and data.firstTarget and #AimGroup:getAllTargets(data.tos) > 0 and #player:getTableMark("@steam__chefeng") > 0
    and (target == player or table.contains(AimGroup:getAllTargets(data.tos), player.id))
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local choices = {}
    local mark = player:getTableMark("@steam__chefeng")
    for _, id in ipairs(mark) do
      table.insertIfNeed(choices, "steam__chefeng-deal"..id)
    end
    if #choices > 0 then
      local choice = room:askForChoice(player, choices, self.name)
      if choice == "steam__chefeng-deal①" then
        table.removeOne(mark, "①")
        player.room:setPlayerMark(player, "@steam__chefeng", #mark > 0 and mark or 0)
        if data.card:isCommonTrick() then
          data.additionalEffect = (data.additionalEffect or 0) + 1
        end
      elseif choice == "steam__chefeng-deal②" then
        table.removeOne(mark, "②")
        player.room:setPlayerMark(player, "@steam__chefeng", #mark > 0 and mark or 0)
        for _, id in ipairs(AimGroup:getAllTargets(data.tos)) do
          local to = room:getPlayerById(id)
          if not to.dead and not player.dead then
            local cards = room:askForCardsChosen(player, to, math.min(#to:getCardIds("he"), 2), 2, "he", self.name,
            "#steam__chefeng-discard::"..to.id)
            room:throwCard(cards, self.name, room:getPlayerById(id), player)
          end
        end
      elseif choice == "steam__chefeng-deal③" then
        table.removeOne(mark, "③")
        player.room:setPlayerMark(player, "@steam__chefeng", #mark > 0 and mark or 0)
        player:drawCards(3, self.name)
      end
      local banner = room:getBanner("steam__liuying_skills") or {}
      local name = "steam__liuying"
      local num
      for i = 1, 30, 1 do
        if banner["steam__liuying"..tostring(i)] == nil then
          name = "steam__liuying"..tostring(i)
          num = i
          break
        end
      end
     --[].复数个技能的序号 1.连招花色 2.连招效果（返回数字）3.连招技的拥有者（返回ID）4.限定技标签（1为限定技，2为无限定标签）
     local number
     if choice == "steam__chefeng-deal①" then
       number = 1
     elseif choice == "steam__chefeng-deal②" then
       number = 2
     elseif choice == "steam__chefeng-deal③" then
       number = 3
     end
      banner[name] = {
        data.card.suit,
        number,
        player.id,
        1
      }
      room:setBanner("steam__liuying_skills", banner)
      room:handleAddLoseSkills(player, name, nil, true, false)
      player.room:sendLog{
        type = "<font color=\"green\">"..Fk:translate(player.general, "zh_CN").."</font> 获得了序号为 "..num..
        " 的 “流影”， 连招花色为" ..Fk:translate(":steam__liuying_suits"..data.card.suit)..
        " 执行的效果为 "..Fk:translate(":steam__liuying_effects"..number).."",
        toast = true,
      }
    end
  end,

  on_acquire = function (self, player, is_start)
    player.room:setPlayerMark(player, "@steam__chefeng", {"①", "②", "③"})
  end,

  on_lose = function (self, player, is_death)
    player.room:setPlayerMark(player, "@steam__chefeng", 0)
  end,
}

godzhangxiu:addSkill(chefeng)
Fk:loadTranslationTable{
  ["steam__chefeng"] = "掣锋",
  [":steam__chefeng"] = "一张锦囊牌指定目标后，若你是使用者或目标，你可以选择并删去一项：1.令此牌额外结算一次；2.弃置目标角色各两张牌；3.摸三张牌。"..
  "然后你获得一个“流影”，且描述中的[]与{}分别为此锦囊牌的花色与本次删去的选项。",
  ["@steam__chefeng"] = "掣锋",
  ["steam__chefeng-deal①"] = "令此牌多结算一次",
  ["steam__chefeng-deal②"] = "弃置每名目标角色各两张牌",
  ["steam__chefeng-deal③"] = "摸三张牌",

  ["#steam__chefeng-discard"] = "流影：弃置 %dest 两张牌",

  ["$steam__chefeng1"] = "长缨抚雪锋芒毁，素手可裂风！",
  ["$steam__chefeng2"] = "舍我无明三昧血，尽染不净天！",
}

local tingjue = fk.CreateTriggerSkill{
  name = "steam__tingjue",
  anim_type = "special",
  frequency = Skill.Compulsory,
  events = {fk.AfterCardsMove},
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(self) then return false end
    for _, move in ipairs(data) do
      for _, info in ipairs(move.moveInfo) do
        if (move.to == player.id and move.toArea == Card.PlayerEquip)
        or (move.from == player.id and info.fromArea == Card.PlayerEquip) then
          return true
        end
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local mark = player:getTableMark("@steam__tingjue")
    for _, move in ipairs(data) do
      if move.to == player.id and move.toArea == Card.PlayerEquip then
        for _, info in ipairs(move.moveInfo) do
          table.insertIfNeed(mark, Fk:getCardById(info.cardId):getSuitString(true))
          for loop = 1, 30, 1 do 
            local name = "steam__liuying"..loop
            local infos = player.room:getBanner("steam__liuying_skills")
            if infos and infos[name] and Fk:getCardById(info.cardId).suit == infos[name][1] and infos[name][3] == player.id and infos[name][4] == 1 then
              player:setSkillUseHistory(name, 0, Player.HistoryGame)
              infos[name][4] = 2
              player.room:setBanner("steam__liuying_skills", infos)
              local redmark = player:getTableMark("@"..name.." X") 
              if #redmark > 0 then
                player.room:setPlayerMark(player, "@"..name, #redmark > 0 and redmark or 0) 
                player.room:setPlayerMark(player, "@"..name.." X", 0)
              end
              player.room:sendLog{
                type = "<font color=\"green\">"..Fk:translate(player.general, "zh_CN").."</font> 序号为 "..loop..
                " 的“流影” <font color=\"green\">删除了</font> <font color=\"red\">限定技</font> 标签",
                toast = true,
              }
            end
          end
        end
      elseif move.from == player.id then
        for _, info in ipairs(move.moveInfo) do
          if info.fromArea == Card.PlayerEquip then
          table.removeOne(mark, Fk:getCardById(info.cardId):getSuitString(true))
          for loop = 1, 30, 1 do 
            local name = "steam__liuying"..loop
            local infos = player.room:getBanner("steam__liuying_skills")
            if infos and infos[name] and Fk:getCardById(info.cardId).suit == infos[name][1] and infos[name][3] == player.id then 
              player.room:handleAddLoseSkills(player, "-"..name, nil, true, false)
              infos[name] = nil
              player.room:setBanner("steam__liuying_skills", infos)
            end
          end
          end
        end
      end
    end
    player.room:setPlayerMark(player, "@steam__tingjue", #mark > 0 and mark or 0)
  end,

  on_lose = function (self, player, is_death)
    player.room:setPlayerMark(player, "@steam__tingjue", 0)
  end,
}
godzhangxiu:addSkill(tingjue)
Fk:loadTranslationTable{
  ["steam__tingjue"] = "霆绝",
  [":steam__tingjue"] = "锁定技，装备牌置入你的场上后，连招条件含有此牌花色的“流影”删去“限定技”标签；装备牌离开你的场上后，删除连招条件含有此牌花色的“流影”。",
  ["@steam__tingjue"] = "霆绝",

  ["$steam__tingjue1"] = "金蛇千丈何人掣？锐士执之破残烟！",
  ["$steam__tingjue2"] = "舞回风，渡云气，天公助我搅层霄！",
}

--[[local liuying_record = fk.CreateTriggerSkill{ --备用方案，如果最后需要共用记牌器就喊出来
  name = "#steam__liuying_record",

  refresh_events = {fk.AfterCardUseDeclared},
  can_refresh = function (self, event, target, player, data)
    return target == player and player:hasSkill(self, true)
  end,
  on_refresh = function (self, event, target, player, data)
  local room = player.room
  local info = room:getBanner("steam__liuying_skills")[self.name]
  local mark = player:getTableMark("@steam__liuying")
    if #mark == 0 and info and info[1] == data.card.suit then
    room:setPlayerMark(player, "steam__liuying", data.card.suit)
    room:addTableMark(player, "@steam__liuying", data.card:getSuitString(true))
  elseif #mark == 1 then
      if data.card.trueName ~= "slash" then
      room:setPlayerMark(player, "steam__liuying", 0)
      room:setPlayerMark(player, "@steam__liuying", 0)
    else
      data.extra_data = data.extra_data or {}
      data.extra_data.combo_skill = data.extra_data.combo_skill or {}
      data.extra_data.combo_skill["steam__liuying"] = player:getMark("steam__liuying")
      room:setPlayerMark(player, "steam__liuying", 0)
      room:setPlayerMark(player, "@steam__liuying", 0)
    return
    end
  end
end,

  on_lose = function (self, player, is_death)
    local room = player.room
      room:setPlayerMark(player, "steam__liuying", 0)
      room:setPlayerMark(player, "@steam__liuying", 0)
  end,
}
Fk:addSkill(liuying_record) ]]

for loop = 1, 30, 1 do  --30个肯定够用，哪怕穷举翻倍也就刚好30
  local liuying = fk.CreateTriggerSkill{
    name = "steam__liuying"..loop,
    mute = true,
    anim_type = "special",
    frequency = Skill.Limited,
    events = {fk.TargetSpecified},
    times = function (self)
      local room = Fk:currentRoom()
      local info = room:getBanner("steam__liuying_skills")
      if info and info[self.name] and info[self.name][3] == Self.id and info[self.name][4] == 1 then 
        --[].复数个技能的序号 1.连招花色 2.连招效果（返回数字）3.连招技的拥有者（返回ID）4.限定技标签（1为限定技，2为无限定标签）
        return 1 - Self:usedSkillTimes(self.name, Player.HistoryGame)
      elseif info and info[self.name] and info[self.name][3] == Self.id and info[self.name][4] == 2 then
        return 1
      end
    end,
    can_trigger = function(self, event, target, player, data) --只能在额外数据判杀，因为谢玄会直接返回true
      if player:hasSkill(self) and target == player and data.card then
        local room = player.room
        local info = room:getBanner("steam__liuying_skills")[self.name]
          return info[1] ~= nil and target == player and data.card and
          data.extra_data and data.extra_data.combo_skill and data.extra_data.combo_skill[""..self.name]
          and (player:usedSkillTimes(self.name, Player.HistoryGame) == 0 or info[4] == 2)
      end
    end,
    on_cost = function(self, event, target, player, data)
      local room = player.room
      local info = room:getBanner("steam__liuying_skills")[self.name][2]
      local prompt = Fk:translate(":steam__liuying_effects"..info)
      return room:askForSkillInvoke(player, self.name, nil, "流影：是否发动序号为"..loop.."的“流影”？"..prompt)
    end,
    on_use = function(self, event, target, player, data)
      local room = player.room   
      player:broadcastSkillInvoke("steam__liuying1")
      if room:getBanner("steam__liuying_skills")[self.name][4] == 2 then
        room:notifySkillInvoked(player, "steam__liuying1", "offensive")
        player:setSkillUseHistory(self.name, 0, Player.HistoryGame)
      elseif room:getBanner("steam__liuying_skills")[self.name][4] == 1 then
        room:notifySkillInvoked(player, "steam__liuying1", "big") --有限定技标签的就播放限定特效，否则只播放进攻技能特效
      end
        player:addCardUseHistory("slash", -1)
      if room:getBanner("steam__liuying_skills")[self.name][2] ~= nil then
      switch(room:getBanner("steam__liuying_skills")[self.name][2], {
        [1] = function ()
          data.additionalEffect = (data.additionalEffect or 0) + 1
        end,
        [2] = function ()
          for _, id in ipairs(AimGroup:getAllTargets(data.tos)) do
            local to = room:getPlayerById(id)
            if not to.dead and not player.dead then
              local cards = room:askForCardsChosen(player, to, math.min(#to:getCardIds("he"), 2), 2, "he", self.name,
              "#steam__liuying-discard::"..to.id)
              room:throwCard(cards, self.name, room:getPlayerById(id), player)
            end
          end
        end,
        [3] = function ()
          player:drawCards(3, self.name)
        end,
      })
      end
    end,

    dynamic_desc = function(self, player)
      local banner = Fk:currentRoom():getBanner("steam__liuying_skills")
      if banner == nil then return self.name end
      local info = banner[self.name]
      --[].复数个技能的序号 1.连招花色 2.连招效果（返回数字）3.连招技的拥有者（返回ID）4.限定技标签（1为限定技，2为无限定标签）
      if info == nil then return self.name end
      if info ~= nil and info[4] == 1 and 1 - player:usedSkillTimes(self.name, Player.HistoryGame) > 0 then 
        return loop.." -- 连招技（["..Fk:translate(":steam__liuying_suits"..info[1]).."]牌+【杀】），限定技，此【杀】指定目标后，你可以令之不计入次数，"..
        "然后{"..Fk:translate(":steam__liuying_effects"..info[2]).."}。你失去此技能时将{}内效果还原为“掣锋”的选项，然后分配1点雷电伤害。"
      end
      if info ~= nil and info[4] == 1 and 1 - player:usedSkillTimes(self.name, Player.HistoryGame) <= 0 then 
        return loop.." -- 连招技（["..Fk:translate(":steam__liuying_suits"..info[1]).."]牌+【杀】），限定技，<font color=\"red\">（已发动）</font>，"..
        "此【杀】指定目标后，你可以令之不计入次数，然后{"..Fk:translate(":steam__liuying_effects"..info[2]).."}。你失去此技能时将{}内效果还原为“掣锋”的选项，然后分配1点雷电伤害。"
      end
      if info ~= nil and info[4] == 2 then 
        return loop.." -- 连招技（["..Fk:translate(":steam__liuying_suits"..info[1]).."]牌+【杀】），此【杀】指定目标后，你可以令之不计入次数，"..
         "然后{"..Fk:translate(":steam__liuying_effects"..info[2]).."}。你失去此技能时将{}内效果还原为“掣锋”的选项，然后分配1点雷电伤害。"
      end
    end,

    refresh_events = {fk.AfterCardUseDeclared}, --记牌器拆出来防止获得新连招后因为共享其他连招技的记牌器直接永动
    can_refresh = function (self, event, target, player, data)
      return target == player and player:hasSkill(self, true)
    end,
    on_refresh = function (self, event, target, player, data)
    local room = player.room
    local info = room:getBanner("steam__liuying_skills")[self.name]
    local mark = player:getMark(""..self.name) --花色类型匹配的才会触发连招记录，否则默认不记录或打断（检测次数这块用点别的办法吧）
      if mark == 0 and info and info[1] == data.card.suit then
      room:setPlayerMark(player, ""..self.name, data.card.suit)
        if player:usedSkillTimes(self.name, Player.HistoryGame) == 0 or info[4] == 2 then
        room:addTableMark(player, "@"..self.name, data.card:getSuitString(true))
      elseif player:usedSkillTimes(self.name, Player.HistoryGame) > 0 and info[4] ~= 2 then
        room:addTableMark(player, "@"..self.name.." X", data.card:getSuitString(true)) --标红表示已达次数上限
        end
    elseif mark ~= 0 then
        if data.card.trueName ~= "slash" or (player:usedSkillTimes(self.name, Player.HistoryGame) > 0 and info[4] ~= 2) then
        room:setPlayerMark(player, ""..self.name, 0)
        room:setPlayerMark(player, "@"..self.name, 0)
        room:setPlayerMark(player, "@"..self.name.." X", 0)
      else
        data.extra_data = data.extra_data or {}
        data.extra_data.combo_skill = data.extra_data.combo_skill or {}
        data.extra_data.combo_skill[""..self.name] = true --第一步已经在对应技能名判断过花色，直接返回true就行
        room:setPlayerMark(player, ""..self.name, 0)
        room:setPlayerMark(player, "@"..self.name, 0)
        room:setPlayerMark(player, "@"..self.name.." X", 0)
      return
      end
    end
  end,

  on_acquire = function (self, player, is_start)
    player:setSkillUseHistory(self.name, 0, Player.HistoryGame)
  end,
    
  on_lose = function (self, player, is_death)
    local room = player.room
    room:setPlayerMark(player, ""..self.name, 0)
    room:setPlayerMark(player, "@"..self.name, 0)
    player:setSkillUseHistory(self.name, 0, Player.HistoryGame)
    player:doNotify("LoseSkill", json.encode{ player.id, self.name, true }) --话说限定技的标记怎么刷新/删除，有没有像转换技使命技那种直接清零的方式？
    room:sendLog{
      type = "<font color=\"green\">"..Fk:translate(player.general, "zh_CN").."</font> 序号为 "..loop.." 的“流影” <font color=\"red\">被删除了</font>",
      toast = true,
    }
    local infos = player.room:getBanner("steam__liuying_skills")
    if player:hasSkill("steam__chefeng", true) then
    local mark = player:getTableMark("@steam__chefeng")
    if infos[self.name][2] == 1 then
      table.insertIfNeed(mark, "①")
      room:sendLog{
        type = "<font color=\"green\">"..Fk:translate(player.general, "zh_CN").."</font> 还原了 “掣锋” 的选项 <font color=\"green\">①</font>"..
        "<font color=\"red\">令此牌多结算一次</font>",
        toast = true,
      }
    elseif infos[self.name][2] == 2 then
      table.insertIfNeed(mark, "②")
      room:sendLog{
        type = "<font color=\"green\">"..Fk:translate(player.general, "zh_CN").."</font> 还原了 “掣锋” 的选项 <font color=\"green\">②</font>"..
        "<font color=\"red\">弃置每名目标角色各两张牌</font>",
        toast = true,
      }
    elseif infos[self.name][2] == 3 then
      table.insertIfNeed(mark, "③")
      room:sendLog{
        type = "<font color=\"green\">"..Fk:translate(player.general, "zh_CN").."</font> 还原了 “掣锋” 的选项 <font color=\"green\">③</font>"..
        "<font color=\"red\">摸三张牌</font>",
        toast = true,
      }
    end
    room:setPlayerMark(player, "@steam__chefeng", #mark > 0 and mark or 0)
    local new_mark = {} --还原选项后重新排序
    for _, choice in ipairs({"①", "②", "③"}) do
      if table.contains(mark, choice) then
        table.insert(new_mark, choice)
      end
    end
    room:setPlayerMark(player, "@steam__chefeng", #new_mark > 0 and new_mark or (#mark > 0 and mark or 0))
    end
      infos[self.name] = nil
      room:setBanner("steam__liuying_skills", infos)
    if not player.dead then
    local to = room:askForChoosePlayers(player, table.map(room:getAllPlayers(), Util.IdMapper), 1, 1,
    "#steam__liuying-damage", self.name, false)
      if #to > 0 then
        player:broadcastSkillInvoke("steam__liuying1")
      room:damage{
        from = player,
        to = room:getPlayerById(to[1]),
        damage = 1,
        damageType = fk.ThunderDamage,
        skillName = self.name,
      }
      end
    end
  end,
  }
  if loop > 1 then
    Fk:addSkill(liuying)
  elseif loop == 1 then
    godzhangxiu:addRelatedSkill(liuying)
  elseif loop < 1 or loop == nil then
    return false
  end
  Fk:loadTranslationTable{
    ["steam__liuying"..loop] = "流影", --呵呵，扶摇特供结算
    [":steam__liuying"..loop] = "连招技（[]牌+【杀】），限定技，此【杀】指定目标后，你可以令之不计入次数，然后{}。你失去此技能时将{}内效果还原为“掣锋”的选项，然后分配1点雷电伤害。",
    ["steam__liuying_effects"..loop] = "效果",
    ["@steam__liuying"..loop] = "流影 "..loop,
    ["@steam__liuying"..loop.." X"] = "<font color=\"red\">流影 "..loop.." X</font>",

    ["$steam__liuying"..loop.."1"] = "天河夜转，银浦流云，搬拦横扫漂回星！",
    ["$steam__liuying"..loop.."2"] = "草不谢荣，木不怨落，拭目重挥驻日戈！",
  }
end

Fk:loadTranslationTable{
  [":steam__liuying_suits1"] = "♠",
  [":steam__liuying_suits2"] = "♣",
  [":steam__liuying_suits3"] = "<font color='red'>♥</font>",
  [":steam__liuying_suits4"] = "<font color='red'>♦</font>",
  [":steam__liuying_suits5"] = "<font color='grey'>X</font>",

  [":steam__liuying_effects1"] = "令此【杀】多结算一次",
  [":steam__liuying_effects2"] = "弃置每名目标角色各两张牌",
  [":steam__liuying_effects3"] = "摸三张牌",
  ["#liuying_record"] = "流影",
  ["@steam__liuying"] = "流影",

  ["#steam__liuying-discard"] = "流影：弃置 %dest 两张牌",
  ["#steam__liuying-damage"] = "流影：请分配1点雷电伤害！",

  ["$steam__liuying1"] = "天河夜转，银浦流云，搬拦横扫漂回星！",
  ["$steam__liuying2"] = "草不谢荣，木不怨落，拭目重挥驻日戈！",

  ["$steam__liuying11"] = "天河夜转，银浦流云，搬拦横扫漂回星！",
  ["$steam__liuying12"] = "草不谢荣，木不怨落，拭目重挥驻日戈！",
}

local trump = General:new(extension, "steam__trump", "west", 4)

local zaidi = fk.CreateActiveSkill{
  name = "steam__zaidi",
  prompt = function ()
    return "#steam__zaidi:::"..Self:getMark("@steam__zaidi")
  end,
  anim_type = "offensive",
  card_num = 0,
  min_target_num = 1,
  card_filter = Util.FalseFunc,
  target_filter = function(self, to_select, selected)
    local to = Fk:currentRoom():getPlayerById(to_select)
    return #selected < Self:getMark("@steam__zaidi") and Self:canPindian(to)
  end,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local pd = U.jointPindian(player, table.map(effect.tos, Util.Id2PlayerMapper), self.name)
    local winner = pd.winner
    if winner then
      room:addPlayerMark(winner, "steam__zaidi_win-round")
    end
    local win, lose = 0, 0
    local myNum = pd.fromCard.number
    for _, result in pairs(pd.results) do
      if result.toCard then
        local num = result.toCard.number
        if num > myNum then
          lose = lose + 1
        elseif num < myNum then
          win = win + 1
        end
      end
    end
    if not player.dead then
      if lose > 0 then
        room:addPlayerMark(player, "@steam__zaidi", lose)
      end
      if win > 0 then
        player:drawCards(win, self.name)
      end
    end
  end,

  attached_skill_name = "steam__zaidi&",
  dynamic_desc = function (self, player, lang)
    if player:getMark("@steam__zaidi") > 1 then
      return "steam__zaidi_dyn:"..player:getMark("@steam__zaidi")
    end
    return self.name
  end,
  on_acquire = function (self, player, is_start)
    player.room:setPlayerMark(player, "@steam__zaidi", 1)
    Skill.onAcquire(self, player)
  end,
  on_lose = function (self, player)
    player.room:setPlayerMark(player, "@steam__zaidi", 0)
    Skill.onLose(self, player)
  end,
}

local steam__zaidi_trigger = fk.CreateTriggerSkill{
  name = "#steam__zaidi_trigger",
  events = {fk.RoundEnd},
  can_trigger = function (self, event, target, player, data)
    if player:hasSkill(zaidi) then
      local maxNum = 0
      for _, p in ipairs(player.room.alive_players) do
        maxNum = math.max(maxNum, p:getMark("steam__zaidi_win-round"))
      end
      if maxNum > 0 then
        local targets = table.map(table.filter(player.room.alive_players, function (p)
          return p:getMark("steam__zaidi_win-round") == maxNum
        end), Util.IdMapper)
        self.cost_data = {tos = targets}
        return true
      end
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    local room = player.room
    for _, winner in ipairs(table.map(self.cost_data.tos, Util.Id2PlayerMapper)) do
      if not winner.dead then
        local tos = room:askForChoosePlayers(winner, table.map(room.alive_players, Util.IdMapper), 1, 1,
        "#steam__zaidi-damage", zaidi.name, false)
        room:damage { from = winner, to = room:getPlayerById(tos[1]), damage = 1, skillName = zaidi.name }
      end
    end
  end,

  refresh_events = {fk.RoundStart},
  can_refresh = function(self, event, target, player, data)
    return player:hasSkill(zaidi, true)
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "@steam__zaidi", 1)
  end,
}
zaidi:addRelatedSkill(steam__zaidi_trigger)

trump:addSkill(zaidi)

local steam__zaidi_other = fk.CreateActiveSkill{
  name = "steam__zaidi&",
  prompt = function ()
    local max = 0
    for _, p in ipairs(Fk:currentRoom().alive_players) do
      max = math.max(max, p:getMark("@steam__zaidi"))
    end
    if max > 1 then
      return "#steam__zaidi-other-multi:::"..max
    end
    return "#steam__zaidi-other"
  end,
  anim_type = "offensive",
  card_num = 0,
  min_target_num = 1,
  card_filter = Util.FalseFunc,
  target_filter = function(self, to_select, selected)
    local to = Fk:currentRoom():getPlayerById(to_select)
    if not Self:canPindian(to) then return false end
    if #selected == 0 then
      return to:hasSkill(zaidi)
    else
      local first = Fk:currentRoom():getPlayerById(selected[1])
      local num = first:getMark("@steam__zaidi")
      return #selected < num
    end
  end,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local first = room:getPlayerById(effect.tos[1])
    first:broadcastSkillInvoke(zaidi.name)
    local pd = U.jointPindian(player, table.map(effect.tos, Util.Id2PlayerMapper), zaidi.name)
    local winner = pd.winner
    if winner then
      room:addPlayerMark(winner, "steam__zaidi_win-round")
    end
    local win, lose = 0, 0
    local hisNum = pd.results[first.id].toCard.number
    local myNum = pd.fromCard.number
    if myNum > hisNum then
      lose = 1
    elseif myNum < hisNum then
      win = 1
    end
    for pid, result in pairs(pd.results) do
      if result.toCard and pid ~= first.id then
        local num = result.toCard.number
        if num > hisNum then
          lose = lose + 1
        elseif num < hisNum then
          win = win + 1
        end
      end
    end
    if not first.dead then
      if lose > 0 then
        room:addPlayerMark(first, "@steam__zaidi", lose)
      end
      if win > 0 then
        first:drawCards(win, zaidi.name)
      end
    end
  end,
  dynamic_desc = function (self, player, lang)
    local max = 0
    for _, p in ipairs(Fk:currentRoom().alive_players) do
      max = math.max(max, p:getMark("@steam__zaidi"))
    end
    if max > 1 then
      return "steam__zaidi_other_dyn:"..max
    end
    return self.name
  end,
}
Fk:addSkill(steam__zaidi_other)

local yingji = fk.CreateTriggerSkill{
  name = "steam__yingji",
  frequency = Skill.Compulsory,
  events = {fk.BeforeCardsMove, fk.Damaged, fk.PindianFinished},
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(self) then return false end
    if event == fk.PindianFinished then
      return data.reason == "steam__zaidi" and data.winner == player
    end
    local mark = player:getMark(self.name)
    if mark == 0 then return false end
    if event == fk.BeforeCardsMove then
      for _, move in ipairs(data) do
        if move.from == player.id then
          if table.find(move.moveInfo, function(info)
            return info.fromArea == Card.PlayerHand and table.contains(mark, info.cardId) end)
          then
            return true
          end
        end
      end
    elseif target == player then
      return table.find(mark, function (id)
        return player.room:getCardArea(id) == Card.Void
      end)
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local mark = player:getMark(self.name)
    if event == fk.BeforeCardsMove then
      local ids = {}
      for _, move in ipairs(data) do
        if move.from == player.id then
          local move_info = {}
          for _, info in ipairs(move.moveInfo) do
            if info.fromArea == Card.PlayerHand and table.contains(mark, info.cardId) then
              table.insert(ids, info.cardId)
            else
              table.insert(move_info, info)
            end
          end
          move.moveInfo = move_info
        end
      end
      if #ids > 0 then
        table.insert(data, {
          moveInfo = table.map(ids, function (id) return {cardId = id, fromArea = Card.PlayerHand } end),
          from = player.id,
          toArea = Card.Void,
          skillName = self.name,
          moveReason = fk.ReasonJustMove,
          proposer = player.id,
          moveVisible = true,
        })
      end
    elseif event == fk.Damaged then
      local ids = table.filter(mark, function (id)
        return room:getCardArea(id) == Card.Void
      end)
      room:obtainCard(player, ids, true, fk.ReasonJustMove, player.id, self.name)
    else
      for _, p in ipairs(room:getOtherPlayers(player, false)) do
        room:setPlayerMark(p, "@steam__yingji", p:getMark("@steam__yingji") - 1)
        p:filterHandcards()
      end
    end
  end,

  refresh_events = {fk.GameStart},
  can_refresh = function (self, event, target, player, data)
    return player:hasSkill(self, true) and not player:isKongcheng()
  end,
  on_refresh = function (self, event, target, player, data)
    local maxNum = 0
    for _, id in ipairs(player.player_cards[Player.Hand]) do
      maxNum = math.max(maxNum, Fk:getCardById(id).number)
    end
    local ids = {}
    for _, id in ipairs(player.player_cards[Player.Hand]) do
      if Fk:getCardById(id).number == maxNum then
        table.insert(ids, id)
        player.room:setCardMark(Fk:getCardById(id), "@@steam__yingji_card", 1)
      end
    end
    player.room:setPlayerMark(player, self.name, ids)
  end,
}

local steam__yingji_filter = fk.CreateFilterSkill{
  name = "#steam__yingji_filter",
  mute = true,
  card_filter = function(self, card, player)
    return player:getMark("@steam__yingji") ~= 0 and table.contains(player.player_cards[Player.Hand], card.id)
  end,
  view_as = function(self, card, player)
    local c = Fk:cloneCard(card.name, card.suit, math.max(1, card.number + player:getMark("@steam__yingji")))
    c.skillName = yingji.name
    return c
  end,
}
yingji:addRelatedSkill(steam__yingji_filter)

trump:addSkill(yingji)

local ziyou = fk.CreateTriggerSkill{
  name = "steam__ziyou$",
  events = {fk.TurnStart},
  can_trigger = function (self, event, target, player, data)
    return target.kingdom == "west" and player:hasSkill(self)
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    player:chat(Fk:translate("steam__ziyou_chat"))
  end,

  refresh_events = {fk.StartPlayCard},
  can_refresh = function (self, event, target, player, data)
    return player:usedSkillTimes(self.name, Player.HistoryTurn) > 0
  end,
  on_refresh = function (self, event, target, player, data)
    player:chat(Fk:translate("steam__ziyou_chat"..math.random(10)))
  end,
}
trump:addSkill(ziyou)
AddWinAudio(trump)
Fk:loadTranslationTable{
  ["steam__trump"] = "特朗普", -- Donald Trump
  ["#steam__trump"] = "上帝的一票",
  ["designer:steam__trump"] = "yyuaN",
  ["illustrator:steam__trump"] = "",
  ["cv:steam__trump"] = "Donald Trump",

  ["steam__zaidi"] = "再缔",
  [":steam__zaidi"] = "每名角色的出牌阶段限一次，其可与至多[1]名角色共同拼点(拼点角色须含你)：每有一张拼点牌点数小于你的，你摸一张牌，每有一张点数大于你的，本轮[]内数字+1。每轮结束时，本轮以此法赢最多次的角色依次分配1点伤害。",
  [":steam__zaidi_dyn"] = "每名角色的出牌阶段限一次，其可与至多[{1}]名角色共同拼点(拼点角色须含你)：每有一张拼点牌点数小于你的，你摸一张牌，每有一张点数大于你的，本轮[]内数字+1。每轮结束时，本轮以此法赢最多次的角色依次分配1点伤害。",
  ["@steam__zaidi"] = "再缔",
  ["#steam__zaidi"] = "再缔：与至多 %arg 名角色共同拼点",
  ["#steam__zaidi-damage"] = "再缔：请分配1点伤害",
  ["#steam__zaidi-other"] = "再缔：你可以与特朗普拼点！",
  ["#steam__zaidi-other-multi"] = "再缔：你可以与包括特朗普在内%arg名角色共同拼点！",
  ["steam__zaidi&"] = "再缔",
  [":steam__zaidi&"] = "出牌阶段限一次，你可与包括特朗普在内至多[1]名角色共同拼点：每有一张拼点牌点数小于其的，其摸一张牌，每有一张点数大于其的，其的【再缔】本轮中[]内数字+1。",
  [":steam__zaidi_other_dyn"] = "出牌阶段限一次，你可与包括特朗普在内至多[{1}]名角色共同拼点：每有一张拼点牌点数小于其的，其摸一张牌，每有一张点数大于其的，其的【再缔】本轮中[]内数字+1。",
  ["#steam__zaidi_trigger"] = "再缔",

  ["steam__yingji"] = "鹰击",
  [":steam__yingji"] = "你点数最大的起始手牌于失去时移出游戏，并于你受到伤害后加入你的手牌。你因〖再缔〗拼点成为赢者后，令其他角色手牌点数永久-1（至少为1）",
  ["#steam__yingji_filter"] = "鹰击",
  ["@steam__yingji"] = "鹰击",
  ["@@steam__yingji_card"] = "鹰击",

  ["steam__ziyou"] = "自由",
  [":steam__ziyou"] = "主公技，西势力角色的回合内，你可以嘴牌！",
  ["steam__ziyou_chat"] = "本回合中，我将嘴牌！",
  ["steam__ziyou_chat1"] = "我有闪，杀我！",
  ["steam__ziyou_chat2"] = "二号位手里有连弩和桃",
  ["steam__ziyou_chat3"] = "我有桃，随便卖血",
  ["steam__ziyou_chat4"] = "先打三号位，他明反",
  ["steam__ziyou_chat5"] = "留小点给我拼点",
  ["steam__ziyou_chat6"] = "是忠臣就别闪",
  ["steam__ziyou_chat7"] = "怎么不选个李昭仪之类的强力忠臣",
  ["steam__ziyou_chat8"] = "你这么打你是民主党吗？",
  ["steam__ziyou_chat9"] = "给我桃，事成之后封你为能源部长",
  ["steam__ziyou_chat10"] = "早知道选王淩了",

  ["$steam__zaidi1"] = "Together, we will Make America Great Again.",
  ["$steam__zaidi2"] = "We will bring back our jobs, we will bring back our bordors, we will bring back our wealth, and we will bring back our dreams.",
  ["$steam__yingji1"] = "In order to fulfill my solemn duty to protect America and its citizens, the United States will withdraw.",
  ["$steam__yingji2"] = "Stay forward is going to be only America first, America first.",
  ["$steam__ziyou1"] = "I will fight for you with every breath in my body, and I will never ever let you down.",
  ["$steam__ziyou2"] = "As the day the people became the rulers of this nation again.",
  ["$steam__trump_win_audio"] = "God bless you, and God bless America!",
}



local jiangwei = General:new(extension, "steam__jiangwei", "han", 4)
local qingbei = fk.CreateTriggerSkill{
  name = "steam__qingbei",
  anim_type = "special",
  events = {fk.EventPhaseChanging},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and table.contains({3, 4, 6}, data.to)
  end,
  on_cost = function (self, event, target, player, data)
    return player.room:askForSkillInvoke(player, self.name, nil, "#steam__qingbei"..data.to.."-invoke")
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:addTableMark(player, self.name, data.to)
    if data.to == 3 then
      room:addTableMark(player, "@steam__qingbei", "判")
      if not player.chained then
        player:setChainState(true)
      end
    elseif data.to == 4 then
      room:addTableMark(player, "@steam__qingbei", "摸")
      player:drawCards(6, self.name)
    elseif data.to == 6 then
      room:addTableMark(player, "@steam__qingbei", "弃")
      if not player:isKongcheng() then
        DIY.ShowCards(player, player:getCardIds("h"))
      end
    end
    data.to = Player.Play
  end,

  refresh_events = {fk.EventPhaseChanging, fk.Deathed},
  can_refresh = function(self, event, target, player, data)
    if event == fk.EventPhaseChanging then
      return target == player and table.contains(player:getTableMark(self.name), data.to)
    elseif event == fk.Deathed then
      return player:getMark(self.name) ~= 0 and data.damage and data.damage.from and data.damage.from == player
    end
  end,
  on_refresh = function(self, event, target, player, data)
    if event == fk.EventPhaseChanging then
      data.to = Player.Play
    elseif event == fk.Deathed then
      local room = player.room
      room:setPlayerMark(player, self.name, 0)
      room:setPlayerMark(player, "@steam__qingbei", 0)
    end
  end,
}
local ranji = fk.CreateTriggerSkill{
  name = "steam__ranji",
  anim_type = "drawcard",
  events = {fk.HpChanged, fk.MaxHpChanged, fk.AfterCardsMove},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) and player:getHandcardNum() < player.hp then
      if event == fk.AfterCardsMove then
        for _, move in ipairs(data) do
          if move.from == player.id then
            for _, info in ipairs(move.moveInfo) do
              if info.fromArea == Card.PlayerHand then
                return true
              end
            end
          end
        end
      else
        return target == player
      end
    end
  end,
  on_cost = function (self, event, target, player, data)
    return player.phase == Player.Play or player.room:askForSkillInvoke(player, self.name, nil, "#steam__ranji-invoke")
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(2, self.name)
    if not player.dead then
      player.room:loseHp(player, 1, self.name)
    end
  end,
}
jiangwei:addSkill(qingbei)
jiangwei:addSkill(ranji)
Fk:loadTranslationTable{
  ["steam__jiangwei"] = "姜维",
  ["#steam__jiangwei"] = "护国麒麟",
  ["illustrator:steam__jiangwei"] = "depp",
  ["designer:steam__jiangwei"] = "志文",

  ["steam__qingbei"] = "倾北",
  [":steam__qingbei"] = "你的一个主要阶段开始前，你可以将之永久改为出牌阶段，若为判定/摸牌/弃牌阶段，你横置/摸六张牌/明置所有牌。"..
  "你杀死一名角色后，复原所有因此法改变的阶段。",
  ["steam__ranji"] = "燃己",
  [":steam__ranji"] = "你的手牌数低于体力值后，你可以摸两张牌，然后失去1点体力。若在你的出牌阶段，则此技能必须发动。",
  ["#steam__qingbei3-invoke"] = "倾北：即将开始判定阶段，是否永久改为出牌阶段并横置武将牌？",
  ["#steam__qingbei4-invoke"] = "倾北：即将开始摸牌阶段，是否永久改为出牌阶段并摸八张牌？",
  ["#steam__qingbei6-invoke"] = "倾北：即将开始弃牌阶段，是否永久改为出牌阶段并明置所有手牌？",
  ["@steam__qingbei"] = "倾北",
  ["#steam__ranji-invoke"] = "燃己：是否失去1点体力，摸两张牌？",

  ["$steam__qingbei1"] = "效逐日之夸父，怀忠志而长存。",
  ["$steam__qingbei2"] = "知天命而不顺，履穷途而强为。",
  ["$steam__ranji1"] = "此身为薪，炬成灰亦照大汉长明。",
  ["$steam__ranji2"] = "维之一腔骨血，可驱驰来北马否？",
  ["~steam__jiangwei"] = "姜维，姜维，又将何为？",
}

local guohuai = General:new(extension, "steam__guohuai", "wei", 4)
local shejing = fk.CreateTriggerSkill {
  name = "steam__shejing",
  events = {fk.EventPhaseChanging},
  can_trigger = function (self, event, target, player, data)
    if target == player and player:hasSkill(self) and data.to > 2 and data.to < 7 and
      player:usedSkillTimes(self.name, Player.HistoryTurn) == 0 and #player.room:getOtherPlayers(player) > 0 then
      local turn_event = player.room.logic:getCurrentEvent():findParent(GameEvent.Turn, true)
      return turn_event ~= nil and turn_event.data[1] == player
    end
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local to = room:askForChoosePlayers(player, table.map(room:getOtherPlayers(player), Util.IdMapper), 1, 1,
      "#steam__shejing-choose:::"..U.ConvertPhse(data.to)..":"..U.ConvertPhse(data.to + 1), self.name, true)
    if #to > 0 then
      self.cost_data = {tos = to}
      return true
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    if data.to == Player.Discard and not player:isKongcheng() then
      player:showCards(player:getCardIds("h"))
      if not player.dead then
        local cards = table.filter(player:getCardIds("h"), function (id)
          return Fk:getCardById(id).is_damage_card
        end)
        if #cards > 0 then
          room:recastCard(cards, player, self.name)
        end
      end
    end
    local p = room:getPlayerById(self.cost_data.tos[1])
    if not p.dead then
      room.logic:getCurrentEvent():addCleaner(function()
        p:gainAnExtraPhase(data.to + 1, true)
      end)
    end
    return true
  end,
}
guohuai:addSkill(shejing)
Fk:loadTranslationTable{
  ["steam__guohuai"] = "郭淮",
  ["#steam__guohuai"] = "云程烟凉",
  ["designer:steam__guohuai"] = "志文",
  ["illustrator:steam__guohuai"] = "心中一凛",

  ["steam__shejing"] = "摄境",
  [":steam__shejing"] = "你的回合内限一次，你的一个主要阶段开始时，你可以跳过之，令一名其他角色执行一个该阶段的下一阶段。若为弃牌阶段，"..
  "你须展示手牌并重铸其中所有伤害类牌。",
  ["#steam__shejing-choose"] = "摄境：是否跳过%arg，令一名角色执行%arg2？",

  ["$steam__shejing1"] = "北原乃敌我必争之地，宜先据之。",
  ["$steam__shejing2"] = "此乃明攻西围，暗袭阳遂之策也。",
  ["~steam__guohuai"] = "万策俱全，却没料到这步……",
}

local zhangmeng = General(extension, "steam__zhangmeng", "qun", 4)--张猛

local zhuoming = fk.CreateTriggerSkill{
  name = "steam__zhuomingone",
  anim_type = "drawcard",
  events = {fk.AfterCardsMove},
  frequency = Skill.Wake,
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) and player:usedSkillTimes(self.name, Player.HistoryGame) == 0 then
      local cards = {}
      for _, move in ipairs(data) do
        if move.toArea == Card.DiscardPile then
          for _, info in ipairs(move.moveInfo) do
            if Fk:getCardById(info.cardId).type == Card.TypeEquip and
              table.contains(player.room.discard_pile, info.cardId) then
              table.insertIfNeed(cards, info.cardId)
            end
          end
        end
      end
      cards = U.moveCardsHoldingAreaCheck(player.room, cards)
      if #cards > 0 then
        self.cost_data = cards
        return true
      end
    end
  end,
  can_wake = function (self, event, target, player, data)
    local cards = self.cost_data or {}
    for _, cid in ipairs(cards) do
      local card = Fk:getCardById(cid)
      if card.type == Card.TypeEquip and #player:getEquipments(card.sub_type) == 0 then
        return true
      end
    end
    return false
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cards = self.cost_data or {}
    for _, cid in ipairs(cards) do
      local card = Fk:getCardById(cid)
      if card.type == Card.TypeEquip and #player:getEquipments(card.sub_type) == 0 then
        room:useCard{
          from = player.id,
          tos = {{player.id}},
          card = card,
        }
      end
    end
    room:setPlayerMark(player, "steam__zhuoming1", 1)
    room:handleAddLoseSkills(player, "steam__zhuomingtwo", nil, false, false)
  end,
}

local zhuoming_buff = fk.CreateTriggerSkill{
  name = "#steam__zhuoming_buff",
  mute = true,
  frequency = Skill.Compulsory,
  events = {fk.DrawNCards},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and player:getMark("steam__zhuoming1") > 0 and target==player
  end,
  on_use = function(self, event, target, player, data)
    data.n = data.n * 2
  end,
}

zhuoming:addRelatedSkill(zhuoming_buff)

local zhuoming2 = fk.CreateTriggerSkill{
  name = "steam__zhuomingtwo",
  anim_type = "special",
  frequency = Skill.Wake,
  events = {fk.Damage, fk.Damaged},
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(self) or player:usedSkillTimes(self.name, Player.HistoryGame) > 0 then return false end
    local other = data.to
    if event == fk.Damage then
      other = data.to
      return other and other ~= player and target == player and
      (#other:getCardIds(Player.Hand) == #player:getCardIds(Player.Hand) or other.hp == player.hp)
    else
      other = data.from
      return other and other == player and target ~= player and
      (#target:getCardIds(Player.Hand) == #player:getCardIds(Player.Hand) or target.hp == player.hp)
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local other = data.to
    if event == fk.Damage then
      other = data.to
    else
      other = data.from
    end
    if other then
      other:setChainState(true)
    end
    player:setChainState(true)
    
    room:setPlayerMark(player, "steam__zhuoming2", 1)
    room:setPlayerMark(other, "steam__zhuoming2", 1)
    room:handleAddLoseSkills(player, "steam__shaoming", nil)
  end,
}


local zhuoming2_bihu = fk.CreateTriggerSkill{
  name = "#steam__zhuomingtwo_bihu",
  anim_type = "defensive",
  mute=true,
  frequency = Skill.Compulsory,
  events = {fk.BeforeChainStateChange},
  can_trigger = function(self, event, target, player, data)
      if not (target==player) then
          return false
      end
      if player:getMark("steam__zhuoming2") > 0 then
          return true
      end

      return false
  end,
  on_use = function(self, event, target, player, data)
    return true
  end,
}


local zhuoming2_buff = fk.CreateTargetModSkill{
  name = "#steam__zhuomingtwo_buff",
  frequency = Skill.Compulsory,
  residue_func = function(self, player, skill, scope, card)
    if player:hasSkill(self) and skill.trueName == "slash_skill" and scope == Player.HistoryPhase 
    and player:getMark("steam__zhuoming2") > 0 then
      local ret=skill.max_use_time[scope]
      if not ret then return nil end
      local status_skills = Fk:currentRoom().status_skills[TargetModSkill] or Util.DummyTable
      for _, skill in ipairs(status_skills) do
        local fix = skill:getFixedNum(player, self, scope, card, to)
        if fix ~= nil then -- 典中典之先到先得
          ret = fix
          break
        end
      end
      if ret then
        return ret
      end
    end
  end,
}

zhuoming2:addRelatedSkill(zhuoming2_bihu)
zhuoming2:addRelatedSkill(zhuoming2_buff)

local shaoming = fk.CreateTriggerSkill{
  name = "steam__shaoming",
  anim_type = "special",
  frequency = Skill.Wake,
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(self) and player.phase == Player.Start and
           player:usedSkillTimes(self.name, Player.HistoryGame) == 0 then
      return #player.room.logic:getEventsOfScope(GameEvent.Death, 1, function(e)
        local death = e.data[1]
        return death.damage and death.damage.from == player
      end, Player.HistoryGame) > 0
    end
    return false
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(player, "steam__shaoming", 1)
  end,
}

local shaoming_trigger = fk.CreateTriggerSkill{
  name = "#steam__shaoming_trigger",
  frequency = Skill.Compulsory,
  events = {fk.DamageCaused},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and player:getMark("steam__shaoming") > 0 and target==player
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    data.damage = data.damage * 2
  end,
}

local shaoming_trigger2 = fk.CreateTriggerSkill{
  name = "#steam__shaoming_trigger2",
  anim_type = "support",
  frequency = Skill.Compulsory,
  events = {fk.EnterDying},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and player:getMark("steam__shaoming") > 0 and target==player
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = target
    room:killPlayer({who = to.id})
    
  end,
}

local shaoming_trigger3 = fk.CreateTriggerSkill{
  name = "#steam__shaoming_trigger3",
  frequency = Skill.Compulsory,
  events = {fk.HpChanged},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and player:getMark("steam__shaoming") > 0 and target==player and player.hp<2
    and player.hp>0
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:damage{
      from = player,
      to = player,
      damage = 999,
      damageType = fk.FireDamage,
      skillName = self.name,  
  }
  end,
}

shaoming:addRelatedSkill(shaoming_trigger)
shaoming:addRelatedSkill(shaoming_trigger2)
shaoming:addRelatedSkill(shaoming_trigger3)

zhangmeng:addSkill(zhuoming)
zhangmeng:addRelatedSkill(zhuoming2)
zhangmeng:addRelatedSkill(shaoming)

Fk:loadTranslationTable{
  ["steam__zhangmeng"] = "张猛",
  ["#steam__zhangmeng"] = "唱罢高台",
  ["designer:steam__zhangmeng"] = "寒雾",

  ["steam__zhuomingone"] = "擢命",
  [":steam__zhuomingone"] = "觉醒技，有装备牌进入弃牌堆后，若你对应装备栏空置，你使用之并翻倍额定摸牌数，然后获得“啄命”。",
  ["steam__zhuoming_buffone"] = "擢命",
  ["steam__zhuoming_drawone"] = "擢命",
  ["@steam__zhuoming1"] = "擢命",
  ["#steam__zhuoming_buff"] = "擢命",

  ["$steam__zhuomingone1"] = "世人以七尺为性命，吾独以性命为七尺。",
  ["$steam__zhuomingone2"] = "钻龟筮占兆，何异于缘木求鱼？",

  ["steam__zhuomingtwo"] = "啄命",
  [":steam__zhuomingtwo"] = [[觉醒技，你受到其他角色的伤害或对其他角色造成伤害后，若你与其体力值或手牌数相等，你翻倍出杀上限并与其永久横置，
  然后获得“灼命”。]],
  ["@steam__zhuomingtwo"] = "啄命",
  ["#steam__zhuomingtwo_bihu"] = "啄命",
  ["#steam__zhuoming2_buff"] = "啄命",
  ["$steam__zhuomingtwo1"] = "自知者不怨人，知命者不怨天。",
  ["$steam__zhuomingtwo2"] = "命由我作，福自己求，从心而觅，感无不通。",

  ["steam__shaoming"] = "灼命",
  [":steam__shaoming"] = "觉醒技，回合开始时，若你杀死过角色，你造成伤害翻倍，并删除你的濒死阶段。且本局你的体力值小于2后，立刻对自己造成致死量的火焰伤害。",
  ["@steam__shaoming"] = "灼命",
  ["#steam__shaoming_trigger"] = "灼命",
  ["#steam__shaoming_trigger2"] = "灼命",
  ["#steam__shaoming_trigger3"] = "灼命",

  ["$steam__shaoming1"] = "将阴梦火，将疾梦食……存此念吾心已败。",
  ["$steam__shaoming2"] = "觉有八征，梦有六候，如今一一在验……",

  ["~steam__zhangmeng"] = "死去皆空，独耻见先父，无颜东归。",
}

local zhuyi = General:new(extension, "steam__zhuyi", "wu", 4)
local kunzhao = fk.CreateTriggerSkill{
  name = "steam__kunzhao",
  anim_type = "control",
  events = {fk.EventPhaseStart},
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Start and
      table.find(player.room:getOtherPlayers(player), function(p)
        return not p:isNude()
      end)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = table.filter(room:getOtherPlayers(player), function(p)
      return not p:isNude()
    end)
    local to = room:askForChoosePlayers(player, table.map(targets, Util.IdMapper), 1, 1,
      "#steam__kunzhao-choose", self.name, true)
    if #to > 0 then
      self.cost_data = {tos = to}
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(self.cost_data.tos[1])
    local card = room:askForCard(to, 1, 1, true, self.name, false, nil, "#steam__kunzhao-give:"..player.id)
    room:moveCardTo(card, Card.PlayerHand, player, fk.ReasonGive, self.name, nil, false, to.id)
    if player.dead or to.dead then return end
    local choice = room:askForChoice(to, {"1", "2", "3"}, self.name, "#steam__kunzhao-choice:"..player.id)
    room:addPlayerMark(player, MarkEnum.SlashResidue.."-turn", tonumber(choice))
    room:sendLog({
      type = "#steam__kunzhao_residue",
      from = player.id,
      arg = choice,
      toast = true,
    })
  end,
}
local ranzhong = fk.CreateActiveSkill{
  name = "steam__ranzhong",
  anim_type = "drawcard",
  min_card_num = 1,
  target_num = 0,
  prompt = "#steam__ranzhong",
  can_use = function(self, player)
    local card = Fk:cloneCard("slash")
    local n = card.skill:getMaxUseTime(player, Player.HistoryPhase, card, nil) or 0
    return player:usedCardTimes("slash", Player.HistoryPhase) < n
  end,
  card_filter = Util.TrueFunc,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    room:loseHp(player, 1, self.name)
    if player.dead then return end
    room:recastCard(effect.cards, player, self.name)
  end,
}
local ranzhong_trigger = fk.CreateTriggerSkill{
  name = "#steam__ranzhong_trigger",
  mute = true,
  main_skill = ranzhong,
  events = {fk.CardUseFinished},
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(ranzhong) and data.card.trueName == "slash" and player.phase == Player.Play and
      not data.extraUse and not player:isKongcheng() then
      local card = Fk:cloneCard("slash")
      local n = card.skill:getMaxUseTime(player, Player.HistoryPhase, card, nil) or 0
      if player:usedCardTimes("slash", Player.HistoryPhase) == n then
        return not table.find(player:getCardIds("h"), function (id)
          return Fk:getCardById(id).trueName == "slash" and (player:isWounded() or player:getHandcardNum() < player.hp)
        end)
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:showCards(player:getCardIds("h"))
    if player.dead then return end
    if player:isWounded() then
      room:recover({
        who = player,
        num = 1,
        recoverBy = player,
        skillName = "steam__ranzhong",
      })
    end
    if player.dead or player:getHandcardNum() >= player.hp then return end
    player:drawCards(player.hp - player:getHandcardNum(), "steam__ranzhong")
  end
}
ranzhong:addRelatedSkill(ranzhong_trigger)
zhuyi:addSkill(kunzhao)
zhuyi:addSkill(ranzhong)
Fk:loadTranslationTable{
  ["steam__zhuyi"] = "朱异",
  ["#steam__zhuyi"] = "枉戍力",
  ["illustrator:steam__zhuyi"] = "哥达耀",
  ["designer:steam__zhuyi"] = "yyuaN",
  ["cv:steam__zhuyi"] = "超绝天",

  ["steam__kunzhao"] = "困沼",
  [":steam__kunzhao"] = "准备阶段，你可以令一名其他角色交给你一张牌，然后其选择令你本回合出牌阶段使用【杀】次数增加1~3次。",
  ["steam__ranzhong"] = "燃忠",
  [":steam__ranzhong"] = "出牌阶段，若你未达到使用【杀】次数上限，你可失去1点体力并重铸任意张牌；当你使用【杀】结算后，若本次使用【杀】"..
  "使你达到使用【杀】次数上限且你手牌中没有【杀】，你可以展示所有手牌，回复1点体力并将手牌摸至体力值。",

  ["#steam__kunzhao-choose"] = "困沼：令一名角色交给你一张牌，然后其令你本回合使用【杀】次数上限增加",
  ["#steam__kunzhao-give"] = "困沼：请交给 %src 一张牌",
  ["#steam__kunzhao-choice"] = "困沼：选择令 %src 本回合出牌阶段使用【杀】增加的次数",
  ["#steam__kunzhao_residue"] = "%from 使用【杀】次数 +%arg",
  ["#steam__ranzhong"] = "燃忠：你可以失去1点体力，重铸任意张牌",
  ["#steam__ranzhong_trigger"] = "燃忠",

  ["$steam__kunzhao1"] = "此心战战，如临深而履薄。",
  ["$steam__kunzhao2"] = "上下无常，涉道浅、没足深。",
  ["$steam__ranzhong1"] = "南岳干、钟山铜，应机方获隼。",
  ["$steam__ranzhong2"] = "丙丁火、藏乎兑，此兆一线生。",
  ["~steam__zhuyi"] = "功名难望、林木无枝。",
}

local zhonghui = General:new(extension, "steam__zhuzhonghui", "wei", 4, 4, General.Female)
local function YewangWildCheck(player, choice)
  local room = player.room
  if table.every({"companion", "yinyangfish", "vanguard", "wild"}, function (mark)
    return player:getMark("@!"..mark) == 0
  end) then
    room:handleAddLoseSkills(player, "-steam__zhuyewang_active&", nil, false, true)
    if choice == "wild" and player.role ~= "lord" then
      player:broadcastSkillInvoke("steam__zhuyewang", 3)
      room:notifySkillInvoked(player, "steam__zhuyewang", "big")
      RUtil.becomeWild(player)
    end
  end
end
local yewang = fk.CreateTriggerSkill{
  name = "steam__zhuyewang",
  mute = true,
  frequency = Skill.Compulsory,
  events = {fk.GameStart, fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    if event == fk.GameStart then
      return player:hasShownSkill(self)
    elseif event == fk.EventPhaseStart then
      return target == player and player.phase == Player.Discard and
        (player:getMark("@!yinyangfish") > 0 or player:getMark("@!wild") > 0) and
        player:getMark("steam__zhuyewang_used-turn") == 0
    end
  end,
  on_cost = function (self, event, target, player, data)
    if event == fk.GameStart then
      return true
    elseif event == fk.EventPhaseStart then
      local choices = {"Cancel"}
      if player:getMark("@!yinyangfish") > 0 then
        table.insert(choices, "yinyangfish")
      end
      if player:getMark("@!wild") > 0 then
        table.insert(choices, "wild")
      end
      local choice = player.room:askForChoice(player, choices, "yinyangfish", "#yinyangfish_max-ask")
      if choice ~= "Cancel" then
        self.cost_data = choice
        return true
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke("steam__zhuyewang", math.random(2))
    if event == fk.GameStart then
      room:notifySkillInvoked(player, "steam__zhuyewang", "special")
      for _, mark in ipairs({"companion", "yinyangfish", "vanguard", "wild"}) do
        room:addPlayerMark(player, "@!"..mark, 1)
      end
      room:handleAddLoseSkills(player, "steam__zhuyewang_viewas&|steam__zhuyewang_active&", nil, false, true)
    elseif event == fk.EventPhaseStart then
      room:setPlayerMark(player, "steam__zhuyewang_used-turn", 1)
      room:setPlayerMark(player, "steam__zhuyewang_yinyangfish-turn", 1)
      room:removePlayerMark(player, "@!"..self.cost_data, 1)
      room:addPlayerMark(player, MarkEnum.AddMaxCardsInTurn, 2)
      room:notifySkillInvoked(player, "yinyangfish_skill&", "defensive")
      YewangWildCheck(player, self.cost_data)
    end
  end,
}
local yewang_viewas = fk.CreateViewAsSkill{
  name = "steam__zhuyewang_viewas&",
  mute = true,
  prompt = "#steam__zhuyewang_viewas&",
  pattern = "peach",
  card_filter = Util.FalseFunc,
  view_as = function(self, cards)
    local card = Fk:cloneCard("peach")
    card.skillName = "companion_peach&"
    return card
  end,
  before_use = function(self, player)
    local room = player.room
    player:broadcastSkillInvoke("steam__zhuyewang", math.random(2))
    local choices = {}
    if player:getMark("@!companion") > 0 then
      table.insert(choices, "companion")
    end
    if player:getMark("@!wild") > 0 then
      table.insert(choices, "wild")
    end
    local choice = room:askForChoice(player, choices, "companion", "#steam__zhuyewang_mark-ask")
    room:setPlayerMark(player, "steam__zhuyewang_used-turn", 1)
    room:setPlayerMark(player, "steam__zhuyewang_companion-round", 1)
    room:removePlayerMark(player, "@!"..choice, 1)
    room:notifySkillInvoked(player, "companion_peach&", "defensive")
    YewangWildCheck(player, choice)
    if player:getMark("@!companion") == 0 and player:getMark("@!wild") == 0 then
      room:handleAddLoseSkills(player, "-"..self.name, nil, false, true)
    end
  end,
  enabled_at_play = function(self, player)
    return (player:getMark("@!companion") > 0 or player:getMark("@!wild") > 0) and
      player:getMark("steam__zhuyewang_used-turn") == 0
  end,
  enabled_at_response = function(self, player, response)
    return not response and (player:getMark("@!companion") > 0 or player:getMark("@!wild") > 0) and
      player:getMark("steam__zhuyewang_used-turn") == 0
  end,
}
local yewang_active = fk.CreateActiveSkill{
  name = "steam__zhuyewang_active&",
  mute = true,
  prompt = function (self, selected_cards, selected_targets)
    return "#steam__zhuyewang_active_"..self.interaction.data
  end,
  interaction = function()
    if Self:getMark("@!wild") > 0 then
      return UI.ComboBox {choices = {"vanguard", "companion", "yinyangfish"}}
    else
      local choices = {}
      for _, mark in ipairs({"companion", "yinyangfish", "vanguard"}) do
        if Self:getMark("@!"..mark) > 0 then
          table.insert(choices, mark)
        end
      end
      return UI.ComboBox {choices = choices}
    end
  end,
  card_num = 0,
  target_num = 0,
  card_filter = Util.FalseFunc,
  can_use = function(self, player)
    return player:getMark("steam__zhuyewang_used-turn") == 0 and
      table.find({"companion", "yinyangfish", "vanguard", "wild"}, function (mark)
        return player:getMark("@!"..mark) > 0
      end)
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    player:broadcastSkillInvoke("steam__zhuyewang", math.random(2))
    local pattern = self.interaction.data
    local choices = {}
    if player:getMark("@!"..pattern) > 0 then
      table.insert(choices, pattern)
    end
    if player:getMark("@!wild") > 0 then
      table.insert(choices, "wild")
    end
    local choice = room:askForChoice(player, choices, pattern, "#steam__zhuyewang_mark-ask")
    room:setPlayerMark(player, "steam__zhuyewang_used-turn", 1)
    room:removePlayerMark(player, "@!"..choice, 1)
    YewangWildCheck(player, pattern)
    if pattern == "companion" then
      room:notifySkillInvoked(player, "companion_skill&", "drawcard")
      room:setPlayerMark(player, "steam__zhuyewang_companion-round", 1)
      player:drawCards(2, self.name)
    elseif pattern == "yinyangfish" then
      room:notifySkillInvoked(player, "yinyangfish_skill&", "drawcard")
      room:setPlayerMark(player, "steam__zhuyewang_yinyangfish-turn", 1)
      player:drawCards(1, self.name)
    elseif pattern == "vanguard" then
      room:notifySkillInvoked(player, "vanguard_skill&", "drawcard")
      room:setPlayerMark(player, "steam__zhuyewang_vanguard-phase", 1)
      local num = 4 - player:getHandcardNum()
      if num > 0 then
        player:drawCards(num, self.name)
      end
    end
  end,
}
local zhuting = fk.CreateTriggerSkill{
  name = "steam__zhuting",
  anim_type = "special",
  events = {fk.RoundEnd},
  frequency = Skill.Wake,
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and player:usedSkillTimes(self.name, Player.HistoryGame) == 0
  end,
  can_wake = function(self, event, target, player, data)
    return player:getMark("steam__zhuyewang_companion-round") > 0 and
      #player.room.logic:getEventsOfScope(GameEvent.Death, 1, function (e)
        return true
      end, Player.HistoryRound) > 0
  end,
  on_use = function (self, event, target, player, data)
    player:broadcastSkillInvoke(self.name, 1)
  end,
}
local zhuting_delay = fk.CreateTriggerSkill{
  name = "#steam__zhuting",
  anim_type = "offensive",
  events = {fk.RoundEnd},
  can_trigger = function (self, event, target, player, data)
    return player:usedSkillTimes("steam__zhuting", Player.HistoryGame) > 0 and
      #player.room.logic:getEventsOfScope(GameEvent.Death, 1, function (e)
        return true
      end, Player.HistoryRound) > 0 and
      player:usedSkillTimes("steam__zhuting", Player.HistoryRound) == 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    player:broadcastSkillInvoke("steam__zhuting", math.random(2, 3))
    player:gainAnExtraTurn(true, "steam__zhuting")
  end,
}
local yuyuan = fk.CreateTriggerSkill{
  name = "steam__yuyuan",
  anim_type = "special",
  events = {fk.TurnEnd},
  frequency = Skill.Wake,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player:usedSkillTimes(self.name, Player.HistoryGame) == 0
  end,
  can_wake = function(self, event, target, player, data)
    return player:getMark("steam__zhuyewang_yinyangfish-turn") > 0 and
      #player.room.logic:getEventsOfScope(GameEvent.MoveCards, 1, function (e)
        for _, move in ipairs(e.data) do
          if move.moveReason == fk.ReasonDiscard then
            return true
          end
        end
      end, Player.HistoryTurn) > 0
  end,
  on_use = function (self, event, target, player, data)
    player:broadcastSkillInvoke(self.name, 1)
  end,
}
local yuyuan_delay = fk.CreateTriggerSkill{
  name = "#steam__yuyuan",
  anim_type = "control",
  events = {fk.TurnEnd},
  can_trigger = function (self, event, target, player, data)
    return player:usedSkillTimes("steam__yuyuan", Player.HistoryGame) > 0 and target == player and
      #player.room.logic:getEventsOfScope(GameEvent.MoveCards, 1, function (e)
        for _, move in ipairs(e.data) do
          if move.moveReason == fk.ReasonDiscard then
            return true
          end
        end
      end, Player.HistoryTurn) > 0 and
      #player.room:canMoveCardInBoard() > 0 and
      player:usedSkillTimes("steam__yuyuan", Player.HistoryTurn) == 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke("steam__yuyuan", math.random(2, 3))
    local targets = room:askForChooseToMoveCardInBoard(player, "#steam__yuyuan-invoke", "steam__yuyuan", false)
    room:askForMoveCardInBoard(player, room:getPlayerById(targets[1]), room:getPlayerById(targets[2]), "steam__yuyuan")
  end,
}
local quyan = fk.CreateTriggerSkill{
  name = "steam__quyan",
  anim_type = "special",
  events = {fk.EventPhaseEnd},
  frequency = Skill.Wake,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Play and
      player:usedSkillTimes(self.name, Player.HistoryGame) == 0
  end,
  can_wake = function(self, event, target, player, data)
    return player:getMark("steam__zhuyewang_vanguard-phase") > 0 and
    #player.room.logic:getEventsOfScope(GameEvent.MoveCards, 1, function (e)
      for _, move in ipairs(e.data) do
        if move.to == player.id and move.moveReason == fk.ReasonDraw then
          return true
        end
      end
    end, Player.HistoryPhase) == 0
  end,
  on_use = function (self, event, target, player, data)
    player:broadcastSkillInvoke(self.name, 1)
  end,
}
local quyan_delay = fk.CreateTriggerSkill{
  name = "#steam__quyan",
  anim_type = "offensive",
  events = {fk.EventPhaseEnd},
  can_trigger = function (self, event, target, player, data)
    return player:usedSkillTimes("steam__quyan", Player.HistoryGame) > 0 and
      target.phase == Player.Play and
      #player.room.logic:getEventsOfScope(GameEvent.MoveCards, 1, function (e)
        for _, move in ipairs(e.data) do
          if move.to == player.id and move.moveReason == fk.ReasonDraw then
            return true
          end
        end
      end, Player.HistoryPhase) > 0 and
      player:usedSkillTimes("steam__quyan", Player.HistoryPhase) == 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke("steam__quyan", math.random(2, 3))
    local to = room:askForChoosePlayers(player, table.map(room.alive_players, Util.IdMapper), 1, 1,
      "#steam__quyan-invoke", "steam__quyan", false)
    room:damage{
      from = player,
      to = room:getPlayerById(to[1]),
      damage = 1,
      damageType = fk.FireDamage,
      skillName = "steam__quyan",
    }
  end,
}
Fk:addSkill(yewang_viewas)
Fk:addSkill(yewang_active)
zhuting:addRelatedSkill(zhuting_delay)
yuyuan:addRelatedSkill(yuyuan_delay)
quyan:addRelatedSkill(quyan_delay)
zhonghui:addSkill(yewang)
zhonghui:addSkill(zhuting)
zhonghui:addSkill(yuyuan)
zhonghui:addSkill(quyan)
Fk:loadTranslationTable{
  ["steam__zhuzhonghui"] = "钟会",
  ["#steam__zhuzhonghui"] = "独巉剑阴",
  ["illustrator:steam__zhuzhonghui"] = "M云涯",
  ["designer:steam__zhuzhonghui"] = "zzcclll朱苦力",
  ["cv:steam__zhuzhonghui"] = "桃妮儿",

  ["steam__zhuyewang"] = "野望",
  [":steam__zhuyewang"] = "锁定技，游戏开始时，你获得全部四种<a href='steam__zhuyewang_hegmark'>国战标记</a>，每回合至多使用一枚。"..
  "当你使用最后一枚标记后，若此标记为<a href='steam__zhuyewang_wild'>“野心家”</a>且你不为主公，你的身份变更为"..
  "<a href='steam__zhuyewang_wildrole'>野心家</a>。",
  ["steam__zhuyewang_hegmark"] = "即<a href='steam__zhuyewang_companion'>“珠联璧合”</a>、"..
  "<a href='steam__zhuyewang_yinyangfish'>“阴阳鱼”</a>、<a href='steam__zhuyewang_vanguard'>“先驱”</a>、"..
  "<a href='steam__zhuyewang_wild'>“野心家”</a>四种标记，可以于对应时机弃置标记发动对应的技能",
  ["steam__zhuyewang_wildrole"] = "野心家在游戏胜负条件判定时视为内奸；野心家击杀其他角色或其他角色击杀野心家后，摸三张牌",
  ["steam__zhuyewang_companion"] = "出牌阶段，你可以弃一枚“珠联璧合”，摸两张牌；你可以弃一枚“珠联璧合”，视为使用【桃】",
  ["steam__zhuyewang_yinyangfish"] = "出牌阶段，你可以弃一枚“阴阳鱼”，摸一张牌；弃牌阶段开始时，你可以弃一枚“阴阳鱼”，本回合手牌上限+2",
  ["steam__zhuyewang_vanguard"] = "出牌阶段，你可以弃一枚“先驱”，将手牌摸至4张",
  ["steam__zhuyewang_wild"] = "你可以将一枚“野心家”当以上三种中任意一种标记弃置并执行其效果",
  ["steam__zhuting"] = "珠庭",
  [":steam__zhuting"] = "觉醒技，轮次结束时，若你本轮使用了<a href='steam__zhuyewang_companion'>“珠联璧合”</a>且本轮有角色死亡："..
  "本局游戏此后每个有角色死亡的轮次结束时，你获得一个额外回合。",
  ["steam__yuyuan"] = "鱼渊",
  [":steam__yuyuan"] = "觉醒技，回合结束时，若你本回合使用了<a href='steam__zhuyewang_yinyangfish'>“阴阳鱼”</a>且本回合有牌被弃置："..
  "本局游戏此后你每个有牌被弃置的回合结束时，你移动场上一张牌。",
  ["steam__quyan"] = "驱焱",
  [":steam__quyan"] = "觉醒技，出牌阶段结束时，若你本阶段使用了<a href='steam__zhuyewang_vanguard'>“先驱”</a>且本阶段未摸牌："..
  "本局游戏此后每个你摸过牌的出牌阶段结束时，你对一名角色造成1点火焰伤害。",
  ["steam__zhuyewang_viewas&"] = "珠联[桃]",
  [":steam__zhuyewang_viewas&"] = "你可以弃置一枚“珠联璧合”或“野心家”标记，视为使用【桃】。",
  ["#steam__zhuyewang_viewas&"] = "珠联璧合：弃置一枚“珠联璧合”或“野心家”标记，视为使用【桃】",
  ["#steam__zhuyewang_mark-ask"] = "选择弃置的标记",
  ["steam__zhuyewang_active&"] = "标记",
  [":steam__zhuyewang_active&"] = "你可以弃置一枚国战标记，执行对应的摸牌效果。",
  ["#steam__zhuyewang_active_companion"] = "珠联璧合：弃置一枚“珠联璧合”或“野心家”标记，摸两张牌",
  ["#steam__zhuyewang_active_yinyangfish"] = "阴阳鱼：弃置一枚“阴阳鱼”或“野心家”标记，摸一张牌",
  ["#steam__zhuyewang_active_vanguard"] = "先驱：弃置一枚“先驱”或“野心家”标记，将手牌摸至4张",
  ["#steam__zhuting"] = "珠庭",
  ["#steam__yuyuan"] = "鱼渊",
  ["#steam__yuyuan-invoke"] = "鱼渊：请移动场上一张牌",
  ["#steam__quyan"] = "驱焱",
  ["#steam__quyan-invoke"] = "驱焱：对一名角色造成1点火焰伤害",

  ["$steam__zhuyewang1"] = "弃燕雀之小志，慕鸿鹄以高举。",
  ["$steam__zhuyewang2"] = "吾欲推赤心于天下，安万物之反侧。",
  ["$steam__zhuyewang3"] = "立事立功，开国称孤；朱轮朱毂，拥旄万里！",
  ["$steam__zhuting1"] = "月角珠庭映伏犀，扶摇当上凤凰池。",
  ["$steam__zhuting2"] = "乍暖微晴，舍北江东，如盖自亭亭。",
  ["$steam__zhuting3"] = "玉山候王母，珠庭谒老君，宁作蜉蝣子，此生逐功业。",
  ["$steam__yuyuan1"] = "此去如鱼入大海、鸟上青霄，再不受羁绊！",
  ["$steam__yuyuan2"] = "龙潜出震，握符御极；鞭笞四海，率土兴仁。",
  ["$steam__yuyuan3"] = "鸢飞戾天，鱼跃于渊。君子之志，岂在福禄黄白？",
  ["$steam__quyan1"] = "霜露所均，不育异类；姬汉旧邦，无取杂种。",
  ["$steam__quyan2"] = "火焱不灭，水浩不息，生民何辜？",
  ["$steam__quyan3"] = "尊王攘夷，扩土生杀，圣人为也！",
  ["~steam__zhuzhonghui"] = "时也，命也……",
}

local ningsui = General:new(extension, "steam__ningsui", "han", 4)
local xiangsui = fk.CreateActiveSkill{
  name = "steam__xiangsui",
  anim_type = "special",
  card_num = 0,
  target_num = 0,
  prompt = "#steam__xiangsui",
  interaction = function(self)
    return UI.ComboBox { choices = {"Top", "Bottom"} }
  end,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local cards
    if self.interaction.data == "Top" then
      cards = room:getNCards(3)
    else
      cards = room:getNCards(3, "bottom")
    end
    room:moveCardTo(cards, Card.Processing, nil, fk.ReasonJustMove, self.name, nil, true, player.id)
    if table.every(cards, function (id)
      return Fk:getCardById(id).suit == Card.Heart
    end) then
      room:delay(1000)
      room:moveCardTo(cards, Card.PlayerHand, player, fk.ReasonJustMove, self.name, nil, true, player.id)
      if not player.dead then
        room:handleAddLoseSkills(player, "-steam__xiangsui|efengqi__guanxing", nil, true, false)
      end
    else
      local result = room:askForGuanxing(player, cards, nil, nil, self.name, true, {"Top", "Bottom"})
      if #result.top > 0 then
        result.top = table.reverse(result.top)
        room:moveCards{
          ids = result.top,
          toArea = Card.DrawPile,
          moveReason = fk.ReasonJustMove,
          skillName = self.name,
          drawPilePosition = 1,
          moveVisible = true,
        }
      end
      if #result.bottom > 0 then
        room:moveCards{
          ids = result.bottom,
          toArea = Card.DrawPile,
          moveReason = fk.ReasonJustMove,
          skillName = self.name,
          drawPilePosition = -1,
          moveVisible = true,
        }
      end
    end
  end,
}
local jiangsu = fk.CreateTriggerSkill{
  name = "steam__jiangsu",
  anim_type = "special",
  events = {fk.EnterDying},
  can_trigger = function (self, event, target, player, data)
    return player:hasSkill(self) and not player:isNude()
  end,
  on_cost = function (self, event, target, player, data)
    local prompt = "#steam__jiangsu1::"..target.id
    if target == player then
      prompt = "#steam__jiangsu2"
    end
    return player.room:askForSkillInvoke(player, self.name, nil, prompt)
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    player:throwAllCards("he")
    if target ~= player then
      if not target.dead then
        room:killPlayer({who = target.id})
      end
    else
      if player:isWounded() and not player.dead then
        room:recover({
          who = player,
          num = player.maxHp - player.hp,
          recoverBy = player,
          skillName = self.name,
        })
      end
      if not player.dead then
        room:handleAddLoseSkills(player, "-steam__jiangsu|kunfenEx", nil, true, false)
      end
    end
  end,
}
local kunfen = fk.CreateTriggerSkill{
  name = "steam__kunfen",
  anim_type = "drawcard",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Finish
  end,
  on_use = function(self, event, target, player, data)
    player.room:loseHp(player, 1, self.name)
    if player:isAlive() then
      player.room:drawCards(player, 2, self.name)
    end
  end,
}
ningsui:addSkill(xiangsui)
ningsui:addSkill(jiangsu)
ningsui:addRelatedSkill("efengqi__guanxing")
ningsui:addRelatedSkill(kunfen)
Fk:loadTranslationTable{
  ["steam__ningsui"] = "宁随",
  ["#steam__ningsui"] = "摧心诀泪",
  ["illustrator:steam__ningsui"] = "佚名",
  ["designer:steam__ningsui"] = "zzcclll朱苦力",

  ["steam__xiangsui"] = "相随",
  [":steam__xiangsui"] = "出牌阶段限一次，你可以展示牌堆底或牌堆顶三张牌，然后将这些牌以任意顺序置于牌堆底或牌堆顶；若均为"..
  "<font color='red'>♥</font>，改为你获得之，失去此技能并获得〖观星〗。",
  ["steam__jiangsu"] = "将谡",
  [":steam__jiangsu"] = "一名角色进入濒死状态时，你可以弃置所有牌，令其死亡；若为你，改为回复所有体力，失去此技能并获得〖困奋〗。",
  ["steam__kunfen"] = "困奋",
  [":steam__kunfen"] = "结束阶段开始时，你可以失去1点体力，然后摸两张牌。",

  ["#steam__xiangsui"] = "相随：你可以展示牌堆底或牌堆顶三张牌，然后你将这些牌以任意顺序置于牌堆底或牌堆顶",
  ["#steam__jiangsu1"] = "将谡：你可以弃置所有牌，令 %dest 死亡！",
  ["#steam__jiangsu2"] = "将谡：是否弃置所有牌，回复至体力上限？",
}

return extension