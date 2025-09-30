local skel = fk.CreateSkill {
  name = "steam__aerfatuxi",
  tags = {Skill.Limited},
}

Fk:loadTranslationTable{
  ["steam__aerfatuxi"] = "阿尔法突袭",
  [":steam__aerfatuxi"] = "限定技，你可以跳过一个主要阶段，视为使用一张不计入次数、目标上限无限的【杀】。",
  ["#steam__aerfatuxi-use"] = "阿尔法突袭：你可以跳过【%arg】，对任意名角色使用【杀】",

  ["$steam__aerfatuxi1"] = "敌人虽众，一击皆斩",
  ["$steam__aerfatuxi2"] = "一展千机",
}

skel:addEffect(fk.EventPhaseChanging, {
  times = function (self, player) return 1 - player:usedSkillTimes(skel.name, Player.HistoryGame) end,
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(skel.name) or player:usedSkillTimes(skel.name, Player.HistoryGame) > 0 then return false end
    return target == player and not data.skipped and
    table.contains({Player.Judge, Player.Draw, Player.Play, Player.Discard}, data.phase)
  end,
  on_cost = function (self, event, target, player, data)
    local card = Fk:cloneCard("slash")
    card.skillName = skel.name
    local room = player.room
    if player:prohibitUse(card) then return false end
    local targets = table.filter(room:getOtherPlayers(player, false), function (p) return not player:isProhibited(p, card) end)
    if #targets == 0 then return false end
    local tos = player.room:askToChoosePlayers(player, {
      targets = targets, min_num = 1, max_num = 9999,
      prompt = "#steam__aerfatuxi-use:::"..Util.PhaseStrMapper(data.phase), skill_name = skel.name,
    })
    if #tos > 0 then
      event:setCostData(self, {tos = tos})
      return true
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local card = Fk:cloneCard("slash")
    card.skillName = skel.name
    room:useCard{
      from = player,
      tos = event:getCostData(self).tos,
      card = card,
      extraUse = true,
    }
    data.skipped = true
  end,
})

return skel
