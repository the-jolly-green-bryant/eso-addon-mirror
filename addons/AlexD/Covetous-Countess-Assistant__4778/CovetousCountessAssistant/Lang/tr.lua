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
}

for stringId, stringValue in pairs(strings) do
    SafeAddString(_G[stringId], stringValue, 2)
end
