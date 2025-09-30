local skel = fk.CreateSkill {
  name = "godhanxin__womingyouwo",
}

Fk:loadTranslationTable{
  ["godhanxin__womingyouwo"] = "我命由我不由天",
  [":godhanxin__womingyouwo"] = "你获得本式后，重铸任意张牌，然后再随机获得其他两式。",

  ["#godhanxin__womingyouwo-ask"] = "我命由我不由天：请选择任意张牌重铸！",

  ["$godhanxin__womingyouwo"] = "百万将士再摇旗，将军韩信战无敌，第十三枪，我命由我不由天！",
}

skel:addEffect(fk.EventAcquireSkill, {
  anim_type = "switch",
  can_trigger = function (self, event, target, player, data)
    return target == player and data.skill.name == skel.name
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cards = room:askToCards(player, { min_num = 1, max_num = 999, include_equip = true, skill_name =  skel.name,
    prompt = "#godhanxin__womingyouwo-ask"})
    if #cards > 0 then
      room:recastCard(cards, player, skel.name)
    end
    local skillslist = {
      "godhanxin__xiangsi","godhanxin__duanchang","godhanxin__manglong", "godhanxin__fengliu",
      "godhanxin__wushuang", "godhanxin__bailong", "godhanxin__wangchuan", "godhanxin__kunpeng",
      "godhanxin__baiguiyexing", "godhanxin__xunchou", "godhanxin__baijiangfenghou", "godhanxin__taitou"
    }
    for _, s in ipairs(skillslist) do
      if player:hasSkill(s, true) then
        table.removeOne(skillslist, s)
      end
    end
    if #skillslist == 0 then return end
    local skills = table.random(skillslist, 2)
    room:handleAddLoseSkills(player, table.concat(skills, "|"))
  end,
})



return skel
