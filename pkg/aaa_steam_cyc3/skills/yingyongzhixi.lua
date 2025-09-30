local skel = fk.CreateSkill {
  name = "steam__yingyongzhixi",
}

Fk:loadTranslationTable{
  ["steam__yingyongzhixi"] = "英勇之息",
  [":steam__yingyongzhixi"] = "你造成或受到伤害后，可以重铸距离1以内的角色各一张牌；然后你可以获得其中的黑色牌，令本技能本回合失效。",

  ["#steam__yingyongzhixi-recast"] = "英勇之息：重铸 %src 的一张牌",
  ["#steam__yingyongzhixi-get"] = "英勇之息：你可获得其中黑色牌",

  ["$steam__yingyongzhixi1"] = "咩啦咩啦！阿果！哈哈哈…若玛斯！",
  ["$steam__yingyongzhixi2"] = "唔！阿果！咩啦！哈——",
  ["$steam__yingyongzhixi3"] = "伊果！伊果！娜拉！哈哈哈",
  ["$steam__yingyongzhixi4"] = "伊多！兰！哈哈哈",
}

local spec = {
  anim_type = "control",
  can_trigger = function (self, event, target, player, data)
    if player:hasSkill(skel.name) and target == player then
      return table.find(player.room.alive_players, function(p)
        return not p:isNude() and (player == p or player:distanceTo(p) == 1)
      end) ~= nil
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local targets = table.filter(room:getAlivePlayers(), function(p)
      return (player == p or player:distanceTo(p) == 1)
    end)
    local cards = {}
    for _, to in ipairs(targets) do
      if not player.dead and not to:isNude() then
        local cid = room:askToChooseCard(player, {
          target = to, flag = "he", skill_name = skel.name, prompt = "#steam__yingyongzhixi-recast:"..to.id
        })
        room:recastCard({cid}, to, skel.name)
        table.insertIfNeed(cards, cid)
      end
    end
    cards = table.filter(cards, function(id) return room:getCardArea(id) == Card.DiscardPile and Fk:getCardById(id).color == Card.Black end)
    if #cards > 0 and not player.dead then
      local _, ch = room:askToChooseCardsAndChoice(player, {
        choices = {"prey"}, cancel_choices = {"Cancel"}, cards = cards, skill_name = skel.name,
        min_num = 1, max_num = #cards, prompt = "#steam__yingyongzhixi-get",
      })
      if ch ~= "Cancel" then
        room:invalidateSkill(player, skel.name, "-turn")
        room:obtainCard(player, cards, true, fk.ReasonJustMove, player, skel.name)
      end
    end
  end,
}

skel:addEffect(fk.Damage, spec)
skel:addEffect(fk.Damaged, spec)

return skel
