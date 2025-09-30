local skel = fk.CreateSkill {
  name = "steam__wujijiandao",
  tags = {Skill.Limited},
}

Fk:loadTranslationTable{
  ["steam__wujijiandao"] = "无极剑道",
  [":steam__wujijiandao"] = "限定技，出牌阶段开始时，你可以获得一张【无双方天戟】或【飞龙夺凤】，本回合结束时弃置之。",
  ["#steam__wujijiandao-choice"] = "无极剑道：你可以获得一张【无双方天戟】或【飞龙夺凤】（回合结束时弃置）",

  ["$steam__wujijiandao1"] = "无极之道在我内心延续",
  ["$steam__wujijiandao2"] = "形势先于蛮力",
}

skel:addEffect(fk.EventPhaseStart, {
  times = function (_, player) return 1 - Self:usedSkillTimes(skel.name, Player.HistoryGame) end,
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(skel.name) or player:usedSkillTimes(skel.name, Player.HistoryGame) > 0 then return false end
    return target == player and player.phase == Player.Play
  end,
  on_cost = function (self, event, target, player, data)
    local choices = {"steam_halberd", "steam_dragon_phoenix"}
    choices = table.filter(choices, function(name) return Fk.all_card_types[name] ~= nil end)
    if #choices == 0 then return end
    table.insert(choices, "Cancel")
    local name = player.room:askToChoice(player, { choices = choices, skill_name = skel.name,
    prompt = "#steam__wujijiandao-choice", detailed = true})
    if name ~= "Cancel" then
      event:setCostData(self, {name = name})
      return true
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local name = event:getCostData(self).name
    local suit, number = Card.Spade, 2
    if name == "steam_halberd" then
      suit, number = Card.Diamond, 12
    end
    local cid = room:printCard(name, suit, number).id
    room:addTableMark(player, "steam__wujijiandao-turn", cid)
    room:obtainCard(player, cid, true, fk.ReasonJustMove, player, skel.name)
  end,
})

skel:addEffect(fk.TurnEnd, {
  is_delay_effect = true,
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return player:getMark("steam__wujijiandao-turn") ~= 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local cards = table.filter(player:getTableMark("steam__wujijiandao-turn"), function(id)
      return table.contains(player:getCardIds("he"), id)
    end)
    if #cards > 0 then
      room:throwCard(cards, skel.name, player, player)
    end
  end,
})

return skel
