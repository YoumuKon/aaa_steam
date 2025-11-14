local extension = Package("aaa_steam_zhengming")
extension.extensionName = "aaa_steam"

local U = require "packages.utility.utility"
local RUtil = require "packages.aaa_fenghou.utility.rfenghou_util"
local DIY = require "packages.diy_utility.diy_utility"

Fk:loadTranslationTable{
  ["aaa_steam_zhengming"] = "争鸣",
}

local zichan = General:new(extension, "steam__zichan", "zheng", 3)

Fk:loadTranslationTable{
  ["steam__zichan"] = "子产",
  ["#steam__zichan"] = "古之遗爱",
  ["designer:steam__zichan"] = "庾兰成",
  ["illustrator:steam__zichan"] = "率土之滨",
}

local junzheng = fk.CreateActiveSkill{
  name = "steam__junzheng",
  anim_type = "control",
  card_num = 1,
  target_num = 0,
  prompt = "#steam__junzheng",
  card_filter = function(self, to_select, selected)
    return #selected == 0
  end,
  can_use = function(self, player)
    return not player:isNude()
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    if #effect.cards > 0 then
      room:moveCards({
        from = player.id,
        ids = effect.cards,
        toArea = Card.DrawPile,
        moveReason = fk.ReasonPut,
        skillName = self.name,
        proposer = player.id,
        drawPilePosition = -1,
      })
    end
    if player.dead then return end
    local ids = table.filter(player:getCardIds("h"), function (id)
      local c = Fk:getCardById(id)
      return #c:getAvailableTargets(player) == 0
    end)
    if #ids == 0 then
      local x = player:getHandcardNum() - player:getMaxCards()
      if x > 0 then
        room:askForDiscard(player, x, x, false, self.name, false)
      elseif x < 0 then
        player:drawCards(-x, self.name)
      end
      player:endPlayPhase()
    else
      local cids = room:askForCard(player, 1, #ids, false, self.name, true, tostring(Exppattern{ id = ids }), "#steam__junzheng-recast")
      if #cids > 0 then
        room:recastCard(cids, player, self.name)
      end
    end
  end,
}
zichan:addSkill(junzheng)

Fk:loadTranslationTable{
  ["steam__junzheng"] = "浚政",
  [":steam__junzheng"] = "出牌阶段，你可以置底一张牌，然后重铸任意张无法使用的手牌。若无牌可重铸，你调整手牌至上限并结束出牌阶段。",
  ["#steam__junzheng"] = "浚政：置底一张牌，重铸任意张无法使用的手牌",
  ["#steam__junzheng-recast"] = "浚政：重铸任意张无法使用的手牌",
}

local jiji = fk.CreateTriggerSkill{
  name = "steam__jiji",
  anim_type = "switch",
  switch_skill_name = "steam__jiji",
  events = {fk.DamageCaused, fk.PreHpRecover},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) and target and target ~= player and
    not table.contains(player:getTableMark("steam__jiji-round"), target.id) then
      if event == fk.DamageCaused then
        return player:getSwitchSkillState(self.name) == fk.SwitchYang
      elseif event == fk.PreHpRecover then
        return player:getSwitchSkillState(self.name) == fk.SwitchYin
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    local prompt = (event == fk.DamageCaused) and ("#steam__jiji-damage:"..target.id..":"..data.to.id)
    or ("#steam__jiji-recover:"..target.id)
    if player.room:askForSkillInvoke(player, self.name, nil, prompt) then
      self.cost_data = {tos = {target.id}}
      return true
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    room:addTableMark(player, "steam__jiji-round", target.id)
    if not target:isNude() then
      local cards = room:askForCard(target, 1, 1, true, self.name, false, nil, "#steam__jiji-give:"..player.id)
      room:obtainCard(player, cards, true, fk.ReasonGive, target.id, self.name)
    end
    if not target.dead then
      junzheng:onUse(room, {from = target.id, tos = {}, cards = {}})
    end
    return true
  end,
}
zichan:addSkill(jiji)

Fk:loadTranslationTable{
  ["steam__jiji"] = "既济",
  [":steam__jiji"] = "转换技，每轮每名角色限一次，一名其他角色①造成伤害时；②回复体力时，你可以取消之，并令其执行一次将置底改为交给你的“浚政”。",
  ["#steam__jiji-damage"] = "既济：你可以防止 %src 对 %dest 造成的伤害，令其执行“浚政”",
  ["#steam__jiji-recover"] = "既济：你可以防止 %src 回复体力，令其执行“浚政”",
  ["#steam__jiji-give"] = "既济：将一张牌交给 %src",
}

local jishou = General:new(extension, "steam__jishou", "vei", 3)
Fk:loadTranslationTable{
  ["steam__jishou"] = "姬寿",
  ["#steam__jishou"] = "同舟邀樽",
  ["designer:steam__jishou"] = "静谦",
  ["cv:steam__jishou"] = "静谦",
  ["illustrator:steam__jishou"] = "？",
  ["~steam__jishou"] = "乘舟去矣…兄长安在…",
}

local yougong = fk.CreateTriggerSkill{
  name = "steam__yougong",
  anim_type = "drawcard",
  events = {fk.CardUsing},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) and target == player and player:usedSkillTimes(self.name) == 0 then
      return not player:isKongcheng()
    end
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    player:filterHandcards()
    local fit = {}
    for _, id in ipairs(player.player_cards[Player.Hand]) do
      local n = 0
      local c = Fk:getCardById(id)
      if c.suit == data.card.suit then
        n = n + 1
      end
      if c.number == data.card.number then
        n = n + 1
      end
      if c.trueName == data.card.trueName then
        n = n + 1
      end
      if n > 0 then
        table.insert(fit, id)
        room:setCardMark(c, "@steam__yougong", n)
      end
    end
    local cards = room:askForCard(player, 1, 1, false, self.name, true, nil, "#steam__yougong-card:::"..data.card:toLogString())
    for _, id in ipairs(fit) do
      room:setCardMark(Fk:getCardById(id), "@steam__yougong", 0)
    end
    if #cards > 0 then
      self.cost_data = {cards = cards}
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cards = self.cost_data.cards
    local c = Fk:getCardById(cards[1])
    player:showCards(cards)
    local n = 0
    if c.suit == data.card.suit then
      n = n + 1
    end
    if c.number == data.card.number then
      n = n + 1
    end
    if c.trueName == data.card.trueName then
      n = n + 1
    end
    if n > 0 then
      player:drawCards(n, self.name)
    end
  end,
}
jishou:addSkill(yougong)

