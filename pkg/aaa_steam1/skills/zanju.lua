local skel = fk.CreateSkill {
  name = "steam__zanju",
}

Fk:loadTranslationTable{
  ["steam__zanju"] = "攒局",
  [":steam__zanju"] = "轮次技，一次拼点开始时，你可令所有角色依次弃置一张手牌，以此法弃牌的角色同时声明此次拼点赢的角色；拼点结束后，声明与结果相符的角色各摸两张牌，然后你摸X张牌（X为此次声明与结果不符的角色数）。",

  ["#steam__zanju-invoke"] = "攒局：你可令所有角色弃1张手牌猜测“%arg”拼点的赢家，猜对的摸2张牌，每错1个你摸1张牌",
  ["#steam__zanju-active"] = "攒局：请弃置1张手牌，并选择你猜测的赢家！",
  ["steam__zanju_active"] = "攒局猜测",
  ["#steam__zanju_guess"] = "%from 猜测 %to 会赢",
}

--- 获取可弃的手牌
---@param player Player
---@return integer[]
local handCardsForThrow = function (player)
  return table.filter(player.player_cards[Player.Hand], function (id)
    return not player:prohibitDiscard(id)
  end)
end

skel:addEffect(fk.StartPindian, {
  anim_type = "control",
  times = function (_, player)
    return 1 - player:usedSkillTimes(skel.name, Player.HistoryRound)
  end,
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(skel.name) and player:usedSkillTimes(skel.name, Player.HistoryRound) == 0 then
      -- 一个拼点只能开一次赌局
      if (data.extra_data and data.extra_data.steam__zanju_Source) then return false end
      local pd_players = {data.from}
      table.insertTable(pd_players, data.tos)
      for _, p in ipairs(player.room.alive_players) do
        -- 拼点角色至少拥有两张手牌才能参加赌局，不然没牌拼点了
        if #handCardsForThrow(p) > (table.contains(pd_players, p) and 1 or 0) then
          return true
        end
      end
    end
  end,
  on_cost = function (self, event, target, player, data)
    return player.room:askToSkillInvoke(player, { skill_name = skel.name, prompt = "#steam__zanju-invoke:::"..data.reason})
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local pd_players = {data.from}
    table.insertTable(pd_players, data.tos)
    local players = table.filter(room.alive_players, function(p)
      return #handCardsForThrow(p) > (table.contains(pd_players, p) and 1 or 0)
    end)
    if #players == 0 then return end
    data.extra_data = data.extra_data or {}
    data.extra_data.steam__zanju_Source = player
    data.extra_data.steam__zanju_Record = {}
    pd_players = table.map(pd_players, Util.IdMapper)

    local moves = {}
    local req = Request:new(players, "AskForUseActiveSkill")
    req.focus_text = skel.name
    req.focus_players = players
    local req_data = {
      "steam__zanju_active",
      "#steam__zanju-active",
      false,
      {
        steam__zanju_targets = pd_players,
      },
    }

    for _, p in ipairs(players) do
      req:setData(p, req_data)
    end
    req:ask()
    for _, to in ipairs(players) do
      local cards, tar
      local result = req:getResult(to)
      if result ~= "" then
        cards = result.card.subcards
        tar = result.targets[1]
      else
        cards = table.random(handCardsForThrow(to), 1)
        tar = table.random(pd_players)
      end

      table.insert(moves, {
        from = to,
        ids = cards,
        toArea = Card.DiscardPile,
        moveReason = fk.ReasonDiscard,
        moveVisible = true,
        proposer = to,
        skillName = skel.name,
      })

      room:sendLog{ type = "#steam__zanju_guess", from = to.id, to = {tar} }
      data.extra_data.steam__zanju_Record[to] = tar
    end
    room:moveCards(table.unpack(moves))
  end,
})

skel:addEffect(fk.PindianFinished, {
  is_delay_effect = true,
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return data.extra_data and data.extra_data.steam__zanju_Source == player
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local winners = {}
    for _, result in pairs(data.results) do
      local winner = result.winner
      if winner then
        table.insert(winners, winner.id)
      end
    end
    local wrong_num = 0
    for to, tar in pairs(data.extra_data.steam__zanju_Record) do
      if table.contains(winners, tar) then
        if not to.dead then
          to:drawCards(2, skel.name)
        end
      else
        wrong_num = wrong_num + 1
      end
    end
    if wrong_num > 0 and not player.dead then
      player:drawCards(wrong_num, skel.name)
    end
  end,
})

local skel2 = fk.CreateSkill {
  name = "steam__zanju_active",
}

skel2:addEffect("active", {
  card_num = 1,
  target_num = 1,
  card_filter = function (self, player, to_select, selected)
    return #selected == 0 and table.contains(player.player_cards[Player.Hand], to_select)
    and not player:prohibitDiscard(Fk:getCardById(to_select))
  end,
  target_filter = function (self, player, to, selected)
    return #selected == 0 and table.contains(self.steam__zanju_targets or {}, to.id)
  end,
})

return {skel, skel2}
