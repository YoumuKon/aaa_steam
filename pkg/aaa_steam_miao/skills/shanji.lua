local skel = fk.CreateSkill {
  name = "steam__shanji",
}

Fk:loadTranslationTable{
  ["steam__shanji"] = "闪击",
  [":steam__shanji"] = "准备阶段，你可以对一名角色造成1点伤害；若与你上次选择的角色相同，此伤害-1。",

  ["#steam__shanji-choose"] = "闪击：你可以对一名角色造成1点伤害",
  ["#steam__shanji-again"] = "闪击：你可以对一名角色造成1点伤害，若选择 %src，则伤害-1。",

  ["$steam__shanji1"] = "Offensive ist die beste Verteidigung.（进攻是最好的防守。）",
}

skel:addEffect(fk.EventPhaseStart, {
  anim_type = "offensive",
  can_trigger = function (self, event, target, player, data)
    return player:hasSkill(skel.name) and target == player and player.phase == Player.Start
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local prompt = "#steam__shanji-choose"
    local mark = player:getMark("steam__shanji_last")
    if mark ~= 0 then
      prompt = "#steam__shanji-again:"..mark
    end
    local tos = room:askToChoosePlayers(player, {
      min_num = 1, max_num = 1, targets = room.alive_players, skill_name = skel.name, prompt = prompt,
      cancelable = data["steam__juantu"] == nil
    })
    if #tos > 0 then
      event:setCostData(self, {tos = tos})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = event:getCostData(self).tos[1]
    local last = player:getMark("steam__shanji_last")
    room:setPlayerMark(player, "steam__shanji_last", to.id)
    local num = 1
    if to.id == last then num = 0 end
    room:damage { from = player, to = to, damage = num, skillName = skel.name }
  end,
})

return skel
