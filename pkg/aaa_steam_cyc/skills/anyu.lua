local skel = fk.CreateSkill {
  name = "steam__anyu",
}

Fk:loadTranslationTable{
  ["steam__anyu"] = "暗誉",
  [":steam__anyu"] = "出牌阶段限一次，你可以重铸任意张点数和为13的牌，视为对一名其他角色使用一张【推心置腹】，你可以先与其同时选择一项：1.你多获得其一张牌；2.你少还给其一张牌。若双方选择相同，则你失去本技能，双方翻面。",

  ["#steam__anyu"] = "暗誉：重铸点数和为13的牌，使用一张【推心置腹】（还差：%arg点！）",
  ["#steam__anyu-ask"] = "暗誉：你可以与其同时选一项效果，若相同，则一起翻面",
  ["steam__anyu_prey"] = "使用者多获得一张牌",
  ["steam__anyu_back"] = "使用者少还给一张牌",
  ["#steam__anyu-choice"] = "你须与对方同时选一项，若选择相同则均翻面",

  ["$steam__anyu"] = "德莱尼拒绝了力量，真是愚蠢。",
}

skel:addEffect("active", {
  anim_type = "control",
  min_card_num = 1,
  target_num = 1,
  prompt = function (self, player, selected_cards, selected_targets)
    local rest = 13
    for _, id in ipairs(selected_cards) do
      rest = rest - Fk:getCardById(id).number
    end
    return "#steam__anyu:::"..rest
  end,
  card_filter = function (self, player, to_select, selected)
    local n = 0
    for _, id in ipairs(selected) do
      n = n + Fk:getCardById(id).number
    end
    return n + Fk:getCardById(to_select).number <= 13
  end,
  target_filter = function (self, player, to, selected, selected_cards)
    return #selected == 0 and player ~= to and not player:isProhibited(to, Fk:cloneCard("sincere_treat"))
  end,
  can_use = function(self, player)
    return player:usedSkillTimes(skel.name, Player.HistoryPhase) == 0
  end,
  times = function (self, player)
    return 1 - player:usedSkillTimes(skel.name, Player.HistoryPhase)
  end,
  feasible = function (self, player, selected, selected_cards, card)
    if #selected ~= 1 then return false end
    local n = 0
    for _, id in ipairs(selected_cards) do
      n = n + Fk:getCardById(id).number
    end
    return n == 13
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local to = effect.tos[1]
    room:recastCard(effect.cards, player, skel.name)
    if player.dead or to.dead then return end
    local card = Fk:cloneCard("sincere_treat")
    card.skillName = skel.name
    local extra_data = {}
    local same
    if room:askToSkillInvoke(player, { skill_name = skel.name, prompt = "#steam__anyu-ask"}) then
      local ret = room:askToJointChoice(player, {
        players = {player, to}, choices = {"steam__anyu_prey", "steam__anyu_back"}, skill_name = skel.name, prompt = "#steam__anyu-choice"
      })
      for _, choice in pairs(ret) do
        extra_data[choice] = (extra_data[choice] or 0) + 1
        if same then
          same = (same == choice)
        else
          same = choice
        end
      end
    end
    card.skill = Fk.skills["steam_anyu__sincere_treat_skill"]
    room:useCard{ from = player, tos = {to}, card = card, extra_data = extra_data }
    if same then
      room:handleAddLoseSkills(player, "-"..skel.name)
      if player:isAlive() then
        player:turnOver()
      end
      if to:isAlive() then
        to:turnOver()
      end
    end
  end,
})



return skel
