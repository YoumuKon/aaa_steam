local extension = Package("aaa_steam_lingcards", Package.CardPack)
extension.extensionName = "aaa_steam"

local U = require "packages/utility/utility"

local drowningSkill = fk.CreateActiveSkill{
  name = "ling__drowning_skill",
  prompt = "#ling__drowning_skill",
  can_use = Util.CanUse,
  target_num = 1,
  mod_target_filter = function(self, to_select, selected, user, card, distance_limited)
    return to_select ~= user and #Fk:currentRoom():getPlayerById(to_select):getCardIds(Player.Equip) > 0
  end,
  target_filter = Util.TargetFilter,
  on_effect = function(self, room, effect)
    local from = room:getPlayerById(effect.from)
    local to = room:getPlayerById(effect.to)
    local all_choices = {"ling__drowning_throw", "ling__drowning_damage:" .. from.id}
    local choices = table.clone(all_choices)
    --if not table.find(to:getCardIds(Player.Equip), function(id) return not to:prohibitDiscard(Fk:getCardById(id)) end) then
    if #to:getCardIds(Player.Equip) == 0 then
      table.remove(choices, 1)
    end
    local choice = room:askForChoice(to, choices, self.name, nil, false, all_choices)
    if choice == "ling__drowning_throw" then
      to:throwAllCards("e")
    else
      room:damage({
        from = from,
        to = to,
        card = effect.card,
        damage = 1,
        damageType = fk.ThunderDamage,
        skillName = self.name
      })
    end
  end
}
local drowning = fk.CreateTrickCard{
  name = "&ling__drowning",
  skill = drowningSkill,
  is_damage_card = true,
  suit = Card.Spade,
  number = 4,
}
extension:addCard(drowning)
Fk:loadTranslationTable{
  ["ling__drowning"] = "水淹七军",
  [":ling__drowning"] = "锦囊牌<br/><b>时机</b>：出牌阶段<br/><b>目标</b>：一名装备区里有牌的其他角色<br/><b>效果</b>：目标角色选择："..
  "1.弃置装备区里的所有牌；2.受到你造成的1点雷电伤害。",
  ["ling__drowning_skill"] = "水淹七军",
  ["ling__drowning_throw"] = "弃置装备区里的所有牌",
  ["ling__drowning_damage"] = "受到%src造成的1点雷电伤害",
  ["#ling__drowning_skill"] = "选择一名装备区里有牌的其他角色，其选择：<br/>1.弃置装备区里的所有牌；2.受到你造成的1点雷电伤害",
}

local warshipSkill = fk.CreateTriggerSkill{
    name = "#lingling__warship_skill",
    attached_equip = "lingling__warship",
    frequency = Skill.Compulsory,
    events = {fk.AfterCardsMove},
    can_trigger = function(self, event, target, player, data)
      if player.dead then return end
      for _, move in ipairs(data) do
        if move.to == player.id and move.toArea == Card.PlayerEquip then
          for _, info in ipairs(move.moveInfo) do
            if Fk:getCardById(info.cardId).name == self.attached_equip then
              return self:isEffectable(player)
            end
          end
        end
        if move.from == player.id then
          for _, info in ipairs(move.moveInfo) do
            if info.fromArea == Card.PlayerEquip and Fk:getCardById(info.cardId).name == self.attached_equip then
              return self:isEffectable(player)
            end
          end
        end
      end
    end,
    on_use = function(self, event, target, player, data)
      local room = player.room
      for _, move in ipairs(data) do
        if move.to == player.id and move.toArea == Card.PlayerEquip then
          for _, info in ipairs(move.moveInfo) do
            if Fk:getCardById(info.cardId).name == self.attached_equip then
              room:changeShield(player, 3)
            end
          end
        end
        if move.from == player.id then
          for _, info in ipairs(move.moveInfo) do
            if info.fromArea == Card.PlayerEquip and Fk:getCardById(info.cardId).name == self.attached_equip then
              room:changeShield(player, -3)
            end
          end
        end
      end
    end,
  
    refresh_events = {fk.BeforeCardsMove},
    can_refresh = function(self, event, target, player, data)
      return table.find(player:getCardIds("e"), function (id)
        return Fk:getCardById(id).name == "lingling__warship"
      end)
    end,
    on_refresh = function(self, event, target, player, data)
      local room = player.room
      local mirror_moves = {}
      local to_void, cancel_move = {},{}
      for _, move in ipairs(data) do
        if move.from == player.id and move.toArea ~= Card.Void then
          local move_info = {}
          local mirror_info = {}
          for _, info in ipairs(move.moveInfo) do
            local id = info.cardId
            if Fk:getCardById(id).name == "lingling__warship" and info.fromArea == Card.PlayerEquip then
              if not player.dead and player:getMark(self.name) == 0 then
                room:setPlayerMark(player, self.name, 1)
                table.insert(cancel_move, id)
              else
                table.insert(mirror_info, info)
                table.insert(to_void, id)
              end
            else
              table.insert(move_info, info)
            end
          end
          move.moveInfo = move_info
          if #mirror_info > 0 then
            local mirror_move = table.clone(move)
            mirror_move.to = nil
            mirror_move.toArea = Card.Void
            mirror_move.moveInfo = mirror_info
            table.insert(mirror_moves, mirror_move)
          end
        end
      end
    end,
  }
  local warship_maxcards = fk.CreateMaxCardsSkill{
    name = "#lingling__warship_maxcards",
    correct_func = function(self, player)
      if player:hasSkill(warshipSkill) then
        return 3
      end
    end,
  }
  warshipSkill:addRelatedSkill(warship_maxcards)
  Fk:addSkill(warshipSkill)
  local warship = fk.CreateTreasure{
    name = "&lingling__warship",
    suit = Card.Club,
    number = 10,
    equip_skill = warshipSkill,
  }
  extension:addCard(warship)
  Fk:loadTranslationTable{
    ["lingling__warship"] = "大战船",
    ["warship"] = "大战船",
    ["#lingling__warship_skill"] = "大战船",
    [":lingling__warship"] = "装备牌·宝物<br/><b>宝物技能</b>：你装备此牌后获得3点护甲，此牌离开装备区时失去这些护甲。你的手牌上限+3。"..
    "此牌首次离开装备区时防止之。",
    ["aaa_steam_lingcards"] = "伶史衍生牌",
  }


  return extension