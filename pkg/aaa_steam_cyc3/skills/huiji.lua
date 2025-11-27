local huiji = fk.CreateSkill{
    name = "steam__huiji",
}

Fk:loadTranslationTable{
    ["steam__huiji"] = "绘迹",
    [":steam__huiji"] = "一名角色的摸牌阶段开始时，其可以交给你一张牌（若为你则改为摸一张牌）并卜算5。",
    ["#steam__huiji-give"] = "啵尚咔！使针的小姑娘，是否用一张牌交换部落测绘师%dest新追寻到的踪迹？",
    ["#steam__huiji-draw"] = "啵尚咔！握紧兵刃，保持警惕！",

    ["$steam__huiji1"] = "（虫语）",
    ["$steam__huiji2"] = "（虫语）",
}

huiji:addEffect(fk.EventPhaseStart, {
    can_trigger = function (self, event, target, player, data)
        return player:hasSkill(huiji.name) and target.phase == Player.Draw
    end,
    on_cost = function (self, event, target, player, data)
        local room = player.room
        if target ~= player then
            local cards = room:askToCards(target, {
                skill_name = huiji.name,
                max_num = 1,
                min_num = 1,
                pattern = ".",
                prompt = "#steam__huiji-give::"..player.id,
            })
            if #cards > 0 then
                event:setCostData(self, { cards = cards })
                return true
            end
        elseif room:askToSkillInvoke(player, {
            skill_name = huiji.name,
            prompt = "#steam__huiji-draw"
        }) then
            return true
        end
    end,
    on_use = function (self, event, target, player, data)
        local room = player.room
        if target == player then
            room:drawCards(player, 1, huiji.name)
        else
            room:obtainCard(player, event:getCostData(self).cards, false, fk.ReasonGive, target, huiji.name)
        end
        room:askToGuanxing(target, { cards = room:getNCards(5), skill_name = huiji.name})
    end,
})

return huiji