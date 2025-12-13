local extension = Package:new("aaa_steam_token", Package.CardPack)
extension.extensionName = "aaa_steam"

Fk:loadTranslationTable{
  ["aaa_steam_token"] = "蒸衍生牌",
}

local dice = fk.CreateCard{
  name = "&dice",
  type = Card.TypeBasic,
  skill = "dice_skill",
}
extension:addCardSpec("dice", Card.Club, 1)
Fk:loadTranslationTable{
  ["dice"] = "骰",
  [":dice"] = "基本牌<br/><b>效果</b>：没有效果，仅用于丢骰子。",
}

local halberd = fk.CreateCard{
  name = "&steam_halberd",
  type = Card.TypeEquip,
  sub_type = Card.SubtypeWeapon,
  attack_range = 4,
  equip_skill = "#steam_halberd_skill",
}
extension:addCardSpec("steam_halberd", Card.Diamond, 12)
Fk:loadTranslationTable{
  ["steam_halberd"] = "无双方天戟",
  [":steam_halberd"] = "装备牌·武器<br/><b>攻击范围</b>：4<br/><b>武器技能</b>：你使用【杀】对目标角色造成伤害后，你可以摸一张牌或弃置其一张牌。",
}

local dragonPhoenix = fk.CreateCard{
  name = "&steam_dragon_phoenix",
  type = Card.TypeEquip,
  sub_type = Card.SubtypeWeapon,
  attack_range = 2,
  equip_skill = "#steam_dragon_phoenix_skill",
}
extension:addCardSpec("steam_dragon_phoenix", Card.Spade, 2)
Fk:loadTranslationTable{
  ["steam_dragon_phoenix"] = "飞龙夺凤",
  [":steam_dragon_phoenix"] = "装备牌·武器<br/><b>攻击范围</b>：2<br/><b>武器技能</b>：①当你使用【杀】指定目标后，你可令目标弃置一张牌。②当一名角色因执行你使用的【杀】的效果而受到你造成的伤害而进入濒死状态后，你可获得其一张手牌。",
}

local forgottencard = fk.CreateCard{
  name = "&forgottencard",
  type = Card.TypeEquip,
  sub_type = Card.SubtypeArmor,
  --equip_skill = "#forgottencard_skill",
  skill = "dice_skill", -- 没法使用
}
extension:addCardSpec("forgottencard", Card.Spade, 1)
Fk:loadTranslationTable{
  ["forgottencard"] = "堕化遗骸",
  [":forgottencard"] = "装备牌·防具<br/><b>防具技能</b>：无法使用。当此牌离开手牌区后，令“堕化遗骸”复位并摸两张牌。",
}

local zhushen = fk.CreateCard{
  name = "&steam_zhushen_equip",
  type = Card.TypeEquip,
  sub_type = Card.SubtypeTreasure,
  equip_skill = "steam_zhushen_equip_skill&",
  on_uninstall = function(self, room, player)
    Treasure.onUninstall(self, room, player)
    player:setSkillUseHistory(self.equip_skill.name, 0, Player.HistoryTurn)
  end,
}
extension:addCardSpec("steam_zhushen_equip", Card.Diamond, 9)
Fk:loadTranslationTable{
  ["steam_zhushen_equip"] = "古旧铸物",
  [":steam_zhushen_equip"] = "装备牌·宝物<br/>"..
  "<b>宝物技能</b>：每回合限一次，你可以将所有“铸神”选择花色的手牌当“铸神”发现的牌使用并摸一张牌。此牌离开你的装备区时销毁，销毁后年摸一张牌。",
}

local kurong = fk.CreateCard{
  name = "&steam_kurong_equip",
  type = Card.TypeEquip,
  sub_type = Card.SubtypeWeapon,
  attack_range = 1,
  dynamic_attack_range = function(self, player)
    if player then
      return player:getMark("@steam_kurong_equip")
    end
  end,
  equip_skill = "#steam_kurong_equip_skill",
}
extension:addCardSpec("steam_kurong_equip", Card.Heart, 6)
Fk:loadTranslationTable{
  ["steam_kurong_equip"] = "嫩竹",
  [":steam_kurong_equip"] = "装备牌·武器<br/><b>攻击范围</b>：1<br/><b>武器技能</b>：每轮结束时，此牌攻击范围+1。"..
  "每轮限一次，你使用牌时，可以弃置一张牌，额外指定一名合法目标。此牌离开装备区后销毁。",
}

