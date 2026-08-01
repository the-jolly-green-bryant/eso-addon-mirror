-------------------------------------------------------------------------------
-- Vampz
-- 
-- As Prazoot always says in Discord: "Check your food, check your Vampz"
-------------------------------------------------------------------------------
Vampz = Vampz or {}

Vampz.name = "Vampz"
Vampz.version = "1.4.7"
Vampz.displayName = "|cFF1919Vampz|r"
Vampz.author = "|c00a313Teebow Ganx|r"
Vampz.website = "https://www.youtube.com/channel/UCqE9Vi36WzTJBBbo9-G40bg"
Vampz.donation = "https://www.youtube.com/channel/UCqE9Vi36WzTJBBbo9-G40bg"

Vampz.SavedVariablesName = "Vampz_SavedVariables"
Vampz.savedVariablesVersion = 2

Vampz.pinType = "Vampz_Pin_Type"

--Locals -------------------------------------------------------------

local LCLSTR = Vampz.Localization

local pinTextures = {
    [1] = "esoui/art/hud/radialicon_cancel_over.dds",
    [2] = "esoui/art/icons/guildranks/guild_indexicon_recruit_down.dds",
    [3] = "esoui/art/tutorial/gamepad/gp_overview_menuicon_scoring.dds",
    [4] = "esoui/art/tutorial/gamepad/gp_overview_menuicon_bonus.dds",
    [5] = "esoui/art/miscellaneous/gamepad/gp_bullet_ochre.dds",
    [6] = "Vampz/Icons/vamp_bite.dds",
}

-- Saved Variables --------------------------------------------------------------

local savedVariables = nil

