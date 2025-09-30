local skel = fk.CreateSkill {
  name = "steam__qianghuotanpan",
}

Fk:loadTranslationTable{
  ["steam__qianghuotanpan"] = "枪火谈判",
  [":steam__qianghuotanpan"] = "出牌阶段限一次，你可以将一张牌当无距离次数限制的【杀】使用，结算后，你令目标及其攻击范围内角色场上的【定时炸弹】立即判定，且每有一张成功引爆，你获得一枚<a href=':cent_coin'>【幸运币】</a>。",

  ["#steam__qianghuotanpan"] = "枪火谈判：将一张牌当无距离次数限制的【杀】使用，然后引爆目标及攻击范围内角色脸上的炸弹",

  ["$steam__qianghuotanpan1"] = "人人有份！",
  ["$steam__qianghuotanpan2"] = "渣滓！",
  ["$steam__qianghuotanpan3"] = "脏东西！",
}

skel:addEffect("viewas", {
  anim_type = "offensive",
  pattern = "slash",
  prompt = "#steam__qianghuotanpan",
  card_filter = function (self, player, to_select, selected)
    return #selected == 0
  end,
  view_as = function (self, player, cards)
    if #cards ~= 1 then return nil end
    local c = Fk:cloneCard("slash")
    c.skillName = skel.name
    c:addSubcard(cards[1])
    return c
  end,
  before_use = function(self, player, use)
    use.extraUse = true
    local tos = {}
    local all = player.room.alive_players
    for _, to in ipairs(use.tos) do
      table.insertIfNeed(tos, to)
      for _, p in ipairs(all) do
        if to:inMyAttackRange(p) then
          table.insertIfNeed(tos, p)
        end
      end
    end
    if #tos > 0 then
      player.room:sortByAction(tos)
      use.extra_data = use.extra_data or {}
      use.extra_data.steam_parrrley_tos = tos
    end
  end,
  after_use = function (self, player, use)
    local room = player.room
    local tos = (use.extra_data or Util.DummyTable).steam_parrrley_tos or Util.DummyTable ---@type ServerPlayer[]
    if #tos == 0 then return end
    for _, to in ipairs(tos) do
      local boom
      if to:hasDelayedTrick("timebomb") then
        for _, id in ipairs(to.player_cards[Player.Judge]) do
          local card = to:getVirtualEquip(id) or Fk:getCardById(id)
          if card.name == "timebomb" then
            room:moveCardTo(card, Card.Processing, nil, fk.ReasonJustMove)
            local judge = {
              who = to,
              reason = "timebomb",
              pattern = ".|.|spade",
            }
            room:judge(judge)
            local subcards = room:getSubcardsByRule(card, { Card.Processing })
            local throw = true
            if judge:matchPattern() then
              boom = true
              room:damage {
                to = to, damage = 2, card = card, skillName = skel.name,
                damageType = (math.random(1,2) == 1 and fk.FireDamage or fk.ThunderDamage)
              }
            else -- 未引爆，放回去
              if not to:isProhibitedTarget(card) then
                throw = false
                if #subcards > 0 then
                  local move = {
                    ids = subcards,
                    to = to.id,
                    toArea = Card.PlayerJudge,
                    moveReason = fk.ReasonPut
                  }
                  if card:isVirtual() then
                    move.virtualEquip = card
                  end
                  room:moveCards(move)
                end
              end
            end
            if throw then
              room:moveCards{
                ids = subcards,
                toArea = Card.DiscardPile,
                moveReason = fk.ReasonUse
              }
            end
            break
          end
        end
      end
      if boom and not player.dead then
        local c = room:printCard("cent_coin", math.random(4), 1)
        room:setCardMark(c, MarkEnum.DestructIntoDiscard, 1)
        room:obtainCard(player, c, true, fk.ReasonJustMove, player, skel.name)
      end
    end
  end,
  times = function (self, player)
    return 1 - player:usedSkillTimes(skel.name, Player.HistoryPhase)
  end,
  enabled_at_play = function(self, player)
    return player:usedSkillTimes(skel.name, Player.HistoryPhase) == 0
  end,
  enabled_at_response = Util.FalseFunc,
})

skel:addEffect("targetmod", {
  bypass_times = function(self, player, skill, scope, card, to)
    return card and table.contains(card.skillNames, skel.name)
  end,
  bypass_distances = function(self, player, skill, card, to)
    return card and table.contains(card.skillNames, skel.name)
  end,
})


return skel
