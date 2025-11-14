local extension = Package("aaa_steam1")
extension.extensionName = "aaa_steam"

local U = require "packages.utility.utility"
local RUtil = require "packages.aaa_fenghou.utility.rfenghou_util"
local DIY = require "packages.diy_utility.diy_utility"

Fk:loadTranslationTable{
  ["steam"] = "蒸",
  ["steam2"] = "蒸", -- 用于双形态武将的武将名前缀
  ["steam3"] = "蒸",
  ["aaa_steam1"] = "steam1",
}



local lixiu = General:new(extension, "steam__lixiu", "jin", 3, 4, General.Female)
local qingshi = fk.CreateTriggerSkill{
  name = "steam__qingshi",
  frequency = Skill.Compulsory,
  mute = true,
  events = {fk.TurnStart, fk.EventPhaseChanging, fk.DrawNCards, fk.EventPhaseStart, fk.EventPhaseProceeding},
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(self) then
      if event == fk.TurnStart then
        return #player.room:canMoveCardInBoard() > 0
      else
        local n = 0
        for _, p in ipairs(player.room.players) do
          n = n + p:getLostHp()
        end
        n = n // #player.room.players
        if event == fk.EventPhaseChanging then
          return data.to == Player.Judge and n >= 1
        elseif event == fk.DrawNCards then
          return data.n > 0 and n >= 2
        elseif event == fk.EventPhaseStart then
          return player.phase == Player.Play and n >= 3 and
            table.find(player.room.discard_pile, function (id)
              return Fk:getCardById(id).trueName == "slash"
            end)
        elseif event == fk.EventPhaseProceeding then
          return player.phase == Player.Discard and player:getHandcardNum() - player:getMaxCards() > 2 and n >= 4
        end
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if event == fk.TurnStart then
      local targets = room:askForChooseToMoveCardInBoard(player, "#steam__qingshi-move", self.name, true)
      if #targets > 0 then
        player:broadcastSkillInvoke(self.name)
        room:notifySkillInvoked(player, self.name, "control")
        room:askForMoveCardInBoard(player, room:getPlayerById(targets[1]), room:getPlayerById(targets[2]), self.name)
      end
    elseif event == fk.EventPhaseChanging then
      player:broadcastSkillInvoke(self.name)
      room:notifySkillInvoked(player, self.name, "defensive")
      return true
    elseif event == fk.DrawNCards and room:askForSkillInvoke(player, self.name, nil, "#steam__qingshi-draw") then
      player:broadcastSkillInvoke(self.name)
      room:notifySkillInvoked(player, self.name, "drawcard")
      data.n = player:getHandcardNum()
    elseif event == fk.EventPhaseStart then
      local card = room:getCardsFromPileByRule("slash", 1, "discardPile")
      if #card > 0 then
        player:broadcastSkillInvoke(self.name)
        room:notifySkillInvoked(player, self.name, "drawcard")
        room:moveCardTo(card, Card.PlayerHand, player, fk.ReasonJustMove, self.name, nil, true, player.id)
      end
    elseif event == fk.EventPhaseProceeding then
      player:broadcastSkillInvoke(self.name)
      room:notifySkillInvoked(player, self.name, "defensive")
      room:askForDiscard(player, 2, 2, false, "phase_discard", false)
      player._phase_end = true
    end
  end,
}
lixiu:addSkill(qingshi)
Fk:loadTranslationTable{
  ["steam__lixiu"] = "李秀",
  ["#steam__lixiu"] = "明惠耀林",
  ["illustrator:steam__lixiu"] = "哥达耀",
  ["designer:steam__lixiu"] = "志文",
  ["cv:steam__lixiu"] = "桃妮儿",

  ["steam__qingshi"] = "情势",
  [":steam__qingshi"] = "锁定技，根据所有角色（包括已死亡角色）已损失体力值的平均值，你获得效果：<br>"..
  "不小于0点：回合开始时，你可以移动场上一张牌。<br>"..
  "不小于1点：你跳过判定阶段。<br>"..
  "不小于2点：摸牌阶段，你可以改为摸手牌数的牌。<br>"..
  "不小于3点：出牌阶段开始时，你从弃牌堆获得一张【杀】。<br>"..
  "不小于4点：弃牌阶段，若你的手牌数减手牌上限大于2，你改为弃置两张牌。",
  ["#steam__qingshi-move"] = "情势：你可以移动场上一张牌",
  ["#steam__qingshi-draw"] = "情势：是否改为摸手牌数的牌？",

  ["$steam__qingshi1"] = "决胜料敌，情势既得，断在不疑。",
  ["$steam__qingshi2"] = "勇而轻死、智则心怯，智勇并济者，方为大将。",
  ["$steam__qingshi3"] = "行营面面、帐门深深，出得沙场又安归？",
  ["~steam__lixiu"] = "父死女继，妻死夫继，誓扫蛮夷！",
}



