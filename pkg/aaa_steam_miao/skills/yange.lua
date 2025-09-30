local skel = fk.CreateSkill {
  name = "steam__yange",
}

Fk:loadTranslationTable{
  ["steam__yange"] = "颜革",
  [":steam__yange"] = "每轮限一次，已受伤角色回合开始时，你可以对其使用一张“约”；若你对其发动过“灯塔”，你可以重置“颜革”，令其将体力值调整为1并用所有手牌交换“约”。",

  ["#steam__yange-use"] = "颜革：你可以对 %src 使用一张“约”",
  ["#steam__yange-reset"] = "颜革：你可以重置“颜革”，令其将体力值调整为1，用所有手牌交换“约”",

  ["$steam__yange1"] = "I cannot afford the luxury of sentiment, mine must be cold logic.",
  ["$steam__yange2"] = "The time has come when we must proceed with the business of carrying the war to the enemy.",
}

skel:addEffect(fk.TurnStart, {
  anim_type = "offensive",
  times = function (_, player)
    return 1 - player:usedSkillTimes(skel.name, Player.HistoryRound)
  end,
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(skel.name) and #player:getPile("steam_treaty") > 0 and player:usedSkillTimes(skel.name, Player.HistoryRound) == 0 then
      return not target.dead and target:isWounded()
    end
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local use = room:askToUseRealCard(player, {
      skill_name = skel.name, cards = player:getPile("steam_treaty"),
      expand_pile = "steam_treaty", pattern = ".|.|.|steam_treaty",
      prompt = "#steam__yange-use:"..target.id, skip = true,
      extra_data = {bypass_distances = true, bypass_times = true, exclusive_targets = {target.id}, fix_targets = {target.id}}
    })
    if use then
      event:setCostData(self, {use = use, tos = {target}})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:useCard(event:getCostData(self).use)
    if player.dead then return end
    if table.contains(player:getTableMark("steam__dengta_put"), target.id)
     or table.contains(player:getTableMark("steam__dengta_recover"), target.id) then
      if room:askToSkillInvoke(player, { skill_name = skel.name, prompt = "#steam__yange-reset"}) then
        player:setSkillUseHistory(skel.name, 0, Player.HistoryRound)
        if target.dead then return end
        local x = target.hp - 1
        if x > 0 then
          room:loseHp(target, x, skel.name)
        elseif x < 0 then
          room:recover { num = -x, skillName = skel.name, who = target, recoverBy = player }
        end
        if target.dead then return end
        local moves = {}
        local cards1, cards2 = {}, {}
        if not target:isKongcheng() then
          cards1 = target:getCardIds("h")
          table.insert(moves, {
            ids = cards1,
            from = target,
            toArea = Card.Processing,
            moveReason = fk.ReasonExchange,
            skillName = skel.name,
            proposer = player,
          })
        end
        if #player:getPile("steam_treaty") > 0 then
          cards2 = player:getPile("steam_treaty")
          table.insert(moves, {
            ids = cards2,
            from = player,
            toArea = Card.Processing,
            moveReason = fk.ReasonExchange,
            skillName = skel.name,
            proposer = player,
          })
        end
        if #moves == 0 then return end
        room:moveCards(table.unpack(moves))
        cards2 = table.filter(cards2, function (id) return room:getCardArea(id) == Card.Processing end)
        cards1 = table.filter(cards1, function (id) return room:getCardArea(id) == Card.Processing end)
        moves = {}
        if player:hasSkill("steam__dengta") and #cards1 > 0 then
          table.insert(moves, {
            ids = cards1,
            to = player,
            toArea = Card.PlayerSpecial,
            moveReason = fk.ReasonExchange,
            skillName = skel.name,
            proposer = player,
            specialName = "steam_treaty",
          })
        end
        if not target.dead and #cards2 > 0 then
          table.insert(moves, {
            ids = cards2,
            to = target,
            toArea = Card.PlayerHand,
            moveReason = fk.ReasonExchange,
            skillName = skel.name,
            proposer = player,
          })
        end
        if #moves > 0 then
          room:moveCards(table.unpack(moves))
        end
        room:cleanProcessingArea(table.connect(cards1, cards2), skel.name)
      end
    end
  end,
})

return skel
