local skel = fk.CreateSkill {
  name = "steam__bizheng",
}

Fk:loadTranslationTable{
  ["steam__bizheng"] = "必争",
  [":steam__bizheng"] = "每回合各限一次，你受到伤害或弃置牌时，可以防止之，然后你须展示手牌并分配直至你的手牌中只有一种类型的牌。",

  ["#steam__bizheng-damage"] = "必争：你可以防止受到伤害，展示手牌并分配直至只剩一种类型",
  ["#steam__bizheng-discard"] = "必争：你可以防止弃置牌，展示手牌并分配直至只剩一种类型",
  ["#steam__bizheng-give"] = "必争：请分配手牌直至只剩一种类型",
}

---@param player ServerPlayer
local doBizheng = function (player)
  local room = player.room
  if player:isKongcheng() then return end
  player:showCards(player:getCardIds("h"))
  while player:isAlive() and not player:isKongcheng() do
    local types = {}
    local cards = player:getCardIds("h")
    for _, id in ipairs(cards) do
      table.insertIfNeed(types, Fk:getCardById(id).type)
    end
    if #types <= 1 then break end
    local others = room:getOtherPlayers(player, false)
    if #others == 0 then break end
    room:askToYiji(player, {
      cards = cards, targets = others, skill_name = skel.name, min_num = 1, max_num = #cards, prompt = "#steam__bizheng-give"
    })
  end
end

skel:addEffect(fk.DamageInflicted, {
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(skel.name) then
      return target == player and player:getMark("steam__bizheng_damage-turn") == 0
    end
  end,
  on_cost = function (self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {skill_name = skel.name, prompt = "#steam__bizheng-damage"})
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    data:preventDamage()
    room:setPlayerMark(player, "steam__bizheng_damage-turn", 1)
    doBizheng(player)
  end,
})

skel:addEffect(fk.BeforeCardsMove, {
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(skel.name) then
      if player:getMark("steam__bizheng_discard-turn") == 0 then
        for _, move in ipairs(data) do
          if move.from == player and move.moveReason == fk.ReasonDiscard then
            for _, info in ipairs(move.moveInfo) do
              if info.fromArea == Player.Hand or info.fromArea == Player.Equip then
                return true
              end
            end
          end
        end
      end
    end
  end,
  on_cost = function (self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {skill_name = skel.name, prompt = "#steam__bizheng-discard"})
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(player, "steam__bizheng_discard-turn", 1)
    room:cancelMove(data, nil, function (move, info)
      return move.from == player and move.moveReason == fk.ReasonDiscard
      and (info.fromArea == Player.Hand or info.fromArea == Player.Equip)
    end)
    -- 感觉在这个时机插结很危险，还是用ExitFunc吧
    room.logic:getCurrentEvent():addExitFunc(function()
      doBizheng(player)
    end)
  end,
})

return skel
