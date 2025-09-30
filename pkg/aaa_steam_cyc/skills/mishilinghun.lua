local skel = fk.CreateSkill {
  name = "steam__mishilinghun",
  tags = {Skill.Compulsory},
}

Fk:loadTranslationTable{
  ["steam__mishilinghun"] = "迷失灵魂",
  [":steam__mishilinghun"] = "锁定技，你或持有你武将牌的角色受到牌的伤害后，复位你的武将牌，然后你摸两张牌。",
}

skel:addEffect(fk.Damaged, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(skel.name) and data.card then
      local owners = {}
      for _, p in ipairs(player.room.alive_players) do
        if table.find(p:getCardIds("h"), function(id) return Fk:getCardById(id):getMark("forgottencard_from") == player.id end) then
          table.insert(owners, p)
        end
      end
      if #owners > 0 then
        return target == player or table.contains(owners, target)
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local moves = {}
    for _, p in ipairs(room.alive_players) do
      local cards = table.filter(p:getCardIds("h"), function(id) return Fk:getCardById(id):getMark("forgottencard_from") == player.id end)
      if #cards > 0 then
        table.insert(moves, {
          ids = cards,
          from = p,
          toArea = Card.Void,
          moveReason = fk.ReasonJustMove,
          skillName = self.name,
          proposer = player,
        })
        room:doIndicate(player, {p})
      end
    end
    room:moveCards(table.unpack(moves))
    if not player.dead then
      player:drawCards(2, skel.name)
    end
  end,
})



return skel
