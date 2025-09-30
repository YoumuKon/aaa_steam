local skel = fk.CreateSkill {
  name = "steam__jinghuaqifu",
  dynamic_desc = function (self, player, lang)
    return "steam__jinghuaqifu_dyn:" .. player:getMark("steam__crystal_skin")
  end,
}

Fk:loadTranslationTable{
  ["steam__jinghuaqifu"] = "晶化奇肤",
  [":steam__jinghuaqifu"] = "蓄力技(0/6)，每轮开始时，补满蓄力点。你成为其他角色牌的目标后，你可以消耗1蓄力点，令其进行一次【浮雷】判定，且若你受到其使用牌的伤害，你获得判定牌。",

  [":steam__jinghuaqifu_dyn"] = "蓄力技({1}/6)，每轮开始时，补满蓄力点。你成为其他角色牌的目标后，你可以消耗1蓄力点，令其进行一次【浮雷】判定，且若你受到其使用牌的伤害，你获得判定牌。",

  ["#steam__jinghuaqifu-invoke"] = "晶化奇肤：你可以消耗1蓄力点，令 %src 进行一次【浮雷】判定",
}

skel:addEffect(fk.RoundStart, {
  anim_type = "special",
  can_trigger = function (self, event, target, player, data)
    return player:hasSkill(skel.name)
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    player.room:setPlayerMark(player, "steam__crystal_skin", 6)
  end,
})

skel:addEffect(fk.TargetConfirmed, {
  anim_type = "offensive",
  can_trigger = function (self, event, target, player, data)
    if not player:hasSkill(skel.name) then return false end
    if target == player and data.from and data.from ~= player and player:getMark("steam__crystal_skin") > 0 then
      return not data.from.dead
    end
  end,
  on_cost = function (self, event, target, player, data)
    if player.room:askToSkillInvoke(player, { skill_name = skel.name, prompt = "#steam__jinghuaqifu-invoke:"..data.from.id}) then
      event:setCostData(self, {tos = {data.from} })
      return true
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    room:removePlayerMark(player, "steam__crystal_skin", 1)
    local from = data.from
    room:doIndicate(player, {from})
    local judge = {
      who = from,
      reason = "floating_thunder",
      pattern = ".|.|spade",
    }
    room:judge(judge)
    if judge.card and judge.card.suit == Card.Spade and not from.dead then
      room:damage{
        to = from,
        damage = 1,
        damageType = fk.ThunderDamage,
        skillName = skel.name,
      }
    end
    local cid = judge.card:getEffectiveId()
    if cid then
      local use = data
      use.extra_data = use.extra_data or {}
      use.extra_data.steam__jinghuaqifu_info = use.extra_data.steam__jinghuaqifu_info or {}
      use.extra_data.steam__jinghuaqifu_info[player] = use.extra_data.steam__jinghuaqifu_info[player] or {}
      table.insertIfNeed(use.extra_data.steam__jinghuaqifu_info[player], cid)
    end
  end,
})

skel:addEffect(fk.CardUseFinished, {
  is_delay_effect = true,
  mute = true,
  can_trigger = function (self, event, target, player, data)
    if not player.dead and data.damageDealt and data.damageDealt[player] then
      local t = ((data.extra_data or Util.DummyTable).steam__jinghuaqifu_info or Util.DummyTable) or Util.DummyTable
      local v = t[player]
      if v then
        event:setCostData(self, {cards = v})
        return true
      end
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local cards = table.filter(event:getCostData(self).cards, function(id)
      return room:getCardArea(id) == Card.DiscardPile
    end)
    if #cards > 0 then
      room:obtainCard(player, cards, true, fk.ReasonJustMove, player, skel.name)
    end
  end,
})

return skel
