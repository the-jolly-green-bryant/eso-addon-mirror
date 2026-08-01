local strings = {
    TITLE = "Guard Warner",
    AUTHOR = "The Dung Merchant",
    VERSION = "1.4",
    WEBSITE = "https://www.esoui.com/downloads/info3590-GuardWarner.html",

    -- label texts
    SHOW_BOUNTY_TIMER_LABEL = "Show bounty time remaining",
    LARGE_SHIELD_LABEL = "Show the larger shield icon",
    KOS_WARNING_LABEL = "Show red shield when guards will attack",
    KOS_ALERT_SOUND_LABEL = "Play alert sound when guards will attack",
    BOUNTY_WARNING_LABEL = "Show yellow shield if bounty applies",
    BOUNTY_ALERT_SOUND_LABEL = "Play alert sound if bounty applies",
    UPSTANDING_WARNING_LABEL = "Show green shield icon whilst upstanding",
    UPSTANDING_ALERT_SOUND_LABEL = "Play alert sound when upstanding",
}

for stringId, stringValue in pairs(strings) do
    ZO_CreateStringId(stringId , stringValue)
    SafeAddVersion(stringId, 1)
end