local skel = fk.CreateSkill {
  name = "steam__buluo",
  tags = {Skill.Compulsory},
}

Fk:loadTranslationTable{
  ["steam__buluo"] = "不落",
  [":steam__buluo"] = "锁定技，结束阶段，你摸X张牌；你的手牌上限+X（X为你装备区牌数的历史最大值）。",
  ["@steam__buluo"] = "不落",
}

skel:addEffect(fk.EventPhaseStart, {
  anim_type = "drawcard",
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(skel.name) and player.phase == Player.Finish and player:getMark("@steam__buluo") > 0
  end,
  on_use = function (self, event, target, player, data)
    player:drawCards(player:getMark("@steam__buluo"), skel.name)
  end,
})

skel:addEffect(fk.AfterCardsMove, {
  can_refresh = function(self, event, target, player, data)
    return (player:hasSkill(skel.name, true) and player:getMark("@steam__buluo") < #player:getCardIds("e"))
    or (player:getMark(skel.name) ~= 0 and tonumber(player:getMark(skel.name)) < #player:getCardIds("e"))
  end,
  on_refresh = function(self, event, target, player, data)
    if player:hasSkill(skel.name, true) then
      player.room:setPlayerMark(player, "@steam__buluo", #player:getCardIds("e"))
    else
      player.room:setPlayerMark(player, skel.name, tostring(#player:getCardIds("e")))
    end
  end,
})

skel:addAcquireEffect(function (self, player, is_start)
  player.room:setPlayerMark(player, "@steam__buluo", tonumber(player:getMark(self.name)))
end)

skel:addLoseEffect(function (self, player, is_death)
  player.room:setPlayerMark(player, self.name, tostring(player:getMark("@steam__buluo")))
  player.room:setPlayerMark(player, "@steam__buluo", 0)
end)

skel:addEffect("maxcards", {
  correct_func = function(self, player)
    return player:getMark("@steam__buluo")
  end,
})

return skel
