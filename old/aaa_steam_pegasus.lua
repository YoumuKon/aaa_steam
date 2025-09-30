local extension = Package("steam_pegasus")
extension.extensionName = "aaa_steam"

Fk:loadTranslationTable{
  ["steam_pegasus"] = "飞骥杯"
}

local U = require "packages/utility/utility"

Fk:addGameEvent("GameEvent.DiscussionPindian", nil, function (self)
  local pindianData = table.unpack(self.data)
  pindianData.color = "nocolor"
  local room = self.room ---@class Room
  local logic = room.logic
  logic:trigger(fk.StartPindian, pindianData.from, pindianData)
  local skillName = pindianData.reason or "pindian"

  if pindianData.reason ~= "" then
    room:sendLog{
      type = "#StartDiscussionReason",
      from = pindianData.from.id,
      arg = skillName,
    }
  end

  local targets = {}
  local moveInfos = {}
  if not pindianData.fromCard then
    table.insert(targets, pindianData.from)
  else
    local _pindianCard = pindianData.fromCard
    local pindianCard = _pindianCard:clone(_pindianCard.suit, _pindianCard.number)
    pindianCard:addSubcard(_pindianCard.id)

    pindianData.fromCard = pindianCard

    table.insert(moveInfos, {
      ids = { _pindianCard.id },
      from = room:getCardOwner(_pindianCard.id).id,
      fromArea = room:getCardArea(_pindianCard.id),
      toArea = Card.Processing,
      moveReason = fk.ReasonPut,
      skillName = pindianData.reason,
      moveVisible = true,
    })
  end

  for _, to in ipairs(pindianData.tos) do
    if pindianData.results[to.id] and pindianData.results[to.id].toCard then
      local _pindianCard = pindianData.results[to.id].toCard
      local pindianCard = _pindianCard:clone(_pindianCard.suit, _pindianCard.number)
      pindianCard:addSubcard(_pindianCard.id)

      pindianData.results[to.id].toCard = pindianCard

      table.insert(moveInfos, {
        ids = { _pindianCard.id },
        from = room:getCardOwner(_pindianCard.id).id,
        fromArea = room:getCardArea(_pindianCard.id),
        toArea = Card.Processing,
        moveReason = fk.ReasonPut,
        skillName = pindianData.reason,
        moveVisible = true,
      })
    else
      table.insert(targets, to)
    end
  end

  local req = Request:new(targets, "AskForUseActiveSkill")
  req.focus_text = skillName
  local data = {
    "choose_cards_skill",
    "#askForDiscussion",
    false,
    {
      num = 1,
      min_num = 1,
      include_equip = false,
      skillName = skillName,
      pattern = ".|.|.|hand",
    },
  }

  for _, p in ipairs(targets) do
    req:setData(p, data)
    local cards = table.random(p:getCardIds("h"), 1)
    req:setDefaultReply(p, cards)
  end
  req:ask()
  local ret = {}
  for _, p in ipairs(targets) do
    local result = req:getResult(p)
    local ids = {}
    if result.card then
      ids = result.card.subcards
    else
      ids = result
    end
    local _pindianCard = Fk:getCardById(ids[1])
    local pindianCard = _pindianCard:clone(_pindianCard.suit, _pindianCard.number)
    pindianCard:addSubcard(_pindianCard.id)

    if p == pindianData.from then
      pindianData.fromCard = pindianCard
    else
      pindianData.results[p.id] = pindianData.results[p.id] or {}
      pindianData.results[p.id].toCard = pindianCard
    end

    table.insert(moveInfos, {
      ids = { _pindianCard.id },
      from = p.id,
      toArea = Card.Processing,
      moveReason = fk.ReasonPut,
      skillName = pindianData.reason,
      moveVisible = true,
    })

    room:sendLog{
      type = "#ShowDiscussionPindianCard",
      from = p.id,
      arg = _pindianCard:toLogString(),
    }
  end

  room:moveCards(table.unpack(moveInfos))

  logic:trigger(fk.PindianCardsDisplayed, nil, pindianData)

  pindianData.opinions = {}
  pindianData.fromOpinion = pindianData.fromCard:getColorString()
  pindianData.opinions[pindianData.fromCard:getColorString()] = (pindianData.opinions[pindianData.fromCard:getColorString()] or 0) + 1
  for toId, result in pairs(pindianData.results) do
    result.opinion = result.toCard:getColorString()
    pindianData.opinions[result.toCard:getColorString()] = (pindianData.opinions[result.toCard:getColorString()] or 0) + 1
  end

  local max, result = 0, {}
  for color, count in pairs(pindianData.opinions) do
    if color ~= "nocolor" and color ~= "noresult" and count > max then
      max = count
    end
  end
  for color, count in pairs(pindianData.opinions) do
    if color ~= "nocolor" and color ~= "noresult" and count == max then
      table.insert(result, color)
    end
  end
  if #result == 1 then
    pindianData.color = result[1]
  end

  room:sendLog{
    type = "#ShowDiscussionResult",
    from = pindianData.from.id,
    arg = pindianData.color,
    toast = true,
  }

  table.removeOne(targets, pindianData.from)
  local pdNum = {}
  pdNum[pindianData.from.id] = pindianData.fromCard.number
  for _, p in ipairs(targets) do
    pdNum[p.id] = pindianData.results[p.id].toCard.number
  end
  local winner, num
  for k, v in pairs(pdNum) do
    if not num or num < v then
      num = v
      winner = k
    elseif num == v then
      winner = nil
    end
  end
  if winner then
    winner = room:getPlayerById(winner) ---@type ServerPlayer
    pindianData.winner = winner
  end

  for toId, result in pairs(pindianData.results) do
    local to = room:getPlayerById(toId)
    result.winner = winner
    local singlePindianData = {
      from = pindianData.from,
      to = to,
      fromCard = pindianData.fromCard,
      toCard = result.toCard,
      winner = winner,
      reason = pindianData.reason,
    }
    logic:trigger(fk.PindianResultConfirmed, nil, singlePindianData)
  end

  if logic:trigger(fk.PindianFinished, pindianData.from, pindianData) then
    logic:breakEvent()
  end
end, function (self)
  local pindianData = table.unpack(self.data)
  local room = self.room

  local toProcessingArea = {}
  local leftFromCardIds = room:getSubcardsByRule(pindianData.fromCard, { Card.Processing })
  if #leftFromCardIds > 0 then
    table.insertTable(toProcessingArea, leftFromCardIds)
  end

  for _, result in pairs(pindianData.results) do
    if result.toCard then
      local leftToCardIds = room:getSubcardsByRule(result.toCard, { Card.Processing })
      if #leftToCardIds > 0 then
        table.insertTable(toProcessingArea, leftToCardIds)
      end
    end
  end

  if #toProcessingArea > 0 then
    room:moveCards({
      ids = toProcessingArea,
      toArea = Card.DiscardPile,
      moveReason = fk.ReasonPutIntoDiscardPile,
    })
  end
  if not self.interrupted then return end
end)

