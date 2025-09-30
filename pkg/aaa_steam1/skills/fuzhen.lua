local skel = fk.CreateSkill {
  name = "steam__fuzhen",
}

Fk:loadTranslationTable{
  ["steam__fuzhen"] = "赴阵",
  [":steam__fuzhen"] = "其他角色的准备阶段，若你在其攻击范围内，你可以令其本回合使用伤害类牌只能指定你为目标，然后你摸已损失体力值张牌。",

  ["#steam__fuzhen-invoke"] = "赴阵：你可以令 %src 本回合伤害牌只能指定你为目标，然后你摸 %arg 张牌",
  ["@@steam__fuzhen-turn"] = "被赴阵",
}

skel:addEffect(fk.EventPhaseStart, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(skel.name) and target ~= player and not target.dead then
      return target.phase == Player.Start and target:inMyAttackRange(player)
    end
  end,
  on_cost = function (self, event, target, player, data)
    if player.room:askToSkillInvoke(player, { skill_name = skel.name,
     prompt = "#steam__fuzhen-invoke:"..target.id.."::"..player:getLostHp()}) then
      event:setCostData(self, {tos = {target}})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:addTableMark(target, "@@steam__fuzhen-turn", player.id)
    player:drawCards(player:getLostHp(), skel.name)
  end,
})

skel:addEffect("prohibit", {
  is_prohibited = function (self, player, to, card)
    if not player then return false end
    local mark = player:getTableMark("@@steam__fuzhen-turn")
    if #mark == 0 then return false end
    if card and card.is_damage_card then
      return #mark > 1 or not table.contains(mark, to.id)
    end
  end,
})

return skel