Fk:loadTranslationTable{
  ["steam__yougong"] = "友恭",
  [":steam__yougong"] = "每回合限一次，当你使用牌时，你可以展示一张手牌，二者的牌名、花色、点数每有一项相同，你摸一张牌。",
  ["#steam__yougong-card"] = "友恭：你可以展示一张手牌，牌名、花色、点数每有一项与%arg相同，你摸一张牌",
  ["@steam__yougong"] = "摸",
  ["$steam__yougong1"] = "常棣之华，鄂不韡韡！",
  ["$steam__yougong2"] = "白羽为契，肝胆同昭！",
}

local qufu = fk.CreateTriggerSkill{
  name = "steam__qufu",
  frequency = Skill.Compulsory,
  anim_type = "offensive",
  events = {fk.TargetSpecified},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) and player.hp == player:getHandcardNum() and (data.card.type == Card.TypeBasic or data.card:isCommonTrick()) then
      local to = player.room:getPlayerById(data.to)
      if AimGroup:isOnlyTarget(to, data) then
        return player == target or to == player
      end
    end
  end,
  on_use = function (self, event, target, player, data)
    data.additionalEffect = 1
  end,
}
jishou:addSkill(qufu)

Fk:loadTranslationTable{
  ["steam__qufu"] = "趋赴",
  [":steam__qufu"] = "锁定技，当一张基本牌或普通锦囊牌指定唯一目标后，若你是此牌的使用者或目标角色且你手牌数等于体力值，此牌结算两次。",
  ["$steam__qufu1"] = "兄长且驻！此刃当赴我身！",
  ["$steam__qufu2"] = "素衣九袭，不掩丹忱！",
}


local jiwusheng = General:new(extension, "steam__jiwusheng", "zheng", 4)
Fk:loadTranslationTable{
  ["steam__jiwusheng"] = "姬寤生",
  ["#steam__jiwusheng"] = "郑庄公",
  ["designer:steam__jiwusheng"] = "喜多芝士",
  ["illustrator:steam__jiwusheng"] = "率土之滨",
}

local miguo = fk.CreateActiveSkill{
  name = "steam__miguo",
  anim_type = "offensive",
  card_num = function (self)
    if RUtil.getSwitchState(Self, self.name) < 3 then
      return 1
    end
    return 0
  end,
  target_num = 0,
  prompt = function (self)
    if RUtil.getSwitchState(Self, self.name) < 3 then
      return "#steam__miguo-xumou"
    end
    return "#steam__miguo-pofu"
  end,
  card_filter = function(self, to_select, selected, player)
    return #selected == 0 and RUtil.getSwitchState(player, self.name) < 3
  end,
  can_use = function(self, player)
    if RUtil.getSwitchState(player, self.name) < 3 then return true end
    return #table.filter({"h", "e", "j"}, function (flag)
      return #player:getCardIds(flag) > 0
    end) > 1
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    if #effect.cards > 0 then
      RUtil.premeditate(player, effect.cards[1], self.name, player.id)
    else
      local choices = {}
      local all = {}
      if #player:getCardIds("h") > 0 then table.insert(all, "$Hand") end
      if #player:getCardIds("e") > 0 then table.insert(all, "$Equip") end
      if #player:getCardIds("j") > 0 then table.insert(all, "$Judge") end
      if #all < 1 then return end
      if #all == 2 then
        choices = all
      else
        choices = room:askForChoices(player, all, 2, 2, self.name, "#steam__jiwusheng-pofuchoice", false)
      end
      local map = {["$Hand"] = "h", ["$Equip"] = "e", ["$Judge"] = "j"}
      local throw = {}
      for _, ch in ipairs(choices) do
        local area = map[ch]
        table.insertTable(throw, player:getCardIds(area))
      end
      room:throwCard(throw, self.name, player, player)
      for _, id in ipairs(throw) do
        if player.dead then return end
        if room:getCardArea(id) == Card.DiscardPile then
          local targets = table.filter(room.alive_players, function (p)
            return player:canPindian(p, true)
          end)
          if #targets == 0 then break end
          local card = Fk:getCardById(id)
          local tos = room:askForChoosePlayers(player, table.map(targets, Util.IdMapper), 1, 1,
          "#steam__miguo-pindian:::"..card:toLogString()..":"..choices[1]..":"..choices[2], self.name, false)
          local to = room:getPlayerById(tos[1])
          -- 用于显示当前进行结算的拼点牌
          room:setPlayerMark(player, "@steam__miguo", Fk:translate(card:toLogString()))
          local pindian = player:pindian({to}, self.name, card)
          if player.dead then return end
          room:setPlayerMark(player, "@steam__miguo", 0)
          if pindian and pindian.results and pindian.results[to.id] and pindian.results[to.id].winner == player then
            local top = room:getNCards(1)[1]
            local topcard = Fk:getCardById(top)
            local toAreaChoices = {}
            if table.contains(choices, "$Hand") then table.insert(toAreaChoices, "$Hand") end
            if table.contains(choices, "$Equip") and topcard.type == Card.TypeEquip and player:canMoveCardIntoEquip(top, false) then
              table.insert(toAreaChoices, "$Equip")
            end
            if table.contains(choices, "$Judge") and topcard.sub_type == Card.SubtypeDelayedTrick
            and not table.contains(player.sealedSlots, Player.JudgeSlot) and not player:hasDelayedTrick(topcard.name) then
              table.insert(toAreaChoices, "$Judge")
            end
            if #toAreaChoices > 0 then
              local area = room:askForChoice(player, toAreaChoices, self.name, "#steam__miguo-toArea:::"..topcard:toLogString())
              if area == "$Hand" then
                room:obtainCard(player, top, false, fk.ReasonPrey, player.id, self.name)
              elseif area == "$Equip" then
                room:moveCardIntoEquip(player, top, self.name, false, player.id)
              else
                room:moveCardTo(top, Card.PlayerJudge, player.id, fk.ReasonPut, self.name, nil, true, player.id)
              end
            end
          end
        end
      end
    end
    RUtil.changeSwitchState(player, self.name)
  end,

  on_acquire = function (self, player, is_start)
    RUtil.setSwitchState(player, self.name, 1, 3)
  end,
  on_lose = function (self, player, is_death)
    RUtil.removeSwitchSkill(player, self.name)
  end,
}
jiwusheng:addSkill(miguo)

