local guanche = fk.CreateSkill{
    name = "steam__guanche",
}
Fk:loadTranslationTable{
    ["steam__guanche"] = "贯掣",
    [":steam__guanche"] = "你使用即时牌的目标每放弃响应一次，你便可明置其或其一名邻家的手牌；相同花色牌被使用后，你暗置这些牌并摸一张牌。",
    ["#steam__guanche"] = "是否发动 贯掣，明置%dest或其一名邻家的手牌",

    ["$steam__guanche1"] = "我看见你了。",
    ["$steam__guanche2"] = "真显眼。",
}
local DIY = require "packages.diy_utility.diy_utility"
local spec = {
    on_cost = function (self, event, target, player, data)
        local room = player.room
        local targets = {}
        if target and target:isAlive() then
            if target:getHandcardNum() > 0 then table.insertIfNeed(targets,target) end
            local last, next = target:getLastAlive(), target:getNextAlive()
            if last:getHandcardNum() - #DIY.getShownCards(last) > 0 then table.insertIfNeed(targets,room:getPlayerById(last.id)) end
            if next:getHandcardNum() - #DIY.getShownCards(next) > 0 then table.insertIfNeed(targets,room:getPlayerById(next.id)) end
            if #targets > 0 then
                local tos = player.room:askToChoosePlayers(player,{
                    max_num = 1,
                    min_num = 1,
                    targets = targets,
                    skill_name = guanche.name,
                    prompt = "#steam__guanche::"..target.id
                })
                if #tos > 0 then
                    event:setCostData(self,tos)
                    return true
                end
            end
        end
    end,
    on_use = function(self, event, target, player, data)
        local room = player.room
        local to = event:getCostData(self)[1]
        local shown = table.filter(to:getCardIds("h"), function (id)
            return not table.contains(DIY.getShownCards(to), id)
        end)
        local mark = player:getTableMark(guanche.name)
        mark[data.eventData.card:getSuitString()] = mark[data.eventData.card:getSuitString()] or {}
        table.insertTableIfNeed(mark[data.eventData.card:getSuitString()],shown)
        room:setPlayerMark(player,guanche.name,mark)
        DIY.showCards(to,shown)
    end,
}
guanche:addEffect(fk.AfterAskForCardUse, {
    can_trigger = function(self, event, target, player, data)
        return player:hasSkill(guanche.name) and data.eventData and data.eventData.from == player and
        data.eventData.tos and table.contains(data.eventData.tos,target) and
        (data.eventData.card.type == Card.TypeBasic or data.eventData.card:isCommonTrick()) and
        not (data.result and data.result.from == target)
    end,
    on_cost = spec.on_cost,
    on_use = spec.on_use,
})
guanche:addEffect(fk.AfterAskForCardResponse, {
    can_trigger = function(self, event, target, player, data)
        return player:hasSkill(guanche.name) and data.eventData and data.eventData.from == player and
        data.eventData.tos and table.contains(data.eventData.tos,target) and
        (data.eventData.card.type == Card.TypeBasic or data.eventData.card:isCommonTrick()) and
        not data.result
    end,
    on_cost = spec.on_cost,
    on_use = spec.on_use,
})
guanche:addEffect(fk.AfterAskForNullification, {
    can_trigger = function(self, event, target, player, data)
        return player:hasSkill(guanche.name) and data.eventData and data.eventData.from == player and
        data.eventData.tos and table.contains(data.eventData.tos,target) and
        (data.eventData.card.type == Card.TypeBasic or data.eventData.card:isCommonTrick()) and
        not (data.result and data.result.from == target)
    end,
    on_cost = spec.on_cost,
    on_use = spec.on_use,
})
guanche:addEffect(fk.CardUsing,{
    can_refresh = function (self, event, target, player, data)
        local mark = player:getTableMark(guanche.name)
        for key, value in pairs(mark) do
            if key == data.card:getSuitString() and #value > 0 then
                return true
            end
        end
    end,
    on_refresh = function (self, event, target, player, data)
        local room = player.room
        local mark = player:getTableMark(guanche.name)
        for _, cp in ipairs(room.alive_players) do
            local hidden = {}
            for key, value in pairs(mark) do
                if key == data.card:getSuitString() and #value > 0 then
                    for _, id in ipairs(cp:getCardIds("h")) do
                        if table.contains(value,id) then
                            table.insertIfNeed(hidden,id)
                        end
                    end
                end
            end
            if #hidden > 0 then
                room:doIndicate(player,cp)
                DIY.hideCards(cp,hidden)
                player:drawCards(1,guanche.name)
            end
        end
        mark[data.card:getSuitString()] = {}
        room:setPlayerMark(player,guanche.name,mark)
    end,
})
return guanche