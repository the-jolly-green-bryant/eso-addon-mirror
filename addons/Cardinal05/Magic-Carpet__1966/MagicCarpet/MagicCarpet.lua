------[[ Namespaces ]]------

if not MagicCarpet then MagicCarpet = { } end
local MC = MagicCarpet
if not Mag then Mag = MagicCarpet end

local LAM

------[[ Constants ]]------

local CONST = { }
MC.CONST = CONST

CONST.ADDON_NAME = "MagicCarpet"
CONST.ADDON_TITLE = "Magic Carpet"
CONST.ADDON_TITLE_SHORT = "Magic Carpet"
CONST.ADDON_VERSION = "5.0"
CONST.ADDON_AUTHOR = "@Cardinal05, @Architectura"
CONST.ADDON_SETTINGS_VERSION = 1

CONST.SAVED_VARS_NAME = "MagicCarpetSavedVars"
CONST.SAVED_VARS_VERSION = 3
CONST.SAVED_VARS_DEFAULTS = {
	EarnedTrophies = { },
	Settings = {
		AscendBehavior = "Toggle",
		DescendBehavior = "Toggle",
		EnableKeybindReminder = true,
		Featherfall = true,
		FeatherfallSensitivity = 1,
		IdleAnimations = true,
		MostRecentMode = "",
		OffsetY = 0,
		PanoramaView = true,
		SearchBackpackItems = true,
		SearchBankItems = true,
		SearchHouseItems = true,
		SearchHouseItemsDistance = 100,
		RefreshInterval = 100,
		RememberModeForEachHome = true,
	}
}

CONST.SLASH_COMMAND_STRING = "/mag"
CONST.SLASH_COMMAND_SETTINGS_STRING = "/magsetup"

CONST.MIN_OFFSET_Y = -200
CONST.MAX_OFFSET_Y = 200

CONST.MIN_ITEM_DISTANCE = 20
CONST.MAX_ITEM_DISTANCE = 100

CONST.MAX_IDLE_TIMER = 1000 * 60
CONST.MAX_LATENCY_MS = 150


------[[ Variables ]]------


local vars = { }
MC.Vars = vars


------[[ Setup ]]------


function MC.Initialize()

	ZO_CreateStringId( "SI_BINDING_NAME_MAGICCARPET_TOGGLE_STATE", "Toggle Magic Carpet On/Off" )
	ZO_CreateStringId( "SI_BINDING_NAME_MAGICCARPET_SUSPEND_RESUME", "Suspend/Resume Magic Carpet" )
	ZO_CreateStringId( "SI_BINDING_NAME_MAGICCARPET_ASCEND", "Ascend" )
	ZO_CreateStringId( "SI_BINDING_NAME_MAGICCARPET_DESCEND", "Descend" )

	vars = ZO_SavedVars:NewAccountWide( CONST.SAVED_VARS_NAME, CONST.SAVED_VARS_VERSION, nil, CONST.SAVED_VARS_DEFAULTS )
	MC.Vars = vars
	MC.Vars.Settings.OffsetY = 0

	SLASH_COMMANDS[ CONST.SLASH_COMMAND_STRING ] = MC.SlashCommand

	MC.CleanVars()
	MC.SetupSettingsMenu()
	MC.GameSettings.RestoreAllSettings()
	MC.Engine:Initialize()

end


function MC.ResetTrophies()

	MC.Vars.EarnedTrophies = { }

end


function MC.ResetSettings()

	MC.Vars.Settings = { }

end


function MC.ResetData( trophies, settings )

	if trophies then MC.ResetTrophies() end
	if settings then MC.ResetSettings() end
	ReloadUI()

end


