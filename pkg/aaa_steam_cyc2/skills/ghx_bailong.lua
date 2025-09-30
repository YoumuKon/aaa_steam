local skel = fk.CreateSkill {
  name = "godhanxin__bailong",
}

Fk:loadTranslationTable{
  ["godhanxin__bailong"] = "白龙",
  [":godhanxin__bailong"] = "你使用【杀】对目标造成伤害后，可以弃置你与其各一张牌，若颜色不同，你视为使用一张【决斗】。",

  ["$godhanxin__bailong"] = "枪似游龙万兵手，命若黄泉不回头，第六枪，白龙！",
}

skel:addEffect(fk.Damage, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(skel.name) and data.card and data.card.trueName == "slash" and
      not data.to:isNude() and table.find(player:getCardIds("he"), function(id) return not player:prohibitDiscard(Fk:getCardById(id)) end)
      and data.by_user and player.room.logic:damageByCardEffect() --别人检测是否有牌，你需要检测是否有牌可弃
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = data.to
    local cards1 = room:askToDiscard(player, {
      min_num = 1, max_num = 1, skill_name = skel.name, cancelable = false, include_equip = true
    })
    local cards2 = {room:askToChooseCard(player, {target = to, flag ="he", skill_name = skel.name })}
    -- 使用同时移动防止插结
    room:moveCards({
      ids = cards1,
      from = player,
      toArea = Card.DiscardPile,
      moveReason = fk.ReasonDiscard,
      skillName = skel.name,
      proposer = player,
    },{
      ids = cards2,
      from = to,
      toArea = Card.DiscardPile,
      moveReason = fk.ReasonDiscard,
      skillName = skel.name,
      proposer = player,
    })
    if player:isAlive() and cards1[1] and cards2[1] and Fk:getCardById(cards1[1]).color ~= Fk:getCardById(cards2[1]).color then
      room:askToUseVirtualCard(player, {
        name = "duel", skill_name = skel.name, cancelable = false
      })
    end
  end,
})



return skel
