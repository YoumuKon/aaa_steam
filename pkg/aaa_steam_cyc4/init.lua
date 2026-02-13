local extension = Package("aaa_steam_cyc4")
extension.extensionName = "aaa_steam"

Fk:loadTranslationTable{
  ["aaa_steam_cyc4"] = "明日嘭舟",
}

General:new(extension, "steam__necrass", "west", 3, 3, General.Female):addSkills{ "steam__hunxiang", "steam__guiyi" }
Fk:loadTranslationTable{
  ["steam__necrass"] = "死芒",
  ["#steam__necrass"] = "冠死以冕",
  ["illustrator:steam__necrass"] = "STAR影法师",
  ["cv:steam__necrass"] = "浮梦若薇",
  ["designer:steam__necrass"] = "cyc",

  ["~steam__necrass"] = "人们哀悼死亡，而死亡从不哀悼。",
}

local wisadel = General:new(extension, "steam__wisadel", "west", 3, 3, General.Female)
wisadel:addSkills{ "steam__mingxi", "steam__liechen" }
wisadel:addRelatedSkills { "steam__zhiyi" }
Fk:loadTranslationTable{
  ["steam__wisadel"] = "维什戴尔",
  ["#steam__wisadel"] = "目光呆滞",
  ["illustrator:steam__wisadel"] = "Liduke",
  ["cv:steam__wisadel"] = "竹达彩奈",
  ["designer:steam__wisadel"] = "cyc",

  ["~steam__wisadel"] = "そんなに死にたい？",
}

General:new(extension, "steam__surtr", "west", 5, 5, General.Female):addSkills{ "steam__xunlie" }
Fk:loadTranslationTable{
  ["steam__surtr"] = "史尔特尔",
  ["#steam__surtr"] = "熔核巨影",
  ["illustrator:steam__surtr"] = "Ask",
  ["cv:steam__surtr"] = "堀江由衣",
  ["designer:steam__surtr"] = "cyc",

  ["~steam__surtr"] = "就这？",
}

General:new(extension, "steam__schwarz", "west", 4, 4, General.Female):addSkills{ "steam__guanche", "steam__shizhong" }
Fk:loadTranslationTable{
  ["steam__schwarz"] = "黑",
  ["#steam__schwarz"] = "深夏的守夜人",
  ["illustrator:steam__schwarz"] = "Ask",
  ["cv:steam__schwarz"] = "伊藤静",
  ["designer:steam__schwarz"] = "铝",

  ["~steam__schwarz"] = "博士，走，我会优先确保你的安全。",
  ["!steam__schwarz"] = "按照你的指示，没有漏网之鱼。",
}

General:new(extension, "steam__ulpianus", "west", 5):addSkills{ "steam__jianzhu", "steam__pilu" }
Fk:loadTranslationTable{
  ["steam__ulpianus"] = "乌尔比安",
  ["#steam__ulpianus"] = "海超人",
  ["illustrator:steam__ulpianus"] = "Skade",
  ["cv:steam__ulpianus"] = "小野大辅",
  ["designer:steam__ulpianus"] = "cyc",

  ["~steam__ulpianus"] = "并非所有人都能迎接胜利，但失败的代价需要所有人来承受。",
}

General:new(extension, "steam__goldenglow", "west", 3, 3, General.Female):addSkills{ "steam__daoliu", "steam__xinmai", "steam__zhanyao" }
Fk:loadTranslationTable{
  ["steam__goldenglow"] = "澄闪",
  ["#steam__goldenglow"] = "绿意火花",
  ["illustrator:steam__goldenglow"] = "Namie",
  ["cv:steam__goldenglow"] = "佐仓绫音",
  ["designer:steam__goldenglow"] = "cyc",

  ["~steam__goldenglow"] = "就差一点点……",
}

