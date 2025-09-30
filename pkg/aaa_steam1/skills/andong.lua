local skel = fk.CreateSkill {
  name = "steam__andong",
}

Fk:loadTranslationTable{
  ["steam__andong"] = "安东",
  [":steam__andong"] = "出牌阶段每项限一次，你可以弃置一名角色一张牌并令其选择另一名角色，然后你选一项令其选择的角色：获得此牌；使用此牌并摸一张牌；摸一张牌并交给前者一张牌。",

  ["#steam__andong"] = "安东：你可以弃置一名角色一张牌并令其选择另一名角色，然后你选一项令其选择的角色执行",
  ["#steam__andong-choice"] = "安东：你须选一项（每阶段每项限一次）",
  ["steam__andong_prey"] = "令 %src 获得%arg",
  ["steam__andong_use"] = "令 %src 使用%arg并摸1牌",
  ["steam__andong_draw"] = "令 %src 摸1并交给 %dest 1牌",
  ["#steam__andong-give"] = "安东：交给 %src 一张牌",
  ["#steam__andong-use"] = "安东：请您使用 %arg",
  ["#steam__andong-other"] = "安东：请选择一名其他角色，令 %src 对其执行一项",

  ["$steam__andong1"] = "勇足以当大难，智涌以安万变。",
  ["$steam__andong2"] = "宽猛克济，方安河东之民。",
}

skel:addEffect("active", {
  anim_type = "control",
  card_num = 0,
  target_num = 1,
  prompt = "#steam__andong",
  card_filter = Util.FalseFunc,
  target_filter = function (self, player, to_select, selected)
    return #selected == 0 and not to_select:isNude()
  end,
  times = function (self, player)
    return 3 - #player:getTableMark("steam__andong-phase")
  end,
  can_use = function(self, player)
    return #player:getTableMark("steam__andong-phase") < 3
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local to = effect.tos[1]
    if player.dead or to:isNude() then return end
    local cid = room:askToChooseCard(player, { target = to, flag = "he", skill_name = skel.name})
    room:throwCard(cid, skel.name, to, player)
    if to.dead or player.dead then return end
    local others = room:getOtherPlayers(to, false)
    if #others == 0 then return end
    local other = room:askToChoosePlayers(to, {
      min_num = 1, max_num = 1, targets = others, skill_name = skel.name, cancelable = false,
      prompt = "#steam__andong-other:"..player.id,
    })[1]
    local card = Fk:getCardById(cid)
    local cardStr = card:toLogString()
    local used = player:getTableMark("steam__andong-phase")
    local all_choices = {"steam__andong_prey:"..other.id.."::"..cardStr,
    "steam__andong_use:"..other.id.."::"..cardStr, "steam__andong_draw:"..other.id..":"..to.id}
    local choices = table.filter(all_choices, function(c) return not table.contains(used, c:split(":")[1]) end)
    if #choices == 0 then return end
    local avilChoices = table.simpleClone(choices)
    for i = #choices, 1, -1 do
      local ch = choices[i]
      if ch:startsWith("steam__andong_prey") then
        if room:getCardArea(cid) ~= Card.DiscardPile then
          table.remove(avilChoices, i)
        end
      elseif ch:startsWith("steam__andong_use") then
        -- 只判被动牌就行了，懒
        if room:getCardArea(cid) ~= Card.DiscardPile or (#card:getAvailableTargets(other) == 0) then
          table.remove(avilChoices, i)
        end
      end
    end
    -- 优先选择可以选择的选项，若均不能选择，那随便选
    local choice = room:askToChoice(player, {
      choices = (#avilChoices > 0 and avilChoices or choices), skill_name = skel.name, all_choices = all_choices,
      prompt = "#steam__andong-choice",
    })
    choice = choice:split(":")[1]
    room:addTableMark(player, "steam__andong-phase", choice)
    if choice == "steam__andong_prey" then
      if room:getCardArea(cid) == Card.DiscardPile then
        room:obtainCard(other, cid, true, fk.ReasonJustMove, other, skel.name)
      end
    elseif choice == "steam__andong_draw" then
      other:drawCards(1, skel.name)
      if not other.dead and not other:isNude() and not to.dead then
        local give = room:askToCards(other, {
          min_num = 1, max_num = 1, include_equip = true, cancelable = false, skill_name = skel.name,
          prompt = "#steam__andong-give:"..to.id
        })
        room:obtainCard(to, give, true, fk.ReasonGive, other, skel.name)
      end
    elseif choice == "steam__andong_use" then
      if room:getCardArea(cid) == Card.DiscardPile then
        local use = room:askToUseRealCard(other, {
          skill_name = skel.name, pattern = {cid}, expand_pile = {cid}, cancelable = false, skip = false,
          extra_data = {expand_pile = {cid}, bypass_times = true},
          prompt = "#steam__andong-use:::" .. cardStr,
        })
        if use and not other.dead then
          other:drawCards(1, skel.name)
        end
      end
    end
  end,
})



return skel
