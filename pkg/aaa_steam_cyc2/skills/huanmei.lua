local skel = fk.CreateSkill {
  name = "steam__huanmei",
}

Fk:loadTranslationTable{
  ["steam__huanmei"] = "幻魅",
  [":steam__huanmei"] = "每两个回合，你获得一张【随机应变】或【随机】。其他角色的回合开始时，你可以交给其一张牌。",

  ["#steam__huanmei-invoke"] = "幻魅：是否交给 %dest 一张牌？",
  ["@@steam__huanmei"] = "幻魅",

  ["$steam__huanmei1"] = " ",
  ["$steam__huanmei2"] = " ",
}

skel:addEffect(fk.TurnStart, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(skel.name) then
      player.room:addPlayerMark(player, skel.name, 1)
      if (target ~= player and not target.dead) or player:getMark(skel.name) == 2 then
        return true
      end
    end
  end,
  on_cost = function (self, event, target, player, data)
    if player:getMark(skel.name) == 2 then
      event:setCostData(self, {tos = player})
      return true
    elseif (target ~= player and not target.dead) and player:getMark(skel.name) ~= 2 then
      local cards = player.room:askToCards(player, {
        min_num = 1,
        max_num = 1,
        include_equip = true,
        skill_name = skel.name,
        prompt = "#steam__huanmei-invoke::"..target.id,
        cancelable = true,
      })
      if #cards > 0 then
        event:setCostData(self, {tos = target, cards = cards})
        return true
      end
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local cards = event:getCostData(self).cards
    if cards ~= nil then
      room:obtainCard(target, cards, false, fk.ReasonGive, player, skel.name)
    else
      room:removePlayerMark(player, skel.name, 2)
      local get = {}
      local name = table.random({"adaptation", "steam_randomcard"}, 1)[1]
      if name == "adaptation" then
        table.insert(get, room:printCard("adaptation", Card.Spade, 2).id)
      elseif name == "steam_randomcard" then
        table.insert(get, room:printCard("steam_randomcard", Card.Diamond, 13).id)
      end
      room:setCardMark(Fk:getCardById(get[1]), "@@steam__huanmei", 1)
      room:obtainCard(player, get, true, fk.ReasonJustMove, player, skel.name, MarkEnum.DestructIntoDiscard)
      if player.dead or target.dead or player:isNude() or target == player then return end
      local cardss = player.room:askToCards(player, {
        min_num = 1,
        max_num = 1,
        include_equip = true,
        skill_name = skel.name,
        prompt = "#steam__huanmei-invoke::"..target.id,
        cancelable = true,
      })
      if #cardss > 0 then
        room:obtainCard(target, cardss, false, fk.ReasonGive, player, skel.name)
      end
    end
  end,
})

skel:addLoseEffect(function (self, player, is_death)
  player.room:setPlayerMark(player, skel.name, 0)
end)

return skel
