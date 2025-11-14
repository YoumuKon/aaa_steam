local DIY = require "packages.diy_utility.diy_utility"

local skel = fk.CreateSkill {
  name = "steam__huanfub",
  tags = {DIY.ReadySkill},
}

Fk:loadTranslationTable{
  ["steam__huanfub"] = "还赴",
  [":steam__huanfub"] = "蓄势技，初始行置。轮次结束时，你可以令X号位获得一张【无懈可击】、使用一张【桃】、装备一张【护心镜】（X为首次重置时弃牌的花色数）。",

  ["#steam__huanfub"] = "还赴：你可以令 %src 获得【无懈可击】、使用【桃】、装备【护心镜】",

  ["$steam__huanfub1"] = "",
  ["$steam__huanfub2"] = "",
}

skel:addEffect(fk.RoundEnd, {
  anim_type = "big",
  can_trigger = function (self, event, target, player, data)
    return player:hasSkill(skel.name)
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local to = table.find(room.alive_players, function (p)
      return p.seat == player:getMark(skel.name)
    end)
    if not to then return false end
    if room:askToSkillInvoke(player, {skill_name = skel.name, prompt = "#steam__huanfub:"..to.id }) then
      event:setCostData(self, {tos = {to} })
      return true
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local to = event:getCostData(self).tos[1]
    local cid = room:printCard("nullification", Card.Club, 13).id
    room:obtainCard(to, cid, true, fk.ReasonJustMove, to, skel.name)
    if to.dead then return end
    local peach = Fk:cloneCard("peach")
    peach.skillName = skel.name
    if to:canUseTo(peach, to) then
      room:useCard{from = to, tos = {to}, card = peach}
    end
    if to.dead then return end
    local card = room:printCard("breastplate", Card.Club, 1)
    if to:canMoveCardIntoEquip(card.id, true) then
      room:moveCardIntoEquip(to, card.id, skel.name, true, to)
    end
  end,
})

skel:addEffect(DIY.SkillReadyFinish, {
  can_refresh = function (self, event, target, player, data)
    return target == player and data.skill.name == skel.name and data.cards and player:getMark(skel.name) == 0
  end,
  on_refresh = function (self, event, target, player, data)
    local suits = {}
    for _, id in ipairs(data.cards) do
      table.insertIfNeed(suits, Fk:getCardById(id).suit)
    end
    --DIY.setReadyCap(player, skel.name, #suits)
    player.room:setPlayerMark(player, skel.name, #suits)
  end,
})

skel:addAcquireEffect(function (self, player, is_start)
  DIY.setReadySkill(player, skel.name, skel.name, true)
end)

return skel
