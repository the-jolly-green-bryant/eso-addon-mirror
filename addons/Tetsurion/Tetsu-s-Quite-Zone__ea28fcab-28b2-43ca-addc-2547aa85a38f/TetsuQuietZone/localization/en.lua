TetsuQuietZone = TetsuQuietZone or {}

TetsuQuietZone.L = {
    TITLE = "|cFFD700Tetsu's|r Quiet Zone",

    INFO_LABEL = "Info",
    INFO_TT = "Hides zone and say lines that contain a guild hyperlink. Can also mute chat of selected guilds you are in. Does not block the official guild-invite popup.\nGold / bugs: mail @Tetsurion.",

    ADS_SECTION = "Mute guild ads",
    ADS_SECTION_TT = "Hide recruit walls in zone / say / yell when the line has a guild hyperlink.",

    ENABLED = "Enable ad filter",
    ENABLED_TT = "Master switch for zone/say/yell ads. On = lines with a guild link never appear in your chat window.",

    FILTER_ZONE = "Filter zone chat",
    FILTER_ZONE_TT = "All zone channels, including language zones (область / zone / Zone / …). Default on.",

    FILTER_SAY = "Filter say chat",
    FILTER_SAY_TT = "Local /say. Default on.",

    FILTER_YELL = "Filter yell chat",
    FILTER_YELL_TT = "Off by default. Turn on if recruit walls also go to yell.",

    GUILD_SECTION = "Mute guild chat",
    GUILD_SECTION_TT = "Each toggle is one guild you belong to. On = hide that guild's messages. Other guilds stay. Saved by guild id, not slot. Default off.",
    GUILD_HINT = "ON - hide messages from this guild",
    GUILD_HINT_TT = "On = hide all messages from that guild's /g and /o. Other guilds, zone and say stay.",
    GUILD_EMPTY = "<<1>>. (empty slot)",
    MUTE_GUILD_TT = "On = hide messages from this guild only. Other guilds, zone and say stay.",

    HIDDEN_LABEL = "Hidden this session: <<1>>",
    HIDDEN_TT = "How many lines were skipped since login (ads + muted guilds). Resets on ReloadUI.",
}
