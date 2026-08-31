local ADDON_NAME = "TetsuDailyWritPrecrafter"
TetsuDailyWritPrecrafter = TetsuDailyWritPrecrafter or {}

local defaultAccountVars = {
    autoQuest = true,
    autoBox = true,
    compatLazyWrit = true,
    quietInfo = false,
    -- Per-character settings stored under characters[charName]
    characters = {},
}

local function GetCharSettings()
    local vars = TetsuDailyWritPrecrafter.savedVars
    if not vars then return nil end
    local name = TetsuDailyWritPrecrafter.Data.PlayerName()
    vars.characters = vars.characters or {}
    if not vars.characters[name] then
        vars.characters[name] = {
            preCraftEnabled = false,
            preCraftDays = 3,
        }
    end
    -- Ensure defaults exist even for old entries
    local cs = vars.characters[name]
    if cs.preCraftEnabled == nil then cs.preCraftEnabled = false end
    if not cs.preCraftDays or cs.preCraftDays < 1 then cs.preCraftDays = 3 end
    if cs.preCraftDays > 10 then cs.preCraftDays = 10 end
    -- Compat: pre-craft is always on (Lazy Writ handles "today")
    if TetsuDailyWritPrecrafter.IsLazyWritCompat and TetsuDailyWritPrecrafter.IsLazyWritCompat() then
        cs.preCraftEnabled = true
    end
    return cs
end

TetsuDailyWritPrecrafter.GetCharSettings = GetCharSettings

function TetsuDailyWritPrecrafter.IsLazyWritCompat()
    local vars = TetsuDailyWritPrecrafter.savedVars
    -- Default ON: missing key counts as compat
    return not (vars and vars.compatLazyWrit == false)
end




local function AddonLooksLikeLazyWrit(name, title)
    local hay = string.lower(tostring(name or "") .. " " .. tostring(title or ""))
    if hay:find("dolgubon", 1, true) and hay:find("writ", 1, true) then
        return true
    end
    if hay:find("lazywrit", 1, true) then
        return true
    end
    if hay:find("lazy writ", 1, true) then
        return true
    end
    return false
end

