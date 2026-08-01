-- -----------------------------------------------------------------------------
-- Lang/zh.lua
-- -----------------------------------------------------------------------------
local strings = {
    SKILLBLOCKER_NJ_UNLOCK_ALL                         = "全部解锁",
    SKILLBLOCKER_NJ_UNLOCKED                           = "已解锁",
    SKILLBLOCKER_NJ_LOCKED                             = "已锁定",
    SKILLBLOCKER_NJ_LOCKED_COMBAT                      = "战斗中锁定",
    SKILLBLOCKER_NJ_LOCKED_ACTIVE                      = "激活时锁定",
    SKILLBLOCKER_NJ_LOADED                             = "加载成功",
    SKILLBLOCKER_NJ_LOCKED_WEREWOLF                    = "狼人形态下锁定",

    SKILLBLOCKER_NJ_BLOCK_SETTINGS                     = "锁定设置",
    SKILLBLOCKER_NJ_BLOCK_STACKS                       = "层数少于此值时锁定 <",
    SKILLBLOCKER_NJ_BLOCK_CRUX                         = "Crux少于此值时锁定 <",
    SKILLBLOCKER_NJ_BLOCK_REVERSE                      = "核心 ≥ 时阻止",
    SKILLBLOCKER_NJ_BLOCK_PROC                         = "格挡直到第 <<1>> 次触发",
    SKILLBLOCKER_NJ_BLOCK_HP                           = "目标生命值高于此值时锁定 >",
    SKILLBLOCKER_NJ_BLOCK_ULTIMATE                     = "点数低于 <<1>> 时锁定",
    SKILLBLOCKER_NJ_BLOCK_DURATION                     = "锁定 <<1>> 秒",
    SKILLBLOCKER_NJ_BLOCK_DEBUFF                       = "锁定直到第 <<1>> 次爆发",

    SKILLBLOCKER_NJ_GENERAL_SETTINGS                   = "通用设置",
    SKILLBLOCKER_NJ_REMEMBER                           = "记住锁定状态？",
    SKILLBLOCKER_NJ_SHOW_ALERT                         = "显示警告",
    SKILLBLOCKER_NJ_ALERT_TOOLTIP                      = "尝试使用被锁定的技能时显示系统警告",

    SKILLBLOCKER_NJ_DOUBLE_CAST_BLOCK_SETTINGS         = "连点保护设置",
    SKILLBLOCKER_NJ_RESET_DOUBLE_CAST_LA               = "轻攻击重置保护",
    SKILLBLOCKER_NJ_RESET_DOUBLE_CAST_LA_TOOLTIP       = "如果启用，轻攻击（左键）将立即移除连点保护。",
    SKILLBLOCKER_NJ_DOUBLE_CAST_BLOCK_DURATION         = "保护持续时间",
    SKILLBLOCKER_NJ_DOUBLE_CAST_BLOCK_DURATION_TOOLTIP = "技能使用后保持锁定状态的时间（秒）（0=∞）。",

    SKILLBLOCKER_NJ_MENU_ACTIVE_BLOCKS_TITLE           = "我的锁定技能列表：",
    SKILLBLOCKER_NJ_MAIN_BAR                           = "主栏：",
    SKILLBLOCKER_NJ_BACK_BAR                           = "副栏：",

    SKILLBLOCKER_NJ_ACTION_ENABLE                      = "启用",
    SKILLBLOCKER_NJ_ACTION_DISABLE                     = "禁用",

    SKILLBLOCKER_NJ_MENU_DOUBLE_CAST_TITLE             = "连点保护设置",
    SKILLBLOCKER_NJ_MENU_STACK_TITLE                   = "按层数锁定",
    SKILLBLOCKER_NJ_MENU_CRUX_TITLE                    = "按 Crux 锁定",
    SKILLBLOCKER_NJ_MENU_PROC_TITLE                    = "按触发 (Proc) 锁定",
    SKILLBLOCKER_NJ_MENU_DEBUFF_TITLE                  = "按技能「爆发」锁定",
    SKILLBLOCKER_NJ_MENU_ULTIMATE_TITLE                = "按终极值锁定",
    SKILLBLOCKER_NJ_MENU_DURATION_TITLE                = "按持续时间锁定",
    SKILLBLOCKER_NJ_MENU_HP_TITLE                      = "按目标生命值锁定",
    SKILLBLOCKER_NJ_MENU_CRIMINAL_TITLE                = "锁定「犯罪行为」",

    SKILLBLOCKER_NJ_DELETE_FROM_SLOT                   = "從槽位刪除",

    SI_BINDING_NAME_SKILLBLOCKER_NJ_UNLOCK_ALL         = "解锁所有技能",
    SI_BINDING_NAME_SKILLBLOCKER_NJ_TOGGLE_SLOT_1      = "切换锁定：栏位 1",
    SI_BINDING_NAME_SKILLBLOCKER_NJ_TOGGLE_SLOT_2      = "切换锁定：栏位 2",
    SI_BINDING_NAME_SKILLBLOCKER_NJ_TOGGLE_SLOT_3      = "切换锁定：栏位 3",
    SI_BINDING_NAME_SKILLBLOCKER_NJ_TOGGLE_SLOT_4      = "切换锁定：栏位 4",
    SI_BINDING_NAME_SKILLBLOCKER_NJ_TOGGLE_SLOT_5      = "切换锁定：栏位 5",
    SI_BINDING_NAME_SKILLBLOCKER_NJ_TOGGLE_SLOT_6      = "切换锁定：终极技能",
}

for stringId, stringValue in pairs(strings) do
    SafeAddString(_G[stringId], stringValue, 2)
end