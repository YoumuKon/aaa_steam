local skel = fk.CreateSkill {
  name = "steam__qiangyin",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["steam__qiangyin"] = "强音",
  [":steam__qiangyin"] = "锁定技，你的初始手牌与你获得的手牌添加未激活的随机<a href='steam__instrument-href'>乐器标记</a>，于你整肃成功后激活。",

  ["steam__instrument-href"] = 
  "能随机到以下标记，标记被激活至少一次后，你获得对应项的效果：<br>"..
  "胡笳：你失去“胡笳”后，获得随机一至三张花色各不相同的牌。<br>"..
  "檀板：你使用“檀板”牌后，可以展示一张非“檀板”的即时牌视为使用之。<br>"..
  "激鼓：每轮限一次，你造成或受到伤害后，若你手牌中的“激鼓”牌数等于装备区牌数，你摸装备栏空位张牌。<br>"..
  "弦：你失去“弦”牌后，防止本回合你下次受到的伤害。<br>"..
  "笛：准备或结束阶段，你卜算等同于你手牌中“笛”数量的牌（至少一张，至多八张）。<br>"..
  "琴：准备阶段，你获得弃牌堆中所有的“琴”牌。<br>"..
  "额外地，这些标记牌即便在被激活后，也计入你的手牌上限。",

  ["@steam__qiangyin-inhand"] = "",
  ["#steam__qiangyin-tanban"] = "强音：您使用的檀板牌结算完毕，是否展示一张非檀板即时牌，视为使用之？",
  ["@steam__qiangyin"] = "强音",
  ["@@steam__qiangyin__skel-turn"] = "强音 焦尾免伤",

  ["$steam__qiangyin1"] = " ",
  ["$steam__qiangyin2"] = " ",
}

local U = require "packages.utility.utility"

skel:addLoseEffect(function (self, player, is_death)
  local room = player.room
  for _, id in ipairs(player:getCardIds("h")) do
    room:setCardMark(Fk:getCardById(id), "@steam__qiangyin-inhand", 0)
  end
  room:setPlayerMark(player, "@steam__qiangyin", 0)
  room:setPlayerMark(player, "steam__qiangyin_qiqin", 0)
  room:setPlayerMark(player, "steam__qiangyin_hujia", 0)
  room:setPlayerMark(player, "steam__qiangyin_jiaowei", 0)
  room:setPlayerMark(player, "steam__qiangyin_jigu", 0)
end)

--游戏开始时，标记初始手牌（如果已经是琴，那么先记录为琴）
skel:addEffect(fk.GameStart, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(skel.name) and not player:isKongcheng()
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cards = player:getCardIds("h")
    local list = {"胡笳X", "檀板X", "激鼓X", "弦X", "笛X", "琴X"}
    for _, id in ipairs(cards) do
      if table.contains(player:getTableMark("steam__qiangyin_qiqin"), id) then
        room:setCardMark(Fk:getCardById(id), "@steam__qiangyin-inhand", "琴")
      end
      if Fk:getCardById(id):getMark("@steam__qiangyin-inhand") == 0 then
        room:setCardMark(Fk:getCardById(id), "@steam__qiangyin-inhand", table.random(list, 1)[1])
      end
    end
  end,
})

--你获得牌时，标记手牌（如果已经是琴，那么先记录为琴）
skel:addEffect(fk.AfterCardsMove, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(skel.name) then
      local cards = {}
      for _, move in ipairs(data) do
        if move.to == player and move.toArea == Player.Hand then
          for _, info in ipairs(move.moveInfo) do
            local id = info.cardId
            if table.contains(player:getCardIds("h"), id) then
              table.insertIfNeed(cards, id)
            end
          end
        end
      end
      cards = player.room.logic:moveCardsHoldingAreaCheck(cards)
      if #cards > 0 then
        event:setCostData(self, {cards = cards})
        return true
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local list = {"胡笳X", "檀板X", "激鼓X", "弦X", "笛X", "琴X"}
    for _, id in ipairs(event:getCostData(self).cards) do
      if table.contains(player:getTableMark("steam__qiangyin_qiqin"), id) then
        room:setCardMark(Fk:getCardById(id), "@steam__qiangyin-inhand", "琴")
      end
      if Fk:getCardById(id):getMark("@steam__qiangyin-inhand") == 0 then
        room:setCardMark(Fk:getCardById(id), "@steam__qiangyin-inhand", table.random(list, 1)[1])
      end
    end
  end,
})

