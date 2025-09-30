local juzhai = fk.CreateSkill{
    name = "steam__juzhai",
}
Fk:loadTranslationTable{
    ["steam__juzhai"] = "据寨",
    [":steam__juzhai"] = "轮次开始时，你可以重铸任意张牌，然后本轮与其他角色计算距离时-X。（X为因此失去和获得的装备牌数）",
    ["#steam__juzhai"] = "据寨：你可以重铸任意张牌",

    ["@steam__juzhai-round"] = "据寨",
}

juzhai:addEffect(fk.RoundStart, {
    anim_type = "drawcard",
    can_trigger = function (self, event, target, player, data)
        return player:hasSkill(juzhai.name) and not player:isAllNude()
    end,
    on_cost = function (self, event, target, player, data)
        local cards = player.room:askToCards(player, {
            skill_name = juzhai.name,
            pattern = ".",
            min_num = 1,
            max_num = #player:getCardIds("he"),
            prompt = "#steam__juzhai",
        })
        if #cards > 0 then
            event:setCostData(self, {cards = cards})
            return true
        end
    end,
    on_use = function (self, event, target, player, data)
        local room = player.room
        local cards = event:getCostData(self).cards
        local num = #table.filter(cards, function (cardID)
            return Fk:getCardById(cardID, true).type == Card.TypeEquip
        end)
        local cards2 = room:recastCard(cards, player, juzhai.name)
        num = num + #table.filter(cards2, function (cardID)
            return Fk:getCardById(cardID, true).type == Card.TypeEquip
        end)
        room:setPlayerMark(player, "@steam__juzhai-round", num)
    end,
})

juzhai:addEffect("distance", {
    correct_func = function(self, from, to)
        if from:hasSkill(juzhai.name) and from:getMark("@steam__juzhai-round") > 0 then
            return -from:getMark("@steam__juzhai-round")
        end
    end,
})

return juzhai