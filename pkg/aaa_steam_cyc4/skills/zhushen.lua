local zhushen = fk.CreateSkill {
  name = "steam__zhushen",
}

Fk:loadTranslationTable{
  ["steam__zhushen"] = "铸神",
  [":steam__zhushen"] = "出牌阶段限两次，你可以弃置一张装备牌，然后<a href='steam__zhushen_href'>铸造神兵</a>，令一名本阶段未选择过的角色使用之！",

  ["steam__zhushen_href"] = "选择一个花色并发现一个即时牌的牌名，生成一件<a href=':steam_zhushen_equip'>【古旧铸物】</a>",

  ["#steam__zhushen"] = "铸神：弃置一张装备牌“铸造神兵”！",
  ["#steam__zhushen-suit"] = "铸神：选择花色",
  ["#steam__zhushen-name"] = "铸神：选择一个牌名",
  ["#steam__zhushen-choose"] = "铸神：令一名角色使用神兵【古旧铸物】！（可以将所有%arg手牌当【%arg2】使用并摸一张牌）",

  ["$steam__zhushen1"] = "铸乃众相之柱！",
  ["$steam__zhushen2"] = "以子之矛攻子之盾，就会产生大爆炸！",
}

zhushen:addEffect("active", {
  anim_type = "support",
  prompt = "#steam__zhushen",
  card_num = 1,
  target_num = 0,
  can_use = function(self, player)
    return player:usedSkillTimes(zhushen.name, Player.HistoryPhase) < 2
  end,
  card_filter = function(self, player, to_select, selected)
    return #selected == 0 and Fk:getCardById(to_select).type == Card.TypeEquip and not player:prohibitDiscard(to_select)
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    room:throwCard(effect.cards, zhushen.name, player, player)
    if player.dead then return end
    local cards = table.filter(room.draw_pile, function (id)
      return Fk:getCardById(id).type == Card.TypeBasic or Fk:getCardById(id):isCommonTrick()
    end)
    if #cards == 0 then return end
    local suit = room:askToChoice(player, {
      choices = { "log_spade", "log_heart", "log_club", "log_diamond" },
      skill_name = zhushen.name,
      prompt = "#steam__zhushen-suit",
    })
    if not room:getBanner(zhushen.name) then
      local names = {}
      for _, card in ipairs(Fk.cards) do
        if not card.is_derived and (card.type == Card.TypeBasic or card:isCommonTrick()) then
          table.insertIfNeed(names, card.name)
        end
      end
      room:setBanner(zhushen.name, names)
    end
    local name = room:askToChoice(player, {
      choices = table.random(room:getBanner(zhushen.name), 3),
      skill_name = zhushen.name,
      prompt = "#steam__zhushen-name",
    })
    local targets = table.filter(room.alive_players, function (p)
      return p:canUseTo(Fk:cloneCard("steam_zhushen_equip", Card.Diamond, 10), p) and
        not table.contains(player:getTableMark("steam__zhushen-phase"), p.id)
    end)
    if #targets == 0 then return end
    local to = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = targets,
      skill_name = zhushen.name,
      prompt = "#steam__zhushen-choose:::"..suit..":"..name,
      cancelable = false,
    })[1]
    room:addTableMark(player, "steam__zhushen-phase", to.id)
    local card = room:printCard("steam_zhushen_equip", Card.Diamond, 10)
    room:setCardMark(card, zhushen.name, {suit, name})
    room:setCardMark(card, MarkEnum.DestructOutMyEquip, 1)
    room:useCard{
      from = to,
      tos = { to },
      card = card,
    }
  end,
})

return zhushen