local shuheng = fk.CreateCard{
  name = "&steam_shuheng_equip",
  type = Card.TypeEquip,
  sub_type = Card.SubtypeArmor,
  equip_skill = "#steam_shuheng_equip_skill",
}
extension:addCardSpec("steam_shuheng_equip", Card.Spade, 1)
Fk:loadTranslationTable{
  ["steam_shuheng_equip"] = "拳经三问",
  [":steam_shuheng_equip"] = "装备牌·防具<br/>"..
  "<b>防具技能</b>：每轮限三次，你造成或受到伤害时，可以摸两张牌再弃置两张牌。",
}

local ranjing = fk.CreateCard{
  name = "&steam_ranjing_equip",
  type = Card.TypeEquip,
  sub_type = Card.SubtypeArmor,
  equip_skill = "#steam_ranjing_equip_skill",
}
extension:addCardSpec("steam_ranjing_equip", Card.Spade, 11)
Fk:loadTranslationTable{
  ["steam_ranjing_equip"] = "旦夕墨宝",
  [":steam_ranjing_equip"] = "装备牌·防具<br/>"..
  "<b>防具技能</b>：每轮限一次，你受到伤害后，可以于本回合结束后执行一个额外回合，此回合开始时，未装备【旦夕墨宝】的角色"..
  "视为被移出游戏。此牌不能被其他角色弃置，且离开装备区后销毁。",
}

local zuitan = fk.CreateCard{
  name = "&steam_zuitan_equip",
  type = Card.TypeEquip,
  sub_type = Card.SubtypeArmor,
  equip_skill = "steam_zuitan_equip_skill&",
}
extension:addCardSpec("steam_zuitan_equip", Card.Club, 3)
Fk:loadTranslationTable{
  ["steam_zuitan_equip"] = "散轶诗简",
  [":steam_zuitan_equip"] = "装备牌·防具<br/>"..
  "<b>防具技能</b>：每轮限一次，你失去最后的手牌后可以摸一张【酒】。此牌进入弃牌堆后销毁。",
}

local baizao = fk.CreateCard{
  name = "&steam_baizao_equip",
  type = Card.TypeEquip,
  sub_type = Card.SubtypeTreasure,
  equip_skill = "steam_baizao_equip_skill&",
  on_uninstall = function(self, room, player)
    Treasure.onUninstall(self, room, player)
    player:setSkillUseHistory("steam_baizao_equip_skill&", 0, Player.HistoryPhase)
  end,
}
extension:addCardSpec("steam_baizao_equip", Card.Heart, 12)
Fk:loadTranslationTable{
  ["steam_baizao_equip"] = "家常小炒",
  [":steam_baizao_equip"] = "装备牌·宝物<br/>"..
  "<b>宝物技能</b>：出牌阶段各限一次，你可以弃置一张基本/非基本牌，然后摸一张属性/可食用牌。此牌离开你的装备区后销毁。",
}

local randomcard = fk.CreateCard{
  name = "&steam_randomcard",
  type = Card.TypeBasic,
  skill = "steam_randomcard_skill",
}
extension:addCardSpec("steam_randomcard", Card.Diamond, 13)
Fk:loadTranslationTable{
  ["steam_randomcard"] = "随机",
  [":steam_randomcard"] = "锦囊牌<br/><b>效果</b>：初始无法使用。当你使用一张牌后，本牌随机变化为一张基本或普通锦囊牌。(保留此效果)",
}

local befriendAttacking = fk.CreateCard{
  name = "&steam__befriend_attacking", -- 衍生避免被检索
  skill = "steam__befriend_attacking_skill",
  type = Card.TypeTrick,
}
--extension:addCardSpec("steam__befriend_attacking", Card.Heart, 9)

extension:loadCardSkels {
  dice,

  halberd,
  dragonPhoenix,
  forgottencard,
  zhushen,
  kurong,
  ranjing,
  shuheng,
  baizao,
  zuitan,
  randomcard,

  befriendAttacking,
}

return extension
