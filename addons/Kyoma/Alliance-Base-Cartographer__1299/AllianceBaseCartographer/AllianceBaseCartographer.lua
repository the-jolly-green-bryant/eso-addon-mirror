-------------------------------------------------------------------------------
-- Alliance Base Cartographer
-------------------------------------------------------------------------------
AllianceBaseCartographer = {}

--Libraries--------------------------------------------------------------------
local LAM = LibStub("LibAddonMenu-2.0")
local LMP = LibStub("LibMapPins-1.0")

--Local constants -------------------------------------------------------------
local ADDON_VERSION = "1.3"
local PINTYPE_NAME = "AllianceBaseCartographer_Pin"
local IMPERIAL_CITY_MAP_INDEX = GetImperialCityMapIndex()

--Local variables -------------------------------------------------------------
local savedVariables

local AD = ALLIANCE_ALDMERI_DOMINION
local DC = ALLIANCE_DAGGERFALL_COVENANT
local EP = ALLIANCE_EBONHEART_PACT

local GlobalPinColor, AlliancePinColors, DummyPinColor

local PinTextures = {
    ["Simple"] = {
        [AD] = "/esoui/art/campaign/overview_allianceicon_aldmeri.dds",
        [DC] = "/esoui/art/campaign/overview_allianceicon_daggefall.dds",
        [EP] = "/esoui/art/campaign/overview_allianceicon_ebonheart.dds",
    },
    ["Banner"] = {
        [AD] = "/esoui/art/guild/guildbanner_icon_aldmeri.dds",
        [DC] = "/esoui/art/guild/guildbanner_icon_daggerfall.dds",
        [EP] = "/esoui/art/guild/guildbanner_icon_ebonheart.dds",
    },
}

--Default values --------------------------------------------------------------
local defaults = {
    useAllianceColors = false,
    pinTexture = {
        type = "Simple",
        size = 40,
        level = 51,
    },
    pinColor = {1, 1, 1, 1},
    pinAllianceColor = {
        [AD] = {GetAllianceColor(AD):UnpackRGBA()},
        [DC] = {GetAllianceColor(DC):UnpackRGBA()},
        [EP] = {GetAllianceColor(EP):UnpackRGBA()},
    },
}

-- Callback to Create pins
local function CreatePins()
    if (GetCurrentMapIndex() == IMPERIAL_CITY_MAP_INDEX) then
        for _, data in ipairs(AllianceBaseCartographerData) do
            local x, y, alliance = unpack(data)
            if (not (not x or not y or x <= 0 or x >= 1 or y <= 0 or y >= 1)) then
                 LMP:CreatePin(PINTYPE_NAME, data, x, y)
            end
        end
    end
end

