local NWAimCam = {}
NWAimCam.name = "NWAimCam"
NWAimCam.version = "1.4"

local isAiming = false
local savedDistance = "130"
local aimTimer = 0

-- Weapon ID Mappings
local WEAPON_IDS = {
    BOW = { 16691 },
    DESTRUCTION = { 15383, 16261, 18396 }, -- Inferno, Ice, Lightning
    RESTORATION = { 16212 }
}

-- Default settings
local defaultSettings = {
    enabled = true,
    enableBow = true,
    enableDestruction = true,
    enableRestoration = true,
    aimDistance = "0",
    maxFOV = 130,
    hOffset = 34,
    failsafeTime = 1.25
}

-- Centralized function to safely reset the camera
local function ResetCamera()
    if isAiming then
        SetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_DISTANCE, savedDistance)
        isAiming = false
        EVENT_MANAGER:UnregisterForUpdate(NWAimCam.name .. "Update")
    end
end

-- Timer logic for failsafe
function NWAimCam.OnUpdate()
    aimTimer = aimTimer + 100
    if aimTimer > (NWAimCam.savedVars.failsafeTime * 1000) then
        ResetCamera()
    end
end

-- Event triggered when heavy attack / aim begins
function NWAimCam.OnCombatEventBegin(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)
    if not isAiming then
        savedDistance = GetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_DISTANCE)
        SetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_DISTANCE, NWAimCam.savedVars.aimDistance)
        isAiming = true
        aimTimer = 0
        EVENT_MANAGER:RegisterForUpdate(NWAimCam.name .. "Update", 100, NWAimCam.OnUpdate)
    end
end

-- Active registered ability IDs table for fast lookup on release
local registeredAbilityLookup = {}

-- Event triggered on other actions to release the camera
function NWAimCam.OnCombatEventEnd(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)
    if isAiming and not registeredAbilityLookup[abilityId] then
        ResetCamera()
    end
end

