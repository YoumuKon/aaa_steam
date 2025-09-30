local skel = fk.CreateSkill {
  name = "steam__siji",
}

Fk:loadTranslationTable{
  ["steam__siji"] = "死寂",
  [":steam__siji"] = "你摸牌时，可以改为获得等量张【毒】，然后弃置一名其他角色等量张牌。",

  ["#steam__siji-ask"] = "死寂：你可以将摸 %arg 张牌改为获得等量张【毒】，然后弃置一名其他角色等量张牌。",
  ["#steam__siji-throw"] = "死寂：选择一名其他角色，弃置其 %arg 张牌。",
}

skel:addEffect(fk.BeforeDrawCard, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(skel.name) and target == player then
      return data.num > 0
    end
  end,
  on_cost = function (self, event, target, player, data)
    return player.room:askToSkillInvoke(player, { skill_name = skel.name, prompt = "#steam__siji-ask:::"..data.num})
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local num = data.num
    data.num = 0
    local get = {}
    local infos = {
      {Card.Spade, 4}, {Card.Spade, 5}, {Card.Spade, 9}, {Card.Spade, 10}, {Card.Club, 4},
    }
    for _ = 1, num do
      local info = table.random(infos)
      local card = room:printCard("es__poison", info[1], info[2]) -- 用间【毒】
      table.insert(get, card.id)
    end
    room:obtainCard(player, get, true, fk.ReasonJustMove, player, skel.name)
    if not player.dead then
      local targets = table.filter(room:getOtherPlayers(player, false), function (p) return not p:isNude() end)
      if #targets > 0 then
        local tos = room:askToChoosePlayers(player, { targets = targets, min_num = 1, max_num = 1,
          prompt = "#steam__siji-throw:::"..(num), skill_name = skel.name
        })
        local to = tos[1]
        if not to then return end
        local x = math.min(#to:getCardIds("he"), num)
        local cards = room:askToChooseCards(player, { target = to, min = x, max = x, flag = "he", skill_name = skel.name})
        room:throwCard(cards, skel.name, to, player)
      end
    end
  end,
})

return skel
