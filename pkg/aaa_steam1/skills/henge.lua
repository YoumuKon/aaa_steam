local skel = fk.CreateSkill {
  name = "steam__henge",
  tags = {Skill.Compulsory},
}

Fk:loadTranslationTable{
  ["steam__henge"] = "衡扼",
  [":steam__henge"] = "锁定技，你使用暗置牌造成伤害后，弃置半数取上张明置牌；你使用明置牌造成伤害后，摸暗置牌的半数取下张牌。",
}

local DIY = require "packages/diy_utility/diy_utility"

skel:addEffect(fk.Damage, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(skel.name) and data.card then
      local useEvent = player.room.logic:getCurrentEvent():findParent(GameEvent.UseCard)
      if useEvent then
        local use = useEvent.data
        return use.from == player and data.card == use.card and use.extra_data and use.extra_data.steam__hengeInfo
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local useEvent = room.logic:getCurrentEvent():findParent(GameEvent.UseCard)
    if useEvent == nil then return end
    local use = useEvent.data
    local shown = DIY.getShownCards(player)
    if use.extra_data.steam__hengeInfo == "hidden" then
      player:broadcastSkillInvoke(skel.name, 1)
      room:notifySkillInvoked(player, skel.name, "negative")
      if #shown > 0 then
        local num = math.ceil(#shown / 2)
        room:askToDiscard(player, { min_num = num, max_num = num, include_equip = false,
          skill_name = skel.name, cancelable = false, pattern = tostring(Exppattern{ id = shown })
        })
      end
    else
      player:broadcastSkillInvoke(skel.name, 2)
      room:notifySkillInvoked(player, skel.name, "drawcard")
      local hidden = table.filter(player:getCardIds("h"), function (id)
        return not table.contains(shown, id)
      end)
      local num = math.floor(#hidden / 2)
      if num > 0 then
        player:drawCards(num, skel.name)
      end
    end
  end,
})

-- 使用牌前监测此牌是暗置还是明置牌
-- 注意，只有使用牌全部为暗置，或全部明置才能触发
skel:addEffect(fk.PreCardUse, {
  can_refresh = function (self, event, target, player, data)
    return target == player and player:hasSkill(skel.name, true)
  end,
  on_refresh = function (self, event, target, player, data)
    local cards = Card:getIdList(data.card)
    if #cards == 0 then return end
    local shown = table.filter(cards, function (id)
      return table.contains(DIY.getShownCards(player), id)
    end)
    data.extra_data = data.extra_data or {}
    if #shown == #cards then
      data.extra_data.steam__hengeInfo = "shown"
    elseif #shown == 0 then
      data.extra_data.steam__hengeInfo = "hidden"
    end
  end,
})

return skel
