local skel = fk.CreateSkill {
  name = "steam__xinsheng",
}

Fk:loadTranslationTable{
  ["steam__xinsheng"] = "心声",
  [":steam__xinsheng"] = "一名角色的结束阶段，你可以摸一张牌，并将一张手牌为其蓄谋；当蓄谋牌不因使用而进入弃牌堆时，结束当前回合。",

  ["#steam__xinsheng-invoke"] = "心声：你可以摸一张牌，并为 %src 蓄谋",
  ["#steam__xinsheng-card"] = "心声：选择一张手牌为 %src 蓄谋",

  ["$steam__xinsheng1"] = "",
  ["$steam__xinsheng2"] = "",
}

local U = require "packages/utility/utility"

skel:addEffect(fk.EventPhaseStart, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(skel.name) then
      return target.phase == Player.Finish and not target.dead
    end
  end,
  on_cost = function (self, event, target, player, data)
    if player.room:askToSkillInvoke(player, { skill_name = skel.name, prompt = "#steam__xinsheng-invoke:"..target.id}) then
      event:setCostData(self, {tos = {target} })
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:drawCards(1, self.name)
    if player.dead or target.dead or player:isKongcheng() then return end
    local cards = room:askToCards(player, {
      min_num = 1, max_num = 1, include_equip = false, cancelable = false, skill_name = skel.name,
      prompt = "#steam__xinsheng-card:"..target.id
    })
    U.premeditate(target, cards, skel.name, player)
  end,
})

skel:addEffect(fk.AfterCardsMove, {
  anim_type = "control",
  priority = 0.99,
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(skel.name) then return end
    for _, move in ipairs(data) do
      -- 再次检测目标区域，防止修改。可能会波及废除牌
      if move.toArea == Card.DiscardPile then
        for _, info in ipairs(move.moveInfo) do
          if info.premeditateCheck then return true end
        end
      end
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:endTurn()
  end,
})

skel:addEffect(fk.BeforeCardsMove, {
  can_refresh = function (self, event, target, player, data)
    return player.seat == 1
  end,
  on_refresh = function (self, event, target, player, data)
    for _, move in ipairs(data) do
      if move.from and move.moveReason ~= fk.ReasonUse and move.toArea == Card.DiscardPile then
        for _, info in ipairs(move.moveInfo) do
          if info.fromArea == Card.PlayerJudge then
            local vcard = move.from:getVirtualEquip(info.cardId)
            if vcard and vcard.trueName == "premeditate" then
              -- 非常危险的数据传输
              info.premeditateCheck = true
            end
          end
        end
      end
    end
  end,
})

return skel
