local skel = fk.CreateSkill {
  name = "steam__shenshengxianli",
}

Fk:loadTranslationTable{
  ["steam__shenshengxianli"] = "神圣献礼",
  [":steam__shenshengxianli"] = "每轮限一次，其他角色的出牌阶段开始时，你可以交给其任意张牌。其下次回复体力后，你摸两张牌。",

  ["#steam__shenshengxianli-invoke"] = "神圣献礼：你可以交给 %src 任意张牌。其下次回复体力你摸两张牌。",
}

skel:addEffect(fk.EventPhaseStart, {
  anim_type = "drawcard",
  times = function (_, player)
    return 1 - player:usedSkillTimes(skel.name, Player.HistoryRound)
  end,
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(skel.name) and player:usedSkillTimes(skel.name, Player.HistoryRound) == 0 then
      return target ~= player and target.phase == Player.Play and not target.dead
    end
  end,
  on_cost = function (self, event, target, player, data)
    local cards = player.room:askToCards(player, {
      min_num = 1, max_num = 9999, skill_name = skel.name, include_equip = true,
      prompt = "#steam__shenshengxianli-invoke:"..target.id,
    })
    if #cards > 0 then
      event:setCostData(self, {tos = {target}, cards = cards})
      return true
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local to = event:getCostData(self).tos[1]
    room:addTableMarkIfNeed(player, "steam__shenshengxianli_record", to.id)
    room:obtainCard(to, event:getCostData(self).cards, false, fk.ReasonGive, player, skel.name)
  end,
})

skel:addEffect(fk.HpRecover, {
  is_delay_effect = true,
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return not player.dead and table.contains(player:getTableMark("steam__shenshengxianli_record"), target.id)
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    local room = player.room
    room:notifySkillInvoked(player, skel.name, "drawcard")
    room:removeTableMark(player, "steam__shenshengxianli_record", target.id)
    player:drawCards(2, skel.name)
  end,
})

return skel
