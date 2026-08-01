-- UnknownFilter.lua  (v0.2.7, API 101046)
-- Console/Gamepad (PS5/Xbox)
-- Auto-armed on load

UnknownFilter = UnknownFilter or {}
local UF = UnknownFilter

UF.name, UF.version = "UnknownFilter", "0.2.7"

-- Modes
UF.MODE_OFF     = 0
UF.MODE_GEAR    = 1
UF.MODE_LEARN   = 2
UF.MODE_MOTIF   = 3
UF.MODE_COLLECT = 4

UF.defaults = {
    mode           = UF.MODE_OFF, -- default OFF
    -- Chat/Debug: silent by default. Output only on commands (EchoOnce).
    echo           = false,       -- persistent echo (you can toggle via /ufecho), default OFF
    debug          = false,
    debugScan      = false,
    keepIfNoLink   = false,
    autoPage       = false,
    skipEmptyPages = true,
    skipMaxHops    = 6,
    debugCap       = 80,
}

UF.TARGET_LIST_NAME = "ZO_TradingHouse_BrowseResults_GamepadContainerList"

UF._armed, UF._eventsRegistered, UF._hooksInstalled, UF._sceneWired = false,false,false,false
UF._kbGroup = nil
UF._lastCount, UF._lastPage, UF._lastHasMore, UF._autoStep = 0,0,false,0

UF._passByIndex, UF._passByLink, UF._passTotal = {}, {}, 0

_G.UnknownFilter = UF
