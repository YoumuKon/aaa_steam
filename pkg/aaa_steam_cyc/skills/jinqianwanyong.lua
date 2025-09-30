local skel = fk.CreateSkill {
  name = "steam__jinqianwanyong",
}

Fk:loadTranslationTable{
  ["steam__jinqianwanyong"] = "金钱万用",
  [":steam__jinqianwanyong"] = "你可以将展柜内的<font color='red'>♦</font>牌当【桃】对自己使用。每轮结束时，你须将展柜内的牌当一张无距离限制【杀】使用。",

  ["#steam__jinqianwanyong-peach"] = "可以将“展柜”中的<font color='red'>♦</font>牌当【桃】对自己使用。",
  ["#steam__jinqianwanyong-slash"] = "你须将展柜内的牌当无距离限制【杀】使用，选择【杀】的目标",
  ["#steam__jinqianwanyong2"] = "金钱万用",
}

skel:addEffect("viewas", {
  anim_type = "defensive",
  pattern = "peach",
  mute_card = false,
  expand_pile = "luxury_showcase",
  prompt = "#steam__jinqianwanyong-peach",
  card_filter = function (self, player, to_select, selected)
    return #selected < 1 and player:getPileNameOfId(to_select) == "luxury_showcase" and Fk:getCardById(to_select).suit == Card.Diamond
  end,
  view_as = function (self, player, cards)
    if #cards ~= 1 then return nil end
    local c = Fk:cloneCard("peach")
    c.skillName = self.name
    c:addSubcard(cards[1])
    return c
  end,
  enabled_at_play = function(self, player)
    return player:isWounded() and #player:getPile("luxury_showcase") > 0
  end,
  enabled_at_response = function (self, player, response)
    return not response and #player:getPile("luxury_showcase") > 0
  end,
})

-- 禁止以此法对其他角色使用桃
skel:addEffect("prohibit", {
  is_prohibited = function(self, from, to, card)
    return from and to and card and from ~= to and table.contains(card.skillNames, skel.name) and card.name == "peach"
  end,
})

skel:addEffect(fk.RoundEnd, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(skel.name) and #player:getPile("luxury_showcase") > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:askToUseVirtualCard(player, {
      name = "slash", subcards = player:getPile("luxury_showcase"), skill_name = skel.name, cancelable = false,
      extra_data = {bypass_distances = true, bypass_times = true},
    })
  end,
})


return skel
