local kurong = fk.CreateSkill{
  name = "steam__kurong",
}

Fk:loadTranslationTable{
  ["steam__kurong"] = "枯荣",
  [":steam__kurong"] = "有角色回满体力或脱离濒死后，你可以令一名角色使用一张<a href=':steam_kurong_equip'>【嫩竹】</a>。",

  ["#steam__kurong-choose"] = "枯荣：是否令一名角色使用一张【嫩竹】？",
  ["@steam_kurong_equip"] = "嫩竹",

  ["$steam__kurong1"] = "枯骨生荒草，丘墟化桑田。",
  ["$steam__kurong2"] = "白露种高山，秋分种平川。",
}

local spec = {
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local get = room:askToChoosePlayers(player, {
      targets = table.filter(player.room.alive_players, function (p) return p:canUseTo(Fk:cloneCard("steam_kurong_equip", Card.Heart, 6), p) end),
      min_num = 1,
      max_num = 1,
      prompt = "#steam__kurong-choose",
      skill_name = kurong.name,
      cancelable = true,
    })
    if #get > 0 then
      event:setCostData(self, {tos = get})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = event:getCostData(self).tos[1]
    local card = room:printCard("steam_kurong_equip", Card.Heart, 6)
    room:setCardMark(card, MarkEnum.DestructOutEquip, 1)
    room:useCard{
      from = to,
      tos = { to },
      card = card,
    }
  end,
}

kurong:addEffect(fk.HpRecover, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(kurong.name) and not target:isWounded() and
    table.find(player.room.alive_players, function (p) return p:canUseTo(Fk:cloneCard("steam_kurong_equip", Card.Heart, 6), p) end)
  end,
  on_cost = spec.on_cost,
  on_use = spec.on_use,
})

kurong:addEffect(fk.AfterDying, {
  anim_type = "support",
  can_trigger = function (self, event, target, player, data)
    return player:hasSkill(kurong.name) and 
    table.find(player.room.alive_players, function (p) return p:canUseTo(Fk:cloneCard("steam_kurong_equip", Card.Heart, 6), p) end)
  end,
  on_cost = spec.on_cost,
  on_use = spec.on_use,
})

return kurong
