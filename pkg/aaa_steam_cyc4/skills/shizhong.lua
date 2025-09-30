local shizhong = fk.CreateSkill{
    name = "steam__shizhong",
}
Fk:loadTranslationTable{
    ["steam__shizhong"] = "矢终",
    [":steam__shizhong"] = "有明置牌的角色视为在你的攻击范围内。你使用【杀】指定上述角色为唯一目标时，可以改为将之交换其一张手牌并明置；当前回合和轮次结束时，若其手中此牌仍明置，你对其造成1点雷电伤害。",
    ["#steam__shizhong"] = "是否发动 矢终，用 %arg 交换 %dest 一张手牌并明置",

    ["$steam__shizhong1"] = "让他们有来无回。",
    ["$steam__shizhong2"] = "他们跑不了。",
}
local DIY = require "packages/diy_utility/diy_utility"
local function tableSize(t)
    local tempCount = 0
    for _, _ in pairs(t) do
        tempCount = tempCount + 1
    end
    return tempCount
end
shizhong:addEffect(fk.AfterCardTargetDeclared,{
    can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(shizhong.name) and
        data.card.trueName == "slash" and data:isOnlyTarget(data.tos[1]) and data.tos[1] ~= player and
        #DIY.getShownCards(data.tos[1]) > 0 and #player.room:getSubcardsByRule(data.card, { Card.Processing }) > 0
    end,
    on_cost = function (self, event, target, player, data)
        if player.room:askToSkillInvoke(player,{
            skill_name = shizhong.name,
            prompt = "#steam__shizhong::"..data.tos[1].id..":"..data.card:toLogString()
        }) then
            return true
        end
    end,
    on_use = function (self, event, target, player, data)
        local room = player.room
        local to = data.tos[1]
        local ids = room:getSubcardsByRule(data.card, { Card.Processing })
        local card = room:askToChooseCard(player, {
            target = to,
            flag = "h",
            skill_name = shizhong.name,
        })
        room:swapCards(player,{{player,ids},{to,{card}}},shizhong.name)
        DIY.showCards(to,ids)
        local mark1, mark2 = player:getTableMark("steam__shizhong-turn"), player:getTableMark("steam__shizhong-round")
        mark1[tostring(to.id)] = mark1[tostring(to.id)] or {}
        mark2[tostring(to.id)] = mark2[tostring(to.id)] or {}
        for _, id in ipairs(ids) do
            table.insert(mark1[tostring(to.id)],id)
            table.insert(mark2[tostring(to.id)],id)
        end
        room:setPlayerMark(player,"steam__shizhong-turn",mark1)
        room:setPlayerMark(player,"steam__shizhong-round",mark2)
        data:removeAllTargets()
    end,
})
shizhong:addEffect(fk.TurnEnd,{
    can_refresh = function (self, event, target, player, data)
        return tableSize(player:getTableMark("steam__shizhong-turn")) > 0
    end,
    on_refresh = function (self, event, target, player, data)
        local room = player.room
        local mark = player:getTableMark("steam__shizhong-turn")
        for key, value in pairs(mark) do
            local to = room:getPlayerById(math.tointeger(tonumber(key)))
            if to:isAlive() and table.find(DIY.getShownCards(to),function (id)
                return table.contains(value,id)
            end) then
                room:damage{
                    to = to,
                    from = player,
                    damage = 1,
                    damageType = fk.ThunderDamage,
                    skillName = shizhong.name
                }
            end
        end
    end,
})
shizhong:addEffect(fk.RoundEnd,{
    can_refresh = function (self, event, target, player, data)
        return tableSize(player:getTableMark("steam__shizhong-round")) > 0
    end,
    on_refresh = function (self, event, target, player, data)
        local room = player.room
        local mark = player:getTableMark("steam__shizhong-round")
        for key, value in pairs(mark) do
            local to = room:getPlayerById(math.tointeger(tonumber(key)))
            if to:isAlive() and table.find(DIY.getShownCards(to),function (id)
                return table.contains(value,id)
            end) then
                room:damage{
                    to = to,
                    from = player,
                    damage = 1,
                    damageType = fk.ThunderDamage,
                    skillName = shizhong.name
                }
            end
        end
    end,
})
shizhong:addEffect("atkrange", {
    within_func = function (self, from, to)
        return from:hasSkill(shizhong.name) and #DIY.getShownCards(to) > 0
    end,
})
return shizhong