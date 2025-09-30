local extension = Package("aaa_steam2")
extension.extensionName = "aaa_steam"

local U = require "packages/utility/utility"
local RUtil = require "packages/aaa_fenghou/utility/rfenghou_util"

Fk:loadTranslationTable{
  ["aaa_steam2"] = "steam2",
}



local zhangrangzhaozhong = General:new(extension, "steam__zhangrangzhaozhong", "han", 3)

local steam__jiedang = fk.CreateTriggerSkill{
  name = "steam__jiedang",
  events = {fk.EventPhaseEnd},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) and target == player and player.phase == Player.Play and not player:isKongcheng() then
      local cards = player:getCardIds("h")
      local cardtype = Fk:getCardById(cards[1]):getTypeString()
      if not table.contains(player:getTableMark("@steam__jiedang-turn"), cardtype.."_char") then
        return table.every(cards, function (id)
          return Fk:getCardById(id):getTypeString() == cardtype
        end)
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    if player:isKongcheng() then return end
    local cards = player:getCardIds("h")
    player.room:addTableMark(player, "@steam__jiedang-turn", Fk:getCardById(cards[1]):getTypeString().."_char")
    player:showCards(cards)
    player:gainAnExtraPhase(Player.Play)
  end,
}
zhangrangzhaozhong:addSkill(steam__jiedang)

local steam__qiechong = fk.CreateActiveSkill{
  name = "steam__qiechong",
  anim_type = "switch",
  switch_skill_name = "steam__qiechong",
  card_num = 0,
  target_num = 1,
  prompt = function(self)
    return "#steam__qiechong_"..Self:getSwitchSkillState(self.name, false, true)
  end,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, to_select, selected)
    local to = Fk:currentRoom():getPlayerById(to_select)
    if #selected == 0 and to and to_select ~= Self.id then
      if Self:getSwitchSkillState(self.name, false) == fk.SwitchYang then
        return not to:isKongcheng()
      else
        return not to:isNude()
      end
    end
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local to = room:getPlayerById(effect.tos[1])
    local cards = {}
    local isYang = player:getSwitchSkillState(self.name, true) == fk.SwitchYang
    local returnToPile = function ()
      cards = table.filter(cards, function (id) return room:getCardArea(id) == Card.Processing end)
      if #cards > 0 then
        cards = table.reverse(cards)
        room:moveCards({ ids = cards, toArea = Card.DrawPile, moveReason = fk.ReasonPut, skillName = self.name })
      end
    end
    if isYang then
      player:drawCards(1, self.name)
      cards = room:askForCardsChosen(player, to, 0, 2, "h", self.name)
    else
      local cid = room:askForCardChosen(player, to, "he", self.name)
      room:obtainCard(player, cid, false, fk.ReasonPrey, player.id, self.name)
      if not player.dead then
        cards = room:getNCards(4)
        room:moveCardTo(cards, Card.Processing, nil, fk.ReasonJustMove, self.name, nil, true, player.id)
        -- 展示牌应该封装fakemove
      end
    end
    if not player.dead and #cards > 0 then
      local x = #room.logic:getEventsOfScope(GameEvent.Phase, 99, function(e)
        return e.data[1] == player and e.data[2] == Player.Play
      end, Player.HistoryTurn)
      local my_cards = table.filter(player:getCardIds("h"), function(id)
        return Fk:translate(Fk:getCardById(id).trueName, "zh_CN"):len() <= x
      end)
      if #my_cards > 0 then
        local ex_cards = room:askForPoxi(player, "steam__qiechong_exchange", {
          { isYang and to.general or "Top", cards },
          { "$Hand", my_cards },
        }, {x}, true)
        if #ex_cards > 0 then
          local my_lose = {}
          for i = #ex_cards, 1, -1 do
            if table.contains(my_cards, ex_cards[i]) then
              table.insert(my_lose, table.remove(ex_cards, i))
            end
          end
          if isYang then
            U.swapCards(room, player, player, to, my_lose, ex_cards, self.name, Player.Hand)
          else
            returnToPile()
            if not player.dead then
              U.swapCardsWithPile(player, my_lose, ex_cards, self.name, "Top", false, player.id)
            end
          end
        end
      end
    end
    returnToPile()
  end,
}
zhangrangzhaozhong:addSkill(steam__qiechong)

Fk:addPoxiMethod{
  name = "steam__qiechong_exchange",
  card_filter = function(to_select, selected, data, extra_data)
    if data == nil or extra_data == nil then return false end
    local lenLimit = extra_data[1] or 0
    if table.contains(data[2][2], to_select) then
      return Fk:translate(Fk:getCardById(to_select).trueName, "zh_CN"):len() <= lenLimit
    else
      local count = 0
      for _, id in ipairs(selected) do
        if table.contains(data[1][2], id) then
          count = count + 1
        else
          count = count - Fk:translate(Fk:getCardById(id).trueName, "zh_CN"):len()
        end
      end
      return count < 0
    end
  end,
  feasible = function(selected, data, extra_data)
    if data == nil or #selected == 0 then return false end
    local count = 0
    for _, id in ipairs(selected) do
      if table.contains(data[1][2], id) then
        count = count + 1
      else
        count = count - Fk:translate(Fk:getCardById(id).trueName, "zh_CN"):len()
      end
    end
    return count == 0
  end,
  prompt = function (data, extra_data)
    if extra_data and extra_data[1] then
      return "#steam__qiechong-exchange:::"..string.format("%.0f", extra_data[1])
    end
    return " "
  end,
  default_choice = function ()
    return {}
  end,
}

Fk:loadTranslationTable{
  ["steam__zhangrangzhaozhong"] = "张让赵忠",
  ["#steam__zhangrangzhaozhong"] = "鹗踞中天",
  ["illustrator:steam__zhangrangzhaozhong"] = "Greencias",
  ["designer:steam__zhangrangzhaozhong"] = "快雪时晴",
  ["cv:steam__zhangrangzhaozhong"] = "张让",

  ["steam__jiedang"] = "结党",
  [":steam__jiedang"] = "回合每种类型限一次，出牌阶段结束时，若你手牌类型均相同，你可展示之并执行一个额外的出牌阶段。",
  ["@steam__jiedang-turn"] = "结党",

  ["steam__qiechong"] = "窃宠",
  [":steam__qiechong"] = "转换技，出牌阶段限一次，阳：你摸一张牌并观看一名其他角色至多两张手牌。阴：你获得一名其他角色一张牌并展示牌堆顶四张牌。若如此，你可用任意张牌名字数不大于X的手牌交换其中任意张牌，你因交换失去牌的牌名字数之和与获得牌的牌数须相等（X你为本回合进行的出牌阶段数量）。",
  ["#steam__qiechong_yang"] = "窃宠：摸1张牌，观看其他角色至多2张手牌",
  ["#steam__qiechong_yin"] = "窃宠：获得其他角色1张牌，展示牌堆顶4张牌",
  ["#steam__qiechong-exchange"] = "窃宠：用任意张字数不大于 %arg 的手牌交换展示牌",
  ["steam__qiechong_exchange"] = "窃宠换牌",

  ["$steam__jiedang1"] = "古人云：宦者四星，在皇之侧，正是你我。",
  ["$steam__jiedang2"] = "天家雨露重新，落在咱家怀里，自是一片赤心。",
  ["$steam__qiechong1"] = "金貂玉带蟒袍新，便是关内侯也做得。",
  ["$steam__qiechong2"] = "职掌六宫，出入荷恩，天子称咱阿父阿母。",
  ["~steam__zhangrangzhaozhong"] = "被任执钧十余年，人间威福早享尽。",
}













local steam__yuanshu = General:new(extension, "steam__yuanshu", "qun", 4)

local steam_yongsi = fk.CreateTriggerSkill{
  name = "steam_yongsi",
  events = {fk.TurnStart,fk.AskForCardUse,fk.AskForPeaches},
  anim_type = "drawcard",
  can_trigger = function (self, event, target, player, data)
    if event == fk.TurnStart then
      return player:hasSkill(self) and target == player
    elseif event == fk.AskForCardUse then
      return player:hasSkill(self) and target == player and data.cardName == "jink"
    else
      return player:hasSkill(self) and player.phase == Player.NotActive and target == player
    end
  end,
  on_cost = function (self, event, target, player, data)
    local reject = player:getTableMark("@steam_yongsi_mark")
    if event == fk.TurnStart then
      return table.contains(reject,"#yongsi_play") or player.room:askForSkillInvoke(player,self.name,nil,"#yongsi-rejectPlay")
    elseif event == fk.AskForCardUse then
      return table.contains(reject,"#yongsi_jink") or player.room:askForSkillInvoke(player,self.name,nil,"#yongsi-rejectJink")
    else
      return table.contains(reject,"#yongsi_peach") or player.room:askForSkillInvoke(player,self.name,nil,"#yongsi-rejectPeach")
    end
    
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local is_maxHandCard = table.every(room:getOtherPlayers(player),function (element, index, array)
      return player:getHandcardNum()>element:getHandcardNum()
    end) 
    room:drawCards(player,3)
    if player.dead then return end
    local become_maxHandCard = (not is_maxHandCard) and table.every(room:getOtherPlayers(player),function (element, index, array)
      return player:getHandcardNum()>element:getHandcardNum()
    end) 
    local reject = player:getTableMark("@steam_yongsi_mark")
    if event == fk.TurnStart then
      if (not table.contains(reject,"#yongsi_play")) and become_maxHandCard then
        room:addTableMark(player,"@steam_yongsi_mark","#yongsi_play")
      end
      room.logic:breakTurn()
      return true
    elseif event == fk.AskForCardUse then
      room:addPlayerMark(player,"cant_use_jink")
      local evt = room.logic:getCurrentEvent():findParent(GameEvent.CardEffect) or room.logic:getCurrentEvent():findParent(GameEvent.SkillEffect)
      if evt then
        evt:addCleaner(function (self)
          room:setPlayerMark(player,"cant_use_jink",0)
        end)
      end
      if (not table.contains(reject,"#yongsi_jink")) and become_maxHandCard then
        room:addTableMark(player,"@steam_yongsi_mark","#yongsi_jink")
      end
    else
      room:setPlayerMark(player,"cant_use_peach",1)
      if  (not table.contains(reject,"#yongsi_peach")) and become_maxHandCard then
        room:addTableMark(player,"@steam_yongsi_mark","#yongsi_peach")
      end
    end
  end,
  refresh_events = {fk.AskForPeachesDone},
  can_refresh = function (self, event, target, player, data)
    return player:hasSkill(self)
  end,
  on_refresh = function (self, event, target, player, data)
    player.room:setPlayerMark(player,"cant_use_peach",0)
  end
}
local steam_yongsi_prohibit = fk.CreateProhibitSkill{
  name = "#steam_yongsi_prohibit",
  prohibit_use = function(self, player, card)
    return (player:getMark("cant_use_jink")>0 and card.trueName == "jink") or(player:getMark("cant_use_peach")>0 and card.trueName == "peach")
  end,
}
steam_yongsi:addRelatedSkill(steam_yongsi_prohibit)
steam__yuanshu:addSkill(steam_yongsi)

