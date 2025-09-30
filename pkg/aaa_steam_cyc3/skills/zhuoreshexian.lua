local skel = fk.CreateSkill {
  name = "steam__zhuoreshexian",
}

Fk:loadTranslationTable{
  ["steam__zhuoreshexian"] = "灼热射线",
  [":steam__zhuoreshexian"] = "你可以消耗1蓄力点以视为使用一张【火攻】。",

  ["#steam__zhuoreshexian"] = "消耗1蓄力点以视为使用【火攻】",
}

skel:addEffect("viewas", {
  anim_type = "offensive",
  pattern = "fire_attack|.|nosuit",
  prompt = "#steam__zhuoreshexian",
  card_filter = Util.FalseFunc,
  view_as = function(self)
    local c = Fk:cloneCard("fire_attack")
    c.skillName = skel.name
    return c
  end,
  before_use = function (self, player, use)
    player.room:removePlayerMark(player, "steam__crystal_skin", 1)
  end,
  enabled_at_play = function(self, player)
    return player:getMark("steam__crystal_skin") > 0
  end,
  enabled_at_response = function (self, player, response)
    return not response and player:getMark("steam__crystal_skin") > 0
  end,
})

return skel