local thunderbringer = General:new(extension, "steam__leizi_the_thunderbringer", "han", 3, 3, General.Female)
thunderbringer.shield = 1
thunderbringer:addSkills{ "steam__mingduan", "steam__shewei" }
Fk:loadTranslationTable{
  ["steam__leizi_the_thunderbringer"] = "司霆惊蛰",
  ["#steam__leizi_the_thunderbringer"] = "诛邪雷法",
  ["illustrator:steam__leizi_the_thunderbringer"] = "竜崎いち",
  ["cv:steam__leizi_the_thunderbringer"] = "徐徐",
  ["designer:steam__leizi_the_thunderbringer"] = "cyc",

  ["~steam__leizi_the_thunderbringer"] = "心静则神清，不和你计较。",
}

General:new(extension, "steam__nian", "han", 4, 4, General.Female):addSkills{ "steam__jiebing", "steam__zhushen", "steam__xieguo" }
Fk:loadTranslationTable{
  ["steam__nian"] = "年",
  ["#steam__nian"] = "申铸",
  ["illustrator:steam__nian"] = "幻象黑兔",
  ["cv:steam__nian"] = "橙璃",
  ["designer:steam__nian"] = "cyc",

  ["~steam__nian"] = "我为什么要在你们这些低劣造物上浪费时间！",
}

General:new(extension, "steam__chongyue", "han", 4, 4):addSkills{ "steam__gangqi", "steam__shuheng"}
Fk:loadTranslationTable{
  ["steam__chongyue"] = "朔",
  ["#steam__chongyue"] = "子武",
  ["illustrator:steam__chongyue"] = "KuroBlood",
  ["cv:steam__chongyue"] = "贾邱",
  ["designer:steam__chongyue"] = "cyc",

  ["~steam__chongyue"] = "你们解决问题，还是只会仰仗干戈吗！",
}

General:new(extension, "steam__shu", "han", 3, 4, General.Female):addSkills{ "steam__yinglin", "steam__linyu", "steam__kurong"}
Fk:loadTranslationTable{
  ["steam__shu"] = "黍",
  ["#steam__shu"] = "巳农",
  ["illustrator:steam__shu"] = "IRIS_呓",
  ["cv:steam__shu"] = "徐晨",
  ["designer:steam__shu"] = "cyc",

  ["~steam__shu"] = "眼前的惨剧，又是何时种下的因呢...",
}

General:new(extension, "steam__xi", "han", 3, 3, General.Female):addSkills{ "steam__ranjing", "steam__mogu" }
Fk:loadTranslationTable{
  ["steam__xi"] = "夕",
  ["#steam__xi"] = "戌绘",
  ["illustrator:steam__xi"] = "幻象黑兔",
  ["cv:steam__xi"] = "空无的念",
  ["designer:steam__xi"] = "cyc",

  ["~steam__xi"] = "墨汁要洒了！",
}

General:new(extension, "steam__ling", "han", 3, 3, General.Female):addSkills{ "steam__changyin", "steam__zuitan" }
Fk:loadTranslationTable{
  ["steam__ling"] = "令",
  ["#steam__ling"] = "寅诗",
  ["illustrator:steam__ling"] = "下野宏铭",
  ["cv:steam__ling"] = "余珊",
  ["designer:steam__ling"] = "cyc",

  ["~steam__ling"] = "此刻便算入秋了。",
}

General:new(extension, "steam__yu", "han", 4, 4):addSkills{ "steam__baizao", "steam__shengyan" }
Fk:loadTranslationTable{
  ["steam__yu"] = "余",
  ["#steam__yu"] = "亥食",
  ["illustrator:steam__yu"] = "一千",
  ["cv:steam__yu"] = "卢晓彤",
  ["designer:steam__yu"] = "cyc",

  ["~steam__yu"] = "禁止明火吗，唔...",
}

