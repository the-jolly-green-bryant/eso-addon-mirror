local LAM = LibAddonMenu2
local LMP = LibMapPins

local addonName = 'PvDoor'
local PIN_DOOR = "PvDoorPin_door"

local pinTextures = {
    [1] = "PvDoor/Icons/PvDoor-door1.dds",
    [2] = "PvDoor/Icons/PvDoor-door2.dds",
    [3] = "PvDoor/Icons/PvDoor-key1.dds",
    [4] = "PvDoor/Icons/PvDoor-exclamation1.dds",
    [5] = "PvDoor/Icons/PvDoor-door3.dds",
    [6] = "PvDoor/Icons/PvDoor-door4.dds",
    [7] = "PvDoor/Icons/PvDoor-mark1.dds"
}

local pinTexturesList = {
    [1] = "Keep Door",
    [2] = "Simple Door",
    [3] = "Key",
    [4] = "Exclamation",
    [5] = "Double Doors",
    [6] = "Door Pointing",
    [7] = "X Mark"
}

local pinColor

PvDoor = ZO_Object:Subclass()
local T = PvDoor
T.name = "PvDoor"
T.version = "1.0.1"
T.debug = false
T.UI = {}

local defaults = {
    pin = {
        type = 1,
        size = 30,
        level = 40,
        hex = ZO_SELECTED_TEXT:ToHex()
    },
    imperial = {
        enabled = true
    }
}
local savedVariables

local function CreateSettingsMenu()
    local panelData = {
        type = "panel",
        name = "PvDoor",
        displayName = "|cFFFFB0PvDoor|r",
        author = "@skineh",
        version = T.version,
        registerForRefresh = true,
        registerForDefaults = true
    }
    LAM:RegisterAddonPanel(T.name, panelData)

	local CreateIcons, icon
	CreateIcons = function(panel)
		if panel == PvDoor then
			icon = WINDOW_MANAGER:CreateControl(nil, panel.controlsToRefresh[2], CT_TEXTURE)
			icon:SetAnchor(RIGHT, panel.controlsToRefresh[2].combobox, LEFT, -10, 0)
			icon:SetTexture(pinTextures[savedVariables.pin.type])
			icon:SetDimensions(savedVariables.pin.size, savedVariables.pin.size)
			CALLBACK_MANAGER:UnregisterCallback("LAM-PanelControlsCreated", CreateIcons)
		end
	end
	CALLBACK_MANAGER:RegisterCallback("LAM-PanelControlsCreated", CreateIcons)

    local optionsTable = {{
        type = "header",
        name = "CYRODIIL",
        width = "full"
    }, {
        type = "dropdown",
        name = "Pin Icon",
        tooltip = "The map pin icon to use for Keep doors.",
        choices = pinTexturesList,
        getFunc = function()
            return pinTexturesList[savedVariables.pin.type]
        end,
        setFunc = function(selected)
            for index, name in ipairs(pinTexturesList) do
                if name == selected then
                    savedVariables.pin.type = index
                    LMP:SetLayoutKey(PIN_DOOR, "texture", pinTextures[index])
                    LMP:RefreshPins(PIN_DOOR)
                    icon:SetTexture(pinTextures[index])
                    break
                end
            end
        end,
        default = pinTexturesList[defaults.pin.type]
    }, {
        type = "colorpicker",
        name = "Pin Tint",
        tooltip = "The color for the Keep door map pins.",
        getFunc = function()
            return pinColor:UnpackRGBA()
        end,
        setFunc = function(...)
            pinColor:SetRGBA(...)
            savedVariables.pin.hex = pinColor:ToHex()
            LMP:RefreshPins()
        end,
        default = ZO_SELECTED_TEXT
    }, {
        type = "slider",
        name = "Pin Size",
        tooltip = "How large the map pin for Keep doors will be.",
        min = 20,
        max = 70,
        step = 1,
        getFunc = function()
            return savedVariables.pin.size
        end,
        setFunc = function(value)
            savedVariables.pin.size = value
            LMP:SetLayoutKey(PIN_DOOR, "size", value)
            LMP:RefreshPins(PIN_DOOR)
            icon:SetDimensions(value, value)
        end,
        default = defaults.pin.size
    }, {
        type = "slider",
        name = "Pin Layer",
        tooltip = "Pins with higher numbers are drawn on top of pins with lower numbers. Raise the Pin Layer to make it appear over other pin types. Examples: Quests 110, Group Members 130, Wayshrine 140, Player 160",
        min = 1,
        max = 300,
        step = 5,
        getFunc = function()
            return savedVariables.pin.level
        end,
        setFunc = function(value)
            savedVariables.pin.level = value
            LMP:SetLayoutKey(PIN_DOOR, "level", value)
            LMP:RefreshPins(PIN_DOOR)
        end,
        default = defaults.pin.level
    },
    {
        type = "header",
        name = "IMPERIAL CITY",
        width = "full"
    },
    {
		type = "checkbox",
		name = "Enable District Labels",
        tooltip = "Toggle if districts and sewer entrances are labeled on the Imperial City map.",
		getFunc = function() 
            return savedVariables.imperial.enabled
        end,
		setFunc = function(value) 
            savedVariables.imperial.enabled = value

            if not value then
                local impData = PvDoors_GetImperialData() 
                for _, data in ipairs(impData) do
                    LMP:RemoveCustomPin(data.label)
                end
            end

            LMP:RefreshPins()
        end,
		default = defaults.imperial.enabled
	}}
    LAM:RegisterOptionControls(T.name, optionsTable)
