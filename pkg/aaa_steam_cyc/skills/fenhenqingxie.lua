local skel = fk.CreateSkill {
  name = "steam__fenhenqingxie",
  dynamic_desc = function (self, player, lang)
    local mark = player:getMark("steam__fenhenqingxie_times")
    if mark > 0 then
      return "steam__fenhenqingxie_dyn:" .. (mark + 1)
    end
  end,
}

Fk:loadTranslationTable{
  ["steam__fenhenqingxie"] = "忿恨倾泻",
  [":steam__fenhenqingxie"] = "每回合限一次，摸牌/出牌/弃牌阶段，你可以改为视为使用一张不可抵消的【兵临城下】并:获得亮出的非【杀】牌/弃置目标等同于其中非【杀】牌数量的牌/弃置等同于其中【杀】数量张手牌。",

  [":steam__fenhenqingxie_dyn"] = "每回合限{1}次，摸牌/出牌/弃牌阶段，你可以改为视为使用一张不可抵消的【兵临城下】并:获得亮出的非【杀】牌/弃置目标等同于其中非【杀】牌数量的牌/弃置等同于其中【杀】数量张手牌。",

  ["steam_fhqx_phase_draw"] = "获得亮出的非【杀】牌",
  ["steam_fhqx_phase_play"] = "弃置目标等同于其中非【杀】牌数量的牌",
  ["steam_fhqx_phase_discard"] = "弃置等同于其中【杀】数量张手牌",
  ["#steam__fenhenqingxie-invoke"] = "忿恨倾泻：你可跳过 %arg，使用【兵临城下】并%arg2",
  ["#steam__fenhenqingxie-effect"] = "请选择【兵临城下】的额外效果",
}

skel:addEffect(fk.EventPhaseStart, {
  anim_type = "offensive",
  times = function (_, player)
    return (1 + player:getMark("@steam__emokuangnu")) - player:usedSkillTimes(skel.name)
  end,
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(skel.name) and target == player and not data.phase_end
    and table.contains({Player.Draw, Player.Play, Player.Discard}, data.phase)
    and player:usedSkillTimes(skel.name) < (1 + player:getMark("@steam__emokuangnu"))
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local card = Fk:cloneCard("mobile__enemy_at_the_gates")
    card.skillName = skel.name
    if #card:getAvailableTargets(player) == 0 then return false end
    local phase = Util.PhaseStrMapper(data.phase)
    if room:askToSkillInvoke(player, {
      skill_name = skel.name, prompt = "#steam__fenhenqingxie-invoke:::".. phase .. ":steam_fhqx_" .. phase
    }) then
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    data.phase_end = true
    local phase = ""
    if table.contains({Player.Draw, Player.Play, Player.Discard}, player.phase) then
      phase = Util.PhaseStrMapper(data.phase)
    else -- 自选效果
      phase = room:askToChoice(player, {
        choices = {"steam_fhqx_phase_draw", "steam_fhqx_phase_play", "steam_fhqx_phase_discard"},
        skill_name = skel.name, prompt = "#steam__fenhenqingxie-effect"
      }):sub(12, -1)
    end
    local use = room:askToUseVirtualCard(player, {
      name = "mobile__enemy_at_the_gates", skill_name = skel.name, cancelable = false, skip = true,
    })
    if not use then return end
    use.unoffsetableList = table.simpleClone(room.players)
    use.extra_data = use.extra_data or {}
    use.extra_data.steam_fhqx_info = {phase, player}
    room:useCard(use)
  end,
})

skel:addEffect(fk.AfterCardsMove, {
  mute = true,
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    if player.dead then return false end
    local effect_event = player.room.logic:getCurrentEvent():findParent(GameEvent.CardEffect)
    if effect_event then
      local eff = effect_event.data
      if table.contains(eff.card.skillNames, skel.name) and eff.extra_data and eff.extra_data.steam_fhqx_info
      and eff.extra_data.steam_fhqx_info[2] == player then -- 谨防修改使用者
        for _, move in ipairs(data) do
          if move.toArea == Card.Processing and move.skillName and string.find(move.skillName, "enemy_at_the_gates") then
            return true
          end
        end
      end
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local effect_event = room.logic:getCurrentEvent():findParent(GameEvent.CardEffect)
    if effect_event == nil then return end
    local eff = effect_event.data
    local slash, nonslash = {}, {}
    for _, move in ipairs(data) do
      if move.toArea == Card.Processing and move.skillName and string.find(move.skillName, "enemy_at_the_gates") then
        for _, info in ipairs(move.moveInfo) do
          if Fk:getCardById(info.cardId).trueName == "slash" then
            table.insertIfNeed(slash, info.cardId)
          else
            table.insertIfNeed(nonslash, info.cardId)
          end
        end
      end
    end
    room:delay(400)
    local phase = eff.extra_data.steam_fhqx_info[1]
    if phase == "phase_draw" then
      local get = table.filter(nonslash, function (id) return room:getCardArea(id) == Card.Processing end)
      if #get > 0 then
        room:obtainCard(player, get, true, fk.ReasonJustMove, player, skel.name)
      end
    elseif phase == "phase_play" then
      local to = eff.to
      local x = math.min(#nonslash, #to:getCardIds("he"))
      if x > 0 then
        local throw = room:askToChooseCards(player, { target = to, min = x, max = x, flag = "he", skill_name = skel.name})
        room:throwCard(throw, skel.name, to, player)
      end
    elseif phase == "phase_discard" then
      local x = #slash
      room:askToDiscard(player, {min_num = x, max_num = x, include_equip = false, skill_name = skel.name, cancelable = false})
    end
  end,
})

return skel
