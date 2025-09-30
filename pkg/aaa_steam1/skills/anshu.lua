local skel = fk.CreateSkill {
  name = "steam__anshu",
  tags = {Skill.Compulsory},
}

Fk:loadTranslationTable{
  ["steam__anshu"] = "安庶",
  [":steam__anshu"] = "锁定技，当你于回合内使用手牌后，你将至少四张手牌置于牌堆顶并视为使用一张由你选择起始结算角色的【五谷丰登】。",

  ["#steam__anshu-card"] = "安庶：请将至少四张手牌置于牌堆顶",
  ["#steam__anshu-begin"] = "安庶：选择一名角色作为【五谷丰登】的起始结算角色",

  ["$steam__anshu1"] = "老幼有所养，天下皆享太平之福。",
  ["$steam__anshu2"] = "民有所食，此诚古贤所言之盛世。",
}

skel:addEffect(fk.CardUseFinished, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(skel.name) then
      return player:getHandcardNum() > 3 and player.phase ~= Player.NotActive and data:isUsingHandcard(player)
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cards = player:getCardIds("h")
    if #cards > 4 then
      cards = room:askToCards(player, { min_num = 4, max_num = 9999, include_equip = false,
      skill_name = skel.name, cancelable = false, prompt = "#steam__anshu-card"})
    end
    cards = room:askToGuanxing(player, {
      cards = cards, top_limit = {#cards, #cards}, bottom_limit = {0,0}, skill_name = skel.name, skip = true
    }).top
    room:moveCardTo(table.reverse(cards), Card.DrawPile, nil, fk.ReasonPut, skel.name, nil, false, player)
    if player.dead then return end
    local card = Fk:cloneCard("amazing_grace")
    card.skillName = skel.name
    if player:prohibitUse(card) then return end
    local tos = table.filter(room.alive_players, function (p) return not player:isProhibited(p, card) end)
    if #tos == 0 then return end
    local first = room:askToChoosePlayers(player, {
      min_num = 1, max_num = 1, targets = tos, skill_name = skel.name, cancelable = false, prompt = "#steam__anshu-begin"
    })[1]
    room:useCard{
      from = player,
      tos = tos,
      card = card,
      extra_data = {steam__anshu_beginner = first}
    }
  end,
})

skel:addEffect(fk.BeforeCardUseEffect, {
  can_refresh = function(self, event, target, player, data)
    return data.card.trueName == "amazing_grace" and table.contains(data.card.skillNames, skel.name)
    and data.extra_data and data.extra_data.steam__anshu_beginner
  end,
  on_refresh = function(self, event, target, player, data)
    local orig_tos, tos, first = data.tos, {}, data.extra_data.steam__anshu_beginner
    local temp = first
    repeat
      if table.contains(orig_tos, temp) then
        table.insert(tos, temp)
      end
      temp = temp.next
    until temp == first
    data.tos = tos
  end,
})

return skel
