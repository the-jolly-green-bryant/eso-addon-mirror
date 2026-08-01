Verditer = Verditer or {}

-- Keybinding label shown in ESO Controls settings
ZO_CreateStringId("SI_BINDING_NAME_VERDITER_TOGGLE", "Toggle Verditer Window")

-- Status strings
ZO_CreateStringId("VERDITER_BUFFER_CLEARED", "Buffers cleared.")
ZO_CreateStringId("VERDITER_LOADED",         "Verditer v%s loaded. Type %s to toggle.")

-- Settings panel
ZO_CreateStringId("VERDITER_SETTINGS_TITLE",         "Verditer Settings")
ZO_CreateStringId("VERDITER_SETTINGS_RESET",         "Reset to Defaults")
ZO_CreateStringId("VERDITER_SETTING_SAMPLE_RATE",    "Sampling Rate")
ZO_CreateStringId("VERDITER_SETTING_TIME_WINDOW",    "Time Window")
ZO_CreateStringId("VERDITER_SETTING_VIEWPORT_ALPHA", "Viewport Alpha")
ZO_CreateStringId("VERDITER_SETTINGS_LOGO_ON",       "Logo: Visible")
ZO_CreateStringId("VERDITER_SETTINGS_LOGO_OFF",      "Logo: Hidden")
ZO_CreateStringId("VERDITER_SETTINGS_RECAP_ON",      "Death Recap: On")
ZO_CreateStringId("VERDITER_SETTINGS_RECAP_OFF",     "Death Recap: Off")
ZO_CreateStringId("VERDITER_LOGO_HINT",              "Logo hidden. Bind a key to Verditer under Settings > Controls > Keybindings (Add-Ons), or type /verditer.")

-- Heavy buffer warning (in chat) — args: window_s, hz, capacity.
ZO_CreateStringId("VERDITER_WARN_HEAVY_BUFFER", "%ds x %d Hz = %d samples may impact FPS. Consider a lower sample rate for long windows.")

-- Help command output
ZO_CreateStringId("VERDITER_HELP_HEADER",  "Verditer commands:")
ZO_CreateStringId("VERDITER_HELP_GRAPH",   "  /verditer         toggle the incoming-damage analytics window")
ZO_CreateStringId("VERDITER_HELP_HELP",    "  /verditer help    show this list")

-- Graph window
ZO_CreateStringId("VERDITER_GRAPH_TITLE",   "Incoming Analysis")
ZO_CreateStringId("VERDITER_GRAPH_RECORD",  "Record")
ZO_CreateStringId("VERDITER_GRAPH_STOP",    "Stop")
ZO_CreateStringId("VERDITER_GRAPH_FLUSH",   "Flush")
ZO_CreateStringId("VERDITER_GRAPH_NO_DATA", "No data — press Record while taking damage.")

-- Title-bar icon-button tooltips
ZO_CreateStringId("VERDITER_TT_DEATHS",   "Deaths — browse this session's death recaps")
ZO_CreateStringId("VERDITER_TT_EXPORT",   "Export the recorded session to CSV")
ZO_CreateStringId("VERDITER_TT_SETTINGS", "Settings")
ZO_CreateStringId("VERDITER_TT_ITP",      "Incoming Pressure — damage + shielded, per second")
ZO_CreateStringId("VERDITER_TT_MIT",      "Effective mitigation — % of incoming damage your shield ate")

-- Slider tooltips: the title names them, so these explain what they DO / the trade-off.
ZO_CreateStringId("VERDITER_TT_SAMPLE",   "How much detail the chart shows")
ZO_CreateStringId("VERDITER_TT_TWINDOW",  "How far back the chart remembers")
ZO_CreateStringId("VERDITER_TT_VPALPHA",  "How dark the chart's background is")

-- Death Recap: the celeste vertical line in the lead-up film.
ZO_CreateStringId("VERDITER_TT_SHIELD_BREAK", "Shield broke here — damage hit your HP directly after this")
ZO_CreateStringId("VERDITER_TT_PEAK",         "Peak incoming damage — highest DTPS in this window")

-- Death Recap window (BACKLOG C)
ZO_CreateStringId("VERDITER_RECAP_TITLE",       "Death Recap")
ZO_CreateStringId("VERDITER_RECAP_DIED",        "YOU DIED")
ZO_CreateStringId("VERDITER_RECAP_FINAL_BLOWS", "FINAL BLOWS")
ZO_CreateStringId("VERDITER_RECAP_LEAD_UP",     "HP")
ZO_CreateStringId("VERDITER_RECAP_BREAKDOWN",   "DAMAGE BY TYPE")
ZO_CreateStringId("VERDITER_RECAP_FROM",        "from")
ZO_CreateStringId("VERDITER_RECAP_FROM_ENV",    "from the environment")
ZO_CreateStringId("VERDITER_RECAP_UNKNOWN",     "Unknown")
ZO_CreateStringId("VERDITER_RECAP_KB",          "KB")
ZO_CreateStringId("VERDITER_RECAP_OVERKILL",    "%d%% overkill")
ZO_CreateStringId("VERDITER_RECAP_PRESSURE",    "peak %s DTPS  ·  %d attackers  ·  %s ABS eaten  ·  %d%% mitigated")
ZO_CreateStringId("VERDITER_RECAP_EXPORT",      "Export")
ZO_CreateStringId("VERDITER_RECAP_AGO_SEC",     "%ds ago")
ZO_CreateStringId("VERDITER_RECAP_AGO_MIN",     "%dm %ds ago")
