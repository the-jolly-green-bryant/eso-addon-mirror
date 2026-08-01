-- Translated by: FusRoDah

local Register = LibCodesCommonCode.RegisterString

Register("SI_LCK_SCAN_START"                , "扫描物品表；仅在主要游戏更新时执行一次")
Register("SI_LCK_SCAN_COMPLETE"             , "扫描完成.")

Register("SI_LCK_SETTINGS_CHATCOMMAND"      , "插件设置面板也可以通过|c00CCFF/lck|r 聊天栏命令打开.")

Register("SI_LCK_SETTINGS_SERVER"           , "服务器")

Register("SI_LCK_SETTINGS_USE_DEFAULT"      , "默认")

Register("SI_LCK_SETTINGS_TRACKING1"        , "不追踪")
Register("SI_LCK_SETTINGS_TRACKING2"        , "追踪低品质")
Register("SI_LCK_SETTINGS_TRACKING3"        , "追踪中品质")
Register("SI_LCK_SETTINGS_TRACKING4"        , "追踪所有")

Register("SI_LCK_SETTINGS_PRIORITY"         , "优先级")
Register("SI_LCK_SETTINGS_PRIORITY_HELP"    , "所有角色共享优先级; 同优先级角色按照资历排序,较早的角色犹豫新角色.")

Register("SI_LCK_SETTINGS_EXPORT"           , "选择导出")

Register("SI_LCK_SETTINGS_MAIN_SECTION"     , "追踪和优先级")
Register("SI_LCK_SETTINGS_RANKING_PREVIEW"  , "当前角色排名顺序")
Register("SI_LCK_SETTINGS_SYSTEM_DEFAULTS"  , "这些系统范围的默认设置将适用于每个角色，除非在服务器、账户或角色级别被覆盖:")
Register("SI_LCK_SETTINGS_SERVER_DEFAULTS"  , "这些服务器范围的默认设置将适用于该服务器上的每个角色，除非在账户或角色级别被覆盖:")
Register("SI_LCK_SETTINGS_ACCOUNT_DEFAULTS" , "这些账户范围的默认设置将适用于属于该账户的每个角色，除非在角色级别被覆盖:")

Register("SI_LCK_SETTINGS_SHARE_SECTION"    , "数据分享")
Register("SI_LCK_SETTINGS_SHARE_CAPTION"    , "导出和复制或者粘贴和导入以共享数据")
Register("SI_LCK_SETTINGS_SHARE_EXPORTC"    , "导出当前")
Register("SI_LCK_SETTINGS_SHARE_EXPORTCT"   , "导出当前角色的知识数据")
Register("SI_LCK_SETTINGS_SHARE_EXPORTA"    , "导出所有")
Register("SI_LCK_SETTINGS_SHARE_EXPORTAT"   , "导出每个启用角色的知识数据")
Register("SI_LCK_SETTINGS_SHARE_EXPORTS"    , "导出选择的 (%d)")
Register("SI_LCK_SETTINGS_SHARE_EXPORTST"   , "导出启用了 \"导出选择选项\" 的角色的知识数据")
Register("SI_LCK_SETTINGS_SHARE_IMPORT"     , "导入")
Register("SI_LCK_SETTINGS_SHARE_CLEAR"      , "清楚")

Register("SI_LCK_SETTINGS_RESET_SECTION"    , "重置数据")
Register("SI_LCK_SETTINGS_RESET_WARNING"    , "这将重置所有设置，删除与 LibCharacterKnowledge 关联的所有数据，并重新加载 UI.")

Register("SI_LCK_SETTINGS_NOSAVE_SECTION"   , "排除账户")
Register("SI_LCK_SETTINGS_NOSAVE_CAPTION"   , "不保存的账户名称列表，以逗号分隔")

Register("SI_LCK_SHARE_EXPORT_LIMIT"        , "已跳过 [<<1>>/<<2>>]; 已达到数据限制.")
Register("SI_LCK_SHARE_IMPORT_STALE"        , "已跳过 [<<1>>/<<2>>]; 当前数据较新.")
Register("SI_LCK_SHARE_IMPORT_API"          , "已跳过 [<<1>>/<<2>>]; 导入的数据是由不同版本的游戏产生的.")
Register("SI_LCK_SHARE_IMPORT_DONE"         , "已导入 [<<1>>/<<2>>]. (<<3>>)")
Register("SI_LCK_SHARE_IMPORT_INVALID"      , "中止导入；遇到损坏的数据.")
Register("SI_LCK_SHARE_IMPORT_BADVERSION"   , "导入的数据由不兼容版本的 LibCharacterKnowledge 编码；请确保两个用户都已更新到 LibCharacterKnowledge 的最新版本.")
Register("SI_LCK_SHARE_IMPORT_NEWCHARACTER" , "您导入了数据库中以前不存在的一个或多个新角色; 使用|c00CCFF/reloadui|r 重载界面，新添加的角色可能将出现在菜单和设置中.")
Register("SI_LCK_SHARE_IMPORT_TALLY"        , "<<1>> 角色已导入.")
