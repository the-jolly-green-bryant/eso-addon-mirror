-- =============================================================================
-- Motifs Tracker — Core Logic v2.0.8
-- Tracks motif style chapter progress with visual grid.
-- Scene-based UI with GAMEPAD_DRIVEN_UI_WINDOW for native console input.
-- =============================================================================

KT = KT or {}
KT.name    = "MotifTracker"
KT.version = "2.2.4"
KT.compatibleAddonNames = {
    MotifTracker = true,
    KnowledgeTracker = true,
}

-- Runtime state ---------------------------------------------------------------
KT.savedVars   = nil
KT.motifs      = {}
KT.undaunted   = {}
KT.scanDone    = false

-- Default saved variables -----------------------------------------------------
local SAVED_VAR_VERSION = 1
local SV_DEFAULTS = {
    position = { x = 300, y = 150 },
    migratedFromKnowledgeTrackerSV = false,
    viewedCharId = nil,
    viewedServer = nil,
    pinnedCharIds = {},
}

-- Keybinding string registration ----------------------------------------------
ZO_CreateStringId("SI_BINDING_NAME_KT_TOGGLE",      "Toggle Motifs Tracker (/mt)")
ZO_CreateStringId("SI_BINDING_NAME_KT_SCROLL_DOWN", "Scroll Down")
ZO_CreateStringId("SI_BINDING_NAME_KT_SCROLL_UP",   "Scroll Up")
ZO_CreateStringId("SI_BINDING_NAME_KT_CLOSE",       "Close Tracker")

-- ═══════════════════════════════════════════════════════════════════════════
-- DATA SCANNING
-- ═══════════════════════════════════════════════════════════════════════════

function KT:ScanAll()
    local scanned = KT_Data:ScanAll({
        viewedCharId = self.savedVars and self.savedVars.viewedCharId or nil,
        viewedServer = self.savedVars and self.savedVars.viewedServer or nil,
        pinnedCharIds = self.savedVars and self.savedVars.pinnedCharIds or {},
    })
    self.motifs = (type(scanned) == "table" and scanned.motifs) or {}
    self.undaunted = (type(scanned) == "table" and scanned.undaunted) or {}
    self.scanDone = true
    self.lastScanAtMs = (type(GetFrameTimeMilliseconds) == "function" and GetFrameTimeMilliseconds()) or 0
end

-- ═══════════════════════════════════════════════════════════════════════════
-- PUBLIC HELPERS
-- ═══════════════════════════════════════════════════════════════════════════

function KT:GetMotifs() return self.motifs end
function KT:GetUndaunted() return self.undaunted end

function KT:EnsureUndaunted(forceRefresh, onReady)
    self.undaunted = KT_Data:GetUndauntedCached(forceRefresh) or self.undaunted or {}
    KT_Data:StartUndauntedScanAsync(function(result)
        self.undaunted = result or {}
        if type(onReady) == "function" then
            onReady(self.undaunted)
        end
    end, forceRefresh)
    return self.undaunted
end

function KT:GetViewedCharacterName()
    local _, chars = KT_Data:GetCharacterContext()
    local viewedId = self.savedVars and self.savedVars.viewedCharId
    for _, ch in ipairs(chars or {}) do
        if ch.id == viewedId then
            return ch.name
        end
    end
    return (GetUnitName and GetUnitName("player")) or "Current"
end

function KT:GetPinnedCount()
    local n = 0
    local pins = self.savedVars and self.savedVars.pinnedCharIds or {}
    for _, v in pairs(pins) do
        if v == true then
            n = n + 1
        end
    end
    return n
end

function KT:EnsureViewedCharacter()
    local server, chars = KT_Data:GetCharacterContext()
    if self.savedVars then
        self.savedVars.viewedServer = server or self.savedVars.viewedServer
    end
    if not chars or #chars == 0 then
        return
    end
    local viewedId = self.savedVars and self.savedVars.viewedCharId
    if viewedId then
        for _, ch in ipairs(chars) do
            if ch.id == viewedId then
                return
            end
        end
    end
    if self.savedVars then
        self.savedVars.viewedCharId = chars[1].id
    end
end

function KT:CycleViewedCharacter(delta)
    local _, chars = KT_Data:GetCharacterContext()
    if not chars or #chars == 0 or not self.savedVars then
        return
    end
    self:EnsureViewedCharacter()
    local currentId = self.savedVars.viewedCharId
    local idx = 1
    for i = 1, #chars do
        if chars[i].id == currentId then
            idx = i
            break
        end
    end
    local count = #chars
    local newIdx = ((idx - 1 + (delta or 1)) % count) + 1
    self.savedVars.viewedCharId = chars[newIdx].id
    self:ScanAll()
    if KT_UI and KT_UI.visible then
        KT_UI:RefreshList()
    end
