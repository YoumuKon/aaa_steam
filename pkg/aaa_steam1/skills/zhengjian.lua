local skel = fk.CreateSkill {
  name = "steam__zhengjian",
}

Fk:loadTranslationTable{
  ["steam__zhengjian"] = "正谏",
  [":steam__zhengjian"] = "其他角色的准备阶段，你可以弃置其判定区或装备区一张牌，并与其拼点：若你没赢，其将你所有手牌当【万箭齐发】使用；若你赢，其本回合不能使用伤害类卡牌。",

  ["#steam__zhengjian-invoke"] = "正谏：你可弃置%src场上一张牌并与其拼点，若你没赢，其将你手牌当【万箭】使用，若你赢，其本回合不能用伤害牌",
  ["@@steam__zhengjian-turn"] = "被正谏",

  ["$steam__zhengjian1"] = "这是我的，最后一谏！",
  ["$steam__zhengjian2"] = "秉忠而谏，何惧一死！",
  ["$steam__zhengjian3"] = "时势如此，我只能从之",
}

skel:addEffect(fk.EventPhaseStart, {
  audio_index = {1,2},
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(skel.name) and target ~= player and target.phase == Player.Start and #target:getCardIds("ej") > 0 then
      return player:canPindian(target)
    end
  end,
  on_cost = function (self, event, target, player, data)
    if player.room:askToSkillInvoke(player, { skill_name = skel.name, prompt = "#steam__zhengjian-invoke:"..target.id}) then
      event:setCostData(self, {tos = {target} })
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cid = room:askToChooseCard(player, { target = target, flag = "ej", skill_name = skel.name})
    room:throwCard(cid, skel.name, target, player)
    if player.dead or target.dead or not player:canPindian(target) then return end
    local pindian = player:pindian({target}, skel.name)
    if pindian.results[target].winner == player then
      room:setPlayerMark(target, "@@steam__zhengjian-turn", 1)
    elseif not target.dead then
      player:broadcastSkillInvoke(skel.name, 3)
      local cards = player:getCardIds("h")
      if #cards == 0 then return end
      local card = Fk:cloneCard("archery_attack")
      card:addSubcards(cards)
      card.skillName = skel.name
      if target:prohibitUse(card) then return end
      local targets = table.filter(room:getOtherPlayers(target), function (p)
        return not target:isProhibited(p, card)
      end)
      if #targets == 0 then return end
      room:useCard{from = target, tos = targets, card = card}
    end
  end,
})

skel:addEffect("prohibit", {
  prohibit_use = function (self, player, card)
    return player and player:getMark("@@steam__zhengjian-turn") ~= 0 and card and card.is_damage_card
  end,
})

return skel
