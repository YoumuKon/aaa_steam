local skel = fk.CreateSkill {
  name = "steam__chixiao",
  tags = {Skill.Compulsory},
}

Fk:loadTranslationTable{
  ["steam__chixiao"] = "鸱鸮",
  [":steam__chixiao"] = "锁定技，你使用牌后，若明置牌数小于暗置牌数，且手牌数为偶数，你将一半手牌翻面；你的暗置牌不计入手牌上限。",
  ["#steam__chixiao-card"] = "鸱鸮：请选择半数手牌，将它们翻面",
}

local DIY = require "packages.diy_utility.diy_utility"

skel:addEffect(fk.CardUseFinished, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(skel.name) and not player:isKongcheng() then
      return #DIY.getShownCards(player) < (player:getHandcardNum() / 2) and (player:getHandcardNum() % 2 == 0)
    end
  end,
  on_use = function(self, event, target, player, data)
    local num = player:getHandcardNum() // 2
    local cards = player.room:askToCards(player, { min_num = num, max_num = num, include_equip = false,
    skill_name = skel.name, cancelable = false, prompt = "#steam__chixiao-card"})
    local shown = table.filter(cards, function (id) -- 已明置的牌
      return table.contains(DIY.getShownCards(player), id)
    end)
    local hidden = table.filter(cards, function (id) -- 暗置牌
      return not table.contains(shown, id)
    end)
    DIY.hideCards(player, shown)
    DIY.showCards(player, hidden)
  end,
})

skel:addEffect("maxcards", {
  exclude_from = function(self, player, card)
    if player:hasSkill(skel.name) then
      return not table.contains(DIY.getShownCards(player), card.id)
    end
  end,
})

return skel
