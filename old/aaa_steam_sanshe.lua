local extension = Package:new("aaa_steam_sanshe")
extension.extensionName = "aaa_steam"

local U = require "packages.utility.utility"

Fk:loadTranslationTable{
  ["aaa_steam_sanshe"] = "散设",
  ["steam_ss"] = "散设",

  ["zhongyangqu_js"] = "<font color='blue'>中央区</font>："..
  "<font color='#808080'>非官方概念</font><br>"..
  "本回合进入弃牌堆的所有牌。",

  ["jishipai_js"] = "<font color='blue'>即时牌</font>："..
  "<font color='#808080'>非官方概念</font><br>"..
  "基本牌与普通锦囊牌。<br>",

}

local guohuai = General:new(extension, "steam_ss__guohuai", "wei", 4)

local jingce = fk.CreateTriggerSkill{
    name = "steam_ss__jingce",
    events = {fk.EventPhaseStart},
    can_trigger = function(self, event, target, player, data)
      return target == player and player.phase == Player.Finish --回合结束
      and #player:getTableMark("steam_ss__jingce-turn") > 0 --中央区需要有牌
    end,
    on_cost = function (self, event, target, player, data)
      local use = U.askForUseVirtualCard(player.room,player,"steam_ss__enemy_at_the_gates",nil,self.name,"#steam_ss__jingce",true,false,false,false,nil,true)
      self.cost_data = {use = use}
      return use ~= nil
    end,
    on_use = function(self, event, target, player, data)
      self.cost_data.use.extra_data = {ids = player:getTableMark("steam_ss__jingce-turn"), toArea = "top"}
      player.room:useCard(self.cost_data.use)
      player.room:setPlayerMark(player,self.name,1)
    end,
  refresh_events = {fk.AfterCardsMove},
  can_refresh = function(self, event, target, player, data)
    if player:hasSkill(self, true) then
      for _, move in ipairs(data) do
        if move.toArea == Card.DiscardPile then
          for _, info in ipairs(move.moveInfo) do
            if table.contains(player.room.discard_pile, info.cardId) then
              return true
            end
          end
        end
        for _, info in ipairs(move.moveInfo) do
          if info.fromArea == Card.DiscardPile and not table.contains(player.room.discard_pile, info.cardId) then
            return true
          end
        end
      end
    end
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    local ids = player:getTableMark("steam_ss__jingce-turn")
    for _, move in ipairs(data) do
      if move.toArea == Card.DiscardPile then
        for _, info in ipairs(move.moveInfo) do
          if table.contains(room.discard_pile, info.cardId) then
            table.insertIfNeed(ids, info.cardId)
          end
        end
      end
      for _, info in ipairs(move.moveInfo) do
        if info.fromArea == Card.DiscardPile and not table.contains(room.discard_pile, info.cardId) then
          table.removeOne(ids, info.cardId)
        end
      end
    end
    room:setPlayerMark(player, "steam_ss__jingce-turn", ids)
  end,
  }

  local jingce_draw = fk.CreateTriggerSkill{
    name = "#steam_ss__jingce_draw",
    frequency = Skill.Compulsory,
    events = {fk.AfterCardsMove},
    can_trigger = function(self, event, target, player, data)
      for _, move in ipairs(data) do
        if move.moveReason == fk.ReasonDraw and 
        (table.find(move.moveInfo,function (info)
            return Fk:getCardById(info.cardId).trueName == "slash"
          end) ~= nil and move.to) then--从牌堆摸到杀
            for _, t in ipairs(player.room:getAlivePlayers()) do
              if t:getMark(jingce.name) > 0 then
                player.room:setPlayerMark(t,jingce.name,0)
                return true
              end
            end
        end
      end
    end,
    on_use = function(self, event, target, player, data)
      player:broadcastSkillInvoke(jingce.name)
      player.room:drawCards(player,3,jingce.name)
    end,
}
jingce:addRelatedSkill(jingce_draw)
guohuai:addSkill(jingce)

Fk:loadTranslationTable{
  ["steam_ss__guohuai"] = "郭淮",--名字
  ["#steam_ss__guohuai"] = "垂问秦雍",--称号
  ["designer:steam_ss__guohuai"] = "坐标系、",--作者
  ["cv:steam_ss__guohuai"] = "官方",--cv
  ["illustrator:steam_ss__guohuai"] = "张帅",--画师
  ["steam_ss__jingce"] = "精策",
  [":steam_ss__jingce"] = "结束阶段，你可以视为使用展示<a href='zhongyangqu_js'>中央区</a>的"..
  "<a href=':steam_ss__enemy_at_the_gates'>【兵临城下】</a>，令下个从牌堆获得【杀】的角色摸三张牌。",

  ["#steam_ss__jingce"] = "你可以视为使用亮出中央区的【兵临城下】",
  
  ["#steam_ss__jingce_draw"] = "精策",
  

  ["$steam_ss__jingce1"] = "方策精详，有备无患。",
  ["$steam_ss__jingce2"] = "精兵据敌，策守如山。",


  ['~steam_ss__guohuai'] = '姜维小儿，竟然……',
}

local caozhang = General:new(extension, "steam_ss__caozhang", "wei", 4)


local jiangchi = fk.CreateTriggerSkill{
    name = "steam_ss__jiangchi",
    mute = true,
    prompt = "#steam_ss__jiangchi",
    events ={fk.EventPhaseStart},
    can_trigger = function(self, event, target ,player, data)
      return player:hasSkill(self) and target == player and player.phase == Player.Start
    end,
    on_cost = function (self, event, target, player, data)
      local room = player.room
      self.cost_data = room:askForChoosePlayers(player,table.map(room:getAlivePlayers(),Util.IdMapper),2,2,"#steam_ss__jiangchi",self.name)
      return #self.cost_data > 0
    end,
    on_use = function(self, event, target, player, data)
      local room = player.room
      for _, t in ipairs(self.cost_data) do
        room:setPlayerMark(room:getPlayerById(t),"@steam_ss__jiangchi-turn","basic")
      end
      
      player:broadcastSkillInvoke(self.name,1)
      room:doIndicate(player.id,self.cost_data)
      room:notifySkillInvoked(player, self.name,nil,self.cost_data)

      if table.contains(self.cost_data,player.id) then
        if room:askForSkillInvoke(player,self.name,nil,"#steam_ss__jiangchi-ask") then
          local u = room:askForUseCard(player,"slash",nil,"#steam_ss__jiangchi_slash",true,{bypass_times = true})
          if u then
            player:broadcastSkillInvoke(self.name,3)
            room:useCard(u)
          else
            player:broadcastSkillInvoke(self.name,2)
            room:drawCards(player,3,self.name)
          end
        end
      end
    end,
  }

  
  local jiangchi_fan = fk.CreateTriggerSkill{
    name = "#steam_ss__jiangchi_fan",
    frequency = Skill.Compulsory,
    anim_type = "negative",
    prompt = "#steam_ss__jiangchi",
    events = {fk.CardUseFinished},
    can_trigger = function(self, event, target, player, data)
      return player == target and player:getMark("@steam_ss__jiangchi-turn") == "basic" and data.card.type == Card.TypeBasic and not player.dead
    end,
    on_use = function(self, event, target, player, data)
      player:turnOver()
    end,
  }

jiangchi:addRelatedSkill(jiangchi_fan)
caozhang:addSkill(jiangchi)

Fk:loadTranslationTable{
  ["steam_ss__caozhang"] = "曹彰",--名字
  ["#steam_ss__caozhang"] = "力鼎千钧",--称号
  ["designer:steam_ss__caozhang"] = "绯红的波罗",--作者
  ["cv:steam_ss__caozhang"] = "官方",--cv
  ["illustrator:steam_ss__caozhang"] = "Yi章",--画师
  ["steam_ss__jiangchi"] = "将驰",
  [":steam_ss__jiangchi"] = "准备阶段，你可以令两名角色本回合使用基本牌后翻面，若包含你，你可以摸三张牌或使用一张【杀】。",
  ["#steam_ss__jiangchi_fan"] = "将驰",

  ["#steam_ss__jiangchi_slash"] = "你可以使用一张【杀】或取消后摸三张牌",
  
  ["@steam_ss__jiangchi-turn"] = "将驰",
  ["#steam_ss__jiangchi"] = "你可以令两名角色本回合使用基本牌后翻面",
  ["#steam_ss__jiangchi-ask"] = "你可以摸三张牌或使用一张【杀】",
  

  ["$steam_ss__jiangchi1"] = "吾定当身先士卒，振魏武雄风！",
  ["$steam_ss__jiangchi2"] = "屯粮坚守，待敌纰漏。",
  ["$steam_ss__jiangchi3"] = "身当矢石，驰骛四方。",

  ['~steam_ss__caozhang'] = '子桓，你害我！',
}

local zhaoyun = General:new(extension, "steam_ss__zhaoyun", "shu", 4)

local longpo_sx = function(player)
  local room = player.room
  local list = player:getTableMark("#steam_ss__longpo-list")
  local d = Fk:translate(player:getMark("#steam_ss__longpo-d"))
  local t = ""
  if #list > 0 then
    for i = 1, #list, 1 do
      local l = Fk:translate(list[i])
      if l == d then
        l = "<font color='red'>"..l.."</font>"
      end
      t = t..l
    end
    room:setPlayerMark(player,"@steam_ss__longpo",t)
  else
    room:setPlayerMark(player,"@steam_ss__longpo",0)
  end
end

