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

return extension