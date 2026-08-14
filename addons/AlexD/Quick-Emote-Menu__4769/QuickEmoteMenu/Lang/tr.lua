local strings = {
    SI_QUICKEMOTEMENU_UNKNOWN_NAME         = "?",
    SI_QUICKEMOTEMENU_CATEGORIES           = "Kategoriler",
    SI_QUICKEMOTEMENU_FAVORITES            = "Favoriler",
    SI_QUICKEMOTEMENU_NO_FAVORITES         = "(boş)",
    SI_QUICKEMOTEMENU_BINDING_TOGGLE       = "Aç/Kapat",
    SI_QUICKEMOTEMENU_OPTION_HOVER         = "Alt menü fare gecikmesi (ms)",
    SI_QUICKEMOTEMENU_OPTION_HOVER_TOOLTIP = "0 = yalnızca tıklayınca aç",
    SI_QUICKEMOTEMENU_OPTION_CLOSE         = "Emote sonrası menüyü kapat (sol tık)",
    SI_QUICKEMOTEMENU_OPTION_RESET         = "Düğme konumunu sıfırla",
    SI_QUICKEMOTEMENU_OPTION_DESCRIPTION   = [[|c3399FFKONTROLLER|r
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
• Favoriler hesap genelinde kaydedilir]],
}

for stringId, stringValue in pairs(strings) do
    SafeAddString(_G[stringId], stringValue, 2)
end
