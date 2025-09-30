local skel = fk.CreateSkill {
  name = "steam__tongdu",
}

Fk:loadTranslationTable{
  ["steam__tongdu"] = "统度",
  [":steam__tongdu"] = "当你成为其他角色使用牌的目标后，你可以令一名角色重铸一张牌，若其重铸了<font color='red'>♦</font>牌，将一张【无中生有】置于牌堆顶。",

  ["#steam__tongdu-choose"] = "统度：你可以令一名角色重铸一张牌",
  ["#steam__tongdu-recast"] = "统度：请重铸1张牌！",

  ["$steam__tongdu1"] = "辎重调拨，乃国之要务，岂可儿戏！",
  ["$steam__tongdu2"] = "府库充盈，民有余财，主公师出有名矣。",
}

skel:addEffect(fk.TargetConfirmed, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(skel.name) and data.from and data.from ~= player and
      table.find(player.room.alive_players, function(p) return not p:isNude() end)
  end,
  on_cost = function(self, event, target, player, data)
    local tos = player.room:askToChoosePlayers(player, {
      targets = table.filter(player.room.alive_players, function(p) return not p:isNude() end),
      min_num = 1, max_num = 1, prompt = "#steam__tongdu-choose", skill_name = skel.name
    })
    if #tos > 0 then
      event:setCostData(self, { tos = tos })
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = event:getCostData(self).tos[1]
    local cards = room:askToCards(to, { min_num = 1, max_num = 1, include_equip = true,
    skill_name = skel.name, cancelable = false, prompt = "#steam__tongdu-recast"})
    local card = Fk:getCardById(cards[1])
    room:recastCard(cards, to, skel.name)
    if card.suit == Card.Diamond then
      local cid = table.find(room.discard_pile, function (id) return Fk:getCardById(id).name == "ex_nihilo" end)
      if cid then
        room:moveCardTo(cid, Card.DrawPile, nil, fk.ReasonPut, skel.name, nil, true)
      else
        for i = #room.draw_pile, 1, -1 do
          local id = room.draw_pile[i]
          if Fk:getCardById(id).name == "ex_nihilo" then
            table.remove(room.draw_pile, i)
            table.insert(room.draw_pile, 1, id)
            room:syncDrawPile()
            break
          end
        end
      end
    end
  end,
})

return skel
