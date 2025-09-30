local extension=Package("steam_sjx")
extension.extensionName="aaa_steam"

Fk:loadTranslationTable{
  ["steam_sjx"] = "设选",
}
local U = require "packages/utility/utility"
--- 按组展示牌，并询问选择若干个牌组（用于清正等）
---@param room Room
---@param player ServerPlayer @ 询问角色
---@param listNames table<string> @ 牌组名的表
---@param listCards table<table<integer>> @ 牌组所含id表的表
---@param minNum integer @ 最小值
---@param maxNum integer @ 最大值
---@param skillName? string @ 技能名
---@param prompt? string @ 提示信息
---@param allowEmpty? boolean @ 是否可以选择空的牌组，默认不可
---@param cancelable? boolean @ 是否可以取消，默认可
---@param canopen boolean@ 是否名牌，默认是
---@return table<string> @ 返回选择的牌组的组名列表
local askForChooseCardList = function (room, player, listNames, listCards, minNum, maxNum, skillName, prompt, allowEmpty, cancelable,canopen)
  local choices = {}
  skillName = skillName or ""
  prompt = prompt or skillName
  if (allowEmpty == nil) then allowEmpty = false end
  if (cancelable == nil) then cancelable = true end
  local availableList = table.simpleClone(listNames)
  if not allowEmpty then
    for i = #listCards, 1, -1 do
      if #listCards[i] == 0 then
        table.remove(availableList, i)
      end
    end
  end
  -- set 'cancelable' to 'true' when the count of cardlist is out of range
  if not cancelable and #availableList < minNum then
    cancelable = true
  end
  local result = room:askForCustomDialog(
    player, skillName,
    "packages/aaa_steam/qml/ChooseCardListBox.qml",
    { listNames, listCards, minNum, maxNum, prompt, allowEmpty, cancelable,canopen }
  )
  if result ~= "" then
    choices = json.decode(result)
  elseif not cancelable and minNum > 0 then
    if #availableList > 0 then
      choices = table.random(availableList, minNum)
    end
  end
  return choices
end


local xuyou= General(extension, "steam__xuyou", "qun", 3)--许攸


local qingxi= fk.CreateActiveSkill{
    name = "steam__qingxi",
    anim_type = "support",
    card_num = 0,
    target_num = 1,
    prompt = "#steam__qingxi",
    can_use = function(self, player)
      return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0 

    end,
    target_filter = function(self, to_select, selected)
        return #selected == 0 and to_select ~= Self.id
      end,
    on_use = function(self, room, effect)
      local player=room:getPlayerById(effect.from)
      local target=room:getPlayerById(effect.tos[1])
      local num = (#player:getAvailableEquipSlots() - #player:getCardIds("e") )-1
      player:drawCards(math.max(num,1),self.name)
      local card1,card2
      if #player:getCardIds("h")>3 then
        local max=#player:getCardIds("h")-2
        card1=room:askForCard(player,2,max,false,self.name,false,".","#steam__qingxi-ask")

      else
        card1=room:askForCard(player,1,2,false,self.name,false,".","#steam__qingxi-ask")

      end
      card2=table.filter(player:getCardIds("h"),function(cid) return not table.contains(card1,cid) end)
      local listCards={card1,card2}
      local choice = askForChooseCardList(room, target, {"第一组","第二组"}, listCards, 1, 1, self.name,
      "#steam__qingxi-dis", false, false,false)
      if choice=="第一组" then
        room:throwCard(card1,self.name,player,target)
      else
        room:throwCard(card2,self.name,player,target)
      end

      local cards = player:getCardIds("h")
      player:showCards(cards)
      local card_s=table.filter(cards,function(cid) return Fk:getCardById(cid).trueName=="slash" end)
      local card_j=table.filter(cards,function(cid) return Fk:getCardById(cid).name=="jink"end)
      if #card_s>=2 then
        room:damage{
          to =target,from = player,damage = 1,damageType = fk.FireDamage,skillName = self.name,
        }
    
      elseif #card_j>=2 then
        if (#target:getCardIds(player.Hand) + #target:getCardIds(player.Equip)) > 0 then
          local cards = room:askForCardsChosen(player, target, 1, 1, "he", self.name, "#steam__qingxi-choscard::"..target.id)
          local dummy = Fk:cloneCard("dilu")
          dummy:addSubcards(cards) --
          room:obtainCard(player.id, dummy, true, fk.ReasonPrey)
        else
          local dummy = Fk:cloneCard("dilu")
          dummy:addSubcards(target:getCardIds("he"))
          room:obtainCard(player.id, dummy, true, fk.ReasonPrey)
        end
      end
    end,
}


  local yiji = fk.CreateTriggerSkill{
    name = "steam__yiji",
    anim_type = "control",
    events = {fk.EventPhaseStart},
    can_trigger = function(self, event, target, player, data)
      return player:hasSkill(self) and target.phase == Player.Play and target == player and not player:isNude()
    end,
    on_cost = function(self, event, target, player, data)
      local success, dat = player.room:askForUseActiveSkill(player, "steam__yiji_active", "#steam__yiji-ask", true)
      if success then
        self.cost_data = dat
        return true
      end
    end,
    on_use = function(self, event, target, player, data)
      local room = player.room
      local data=self.cost_data 
  
      room:throwCard(data.cards, self.name, player, player)
      local ids = room:getCardsFromPileByRule(""..data.interaction, 1, "discardPile")
      if #ids > 0 then
        room:obtainCard(player, ids[1], false, fk.ReasonJustMove)
      end


    end,
  }

  local yiji_active = fk.CreateActiveSkill{
    name = "steam__yiji_active",
    interaction = function(self)
      return UI.ComboBox { choices = {"slash","jink"} }
    end,
    card_num = 1,
    card_filter = function(self, to_select, selected)
      if #selected==0 then return true end
    end,
    on_use = function(self, room, effect)
      return true
    end,
  }
  Fk:addSkill(yiji_active)
  xuyou:addSkill(qingxi)
  xuyou:addSkill(yiji)
Fk:loadTranslationTable{
    ["steam__xuyou"]="许攸",
    ["#steam__xuyou"] = "毕方矫翼",
    ["designer:steam__xuyou"] = "伶伶",

    ["steam__qingxi"]="轻袭",
    [":steam__qingxi"]=[[出牌阶段限一次，你可以摸X张牌（X为你空余装备栏数-1且至少为1），然后将手牌分为两份(每份至少两张！)，令一名其他角色弃置其中一份，你展示另一份，
    若其中有至少两张：【杀】，你对其造成1点火焰伤害；【闪】，你获得其一张牌。]],

    ["#steam__qingxi"]="轻袭:你可以摸X张牌（X为你空余装备栏数-1，且至少为1），然后将手牌分为两份!令一名角色选择一份弃置",
    ["#steam__qingxi-ask"]="轻袭:请将你的手牌分为两份（这是第一份！第二份将会自动生成）",
    ["#steam__qingxi-dis"]="轻袭:选择许攸的一份手牌弃置！",
    ["#steam__qingxi-choscard"]="轻袭:请获得%dest 两张牌！",

    ["steam__yiji"]="易计",
    [":steam__yiji"]="出牌阶段开始时，你可以弃置一张牌，然后秘密从弃牌堆获得一张【杀】或【闪】。",
    ["#steam__yiji-ask"]="易计:你可以弃置一张牌，然后秘密从弃牌堆获得一张【杀】或【闪】。",
    ["steam__yiji_active"]="抉择",
    
}
local fangao= General(extension, "steam__fangao", "west", 3)--梵高

local kunanjintou = fk.CreateActiveSkill{
  name = "steam__kunanjintou",
  anim_type = "offensive",
  prompt = "#steam__kunanjintou",
  card_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) < 2
  end,
  card_filter = function(self, to_select, selected)
    return #selected == 0
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)

    room:throwCard(effect.cards, self.name, player, player)
    local cards=player:getTableMark("@$steam__kunanjintou")

    table.insert(cards,effect.cards[1])
    local suits = {}
    local numbers = {}
    for _, cid in ipairs(cards) do
      table.insertIfNeed(suits, Fk:getCardById(cid).suit)
      table.insertIfNeed(numbers, Fk:getCardById(cid).number)
    end
    if #suits >= 4 then
      room:recover({
        who = player,
        num = 1,
        recoverBy = player,
        skillName = self.name
      })
    else
      room:loseHp(player, 1,self.name)

    end
    if #numbers >= 8 then
      room:killPlayer{who = player.id}
    end
    room:setPlayerMark(player,"@$steam__kunanjintou",cards)
  end,
}

