local ADDON_NAME = "TetsuDailyWritPrecrafter"
TetsuDailyWritPrecrafter = TetsuDailyWritPrecrafter or {}

local defaultAccountVars = {
    autoQuest = true,
    autoBox = true,
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
    return cs
end

TetsuDailyWritPrecrafter.GetCharSettings = GetCharSettings

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

    -- Station keybind management
    local function RefreshStationKeybind()
        if not TetsuDailyWritPrecrafter.Crafting then return end
        EVENT_MANAGER:UnregisterForUpdate("TDWP_KeybindRefresh")
        local attempts = 0
        EVENT_MANAGER:RegisterForUpdate("TDWP_KeybindRefresh", 200, function()
            attempts = attempts + 1
            if not GetCraftingInteractionType or GetCraftingInteractionType() == 0 then
                EVENT_MANAGER:UnregisterForUpdate("TDWP_KeybindRefresh")
                TetsuDailyWritPrecrafter.Crafting.RemoveStationKeybind()
                return
            end
            TetsuDailyWritPrecrafter.Crafting.AddStationKeybind()
            if attempts >= 2 then
                EVENT_MANAGER:UnregisterForUpdate("TDWP_KeybindRefresh")
            end
        end)
    end

    EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "_StationOpen", EVENT_CRAFTING_STATION_INTERACT, function()
        RefreshStationKeybind()
    end)

    local function ClearStationKeybind()
        EVENT_MANAGER:UnregisterForUpdate("TDWP_KeybindRefresh")
        if TetsuDailyWritPrecrafter.Crafting and TetsuDailyWritPrecrafter.Crafting.RemoveStationKeybind then
            TetsuDailyWritPrecrafter.Crafting.RemoveStationKeybind()
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
    end)

    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