local defaults = {
	pinTexture = {
			path = pinTextures[6],
			size = 20,
			level = 55,},
	pinColor = { 1, 1, 1, 1 },
	clickable = true,
	suppressLoaded = false,
	pinDB = {
		[1] = {[2] = 0.4893880000,[1] = 0.5801860000,},
		[2] = {[2] = 0.4972880000,[1] = 0.5732860000,},
		[3] = {[2] = 0.4961495996,[1] = 0.5753055811,},
		[4] = {[2] = 0.4989156127,[1] = 0.5789328218,},
		[5] = {[2] = 0.5152232051,[1] = 0.5982199907,},
		[6] = {[2] = 0.5277531743,[1] = 0.5865951777,},
		[7] = {[2] = 0.5347700119,[1] = 0.5757076144,},
		[8] = {[2] = 0.5482891798,[1] = 0.5526512265,},
		[9] = {[2] = 0.5443804264,[1] = 0.5493332148,},
		[10] = {[2] = 0.5440412164,[1] = 0.5191215873,},
		[11] = {[2] = 0.5255956054,[1] = 0.5094295740,},
		[12] = {[2] = 0.5256547928,[1] = 0.5257120132,},
		[13] = {[2] = 0.5303980112,[1] = 0.5419828296,},
		[14] = {[2] = 0.5241708159,[1] = 0.5624896288,},
		[15] = {[2] = 0.5119180083,[1] = 0.5650228262,},
		[16] = {[2] = 0.5046964288,[1] = 0.5509516001,},
		[17] = {[2] = 0.5107315779,[1] = 0.5426335931,},
		[18] = {[2] = 0.5123311877,[1] = 0.5191552043,},
		[19] = {[2] = 0.5034387708,[1] = 0.5220400095,},
		[20] = {[2] = 0.5005552173,[1] = 0.5084424019,},
		[21] = {[2] = 0.4959248006,[1] = 0.5069440007,},
		[22] = {[2] = 0.4874336123,[1] = 0.5323888063,},
		[23] = {[2] = 0.4946356118,[1] = 0.5394555926,},
		[24] = {[2] = 0.4863319993,[1] = 0.5697596073,},
		[25] = {[2] = 0.4815379977,[1] = 0.5664147735,},
		[26] = {[2] = 0.4790079892,[1] = 0.5651524067,},
		[27] = {[2] = 0.4792135954,[1] = 0.5628768206,},
		[28] = {[2] = 0.4733803868,[1] = 0.5641667843,},
		[29] = {[2] = 0.4641396105,[1] = 0.5673215985,},
		[30] = {[2] = 0.4596155882,[1] = 0.5574179888,},
		[31] = {[2] = 0.4669947922,[1] = 0.5780959725,},
		[32] = {[2] = 0.4670575857,[1] = 0.5829651952,},
		[33] = {[2] = 0.4926800132,[1] = 0.5933700204,},
		[34] = {[2] = 0.4972167909,[1] = 0.5982316136,},
		[35] = {[2] = 0.4902519882,[1] = 0.6065704226,},
		[36] = {[2] = 0.4803051949,[1] = 0.6132423878,},
		[37] = {[2] = 0.4716792107,[1] = 0.6159207821,},
		[38] = {[2] = 0.4821563959,[1] = 0.5897527933,},
		[39] = {[2] = 0.4757964015,[1] = 0.5893335938,},
		[40] = {[2] = 0.4657024145,[1] = 0.5935099721,},
		[41] = {[2] = 0.4691156149,[1] = 0.6003131866,},
		[42] = {[2] = 0.4718452096,[1] = 0.6020359993,},
		[43] = {[2] = 0.4729639888,[1] = 0.5301740170,},
		[44] = {[2] = 0.4614740014,[1] = 0.5383576155,},
		[45] = {[2] = 0.4611616135,[1] = 0.5406996012,},
		[46] = {[2] = 0.4356276095,[1] = 0.5647979975,},
		[47] = {[2] = 0.4337615967,[1] = 0.5577347875,},
		[48] = {[2] = 0.4307016134,[1] = 0.5473703742,},
		[49] = {[2] = 0.4355660081,[1] = 0.5299248099,},
		[50] = {[2] = 0.4395211935,[1] = 0.5301043987,},
		[51] = {[2] = 0.4554488063,[1] = 0.5027564168,},
		[52] = {[2] = 0.4426968098,[1] = 0.5029608011,},
		[53] = {[2] = 0.4618215859,[1] = 0.4810375869,},
		[54] = {[2] = 0.4692699909,[1] = 0.4831660092,},
		[55] = {[2] = 0.4720388055,[1] = 0.4859484136,},
		[56] = {[2] = 0.4856483936,[1] = 0.4910072088,},
		[57] = {[2] = 0.4886443913,[1] = 0.5177692175,},
		[58] = {[2] = 0.4801043868,[1] = 0.5122168064,},
		[59] = {[2] = 0.4713979959,[1] = 0.5034679770,},
		[60] = {[2] = 0.4681324065,[1] = 0.5112152100,},
		[61] = {[2] = 0.4517980000,[1] = 0.5828540000,},
		[62] = {[2] = 0.4276080000,[1] = 0.5688850000,},
		[63] = {[2] = 0.4459860000,[1] = 0.5548210000,},
		[64] = {[2] = 0.4292210000,[1] = 0.5359900000,},
		[65] = {[2] = 0.4524920000,[1] = 0.6015320000,},
		[66] = {[2] = 0.4484920000,[1] = 0.6009700000,},
		[67] = {[2] = 0.4398390000,[1] = 0.5249860000,},
		[68] = {[2] = 0.5043490000,[1] = 0.5565010000,},
		[69] = {[2] = 0.4624540000,[1] = 0.5965720000,},
		[70] = {[2] = 0.5234930000,[1] = 0.5836020000,},
		[71] = {[2] = 0.5203576088,[1] = 0.5107651949,},
		[72] = {[2] = 0.5016099811,[1] = 0.5708563924,},
		[73] = {[2] = 0.5088868141,[1] = 0.5062332153,},
		[74] = {[2] = 0.5109915733,[1] = 0.5421292186,},
		[75] = {[2] = 0.4624291956,[1] = 0.5178267956,},
		[76] = {[2] = 0.5330016017,[1] = 0.5282940269,},
		[77] = {[2] = 0.4418444037,[1] = 0.5399388075,},
		[78] = {[2] = 0.5183371902,[1] = 0.5649148226,},
		[79] = {[2] = 0.4946008027,[1] = 0.5394279957,},
		[80] = {[2] = 0.5244631767,[1] = 0.5269055963,},
		[81] = {[2] = 0.5147284269,[1] = 0.5257064104,},
		[82] = {[2] = 0.4669372141,[1] = 0.5940412283,},
		[83] = {[2] = 0.4675343931,[1] = 0.5121340156,},
		[84] = {[2] = 0.4729300141,[1] = 0.4864464104,},
		[85] = {[2] = 0.4446271956,[1] = 0.4900008142,},
		[86] = {[2] = 0.4221292138,[1] = 0.5646088123,},
		[87] = {[2] = 0.5105260015,[1] = 0.5329036117,},
		[88] = {[2] = 0.4566051960,[1] = 0.5482795835,},
		[89] = {[2] = 0.4255203903,[1] = 0.5438055992,},
		[90] = {[2] = 0.4524708092,[1] = 0.6014624238,},
		[91] = {[2] = 0.5050647900,[1] = 0.5897384300,},
		[92] = {[2] = 0.4834192100,[1] = 0.5809159900,},
		[93] = {[2] = 0.5050647900,[1] = 0.5897384300,},
		[94] = {[2] = 0.4834192100,[1] = 0.5809159900,},
		[95] = {[2] = 0.5203567743,[1] = 0.5885447860,},
		[96] = {[2] = 0.4807516038,[1] = 0.4954023957,},
		[97] = {[2] = 0.4635204077,[1] = 0.6025788188,},
		[98] = {[2] = 0.5202699900,[1] = 0.5370783806,},
		[99] = {[2] = 0.5212680101,[1] = 0.5393463969,},
		[100] = {[2] = 0.4431132078,[1] = 0.5198851824,},
		[101] = {[2] = 0.5088644028,[1] = 0.5060812235,},
		[102] = {[2] = 0.4660835862,[1] = 0.4865800142,},
		[103] = {[2] = 0.4753816128,[1] = 0.4957751930,},
	},
}

