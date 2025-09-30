local extension = Package("aaa_steam_cyc")
extension.extensionName = "aaa_steam"

Fk:loadTranslationTable{
  ["aaa_steam_cyc"] = "嘭！", -- 以撒包
}



local isaac = General:new(extension, "steam__isaac", "west", 3)
isaac:addSkill("steam__mingyunzhitou")
isaac.shield = 1
Fk:loadTranslationTable{
  ["steam__isaac"] = "以撒",
  ["#steam__isaac"] = "",
  ["designer:steam__isaac"] = "cyc",
  ["illustrator:steam__isaac"] = "矢泽秋落",
}

General:new(extension, "steam__corrupted_isaac", "west", 4):addSkills { "steam__kuanlu", "steam__xiashen" }
Fk:loadTranslationTable{
  ["steam__corrupted_isaac"] = "堕化以撒",
  ["#steam__corrupted_isaac"] = "",
  ["designer:steam__corrupted_isaac"] = "cyc",
  ["illustrator:steam__corrupted_isaac"] = "矢泽秋落",
}

General:new(extension, "steam__eden", "west", 4, 4, General.Female):addSkill("steam__tianzhuding")
Fk:loadTranslationTable{
  ["steam__eden"] = "伊甸",
  ["#steam__eden"] = "",
  ["designer:steam__eden"] = "cyc",
  ["illustrator:steam__eden"] = "矢泽秋落",
}

General:new(extension, "steam__error_eden", "west", 4, 4, General.Female):addSkill("steam__cuowuji")
Fk:loadTranslationTable{
  ["steam__error_eden"] = "堕化伊甸",
  ["#steam__error_eden"] = "",
  ["designer:steam__error_eden"] = "cyc",
  ["illustrator:steam__error_eden"] = "矢泽秋落",
}

General:new(extension, "steam__eve", "west", 3, 3, General.Female):addSkills {"steam__jinjizhimen", "steam__yonghengzhizhou"}
Fk:loadTranslationTable{
  ["steam__eve"] = "夏娃",
  ["#steam__eve"] = "",
  ["designer:steam__eve"] = "cyc",
  ["illustrator:steam__eve"] = "矢泽秋落",
}

local corrupted_eve =  General:new(extension, "steam__corrupted_eve", "west", 3, 3, General.Female)
corrupted_eve:addSkills{"steam__xuehcao", "steam__xueming"}
corrupted_eve:addRelatedSkills{"steam1__zhiyi_draw", "steam1__zhiyi_use"}
Fk:loadTranslationTable{
  ["steam__corrupted_eve"] = "堕化夏娃",
  ["#steam__corrupted_eve"] = "",
  ["designer:steam__corrupted_eve"] = "cyc",
  ["illustrator:steam__corrupted_eve"] = "矢泽秋落",
}

General:new(extension, "steam__azazel", "west", 4):addSkills{"steam__fenhenqingxie", "steam__emokuangnu"}
Fk:loadTranslationTable{
  ["steam__azazel"] = "阿撒泻勒",
  ["#steam__azazel"] = "",
  ["designer:steam__azazel"] = "cyc",
  ["illustrator:steam__azazel"] = "矢泽秋落",
}

General:new(extension, "steam__corrupted_azazel", "west", 5):addSkills{"steam__xuehou", "steam__xueqing", "steam__emobaofa"}
Fk:loadTranslationTable{
  ["steam__corrupted_azazel"] = "堕化阿撒泻勒",
  ["#steam__corrupted_azazel"] = "",
  ["designer:steam__corrupted_azazel"] = "cyc",
  ["illustrator:steam__corrupted_azazel"] = "矢泽秋落",
}

General:new(extension, "steam__cain", "west", 4):addSkills{"steam__secret_passage", "steam__wall_breaker"}
Fk:loadTranslationTable{
  ["steam__cain"] = "该隐",
  ["#steam__cain"] = "",
  ["illustrator:steam__cain"] = "矢泽秋落",
  ["designer:steam__cain"] = "cyc",
}