Fk:addPoxiMethod{
  name = "steam__niuquxingkong-ch",
  card_filter = function(to_select, selected, data)
    if #selected==0 then 
      return true 
    elseif #selected==1 then
      return Fk:getCardById(to_select).color~=Fk:getCardById(selected[1]).color
    end

  end,
  feasible = function(selected)
    return  #selected<=2
  end,
  prompt = function ()
    return "扭曲虚空:获得两张颜色不同的牌。"
  end,
}

local niuquxingkong= fk.CreateTriggerSkill{
  name = "steam__niuquxingkong",
  events = {fk.HpChanged},
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player, data)
    return target==player and player:hasSkill(self.name) and not player.dead and player:usedSkillTimes(self.name, Player.HistoryRound) < 1
  end,

  on_use = function(self, event, target, player, data)
    local room = player.room
    local targets = room.alive_players
    local req = Request:new(targets, "AskForUseActiveSkill")
    req.focus_text ="扭曲星空正在冲击灵魂！！！"
    for _, p in ipairs(targets) do
      local n=math.min(#p:getCardIds("he"),2)
      local extraData = {
        num = n,
        min_num = n,
        include_equip = true,
        pattern = ".",
        reason = self.name,
      }
      local data = {"choose_cards_skill", "#askForreset", false, extraData }
      req:setData(p, data)
      req:setDefaultReply(p, table.random(p:getCardIds("he"), n))
    end
    req:ask()
    for _, p in ipairs(targets) do
      local result = req:getResult(p)
      local card={}
      if result ~= "" then
        if type(result) == "table" and result.card then
          card= result.card.subcards
        else
          card = result
        end
      else
        card = result
      end
      if #card > 0 then
        room:recastCard(card, p, self.name)
      end

    end
    local cards = {}
    room.logic:getEventsOfScope(GameEvent.MoveCards, 1, function(e)
      for _, move in ipairs(e.data) do
        if move.toArea == Card.DiscardPile then
          for _, info in ipairs(move.moveInfo) do
            table.insertIfNeed(cards, info.cardId)
          end
        end
      end
    end, Player.HistoryTurn)
    cards = table.filter(cards, function (id)
      return table.contains(room.discard_pile, id)
    end)
    --local cards = table.filter(room.discard_pile, function(id) return true end)
    --local c = room:askForCardsChosen(player, player, 1, 1, {card_data = {{self.name, cards}}}, self.name)
    local get=room:askForPoxi(player,"steam__niuquxingkong-ch",{
      { self.name, cards},
    }, nil, true)
    room:obtainCard(player, get, false, fk.ReasonPrey)

  end,
}


fangao:addSkill(kunanjintou)
fangao:addSkill(niuquxingkong)
Fk:loadTranslationTable{
  ["steam__fangao"]="梵高",
  ["#steam__fangao"]="麦田风声",
  ["designer:steam__fangao"] = "伶伶",
  ["steam__kunanjintou"]="苦难尽头",
  ["@$steam__kunanjintou"]="苦难",
  [":steam__kunanjintou"]="出牌阶段限一次，你可以弃置一张牌，然后失去1点体力。若你以此法弃置的牌：花色达到四种，“失去”改为“回复”；点数达到八种，你死亡。",
  ["steam__niuquxingkong"]="扭曲星空",
  [":steam__niuquxingkong"]="当你每轮首次体力变化后，你可以令所有角色各重铸两张牌（不足全重铸，无牌不重铸），然后你获得本回合进入弃牌堆至多两张颜色不同的牌。",
  ["#askForreset"] = "请重铸两张牌！",
  ["#steam__niuquxingkong-ch"]="扭曲星空:获得两张颜色不同的牌。",
  ["#steam__kunanjintou"]="苦难尽头:你可以弃置一张牌，然后失去1点体力。",

}

local wangling = General(extension, "steam__wangling", "god", 4)--王凌

