local skel = fk.CreateSkill {
  name = "steam__lingqu",
  tags = {Skill.Switch},
}

Fk:loadTranslationTable{
  ["steam__lingqu"] = "灵躯",
  [":steam__lingqu"] = "转换技，你每轮首次使用一种颜色的实体牌后，可以视为使用一张【逐近弃远】，且可以：①使用因此弃置的牌；②弃置因此获得的牌，对目标造成1点伤害。",

  [":steam__lingqu_yang"] = "转换技，你每轮首次使用一种颜色的实体牌后，可以视为使用一张【逐近弃远】，且可以：<font color=\"#E0DB2F\">①使用因此弃置的牌；</font>②弃置因此获得的牌，对目标造成1点伤害。",
  [":steam__lingqu_yin"] = "转换技，你每轮首次使用一种颜色的实体牌后，可以视为使用一张【逐近弃远】，且可以：①使用因此弃置的牌；<font color=\"#E0DB2F\">②弃置因此获得的牌，对目标造成1点伤害。</font>",

  ["@steam__lingqu-round"] = "灵躯",
  ["#steam__lingqu-damage"] = "灵躯：你可以弃置 %arg 对 %src 造成1点伤害",
  ["#steam__lingqu-use"] = "灵躯：你可以使用弃置的牌",
  ["#steam__lingqu-yang"] = "灵躯：可以视为使用【逐近弃远】，且可使用因此弃置的牌",
  ["#steam__lingqu-yin"] = "灵躯：可以视为使用【逐近弃远】，且可弃置获得的牌，对目标造成1点伤害",
}

skel:addEffect(fk.CardUseFinished, {
  anim_type = "switch",
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(skel.name) and target == player then
      return data.extra_data and data.extra_data.steam__lingquCheck
    end
  end,
  on_cost = function (self, event, target, player, data)
    local state = data.extra_data.steam__lingquCheck
    local use = player.room:askToUseVirtualCard(player, {
      name = "chasing_near", skill_name = skel.name, skip = true, prompt = "#steam__lingqu-"..state,
    })
    if use then
      event:setCostData(self, use)
      return true
    end
  end,
  on_use = function (self, event, target, player, data)
    local use = event:getCostData(self)
    use.extra_data = use.extra_data or {}
    use.extra_data.steam__lingquBuff = data.extra_data.steam__lingquCheck
    player.room:useCard(use)
  end,
})

-- 记录首张使用颜色
skel:addEffect(fk.CardUsing, {
  can_refresh = function (self, event, target, player, data)
    return target == player and player:hasSkill(skel.name, true) and
    not data.card:isVirtual() and
    not table.contains(player:getTableMark("@steam__lingqu-round"), data.card:getColorString())
  end,
  on_refresh = function (self, event, target, player, data)
    player.room:addTableMark(player, "@steam__lingqu-round", data.card:getColorString())
    data.extra_data = data.extra_data or {}
    data.extra_data.steam__lingquCheck = player:getSwitchSkillState(skel.name, false, true)
  end,
})

skel:addLoseEffect(function (self, player, is_death)
  player.room:setPlayerMark(player, "@steam__lingqu-round", 0)
end)

skel:addEffect(fk.AfterCardsMove, {
  is_delay_effect = true,
  mute = true,
  can_trigger = function(self, event, target, player, data)
    local effectEvent = player.room.logic:getCurrentEvent():findParent(GameEvent.CardEffect)
    if effectEvent == nil then return false end
    local eff = effectEvent.data
    if eff.card.name == "chasing_near" and table.contains(eff.card.skillNames, skel.name)
      and eff.from == player and not player.dead then
      local buff = eff.extra_data and eff.extra_data.steam__lingquBuff
      if not buff then return end
      local cid
      for _, move in ipairs(data) do
        if move.skillName and string.find(move.skillName, "chasing_near") then
          for _, info in ipairs(move.moveInfo) do
            local card = Fk:getCardById(info.cardId)
            if buff == "yang" and move.moveReason == fk.ReasonDiscard and player.room:getCardArea(card.id) == Card.DiscardPile then
              cid = info.cardId
            elseif buff == "yin" and move.moveReason == fk.ReasonPrey and table.contains(player:getCardIds("h"), card.id) then
              cid = info.cardId
            end
          end
        end
      end
      if cid then
        event:setCostData(self, cid)
        return true
      end
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local effectEvent = player.room.logic:getCurrentEvent():findParent(GameEvent.CardEffect)
    if not effectEvent then return end
    local eff = effectEvent.data
    local cid = event:getCostData(self)
    if eff.extra_data.steam__lingquBuff == "yang" then
      room:askToUseRealCard(player, {
        cards = {cid}, skill_name = skel.name, prompt = "#steam__lingqu-use", expand_pile = {cid}, pattern = {cid}, skip = false,
        extra_data = {bypass_times = true},
      })
    elseif eff.to:isAlive() and room:askToSkillInvoke(player, { skill_name = skel.name,
        prompt = "#steam__lingqu-damage:"..eff.to.id.."::"..Fk:getCardById(cid):toLogString()
      }) then
      room:throwCard(cid, skel.name, player, player)
      room:doIndicate(player, {eff.to})
      room:damage { from = player, to = eff.to, damage = 1, skillName = skel.name }
    end
  end,
})

return skel