General:new(extension, "steam__wang", "han", 3, 3):addSkills{ "steam__qihe", "steam__shijie" }
Fk:loadTranslationTable{
  ["steam__wang"] = "望",
  ["#steam__wang"] = "丑谋",
  ["illustrator:steam__wang"] = "KuroBlood",
  ["cv:steam__wang"] = "弦雾妖弦",
  ["designer:steam__wang"] = "cyc",

  ["~steam__wang"] = "尽出点馊主意。",
}

local weapon__steam__qihe = fk.CreateCard{
  name = "&weapon__steam__qihe",
  type = Card.TypeEquip,
  sub_type = Card.SubtypeWeapon,
}
extension:loadCardSkels{weapon__steam__qihe}
extension:addCardSpec("weapon__steam__qihe")

local armor__steam__qihe = fk.CreateCard{
  name = "&armor__steam__qihe",
  type = Card.TypeEquip,
  sub_type = Card.SubtypeArmor,
}
extension:loadCardSkels{armor__steam__qihe}
extension:addCardSpec("armor__steam__qihe")

local offensive_horse__steam__qihe = fk.CreateCard{
  name = "&offensive_horse__steam__qihe",
  type = Card.TypeEquip,
  sub_type = Card.SubtypeOffensiveRide,
}
extension:loadCardSkels{offensive_horse__steam__qihe}
extension:addCardSpec("offensive_horse__steam__qihe")

local defensive_horse__steam__qihe = fk.CreateCard{
  name = "&defensive_horse__steam__qihe",
  type = Card.TypeEquip,
  sub_type = Card.SubtypeDefensiveRide,
}
extension:loadCardSkels{defensive_horse__steam__qihe}
extension:addCardSpec("defensive_horse__steam__qihe")

local treasure__steam__qihe = fk.CreateCard{
  name = "&treasure__steam__qihe",
  type = Card.TypeEquip,
  sub_type = Card.SubtypeTreasure,
}
extension:loadCardSkels{treasure__steam__qihe}
extension:addCardSpec("treasure__steam__qihe")
Fk:loadTranslationTable{
  ["weapon__steam__qihe"] = "云与漆X",
  ["armor__steam__qihe"] = "云与漆X",
  ["offensive_horse__steam__qihe"] = "云与漆X",
  ["defensive_horse__steam__qihe"] = "云与漆X",
  ["treasure__steam__qihe"] = "云与漆X",
  [":weapon__steam__qihe"] = "这是一张“云与漆”衍生的武器。",
  [":armor__steam__qihe"] = "这是一张“云与漆”衍生的防具。",
  [":offensive_horse__steam__qihe"] = "这是一张“云与漆”衍生的进攻坐骑。",
  [":defensive_horse__steam__qihe"] = "这是一张“云与漆”衍生的防御坐骑。",
  [":treasure__steam__qihe"] = "这是一张“云与漆”衍生的宝物。",
}

General:new(extension, "steam__mlynar", "west", 6, 6):addSkills{ "steam__mochen", "steam__fengmang"}
Fk:loadTranslationTable{
  ["steam__mlynar"] = "玛恩纳",
  ["#steam__mlynar"] = "读报僵尸",
  ["illustrator:steam__mlynar"] = "竜崎いち",
  ["cv:steam__mlynar"] = "王宇航",
  ["designer:steam__mlynar"] = "cyc",

  ["~steam__mlynar"] = "没有其他工作的话，我就先行告退了。",
}

General:new(extension, "steam__Degenbrecher", "west", 4, 4, General.Female):addSkills { "steam__xuanqi", "steam__xiaomie", }
Fk:loadTranslationTable{
  ["steam__Degenbrecher"] = "锏",
  ["#steam__Degenbrecher"] = "传奇三罐王",
  ["illustrator:steam__Degenbrecher"] = "竜崎いち",
  ["designer:steam__Degenbrecher"] = "cyc",
  ["cv:steam__Degenbrecher"] = "吴迪",

  ["~steam__Degenbrecher"] = "还沉浸在过往之中吗……",
}

return extension
