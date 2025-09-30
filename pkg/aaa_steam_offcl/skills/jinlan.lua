local skel = fk.CreateSkill {
  name = "steam__jinlan",
}

Fk:loadTranslationTable{
  ["steam__jinlan"] = "尽览",
  [":steam__jinlan"] = "当你每回合首次获得/失去牌后，你可以展示手牌，若点数/牌名均不同，你摸一张牌。",

  ["#steam__jinlan_get"] = "尽览：你可以展示手牌，若点数均不同，摸1张牌",
  ["#steam__jinlan_lose"] = "尽览：你可以展示手牌，若牌名均不同，摸1张牌",
  ["steam__jinlan_lose"] = "尽览[失]",
  ["steam__jinlan_get"] = "尽览[得]",

  ["$steam__jinlan1"] = "深览精远之统，宜效商周之制。",
  ["$steam__jinlan2"] = "建久安于万载，垂长统于无穷。",
}

skel:addEffect(fk.AfterCardsMove, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(skel.name) and not player:isKongcheng() then
      local room = player.room
      local currentId = room.logic:getCurrentEvent():findParent(GameEvent.MoveCards, true).id
      -- 记录首次失去和获得牌的事件ID
      local getId, loseId = player:getMark("steam__jinlan_get-turn"), player:getMark("steam__jinlan_lose-turn")
      if getId == 0 or loseId == 0 then
        room.logic:getEventsOfScope(GameEvent.MoveCards, 1, function(e)
          for _, move in ipairs(e.data) do
            if getId == 0 then
              if move.to == player and move.toArea == Player.Hand then
                getId = e.id
                room:setPlayerMark(player, "steam__jinlan_get-turn", getId)
              end
            end
            if loseId == 0 then
              if move.from == player and table.find(move.moveInfo, function(info)
              return info.fromArea == Card.PlayerEquip or info.fromArea == Card.PlayerHand end) then
                loseId = e.id
                room:setPlayerMark(player, "steam__jinlan_lose-turn", loseId)
              end
            end
          end
          return getId ~= 0 and loseId ~= 0
        end, Player.HistoryTurn)
      end
      return currentId == getId or currentId == loseId
    end
  end,
  on_trigger = function (self, event, target, player, data)
    local datas = {}
    local currentId = player.room.logic:getCurrentEvent():findParent(GameEvent.MoveCards, true).id
    local getId, loseId = player:getMark("steam__jinlan_get-turn"), player:getMark("steam__jinlan_lose-turn")
    if currentId == getId then
      table.insert(datas, "steam__jinlan_get")
    end
    if currentId == loseId then
      table.insert(datas, "steam__jinlan_lose")
    end
    while #datas > 0 and player:hasSkill(skel.name) do
      local choice = player.room:askToChoice(player, {choices = datas, skill_name = skel.name})
      table.removeOne(datas, choice)
      self:doCost(event, target, player, choice)
    end
  end,
  on_cost = function (self, event, target, player, data)
    return player.room:askToSkillInvoke(player, { skill_name = skel.name, prompt = "#".. data })
  end,
  on_use = function (self, event, target, player, data)
    player:filterHandcards()
    local cards = player:getCardIds("h")
    player:showCards(cards)
    if player.dead then return end
    local infos = {}
    if data == "steam__jinlan_get" then
      for _, id in ipairs(cards) do
        table.insertIfNeed(infos, Fk:getCardById(id).number)
      end
      if #infos == #cards then
        player:drawCards(1, skel.name)
      end
    else
      for _, id in ipairs(cards) do
        table.insertIfNeed(infos, Fk:getCardById(id).trueName)
      end
      if #infos == #cards then
        player:drawCards(1, skel.name)
      end
    end
  end,
})

return skel
