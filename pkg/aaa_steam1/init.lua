local extension = Package("aaa_steam1")
extension.extensionName = "aaa_steam"

Fk:loadTranslationTable{
  ["aaa_steam1"] = "蒸1",
}


General:new(extension, "steam__longyufei", "shu", 3, 3, General.Female):addSkills {"steam__cuiyao", "steam__zhenjue" }
Fk:loadTranslationTable{
  ["steam__longyufei"] = "龙羽飞",
  ["#steam__longyufei"] = "",
  ["designer:steam__longyufei"] = "花俏蛮娇",
  ["illustrator:steam__longyufei"] = "",
}

General:new(extension, "steam__guosi", "han", 4):addSkills{"steam__tansi"}
Fk:loadTranslationTable{
  ["steam__guosi"] = "郭汜",
  ["#steam__guosi"] = "鸷狠诡戾",
  ["designer:steam__guosi"] = "老猫",
  ["illustrator:steam__guosi"] = "秋呆呆",

  ["~steam__guosi"] = "这荣华富贵我还没享受够呢——",
}

General:new(extension, "steam__rembrandt", "west", 3):addSkills{"steam__guanganfa"}

Fk:loadTranslationTable{
  ["steam__rembrandt"] = "伦勃朗",
  ["#steam__rembrandt"] = "光影诗者",
  ["designer:steam__rembrandt"] = "Emo",
  ["illustrator:steam__rembrandt"] = "",
}

General:new(extension, "steam__yudu", "qun", 4):addSkills{"steam__qiaolve"}

Fk:loadTranslationTable{
  ["steam__yudu"] = "于毒",
  ["#steam__yudu"] = "虓据黑山",
  ["illustrator:steam__yudu"] = "MUMU",
  ["designer:steam__yudu"] = "小叶子",
  ["cv:steam__yudu"] = " ",

  ["~steam__yudu"] = " ",
}

General:new(extension, "steam__shiji", "wu", 4):addSkills{ "steam__subei", "steam__shichu" }
Fk:loadTranslationTable{
  ["steam__shiji"] = "施绩",
  ["#steam__shiji"] = "威重柱国",
  ["illustrator:steam__shiji"] = "AI",
  ["designer:steam__shiji"] = "小叶子",
}


General:new(extension, "steam__zhangyann", "qun", 4):addSkills{"steam__qingxii"}
Fk:loadTranslationTable{
  ["steam__zhangyann"] = "张燕",
  ["#steam__zhangyann"] = "苍山黄霆",
  ["illustrator:steam__zhangyann"] = "尼乐小丑",
  ["designer:steam__zhangyann"] = "老班长与鱼刺",
  ["cv:steam__zhangyann"] = "隐匿之隐匿",

  ["~steam__zhangyann"] = "爹爹半生沉浮，能给吾儿和弟兄们找个好归宿，也算没有遗憾了...",
}

General:new(extension, "steam__sunshangxiang", "shu", 3, 3, General.Female):addSkills{"steam__shijian","steam__nianqing"}
Fk:loadTranslationTable{
  ["steam__sunshangxiang"] = "孙尚香",
  ["#steam__sunshangxiang"] = "花好月圆",
  ["designer:steam__sunshangxiang"] = "辛涟月",
  ["illustrator:steam__sunshangxiang"] = "花弟",

  ["~steam__sunshangxiang"] = "片云凝不散，回看故乡愁。",
}

General:new(extension, "steam__thutmose_third", "west", 4):addSkills{ "steam__zaizhu", "steam__lvzheng" }
Fk:loadTranslationTable{
  ["steam__thutmose_third"] = "图特摩斯三世",
  ["#steam__thutmose_third"] = "荣日重光",
  ["designer:steam__thutmose_third"] = "杨林",
  ["illustrator:steam__thutmose_third"] = "",
}

General:new(extension, "steam__sheldon", "west", 3):addSkills{"steam__zhuyun", "steam__zanju"}
Fk:loadTranslationTable{
  ["steam__sheldon"] = "谢尔登", -- Sheldon Gary Adelson
  ["#steam__sheldon"] = "倾天豪掷",
  ["designer:steam__sheldon"] = "杨林",
  ["illustrator:steam__sheldon"] = "AI",
}

