local skel = fk.CreateSkill {
  name = "steam__geding",
}

Fk:loadTranslationTable{
  ["steam__geding"] = "革鼎",
  [":steam__geding"] = "出牌阶段各限一次，你可以①展示一张基本牌或普通锦囊牌，以此牌牌名替换“复古”中的一个牌名；②交给一名其他角色一张牌，令其不能以“复古”使用牌。",

  ["#steam__geding"] = "革鼎：展示一张基本牌或普通锦囊牌，替换“复古”中的一个牌名；交给一名其他角色一张牌，令其不能以“复古”使用牌",
  ["#steam__geding1"] = "革鼎：展示一张基本牌或普通锦囊牌，以此牌牌名替换“复古”中的一个牌名",
  ["#steam__geding2"] = "革鼎：交给一名其他角色一张牌，令其不能以“复古”使用牌",
  ["steam__geding1"] = "替换牌名",
  ["steam__geding2"] = "交出牌",
  ["#steam__geding-change"] = "革鼎：以【%arg】替换“复古”中的一个牌名",
  ["SteamFugu"] = "%arg2张：【%arg】",
  ["@@steam__geding_forbid"] = "已禁用",
}

skel:addEffect("active", {
  anim_type = "control",
  prompt = function (self)
    local choice = self.interaction.data
    if choice then
      return "#"..choice
    end
    return "#steam__geding"
  end,
  interaction = function(self, player)
    local all_choices = {"steam__geding1", "steam__geding2"}
    local choices = table.filter(all_choices, function (ch) return not table.contains(player:getTableMark("steam__geding-phase"), ch) end)
    if #choices > 0 then
      return UI.ComboBox { choices = choices, all_choices = all_choices }
    end
  end,
  card_filter = function(self, player, to_select, selected)
    if #selected ~= 0 then return false end
    if self.interaction.data == "steam__geding1" then
      local card = Fk:getCardById(to_select)
      return card.type == Card.TypeBasic or card:isCommonTrick()
    else
      return true
    end
  end,
  target_tip = function (self, player, to_select, selected, selected_cards)
    if self.interaction.data == "steam__geding2" and to_select:getMark("steam__fugu_forbid") ~= 0 then
      return "@@steam__geding_forbid"
    end
  end,
  target_filter = function (self, player, to_select, selected, selected_cards)
    return self.interaction.data == "steam__geding2" and #selected == 0 and player ~= to_select and #selected_cards == 1
  end,
  can_use = function(self, player)
    return #player:getTableMark("steam__geding-phase") < 2
  end,
  feasible = function (self, player, selected, selected_cards)
    if self.interaction.data == "steam__geding1" then
      return #selected_cards == 1
    else
      return #selected_cards == 1 and #selected == 1
    end
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local choice = self.interaction.data
    if choice == nil then return end
    room:addTableMark(player, "steam__geding-phase", choice)
    if choice == "steam__geding1" then
      local card = Fk:getCardById(effect.cards[1])
      player:showCards(card)
      local names = Fk:currentRoom():getBanner("steam__fugu_names")
      if names == nil then
        names = {"", "nullification", "amazing_grace", "peach"}
      end
      local name = card.name
      local choices = {}
      for i = 4, 2, -1 do
        table.insert(choices, "SteamFugu:::"..names[i]..":"..i)
      end
      choice = room:askToChoice(player, { choices = choices, skill_name = self.name, prompt = "#steam__geding-change:::"..name })
      local index = tonumber(choice:sub(-1, -1))
      if index then
        names[index] = name
        room:setBanner("steam__fugu_names", names)
      end
    else
      local to = effect.tos[1]
      room:setPlayerMark(to, "steam__fugu_forbid", 1)
      room:obtainCard(to, effect.cards, false, fk.ReasonGive, player.id, self.name)
      room:handleAddLoseSkills(to, "-steam__fugu&", nil, false)
    end
  end,
})

return skel
