SpawnPoints = SpawnPoints or {}

SpawnPoints.name = "SpawnPoints"
SpawnPoints.version = "2025.08.28"
SpawnPoints.displayName = "|cf49b42SpawnPoints|r"
SpawnPoints.author = "|c3CB371@Masteroshi430|r, |c00a313Teebow Ganx|r"
SpawnPoints.website = ""


SpawnPoints.SavedVariablesName = "SpawnPoints_SavedVariables"
SpawnPoints.savedVariablesVersion = 1

SpawnPoints.pinType = "SpawnPoints_Pin_Type"

--Locals -------------------------------------------------------------

local LCLSTR = SpawnPoints.Localization

local pinTextures = {
    [1] = "SpawnPoints/Icons/SpawnPoint.dds",
	[2] = "SpawnPoints/Icons/Tallons.dds",
	[3] = "SpawnPoints/Icons/realistic.dds",
	[4] = "SpawnPoints/Icons/realisticborder.dds",
	[5] = "SpawnPoints/Icons/iconic.dds",
	[6] = "SpawnPoints/Icons/iconicborder.dds",
	[7] = "SpawnPoints/Icons/whiteiconicborder.dds",
}

-- Saved Variables --------------------------------------------------------------

local savedVariables = nil

local defaults = {
	pinTexture = {
			path = pinTextures[6],
			size = 20,
			level = 99,},
	pinColor = { 1, 1, 1, 1 },
	clickable = true,
	suppressLoaded = false,
}

local pinDB = {
	 [1] =  {[1] = 0.5556236173957, [2] = 0.55770519704442,},
	 [2] =  {[1] = 0.5147664109773, [2] = 0.49649239983131,},
	 [3] =  {[1] = 0.52134921198484,[2] = 0.5276523956717,},
	 [4] =  {[1] = 0.53358440929987,[2] = 0.51460159220702,},
	 [5] =  {[1] = 0.54723881174083,[2] = 0.49840959999599,},
	 [6] =  {[1] = 0.55472681541152,[2] = 0.51150399472332,},
	 [7] =  {[1] = 0.54712240922937,[2] = 0.54253359228506,},
	 [8] =  {[1] = 0.57547361713543,[2] = 0.53851400150911,},
	 [9] =  {[1] = 0.61207881935751,[2] = 0.43001199334908,},
	 [10] = {[1] = 0.58811481508075,[2] = 0.42584879173234,},
	 [11] = {[1] = 0.59979041774235,[2] = 0.45008439382253,},
	 [12] = {[1] = 0.57370681380061,[2] = 0.45438319183919,},
	 [13] = {[1] = 0.56720561095896,[2] = 0.46880479191958,},
	 [14] = {[1] = 0.58800761254659,[2] = 0.47092519624731,},
	 [15] = {[1] = 0.59554841818604,[2] = 0.48763999393145,},
	 [16] = {[1] = 0.58346961512047,[2] = 0.49594879114424,},
	 [17] = {[1] = 0.47954680848308,[2] = 0.44162319348745,},
	 [18] = {[1] = 0.49763960987884,[2] = 0.44042919200377,},
	 [19] = {[1] = 0.52296680939066,[2] = 0.4295543923797,},
	 [20] = {[1] = 0.52256000946204,[2] = 0.44328599148138,},
	 [21] = {[1] = 0.51437801100326,[2] = 0.46330399407164,},
	 [22] = {[1] = 0.53062401217715,[2] = 0.46503639539227,},
	 [23] = {[1] = 0.5469580112679, [2] = 0.43970959284741,},
	 [24] = {[1] = 0.49597360932722,[2] = 0.46706279365471,},

}


local PIN_TOOLTIP = {
    tooltip = ZO_MAP_TOOLTIP_MODE.INFORMATION,
    creator = function( pin )
        InformationTooltip:AddLine( "Volendrung Spawn Point" )
    end,
}

