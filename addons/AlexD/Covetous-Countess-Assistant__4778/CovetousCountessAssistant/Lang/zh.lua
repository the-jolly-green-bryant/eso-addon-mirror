local strings = {
    SI_COVETOUSCOUNTESSASSISTANT_OPTION_TRACK_COUNTESS
        = "追踪贪婪女伯爵",
    SI_COVETOUSCOUNTESSASSISTANT_OPTION_TRACK_COUNTESS_TOOLTIP
        = "标记可用于贪婪女伯爵寻宝的宝物。",
    SI_COVETOUSCOUNTESSASSISTANT_OPTION_TRACK_CROW
        = "追踪贡品司库",
    SI_COVETOUSCOUNTESSASSISTANT_OPTION_TRACK_CROW_TOOLTIP
        = "标记可用于贡品司库（乌鸦）寻宝的宝物。",
    SI_COVETOUSCOUNTESSASSISTANT_OPTION_SETTINGS
        = "设置",
    SI_COVETOUSCOUNTESSASSISTANT_MSG_COUNTESS_ON
        = "贪婪女伯爵追踪：开",
    SI_COVETOUSCOUNTESSASSISTANT_MSG_COUNTESS_OFF
        = "贪婪女伯爵追踪：关",
    SI_COVETOUSCOUNTESSASSISTANT_MSG_CROW_ON
        = "贡品司库追踪：开",
    SI_COVETOUSCOUNTESSASSISTANT_MSG_CROW_OFF
        = "贡品司库追踪：关",
}

for stringId, stringValue in pairs(strings) do
    SafeAddString(_G[stringId], stringValue, 2)
end
