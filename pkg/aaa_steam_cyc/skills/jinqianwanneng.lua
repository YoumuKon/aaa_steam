local skel = fk.CreateSkill {
  name = "steam__jinqianwanneng",
}

Fk:loadTranslationTable{
  ["steam__jinqianwanneng"] = "金钱万能",
  [":steam__jinqianwanneng"] = "你可以将展柜内的<font color='red'>♦</font>牌当【桃】对自己使用。",

  ["#steam__jinqianwanneng2"] = "金钱万能",
  ["#steam__jinqianwanneng-peach"] = "可以将“展柜”中的<font color='red'>♦</font>牌当【桃】对自己使用。",
}

skel:addEffect("viewas", {
  anim_type = "defensive",
  pattern = "peach",
  mute_card = false,
  expand_pile = "keeper_showcase",
  prompt = "#steam__jinqianwanneng-peach",
  card_filter = function (self, player, to_select, selected)
    return #selected < 1 and player:getPileNameOfId(to_select) == "keeper_showcase" and Fk:getCardById(to_select).suit == Card.Diamond
  end,
  view_as = function (self, player, cards)
    if #cards ~= 1 then return nil end
    local c = Fk:cloneCard("peach")
    c.skillName = skel.name
    c:addSubcard(cards[1])
    return c
  end,
  enabled_at_play = function(self, player)
    return player:isWounded() and #player:getPile("keeper_showcase") > 0
  end,
  enabled_at_response = function (self, player, response)
    return not response and #player:getPile("keeper_showcase") > 0
  end,
})

-- 禁止以此法对其他角色使用桃
skel:addEffect("prohibit", {
  is_prohibited = function(self, from, to, card)
    return from and to and card and from ~= to and table.contains(card.skillNames, skel.name)
  end,
})


return skel
