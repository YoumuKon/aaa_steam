local skel = fk.CreateSkill {
  name = "steam__exi",
}

Fk:loadTranslationTable{
  ["steam__exi"] = "恶戏",
  [":steam__exi"] = "每回合限一次，你需使用手牌中的基本牌或锦囊牌时，若你的手牌数不多于体力上限，你可以声明此牌，且令当前回合角色展示你一张手牌。若不为声明牌，你使用声明牌，再将手牌数补至体力上限。若为声明牌，你令你与一名其他角色依次重铸各自的所有牌。",

  ["#steam__exi-choose"] = "恶戏：选择一名其他角色，你与其各重铸所有牌",
  ["#steam__exi"] = "恶戏：你可以选择并声明一张即将使用的牌，你有可能使用之",
  ["#steam__exiLog"] = "%from 声明了牌 %arg",
}

skel:addEffect("viewas", {
  anim_type = "drawcard",
  pattern = ".",
  prompt = "#steam__exi",
  card_filter = function (self, player, to_select, selected)
    if #selected > 0 or not table.contains(player.player_cards[Player.Hand], to_select) then return false end
    local card = Fk:getCardById(to_select)
    if card.type == Card.TypeEquip then return end
    if Fk.currentResponsePattern == nil then
      return player:canUse(card) and not player:prohibitUse(card)
    else
      return Exppattern:Parse(Fk.currentResponsePattern):match(card)
    end
  end,
  view_as = function (self, player, cards)
    if #cards ~= 1 then return nil end
    return Fk:getCardById(cards[1])
  end,
  before_use = function(self, player, use)
    local room = player.room
    local current = room.current
    if player:isKongcheng() then return skel.name end
    room:sendLog{ type = "#steam__exiLog", from = player.id, arg = use.card:toLogString(), toast = true }
    local cid = room:askToChooseCard(current, { target = player, flag = "h", skill_name = skel.name})
    player:showCards({cid})
    local right = (cid == use.card.id)
    room:setCardEmotion(cid, right and "judgegood" or "judgebad")
    room:delay(600)
    if right then
      local players = {player}
      local tos = table.filter(room:getOtherPlayers(player, false), function (p) return not p:isNude() end)
      if #tos > 0 then
        tos = room:askToChoosePlayers(player, {
          min_num = 1, max_num = 1, targets = tos, skill_name = skel.name, cancelable = false,
          prompt = "#steam__exi-choose",
        })
        if #tos > 0 then
          table.insert(players, tos[1])
        end
      end
      for _, p in ipairs(players) do
        local cards = p:getCardIds("he")
        if #cards > 0 then
          room:recastCard(cards, p, skel.name)
        end
      end
      return ""
    else
      use.extra_data = use.extra_data or {}
      use.extra_data.steam__exiDraw = true
    end
  end,
  after_use = function(self, player, use)
    if not player.dead and use.extra_data and use.extra_data.steam__exiDraw then
      local num = player.maxHp - player:getHandcardNum()
      if num > 0 then
        player:drawCards(num, skel.name)
      end
    end
  end,
  times = function (self, player)
    return 1 - player:usedSkillTimes(skel.name)
  end,
  enabled_at_play = function(self, player)
    return player:getHandcardNum() <= player.maxHp and not player:isKongcheng() and player:usedSkillTimes(skel.name) == 0
  end,
  enabled_at_response = function (self, player, response)
    return player:getHandcardNum() <= player.maxHp and not player:isKongcheng() and player:usedSkillTimes(skel.name) == 0
    and not response and Fk.currentResponsePattern
    and table.find(player:getCardIds("h"), function (id)
      return Fk:getCardById(id).type ~= Card.TypeEquip and Exppattern:Parse(Fk.currentResponsePattern):match(Fk:getCardById(id))
    end)
  end,
})



return skel
