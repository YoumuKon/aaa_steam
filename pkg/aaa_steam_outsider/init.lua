local extension = Package("aaa_steam_outsider")
extension.extensionName = "aaa_steam"

Fk:loadTranslationTable{
  ["aaa_steam_outsider"] = "外来蒸",
}

General:new(extension, "aaa_steam_outsider__caoxiu", "wei", 4, 4, General.Male):addSkills { "aaa_steam_outsider__qingxi", "aaa_steam_outsider__qianju" }
Fk:loadTranslationTable{
  ["aaa_steam_outsider__caoxiu"] = "曹休",
  ["#aaa_steam_outsider__caoxiu"] = "千里骐骥",
  ["designer:aaa_steam_outsider__caoxiu"] = "长妤眠",
  ["illustrator:aaa_steam_outsider__caoxiu"] = "Roc",

  ["~aaa_steam_outsider__caoxiu"] = "兵行险招，终有一失。",
}

return extension
