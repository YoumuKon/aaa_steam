local DIY = require "packages/diy_utility/diy_utility"

local skel = fk.CreateSkill {
  name = "steam__shengsinizhuan",
  tags = {DIY.ReadySkill},
}

Fk:loadTranslationTable{
  ["steam__shengsinizhuan"] = "生死逆转",
  [":steam__shengsinizhuan"] = "<a href='diy_ready_skill'>蓄势技</a>，准备阶段，你可以摸三张牌或回复1点体力，再将任意张牌扣置于武将牌旁。",

  ["#steam__shengsinizhuan-put"] = "生死逆转：可以将任意张牌扣置于武将牌旁",
  ["#steam__shengsinizhuan-pile"] = "生死逆转：选择你要添加的牌堆！",
}

skel:addEffect(fk.EventPhaseStart, {
  anim_type = "big",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(skel.name) and target == player and player.phase == Player.Start
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if not player:isWounded() or room:askToChoice(player, { choices = {"draw3", "recover"}, skill_name = skel.name}) == "draw3" then
      player:drawCards(3, skel.name)
    else
      room:recover { num = 1, skillName = skel.name, who = player, recoverBy = player }
    end
    if player.dead or player:isNude() then return end
    local piles = {}
    if player:hasSkill("steam__shengsipaihuai", true) then
      table.insert(piles, "$steam__shengsipaihuai_pile")
    end
    for name, ids in pairs(player.special_cards) do
      if #ids > 0 then
        table.insertIfNeed(piles, name)
      end
    end
    if #piles == 0 then return end
    local cards = room:askToCards(player, { min_num = 1, max_num = 999, cancelable = true,
    skill_name = skel.name, include_equip = true, prompt = "#steam__shengsinizhuan-put"})
    if #cards > 0 then
      local pilename = room:askToChoice(player, {choices = piles, skill_name = skel.name, prompt = "#steam__shengsinizhuan-pile"})
      player:addToPile(pilename, cards, false, skel.name)
    end
  end,
})

return skel
