local linyu = fk.CreateSkill {
  name = "steam__linyu",
}

Fk:loadTranslationTable{
  ["steam__linyu"] = "霖雨",
  [":steam__linyu"] = "每回合限一次，一张牌指定多个目标后，你可以摸至多X张牌并交给等量名目标角色各一张牌。(X为手牌数不大于体力值的目标数)",

  ["#steam__linyu-choose"] = "霖雨：是否摸X张牌，然后交给等量名角色各一张牌？(X为手牌数不大于体力值的目标数)",
  ["#steam__linyu-give"] = "霖雨：请将 %arg 张牌交给等量名角色各一张！",

  ["$steam__linyu1"] = "唉，原本不该我出手的。",
  ["$steam__linyu2"] = "把你种在土里，你重新长吧！",
}

linyu:addEffect(fk.TargetSpecified, {
  anim_type = "support",
  can_trigger = function (self, event, target, player, data)
    return player:hasSkill(linyu.name) and data.firstTarget and #data.use.tos > 1 and player:usedSkillTimes(linyu.name, Player.HistoryTurn) == 0
    and table.find(data.use.tos, function (p) return not p.dead and p:getHandcardNum() <= p.hp end)
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local targets = table.filter(data.use.tos, function (p) return not p.dead and p:getHandcardNum() <= p.hp end)
    local n = room:askToNumber(player, {
      skill_name = linyu.name,
      prompt = "#steam__linyu-choose",
      min = 1,
      max = #targets,
      cancelable = true,
    })
    if n ~= nil then
      event:setCostData(self, {choice = n})
      return true
    end
  end,
  on_use = function (self, event, target, player, data)
    local n = event:getCostData(self).choice
    player:drawCards(n, linyu.name)
    if player.dead then return end
    local targets = table.filter(data.use.tos, function (p) return not p.dead end)
    local x = math.min(n, #targets)
    local y = math.min(#player:getCardIds("he"), x)
    if y == 0 then return end
    player.room:askToYiji(player, {
      min_num = y,
      max_num = y,
      skill_name = linyu.name,
      targets = targets,
      cards = player:getCardIds("he"),
      prompt = "#steam__linyu-give:::"..y,
      single_max = 1,
    })
  end,
})

return linyu
