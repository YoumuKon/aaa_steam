local skel = fk.CreateSkill {
  name = "steam__guhuntiesuo",
}

Fk:loadTranslationTable{
  ["steam__guhuntiesuo"] = "孤魂铁索",
  [":steam__guhuntiesuo"] = "每轮限一次，一名角色的回合开始时，你可以将两张牌当【铁索连环】使用，且目标本回合不能使用与之同色的牌，然后你摸一张牌。",

  ["steam__guhuntiesuo_vs"] = "孤魂铁索",
  ["@steam__guhuntiesuo-turn"] = "魂索",
  ["#steam__guhuntiesuo-use"] = "孤魂铁索：将两张牌当【铁索连环】使用，目标本回合不能使用与之同色的牌",
}

skel:addEffect(fk.TurnStart, {
  times = function (_, player)
    return 1 - player:usedSkillTimes(skel.name, Player.HistoryRound)
  end,
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(skel.name) and #player:getCardIds("he") > 1 and
    player:usedSkillTimes(skel.name, Player.HistoryRound) == 0
  end,
  on_cost = function (self, event, target, player, data)
    local use = player.room:askToUseVirtualCard(player, {
      name = "iron_chain", skill_name = skel.name, cancelable = true, skip = true, prompt = "#steam__guhuntiesuo-use",
      card_filter = { n = {2, 2}, pattern = "." }
    })
    if use then
      event:setCostData(self, use)
      return true
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local use = event:getCostData(self)
    for _, to in ipairs(use.tos) do
      room:setPlayerMark(to, "@steam__guhuntiesuo-turn", use.card:getColorString())
    end
    room:useCard(use)
    if player:isAlive() then
      player:drawCards(1, skel.name)
    end
  end,
})

skel:addEffect("prohibit", {
  prohibit_use = function(self, player, card)
    local mark = player:getMark("@steam__guhuntiesuo-turn")
    if mark ~= 0 and card then
      return card:getColorString() == mark
      and not (card.color == Card.NoColor and #card.skillNames == 0 and card:isVirtual())
      -- 禁止使用无色牌很危险
    end
  end,
})

return skel
