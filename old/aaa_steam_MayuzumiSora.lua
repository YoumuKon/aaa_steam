local extension = Package("aaa_steam_MayuzumiSora")
extension.extensionName = "aaa_steam"

local U = require "packages.utility.utility"
local RUtil = require "packages.aaa_fenghou.utility.rfenghou_util"
local DIY = require "packages.diy_utility.diy_utility"

Fk:loadTranslationTable{
  ["aaa_steam_MayuzumiSora"] = "黛穹",
}

local duxi = General(extension, "steam__duxi", "jin", 3, 3, General.Male)
local xiahoumiao = General(extension, "steam__xiahoumiao", "jin", 3, 3, General.Female)
local yyangxiu = General(extension, "steam__yyangxiu", "jin", 3, 3, General.Male)
local luji = General(extension, "steam__luji", "wu", 4, 4, General.Male)
local luji2 = General(extension, "steam2__luji", "jin", 4, 4, General.Male)
luji2.hidden = true
local luyun = General(extension, "steam__luyun", "wu", 4, 4, General.Male)
local luyun2 = General(extension, "steam2__luyun", "jin", 4, 4, General.Male)
luyun2.hidden = true

local function AddWinAudio(general)
  local Win = fk.CreateActiveSkill{ name = general.name.."_win_audio" }
  Win.package = extension
  Fk:addSkill(Win)
end

local liangzhi = fk.CreateActiveSkill{
  name = "steam__liangzhi",
  anim_type = "offensive",
  card_num = 0,
  target_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, to_select, selected, selected_cards)
    return #selected == 0 and to_select ~= Self.id and not Fk:currentRoom():getPlayerById(to_select):isNude()
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    local cards = room:askForCardsChosen(player, target, 1, 3, "he", self.name)
    local cards2 = table.filter(cards, function(id) return table.contains(target:getCardIds{Player.Hand, Player.Equip}, id) end)
    local x = #cards2
    player:showCards(cards2)
    if not target.dead then
      local choices = {}
      if table.every(cards2, function(id) return not target:prohibitDiscard(Fk:getCardById(id)) end) then
        table.insert(choices, "discard and drawyou")
      end
      if not target:isProhibited(player, Fk:cloneCard("slash")) then
        table.insert(choices, "slashyou")
      end
      if #choices == 0 then return end
      local choice = room:askForChoice(target, choices, "steam__liangzhi", "#steam__liangzhi-choice")
      if choice == "discard and drawyou" then
        room:moveCards(
        {from = target.id,
        ids = cards2,
        toArea = Card.DiscardPile,
        moveReason = fk.ReasonDiscard,
        proposer = target.id,
        skillName = self.name}
        )
        if not target.dead then
        target:drawCards(x, self.name)
        end
        if not player.dead then
        player:drawCards(x, self.name)
        end
      else
      local card = Fk:cloneCard("slash")
      card.skillName = self.name
      for _, id in ipairs(cards2) do
        card:addSubcard(id)
      end
      room:useCard{
      from = target.id ,
      tos = { { player.id} },
      card = card,
      extraUse = true,
    } 
      end
    end
  end,
}
duxi:addSkill(liangzhi)
local zhenzhan = fk.CreateTriggerSkill{
  name = "steam__zhenzhan",
  anim_type = "masochism",
  events = {fk.Damaged, fk.EnterDying},
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(self) then
      if event == fk.Damaged then
        return true
      else
        return not player:isProhibited(target, Fk:cloneCard("analeptic"))
      end
    end
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    if event == fk.Damaged then
      local choices = {"Damaged-1","cancel"}
      if not data.from.dead then
        table.insert(choices, "Damage-1")
      end
      local choice = player.room:askForChoice(player, choices, "steam__zhenzhan", "#steam__zhenzhan-choice")
      if choice ~= "cancel" then
        self.cost_data = choice
        return true
      end
    else
      local card = room:askForCard(player, 1, 1, true, self.name, true, ".|.|.|.|.|equip", "#steam__zhenzhan-ask")
      if #card > 0 then
        self.cost_data = { cards = card, tos = {target.id} }
        return true
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if event == fk.Damaged then
      if self.cost_data == "Damaged-1" then
        room:addPlayerMark(player, "@steam__zhenzhan1", 1)
      elseif not data.from.dead then
        room:addPlayerMark(data.from, "@steam__zhenzhan2", 1)
      end
  else
    local card = Fk:cloneCard("analeptic")
    card.skillName = self.name
    card:addSubcard(self.cost_data.cards[1])
    room:useCard{
      from = player.id,
      tos = { { target.id } },
      extra_data = { analepticRecover = true },
      card = card,
    }    
    end
  end
}
local zhenzhan_trigger = fk.CreateTriggerSkill{
  name = "#steam__zhenzhan_trigger",
  mute = true,
  events = {fk.DamageCaused, fk.DamageInflicted},
  can_trigger = function(self, event, target, player, data)
    if event == fk.DamageCaused then
      return target:getMark("@steam__zhenzhan2") > 0
    else
      return target:getMark("@steam__zhenzhan1") > 0
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if event == fk.DamageCaused then
      local x = target:getMark("@steam__zhenzhan2")
      room:notifySkillInvoked(target, "steam__zhenzhan", "offensive")
      data.damage = data.damage - x
      room:setPlayerMark(target, "@steam__zhenzhan2", 0)
    else
      local x = target:getMark("@steam__zhenzhan1")
      room:notifySkillInvoked(target, "steam__zhenzhan", "defensive")
      data.damage = data.damage - x
      room:setPlayerMark(target, "@steam__zhenzhan1", 0)
    end
  end,
}
zhenzhan:addRelatedSkill(zhenzhan_trigger)
duxi:addSkill(zhenzhan)

