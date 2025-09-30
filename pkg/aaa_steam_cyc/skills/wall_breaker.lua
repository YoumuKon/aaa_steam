local skel = fk.CreateSkill {
  name = "steam__wall_breaker",
  tags = {Skill.Compulsory},
}

Fk:loadTranslationTable{
  ["steam__wall_breaker"] = "破壁之手",
  [":steam__wall_breaker"] = "锁定技，你摸牌后，获得牌堆底的两张牌，然后你须卜算两张手牌。",

  ["#steam__wall_breaker-ask"] = "破壁之手：请选择两张手牌，置于牌堆顶或牌堆底",
}

skel:addEffect(fk.AfterCardsMove, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(skel.name) then
      for _, move in ipairs(data) do
        if move.to == player and move.toArea == Player.Hand and move.moveReason == fk.ReasonDraw then
          return true
        end
      end
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    room:moveCardTo(room:getNCards(2, "bottom"), Card.PlayerHand, player, fk.ReasonJustMove, skel.name, nil, false, player)
    if player.dead or player:isKongcheng() then return end
    local cards = player:getCardIds("h")
    if #cards > 2 then
      cards = room:askToCards(player, {
        min_num = 2, max_num = 2, cancelable = false, include_equip = false, skill_name = skel.name,
        prompt = "#steam__wall_breaker-ask"
      })
    end
    local result = room:askToGuanxing(player, {
      cards = cards, skill_name = skel.name, skip = true,
    })
    local moves = {}
    if #result.top > 0 then
      result.top = table.reverse(result.top)
      table.insert(moves, {
        from = player,
        ids = result.top,
        toArea = Card.DrawPile,
        moveReason = fk.ReasonJustMove,
        skillName = skel.name,
        proposer = player,
        moveVisible = false,
        drawPilePosition = 1,
      })
    end
    if #result.bottom > 0 then
      table.insert(moves, {
        from = player,
        ids = result.bottom,
        toArea = Card.DrawPile,
        moveReason = fk.ReasonJustMove,
        skillName = skel.name,
        proposer = player,
        moveVisible = false,
        drawPilePosition = -1,
      })
    end
    room:moveCards(table.unpack(moves))
  end,
})



return skel
