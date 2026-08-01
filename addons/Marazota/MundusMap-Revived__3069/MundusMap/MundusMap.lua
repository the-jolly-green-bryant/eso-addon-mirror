--
-- improved and corrected by Aruntas for version 1.6
-- Fixed LAM 2.0 addon menu by Baertram
--
local MunMapSettings = {}
local MunMapdefaults =
{
    showMundusStones = true,
	showTamrielStones = true,
	showStoneType = {
		[1] = true,
		[2] = true,
		[3] = true,
		[4] = true,
		[5] = true,
		[6] = true,
		[7] = true,
		[8] = true,
		[9] = true,
		[10] = true,
		[11] = true,
		[12] = true,
		[13] = true,
	}
}

-- Gets Tool Tip Text
local function GetInfoFromTag(pin)
	local _, pinTag = pin:GetPinTypeAndTag()
	local mundusname = MunMap.localization["filter"..pinTag[3]]
	local mundustype = MunMap.localization["filtertooltip"..pinTag[3]]

	return mundusname, mundustype
end

-- Creates Tool Tip
MunMap.pinTooltipCreator = {}
MunMap.pinTooltipCreator.tooltip = 1
MunMap.pinTooltipCreator.creator = function(pin)
	local mundusname, mundustype = GetInfoFromTag(pin)
        InformationTooltip:AddLine("Mundus Stone Information:", "", ZO_HIGHLIGHT_TEXT:UnpackRGB())
		ZO_Tooltip_AddDivider(InformationTooltip)
        InformationTooltip:AddLine(mundusname, "", ZO_TOOLTIP_DEFAULT_COLOR:UnpackRGB())
        InformationTooltip:AddLine(mundustype, "", ZO_TOOLTIP_DEFAULT_COLOR:UnpackRGB())
		ZO_Tooltip_AddDivider(InformationTooltip)
end

--Handles icon placement on maps for Mundus Stones
local function GetZoneAndSubzone()
	local textureName = GetMapTileTexture()

	textureName = string.lower(textureName)
--	d(textureName)
	local _,_,_,zone,subzone = string.find(textureName, "(maps/)([%w%-]+)/([%w%-]+_%w+)")
	
	return zone, subzone
end

function MunMap.pinCreator_Mundus(pinManager)
    if not MunMapSettings.showMundusStones then return end
	local zone, subzone = GetZoneAndSubzone()
	if MunMap.MundusMapData[zone] == nil or MunMap.MundusMapData[zone][subzone] == nil then return end
	local Munduss = MunMap.MundusMapData[zone][subzone]
	if (zone == "tamriel" and MunMapSettings.showTamrielStones == false) then return end

		for _, pinData in pairs(Munduss) do
			if (MunMapSettings.showStoneType[pinData[3]]) == true then
				--ZO_WorldMap_AddCustomPin(pinType, addCallback, nil, pinLayoutData, pinTooltipCreator)
				pinManager:CreatePin( _G["Mundus_Stone_Pin"], pinData, pinData[1], pinData[2])
			end
		end
end

