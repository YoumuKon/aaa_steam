local skel = fk.CreateSkill {
  name = "steam__qingxii",
}

Fk:loadTranslationTable{
  ["steam__qingxii"] = "轻袭",
  [":steam__qingxii"] = "你的手牌数变化后，若比你本技能记录过的手牌数均大或均小，你可以视为使用一张【杀】。你于杀死角色后重置此技能。",

  ["@steam__qingxii"] = "轻袭",
  ["#steam__qingxii-slash"] = "轻袭：你可以视为使用一张【杀】，不选目标则取消发动",

  ["$steam__qingxii1"] = "今天降了我张燕，黑山寨里少不了你一份好处！",
  ["$steam__qingxii2"] = "唉，想我堂堂黑山飞燕，也得当朝廷的狗腿子！",
}

skel:addEffect(fk.AfterCardsMove, {
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    local room = player.room
    if player:hasSkill(skel.name) and not table.contains(player:getTableMark("@steam__qingxii"), player:getHandcardNum()) then
      for _, move in ipairs(data) do
        if move.to == player and move.toArea == Card.PlayerHand then
          if #player:getTableMark("@steam__qingxii") == 2 then
            if player:getHandcardNum() < player:getTableMark("@steam__qingxii")[1] then
              room:removeTableMark(player, "@steam__qingxii", player:getTableMark("@steam__qingxii")[1])
              room:addTableMark(player, "@steam__qingxii", player:getHandcardNum())
                local list = {}
                table.insertIfNeed(list, math.min(player:getTableMark("@steam__qingxii")[1], player:getTableMark("@steam__qingxii")[2]))
                table.insertIfNeed(list, math.max(player:getTableMark("@steam__qingxii")[1], player:getTableMark("@steam__qingxii")[2]))
                room:setPlayerMark(player, "@steam__qingxii", list)
              return true
            elseif player:getHandcardNum() > player:getTableMark("@steam__qingxii")[2] then
            room:removeTableMark(player, "@steam__qingxii", player:getTableMark("@steam__qingxii")[2])
            room:addTableMark(player, "@steam__qingxii", player:getHandcardNum())
                local list = {}
                table.insertIfNeed(list, math.min(player:getTableMark("@steam__qingxii")[1], player:getTableMark("@steam__qingxii")[2]))
                table.insertIfNeed(list, math.max(player:getTableMark("@steam__qingxii")[1], player:getTableMark("@steam__qingxii")[2]))
                room:setPlayerMark(player, "@steam__qingxii", list)
              return true
            end
          elseif #player:getTableMark("@steam__qingxii") <= 1 then
            room:addTableMark(player, "@steam__qingxii", player:getHandcardNum())
            if player:getTableMark("@steam__qingxii")[2] ~= nil then
              local list = {}
              table.insertIfNeed(list, math.min(player:getTableMark("@steam__qingxii")[1], player:getTableMark("@steam__qingxii")[2]))
              table.insertIfNeed(list, math.max(player:getTableMark("@steam__qingxii")[1], player:getTableMark("@steam__qingxii")[2]))
              room:setPlayerMark(player, "@steam__qingxii", list)
            end
            return true
          end
        end
        if move.from == player then
          for _, info in ipairs(move.moveInfo) do
            if info.fromArea == Card.PlayerHand then
              if #player:getTableMark("@steam__qingxii") == 2 then
                if player:getHandcardNum() < player:getTableMark("@steam__qingxii")[1] then
                  room:removeTableMark(player, "@steam__qingxii", player:getTableMark("@steam__qingxii")[1])
                  room:addTableMark(player, "@steam__qingxii", player:getHandcardNum())
                    local list = {}
                    table.insertIfNeed(list, math.min(player:getTableMark("@steam__qingxii")[1], player:getTableMark("@steam__qingxii")[2]))
                    table.insertIfNeed(list, math.max(player:getTableMark("@steam__qingxii")[1], player:getTableMark("@steam__qingxii")[2]))
                    room:setPlayerMark(player, "@steam__qingxii", list)
                  return true
                elseif player:getHandcardNum() > player:getTableMark("@steam__qingxii")[2] then
                room:removeTableMark(player, "@steam__qingxii", player:getTableMark("@steam__qingxii")[2])
                room:addTableMark(player, "@steam__qingxii", player:getHandcardNum())
                    local list = {}
                    table.insertIfNeed(list, math.min(player:getTableMark("@steam__qingxii")[1], player:getTableMark("@steam__qingxii")[2]))
                    table.insertIfNeed(list, math.max(player:getTableMark("@steam__qingxii")[1], player:getTableMark("@steam__qingxii")[2]))
                    room:setPlayerMark(player, "@steam__qingxii", list)
                  return true
                end
              elseif #player:getTableMark("@steam__qingxii") <= 1 then
                room:addTableMark(player, "@steam__qingxii", player:getHandcardNum())
                if player:getTableMark("@steam__qingxii")[2] ~= nil then
                  local list = {}
                  table.insertIfNeed(list, math.min(player:getTableMark("@steam__qingxii")[1], player:getTableMark("@steam__qingxii")[2]))
                  table.insertIfNeed(list, math.max(player:getTableMark("@steam__qingxii")[1], player:getTableMark("@steam__qingxii")[2]))
                  room:setPlayerMark(player, "@steam__qingxii", list)
                end
                return true
              end
            end
          end
        end
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local use = room:askToUseVirtualCard(player, {
      name = "slash",
      skill_name = skel.name,
      prompt = "#steam__qingxii-slash",
      cancelable = true,
      skip = true,
      extra_data = {
        bypass_times = true,
        extraUse = true,
      },
    })
    if use then
      event:setCostData(self, {extra_data = use})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    player.room:useCard(event:getCostData(self).extra_data)
  end,
})

skel:addEffect(fk.Deathed, {
  can_refresh = function (self, event, target, player, data)
    return player:hasSkill(skel.name) and data.killer == player
  end,
  on_refresh = function (self, event, target, player, data)
    player.room:setPlayerMark(player, "@steam__qingxii", 0)
  end,
})

skel:addLoseEffect(function (self, player, is_death)
  player.room:setPlayerMark(player, "@steam__qingxii", 0)
end)

return skel
