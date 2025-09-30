local skel = fk.CreateSkill {
  name = "steam__qingzhan",
}

Fk:loadTranslationTable{
  ["steam__qingzhan"] = "请战",
  [":steam__qingzhan"] = "每轮开始时，你可以减1点体力上限，随机使用一张武器牌，然后摸一张牌。",

  ["#steam__qingzhan"] = "请战：你可减1点体力上限，用一张武器牌，摸一张牌！",

  ["$steam__qingzhan"] = "国服韩信，请战！！！！！",
}

skel:addEffect(fk.RoundStart, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return player.maxHp > 0 and player:hasSkill(skel.name) and #player:getAvailableEquipSlots(Card.SubtypeWeapon) > 0
    and #player.room:getCardsFromPileByRule(".|.|.|.|.|weapon") > 0
  end,
  on_cost = function (self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {skill_name = skel.name, prompt = "#steam__qingzhan"})
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:changeMaxHp(player, -1)
    local cids = room:getCardsFromPileByRule(".|.|.|.|.|weapon")
    if #cids > 0 and not player.dead then
      local card = Fk:getCardById(cids[1])
      if player:canUseTo(card, player) then
        room:useCard({
          from = player,
          tos = {player},
          card = card,
        })
      else
        room:obtainCard(player, card, true, fk.ReasonJustMove, player, skel.name)
      end
    end
    if not player.dead then
      player:drawCards(1, skel.name)
    end
  end,
})



return skel