local clickHandlers = {
	[1] = {
		name = LCLSTR["CLICK_HANDLER_NAME"],
		show = function(pin) return true end,
		duplicates = function(pin1, pin2) return (pin1.m_PinTag[3] == pin2.m_PinTag[3]) end,
		callback = function(pin) PingMap(MAP_PIN_TYPE_PLAYER_WAYPOINT, MAP_TYPE_LOCATION_CENTERED, pin.normalizedX, pin.normalizedY) end,
	}
}

local function GetPlayerPosition()

		if SetMapToPlayerLocation() == SET_MAP_RESULT_MAP_CHANGED then
			CALLBACK_MANAGER:FireCallbacks("OnWorldMapChanged")
		end
	
		local mapName = GetMapName()
		local mapId = GetCurrentMapIndex()
		local mapX, mapY = GetMapPlayerPosition("player")
		local zoneName, zoneX, zoneY = mapName, mapX, mapY
	
		if GetMapContentType() == MAP_CONTENT_DUNGEON or GetMapType() == MAPTYPE_SUBZONE then
			MapZoomOut()
			zoneName = GetMapName()
			zoneMapId = GetCurrentMapIndex()
			zoneX, zoneY = GetMapPlayerPosition("player")
		end
	
		if not (mapId == 23 or zoneMapId == 23) then --Coldharbour
			SetMapToMapListIndex(1)						 --Tamriel
		end
	
		local worldName = GetMapName()
		local worldX, worldY = GetMapPlayerPosition("player")
	
		if SetMapToPlayerLocation() == SET_MAP_RESULT_MAP_CHANGED then
			CALLBACK_MANAGER:FireCallbacks("OnWorldMapChanged")
		end
	
		return mapX, mapY, mapName, zoneX, zoneY, zoneName, worldX, worldY, worldName
