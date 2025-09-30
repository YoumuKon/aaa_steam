local skel = fk.CreateSkill {
  name = "steam__shengsipaihuai",
  tags = {Skill.Compulsory},
  derived_piles = "$steam__shengsipaihuai_pile",
}

Fk:loadTranslationTable{
  ["steam__shengsipaihuai"] = "生死徘徊",
  [":steam__shengsipaihuai"] = "锁定技，游戏开始时，你摸四张牌并将四张牌扣置于武将牌旁。你的额定回合结束后，你用手牌交换武将牌旁的牌，执行一个额外回合。",

  ["#steam__shengsipaihuai-put"] = "生死徘徊：将四张牌扣置于武将牌旁！",
  ["$steam__shengsipaihuai_pile"] = "生死徘徊",
}

skel:addEffect(fk.GameStart, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(skel.name)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:drawCards(4, skel.name)
    if player.dead or player:isNude() then return end
    local cards = player:getCardIds("he")
    if #cards > 4 then
      cards = room:askToCards(player, { min_num = 4, max_num = 4, include_equip = true,
       skill_name = skel.name, cancelable = false, prompt = "#steam__shengsipaihuai-put"})
    end
    player:addToPile("$steam__shengsipaihuai_pile", cards, false, skel.name)
  end,
})

skel:addEffect(fk.TurnEnd, {
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(skel.name) then
      return target == player and not player:insideExtraTurn()
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local hand, pile = player:getCardIds("h"), player:getPile("$steam__shengsipaihuai_pile")
    if #hand > 0 or #pile > 0 then
      room:swapCardsWithPile(player, hand, pile, skel.name, "$steam__shengsipaihuai_pile", false)
    end
    if player.dead then return end
    player:gainAnExtraTurn(true, skel.name)
  end,
})

skel:addEffect(fk.TurnStart, {-- 每回合开始时切换插画
  can_refresh = function (self, event, target, player, data)
    return target == player
  end,
  on_refresh = function (self, event, target, player, data)
    local room = player.room
    local ge1, ge2 = "steam__corrupted_lazarus", "steam2__corrupted_lazarus"
    if player.general == ge1 then
      room:setPlayerProperty(player, "general", ge2)
    elseif player.general == ge2 then
      room:setPlayerProperty(player, "general", ge1)
    end
    if player.deputyGeneral == ge1 then
      room:setPlayerProperty(player, "deputyGeneral", ge2)
    elseif player.deputyGeneral == ge2 then
      room:setPlayerProperty(player, "deputyGeneral", ge1)
    end
  end,
})

return skel