-- Settings menu --------------------------------------------------------------
local function CreateSettingsMenu()
    local panelData = {
        type = "panel",
        name = "Alliance Base Cartographer",
        displayName = "Alliance Base Cartographer",
        author = "Kyoma",
        version = ADDON_VERSION,
        slashCommand = "/abcsettings",
        registerForRefresh = true,
        registerForDefaults = true,
    }
    local settingsPanel = LAM:RegisterAddonPanel("AllianceBaseCartographer", panelData)

    local optionsData = {
        {
            type = "header",
            name = "GENERAL OPTIONS",
        },
        {
            type = "slider",
            name = "Pin size",
            tooltip = "Set the size of the map pins",
            min = 20,
            max = 70,
            getFunc = function() return savedVariables.pinTexture.size end,
            setFunc = function(size)
                savedVariables.pinTexture.size = size
                LMP:SetLayoutKey(PINTYPE_NAME, "size", size)
                LMP:RefreshPins(PINTYPE_NAME)
            end,
            default = defaults.pinTexture.size,
        },
        {
            type = "dropdown",
            name = "Pin texture type",
            tooltip = "The type of icons used. Colors are only available for the simple textures.",
            choices = {"Simple", "Banner"},
            getFunc = function() return savedVariables.pinTexture.type end,
            setFunc = function(value)
                savedVariables.pinTexture.type = value
                LMP:RefreshPins(PINTYPE_NAME)
            end,
            default = defaults.pinTexture.type
            
        },
        {
            type = "header",
            name = "COLOR OPTIONS",
        },
        {
            type = "colorpicker",
            name = "Pin Color",
            tooltip = "Set the color of the map pins",
            getFunc = function() return unpack(savedVariables.pinColor) end,
            setFunc = function(r,g,b,a)
                savedVariables.pinColor = {r,g,b,a}
                GlobalPinColor:SetRGBA(r,g,b,a)
                LMP:RefreshPins(PINTYPE_NAME)
            end,
            default = ZO_ColorDef:New(unpack(defaults.pinColor)),
        },
        {
            type = "checkbox",
            name = "Use Alliance Colors",
            tooltip = "Use the alliance colors for the map pins.",
            getFunc = function() return savedVariables.useAllianceColors end,
            setFunc = function(value)
                savedVariables.useAllianceColors = value 
                LMP:RefreshPins(PINTYPE_NAME)
            end,
        },
        {
            type = "colorpicker",
            name = " - Aldmeri Dominion",
            tooltip = "Set the color of the Aldmeri Dominion map pins",
            getFunc = function() return unpack(savedVariables.pinAllianceColor[AD]) end,
            setFunc = function(r,g,b,a)
                savedVariables.pinAllianceColor[AD] = {r,g,b,a}
                AlliancePinColors[AD]:SetRGBA(r,g,b,a)
                LMP:RefreshPins(PINTYPE_NAME)
            end,
            disabled = function() return not savedVariables.useAllianceColors end,
            default = ZO_ColorDef:New(unpack(defaults.pinAllianceColor[AD])),
        },
        {
            type = "colorpicker",
            name = " - Daggerfall Covenant",
            tooltip = "Set the color of the Daggerfall Covenant map pins",
            getFunc = function() return unpack(savedVariables.pinAllianceColor[DC]) end,
            setFunc = function(r,g,b,a)
                savedVariables.pinAllianceColor[DC] = {r,g,b,a}
                AlliancePinColors[DC]:SetRGBA(r,g,b,a)
                LMP:RefreshPins(PINTYPE_NAME)
            end,
            disabled = function() return not savedVariables.useAllianceColors end,
            default = ZO_ColorDef:New(unpack(defaults.pinAllianceColor[DC])),
        },
        {
            type = "colorpicker",
            name = " - Ebonheart Pact",
            tooltip = "Set the color of the Ebonheart Pact map pins",
            getFunc = function() return unpack(savedVariables.pinAllianceColor[EP]) end,
            setFunc = function(r,g,b,a)
                savedVariables.pinAllianceColor[EP] = {r,g,b,a}
                AlliancePinColors[EP]:SetRGBA(r,g,b,a)
                LMP:RefreshPins(PINTYPE_NAME)
            end,
            disabled = function() return not savedVariables.useAllianceColors end,
            default = ZO_ColorDef:New(unpack(defaults.pinAllianceColor[EP])),
        },
    }
    LAM:RegisterOptionControls("AllianceBaseCartographer", optionsData)
end

-- Initialize --------------------------------------------------------------
local function OnLoad(eventCode, addOnName)

    if (addOnName == "AllianceBaseCartographer") then

        -- Load / Create saved variable file
        savedVariables = ZO_SavedVars:NewAccountWide("ABC_Data", 2, nil, defaults)

        AlliancePinColors = {}
        AlliancePinColors[AD] = ZO_ColorDef:New(unpack(savedVariables.pinAllianceColor[AD]))
        AlliancePinColors[DC] = ZO_ColorDef:New(unpack(savedVariables.pinAllianceColor[DC]))
        AlliancePinColors[EP] = ZO_ColorDef:New(unpack(savedVariables.pinAllianceColor[EP]))
        GlobalPinColor = ZO_ColorDef:New(unpack(savedVariables.pinColor))
        DummyPinColor = ZO_ColorDef:New(1, 1, 1, 1)

        -- Get pin layout from saved variables
        local pinLayout = { 
            level = savedVariables.pinTexture.level, 
            texture = function(pin)
                return PinTextures[savedVariables.pinTexture.type][pin.m_PinTag[3]]
            end, 
            size = savedVariables.pinTexture.size, 
            tint = function(pin)
                if (savedVariables.pinTexture.type == "Banner") then
                    return DummyPinColor
                elseif (savedVariables.useAllianceColors) then
                    return AlliancePinColors[pin.m_PinTag[3]]
                else
                    return GlobalPinColor
                end
            end,
        }

        -- Create addon menu
        CreateSettingsMenu()

        -- Initialize map pins (LibMapPins)
        LMP:AddPinType(PINTYPE_NAME, CreatePins, nil, pinLayout, nil)

        -- Add filter check boxes
        LMP:AddPinFilter(PINTYPE_NAME, "Alliance Bases", nil, savedVariables.filters)

        EVENT_MANAGER:UnregisterForEvent("AllianceBaseCartographer", EVENT_ADD_ON_LOADED)
    end
end

-- Init AllianceBaseCartographer
EVENT_MANAGER:RegisterForEvent("AllianceBaseCartographer", EVENT_ADD_ON_LOADED, OnLoad)