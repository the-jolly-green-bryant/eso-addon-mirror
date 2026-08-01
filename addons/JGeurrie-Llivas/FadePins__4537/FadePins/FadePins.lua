local ADDON_NAME = "FadePins"

local USE_FADE = true
local FADE_MODIFIER = 0.25

local isMapOpen = false
local hoveredGroups = {}
local pinManagerInstance = nil

local function GetPinGroup(pinType, customPins)
    -- the pin's group is stored, but only while the mouse is hovering over them
    local builtInGroup = ZO_MapPin.PIN_TYPE_TO_PIN_GROUP[pinType]
    if builtInGroup then return builtInGroup end
    local customPin = customPins[pinType]
    if customPin then return customPin.pinTypeString end
    return nil
end

-- clarification: all pins from other groups
local function ApplyFadeToAllPins()
    -- eso already has methods to alter pins; it's used to alter other groups
    if pinManagerInstance == nil then return end
    local hasHover = next(hoveredGroups) ~= nil
    local useFade = USE_FADE
    local fadeModifier = FADE_MODIFIER
    local customPins = ZO_WorldMap_GetPinManager().customPins
    for _, pin in pairs(pinManagerInstance:GetActiveObjects()) do
        local control = pin:GetControl()
        if hasHover and useFade then
            local group = GetPinGroup(pin:GetPinType(), customPins)
            -- pins that don't have groups are gated out; that causes errors
            control:SetAlpha((group and hoveredGroups[group]) and 1 or fadeModifier)
        else
            control:SetAlpha(1)
        end
    end
end

local function OnPinMouseEnter(self, pinType)
    if not isMapOpen then return end
    local group = GetPinGroup(pinType, ZO_WorldMap_GetPinManager().customPins)
    if group == nil then
        -- when a nil group is hovered, all groups are altered for a brief time
        -- hovering over any pin stops transitions, even if it's texture is transparent
        ApplyFadeToAllPins()
        return
    end
    -- the pin's group is stored, but only while the mouse is hovering over them
    hoveredGroups[group] = true
    ApplyFadeToAllPins()
end

local function OnPinMouseExit(self, pinType)
    if not isMapOpen then return end
    local group = GetPinGroup(pinType, ZO_WorldMap_GetPinManager().customPins)
    if group == nil then
        ApplyFadeToAllPins()
        return
    end
    -- the pin's group is stored, but only while the mouse is hovering over them
    hoveredGroups[group] = nil
    ApplyFadeToAllPins()
end

local function OnMapShowing()
    -- nothing happens unless the map is open
    isMapOpen = true
end

local function OnMapHidden()
    -- nothing happens unless the map is open
    isMapOpen = false
    ZO_ClearTable(hoveredGroups)
    ApplyFadeToAllPins()
end

local function OnStateChange(oldState, newState)
    -- nothing happens unless the map is open
    if newState == SCENE_SHOWING then
        OnMapShowing()
    elseif newState == SCENE_HIDDEN then
        OnMapHidden()
    end
end

local function OnPlayerActivated(event, initial)
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_PLAYER_ACTIVATED)
    -- nothing happens unless the player is loaded; not the loading screen
    -- eso already has callbacks for when the map opens and closes
    WORLD_MAP_SCENE:RegisterCallback("StateChange", OnStateChange)
    GAMEPAD_WORLD_MAP_SCENE:RegisterCallback("StateChange", OnStateChange)

    -- eso already has hooks for when the mouse starts or stops hovering over pins
    ZO_PostHook(WORLD_MAP_MANAGER, "DoMouseEnterForPinType", OnPinMouseEnter)
    ZO_PostHook(WORLD_MAP_MANAGER, "DoMouseExitForPinType", OnPinMouseExit)

    -- when the map changes, fade is reapplied using an instance captured from createpin
    -- pins are replaced, not changed; they revert back to their original appearance
    ZO_PostHook(ZO_WorldMapPins_Manager, "CreatePin", function(self, pinType)
        pinManagerInstance = self
        if isMapOpen and next(hoveredGroups) ~= nil then
            ApplyFadeToAllPins()
        end
    end)
end

local function OnAddOnLoaded(event, addonName)
    if addonName ~= ADDON_NAME then return end
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
