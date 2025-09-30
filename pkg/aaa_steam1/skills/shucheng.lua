local skel = fk.CreateSkill {
  name = "steam__shucheng",
  dynamic_desc = function (self, player, lang)
    local arg1, arg2 = Fk:translate("steam__shucheng1", lang), Fk:translate("steam__shucheng2", lang)
    local mark = player:getTableMark("steam__shucheng-round")
    if table.contains(mark, "slash") then
      arg1 = "<font color='grey'>" .. arg1 .. "</font>"
    end
    if table.contains(mark, "jink") then
      arg2 = "<font color='grey'>" .. arg2 .. "</font>"
    end
    return "steam__shucheng_inner:" .. arg1 .. ":" .. arg2
  end,
}

Fk:loadTranslationTable{
  ["steam__shucheng"] = "戍城",
  [":steam__shucheng"] = "每轮各限一次，你可以弃置你与一名手牌数最多者的各一张牌/与一名手牌数最少者各摸一张牌以视为使用一张【杀】/【闪】。",

  [":steam__shucheng_inner"] = "每轮各限一次，你可以{1}/{2}以视为使用一张【杀】/【闪】。",
  ["steam__shucheng1"] = "弃置你与一名手牌数最多者的各一张牌",
  ["steam__shucheng2"] = "与一名手牌数最少者各摸一张牌",

  ["#steam__shucheng-jink"] = "戍城:你可以与一名手牌数最少者各摸一张牌，视为使用一张【闪】",
  ["#steam__shucheng-slash"] = "戍城:你可以弃置你与一名手牌数最多者的各一张牌，视为使用一张【杀】",
  ["#steam__shucheng-choose-jink"] = "戍城:选择1名手牌数最少的角色，你与其各摸一张牌",
  ["#steam__shucheng-choose-slash"] = "戍城:选择1名手牌数最多的角色，你弃置你与其各一张牌",
}

---@param player Player @ 使用者
---@param name string @ 使用牌名
---@param using? boolean @ 是否已使用（使用时会清空pattern数据）
---@return Player[]
local getShuchengTars = function (player, name, using)
  local skillName = "steam__shucheng"
  if table.contains(player:getTableMark("steam__shucheng-round"), name) then return {} end
  local card = Fk:cloneCard(name)
  card.skillName = skillName
  if player:prohibitUse(card) then return {} end
  if not using then
    if Fk.currentResponsePattern == nil then
      if not player:canUse(card) then return {} end
    else
      if not Exppattern:Parse(Fk.currentResponsePattern):matchExp(name) then return {} end
    end
  end
  local max, min = 0, 9999
  local players = Fk:currentRoom().alive_players
  for _, p in ipairs(players) do
    min = math.min(min, p:getHandcardNum())
    max = math.max(max, p:getHandcardNum())
  end
  if name == "jink" then
    return table.filter(players, function(p) return p:getHandcardNum() == min end)
  else
    local ret = table.filter(players, function(p) return p:getHandcardNum() == max and not p:isNude() end)
    if #table.filter(player:getCardIds("he"), function (id)
      return not player:prohibitDiscard(id)
    end) < 2 then table.removeOne(ret, player) end -- 弃自己2牌的情况
    return ret
  end
end

skel:addEffect("viewas", {
  pattern = "slash,jink",
  times = function (self, player)
    return 2 - #player:getTableMark("steam__shucheng-round")
  end,
  prompt = function (self, player)
    if Fk.currentResponsePattern and Exppattern:Parse(Fk.currentResponsePattern):matchExp("jink") then
      return "#steam__shucheng-jink"
    end
    return "#steam__shucheng-slash"
  end,
  interaction = function(self, player)
    local names = table.filter({"slash", "jink"}, function (name)
      return #getShuchengTars(player, name) > 0
    end)
    if #names == 0 then return end
    return UI.CardNameBox {choices = names, all_choices = {"slash", "jink"}}
  end,
  card_filter = Util.FalseFunc,
  before_use = function (self, player, use)
    local room = player.room
    local name = use.card.name
    local targets = getShuchengTars(player, name, true)
    if #targets == 0 then return self.name end
    room:addTableMark(player, "steam__shucheng-round", name)
    local tos = room:askToChoosePlayers(player, {
      min_num = 1, max_num = 1, targets = targets, skill_name = skel.name,
      cancelable = false, prompt = "#steam__shucheng-choose-"..name,
    })
    local to = tos[1]
    if name == "jink" then
      player:drawCards(1, self.name)
      if not to.dead then
        to:drawCards(1, self.name)
      end
    else
      for _, p in ipairs({player, to}) do
        if not p:isNude() then
          if p ~= player then
            local cid = room:askToChooseCard(player, { target = p, flag = "he", skill_name = self.name})
            room:throwCard(cid, self.name, p, player)
          else
            room:askToDiscard(player, {min_num = 1, max_num = 1, include_equip = true, skill_name = skel.name, cancelable = false})
          end
        end
      end
    end
  end,
  view_as = function(self)
    if not self.interaction.data then return end
    local card = Fk:cloneCard(self.interaction.data)
    card.skillName = self.name
    return card
  end,
  enabled_at_play = function(self, player)
    return player:canUse(Fk:cloneCard("slash")) and #getShuchengTars(player, "slash") > 0
  end,
  enabled_at_response = function(self, player, response)
    if not response and Fk.currentResponsePattern then
      for _, name in ipairs({"slash","jink"}) do
        if #getShuchengTars(player, name) > 0 then
          return true
        end
      end
    end
  end,
})

return skel
