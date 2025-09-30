local changyin = fk.CreateSkill {
  name = "steam__changyin",
  tags = { Skill.Rhyme },
  dynamic_desc = function (self, player, lang)
    if player:getMark("@@steam__changyin1") > 0 then
      return "韵律技，出牌阶段限一次，<font color=\"#E0DB2F\">平：你可以弃置两张牌，摸两张牌名押韵的牌</font>；仄：你可以弃置两张牌名押韵的牌，摸四张牌。<br>转韵：你使用【酒】。"
    elseif player:getMark("@@steam__changyin2") > 0 then
      return "韵律技，出牌阶段限一次，平：你可以弃置两张牌，摸两张牌名押韵的牌；<font color=\"#E0DB2F\">仄：你可以弃置两张牌名押韵的牌，摸四张牌</font>。<br>转韵：你使用【酒】。"
    end
    return "韵律技，出牌阶段限一次，平：你可以弃置两张牌，摸两张牌名押韵的牌；仄：你可以弃置两张牌名押韵的牌，摸四张牌。<br>转韵：你使用【酒】。"
  end,
}

Fk:loadTranslationTable{
  ["steam__changyin"] = "长吟",
  [":steam__changyin"] = "韵律技，出牌阶段限一次，平：你可以弃置两张牌，摸两张牌名押韵的牌；仄：你可以弃置两张牌名押韵的牌，摸四张牌。<br>转韵：你使用【酒】。",

  ["#steam__changyin-1"] = "长吟：弃置两张牌，获得两张牌名押韵的牌。",
  ["#steam__changyin-2"] = "长吟：弃置两张牌名押韵的牌，摸四张牌。",
  ["#steam__changyin-3"] = "长吟：韵律状态获取异常，技能无法执行效果。",
  ["@@steam__changyin1"] = "长吟 平",
  ["@@steam__changyin2"] = "长吟 仄",

  ["$steam__changyin1"] = "满酹杯中物，天下共余愁。",
  ["$steam__changyin2"] = "万物一言，方有大气象。",
}

