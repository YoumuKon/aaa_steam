local shewei = fk.CreateSkill {
  name = "steam__shewei",
}

Fk:loadTranslationTable{
  ["steam__shewei"] = "摄威",
  [":steam__shewei"] = "判定阶段开始时，你可以依次重铸、置顶区域内共计至多X张牌（X为你的体力值），然后令等量名角色各进行一次【浮雷】判定，"..
  "本回合出牌阶段限一次，你使用即时牌可以额外指定一名未因此受到伤害的角色。",

  ["#steam__shewei-card"] = "摄威：将一张牌重铸或置顶（第%arg张/共%arg2张）",
  ["#steam__shewei-choose"] = "摄威：令%arg名角色进行【浮雷】判定",
  ["@@steam__shewei-turn"] = "摄威",
  ["#steam__shewei-target"] = "摄威：你可以为%arg额外指定一个目标",

  ["$steam__shewei1"] = "三元归一剑贯魑魅，一点浩气霆击祸祟！",
  ["$steam__shewei2"] = "斩妖除奸恶，雷霆动乾坤！",
  ["$steam__shewei3"] = "天雷滚滚，你想往哪里逃！",
}

shewei:addEffect(fk.EventPhaseStart, {
  anim_type = "drawcard",
  audio_index = {1, 2},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(shewei.name) and
      player.phase == Player.Judge and not player:isAllNude() and player.hp > 0
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local success, dat = room:askToUseActiveSkill(player, {
      skill_name = "#steam__shewei_active",
      prompt = "#steam__shewei-card:::1:"..player.hp,
    })
    if success and dat then
      event:setCostData(self, {cards = dat.cards, choice = dat.interaction})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local card = event:getCostData(self).cards
    local choice = event:getCostData(self).choice
    local total, n = player.hp, 1
    if choice == "recast" then
      room:recastCard(card, player, shewei.name)
    else
      room:moveCards({
        ids = card,
        from = player,
        toArea = Card.DrawPile,
        moveReason = fk.ReasonPut,
        skillName = shewei.name,
        drawPilePosition = 1,
      })
    end
    if total > 1 then
      for i = 2, total, 1 do
        if player.dead or player:isAllNude() then break end
        local success, dat = room:askToUseActiveSkill(player, {
          skill_name = "#steam__shewei_active",
          prompt = "#steam__shewei-card:::"..i..":"..total,
        })
        if not (success and dat) then
          break
        end
        n = n + 1
        if dat.interaction == "recast" then
          room:recastCard(dat.cards, player, shewei.name)
        else
          room:moveCards({
            ids = dat.cards,
            from = player,
            toArea = Card.DrawPile,
            moveReason = fk.ReasonPut,
            skillName = shewei.name,
            drawPilePosition = 1,
          })
        end
      end
    end
    if player.dead then return end
    local tos = table.simpleClone(room.alive_players)
    if #tos > n then
      tos = room:askToChoosePlayers(player, {
        min_num = n,
        max_num = n,
        targets = room.alive_players,
        skill_name = shewei.name,
        prompt = "#steam__shewei-choose:::"..n,
        cancelable = false,
      })
    end
    room:sortByAction(tos)
    for _, p in ipairs(tos) do
      local judge = {
        who = p,
        reason = "floating_thunder",
        pattern = ".|.|spade",
      }
      room:judge(judge)
      if judge:matchPattern() then
        room:damage{
          to = p,
          damage = 1,
          damageType = Fk:getDamageNature(fk.ThunderDamage) and fk.ThunderDamage or fk.NormalDamage,
          skillName = "floating_thunder_skill",
        }
      elseif not p.dead and not player.dead then
        room:addTableMarkIfNeed(p, "@@steam__shewei-turn", player.id)
      end
    end
  end,
})

shewei:addEffect(fk.AfterCardTargetDeclared, {
  anim_type = "offensive",
  audio_index = 3,
  can_trigger = function (self, event, target, player, data)
    return target == player and not player.dead and player.phase == Player.Play and
      (data.card.type == Card.TypeBasic or data.card:isCommonTrick()) and
      table.find(data:getExtraTargets({bypass_distances = true}), function (p)
        return table.contains(p:getTableMark("@@steam__shewei-turn"), player.id)
      end) and
      player:usedEffectTimes(self.name, Player.HistoryPhase) == 0
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local targets = table.filter(data:getExtraTargets({bypass_distances = true}), function (p)
      return table.contains(p:getTableMark("@@steam__shewei-turn"), player.id)
    end)
    local to = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = targets,
      skill_name = shewei.name,
      prompt = "#steam__shewei-target:::"..data.card:toLogString(),
      cancelable = true,
    })
    if #to > 0 then
      event:setCostData(self, {tos = to})
      return true
    end
  end,
  on_use = function (self, event, target, player, data)
    local to = event:getCostData(self).tos[1]
    player.room:sendLog{
      type = "#AddTargetsBySkill",
      from = player.id,
      to = {to.id},
      arg = shewei.name,
      arg2 = data.card:toLogString()
    }
    data:addTarget(to)
  end,
})
return shewei
