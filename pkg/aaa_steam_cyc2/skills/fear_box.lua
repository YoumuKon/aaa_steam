local skel = fk.CreateSkill {
  name = "steam__fear_box",
  tags = { Skill.Hidden },
}

Fk:loadTranslationTable{
  ["steam__fear_box"] = "惊吓魔盒",
  [":steam__fear_box"] = "隐匿。你登场后，或休整归来后，你摸两张牌且可以将一张牌当造成冰冻伤害的【出其不意】使用。结束阶段，"..
  "你可以失去1点体力并隐匿。",

  ["steam__fear_box_viewas"] = "惊吓魔盒",
  ["#steam__fear_box-use"] = "惊吓魔盒：你可以将一张牌当造成冰冻伤害的【出其不意】使用",
  ["#steam__fear_box-hide"] = "惊吓魔盒：是否失去1点体力并隐匿？",

  ["$steam__fear_box1"] = "恶作剧的对象，是你哦！",
  ["$steam__fear_box2"] = "呜呼嘿嘿！",
}

local U = require "packages.utility.utility"
local DIY = require "packages.diy_utility.diy_utility"

local on_use = function (self, event, target, player, data)
    player:drawCards(2, skel.name)
    if not player.dead and not player:isNude() then
      player.room:askToUseVirtualCard(player, {
        prompt = "#steam__fear_box-use", skill_name = skel.name, skip = false, name = "unexpectation",
        card_filter = {
          n = {1, 1}
        }
      })
    end
  end

skel:addEffect(U.GeneralAppeared, {
  anim_type = "drawcard",
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasShownSkill(skel.name)
  end,
  on_cost = Util.TrueFunc,
  on_use = on_use,
})

skel:addEffect(fk.AfterPlayerRevived, {
  anim_type = "drawcard",
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasShownSkill(skel.name) and data.reason == "rest"
  end,
  on_cost = Util.TrueFunc,
  on_use = on_use,
})

skel:addEffect(fk.EventPhaseStart, {
  anim_type = "defensive",
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(skel.name) and player.phase == Player.Finish
  end,
  on_cost = function (self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {skill_name = skel.name, prompt = "#steam__fear_box-hide" })
  end,
  on_use = function (self, event, target, player, data)
    player.room:loseHp(player, 1, skel.name)
    if not player.dead then
      DIY.enterHidden(player)
    end
  end,
})

skel:addEffect(fk.PreDamage, {
  can_refresh = function (self, event, target, player, data)
    return target == player and data.card and table.contains(data.card.skillNames, skel.name)
  end,
  on_refresh = function (self, event, target, player, data)
    data.damageType = fk.IceDamage
  end,
})

return skel
