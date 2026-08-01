LibSlashCommander:AddFile("descriptions/zh.lua", 2, function(lib)
    lib.descriptions = {
        [GetString(SI_SLASH_SCRIPT)] = "执行指定的文本作为Lua代码",
        [GetString(SI_SLASH_CHATLOG)] = "切换聊天日志开/关",
        [GetString(SI_SLASH_GROUP_INVITE)] = "邀请指定名称到群组",
        [GetString(SI_SLASH_JUMP_TO_LEADER)] = "跳转到团队领袖",
        [GetString(SI_SLASH_JUMP_TO_GROUP_MEMBER)] = "跳转到指定的团队成员",
        [GetString(SI_SLASH_JUMP_TO_FRIEND)] = "跳转到指定的朋友",
        [GetString(SI_SLASH_JUMP_TO_GUILD_MEMBER)] = "跳转到指定的公会成员",
        [GetString(SI_SLASH_RELOADUI)] = "重新加载用户界面",
        [GetString(SI_SLASH_PLAYED_TIME)] = "显示在此角色上的游戏时间",
        [GetString(SI_SLASH_READY_CHECK)] = "在组中发起就绪检查",
        [GetString(SI_SLASH_DUEL_INVITE)] = "向指定玩家发起决斗",
        [GetString(SI_SLASH_LOGOUT)] = "返回到角色选择",
        [GetString(SI_SLASH_CAMP)] = "返回到角色选择",
        [GetString(SI_SLASH_QUIT)] = "关闭游戏",
        [GetString(SI_SLASH_FPS)] = "切换FPS显示",
        [GetString(SI_SLASH_LATENCY)] = "切换延迟显示",
        [GetString(SI_SLASH_STUCK)] = "打开卡住角色的帮助屏幕",
        [GetString(SI_SLASH_REPORT_BUG)] = "打开错误报告屏幕",
        [GetString(SI_SLASH_REPORT_FEEDBACK)] = "打开反馈报告屏幕",
        [GetString(SI_SLASH_REPORT_HELP)] = "打开帮助屏幕",
        [GetString(SI_SLASH_REPORT_CHAT)] = "打开报告玩家屏幕",
        [GetString(SI_SLASH_ENCOUNTER_LOG)] = "切换日志记录。'?' 显示选项",
    }

    -- 表情和聊天切换的描述在 types.lua 文件中指定
end)
