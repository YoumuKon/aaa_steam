local skel = fk.CreateSkill {
  name = "steam__niuqulinghun",
  tags = {Skill.Compulsory},
}

Fk:loadTranslationTable{
  ["steam__niuqulinghun"] = "扭曲灵魂",
  [":steam__niuqulinghun"] = "锁定技，每名其他角色首次受到伤害后，你夺取其1点手牌上限。弃牌阶段开始时，你用【法】将手牌补至上限（至多5张）。",

  ["#steam__niuqulinghun_draw"] = "扭曲灵魂",
  ["$steam__niuqulinghun1"] = "嗯哼——啦啦啦啦",
  ["$steam__niuqulinghun2"] = "嗯！啦啦啦",
}

skel:addEffect(fk.Damaged, {
  anim_type = "control",
  can_trigger = function (self, event, target, player, data)
    if player:hasSkill(skel.name) and target ~= player then
      local damageEvent = player.room.logic:getCurrentEvent():findParent(GameEvent.Damage, true)
      if not damageEvent then return false end
      local currentId = damageEvent.id
      local recordId = 0
      player.room.logic:getActualDamageEvents(1, function(e)
        if e.data.to == target then
          recordId = e.id
          return true
        end
        return false
      end, Player.HistoryGame)
      return currentId == recordId
    end
  end,
  on_cost = function (self, event, target, player, data)
    event:setCostData(self, {tos = {target} })
    return true
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    room:addPlayerMark(target, MarkEnum.MinusMaxCards)
    room:addPlayerMark(player, MarkEnum.AddMaxCards)
  end,
})

skel:addEffect(fk.EventPhaseStart, {
  anim_type = "drawcard",
  can_trigger = function (self, event, target, player, data)
    if player:hasSkill(skel.name) and player == target and player.phase == Player.Discard then
      return player:getHandcardNum() < player:getMaxCards()
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    if Fk.all_card_types["charm"] == nil then return end
    local x = math.min(player:getMaxCards() - player:getHandcardNum(), 5)
    local ids = {}
    for _ = 1, x do
      table.insert(ids, room:printCard("charm", math.random(4), math.random(13)).id)
    end
    room:obtainCard(player, ids, true, fk.ReasonJustMove, player, skel.name)
  end,
})

return skel
