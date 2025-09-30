local skel = fk.CreateSkill {
  name = "steam__quanlue",
  tags = {Skill.Compulsory},
}

Fk:loadTranslationTable{
  ["steam__quanlue"] = "权略",
  [":steam__quanlue"] = "锁定技，造成伤害的普通锦囊牌结算后，你将手牌摸至X张（X为此结算中受到伤害的角色数，至多为5）。",

  ["$steam__quanlue1"] = "败则一身不保，胜则无威不加！",
  ["$steam__quanlue2"] = "敌人已乱，主公正可乘势击之！",
}

skel:addEffect(fk.CardUseFinished, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(skel.name) and data.card:isCommonTrick() and data.damageDealt then
      local n = 0
      for _, _ in pairs(data.damageDealt) do
        n = n + 1
      end
      n = math.min(n, 5) - player:getHandcardNum()
      return n > 0
    end
  end,
  on_use = function(self, event, target, player, data)
    local n = 0
    for _, _ in pairs(data.damageDealt) do
      n = n + 1
    end
    n = math.min(n, 5) - player:getHandcardNum()
    if n > 0 then
      player:drawCards(n, skel.name)
    end
  end,
})



return skel