Fk:loadTranslationTable{
  ["steam__duxi"] = "杜锡",
  ["#steam__duxi"] = "潜虬隐尺水",
  ["cv:steam__duxi"] = "暂无",
  ["illustrator:steam__duxi"] = "鹜雨",
  ["designer:steam__duxi"] = "黛穹&一曲醉流觞",

  ["steam__liangzhi"] = "亮直",
  [":steam__liangzhi"] = "出牌阶段限一次，你可以展示一名其他角色至多三张牌，然后令其选择一项：1.弃置展示牌，然后其与你依次摸等量的牌；2.将展示牌当一张无距离限制的【杀】对你使用。",
  ["steam__zhenzhan"] = "针毡",
  [":steam__zhenzhan"] = "当你受到伤害后，你可以选择一项：1.令你下次受到的伤害-1；2.令伤害来源下次造成的伤害-1。当你进入濒死状态时，你可以将一张装备牌当【酒】使用。",

  ["discard and drawyou"] = "弃置展示牌，与对方依次摸等量的牌",
  ["slashyou"] = "将展示牌当【杀】对对方使用",
  ["#steam__liangzhi-choice"] = "亮直：请选择一项",
  ["Damaged-1"] = "你下次受到的伤害-1",
  ["Damage-1"] = "伤害来源下次造成的伤害-1",
  ["@steam__zhenzhan1"] = "受到伤害-",
  ["@steam__zhenzhan2"] = "造成伤害-",
  ["steam__zhenzhan_trigger"] = "针毡",
  ["#steam__zhenzhan-choice"] = "针毡：请选择一项",
  ["#steam__zhenzhan-ask"] = "针毡：请将一张装备牌当【酒】使用。",

  ["~steam__duxi"] = "临渊解梦，何如直挂云帆？",
} 

local jiandie = fk.CreateTriggerSkill{
  name = "steam__jiandie",
  events = {fk.EventPhaseStart},
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    if not (player:hasSkill(self) and target == player) then return false end
      return player.phase == Player.Play and not player:isKongcheng()
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local card = room:askForCard(player, 1, 4, false, self.name, true, ".", "#steam__jiandie_ask")
    if #card > 0 then
      self.cost_data = card
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local x = #self.cost_data
    room:recastCard(self.cost_data, player, self.name)
    if #table.map(room:getOtherPlayers(player), Util.IdMapper) > 0 then
    local to = room:askForChoosePlayers(player, table.map(room:getOtherPlayers(player), Util.IdMapper), 1, 1,
    "steam__jiandie-start", self.name, false)
    local first = room:getPlayerById(to[1])
    local choices = {"draw1","recast1","discardarea1","reset"}
    local tolose = room:askForChoices(first, choices, 1, x, self.name, "#steam__jiandie-choice", false)
    if table.contains(tolose, "draw1") and not first.dead then
      first:drawCards(1, self.name)
    end
    if table.contains(tolose, "recast1") and not first.dead and not first:isNude() then
      local recast = room:askForCard(first, 1, 1, true, self.name, false,".|.|.|.|.|", "#steam__jiandie-recast")
      room:recastCard(recast, first, self.name)
    end
    if table.contains(tolose, "discardarea1") and not first.dead and not first:isAllNude() then
      local chosen = room:askForCardChosen(first, first, "hej", self.name, "#steam__jiandie-discardarea1")
      room:throwCard({chosen}, self.name, first, first)
    end
    if table.contains(tolose, "reset") and not first.dead then
      first:reset()
    end
    local choices1 = {"dosame","cancel"}
    if room:askForChoice(player, choices1, self.name, "#steam__jiandie-choice1") == "dosame" then
      if table.contains(tolose, "draw1") and not player.dead then
        player:drawCards(1, self.name)
      end
      if table.contains(tolose, "recast1") and not player.dead and not player:isNude() then
        local recast = room:askForCard(player, 1, 1, true, self.name, false,".|.|.|.|.|", "#steam__jiandie-recast")
        room:recastCard(recast, player, self.name)
      end
      if table.contains(tolose, "discardarea1") and not player.dead and not player:isAllNude() then
        local chosen = room:askForCardChosen(player, player, "hej", self.name)
        room:throwCard({chosen}, self.name, player, player)
      end
      if table.contains(tolose, "reset") and not player.dead then
        player:reset()
      end
    end
  end
  end,
}
xiahoumiao:addSkill(jiandie)

local sangyu = fk.CreateTriggerSkill{
  name = "steam__sangyu",
  anim_type = "offensive",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    local room = player.room
    if player:hasSkill(self) and target ~= player and target.phase == Player.Finish then
      return (#room.logic:getEventsOfScope(GameEvent.MoveCards, 1, function (e)
        for _, move in ipairs(e.data) do
          if move.from == player.id and move.to ~= player.id then
            for _, info in ipairs(move.moveInfo) do
              if info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip then
                return true
              end
            end
          end
        end
      end, Player.HistoryTurn) > 0 and player:isWounded())
    or #room.logic:getEventsOfScope(GameEvent.ChangeHp, 1, function(e)
          local damage = e.data[5]
          if damage and damage.to == player then
            return true
          end
        end, Player.HistoryTurn) > 0
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if #room.logic:getEventsOfScope(GameEvent.MoveCards, 1, function (e)
      for _, move in ipairs(e.data) do
        if move.from == player.id and move.to ~= player.id then
          for _, info in ipairs(move.moveInfo) do
            if info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip then
              return true
            end
          end
        end
      end
    end, Player.HistoryTurn) > 0 and player:isWounded() then
      room:recover({
        who = player,
        num = 1,
        recoverBy = player,
        skillName = self.name,
      })
    end
    if #room.logic:getEventsOfScope(GameEvent.ChangeHp, 1, function(e)
      local damage = e.data[5]
      if damage and damage.to == player then
        return true
      end
    end, Player.HistoryTurn) > 0 then
      player:drawCards(1,self.name)
    end
  end,
}
xiahoumiao:addSkill(sangyu)