local longpo = fk.CreateViewAsSkill{
    name = "steam_ss__longpo",
    pattern = ".|.|.|.|.|basic|.",
    mute = true,
    anim_type = "switch",
    prompt = function(self, cards)
      return "#steam_ss__longpo:::"..Fk:translate(Self:getMark("#steam_ss__longpo-d"))
    end,
    before_use = function (self, player, use)
      local room = player.room
      local list = Self:getTableMark("#steam_ss__longpo-list")--牌名顺序
      local d = player:getMark("#steam_ss__longpo-d")--当前牌名
      for i, v in ipairs({"slash","jink","peach","analeptic"}) do
        if d == v then
          player:broadcastSkillInvoke(self.name,i)
          room:notifySkillInvoked(player, self.name)
          break
         end
      end
      if #list > 1 then--还有下一项
        for i, m in ipairs(list) do
          if m == d then
            room:setPlayerMark(player,"#steam_ss__longpo-d",i == #list and list[1] or list[i+1])--转到下一项，最后一项要转到第一项
          end
        end
      else
        room:setPlayerMark(player,"#steam_ss__longpo-d",0)--没有当前项和下一项清空
      end
      room:drawCards(player,1,self.name)
      room:removeTableMark(player,"#steam_ss__longpo-list",d)--移除当前项
      longpo_sx(player)
    end,
    card_filter = Util.FalseFunc,
    view_as = function(self, cards,player)
      local c = Fk:cloneCard(player:getMark("#steam_ss__longpo-d"))
      c.skillName = self.name
      return c
    end,
    enabled_at_response = function (self,player,response)
      return player:getMark("#steam_ss__longpo-d") ~= 0
    end,
    enabled_at_play = function (self,player)
      return player:getMark("#steam_ss__longpo-d") ~= 0
    end,
    on_acquire =function (self, player, is_start)
      player.room:addTableMark(player,"#steam_ss__longpo-list", "slash")
      player.room:addTableMark(player,"#steam_ss__longpo-list", "jink")
      player.room:addTableMark(player,"#steam_ss__longpo-list", "peach")
      player.room:addTableMark(player,"#steam_ss__longpo-list", "analeptic")
      player.room:setPlayerMark(player,"#steam_ss__longpo-d", "slash")
      longpo_sx(player)
    end,
    on_lose = function (self, player, is_death)
      player.room:setPlayerMark(player,"#steam_ss__longpo-list", 0)
      player.room:setPlayerMark(player,"#steam_ss__longpo-d", 0)
      player.room:setPlayerMark(player,"@steam_ss__longpo", 0)
    end
  }
local youqiang = fk.CreateTriggerSkill{
  name = "steam_ss__youqiang",
  mute = true,
  events = {fk.AfterCardsMove},
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(self) then return false end--来自薛灵芸
    local room = player.room
    local move_event = room.logic:getCurrentEvent()--当前时机
    local parent_event = move_event.parent--当前时机的父级时机
    local card_ids = {}
    local cards = {}
    if parent_event ~= nil then
      if parent_event.event == GameEvent.UseCard or parent_event.event == GameEvent.RespondCard then
        local parent_data = parent_event.data[1]--使用或打出
        if parent_data.from == player.id then
          card_ids = room:getSubcardsByRule(parent_data.card)
        end
      elseif parent_event.event == GameEvent.Pindian then--拼点
        local pindianData = parent_event.data[1]
        if pindianData.from == player then
          card_ids = room:getSubcardsByRule(pindianData.fromCard)
        else
          for toId, result in pairs(pindianData.results) do
            if player.id == toId then
              card_ids = room:getSubcardsByRule(result.toCard)
              break
            end
          end
        end
      end
    end
    for _, move in ipairs(data) do
      if move.toArea == Card.DiscardPile then--进入弃牌堆
        if move.from == player.id then--自己弃的
          for _, info in ipairs(move.moveInfo) do
            if (info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip) and
            Fk:getCardById(info.cardId).type == Card.TypeBasic then
              table.insert(cards, info.cardId)
            end
          end
        elseif #card_ids > 0 then--使用或其他情况
          for _, info in ipairs(move.moveInfo) do
            if info.fromArea == Card.Processing and table.contains(card_ids, info.cardId) and
            Fk:getCardById(info.cardId).type == Card.TypeBasic then
              table.insert(cards, info.cardId)
            end
          end
        end
      end
    end
    if #cards > 0 then
      self.cost_data = cards
      return true
    end
  end,
  on_cost = function (self, event, target, player, data)
    local j,t = {},{}
    local all = self.cost_data
    for _, v in ipairs(all) do
      local c = Fk:getCardById(v).trueName
      if not table.contains(player:getTableMark("#steam_ss__longpo-list"),c) and
      not table.contains(t,c) then--龙魄没有这个牌名且没有被添加
        table.insert(t,c)
      elseif c ~= player:getMark("#steam_ss__longpo-d") and not table.contains(j,c) then
          table.insert(j,c)--与当前不同的项且没有被添加
      end
    end
    self.cost_data = {t,j,all}
    return #t > 0 or #j > 0--有牌名可以添加或者可以调整至与当前项不同
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local t = self.cost_data[1]
    local j = self.cost_data[2]
    local g = false
    for i = 1, #self.cost_data[1], 1 do
      local choice = room:askForChoice(player, t, self.name,"#steam_ss__youqiang-tj")--询问添加牌名
      room:addTableMark(player,"#steam_ss__longpo-list", choice)
      table.removeOne(t,choice)
      g = #player:getTableMark("#steam_ss__longpo-list") == 1
      if g then--选项从0到1设置当前项
        room:setPlayerMark(player,"#steam_ss__longpo-d",choice)
      end
      longpo_sx(player)--播放语音
      player:broadcastSkillInvoke(self.name)
      room:notifySkillInvoked(player, self.name)
    end
    if g then--由于当前项更改，更新新的调整列表，和cost一致
      local y,u = {},{}
      for _, v in ipairs(self.cost_data[3]) do
        local c = Fk:getCardById(v).trueName
        if not table.contains(player:getTableMark("#steam_ss__longpo-list"),c) and
        not table.contains(y,c) then--龙魄没有这个牌名且没有被添加
          table.insert(y,c)
        elseif c ~= player:getMark("#steam_ss__longpo-d") and not table.contains(u,c) then
            table.insert(u,c)--与当前不同的项且没有被添加
        end
      end
      j = u
    end

    if #j > 0 then
      table.insert(j,"Cancel")
      local choice = room:askForChoice(player, j, self.name,"#steam_ss__youqiang-tz")--询问调整牌名
      if choice ~= "Cancel" then
        room:setPlayerMark(player,"#steam_ss__longpo-d", choice)
        longpo_sx(player)
        player:broadcastSkillInvoke(self.name)
        room:notifySkillInvoked(player, self.name)
      end
    end
  end,
}
zhaoyun:addSkill(longpo)
zhaoyun:addSkill(youqiang)


Fk:loadTranslationTable{
  ["steam_ss__zhaoyun"] = "赵云",--名字
  ["#steam_ss__zhaoyun"] = "纵横九寰",--称号
  ["designer:steam_ss__zhaoyun"] = "俗河",--作者
  ["cv:steam_ss__zhaoyun"] = "官方",--cv
  ["illustrator:steam_ss__zhaoyun"] = "凡果_Make",--画师
  ["steam_ss__longpo"] = "龙魄",
  [":steam_ss__longpo"] = "<b>转换技</b>，你可以视为使用或打出一张①【杀】；②【闪】；③【桃】；④【酒】，然后你摸一张牌并移除此项。",
  ["steam_ss__youqiang"] = "游枪",
  [":steam_ss__youqiang"] = "你的基本牌进入弃牌堆后，若“<b>龙魄</b>”包含此牌名，你可以将“<b>龙魄</b>”调整至对应项；否则将之加入“<b>龙魄</b>”末项。",


  ["#steam_ss__longpo"] = "你可以视为使用或打出一张【%arg】",
  
  ["#steam_ss__longpo-d"] = "龙魄",
  ["#steam_ss__longpo-list"] = "龙魄顺序",
  ["@steam_ss__longpo"] = "龙魄",
  ["#steam_ss__youqiang-tj"] = "请选择一项加入“<b>龙魄</b>”末项",
  ["#steam_ss__youqiang-tz"] = "你可以将“<b>龙魄</b>”转换至",
  

  ["$steam_ss__longpo1"] = "千里一怒，红莲灿世。",
  ["$steam_ss__longpo2"] = "腾龙行云，首尾不见。",
  ["$steam_ss__longpo3"] = "金甲映日，驱邪祛秽。",
  ["$steam_ss__longpo4"] = "潜龙于渊，涉灵愈伤。",
  ["$steam_ss__youqiang1"] = "龙战于野，其血玄黄。",
  ["$steam_ss__youqiang2"] = "潜龙勿用，藏锋守拙。",


  ['~steam_ss__zhaoyun'] = '你们谁…还敢再上……',
}

local huangzhong = General:new(extension, "steam_ss__huangzhong", "shu", 4)

 local tuigong = fk.CreateActiveSkill{
   name = "steam_ss__tuigong",
   prompt = "#steam_ss__tuigong",
   interaction = function()
    return UI.Spin {
      from = 1,
      to = 5,
      default = 1
    }
  end,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) < 1
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    room:setPlayerMark(player, "@steam_ss__tuigong", self.interaction.data)
  end,
 }

--修改这个方法，获取除调用方法以外的所有范围技能，达到令攻击范围不受装备，技能的影响(既锁定攻击范围)
  --- 获取玩家攻击范围。
---@return integer
local getAttackRange_suoding = function (player,self)
  local baseValue = 1

  local weapons = table.filter(player:getEquipments(Card.SubtypeWeapon), function (id)
    local weapon = Fk:getCardById(id) ---@class Weapon
    return weapon:AvailableAttackRange(player)
  end)
  if #weapons > 0 then
    baseValue = 0
    for _, id in ipairs(weapons) do
      local weapon = Fk:getCardById(id) ---@class Weapon
      baseValue = math.max(baseValue, weapon:getAttackRange(player) or 1)
    end
  end

  local status_skills = Fk:currentRoom().status_skills[AttackRangeSkill] or Util.DummyTable ---@type AttackRangeSkill[]
  local max_fixed, correct = nil, 0
  for i, skill in ipairs(status_skills) do
    if skill ~= self then --仅增加这一句代码，避免递归
      local f = skill:getFixed(player)
      if f ~= nil then
        max_fixed = max_fixed and math.max(max_fixed, f) or f
      end
      local c = skill:getCorrect(player)
      correct = correct + (c or 0)
    end
  end

  return math.max(math.max(baseValue, (max_fixed or 0)) + correct, 0)
