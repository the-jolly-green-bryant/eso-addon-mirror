-- Transmute Set Crafter
-- A queue-based transmutation assistant for the Transmutation Station.
-- Based on the design of Dolgubon's Lazy Set Crafter by Joseph Heinzle.
--
-- This file MUST load first (see manifest). It defines the namespace
-- and TSC.name so all subsequent modules can reference them at load time.

TransmuteSetCrafter = TransmuteSetCrafter or {}
local TSC = TransmuteSetCrafter

TSC.name    = "TransmuteSetCrafter"
TSC.version = 1

-- ── Shared color + armor-type tables ──────────────────────
-- One source of truth for colors and armor letters used by both the lists
-- (UI.lua) and the queue derivation (Queue.lua). ZO_ColorDef has both
-- :UnpackRGBA() for SetColor calls and :Colorize(text) for inline color
-- markup in label strings.

TSC.Color = {
    ARMOR_HEAVY  = ZO_ColorDef:New("FF5050"),
    ARMOR_MEDIUM = ZO_ColorDef:New("50FF50"),
    ARMOR_LIGHT  = ZO_ColorDef:New("60A0FF"),
    TEAL         = ZO_ColorDef:New("76BCC3"),
    DISABLED     = ZO_ColorDef:New(0.40, 0.40, 0.40, 1),
    ENOUGH       = ZO_ColorDef:New(0.55, 0.95, 0.55, 1),  -- have ≥ needed
    SHORT        = ZO_ColorDef:New(1.00, 0.45, 0.45, 1),  -- short of materials
    HEADER_HOVER = ZO_ColorDef:New(1.00, 1.00, 0.40, 1),  -- inventory header hover
}

TSC.ArmorLetter = {
    [ARMORTYPE_HEAVY]  = "H",
    [ARMORTYPE_MEDIUM] = "M",
    [ARMORTYPE_LIGHT]  = "L",
}

-- ── Notification helper ───────────────────────────────────
-- One place to send user-facing messages. INFO/WARN go to chat with a
-- "[TSC] " prefix; ERROR also pops a top-screen alert with negative sound
-- (so the user notices even with the chat window collapsed).

TSC.NOTIFY_INFO  = "info"
TSC.NOTIFY_WARN  = "warn"
TSC.NOTIFY_ERROR = "error"

local NOTIFY_PREFIX = "[TSC] "

function TSC.Notify(level, text)
    if level == TSC.NOTIFY_ERROR then
        ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NEGATIVE_CLICK, text)
    end
    d(NOTIFY_PREFIX .. text)
end

function TSC.NotifyF(level, stringId, ...)
    TSC.Notify(level, zo_strformat(stringId, ...))
end

-- ── Shared UI state ───────────────────────────────────────
-- Selection state shared between UI.lua (click handlers, edit/add flow) and
-- UI_Dropdowns.lua (combobox callbacks write here when the user picks).
-- Each refers to TSC._UI.selected* instead of holding its own local copy.

TSC._UI = {
    -- Trait/quality/enchant pickers (set by UI_Dropdowns combobox callbacks)
    selectedTrait          = nil,
    selectedQuality        = nil,
    selectedEnchant        = "",
    selectedEnchantQuality = ITEM_FUNCTIONAL_QUALITY_LEGENDARY,
    -- Multi-select piece state (mutated by UI_Lists, read by add/edit flow)
    selectedPieces         = {},
    lastSelectedPiece      = nil,
    lastUsedCategory       = nil,
    editingQueueIndex      = nil,
    -- Set/piece browsing mode (mutated by UI_Lists + OpenWindow)
    browsingMode           = "sets",
    selectedSet            = nil,
}

-- Pick a TSC.Color for an armor type, returning nil for non-armor (caller
-- decides the fallback). Centralizes the H→red / M→green / L→blue mapping.
function TSC.GetArmorColor(armorType)
    if     armorType == ARMORTYPE_HEAVY  then return TSC.Color.ARMOR_HEAVY
    elseif armorType == ARMORTYPE_MEDIUM then return TSC.Color.ARMOR_MEDIUM
    elseif armorType == ARMORTYPE_LIGHT  then return TSC.Color.ARMOR_LIGHT
    end
    return nil
end

-- ── Lazy caches ────────────────────────────────────────────
-- Both invalidate on EVENT_ITEM_SET_COLLECTIONS_UPDATED so the data manager
-- can swap underlying objects without leaving us with stale references.

