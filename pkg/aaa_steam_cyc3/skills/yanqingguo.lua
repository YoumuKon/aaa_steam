local skel = fk.CreateSkill {
  name = "steam__yanqingguo",
  tags = {Skill.Compulsory},
}

Fk:loadTranslationTable{
  ["steam__yanqingguo"] = "魇倾国",
  [":steam__yanqingguo"] = "锁定技，你受到伤害后，删去〖圣巢颂〗的末项，并令其余项的数值+1。",
}

skel:addEffect(fk.Damaged, {
  anim_type = "negative",
  can_trigger = function (self, event, target, player, data)
    if target == player and player:hasSkill(skel.name) then
      return player:getMark("steam__shengchaosong_remove") < 5 and player:hasSkill("steam__shengchaosong", true)
    end
  end,
  on_use = function (self, event, target, player, data)
    player.room:addPlayerMark(player, "steam__shengchaosong_remove", 1)
    if player:getMark("steam__shengchaosong_remove") == 1 then
      player.room:changeMaxHp(player, -1)
    end
  end,
})

return skel
