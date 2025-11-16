local extension = Package("aaa_steam_minshe")
extension.extensionName = "aaa_steam"

Fk:loadTranslationTable{
  ["aaa_steam_minshe"] = "官服民间设计师作品",
  ["steamMinshe"] = "蒸",
}

local wenyuan = General:new(extension, "steamMinshe__wenyuan", "wei", 4, 4, General.Male)--
wenyuan:addSkills { "steamMinshe__lvli", "steamMinshe__beishui" }
wenyuan:addRelatedSkills{ "steamMinshe__qingjiao" }
Fk:loadTranslationTable{
  ["steamMinshe__wenyuan"] = "文鸯",
  ["#steamMinshe__wenyuan"] = "万人亦往",
  ["designer:steamMinshe__wenyuan"] = "快雪时晴",
  ["illustrator:steamMinshe__wenyuan"] = "Thinking",

  ["~steamMinshe__wenyuan"] = "痛贯心膂，天灭大魏啊！",
}

General:new(extension, "steamMinshe__caoxiu", "wei", 4, 4, General.Male):addSkills { "steamMinshe__qingxi", "steamMinshe__qianju" }
Fk:loadTranslationTable{
  ["steamMinshe__caoxiu"] = "曹休",
  ["#steamMinshe__caoxiu"] = "千里骐骥",
  ["designer:steamMinshe__caoxiu"] = "长妤眠",
  ["illustrator:steamMinshe__caoxiu"] = "Roc",

  ["~steamMinshe__caoxiu"] = "兵行险招，终有一失。",
}

return extension