local labels = {
    HG_MENU_GLOBAL_SETTINGS = "常规",
    HG_MENU_ENABLED = "启用",
    HG_MENU_DEBUG = "偵錯",
    HG_MENU_OPTIONAL_SETTINGS = "设置",
    HG_MENU_HIDE_NAMEPLATES = "隐藏名牌",
    HG_MENU_HIDE_HEALTHBARS = "隐藏生命条"
}

for key, value in pairs(labels) do
    SafeAddVersion(key, 1)
    ZO_CreateStringId(key, value)
end
