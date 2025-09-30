local skel = fk.CreateSkill {
  name = "steam__lvzheng",
  tags = {Skill.Lord},
}

Fk:loadTranslationTable{
  ["steam__lvzheng"] = "屡征",
  [":steam__lvzheng"] = "主公技，准备阶段/结束阶段，你可弃置你和一名其他西势力角色判定区/其他非西势力角色装备区的各一张牌。",

  ["#steam__lvzheng-judge"] = "屡征：你可弃置你和一名其他西势力角色判定区各一张牌",
  ["#steam__lvzheng-equip"] = "屡征：你可弃置你和一名其他非西势力角色装备区各一张牌",
}

skel:addEffect(fk.EventPhaseStart, {
  anim_type = "control",
  can_trigger = function (self, event, target, player, data)
    if player:hasSkill(skel.name) then
      if player.phase == Player.Start and #player:getCardIds("j") > 0 then
        return table.find(player.room.alive_players, function (p)
          return p ~= player and #p:getCardIds("j") > 0 and p.kingdom == "west"
        end)
      elseif player.phase == Player.Finish and #player:getCardIds("e") > 0 then
        return table.find(player.room.alive_players, function (p)
          return p ~= player and #p:getCardIds("e") > 0 and p.kingdom ~= "west"
        end)
      end
    end
  end,
  on_cost = function (self, event, target, player, data)
    local targets = table.filter(player.room:getOtherPlayers(player, false), function (p)
      if player.phase == Player.Start then
        return #p:getCardIds("j") > 0 and p.kingdom == "west"
      else
        return #p:getCardIds("e") > 0 and p.kingdom ~= "west"
      end
    end)
    if #targets == 0 then return false end
    local tos = player.room:askToChoosePlayers(player, {
      min_num = 1, max_num = 1, targets = targets, skill_name = skel.name,
      prompt = player.phase == Player.Start and "#steam__lvzheng-judge" or "#steam__lvzheng-equip",
    })
    if #tos > 0 then
      event:setCostData(self, {tos = tos})
      return true
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local to = event:getCostData(self).tos[1]
    local area = player.phase == Player.Start and "j" or "e"
    for _, p in ipairs({player, to}) do
      if #p:getCardIds(area) > 0 then
        local cid = room:askToChooseCard(player, { target = p, flag = area, skill_name = skel.name})
        room:throwCard(cid, skel.name, p, player)
      end
    end
  end,
})

return skel
