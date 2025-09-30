local skel = fk.CreateSkill {
  name = "steam__spirit_rush",
}

Fk:loadTranslationTable{
  ["steam__spirit_rush"] = "灵魄突袭",
  [":steam__spirit_rush"] = "你获得或失去过手牌的阶段结束时，你可以重铸当前回合角色一张牌。若重铸牌的区域与上次不同，你摸一张牌。",

  ["#steam__spirit_rush0-invoke"] = "灵魄突袭：是否重铸 %dest 的一张牌？",
  ["#steam__spirit_rush-invoke"] = "灵魄突袭：是否重铸 %dest 的一张牌？若为%arg，你摸一张牌",
  ["#steam__spirit_rush0-ask"] = "灵魄突袭：重铸 %dest 的一张牌",
  ["#steam__spirit_rush-ask"] = "灵魄突袭：重铸 %dest 的一张牌，若为%arg，你摸一张牌",

  ["$steam__spirit_rush1"] = "狐步轻盈~",
  ["$steam__spirit_rush2"] = "轻捷的步伐~",
  ["$steam__spirit_rush3"] = "跑起来吧~",
}

skel:addEffect(fk.EventPhaseEnd, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(skel.name) and target.phase >= Player.Start and target.phase <= Player.Finish and
      not target.dead and not target:isNude() and
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
      end, Player.HistoryPhase) > 0
  end,
  on_cost = function(self, event, target, player, data)
    local prompt = "#steam__spirit_rush0-invoke::"..target.id
    if player:getMark(skel.name) ~= 0 then
      if player:getMark(skel.name) == Card.PlayerHand then
        prompt = "#steam__spirit_rush-invoke::"..target.id..":".."$Equip"
      elseif player:getMark(skel.name) == Card.PlayerEquip then
        prompt = "#steam__spirit_rush-invoke::"..target.id..":".."$Hand"
      end
    end
    if player.room:askToSkillInvoke(player, { skill_name = skel.name, prompt = prompt }) then
      event:setCostData(self, {tos = {target}})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local prompt = "#steam__spirit_rush0-ask::"..target.id
    if player:getMark(skel.name) == Card.PlayerHand then
      prompt = "#steam__spirit_rush-ask::"..target.id..":".."$Equip"
    elseif player:getMark(skel.name) == Card.PlayerEquip then
      prompt = "#steam__spirit_rush-ask::"..target.id..":".."$Hand"
    end
    local card = target ~= player and
    room:askToChooseCard(player, { target = target, flag = "he", skill_name = skel.name, prompt = prompt })
    or room:askToCards(player, {
      min_num = 1, max_num = 1, skill_name = skel.name, include_equip = true, cancelable = false, prompt = prompt
    })[1]
    local yes = player:getMark(skel.name) ~= 0 and room:getCardArea(card) ~= player:getMark(skel.name)
    room:setPlayerMark(player, skel.name, room:getCardArea(card))
    room:recastCard({card}, target, skel.name)
    if yes and not player.dead then
      player:drawCards(1, skel.name)
    end
  end,
})

return skel
