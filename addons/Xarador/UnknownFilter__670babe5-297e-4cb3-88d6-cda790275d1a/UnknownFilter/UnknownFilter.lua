-- UnknownFilter.lua
-- ESO Update 50 / API 101050

UnknownFilter = UnknownFilter or {}
local UF = UnknownFilter

UF.name = "UnknownFilter"
UF.version = "0.3.2"
UF.apiVersion = 101050
UF.settingsVersion = 302

UF.MODE_OFF = 0
UF.MODE_GEAR = 1
UF.MODE_LEARN = 2
UF.MODE_MOTIF = 3
UF.MODE_COLLECT = 4

UF.defaults = {
    settingsVersion = 0,
    mode = UF.MODE_OFF,
    echo = false,
    debug = false,
    debugScan = false,
    keepIfNoLink = false,
    autoPage = false,
    skipEmptyPages = true,
    skipMaxHops = 6,
    debugCap = 80,
}

UF._armed = false
UF._eventsRegistered = false
UF._sceneWired = false
UF._uiHooksInstalled = false
UF._pagingHooksInstalled = false
UF._runtimeAttempts = 0
UF._kbGroup = nil

UF._serverItemCount = 0
UF._visibleItemCount = 0
UF._filteredPageEmpty = false

UF._autoHops = 0
UF._autoToken = 0
UF._focusToken = 0
UF._lastCompletedPage = nil
UF._autoRequestPending = false

UF._passByIndex = {}
UF._passByLink = {}
UF._passTotal = 0

_G.UnknownFilter = UF
