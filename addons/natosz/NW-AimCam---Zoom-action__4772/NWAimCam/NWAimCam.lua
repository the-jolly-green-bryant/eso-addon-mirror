local NWAimCam = {}
NWAimCam.name = "NWAimCam"
NWAimCam.version = "1.2"

local isAiming = false
local savedDistance = "130"
local aimTimer = 0

-- Default settings when the Addon is loaded for the first time
local defaultSettings = {
    enabled = true,
    aimDistance = "0",
    maxFOV = 130,
    hOffset = 34,
    failsafeTime = 1.25
}

-- Centralized function to safely reset the camera and stop the timer
local function ResetCamera()
    if isAiming then
        SetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_DISTANCE, savedDistance)
        isAiming = false
        EVENT_MANAGER:UnregisterForUpdate(NWAimCam.name .. "Update")
    end
end

-- Timer logic to unlock the camera if the game misses the arrow release
function NWAimCam.OnUpdate()
    aimTimer = aimTimer + 100
    
    -- Multiply the seconds by 1000 to match the game's millisecond ticks
    if aimTimer > (NWAimCam.savedVars.failsafeTime * 1000) then
        ResetCamera()
    end
end

function NWAimCam.OnCombatEventIn(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)
    
    if not NWAimCam.savedVars.enabled then return end
    
    if sourceType == COMBAT_UNIT_TYPE_PLAYER then
        
        -- Player starts pulling the bowstring
        if result == ACTION_RESULT_BEGIN and abilityId == 16691 then
            if not isAiming then
                savedDistance = GetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_DISTANCE)
                
                SetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_DISTANCE, NWAimCam.savedVars.aimDistance)
                isAiming = true
                aimTimer = 0
                
                EVENT_MANAGER:RegisterForUpdate(NWAimCam.name .. "Update", 100, NWAimCam.OnUpdate)
            end
            
        -- Player is already aiming
        elseif isAiming then
            
            if abilityId == 28549 or abilityId == 28545 then
                ResetCamera()
                
            elseif abilityId ~= 16691 then
                ResetCamera()
            end
        end
    end
end

-- Function that builds the Settings Menu using LibAddonMenu-2.0
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
            type = "checkbox",
            name = "Enable Action Aim",
            tooltip = "Turns the camera magic on or off.",
            getFunc = function() return NWAimCam.savedVars.enabled end,
            setFunc = function(value) NWAimCam.savedVars.enabled = value end,
            default = defaultSettings.enabled,
        },
        {
            type = "dropdown",
            name = "Zoom Style",
            tooltip = "How do you want to see when pulling the bow?\nFirst Person: Looks through the character's eyes.\nShoulder Aim: The camera stays close, like in a shooter game.",
            choices = {"First Person", "Shoulder Aim"},
            choicesValues = {"0", "1.5"},
            getFunc = function() return NWAimCam.savedVars.aimDistance end,
            setFunc = function(value) NWAimCam.savedVars.aimDistance = value end,
            default = defaultSettings.aimDistance,
        },
        {
            type = "slider",
            name = "Maximum Field of View (FOV)",
            tooltip = "Adjust your normal 3rd person Field of View directly from here.",
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
            tooltip = "Moves the camera left or right. 34 is the ideal spot for playing over the shoulder.",
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
            name = "Failsafe Timer (Seconds)",
            tooltip = "How long the camera should wait to release if the game loses the arrow release signal.",
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
            text = "Recommended Failsafe Timer for each FOV:\n" ..
                   "90 FOV = 1.25 sec\n" ..
                   "100 FOV = 1.35 sec\n" ..
                   "110 FOV = 1.45 sec\n" ..
                   "120 FOV = 1.50 sec\n" ..
                   "130 FOV = 1.55 sec\n\n" ..
                   "Dodges, Sprinting, WASD, and other keys will zoom out back to max FOV immediately.\n\n" ..
                   "Zoom in and out speed is not possible to change, so the less max FOV you use the better the gameplay immersion (Real Action Combat Players play ZOOMED IN).",
        },
    }
    LAM:RegisterOptionControls("NWAimCamOptions", optionsData)
end

function NWAimCam.OnAddOnLoaded(event, addonName)
    if addonName == NWAimCam.name then
        EVENT_MANAGER:UnregisterForEvent(NWAimCam.name, EVENT_ADD_ON_LOADED)
        
        NWAimCam.savedVars = ZO_SavedVars:NewAccountWide("NWAimCamVariables", 1, nil, defaultSettings)
        
        CreateSettingsMenu()
        
        EVENT_MANAGER:RegisterForEvent(NWAimCam.name .. "In", EVENT_COMBAT_EVENT, NWAimCam.OnCombatEventIn)
        EVENT_MANAGER:AddFilterForEvent(NWAimCam.name .. "In", EVENT_COMBAT_EVENT, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
    end
end

EVENT_MANAGER:RegisterForEvent(NWAimCam.name, EVENT_ADD_ON_LOADED, NWAimCam.OnAddOnLoaded)