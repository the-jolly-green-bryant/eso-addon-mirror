-- Simplified Chinese Localization Strings for TorigaHUD
local strings = {
    BINDING_NAME_TORIGAHUD_TOGGLE_DRAG = "解锁/锁定 HUD 位置",
    
    TORIGAHUD_SETTINGS_DISPLAY_NAME = "|cFFD700TorigaHUD|r 设置",
    TORIGAHUD_SETTINGS_GENERAL_HEADER = "常规设置",
    TORIGAHUD_SETTINGS_HIDE_OOC = "脱战隐藏",
    TORIGAHUD_SETTINGS_HIDE_OOC_TT = "启用时，在脱离战斗且没有敌对目标时隐藏所有资源条。",
    TORIGAHUD_SETTINGS_SHOW_SHIELDS = "显示护盾",
    TORIGAHUD_SETTINGS_SHOW_SHIELDS_TT = "启用时，在生命值条上方显示半透明蓝色护盾条以指示当前护盾量。",
    TORIGAHUD_SETTINGS_LERP_SPEED = "资源条平滑动画速度",
    TORIGAHUD_SETTINGS_LERP_SPEED_TT = "调整资源条数值变化的平滑过渡速度。（1.00 = 瞬间更新，无平滑动画）",
    TORIGAHUD_SETTINGS_SEGMENT_SIZE = "单格代表数值 (生命/资源)",
    TORIGAHUD_SETTINGS_SEGMENT_SIZE_TT = "调整资源条上每个方格所代表的资源点数（生命、魔法、耐力、目标）。例如，2000 表示每个方格对应 2000 点资源。",
    TORIGAHUD_SETTINGS_SCALE = "HUD 缩放 (大小)",
    TORIGAHUD_SETTINGS_SCALE_TT = "调整所有 HUD 元素的全局大小。",
    TORIGAHUD_SETTINGS_PRESETS_HEADER = "预设与定位",
    TORIGAHUD_SETTINGS_PRESET = "布局预设",
    TORIGAHUD_SETTINGS_PRESET_TT = "选择预设布局以快速重新排列 HUD。",
    TORIGAHUD_SETTINGS_PRESET_VERTICAL = "战斗聚焦 (垂直)",
    TORIGAHUD_SETTINGS_PRESET_HORIZONTAL = "战斗聚焦 (水平)",
    TORIGAHUD_SETTINGS_PRESET_MINIMALIST = "极简 (紧凑)",
    TORIGAHUD_SETTINGS_UNLOCK = "解锁 HUD 位置",
    TORIGAHUD_SETTINGS_UNLOCK_TT = "启用此选项以解锁资源条。这会关闭设置菜单，并显示“应用/取消”对话框供您用鼠标拖动排列元素。",
    TORIGAHUD_SETTINGS_RESET = "重置默认位置",
    TORIGAHUD_SETTINGS_RESET_TT = "将所有 HUD 资源条恢复至其初始默认位置。",
    
    TORIGAHUD_DRAG_XP = "经验值",
    TORIGAHUD_DRAG_TARGET = "目标",
    
    TORIGAHUD_DIALOG_TITLE = "用鼠标拖动排列各个资源条",
    TORIGAHUD_DIALOG_APPLY = "应用",
    TORIGAHUD_DIALOG_CANCEL = "取消",
    
    TORIGAHUD_TEXT_HEALTH = "生命",
    TORIGAHUD_TEXT_LEVEL = "等级",
    TORIGAHUD_TEXT_XP = "经验值",
    TORIGAHUD_TEXT_MAGICKA = "魔法",
    TORIGAHUD_TEXT_STAMINA = "耐力",
    TORIGAHUD_TEXT_TARGET_TEST = "测试目标",
}

for stringId, stringValue in pairs(strings) do
    ZO_CreateStringId("SI_" .. stringId, stringValue)
end
