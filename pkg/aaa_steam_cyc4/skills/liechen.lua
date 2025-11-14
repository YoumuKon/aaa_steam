
local DIY = require "packages.diy_utility.diy_utility"

local liechen = fk.CreateSkill {
  name = "steam__liechen",
  tags = { DIY.ReadySkill },
}

Fk:loadTranslationTable{
  ["steam__liechen"] = "裂辰",
  [":steam__liechen"] = "蓄势技，出牌阶段，你可以摸两张牌并获得两个触发类别改为与所获牌类别一一对应的〖执义〗。",

  ["#steam__liechen"] = "裂辰：摸两张牌，获得对应的两个“执义”",

  ["$steam__liechen1"] = "真可怜，今天轮到你倒霉。",
  ["$steam__liechen2"] = "砰！是谁告诉你，我每次都会倒数的？",
}

liechen:addEffect("active", {
  anim_type = "drawcard",
  prompt = "#steam__liechen",
  card_num = 0,
  target_num = 0,
  can_use = Util.TrueFunc,
  on_use = function (self, room, effect)
    local player = effect.from
    local cards = player:drawCards(2, liechen.name)
    if not player.dead and #cards > 0 then
      for _, id in ipairs(cards) do
        local type = Fk:getCardById(id):getTypeString()
        for i = 1, 30 do
          local name = "steam__zhiyi"..i
          if not player:hasSkill(name, true) then
            room:setPlayerMark(player, name, type)
            room:handleAddLoseSkills(player, name)
            break
          end
        end
      end
    end
  end,
})

return liechen
