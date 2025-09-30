local skel = fk.CreateSkill {
  name = "steam__wujinxukong",
}

Fk:loadTranslationTable{
  ["steam__wujinxukong"] = "无尽虚空",
  [":steam__wujinxukong"] = "每回合限一次，你获得牌后，可以弃置之并摸等量张牌。若含：锦囊牌，下一名角色的准备阶段，你摸一张牌；装备牌，你获得该牌的装备技能（每种副类别限一张）。",

  ["#steam__wujinxukong-ask"] = "无尽虚空：你可以弃置这些牌，摸 %arg 张牌并获得其中装备牌技能",
  ["#steam__wujinxukong-replace"] = "无尽虚空：你的装备技能大于限制，选择一个保留",
  ["@$steam__wujinxukong"] = "无尽虚空",
}

skel:addEffect(fk.AfterCardsMove, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(skel.name) or player:usedSkillTimes(skel.name) ~= 0 then return false end
    local ids = {}
    for _, move in ipairs(data) do
      if move.toArea == Player.Hand and move.to == player then
        for _, info in ipairs(move.moveInfo) do
          if table.contains(player.player_cards[Player.Hand], info.cardId)
          and not player:prohibitDiscard(info.cardId) then
            table.insertIfNeed(ids, info.cardId)
          end
        end
      end
    end
    if #ids > 0 then
      event:setCostData(self, {cards = ids})
      return true
    end
  end,
  on_cost = function (self, event, target, player, data)
    local cost_data = event:getCostData(self)
    local num = #cost_data.cards
    --[[
    if player:usedSkillTimes(skel.name, Player.HistoryRound) == 0 then
      num = num * 2
    end
    num = math.min(num, 5)
    --]]
    if player.room:askToSkillInvoke(player, { skill_name = skel.name, prompt = "#steam__wujinxukong-ask:::"..num}) then
      cost_data.num = num
      event:setCostData(self, cost_data)
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cards = event:getCostData(self).cards
    local num = event:getCostData(self).num
    if not cards or not num then return end
    local newEquipMap, hasTrick = {}, false
    for _, id in ipairs(cards) do
      local card = Fk:getCardById(id)---@type EquipCard
      if card.type == Card.TypeEquip then
        local equipSkills = card:getEquipSkills(player)
        if #equipSkills > 0 then
          newEquipMap[card.sub_type] = newEquipMap[card.sub_type] or {}
          table.insertIfNeed(newEquipMap[card.sub_type], card.name)
        end
      elseif card.type == Card.TypeTrick then
        hasTrick = true
      end
    end
    room:throwCard(cards, skel.name, player, player)
    if player.dead then return end
    -- 处理一下新加的装备技能
    local skills = {}
    for sub_type, names in pairs(newEquipMap) do
      local choices = table.simpleClone(names)
      local exist = table.find(player:getTableMark("@$steam__wujinxukong"), function (name)
        return Fk:cloneCard(name).sub_type == sub_type
      end)
      if exist then table.insert(choices, exist) end
      local choice = room:askToChoice(player, {
        skill_name = skel.name, prompt = "#steam__wujinxukong-replace", choices = choices,
      })
      if exist and choice ~= exist then -- 移除已有
        room:removeTableMark(player, "@$steam__wujinxukong", exist)
        for _, s in ipairs(Fk:cloneCard(exist):getEquipSkills(player)) do
          table.insertIfNeed(skills, "-" .. s.name)
        end
      end
      if exist ~= choice then -- 新加入
        room:addTableMarkIfNeed(player, "@$steam__wujinxukong", choice)
        for _, s in ipairs(Fk:cloneCard(choice):getEquipSkills(player)) do
          table.insertIfNeed(skills, s.name)
        end
      end
    end
    if #skills > 0 then
      room:handleAddLoseSkills(player, table.concat(skills, "|"), skel.name) -- source skill智慧做虚拟装备技能
    end
    if player.dead then return end
    player:drawCards(num, skel.name)
    if player.dead then return end
    if hasTrick then
      room:addPlayerMark(player, "steam__wujinxukong_delay", 1)
    end
  end,
})

skel:addEffect(fk.EventPhaseStart, {
  anim_type = "drawcard",
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    return target.phase == Player.Start and player:getMark("steam__wujinxukong_delay") ~= 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local num = player:getMark("steam__wujinxukong_delay")
    player.room:setPlayerMark(player, "steam__wujinxukong_delay", 0)
    player:drawCards(num, skel.name)
  end,
})

skel:addLoseEffect(function (self, player, is_death)
  player.room:setPlayerMark(player, "@$steam__wujinxukong", 0)
end)

return skel