Fk:loadTranslationTable{
  ["steam__xiahoumiao"] = "夏侯邈",
  ["#steam__xiahoumiao"] = "万岁乡君",
  ["cv:steam__xiahoumiao"] = "暂无",
  ["illustrator:steam__xiahoumiao"] = "宸星",
  ["designer:steam__xiahoumiao"] = "黛穹",

  ["steam__jiandie"] = "鹣鲽",
  [":steam__jiandie"] = "出牌阶段开始时，你可以重铸至多四张手牌，然后令一名其他角色选择至多等量项并依次执行：1.摸一张牌：2.重铸一张牌；3.弃置区域里的一张牌；4.复原武将牌。结算后你可以依次执行同选项。",
  ["steam__sangyu"] = "桑榆",
  [":steam__sangyu"] = "其他角色的结束阶段，若你本回合内：失去过牌，你可以回复1点体力；受到过伤害，你可以摸一张牌。",

  ["#steam__jiandie_ask"] = "鹣鲽：你可以重铸至多四张手牌，令其他角色选择至多等量项执行，且你也可以执行",
  ["steam__jiandie-start"] = "鹣鲽：你已重铸手牌，请令其他角色选择至多等量项执行，且你也可以执行",
  ["#steam__jiandie-choice"] = "鹣鲽：请选择至多发起者重铸牌数项执行，且其也可以执行",
  ["#steam__jiandie-choice1"] = "鹣鲽：是否也执行其的选择？",
  ["recast1"] = "重铸一张牌",
  ["discardarea1"] = "弃置区域里的一张牌",
  ["dosame"] = "执行相同选项",
  ["#steam__jiandie-recast"] = "鹣鲽：请重铸一张牌",
  ["#steam__jiandie-discardarea1"] = "鹣鲽：请弃置区域里的一张牌",

  ["~steam__xiahoumiao"] = "临渊解梦，何如直挂云帆？",
} 

local haochi = fk.CreateActiveSkill{
  name = "steam__haochi",
  anim_type = "drawcard",
  min_card_num = 1,
  target_num = 1,
  prompt = "#steam__haochi",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  card_filter = function(self, to_select, selected)
    return table.contains(Self:getCardIds("he"), to_select)
  end,
  target_filter = function(self, to_select, selected)
    return #selected == 0 and to_select ~= Self.id 
  end,
  on_use = function(self, room, effect)
    local target = room:getPlayerById(effect.tos[1])
    local player = room:getPlayerById(effect.from)
    player.room:setPlayerMark(player, "steam__haochi-phase", 1)
    local cards = effect.cards
    room:moveCardTo(cards, Player.Hand, target, fk.ReasonGive, self.name, nil, false, player.id)
    local n = player:getHandcardNum()
    for _, p in ipairs(room:getOtherPlayers(player, false)) do
      n = math.max(n, p:getHandcardNum())
    end
    if player:getHandcardNum() < n then
      player:drawCards(n - player:getHandcardNum(), self.name)
    end
  end,
}
local haochi_delay = fk.CreateTriggerSkill{
  name = "#steam__haochi_delay",
  mute = true,
  events = {fk.EventPhaseEnd},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:getMark("steam__haochi-phase") > 0 and not player:isKongcheng()
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local n = player:getHandcardNum()
    for _, p in ipairs(room:getOtherPlayers(player, false)) do
      n = math.min(n, p:getHandcardNum())
    end
    if player:getHandcardNum() > n then
      room:askForDiscard(player, player:getHandcardNum() - n, player:getHandcardNum() - n, false, self.name, false, ".", "#steam__haochi-delay")
    end
  end,
}
haochi:addRelatedSkill(haochi_delay)
yyangxiu:addSkill(haochi)
local qilu = fk.CreateTriggerSkill{
  name = "steam__qilu",
  anim_type = "support",
  frequency = Skill.Compulsory,
  events = {fk.AfterCardsMove},
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(self) then return false end
      for _, move in ipairs(data) do
        local to = move.to and player.room:getPlayerById(move.to) or nil
        if to and move.proposer == player.id and move.moveReason == fk.ReasonGive then
          return true
        end
      end
  end,
  on_trigger = function(self, event, target, player, data)
    local targets = {}
    local room = player.room
    for _, move in ipairs(data) do
      local to = move.to and room:getPlayerById(move.to) or nil
      if to and to ~= player and (move.from == player.id or (move.skillName and player:hasSkill(move.skillName))) 
      and (move.toArea == Card.PlayerHand or move.toArea == Card.PlayerEquip) and move.moveReason == fk.ReasonGive then
        table.insertIfNeed(targets, move.to)
      end
    end
    room:sortPlayersByAction(targets)
    for _, target_id in ipairs(targets) do
      if not player:hasSkill(self) then break end
      local skill_target = room:getPlayerById(target_id)
      self:doCost(event, skill_target, player, data)
    end
  end,
  on_use = function(self, event, target, player, data)
    for _, move in ipairs(data) do
      local to = move.to and player.room:getPlayerById(move.to) or nil
      if to ~= player and player:getMark(self.name) == move.to and player:isWounded() then
        player.room:recover({
          who = player,
          num = 1,
          recoverBy = player,
          skillName = self.name,
        })
      elseif player:getMark(self.name) ~= move.to and player:getMark(self.name) ~= 0 then
        player.room:loseHp(player, 1, self.name)
      end
      player.room:setPlayerMark(player, self.name, move.to)
      player.room:setPlayerMark(player, "@steam__qilu", player.room:getPlayerById(move.to).general)
    end
  end,

  on_acquire = function (self, player, is_start)
    local room = player.room
    room.logic:getEventsOfScope(GameEvent.MoveCards, 1, function (e)
      for _, move in ipairs(e.data) do
        local to = move.to and player.room:getPlayerById(move.to) or nil
        if to and move.proposer == player.id and move.moveReason == fk.ReasonGive then
          room:setPlayerMark(player, self.name, move.to)
          room:setPlayerMark(player, "@steam__qilu", player.room:getPlayerById(move.to).general)
        end
      end
    end, Player.HistoryGame)
  end,
}
yyangxiu:addSkill(qilu)

