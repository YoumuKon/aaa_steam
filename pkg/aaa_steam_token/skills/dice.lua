local skel = fk.CreateSkill {
  name = "dice_skill",
}

skel:addEffect("cardskill", {
  mod_target_filter = Util.FalseFunc,
  can_use = Util.FalseFunc,
})

return skel