Fk:loadTranslationTable{
  ["steam__miguo"] = "弭国",
  [":steam__miguo"] = "转换技，出牌阶段，你可①蓄谋；②蓄谋；③破釜2，然后以弃置牌依次拼点，若你赢，则将牌堆顶一张牌合法置入弃置牌区域内。",
  ["#steam__miguo-xumou"] = "弭国：你可以蓄谋一张牌",
  ["#steam__miguo-pofu"] = "弭国：你可以破釜2，然后以弃置牌依次拼点",
  ["#steam__miguo-pindian"] = "弭国：你须用%arg拼点，若你赢，将牌堆顶牌置入 %arg2 或 %arg3",
  ["@steam__miguo"] = "", -- 用于显示拼点牌
  ["#steam__miguo-toArea"] = "弭国：你将获得%arg，选择此牌置入的区域！",
  ["#steam__jiwusheng-pofuchoice"] = "弭国：选择你两个区域，弃置其中所有牌！",
}

local xiaowei = fk.CreateTriggerSkill{
  name = "steam__xiaowei",
  events = {fk.CardUsing},
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and target == player and data.card.is_damage_card and data.tos
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local tos = TargetGroup:getRealTargets(data.tos)
    if room:askForSkillInvoke(target, self.name, nil, "#steam__xiaowei-invoke:::"..data.card.name) then
      room:sortPlayersByAction(tos)
      self.cost_data = {tos = tos}
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local draw
    for _, pid in ipairs(self.cost_data.tos) do
      local to = room:getPlayerById(pid)
      if not to.dead and not to:isAllNude() then
        local cid = room:askForCardChosen(player, to, "hej", self.name)
        room:throwCard(cid, self.name, to, player)
        if #to:getCardIds("hej") < #player:getCardIds("hej") then
          draw = true
        end
      end
      if player.dead then break end
    end
    if draw and player:isAlive() then
      room:invalidateSkill(player, self.name, "-turn")
      player:drawCards(2, self.name)
    end
    data.tos = {}
  end,
}
jiwusheng:addSkill(xiaowei)

Fk:loadTranslationTable{
  ["steam__xiaowei"] = "虓威",
  [":steam__xiaowei"] = "你使用伤害牌时，可改为弃置目标角色区域内的一张牌，若其区域内的总牌数小于你，你摸两张牌，然后此技能本回合失效。",
  ["#steam__xiaowei-invoke"] = "虓威：你可以将使用的【%arg】改为弃置目标区域内一张牌",
}

local yingrenhao = General:new(extension, "steam__yingrenhao", "qin", 4)
Fk:loadTranslationTable{
  ["steam__yingrenhao"] = "嬴任好",
  ["#steam__yingrenhao"] = "秦穆公",
  ["designer:steam__yingrenhao"] = "寒雾",
  ["cv:steam__yingrenhao"] = "寒雾",
  ["illustrator:steam__yingrenhao"] = "?",
  ["~steam__yingrenhao"] = "我心之忧，日月逾迈，若弗云来…",
}

local hongding = fk.CreateActiveSkill{
  name = "steam__hongding",
  anim_type = "big",
  card_num = 0,
  min_target_num = 1,
  prompt = "#steam__hongding",
  can_use = function(self, player)
    return player:getMark("@@rfenghou_readying:::"..self.name) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, to_select, selected, _, _, _, player)
    local to = Fk:currentRoom():getPlayerById(to_select)
    return to:getHandcardNum() <= player:getHandcardNum()
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    room:sortPlayersByAction(effect.tos)
    local tos = table.map(effect.tos, Util.Id2PlayerMapper)
    for _, to in ipairs(tos) do
      if not to.dead then
        to:drawCards(1, self.name)
      end
    end
    for _, to in ipairs(tos) do
      if player.dead then break end
      if not to.dead then
        local use = U.askForPlayCard(room, to, nil, ".", self.name, "#steam__hongding-use:"..player.id, {bypass_times = true})
        if not use and not to:isNude() and not player.dead then
          local cards = room:askForCard(to, 1, 1, true, self.name, false, nil, "#steam__hongding-give:"..player.id)
          room:obtainCard(player, cards, true, fk.ReasonGive, to.id, self.name)
        end
      end
    end
  end,
}
hongding.RfenghouReadySkill = true

yingrenhao:addSkill(hongding)

Fk:loadTranslationTable{
  ["steam__hongding"] = "鸿鼎",
  [":steam__hongding"] = "蓄势技，出牌阶段，你可令任意名手牌数不大于你的角色摸一张牌，然后这些角色须使用一张牌或交给你一张牌。",
  ["#steam__hongding"] = "鸿鼎：令任意名手牌数不大于你的角色摸一张牌，然后其须用牌或给牌",
  ["@@rfenghou_readying:::steam__hongding"] = "鸿鼎 蓄势中",
  ["#steam__hongding-use"] = "鸿鼎：你须使用一张牌，否则须交给 %src 一张牌",
  ["#steam__hongding-give"] = "鸿鼎：请交给 %src 一张牌",

  ["$steam__hongding1"] = "西戎宾从，东向而霸！",
  ["$steam__hongding2"] = "一统西陲，六合归心！",
}

local xiongzhan = fk.CreateTriggerSkill{
  name = "steam__xiongzhan",
  events = {fk.CardUsing},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and data.card.type == Card.TypeBasic and player == player.room.current
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local top = room:getNCards(3)
    local cards = room:askForCardsChosen(player, player, 0, 3, { card_data = { { "Top", top } } },
    self.name, "#steam__xiongzhan-card:::"..data.card.trueName)
    if #cards == 0 then return end
    room:moveCards({
      ids = cards,
      toArea = Card.DiscardPile,
      moveReason = fk.ReasonDiscard,
      proposer = player.id,
      skillName = self.name
    })
    if table.find(cards, function (id)
      return Fk:getCardById(id).trueName == data.card.trueName
    end) then
      local choice = room:askForChoice(player, {"steam__xiongzhan_nullify", "steam__xiongzhan_plus"},
      self.name, "#steam__xiongzhan-choice:"..data.from.."::"..data.card:toLogString())
      if choice == "steam__xiongzhan_plus" then
        if data.card.is_damage_card then
          data.additionalDamage = (data.additionalDamage or 0) + 1
        elseif data.card.name == "peach" then
          data.additionalRecover = (data.additionalRecover or 0) + 1
        elseif data.card.name == "analeptic" then
          if data.extra_data and data.extra_data.analepticRecover then
            data.additionalRecover = (data.additionalRecover or 0) + 1
          else
            data.extra_data = data.extra_data or {}
            data.extra_data.additionalDrank = (data.extra_data.additionalDrank or 0) + 1
          end
        elseif data.card.name == "drugs" then
          data.extra_data = data.extra_data or {}
          data.extra_data.additionalBuff = (data.extra_data.additionalBuff or 0) + 1
        end
      else
        if data.toCard then
          data.toCard = nil
        elseif data.tos then
          data.tos = {}
        end
      end
    end
  end,
}
yingrenhao:addSkill(xiongzhan)