Fk:loadTranslationTable{
  ["steam__yyangxiu"] = "羊琇",
  ["#steam__yyangxiu"] = "鲜克有终",
  ["cv:steam__yyangxiu"] = "暂无",
  ["illustrator:steam__yyangxiu"] = "桃桃糍花",
  ["designer:steam__yyangxiu"] = "黛穹&一曲醉流觞",

  ["steam__haochi"] = "豪侈",
  [":steam__haochi"] = "出牌阶段限一次，你可以将至少一张牌交给一名其他角色，然后你摸牌至与手牌最多的角色的手牌数相同。若如此做，此阶段结束时，你将手牌弃置至与手牌最少的角色的手牌数相同。",
  ["steam__qilu"] = "歧路",
  [":steam__qilu"] = "锁定技，当你交给其他角色牌后，若其为你上次交给牌的角色，你回复1点体力；否则你失去1点体力。",

  ["#steam__haochi"] = "豪侈：你可以交出任意张牌，摸牌至全场最多，本阶段结束时弃置手牌至全场最少！",
  ["#steam__haochi_delay"] = "豪侈",
  ["#steam__haochi-delay"] = "豪侈：请弃置手牌至全场最少！",
  ["@steam__qilu"] = "歧路",

  ["~steam__yyangxiu"] = "临渊解梦，何如直挂云帆？",
} 

local yicai = fk.CreateViewAsSkill{
  name = "steam__yicai",
  anim_type = "control",
  frequency = Skill.Compulsory,
  prompt = "#steam__yicai-viewas",
  pattern = ".|.|.|.|.|basic",
  interaction = function()
    local all_names = U.getAllCardNames("b")
    local names = U.getViewAsCardNames(Self, "steam__yicai", all_names)
    if #names > 0 then
      return UI.ComboBox { choices = names, all_choices = all_names }
    end
  end,
  handly_pile = true,
  card_filter = function(self, to_select, selected)
    return #selected == 0 and Fk:getCardById(to_select).sub_type == Card.SubtypeDelayedTrick
  end,
  view_as = function(self, cards)
    if not self.interaction.data or #cards ~= 1 then return end
    local card = Fk:cloneCard(self.interaction.data)
    card.skillName = self.name
    card:addSubcard(cards[1])
    return card
  end,
}
local yicai_trigger = fk.CreateTriggerSkill{
  name = "#steam__yicai_trigger",
  anim_type = "offensive",
  frequency = Skill.Compulsory,

  refresh_events = {fk.CardUsing},
  can_refresh = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and data.card.skillName == "steam__yicai" and data.card.trueName == "slash"
  end,
  on_refresh = function(self, event, target, player, data)
    data.additionalDamage = (data.additionalDamage or 0) + 1
  end,
}
local yicai_prohibit = fk.CreateProhibitSkill{
  name = "#steam__yicai_prohibit",
  frequency = Skill.Compulsory,
  is_prohibited = function(self, from, to, card)
    if to:hasSkill(self) then
      return card.sub_type == Card.SubtypeDelayedTrick
    end
  end,
}
yicai:addRelatedSkill(yicai_trigger)
yicai:addRelatedSkill(yicai_prohibit)
luji:addSkill(yicai)

