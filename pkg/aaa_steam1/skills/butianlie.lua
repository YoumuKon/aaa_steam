local skel = fk.CreateSkill {
  name = "steam__butianlie",
  tags = {Skill.Limited},
}

Fk:loadTranslationTable{
  ["steam__butianlie"] = "补天裂",
  [":steam__butianlie"] = "限定技，出牌阶段，你可以重置〖看试手〗的记录，并依次视为使用以此法恢复的普通锦囊牌，若造成伤害，"..
  "本局游戏你的此锦囊牌视为【酒】。",

  ["#steam__butianlie"] = "补天裂：是否重置并视为使用“看试手”记录的锦囊牌？",
  ["#steam__butianlie-ask"] = "补天裂：请视为使用其中一张牌",

  ["$steam__butianlie1"] = "",
  ["$steam__butianlie2"] = "",
}

local U = require "packages/utility/utility"

skel:addEffect("active", {
  card_num = 0,
  target_num = 0,
  prompt = "#steam__butianlie",
  frequency = Skill.Limited,
  can_use = function(self, player)
    return player:usedSkillTimes(skel.name, Player.HistoryGame) == 0 and
      #player:getTableMark("@$steam__kanshishou") > 0
  end,
  card_filter = Util.FalseFunc,
  on_use = function(self, room, effect)
    local player = effect.from
    local cards = table.filter(U.getUniversalCards(player.room, "t"), function (id)
      return table.contains(player:getTableMark("@$steam__kanshishou"), Fk:getCardById(id).name)
    end)
    room:setPlayerMark(player, "@$steam__kanshishou", 0)
    room:setPlayerMark(player, "steam__kanshishou", 0)
    player:filterHandcards()
    while #cards > 0 and not player.dead do
      local use = room:askToUseRealCard(player, {
        skill_name = skel.name, prompt = "#steam__butianlie-ask", skip = true, pattern = cards,
        expand_pile = cards, extra_data = {expand_pile = cards},
      })
      if use then
        local card = Fk:cloneCard(use.card.name)
        card.skillName = skel.name
        table.removeOne(cards, use.card.id)
        use = {
          card = card,
          from = player,
          tos = use.tos,
        }
        room:useCard(use)
        if use.damageDealt and not player.dead then
          room:addTableMark(player, skel.name, card.name)
          player:filterHandcards()
        end
      end
    end
  end,
})

skel:addEffect("filter", {
  anim_type = "offensive",
  card_filter = function(self, to_select, player)
    return table.contains(player:getTableMark(skel.name), to_select.name) and
      table.contains(player:getCardIds("h"), to_select.id)
  end,
  view_as = function(self, _, to_select)
    local card = Fk:cloneCard("analeptic", to_select.suit, to_select.number)
    card.skillName = skel.name
    return card
  end,
})

return skel