function MC.SetupSettingsMenu()

	LAM = LibAddonMenu2

	local panel = {
		type = "panel",
		author = CONST.ADDON_AUTHOR,
		name = CONST.ADDON_TITLE,
		displayName = CONST.ADDON_TITLE,
		version = CONST.ADDON_VERSION,
		slashCommand = CONST.SLASH_COMMAND_SETTINGS_STRING,
		registerForRefresh = true,
		registerForDefaults = true
	}

	MC.LamPanel = LAM:RegisterAddonPanel( "MagicCarpetSettings", panel )

	local options = { }


	table.insert( options, {
		type = "header",
		name = "Vehicle Assembly",
	} )

	table.insert( options, {
		type = "checkbox",
		name = "Assemble with Inventory Items**",
		tooltip = "When enabled, your vehicles will be constructed using items found in your character's inventory whenever possible.\n\n" ..
			"** Note that assembly from Inventory items is only available in homes that you own.",
		getFunc = function() return MC.Vars.Settings.SearchBackpackItems end,
		setFunc = function(value) MC.Vars.Settings.SearchBackpackItems = value end,
		default = CONST.SAVED_VARS_DEFAULTS.Settings.SearchBackpackItems,
		disabled = false,
	} )

	table.insert( options, {
		type = "checkbox",
		name = "Assemble with Bank Items**",
		tooltip = "When enabled, your vehicles will be constructed using items found in your personal bank whenever possible.\n\n" ..
			"** Note that assembly from Bank items is only available in homes that you own.",
		getFunc = function() return MC.Vars.Settings.SearchBankItems end,
		setFunc = function(value) MC.Vars.Settings.SearchBankItems = value end,
		default = CONST.SAVED_VARS_DEFAULTS.Settings.SearchBankItems,
		disabled = false,
	} )

	table.insert( options, {
		type = "checkbox",
		name = "Assemble with House Items",
		tooltip = "When enabled, your vehicles will be constructed using items found in the current house whenever possible.",
		getFunc = function() return MC.Vars.Settings.SearchHouseItems end,
		setFunc = function(value) MC.Vars.Settings.SearchHouseItems = value end,
		default = CONST.SAVED_VARS_DEFAULTS.Settings.SearchHouseItems,
		disabled = false,
	} )

	table.insert( options, {
		type = "header",
		name = "Vehicle Handling",
	} )

	table.insert( options, {
		type = "dropdown",
		name = "Ascend Behavior",
		choices = { "Hold Down", "Toggle" },
		tooltip = "Determines whether the 'Ascend' key must be held down to ascend or whether each tap of the key toggles Ascension ON or OFF.",
		getFunc = function() return MC.Vars.Settings.AscendBehavior end,
		setFunc = function(value) MC.Vars.Settings.AscendBehavior = value end,
		default = CONST.SAVED_VARS_DEFAULTS.Settings.AscendBehavior,
		disabled = false,
	} )

	table.insert( options, {
		type = "dropdown",
		name = "Descend Behavior",
		choices = { "Hold Down", "Toggle" },
		tooltip = "Determines whether the 'Descend' key must be held down to descend or whether each tap of the key toggles Descension ON or OFF.",
		getFunc = function() return MC.Vars.Settings.DescendBehavior end,
		setFunc = function(value) MC.Vars.Settings.DescendBehavior = value end,
		default = CONST.SAVED_VARS_DEFAULTS.Settings.DescendBehavior,
		disabled = false,
	} )
