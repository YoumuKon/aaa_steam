local skel = fk.CreateSkill {
  name = "godhanxin__kunpeng",
}

Fk:loadTranslationTable{
  ["godhanxin__kunpeng"] = "鲲鹏",
  [":godhanxin__kunpeng"] = "你使用【杀】时，你可以令攻击范围内的角色选择是否为你助战→弃置目标一张牌。此【杀】结算后，若造成过伤害，你获得一名拒绝助战的角色一张牌。",

  ["#godhanxin__kunpeng-discard"] = "鲲鹏：是否为此【杀】的使用者助战，弃置一张基本牌，令其弃置每个目标各一张牌？<br>（否则此【杀】结算后使用者可能获得你一张牌）",
  ["#steam__kunpeng-prey"] = "鲲鹏: 请选择1名拒绝助战的角色，获得其一张牌！",
  ["#steam__kunpeng-throw"] = "鲲鹏: 选择1个目标，弃置其1张牌",

  ["$godhanxin__kunpeng"] = "翻云起雾藏杀意，横扫千军几万里，第八枪，鲲鹏！",
}

skel:addEffect(fk.CardUsing, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and target == player and data.card and data.card.trueName == "slash" and #data.tos > 0
    and #table.filter(player.room:getOtherPlayers(player), function(p)
      return target:inMyAttackRange(p) end) > 0
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    data.extra_data = data.extra_data or {}
    data.extra_data.godhanxin__kunpeng_user = player.id
    local targets = table.filter(room:getOtherPlayers(player), function(p)
      return target:inMyAttackRange(p)
    end)
    for _, to in ipairs(targets) do
      if player.dead then break end
      if not to.dead then
        local discard = room:askToDiscard(to, {
          min_num = 1, max_num = 2, skill_name = skel.name, pattern = ".|.|.|.|.|basic",
          prompt = "#godhanxin__kunpeng-discard"
        })
        if #discard > 0 then
          local tos = table.filter(data.tos, function(p)
            return not p:isNude()
          end)
          if #tos > 0 then
            local tar = room:askToChoosePlayers(player, {
              targets = tos, max_num = 1, min_num = 1, skill_name = skel.name, cancelable = false,
              prompt = "#steam__kunpeng-throw"
            })[1]
            local cid = room:askToChooseCard(player, { target = tar, flag = "he", skill_name = skel.name})
            room:throwCard(cid, skel.name, to, player)
          end
        else
          data.extra_data.godhanxin__kunpeng = data.extra_data.godhanxin__kunpeng or {}
          table.insertIfNeed(data.extra_data.godhanxin__kunpeng, to.id)
        end
      end
    end
  end,
})

skel:addEffect(fk.CardUseFinished, {
  is_delay_effect = true,
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return not player.dead and data.card and data.card.trueName == "slash" and data.damageDealt
    and data.extra_data and data.extra_data.godhanxin__kunpeng_user == player.id
    and data.extra_data.godhanxin__kunpeng
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local targets = table.filter(table.map(data.extra_data.godhanxin__kunpeng, Util.Id2PlayerMapper), function (p)
      return not p:isNude()
    end)
    if #targets > 0 then
      local tar = room:askToChoosePlayers(player, {
        targets = targets, max_num = 1, min_num = 1, skill_name = skel.name, cancelable = false,
        prompt = "#steam__kunpeng-prey"
      })[1]
      local cid = room:askToChooseCard(player, { target = tar, flag = "he", skill_name = skel.name})
      room:obtainCard(player, cid, false, fk.ReasonPrey, player, skel.name)
    end
  end,
})



return skel
