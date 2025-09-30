local ret = {}

local qinxinAudios = {"圣光，请指引我。", "我可以帮你。", "我为圣光而战。", "我知道自己在干什么。", "圣光的叛徒！", "王子并不好当。", "你已无药可救！", "相信圣光的我真是愚蠢。"} -- 屯田工作室-大剧杯

local skillName = "steam__qinxin"
local skillDesc = "限定技，当一名角色受到伤害后，你可以①令其回复1点体力；②令其摸两张牌；③摸一张牌；④什么也不做；⑤弃置其两张牌；⑥弃置一张牌；⑦对其造成1点伤害。"

Fk:loadTranslationTable{
  [skillName] = "侵心",
  [":".. skillName] = skillDesc,

  [":steam__qinxin_dyn"] = "限定技，当一名角色受到伤害后，你可以{1}。",
  ["steam__qinxin1"] = "令其回复1点体力",
  ["steam__qinxin2"] = "令其摸两张牌",
  ["steam__qinxin3"] = "摸一张牌",
  ["steam__qinxin4"] = "什么也不做",
  ["steam__qinxin5"] = "弃置其两张牌",
  ["steam__qinxin6"] = "弃置一张牌",
  ["steam__qinxin7"] = "对其造成1点伤害",

  ["#steam__qinxin-ask"] = "侵心：%src 受到了伤害，你可以%arg",
}

for loop = 0, 50 do
  local skel_name = loop == 0 and skillName or "steam"..loop.. "__qinxin"
  local skel = fk.CreateSkill {
    name = skel_name,
    tags = {Skill.Limited},
    dynamic_desc = function (self, player, lang)
      local mark = player:getMark(self.name)
      if mark > 0 and mark < 8 then
        return "steam__qinxin_dyn:steam__qinxin"..mark
      end
    end,
  }

  skel:addEffect(fk.Damaged, {
    can_trigger = function(self, event, target, player, data)
      if player:hasSkill(skel_name) and not target.dead and player:usedSkillTimes(skel_name, Player.HistoryGame) == 0 then
        local mark = player:getMark(skel_name)
        if mark > 0 and mark < 8 then
          if mark == 1 and not target:isWounded() then return false end
          if mark == 5 and #target:getCardIds("he") < 2 then return false end
          if mark == 6 and player:isNude() then return false end
          return true
        end
      end
    end,
    on_cost = function (self, event, target, player, data)
      local mark = player:getMark(skel_name)
      if player.room:askToSkillInvoke(player, { skill_name = skel_name,
       prompt = "#steam__qinxin-ask:" .. target.id.."::steam__qinxin"..mark}) then
        return true
      end
    end,
    on_use = function (self, event, target, player, data)
      local room = player.room
      local mark = player:getMark(skel_name)
      room:notifySkillInvoked(player, skel_name, "big")
      player:broadcastSkillInvoke("dajubei__qinxin", mark)
      if mark == 1 then
        room:recover { num = 1, skillName = skel_name, who = target, recoverBy = player }
      elseif mark == 2 then
        target:drawCards(2, skel_name)
      elseif mark == 3 then
        player:drawCards(1, skel_name)
      elseif mark == 5 then
        local ids = room:askToChooseCards(player, { target = target, min = 2, max = 2, flag = "he", skill_name = skel_name})
        room:throwCard(ids, skel_name, target, player)
      elseif mark == 6 then
        room:askToDiscard(player, {min_num = 1, max_num = 1, include_equip = true, skill_name = skel.name, cancelable = false})
      elseif mark == 7 then
        room:damage { from = player, to = target, damage = 1, skillName = skel_name }
      end
    end,
  })

  skel:addAcquireEffect(function (self, player, is_start)
    player.room:setPlayerMark(player, self.name, math.random(7))
  end)

  Fk:loadTranslationTable{
    [skel_name] = "侵心",
    [":"..skel_name] = skillDesc,
    -- for限定技满屏特效
    ["$"..skel_name.."1"] = table.random(qinxinAudios),
    ["$"..skel_name.."2"] = table.random(qinxinAudios),
  }

  table.insert(ret, skel)
end

return ret