local steam_pizhi = fk.CreateTriggerSkill{
  name = "steam_pizhi",
  events = {fk.TargetConfirmed},
  can_trigger = function (self, event, target, player, data)
    return player:hasSkill(self) and player == target and data.card.trueName == "slash"
  end,
  on_cost = function (self, event, target, player, data)
    local cards = player.room:askForDiscard(player,1,2,true,self.name,true,".","pizhi-discard",true)
    self.cost_data = cards;
    return #cards>0
  end,
  on_use = function (self, event, target, player, data)
    player.room:throwCard(self.cost_data,self.name,player)
    if player.dead then return end
    player.room:addPlayerMark(player,"pizhi-extra",#self.cost_data)
    data.additionalEffect = (data.additionalEffect or 0) + player:getMark("pizhi-extra");
  end
}
local steam_pizhi_delay = fk.CreateTriggerSkill{
  name = "#steam_pizhi_delay",
  events = {fk.CardUseFinished},
  mute = true,
  can_trigger = function (self, event, target, player, data)
    return player:hasSkill(self) and player:getMark("pizhi-extra")>0 and data.card.trueName == "slash"
  end,
  on_trigger = function (self, event, target, player, data)
    local cardUser = player.room:getPlayerById(data.from)
    if player:getMark("pizhi-extra")>0 then
      while player:getMark("pizhi-extra")>0 do
        player.room:removePlayerMark(player,"pizhi-extra")
        if #cardUser:getCardIds("hej")>0 and cardUser:isAlive() then
          player.room:useVirtualCard("dismantlement",nil,player,{cardUser})
        else
          break
        end
        if player.dead then return end
      end
    end
  end
}

steam_pizhi:addRelatedSkill(steam_pizhi_delay)
steam__yuanshu:addSkill(steam_pizhi)

Fk:loadTranslationTable {
  ["steam__yuanshu"] = "袁术",
  ["#steam__yuanshu"] = "蠹殁安还",
  ["designer:steam__yuanshu"] = "牧孖",
  ["steam_yongsi_jink"] = "庸肆",
  ["steam_yongsi"] = "庸肆",
  [":steam_yongsi"] = "回合开始时，或当你需要使用【闪】时，或当你于回合外需要使用【桃】时，你可以拒绝执行之并摸三张牌，"..
    "然后若你手牌数变为全场唯一最多，你于该时机仅能如此做。",
  ["#yongsi-rejectPeach"] = "庸肆：你可以拒绝使用【桃】并摸三张牌，若手牌变为最多则此后你只能此做",
  ["#yongsi-rejectJink"] = "庸肆：你可以拒绝使用【闪】并摸三张牌，若手牌变为最多则此后你只能此做",
  ["#yongsi-rejectPlay"] = "庸肆：你可以摸三张牌并跳过本回合，若手牌变为最多则此后你只能此做",
  ["#steam_yongsi_prohibit"] = "庸肆",
  ["@steam_yongsi_mark"] = "庸肆",
  ["#yongsi_play"] = "出",
  ["#yongsi_jink"] = "闪",
  ["#yongsi_peach"] = "桃",
  ["steam_pizhi"] = "圮秩",
  [":steam_pizhi"] = "当你成为【杀】的目标后，你可以弃置至多两张牌令此牌对你结算等量次，则此牌结算结束后，你视为对其使用等量张【过河拆桥】。",
  ["pizhi-discard"] = "圮秩：你可以弃牌使此【杀】牌对你额外结算等量次"
}



local steam__zhengxuan = General:new(extension, "steam__zhengxuan", "qun", 3)

local steam__botong = fk.CreateTriggerSkill{
  name = "steam__botong",
  events = {fk.CardUsing, fk.TurnStart},
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(self) then return end
    if event == fk.CardUsing then
      if player.phase ~= Player.NotActive then return end
      local currentEvent = player.room.logic:getCurrentEvent():findParent(GameEvent.UseCard, true)
      if currentEvent then
        local last = player.room.logic:getEventsByRule(GameEvent.UseCard, 1, function (e)
          return e.id < currentEvent.id
        end, 1)
        return #last > 0 and last[1].data[1].from ~= target.id
      end
    else
      return target == player and player:getMark("@hf_classic") > 1
    end
  end,
  on_cost = function (self, event, target, player, data)
    return event == fk.CardUsing or player.room:askForSkillInvoke(player, self.name)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if event == fk.CardUsing then
      room:notifySkillInvoked(player, self.name, "special")
      room:addPlayerMark(player, "@hf_classic")
    else
      room:notifySkillInvoked(player, self.name, "drawcard")
      player:broadcastSkillInvoke(self.name, 1)
      local top = room:getNCards(player:getMark("@hf_classic"))
      room:setPlayerMark(player, "@hf_classic", 0)
      local result = room:askForCustomDialog(player, self.name,
      "packages/aaa_steam/qml/BotongBox.qml", {
        top, "#steam__botong"})
      if result == "" then return end
      local cards = json.decode(result)
      if #cards == 0 then return end
      player:broadcastSkillInvoke(self.name, 2)
      room:obtainCard(player, cards, true, fk.ReasonJustMove, player.id, self.name)
      while not player.dead do
        cards = table.filter(cards, function (id) return table.contains(player.player_cards[Player.Hand], id) end)
        if #cards == 0 then break end
        if table.every(room.alive_players, function (p)
          return #p:getPile("steam__botong_pile") > 0
        end) then break end
        local _,dat = room:askForUseActiveSkill(player, "steam__botong_choose", "#steam__botong-put", true, {steam__botong_cards = cards})
        if not dat then break end
        room:getPlayerById(dat.targets[1]):addToPile("steam__botong_pile", dat.cards, true, self.name, player.id)
      end
    end
  end,
}

local steam__botong_delay = fk.CreateTriggerSkill{
  name = "#steam__botong_delay",
  anim_type = "support",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player.phase == Player.Start and #player:getPile("steam__botong_pile") > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local suit = Fk:getCardById(player:getPile("steam__botong_pile")[1]).suit
    room:obtainCard(player, player:getPile("steam__botong_pile"), true, fk.ReasonJustMove)
    if player.dead then return end
    if suit == Card.Heart then
      target:gainAnExtraPhase(Player.Play, true)
    elseif suit == Card.Club then
      target:gainAnExtraPhase(Player.Draw, true)
    elseif suit == Card.Diamond then
      room:recover { num = 1, skillName = self.name, who = player, recoverBy = player }
    elseif suit == Card.Spade then
      target:skip(Player.Judge)
      target:skip(Player.Discard)
    end
  end,
}
steam__botong:addRelatedSkill(steam__botong_delay)

steam__zhengxuan:addSkill(steam__botong)

local steam__botong_choose = fk.CreateActiveSkill{
  name = "steam__botong_choose",
  card_num = 1,
  target_num = 1,
  card_filter = function(self, to_select, selected)
    return #selected == 0 and table.contains(self.steam__botong_cards or {}, to_select)
    and Fk:getCardById(to_select).suit ~= Card.NoSuit
  end,
  target_filter = function(self, to_select, selected, selected_cards)
    local to = Fk:currentRoom():getPlayerById(to_select)
    return #selected == 0 and #selected_cards == 1 and to and #to:getPile("steam__botong_pile") == 0
  end,
}
Fk:addSkill(steam__botong_choose)

local steam__yinxiu = fk.CreateTriggerSkill{
  name = "steam__yinxiu",
  anim_type = "defensive",
  frequency = Skill.Compulsory,
  events = {fk.DamageInflicted, fk.PreCardEffect},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) then
      if event == fk.PreCardEffect then
        return player.id == data.to and (data.card:isVirtual() or data.card.name ~= Fk:getCardById(data.card.id, true).name)
      else
        return ((not data.card) or (not data.from)) and target == player
      end
    end
  end,
  on_use = Util.TrueFunc,
}
steam__zhengxuan:addSkill(steam__yinxiu)

Fk:loadTranslationTable{
  ["steam__zhengxuan"] = "郑玄",
  ["#steam__zhengxuan"] = "为世儒宗",
  ["cv:steam__zhengxuan"] = "官方",
  ["designer:steam__zhengxuan"] = "emo公主",
  ["illustrator:steam__zhengxuan"] = "官方",

  ["steam__botong"] = "博通",
  [":steam__botong"] = "你的回合外，每当一名角色使用牌时，若其与上一张牌的使用者不同，你获得1枚“经”。回合开始时，你可以移去所有“经”（至少2枚）进行一次“采经”。然后你可以将获得的牌扣置于任意角色武将牌旁（每角色限一张），其下个准备阶段获得之，并按照花色获得效果："..
  "<br><font color='red'>♥</font>，获得一个出牌阶段；♣，获得一个摸牌阶段；"..
  "<br><font color='red'>♦</font>，回复一点体力；♠，跳过判定和弃牌阶段。"..
  "<br><font color='grey'><b>#采经：</b>将牌堆顶X张牌随机打乱，整理这些牌，将其中角度相同的明牌与暗牌挪动到一起消除，获得消除的牌（X为移去“经”数）。</font>",
  ["#steam__botong"] = "“采经”：将角度相同的明牌和暗牌移动到一起消除",
  ["@hf_classic"] = "经",
  ["#steam__botong_delay"] = "博通",
  ["steam__botong_pile"] = "博通",
  ["steam__botong_choose"] = "博通",
  ["#steam__botong-put"] = "博通：你可将“采经”牌扣置于任意角色武将牌旁，其下个准备阶段获得并根据花色执行效果",

  ["steam__yinxiu"] = "隐修",
  [":steam__yinxiu"] = "锁定技，虚拟牌或转化牌对你无效，防止你受到无来源或无伤害牌造成的伤害。",

  ["$steam__botong1"] = "举吾一家之见，其反诸位之解。",
  ["$steam__botong2"] = "此经已著毕，汝可视观之。",
  ["~steam__zhengxuan"] = "学海无涯，憾吾生，有涯矣……",
}



