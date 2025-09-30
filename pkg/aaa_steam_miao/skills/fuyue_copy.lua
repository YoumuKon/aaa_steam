local skel = fk.CreateSkill {
  name = "steam__fuyue_copy",
}

Fk:loadTranslationTable{
  ["steam__fuyue_copy"] = "斧钺",
  [":steam__fuyue_copy"] = "弃牌阶段开始时，你须将体力或手牌数调整至与另一项相等，然后令一名角色执行你此次调整的手牌或体力变动。",
}

---@param p ServerPlayer
---@param str string
local doFuyue = function (p, str)
  local room = p.room
  local splitter = str:split(":")
  local choice, num = splitter[1], tonumber(splitter[4]) or 0
  if choice:endsWith("draw") then
    p:drawCards(num, skel.name)
  elseif choice:endsWith("discard") then
    room:askToDiscard(p, {min_num = num, max_num = num, include_equip = true, skill_name = skel.name, cancelable = false})
  elseif choice:endsWith("recover") then
    room:recover { num = num, skillName = skel.name, who = p, recoverBy = room.current }
  elseif choice:endsWith("losehp") then
    room:loseHp(p, num, skel.name)
  end
end

skel:addEffect(fk.EventPhaseStart, {
  mute = true,
  can_trigger = function (self, event, target, player, data)
    if player:hasSkill(skel.name) and target == player then
      return player.phase == Player.Discard
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    local room = player.room
    room:notifySkillInvoked(player, "steam__fuyue", "control")
    player:broadcastSkillInvoke("steam__fuyue", math.random(2))
    local x = player:getHandcardNum() - player.hp
    if x == 0 then return end
    local choices = {}
    if x > 0 then
      table.insert(choices, "steam__fuyue_discard:::" .. x)
      table.insert(choices, "steam__fuyue_recover:::" .. x)
    else
      table.insert(choices, "steam__fuyue_draw:::" .. -x)
      table.insert(choices, "steam__fuyue_losehp:::" .. -x)
    end
    local choice = room:askToChoice(player, { choices = choices, skill_name = skel.name, "#steam__fuyue-choice"})
    doFuyue(player, choice)
    if not player.dead then
      local tos = room:askToChoosePlayers(player, { targets = room.alive_players, min_num = 1, max_num = 1,
      prompt = "#steam__fuyue-choose", skill_name = skel.name, cancelable = false})
      if #tos > 0 then
        local to = tos[1]
        doFuyue(to, choice)
      end
    end
  end,
})

return skel