end

function KT:TogglePinViewedCharacter()
    if not self.savedVars then
        return
    end
    self.savedVars.pinnedCharIds = self.savedVars.pinnedCharIds or {}
    local id = self.savedVars.viewedCharId
    if not id then
        return
    end
    if self.savedVars.pinnedCharIds[id] then
        self.savedVars.pinnedCharIds[id] = nil
    else
        if self:GetPinnedCount() >= 3 then
            d("|cE8C05C[MT]|r Max 3 pinned characters.")
            return
        end
        self.savedVars.pinnedCharIds[id] = true
    end
    self:ScanAll()
    if KT_UI and KT_UI.visible then
        KT_UI:RefreshList()
    end
end

function KT:ToggleWindow()
    if KT_UI then
        KT_UI:Toggle()
    end
end

-- ═══════════════════════════════════════════════════════════════════════════
-- INITIALISATION
-- ═══════════════════════════════════════════════════════════════════════════

function KT:Initialize()
    self.savedVars = ZO_SavedVars:NewAccountWide(
        "MotifTrackerSV", SAVED_VAR_VERSION, nil, SV_DEFAULTS)

    -- One-time migration from old variable bucket name.
    if not self.savedVars.migratedFromKnowledgeTrackerSV then
        local oldRoot = _G["KnowledgeTrackerSV"]
        local displayName = type(GetDisplayName) == "function" and GetDisplayName() or nil
        local oldAccount = (type(oldRoot) == "table" and displayName) and oldRoot[displayName] or nil
        local oldAccountWide = (type(oldAccount) == "table" and oldAccount["$AccountWide"]) or nil
        local oldPosition = nil
        if type(oldAccountWide) == "table" and type(oldAccountWide.position) == "table" then
            oldPosition = oldAccountWide.position
        end

        if type(oldPosition) == "table" then
            self.savedVars.position = {
                x = tonumber(oldPosition.x) or self.savedVars.position.x,
                y = tonumber(oldPosition.y) or self.savedVars.position.y,
            }
        end
        self.savedVars.migratedFromKnowledgeTrackerSV = true
    end
    if type(self.savedVars.pinnedCharIds) ~= "table" then
        self.savedVars.pinnedCharIds = {}
    end
    self:EnsureViewedCharacter()
    self:ScanAll()

    -- Initialize UI
    if KT_UI then
        KT_UI:Initialize()
    end

    SLASH_COMMANDS["/mt"] = function(args)
        local cmd = string.lower(args or "")
        if cmd == "close" or cmd == "hide" then
            if KT_UI then KT_UI:Hide() end
        elseif cmd == "help" or cmd == "?" then
            d("|cE8C05C[MT] Commands:|r")
            d("  |c00FFFF/mt|r - toggle tracker")
            d("  |c00FFFF/mt close|r - close tracker")
            d("  |c00FFFF/mt help|r - show this list")
            d("  Left Stick = line scroll, L2/R2 = page scroll, Square = search")
            d("  L1/R1 = next/prev char, X = show missing pieces, Triangle = switch tab")
        else
            self:ToggleWindow()
        end
    end
    SLASH_COMMANDS["/motifstracker"] = function() self:ToggleWindow() end

    EVENT_MANAGER:RegisterForEvent(self.name .. "_StyleLearned",
        EVENT_STYLE_LEARNED,
        function()
            KT_Data:InvalidateUndauntedCache()
            self:ScanAll()
            if KT_UI and KT_UI.visible then KT_UI:RefreshList() end
        end)
end

-- Late initialization: add to Journal menu after game UI is fully loaded
function KT:LateInitialize()
    if KT_UI then
        KT_UI:LateInit()
    end
end

-- ═══════════════════════════════════════════════════════════════════════════
-- EVENT HOOKS
-- ═══════════════════════════════════════════════════════════════════════════

local function OnAddonLoaded(_, addonName)
    if not (KT.compatibleAddonNames and KT.compatibleAddonNames[addonName]) then
        return
    end
    EVENT_MANAGER:UnregisterForEvent(KT.name, EVENT_ADD_ON_LOADED)
    KT:Initialize()
end

local function OnPlayerActivated()
    EVENT_MANAGER:UnregisterForEvent(KT.name .. "_PlayerActivated", EVENT_PLAYER_ACTIVATED)
    zo_callLater(function()
        KT:ScanAll()
        KT:LateInitialize()
    end, 2000)
end

EVENT_MANAGER:RegisterForEvent(KT.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)
EVENT_MANAGER:RegisterForEvent(KT.name .. "_PlayerActivated", EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
