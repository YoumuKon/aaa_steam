local skel = fk.CreateSkill {
  name = "steam__zhuren",
}

Fk:loadTranslationTable{
  ["steam__zhuren"] = "铸人",
  [":steam__zhuren"] = "出牌阶段，你可以弃置与你手牌数之差为1的一名角色的一张手牌；然后你不能对其发动此技能，直到其失去牌。",

  ["#steam__zhuren"] = "铸人：选择与你手牌数之差为1的一名角色，弃置其一张手牌",
  ["@@steam__zhuren_forbid"] = "禁止选",
}

skel:addEffect("active", {
  anim_type = "control",
  card_num = 0,
  target_num = 1,
  prompt = "#steam__zhuren",
  card_filter = Util.FalseFunc,
  target_tip = function (self, player, to, selected, selected_cards)
    if #selected == 0 then
      if table.contains(player:getTableMark("steam__zhuren_forbid"), to.id) then
        return "@@steam__zhuren_forbid"
      end
    end
  end,
  target_filter = function (self, player, to, selected)
    return #selected == 0 and not to:isKongcheng() and math.abs(player:getHandcardNum() - to:getHandcardNum()) == 1
    and not table.contains(player:getTableMark("steam__zhuren_forbid"), to.id)
  end,
  can_use = function(self, player)
    return true
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local to = effect.tos[1]
    if to:isKongcheng() then return end
    local cid = room:askToChooseCard(player, { target = to, flag = "h", skill_name = self.name})
    room:throwCard(cid, self.name, to, player)
    if player.dead or to.dead then return end
    room:addTableMark(player, "steam__zhuren_forbid", to.id)
  end,
})

skel:addEffect(fk.AfterCardsMove, {
  can_refresh = function(self, event, target, player, data)
    return #player:getTableMark("steam__zhuren_forbid") ~= 0
  end,
  on_refresh = function (self, event, target, player, data)
    local mark = player:getTableMark("steam__zhuren_forbid")
    for _, move in ipairs(data) do
      if move.from and move.from ~= player and
      table.find(move.moveInfo, function (info) return info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip end) then
        table.removeOne(mark, move.from.id)
      end
    end
    player.room:setPlayerMark(player, "steam__zhuren_forbid", #mark > 0 and mark or 0)
  end,
})

skel:addLoseEffect(function (self, player, is_death)
  player.room:setPlayerMark(player, "steam__zhuren_forbid", 0)
end)

return skel