Fk:loadTranslationTable{
  ["#ShowDiscussionPindianCard"] = "%from 的意见牌为 %arg",
}

--- 拿【影】
---@param room Room
---@param n integer
---@return integer[]
local getShade = function (room, n)
  local ids = {}
  for _, id in ipairs(room.void) do
    if n <= 0 then break end
    if Fk:getCardById(id).name == "rfenghou__shade" then
      room:setCardMark(Fk:getCardById(id), MarkEnum.DestructIntoDiscard, 1)
      table.insert(ids, id)
      n = n - 1
    end
  end
  while n > 0 do
    local card = room:printCard("rfenghou__shade", Card.Spade, 1)
    room:setCardMark(card, MarkEnum.DestructIntoDiscard, 1)
    table.insert(ids, card.id)
    n = n - 1
  end
  return ids
end

local simashi = General(extension, "steam_pegasus__simashi", "jin", 4)

local dangyi = fk.CreateActiveSkill{
  name = "steam_pegasus__dangyi",
  anim_type = "control",
  can_use = function (self, player, card, extra_data)
    return not player:isKongcheng() and player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  card_num = 0,
  target_num = 0,
  card_filter = Util.FalseFunc,
  target_filter = Util.FalseFunc,
  on_use = function (self, room, effect)
    local player = room:getPlayerById(effect.from)
    local targets = table.filter(room:getOtherPlayers(player), function (p)
      return player:canPindian(p)
    end)
    local pindianData = { from = player, tos = targets, reason = self.name, fromCard = nil, results = {}, winner = nil }
    local event = GameEvent["GameEvent.DiscussionPindian"]:create(pindianData)
    local _, ret = event:exec()

    local winner = pindianData.winner or player
    local pindianCards = {}
    table.insertTableIfNeed(pindianCards, room:getSubcardsByRule(pindianData.fromCard))
    for _, p in ipairs(targets) do
      local result = pindianData.results[p.id]
      if result.toCard then
        table.insertTableIfNeed(pindianCards, room:getSubcardsByRule(result.toCard))
      end
    end
    if #pindianCards > 0 then
      local cards = room:askForCardsChosen(winner, winner, 0, 999, { card_data = {{"Pindian", pindianCards},} }, self.name, "#steam_pegasus__dangyi-put")
      if #cards > 0 then
        room:moveCards{
          ids = cards,
          toArea = Card.DrawPile,
          moveReason = fk.ReasonPut,
          skillName = self.name,
          proposer = player.id,
        }
      end
    end
    if pindianData.color == "nocolor" or player.dead then return end
    local card
    if pindianData.color == "red" then
      card = Fk:cloneCard("amazing_grace")
      card.skillName = self.name
      targets = table.filter(targets, function (p)
        return player:canUseTo(card, p) and (pindianData.results[p.id].opinion == pindianData.fromOpinion)
      end)
      table.insert(targets, player)
    else
      card = Fk:cloneCard("hanqing__enemy_at_the_gates")
      card.skillName = self.name
      targets = table.filter(targets, function (p)
        return player:canUseTo(card, p) and (pindianData.results[p.id].opinion ~= pindianData.fromOpinion)
      end)
    end
    if #targets == 0 then return end
    room:useCard{
      card = card,
      from = player.id,
      tos = table.map(targets, function (p) return {p.id} end),
    }
  end
}
simashi:addSkill(dangyi)

