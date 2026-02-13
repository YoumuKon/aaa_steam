local qihe = fk.CreateSkill {
  name = "steam__qihe",
}

Fk:loadTranslationTable{
  ["steam__qihe"] = "气合",
  [":steam__qihe"] = "每轮开始时，或有转换技完整转换一轮后，你可以摸一张牌并令一名未装备<a href=':steam_qihe_equip'>【云与漆】</a>的角色使用<a href=':steam_qihe_equip'>【云与漆】</a>。",
  ["#steam__qihe-choose"] = "气合：令一名角色使用【云与漆】",

  ["$steam__qihe1"] = "劳烦各位，各自落座。",
  ["$steam__qihe2"] = "下已进我局中。",
}

local DIY = require "packages.diy_utility.diy_utility"

local spec = {
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:drawCards(1, qihe.name)
    if not player.dead then
      local targets = table.filter(room.alive_players, function (p)
        return p:canUseTo(Fk:cloneCard("steam_qihe_equip", Card.Club, 2), p) 
        and not table.find(p:getCardIds("e"), function (id) return Fk:getCardById(id).trueName == "steam_qihe_equip" end)
      end)
      if #targets == 0 then return end
      local to = room:askToChoosePlayers(player, {
        min_num = 1,
        max_num = 1,
        targets = targets,
        skill_name = qihe.name,
        prompt = "#steam__qihe-choose",
        cancelable = false,
      })[1]
      local card = room:printCard("steam_qihe_equip", Card.Club, 2)
      room:setCardMark(card, MarkEnum.DestructOutMyEquip, 1)
      room:useCard{
        from = to,
        tos = { to },
        card = card,
      }
    end
  end,
}

--每轮开始时
qihe:addEffect(fk.RoundStart, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(qihe.name)
  end,
  on_use = spec.on_use,
})

--转换技发动后（若为阳），或你发动云与漆使用牌后（必定切换装备牌转换技为阳）
qihe:addEffect(fk.AfterSkillEffect, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(qihe.name) and (data.skill.name == "steam_qihe_equip_yin&" or
    (data.skill:hasTag(Skill.Switch) and not data.skill.is_delay_effect and target:getSwitchSkillState(data.skill.name, false) == fk.SwitchYang))
  end,
  on_use = spec.on_use,
})

--多转类技能的默认周始
qihe:addEffect(DIY.SkillSwitchLoopback, {
  anim_type = "offensive",
  can_trigger = function (self, event, target, player, data)
    return target and data and target:hasSkill(data.skill.name, true) and player:hasSkill(qihe.name)
  end,
  on_use = spec.on_use,
})

return qihe
