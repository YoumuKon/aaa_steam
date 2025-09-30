local skel = fk.CreateSkill {
  name = "steam__tushe",
}

Fk:loadTranslationTable{
  ["steam__tushe"] = "图射",
  [":steam__tushe"] = "当你使用指定首个目标后，若你没有基本牌，则你可以摸X张牌（X为此牌指定的目标数）。",

  ["$steam__tushe1"] = "据险以图进，备策而施为！",
  ["$steam__tushe2"] = "夫战者，可时以奇险之策而图常谋！",
}

skel:addEffect(fk.TargetSpecified, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(skel.name) and data.firstTarget and
      not table.find(player:getCardIds(Player.Hand), function(id) return Fk:getCardById(id).type == Card.TypeBasic end) and
       data.use and #data.use.tos > 0
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(#data.use.tos, self.name)
  end,
})

return skel