-- 鹜璨技能
local wucan = fk.CreateTriggerSkill{
  name = "steam__wucan",
  anim_type = "control",
  frequency = Skill.Limited,
  events = {fk.EventPhaseEnd},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and player.phase == Player.Play
      and player:usedSkillTimes(self.name, Player.HistoryGame) == 0
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askForSkillInvoke(player, self.name, data)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:notifySkillInvoked(player, self.name, "control")
   
    
    -- 第一步：重铸2张牌
    local cards1 = room:askForCard(player, 2, 2, false, self.name, true, ".", "#steam__wucan-recast1")
    if #cards1 > 0 then
      room:recastCard(cards1, player, self.name)
    else 
      return false
    end
    
    -- 第二步：重铸4张牌，可交出所有基本牌分配一点雷电伤害
    local cards2 = room:askForCard(player, 4, 4, false, self.name, true, ".", "#steam__wucan-recast2")
    if #cards2 > 0 then
      room:recastCard(cards2, player, self.name)
      
      -- 检查是否有基本牌可以交出
      local basic_cards = table.filter(player:getCardIds("h"), function(cid)
        return Fk:getCardById(cid).type == Card.TypeBasic
      end)
      
      if #basic_cards > 0 and room:askForSkillInvoke(player, self.name, nil, "#steam__wucan-damage") then
        room:throwCard(basic_cards, self.name, player, player)
        
        -- 选择一名角色造成雷电伤害
        local targets = room:getAlivePlayers()
        local target = room:askForChoosePlayers(player, table.map(targets, function(p) return p.id end),
        1, 1, "#steam__wucan-choose-damage", self.name, false)[1]
        if target then
          room:damage({
            from = player,
            to = room:getPlayerById(target),
            damage = 1,
            damageType = fk.ThunderDamage,
            skillName = self.name
          })
        end
      end
    else 
      return false
    end
    
    -- 第三步：重铸6张牌，可弃置所有装备牌，摸双倍的牌
    local cards3 = room:askForCard(player, 6, 6, false, self.name,  true, ".", "#steam__wucan-recast3")
    if #cards3 > 0 then
      room:recastCard(cards3, player, self.name)
      
      -- 检查是否有装备牌可以弃置
      local equip_cards = player:getCardIds("e")
      if #equip_cards > 0 and room:askForSkillInvoke(player, self.name, nil, "#steam__wucan-draw") then
        room:throwCard(equip_cards, self.name, player, player)
        player:drawCards(#equip_cards * 2, self.name)
      end
    else 
      return false
    end
    
    -- 第四步：重铸8张牌，复原"南启"
    local cards4 = room:askForCard(player, 8, 8, false, self.name, true, ".", "#steam__wucan-recast4")
    if #cards4 > 0 then
      room:recastCard(cards4, player, self.name)
      if player:getMark("steam__wucan_modified") == 0 then
        player:setSkillUseHistory("steam__nanqi", 0, Player.HistoryGame)
      else
        player:setSkillUseHistory("steam__baijie", 0, Player.HistoryGame)
      end
    end
  end,
}

-- 南启技能
local nanqi = fk.CreateTriggerSkill{
  name = "steam__nanqi",
  anim_type = "control",
  frequency = Skill.Limited,
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and player.phase == Player.Play
      and player:usedSkillTimes(self.name, Player.HistoryGame) == 0
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askForSkillInvoke(player, self.name, data)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:notifySkillInvoked(player, self.name, "control")
  
    
    local choices = {"nanqi_basic", "nanqi_move", "nanqi_chain"}
    local all_players = room:getAlivePlayers()
    local player_choices = {}
    local shown_cards = {}
    local chained_players = {}
    
    -- 所有角色同时选择
    for _, p in ipairs(all_players) do
      local choice = room:askForChoice(p, choices, self.name, "#steam__nanqi-choice")
      player_choices[p.id] = choice
      
      if choice == "nanqi_basic" then
        -- 展示一张基本牌
        local basic_cards = table.filter(p:getCardIds("h"), function(cid)
          return Fk:getCardById(cid).type == Card.TypeBasic
        end)
        
        if #basic_cards > 0 then
          local card = room:askForCard(p, 1, 1, false, self.name, true, ".|.|.|.|.|basic", "#steam__nanqi-show")[1]
          if card then
            p:showCards({card})
            table.insert(shown_cards, card)
          end
        end
      elseif choice == "nanqi_move" then
        -- 移动场上的一张牌
        if #room:canMoveCardInBoard() > 0 then
          local targets = room:askForChooseToMoveCardInBoard(p, "#steam__qiaobian-move", self.name, false)
          if #targets == 2 then
            targets = table.map(targets, Util.Id2PlayerMapper)
            room:askForMoveCardInBoard(p, targets[1], targets[2], self.name)
          end
        end
      elseif choice == "nanqi_chain" then
        -- 横置
        p:setChainState(true)
        table.insert(chained_players, p)
      end
    end
    
    -- 统计展示的基本牌
    local card_count = {}
    for _, card_id in ipairs(shown_cards) do
      local card = Fk:getCardById(card_id)
      card_count[card.name] = (card_count[card.name] or 0) + 1
    end
    
    -- 找出展示最多的基本牌
    local max_count = 0
    local max_card_name = nil
    for name, count in pairs(card_count) do
      if count > max_count then
        max_count = count
        max_card_name = name
      end
    end
    
    -- 使用展示最多的基本牌
    if max_card_name then
      local use = U.askForUseVirtualCard(room, player, max_card_name, nil, self.name, nil, false, true, true, true)
      if use then
        room:useCard(use)
      end
    end
    
    -- 如果没有角色横置，复原"鹜璨"，若发动过败阶，则复原"败阶"
    if #chained_players == 0 then
      if player:getMark("steam__nanqi_modified") == 0 then
        player:setSkillUseHistory("steam__wucan", 0, Player.HistoryGame)

      else
        player:setSkillUseHistory("steam__baijie", 0, Player.HistoryGame)
   
      end
    end
  end,
}

-- 败阶技能
local baijie = fk.CreateActiveSkill{
  name = "steam__baijie",
  anim_type = "control",
  card_num = 0,
  frequency = Skill.Limited,

  can_use = function(self, player)
    local choices = {}
    if player:usedSkillTimes("steam__wucan", Player.HistoryGame) > 0 then
      table.insert(choices, "steam__wucan")
    end
    if player:usedSkillTimes("steam__nanqi", Player.HistoryGame) > 0 then
      table.insert(choices, "steam__nanqi")
    end
    return player:usedSkillTimes(self.name, Player.HistoryGame) == 0 and #choices > 0

  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    room:notifySkillInvoked(player, self.name, "control")
    local mark = player:getTableMark("@@"..self.name)

    
    -- 摸三张牌
    player:drawCards(3, self.name)
    
    -- 选择复原哪个技能
    local choices = {}
    if player:usedSkillTimes("steam__wucan", Player.HistoryGame) > 0 then
      table.insert(choices, "steam__wucan")
    end
    if player:usedSkillTimes("steam__nanqi", Player.HistoryGame) > 0 then
      table.insert(choices, "steam__nanqi")
    end
    
    if #choices > 0 then
      local choice = room:askForChoice(player, choices, self.name, "#steam__baijie-choice")
      player:setSkillUseHistory(choice, 0, Player.HistoryGame)
      room:setPlayerMark(player, "@"..choice, 0)
      player:setSkillUseHistory(choice, 0, Player.HistoryGame)
      table.insert(mark, choice)
      room:setPlayerMark(player, "@@"..self.name, mark)
      -- 修改技能描述，最后的技能改为"败阶"
      if choice == "steam__wucan" then
        -- 这里只是概念上的修改，实际上需要在游戏逻辑中处理
        room:setPlayerMark(player, "steam__wucan_modified", 1)
      elseif choice == "steam__nanqi" then
        -- 这里只是概念上的修改，实际上需要在游戏逻辑中处理
        room:setPlayerMark(player, "steam__nanqi_modified", 1)
      end
    end
  end,
}

wangling:addSkill(wucan)
wangling:addSkill(nanqi)
wangling:addSkill(baijie)

Fk:loadTranslationTable{
  ["steam__wangling"] = "王凌",
  ["#steam__wangling"] = "迭浪徙向",
  ["designer:steam__wangling"] = "BCG",
  
  ["steam__wucan"] = "鹜璨",
  [":steam__wucan"] = [[限定技，阶段结束后，你可依次重铸二、四、六、八张牌，第二步后，你可交出所有基本牌，
  分配一点雷电伤害；第三步后，你可弃置所有装备牌，摸双倍的牌；第四步后，你复原"南启"。]],
  ["#steam__wucan-recast1"] = "鹜璨：请重铸2张牌",
  ["#steam__wucan-recast2"] = "鹜璨：请重铸4张牌",
  ["#steam__wucan-recast3"] = "鹜璨：请重铸6张牌",
  ["#steam__wucan-recast4"] = "鹜璨：请重铸8张牌",
  ["#steam__wucan-damage"] = "鹜璨：你可以交出所有基本牌，分配一点雷电伤害",
  ["#steam__wucan-choose-damage"] = "鹜璨：选择一名角色，对其造成1点雷电伤害",
  ["#steam__wucan-draw"] = "鹜璨：你可以弃置所有装备牌，摸双倍的牌",
  ["@steam__wucan"] = "鹜璨",
  
  ["steam__nanqi"] = "南启",
  [":steam__nanqi"] = [[限定技，阶段开始时，你可与所有角色同时选择一项：展示一张基本牌；移动其场上的一张牌；
  横置；你视为使用被展示最多的基本牌，若无角色因此横置，复原"鹜粲"。]],
  ["#steam__nanqi-choice"] = "南启：请选择一项：展示一张基本牌；移动场上的一张牌；横置",
  ["#steam__nanqi-show"] = "南启：请展示一张基本牌",
  ["#steam__nanqi-move"] = "南启：移动场上的一张牌",
  ["#steam__nanqi-move-to"] = "南启：请选择移动的目标角色",
  ["@steam__nanqi"] = "南启",
  ["nanqi_basic"] = "展示基本牌",
  ["nanqi_move"] = "移动牌",
  ["nanqi_chain"] = "横置",
  
  ["steam__baijie"] = "败阶",
  [":steam__baijie"] = [[限定技，出牌阶段，你可摸三张牌并复原"鹜璨"或"南启"，但之描述内最后的技能改为"败阶"。]],
  ["#steam__baijie-choice"] = "败阶：请选择要复原的技能",
  ["@@steam__baijie"] = "败阶",


  ["$steam__wucan1"] = "卅年岁月，八千里风与云！",
  ["$steam__wucan2"] = "逐彩璨而揽流光，倚繁星以盼长明！",
  ["$steam__wucan3"] = "长虹贯日，雷霆震宇，且整军以迎敌！",
  ["$steam__wucan4"] = "走马扬尘，银狐蹈雪，待利刃之出鞘！",
  ["$steam__nanqi1"] = "吾志在改天换地，诸君可愿共赴？",
  ["$steam__nanqi3"] = "百鹤齐唳，今当重绘山河！",
  ["$steam__nanqi2"] = "玉衡耀斗，波涛卷天，此兴军之时也！",
  ["$steam__baijie1"] = "旌旗未偃，何以言败？",
  ["$steam__baijie2"] = "皓月凌空，前途坦荡！",
  ["~steam__wangling"] = "若得风云际会，吾必……（咳血）斩了你这逆贼！",
}
--[[
鹜璨：
1.卅年岁月，八千里风与云！

2.逐彩璨而揽流光，倚繁星以盼长明！
（以上是分配雷电伤害）
3.长虹贯日，雷霆震宇，且整军以迎敌！
走马扬尘，银狐蹈雪，待利刃之出鞘！
（以上是弃置装备牌）
4.玉衡耀斗，波涛卷天，此兴军之时也！
 （复原技能）
南启：
吾志在改天换地，诸君可愿共赴？

百鹤齐唳，今当重绘山河！
 
败阶：
旌旗未偃，何以言败？
（复原鹜璨）
皓月凌空，前途坦荡！
（复原南启）
胜利：
风云变幻，乾坤扭转，吾终得胜！

失败：
若得风云际会，吾必……（咳血）斩了你这逆贼！
--]]

local lukang= General(extension, "steam__lukang", "wu", 3)--陆抗

local zhuwei = fk.CreateActiveSkill{
  name = "steam__zhuwei",
  anim_type = "control",
  prompt="铸围：弃置一张杀和武器牌，或者弃置一张闪和防具牌以获得技能（先选基本牌！）",
  can_use = function(self, player)
    return not player:isKongcheng() 
  end,
  card_filter = function(self, to_select, selected)
    local card = Fk:getCardById(to_select)
    if #selected == 0 then
      -- 选第一张牌时,可以是杀或闪
      return (card.name == "slash" or card.name == "jink") and 
             not Self:prohibitDiscard(card)
    elseif #selected == 1 then
      local first = Fk:getCardById(selected[1])
      if first.name == "slash" then
        -- 第一张是杀,第二张要是武器
        return card.sub_type == Card.SubtypeWeapon and
               not Self:prohibitDiscard(card)
      elseif first.name == "jink" then
        -- 第一张是闪,第二张要是防具
        return card.sub_type == Card.SubtypeArmor and
               not Self:prohibitDiscard(card)
      end
    end
    return false
  end,
  card_num = 2,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local cards = effect.cards
    local first = Fk:getCardById(cards[1])
    local second = Fk:getCardById(cards[2])
    
    room:throwCard(cards, self.name, player, player)
    
    if first.name == "slash" then
      -- 获得武器牌的技能
      if second.equip_skill then
        room:handleAddLoseSkills(player, second.equip_skill.name, nil, true)
      end
    elseif first.name == "jink" then
      -- 获得防具牌的技能
      if second.equip_skill then
        room:handleAddLoseSkills(player, second.equip_skill.name, nil, true)
      end
    end
  end
}
lukang:addSkill(zhuwei)


local xieyang = fk.CreateTriggerSkill{
  name = "steam__xieyang",
  anim_type = "drawcard",
  events = {fk.AfterSkillEffect},
  can_trigger = function(self, event, target, player, data)
    return target and target == player and player:hasSkill(self.name) and 
           data.name ~= self.name and data.name ~= "#steam__xieyang_buff" and  target:hasSkill(data)
            and not data.cardSkill
            and ((data:isPlayerSkill(player) and data.visible) or data:isEquipmentSkill(player))
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askForSkillInvoke(player, self.name, data)
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(1, self.name)
  end,
}

local xieyang_buff = fk.CreateAttackRangeSkill{
  name = "#steam__xieyang_buff",
  correct_func = function(self, from, to)
    if from:hasSkill(self) then
      return  #table.filter(
        from.player_skills,
        function(skill) return (skill:isPlayerSkill(from) and skill.visible) or skill:isEquipmentSkill(from)end
      )
    end
  end,
}

