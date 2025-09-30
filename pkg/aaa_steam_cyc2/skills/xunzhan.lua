local skel = fk.CreateSkill {
  name = "steam__xunzhan",
}

Fk:loadTranslationTable{
  ["steam__xunzhan"] = "迅斩",
  [":steam__xunzhan"] = "你可以将一张基本牌当【杀】使用或打出，若如此做，本回合所有角色不能使用与之同花色的牌。",

  ["#steam__xunzhan"] = "迅斩：将一张基本牌当【杀】使用或打出，本回合所有角色不能使用此花色的牌",
  ["@steam__xunzhan-turn"] = "迅斩",

  ["$steam__xunzhan1"] = "他们不敢还击。",
  ["$steam__xunzhan2"] = "动作太慢！",
}

skel:addEffect("viewas", {
  pattern = "slash",
  anim_type = "offensive",
  prompt = "#steam__xunzhan",
  card_num = 1,
  card_filter = function (self, player, to_select, selected)
    return #selected == 0 and Fk:getCardById(to_select).type == Card.TypeBasic
  end,
  view_as = function(self, _, cards)
    if #cards ~= 1 then return end
    local card = Fk:cloneCard("slash")
    card:addSubcard(cards[1])
    card.skillName = skel.name
    return card
  end,
  before_use = function(self, player, use)
    local room = player.room
    for _, p in ipairs(room.alive_players) do
      room:addTableMark(p, "@steam__xunzhan-turn", use.card:getSuitString(true))
    end
  end,
})

skel:addEffect("prohibit", {
  prohibit_use = function(self, player, card)
    return card and table.contains(player:getTableMark("@steam__xunzhan-turn"), card:getSuitString(true))
  end,
})

return skel
