local extension = Package("aaa_steam_token", Package.CardPack)
extension.extensionName = "aaa_steam"

Fk:loadTranslationTable{
  ["aaa_steam_token"] = "steam衍生牌",
}

local catapultSkill = fk.CreateTriggerSkill{
  name = "#steam_pegasus__catapult_skill",
  attached_equip = "steam_pegasus__catapult",
  events = {fk.BeforeCardsMove},
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(self) then return false end
    for _, move in ipairs(data) do
      if move.from == player.id and move.moveReason == fk.ReasonUse then
        local use = player.room.logic:getCurrentEvent():findParent(GameEvent.UseCard,true).data[1]
        if (not use.card:isVirtual() or #use.card.subcards == 0) and use.card.trueName == "slash" then
          self.cost_data = use
          return true
        end
      end
    end
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local use = self.cost_data
    local tos = use.tos[1]
    local to, cards = room:askForChooseCardsAndPlayers(player, 1, 1, tos, 1, 1, "slash", "#catapult-give", self.name, false)
    if #to == 1 and #cards == 1 then
      self.cost_data = {to[1], cards[1]}
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    for _, move in ipairs(data) do
      if move.moveReason == fk.ReasonUse then
        move.moveInfo = {}
      end
    end
    local to, card = table.unpack(self.cost_data)
    room:obtainCard(to, card, true, fk.ReasonGive, player.id, self.name)
    local obtianer = room:getPlayerById(to)
    if not obtianer.dead then
      local cards
      if #obtianer:getCardIds("he") > 0 then
        cards = room:askForCardsChosen(player, obtianer, 1, 3, "he", self.name)
      end
      room:throwCard(cards, self.name, obtianer, player)
      if not obtianer.dead then
        local map = {}
        for _, id in ipairs(cards) do
          map[Fk:getCardById(id).trueName] = (map[Fk:getCardById(id).trueName] or 0) + 1
        end
        if map["slash"] and not map["jink"] then
          room:damage{
            damage = 1,
            from = player,
            to = obtianer,
            skillName = self.name,
          }
        end
      end
    end
  end,
}
local catapult_prohibit = fk.CreateProhibitSkill{
  name = "#steam_pegasus__catapult_prohibit",
  prohibit_use = function (self, player, card)
    if player:hasSkill(self) and card.trueName == "slash" and (not card:isVirtual() or #card.subcards == 0) then
      if not table.find(player:getCardIds("he"), function (id) return Fk:getCardById(id).trueName == "slash" end) then
        return true
      end
    end
  end,
}
catapultSkill:addRelatedSkill(catapult_prohibit)
Fk:addSkill(catapultSkill)

local catapult = fk.CreateTreasure{
  name = "&steam_pegasus__catapult",
  suit = Card.Diamond,
  number = 9,
  equip_skill = catapultSkill,
}
extension:addCard(catapult)
Fk:loadTranslationTable{
  ["steam_pegasus__catapult"] = "霹雳车",
  ["#steam_pegasus__catapult_skill"] = "霹雳车",
  [":steam_pegasus__catapult"] = "装备牌·宝物<br /><b>宝物技能</b>：你使用【杀】的方式改为交给目标一张【杀】并弃置其至多三张牌，若弃置了【杀】但未弃置【闪】，对其造成1点伤害。此牌离开场上时销毁。",

  ["#catapult-give"] = "霹雳车：交给目标一张【杀】并弃置其至多三张牌"
}

fk.GodDamage = 8 --注册的ID

Fk:addDamageNature(fk.GodDamage, "god_damage")

local slash = Fk:cloneCard("slash")
local godSlashSkill = fk.CreateActiveSkill{
  name = "god__slash_skill",
  max_phase_use_time = 1,
  target_num = 1,
  can_use = slash.skill.canUse,
  mod_target_filter = slash.skill.modTargetFilter,
  target_filter = slash.skill.targetFilter,
  on_effect = function(self, room, effect)
    local to = effect.to
    local from = effect.from
    room:damage({
      from = room:getPlayerById(from),
      to = room:getPlayerById(to),
      card = effect.card,
      damage = 1,
      damageType = fk.GodDamage,
      skillName = self.name
    })
  end
}
local GodDamageSkill = fk.CreateTriggerSkill{
  name = "god_damage_skill",
  global = true,
  mute = true,
  events = {fk.DamageCaused},
  can_trigger = function(self, event, target, player, data)
    return target == player and data.damageType == fk.GodDamage and data.card and data.card.name == "god__slash" and not data.chain
    and ((data.card.extra_data and data.card.extra_data.godSlashBypassKingdom and data.card.extra_data.godSlashBypassKingdom == true)
    or target.kingdom == "god" or Fk.generals[target.general].kingdom == "god" or Fk.generals[target.general].subkingdom == "god"
    or (target.deputyGeneral ~= "" and (Fk.generals[target.deputyGeneral].kingdom == "god" or Fk.generals[target.deputyGeneral].subkingdom == "god")))
  end,
  on_cost = function (self, event, target, player, data)
    return player.room:askForSkillInvoke(player, self.name, nil, "#god_damage_skill-invoke::"..data.to.id)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:changeMaxHp(data.to, -data.damage)
    return true
  end
}
Fk:addSkill(GodDamageSkill)
local godSlash = fk.CreateBasicCard{
  name = "&god__slash",
  skill = godSlashSkill,
  is_damage_card = true,
}
extension:addCards{
  godSlash:clone(Card.Heart, 7),
}
Fk:loadTranslationTable{
  ["god_damage"] = "神祇属性",

  ["god__slash"] = "神杀",
  ["god_damage_skill"] = "神杀",
  [":god__slash"] = "基本牌<br/><b>时机</b>：出牌阶段<br/><b>目标</b>：攻击范围内的一名角色<br /><b>效果</b>：对目标角色造成1点神祇伤害。"..
  "<br>你使用此牌对目标角色造成伤害时，若你的势力含有神，你可以防止此伤害，令其减少防止前伤害值的体力上限。",
  ["#god_damage_skill-invoke"] = "神杀：你可以防止对目标角色 %dest 造成伤害，令其减少防止前伤害值的体力上限！",
}

return extension