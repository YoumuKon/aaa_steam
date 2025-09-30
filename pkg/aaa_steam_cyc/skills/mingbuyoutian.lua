local skel = fk.CreateSkill {
  name = "steam__mingbuyoutian",
}

Fk:loadTranslationTable{
  ["steam__mingbuyoutian"] = "命不由天",
  [":steam__mingbuyoutian"] = "当你需要使用一张非基本牌时，你可以依次弃置两张牌(第一张取花色，第二张取点数)，然后若牌堆或弃牌堆中存在该花色点数组合的所需牌，你使用之。",

  ["#steam__mingbuyoutian"] = "先选择牌名，再选择两张牌(第一张取花色，第二张取点数)，若有所需牌，你使用之",
  ["#steam__mingbuyoutian_advice"] = "【%arg】推荐组合：[%arg2]（第一张取花色，第二张取点数）",
  ["#steam__mingbuyoutian_FailLog"] = "未检索到 %arg[%arg2%arg3]",
}

skel:addEffect("viewas", {
  pattern = ".|.|.|.|.|trick,equip",
  prompt = function (self, player, selected_cards, selected)
    local choice = self.interaction.data
    if choice == "?" or choice == nil then
      return "#steam__mingbuyoutian"
    else
      local list = {}
      for _, card in ipairs(Fk.cards) do
        if card.name == choice then
          local str = Fk:translate(card:getSuitString(true)) .. card.number
          table.insertIfNeed(list, str)
          if #list > 3 then break end
        end
      end
      local arg2 = table.concat(list, " ,")
      return "#steam__mingbuyoutian_advice:::" .. choice .. ":" .. arg2
    end
  end,
  interaction = function (self, player)
    local all_choices = Fk:getAllCardNames("tde")
    local choices = player:getViewAsCardNames(skel.name, all_choices)
    if #choices > 0 then
      return UI.CardNameBox { choices = choices, all_choices = all_choices, default_choice = "?" }
    end
  end,
  card_filter = function (self, player, to_select, selected)
    return #selected < 2 and not player:prohibitDiscard(to_select)
  end,
  view_as = function (self, player, cards)
    local name = self.interaction.data
    if #cards ~= 2 or name == nil or name == "?" then return nil end
    local c = Fk:cloneCard(name)
    c.skillName = skel.name
    c:setMark("steam__mingbuyoutian_data", cards)
    return c
  end,
  before_use = function(self, player, use)
    local room = player.room
    local cards = use.card:getMark("steam__mingbuyoutian_data")
    if type(cards) ~= "table" then return "" end
    local suit, number = Fk:getCardById(cards[1]):getSuitString(), Fk:getCardById(cards[2]).number
    room:throwCard(cards, skel.name, player, player)
    local ids = room:getCardsFromPileByRule(".|"..number.."|"..suit.."|.|"..use.card.name, 1, "allPiles")
    if #ids > 0 then
      use.card = Fk:getCardById(ids[1])
    else
      room:sendLog{
        type = "#steam__mingbuyoutian_FailLog", arg = use.card.name, arg2 = "log_"..suit, arg3 = tostring(number),
        toast = true
      }
      return ""
    end
  end,
  enabled_at_play = function(self, player)
    return #player:getCardIds("he") > 1
  end,
  enabled_at_response = function (self, player, response)
    if not response and #player:getCardIds("he") > 1 and Fk.currentResponsePattern then
      for _, name in ipairs(Fk:getAllCardNames("tde")) do
        if Exppattern:Parse(Fk.currentResponsePattern):matchExp(name) then
          return true
        end
      end
    end
  end,
})



return skel
