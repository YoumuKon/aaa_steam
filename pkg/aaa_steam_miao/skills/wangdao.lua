local skel = fk.CreateSkill {
  name = "steam__wangdao",
  tags = {Skill.Compulsory, Skill.Lord}
}

Fk:loadTranslationTable{
  ["steam__wangdao"] = "王道",
  [":steam__wangdao"] = "主公技，锁定技，非“新”势力角色获得你的牌后，势力变更为“新”；你的回合开始时，若所有角色势力均为“新”，你所在阵营胜利。",

  ["$steam__wangdao1"] = "",
  ["$steam__wangdao2"] = "",
}

skel:addEffect(fk.AfterCardsMove, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(skel.name) then return false end
    local tos = {}
    for _, move in ipairs(data) do
      if move.from == player and move.to and move.toArea == Card.PlayerHand and table.find(move.moveInfo, function (info)
        return info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip
      end) then
        local to = move.to
        if to and not to.dead and to.kingdom ~= "newdyn" then
          table.insertIfNeed(tos, to)
        end
      end
    end
    if #tos > 0 then
      event:setCostData(self, {tos = tos})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    for _, to in ipairs(event:getCostData(self).tos) do
      room:changeKingdom(to, "newdyn")
    end
  end,
})

skel:addEffect(fk.TurnStart, {
  anim_type = "big",
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(skel.name) then return false end
    return target == player and table.every(player.room.alive_players, function (p)
      return p.kingdom == "newdyn"
    end)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local role = player.role
    if role == "lord" or role == "loyalist" then
      role = "lord+loyalist"
    elseif role == "rebel" or role == "rebel_chief" then
      role = "rebel+rebel_chief"
    end
    role = role .. "+civilian"
    room:gameOver(role)
  end,
})

return skel