local function OnAddOnLoaded(eventCode, addOnName)
    if(addOnName == "MundusMap") then

        -- Load / Create our saved variable file
        MunMapSettings = ZO_SavedVars:NewAccountWide("MUNDUSMAP_DB", 1, nil, MunMapdefaults)

        -- Initialize Options Window
        local LAM = LibAddonMenu2

        MunMap.MapPins = CustomMapPins:New()
        MunMap.MapPins:CreatePinType("Mundus_Stone_Pin", MunMap.Settings, MunMap.pinTooltipCreator, MunMap.pinCreator_Mundus)
        MunMap.MapPins:RefreshPins()

        if (MunMapSettings.showMundusStones == false) then
            MunMap.MapPins:enablePins( "Mundus_Stone_Pin", disable )
        else
            MunMap.MapPins:CreatePinType("Mundus_Stone_Pin", MunMap.Settings, MunMap.pinTooltipCreator, MunMap.pinCreator_Mundus)
        end

        -- MundusMap On/Off
        local function GetMundusSetting()
            return MunMapSettings.showMundusStones
        end

        local function FlipMundusSetting()
            if (MunMapSettings.showMundusStones == true) then
                MunMapSettings.showMundusStones = false
            else
                MunMapSettings.showMundusStones = true
                MunMap.MapPins:CreatePinType("Mundus_Stone_Pin", MunMap.Settings, MunMap.pinTooltipCreator, MunMap.pinCreator_Mundus)
            end
            MunMap.MapPins:RefreshPins()
        end

        -- Tamriel Map
        local function GetTamrielSetting()
            return MunMapSettings.showTamrielStones
        end

        local function FlipTamrielSetting()
            if (MunMapSettings.showTamrielStones == true) then
                MunMapSettings.showTamrielStones = false
            else
                MunMapSettings.showTamrielStones = true
                MunMap.MapPins:CreatePinType("Mundus_Stone_Pin", MunMap.Settings, MunMap.pinTooltipCreator, MunMap.pinCreator_Mundus)
            end
            MunMap.MapPins:RefreshPins()
        end

        function MunMap.GetPinType( stoneNumber )
            return "MnMpPin" .. stoneNumber
        end

        function MunMap.RefreshPins( stoneNumber )
            if not stoneNumber then
                ZO_WorldMap_RefreshCustomPinsOfType()
                -- COMPASS_PINS:RefreshPins()
                return
            end
            if stoneNumber >= 1 and stoneNumber <= 13 then
                ZO_WorldMap_RefreshCustomPinsOfType( _G[ MunMap.GetPinType( stoneNumber ) ] )
                --COMPASS_PINS:RefreshPins( MunMap.GetPinType( stoneNumber ) )
            end
        end

        function MunMap.GetFilter( stoneNumber )
            return MunMapSettings.showStoneType[ stoneNumber ]
        end

        function MunMap.SetFilter( stoneNumber, value )
            MunMapSettings.showStoneType[ stoneNumber ] = value
            MunMap.RefreshPins( stoneNumber )
        end

    --============= LAM 2.0 SETIINGS PANEL - BEGIN =================================
        local panelData = {
            type 				= 'panel',
            name 				= "MundusMap",
            displayName 		= "MundusMap",
            author 				= "QuinicAcid, modified by Aruntas & Baertram",
            version 			= "0.25b",
            registerForRefresh 	= true,
            registerForDefaults = true,
            slashCommand = "/mms",
        }
        LAM:RegisterAddonPanel("MundusMap_LAM_2_0_Panel", panelData)

        optionsTable =
        {	-- BEGIN OF OPTIONS TABLE

            [1] = {
                type = 'description',
                text = "MundusMap - Show mundus stones at the Tamriel map",
            },
            [2] = {
                type = 'header',
                name = "Settings",
            },
            [3] = {
                type = "checkbox",
                name = "Show Mundus Stone Locations",
                tooltip = "Turn MundusMap |c00FF00ON|r/|cFF0000OFF|r",
                getFunc = function() return GetMundusSetting() end,
                setFunc = function(value)
                    FlipMundusSetting()
                end,
                default = MunMapSettings.showMundusStones,
                width="half",
            },
            [4] = {
                type = "checkbox",
                name = "Show On Tamriel Map",
                tooltip = "Show Stones on map of Tamriel",
                getFunc = function() return GetTamrielSetting() end,
                setFunc = function(value)
                    FlipTamrielSetting()
                end,
                default = MunMapSettings.showTamrielStones,
                width="half",
                disabled = function() return not MunMapSettings.showMundusStones end,
            },
            [5] = {
                type = 'header',
                name = "Type",
            },
        }
        for stoneNumber = 1,13 do
            --d(MunMapsettings.showStoneType[ stoneNumber ])
            optionsTable[stoneNumber + 5] = {
                type = "checkbox",
                name = MunMap.localization["filter"..stoneNumber],
                tooltip = "|c00CC00"..MunMap.localization["filtertooltip"..stoneNumber].."|r",
                getFunc = function() return MunMap.GetFilter(stoneNumber) end,
                setFunc = function(value)
                    MunMap.SetFilter(stoneNumber, value)
                end,
            default = MunMapSettings.showStoneType[stoneNumber],
            width="full",
            }
        end

    --[[
        optionsTable[19] =	{
                type = 'header',
                name = "Zone",
        },
        optionsTable[20] =  {
                type = "checkbox",
                name = "Cyrodiil",
                tooltip = "Show in Cyrodiil zone",
                getFunc = function() return GetMundus end,
                setFunc = function(value)
                    FlipMundus
                end,
                default = MunMapSettings.showTamrielStones,
                width="half",
        },
        LAM:AddCheckbox(MundusMapMenu, "MundusMap_showCyrodiil", "", "", , )
        LAM:AddCheckbox(MundusMapMenu, "MundusMap_showZone2", "Ebonheart Pact", "Show In This Zone", GetMundus, FlipMundus)
        LAM:AddCheckbox(MundusMapMenu, "MundusMap_showZone3", "Daggerfall Covenant", "Show In This Zone", GetMundus, FlipMundus)
        LAM:AddCheckbox(MundusMapMenu, "MundusMap_showZone4", "Aldmeri Dominion", "Show In This Zone", GetMundus, FlipMundus)
    ]]
        LAM:RegisterOptionControls("MundusMap_LAM_2_0_Panel", optionsTable)
    --============= LAM 2.0 SETIINGS PANEL - END ===================================
    end
end

-- Init MundusMap
function MundusMapInit()
	EVENT_MANAGER:RegisterForEvent("MundusMap", EVENT_ADD_ON_LOADED, OnAddOnLoaded)
end
