local skels = {}

local yulun = fk.CreateSkill{
    name = "steam__yulun",
    tags = {Skill.Wake},
}
Fk:loadTranslationTable{
    ["steam__yulun"] = "狱轮",
    [":steam__yulun"] = "觉醒技，当你脱离受伤或濒死状态后，你<a href='#RuMoDesc'><font color='red'>入魔</font></a>并获得〖不佛〗。",
    ["#RuMoDesc"] = "入魔是每局游戏限一次的操作，入魔后，每轮结束时，若本轮你未造成过伤害，你失去1点体力。",
}

yulun:addEffect(fk.HpChanged, {
    anim_type = "big",
    can_trigger = function (self, event, target, player, data)
        return target == player and player:hasSkill(yulun.name) and player:usedSkillTimes(yulun.name, Player.HistoryGame) == 0
    end,
    can_wake = function (self, event, target, player, data)
        return data.num > 0 and not player:isWounded()
    end,
    on_use = function (self, event, target, player, data)
        local room = player.room
        if Fk.skills["#rumo"] and not player:hasSkill("#rumo", true) then
            room:handleAddLoseSkills(player, "#rumo", nil, false, true)
        end
        room:handleAddLoseSkills(player, "steam__bufo")
    end,
})

yulun:addEffect(fk.AfterDying, {
    anim_type = "big",
    can_trigger = function (self, event, target, player, data)
        return target == player and player:hasSkill(yulun.name) and player:usedSkillTimes(yulun.name, Player.HistoryGame) == 0
    end,
    can_wake = Util.TrueFunc,
    on_use = function (self, event, target, player, data)
        local room = player.room
        if Fk.skills["#rumo"] and not player:hasSkill("#rumo", true) then
            room:handleAddLoseSkills(player, "#rumo", nil, false, true)
        end
        room:handleAddLoseSkills(player, "steam__bufo")
    end,
})

table.insert(skels, yulun)

if not Fk.skills["#rumo"] then
    local rumo = fk.CreateSkill {
        name = "#rumo",
    }

    Fk:loadTranslationTable{
        ["#rumo"] = "入魔",
    }

    rumo:addEffect(fk.RoundEnd, {
        anim_type = "negative",
        is_delay_effect = true,
        can_trigger = function (self, event, target, player, data)
            return
            player:hasSkill(rumo.name, true) and
            #player.room.logic:getActualDamageEvents(1, function (e)
                return e.data.from == player
            end, Player.HistoryRound) == 0
        end,
        on_use = function (self, event, target, player, data)
            player.room:loseHp(player, 1, rumo.name)
        end,
    })

    table.insert(skels, rumo)
end

return skels