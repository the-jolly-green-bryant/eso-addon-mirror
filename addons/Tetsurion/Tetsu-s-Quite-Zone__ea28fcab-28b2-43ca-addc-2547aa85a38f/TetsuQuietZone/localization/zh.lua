TetsuQuietZone = TetsuQuietZone or {}
local L = TetsuQuietZone.L
if not L then return end

L.TITLE = "|cFFD700Tetsu's|r Quiet Zone"

L.INFO_LABEL = "说明"
L.INFO_TT = "隐藏带有公会超链接的区域和 say 消息。其他聊天不变。不拦截官方邀请弹窗。\n金币／反馈：邮件 @Tetsurion。"

L.ENABLED = "隐藏公会广告"
L.ENABLED_TT = "总开关。开启后，带公会链接的区域／say 不会出现在你的聊天窗口。"

L.FILTER_ZONE = "过滤区域聊天"
L.FILTER_ZONE_TT = "所有区域频道，含各语言分区。默认开。"

L.FILTER_SAY = "过滤 say"
L.FILTER_SAY_TT = "附近 say。默认开。"

L.FILTER_YELL = "过滤 yell"
L.FILTER_YELL_TT = "默认关。广告也打 yell 时再开。"

L.HIDDEN_LABEL = "本会话已隐藏"
L.HIDDEN_TT = "本次登录跳过的行数。ReloadUI 后清零。"