local bianwang = fk.CreateTriggerSkill{
  name = "steam__bianwang",
  anim_type = "drawcard",
  events = {fk.TargetConfirmed},
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(self) then
      local room = player.room
      local use_event = room.logic:getCurrentEvent():findParent(GameEvent.UseCard, true)
      if use_event == nil then return false end
        return #room.logic:getEventsOfScope(GameEvent.UseCard, 999, function (e)
          local use = e.data[1]
          if table.find(TargetGroup:getRealTargets(use.tos), function (pid)
            return pid == player.id
          end) then
          return true
          end
        end, Player.HistoryTurn) == 1
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local card = room:askForDiscard(player, 1, 1, true, self.name, true, ".", "#steam__bianwang")
    if #card > 0 then
    table.insertIfNeed(data.nullifiedTargets, player.id)
  else
    data.disresponsiveList = data.disresponsiveList or {}
    table.insertIfNeed(data.disresponsiveList, player.id)
    player:drawCards(1, self.name)
    end
  end,
}
luji:addSkill(bianwang)
local ruluo = fk.CreateTriggerSkill{
  name = "steam__ruluo",
  anim_type = "control",
  frequency = Skill.Compulsory,
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and
      player.phase == Player.Start
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local choices = {"recoverall"}
    if player.general == "steam__luji" or player.general == "steam__luyun" or player.general == "simayi" then
      table.insertIfNeed(choices, "changejin")
    end
    if target.deputyGeneral and target.deputyGeneral ~= "" then
      if player.deputyGeneral == "steam__luji" or player.deputyGeneral == "steam__luyun" or player.deputyGeneral == "simayi" then
        table.insertIfNeed(choices, "changejin")
      end
    end
    local choice = room:askForChoice(player, choices, "steam__ruluo", "#steam__ruluo-choice")
    if choice == "recoverall" then
      if player:getLostHp() > 0 then
        room:recover({who = player, num = player:getLostHp(), recoverBy = player, skillName = self.name})
      end
      room:handleAddLoseSkills(player, "-steam__ruluo", nil, true, false)
    else
      player:drawCards(3, self.name)
      local choices1 = {}
      if player.general == "steam__luji" or player.general == "steam__luyun" or player.general == "simayi" then
        table.insert(choices1, "changejin_general")
      end
      if player.deputyGeneral and player.deputyGeneral ~= "" then
        if player.deputyGeneral == "steam__luji" or player.deputyGeneral == "steam__luyun" or player.deputyGeneral == "simayi" then
          table.insert(choices1, "changejin_deputyGeneral")
        end
      end
      if #choices1 == 0 then return end
      local choice1 = room:askForChoice(player, choices1, "steam__ruluo", "#steam__ruluo-choice")
      if choice1 == "changejin_general" then
        if player.general == "steam__luji" then
          room:changeHero(player, "steam2__luji", false, false, true, false, true)
        elseif player.general == "steam__luyun" then
          room:changeHero(player, "steam2__luyun", false, false, true, false, true)
        elseif player.general == "simayi" then
          room:changeHero(player, "ol__simayi", false, false, true, false, true)
        end
        room:broadcastProperty(player, "general")
      else
        if player.deputyGeneral == "steam__luji" then
          room:changeHero(player, "steam2__luji", false, true, true, false, false)
        elseif player.deputyGeneral == "steam__luyun" then
          room:changeHero(player, "steam2__luyun", false, true, true, false, false)
        elseif player.deputyGeneral == "simayi" then
          room:changeHero(player, "ol__simayi", false, true, true, false, false)
        end
        room:broadcastProperty(player, "deputyGeneral")
      end
    end
  end,
}
luji:addSkill(ruluo)

