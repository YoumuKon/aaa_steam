local skel = fk.CreateSkill {
  name = "steam__lubao",
}

Fk:loadTranslationTable{
  ["steam__lubao"] = "卤簿",
  [":steam__lubao"] = "当你摸牌/弃牌时，可以改为获得一名其他角色的区域等量牌/置入一名其他角色区域内。",

  ["#steam__lubao-prey"] = "卤簿：你可以将摸牌改为获得一名其他角色区域内 %arg 张牌",
  ["#steam__lubao-put"] = "卤簿：你可以将你的弃牌置入一名其他角色区域内",
  ["#steam__lubao-area"] = "卤簿：请选择%arg置入的区域",

  ["$steam__lubao1"] = "越山渡河，万里无阻，老贼，此天亡汝！",
  ["$steam__lubao2"] = "剪凶徒，匡天下，一麾以清京洛。",
}

skel:addEffect(fk.BeforeCardsMove, {
  anim_type = "control",
  can_trigger = function (self, event, target, player, data)
    if not player:hasSkill(skel.name) then return end
    for _, move in ipairs(data) do
      if move.from == player and move.moveReason == fk.ReasonDiscard then
        for _, info in ipairs(move.moveInfo) do
          if info.fromArea == Player.Hand or info.fromArea == Player.Equip then
            return true
          end
        end
      end
    end
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local tos = room:askToChoosePlayers(player, { targets = room:getOtherPlayers(player, false), min_num = 1, max_num = 1,
    prompt = "#steam__lubao-put", skill_name = skel.name })
    if #tos > 0 then
      event:setCostData(self, {tos = tos})
      return true
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local to = event:getCostData(self).tos[1] ---@type ServerPlayer
    local equips, judges, hands, equipRecord, judgeRecord, moves = {}, {}, {}, {}, {}, {}
    local ids = {}
    for _, move in ipairs(data) do
      if move.from == player and move.moveReason == fk.ReasonDiscard then
        for _, info in ipairs(move.moveInfo) do
          if info.fromArea == Player.Hand or info.fromArea == Player.Equip then
            table.insert(ids, info.cardId)
          end
        end
      end
    end
    room:cancelMove(data, ids)
    for _, id in ipairs(ids) do
      local c = Fk:getCardById(id)
      local toArea = "$Hand"
      local sub_type = c.sub_type
      local prompt = "#steam__lubao-area:::"..c:toLogString()
      if c.type == Card.TypeEquip then
        -- 计算一下对方装备区的此装备栏有多少空位
        local rest = #to:getAvailableEquipSlots(sub_type) - #to:getEquipments(sub_type) - (equipRecord[sub_type] or 0)
        if rest > 0 then
          toArea = room:askToChoice(player, { choices = {"$Hand", "$Equip"}, skill_name = skel.name, prompt = prompt })
        end
      elseif sub_type == Card.SubtypeDelayedTrick then
        if not to:isProhibitedTarget(c) and judgeRecord[c.name] == nil then
          toArea = room:askToChoice(player, { choices = {"$Hand", "$Judge"}, skill_name = skel.name, prompt = prompt })
        end
      end
      if toArea == "$Equip" then
        equipRecord[sub_type] = (equipRecord[sub_type] or 0) + 1
        table.insert(equips, id)
      elseif toArea == "$Judge" then
        judgeRecord[c.name] = true
        table.insert(judges, id)
      else
        table.insert(hands, id)
      end
    end
    if #hands > 0 then
      table.insert(moves, {
        from = player,
        ids = hands,
        to = to,
        toArea = Player.Hand,
        moveReason = fk.ReasonGive,
        skillName = skel.name,
        moveVisible = false,
        proposer = player,
      })
    end
    if #equips > 0 then
      table.insert(moves, {
        from = player,
        ids = equips,
        to = to,
        toArea = Player.Equip,
        moveReason = fk.ReasonJustMove,
        skillName = skel.name,
        moveVisible = true,
        proposer = player,
      })
    end
    if #judges > 0 then
      table.insert(moves, {
        from = player,
        ids = judges,
        to = to,
        toArea = Player.Judge,
        moveReason = fk.ReasonJustMove,
        skillName = skel.name,
        moveVisible = true,
        proposer = player,
      })
    end
    if #moves > 0 then
      room:moveCards(table.unpack(moves))
    end
  end,
})

skel:addEffect(fk.BeforeDrawCard, {
  anim_type = "control",
  can_trigger = function (self, event, target, player, data)
    if not player:hasSkill(skel.name) then return end
    return target == player and data.num > 0 and table.find(player.room.alive_players, function (p)
      return p ~= player and not p:isAllNude()
    end)
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local targets = table.filter(room:getOtherPlayers(player, false), function (p) return not p:isAllNude() end)
    if #targets == 0 then return false end
    local tos = room:askToChoosePlayers(player, { targets = targets, min_num = 1, max_num = 1,
    prompt = "#steam__lubao-prey:::"..data.num, skill_name = skel.name })
    if #tos > 0 then
      event:setCostData(self, {tos = tos})
      return true
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local to = event:getCostData(self).tos[1]
    local x = math.min(data.num, #to:getCardIds("hej"))
    if x == 0 then return end
    local cards = room:askToChooseCards(player, { target = to, min = x, max = x, flag = "hej", skill_name = skel.name})
    room:obtainCard(player, cards, false, fk.ReasonPrey, player, skel.name)
    data.num = 0
    return true
  end,
})

return skel
