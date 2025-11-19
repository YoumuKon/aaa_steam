local skel = fk.CreateSkill{
  name = "steam__shiwei",
}

Fk:loadTranslationTable{
  ["steam__shiwei"] = "誓卫",
  [":steam__shiwei"] = "每轮限一次，其他角色成为伤害牌的唯一目标时，你可以赠予其一张牌以转移给你。若如此做，直到本轮结束，你未受到过伤害的回合内，防止其受到的伤害。",

  ["#steam__shiwei-choose"] = "誓卫：%src 对 %dest 使用%arg，是否交给目标一张牌或将一张装备牌置入其装备区，将此牌转移给你。",
  ["steam__shiwei-give"] = "交给目标一张牌",
  ["steam__shiwei-move"] = "将一张装备牌置入目标装备区",
  ["@steam__shiwei-round"] = "誓卫",

  ["$steam__shiwei1"] = " ",
  ["$steam__shiwei2"] = " ",
}

skel:addEffect(fk.TargetConfirming, {
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(skel.name) and not player:isNude() and target ~= player 
    and data.card.is_damage_card and data:isOnlyTarget(target) and not data.cancelled
    and player:usedEffectTimes(self.name, Player.HistoryRound) == 0
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local success, dat = room:askToUseActiveSkill(player, {
      skill_name = "steam__shiwei_active",
      prompt = "#steam__shiwei-choose:"..data.from.id..":"..data.to.id..":"..data.card:toLogString(),
      cancelable = true,
      extra_data = {
        tos = data.to.id,
      }
    })
    if success and dat then
      event:setCostData(self, {tos = {target}, choice = dat.interaction, cards = dat.cards})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = event:getCostData(self).tos[1]
    local choice = event:getCostData(self).choice
    local cards = event:getCostData(self).cards ---@type integer[]
    if choice == "steam__shiwei-give" then
      room:obtainCard(to, cards, false, fk.ReasonGive, player, skel.name)
    elseif choice == "steam__shiwei-move" then
      room:moveCardIntoEquip(to, cards, skel.name, false, player)
    end
    if not data.from:isProhibited(player, data.card) and not player.dead and data:cancelCurrentTarget() then
      data:addTarget(player)
    end
    if not player.dead then
      room:setPlayerMark(player, "@steam__shiwei-round", to)
    end
  end,
})

skel:addEffect(fk.DamageInflicted, {
  anim_type = "support",
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(skel.name) and player:getMark("@steam__shiwei-round") == target and
      #player.room.logic:getActualDamageEvents(1, function (e) return e.data.to == player end, Player.HistoryTurn) == 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    data:preventDamage()
  end,
})

return skel
