local skel = fk.CreateSkill {
  name = "steam__zhenyu",
}

Fk:loadTranslationTable{
  ["steam__zhenyu"] = "镇御",
  [":steam__zhenyu"] = "一名角色受到伤害后，你可以弃置其装备区一张牌，令其回复1点体力，若为“补筑”牌，其摸牌至体力上限（至多摸5张）；否则你失去1点体力。",

  ["#steam__zhenyu-invoke"] = "镇御:你可以弃置 %src 装备区一张牌，令其回复1点体力",
  ["#steam__zhenyu-bad"] = "镇御:你可以弃置 %src 装备区一张牌，令其回复1点体力，然后你失去1体力",
}

skel:addEffect(fk.Damaged, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(skel.name) and not target.dead and #target:getCardIds("e") > 0
  end,
  on_cost = function (self, event, target, player, data)
    local prompt = "#steam__zhenyu-invoke:"..target.id
    if not table.find(target:getCardIds("e"), function (id) -- 宝宝贴士
      return Fk:getCardById(id):getMark("@@steam__buzhu_card") ~= 0
    end) then
      prompt = "#steam__zhenyu-bad:"..target.id
    end
    if player.room:askToSkillInvoke(player, { skill_name = skel.name, prompt = prompt }) then
      event:setCostData(self, {tos = {target}})
      return true
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local equps = target:getCardIds("e")
    local cid = equps[1]
    if #equps > 1 then -- 区分“补筑”牌和其他装备
      local good, normal = {}, {}
      for _, id in ipairs(equps) do
        if Fk:getCardById(id):getMark("@@steam__buzhu_card") ~= 0 then
          table.insert(good, id)
        else
          table.insert(normal, id)
        end
      end
      local card_data = {}
      if #normal > 0 then
        table.insert(card_data, { "$Equip", normal })
      end
      if #good > 0 then
        table.insert(card_data, { "@@steam__buzhu_card", good })
      end
      cid = room:askToChooseCard(player, {
        target = target, skill_name = skel.name, flag = {
          card_data = card_data
        }
      })
    end
    local good = Fk:getCardById(cid):getMark("@@steam__buzhu_card") ~= 0
    room:throwCard({cid}, skel.name, target, player)
    if not target.dead then
      room:recover { num = 1, skillName = skel.name, who = target, recoverBy = player }
    end
    if good then
      if not target.dead then
        local x = math.min(5, target.maxHp - target:getHandcardNum())
        if x > 0 then
          target:drawCards(x, skel.name)
        end
      end
    else
      if not player.dead then
        room:loseHp(player, 1, skel.name)
      end
    end
  end,
})

--- 检测是否因为“补筑”而移入装备区
skel:addEffect(fk.AfterCardsMove, {
  can_refresh = function(self, event, target, player, data)
    return player.seat == 1
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    local skillCheck = function ()
      local currentEvent = room.logic:getCurrentEvent()
      if currentEvent.parent and currentEvent.parent.event == GameEvent.UseCard then
        local skillEvent = currentEvent.parent.parent
        return skillEvent and skillEvent.event == GameEvent.SkillEffect
        and skillEvent.data and skillEvent.data.skill.name == "steam__buzhu"
      end
    end
    for _, move in ipairs(data) do
      for _, info in ipairs(move.moveInfo) do
        if info.fromArea == Player.Equip then
          if Fk:getCardById(info.cardId):getMark("@@steam__buzhu_card") ~= 0 then
            room:setCardMark(Fk:getCardById(info.cardId), "@@steam__buzhu_card", 0)
          end
        end
      end
      if move.toArea == Player.Equip then
        if skillCheck() then
          for _, info in ipairs(move.moveInfo) do
            room:setCardMark(Fk:getCardById(info.cardId), "@@steam__buzhu_card", 1)
          end
        end
      end
    end
  end,
})



return skel
