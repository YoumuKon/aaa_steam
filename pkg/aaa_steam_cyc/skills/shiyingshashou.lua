local skel = fk.CreateSkill {
  name = "steam__shiyingshashou",
}

Fk:loadTranslationTable{
  ["steam__shiyingshashou"] = "噬影杀手",
  [":steam__shiyingshashou"] = "每回合限一次，你指定或成为伤害牌的唯一目标后，可以弃置以下两项中的角色各一张牌：使用者、目标、最短路径上的所有角色。若其中至少半数为♠牌，你摸一张牌，且该伤害牌不计入次数。",

  ["#steam__shiyingshashou-choice"] = "噬影杀手：你可以选择两项，弃置这些角色各一张牌。若半数为♠，你摸一张牌，该牌不计入次数",
  ["steam__shiyingshashou_user"] = "使用者(%src)",
  ["steam__shiyingshashou_tar"] = "目标(%src)",
  ["steam__shiyingshashou_step"] = "路径上角色",
  ["steam__shiyingshashou_left"] = "向左(%arg)",
  ["steam__shiyingshashou_right"] = "向右(%arg)",
}

local spec = {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(skel.name) and data.from ~= data.to
    and player:usedSkillTimes(skel.name) == 0
    and data.card.is_damage_card and data:isOnlyTarget(data.to)
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local from, to = data.from, data.to
    local choices = {"steam__shiyingshashou_user:".. from.id,  "steam__shiyingshashou_tar:".. to.id}
    local left, right = {}, {}
    local temp = from.next
    while temp ~= to do
      if temp:isAlive() then
        table.insert(right, temp)
      end
      temp = temp.next
    end
    temp = to.next
    while temp ~= from do
      if temp:isAlive() then
        table.insert(left, temp)
      end
      temp = temp.next
    end
    local min_dist = math.min(#left, #right)
    if min_dist > 0 then
      table.insert(choices, "steam__shiyingshashou_step")
    end
    choices = room:askToChoices(player, {
      choices = choices, min_num = 2, max_num = 2,
      skill_name = skel.name, prompt = "#steam__shiyingshashou-choice"
    })
    if #choices == 2 then
      choices = table.map(choices, function (choice) return string.split(choice, ":")[1] end)
      local tos = {}
      if table.contains(choices, "steam__shiyingshashou_user") then
        table.insert(tos, from)
      end
      if table.contains(choices, "steam__shiyingshashou_tar") then
        table.insert(tos, to)
      end
      if table.contains(choices, "steam__shiyingshashou_step") then
        local step_choices = {}
        if #left == min_dist then
          table.insert(step_choices, "steam__shiyingshashou_left:::"..table.concat(table.map(left, function (p)
            return Fk:translate(p.general)
          end), ","))
        end
        if #right == min_dist then
          table.insert(step_choices, "steam__shiyingshashou_right:::"..table.concat(table.map(right, function (p)
            return Fk:translate(p.general)
          end), ","))
        end
        local step_choice = room:askToChoice(player, { choices = step_choices, skill_name = skel.name})
        if step_choice:startsWith"steam__shiyingshashou_left" then
          table.insertTable(tos, left)
        else
          table.insertTable(tos, right)
        end
      end
      room:sortByAction(tos)
      event:setCostData(self, {tos = tos})
      return true
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local tos = event:getCostData(self).tos ---@type ServerPlayer[]
    local spade, all = 0, 0
    for _, p in ipairs(tos) do
      if not p:isNude() then
        all = all + 1
        local cid = room:askToChooseCard(player, { target = p, flag = "he", skill_name = skel.name})
        if Fk:getCardById(cid).suit == Card.Spade then
          spade = spade + 1
        end
        room:throwCard(cid, skel.name, p, player)
      end
    end
    if spade > 0 and spade >= all / 2 then
      if not player.dead then
        player:drawCards(1, skel.name)
      end
      local useEvent = room.logic:getCurrentEvent():findParent(GameEvent.UseCard, true)
      if useEvent then
        local use = useEvent.data
        if not use.extraUse then
          use.from:addCardUseHistory(use.card.trueName, -1)
          use.extraUse = true
        end
      end
    end
  end,
}

skel:addEffect(fk.TargetSpecified, {
  anim_type = "offensive",
  times = function (_, player)
    return 1 - player:usedSkillTimes(skel.name)
  end,
  can_trigger = spec.can_trigger,
  on_cost = spec.on_cost,
  on_use = spec.on_use,
})

skel:addEffect(fk.TargetConfirmed, {
  anim_type = "defensive",
  can_trigger = spec.can_trigger,
  on_cost = spec.on_cost,
  on_use = spec.on_use,
})

return skel
