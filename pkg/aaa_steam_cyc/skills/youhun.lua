local skel = fk.CreateSkill {
  name = "steam__youhun",
  tags = {Skill.Compulsory},
}

Fk:loadTranslationTable{
  ["steam__youhun"] = "幽魂",
  [":steam__youhun"] = "锁定技，你的手牌上限为4。你使用基本牌无距离限制。",
}

skel:addEffect("maxcards", {
  fixed_func = function(self, player)
    if player:hasSkill(skel.name) then
      return 4
    end
  end,
})

skel:addEffect("targetmod", {
  bypass_distances = function(self, player, skill, card)
    return player and player:hasSkill(skel.name) and card and card.type == Card.TypeBasic
  end,
})

return skel
