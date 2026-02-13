local shijie = fk.CreateSkill {
  name = "steam__shijie",
}

Fk:loadTranslationTable{
  ["steam__shijie"] = "世劫",
  [":steam__shijie"] = "出牌阶段限一次，你可以将一名角色场上颜色较少的所有牌当一张即时牌使用，若指定了该角色为目标，结算后其失去1点体力并调离。"..
  "轮次结束时，你可以发动任意次〖世劫〗并失去之。",

  ["#steam__shijie"] = "世劫：是否视为使用即时牌（底牌用一名角色场上颜色较少的所有牌转化）？",
  ["#steam__shijie-choose"] = "世劫：请用一名角色场上颜色较少的所有牌转化使用牌（若其也为目标，结算后其失去体力并调离）",
  ["#steam__shijie-invoke"] = "是否如出牌阶段空闲点般发动〖世劫〗？若如此做，结算后你失去〖世劫〗。",

  ["$steam__shijie1"] = "个一劫，是跑不脱的。",
  ["$steam__shijie2"] = "眼观全局，输赢不在个一点。",
}

local DIY = require "packages.diy_utility.diy_utility"

---@return ServerPlayer[]
local shijieMatch = function ()
  local list = {}
  for _, p in ipairs(Fk:currentRoom().alive_players) do
    local color_list = {}
    for _, color in ipairs({Card.Black, Card.Red, Card.NoColor}) do
      local x = table.filter(p:getCardIds("ej"), function (id) return Fk:getCardById(id).color == color end)
      if #x > 0 then
        table.insertIfNeed(color_list, #x)
      end
    end
    if #color_list > 1 then
      table.insertIfNeed(list, p)
    end
  end
  return list
end

---@param numbers integer[]
local function minPositive(numbers)
  local min = nil
  for _, num in ipairs(numbers) do
    if num > 0 then
      if min == nil or num < min then
        min = num
      end
    end
  end
  return min
end

Fk:addTargetTip{
  name = "steam__shijie",
  target_tip = function(self, player, to_select, selected, selected_cards, card, selectable)
    if not selectable then return end
    local x = table.filter(to_select:getCardIds("ej"), function (id) return Fk:getCardById(id).color == Card.Black end)
    local y = table.filter(to_select:getCardIds("ej"), function (id) return Fk:getCardById(id).color == Card.Red end)
    local z = table.filter(to_select:getCardIds("ej"), function (id) return Fk:getCardById(id).color == Card.NoColor end)
    if minPositive({#x, #y, #z}) == #x then
      return "black"
    elseif minPositive({#x, #y, #z}) == #y then
      return "red"
    elseif minPositive({#x, #y, #z}) == #z then
      return "NoColor"
    end
  end,
}

shijie:addEffect("viewas", {
  prompt = "#steam__shijie",
  mute_card = false,
  interaction = function(self, player)
    local all_names = Fk:getAllCardNames("t")
    return UI.CardNameBox {
      choices = player:getViewAsCardNames(shijie.name, all_names),
      all_choices = all_names,
    }
  end,
  card_filter = Util.FalseFunc,
  view_as = function(self, player, cards)
    if Fk.all_card_types[self.interaction.data] == nil or #shijieMatch() == 0 then return end
    local card = Fk:cloneCard(self.interaction.data)
    card.skillName = self.name
    return card
  end,
  before_use = function (self, player, use)
    local switcher = player.room:askToChoosePlayers(player, {
      targets = shijieMatch(),
      min_num = 1,
      max_num = 1,
      prompt = "#steam__shijie-choose",
      skill_name = shijie.name,
      cancelable = false,
      target_tip_name = shijie.name,
    })[1]
    local x = table.filter(switcher:getCardIds("ej"), function (id) return Fk:getCardById(id).color == Card.Black end)
    local y = table.filter(switcher:getCardIds("ej"), function (id) return Fk:getCardById(id).color == Card.Red end)
    local z = table.filter(switcher:getCardIds("ej"), function (id) return Fk:getCardById(id).color == Card.NoColor end)
    if minPositive({#x, #y, #z}) == #x then
      use.card:addSubcards(table.filter(switcher:getCardIds("ej"), function (id) return Fk:getCardById(id).color == Card.Black end))
    elseif minPositive({#x, #y, #z}) == #y then
      use.card:addSubcards(table.filter(switcher:getCardIds("ej"), function (id) return Fk:getCardById(id).color == Card.Red end))
    elseif minPositive({#x, #y, #z}) == #z then
      use.card:addSubcards(table.filter(switcher:getCardIds("ej"), function (id) return Fk:getCardById(id).color == Card.NoColor end))
    end
    use.extra_data = use.extra_data or {}
    use.extra_data.steam__shijie = use.extra_data.steam__shijie or {}
    table.insertIfNeed(use.extra_data.steam__shijie, switcher)
  end,
  enabled_at_play = function(self, player)
    return player:usedSkillTimes(shijie.name, Player.HistoryPhase) == 0 and #shijieMatch() > 0
  end,
})

shijie:addEffect(fk.CardUseFinished, {
  can_refresh = function(self, event, target, player, data)
    return target == player and data.extra_data and data.extra_data.steam__shijie
  end,
  on_refresh = function (self, event, target, player, data)
    for _, p in ipairs (player.room.alive_players) do
      if not p.dead and table.contains(data.extra_data.steam__shijie, p) and table.contains(data.tos, p) then
        player.room:loseHp(p, 1, shijie.name)
        DIY.removePlayer(p, "-turn")
      end
    end
  end,
})

shijie:addEffect(fk.RoundEnd, {
  anim_type = "special",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(shijie.name) and #shijieMatch() > 0
  end,
  on_cost = function (self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {skill_name = shijie.name, prompt ="#steam__shijie-invoke"})
  end,
  on_use = function (self, event, target, player, data)
    while not player.dead and #shijieMatch() > 0 do
      local success, dat = player.room:askToUseActiveSkill(player, {
        skill_name = shijie.name,
        cancelable = true,
      })
      if success and dat then
        local card = Fk:cloneCard(dat.interaction)
        card.skillName = shijie.name
        local switcher = player.room:askToChoosePlayers(player, {
          targets = shijieMatch(),
          min_num = 1,
          max_num = 1,
          prompt = "#steam__shijie-choose",
          skill_name = shijie.name,
          cancelable = false,
          target_tip_name = shijie.name,
        })[1]
        local x = table.filter(switcher:getCardIds("ej"), function (id) return Fk:getCardById(id).color == Card.Black end)
        local y = table.filter(switcher:getCardIds("ej"), function (id) return Fk:getCardById(id).color == Card.Red end)
        local z = table.filter(switcher:getCardIds("ej"), function (id) return Fk:getCardById(id).color == Card.NoColor end)
        if minPositive({#x, #y, #z}) == #x then
          card:addSubcards(table.filter(switcher:getCardIds("ej"), function (id) return Fk:getCardById(id).color == Card.Black end))
        elseif minPositive({#x, #y, #z}) == #y then
          card:addSubcards(table.filter(switcher:getCardIds("ej"), function (id) return Fk:getCardById(id).color == Card.Red end))
        elseif minPositive({#x, #y, #z}) == #z then
          card:addSubcards(table.filter(switcher:getCardIds("ej"), function (id) return Fk:getCardById(id).color == Card.NoColor end))
        end
        player.room:useCard{
          from = player,
          tos = dat.targets,
          card = card,
          extraUse = true,
          extra_data = {
            steam__shijie = {switcher}
          }
        }
      else
        break
      end
    end
    player.room:handleAddLoseSkills(player, "-"..shijie.name)
  end,
})

return shijie
