local skel = fk.CreateSkill {
  name = "steam__lianxi",
  tags = {Skill.Compulsory},
}

Fk:loadTranslationTable{
  ["steam__lianxi"] = "联席",
  [":steam__lianxi"] = "锁定技，其他角色于摸牌阶段外摸牌后，若其手牌数为场上唯一最多，你摸一张牌。",
}

skel:addEffect(fk.AfterCardsMove, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(skel.name) then return false end
    local tos = {}
    for _, move in ipairs(data) do
      if move.to and move.to ~= player and move.toArea == Player.Hand and move.to:isAlive()
        and move.to.phase ~= Player.Draw then
        if table.find(move.moveInfo, function (info) return info.fromArea == Card.DrawPile end) then
          table.insertIfNeed(tos, move.to)
        end
      end
    end
    if #tos == 1 then
      local to = tos[1]
      if table.every(player.room.alive_players, function (p)
        return p == to or p:getHandcardNum() < to:getHandcardNum()
      end) then
        event:setCostData(self, {tos = tos})
        return true
      end
    end
  end,
  on_use = function (self, event, target, player, data)
    player:drawCards(1, skel.name)
  end,
})

return skel