end
local tuigong_attackrange = fk.CreateAttackRangeSkill{--没法在这里实时获取攻击距离，既这是攻击范围计算的一部分，尝试运算会递归
name = "#tuigong_attackrange",
correct_func = function (self, from, to)
  if from:getMark("@steam_ss__tuigong") > 0 then
    local num = - getAttackRange_suoding(from,self) --获取玩家攻击范围，转为负值后用于归0
    return num + from:getMark("@steam_ss__tuigong") --将所有除本技能以外的所有影响范围的因素计算后归0，再设置为推弓的数量
  end
end,
}


local qiangji = fk.CreateTriggerSkill{
  name = "steam_ss__qiangji",
  mute = true,
  anim_type = "offensive",
  frequency = Skill.Compulsory,--锁定技
  events = {fk.DamageCaused,fk.CardUsing},
  can_trigger = function(self, event, target, player, data)
   return target == player and player:hasSkill(self)
  end,
  on_cost = function(self, event, target, player, data)
    if data.to == player then return false end
    if event == fk.CardUsing and (data.card.trueName == "slash" or data.card:isCommonTrick()) then
      for i = 1, player:getAttackRange(), 1 do--从1开始找距离最近的角色列表
        local targets = table.filter(player.room:getOtherPlayers(player), function(p)
          return player:distanceTo(p) == i
        end)
        if #targets > 0 then
          self.cost_data = targets
          return true
        end
      end
    else
      for i = player:getAttackRange(), 1, -1 do--从最远距离找到人为止，看看这个目标在不在其中
        local targets = table.filter(player.room:getOtherPlayers(player), function(p)
          return player:distanceTo(p) == i
        end)
        if #targets > 0 then
          return table.find(targets,function (t) return t == data.to end)
        end
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    if event == fk.CardUsing then
      data.disresponsiveList = data.disresponsiveList or {}
      for _, p in ipairs(self.cost_data) do
        table.insertIfNeed(data.disresponsiveList, p.id)
      end
      player.room:notifySkillInvoked(player,self.name,nil,table.map(self.cost_data,Util.IdMapper))
      player:broadcastSkillInvoke(self.name,1)
    else
      data.damage = data.damage + 1
      player.room:doIndicate(player.id,{data.to.id})
      player.room:notifySkillInvoked(player,self.name,nil,{data.to.id})
      player:broadcastSkillInvoke(self.name,2)
    end
  end,
}



tuigong:addRelatedSkill(tuigong_attackrange)
huangzhong:addSkill(tuigong)
huangzhong:addSkill(qiangji)

Fk:loadTranslationTable{
  ["steam_ss__huangzhong"] = "黄忠",--名字
  ["#steam_ss__huangzhong"] = "矢贯金石",--称号
  ["designer:steam_ss__huangzhong"] = "RIN",--作者
  ["cv:steam_ss__huangzhong"] = "官方",--cv
  ["illustrator:steam_ss__huangzhong"] = "巴萨小马",--画师
  ["steam_ss__tuigong"] = "推弓",
  [":steam_ss__tuigong"] = "出牌阶段限一次，你可以将攻击范围调整至1~5。",
  ["steam_ss__qiangji"] = "强击",
  [":steam_ss__qiangji"] = "<b>锁定技</b>，攻击范围内最近的角色不能响应你的牌，你对攻击范围内最远的角色造成的伤害+1。",

  ["#steam_ss__tuigong"] = "你可以将攻击范围调整至1~5",

  ["@steam_ss__tuigong"] = "推弓",

  ["$steam_ss__tuigong1"] = "箭阵开道，所向披靡！",
  ["$steam_ss__tuigong2"] = "哪里逃，看箭！",
  ["$steam_ss__qiangji1"] = "穿杨射柳，百发百中！",
  ["$steam_ss__qiangji2"] = "烈弓之下，片甲不存！",

  ['~steam_ss__huangzhong'] = '呃，弦，断了。',
}



local zhuji = General:new(extension, "steam_ss__zhuji", "wu", 4)
local xushi = fk.CreateActiveSkill{
  name = "steam_ss__xushi",
  mute = true,
  anim_type = "control",
  prompt = "#steam_ss__xushi",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) < 1
  end,
  card_filter = Util.FalseFunc,
  target_filter = Util.FalseFunc,
  on_use = function(self, room, Effect)
    local player = room:getPlayerById(Effect.from)
    player:broadcastSkillInvoke(self.name,2)
    room:notifySkillInvoked(player, self.name)
    local cards = room:getNCards(3)
    room:moveCardTo(cards, Card.Processing, nil, fk.ReasonJustMove, self.name, nil, true, player.id)
    room:delay(#cards * 150)
    local x = room:askForUseRealCard(player,cards,self.name,nil,{expand_pile = cards},true,true)
    if x ~= nil then
      local n = player:getMark("@steam_ss__xushi")
      if x.card.is_damage_card and n > 0 then
        room:setPlayerMark(player,"@steam_ss__xushi",0)
        player:broadcastSkillInvoke(self.name,3)
        room:notifySkillInvoked(player, self.name,"offensive")
        x.additionalDamage = (x.additionalDamage or 0) + n
      end
      room:useCard(x)
    end
    if x == nil or not x.card.is_damage_card then--没用伤害牌
      player:broadcastSkillInvoke(self.name,1)
      room:addPlayerMark(player,"@steam_ss__xushi",1)
    end

    cards = table.filter(cards, function(id) return room:getCardArea(id) == Card.Processing end)
    room:moveCardTo(table.reverse(cards), Card.DrawPile, nil, fk.ReasonPut, self.name, nil, true, player.id)
  end,
}

zhuji:addSkill(xushi)

Fk:loadTranslationTable{
  ["steam_ss__zhuji"] = "朱绩",--名字
  ["#steam_ss__zhuji"] = "克绍堂构",--称号
  ["designer:steam_ss__zhuji"] = "RIN",--作者
  ["cv:steam_ss__zhuji"] = "官方",--cv
  ["illustrator:steam_ss__zhuji"] = "官方",--画师
  ["steam_ss__xushi"] = "蓄势",
  [":steam_ss__xushi"] = "出牌阶段限一次，你可以展示牌堆顶的三张牌，然后你可以使用其中一张牌，若为伤害牌，此牌伤害+X并重置X。（X为你以此法未使用伤害牌的次数）",

  ["@steam_ss__xushi"] = "蓄势",
  
  ["#steam_ss__xushi"] = "你可以展示牌堆顶的三张牌，然后你可以使用其中一张牌",
  ["$steam_ss__xushi1"] = "蓄力待时，不争首功。",
  ["$steam_ss__xushi2"] = "洞若观火，运筹帷幄。",
  ["$steam_ss__xushi3"] = "时机已到，全军出击！",

  ["~steam_ss__zhuji"] = '以后……就交给年轻人了……',
}


local lvmeng = General:new(extension, "steam_ss__lvmeng", "wu", 4)
local keji = fk.CreateActiveSkill{
  name = "steam_ss__keji",
  prompt = "#steam_ss__keji",
  anim_type = "drawcard",
  min_card_num = 1,
  target_filter = Util.FalseFunc,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) < 1 and not player:isKongcheng()
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    room:recastCard(effect.cards, player, self.name)
    for _, i in ipairs(effect.cards) do
      local c = Fk:getCardById(i)
      if c.trueName == "slash" or c.name == "analeptic" then
        room:drawCards(player,1,self.name)
        break
      end
    end
  end,
}

local tanhu = fk.CreateActiveSkill{
  name = "steam_ss__tanhu",
  anim_type = "control",
  prompt = "#steam_ss__tanhu",
  target_num = 1,
  card_num = 0,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, to_select, selected, _, _, _, player)
    return #selected == 0 and to_select ~= player.id and not Fk:currentRoom():getPlayerById(to_select):isKongcheng()
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    local cards = target.player_cards[Player.Hand]
    local hearts = table.filter(cards, function (id) return Fk:getCardById(id).name == "snatch" end)
    U.viewCards(player, cards, self.name, "#steam_ss__tanhu-view::"..target.id)
    if #hearts > 0 then
      room:throwCard(hearts, self.name, target, player)
    end
  end,
}

