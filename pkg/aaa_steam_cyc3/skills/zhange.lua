local zhange = fk.CreateSkill{
    name = "steam__zhange",
}

Fk:loadTranslationTable{
    ["steam__zhange"] = "战歌",
    [":steam__zhange"] = "出牌阶段，你可以将手牌中的装备牌重铸为另一指定副类别的装备牌。你的装备技能均替换为〖挑衅〗，且你可以使用弃置牌。",
    ["#steam__zhange"] = "战歌：你可以将手牌中的装备牌重铸为另一指定副类别的装备牌",
    ["#steam__zhange-use"] = "战歌：你可以使用这张牌",
    ["$steam__zhange"] = "（虫语）",
}

local subtype_string_table = {
    ["weapon"] = Card.SubtypeWeapon,
    ["armor"] = Card.SubtypeArmor,
    ["defensive_ride"] = Card.SubtypeDefensiveRide,
    ["offensive_ride"] = Card.SubtypeOffensiveRide,
    ["treasure"] = Card.SubtypeTreasure,
}

--- 让玩家摸指定pattern的牌
---@param room Room @ 游戏房间
---@param player ServerPlayer @ 摸牌的玩家
---@param num integer @ 摸牌数
---@param skillName? string @ 技能名
---@param fromPlace? DrawPilePos @ 摸牌的位置，默认牌堆顶
---@param moveMark? table|string @ 移动后自动赋予标记，格式：{标记名(支持-inarea后缀，移出值代表区域后清除), 值}
---@param pattern? string @ 查找规则
---@return integer[] @ 摸到的牌
local function drawCardsByRule(room, player, num, skillName, fromPlace, moveMark, pattern)

    if not pattern then pattern = "." end

    if num < 1 then
        return {}
    end

    local drawData = DrawData:new{
        who = player,
        num = num,
        skillName = skillName,
        fromPlace = fromPlace or "top",
    }
    if room.logic:trigger(fk.BeforeDrawCard, player, drawData) then
        return {}
    end

    num = drawData.num
    fromPlace = drawData.fromPlace
    player = drawData.who

    local pileToSearch = room.draw_pile
    if #pileToSearch == 0 then
        return {}
    end

    local matchedIds = {}
    for _, id in ipairs(pileToSearch) do
        if Fk:getCardById(id):matchPattern(pattern) then
            table.insert(matchedIds, id)
        end
    end

    if #matchedIds == 0 then
        return {}
    end

    local topCards = {}

    local i, j = 1, num
    if fromPlace == "bottom" then
        i = #matchedIds + 1 - num
        j = #matchedIds
    end

    if #matchedIds < num then
        for _, id in ipairs(room.discard_pile) do
            if Fk:getCardById(id):matchPattern(pattern) then
                table.insertIfNeed(matchedIds, id)
            end
        end
        if #matchedIds < num then
            topCards = table.simpleClone(matchedIds)
        else
            topCards = table.slice(matchedIds, i, j + 1)
        end
    else
        topCards = table.slice(matchedIds, i, j + 1)
    end

    if #topCards == 0 then
        return {}
    end

    room:moveCards({
        ids = topCards,
        to = player,
        toArea = Card.PlayerHand,
        moveReason = fk.ReasonDraw,
        proposer = player,
        skillName = skillName,
        moveMark = moveMark,
    })

    return { table.unpack(topCards) }
end