local zhangyu = General:new(extension, "steam__zhangyu", "shu", 3)
local chentu = fk.CreateTriggerSkill{
  name = "steam__chentu",
  anim_type = "support",
  events = {fk.EventPhaseStart},
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(self) and
      table.contains({Player.Start, Player.Finish}, player.phase) and
      table.find(player.room.alive_players, function (p)
        return not p:isNude()
      end)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = table.filter(room:getOtherPlayers(player), function (p)
      return not p:isNude()
    end)
    if table.find(player:getCardIds("he"), function (id)
      return not player:prohibitDiscard(id)
    end) then
      table.insert(targets, player)
    end
    local to = room:askForChoosePlayers(player, table.map(targets, Util.IdMapper), 1, 1, "#steam__chentu-choose", self.name, true)
    if #to > 0 then
      self.cost_data = {tos = to}
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(self.cost_data.tos[1])
    local n = #room:askForDiscard(to, 1, 999, true, self.name, false, nil, "#steam__chentu-discard")
    if n == 0 then return end
    local cards = room:getNCards(2 * n)
    room:moveCardTo(cards, Card.Processing, nil, fk.ReasonJustMove, self.name, nil, true, to.id)
    if not player.dead then
      local result = U.askforChooseCardsAndChoice(player, cards, {"OK"}, self.name, "#steam__chentu-swap", {"Cancel"}, 2, 2)
      if #result == 2 then
        local i1, i2 = table.indexOf(cards, result[1]), table.indexOf(cards, result[2])
        cards[i1], cards[i2] = result[2], result[1]
      end
    end
    if not to.dead then
      local result = room:askForPoxi(to, self.name, { { "Top", cards } }, nil, true)
      if #result > 0 then
        room:moveCardTo(result, Card.PlayerHand, to, fk.ReasonJustMove, self.name, nil, true, to.id)
      end
    end
    cards = table.filter(cards, function (id)
      return room:getCardArea(id) == Card.Processing
    end)
    if #cards > 0 then
      cards = table.reverse(cards)
      room:moveCards({
        ids = cards,
        toArea = Card.DrawPile,
        moveReason = fk.ReasonJustMove,
      })
    end
  end,
}
Fk:addPoxiMethod{
  name = "steam__chentu",
  prompt = function (data, extra_data)
    return "#steam__chentu"
  end,
  card_filter = function(to_select, selected, data, extra_data)
    if #selected == 0 then
      return true
    else
      return Fk:getCardById(to_select):compareColorWith(Fk:getCardById(selected[1])) and
        table.find(selected, function (id)
          return table.indexOf(data[1][2], id) + 1 == table.indexOf(data[1][2], to_select) or
            table.indexOf(data[1][2], id) - 1 == table.indexOf(data[1][2], to_select)
        end)
    end
  end,
  feasible = function(selected, data, extra_data)
    return #selected > 0
  end,
}
local kuiming = fk.CreateTriggerSkill{
  name = "steam__kuiming",
  anim_type = "control",
  events = {fk.EventPhaseProceeding},
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Judge
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    player._phase_end = true
    local cards = {}
    for _ = 1, 100, 1 do
      local judge = {
        who = player,
        reason = self.name,
        pattern = ".|.|^spade",
        skipDrop = true,
      }
      room:judge(judge)
      if judge.card then
        table.insert(cards, judge.card.id)
        if judge.card.suit == Card.Spade then
          break
        end
      end
    end
    cards = table.filter(cards, function (id)
      return room:getCardArea(id) == Card.Processing
    end)
    if #cards == 0 then return end
    if player.dead then
      room:moveCardTo(cards, Card.DiscardPile, nil, fk.ReasonJudge)
    else
      local result = room:askForGuanxing(player, cards, nil, nil, self.name, true, {"Top", "Bottom"})
      local moves = {}
      if #result.top > 0 then
        result.top = table.reverse(result.top)
        table.insert(moves, {
          ids = result.top,
          toArea = Card.DrawPile,
          moveReason = fk.ReasonJustMove,
          skillName = self.name,
          proposer = player.id,
          moveVisible = true,
          drawPilePosition = 1,
        })
      end
      if #result.bottom > 0 then
        table.insert(moves, {
          ids = result.bottom,
          toArea = Card.DrawPile,
          moveReason = fk.ReasonJustMove,
          skillName = self.name,
          proposer = player.id,
          moveVisible = true,
          drawPilePosition = -1,
        })
      end
      room:moveCards(table.unpack(moves))
    end
  end,
}
local kuiming_delay = fk.CreateTriggerSkill{
  name = "#steam__kuiming_delay",
  anim_type = "negative",
  events = {fk.TurnEnd},
  can_trigger = function (self, event, target, player, data)
    return target == player and player:usedSkillTimes("steam__kuiming", Player.HistoryTurn) > 0 and not player.dead
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    local room = player.room
    if #room:askForDiscard(player, 1, 1, false, "steam__kuiming", true, "jink", "#steam__kuiming-discard") == 0 then
      room:loseHp(player, 1, "steam__kuiming")
    end
  end,
}
kuiming:addRelatedSkill(kuiming_delay)
zhangyu:addSkill(chentu)
zhangyu:addSkill(kuiming)
Fk:loadTranslationTable{
  ["steam__zhangyu"] = "张裕",
  ["#steam__zhangyu"] = "玄目通天",
  ["illustrator:steam__zhangyu"] = "",
  ["designer:steam__zhangyu"] = "左小白",

  ["steam__chentu"] = "谶图",
  [":steam__chentu"] = "出牌阶段或结束阶段开始时，你可以指定一名角色，其可以弃置任意张牌并展示牌堆顶两倍数量的牌，然后你可以交换其中两张牌的顺序"..
  "且其可以获得任意张相邻且颜色相同的牌。",
  ["steam__kuiming"] = "窥命",
  [":steam__kuiming"] = "判定阶段，你可以改为依次进行判定直到结果为♠，然后你将判定牌以任意顺序置于牌堆顶或牌堆底；本回合结束时，"..
  "你需弃置一张【闪】或失去1点体力。",
  ["#steam__chentu-choose"] = "谶图：你可以令一名角色弃置任意张牌，展示牌堆顶两倍的牌，其可能获得其中一些牌",
  ["#steam__chentu-discard"] = "谶图：弃置任意张牌，展示牌堆顶两倍的牌，你可能获得其中一些牌",
  ["#steam__chentu-swap"] = "谶图：你可以交换其中两张牌的位置",
  ["#steam__chentu"] = "谶图：你可以获得其中任意张相邻且颜色相同的牌",
  ["#steam__kuiming_delay"] = "窥命",
  ["#steam__kuiming-discard"] = "窥命：请弃置一张【闪】，否则失去1点体力",
}

local lvbu = General:new(extension, "steam__lvbu", "qun", 5)
local yizhi = fk.CreateTriggerSkill{
  name = "steam__yizhi",
  anim_type = "drawcard",
  frequency = Skill.Compulsory,
  events = {fk.Damage},
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(self) and not player:isAllNude()
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local card1 = room:askForCard(player, 1, 1, true, self.name, false, nil, "#steam__yizhi-recast", player:getCardIds("j"))
    local card2 = room:recastCard(card1, player, self.name)
    if #card2 > 0 and Fk:getCardById(card1[1]):compareColorWith(Fk:getCardById(card2[1]), true) and not player.dead then
      player:drawCards(1, self.name)
    end
  end,
}
local qingzhen = fk.CreateActiveSkill{
  name = "steam__qingzhen",
  anim_type = "offensive",
  card_num = 0,
  min_target_num = 1,
  max_target_num = 3,
  prompt = "#steam__qingzhen",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, to_select, selected)
    return #selected < 3 and to_select ~= Self.id and not Fk:currentRoom():getPlayerById(to_select):isNude()
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    table.insert(effect.tos, player.id)
    room:sortPlayersByAction(effect.tos)
    local targets = table.map(effect.tos, Util.Id2PlayerMapper)
    local tos = {}
    for _, p in ipairs(targets) do
      if not p.dead then
        if p:isNude() then
          table.insert(tos, p.id)
        else
          local card = room:askForDiscard(p, 1, 1, true, self.name, false, nil, "#steam__qingzhen-discard")
          if #card == 0 or Fk:getCardById(card[1]).trueName ~= "slash" then
            table.insert(tos, p.id)
          end
        end
      end
    end
    if #tos == 0 then
      player:setSkillUseHistory(self.name, 0, Player.HistoryPhase)
      return
    end
    room:sortPlayersByAction(tos)
    for _, id in ipairs(tos) do
      local p = room:getPlayerById(id)
      if not p.dead then
        room:damage{
          from = player,
          to = p,
          damage = 1,
          skillName = self.name,
        }
      end
    end
  end,
}
lvbu:addSkill(yizhi)
lvbu:addSkill(qingzhen)
Fk:loadTranslationTable{
  ["steam__lvbu"] = "吕布",
  ["#steam__lvbu"] = "虎视中原",
  ["illustrator:steam__lvbu"] = "",
  ["designer:steam__lvbu"] = "o.O",

  ["steam__yizhi"] = "易帜",
  [":steam__yizhi"] = "锁定技，当你造成伤害后，你重铸区域里的一张牌，若失去牌与获得牌颜色不同，你摸一张牌。",
  ["steam__qingzhen"] = "倾阵",
  [":steam__qingzhen"] = "出牌阶段限一次，你可以令至多三名有牌的其他角色与你依次弃置一张牌，若被弃置的牌均为【杀】，你重置“倾阵”；"..
  "否则你对其中未弃置【杀】的角色各造成1点伤害。",
  ["#steam__yizhi-recast"] = "易帜：请重铸区域里的一张牌",
  ["#steam__qingzhen"] = "倾阵：与至多三名角色各弃置一张牌，若均为【杀】则重置此技能，否则你对未弃置【杀】的角色造成伤害",
  ["#steam__qingzhen-discard"] = "倾阵：请弃置一张牌，若不为【杀】则受到伤害！",
}


local bailingyun = General:new(extension, "steam__bailingyun", "wei", 3, 3, General.Female)

Fk:loadTranslationTable{
  ["steam__bailingyun"] = "柏灵筠",--MP001
  ["#steam__bailingyun"] = "花玉两似",
  ["illustrator:steam__bailingyun"] = "",
  ["designer:steam__bailingyun"] = "左小白",
  ["~steam__bailingyun"] = "",
}

