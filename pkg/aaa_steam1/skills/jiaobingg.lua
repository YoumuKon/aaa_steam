local skel = fk.CreateSkill {
  name = "steam__jiaobingg",
  tags = {Skill.Compulsory}, 
}

Fk:loadTranslationTable{
  ["steam__jiaobingg"] = "矫兵",
  [":steam__jiaobingg"] = "锁定技，若<a href='steam__jiaobingg_desc-href'>如下做</a>后X未增加，你以移出方式使用即时牌并将手牌摸至X张（X为点数大于手牌数的移出牌数）",

  ["steam__jiaobingg_desc-href"] = "实际效果：锁定技，你使用即时牌时，模拟以下操作（无视其他技能）：将此牌置为「矫兵」，摸牌至X张，若X最终未增加，你将此牌置为「矫兵」，将手牌摸至X张。"..
  "（X为「矫兵」中点数大于手牌数的牌数）",

  ["$steam__jiaobingg1"] = "明犯强汉者，虽远必诛！",
  ["$steam__jiaobingg2"] = "夷狄畏服大种，其天性也！",
  ["$steam__jiaobingg3"] = "国家与公卿议，大策非凡所见，事必不从。",
  ["$steam__jiaobingg4"] = "战机不我待，大众已集会，竖子欲沮众也？",
}

skel:addEffect(fk.CardUsing, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(skel.name) then
      --先找一下实体牌（均在处理区才能操作）
      local card_ids = Card:getIdList(data.card)
      if #card_ids == 0 or not table.every(card_ids, function (id) return player.room:getCardArea(id) == Card.Processing end) 
      or data.card.type == Card.TypeEquip or (data.card.sub_type and data.card.sub_type == Card.SubtypeDelayedTrick) then return end
      local x, y = 0, 0 --此时的X，彼时最终的X
      local list = {}
      for _, id in ipairs(player:getPile(skel.name)) do
        table.insertIfNeed(list, id)
        if Fk:getCardById(id).number > player:getHandcardNum() then
          x = x + 1
        end
      end
      for _, id in ipairs(card_ids) do
        table.insertIfNeed(list, id)
      end
      --将实体牌和已经移出游戏的牌作为集合，准备比对结果
      local z = 0 --第三个变量，处理模拟移除到摸牌之间的X
      for _, id in ipairs(list) do
        if Fk:getCardById(id).number > player:getHandcardNum() then
          z = z + 1
        end
      end
      for _, id in ipairs(list) do
        if Fk:getCardById(id).number > math.max(player:getHandcardNum(), z) then
          y = y + 1
        end
      end
      return x >= y
    end
  end,
  on_use = function (self, event, target, player, data)
    player:addToPile(skel.name, data.card, false, self.name, player.id)
    if not player.dead then
      local x = 0
      for _, id in ipairs(player:getPile(skel.name)) do
        if Fk:getCardById(id).number > player:getHandcardNum() then
          x = x + 1
        end
      end
      if x > player:getHandcardNum() then
        player:drawCards(x - player:getHandcardNum(), skel.name)
      end
    end
  end,
})

return skel
