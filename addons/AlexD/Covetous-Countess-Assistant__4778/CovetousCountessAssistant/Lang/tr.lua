local strings = {
    SI_COVETOUSCOUNTESSASSISTANT_OPTION_TRACK_COUNTESS
        = "Açgözlü Kontesi Takip Et",
    SI_COVETOUSCOUNTESSASSISTANT_OPTION_TRACK_COUNTESS_TOOLTIP
        = "Açgözlü Kontes avları için kullanılabilir hazineleri işaretle.",
    SI_COVETOUSCOUNTESSASSISTANT_OPTION_TRACK_CROW
        = "Harçlar Hazinedarını Takip Et",
    SI_COVETOUSCOUNTESSASSISTANT_OPTION_TRACK_CROW_TOOLTIP
        = "Harçlar Hazinedarı (Karga) avları için kullanılabilir hazineleri işaretle.",
    SI_COVETOUSCOUNTESSASSISTANT_OPTION_SETTINGS
        = "Ayarlar",
    SI_COVETOUSCOUNTESSASSISTANT_MSG_COUNTESS_ON
        = "Açgözlü Kontes takibi: AÇIK",
    SI_COVETOUSCOUNTESSASSISTANT_MSG_COUNTESS_OFF
        = "Açgözlü Kontes takibi: KAPALI",
    SI_COVETOUSCOUNTESSASSISTANT_MSG_CROW_ON
        = "Harçlar Hazinedarı takibi: AÇIK",
    SI_COVETOUSCOUNTESSASSISTANT_MSG_CROW_OFF
        = "Harçlar Hazinedarı takibi: KAPALI",
    SI_COVETOUSCOUNTESSASSISTANT_OPTION_HIGHLIGHT_QUEST_ITEMS
        = "Görev eşyası eşleşmelerini vurgula",
    SI_COVETOUSCOUNTESSASSISTANT_OPTION_HIGHLIGHT_QUEST_ITEMS_TOOLTIP
        = "Eşyalar etkin görevin etiketleriyle eşleştiğinde simgelerini yeşil gösterir.",
    SI_COVETOUSCOUNTESSASSISTANT_MSG_HIGHLIGHT_ON
        = "Görev eşyası vurgulama: AÇIK",
    SI_COVETOUSCOUNTESSASSISTANT_MSG_HIGHLIGHT_OFF
        = "Görev eşyası vurgulama: KAPALI",
    SI_COVETOUSCOUNTESSASSISTANT_OPTION_AUTOSKIP_TIPBOARD
        = "İpucu Panosu tekliflerini otomatik atla",
    SI_COVETOUSCOUNTESSASSISTANT_OPTION_AUTOSKIP_TIPBOARD_TOOLTIP
        = "Açgözlü Kontes olmayan İpucu Panosu tekliflerini otomatik olarak kapatır.",
    SI_COVETOUSCOUNTESSASSISTANT_OPTION_AUTOSKIP_TIPBOARD_WARNING
        = "Bu, Kontes olmayan diyalogları otomatik olarak kapatacaktır.",
    SI_COVETOUSCOUNTESSASSISTANT_MSG_AUTOSKIP_ON
        = "İpucu Panosu otomatik atlama: AÇIK",
    SI_COVETOUSCOUNTESSASSISTANT_MSG_AUTOSKIP_OFF
        = "İpucu Panosu otomatik atlama: KAPALI",
}

for stringId, stringValue in pairs(strings) do
    SafeAddString(_G[stringId], stringValue, 2)
end
