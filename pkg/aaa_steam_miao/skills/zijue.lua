local skel = fk.CreateSkill {
  name = "steam__zijue",
}

Fk:loadTranslationTable{
  ["steam__zijue"] = "自决",
  [":steam__zijue"] = "判定区有牌的角色的准备阶段，其可以弃一张牌并选择一项：1.受到1点伤害，获得判定区一张牌并展示；2.令你获得此牌，跳过判定阶段。",

  ["#steam__zijue-cost"] = "自决：你可以弃置一张牌，选择1.受到伤害并获得判定区一张牌；2.交给 %src 跳过判定",
  ["steam__zijue_damage"] = "受到1点伤害，获得判定区一张牌",
  ["steam__zijue_give"] = "令%src获得%arg，跳过判定阶段",
  ["#steam__zijue-prey"] = "选择你判定区1张牌，获得之",

  ["$steam__zijue1"] = "",
  ["$steam__zijue2"] = "",
}

skel:addEffect(fk.EventPhaseStart, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(skel.name) then
      return target.phase == Player.Start and not target.dead and #target:getCardIds("j") > 0 and not target:isNude()
    end
  end,
  on_cost = function (self, event, target, player, data)
    local cards = player.room:askToDiscard(target, {
      min_num = 1, max_num = 1, skill_name = skel.name, include_equip = true, skip = true,
      prompt = "#steam__zijue-cost:"..player.id
    })
    if #cards > 0 then
      event:setCostData(self, {tos = {target}, cards = cards })
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cid = event:getCostData(self).cards[1]
    room:throwCard(cid, skel.name, target, target)
    if target.dead then return end
    local all_choices = {"steam__zijue_damage", "steam__zijue_give:"..player.id.."::"..Fk:getCardById(cid):toLogString()}
    local choices = table.simpleClone(all_choices)
    if player.dead or room:getCardArea(cid) ~= Card.DiscardPile then table.remove(choices, 2) end
    local choice = room:askToChoice(target, { choices = choices, skill_name = skel.name, all_choices = all_choices})
    if choice == "steam__zijue_damage" then
      room:doIndicate(player, {target})
      room:damage { from = player, to = target, damage = 1, skillName = skel.name }
      if not target.dead and #target:getCardIds("j") > 0 then
        local cards = target:getCardIds("j")
        if #cards > 1 then
          cards = {room:askToChooseCard(target, { target = target, flag=  "j", skill_name = skel.name, prompt = "#steam__zijue-prey"})}
        end
        room:obtainCard(target, cards, true, fk.ReasonPrey, target, skel.name)
        target:showCards(cards)
      end
    else
      room:doIndicate(target, {player})
      room:obtainCard(player, cid, true, fk.ReasonPrey, target, skel.name)
      target:skip(Player.Judge)
    end
  end,
})



return skel
