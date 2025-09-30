local skel = fk.CreateSkill {
  name = "steam__bairen",
  tags = {Skill.Compulsory},
}

Fk:loadTranslationTable{
  ["steam__bairen"] = "百韧",
  [":steam__bairen"] = "锁定技，你的回合外，当前回合角色至多对你造成X点伤害（X为当前轮次数）。",
  ["@steam__bairen-turn"] = "百韧",

  ["$steam__bairen1"] = "",
  ["$steam__bairen2"] = "",
}

skel:addEffect(fk.DamageInflicted, {
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(skel.name) and target == player and player.phase == Player.NotActive and data.from
    and data.from == player.room.current
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if player:getMark("@steam__bairen-turn") == "0" then
      data:preventDamage()
      return
    end
    local mark = player:getMark("@steam__bairen-turn")
    if mark > data.damage then
      room:removePlayerMark(player, "@steam__bairen-turn", data.damage)
    else
      room:setPlayerMark(player, "@steam__bairen-turn", "0")
      data:changeDamage(mark - data.damage)
    end
  end,
})

skel:addEffect(fk.TurnStart, {
  can_refresh = function (self, event, target, player, data)
    return player:hasSkill(skel.name, true) and target ~= player
  end,
  on_refresh = function (self, event, target, player, data)
    player.room:setPlayerMark(player, "@steam__bairen-turn", player.room:getBanner("RoundCount") or 1)
  end,
})

skel:addLoseEffect(function (self, player, is_death)
  player.room:setPlayerMark(player, "@steam__bairen-turn", 0)
end)

return skel