local cachedCurrencyType -- nil = not computed yet

function TSC.GetReconCurrencyType()
    if cachedCurrencyType == nil then
        cachedCurrencyType = ITEM_SET_COLLECTIONS_DATA_MANAGER:GetReconstructionCurrencyOptionType(1)
                             or CURT_TRANSMUTE_CRYSTALS
    end
    return cachedCurrencyType
end

local pieceDataCache = {}  -- [pieceId] = pieceData | false (miss)

function TSC.GetPieceData(pieceId)
    if not pieceId then return nil end
    local hit = pieceDataCache[pieceId]
    if hit == nil then
        hit = ITEM_SET_COLLECTIONS_DATA_MANAGER:GetItemSetCollectionPieceData(pieceId) or false
        pieceDataCache[pieceId] = hit
    end
    return hit or nil
end

EVENT_MANAGER:RegisterForEvent(TSC.name .. "_CacheInval",
    EVENT_ITEM_SET_COLLECTIONS_UPDATED,
    function()
        cachedCurrencyType = nil
        pieceDataCache     = {}
    end)

-- ── Saved variable defaults ────────────────────────────────

TSC.defaults = {
    queue          = {},
    xPos           = nil,
    yPos           = nil,
    windowWidth           = 900,
    windowHeight          = 540,
    dividerX              = 384,
    costWindowWidth       = 300,
    costWindowHeight      = 540,
    costWindowHidden      = false,
    costXPos              = nil,  -- nil → docked to main window
    costYPos              = nil,
    quicksaveWindowWidth  = 280,
    quicksaveWindowHeight = 540,
    quicksaveWindowHidden = false,
    quicksaveXPos         = nil,  -- nil → docked to cost window
    quicksaveYPos         = nil,
    quicksaves            = {},
    openAtStation         = true,
    closeOnExit           = true,
    autoOpenReconstruct   = true,
    openAtEnchantStation  = true,
    closeOnEnchantExit    = true,
    sortMode            = "name",  -- "name" | "cost" | "weight"
}

-- ── Initialization ─────────────────────────────────────────

local function Initialize()
    TSC.savedVars = ZO_SavedVars:NewAccountWide(
        "TransmuteSetCrafterSavedVars", TSC.version, nil, TSC.defaults)

    -- One-time: clear stale side-window positions so they re-dock to the XML
    -- defaults (cost right of main, quicksave right of cost).
    if not TSC.savedVars.sideWindowDockMigrated then
        TSC.savedVars.costXPos              = nil
        TSC.savedVars.costYPos              = nil
        TSC.savedVars.quicksaveXPos         = nil
        TSC.savedVars.quicksaveYPos         = nil
        TSC.savedVars.sideWindowDockMigrated = true
    end

    TSC.InitializeSettings()
    TSC.SetupUI()
end

-- ── Console fast-path ─────────────────────────────────────
-- This is a keyboard-only addon. Console clients can't usefully load it.
-- Bail before registering any user-facing events so nothing fires and no
-- savedVars are touched. IsConsoleUI() is stable for the whole session,
-- unlike IsInGamepadPreferredMode() (which a PC player can toggle), so
-- using it at init time is safe: if it's false now, it stays false, and
-- mid-session gamepad toggles are handled separately below by the
-- EVENT_GAMEPAD_PREFERRED_MODE_CHANGED watcher.
if IsConsoleUI() then return end

-- ── Addon loaded ───────────────────────────────────────────

local function OnAddonLoaded(_, addonName)
    if addonName ~= TSC.name then return end
    EVENT_MANAGER:UnregisterForEvent(TSC.name, EVENT_ADD_ON_LOADED)
    Initialize()
end

EVENT_MANAGER:RegisterForEvent(TSC.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)

-- ── Player activated — deferred setup that needs live bags ─
-- Restore the persisted queue (bags are accessible now) and
-- register the retrait scene state callback (scenes are set up now).

