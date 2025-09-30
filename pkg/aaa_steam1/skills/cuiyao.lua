local skel = fk.CreateSkill {
  name = "steam__cuiyao",
}

Fk:loadTranslationTable{
  ["steam__cuiyao"] = "淬曜",
  [":steam__cuiyao"] = "你可将任意张牌当做你本回合未使用过的牌名字数不超过X的伤害牌使用，若这些牌：类型各不相同，其造成的伤害视为火属性；花色各不相同，你可以横置至多X名角色；（X为转化底牌数量）",

  ["#steam__cuiyao"] = "你可将任意张牌当做你本回合未使用过的牌名字数不超过底牌数的伤害牌使用",
  ["#steam__cuiyao-chain"] = "淬曜：你可以横置至多 %arg 名角色",
  ["#SteamCuiyaoDamageLog"] = "%arg 将造成的伤害改为<font color='red'>火焰</font>伤害",
}

skel:addEffect("viewas", {
  anim_type = "offensive",
  mute_card = false,
  prompt = "#steam__cuiyao",
  pattern = ".|.|.|.|.|basic,trick",
  interaction = function(self, player)
    local mark = player:getTableMark("steam__cuiyao-turn")
    local all_choices = table.filter(Fk:getAllCardNames("bt"), function (name)
      return Fk:cloneCard(name).is_damage_card and not table.contains(mark, Fk:cloneCard(name).trueName)
    end)
    local choices = player:getViewAsCardNames(skel.name, all_choices)
    if #choices > 0 then
      return UI.CardNameBox { choices = choices, all_choices = all_choices }
    end
  end,
  handly_pile = true,
  card_filter = Util.TrueFunc,
  view_as = function (self, player, cards)
    if #cards == 0 or not self.interaction.data then return end
    local card = Fk:cloneCard(self.interaction.data)
    if Fk:translate(card.trueName, "zh_CN"):len() > #cards then return nil end
    card:addSubcards(cards)
    card.skillName = skel.name
    return card
  end,
  before_use = function(self, player, use)
    use.extra_data = use.extra_data or {}
    use.extra_data.steam__cuiyao_from = player.id
    local cards = use.card.subcards
    local types, suits = {}, {}
    for _, cid in ipairs(cards) do
      table.insertIfNeed(types, Fk:getCardById(cid).type)
      table.insertIfNeed(suits, Fk:getCardById(cid).suit)
    end
    -- 仅有1张也算不相同
    if #types == #cards then
      use.extra_data.steam__cuiyao_fire = true
      player.room:sendLog {type = "#SteamCuiyaoDamageLog", arg = use.card:toLogString(), toast = true}
    end
    if #suits == #cards then
      use.extra_data.steam__cuiyao_chain = #cards
    end
  end,
  enabled_at_play = function(self, player)
    return true
  end,
  enabled_at_response = function(self, player, response)
    if response then return false end
    local mark = player:getTableMark("steam__cuiyao-turn")
    return #table.filter(player:getViewAsCardNames(skel.name, Fk:getAllCardNames("bt")), function (name)
      return not table.contains(mark, Fk:cloneCard(name).trueName) and Fk:cloneCard(name).is_damage_card
    end) > 0
  end,
})

skel:addAcquireEffect(function (self, player, is_start)
  local mark = {}
  local turn_event = player.room.logic:getCurrentEvent():findParent(GameEvent.Turn)
  if turn_event == nil then return end
  local use
  player.room.logic:getEventsByRule(GameEvent.UseCard, 1, function (e)
    use = e.data
    if use.from == player then
      table.insertIfNeed(mark, use.card.trueName)
    end
    return false
  end, turn_event.id)
  player.room:setPlayerMark(player, "steam__cuiyao-turn", mark)
end)

skel:addEffect(fk.CardUsing, {
  is_delay_effect = true,
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return not player.dead and data.extra_data and data.extra_data.steam__cuiyao_from == player.id
      and data.extra_data.steam__cuiyao_chain
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local n = data.extra_data.steam__cuiyao_chain
    local tos = room:askToChoosePlayers(player, {
      min_num = 1, max_num = n, targets = room.alive_players, skill_name = skel.name,
      prompt = "#steam__cuiyao-chain:::"..n,
    })
    if #tos == 0 then return end
    room:sortByAction(tos)
    for _, to in ipairs(tos) do
      if not to.dead and not to.chained then
        to:setChainState(true)
      end
    end
  end,
})

skel:addEffect(fk.PreDamage, {
  can_refresh = function(self, event, target, player, data)
    if data.damageType ~= fk.FireDamage then
      local parentEvent = player.room.logic:getCurrentEvent():findParent(GameEvent.CardEffect)
      if parentEvent then
        local use = parentEvent.data
        return use.card == data.card and use.extra_data and use.extra_data.steam__cuiyao_fire
      end
    end
  end,
  on_refresh = function(self, event, target, player, data)
    data.damageType = fk.FireDamage
  end,
})

skel:addEffect(fk.AfterCardUseDeclared, {
  can_refresh = function(self, event, target, player, data)
    return target == player and player:hasSkill(skel.name, true)
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:addTableMarkIfNeed(player, "steam__cuiyao-turn", data.card.trueName)
  end,
})


return skel
