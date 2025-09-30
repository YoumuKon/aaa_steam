local gangqi = fk.CreateSkill {
  name = "steam__gangqi",
  tags = { Skill.Combo },
  dynamic_desc = function (self, player, lang)
    if player:getMark("steam__gangqi_combo") == 0 then return end
    local str = "steam__gangqi_inner:"..
      Fk:translate(player:getMark("steam__gangqi_combo")[1])..":"..
      Fk:translate(player:getMark("steam__gangqi_combo")[2])
    for i = 1, 4 do
      str = str.. ":".. table.concat(table.map(player:getTableMark("steam__gangqi"..i), function (s)
        return Fk:translate(s)
      end))
    end
    return str
  end,
}

Fk:loadTranslationTable{
  ["steam__gangqi"] = "刚炁",
  [":steam__gangqi"] = "连招技（？+？），每次连招随机生成两个花色作为条件。<br>"..
  "完成连招：你摸一张牌并选择本次连招中的一个花色，令此后你使用此花色的牌时拥有以下一项未拥有的效果：<br>"..
  "轻拳：结算后你摸一张牌。<br>"..
  "重拳：此牌造成的伤害+1。<br>"..
  "鞭腿：造成伤害后可弃置目标一张牌。<br>"..
  "架势：指定目标后可重铸其一张牌。",

  [":steam__gangqi_inner"] = "连招技（{1}+{2}），每次连招随机生成两个花色作为条件。<br>"..
  "完成连招：你摸一张牌并选择本次连招中的一个花色，令此后你使用此花色的牌时拥有以下一项未拥有的效果：<br>"..
  "轻拳（{3}）：结算后你摸一张牌。<br>"..
  "重拳（{4}）：此牌造成的伤害+1。<br>"..
  "鞭腿（{5}）：造成伤害后可弃置目标一张牌。<br>"..
  "架势（{6}）：指定目标后可重铸其一张牌。",

  ["#steam__gangqi-suit"] = "刚炁：选择要获得增益的花色",
  ["#steam__gangqi-choice"] = "刚炁：选择令你使用%arg牌拥有的额外效果",
  ["steam__gangqi1"] = "轻拳：结算后摸一张牌",
  ["steam__gangqi2"] = "重拳：造成的伤害+1",
  ["steam__gangqi3"] = "鞭腿：造成伤害后可弃置目标一张牌",
  ["steam__gangqi4"] = "架势：指定目标后可重铸其一张牌",
  ["#steam__gangqi-discard"] = "刚炁：是否弃置 %dest 一张牌？",
  ["#steam__gangqi-recast"] = "刚炁：是否重铸 %dest 一张牌？",

  ["$steam__gangqi1"] = "劲发江潮落，气收秋毫平。",
  ["$steam__gangqi2"] = "千招百式在一息！",
  ["$steam__gangqi3"] = "形不成形，意不在意，再去练练吧。",
}

gangqi:addEffect(fk.CardUsing, {
  anim_type = "drawcard",
  audio_index = {1, 2},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(gangqi.name) and
      data.extra_data and data.extra_data.combo_skill and data.extra_data.combo_skill[gangqi.name]
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(player, gangqi.name, 0)
    player:drawCards(1, gangqi.name)
    if player.dead or not player:hasSkill(gangqi.name, true) then return end
    local suits = table.filter(player:getTableMark("steam__gangqi_combo"), function (s)
      return table.find({1, 2, 3, 4}, function (i)
        return not table.contains(player:getTableMark("steam__gangqi"..i), s)
      end) ~= nil
    end)
    if #suits > 0 then
      local suit = room:askToChoice(player, {
        choices = suits,
        skill_name = gangqi.name,
        prompt = "#steam__gangqi-suit",
      })
      local choices = table.filter({1, 2, 3, 4}, function (i)
        return not table.contains(player:getTableMark("steam__gangqi"..i), suit)
      end)
      if #choices > 0 then
        local choice = room:askToChoice(player, {
          choices = table.map(choices, function (i)
            return "steam__gangqi"..i
          end),
          skill_name = gangqi.name,
          prompt = "#steam__gangqi-choice:::"..suit,
        })
        room:addTableMark(player, choice, suit)
      end
    end
    if player:hasSkill(gangqi.name, true) then
      room:setPlayerMark(player, "steam__gangqi_combo", {
        table.random({"log_spade", "log_heart", "log_club", "log_diamond"}),
        table.random({"log_spade", "log_heart", "log_club", "log_diamond"}),
      })
    end
  end,
})

