local mingduan = fk.CreateSkill {
  name = "steam__mingduan",
}

Fk:loadTranslationTable{
  ["steam__mingduan"] = "明断",
  [":steam__mingduan"] = "你与其他角色于出牌阶段内使用的目标包含对方的首张牌结算后，你可以令一名目标进行一次【浮雷】判定并蓄谋判定牌。",

  ["#steam__mingduan-choose"] = "明断：你可以令一名目标进行一次【浮雷】判定并蓄谋判定牌",

  ["$steam__mingduan1"] = "电光石火，有触即发！",
  ["$steam__mingduan2"] = "有术无道，愚不可及！",
}

local U = require "packages/utility/utility"

mingduan:addEffect(fk.CardUseFinished, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(mingduan.name) and
      target.phase == Player.Play and
      player:usedSkillTimes(mingduan.name, Player.HistoryPhase) == 0 then
      if target == player then
        if table.find(data.tos, function (p)
          return p ~= player and not p.dead
        end) then
          local use_events = player.room.logic:getEventsOfScope(GameEvent.UseCard, 2, function (e)
            return e.data.from == player and table.find(e.data.tos, function (p)
              return p ~= player
            end) ~= nil
          end, Player.HistoryPhase)
          return #use_events == 1 and use_events[1].data.card == data.card
        end
      else
        if table.contains(data.tos, player) then
          local use_events = player.room.logic:getEventsOfScope(GameEvent.UseCard, 2, function (e)
            return e.data.from == target and table.contains(e.data.tos, player)
          end, Player.HistoryPhase)
          return #use_events == 1 and use_events[1].data.card == data.card
        end
      end
    end
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local tos = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = data.tos,
      skill_name = mingduan.name,
      prompt = "#steam__mingduan-choose",
      cancelable = true,
    })
    if #tos > 0 then
      room:sortByAction(tos)
      event:setCostData(self, {tos = tos})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local tos = event:getCostData(self).tos or {}
    for _, p in ipairs(tos) do
      if not p.dead then
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
            card = data.card,
            damageType = Fk:getDamageNature(fk.ThunderDamage) and fk.ThunderDamage or fk.NormalDamage,
            skillName = "floating_thunder_skill",
          }
        end
        if judge.card and room:getCardArea(judge.card) == Card.DiscardPile and #Card:getIdList(judge.card) == 1 and
          not player.dead then
          U.premeditate(player, judge.card, mingduan.name)
        end
      end
    end
  end,
})

return mingduan
