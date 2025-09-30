local shengyan = fk.CreateSkill {
  name = "steam__shengyan",
  dynamic_desc = function(self, player)
    local mark = player:getTableMark("steam__shengyan-round")
    local first = table.contains(mark, 1) and "令之无视防具<font color='red'>（已用）</font>" or "令之无视防具"
    local second = table.contains(mark, 2) and "令其中一名目标不可响应<font color='red'>（已用）</font>" or "令其中一名目标不可响应"
    return "每轮各限一次，你攻击范围内有角色成为伤害牌的目标后，你可以重铸一张同色牌，令之改为火属性并选择一项：1."..first.."；2."..second.."。"
  end,
}

Fk:loadTranslationTable{
  ["steam__shengyan"] = "升烟",
  [":steam__shengyan"] = "每轮各限一次，你攻击范围内有角色成为伤害牌的目标后，你可以重铸一张同色牌，令之改为火属性并选择一项：1.令之无视防具；2.令其中一名目标不可响应。",
  --【杀】改为火【杀】，其他伤害牌改为造成火焰伤害
  ["#steam__shengyan-invoke"] = "升烟：是否重铸一张%arg的牌，将此牌改为火属性？",
  ["#steam__shengyan-choose"] = "升烟：令%arg的一个目标不可响应此牌，或令此牌无视防具（未选择任何角色则视为选择无视防具一项）",

  ["$steam__shengyan1"] = "文火慢炖，不能着急。",
  ["$steam__shengyan2"] = "还不老实，那就别怪我下猛料了！",
}

shengyan:addEffect(fk.TargetConfirmed, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(shengyan.name) and #player:getTableMark("steam__shengyan-round") < 2 and not player:isAllNude()
    and table.find(data.use.tos, function(p) return player:inMyAttackRange(p) end) and data.card.is_damage_card and data.firstTarget
  end,
  on_cost = function (self, event, target, player, data)
    local color = data.card:getColorString()
    local cards = player.room:askToCards(player, {
      min_num = 1,
      max_num = 1,
      include_equip = true,
      pattern = ".|.|"..color,
      skill_name = shengyan.name,
      prompt = "#steam__shengyan-invoke:::"..color,
      cancelable = true,
    })
    if #cards > 0 then
      event:setCostData(self, {cards = cards})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:recastCard(event:getCostData(self).cards, player, shengyan.name)
    data.extra_data = data.extra_data or {}
    if data.card.trueName == "slash" then
      local use = room.logic:getCurrentEvent():findParent(GameEvent.UseCard, true)
      if use ~= nil and Fk.skills["fire__slash_skill"] then
        local new_card = Fk:cloneCard("fire__slash", data.card.suit, data.card.number)
        local c = table.simpleClone(data.card)
        for k, v in pairs(c) do
          if new_card[k] == nil then
            new_card[k] = v
          end
        end
        if data.card:isVirtual() then
          new_card.subcards = data.card.subcards
        else
          new_card.id = data.card.id
        end
        new_card.skillNames = data.card.skillNames
        new_card.skill = Fk.skills["fire__slash_skill"]
        data.card = new_card
        use.data.card = new_card
      end
    elseif data.card.trueName ~= "slash" then
      data.extra_data.steam__shengyan_damage = data.extra_data.steam__shengyan_damage or {}
      table.insert(data.extra_data.steam__shengyan_damage, player)
    end
    if not player.dead then
      if #player:getTableMark("steam__shengyan-round") == 1 and table.contains(player:getTableMark("steam__shengyan-round"), 2) then
        room:addTableMarkIfNeed(player, "steam__shengyan-round", 1)
        for _, p in ipairs(room.alive_players) do
          room:addTableMark(p, MarkEnum.MarkArmorInvalidFrom, player.id)
        end
        room.logic:getCurrentEvent():findParent(GameEvent.UseCard, true):addCleaner(function()
          for _, p in ipairs(room.alive_players) do
            room:removeTableMark(p, MarkEnum.MarkArmorInvalidFrom, player.id)
          end
        end)
      else
        local boolean = #player:getTableMark("steam__shengyan-round") == 1 and table.contains(player:getTableMark("steam__shengyan-round"), 1)
        local to = {}
        if boolean then
          to = room:askToChoosePlayers(player, {
            targets = data.use.tos,
            min_num = 1,
            max_num = 1,
            prompt = "#steam__shengyan-choose:::"..data.card:toLogString(),
            skill_name = shengyan.name,
            cancelable = false,
          })
        else
          to = room:askToChoosePlayers(player, {
            targets = data.use.tos,
            min_num = 1,
            max_num = 1,
            prompt = "#steam__shengyan-choose:::"..data.card:toLogString(),
            skill_name = shengyan.name,
            cancelable = true,
          })
        end
        if #to > 0 then
          room:addTableMarkIfNeed(player, "steam__shengyan-round", 2)
          data.use.disresponsiveList = data.use.disresponsiveList or {}
          table.insert(data.use.disresponsiveList, to[1])
        else
          room:addTableMarkIfNeed(player, "steam__shengyan-round", 1)
          for _, p in ipairs(room.alive_players) do
            room:addTableMark(p, MarkEnum.MarkArmorInvalidFrom, player.id)
          end
          room.logic:getCurrentEvent():findParent(GameEvent.UseCard, true):addCleaner(function()
            for _, p in ipairs(room.alive_players) do
              room:removeTableMark(p, MarkEnum.MarkArmorInvalidFrom, player.id)
            end
          end)
        end
      end
    end
  end,
})

shengyan:addEffect(fk.PreDamage, {
  can_refresh = function(self, event, target, player, data)
    if data.card then
      local e = player.room.logic:getCurrentEvent():findParent(GameEvent.UseCard, true)
      if e then
        local use = e.data
        return use.extra_data and use.extra_data.steam__shengyan_damage and table.contains(use.extra_data.steam__shengyan_damage, player)
      end
    end
  end,
  on_refresh = function(self, event, target, player, data)
    data.damageType = fk.FireDamage
  end,
})

return shengyan
