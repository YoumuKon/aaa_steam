local extension = Package("aaa_steam_cyc2")
extension.extensionName = "aaa_steam"

Fk:loadTranslationTable{
  ["aaa_steam_cyc2"] = "嘭！！", -- LOL包
}


General:new(extension, "steam__lillia", "west", 3, 3, General.Female):addSkills{"steam__mengmanzhi", "steam__feihuata", "steam__jinghuangmu", "steam__liuwozhong", "steam__yelanyao"}
Fk:loadTranslationTable{
  ["steam__lillia"] = "莉莉娅",
  ["#steam__lillia"] = "含羞蓓蕾",
  ["illustrator:steam__lillia"] = "",
  ["designer:steam__lillia"] = "cyc",

  ["~steam__lillia"] = "哦！嚯…哦……",
}

General:new(extension, "steam__nasus", "west", 4):addSkills{"steam__siphoning_strike", "steam__spirit_fire", "steam__wither"}
Fk:loadTranslationTable{
  ["steam__nasus"] = "内瑟斯",
  ["#steam__nasus"] = "沙漠死神",
  ["illustrator:steam__nasus"] = "Christian Fell",
  ["designer:steam__nasus"] = "cyc",
}

General:new(extension, "steam__gangplank", "west", 3):addSkills{"steam__huoyaotong", "steam__huaixueliaofa", "steam__qianghuotanpan"}
Fk:loadTranslationTable{
  ["steam__gangplank"] = "普朗克",
  ["#steam__gangplank"] = "海洋之灾",
  ["cv:steam__gangplank"] = "英雄联盟",
  ["designer:steam__gangplank"] = "cyc",
  ["illustrator:steam__gangplank"] = "英雄联盟",

  ["~steam__gangplank"] = "我回来时会变得更强。",
}

local renata = General:new(extension, "steam__renata", "west", 3, 3, General.Female)
renata:addSkills {"steam__zhongchengjili", "steam__jishijiunan", "steam__eyishougou"}
renata:addRelatedSkill("steam__dunxi")
Fk:loadTranslationTable{
  ["steam__renata"] = "烈娜塔", -- 烈娜塔·戈拉斯克 Renata Glasc
  ["#steam__renata"] = "炼金男爵",
  ["illustrator:steam__renata"] = "",
  ["designer:steam__renata"] = "cyc",
  ["~steam__renata"] = "终于，我能和他们团聚了…",
}

General:new(extension, "steam__masteryi", "west", 3):addSkills {"steam__aerfatuxi", "steam__mingxiang", "steam__wujijiandao", "steam__gaoyuanxuetong"}
Fk:loadTranslationTable{
  ["steam__masteryi"] = "易",
  ["#steam__masteryi"] = "无极剑圣",
  ["cv:steam__masteryi"] = "英雄联盟",
  ["designer:steam__masteryi"] = "cyc",
  ["illustrator:steam__masteryi"] = "英雄联盟",
  ["~steam__masteryi"] = "这将会是一个惨痛的教训",
}

local viktor = General:new(extension, "steam__viktor", "west", 3)
viktor:addSkills{"steam__xianlu", "steam__rongsheng", "steam__guangrongjinhua"}
viktor.shield = 1
Fk:loadTranslationTable{
  ["steam__viktor"] = "维克托",
  ["#steam__viktor"] = "奥术先驱",
  ["illustrator:steam__viktor"] = "",
  ["designer:steam__viktor"] = "cyc",
  ["~steam__viktor"] = "没有进化……就没有自由……",
}

local talon = General:new(extension, "steam__talon", "west", 3)
talon:addSkills{ "steam__daofengzhimo", "steam__zhancaochugen", "steam__cikezhidao", "steam__anyingtuxi" }
talon.shield = 1
Fk:loadTranslationTable{
  ["steam__talon"] = "泰隆",
  ["#steam__talon"] = "刀锋之影",
  ["illustrator:steam__talon"] = "",
  ["designer:steam__talon"] = "cyc",
  ["~steam__talon"] = "哈哈哈哈哈哈……",
}

local anbesa = General:new(extension, "steam__anbesa", "west", 4, 4, General.Female)
anbesa:addSkills{"steam__longquanguibu", "steam__anxi", "steam__tieling", "steam__gongkaichuxing"}
anbesa:addRelatedSkill("steam__chuanwu")
Fk:loadTranslationTable{
  ["steam__anbesa"] = "安蓓萨",
  ["#steam__anbesa"] = "铁血狼母",
  ["designer:steam__anbesa"] = "cyc",
  ["illustrator:steam__anbesa"] = "",
  ["~steam__anbesa"] = "呃啊！",
}

General:new(extension, "steam__fiora", "west", 4, 4, General.Female):addSkills{ "steam__xunzhan", "steam__jueyu" }
Fk:loadTranslationTable{
  ["steam__fiora"] = "菲奥娜",
  ["#steam__fiora"] = "无双剑姬",
  ["designer:steam__fiora"] = "CYC",
  ["illustrator:steam__fiora"] = "潘诚伟",

  ["~steam__fiora"] = " 你们看上去像体面人，我不想下手太狠。",
}

