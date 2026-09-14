TetsuQuietZone = TetsuQuietZone or {}
local L = TetsuQuietZone.L
if not L then return end

L.TITLE = "|cFFD700Tetsu's|r Quiet Zone"

L.INFO_LABEL = "说明"
L.INFO_TT = "隐藏带有公会超链接的区域和 say 消息。也可静音你所选所属公会的聊天。不拦截官方邀请弹窗。\n金币／反馈：邮件 @Tetsurion。"

L.ADS_SECTION = "静音公会广告"
L.ADS_SECTION_TT = "隐藏区域／say／yell 中带公会链接的招募墙。"

L.ENABLED = "启用广告过滤"
L.ENABLED_TT = "区域／say／yell 广告总开关。开启后，带公会链接的行不会出现在你的聊天窗口。"

L.FILTER_ZONE = "过滤区域聊天"
L.FILTER_ZONE_TT = "所有区域频道，含各语言分区。默认开。"

L.FILTER_SAY = "过滤 say"
L.FILTER_SAY_TT = "附近 say。默认开。"

L.FILTER_YELL = "过滤 yell"
L.FILTER_YELL_TT = "默认关。广告也打 yell 时再开。"

L.GUILD_SECTION = "静音公会聊天"
L.GUILD_SECTION_TT = "每个开关对应一个你所在的公会。开＝隐藏该公会的消息。其他公会不变。按公会 id 保存。默认关。"
L.GUILD_HINT = "开 - 隐藏该公会的消息"
L.GUILD_HINT_TT = "开＝隐藏该公会 /g 和 /o 的全部消息。其他公会、区域和 say 不变。"
L.GUILD_EMPTY = "<<1>>.（空槽）"
L.MUTE_GUILD_TT = "开＝只隐藏这个公会的消息。不改其他公会、区域或 say。"

L.HIDDEN_LABEL = "本会话已隐藏：<<1>>"
L.HIDDEN_TT = "本次登录跳过的行数（广告 + 已静音公会）。ReloadUI 后清零。"
