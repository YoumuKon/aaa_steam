local skel = fk.CreateSkill {
  name = "steam__eyishougou",
  tags = {Skill.Switch},
}

Fk:loadTranslationTable{
  ["steam__eyishougou"] = "恶意收购",
  [":steam__eyishougou"] = "转换技，游戏开始时可自选阴阳状态。出牌阶段限一次，你可以令一名角色将一张牌当【远交近攻】对你指定的另一名角色使用。然后使用者展示以此法获得的：①♠牌；②非<font color='red'>♥</font>牌；获得等量的<a href=':steam__dunxi'>“钝”标记</a>。",

  [":steam__eyishougou_yang"] = "转换技，游戏开始时可自选阴阳状态。出牌阶段限一次，你可以令一名角色将一张牌当【远交近攻】对你指定的另一名角色使用。然后使用者展示以此法获得的：<font color='#E0DB2F'>①♠牌；</font>②非♥牌；获得等量的<a href=':steam__dunxi'>“钝”标记</a>。",
  [":steam__eyishougou_yin"] = "转换技，游戏开始时可自选阴阳状态。出牌阶段限一次，你可以令一名角色将一张牌当【远交近攻】对你指定的另一名角色使用。然后使用者展示以此法获得的：①♠牌；<font color='#E0DB2F'>②非♥牌</font>；获得等量的<a href=':steam__dunxi'>“钝”标记</a>。",

  ["#steam__eyishougou-yang"] = "令一名角色将一张牌当【远交近攻】对你选择的角色使用，然后前者展示所有♠牌",
  ["#steam__eyishougou-yin"] = "令一名角色将一张牌当【远交近攻】对你选择的角色使用，然后前者展示所有非<font color='red'>♥</font>牌",
  ["steam__eyishougou_user"] = "使用者",
  ["steam__eyishougou_yang"] = "展示♠牌",
  ["steam__eyishougou_yin"] = "展示非<font color='red'>♥</font>牌",
  ["#steam__eyishougou-switch"] = "恶意收购：选择初始阴阳状态，即【远交近攻】使用者须展示的牌",
  ["#steam__eyishougou-use"] = "恶意收购：你须将一张牌当【远交近攻】对 %src 使用",

  ["$steam__eyishougou1"] = "现在你要替我卖命了！",
  ["$steam__eyishougou2"] = "全部带走，享受痛苦！",
}

skel:addEffect("active", {
  anim_type = "switch",
  card_num = 0,
  target_num = 2,
  switch_skill_name = "steam__eyishougou",
  prompt = function (self, player)
    return "#steam__eyishougou-"..player:getSwitchSkillState(self.name, false, true)
  end,
  target_tip = function (self, player, to_select, selected)
    if #selected > 0 and to_select == selected[1] then
      return "steam__eyishougou_user"
    end
  end,
  card_filter = Util.FalseFunc,
  target_filter = function (self, player, to, selected)
    if #selected == 0 then
      return not to:isNude()
    elseif #selected == 1 then
      return true -- 不需要势力不同
    end
  end,
  times = function (self, player)
    return 1 - player:usedSkillTimes(self.name, Player.HistoryPhase)
  end,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local user = effect.tos[1]
    local to = effect.tos[2]
    local isYang = player:getSwitchSkillState(self.name, true) == fk.SwitchYang
    local ids = table.filter(user:getCardIds("he"), function (id)
      local card = Fk:cloneCard("steam__befriend_attacking")
      card.skillName = self.name
      card:addSubcard(id)
      return not user:prohibitUse(card) and not user:isProhibited(to, card)
    end)
    if #ids == 0 then return end
    if #ids > 1 then
      ids = room:askToCards(user, {
        min_num = 1, max_num = 1, include_equip = true,
        skill_name = self.name, cancelable = false,
        pattern = tostring(Exppattern{ id = ids }),
        prompt = "#steam__eyishougou-use:" .. to.id,
      })
    end
    local use = room:useVirtualCard("steam__befriend_attacking", ids, user, to, self.name)
    if user.dead or not use then return end
    ids = (use.extra_data or {}).steam__eyishougou_draw or {}
    ids = table.filter(ids, function (id)
      if not table.contains(user.player_cards[Player.Hand], id) then return false end
      local c = Fk:getCardById(id)
      if isYang then
        return c.suit == Card.Spade
      else
        return c.suit ~= Card.Heart
      end
    end)
    if #ids == 0 then return end
    user:showCards(ids)
    room:addSkill("steam__dunxi")
    room:addPlayerMark(user, "@steam__dunxi", #ids)
  end,
})

-- 开局自选阴阳状态
skel:addEffect(fk.GameStart, {
  can_refresh = function(self, event, target, player, data)
    return player:hasSkill(skel.name)
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    local skillName = skel.name
    local choices = {"steam__eyishougou_yang", "steam__eyishougou_yin"}
    local choice = room:askToChoice(player, { choices = choices, skill_name = skillName, prompt = "#steam__eyishougou-switch"})
    local switch_state = table.indexOf(choices, choice) - 1
    room:setPlayerMark(player, MarkEnum.SwithSkillPreName .. skillName, switch_state)
    player:setSkillUseHistory(skillName, 0, Player.HistoryGame)
  end,
})

--- 记录因此摸到的牌
skel:addEffect(fk.AfterCardsMove, {
  can_refresh = function (self, event, target, player, data)
    return not player.dead
  end,
  on_refresh = function (self, event, target, player, data)
    local logic = player.room.logic
    local parent = logic:getCurrentEvent().parent
    if parent and parent.event == GameEvent.SkillEffect then
      local effect_event = parent.parent
      if effect_event and effect_event.event == GameEvent.CardEffect then
        local eff = effect_event.data
        if table.contains(eff.card.skillNames, skel.name) and eff.from == player then
          local useEvent = effect_event:findParent(GameEvent.UseCard)
          if not useEvent then return end
          local use = useEvent.data
          local ids = {}
          for _, move in ipairs(data) do
            if move.toArea == Card.PlayerHand and move.to == player then
              for _, info in ipairs(move.moveInfo) do
                table.insertIfNeed(ids, info.cardId)
              end
            end
          end
          use.extra_data = use.extra_data or {}
          use.extra_data.steam__eyishougou_draw = use.extra_data.steam__eyishougou_draw or {}
          table.insertTableIfNeed(use.extra_data.steam__eyishougou_draw, ids)
        end
      end
    end
  end,
})


return skel
