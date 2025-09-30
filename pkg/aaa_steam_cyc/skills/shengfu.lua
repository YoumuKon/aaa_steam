local skel = fk.CreateSkill {
  name = "steam__shengfu",
}

Fk:loadTranslationTable{
  ["steam__shengfu"] = "圣符",
  [":steam__shengfu"] = "每回合限一次，你需要使用/打出基本牌时，可以弃置X张牌视为使用一张无法抵消的【洞烛先机】(X为本轮发动次数，从0起)。",

  ["#steam__shengfu"] = "圣符：你可以弃置%arg张牌，视为使用一张【洞烛先机】",
}

skel:addEffect("viewas", {
  anim_type = "drawcard",
  --pattern = "foresight",
  prompt = function (self, player)
    return "#steam__shengfu:::"..player:usedSkillTimes(skel.name, Player.HistoryRound)
  end,
  card_filter = function (self, player, to_select, selected)
    return not player:prohibitDiscard(to_select) and #selected < player:usedSkillTimes(skel.name, Player.HistoryRound)
  end,
  view_as = function (self, player, cards)
    if #cards ~= player:usedSkillTimes(skel.name, Player.HistoryRound) then return nil end
    local c = Fk:cloneCard("foresight")
    c.skillName = skel.name
    c:addFakeSubcards(cards)
    return c
  end,
  before_use = function (self, player, use)
    use.disresponsiveList = table.simpleClone(player.room.players)
  end,
  enabled_at_play = function (self, player)
    return player:usedSkillTimes(skel.name) < 1
  end,
  enabled_at_response = Util.FalseFunc,
  times = function (self, player)
    return 1 - player:usedSkillTimes(skel.name)
  end,
})

local spec = {
  anim_type = "drawcard",
  can_trigger = function (self, event, target, player, data)
    if player:hasSkill(skel.name) and target == player and player:usedSkillTimes(skel.name) == 0 then
      return Exppattern:Parse(".|.|.|.|.|basic"):matchExp(data.pattern) or Exppattern:Parse(data.pattern):matchExp(".|.|.|.|.|basic")
    end
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local _, dat = room:askToUseActiveSkill(player, {
      skill_name = skel.name, prompt =  "#steam__shengfu:::"..player:usedSkillTimes(skel.name, Player.HistoryRound),
      skip = true, cancelable = true
    })
    if dat then
      event:setCostData(self, {cards = dat.cards})
      return true
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local cards = event:getCostData(self).cards
    local c = Fk:cloneCard("foresight")
    c.skillName = skel.name
    c:addFakeSubcards(cards)
    room:useCard{
      from = player, tos = {player},
      card = c,
      unoffsetableList = table.simpleClone(room.players)
    }
  end,
}

skel:addEffect(fk.AskForCardUse, spec)

skel:addEffect(fk.AskForCardResponse, spec)

skel:addEffect(fk.CardUsing, {
  is_delay_effect = true,
  mute = true,
  can_trigger = function (self, event, target, player, data)
    return target == player and table.contains(data.card.skillNames, skel.name)
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    local cards = table.filter(data.card.fake_subcards, function (id)
      return table.contains(player:getCardIds("he"), id)
    end)
    if #cards > 0 then
      player.room:throwCard(cards, skel.name, player, player)
    end
  end,
})

return skel