local function extractBracketContents(text, openBracket, closeBracket)
  local result = {}
  local startPos = 1
  local openPos, closePos

  while true do
      openPos = string.find(text, openBracket, startPos)
      if not openPos then break end

      closePos = string.find(text, closeBracket, openPos + #openBracket)
      if not closePos then break end

      local content = string.sub(text, openPos + #openBracket, closePos - 1)
      table.insert(result, content)

      startPos = closePos + #closeBracket
  end

  return result
end--寻找文本的函数


local duxi = fk.CreateTriggerSkill{
  name = "steam_ss__duxi",
  anim_type = "special",
  prompt = "#steam_ss__duxi",
  frequency = Skill.Limited,
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and target.phase == Player.Finish and
    player:usedSkillTimes(self.name, Player.HistoryGame) == 0 and
    player:usedCardTimes("slash") == 0 and #player:getTableMark("@steam_ss__duxi-turn") == 4
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    room:delay(800)
    local skills = table.filter(player.player_skills, function(s) return not s:isEquipmentSkill(player) end)
    --过滤装备的技能
    local cardName = {}
    for i, s in ipairs(skills) do
      local n = extractBracketContents(Fk:translate(":"..s.name),"【", "】")
      for j, cn in ipairs(n) do
        table.insert(cardName,cn)
        for _, v in ipairs(Fk.all_card_names) do --翻译表没法从译文转原文，暂时用所有牌堆检索
          if Fk:translate(v) == cn and Fk:cloneCard(v).type ~= Card.TypeEquip then
            if i > 1 or j > 1 then player:broadcastSkillInvoke(self.name) end
            U.askForUseVirtualCard(room,player,v,nil,self.name)
          end
        end
      end
    end
  end,
  refresh_events = {fk.AfterCardsMove},
  can_refresh = function(self, event, target, player, data)
    if player:hasSkill(self, true) and player:usedSkillTimes(self.name, Player.HistoryGame) == 0 then--限定技发动后不记录
      for _, move in ipairs(data) do
        if move.toArea == Card.DiscardPile then
          for _, info in ipairs(move.moveInfo) do
            if table.contains(player.room.discard_pile, info.cardId) then
              return true
            end
          end
        end
        for _, info in ipairs(move.moveInfo) do
          if info.fromArea == Card.DiscardPile and not table.contains(player.room.discard_pile, info.cardId) then
            return true
          end
        end
      end
    end
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    local ids = player:getTableMark("steam_ss__duxi-turn")
    for _, move in ipairs(data) do
      if move.toArea == Card.DiscardPile then
        for _, info in ipairs(move.moveInfo) do
          if table.contains(room.discard_pile, info.cardId) then
            table.insertIfNeed(ids, info.cardId)
          end
        end
      end
      for _, info in ipairs(move.moveInfo) do
        if info.fromArea == Card.DiscardPile and not table.contains(room.discard_pile, info.cardId) then
          table.removeOne(ids, info.cardId)
        end
      end
    end
    room:setPlayerMark(player, "steam_ss__duxi-turn", ids)
    for _, v in ipairs(player:getTableMark("steam_ss__duxi-turn")) do--添加花色
      local suit = Fk:getCardById(v):getSuitString(true)
      if not table.contains(player:getTableMark("@steam_ss__duxi-turn"), suit) then
        player.room:addTableMark(player, "@steam_ss__duxi-turn", suit)
      end
    end
  end,
}


lvmeng:addSkill(keji)
lvmeng:addSkill(tanhu)
lvmeng:addSkill(duxi)

Fk:loadTranslationTable{
  ["steam_ss__lvmeng"] = "吕蒙",--名字
  ["#steam_ss__lvmeng"] = "国士之风",--称号
  ["designer:steam_ss__lvmeng"] = "RIN",--作者
  ["cv:steam_ss__lvmeng"] = "官方",--cv
  ["illustrator:steam_ss__lvmeng"] = "玖等仁品",--画师
  ["steam_ss__keji"] = "克己",
  [":steam_ss__keji"] = "出牌阶段限一次，你可以重铸任意张牌，若其中有【杀】或【酒】，你摸一张牌。",
  ["steam_ss__tanhu"] = "探虎",
  [":steam_ss__tanhu"] = "出牌阶段限一次，你可以观看一名其他角色的手牌并弃置其中的【顺手牵羊】。",
  ["steam_ss__duxi"] = "渡袭",
  [":steam_ss__duxi"] = "<b>限定技</b>，每回合结束时，若你本回合未使用过【杀】且<a href='zhongyangqu_js'>中央区</a>的牌包含四种花色，你可以依次视为使用你技能描述中包含的牌名。",

  ["#steam_ss__keji"] = "你可以重铸任意张牌",
  ["#steam_ss__tanhu"] = "你可以观看一名其他角色的手牌",
  ["#steam_ss__tanhu-view"] = "探虎：观看%dest的手牌",
  ["#steam_ss__duxi"] = "你可以依次视为使用你技能中包含的牌名",
  ["@steam_ss__duxi-turn"] = "渡袭",

  ["$steam_ss__keji1"] = "任其妄为无所动，守得云开见月明。",
  ["$steam_ss__keji2"] = "任凭风浪起，稳坐钓鱼船。",
  ["$steam_ss__tanhu1"] = "此速攻可胜，切莫筑室道谋！",
  ["$steam_ss__tanhu2"] = "生死存亡之道，不可不察！",
  ["$steam_ss__duxi1"] = "今日起兵，渡江攻敌！",
  ["$steam_ss__duxi2"] = "时机已到，全军出击！",

  ["~steam_ss__lvmeng"] = '不求富贵来，只愿故土安。',
}

local sunquan = General:new(extension, "steam_ss__sunquan", "wu", 4)

local zhiheng = fk.CreateViewAsSkill{
  name = "steam_ss__zhiheng",
  anim_type = "drawcard",
  prompt = "#steam_ss__zhiheng",
  pattern = "bogus_flower",
  card_filter = function(self, to_select, selected)
    if #selected == 1 then return false end
    return true
  end,
  view_as = function(self, cards)
    if #cards ~= 1 then
      return nil
    end
    local c = Fk:cloneCard("bogus_flower")
    c.skillName = self.name
    c:addSubcard(cards[1])
    return c
  end,
  after_use = function (self, player, use)
    local red , black = 0,0
    for _, c in ipairs(player:getCardIds("h")) do
      local card = Fk:getCardById(c)
      if card.color == Card.Black then black = black + 1
      elseif card.color == Card.Red then red = red + 1 end
    end
    if red == black then
      player.room:drawCards(player,1,self.name)
      player:broadcastSkillInvoke(self.name)
    end
  end,
}


sunquan:addSkill(zhiheng)



Fk:loadTranslationTable{
   ["steam_ss__sunquan"] = "孙权",--名字
   ["#steam_ss__sunquan"] = "永开吴祚",--称号
   ["designer:steam_ss__sunquan"] = "阿鸡",--作者
   ["cv:steam_ss__sunquan"] = "官方",--cv
   ["illustrator:steam_ss__sunquan"] = "陈层",--画师
   ["steam_ss__zhiheng"] = "制衡",
   [":steam_ss__zhiheng"] = "你可以将一张牌当<a href=':bogus_flower'>【树上开花】</a>使用，结算后若你的红色手牌与黑色手牌数量相等，你摸一张牌。",

   ["#steam_ss__zhiheng"] = "你可以将一张牌当【树上开花】使用",
 
   ["$steam_ss__zhiheng1"] = "三思而行，游刃有余。",
   ["$steam_ss__zhiheng2"] = "制衡联合，稳而不乱。",

   ['~steam_ss__sunquan'] = '哥哥，汝之所托我尽力了。',
 }

local lvyi = General:new(extension, "steam_ss__lvyi", "wu", 4)

 local shiquan = fk.CreateTriggerSkill{
  name = "steam_ss__shiquan",
  frequency = Skill.Compulsory,--锁定技
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Play
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:loseHp(player,1,self.name)
    if not player.dead then
        room:drawCards(player,player.hp,self.name)
        for _, p in ipairs(room:getOtherPlayers(player, false)) do
            if p:getHandcardNum() > player:getHandcardNum() then--不是最大直接返回
                return
            end
        end
        room:recover({who = player,num = 1,recoverBy = player,skillName = self.name})
    end
  end,
}


local banghui = fk.CreateActiveSkill{
    name = "steam_ss__banghui",
    prompt = "#steam_ss__banghui",
    can_use = function(self, player)
       return player:usedSkillTimes(self.name, Player.HistoryPhase) < 1
    end,
    card_filter = Util.FalseFunc,
    target_filter = function(self, to_select, selected)
     return #selected == 0
    end,
    target_num = 1,
    on_use = function(self, room, effect)
      local player = room:getPlayerById(effect.from)
      local target = room:getPlayerById(effect.tos[1])
      local ask = {"steam_ss__banghui_sh"}
      if #target:getCardIds("he") > 1 then
        ask = {"steam_ss__banghui_sh","steam_ss__banghui_qi", "steam_ss__banghui_bs:"..player.id}
      end
      local choice = room:askForChoice(target, ask, self.name)
      if choice:startsWith("steam_ss__banghui_bs") then
        room:addPlayerMark(player,"@steam_ss__banghui")
      end
      if choice ~= "steam_ss__banghui_qi" then
        room:damage({to = target, damage = 1, skillName = self.name})
      end
      if choice ~= "steam_ss__banghui_sh" then
        room:askForDiscard(target,2,2,true,self.name,false)
      end
    end,
  }
local qingsha = fk.CreateTriggerSkill{
  name = "steam_ss__qingsha",
  frequency = Skill.Compulsory,--锁定技
  events = {fk.HpChanged},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self.name) and target == player and
    player:getMark("@steam_ss__banghui") > player.hp and --标记大于体力
    player:getMark("@steam_ss__banghui") > 0 --必须有标记
  end,
  on_cost = function(self, event, target, player, data)
    player.room:setPlayerMark(player,"@steam_ss__banghui",0)
    return true
  end,
  on_use = function(self, event, target, player, data)
    player.room:damage({to = player, damage = 2, skillName = self.name})
  end,
}

lvyi:addSkill(shiquan)
lvyi:addSkill(banghui)
lvyi:addSkill(qingsha)

Fk:loadTranslationTable{
  ["steam_ss__lvyi"] = "吕壹",--名字
  ["#steam_ss__lvyi"] = "以权倾覆",--称号
  ["designer:steam_ss__lvyi"] = "youfan",--作者
  ["cv:steam_ss__lvyi"] = "官方",--cv
  ["illustrator:steam_ss__lvyi"] = "官方",--画师
  ["steam_ss__shiquan"] = "恃权",
  [":steam_ss__shiquan"] = "<b>锁定技</b>，出牌阶段开始时，你失去1点体力并摸X张牌。然后若你的手牌数为全场最多，你回复1点体力。（X为你的体力值）",
  ["steam_ss__banghui"] = "谤毁",
  [":steam_ss__banghui"] = "出牌阶段限一次，你可令一名角色选择受到1点无来源伤害或弃置两张牌。<br>背水：令你获得1个“非”。",
  ["steam_ss__qingsha"] = "倾厦",
  [":steam_ss__qingsha"] = "<b>锁定技</b>，当你的体力值变化后，若“非”的数量大于你的体力值，你移除所有“非”并受到2点无来源伤害。",

  ["steam_ss__banghui_sh"] = "受到1点无来源伤害",
  ["steam_ss__banghui_qi"] = "弃置两张牌",
  ["steam_ss__banghui_bs"] = "背水：令%src获得1个“非”",
  ["#steam_ss__banghui"] = "谤毁：你可令一名角色选择受到伤害或弃置牌，其可以背水后令你获得1个“非”",

  ["@steam_ss__banghui"] = "非",
  
  ["$steam_ss__shiquan1"] = "众人与蝼蚁何异？哈哈哈……",
  ["$steam_ss__shiquan2"] = "哼，树敌三千又如何？",
  ["$steam_ss__banghui1"] = "殿堂之间，皆为不忠之贼！",
  ["$steam_ss__banghui2"] = "玉陛之下，尽是叛逆之臣！",
  ["$steam_ss__qingsha1"] = "这是要我命归黄泉吗？",
  ["$steam_ss__qingsha2"] = "命啊！命！",

  ['~steam_ss__lvyi'] = '假的······都是假的',
}



local yanliangwenchou = General:new(extension, "steam_ss__yanliangwenchou", "qun", 4)

 local shuangxiong = fk.CreateTriggerSkill{--利用队友列表实现手牌始终明置的效果
  name = "steam_ss__shuangxiong",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Play--出牌开始
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askForSkillInvoke(player,self.name)
  end,
  on_use = function(self, event, target, player, data)
    for _, p in ipairs(player.room:getOtherPlayers(player, false)) do
     if table.find(p.buddy_list,function (t) return t == player.id end) == nil then
      p:addBuddy(player)
      player.room:addTableMark(player, self.name, p.id)
     end
    end
  end,
  on_lose = function (self, player)
    for _, p in ipairs(player:getTableMark(self.name)) do
      player.room:getPlayerById(p):removeBuddy(player)
     end
    player.room:setPlayerMark(player, self.name, 0)
  end,
}

local shuangxiong_js = fk.CreateTriggerSkill{--把不是真的队友移出队友列表
  name = "#steam_ss__shuangxiong_js",
  mute = true,
  frequency = Skill.Compulsory,--锁定技
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player.phase == Player.Finish and 
    #player:getTableMark(shuangxiong.name) > 0--回合结束
  end,
  on_use = function(self, event, target, player, data)
    for _, p in ipairs(player:getTableMark(shuangxiong.name)) do
      player.room:getPlayerById(p):removeBuddy(player)
    end
    player.room:setPlayerMark(player, self.name, 0)
  end,
}
local shuangxiong_filter = fk.CreateFilterSkill{
  name = "#steam_ss__shuangxiong_filter",
  anim_type = "offensive",
  card_filter = function(self, card, player)
    if player.phase ~= Player.NotActive and player:usedSkillTimes(shuangxiong.name) > 0 and
    table.contains(player.player_cards[Player.Hand], card.id) then
      local red , black = 0,0
      for _, c in ipairs(player.getCardIds(player,Player.Hand)) do
        if Fk:getCardById(c).color == Card.Black then black = black + 1 end
        if Fk:getCardById(c).color == Card.Red then red = red + 1 end
      end
      if red == black then return false end
      if red < black then
        return card.color == Card.Black
      else
        return card.color == Card.Red
      end
    end
  end,
  view_as = function(self, card, player)
    local c = Fk:cloneCard("duel", card.suit, card.number)
    c.skillName = shuangxiong.name
    return c
  end,
}
local shuangxiong_yy = fk.CreateTriggerSkill{--专为语音做个技能
  name = "#steam_ss__shuangxiong_yy",
  mute = true,
  frequency = Skill.Compulsory,--锁定技
  events = {fk.PreCardUse},
  can_trigger = function(self, event, target, player, data)
    return target == player and 
    table.contains(data.card.skillNames, shuangxiong.name)
  end,
  on_use = function(self, event, target, player, data)
    player:broadcastSkillInvoke(shuangxiong.name)
  end,
}--]]

