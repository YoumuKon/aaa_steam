local skel = fk.CreateSkill {
  name = "steam__yongshengzhilu",
  tags = {Skill.Compulsory, Skill.Switch},
}

Fk:loadTranslationTable{
  ["steam__yongshengzhilu"] = "永生之路",
  [":steam__yongshengzhilu"] = "锁定技，转换技，准备阶段，你弃置三张【法】并：①随机获得一个含有“造成1点伤害”的技能；②加1点体力上限并回复1点体力。",

  [":steam__yongshengzhilu_yang"] = "锁定技，转换技，准备阶段，你弃置三张【法】并：<font color=\"#E0DB2F\">①随机获得一个含有“造成1点伤害”的技能；</font>②加1点体力上限并回复1点体力。",
  [":steam__yongshengzhilu_yin"] = "锁定技，转换技，准备阶段，你弃置三张【法】并：①随机获得一个含有“造成1点伤害”的技能；<font color=\"#E0DB2F\">②加1点体力上限并回复1点体力。</font>",

  ["#steam__yongshengzhilu-choice"] = "永生之路：选择一个技能获得！",
  ["$steam__yongshengzhilu1"] = "嗯！",
  ["$steam__yongshengzhilu2"] = "嗯啦——",
}

skel:addEffect(fk.EventPhaseStart, {
  anim_type = "switch",
  can_trigger = function (self, event, target, player, data)
    if player:hasSkill(skel.name) and player == target and player.phase == Player.Start then
      local cards = table.filter(player:getCardIds("h"), function (id)
        return Fk:getCardById(id).name == "charm" and not player:prohibitDiscard(id)
      end)
      if #cards > 2 then
        event:setCostData(self, {cards = cards})
        return true
      end
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    room:askToDiscard(player, {min_num = 3, max_num = 3, include_equip = false, skill_name = skel.name, cancelable = false, pattern = "charm" })
    if player.dead then return end
    if player:getSwitchSkillState(skel.name, true) == fk.SwitchYang then
      local skills = room:getTag("steam__yongshengzhilu_skills")
      if skills == nil then
        skills = {}
        for _, g in ipairs(Fk:getAllGenerals()) do
          for _, s in ipairs(g:getSkillNameList()) do
            local skill = Fk.skills[s]
            if not skill:hasTag(Skill.AttachedKingdom) then
              local desc = Fk:translate(":"..s, "zh_CN")
              local pat1 = "造成1点%P?%P?%P?%P?%P?%P?伤害"
              local pat2 = "造成一点%P?%P?%P?%P?%P?%P?伤害"
              local match_start, match_end = desc:find(pat1)
              if not match_start then
                match_start, match_end = desc:find(pat2)
              end
              if match_start and match_end then
                local after_match = desc:sub(match_end + 1, match_end + 3)
                if after_match == "后" or after_match == "时" then
                  -- 排除【狂骨】！
                else
                  table.insert(skills, s)
                end
              end
            end
          end
        end
        room:setTag("steam__yongshengzhilu_skills", skills)
      end
      skills = table.filter(skills, function (s) return not player:hasSkill(s, true) end)
      if #skills == 0 then return end
      local choice = table.random(skills)
      room:handleAddLoseSkills(player, choice)
    else
      room:changeMaxHp(player, 1)
      if not player.dead then
        room:recover { num = 1, skillName = skel.name, who = player, recoverBy = player }
      end
    end
  end,
})

return skel