local mateng = General:new(extension, "steam__mateng", "qun", 4)
local xiongdang = fk.CreateActiveSkill{
  name = "steam__xiongdang",
  anim_type = "control",
  card_num = 0,
  min_target_num = 1,
  prompt = "#steam__xiongdang",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = Util.TrueFunc,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    player:drawCards(#effect.tos, self.name)
    if player.dead or player:isKongcheng() then return end
    local cards = room:askForCard(player, #effect.tos, #effect.tos, false, self.name, false, nil,
      "#steam__xiongdang-show:::"..#effect.tos)
    player:showCards(cards)
    cards = table.filter(cards, function (id)
      return table.contains(player:getCardIds("h"), id)
    end)
    room:sortPlayersByAction(effect.tos)
    local targets = table.map(effect.tos, Util.Id2PlayerMapper)
    targets = table.filter(targets, function (p)
      return not p.dead
    end)
    while #targets > 0 and #cards > 0 and not player.dead do
      local to = targets[1]
      local use = U.askForUseRealCard(room, to, cards, nil, self.name,
      "#steam__xiongdang-use", {
        bypass_times = true,
        extraUse = true,
        expand_pile = to ~= player and cards or {},
      }, false, false)
      if use then
        table.removeOne(cards, use.card.id)
      else
        break
      end
      cards = table.filter(cards, function (id)
        return table.contains(player:getCardIds("h"), id)
      end)
      table.remove(targets, 1)
      table.insert(targets, to)
      targets = table.filter(targets, function (p)
        return not p.dead
      end)
    end
    cards = table.filter(cards, function (id)
      return table.contains(player:getCardIds("h"), id)
    end)
    if #cards > 0 then
      room:throwCard(cards, self.name, player, player)
    end
  end,
}
local beikou = fk.CreateTriggerSkill{
  name = "steam__beikou$",
  anim_type = "support",
  events = {fk.AfterCardsMove},
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(self) then return false end
    local cards = {}
    for _, move in ipairs(data) do
      if move.from == player.id and move.moveReason == fk.ReasonDiscard and move.toArea == Card.DiscardPile then
        for _, info in ipairs(move.moveInfo) do
          if info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip then
            table.insertIfNeed(cards, info.cardId)
          end
        end
      end
    end
    cards = table.filter(cards, function(id) return player.room:getCardArea(id) == Card.DiscardPile end)
    cards = U.moveCardsHoldingAreaCheck(player.room, cards)
    if #cards > 0 then
      self.cost_data = {cards = cards}
      return true
    end
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local _, dat = room:askForUseActiveSkill(player, "steam__beikou_active", "#steam__beikou-give",
    true, {expand_pile = self.cost_data.cards})
    if dat then
      self.cost_data = {tos = dat.targets, cards = dat.cards}
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:obtainCard(self.cost_data.tos[1], self.cost_data.cards, true, fk.ReasonGive, player.id, self.name)
  end,
}
local beikou_active = fk.CreateActiveSkill{
  name = "steam__beikou_active",
  min_card_num = 1,
  target_num = 1,
  card_filter = function(self, to_select, selected)
    return type(self.expand_pile) == "table" and table.contains(self.expand_pile, to_select)
  end,
  target_filter = function(self, to_select, selected, selected_cards)
    local to = Fk:currentRoom():getPlayerById(to_select)
    if #selected == 0 and Self.id ~= to_select then
      if to.kingdom ~= "qun" then
        return #selected_cards == 1
      else
        return #selected_cards > 0
      end
    end
  end,
}
Fk:addSkill(beikou_active)
mateng:addSkill(xiongdang)
mateng:addSkill("mashu")
mateng:addSkill(beikou)
Fk:loadTranslationTable{
  ["steam__mateng"] = "马腾",
  ["#steam__mateng"] = "驰骋西陲",
  ["illustrator:steam__mateng"] = "君桓文化",
  ["designer:steam__mateng"] = "胖即是胖",

  ["steam__xiongdang"] = "雄荡",
  [":steam__xiongdang"] = "出牌阶段限一次，你可以选择任意名角色，然后你摸等量张牌并展示等量张手牌；若如此做，这些角色依次使用一张因此展示的牌"..
  "直到无法使用，然后你弃置剩余的牌。",
  ["steam__beikou"] = "备寇",
  [":steam__beikou"] = "主公技，当你因弃置失去牌后，你可以将其中一张牌交给一名其他角色，或将其中任意张牌交给一名其他群势力角色。",
  ["#steam__xiongdang"] = "雄荡：选择任意名角色，你摸等量牌并展示等量牌，令这些角色依次使用其中一张",
  ["#steam__xiongdang-use"] = "雄荡：请使用其中一张牌",
  ["#steam__xiongdang-show"] = "雄荡：请展示%arg张牌",
  ["#steam__beikou-give"] = "备寇：你可将其中一张牌交给一名其他角色/任意张牌交给一名其他群势力角色",
  ["steam__beikou_active"] = "备寇分牌",

  ["$steam__xiongdang1"] = "弟兄们，我们的机会来了！",
  ["$steam__xiongdang2"] = "此时不战，更待何时！",
  ["$steam__beikou1"] = "集众人之力，成群雄霸业！",
  ["$steam__beikou2"] = "将士们，随我起誓！",["~steam__mateng"] = "逆子无谋，祸及全族。",
}




local simayi = General:new(extension, "steam__simayi", "jin", 3)
local taozhu = fk.CreateTriggerSkill{
  name = "steam__taozhu",
  anim_type = "control",
  events = {fk.CardUsing, fk.DamageInflicted},
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(self) then
      if event == fk.CardUsing then
        return data.card.type == Card.TypeTrick
      elseif event == fk.DamageInflicted then
        return true
      end
    end
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local prompt = event == fk.CardUsing and "taozhu_cardusing" or "taozhu_damage"
    local choices = {"steam__taozhu1:::"..prompt, "draw1", "Cancel"}
    local to = nil
    if event == fk.CardUsing then
      room.logic:getEventsByRule(GameEvent.UseCard, 1, function (e)
        if e.id ~= room.logic:getCurrentEvent().id then
          local use = e.data[1]
          if use.card.type == Card.TypeTrick then
            to = room:getPlayerById(use.from)
            return true
          end
        end
      end, 1)
    elseif event == fk.DamageInflicted then
      room.logic:getActualDamageEvents(1, function (e)
        if e.id ~= room.logic:getCurrentEvent().id then
          to = e.data[1].to
          return true
        end
      end, nil, 1)
    end
    if to and not to.dead then
      prompt = event == fk.CardUsing and "taozhu_canceluse" or "taozhu_canceldamage"
      choices[2] = "steam__taozhu2:"..target.id..":"..to.id..":"..prompt
    end
    local choice = room:askForChoice(player, choices, self.name)
    if choice ~= "Cancel" then
      if choice:startsWith("steam__taozhu2") and to then
        self.cost_data = {tos = {to.id}, choice = choice}
        return true
      else
        self.cost_data = {choice = choice}
        return true
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if self.cost_data.choice:startsWith("steam__taozhu1") then
      local info = string.split(self.cost_data.choice, ":")
      room:setPlayerMark(player, "@@steam__"..info[4], 1)
    else
      player:drawCards(1, self.name)
      if player.dead then return end
      if self.cost_data.choice:startsWith("steam__taozhu2") then
        local to = room:getPlayerById(self.cost_data.tos[1])
        if to.dead or not player:canPindian(to) then return end
        local pindian = player:pindian({to}, self.name)
        if pindian.results[to.id].winner ~= player then
          if event == fk.CardUsing then
            data.tos = {}
          elseif event == fk.DamageInflicted then
            return true
          end
        end
      end
    end
  end,
}
local taozhu_delay = fk.CreateTriggerSkill{
  name = "#steam__taozhu_delay",
  priority = 2,
  anim_type = "control",
  events = {fk.CardUsing, fk.DamageInflicted},
  can_trigger = function(self, event, target, player, data)
    if event == fk.CardUsing and data.card.type == Card.TypeTrick then
      return player:getMark("@@steam__taozhu_cardusing") > 0
    elseif event == fk.DamageInflicted then
      return player:getMark("@@steam__taozhu_damage") > 0
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    local room = player.room
    room:doIndicate(player.id, {target.id})
    if event == fk.CardUsing and data.card.type == Card.TypeTrick then
      room:setPlayerMark(player, "@@steam__taozhu_cardusing", 0)
    elseif event == fk.DamageInflicted then
      room:setPlayerMark(player, "@@steam__taozhu_damage", 0)
    end
    if target.dead or target:isNude() then return end
    local flag = "he"
    if target == player then
      if #player:getCardIds("e") == 0 then return end
      flag = "e"
    end
    local card = room:askForCardChosen(player, target, flag, "steam__taozhu", "#steam__taozhu-prey::"..target.id)
    room:moveCardTo(card, Card.PlayerHand, player, fk.ReasonPrey, "steam__taozhu", nil, false, player.id)
  end,
}
local tuigong = fk.CreateTriggerSkill{
  name = "steam__tuigong",
  mute = true,
  events = {fk.DamageCaused, fk.RoundEnd},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) and player:getMark(self.name) == 0 then
      if event == fk.DamageCaused then
        return target == player and data.damage >= data.to.hp + data.to.shield and
          not data.to.dead and player:canUseTo(Fk:cloneCard("sincere_treat"), data.to, {bypass_distances = true})
      elseif event == fk.RoundEnd then
        local to = nil
        for _, p in ipairs(player.room.alive_players) do
          if #p:getCardIds("ej") > 0 then
            if to ~= nil then return end
            if #p:getCardIds("ej") > 1 then
              return
            else
              to = p
            end
          end
        end
        if to == nil then return end
        if player.room:canMoveCardInBoard(nil, {to}) then
          self.cost_data = {tos = {to.id}}
          return true
        end
      end
    end
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    if event == fk.DamageCaused then
      if room:askForSkillInvoke(player, self.name, nil,
        "#steam__tuigong-invoke::"..data.to.id..":"..player:getMark("@steam__tuigong")) then
        self.cost_data = {tos = {data.to.id}}
        return true
      end
    elseif event == fk.RoundEnd then
      return room:askForSkillInvoke(player, self.name, nil, "#steam__tuigong-add::"..self.cost_data.tos[1])
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke(self.name)
    if event == fk.DamageCaused then
      room:notifySkillInvoked(player, self.name, "big")
      room:setPlayerMark(player, self.name, 1)
      local n = player:getMark("@steam__tuigong")
      room:setPlayerMark(player, "@steam__tuigong", 0)
      for i = 1, n, 1 do
        if player.dead or data.to.dead then return end
        room:useVirtualCard("sincere_treat", nil, player, data.to, self.name)
      end
    elseif event == fk.RoundEnd then
      room:notifySkillInvoked(player, self.name, "control")
      room:addPlayerMark(player, "@steam__tuigong", 1)
      local tos = room:askForChooseToMoveCardInBoard(player, "#steam__tuigong-move", self.name, false, nil, false)
      local targets = table.map(tos, Util.Id2PlayerMapper)
      room:askForMoveCardInBoard(player, targets[1], targets[2], self.name)
    end
  end,

  on_acquire = function (self, player, is_start)
    player.room:setPlayerMark(player, "@steam__tuigong", 3)
  end,
  on_lose = function (self, player, is_death)
    player.room:setPlayerMark(player, "@steam__tuigong", 0)
  end,
}
taozhu:addRelatedSkill(taozhu_delay)
simayi:addSkill(taozhu)
simayi:addSkill(tuigong)
Fk:loadTranslationTable{
  ["steam__simayi"] = "司马懿",
  ["#steam__simayi"] = "",
  ["illustrator:steam__simayi"] = "凝聚永恒",
  ["designer:steam__simayi"] = "初长风",

  ["steam__taozhu"] = "韬逐",
  [":steam__taozhu"] = "当你使用锦囊牌或受到伤害时，你可以选择一项：1.获得下名执行本操作的角色一张牌；2.摸一张牌，然后与上名执行本操作的角色拼点，"..
  "若你没赢，取消之。",
  ["steam__tuigong"] = "推宫",
  [":steam__tuigong"] = "每局游戏限一次，当你造成致命伤害时，你可以视为对其使用(3)张【推心置腹】。此前轮次结束时，你可以令此值+1并移动场上"..
  "唯一的牌。",

  ["steam__taozhu1"] = "下一名角色%arg时，你获得其一张牌",
  ["steam__taozhu2"] = "摸一张牌并与 %dest 拼点，若你没赢，%src %arg",
  ["taozhu_cardusing"] = "使用锦囊牌",
  ["taozhu_damage"] = "受到伤害",
  ["taozhu_canceluse"] = "取消使用的锦囊",
  ["taozhu_canceldamage"] = "防止受到的伤害",
  ["@@steam__taozhu_cardusing"] = "韬逐 使用锦囊",
  ["@@steam__taozhu_damage"] = "韬逐 受到伤害",
  ["#steam__taozhu_delay"] = "韬逐",
  ["#steam__taozhu-prey"] = "韬逐：获得 %dest 一张牌",
  ["#steam__tuigong-invoke"] = "推宫：是否视为对 %dest 使用%arg张【推心置腹】？",
  ["@steam__tuigong"] = "推宫",
  ["#steam__tuigong-add"] = "推宫：是否令“推宫”张数+1并移动 %dest 场上的牌？",
  ["#steam__tuigong-move"] = "推宫：请移动场上的牌",

  ["$steam__taozhu1"] = "善瞻者察微于九地之下！",
  ["$steam__taozhu2"] = "善谋者鹰扬于九天之上！",
  ["$steam__tuigong1"] = "以退为进，俗子焉能度之。",
  ["$steam__tuigong2"] = "应时而变，当行权宜之计。",
  ["~steam__simayi"] = "大业五十年，说与山鬼听……",
}

local simashi = General:new(extension, "steam__simashi", "jin", 3)
local maishi = fk.CreateFilterSkill{
  name = "steam__maishi",
  card_filter = function(self, card, player, isJudgeEvent)
    return player:hasSkill(self) and player.phase ~= Player.NotActive and player:getMark("steam__maishi-turn") == 0 and
    card.color == Card.Black and table.contains(player:getCardIds("h"), card.id)
  end,
  view_as = function(self, card)
    return Fk:cloneCard("steam__underhanding", card.suit, card.number)
  end,
}
local maishi_trigger = fk.CreateTriggerSkill{
  name = "#steam__maishi_trigger",

  refresh_events = {fk.AfterCardUseDeclared},
  can_refresh = function(self, event, target, player, data)
    return target == player and player.phase ~= Player.NotActive and data.card.type == Card.TypeTrick
  end,
  on_refresh = function (self, event, target, player, data)
    player.room:setPlayerMark(player, "steam__maishi-turn", 1)
  end,
}
local ruilve = fk.CreateActiveSkill{
  name = "steam__ruilve",
  anim_type = "drawcard",
  min_card_num = 1,
  target_num = 0,
  prompt = "#steam__ruilve",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  card_filter = function(self, to_select, selected)
    return Fk:getCardById(to_select, false).type == Card.TypeTrick
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    room:recastCard(effect.cards, player, self.name)
    if player.dead then return end
    local cards = table.filter(effect.cards, function (id)
      if table.contains(room.discard_pile, id) then
        local card = Fk:getCardById(id)
        return player:canUse(card, { bypass_times = true }) and not player:prohibitUse(card)
      end
    end)
    if #cards == 0 then return end
    U.askForUseRealCard(room, player, cards, nil, self.name, "#steam__ruilve-use", { expand_pile = cards, bypass_times = true })
  end
}
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
local fuyu = fk.CreateTriggerSkill{
  name = "steam__fuyu",
  anim_type = "support",
  frequency = Skill.Compulsory,
  events = {fk.CardUseFinished},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and
      table.find(player.room.alive_players, function (p)
        return Fk.generals[p.general].trueName:startsWith("sima")
      end)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local targets = table.filter(room.alive_players, function (p)
      return Fk.generals[p.general].trueName:startsWith("sima")
    end)
    local to
    if #targets == 1 then
      to = {player.id}
    else
      to = room:askForChoosePlayers(player, table.map(targets, Util.IdMapper), 1, 1, "#steam__fuyu-choose", self.name, false)
    end
    room:moveCardTo(getShade(room, 1), Card.PlayerHand, to[1], fk.ReasonJustMove, self.name, nil, true, player.id)
  end,
}
maishi:addRelatedSkill(maishi_trigger)
simashi:addSkill(maishi)
simashi:addSkill(ruilve)
simashi:addSkill(fuyu)
Fk:loadTranslationTable{
  ["steam__simashi"] = "司马师",
  ["#steam__simashi"] = "韬隐沉略",
  ["illustrator:steam__simashi"] = "拉布拉卡",
  ["designer:steam__simashi"] = "胖即是胖",

  ["steam__maishi"] = "埋士",
  [":steam__maishi"] = "锁定技，你的回合内，若你本回合未使用过锦囊牌，你的所有黑色手牌均视为【瞒天过海】。",
  ["steam__ruilve"] = "睿略",
  [":steam__ruilve"] = "出牌阶段限一次，你可以重铸任意张锦囊牌，然后你可以使用其中的一张牌。",
  ["steam__fuyu"] = "伏慾",
  [":steam__fuyu"] = "宗族技，当你使用牌结算后，你令一名同宗族角色获得一张【影】。",
  ["#steam__ruilve"] = "睿略：你可以重铸任意张锦囊牌，然后可以使用其中一张牌",
  ["#steam__ruilve-use"] = "睿略：你可以使用其中一张牌",
  ["#steam__fuyu-choose"] = "伏慾：令一名同族角色获得一张【影】",

  ["$steam__ruilve1"] = "司马氏满门英杰，皆经天纬地之才！",
  ["$steam__ruilve2"] = "外知军略，内通政事，此乃明君之象。",
  ["$steam__fuyu1"] = "成大事者，当务实权而远虚名！",
  ["$steam__fuyu2"] = "潜龙隐于千丈海，胸有韬晦十万兵。",
  ["~steam__simashi"] = "司马师",
}

local simayiw = General:new(extension, "steam__simayiw", "jin", 4)
local tongkai = fk.CreateTriggerSkill{
  name = "steam__tongkai",
  anim_type = "offensive",
  frequency = Skill.Compulsory,
  events = {fk.TargetSpecifying},
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(self) and data.card.trueName == "slash" and #AimGroup:getAllTargets(data.tos) == 1 then
      local to = player.room:getPlayerById(data.to)
      for _, p in ipairs({player, to}) do
        if table.find(p:getCardIds("he"), function (id)
          return not p:prohibitDiscard(id)
        end) then
          return true
        end
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local tos = {}
    local to = room:getPlayerById(data.to)
    for _, p in ipairs({player, to}) do
      if table.find(p:getCardIds("he"), function (id)
        return not p:prohibitDiscard(id)
      end) then
        table.insert(tos, p.id)
      end
    end
    local target = room:askForChoosePlayers(player, tos, 1, 1, "#steam__tongkai-choose", self.name, false)
    target = room:getPlayerById(target[1])

    local choices = {}
    tos = {}
    if target:getNextAlive() ~= to and target:getNextAlive() ~= player and
      not player:isProhibited(target:getNextAlive(), data.card) then
      table.insert(tos, target:getNextAlive().id)
      table.insert(choices, "steam__tongkai1")
    end
    if target:getLastAlive() ~= to and target:getLastAlive() ~= player and
      not player:isProhibited(target:getLastAlive(), data.card) then
      table.insert(tos, target:getLastAlive().id)
      table.insertIfNeed(choices, "steam__tongkai1")
    end
    if table.find(target:getCardIds("he"), function (id)
      return not target:prohibitDiscard(id)
    end) then
      table.insert(choices, "steam__tongkai2")
    end
    local cards = table.filter(target:getCardIds("he"), function (id)
      return not target:prohibitDiscard(id)
    end)
    if #choices == 2 and #cards > 1 then
      table.insert(choices, "steam__tongkai_beishui")
    end

    local choice = room:askForChoice(target, choices, self.name, nil, false,
      {"steam__tongkai1", "steam__tongkai2", "steam__tongkai_beishui"})
    if choice ~= "steam__tongkai2" then
      local num = choice == "steam__tongkai_beishui" and 2 or 1
      local victim, ids = room:askForChooseCardsAndPlayers(target, num, num, tos, 1, 1, tostring(Exppattern{ id = cards }),
        "#steam__tongkai-transfer:::"..num, self.name, false, false)
      room:throwCard(ids, self.name, target, target)
      AimGroup:cancelTarget(data, data.to)
      AimGroup:addTargets(room, data, victim[1])
    end
    if choice ~= "steam__tongkai1" then
      if choice == "steam__tongkai2" then
        room:askForDiscard(target, 1, 1, true, self.name, false)
      end
      data.additionalDamage = (data.additionalDamage or 0) + 1
    end
    if choice == "steam__tongkai_beishui" then
      data.extra_data = data.extra_data or {}
      data.extra_data.steam__tongkai_draw = data.extra_data.steam__tongkai_draw or {}
      data.extra_data.steam__tongkai_draw[target.id] = (data.extra_data.steam__tongkai_draw[target.id] or 0) + 1
    end
  end,
}
local tongkai_delay = fk.CreateTriggerSkill{
  name = "#steam__tongkai_delay",
  mute = true,
  events = {fk.CardUseFinished},
  can_trigger = function(self, event, target, player, data)
    return not player.dead and data.extra_data and data.extra_data.steam__tongkai_draw and
    data.extra_data.steam__tongkai_draw[player.id]
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    player:drawCards(2 * data.extra_data.steam__tongkai_draw[player.id], "steam__tongkai")
  end,
}
tongkai:addRelatedSkill(tongkai_delay)
simayiw:addSkill(tongkai)
Fk:loadTranslationTable{
  ["steam__simayiw"] = "司马乂",
  ["#steam__simayiw"] = "",
  ["illustrator:steam__simayiw"] = "",
  ["designer:steam__simayiw"] = "末折",

  ["steam__tongkai"] = "同忾",
  [":steam__tongkai"] = "锁定技，你使用【杀】指定唯一目标时，你令你或其执行一项：<br>"..
  "1.弃置一张牌，此牌重新指定其一名邻家为目标；<br>2.弃置一张牌，此牌造成的伤害加1。<br>背水：此牌结算后，摸两张牌。",
  ["#steam__tongkai-choose"] = "同忾：请令一名角色选择一项",
  ["steam__tongkai1"] = "弃一张牌，重新指定你一名邻家为此【杀】目标",
  ["steam__tongkai2"] = "弃一张牌，此【杀】伤害加1",
  ["steam__tongkai_beishui"] = "背水：此【杀】结算后你摸两张牌",
  ["#steam__tongkai-transfer"] = "同忾：弃%arg张牌，重新选择此【杀】的目标",
  ["#steam__tongkai_delay"] = "同忾",
}

local steam__underhandingSkill = fk.CreateActiveSkill{
  name = "steam__underhanding_skill",
  prompt = "#steam__underhanding_skill",
  can_use = Util.CanUse,
  min_target_num = 1,
  max_target_num = 2,
  mod_target_filter = function(self, to_select, selected, user, card)
    return user.id ~= to_select and not Fk:currentRoom():getPlayerById(to_select):isAllNude()
  end,
  target_filter = Util.TargetFilter,
  on_effect = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local to = room:getPlayerById(effect.to)
    if not to:isAllNude() then
      local id = room:askForCardChosen(player, to, "hej", self.name)
      room:obtainCard(player, id, false, fk.ReasonPrey, player.id, self.name)
      local e = player.room.logic:getCurrentEvent():findParent(GameEvent.UseCard)
      if e then
        local use = e.data[1]
        use.extra_data = use.extra_data or {}
        use.extra_data.steam__underhanding_targets = use.extra_data.steam__underhanding_targets or {}
        table.insertIfNeed(use.extra_data.steam__underhanding_targets, to.id)
      end
    end
  end,
  on_action = function (self, room, use, finished)
    if not finished then return end
    local player = room:getPlayerById(use.from)
    if player.dead or player:isNude() then return end
    local targets = (use.extra_data or {}).steam__underhanding_targets or {}
    if #targets == 0 then return end
    room:sortPlayersByAction(targets)
    for _, pid in ipairs(targets) do
      local target = room:getPlayerById(pid)
      if not player:isNude() and not target.dead and not player.dead then
        local c = room:askForCard(player, 1, 1, true, self.name, false, nil, "#steam__underhanding-card::" .. pid)[1]
        room:moveCardTo(c, Player.Hand, target, fk.ReasonGive, self.name, nil, false, player.id)
      end
    end
  end
}
local steam__underhandingExclude = fk.CreateMaxCardsSkill{
  name = "steam__underhanding_exclude",
  global = true,
  exclude_from = function(self, player, card)
    return card and card.name == "steam__underhanding"
  end,
}
Fk:addSkill(steam__underhandingExclude)
local steam__underhanding = fk.CreateTrickCard{
  name = "&steam__underhanding",
  suit = Card.Heart,
  number = 5,
  skill = steam__underhandingSkill,
  multiple_targets = true,
}
steam__underhanding.package = extension
Fk:addCard(steam__underhanding)
Fk:loadTranslationTable{
  ["steam__underhanding"] = "瞒天过海",
  [":steam__underhanding"] = "锦囊牌<br /><b>时机</b>：出牌阶段<br /><b>目标</b>：一至两名区域内有牌的其他角色。<br/><b>效果</b>："..
  "你依次获得目标角色区域内的一张牌，然后依次交给目标角色一张牌。<br/>此牌不计入你的手牌上限。",
  ["steam__underhanding_skill"] = "瞒天过海",
  ["steam__underhanding_action"] = "瞒天过海",
  ["#steam__underhanding-card"] = "瞒天过海：交给 %dest 一张牌",
  ["#steam__underhanding_skill"] = "选择一至两名区域内有牌的其他角色，依次获得其区域内的一张牌，然后依次交给其一张牌",
}





local dongmindonghuang = General:new(extension, "steam__dongmindonghuang", "qun", 4)
local ciheng = fk.CreateTriggerSkill{
  name = "steam__ciheng",
  anim_type = "offensive",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Play and
      #player.room.alive_players > 1
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local tos = room:askForChoosePlayers(player, table.map(room.alive_players, Util.IdMapper), 2, 2,
      "#steam__ciheng-choose", self.name)
    if #tos > 0 then
      room:sortPlayersByAction(tos)
      self.cost_data = {tos = tos}
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local targets = table.map(self.cost_data.tos, Util.Id2PlayerMapper)
    for _, p in ipairs(targets) do
      room:setPlayerMark(p, "@@steam__ciheng-turn", 1)
      room:handleAddLoseSkills(p, "steam__ciheng&", nil, false, true)
      room.logic:getCurrentEvent():findParent(GameEvent.Turn):addCleaner(function()
        room:handleAddLoseSkills(p, "-steam__ciheng&", nil, false, true)
      end)
    end
    targets = table.filter(targets, function (p)
      return not p:isKongcheng()
    end)
    if #targets > 0 then
      local result = U.askForJointCard(targets, 1, 999, false, self.name, true, nil, "#steam__ciheng-ask")
      for _, ids in pairs(result) do
        if #ids > 0 then
          for _, id in ipairs(ids) do
            room:setCardMark(Fk:getCardById(id), "@@steam__ciheng-inhand-turn", 1)
          end
        end
      end
    end
  end,
}
local ciheng_delay = fk.CreateTriggerSkill{
  name = "#steam__ciheng_delay",
  anim_type = "control",
  events = {fk.EventPhaseEnd},
  can_trigger = function(self, event, target, player, data)
    return target == player and player.phase == Player.Play and player:usedSkillTimes("steam__ciheng", Player.HistoryPhase) > 0 and
      table.find(player.room.alive_players, function (p)
        return p:getMark("@@steam__ciheng-turn") > 0
      end)
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    local room = player.room
    for _, p in ipairs(room:getAlivePlayers()) do
      if p:getMark("@@steam__ciheng-turn") > 0 then
        local cards = table.filter(p:getCardIds("h"), function (id)
          local card = Fk:getCardById(id, false)
          return card:getMark("@@steam__ciheng-inhand-turn") == 0 and card.trueName ~= "duel" and not p:prohibitDiscard(id)
        end)
        if #cards > 0 then
          room:throwCard(cards, "steam__ciheng", p, p)
        end
      end
    end
  end,
}
local ciheng_filter = fk.CreateFilterSkill{
  name = "#steam__ciheng_filter",
  anim_type = "offensive",
  card_filter = function(self, card, player, isJudgeEvent)
    return card:getMark("@@steam__ciheng-inhand-turn") > 0 and table.contains(player:getCardIds("h"), card.id)
  end,
  view_as = function(self, card)
    return Fk:cloneCard("duel", card.suit, card.number)
  end,
}
local ciheng_prohibit = fk.CreateProhibitSkill{
  name = "#steam__ciheng_prohibit",
  is_prohibited = function (self, from, to, card)
    return from:usedSkillTimes("steam__ciheng", Player.HistoryPhase) > 0 and card and
      to:getMark("@@steam__ciheng-turn") == 0
  end,
}
local ciheng_viewas = fk.CreateViewAsSkill{
  name = "steam__ciheng&",
  anim_type = "offensive",
  pattern = "slash",
  prompt = "#steam__ciheng&",
  card_filter = function(self, to_select, selected)
    return #selected == 0 and table.contains(Self:getCardIds("h"), to_select) and
      Fk:getCardById(to_select):getMark("@@steam__ciheng-inhand-turn") == 0
  end,
  view_as = function(self, cards)
    if #cards ~= 1 then return end
    local c = Fk:cloneCard("slash")
    c.skillName = self.name
    c:addSubcard(cards[1])
    return c
  end,
}
Fk:addSkill(ciheng_viewas)
ciheng:addRelatedSkill(ciheng_delay)
ciheng:addRelatedSkill(ciheng_filter)
ciheng:addRelatedSkill(ciheng_prohibit)
dongmindonghuang:addSkill(ciheng)
Fk:loadTranslationTable{
  ["steam__dongmindonghuang"] = "董旻董璜",
  ["#steam__dongmindonghuang"] = "魔鲠",
  ["illustrator:steam__dongmindonghuang"] = "北★MAN",
  ["designer:steam__dongmindonghuang"] = "小叶子",

  ["steam__ciheng"] = "呲横",
  [":steam__ciheng"] = "出牌阶段开始时，你可选择两名角色，本回合你仅能对这些角色使用牌，并令这些角色选择其任意张手牌，本回合这些牌视为【决斗】且"..
  "其余手牌可当【杀】使用或打出。此阶段结束时，这些角色弃置手牌中不为【决斗】的牌。",
  ["steam__ciheng&"] = "呲横",
  [":steam__ciheng&"] = "你可以将非“呲横”手牌当【杀】使用或打出。",
  ["#steam__ciheng-choose"] = "呲横：你可以选择两名角色，本回合仅能对这些角色使用牌",
  ["@@steam__ciheng-turn"] = "呲横",
  ["#steam__ciheng-ask"] = "呲横：选择任意张手牌本回合视为【决斗】，其他手牌本回合可以当【杀】",
  ["@@steam__ciheng-inhand-turn"] = "呲横",
  ["#steam__ciheng_delay"] = "呲横",
  ["#steam__ciheng_filter"] = "呲横",
  ["#steam__ciheng&"] = "呲横：你可以将非“呲横”手牌当【杀】使用或打出",
}



local yanghuiyu = General:new(extension, "steam__yanghuiyu", "jin", 3, 3, General.Female)
local shenyi = fk.CreateTriggerSkill{
  name = "steam__shenyi",
  anim_type = "support",
  events = {fk.CardUseFinished},
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(self) and player:usedSkillTimes(self.name, Player.HistoryTurn) == 0 then
      local dat = nil
      player.room.logic:getEventsByRule(GameEvent.UseCard, 1, function (e)
        if e.id ~= player.room.logic:getCurrentEvent().id then
          local use = e.data[1]
          dat = use
          return true
        end
      end, 1)
      return dat and dat.from ~= player.id
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local n = #room.logic:getEventsOfScope(GameEvent.UseCard, 5, Util.TrueFunc, Player.HistoryTurn)
    local cards = room:getNCards(n)
    local red = table.filter(cards, function (id)
      return Fk:getCardById(id).color == Card.Red
    end)
    if #red > 0 then
      room:askForYiji(player, red, room.alive_players, self.name, 0, n, "#steam__shenyi-give", cards)
    end
    cards = table.filter(cards, function (id)
      return table.contains(room.draw_pile, id)
    end)
    if #cards > 0 and not player.dead then
      room:askForGuanxing(player, cards)
    end
  end,
}
local hongcao = fk.CreateViewAsSkill{
  name = "steam__hongcao",
  anim_type = "support",
  pattern = "peach,nullification",
  prompt = function (self)
    local red = table.filter(Self:getCardIds("h"), function(id)
      return Fk:getCardById(id).color == Card.Red
    end)
    local black = table.filter(Self:getCardIds("h"), function(id)
      return Fk:getCardById(id).color == Card.Black
    end)
    if #red > #black then
      return "#steam__hongcao-peach"
    else
      return "#steam__hongcao-nullification"
    end
  end,
  card_filter = Util.FalseFunc,
  view_as = function(self, cards)
    local red = table.filter(Self:getCardIds("h"), function(id)
      return Fk:getCardById(id).color == Card.Red
    end)
    local black = table.filter(Self:getCardIds("h"), function(id)
      return Fk:getCardById(id).color == Card.Black
    end)
    local c = Fk:cloneCard(#red > #black and "peach" or "nullification")
    c.skillName = self.name
    return c
  end,
  before_use = function (self, player, use)
    local room = player.room
    local red = table.filter(player:getCardIds("h"), function(id)
      return Fk:getCardById(id).color == Card.Red
    end)
    local black = table.filter(player:getCardIds("h"), function(id)
      return Fk:getCardById(id).color == Card.Black
    end)
    if use.card.name == "peach" then
      room:recastCard(red, player, self.name)
    else
      room:throwCard(black, self.name, player, player)
    end
  end,
  enabled_at_play = function (self, player)
    local red = table.filter(player:getCardIds("h"), function(id)
      return Fk:getCardById(id).color == Card.Red
    end)
    local black = table.filter(player:getCardIds("h"), function(id)
      return Fk:getCardById(id).color == Card.Black
    end)
    return #red > #black and player:canUse(Fk:cloneCard("peach"))
  end,
  enabled_at_response = function(self, player, response)
    if response or player:isKongcheng() then return end
    local red = table.filter(player:getCardIds("h"), function(id)
      return Fk:getCardById(id).color == Card.Red
    end)
    local black = table.filter(player:getCardIds("h"), function(id)
      return Fk:getCardById(id).color == Card.Black
    end)
    if #red > #black then
      return #U.getViewAsCardNames(player, self.name, {"peach"}) > 0
    elseif table.every(black, function (id)
      return not player:prohibitDiscard(id)
    end) then
      return #U.getViewAsCardNames(player, self.name, {"nullification"}) > 0
    end
  end,
}
yanghuiyu:addSkill(shenyi)
yanghuiyu:addSkill(hongcao)
Fk:loadTranslationTable{
  ["steam__yanghuiyu"] = "羊徽瑜",
  ["#steam__yanghuiyu"] = "端清才德",
  ["illustrator:steam__yanghuiyu"] = "匠人绘",
  ["designer:steam__yanghuiyu"] = "末页",

  ["steam__shenyi"] = "慎仪",
  [":steam__shenyi"] = "每回合限一次，你使用牌结算完毕后，若上一张牌不为你使用，你可以卜算X并分配其中的红色牌（X为本回合所有角色使用的牌数之和且"..
  "至多为5）。",
  ["steam__hongcao"] = "弘操",
  [":steam__hongcao"] = "若你手牌中：红色牌更多，你可以重铸所有红色手牌以视为使用【桃】；否则你可以弃置所有黑色手牌以视为使用【无懈可击】。",
  ["#steam__shenyi-give"] = "慎仪：你可以分配其中的红色牌",
  ["#steam__hongcao-peach"] = "弘操：你可以重铸所有红色手牌，视为使用【桃】",
  ["#steam__hongcao-nullification"] = "弘操：你可以弃置所有黑色手牌，视为使用【无懈可击】",

  ["$steam__shenyi1"] = "贤良淑德，才学洽闻。",
  ["$steam__shenyi2"] = "聪慧贤德，以文才称。",
  ["$steam__hongcao1"] = "终温且惠，其仪淑慎。",
  ["$steam__hongcao2"] = "既慎其仪，克明礼教。",
  ["~steam__yanghuiyu"] = "心之云痛，痛贯穹昊……",
}

--[[
local zhaoe = General:new(extension, "steam__zhaoe", "qun", 4, 4, General.Female)

local steam__renchou = fk.CreateViewAsSkill{
  name = "steam__renchou",
  anim_type = "offensive",
  pattern = "duel",
  prompt = function(self)
    local promot = "#steam__renchou"
    local x = Self:getMark("steam__renchou-turn")
    if x > 0 then
      promot = "#steam__renchou-ex:::"..(x+1)
    end
    return promot
  end,
  card_filter = function(self, to_select, selected)
    return true
  end,
  view_as = function(self, cards)
    if #cards == 0 or #cards <= Self:getMark("steam__renchou-turn")  then return nil end
    local c = Fk:cloneCard("duel")
    c.skillName = self.name
    c:addSubcards(cards)
    return c
  end,
  before_use = function(self, player, use)
    local room = player.room
    local x = #use.card.subcards
    room:setPlayerMark(player, "steam__renchou-turn", x)
    use.additionalDamage = (x - 1)
  end,
  after_use = function (self, player, use)
    if player:getMark("@@steam__yanshi") ~= 0 then
      local room = player.room
      room:setPlayerMark(player, "@@steam__yanshi", 0)
      room:handleAddLoseSkills(player, "-steam__renchou")
    end
  end,
  enabled_at_play = function(self, player)
    return true
  end,
  enabled_at_response = function (self, player, response)
    return not response
  end,

  on_lose = function (self, player)
    if player:getMark("@@steam__yanshi") ~= 0 then
      player.room:setPlayerMark(player, "@@steam__yanshi", 0)
    end
  end,
}

local steam__renchou_trigger = fk.CreateTriggerSkill{
  name = "#steam__renchou_trigger",
  events = {fk.CardUsing},
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(steam__renchou) and table.contains(data.card.skillNames, steam__renchou.name)
      and player.hp == 1 then
      return #player.room.logic:getEventsOfScope(GameEvent.Death, 1, function(e)
        local death = e.data[1]
        return death.damage and death.damage.from == player
      end, Player.HistoryTurn) > 0
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    player:drawCards(1, "steam__renchou")
  end,
}
steam__renchou:addRelatedSkill(steam__renchou_trigger)

zhaoe:addSkill(steam__renchou)

local steam__yanshi = fk.CreateTriggerSkill{
  name = "steam__yanshi",
  events = {fk.EnterDying},
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) and target == player and player.hp < 1 then
      return table.find(player.room.alive_players, function (p)
        return not p:hasSkill(steam__renchou, true)
      end) ~= nil
    end
  end,
  on_cost = function (self, event, target, player, data)
    local targets = table.filter(player.room.alive_players, function (p) return not p:hasSkill(steam__renchou, true) end)
    local tos = player.room:askForChoosePlayers(player, table.map(targets, Util.IdMapper), 1, 1,
    "#steam__yanshi-choose", self.name, true)
    if #tos > 0 then
      self.cost_data = {tos = tos}
      return true
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(self.cost_data.tos[1])
    room:setPlayerMark(to, "@@steam__yanshi", 1)
    room:handleAddLoseSkills(to, "steam__renchou")
    if not player.dead then
      room:recover { num = 1-player.hp, skillName = self.name, who = player, recoverBy = player }
    end
  end,
}
zhaoe:addSkill(steam__yanshi)
Fk:loadTranslationTable{
  ["steam__zhaoe"] = "赵娥",
  ["#steam__zhaoe"] = "",
  ["illustrator:steam__zhaoe"] = "哥达耀",
  ["designer:steam__zhaoe"] = "从珂",

  ["steam__renchou"] = "刃仇",
  [":steam__renchou"] = "你可以将任意张牌当一张伤害基数为底牌数的【决斗】使用（须至少比本回合上次发动多1张）；你杀死角色的回合内，此【决斗】带有《残躯→摸一张牌》。",
  ["#steam__renchou"] = "刃仇：将任意张牌当害基数为底牌数的【决斗】使用",
  ["#steam__renchou-ex"] = "刃仇：将至少%arg张牌当害基数为底牌数的【决斗】使用",
  ["#steam__renchou_trigger"] = "刃仇",

  ["steam__yanshi"] = "言誓",
  [":steam__yanshi"] = "当你进入濒死状态时，你可以令一名没有“刃仇”的角色获得发动后失去的“刃仇”，然后你回复体力至1点。",
  ["#steam__yanshi-choose"] = "言誓：你可令一名没有“刃仇”的角色获得发动后失去的“刃仇”，回复体力至1",
  ["@@steam__yanshi"] = "言誓:刃仇",
}
--]]



