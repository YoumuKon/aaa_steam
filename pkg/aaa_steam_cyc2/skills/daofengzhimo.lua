local skel = fk.CreateSkill {
  name = "steam__daofengzhimo",
  tags = {Skill.Hidden},
}

Fk:loadTranslationTable{
  ["steam__daofengzhimo"] = "刀锋之末",
  [":steam__daofengzhimo"] = "隐匿技，你登场的回合结束时，你获得中央区内的伤害牌。",

  ["@@steam__daofengzhimo-turn"] = "刀锋之末",

  ["$steam__daofengzhimo1"] = "速战速决吧！",
  ["$steam__daofengzhimo2"] = "他们活不长了。",
}

local U = require "packages/utility/utility"

skel:addEffect(U.GeneralAppeared, {
  anim_type = "drawcard",
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasShownSkill(skel.name)
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    player.room:setPlayerMark(player, "@@steam__daofengzhimo-turn", 1)
  end,
})

skel:addEffect(fk.TurnEnd, {
  is_delay_effect = true,
  anim_type = "drawcard",
  can_trigger = function (self, event, target, player, data)
    return player:getMark("@@steam__daofengzhimo-turn") > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local cards = table.filter(room:getBanner("@$CenterArea") or Util.DummyTable, function (id)
      return Fk:getCardById(id).is_damage_card
    end)
    if #cards > 0 then
      room:obtainCard(player, cards, true, fk.ReasonJustMove, player, skel.name)
    end
  end,
})

skel:addAcquireEffect(function (self, player, is_start)
  player.room:addSkill("#CenterArea")
end)

return skel
