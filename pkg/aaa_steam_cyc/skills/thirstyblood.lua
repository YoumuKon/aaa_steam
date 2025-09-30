local skel = fk.CreateSkill {
  name = "steam__thirstyblood",
  tags = {Skill.Compulsory},
}

Fk:loadTranslationTable{
  ["steam__thirstyblood"] = "血嗜",
  [":steam__thirstyblood"] = "锁定技，你造成或受到伤害后，重铸任意张黑色牌。",

  ["#steam__thirstyblood-recast"] = "血嗜：请重铸任意张黑色牌",
}

local can_trigger = function (self, event, target, player, data)
  return target == player and player:hasSkill(skel.name) and not player:isNude()
end

local on_use = function (self, event, target, player, data)
  local room = player.room
  local cards = room:askToCards(player, {
    min_num = 1, max_num = 9999, skill_name = skel.name, prompt = "#steam__thirstyblood-recast",
    include_equip = true, cancelable = true, pattern = ".|.|spade,club",
  })
  if #cards > 0 then
    room:recastCard(cards, player, skel.name)
  end
end

skel:addEffect(fk.Damage, {
  anim_type = "masochism",
  can_trigger = can_trigger,
  on_use = on_use,
})

skel:addEffect(fk.Damaged, {
  anim_type = "masochism",
  can_trigger = can_trigger,
  on_use = on_use,
})


return skel
