local xunlie = fk.CreateSkill {
  name = "steam__xunlie",
}

Fk:loadTranslationTable{
  ["steam__xunlie"] = "寻烈",
  [":steam__xunlie"] = "每回合限X次，每轮每牌名限一次，你可以将任意张牌当初始手牌中的一张即时牌使用。若转化牌数小于X，结算后，"..
  "你横置X名角色并受到1点火焰伤害。（X为轮次数）",

  ["#steam__xunlie"] = "寻烈：将任意张牌当一张初始手牌使用，若少于%arg张则横置角色并受到火焰伤害",
  ["#steam__xunlie-choose"] = "寻烈：横置%arg名角色，你受到1点火焰伤害",

  ["$steam__xunlie1"] = "莱万汀！",
  ["$steam__xunlie2"] = "一个也别想逃！"
}

xunlie:addEffect("viewas", {
  anim_type = "offensive",
  pattern = ".",
  prompt = function (self, player)
    return "#steam__xunlie:::"..Fk:currentRoom():getBanner("RoundCount")
  end,
  interaction = function(self, player)
    local all_names = player:getTableMark(xunlie.name)
    local names = player:getViewAsCardNames(xunlie.name, all_names, nil, player:getTableMark("steam__xunlie-round"))
    if #names == 0 then return end
    return UI.CardNameBox { choices = names, all_choices = all_names }
  end,
  handly_pile = true,
  card_filter = Util.TrueFunc,
  view_as = function(self, player, cards)
    if not self.interaction.data or #cards == 0 then return end
    local card = Fk:cloneCard(self.interaction.data)
    card:addSubcards(cards)
    card.skillName = xunlie.name
    return card
  end,
  before_use = function(self, player, use)
    player.room:addTableMark(player, "steam__xunlie-round", use.card.trueName)
  end,
  after_use = function (self, player, use)
    local room = player.room
    local n = room:getBanner("RoundCount")
    if not player.dead and #Card:getIdList(use.card) < n then
      local targets = table.filter(room.alive_players, function (p)
        return not p.chained
      end)
      if #targets > 0 then
        if #targets > n then
          targets = room:askToChoosePlayers(player, {
            min_num = n,
            max_num = n,
            targets = targets,
            skill_name = xunlie.name,
            prompt = "#steam__xunlie-choose",
            cancelable = false,
          })
        end
        room:sortByAction(targets)
        for _, p in ipairs(targets) do
          if not p.chained and not p.dead then
            p:setChainState(true, xunlie.name)
          end
        end
      end
    end
    if not player.dead then
      room:damage{
        from = nil,
        to = player,
        damage = 1,
        skillName = xunlie.name,
        damageType = fk.FireDamage,
      }
    end
  end,
  enabled_at_play = function(self, player)
    return player:usedSkillTimes(xunlie.name, Player.HistoryTurn) < Fk:currentRoom():getBanner("RoundCount") and
      #player:getViewAsCardNames(xunlie.name, player:getTableMark(xunlie.name), nil, player:getTableMark("steam__xunlie-round")) > 0
  end,
  enabled_at_response = function(self, player, response)
    if response then return end
    return player:usedSkillTimes(xunlie.name, Player.HistoryTurn) < Fk:currentRoom():getBanner("RoundCount") and
      #player:getViewAsCardNames(xunlie.name, player:getTableMark(xunlie.name), nil, player:getTableMark("steam__xunlie-round")) > 0
  end,
  enabled_at_nullification = function (self, player, data)
    return player:usedSkillTimes(xunlie.name, Player.HistoryTurn) < Fk:currentRoom():getBanner("RoundCount") and
      table.contains(player:getTableMark(xunlie.name), "nullification")
  end,
})

xunlie:addEffect(fk.AfterDrawInitialCards, {
  global = true,
  can_refresh = function (self, event, target, player, data)
    return target == player and not player:isKongcheng()
  end,
  on_refresh = function (self, event, target, player, data)
    local names = {}
    for _, id in ipairs(player:getCardIds("h")) do
      local card = Fk:getCardById(id)
      if card.type == Card.TypeBasic or card:isCommonTrick() then
        table.insertIfNeed(names, card.name)
      end
    end
    if #names > 0 then
      player.room:setPlayerMark(player, xunlie.name, names)
    end
  end,
})

return xunlie