local clickHandlers = {
	[1] = {
		name = LCLSTR["CLICK_HANDLER_NAME"],
		show = function(pin) return true end,
		duplicates = function(pin1, pin2) return (pin1.m_PinTag[1] == pin2.m_PinTag[1]) and (pin1.m_PinTag[2] == pin2.m_PinTag[2]) end,
		callback = function(pin) PingMap(MAP_PIN_TYPE_PLAYER_WAYPOINT, MAP_TYPE_LOCATION_CENTERED, pin.normalizedX, pin.normalizedY) end,
	}
}

-- Cache of world -> local coordinate conversions for the world-map pin path.
-- Safe to cache here because this path is only ever reached while
-- PinsShouldBeVisible() holds true, i.e. GetMapType() == MAPTYPE_ZONE and we're
-- on the Cyrodiil zone map, so the projection LibGPS3 uses is constant.
-- Cleared whenever the displayed world map changes (see OnMapChanged below).
local mapPinLocalCoordsCache = {}

local function InvalidateMapPinCoordsCache()
	mapPinLocalCoordsCache = {}
end

local function PinsShouldBeVisible()
	if IsInCyrodiil() == false then return false end -- Not in Cyrodiil? Bye
	if not LibMapPins:IsEnabled(SpawnPoints.pinType) then return false end
	if((GetCurrentMapIndex() ~= GetCyrodiilMapIndex())) then return false end
	if GetMapType() ~= MAPTYPE_ZONE then return false end -- Only show in zone map
	return true
end

