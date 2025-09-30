local ret = {}

local skel = fk.CreateSkill {
  name = "steam__emoshoutai",
}

Fk:loadTranslationTable{
  ["steam__emoshoutai"] = "恶魔受胎",
  [":steam__emoshoutai"] = "当你受到1点伤害后，你摸两张牌且可以弃置其中一张牌。若弃置了黑色【杀】或黑色单目标锦囊牌，你可以用该牌牌名替换你一个〖重身〗里的牌名。",

  ["#steam__emoshoutai-discard"] = "恶魔受胎：可弃置一张牌，若弃了黑色【杀】或黑色单目标锦囊牌，可用此牌名替换〖重身〗里的牌名",
  ["#steam__emoshoutai-choice"] = "恶魔受胎：你可以用【%arg】替换一个〖重身〗里的牌名",
}

local function getChongshenSkills()
  local chongshenSkills = {"steam__chongshen"}
  for i = 1, 50 do
    table.insert(chongshenSkills, "steam"..i.."__chongshen")
  end
  return table.filter(chongshenSkills, function (skill)
    return Fk.skills[skill] ~= nil
  end)
end

skel:addEffect(fk.Damaged, {
  anim_type = "masochism",
  trigger_times = function (self, event, target, player, data)
    return data.damage
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local ids = player:drawCards(2, skel.name)
    ids = table.filter(ids, function (id) return table.contains(player:getCardIds("he"), id) end)
    if player.dead or #ids == 0 then return end
    local cards = room:askToDiscard(player, {
      min_num = 1, max_num = 1, cancelable = true, include_equip = true, pattern = tostring(Exppattern{ id = ids }),
      skill_name = skel.name, skip = true, prompt = "#steam__emoshoutai-discard"
    })
    if #cards == 0 then return end
    local card = Fk:getCardById(cards[1])
    room:throwCard(cards, skel.name, player, player)
    if not player.dead and card.color == Card.Black and (card.trueName == "slash"
     or (card.type == Card.TypeTrick and not card.multiple_targets)) then
      local chongshenSkills = getChongshenSkills()
      local names = {}
      for _, skill in ipairs(chongshenSkills) do
        if player:hasShownSkill(skill, true) then
          local name = "jink"
          local mark = player:getMark("@"..skill)
          if mark ~= 0 then name = mark end
          if name ~= card.name then
            table.insert(names, name)
          end
        end
      end
      if #names > 0 then
        table.insert(names, "Cancel")
        local choice = room:askToChoice(player, {
          choices = names, skill_name = skel.name, prompt = "#steam__emoshoutai-choice:::"..card.name
        })
        if choice == "Cancel" then return end
        local skill = table.find(chongshenSkills, function (skill)
          if player:hasShownSkill(skill, true) then
            local name = "jink"
            local mark = player:getMark("@"..skill)
            if mark ~= 0 then name = mark end
            return name == choice
          end
        end)
        if skill then
          room:setPlayerMark(player, "@"..skill, card.name)
        end
      end
    end
  end,
})

table.insert(ret, skel)

-- 这么多个重身共有一个记录器
local skel_record = fk.CreateSkill {
  name = "#steam__chongshen_record",
}

skel:addEffect(fk.AfterCardsMove, {
  can_refresh = function(self, event, target, player, data)
    if not player.dead and not player:isKongcheng() then
      return table.find(getChongshenSkills(), function (s)
        return player:hasSkill(s, true)
      end)
    end
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    local hand = player:getCardIds("h")
    for _, move in ipairs(data) do
      if move.to == player and move.toArea == Player.Hand then
        for _, info in ipairs(move.moveInfo) do
          local id = info.cardId
          if table.contains(hand, id) then
            room:setCardMark(Fk:getCardById(id), "@@chongshen-inhand-round", 1)
          end
        end
      end
    end
  end,
})

table.insert(ret, skel_record)

Fk:loadTranslationTable{
  ["@@chongshen-inhand-round"] = "重身", -- 以防服务器没装OL包
  ["@steam__chongshen"] = "重身",
  ["#steam__chongshen-viewas"] = "重身：将一张本轮获得的红色牌当做【%arg】使用",
  [":steam__chongshen_dyn"] = "你可以将一张你于当前轮次内得到的红色牌当【{1}】使用。",
}

for loop = 0, 50, 1 do
  local skel_name = loop == 0 and "steam__chongshen" or "steam"..loop.."__chongshen"
  local skel_chongshen = fk.CreateSkill {
    name = skel_name,
    dynamic_desc = function (self, player, lang)
      local mark = player:getMark("@"..self.name)
      if mark ~= 0 then
        return "steam__chongshen_dyn:"..mark
      end
    end,
  }

  skel_chongshen:addEffect("viewas", {
    pattern = ".|.|.|.|.|basic,trick",
    prompt = function (self, player)
      local name = player:getMark("@"..self.name)
      if name == 0 then name = "jink" end
      return "#steam__chongshen-viewas:::"..name
    end,
    card_filter = function (self, player, to_select, selected)
      if #selected ~= 0 then return false end
      local card = Fk:getCardById(to_select)
      return card.color == Card.Red and card:getMark("@@chongshen-inhand-round") > 0
    end,
    view_as = function (self, player, cards)
      if #cards ~= 1 then return nil end
      local name = player:getMark("@"..self.name)
      if name == 0 then name = "jink" end
      local c = Fk:cloneCard(name)
      c.skillName = self.name
      c:addSubcard(cards[1])
      return c
    end,
    enabled_at_response = function(self, player, response)
      if response or not Fk.currentResponsePattern then return false end
      local name = player:getMark("@"..self.name)
      if name == 0 then name = "jink" end
      return Exppattern:Parse(Fk.currentResponsePattern):matchExp(name)
    end,
    enabled_at_play = function (self, player)
      -- 不用canUse判定是为了看到prompt，看能转化的是啥
      local mark = player:getMark("@"..self.name)
      return mark ~= 0 and not Fk:cloneCard(mark).is_passive
    end,
  })

  skel_chongshen:addLoseEffect(function (self, player, is_death)
    player.room:setPlayerMark(player, "@"..self.name, 0)
  end)

  skel_chongshen:addAcquireEffect(function (self, player, is_start)
    local room = player.room
    room:addSkill("#steam__chongshen_record")
    -- 查询本轮之前获得的红牌
    if not is_start and not player:isKongcheng() then
      local hand = player:getCardIds("h")
      room.logic:getEventsOfScope(GameEvent.MoveCards, 1, function(e)
        for _, move in ipairs(e.data) do
          if move.to == player and move.toArea == Player.Hand then
            for _, info in ipairs(move.moveInfo) do
              local id = info.cardId
              if table.removeOne(hand, id) then
                room:setCardMark(Fk:getCardById(id), "@@chongshen-inhand-round", 1)
              end
            end
          end
        end
        return #hand == 0
      end, Player.HistoryRound)
    end
  end)


  Fk:loadTranslationTable{
    [skel_name] = "重身",
    [":"..skel_name] = "你可以将一张你于当前轮次内得到的红色牌当【闪】使用。",
    ["@"..skel_name] = "重身",
  }
  table.insert(ret, skel_chongshen)
end


return ret
