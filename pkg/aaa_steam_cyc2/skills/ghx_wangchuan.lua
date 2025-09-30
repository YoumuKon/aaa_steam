local skel = fk.CreateSkill {
  name = "godhanxin__wangchuan",
}

Fk:loadTranslationTable{
  ["godhanxin__wangchuan"] = "忘川",
  [":godhanxin__wangchuan"] = "你使用【杀】指定目标后，可以弃置其两张牌，令此【杀】伤害-1。",

  ["#godhanxin__wangchuan-card"] = "忘川：弃置 %dest 两张牌",

  ["$godhanxin__wangchuan"] = "有过痛苦方知众生痛苦，有过牵挂了无牵挂，若是修佛先修心，一枪风雪一枪冰，第七枪，忘川！",
}

skel:addEffect(fk.TargetSpecified, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(skel.name) and data.card.trueName == "slash" and #data.to:getCardIds("he") >= 2
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = data.to
    local cards = to:getCardIds("he")
    if #cards > 2 then
      cards = room:askToChooseCards(player, { target = to, max = 2, min = 2, flag = "he", skill_name = skel.name,
      prompt = "#godhanxin__wangchuan-card::"..to.id})
    end
    room:throwCard(cards, skel.name, to, player)
    data.additionalDamage = (data.additionalDamage or 0) - 1
  end,
})



return skel
