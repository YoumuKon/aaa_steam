local bufo = fk.CreateSkill{
    name = "steam__bufo",
    tags = {Skill.Compulsory}
}
Fk:loadTranslationTable{
    ["steam__bufo"] = "不佛",
    [":steam__bufo"] = "锁定技，回合开始时，你对距离1的角色各造成1点火焰伤害。当你受到大于1点的伤害时，此伤害-1。",

    ["$steam__bufo1"] = "我不入地狱，谁入地狱？",
}

bufo:addEffect(fk.TurnStart, {
    can_trigger = function (self, event, target, player, data)
        if target == player and player:hasSkill(bufo.name) then
            return table.find(player.room.alive_players, function (tp)
                return player:distanceTo(tp) == 1
            end)
        end
    end,
    on_use = function (self, event, target, player, data)
        local room = player.room
        for _, tp in ipairs(room:getOtherPlayers(player)) do
            if player:distanceTo(tp) == 1 then
                room:damage{
                    from = player,
                    to = tp,
                    damage = 1,
                    skillName = bufo.name,
                    damageType = fk.FireDamage
                }
            end
        end
    end,
})

bufo:addEffect(fk.DetermineDamageInflicted, {
    can_trigger = function(self, event, target, player, data)
        return target == player and player:hasSkill(bufo.name) and data.damage > 1
    end,
    on_use = function(self, event, target, player, data)
        data:changeDamage(1 - data.damage)
    end,
})

return bufo