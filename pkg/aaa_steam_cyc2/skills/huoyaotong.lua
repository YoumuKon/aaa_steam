local skel = fk.CreateSkill {
  name = "steam__huoyaotong",
}

Fk:loadTranslationTable{
  ["steam__huoyaotong"] = "火药桶",
  [":steam__huoyaotong"] = "游戏开始时，或有角色死亡后，将你武将牌上的<a href=':timebomb'>【定时炸弹】</a>补至三张。你可以如手牌般使用这些牌。",

  ["powderkeg"] = "火药桶", -- 不要使用&牌堆
  ["#steam__huoyaotong"] = "火药桶：使用一个炸弹！",

  ["$steam__huoyaotong1"] = "更多火药！",
  ["$steam__huoyaotong2"] = "当心炸药桶！",
  ["$steam__huoyaotong3"] = "烧吧！",
  ["$steam__huoyaotong4"] = "死人们，讲述着我的故事！", -- 补炸弹
}

skel:addEffect("viewas", {
  anim_type = "offensive",
  expand_pile = "powderkeg",
  prompt = "#steam__huoyaotong",
  mute = true,
  pattern = "timebomb",
  audio_index = {1,2,3},
  card_filter = function (self, player, to_select, selected, selected_targets)
    return #selected == 0 and player:getPileNameOfId(to_select) == "powderkeg"
  end,
  view_as = function (self, player, cards)
    if #cards ~= 1 then return nil end
    return Fk:getCardById(cards[1])
  end,
  enabled_at_play = function(self, player)
    return #player:getPile("powderkeg") > 0
  end,
  enabled_at_response = function (self, player, response)
    return #player:getPile("powderkeg") > 0 and not response
  end,
})

local can_trigger = function (self, event, target, player, data)
  if not player:hasSkill(skel.name) then return false end
  if Fk.all_card_types["timebomb"] == nil then return false end
  return #player:getPile("powderkeg") < 3
end

local on_use = function(self, event, target, player, data)
  local room = player.room
  local ids = {}
  for i = #player:getPile("powderkeg") + 1, 3 do
    local c = room:printCard("timebomb", Card.Spade, table.random({6, 9}))
    room:setCardMark(c, MarkEnum.DestructIntoDiscard, 1)
    table.insert(ids, c.id)
  end
  player:addToPile("powderkeg", ids, true, skel.name)
end

skel:addEffect(fk.GameStart, {
  anim_type = "drawcard",
  audio_index = 4,
  can_trigger = can_trigger,
  on_cost = Util.TrueFunc,
  on_use = on_use,
})

skel:addEffect(fk.Deathed, {
  anim_type = "drawcard",
  audio_index = 4,
  can_trigger = can_trigger,
  on_cost = Util.TrueFunc,
  on_use = on_use,
})


return skel
