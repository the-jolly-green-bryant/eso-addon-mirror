local CAMERA_MOUNTED_DISTANCE = 6.0
local CAMERA_UNMOUNTED_WEAPON_OUT = 6.0
local CAMERA_UNMOUNTED_WEAPON_IN = 2.5

local function UpdateCamera(mounted)
    local isMounted = mounted
    if isMounted == nil then
        isMounted = IsMounted()
    end

    local inCombat = IsUnitInCombat("player")

    if isMounted then
        SetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_DISTANCE, tostring(CAMERA_MOUNTED_DISTANCE))
    elseif inCombat then
        SetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_DISTANCE, tostring(CAMERA_UNMOUNTED_WEAPON_OUT))
    else
        SetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_DISTANCE, tostring(CAMERA_UNMOUNTED_WEAPON_IN))
    end
end

local function OnMountedChanged(eventId, mounted)
    UpdateCamera(mounted)
end

local function CreateSettings()
    local panelData = {
        type = "panel",
        name = "MyDynamicCamera",
        displayName = "My Dynamic Camera",
        author = "User",
        version = "1.0",
    }

    local optionsTable = {
        {
            type = "slider",
            name = "Distance monté",
            tooltip = "Distance caméra quand monté",
            min = 2,
            max = 15,
            step = 0.1,
            getFunc = function() return CAMERA_MOUNTED_DISTANCE end,
            setFunc = function(value)
                CAMERA_MOUNTED_DISTANCE = value
                UpdateCamera()
            end,
            width = "full",
        },
        {
            type = "slider",
            name = "Distance armes sorties",
            tooltip = "Distance caméra quand armes sorties",
            min = 2,
            max = 15,
            step = 0.1,
            getFunc = function() return CAMERA_UNMOUNTED_WEAPON_OUT end,
            setFunc = function(value)
                CAMERA_UNMOUNTED_WEAPON_OUT = value
                UpdateCamera()
            end,
            width = "full",
        },
        {
            type = "slider",
            name = "Distance armes rangées",
            tooltip = "Distance caméra quand armes rangées",
            min = 2,
            max = 15,
            step = 0.1,
            getFunc = function() return CAMERA_UNMOUNTED_WEAPON_IN end,
            setFunc = function(value)
                CAMERA_UNMOUNTED_WEAPON_IN = value
                UpdateCamera()
            end,
            width = "full",
        },
    }

    LibAddonMenu2:RegisterAddonPanel("MyDynamicCameraPanel", panelData)
    LibAddonMenu2:RegisterOptionControls("MyDynamicCameraPanel", optionsTable)
end

local function OnAddonLoaded(event, addonName)
    if addonName ~= "MyDynamicCamera" then return end

    EVENT_MANAGER:UnregisterForEvent("MyDynamicCamera", EVENT_ADD_ON_LOADED)

    CreateSettings()

    EVENT_MANAGER:RegisterForEvent("MyDynamicCamera", EVENT_PLAYER_ACTIVATED, function() UpdateCamera() end)
    EVENT_MANAGER:RegisterForEvent("MyDynamicCamera", EVENT_MOUNTED_STATE_CHANGED, OnMountedChanged)
    EVENT_MANAGER:RegisterForEvent("MyDynamicCamera", EVENT_PLAYER_COMBAT_STATE, function() UpdateCamera() end)
end

EVENT_MANAGER:RegisterForEvent("MyDynamicCamera", EVENT_ADD_ON_LOADED, OnAddonLoaded)
