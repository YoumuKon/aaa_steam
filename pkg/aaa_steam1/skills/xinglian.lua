local skel = fk.CreateSkill {
  name = "steam__xinglian",
  tags = {Skill.Compulsory},
}

local pilename = "@[steam__xinglian]"

Fk:loadTranslationTable{
  ["steam__xinglian"] = "星链",
  [":steam__xinglian"] = "锁定技，准备阶段，若你无星链牌，你将牌堆顶的四张牌置于武将牌上。你不因此技能获得牌后，你可用一张手牌替换一张星链牌；然后若星链牌的点数之和等于24，你获得这些牌。",

  [pilename] = "星链",
  ["#steam__xinglian-invoke"] = "星链：你可用一张手牌替换一张星链牌，若星链牌点数和为24，你获得之",
  ["#steam__xinglian-exchange"] = "用一张手牌替换一张星链牌，当前星链点数和：%arg",
}

Fk:addQmlMark{
  name = "steam__xinglian",
  how_to_show = function(name, value, p)
    local num = 0
    for _, id in ipairs(p:getPile(pilename)) do
      num = num + Fk:getCardById(id).number
    end
    if num > 0 then
      return tostring(num) .. " 点"
    end
    return " "
  end,
  qml_path = "packages/utility/qml/ViewPile"
}

Fk:addPoxiMethod{
  name = "steam__xinglian",
  prompt = function (data)
    if not data then return " " end
    local num = 0
    for _, id in ipairs((data[1])[2]) do
      num = num + Fk:getCardById(id).number
    end
    return "#steam__xinglian-exchange:::" .. num
  end,
  card_filter = function (to_select, selected, data)
    if data and #selected < 2 then
      for _, id in ipairs(selected) do
        for _, v in ipairs(data) do
          if table.contains(v[2], id) and table.contains(v[2], to_select) then
            return false
          end
        end
      end
      return true
    end
  end,
  feasible = function(selected, data)
    return data and #selected == 2
  end,
  default_choice = function(data)
    if not data then return {} end
    local cids = table.map(data, function(v) return v[2][1] end)
    return cids
  end,
}

skel:addEffect(fk.EventPhaseStart, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(skel.name) then
      return player.phase == Player.Start and #player:getPile(pilename) == 0
    end
  end,
  on_use = function(self, event, target, player, data)
    player:addToPile(pilename, player.room:getNCards(4), true, skel.name)
  end,
})

skel:addEffect(fk.AfterCardsMove, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(skel.name) and #player:getPile(pilename) > 0 and not player:isKongcheng() then
      for _, move in ipairs(data) do
        if move.to == player and move.toArea == Player.Hand and move.skillName ~= skel.name then
          return true
        end
      end
    end
  end,
  on_cost = function (self, event, target, player, data)
    return player.room:askToSkillInvoke(player, { skill_name = skel.name, prompt = "#steam__xinglian-invoke"})
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local card_data = {
      {pilename, player:getPile(pilename)},
      {"$Hand", player:getCardIds("h")},
    }
    local cards = room:askToPoxi(player, {
      poxi_type = skel.name,
      data = card_data,
      cancelable = false,
    })
    if #cards ~= 2 then return end
    local put, get = {cards[1]}, {cards[2]}
    if table.contains(player:getPile(pilename), put[1]) then
      put, get = get, put
    end
    room:swapCardsWithPile(player, put, get, skel.name, pilename)
    if player.dead then return end
    local num = 0
    for _, id in ipairs(player:getPile(pilename)) do
      num = num + Fk:getCardById(id).number
    end
    if num == 24 then
      room:delay(700)
      room:obtainCard(player, player:getPile(pilename), true, fk.ReasonJustMove, player, skel.name)
    end
  end,
})

return skel
