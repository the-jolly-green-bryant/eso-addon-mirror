-- Translated by: FusRoDah

local Register = LibCodesCommonCode.RegisterString

Register("SI_RCR_SUBTITLE_HISTORY"        , "历史")

Register("SI_RCR_MESSAGE_TRIAL_START"     , "<<1>> 已开始; 标准完成时间为 <<2>> 分钟。（此时间为计分参考，与成就无关）")
Register("SI_RCR_MESSAGE_TRIAL_END"       , "<<1>> 最终得分为 <<2>>，剩余活力 <<3>>。 总时间是 <<4>>；比标准完成时间 <<6>> 分钟<<5>> <<7>>。 [|c00FFCC|H0:rcr|h打开历史|h|r]")
Register("SI_RCR_MESSAGE_TRIAL_END1"      , "快")
Register("SI_RCR_MESSAGE_TRIAL_END2"      , "慢")
Register("SI_RCR_MESSAGE_OBSOLETE"        , "|cFF0000警告：|r请卸载 《<<1>>》 插件。 《<<1>>》 插件已过时，它的功能已包含在Raidificator中。")

Register("SI_RCR_HEADER_TIMESTAMP"        , "日期")
Register("SI_RCR_HEADER_CHARACTER"        , "角色")
Register("SI_RCR_HEADER_SCORE"            , "分数")
Register("SI_RCR_HEADER_DURATION"         , "时长")

Register("SI_RCR_ALL_ACCOUNTS"            , "所有账户")
Register("SI_RCR_GROUP_MEMBERS"           , "队伍成员")

Register("SI_RCR_ACHIEVEMENT_CATEGORY3"   , "竞技场")

Register("SI_RCR_FILTER_HIDE_ARC_1"       , "隐藏巡回1")
Register("SI_RCR_FILTER_PLEDGES"          , "今天的无畏者誓约任务")

Register("SI_RCR_DTR_TITLE"               , "重组队伍")
Register("SI_RCR_DTR_SLASH_CONFIRM"       , "你确定要解散并重组队伍吗？")
Register("SI_RCR_DTR_DISCOVERY"           , "你可以在聊天栏使用 |c00CCFF/reformgroup|r 命令或者绑定一个自定义按键来一键解散并重组当前队伍。")
Register("SI_BINDING_NAME_RCR_REFORM"     , "Raidificator: 重组队伍")

Register("SI_RCR_KEYBIND_CONFIRM"         , "%s：为了确认，请重新发出此命令 %d 次在接下来的 %0.1f 秒内。")

Register("SI_RCR_PLEDGES"                 , "无畏者誓约任务")

Register("SI_RCR_SECTION_STATUS"          , "状态栏")
Register("SI_RCR_SETTING_BGCOLOR"         , "背景颜色")

Register("SI_RCR_SECTION_LOGGING"         , "日志记录")
Register("SI_RCR_SETTING_LOG_DUNGEON"     , "自动记录老兵地下城")
Register("SI_RCR_SETTING_LOG_TRIAL"       , "自动记录老兵试炼和竞技场")
Register("SI_RCR_SETTING_LOG_ENDLESS"     , "自动记录无尽档案塔")

Register("SI_RCR_SECTION_QUESTS"          , "加入正在进行的任务")
Register("SI_RCR_SETTING_QUESTS_DUNGEONS" , "地下城任务")
Register("SI_RCR_SETTING_QUESTS_TRIALS"   , "试炼任务")
Register("SI_RCR_SETTING_QUESTS_ARENAS"   , "竞技场和无尽档案塔任务")
Register("SI_RCR_SETTING_QUEST_ACTION0"   , "什么都不做")
Register("SI_RCR_SETTING_QUEST_ACTION1"   , "总是接受")
Register("SI_RCR_SETTING_QUEST_ACTION2"   , "总是拒绝")

Register("SI_RCR_SECTION_CASTS"           , "技能误触屏蔽")
Register("SI_RCR_SETTING_CASTS_TEXT"      , "如果启用，将会阻止释放一些仅用于获得被动 buff 的技能，此功能仅在地牢、试炼或竞技场中进行战斗时才有效。 屏蔽的技能包括：<<1>>")