shuangxiong:addRelatedSkill(shuangxiong_yy)
shuangxiong:addRelatedSkill(shuangxiong_filter)
shuangxiong:addRelatedSkill(shuangxiong_js)
yanliangwenchou:addSkill(shuangxiong)
Fk:loadTranslationTable{
  ["steam_ss__yanliangwenchou"] = "颜良文丑",--名字
  ["#steam_ss__yanliangwenchou"] = "狼豹棠棣",--称号
  ["designer:steam_ss__yanliangwenchou"] = "青梅煮酒",--作者
  ["cv:steam_ss__yanliangwenchou"] = "官方",--cv
  ["illustrator:steam_ss__yanliangwenchou"] = "KayaK",--画师
  ["steam_ss__shuangxiong"] = "双雄",
  [":steam_ss__shuangxiong"] = "出牌阶段开始时，你可令你本回合明置手牌且其中唯一最多颜色的牌视为【决斗】。",

  ["#steam_ss__shuangxiong_js"] = "双雄",
  ["#steam_ss__shuangxiong_filter"] = "双雄",
  ["#steam_ss__shuangxiong_yy"] = "双雄",
  
  ["$steam_ss__shuangxiong1"] = "哥哥，且看我与赵云一战！/且与他战个五十回合！",
  ["$steam_ss__shuangxiong2"] = "此战，如有你我一人在此，何惧华雄！/定叫他有去无回！",

  ['~steam_ss__yanliangwenchou'] = '吾等是太轻敌了...',
}



local jiaxu = General:new(extension, "steam_ss__jiaxu", "qun", 3)

local weimu = fk.CreateTriggerSkill{
  name = "steam_ss__weimu",
  events = {fk.CardUsing},
  mute = true,
  can_trigger = function(self, event, target, player, data)
    local targets = TargetGroup:getRealTargets(data.tos)
    return player:hasSkill(self) and data.from ~= player.id and --自己不是使用者
    (table.find(targets,function (id) return id == player.id end) or--成为目标
    player.phase ~= Player.NotActive) and --回合内
    (data.card.type == Card.TypeBasic or (data.card.type == Card.TypeTrick and data.card.sub_type ~= Card.SubtypeDelayedTrick))--即时牌
  end,
  on_cost = function(self, event, target, player, data)
    local g = table.filter(player:getAllSkills(),function (s)
      return string.find(s.name,"steam_ss__guimou__") ~= nil --拥有的鬼谋技能
    end)
    local nokong = table.filter(g,function (m)--不空的
      return table.contains(player:getMarkNames(), m.name)
    end)
    self.cost_data = {g,nokong}
    return #nokong < #g and--不为空的鬼谋数量小于总鬼谋数量就代表有空的鬼谋
      player.room:askForSkillInvoke(player,self.name,nil,"#steam_ss__weimu-ask:::"..Fk:translate(data.card.name))
  end,
  on_use = function(self, event, target, player, data)
    player.room:doIndicate(player.id,{data.from})
    player:broadcastSkillInvoke(self.name,math.random(1,2) + (player.phase ~= Player.NotActive and 2 or 0))
    local all,kong = {},{}
    for _, v in ipairs(self.cost_data[1]) do
      table.insert(all,v.name)
      if not table.contains(self.cost_data[2], v) then--排除不为空的鬼谋
        table.insert(kong,v.name)
      end
    end
    local ask = player.room:askForChoice(player,kong,self.name,"#steam_ss__weimu:::"..Fk:translate(data.card.name),nil,all)
    player.room:setPlayerMark(player,ask,data.card.name)
    data.toCard = nil--牌失效
    data.tos = {}
  end,
}

for i = 1, 9, 1 do
  Fk:loadTranslationTable{
    ["steam_ss__guimou__"..i] = "鬼谋",
    [":steam_ss__guimou__"..i] = "",
  }
   local g = fk.CreateViewAsSkill{
    name = "steam_ss__guimou__"..i,--技能名就是标记名，标记内容是记录的牌名
    frequency = Skill.Limited,
    mute = true,
    pattern = ".",
    dynamic_desc = function(self, player)--技能描述
      if player:getMark(self.name) ~= 0 then
        --return Fk:translate("steam_ss__guimou_dest:"..Fk:translate(player:getMark(self.name)))
        if player:usedSkillTimes(self.name,Player.HistoryGame) == 0 then--用红色标明没发动过，找不到上一行不能获取牌名的原因，明明和下面的prompt一样
          return "<b>限定技</b>，你可以视为使用或打出一张<br><font color='red'>【"..Fk:translate(player:getMark(self.name)).."】</font>。"
        else
          return "<b>限定技</b>，你可以视为使用或打出一张<br>【"..Fk:translate(player:getMark(self.name)).."】。"
        end
      end
      return ""
    end,
    prompt = function(self, cards)
      return "#steam_ss__guimou_zu:::"..Fk:translate(Self:getMark(self.name))
    end,
    before_use = function (self, player, use)
      player:broadcastSkillInvoke("steam_ss__guimou__9")
      --player:broadcastSkillInvoke(weimu.name,math.random(1,2)+4)--由于语音放到了帷幕里，大动画要播语音后播放
      player.room:notifySkillInvoked(player,"steam_ss__guimou__9",nil,nil)
    end,
    card_filter = Util.FalseFunc,
    view_as = function(self, cards,player)
      local c = Fk:cloneCard(player:getMark(self.name))
      c.skillName = self.name
      return c
    end,
    enabled_at_response = function (self,player,response)
      return player:usedSkillTimes(self.name,Player.HistoryGame) == 0 and player:getMark(self.name) ~= 0
    end,
    enabled_at_play = function (self,player)
      return player:usedSkillTimes(self.name,Player.HistoryGame) == 0 and player:getMark(self.name) ~= 0
    end,}
  jiaxu:addSkill(g)
end