local steam__qieji = fk.CreateTriggerSkill{
  name = "steam__qieji",
  events = {fk.EventPhaseStart},
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Finish
    and table.find(player.room.alive_players, function(p)
      return p:inMyAttackRange(player) and not p:isKongcheng()
    end) ~= nil
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local targets = table.filter(room.alive_players, function (p) return p:inMyAttackRange(player) and not p:isKongcheng() end)
    if #targets == 0 then return false end
    local tos = player.room:askForChoosePlayers(player, table.map(targets, Util.IdMapper), 1, 999,
    "#steam__qieji-choose", self.name, true)
    if #tos > 0 then
      room:sortPlayersByAction(tos)
      self.cost_data = {tos = tos}
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cards = {}
    local tos = table.simpleClone(self.cost_data.tos)
    local targets = table.map(tos, Util.Id2PlayerMapper)
    for _, to in ipairs(targets) do
      local cid = room:askForCardChosen(player, to, "h", self.name)
      table.insert(cards, cid)
    end
    if #cards == 0 then return end
    room:obtainCard(player, cards, true, fk.ReasonPrey, player.id, self.name)
    if player.dead then return end
    if not player:isKongcheng() then
      local n = #cards
      local move = room:askForYiji(player, player:getCardIds("h"), room.alive_players, self.name,
      0, n, "#steam__qieji-yiji:::"..n)
      for pid, cids in pairs(move) do
        if #cids > 0 then
          table.removeOne(tos, pid)
        end
      end
    end
    room:setPlayerMark(player, "@steam__qieji", tostring(#tos))
  end,
}

local steam__qieji_delay = fk.CreateTriggerSkill{
  name = "#steam__qieji_delay",
  events = {fk.DamageInflicted},
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:getMark("@steam__qieji") ~= 0 and data.card and data.card.type == Card.TypeTrick
    and data.damage ~= tonumber(player:getMark("@steam__qieji"))
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local mark = tonumber(player:getMark("@steam__qieji"))
    player:broadcastSkillInvoke("steam__qieji")
    room:notifySkillInvoked(player, "steam__qieji", mark > data.damage and "negative" or "defensive")
    data.damage = mark
  end,

  refresh_events = {fk.TurnStart},
  can_refresh = function(self, event, target, player, data)
    return target == player and player:getMark("@steam__qieji") ~= 0
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "@steam__qieji", 0)
  end,
}
steam__qieji:addRelatedSkill(steam__qieji_delay)

bailingyun:addSkill(steam__qieji)

Fk:loadTranslationTable{
  ["steam__qieji"] = "窃机",
  [":steam__qieji"] = "结束阶段，你可以获得攻击范围内含有你的任意名角色的各一张手牌并分配你等量张手牌，然后你于你的下个回合开始前受到的锦囊牌伤害基数改为X（X为这些角色中未获得牌的角色数量）。",
  ["#steam__qieji_delay"] = "窃机",
  ["steam__qieji_active"] = "窃机",
  ["#steam__qieji-choose"] = "窃机：获得攻击范围内含有你的任意名角色的各一张手牌，再分配等量张手牌",
  ["#steam__qieji-yiji"] = "窃机：请分配 %arg 张手牌（点取消自己保留）",
  ["@steam__qieji"] = "窃机",
}

---@param room Room
---@param to ServerPlayer
---@return integer[]
local doHuishi = function (room, to)
  local skillName = "steam__huishi"
  if to.dead then return {} end
  local cards = {}
  local maxNum = 0
  for _, p in ipairs(room.alive_players) do
    maxNum = math.max(maxNum, p:getHandcardNum())
  end
  local toNum = to:getHandcardNum()
  if toNum < maxNum then
    -- 若不为最大，摸1+与手牌最大差值张牌
    cards = to:drawCards(maxNum - toNum + 1, skillName)
  else
    local maxPlayers = table.filter(room.alive_players, function (p)
      return p:getHandcardNum() == maxNum
    end)
    -- 若不为唯一最大，摸1张
    if #maxPlayers > 1 then
      cards = to:drawCards(1, skillName)
    else
      -- 若为唯一最大，弃置(1+与第二大之差)张
      local secondMaxNum = 0
      for _, p in ipairs(room.alive_players) do
        if p:getHandcardNum() < maxNum then
          secondMaxNum = math.max(secondMaxNum, p:getHandcardNum())
        end
      end
      local num = maxNum - secondMaxNum + 1
      cards = room:askForDiscard(to, num, num, false, skillName, false)
    end
  end
  return cards
end

local steam__huishi = fk.CreateActiveSkill{
  name = "steam__huishi",
  anim_type = "control",
  card_num = 0,
  target_num = 1,
  card_filter = Util.FalseFunc,
  prompt = "#steam__huishi",
  target_tip = function (self, to_select, selected, selected_cards, card, selectable, extra_data)
    local maxNum = 0
    for _, p in ipairs(Fk:currentRoom().alive_players) do
      maxNum = math.max(maxNum, p:getHandcardNum())
    end
    local maxPlayers = table.filter(Fk:currentRoom().alive_players, function (p)
      return p:getHandcardNum() == maxNum
    end)
    if #maxPlayers == 1 and maxPlayers[1].id == to_select then
      return "@@steam__huishi_max"
    end
  end,
  target_filter = function(self, to_select, selected)
    return #selected == 0
  end,
  can_use = function(self, player)
    return player:getMark("steam__huishi-phase") == 0 and table.contains(player:getTableMark("@steam__huishi_record"), "steam__huishi_play")
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local to = room:getPlayerById(effect.tos[1])
    room:setPlayerMark(player, "steam__huishi-phase", 1)
    local cards = doHuishi(room, to)
    if not player.dead and #cards > 2 then
      room:removeTableMark(player, "@steam__huishi_record", "steam__huishi_play")
    end
  end,

  on_acquire = function (self, player)
    player.room:setPlayerMark(player, "@steam__huishi_record", {"steam__huishi_play", "steam__huishi_damage", "steam__huishi_death"})
  end,
  on_lose = function (self, player, is_death)
    if is_death then return end
    player.room:setPlayerMark(player, "@steam__huishi_record", 0)
  end,
}

local steam__huishi_trigger = fk.CreateTriggerSkill{
  name = "#steam__huishi_trigger",
  events = {fk.Damaged, fk.Death},
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if target == player then
      if event == fk.Damaged then
        return player:hasSkill(self) and table.contains(player:getTableMark("@steam__huishi_record"), "steam__huishi_damage")
      else
        return player:hasSkill(self, false, true) and table.contains(player:getTableMark("@steam__huishi_record"), "steam__huishi_death")
      end
    end
  end,
  on_trigger = function(self, event, target, player, data)
    self.cancel_cost = false
    local n = 1
    if event == fk.Damaged then n = data.damage end
    for i = 1, n do
      if self.cancel_cost or not self:triggerable(event, target, player, data) then break end
      self:doCost(event, target, player, data)
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local success, dat = room:askForUseActiveSkill(player, "steam__huishi", "#steam__huishi", true, {skipUse = true})
    if success and dat then
      self.cost_data = {tos = dat.targets}
      return true
    end
    self.cancel_cost = true
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(self.cost_data.tos[1])
    player:broadcastSkillInvoke("steam__huishi")
    room:notifySkillInvoked(player, "steam__huishi","control")
    local cards = doHuishi(room, to)
    if not player.dead and #cards > 2 then
      room:removeTableMark(player, "@steam__huishi_record", event == fk.Damaged and "steam__huishi_damage" or "steam__huishi_death")
    end
  end,
}
steam__huishi:addRelatedSkill(steam__huishi_trigger)
bailingyun:addSkill(steam__huishi)

Fk:loadTranslationTable{
  ["steam__huishi"] = "洄势",
  [":steam__huishi"] = "出牌阶段限一次，或当你受到1点伤害后，或死亡时，你可以令一名手牌数为/不为唯一最大的角色将手牌调整至不为/为唯一最大，若因此调整的牌数大于2，你需失去一个发动时机。",
  ["#steam__huishi"] = "洄势:令手牌数为/不为唯一最大的角色将手牌调整至不为/为唯一最大",
  ["#steam__huishi_trigger"] = "洄势",
  ["@@steam__huishi_max"] = "唯一最大",
  ["@steam__huishi_record"] = "洄势",
  ["steam__huishi_play"] = "出",
  ["steam__huishi_damage"] = "伤",
  ["steam__huishi_death"] = "死",

  ["$steam__huishi1"] = "",
  ["$steam__huishi2"] = "",
}


local subaru = General:new(extension, "steam__natsuki_subaru", "shu", 3)  --我也不知道为啥是蜀
local suhui = fk.CreateTriggerSkill{
  name = "steam__suhui",
  anim_type = "control",
  events = {fk.EventPhaseEnd},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and target.phase == Player.Finish and not target.dead and
      player:usedSkillTimes(self.name, Player.HistoryRound) == 0
  end,
  on_cost = function (self, event, target, player, data)
    if player.room:askForSkillInvoke(player, self.name, nil, "#steam__suhui-invoke::"..target.id) then
      self.cost_data = {tos = {target.id}}
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local hp_record = target:getMark("steam__suhui_record-turn")
    if hp_record == 0 then return end
    for _, p in ipairs(room:getAlivePlayers()) do
      local p_record = table.find(hp_record, function (sub_record)
        return #sub_record == 2 and sub_record[1] == p.id
      end)
      if p_record then
        p.hp = math.min(p.maxHp, p_record[2])
        room:broadcastProperty(p, "hp")
      end
    end
    if not target.dead then
      target:gainAnExtraPhase(Player.Play)
    end
  end,

  refresh_events = {fk.TurnStart},
  can_refresh = function(self, event, target, player, data)
    return target == player
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    local hp_record = {}
    for _, p in ipairs(room.alive_players) do
      table.insert(hp_record, {p.id, p.hp})
    end
    room:setPlayerMark(player, "steam__suhui_record-turn", hp_record)
  end,
}
local xiongxin = fk.CreateActiveSkill{
  name = "steam__xiongxin",
  anim_type = "control",
  card_num = 0,
  target_num = 1,
  prompt = "#steam__xiongxin",
  interaction = function (self)
    return U.CardNameBox { choices = Self:getMark(self.name), }
  end,
  can_use = Util.TrueFunc,
  card_filter = Util.FalseFunc,
  target_filter = function(self, to_select, selected, selected_cards)
    return #selected == 0 and to_select ~= Self.id and not table.contains(Self:getTableMark("steam__xiongxin-phase"), to_select) and
      not Fk:currentRoom():getPlayerById(to_select):isKongcheng()
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    room:addTableMark(player, "steam__xiongxin-phase", target.id)
    local cards = table.filter(target:getCardIds("h"), function (id)
      return Fk:getCardById(id).trueName == self.interaction.data
    end)
    U.askForUseRealCard(room, player, cards, nil, self.name,
      "#steam__xiongxin-use::"..target.id..":"..self.interaction.data, {
        bypass_times = true,
        extraUse = true,
        expand_pile = target:getCardIds("h"),
      }, false, true)
    if #cards == 0 then
      room:loseHp(player, 1, self.name)
    end
  end,

  on_acquire = function (self, player, is_start)
    local all_names = {}
    for _, card in ipairs(Fk.cards) do
      if not table.contains(Fk:currentRoom().disabled_packs, card.package.name) and not card.is_derived then
        table.insertIfNeed(all_names, card.trueName)
      end
    end
    player.room:setPlayerMark(player, self.name, all_names)
  end,
}
subaru:addSkill(suhui)
subaru:addSkill(xiongxin)
Fk:loadTranslationTable{
  ["steam__natsuki_subaru"] = "菜月昴",
  ["#steam__natsuki_subaru"] = "异界旅者",
  ["illustrator:steam__natsuki_subaru"] = "",
  ["designer:steam__natsuki_subaru"] = "",

  ["steam__suhui"] = "溯回",
  [":steam__suhui"] = "每轮限一次，一名角色回合结束时，你可以令所有角色将体力值调整为本回合开始时的数值，然后令其执行一个额外的出牌阶段。",
  ["steam__xiongxin"] = "雄心",
  [":steam__xiongxin"] = "出牌阶段每名角色限一次，你可以声明一个牌名并观看一名其他角色的手牌，若其有此牌，你可以使用之，否则你失去1点体力。",

  ["#steam__suhui-invoke"] = "溯回：是否令所有角色将体力值调整为本回合开始时，%dest 获得一个额外出牌阶段？",
  ["#steam__xiongxin"] = "雄心：声明牌名并观看一名角色手牌，若其有此牌可以使用之，否则失去1点体力",
  ["#steam__xiongxin-use"] = "雄心：你可以使用 %dest 手牌中一张【%arg】",
}









local mengda = General:new(extension, "steam__mengda", "han", 4)
mengda.subkingdom = "wei"
Fk:loadTranslationTable{
  ["steam__mengda"] = "孟达",
  ["#steam__mengda"] = "反复苟得",
  ["designer:steam__mengda"] = "emo公主",
  ["illustrator:steam__mengda"] = "错落宇宙",
}

local daigu = fk.CreateTriggerSkill{
  name = "steam__daigu",
  frequency = Skill.Compulsory,
  events = {fk.CardUseFinished},
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and target.kingdom ~= player.kingdom and target.phase == Player.Play and
    not table.contains(player:getTableMark("@steam__daigu"), target.kingdom)
    and table.every(player.room.alive_players, function (p) return not p.dying end)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cardType, kingdom = data.card:getTypeString(), target.kingdom
    local use = U.askForUseRealCard(room, player, nil, ".|.|.|.|.|"..cardType, self.name, "#steam__daigu-use:::"..cardType..":"..kingdom)
    if not use then
      player:drawCards(2, self.name)
      if player.dead then return end
      room:addTableMark(player, "@steam__daigu", kingdom)
      if table.every(room.alive_players, function (p)
        return p.kingdom == player.kingdom or table.contains(player:getTableMark("@steam__daigu"), p.kingdom)
      end) then
        local skillToGet = "goude"
        local kingdoms = {}
        for _, p in ipairs(room.alive_players) do
          if p.kingdom ~= player.kingdom then
            table.insertIfNeed(kingdoms, p.kingdom)
          end
        end
        if #kingdoms > 0 then
          local choice = room:askForChoice(player, kingdoms, self.name, "#steam__daigu-change")
          room:changeKingdom(player, choice, true)
          if player.dead then return end
          local skills = {}
          local ignoreBlacklist = false -- 是否无视禁表
          local isLord = (player.role == "lord" and player.role_shown)
          for _, g in pairs(Fk.generals) do
            if not g.hidden and not g.total_hidden then
              if ignoreBlacklist or Fk:canUseGeneral(g.name) then
                for _, skill in ipairs(g.skills) do
                  if table.contains(skill.attachedKingdom or {}, player.kingdom) and not (skill.lordSkill and not isLord) then
                    table.insertIfNeed(skills, skill.name)
                  end
                end
              end
            end
          end
          if #skills > 0 then
            skillToGet = table.random(skills)
          end
        end
        room:handleAddLoseSkills(player, "-"..self.name.."|"..skillToGet)
        if not player.dead then
          U.askForUseVirtualCard(room, player, "slash", nil, self.name, nil, false, true, true, true)
        end
      end
    end
  end,

  on_lose = function (self, player)
    player.room:setPlayerMark(player, "@steam__daigu", 0)
  end,
}
mengda:addSkill(daigu)
mengda:addRelatedSkill("goude")
Fk:loadTranslationTable{
  ["steam__daigu"] = "待沽",
  [":steam__daigu"] = "锁定技，与你势力不同的角色于出牌阶段使用牌后，若无濒死角色，你需使用一张同类型牌，否则你摸两张牌且对此势力不再询问，若无可发动势力，你变更为场上其他势力，将本技能替换为当前势力的势力技（若无改为【苟得】），然后视为使用一张【杀】。",
  ["@steam__daigu"] = "待沽",
  ["#steam__daigu-use"] = "待沽：你需使用一张%arg，否则摸2张牌，且不再对【%arg2】势力询问【待沽】",
  ["#steam__daigu-change"] = "待沽：请变为一个场上势力！",

  ["$steam__daigu1"] = "我有武力傍身，必可待价而沽。",
  ["$steam__daigu2"] = "气节？可当粟米果腹乎！",
}

local wenyuan = General:new(extension, "steam__wenyuan", "shu", 3, 3, General.Female)
Fk:loadTranslationTable{
  ["steam__wenyuan"] = "文鸳",
  ["#steam__wenyuan"] = "揾泪红袖",
  ["designer:steam__wenyuan"] = "从珂",
  ["illustrator:steam__wenyuan"] = "匠人绘",
  ["~steam__wenyuan"] = "伯约，回家了。",
}

local kengqiang = fk.CreateViewAsSkill{
  name = "steam__kengqiang",
  anim_type = "offensive",
  pattern = "duel,fire_attack",
  prompt = "#steam__kengqiang",
  interaction = function(self)
    return U.CardNameBox { choices = {"duel", "fire_attack"} }
  end,
  card_filter = Util.FalseFunc,
  view_as = function(self, cards)
    if not self.interaction.data then return nil end
    local c = Fk:cloneCard(self.interaction.data)
    c.skillName = self.name
    return c
  end,
  enabled_at_play = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) < 2
  end,
  enabled_at_response = Util.FalseFunc,
}
local kengqiang_trigger = fk.CreateTriggerSkill{
  name = "#steam__kengqiang_trigger",
  anim_type = "offensive",
  main_skill = kengqiang, 
  events = {fk.DamageCaused},
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(kengqiang) then
      return player:usedSkillTimes(kengqiang.name, Player.HistoryPhase) < 2
    end
  end,
  on_cost = function (self, event, target, player, data)
    if player.room:askForSkillInvoke(player, self.name, nil, "#steam__qingshi-damage:"..data.to.id) then
      self.cost_data = {tos = {data.to.id}}
      return true
    end
  end,
  on_use = function (self, event, target, player, data)
    player:broadcastSkillInvoke(kengqiang.name)
    data.damage = data.damage + 1
  end,
}
kengqiang:addRelatedSkill(kengqiang_trigger)
wenyuan:addSkill(kengqiang)

