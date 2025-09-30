local changbiao = fk.CreateSkill{
  name = "steam__changbiao",
}

Fk:loadTranslationTable {
  ["steam__changbiao"] = "长标",
  [":steam__changbiao"] = "出牌阶段限一次，你可以将任意张手牌当【杀】使用（无距离限制），若此【杀】造成过伤害，此阶段结束时，你摸等量的牌。",

  ["#steam__changbiao"] = "长标：你可以将任意张手牌当【杀】使用",
  ["@steam__changbiao_draw-phase"] = "长标",

  ["$steam__changbiao1"] = "兵主血脉，岂可懦然藏身莽荒。",
  ["$steam__changbiao2"] = "蚩尤之嗣，举兵图复旧日河山。",
}

changbiao:addEffect("viewas", {
  anim_type = "offensive",
  pattern = "slash",
  prompt = "#steam__changbiao",
  handly_pile = true,
  card_filter = function(self, player, to_select, selected)
    return Fk:currentRoom():getCardArea(to_select) ~= Player.Equip
  end,
  view_as = function(self, player, cards)
    if #cards < 1 then return end
    local c = Fk:cloneCard("slash")
    c.skillName = changbiao.name
    c:addSubcards(cards)
    return c
  end,
  before_use = function(self, player, use)
    use.extra_data = use.extra_data or {}
    use.extra_data.changbiao = player
  end,
  enabled_at_play = function(self, player)
    return player:usedSkillTimes(changbiao.name, Player.HistoryPhase) < 1
  end,
  enabled_at_response = Util.FalseFunc,
})

changbiao:addEffect(fk.EventPhaseEnd, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return player:getMark("@steam__changbiao_draw-phase") > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    player:drawCards(player:getMark("@steam__changbiao_draw-phase"), "steam__changbiao")
  end,
})

changbiao:addEffect(fk.CardUseFinished, {
  can_refresh = function(self, event, target, player, data)
    return (data.extra_data or {}).changbiao == player and data.damageDealt and not player.dead
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:addPlayerMark(player, "@steam__changbiao_draw-phase", #data.card.subcards)
  end,
})

changbiao:addEffect("targetmod", {
  bypass_distances =  function(self, player, skill, card, to)
    return table.contains(card.skillNames, changbiao.name)
  end,
})

return changbiao