local changyin_pairs = {
  --a ia ua：杀，万箭齐发，藤甲，木牛流马，兵临城下，桐油百韧甲，烂银甲，商鞅变法，奇门八卦
  a = {
    "slash",
    "archery_attack",
    "vine",
    "wooden_ox",
    "enemy_at_the_gates",
    "ex_vine",
    "glittery_armor",
    "shangyang_reform",
    "py_diagram",
  },

  --o e uo：衠钢槊，三略，霹雳车，大攻车，连弩战车，望梅止渴
  e = {
    "steel_lance",
    "py_threebook",
    "catapult",
    "siege_engine",
    "offensive_siege_engine",
    "defensive_siege_engine",
    "wd_crossbow_tank",
    "wd_stop_thirst"
  },

  --ie ve：趁火打劫
  ie = {
    "looting"
  },

  --ai uai：黑光铠，瞒天过海，玲珑狮蛮带
  ai = {
    "dark_armor",
    "underhanding",
    "py_belt",
  },

  --ei ui：调剂盐梅，以半击倍，浮雷，照月狮子盔，养精蓄锐
  ei = {
    "redistribute",
    "defeating_the_double",
    "floating_thunder",
    "ex_silver_lion",
    "wd_save_energy",
  },

  --ao iao：桃，青龙偃月刀，丈八蛇矛，过河拆桥，古锭刀，笑里藏刀，七宝刀，金蝉脱壳，增兵减灶，以逸待劳，三尖两刃刀，鬼龙斩月刀，红棉百花袍，
  --国风玉袍，烈淬刀，七星刀，家常小炒
  ao = {
    "peach",
    "blade",
    "spear",
    "dismantlement",
    "guding_blade",
    "daggar_in_smile",
    "seven_stars_sword",
    "crafty_escape",
    "reinforcement",
    "await_exhausted",
    "triblade",
    "py_blade",
    "py_robe",
    "py_cloak",
    "quenched_blade",
    "wd_seven_stars_sword",
    "steam_baizao_equip",
  },

  --ou iu：无中生有，决斗，骅骝，酒，走
  ou = {
    "ex_nihilo",
    "duel",
    "huailiu",
    "analeptic",
    "wd_run",
  },

  --an ian uan van：闪，闪电，青釭剑，雌雄双股剑，寒冰剑，爪黄飞电，大宛，兵粮寸断，朱雀羽扇，铁索连环，乌铁锁链，五行鹤翎扇，逐近弃远，
  --砖，吴六剑，真龙长剑，束发紫金冠，虚妄之冕，思召剑，水波剑，玄剑
  an = {
    "jink",
    "lightning",
    "qinggang_sword",
    "double_swords",
    "ice_sword",
    "zhuahuangfeidian",
    "dayuan",
    "supply_shortage",
    "fan",
    "iron_chain",
    "black_chain",
    "five_elements_fan",
    "chasing_near",
    "n_brick",
    "six_swords",
    "qin_dragon_sword",
    "py_hat",
    "py_coronet",
    "sizhao_sword",
    "water_sword",
    "xuanjian_sword",
  },

  --en in un vn：借刀杀人，南蛮入侵，八卦阵，仁王盾，水淹七军，先天八卦阵，仁王金刚盾，天雷刃，太极拂尘，金
  en = {
    "collateral",
    "savage_assault",
    "eight_diagram",
    "nioh_shield",
    "drowning",
    "horsetail_whisk",
    "ex_eight_diagram",
    "ex_nioh_shield",
    "thunder_blade",
    "wd_drowning",
    "wd_gold",
  },

  --ang iang uang：顺手牵羊，李代桃僵，银月枪，红缎枪，粮
  ang = {
    "snatch",
    "substituting",
    "moon_spear",
    "red_spear",
    "wd_rice",
  },

  --eng ing ong ung：五谷丰登，麒麟弓，绝影，紫骍，火攻，护心镜，奇正相生，弃甲曳兵，草木皆兵，远交近攻，赤血青锋，照骨镜，欲擒故纵
  eng = {
    "amazing_grace",
    "kylin_bow",
    "jueying",
    "zixing",
    "fire_attack",
    "breastplate",
    "raid_and_frontal_attack",
    "abandoning_armor",
    "paranoid",
    "befriend_attacking",
    "blood_sword",
    "py_mirror",
    "wd_breastplate",
    "wd_let_off_enemy",
  },

  --i er v：桃园结义，无懈可击，方天画戟，白银狮子，出其不意，洞烛先机，美人计，传国玉玺，违害就利，声东击西，斗转星移，知己知彼，
  --无双方天戟，镔铁双戟，混毒弯匕，日月戟
  i = {
    "god_salvation",
    "nullification",
    "halberd",
    "silver_lion",
    "unexpectation",
    "foresight",
    "honey_trap",
    "qin_seal",
    "avoiding_disadvantages",
    "diversion",
    "time_flying",
    "known_both",
    "py_halberd",
    "py_double_halberd",
    "poisonous_dagger",
    "wd_sun_moon_halberd",
  },

  --u：乐不思蜀，诸葛连弩，贯石斧，赤兔，的卢，天机图，太公阴符，毒，偷梁换柱，推心置腹，文和乱武，连弩，悦刻五，太平要术，
  --四乘粮舆，铁蒺玄舆，飞轮战舆，金梳，琼梳，犀梳，秦弩，元戎精械弩，灵宝仙葫，冲应神符，白鹄，诱敌深入，古旧铸物
  u = {
    "indulgence",
    "crossbow",
    "axe",
    "chitu",
    "dilu",
    "wonder_map",
    "taigong_tactics",
    "poison",
    "replace_with_a_fake",
    "sincere_treat",
    "wenhe_chaos",
    "xbow",
    "n_relx_v",
    "peace_spell",
    "grain_cart",
    "caltrop_cart",
    "wheel_cart",
    "golden_comb",
    "jade_comb",
    "rhino_comb",
    "qin_crossbow",
    "ex_crossbow",
    "celestial_calabash",
    "talisman",
    "wd_baihu",
    "wd_lure_in_deep",
    "steam_zhushen_equip",
  },
}

