local skel = fk.CreateSkill {
  name = "steam__subei",
}

Fk:loadTranslationTable{
  ["steam__subei"] = "肃备",
  [":steam__subei"] = "出牌阶段限一次，你可以重铸至多你体力上限张牌；出牌阶段，若你以此重铸过牌且手中的伤害牌数为X，你可展示所有手牌并令此技能本阶段改为限两次（X为你上次以此重铸的牌数）。",

  ["#steam__subei"] = "肃备：你可以重铸至多%arg张牌",
  ["#steam__subei0"] = "肃备：你可以展示所有手牌，重置此技能(限一次！)",
  ["@steam__subei-phase"] = "肃备",
}

skel:addEffect("active", {
  anim_type = "drawcard",
  target_num = 0,
  prompt = function (self, player)
    if player:usedSkillTimes(skel.name, Player.HistoryPhase) == 0 then
      return "#steam__subei:::"..player.maxHp
    else
      return "#steam__subei0"
    end
  end,
  can_use = function (self, player)
    if player:usedSkillTimes(skel.name, Player.HistoryPhase) == 0 then
      return true
    elseif player:getMark("steam__subei_rest-phase") == 0 then
      return #table.filter(player:getCardIds("h"), function (id)
        return Fk:getCardById(id).is_damage_card
      end) == player:getMark("@steam__subei-phase")
    end
  end,
  card_filter = function (self, player, to_select, selected)
    if player:usedSkillTimes(skel.name, Player.HistoryPhase) == 0 then
      return #selected < player.maxHp
    end
    return false
  end,
  feasible = function (self, player, selected, selected_cards)
    if player:usedSkillTimes(skel.name, Player.HistoryPhase) == 0 then
      return #selected_cards > 0
    else
      return #selected_cards == 0
    end
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    if #effect.cards > 0 then
      room:setPlayerMark(player, "@steam__subei-phase", #effect.cards)
      room:recastCard(effect.cards, player, skel.name)
    else
      room:addPlayerMark(player, "steam__subei_rest-phase")
      player:setSkillUseHistory(skel.name, 0, Player.HistoryPhase)
      player:showCards(player:getCardIds("h"))
    end
  end,
})

return skel
