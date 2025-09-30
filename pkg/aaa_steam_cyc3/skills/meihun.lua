local meihun = fk.CreateSkill {
  name = "steam__meihun",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["steam__meihun"] = "魅魂",
  [":steam__meihun"] = "锁定技，你没有初始手牌，游戏开始时，你从其他角色的手牌中各发现一张牌；若最后你的手牌数不足四张，则重复此流程。",

  ["$steam__meihun1"] = "你们的争斗，不过是我指尖的傀儡戏。",
  ["$steam__meihun2"] = "我动动指尖，便能让山河变色，群雄皆醉。",
}

meihun:addEffect(fk.GameStart, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(meihun.name) and
      table.find(player.room:getOtherPlayers(player, false), function (p)
        return not p:isKongcheng()
      end)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local loop_lock = 0
    while loop_lock == 0 or player:getHandcardNum() < 4 do
      loop_lock = loop_lock + 1
      if loop_lock > 20 then
        return
      end
      for _, p in ipairs(room:getOtherPlayers(player)) do
        if not p.dead and not p:isKongcheng() then
          local id = room:askToChooseCard(player, {
            target = p,
            flag = { card_data = {{ p.general, table.random(p:getCardIds("h"), 3) }} },
            skill_name = meihun.name,
          })
          room:obtainCard(player, id, false, fk.ReasonPrey, player, meihun.name)
          if player.dead then return end
        end
      end
    end
  end,
})

meihun:addEffect(fk.DrawInitialCards, {
  can_refresh = function (self, event, target, player, data)
    return target == player and player:hasSkill(meihun.name)
  end,
  on_refresh = function (self, event, target, player, data)
    data.num = -999
  end,
})

return meihun