function TetsuDailyWritPrecrafter.GetConflictingWritAddons()
    local found, seen = {}, {}
    if GetNumAddOns then
        for i = 1, GetNumAddOns() do
            local name, title, author, description, enabled = GetAddOnInfo(i)
            if enabled and AddonLooksLikeLazyWrit(name, title) then
                local label = title or name
                if label and not seen[label] then
                    seen[label] = true
                    found[#found + 1] = label
                end
            end
        end
    end
    -- Loaded in this session even if the folder name is unexpected
    if _G.WritCreater and not seen["Dolgubon's Lazy Writ Crafter"] then
        found[#found + 1] = "Dolgubon's Lazy Writ Crafter"
    end
    return found
end

function TetsuDailyWritPrecrafter.HasLazyWritLoaded()
    local list = TetsuDailyWritPrecrafter.GetConflictingWritAddons()
    return list and #list > 0, list
end

function TetsuDailyWritPrecrafter.HasWritConflict()
    -- Compat mode: Lazy Writ owns today/quests/boxes; we only pre-craft. No hard block.
    if TetsuDailyWritPrecrafter.IsLazyWritCompat and TetsuDailyWritPrecrafter.IsLazyWritCompat() then
        return false, {}
    end
    local list = TetsuDailyWritPrecrafter.GetConflictingWritAddons()
    return list and #list > 0, list
end

local function Announce(title, body, chatLine)
    if chatLine then d(chatLine) end
    pcall(function()
        ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.GENERAL_ALERT_ERROR, title .. " — " .. body)
    end)
    pcall(function()
        if CENTER_SCREEN_ANNOUNCE and CENTER_SCREEN_ANNOUNCE.AddMessage then
            CENTER_SCREEN_ANNOUNCE:AddMessage(
                EVENT_BROADCAST,
                CSA_CATEGORY_LARGE_TEXT,
                SOUNDS.GENERAL_ALERT_ERROR,
                title,
                body
            )
        end
    end)
end

local function ShowMissingLazyWritWarning()
    local L = TetsuDailyWritPrecrafter.L or {}
    Announce(
        L.MISSING_LWC_TITLE or "Lazy Writ Creator not found",
        L.MISSING_LWC_BODY or "Install Lazy Writ Creator, or turn OFF Work together in settings (stand-alone).",
        L.MISSING_LWC_CHAT or "|cFF6666[Tetsu's Daily Writ Precrafter]|r Lazy Writ Creator is not enabled. Install it, or disable Work together for stand-alone."
    )
end

local function ShowConflictWarning(list)
    local L = TetsuDailyWritPrecrafter.L or {}
    local names = table.concat(list, ", ")
    local title = L.CONFLICT_TITLE or "Addon conflict"
    local body = zo_strformat(
        L.CONFLICT_BODY or "Disable <<1>> while Tetsu's Daily Writ Precrafter is enabled. Both addons craft writs and will clash.",
        names
    )
    local chatLine = zo_strformat(
        L.CONFLICT_CHAT or "|cFF6666[Tetsu's Daily Writ Precrafter]|r Conflict: disable |cFFD700<<1>>|r. Auto-craft is paused.",
        names
    )
    Announce(title, body, chatLine)
end

local function SanitizeDatabase()
    local vars = TetsuDailyWritPrecrafter.savedVars
    if not vars or not vars.characters then return end

    local validNames = {}
    local numChars = GetNumCharacters and GetNumCharacters() or 0
    for i = 1, numChars do
        local n = TetsuDailyWritPrecrafter.Data.CharacterNameFromIndex(i)
        if n then validNames[n] = true end
    end

    for key, _ in pairs(vars.characters) do
        if not validNames[key] then
            vars.characters[key] = nil
        end
    end
end

local function OnAddOnLoaded(event, addonName)
    if addonName ~= ADDON_NAME then return end

    TetsuDailyWritPrecrafter.savedVars = ZO_SavedVars:NewAccountWide(
        "TetsuDailyWritPrecrafterSavedVars",
        1,
        nil,
        defaultAccountVars
    )

    SanitizeDatabase()
    GetCharSettings() -- ensure current character entry exists

    if TetsuDailyWritPrecrafter.RegisterSettings then
        TetsuDailyWritPrecrafter.RegisterSettings()
    end

    if TetsuDailyWritPrecrafter.Quests and TetsuDailyWritPrecrafter.Quests.Initialize then
        TetsuDailyWritPrecrafter.Quests.Initialize()
    end
    -- Let Lazy Writ finish today's writ, but do not kick us out during our pre-craft.
    zo_callLater(function()
        if not _G.WritCreater then return end
        local orig = WritCreater.IsOkayToExitCraftStation
        WritCreater.IsOkayToExitCraftStation = function(...)
            local C = TetsuDailyWritPrecrafter.Crafting
            if C and C.IsBusy and C.IsBusy() then
                return false
            end
            if type(orig) == "function" then
                return orig(...)
            end
            return true
        end
    end, 1500)


    -- Station keybind management
    local function RefreshStationKeybind()
        if not TetsuDailyWritPrecrafter.Crafting then return end
        EVENT_MANAGER:UnregisterForUpdate("TDWP_KeybindRefresh")
        local C = TetsuDailyWritPrecrafter.Crafting
        local ct = GetCraftingInteractionType and GetCraftingInteractionType() or 0
        if C.IsWritCraftType and not C.IsWritCraftType(ct) then
            if C.RemoveStationKeybind then C.RemoveStationKeybind() end
            return
        end
        local attempts = 0
        EVENT_MANAGER:RegisterForUpdate("TDWP_KeybindRefresh", 200, function()
            attempts = attempts + 1
            local now = GetCraftingInteractionType and GetCraftingInteractionType() or 0
            if (C.IsWritCraftType and not C.IsWritCraftType(now)) or now == 0 then
                EVENT_MANAGER:UnregisterForUpdate("TDWP_KeybindRefresh")
                if C.RemoveStationKeybind then C.RemoveStationKeybind() end
                return
            end
            C.AddStationKeybind()
            if attempts >= 2 then
                EVENT_MANAGER:UnregisterForUpdate("TDWP_KeybindRefresh")
            end
        end)
    end

    EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "_StationOpen", EVENT_CRAFTING_STATION_INTERACT, function(_, craftingType)
        local C = TetsuDailyWritPrecrafter.Crafting
        if C and C.IsWritCraftType and not C.IsWritCraftType(craftingType) then
            EVENT_MANAGER:UnregisterForUpdate("TDWP_KeybindRefresh")
            if C.RemoveStationKeybind then C.RemoveStationKeybind() end
            return
        end
        RefreshStationKeybind()
    end)

    local function ClearStationKeybind()
        EVENT_MANAGER:UnregisterForUpdate("TDWP_KeybindRefresh")
        if TetsuDailyWritPrecrafter.Crafting then
            if TetsuDailyWritPrecrafter.Crafting.AbortBecauseStationClosed then
                TetsuDailyWritPrecrafter.Crafting.AbortBecauseStationClosed()
            end
            TetsuDailyWritPrecrafter.Crafting._stationSessionDone = false
            TetsuDailyWritPrecrafter.Crafting._autoQuestStarted = false
            TetsuDailyWritPrecrafter.Crafting._stationLock = false
            if TetsuDailyWritPrecrafter.Crafting.RemoveStationKeybind then
                TetsuDailyWritPrecrafter.Crafting.RemoveStationKeybind()
            end
        end
    end

    EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "_StationClose", EVENT_END_CRAFTING_INTERACTION, ClearStationKeybind)
    if EVENT_END_CRAFTING_STATION_INTERACT then
        EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "_StationClose2", EVENT_END_CRAFTING_STATION_INTERACT, ClearStationKeybind)
    end

    if SCENE_MANAGER and SCENE_MANAGER.RegisterCallback then
        SCENE_MANAGER:RegisterCallback("SceneStateChanged", function(scene, oldState, newState)
            pcall(function()
                if not scene or not scene.GetName then return end
                if scene:GetName() ~= "hud" then return end
                if newState ~= SCENE_SHOWN then return end
                local cType = GetCraftingInteractionType and GetCraftingInteractionType() or 0
                if not cType or cType == 0 then
                    ClearStationKeybind()
                end
            end)
        end)
    end

    EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "_ModeUpdate", EVENT_CRAFTING_MODE_UPDATED, function()
        RefreshStationKeybind()
    end)

    EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "_Activated", EVENT_PLAYER_ACTIVATED, function()
        SanitizeDatabase()
        GetCharSettings()
        if not TetsuDailyWritPrecrafter._modeWarned then
            TetsuDailyWritPrecrafter._modeWarned = true
            zo_callLater(function()
                if TetsuDailyWritPrecrafter.IsLazyWritCompat and TetsuDailyWritPrecrafter.IsLazyWritCompat() then
                    local hasLwc = TetsuDailyWritPrecrafter.HasLazyWritLoaded and select(1, TetsuDailyWritPrecrafter.HasLazyWritLoaded())
                    if not hasLwc then
                        ShowMissingLazyWritWarning()
                    end
                else
                    local has, list = TetsuDailyWritPrecrafter.HasWritConflict()
                    if has then
                        ShowConflictWarning(list)
                    end
                end
            end, 2500)
        end
    end)

    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
