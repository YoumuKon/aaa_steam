local skel = fk.CreateSkill {
  name = "godhanxin__xunchou",
}

Fk:loadTranslationTable{
  ["godhanxin__xunchou"] = "寻仇",
  [":godhanxin__xunchou"] = "你使用【杀】指定目标后，可以令其本回合不能使用牌。",

  ["#godhanxin__xunchou-ask"] = "寻仇:以令 %src 本回合不能使用牌！",
  ["@@godhanxin__xunchou-turn"] = "寻仇:禁使用",
  ["$godhanxin__xunchou"] = "天地无情恨多少，夜里孤身泣不长，冤魂不愿为天意，长枪出，君王泣，第十枪，寻仇！",
}

skel:addEffect(fk.TargetSpecified, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(skel.name) and data.card.trueName == "slash"
  end,
  on_cost = function (self, event, target, player, data)
    if player.room:askToSkillInvoke(player, {skill_name = skel.name, prompt = "#godhanxin__xunchou-ask:" .. data.to.id }) then
      event:setCostData(self, {tos = {data.to}})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    player.room:setPlayerMark(data.to, "@@godhanxin__xunchou-turn", 1)
  end,
})

skel:addEffect("prohibit", {
  prohibit_use = function(self, player, card)
    return player:getMark("@@godhanxin__xunchou-turn") ~= 0 and card
  end,
})

return skel
