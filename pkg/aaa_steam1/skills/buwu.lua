local skel = fk.CreateSkill {
  name = "steam__buwu",
  tags = {Skill.Compulsory},
}

Fk:loadTranslationTable{
  ["steam__buwu"] = "布武",
  [":steam__buwu"] = "锁定技，其他角色的装备牌进入弃牌堆时，若你对应的装备栏无牌，将此牌置入你装备区；其他角色阵亡后，若你不为杀死其的角色，你于结算奖惩后结算一次杀死其身份的奖惩。",
}

skel:addEffect(fk.AfterCardsMove, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(skel.name) then return false end
    local room = player.room
    local ids = {}
    for _, move in ipairs(data) do
      if move.toArea == Card.DiscardPile and move.from and move.from ~= player then
        for _, info in ipairs(move.moveInfo) do
          if room:getCardArea(info.cardId) == Card.DiscardPile and info.fromArea == Card.PlayerEquip then
            local card = Fk:getCardById(info.cardId)
            if player:getEquipment(card.sub_type) == nil and table.every(ids, function (id)
              return Fk:getCardById(id).sub_type ~= card.sub_type
            end) then
              table.insert(ids, info.cardId)
            end
          end
        end
      end
    end
    if #ids > 0 then
      event:setCostData(self, ids)
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:delay(200)
    room:moveCardIntoEquip(player, event:getCostData(self), skel.name, false, player)
  end,
})

skel:addEffect(fk.Deathed, {
  anim_type = "negative",
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(skel.name) then return false end
    return target ~= player and not (data.killer == player)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local mode = Fk.game_modes[room.settings.gameMode]
    if mode and type(mode.deathRewardAndPunish) == "function" then
      mode:deathRewardAndPunish(target, player)
    end
  end,
})

return skel