Fk:loadTranslationTable{
  ["steam__kengqiang"] = "铿锵",
  [":steam__kengqiang"] = "出牌阶段限两次，你可以视为使用一张【火攻】或【决斗】；你造成伤害时，你可以令此伤害+1。",
  ["#steam__kengqiang_trigger"] = "铿锵",
  ["#steam__qingshi-damage"] = "铿锵：你对%src造成伤害，可令伤害值+1",
  ["#steam__kengqiang"] = "铿锵：视为使用一张【火攻】或【决斗】",

  ["$steam__kengqiang1"] = "女子着征袍，战意越关山。",
  ["$steam__kengqiang2"] = "兴武效妇好，挥钺断苍穹！",
}

local shangjue = fk.CreateActiveSkill{
  name = "steam__shangjue",
  frequency = Skill.Limited,
  card_num = 0,
  target_num = 0,
  prompt = "#steam__shangjue",
  card_filter = Util.FalseFunc,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryGame) == 0
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    if player.dead then return end
    local n = player.hp - 1
    if n > 0 then
      room:loseHp(player, n, self.name)
    elseif n < 0 then
      room:recover { num = -n, skillName = self.name, who = player, recoverBy = player }
    end
    if player.dead then return end
    room:changeMaxHp(player, 1)
    if player.dead then return end
    local ids = room:getBanner("@$CenterArea") or {}
    if #ids > 0 then
      room:obtainCard(player, ids, true, fk.ReasonJustMove, player.id, self.name)
    end
  end,
}
local shangjue_trigger = fk.CreateTriggerSkill{
  name = "#steam__shangjue_trigger",
  anim_type = "offensive",
  main_skill = shangjue,
  events = {fk.EnterDying},
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(shangjue) then
      return player:usedSkillTimes(shangjue.name, Player.HistoryGame) == 0
    end
  end,
  on_use = function (self, event, target, player, data)
    player:broadcastSkillInvoke(shangjue.name)
    shangjue:onUse(player.room, { from = player.id, tos = {}, cards = {} })
  end,
}
shangjue:addRelatedSkill(shangjue_trigger)
shangjue.CenterArea = true
wenyuan:addSkill(shangjue)

Fk:loadTranslationTable{
  ["steam__shangjue"] = "殇决",
  [":steam__shangjue"] = "限定技，当你进入濒死时或出牌阶段，你可以将体力调整至1点，加1点体力上限，并获得中央区所有牌。",
  ["#steam__shangjue"] = "殇决：将体力调整至1点，加1点体力上限，并获得中央区所有牌",
  ["#steam__shangjue_trigger"] = "殇决",

  ["$steam__shangjue1"] = "伯约，奈何桥畔，再等我片刻。",
  ["$steam__shangjue2"] = "与君同生共死，岂可空待黄泉！",
}

local wenyuan2 = General:new(extension, "steam2__wenyuan", "han", 3, 3, General.Female)
Fk:loadTranslationTable{
  ["steam2__wenyuan"] = "文鸳",
  ["#steam2__wenyuan"] = "揾泪红袖",
  ["designer:steam2__wenyuan"] = "从珂",
  ["illustrator:steam2__wenyuan"] = "VE",
  ["~steam2__wenyuan"] = "秋风起，天意凉，独立黄昏愁满肠。",
}

local kunli = fk.CreateTriggerSkill{
  name = "steam__kunli",
  anim_type = "drawcard",
  events = {fk.TurnEnd},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) then
      local drawNum, damageNum = 0, 0
      player.room.logic:getActualDamageEvents(1, function(e)
        local damage = e.data[1]
        if damage.from == player then
          damageNum = damageNum + damage.damage
        end
        return false
      end)
      player.room.logic:getEventsOfScope(GameEvent.MoveCards, 1, function(e)
        for _, move in ipairs(e.data) do
          if move.to == player.id and move.toArea == Card.PlayerHand then
            drawNum = drawNum + #table.filter(move.moveInfo, function (info)
              return info.fromArea == Card.DrawPile
            end)
          end
        end
        return false
      end, Player.HistoryTurn)
      if drawNum > 0 and drawNum <= damageNum then
        self.cost_data = {both = drawNum == damageNum}
        return true
      end
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:drawCards(2, self.name)
    if self.cost_data.both then
      room:handleAddLoseSkills(player, "-"..self.name.."|steam__qingbei")
    end
  end,
}
wenyuan2:addSkill(kunli)
wenyuan2:addRelatedSkill("steam__qingbei")

