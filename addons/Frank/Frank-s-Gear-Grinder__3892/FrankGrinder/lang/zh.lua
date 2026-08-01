local strings = {

    -----------
    -- Menu
    GG_MENU_LE_HEADER = "线索过期提醒",
    GG_MENU_LE_DESC = "当玩家切换区域时会触发提醒。将在设定天数内即将过期的线索会触发提醒。显示提醒后，将在设定的间隔时间内暂停再次提醒。",
    GG_MENU_LE_ENABLED = "启用",
    GG_MENU_LE_ENABLED_TT = "启用线索过期提醒？",
    GG_MENU_LE_ANNOUNCE_REMINDERS = "屏幕提醒",
    GG_MENU_LE_ANNOUNCE_REMINDERS_TT = "在屏幕上显示线索过期提醒？",
    GG_MENU_LE_CHAT_REMINDERS = "聊天窗口提醒",
    GG_MENU_LE_CHAT_REMINDERS_TT = "在聊天窗口显示提醒？",
    GG_MENU_LE_WARNING_PERIOD = "提醒提前天数（1–20 天）",
    GG_MENU_LE_WARNING_PERIOD_TT = "在线索过期前多少天开始提醒。",
    GG_MENU_LE_NO_WARNING_PERIOD = "无提醒间隔（分钟）[1–120]",
    GG_MENU_LE_NO_WARNING_PERIOD_TT = "提醒之间的秒数间隔。",
    GG_MENU_GF_HEADER = "组队查找通知",
    GG_MENU_GF_ENABLED = "启用",
    GG_MENU_GF_ENABLED_TT = "在聊天窗口启用组队查找通知？",
    GG_MENU_GF_CHECK_INTERVAL = "组队查找检查间隔（秒）[5–60]",
    GG_MENU_GF_CHECK_INTERVAL_TT = "检查组队查找中新的试炼招募的秒数间隔。最小 5 秒，最大 60 秒。",
    GG_MENU_GF_TRIAL_HEADER = "需要通知的试炼（组队查找）",
    GG_MENU_GF_TRIAL_DESC = "请注意：使用“任意试炼”选项创建的招募也会包含在通知中。",
    GG_MENU_GF_TRIAL_TT = "是否包含 %s 的组队查找招募？",
    GG_MENU_PA_HEADER = "Personal Assistant 集成",
    GG_MENU_PA_DESC = "需求:\n- 插件: LibCharacterKnowledge、LibPrice（并启用价格来源，如 TamrielTradeCentre、Master Merchant 或 Arkadius' Trade Tools）\n- 为商人角色设置专用的 Personal Assistant LOOT 配置文件，以防止多余物品和待售物品在从银行取出时被自动学习。\n\n分配规则:\n1. 工匠未学习的物品 → 发送给工匠\n2. 低价值物品根据 LibCharacterKnowledge 发送给下一个角色\n3. 多余及高价值物品发送给商人（若启用），否则保留在银行。",
    GG_MENU_PA_ENABLED = "启用？",
    GG_MENU_PA_ENABLED_TT = "是否启用 Personal Assistant 覆盖？禁用需要重新加载界面。",
    GG_MENU_PA_SALE_VALUE_THRESHOLD = "出售价值阈值",
    GG_MENU_PA_SALE_VALUE_THRESHOLD_TT = "出售价值低于或等于此阈值的物品将被视为低价值。",
    GG_MENU_PA_CRAFTER_CHARACTER_NAME = "工匠角色名称",
    GG_MENU_PA_CRAFTER_CHARACTER_NAME_TT = "作为工匠的角色名称。",
    GG_MENU_PA_TRADER_CHARACTER_NAME = "商人角色名称",
    GG_MENU_PA_TRADER_CHARACTER_NAME_TT = "作为商人的角色名称。",
    GG_MENU_PA_WITHDRAW_TO_TRADER_ENABLED = "提取至商人？",
    GG_MENU_PA_WITHDRAW_TO_TRADER_ENABLED_TT = "将多余物品从银行提取给商人。",

    -----------
    -- core
    GG_LAM_NOT_FOUND = "未找到 LibAddonMenu2，无法创建菜单。",
    GG_CHARACTERS = "角色",
    GG_SHOW_WINDOW = "显示窗口",
    GG_TOGGLE_LOCATION_TRACKER = "切换位置变更追踪器",
    GG_REMAINING = " 剩余",
    GG_ELAPSED = " 已过",

    -----------
    -- Lead Expiry
    GG_LE_NEW_LEAD = "未发现/新的线索",
    GG_LE_LEAD = "线索",
    GG_LE_LORE_LEAD = "未完成的图鉴/传说线索",
    GG_LE_EXPIRY_IN = " 将在 ",
    GG_LE_EXPIRING_IN = "线索将在 ",
    GG_LE_FOUND_IN = " 发现于 ",
    GG_LE_UNKNOWN_NAME = "未知线索",
    GG_LE_UNKNOWN_ZONE = "未知区域",
    GG_LE_REMIND = "提醒",
    GG_LE_IGNORE = "忽略",
    GG_LE_DISABLE_REMINDER = "禁用提醒",
    GG_LE_ENABLE_REMINDER = "启用提醒",
    GG_LE_TOGGLE_REMINDER = "切换提醒",
    
    -----------
    -- Group Finder
    GG_GF_NEW_LISTING = "新的列表",
    GG_GF_UPDATED_LISTING = "更新的列表",
    GG_GF_REMOVED_LISTING = "已移除的列表",
    GG_GF_NO_LISTING = "组队查找器：|cff0000未找到任何列表。|r 找到后将通知。",

    -----------
    -- Location Change
    GG_LOCATION_CHANGED = "位置已更改",
    GG_LOCATION_ENABLED = "位置变更追踪器已启用",
    GG_LOCATION_DISABLED = "位置变更追踪器已禁用",

    -----------
    -- Night Market
    GG_NM_MENU_ELMS_GUIDANCE_HEADER = "夜市任务目标指引",
    GG_NM_MENU_BLUE_MARKERS = "蓝色标记表示可能的任务起始位置。",
    GG_NM_MENU_GREEN_MARKERS = "绿色标记表示可能的任务目标位置。",
    GG_NM_MENU_NOTE_ON_ELMS = "注意：必须安装并启用 ElmsMarkers 才会显示这些标记。",
    GG_NM_MENU_QUEST_LIST_HDR = "数字对应以下任务。",
    GG_NM_MENU_HIDE_TRACKER = "隐藏阵营得分追踪器",
    GG_NM_MENU_HIDE_TRACKER_TT = "隐藏屏幕上的夜市场阵营得分。",
    GG_NM_MENU_ELMS_ENABLE = "启用 ElmsMarkers 标记注入？",
    GG_NM_MENU_ELMS_ENABLE_TT = "为夜市场任务向 ElmsMarkers 添加 3D 标记。",
    GG_NM_GROUP_AUTO = "Argent 组队自动化",
    GG_NM_GROUP_AUTO_OFF = "关闭",
    GG_NM_GROUP_AUTO_ON = "开启",
    GG_NM_GROUP_AUTO_ERROR_NOTINZONE = "不在活动区域",
    GG_NM_GROUP_AUTO_ERROR_ZONENOTACTIVE = "活动区域未开启",
    GG_NM_GROUP_AUTO_ERROR_FAILEDTWICE = "组队查找创建失败两次",
    GG_NM_GROUP_AUTO_ALLDONE = "已获得所有钥匙",
    GG_NM_GROUP_AUTO_LISTINGREMOVED = "列表已移除",
    GG_NM_GROUP_AUTO_QUESTSHARE1 = "已分享",
    GG_NM_GROUP_AUTO_QUESTSHARE2 = "个任务给队伍。",
    GG_NM_GROUP_AUTOMATION_KEYBIND = "切换 Argent 组队自动化",

    -----------
    -- Time
    GG_TIME_SECONDS = "秒",
    GG_TIME_MINUTES = "分钟",
    GG_TIME_HOURS = "小时",
    GG_TIME_DAYS = "天",
    GG_TIME_NONE = "无",

}

for id, val in pairs(strings) do
   ZO_CreateStringId(id, val)
   SafeAddVersion(id, 1)
end