local zuitan = fk.CreateSkill {
  name = "steam__zuitan",
}

Fk:loadTranslationTable{
  ["steam__zuitan"] = "醉叹",
  [":steam__zuitan"] = "准备或结束阶段，或当你受到伤害后，你可以弃置所有手牌并摸三张牌，然后移动场上的<a href=':steam_zuitan_equip'>【散轶诗简】</a>(若场上没有则先令一名角色使用之)。",

  ["#steam__zuitan-choose"] = "醉叹：令一名角色使用一张【散轶诗简】！",
  ["#steam__zuitan-choose1"] = "醉叹：请选择一名有【散轶诗简】的角色！",
  ["#steam__zuitan-choose2"] = "醉叹：请选择上一步选择的【散轶诗简】的移动终点！",

  ["$steam__zuitan1"] = "直抒胸臆，酣畅淋漓！",
  ["$steam__zuitan2"] = "折戟沉沙，壮志未酬！",
  ["$steam__zuitan3"] = "兵戈伐谋，千古不易。",
  ["$steam__zuitan4"] = "一曲战歌，一首悲词。",
}

local spec = {
  on_use = function(self, event, target, player, data)
    local room = player.room
    if not player:isKongcheng() then
      player:throwAllCards("h", zuitan.name)
    end
    if not player.dead then
      player:drawCards(3, zuitan.name)
      if not player.dead then
        local print, moves = {} , {}
        for _, p in ipairs(room.alive_players) do
          for _, id in ipairs(p:getCardIds("e")) do
            if Fk:getCardById(id).name == "steam_zuitan_equip" then
                table.insertIfNeed(print, id)
              if table.find(room:getOtherPlayers(p), function (ps) return p:canMoveCardInBoardTo(ps, id) end) then
                table.insertIfNeed(moves, p)
              end
            end
          end
        end
        if #print == 0 then
          local targets = table.filter(room.alive_players, function (p)
            return p:canUseTo(Fk:cloneCard("steam_zuitan_equip", Card.Club, 3), p)
          end)
          if #targets == 0 then return end
          local to = room:askToChoosePlayers(player, {
            min_num = 1,
            max_num = 1,
            targets = targets,
            skill_name = zuitan.name,
            prompt = "#steam__zuitan-choose",
            cancelable = false,
          })[1]
          local card = room:printCard("steam_zuitan_equip", Card.Club, 3)
          room:setCardMark(card, MarkEnum.DestructOutEquip, 1)
          room:useCard{
            from = to,
            tos = { to },
            card = card,
          }
        elseif #print > 0 and #moves > 0 then
          local to1 = room:askToChoosePlayers(player, {
            min_num = 1,
            max_num = 1,
            targets = moves,
            skill_name = zuitan.name,
            prompt = "#steam__zuitan-choose1",
            cancelable = false,
          })[1]
          local lit = {}
          for _, id in ipairs(to1:getCardIds("e")) do
            if Fk:getCardById(id).name == "steam_zuitan_equip" and table.find(room:getOtherPlayers(to1), function (ps)
              return to1:canMoveCardInBoardTo(ps, id) end) then
              table.insertIfNeed(lit, id)
            end
          end
          if #lit > 0 then
            local to2 = room:askToChoosePlayers(player, {
              min_num = 1,
              max_num = 1,
              targets = table.filter(room:getOtherPlayers(to1), function (ps) return to1:canMoveCardInBoardTo(ps, lit[1]) end),
              skill_name = zuitan.name,
              prompt = "#steam__zuitan-choose2",
              cancelable = false,
            })[1]
            room:moveCardIntoEquip(to2, lit[1], zuitan.name, true, player)
          end
        end
      end
    end
  end,
}

zuitan:addEffect(fk.EventPhaseStart, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(zuitan.name) and (player.phase == Player.Start or player.phase == Player.Finish)
  end,
  on_use = spec.on_use,
})

zuitan:addEffect(fk.Damaged, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(zuitan.name)
  end,
  on_use = spec.on_use,
})

return zuitan
