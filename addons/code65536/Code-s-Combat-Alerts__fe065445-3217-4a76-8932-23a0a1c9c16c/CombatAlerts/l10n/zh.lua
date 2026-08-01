-- Translated by: FusRoDah

local Register = LibCombatAlerts.RegisterString

Register("SI_CA_MODULE_LOAD"                    , "加载模块 [<<1>>]。")
Register("SI_CA_MODULE_UNLOAD"                  , "卸载模块 [<<1>>]。")
Register("SI_CA_CORRUPTED"                      , "|cFF0000错误:|r 您安装的战斗警报似乎已经损坏，可能是 Minion 更新错误所致。 |cFF0000请删除后重新安装插件。|r")

Register("SI_CA_PURGEABLE_EFFECTS"              , "可净化的效果")
Register("SI_CA_NEARBY"                         , "附近的玩家")
Register("SI_CA_NEARBY_EMPTY"                   , "附近没有玩家")

Register("SI_CA_SETTINGS_SUPPRESS"              , "抑制模块加载和卸载消息")
Register("SI_CA_SETTINGS_DISABLE_ANNOYING"      , "禁用烦人的基础游戏消息")
Register("SI_CA_SETTINGS_BYPASS_PURGE_CHECK"    , "始终跟踪可净化的效果")
Register("SI_CA_SETTINGS_BYPASS_PURGE_CHECK_TT" , "默认情况下，如果玩家没有装备范围驱散技能，则会禁用针对团队的可净化效果追踪；启用此选项将跳过这一要求。")
Register("SI_CA_SETTINGS_NEARBY"                , "显示附近的玩家")

Register("SI_CA_SETTINGS_MODULES"               , "模块")
Register("SI_CA_SETTINGS_MODULE_INFO"           , "区域: <<1>>\n作者: <<2>>")
Register("SI_CA_SETTINGS_MODULE_ABILITY"        , "为 “<<1>>” 启用警报")
Register("SI_CA_SETTINGS_MODULE_ABILITY_NEARBY" , "为附近 “<<1>>” 启用警报")
Register("SI_CA_SETTINGS_MODULE_RAID_LEAD"      , "启用组长模式")
Register("SI_CA_SETTINGS_MODULE_RAID_LEAD_TT"   , "为了减少不相关警报的干扰，某些警报仅对某些玩家可见。\n\n启用此模式将绕过这些限制，旨在帮助为其他玩家提供指导。")

Register("SI_CA_SETTINGS_REPOSITION"            , "重新定位 UI 元素")
Register("SI_CA_SETTINGS_MOVE_ELEMENTS"         , "重新定位元素")
Register("SI_CA_SETTINGS_MOVE_ELEMENTS_TT"      , "可以使用鼠标随时移动许多 UI 元素，而无需使用设置面板。然而，大多数 UI 元素在战斗之外都是隐藏的，这将允许您在战斗之外重新定位 UI 元素。")
Register("SI_CA_SETTINGS_RESET_ELEMENTS"        , "重置所有元素")

Register("SI_CA_MOVE_STATUS"                    , "状态面板")
Register("SI_CA_MOVE_GROUP_PANEL"               , "团队面板")
Register("SI_CA_MOVE_NEARBY"                    , "附近")

Register("SI_CA_LEGACY_HOF"                     , "《Halls of Fabrication Status Panel》 插件已停用，应卸载；它的功能已合并到此插件中。")