--- 重铸一名角色的牌为指定pattern的牌。
---@param room Room @ 游戏房间
---@param card_ids integer[] @ 被重铸的牌
---@param who ServerPlayer @ 重铸的角色
---@param skillName? string @ 技能名，默认为“重铸”
---@param moveMark? table|string @ 移动后自动赋予标记，格式：{标记名(支持-inarea后缀，移出值代表区域后清除), 值}
---@param pattern? string @ 查找规则
---@return integer[] @ 摸到的牌
local function recastCardByRule(room, card_ids, who, skillName, moveMark, pattern)

    if not pattern then pattern = "." end

    if type(card_ids) == "number" then
        card_ids = {card_ids}
    end
    skillName = skillName or "recast"
    room:moveCards({
        ids = card_ids,
        from = who,
        toArea = Card.DiscardPile,
        skillName = skillName,
        moveReason = fk.ReasonRecast,
        proposer = who,
    })
    room:sendFootnote(card_ids, {
        type = "##RecastCard",
        from = who.id,
    })
    room:broadcastPlaySound("./audio/system/recast")
    room:sendLog{
        type = skillName == "recast" and "#Recast" or "#RecastBySkill",
        from = who.id,
        card = card_ids,
        arg = skillName,
    }
    if who.dead then return {} end
    return drawCardsByRule(room, who, #card_ids, skillName, "top", moveMark, pattern)
end

zhange:addEffect("active", {
    anim_type = "drawcard",
    prompt = "#steam__zhange",
    card_num = 1,
    target_num = 0,
    can_use = Util.TrueFunc,
    interaction = function (self, player)
        return UI.ComboBox{ choices = {
            "weapon",
            "armor",
            "defensive_ride",
            "offensive_ride",
            "treasure",
        } }
    end,
    card_filter = function(self, player, to_select, selected)
        return #selected == 0 and Fk:getCardById(to_select).type == Card.TypeEquip and table.contains(player:getCardIds("h"), to_select) and Fk:getCardById(to_select).sub_type ~= subtype_string_table[self.interaction.data]
    end,
    on_use = function(self, room, effect)
        recastCardByRule(room, effect.cards, effect.from, zhange.name, nil, ".|.|.|.|.|"..self.interaction.data)
    end,
})

zhange:addEffect(fk.AfterCardsMove, {
    can_refresh = function(self, event, target, player, data)
        if not player:hasSkill(zhange.name) then return false end
        for _, move in ipairs(data) do
            for _, info in ipairs(move.moveInfo) do
                if (move.to == player and move.toArea == Card.PlayerEquip)
                or (move.from == player and info.fromArea == Card.PlayerEquip) then
                return Fk:getCardById(info.cardId).type == Card.TypeEquip
                end
            end
        end
    end,
    on_refresh = function(self, event, target, player, data)
        for _, move in ipairs(data) do
        for _, info in ipairs(move.moveInfo) do
            if move.to == player and move.toArea == Card.PlayerEquip and Fk:getCardById(info.cardId).type == Card.TypeEquip then
            for _, skill in ipairs(player.player_skills) do
                if skill:getSkeleton().attached_equip and Fk.all_card_types[skill:getSkeleton().attached_equip].type == Card.TypeEquip then
                if Fk.skills[skill] and player:hasSkill(skill, true) then
                    player.room:handleAddLoseSkills(player, "-"..skill, zhange.name, false, true)
                end
                if Fk.skills[skill.name] and player:hasSkill(skill.name, true) then
                    player.room:handleAddLoseSkills(player, "-"..skill.name, zhange.name, false, true)
                end
                end
            end
            local get = true
            for i = 0, 30, 1 do
                local name = i == 0 and "steam__tiaoxin" or "steam"..i.."__tiaoxin"
                if not get then break end
                if player:getMark(""..name.."record") == Fk:getCardById(info.cardId).name then
                get = false
                player.room:handleAddLoseSkills(player, name, nil, false, true)
                break
                end
            end
            for i = 0, 30, 1 do
                local name = i == 0 and "steam__tiaoxin" or "steam"..i.."__tiaoxin"
                if not get then break end
                if not player:hasSkill(name, true) then
                get = false
                --player:setSkillUseHistory(name, 0, Player.HistoryGame)
                player.room:setPlayerMark(player, ""..name.."record", Fk:getCardById(info.cardId).name) --记录一下卡牌名字，用来定位删除的技能
                player.room:handleAddLoseSkills(player, name, nil, false, true)
                break
                end
            end
            elseif move.from == player and info.fromArea == Card.PlayerEquip and Fk:getCardById(info.cardId).type == Card.TypeEquip then
            for i = 0, 30, 1 do
                local name = i == 0 and "steam__tiaoxin" or "steam"..i.."__tiaoxin"
                if player:hasSkill(name, true) and player:getMark(""..name.."record") == Fk:getCardById(info.cardId).name then
                --player:setSkillUseHistory(name, 0, Player.HistoryGame)
                --player.room:setPlayerMark(player, ""..name, 0)
                --player.room:setPlayerMark(player, ""..name.."record", 0)
                player.room:handleAddLoseSkills(player, "-"..name, nil, false, true)
                break
                end
            end
            end
        end
        end
    end,
})

zhange:addAcquireEffect(function (self, player, is_start)
    for _, skill in ipairs(player.player_skills) do
        if skill:getSkeleton().attached_equip and Fk.all_card_types[skill:getSkeleton().attached_equip].type == Card.TypeEquip then
        if Fk.skills[skill] and player:hasSkill(skill, true) then
            player.room:handleAddLoseSkills(player, "-"..skill, zhange.name, false, true)
        end
        if Fk.skills[skill.name] and player:hasSkill(skill.name, true) then
            player.room:handleAddLoseSkills(player, "-"..skill.name, zhange.name, false, true)
        end
        end
    end
    for _, e in ipairs(player.player_cards[Player.Equip]) do
        if Fk:getCardById(e).type == Card.TypeEquip then
        local get = true
        for i = 0, 30, 1 do
            local name = i == 0 and "steam__tiaoxin" or "steam"..i.."__tiaoxin"
            if not get then break end
            if player:getMark(""..name.."record") == Fk:getCardById(e).name then
            get = false
            player.room:handleAddLoseSkills(player, name, nil, false, true)
            break
            end
        end
        for i = 0, 30, 1 do
            local name = i == 0 and "steam__tiaoxin" or "steam"..i.."__tiaoxin"
            if not player:hasSkill(name, true) then
            get = false
            --player:setSkillUseHistory(name, 0, Player.HistoryGame)
            player.room:setPlayerMark(player, ""..name.."record", Fk:getCardById(e).name) --记录一下卡牌名字，用来定位删除的技能
            player.room:handleAddLoseSkills(player, name, nil, false, true)
            break
            end
        end
        end
    end
end)

zhange:addLoseEffect(function (self, player, is_death)
    for i = 0, 30, 1 do
        local name = i == 0 and "steam__tiaoxin" or "steam"..i.."__tiaoxin"
        if player:hasSkill(name, true) then
        --player:setSkillUseHistory(name, 0, Player.HistoryGame)
        --player.room:setPlayerMark(player, ""..name, 0)
        --player.room:setPlayerMark(player, ""..name.."record", 0)
        player.room:handleAddLoseSkills(player, "-"..name, nil, false, true)
        end
    end
end)

zhange:addEffect('invalidity', {
    invalidity_func = function(self, player, skill)
        if skill:getSkeleton() and skill:getSkeleton().attached_equip then
            if player:hasSkill(zhange.name) then return true end
        end
    end
})

--- 获取玩家攻击范围。
---@param excludeIds? integer[] @ 忽略的自己装备的id列表
---@param excludeSkills? string[] @ 忽略的技能名列表
---@param player Player @ 玩家
---@param self AttackRangeSkill @ 当前技能
---@return integer
local getAttackRange_zhange = function (excludeIds, excludeSkills, player, self)
    local baseValue = 1

    local weapons = table.filter(player:getEquipments(Card.SubtypeWeapon), function (id)
        if not table.contains(excludeIds or {}, id) then
        local weapon = player:getVirtualEquip(id) or Fk:getCardById(id) ---@class Weapon
        return weapon:AvailableAttackRange(player)
        end
    end)
    if #weapons > 0 then
        baseValue = 0
        for _, id in ipairs(weapons) do
        local weapon = player:getVirtualEquip(id) or Fk:getCardById(id) ---@class Weapon
        baseValue = math.max(baseValue, weapon:getAttackRange(player) or 1)
        end
    end

    excludeSkills = excludeSkills or {}
    if excludeIds then
        for _, id in ipairs(excludeIds) do
        local equip = player:getVirtualEquip(id) --[[@as EquipCard]]
        if equip == nil and table.contains(player:getCardIds("e"), id) and Fk:getCardById(id).type == Card.TypeEquip then
            equip = Fk:getCardById(id) --[[@as EquipCard]]
        end
        if equip and equip.type == Card.TypeEquip then
            for _, skill in ipairs(equip:getEquipSkills(player)) do
            table.insertIfNeed(excludeSkills, skill.name)
            end
        end
        end
    end

    local status_skills = Fk:currentRoom().status_skills[AttackRangeSkill] or Util.DummyTable ---@type AttackRangeSkill[]
    local max_fixed, correct = nil, 0
    for _, skill in ipairs(status_skills) do
        if not table.contains(excludeSkills, skill.name) and self ~= skill then
        local final = skill:getFinal(player)
        if final then -- 目前逻辑，发现一个终值马上返回
            return math.max(0, final)
        end
        local f = skill:getFixed(player)
        if f ~= nil then
            max_fixed = max_fixed and math.max(max_fixed, f) or f
        end
        local c = skill:getCorrect(player)
        correct = correct + (c or 0)
        end
    end

    return math.max(math.max(baseValue, (max_fixed or 0)) + correct, 0)
end

zhange:addEffect("atkrange", {
    final_func = function (self, from)
        if from:hasSkill(zhange.name) then
            local weapons = table.filter(from:getEquipments(Card.SubtypeWeapon), function (id)
                local weapon = Fk:getCardById(id) ---@class Weapon
                return weapon:AvailableAttackRange(from)
            end)
            return getAttackRange_zhange(weapons, {}, from, self)
        end
    end,
})

return zhange