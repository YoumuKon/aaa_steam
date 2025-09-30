local skel = fk.CreateSkill {
  name = "steam__xxx",
}

Fk:loadTranslationTable{
  [""] = "",
  [""] = "",
  [""] = "",
}

skel:addEffect(fk.Damage, {
  anim_type = "drawcard",
})



return skel
