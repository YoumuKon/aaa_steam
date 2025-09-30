local skel = fk.CreateSkill {
  name = "steam__xueming",
}

Fk:loadTranslationTable{
  ["steam__xueming"] = "血鸣",
  [":steam__xueming"] = "出牌阶段，或任意角色濒死时，你可以失去一个技能，摸一张<font color='red'>♥</font>或♠牌。",

  ["#steam__xueming-ask"] = "血鸣：你可以失去一个技能，摸一张<font color='red'>♥</font>或♠牌",
  ["#steam__xueming-lose"] = "血鸣：请失去一个技能",
  ["#steam__xueming-suit"] = "血鸣：选择你要获得的牌的花色！",
}

---@param player  ServerPlayer
local function onUse(player)
  local room = player.room
  local skills = player:getSkillNameList()
  if #skills == 0 then return end
  local tolose = room:askToChoice(player, { choices = skills, skill_name = skel.name, prompt = "#steam__xueming-lose", detailed = true})
  room:handleAddLoseSkills(player, "-"..tolose)
  if player.dead then return end
  local suit = room:askToChoice(player, { choices = {"log_heart", "log_spade"}, skill_name = skel.name, prompt = "#steam__xueming-suit"})
  suit = suit:sub(5, -1)
  local ids = room:getCardsFromPileByRule(".|.|"..suit)
  if #ids > 0 then
    room:obtainCard(player, ids, true, fk.ReasonJustMove, player, skel.name)
  end
end

skel:addEffect("active", {
  anim_type = "drawcard",
  prompt = "#steam__xueming-ask",
  card_num = 0,
  target_num = 0,
  card_filter = Util.FalseFunc,
  can_use = function(self, player)
    return #player:getSkillNameList() > 0
  end,
  on_use = function(self, room, effect)
    onUse(effect.from)
  end,
})

skel:addEffect(fk.EnterDying, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(skel.name) and #player:getSkillNameList() > 0
  end,
  on_cost = function (self, event, target, player, data)
    return player.room:askToSkillInvoke(player, { skill_name = skel.name, prompt = "#steam__xueming-ask"})
  end,
  on_use = function (self, event, target, player, data)
    onUse(player)
  end,
})

return skel
