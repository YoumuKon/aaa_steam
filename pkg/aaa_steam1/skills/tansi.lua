local skel = fk.CreateSkill {
  name = "steam__tansi",
}

Fk:loadTranslationTable{
  ["steam__tansi"] = "贪饲",
  [":steam__tansi"] = "你可以将【杀】当作【顺手牵羊】使用，或将本回合内获得的牌当作【杀】使用，因前者/后者使用的【杀】计入/不计入额定使用【杀】次数，若均满足，此牌无距离限制且不能被响应。",
  -- 均满足：指此牌为本回合获得的【杀】；计入【杀】次数=受【杀】次数限制；不计入【杀】=不受次数限制

  ["@@steam__tansi-inhand-turn"] = "贪饲",
  ["#steam__tansi"] = "贪饲：将【杀】当作【顺手牵羊】使用(计入杀次数)、本回合内获得的牌当作无次数限制【杀】使用",

  ["$steam__tansi1"] = "此机，我怎么会错失。",
  ["$steam__tansi2"] = "你的东西，现在是我的了！",
  ["$steam__tansi3"] = "连发伺动，顺手可得。", -- 背水
}

skel:addEffect("viewas", {
  anim_type = "offensive",
  pattern = "slash,snatch",
  prompt = "#steam__tansi",
  mute = true,
  mute_card = true,
  interaction = function (self, player)
    local all_choices = {"slash", "snatch"}
    local choices = player:getViewAsCardNames(skel.name, all_choices)
    if Fk.currentResponsePattern == nil then -- 杀次数不够时，禁止转化顺手
      local slash = Fk:cloneCard("slash")
      if table.find(Fk:currentRoom().alive_players, function(to)
        return slash.skill:withinTimesLimit(player, Player.HistoryPhase, slash, "slash", to)
      end) == nil then
        table.removeOne(choices, "snatch")
      end
    end
    if #choices > 0 then
      return UI.CardNameBox { choices = choices, all_choices = all_choices }
    end
  end,
  card_filter = function (self, player, to_select, selected)
    local name = self.interaction.data
    if #selected == 0 and name then
      if name == "slash" then
        return Fk:getCardById(to_select):getMark("@@steam__tansi-inhand-turn") ~= 0
      else
        return Fk:getCardById(to_select).trueName == "slash"
      end
    end
  end,
  view_as = function (self, player, cards)
    local name = self.interaction.data
    if not name or #cards ~= 1 then return nil end
    local c = Fk:cloneCard(name)
    c.skillName = skel.name
    c:addSubcard(cards[1])
    return c
  end,
  before_use = function(self, player, use)
    local room = player.room
    room:notifySkillInvoked(player, skel.name, use.card.trueName == "slash" and "offensive" or "control")
    if not use.extraUse and use.card.trueName == "snatch" then
      player:addCardUseHistory("slash", 1)
    end
    if use.card.trueName == "slash" then
      use.extraUse = true
    end
    local cid = use.card.subcards[1]
    if cid and Fk:getCardById(cid).trueName == "slash" and Fk:getCardById(cid):getMark("@@steam__tansi-inhand-turn") ~= 0 then
      use.disresponsiveList = table.simpleClone(player.room.players)
      player:broadcastSkillInvoke(skel.name, 3) -- 背水
    else
      player:broadcastSkillInvoke(skel.name, math.random(2))
    end
  end,
  enabled_at_play = function(self, player)
    return not player:isKongcheng()
  end,
  enabled_at_response = function (self, player, response)
    return not response
  end,
})

skel:addAcquireEffect(function (self, player, is_start)
  local hand = player:getCardIds("h")
  if #hand == 0 then return end
  local room = player.room
  local get = {}
  room.logic:getEventsOfScope(GameEvent.MoveCards, 1, function(e)
    for _, move in ipairs(e.data) do
      if move.to == player and move.toArea == Player.Hand then
        for _, info in ipairs(move.moveInfo) do
          table.insert(get, info.cardId)
        end
      end
    end
    return false
  end, Player.HistoryTurn)
  for _, id in ipairs(hand) do
    if table.contains(get, id) then
      room:setCardMark(Fk:getCardById(id), "@@steam__tansi-inhand-turn", 1)
    end
  end
end)

skel:addLoseEffect(function (self, player, is_death)
  local room = player.room
  for _, id in ipairs(player:getCardIds("h")) do
    room:setCardMark(Fk:getCardById(id), "@@steam__tansi-inhand-turn", 0)
  end
end)

skel:addEffect("targetmod", {
  bypass_times = function(self, player, skill, scope, card, to)
    return card and card.trueName == "slash" and table.contains(card.skillNames, skel.name)
  end,
  bypass_distances = function(self, player, skill, card, to)
    if card and table.contains(card.skillNames, skel.name) then
      local cid = card.subcards[1]
      return cid and Fk:getCardById(cid).trueName == "slash" and Fk:getCardById(cid):getMark("@@steam__tansi-inhand-turn") ~= 0
    end
  end,
})

-- 为顺手牵羊加上杀的次数检测
skel:addEffect("prohibit", {
  is_prohibited = function(self, from, to, card)
    if from and to and card and card.name == "snatch" and table.contains(card.skillNames, skel.name) then
      local cid = card.subcards[1]
      if not cid then return true end
      local slash = Fk:getCardById(cid)
      return not slash.skill:withinTimesLimit(from, Player.HistoryPhase, slash, "slash", to)
    end
  end,
})

skel:addEffect(fk.AfterCardsMove, {
  can_refresh = function(self, event, target, player, data)
    return player:hasSkill(skel.name, true)
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    for _, move in ipairs(data) do
      if move.to == player and move.toArea == Player.Hand then
        for _, info in ipairs(move.moveInfo) do
          local id = info.cardId
          if table.contains(player.player_cards[Player.Hand], info.cardId) then
            room:setCardMark(Fk:getCardById(id), "@@steam__tansi-inhand-turn", 1)
          end
        end
      end
    end
  end,
})

return skel
