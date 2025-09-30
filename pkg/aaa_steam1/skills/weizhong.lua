local skel = fk.CreateSkill {
  name = "steam__weizhong",
  tags = {Skill.Compulsory},
}

Fk:loadTranslationTable{
  ["steam__weizhong"] = "威重",
  [":steam__weizhong"] = "锁定技，当你的体力上限减少/增加时，你摸两张牌/分配两点伤害。",

  ["#steam__weizhong-damage"] = "威重：请分配1点伤害！（第%arg点，共2点）",

  ["$steam__weizhong1"] = "父魂于身，兄姿于表，天下自可纵横！",
  ["$steam__weizhong2"] = "擎旗斩将学霸王，秣马厉兵效乌程！",
}


skel:addEffect(fk.MaxHpChanged, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(skel.name) and target == player and data.num ~= 0
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if data.num < 0 then
      player:broadcastSkillInvoke(skel.name, 2)
      room:notifySkillInvoked(player, skel.name, "drawcard")
      player:drawCards(2, skel.name)
    else
      player:broadcastSkillInvoke(skel.name, 1)
      room:notifySkillInvoked(player, skel.name, "offensive")
      for i = 1, 2 do
        local tos = room:askToChoosePlayers(player, {
          targets = room.alive_players, max_num = 1, min_num = 1, skill_name = skel.name, cancelable = false,
          prompt = "#steam__weizhong-damage:::"..i,
        })
        if #tos > 0 then
          room:doIndicate(player, tos)
          room:damage { from = player, to = tos[1], damage = 1, skillName = skel.name }
        end
      end
    end
  end,
})

return skel
