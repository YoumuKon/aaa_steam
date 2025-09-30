local skel = fk.CreateSkill {
  name = "godhanxin__baiguiyexing",
}

Fk:loadTranslationTable{
  ["godhanxin__baiguiyexing"] = "百鬼夜行",
  [":godhanxin__baiguiyexing"] = "你可以将一张【杀】当多亮出两张牌的【兵临城下】使用。",
  ["#godhanxin__baiguiyexing"] = "你可以将一张【杀】当多亮出两张牌的【兵临城下】使用。",

  ["$godhanxin__baiguiyexing"] = "纵使韩信断了枪，也徒留我一人伤，第九枪，百鬼夜行！",
}

skel:addEffect("viewas", {
  anim_type = "offensive",
  pattern = "enemy_at_the_gates",
  handly_pile = true,
  prompt = "#godhanxin__baiguiyexing",
  card_filter = function (self, player, to_select, selected)
    return #selected == 0 and Fk:getCardById(to_select).trueName == "slash"
  end,
  view_as = function (self, player, cards)
    if #cards ~= 1 then return nil end
    local c = Fk:cloneCard("enemy_at_the_gates")
    c.skillName = skel.name
    c:addSubcard(cards[1])
    return c
  end,
  before_use = function(self, player, use)
    use.extra_data = use.extra_data or {}
    use.extra_data.num = 2
  end,
  enabled_at_response = function(self, player, response)
    return not response
  end,
})



return skel
