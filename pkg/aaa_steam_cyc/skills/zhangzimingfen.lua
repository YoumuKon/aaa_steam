local skel = fk.CreateSkill {
  name = "steam__zhangzimingfen",
  tags = {Skill.Limited},
}

local pilename = "steam__zzmf"

Fk:loadTranslationTable{
  ["steam__zhangzimingfen"] = "长子名分",
  [":steam__zhangzimingfen"] = "限定技，结束阶段，你可以回复体力至体力上限，并将牌堆顶的八张牌置于武将牌上，可如手牌般使用或打出，且每回合结束时，你须弃置其中一张。均失去后，将〖日月当空〗中的三张牌依次改为锦囊牌、锦囊牌、锦囊牌。",

  [pilename] = "长子",
  ["#steam__zhangzimingfen-remove"] = "长子名分：请移除一张",

  ["$steam__zhangzimingfen1"] = "",
  ["$steam__zhangzimingfen2"] = "",
}

skel:addEffect(fk.EventPhaseStart, {
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(skel.name) and target == player and player.phase == Player.Finish
    and player:usedSkillTimes(skel.name, Player.HistoryGame) == 0
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    -- 更换皮肤
    local ge1, ge2 = "steam__jacobesau", "steam2__jacobesau"
    if player.general == ge1 then
      room:setPlayerProperty(player, "general", ge2)
    elseif player.deputyGeneral == ge1 then
      room:setPlayerProperty(player, "deputyGeneral", ge2)
    end
    if player:isWounded() then
      room:recover { num = player.maxHp - player.hp, skillName = skel.name, who = player, recoverBy = player }
      if player.dead then return end
    end
    player:addToPile(pilename, room:getNCards(8), true, skel.name)
  end,
})

skel:addEffect(fk.TurnEnd, {
  is_delay_effect = true,
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return #player:getPile(pilename) > 0
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local cards = room:askToCards(player, {
      min_num = 1, max_num = 1, cancelable = false, include_equip = false, skill_name = skel.name,
      expand_pile = pilename, pattern = ".|.|.|"..pilename
    })
    room:throwCard(cards, skel.name, player, player)
  end,
})

skel:addEffect(fk.AfterCardsMove, {
  can_refresh = function (self, event, target, player, data)
    if not player.dead and #player:getPile(pilename) == 0 then
      for _, move in ipairs(data) do
        if move.from == player and table.find(move.moveInfo, function (info)
            return info.fromSpecialName == pilename
          end) then
          return true
        end
      end
    end
  end,
  on_refresh = function (self, event, target, player, data)
    player.room:setPlayerMark(player, "steam__riyuedangkong_levelup", 1)
  end,
})

skel:addEffect("filter", {
  handly_cards = function (self, player)
    if player:hasSkill(skel.name) then
      return player:getPile(pilename)
    end
  end,
})

return skel