local xieyang_maxcards = fk.CreateMaxCardsSkill{
  name = "#steam__xieyang_maxcards", 
  correct_func = function(self, player)
    if player:hasSkill(self) then
      return  #table.filter(
        player.player_skills,
        function(skill) return (skill:isPlayerSkill(player) and skill.visible) or skill:isEquipmentSkill(player)end
      )
    end
  end,
}


xieyang:addRelatedSkill(xieyang_buff)
xieyang:addRelatedSkill(xieyang_maxcards)

lukang:addSkill(xieyang)

Fk:loadTranslationTable{
    ["steam__xieyang"] = "颉颃",
  [":steam__xieyang"] = "此你发动你的其他技能后，你可摸一张牌。你的攻击范围和手牌上限+你的技能数。(装备技能也可触发此技能)",
  ["steam__xieyang_draw"] = "颉颃",
  ["#steam__xieyang_buff"] = "颉颃",
  ["#steam__xieyang_maxcards"] = "颉颃",
}
-- 添加技能翻译
Fk:loadTranslationTable{
  ["steam__lukang"]="陆抗",
  ["steam__zhuwei"] = "铸围",
  [":steam__zhuwei"] = "出牌阶段，你可弃置一张【杀】和一张武器牌，或一张【闪】和一张防具牌，以永久获得此装备牌的技能。",
}







