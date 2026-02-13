local skill = fk.CreateSkill {
  name = "steam_qihe_equip_yin&",
}

Fk:loadTranslationTable{
  ["steam_qihe_equip_yin&"] = "云与漆（阴）",
  [":steam_qihe_equip_yin&"] = "你可以选择一名【云与漆】为阴分支的角色，移动其场上的一张牌；以视为使用一张【杀/闪】。",

  ["#steam_qihe_equip2"] = "云与漆（阴）：视为使用【杀】/【闪】，随后选择一名云与漆为阴分支的角色，移动其场上一张牌。",

  ["#steam_qihe_equip_yin-choose"] = "云与漆：请选择一名云与漆为阴分支的角色，移动其场上一张牌。",
  ["#steam_qihe_equip_yin-move"] = "云与漆：请选择一名角色，将%dest场上的一张牌移动给其。",
}

local U = require "packages.utility.utility"

---@param player Player|ServerPlayer
---@return ServerPlayer[]
local qiheMatch = function (player)
  local list = {}
  for _, p in ipairs(Fk:currentRoom().alive_players) do
    if p:hasSkill("steam_qihe_equip_skill&") and #p:getCardIds("ej") > 0 and
      p:getSwitchSkillState("steam_qihe_equip_skill&", false) == fk.SwitchYin then
      for _, id in ipairs(p:getCardIds("ej")) do
        for _, ps in ipairs(Fk:currentRoom().alive_players) do
          if ps ~= p and p:canMoveCardInBoardTo(ps, id) then
            table.insertIfNeed(list, p)
          end
        end
      end
    end
  end
  return list
end

--与阳部分独立
skill:addEffect("viewas", {
  pattern = "slash,jink",
  prompt = function (self, player, selected_cards, selected_targets)
    return "#steam_qihe_equip2"
  end,
  interaction = function(self, player)
    local names = player:getViewAsCardNames(skill.name, {"slash", "jink"})
    return UI.CardNameBox {choices = names, all_choices = {"slash", "jink"}}
  end,
  card_filter = Util.FalseFunc,
  view_as = function(self)
    if not self.interaction.data then return end
    local card = Fk:cloneCard(self.interaction.data)
    card.skillName = skill.name
    return card
  end,
  before_use = function (self, player, use)
    local switcher = player.room:askToChoosePlayers(player, {
      targets = qiheMatch(player),
      min_num = 1,
      max_num = 1,
      prompt = "#steam_qihe_equip_yin-choose",
      skill_name = skill.name,
      cancelable = false,
    })[1]
    U.SetSwitchSkillState(switcher, "steam_qihe_equip_skill&", fk.SwitchYang)
    local list = {}
    for _, id in ipairs(switcher:getCardIds("ej")) do
      for _, p in ipairs(player.room.alive_players) do
        if p ~= switcher and switcher:canMoveCardInBoardTo(p, id) then
          table.insertIfNeed(list, p)
        end
      end
    end
    local taker = player.room:askToChoosePlayers(player, {
      targets = list,
      min_num = 1,
      max_num = 1,
      prompt = "#steam_qihe_equip_yin-move::"..switcher.id,
      skill_name = skill.name,
      cancelable = false,
    })[1]
    player.room:askToMoveCardInBoard(player, { target_one = switcher, target_two = taker, move_from = switcher, skill_name = skill.name })
  end,
  enabled_at_play = function(self, player)
    return #player:getViewAsCardNames(skill.name, {"slash"}) > 0 and #qiheMatch(player) > 0
  end,
  enabled_at_response = function(self, player, response)
    return not response and #player:getViewAsCardNames(skill.name, {"slash", "jink"}) > 0 and #qiheMatch(player) > 0
  end,
})

return skill
