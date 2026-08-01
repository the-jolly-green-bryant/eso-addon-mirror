-- Dynamic Encounters : localization
-- Runtime language selection; English is the fallback for any missing key.

DynamicEncounters = DynamicEncounters or {}
local HE = DynamicEncounters

local en = {
    PANEL_TITLE          = "Dynamic Encounters +",
    STATUS_LIVE          = "LIVE NOW",
    STATUS_LIVE_FOR      = "live <<1>>",           -- <<1>> = elapsed time
    STATUS_EXPECTED      = "next ~<<1>>",          -- <<1>> = countdown
    STATUS_OVERDUE       = "due any moment",
    STATUS_COOLDOWN      = "ended <<1>> ago",
    STATUS_UNKNOWN       = "no data - visit zone",
    STATUS_STALE         = "last seen <<1>> ago",
    STEP_TIME_LEFT       = "<<1>> left",           -- step expiry countdown
    CONFIDENCE           = "est. from <<1>> cycle(s)",
    CONFIDENCE_LEARNING  = "learning...",
    ARRIVE_EARLY         = "arrive a few min early",
    YOU_ARE_HERE         = "(you are here)",
    ALERT_LIVE           = "Dynamic Encounter underway!",
    ALERT_LIVE_SUB       = "<<1>> has begun in <<2>>",
    ALERT_SOON           = "Dynamic Encounter expected soon",
    ALERT_SOON_SUB       = "<<1>> in <<2>> (estimated)",
    CHAT_PREFIX          = "|c66CCFF[Dynamic Encounters]|r ",
    CHAT_LIVE            = "<<1>> is LIVE in <<2>>!",
    CHAT_ENDED           = "<<1>> in <<2>> has ended. Next expected in ~<<3>>.",
    CHAT_SOON            = "<<1>> in <<2>> expected in ~<<3>> (estimate).",
    SET_HOVER_TOOLTIPS    = "Show hover tooltips",
    SET_HOVER_TOOLTIPS_TIP = "Show help text when hovering over HUD buttons",
    CMD_HELP             = "Commands: /denc toggle | lock | unlock | reset | resetpos | scan | status | log | debug",
    CMD_STATUS_HEADER    = "Status by zone:",
    CMD_RESET_DONE       = "Panel position and learned timings reset for this server.",
    CMD_RESET_POS        = "Panel position reset.",
    SET_RESET_POSITION   = "Reset Panel Position",
    SET_RESET_POSITION_TIP = "Moves the panel back to its default location. Keeps learned timings.",
    CMD_SCAN_DONE        = "Rescanned world events in the current zone.",
    NOTE_INSTANCE        = "Note: shards (zone instances) can run different clocks; estimates apply to what this client has observed.",
    DISCLAIMER           = "Learned estimates, not official timers.",

    -- Settings
    SET_PANEL_SHOW       = "Show panel",
    SET_PANEL_LOCK       = "Lock panel position",
    SET_SCALE            = "Panel scale",
    SET_OPACITY          = "Background opacity",
    SET_THEME            = "Theme",
    SET_THEME_DARK       = "Dark",
    SET_THEME_LIGHT      = "Light",
    SET_THEME_CUSTOM     = "Custom",
    SET_HEADER_COLORS    = "Custom colors",
    SET_COLORS_HINT      = "Used when the theme is set to Custom. Seeded from Dark.",
    SET_COLORS_RESET     = "Reset custom colors",
    COLOR_bg             = "Background",
    COLOR_border         = "Border / accent",
    COLOR_title          = "Panel title",
    COLOR_name           = "Encounter names",
    COLOR_zone           = "Zone text",
    COLOR_timer          = "Detail text",
    COLOR_live           = "Live",
    COLOR_soon           = "Expected",
    COLOR_overdue        = "Overdue",
    COLOR_unknown        = "No data",
    COLOR_here           = "Current-zone highlight",
    SET_COMPACT          = "Compact mode (hide zone names)",
    SET_COLLAPSED        = "Start collapsed",
    SET_COLLAPSE_MODE    = "Collapse display mode",
    COLLAPSE_MODE_NAME   = "Name only",
    COLLAPSE_MODE_STATUS = "Name + status",
    COLLAPSE_MODE_FULL   = "Full info",
    SET_DELUXE           = "Deluxe mode (show prediction details)",
    SET_DELUXE_TIP       = "Shows confidence breakdown, sample counts, and loading screen info for each encounter prediction.",
    SET_SHOW_TRAVEL      = "Show wayshrine buttons",
    SET_SHOW_HEADER_WS   = "Show header wayshrine button",
    SET_SHOW_HEADER_WS_TIP = "A persistent wayshrine shortcut on the panel header. Right-click to assign a wayshrine; left-click to open its map.",
    SET_SHOW_DISCLAIMER   = "Show disclaimer footer",
    SET_PANEL_WIDTH       = "Panel width",
    SET_ONLY_CURRENT     = "Only show the encounter of your current zone",
    SET_HIDE_IN_COMBAT   = "Hide panel during combat",
    SET_SHOW_SECONDS     = "Show seconds in timers",
    SET_RESET_TIMINGS       = "Reset Learned Timings",
    SET_RESET_TIMINGS_TOOLTIP = "Clears all learned cooldown data and observation log. Use if timers seem inaccurate after a game patch.",
    SET_SHOW_MAP_PINS    = "Show encounter locations on world map",
    SET_HEADER_ENCOUNTERS= "Encounters",
    SET_TRACK_FMT        = "Track <<1>>",
    SET_HEADER_ALERTS    = "Alerts",
    SET_ALERT_CSA        = "On-screen announcement when one goes live",
    SET_ALERT_CHAT       = "Chat message when one goes live / ends",
    SET_ALERT_SOUND      = "Alert sound",
    SET_ALERT_SOUND_NONE = "None",
    SET_PREALERT         = "Early warning before estimated start (seconds, 0 = off)",
    SET_PREALERT_WARN    = "Early warnings use learned estimates, not an official timer.",
}