--[[
	table.insert( options, {
		type = "checkbox",
		name = "Vertical Adjustment",
		tooltip = "When enabled, you may change the Vertical Adjustment of the Magic Carpet using the setting below or by clicking the Up/Down arrows on the MC button while a carpet is active.",
		warning = "This setting should only be enabled if you need to adjust the Magic Carpet height for Cosmetic modes. It is strongly advised that this setting remain OFF otherwise.",
		isDangerous = true,
		getFunc = function() return MC.Vars.Settings.AllowVerticalAdjustment end,
		setFunc = function(value) MC.Vars.Settings.AllowVerticalAdjustment = value end,
		default = false,
		disabled = false,
	} )

	table.insert( options, {
		type = "slider",
		name = "Vertical Adjustment (centimeters)",
		tooltip = "This setting can be used to raise or lower the vehicle by adjusting the distance (in centimeters) from your feet to the vehicle.\n\n" ..
			"You may also adjust the vehicle's height while flying by using the up and down arrow buttons on the Magic Carpet button.\n\n" ..
			"Note: A positive distance raises the vehicle; A negative distance lowers the vehicle.\n" ..
			"The default is 0 centimeters.",
		autoSelect = true,
		clampInput = true,
		decimals = 0,
		step = 1,
		min = CONST.MIN_OFFSET_Y,
		max = CONST.MAX_OFFSET_Y,
		getFunc = function() return ( MC.Vars.Settings.OffsetY or 0 ) end,
		setFunc = function(value) MC.Vars.Settings.OffsetY = value end,
		default = CONST.SAVED_VARS_DEFAULTS.Settings.OffsetY,
		disabled = function() return not MC.Vars.Settings.AllowVerticalAdjustment end,
	} )
]]
	table.insert( options, {
		type = "checkbox",
		name = "Auto Adjust Camera",
		tooltip = "When enabled, your camera will automatically be adjusted to the distance and height that is recommended " ..
			"for the current Magic Carpet mode.\n\n" ..
			"Note: Your current camera distance and vertical offset are automatically restored when you turn the carpet OFF.",
		getFunc = function()
			if nil == MC.Vars.Settings.AutoAdjustCamera then
				return true
			else
				return MC.Vars.Settings.AutoAdjustCamera
			end
		end,
		setFunc = function(value)
			MC.Vars.Settings.AutoAdjustCamera = value
			if not value then
				MC.GameSettings:RestoreAllSettings()
			end
		end,
		default = true,
		disabled = false,
	} )


	table.insert( options, {
		type = "header",
		name = "Vehicle Performance",
	} )

	table.insert( options, {
		type = "dropdown",
		name = "Refresh Rate",
		--choices = { "Very High", "High", "Medium", "Low", "Very Low" },
		choices = { "High", "Medium", "Low", "Very Low" },
		tooltip = "Determines the rate at which your vehicle's position is synchronized with your character's position.\n\n" ..
			"Higher refresh rates should furnish greater stability and responsiveness, but may cause framerate drops or disconnects in very high latency conditions. " ..
			"If you experience these issues, select a lower refresh rate.",
		getFunc = function()
			local interval = MC.Vars.Settings.RefreshInterval or 0
			--if 75 >= interval then return "Very High"
			--elseif 100 >= interval then return "High"
			if 100 >= interval then return "High"
			elseif 125 >= interval then return "Medium"
			elseif 150 >= interval then return "Low"
			else return "Very Low" end
		end,
		setFunc = function(value)
			local interval = 100
			--if "Very High" == value then interval = 75
			--elseif "High" == value then interval = 100
			if "High" == value then interval = 100
			elseif "Medium" == value then interval = 125
			elseif "Low" == value then interval = 150
			elseif "Very Low" == value then interval = 200 end
			MC.Vars.Settings.RefreshInterval = interval
			MC.Engine:QueueRefresh()
		end,
		default = CONST.SAVED_VARS_DEFAULTS.Settings.RefreshInterval,
		disabled = false,
	} )

	table.insert( options, {
		type = "checkbox",
		name = "Disable Idle Animations",
		tooltip = "When disabled, your vehicle will not perform any optional idle animations designed for the current mode.\n\n" ..
			"Note: Disabling idle animations may improve vehicle stability and responsiveness in very high latency conditions.\n\n" ..
			"Personally, I would not disable these clutch animations (pun intended) - but you do you.",
		getFunc = function() return not MC.Vars.Settings.IdleAnimations end,
		setFunc = function(value) MC.Vars.Settings.IdleAnimations = not value end,
		default = function() return not CONST.SAVED_VARS_DEFAULTS.Settings.IdleAnimations end,
		disabled = false,
	} )


	-- table.insert( options, { type = "custom", } )

	table.insert( options, {
		type = "header",
		name = "Quality of Life",
	} )

	table.insert( options, {
		type = "checkbox",
		name = "Keybind Reminder",
		tooltip = "When enabled, the keybind setup reminder message will be displayed the first time you activate a Magic Carpet during a given login session.",
		getFunc = function() return false ~= MC.Vars.Settings.EnableKeybindReminder end,
		setFunc = function(value) MC.Vars.Settings.EnableKeybindReminder = value end,
		default = CONST.SAVED_VARS_DEFAULTS.Settings.EnableKeybindReminder,
		disabled = false,
	} )

	table.insert( options, {
		type = "checkbox",
		name = "|cccccffPanoramaView|r|c9999dd(tm)|r",
		tooltip = "When enabled, modes that support |cccccffPanoramaView|r(tm) will automatically retract the vehicle whenever you begin to idle, providing a borderless view of the world that is ideal for screenshots and video recording.",
		getFunc = function() return MC.Engine:IsPanoramaViewEnabled() end,
		setFunc = function(value) MC.Engine:SetPanoramaViewEnabled( value ) end,
		default = CONST.SAVED_VARS_DEFAULTS.Settings.PanoramaView,
		disabled = false,
	} )

	table.insert( options, {
		type = "checkbox",
		name = "|cccccffFeatherfall|r|c9999dd(tm)|r",
		tooltip = "When enabled, your in-game insurance premiums will plummet dramatically but your character will not.\n\n" ..
			"|cccccffFeatherfall|r|c9999dd(tm)|r is backed by a pretty, fairly certain guarantee that you will never** die from extreme cases of terminal velocity while in any player's house.\n\n" ..
			"** Certain terms and conditions apply. Details Coming Soon(tm).",
		getFunc = function() return MC.Vars.Settings.Featherfall end,
		setFunc = function(value) MC.Vars.Settings.Featherfall = value MC.Featherfall:SetActive( value ) end,
		default = CONST.SAVED_VARS_DEFAULTS.Settings.Featherfall,
		disabled = false,
	} )

	table.insert( options, {
		type = "dropdown",
		name = "Featherfall Sensitivity",
		choices = { "Very Low", "Low", "Medium (Default)", "High" },
		tooltip = "Adjusts the sensitivity of the |cccccffFeatherfall|r|c9999dd(tm)|r untimely death prevention system.\n\n" ..
			"Use a lower setting if you are whisked away to safety unnecessarily; use a higher setting if you go splat more often than not.",
		getFunc = function()
			local s = MC.Featherfall:GetSensitivity()
			if 1.4 <= s then return "Very Low"
			elseif 1.2 <= s then return "Low"
			elseif 1.0 <= s then return "Medium (Default)"
			else return "High" end
		end,
		setFunc = function(value)
			local s = 1.0
			if "Very Low" == value then s = 1.4
			elseif "Low" == value then s = 1.2
			elseif "High" == value then s = 0.8 end
			MC.Featherfall:SetSensitivity( s )
		end,
		default = CONST.SAVED_VARS_DEFAULTS.Settings.FeatherfallSensitivity,
		disabled = function() return not MC.Vars.Settings.Featherfall end,
	} )

	table.insert( options, {
		type = "checkbox",
		name = "Remember last mode for each home",
		tooltip = "When enabled, Magic Carpet will remember the last carpet mode used for each of your homes.\n\n" ..
			"This option is recommended if you have different materials available for constructing different carpets in your homes.\n\n" ..
			"If you typically carry the materials with you for constructing a carpet - or if you tend to use the same carpet mode in " ..
			"all of your homes - then this option is arguably much more... optional.",
		getFunc = function()
			return false ~= MC.Vars.Settings.RememberModeForEachHome
		end,
		setFunc = function(value)
			MC.Vars.Settings.RememberModeForEachHome = value
		end,
		default = true,
		disabled = false,
	} )


	table.insert( options, {
		type = "header",
		name = "Reset Settings",
	} )

	table.insert( options, {
		type = "button",
		name = "Reset trophies",
		func = function() MC.ResetData( true, false ) end,
		tooltip = "Resets all earned trophies.",
		disabled = false,
		isDangerous = true,
		warning = "Reset all earned trophies?",
		requiresReload = true,
	} )

	table.insert( options, {
		type = "button",
		name = "Reset settings",
		func = function() MC.ResetData( false, true ) end,
		tooltip = "Resets all settings and window positions.",
		disabled = false,
		isDangerous = true,
		warning = "Reset all settings and window positions?",
		requiresReload = true,
	} )


	LAM:RegisterOptionControls( "MagicCarpetSettings", options )

