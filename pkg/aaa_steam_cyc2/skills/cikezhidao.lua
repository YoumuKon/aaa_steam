local skel = fk.CreateSkill {
  name = "steam__cikezhidao",
}

Fk:loadTranslationTable{
  ["steam__cikezhidao"] = "刺客之道",
  [":steam__cikezhidao"] = "出牌阶段每种花色限一次，你可以重铸一张牌，移出一名邻家直到回合结束。",

  ["#steam__cikezhidao"] = "刺客之道：重铸一张牌，移出一名邻家直到回合结束",
  ["@steam__cikezhidao-phase"] = "刺道",

  ["$steam__cikezhidao1"] = "又是一具阴沟里的尸体。",
  ["$steam__cikezhidao2"] = "无处可藏！",
}

local DIY = require "packages.diy_utility.diy_utility"

skel:addEffect("active", {
  anim_type = "control",
  prompt = "#steam__cikezhidao",
  card_num = 1,
  target_num = 1,
  card_filter = function (self, player, to_select, selected)
    local suit = Fk:getCardById(to_select):getSuitString(true)
    return #selected == 0 and not table.contains(player:getTableMark("@steam__cikezhidao-phase"), suit)
    and suit ~= "log_nosuit"
  end,
  target_filter = function (self, player, to, selected)
    return #selected == 0 and (player:getNextAlive() == to or to:getNextAlive() == player) and not to:isRemoved()
  end,
  can_use = function(self, player)
    return #player:getTableMark("@steam__cikezhidao-phase") < 4
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local to = effect.tos[1]
    local suit = Fk:getCardById(effect.cards[1]):getSuitString(true)
    room:addTableMark(player, "@steam__cikezhidao-phase", suit)
    room:recastCard(effect.cards, player, self.name)
    if to.dead then return end
    DIY.removePlayer(to, "-turn")
  end,
})

skel:addLoseEffect(function (self, player, is_death)
  player.room:setPlayerMark(player, "@steam__cikezhidao-phase", 0)
end)

return skel
