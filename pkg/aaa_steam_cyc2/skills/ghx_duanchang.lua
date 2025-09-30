local skel = fk.CreateSkill {
  name = "godhanxin__duanchang",
}

Fk:loadTranslationTable{
  ["godhanxin__duanchang"] = "断肠",
  [":godhanxin__duanchang"] = "你使用【杀】指定目标后，可以移除目标角色等同于其技能数张牌至其下回合开始。",

  ["#godhanxin__duanchang-card"] = "断肠：将 %dest 的 %arg张牌移出游戏直至其下回合开始",
  ["#godhanxin__duanchang-ask"] = "断肠：你可以将 %dest 的 %arg张牌移出游戏直至其下回合开始！",
  ["$steam__duanchang"] = "断肠",

  ["$godhanxin__duanchang"] = "第二枪，相思一夜情多少，地角天涯未是长，断肠！",
}

---@param player Player
local function getTrueSkills(player)
  local skills = {}
  for _, s in ipairs(player.player_skills) do
    if s:isPlayerSkill(player) and not (s.name == "m_feiyang" or s.name == "m_bahu") then
      table.insertIfNeed(skills, s.name)
    end
  end
  return skills
end

skel:addEffect(fk.TargetSpecified, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(skel.name) and data.card.trueName == "slash" and
    not data.to.dead and not data.to:isNude()
    --#data.to:getCardIds("he") >= #getTrueSkills(data.to)
  end,
  on_cost = function (self, event, target, player, data)
    if player.room:askToSkillInvoke(player, {skill_name = skel.name,
      prompt = "#godhanxin__duanchang-ask::" .. data.to.id .. ":" .. #getTrueSkills(data.to)
     }) then
      event:setCostData(self, {tos = {data.to} })
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = data.to
    local x = #getTrueSkills(to)
    local cards = to:getCardIds("he")
    if #cards > x then
      cards = room:askToChooseCards(player, {
        target = to, max = x, min = x, flag = "he", skill_name = skel.name, prompt =  "#godhanxin__duanchang-card::"..to.id..":"..x
      })
    end
    if #cards > 0 then
      to:addToPile("$steam__duanchang", cards, false, skel.name)
    end
  end,
})

skel:addEffect(fk.TurnStart, {
  is_delay_effect = true,
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return #target:getPile("$steam__duanchang") > 0 and target == player
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    player.room:moveCardTo(target:getPile("$steam__duanchang"), Player.Hand, target, fk.ReasonPrey, skel.name)
  end,
})

return skel
