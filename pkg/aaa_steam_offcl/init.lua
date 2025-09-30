local extension = Package("aaa_steam_offcl")
extension.extensionName = "aaa_steam"

Fk:loadTranslationTable{
  ["aaa_steam_offcl"] = "官改",
  ["steammou"] = "蒸谋",
}

-- 官改征集第一期
General:new(extension, "steam__liuba", "shu", 3):addSkills {"steam__duanbi", "steam__tongdu" }
Fk:loadTranslationTable{
  ["steam__liuba"] = "刘巴",
  ["#steam__liuba"] = "撰科行律",
  ["designer:steam__liuba"] = "胖即是胖",
  ["~steam__liuba"] = "",
}

-- 官改征集第一期
local peixiu = General:new(extension, "steam__peixiu", "jin", 3)
peixiu:addSkills { "steam__xingtu", "steam__jinlan" }
peixiu.subkingdom = "qun"
Fk:loadTranslationTable{
  ["steam__peixiu"] = "裴秀",
  ["#steam__peixiu"] = "晋国开秘",
  ["designer:steam__peixiu"] = "猫",
  ["illustrator:steam__peixiu"] = "鬼画府",
}

-- 官改征集第一期
General:new(extension, "steam__caosong", "wei", 3):addSkills{"steam__yijin", "steam__guanzong"}
Fk:loadTranslationTable{
  ["steam__caosong"] = "曹嵩",
  ["#steam__caosong"] = "富有亿金",
  ["designer:steam__caosong"] = "胖即是胖",
  ["illustrator:steam__caosong"] = "",
  ["~steam__caosong"] = "",
}


General:new(extension, "steam__liuyan", "qun", 3):addSkills{"steam__tushe", "steam__limu"}
Fk:loadTranslationTable{
  ["steam__liuyan"] = "刘焉",
  ["#steam__liuyan"] = "裂土之宗",
  ["cv:steam__liuyan"] = "金垚",
  ["designer:steam__liuyan"] = "桃花僧",
  ["illustrator:steam__liuyan"] = "明暗交界", -- 传说皮 雄踞益州

  ["~steam__liuyan"] = "我怎会有图谋不轨之心？",
}

General:new(extension, "steam__godxunyu", "god", 3):addSkills{"steam__tianzuo", "steam__lingce", "steam__dinghan"}
Fk:loadTranslationTable{
  ["steam__godxunyu"] = "神荀彧",
  ["#steam__godxunyu"] = "洞心先识",
  ["cv:steam__godxunyu"] = "",
  ["designer:steam__godxunyu"] = "先帝",
  ["illustrator:steam__godxunyu"] = "JJGG",

  ["~steam__godxunyu"] = "宁鸣而死，不默而生……",
}




return extension