Fk:loadTranslationTable{
  ["steam__xiongzhan"] = "雄瞻",
  [":steam__xiongzhan"] = "你的回合内，一张基本牌被使用时，你可观看牌顶三张牌并弃置其中任意张，若弃置同名牌，此牌无效或基数+1。",
  ["#steam__xiongzhan-card"] = "弃置其中任意张，若弃置【%arg】则令使用牌无效或基数+1",
  ["#steam__xiongzhan-choice"] = "雄瞻：选择令 %src 使用的 %arg 无效或基数+1？",
  ["steam__xiongzhan_nullify"] = "无效",
  ["steam__xiongzhan_plus"] = "基数+1",
  ["$steam__xiongzhan1"] = "渭水汤汤，泾以渭浊！",
  ["$steam__xiongzhan2"] = "去芜存菁，霸业可期！",
}

local chengdechen = General:new(extension, "steam__chengdechen", "chu", 4)
Fk:loadTranslationTable{
  ["steam__chengdechen"] = "成得臣",
  ["#steam__chengdechen"] = "掌戎沉乾",
  ["designer:steam__chengdechen"] = "慕晴mqi",
  ["illustrator:steam__chengdechen"] = "率土之滨",
}

local woshij = fk.CreateViewAsSkill{
  name = "steam__woshij",
  anim_type = "offensive",
  pattern = "chasing_near",
  prompt = "#steam__woshij",
  card_filter = function(self, to_select, selected)
    if #selected == 0 then
      local desc = Fk:translate(":"..Fk:getCardById(to_select).name, "zh_CN")
      return desc:find("距离") or desc:find("攻击范围")
    end
  end,
  view_as = function(self, cards)
    if #cards ~= 1 then return nil end
    local c = Fk:cloneCard("chasing_near")
    c.skillName = self.name
    c:addSubcard(cards[1])
    return c
  end,
  before_use = function(self, player, use)
    use.extra_data = use.extra_data or {}
    use.extra_data.steam__woshijFrom = player
  end,
  after_use = function (self, player, use)
    if player.dead then return end
    local tos = (use.extra_data or Util.DummyTable).steam__woshijResult
    if tos then
      local room = player.room
      room:sortPlayersByAction(tos)
      for _, pid in ipairs(tos) do
        local to = room:getPlayerById(pid)
        if not to.dead then
          room:doIndicate(player.id, {pid})
          room:damage { from = player, to = to, damage = 1, skillName = self.name }
          if not to.dead then
            DIY.removePlayer(to, "-turn")
          end
        end
      end
    end
  end,
  enabled_at_play = function(self, player)
    return not player:isNude()
  end,
  enabled_at_response = Util.FalseFunc,
}
local woshij_trigger = fk.CreateTriggerSkill{
  name = "#steam__woshij_trigger",

  refresh_events = {fk.CardEffectFinished},
  can_refresh = function(self, event, target, player, data)
    return not player.dead and data.to == player.id and
    data.card.name == "chasing_near" and table.contains(data.card.skillNames, woshij.name)
  end,
  on_refresh = function(self, event, target, player, data)
    local useParent = player.room.logic:getCurrentEvent():findParent(GameEvent.UseCard)
    if useParent then
      local use = useParent.data[1]
      if not use.extra_data then return end
      local from = use.extra_data.steam__woshijFrom
      if not (from and from:isAlive() and from:getHandcardNum() == player:getHandcardNum()) then return end
      use.extra_data.steam__woshijResult = use.extra_data.steam__woshijResult or {}
      table.insertIfNeed(use.extra_data.steam__woshijResult, player.id)
    end
  end,
}

woshij:addRelatedSkill(woshij_trigger)
chengdechen:addSkill(woshij)

Fk:loadTranslationTable{
  -- 注意重名：我视
  ["steam__woshij"] = "握势",
  [":steam__woshij"] = "出牌阶段，你可将一张有关距离或攻击范围的牌当【逐近弃远】使用；若目标角色的手牌数因此变为与你相同，你对其造成1点伤害，然后调离其至回合结束。",
  ["#steam__woshij"] = "握势：将有关距离或攻击范围的牌当【逐近弃远】使用，若使目标手牌数因此与你相同，对其造成伤害并调离",
}


local baosi = General:new(extension, "steam__baosi", "zhou", 3, 3, General.Female)
Fk:loadTranslationTable{
  ["steam__baosi"] = "褒姒",
  ["#steam__baosi"] = "烽影抿嫣",
  ["designer:steam__baosi"] = "寒雾&慕晴mqi",
  ["illustrator:steam__baosi"] = "率土之滨",
}

local hanzhi = fk.CreateTriggerSkill{
  name = "steam__hanzhi",
  events = {fk.EventPhaseStart},
  anim_type = "control",
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) and target == player then
      return player.phase == Player.Start
    end
  end,
  on_cost = function (self, event, target, player, data)
    local _, dat = player.room:askForUseActiveSkill(player, "#steam__hanzhi_active", "#steam__hanzhi-choose", true)
    if dat then
      self.cost_data = {tos = dat.targets, choice = dat.interaction}
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local tar = room:getPlayerById(self.cost_data.tos[1])
    local from = self.cost_data.choice == "steam__hanzhi_me" and player or tar
    local to = from == player and tar or player
    room:useVirtualCard("artful_graft", nil, from, to, self.name)
    if from:isAlive() and to:isAlive() then
      room:addTableMark(from, "@[player]steam__hanzhi", to.id)
    end
  end,
}

local hanzhi_delay = fk.CreateTriggerSkill{
  name = "#steam__hanzhi_delay",
  mute = true,
  events = {fk.DamageInflicted},
  can_trigger = function (self, event, target, player, data)
    return table.contains(player:getTableMark("@[player]steam__hanzhi"), target.id)
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke(hanzhi.name)
    room:notifySkillInvoked(player, hanzhi.name, "negative")
    room:removeTableMark(player, "@[player]steam__hanzhi", target.id)
    room:doIndicate(target.id, {player.id})
    room:damage{
      from = data.from,
      to = player,
      damage = data.damage,
      damageType = data.damageType,
      skillName = data.skillName,
      chain = data.chain,
      card = data.card,
    }
    return true
  end,
}
hanzhi:addRelatedSkill(hanzhi_delay)