gangqi:addEffect(fk.AfterCardUseDeclared, {
  can_refresh = function (self, event, target, player, data)
    if target == player and player:hasSkill(gangqi.name, true) then
      local skill_effect = player.room.logic:getCurrentEvent():findParent(GameEvent.SkillEffect)
      if skill_effect == nil then
        return true
      else
        return not (skill_effect.data.skill.skeleton == gangqi and skill_effect.data.who == player)
      end
    end
  end,
  on_refresh = function (self, event, target, player, data)
    local room = player.room
    if player:getMark(gangqi.name) == 0 then
      if data.card:getSuitString(true) == player:getMark("steam__gangqi_combo")[1] then
        room:setPlayerMark(player, gangqi.name, 1)
      end
    elseif player:getMark(gangqi.name) == 1 then
      if data.card:getSuitString(true) == player:getMark("steam__gangqi_combo")[2] then
        data.extra_data = data.extra_data or {}
        data.extra_data.combo_skill = data.extra_data.combo_skill or {}
        data.extra_data.combo_skill[gangqi.name] = true
      else
        player:broadcastSkillInvoke(gangqi.name, 3)
        if data.card:getSuitString(true) == player:getMark("steam__gangqi_combo")[1] then
          room:setPlayerMark(player, gangqi.name, 1)
        else
          room:setPlayerMark(player, gangqi.name, 0)
        end
      end
    end
  end,
})

gangqi:addEffect(fk.PreCardUse, {
  can_refresh = function (self, event, target, player, data)
    return target == player
  end,
  on_refresh = function (self, event, target, player, data)
    for i = 1, 4 do
      if table.contains(player:getTableMark("steam__gangqi"..i), data.card:getSuitString(true)) then
        data.extra_data = data.extra_data or {}
        data.extra_data["steam__gangqi"..i] = true
      end
    end
    if data.extra_data and data.extra_data.steam__gangqi2 then
      data.additionalDamage = (data.additionalDamage or 0) + 1
    end
  end,
})

gangqi:addEffect(fk.CardUseFinished, {
  mute = true,
  is_delay_effect = true,
  can_trigger = function (self, event, target, player, data)
    return target == player and not player.dead and
      data.extra_data and data.extra_data.steam__gangqi1
  end,
  on_use = function (self, event, target, player, data)
    player:drawCards(1, gangqi.name)
  end,
})

gangqi:addEffect(fk.Damage, {
  mute = true,
  is_delay_effect = true,
  can_trigger = function (self, event, target, player, data)
    if target == player and not player.dead and
      data.card and not data.to.dead and not data.to:isNude() then
      local use_event = player.room.logic:getCurrentEvent():findParent(GameEvent.UseCard)
      return use_event and use_event.data.card == data.card and
        use_event.data.extra_data and use_event.data.extra_data.steam__gangqi3
    end
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    if room:askToSkillInvoke(player, {
      skill_name = gangqi.name,
      prompt = "#steam__gangqi-discard::"..data.to.id,
    }) then
      event:setCostData(self, {tos = {data.to}})
      return true
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    if data.to == player then
      room:askToDiscard(player, {
        min_num = 1,
        max_num = 1,
        include_equip = true,
        skill_name = gangqi.name,
        cancelable = false,
      })
    else
      local card = room:askToChooseCard(player, {
        target = data.to,
        flag = "he",
        skill_name = gangqi.name,
      })
      room:throwCard(card, gangqi.name, data.to, player)
    end
  end,
})

gangqi:addEffect(fk.TargetSpecified, {
  mute = true,
  is_delay_effect = true,
  can_trigger = function (self, event, target, player, data)
    return target == player and not player.dead and
      data.extra_data and data.extra_data.steam__gangqi4 and
      not data.to:isNude()
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    if room:askToSkillInvoke(player, {
      skill_name = gangqi.name,
      prompt = "#steam__gangqi-recast::"..data.to.id,
    }) then
      event:setCostData(self, {tos = {data.to}})
      return true
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local card = room:askToChooseCard(player, {
      target = data.to,
      flag = "he",
      skill_name = gangqi.name,
    })
    room:recastCard({card}, data.to, gangqi.name)
  end,
})

gangqi:addAcquireEffect(function (self, player, is_start)
  player.room:setPlayerMark(player, "steam__gangqi_combo", {
    table.random({"log_spade", "log_heart", "log_club", "log_diamond"}),
    table.random({"log_spade", "log_heart", "log_club", "log_diamond"}),
  })
end)

gangqi:addLoseEffect(function (self, player, is_death)
  local room = player.room
  room:setPlayerMark(player, "steam__gangqi_combo", 0)
  room:setPlayerMark(player, "steam__gangqi1", 0)
  room:setPlayerMark(player, "steam__gangqi2", 0)
  room:setPlayerMark(player, "steam__gangqi3", 0)
  room:setPlayerMark(player, "steam__gangqi4", 0)
end)

return gangqi
