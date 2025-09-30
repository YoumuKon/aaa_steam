local skel = fk.CreateSkill {
  name = "steam__nianqing",
  tags = {Skill.Wake},
}

Fk:loadTranslationTable{
  ["steam__nianqing"] = "念卿",
  [":steam__nianqing"] = "觉醒技，蜀势力角色进入濒死时，你将“试剑”中的【杀】改为【桃】，且你只能以“试剑”使用【桃】。",

  ["@@steam__nianqing"] = "试剑 仅能转桃",

  ["$steam__nianqing1"] = "离情别绪生，回忆长相思。",
  ["$steam__nianqing2"] = "依依不舍情，久久别离恨。",
}

skel:addEffect(fk.EnterDying, {
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(skel.name) and target.dying and target.kingdom == "shu"
    and player:usedSkillTimes(skel.name, Player.HistoryGame) == 0
  end,
  can_wake = function(self, event, target, player, data)
    return target.dying
  end,
  on_use = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "@@steam__nianqing", 1)
  end,
})

skel:addEffect("prohibit", {
  prohibit_use = function(self, player, card)
    if player:getMark("@@steam__nianqing") > 0 then
      if not card:isVirtual() then --转化虚拟不杀，不然自己没法用实体桃转化
        return card.trueName == "peach" and not table.contains(card.skillNames, "steam__shijian")
      end
    end
  end,
})

skel:addLoseEffect(function (self, player, is_death)
  player.room:setPlayerMark(player, "@@steam__nianqing", 0)
end)

return skel
