if not LiveAchiever then LiveAchiever = {} end
if not LiveAchiever.Lang then LiveAchiever.Lang = {} end

LiveAchiever.Lang.en = {
    -- HUD
    HUD_Title = "Tracked Achievements",
    HUD_Completed = "Completed",
    HUD_Crit_Default = "Criterion",
    Btn_Add_Tooltip = "Add recently updated achievements",
    History_Instruction = "Click to track:",
    
    -- Zone Guide Panel
    Zone_Panel_Title = "Zone Guide Achievements",
    Zone_Panel_Empty = "All achievements completed.",
    
    -- Chat Messages
    Chat_Update = "Update:",
    Chat_Track_Btn = "[Track this progress]",
    Chat_Progress_InProgress = "Progress: In progress",
    
    -- Status Messages
    Msg_Track_Stop = "Tracking stopped.",
    Msg_Track_Start = "Tracking started.",
    Msg_Pos_Reset = "LiveAchiever: Position reset.",
    Msg_List_Cleared = "LiveAchiever: List cleared.",
    Msg_Time_Set = "LiveAchiever: Accumulation time set to: <<1>>", 
    
    -- Settings Menu
    Settings_Section_Notify = "Notifications",
    Settings_Time_Label = "Progress accumulation time",
    Settings_Time_Tooltip = "How long progress should be summed up (e.g. +5). The counter will disappear after this time.",
    Settings_Section_Manage = "Management",
    Settings_Hide_Combat_Label = "Hide in Combat",
    Settings_Hide_Combat_Tooltip = "Automatically hide the tracker window when you enter combat.",
    
    -- Settings Sliders
    Settings_Slider_X_Label = "Horizontal Position (X)",
    Settings_Slider_X_Tooltip = "Moves the window left/right. Useful in Gamepad mode.",
    Settings_Slider_Y_Label = "Vertical Position (Y)",
    Settings_Slider_Y_Tooltip = "Moves the window up/down. Useful in Gamepad mode.",
    
    Settings_Reset_Pos = "HUD Position",
    Settings_Reset_Pos_Btn = "Reset Position",
    Settings_Clear_List = "Tracking List",
    Settings_Clear_List_Btn = "Clear All",
    
    -- Window Context Menu
    Menu_ResetPos = "Reset Position",

    -- Achievement Context Menu
    Menu_Track = "Track (LiveAchiever)",
    Menu_StopTrack = "Stop tracking (LiveAchiever)",
    
    -- Navigation / Gamepad
    Nav_Tracked = "|c00FF00[TRACKED]|r",
    Nav_History = "|cFFFF00[HISTORY]|r",
    Nav_Action_Remove = "|cFF0000(Remove)|r",
    Nav_Action_Add = "|c00FF00(Add)|r",
    Hist_Prev = "< Previous",
    Hist_Next = "Next >",
    
    -- Time Options
    Time_Opt_1 = "1. three seconds",
    Time_Opt_2 = "2. ten seconds",
    Time_Opt_3 = "3. one minute",
    Time_Opt_4 = "4. two minutes",
    Time_Opt_5 = "5. five minutes",
    Time_Opt_6 = "6. ten minutes",
    Time_Opt_7 = "7. twenty minutes",
    Time_Opt_8 = "8. thirty minutes",
    Time_Opt_9 = "9. one hour",
    Time_Opt_10 = "10. two hours",
	
	-- Positioning Mode
    Settings_Unlock_Label = "Unlock Window (Positioning)",
    Settings_Unlock_Tooltip = "Shows the tracker in menus for adjustment. IMPORTANT: Disable this after positioning to hide the window in menus again.",
	
	-- Appearance & Gamepad
    Settings_Section_Appearance = "Appearance",
    Settings_Font_Label = "Font Size",
    Settings_Font_Tooltip = "Adjust text size (Range: 6-28).",
    Settings_Alpha_Label = "Background Opacity",
    Settings_Alpha_Tooltip = "Adjust window background transparency (0% = invisible).",
    Menu_Btn_Press = "Press Right Stick",
    Menu_No_History = "(No recent updates)",
}