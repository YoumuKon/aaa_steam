local skel = fk.CreateSkill {
  name = "steam__yongheng",
}

Fk:loadTranslationTable{
  ["steam__yongheng"] = "永恒",
  [":steam__yongheng"] = "每回合限一次，每轮限三次，你需要使用/打出基本牌时，可以将两张牌当【洞烛先机】使用。",
  -- 此【洞烛先机】无法抵消

  ["#steam__yongheng-cost"] = "永恒：你可以将两张牌当【洞烛先机】使用",
}

skel:addEffect("viewas", {
  prompt = "#steam__yongheng-cost",
  anim_type = "drawcard",
  mute_card = false,
  card_filter = function (self, player, to_select, selected)
    return #selected < 2
  end,
  view_as = function (self, player, cards)
    if #cards ~= 2 then return nil end
    local c = Fk:cloneCard("foresight")
    c.skillName = skel.name
    c:addSubcards(cards)
    return c
  end,
  before_use = function (self, player, use)
    use.unoffsetableList = table.simpleClone(player.room.alive_players)
  end,
  enabled_at_play = function (self, player)
    return player:usedSkillTimes(skel.name) < 1 and player:usedSkillTimes(skel.name, Player.HistoryRound) < 3
  end,
  enabled_at_response = Util.FalseFunc,
  times = function (self, player)
    if player:usedSkillTimes(skel.name, Player.HistoryRound) >= 3 then return 0 end
    return 1 - player:usedSkillTimes(skel.name)
  end,
})

local can_trigger = function (self, event, target, player, data)
  if player:hasSkill(skel.name) and target == player and player:usedSkillTimes(skel.name) == 0 and #player:getCardIds("he") > 1
  and player:usedSkillTimes(skel.name, Player.HistoryRound) < 3 then
    if data.pattern then
      if Exppattern:Parse(".|.|.|.|.|basic"):matchExp(data.pattern) or Exppattern:Parse(data.pattern):matchExp(".|.|.|.|.|basic") then
        return true
      end
    end
  end
end

local on_cost = function (self, event, target, player, data)
  local _, dat = player.room:askToUseActiveSkill(player, { skill_name = "steam__yongheng", prompt = "#steam__yongheng-cost", skip = true })
  if dat then
    event:setCostData(self, dat.cards)
    return true
  end
end

local on_use = function (self, event, target, player, data)
  local room = player.room
  local card = Fk:cloneCard("foresight")
  card.skillName = skel.name
  card:addSubcards(event:getCostData(self))
  if card then
    room:useCard{from = player, tos = {player}, card = card, unoffsetableList = table.simpleClone(room.alive_players)}
  end
end

skel:addEffect(fk.AskForCardUse, {
  anim_type = "drawcard",
  can_trigger = can_trigger,
  on_cost = on_cost,
  on_use = on_use,
})

skel:addEffect(fk.AskForCardResponse, {
  anim_type = "drawcard",
  can_trigger = can_trigger,
  on_cost = on_cost,
  on_use = on_use,
})

return skel
