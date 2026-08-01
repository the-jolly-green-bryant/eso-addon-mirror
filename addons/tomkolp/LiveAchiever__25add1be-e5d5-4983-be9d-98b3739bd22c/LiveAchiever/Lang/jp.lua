if not LiveAchiever then LiveAchiever = {} end
if not LiveAchiever.Lang then LiveAchiever.Lang = {} end

LiveAchiever.Lang.jp = {
    -- HUD
    HUD_Title = "追跡中の実績",
    HUD_Completed = "完了",
    HUD_Crit_Default = "条件",
    Btn_Add_Tooltip = "最近更新された実績を追加",
    History_Instruction = "クリックして追跡:",
    
    -- Zone Guide Panel
    Zone_Panel_Title = "ゾーンガイドの実績",
    Zone_Panel_Empty = "全ての実績を完了しました。",
    
    -- Chat Messages
    Chat_Update = "更新:",
    Chat_Track_Btn = "[追跡する]",
    Chat_Progress_InProgress = "進行状況: 進行中",
    
    -- Status Messages
    Msg_Track_Stop = "追跡を停止しました。",
    Msg_Track_Start = "追跡を開始しました。",
    Msg_Pos_Reset = "LiveAchiever: 位置をリセットしました。",
    Msg_List_Cleared = "LiveAchiever: リストをクリアしました。",
    Msg_Time_Set = "LiveAchiever: 累積時間を設定: <<1>>", 
    
    -- Settings Menu
    Settings_Section_Notify = "通知",
    Settings_Time_Label = "進行状況の累積時間",
    Settings_Time_Tooltip = "進行状況を合算して表示する時間（例：+5）。この時間が経過するとカウンターは消えます。",
    Settings_Section_Manage = "管理",
    Settings_Hide_Combat_Label = "戦闘中は非表示",
    Settings_Hide_Combat_Tooltip = "戦闘に入ると自動的に追跡ウィンドウを非表示にします。",
    
    -- Settings Sliders
    Settings_Slider_X_Label = "水平位置 (X)",
    Settings_Slider_X_Tooltip = "ウィンドウを左右に移動します。ゲームパッドモードで便利です。",
    Settings_Slider_Y_Label = "垂直位置 (Y)",
    Settings_Slider_Y_Tooltip = "ウィンドウを上下に移動します。ゲームパッドモードで便利です。",
    
    Settings_Reset_Pos = "HUDの位置",
    Settings_Reset_Pos_Btn = "位置をリセット",
    Settings_Clear_List = "追跡リスト",
    Settings_Clear_List_Btn = "すべてクリア",
    
    -- Window Context Menu
    Menu_ResetPos = "位置をリセット",

    -- Context Menu
    Menu_Track = "追跡 (LiveAchiever)",
    Menu_StopTrack = "追跡停止 (LiveAchiever)",
    
    -- Navigation / Gamepad
    Nav_Tracked = "|c00FF00[追跡中]|r",
    Nav_History = "|cFFFF00[履歴]|r",
    Nav_Action_Remove = "|cFF0000(削除)|r",
    Nav_Action_Add = "|c00FF00(追加)|r",
    Hist_Prev = "< 前へ",
    Hist_Next = "次へ >",
    
    -- Time Options
    Time_Opt_1 = "1. 3秒",
    Time_Opt_2 = "2. 10秒",
    Time_Opt_3 = "3. 1分",
    Time_Opt_4 = "4. 2分",
    Time_Opt_5 = "5. 5分",
    Time_Opt_6 = "6. 10分",
    Time_Opt_7 = "7. 20分",
    Time_Opt_8 = "8. 30分",
    Time_Opt_9 = "9. 1時間",
    Time_Opt_10 = "10. 2時間",
	
	-- Positioning Mode
    Settings_Unlock_Label = "ウィンドウのロック解除 (位置調整)",
    Settings_Unlock_Tooltip = "メニュー内でウィンドウを表示します。重要: 位置調整後はこのオプションを無効にして、メニュー内でウィンドウを再び非表示にしてください。",
	
	-- 外観 & ゲームパッド
    Settings_Section_Appearance = "外観",
    Settings_Font_Label = "フォントサイズ",
    Settings_Font_Tooltip = "テキストサイズを調整 (範囲: 6-28)。",
    Settings_Alpha_Label = "背景の不透明度",
    Settings_Alpha_Tooltip = "ウィンドウ背景の透明度を調整 (0% = 不可視)。",
    Menu_Btn_Press = "右スティックを押す",
    Menu_No_History = "(更新なし)",
}