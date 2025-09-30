-- 根据手牌数获取复古牌名
local getFuguName = function (num)
  local names = Fk:currentRoom():getBanner("steam__fugu_names")
  if names == nil then
    names = {"", "nullification", "amazing_grace", "peach"}
  end
  if Fk.all_card_types[names[num]] then
    return names[num]
  end
  return nil
end

local skel = fk.CreateSkill {
  name = "steam__fugu",
  attached_skill_name = "steam__fugu&",
  dynamic_desc = function (self, player, lang)
    local names = Fk:currentRoom():getBanner("steam__fugu_names")
    if names == nil then return "steam__fugu" end
    return "steam__fugu_dyn:" .. names[4] .. ":" .. names[3] .. ":" .. names[2]
  end,
}

Fk:loadTranslationTable{
  ["steam__fugu"] = "复古",
  [":steam__fugu"] = "所有角色每回合限一次，其可以根据其手牌数，将两张牌按照以下规则使用：四张，【桃】；三张，【五谷丰登】；两张，【无懈可击】。",

  ["#steam__fugu"] = "复古：你可以将两张牌当【%arg】使用",
  [":steam__fugu_dyn"] = "所有角色每回合限一次，其可以根据其手牌数，将两张牌按照以下规则使用：四张，【{1}】；三张，【{2}】；两张，【{3}】。",

  ["steam__fugu&"] = "复古",
  [":steam__fugu&"] = "每回合限一次，你可以根据手牌数，将两张牌按照以下规则使用：四张，【桃】；三张，【五谷丰登】；两张，【无懈可击】。",
  [":steam__fugu_dyn&"] = "每回合限一次，你可以根据手牌数，将两张牌按照以下规则使用：四张，【{1}】；三张，【{2}】；两张，【{3}】。",
}

skel:addEffect("viewas", {
  pattern = ".|.|.|.|.|trick,basic",
  prompt = function (self, player)
    local name = getFuguName(player:getHandcardNum())
    if name then
      return "#steam__fugu:::"..name
    end
    return " "
  end,
  handly_pile = true,
  card_filter = function(self, _, to_select, selected)
    return #selected < 2
  end,
  view_as = function(self, player, cards)
    if #cards ~= 2 then return nil end
    local name = getFuguName(player:getHandcardNum())
    if name == nil then return nil end
    local c = Fk:cloneCard(name)
    c.skillName = self.name
    c:addSubcards(cards)
    return c
  end,
  times = function (self, player)
    return 1 - player:usedSkillTimes(self.name)
  end,
  enabled_at_play = function(self, player)
    if player:usedSkillTimes(self.name) == 0 and player:getHandcardNum() > 1 and player:getMark("steam__fugu_forbid") == 0 then
      local name = getFuguName(player:getHandcardNum())
      if name then
        local card = Fk:cloneCard(name)
        return player:canUse(card)
      end
    end
  end,
  enabled_at_response = function (self, player, response)
    if player:usedSkillTimes(self.name) == 0 and player:getHandcardNum() > 1 and player:getMark("steam__fugu_forbid") == 0 then
      if not response and Fk.currentResponsePattern then
        local name = getFuguName(player:getHandcardNum())
        return name and Exppattern:Parse(Fk.currentResponsePattern):match(Fk:cloneCard(name))
      end
    end
  end,
})

local skel2 = fk.CreateSkill {
  name = "steam__fugu&",
  dynamic_desc = function (self, player, lang)
    local names = Fk:currentRoom():getBanner("steam__fugu_names")
    if names == nil then return "steam__fugu&" end
    return "steam__fugu_dyn&:" .. names[4] .. ":" .. names[3] .. ":" .. names[2]
  end,
}

skel2:addEffect("viewas", {
  pattern = ".|.|.|.|.|trick,basic",
  prompt = function (self, player)
    local name = getFuguName(player:getHandcardNum())
    if name then
      return "#steam__fugu:::"..name
    end
    return " "
  end,
  handly_pile = true,
  card_filter = function(self, _, _, selected)
    return #selected < 2
  end,
  view_as = function(self, player, cards)
    if #cards ~= 2 then return nil end
    local name = getFuguName(player:getHandcardNum())
    if name == nil then return nil end
    local c = Fk:cloneCard(name)
    c.skillName = self.name
    c:addSubcards(cards)
    return c
  end,
  times = function (self, player)
    return 1 - player:usedSkillTimes(self.name)
  end,
  enabled_at_play = function(self, player)
    if player:usedSkillTimes(self.name) == 0 and player:getHandcardNum() > 1 and player:getMark("steam__fugu_forbid") == 0 then
      local name = getFuguName(player:getHandcardNum())
      if name then
        local card = Fk:cloneCard(name)
        return player:canUse(card)
      end
    end
  end,
  enabled_at_response = function (self, player, response)
    if player:usedSkillTimes(self.name) == 0 and player:getHandcardNum() > 1 and player:getMark("steam__fugu_forbid") == 0 then
      if not response and Fk.currentResponsePattern then
        local name = getFuguName(player:getHandcardNum())
        return name and Exppattern:Parse(Fk.currentResponsePattern):match(Fk:cloneCard(name))
      end
    end
  end,
  before_use = function (self, player, use)
    player:broadcastSkillInvoke("steam__fugu")
  end,
})

return {skel, skel2}
