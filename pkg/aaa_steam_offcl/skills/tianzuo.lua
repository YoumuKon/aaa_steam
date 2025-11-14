local skel = fk.CreateSkill {
  name = "steam__tianzuo",
  tags = {Skill.Compulsory},
}

Fk:loadTranslationTable{
  ["steam__tianzuo"] = "天佐",
  [":steam__tianzuo"] = "锁定技，游戏开始时，将8张<a href='raid_and_frontal_attack_href'>【奇正相生】</a>加入牌堆；【奇正相生】对你无效；其他角色的【奇正相生】生效时，你观看目标手牌，并重新指定“正兵”、“奇兵”。",

  ["#steam__tianzuo-choice"] = "天佐：请重新指定：正兵：%dest不出闪，%src获得其牌；奇兵：%dest不出杀，%src对其造成伤害",

  ["raid_and_frontal_attack_href"] = "【<b>奇正相生</b>】（♠2/♠4/♠6/♠8/♣3/♣5/♣7/♣9） 锦囊牌<br/>" ..
  "出牌阶段，对一名其他角色使用。当此牌指定目标后，你为其指定“奇兵”或“正兵”。"..
  "目标角色可以打出一张【杀】或【闪】，然后若其为：“正兵”目标且未打出【杀】，你对其造成1点伤害；“奇兵”目标且未打出【闪】，你获得其一张牌。",

  ["$steam__tianzuo1"] = "此时进之多弊，守之多利，愿主公熟虑。",
  ["$steam__tianzuo2"] = "主公若不时定，待四方生心，则无及矣。",
}

local U = require "packages.utility.utility"

skel:addEffect(fk.GameStart, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(skel.name) then return false end
    return true
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local name = "raid_and_frontal_attack"
    local cards = {
      {name, Card.Spade, 2},
      {name, Card.Spade, 4},
      {name, Card.Spade, 6},
      {name, Card.Spade, 8},
      {name, Card.Club, 3},
      {name, Card.Club, 5},
      {name, Card.Club, 7},
      {name, Card.Club, 9},
    }
    room:changeCardArea(U.prepareDeriveCards(room, cards, skel.name), Card.DrawPile)
  end,
})

skel:addEffect(fk.PreCardEffect, {
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(skel.name) then return false end
    return data.to == player and data.card.trueName == "raid_and_frontal_attack"
  end,
  on_use = function(self, event, target, player, data)
    data:setNullified(player)
  end,
})

skel:addEffect(fk.CardEffecting, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(skel.name) then return false end
    return data.from and data.from ~= player and data.to and not data.to.dead
    and data.card.trueName == "raid_and_frontal_attack"
  end,
  on_cost = function (self, event, target, player, data)
    event:setCostData(self, {tos = {data.to}})
    return true
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = data.to
    if to.dead then return end
    local cards = to:getCardIds("h")
    if #cards > 0 then
      player.room:viewCards(player, { cards = cards, skill_name = skel.name, prompt = "$ViewCardsFrom:"..to.id })
    end
    local choice = room:askToChoice(player, {
      choices = { "RFA_frontal", "RFA_raid" }, skill_name = skel.name,
      prompt = "#steam__tianzuo-choice:" .. data.from.id..":"..data.to.id
    })
    data.extra_data = data.extra_data or {}
    data.extra_data.RFAChosen = choice
  end,
})


return skel
