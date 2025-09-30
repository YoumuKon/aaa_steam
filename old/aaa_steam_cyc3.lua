local extension = Package("aaa_steam_cyc3")
extension.extensionName = "aaa_steam"

local U = require "packages/utility/utility"
local RUtil = require "packages/aaa_fenghou/utility/rfenghou_util"
local DIY = require "packages/diy_utility/diy_utility"

Fk:loadTranslationTable{
  ["aaa_steam_cyc3"] = "嘭嘭嘭",
  ["hollow"] = "空",
}


local hollowknight = General:new(extension, "steam__hollowknight", "hollow", 4)

Fk:loadTranslationTable{
  ["steam__hollowknight"] = "空洞骑士",
  ["#steam__hollowknight"] = "",
  ["designer:steam__hollowknight"] = "cyc",
  ["illustrator:steam__hollowknight"] = "",
}


local zhanlu = fk.CreateTriggerSkill{
  name = "steam__zhanlu",
  anim_type = "switch",
  switch_skill_name = "steam__zhanlu",
  frequency = Skill.Compulsory,
  events = {fk.TurnEnd},
  on_use = function(self, event, target, player, data)
    local room = player.room
    if player:getSwitchSkillState(self.name, true) == fk.SwitchYang then
      local mark = player:getTableMark("@$steam__zhanlu")
      local weapons = table.filter(room:getTag("steam__zhanlu_weapon") or {}, function(name)
        return not table.contains(mark, name)
      end)
      if #weapons > 0 then
        local rnd = table.random(weapons, 3)
        local cards = table.map(rnd, function(name) return Fk.all_card_types[name].id end)
        local cid = room:askForCardChosen(player, player, { card_data = { { self.name, cards } } }, self.name, "#steam__zhanlu-card")
        local card = Fk:getCardById(cid, true)
        ---@cast card EquipCard
        room:addTableMark(player, "@$steam__zhanlu", card.name)
        if card.sub_type == Card.SubtypeWeapon then
          local skills = card:getEquipSkills(player)
          if #skills > 0 then
            room:handleAddLoseSkills(player, table.concat(table.map(skills, Util.NameMapper), "|"), self.name)
          end
        end
      end
    else
      local skills = player:getAllSkills()
      local num = #table.filter(skills, function (s)
        local equip = Fk.all_card_types[s.attached_equip]
        return s:isEquipmentSkill(player) and equip and equip.sub_type == Card.SubtypeWeapon
      end)
      if num > 0 then
        player:drawCards(num, self.name)
      end
    end
  end,

  on_lose = function (self, player, is_death)
    player.room:setPlayerMark(player, "@$steam__zhanlu", 0)
  end,
  on_acquire = function (self, player, is_start)
    local room = player.room
    if room:getTag("steam__zhanlu_weapon") == nil then
      local tag = {}
      for _, name in ipairs(Fk.all_card_names) do
        local card = Fk:cloneCard(name)
        if card.sub_type == Card.SubtypeWeapon then
          table.insert(tag, card.name)
        end
      end
      room:setTag("steam__zhanlu_weapon", tag)
    end
  end,
}

local zhanlu_attackrange = fk.CreateAttackRangeSkill{
  name = "#steam__zhanlu_attackrange",
  correct_func = function (self, player, to)
    if player:hasSkill(zhanlu.name) then
      return #player:getTableMark("@$steam__zhanlu")
    end
  end,
}
zhanlu:addRelatedSkill(zhanlu_attackrange)

local zhanlu_filter = fk.CreateFilterSkill{
  name = "#steam__zhanlu_filter",
  card_filter = function(self, card, player)
    return player:hasSkill(zhanlu.name) and card.sub_type == Card.SubtypeWeapon and table.contains(player.player_cards[Player.Hand], card.id)
    and Fk.all_card_types["charm"] ~= nil
  end,
  view_as = function(self, card)
    local c = Fk:cloneCard("charm", card.suit, card.number)
    c.skillName = "steam__zhanlu"
    return c
  end,
}
zhanlu:addRelatedSkill(zhanlu_filter)

hollowknight:addSkill(zhanlu)

