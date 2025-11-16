local qingxi = fk.CreateSkill {
  name = "steamMinshe__qingxi",
}

--- @param player ServerPlayer
--- @param choice string
local function runQianXi(player, choice)
  local room = player.room
  if choice == "discard" and not player:isNude() then
    return room:askToDiscard(player, {
      min_num = 1,
      max_num = 1,
      include_equip = true,
      skill_name = qingxi.name,
      cancelable = false,
    })
  elseif choice == "recast" and not player:isNude() then
    local cards = room:askToCards(player, {
      min_num = 1,
      max_num = 1,
      include_equip = true,
      skill_name = qingxi.name,
      prompt = "#steamMinshe__qingxi-recast",
      cancelable = false,
    })
    if #cards > 0 then
      room:recastCard(cards, player, qingxi.name)
    end
    return cards
  elseif choice == "use" then
    return room:askToPlayCard(player, {
      skill_name = qingxi.name,
      cancelable = false,
    })
  end
end

qingxi:addEffect(fk.EventPhaseProceeding, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(qingxi.name) and player.phase == Player.Start
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = qingxi.name,
      prompt = "#steamMinshe__qingxi-invoke",
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cards = {}
    local choices = {
      "discard",
      "recast",
      "use",
    }
    -- 弃置
    local card = room:askToDiscard(player, {
      min_num = 1,
      max_num = 1,
      include_equip = true,
      skill_name = qingxi.name,
      cancelable = false,
    })[1]
    if card then
      cards[1] = Fk:getCardById(card)
      if not player:isNude() then
        card = room:askToCards(player, {
          min_num = 1,
          max_num = 1,
          include_equip = true,
          skill_name = qingxi.name,
          prompt = "#steamMinshe__qingxi-recast",
          cancelable = false,
        })[1]
        if card then
          cards[2] = Fk:getCardById(card)
          room:recastCard({card}, player, qingxi.name)
          local use = room:askToPlayCard(player, {
            skill_name = qingxi.name,
            cancelable = false,
          })
          if use then
            cards[3] = use.card
          end
        end
      end
    end
    local match_pairs = {type = {}, suit = {}}
    --- @param choice_card Card
    for i, choice_card in ipairs(cards) do
      match_pairs.type[choice_card.type] = match_pairs.type[choice_card.type] or {}
      table.insert(match_pairs.type[choice_card.type], choices[i])
      if choice_card.suit ~= Card.NoSuit and choice_card.suit ~= Card.Unknown then
        match_pairs.suit[choice_card.suit] = match_pairs.suit[choice_card.suit] or {}
        table.insert(match_pairs.suit[choice_card.suit], choices[i])
      end
    end

    local card_pairs
    for _, arr in pairs(match_pairs.type) do
      if #arr == 2 then
        card_pairs = arr
        break
      end
    end
    if card_pairs then
      local _, dat = room:askToUseActiveSkill(player, {
        skill_name = "#steamMinshe__qingxi_active",
        prompt = "#steamMinshe__qingxi-select:::" .. table.concat(table.map(card_pairs, Util.TranslateMapper), "/"),
        extra_data = {
          skillName = qingxi.name,
          choices = card_pairs,
          all_choices = choices,
        }
      })
      if dat then
        runQianXi(dat.targets[1], dat.interaction)
      end
    end

    card_pairs = nil
    for _, arr in pairs(match_pairs.suit) do
      if #arr == 2 then
        card_pairs = arr
        break
      end
    end
    if card_pairs then
      local choice = table.filter(choices, function (str)
        return not table.contains(card_pairs, str)
      end)[1]
      if choice then
        local to = room:askToChoosePlayers(player, {
          min_num = 1,
          max_num = 1,
          targets = room.alive_players,
          skill_name = qingxi.name,
          prompt = "#steamMinshe__qingxi-select:::" .. choice,
        })[1]
        if to then
          runQianXi(to, choice)
        end
      end
    end
  end
})

Fk:loadTranslationTable{
  ["steamMinshe__qingxi"] = "倾袭",
  [":steamMinshe__qingxi"] = "准备阶段，你可以依次弃置，重铸，使用一张牌，若恰有两项：类型相同，你令一名角色执行其中一项；花色相同：你令一名角色执行余下一项。",

  ["#steamMinshe__qingxi-invoke"] = "倾袭：你可以弃置，重铸，使用一张牌，若恰有两项的牌类型/花色相同，你令一名角色执行其中/余下一项",
  ["#steamMinshe__qingxi-recast"] = "倾袭：请重铸一张牌",

  ["$steamMinshe__qingxi1"] = "策马疾如电，溃敌一瞬间。",
  ["$steamMinshe__qingxi2"] = "虎豹骑岂能徒有虚名？杀！",
}

return qingxi