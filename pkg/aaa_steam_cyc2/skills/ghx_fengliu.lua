local skel = fk.CreateSkill {
  name = "godhanxin__fengliu",
}

Fk:loadTranslationTable{
  ["godhanxin__fengliu"] = "风流",
  [":godhanxin__fengliu"] = "你获得本式后，将随机一张性别为女的武将作为本回合的副将。",

  ["$godhanxin__fengliu"] = "乾坤一簌天下游，月如钩难别求，第四枪，风流！",
}

local DIY = require "packages.diy_utility.diy_utility"

skel:addEffect(fk.EventAcquireSkill, {
  anim_type = "switch",
  can_trigger = function (self, event, target, player, data)
    return target == player and data.skill.name == skel.name
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local generals = {}
    -- 获得额外技能的武将不能要
    local exist = {"rmt__suqingyue", "rmt__weizifu"}
    for _, p in ipairs(room.players) do
      table.insertIfNeed(exist, p.general)
      if p.deputyGeneral ~= "" then
        table.insertIfNeed(exist, p.deputyGeneral)
      end
    end
    for _, g in ipairs(room.general_pile) do
      local general = Fk.generals[g]
      if general.gender == General.Female then
        if table.find(general:getSkillNameList(player.role == "lord"), function (s)
          local skill = Fk.skills[s]
          return not (skill:hasTag(Skill.Limited) or skill:hasTag(Skill.Quest) or skill:hasTag(Skill.Wake)
          or skill:hasTag(DIY.ReadySkill))
        end) then
          table.insert(generals, general.name)
        end
      end
    end
    if #generals == 0 then return end
    if player.tag["godhanxin_orgi_deputy"] == nil then
      player.tag["godhanxin_orgi_deputy"] = player.deputyGeneral
    end
    local general = table.random(generals)
    room:setPlayerMark(player, "@@godhanxin_generalclear-turn", 1) -- 仅做提示
    room:changeHero(player, general, false, true, true, false, false)
  end,
})



return skel