Fk:loadTranslationTable{
  ["steam__zhanlu"] = "斩路",
  [":steam__zhanlu"] = "转换技，锁定技，你的武器牌视为【法】。回合结束时，你①从全扩中发现一张武器牌，获得其武器技能并令攻击范围+1；②摸X张牌。(X为你的武器技能数)",
  ["#steam__zhanlu_filter"] = "斩路",
  ["@$steam__zhanlu"] = "斩路",
  ["#steam__zhanlu-card"] = "斩路：选择一把武器，获得此武器的技能！",
}

local jiemeng = fk.CreateTriggerSkill{
  name = "steam__jiemeng",
  anim_type = "control",
  events = {fk.Damage, fk.Damaged},
  times = function (self)
    return 1 - Self:usedSkillTimes(self.name, Player.HistoryRound)
  end,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player:usedSkillTimes(self.name, Player.HistoryRound) == 0
    and data.from and data.from ~= data.to
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local tos = {}
    if data.from and not data.from.dead then
      table.insert(tos, data.from.id)
    end
    if not data.to.dead then
      table.insert(tos, data.to.id)
    end
    local prompt = ""
    if #tos == 1 then
      prompt = "#steam__jiemeng-single:"..tos[1]
    else
      prompt = "#steam__jiemeng-multi:"..tos[1]..":"..tos[2]
    end
    if room:askForSkillInvoke(player, self.name, nil, prompt) then
      self.cost_data = {tos = tos}
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:endTurn()
    local tos = table.map(self.cost_data.tos, Util.Id2PlayerMapper)---@type ServerPlayer[]
    -- 额外回合顺序很乱啊……
    local func = function ()
      for _, to in ipairs(tos) do
        if not to.dead then
          to:gainAnExtraTurn(false, self.name)
        end
      end
    end
    local turn = room.logic:getCurrentEvent():findParent(GameEvent.Turn, true)
    if turn then
      turn:prependExitFunc(func)
    else
      func ()
    end
  end,

  refresh_events = {fk.TurnStart},
  can_refresh = function(self, event, target, player, data)
    return target == player and player:getCurrentExtraTurnReason() == self.name
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    room:sendLog{type = "#SteamWumeiLog", from = player.id}
    room:setPlayerMark(player, "@@steam__jiemeng_wumei", 1)
    local tag = {}
    for _, p in ipairs(room.alive_players) do
      tag[tostring(p.id)] = p.hp
    end
    room:setTag("steam__jiemeng_record", tag)
  end,
}
local jiemeng_delay = fk.CreateTriggerSkill{
  name = "#steam__jiemeng_delay",
  events = {fk.TurnEnd},
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return player == target and player.room:getTag("steam__jiemeng_record") ~= nil
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:notifySkillInvoked(player, jiemeng.name, "special")
    room:setPlayerMark(player, "@@steam__jiemeng_wumei", 0)
    local hp_record = room:getTag("steam__jiemeng_record")
    if type(hp_record) ~= "table" then return false end
    room:setTag("steam__jiemeng_record", nil)
    hp_record = table.simpleClone(hp_record)
    for _, p in ipairs(room:getAlivePlayers()) do
      local p_record = hp_record[tostring(p.id)]
      if p_record then
        p.hp = math.min(p.maxHp, p_record)
        room:broadcastProperty(p, "hp")
      end
    end
  end,
}
jiemeng:addRelatedSkill(jiemeng_delay)

hollowknight:addSkill(jiemeng)

Fk:loadTranslationTable{
  ["steam__jiemeng"] = "揭梦",
  [":steam__jiemeng"] = "每轮限一次，你对其他角色造成伤害，或受到其他角色的伤害后，可以结束当前回合，然后伤害来源与受伤角色各执行一个〖寤寐〗回合。",
  ["@@steam__jiemeng_wumei"] = "寤寐",
  ["#steam__jiemeng-single"] = "揭梦：你可以结束回合，令 %src 执行〖寤寐〗回合",
  ["#steam__jiemeng-multi"] = "揭梦：你可以结束回合，令 %src 与 %dest 依次执行〖寤寐〗回合",
  ["#steam__jiemeng_delay"] = "揭梦",
  ["#SteamWumeiLog"] = "%from 开始了〖寤寐〗回合",
}








return extension