local de = {
    PANEL_TITLE          = "Dynamic Encounters +",
    STATUS_LIVE          = "JETZT AKTIV",
    STATUS_LIVE_FOR      = "aktiv seit <<1>>",
    STATUS_EXPECTED      = "n\195\164chstes ~<<1>>",
    STATUS_OVERDUE       = "jeden Moment f\195\164llig",
    STATUS_COOLDOWN      = "endete vor <<1>>",
    STATUS_UNKNOWN       = "keine Daten - Zone besuchen",
    STATUS_STALE         = "zuletzt vor <<1>> gesehen",
    STEP_TIME_LEFT       = "noch <<1>>",
    CONFIDENCE           = "gesch\195\164tzt aus <<1>> Zyklen",
    YOU_ARE_HERE         = "(du bist hier)",
    ALERT_LIVE           = "Dynamische Begegnung l\195\164uft!",
    ALERT_LIVE_SUB       = "<<1>> hat in <<2>> begonnen",
    ALERT_SOON           = "Dynamische Begegnung erwartet",
    ALERT_SOON_SUB       = "<<1>> in <<2>> (gesch\195\164tzt)",
    CHAT_LIVE            = "<<1>> ist in <<2>> AKTIV!",
    CHAT_ENDED           = "<<1>> in <<2>> ist beendet. N\195\164chste in ~<<3>> erwartet.",
    CHAT_SOON            = "<<1>> in <<2>> in ~<<3>> erwartet (Sch\195\164tzung).",
}

local fr = {
    PANEL_TITLE          = "Dynamic Encounters +",
    STATUS_LIVE          = "EN COURS",
    STATUS_LIVE_FOR      = "actif depuis <<1>>",
    STATUS_EXPECTED      = "prochain ~<<1>>",
    STATUS_OVERDUE       = "imminent",
    STATUS_COOLDOWN      = "termin\195\169 il y a <<1>>",
    STATUS_UNKNOWN       = "aucune donn\195\169e - visitez la zone",
    STATUS_STALE         = "vu il y a <<1>>",
    STEP_TIME_LEFT       = "<<1>> restant",
    CONFIDENCE           = "estim\195\169 sur <<1>> cycle(s)",
    YOU_ARE_HERE         = "(vous \195\170tes dans cette zone)",
    ALERT_LIVE           = "Rencontre dynamique en cours !",
    ALERT_LIVE_SUB       = "<<1>> a commenc\195\169 en <<2>>",
    ALERT_SOON           = "Rencontre dynamique imminente",
    ALERT_SOON_SUB       = "<<1>> dans <<2>> (estimation)",
    CHAT_LIVE            = "<<1>> est EN COURS en <<2>> !",
    CHAT_ENDED           = "<<1>> en <<2>> est termin\195\169. Prochaine dans ~<<3>>.",
    CHAT_SOON            = "<<1>> en <<2>> attendue dans ~<<3>> (estimation).",
}

local translations = { de = de, fr = fr }

function HE.GetString(key, ...)
    local lang = GetCVar("language.2")
    local t = translations[lang]
    local text = (t and t[key]) or en[key] or key
    if select("#", ...) > 0 then
        return zo_strformat(text, ...)
    end
    return text
end
