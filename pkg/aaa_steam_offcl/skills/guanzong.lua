local skel = fk.CreateSkill {
  name = "steam__guanzong",
}

Fk:loadTranslationTable{
  ["steam__guanzong"] = "惯纵",
  [":steam__guanzong"] = "出牌阶段限一次，你可以移动场上的一张牌，然后因此失去牌的角色可以对因此获得牌的角色造成1点伤害。",

  ["#steam__guanzong"] = "惯纵：移动场上的一张牌，失去牌的角色可对获得牌的角色造成伤害",
  ["#steam__guanzong-ask"] = "惯纵：你可以对 %src 造成1点伤害！",

  ["$steam__guanzong1"] = "汝为叔父，怎可与小辈计较！",
  ["$steam__guanzong2"] = "阿瞒生龙活虎，汝切勿胡言！",
}

skel:addEffect("active", {
  anim_type = "control",
  prompt = "#steam__guanzong",
  card_num = 0,
  target_num = 2,
  card_filter = Util.FalseFunc,
  target_filter = function (self, player, to, selected)
    if #selected == 0 then
      return #to:getCardIds("ej") > 0
    elseif #selected == 1 then
      local from = selected[1]
      return from:canMoveCardsInBoardTo(to) or to:canMoveCardsInBoardTo(from)
    end
  end,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  times = function (self, player)
    return 1 - player:usedSkillTimes(self.name, Player.HistoryPhase)
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local tar1, tar2 = effect.tos[1], effect.tos[2]
    local reslut = room:askToMoveCardInBoard(player, { target_one = tar1, target_two = tar2, skill_name = self.name})
    if not reslut then return end
    local from, to = reslut.from, reslut.to
    if not from.dead and not to.dead then
      if room:askToSkillInvoke(from, { skill_name = self.name, prompt = "#steam__guanzong-ask:"..to.id}) then
        room:doIndicate(from, {to})
        room:damage { from = from, to = to, damage = 1, skillName = self.name }
      end
    end
  end,
})

return skel
