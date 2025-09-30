local skel = fk.CreateSkill {
  name = "steam__yonghengzhizhou",
  tags = {Skill.Compulsory},
}

Fk:loadTranslationTable{
  ["steam__yonghengzhizhou"] = "永恒之咒",
  [":steam__yonghengzhizhou"] = "锁定技，出牌阶段开始时，你须对一名角色造成1点伤害，然后其随机获得两张伤害牌；若你失去过〖永恒之咒〗获得的【桃】，则再执行一次。",
  ["#steam__yonghengzhizhou-choose"] = "永恒之咒：你须对一名角色造成1点伤害，再令其获得两张伤害牌",
}

skel:addEffect(fk.EventPhaseStart, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(skel.name) and player.phase == Player.Play and target == player
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    for i = 1, 2 do
      local tos = room:askToChoosePlayers(player, { targets = room.alive_players, min_num = 1, max_num = 1,
       prompt = "#steam__yonghengzhizhou-choose", skill_name = skel.name, cancelable = false})
      local to = tos[1]
      room:damage{from = player, to = to, damage = 1, skillName = skel.name}
      if not to.dead then
        local cards = table.filter(table.connect(room.draw_pile, room.discard_pile), function (id)
          return Fk:getCardById(id).is_damage_card
        end)
        if #cards > 0 then
          room:moveCardTo(table.random(cards, 2), Card.PlayerHand, to, fk.ReasonJustMove, skel.name, nil, true)
        end
      end
      if player.dead or player:getMark("steam__yonghengzhizhou_lose") == 0 then return end
    end
  end,
})

skel:addEffect(fk.AfterCardsMove, {
  can_refresh = function (self, event, target, player, data)
    if player:hasSkill(skel.name, true) and player:getMark("steam__yonghengzhizhou_lose") == 0 then
      for _, move in ipairs(data) do
        if move.from == player then
          for _, info in ipairs(move.moveInfo) do
            if info.fromArea == Card.PlayerHand and Fk:getCardById(info.cardId):getMark("@@steam__jinjizhimen") == player.id then
              return true
            end
          end
        end
      end
    end
  end,
  on_refresh = function (self, event, target, player, data)
    player.room:setPlayerMark(player, "steam__yonghengzhizhou_lose", 1)
  end,
})

return skel