changyin:addEffect("active", {
  mute = true,
  prompt = function (self, player, selected_cards, selected_targets)
    if player:getMark("@@steam__changyin1") > 0 then
      return "#steam__changyin-1"
    elseif player:getMark("@@steam__changyin2") > 0 then
      return "#steam__changyin-2"
    end
    return "#steam__changyin-3"
  end,
  card_num = 2,
  target_num = 0,
  can_use = function(self, player)
    return (player:getMark("@@steam__changyin1") > 0 or player:getMark("@@steam__changyin2") > 0) and
    player:usedSkillTimes(changyin.name, Player.HistoryPhase) == 0
  end,
  card_filter = function (self, player, to_select, selected)
    if player:getMark("@@steam__changyin1") > 0 then
      return #selected < 2 and not player:prohibitDiscard(Fk:getCardById(to_select))
    elseif player:getMark("@@steam__changyin2") > 0 then
      local match = false
      if #selected == 1 then
        for _, v in pairs(changyin_pairs) do
          if table.contains(v, Fk:getCardById(selected[1]).trueName) and table.contains(v, Fk:getCardById(to_select).trueName) then
            match = true
          end
        end
      end
      return not player:prohibitDiscard(Fk:getCardById(to_select)) and (#selected == 0 or (#selected == 1 and match))
    elseif not player:getMark("@@steam__changyin1") > 0 and not player:getMark("@@steam__changyin2") > 0 then
      return false
    end
  end,
  target_filter = Util.FalseFunc,
  on_use = function(self, room, effect)
    local player = effect.from
    local card = effect.cards
    local rhyme = 0
    room:notifySkillInvoked(player, changyin.name, "drawcard")
    if player:getMark("@@steam__changyin1") > 0 then
      rhyme = 1
      player:broadcastSkillInvoke(changyin.name, 1)
    end
    if player:getMark("@@steam__changyin2") > 0 then
      rhyme = 2
      player:broadcastSkillInvoke(changyin.name, 2)
    end
    room:throwCard(card, changyin.name, player, player)
    if player.dead then return end
    if rhyme == 1 then
      local list = {}
      local rhyme_types = {}
      for z, _ in pairs(changyin_pairs) do
        table.insertIfNeed(rhyme_types, z)
      end
      while #list < 2 and #rhyme_types > 0 do
        local random_idx = 0
        random_idx = random_idx + math.random(#rhyme_types)
        local random_rhyme = rhyme_types[random_idx]
        local card_list = changyin_pairs[random_rhyme]
        for _, card_id in ipairs(room.draw_pile) do
          if table.contains(card_list, Fk:getCardById(card_id).trueName) then
            table.insertIfNeed(list, card_id)
          end
        end
        if #list < 2 then
          for _, card_id in ipairs(room.discard_pile) do
            if table.contains(card_list, Fk:getCardById(card_id).trueName) then
              table.insertIfNeed(list, card_id)
            end
          end
        end
        if #list >= 2 then break end
        if #list < 2 then
          list = {}
        end
        table.remove(rhyme_types, random_idx)
      end
      if #list > 0 then
        if table.find(list, function (id) return Fk:getCardById(id).trueName ~= Fk:getCardById(list[1]).trueName end) then
          local listx = {list[1]}
          table.insert (listx, table.random(table.filter(list, function (id) return Fk:getCardById(id).trueName ~= Fk:getCardById(list[1]).trueName end), 1))
          room:obtainCard(player, listx, true, fk.ReasonPrey, player, changyin.name)
        else
          room:obtainCard(player, {table.random(list, 2)}, true, fk.ReasonPrey, player, changyin.name)
        end
      end
    elseif rhyme == 2 then
      player:drawCards(4, changyin.name)
    end
  end,
})

changyin:addEffect(fk.CardUsing, {
  can_refresh = function(self, event, target, player, data)
    return player:hasSkill("steam__changyin", true) and data.card.trueName == "analeptic" and target == player
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    for i = 1 , 2 , 1 do
      if player:getMark("@@steam__changyin"..i) > 0 then
        room:notifySkillInvoked(player, changyin.name, "switch")
        local n = i + 1 > 2 and 1 or i + 1
        room:setPlayerMark(player, "@@steam__changyin"..n, 1)
        room:setPlayerMark(player, "@@steam__changyin"..i, 0)
        --player:setSkillUseHistory(changyin.name, 0, Player.HistoryPhase)
        break
      end
    end
  end,
})

changyin:addAcquireEffect(function (self, player, is_start)
  player.room:setPlayerMark(player, "@@steam__changyin1", 1)
end)

changyin:addLoseEffect(function (self, player, is_death)
  player.room:setPlayerMark(player, "@@steam__changyin1", 0)
  player.room:setPlayerMark(player, "@@steam__changyin2", 0)
end)

return changyin
