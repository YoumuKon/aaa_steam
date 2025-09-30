local skel = fk.CreateSkill {
  name = "steam__jiqiao",
}

Fk:loadTranslationTable{
  ["steam__jiqiao"] = "激峭",
  [":steam__jiqiao"] = "你使用牌后，获得一枚“峭”。结束阶段，你可以将体力上限调整至“峭”数加一，并清除全部“峭”。",

  ["@steam__jiqiao"] = "峭",
  ["#steam__jiqiao-invoke"] = "激峭：你可以将体力上限调整为 %arg 并清除“峭”标记",

  ["$steam__jiqiao1"] = "我自饮马长江头，横刀问天谁敌手！",
  ["$steam__jiqiao2"] = "诸君且拭目，看我江东子弟虎步南北、纵横天下！",
}

skel:addEffect(fk.CardUseFinished, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(skel.name) and target == player then
      return true
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:addPlayerMark(player, "@steam__jiqiao")
  end,
})

skel:addEffect(fk.EventPhaseStart, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(skel.name) and target == player then
      return player.phase == Player.Finish and player.maxHp ~= (player:getMark("@steam__jiqiao") + 1)
    end
  end,
  on_cost = function (self, event, target, player, data)
    if event == fk.CardUseFinished then return true end
    return player.room:askToSkillInvoke(player, {
      skill_name = skel.name,
      prompt = "#steam__jiqiao-invoke:::" .. (player:getMark("@steam__jiqiao") + 1)
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local num = player:getMark("@steam__jiqiao") + 1
    room:setPlayerMark(player, "@steam__jiqiao", 0)
    room:changeMaxHp(player, num - player.maxHp)
  end,
})

skel:addLoseEffect(function (self, player, is_death)
  player.room:setPlayerMark(player, "@steam__jiqiao", 0)
end)

return skel
