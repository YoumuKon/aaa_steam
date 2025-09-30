local skel = fk.CreateSkill {
  name = "steam__guanganfa",
  tags = {Skill.Compulsory},

  dynamic_desc = function (self, player, lang)
    local color = player:getMark("@steam__guanganfa-turn")
    if color ~= 0 then
      return "steam__guanganfa_dyn:"..color
    end
    return self.name
  end,
}

Fk:loadTranslationTable{
  ["steam__guanganfa"] = "光暗法",
  [":steam__guanganfa"] = "锁定技，你的手牌黑色、红色牌各至少有一张。每回合开始时，若上回合你仅失去一种颜色的手牌，本回合改为：你手牌始终为三张另一颜色的牌。",

  [":steam__guanganfa_dyn"] = "锁定技，本回合你手牌始终为三张{1}牌。",
  ["@steam__guanganfa-turn"] = "光暗法",
  ["#steam__guanganfa-exceed"] = "光暗法：请弃置 %arg 张多余的【%arg2】牌",

  ["$steam__guanganfa1"] = "",
  ["$steam__guanganfa2"] = "",
}

local spec = {
  on_use = function (self, event, target, player, data)
    local room = player.room
    local color = event:getCostData(self).choice
    if color then
      room:setPlayerMark(player, "@steam__guanganfa-turn", color)
    end
    color = player:getMark("@steam__guanganfa-turn")
    local colorPatMap = {["red"] = ".|.|heart,diamond", ["black"] = ".|.|spade,club"}
    -- 弃牌
    if color ~= 0 then
      local hand = player.player_cards[Player.Hand]
      local throw = table.filter(hand, function (id)
        return Fk:getCardById(id):getColorString() ~= color
      end)
      -- 指定颜色多于3张时，也需弃置
      local exceed = #hand - #throw - 3
      if exceed > 0 then
        local cards = player.room:askToCards(player, {
        min_num = exceed,
        max_num = exceed,
        include_equip = false,
        skill_name = skel.name,
        cancelable = false,
        prompt = "#steam__guanganfa-exceed:::"..exceed..":"..color,
        pattern = colorPatMap[color].."|hand",
        })
        table.insertTable(throw, cards)
      end
      if #throw > 0 then
        room:throwCard(throw, skel.name, player, player)
        if player.dead then return end
      end
    end
    local get = {}
    local colorNumMap = {["red"] = 0, ["black"] = 0}
    for _, id in ipairs(player.player_cards[Player.Hand]) do
      local col = Fk:getCardById(id):getColorString()
      if colorNumMap[col] then
        colorNumMap[col] = colorNumMap[col] + 1
      end
    end
    if color ~= 0 then
      local num = 3 - colorNumMap[color]
      if num > 0 then
        get = room:getCardsFromPileByRule(colorPatMap[color], num, "allPiles")
      end
    else
      for col, num in pairs(colorNumMap) do
        if num == 0 then
          local cid = room:getCardsFromPileByRule(colorPatMap[col], 1, "allPiles")[1]
          if cid then
            table.insert(get, cid)
          end
        end
      end
    end
    if #get > 0 then
      room:obtainCard(player, get, true, fk.ReasonJustMove, player.id, skel.name)
    end
  end,
}

skel:addEffect(fk.AfterCardsMove, {
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(skel.name) then return false end
    if player:usedSkillTimes(skel.name, Player.HistoryTurn) > 99 then return false end -- 预防死循环
    local hand = player.player_cards[Player.Hand]
    local check = false
    local black, red = 0, 0
    for _, id in ipairs(hand) do
      local c = Fk:getCardById(id)
      if c.color == Card.Black then
        black = black + 1
      elseif c.color == Card.Red then
        red = red + 1
      end
    end
    local mark = player:getMark("@steam__guanganfa-turn")
    if mark == 0 then
      check = black == 0 or red == 0
    elseif mark == "red" then
      check = red ~= 3 or red ~= #hand
    elseif mark == "black" then
      check = black ~= 3 or black ~= #hand
    end
    event:setCostData(self, {choice = nil})
    if not check then return false end
    for _, move in ipairs(data) do
      if (move.to == player and move.toArea == Card.PlayerHand) or
      (move.from == player and table.find(move.moveInfo, function(info) return info.fromArea == Card.PlayerHand end)) then
        return true
      end
    end
  end,
  on_use = spec.on_use,
})

skel:addEffect(fk.TurnStart, {
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(skel.name) then return false end
    if player:usedSkillTimes(skel.name, Player.HistoryTurn) > 99 then return false end -- 预防死循环
    local hand = player.player_cards[Player.Hand]
    local check = false
    local black, red = 0, 0
    for _, id in ipairs(hand) do
      local c = Fk:getCardById(id)
      if c.color == Card.Black then
        black = black + 1
      elseif c.color == Card.Red then
        red = red + 1
      end
    end
    local mark = player:getMark("@steam__guanganfa-turn")
    if mark == 0 then
      check = black == 0 or red == 0
    elseif mark == "red" then
      check = red ~= 3 or red ~= #hand
    elseif mark == "black" then
      check = black ~= 3 or black ~= #hand
    end
    event:setCostData(self, {choice = nil})
    local lastColor
    local current_event = player.room.logic:getCurrentEvent():findParent(GameEvent.Turn, true)
    if not current_event then return false end
    local last_event = player.room.logic:getEventsByRule(GameEvent.Turn, 1, function (e)
      return e.id < current_event.id
    end, 1)[1]
    -- 检查上一回合是否仅失去一种颜色的手牌
    if last_event then
      if #player.room.logic:getEventsByRule(GameEvent.MoveCards, 1, function (e)
        if e.id > current_event.id then return false end
        for _, move in ipairs(e.data) do
          if move.from == player then
            for _, info in ipairs(move.moveInfo) do
              if info.fromArea == Card.PlayerHand then
                local color = Fk:getCardById(info.cardId):getColorString()
                if color == "nocolor" then
                  return true
                elseif not lastColor then
                  lastColor = color
                elseif lastColor ~= color then
                  return true
                end
              end
            end
          end
        end
      end, last_event.id) > 0 then
        lastColor = nil
      end
    end
    if lastColor then
      event:setCostData(self, {choice = lastColor == "red" and "black" or "red"})
      return true
    else
      return check
    end
  end,
  on_use = spec.on_use,
})

return skel
