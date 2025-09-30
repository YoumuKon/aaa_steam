local skel = fk.CreateSkill {
  name = "steam__tandewuyan",
}

Fk:loadTranslationTable{
  ["steam__tandewuyan"] = "贪得无厌",
  [":steam__tandewuyan"] = "你需要使用展柜内的一张牌时，可以进行一次【浮雷】判定并使用之。",

  ["#steam__tandewuyan"] = "贪得无厌：你可以使用“展柜”中的一张牌。但须先进行【浮雷】判定！",
  [""] = "",
  [""] = "",
  [""] = "",
}

skel:addEffect("viewas", {
  anim_type = "drawcard",
  pattern = ".",
  prompt = "#steam__tandewuyan",
  expand_pile = "luxury_showcase",
  card_filter = function (self, player, to_select, selected)
    if #selected < 1 and player:getPileNameOfId(to_select) == "luxury_showcase" then
      if not table.contains(player:getTableMark("steam__tandewuyan_temp"), to_select) then
        local card = Fk:getCardById(to_select)
        if Fk.currentResponsePattern == nil then
          return player:canUse(card) and not player:prohibitUse(card)
        else
          return Exppattern:Parse(Fk.currentResponsePattern):match(card)
        end
      end
    end
  end,
  view_as = function (self, player, cards)
    if #cards ~= 1 then return end
    return Fk:getCardById(cards[1])
  end,
  before_use = function (self, player, use)
    local room = player.room
    -- 防止濒死插结导致的重复用一张牌
    room:addTableMark(player, "steam__tandewuyan_temp", use.card.id)
    local judge = {
      who = player,
      reason = "floating_thunder",
      pattern = ".|.|spade",
    }
    room:judge(judge)
    if judge:matchPattern() and not player.dead then
      room:damage{
        to = player,
        damage = 1,
        damageType = fk.ThunderDamage,
        skillName = skel.name,
      }
    end
    room:removeTableMark(player, "steam__tandewuyan_temp", use.card.id)
  end,
  enabled_at_play = function(self, player)
    return #player:getPile("luxury_showcase") > 0
  end,
  enabled_at_response = function(self, player, response)
    if not response and Fk.currentResponsePattern then
      return table.find(player:getPile("luxury_showcase"), function (id)
        return Exppattern:Parse(Fk.currentResponsePattern):match(Fk:getCardById(id))
      end)
    end
  end,
})



return skel
