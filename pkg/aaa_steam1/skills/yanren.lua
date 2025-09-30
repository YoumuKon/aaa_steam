local skel = fk.CreateSkill {
  name = "steam__yanren",
  max_branches_use_time = {
    ["draw"] = { [Player.HistoryPhase] = 1 },
    ["yiji"] = { [Player.HistoryPhase] = 1 },
  }
}

Fk:loadTranslationTable{
  ["steam__yanren"] = "宴仁",
  [":steam__yanren"] = "出牌阶段各限一次，你可以：1.摸三张牌，然后分配至少半数手牌；2.分配至少半数手牌，然后摸三张牌。",

  ["#steam__yanren"] = "宴仁：选择一项",
  ["steam__yanren_draw"] = "摸三张牌，分配至少半数手牌",
  ["steam__yanren_yiji"] = "分配至少半数手牌，摸三张牌",
  ["#steam__yanren-give"] = "宴仁：分配至少 %arg 张手牌",

  ["$steam__yanren1"] = "我将丹心酿烈酒，且取一觞慰风尘。",
  ["$steam__yanren2"] = "余酒尽倾江海中，与君共宴天下人。",
}

skel:addEffect("active", {
  anim_type = "support",
  card_num = 0,
  target_num = 0,
  prompt = "#steam__yanren",
  interaction = function(self, player)
    local all_choices = {"steam__yanren_draw", "steam__yanren_yiji"}
    local choices = {}
    if skel:withinBranchTimesLimit(player, "draw", Player.HistoryPhase) then
      table.insert(choices, "steam__yanren_draw")
    end
    if skel:withinBranchTimesLimit(player, "yiji", Player.HistoryPhase) then
      table.insert(choices, "steam__yanren_yiji")
    end
    return UI.ComboBox { choices = choices, all_choices = all_choices }
  end,
  can_use = function(self, player)
    return skel:withinBranchTimesLimit(player, "draw", Player.HistoryPhase)
    or skel:withinBranchTimesLimit(player, "yiji", Player.HistoryPhase)
  end,
  card_filter = function (self, player, to_select, selected)
    return self.interaction.data == "steam__yanren_yiji" and table.contains(player.player_cards[Player.Hand], to_select)
  end,
  history_branch = function(self, player, data)
    if data.interaction_data == nil then return nil end
    local choice = string.sub(data.interaction_data, -4, -1)
    return choice
  end,
  feasible = function (self, player, selected, selected_cards)
    if self.interaction.data == "steam__yanren_draw" then
      return true
    elseif self.interaction.data == "steam__yanren_yiji" then
      return #selected_cards >= player:getHandcardNum() / 2
    end
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local choice = effect.interaction_data
    if choice == "steam__yanren_draw" then
      player:drawCards(3, skel.name)
      if player.dead or player:getHandcardNum() < 2 or #room:getOtherPlayers(player) == 0 then return end
      local n = (player:getHandcardNum() + 1) // 2
      room:askToYiji(player, {
        cards = player:getCardIds("h"), targets = room:getOtherPlayers(player), skill_name = skel.name,
        min_num = n, max_num = 999, prompt = "#steam__yanren-give:::"..n
      })
    else
      local n = (player:getHandcardNum() + 1) // 2
      local targets = room:getOtherPlayers(player, false)
      if #targets == 0 then return end
      room:askToYiji(player, {
        cards = effect.cards, targets = targets, skill_name = skel.name, min_num = #effect.cards, max_num = #effect.cards,
        prompt = "#steam__yanren-give:::"..n
      })
      if player.dead then return end
      player:drawCards(3, skel.name)
    end
  end,
})

return skel
