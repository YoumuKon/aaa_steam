local ret = {}

Fk:loadTranslationTable{
  ["#steam__yonghengxinyang-ask"] = "永恒信仰：你可以选择一个花色，令拥有〖永恒信仰〗的角色各摸一张该花色的牌。",
}

for loop = 0, 10 do
  local skel_name = loop == 0 and "steam__yonghengxinyang" or "steam"..loop.."__yonghengxinyang"
  local skel = fk.CreateSkill {
    name = skel_name,
  }
  skel:addEffect(fk.AfterCardsMove, {
    anim_type = "drawcard",
    times = function (_, player)
      return 1 - player:usedSkillTimes(skel.name, Player.HistoryPhase)
    end,
    can_trigger = function(self, event, target, player, data)
      if player:hasSkill(skel.name) and player:usedSkillTimes(skel.name, Player.HistoryPhase) == 0 then
        for _, move in ipairs(data) do
          if move.from == player and move.moveReason == fk.ReasonDiscard then
            for _, info in ipairs(move.moveInfo) do
              if info.fromArea == Player.Hand or info.fromArea == Player.Equip then
                return true
              end
            end
          end
        end
      end
    end,
    on_cost = function (self, event, target, player, data)
      local room = player.room
      local suits = {"log_spade", "log_heart", "log_diamond", "log_club", "Cancel"}
      local choice = room:askToChoice(player, { choices = suits, skill_name = skel.name, prompt = "#steam__yonghengxinyang-ask"})
      if choice == "Cancel" then return false end
      local tos = {}
      for _, p in ipairs(room:getAlivePlayers()) do
        if table.find(p:getSkillNameList(), function(s) return s:endsWith("yonghengxinyang") end) then
          table.insert(tos, p)
        end
      end
      event:setCostData(self, {choice = choice:sub(5, -1), tos = tos})
      return true
    end,
    on_use = function(self, event, target, player, data)
      local room = player.room
      local suit = event:getCostData(self).choice
      for _, to in ipairs(event:getCostData(self).tos) do
        if not to.dead then
          local ids = room:getCardsFromPileByRule(".|.|"..suit)
          if #ids > 0 then
            room:obtainCard(to, ids, true, fk.ReasonJustMove, player, skel.name)
          end
        end
      end
    end,
  })

  Fk:loadTranslationTable{
    [skel_name] = "永恒信仰",
    [":"..skel_name] = "每阶段限一次，你的牌被弃置后，你可以选择一个花色，令拥有〖永恒信仰〗的角色各摸一张该花色的牌。",
  }
  table.insert(ret, skel)
end

return ret
