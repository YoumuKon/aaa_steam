local skel = fk.CreateSkill {
  name = "steam__rage",
  tags = {Skill.Compulsory},
}

Fk:loadTranslationTable{
  ["steam__rage"] = "狂暴！",
  [":steam__rage"] = "锁定技，你手牌变动过的回合结束时，若你的手牌均为红色，你依次将手牌当火【杀】或【决斗】使用，期间你受到伤害后摸一张牌。",

  ["steam__rage_viewas"] = "狂暴！",
  ["#steam__rage-use"] = "狂暴！你须将一张手牌当火【杀】或【决斗】使用！",
}

skel:addEffect(fk.TurnEnd, {
  anim_type = "offensive",
  events = {fk.TurnEnd},
  can_trigger = function (self, event, target, player, data)
    return player:hasSkill(skel.name) and player:getHandcardNum() > 0 and
      table.every(player:getCardIds("h"), function (id)
        return Fk:getCardById(id).color == Card.Red
      end) and
      #player.room.logic:getEventsOfScope(GameEvent.MoveCards, 1, function(e)
        for _, move in ipairs(e.data) do
          if move.to == player and move.toArea == Card.PlayerHand then
            return true
          end
          if move.from == player then
            for _, info in ipairs(move.moveInfo) do
              if info.fromArea == Card.PlayerHand then
                return true
              end
            end
          end
        end
      end, Player.HistoryTurn) > 0
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(player, "steam__rage-tmp-turn", 1)
    while not player.dead and not player:isKongcheng() do
      local yes = false
      for _, id in ipairs(player:getCardIds("h")) do
        local card = Fk:cloneCard("fire__slash")
        card.skillName = self.name
        card:addSubcard(id)
        if table.find(room:getOtherPlayers(player), function (p)
          return player:canUseTo(card, p, {bypass_times = true})
        end) then
          yes = true
          break
        end
        card = Fk:cloneCard("duel")
        card:addSubcard(id)
        if table.find(room:getOtherPlayers(player), function (p)
          return player:canUseTo(card, p)
        end) then
          yes = true
          break
        end
      end
      if not yes then return end
      local use = room:askToUseVirtualCard(player, {
        name = {"fire__slash", "duel"}, skill_name = skel.name, cancelable = false, skip = false,
        card_filter = { n = {1, 1}, pattern = ".|.|.|hand", prompt = "#steam__rage-use" }
      })
      if not use then break end
    end
    room:setPlayerMark(player, "steam__rage-tmp-turn", 0)
  end,
})

skel:addEffect(fk.Damaged, {
  anim_type = "masochism",
  can_trigger = function (self, event, target, player, data)
    return target == player and player:getMark("steam__rage-tmp-turn") > 0
  end,
  on_use = function (self, event, target, player, data)
    player:drawCards(1, skel.name)
  end,
})

local skel2 = fk.CreateSkill {
  name = "steam__rage_viewas",
  tags = {Skill.Compulsory},
}

skel2:addEffect("viewas", {
  anim_type = "drawcard",
  interaction = function ()
    return UI.CardNameBox { choices = {"fire__slash", "duel"} }
  end,
  card_filter = function (self, player, to_select, selected)
    return table.contains(player:getCardIds("h"), to_select)
  end,
  view_as = function (self, player, cards)
    if #cards ~= 1 then return end
    local card = Fk:cloneCard(self.interaction.data)
    card.skillName = skel.name
    card:addSubcards(cards)
    return card
  end,
})

return {skel, skel2}
