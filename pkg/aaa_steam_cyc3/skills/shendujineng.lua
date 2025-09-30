local skel = fk.CreateSkill {
  name = "steam__shendujineng",
}

Fk:loadTranslationTable{
  ["steam__shendujineng"] = "深度汲能",
  [":steam__shendujineng"] = "当任意角色受到属性伤害后，你可以消耗1蓄力点，摸伤害值张牌。",

  ["#steam__shendujineng-draw"] = "深度汲能：消耗1蓄力点，摸 %arg 张牌",
}

skel:addEffect(fk.Damaged, {
  anim_type = "drawcard",
  can_trigger = function (self, event, target, player, data)
    return player:hasSkill(skel.name) and data.damageType ~= fk.NormalDamage and player:getMark("steam__crystal_skin") > 0
  end,
  on_cost = function (self, event, target, player, data)
    return player.room:askToSkillInvoke(player, { skill_name = self.name, prompt = "#steam__shendujineng-draw:::"..data.damage})
  end,
  on_use = function (self, event, target, player, data)
    player.room:removePlayerMark(player, "steam__crystal_skin", 1)
    player:drawCards(data.damage, self.name)
  end,
})

return skel