local wenyang2 = General:new(extension, "steam2__wenyang", "wu", 4)

local steam__chongjian = fk.CreateViewAsSkill{
  name = "steam__chongjian",
  pattern = "jink,duel",
  mute = true,
  prompt = "#steam__chongjian",
  interaction = function(self)
    local all_names = self.pattern:split(",")
    local names = U.getViewAsCardNames(Self, self.name, all_names)
    if #names > 0 then
      return U.CardNameBox {choices = names, all_choices = all_names}
    end
  end,
  card_filter = function (self, to_select, selected)
    if Self:getHandcardNum() > 1 then
      return #selected < Self:getHandcardNum() - 1 and table.contains(Self:getCardIds("h"), to_select) and
        not Self:prohibitDiscard(to_select)
    else
      return false
    end
  end,
  view_as = function(self, cards)
    if not self.interaction.data then return nil end
    if Self:getHandcardNum() > 1 then
      if #cards ~= Self:getHandcardNum() - 1 then return end
      self.cost_data = cards
    elseif Self:getHandcardNum() == 0 then
      if #cards > 0 then return end
      self.cost_data = nil
    end
    local card = Fk:cloneCard(self.interaction.data)
    card.skillName = self.name
    return card
  end,
  before_use = function (self, player, use)
    local room = player.room
    if use.card.is_damage_card then
      player:broadcastSkillInvoke(self.name, table.random({1, 2}))
      room:notifySkillInvoked(player, self.name, "offensive")
    else
      player:broadcastSkillInvoke(self.name, table.random({3, 4}))
      room:notifySkillInvoked(player, self.name, "defensive")
    end
    if self.cost_data then
      room:throwCard(self.cost_data, self.name, player, player)
    else
      player:drawCards(1, self.name)
    end
  end,
  enabled_at_play = function(self, player)
    return player:getHandcardNum() ~= 1
  end,
  enabled_at_response = function(self, player, response)
    return not response and player:getHandcardNum() ~= 1
  end,
}
wenyang2:addSkill(steam__chongjian)
Fk:loadTranslationTable{
  ["steam2__wenyang"] = "文鸯",
  ["#steam2__wenyang"] = "独骑破军",
  ["illustrator:steam2__wenyang"] = "M云涯",
  ["designer:steam2__wenyang"] = "从珂",

  ["steam__chongjian"] = "冲坚",
  [":steam__chongjian"] = "你可以将手牌调整至1，视为使用【闪】或【决斗】。",
  ["#steam__chongjian"] = "刃仇：将手牌调整至1，视为使用【闪】或【决斗】",
  ["$steam__chongjian1"] = "奋六钧之力，破九天重云！",
  ["$steam__chongjian2"] = "攻敌营垒，不留一隅之地！",
}