local hanzhi_active = fk.CreateActiveSkill{
  name = "#steam__hanzhi_active",
  card_num = 0,
  target_num = 1,
  card_filter = Util.FalseFunc,
  interaction = function(self, player)
    return UI.ComboBox { choices = {"steam__hanzhi_me", "steam__hanzhi_you"} }
  end,
  target_filter = function(self, to_select, selected, _, _, _, player)
    local to = Fk:currentRoom():getPlayerById(to_select)
    if #selected == 0 and player.id ~= to_select then
      local card = Fk:cloneCard("artful_graft")
      card.skillName = self.name
      if self.interaction.data == "steam__hanzhi_me" then
        return player:canUseTo(card, to)
      elseif self.interaction.data == "steam__hanzhi_you" then
        return to:canUseTo(card, player)
      end
    end
  end,
}
Fk:addSkill(hanzhi_active)
baosi:addSkill(hanzhi)

Fk:loadTranslationTable{
  ["steam__hanzhi"] = "含胭",
  [":steam__hanzhi"] = "准备阶段，你可以选择一名其他角色，视为你对其/其对你使用一张【移花接木】，然后你/其下次代替对方受到伤害。",
  ["#steam__hanzhi_active"] = "含胭",
  ["#steam__hanzhi-choose"] = "含胭：选择一名其他角色，选择你对其，或其对你使用【移花接木】，使用者代替对方受到下次伤害",
  ["steam__hanzhi_me"] = "你对其使用",
  ["steam__hanzhi_you"] = "令其对你使用",
  ["@[player]steam__hanzhi"] = "含胭",
}

local piaoxu = fk.CreateTriggerSkill{
  name = "steam__piaoxu",
  events = {fk.EnterDying},
  frequency = Skill.Limited,
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) and target == player then
      return player:usedSkillTimes(self.name, Player.HistoryGame) == 0
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:doIndicate(player.id, table.map(room.alive_players, Util.IdMapper))
    for _, p in ipairs(room:getAlivePlayers()) do
      if p:isAlive() then
        local cards = room:askForDiscard(p, 2, 2, true, self.name, true, nil, "#steam__piaoxu-discard")
        if #cards == 0 then
          cards = room:getNCards(2)
          room:moveCards({
            ids = cards,
            toArea = Card.DiscardPile,
            moveReason = fk.ReasonDiscard,
            skillName = self.name,
            proposer = p.id,
          })
        end
        if player:isAlive() then
          cards = table.filter(cards, function (id)
            return Fk:getCardById(id).suit == Card.Heart and room:getCardArea(id) == Card.DiscardPile
          end)
          if #cards > 0 then
            room:delay(300)
            room:obtainCard(player, cards, true, fk.ReasonJustMove, player.id, self.name)
          end
        end
      end
    end
  end,
}
baosi:addSkill(piaoxu)

Fk:loadTranslationTable{
  ["steam__piaoxu"] = "飘絮",
  [":steam__piaoxu"] = "限定技，你进入濒死时，可令所有角色弃置自己或牌顶两张牌，你获得弃置的<font color='red'>♥</font>牌。",
  ["#steam__piaoxu-discard"] = "飘絮：你可以弃置2张牌，若取消则弃置牌堆顶2张牌",
  ["$steam__piaoxu1"] = "",
  ["$steam__piaoxu2"] = "",
}

local zizifu = General:new(extension, "steam__zizifu", "song", 4)
Fk:loadTranslationTable{
  ["steam__zizifu"] = "子兹甫",
  ["#steam__zizifu"] = "宋襄公",
  ["designer:steam__zizifu"] = "JIanan",
  ["illustrator:steam__zizifu"] = "率土之滨",
}

local renshi = fk.CreateTriggerSkill{
  name = "steam__renshi",
  anim_type = "offensive",
  events = {fk.EventPhaseStart, fk.TurnEnd},
  times = function () -- 用于显示回合结束时是否能否发动
    local mark = Self:getMark("steam__renshi-turn")
    if mark == 0 then
      return -1
    end
    return mark
  end,
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) and target == player then
      --[[
      local max = 0
      for _, p in ipairs(player.room.alive_players) do
        max = math.max(max, p:getHandcardNum())
      end
      if player:getHandcardNum() == max then return false end
      --]]
      if event == fk.EventPhaseStart then
        return player.phase == Player.Start
      else
        return player:getMark("steam__renshi-turn") ~= 0
      end
    end
  end,
  on_cost = function (self, event, target, player, data)
    local use = U.askForUseVirtualCard(player.room, player, "slash", nil, self.name, "#steam__renshi-slash", true, true, true, true, nil, true)
    if use then
      self.cost_data = use
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local max = 0
    for _, p in ipairs(room.alive_players) do
      max = math.max(max, p:getHandcardNum())
    end
    player:drawCards(math.max(1, max - player:getHandcardNum()))
    room:useCard(self.cost_data)
  end,
}
local renshi_delay = fk.CreateTriggerSkill{
  name = "#steam__renshi_delay",
  mute = true,
  events = {fk.PreCardEffect},
  can_trigger = function(self, event, target, player, data)
    if not player.dead and player.id == data.to and table.contains(data.card.skillNames, renshi.name) then
      local tos = TargetGroup:getRealTargets(data.tos)
      return table.contains(tos, player.id) and not table.find(tos, function (id) return id ~= player.id end)
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cards = player:getCardIds("h")
    if #cards > 0 then
      player:showCards(cards)
      if table.find(cards, function (id) return Fk:getCardById(id).name == "jink" end) then
        return
      end
      room:delay(600)
    end
    local ids = {}
    while not player.dead do
      local top = room:getNCards(1)[1]
      table.insertIfNeed(ids, top)
      room:moveCardTo(top, Card.Processing, nil, fk.ReasonPut, renshi.name, nil, true, player.id)
      room:delay(120)
      if Fk:getCardById(top).name == "jink" then
        room:setCardEmotion(top, "Judgegood")
        room:useCard{from = player.id, card = Fk:getCardById(top), toCard = data.card, responseToEvent = data}
        break
      end
    end
    local from = room:getPlayerById(data.from)
    if from and #ids > from:getHandcardNum() then
      room:setPlayerMark(from, "steam__renshi-turn", 1)
    end
    room:cleanProcessingArea(ids)
    return data.isCancellOut
  end,
}
renshi:addRelatedSkill(renshi_delay)
zizifu:addSkill(renshi)

Fk:loadTranslationTable{
  ["steam__renshi"] = "仁师",
  [":steam__renshi"] = "准备阶段，你可以将手牌摸至唯一最多并视为使用【杀】，然后展示唯一目标所有手牌，若其无牌可响应，你令其检索一张【闪】以响应之。若检索牌数大于你的手牌数，则你可于本回合结束时发动此技能。",
  ["#steam__renshi-slash"] = "仁师：你可以将手牌摸至唯一最多，视为使用【杀】（请选择杀的目标！）",
  ["#steam__renshi_delay"] = "仁师",
}

