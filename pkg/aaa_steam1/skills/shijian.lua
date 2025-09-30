local skel = fk.CreateSkill {
  name = "steam__shijian",
}

Fk:loadTranslationTable{
  ["steam__shijian"] = "试剑",
  [":steam__shijian"] = "你可以将两张基本牌或一张装备牌当不计入次数限制的【杀】使用，若你因此失去了某区域的最后一张牌，你与一名其他角色各摸一张牌。",

  ["#steam__shijian"] = "试剑：请将两张基本牌或一张装备牌当可选的基本牌使用！（无视次数限制）",
  ["#steam__shijian_trigger"] = "试剑",
  ["#steam__shijian-active"] = "试剑：请与一名其他角色各摸一张牌！",

  ["$steam__shijian1"] = "小女，就爱这舞刀弄枪。",
  ["$steam__shijian2"] = "小看我，你可是要吃亏的。",
}

skel:addEffect("viewas", {
  anim_type = "offensive",
  pattern = "slash,peach",
  prompt = "#steam__shijian",
  interaction = function(self, player)
    local all_names = {"slash", "peach"}
    local undo = {}
    if player:getMark("@@steam__nianqing") > 0 then
      table.insert(undo, "slash")
    end
    if player:getMark("@@steam__nianqing") == 0 then
      table.insert(undo, "peach")
    end
    local names = player:getViewAsCardNames(skel.name, all_names, nil, undo)
    if #names > 0 then
      return UI.CardNameBox { choices = names, all_choices = all_names }
    end
  end,
  handly_pile = true,
  card_filter = function(self, player, to_select, selected)
    return #selected < 2 and Fk:getCardById(to_select) ~= Card.TypeTrick
  end,
  view_as = function(self, player, cards)
    if #cards < 1 or #cards > 2 or not self.interaction.data then return end
    for _, id in ipairs(cards) do
      if #cards == 2 and Fk:getCardById(id).type ~= Card.TypeBasic then return end
      if #cards == 1 and Fk:getCardById(id).type ~= Card.TypeEquip then return end
    end
    local card = Fk:cloneCard(self.interaction.data)
    card.skillName = skel.name
    card:addSubcards(cards)
    return card
  end,
  before_use = function (self, player, use)
    use.extraUse = true
    local draw = false
    for _, id in ipairs(use.card.subcards) do
      if #player:getCardIds("e") == 1 and table.contains(player:getCardIds("e"), id) then
        draw = true
      end
      if #player:getCardIds("h") == 1 and table.contains(player:getCardIds("h"), id) then
        draw = true
      end
      if #player:getCardIds("h") == 2 then
        for _, p in ipairs(player:getCardIds("h")) do
          if not table.contains(use.card.subcards, p) then
            break
          end
        end
        draw = true
      end
    end
    if draw == true then
      use.extra_data = use.extra_data or {}
      use.extra_data.steam__shijian_draw = player
    end
  end,
  enabled_at_response = function(self, player, response)
    local all_names = {"slash", "peach"}
    local undo = {}
    if player:getMark("@@steam__nianqing") > 0 then
      table.insert(undo, "slash")
    end
    if player:getMark("@@steam__nianqing") == 0 then
      table.insert(undo, "peach")
    end
    return not response and #player:getHandlyIds() + #player:getCardIds("e") > 0 and
    #player:getViewAsCardNames(skel.name, all_names, nil, undo) > 0
  end,
})

skel:addEffect(fk.CardUsing, {
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    return not player.dead and data.extra_data and data.extra_data.steam__shijian_draw == player and #player.room:getOtherPlayers(player) > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = room:getOtherPlayers(player),
      skill_name = skel.name,
      prompt = "#steam__shijian-active",
      cancelable = false,
    })[1]
    room:drawCards(player, 1, skel.name)
    if not to.dead then
      room:drawCards(to, 1, skel.name)
    end
  end,
})

skel:addEffect("targetmod", {
  bypass_times = function(self, player, skill, scope, card)
    return card and table.contains(card.skillNames, skel.name)
  end,
})

return skel