local fushi = fk.CreateTriggerSkill{
  name = "steam_pegasus__fushi",
  anim_type = "control",
  events = {fk.PindianCardsDisplayed},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) and not player:isKongcheng() then
      return player:usedSkillTimes(self.name, Player.HistoryTurn) == 0
    end
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local card = room:askForDiscard(player, 1, 1, true, self.name, true, ".", "#steam_pegasus__fushi-discard", true)
    if #card == 1 then
      self.cost_data = card[1]
      return true
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    room:throwCard(self.cost_data, self.name, player, player)
    local card_data = {{data.from.general, room:getSubcardsByRule(data.fromCard)}}
    for _, p in ipairs(room.players) do
      if data.results[p.id] and data.results[p.id].toCard then
        table.insert(card_data, {p.general, room:getSubcardsByRule(data.results[p.id].toCard)})
      end
    end
    local ori = room:askForCardChosen(player, player, {card_data = card_data}, self.name, "#steam_pegasus__fushi-replace")
    local orig_card = Fk:getCardById(ori)
    local shade = getShade(room, 1)[1]
    local new_card = Fk:cloneCard("rfenghou__shade", Card.Spade, 1)
    new_card:addSubcard(shade)
    if room:getSubcardsByRule(data.fromCard)[1] == ori then
      room:sendLog{
        type = "#FushiChangePindian",
        from = player.id,
        to = {data.from.id},
        arg = Fk:getCardById(shade):toLogString(),
      }
      data.fromCard = new_card
    else
      for _, p in ipairs(room.players) do
        if data.results[p.id] and room:getSubcardsByRule(data.results[p.id].toCard)[1] == ori then
          room:sendLog{
            type = "#FushiChangePindian",
            from = player.id,
            to = {p.id},
            arg = Fk:getCardById(shade):toLogString(),
          }
          data.results[p.id].toCard = new_card
          break
        end
      end
    end
    local moves = {{
      ids = { shade },
      toArea = Card.Processing,
      moveReason = fk.ReasonJustMove,
      skillName = data.reason,
      moveVisible = true,
    },
    {
      ids = { ori },
      fromArea = Card.Processing,
      toArea = Card.DiscardPile,
      moveReason = fk.ReasonJustMove,
      skillName = data.reason,
      moveVisible = true,
    }}
    room:moveCards(table.unpack(moves))
  end,
}
simashi:addSkill(fushi)

Fk:loadTranslationTable{
  ["steam_pegasus__simashi"] = "司马师",
  ["#steam_pegasus__simashi"] = "摧坚荡异",
  ["designer:steam_pegasus__simashi"] = "忆雨Meiko",

  ["steam_pegasus__dangyi"] = "荡异",
  [":steam_pegasus__dangyi"] = "出牌阶段限一次，你可与所有其他角色进行同时视为议事的逐鹿，赢者（没有则为你）将任意张拼点牌置于牌堆顶，"
  .."若意见为红/黑，你视为对意见与你相同/不同的角色使用一张【五谷丰登】/【兵临城下】。",
  ["#steam_pegasus__dangyi-put"] = "荡异：将任意张拼点牌置于牌堆顶",

  ["steam_pegasus__fushi"] = "伏士",
  [":steam_pegasus__fushi"] = "每回合限一次，当一张拼点牌亮出前，你可弃置一张牌并将之替换为【影】。",
  ["#steam_pegasus__fushi-discard"] = "伏士：可以弃置一张牌并将一张拼点牌替换为【影】",
  ["#steam_pegasus__fushi-replace"] = "伏士：将一张拼点牌替换为【影】",
  ["#FushiChangePindian"] = "%from 将 %to 的拼点牌替换为 %arg",
}

local liuye = General(extension, "steam_pegasus__liuye", "wei", 3)

--- 拿【霹雳车】
---@param room Room
---@return integer
local getCatapult = function (room)
  for _, id in ipairs(room.void) do
    if Fk:getCardById(id).name == "steam_pegasus__catapult" then
      room:setCardMark(Fk:getCardById(id), MarkEnum.DestructOutEquip, 1)
      return id
    end
  end
  local card = room:printCard("steam_pegasus__catapult", Card.Diamond, 9)
  room:setCardMark(card, MarkEnum.DestructOutEquip, 1)
  return card.id
end

local polu = fk.CreateTriggerSkill{
  name = "steam_pegasus__polu",
  anim_type = "drawcard",
  events = {fk.EventPhaseStart},
  can_trigger = function (self, event, target, player, data)
    if player == target and player:hasSkill(self) and player.phase == Player.Start then
      return true
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local catapultOnfild = false
    for _, p in ipairs(room.alive_players) do
      for _, id in ipairs(p:getCardIds("ej")) do
        if Fk:getCardById(id).trueName == "catapult" then
          catapultOnfild = true
          break
        end
      end
    end
    if catapultOnfild then
      local slashs = table.filter(room.discard_pile, function (id)
        return Fk:getCardById(id).trueName == "slash"
      end)
      if #slashs > 0 then
        local card = room:askForCardChosen(player, player, {card_data = {{"pile_discard", slashs},}}, self.name)
        room:obtainCard(player, card, true, fk.ReasonJustMove, player.id)
      end
    else
      local catapult = getCatapult(room)
      room:moveCardIntoEquip(player, catapult, self.name, true, player)
    end
  end,
}

