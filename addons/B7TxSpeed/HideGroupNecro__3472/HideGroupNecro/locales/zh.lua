local labels = {
    HG_MENU_GLOBAL_SETTINGS = "常规",
    HG_MENU_ENABLED = "启用",
    HG_MENU_DEBUG = "偵錯",
    HG_MENU_OPTIONAL_SETTINGS = "设置",
    HG_MENU_NAMEPLATE_MODE = "显示名牌",
    HG_MENU_HEALTHBAR_MODE = "显示生命条",
    HG_MENU_CHOICE_NEVER = "从不",
    HG_MENU_CHOICE_ALWAYS = "始终",
    HG_MENU_CHOICE_INJURED = "受伤",
}

for key, value in pairs(labels) do
    SafeAddVersion(key, 1)
    ZO_CreateStringId(key, value)
end