luji2:addSkill("steam__yicai")
local luhai = fk.CreateTriggerSkill{
  name = "steam__luhai",
  events = {fk.EventPhaseStart},
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    if not (player:hasSkill(self) and target == player) then return false end
      return player.phase == Player.Play
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local to = room:askForChoosePlayers(player, table.map(room:getOtherPlayers(player), Util.IdMapper), 1, 1,
    "steam__luhai-start", self.name, true)
    if #to > 0 then
      self.cost_data = to[1]
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local first = room:getPlayerById(self.cost_data)
    local cards = room:askForCardsChosen(player, first, 0, 2, "he", self.name, "steam__luhai-throw")
    if #cards > 0 then
      room:moveCards(
        {from = first.id,
        ids = cards,
        toArea = Card.DiscardPile,
        moveReason = fk.ReasonDiscard,
        proposer = player.id,
        skillName = self.name}
        )
      player:setMark("steam__luhai1-phase", #cards)
    end
    if not first.dead and not player.dead then
    local strike = {"0","1","2"}
    local choice = player.room:askForChoice(player, strike, self.name, "#steam__luhai-choicemax::"..first.id,
    false, {"0","1","2"})
    if tonumber(choice) == 1 then
      room:damage{
        from = player,
        to = first,
        damage = 1,
        damageType = fk.ThunderDamage,
        skillName = self.name,
      }
      room:setPlayerMark(player, "steam__luhai2_1-phase", first.id)
    elseif tonumber(choice) == 2 then
      room:damage{
        from = player,
        to = first,
        damage = 2,
        damageType = fk.ThunderDamage,
        skillName = self.name,
      }
      room:setPlayerMark(player, "steam__luhai2_2-phase", first.id)
    end
    end
  end,
}
local luhai_delay = fk.CreateTriggerSkill{
  name = "#steam__luhai_delay",
  mute = true,
  events = {fk.EventPhaseEnd},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:usedSkillTimes("steam__luhai", Player.HistoryPhase) > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if player:getMark("steam__luhai1-phase") > 0 then
      room:askForDiscard(player, player:getMark("steam__luhai1-phase"), player:getMark("steam__luhai1-phase"), false, self.name, false, ".", "#steam__luhai-delay")
    end
      local mark1 = player:getMark("steam__luhai2_1-phase")
      local mark2 = player:getMark("steam__luhai2_2-phase")
      if mark1 ~= 0 and not room:getPlayerById(mark1).dead and not player.dead then
        room:damage{
          from = room:getPlayerById(mark1),
          to = player,
          damage = 1,
          damageType = fk.ThunderDamage,
          skillName = self.name,
        }
      end
      if mark2 ~= 0 and not room:getPlayerById(mark2).dead and not player.dead then
        room:damage{
          from = room:getPlayerById(mark2),
          to = player,
          damage = 2,
          damageType = fk.ThunderDamage,
          skillName = self.name,
        }
      end
  end,
}
luhai:addRelatedSkill(luhai_delay)
luji2:addSkill(luhai)
local heli = fk.CreateTriggerSkill{
  name = "steam__heli",
  anim_type = "masochism",
  events = {fk.Death},
  can_trigger = function(self, event, target, player, data)
    if target == player then
      return player:hasSkill(self, false, true)
    end
  end,
  on_cost = function(self, event, target, player, data)
    local to = player.room:askForChoosePlayers(player, table.map(player.room:getAlivePlayers(), Util.IdMapper), 1, 1, "#steam__heli-choose", self.name, true)
    if #to > 0 then
      self.cost_data = to[1]
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local to = player.room:getPlayerById(self.cost_data)
    player.room:setPlayerMark(to, "@@steam__heli", 1)
  end,
}
local heli_maxcards = fk.CreateMaxCardsSkill{
  name = "#steam__heli_maxcards",
  global = true,
  correct_func = function(self, player)
    if player:getMark("@@steam__heli") > 0 then
    return -Fk:currentRoom():getBanner("RoundCount")
    end
  end,
}
heli:addRelatedSkill(heli_maxcards)
luji2:addSkill(heli)
Fk:loadTranslationTable{
  ["steam__luji"] = "陆机",
  ["#steam__luji"] = "放鹤华亭",
  ["cv:steam__luji"] = "暂无",
  ["illustrator:steam__luji"] = "帛小曳",
  ["designer:steam__luji"] = "黛穹&一曲醉流觞",

  ["steam__yicai"] = "逸才",
  [":steam__yicai"] = "锁定技，你不能成为延时锦囊牌的目标。你的延时锦囊牌能当任意一张基本牌使用或打出，以此法使用的【杀】造成的伤害+1。",
  ["steam__bianwang"] = "辩亡",
  [":steam__bianwang"] = "当你每回合首次成为牌的目标后，你可以选择令此牌对你无效/不能被响应，然后你弃置/摸一张牌。",
  ["steam__ruluo"] = "入洛",
  [":steam__ruluo"] = "锁定技，准备阶段，你选择一项：1.摸三张牌并将武将牌替换为晋势力同名武将；2.将体力回复至体力上限并失去“入洛”。",
  --彩蛋：入洛检测三个同名（陆云，陆机，**），洛水也是洛

  ["#steam__yicai-viewas"] = "逸才：请将一张延时锦囊牌当基本牌使用",
  ["#steam__yicai_trigger"] = "逸才",
  ["#steam__bianwang"] = "辩亡：请弃置一张牌令使用牌对你无效，否则你摸一张牌且不可响应此牌。",
  ["#steam__ruluo-choice"] = "入洛：请选择一项",
  ["recoverall"] = "回复所有体力，失去本技能",
  ["changejin"] = "更换主将或副将为替换为晋势力同名武将",
  ["changejin_general"] = "更换主将为替换为晋势力同名武将",
  ["changejin_deputyGeneral"] = "更换副将为替换为晋势力同名武将",

  ["~steam__luji"] = "临渊解梦，何如直挂云帆？",

  ["steam2__luji"] = "陆机",
  ["#steam2__luji"] = "清厉之朗月",
  ["cv:steam2__luji"] = "暂无",
  ["illustrator:steam2__luji"] = "帛小曳",
  ["designer:steam2__luji"] = "黛穹&一曲醉流觞",

  ["steam__luhai"] = "陆海",
  [":steam__luhai"] = "出牌阶段开始时，你可以选择一名其他角色并依次执行任意项：1.弃置其至多两张牌，然后此阶段结束时，你弃置等量的牌；"..
  "2.对其造成至多2点雷电伤害，然后此阶段结束时，你受到其造成的等量雷电伤害。",
  ["steam__heli"] = "鹤唳",
  [":steam__heli"] = "当你死亡时，你可以令一名其他角色的手牌上限-X（X为游戏轮数）。",

  ["#steam__luhai_delay"] = "陆海",
  ["#steam__luhai-delay"] = "陆海：请弃置等同于你本阶段因此弃置其他角色牌数张牌。",
  ["steam__luhai-start"] = "是否对一名其他角色发动 陆海？",
  ["steam__luhai-throw"] = "发动 陆海：是否弃置其他角色至多两张牌，然后你本阶段结束弃置等量张牌？",
  ["#steam__luhai-choicemax"] = "对 %dest 发动 陆海 ， 选择对其造成雷电伤害的数量（其本阶段结束也对你造成等量伤害）。",
  ["#steam__heli-choose"] = "鹤唳：令一名其他角色的手牌上限-X（X为游戏轮数）。",
  ["#steam__heli_maxcards"] = "鹤唳",
  ["@@steam__heli"] = "鹤唳",
} 
local qingcai = fk.CreateViewAsSkill{
  name = "steam__qingcai",
  anim_type = "control",
  frequency = Skill.Compulsory,
  prompt = "#steam__qingcai-viewas",
  pattern = ".|.|.|.|.|basic",
  interaction = function()
    local all_names = U.getAllCardNames("b")
    local names = U.getViewAsCardNames(Self, "steam__qingcai", all_names)
    if #names > 0 then
      return UI.ComboBox { choices = names, all_choices = all_names }
    end
  end,
  handly_pile = true,
  card_filter = function(self, to_select, selected)
    return #selected == 0 and Fk:getCardById(to_select).sub_type == Card.SubtypeDelayedTrick
  end,
  view_as = function(self, cards)
    if not self.interaction.data or #cards ~= 1 then return end
    local card = Fk:cloneCard(self.interaction.data)
    card.skillName = self.name
    card:addSubcard(cards[1])
    return card
  end,
}
local qingcai_trigger = fk.CreateTriggerSkill{
  name = "#steam__qingcai_trigger",
  anim_type = "offensive",
  frequency = Skill.Compulsory,

  refresh_events = {fk.CardUsing},
  can_refresh = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and data.card.skillName == "steam__qingcai" and data.card.name == "peach"
  end,
  on_refresh = function(self, event, target, player, data)
    data.additionalRecover = (data.additionalRecover or 0) + 1
  end,
}
local qingcai_prohibit = fk.CreateProhibitSkill{
  name = "#steam__qingcai_prohibit",
  frequency = Skill.Compulsory,
  is_prohibited = function(self, from, to, card)
    if to:hasSkill(self) then
      return card.sub_type == Card.SubtypeDelayedTrick
    end
  end,
}
qingcai:addRelatedSkill(qingcai_trigger)
qingcai:addRelatedSkill(qingcai_prohibit)
luyun:addSkill(qingcai)

local guying = fk.CreateTriggerSkill{
  name = "steam__guying",
  anim_type = "support",
  events = {fk.AfterCardsMove},
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(self) or player.room:getOtherPlayers(player, false) == 0 or
    #player.room.logic:getEventsOfScope(GameEvent.MoveCards, 999, function (e)
      for _, move in ipairs(e.data) do
        if move.from == player.id and move.toArea == Card.DiscardPile then
          for _, info in ipairs(move.moveInfo) do
            if info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip then
              return true
            end
          end
        end
      end
    end, Player.HistoryTurn) > 1 then return false end
    local cards = {}
    for _, move in ipairs(data) do
      if move.from == player.id and move.toArea == Card.DiscardPile then
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
    local cards = self.cost_data.cards
    local choice = {}
    for _, id in ipairs(cards) do
      if Fk:getCardById(id).color == Card.Red then
        table.insertIfNeed(choice, "givered")
      end
      if Fk:getCardById(id).color == Card.Black and player:canUse(Fk:getCardById(id), {bypass_times = false}) then
        table.insertIfNeed(choice, "useblack")
      end
    end
    if #choice > 0 then
      return player.room:askForSkillInvoke(player, self.name, nil, nil)
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cards = {}
    for _, move in ipairs(data) do
      if move.from == player.id and move.toArea == Card.DiscardPile then
        for _, info in ipairs(move.moveInfo) do
          if info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip then
            table.insertIfNeed(cards, info.cardId)
          end
        end
      end
    end
    cards = table.filter(cards, function(id) return player.room:getCardArea(id) == Card.DiscardPile end)
    cards = U.moveCardsHoldingAreaCheck(player.room, cards)
    local choice = {}
    for _, id in ipairs(cards) do
      if Fk:getCardById(id).color == Card.Red then
        table.insertIfNeed(choice, "givered")
      end
      if Fk:getCardById(id).color == Card.Black and player:canUse(Fk:getCardById(id), {bypass_times = false}) then
        table.insertIfNeed(choice, "useblack")
      end
    end
    if #choice > 0 then
      local choices = room:askForChoice(player, choice, "steam__guying", "#steam__guying-choice")
    if choices == "givered" then
      room:askForYiji(player, table.filter(cards, function(id) return Fk:getCardById(id).color == Card.Red end), {player}, self.name, 1, 1,
      "#steam__guying-give", table.filter(cards, function(id) return Fk:getCardById(id).color == Card.Red end), false)
    elseif choices == "useblack" then
      U.askForUseRealCard(room, player, table.filter(cards, function(id) return Fk:getCardById(id).color == Card.Black and 
      player:canUse(Fk:getCardById(id), {bypass_times = false}) end), nil, self.name, "#steam__guying-use", {
        bypass_times = true,
        extraUse = false,
        expand_pile = table.filter(cards, function(id) return Fk:getCardById(id).color == Card.Black and 
          player:canUse(Fk:getCardById(id), {bypass_times = false}) end),
      }, false, true)
    end
    end
  end,
}
luyun:addSkill(guying)
luyun:addSkill("steam__ruluo")

