local skill = fk.CreateSkill {
  name = "steam_zhushen_equip_skill&",
  attached_equip = "steam_zhushen_equip",
}

Fk:loadTranslationTable{
  ["steam_zhushen_equip_skill&"] = "铸物",
  [":steam_zhushen_equip_skill&"] = "每回合限一次，你可以将所有“铸神”选择花色的手牌当“铸神”发现的牌使用并摸一张牌。",
  ["#steam_zhushen_equip_skill"] = "铸物：将所有%arg手牌当【%arg2】使用并摸一张牌",
}

skill:addEffect("viewas", {
  pattern = ".",
  prompt = function (self, player)
    for _, id in ipairs(player:getCardIds("e")) do
      local card = Fk:getCardById(id)
      if card.name == skill.attached_equip and
        card:getMark("steam__zhushen") ~= 0 and
        table.find(player:getCardIds("h"), function (id2)
          return Fk:getCardById(id2):getSuitString(true) == card:getMark("steam__zhushen")[1]
        end) and
        #player:getViewAsCardNames(skill.name, {card:getMark("steam__zhushen")[2]},
        table.filter(player:getCardIds("h"), function (id2)
          return Fk:getCardById(id2):getSuitString(true) == card:getMark("steam__zhushen")[1]
        end)) > 0 then
        return "#steam_zhushen_equip_skill:::"..card:getMark("steam__zhushen")[1]..":"..card:getMark("steam__zhushen")[2]
      end
    end
  end,
  card_filter = Util.FalseFunc,
  view_as = function(self, player, cards)
    for _, id in ipairs(player:getCardIds("e")) do
      local card = Fk:getCardById(id)
      if card.name == skill.attached_equip and
        card:getMark("steam__zhushen") ~= 0 and
        table.find(player:getCardIds("h"), function (id2)
          return Fk:getCardById(id2):getSuitString(true) == card:getMark("steam__zhushen")[1]
        end) and
        #player:getViewAsCardNames(skill.name, {card:getMark("steam__zhushen")[2]},
        table.filter(player:getCardIds("h"), function (id2)
          return Fk:getCardById(id2):getSuitString(true) == card:getMark("steam__zhushen")[1]
        end)) > 0 then
        local c = Fk:cloneCard(card:getMark("steam__zhushen")[2])
        c.skillName = skill.name
        cards = table.filter(player:getCardIds("h"), function (id2)
          return Fk:getCardById(id2):getSuitString(true) == card:getMark("steam__zhushen")[1]
        end)
        if #cards == 0 then return end
        c:addSubcards(cards)
        return c
      end
    end
  end,
  after_use = function (self, player, use)
    if not player.dead then
      player:drawCards(1, skill.name)
    end
  end,
  enabled_at_play = function (self, player)
    return player:usedSkillTimes(skill.name, Player.HistoryTurn) == 0 and
      table.find(player:getCardIds("e"), function (id)
        local card = Fk:getCardById(id)
        return card.name == skill.attached_equip and
          card:getMark("steam__zhushen") ~= 0 and
          table.find(player:getCardIds("h"), function (id2)
            return Fk:getCardById(id2):getSuitString(true) == card:getMark("steam__zhushen")[1]
          end) and
          #player:getViewAsCardNames(skill.name, {card:getMark("steam__zhushen")[2]},
          table.filter(player:getCardIds("h"), function (id2)
            return Fk:getCardById(id2):getSuitString(true) == card:getMark("steam__zhushen")[1]
          end)) > 0
      end)
  end,
  enabled_at_response = function (self, player, response)
    return not response and player:usedSkillTimes(skill.name, Player.HistoryTurn) == 0 and
      table.find(player:getCardIds("e"), function (id)
        local card = Fk:getCardById(id)
        return card.name == skill.attached_equip and
          card:getMark("steam__zhushen") ~= 0 and
          table.find(player:getCardIds("h"), function (id2)
            return Fk:getCardById(id2):getSuitString(true) == card:getMark("steam__zhushen")[1]
          end) and
          #player:getViewAsCardNames(skill.name, {card:getMark("steam__zhushen")[2]},
          table.filter(player:getCardIds("h"), function (id2)
            return Fk:getCardById(id2):getSuitString(true) == card:getMark("steam__zhushen")[1]
          end)) > 0
      end)
  end,
  enabled_at_nullification = function (self, player, data)
    return player:usedSkillTimes(skill.name, Player.HistoryTurn) == 0 and
      not player:isKongcheng() and
      table.find(player:getCardIds("e"), function (id)
        local card = Fk:getCardById(id)
        return card.name == skill.attached_equip and
          card:getMark("steam__zhushen") ~= 0 and card:getMark("steam__zhushen")[2] == "nullification"
      end) ~= nil
  end,
})

return skill
