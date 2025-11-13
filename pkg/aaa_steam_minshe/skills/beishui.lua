local beishui = fk.CreateSkill{
    name = "steamMinshe__beishui"
}

Fk:loadTranslationTable{
    ["steamMinshe__beishui"] = "背水",
    [":steamMinshe__beishui"] = "每个回合结束时，若你手牌数不大于1，你执行一个视为拥有“<a href = ':steamMinshe__beishui_qingjiao'><font color='#195494'>清剿</font></a>”且“膂力”中的“或”改成“和”的出牌阶段。",
    ["@[desc]steamMinshe__beishui-phase"] = "背水",
    [":steamMinshe__beishui_qingjiao"] = "<b>清剿</b>：出牌阶段开始时，你可以弃置所有手牌，然后从牌堆或弃牌堆中随机获得八张牌名各不相同且副类别不同的牌。若如此做，结束阶段，你弃置所有牌。",
    [":steamMinshe__beishui-phase"] = "效淮阴之举，力敌数千！<br>你视为拥有“清剿”且“膂力”中的“或”改成“和”",

    ["$steamMinshe__beishui1"] = "某若退却半步，诸将可立斩之！",
    ["$steamMinshe__beishui2"] = "效淮阴之举，力敌数千！"
}

beishui:addEffect(fk.TurnEnd, {
    can_trigger = function (self, event, target, player, data)
        return player:hasSkill(beishui.name) and player:getHandcardNum() < 2
    end,
    on_cost = Util.TrueFunc,
    on_use = function (self, event, target, player, data)
        local room = player.room
        room:setPlayerMark(player, "@[desc]steamMinshe__beishui-phase", 1)
        player:gainAnExtraPhase(Player.Play, beishui.name)
    end,
})

return beishui