local skel = fk.CreateSkill {
  name = "steam__jueyu",
}

Fk:loadTranslationTable{
  ["steam__jueyu"] = "决誉",
  [":steam__jueyu"] = "出牌阶段限一次，你可以展示一名其他角色的一张手牌。若如此做，本阶段你下次对其造成伤害后，可以获得其一张被展示过的"..
  "同花色牌，或于本阶段结束后获得一个额外的出牌阶段。",

  ["#steam__jueyu"] = "决誉：展示一名角色一张手牌，本阶段下次对其造成伤害后可以执行选项",
  ["@steam__jueyu-phase"] = "决誉",
  ["#steam__jueyu_trigger"] = "决誉",
  ["#steam__jueyu-phase"] = "决誉：是否获得一个额外的出牌阶段？",
  ["#steam__jueyu-prey"] = "决誉：你可以获得 %dest 一张牌或获得额外出牌阶段",
  ["steam__jueyu_phase"] = "获得额外出牌阶段",
  ["@$steam__jueyu"] = "展示牌",
}

skel:addEffect("active", {
  prompt = "#steam__jueyu",
  anim_type = "control",
  card_num = 0,
  target_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  times = function (self, player)
    return 1 - player:usedSkillTimes(self.name, Player.HistoryPhase)
  end,
  card_filter = Util.FalseFunc,
  target_filter = function (self, player, to_select, selected)
    return #selected == 0 and to_select ~= player and not to_select:isKongcheng()
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    local id = room:askToChooseCard(player, { target = target, flag = "h", skill_name = self.name})
    target:showCards(id)
    if player.dead or target.dead then return end
    room:setPlayerMark(target, "@steam__jueyu-phase", Fk:getCardById(id):getSuitString(true))
    room:addTableMark(player, "steam__jueyu-phase", target.id)
  end,
})

skel:addEffect(fk.Damage, {
  is_delay_effect = true,
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and not player.dead and
      table.contains(player:getTableMark("steam__jueyu-phase"), data.to.id)
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local all = data.to:getTableMark("@$steam__jueyu")
    local cards = table.filter(all, function (id)
      return Fk:getCardById(id):getSuitString(true) == data.to:getMark("@steam__jueyu-phase")
    end)
    room:setPlayerMark(data.to, "@steam__jueyu-phase", 0)
    room:removeTableMark(player, "steam__jueyu-phase", data.to.id)
    if target.dead or #cards == 0 then
      if room:askToSkillInvoke(player, { skill_name = skel.name, prompt = "#steam__jueyu-phase"}) then
        player:gainAnExtraPhase(Player.Play, skel.name)
      end
    else
      local get, choice = room:askToChooseCardsAndChoice(player, {
        cards = cards, choices = {"OK"}, skill_name = skel.name, prompt = "#steam__jueyu-prey::"..data.to.id,
        cancel_choices = {"steam__jueyu_phase", "Cancel"}, min_num = 1, max_num = 1,
        all_cards = all,
      })
      if #get > 0 then
        room:moveCardTo(get, Card.PlayerHand, player, fk.ReasonPrey, skel.name, nil, true, player)
      elseif choice == "steam__jueyu_phase" then
        player:gainAnExtraPhase(Player.Play, skel.name)
      end
    end
  end,
})

skel:addEffect(fk.CardShown, {
  can_refresh = function(self, event, target, player, data)
    return player:hasSkill(skel.name, true)
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    local mark = target:getTableMark("@$steam__jueyu")
    for _, id in ipairs(data.cardIds) do
      if table.contains(target:getCardIds("h"), id) then
        table.insertIfNeed(mark, id)
      end
    end
    room:setPlayerMark(target, "@$steam__jueyu", mark)
  end,
})

skel:addEffect(fk.AfterCardsMove, {
  can_refresh = function(self, event, target, player, data)
    return player:getMark("@$steam__jueyu") ~= 0
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    local mark = player:getTableMark("@$steam__jueyu")
    for _, move in ipairs(data) do
      if move.from == player then
        for _, info in ipairs(move.moveInfo) do
          if info.fromArea == Card.PlayerHand and table.contains(mark, info.cardId) then
            room:removeTableMark(player, "@$steam__jueyu", info.cardId)
          end
        end
      end
    end
  end,
})

return skel
