local jiebing = fk.CreateSkill {
  name = "steam__jiebing",
}

Fk:loadTranslationTable{
  ["steam__jiebing"] = "解兵",
  [":steam__jiebing"] = "每轮各限一次，一名角色使用武器/防具/宝物牌后，你可以令一名角色随机获得一张伤害/抵消/锦囊牌。",

  ["#steam__jiebing-weapon"] = "解兵：你可以令一名角色随机获得一张伤害牌",
  ["#steam__jiebing-armor"] = "解兵：你可以令一名角色随机获得一张抵消牌",
  ["#steam__jiebing-treasure"] = "解兵：你可以令一名角色随机获得一张锦囊牌",

  ["$steam__jiebing1"] = "明王圣帝，谁能去兵哉？",
  ["$steam__jiebing2"] = "生杀之机，焉能拱手相让？",
}

jiebing:addEffect(fk.CardUseFinished, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(jiebing.name) and
      table.contains({
        Card.SubtypeWeapon,
        Card.SubtypeArmor,
        Card.SubtypeTreasure,
      }, data.card.sub_type) and
      not table.contains(player:getTableMark("steam__jiebing-round"), data.card.sub_type)
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local to = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = room.alive_players,
      skill_name = jiebing.name,
      prompt = "#steam__jiebing-"..data.card:getSubtypeString(),
      cancelable = true,
    })
    if #to > 0 then
      event:setCostData(self, {tos = to})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = event:getCostData(self).tos[1]
    room:addTableMark(player, "steam__jiebing-round", data.card.sub_type)
    local cards = {}
    if data.card.sub_type == Card.SubtypeWeapon then
      cards = table.filter(table.connect(room.draw_pile, room.discard_pile), function (id)
        return Fk:getCardById(id).is_damage_card
      end)
    elseif data.card.sub_type == Card.SubtypeArmor then
      cards = table.filter(table.connect(room.draw_pile, room.discard_pile), function (id)
        return Fk:getCardById(id).is_passive and
          string.find(Fk:translate(":"..Fk:getCardById(id).name, "zh_CN"), "抵消") ~= nil
      end)
    elseif data.card.sub_type == Card.SubtypeTreasure then
      cards = room:getCardsFromPileByRule(".|.|.|.|.|trick", 1, "allPiles")
    end
    if #cards > 0 then
      room:moveCardTo(table.random(cards), Card.PlayerHand, to, fk.ReasonJustMove, jiebing.name, nil, false, player)
    end
  end,
})

return jiebing