General:new(extension, "steam__corrupted_cain", "west", 4):addSkills { "steam__zhudingweida", "steam__mingbuyoutian" }
Fk:loadTranslationTable{
  ["steam__corrupted_cain"] = "堕化该隐",
  ["#steam__corrupted_cain"] = "",
  ["designer:steam__corrupted_cain"] = "cyc",
  ["illustrator:steam__corrupted_cain"] = "矢泽秋落",
}

General:new(extension, "steam__lilith", "west", 3, 3, General.Female):addSkills {
  "steam__diyudao", "steam__emoshoutai",
  "steam__chongshen", "steam1__chongshen", "steam2__chongshen", "steam3__chongshen",
}
Fk:loadTranslationTable{
  ["steam__lilith"] = "莉莉丝",
  ["#steam__lilith"] = "",
  ["designer:steam__lilith"] = "cyc",
  ["illustrator:steam__lilith"] = "矢泽秋落",
}

local corrupted_lilith = General:new(extension, "steam__corrupted_lilith", "west", 3, 3, General.Female)
corrupted_lilith:addSkills{"steam__emorenshen", "steam__taiernuquan"}
corrupted_lilith:addRelatedSkill("steam__chongshen")
Fk:loadTranslationTable{
  ["steam__corrupted_lilith"] = "堕化莉莉丝",
  ["#steam__corrupted_lilith"] = "",
  ["designer:steam__corrupted_lilith"] = "cyc",
  ["illustrator:steam__corrupted_lilith"] = "矢泽秋落",
}

General:new(extension, "steam__samson", "west", 6):addSkills { "steam__nuyizengsheng" }
Fk:loadTranslationTable{
  ["steam__samson"] = "参孙",
  ["#steam__samson"] = "",
  ["designer:steam__samson"] = "cyc",
  ["illustrator:steam__samson"] = "矢泽秋落",
}

General:new(extension, "steam__corrupted_samson", "west", 4):addSkills { "steam__bloodthirsty", "steam__thirstyblood", "steam__rage" }
Fk:loadTranslationTable{
  ["steam__corrupted_samson"] = "堕化参孙",
  ["#steam__corrupted_samson"] = "",
  ["designer:steam__corrupted_samson"] = "cyc",
  ["illustrator:steam__corrupted_samson"] = "矢泽秋落",
}

General:new(extension, "steam__apollyon", "west", 4):addSkills{"steam__wujinxukong"}
Fk:loadTranslationTable{
  ["steam__apollyon"] = "亚玻伦",
  ["#steam__apollyon"] = "",
  ["illustrator:steam__apollyon"] = "矢泽秋落",
  ["designer:steam__apollyon"] = "cyc",
}

General:new(extension, "steam__corrupted_apollyon", "west", 4):addSkills { "steam__wudishenkeng" }
Fk:loadTranslationTable{
  ["steam__corrupted_apollyon"] = "堕化亚玻伦",
  ["#steam__corrupted_apollyon"] = "",
  ["illustrator:steam__corrupted_apollyon"] = "矢泽秋落",
  ["designer:steam__corrupted_apollyon"] = "cyc",
}

General:new(extension, "steam__magdala", "west", 3, 3, General.Female):addSkills{"steam__yonghengxinyang", "steam__shenshengxianli", "steam__shengxin"}
Fk:loadTranslationTable{
  ["steam__magdala"] = "抹大拉",
  ["#steam__magdala"] = "",
  ["designer:steam__magdala"] = "cyc",
  ["illustrator:steam__magdala"] = "矢泽秋落",
}

General:new(extension, "steam__corrupted_magdala", "west", 5, 5, General.Female):addSkills{"steam__wuxue", "steam__xunai"}
Fk:loadTranslationTable{
  ["steam__corrupted_magdala"] = "堕化抹大拉",
  ["#steam__corrupted_magdala"] = "",
  ["designer:steam__corrupted_magdala"] = "cyc",
  ["illustrator:steam__corrupted_magdala"] = "矢泽秋落",
}

General:new(extension, "steam__lazarus", "west", 4):addSkills{ "steam__ezhou", "steam__jiuen" }
Fk:loadTranslationTable{
  ["steam__lazarus"] = "拉撒路",
  ["#steam__lazarus"] = "",
  ["designer:steam__lazarus"] = "cyc",
  ["illustrator:steam__lazarus"] = "矢泽秋落",
}