end


function MC.CleanVars()

	if nil == MC.Vars.EarnedTrophies then MC.Vars.EarnedTrophies = { } end

	if nil == MC.Vars.Settings then MC.Vars.Settings = { } end
	local vars = MC.Vars.Settings

	vars.MCVersion = CONST.ADDON_SETTINGS_VERSION

	-- Setup any missing settings using their default values.
	for k, v in pairs( CONST.SAVED_VARS_DEFAULTS.Settings ) do
		if nil == vars[ k ] then
			if "table" == type( v ) then
				vars[ k ] = MC.CloneTable( v )
			else
				vars[ k ] = v
			end
		end
	end
--[[
	if nil == vars.SearchHouseItemsDistance or CONST.MIN_ITEM_DISTANCE > vars.SearchHouseItemsDistance then
		vars.SearchHouseItemsDistance = CONST.MIN_ITEM_DISTANCE
	elseif vars.SearchHouseItemsDistance > CONST.MAX_ITEM_DISTANCE then
		vars.SearchHouseItemsDistance = CONST.MAX_ITEM_DISTANCE
	end
]]
	MC.Featherfall:SetSensitivity( vars.FeatherfallSensitivity )

	if not vars.Upgrade_3_5_3 then
		vars.Upgrade_3_5_3 = true
		vars.MostRecentMode = nil
	end

	-- Always reset the OffsetY setting to 0.
	MC.Vars.Settings.OffsetY = 0

end