local wenyang = General:new(extension, "steam__wenyang", "wei", 5)

local quedi = fk.CreateViewAsSkill{
  name = "steam__quedi",
  anim_type = "offensive",
  pattern = "duel",
  prompt = "#steam__quedi",
  card_filter = function (self, to_select, selected)
    return #selected == 0 and Fk:getCardById(to_select).type == Card.TypeEquip
    and not Self:prohibitDiscard(Fk:getCardById(to_select))
  end,
  view_as = function(self, cards)
    if #cards > 1 then return end
    local c = Fk:cloneCard("duel")
    c.skillName = self.name
    if #cards == 1 then
      c:addSubcard(cards[1])
    end
    return c
  end,
  before_use = function (self, player, use)
    if #use.card.subcards == 0 then
      player.room:loseHp(player, 1, self.name)
    end
  end,
  enabled_at_response = Util.FalseFunc,
}
wenyang:addSkill(quedi)

local choujue = fk.CreateTriggerSkill{
  name = "steam__choujue",
  anim_type = "drawcard",
  events = {fk.DrawNCards},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self)
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    data.n = player:getMark("@steam__choujue")
  end,

  on_lose = function (self, player, is_death)
    player.room:setPlayerMark(player, "@steam__choujue", 0)
  end,

  refresh_events = {fk.TurnEnd, fk.Damaged},
  can_refresh = function (self, event, target, player, data)
    return target == player and player:hasSkill(self)
  end,
  on_refresh = function (self, event, target, player, data)
    player.room:addPlayerMark(player, "@steam__choujue", 1)
  end,
}
wenyang:addSkill(choujue)



