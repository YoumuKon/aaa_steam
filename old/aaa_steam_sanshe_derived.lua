local extension = Package:new("aaa_steam_sanshe_derived", Package.CardPack)
extension.extensionName = "aaa_steam"

Fk:loadTranslationTable{
  ["aaa_steam_sanshe_derived"] = "散设",
}

local U = require "packages.utility.utility"

local enemyAtTheGatesSkill = fk.CreateActiveSkill{--修改自汗青的兵临城下
  name = "steam_ss__enemy_at_the_gates_skill",
  prompt = "#steam_ss__enemy_at_the_gates_skill",
  can_use = Util.CanUse,
  target_num = 1,
  mod_target_filter = function(self, to_select, selected, player, card)
    return to_select ~= player.id
  end,
  target_filter = function(self, to_select, selected, _, card, extra_data, player)
    return Util.TargetFilter(self, to_select, selected, _, card, extra_data, player) and
      self:modTargetFilter(to_select, selected, player, card)
  end,
  on_effect = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.to)
    effect.extra_data = effect.extra_data or {}
    effect.extra_data.ids = effect.extra_data.ids or {} --指定展示的牌
    local n,cards
    if #effect.extra_data.ids ~= 0 then
      cards = effect.extra_data.ids
    else
      n = 4 + (effect.extra_data.num or 0)--负值可展示4以下张牌?
      if n < 1 then return end
      cards = room:getNCards(n, effect.extra_data.fromArea or "top")
    end
    effect.extra_data.EXenemy_at_the_gates = cards
    room:moveCardTo(cards, Card.Processing, nil, fk.ReasonJustMove, self.name, nil, true, player.id)
    cards = effect.extra_data.EXenemy_at_the_gates
    local rest = {}
    while not target.dead do
      cards = table.filter(cards, function (id)
        return room:getCardArea(id) == Card.Processing
      end)
      if #cards == 0 then break end
      room:delay(800)
      local card = Fk:getCardById(cards[1])
      if card.trueName == "slash" and player:canUseTo(card, target, {bypass_distances = true, bypass_times = true}) then
        room:useCard({
          card = card,
          from = player.id,
          tos = {{target.id}},
          extraUse = true,
        })
      else
        table.insert(rest, cards[1])
        table.remove(cards, 1)
      end
    end
    rest = table.filter(rest, function (id)
      return room:getCardArea(id) == Card.Processing
    end)
    if #rest > 0 then
      local toArea = effect.extra_data.toArea
      if toArea == "top" then
        room:moveCards({
          ids = table.reverse(rest), toArea = Card.DrawPile, moveReason = fk.ReasonPut,
        })
      elseif toArea == "bottom" then
        room:moveCards({
          ids = rest, toArea = Card.DrawPile, moveReason = fk.ReasonPut, drawPilePosition = -1,
        })
      else
        room:moveCards({
          ids = rest,
          toArea = Card.DiscardPile,
          moveReason = fk.ReasonPutIntoDiscardPile,
        })
      end
    end
  end,
}

local enemyAtTheGates = fk.CreateTrickCard{
  name = "&steam_ss__enemy_at_the_gates",
  suit = Card.Spade,
  number = 7,
  skill = enemyAtTheGatesSkill,
}
extension:addCards{
  enemyAtTheGates,
}
Fk:loadTranslationTable{
  ["steam_ss__enemy_at_the_gates"] = "兵临城下",
  [":steam_ss__enemy_at_the_gates"] = "锦囊牌<br /><b>时机</b>：出牌阶段<br /><b>目标</b>：一名其他角色<br /><b>效果</b>：你展示牌堆顶的四张牌，依次对目标角色使用其中的【杀】，然后将其余的牌以原顺序放回牌堆顶。",
  ["#steam_ss__enemy_at_the_gates_skill"] = "选择一名其他角色，你展示牌堆顶四张牌，依次对其使用其中【杀】，其余牌放回牌堆顶",
  ["steam_ss__enemy_at_the_gates_skill"] = "兵临城下",
}


return extension
