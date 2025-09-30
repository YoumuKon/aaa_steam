local skel = fk.CreateSkill {
  name = "steam__zaizhu",
}

Fk:loadTranslationTable{
  ["steam__zaizhu"] = "再铸",
  [":steam__zaizhu"] = "连招技（其他角色使用牌+你使用牌），你可将你的手牌张数调整至这两张牌牌名字数之和；若你因此弃置至少两张牌，你可令一名其他角色调整手牌数至这两张牌牌名字数之差。",

  ["#steam__zaizhu-draw"] = "再铸：你可以摸 %arg 张牌",
  ["#steam__zaizhu-cost"] = "再铸：你可以弃置 %arg 张手牌，若至少弃2张，可将一名其他角色手牌调整至%arg2张",
  ["#steam__zaizhu-choose"] = "再铸：你可令一名其他角色调整手牌至%arg",
}

skel:addEffect(fk.CardUsing, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(skel.name) and
      data.extra_data and data.extra_data.combo_skill and data.extra_data.combo_skill[skel.name]
      and data.extra_data[skel.name] and data.extra_data[skel.name].plus ~= player:getHandcardNum()
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local plus = data.extra_data[skel.name].plus
    local minus = data.extra_data[skel.name].minus
    local num = player:getHandcardNum() - plus
    if num > 0 then
      local cards = room:askToDiscard(player, {
        min_num = num, max_num = num, include_equip = false, skill_name = skel.name, cancelable = true,
        prompt = "#steam__zaizhu-cost:::"..num..":"..minus, skip = true
      })
      if #cards > 0 then
        event:setCostData(self, {cards = cards})
        return true
      end
    else
      event:setCostData(self, {cards = {}})
      return room:askToSkillInvoke(player, { skill_name = skel.name, prompt = "#steam__zaizhu-draw:::"..(-num)})
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local plus, minus = data.extra_data[skel.name].plus, data.extra_data[skel.name].minus
    local cards = event:getCostData(self).cards
    if cards and #cards > 0 then
      room:throwCard(cards, skel.name, player, player)
      if player.dead or #cards < 2 then return end
      local targets = room:getOtherPlayers(player, false)
      local to = room:askToChoosePlayers(player, {
        min_num = 1, max_num = 1, skill_name = skel.name, cancelable = true, targets = room:getOtherPlayers(player, false),
        prompt = "#steam__zaizhu-choose:::"..minus,
      })[1]
      if to then
        local num = to:getHandcardNum() - minus
        if num > 0 then
          room:askToDiscard(to, {min_num = num, max_num = num, include_equip = false, skill_name = skel.name, cancelable = false})
        elseif num < 0 then
          to:drawCards(-num, skel.name)
        end
      end
    else
      player:drawCards(plus - player:getHandcardNum(), skel.name)
    end
  end,
})

skel:addEffect(fk.CardUsing, {
  can_refresh = function (self, event, target, player, data)
    return target == player and player:hasSkill(skel.name, true)
  end,
  on_refresh = function (self, event, target, player, data)
    local current = player.room.logic:getCurrentEvent():findParent(GameEvent.UseCard, true)
    if current == nil then return end
    local last = player.room.logic:getEventsByRule(GameEvent.UseCard, 1, function (e)
      return e.id < current.id
    end, 1)[1]
    if last and last.data.from ~= player then
      local lastCard = last.data.card
      local plus = Fk:translate(data.card.trueName, "zh_CN"):len() + Fk:translate(lastCard.trueName, "zh_CN"):len()
      local minus = math.abs(Fk:translate(data.card.trueName, "zh_CN"):len() - Fk:translate(lastCard.trueName, "zh_CN"):len())
      data.extra_data = data.extra_data or {}
      data.extra_data.combo_skill = data.extra_data.combo_skill or {}
      data.extra_data.combo_skill[skel.name] = true
      data.extra_data[skel.name] = {plus = plus, minus = minus}
    end
  end,
})

return skel
