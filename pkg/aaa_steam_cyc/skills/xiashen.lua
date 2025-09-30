local skel = fk.CreateSkill {
  name = "steam__xiashen",
  tags = {Skill.Compulsory},
}

Fk:loadTranslationTable{
  ["steam__xiashen"] = "狭身",
  [":steam__xiashen"] = "锁定技，弃牌阶段开始时，你摸两张牌，然后若你需要弃牌，你将手牌摸至八张。",
}

skel:addEffect(fk.EventPhaseStart, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(skel.name) and target == player and player.phase == Player.Discard
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(2, self.name)
    if player.dead then return end
    local status_skills = Fk:currentRoom().status_skills[MaxCardsSkill] or Util.DummyTable
    -- 不计入手牌上限的牌
    local excludeCards = table.filter(player:getCardIds{ Player.Hand }, function(id)
      local card = Fk:getCardById(id)
      for _, skill in ipairs(status_skills) do
        if skill:excludeFrom(player, card) then
          return true
        end
      end
    end)
    if (player:getHandcardNum() - #excludeCards) > player:getMaxCards() then
      local x = 8 - player:getHandcardNum()
      if x > 0 then
        player:drawCards(x, self.name)
      end
    end
  end,
})

return skel
