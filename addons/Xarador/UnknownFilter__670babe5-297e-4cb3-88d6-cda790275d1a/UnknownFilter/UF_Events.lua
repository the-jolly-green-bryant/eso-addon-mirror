-- UF_Events.lua (v0.2.8)
local UF = UnknownFilter

-- ===== Helpers (wie 0.2.7) ==================================================

local function IsTradingSceneShown()
    local sc = SCENE_MANAGER and SCENE_MANAGER:GetScene("gamepad_trading_house")
    if not sc then return false end
    if sc.IsShowing and sc:IsShowing() then return true end
    if sc.GetState and sc:GetState() == SCENE_SHOWN then return true end
    return false
end

local function IsBrowseMode()
    if TRADING_HOUSE_GAMEPAD and TRADING_HOUSE_GAMEPAD.GetCurrentMode then
        local m = TRADING_HOUSE_GAMEPAD:GetCurrentMode()
        if type(ZO_TRADING_HOUSE_MODE_BROWSE) == "number" then
            return m == ZO_TRADING_HOUSE_MODE_BROWSE
        end
        return m == 1
    end
    return false
end

-- ===== Neue kleine Guards / Safe Wrapper ====================================

local function SafeCall(fn, ...)
    if type(fn) ~= "function" then return false end
    local ok, err = pcall(fn, ...)
    if not ok and err then
        d(("[UnknownFilter] SafeCall error: %s"):format(tostring(err)))
    end
    return ok
end

-- Flüchtige UI-Referenzen (falls in GUI gecacht wird) aggressiv löschen
function UF:ClearTransientUIRefs()
    self._lastBrowseData = nil
    self._lastScrollList = nil
end

-- Nur Guarding (Hooks/Prune bleiben in UF_GUI.lua)
local function WireSceneGuards()
    local sm = SCENE_MANAGER
    if not sm then return end

    -- Beim Verlassen der Browse-Results Szene alles Vergängliche vergessen.
    local gpBrowse = sm:GetScene("gamepad_tradinghouse_browse_results")
    if gpBrowse and not UF._gpBrowseGuard then
        UF._gpBrowseGuard = true
        gpBrowse:RegisterCallback("StateChange", function(_, newState)
            if newState == SCENE_HIDING or newState == SCENE_HIDDEN then
                SafeCall(UF.ClearTransientUIRefs, UF)
            end
        end)
    end

    -- Optional: Keyboard-Browse ebenfalls absichern
    local kbBrowse = sm:GetScene("tradinghousebrowse")
    if kbBrowse and not UF._kbBrowseGuard then
        UF._kbBrowseGuard = true
        kbBrowse:RegisterCallback("StateChange", function(_, newState)
            if newState == SCENE_HIDING or newState == SCENE_HIDDEN then
                SafeCall(UF.ClearTransientUIRefs, UF)
            end
        end)
    end
end

-- ===== Trading-House Ergebnis-Callback (wie 0.2.7, mit SafeCall) ============

function UF:OnResults(_, guildId, numItemsOnPage, currentPage, hasMorePages)
    if not self._armed then return end

    self._lastCount   = numItemsOnPage or 0
    self._lastPage    = currentPage or 0
    self._lastHasMore = hasMorePages and true or false
    if (currentPage or 0) == 0 then self._autoStep = 0 end

    self:Say(string.format("---- RESULTS ---- page=%d more=%s count=%d mode=%s",
        self._lastPage, tostring(self._lastHasMore), self._lastCount,
        self:ModeShort((self.saved and self.saved.mode) or self.MODE_OFF)))

    local kept = 0
    if IsTradingSceneShown() and IsBrowseMode() then
        kept = select(1, SafeCall(self.PruneResultList, self)) or 0
    end

    if (self.saved and self.saved.skipEmptyPages)
        and ((self.saved.mode or self.MODE_OFF) ~= self.MODE_OFF)
        and (kept or 0) == 0
        and self._lastHasMore
    then
        self._skipHops = (self._skipHops or 0) + 1
        if self._skipHops <= (self.saved.skipMaxHops or 6) then
            self:Say(string.format("Empty page (%d) → requesting next…", self._lastPage))
            SafeCall(self.RequestPage, self, (self._lastPage or 0) + 1)
            return
        else
            self:Say("Stop skipping: safety limit reached")
        end
    else
        self._skipHops = 0
    end
end

-- ===== Events registrieren ===================================================

local function EnsureEvents()
    if UF._eventsRegistered then return end

    EVENT_MANAGER:RegisterForEvent(
        UF.name,
        EVENT_TRADING_HOUSE_SEARCH_RESULTS_RECEIVED,
        function(...) SafeCall(UF.OnResults, UF, ...) end
    )

    EVENT_MANAGER:RegisterForEvent(
        UF.name,
        EVENT_PLAYER_ACTIVATED,
        function()
            if UF._armed then
                zo_callLater(function()
                    SafeCall(WireSceneGuards)
                    SafeCall(UF.WireSceneKeybind, UF) -- bleibt in UF_GUI.lua
                end, 150)
            end
        end
    )

    EVENT_MANAGER:RegisterForEvent(
        UF.name,
        EVENT_OPEN_STORE,
        function() SafeCall(UF.ClearTransientUIRefs, UF) end
    )

    UF._eventsRegistered = true
end

-- ===== Armierung / OnLoaded / Slash-Commands ================================

local function ArmAddon()
    if UF._armed then return end
    UF._armed = true
    UF.saved = UF.saved or ZO_SavedVars:NewAccountWide("UnknownFilterSavedVars", 1, nil, UF.defaults)
    EnsureEvents()
    SafeCall(WireSceneGuards)
    SafeCall(UF.WireSceneKeybind, UF)
end

local function OnLoaded(_, addon)
    if addon ~= UF.name then return end
    EVENT_MANAGER:UnregisterForEvent(UF.name, EVENT_ADD_ON_LOADED)
    UF.saved = ZO_SavedVars:NewAccountWide("UnknownFilterSavedVars", 1, nil, UF.defaults)
    ArmAddon()
end
EVENT_MANAGER:RegisterForEvent(UF.name, EVENT_ADD_ON_LOADED, OnLoaded)

SLASH_COMMANDS["/ufmode"]  = function() SafeCall(UF.Slash_mode,  UF) end
SLASH_COMMANDS["/ufdebug"] = function(arg) SafeCall(UF.Slash_debug, UF, arg) end
SLASH_COMMANDS["/ufscan"]  = function(arg) SafeCall(UF.Slash_scan,  UF, arg) end
SLASH_COMMANDS["/ufdump"]  = function() SafeCall(UF.Slash_dump,  UF) end
SLASH_COMMANDS["/ufprobe"] = function() SafeCall(UF.Slash_probe, UF) end
SLASH_COMMANDS["/ufforce"] = function() SafeCall(UF.Slash_force, UF) end
SLASH_COMMANDS["/ufauto"]  = function(arg) SafeCall(UF.Slash_auto,  UF, arg) end
SLASH_COMMANDS["/ufpage"]  = function(arg) SafeCall(UF.Slash_page,  UF, arg) end