Fk:loadTranslationTable{
  ["steam__wenyang"] = "文鸯",
  ["#steam__wenyang"] = "",
  ["cv:steam__wenyang"] = "",
  ["designer:steam__wenyang"] = "从珂",
  ["illustrator:steam__wenyang"] = "",


  ["steam__quedi"] = "却敌",
  [":steam__quedi"] = "出牌阶段，你可以失去1点体力或将一张装备牌当【决斗】使用。",
  ["#steam__quedi"] = "却敌：失去1点体力或将一张装备牌当【决斗】使用",

  ["steam__choujue"] = "仇决",
  [":steam__choujue"] = "你的摸牌阶段摸牌数为0；回合结束时或受到伤害后，此数字+1。",
  ["@steam__choujue"] = "仇决",

  ["$steam__quedi1"] = "乐嘉风起残云散，万钧雷震万千军！",
  ["$steam__quedi2"] = "进袭如惊涛，破围如落潮！",
}


local wenyang3 = General:new(extension, "steam3__wenyang", "jin", 4)
Fk:loadTranslationTable{
  ["steam3__wenyang"] = "文鸯",
  ["#steam3__wenyang"] = "",
  ["cv:steam3__wenyang"] = "",
  ["designer:steam3__wenyang"] = "从珂",
  ["illustrator:steam3__wenyang"] = "鬼画府",
  ["~steam3__wenyang"] = "",
}
local chuifeng = fk.CreateViewAsSkill{
  name = "steam__chuifeng",
  anim_type = "offensive",
  prompt = "#steam__chuifeng",
  pattern = "slash",
  card_filter = function(self, to_select, selected)
    return #selected < 3 and table.contains(Self.player_cards[Player.Hand], to_select)
  end,
  view_as = function(self, cards)
    if #cards ~= 3 and not (#cards == 1 and Self:getHandcardNum() == 1) then return nil end
    local c = Fk:cloneCard("slash")
    c.skillName = self.name
    c:addSubcards(cards)
    return c
  end,
  after_use = function (self, player, use)
    local room = player.room
    if player.dead or not use.damageDealt then return end
    player:drawCards(3, self.name)
    if player.dead then return end
    local num = (player:getHandcardNum() + 1) // 2
    room:askForDiscard(player, num, num, false, self.name, false)
  end,
  enabled_at_play = function(self, player)
    return true
  end,
  enabled_at_response = function (self, player, response)
    return not response and not player:isKongcheng()
  end,
}
local chuifengBuff = fk.CreateTriggerSkill{
  name = "#steam__chuifeng_trigger",
  refresh_events = {fk.TargetSpecified},
  can_refresh = function (self, event, target, player, data)
    return player.id == data.to and table.contains(data.card.skillNames, chuifeng.name) and not player.dead
  end,
  on_refresh = function (self, event, target, player, data)
    player:addQinggangTag(data)
  end
}
chuifeng:addRelatedSkill(chuifengBuff)
wenyang3:addSkill(chuifeng)
Fk:loadTranslationTable{
  ["steam__chuifeng"] = "椎锋",
  [":steam__chuifeng"] = "你可以将三张或唯一一张手牌当无视防具的【杀】使用，若造成伤害，你摸三张牌并弃置半数向上手牌。",
  ["#steam__chuifeng"] = "椎锋：将三张或唯一一张手牌当无视防具的【杀】使用，若造成伤害，则摸3弃半",

  ["$steam__chuifeng1"] = "率军冲锋，不惧刀枪所阻！",
  ["$steam__chuifeng2"] = "登锋履刃，何妨马革裹尸！",
}


