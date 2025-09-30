local skel = fk.CreateSkill {
  name = "steam__xianlu",
}

Fk:loadTranslationTable{
  ["steam__xianlu"] = "先路",
  [":steam__xianlu"] = "你的攻击范围-1。一名角色的准备阶段，其可以受到你造成的1点伤害，若如此做，你摸一张牌并交给其一张牌，然后你攻击范围+1。",

  ["#steam__xianlu-ask"] = "先路：你可以受到%src造成1点伤害，然后其摸1牌并给你1牌",
  ["@steam__xianlu"] = "先路",
  ["#steam__xianlu-give"] = "先路：请交给 %src 一张牌",

  ["$steam__xianlu1"] = "我，是一切的开端！",
  ["$steam__xianlu2"] = "众生皆苦，但我会载着那些苦难的人传致于进化的荣光。",
}

skel:addEffect(fk.EventPhaseStart, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(skel.name) and not target.dead and target.phase == Player.Start
  end,
  on_cost = function(self, event, target, player, data)
    if player.room:askToSkillInvoke(target, { skill_name = skel.name, prompt = "#steam__xianlu-ask:"..player.id}) then
      event:setCostData(self, {tos = {target} })
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:damage { from = player, to = target, damage = 1, skillName = skel.name }
    if not player.dead then
      player:drawCards(1, skel.name)
    end
    if not target.dead and target ~= player and not player:isNude() then
      local cards = room:askToCards(player, { min_num = 1, max_num = 1, include_equip = true,
       skill_name = skel.name, cancelable = false, prompt = "#steam__xianlu-give:"..target.id })
      room:obtainCard(target, cards, false, fk.ReasonGive, player, skel.name)
    end
    if not player.dead then
      local num = tonumber(player:getMark("@steam__xianlu")) + 1
      room:setPlayerMark(player, "@steam__xianlu", (num >= 0 and "+" or "") .. tostring(num))
    end
  end,
})

skel:addEffect("atkrange", {
  correct_func = function (self, player)
    if player:hasSkill(skel.name) then
      return tonumber(player:getMark("@steam__xianlu"))
    end
  end,
})

skel:addAcquireEffect(function (self, player, is_start)
  player.room:setPlayerMark(player, "@steam__xianlu", "-1")
end)

skel:addLoseEffect(function (self, player, is_death)
  player.room:setPlayerMark(player, "@steam__xianlu", 0)
end)

return skel