local function OnPlayerActivated()
    EVENT_MANAGER:UnregisterForEvent(TSC.name .. "_Activate", EVENT_PLAYER_ACTIVATED)

    -- Restore queue from saved vars, dropping any items no longer in bags
    TSC.RestoreQueue()
    TSC.RefreshQueueList()
    TSC.UpdateCostDisplay()

    -- Watch the keyboard retrait scene for close-on-exit and to auto-switch to
    -- the Reconstruct tab. KEYBOARD_RETRAIT_ROOT_SCENE is a global set by the
    -- game's retrait station code.
    --
    -- Auto-switch design: ZOS's OnInteractSceneShowing reads self.mode to pick
    -- the active tab. We set self.mode to RECONSTRUCT before ZOS's callback by
    -- registering a prioritized StateChange callback (priority<nil sorts first).
    -- The "arm" flag is reset only on real interaction-end (walk-away), detected
    -- via GetInteractionType()==INTERACTION_NONE at SCENE_HIDDEN. Menu-pops leave
    -- the interaction active (INTERACTION_RETRAIT) so the flag stays cleared and
    -- a mid-session manual switch to Retrait is not overridden.
    TSC._needReconstructSwitch = true

    local scene = KEYBOARD_RETRAIT_ROOT_SCENE
                  or SCENE_MANAGER:GetScene("retrait_keyboard_root")
    if scene then
        scene:RegisterCallback("StateChange", function(oldState, newState)
            if newState == SCENE_SHOWING and oldState == SCENE_HIDDEN
               and TSC.savedVars and TSC.savedVars.autoOpenReconstruct
               and TSC._needReconstructSwitch
               and ZO_RETRAIT_STATION_KEYBOARD then
                ZO_RETRAIT_STATION_KEYBOARD.mode = ZO_RETRAIT_MODE_RECONSTRUCT
                TSC._needReconstructSwitch = nil
            end
        end, nil, 1)

        scene:RegisterCallback("StateChange", function(_, newState)
            if newState == SCENE_HIDDEN then
                if GetInteractionType() == INTERACTION_NONE then
                    TSC._needReconstructSwitch = true
                end
                if TSC.savedVars and TSC.savedVars.closeOnExit then
                    TSC.CloseWindow()
                end
            end
        end)
    end

    -- Escape key handler: when the in-game menu would open (escape pressed
    -- with no other UI on top), close our window stack first and cancel the
    -- menu opening so escape acts like "close TSC" rather than "open menu".
    local gameMenuScene = SCENE_MANAGER:GetScene("gameMenuInGame")
    if gameMenuScene then
        gameMenuScene:RegisterCallback("StateChange", function(_, newState)
            if newState ~= SCENE_SHOWING then return end
            local mainWin = TransmuteSetCrafterWindow
            if not mainWin or mainWin:IsHidden() then return end

            TSC.CloseWindow()
            -- Cancel the game menu that just started opening
            zo_callLater(function()
                if SCENE_MANAGER:IsShowing("gameMenuInGame") then
                    SCENE_MANAGER:Hide("gameMenuInGame")
                end
            end, 0)
        end)
    end
end

EVENT_MANAGER:RegisterForEvent(
    TSC.name .. "_Activate", EVENT_PLAYER_ACTIVATED, OnPlayerActivated)

-- ── Retrait station open event ─────────────────────────────

EVENT_MANAGER:RegisterForEvent(
    TSC.name .. "_Open",
    EVENT_RETRAIT_STATION_INTERACT_START,
    function()
        if TSC.savedVars and TSC.savedVars.openAtStation then
            TSC.OpenWindow()
        end
    end
)

-- ── Slash commands ─────────────────────────────────────────

SLASH_COMMANDS["/tsc"]              = function() TSC.ToggleWindow() end
SLASH_COMMANDS["/transmutecrafter"] = function() TSC.ToggleWindow() end

-- ── Gamepad-mode toggle watcher ───────────────────────────
-- A PC player can switch into gamepad-preferred mode mid-session without
-- /reloadui. If TSC's window is open at the moment they switch, the
-- keyboard-only UI becomes orphaned behind the gamepad UI and the user
-- can't interact with it. Auto-close it on the switch so the next manual
-- open will route through TSC.OpenWindow's gamepad-mode alert.
EVENT_MANAGER:RegisterForEvent(
    TSC.name .. "_ModeChange",
    EVENT_GAMEPAD_PREFERRED_MODE_CHANGED,
    function()
        if not IsInGamepadPreferredMode() then return end
        local win = TransmuteSetCrafterWindow
        if win and not win:IsHidden() then
            TSC.CloseWindow()
        end
    end)
