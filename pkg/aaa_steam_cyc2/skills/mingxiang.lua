local skel = fk.CreateSkill {
  name = "steam__mingxiang",
  tags = {Skill.Limited},
}

Fk:loadTranslationTable{
  ["steam__mingxiang"] = "冥想",
  [":steam__mingxiang"] = "限定技，你受到伤害后，可以施法（X=1~3）：你摸X张牌并回复1点体力。",

  ["#steam__mingxiang-invoke"] = "冥想：你可以令（X=1~3）个回合后，摸X张牌并恢复1点体力",
  ["steam__mingxiang_active"] = "冥想",
  ["@steam__mingxiang"] = "冥想",
  ["#steam__mingxiang_delay"] = "冥想",

  ["$steam__mingxiang1"] = "意志与肉身",
  ["$steam__mingxiang2"] = "啊，嗯——",
}

skel:addEffect(fk.Damaged, {
  times = function (_, player) return 1 - player:usedSkillTimes(skel.name, Player.HistoryGame) end,
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(skel.name) or player:usedSkillTimes(skel.name, Player.HistoryGame) > 0 then return false end
    return target == player
  end,
  on_cost = function (self, event, target, player, data)
    local _, dat = player.room:askToUseActiveSkill(player, { skill_name = "steam__mingxiang_active", prompt = "#steam__mingxiang-invoke" })
    if dat then
      event:setCostData(self, {num = dat.interaction})
      return true
    end
  end,
  on_use = function (self, event, target, player, data)
    local num = event:getCostData(self).num
    player.room:addTableMark(player, "@steam__mingxiang", num)
    player.room:addTableMark(player, "steam__mingxiang", num)
  end,
})

skel:addEffect(fk.TurnStart, {
  is_delay_effect = true,
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return player:getMark("@steam__mingxiang") ~= 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    local room = player.room
    -- 为了存储多个冥想，会麻烦点
    local mark = player:getMark("@steam__mingxiang")
    local record = player:getMark("steam__mingxiang")
    local drawList = {}
    for i = #mark, 1, -1 do
      mark[i] = mark[i] - 1
      if mark[i] <= 0 then
        table.remove(mark, i)
        table.insert(drawList, table.remove(record, i))
      end
    end
    room:setPlayerMark(player, "@steam__mingxiang", #mark > 0 and mark or 0)
    room:setPlayerMark(player, "steam__mingxiang", #record > 0 and record or 0)
    if #drawList == 0 then return end
    for _, num in ipairs(drawList) do
      if player.dead then break end
      player:drawCards(num, "steam__mingxiang")
      if player.dead then break end
      room:recover { num = 1, skillName = skel.name, who = player, recoverBy = player }
    end
  end,
})

local skel2 = fk.CreateSkill {
  name = "steam__mingxiang_active",
}

skel2:addEffect("active", {
  card_num = 0,
  target_num = 0,
  card_filter = Util.FalseFunc,
  interaction = function()
    return UI.Spin { from = 1, to = 3 }
  end,
})

return {skel, skel2}
