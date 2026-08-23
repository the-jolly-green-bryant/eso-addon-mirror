local strings = {
    SI_QUICKEMOTEMENU_UNKNOWN_NAME          = "?",
    SI_QUICKEMOTEMENU_CATEGORIES            = "Kategoriler",
    SI_QUICKEMOTEMENU_FAVORITES             = "Favoriler",
    SI_QUICKEMOTEMENU_NO_FAVORITES          = "(boş)",
    SI_QUICKEMOTEMENU_BINDING_TOGGLE        = "Aç/Kapat",
    SI_QUICKEMOTEMENU_OPTION_HOVER          = "Alt menü fare gecikmesi (ms)",
    SI_QUICKEMOTEMENU_OPTION_HOVER_TOOLTIP  = "0 = yalnızca tıklayınca aç",
    SI_QUICKEMOTEMENU_OPTION_UIMODE         = "Düğmeyi yalnızca UI modunda göster",
    SI_QUICKEMOTEMENU_OPTION_UIMODE_TOOLTIP =
    "Ana düğmeyi yalnızca fare imleci etkinken (UI modu) gösterir. Normal oyun/etkileşim moduna döndüğünüzde gizlenir.",
    SI_QUICKEMOTEMENU_OPTION_DETACH         = "Düğmeyi sohbetten ayır",
    SI_QUICKEMOTEMENU_OPTION_DETACH_TOOLTIP = "Düğmeyi sohbet penceresinin dışına taşır. Düğme serbestçe sürüklenebilir.",
    SI_QUICKEMOTEMENU_OPTION_SETTINGS       = "Ayarlar",
    SI_QUICKEMOTEMENU_OPTION_ATTACH_BUTTON  = "Düğmeyi sabitle",
    SI_QUICKEMOTEMENU_OPTION_DETACH_BUTTON  = "Düğmeyi ayır",
    SI_QUICKEMOTEMENU_OPTION_SHOW_PANEL     = "Ayar panelini göster",
    SI_QUICKEMOTEMENU_OPTION_CLOSE          = "Emote sonrası menüyü kapat (sol tık)",
    SI_QUICKEMOTEMENU_OPTION_RESET          = "Düğme konumunu sıfırla",
    SI_QUICKEMOTEMENU_OPTION_CHAT_BUTTON_OFFSET_X         = "Sohbet Düğmesi X Kaydırması",
    SI_QUICKEMOTEMENU_OPTION_CHAT_BUTTON_OFFSET_X_TOOLTIP = "Düğmenin sohbet penceresi seçenekleri düğmesine göre yatay kaydırması. Yalnızca düğme sohbet penceresine bağlı olduğunda geçerlidir.",
    SI_QUICKEMOTEMENU_OPTION_DESCRIPTION    = [[
|c3399FFÖZELLİKLER|r
• Kategoriler ve favoriler ile emotelere hızlı erişim
• Kategoriler ve emote'lar doğrudan oyun verilerinden yüklenir
• Oyuna eklenen yeni emote'lar otomatik olarak listede görünür

|c3399FFKONTROLLER|r
• Düğmeye sol tıkla menüyü aç veya kapat
• Sağ tıkla ve sürükle düğmeyi taşı
• Emote'a sol tıkla oynat
• Emote'a sağ tıkla Favorilere ekle veya çıkar

|c3399FFMENÜLER|r
• Kategoriler — emote'ları kategoriye göre gez
• Favoriler — kayıtlı emote'lara hızlı erişim
• Alt menüler fareyle veya tıklayınca açılır (gecikmeye bak)
• Menüler düğme konumuna göre üst/alt ve sol/sağ açılır

|c3399FFİPUÇLARI|r
• Menüyü aç/kapat için tuş atamasını kullan
• /qempanel bu ayar panelini açar
• Favoriler hesap genelinde kaydedilir
]],
}

for stringId, stringValue in pairs(strings) do
    SafeAddString(_G[stringId], stringValue, 2)
end