General:new(extension, "steam__corrupted_lazarus", "west", 3):addSkills{"steam__shengsipaihuai", "steam__shengsinizhuan"}
Fk:loadTranslationTable{
  ["steam__corrupted_lazarus"] = "堕化拉撒路",
  ["#steam__corrupted_lazarus"] = "",
  ["designer:steam__corrupted_lazarus"] = "cyc",
  ["illustrator:steam__corrupted_lazarus"] = "矢泽秋落",
}

local corrupted_lazarus2 = General:new(extension, "steam2__corrupted_lazarus", "west", 3)
corrupted_lazarus2:addSkills{"steam__shengsipaihuai", "steam__shengsinizhuan"}
corrupted_lazarus2.total_hidden = true
Fk:loadTranslationTable{
  ["steam2__corrupted_lazarus"] = "堕化拉撒路",
}

local bethany = General:new(extension, "steam__bethany", "west", 4, 4, General.Female)
bethany:addSkill("steam__tiantangjieti")
bethany:addRelatedSkills{"steam__xufa", "steam__paiyi", "steam__xutu"}
Fk:loadTranslationTable{
  ["steam__bethany"] = "伯大尼",
  ["#steam__bethany"] = "",
  ["designer:steam__bethany"] = "cyc",
  ["illustrator:steam__bethany"] = "矢泽秋落",
}

General:new(extension, "steam__corrupted_bethany", "west", 3, 3, General.Female):addSkills{"steam__kuangxin", "rmt__xingjiang"}
Fk:loadTranslationTable{
  ["steam__corrupted_bethany"] = "堕化伯大尼",
  ["#steam__corrupted_bethany"] = "",
  ["designer:steam__corrupted_bethany"] = "cyc",
  ["illustrator:steam__corrupted_bethany"] = "矢泽秋落",
}

General:new(extension, "steam__jacobesau", "west", 4):addSkills { "steam__riyuedangkong", "steam__zhangzimingfen" }
Fk:loadTranslationTable{
  ["steam__jacobesau"] = "雅各以扫",
  ["#steam__jacobesau"] = "",
  ["designer:steam__jacobesau"] = "cyc",
  ["illustrator:steam__jacobesau"] = "矢泽秋落",
}

local jacobesau2 = General:new(extension, "steam2__jacobesau", "west", 4)
jacobesau2:addSkills { "steam__riyuedangkong", "steam__zhangzimingfen" }
jacobesau2.hidden = true
jacobesau2.total_hidden = true
Fk:loadTranslationTable{
  ["steam2__jacobesau"] = "雅各以扫", -- 皮肤
}


General:new(extension, "steam__corrupted_jacob", "west", 4):addSkills{"steam__chanhuiruzui", "steam__guhuntiesuo" }
Fk:loadTranslationTable{
  ["steam__corrupted_jacob"] = "堕化雅各",
  ["#steam__corrupted_jacob"] = "",
  ["designer:steam__corrupted_jacob"] = "cyc",
  ["illustrator:steam__corrupted_jacob"] = "矢泽秋落",
}

-- 仅用于显示武将图
local corrupted_esau = General:new(extension, "steam__corrupted_esau", "west", 4)
corrupted_esau:addSkill("steam__chanhuiruzui")
corrupted_esau.total_hidden = true
Fk:loadTranslationTable{
  ["steam__corrupted_esau"] = "堕化以扫",
  ["#steam__corrupted_esau"] = "",
  ["designer:steam__corrupted_esau"] = "cyc",
  ["illustrator:steam__corrupted_esau"] = "矢泽秋落",
}

-- 小蓝人
General:new(extension, "steam__bluebaby", "west", 4):addSkills{"steam__lale", "steam__siji", "steam__chuangshiji"}
Fk:loadTranslationTable{
  ["steam__bluebaby"] = "???",
  ["#steam__bluebaby"] = "",
  ["designer:steam__bluebaby"] = "cyc",
  ["illustrator:steam__bluebaby"] = "矢泽秋落",
}

