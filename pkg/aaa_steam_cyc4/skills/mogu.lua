local mogu = fk.CreateSkill {
  name = "steam__mogu",
}

Fk:loadTranslationTable{
  ["steam__mogu"] = "摹骨",
  [":steam__mogu"] = "出牌阶段限一次，你可以亮出牌堆顶的一张牌，然后你可以将一张牌当其中一张同花色即时牌使用并可重复此流程。若本次转化牌数不超过一张，亮出牌数永久+1；"..
  "你以此法使用重复牌名的牌后，终止本流程并结束本阶段。",

  ["@steam__mogu"] = "摹骨 +",
  ["#steam__mogu"] = "摹骨：你可以重复→亮出牌堆顶牌，有机会将一张牌当亮出牌中一张同花色即时牌使用！",
  ["#steam__mogu_active"] = "摹骨：请将一张牌当牌表中的一张即时牌使用，每种花色能转化的范围详见选项提示！",
  ["#steam__mogu_continute"] = "摹骨：是否继续重复亮出牌和转化牌的流程？",

  ["$steam__mogu1"] = "这片战场，适合泼墨法。",
  ["$steam__mogu2"] = "落锋长日坠，起笔叠嶂起！",
  ["$steam__mogu3"] = "今天我心情不错，送你们一幅《沙场白骨图》吧。",
  ["$steam__mogu4"] = "以有形摹无垠，以无形应天下！",
}

mogu:addEffect("active", {
  anim_type = "control",
  prompt = "#steam__mogu",
  card_num = 0,
  target_num = 0,
  can_use = function(self, player)
    return player:usedSkillTimes(mogu.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  on_use = function(self, room, effect)
    local player = effect.from
    local num = 0
    local namelist = {}
    local cleanlist = {}
    repeat
      local list = {}
      local cards = room:getNCards(1 + player:getMark("@steam__mogu"))
      room:turnOverCardsFromDrawPile(player, cards, mogu.name)
      for _, id in ipairs (cards) do
        table.insertIfNeed(list, id)
        table.insertIfNeed(cleanlist, id)
      end
      if not player.dead then
        local _, dat = room:askToUseActiveSkill(player, {
          skill_name = "steam__mogu_active",
          prompt = "#steam__mogu_active",
          no_indicate = true,
          extra_data = {mogu_list = list},
        })
        if dat then
          num = num + 1
          local card = Fk:cloneCard(string.split(dat.interaction, ":")[4])
          card.skillName = mogu.name
          card:addSubcards(dat.cards)
          room:useCard{
            from = player,
            tos = dat.targets,
            card = card,
            extraUse = true,
          }
          if table.contains(namelist, card.trueName) then
            player:endPlayPhase()
            break
          else
            table.insertIfNeed(namelist, card.trueName)
          end
          if not player.dead then
            if not room:askToSkillInvoke(player, {skill_name = mogu.name, prompt = "#steam__mogu_continute"}) then
              break
            end
          end
        else
          break
        end
      end
    until player.dead
    if not player.dead and num <= 1 then
      room:addPlayerMark(player, "@steam__mogu", 1)
    end
    room:cleanProcessingArea(cleanlist, mogu.name)
  end,
})

return mogu