local guanzhong = General:new(extension, "steam__guanzhong", "qi", 3)
Fk:loadTranslationTable{
  ["steam__guanzhong"] = "管仲",
  ["#steam__guanzhong"] = "长矢锵玉",
  ["designer:steam__guanzhong"] = "争鸣工作室",
  ["illustrator:steam__guanzhong"] = "率土之滨",
}

local yuantuForesightSkill = fk.CreateActiveSkill{
  name = "steam_yuantu__foresight_skill",
  mod_target_filter = Util.TrueFunc,
  can_use = Util.SelfCanUse,
  on_use = function(self, room, cardUseEvent)
    if not cardUseEvent.tos or #TargetGroup:getRealTargets(cardUseEvent.tos) == 0 then
      cardUseEvent.tos = {{cardUseEvent.from}}
    end
  end,
  on_effect = function(self, room, effect)
    local player = room:getPlayerById(effect.to)
    local cards = U.turnOverCardsFromDrawPile(player, 2, self.name, false)
    local from = room:getPlayerById((effect.extra_data or {}).steam__yuantuFrom)
    if from and not player:isNude() then
      local excards = room:askForCard(from, 1, 999, true, self.name, true, nil, "#steam__yuantu-busuan")
      if #excards > 0 then
        table.insertTable(cards, excards)
        room:moveCardTo(excards, Card.Processing, nil, fk.ReasonJustMove, self.name, nil, false, from.id, nil, player.id)
      end
    end
    local moves = {}
    local result = room:askForGuanxing(player, cards, nil, nil, self.name, true)
    if #result.top > 0 then
      table.insert(moves, {
        ids = table.reverse(result.top),
        toArea = Card.DrawPile,
        moveReason = fk.ReasonPut,
        skillName = self.name,
        proposer = player.id,
        moveVisible = false,
        visiblePlayers = {player.id},
      })
    end
    if #result.bottom > 0 then
      table.insert(moves, {
        ids = result.bottom,
        toArea = Card.DrawPile,
        moveReason = fk.ReasonPut,
        skillName = self.name,
        proposer = player.id,
        moveVisible = false,
        visiblePlayers = {player.id},
        drawPilePosition = -1,
      })
    end
    room:moveCards(table.unpack(moves))
    room:drawCards(player, 2, self.name)
  end
}
yuantuForesightSkill.cardSkill = true
Fk:addSkill(yuantuForesightSkill)

local yuantu = fk.CreateTriggerSkill{
  name = "steam__yuantu",
  anim_type = "control",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and target.phase == Player.Draw
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local handcard = player:getHandcardNum()
    local card = Fk:cloneCard("foresight")
    card.skillName = self.name
    local use = {from = player.id, card = card, tos = {{player.id}}}
    room:useCard(use)
    if not player.dead and player:getHandcardNum() > handcard then
      room:invalidateSkill(player, self.name, "-round")
    end
  end,

  refresh_events = {fk.PreCardUse},
  can_refresh = function (self, event, target, player, data)
    return target == player and table.contains(data.card.skillNames, self.name)
  end,
  on_refresh = function (self, event, target, player, data)
    data.card.skill = yuantuForesightSkill
    data.extra_data = data.extra_data or {}
    data.extra_data.steam__yuantuFrom = player.id
  end,
}
guanzhong:addSkill(yuantu)

Fk:loadTranslationTable{
  ["steam__yuantu"] = "渊图",
  [":steam__yuantu"] = "一名角色摸牌阶段开始时，你可视为使用【洞烛先机】，且你可将任意张牌并入卜算牌。若你因此手牌数大于使用前，此技能本轮失效。",
  ["steam_yuantu__foresight_skill"] = "洞烛先机",
  ["#steam__yuantu-busuan"] = "渊图：你可以将任意张牌加入卜算牌",
}


local kuangjing = fk.CreateTriggerSkill{
  name = "steam__kuangjing",
  anim_type = "support",
  events = {fk.EventPhaseEnd},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and target.phase == Player.Discard
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local discards = {}
    room.logic:getEventsOfScope(GameEvent.MoveCards, 1, function(e)
      for _, move in ipairs(e.data) do
        if move.from == target.id and move.moveReason == fk.ReasonDiscard then
          for _, info in ipairs(move.moveInfo) do
            if info.fromArea == Card.PlayerHand then
              table.insertIfNeed(discards, info.cardId)
            end
          end
        end
      end
      return false
    end, Player.HistoryTurn)
    local discardNames = {}
    for _, id in ipairs(discards) do
      table.insertIfNeed(discardNames, Fk:getCardById(id).name)
    end
    local card = Fk:cloneCard("carry_forward")
    card.skillName = self.name
    local use = {from = player.id, card = card, tos = {{player.id}}}
    room:useCard(use)
    if player.dead then return end
    local ids = (use.extra_data or {}).steam__kuangjingCards or {}
    if table.find(ids, function(id) return table.contains(discardNames, Fk:getCardById(id).trueName) end) then
      discards = table.filter(discards, function(id) return room:getCardArea(id) == Card.DiscardPile end)
      if #discards > 0 and not target.dead then
        local get = room:askForCardChosen(target, target, { card_data = { { self.name, discards } } }, self.name, "#steam__kuangjing-prey")
        room:obtainCard(target, get, true, fk.ReasonJustMove, player.id, self.name)
      end
    else
      room:invalidateSkill(player, self.name, "-round")
    end
  end,

  refresh_events = {fk.AfterCardsMove},
  can_refresh = function (self, event, target, player, data)
    return player.seat == 1
  end,
  on_refresh = function (self, event, target, player, data)
    local useEvent = player.room.logic:getCurrentEvent():findParent(GameEvent.UseCard)
    if useEvent then
      local use = useEvent.data[1]
      local ids = {}
      -- 弃置所有手牌
      if use.card.name == "carry_forward" and table.contains(use.card.skillNames, self.name) then
        for _, move in ipairs(data) do
          if move.from == use.from and move.moveReason == fk.ReasonDiscard and move.skillName == "carry_forward_skill" then
            for _, info in ipairs(move.moveInfo) do
              if info.fromArea == Card.PlayerHand then
                table.insert(ids, info.cardId)
              end
            end
          end
        end
        -- 转化所有手牌
      elseif table.contains(use.card.skillNames, "carry_forward_skill") then
        local parentUse = useEvent:findParent(GameEvent.UseCard)
        if not parentUse then return end
        use = parentUse.data[1]
        if not table.contains(use.card.skillNames, self.name) then return end
        for _, move in ipairs(data) do
          if move.from == use.from and move.moveReason == fk.ReasonUse and move.toArea == Card.Processing then
            for _, info in ipairs(move.moveInfo) do
              if info.fromArea == Card.PlayerHand then
                table.insert(ids, info.cardId)
              end
            end
          end
        end
      end
      if #ids > 0 then
        use.extra_data = use.extra_data or {}
        use.extra_data.steam__kuangjingCards = ids
      end
    end
  end,
}
guanzhong:addSkill(kuangjing)

