local skel = fk.CreateSkill {
  name = "steam__shengchaosong",
  tags = {Skill.Compulsory},
  dynamic_desc = function (self, player, lang)
    local mark = player:getMark("steam__shengchaosong_remove")
    if mark < 1 then return self.name end
    if mark > 4 then return "steam__shengchaosong_empty" end
    local max = 5 - mark
    local arg = ""
    for i = 1, max do
      arg = arg.. Fk:translate("HallownestOde"..i, lang)
      if i < max then
        arg = arg.. "、"
      end
    end
    return "steam__shengchaosong_dyn:"..arg..":"..tostring(mark+1)
  end,
}

Fk:loadTranslationTable{
  ["steam__shengchaosong"] = "圣巢颂",
  [":steam__shengchaosong"] = "锁定技，你的①额定摸牌数、②手牌上限、③攻击范围、④出【杀】次数、⑤体力上限+1。结束阶段，若末项不为全场唯一最大，你摸两张牌并受到1点伤害。",
  [":steam__shengchaosong_dyn"] = "锁定技，你的{1}+{2}。结束阶段，若末项不为全场唯一最大，你摸两张牌并受到1点伤害。",
  -- 删完5项后，稳定触发后半段
  [":steam__shengchaosong_empty"] = "锁定技，结束阶段，你摸两张牌并受到1点伤害。",

  ["HallownestOde1"] = "①额定摸牌数",
  ["HallownestOde2"] = "②手牌上限",
  ["HallownestOde3"] = "③攻击范围",
  ["HallownestOde4"] = "④出【杀】次数",
  ["HallownestOde5"] = "⑤体力上限",
}

skel:addLoseEffect(function (self, player, is_start)
  player.room:setPlayerMark(player, "steam__shengchaosong_remove", 0)
end)


skel:addEffect(fk.EventPhaseStart, {
  anim_type = "negative",
  can_trigger = function (self, event, target, player, data)
    if target == player and player:hasSkill(skel.name) and player.phase == Player.Finish then
      local mark = player:getMark("steam__shengchaosong_remove")
      if mark > 4 then return true end
      local addition = mark + 1
      local slash = Fk:cloneCard("slash")
      ---@param p Player
      local getValue = function (p)
        if mark == 0 then return p.maxHp end
        if mark == 1 then return slash.skill:getMaxUseTime(p, Player.HistoryPhase, slash) or 1 end
        if mark == 2 then return p:getAttackRange() end
        if mark == 3 then return p:getMaxCards() end
        if mark == 4 then return p == player and (2 + addition) or 2 end -- 额定摸牌数不是状态技，没法获得
        return 2
      end
      return table.find(player.room.alive_players, function (p)
        return p ~= player and getValue(p) >= getValue(player)
      end)
    end
  end,
  on_use = function (self, event, target, player, data)
    player:drawCards(2, skel.name)
    if not player.dead then
      player.room:damage { from = player, to = target, damage = 1, skillName = skel.name }
    end
  end,
})

skel:addEffect(fk.DrawNCards, {
  anim_type = "drawcard",
  can_trigger = function (self, event, target, player, data)
    if target == player and player:hasSkill(skel.name) then
      return player:getMark("steam__shengchaosong_remove") < 5
    end
  end,
  on_use = function (self, event, target, player, data)
    data.n = data.n + (player:getMark("steam__shengchaosong_remove") + 1)
  end,
})

skel:addEffect(fk.EventAcquireSkill, {
  anim_type = "defensive",
  can_trigger = function (self, event, target, player, data)
    return target == player and data.skill.name == skel.name
  end,
  on_use = function (self, event, target, player, data)
    player.room:changeMaxHp(player, 1)
  end,
})

skel:addEffect("maxcards", {
  correct_func = function(self, player)
    local mark = player:getMark("steam__shengchaosong_remove")
    if player:hasSkill(skel.name) and mark < 4 then
      return mark + 1
    end
  end,
})

skel:addEffect("atkrange", {
  correct_func = function (self, player)
    local mark = player:getMark("steam__shengchaosong_remove")
    if player:hasSkill(skel.name) and mark < 3 then
      return mark + 1
    end
  end,
})

skel:addEffect("targetmod", {
  residue_func = function(self, player, skill)
    if skill.trueName == "slash_skill" then
      local mark = player:getMark("steam__shengchaosong_remove")
      if player:hasSkill(skel.name) and mark < 2 then
        return mark + 1
      end
    end
  end,
})

return skel