General:new(extension, "steam__musk", "west", 4):addSkills{"steam__lianxi", "steam__xinglian"}
Fk:loadTranslationTable{
  ["steam__musk"] = "马斯克", -- Elon Musk
  ["#steam__musk"] = "硅谷钢铁侠",
  ["illustrator:steam__musk"] = "AI",
  ["designer:steam__musk"] = "杨林",
}

General:new(extension, "steam__putin", "west", 4):addSkills{"steam__bairen", "steam__wansheng"}
Fk:loadTranslationTable{
  ["steam__putin"] = "普京",
  ["#steam__putin"] = "冬临大帝",
  ["illustrator:steam__putin"] = "AI",
  ["designer:steam__putin"] = "杨林",
  ["~steam__putin"] = "",
}

General:new(extension, "steam__kobe", "west", 4):addSkills{"steam__zhijin", "steam__yigui"}
Fk:loadTranslationTable{
  ["steam__kobe"] = "科比", -- Kobe Bryant
  ["#steam__kobe"] = "燃蟒化蛟",
  ["illustrator:steam__kobe"] = "",
  ["designer:steam__kobe"] = "杨林",
  ["~steam__kobe"] = "man，hhhhh，what can I say,mamba out.",
}

General:new(extension, "steam__jinwuzhu", "qun", 4):addSkills{"steam__futu", "steam__lugong"}
Fk:loadTranslationTable{
  ["steam__jinwuzhu"] = "金兀术",
  ["#steam__jinwuzhu"] = "赤龙郎君",
  ["designer:steam__jinwuzhu"] = "杨林",
  ["illustrator:steam__jinwuzhu"] = "",
}

General:new(extension, "steam__nobunaga", "qun", 4):addSkills{"steam__exi", "steam__buwu"}
Fk:loadTranslationTable{
  ["steam__nobunaga"] = "织田信长",
  ["#steam__nobunaga"] = "第六天魔王",
  ["designer:steam__nobunaga"] = "杨林",
  ["illustrator:steam__nobunaga"] = "信长的野望",
}

General:new(extension, "steam__nvwa", "god", 3, 3, General.Female):addSkills{"steam__bushi", "steam__zhuren"}
Fk:loadTranslationTable{
  ["steam__nvwa"] = "女娲",
  ["#steam__nvwa"] = "阴皇",
  ["designer:steam__nvwa"] = "杨林",
  ["illustrator:steam__nvwa"] = "AI",
}

General:new(extension, "steam__duji", "wei", 3):addSkills{"steam__andong", "steam__kanghui"}
Fk:loadTranslationTable{
  ["steam__duji"] = "杜畿",
  ["#steam__duji"] = "",
  ["designer:steam__duji"] = "胖即是胖",
}

General:new(extension, "steam__yuquan", "wu", 2, 5):addSkills{"steam__mianzhou", "steam__fuzhen"}
Fk:loadTranslationTable{
  ["steam__yuquan"] = "于诠",
  ["#steam__yuquan"] = "杀身成仁",
  ["illustrator:steam__yuquan"] = "",
  ["designer:steam__yuquan"] = "颜渊",
}

General:new(extension, "steam__zhangte", "wei", 4):addSkills{"steam__buzhu", "steam__zhenyu"}
Fk:loadTranslationTable{
  ["steam__zhangte"] = "张特",
  ["#steam__zhangte"] = "缓兵之策",
  ["illustrator:steam__zhangte"] = "",
  ["designer:steam__zhangte"] = "颜渊",
}

General:new(extension, "steam__tianfeng", "qun", 3):addSkills{"steam__zhengjian", "steam__quanlue"}
Fk:loadTranslationTable{
  ["steam__tianfeng"] = "田丰",
  ["#steam__tianfeng"] = "直言规劝",
  ["illustrator:steam__tianfeng"] = "",
  ["designer:steam__tianfeng"] = "颜渊",
}

General:new(extension, "steam__lusu", "wu", 3):addSkills{"steam__taolue", "steam__hezong"}
Fk:loadTranslationTable{
  ["steam__lusu"] = "鲁肃",
  ["#steam__lusu"] = "文韬武略",
  ["illustrator:steam__lusu"] = "",
  ["designer:steam__lusu"] = "颜渊＆江雪埋骨",
}

