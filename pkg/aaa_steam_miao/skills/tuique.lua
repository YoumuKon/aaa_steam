local skel = fk.CreateSkill {
  name = "steam__tuique",
}

Fk:loadTranslationTable{
  ["steam__tuique"] = "退却",
  [":steam__tuique"] = "结束阶段，你可以令一名角色回复1点体力；若与你上次选择的角色不同，回复量+1。",

  ["#steam__tuique-choose"] = "退却：你可以令一名角色回复1点体力",
  ["#steam__tuique-again"] = "退却：你可以令一名角色回复1点体力，若未选择 %src，回复量+1。",

  ["$steam__tuique1"] = "Ein Krieg ist erst dann verloren, wenn man ihn als verloren betrachtet.（唯有承认失败时，战争才会失败。）",
}

skel:addEffect(fk.EventPhaseStart, {
  anim_type = "support",
  can_trigger = function (self, event, target, player, data)
    return player:hasSkill(skel.name) and target == player and player.phase == Player.Finish
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local prompt = "#steam__tuique-choose"
    local mark = player:getMark("steam__tuique_last")
    if mark ~= 0 then
      prompt = "#steam__tuique-again:"..mark
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
    local last = player:getMark("steam__tuique_last")
    room:setPlayerMark(player, "steam__tuique_last", to.id)
    local num = 1
    if last ~= 0 and to.id ~= last then num = 2 end
    room:recover { num = num, skillName = skel.name, who = to, recoverBy = player }
  end,
})


return skel
