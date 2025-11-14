local skel = fk.CreateSkill {
  name = "steam__xueqing",
}

Fk:loadTranslationTable{
  ["steam__xueqing"] = "血倾",
  [":steam__xueqing"] = "出牌阶段限一次，你可以摸至多三张牌并明置等量的手牌，然后你视为使用等量张【火攻】；均结算后，你受到等同于你明置手牌数的火焰伤害。",

  ["#steam__xueqing"] = "你可摸至多三张牌并明置等量的手牌，再视为使用等量【火攻】，最终每剩1明置牌受到1火伤",
  ["#steam__xueqing-show"] = "血倾：请明置 %arg 张手牌",
  ["#steam__xueqing-fire"] = "血倾：请选择使用【火攻】的目标（第 %arg 张，共 %arg2 张）",
}

local DIY = require "packages.diy_utility.diy_utility"

skel:addEffect("active", {
  anim_type = "offensive",
  card_num = 0,
  target_num = 0,
  prompt = "#steam__xueqing",
  card_filter = Util.FalseFunc,
  interaction = function()
    return UI.Spin { from = 1, to = 3 }
  end,
  times = function (self, player)
    return (1 + player:getMark("@steam__emobaofa")) - player:usedSkillTimes(skel.name, Player.HistoryPhase)
  end,
  can_use = function(self, player)
    return player:usedSkillTimes(skel.name, Player.HistoryPhase) < (1 + player:getMark("@steam__emobaofa"))
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local num = self.interaction.data
    if type(num) ~= "number" or player.dead then return end
    player:drawCards(num, skel.name)
    if player.dead or player:isKongcheng() then return end
    local cards = player:getCardIds("h")
    if #cards > num then
      cards = room:askToCards(player, {
        min_num = num, max_num = num, include_equip =  false, skill_name = skel.name,
        cancelable = false, prompt = "#steam__xueqing-show:::"..num
      })
    end
    DIY.showCards(player, cards)
    for i = 1, num, 1 do
      if player.dead then return end
      room:askToUseVirtualCard(player, {
        name = "fire_attack", skill_name = skel.name, cancelable = false,
        prompt = "#steam__xueqing-fire:::"..i..":"..num,
      })
    end
    if not player:isKongcheng() then
      local x = #DIY.getShownCards(player)
      if x > 0 then
        room:damage { from = nil, to = player, damage = x, skillName = skel.name, damageType = fk.FireDamage }
      end
    end
  end,
})

return skel
