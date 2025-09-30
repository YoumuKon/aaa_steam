local skel = fk.CreateSkill {
  name = "steam__dalixingyi",
}

Fk:loadTranslationTable{
  ["steam__dalixingyi"] = "大力行医",
  [":steam__dalixingyi"] = "出牌阶段限一次，你可以令一名已受伤角色连续视为使用【散】直至体力回满（至多使用5张）。"..
  "其每因此回复1点体力，便发送一句“那我问你”，并视为使用一张牌名、目标随机而定的即时牌。",

  ["#steam__dalixingyi"] = "大力行医：令一名已受伤角色连续视为使用【散】直至体力回满，并随机视为使用牌！",

  ["Now I ask you"] = "那我问你",
  ["$steam__dalixingyi1"] = "别怕，我是医生。",
  ["$steam__dalixingyi2"] = "一兆万毫升的治病水儿，紧急！",
  ["$steam__dalixingyi3"] = "旧的疤痕怎么治？用新的盖过去!",
}

skel:addEffect("active", {
  anim_type = "support",
  card_num = 0,
  target_num = 1,
  prompt = "#steam__dalixingyi",
  card_filter = Util.FalseFunc,
  target_filter = function (self, player, to_select, selected)
    return #selected == 0 and to_select:isWounded()
  end,
  can_use = function(self, player)
    return player:usedSkillTimes(skel.name, Player.HistoryPhase) == 0
  end,
  times = function (self, player)
    return 1 - player:usedSkillTimes(skel.name, Player.HistoryPhase)
  end,
  on_use = function(self, room, effect)
    local to = effect.tos[1]
    for _ = 1, 5 do
      if to.dead or not to:isWounded() then break end
      local card = Fk:cloneCard("drugs")
      card.skillName = skel.name
      if not room:useVirtualCard("drugs", nil, to, to, skel.name, true) then break end
    end
  end,
})

skel:addEffect(fk.HpRecover, {
  is_delay_effect = true,
  mute = true,
  can_trigger = function (self, event, target, player, data)
    return target == player and not target.dead
    and data.card and data.card.trueName == "drugs"
    and table.contains(data.card.skillNames, skel.name)
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local skillName = skel.name
    local names = table.filter(Fk:getAllCardNames("bt"), function (name)
      local c = Fk:cloneCard(name)
      c.skillName = skillName
      return player:canUse(c, {bypass_distances = true, bypass_times = true})
      and not player:prohibitUse(c) and c.skill:getMinTargetNum(player) < 2
    end)
    table.removeOne(names, "drugs")
    while #names > 0 do
      local name = table.remove(names, math.random(1, #names))
      local card = Fk:cloneCard(name)
      card.skillName = skillName
      local targets = table.filter(room.alive_players, function (p)
        if player:isProhibited(p, card) then return false end
        if card.trueName == "slash" then
          return true
        else
          return card.skill:modTargetFilter(player, p, {}, card, {bypass_distances = true, bypass_times = true})
        end
      end)
      if #targets > 0 then
        local to = table.random(targets)
        room:delay(700)
        player:chat(Fk:translate("Now I ask you"))
        player:broadcastSkillInvoke(skel.name)
        room:delay(200)
        room:useCard{from = player, tos = {to}, card = card, extraUse = true}
        break
      end
    end
  end,
})

return skel
