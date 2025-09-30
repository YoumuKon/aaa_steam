local skel = fk.CreateSkill {
  name = "godhanxin__taitou",
}

Fk:loadTranslationTable{
  ["godhanxin__taitou"] = "抬头",
  [":godhanxin__taitou"] = "你使用【杀】时，可以摸等同于之点数张牌，然后弃置手牌至四张。",

  ["$godhanxin__taitou"] = "你说此生不负良人，千里共婵娟，怎奈人去楼空似云烟，白发青丝一瞬间，今世轮回为少年，爱过之后知情浓，佳人走发不留，第十二枪，抬头！",
}

skel:addEffect(fk.CardUsing, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(skel.name) and data.card and data.card.trueName == "slash"
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local x = data.card.number
    if x > 0 then
      player:drawCards(x, skel.name)
      local y = player:getHandcardNum() - 4
      if y > 0 then
        room:askToDiscard(player, { min_num =  y, max_num = y, include_equip = false, skill_name = skel.name, cancelable = false})
      end
    end
  end,
})



return skel
