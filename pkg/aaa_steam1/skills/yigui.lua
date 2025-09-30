local skel = fk.CreateSkill {
  name = "steam__yigui",
  tags = {Skill.Compulsory},
}

Fk:loadTranslationTable{
  ["steam__yigui"] = "忆归",
  [":steam__yigui"] = "锁定技，杀死你的其他角色阵亡后，你复活，并将体力值回复至两点，再摸四张牌。",
  ["@steam__yigui"] = "忆归",

  ["$steam__yigui1"] = "see you again.",
  ["$steam__yigui2"] = "If I accept there and have to face myself and tell myself you're a failure, I think that's a worse, that's almost worse than death.",
}

skel:addEffect(fk.Deathed, {
  anim_type = "big",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(skel.name, false, true) and target and target.id == player.tag["steam__yigui_killer"]
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(player, "@steam__yigui", 0)
    player.tag["steam__yigui_killer"] = nil
    room:setPlayerRest(player, 0)
    room:revivePlayer(player, true, skel.name)
    room:setPlayerProperty(player, "hp", math.min(2, player.maxHp))
    player:drawCards(4, skel.name)
  end,
})

skel:addEffect(fk.Deathed, {
  can_refresh = function (self, event, target, player, data)
    return target == player and player:hasShownSkill(skel.name, false, true) and player.rest == 0
    and data.killer and data.killer ~= player and not data.killer.dead
  end,
  on_refresh = function (self, event, target, player, data)
    player.room:setPlayerMark(player, "@steam__yigui", data.killer.general)
    player.tag["steam__yigui_killer"] = data.killer.id
  end,
})

skel:addLoseEffect(function (self, player, is_death)
  if not is_death and player:getMark("@steam__yigui") ~= 0 then
    player.room:setPlayerMark(player, "@steam__yigui", 0)
  end
end)

return skel
