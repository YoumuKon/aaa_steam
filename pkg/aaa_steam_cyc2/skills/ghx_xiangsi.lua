local skel = fk.CreateSkill {
  name = "godhanxin__xiangsi",
}

Fk:loadTranslationTable{
  ["godhanxin__xiangsi"] = "相思",
  [":godhanxin__xiangsi"] = "你使用【杀】指定目标后，可以先视为对其中一名目标使用一张【推心置腹】，若其因此获得<font color='red'>♥</font>牌，此【杀】伤害+1。",

  ["#godhanxin__xiangsi-choose"] = "是否发动 相思，视为对其中一名目标使用【推心置腹】，若其因此获得红桃牌，此【杀】的伤害+1。",
  ["#godhanxin__xiangsi-invoke"] = "是否对%dest发动 相思，视为对其使用【推心置腹】，若其因此获得红桃牌，此【杀】的伤害+1。",

  ["$godhanxin__xiangsi"] = "第一枪，长相思兮长相忆，短相思兮无穷极，相思！",
}

skel:addEffect(fk.TargetSpecified, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(skel.name) and data.firstTarget and data.card.trueName == "slash"
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local card = Fk:cloneCard("sincere_treat")
    card.skillName = skel.name
    if player:prohibitUse(card) then return false end
    local targets = table.filter(data.use.tos, function (to)
      return not to.dead and not to:isAllNude() and not player:isProhibited(to,card)
    end)
    if #targets == 1 then
      if room:askToSkillInvoke(player, { skill_name = skel.name, prompt = "#godhanxin__xiangsi-invoke::" .. targets[1].id}) then
        event:setCostData(self, { tos = targets })
        return true
      end
    elseif #targets > 1 then
      local tos = room:askToChoosePlayers(player, { targets = targets, max_num = 1, min_num = 1,
      prompt = "#godhanxin__xiangsi-choose", skill_name = skel.name })
      if #tos > 0 then
        event:setCostData(self, { tos = tos })
        return true
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = event:getCostData(self).tos[1]
    local card = Fk:cloneCard("sincere_treat")
    card.skillName = skel.name
    local use = {
      from = player,
      card = card,
      tos = { to },
      extraUse = true,
    }
    room:useCard(use)
    if use.extra_data and use.extra_data.godhanxin__xiangsi then
      data.additionalDamage = (data.additionalDamage or 0) + 1
    end
  end,
})

skel:addEffect(fk.AfterCardsMove, {
  can_refresh = function(self, event, target, player, data)
    local e = player.room.logic:getCurrentEvent():findParent(GameEvent.CardEffect)
    if e then
      local eff = e.data
      if eff.card.trueName == "sincere_treat" and table.contains(eff.card.skillNames, skel.name) and eff.to == player then
        return true
      end
    end
  end,
  on_refresh = function(self, event, target, player, data)
    for _, move in ipairs(data) do
      if move.to == player and move.toArea == Card.PlayerHand and move.skillName and string.find(move.skillName, "sincere_treat")  then
        for _, info in ipairs(move.moveInfo) do
          if Fk:getCardById(info.cardId).suit == Card.Heart then
            local e = player.room.logic:getCurrentEvent():findParent(GameEvent.UseCard)
            if e then
              local use = e.data
              use.extra_data = use.extra_data or {}
              use.extra_data.godhanxin__xiangsi = true
            end
            return
          end
        end
      end
    end
  end,
})

return skel