end

function RecordPosition()
    local zone, subzone = LMP:GetZoneAndSubzone()
    local x, z, heading = GetMapPlayerPosition("player")
    savedVariables.doorsData = PvDoors_SetLocalData(savedVariables.doorsData, zone, subzone, {x, z, heading})

    d("Recorded " .. zone .. "/" .. subzone .. " [" .. tostring(x) .. ", " .. tostring(z) .. "] heading " .. heading)
end

local function SetPinColor(pin)
    return pinColor
end

local function PinCallback()
    if not LMP:IsEnabled(PIN_DOOR) or (GetMapType() > MAPTYPE_ZONE) then
        return
    end

    if not IsPlayerActivated() then
        return
    end

    local zone, subzone = LMP:GetZoneAndSubzone()
    local data = PvDoors_GetLocalData(zone, subzone)

    if data ~= nil then
        for _, pinData in ipairs(data) do
            LMP:CreatePin(PIN_DOOR, pinData, pinData[1], pinData[2])
        end
    end
end

local function ImpCallback(pinType)
    if GetMapType() > MAPTYPE_ZONE then
        return
    end

    if not IsPlayerActivated() then
        return
    end

    if not savedVariables.imperial.enabled then
        return
    end

    local zone, subzone = LMP:GetZoneAndSubzone()
    if zone == "cyrodiil" and subzone == "imperialcity_base" then
        local data = PvDoors_GetImperialData()
        for _, pinData in ipairs(data) do
            if pinData.label == pinType then
                if LMP:IsEnabled(pinData.label) then
                    LMP:CreatePin(pinData.label, pinData, pinData.x, pinData.y)
                end
            end
        end
    end
end

local function Init(event, name)
    if name ~= addonName then
        return
    end

    savedVariables = ZO_SavedVars:NewAccountWide("PvDoor_SavedVariables", 4, nil, defaults)

    pinColor = ZO_ColorDef:New(savedVariables.pin.hex)
    local layout = {
        level = savedVariables.pin.level,
        texture = pinTextures[savedVariables.pin.type],
        size = savedVariables.pin.size,
        tint = SetPinColor
    }
    LMP:AddPinType(PIN_DOOR, PinCallback, nil, layout, nil)

    local impData = PvDoors_GetImperialData() 
    for _, data in ipairs(impData) do
        local impLayout = {
            level = 40,
            texture = data.path,
            size = data.size / 2,
            hex = ZO_SELECTED_TEXT:ToHex()
        }
        LMP:AddPinType(data.label, function () ImpCallback(data.label) end, nil, impLayout, nil)
    end

    CreateSettingsMenu()

    EVENT_MANAGER:UnregisterForEvent(addonName, EVENT_ADD_ON_LOADED)
end

EVENT_MANAGER:RegisterForEvent(addonName, EVENT_ADD_ON_LOADED, Init)
