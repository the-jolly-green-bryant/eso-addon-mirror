local strings = {
    SI_HAA_PANEL_NAME               = "Heavy Attack Alerter",
    SI_HAA_COMBAT_ONLY_NAME         = "Show only in combat",
    SI_HAA_COMBAT_ONLY_TIP          = "Hides the shield icon while out of combat.",
    SI_HAA_SOUND_NAME               = "Alert Sound",
    SI_HAA_SOUND_TIP                = "Sound played when an enemy starts a heavy attack.",
    SI_HAA_SOUND_CHAMPION           = "Chime (Champion Points)",
    SI_HAA_SOUND_DUEL               = "Duel (Duel Start)",
    SI_HAA_SOUND_QUEST              = "Victory (Quest Completed)",
    SI_HAA_SOUND_NONE               = "No Sound",
    SI_HAA_ALPHA_NAME               = "Safe Shield Opacity (%)",
    SI_HAA_ALPHA_TIP                = "Opacity of the green shield in normal state.",
    SI_HAA_ALERT_ALPHA_NAME         = "Alert Shield Opacity (%)",
    SI_HAA_ALERT_ALPHA_TIP          = "Opacity of the red shield during heavy attack warnings.",
    SI_HAA_SIZE_NAME                = "Icon Size (px)",
    SI_HAA_OFFSET_X_NAME            = "Horizontal Offset (X)",
    SI_HAA_OFFSET_Y_NAME            = "Vertical Offset (Y)",
    SI_HAA_TEST_BUTTON_NAME         = "Test Alert",
    SI_HAA_TEST_BUTTON_TIP          = "Triggers a 1.5-second test alert with sound to preview your settings.",
}

for stringId, stringValue in pairs(strings) do
    ZO_CreateStringId(stringId, stringValue)
    SafeAddVersion(stringId, 1)
end