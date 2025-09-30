local skel = fk.CreateSkill {
  name = "steam__fengmang",
}

Fk:loadTranslationTable{
  ["steam__fengmang"] = "封芒",
  [":steam__fengmang"] = "若你判定区牌数小于体力值，你可以跳过判定阶段。"..
  "判定阶段开始时，你须失去至少1点体力或体力上限，令本阶段你使用的前等量张伤害牌无视距离且不可响应；然后你须弃置区域内至少一张牌，令本阶段你使用的前等量张伤害牌不计次数。",

  ["#steam__fengmang-skip"] = "封芒：你可以跳过判定阶段",
  ["@steam__fengmang_dist-phase"] = "封芒:不可响应",
  ["@steam__fengmang_times-phase"] = "封芒:不计次数",
  ["SteamLoseHp"] = "失去体力",
  ["SteamLoseMaxHp"] = "扣减体力上限",
  ["#steam__fengmang-choice"] = "封芒：你须失去至少1点体力或体力上限！",
  ["#steam__fengmang-losehp"] = "封芒：选择失去数量，令你本阶段你使用的前等量张伤害牌无视距离且不可响应",
  ["#steam__fengmang-discard"] = "封芒：弃置区域内牌，令你本阶段你使用的前等量张伤害牌不计次数",

  ["$steam__fengmang1"] = "令人厌倦。",
  ["$steam__fengmang2"] = "下雨了。",
}

skel:addEffect(fk.EventPhaseChanging, {
  anim_type = "control",
  can_trigger = function (self, event, target, player, data)
    if player:hasSkill(skel.name) and target == player and data.phase == Player.Judge and not data.skipped then
      return #player:getCardIds("j") < player.hp
    end
  end,
  on_cost = function (self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {skill_name = skel.name, prompt = "#steam__fengmang-skip"})
  end,
  on_use = function (self, event, target, player, data)
    data.skipped = true
  end,
})

skel:addEffect(fk.EventPhaseStart, {
  anim_type = "offensive",
  can_trigger = function (self, event, target, player, data)
    return player:hasSkill(skel.name) and target == player and data.phase == Player.Judge
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local choice = room:askToChoice(player, {
      choices = {"SteamLoseHp", "SteamLoseMaxHp"}, skill_name = skel.name, prompt = "#steam__fengmang-choice"
    })
    local choices = {"1"}
    for i = 2, choice == "SteamLoseHp" and player.hp or player.maxHp do
      table.insert(choices, tostring(i))
    end
    local num = tonumber(room:askToChoice(player, {
      choices = choices, skill_name = skel.name, prompt = "#steam__fengmang-losehp"
    })) or 1
    if choice == "SteamLoseHp" then
      room:loseHp(player, num, skel.name)
    else
      room:changeMaxHp(player, - num)
    end
    if player.dead then return end
    room:addPlayerMark(player, "@steam__fengmang_dist-phase", num)
    local cards_data = {} -- 区域内所有牌均可见！
    local handcards = table.filter(player:getCardIds(Player.Hand), function (id)
      return not player:prohibitDiscard(id)
    end)
    local equips = table.filter(player:getCardIds(Player.Equip), function (id)
      return not player:prohibitDiscard(id)
    end)
    local judges = player:getCardIds(Player.Judge)
    if #handcards > 0 then
      table.insert(cards_data, {"$Hand", handcards})
    end
    if #equips > 0 then
      table.insert(cards_data, {"$Equip", equips})
    end
    if #judges > 0 then -- 由于蓄谋是从最末尾(最后进入判定区的)开始用的，加个倒置让使用的第一张蓄谋牌在左侧
      table.insert(cards_data, {"$Judge", table.reverse(judges) })
    end
    if #cards_data > 0 then
      local cards = room:askToChooseCards(player, {
        min = 1, max = 9999, skill_name = skel.name, target = player,
        flag = { card_data = cards_data },
        prompt = "#steam__fengmang-discard",
      })
      room:throwCard(cards, skel.name, player, player)
      if player.dead then return end
      room:addPlayerMark(player, "@steam__fengmang_times-phase", #cards)
    end
  end,
})

skel:addEffect(fk.CardUsing, {
  can_refresh = function (self, event, target, player, data)
    return target == player and data.card.is_damage_card and
    (player:getMark("@steam__fengmang_dist-phase") > 0 or player:getMark("@steam__fengmang_times-phase") > 0)
  end,
  on_refresh = function (self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke(skel.name)
    if player:getMark("@steam__fengmang_dist-phase") > 0 then
      room:removePlayerMark(player, "@steam__fengmang_dist-phase", 1)
      data.disresponsiveList = table.simpleClone(room.players)
    end
    if player:getMark("@steam__fengmang_times-phase") > 0 then
      room:removePlayerMark(player, "@steam__fengmang_times-phase", 1)
      if not data.extraUse then
        player:addCardUseHistory(data.card.trueName, -1)
        data.extraUse = true
      end
      if data.extra_data and data.extra_data.premeditate then
        room:removeTableMark(player, "premeditate-phase", data.card.trueName) -- 移除蓄谋牌名限制
      end
    end
  end,
})

skel:addEffect("targetmod", {
  bypass_distances = function (self, player, skill, card)
    return card and player:getMark("@steam__fengmang_dist-phase") > 0 and card.is_damage_card
  end,
  bypass_times = function (self, player, skill, scope, card)
    return card and player:getMark("@steam__fengmang_times-phase") > 0 and card.is_damage_card
  end,
})

return skel
