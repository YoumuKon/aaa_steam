local ranjing = fk.CreateSkill{
  name = "steam__ranjing",
  tags = { Skill.Hidden },
}

Fk:loadTranslationTable{
  ["steam__ranjing"] = "染境",
  [":steam__ranjing"] = "隐匿技，你登场后，摸一张能对自己使用的牌，然后获得一张<a href=':steam_ranjing_equip'>【旦夕墨宝】</a>并可令一名角色使用之。"..
  "你失去某区域最后一张牌后隐匿。",

  ["#steam__ranjing-choose"] = "染境：令一名角色使用此【旦夕墨宝】",

  ["$steam__ranjing1"] = "那就赶紧了结吧。",
  ["$steam__ranjing2"] = "我对你们还算是有感情的，大多数时候。",
}

local U = require "packages.utility.utility"
local DIY = require "packages.diy_utility.diy_utility"

ranjing:addEffect(U.GeneralAppeared, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasShownSkill(ranjing.name)
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local list = {}
    for _, id in ipairs (room.draw_pile) do
      local card = Fk:getCardById(id)
      local tos = card:getFixedTargets(player)
      if tos and table.find(tos, function(p)
        return not player:isProhibited(p, card)
      and Util.CardTargetFilter(card.skill, player, p, {}, card.subcards, card) end) ~= nil then
        table.insertIfNeed(list, id)
      end
    end
    if #list == 0 then
      for _, id in ipairs (room.discard_pile) do
        local card = Fk:getCardById(id)
        local tos = card:getFixedTargets(player)
        if tos and table.find(tos, function(p)
          return not player:isProhibited(p, card)
        and Util.CardTargetFilter(card.skill, player, p, {}, card.subcards, card) end) ~= nil then
          table.insertIfNeed(list, id)
        end
      end
    end
    if #list > 0 then
      room:obtainCard(player, {table.random(list, 1)}, true, fk.ReasonJustMove, player, ranjing.name)
    end
    if player.dead then return end
    local get = {}
    table.insert(get, room:printCard("steam_ranjing_equip", Card.Spade, 11):getEffectiveId())
    room:setCardMark(Fk:getCardById(get[1]), MarkEnum.DestructOutEquip, 1)
    room:obtainCard(player, get, true, fk.ReasonJustMove, player, ranjing.name)
    local targets = table.filter(room.alive_players, function (p)
      return p:canUseTo(Fk:cloneCard("steam_baizao_equip", Card.Heart, 12), p)
    end)
    if #targets == 0 or player.dead or not table.contains(player:getCardIds("h"), get[1]) then return end
    local to = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = targets,
      skill_name = ranjing.name,
      prompt = "#steam__ranjing-choose",
      cancelable = true,
    })
    if #to > 0 then
      room:useCard{
        from = to[1],
        tos = { to[1] },
        card = Fk:getCardById(get[1]),
      }
    end
  end,
})

ranjing:addEffect(fk.AfterCardsMove, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(ranjing.name) then
      for _, move in ipairs(data) do
        if move.from and move.from == player and not move.from.dead then
          for _, info in ipairs(move.moveInfo) do
            if (info.fromArea == Card.PlayerHand and move.from:isKongcheng()) or
              (info.fromArea == Card.PlayerEquip and #move.from:getCardIds("e") == 0) or
              (info.fromArea == Card.PlayerJudge and #move.from:getCardIds("j") == 0) then
              return true
            end
          end
        end
      end
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    DIY.enterHidden(player)
  end,
})

--不因本技能产生的旦夕墨宝不触发销毁和防止弃置，此事在店长召唤出的其他装备亦有记载（也许？）
ranjing:addEffect(fk.BeforeCardsMove, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if #player:getEquipments(Card.SubtypeArmor) == 0 then return false end
    for _, move in ipairs(data) do
      if move.from == player and move.moveReason == fk.ReasonDiscard and move.proposer ~= player then
        for _, info in ipairs(move.moveInfo) do
          if info.fromArea == Card.PlayerEquip and Fk:getCardById(info.cardId).name == "steam_ranjing_equip" and
            Fk:getCardById(info.cardId).sub_type == Card.SubtypeArmor then
            return true
          end
        end
      end
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local ids = {}
    for _, move in ipairs(data) do
      if move.from == player and move.moveReason == fk.ReasonDiscard and move.proposer ~= player then
        for _, info in ipairs(move.moveInfo) do
          if info.fromArea == Card.PlayerEquip and Fk:getCardById(info.cardId).name == "steam_ranjing_equip" and
            Fk:getCardById(info.cardId).sub_type == Card.SubtypeArmor then
            table.insertIfNeed(ids, info.cardId)
          end
        end
      end
    end
    player.room:cancelMove(data, ids)
  end,
})

return ranjing
