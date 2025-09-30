local skel = fk.CreateSkill {
  name = "steam__sizhige",
}

Fk:loadTranslationTable{
  ["steam__sizhige"] = "丝之歌",
  [":steam__sizhige"] = "每回合限一次，你不以此法造成/受到伤害时，可以摸至多三张牌并交给伤害来源等量的牌，令此伤害延迟至等量个回合后的结束阶段结算。若你本回合已发动“韧之意”且存活角色数不大于3，你扣减1点体力上限。",

  ["#steam__sizhige-ask"] = "丝之歌：你可以防止 %src 对 %dest 造成%arg点伤害，摸牌并交给 %src 等量牌，令伤害延迟",
  ["#steam__sizhige-num"] = "丝之歌：选择你摸牌数，并交给 %src 等量牌",
  ["#steam__sizhige-give"] = "丝之歌：请交给 %src %arg 张牌！",

  ["$steam__sizhige1"] = "哈噶雷！",
  ["$steam__sizhige2"] = "给盾！",
  ["$steam__sizhige3"] = "噶哒哒",
  ["$steam__sizhige4"] = "艾迪落！",
}

local can_trigger = function(self, event, target, player, data)
  if not player:hasSkill(skel.name) or target ~= player or player:usedSkillTimes(skel.name, Player.HistoryTurn) ~= 0 then return false end
  return data.skillName ~= skel.name and data.from and data.from:isAlive()
end

local on_cost = function (self, event, target, player, data)
  return player.room:askToSkillInvoke(player, { skill_name = skel.name,
  prompt = "#steam__sizhige-ask:"..data.from.id..":"..data.to.id..":"..data.damage  })
end

---@param player ServerPlayer
local on_use = function (self, event, target, player, data)
  local room = player.room
  local from = data.from
  if from == nil then return false end
  local num = room:askToChoice(player, { choices = {"1", "2", "3"}, skill_name = skel.name, prompt = "#steam__sizhige-num:"..from.id})
  num = tonumber(num) or 1
  player:drawCards(num, skel.name)
  if not player.dead and not player:isNude() and not from.dead and player ~= from then
    local cards = player:getCardIds("he")
    if #cards > num then
      cards = room:askToCards(player, {
        min_num = num, max_num = num, skill_name = skel.name, include_equip = true, cancelable = false,
        prompt = "#steam__sizhige-give:"..from.id.."::"..num,
      })
    end
    room:obtainCard(from, cards, false, fk.ReasonGive, player, skel.name)
  end
  local mark = room:getTag("steam__sizhige_record") or {}
  -- 仅记录伤害点数和属性
  table.insert(mark, {from.id, data.to.id, num, data.damage, data.damageType})
  room:setTag("steam__sizhige_record", mark)
  if player:usedSkillTimes("steam__renzhiyi", Player.HistoryTurn) > 0 and #room.alive_players <= 3 then
    room:changeMaxHp(player, -1)
  end
  data:preventDamage()
end

skel:addEffect(fk.DamageCaused, {
  anim_type = "control",
  times = function (_, player)
    return 1 - player:usedSkillTimes(skel.name, Player.HistoryTurn)
  end,
  can_trigger = can_trigger,
  on_cost = on_cost,
  on_use = on_use,
})

skel:addEffect(fk.DamageInflicted, {
  anim_type = "control",
  can_trigger = can_trigger,
  on_cost = on_cost,
  on_use = on_use,
})

skel:addEffect(fk.EventPhaseStart, {
  is_delay_effect = true,
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return target.phase == Player.Finish and target == player
    and player.room:getTag("steam__sizhige_record") ~= nil
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local mark = table.simpleClone(room:getTag("steam__sizhige_record"))
    local new_mark = {}
    for _, dat in ipairs(mark) do
      local fromId, toId, count, num, type = table.unpack(dat)
      local from, to = room:getPlayerById(fromId), room:getPlayerById(toId)
      dat[3] = count - 1
      if dat[3] < 0 then
        if not to.dead then
          from:broadcastSkillInvoke(skel.name)
          room:notifySkillInvoked(from, skel.name, "offensive", {toId})
          room:doIndicate(from, {to})
          room:damage { from = from, to = to, damage = num, skillName = skel.name, damageType = type }
          room:delay(600)
        end
      else
        table.insert(new_mark, dat)
      end
    end
    room:setTag("steam__sizhige_record", #new_mark > 0 and new_mark or nil)
  end,
})

return skel