local caoshuang= General(extension, "steam__caoshuang", "wei", 4)--曹爽



local zhuanshe = fk.CreateTriggerSkill{
  name = "steam__zhuanshe",
  anim_type = "offensive",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target ~= player and player:hasSkill(self) and target.phase == Player.Play and not player:isKongcheng()
  end,
  on_cost = function(self, event, target, player, data)
      --local card = player.room:askForCard(player, 1, 1, false, self.name, true, ".", "#ev__waiqumoyan::"..data.to)
      local card = player.room:askForCard(player, 1, 1, false, self.name, true, ".", "#steam__zhuanshe::"..target.id)
      if #card > 0 then
        self.cost_data = card[1]
        return true
      end
    end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cid = self.cost_data
    player:showCards(cid)
    if player.dead then return end
    room:obtainCard(target.id, cid, true, fk.ReasonGive)
    local card=Fk:getCardById(cid)
    
    room:setPlayerMark(target, "@steam__zhuanshe",card.name)
    if card.type == Card.TypeBasic or card:isCommonTrick() then
      room:setPlayerMark(target, "steam__zhuanshe-turn",1)
    end
  end,
}

local zhuanshe_delay= fk.CreateTriggerSkill{
  name = "#steam__zhuanshe_delay",
  anim_type = "offensive",
  events = {fk.TargetSpecifying,fk.TurnEnd},
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(self) then return false end
    
    if event == fk.TurnEnd then
      if target:getMark("@steam__zhuanshe")==0 then return end
      local name=target:getMark("@steam__zhuanshe")
      local room = player.room
      local play_ids = {}
      room.logic:getEventsOfScope(GameEvent.Phase, 1, function (e)
        if e.data[2] == Player.Play and e.end_id then
          table.insert(play_ids, {e.id, e.end_id})
        end
        return false
      end, Player.HistoryTurn)
      if #play_ids == 0 then return true end
      --检测
      local function PlayCheck (e)
        local in_play = false
        for _, ids in ipairs(play_ids) do
          if e.id > ids[1] and e.id < ids[2] then
            in_play = true
            break
          end
        end
        return in_play and e.data[1].from == target.id and e.data[1].card.name == name
      end
      room:setPlayerMark(target, "@steam__zhuanshe",0)
      return #room.logic:getEventsOfScope(GameEvent.UseCard, 2, PlayCheck, Player.HistoryTurn) == 0

    elseif event == fk.TargetSpecifying then
      if target:getMark("@steam__zhuanshe")~=0 then

        return target:getMark("@steam__zhuanshe") == data.card.name and target:getMark("steam__zhuanshe-turn") == 1
        and data.card:getMark("zhuanshe-inhand")==0
      end
    end
   

  end,
  on_cost = function(self, event, target, player, data)
      local room=player.room
    if event == fk.TargetSpecifying then
      if player.dead then return end
      local availableTargets = U.getUseExtraTargets(room, data, true, true)
      local num = 1
      if #availableTargets > 0 and num > 0 then
          local targets = room:askForChoosePlayers(player, availableTargets, 1, num,
           "#steam__zhuanshe-choose:::"..data.card:toLogString() .. ":" .. num, self.name, true)
           if #targets > 0 then
            self.cost_data = targets
            data.card:setMark("zhuanshe-inhand",1)
            return true
          end

      end
    elseif event == fk.TurnEnd then
      return player.room:askForSkillInvoke(player, self.name, data, "#steam__zhuanshe-dmg::" .. target.id)
    end
  end,
  on_use = function(self, event, target, player, data)
      local room = player.room
      if event == fk.TargetSpecifying then
          local targets = self.cost_data
          if #targets > 0 then
              table.forEach(targets, function(pid) AimGroup:addTargets(room, data, pid) end)
          end
      else
          room:damage{
              from = player,
              to = target,
              damage = 1,
              skillName = self.name,
          }

      end
  end
}


local weiqiu=fk.CreateTriggerSkill{
  name = "steam__weiqiu",
  anim_type = "special",
  frequency = Skill.Compulsory,
  events = {fk.PreHpRecover},
  can_trigger = function(self, event, target, player, data)

   return player:hasSkill(self) and player:isKongcheng()
  end,
  on_use = function(self, event, target, player, data)
      player:drawCards(1,self.name)
      return true
  end,
}
zhuanshe:addRelatedSkill(zhuanshe_delay)
caoshuang:addSkill(zhuanshe)
caoshuang:addSkill(weiqiu)

