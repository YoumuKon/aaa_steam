local chaoxiong = fk.CreateSkill{
    name = "steam__chaoxiong",
}
Fk:loadTranslationTable{
    ["steam__chaoxiong"] = "超雄",
    [":steam__chaoxiong"] = "你使用【杀】结算后，可以摸一张牌并选择一项：1.对其中一名目标再使用一张【杀】，且本回合本技能强制发动；2.将所有手牌当【决斗】使用。",
    ["#steam__chaoxiong-invoke"] = "是否发动 超雄，摸一张牌并使用【杀】或【决斗】？",
    ["#steam__chaoxiong-slash"] = "超雄：对其中一个目标再使用一张【杀】，或点“取消”将所有手牌当【决斗】使用",
    ["#steam__chaoxiong-duel"] = "超雄：将所有手牌当【决斗】使用",
    ["@@steam__chaoxiong-turn"] = "强制超雄",

    ["$steam__chaoxiong1"] = "司马氏之罪，尽洛水亦难清！",
    ["$steam__chaoxiong2"] = "汝司马氏世受魏恩，今安敢如此！",
}

chaoxiong:addEffect(fk.CardUseFinished, {
    anim_type = "offensive",
    can_trigger = function (self, event, target, player, data)
        return target == player and data.card.trueName == "slash" and player:hasSkill(chaoxiong.name)
    end,
    on_cost = function (self, event, target, player, data)
        if player:getMark("@@steam__chaoxiong-turn") ~= 0 or player.room:askToSkillInvoke(player,{
            skill_name = chaoxiong.name,
            prompt = "#steam__chaoxiong-invoke",
        }) then
            return true
        end
    end,
    on_use = function (self, event, target, player, data)
        local room = player.room
        local targets = table.map(data.tos,Util.IdMapper)
        player:drawCards(1, chaoxiong.name)
        local use = room:askToPlayCard(player,{
            pattern = "slash",
            prompt = "#steam__chaoxiong-slash",
            cancelable = true,
            skill_name = chaoxiong.name,
            extra_data = {
                exclusive_targets = targets,
                bypass_distances = true,
                bypass_times = true,
                extraUse = true,
            },
            skip = true,
        })
        if use then
            room:setPlayerMark(player, "@@steam__chaoxiong-turn", 1)
            room:useCard(use)
        elseif #player:getCardIds("h") > 0 then
            room:askToUseVirtualCard(player,{
                name = "duel",
                subcards = player:getCardIds("h"),
                skill_name = chaoxiong.name,
                cancelable = false,
                prompt = "#steam__chaoxiong-duel",
            })
        end
    end,
})

return chaoxiong