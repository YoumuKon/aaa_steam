local skel = fk.CreateSkill {
  name = "steam__rongyaochongzhuang",
}

Fk:loadTranslationTable{
  ["steam__rongyaochongzhuang"] = "荣耀冲撞",
  [":steam__rongyaochongzhuang"] = "轮次结束时，你可以重铸一种花色的手牌并移动至多等量个座次，然后你可以将本次获得的一种花色的牌当【出其不意】对一名邻家使用。",

  ["#steam__rongyaochongzhuang-suit"] = "荣耀冲撞：你可以重铸一种花色所有手牌，然后移动至多等量的座次",
  ["#steam__rongyaochongzhuang-dir"] = "荣耀冲撞：你可以移动一格座位（第 %arg 次，共 %arg2 次）",
  ["steam__rycz_active"] = "",
  ["#steam__rongyaochongzhuang-atk"] = "荣耀冲撞：选择1种花色，将重铸获得的此花色牌当【出其不意】对邻家使用",

  ["clockwisedir"] = "←顺时针",
  ["anticlockwisedir"] = "逆时针→",

  ["$steam__rongyaochongzhuang1"] = "啊！芬达！",
  ["$steam__rongyaochongzhuang2"] = "多玛！多玛！多玛多玛多玛",
}

skel:addEffect(fk.RoundEnd, {
  anim_type = "drawcard",
  mute = true,
  priority = 0.9,
  can_trigger = function (self, event, target, player, data)
    return player:hasSkill(skel.name) and not player:isKongcheng()
  end,
  on_cost = function (self, event, target, player, data)
    local suits = {}
    for _, id in ipairs(player:getCardIds("h")) do
      table.insertIfNeed(suits, Fk:getCardById(id):getSuitString(true))
    end
    table.insertIfNeed(suits, "Cancel")
    local suit = player.room:askToChoice(player, { choices = suits, skill_name = skel.name, prompt = "#steam__rongyaochongzhuang-suit"})
    if suit ~= "Cancel" then
      event:setCostData(self, {suit = suit})
      return true
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke(skel.name, 1)
    room:notifySkillInvoked(player, skel.name, "control")
    local suit = event:getCostData(self).suit
    local cards = table.filter(player:getCardIds("h"), function(id)
      return Fk:getCardById(id):getSuitString(true) == suit
    end)
    local num = #cards
    cards = room:recastCard(cards, player, skel.name)
    for i = 1, num do
      if player.dead or player:getNextAlive(true) == player then return end
      local dir = room:askToChoice(player, {
        choices = {"clockwisedir", "Cancel", "anticlockwisedir"}, skill_name = skel.name,
        prompt = "#steam__rongyaochongzhuang-dir:::"..i..":"..num,
      })
      if dir == "Cancel" then break end
      local to = player:getLastAlive(true)
      if dir == "anticlockwisedir" then
        to = player:getNextAlive(true)
      end
      room:swapSeat(player, to)
    end
    cards = table.filter(cards, function(id) return table.contains(player:getCardIds("h"), id) end)
    if #cards == 0 then return end
    local suits = {}
    for _, id in ipairs(cards) do
      local s = Fk:getCardById(id):getSuitString(true)
      table.insertIfNeed(suits, s)
    end
    if #suits == 0 then return end
    local _, dat = room:askToUseActiveSkill(player, {
      skill_name = "steam__rycz_active", prompt =  "#steam__rongyaochongzhuang-atk",
      extra_data = {rycz_suits = suits, rycz_cards = cards},
    })
    if dat then
      player:broadcastSkillInvoke(skel.name, 2)
      local to = dat.targets[1]
      local subcards = table.filter(cards, function(id) return Fk:getCardById(id):getSuitString(true) == dat.interaction end)
      local card = Fk:cloneCard("unexpectation")
      card:addSubcards(subcards)
      card.suit = Fk:getCardById(subcards[1]).suit
      room:useCard{from = player, tos = {to}, card = card}
    end
  end,
})

local skel2 = fk.CreateSkill {
  name = "steam__rycz_active",
}

skel2:addEffect("active", {
  min_card_num = 0,
  target_num = 1,
  interaction = function (self, player)
    if not self.rycz_suits then return end
    return UI.ComboBox { choices = self.rycz_suits }
  end,
  card_filter = function (self, player, to_select, selected)
    if self.interaction.data and self.rycz_cards then
      return Fk:getCardById(to_select):getSuitString(true) == self.interaction.data
      and table.contains(self.rycz_cards, to_select)
    end
  end,
  target_filter = function (self, player, to, selected, selected_cards)
    if #selected == 0 and (to:getNextAlive() == player or player:getNextAlive() == to) then
      local suit, cards = self.interaction.data, self.rycz_cards
      if not suit or not cards then return false end
      local subcards = table.filter(cards, function(id) return Fk:getCardById(id):getSuitString(true) == suit end)
      if #subcards == 0 then return false end
      local card = Fk:cloneCard("unexpectation")
      card:addSubcards(subcards)
      card.suit = Fk:getCardById(subcards[1]).suit
      return player:canUseTo(card, to)
    end
  end,
})

return {skel,skel2}
