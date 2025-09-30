local extension = Package("aaa_steam_miao")
extension.extensionName = "aaa_steam"

Fk:loadTranslationTable{
  ["aaa_steam_miao"] = "动物朋友", -- 理塘妙妙屋
}



General:new(extension, "steam__rommel", "west", 4):addSkills{"steam__jijin", "steam__qisheng"}
Fk:loadTranslationTable{
  ["steam__rommel"] = "隆美尔",-- Erwin Rommel
  ["#steam__rommel"] = "帝国之鹰",
  ["cv:steam__rommel"] = "",
  ["designer:steam__rommel"] = "妙啊",
  ["illustrator:steam__rommel"] = "坦克世界",
}

General:new(extension, "steam__manstein", "west", 3):addSkills{"steam__shanji", "steam__tuique", "steam__juantu"}
Fk:loadTranslationTable{
  ["steam__manstein"] = "曼施坦因",-- Erich von Manstein
  ["#steam__manstein"] = "失去的胜利",
  ["cv:steam__manstein"] = "易大剧",
  ["designer:steam__manstein"] = "妙啊",
  ["illustrator:steam__manstein"] = "坦克世界",
  ["~steam__manstein"] = "Der Feldmarschall von Preußen kapituliert nie.（普鲁士的陆军元帅决不投降！）",
}

General:new(extension, "steam__goebbels", "west", 3):addSkills{ "steam__xinsheng", "steam__zijue" }
Fk:loadTranslationTable{
  ["steam__goebbels"] = "戈培尔",-- Paul Joseph Goebbels
  ["#steam__goebbels"] = "纵横捭阖",
  ["cv:steam__marshall"] = "",
  ["designer:steam__goebbels"] = "妙啊",
  ["illustrator:steam__goebbels"] = "AI",
}

General:new(extension, "steam__marshall", "west", 3):addSkills {"steam__dengta", "steam__yange"}
Fk:loadTranslationTable{
  ["steam__marshall"] = "马歇尔",-- George Catlett Marshall
  ["#steam__marshall"] = "纵横捭阖",
  ["cv:steam__marshall"] = "",
  ["designer:steam__marshall"] = "妙啊",
  ["illustrator:steam__marshall"] = "坦克世界",
  ["~steam__marshall"] = "We have walked blindly, ignoring the lessons of the past",
}

General:new(extension, "steam__stalin", "west", 4):addSkills{"steam__yizhii", "steam__bizheng"}
Fk:loadTranslationTable{
  ["steam__stalin"] = "斯大林",-- Joseph Vissarionovich Stalin
  ["#steam__stalin"] = "钢铁",
  ["cv:steam__stalin"] = "",
  ["designer:steam__stalin"] = "妙啊",
  ["illustrator:steam__stalin"] = "克里姆林宫",
}

local gaohuan = General:new(extension, "steam__gaohuan", "qi", 4)
gaohuan:addSkill("steam__daozu")
Fk:loadTranslationTable{
  ["steam__gaohuan"] = "高欢",
  ["#steam__gaohuan"] = "不辞履虎",
  ["designer:steam__gaohuan"] = "妙啊",
  ["illustrator:steam__gaohuan"] = "AI",
  ["cv:steam__gaohuan"] = "Kazami",

  ["~steam__gaohuan"] = "六镇扰乱，百姓愁怨，无复聊生…",
  ["!steam__gaohuan"] = "盖天意人心，好生恶杀，吉凶报应，盖有由焉。",
}

General:new(extension, "steam__wuzixu", "wu", 4):addSkills{ "steam__nixing", "steam__liehen" }
Fk:loadTranslationTable{
  ["steam__wuzixu"] = "伍子胥",
  ["#steam__wuzixu"] = "日暮途远",
  ["designer:steam__wuzixu"] = "妙啊",
  ["illustrator:steam__wuzixu"] = "AI",
  ["cv:steam__wuzixu"] = "妙啊",
  ["~steam__wuzixu"] = "此生沉抱，将悬何方？",
}

General:new(extension, "steam__zhuwen", "wei", 4):addSkills {"steam__zhali", "steam__panfu"}
Fk:loadTranslationTable{
  ["steam__zhuwen"] = "朱温",
  ["#steam__zhuwen"] = "颈血且搵",
  ["designer:steam__zhuwen"] = "妙啊",
  ["illustrator:steam__zhuwen"] = "皇帝养成计划",
  ["cv:steam__zhuwen"] = "妙啊",

  ["~steam__zhuwen"] = "世间哪有子杀父、弟杀兄之理！",
  ["!steam__zhuwen"] = "天下非一人之天下，须非刘、李祖宗所传！",
}

General:new(extension, "steam__wangmang", "newdyn", 4):addSkills{ "steam__fugu", "steam__geding", "steam__wangdao" }
Fk:loadTranslationTable{
  ["steam__wangmang"] = "王莽",
  ["#steam__wangmang"] = "先圣之治世",
  ["designer:steam__wangmang"] = "妙啊",
  ["illustrator:steam__wangmang"] = "三国杀",
}

General:new(extension, "steam__huangchao", "qi", 4):addSkills {"steam__qiufeng", "steam__chongtian"}
Fk:loadTranslationTable{
  ["steam__huangchao"] = "黄巢",
  ["#steam__huangchao"] = "青帝不第",
  ["designer:steam__huangchao"] = "妙啊",
  ["illustrator:steam__huangchao"] = "AI",
  ["cv:steam__huangchao"] = "妙啊",

  ["~steam__huangchao"] = "若取吾首献天子，可得富贵，毋与他人。",
}



return extension
