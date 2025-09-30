local skel = fk.CreateSkill {
  name = "godhanxin__wushuang",
}

Fk:loadTranslationTable{
  ["godhanxin__wushuang"] = "无双",
  [":godhanxin__wushuang"] = "你使用【杀】的目标上限为3，每少指定一名目标，此【杀】的响应量+1。",

  ["#godhanxin__wushuang-extra"] = "无双:请选择 %arg 名【杀】额外目标，每少指定一名，此【杀】响应量+1",

  ["$godhanxin__wushuang"] = "书香百味有多少，天下何人配白衣，第五枪，无双！",
}

skel:addEffect(fk.AfterCardTargetDeclared, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(skel.name) and target == player and data.tos and #data.tos < 3 and data.card.trueName == "slash"
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local targets = data:getExtraTargets()
    local tos = room:askToChoosePlayers(player, {
      min_num = 1, max_num = 3 - #data.tos, skill_name = skel.name, targets = targets,
      prompt = "#godhanxin__wushuang-extra:::" .. 3 - #data.tos
    })
    for _, to in ipairs(tos) do
      data:addTarget(to)
    end
    local num = 3 - #data.tos
    if num > 0 then
      data.extra_data = data.extra_data or {}
      data.extra_data.godhanxin__wushuang = num
    end
  end,
})

skel:addEffect(fk.TargetSpecified, {
  can_refresh = function(self, event, target, player, data)
    return data.extra_data and data.extra_data.godhanxin__wushuang
  end,
  on_refresh = function(self, event, target, player, data)
    data:setResponseTimes(data:getResponseTimes() + data.extra_data.godhanxin__wushuang)
  end,
})

return skel