Fk:loadTranslationTable{
  ["steam__caoshuang"]="曹爽",
  ["steam__zhuanshe"]="专摄",
  [":steam__zhuanshe"]=[[其他角色的出牌阶段开始时，你可以展示一张手牌并交给其。当其于本回合内使用与之名称相同的基本牌或普通锦囊牌时，
  你可以额外指定一名角色为目标(无距离限制)。当前回合结束后，若其于本回合内未使用与之名称相同的牌，你可以对其造成1点伤害。]],

  ["steam__weiqiu"]="危秋",
  [":steam__weiqiu"]="锁定技，当一名角色回复体力时，若你没有手牌，改为令你摸一张牌。",

  [ "#steam__zhuanshe"]="专摄：你可展示一张手牌并交给%dest",
  ["@steam__zhuanshe"]="专摄",
  ["#steam__zhuanshe-choose"] = "专摄：为此%arg额外指定至多%arg2个目标",
  ["#steam__zhuanshe-dmg"]="专摄：你可以对%dest造成1点伤害",
  ["#steam__zhuanshe_delay"]="专摄",
  
}

local zhugdan = General(extension, "steam__zhugdan", "wei", 4)--诸葛诞
Fk:addPoxiMethod{
  name = "steam__yicheng_recast",
  card_filter = function(to_select, selected, data)
    return #selected<4
  end,
  feasible = function(selected)
    return #selected == 4
  end,
  prompt = function ()
    return "#steam__yicheng_recast-ask"
  end
}
Fk:loadTranslationTable{
  ["#steam__yicheng_recast-ask"]="枙城：你可以重铸你与一名其他角色共4张牌",
  ["@steam__yicheng_recast"]="枙城",
}
local yicheng = fk.CreateActiveSkill{
  name = "steam__yicheng",
  anim_type = "support",
  prompt = "#steam__yicheng_recast-ask",
  card_num = 0,
  target_num = 1,
  can_use = function(self, player)
    return player:getMark("steam__yicheng-turn")==0
  end,
  card_filter = function(self, to_select, selected)
    return false
  end,
  target_filter = function(self, to_select, selected)
    return #selected == 0 and to_select ~= Self.id
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    local player_hands = player:getCardIds("he")
    local target_hands = target:getCardIds("he")
    local extra_data = {}
    local visible_data = {}
    for _, id in ipairs(player_hands) do
      if not player:cardVisible(id) then
        visible_data[tostring(id)] = false
      end
    end
    for _, id in ipairs(target_hands) do
      if not player:cardVisible(id) then
        visible_data[tostring(id)] = false
      end
    end
    if next(visible_data) == nil then visible_data = nil end
    extra_data.visible_data = visible_data
    local cards = room:askForPoxi(player, "steam__yicheng_recast", {
      { player.general, player_hands },
      { target.general, target_hands },
    }, extra_data, true)
    local peach = table.find(cards, function(id)
      return Fk:getCardById(id).name == "peach"
    end)
    local slash=table.filter(cards,function(cid) return Fk:getCardById(cid).trueName=="slash" end)
    local mycards=table.filter(cards,function(cid) return table.contains(player_hands,cid) end)
    local othercards=table.filter(cards,function(cid) return table.contains(target_hands,cid) end)

    if peach then
      room:throwCard(mycards, self.name, player, player)
      room:throwCard(othercards, self.name, target, player)
    else
      room:recastCard(mycards, player, self.name)
      room:recastCard(othercards, target, self.name)
    end
    if #slash > 0 then
      room:obtainCard(player, slash, true, fk.ReasonGive)
      room:setPlayerMark(player, "steam__yicheng-turn",1)
      
    end
  end,
}
local yicheng_delay=fk.CreateTriggerSkill{
  name = "#steam__yicheng_delay",
  anim_type = "support",
  events = {fk.EnterDying},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and player:getMark("steam__yicheng-turn")==0
  end,
  on_cost = function(self, event, target, player, data)
    local success, dat =  player.room:askForUseActiveSkill(player, "steam__yicheng", "枙城", true,nil,false)
    if success and dat then
      self.cost_data = {cards = dat.cards, tos = dat.targets}
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
      local room = player.room
      room:notifySkillInvoked(player, "steam__yicheng", "support")
  end,
}

yicheng:addRelatedSkill(yicheng_delay)
zhugdan:addSkill(yicheng)

Fk:loadTranslationTable{
  ["steam__zhugdan"] = "诸葛诞",
  ["#steam__zhugdan"] = "枙梦难成",
  ["designer:steam__zhugdan"] = "Sonaly",
  ["#steam__yicheng_delay"]="枙城",
  ["steam__yicheng"] = "枙城",
  [":steam__yicheng"] = [[出牌阶段或一名角色濒死时，你可以重铸你与一名其他角色共4张牌；若重铸的牌：包括【桃】，改为弃置；包括【杀】，
  你获得之且本回合【枙城】失效。]],
}

local shidaobao = General(extension, "steam__shidaobao", "qun", 3)--释道宝

local qisu = fk.CreateActiveSkill{
  name = "steam__qisu",
  anim_type = "support",
  prompt = "#steam__qisu-ask",
  card_num = 3,
  target_num = 0,
  can_use = function(self, player)
    return true
  end,
  card_filter = function(self, to_select, selected)
    return #selected < 3 and not Self:prohibitDiscard(Fk:getCardById(to_select))
  end,
  interaction = function(self)
    local all_names = {"peach", "foresight"}
    local names = U.getViewAsCardNames(Self, self.name, all_names)
    return U.CardNameBox { choices = names, all_choices = all_names }
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local cards = effect.cards
    local choice = self.interaction.data
    
    room:throwCard(cards, self.name, player, player)
    
    local black_count = #table.filter(cards, function(id)
      return Fk:getCardById(id).color == Card.Black
    end)
    
    local card = Fk:cloneCard(choice)
    card.skillName = self.name
    room:useCard({
      from = player.id,
      card = card,
      tos = {{player.id}},
    })
    
    if black_count > 0 then
      player:drawCards(black_count, self.name)
    end
  end,
}

