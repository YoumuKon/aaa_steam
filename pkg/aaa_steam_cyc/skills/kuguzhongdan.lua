local skel = fk.CreateSkill {
  name = "steam__kuguzhongdan",
}

Fk:loadTranslationTable{
  ["steam__kuguzhongdan"] = "枯骨重担",
  [":steam__kuguzhongdan"] = "准备阶段，你可以扔出<a href='steam__kuguzhongdan_href'>你的武将牌</a>至一名其他角色手牌中，对其造成0-2点伤害！(你每损失1点体力，便可以令伤害下限或上限+1)",

  ["steam__kuguzhongdan_href"] = "“堕化遗骸”的武将牌视为♠A，类型为装备牌，不能使用，离开手牌区时立即复位。",
  ["#steam__kuguzhongdan-choose"] = "枯骨重担：你可以扔出你的武将牌，对目标造成 0 ~ 2 点伤害！",
  ["#steam__kuguzhongdan-choice"] = "增加对其伤害的上限或下限（当前下限: %arg；上限: %arg2；剩余: %arg3 次）",
  ["steam__kuguzhongdan_min"] = "增加下限",
  ["steam__kuguzhongdan_max"] = "增加上限",

  ["#steam__kuguzhongdan_delay"] = "枯骨重担",
}

local myGeneral = "steam__corrupted_theforgotten"

skel:addEffect(fk.EventPhaseStart, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    if Fk.all_card_types["forgottencard"] == nil then return end
    if target == player and player:hasSkill(skel.name) and player.phase == Player.Start then
      return player.general == myGeneral or player.deputyGeneral == myGeneral
    end
  end,
  on_cost = function (self, event, target, player, data)
    local tos = player.room:askToChoosePlayers(player, {
      targets = player.room:getOtherPlayers(player, false), max_num = 1, min_num = 1,
      prompt = "#steam__kuguzhongdan-choose", skill_name = skel.name
    })
    if #tos > 0 then
      event:setCostData(self, {tos = tos})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = event:getCostData(self).tos[1]
    if player.general == myGeneral then
      room:setPlayerProperty(player, "general", player.gender == General.Male and "blank_shibing" or "blank_nvshibing")
    end
    if player.deputyGeneral == myGeneral then
      room:setPlayerProperty(player, "deputyGeneral", "")
      player.tag["forgotten_deputy"] = true
    end
    room:handleAddLoseSkills(player, "-" .. skel.name)
    local card = room:printCard("forgottencard", Card.Spade, 1)
    room:setCardMark(card, "forgottencard_from", player.id)

    local min, max = 0, 2
    local all_choices = {"steam__kuguzhongdan_min", "steam__kuguzhongdan_max", "Cancel"}
    local x = player:getLostHp()
    for i = 1, x do
      local choices = table.simpleClone(all_choices)
      if min >= max then table.remove(choices, 1) end
      local choice = room:askToChoice(player, {
        choices = choices, skill_name = skel.name, all_choices = all_choices,
        prompt = "#steam__kuguzhongdan-choice:::"..min..":"..max..":"..(x-i+1),
      })
      if choice == "Cancel" then break
      elseif choice == "steam__kuguzhongdan_min" then min = min + 1
      else max = max + 1 end
    end
    local rnd = math.random(min, max)

    room:doIndicate(player, {to})
    room:obtainCard(to, card, true, fk.ReasonJustMove, player, skel.name)
    if rnd > 0 and not to.dead then
      room:damage { from = player, to = to, damage = rnd, skillName = skel.name }
    end
  end,
})

--- 武将牌离开手牌后，复原武将牌
skel:addEffect(fk.AfterCardsMove, {
  mute = true,
  is_delay_effect = true,
  priority = 0.9,
  can_trigger = function(self, event, target, player, data)
    for _, move in ipairs(data) do
      for _, info in ipairs(move.moveInfo) do
        if info.fromArea == Player.Hand then
          if Fk:getCardById(info.cardId):getMark("forgottencard_from") == player.id then
            return true
          end
        end
      end
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local cards = {}
    for _, move in ipairs(data) do
      for _, info in ipairs(move.moveInfo) do
        if info.fromArea == Player.Hand and Fk:getCardById(info.cardId):getMark("forgottencard_from") == player.id then
          room:setCardMark(Fk:getCardById(info.cardId), "forgottencard_from", 0)
          if room:getCardArea(info.cardId) ~= Card.Void then
            table.insert(cards, info.cardId)
          end
        end
      end
    end
    if #cards > 0 then -- 销毁武将牌
      room:moveCardTo(cards, Card.Void, nil, fk.ReasonJustMove, skel.name, nil, true)
    end
    -- 复原武将牌
    if player.tag["forgotten_deputy"] then -- 复位在副将
      player.tag["forgotten_deputy"] = false
      room:changeHero(player, myGeneral, false, true, true, false, true)
    else
      room:changeHero(player, myGeneral, false, false, true, false, true)
    end
  end,
})

return skel