local function CreateSettingsMenu()

	local LAM = LibAddonMenu2

	local panelData = {
		type = "panel",
		slashCommand = "/SpawnPointssettings",
		name = SpawnPoints.name,
		displayName = SpawnPoints.displayName,
		author = SpawnPoints.author,
		version = SpawnPoints.version,
		website = SpawnPoints.website,
		donation = SpawnPoints.donation,
		registerForRefresh = true,
		registerForDefaults = true,
	}
	local settingsPanel = LAM:RegisterAddonPanel("SpawnPoints_Pinz", panelData)
	
	local optionsData = {}
	local function AddControl(type, data)
		data.type = type
		optionsData[#optionsData + 1] = data
	end

	local function AddHeader(data) AddControl("header", data) end
	local function AddIconPicker(data) AddControl("iconpicker", data) end
	local function AddSlider(data) AddControl("slider", data) end
	local function AddColorPicker(data) AddControl("colorpicker", data) end
	local function AddCheckbox(data) AddControl("checkbox", data) end
	local function AddDropdown(data) AddControl("dropdown", data) end

	AddHeader({
		name = LCLSTR["SETTINGS_GENERAL_OPTIONS_HEADER"]
	})

	AddCheckbox({
		name = LCLSTR.NAME_SUPPRESS,
		tooltip = LCLSTR.TOOLTIP_SUPPRESS,
		default = false,
		getFunc = function() return savedVariables.suppressLoaded end,
		setFunc = function(newValue) savedVariables.suppressLoaded = newValue end,
	})

	AddIconPicker({
		name = LCLSTR["SETTINGS_MAP_PIN_ICON_LABEL"],
		tooltip = LCLSTR["SETTINGS_MAP_PIN_ICON_DESCRIPTION"],
		choices = pinTextures,
		choicesTooltips = nil, -- pinTexturesList,
		getFunc = function() return savedVariables.pinTexture.path end,
		setFunc = function(selected)
			savedVariables.pinTexture.path = selected
			LibMapPins:SetLayoutKey(SpawnPoints.pinType, "texture", selected)
			LibMapPins:RefreshPins(SpawnPoints.pinType)
		end,
		default = pinTextures[5]
	})

	AddSlider({
		name = LCLSTR["SETTINGS_MAP_PIN_SIZE_LABEL"],
		tooltip = LCLSTR["SETTINGS_MAP_PIN_SIZE_DESCRIPTION"],
		min = 10,
		max = 70,
		getFunc = function() return savedVariables.pinTexture.size end,
		setFunc = function(size)
			savedVariables.pinTexture.size = size
			LibMapPins:SetLayoutKey(SpawnPoints.pinType, "size", size)
			LibMapPins:RefreshPins(SpawnPoints.pinType)
		end,
		default = defaults.pinTexture.size
	})

	AddColorPicker({
		name = LCLSTR["SETTINGS_MAP_PIN_COLOR_LABEL"],
		tooltip = LCLSTR["SETTINGS_MAP_PIN_COLOR_DESCRIPTION"],
		getFunc = function() return unpack(savedVariables.pinColor) end,
		setFunc = function(r,g,b,a)
			savedVariables.pinColor = {r,g,b,a}
			LibMapPins:GetLayoutKey(SpawnPoints.pinType, "tint"):SetRGBA(r,g,b,a)
			LibMapPins:RefreshPins(SpawnPoints.pinType)
		end,
		default = ZO_ColorDef:New(unpack(defaults.pinColor))
	})

	AddCheckbox({
		name = LCLSTR["SETTINGS_CLICKABLE_LABEL"],
		tooltip = LCLSTR["SETTINGS_CLICKABLE_DESCRIPTION"],
		getFunc = function() return savedVariables.clickable end,
		setFunc = function(newValue) 
			savedVariables.clickable = newValue 
			local SpawnClicks = nil
			if savedVariables.clickable == true then SpawnClicks = clickHandlers end		
			LibMapPins:SetClickHandlers(SpawnPoints.pinType, SpawnClicks)		
		end,
		default = defaults.clickable
	})

	LAM:RegisterOptionControls("SpawnPoints_Pinz", optionsData)

end

local settingsResetDialogSetup = false

local function showSettingsResetDialog()
	zo_callLater( function() -- In case it is called by EVENT_ADD_ON_LOADED handler
		if not settingsResetDialogSetup then 
			ZO_Dialogs_RegisterCustomDialog("SpawnPoints_SETTINGS_RESET",
			{
				gamepadInfo =
				{
					dialogType = GAMEPAD_DIALOGS.BASIC,
				},
				title =
				{
					text = "SpawnPoints Settings Reset",
				},
				mainText =
				{
					text = "This new version of SpawnPoints has reset your SpawnPoints addon settings, including the color, size and style of map pins for Volendrung Spawn Points in Cyrodiil. Please open settings and set the pin style again if necessary.",
				},
				buttons =
				{
					{
						text = "OK",
					},
				}
			})
	
			settingsResetDialogSetup = true
		end
	
		ZO_Dialogs_ShowPlatformDialog("SpawnPoints_SETTINGS_RESET", nil, nil)
	end, 1000) 
end

local function CreateCompassPins(pinManager)
	-- Skip the transform work entirely when not even in Cyrodiil; the compass
	-- can refresh far more often than the world map is open, so this check
	-- avoids 24 needless coordinate conversions + pin creations most of the
	-- time a player isn't in Cyrodiil at all.
	if IsInCyrodiil() == false then return end

	for i = 1, #pinDB do
		local pinData = pinDB[i]
		-- Not cached here: unlike the world-map path, we can't guarantee the
		-- compass conversion is always evaluated under the same fixed
		-- MAPTYPE_ZONE context, so we play it safe and compute it fresh.
		local x, y = LibGPS3:GlobalToLocal(pinData[1], pinData[2])
		pinManager:CreatePin(SpawnPoints.pinType, pinData, x, y, "Volendrung Spawn Point")
	end
end

local function CreateMapPins()
	if PinsShouldBeVisible() == false then return end

	for i = 1, #pinDB do
		local pinData = pinDB[i]
		local cached = mapPinLocalCoordsCache[i]
		local x, y
		if cached then
			x, y = cached[1], cached[2]
		else
			x, y = LibGPS3:GlobalToLocal(pinData[1], pinData[2])
			mapPinLocalCoordsCache[i] = { x, y }
		end

		if x > 0 and x < 1 and y > 0 and y < 1 then
			LibMapPins:CreatePin(SpawnPoints.pinType, pinData, x, y)
		end
	end
end

function SpawnPoints.EVENT_ADD_ON_LOADED(eventCode, addOnName)

	if(addOnName ~= SpawnPoints.name) then return end



	savedVariables = ZO_SavedVars:NewAccountWide(SpawnPoints.SavedVariablesName, SpawnPoints.savedVariablesVersion, nil, defaults)

	if savedVariables.settingsVersion == nil then
		-- If we need to show this dialog again in the future, 
		-- savedVariables.settingsVersion will be set to 2 
		-- so figure out what to do if we need to show it again
		savedVariables.settingsVersion = SpawnPoints.savedVariablesVersion -- for this notice, wew set it to 2, current version 
		showSettingsResetDialog()
	end


	local mapPinLayout = {
		level = savedVariables.pinTexture.level,
		texture = savedVariables.pinTexture.path,
		size = savedVariables.pinTexture.size,
		tint = ZO_ColorDef:New(unpack(savedVariables.pinColor))
	}

	LibMapPins:AddPinType(SpawnPoints.pinType, CreateMapPins, nil, mapPinLayout, PIN_TOOLTIP)
	LibMapPins:AddPinFilter(SpawnPoints.pinType, LCLSTR["PIN_FILTER_NAME"], nil, savedVariables.filters)

	-- Add Compass pins too
	local compassPinLayout = { 
		maxDistance = 0.05, 
		texture = savedVariables.pinTexture.path, 
		pinName = "Volendrung Spawn Point"
	}

	COMPASS_PINS:AddCustomPin(SpawnPoints.pinType, CreateCompassPins, compassPinLayout)
	COMPASS_PINS:RefreshPins(SpawnPoints.pinType)

	-- Add nil handler for Left Click
	local SpawnClicks = nil
	if savedVariables.clickable == true then SpawnClicks = clickHandlers end

	LibMapPins:SetClickHandlers(SpawnPoints.pinType, SpawnClicks)
	
	-- These pins only appear in the main Cyrodiil map
	LibMapPins:SetPinFilterHidden(SpawnPoints.pinType, "pve", true)
	LibMapPins:SetPinFilterHidden(SpawnPoints.pinType, "pvp", not PinsShouldBeVisible())
	LibMapPins:SetPinFilterHidden(SpawnPoints.pinType, "imperialPvP", true)
	LibMapPins:SetPinFilterHidden(SpawnPoints.pinType, "battleground", true)

	local function OnMapChanged()
		local shouldHide = not PinsShouldBeVisible()
		-- d(string.format("SpawnPoints.OnMapChanged: Should hide SpawnPoints.pinType == %s", tostring(shouldHide)))
		LibMapPins:SetPinFilterHidden(SpawnPoints.pinType, "pvp", shouldHide)
		-- The displayed map (and therefore the world->local projection) may have
		-- changed, so any cached coordinates are no longer trustworthy.
		InvalidateMapPinCoordsCache()
	end

	CALLBACK_MANAGER:RegisterCallback("OnWorldMapChanged", OnMapChanged)

	CreateSettingsMenu()

	-- Be a good citizen and unregister for load events now
	EVENT_MANAGER:UnregisterForEvent(SpawnPoints.name, EVENT_ADD_ON_LOADED)
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
-- A D D O N   E N T R Y   P O I N T
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
-- It all starts here actually, by registering our event handler to load our Addon
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 

EVENT_MANAGER:RegisterForEvent(SpawnPoints.name, EVENT_ADD_ON_LOADED, SpawnPoints.EVENT_ADD_ON_LOADED)