local skel = fk.CreateSkill {
  name = "steam__dengta",
  derived_piles = "steam_treaty",
}

Fk:loadTranslationTable{
  ["steam__dengta"] = "灯塔",
  [":steam__dengta"] = "每名角色各限一次，一名角色手牌数变为1时，你可以令其将手牌置于你的武将牌旁，称为“约”，然后其摸三张牌；一名角色的体力值变为1时，你可以令其回复2点体力值。",

  ["steam_treaty"] = "约",
  ["#steam__dengta-recover"] = "灯塔：你可以令 %src 回复 2 点体力值（每名角色限一次）",
  ["#steam__dengta-put"] = "灯塔：你可以将 %src 手牌置入“约”，令其摸三张牌（每名角色限一次）",

  ["$steam__dengta1"] = "Not one American soldier is going to die on that goddamned beach.",
  ["$steam__dengta2"] = "The only way human beings can win a war is to prevent it.",
}

skel:addEffect(fk.AfterCardsMove, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(skel.name) then return false end
    local room = player.room
    local tos = {}
    for _, move in ipairs(data) do
      local temp = move.to
      if temp and temp:isAlive() and temp:getHandcardNum() == 1 and
      not table.contains(player:getTableMark("steam__dengta_put"), temp.id)
      and move.toArea == Card.PlayerHand then
        table.insertIfNeed(tos, temp)
      end
      temp = move.from
      if temp and temp:isAlive() and temp:getHandcardNum() == 1 and
      not table.contains(player:getTableMark("steam__dengta_put"), temp.id)
      and table.find(move.moveInfo, function (info) return info.fromArea == Card.PlayerHand end) then
        table.insertIfNeed(tos, temp)
      end
    end
    if #tos > 0 then
      event:setCostData(self, {targets = tos})
      return true
    end
  end,
  on_trigger = function (self, event, target, player, data)
    local tos = table.simpleClone(event:getCostData(self).targets) ---@type ServerPlayer[]
    local room = player.room
    room:sortByAction(tos)
    for _, to in ipairs(tos) do
      if not player:hasSkill(skel.name) then break end
      if not to.dead and to:getHandcardNum() == 1 and not table.contains(player:getTableMark("steam__dengta_put"), to.id) then
        self:doCost(event, to, player, data)
      end
    end
  end,
  on_cost = function (self, event, target, player, data)
    if player.room:askToSkillInvoke(player, { skill_name = skel.name, prompt = "#steam__dengta-put:"..target.id}) then
      player.room:addTableMark(player, "steam__dengta_put", target.id)
      event:setCostData(self, {tos = {target} })
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local to = target ---@type ServerPlayer
    player:addToPile("steam_treaty", to:getCardIds("h"), true, skel.name)
    if not to.dead then
      to:drawCards(3, skel.name)
    end
  end,
})

skel:addEffect(fk.HpChanged, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(skel.name) then return false end
    return not target.dead and target.hp == 1 and target:isWounded()
      and not table.contains(player:getTableMark("steam__dengta_recover"), target.id)
  end,
  on_cost = function (self, event, target, player, data)
    if player.room:askToSkillInvoke(player, { skill_name = skel.name, prompt = "#steam__dengta-recover:"..target.id}) then
      event:setCostData(self, {tos = {target} })
      player.room:addTableMark(player, "steam__dengta_recover", target.id)
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    player.room:recover { num = 2, skillName = skel.name, who = target, recoverBy = player }
  end,
})

return skel
