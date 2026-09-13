local strings = {
    SI_PBSSMS_SCENE_FAILED = "Screenshot mode could not open: %s",
    SI_PBSSMS_BOTH_FAILED = "Could not hide the interface: %s",
    SI_PBSSMS_FELL_BACK = "Using UI hiding instead of screenshot mode: %s",
    SI_PBSSMS_TURNED_ON = "Enabled. Hold L2, then press D-pad Left.",
    SI_PBSSMS_TURNED_OFF = "Disabled.",
    SI_PBSSMS_MODE_SET = "Mode: %s",
    SI_PBSSMS_ERROR_MODE = "Use /pbshot mode auto, scene, or gui.",
    SI_PBSSMS_RESET = "Settings reset.",
    SI_PBSSMS_ERROR_UNKNOWN = "Unknown command: %s. Use /pbshot help.",
    SI_PBSSMS_HELP_HEADER = "Hold L2, then press D-pad Left on the gamepad HUD.",
    SI_PBSSMS_HELP_STATUS = "/pbshot status — show status",
    SI_PBSSMS_HELP_NOW = "/pbshot now — try screenshot mode; repeat to restore fallback UI",
    SI_PBSSMS_HELP_MODE = "/pbshot mode auto|scene|gui — select mode",
    SI_PBSSMS_HELP_BINDS = "/pbshot binds — show inherited bindings",
    SI_PBSSMS_HELP_MASTER = "/pbshot on|off — enable/disable",
    SI_PBSSMS_HELP_RESET = "/pbshot reset — restore defaults",
}
for id, value in pairs(strings) do ZO_CreateStringId(id, value) end
