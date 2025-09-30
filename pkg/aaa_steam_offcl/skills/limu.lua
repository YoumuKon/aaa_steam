local skel = fk.CreateSkill {
  name = "steam__limu",
}

Fk:loadTranslationTable{
  ["steam__limu"] = "立牧",
  [":steam__limu"] = "出牌阶段，你可以将一张<font color='red'>♦</font>牌或<font color='red'>♥</font>【闪】当【乐不思蜀】对自己使用，然后回复1点体力；你的判定区有牌时，你使用牌没有次数和距离限制。",

  ["#steam__limu"] = "立牧：选择一张<font color='red'>♦</font>牌或<font color='red'>♥</font>【闪】当【乐不思蜀】对自己使用，然后回复1点体力",

  ["$steam__limu1"] = "今诸州纷乱，当立牧以定！",
  ["$steam__limu2"] = "此非为偏安一隅，但求一方百姓安宁！",
}

skel:addEffect("active", {
  anim_type = "defensive",
  prompt = "#steam__limu",
  card_num = 1,
  target_num = 0,
  can_use = function(self, player)
    return not player:hasDelayedTrick("indulgence") and not table.contains(player.sealedSlots, Player.JudgeSlot)
  end,
  target_filter = Util.FalseFunc,
  card_filter = function (self, player, to_select, selected)
    local c = Fk:getCardById(to_select)
    if #selected == 0 and (c.suit == Card.Diamond or (c.suit == Card.Heart and c.trueName == "jink")) then
      local card = Fk:cloneCard("indulgence")
      card:addSubcard(to_select)
      return not player:prohibitUse(card) and not player:isProhibited(player, card)
    end
  end,
  on_use = function(self, room, use)
    local player = use.from
    local cards = use.cards
    local card = Fk:cloneCard("indulgence")
    card:addSubcards(cards)
    room:useCard{
      from = use.from,
      tos = {use.from},
      card = card,
    }
    if not player.dead then
      room:recover{
        who = player,
        num = 1,
        skillName = self.name,
        recoverBy = player,
      }
    end
  end,
})

skel:addEffect(fk.PreCardUse, {
  can_refresh = function(self, event, target, player, data)
    return player == target and #player:getCardIds(Player.Judge) > 0 and player:hasSkill(skel.name)
  end,
  on_refresh = function(self, event, target, player, data)
    data.extraUse = true
  end,
})

skel:addEffect("targetmod", {
  bypass_times = function(self, player, skill, scope, card)
    return card and player:hasSkill(skel.name) and #player:getCardIds(Player.Judge) > 0
  end,
  bypass_distances =  function(self, player, skill, card)
    return card and player:hasSkill(skel.name) and #player:getCardIds(Player.Judge) > 0
  end,
})

return skel
