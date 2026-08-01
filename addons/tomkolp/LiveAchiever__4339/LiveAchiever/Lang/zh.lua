if not LiveAchiever then LiveAchiever = {} end
if not LiveAchiever.Lang then LiveAchiever.Lang = {} end

LiveAchiever.Lang.zh = {
    -- HUD
    HUD_Title = "追踪的成就",
    HUD_Completed = "已完成",
    HUD_Crit_Default = "标准",
    Btn_Add_Tooltip = "添加最近更新的成就",
    History_Instruction = "点击追踪:",
    
    -- Zone Guide Panel
    Zone_Panel_Title = "区域指南成就",
    Zone_Panel_Empty = "所有成就已完成。",
    
    -- Chat Messages
    Chat_Update = "更新：",
    Chat_Track_Btn = "[追踪此进度]",
    Chat_Progress_InProgress = "进度：进行中",
    
    -- Status Messages
    Msg_Track_Stop = "停止追踪。",
    Msg_Track_Start = "开始追踪。",
    Msg_Pos_Reset = "LiveAchiever：位置已重置。",
    Msg_List_Cleared = "LiveAchiever：列表已清空。",
    Msg_Time_Set = "LiveAchiever：累计时间设置为：<<1>>", 
    
    -- Settings Menu
    Settings_Section_Notify = "通知",
    Settings_Time_Label = "进度累计时间",
    Settings_Time_Tooltip = "进度应该累计多长时间（例如 +5）。计数器将在此时后消失。",
    Settings_Section_Manage = "管理",
    Settings_Hide_Combat_Label = "战斗中隐藏",
    Settings_Hide_Combat_Tooltip = "进入战斗时自动隐藏追踪窗口。",
    
    -- Settings Sliders
    Settings_Slider_X_Label = "水平位置 (X)",
    Settings_Slider_X_Tooltip = "向左/向右移动窗口。在手柄模式下很有用。",
    Settings_Slider_Y_Label = "垂直位置 (Y)",
    Settings_Slider_Y_Tooltip = "向上/向下移动窗口。在手柄模式下很有用。",
    
    Settings_Reset_Pos = "HUD 位置",
    Settings_Reset_Pos_Btn = "重置位置",
    Settings_Clear_List = "追踪列表",
    Settings_Clear_List_Btn = "全部清除",
    
    -- Window Context Menu
    Menu_ResetPos = "重置位置",

    -- Context Menu
    Menu_Track = "追踪 (LiveAchiever)",
    Menu_StopTrack = "停止追踪 (LiveAchiever)",
    
    -- Navigation / Gamepad
    Nav_Tracked = "|c00FF00[已追踪]|r",
    Nav_History = "|cFFFF00[历史]|r",
    Nav_Action_Remove = "|cFF0000(移除)|r",
    Nav_Action_Add = "|c00FF00(添加)|r",
    Hist_Prev = "< 上一个",
    Hist_Next = "下一个 >",
    
    -- Time Options
    Time_Opt_1 = "1. 三秒",
    Time_Opt_2 = "2. 十秒",
    Time_Opt_3 = "3. 一分钟",
    Time_Opt_4 = "4. 两分钟",
    Time_Opt_5 = "5. 五分钟",
    Time_Opt_6 = "6. 十分钟",
    Time_Opt_7 = "7. 二十分钟",
    Time_Opt_8 = "8. 三十分钟",
    Time_Opt_9 = "9. 一小时",
    Time_Opt_10 = "10. 两小时",
	
	-- Positioning Mode
    Settings_Unlock_Label = "解锁窗口 (位置调整)",
    Settings_Unlock_Tooltip = "在菜单中显示窗口。重要提示：调整位置后请禁用此选项，以便在菜单中再次隐藏窗口。",
	
	-- 外观 & 手柄
    Settings_Section_Appearance = "外观",
    Settings_Font_Label = "字体大小",
    Settings_Font_Tooltip = "调整文字大小 (范围: 6-28)。",
    Settings_Alpha_Label = "背景不透明度",
    Settings_Alpha_Tooltip = "调整窗口背景透明度 (0% = 不可见)。",
    Menu_Btn_Press = "按下右摇杆",
    Menu_No_History = "(无更新)",
}