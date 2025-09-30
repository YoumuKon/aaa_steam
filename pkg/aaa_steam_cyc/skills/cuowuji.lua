local skel = fk.CreateSkill {
  name = "steam__cuowuji",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["steam__cuowuji"] = "错误技",
  [":steam__cuowuji"] = "锁定技，你受到其他角色造成的伤害后，重铸区域内的所有牌。你每回合首次造成伤害后，“堕化伊甸”摸一张牌，"..
  "然后若受伤角色没有〖错误技〗，其获得之。",
}

skel:addEffect(fk.Damage, {
  can_trigger = function (self, event, target, player, data)
    if target == player and player:hasSkill(skel.name) then
      local damageEvent = player.room.logic:getActualDamageEvents(1, function(e) return e.data.from == player end)[1]
      return damageEvent and damageEvent.data == data
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    for _, p in ipairs(room:getAlivePlayers()) do
      if not p.dead and (p.general == "steam__error_eden" or p.deputyGeneral == "steam__error_eden") then
        p:drawCards(1, skel.name)
      end
    end
    if not data.to.dead and not data.to:hasSkill(skel.name, true) then
      room:handleAddLoseSkills(data.to, skel.name)
    end
  end,
})

skel:addEffect(fk.Damaged, {
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(skel.name) and
      data.from and data.from ~= player and not player:isAllNude()
  end,
  on_use = function (self, event, target, player, data)
    player.room:recastCard(player:getCardIds("hej"), player, skel.name)
  end,
})

return skel
