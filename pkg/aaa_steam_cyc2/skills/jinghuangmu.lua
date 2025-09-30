local skel = fk.CreateSkill {
  name = "steam__jinghuangmu",
}

Fk:loadTranslationTable{
  ["steam__jinghuangmu"] = "惊惶木",
  [":steam__jinghuangmu"] = "出牌阶段开始时，你可以选择至多三名角色，视为对其使用一张【以逸待劳】，以此法弃置两张同色牌的角色横置。",

  ["#steam__jinghuangmu-choose"] = "惊惶木：你可视为对至多三名角色使用一张【以逸待劳】",

  ["$steam__jinghuangmu1"] = "喂，你，你听见我说话了吗——不是你，是你的梦。",
  ["$steam__jinghuangmu2"] = "你会不会，可能，说不定，大概，想和我一起做梦呢?",
}

skel:addEffect(fk.EventPhaseStart, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(skel.name) and player.phase == Player.Play
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    if Fk.all_card_types["await_exhausted"] == nil then return end
    local card = Fk:cloneCard("await_exhausted")
    card.skillName = skel.name
    if player:prohibitUse(card) then return false end
    local targets = table.filter(room.alive_players, function(p)
      return not player:isProhibited(p, card)
    end)
    if #targets == 0 then return false end
    local tos = room:askToChoosePlayers(player, {
      min_num = 1, max_num = 3, targets = targets, skill_name = skel.name,
      prompt = "#steam__jinghuangmu-choose",
    })
    if #tos > 0 then
      room:sortByAction(tos)
      event:setCostData(self, {tos = tos} )
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local card = Fk:cloneCard("await_exhausted")
    card.skillName = skel.name
    room:useCard{
      from = player,
      tos = event:getCostData(self).tos,
      card = card,
    }
  end,
})

skel:addEffect(fk.AfterCardsMove, {
  is_delay_effect = true,
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if player.dead or player.chained then return false end
    local parent = player.room.logic:getCurrentEvent().parent
    if parent and parent.event == GameEvent.SkillEffect then
      parent = parent.parent
      if parent and parent.event == GameEvent.CardEffect then
        local eff = parent.data
        if eff.card.name == "await_exhausted" and table.contains(eff.card.skillNames, skel.name) then
          local ids = {}
          for _, move in ipairs(data) do
            if move.from == player and move.moveReason == fk.ReasonDiscard
             and move.skillName and string.find(move.skillName, "await_exhausted") then
              for _, info in ipairs(move.moveInfo) do
                table.insert(ids, info.cardId)
              end
            end
          end
          if #ids == 2 and Fk:getCardById(ids[1]).color == Fk:getCardById(ids[2]).color then
            return true
          end
        end
      end
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    player:setChainState(true)
  end,
})


return skel
