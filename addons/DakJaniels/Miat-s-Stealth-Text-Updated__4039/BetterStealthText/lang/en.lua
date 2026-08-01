local strings =
{
    BETTERSTEALTHTEXT_INVISIBLE = "Invisible",
    BETTERSTEALTHTEXT_REVEALED = "Revealed",
    BETTERSTEALTHTEXT_HIDING = "Hiding",
    -- Addon menu and option strings
    BETTERSTEALTHTEXT_ADDON_NAME = "Miat's Stealth Text",
    BETTERSTEALTHTEXT_ADDON_OPTIONS = "Miat's Stealth Text options",
    BETTERSTEALTHTEXT_ADDON_ENABLED = "ADDON ENABLED",
    BETTERSTEALTHTEXT_ADDON_ENABLED_TOOLTIP = "ON - enabled, OFF - disabled",
    BETTERSTEALTHTEXT_ACCOUNTWIDE = "Same settings for all characters",
    BETTERSTEALTHTEXT_ACCOUNTWIDE_TOOLTIP = "ON - Each character has the same set of settings, OFF - Separate settings for each character",
    BETTERSTEALTHTEXT_ACCOUNTWIDE_WARNING = "Triggering this options with reload the UI",
    BETTERSTEALTHTEXT_DISPLAY_OPTIONS = "Display options",
    BETTERSTEALTHTEXT_SCALE = "Set stealth text scale (%)",
    BETTERSTEALTHTEXT_SCALE_TOOLTIP = "Icon and text scale goes from 50% to 400% of original scale",
    BETTERSTEALTHTEXT_STEALTH_COLORS_OPTIONS = "Stealth colors options",
    BETTERSTEALTHTEXT_SAME_HIDDEN_INVISIBLE = "Same color for HIDDEN and INVISIBLE stealth states",
    BETTERSTEALTHTEXT_SAME_HIDDEN_INVISIBLE_TOOLTIP = "ON - enabled (HIDDEN color applies to INVISIBLE), OFF - disabled (separate settings for HIDDEN and INVISIBLE)",
    BETTERSTEALTHTEXT_HIDDEN_COLOR = "Pick color for HIDDEN state",
    BETTERSTEALTHTEXT_HIDDEN_COLOR_TOOLTIP = "Pick color of text for HIDDEN stealth state",
    BETTERSTEALTHTEXT_INVISIBLE_COLOR = "Pick color for INVISIBLE state",
    BETTERSTEALTHTEXT_INVISIBLE_COLOR_TOOLTIP = "Pick color of text for INVISIBLE stealth state",
    BETTERSTEALTHTEXT_SAME_ALMOST_HIDDEN_INVISIBLE = "Same color for HIDDEN and INVISIBLE almost detected stealth states",
    BETTERSTEALTHTEXT_SAME_ALMOST_HIDDEN_INVISIBLE_TOOLTIP = "ON - enabled (HIDDEN color applies to INVISIBLE) for almost detected states, OFF - disabled (separate settings for HIDDEN and INVISIBLE) for almost detected states",
    BETTERSTEALTHTEXT_HIDDEN_ALMOST_COLOR = "Pick color for HIDDEN ALMOST DETECTED state",
    BETTERSTEALTHTEXT_HIDDEN_ALMOST_COLOR_TOOLTIP = "Pick color of text for HIDDEN ALMOST DETECTED stealth state",
    BETTERSTEALTHTEXT_INVISIBLE_ALMOST_COLOR = "Pick color for INVISIBLE ALMOST DETECTED state",
    BETTERSTEALTHTEXT_INVISIBLE_ALMOST_COLOR_TOOLTIP = "Pick color of text for INVISIBLE ALMOST DETECTED stealth state",
    BETTERSTEALTHTEXT_ENABLE_HIDING = "Enable 'HIDING' text",
    BETTERSTEALTHTEXT_ENABLE_HIDING_TOOLTIP = "ON - enabled, OFF - disabled",
    BETTERSTEALTHTEXT_HIDING_COLOR = "Pick color for HIDING state",
    BETTERSTEALTHTEXT_HIDING_COLOR_TOOLTIP = "Pick color of text for HIDING stealth state",
    BETTERSTEALTHTEXT_DETECTED_COLOR = "Pick color for DETECTED state",
    BETTERSTEALTHTEXT_DETECTED_COLOR_TOOLTIP = "Pick color of text for DETECTED stealth state",
    BETTERSTEALTHTEXT_REVEALED_COLOR = "Pick color for REVEALED state",
    BETTERSTEALTHTEXT_REVEALED_COLOR_TOOLTIP = "Pick color of text for REVEALED stealth state",
    BETTERSTEALTHTEXT_DISGUISE_COLORS_OPTIONS = "Disguise colors options",
    BETTERSTEALTHTEXT_DISGUISED_COLOR = "Pick color for DISGUISED state",
    BETTERSTEALTHTEXT_DISGUISED_COLOR_TOOLTIP = "Pick color of text for DISGUISED disguise state",
    BETTERSTEALTHTEXT_SUSPICIOUS_COLOR = "Pick color for SUSPICIOUS state",
    BETTERSTEALTHTEXT_SUSPICIOUS_COLOR_TOOLTIP = "Pick color of text for SUSPICIOUS disguise state",
    BETTERSTEALTHTEXT_DANGER_COLOR = "Pick color for DANGER state",
    BETTERSTEALTHTEXT_DANGER_COLOR_TOOLTIP = "Pick color of text for DANGER disguise state",
    BETTERSTEALTHTEXT_DISCOVERED_COLOR = "Pick color for DISCOVERED state",
    BETTERSTEALTHTEXT_DISCOVERED_COLOR_TOOLTIP = "Pick color of text for DISCOVERED disguise state"
}

for stringId, stringValue in pairs(strings) do
    ZO_CreateStringId(stringId, stringValue)
    SafeAddVersion(stringId, 1)
end
