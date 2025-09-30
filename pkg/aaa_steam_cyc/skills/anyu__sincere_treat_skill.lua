local skill = fk.CreateSkill {
  name = "steam_anyu__sincere_treat_skill",
}

Fk:loadTranslationTable{
  ["#sincere_treat-give"] = "推心置腹：请交给 %dest %arg张手牌",
  ["steam_anyu__sincere_treat_skill"] = "推心置腹",
}


skill:addEffect("cardskill", {
  prompt = "#sincere_treat_skill",
  distance_limit = 1,
  target_num = 1,
  mod_target_filter = function(self, player, to_select, selected, card, extra_data)
    return to_select ~= player and
      not (to_select:isAllNude() or
        (not (extra_data and extra_data.bypass_distances) and not self:withinDistanceLimit(player, false, card, to_select)))
  end,
  target_filter = Util.CardTargetFilter,
  on_effect = function(self, room, effect)
    local player = effect.from
    local target = effect.to
    if player.dead or target.dead or target:isAllNude() then return end

    local exRreyNum = (effect.extra_data or Util.DummyTable).steam__anyu_prey or 0 -- 额外获得数
    local cards = room:askToChooseCards(player, {
      target = target,
      min = 1,
      max = 2 + exRreyNum,
      flag = "hej",
      skill_name = skill.name,
    })
    room:obtainCard(player, cards, false, fk.ReasonPrey, player, skill.name)
    if not player.dead and not target.dead or player:isKongcheng() then
      local exBackNum = (effect.extra_data or Util.DummyTable).steam__anyu_back or 0 -- 减少还给数
      -- 注意，获得牌大于2张时，还给牌数减少额外获得牌数，不大于2张时，视为未额外获得牌
      local backNum = math.max(2, #cards - exRreyNum) - exBackNum -- 理应返回牌数
      local n = math.min(backNum, player:getHandcardNum()) -- 实际返回牌数
      if n < 1 then return end
      cards = room:askToCards(player, {
        min_num = n,
        max_num = n,
        include_equip = false,
        skill_name = skill.name,
        prompt = "#sincere_treat-give::"..target.id..":"..n,
        cancelable = false,
      })
      room:obtainCard(target, cards, false, fk.ReasonGive, player, skill.name)
    end
  end,
})

return skill
