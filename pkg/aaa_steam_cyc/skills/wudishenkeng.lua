local skel = fk.CreateSkill {
  name = "steam__wudishenkeng",
}

Fk:loadTranslationTable{
  ["steam__wudishenkeng"] = "无底深坑",
  [":steam__wudishenkeng"] = "每回合限一次，你需要使用一张基本牌或普通锦囊牌时，可以重铸至少一张同名牌视为使用之。若不小于两张，之后你以此法使用牌后视为使用该牌。(每轮每牌名限追加使用一次)",

  ["#steam__wudishenkeng"] = "无底深坑：重铸至少一张同名牌视为使用需要的牌",
  ["#steam__wudishenkeng-card"] = "无底深坑：重铸任意张【%arg】视为使用【%arg2】！",
  ["@$steam__wudishenkeng"] = "无底深坑",
  ["#steam__wudishenkeng-use"] = "无底深坑：请追加使用【%arg】",
}

skel:addEffect("viewas", {
  name = "steam__wudishenkeng",
  anim_type = "drawcard",
  pattern = ".|.|.|.|.|basic,trick",
  prompt = function (self, player, cards)
    if #cards == 0 then return "#steam__wudishenkeng" end
    local card = Fk:getCardById(cards[1])
    -- 服了火杀了，目前逻辑是只需要重铸同真名的牌，视为使用第一张选择的牌名
    return "#steam__wudishenkeng-card:::"..card.trueName..":"..card.name
  end,
  card_filter = function (self, player, to_select, selected)
    local card = Fk:getCardById(to_select)
    if table.contains(player.player_cards[Player.Hand], to_select) and (card:isCommonTrick() or card.type == Card.TypeBasic) then
      if #selected == 0 then
        if Fk.currentResponsePattern == nil then
          return player:canUse(card) and not player:prohibitUse(card)
        else
          return Exppattern:Parse(Fk.currentResponsePattern):match(card)
        end
      else
        return Fk:getCardById(selected[1]).trueName == card.trueName
      end
    end
  end,
  view_as = function (self, player, cards)
    if #cards == 0 then return nil end
    local card = Fk:cloneCard(Fk:getCardById(cards[1]).name)
    card:setMark(skel.name, cards)
    card.skillName = skel.name
    return card
  end,
  before_use = function(self, player, use)
    local room = player.room
    local cards = use.card:getMark(skel.name)
    if type(cards) ~= "table" then return "" end
    if #cards > 1 then
      use.extra_data = use.extra_data or {}
      use.extra_data.steam__wudishenkengName = use.card.name
    end
    room:recastCard(cards, player, skel.name)
  end,
  after_use = function(self, player, use)
    if player.dead then return end
    local room = player.room
    local mark = player:getTableMark("@$steam__wudishenkeng")
    for _, name in ipairs(mark) do
      if not table.contains(player:getTableMark("steam__wudishenkeng_used-round"), name) then
        if room:askToUseVirtualCard(player, {
          name = name, cancelable = false, skill_name = skel.name, skip = false, prompt = "#steam__wudishenkeng-use:::"..name,
          extra_data = {bypass_distances = true, bypass_times = true}
        }) then
          room:addTableMark(player, "steam__wudishenkeng_used-round", name)
        end
        if player.dead then break end
      end
    end
    if player.dead or not use.extra_data then return end
    local newName = use.extra_data.steam__wudishenkengName
    if newName then
      if not table.find(mark, function(name) return Fk:cloneCard(name).trueName == Fk:cloneCard(newName).trueName end) then
        room:addTableMark(player, "@$steam__wudishenkeng", newName)
      end
    end
  end,
  times = function (self, player)
    return 1 - player:usedSkillTimes(skel.name)
  end,
  enabled_at_play = function(self, player)
    return not player:isKongcheng() and player:usedSkillTimes(skel.name) == 0
  end,
  enabled_at_response = function (self, player, response)
    return not player:isKongcheng() and player:usedSkillTimes(skel.name) == 0
    and not response and Fk.currentResponsePattern
    and table.find(player:getCardIds("h"), function (id)
      local card = Fk:getCardById(id)
      return (card:isCommonTrick() or card.type == Card.TypeBasic) and
      Exppattern:Parse(Fk.currentResponsePattern):match(card)
    end)
  end,
})



return skel