Fk:loadTranslationTable{
  ["steam__kuangjing"] = "匡靖",
  [":steam__kuangjing"] = "一名角色弃牌阶段结束时，你可视为使用【继往开来】；若你失去牌与其弃置牌有同牌名，其收回弃置牌中一张，否则此技能本轮失效。",
  ["#steam__kuangjing-prey"] = "匡靖：收回一张弃置牌",
}

local jiguizhu = General:new(extension, "steam__jiguizhu", "jin", 3)
Fk:loadTranslationTable{
  ["steam__jiguizhu"] = "姬诡诸",
  ["#steam__jiguizhu"] = "晋献公",
  ["designer:steam__jiguizhu"] = "森博十夜",
  ["illustrator:steam__jiguizhu"] = "率土之滨",
}

---@param player ServerPlayer
local doYinxun = function (player, choice)
  local room = player.room
  if player.dead then return end
  local skillName = "steam__yinxun"
  if choice == "steam__yinxun_draw" then
    local num = room:askForChoice(player, {"0", "1", "2"}, skillName, "#steam__yinxun-draw")
    if num ~= "0" then
      player:drawCards(tonumber(num), skillName)
    end
  elseif choice == "steam__yinxun_move" then
    if #room:canMoveCardInBoard() > 0 then
      local tos = room:askForChooseToMoveCardInBoard(player, "steam__yinxun_move", skillName, false)
      room:askForMoveCardInBoard(player, room:getPlayerById(tos[1]), room:getPlayerById(tos[2]), skillName)
    end
  elseif choice == "steam__yinxun_damage" then
    room:damage { from = nil, to = player, damage = 1, skillName = skillName }
  elseif choice == "steam__yinxun_inval" then
    room:setPlayerMark(player, "@@steam__yinxun-turn", 1)
    if not player:hasSkill("qianjie", true, true) then
      room:handleAddLoseSkills(player, "qianjie")
      local turn = room.logic:getCurrentEvent():findParent(GameEvent.Turn,true)
      if turn then
        turn:addCleaner(function()
          room:handleAddLoseSkills(player, "-qianjie")
        end)
      end
    end
  end
end

local yinxun = fk.CreateActiveSkill{
  name = "steam__yinxun",
  anim_type = "offensive",
  card_num = 0,
  target_num = 1,
  prompt = "#steam__yinxun",
  card_filter = Util.FalseFunc,
  target_filter = function(self, to_select, selected, _, _, _, player)
    local to = Fk:currentRoom():getPlayerById(to_select)
    return #selected == 0 and player:canPindian(to)
  end,
  can_use = function(self, player)
    return not player:isKongcheng()
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local to = room:getPlayerById(effect.tos[1])
    local effectMap = {}
    local all_effects = {"steam__yinxun_draw", "steam__yinxun_move", "steam__yinxun_damage", "steam__yinxun_inval"}
    local choices = table.simpleClone(all_effects)
    local chosen = {}
    local players = {player, to}
    local turn = 1
    while #choices > 0 do
      local current = players[turn]
      local choice = room:askForChoice(current, choices, self.name, "#steam__yinxun-choice")
      table.removeOne(choices, choice)
      table.insert(chosen, choice)
      local choice2 = room:askForChoice(current, {"SteamYinxunWin", "SteamYinxunLose"}, self.name, "#steam__yinxun-choice2:::"..choice)
      effectMap[choice] = choice2
      if #choices == 0 then break end
      turn = (turn == 1) and 2 or 1
    end
    local pindian = player:pindian({to}, self.name)
    local winner = pindian.results[to.id].winner
    if not winner then return end
    local loser = (winner == player) and to or player
    for _, eff in ipairs(chosen) do
      local who = (effectMap[eff] == "SteamYinxunWin") and winner or loser
      doYinxun(who, eff)
    end
  end,
}
local yinxun_invalidity = fk.CreateInvaliditySkill {
  name = "#steam__yinxun_invalidity",
  invalidity_func = function(self, from, skill)
    return from:getMark("@@steam__yinxun-turn") ~= 0 and skill:isPlayerSkill(from) and skill.name ~= "qianjie"
  end
}
yinxun:addRelatedSkill(yinxun_invalidity)
jiguizhu:addSkill(yinxun)

Fk:loadTranslationTable{
  ["steam__yinxun"] = "夤询",
  [":steam__yinxun"] = "出牌阶段，你可与一名其他角色依次将下述一项分配至本次输赢效果中，并重复此流程直至均被分配，然后进行拼点：<br>"..
  "①摸至多两张牌。②移动场上一张牌。③受到1点伤害。④本回合所有技能替换为“谦节”。",
  ["#steam__yinxun"] = "夤询：与一名角色拼点，并轮流决定输赢效果",
  ["#steam__yinxun-choice"] = "夤询：请选择一项效果（对双方均生效）",
  ["#steam__yinxun-choice2"] = "夤询：请选择令赢的角色还是输的角色执行效果【%arg】",
  ["SteamYinxunWin"] = "赢者执行",
  ["SteamYinxunLose"] = "输者执行",
  ["@@steam__yinxun-turn"] = "夤询:封技能",
  ["#steam__yinxun-draw"] = "选择你的摸牌数",
  ["steam__yinxun_draw"] = "摸至多两张牌",
  ["steam__yinxun_move"] = "移动场上一张牌",
  ["steam__yinxun_damage"] = "受到1点伤害",
  ["steam__yinxun_inval"] = "技能换为“谦节”",
}

