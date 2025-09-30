local skel = fk.CreateSkill {
  name = "steam__paiyi",
}

Fk:loadTranslationTable{
  ["steam__paiyi"] = "排异",
  [":steam__paiyi"] = "出牌阶段限一次，你可以将一张“权”置入弃牌堆，令一名角色摸两张牌，然后若该角色的手牌数大于你，你对其造成1点伤害。",

  ["steam_quan"] = "权",
  ["#steam__paiyi"] = "排异：令一名角色摸两张牌，然后若其手牌数大于你，对其造成1点伤害",
}

skel:addEffect("active", {
  anim_type = "control",
  card_num = 1,
  target_num = 1,
  expand_pile = "steam_quan",
  prompt = "#steam__paiyi",
  times = function (self, player)
    return 1 - player:usedSkillTimes(skel.name, Player.HistoryPhase)
  end,
  can_use = function(self, player)
    return #player:getPile("steam_quan") > 0 and player:usedSkillTimes(skel.name, Player.HistoryPhase) == 0
  end,
  target_filter = function(self, _, _, selected)
    return #selected == 0
  end,
  card_filter = function (self, player, to_select, selected)
    return #selected == 0 and player:getPileNameOfId(to_select) == "steam_quan"
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    room:moveCards({
      from = player,
      ids = effect.cards,
      toArea = Card.DiscardPile,
      moveReason = fk.ReasonPutIntoDiscardPile,
      skillName = skel.name,
    })
    if target.dead then return end
    target:drawCards(2, skel.name)
    if target:getHandcardNum() > player:getHandcardNum() then
      room:damage{
        from = player,
        to = target,
        damage = 1,
        skillName = skel.name,
      }
    end
  end,
})

return skel
