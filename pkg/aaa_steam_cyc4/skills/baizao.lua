local baizao = fk.CreateSkill {
  name = "steam__baizao",
  dynamic_desc = function(self, player)
    local mark = player:getTableMark("steam__baizao-round")
    local first = table.contains(mark, 1) and "<a href=':steam__isEdible'>可食用牌</a><font color='red'>（已发动）</font>" or "<a href=':steam__isEdible'>可食用牌</a>"
    local second = table.contains(mark, 2) and "<a href=':steam__isElement'>属性牌</a><font color='red'>（已发动）</font>" or "<a href=':steam__isElement'>属性牌</a>"
    return "每轮各限一次，一名角色使用一张"..first.."/"..second.."结算后，你可以打出一张另一项，摸两张牌并令一名角色使用一张<a href=':steam_baizao_equip'>【家常小炒】</a>。"
  end,
}

Fk:loadTranslationTable{
  ["steam__baizao"] = "百灶",
  [":steam__baizao"] = "每轮各限一次，一名角色使用一张<a href=':steam__isEdible'>可食用牌</a>/<a href=':steam__isElement'>属性牌</a>结算后，你可以打出一张另一项，"..
  "摸两张牌并令一名角色使用一张<a href=':steam_baizao_equip'>【家常小炒】</a>。",
  ["#steam__baizao-invoke1"] = "百灶：是否打出一张属性牌？",
  ["#steam__baizao-invoke2"] = "百灶：是否打出一张可食用牌？",
  ["#steam__baizao-choice"] = "百灶：此牌符合两个分支的条件，请选择一项（选择后若不打出牌则取消发动，不计入分支次数限制）",
  ["#steam__baizao-eat"] = "此牌为可食用牌，打出属性牌执行后续",
  ["#steam__baizao-ele"] = "此牌为属性牌，打出可食用牌执行后续",
  ["#steam__baizao-choose"] = "百灶：令一名角色使用一张【家常小炒】！",
  [":steam__isEdible"] = "可食用牌：桃，酒，散，南蛮入侵，顺手牵羊，桃园结义，五谷丰登，决斗，所有坐骑牌，木牛流马",
  [":steam__isElement"] = "属性牌：能造成属性伤害的伤害牌，以及被升烟修改过的伤害牌（【闪电】是否算属性牌有争议，暂时不用）",

  ["$steam__baizao1"] = "热锅冷油，火候正好。",
  ["$steam__baizao2"] = "排好队排好队，好菜多的是。",
}

---@param card Card
---@return boolean
--根据设计师给出的名单，穷举出的可食用牌牌表
local isEdible = function (card)
  local list = {"peach", "analeptic", "drugs", "duel", "snatch", "savage_assault", "amazing_grace", "god_salvation", "wooden_ox"}
  return card.sub_type == Card.SubtypeOffensiveRide or card.sub_type == Card.SubtypeDefensiveRide
  or table.contains(list, card.trueName)
end

---@param card Card
---@return boolean
--检索牌名中是否出现属性字眼，判断属性牌与否
local isElement = function (card)
  if card.is_damage_card then
    return string.find(Fk:translate(""..card.name, "zh_CN"), "火") ~= nil or
    string.find(Fk:translate(""..card.name, "zh_CN"), "雷") ~= nil or
    string.find(Fk:translate(""..card.name, "zh_CN"), "冰") ~= nil or
    string.find(Fk:translate(""..card.name, "zh_CN"), "水") ~= nil
  end
  return false
end

baizao:addEffect(fk.CardUseFinished, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    local mark = player:getTableMark("steam__baizao-round")
    return player:hasSkill(baizao.name) and not player:isAllNude() and ((isEdible(data.card) and not table.contains(mark, 1)) or
    ((isElement(data.card) or (data.extra_data and data.extra_data.steam__shengyan_damage)) and not table.contains(mark, 2)))
  end,
  on_cost = function (self, event, target, player, data)
    local mark = player:getTableMark("steam__baizao-round")
    local eat = isEdible(data.card) and not table.contains(mark, 1)
    local ele = (isElement(data.card) or (data.extra_data and data.extra_data.steam__shengyan_damage)) and not table.contains(mark, 2)
    local cards1 = table.filter(player:getCardIds("h"), function (id) return isElement(Fk:getCardById(id)) end)
    local cards2 = table.filter(player:getCardIds("h"), function (id) return isEdible(Fk:getCardById(id)) end)
    if eat and not ele then
      local respond = player.room:askToResponse(player, {
        skill_name = baizao.name,
        pattern = ".|.|.|hand|.|.|"..table.concat(cards1, ","),
        prompt = "#steam__baizao-invoke1",
        cancelable = true,
      })
      if respond then
        event:setCostData(self, {datas = respond, choice = 1})
        return true
      end
    elseif ele and not eat then
      local respond = player.room:askToResponse(player, {
        skill_name = baizao.name,
        pattern = ".|.|.|hand|.|.|"..table.concat(cards2, ","),
        prompt = "#steam__baizao-invoke2",
        cancelable = true,
      })
      if respond then
        event:setCostData(self, {datas = respond, choice = 2})
        return true
      end
    elseif ele and eat then
      local choice = player.room:askToChoice(player, {      
      choices = {"#steam__baizao-eat", "#steam__baizao-ele"},
      prompt = "#steam__baizao-choice",
      skill_name = baizao.name,})
      if choice == "#steam__baizao-eat" then
        local respond = player.room:askToResponse(player, {
          skill_name = baizao.name,
          pattern = ".|.|.|hand|.|.|"..table.concat(cards1, ","),
          prompt = "#steam__baizao-invoke1",
          cancelable = true,
        })
        if respond then
          event:setCostData(self, {datas = respond, choice = 1})
          return true
        end
      elseif choice == "#steam__baizao-ele" then
        local respond = player.room:askToResponse(player, {
          skill_name = baizao.name,
          pattern = ".|.|.|hand|.|.|"..table.concat(cards2, ","),
          prompt = "#steam__baizao-invoke2",
          cancelable = true,
        })
        if respond then
          event:setCostData(self, {datas = respond, choice = 2})
          return true
        end
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if event:getCostData(self).choice == 1 then
      room:addTableMarkIfNeed(player, "steam__baizao-round", 1)
    elseif event:getCostData(self).choice == 2 then
      room:addTableMarkIfNeed(player, "steam__baizao-round", 2)
    end
    room:responseCard(event:getCostData(self).datas)
    if not player.dead then
      player:drawCards(2, baizao.name)
      if not player.dead then
        local targets = table.filter(room.alive_players, function (p)
          return p:canUseTo(Fk:cloneCard("steam_baizao_equip", Card.Heart, 12), p)
        end)
        if #targets == 0 then return end
        local to = room:askToChoosePlayers(player, {
          min_num = 1,
          max_num = 1,
          targets = targets,
          skill_name = baizao.name,
          prompt = "#steam__baizao-choose",
          cancelable = false,
        })[1]
        local card = room:printCard("steam_baizao_equip", Card.Heart, 12)
        room:setCardMark(card, MarkEnum.DestructOutMyEquip, 1)
        room:useCard{
          from = to,
          tos = { to },
          card = card,
        }
      end
    end
  end,
})

return baizao