Fk:loadTranslationTable{
  ["steam__kunli"] = "困励",
  [":steam__kunli"] = "每回合结束时，若你本回合摸牌数大于0且不大于造成的伤害数，你摸两张牌，若相等，你失去此技能并获得“倾北”。",
  
  ["$steam__kunli1"] = "回首万重山，难阻轻舟一叶。",
  ["$steam__kunli2"] = "已过山穷水尽，前有柳暗花明。",
}

local kuichi = fk.CreateTriggerSkill{
  name = "steam__kuichi",
  anim_type = "drawcard",
  events = {fk.TurnStart},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) then
      local turnEvent = player.room.logic:getCurrentEvent():findParent(GameEvent.Turn, true)
      if not turnEvent then return false end
      local lastTurn
      local events = player.room.logic.event_recorder[GameEvent.Turn] or Util.DummyTable
      for i = #events, 1, -1 do
        local e = events[i]
        if e.id < turnEvent.id then
          lastTurn = e
          break
        end
      end
      if not lastTurn then return false end
      local drawNum, damageNum = 0, 0
      -- 倒序找
      player.room.logic:getActualDamageEvents(1, function(e)
        if e.id > turnEvent.id then return false end
        local damage = e.data[1]
        if damage.from == player then
          damageNum = damageNum + damage.damage
        end
        return false
      end, nil, lastTurn.id)
      player.room.logic:getEventsByRule(GameEvent.MoveCards, 1, function(e)
        if e.id > turnEvent.id then return false end
        for _, move in ipairs(e.data) do
          if move.to == player.id and move.toArea == Card.PlayerHand then
            drawNum = drawNum + #table.filter(move.moveInfo, function (info)
              return info.fromArea == Card.DrawPile
            end)
          end
        end
        return false
      end, lastTurn.id)
      if damageNum > 0 and damageNum <= drawNum then
        self.cost_data = {both = drawNum == damageNum}
        return true
      end
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local tos = room:askForChoosePlayers(player, table.map(room.alive_players, Util.IdMapper), 1, 1, "#steam__kuichi-damage", self.name, false)
    if #tos > 0 then
      room:damage { from = player, to = room:getPlayerById(tos[1]), damage = 1, skillName = self.name }
    end
    if self.cost_data.both then
      room:handleAddLoseSkills(player, "-"..self.name.."|steam__qingbei")
    end
  end,
}
wenyuan2:addSkill(kuichi)
wenyuan2:addRelatedSkill("steam__ranji")

Fk:loadTranslationTable{
  ["steam__kuichi"] = "匮饬",
  [":steam__kuichi"] = "每回合开始时，若你上回合造成的伤害数大于0且不大于摸牌数，你造成1点伤害，若相等，你失去此技能并获得“燃己”。",
  ["#steam__kuichi-damage"] = "匮饬：请对一名角色造成1点伤害",
  
  ["$steam__kuichi1"] = "久战沙场，遗伤无数。",
  ["$steam__kuichi2"] = "人无完人，千虑亦有一失。",
}


local majun = General:new(extension, "steam__majun", "wei", 3)

Fk:loadTranslationTable{
  ["steam__majun"] = "马钧",
  ["#steam__majun"] = "大魏发明家",
  ["cv:steam__majun"] = "",
  ["designer:steam__majun"] = "emo公主",
  ["illustrator:steam__majun"] = "第七个橘子",
}

local qiaosi_card_record = {}

local qiaosi = fk.CreateTriggerSkill{
  name = "steam__qiaosi",
  frequency = Skill.Compulsory,
  anim_type = "drawcard",
  events = {fk.GameStart},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local pname = player._splayer:getScreenName()
    if pname and pname ~= "" then
      local cards = qiaosi_card_record[pname]
      if cards and #cards > 0 then
        local get = {}
        for _, info in ipairs(cards) do
          local cardname = info[1]
          local fakecard = Fk:cloneCard(cardname)
          if cardname == "xbow" or -- 特判一下连弩
           (not fakecard.is_derived and fakecard.package and not table.contains(room.disabled_packs, fakecard.package.name)) then
            table.insert(get, room:printCard(info[1], info[2], info[3]).id)
          end
        end
        if #get == 0 then return end
        room:obtainCard(player, get, false, fk.ReasonJustMove, player.id, self.name)
      end
    end
  end,
}
majun:addSkill(qiaosi)

-- 注意：由于退出房间导致checkNoHuman导致的结束游戏，不会记录
local qiaosi_record = fk.CreateTriggerSkill{
  name = "steam__qiaosi_record",
  global = true,

  refresh_events = {fk.GameFinished, fk.Death},
  can_refresh = function(self, event, target, player, data)
    if event == fk.Death then
      return target == player and not player:isNude()
    end
    return true
  end,
  on_refresh = function(self, event, target, player, data)
    if event == fk.Death then
      player.tag["steam__qiaosi_deathcard"] = player:getCardIds("he")
      return
    end
    local pname = player._splayer:getScreenName()
    if pname and pname ~= "" then
      local cards = player:getCardIds("he")
      if #cards == 0 then
        cards = player.tag["steam__qiaosi_deathcard"]
        if cards == nil or #cards == 0 then return end
      end
      cards = table.random(cards, 4)
      cards = table.map(cards, function(id)
        local card = Fk:getCardById(id)
        return {card.name, card.suit, card.number}
      end)
      qiaosi_card_record[pname] = cards
    end
  end,
}
Fk:addSkill(qiaosi_record)

Fk:loadTranslationTable{
  ["steam__qiaosi"] = "巧思",
  [":steam__qiaosi"] = "锁定技，游戏开始时，你获得上局你死亡时或游戏结束时你的牌（至多4张）。",
  
  ["$steam__qiaosi1"] = "另辟蹊径博君乐，盛世美景百戏中。",
  ["$steam__qiaosi2"] = "机关精巧，将军可看在眼里？",
}

local jingxie = fk.CreateActiveSkill{
  name = "steam__jingxie",
  anim_type = "drawcard",
  card_num = 0,
  target_num = 0,
  card_filter = Util.FalseFunc,
  prompt = "#steam__jingxie",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local get = {}
    for _, t in ipairs({"basic", "trick", "equip"}) do
      local let = room:getCardsFromPileByRule(".|.|.|.|.|"..t, 1, "allPiles")[1]
      if let then
        table.insert(get, let)
      end
    end
    if #get > 0 then
      room:obtainCard(player, get, true, fk.ReasonJustMove, player.id, self.name)
      if player.dead or player:isNude() then return end
      room:askForDiscard(player, 2, 2, true, self.name, false)
    end
  end,
}
majun:addSkill(jingxie)

Fk:loadTranslationTable{
  ["steam__jingxie"] = "精械",
  [":steam__jingxie"] = "出牌阶段限一次，你可以获得每种类型的牌各一张，然后弃置两张牌。",
  ["#steam__jingxie"] = "精械：获得每种类型的牌各一张，再两张牌",
  
  ["$steam__jingxie1"] = "吾所欲作者，国之精器、军之要用也。",
  ["$steam__jingxie2"] = "路未尽，铸不止。",
}

local liuchen = General:new(extension, "steam__liuchen", "han", 4)
Fk:loadTranslationTable{
  ["steam__liuchen"] = "刘谌",
  ["#steam__liuchen"] = "血荐轩辕",
  ["designer:steam__liuchen"] = "emo公主",
}

local zhanjue = fk.CreateViewAsSkill{
  name = "steam__zhanjue",
  anim_type = "offensive",
  prompt = function (self)
    local mark = Self:getMark(self.name)
    if Self:getMark("@@steam__zhanjue") == 0 then
      return "#steam__zhanjue-card:::"..mark
    else
      return "#steam__zhanjue-hp:::"..mark
    end
  end,
  card_filter = function(self, to_select, selected)
    if Self:prohibitDiscard(to_select) or not table.contains(Self.player_cards[Player.Hand], to_select) then return false end
    if Self:getMark("@@steam__zhanjue") == 0 then
      local x = Self:getHandcardNum() - Self:getMark(self.name)
      if x > 0 then
        return #selected < x
      end
    end
  end,
  view_as = function(self, cards)
    if Self:getMark("@@steam__zhanjue") == 0 then
      local x = Self:getHandcardNum() - Self:getMark(self.name)
      if x > 0 and #cards ~= x then return nil end
    end
    local card = Fk:cloneCard("duel")
    card.skillName = self.name
    if #cards > 0 then
      card:setMark(self.name, cards)
    end
    return card
  end,
  before_use = function(self, player, use)
    local room = player.room
    local mark = player:getMark(self.name)
    if player:getMark("@@steam__zhanjue") == 0 then
      local x = mark - player:getHandcardNum()
      if x > 0 then
        player:drawCards(x, self.name)
      else
        local discards = use.card:getMark(self.name)
        if type(discards) == "table" then
          room:throwCard(discards, self.name, player, player)
        end
      end
    else
      local x = mark - player.hp
      if x > 0 then
        room:recover { num = x, skillName = self.name, who = player, recoverBy = player }
      else
        room:loseHp(player, -x, self.name)
      end
    end
    if not player.dead then
      if mark == 0 and player:getMark("@@steam__zhanjue") == 0 then
        room:setPlayerMark(player, self.name, 4)
        room:setPlayerMark(player, "@@steam__zhanjue", 1)
      else
        room:setPlayerMark(player, self.name, mark - 1)
      end
    end
  end,
  after_use = function (self, player, use)
    local room = player.room
    if use and use.damageDealt then
      for pid, _ in pairs(use.damageDealt) do
        local to = room:getPlayerById(pid)
        if not to.dead then
          to:drawCards(1, self.name)
        end
      end
    end
  end,
  enabled_at_play = function(self, player)
    local mark = player:getMark(self.name)
    if player:getMark("@@steam__zhanjue") == 0 then
      return player:getHandcardNum() ~= mark
    else
      -- 标记值大于体力上限时，无法调整至标记值
      return player.hp ~= mark and mark <= player.maxHp
    end
  end,
  enabled_at_response = Util.FalseFunc,
  on_acquire = function (self, player, is_start)
    player.room:setPlayerMark(player, self.name, 4)
  end,
  on_lose = function (self, player, is_death)
    player.room:setPlayerMark(player, self.name, 0)
    player.room:setPlayerMark(player, "@@steam__zhanjue", 0)
  end,

  dynamic_desc = function (self, player, lang)
    if player:getMark("@@steam__zhanjue") == 0 then
      return "steam__zhanjue_dyn:"..player:getMark(self.name)
    else
      return "steam__zhanjue_dyn_hp:"..player:getMark(self.name)
    end
  end,
}
liuchen:addSkill(zhanjue)

