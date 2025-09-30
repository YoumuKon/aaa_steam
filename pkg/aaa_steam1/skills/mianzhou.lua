local skel = fk.CreateSkill {
  name = "steam__mianzhou",
  tags = {Skill.Compulsory},
}

Fk:loadTranslationTable{
  ["steam__mianzhou"] = "免胄",
  [":steam__mianzhou"] = "锁定技，若你的装备区没有牌，当你受到致命伤害时，改为减少1点体力上限，然后令一名其他角色本回合不能使用一种类型的牌（每回合首次发动不可选择基本牌）。",

  ["@steam__mianzhou-turn"] = "免胄",
  ["#steam__mianzhou-choose"] = "免胄：令一名其他角色本回合不能使用一种类型的牌",
  ["#steam__mianzhou-choice"] = "免胄：选择令 %src 本回合不能使用一种类型的牌",
}

skel:addEffect(fk.DamageInflicted, {
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(skel.name) and target == player and #player:getCardIds("e") == 0 then
      return data.damage >= (player.hp + player.shield)
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:changeMaxHp(player, -1)
    data:preventDamage()
    if player.dead then return end
    local targets = room:getOtherPlayers(player, false)
    if #targets > 0 then
      local tos = room:askToChoosePlayers(player, {
        min_num = 1, max_num = 1, skill_name = skel.name, targets = targets, cancelable = false,
        prompt = "#steam__mianzhou-choose",
      })
      if #tos > 0 then
        local to = tos[1]
        local choices = {"basic", "trick", "equip"}
        if player:usedSkillTimes(skel.name) < 2 then table.remove(choices, 1) end
        local cardType = room:askToChoice(player, {choices = choices, skill_name = skel.name,
        prompt = "#steam__mianzhou-choice:"..to.id}) .. "_char"
        room:addTableMarkIfNeed(to, "@steam__mianzhou-turn", cardType)
      end
    end
  end,
})

skel:addEffect("prohibit", {
  prohibit_use = function(self, player, card)
    return card and table.contains(player:getTableMark("@steam__mianzhou-turn"), card:getTypeString() .. "_char")
  end,
})

return skel
