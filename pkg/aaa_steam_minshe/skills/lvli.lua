local lvli = fk.CreateSkill{
    name = "steamMinshe__lvli",
    tags = {Skill.Compulsory},
    dynamic_desc = function (self, player, lang)
        if player:getMark("@[desc]steamMinshe__beishui") > 0 then
            return "锁定技，你使用非伤害牌结算后，横置并翻至背面；你的体力值变化后，复原武将牌并破釜1并摸等量牌；你的武将牌状态变化后，本回合你使用的下一张牌无距离和次数限制。"
        end
    end,
}

Fk:loadTranslationTable{
    ["steamMinshe__lvli"] = "膂力",
    [":steamMinshe__lvli"] = "锁定技，你使用非伤害牌结算后，横置或翻至背面；你的体力值变化后，复原武将牌或破釜1并摸等量牌；你的武将牌状态变化后，本回合你使用的下一张牌无距离和次数限制。",
    ["#steamMinshe__lvli1"] = "横置自己",
    ["#steamMinshe__lvli2"] = "翻至背面",
    ["#steamMinshe__lvli3"] = "复原武将牌",
    ["#steamMinshe__lvli4"] = "破釜手牌区",
    ["#steamMinshe__lvli5"] = "破釜装备区",
    ["#steamMinshe__lvli6"] = "破釜判定区",
    ["#steamMinshe__lvli"] = "膂力：请选择一项",
    ["@[desc]steamMinshe__lvli-turn"] = "膂力",
    [":steamMinshe__lvli-turn"] = "姿器膂力，万人之雄。<br>本回合你使用的下一张牌无距离和次数限制",

    ["$steamMinshe__lvli1"] = "此击若中，万念俱灰！",
    ["$steamMinshe__lvli2"] = "姿器膂力，万人之雄。",
}

lvli:addEffect(fk.CardUseFinished, {
    can_trigger = function (self, event, target, player, data)
        if player == target and player:hasSkill(lvli.name) then
            return not data.card.is_damage_card and not (player.chained and not player.faceup)
        end
    end,
    on_cost = function (self, event, target, player, data)
        local choices = {}
        if not player.chained then
            table.insert(choices, "#steamMinshe__lvli1")
        end
        if player.faceup then
            table.insert(choices, "#steamMinshe__lvli2")
        end
        if #choices > 0  then
            local room = player.room
            local choice = choices[1]
            if #choices > 1 and player:getMark("@[desc]steamMinshe__beishui") == 0 then
                choice = room:askToChoice(player, {
                    choices = choices,
                    all_choices = { "#steamMinshe__lvli1",  "#steamMinshe__lvli2"},
                    skill_name = lvli.name,
                    prompt = "#steamMinshe__lvli"
                })
            end
            event:setCostData(self, choice)
            return true
        end
    end,
    on_use = function (self, event, target, player, data)
        local room = player.room
        if event:getCostData(self) == "#steamMinshe__lvli1" or player:getMark("@[desc]steamMinshe__beishui") > 0 then
            player:setChainState(true)
        end
        if event:getCostData(self) == "#steamMinshe__lvli2" or player:getMark("@[desc]steamMinshe__beishui") > 0 then
            if player.faceup then player:turnOver() end
        end
    end,
})

lvli:addEffect(fk.HpChanged, {
    can_trigger = function (self, event, target, player, data)
        if player == target and player:hasSkill(lvli.name) then
            return player.chained or not player.faceup or not player:isAllNude()
        end
    end,
    on_cost = function (self, event, target, player, data)
        local choices = {}
        local all_choices = { "#steamMinshe__lvli3", "#steamMinshe__lvli4", "#steamMinshe__lvli5", "#steamMinshe__lvli6"}
        if player:getMark("@[desc]steamMinshe__beishui") > 0 then
            all_choices = { "#steamMinshe__lvli4", "#steamMinshe__lvli5", "#steamMinshe__lvli6"}
        else
            if player.chained or not player.faceup then
                table.insert(choices, "#steamMinshe__lvli3")
            end
        end
        if #player:getCardIds("h") > 0 then
            table.insert(choices, "#steamMinshe__lvli4")
        end
        if #player:getCardIds("e") > 0 then
            table.insert(choices, "#steamMinshe__lvli5")
        end
        if #player:getCardIds("j") > 0 then
            table.insert(choices, "#steamMinshe__lvli6")
        end
        if #choices > 0 then
            local room = player.room
            local choice = choices[1]
            if #choices > 1 then
                choice = room:askToChoice(player, {
                    choices = choices,
                    all_choices = all_choices,
                    skill_name = lvli.name,
                    prompt = "#steamMinshe__lvli"
                })
            end
            event:setCostData(self, choice)
            return true
        elseif (player.chained or not player.faceup) and player:getMark("@[desc]steamMinshe__beishui") > 0 then
            event:setCostData(self, "")
            return true
        end
    end,
    on_use = function (self, event, target, player, data)
        local room = player.room
        if player:getMark("@[desc]steamMinshe__beishui") > 0 or event:getCostData(self) == "#steamMinshe__lvli3" then
            player:setChainState(false)
            if not player.faceup then
                player:turnOver()
            end
        end
        if player:getMark("@[desc]steamMinshe__beishui") > 0 or event:getCostData(self) ~= "#steamMinshe__lvli3" then
            local cards = {}
            if event:getCostData(self) == "#steamMinshe__lvli4" then
                cards = player:getCardIds("h")
            elseif event:getCostData(self) == "#steamMinshe__lvli5" then
                cards = player:getCardIds("e")
            else
                cards = player:getCardIds("j")
            end
            if #cards > 0 then
                room:throwCard(cards, lvli.name, player)
                player:drawCards(#cards, lvli.name)
            end
        end
    end,
})

local spec = {
    anim_type = "special",
    can_trigger = function(self, event, target, player, data)
        return target == player and player:hasSkill(lvli.name)
    end,
    on_use = function(self, event, target, player, data)
        local room = player.room
        room:setPlayerMark(player, "@[desc]steamMinshe__lvli-turn", 1)
    end,
}

lvli:addEffect(fk.TurnedOver, spec)
lvli:addEffect(fk.ChainStateChanged, spec)

lvli:addEffect(fk.CardUseFinished, {
    can_refresh = function(self, event, target, player, data)
        return target == player and player:hasSkill(lvli.name)
    end,
    on_refresh = function(self, event, target, player, data)
        player.room:setPlayerMark(player, "@[desc]steamMinshe__lvli-turn", 0)
    end,
})

lvli:addEffect("targetmod", {
    bypass_times = function(self, player, skill, scope)
        return player:hasSkill(lvli.name) and player:getMark("@[desc]steamMinshe__lvli-turn") > 0
    end,
    bypass_distances = function(self, player, skill)
        return player:hasSkill(lvli.name) and player:getMark("@[desc]steamMinshe__lvli-turn") > 0
    end,
})

return lvli