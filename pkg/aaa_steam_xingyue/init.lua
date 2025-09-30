local extension = Package("aaa_steam_xingyue")
extension.extensionName = "aaa_steam"

Fk:loadTranslationTable{
  ["aaa_steam_xingyue"] = "星月赛",
}


General:new(extension, "steam__lvdai", "wu", 4):addSkills {"steam__yanke"}
Fk:loadTranslationTable{
  ["steam__lvdai"] = "吕岱",
  ["#steam__lvdai"] = "南宣国化",
  ["illustrator:steam__lvdai"] = "学徒小李",
  ["designer:steam__lvdai"] = "志文",

  ["~steam__lvdai"] = "再也不能，为吴国奉身了。",
}


return extension
