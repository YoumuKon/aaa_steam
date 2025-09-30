local skel = fk.CreateSkill {
  name = "steam__shangdiankaimen",
  attached_skill_name = "steam__shangdiankaimen&",
}

Fk:loadTranslationTable{
  ["steam__shangdiankaimen"] = "商店开门",
  [":steam__shangdiankaimen"] = "每名角色的出牌阶段限一次，其可以交给你X张牌，获得展柜内一张牌。(X为展柜内牌数)",

  ["#steam__shangdiankaimen"] = "商店开门：你可以获得“展柜”内一张牌",
  ["#steam__shangdiankaimen-get"] = "商店开门：选择一张获得！",

  ["#steam__shangdiankaimen-other"] = "你可以交给店长X张牌，获得其展柜内一张牌。(X为展柜内牌数)",
  ["steam__shangdiankaimen&"] = "购买",
  [":steam__shangdiankaimen&"] = "出牌阶段限一次，你可以交给拥有“商店开门”的角色X张牌，获得其展柜内一张牌。(X为展柜内牌数)",
}

skel:addEffect("active", {
  anim_type = "drawcard",
  card_num = 1,
  target_num = 0,
  prompt = "#steam__shangdiankaimen",
  expand_pile = "keeper_showcase",
  card_filter = function (self, player, to_select, selected)
    return #selected < 1 and player:getPileNameOfId(to_select) == "keeper_showcase"
  end,
  times = function (self, player)
    return 1 - player:usedSkillTimes(self.name, Player.HistoryPhase)
  end,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0 and #player:getPile("keeper_showcase") > 0
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    room:obtainCard(player, effect.cards, true, fk.ReasonJustMove, player, self.name)
  end,
})

local skel2 = fk.CreateSkill {
  name = "steam__shangdiankaimen&",
}

skel2:addEffect("active", {
  anim_type = "drawcard",
  min_card_num = 1,
  target_num = 1,
  prompt = "#steam__shangdiankaimen-other",
  times = function (self, player)
    return 1 - player:usedSkillTimes(self.name, Player.HistoryPhase)
  end,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
    and table.find(Fk:currentRoom().alive_players, function (p)
      return p:hasSkill(skel.name) and p ~= player and #p:getPile("keeper_showcase") > 0
    end)
  end,
  card_filter = function (self, player, to_select, selected)
    local max = 0
    for _, p in ipairs(Fk:currentRoom().alive_players) do
      if p:hasSkill(skel.name) and p ~= player then
        max = math.max(max, #p:getPile("keeper_showcase"))
      end
    end
    return #selected < max
  end,
  target_filter = function (self, player, to, selected, selected_cards)
    return #selected_cards > 0 and to ~= player and to:hasSkill(skel.name)
    and #to:getPile("keeper_showcase") == #selected_cards
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local to = effect.tos[1]
    room:obtainCard(to, effect.cards, true, fk.ReasonGive, player, skel.name)
    if player.dead or #to:getPile("keeper_showcase") == 0 then return end
    local card = room:askToChooseCard(player, {
      target = to, skill_name = skel.name, prompt = "#steam__shangdiankaimen-get",
      flag = { card_data = { { "steam__shangdiankaimen&", to:getPile("keeper_showcase") } } },
    })
    room:obtainCard(player, card, true, fk.ReasonPrey, player, skel.name)
  end,
})

return {skel, skel2}
