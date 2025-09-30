local skel = fk.CreateSkill {
  name = "steam__yanke",
}

Fk:loadTranslationTable{
  ["steam__yanke"] = "严恪",
  [":steam__yanke"] = "你的非转化牌对一名角色生效前，你可将此牌效果改为造成1点伤害。",
  ["#steam__yanke-invoke"] = "严恪：你使用的%arg即将对 %dest 生效，是否将效果改为对其造成1点伤害？",

  ["$steam__yanke1"] = "为国勤事，体素精勤。",
  ["$steam__yanke2"] = "忠勤为国，通达治体。",
}

skel:addEffect(fk.PreCardEffect, { -- 注意，延时锦囊此时机没有data.from，装备牌不过此时机
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return data.from == player and player:hasSkill(skel.name) and not data.card:isVirtual() and data.to and data.to:isAlive()
  end,
  on_cost = function (self, event, target, player, data)
    if player.room:askToSkillInvoke(player, { skill_name = self.name,
     prompt = "#steam__yanke-invoke::"..data.to.id..":"..data.card:toLogString() }) then
      event:setCostData(self, { tos = {data.to} })
      return true
    end
  end,
  on_use = function (self, event, target, player, data)
    data:changeCardSkill("steam__yanke_card_skill")
  end,
})

return skel