-- Performance Optimization: Register events strictly for enabled weapons
function NWAimCam.RegisterEvents()
    NWAimCam.UnregisterEvents()

    if not NWAimCam.savedVars.enabled then return end

    registeredAbilityLookup = {}
    local abilitiesToRegister = {}

    if NWAimCam.savedVars.enableBow then
        for _, id in ipairs(WEAPON_IDS.BOW) do
            table.insert(abilitiesToRegister, id)
            registeredAbilityLookup[id] = true
        end
    end

    if NWAimCam.savedVars.enableDestruction then
        for _, id in ipairs(WEAPON_IDS.DESTRUCTION) do
            table.insert(abilitiesToRegister, id)
            registeredAbilityLookup[id] = true
        end
    end

    if NWAimCam.savedVars.enableRestoration then
        for _, id in ipairs(WEAPON_IDS.RESTORATION) do
            table.insert(abilitiesToRegister, id)
            registeredAbilityLookup[id] = true
        end
    end

    -- Register individual engine filters for each enabled weapon ID
    for _, abilityId in ipairs(abilitiesToRegister) do
        local eventName = NWAimCam.name .. "Begin_" .. tostring(abilityId)
        EVENT_MANAGER:RegisterForEvent(eventName, EVENT_COMBAT_EVENT, NWAimCam.OnCombatEventBegin)
        EVENT_MANAGER:AddFilterForEvent(eventName, EVENT_COMBAT_EVENT, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
        EVENT_MANAGER:AddFilterForEvent(eventName, EVENT_COMBAT_EVENT, REGISTER_FILTER_ACTION_RESULT, ACTION_RESULT_BEGIN)
        EVENT_MANAGER:AddFilterForEvent(eventName, EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, abilityId)
    end

    -- If at least one category is enabled, register the End event
    if #abilitiesToRegister > 0 then
        EVENT_MANAGER:RegisterForEvent(NWAimCam.name .. "End", EVENT_COMBAT_EVENT, NWAimCam.OnCombatEventEnd)
        EVENT_MANAGER:AddFilterForEvent(NWAimCam.name .. "End", EVENT_COMBAT_EVENT, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
    end
end

-- Performance Optimization: Unregister all events completely
function NWAimCam.UnregisterEvents()
    for _, category in pairs(WEAPON_IDS) do
        for _, id in ipairs(category) do
            EVENT_MANAGER:UnregisterForEvent(NWAimCam.name .. "Begin_" .. tostring(id), EVENT_COMBAT_EVENT)
        end
    end
    EVENT_MANAGER:UnregisterForEvent(NWAimCam.name .. "End", EVENT_COMBAT_EVENT)
    ResetCamera()
end

-- Settings Menu setup
local function CreateSettingsMenu()
    local LAM = LibAddonMenu2
    
    local panelData = {
        type = "panel",
        name = "NW Aim Camera",
        displayName = "NW Action Aim",
        author = "Natosz",
        version = NWAimCam.version,
        registerForRefresh = true,
        registerForDefaults = true,
    }
    LAM:RegisterAddonPanel("NWAimCamOptions", panelData)
    
    local optionsData = {
        {
            type = "header",
            name = "General Settings",
        },
        {
            type = "checkbox",
            name = "Enable Action Aim",
            tooltip = "Turns the camera magic on or off.",
            getFunc = function() return NWAimCam.savedVars.enabled end,
            setFunc = function(value) 
                NWAimCam.savedVars.enabled = value 
                NWAimCam.RegisterEvents()
            end,
            default = defaultSettings.enabled,
        },
        {
            type = "header",
            name = "Weapon Triggers",
        },
        {
            type = "checkbox",
            name = "Bows",
            tooltip = "Enable action aim zoom when drawing a Bow.",
            getFunc = function() return NWAimCam.savedVars.enableBow end,
            setFunc = function(value) 
                NWAimCam.savedVars.enableBow = value 
                NWAimCam.RegisterEvents()
            end,
            disabled = function() return not NWAimCam.savedVars.enabled end,
            default = defaultSettings.enableBow,
        },
        {
            type = "checkbox",
            name = "Destruction Staves",
            tooltip = "Enable action aim zoom for Inferno, Ice, and Lightning Staves.",
            getFunc = function() return NWAimCam.savedVars.enableDestruction end,
            setFunc = function(value) 
                NWAimCam.savedVars.enableDestruction = value 
                NWAimCam.RegisterEvents()
            end,
            disabled = function() return not NWAimCam.savedVars.enabled end,
            default = defaultSettings.enableDestruction,
        },
        {
            type = "checkbox",
            name = "Restoration Staves",
            tooltip = "Enable action aim zoom for Restoration Staves.",
            getFunc = function() return NWAimCam.savedVars.enableRestoration end,
            setFunc = function(value) 
                NWAimCam.savedVars.enableRestoration = value 
                NWAimCam.RegisterEvents()
            end,
            disabled = function() return not NWAimCam.savedVars.enabled end,
            default = defaultSettings.enableRestoration,
        },
        {
            type = "header",
            name = "Camera Customization",
        },
        {
            type = "dropdown",
            name = "Zoom Style",
            tooltip = "First Person: Look through character eyes.\nShoulder Aim: Close over-the-shoulder view.",
            choices = {"First Person", "Shoulder Aim"},
            choicesValues = {"0", "1.5"},
            getFunc = function() return NWAimCam.savedVars.aimDistance end,
            setFunc = function(value) NWAimCam.savedVars.aimDistance = value end,
            default = defaultSettings.aimDistance,
        },
        {
            type = "slider",
            name = "Maximum Field of View (FOV)",
            tooltip = "Adjust normal 3rd person FOV directly from here.",
            min = 70,
            max = 130,
            step = 1,
            getFunc = function() return NWAimCam.savedVars.maxFOV end,
            setFunc = function(value) 
                NWAimCam.savedVars.maxFOV = value 
                SetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_THIRD_PERSON_FIELD_OF_VIEW, tostring(value))
            end,
            default = defaultSettings.maxFOV,
        },
        {
            type = "slider",
            name = "Horizontal Offset",
            tooltip = "Camera offset (34 is ideal for over the shoulder).",
            min = -50,
            max = 50,
            step = 1,
            getFunc = function() return NWAimCam.savedVars.hOffset end,
            setFunc = function(value) 
                NWAimCam.savedVars.hOffset = value 
                SetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_THIRD_PERSON_HORIZONTAL_OFFSET, tostring(value))
            end,
            default = defaultSettings.hOffset,
        },
        {
            type = "slider",
            name = "Zoom Immersion Control (Seconds)",
            tooltip = "Adjust the zoom out timing. Ideal default for Bow; adjust if playing with slower or channeled staves.",
            min = 0.50,
            max = 3.00,
            step = 0.05,
            decimals = 2,
            getFunc = function() return NWAimCam.savedVars.failsafeTime end,
            setFunc = function(value) NWAimCam.savedVars.failsafeTime = value end,
            default = defaultSettings.failsafeTime,
        },
        {
            type = "description",
            title = "Recommended Settings & Tips",
            text = "Recommended Zoom Immersion Control for Bow:\n" ..
                   "90 FOV = 1.25 sec\n" ..
                   "100 FOV = 1.35 sec\n" ..
                   "110 FOV = 1.45 sec\n" ..
                   "120 FOV = 1.50 sec\n" ..
                   "130 FOV = 1.55 sec\n\n" ..
                   "Ideal for Bow; other weapons with different attack charge or channel durations might require adjusting this slider to match your playstyle.\n\n" ..
                   "Dodges, Sprinting, WASD, and other actions will zoom out back to max FOV immediately.\n\n" ..
                   "Zoom in and out speed is controlled by the engine, so using a lower max FOV delivers greater immersion (Real Action Combat Players play ZOOMED IN).",
        },
    }
    LAM:RegisterOptionControls("NWAimCamOptions", optionsData)
end

function NWAimCam.OnAddOnLoaded(event, addonName)
    if addonName == NWAimCam.name then
        EVENT_MANAGER:UnregisterForEvent(NWAimCam.name, EVENT_ADD_ON_LOADED)
        
        NWAimCam.savedVars = ZO_SavedVars:NewAccountWide("NWAimCamVariables", 1, nil, defaultSettings, GetWorldName())
        
        CreateSettingsMenu()
        
        if NWAimCam.savedVars.enabled then
            NWAimCam.RegisterEvents()
        end
    end
end

EVENT_MANAGER:RegisterForEvent(NWAimCam.name, EVENT_ADD_ON_LOADED, NWAimCam.OnAddOnLoaded)