luyun2:addSkill("steam__qingcai")

local miaotan = fk.CreateActiveSkill{
  name = "steam__miaotan",
  anim_type = "offensive",
  card_num = 0,
  target_num = 1,
  prompt = "#steam__miaotan",
  can_use = function(self, player)
    return not player:isKongcheng()
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, to_select, selected)
    if #selected == 0 and not table.contains(Self:getTableMark("steam__miaotan-phase"), to_select) and to_select ~= Self.id then
      local target = Fk:currentRoom():getPlayerById(to_select)
      return Self:canPindian(target)
    end
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    room:addTableMark(player, "steam__miaotan-phase", target.id)
    local pindian = player:pindian({target}, self.name)
    if player.dead then return end
    local winner = pindian.results[target.id].winner
    if winner == nil or winner.dead then return end
    local cards = {}
    local id = pindian.fromCard:getEffectiveId()
    if room:getCardArea(id) == Card.DiscardPile then
      table.insert(cards, id)
    end
    id = pindian.results[target.id].toCard:getEffectiveId()
    if room:getCardArea(id) == Card.DiscardPile then
      table.insertIfNeed(cards, id)
    end
    if winner ~= player then
      room:obtainCard(player, cards, true, fk.ReasonJustMove, player.id, self.name)
      room:endTurn()
    else
      if #table.filter(U.getUniversalCards(room, "t"), function(id) local trick = Fk:getCardById(id)
        return trick.skill:getMinTargetNum() > 0 and not player:isProhibited(target, trick) and not player:prohibitUse(trick)
      end) > 0 then
      local _, dat = room:askForUseActiveSkill(player, "steam__miaotan_active", "#steam__miaotan-invoke::"..target.id, false, {miaotan_to = target.id})
      if dat then
        local card = Fk:cloneCard(dat.interaction)
        card.skillName = self.name
        room:useCard{
          from = player.id,
          tos = {{target.id}},
          card = card,
        }
      end
      end
    end
  end,
}
local miaotan_active = fk.CreateActiveSkill{
  name = "steam__miaotan_active",
  card_num = 0,
  target_num = 0,
  interaction = function()
    local all_names = U.getAllCardNames("t")
    return U.CardNameBox {
      choices = U.getViewAsCardNames(Self, "steam__miaotan_active", all_names),
      all_choices = all_names,
    }
  end,
  card_filter = function(self, to_select, selected)
    if #selected > 0 or Fk.all_card_types[self.interaction.data] == nil then return false end
    local card = Fk:cloneCard(self.interaction.data)
    card.skillName = "steam__miaotan"
    local to = Fk:currentRoom():getPlayerById(self.miaotan_to)
    return not Self:isProhibited(to, card) and not Self:prohibitUse(card)
  end,
}
luyun2:addSkill(miaotan)
Fk:addSkill(miaotan_active)
local mingli = fk.CreateTriggerSkill{
  name = "steam__mingli",
  anim_type = "special",
  events = {fk.PindianCardsDisplayed},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) and (player == data.from or player == data.to) then
      local cardA = Fk:getCardById(data.fromCard:getEffectiveId())
      local cardB
      for _, to in ipairs(data.tos) do
       cardB = Fk:getCardById(data.results[to.id].toCard:getEffectiveId())
      end
      return cardA.color ~= cardB.color or cardA.type ~= cardB.type
    end
  end,
  on_use = function(self, event, target, player, data)
    local cardA = Fk:getCardById(data.fromCard:getEffectiveId())
      local cardB
      for _, to in ipairs(data.tos) do
       cardB = Fk:getCardById(data.results[to.id].toCard:getEffectiveId())
      end
    if cardA.color ~= cardB.color then
      player.room:setPlayerMark(player, "steam__miaotan-phase", 0)
    end
    if cardA.type ~= cardB.type then
      local choices = {"+2","-2"}
      local choice = player.room:askForChoice(player, choices, self.name, "#steam__mingli-reward", false)
      if choice == "+2" then
      player.room:changePindianNumber(data, player, 2, self.name)
      else
      player.room:changePindianNumber(data, player, -2, self.name)
      end
    end
  end,
}
luyun2:addSkill(mingli)
Fk:loadTranslationTable{
  ["steam__luyun"] = "陆云",
  ["#steam__luyun"] = "云间龙驹",
  ["cv:steam__luyun"] = "暂无",
  ["illustrator:steam__luyun"] = "帛小曳",
  ["designer:steam__luyun"] = "黛穹&一曲醉流觞",

  ["steam__qingcai"] = "清才",
  [":steam__qingcai"] = "锁定技，你不能成为延时锦囊牌的目标。你的延时锦囊牌能当任意一张基本牌使用或打出，以此法使用的【桃】回复的体力+1。",
  ["steam__guying"] = "顾影",
  [":steam__guying"] = "每回合当你的牌首次置入弃牌堆时，你可以选择一项：1.使用其中一张黑色牌；2.获得其中一张红色牌。",

  ["#steam__qingcai-viewas"] = "清才：请将一张延时锦囊牌当基本牌使用",
  ["#steam__qingcai_trigger"] = "清才",
  ["givered"] = "分配红色牌",
  ["useblack"] = "使用黑色牌",
  ["#steam__guying-choice"] = "顾影：请选择一项",
  ["#steam__guying-give"] = "请分配一张红色牌",
  ["#steam__guying-use"] = "请使用一张黑色牌",

  ["~steam__luyun"] = "临渊解梦，何如直挂云帆？",

  ["steam2__luyun"] = "陆云",
  ["#steam2__luyun"] = "弘静之重岩",
  ["cv:steam2__luyun"] = "暂无",
  ["illustrator:steam2__luyun"] = "帛小曳",
  ["designer:steam2__luyun"] = "黛穹&一曲醉流觞",

  ["steam__miaotan"] = "妙谈",
  [":steam__miaotan"] = "出牌阶段每名角色限一次，你可以与一名角色拼点，若你赢，你视为对其使用一张普通锦囊牌；若你没赢，你获得这两张拼点牌，然后结束当前回合。",
  ["steam__mingli"] = "明吏",
  [":steam__mingli"] = "当你的拼点牌亮出后，若两张拼点牌：颜色不同，你可以重置“妙谈”次数；类别不同，你可以令你的拼点牌点数+2或-2。",

  ["#steam__miaotan"] = "妙谈：与一名角色拼点。",
  ["steam__miaotan_active"] = "妙谈",
  ["#steam__miaotan-invoke"] = "妙谈：对 %dest 使用一张普通锦囊牌！",
  ["#steam__mingli-reward"] = "明吏：请选择拼点牌点数的修改值！",
} 
return extension
