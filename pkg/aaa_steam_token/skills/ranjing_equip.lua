local skill = fk.CreateSkill {
  name = "#steam_ranjing_equip_skill",
  attached_equip = "steam_ranjing_equip",
}

local DIY = require "packages/diy_utility/diy_utility"

Fk:loadTranslationTable{
  ["#steam_ranjing_equip_skill"] = "旦夕墨宝",
  [":#steam_ranjing_equip_skill"] = "每轮限一次，你受到伤害后，可以于本回合结束后执行一个额外回合，此回合内，未装备【旦夕墨宝】的角色"..
  "视为被移出游戏。此牌不能被其他角色弃置，且离开装备区后销毁。",

  ["@@steam_ranjing_getturn"] = "将获得墨宝回合",
  ["@@steam_ranjing_inturn-turn"] = "旦夕墨宝 回合",
}

skill:addEffect(fk.Damaged, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    if player.room.logic:getCurrentEvent():findParent(GameEvent.Round, true) == nil then return end
    return target == player and player:hasSkill(skill.name) and player:usedSkillTimes(skill.name, Player.HistoryRound) == 0
  end,
  on_use = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "@@steam_ranjing_getturn", 1)
    player:gainAnExtraTurn(true, skill.name, nil, {
      steam_ranjing_source = player,
    })
  end,
})

--实际上：回合开始时，未装备旦夕墨宝的角色就被移出游戏，因为无法处理检测装备区变化后干涉其他移出游戏效果的问题
skill:addEffect(fk.BeforeTurnStart, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return target == player and data.extra_data and data.extra_data.steam_ranjing_source
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "@@steam_ranjing_getturn", 0)
    player.room:setPlayerMark(player, "@@steam_ranjing_inturn-turn", 1)
    for _, p in ipairs (player.room.alive_players) do
      if not table.find(p:getCardIds("e"), function (id) return Fk:getCardById(id).name == "steam_ranjing_equip" and
        Fk:getCardById(id).sub_type == Card.SubtypeArmor end) then
        DIY.removePlayer(p, "-turn")
      end
    end
  end,
})

return skill