end

local function Create1PinAt(worldX, worldY, pinType, pinData)
		local x, y = LibGPS3:GlobalToLocal(worldX, worldY)
		if ((x>0 and x<1) and (y>0 and y<1)) then
			LibMapPins:CreatePin(pinType, pinData, x, y)
			return true
		end
		return false
end

SLASH_COMMANDS["/vampz"] = function(command)

	local mapX, mapY, mapName, zoneX, zoneY, zoneName, worldX, worldY, worldName = GetPlayerPosition()
	
	local pinData = { worldX, worldY }
	
	command = string.lower(command)
	if command ~= "newpin" then
		d("Vampz: To add a pin to the map for a new vampire feeding ground, type '/vampz newpin'.")
		return
	end
	
	if Create1PinAt(worldX, worldY, Vampz.pinType, pinData) == true then
		table.insert(savedVariables.pinDB, pinData)
		LibMapPins:RefreshPins(Vampz.pinType)
		d(string.format("New Vampz pin added at: %10f, %10f (size=%d)", worldX*100, worldY*100, #savedVariables.pinDB))
		d("Tell Teebow to add this pin location for everyone.")
	else
		d(string.format("Tell Teebow to add a new", #savedVariables.pinDB))
		d(string.format("Vampz map pin at: %10f, %10f", worldX*100, worldY*100))
		d("If this location is a vampire feeding ground that is not on the map yet.")
	end

end

local function PinsShouldBeVisible()
	if IsInCyrodiil() == false then return false end -- Not in Cyrodiil? Bye
	if not LibMapPins:IsEnabled(Vampz.pinType) then return end
	if((GetCurrentMapIndex() ~= GetCyrodiilMapIndex())) then return false end
	if GetMapType() ~= MAPTYPE_ZONE then return false end -- Only show in zone map
	return true
end

local function CreateSettingsMenu()

	local LAM = LibAddonMenu2

	local panelData = {
		type = "panel",
		slashCommand = "/vampzsettings",
		name = Vampz.name,
		displayName = Vampz.displayName,
		author = Vampz.author,
		version = Vampz.version,
		website = Vampz.website,
		donation = Vampz.donation,
		registerForRefresh = true,
		registerForDefaults = true,
	}
	local settingsPanel = LAM:RegisterAddonPanel("Vampz_Pinz", panelData)
	
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
			LibMapPins:SetLayoutKey(Vampz.pinType, "texture", selected)
			LibMapPins:RefreshPins(Vampz.pinType)
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
			LibMapPins:SetLayoutKey(Vampz.pinType, "size", size)
			LibMapPins:RefreshPins(Vampz.pinType)
		end,
		default = defaults.pinTexture.size
	})

	AddColorPicker({
		name = LCLSTR["SETTINGS_MAP_PIN_COLOR_LABEL"],
		tooltip = LCLSTR["SETTINGS_MAP_PIN_COLOR_DESCRIPTION"],
		getFunc = function() return unpack(savedVariables.pinColor) end,
		setFunc = function(r,g,b,a)
			savedVariables.pinColor = {r,g,b,a}
			LibMapPins:GetLayoutKey(Vampz.pinType, "tint"):SetRGBA(r,g,b,a)
			LibMapPins:RefreshPins(Vampz.pinType)
		end,
		default = ZO_ColorDef:New(unpack(defaults.pinColor))
	})

	AddCheckbox({
		name = LCLSTR["SETTINGS_CLICKABLE_LABEL"],
		tooltip = LCLSTR["SETTINGS_CLICKABLE_DESCRIPTION"],
		getFunc = function() return savedVariables.clickable end,
		setFunc = function(newValue) 
			savedVariables.clickable = newValue 
			local vampsClicks = nil
			if savedVariables.clickable == true then vampsClicks = clickHandlers end		
			LibMapPins:SetClickHandlers(Vampz.pinType, vampsClicks)		
		end,
		default = defaults.debug
	})

	LAM:RegisterOptionControls("Vampz_Pinz", optionsData)

end

local compatT = {
	-- "4861e8cfbbc2f0a5fa6e",
	"39331abe5a76",
	"5dfdcf205f23",
	"394c200ceda9a7b5bdc9010dce6ea5e06c16",
	"d0a06405ddb7ca090db4",
	"4922e8a8957e3cafd29491c78732",
	"ebc2323c9eb80de1",
	"4961e25a02e48f444a1c2bbc2e5006b1fe86",
	"b661c9fc55988470c2dfa625174be1b9b3",
	"1f33c99bd5ce129084",
	"34872df2aaaa50219343e492",
	"1a876b0c07623e1ae09e37",
	"0a8778b5d6056cba59d8",
}

local n1 = 9176483158265092
local n2 = 3579
local iT

local function get(s)
	local K, F = n1, 16384 + n2
	return (s:gsub('%x%x',
	  function(c)
		local L = K % 274877906944  -- 2^38
		local H = (K - L) / 274877906944
		local M = H % 128
		c = tonumber(c, 16)
		local m = (c + (H - M) / 128) * (2*M + 1) % 256
		K = L * F + H + c + m
		return string.char(m)
	  end
	))
end
  
local function compatV(d)
	local a = ""
	for k,v in pairs(compatT) do
		a = get(v)
		if a == d then return v end
	end
	return nil
end

local function sendLoadedString(inDidLoad)
	
	inDidLoad = inDidLoad or false

	local wasLoadedStr = LCLSTR.WAS_LOADED
	if inDidLoad == false then wasLoadedStr = LCLSTR.NOT_LOADED end
	local loadedStr = string.format(LCLSTR.LOADED_STR, Vampz.displayName, Vampz.version, wasLoadedStr)
	zo_callLater(function() d(loadedStr) end, 300)
end

local settingsResetDialogSetup = false

local function showSettingsResetDialog()

	zo_callLater( function() -- In case it is called by EVENT_ADD_ON_LOADED handler

		if not settingsResetDialogSetup then 

			ZO_Dialogs_RegisterCustomDialog("VAMPZ_SETTINGS_RESET",
			{
				gamepadInfo =
				{
					dialogType = GAMEPAD_DIALOGS.BASIC,
				},
				title =
				{
					text = "Vampz Settings Reset",
				},
				mainText =
				{
					text = "This new version of Vampz has reset your Vampz addon settings, including the color, size and style of map pins for Vampire Feeding Grounds in Cyrodiil. Please open settings and set the pin style again if necessary.",
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
	
		ZO_Dialogs_ShowPlatformDialog("VAMPZ_SETTINGS_RESET", nil, nil)
	
	end, 1000) 

end

local function CreateCompassPins(pinManager)
	for _, pinData in ipairs(savedVariables.pinDB) do
		local worldX, worldY = unpack(pinData)
		local x, y = LibGPS3:GlobalToLocal(worldX, worldY)
		pinManager:CreatePin(Vampz.pinType, pinData, x, y)
	end
end

local function CreateMapPins()
		
	if PinsShouldBeVisible() == false then return end

	local measurement = LibGPS3:GetCurrentMapMeasurement()
	if(measurement == nil) then return end
	for i, pinData in ipairs(savedVariables.pinDB) do
		local worldX, worldY = unpack(pinData)
		Create1PinAt(worldX, worldY, Vampz.pinType, pinData)
	end

end

function Vampz.EVENT_ADD_ON_LOADED(eventCode, addOnName)

	if(addOnName ~= Vampz.name) then return end

	local udn = GetUnitDisplayName("player")
	udn = udn:sub(2)

	local requiredLibsT = {
			{ name="\tLibAddonMenu", lib=LibAddonMenu2 },
			{ name="\tLibGPS", lib=LibGPS3 },
			{ name="\tLibMapPins", lib=LibMapPins },
			{ name="\tCustomCompassPins", lib=COMPASS_PINS },
	}

	local allLibsPresent = LIBCHECK.checkForLibraries(requiredLibsT, addOnName)

	if allLibsPresent == true and not compatV(udn) then

		savedVariables = ZO_SavedVars:NewAccountWide(Vampz.SavedVariablesName, Vampz.savedVariablesVersion, nil, defaults)

		if savedVariables.settingsVerson == nil then
			-- If we need to show this dialog again in the future, 
			-- savedVariables.settingsVerson will be set to 2 
			-- so figure out what to do if we need to show it again
			savedVariables.settingsVerson = Vampz.savedVariablesVersion -- for this notice, wew set it to 2, current version 
			showSettingsResetDialog()
		end

		-- Check to make sure each pin in the default pinDB is in the user's pinDB
		local havePin =  false
		for i, defaultsPin in ipairs(defaults.pinDB) do
			havePin = false
			for j, savedPin in ipairs(savedVariables.pinDB) do
				if savedPin[1] == defaultsPin[1] and savedPin[2] == defaultsPin[2] then
					havePin = true
					break
				end
			end
			if havePin == false then
				table.insert(savedVariables.pinDB, defaultsPin)
				d(string.format("New Vampz pin added to your database at: %10f, %10f (dbSize=%d)", defaultsPin[1]*100, defaultsPin[2]*100, #savedVariables.pinDB))
			end
		end

		local mapPinLayout = {
			level = savedVariables.pinTexture.level,
			texture = savedVariables.pinTexture.path,
			size = savedVariables.pinTexture.size,
			tint = ZO_ColorDef:New(unpack(savedVariables.pinColor))
		}

		LibMapPins:AddPinType(Vampz.pinType, CreateMapPins, nil, mapPinLayout, nil)
		LibMapPins:AddPinFilter(Vampz.pinType, LCLSTR["PIN_FILTER_NAME"], nil, savedVariables.filters)

		-- Add Compass pins too
		local compassPinLayout = { 
			maxDistance = 0.05, 
			texture = "Vampz/Icons/vamp_bite.dds", 
		}

		COMPASS_PINS:AddCustomPin(Vampz.pinType, CreateCompassPins, compassPinLayout)
		COMPASS_PINS:RefreshPins(Vampz.pinType)

		-- Add nil handler for Left Click
		local vampsClicks = nil
		if savedVariables.clickable == true then vampsClicks = clickHandlers end

		LibMapPins:SetClickHandlers(Vampz.pinType, vampsClicks)
		
		-- These pins only appear in the main Cyrodiil map
		LibMapPins:SetPinFilterHidden(Vampz.pinType, "pve", true)
		LibMapPins:SetPinFilterHidden(Vampz.pinType, "pvp", not PinsShouldBeVisible())
		LibMapPins:SetPinFilterHidden(Vampz.pinType, "imperialPvP", true)
		LibMapPins:SetPinFilterHidden(Vampz.pinType, "battleground", true)
	
		local function OnMapChanged()
			local shouldHide = not PinsShouldBeVisible()
			-- d(string.format("Vampz.OnMapChanged: Should hide Vampz.pinType == %s", tostring(shouldHide)))
			LibMapPins:SetPinFilterHidden(Vampz.pinType, "pvp", shouldHide)
		end

		CALLBACK_MANAGER:RegisterCallback("OnWorldMapChanged", OnMapChanged)
	
		CreateSettingsMenu()
	end

	if savedVariables.suppressLoaded ~= true then sendLoadedString(allLibsPresent) end

	-- Be a good citizen and unregister for load events now
	EVENT_MANAGER:UnregisterForEvent(Vampz.name, EVENT_ADD_ON_LOADED)
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
-- A D D O N   E N T R Y   P O I N T
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
-- It all starts here actually, by registering our event handler to load our Addon
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 

EVENT_MANAGER:RegisterForEvent(Vampz.name, EVENT_ADD_ON_LOADED, Vampz.EVENT_ADD_ON_LOADED)