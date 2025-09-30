local skel = fk.CreateSkill {
  name = "steam__emorenshen",
  tags = {Skill.Compulsory},
}

Fk:loadTranslationTable{
  ["steam__emorenshen"] = "恶魔妊娠",
  [":steam__emorenshen"] = "锁定技，每轮开始时，或你受到1点伤害后，你摸一张牌并获得一个〖重身〗。",
}

local on_use = function(self, event, target, player, data)
    local room = player.room
    player:drawCards(1, skel.name)
    if player.dead then return end
    local chongshenSkills = {"steam__chongshen"}
    for i = 1, 50 do
      table.insert(chongshenSkills, "steam"..i.."__chongshen")
    end
    for _, skill in ipairs(chongshenSkills) do
      if Fk.skills[skill] ~= nil and not player:hasSkill(skill, true) then
        room:handleAddLoseSkills(player, skill)
        break
      end
    end
  end

skel:addEffect(fk.Damaged, {
  anim_type = "masochism",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(skel.name) and target == player
  end,
  trigger_times = function (self, event, target, player, data)
    return data.damage
  end,
  on_use = on_use,
})

skel:addEffect(fk.RoundStart, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(skel.name)
  end,
  on_use = on_use,
})

return skel
