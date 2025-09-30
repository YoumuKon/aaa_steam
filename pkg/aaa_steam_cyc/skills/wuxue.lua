local skel = fk.CreateSkill {
  name = "steam__wuxue",
  tags = {Skill.Compulsory},
}

Fk:loadTranslationTable{
  ["steam__wuxue"] = "污血",
  [":steam__wuxue"] = "锁定技，回合结束时，你获得一张【毒】。你扣减体力后，摸一张牌。",
}

skel:addEffect(fk.TurnEnd, {
  anim_type = "negative",
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(skel.name) and target == player then
      return true
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local infos = {
      {Card.Spade, 4}, {Card.Spade, 5}, {Card.Spade, 9}, {Card.Spade, 10}, {Card.Club, 4},
    }
    local info = table.random(infos)
    -- 用间篇
    local card = room:printCard("es__poison", info[1], info[2])
    room:obtainCard(player, card, true, fk.ReasonJustMove, player, skel.name)
  end,
})

skel:addEffect(fk.HpChanged, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(skel.name) and target == player then
      return data.num < 1
    end
  end,
  on_use = function (self, event, target, player, data)
    player:drawCards(1, skel.name)
  end,
})

return skel
