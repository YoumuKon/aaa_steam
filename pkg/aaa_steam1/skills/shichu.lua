local skel = fk.CreateSkill {
  name = "steam__shichu",
}

Fk:loadTranslationTable{
  ["steam__shichu"] = "势出",
  [":steam__shichu"] = "每回合各限一次，你使用牌时，若本回合进入弃牌堆的两种颜色牌数量相同，你可以摸一张牌或令此牌伤害+1。",

  ["steam__shichu_damage"] = "此牌伤害+1",
}

skel:addEffect(fk.CardUsing, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(skel.name) and #player:getTableMark("steam__shichu-turn") < 2 then
      local red, black = 0, 0
      player.room.logic:getEventsOfScope(GameEvent.MoveCards, 1, function(e)
        for _, move in ipairs(e.data) do
          if move.toArea == Card.DiscardPile then
            for _, info in ipairs(move.moveInfo) do
              if Fk:getCardById(info.cardId).color == Card.Red then
                red = red + 1
              elseif Fk:getCardById(info.cardId).color == Card.Black then
                black = black + 1
              end
            end
          end
        end
      end, Player.HistoryTurn)
      return red == black
    end
  end,
  on_cost = function (self, event, target, player, data)
    local all_choices = {"draw1", "steam__shichu_damage", "Cancel"}
    local choices = table.filter(all_choices, function (ch)
      return not table.contains(player:getTableMark("steam__shichu-turn"), ch)
    end)
    if not data.card.is_damage_card then
      table.removeOne(choices, "steam__shichu_damage")
    end
    if #choices <= 1 then return false end
    local choice = player.room:askToChoice(player, {
      choices = choices, skill_name = skel.name, all_choices = all_choices
    })
    if choice ~= "Cancel" then
      player.room:addTableMark(player, "steam__shichu-turn", choice)
      event:setCostData(self, { choice = choice })
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    if event:getCostData(self).choice == "draw1" then
      player:drawCards(1, skel.name)
    else
      data.additionalDamage = (data.additionalDamage or 0) + 1
    end
  end,
})

skel:addAcquireEffect(function (self, player)
  player.room:addSkill("#CenterArea")
end)

return skel
