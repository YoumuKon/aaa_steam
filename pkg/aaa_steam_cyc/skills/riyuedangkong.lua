local skel = fk.CreateSkill {
  name = "steam__riyuedangkong",
  dynamic_desc = function (self, player, lang)
    if player:getMark("steam__riyuedangkong_levelup") ~= 0 then
      return "steam__riyuedangkong_levelup"
    end
    return "steam__riyuedangkong"
  end,
}

Fk:loadTranslationTable{
  ["steam__riyuedangkong"] = "日月当空",
  [":steam__riyuedangkong"] = "每回合限一次，你获得牌后，可以弃置至多两张牌，获得以下前等量+1项：火【杀】、【决斗】、插画含有动物的牌。",
  -- 动物：南蛮、顺手、无懈、坐骑
  ["#steam__riyuedangkong-cost"] = "你可以弃置1-2张牌，获得前等量+1项：火【杀】、【决斗】、动物牌",
  ["#steam__riyuedangkong-trick"] = "你可以弃置1-2张牌，获得等量+1张锦囊牌",
  [":steam__riyuedangkong_levelup"] = "每回合限一次，你获得牌后，可以弃置至多两张牌，获得等量+1张锦囊牌。",
}

skel:addEffect(fk.AfterCardsMove, {
  anim_type = "drawcard",
  times = function (_, player)
    return 1 - player:usedSkillTimes(skel.name)
  end,
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(skel.name) and not player:isNude() and player:usedSkillTimes(skel.name) == 0 then
      for _, move in ipairs(data) do
        if move.to == player and move.toArea == Player.Hand then
          return true
        end
      end
    end
  end,
  on_cost = function (self, event, target, player, data)
    local prompt = "#steam__riyuedangkong-cost"
    if player:getMark("steam__riyuedangkong_levelup") ~= 0 then
      prompt = "#steam__riyuedangkong-trick"
    end
    local cards = player.room:askToDiscard(player, {
      min_num = 1, max_num = 2, skill_name = skel.name, cancelable = true, include_equip = true, skip = true,
      prompt = prompt
    })
    if #cards > 0 then
      event:setCostData(self, { cards = cards })
      return true
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local cards = event:getCostData(self).cards
    room:throwCard(cards, skel.name, player, player)
    if player.dead then return end
    local n = #cards + 1
    local get = {}
    if player:getMark("steam__riyuedangkong_levelup") ~= 0 then
      get = room:getCardsFromPileByRule(".|.|.|.|.|trick", n, "allPiles")
    else
      -- 不能用sb expPattern "savage_assault,snatch,nullification;.|.|.|.|.|offensive_horse,defensive_horse"
      local map = {".|.|.|.|fire__slash", "duel"}
      for i = 1, n do
        local cid
        if i < 3 then
          cid = room:getCardsFromPileByRule(map[i], 1, "allPiles")[1]
        else
          local animals = {
            "savage_assault", "snatch", "nullification", -- 南蛮 顺手牵羊 无懈可击
            "carrier_pigeon", "bronze_sparrow", "bee_cloth", "bee_armor", -- 信鸽 铜雀
            "certamen", -- 逐鹿天下
          }
          cid = table.find(table.connect(room.draw_pile, room.discard_pile), function (id)
            local c = Fk:getCardById(id)
            return c.sub_type == Card.SubtypeDefensiveRide or c.sub_type == Card.SubtypeOffensiveRide
            or table.contains(animals, c.name)
          end)
        end
        if cid then
          table.insert(get, cid)
        end
      end
    end
    if #get > 0 then
      room:obtainCard(player, get, true, fk.ReasonJustMove, player, skel.name)
    end
  end,
})

return skel
