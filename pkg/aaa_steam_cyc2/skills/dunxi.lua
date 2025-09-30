local skel = fk.CreateSkill {
  name = "steam__dunxi",
}

Fk:loadTranslationTable{
  ["steam__dunxi"] = "钝袭",
  [":steam__dunxi"] = "有“钝”标记的角色使用基本牌或锦囊牌时，"..
  "若目标数为1且没有处于濒死状态的角色，其移去一个“钝”，然后目标改为随机一名角色。"..
  "若随机的目标与原本目标相同，则其于此牌结算结束后失去1点体力并结束出牌阶段。",

  ["@steam__dunxi"] = "钝",
  ["#steam__dunxi_log"] = "%from 使用 %arg 目标改为 %to",

  ["$steam__dunxi1"] = "看锤！",
  ["$steam__dunxi2"] = "且吃我一锤！",
}
---@param data UseCardData
---@param target ServerPlayer
local canTransferByDunxi = function (data, target)
  local player = data.from
  if player:isProhibited(target, data.card) then return false end
  if data.card.trueName == "slash" then -- 可以杀自己
    return true
  elseif data.card.skill:modTargetFilter(player, target, {}, data.card, {bypass_distances = true}) then
    local sub_tos = data.subTos
    if sub_tos and #sub_tos > 0 and sub_tos[1][1] ~= nil then
      local sub_to = sub_tos[1][1]
      local orig_to = data.tos[1]
      return data.card.skill:targetFilter(player, sub_to, {orig_to}, {}, data.card)
    end
    return true
  end
  return false
end

skel:addEffect(fk.CardUsing, {
  anim_type = "negative",
  can_trigger = function(self, event, target, player, data)
    if player == target and player:getMark("@steam__dunxi") > 0 and
      (data.card.type == Card.TypeBasic or data.card.type == Card.TypeTrick) and #data.tos == 1 then
      return not table.find(player.room.alive_players, function (p)
        return p.dying
      end)
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:removePlayerMark(player, "@steam__dunxi")
    local orig_to = data.tos[1]
    local targets = {}
    for _, p in ipairs(room.alive_players) do
      if canTransferByDunxi(data, p) then
        table.insert(targets, p)
      end
    end
    if #targets == 0 then
      data:removeAllTargets()
      return
    end
    local random_target = table.random(targets)
    room:sendLog{type = "#steam__dunxi_log", from = data.from.id, to = {random_target.id}, arg = data.card:toLogString(), toast = true}

    if random_target == orig_to then
      data.extra_data = data.extra_data or {}
      data.extra_data.steam__dunxi_user = player.id
    else
      data.tos = { random_target }
    end
  end,
})

skel:addEffect(fk.CardUseFinished, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return not player.dead and data.extra_data and data.extra_data.steam__dunxi_user == player.id
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    player.room:loseHp(player, 1, self.name)
    if player.phase == Player.Play then
      player:endPlayPhase()
    end
  end,
})

return skel
