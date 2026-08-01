--Local constants
AHUD = {}
local AHUD_Name = "ArmorHUD"
local AHUD_Version = "1.3.3"

local previewhud = false

--Sets the HUD up
function AHUD:Initialize()

	--Setup Items
	AHUD.Item:Init()
	
	--Create Settings Menu
	AHUD.CreateSettingsMenu()
	
	-- Register the slash command handler
	SLASH_COMMANDS["/ahud"] = AHUD.Commands
	SLASH_COMMANDS["/ahudh"] = AHUD.Hide
	SLASH_COMMANDS["/ahudv"] = AHUD.Version
	
	-- Fire a callback after setup
	CALLBACK_MANAGER:FireCallbacks("AHUD_Ready")
end

--Calls an Update
local function AHUD_Update()
	AHUD.Item:Update()
end

--Loads the Addon
function AHUD.OnAddOnLoaded(event, addonName)
  if addonName == AHUD_Name then
    AHUD:Initialize()
	EVENT_MANAGER:RegisterForUpdate("AHUD_Update", 1000, AHUD_Update)
	EVENT_MANAGER:RegisterForUpdate("AHUD_Welcome",2000, AHUD.Welcome)
  end
end

function AHUD.Welcome(event, addonName)
	d("|c008000ArmorHUD|r loaded. Type |cFFFFFF/ahud|r for more infos")
	EVENT_MANAGER:UnregisterForUpdate("AHUD_Welcome")
end

--Displays shlash commands
function AHUD.Commands( text )
d("ArmorHUD slash commands:")
d("|cFFFFB0Hides ArmorHUD:|r |cFFFFFF/ahudh|r")
d("|cFFFFB0Displays version:|r |cFFFFFF/ahudv|r")
end

-- Display the current version
function AHUD.Version( text )
	d("You are using |c008000ArmorHUD|r version |cFFFFFF" .. AHUD_Version .."|r")
end

--Hides the addon
function AHUD.Hide( text )
	if(AHUD.Item.savedVariables.Hiden) then 
		AHUD.Item.savedVariables.Hiden = false
	else
		AHUD.Item.savedVariables.Hiden = true
	end
	AHUD.Item.Control:SetHidden(AHUD.Item.savedVariables.Hiden)
end

--Creates settings menu
function AHUD.CreateSettingsMenu()

	local LAM = LibAddonMenu2
	
	if LAM == nil and LibStub then LAM = LibStub("LibAddonMenu-2.0") end
	
	if LAM == nil then return end

	local panelData = {
		type = "panel",
		name = AHUD_Name,
		displayName = "|cFFFFB0" .. AHUD_Name .. "|r",
		author =  "|cFFA500 Dankin0815 |r ",
		version = AHUD_Version,
		slashCommand = "/ahud",
		registerForRefresh = true,
		registerForDefaults = true,
	}
	LAM:RegisterAddonPanel(AHUD_Name, panelData)
	
	local optionsTable = {
		{
			type = "checkbox",
			name = GetString(AHUD_PREVIEW),
			tooltip = GetString(AHUD_PREVIEW_DESC),
			getFunc = function() return previewhud end,
			setFunc = function(value) 
			if value then 					
				AHUD.Item.Control:SetHidden(false)				
			else 					
				AHUD.Item.Control:SetHidden(true)				
			end 				 				
			previewhud = value 
			end,
		},
		{
			type = "checkbox",
			name = GetString(AHUD_SHOWTEXT),
			tooltip = GetString(AHUD_SHOWTEXT_DESC),
			getFunc = function() return AHUD.Item.savedVariables.HideText end,
			setFunc = function(value) AHUD.Item.savedVariables.HideText = value end,
			default = function() return AHUD.Item.Default.HideText end,
        },
		{
			type = "colorpicker",
			name = GetString(AHUD_PERFECT),
			tooltip = GetString(AHUD_PERFECT_DESC),
			getFunc = function() return unpack(AHUD.Item.savedVariables.ColorPerfect) end,
			setFunc = function(r,g,b,a) AHUD.Item.savedVariables.ColorPerfect = {r,g,b,a} end,
			default = {r = AHUD.Item.Default.ColorPerfect[1], g = AHUD.Item.Default.ColorPerfect[2], b = AHUD.Item.Default.ColorPerfect[3], a = AHUD.Item.Default.ColorPerfect[4]},
		},
		{
			type = "colorpicker",
			name = GetString(AHUD_GOOD),
			tooltip = GetString(AHUD_GOOD_DESC),
			getFunc = function() return unpack(AHUD.Item.savedVariables.ColorWell) end,
			setFunc = function(r,g,b,a) AHUD.Item.savedVariables.ColorWell = {r,g,b,a} end,
			default = {r = AHUD.Item.Default.ColorWell[1], g = AHUD.Item.Default.ColorWell[2], b = AHUD.Item.Default.ColorWell[3], a = AHUD.Item.Default.ColorWell[4]},
		}
		,
		{
			type = "colorpicker",
			name = GetString(AHUD_ACCEPTABLE),
			tooltip = GetString(AHUD_ACCEPTABLE_DESC),
			getFunc = function() return unpack(AHUD.Item.savedVariables.ColorAcceptable) end,
			setFunc = function(r,g,b,a) AHUD.Item.savedVariables.ColorAcceptable = {r,g,b,a} end,
			default = {r = AHUD.Item.Default.ColorAcceptable[1], g = AHUD.Item.Default.ColorAcceptable[2], b = AHUD.Item.Default.ColorAcceptable[3], a = AHUD.Item.Default.ColorAcceptable[4]},
		}
		,
		{
			type = "colorpicker",
			name = GetString(AHUD_BAD),
			tooltip = GetString(AHUD_BAD_DESC),
			getFunc = function() return unpack(AHUD.Item.savedVariables.ColorBad) end,
			setFunc = function(r,g,b,a) AHUD.Item.savedVariables.ColorBad = {r,g,b,a} end,
			default = {r = AHUD.Item.Default.ColorBad[1], g = AHUD.Item.Default.ColorBad[2], b = AHUD.Item.Default.ColorBad[3], a = AHUD.Item.Default.ColorBad[4]},
		}
		,
		{
			type = "colorpicker",
			name = GetString(AHUD_BROCKEN),
			tooltip = GetString(AHUD_BROCKEN_DESC),
			getFunc = function() return unpack(AHUD.Item.savedVariables.ColorBrocken) end,
			setFunc = function(r,g,b,a) AHUD.Item.savedVariables.ColorBrocken = {r,g,b,a} end,
			default = {r = AHUD.Item.Default.ColorBrocken[1], g = AHUD.Item.Default.ColorBrocken[2], b = AHUD.Item.Default.ColorBrocken[3], a = AHUD.Item.Default.ColorBrocken[4]},
		},
		{
			type = "slider",
			name = GetString(AHUD_ICONSIZE),
			tooltip = GetString(AHUD_ICONSIZE_DESC),
			min = 32,
			max = 64,
			step = 1,
			getFunc = function() return AHUD.Item.savedVariables.IconSize end,
			setFunc = function(value) AHUD.Item.savedVariables.IconSize = value end,
			default = AHUD.Item.Default.IconSize,
			warning = GetString(AHUD_ICONSIZE_WARN),
		}
	}
	LAM:RegisterOptionControls(AHUD_Name, optionsTable)
end

--Register Event
EVENT_MANAGER:RegisterForEvent(AHUD.name, EVENT_ADD_ON_LOADED, AHUD.OnAddOnLoaded)

--Add Binding
ZO_CreateStringId("SI_BINDING_NAME_Armor_HUD", "Toggle ON/OFF")