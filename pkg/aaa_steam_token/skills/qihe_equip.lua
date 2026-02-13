local skill = fk.CreateSkill {
  name = "steam_qihe_equip_skill&",
  attached_equip = "steam_qihe_equip",
  tags = { Skill.Switch },
}

Fk:loadTranslationTable{
  ["steam_qihe_equip_skill&"] = "云与漆",
  [":steam_qihe_equip_skill&"] = "转换技，每回合限一次，阳：你可以将最靠近牌堆顶的非装备牌置入一个空置装备栏；阴：望可以移动你场上的一张牌；以视为使用一张【杀/闪】。"..
  "此牌离开你的装备区后销毁。",

  ["#steam_qihe_equip0"] = "云与漆（阳）：请选择一个空装备栏，向其中置入牌以视为使用【杀】/【闪】。",
  ["#steam_qihe_equip1"] = "云与漆（阴）：请参看另一个技能按钮。",
  ["#steam_qihe_equip-choose"] = "云与漆：请选择一个空置装备栏以置入牌。",
}

local mapper = {
  [Player.WeaponSlot] = "weapon",
  [Player.ArmorSlot] = "armor",
  [Player.OffensiveRideSlot] = "offensive_horse",
  [Player.DefensiveRideSlot] = "defensive_horse",
  [Player.TreasureSlot] = "treasure",
}

--阴部分做独立按钮，因未必是同一角色
skill:addEffect("viewas", {
  pattern = "slash,jink",
  prompt = function (self, player, selected_cards, selected_targets)
    return "#steam_qihe_equip"..player:getSwitchSkillState(skill.name, false)
  end,
  interaction = function(self, player)
    local names = player:getViewAsCardNames(skill.name, {"slash", "jink"})
    return UI.CardNameBox {choices = names, all_choices = {"slash", "jink"}}
  end,
  card_filter = Util.FalseFunc,
  view_as = function(self)
    if not self.interaction.data then return end
    local card = Fk:cloneCard(self.interaction.data)
    card.skillName = skill.name
    return card
  end,
  before_use = function (self, player, use)
    if #table.filter(player.room.draw_pile, function (id) return Fk:getCardById(id).type ~= Card.TypeEquip end) == 0 then return "" end
    local choices = {}
    for _, sub_type in ipairs(player.equipSlots) do
      if player:hasEmptyEquipSlot(Util.convertSubtypeAndEquipSlot(sub_type)) then
        table.insertIfNeed(choices, sub_type)
      end
    end
    if #choices > 0 then
      local choice = player.room:askToChoice(player, {
        choices = choices,
        skill_name = skill.name,
        prompt = "#steam_qihe_equip-choose",
        cancelable = false,
      })
      for _, id in ipairs(player.room.draw_pile) do
        if Fk:getCardById(id).type ~= Card.TypeEquip then
          local card = Fk:cloneCard(mapper[choice].."__steam__qihe")
          card:addSubcard(id)
          player.room:moveCardIntoEquip(player, card, skill.name, true, player)
          break
        end
      end
    end
  end,
  enabled_at_play = function(self, player)
    return player:hasEmptyEquipSlot() and #player:getViewAsCardNames(skill.name, {"slash"}) > 0 and
      player:getSwitchSkillState(skill.name, false) == fk.SwitchYang and
      #table.filter(Fk:currentRoom().draw_pile, function (id) return Fk:getCardById(id).type ~= Card.TypeEquip end) > 0
  end,
  enabled_at_response = function(self, player, response)
    return not response and player:hasEmptyEquipSlot() and
      #player:getViewAsCardNames(skill.name, {"slash", "jink"}) > 0 and
      player:getSwitchSkillState(skill.name, false) == fk.SwitchYang and
      #table.filter(Fk:currentRoom().draw_pile, function (id) return Fk:getCardById(id).type ~= Card.TypeEquip end) > 0
  end,
})

skill:addAcquireEffect(function (self, player, is_start, src)
  for _, p in ipairs(player.room.alive_players) do
    if not p.dead and p:hasSkill("steam__qihe", true) then
      p:addFakeSkill("steam_qihe_equip_yin&")
    end
  end
end)

skill:addLoseEffect(function (self, player, is_death)
  if table.every(player.room.alive_players, function (p) return not p.dead and not p:hasSkill(skill.name, true) end) then
    for _, p in ipairs(player.room.alive_players) do
      p:loseFakeSkill("steam_qihe_equip_yin&")
    end
  end  
end)

return skill
