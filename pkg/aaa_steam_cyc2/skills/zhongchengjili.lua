local skel = fk.CreateSkill {
  name = "steam__zhongchengjili",
  attached_skill_name = "steam__zhongchengjili&",
}

Fk:loadTranslationTable{
  ["steam__zhongchengjili"] = "忠诚激励",
  [":steam__zhongchengjili"] = "每名角色的出牌阶段限一次，其可以请求发动一次〖苦肉〗，若你同意，其视为使用一张【散】。",

  ["steam__zhongchengjili&"] = "苦肉",
  [":steam__zhongchengjili&"] = "出牌阶段限一次，你可以请求发动一次〖苦肉〗，若“忠诚激励”拥有者同意，你视为使用一张【散】。",
  ["#steam__zhongchengjili"] = "你可以〖苦肉〗，然后视为使用一张【散】",
  ["#steam__zhongchengjili-other"] = "你可以请求发动〖苦肉〗，若被同意，你视为使用【散】",
  ["#steam__zhongchengjili-ask"] = "忠诚激励：是否同意 %src 发动〖苦肉〗？",
  ["steam__zhongchengjili_owner"] = "请求对象",
  ["#steam__zhongchengjili-choose-owner"] = "忠诚激励：请选择请求对象",

  ["$steam__zhongchengjili1"] = "把水搅浑",
  ["$steam__zhongchengjili2"] = "这就叫合作",
}

skel:addEffect("active", {
  anim_type = "drawcard",
  card_num = 0,
  target_num = 0,
  card_filter = Util.FalseFunc,
  target_filter = Util.FalseFunc,
  prompt = "#steam__zhongchengjili",
  times = function (self, player)
    return 1 - player:usedSkillTimes(self.name, Player.HistoryPhase)
  end,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    room:loseHp(player, 1, self.name)
    if player.dead then return end
    player:drawCards(2, self.name)
    if player.dead then return end
    room:useVirtualCard("drugs", nil, player, player, self.name, true)
  end,
})

local skel2 = fk.CreateSkill {
  name = "steam__zhongchengjili&",
}

skel2:addEffect("active", {
  anim_type = "drawcard",
  card_num = 0,
  target_num = 0,
  card_filter = Util.FalseFunc,
  target_filter = Util.FalseFunc,
  prompt = "#steam__zhongchengjili-other",
  target_tip = function (self, player, to, selected)
    if to ~= player and to:hasSkill(skel.name) then
      return "steam__zhongchengjili_owner"
    end
  end,
  times = function (self, player)
    return 1 - player:usedSkillTimes(self.name, Player.HistoryPhase)
  end,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0 and
    table.find(Fk:currentRoom().alive_players, function(p)
      return p ~= player and p:hasSkill(skel.name)
    end)
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local targets = table.filter(room.alive_players, function(p)
      return p ~= player and p:hasSkill(skel.name)
    end)
    if #targets == 0 then return end
    local owner = targets[1]
    if #targets > 1 then
      owner = room:askToChoosePlayers(player, { targets = targets, min_num = 1, max_num = 1,
      prompt = "#steam__zhongchengjili-choose-owner", skill_name = self.name, cancelable = false})[1]
    end
    if not room:askToSkillInvoke(owner, { skill_name = self.name, prompt = "#steam__zhongchengjili-ask:"..player.id}) then return end
    owner:broadcastSkillInvoke(skel.name)
    room:doIndicate(owner, {player})
    room:loseHp(player, 1, self.name)
    if player.dead then return end
    player:drawCards(2, self.name)
    if player.dead then return end
    room:useVirtualCard("drugs", nil, player, player, self.name, true)
  end,
})

return {skel, skel2}
