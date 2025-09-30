local skel = fk.CreateSkill {
  name = "steam__lingce",
  tags = {Skill.Compulsory},
}

Fk:loadTranslationTable{
  ["steam__lingce"] = "灵策",
  [":steam__lingce"] = "锁定技，当<a href='bag_of_tricks'>智囊</a>牌、〖定汉〗已记录的锦囊牌或【奇正相生】使用时，若为虚拟或转化牌，你摸一张牌；若为实体牌，你对一名角色造成1点伤害。",

  ["bag_of_tricks"] = "#\"<b>智囊</b>\" ：即【过河拆桥】【无懈可击】【无中生有】。",
  ["#steam__lingce-damage"] = "灵策：请对1名角色造成1点伤害",

  ["$steam__lingce1"] = "绍士卒虽众，其实难用，必无为也。",
  ["$steam__lingce2"] = "袁军不过一盘砂砾，主公用奇则散。",
}

skel:addEffect(fk.CardUsing, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    local zhinang = { "ex_nihilo", "dismantlement", "nullification" }
    return
      player:hasSkill(skel.name) and
      (
        table.contains(zhinang, data.card.trueName) or
        table.contains(player:getTableMark("@$steam__dinghan"), data.card.trueName) or
        data.card.trueName == "raid_and_frontal_attack"
      )
  end,
  on_cost = function (self, event, target, player, data)
    if data.card:isVirtual() or Fk:getCardById(data.card.id, true).name ~= data.card.name then
      event:setCostData(self, {anim_type = "drawcard"})
    end
    return true
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if data.card:isVirtual() or Fk:getCardById(data.card.id, true).name ~= data.card.name then
      player:drawCards(1, skel.name)
      return
    end
    local targets = room.alive_players
    if #targets == 0 then return false end
    local tos = room:askToChoosePlayers(player, {
      min_num = 1, max_num = 1, prompt = "#steam__lingce-damage", skill_name = skel.name, cancelable = false, targets = targets
    })
    if #tos > 0 then
      local to = tos[1]
      room:doIndicate(player, {to})
      room:damage { from = player, to = to, damage = 1, skillName = skel.name }
    end
  end,
})

return skel
