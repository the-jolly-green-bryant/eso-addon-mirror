if not LiveAchiever then LiveAchiever = {} end
if not LiveAchiever.Lang then LiveAchiever.Lang = {} end

LiveAchiever.Lang.tr = {
    -- HUD
    HUD_Title = "Takip Edilen Başarılar",
    HUD_Completed = "Tamamlandı",
    HUD_Crit_Default = "Kriter",
    Btn_Add_Tooltip = "Son güncellenen başarıları ekle",
    History_Instruction = "Takip etmek için tıkla:",
    
    -- Zone Guide Panel
    Zone_Panel_Title = "Bölge Rehberi Başarıları",
    Zone_Panel_Empty = "Tüm başarılar tamamlandı.",
    
    -- Chat Messages
    Chat_Update = "Güncelleme:",
    Chat_Track_Btn = "[Bu ilerlemeyi takip et]",
    Chat_Progress_InProgress = "İlerleme: Devam ediyor",
    
    -- Status Messages
    Msg_Track_Stop = "Takip durduruldu.",
    Msg_Track_Start = "Takip başlatıldı.",
    Msg_Pos_Reset = "LiveAchiever: Konum sıfırlandı.",
    Msg_List_Cleared = "LiveAchiever: Liste temizlendi.",
    Msg_Time_Set = "LiveAchiever: Biriktirme süresi ayarlandı: <<1>>", 
    
    -- Settings Menu
    Settings_Section_Notify = "Bildirimler",
    Settings_Time_Label = "İlerleme biriktirme süresi",
    Settings_Time_Tooltip = "İlerlemelerin ne kadar süre toplanacağı (örn. +5). Sayaç bu süreden sonra kaybolur.",
    Settings_Section_Manage = "Yönetim",
    Settings_Hide_Combat_Label = "Savaşta Gizle",
    Settings_Hide_Combat_Tooltip = "Savaşa girdiğinizde takip penceresini otomatik olarak gizle.",
    
    -- Settings Sliders
    Settings_Slider_X_Label = "Yatay Konum (X)",
    Settings_Slider_X_Tooltip = "Pencereyi sola/sağa taşır. Oyun Kumandası modunda kullanışlıdır.",
    Settings_Slider_Y_Label = "Dikey Konum (Y)",
    Settings_Slider_Y_Tooltip = "Pencereyi yukarı/aşağı taşır. Oyun Kumandası modunda kullanışlıdır.",
    
    Settings_Reset_Pos = "HUD Konumu",
    Settings_Reset_Pos_Btn = "Konumu Sıfırla",
    Settings_Clear_List = "Takip Listesi",
    Settings_Clear_List_Btn = "Hepsini Temizle",
    
    -- Window Context Menu
    Menu_ResetPos = "Konumu Sıfırla",

    -- Context Menu
    Menu_Track = "Takip Et (LiveAchiever)",
    Menu_StopTrack = "Takibi Bırak (LiveAchiever)",
    
    -- Navigation / Gamepad
    Nav_Tracked = "|c00FF00[TAKİPTE]|r",
    Nav_History = "|cFFFF00[GEÇMİŞ]|r",
    Nav_Action_Remove = "|cFF0000(Kaldır)|r",
    Nav_Action_Add = "|c00FF00(Ekle)|r",
    Hist_Prev = "< Önceki",
    Hist_Next = "Sonraki >",
    
    -- Time Options
    Time_Opt_1 = "1. üç saniye",
    Time_Opt_2 = "2. on saniye",
    Time_Opt_3 = "3. bir dakika",
    Time_Opt_4 = "4. iki dakika",
    Time_Opt_5 = "5. beş dakika",
    Time_Opt_6 = "6. on dakika",
    Time_Opt_7 = "7. yirmi dakika",
    Time_Opt_8 = "8. otuz dakika",
    Time_Opt_9 = "9. bir saat",
    Time_Opt_10 = "10. iki saat",
	
	-- Positioning Mode
    Settings_Unlock_Label = "Pencere Kilidini Aç (Konumlandırma)",
    Settings_Unlock_Tooltip = "Pencereyi menülerde gösterir. ÖNEMLİ: Konumlandırdıktan sonra pencerenin menülerde tekrar gizlenmesi için bunu devre dışı bırakın.",
	
	-- Görünüm & Oyun Kumandası
    Settings_Section_Appearance = "Görünüm",
    Settings_Font_Label = "Yazı Boyutu",
    Settings_Font_Tooltip = "Metin boyutunu ayarla (Aralık: 6-28).",
    Settings_Alpha_Label = "Arkaplan Opaklığı",
    Settings_Alpha_Tooltip = "Pencere arkaplan şeffaflığını ayarla (%0 = görünmez).",
    Menu_Btn_Press = "Sağ Analoga Bas",
    Menu_No_History = "(Güncelleme yok)",
}