--整肃成功后，激活标记
skel:addEffect(fk.EventPhaseEnd, {
  mute = true,
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    if target == player and player.phase == Player.Discard and not player.dead and player:hasSkill(skel.name) then
      --由于没有特定的整肃成功时机（用领取奖励的时机可能因为某些技能被取消），故遍历场上所有技能寻找成功整肃的数据
      for _, p in ipairs(player.room:getAllPlayers()) do
        for _, str in ipairs(p:getSkillNameList()) do
          if U.checkZhengsu(player, target, str) then
            return true
          end
        end
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cards = player:getCardIds("h")
    local list = {"胡笳", "檀板", "激鼓", "弦", "笛", "琴"}
    for _, id in ipairs(cards) do
      for _, is in ipairs(list) do
        if Fk:getCardById(id):getMark("@steam__qiangyin-inhand") == is.."X" then
          room:setCardMark(Fk:getCardById(id), "@steam__qiangyin-inhand", is)
          if is == "激鼓" then
            room:addTableMarkIfNeed(player, "@steam__qiangyin", "激鼓") --激活激鼓
          elseif is == "笛" then
            room:addTableMarkIfNeed(player, "@steam__qiangyin", "羲笛") --激活羲笛
          elseif is == "胡笳" then
            room:addTableMarkIfNeed(player, "steam__qiangyin_hujia", id) --记录胡笳的牌表方便判断失去
          elseif is == "弦" then
            room:addTableMarkIfNeed(player, "steam__qiangyin_jiaowei", id) --记录弦的牌表方便判断失去
          elseif is == "琴" then
            room:addTableMarkIfNeed(player, "steam__qiangyin_qiqin", id) --记录琴的牌表方便回收
          end
        end
      end
    end
  end,
})

--胡笳（乐蔡文姬）：失去牌补充花色，其实是悲愤技能的效果
skel:addEffect(fk.AfterCardsMove, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(skel.name) and player:getMark("steam__qiangyin_hujia") ~= 0 then
      local cards = {}
      for _, move in ipairs(data) do
        if move.from == player then
          for _, info in ipairs(move.moveInfo) do
            if info.fromArea == Card.PlayerHand and table.contains(player:getTableMark("steam__qiangyin_hujia"), info.cardId) then
              table.insertIfNeed(cards, info.cardId)
            end
          end
        end
      end
      if #cards > 0 then
        event:setCostData(self, {cards = cards})
        return true
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    for _, id in ipairs(event:getCostData(self).cards) do
      room:removeTableMark(player, "steam__qiangyin_hujia", id)
    end
    room:setPlayerMark(player, "steam__qiangyin_hujia", #player:getTableMark("steam__qiangyin_hujia"))
    local num = math.random(1, 3)
    local cards = {}
    for _, ids in ipairs(room.draw_pile) do
      if not table.find(cards, function (idss) return Fk:getCardById(idss).suit == Fk:getCardById(ids).suit end) then
        table.insertIfNeed(cards, ids)
      end
      if #cards >= num then break end
    end
    if #cards > 0 then
      room:moveCards({
        ids = cards,
        to = player,
        toArea = Card.PlayerHand,
        moveReason = fk.ReasonPrey,
        proposer = player,
        skillName = skel.name,
      })
    end
  end,
})

--檀板（乐貂蝉）：展示牌视为使用，其实是低讴技能的效果
skel:addEffect(fk.PreCardUse, {
  can_refresh = function (self, event, target, player, data)
    return target == player and player:hasSkill(skel.name, true) and data.card:getMark("@steam__qiangyin-inhand") ~= 0
    and data.card:getMark("@steam__qiangyin-inhand") == "檀板"
  end,
  on_refresh = function (self, event, target, player, data)
    data.extra_data = data.extra_data or {}
    data.extra_data.usingSteamTanban = true
  end,
})

skel:addEffect(fk.CardUseFinished, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(skel.name) and
      not player:isKongcheng() and (data.extra_data or {}).usingSteamTanban
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local ids = {}
    for _, id in ipairs(player:getCardIds("h")) do
      if Fk:getCardById(id):getMark("@steam__qiangyin-inhand") ~= "檀板" 
      and (Fk:getCardById(id).type == Card.TypeBasic or Fk:getCardById(id):isCommonTrick())
      and #Fk:getCardById(id):getDefaultTarget(player, {bypass_times= true}) > 0 then
        table.insert(ids, id)
      end
    end
    if #ids == 0 then return false end
    local cards = room:askToCards(player, {
      min_num = 1,
      max_num = 1,
      pattern = tostring(Exppattern{ id = ids }),
      prompt = "#steam__qiangyin-tanban",
      skill_name = skel.name,
      cancelable = true,
    })
    if #cards > 0 then
      event:setCostData(self, {cards = cards})
    end
    return #cards > 0
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local id = event:getCostData(self).cards[1]
    player:showCards(id)
    if player.dead then return end
    local card = Fk:getCardById(id)
    if card.type == Card.TypeBasic or card:isCommonTrick() then
      room:askToUseVirtualCard(player, {
      name = card.name,
      skill_name = skel.name,
      cancelable = true,
      extra_data = {
        bypass_times = true,
        extraUse = true,
      },
    })
    end
  end,
})

