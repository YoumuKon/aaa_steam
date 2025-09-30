local skel = fk.CreateSkill {
  name = "steam__bushi",
  dynamic_desc = function (self, player, lang)
    local mark = player:getMark(self.name)
    if mark ~= 0 then
      local args = {}
      for i = 1, 3 do
        local arg = Fk:translate("steam__bushi"..i, lang)
        if table.contains(mark, i) then -- 无效项变灰
          arg = "<font color='grey'>" .. arg .. "</font>"
        end
        table.insert(args, arg)
      end
      return "steam__bushi_dyn:" .. table.concat(args, ":")
    end
  end,
}

Fk:loadTranslationTable{
  ["steam__bushi"] = "补世",
  [":steam__bushi"] = "你使用一张牌后，你可重铸三/二/一张花色/类别/颜色均不同且与使用牌不同的牌，再摸等量张牌；然后你不能因此重铸相等张数的牌，直到牌堆洗切/本轮结束/本回合结束。",

  [":steam__bushi_dyn"] = "你使用一张牌后，你可重铸{3}/{2}/{1}且与使用牌不同的牌，再摸等量张牌；然后你不能因此重铸相等张数的牌，直到牌堆洗切/本轮结束/本回合结束。",

  ["steam__bushi_active"] = "补世",
  ["#steam__bushi-card"] = "补世：你可重铸三/二/一张与%arg花色/类别/颜色均不同的牌，再摸等量张牌",
  ["steam__bushi1"] = "1张颜色不同的牌",
  ["steam__bushi2"] = "2张类别不同的牌",
  ["steam__bushi3"] = "3张花色不同的牌",
}

skel:addEffect(fk.CardUseFinished, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    if player == target and player:hasSkill(skel.name) then
      return table.find({1, 2, 3}, function (num)
        return #player:getCardIds("he") >= num and not table.contains(player:getTableMark(skel.name), num)
      end)
    end
  end,
  on_cost = function (self, event, target, player, data)
    local _, dat = player.room:askToUseActiveSkill(player, {
      skill_name = "steam__bushi_active", prompt = "#steam__bushi-card:::"..data.card:toLogString(),
      extra_data = {steam__bushi_info = {suit = data.card.suit, type = data.card.type, color = data.card.color} }
    })
    if dat then
      event:setCostData(self, { cards = dat.cards })
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cards = event:getCostData(self).cards
    local num = #cards
    room:addTableMark(player, skel.name, num)
    room:recastCard(cards, player, skel.name)
    if not player.dead then
      player:drawCards(num, skel.name)
    end
  end,
})


skel:addEffect(fk.AfterDrawPileShuffle, {
  can_refresh = function(self, event, target, player, data)
    return player:hasSkill(skel.name, true)
  end,
  on_refresh = function (self, event, target, player, data)
    player.room:removeTableMark(player, skel.name, 3)
  end,
})

skel:addEffect(fk.RoundEnd, {
  late_refresh = true,
  can_refresh = function(self, event, target, player, data)
    return player:hasSkill(skel.name, true)
  end,
  on_refresh = function (self, event, target, player, data)
    player.room:removeTableMark(player, skel.name, 2)
  end,
})

skel:addEffect(fk.TurnEnd, {
  late_refresh = true,
  can_refresh = function(self, event, target, player, data)
    return player:hasSkill(skel.name, true)
  end,
  on_refresh = function (self, event, target, player, data)
    player.room:removeTableMark(player, skel.name, 1)
  end,
})

local skel2 = fk.CreateSkill {
  name = "steam__bushi_active",
}

skel2:addEffect("active", {
  interaction = function (self, player)
    local all_choices, choices = {}, {}
    for i = 1, 3 do
      local c = "steam__bushi"..i
      table.insert(all_choices, c)
      if not table.contains(player:getTableMark("steam__bushi"), i) then
        table.insert(choices, c)
      end
    end
    if #choices > 0 then
      return UI.ComboBox { choices = choices, all_choices = all_choices }
    end
  end,
  card_filter = function (self, player, to_select, selected)
    local choice = self.interaction.data
    if choice and type(self.steam__bushi_info) == "table" then
      local num = tonumber(choice:sub(-1, -1))
      if #selected < num then
        if num == 1 then
          return Fk:getCardById(to_select).color ~= self.steam__bushi_info.color
        end
        local all, ret = {to_select}, {}
        table.insertTable(all, selected)
        if num == 2 then
          for _, id in ipairs(all) do
            table.insertIfNeed(ret, Fk:getCardById(id).type)
          end
          table.insertIfNeed(ret, self.steam__bushi_info.type)
        else
          for _, id in ipairs(all) do
            table.insertIfNeed(ret, Fk:getCardById(id).suit)
          end
          table.insertIfNeed(ret, self.steam__bushi_info.suit)
        end
        return #ret == (#all + 1)
      end
    end
  end,
  target_filter = Util.FalseFunc,
  feasible = function (self, player, _, selected_cards)
    local choice = self.interaction.data
    return type(choice) == "string" and #selected_cards == tonumber(choice:sub(-1, -1))
  end,
})


return {skel, skel2}