local jiegou = fk.CreateTriggerSkill{
  name = "steam__jiegou",
  anim_type = "negative",
  frequency = Skill.Compulsory,
  events = {fk.CardUseFinished, fk.CardEffectCancelledOut, fk.RoundEnd},
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(self) then return false end
    
    if event == fk.CardUseFinished then
      if target ~= player then return false end
      if data.card.skillName == "steam__wuchan" then return false end
      
      -- 检查是否使用过同名牌
      local used_cards = {}
      player.room.logic:getEventsOfScope(GameEvent.UseCard, 1, function(e)
        if e.data[1].from == player.id and e.data[1].card.name == data.card.name then
          table.insert(used_cards, e.data[1].card.name)
        end
      end, Player.HistoryTurn)
      
      return #used_cards > 1 or data.card.is_damage_card
             
    elseif event == fk.CardEffectCancelledOut then
      return target == player
    elseif event == fk.RoundEnd then
      return player:getMark("@@steam__jiegou-round") == 0
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if event == fk.RoundEnd then
      player:setSkillUseHistory("steam__wuchan", 0, Player.HistoryGame)
    else
      room:loseHp(player, 1, self.name)
      room:setPlayerMark(player, "@@steam__jiegou-round", 1)
    end
  end,
}

local wuchan = fk.CreateTriggerSkill{
  name = "steam__wuchan",
  anim_type = "special",
  frequency = Skill.Wake,
  events = {fk.EnterDying},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self)
    and player:usedSkillTimes(self.name, Player.HistoryGame) == 0
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:recover({
      who = player,
      num = 1 - player.hp,
      recoverBy = player,
      skillName = self.name,
    })
    
    local times = player:usedSkillTimes("steam__qisu", Player.HistoryRound)
    if times==0 then return end
    for i = 1, times do
      local judge,result
        judge = {
          who = player,
          reason = self.name,
          pattern = ".|2~9|spade",
          extra_data = {wuchanSource = player.id}
        }
        room:judge(judge)
        result = judge.card
        if result.suit == Card.Spade and result.number >= 2 and result.number <= 9 then
          room:damage{
            to = judge.who,
            damage = 3,
            damageType = fk.ThunderDamage,
            skillName = self.name,
          }
        end
    end
    
 
  end,
}


local wuchan_trigger = fk.CreateTriggerSkill{
  name = "#wuchan_trigger",
  mute=true,
  anim_type = "drawcard",
  events = {fk.FinishJudge},
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and player.room:getCardArea(data.card) == Card.Processing
    and data.extra_data and data.extra_data.wuchanSource == player.id
  end,
  on_use = function(self, event, target, player, data)
    player.room:obtainCard(player.id, data.card, true, fk.ReasonJustMove)
  end,
}
wuchan:addRelatedSkill(wuchan_trigger)
shidaobao:addSkill(qisu)
shidaobao:addSkill(jiegou)
shidaobao:addSkill(wuchan)

Fk:loadTranslationTable{
  ["steam__shidaobao"] = "释道宝",
  ["#steam__shidaobao"] = "烂觞涌江",
  ["designer:steam__shidaobao"] = "静谦",

  ["steam__qisu"] = "弃俗",
  [":steam__qisu"] = "你可以弃置三张牌并视为使用【桃】或【洞烛先机】，然后摸本次弃置黑色牌数张牌。",
  ["#steam__qisu-ask"] = "弃俗：你可以弃置三张牌并视为使用【桃】或【洞烛先机】。",
  ["steam__jiegou"] = "戒垢",
  [":steam__jiegou"] = "锁定技，以下时机你失去1点体力：使用本回合使用过的同名牌后；使用伤害牌后；使用牌被抵消后。未触发过上述效果的轮次结束时，你复原“悟禅”。",
  ["steam__wuchan"] = "悟禅",
  [":steam__wuchan"] = "觉醒技，你进入濒死状态时，回复体力至1点，然后判定X次【闪电】并获得所有生效的判定牌（X为你本轮发动“弃俗”的次数）。",
  ["@@steam__jiegou-round"] = "未戒垢",
  ["@steam__wuchan"] = "悟禅",
  ["#steam__wuchan_trigger"] = "悟禅",
  ["$steam__wuchan1"]="菩提本无树,明镜亦非台",
  ["$steam__wuchan2"]="本来无一物,何处惹尘埃",
}

local xunyu = General(extension, "steam_sjx__xunyu", "han", 3) -- 荀彧


-- 睹机技能
local duji = fk.CreateActiveSkill{
  name = "steam1__duji",
  anim_type = "control",
  prompt = "#steam1__duji",
  card_num = 0,
  target_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  target_filter = function(self, to_select, selected, selected_cards, _, _, player)
    return #selected == 0 and not Fk:currentRoom():getPlayerById(to_select):isKongcheng()
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    local usecardname=function(cardnames,player,room,skillname,realcards)
      local names = U.getViewAsCardNames(player, skillname, cardnames)
      local card_name = room:askForChoice(player, names, skillname, "#steam__duji-choiceuse")
      local use = U.askForUseVirtualCard(room, player, card_name, realcards, skillname, "#steam__duji-use:::" .. card_name, false, true, true)
    end
    -- 展示手牌
    local handcards = target:getCardIds("h")
    target:showCards(handcards)
    
    
    -- 获取基本牌和非基本牌
    local basic_cards = table.filter(handcards, function(cid)
      return Fk:getCardById(cid).type == Card.TypeBasic
    end)
    local non_basic_cards = table.filter(handcards, function(cid)
      return Fk:getCardById(cid).type ~= Card.TypeBasic
    end)    -- 让目标选择选项
    local choices = {}
    if #basic_cards > 0 then
      table.insert(choices, "duji_basic")
    end
    if #non_basic_cards > 0 then
      table.insert(choices, "duji_non_basic")
    end
    
    if #choices == 0 then return end
    
    local choice = room:askForChoice(target, choices, self.name, "#steam__duji-choice")
    
    if choice == "duji_basic" then
      -- 将所有基本牌当一张基本牌使用
     
       local allCardIds = Fk:getAllCardIds()
       local allCardMapper = {}
       local allCardNames = {}
       for _, id in ipairs(allCardIds) do
         local card = Fk:getCardById(id)
         if card.type == Card.TypeBasic then
           if allCardMapper[card.name] == nil then
             table.insert(allCardNames, card.name)
           end
   
           allCardMapper[card.name] = allCardMapper[card.name] or {}
           table.insert(allCardMapper[card.name], id)
         end
       end
       usecardname(allCardNames,target,room,self.name,basic_cards)

   
    else
      -- 将所有非基本牌当一张普通锦囊牌使用
      local allCardIds = Fk:getAllCardIds()
      local allCardMapper = {}
      local allCardNames = {}
      for _, id in ipairs(allCardIds) do
        local card = Fk:getCardById(id)
        if card.type == Card.TypeTrick and card:isCommonTrick() then
          if allCardMapper[card.name] == nil then
            table.insert(allCardNames, card.name)
          end
  
          allCardMapper[card.name] = allCardMapper[card.name] or {}
          table.insert(allCardMapper[card.name], id)
        end
      end

      usecardname(allCardNames,target,room,self.name,non_basic_cards)
     
    end

    -- 如果目标不是自己，自己可以执行另一项
    if target ~= player then
      local phandcards = player:getCardIds("h")
      player:showCards(phandcards)
      
      -- 获取基本牌和非基本牌
      local pb = table.filter(phandcards, function(cid)
        return Fk:getCardById(cid).type == Card.TypeBasic
      end)
      local pnb = table.filter(phandcards, function(cid)
        return Fk:getCardById(cid).type ~= Card.TypeBasic
      end)
      if choice == "duji_basic" and #pb > 0 then
            -- 将所有非基本牌当一张普通锦囊牌使用
            local allCardIds = Fk:getAllCardIds()
            local allCardMapper = {}
            local allCardNames = {}
            for _, id in ipairs(allCardIds) do
              local card = Fk:getCardById(id)
              if card.type == Card.TypeTrick and card:isCommonTrick() then
                if allCardMapper[card.name] == nil then
                  table.insert(allCardNames, card.name)
                end
        
                allCardMapper[card.name] = allCardMapper[card.name] or {}
                table.insert(allCardMapper[card.name], id)
              end
            end
      
            usecardname(allCardNames,player,room,self.name,pnb)
      elseif choice == "duji_non_basic" and #pnb > 0 then
        local allCardIds = Fk:getAllCardIds()
        local allCardMapper = {}
        local allCardNames = {}
        for _, id in ipairs(allCardIds) do
          local card = Fk:getCardById(id)
          if card.type == Card.TypeBasic then
            if allCardMapper[card.name] == nil then
              table.insert(allCardNames, card.name)
            end
    
            allCardMapper[card.name] = allCardMapper[card.name] or {}
            table.insert(allCardMapper[card.name], id)
          end
        end
        usecardname(allCardNames,player,room,self.name,pb)
      end
    end
  end,
}

