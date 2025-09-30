local skel = fk.CreateSkill {
  name = "steam__dachangjizaozheng",
  tags = {Skill.Compulsory},
}

Fk:loadTranslationTable{
  ["steam__dachangjizaozheng"] = "大肠激躁症",
  [":steam__dachangjizaozheng"] = "锁定技，每当一张点数为10的牌进入弃牌堆后，你获得一个随机效果的限定技〖侵心〗。",
}

skel:addEffect(fk.AfterCardsMove, {
  anim_type = "special",
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(skel.name) then return false end
    for _, move in ipairs(data) do
      if move.toArea == Card.DiscardPile then
        for _, info in ipairs(move.moveInfo) do
          if Fk:getCardById(info.cardId).number == 10 then
            return true
          end
        end
      end
    end
  end,
  trigger_times = function (self, event, target, player, data)
    local n = 0
    for _, move in ipairs(data) do
      if move.toArea == Card.DiscardPile then
        for _, info in ipairs(move.moveInfo) do
          if Fk:getCardById(info.cardId).number == 10 then
            n = n + 1
          end
        end
      end
    end
    return n
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    for loop = 0, 50 do
      local skill = loop == 0 and "" or "steam"..loop.. "__qinxin"
      if Fk.skills[skill] and not player:hasSkill(skill, true) then
        room:handleAddLoseSkills(player, skill)
        break
      end
    end
  end,
})

return skel