local shibing = fk.CreateTriggerSkill{
  name = "steam__shibing",
  anim_type = "offensive",
  events = {fk.PindianCardsDisplayed},
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(self) then return false end
    return player == data.from or table.contains(data.tos, player)
  end,
  on_cost = function (self, event, target, player, data)
    local tos = player == data.from and data.tos or {data.from}
    tos = table.filter(tos, function(p) return player:canUseTo(Fk:cloneCard("duel"), p) end)
    if #tos == 0 then return false end
    if #tos > 1 then
      tos = player.room:askForChoosePlayers(player, table.map(tos, Util.IdMapper), 1, 1, "#steam__shibing-choose", self.name, true)
      if #tos == 1 then
        self.cost_data = {tos = tos}
        return true
      end
    elseif player.room:askForSkillInvoke(player, self.name, nil, "#steam__shibing-ask:"..tos[1].id) then
      self.cost_data = {tos = {tos[1].id} }
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(self.cost_data.tos[1])
    local card = Fk:cloneCard("duel")
    card.skillName = self.name
    local use = {
      from = player.id,
      tos = {{to.id}},
      card = card,
      extra_data = {steam__shibing_data = data},
    }
    room:useCard(use)
  end,

  refresh_events = {fk.PreDamage},
  can_refresh = function (self, event, target, player, data)
    if data.card and target == player then
      local useEvent = player.room.logic:getCurrentEvent():findParent(GameEvent.UseCard)
      if useEvent then
        local use = useEvent.data[1]
        return use.card == data.card and use.extra_data and use.extra_data.steam__shibing_data
      end
    end
  end,
  on_refresh = function (self, event, target, player, data)
    data.damage = data.damage - 1
    local useEvent = player.room.logic:getCurrentEvent():findParent(GameEvent.UseCard)
    if useEvent then
      local use = useEvent.data[1]
      local pindian = use.extra_data.steam__shibing_data
      if not pindian then return end
      local winner = data.from
      local card
      if winner == pindian.from then
        card = pindian.fromCard
      elseif pindian.results[winner.id] then
        card = pindian.results[winner.id].toCard
      end
      if card then
        card.number = 14
        player.room:sendLog{type = "#SteamShibingLog", from = winner.id, arg = pindian.reason or ""}
      end
    end
  end,
}
jiguizhu:addSkill(shibing)

Fk:loadTranslationTable{
  ["steam__shibing"] = "恃兵",
  [":steam__shibing"] = "你的拼点牌亮出时，可视为对拼点另一方使用伤害-1的【决斗】，赢者的拼点牌视为14点。",
  ["#steam__shibing-ask"] = "恃兵：你可以视为对 %src 使用【决斗】，赢者视为拼点赢",
  ["#steam__shibing-choose"] = "恃兵：你可以视为对一名拼点角色使用【决斗】，赢者视为拼点赢",
  ["#SteamShibingLog"] = "%from 进行 %arg 拼点的拼点牌视为14点！",
}

--[[
local shibing = fk.CreateTriggerSkill{
  name = "steam__shibing",
  anim_type = "offensive",
  times = function (self)
    return 1 - Self:usedSkillTimes(self.name)
  end,
  events = {fk.StartPindian},
  can_trigger = function(self, event, target, player, data)
    if not (player:hasSkill(self) and player:usedSkillTimes(self.name) == 0) then return false end
    return player == data.from or table.contains(data.tos, player)
  end,
  on_cost = function (self, event, target, player, data)
    local tos = player == data.from and data.tos or {data.from}
    tos = table.filter(tos, function(p) return player:canUseTo(Fk:cloneCard("duel"), p) end)
    if #tos == 0 then return false end
    if #tos > 1 then
      tos = player.room:askForChoosePlayers(player, table.map(tos, Util.IdMapper), 1, 1, "#steam__shibing-choose", self.name, true)
      if #tos == 1 then
        self.cost_data = {tos = tos}
        return true
      end
    elseif player.room:askForSkillInvoke(player, self.name, nil, "#steam__shibing-ask:"..tos[1].id) then
      self.cost_data = {tos = {tos[1].id} }
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(self.cost_data.tos[1])
    local use = room:useVirtualCard("duel", nil, player, to, self.name)
    local winner, loser
    if use and use.damageDealt then
      if use.damageDealt[to.id] then
        winner = player
      elseif use.damageDealt[player.id] then
        winner = to
      end
    end
    if winner then
      loser = (winner == player) and to or player
      data.extra_data = data.extra_data or {}
      data.extra_data.steam__shibing_winner = winner.id
      data.extra_data.steam__shibing_loser = loser.id
      -- 打印两张牌作为拼点牌，防止调用空值报错
      local bigCard, smallCard
      local tag = room:getTag(self.name)
      if tag == nil then
        bigCard = room:printCard("slash", Card.Spade, 13)
        smallCard = room:printCard("jink", Card.Heart, 1)
        room:setTag(self.name, {bigCard.id, smallCard.id})
      else
        bigCard = Fk:getCardById(tag[1])
        smallCard = Fk:getCardById(tag[2])
      end
      room:setCardMark(bigCard, MarkEnum.DestructIntoDiscard, 1)
      room:setCardMark(smallCard, MarkEnum.DestructIntoDiscard, 1)
      data.results = data.results or {}
      if data.from == winner then
        data.fromCard = bigCard
        data.results[loser.id] = data.results[loser.id] or {}
        data.results[loser.id].toCard = smallCard
      else
        data.fromCard = smallCard
        data.results[winner.id] = data.results[winner.id] or {}
        data.results[winner.id].toCard = bigCard
      end
    end
    -- 任何一个拼点角色没有手牌，都强制结束拼点流程……
    if (data.from:isKongcheng() and not data.fromCard) or table.find(data.tos, function(p)
      return p:isKongcheng() and not (data.results and data.results[p.id] and data.results[p.id].toCard) end)
    then
      local pindianEvent = room.logic:getCurrentEvent():findParent(GameEvent.Pindian, true)
      if pindianEvent then
        pindianEvent:shutdown()
      end
    end
  end,

  refresh_events = {fk.PindianFinished},
  can_refresh = function (self, event, target, player, data)
    return target == player and data.extra_data and data.extra_data.steam__shibing_winner
    and data.extra_data.steam__shibing_loser
  end,
  on_refresh = function (self, event, target, player, data)
    local winner, loser = data.extra_data.steam__shibing_winner, data.extra_data.steam__shibing_loser
    if winner == data.from then
      if data.results[loser.id] then
        data.results[loser.id].winner = winner
      end
    elseif data.from == loser then
      if data.results[winner.id] then
        data.results[winner.id].winner = winner
      end
    end
  end,
}
jiguizhu:addSkill(shibing)

Fk:loadTranslationTable{
  ["steam__shibing"] = "恃兵",
  [":steam__shibing"] = "每回合限一次，你拼点时，可视为对其使用【决斗】，赢者视为拼点赢",
  ["#steam__shibing-ask"] = "恃兵：你可以视为对 %src 使用【决斗】，赢者视为拼点赢",
  ["#steam__shibing-choose"] = "恃兵：你可以视为对一名拼点角色使用【决斗】，赢者视为拼点赢",
}
--]]



return extension
