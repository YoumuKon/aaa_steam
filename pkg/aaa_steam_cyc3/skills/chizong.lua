local chizong = fk.CreateSkill{
    name = "steam__chizong"
}
Fk:loadTranslationTable{
    ["steam__chizong"] = "赤宗",
    [":steam__chizong"] = "每回合限一次，你使用牌指定其他角色，或其他角色使用牌指定你为目标时，若没有濒死角色，你可以选择一名目标，令此牌对其按<a href=':steam_chizong__daggar_in_smile'>【笑里藏刀】</a>结算。",
    [":steam_chizong__daggar_in_smile"] = "<b>笑里藏刀</b>：出牌阶段，对一名其他角色使用。目标角色摸X张牌（X为其已损失体力值且至多为5），然后你对其造成1点伤害。",
    ["#steam__chizong"] = "赤宗：你可以令%arg对其中一个目标改为按【笑里藏刀】结算",
}

chizong:addEffect(fk.TargetSpecifying, {
    can_trigger = function (self, event, target, player, data)
        if player == target and player:hasSkill(chizong.name) and player:usedSkillTimes(chizong.name) == 0 then
            return data.firstTarget and table.find(data.tos, function (to)
                return to ~= player
            end) and not table.find(player.room.alive_players, function (tp)
                return tp.dying
            end)
        end
    end,
    on_cost = function (self, event, target, player, data)
        local tos = player.room:askToChoosePlayers(player, {
            targets = data:getAllTargets(),
            max_num = 1,
            min_num = 1,
            skill_name = chizong.name,
            prompt = "#steam__chizong:::"..data.card:toLogString()
        })
        if #tos > 0 then
            event:setCostData(self, { tos = tos })
            return true
        end
    end,
    on_use = function (self, event, target, player, data)
        local room = player.room
        data.extra_data = data.extra_data or {}
        data.extra_data.steam__chizong = data.extra_data.steam__chizong or {}
        table.insertTableIfNeed(data.extra_data.steam__chizong, event:getCostData(self).tos)
    end,
})

chizong:addEffect(fk.TargetConfirming, {
    can_trigger = function (self, event, target, player, data)
        if player == target and player:hasSkill(chizong.name) and player:usedSkillTimes(chizong.name) == 0 then
            return data.from ~= player and not table.find(player.room.alive_players, function (tp)
                return tp.dying
            end)
        end
    end,
    on_cost = function (self, event, target, player, data)
        local tos = player.room:askToChoosePlayers(player, {
            targets = data:getAllTargets(),
            max_num = 1,
            min_num = 1,
            skill_name = chizong.name,
            prompt = "#steam__chizong:::"..data.card:toLogString()
        })
        if #tos > 0 then
            event:setCostData(self, { tos = tos })
            return true
        end
    end,
    on_use = function (self, event, target, player, data)
        local room = player.room
        data.extra_data = data.extra_data or {}
        data.extra_data.steam__chizong = data.extra_data.steam__chizong or {}
        table.insertTableIfNeed(data.extra_data.steam__chizong, event:getCostData(self).tos)
    end,
})

chizong:addEffect(fk.PreCardEffect, {
    can_refresh = function (self, event, target, player, data)
        if data.to == player and data.extra_data and data.extra_data.steam__chizong then
            return table.contains(data.extra_data.steam__chizong, data.to)
        end
    end,
    on_refresh = function (self, event, target, player, data)
        data:changeCardSkill("steam_chizong__daggar_in_smile_skill")
    end,
})

return chizong