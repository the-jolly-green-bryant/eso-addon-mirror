local strings = {
    SI_QUICKEMOTEMENU_UNKNOWN_NAME         = "?",
    SI_QUICKEMOTEMENU_CATEGORIES           = "分类",
    SI_QUICKEMOTEMENU_FAVORITES            = "收藏",
    SI_QUICKEMOTEMENU_NO_FAVORITES         = "(空)",
    SI_QUICKEMOTEMENU_BINDING_TOGGLE       = "切换",
    SI_QUICKEMOTEMENU_OPTION_HOVER         = "子菜单悬停延迟 (毫秒)",
    SI_QUICKEMOTEMENU_OPTION_HOVER_TOOLTIP = "0 = 仅点击时打开",
    SI_QUICKEMOTEMENU_OPTION_CLOSE         = "播放表情后关闭菜单 (左键)",
    SI_QUICKEMOTEMENU_OPTION_RESET         = "重置按钮位置",
    SI_QUICKEMOTEMENU_OPTION_DESCRIPTION   = [[|c3399FF操作|r
• 左键点击按钮打开或关闭菜单
• 右键拖动按钮移动位置
• 左键点击表情播放
• 右键点击表情添加或移除收藏

|c3399FF菜单|r
• 分类 — 按分类浏览表情
• 收藏 — 快速访问已保存表情
• 子菜单在悬停或点击时打开 (见延迟设置)
• 菜单根据按钮位置向上/下、左/右打开

|c3399FF提示|r
• 使用快捷键切换菜单
• /qempanel 打开此设置面板
• 收藏账号通用]],
}

for stringId, stringValue in pairs(strings) do
    SafeAddString(_G[stringId], stringValue, 2)
end