--激鼓：造成或受到伤害后摸装备区空位数牌
local spec = {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(skel.name) and table.contains(player:getTableMark("@steam__qiangyin"), "激鼓") and
      #table.filter(player:getCardIds("h"), function (id) return Fk:getCardById(id):getMark("@steam__qiangyin-inhand") == "激鼓" end) == #player:getCardIds("e")
      and #player:getAvailableEquipSlots() > #player:getCardIds("e") and player:usedEffectTimes("#steam__qiangyin_8_trig", Player.HistoryRound) +
      player:usedEffectTimes("#steam__qiangyin_9_trig", Player.HistoryRound) == 0
  end,
  on_use = function(self, event, target, player, data)
    local n = #player:getAvailableEquipSlots() - #player:getCardIds("e")
    player:drawCards(n, skel.name)
  end,
}

skel:addEffect(fk.Damage, spec)
skel:addEffect(fk.Damaged, spec)

--焦尾：失去后防止本回合下次受到伤害
skel:addEffect(fk.AfterCardsMove, {
  mute = true,
  can_refresh = function(self, event, target, player, data)
    if player:hasSkill(skel.name, true) then
      for _, move in ipairs(data) do
        if move.to == player and move.toArea == Card.PlayerHand then
          for _, info in ipairs(move.moveInfo) do
            if table.contains(player:getCardIds("h"), info.cardId) then
              return true
            end
          end
        end
        if move.from == player then
          for _, info in ipairs(move.moveInfo) do
            if info.fromArea == Card.PlayerHand and table.contains(player:getTableMark("steam__qiangyin_jiaowei"), info.cardId) then
              return true
            end
          end
        end
      end
    end
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    local cards = table.filter(player:getCardIds("h"), function (id)
      return Fk:getCardById(id):getMark("@steam__qiangyin-inhand") == "弦"
    end)
    local yes = false
    for _, move in ipairs(data) do
      if move.from == player then
        for _, info in ipairs(move.moveInfo) do
          if info.fromArea == Card.PlayerHand and
            table.contains(player:getTableMark("steam__qiangyin_jiaowei"), info.cardId) and
            not table.contains(cards, info.cardId) then
            yes = true
          end
        end
      end
    end
    room:setPlayerMark(player, "steam__qiangyin_jiaowei", cards)
    if yes and player:hasSkill(skel.name) and room.current.phase ~= Player.NotActive then
      room:setPlayerMark(player, "@@steam__qiangyin__skel-turn", 1)
    end
  end,
})

skel:addEffect(fk.DetermineDamageInflicted, {
  anim_type = "defensive",
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:getMark("@@steam__qiangyin__skel-turn") > 0
  end,
  on_use = function (self, event, target, player, data)
    data:preventDamage()
    player.room:setPlayerMark(player, "@@steam__qiangyin__skel-turn", 0)
  end,
})

--羲笛：准备或结束阶段卜算
skel:addEffect(fk.EventPhaseStart, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(skel.name) and (player.phase == Player.Start or player.phase == Player.Finish)
    and table.contains(player:getTableMark("@steam__qiangyin"), "羲笛")
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local n = #table.filter(player:getCardIds("h"), function (id)
      return Fk:getCardById(id):getMark("@steam__qiangyin-inhand") == "笛"
    end)
    n = math.min(n, 8)
    n = math.max(n, 1)
    room:askToGuanxing(player, {
      cards = room:getNCards(n),
      skill_name = skel.name,
    })
  end,
})

--绮琴：准备阶段回收琴牌
skel:addEffect(fk.EventPhaseStart, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(skel.name) and player.phase == Player.Start and
      table.find(player.room.discard_pile, function(id) return table.contains(player:getTableMark("steam__qiangyin_qiqin"), id) end)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cards = table.filter(room.discard_pile, function(id)
      return table.contains(player:getTableMark("steam__qiangyin_qiqin"), id)
    end)
    room:moveCardTo(cards, Player.Hand, player, fk.ReasonJustMove, skel.name, nil, false, player)
  end,
})

return skel
