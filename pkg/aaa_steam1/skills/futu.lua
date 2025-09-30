local skel = fk.CreateSkill {
  name = "steam__futu",
  tags = {Skill.Compulsory},
}

Fk:loadTranslationTable{
  ["steam__futu"] = "浮屠",
  [":steam__futu"] = "锁定技，你计算与其他角色的距离-X；其他角色计算与你的距离+X（X为已横置的角色数）。",
}

skel:addEffect("distance", {
  correct_func = function(self, from, to)
    local x = #table.filter(Fk:currentRoom().alive_players, function (p) return p.chained end)
    local ret = 0
    if from:hasSkill(skel.name) then
      ret = ret - x
    end
    if to:hasSkill(skel.name) then
      ret = ret + x
    end
    return ret
  end,
})



return skel
