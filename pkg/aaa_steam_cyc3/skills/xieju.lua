local xieju = fk.CreateSkill{
    name = "steam__xieju",
    tags = {Skill.Wake}
}
Fk:loadTranslationTable{
    ["steam__xieju"] = "偕举",
    [":steam__xieju"] = "觉醒技，一号位的体力值降至低于你后，你摸一张武器牌，并令至多X名角色各获得一个共通发动次数的〖卫境〗。（X为此武器的攻击范围）",
    ["#steam__xieju"] = "偕举：令至多%arg名角色各获得一个共通发动次数的〖卫境〗",

    ["$steam__xieju1"] = "孛星起于吴楚，吾等应举刀兵！",
    ["$steam__xieju2"] = "尽点淮南兵马，以讨司马逆臣！",
}

xieju:addEffect(fk.HpChanged, {
    can_trigger = function (self, event, target, player, data)
        return player:hasSkill(xieju.name) and data.num < 0 and player:usedSkillTimes(xieju.name, Player.HistoryGame) == 0
    end,
    can_wake = function (self, event, target, player, data)
        return target.hp < player.hp and target.seat == 1
    end,
    on_use = function (self, event, target, player, data)
        local room = player.room
        local cards = player.room:getCardsFromPileByRule(".|.|.|.|.|weapon", 1, "allPiles")
        if #cards > 0 then
            room:obtainCard(player, cards[1], true, fk.ReasonDraw, player, xieju.name)
            if player.dead then return false end
            local weapon = Fk:getCardById(cards[1]) ---@class Weapon
            local num = weapon:getAttackRange(player)
            if num > 0 then
                local tos = room:askToChoosePlayers(player, {
                    skill_name = xieju.name,
                    min_num = 1,
                    max_num = num,
                    cancelable = true,
                    targets = room:getAlivePlayers(),
                    prompt = "#steam__xieju:::"..num,
                })
                if #tos > 0 then
                    for _, cp in ipairs(tos) do
                        room:handleAddLoseSkills(cp, "steam__weijing")
                    end
                end
            end
        end
    end,
})

return xieju