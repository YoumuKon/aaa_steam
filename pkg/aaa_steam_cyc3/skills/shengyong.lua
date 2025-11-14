local skel = fk.CreateSkill{
  name = "steam__shengyong",
  tags = { Skill.Switch, Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["steam__shengyong"] = "圣咏",
  [":steam__shengyong"] = "转换技，锁定技，出牌阶段开始时，你整肃 阳：擂进；阴：鸣止。",

  [":steam__shengyong_yang"] = "转换技，锁定技，出牌阶段开始时，你整肃 <font color=\"#E0DB2F\">阳：擂进</font>；阴：鸣止。",
  [":steam__shengyong_yin"] = "转换技，锁定技，出牌阶段开始时，你整肃 阳：擂进；<font color=\"#E0DB2F\">阴：鸣止</font>。",
  ["#steam__shengyong-reward"] = "圣咏：整肃成功，请选择一项奖励。",

  ["$steam__shengyong1"] = " ",
  ["$steam__shengyong2"] = " ",
}

local U = require "packages/utility/utility"

skel:addEffect(fk.EventPhaseStart, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(skel.name) and player.phase == Player.Play
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local datas = {
      player = player,
      target = player,
      skill_name = skel.name,
      choice = player:getSwitchSkillState(skel.name, true) == fk.SwitchYang and "zhengsu_leijin" or "zhengsu_mingzhi",
    }
    room.logic:trigger(U.StartZhengsu, player, datas)
    local mark_name = "@" .. datas.choice .. "-turn"
    if player:getMark(mark_name) == 0 then
      room:setPlayerMark(player, mark_name, "")
    end
    room:addTableMark(player, "zhengsu_skill-turn", {player.id, skel.name, datas.choice})
    room:addSkill("#mobile_zhengsu_recorder")
  end,
})

skel:addEffect(fk.EventPhaseEnd, {
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and player.phase == Player.Discard and not player.dead and
      U.checkZhengsu(player, target, skel.name)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local choices = {"draw2"}
    if player:isWounded() then
      table.insert(choices, 1, "recover")
    end
    local reward = room:askToChoice(player, {
      choices = choices,
      skill_name = skel.name, 
      prompt = "#steam__shengyong-reward",
      all_choices = {"draw2", "recover"},
    })
    U.rewardZhengsu(player, player, reward, skel.name)
  end,
})

return skel