local lvmeng = General:new(extension, "steam__lvmeng", "wu", 4)

local keji = fk.CreateTriggerSkill{
  name = "steam__keji",
  anim_type = "drawcard",
  events = {fk.TurnEnd},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) and not player:isKongcheng() then
      local room = player.room
      if #room.logic:getEventsOfScope(GameEvent.MoveCards, 1, function (e)
        for _, move in ipairs(e.data) do
          if move.from == player.id then
            for _, info in ipairs(move.moveInfo) do
              if info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip then
                return true
              end
            end
          end
        end
      end, Player.HistoryTurn) > 0 then
        local cards = {}
        room.logic:getEventsOfScope(GameEvent.MoveCards, 1, function (e)
          for _, move in ipairs(e.data) do
            if move.toArea == Card.DiscardPile then
              for _, info in ipairs(move.moveInfo) do
                if table.contains(room.discard_pile, info.cardId) then
                  table.insertIfNeed(cards, info.cardId)
                end
              end
            end
          end
        end, Player.HistoryTurn)
        if #cards > 0 then
          self.cost_data = {cards = cards}
          return true
        end
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    player.room:moveCards({
      from = player.id,
      ids = player:getCardIds("h"),
      toArea = Card.DiscardPile,
      moveReason = fk.ReasonExchange,
      skillName = self.name,
      proposer = player.id,
      moveVisible = true,
    },
    {
      to = player.id,
      ids = self.cost_data.cards,
      toArea = Card.PlayerHand,
      moveReason = fk.ReasonExchange,
      skillName = self.name,
      proposer = player.id,
      moveVisible = true,
    })
  end,
}
lvmeng:addSkill(keji)
Fk:loadTranslationTable{
  ["steam__lvmeng"] = "吕蒙",
  ["#steam__lvmeng"] = "白衣渡江",
  ["illustrator:steam__lvmeng"] = "biou09",
  ["designer:steam__lvmeng"] = "云雀",

  ["steam__keji"] = "克己",
  [":steam__keji"] = "你失去过牌的回合结束时，你可以用你的所有手牌交换本回合进入弃牌堆的牌。",

  ["$steam__keji1"] = "隐忍克己，以待天时。",
  ["$steam__keji2"] = "一介武夫，终成一代儒将。",
  ["~steam__lvmeng"] = "咳咳……本想攻其不备，谁知……",
}

return extension
