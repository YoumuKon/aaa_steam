local skel = fk.CreateSkill {
  name = "steam__kuangyi",
  tags = {Skill.Compulsory},
}

Fk:loadTranslationTable{
  ["steam__kuangyi"] = "匡翊",
  [":steam__kuangyi"] = "锁定技，当一名角色受到伤害后，你视为使用一张【增兵减灶】，若受伤角色和目标角色均为你或均不为你，本轮“匡翊”失效。",

  ["#steam__kuangyi-choose"] = "匡翊：%src 受到伤害，你须选择【增兵减灶】的目标并使用之",

  ["$steam__kuangyi1"] = "家国兴衰，系于一肩之上，朝纲待重振之时。",
  ["$steam__kuangyi2"] = "吾辈向汉，当矢志不渝，不可坐视神州陆沉。",
}

skel:addEffect(fk.Damaged, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(skel.name) and target
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local card = Fk:cloneCard("reinforcement")
    card.skillName = self.name
    if player:prohibitUse(card) then return end
    local max_target_num = card.skill:getMaxTargetNum(player, card)
    local targets = table.filter(room.alive_players, function (p) return not player:isProhibited(p, card) end)
    if #targets == 0 or max_target_num == 0 then return end
    local tos = room:askToChoosePlayers(player, {
      targets = targets, min_num = 1, max_num = max_target_num,
      prompt = "#steam__kuangyi-choose:"..target.id, skill_name = self.name, cancelable = false
    })
    room:sortByAction(tos)
    room:useCard{
      from = player,
      tos = tos,
      card = card,
    }
    if (target == player) == (table.contains(tos, player)) then
      room:invalidateSkill(player, self.name, "-round")
    end
  end,
})

return skel
