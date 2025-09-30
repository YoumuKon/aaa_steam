local skel = fk.CreateSkill {
  name = "steam__panfu",
  tags = {Skill.Lord, Skill.Compulsory},
}

Fk:loadTranslationTable{
  ["steam__panfu"] = "叛附",
  [":steam__panfu"] = "主公技，锁定技，与你势力相同的角色的回合内，“诈立”中的“你可以弃置X张牌”视为“你可以弃置其X张牌”。若如此做，你须变更势力。",
  ["#steam__panfu-choice"] = "叛附：你须变更势力",

  ["$steam__panfu1"] = "黄巢只一匹夫，弃贼扶唐，实为良久之计。",
  ["$steam__panfu2"] = "李姓失天下，天运循环使之然也！",
}

skel:addEffect(fk.AfterSkillEffect, {
  anim_type = "control",
  can_trigger = function (self, event, target, player, data)
    local current = player.room:getCurrent()
    return target == player and player:hasSkill(skel.name) and
    data.skill and data.skill.name == "steam__zhali" and not data.skill.is_delay_effect and
    current and current.kingdom == player.kingdom
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local kingdoms = {"wei", "shu", "wu", "jin"}
    for _, p in ipairs(room.players) do
      table.insertIfNeed(kingdoms, p.kingdom)
    end
    local choices = table.simpleClone(kingdoms)
    table.removeOne(choices, player.kingdom)
    local choice = room:askToChoice(player, { choices = choices, skill_name = self.name, prompt = "#steam__panfu-choice", all_choices = kingdoms})
    room:changeKingdom(player, choice, true)
  end,
})

return skel
