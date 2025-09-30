local zhuisuo = fk.CreateSkill{
    name = "steam__zhuisuo",
}
Fk:loadTranslationTable{
    ["steam__zhuisuo"] = "追索",
    [":steam__zhuisuo"] = "出牌阶段结束时，若你本阶段仅对一名其他角色使用过牌，你可以摸一张牌并与其拼点：若其没赢，你永久增加一个仅能对你与其用牌的额外出牌阶段，且此后不能再与其拼点。",
    ["#steam__zhuisuo-invoked"] = "追索：是否与 %dest 拼点，有可能获得一个额外的出牌阶段",
    ["@[player]steam__zhuisuo"] = "追索",

    ["$steam__zhuisuo1"] = "九黎兴兵，不向南中百族。",
    ["$steam__zhuisuo2"] = "南中出军，锋指山外之人。",
}

zhuisuo:addEffect(fk.EventPhaseEnd, {
    can_trigger = function (self, event, target, player, data)
        if player == target and player:hasSkill(zhuisuo.name) and player.phase == player.Play then
            local targets = {}
            player.room.logic:getEventsOfScope(GameEvent.UseCard, 1, function (e)
                local use = e.data
                if use.from == player and table.find(use.tos, function(p)
                    return p ~= player
                end) then
                    table.insertTableIfNeed(targets, table.filter(use.tos, function(p)
                        return p ~= player
                    end))
                end
            end, Player.HistoryTurn)
            if #targets == 1 and not table.contains(player:getTableMark("@[player]steam__zhuisuo"), targets[1].id) and player:canPindian(targets[1], true) then
                event:setCostData(self, targets[1])
                return true
            end
        end
    end,
    on_cost = function (self, event, target, player, data)
        if player.room:askToSkillInvoke(player, {
            skill_name = zhuisuo.name,
            prompt = "#steam__zhuisuo-invoked::"..event:getCostData(self).id
        }) then
            return true
        end
    end,
    on_use = function (self, event, target, player, data)
        local room = player.room
        local to = event:getCostData(self)
        player:drawCards(1, zhuisuo.name)
        if player:canPindian(to) then
            local pindian = player:pindian({to}, zhuisuo.name)
            if pindian and pindian.results[to] then
            local winner = pindian.results[to].winner
                if winner ~= to then
                    room:addTableMarkIfNeed(player, "@[player]steam__zhuisuo", to.id)
                end
            end
        end
    end,
})

zhuisuo:addEffect(fk.EventPhaseEnd, {
    is_delay_effect = true,
    priority = 0.001,
    can_trigger = function (self, event, target, player, data)
        return target == player and player.phase == Player.Play and #table.filter(player:getTableMark("@[player]steam__zhuisuo"),function (element)
            return not table.contains(player:getTableMark("steam__zhuisuo-turn"), element)
        end) > 0
    end,
    on_trigger = function (self, event, target, player, data)
        local room = player.room
        local mark = table.filter(player:getTableMark("@[player]steam__zhuisuo"),function (element)
            return not table.contains(player:getTableMark("steam__zhuisuo-turn"), element)
        end)
        room:addTableMarkIfNeed(player, "steam__zhuisuo-turn", mark[1])
        player:gainAnExtraPhase(Player.Play, zhuisuo.name, true, { steam__zhuisuo = mark[1] })
    end,
})

zhuisuo:addEffect(fk.EventPhaseStart, {
    can_refresh = function (self, event, target, player, data)
        return target == player and player.phase == Player.Play and data.reason == zhuisuo.name
    end,
    on_refresh = function (self, event, target, player, data)
        player.room:setPlayerMark(player, "steam__zhuisuo-phase", data.extra_data.steam__zhuisuo)
    end,
})

zhuisuo:addEffect("prohibit", {
    is_prohibited = function(self, from, to, card)
        return from:getMark("steam__zhuisuo-phase") ~= 0 and from.phase == Player.Play and to ~= from and to.id ~= from:getMark("steam__zhuisuo-phase")
    end,
})

return zhuisuo