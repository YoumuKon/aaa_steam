local skel = fk.CreateSkill {
  name = "steam__qiaolve",
}

Fk:loadTranslationTable{
  ["steam__qiaolve"] = "趫掠",
  [":steam__qiaolve"] = "出牌阶段限一次，你可失去1点体力并将一张牌当无距离次数限制且无视防具的【杀】对一名其他角色使用。"..
  "使用时，若有目标手牌比你多一张，你可以回复1点体力。结算后，你可以选择重复此流程或与该角色交换手牌。",
  ["steam__qiaolve1"] = "再发动一次本技能",
  ["steam__qiaolve2"] = "与 %dest 交换手牌",
  ["#steam__qiaolve"] = "趫掠：失去1点体力，将一张牌当【杀】对一名角色使用（无距离次数限制）",
  ["#steam__qiaolve-invoke"] = "趫掠：是否回复1点体力？",

  ["$steam__qiaolve1"] = " ",
  ["$steam__qiaolve2"] = " ",
}

skel:addEffect("active", {
  prompt = "#steam__qiaolve",
  anim_type = "offensive",
  card_num = 1,
  target_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(skel.name, Player.HistoryPhase) == 0 and not player:prohibitUse(Fk:cloneCard("slash"))
    and table.find(player:getCardIds("he"), function (id) return not player:prohibitUse(Fk:getCardById(id)) end)
  end,
  card_filter = function(self, player, to_select, selected)
    return #selected == 0 and not player:prohibitUse(Fk:getCardById(to_select))
  end,
  target_filter = function(self, player, to_select, selected, selected_cards)
    return #selected == 0 and to_select ~= player and not player:isProhibited(to_select, Fk:cloneCard("slash"))
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    room:loseHp(player, 1, skel.name)
    if player.dead or target.dead then return end
    local slash = Fk:cloneCard("slash")
    slash.skillName = skel.name
    slash:addSubcard(Fk:getCardById(effect.cards[1]))
    local use = {
      from = player,
      tos = {target},
      card = slash,
      extraUse = true,
    }
    room:useCard(use)
    if not player.dead then
      local choices = {"cancel"}
      if #table.filter(player:getCardIds("he"), function (id) return not player:prohibitUse(Fk:getCardById(id)) end) > 0
      and table.find(room.alive_players, function (p) return not player:isProhibited(p, Fk:cloneCard("slash")) end) then
        table.insert(choices, "steam__qiaolve1")
      end
      if not target.dead then
        table.insert(choices, "steam__qiaolve2::"..effect.tos[1].id)
      end
      local choice = room:askToChoice(player, {
        choices = choices,
        skill_name = skel.name,
      })
      if choice == "steam__qiaolve1" then
        room:askToUseActiveSkill(player, {
          skill_name = skel.name,
          prompt = "#steam__qiaolve",
          cancelable = false,
        })
      elseif choice == "steam__qiaolve2::"..effect.tos[1].id then
        room:swapAllCards(player, {player, target}, skel.name)
      end
    end
  end,
})

skel:addEffect(fk.CardUsing, {
  can_refresh = function (self, event, target, player, data)
    return target == player and table.contains(data.card.skillNames, skel.name) and not player.dead and
    table.find(data.tos, function (p) return p:getHandcardNum() - player:getHandcardNum() == 1 end)
  end,
  on_refresh = function (self, event, target, player, data)
    if player.room:askToSkillInvoke(target, {
      skill_name = skel.name,
      prompt = "#steam__qiaolve-invoke",
    }) then
      player.room:recover{
        who = player,
        num = 1,
        recoverBy = player,
        skillName = skel.name,
      }
    end
  end 
})

skel:addEffect(fk.TargetSpecified, {
  can_refresh = function (self, event, target, player, data)
    return player == data.to and table.contains(data.card.skillNames, skel.name) and not player.dead
  end,
  on_refresh = function (self, event, target, player, data)
    data.to:addQinggangTag(data)
  end 
})

return skel