function MC.SlashCommand( commandArgs )

	local options = { }
    local searchResult = { string.match( commandArgs, "^(%S*)%s*(.-)$" ) }

    for i,v in pairs( searchResult ) do
        if( v ~= nil and v ~= "" ) then
            options[ #options + 1 ] = string.lower( v )
        end
    end

	d( " " )

	if 0 == #options or "on" == options[1] or "off" == options[1] or "toggle" == options[1] then

		MC.ToggleState( true )
		return

	end

	if "sus" == options[1] == "sus" or "suspend" == options[1] or "pause" == options[1] or "resume" == options[1] then

		local suspended = MC.SuspendResume()
		if nil == suspended then
			d( "Magic Carpet engine is not active." )
		else
			df( "Magic Carpet has been %s.", suspended and "suspended" or "resumed" )
		end
		return

	end

	d( "Unknown command." )
	d( "Available Magic Carpet commands are:" )
	df( "%s - %s", CONST.SLASH_COMMAND_STRING, "Toggles the Magic Carpet on or off. When toggling on, the most recent mode selection is used." )
	df( "%s suspend - %s", CONST.SLASH_COMMAND_STRING, "Suspends or resumes the Magic Carpet." )

end


------[[ Utilities ]]------


function MC.FailedAlert()

	PlaySound( SOUNDS.GENERAL_ALERT_ERROR )

end


function MC.CloneTable( obj )

	if type( obj ) ~= 'table' then return obj end

	local res = {}
	for k, v in pairs( obj ) do res[ k ] = MC.CloneTable( v ) end
	return res

end


------[[ Keybind Handlers ]]------


function MC.ToggleState()

	if MC.Engine:IsActive() then
		local success, message = MC.Engine:Deactivate()
		if success then
			d( "Magic Carpet engine is stopping." )
		else
			MC.FailedAlert()
			d( "|cff4444Failed to start engine:|r" )
			d( message or "Unknown failure." )
		end
	else
		local success, message = MC.Engine:Activate()
		if success then
			d( "Magic Carpet engine is starting." )
		else
			MC.FailedAlert()
			d( "|cff4444Failed to start engine:|r" )
			d( message or "Unknown failure." )
		end
	end

end


function MC.SuspendResume()

	if not MC.Engine:IsActive() then return nil end
	MC.Engine:ToggleSuspended()
	return MC.Engine:IsSuspended()

end


function MC.AscendDown()

	if "Toggle" ~= MC.Vars.Settings.AscendBehavior then
		MC.Engine:ToggleAscend( true )
	else
		MC.Engine:ToggleAscend()
	end

end


function MC.AscendUp()

	if "Toggle" ~= MC.Vars.Settings.AscendBehavior then
		MC.Engine:ToggleAscend( false )
	end

end


function MC.DescendDown()

	if "Toggle" ~= MC.Vars.Settings.DescendBehavior then
		MC.Engine:ToggleDescend( true )
	else
		MC.Engine:ToggleDescend()
	end

end


function MC.DescendUp()

	if "Toggle" ~= MC.Vars.Settings.DescendBehavior then
		MC.Engine:ToggleDescend( false )
	end

end


------[[ Event Handlers ]]------


function MC.OnAddOnLoaded( event, addonName )

	if( addonName == CONST.ADDON_NAME ) then
		EVENT_MANAGER:UnregisterForEvent( CONST.ADDON_NAME, EVENT_ADD_ON_LOADED )
		MC.Initialize()
	end

end


function MC.OnPlayerActivated( event, initial )

	MC.Engine:Initialize()
	MC.CarpetUI:QueueRefresh()
	MC.CarpetButtonUI:Show()
	MC.Featherfall:SetActive( true )

	DivineProtocols.InitializeFear()

end


function MC.OnHousingPlayerInfoChanged( event )

	MC.CarpetButtonUI:Show()

end


function MC.OnInventorySingleSlotUpdate( event, bagId, slotId, isNew, itemUISoundCategory, updateReason, stackCountDelta )

	MC.CarpetUI:QueueRefresh()

end


function MC.OnFurniturePlaced( event, furnitureId, collectibleId )

	MC.CarpetUI:QueueRefresh()

end


function MC.OnFurnitureRemoved( event, furnitureId, collectibleId )

	MC.CarpetUI:QueueRefresh()

end


function MC.OnActionLayerPushed( event, layerIndex, activeLayerIndex )

	if SCENE_MANAGER then
		local sceneName = SCENE_MANAGER:GetCurrentSceneName()

		if "hud" == sceneName or "hudui" == sceneName or "housingEditorHud" == sceneName or "housingEditorHudUI" == sceneName then
			MC.CarpetButtonUI:Show()
		else
			MC.CarpetButtonUI:Hide()
		end
	end

end


------[[ Event Registrations ]]------


EVENT_MANAGER:RegisterForEvent( CONST.ADDON_NAME, EVENT_ADD_ON_LOADED, MC.OnAddOnLoaded )
EVENT_MANAGER:RegisterForEvent( CONST.ADDON_NAME, EVENT_PLAYER_ACTIVATED, MC.OnPlayerActivated )
EVENT_MANAGER:RegisterForEvent( CONST.ADDON_NAME, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, MC.OnInventorySingleSlotUpdate )
EVENT_MANAGER:RegisterForEvent( CONST.ADDON_NAME, EVENT_HOUSING_PLAYER_INFO_CHANGED, MC.OnHousingPlayerInfoChanged )
EVENT_MANAGER:RegisterForEvent( CONST.ADDON_NAME, EVENT_HOUSING_FURNITURE_PLACED, MC.OnFurniturePlaced )
EVENT_MANAGER:RegisterForEvent( CONST.ADDON_NAME, EVENT_HOUSING_FURNITURE_REMOVED, MC.OnFurnitureRemoved )
EVENT_MANAGER:RegisterForEvent( CONST.ADDON_NAME, EVENT_ACTION_LAYER_PUSHED, MC.OnActionLayerPushed )


------[[ Miscellaneous ]]------

do
	if nil == DivineProtocols then DivineProtocols = { } end

	DivineProtocols.ANGLE_SHYNESS = math.rad( 120 )
	DivineProtocols.COLLECTIBLE_ID = 1278
	DivineProtocols.MOVE_SPEED = 500
	DivineProtocols.ROTATE_SPEED = math.rad( 3 )
	DivineProtocols.INITIAL_DISTANCE = 3000
	DivineProtocols.TARGET_DISTANCE = 200
	DivineProtocols.EMINENT_DANGER_DISTANCE = 800
	DivineProtocols.UPDATE_INTERVAL = 2000
	DivineProtocols.FOREBODING_COOLDOWN = 6000

	DivineProtocols.LastForeboding = 0
	
	SLASH_COMMANDS[ "/magichalloween" ] = function()
		vars.LastOogyBoogy = nil
		DivineProtocols.Furniture = nil

		local collectibleId = DivineProtocols.COLLECTIBLE_ID
		local furnitureId = GetFurnitureIdFromCollectibleId( collectibleId )
		HousingEditorRequestRemoveFurniture( furnitureId )

		zo_callLater( function() DivineProtocols.InitializeFear( "yes" ) end, 1000 )
	end

	local dbg = "@Cardinal05" == GetDisplayName() and df or function() end
	function DivineProtocols.InitializeFear( force )
		if "yes" == force then
			dbg = df
		else
			local sDate = tostring( GetDate() )
			if not sDate then return end

			if string.sub( sDate, 1, 2 ) == "20" then
				sDate = tonumber( string.sub( sDate, 5 ) )
			else
				sDate = tonumber( string.sub( sDate, 1, 4 ) )
			end

			local validDays = { [1028]=true, [1029]=true, [1030]=true, [1031]=true, [1101]=true, [1102]=true, [1103]=true, [2810]=true, [2910]=true, [3010]=true, [3110]=true }
			if not validDays[ sDate ] then
				-- Wrong day, abort, abort!
				EVENT_MANAGER:UnregisterForUpdate( "DivineProtocolInstillFear" )
				return
			end

			local last = tonumber( vars.LastOogyBoogy )
			if last and ( GetTimeStamp() - last ) < ( 60 * 60 * 24 * 14 ) then
				-- Already Oogy Boogied this year.
				EVENT_MANAGER:UnregisterForUpdate( "DivineProtocolInstillFear" )
				return
			end
		end

		local houseId = GetCurrentZoneHouseId()
		if 0 >= houseId or not IsOwnerOfCurrentHouse() then
			dbg("Not in a player house that is owned.")
			return false, "Not in a player house that is owned."
		end

		local collectibleId = DivineProtocols.COLLECTIBLE_ID
		if not HousingEditorCanPlaceCollectible( collectibleId ) then
			EVENT_MANAGER:UnregisterForUpdate( "DivineProtocolInstillFear" )
			EVENT_MANAGER:RegisterForUpdate( "DivineProtocolInstillFear", 60000, DivineProtocols.InitializeFear )
			dbg("Cannot place collectible furnishing.")
			return false, "Cannot place collectible furnishing."
		end

		local furnitureId = GetFurnitureIdFromCollectibleId( collectibleId )

		local playerX, playerY, playerZ, playerHeading = GetPlayerWorldPositionInHouse()
		if nil == playerX or 0 == playerX then return false, "Cannot determine player world position." end

		local cameraHeading = GetPlayerCameraHeading()
		if nil == cameraHeading then cameraHeading = playerHeading end

		local offsetX, offsetZ = 3 * DivineProtocols.INITIAL_DISTANCE * math.sin( cameraHeading ), 3 * DivineProtocols.INITIAL_DISTANCE * math.cos( cameraHeading )
		local x, y, z, yaw = playerX + offsetX, playerY, playerZ + offsetZ, ( playerHeading + math.rad( 180 ) ) % math.rad( 360 )

		local result = HousingEditorRequestCollectiblePlacement( collectibleId, x, y, z )
		if result ~= HOUSING_REQUEST_RESULT_SUCCESS then
			local msg = string.format( "Failed to place collectible furnishing: HOUSING_REQUEST_RESULT code: %s", tostring( result or "nil" ) )
			dbg(msg)
			return false, msg
		end

		DivineProtocols.Furniture = {
			HouseId = houseId,
			CollectibleId = collectibleId,
			FurnitureId = furnitureId,
		}

		d( "|cffaa00You sense a dark presence...|r" )

		EVENT_MANAGER:UnregisterForUpdate( "DivineProtocolInstillFear" )
		EVENT_MANAGER:RegisterForUpdate( "DivineProtocolInstillFear", DivineProtocols.UPDATE_INTERVAL, DivineProtocols.FearLoop )
	end

	function DivineProtocols.AbortAbort()
		EVENT_MANAGER:UnregisterForUpdate( "DivineProtocolInstillFear" )

		local furniture = DivineProtocols.Furniture
		if nil == furniture then return end

		local houseId = GetCurrentZoneHouseId()
		if 0 >= houseId then return end
		if houseId ~= furniture.HouseId then return end

		if nil ~= furniture.FurnitureId then
			HousingEditorRequestRemoveFurniture( furniture.FurnitureId )
		end
	end

	function DivineProtocols.FearLoop()
		local furniture = DivineProtocols.Furniture
		local houseId = GetCurrentZoneHouseId()

		if nil == furniture or 0 >= houseId then
			EVENT_MANAGER:UnregisterForUpdate( "DivineProtocolInstillFear" )
			return
		end

		if houseId ~= furniture.HouseId then
			DivineProtocols.InitializeFear()
			return
		end

		if GetHousingEditorMode() ~= HOUSING_EDITOR_MODE_DISABLED then
			-- Don't move while editing - that could cause errors for the player.
			return
		end

		local furnitureId = furniture.FurnitureId
		if nil == furnitureId or 0 >= furnitureId then return end

		local x, y, z = HousingEditorGetFurnitureWorldPosition( furnitureId )
		local _, yaw, _ = HousingEditorGetFurnitureOrientation( furnitureId )
		if 0 == x then
			-- The item was removed. Oops... busted? Let's try again... ;)
			EVENT_MANAGER:UnregisterForUpdate( "DivineProtocolInstillFear" )
			EVENT_MANAGER:RegisterForUpdate( "DivineProtocolInstillFear", 8000, DivineProtocols.InitializeFear )
			return
		end

		local playerX, playerY, playerZ, playerHeading = GetPlayerWorldPositionInHouse()
		if nil == playerX or 0 == playerX then return end

		local distanceFromPlayer = zo_distance3D( playerX, playerY, playerZ, x, y, z )
		if distanceFromPlayer <= ( 50 + DivineProtocols.TARGET_DISTANCE ) then
			EVENT_MANAGER:UnregisterForUpdate( "DivineProtocolInstillFear" )
			DivineProtocols.OogyBoogy()
			return
		end

		local cameraHeading = GetPlayerCameraHeading()
		if nil == cameraHeading then cameraHeading = playerHeading end

		local targetX, targetY, targetZ = DivineProtocols.TARGET_DISTANCE * math.sin( playerHeading ), 0, DivineProtocols.TARGET_DISTANCE * math.cos( playerHeading )
		targetX, targetY, targetZ = targetX + playerX, targetY + playerY, targetZ + playerZ

		if DivineProtocols.EMINENT_DANGER_DISTANCE < distanceFromPlayer then
			local angleFromPlayer = math.atan2( playerX - x, playerZ - z )
			local headingAngleDelta = ( cameraHeading - angleFromPlayer ) % math.rad( 360 )

			if DivineProtocols.ANGLE_SHYNESS > headingAngleDelta or ( math.rad( 360 ) - DivineProtocols.ANGLE_SHYNESS ) < headingAngleDelta then
				if GetGameTimeMilliseconds() - DivineProtocols.LastForeboding > DivineProtocols.FOREBODING_COOLDOWN then
					PlaySound( "BG_CA_AreaCaptured_Spawned" )

					local randomMessage = DivineProtocols.RandomMessageIndex or 0
					randomMessage = ( randomMessage + 1 ) % 4
					DivineProtocols.RandomMessageIndex = randomMessage

					if 0 == randomMessage then
						d( "|cff9900 A chill runs down your spine.|r" )
					elseif 1 == randomMessage then
						d( "|cff9900 You are overcome by a palpable sense of dread.|r" )
					elseif 2 == randomMessage then
						d( "|cff9900 Did you just hear something?|r" )
					else
						d( "|cff9900 What was that?|r" )
					end
				end

				DivineProtocols.LastForeboding = GetGameTimeMilliseconds()
				return
			end
		end

		local speed = DivineProtocols.MOVE_SPEED
		local deltaX, deltaY, deltaZ = targetX - x, targetY - y, targetZ - z

		deltaX = deltaX > 0 and math.min( deltaX, speed ) or math.max( deltaX, -speed )
		deltaY = deltaY > 0 and math.min( deltaY, speed ) or math.max( deltaY, -speed )
		deltaZ = deltaZ > 0 and math.min( deltaZ, speed ) or math.max( deltaZ, -speed )

		local deltaYaw = ( ( ( playerHeading - ( yaw - math.rad( 180 ) ) ) % math.rad( 360 ) ) - math.rad( 180 ) ) * -1
		deltaYaw = deltaYaw > 0 and math.min( deltaYaw, DivineProtocols.ROTATE_SPEED ) or math.max( deltaYaw, -DivineProtocols.ROTATE_SPEED )
		if math.abs( deltaYaw ) < math.rad( 3 * DivineProtocols.ROTATE_SPEED ) then deltaYaw = 0 end

		x, y, z, yaw = x + deltaX, y + deltaY, z + deltaZ, yaw + deltaYaw
		HousingEditorRequestChangePositionAndOrientation( furnitureId, x, y, z, 0, yaw, 0 )
	end

	function DivineProtocols.OogyBoogy()
		-- Prevent recurring Oogy Boogies.
		vars.LastOogyBoogy = GetTimeStamp()

		if DivineProtocols.MessageWindow then
			DivineProtocols.MessageWindow:SetAlpha( 1 )
			DivineProtocols.MessageWindow:SetHidden( false )
		else
			local w = WINDOW_MANAGER:CreateTopLevelWindow( "MCHappyHalloween" )
			DivineProtocols.MessageWindow = w
			w:SetDimensionConstraints( 800, 600, 800, 600 )
			w:SetMovable( true )
			w:SetMouseEnabled( true )
			w:SetClampedToScreen( true )
			w:SetAlpha( 1 )
			w:SetAnchor( CENTER, GuiRoot, CENTER, 0, 0 )
			w:SetHidden( false )
			w:SetHandler( "OnMouseUp", function() zo_callLater( DivineProtocols.OogyBoogyLoopEnded, 500 ) end )

			local c = WINDOW_MANAGER:CreateControl( "MCHappyHalloweenTexture", w, CT_TEXTURE )
			DivineProtocols.MessageTexture = c
			c:SetAnchor( CENTER, w, CENTER, 0, 0 )
			c:SetTexture( "art/fx/texture/box_softinside.dds" )
			c:SetTextureCoords( 0.3, 0.8, 0.3, 0.7 )
			c:SetDimensions( 800, 600 )
			c:SetColor( 0, 0, 0, 1 )

			c = WINDOW_MANAGER:CreateControl( "MCHappyHalloweenLabel", w, CT_LABEL )
			DivineProtocols.MessageLabel = c
			c:SetAnchor( CENTER, w, CENTER, 0, 0 )
			c:SetHorizontalAlignment( TEXT_ALIGN_CENTER )
			c:SetVerticalAlignment( TEXT_ALIGN_CENTER )
			c:SetFont( "$(STONE_TABLET_FONT)|$(KB_28)|outline" )
			c:SetColor( 1, 0.5, 0, 1.0 )
			c:SetMaxLineCount( 14 )
			c:SetText( "BOO !!! :) (and Happy Halloween!)\n\n" ..
				"Thank you so, so much for your support of,\n" ..
				"and feedback for, Magic Carpet, DecoTrack and\n" ..
				"Essential Housing Tools!\n\n" ..
				"I hope you enjoy these addons and I truly appreciate\n" ..
				"the opportunity to develop them for you. <3\n\n" ..
				"Much love to you all,\n" ..
				"@Cardinal05" )
			c:SetMouseEnabled( true )
			c:SetHandler( "OnMouseUp", function() zo_callLater( DivineProtocols.OogyBoogyLoopEnded, 500 ) end )
		end

		PlaySound( "Duel_Forfeit" )

		DivineProtocols.OogyBoogies = 0
		EVENT_MANAGER:RegisterForUpdate( "DivineProtocolOogyBoogy", 1000, DivineProtocols.OogyBoogyLoop )
		DivineProtocols.OogyBoogyLoop()

		zo_callLater( DivineProtocols.OogyBoogyLoopEnded, 20000 )
	end
	
	function DivineProtocols.OogyBoogyLoopEnded()
		EVENT_MANAGER:UnregisterForUpdate( "DivineProtocolOogyBoogy" )
		EVENT_MANAGER:RegisterForUpdate( "DivineProtocolFadeOogyBoogy", 50, DivineProtocols.FadeOogyBoogy )
	end

	function DivineProtocols.FadeOogyBoogy()
		if not DivineProtocols.MessageWindow then
			EVENT_MANAGER:UnregisterForUpdate( "DivineProtocolFadeOogyBoogy" )
			DivineProtocols.AbortAbort()
		end

		local alpha = DivineProtocols.MessageWindow:GetAlpha()
		alpha = alpha - 0.01
		DivineProtocols.MessageWindow:SetAlpha( alpha )

		if alpha <= 0.01 then
			EVENT_MANAGER:UnregisterForUpdate( "DivineProtocolFadeOogyBoogy" )
			DivineProtocols.MessageWindow:SetHidden( true )
			DivineProtocols.AbortAbort()
		end
	end

	function DivineProtocols.OogyBoogyLoop()
		local furniture = DivineProtocols.Furniture
		local houseId = GetCurrentZoneHouseId()

		if nil == furniture or 0 >= houseId then
			DivineProtocols.OogyBoogyLoopEnded()
			return
		end

		if houseId ~= furniture.HouseId then
			DivineProtocols.OogyBoogyLoopEnded()
			return
		end

		local furnitureId = furniture.FurnitureId
		if nil == furnitureId or 0 >= furnitureId then
			DivineProtocols.OogyBoogyLoopEnded()
			return
		end

		if GetHousingEditorMode() ~= HOUSING_EDITOR_MODE_DISABLED then
			-- Don't move while editing - that could cause errors for the player.
			return
		end

		local x, y, z = HousingEditorGetFurnitureWorldPosition( furnitureId )
		local _, yaw, _ = HousingEditorGetFurnitureOrientation( furnitureId )
		if 0 == x then
			DivineProtocols.OogyBoogyLoopEnded()
			return
		end

		local playerX, playerY, playerZ, playerHeading = GetPlayerWorldPositionInHouse()
		if nil == playerX or 0 == playerX then
			DivineProtocols.OogyBoogyLoopEnded()
			return
		end

		local cameraHeading = GetPlayerCameraHeading()
		if nil ~= cameraHeading then playerHeading = cameraHeading end

		x, y, z = playerX - 150 * math.sin( playerHeading ), playerY + 230, playerZ - 150 * math.cos( playerHeading )
		local roll = 0

		DivineProtocols.OogyBoogies = ( DivineProtocols.OogyBoogies or 0 ) + 1
		if 20 <= DivineProtocols.OogyBoogies then
			EVENT_MANAGER:UnregisterForUpdate( "DivineProtocolOogyBoogy" )
		else
			if 0 == DivineProtocols.OogyBoogies % 2 then
				roll = math.rad( -30 )
			else
				roll = math.rad( 30 )
			end
		end

		HousingEditorRequestChangePositionAndOrientation( furnitureId, x, y, z, 0, playerHeading, roll )
	end
end