local skel = fk.CreateSkill {
  name = "steam__deceive_magic",
  tags = {Skill.Compulsory},
}

Fk:loadTranslationTable{
  ["steam__deceive_magic"] = "欺诈魔术",
  [":steam__deceive_magic"] = "锁定技，你的濒死结算后，若你未被救回，且你不是所在阵营的唯一存活者，则休整至你的下回合开始。",

  ["$steam__deceive_magic1"] = "这很好玩啊！",
  ["$steam__deceive_magic2"] = "神出鬼没——就是我！",
}

skel:addEffect(fk.AskForPeachesDone, {
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(skel.name) and player:usedSkillTimes(self.name) == 0 and player.hp <= 0 then
      return table.find(player.room:getOtherPlayers(player), function (p)
        return p:isFriend(player)
      end)
    end
  end,
  on_use = function(self, event, target, player, data)
    player.room:setPlayerRest(player, 1)
  end,
})

return skel