local corrupted_bluebaby = General:new(extension, "steam__corrupted_bluebaby", "west", 4)
corrupted_bluebaby:addSkills{"steam__lale", "steam__dachangjizaozheng"}
corrupted_bluebaby:addRelatedSkill("steam__qinxin")
Fk:loadTranslationTable{
  ["steam__corrupted_bluebaby"] = "堕化???",
  ["#steam__corrupted_bluebaby"] = "",
  ["designer:steam__corrupted_bluebaby"] = "cyc",
  ["illustrator:steam__corrupted_bluebaby"] = "矢泽秋落",
}

local keeper = General:new(extension, "steam__keeper", "west", 3)
keeper:addSkills{ "steam__dixiaheishi", "steam__shangdiankaimen", "steam__jinqianwanneng" }
keeper.shield = 1
Fk:loadTranslationTable{
  ["steam__keeper"] = "店长",
  ["#steam__keeper"] = "",
  ["designer:steam__keeper"] = "cyc",
  ["illustrator:steam__keeper"] = "矢泽秋落",
}


General:new(extension, "steam__corrupted_keeper", "west", 3):addSkills{ "steam__haohuazhuangui", "steam__tandewuyan", "steam__jinqianwanyong" }
Fk:loadTranslationTable{
  ["steam__corrupted_keeper"] = "堕化店长",
  ["#steam__corrupted_keeper"] = "",
  ["designer:steam__corrupted_keeper"] = "cyc",
  ["illustrator:steam__corrupted_keeper"] = "矢泽秋落",
}

General:new(extension, "steam__thelost", "west", 1):addSkills{ "steam__shenci", "steam__yongheng", "steam__youhun" }
Fk:loadTranslationTable{
  ["steam__thelost"] = "游魂",
  ["#steam__thelost"] = "",
  ["designer:steam__thelost"] = "cyc",
  ["~steam__thelost"] = "呃啊！",
  ["illustrator:steam__thelost"] = "矢泽秋落",
}

General:new(extension, "steam__corrupted_thelost", "west", 1):addSkills{"steam__yuen", "steam__shengfu", "steam__youhun"}
Fk:loadTranslationTable{
  ["steam__corrupted_thelost"] = "堕化游魂",
  ["#steam__corrupted_thelost"] = "",
  ["designer:steam__corrupted_thelost"] = "cyc",
  ["~steam__corrupted_thelost"] = "呃啊！",
  ["illustrator:steam__corrupted_thelost"] = "矢泽秋落",
}

General:new(extension, "steam__theforgotten", "west", 3, 4):addSkills{ "steam__jianlu", "steam__lingqu" }
Fk:loadTranslationTable{
  ["steam__theforgotten"] = "遗骸",
  ["#steam__theforgotten"] = "",
  ["designer:steam__theforgotten"] = "cyc",
  ["illustrator:steam__theforgotten"] = "矢泽秋落",
}

General:new(extension, "steam__corrupted_theforgotten", "west", 4):addSkills{"steam__kuguzhongdan", "steam__mishilinghun"}
Fk:loadTranslationTable{
  ["steam__corrupted_theforgotten"] = "堕化遗骸",
  ["#steam__corrupted_theforgotten"] = "",
  ["designer:steam__corrupted_theforgotten"] = "cyc",
  ["illustrator:steam__corrupted_theforgotten"] = "矢泽秋落",
}

General:new(extension, "steam__judas", "west", 3):addSkills{ "steam__anyu", "steam__beici" }
Fk:loadTranslationTable{
  ["steam__judas"] = "犹大",
  ["#steam__judas"] = "",
  ["designer:steam__judas"] = "cyc",
  ["illustrator:steam__judas"] = "矢泽秋落",
}

General:new(extension, "steam__corrupted_judas", "west", 4):addSkills{ "steam__heianyishu", "steam__shiyingshashou" }
Fk:loadTranslationTable{
  ["steam__corrupted_judas"] = "堕化犹大",
  ["#steam__corrupted_judas"] = "",
  ["designer:steam__corrupted_judas"] = "cyc",
  ["illustrator:steam__corrupted_judas"] = "矢泽秋落",
}







return extension