General:new(extension, "steam__zhaoqu", "wei", 4):addSkills{"steam__chixiao", "steam__henge"}
Fk:loadTranslationTable{
  ["steam__zhaoqu"] = "赵衢",
  ["#steam__zhaoqu"] = "",
  ["designer:steam__zhaoqu"] = "半城",
  ["illustrator:steam__zhaoqu"] = "2B铅笔",
}

General:new(extension, "steam__spjiangwei", "wei", 4):addSkills{ "steam__shucheng", "steam__kunshou" }
Fk:loadTranslationTable{
  ["steam__spjiangwei"] = "姜维",
  ["#steam__spjiangwei"] = "天水麒麟",
  ["designer:steam__spjiangwei"] = "长青",
  ["illustrator:steam__spjiangwei"] = "",
}

General:new(extension, "steam__elizabeth_second", "west", 3, 3, General.Female):addSkills {"steam__buluo", "steam__yinglian"}
Fk:loadTranslationTable{
  ["steam__elizabeth_second"] = "伊丽莎白二世",
  ["#steam__elizabeth_second"] = "永不退位",
  ["designer:steam__elizabeth_second"] = "emo公主",
  ["illustrator:steam__elizabeth_second"] = "AI",
}

General:new(extension, "steam__guanyinping", "shu", 3, 3, General.Female):addSkills {"steam__zhuiyue", "steam__zhuohun"}
Fk:loadTranslationTable{
  ["steam__guanyinping"] = "关银屏",
  ["#steam__guanyinping"] = "九天凰舞",
  ["illustrator:steam__guanyinping"] = "木美人",
  ["designer:steam__guanyinping"] = "末页&屑",

  ["~steam__guanyinping"] = "红已花残，此仇，未能报。",
}

General:new(extension, "steam__gaolishi", "tang", 3):addSkills{"steam__huanfua", "steam__huanfub"}
Fk:loadTranslationTable{
  ["steam__gaolishi"] = "高力士",
  ["#steam__gaolishi"] = "孤影从一",
  ["designer:steam__gaolishi"] = "Emo",
  ["illustrator:steam__gaolishi"] = "AI",
}

General:new(extension, "steam__sunyi", "wu", 5):addSkills{"steam__jiqiao", "steam__weizhong"}
Fk:loadTranslationTable{
  ["steam__sunyi"] = "孙翊",
  ["#steam__sunyi"] = "翻江龙",
  ["designer:steam__sunyi"] = "未折",
  ["illustrator:steam__sunyi"] = "",
}

General:new(extension, "steam__xunyu", "wei", 3):addSkills{"steam__kuangyi", "steam__anshu"}
Fk:loadTranslationTable{
  ["steam__xunyu"] = "荀彧",
  ["#steam__xunyu"] = "怀忠念治",
  ["designer:steam__xunyu"] = "o.O",
  ["illustrator:steam__xunyu"] = "徐子晖",

  ["~steam__xunyu"] = "大江东去，当年月照今世人。",
}

General:new(extension, "steam__xinqiji", "song", 3):addSkills{"steam__kanshishou", "steam__butianlie"}
Fk:loadTranslationTable{
  ["steam__xinqiji"] = "辛弃疾",
  ["#steam__xinqiji"] = "匣中剑鸣",
  ["illustrator:steam__xinqiji"] = "",
  ["designer:steam__xinqiji"] = "续约",
}

General:new(extension, "steamxd__chentang", "han", 4):addSkills{"steam__jiaobingg"}
Fk:loadTranslationTable{
  ["steamxd"] = "蒸",

  ["steamxd__chentang"] = "陈汤",
  ["#steamxd__chentang"] = "西极天马",
  ["illustrator:steamxd__chentang"] = "未知",
  ["designer:steamxd__chentang"] = "玄蝶既白",
  ["cv:steamxd__chentang"] = "隐匿之隐匿",

  ["~steamxd__chentang"] = "黄沙卷马蹄，催我归长安...",
}

local liubei = General:new(extension, "steam__liubei", "shu", 4)
liubei.subkingdom = "han"
liubei:addSkills{ "steam__yanren", "steam__renyan" }
Fk:loadTranslationTable{
  ["steam__liubei"] = "刘备",
  ["#steam__liubei"] = "熔裁昭日",
  ["illustrator:steam__liubei"] = "无鳏",
  ["designer:steam__liubei"] = "云雀",
  ["~steam__liubei"] = "醉泣江山君莫笑，似我刘备有几人。",
}


return extension
