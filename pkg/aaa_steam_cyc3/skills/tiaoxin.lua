local skels = {}

Fk:loadTranslationTable{
  ["steam__tiaoxin"] = "挑衅",
  [":steam__tiaoxin"] = "出牌阶段限一次，你可以令一名其他角色选择：1.对你使用一张【杀】；2.你弃置其一张牌。",
  ["$steam__tiaoxin_steam__shakra1"] = "（虫语）",
  ["$steam__tiaoxin_steam__shakra2"] = "（虫语）",
}

for loop = 0, 30 do
  local tiaoxin = fk.CreateSkill{
    name = loop == 0 and "steam__tiaoxin" or "steam"..loop.."__tiaoxin",
    dynamic_name = function (self, player, lang)
      local name = "挑衅"
      local src = (loop == 0 and "steam__tiaoxin" or "steam"..loop.."__tiaoxin").."record"
      if player:getMark(src) ~= 0 then
        name = "挑衅("..string.sub(Fk:translate(player:getMark(src)), 1, 6)..")"
      end
      return name
    end,
  }

  tiaoxin:addEffect("active", {
    anim_type = "control",
    max_phase_use_time = 1,
    card_num = 0,
    target_num = 1,
    can_use = function(self, player)
      if player:getMark(tiaoxin.name.."record") ~= 0 then
        return player:getMark(player:getMark(tiaoxin.name.."record").."-phase") == 0
      else
        return player:usedSkillTimes(tiaoxin.name, Player.HistoryPhase) == 0
      end
    end,
    card_filter = Util.FalseFunc,
    target_filter = function(self, player, to_select, selected)
      return #selected == 0 and to_select ~= player
    end,
    mute = true,
    on_use = function(self, room, effect)
      local player = effect.from
      local target = effect.tos[1]
      room:notifySkillInvoked(player, "steam__tiaoxin", "control")
      player:broadcastSkillInvoke("steam__tiaoxin")
      room:addPlayerMark(player, player:getMark(tiaoxin.name.."record").."-phase", 1)
      local use = room:askToUseCard(target, {
        skill_name = tiaoxin.name,
        pattern = "slash",
        prompt = "#tiaoxin-use:"..player.id,
        extra_data = {
          exclusive_targets = {player.id},
          bypass_times = true,
        }
      })
      if use then
        use.extraUse = true
        room:useCard(use)
      else
        if not target:isNude() then
          local card = room:askToChooseCard(player, {
            target = target,
            skill_name = tiaoxin.name,
            flag = "he",
          })
          room:throwCard(card, tiaoxin.name, target, player)
          if player:getMark(tiaoxin.name.."record") ~= 0 then
            room:askToUseRealCard(player, {
              skill_name = "steam__zhange",
              pattern = {card},
              prompt = "#steam__zhange-use",
              extra_data = {
                bypass_times = true,
                extraUse = true,
                expand_pile = {card},
              },
            })
          end
        end
      end
    end,
  })

  Fk:loadTranslationTable{
    ["steam"..loop.."__tiaoxin"] = "挑衅",
    [":steam"..loop.."__tiaoxin"] = "出牌阶段限一次，你可以令一名其他角色选择：1.对你使用一张【杀】；2.你弃置其一张牌。",
  }

  table.insert(skels, tiaoxin)
end

return skels
