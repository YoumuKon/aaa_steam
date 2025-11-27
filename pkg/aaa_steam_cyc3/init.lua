local extension = Package("aaa_steam_cyc3")
extension.extensionName = "aaa_steam"

Fk:loadTranslationTable{
  ["aaa_steam_cyc3"] = "嘭嘭嘭", -- 空洞包
  ["hollow"] = "空",
}


-- hollowknight = General:new(extension, "steam__hollowknight", "hollow", 4)
Fk:loadTranslationTable{
  ["steam__hollowknight"] = "空洞骑士",
  ["#steam__hollowknight"] = "",
  ["designer:steam__hollowknight"] = "cyc",
  ["illustrator:steam__hollowknight"] = "",
}

General:new(extension, "steam__hornet", "hollow", 3, 3, General.Female):addSkills{"steam__renzhiyi", "steam__sizhige"}
Fk:loadTranslationTable{
  ["steam__hornet"] = "大黄蜂",
  ["#steam__hornet"] = "",
  ["designer:steam__hornet"] = "cyc",
  ["illustrator:steam__hornet"] = "",
  ["~steam__hornet"] = "哈——",
}

General:new(extension, "steam__quirrel", "hollow", 4):addSkills { "steam__mingzhao", "steam__juejin" }
Fk:loadTranslationTable{
  ["steam__quirrel"] = "奎若",
  ["#steam__quirrel"] = "",
  ["designer:steam__quirrel"] = "cyc",
  ["illustrator:steam__quirrel"] = "",
  ["~steam__quirrel"] = "多斯达噶农",
}

General:new(extension, "steam__soulmaster", "hollow", 4):addSkills { "steam__niuqulinghun", "steam__yongshengzhilu" }
Fk:loadTranslationTable{
  ["steam__soulmaster"] = "灵魂大师",
  ["#steam__soulmaster"] = "",
  ["designer:steam__soulmaster"] = "cyc",
  ["illustrator:steam__soulmaster"] = "",
  ["~steam__soulmaster"] = "唔啊！！！",
}

local collector = General:new(extension, "steam__collector", "hollow", 3)
collector:addSkills{"steam__aizhita", "steam__jierunang"}
collector.shield = 1
Fk:loadTranslationTable{
  ["steam__collector"] = "收藏家",
  ["#steam__collector"] = "",
  ["designer:steam__collector"] = "cyc",
  ["illustrator:steam__collector"] = "",
  ["~steam__collector"] = "（鬼叫）",
}

General:new(extension, "steam__dungdefender", "hollow", 4):addSkills{"steam__yingyongzhixi", "steam__rongyaochongzhuang"}
Fk:loadTranslationTable{
  ["steam__dungdefender"] = "奥格瑞姆",
  ["#steam__dungdefender"] = "",
  ["designer:steam__dungdefender"] = "cyc",
  ["illustrator:steam__dungdefender"] = "",
  ["~steam__dungdefender"] = "",
}

General:new(extension, "steam__crystal_guardian", "hollow", 4):addSkills{"steam__jinghuaqifu", "steam__zhuoreshexian", "steam__shendujineng"}
Fk:loadTranslationTable{
  ["steam__crystal_guardian"] = "水晶守卫",
  ["#steam__crystal_guardian"] = "",
  ["designer:steam__crystal_guardian"] = "cyc",
  ["illustrator:steam__crystal_guardian"] = "",
  ["~steam__crystal_guardian"] = "",
}

General:new(extension, "steam__paleking", "hollow", 5):addSkills{"steam__shengchaosong", "steam__yanqingguo", "steam__mengliushang"}
Fk:loadTranslationTable{
  ["steam__paleking"] = "苍白之王",
  ["#steam__paleking"] = "",
  ["designer:steam__paleking"] = "cyc",
  ["illustrator:steam__paleking"] = "",
  ["~steam__paleking"] = "",
}

General:new(extension, "steam__fourth_chorus", "hollow", 4):addSkills{"steam__qiangyin", "steam__shengyong"}
Fk:loadTranslationTable{
  ["steam__fourth_chorus"] = "圣咏奏唱团",
  ["#steam__fourth_chorus"] = "",
  ["designer:steam__fourth_chorus"] = "cyc",
  ["illustrator:steam__fourth_chorus"] = "",
  ["~steam__fourth_chorus"] = "",
}

General:new(extension, "steam__seth", "hollow", 4):addSkills{"steam__jianke", "steam__shiwei"}
Fk:loadTranslationTable{
  ["steam__seth"] = "赛斯",
  ["#steam__seth"] = "甲木林第一高手",
  ["designer:steam__seth"] = "cyc",
  ["illustrator:steam__seth"] = "",
  ["~steam__seth"] = "",
}

local shakra = General:new(extension, "steam__shakra", "hollow", 4)--
shakra:addSkills{"steam__huiji", "steam__zhange"}
shakra:addRelatedSkills{ "steam__tiaoxin" }
Fk:loadTranslationTable{
  ["steam__shakra"] = "沙克拉",
  ["#steam__shakra"] = "游击地图师",
  ["designer:steam__shakra"] = "cyc",
  ["illustrator:steam__shakra"] = "",
  ["~steam__shakra"] = "",
}

General:new(extension, "steam__goddiaochan", "god", 3, 3, General.Female):addSkills { "steam__meihun", "steam__huoxin" }
Fk:loadTranslationTable{
  ["steam__goddiaochan"] = "神貂蝉",
  ["#steam__goddiaochan"] = "欲界非天",
  ["illustrator:steam__goddiaochan"] = "KayaK",
  ["designer:steam__goddiaochan"] = "cyc",

  ["~steam__goddiaochan"] = "待我归来，定让这天下再为我癫狂！",
}

local wenqin = General:new(extension, "steam__wenqin", "wei", 4, 4, General.Male)--
wenqin:addSkills { "steam__chaoxiong", "steam__xieju" }
wenqin:addRelatedSkills{ "steam__weijing" }
Fk:loadTranslationTable{
  ["steam__wenqin"] = "文钦",
  ["#steam__wenqin"] = "仇烈涸清",
  ["illustrator:steam__wenqin"] = "铁杵文化",
  ["designer:steam__wenqin"] = "cyc",

  ["~steam__wenqin"] = "伺君兵败之日，必报此仇于九泉！",
}

General:new(extension, "steamcyc__huaman", "shu", 4, 4, General.Female):addSkills { "steam__zhuisuo", "steam__changbiao" }
Fk:loadTranslationTable{
  ["steamcyc"] = "蒸",
  ["steamcyc__huaman"] = "花鬘",
  ["#steamcyc__huaman"] = "夷地恋",
  ["illustrator:steamcyc__huaman"] = "",
  ["designer:steamcyc__huaman"] = "cyc",

  ["~steamcyc__huaman"] = "沙场叶落，山花凋零。",
}

local wenqin = General:new(extension, "steamcyc__zerong", "qun", 4, 4, General.Male)--
wenqin:addSkills { "steam__chizong", "steam__yulun" }
wenqin:addRelatedSkills{ "steam__bufo" }
Fk:loadTranslationTable{
  ["steamcyc__zerong"] = "魔笮融",
  ["#steamcyc__zerong"] = "血魔",
  ["illustrator:steamcyc__zerong"] = "",
  ["designer:steamcyc__zerong"] = "cyc",

  ["~steamcyc__zerong"] = "众生不悟，迷之者多。",
  ["!steamcyc__zerong"] = "无有三途苦难之名，但有自然快乐之声。",
}

return extension