General:new(extension, "steam__shaco", "west", 1):addSkills{"steam__fear_box", "steam__deceive_magic"}
Fk:loadTranslationTable{
  ["steam__shaco"] = "萨科",
  ["#steam__shaco"] = "恶魔小丑",
  ["illustrator:steam__shaco"] = "Evan Monteiro",
  ["designer:steam__shaco"] = "cyc",

  ["~steam__shaco"] = "额啊——",
}

Fk:loadTranslationTable{
  ["steam__thresh"] = "锤石",
  ["#steam__thresh"] = "魂锁典狱长",
  ["illustrator:steam__thresh"] = "Victor Maury",
  ["designer:steam__thresh"] = "cyc",

  ["~steam__thresh"] = "我，疯了？很有可能——",
}

General:new(extension, "steam__ahri", "west", 3, 3, General.Female):addSkills{ "steam__essence_theft", "steam__spirit_rush" }
Fk:loadTranslationTable{
  ["steam__ahri"] = "阿狸",
  ["#steam__ahri"] = "九尾妖狐",
  ["illustrator:steam__ahri"] = "Chengwei Pan",
  ["designer:steam__ahri"] = "cyc",

  ["~steam__ahri"] = "说不定，我能再见到他……",
}

-- General:new(extension, "steam__sylas", "west", 4)
Fk:loadTranslationTable{
  ["steam__sylas"] = "塞拉斯",
  ["#steam__sylas"] = "解脱者",
  ["illustrator:steam__sylas"] = "Victor Maury",
  ["designer:steam__sylas"] = "cyc",

  ["~steam__sylas"] = "终于，不再有墙了…",
}

Fk:loadTranslationTable{
  ["steam__janna"] = "迦娜",
  ["#steam__janna"] = "风暴之怒",
  ["illustrator:steam__janna"] = "Jason Chan",
  ["designer:steam__janna"] = "cyc",

  ["~steam__janna"] = "真理之意，与我同在……",
}

-- General:new(extension, "steam__nocturne", "west", 4)
Fk:loadTranslationTable{
  ["steam__nocturne"] = "魔腾",
  ["#steam__nocturne"] = "永恒梦魇",
  ["illustrator:steam__nocturne"] = "Francis Tneh",
  ["designer:steam__nocturne"] = "cyc",

  ["~steam__nocturne"] = "哎呀，哎呀，哎吼，吼！",
}

General:new(extension, "steam__mundo", "west", 5, 6):addSkills{ "steam__dalixingyi" }
Fk:loadTranslationTable{
  ["steam__mundo"] = "蒙多",
  ["#steam__mundo"] = "祖安狂人",
  ["illustrator:steam__mundo"] = "",
  ["designer:steam__mundo"] = "cyc",

  ["~steam__mundo"] = "谁来治蒙多……",
}

General:new(extension, "steam__udyr", "west", 4):addSkills{"steam__zhonglingniudai", "steam__xianzuzhaohuan"}
Fk:loadTranslationTable{
  ["steam__udyr"] = "乌迪尔",
  ["#steam__udyr"] = "兽灵行者",
  ["illustrator:steam__udyr"] = "",
  ["designer:steam__udyr"] = "cyc",
  ["~steam__udyr"] = "终于……一片寂静……",
}

General:new(extension, "steam__volibear", "west", 4):addSkills{"steam__kuangleijianqi", "steam__pitianlidi"}
Fk:loadTranslationTable{
  ["steam__volibear"] = "沃利贝尔",
  ["#steam__volibear"] = "不灭狂雷",
  ["illustrator:steam__volibear"] = "",
  ["designer:steam__volibear"] = "猫",

  -- ["~steam__volibear"] = "",
}

General:new(extension, "steam__neeko", "west", 3, 3, General.Female):addSkills{"steam__huanmei", "steam__zhanfang",}
Fk:loadTranslationTable{
  ["steam__neeko"] = "妮蔻",
  ["#steam__neeko"] = "万花通灵",
  ["illustrator:steam__neeko"] = "",
  ["designer:steam__neeko"] = "cyc",
  ["~steam__neeko"] = " ",
}


local godhanxin = General:new(extension, "steam__godhanxin", "god", 4, 13)
godhanxin:addSkills{"steam__qiangjue", "steam__qingzhan" }
godhanxin:addRelatedSkills{
  "godhanxin__xiangsi", -- 相思
  "godhanxin__duanchang", -- 断肠
  "godhanxin__manglong", -- 盲龙
  "godhanxin__fengliu", -- 风流
  "godhanxin__wushuang", -- 无双
  "godhanxin__bailong", -- 白龙
  "godhanxin__wangchuan", -- 忘川
  "godhanxin__kunpeng", -- 鲲鹏
  "godhanxin__baiguiyexing", -- 百鬼夜行
  "godhanxin__xunchou", -- 寻仇
  "godhanxin__baijiangfenghou", -- 拜将封侯
  "godhanxin__taitou", -- 抬头
  "godhanxin__womingyouwo", -- 我命由我不由天
}

Fk:loadTranslationTable{
  ["steam__godhanxin"] = "神韩信",
  ["#steam__godhanxin"] = "国服",
  ["cv:steam__godhanxin"] = "小仔爷",
  ["illustrator:steam__godhanxin"] = "山海经异兽录",
  ["designer:steam__godhanxin"] = "cyc",

  ["~steam__godhanxin"] = "你和韩信无缘！",
}




return extension