jiaxu:addSkill(weimu)
Fk:loadTranslationTable{
  ["steam_ss__jiaxu"] = "贾诩",--名字
  ["#steam_ss__jiaxu"] = "真·帷幕",--称号
  ["designer:steam_ss__jiaxu"] = "青梅煮酒",--作者
  ["cv:steam_ss__jiaxu"] = "官方",--cv
  ["illustrator:steam_ss__jiaxu"] = "KayaK",--画师
  ["steam_ss__weimu"] = "帷幕",
  [":steam_ss__weimu"] = "其他角色对你或于你回合内使用<a href='jishipai_js'>即时牌</a>时，你可以将一个空的“<b>鬼谋</b>”添加描述：<br><i><b>限定技</b>，你可以视为使用或打出一张【】。<br></i>然后令此牌无效并将之牌名加入上述括号。",
  

  [":steam_ss__guimou_dest"] = "<b>限定技</b>，你可以视为使用或打出一张【%arg】。",

  ["#steam_ss__weimu"] = "选择一个“<b>鬼谋</b>”改为：<b>限定技</b>，你可以视为使用或打出一张【%arg】。",
  ["#steam_ss__weimu-ask"] = "你可以令%arg无效并将一个“<b>鬼谋</b>”改为：<b>限定技</b>，你可以视为使用或打出一张【%arg】。",
  ["#steam_ss__guimou_zu"] = "你可以视为使用或打出一张【%arg】",
  
  ["@$steam_ss__guimou—mark"] = "鬼谋",


  ["$steam_ss__weimu1"] = "此计伤不到我。",
  ["$steam_ss__weimu2"] = "你奈我何？",
  ["$steam_ss__weimu3"] = "神仙难救，神仙难救啊。",
  ["$steam_ss__weimu4"] = "我要你三更死，谁敢留你到五更！",

  ["$steam_ss__guimou__91"] = "我有三窟之筹谋，不蹈背水之维谷。",
  ["$steam_ss__guimou__92"] = "已积千里跬步，欲履万里河山。",

  ['~steam_ss__jiaxu'] = '我的时辰……也到了……',
}


local simahui = General:new(extension, "steam_ss__simahui", "qun", 4)

