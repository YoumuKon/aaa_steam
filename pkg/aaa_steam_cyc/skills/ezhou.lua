local skel = fk.CreateSkill {
  name = "steam__ezhou",
  tags = {Skill.Compulsory},
}

Fk:loadTranslationTable{
  ["steam__ezhou"] = "厄咒",
  [":steam__ezhou"] = "锁定技，每个回合开始时，你须进行一次【浮雷】判定。当你扣减1点体力后，摸一张牌并随机获得一枚标记：“笞”、“杖”、“徒”、“流”、“死”。",

  -- 加个1和官方的区分
  ["@[desc]shencai1si"] = "死",
  ["@[desc]shencai1chi"] = "笞",
  ["@[desc]shencai1zhang"] = "杖",
  ["@[desc]shencai1tu"] = "徒",
  ["@[desc]shencai1liu"] = "流",

  [":shencai1si"] = "回合结束时，若你“死”标记个数大于场上存活人数，你死亡。",
  [":shencai1chi"] = "每轮限一次，受到伤害后失去1点体力。",
  [":shencai1zhang"] = "无法响应【杀】。",
  [":shencai1tu"] = "每阶段一次，失去手牌后随机弃置一张手牌。",
  [":shencai1liu"] = "结束阶段将武将牌翻面。",
}

local ezhou_mark = {"@[desc]shencai1si", "@[desc]shencai1chi", "@[desc]shencai1zhang", "@[desc]shencai1tu", "@[desc]shencai1liu"}


skel:addEffect(fk.TurnStart, {
  anim_type = "negative",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(skel.name)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local judge = {
      who = player,
      reason = "floating_thunder",
      pattern = ".|.|spade",
    }
    room:judge(judge)
    if judge.card.suit == Card.Spade and not player.dead then
      room:damage{
        to = player,
        damage = 1,
        damageType = fk.ThunderDamage,
        skillName = skel.name,
      }
    end
  end,
})

skel:addEffect(fk.HpChanged, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(skel.name) then
      return target == player and data.num < 1
    end
  end,
  trigger_times = function (self, event, target, player, data)
    return math.abs(data.num)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:drawCards(1, skel.name)
    if not player.dead then
      local mark = table.random(ezhou_mark)
      room:addPlayerMark(player, mark)
    end
  end,
})

skel:addEffect(fk.Damaged, {
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    if player.dead then return false end
    return player == target and player:getMark("@[desc]shencai1chi") > 0 and player:getMark("shencai1chi-round") == 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    player.room:setPlayerMark(player, "shencai1chi-round", 1)
    player.room:loseHp(player, 1, skel.name)
  end,
})

skel:addEffect(fk.TargetConfirmed, {
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    if player.dead then return false end
    return player == target and data.card.trueName == "slash" and player:getMark("@[desc]shencai1zhang") > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    data:setDisresponsive(player)
  end,
})

skel:addEffect(fk.AfterCardsMove, {
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    if player.dead then return false end
    if player:getMark("@[desc]shencai1tu") > 0 and not player:isKongcheng()
      and player:getMark("shencai1tu-phase") == 0 then
      for _, move in ipairs(data) do
        if move.skillName ~= skel.name and move.from == player then
          for _, info in ipairs(move.moveInfo) do
            if info.fromArea == Card.PlayerHand then
              return true
            end
          end
        end
      end
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    local cards = table.filter(player.player_cards[Player.Hand], function (id)
      return not player:prohibitDiscard(Fk:getCardById(id))
    end)
    if #cards > 0 then
      player.room:setPlayerMark(player, "shencai1tu-phase", 1)
      player.room:throwCard(table.random(cards, 1), skel.name, player, player)
    end
  end,
})

skel:addEffect(fk.EventPhaseStart, {
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    if player.dead then return false end
    return player == target and player:getMark("@[desc]shencai1liu") > 0 and player.phase == Player.Finish
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    player:turnOver()
  end,
})

skel:addEffect(fk.TurnEnd, {
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    if player.dead then return false end
    return player == target and player:getMark("@[desc]shencai1si") > #player.room.alive_players
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    player.room:killPlayer({who = player})
  end,
})

return skel
