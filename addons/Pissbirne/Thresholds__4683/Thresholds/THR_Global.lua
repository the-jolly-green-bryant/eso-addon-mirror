---------------------------------------------------------------------------
-- Thresholds - global addon table, constants and saved variable defaults
---------------------------------------------------------------------------

Thresholds = {
    name = "Thresholds",
    displayName = "Thresholds",
    author = "Birne",
    version = "1.4.1",

    SVName = "ThresholdsSavedVariables",
    SVVersion = 1,
    SV = nil, -- assigned in THR.Initialize

    BOSS_TAGS = { "boss1", "boss2", "boss3", "boss4", "boss5", "boss6" },
    MAX_ROWS = 6,

    FRAME_WIDTH = 320,
    ROW_HEIGHT = 26,
    FRAME_PADDING = 8,

    -- runtime state -------------------------------------------------------
    isEnabled = false,        -- events registered
    isCombat = false,
    previewMode = false,      -- forced-visible while the settings panel is open
    currentZoneId = 0,
    clientLang = nil,         -- GetCVar("Language.2"), cached in THR.Initialize

    subjects = {},            -- key -> subject table (see THR_Engine.lua)
    subjectKeyByTag = {},     -- unit tag ("boss1") -> subject key
    dedupe = {},              -- "<name>:<value>" -> true, cleared on combat end

    -- ui handles ----------------------------------------------------------
    frame = nil,
    content = nil,            -- inner control gated by combat/lock/subjects
    rows = nil,
    menuPanel = nil,
}

-- Seeded into SV.globalThresholds exactly once (see THR.Initialize). Must
-- NOT live in the ZO_SavedVars defaults: missing array indices would be
-- re-merged into a user-shortened list on every load.
Thresholds.DEFAULT_GLOBAL_THRESHOLDS = { 90, 70, 50, 25 }

Thresholds.default = {
    enabled = true,
    alerts = {
        text = true,          -- prominent on-screen text alert
        textFontSize = 32,
        textDuration = 3,     -- seconds
        sound = true,
        soundName = "DUEL_START",
        frame = true,
        -- textX/textY stay unset until the alert text is moved
    },
    frame = {
        locked = true,
        showOutOfCombat = false,
        fontSize = 20,
        -- left/top stay unset until the frame is moved
    },
    globalThresholds = {}, -- seeded from DEFAULT_GLOBAL_THRESHOLDS once
    zones = {},
    -- Threshold lists (globalThresholds, zones[id].thresholds and
    -- zones[id].bosses[name]) are mixed arrays; each item is either a plain
    -- percent number or a sparse alert entry table:
    --     { pct = 70, text = "Portal!", color = {r,g,b}, sound = "KEY",
    --       soundRepeat = 2|3, fontSize = n, duration = n, x = n, y = n,
    --       noText = true, noSound = true }
    -- x/y are a per-alert screen position (offset from top-center, like
    -- alerts.textX/textY); omitted = the shared alert position.
    -- Only keys differing from the global alert defaults are stored; missing
    -- keys inherit SV.alerts.* at fire time (see THR.FireAlert).
    --
    -- zones[zoneId] = {
    --     name = "Zone Name",                    -- display only
    --     thresholds = <list> or nil,            -- nil -> globalThresholds
    --     bosses = { ["Boss Name"] = <list> },   -- per-boss overrides
    -- }
}
