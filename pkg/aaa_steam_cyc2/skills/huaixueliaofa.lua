local skel = fk.CreateSkill {
  name = "steam__huaixueliaofa",
}

Fk:loadTranslationTable{
  ["steam__huaixueliaofa"] = "坏血疗法",
  [":steam__huaixueliaofa"] = "每轮开始时，你获得一个<a href='orange_href'>“橘”</a>标记。准备阶段，你可以移去一枚“橘”，重铸判定区内的牌并回复1点体力。",

  ["orange_href"] = "若你有“橘”，摸牌阶段摸牌数+1，受到伤害时移去一枚防止之。",
  ["@orange"] = "橘",
  ["#steam__huaixueliaofa-invoke"] = "坏血疗法:可以移去一枚“橘”，重铸判定区内的牌并回复1点体力",

  ["$steam__huaixueliaofa1"] = "爽到极点！",
  ["$steam__huaixueliaofa2"] = "好受多了！",
}

skel:addEffect(fk.RoundStart, {
  anim_type = "defensive",
  can_trigger = function (self, event, target, player, data)
    return player:hasSkill(skel.name)
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    player.room:addPlayerMark(player, "@orange")
  end,
})

skel:addEffect(fk.EventPhaseStart, {
  anim_type = "defensive",
  can_trigger = function (self, event, target, player, data)
    return player:hasSkill(skel.name) and  player.phase == Player.Start and player:getMark("@orange") > 0
      and (player:isWounded() or #player:getCardIds("j") > 0)
  end,
  on_cost = function (self, event, target, player, data)
    return player.room:askToSkillInvoke(player, { skill_name = skel.name, prompt = "#steam__huaixueliaofa-invoke"})
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:removePlayerMark(player, "@orange")
    local cards = player:getCardIds("j")
    if #cards > 0 then
      room:recastCard(cards, player, skel.name)
    end
    if not player.dead then
      room:recover { num = 1, skillName = skel.name, who = player, recoverBy = player }
    end
  end,
})

skel:addEffect(fk.DrawNCards, {
  anim_type = "drawcard",
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and target:getMark("@orange") > 0
  end,
  on_use = function(self, event, target, player, data)
    data.n = data.n + 1
  end
})

skel:addEffect(fk.DamageInflicted, {
  anim_type = "defensive",
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and target:getMark("@orange") > 0
  end,
  on_use = function(self, event, target, player, data)
    player.room:removePlayerMark(target, "@orange")
    data:preventDamage()
  end,
})

return skel
