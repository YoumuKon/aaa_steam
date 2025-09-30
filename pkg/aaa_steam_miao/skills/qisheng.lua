local skel = fk.CreateSkill {
  name = "steam__qisheng",
}

Fk:loadTranslationTable{
  ["steam__qisheng"] = "奇胜",
  [":steam__qisheng"] = "回合结束时，你可以选择中央区的三张伤害牌，依次置入手牌、置于牌堆顶、使用，若以此法使用的牌造成了伤害，则重复此流程。",

  ["#steam__qisheng-card"] = "奇胜：选择三张伤害牌，依次置入手牌、置于牌堆顶、使用",
  ["#steam__qisheng-prey"] = "奇胜：选择一张置入手牌",
  ["#steam__qisheng-put"] = "奇胜：选择一张置于牌堆顶",
  ["#steam__qisheng-use"] = "奇胜：请使用此牌！",

  ["$steam__qisheng1"] = "",
  ["$steam__qisheng2"] = "",
}

skel:addEffect(fk.TurnEnd, {
  anim_type = "offensive",
  can_trigger = function (self, event, target, player, data)
    if player:hasSkill(skel.name) and target == player then
      return #table.filter(player.room:getBanner("@$CenterArea") or Util.DummyTable, function (id)
        return Fk:getCardById(id).is_damage_card
      end) > 2
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    while player:isAlive() do
      local cards = table.filter(room:getBanner("@$CenterArea"), function (id)
        return Fk:getCardById(id).is_damage_card
      end)
      if #cards < 3 then break end
      cards = room:askToChooseCards(player, {
        target = player, min = 3, max = 3,
        flag = { card_data = { { skel.name, cards } } },
        skill_name = skel.name, prompt = "#steam__qisheng-card"
      })
      local get = room:askToCards(player, {
        min_num = 1, max_num = 1, cancelable = false ,include_equip = false, skill_name = skel.name,
        pattern = tostring(Exppattern{ id = cards }), prompt = "#steam__qisheng-prey",
        expand_pile = cards,
      })[1]
      table.removeOne(cards, get)
      room:obtainCard(player, get, true, fk.ReasonPrey, player, skel.name)
      cards = table.filter(cards, function (id) return room:getCardArea(id) == Card.DiscardPile end)
      if #cards == 0 then break end
      if player.dead then
        room:moveCardTo(cards[1], Card.DrawPile, nil, fk.ReasonPut, skel.name, nil, false)
        break
      end
      local put = room:askToCards(player, {
        min_num = 1, max_num = 1, cancelable = false ,include_equip = false, skill_name = skel.name,
        pattern = tostring(Exppattern{ id = cards }), prompt = "#steam__qisheng-put",
        expand_pile = cards,
      })[1]
      room:moveCardTo(put, Card.DrawPile, nil, fk.ReasonPut, skel.name, nil, false)
      table.removeOne(cards, put)
      if player.dead or #cards == 0 or room:getCardArea(cards[1]) ~= Card.DiscardPile then break end
      local use = room:askToUseRealCard(player, {
        pattern = cards, cancelable = false, skill_name = skel.name, expand_pile = cards,
        prompt = "#steam__qisheng-use", extra_data = {expand_pile = cards},
      })
      if not (use and use.damageDealt) then break end
    end
  end,
})

skel:addAcquireEffect(function (self, player, is_start)
  player.room:addSkill("#CenterArea")
end)

return skel