local qinwang = fk.CreateViewAsSkill{
  name = "steam__qinwang$",
  anim_type = "offensive",
  pattern = "slash",
  prompt = function ()
    if table.every(Fk:currentRoom().alive_players, function (p)
      return p == Self or (p.kingdom ~= "han" and p.kingdom ~= "shu")
    end) then
      return "#steam__qinwang-pile"
    end
    return "#steam__qinwang"
  end,
  card_filter = function(self, to_select, selected)
    return #selected < 2
  end,
  view_as = function(self, cards)
    if #cards ~= 2 then return nil end
    local c = Fk:cloneCard("slash")
    c.skillName = self.name
    c:setMark(self.name, cards)
    return c
  end,
  before_use = function(self, player, use)
    local room = player.room
    local cards = use.card:getMark(self.name)
    if cards == nil then return "" end
    local targets = table.map(table.filter(room.alive_players, function (p)
      return (p.kingdom == "han" or p.kingdom == "shu") and p ~= player
    end), Util.IdMapper)
    local slash
    if #targets == 0 then
      -- 将选择的两张牌置于牌堆底
      room:moveCards{
        from = player.id,
        ids = cards,
        toArea = Card.DrawPile,
        moveReason = fk.ReasonPut,
        skillName = self.name,
        moveVisible = false,
        proposer = player.id,
        drawPilePosition = -1,
      }
      -- 翻开牌堆顶牌直到有【杀】
      for i = 1, 20 do
        local top = room:getNCards(1)
        room:moveCardTo(top, Card.Processing, nil, fk.ReasonJustMove, self.name, nil, true, player.id)
        room:delay(400)
        local c = Fk:getCardById(top[1])
        if c.trueName == "slash" then
          room:setCardEmotion(c.id, "judgegood")
          slash = c
          break
        end
        room:cleanProcessingArea(top, self.name)
        if i > 4 and math.random() < 0.5 then break end
      end
    else
      local tos = room:askForChoosePlayers(player, targets, 1, 1, "#steam__qinwang-choose", self.name, false)
      local to = room:getPlayerById(tos[1])
      room:moveCardTo(cards, Card.PlayerHand, to, fk.ReasonGive, self.name, nil, false, player.id)
      if not to.dead then
        local slash_ask = room:askForResponse(to, "slash", "slash", "#steam__qinwang-ask:"..player.id, true)
        if slash_ask then
          room:responseCard({
            from = to.id,
            card = slash_ask,
            skipDrop = true,
          })
          slash = slash_ask
        end
      end
    end
    if slash then
      use.card = slash
    else
      room:loseHp(player, 1, self.name)
      return self.name
    end
  end,
  enabled_at_play = Util.FalseFunc,
  enabled_at_response = function (self, player, response)
    return #player:getCardIds("he") > 1 and response
  end,
}
liuchen:addSkill(qinwang)

Fk:loadTranslationTable{
  ["steam__zhanjue"] = "战绝",
  [":steam__zhanjue"] = "你可以将手牌数调整为4并令此数值-1，视为使用一张令受伤角色摸一张牌的【决斗】。此值首次减至负后，重置为4且改为调整体力值。",
  ["#steam__zhanjue"] = "",
  ["@@steam__zhanjue"] = "战绝 体力",
  ["#steam__zhanjue-card"] = "战绝：将手牌数调整为%arg，视为使用令受伤角色摸一张牌的【决斗】",
  ["#steam__zhanjue-hp"] = "战绝：将体力值调整为%arg，视为使用令受伤角色摸一张牌的【决斗】",
  [":steam__zhanjue_dyn"] = "你可以将手牌数调整为{1}并令此数值-1，视为使用一张令受伤角色摸一张牌的【决斗】。此值首次减至负后，重置为4且改为调整体力值。",
  [":steam__zhanjue_dyn_hp"] = "你可以将体力值调整为{1}并令此数值-1，视为使用一张令受伤角色摸一张牌的【决斗】。",
  
  ["steam__qinwang"] = "勤王",
  [":steam__qinwang"] = "主公技，你可以将两张牌交给一名汉或蜀势力角色，请求其替你打出一张【杀】，若拒绝，你失去1点体力。若无符合角色，改为请求牌堆！",
  ["#steam__qinwang"] = "勤王：选择两张牌交给一名蜀汉势力角色，请求其出杀",
  ["#steam__qinwang-pile"] = "勤王：选择两张牌置于牌堆底，请求牌堆出杀！",
  ["#steam__qinwang-ask"] = "勤王: 你可以代替 %src 使用或打出【杀】",
  ["#steam__qinwang-choose"] = "勤王:选择一名汉或蜀势力角色，请求其出【杀】",

  ["$steam__zhanjue1"] = "成败在此一举，杀！",
  ["$steam__zhanjue2"] = "此刻，唯有死战，安能言降！",
  ["$steam__qinwang1"] = "大厦倾危，谁堪栋梁！",
  ["$steam__qinwang2"] = "国有危难，哪位将军请战？",
}






local ganfuren = General:new(extension, "steam__ganfuren", "shu", 3, 3, General.Female)
Fk:loadTranslationTable{
  ["steam__ganfuren"] = "甘夫人",
  ["#steam__ganfuren"] = "淑芬达婷",
  ["illustrator:steam__ganfuren"] = "",
  ["designer:steam__ganfuren"] = "慕晴mqi",
  ["~steam__ganfuren"] = "只愿夫君，大事可成，兴汉有期……",
}

local shenzhi = fk.CreateTriggerSkill{
  name = "steam__shenzhi",
  events = {fk.EventPhaseStart},
  anim_type = "drawcard",
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) and target == player then
      return player.phase == Player.Start
    end
  end,
  on_cost = function (self, event, target, player, data)
    local _, dat = player.room:askForUseActiveSkill(player, "#steam__shenzhi_active", "#steam__shenzhi-choose", true)
    if dat then
      self.cost_data = {tos = dat.targets, choice = dat.interaction}
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local tar = room:getPlayerById(self.cost_data.tos[1])
    local from = self.cost_data.choice == "steam__shenzhi_me" and player or tar
    local to = from == player and tar or player
    room:useVirtualCard("artful_graft", nil, from, to, self.name)
  end,
}

local shenzhi_active = fk.CreateActiveSkill{
  name = "#steam__shenzhi_active",
  card_num = 0,
  target_num = 1,
  card_filter = Util.FalseFunc,
  interaction = function(self, player)
    local all_choices = {"steam__shenzhi_me", "steam__shenzhi_you"}
    local choices = {all_choices[2]}
    if not player:isNude() then
      table.insert(choices, 1, all_choices[1])
    end
    return UI.ComboBox { choices = choices, all_choices = all_choices }
  end,
  target_filter = function(self, to_select, selected, _, _, _, player)
    local to = Fk:currentRoom():getPlayerById(to_select)
    return #selected == 0 and player.id ~= to_select and not (self.interaction.data == "steam__shenzhi_you" and to:isNude())
  end,
}
Fk:addSkill(shenzhi_active)
ganfuren:addSkill(shenzhi)
Fk:loadTranslationTable{
  ["steam__shenzhi"] = "神智",
  [":steam__shenzhi"] = "准备阶段，你可以选择一名其他角色，视为你对其或其对你使用一张【移花接木】。",
  ["#steam__shenzhi_active"] = "神智",
  ["#steam__shenzhi-choose"] = "神智：选择一名其他角色，选择你对其，或其对你使用【移花接木】",
  ["steam__shenzhi_me"] = "你对其使用",
  ["steam__shenzhi_you"] = "令其对你使用",

  ["$steam__shenzhi1"] = "昔子罕不以玉为宝，《春秋》美之。",
  ["$steam__shenzhi2"] = "今吴、魏未灭，安以妖玩继怀？",
}

local shushen = fk.CreateTriggerSkill{
  name = "steam__shushen",
  anim_type = "support",
  events = {fk.AfterCardsMove},
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(self) or not player:isKongcheng() then return end
    for _, move in ipairs(data) do
      if move.from == player.id then
        for _, info in ipairs(move.moveInfo) do
          if info.fromArea == Card.PlayerHand then
            return true
          end
        end
      end
    end
  end,
  on_cost = function (self, event, target, player, data)
    local targets = table.map(player.room.alive_players, Util.IdMapper)
    if #player:getCardIds("he") < 2 then
      table.removeOne(targets, player.id)
    end
    local tos = player.room:askForChoosePlayers(player, targets, 1, 1, "#steam__shushen-choose", self.name, true)
    if #tos > 0 then
      self.cost_data = {tos = tos}
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(self.cost_data.tos[1])
    if #to:getCardIds("he") > 1 then
      local prompt, cancancel
      if to == player then
        cancancel = false
        prompt = "#steam__shushen-recastself"
      else
        cancancel = true
        prompt = "#steam__shushen-recast"
      end
      local cards = room:askForCard(to, 2, 2, true, self.name, cancancel, nil, prompt)
      if #cards > 0 then
        room:recastCard(cards, to, self.name)
        return
      end
    end
    if to ~= player then
      to:drawCards(2, self.name)
      if not to.dead and player:hasShownSkill(self, true) then
        room:handleAddLoseSkills(player, "-"..self.name)
        room:handleAddLoseSkills(to, self.name)
      end
    end
  end,
}
ganfuren:addSkill(shushen)

Fk:loadTranslationTable{
  ["steam__shushen"] = "淑慎",
  [":steam__shushen"] = "当你失去最后一张手牌后，你可以令一名角色选择重铸两张牌，或摸两张牌并将此技能转移至其。",
  ["#steam__shushen-choose"] = "淑慎：你可以令一名角色重铸两张牌，若其未重铸，其摸2张并获得此技能",
  ["#steam__shushen-recast"] = "淑慎：请重铸两张牌，取消：摸两张牌并获得技能“淑慎”",
  ["#steam__shushen-recastself"] = "淑慎：请重铸两张牌",

  ["$steam__shushen1"] = "此者国亡之象，夫君岂不知乎？",
  ["$steam__shushen2"] = "为人妻者，当为夫计。",
}





--[[
【英贤】
主公技，游戏开始时，你可以令一名其他西势力角色从剩余武将牌中观看5张西势力武将并选一张，其选一项：1.用此牌替换其武将牌；2.令你摸等于其名字长度张牌。
--]]


local zhujianping = General:new(extension, "steam__zhujianping", "qun", 3)
Fk:loadTranslationTable{
  ["steam__zhujianping"] = "朱建平",
  ["#steam__zhujianping"] = "晓通命理",
  ["designer:steam__zhujianping"] = "胼躇",
  ["illustrator:steam__zhujianping"] = "君桓文化",
  ["~steam__zhujianping"] = "相者千算，难避一失。",
}

