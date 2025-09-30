local skel = fk.CreateSkill {
  name = "steam__jierunang",
  tags = {Skill.Compulsory},
}

Fk:loadTranslationTable{
  ["steam__jierunang"] = "皆入囊",
  [":steam__jierunang"] = "锁定技，每回合结束时，你获得中央区中其他角色使用过的【顺手牵羊】。",
}

skel:addAcquireEffect(function (self, player, is_start)
  player.room:addSkill("#CenterArea")
end)

skel:addEffect(fk.TurnEnd, {
  anim_type = "drawcard",
  can_trigger = function (self, event, target, player, data)
    if not player:hasSkill(skel.name) then return false end
    local cards = table.filter(player.room:getBanner("@$CenterArea") or Util.DummyTable, function (id)
      return Fk:getCardById(id).name == "snatch"
    end)
    if #cards == 0 then return false end
    local get = {}
    player.room.logic:getEventsOfScope(GameEvent.UseCard, 1, function(e)
      local use = e.data
      if use.card.name == "snatch" and use.from ~= player then
        for _, id in ipairs(Card:getIdList(use.card)) do
          if Fk:getCardById(id).name == "snatch" then
            table.insertIfNeed(get, id)
          end
        end
      end
      return false
    end, Player.HistoryTurn)
    if #get > 0 then
      event:setCostData(self, {cards = get})
      return true
    end
  end,
  on_use = function (self, event, target, player, data)
    player.room:obtainCard(player, event:getCostData(self).cards, true, fk.ReasonJustMove, player, self.name)
  end,
})

return skel
