local skel = fk.CreateSkill {
  name = "steam__xunai",
}

Fk:loadTranslationTable{
  ["steam__xunai"] = "寻爱",
  [":steam__xunai"] = "出牌阶段，你可以用一张黑色牌交换一名其他角色的一张牌。若你未换得红色牌，你与其各失去1点体力，然后结束本回合。",

  ["#steam__xunai"] = "寻爱：可以用一张黑色牌交换一名其他角色的一张牌，若未获得红牌，你与其失去体力",
}

skel:addEffect("active", {
  anim_type = "support",
  prompt = "#steam__xunai",
  card_num = 1,
  target_num = 1,
  card_filter = function (self, player, to_select, selected)
    return #selected == 0 and Fk:getCardById(to_select).color == Card.Black
  end,
  target_filter = function (self, player, to, selected)
    return #selected == 0 and player ~= to and not to:isNude()
  end,
  can_use = function(self, player)
    return not player:isNude()
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local to = effect.tos[1]
    local cid = room:askToChooseCard(player, { target = to, flag = "he", skill_name = self.name})
    local isRed = Fk:getCardById(cid).color == Card.Red
    room:swapCards(player, { {player, effect.cards}, {to, {cid}} }, self.name)
    if not isRed then
      if player:isAlive() then
        room:loseHp(player, 1, self.name)
      end
      if to:isAlive() then
        room:loseHp(to, 1, self.name)
      end
      room:endTurn()
    end
  end,
})

return skel