local kuitian = fk.CreateTriggerSkill{
  name = "steam__kuitian",
  refresh_events = {fk.PreCardUse, fk.PreCardRespond},
  can_refresh = function(self, event, target, player, data)
    if player:hasSkill(self, true) then
      local cards = Card:getIdList(data.card)
      if #cards == 0 then return end
      local i = player.maxHp - player:getMark("steam__kuitian-round")
      if i < 1 then return end
      local id = player.room.draw_pile[i]
      return id and table.contains(cards, id)
    end
  end,
  on_refresh = function(self, event, target, player, data)
    player:broadcastSkillInvoke(self.name)
    player.room:notifySkillInvoked(player, self.name)
    player.room:addPlayerMark(player, "steam__kuitian-round", 1)
  end,
}
local kuitian_filter = fk.CreateFilterSkill{
  name = "#steam__kuitian_filter",
  handly_cards = function (self, player)
    if player:hasSkill(kuitian) then
      local i = player.maxHp - player:getMark("steam__kuitian-round")
      if i > 0 then
        local id = Fk:currentRoom().draw_pile[i]
        if id then
          return {id}
        end
      end
    end
  end,
}
kuitian:addRelatedSkill(kuitian_filter)
zhujianping:addSkill(kuitian)

Fk:loadTranslationTable{
  ["steam__kuitian"] = "窥天",
  [":steam__kuitian"] = "锁定技，牌堆顶的第X张牌始终由你可见，你可以使用或打出此牌，然后本轮此可见牌前移一位。(X为你的体力上限)",
  ["#steam__kuitian_filter"] = "窥天",

  ["$steam__kuitian1"] = "天有其道，顺之则昌。",
  ["$steam__kuitian2"] = "胸怀异术，可得天佑。",
}

local shixiang = fk.CreateActiveSkill{
  name = "steam__shixiang",
  frequency = Skill.Limited,
  prompt = "#steam__shixiang",
  card_num = 0,
  target_num = 1,
  card_filter = Util.FalseFunc,
  target_filter = function(self, to_select, selected, _, _, _, player)
    local to = Fk:currentRoom():getPlayerById(to_select)
    return #selected == 0 and player.id ~= to_select and to:isWounded()
  end,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryGame) == 0
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local to = room:getPlayerById(effect.tos[1])
    room:recover { num = to.maxHp - to.hp, skillName = self.name, who = to, recoverBy = player }
    if to:isAlive() then
      room:setPlayerMark(to, "@@steam__shixiang", 1)
    end
  end,
}
local shixiang_delay = fk.CreateTriggerSkill{
  name = "#steam__shixiang_delay",
  refresh_events = {fk.BeforeHpChanged},
  can_refresh = function(self, event, target, player, data)
    return target == player and player:getMark("@@steam__shixiang") ~= 0 and data.num ~= 0
  end,
  on_refresh = function(self, event, target, player, data)
    player:broadcastSkillInvoke(shixiang.name)
    player.room:notifySkillInvoked(player, self.name, "negative")
    data.num = data.num + (data.num > 0 and 1 or -1)
  end,
}
shixiang:addRelatedSkill(shixiang_delay)
zhujianping:addSkill(shixiang)

Fk:loadTranslationTable{
  ["steam__shixiang"] = "饰相",
  [":steam__shixiang"] = "限定技，出牌阶段，你可以令一名已受伤的其他角色将体力回复至上限，然后本局游戏其体力值即将变化时，此变化值+1。",
  ["#steam__shixiang"] = "饰相：令一名已受伤的其他角色将体力回复至上限，其本局游戏体力变化值+1",
  ["@@steam__shixiang"] = "饰相",
  ["#steam__shixiang_delay"] = "饰相",

  ["$steam__shixiang1"] = "命运多舛，福祸莫测。",
  ["$steam__shixiang2"] = "人生茫茫，旦夕难保。",
}






local Jeanne = General:new(extension, "steam__joanofarc", "west", 3, 4, General.Female)
Fk:loadTranslationTable{
  ["steam__joanofarc"] = "贞德",
  ["#steam__joanofarc"] = "奥尔良的圣女",
  ["designer:steam__joanofarc"] = "emo公主",
  ["illustrator:steam__joanofarc"] = "曙光英雄",
}
local yuanlin_vs = fk.CreateViewAsSkill{
  name = "steam__yuanlin_vs",
  card_filter = function(self, to_select, selected)
    return #selected == 0
  end,
  view_as = function(self, cards)
    if #cards ~= 1 then return nil end
    local c = Fk:cloneCard("peach")
    c.skillName = "steam__yuanlin"
    c:addSubcard(cards[1])
    return c
  end,
}
Fk:addSkill(yuanlin_vs)
local yuanlin = fk.CreateTriggerSkill{
  name = "steam__yuanlin",
  anim_type = "offensive",
  frequency = Skill.Compulsory,
  events = {fk.RoundStart},
  can_trigger = function (self, event, target, player, data)
    if not player:hasSkill(self) then return false end
    return (player.room:getBanner("RoundCount") or 0) % 2 == 1
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local n = 0
    local cards = player:getCardIds("e")
    if #cards > 0 then
      n = #cards
      room:moveCardTo(cards, Card.DiscardPile, nil, fk.ReasonJustMove, self.name, nil, true, player.id)
    end
    if player.hp > 0 then
      n = n + player.hp
      room:loseHp(player, player.hp, self.name)
    end
    if not player.dead then
      player:drawCards(n, self.name)
    end
    while player:isAlive() and player:isWounded() and not player:isNude() do
      local _, dat = room:askForUseViewAsSkill(player, "steam__yuanlin_vs", "#steam__yuanlin-use", true)
      if not dat then break end
      local card = yuanlin_vs:viewAs(dat.cards, player)
      if card then
        if card.suit ~= Card.NoSuit then
          room:addTableMarkIfNeed(player, "@steam__yuanlin", card:getSuitString(true))
        end
        room:useCard{from = player.id, tos = {{player.id}}, card = card}
      end
    end
    if player.dead then return end
    local mark = player:getTableMark("@steam__yuanlin")
    for _, id in ipairs(player:getCardIds("h")) do
      local card = Fk:getCardById(id)
      if not table.contains(mark, card:getSuitString(true)) then
        room:setCardMark(card, "@@steam__yuanlin-inhand", 1)
      end
    end
    player:filterHandcards()
    room:setPlayerMark(player, "@steam__yuanlin", 0)
    if player.hp < 1 then
      room:enterDying{who = player.id}
    end
  end,

  refresh_events = {fk.BeforeHpChanged, fk.PreCardUse},
  can_refresh = function (self, event, target, player, data)
    if event == fk.BeforeHpChanged then
      return data.skillName == self.name
    else
      return data.card.trueName == "slash" and data.card:getMark("@@steam__yuanlin-inhand") ~= 0 and target == player
    end
  end,
  on_refresh = function (self, event, target, player, data)
    if event == fk.BeforeHpChanged then
      data.preventDying = true
    else
      data.additionalDamage = (data.additionalDamage or 0) + 1
    end
  end,
}
local yuanlin_maxcards = fk.CreateMaxCardsSkill{
  name = "#steam__yuanlin_maxcards",
  exclude_from = function(self, player, card)
    return card and card:getMark("@@steam__yuanlin-inhand") ~= 0
  end,
}
yuanlin:addRelatedSkill(yuanlin_maxcards)
local yuanlin_filter = fk.CreateFilterSkill{
  name = "#steam__yuanlin_filter",
  card_filter = function(self, card, player)
    return card:getMark("@@steam__yuanlin-inhand") ~= 0
  end,
  view_as = function(self, card)
    local c = Fk:cloneCard("slash", card.suit, card.number)
    c.skillName = "steam__yuanlin"
    return c
  end,
}
yuanlin:addRelatedSkill(yuanlin_filter)
Jeanne:addSkill(yuanlin)
Fk:loadTranslationTable{
  ["steam__yuanlin"] = "鸢临",
  [":steam__yuanlin"] = "锁定技，奇数轮开始时，你失去所有装备区牌和体力值并摸等量张牌，且你可以将任意张牌当【桃】使用，此时未使用花色的手牌视为不计入手牌且伤害+1的【杀】。",
  ["steam__yuanlin_vs"] = "鸢临",
  ["#steam__yuanlin-use"] = "鸢临：你可以将任意一张牌当【桃】使用",
  ["@steam__yuanlin"] = "鸢临",
  ["@@steam__yuanlin-inhand"] = "鸢临",
  ["#steam__yuanlin_filter"] = "鸢临",
}

local function fireJudge(to)
  if to.dead then return end
  local room = to.room
  local judge = {
    who = to,
    reason = "lightning",
    pattern = ".|2~9|spade",
  }
  room:judge(judge)
  if not to.dead and judge.card.suit == Card.Spade and judge.card.number > 1 and judge.card.number < 10 then
    room:damage{
      to = to,
      damage = 3,
      damageType = fk.FireDamage,
      skillName = "steam__nicai",
    }
  end
end
local nicai = fk.CreateTriggerSkill{
  name = "steam__nicai",
  anim_type = "defensive",
  frequency = Skill.Compulsory,
  events = {fk.PreCardEffect},
  can_trigger = function(self, event, target, player, data)
    return data.to == player.id and player:hasSkill(self) and data.card.suit == Card.Spade
    and (data.card.is_damage_card or data.card.name == "lightning")
    -- 闪电不算伤害牌，呃呃
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cards = room:getSubcardsByRule(data.card, {Card.Processing})
    if #cards > 0 then
      room:moveCards({
        ids = cards,
        toArea = Card.DrawPile,
        moveReason = fk.ReasonPut,
        skillName = self.name,
        drawPilePosition = math.random(#room.draw_pile + 1),
      })
    end
    fireJudge(player)
    return true
  end,
}
local nicai_delay = fk.CreateTriggerSkill{
  name = "#steam__nicai_delay",
  mute = true,
  frequency = Skill.Compulsory,
  events = {fk.DamageInflicted},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(nicai) and data.skillName == "steam__nicai"
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    while data.damage > 0 and not player.dead do
      if U.askForPlayCard(room, player, nil, nil, nicai.name, "#steam__nicai-use", {bypass_times = true}) then
        data.damage = data.damage - 1
      else
        break
      end
    end
    if data.damage < 1 then
      local tos = room:askForChoosePlayers(player, table.map(room.alive_players, Util.IdMapper),
      1, 1, "#steam__nicai-choose", self.name, false)
      fireJudge(room:getPlayerById(tos[1]))
      return true
    end
  end,
}
nicai:addRelatedSkill(nicai_delay)
Jeanne:addSkill(nicai)

Fk:loadTranslationTable{
  ["steam__nicai"] = "逆裁",
  [":steam__nicai"] = "锁定技，♠伤害牌对你生效前，防止之并洗入牌堆，你进行造成火焰伤害的【闪电】判定，且可以使用任意张牌防止等量点伤害，若均防止，令一名角色进行此判定。",
  ["#steam__nicai-choose"] = "逆裁：令一名角色进行火焰【闪电】判定！  ",
  ["#steam__nicai-use"] = "逆裁：使用一张牌，令你受到伤害-1",
  ["#steam__nicai_delay"] = "逆裁",
}





return extension
