local skel = fk.CreateSkill {
  name = "steam__essence_theft",
}

Fk:loadTranslationTable{
  ["steam__essence_theft"] = "摄魂夺魄",
  [":steam__essence_theft"] = "出牌阶段，你可以用X张<font color='red'>♥</font>牌交换一名其他角色的X+1张牌。（X为本回合本技能发动次数）。",

  ["#steam__essence_theft"] = "摄魂夺魄：你可以用%arg张<font color='red'>♥</font>牌交换一名其他角色的%arg2张牌",
  ["#steam__essence_theft-prey"] = "摄魂夺魄：获得 %dest 的%arg张牌",

  ["$steam__essence_theft1"] = "你喜欢吗?",
  ["$steam__essence_theft2"] = "mua~",
}

skel:addEffect("active", {
  anim_type = "control",
  card_num = function (self, player)
    return player:usedSkillTimes(self.name, Player.HistoryTurn) + 1
  end,
  target_num = 1,
  prompt = function (self, player)
    local n = player:usedSkillTimes(self.name, Player.HistoryTurn) + 1
    return "#steam__essence_theft:::"..n..":"..(n + 1)
  end,
  can_use = Util.TrueFunc,
  card_filter = function (self, player, to_select, selected)
    return #selected < player:usedSkillTimes(self.name, Player.HistoryTurn) + 1 and Fk:getCardById(to_select).suit == Card.Heart
  end,
  target_filter = function (self, player, to_select, selected)
    return #selected == 0 and to_select ~= player and not to_select:isNude()
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    local n = player:usedSkillTimes(self.name, Player.HistoryTurn) + 1
    local cards = {}
    if #target:getCardIds("he") > n then
      cards = room:askToChooseCards(player, {
        target = target, min = n, max = n, skill_name = skel.name, flag = "he",
        prompt = "#steam__essence_theft-prey::"..target.id..":"..n
      })
    else
      cards = target:getCardIds("he")
    end
    room:moveCards({
      from = player,
      to = target,
      ids = effect.cards,
      toArea = Card.PlayerHand,
      moveReason = fk.ReasonExchange,
      skillName = self.name,
      proposer = player,
      moveVisible = false,
    },
    {
      from = target,
      to = player,
      ids = cards,
      toArea = Card.PlayerHand,
      moveReason = fk.ReasonExchange,
      skillName = self.name,
      proposer = player,
      moveVisible = false,
    })
  end,
})

return skel
