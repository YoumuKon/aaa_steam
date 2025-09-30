local yinglin = fk.CreateSkill {
  name = "steam__yinglin",
}

Fk:loadTranslationTable{
  ["steam__yinglin"] = "盈廪",
  [":steam__yinglin"] = "出牌阶段限一次，你可以将一张能使你<a href=':steam__isGetCard'>获得牌</a>/<a href=':steam__isRecoverCard'>回复体力</a>的牌当【五谷丰登】/【桃园结义】使用。",

  ["#steam__yinglin"] = "盈廪：你可以将一张能使你获得牌/回复体力的牌当【五谷丰登】/【桃园结义】使用。",
  [":steam__isGetCard"] = "可获得牌的牌：无中生有，顺手牵羊，借刀杀人，五谷丰登，铁索连环，无双方天戟，飞龙夺凤，树上开花，推心置腹，趁火打劫，草木皆兵，增兵减灶，金蝉脱壳，"..
  "洞烛先机，逐近弃远，天机图，太公阴符，解甲归田，草船借箭，逐鹿天下，古旧铸物，拳经三问，散佚诗简，家常小炒",
  [":steam__isRecoverCard"] = "回复类牌：桃，酒，散，桃园结义，白银狮子，刮骨疗毒",

  ["$steam__yinglin1"] = "清明宜晴，谷雨宜雨。",
  ["$steam__yinglin2"] = "春风化物，正当节令。",
}

---@param card Card
---@return boolean
--根据3D常见定义名单，穷举出的可获得牌牌表
local isGetCard = function (card)
  local list = {"ex_nihilo", "snatch", "collateral", "amazing_grace", "iron_chain", "steam_halberd", "steam_dragon_phoenix", "bogus_flower", "sincere_treat", "looting",
  "paranoid", "reinforcement", "crafty_escape", "foresight", "chasing_near", "wonder_map", "taigong_tactics", "demobilized", "borrow_arrows", "certamen",
  "steam_zhushen_equip", "steam_shuheng_equip", "steam_zuitan_equip", "steam_baizao_equip",}
  return table.contains(list, card.trueName)
end

---@param card Card
---@return boolean
--根据3D常见定义名单，穷举出的回复类牌牌表
local isRecoverCard = function (card)
  local list = {"peach", "analeptic", "god_salvation", "silver_lion", "drugs", "scrape_poison"}
  return table.contains(list, card.trueName)
end

yinglin:addEffect("viewas", {
  anim_type = "offensive",
  prompt = "#steam__yinglin",
  handly_pile = true,
  card_filter = function (self, player, to_select, selected)
    return #selected == 0 and (isGetCard(Fk:getCardById(to_select)) or isRecoverCard(Fk:getCardById(to_select)))
  end,
  view_as = function(self, player, cards)
    if #cards ~= 1 then return end
    local name = ""
    if isGetCard(Fk:getCardById(cards[1])) then name = "amazing_grace" end
    if isRecoverCard(Fk:getCardById(cards[1])) then name = "god_salvation" end
    if name == "" then return end
    local c = Fk:cloneCard(name)
    c.skillName = yinglin.name
    c:addSubcard(cards[1])
    return c
  end,
  enabled_at_play = function(self, player)
    return player:usedSkillTimes(yinglin.name, Player.HistoryPhase) == 0
  end,
})

return yinglin
