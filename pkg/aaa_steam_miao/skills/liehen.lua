local skel = fk.CreateSkill {
  name = "steam__liehen",
}

Fk:loadTranslationTable{
  ["steam__liehen"] = "烈恨",
  [":steam__liehen"] = "出牌阶段限一次，你可以选择一名角色，令其调整手牌数至与你相等，然后你依次使用其以此法弃置的可以使用的牌。",

  ["#steam__liehen"] = "烈恨：令一名角色调整手牌数至与你相等，然后使用其弃置的牌",
  ["#steam__liehen-use"] = "烈恨：请使用其弃置的牌",
  ["#steam__liehen-discard"] = "烈恨：请弃置 %arg 张手牌，且 %dest 可以使用这些牌",

  ["$steam__liehen1"] = "怒涛九折，鞭之复鞭，独宿愤难消！",
  ["$steam__liehen2"] = "纵剖棺戮尸，父兄之仇，亦难报十一！",
}

skel:addEffect("active", {
  anim_type = "control",
  prompt = "#steam__liehen",
  card_num = 0,
  target_num = 1,
  card_filter = Util.FalseFunc,
  target_filter = function (self, player, to, selected)
    return #selected == 0 and to:getHandcardNum() ~= player:getHandcardNum()
  end,
  times = function (self, player)
    return 1 - player:usedSkillTimes(skel.name, Player.HistoryPhase)
  end,
  can_use = function(self, player)
    return player:usedSkillTimes(skel.name, Player.HistoryPhase) == 0
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local to = effect.tos[1]
    local cards = {}
    local x = to:getHandcardNum() - player:getHandcardNum()
    if x > 0 then
      cards = room:askToDiscard(to, {
        min_num = x, max_num = x, include_equip = false, skill_name = skel.name, cancelable = false,
        prompt = "#steam__liehen-discard::" .. player.id .. ":" .. x
      })
    else
      to:drawCards(-x, skel.name)
    end
    while player:isAlive() do
      cards = table.filter(cards, function (id) return room:getCardArea(id) == Card.DiscardPile end)
      if #cards == 0 then break end
      local use = room:askToUseRealCard(player, {
        pattern = cards, skill_name = skel.name, prompt = "#steam__liehen-use",
        expand_pile = cards, skip = true, extra_data = {
          expand_pile = cards,
          bypass_times = true,
          extraUse = true,
        }
      })
      if not use then break end
      table.removeOne(cards, use.card:getEffectiveId())
      room:useCard(use)
    end
  end,
})

return skel