-- 化烬技能
local huajin = fk.CreateTriggerSkill{
  name = "steam__huajin",
  anim_type = "negative",
  frequency = Skill.Compulsory,
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Finish
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local last_lost = player:getMark("steam__huajin-last_lost")
    local current_hand = #player:getCardIds("h")
    local diff = last_lost - current_hand
    
    if diff ~= 0 then
      if diff > 0 then
        -- 需要摸牌
        player:drawCards(diff, self.name)
      else
        -- 需要弃牌
        local to_discard = room:askForDiscard(player, -diff, -diff, false, self.name, false)
        if #to_discard > 0 then
          room:throwCard(to_discard, self.name, player, player)
        end

      end

    end
    if math.abs(diff) ~= 1 and diff<0 then
      local targets = table.map(room.alive_players, Util.IdMapper)
      local tos = room:askForChoosePlayers(player, targets, 1, 1, "#steam__huajin-damage", self.name, false)
      room:damage {
        from = player, to = room:getPlayerById(tos[1]),
        damage = 1, skillName = self.name, damageType = fk.FireDamage,
      }
    elseif math.abs(diff) ~= 1 and diff>0 then
      room:damage {
        from = player, to = player,
        damage = 1, skillName = self.name, damageType = fk.FireDamage,
      }
    end
  end,
}

-- 记录失去牌数的技能
local huajin_record = fk.CreateTriggerSkill{
  name = "#steam__huajin_record",
  anim_type = "drawcard",
  mute=true,
  frequency = Skill.Compulsory,
  events = {fk.AfterCardsMove},
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(self) then return false end
    for _, move in ipairs(data) do
      if move.from == player.id then
        return true
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local lost = 0
    for _, move in ipairs(data) do
      if move.from == player.id then
       lost=lost+#move.moveInfo
      end
    end
    room:setPlayerMark(player, "steam__huajin-last_lost", lost)

  end,
}

huajin:addRelatedSkill(huajin_record)


xunyu:addSkill(duji)
xunyu:addSkill(huajin)

Fk:loadTranslationTable{
  ["steam_sjx__xunyu"] = "荀彧",
  ["#steam_sjx__xunyu"] = "白头如新",
  ["designer:steam_sjx__xunyu"] = "夜已央",
  
  ["steam1__duji"] = "睹机",
  [":steam1__duji"] = "出牌阶段限一次，你可令一名角色展示手牌并选择一项：1.将所有基本手牌当一张基本牌使用；2.将所有非基本牌当一张普通锦囊牌使用。然后若其不为你，你可执行另一项。",
  ["#steam1__duji"] = "睹机：你可以令一名角色展示手牌并选择一项",
  ["#steam__duji-choice"] = "睹机：请选择一项：将所有基本手牌当一张基本牌使用；将所有非基本牌当一张普通锦囊牌使用",
  ["#steam__duji-basic"] = "睹机：请选择一张基本牌",
  ["#steam__duji-non_basic"] = "睹机：请选择一张普通锦囊牌",
  ["duji_basic"] = "将所有基本手牌当一张基本牌使用",
  ["duji_non_basic"] = "将所有非基本牌当一张普通锦囊牌使用",
  ["#steam__duji-choiceuse"] = "睹机：要视为使用的牌",

  ["#steam__duji-use"] = "睹机：请视为使用【%arg】",
  
  ["steam__huajin"] = "化烬",
  [":steam__huajin"] = "锁定技，结束阶段，你将手牌数调整至你上次失去的牌数，若变化量不为1，你对一名角色造成1点火焰伤害，若你摸牌，改为对自己造成。",
  ["#steam__huajin-damage"] = "化烬：请选择一名角色，对其造成1点火焰伤害",
  ["@steam__huajin-last_lost"] = "化烬",
}

Fk:loadTranslationTable{
  ["$steam1__duji1"] = "因势利导，是为良计。",
  ["$steam1__duji2"] = "狭路相逢，唯勇进得胜，无委曲求全。",
  ["$steam__huajin1"] = "三尺微命，既已许国，难再许公。",
  ["$steam__huajin2"] = "或忠信而死节兮，或訑谩而不疑。",
  ["~steam_sjx__xunyu"] = "谢主隆恩。",
}


--[[
神 王凌 体力4 称号迭浪徙向 设计师BCG
鹜璨
限定技，阶段结束后，你可依次重铸二、四、六、八张牌，第二步后，你可交出所有基本牌，分配一点雷电伤害；第三步后，你可弃置所有装备牌，摸双倍的牌；第四步后，你复原“南启”。
南启
限定技，阶段开始时，你可与所有角色同时选择一项：展示一张基本牌；移动其场上的一张牌；横置；你视为使用被展示最多的基本牌，若无角色因此横置，复原“鹜粲”。
败阶
限定技，出牌阶段，你可摸三张牌并复原“鹜璨”或“南启”，但之描述内最后的技能改为“败阶”。
--]]

return extension
