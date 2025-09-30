local skel = fk.CreateSkill {
  name = "steam__yelanyao",
}

Fk:loadTranslationTable{
  ["steam__yelanyao"] = "夜阑谣",
  [":steam__yelanyao"] = "出牌阶段限一次，你可以选择两名武将牌状态不同的角色，令其中一名角色获得另一名角色一张牌，然后失去牌的角色摸一张牌。",

  ["steam__yelanyao_get"] = "获得牌",
  ["steam__yelanyao_lose"] = "失去牌",
  ["#steam__yelanyao"] = "夜阑谣：选择两名武将牌状态不同的角色，第一个角色获得第二个角色的一张牌，再令后者摸一张牌",

  ["$steam__yelanyao1"] = "都去睡觉吧~",
  ["$steam__yelanyao2"] = "该睡觉咯~",
}

skel:addEffect("active", {
  anim_type = "control",
  card_num = 0,
  target_num = 2,
  card_filter = Util.FalseFunc,
  prompt = "#steam__yelanyao",
  target_filter = function (self, player, to, selected, selected_cards, card, extra_data)
    if #selected == 0 then return true end
    if #selected == 1 then
      local first = selected[1]
      return (to.chained ~= first.chained or to.faceup ~= first.faceup) and not to:isNude()
    end
  end,
  target_tip = function (self, player, to_select, selected, selected_cards, card, selectable, extra_data)
    if to_select == selected[1] then
      return { {content = "steam__yelanyao_get" , type = "normal"} }
    end
    if (#selected == 1 and selectable) or to_select == selected[2] then
      return { {content = "steam__yelanyao_lose", type = "warning"} }
    end
  end,
  times = function (self, player)
    return 1 - player:usedSkillTimes(skel.name, Player.HistoryPhase)
  end,
  can_use = function(self, player)
    return player:usedSkillTimes(skel.name, Player.HistoryPhase) == 0
  end,
  on_use = function(self, room, effect)
    local getter = effect.tos[1]
    local loser = effect.tos[2]
    local cid = room:askToChooseCard(getter, { target = loser, flag = "he", skill_name = skel.name})
    room:obtainCard(getter, cid, false, fk.ReasonPrey, getter, skel.name)
    if not loser.dead then
      loser:drawCards(1, skel.name)
    end
  end,
})



return skel