local bishi = fk.CreateTriggerSkill{
  name = "steam_ss__bishi",
  frequency = Skill.Compulsory,
  events = {fk.EventPhaseStart,fk.EventPhaseEnd},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Play--出牌开始或结束
  end,
  on_use = function(self, event, target, player, data)
    local h = player:getCardIds("h")
    local bs = player:getPile("$steam_ss__bishi")
    player:addToPile("$steam_ss__bishi", h, false, self.name)
    if #h < player.hp then
      if #bs > 0 then
        player.room:moveCardTo(bs, Player.Hand, player, fk.ReasonJustMove, self.name)
      end
    else
      player.room:drawCards(player,#h,self.name)
    end
  end,
}

simahui:addSkill(bishi)

Fk:loadTranslationTable{
  ["steam_ss__simahui"] = "司马徽",--名字
  ["#steam_ss__simahui"] = "避祸隐世",--称号
  ["designer:steam_ss__simahui"] = "赛博尼古丁真",--作者
  ["cv:steam_ss__simahui"] = "官方",--cv
  ["illustrator:steam_ss__simahui"] = "凡果_Make",--画师
  ["steam_ss__bishi"] = "避世",
  [":steam_ss__bishi"] = "<b>锁定技</b>，出牌阶段开始或结束时，若你的手牌数不小于体力值，你将所有手牌移出游戏并摸等量的牌，否则你将“<b>避世</b>”牌与手牌交换。",

  ["$steam_ss__bishi"] = "避世",
  
  ["$steam_ss__bishi1"] = "身在幽静处，大隐山林间。",
  ["$steam_ss__bishi2"] = "长乐山水中，名留久长远。",

  ['~steam_ss__simahui'] = '汝等，可不要让我失望啊。',
}


local haozhao = General:new(extension, "steam_ss__haozhao", "wei", 4)


local zhengu = fk.CreateTriggerSkill{
    name = "steam_ss__zhengu",
    prompt = "#steam_ss__zhengu",
    events ={fk.CardUsing},
    can_trigger = function(self, event, target, player, data)
      return target == player and player:hasSkill(self) and player:usedSkillTimes(self.name) == 0 and
      (data.card.type == Card.TypeBasic or 
      (data.card.type == Card.TypeTrick and 
      data.card.sub_type ~= Card.SubtypeDelayedTrick))--即时牌
  end,
  on_cost = function (self, event, target, player, data)
    local tos = data.tos and #data.tos or 0
    local num = player:getHandcardNum()
    local mark = player:getMark("@steam_ss__zhengu")
    if tos == num and tos == mark and num == mark then return false end--全相等返回
    local n = {tos,num,mark}
    local text = {"#steam_ss__mubiaoshu","#steam_ss__shoupaishu","@steam_ss__zhengu"}
    local all,ask,b = {},{},{}
    for i, v in ipairs(text) do
      for j, u in ipairs(text) do
        if i ~= j then--变化数至多为5
          local bian = n[i] > n[j] and math.max(n[j],n[i] - 5) or math.min(n[j],n[i] + 5)
          local t = "#steam_ss__tiaozheng:::"..v..":"..u..":"..bian
          if n[i] == n[j] then
            t = "#steam_ss__tiaozheng:::"..v..":"..u..":"..n[i]
          else
            if i == 1 then
              print(tos , #player.room:getUseExtraTargets(data,true), bian)
              if (tos + #player.room:getUseExtraTargets(data,true)) >= bian then--合法目标数必须足够
                table.insert(ask,t)
                table.insert(b,bian)
              end
            else
              table.insert(ask,t)
              table.insert(b,bian)
            end
          end
          table.insert(all,t)
        end
      end
    end
    table.insert(ask,"Cancel")
    table.insert(all,"Cancel")
    local choices = player.room:askForChoice(player,ask,self.name,nil,false,all)
    if choices == "Cancel" then
      return false
    else
      for i, v in ipairs(all) do
        if choices == v then
          for j, u in ipairs(ask) do
            if choices == u then
              self.cost_data = {xuan = i,bian = b[j]}
              return true
            end
          end
        end
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local cost = self.cost_data
    local room = player.room
    if cost.xuan < 3 then --调整目标
      if #data.tos > cost.bian then
        local ts = TargetGroup:getRealTargets(data.tos)
        if cost.bian > 0 then--目标为0不用选
          local n = #data.tos - cost.bian
          ts = room:askForChoosePlayers(player,ts,n,n,"#steam_ss__zhengu-jian:::"..n,self.name,false)
        end
        for i = 1, #ts, 1 do
          TargetGroup:removeTarget(data.tos, ts[i])
        end--从列表中移除目标,没找到怎么以列表为参数移除，暂时一个个移除
      else
        local n = cost.bian - #data.tos
        local ts = room:askForChoosePlayers(player,room:getUseExtraTargets(data,true),n,n,"#steam_ss__zhengu-jia:::"..n,self.name,false)
        TargetGroup:pushTargets(data.tos, ts)
      end
    elseif cost.xuan > 2 and cost.xuan < 5 then --调整手牌
      if player:getHandcardNum() > cost.bian then
        room:askForDiscard(player,player:getHandcardNum() - cost.bian,player:getHandcardNum() - cost.bian,false,self.name,false)
      else
        room:drawCards(player,cost.bian - player:getHandcardNum(),self.name)
      end
    else--调整镇骨
      room:setPlayerMark(player,"@steam_ss__zhengu",cost.bian)
    end
  end,
  on_acquire = function (self, player, is_start)
    player.room:setPlayerMark(player,"@steam_ss__zhengu",3)
  end,
  on_lose = function (self, player, is_start)
    player.room:setPlayerMark(player,"@steam_ss__zhengu",0)
  end,
}


haozhao:addSkill(zhengu)

Fk:loadTranslationTable{
  ["steam_ss__haozhao"] = "郝昭",--名字
  ["#steam_ss__haozhao"] = "扣弦的豪将",--称号
  ["designer:steam_ss__haozhao"] = "U",--作者
  ["cv:steam_ss__haozhao"] = "官方",--cv
  ["illustrator:steam_ss__haozhao"] = "秋呆呆",--画师
  ["steam_ss__zhengu"] = "镇骨",
  [":steam_ss__zhengu"] = "每回合限一次，当你使用<a href='jishipai_js'>即时牌</a>时，你可以将一项调整至与另一项相等（变化量至多为5）：<br>1.目标数；2.手牌数；3.3。",
  ["#steam_ss__mubiaoshu"] = "目标数",
  ["#steam_ss__shoupaishu"] = "手牌数",
  ["@steam_ss__zhengu"] = "镇骨",
  ["#steam_ss__tiaozheng"] = "将%arg调整至%arg2（%arg3）",
  ["#steam_ss__zhengu-jian"] = "请减少%arg个目标",
  ["#steam_ss__zhengu-jia"] = "请增加%arg个目标",

  ["$steam_ss__zhengu1"] = "镇守城池，必以骨相拼！",
  ["$steam_ss__zhengu2"] = "孔明计虽百算，却难敌吾镇骨千具！",

  ['~steam_ss__haozhao'] = '镇守陈仓，也有一失。',
}


local qiaozhou = General(extension, "steam_ss__qiaozhou", "shu", 3)
qiaozhou.subkingdom = "jin"
local shiming = fk.CreateTriggerSkill{
  name = "steam_ss__shiming",
  anim_type = "drawcard",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target.phase == Player.Start and player:hasSkill(self) and player.kingdom == target.kingdom and
    player:usedSkillTimes(self.name,Player.HistoryRound) == 0
  end,
  on_cost = function (self, event, target, player, data)
    return player.room:askForSkillInvoke(player,self.name)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:askForGuanxing(player, room:getNCards(math.min(3, #room.draw_pile)))
    local n = #table.filter(room:getAlivePlayers(),function (t) return t.kingdom == player.kingdom end)
    local tb = room:askForChoice(player, {"Top","Bottom"}, self.name, "#steam_ss__shiming-ask:::"..n)
    room:drawCards(player,n,self.name,tb == "Top" and "top" or "bottom")
    local kingdoms = {"wei", "shu", "wu", "qun", "jin"}
    local choices = table.simpleClone(kingdoms)
    table.removeOne(choices, player.kingdom)
    local choice = room:askForChoice(player, choices, self.name, "#steam_ss__shiming-invoke", false, kingdoms)
    room:changeKingdom(player, choice, true)
  end,
}

local qiangjian = fk.CreateTriggerSkill{
  name = "steam_ss__qiangjian",
  anim_type = "control",
  events = {fk.EventPhaseEnd},
  can_trigger = function(self, event, target, player, data)
    return target.phase == Player.Draw and player:hasSkill(self) and player:canPindian(target)
  end,
  on_cost = function (self, event, target, player, data)
    return player.room:askForSkillInvoke(player,self.name)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local pindian = player:pindian({target},self.name)
    if pindian.results[target.id].winner == player then
      room:obtainCard(target, pindian.fromCard, true, fk.ReasonJustMove,player.id,self.name)
      target:skip(Player.Play)
      target:skip(Player.Discard)
    end
  end,
}

local nixun = fk.CreateTriggerSkill{
  name = "steam_ss__nixun",
  frequency = Skill.Compulsory,
  events = {fk.AfterPropertyChange},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and data.kingdom == "jin"
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local ps = room:askForChoosePlayers(player,table.map(room:getAlivePlayers(),Util.IdMapper),1,1,"#steam_ss__nixun-ask",self.name,false)
    local p = room:getPlayerById(ps[1])
    local all = {"#steam_ss__nixun-hp","#steam_ss__nixun-draw","#steam_ss__nixun-blcx"}
    local ask = table.simpleClone(all)
    local blcx = Fk:cloneCard("steam_ss__enemy_at_the_gates")
    if not p:isWounded() then
      table.removeOne(ask, "#steam_ss__nixun-hp")
    end
    if U.getDefaultTargets(p,blcx) == nil then
      table.removeOne(ask, "#steam_ss__nixun-blcx")
    end
    local choice = room:askForChoice(p, ask, self.name, nil, false, all)
    self.cost_data = {p = p, choice = choice}
    return true
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local p = self.cost_data.p
    if self.cost_data.choice == "#steam_ss__nixun-hp" then
      room:recover{
        who = p,
        num = 1,
        recoverBy = player,
        skillName = self.name,
      }
    elseif self.cost_data.choice == "#steam_ss__nixun-draw" then
      room:drawCards(p,2,self.name)
    else
      local use = U.askForUseVirtualCard(room,p,"steam_ss__enemy_at_the_gates",nil,self.name,nil,false,false,false,false,nil,true)
      if use then
        use.extra_data = {toArea = "top"}
        player.room:useCard(use)
      end
    end
  end,
}

nixun:addAttachedKingdom("jin")
qiangjian:addAttachedKingdom("shu")
qiaozhou:addSkill(shiming)
qiaozhou:addSkill(qiangjian)
qiaozhou:addSkill(nixun)

Fk:loadTranslationTable{
  ["steam_ss__qiaozhou"] = "谯周",--名字
  ["#steam_ss__qiaozhou"] = "谶星沉祚",--称号
  ["designer:steam_ss__qiaozhou"] = "TwinkleYellow",--作者
  ["cv:steam_ss__qiaozhou"] = "官方",--cv
  ["illustrator:steam_ss__qiaozhou"] = "鬼画府",--画师
  ["steam_ss__shiming"] = "识命",
  [":steam_ss__shiming"] = "每轮限一次，势力与你相同的角色的准备阶段，你可以卜算3，然后从牌堆顶或牌堆底摸X张牌（X为势力与你相同的角色数）。若如此做，你变更势力。",
  ["steam_ss__qiangjian"] = "强谏",
  [":steam_ss__qiangjian"] = "<b>蜀势力技</b>，其他角色的摸牌阶段结束时，你可以与其拼点，若你赢，其获得你的拼点牌，然后跳过本回合的出牌阶段和弃牌阶段。",
  ["steam_ss__nixun"] = "逆勋",
  [":steam_ss__nixun"] = "<b>晋势力技</b>，<b>锁定技</b>，当你变更至此势力时，你令一名角色选择一项：1.回复1点体力；2.摸两张牌；3.视为使用一张<a href=':steam_ss__enemy_at_the_gates'>【兵临城下】</a>。",


  ["#steam_ss__shiming-ask"] = "请选择从何处摸%arg张牌",
  ["#steam_ss__shiming-invoke"] = "变更势力",

  ["#steam_ss__nixun-hp"] = "回复1点体力",
  ["#steam_ss__nixun-draw"] = "摸两张牌",
  ["#steam_ss__nixun-blcx"] = "视为使用【兵临城下】",

  ["#steam_ss__nixun-ask"] = "令一名角色进行<b>“逆勋”</b>选择",


  ["$steam_ss__shiming1"] = "今天命在北，我等已尽人事。",
  ["$steam_ss__shiming2"] = "益州国疲民敝，非人力可续之。",
  ["$steam_ss__qiangjian1"] = "陛下降，若魏不裂土以封，臣必以古义争之。",
  ["$steam_ss__qiangjian2"] = "诸葛公天纵之才而堪堪弼国，况我等凡夫乎？",
  ["$steam_ss__nixun1"] = "典午忽兮，月酉没兮。",
  ["$steam_ss__nixun2"] = "周慕孔子遗风，可与刘、扬同轨。",

  ['~steam_ss__qiaozhou'] = '老夫死不足惜，但求蜀地百姓无虞！',
}


local sunyi = General:new(extension, "steam_ss__sunyi", "wu", 5)

local qiaoji = fk.CreateTriggerSkill{
  name = "steam_ss__qiaoji",
  frequency = Skill.Compulsory,
  events = {fk.CardUseFinished},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and data.card.type ~= Card.TypeTrick and not player.dead
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:recover{
      who = player,
      num = 2,
      recoverBy = player,
      skillName = self.name,
    }
    if not player.dead then
      room:drawCards(player,3,self.name)
    end
    if not player.dead and player.hp > 3 then
      room:loseHp(player,4,self.name)
    end
    if not player.dead and player:getHandcardNum() > 4 then
      room:askForDiscard(player,5,5,false,self.name,false)
    end
  end,
}

sunyi:addSkill(qiaoji)

Fk:loadTranslationTable{
  ["steam_ss__sunyi"] = "孙翊",
  ["#steam_ss__sunyi"] = "虓风快意",
  ["designer:steam_ss__sunyi"] = "U",
  ["illustrator:steam_ss__sunyi"] = "君桓文化",
  ["cv:steam_ss__sunyi"] = "官方",
  ["steam_ss__qiaoji"] = "峭急",
  [":steam_ss__qiaoji"] = "<b>锁定技</b>，当你使用非锦囊牌后回复2点体力、摸三张牌，然后失去4点体力、弃置五张手牌（不足则不失去，不足则不弃）。",

  ["$steam_ss__qiaoji1"] = "为将者，当躬冒矢石！",
  ["$steam_ss__qiaoji2"] = "吾承父兄之志，危又何惧？",

  ['~steam_ss__sunyi'] = "功业未成而身先死，惜哉，惜哉！",
}


local guyu = General:new(extension, "steam_ss__guyu", "wu", 4)

local tuilang = fk.CreateTriggerSkill{
  name = "steam_ss__tuilang",
  anim_type = "drawcard",
  events = {fk.AfterCardsMove},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) then
      for _, move in ipairs(data) do
        if move.from == player.id then
          for _, info in ipairs(move.moveInfo) do
            if info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip then
              local m = player:getMark("@steam_ss__tuilang")
              return (m % 3 == 0) and m > 0
            end
          end
        end
      end
    end
  end,
  on_cost = function (self, event, target, player, data)
    return player.room:askForSkillInvoke(player,self.name)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:drawCards(player,2,self.name)
    room:askForDiscard(player,1,999,true,self.name,true,nil,"#steam_ss__tuilang")
  end,
  refresh_events = {fk.AfterCardsMove},
  can_refresh = function(self, event, target, player, data)
    if player:hasSkill(self) then
      for _, move in ipairs(data) do
        if move.from == player.id then
          self.cost_data = #table.filter(move.moveInfo,function (info)
            return info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip
          end)
          return true
        end
      end
    end
  end,
  on_refresh = function (self, event, target, player, data)
    player.room:addPlayerMark(player,"@steam_ss__tuilang",self.cost_data)
  end,
}

guyu:addSkill(tuilang)

Fk:loadTranslationTable{
  ["steam_ss__guyu"] = "顾裕",
  ["#steam_ss__guyu"] = "镇东少豪",
  ["designer:steam_ss__guyu"] = "绯红的波罗",
  ["illustrator:steam_ss__guyu"] = "",
  ["cv:steam_ss__guyu"] = "官方",
  ["steam_ss__tuilang"] = "推浪",
  [":steam_ss__tuilang"] = "当你失去过的总牌数变为3的整倍数时，你可以摸两张牌，然后弃置任意张牌。",

  ["@steam_ss__tuilang"] = "推浪",
  ["#steam_ss__tuilang"] = "你可以弃置任意张牌",

  ["$steam_ss__tuilang1"] = "激流勇进，乘帆破浪！",
  ["$steam_ss__tuilang2"] = "洄旋逆转，定克惊涛！",

  ['~steam_ss__guyu'] = "亡者已矣，何患无人！",
}


local sunhuan = General:new(extension, "steam_ss__sunhuan", "wu", 4)

local eyao = fk.CreateTriggerSkill{
  name = "steam_ss__eyao",
  events = {fk.EventPhaseStart,fk.CardUseFinished},
  can_trigger = function(self, event, target, player, data)
    if event == fk.CardUseFinished then
      return player:hasSkill(self) and data.card.type == Card.TypeEquip and not player.dead
    else
      return target == player and player:hasSkill(self) and player.phase == Player.Play--出牌开始
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local i = 0
    for _, p in ipairs(player.room:getAlivePlayers()) do
      i = i + #p:getCardIds("e")
    end
    i = i % 2
    self.cost_data = {num = i}
    if i == 0 then
      local ps = room:askForChoosePlayers(player,
      table.map(table.filter(room:getAlivePlayers(),function (p) return #p:getCardIds("h") > 0 end)
      ,Util.IdMapper),
      1,1,"#steam_ss__eyao-ou",self.name)
      if #ps > 0 then
        self.cost_data = {num = i , p = ps[1]}
        return true
      end
    else
      return room:askForSkillInvoke(player,self.name,nil,"#steam_ss__eyao-ji")
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if self.cost_data.num == 0 then
      local p = room:getPlayerById(self.cost_data.p)
      local c = Fk:getCardById(room:askForCardChosen(player,p,"h",self.name))
      p:showCards(c)
      room:addTableMarkIfNeed(p,"@$steam_ss__eyao-turn",c.trueName)
    else
      room:drawCards(player,1,self.name)
    end
  end,
}
local eyao_filter = fk.CreateFilterSkill{
  name = "#steam_ss__eyao_filter",
  anim_type = "control",
  card_filter = function(self, card, player)
    return table.contains(player:getTableMark("@$steam_ss__eyao-turn"),card.trueName)
  end,
  view_as = function(self, card, player)
    local c = Fk:cloneCard("dismantlement", card.suit, card.number)
    c.skillName = eyao.name
    return c
  end,
}
eyao:addRelatedSkill(eyao_filter)
sunhuan:addSkill(eyao)

Fk:loadTranslationTable{
  ["steam_ss__sunhuan"] = "孙桓",
  ["#steam_ss__sunhuan"] = "扼龙决险",
  ["designer:steam_ss__sunhuan"] = "AiWuJU",
  ["illustrator:steam_ss__sunhuan"] = "一意动漫",
  ["cv:steam_ss__sunhuan"] = "官方",
  ["steam_ss__eyao"] = "扼要",
  [":steam_ss__eyao"] = "出牌阶段开始时或当一名角色使用装备牌后，若场上的装备数之和为：奇数，你可以摸一张牌；偶数，你可以展示一名角色的一张手牌，本回合该角色与此牌同名的手牌均视为【过河拆桥】。",

  ["#steam_ss__eyao_filter"] = "扼要",
  ["@$steam_ss__eyao-turn"] = "扼要",
  ["#steam_ss__eyao-ji"] = "你可以摸一张牌",
  ["#steam_ss__eyao-ou"] = "你可以展示一名角色的一张手牌，令其同名手牌视为【过河拆桥】",
  ["#steam_ss__eyao-ask"] = "请选择一名角色",

  ["$steam_ss__eyao1"] = "将者临战，谋先定而后动兵戈。",
  ["$steam_ss__eyao2"] = "沙场交兵，先击未中者命悬矣。",

  ['~steam_ss__sunhuan'] = "烈马迷山径，少年白发生。",
}



local zhugejun = General:new(extension, "steam_ss__zhugejun", "qun", 4)


local genghuang = fk.CreateTriggerSkill{
  name = "steam_ss__genghuang",
  events ={fk.BeforeDrawCard},--摸牌前
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and data.num > 0 and player:usedSkillTimes(self.name) == 0
end,
on_cost = function (self, event, target, player, data)
  return player.room:askForSkillInvoke(player,self.name,nil,"#steam_ss__genghuang-ask:::"..data.num)
end,
on_use = function(self, event, target, player, data)
  local judge = {
    who = player,
    reason = self.name,
  }
  player.room:judge(judge)
  data.num = data.num - 1 + #table.filter(player:getCardIds("h"),function (id)
    return Fk:getCardById(id).color == judge.card.color
  end)
end,
}


local bisao = fk.CreateTriggerSkill{
  name = "steam_ss__bisao",
  events ={fk.BeforeCardsMove},
  can_trigger = function(self, event, target, player, data)
  if target ~= player and not player:hasSkill(self) then return end
  for _, move in ipairs(data) do
    local cards = {}
    if move.moveReason == fk.ReasonDiscard and move.from == player.id and move.proposer == player.id and move.skillName ~= self.name then
      for _, info in ipairs(move.moveInfo) do
          if info.fromArea == Player.Hand or info.fromArea == Player.Equip then
            table.insert(cards,info.cardId)
          end
      end
      self.cost_data = {cards = cards,moveInfo = move.moveInfo}
      return (#player:getCardIds("he") - #cards) > 0
    end
  end

end,
on_cost = function (self, event, target, player, data)
  local p = ".|.|.|.|.|.|^("..table.concat(self.cost_data.cards, ",")..")"
  local c = player.room:askForDiscard(player,1,1,true,self.name,true,p,"#steam_ss__bisao-ask")
  if #c > 0 then
    table.insert(self.cost_data.cards,c[1])
    return true
  end
end,
on_use = function(self, event, target, player, data)
  local room = player.room
  local cards = self.cost_data.cards
  local judge = {
    who = player,
    reason = self.name,
  }
  room:judge(judge)
  room:moveCardTo(cards, Card.Processing, nil, fk.ReasonJustMove, self.name, nil, true, player.id)
  room:delay(#cards * 150)
  local cards_true = {}
  local y = 0 --使用的牌数
    repeat
      cards_true = table.filter(cards,function(id)
        local tc = Fk:getCardById(id)
        local hf = U.getDefaultTargets(player,tc,true)--合法性检测,为nil不合法，为空则没法手动选择目标
        return hf ~= nil and not player:prohibitUse(tc) and tc.color == judge.card.color end)
      if #cards_true > 0 then
        if y == 0 then
          player.room:sendLog{
            type = "#steam_ss__bisao-log",
            from = player.id,
            card = cards_true,
            toast = true,}
            y = y + 1
        else
          player:broadcastSkillInvoke(self.name)
        end
        local x = room:askForUseRealCard(player,cards_true,self.name,nil,{expand_pile = cards_true},false)
        if x then
          table.removeOne(cards,x.card.id)
          table.removeOne(self.cost_data.moveInfo,table.find(self.cost_data.moveInfo,function (info)
            return info.cardId == x.card.id
          end))
        end
      end
    until #cards_true == 0--真就下去，假就循环
end,
}



local shouzhen = fk.CreateTriggerSkill{
  name = "steam_ss__shouzhen",
  events ={fk.AskForRetrial},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and #player:getTableMark("@$steam_ss__shouzhen") > 0
end,
on_cost = function (self, event, target, player, data)
  return player.room:askForSkillInvoke(player,self.name)
end,
on_use = function(self, event, target, player, data)
  player.room:retrial(Fk:getCardById(player:getTableMark("@$steam_ss__shouzhen")[1]), player, data, self.name)
end,
refresh_events = {fk.FinishJudge},
can_refresh = function (self, event, target, player, data)
  return target == player and player:hasSkill(self)
end,
on_refresh = function (self, event, target, player, data)
  player.room:setPlayerMark(player,"@$steam_ss__shouzhen",{data.card.id})
end,
on_acquire = function (self, player, is_start)
  local dat = nil
  player.room.logic:getEventsByRule(GameEvent.Judge, 1, function (e)
    if e.id ~= player.room.logic:getCurrentEvent().id and e.data[1].who == player then
        local use = e.data[1]
        dat = use
        return true
    end
  end, 1)
  if dat and dat.who == player then
    player.room:setPlayerMark(player,"@$steam_ss__shouzhen",{dat.card.id})--获得技能时获取上一次判定结果，以防左慈类的武将
  end
end,
on_lose = function (self, player, is_death)
  player.room:setPlayerMark(player,"@$steam_ss__shouzhen",0)
end,
}


zhugejun:addSkill(genghuang)
zhugejun:addSkill(bisao)
zhugejun:addSkill(shouzhen)

Fk:loadTranslationTable{
  ["steam_ss__zhugejun"] = "诸葛均",--名字
  ["#steam_ss__zhugejun"] = "荫敝自珍",--称号
  ["designer:steam_ss__zhugejun"] = "小叶子",--作者
  ["cv:steam_ss__zhugejun"] = "官方",--cv
  ["illustrator:steam_ss__zhugejun"] = "错落宇宙",--画师
  ["steam_ss__genghuang"] = "耕荒",
  [":steam_ss__genghuang"] = "每回合限一次，你摸牌时可以少摸一张并进行判定，然后多摸手中与判定同颜色牌数张牌。",
  ["steam_ss__bisao"] = "敝扫",
  [":steam_ss__bisao"] = "你弃牌时可以多弃一张并进行判定，然后使用弃牌中与判定颜色相同的牌。",
  ["steam_ss__shouzhen"] = "守真",
  [":steam_ss__shouzhen"] = "你可将你的判定结果改为你上次的判定结果。",

  ["@$steam_ss__shouzhen"] = "守真",
  ["#steam_ss__genghuang-ask"] = "你即将摸%arg张牌，你可以少摸一张牌以发动【耕荒】",

  ["#steam_ss__bisao-ask"] = "你可以多弃一张牌以发动【敝扫】",
  ["#steam_ss__bisao-log"] = "%from 可以使用 %card",

  ["$steam_ss__genghuang1"] = "勤耕陇亩地，并修德与身。",
  ["$steam_ss__genghuang2"] = "田垄不可废，耕读不可怠。",
  ["$steam_ss__bisao1"] = "勤学广才，秉宁静以待致远。",
  ["$steam_ss__bisao2"] = "读群书而后知，见众贤而思进。",
  ["$steam_ss__shouzhen1"] = "临别教诲，均谨记在心。",

  ['~steam_ss__zhugejun'] = '战火延绵，不知兄长归期。',
}


return extension