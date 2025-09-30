local xieguo = fk.CreateSkill {
  name = "steam__xieguo",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["steam__xieguo"] = "械国",
  [":steam__xieguo"] = "锁定技，游戏开始时，你随机使用两张装备牌。",

  ["$steam__xieguo1"] = "这点小菜还不够填牙缝的。",
  ["$steam__xieguo2"] = "哦？要我亲自动手吗？",
}

xieguo:addEffect(fk.GameStart, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(xieguo.name)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local equipMap = {}
    for _, id in ipairs(room.draw_pile) do
      local sub_type = Fk:getCardById(id).sub_type
      if Fk:getCardById(id).type == Card.TypeEquip and player:canUseTo(Fk:getCardById(id), player) then
        local list = equipMap[tostring(sub_type)] or {}
        table.insert(list, id)
        equipMap[tostring(sub_type)] = list
      end
    end
    local sub_types = {}
    for k, _ in pairs(equipMap) do
      table.insert(sub_types, k)
    end
    sub_types = table.random(sub_types, 2)
    local cards = {}
    for _, sub_type in ipairs(sub_types) do
      table.insert(cards, table.random(equipMap[sub_type]))
    end
    if #cards > 0 then
      for _, id in ipairs(cards) do
        if not player.dead and player:canUseTo(Fk:getCardById(id), player) then
          room:useCard{
            from = player,
            tos = { player },
            card = Fk:getCardById(id),
          }
        end
      end
    end
  end,
})

return xieguo
