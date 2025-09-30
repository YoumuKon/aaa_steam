local skel = fk.CreateSkill {
  name = "steam__haohuazhuangui",
  derived_piles = "luxury_showcase",
}

Fk:loadTranslationTable{
  ["steam__haohuazhuangui"] = "豪华专柜",
  [":steam__haohuazhuangui"] = "你没有判定区，改为一个容量为3的展柜。每轮开始时，将牌堆顶的三张牌置入展柜；每回合限一次，你造成伤害后，可以将受伤角色的一张牌置入展柜(超过3张时须弃置多余牌)。",

  ["luxury_showcase"] = "专柜",
  ["#steam__haohuazhuangui-put"] = "豪华专柜：你可以将 %src 一张牌置入“专柜”",
}

--- 往展柜塞牌
---@param player ServerPlayer
---@param cards integer[]
local function addToShowcase(player, cards)
  local room = player.room
  local pilename = "luxury_showcase"
  player:addToPile(pilename, cards, true, skel.name)
  -- 溢出移除
  local x = #player:getPile(pilename) - 3
  if x > 0 then
    local throw = room:askToChooseCards(player, {
      target = player, skill_name = skel.name, min = x, max = x, prompt = "#showcase-remove:::" .. x,
      flag = { card_data = { { pilename, player:getPile(pilename) } } }
    })
    room:moveCardTo(throw, Card.DiscardPile, nil, fk.ReasonPutIntoDiscardPile, skel.name, nil, true, player)
  end
end


skel:addEffect(fk.Damage, {
  anim_type = "control",
  times = function (self, player)
    return 1 - player:usedEffectTimes(self.name, Player.HistoryTurn)
  end,
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(skel.name) then
      return target == player and not data.to:isNude() and player:usedEffectTimes(self.name, Player.HistoryTurn) == 0
    end
  end,
  on_cost = function (self, event, target, player, data)
    if player.room:askToSkillInvoke(player, { skill_name = skel.name, prompt = "#steam__haohuazhuangui-put:"..data.to.id }) then
      event:setCostData(self, {tos = {data.to} })
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cid = room:askToChooseCard(player, { target = data.to, flag = "he", skill_name = skel.name})
    addToShowcase(player, {cid})
  end,
})

skel:addEffect(fk.RoundStart, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(skel.name)
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    addToShowcase(player, player.room:getNCards(3))
  end,
})

-- 这部分别写在onAcquire里，因为会触发事件
skel:addEffect(fk.EventAcquireSkill, {
  can_trigger = function(self, event, target, player, data)
    return target == player and data.skill.name == skel.name and not table.contains(player.sealedSlots, Player.JudgeSlot)
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    player.room:abortPlayerArea(player, Player.JudgeSlot)
  end,
})


return skel
