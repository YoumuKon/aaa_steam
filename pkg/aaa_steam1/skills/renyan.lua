local skel = fk.CreateSkill {
  name = "steam__renyan",
}

Fk:loadTranslationTable{
  ["steam__renyan"] = "纫炎",
  [":steam__renyan"] = "当你的手牌数变化为一后，你可以展示之并对一名角色造成1点火焰伤害，若你因此展示的牌与本回合展示过的牌花色相同，你将"..
  "手牌摸至上限且此技能本回合失效。",

  ["#steam__yanren-give"] = "宴仁：将至少%arg张手牌分配给其他角色",
  ["#steam__renyan-choose"] = "纫炎：你可以展示手牌，对一名角色造成1点火焰伤害",

  ["$steam__renyan1"] = "卿乃志同之股肱，国贼当前，可欲诛之。",
  ["$steam__renyan2"] = "请君振炎汉之武运，除篡国之逆贼。",
}

skel:addEffect(fk.AfterCardsMove, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(skel.name) or player:getHandcardNum() ~= 1 then return end
    for _, move in ipairs(data) do
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
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local tos = room:askToChoosePlayers(player, {
      min_num = 1, max_num = 1, skill_name = skel.name, targets = room.alive_players, prompt = "#steam__renyan-choose",
    })
    if #tos > 0 then
      event:setCostData(self, {tos = tos})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = event:getCostData(self).tos[1]
    local suit = Fk:getCardById(player:getCardIds("h")[1]).suit
    local same = table.contains(player:getTableMark("steam__renyan-turn"), suit)
    player:showCards(player:getCardIds("h"))
    if not to.dead then
      room:damage{
        from = player,
        to = to,
        damage = 1,
        damageType = fk.FireDamage,
        skillName = skel.name,
      }
    end
    if player.dead then return end
    if same then
      room:invalidateSkill(player, skel.name, "-turn")
      if player:getHandcardNum() < player:getMaxCards() then
        player:drawCards(player:getMaxCards() - player:getHandcardNum(), skel.name)
      end
    end
  end,
})

skel:addEffect(fk.CardShown, {
  can_refresh = function (self, event, target, player, data)
    return target == player and player:hasSkill(skel.name, true)
  end,
  on_refresh = function (self, event, target, player, data)
    local mark = player:getTableMark("steam__renyan-turn")
    for _, id in ipairs(data.cardIds) do
      table.insertIfNeed(mark, Fk:getCardById(id).suit)
    end
    player.room:setPlayerMark(player, "steam__renyan-turn", mark)
  end
})

return skel