local polu_game_start = fk.CreateTriggerSkill{
  name = "#steam_pegasus__polu_game_start",
  anim_type = "drawcard",
  events = {fk.GameStart},
  can_trigger = function (self, event, target, player, data)
    return player:hasSkill(polu)
  end,
  on_trigger = function (self, event, target, player, data)
    polu:doCost(event, target, player, data)
  end
}
polu:addRelatedSkill(polu_game_start)

liuye:addSkill(polu)

local doLiaoshi = function (room, player, targetA, targetB, skill_name)
  local move = room:askForMoveCardInBoard(player, targetA, targetB, skill_name, nil, targetA)
  if move and move.card then
    local card = move.card ---@type Card
    local mark = player:getTableMark("@steam_pegasus__liaoshi-turn")
    table.insert(mark, card:getSuitString(true))
    room:setPlayerMark(player, "@steam_pegasus__liaoshi-turn", mark)
    room:handleAddLoseSkills(player, "#steam_pegasus__liaoshi_delay")
  end
end

local liaoshi = fk.CreateActiveSkill{
  name = "steam_pegasus__liaoshi",
  anim_type = "control",
  prompt = function (self, selected_cards, selected_targets)
    if #selected_targets == 0 then
      return "#steam_pegasus__liaoshi-ivk1"
    else
      return "#steam_pegasus__liaoshi-ivk2"
    end
  end,
  can_use = function (self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  card_num = 0,
  target_num = 2,
  card_filter = Util.FalseFunc,
  target_filter = function (self, to_select, selected)
    if #selected == 0 then
      return #Fk:currentRoom():getPlayerById(to_select):getCardIds("ej") > 0
    elseif #selected == 1 then
      local targetA = Fk:currentRoom():getPlayerById(selected[1])
      local targetB = Fk:currentRoom():getPlayerById(to_select)
      local cards = targetA:getCardIds("ej")
      for _, id in ipairs(cards) do
        if targetA:canMoveCardInBoardTo(targetB, id) then
          return true
        end
      end
    end
    return false
  end,
  on_use = function (self, room, effect)
    local player = room:getPlayerById(effect.from)
    local targetA = room:getPlayerById(effect.tos[1])
    local targetB = room:getPlayerById(effect.tos[2])
    doLiaoshi(room, player, targetA, targetB, self.name)
  end,
}
local liaoshi_masochism = fk.CreateTriggerSkill{
  name = "#steam_pegasus__liaoshi_masochism",
  anim_type = "masochism",
  events = {fk.Damaged},
  can_trigger = function (self, event, target, player, data)
    if player == target and player:hasSkill("steam_pegasus__liaoshi") then
      return true
    end
  end,
  on_trigger = function (self, event, target, player, data)
    local room = player.room
    room:askForUseActiveSkill(player, "steam_pegasus__liaoshi", "#steam_pegasus__liaoshi-masochism")
  end,
}
liaoshi:addRelatedSkill(liaoshi_masochism)

local liaoshi_delay = fk.CreateTriggerSkill{
  name = "#steam_pegasus__liaoshi_delay",
  anim_type = "drawcard",
  events = {fk.CardUsing},
  can_trigger = function (self, event, target, player, data)
    if player:hasSkill(self) then
      local mark = player:getTableMark("@steam_pegasus__liaoshi-turn")
      local suit = data.card:getSuitString(true)
      if table.contains(mark, suit) then
        return true
      end
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    local mark = player:getTableMark("@steam_pegasus__liaoshi-turn")
    local suit = data.card:getSuitString(true)
    player:drawCards(#table.filter(mark, function (s) return s == suit end), self.name)
  end,

  refresh_events = {fk.TurnEnd},
  can_refresh = function (self, event, target, player, data)
    return player:hasSkill(self)
  end,
  on_refresh = function (self, event, target, player, data)
    player.room:handleAddLoseSkills(player, "-"..self.name)
  end
}
Fk:addSkill(liaoshi_delay)

liuye:addSkill(liaoshi)

Fk:loadTranslationTable{
  ["steam_pegasus__liuye"] = "刘晔",
  ["#steam_pegasus__liuye"] = "佐世之才",
  ["designer:steam_pegasus__liuye"] = "yyuaN",

  ["steam_pegasus__polu"] = "破橹",
  [":steam_pegasus__polu"] = "游戏开始时，或准备阶段，若场上没有【霹雳车】，将【霹雳车】置于你的宝物栏，若已有，你从弃牌堆中获得一张【杀】。",
  ["#steam_pegasus__polu_game_start"] = "破橹",

  ["steam_pegasus__liaoshi"] = "料势",
  [":steam_pegasus__liaoshi"] = "出牌阶段限一次，或当你受到伤害后，你可以移动场上一张牌，本回合与之花色相同的牌被使用时，你摸一张牌。",
  ["#steam_pegasus__liaoshi_masochism"] = "料势",
  ["#steam_pegasus__liaoshi_delay"] = "料势",

  ["#steam_pegasus__liaoshi-ivk1"] = "料势：你可以移动场上一张牌，请选择移动来源角色（第一步）",
  ["#steam_pegasus__liaoshi-ivk2"] = "料势：你可以移动场上一张牌，请选择接受牌的角色（第二步）",
  ["#steam_pegasus__liaoshi-masochism"] = "料势：你可以移动场上一张牌，请选择依次选择：移动来源角色、接受牌的角色",
  ["@steam_pegasus__liaoshi-turn"] = "料势",
}

local wenyang = General(extension, "steam_pegasus__wenyang", "qun", 5)

local dianpei_des = {"steam_pegasus__dianpei_st", "steam_pegasus__dianpei_nd", "steam_pegasus__dianpei_rd"}

---@param player ServerPlayer
---@param skill_name string
---@return ServerPlayer
local dianpei_st = function (player, skill_name)
  player.room:damage{
    damage = 1,
    from = player,
    to = player,
    skillName = skill_name,
  }
  return player
end

---@param player ServerPlayer
---@param skill_name string
---@return ServerPlayer|false
local dianpei_nd = function (player, skill_name)
  if player:isNude() then return false end
  local room = player.room
  local move = room:askForYiji(player, player:getCardIds("he"), room:getOtherPlayers(player), skill_name, 1, 1)
  for _, p in ipairs(room.alive_players) do
    if move[p.id] then
      return p
    end
  end
  return false
end

---@param player ServerPlayer
---@param skill_name string
---@return ServerPlayer|false
local dianpei_rd = function (player, skill_name)
  local room = player.room
  local targets = table.filter(room.alive_players, function (p)
    return player:canPindian(p)
  end)
  if #targets == 0 then return false end
  targets = table.map(targets, Util.IdMapper)
  local target = room:askForChoosePlayers(player, targets, 1, 1, "#steam_pegasus__dianpei-pindian", skill_name, false)
  if #target == 0 then return false end
  local pindian = player:pindian(table.map(target, Util.Id2PlayerMapper), skill_name)
  local winner = pindian.results[target[1]].winner
  if winner then
    return winner
  end
  return false
end

local dianpei_func = {dianpei_st, dianpei_nd, dianpei_rd}

local dianpei = fk.CreateActiveSkill{
  name = "steam_pegasus__dianpei",
  dynamic_desc = function(self, player)
    local des = table.map(player:getTableMark(self.name), function(d)
      return Fk:translate(d)
    end)
    return "steam_pegasus__dianpei_inner:"..table.concat(des, "")
  end,
  can_use = function (self, player, card, extra_data)
    return player:getMark(self.name.."invalid-turn") == 0
  end,
  card_num = 0,
  target_num = 0,
  card_filter = Util.FalseFunc,
  target_filter = Util.FalseFunc,
  on_use = function (self, room, effect)
    local player = room:getPlayerById(effect.from)
    local mark = player:getTableMark(self.name)
    local p = dianpei_func[table.indexOf(dianpei_des, mark[1])](player, self.name)
    if p then
      p = dianpei_func[table.indexOf(dianpei_des, mark[2])](p, self.name)
      if p then
        p = dianpei_func[table.indexOf(dianpei_des, mark[3])](p, self.name)
        if p then
          local choice = room:askForChoice(p, {"①②③", "①③②", "②①③", "②③①", "③①②", "③②①"}, self.name, "#steam_pegasus__dianpei-order")
          local new_mark = {}
          for i = 1, 3 do table.insert(new_mark, dianpei_des[table.indexOf({"①", "②", "③"}, choice[i])]) end
          room:setPlayerMark(player, self.name, new_mark)
          if player.kingdom ~= p.kingdom and room:askForSkillInvoke(player, self.name, nil, "#steam_pegasus__dianpei-kingdom:::"..Fk:translate(p.kingdom)) then
            room:setPlayerProperty(player, "kingdom", p.kingdom)
          else
            room:setPlayerMark(player, self.name.."invalid-turn", 1)
            player:setSkillUseHistory("steam_pegasus__beimang", 0, Player.HistoryGame)
          end
        end
      end
    end
  end,

  on_acquire = function (self, player, is_start)
    local room = player.room
    room:setPlayerMark(player, self.name, dianpei_des)
  end,
  on_lose = function (self, player, is_death)
    player.room:setPlayerMark(player, self.name, 0)
  end
}
wenyang:addSkill(dianpei)

local beimang = fk.CreateTriggerSkill{
  name = "steam_pegasus__beimang",
  frequency = Skill.Limited,
  events = {fk.DamageInflicted, fk.DamageCaused},
  can_trigger = function (self, event, target, player, data)
    if player:hasSkill(self) and player:usedSkillTimes(self.name, Player.HistoryGame) == 0 then
      return player.kingdom == target.kingdom
    end
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    return room:askForSkillInvoke(player, self.name, data, "#steam_pegasus__beimang-ivk:"..data.to.id)
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    room:doIndicate(player.id, {data.to.id})
    data.damage = data.damage + 1
  end,
}
wenyang:addSkill(beimang)

Fk:loadTranslationTable{
  ["steam_pegasus__wenyang"] = "文鸯",
  ["#steam_pegasus__wenyang"] = "孤命侵离",
  ["designer:steam_pegasus__wenyang"] = "一般路过の祝商",

  ["steam_pegasus__dianpei"] = "顛沛",
  [":steam_pegasus__dianpei"] = "出牌阶段，你可以{①受到1点伤害，然后②分配一张牌，获得牌的角色③与一名角色拼点，赢的角色}改变上述项的顺序；你须将势力变更至其相同，否则本技能本回合失效，重置“背芒”。",
  [":steam_pegasus__dianpei_inner"] = "出牌阶段，你可以{{1}}改变上述项的顺序；你须将势力变更至其相同，否则本技能本回合失效，重置“背芒”。",
  ["steam_pegasus__dianpei_st"] = "①受到1点伤害，然后",
  ["steam_pegasus__dianpei_nd"] = "②分配一张牌，获得牌的角色",
  ["steam_pegasus__dianpei_rd"] = "③与一名角色拼点，赢的角色",
  ["#steam_pegasus__dianpei-pindian"] = "顛沛：请与一名角色拼点",
  ["#steam_pegasus__dianpei-order"] = "颠沛：请选择“颠沛”的顺序",
  ["#steam_pegasus__dianpei-kingdom"] = "颠沛：将势力变更为 %arg ，否则本技能本回合失效，重置“背芒”",

  ["steam_pegasus__beimang"] = "背芒",
  [":steam_pegasus__beimang"] = "限定技，同势力角色造成或受到伤害时，你令此伤害+1，受伤角色于结算完成后回复1点体力或摸两张牌。",
  ["#steam_pegasus__beimang-ivk"] = "背芒：是否令 %src 受到的伤害+1？"
}

---@param player Player
---@return string[]
local getPlayerSkills = function (player)
  local skills = {}
  for _, s in ipairs(player.player_skills) do
    if s:isPlayerSkill(player) then
      table.insertIfNeed(skills, s.name)
    end
  end
  return skills
end

local zhangzhi = General(extension, "steam_pegasus__zhangzhi", "qun", 3)

local dubi = fk.CreateTargetModSkill{
  name = "steam_pegasus__dubi",
  frequency = Skill.Compulsory,
  bypass_times = function(self, player, skill, scope)
    return player:hasSkill(self) and #getPlayerSkills(player) == 1
  end,
  bypass_distances = function(self, player, skill)
    return player:hasSkill(self) and #getPlayerSkills(player) == 1
  end,
}
zhangzhi:addSkill(dubi)

local shudao = fk.CreateTriggerSkill{
  name = "steam_pegasus__shudao",
  frequency = Skill.Compulsory,
  events = {fk.CardUsing},
  can_trigger = function (self, event, target, player, data)
    if player:hasSkill(self) and player == target then
      local room = player.room
      local name
      if data.card.type == Card.TypeTrick then
        name = "steam_pegasus__feibai"
      else
        name = "steam_pegasus__kumo"
      end
      if player:hasSkill(name) then return false end
      local filter = function (e)
        local use = e.data[1]
        if use.from == player.id then
          if data.card.type == Card.TypeTrick then
            return use.card.type == Card.TypeTrick
          else
            return use.card.type ~= Card.TypeTrick
          end
        end
      end
      if #room.logic:getEventsOfScope(GameEvent.UseCard, #getPlayerSkills(player) + 1, filter, Player.HistoryTurn) == #getPlayerSkills(player) then
        self.cost_data = name
        return true
      end
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local name = self.cost_data
    room:handleAddLoseSkills(player, name)
    room.logic:getCurrentEvent():findParent(GameEvent.Turn):addExitFunc(function ()
      room:handleAddLoseSkills(player, "-"..name)
    end)
  end
}
zhangzhi:addSkill(shudao)

local feibai = fk.CreateTriggerSkill{
  name = "steam_pegasus__feibai",
  frequency = Skill.Compulsory,
  anim_type = "offensive",
  events = {fk.CardUsing},
  can_trigger = function (self, event, target, player, data)
    if player:hasSkill(self) and player == target then
      local targets = TargetGroup:getRealTargets(data.tos)
      if #targets > 0 then
        return table.find(targets, function (pid)
          return pid ~= player.id
        end)
      end
      return false
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local skills = getPlayerSkills(player)
    local num = math.min(#player:getCardIds("he"), #skills)
    room:askForDiscard(player, num, num, true, self.name, false)
    if num == #skills then
      local to = room:askForChoosePlayers(player, table.map(room.alive_players, Util.IdMapper), 1, 1, "#steam_pegasus__feibai-damage", self.name, false)
      room:damage{
        damage = 1,
        from = player,
        to = room:getPlayerById(to[1]),
        skillName = self.name,
      }
    end
    skills = room:askForChoices(player, skills, 1, 999, self.name, "steam_pegasus__feibai-chuanwu", false, true)
    room:handleAddLoseSkills(player, table.concat(table.map(skills, function(s) return "-"..s end), "|"))
    room.logic:getCurrentEvent():findParent(GameEvent.Turn):addExitFunc(function ()
      room:handleAddLoseSkills(player, table.concat(skills, "|"))
    end)
    room:drawCards(player, #skills, self.name)
  end,
}
zhangzhi:addRelatedSkill(feibai)

local kumo = fk.CreateTriggerSkill{
  name = "steam_pegasus__kumo",
  frequency = Skill.Compulsory,
  anim_type = "support",
  events = {fk.CardUsing},
  can_trigger = function (self, event, target, player, data)
    if player:hasSkill(self) and player == target then
      local targets = TargetGroup:getRealTargets(data.tos)
      return #targets == 0 or (#targets == 1 and targets[1] == player.id)
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local skills = getPlayerSkills(player)
    local num = math.min(#player:getCardIds("he"), 4 - #skills)
    if num > 0 then
      room:askForDiscard(player, num, num, true, self.name, false)
      if num == 4 - #skills and player:isWounded() then
        room:recover{
          who = player,
          num = 1,
          skillName = self.name,
        }
      end
    end
    skills = room:askForChoices(player, skills, 1, 999, self.name, "steam_pegasus__kumo-chuanwu", false, true)
    room:handleAddLoseSkills(player, table.concat(table.map(skills, function(s) return "-"..s end), "|"))
    room.logic:getCurrentEvent():findParent(GameEvent.Turn):addExitFunc(function ()
      room:handleAddLoseSkills(player, table.concat(skills, "|"))
    end)
    room:drawCards(player, #skills, self.name)
  end,
}
zhangzhi:addRelatedSkill(kumo)

Fk:loadTranslationTable{
  ["steam_pegasus__zhangzhi"] = "张芝",
  ["#steam_pegasus__zhangzhi"] = "草书之冠",
  ["designer:steam_pegasus__zhangzhi"] = "神秘跳跳鱼",
  ["illustrator:steam_pegasus__zhangzhi"] = "君桓文化",

  ["steam_pegasus__dubi"] = "独笔",
  [":steam_pegasus__dubi"] = "锁定技，若你仅有此技能，你使用牌无距离次数限制。",

  ["steam_pegasus__shudao"] = "书道",
  [":steam_pegasus__shudao"] = "锁定技，你同一回合内使用第X张基本/非基本牌后（X为你的技能数），本回合获得“飞白”/“枯墨”。",

  ["steam_pegasus__feibai"] = "飞白",
  [":steam_pegasus__feibai"] = "锁定技，你使用指定其他角色为目标的牌时，弃置X张牌并分配一点伤害；然后你失去至少一个技能直到回合结束并摸等量的牌。",
  ["#steam_pegasus__feibai-damage"] = "飞白：请分配1点伤害",
  ["steam_pegasus__feibai-chuanwu"] = "飞白：请失去至少一个技能直到回合结束，摸等量的牌",

  ["steam_pegasus__kumo"] = "枯墨",
  [":steam_pegasus__kumo"] = "锁定技，你使用未指定其他角色为目标的牌时，弃置4-X张牌并回复一点体力；然后你失去至少一个技能直到回合结束并摸等量的牌。",
  ["steam_pegasus__kumo-chuanwu"] = "枯墨：请失去至少一个技能直到回合结束，摸等量的牌",
}

local godzhangjiao = General(extension, "steam_pegasus__godzhangjiao", "god", 3)

local wendao = fk.CreateActiveSkill{
  name = "steam_pegasus__wendao",
  can_use = function (self, player, card, extra_data)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  card_num = 0,
  target_num = 1,
  card_filter = Util.FalseFunc,
  target_filter = function (self, to_select, selected)
    return #selected == 0
  end,
  on_use = function (self, room, effect) ---@param room Room
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    local cards = {}
    while true do
      local judge = {
        who = target,
        reason = "floating_thunder",
        pattern = ".|.|spade",
      }
      room:judge(judge)
      table.insertIfNeed(cards, judge.card)
      if judge.card.suit == Card.Spade and not target.dead then
        room:damage{
          to = target,
          damage = 1,
          damageType = fk.ThunderDamage,
          skillName = self.name,
        }
        break
      end
    end
    cards = table.filter(cards, function(c) return room:getCardArea(c) == Card.DiscardPile end)
    if #cards == 0 then return false end
    local to = room:askForChoosePlayers(player, table.map(room.alive_players, Util.IdMapper), 1, 1, "#steam_pegasus__wendao-obtain", self.name, false)
    room:obtainCard(to[1], cards, true, fk.ReasonJustMove, player.id, self.name)
    if to[1] ~= target.id and not player.dead then
      room:handleAddLoseSkills(player, "-"..self.name)
    end
  end
}
godzhangjiao:addSkill(wendao)

for i = 0, 100 do
  local limited_wendao = fk.CreateActiveSkill{
    name = "steam_pegasus__wendao_"..tostring(i),
    frequency = Skill.Limited,
    can_use = function (self, player, card, extra_data)
      return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0 and player:usedSkillTimes(self.name, Player.HistoryGame) == 0
    end,
    card_num = 0,
    target_num = 1,
    card_filter = Util.FalseFunc,
    target_filter = wendao.targetFilter,
    on_use = wendao.onUse,
  }
  Fk:addSkill(limited_wendao)
  Fk:loadTranslationTable{
    ["steam_pegasus__wendao_"..tostring(i)] = "问道",
    [":steam_pegasus__wendao_"..tostring(i)] = "限定技，出牌阶段限一次，你可以令一名角色进行【浮雷】判定直至因此受到伤害，然后你令一名角色获得这些判定牌，若不为同一名角色，失去此技能。",
  }
end

local getWendao = function (player)
  local index = player.tag["steam_pegasus__wendao"] or 0
  player.room:handleAddLoseSkills(player, "steam_pegasus__wendao_"..tostring(index))
  player.tag["steam_pegasus__wendao"] = index + 1
end

local hongfa = fk.CreateTriggerSkill{
  name = "steam_pegasus__hongfa",
  events = {fk.DamageInflicted},
  can_trigger = function (self, event, target, player, data)
    if player:hasSkill(self) and Fk:canChain(data.damageType) and not data.chain then
      local tos = table.filter(player.room:getOtherPlayers(data.to), function(p) return p.hp == data.to.hp end)
      if #tos > 0 then
        self.cost_data = table.map(tos, Util.IdMapper)
        return true
      end
    end
  end,
  on_cost = function (self, event, target, player, data)
    local tos = player.room:askForChoosePlayers(player, self.cost_data, #self.cost_data, 999, "#steam_pegasus__hongfa-damage", self.name, true)
    if tos and #tos > 0 then
      self.cost_data = tos
      return true
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    data.beginnerOfTheDamage = true
    data.extra_data = data.extra_data or {}
    data.extra_data.hongfa = true
    local targets = self.cost_data
    room:sortPlayersByAction(targets, false)
    room.logic:getCurrentEvent():findParent(GameEvent.Damage, true):addExitFunc(function ()
      for _, pid in ipairs(targets) do
        room:sendLog{
          type = "#ChainDamage",
          from = pid
        }
        room:damage{
          from = data.from,
          to = room:getPlayerById(pid),
          damage = data.damage,
          damageType = data.damageType,
          card = data.card,
          skillName = self.name,
          chain = true,
        }
      end
    end)
  end,
}
local hongfa_delay = fk.CreateTriggerSkill{
  name = "#steam_pegasus__hongfa_delay",
  mute = true,
  events = {fk.DamageFinished},
  can_trigger = function (self, event, target, player, data)
    return player:hasSkill(hongfa.name) and ((data.extra_data and data.extra_data.hongfa) or data.skillName == hongfa.name)
  end,
  on_cost = function (self, event, target, player, data)
    return player.room:askForSkillInvoke(data.to, hongfa.name, data, "#steam_pegasus__hongfa-skill")
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    room:notifySkillInvoked(player, hongfa.name, "special")
    room:doIndicate(player.id, {data.to.id})
    getWendao(data.to)
  end,
}
hongfa:addRelatedSkill(hongfa_delay)
godzhangjiao:addSkill(hongfa)

local hanting = fk.CreateTriggerSkill{
  name = "steam_pegasus__hanting",
  frequency = Skill.Wake,
  events = {fk.EventPhaseStart},
  can_wake = function (self, event, target, player, data)
    local skills, used_skills, used_skills_tab = 0, 0, {}
    for _, p in ipairs(player.room.alive_players) do
      for _, s in ipairs(p.player_skills) do
        if s:isPlayerSkill(p) then
          skills = skills + 1
          if table.contains({Skill.Limited, Skill.Wake}, s.frequency) and p:usedSkillTimes(s.name, Player.HistoryGame) == 1 then
            used_skills = used_skills + 1
            used_skills_tab[p.id] = used_skills_tab[p.id] or {}
            table.insert(used_skills_tab[p.id], s)
          end
        end
      end
    end
    if used_skills >= skills / 2 then
      self.cost_data = used_skills_tab
      return true
    end
  end,
  can_trigger = function (self, event, target, player, data)
    if player == target and player:hasSkill(self) then
      return player.phase == Player.Start and player:usedSkillTimes(self.name, Player.HistoryGame) == 0
    end
  end,
  on_use = function (self, event, target, player, data)
    local used_skills, choices = self.cost_data, {}
    local room = player.room
    for _, p in ipairs(room.alive_players) do
      local skills = used_skills[p.id] or {}
      if #skills > 0 then
        local choice = room:askForChoice(player, table.map(skills, function(s) return s.name end), self.name, "steam_pegasus__hanting-refresh", true)
        player:setSkillUseHistory(choice, 0, Player.HistoryGame)
        table.insert(choices, choice)
      end
    end
    local cn_names = {}
    for _, s in ipairs(choices) do
      table.insertIfNeed(cn_names, Fk:translate(s))
    end
    if #cn_names > 1 then return end
    if cn_names[1] == "问道" then
      getWendao(player)
    end
  end,
}
godzhangjiao:addSkill(hanting)

Fk:loadTranslationTable{
  ["steam_pegasus__godzhangjiao"] = "神张角",
  ["#steam_pegasus__godzhangjiao"] = "驭道震泽",
  ["designer:steam_pegasus__godzhangjiao"] = "老酒馆的猫",

  ["steam_pegasus__wendao"] = "问道",
  [":steam_pegasus__wendao"] = "出牌阶段限一次，你可以令一名角色进行【浮雷】判定直至因此受到伤害，然后你令一名角色获得这些判定牌，若不为同一名角色，失去此技能。",
  ["#steam_pegasus__wendao-obtain"] = "问道：请选择获得这些判定牌的角色",

  ["steam_pegasus__hongfa"] = "弘法",
  [":steam_pegasus__hongfa"] = "有角色受到属性伤害时，你可以令此伤害改为于相同体力的角色间传导，结算后，受伤角色可以获得带有“限定技”标签的“问道”。",
  ["#steam_pegasus__hongfa-damage"] = "弘法：令此伤害改为于相同体力的角色间传导",

  ["#steam_pegasus__hongfa_delay"] = "弘法",
  ["#steam_pegasus__hongfa-skill"] = "弘法：可以获得带有限定技标签的“问道”",

  ["steam_pegasus__hanting"] = "撼庭",
  [":steam_pegasus__hanting"] = "觉醒技，准备阶段，若场上超过半数的技能已失效，你依次重置每名角色一个已失效的技能，若均为同名技能，你获得之。",
}

return extension
