local skel = fk.CreateSkill {
  name = "steam__renzhiyi",
}

Fk:loadTranslationTable{
  ["steam__renzhiyi"] = "韧之意",
  [":steam__renzhiyi"] = "每轮限一次，一名角色的回合开始时，你可以视为使用一张【调虎离山】(不能指定回合角色)，若含上次的目标，你先对其各造成1点伤害。",

  ["steam__renzhiyi_active"] = "韧之意",
  ["#steam__renzhiyi-choose"] = "韧之意：你可以视为使用一张【调虎离山】，对上次目标造成伤害",
  ["last_target"] = "上次目标",

  ["$steam__renzhiyi1"] = "杀！",
  ["$steam__renzhiyi2"] = "哈！",
}

skel:addEffect(fk.TurnStart, {
  anim_type = "control",
  times = function (_, player)
    return 1 - player:usedSkillTimes(skel.name, Player.HistoryRound)
  end,
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(skel.name) or target.dead or Fk.all_card_types["lure_tiger"] == nil then return false end
    return player:usedSkillTimes(skel.name, Player.HistoryRound) == 0
    and not player:prohibitUse(Fk:cloneCard("lure_tiger"))
  end,
  on_cost = function (self, event, target, player, data)
    local _, dat = player.room:askToUseActiveSkill(player, { skill_name = "steam__renzhiyi_active",
    prompt = "#steam__renzhiyi-choose", extra_data = {renzhiyi_tar = target.id} })
    if dat then
      player.room:sortByAction(dat.targets)
      event:setCostData(self, {tos = dat.targets})
      return true
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local tos = event:getCostData(self).tos
    local last = player:getTableMark("steam__renzhiyi_last")
    local victims = table.filter(tos, function(p) return table.contains(last, p.id) end)
    room:setPlayerMark(player, "steam__renzhiyi_last", table.map(tos, Util.IdMapper))
    for _, p in ipairs(victims) do
      if not p.dead then
        room:doIndicate(player, {p})
        room:damage { from = player, to = p, damage = 1, skillName = skel.name }
      end
    end
    local card = Fk:cloneCard("lure_tiger")
    card.skillName = skel.name
    room:useCard{
      from = player,
      tos = tos,
      card = card,
      extraUse = true,
    }
  end,
})

local skel2 = fk.CreateSkill {
  name = "steam__renzhiyi_active",
}

skel2:addEffect("active", {
  card_num = 0,
  min_target_num = 1,
  card_filter = Util.FalseFunc,
  target_tip = function (self, player, to_select, selected, selected_cards, card, selectable, extra_data)
    if self.renzhiyi_tar == to_select.id then
      return { {content = "prohibit", type = "warning"} }
    end
    local last = player:getTableMark("steam__renzhiyi_last")
    if table.contains(last, to_select.id) then
      return "last_target"
    end
  end,
  target_filter = function (self, player, to, selected)
    if self.renzhiyi_tar == to.id then return false end
    local card = Fk:cloneCard("lure_tiger")
    card.skillName = skel.name
    return not player:isProhibited(to, card) and #selected < card.skill:getMaxTargetNum(player, card)
  end,
})

return {skel, skel2}
