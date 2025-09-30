local skel = fk.CreateSkill {
  name = "steam__emokuangnu",
}

Fk:loadTranslationTable{
  ["steam__emokuangnu"] = "恶魔狂怒",
  [":steam__emokuangnu"] = "轮次结束时，若你本轮造成的伤害数不小于当前体力值，你可以失去1点体力或体力上限，立即执行一种〖忿恨倾泻〗的效果，或令〖忿恨倾泻〗的每回合发动次数+1。",

  ["#steam__emokuangnu_use"] = "使用【兵临城下】",
  ["#steam__emokuangnu_times"] = "增加〖忿恨倾泻〗次数",
}

skel:addEffect(fk.RoundEnd, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(skel.name) then
      local count = 0
      return #player.room.logic:getActualDamageEvents(1, function (e)
        local damage = e.data
        if damage.from == player then
          count = count + damage.damage
        end
        return count >= player.hp
      end, Player.HistoryRound) > 0
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local choice = room:askToChoice(player, { choices = {"loseMaxHp", "loseHp"}, skill_name = skel.name})
    if choice == "loseMaxHp" then
      room:changeMaxHp(player, -1)
    else
      room:loseHp(player, 1, skel.name)
    end
    if player.dead then return end
    choice = room:askToChoice(player, { choices = {"#steam__emokuangnu_use", "#steam__emokuangnu_times"}, skill_name = skel.name})
    if choice == "#steam__emokuangnu_times" then
      room:addPlayerMark(player, "steam__emokuangnu_times", 1)
    else
      -- 直接新建一个假事件出来！
      local angerPour = Fk.skills["steam__fenhenqingxie"] ---@type TriggerSkill
      if not (angerPour and angerPour:isInstanceOf(TriggerSkill)) then return end
      room:addSkill(angerPour) -- 别忘了加入房间，否则延时效果不生效
      local event_data = PhaseData:new{
        who = player,
        reason = "game_rule",
        phase = Player.Start, -- 为了自选
      }
      local event_obj = fk.EventPhaseStart:new(room, player, event_data)
      angerPour:use(event_obj, player, player, event_data)
    end
  end,
})

return skel
