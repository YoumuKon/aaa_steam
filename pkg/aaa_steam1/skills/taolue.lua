local skel = fk.CreateSkill {
  name = "steam__taolue",
  tags = {Skill.Switch},
}

Fk:loadTranslationTable{
  ["steam__taolue"] = "韬略",
  [":steam__taolue"] = "转换技，出牌阶段，①你可以弃置一张牌并视为使用一张【声东击西】。②你可以弃置两张牌并令一名角色视为使用一张【树上开花】（若选择你，本轮该转换项失效）。",

  ["#steam__taolue-yang"] = "韬略：弃置一张牌并视为使用一张【声东击西】",
  ["#steam__taolue-yin"] = "韬略：弃置两张牌并令一名角色视为使用一张【树上开花】",
}

skel:addEffect("active", {
  anim_type = "switch",
  switch_skill_name = "steam__taolue",
  min_target_num = 1,
  prompt = function (self, player)
    return "#steam__taolue-"..player:getSwitchSkillState(skel.name, false, true)
  end,
  card_filter = function (self, player, to_select, selected)
    if player:prohibitDiscard(Fk:getCardById(to_select)) then return false end
    if player:getSwitchSkillState(skel.name) == fk.SwitchYang then
      return #selected < 1
    else
      return #selected < 2
    end
  end,
  target_filter = function (self, player, to, selected, selected_cards)
    if player:getSwitchSkillState(skel.name) == fk.SwitchYang then
      if #selected_cards ~= 1 then return false end
      local card = Fk:cloneCard("diversion")
      card:addSubcards(selected_cards)
      card.skillName = skel.name
      local max_target_num = card.skill:getMaxTargetNum(player, card)
      return not player:prohibitUse(card) and not player:isProhibited(to, card) and #selected < max_target_num
      and card.skill:modTargetFilter(player, to, selected, card, {bypass_distances = true})
    else
      if #selected_cards ~= 2 then return false end
      local card = Fk:cloneCard("bogus_flower")
      card:addSubcards(selected_cards)
      card.skillName = skel.name
      return not to:prohibitUse(card) and not to:isProhibited(to, card)
    end
  end,
  can_use = function(self, player)
    return not (player:getSwitchSkillState(skel.name) == fk.SwitchYin and player:getMark("steam__taolue_yinfail-round") ~= 0)
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    room:throwCard(effect.cards, skel.name, player, player)
    if player:getSwitchSkillState(skel.name, true) == fk.SwitchYang then
      if not player.dead then
        room:useVirtualCard("diversion", nil, player, effect.tos, skel.name)
      end
    else
      local to = effect.tos[1]
      if not to.dead then
        room:useVirtualCard("bogus_flower", nil, to, to, skel.name)
        if to == player then
          room:setPlayerMark(player, "steam__taolue_yinfail-round", 1)
        end
      end
    end
  end,
})



return skel
