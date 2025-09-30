local skel = fk.CreateSkill {
  name = "steam__jianlu",
}

Fk:loadTranslationTable{
  ["steam__jianlu"] = "坚颅",
  [":steam__jianlu"] = "你受到伤害后，可以减任意点体力上限，获得等量的护甲。",

  ["steam__jianlu_number"] = "坚颅",
  ["#steam__jianlu-ask"] = "坚颅：可以减任意点体力上限，获得等量的护甲",
}

skel:addEffect(fk.Damaged, {
  anim_type = "defensive",
  events = {fk.Damaged},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(skel.name) and target == player and player.maxHp > 0
  end,
  on_cost = function (self, event, target, player, data)
    local _ ,dat = player.room:askToUseActiveSkill(player, { skill_name = "steam__jianlu_number", prompt = "#steam__jianlu-ask" })
    if dat then
      event:setCostData(self, dat.interaction)
      return true
    end
  end,
  on_use = function (self, event, target, player, data)
    local num = event:getCostData(self)
    local room = player.room
    room:changeMaxHp(player, -num)
    if player:isAlive() then
      room:changeShield(player, num)
    end
  end,
})

local skel2 = fk.CreateSkill {
  name = "steam__jianlu_number",
}

skel2:addEffect("active", {
  card_num = 0,
  target_num = 0,
  card_filter = Util.FalseFunc,
  interaction = function (self, player)
    return UI.Spin { from = 1, to = player.maxHp }
  end,
})

return {skel, skel2}
