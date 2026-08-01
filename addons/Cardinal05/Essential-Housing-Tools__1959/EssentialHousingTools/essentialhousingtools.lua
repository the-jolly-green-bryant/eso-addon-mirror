if not EHT then EHT = { } end
if not EHT.Setup then EHT.Setup = { } end
local LAM

local ctrl = "|cffe0b0"
local highlight = "|cffff99"

---[ Operations : Add-On ]---

local isOperational = true

function EHT.Setup.IsOperational()
	return isOperational
end

function EHT.Setup.SetOperational( value )
	local wasOperational = isOperational
	isOperational = isOperational and value

	if wasOperational and not isOperational and EHT.Handlers and EHT.Handlers.UnregisterHandlers then
		EHT.Handlers.UnregisterHandlers()
	end
end

function EHT.Setup.ValidateModules()
	if not LAM then
		EHT.Setup.SetOperational( false )
		zo_callLater( function()
			local msg = "|cffff00Please install LibAddonMenu-2.0 in order to use Essential Housing Tools."
			d( msg )
			if EHT.UI and EHT.UI.ShowAlertDialog then
				EHT.UI.ShowAlertDialog( "", msg )
			end
		end, 5000 )
		return false
	end

	local m = EHT.Modules
	local valid = "table" == type( m ) and
		m.Business and m.ChangeTracking and m.Data and m.Effects and
		m.EssentialHousingTools and m.GUI and m.Handlers and m.Housing and
		m.Interop and m.Mapcast and m.Namespaces and m.Pointers and
		m.QuickAction and m.Tutorials and m.UI and m.Utilities

	if not valid then
		EHT.Setup.SetOperational( false )
		zo_callLater( function()
			local msg = 
				"|cffff88WARNING! |cffffffEssential Housing Tools may not installed properly...\n\n" ..
				"|cffffffTypically this results from a connectivity issue or even a Minion hiccup while installing an EHT update.\n\n" ..
				"|cffffffIf you type |c88ffff/reloadui|cffffff and still receive this message, please reinstall Essential Housing Tools " ..
				"(but do |cff1111NOT|cffffff delete your SavedVariables files) and then type |c88ffff/reloadui|cffffff or restart your game."
			d( msg )
			if EHT.UI and EHT.UI.ShowAlertDialog then
				EHT.UI.ShowAlertDialog( "", msg )
			end
		end, 5000 )
	end

	return valid
end

function EHT.Setup.Initialize()
	LAM = LibAddonMenu2

	if not EHT.Setup.ValidateModules() then
		return false
	end
	
	EHT.PushTS( "EHT.Setup.Initialize()" )

	EHT.Handlers.RegisterHandlers()
	EHT.Setup.SetupStrings()
	EHT.SavedVars = ZO_SavedVars:NewAccountWide( EHT.SAVED_VARS_FILE, EHT.SAVED_VARS_VERSION, nil, EHT.SAVED_VARS_DEFAULTS )
	EHT.Setup.CleanVars()
	EHT.Housing.SetupDimensionLookupTable()
	EHT.Setup.SetupUIExtensions()
	EHT.Setup.SetupSettingsMenu()
	EHT.CleanDefaultSettings()

	zo_callLater( EHT.Setup.SetupSlashCommands, 2000 )
	zo_callLater( function()
		EHT.GUI:SetCustomUIHidingEnabled( EHT.GetSetting( "EnableCustomUIHiding" ) )
	end, 1000 )

	local previousPlayer = EHT.SavedVars.DataTransferredFrom

	if "string" == type( previousPlayer ) then
		-- The saved variables were recently transferred from a previous @player name (after a name change, etc.).
		-- Purge the previous @player name's data in order to trim the saved variables file size.
		local oldData = ZO_SavedVars:NewAccountWide( EHT.SAVED_VARS_FILE, EHT.SAVED_VARS_VERSION, nil, nil, nil, previousPlayer )

		if oldData and oldData.Houses then
			oldData.Houses = nil
			oldData.Builds = nil
		end

		EHT.SavedVars.DataTransferredFrom = nil
	end

	EHT.PopTS( "EHT.Setup.Initialize()" )

	return true
end

function EHT.Setup.SetupSlashCommands()
	SLASH_COMMANDS[ "/eht" ] = EHT.UI.ShowToolDialog
	SLASH_COMMANDS[ "/ehtver" ] = EHT.Biz.SlashCommandVersion
	SLASH_COMMANDS[ "/ehtversion" ] = EHT.Biz.SlashCommandVersion
	SLASH_COMMANDS[ "/resetehtwin" ] = EHT.UI.ResetAllDialogSettings
	SLASH_COMMANDS[ "/resetdim" ] = EHT.Biz.ResetDimensions
	SLASH_COMMANDS[ "/resetdimensions" ] = EHT.Biz.ResetDimensions
	SLASH_COMMANDS[ "/playscene" ] = EHT.Biz.SlashCommandPlayScene
	SLASH_COMMANDS[ "/stopscene" ] = EHT.Biz.SlashCommandStopScene
	SLASH_COMMANDS[ "/rewindscene" ] = EHT.Biz.SlashCommandRewindScene
	SLASH_COMMANDS[ "/gametime" ] = EHT.Util.GetInGameTimeCommand
	SLASH_COMMANDS[ "/hub" ] = EHT.UI.ShowHousingHub
	SLASH_COMMANDS[ "/publishfx" ] = function() EHT.Effect:PublishFX() end
	SLASH_COMMANDS[ "/storage" ] = EHT.UI.SummonStorage
	SLASH_COMMANDS[ "/craft" ] = EHT.UI.SummonCrafting
	SLASH_COMMANDS[ "/camerazoomin" ] = EHT.Util.CameraZoomIn
	SLASH_COMMANDS[ "/camerazoomout" ] = EHT.Util.CameraZoomOut
	SLASH_COMMANDS[ "/camerazoominout" ] = EHT.Util.CameraZoomInOut
	SLASH_COMMANDS[ "/camerazoomoutin" ] = EHT.Util.CameraZoomOutIn
	SLASH_COMMANDS[ "/fxmetrics" ] = EHT.Effect.DumpFXMetrics
	SLASH_COMMANDS[ "/itemsetcompletion" ] = EHT.Util.PrintItemSetCollectionPieceCompletion
	
	if EHT.IsDev then
		SLASH_COMMANDS[ "/setgametime" ] = EHT.Util.SetInGameTimeCommand
	end

	if nil == SLASH_COMMANDS[ "/loc" ] then SLASH_COMMANDS[ "/loc" ] = EHT.Biz.ShowMyLocation end
	if nil == SLASH_COMMANDS[ "/pos" ] then SLASH_COMMANDS[ "/pos" ] = EHT.Biz.ShowMyLocation end
	if nil == SLASH_COMMANDS[ "/clockme" ] then SLASH_COMMANDS[ "/clockme" ] = EHT.Biz.ClockMovementSpeed end
	if nil == SLASH_COMMANDS[ "/measure" ] then SLASH_COMMANDS[ "/measure" ] = EHT.Biz.ShowItemDimensions end
	if nil == SLASH_COMMANDS[ "/origin" ] then SLASH_COMMANDS[ "/origin" ] = EHT.Biz.ShowSelectionOrigin end
	if nil == SLASH_COMMANDS[ "/re" ] then SLASH_COMMANDS[ "/re" ] = function() ReloadUI() end end
	if nil == SLASH_COMMANDS[ "/dice" ] then SLASH_COMMANDS[ "/dice" ] = function( args ) EHT.Biz.RollDice( "dice", args ) end end
	if nil == SLASH_COMMANDS[ "/roll" ] then SLASH_COMMANDS[ "/roll" ] = function( args ) EHT.Biz.RollDice( "roll", args ) end end
	if nil == SLASH_COMMANDS[ "/rolldice" ] then SLASH_COMMANDS[ "/rolldice" ] = function( args ) EHT.Biz.RollDice( "rolldice", args ) end end
	if nil == SLASH_COMMANDS[ "/droll" ] then SLASH_COMMANDS[ "/droll" ] = function( args ) EHT.Biz.RollDice( "droll", args ) end end
	if nil == SLASH_COMMANDS[ "/rolld" ] then SLASH_COMMANDS[ "/rolld" ] = function( args ) EHT.Biz.RollDice( "rolld", args ) end end

	if EHT.IsDev then SLASH_COMMANDS[ "/sc" ] = SLASH_COMMANDS[ "/script" ] end
end

function EHT.Setup.SetupUIExtensions()
	EHT.UI.SetupUIExtensions()
end

function EHT.Setup.OnNewInstallation()
	if not EHT.Housing.GetHouseId() or IsUnitInCombat( "player" ) then
		return
	end

	EVENT_MANAGER:UnregisterForUpdate( "EHT.Setup.OnNewInstallation" )
	EHT.UI.ShowNewInstallationDialog()
end

function EHT.Setup.CleanVars()
	EHT.PushTS( "EHT.Setup.CleanVars()" )

	local vars = EHT.SavedVars
	for k, v in pairs( EHT.SAVED_VARS_DEFAULTS ) do
		if nil == vars[ k ] then
			if "table" == type( v ) then
				vars[ k ] = EHT.Util.CloneTable( v )
			else
				vars[ k ] = v
			end
		end
	end

	if "table" ~= type(vars.Houses) then vars.Houses = { } end

	for index, house in pairs(EHT.Data.GetFavoriteHouses()) do
		if "table" == type(house) then
			house.HouseId = tonumber(house.HouseId)
			house.Owner = EHT.Util.Trim(string.lower(house.Owner))
		end
	end

	if "number" ~= type(vars.MaxHouseHistory) or EHT.CONST.MIN_HOUSE_HISTORY > vars.MaxHouseHistory then vars.MaxHouseHistory = EHT.CONST.MIN_HOUSE_HISTORY end
	if EHT.CONST.MAX_HOUSE_HISTORY < vars.MaxHouseHistory then vars.MaxHouseHistory = EHT.CONST.MAX_HOUSE_HISTORY end
	vars.MaxHouseHistory = tonumber(vars.MaxHouseHistory)

	local recCount = 0
	for houseKey, house in pairs( vars.Houses ) do
		if tonumber( houseKey ) then
			recCount = recCount + 1
		end

		if string.find( tostring( houseKey ), "@" ) then
			if "table" == type( house.Effects ) and 0 == #house.Effects then
				house.Effects = nil
			end
			if "table" == type( house.Furniture ) and 0 == #house.Furniture then
				house.Furniture = nil
			end
			if "table" == type( house.Groups ) and 0 == #house.Groups then
				house.Groups = nil
			end
			if "table" == type( house.History ) and 0 == #house.History then
				house.History = nil
				house.HistoryIndex = nil
			end
			if "table" == type( house.Scenes ) and 0 == #house.Scenes then
				house.Scenes = nil
			end
			if "table" == type( house.Triggers ) and 0 == #house.Triggers then
				house.Triggers = nil
			end
		else
			if nil == house.Furniture or "table" ~= type( house.Furniture ) then house.Furniture = { } end
			if nil == house.Groups or "table" ~= type( house.Groups ) then house.Groups = { } end
			if nil == house.Scenes or "table" ~= type( house.Scenes ) then house.Scenes = { } end
			if nil == house.Triggers or "table" ~= type( house.Triggers ) then house.Triggers = { } end
			if nil == house.History or "table" ~= type( house.History ) then house.History = { } end
			if nil == house.Groups[ EHT.CONST.GROUP_DEFAULT ] then house.Groups[ EHT.CONST.GROUP_DEFAULT ] = { } end
			if "table" ~= type( house.Effects ) then house.Effects = { } end

			for index, history in ipairs( house.History ) do
				if "string" ~= type( history ) then
					house.History[index] = EHT.Data.SerializeHistoryRecord( history )
				end
			end

			-- Remove any integer-keyed Scenes erroneously placed in this table.
			-- All valid scenes are now keyed by Scene Name.
			if 0 < #house.Scenes then
				for index = #house.Scenes, 1, -1 do
					table.remove( house.Scenes, index )
				end
			end

			for sceneName, scene in pairs( house.Scenes ) do
				if nil == scene.Group then scene.Group = { } end
				if nil == scene.FrameIndex then scene.FrameIndex = 1 end
				if nil == scene.Frames then scene.Frames = { } end

				for _, frame in ipairs( scene.Frames ) do
					if nil == frame.State then frame.State = { } end
				end
			end

			local isLocalHouse = EHT.Data.IsLocalHouseId( houseKey ) -- house.HouseId )

			for effectIndex, effect in pairs( house.Effects ) do
				local et = tonumber( effect.EffectType )
				if et and 8002 < et and 8500 > et then
					-- Convert any legacy Library FX into the one of the new all-in-one Library FX.
					effect.EffectType = 8001
				end

				if isLocalHouse and nil == effect.Id then
					-- Ensure that the player's own houses' effects have unique IDs.
					effect.Id = EHT.Data.AcquireNewEffectId()
				end
			end

			if isLocalHouse then
				-- Ensure that the player's own houses' effects have unique IDs.
				for triggerIndex, trigger in ipairs( house.Triggers ) do
					if nil == trigger.UniqueId then trigger.UniqueId = EHT.Data.GetNextTriggerUniqueId() end
				end
			end
		end
	end

	if not EHT.Util.IsListValue( EHT.CONST.SELECTION_MODE, vars.SelectionMode ) then vars.SelectionMode = EHT.CONST.SELECTION_MODE.SINGLE end

	if vars.SelectionRadius < EHT.CONST.FIND_ADJACENT_RADIUS_MIN then vars.SelectionRadius = EHT.CONST.FIND_ADJACENT_RADIUS_MIN
	elseif vars.SelectionRadius > EHT.CONST.FIND_ADJACENT_RADIUS_MAX then vars.SelectionRadius = EHT.CONST.FIND_ADJACENT_RADIUS_MAX end

	if 0 == vars.SelectionPrecision then
		vars.SelectionPrecision = 3
		vars.SelectionPrecisionUseCustom = false
	end

	if vars.SelectionIndicatorAlpha < EHT.CONST.MIN_SELECTION_INDICATOR_ALPHA then vars.SelectionIndicatorAlpha = EHT.CONST.MIN_SELECTION_INDICATOR_ALPHA end
	if vars.SelectionBoxAlpha < EHT.CONST.MIN_SELECTION_BOX_ALPHA then vars.SelectionBoxAlpha = EHT.CONST.MIN_SELECTION_BOX_ALPHA end
	if vars.GuidelinesAlpha < EHT.CONST.MIN_GRID_ALPHA then vars.GuidelinesAlpha = EHT.CONST.MIN_GRID_ALPHA end
	if vars.GuidelinesLaserAlpha < EHT.CONST.MIN_GRID_ALPHA then vars.GuidelinesLaserAlpha = EHT.CONST.MIN_GRID_ALPHA end
	if vars.GuidelinesRadius < EHT.CONST.MIN_GRID_RADIUS then vars.GuidelinesRadius = EHT.CONST.MIN_GRID_RADIUS end
	if vars.GuidelinesRadius > EHT.CONST.MAX_GRID_RADIUS then vars.GuidelinesRadius = EHT.CONST.MAX_GRID_RADIUS end
	if not vars.GuidelinesUnits or vars.GuidelinesUnits < EHT.CONST.MIN_GRID_UNITS or vars.GuidelinesUnits > EHT.CONST.MAX_GRID_UNITS then vars.GuidelinesUnits = EHT.SAVED_VARS_DEFAULTS.GuidelinesUnits or 100 end

	if nil == vars.Dimensions or nil == vars.DimensionsVersion then
		vars.Dimensions = { }
		vars.DimensionsVersion = 1
	else
		-- Cull the Item Dimensions cache if necessary.
		local dimCount, maxCount = 0, EHT.CONST.MAX_DIMENSION_CACHE_ITEMS

		for dimKey, _ in pairs( vars.Dimensions ) do
			dimCount = dimCount + 1
			if dimCount > maxCount then vars.Dimensions[dimKey] = nil end
		end
	end

	local function SubstituteSelectionModes( t, key )
		local value = t[ key ]

		if nil ~= value then
			if string.lower( value ) == "contiguous items" then t[ key ] = EHT.CONST.SELECTION_MODE.CONNECTED
			elseif string.lower( value ) == "contiguous items (same as target)" then t[ key ] = EHT.CONST.SELECTION_MODE.CONNECTED_HOMOGENEOUS end
		end
	end

	SubstituteSelectionModes( vars, "SelectionMode" )
	SubstituteSelectionModes( vars, "SelectionModifierAlt" )
	SubstituteSelectionModes( vars, "SelectionModifierCtrl" )
	SubstituteSelectionModes( vars, "SelectionModifierShift" )

	-- Eliminate unnecessary Crafting Station Id list.
	vars.CraftingStationItemIds = nil

	local function SubstituteBuildTemplate( t, key )
		local value = t[ key ]

		if nil ~= value then
			if string.lower( value ) == "crafting stations" then
				t[ key ] = EHT.CONST.BUILD_TEMPLATE.CRAFTING_STATIONS_PODS
			elseif string.lower( value ) == "rectangle" then
				t[ key ] = EHT.CONST.BUILD_TEMPLATE.RECTANGLE_OUTLINE
			elseif string.lower( value ) == "rectangle (filled)" then
				t[ key ] = EHT.CONST.BUILD_TEMPLATE.RECTANGLE
			end
		end
	end

	if nil == vars.Builds then vars.Builds = { } end

	for index, build in ipairs( vars.Builds ) do
		SubstituteBuildTemplate( build, "TemplateName" )
	end

	if nil ~= vars.Build then
		SubstituteBuildTemplate( vars.Build, "TemplateName" )
	end

	vars.EnableEffectsMapcast = false

	if "table" == type( vars.RecentNotifications ) then
		local ts = GetTimeStamp()
		local minTS = ts - ( 60 * 60 * 24 )

		for key, t in pairs( vars.RecentNotifications ) do
			if t < minTS then
				vars.RecentNotifications[key] = nil
			end
		end
	end

	if not vars.HousingHubOpenHousesSortVersion then
		EHT.SavedVars.HousingHubOpenHousesSort = "Newest"
		vars.HousingHubOpenHousesSortVersion = 1
	end

	if 0 == recCount and not EHT.SavedVars.ExistingInstallation then
		EVENT_MANAGER:RegisterForUpdate( "EHT.Setup.OnNewInstallation", 10000, EHT.Setup.OnNewInstallation )
	end
	EHT.SavedVars.ExistingInstallation = true

	EHT.PopTS( "EHT.Setup.CleanVars()" )
end

local function GetSettingValue( value, defaultValue )
	if nil ~= value then
		return value
	else
		return defaultValue
	end
end

function EHT.Setup.SetupSettingsMenu()
	local ADDON_ID = "EssentialHousingToolsAddOnMenu"
	local PANEL_DATA =
	{
		type = "panel",
		name = EHT.ADDON_TITLE,
		displayName = EHT.ADDON_TITLE .. " - Settings",
		author = EHT.ADDON_AUTHOR,
		version = EHT.ADDON_VERSION,
		website = EHT.ADDON_HELP_URL,
		slashCommand = "/ehtsettings",
		registerForRefresh = true,
		registerForDefaults = true,
	}
	EHT.LAMPanel = LAM:RegisterAddonPanel(ADDON_ID, PANEL_DATA)

	local options = { }

	table.insert( options, {
		type = "custom",
	} )

	table.insert( options, {
		type = "header",
		name = "Points of Interest",
	} )

	table.insert( options, {
		type = "checkbox",
		name = "Show Point of Interest markers in homes",
		tooltip = "Toggle this ON to see identifying markers above certain crafting stations in any home.",
		key = "ShowPOIs",
		default = true,
		getFunc = function()
			return EHT.GetSetting("ShowPOIs")
		end,
		setFunc = function(value)
			EHT.SetSetting("ShowPOIs", value)
			EHT.SetSetting("ShowAssistantPOIs", value and EHT.GetDefaultSetting("ShowAssistantPOIs"))
			EHT.SetSetting("ShowMasterWritPOIs", value and EHT.GetDefaultSetting("ShowMasterWritPOIs"))
			EHT.SetSetting("ShowCraftingStationPOIs", value and EHT.GetDefaultSetting("ShowCraftingStationPOIs"))
			EHT.SetSetting("EnablePOIColors", value and EHT.GetDefaultSetting("EnablePOIColors"))
			EHT.EffectUI.RefreshPOIEffects()
		end,
	} )

	table.insert( options, {
		type = "checkbox",
		name = "Show Banker and Merchant Points of Interest",
		tooltip = "Toggle this ON to see identifying markers above Banker and Merchant Assistants.",
		key = "ShowAssistantPOIs",
		default = false,
		getFunc = function()
			return EHT.GetSetting("ShowAssistantPOIs")
		end,
		setFunc = function(value)
			if value and not EHT.GetSetting("ShowPOIs") then
				EHT.SetSetting("ShowPOIs", true)
			end
			EHT.SetSetting("ShowAssistantPOIs", value)
			EHT.EffectUI.RefreshPOIEffects()
		end,
	} )

	table.insert( options, {
		type = "checkbox",
		name = "Show Master Writ crafting station Points of Interest",
		tooltip = "Toggle this ON to see identifying markers above attuned, Item Set crafting stations for which you have a master writ in your inventory.\n\n" ..
			"|cffff00NOTE:|cffffff Master writs already added to your quest journal are not yet supported.",
		key = "ShowMasterWritPOIs",
		default = true,
		getFunc = function()
			return EHT.GetSetting("ShowMasterWritPOIs")
		end,
		setFunc = function(value)
			if value and not EHT.GetSetting("ShowPOIs") then
				EHT.SetSetting("ShowPOIs", true)
			end
			EHT.SetSetting("ShowMasterWritPOIs", value)
			EHT.EffectUI.RefreshPOIEffects()
		end,
	} )

	table.insert( options, {
		type = "checkbox",
		name = "Show non-Item Set crafting station Points of Interest",
		tooltip = "Toggle this ON to see identifying markers above non-attuned, non-Item Set crafting stations and alchemy, enchanting, provisioning, outfitting and transmutation stations.",
		default = false,
		key = "ShowCraftingStationPOIs",
		getFunc = function()
			return EHT.GetSetting( "ShowCraftingStationPOIs" )
		end,
		setFunc = function(value)
			if value and not EHT.GetSetting("ShowPOIs") then
				EHT.SetSetting("ShowPOIs", true)
			end
			EHT.SetSetting("ShowCraftingStationPOIs", value)
			EHT.EffectUI.RefreshPOIEffects()
		end,
	} )

	table.insert( options, {
		type = "checkbox",
		name = "Show markers in color",
		tooltip = "Toggle this ON for color markers or OFF for white markers.",
		default = true,
		key = "EnablePOIColors",
		getFunc = function()
			return EHT.GetSetting("EnablePOIColors")
		end,
		setFunc = function(value)
			if value and not EHT.GetSetting("ShowPOIs") then
				EHT.SetSetting("ShowPOIs", true)
			end
			EHT.SetSetting("EnablePOIColors", value)
			EHT.EffectUI.RefreshPOIEffects()
		end,
	} )

	table.insert( options, {
		type = "slider",
		name = "Point of Interest marker size",
		tooltip = "Adjust the slider to decrease or increase the size of Point of Interest markers.",
		autoSelect = true,
		clampInput = true,
		decimals = 0,
		step = 1,
		min = 1,
		max = 100,
		default = 0.5,
		key = "POIMarkerScale",
		getFunc = function() return EHT.GetSetting( "POIMarkerScale" ) * 100 end,
		setFunc = function(value)
			EHT.SavedVars.POIMarkerScale = value / 100
			if EHT.GetSetting("ShowPOIs") then
				EHT.EffectUI.RefreshPOIEffects()
			end
		end,
	} )

	table.insert( options, {
		type = "slider",
		name = "Point of Interest marker transparency",
		tooltip = "Adjust the slider to decrease or increase the transparency of Point of Interest markers.",
		autoSelect = true,
		clampInput = true,
		decimals = 0,
		step = 1,
		min = 1,
		max = 100,
		default = 0.5,
		key = "POIMarkerAlpha",
		getFunc = function() return EHT.GetSetting( "POIMarkerAlpha" ) * 100 end,
		setFunc = function(value)
			EHT.SavedVars.POIMarkerAlpha = value / 100
			if EHT.GetSetting("ShowPOIs") then
				EHT.EffectUI.RefreshPOIEffects()
			end
		end,
	} )


	table.insert( options, {
		type = "custom",
	} )

	table.insert( options, {
		type = "header",
		name = "Essential Housing Community(TM)",
	} )

	table.insert( options, {
		type = "checkbox",
		name = "Hide Guest Journals that you have signed",
		tooltip = "When toggled ON, other players' Guest Journals that you have already signed will be hidden automatically.\n\n" ..
			"|cffff00NOTE: You may summon the current home's Guest Journal at any time from the Shortcuts & Options menu on the EHT button.|r",
		key = "HideSignedGuestJournals",
		getFunc = function() return EHT.GetSetting( "HideSignedGuestJournals" ) end,
		setFunc = function(value) EHT.SavedVars.HideSignedGuestJournals = value end,
		default = false,
		disabled = function() return false end,
	} )

	table.insert( options, {
		type = "checkbox",
		name = "Hide your homes' Guest Journals",
		tooltip = "When toggled ON, your homes' Guest Journals will be hidden automatically.\n\n" ..
			"|cffff00NOTE: You may summon the current home's Guest Journal at any time from the Shortcuts & Options menu on the EHT button.|r",
		key = "HideMyGuestJournals",
		getFunc = function() return EHT.GetSetting( "HideMyGuestJournals" ) end,
		setFunc = function(value) EHT.SavedVars.HideMyGuestJournals = value end,
		default = false,
		disabled = function() return false end,
	} )

	table.insert( options, {
		type = "checkbox",
		name = "Enable Guest Journal chime",
		tooltip = "When toggled ON, Guest Journals appear with an audible chime.",
		key = "EnableGuestJournalAudio",
		getFunc = function() return EHT.GetSetting( "EnableGuestJournalAudio" ) end,
		setFunc = function(value) EHT.SavedVars.EnableGuestJournalAudio = value end,
		default = true,
		disabled = function() return false end,
	} )


	table.insert( options, {
		type = "custom",
	} )

	table.insert( options, {
		type = "header",
		name = "Essential Effects(TM)",
	} )

	table.insert( options, {
		type = "dropdown",
		choices = EHT.CONST.ADJUST_FX_SETTINGS,
		name = "Temporarily adjust video settings to support FX",
		tooltip = "The video settings that best support the display of FX are:\n" ..
			"|c88ffffDisplay Mode|r = \"|cffff88Windowed (Fullscreen)|r\"\n" ..
			"|c88ffffSubSampling Quality|r = \"|cffff88High|r\"\n\n" ..
			"Essential Housing Tools can manage these settings when displaying FX:\n\n" ..
			"|cffff88Always|r || Automatically adjust your video settings while visiting a home with FX and automatically restore your original settings after leaving the home. |c00ffff(Recommended)|r\n\n" ..
			"|cffff88Ask Me|r || Prompt for your permission to adjust your video settings while visiting a home with FX. |cbbbb44Note:|r You will only be prompted if your settings are not configured as shown above.\n\n" ..
			"|cffff88Never|r || Never automatically adjust your video settings. |cbbbb44Note:|r FX viewed with incorrect video settings may be visible through walls and terrain, appear distorted or not be visible at all.",
		key = "AdjustFXSettings",
		getFunc = function()
			local value = EHT.GetSetting( "AdjustFXSettings" )
			if value then
				value = EHT.CONST.ADJUST_FX_SETTINGS[ value ]
			end
			return value or "Ask Me"
		end,
		setFunc = function(value)
			EHT.SavedVars.AdjustFXSettings = EHT.CONST.ADJUST_FX_SETTINGS_VALUES[ value ]
		end,
		default = EHT.CONST.ADJUST_FX_SETTINGS_VALUES[ "Ask Me" ],
		disabled = function() return false end,
	} )

	table.insert( options, {
		type = "checkbox",
		name = "Show Essential Effects(tm) when UI is hidden",
		tooltip = "Enable this option to see Essential Effects(tm) even when the game's User Interface is hidden.\n\n" ..
			"Disable this option if you experience conflicts with other add-ons when hiding and showing the game's User Interface.",
		key = "EnableCustomUIHiding",
		getFunc = function() return EHT.GetSetting( "EnableCustomUIHiding" ) end,
		setFunc = function(value) EHT.GUI:SetCustomUIHidingEnabled( value ) end,
		default = false,
		disabled = function() return false end,
	} )

	table.insert( options, {
		type = "checkbox",
		name = "Show received Essential Effects(tm) alert",
		tooltip = "When toggled ON, a large alert will be shown briefly to confirm that you have received another player's Essential Effects(tm) data.",
		key = "ShowEssentialEffectsReceivedOSD",
		getFunc = function() return EHT.GetSetting( "ShowEssentialEffectsReceivedOSD" ) end,
		setFunc = function(value) EHT.SavedVars.ShowEssentialEffectsReceivedOSD = value end,
		default = EHT.SAVED_VARS_DEFAULTS.ShowEssentialEffectsReceived,
		disabled = function() return false end,
	} )

	table.insert( options, {
		type = "checkbox",
		name = "Show received Essential Effects(tm) in chat",
		tooltip = "When toggled ON, a chat message will be shown to confirm that you have received another player's Essential Effects(tm) data.",
		key = "ShowEssentialEffectsReceived",
		getFunc = function() return EHT.GetSetting( "ShowEssentialEffectsReceived" ) end,
		setFunc = function(value) EHT.SavedVars.ShowEssentialEffectsReceived = value end,
		default = EHT.SAVED_VARS_DEFAULTS.ShowEssentialEffectsReceived,
		disabled = function() return false end,
	} )

	table.insert( options, {
		type = "checkbox",
		name = "Suppress notifications when shared to guild",
		tooltip = "When toggled ON, all notifications of Essential Effects(tm) shared to the entire Guild will be suppressed.",
		key = "SuppressGuildShareNotifications",
		getFunc = function() return EHT.GetSetting( "SuppressGuildShareNotifications" ) end,
		setFunc = function(value) EHT.SavedVars.SuppressGuildShareNotifications = value end,
		default = true,
		disabled = function() return not EHT.GetSetting( "ShowEssentialEffectsReceived" ) and not EHT.GetSetting( "ShowEssentialEffectsReceivedOSD" ) end,
	} )

	table.insert( options, {
		type = "checkbox",
		name = "Suppress repeat Essential Effects(tm) notifications",
		tooltip = "When toggled ON, |cffff00repeat notifications|r of received Essential Effects(tm) for the same player will be suppressed for a period of 24 hours.\n\n" ..
			"Enable this option if you do not wish to see more than one notification per player, per day.\n\n" ..
			"NOTE: When this option is enabled, repeat error messages for the same player will also be suppressed.",
		key = "SuppressDuplicateNotifications",
		getFunc = function() return EHT.GetSetting( "SuppressDuplicateNotifications" ) end,
		setFunc = function(value) EHT.SavedVars.SuppressDuplicateNotifications = value end,
		default = true,
		disabled = function() return false end,
	} )

	table.insert( options, {
		type = "checkbox",
		name = "Use your portals automatically",
		tooltip = "When toggled ON, you will automatically use portals in your homes as soon as you are within range.\n\n" ..
			"Toggle this OFF if you wish to be prompted for your confirmation prior to using other players' portals.\n\n" ..
			"NOTE: Portals |cffff00cannot|r be used while in Housing Editor mode regardless of this setting.",
		key = "AutoUsePortals",
		getFunc = function() return EHT.GetSetting( "AutoUsePortals" ) end,
		setFunc = function(value) EHT.SavedVars.AutoUsePortals = value end,
		default = true,
		disabled = function() return false end,
	} )

	table.insert( options, {
		type = "checkbox",
		name = "Use other players' portals automatically",
		tooltip = "When toggled ON, you will automatically use portals in other players' homes as soon as you are within range.\n\n" ..
			"Toggle this OFF if you wish to be prompted for your confirmation prior to using other players' portals.\n\n" ..
			"NOTE: Portals |cffff00cannot|r be used while in Housing Editor mode regardless of this setting.",
		key = "AutoUseHostPortals",
		getFunc = function() return EHT.GetSetting( "AutoUseHostPortals" ) end,
		setFunc = function(value) EHT.SavedVars.AutoUseHostPortals = value end,
		default = true,
		disabled = function() return false end,
	} )

	table.insert( options, {
		type = "checkbox",
		name = "Show portal destination briefly",
		tooltip = "When toggled ON, an alert will be shown briefly to indicate the destination of an activated portal.",
		key = "EnablePortalDestinationOSD",
		getFunc = function() return EHT.GetSetting( "EnablePortalDestinationOSD" ) end,
		setFunc = function(value) EHT.SavedVars.EnablePortalDestinationOSD = value end,
		default = true,
		disabled = function() return false end,
	} )

	table.insert( options, {
		type = "slider",
		name = "Number of Recently Used effects shown",
		tooltip = "Set the maximum number of effects to display in the Recently Used category.",
		autoSelect = true,
		clampInput = true,
		decimals = 0,
		step = 1,
		min = 3,
		max = 30,
		key = "MaxRecentlyUsedEffects",
		getFunc = function() return EHT.GetSetting( "MaxRecentlyUsedEffects" ) end,
		setFunc = function(value) EHT.SavedVars.MaxRecentlyUsedEffects = value end,
		default = 10,
		disabled = function() return false end
	} )

	table.insert( options, {
		type = "checkbox",
		name = "Hide Edit Effect buttons (|cffff00WARNING|r)",
		tooltip = "When toggled ON, the Edit Effect (Paint Bucket) buttons will be hidden.\n\n|c00ffffYou can easily toggle this option directly from the EHT button's pop up menu using the \"FX\" Selection check box.|r\n\n|cffff00Essential Effects CANNOT be edited while this option is enabled.|r",
		key = "EditEffectButtonHidden",
		getFunc = function() return EHT.GetSetting( "EditEffectButtonHidden" ) end,
		setFunc = function(value) EHT.SavedVars.EditEffectButtonHidden = value end,
		default = false,
		disabled = function() return false end,
	} )

	table.insert( options, {
		type = "slider",
		name = "Edit Effect button opacity (%)",
		tooltip = "Adjust how transparent the Edit Effect (Paint Bucket) buttons are.\n\nLower opacity is more transparent.",
		autoSelect = true,
		clampInput = true,
		decimals = 0,
		step = 5,
		min = 20,
		max = 100,
		key = "EditEffectButtonAlpha",
		getFunc = function() return EHT.GetSetting( "EditEffectButtonAlpha" ) end,
		setFunc = function(value) EHT.SavedVars.EditEffectButtonAlpha = value end,
		default = 100,
		disabled = function() return false end
	} )

	table.insert( options, {
		type = "slider",
		name = "Edit Effect button size (%)",
		tooltip = "Adjust the size of the Edit Effect (Paint Bucket) buttons are.",
		autoSelect = true,
		clampInput = true,
		decimals = 0,
		step = 5,
		min = 40,
		max = 200,
		key = "EditEffectButtonSize",
		getFunc = function() return EHT.GetSetting( "EditEffectButtonSize" ) end,
		setFunc = function(value) EHT.SavedVars.EditEffectButtonSize = value end,
		default = 100,
		disabled = function() return false end
	} )


	table.insert( options, {
		type = "custom",
	} )

	table.insert( options, {
		type = "header",
		name = "3D Editing Assistance",
	} )

	table.insert( options, {
		type = "slider",
		name = "Selection Sphere opacity (%)",
		tooltip = "Adjust the opacity of the 3D sphere shown when using the \"Radius\" or \"Radius (Same As Target)\" selection mode.",
		autoSelect = true,
		clampInput = true,
		decimals = 0,
		step = 5,
		min = 100 * EHT.CONST.MIN_SELECTION_INDICATOR_ALPHA,
		max = 100,
		key = "SelectionSphereAlpha",
		getFunc = function() return EHT.GetSetting( "SelectionSphereAlpha" ) end,
		setFunc = function(value) EHT.SavedVars.SelectionSphereAlpha = value end,
		default = 60,
		disabled = function() return false end
	} )

	table.insert( options, {
		type = "slider",
		name = "Indicator size (%)",
		tooltip = "Adjust the relative size of the selection, build, scene, lock and locator pin icons shown in the 3D environment.",
		default = 1,
		min = 30,
		max = 200,
		percent = true,
		decimals = 0,
		step = 5,
		autoSelect = true,
		clampInput = true,
		key = "IndicatorScale",
		getFunc = function() return EHT.GetSetting( "IndicatorScale" ) * 100 end,
		setFunc = function(value) EHT.SetSetting("IndicatorScale", value / 100) end,
		disabled = function() return false end
	} )

	table.insert( options, {
		type = "checkbox",
		name = "Show Selection Checks",
		tooltip = "Toggle this ON to show a 3D check on each item that is in your current selection while in Housing Editor mode.",
		getFunc = function() return EHT.SavedVars.ShowSelectionIndicators end,
		setFunc = function(value) EHT.SavedVars.ShowSelectionIndicators = value EHT.Pointers.SetGroupedHidden( not value ) end,
		default = EHT.SAVED_VARS_DEFAULTS.ShowSelectionIndicators,
		disabled = function() return false end,
	} )

	table.insert( options, {
		type = "slider",
		name = "Selection Check opacity (%)",
		tooltip = "Adjust the opacity of the 3D checks displayed in the 3D environment.\n\nLower opacity results in more transparent checks.",
		autoSelect = true,
		clampInput = true,
		decimals = 0,
		step = 5,
		min = 100 * EHT.CONST.MIN_SELECTION_INDICATOR_ALPHA,
		max = 100,
		getFunc = function() return EHT.SavedVars.SelectionIndicatorAlpha * 100 end,
		setFunc = function(value) EHT.SavedVars.SelectionIndicatorAlpha = value / 100 end,
		default = EHT.SAVED_VARS_DEFAULTS.SelectionIndicatorAlpha * 100,
		disabled = function() return not EHT.SavedVars.ShowSelectionIndicators end
	} )

	table.insert( options, {
		type = "checkbox",
		name = "Show Selection Box",
		tooltip = "Toggle this ON to show a 3D box around all of the items in your current selection while in Housing Editor mode.",
		getFunc = function() return EHT.SavedVars.ShowSelectionBoxIndicator end,
		setFunc = function(value) EHT.SavedVars.ShowSelectionBoxIndicator = value EHT.Pointers.SetGroupOutlineHidden( not value ) end,
		default = EHT.SAVED_VARS_DEFAULTS.ShowSelectionBoxIndicator,
		disabled = function() return false end,
	} )

	table.insert( options, {
		type = "slider",
		name = "Selection Box opacity (%)",
		tooltip = "Adjust the opacity of the 3D box displayed in the 3D environment.\n\nLower opacity results in a more transparent box.",
		autoSelect = true,
		clampInput = true,
		decimals = 0,
		step = 5,
		min = 100 * EHT.CONST.MIN_SELECTION_BOX_ALPHA,
		max = 100,
		getFunc = function() return EHT.SavedVars.SelectionBoxAlpha * 100 end,
		setFunc = function(value) EHT.SavedVars.SelectionBoxAlpha = value / 100 end,
		default = EHT.SAVED_VARS_DEFAULTS.SelectionBoxAlpha * 100,
		disabled = function() return not EHT.SavedVars.ShowSelectionBoxIndicator end,
	} )

	table.insert( options, {
		type = "checkbox",
		name = "Show Horizontal Grid",
		tooltip = "Toggle this ON to show a Horizontal 3D grid while in Housing Editor mode that can be used for more accurate editing.",
		getFunc = function() return EHT.SavedVars.ShowGuidelines end,
		setFunc = function(value) EHT.SavedVars.ShowGuidelines = value EHT.Biz.SetGuidelinesSettingsChanged() EHT.Pointers.SetGuidelinesHidden( not value ) end,
		default = EHT.SAVED_VARS_DEFAULTS.ShowGuidelines,
		disabled = function() return false end,
	} )

	table.insert( options, {
		type = "checkbox",
		name = "Show Vertical Grid",
		tooltip = "Toggle this ON to show a Vertical 3D grid while in Housing Editor mode that can be used for more accurate editing.",
		getFunc = function() return EHT.SavedVars.ShowGuidelinesVertical end,
		setFunc = function(value) EHT.SavedVars.ShowGuidelinesVertical = value EHT.Biz.SetGuidelinesSettingsChanged() end,
		default = EHT.SAVED_VARS_DEFAULTS.ShowGuidelinesVertical,
		disabled = function() return not EHT.SavedVars.ShowGuidelines end,
	} )

	table.insert( options, {
		type = "slider",
		name = "Grid opacity (%)",
		tooltip = "Adjust the opacity of the grid displayed in the 3D environment.\n\n" ..
			"Lower opacity results in more transparent grid lines.",
		autoSelect = true,
		clampInput = true,
		decimals = 0,
		step = 5,
		min = 100 * EHT.CONST.MIN_GRID_ALPHA,
		max = 100,
		getFunc = function() return EHT.SavedVars.GuidelinesAlpha * 100 end,
		setFunc = function(value) EHT.SavedVars.GuidelinesAlpha = value / 100 EHT.Biz.SetGuidelinesSettingsChanged() end,
		default = EHT.SAVED_VARS_DEFAULTS.GuidelinesAlpha * 100,
		disabled = function() return not EHT.SavedVars.ShowGuidelines end,
	} )

	table.insert( options, {
		type = "slider",
		name = "Grid units (meters)",
		tooltip = "Adjust the distance between each guideline in the grid.\n\n" ..
			"Units are in meters.",
		autoSelect = true,
		clampInput = true,
		decimals = 2,
		step = 0.1,
		min = EHT.CONST.MIN_GRID_UNITS / 100,
		max = EHT.CONST.MAX_GRID_UNITS / 100,
		getFunc = function() return EHT.SavedVars.GuidelinesUnits / 100 end,
		setFunc = function(value) EHT.SavedVars.GuidelinesUnits = value * 100 EHT.Biz.SetGuidelinesSettingsChanged() end,
		default = EHT.SAVED_VARS_DEFAULTS.GuidelinesUnits / 100,
		disabled = function() return not EHT.SavedVars.ShowGuidelines end,
	} )

	table.insert( options, {
		type = "slider",
		name = "Grid radius (guideline count)",
		tooltip = "Adjust the number of guidelines shown in each direction.\n\n" ..
			"Increasing this value will expand the overall grid size.",
		autoSelect = true,
		clampInput = true,
		decimals = 0,
		step = 1,
		min = EHT.CONST.MIN_GRID_RADIUS,
		max = EHT.CONST.MAX_GRID_RADIUS,
		getFunc = function() return EHT.SavedVars.GuidelinesRadius end,
		setFunc = function(value) EHT.SavedVars.GuidelinesRadius = value EHT.Biz.SetGuidelinesSettingsChanged() end,
		default = EHT.SAVED_VARS_DEFAULTS.GuidelinesRadius,
		disabled = function() return not EHT.SavedVars.ShowGuidelines end,
	} )

	table.insert( options, {
		type = "checkbox",
		name = "Show LaserAlign(tm) guide beams",
		tooltip = "Toggle this ON to show 3D lasers that extend from all corners of an item while you are manually editing it.\n\n" ..
			"These leveling lasers extend well beyond the item's bounding box to aid in placing the item precisely in relation to other items, walls, the floor and more.",
		getFunc = function() return EHT.SavedVars.ShowGuidelinesBoundaryHighlights end,
		setFunc = function(value) EHT.SavedVars.ShowGuidelinesBoundaryHighlights = value EHT.Biz.SetGuidelinesSettingsChanged() end,
		default = EHT.SAVED_VARS_DEFAULTS.ShowGuidelinesBoundaryHighlights,
		disabled = function() return not EHT.SavedVars.ShowGuidelines end,
	} )

	table.insert( options, {
		type = "slider",
		name = "LaserAlign(tm) opacity (%)",
		tooltip = "Adjust the opacity of the LaserAlign(tm) beams in the 3D environment.\n\n" ..
			"Lower opacity results in more transparent, lower brightness beams.",
		autoSelect = true,
		clampInput = true,
		decimals = 0,
		step = 5,
		min = 100 * EHT.CONST.MIN_GRID_ALPHA,
		max = 100,
		getFunc = function() return EHT.SavedVars.GuidelinesLaserAlpha * 100 end,
		setFunc = function(value) EHT.SavedVars.GuidelinesLaserAlpha = value / 100 EHT.Biz.SetGuidelinesSettingsChanged() end,
		default = EHT.SAVED_VARS_DEFAULTS.GuidelinesLaserAlpha * 100,
		disabled = function() return not EHT.SavedVars.ShowGuidelinesBoundaryHighlights or not EHT.SavedVars.ShowGuidelines end,
	} )

	table.insert( options, {
		type = "custom",
	} )


	table.insert( options, {
		type = "header",
		name = "Selecting Items",
	} )
--[[
	table.insert( options, {
		type = "checkbox",
		name = "Prevent camera from shifting when selecting items",
		tooltip = "When toggled ON, the camera will no longer jump or shift whenever you pick up an item.",
		key = "EnableSteadyCam",
		getFunc = function() return EHT.GetSetting( "EnableSteadyCam" ) end,
		setFunc = function(value) EHT.SavedVars.EnableSteadyCam = value end,
		default = true,
		disabled = function() return false end,
	} )
]]
	table.insert( options, {
		type = "checkbox",
		name = "Hide While Placing",
		tooltip = "Toggle this ON to hide " .. EHT.ADDON_TITLE .. " windows while you are placing items in order to reduce screen clutter.",
		getFunc = function() return EHT.SavedVars.HideDuringPlacement end,
		setFunc = function(value) EHT.SavedVars.HideDuringPlacement = value end,
		default = EHT.SAVED_VARS_DEFAULTS.HideDuringPlacement,
		disabled = function() return false end,
	} )

	table.insert( options, {
		type = "checkbox",
		name = "Show Item Inspection HUD",
		tooltip = "When toggled ON, a window will display information related to items while using the Housing Editor or Inspection Mode.  This information includes the item position, orientation and, optionally, inventory data from DecoTrack.\n\n** Inventory data requires DecoTrack to be installed and active",
		getFunc = function() return EHT.SavedVars.EnableHUDItemData end,
		setFunc = function(value)
			EHT.SavedVars.EnableHUDItemData = value
			EHT.UI.SetInspectionItemInfoDialogEnabled(value)
		end,
		default = EHT.SAVED_VARS_DEFAULTS.EnableHUDItemData,
		disabled = function() return false end,
	} )

	table.insert( options, {
		type = "checkbox",
		name = "Include DecoTrack Data in Item Inspection HUD",
		tooltip = "When toggled ON, inventory data collected from DecoTrack will be included in the window displaying information related to items while using the Housing Editor or Inspection Mode.\n\n** Inventory data requires DecoTrack to be installed and active",
		getFunc = function() return EHT.SavedVars.EnableHUDDecoTrackData end,
		setFunc = function(value) EHT.SavedVars.EnableHUDDecoTrackData = value end,
		default = EHT.SAVED_VARS_DEFAULTS.EnableHUDDecoTrackData,
		disabled = function() return not EHT.SavedVars.EnableHUDItemData end,
	} )

	table.insert( options, {
		type = "slider",
		name = "Multi-Select Radius (centimeters)",
		tooltip = "When selecting furniture with the Radius mode, furniture near the originally targeted furnishing is automatically selected. Use this setting to control the maximum distance that surrounding furniture can be. Measured in centimeters.",
		autoSelect = true,
		clampInput = true,
		decimals = 0,
		step = 10,
		min = EHT.CONST.FIND_ADJACENT_RADIUS_MIN,
		max = EHT.CONST.FIND_ADJACENT_RADIUS_MAX,
		getFunc = function() return EHT.SavedVars.SelectionRadius end,
		setFunc = function(value) EHT.SavedVars.SelectionRadius = value end,
		default = EHT.SAVED_VARS_DEFAULTS.SelectionRadius,
		disabled = function() return false end,
	} )

	table.insert( options, {
		type = "checkbox",
		name = "Show Select / Deselect reminder reticle",
		tooltip = "|cffffff" ..
			"Toggle this ON to see the Select / Deselect reticle (crosshair) tip when " ..
			"you first log in as a reminder of your current keybind configured for " ..
			"Group Selecting/Deselecting items:\n" ..
			"|cffff33Controls || Housing Editor || Essential Housing Tools || Select / Deselect|cffffff" ..
			"\n\n" ..
			"This feature is intended to help introduce players who are new to " ..
			"Essential Housing Tools to a fundamentally important concept: " ..
			"|c33ffffLearning how to Select and Deselect furniture items.|cffffff",
		key = "ShowGroupSelectReticleReminder",
		getFunc = function() return EHT.GetSetting( "ShowGroupSelectReticleReminder" ) end,
		setFunc = function(value)
			EHT.SavedVars.ShowGroupSelectReticleReminder = value
			if value then
				EHT.GroupSelectHintExpires = nil
			else
				EHT.UI.HideInteractionPrompt()
			end
		end,
		default = true,
		disabled = function() return false end,
	} )

	local selectionModeDefault = "Using current mode (DEFAULT)"
	local selectionModeList = { }
	for _, mode in pairs( EHT.CONST.SELECTION_MODE ) do table.insert( selectionModeList, mode ) end
	table.sort( selectionModeList )
	table.insert( selectionModeList, 1, selectionModeDefault )

	table.insert( options, {
		type = "dropdown",
		name = "Holding ALT + Group Select will select",
		choices = selectionModeList,
		tooltip = "Specifies what Select Mode to force when you hold ALT down while pressing the Group Select key.",
		getFunc = function() return nil == EHT.SavedVars.SelectionModifierAlt and selectionModeDefault or EHT.SavedVars.SelectionModifierAlt end,
		setFunc = function(value) EHT.SavedVars.SelectionModifierAlt = value == selectionModeDefault and nil or value end,
		default = EHT.SAVED_VARS_DEFAULTS.SelectionModifierAlt,
		disabled = function() return false end,
	} )

	table.insert( options, {
		type = "dropdown",
		name = "Holding CTRL + Group Select will select",
		choices = selectionModeList,
		tooltip = "Specifies what Select Mode to force when you hold CTRL down while pressing the Group Select key.",
		getFunc = function() return nil == EHT.SavedVars.SelectionModifierCtrl and selectionModeDefault or EHT.SavedVars.SelectionModifierCtrl end,
		setFunc = function(value) EHT.SavedVars.SelectionModifierCtrl = value == selectionModeDefault and nil or value end,
		default = EHT.SAVED_VARS_DEFAULTS.SelectionModifierCtrl,
		disabled = function() return false end,
	} )

	table.insert( options, {
		type = "dropdown",
		name = "Holding SHIFT + Group Select will select",
		choices = selectionModeList,
		tooltip = "Specifies what Select Mode to force when you hold SHIFT down while pressing the Group Select key.",
		getFunc = function() return nil == EHT.SavedVars.SelectionModifierShift and selectionModeDefault or EHT.SavedVars.SelectionModifierShift end,
		setFunc = function(value) EHT.SavedVars.SelectionModifierShift = value == selectionModeDefault and nil or value end,
		default = EHT.SAVED_VARS_DEFAULTS.SelectionModifierShift,
		disabled = function() return false end,
	} )

	table.insert( options, {
		type = "checkbox",
		name = "Reset Selection at Login/Reload",
		tooltip = "Toggle this ON to automatically clear your current item selection at login or when the user interface is reloaded.",
		getFunc = function() return EHT.SavedVars.SelectionVolatile end,
		setFunc = function(value) EHT.SavedVars.SelectionVolatile = value end,
		default = false,
		disabled = function() return false end,
		isDangerous = true,
		warning = "If enabled, be sure to use the " .. ctrl .. "Save|r button on the " .. highlight .. "Select|r tab to save your selection before logging out or exiting the game.",
	} )

	table.insert( options, {
		type = "custom",
	} )


	table.insert( options, {
		type = "header",
		name = "Editing Items",
	} )

	local editModeList = { }
	for _, mode in pairs( EHT.CONST.EDIT_MODE ) do table.insert( editModeList, mode ) end

	table.insert( options, {
		type = "checkbox",
		name = "Show direction/rotation arrow",
		tooltip = "When toggled ON, a large arrow will overlay your selected item(s) to visually indicate " ..
			"the direction that the directional pad arrows will move or rotate the item(s).",
		key = "ShowDirectionalArrowsInWorld",
		getFunc = function() return EHT.GetSetting( "ShowDirectionalArrowsInWorld" ) end,
		setFunc = function(value)
			EHT.SavedVars.ShowDirectionalArrowsInWorld = value
			EHT.DirectionalIndicators:RefreshSettings()
			EHT.UI.RefreshDirectionalPad()
		end,
		default = true,
		disabled = function() return false end,
	} )

	table.insert( options, {
		type = "dropdown",
		name = "Directional Editing",
		choices = editModeList,
		sort = "name-up",
		tooltip = "Specifies how the Directional Pad moves your selected items.\n\n" ..
			"|cddeeffAbsolute|r mode allows you to move items in the cardinal directions - North, South, East and West.\n" ..
			"|cddeeffRelative|r mode allows you to move items relative to the direction your character is facing - Forward, Backward, Left and Right.\n\n" ..
			"|cccccffDefault:|r |cddeeffRelative|r mode as it is generally more intuitive to use.",
		getFunc = function() return nil == EHT.SavedVars.EditMode and EHT.CONST.EDIT_MODE.RELATIVE or EHT.SavedVars.EditMode end,
		setFunc = function(value)
			EHT.SavedVars.EditMode = value
			EHT.DirectionalIndicators:RefreshSettings()
			EHT.UI.RefreshDirectionalPad()
		end,
		default = EHT.SAVED_VARS_DEFAULTS.EditMode,
		disabled = function() return false end,
	} )

	table.insert( options, {
		type = "checkbox",
		name = "Move items relative to your character's heading",
		tooltip = "When toggled ON, the Forward/Backward/Left/Right buttons will move your selected items relative to the direction that your character is facing.\n\n" ..
			"When toggled OFF, your selected items will move relative to the direction that the camera is facing (Default).",
		key = "EditorUsesUnitHeading",
		getFunc = function() return EHT.GetSetting( "EditorUsesUnitHeading" ) end,
		setFunc = function(value)
			EHT.SavedVars.EditorUsesUnitHeading = value
			EHT.DirectionalIndicators:RefreshSettings()
			EHT.UI.RefreshDirectionalPad()
		end,
		default = false,
		disabled = function() return nil ~= EHT.SavedVars.EditMode and EHT.SavedVars.EditMode ~= EHT.CONST.EDIT_MODE.RELATIVE end,
	} )

	table.insert( options, {
		type = "checkbox",
		name = "Enable SmoothMotion(tm)",
		tooltip = "When toggled ON, server requests will be issued simultaneously for up to 10 items at a time, " ..
			"resulting in more smooth animations for, and group edits of, multiple items.\n\n" ..
			"Note the following:\n" ..
			"- The 10 items per second maximum can only be achieved when the Edit Speed setting is set to 100.\n" ..
			"- The overall server maximum of 10 item moves per second is observed regardless of this setting.\n" ..
			"- You should DISABLE this feature IF you experience disconnects or automatic logouts when using " .. EHT.ADDON_TITLE .. ".",
		getFunc = function() return EHT.SavedVars.EnableSmoothMotion end,
		setFunc = function(value) EHT.SavedVars.EnableSmoothMotion = value end,
		default = EHT.SAVED_VARS_DEFAULTS.EnableSmoothMotion,
		disabled = function() return false end,
	} )

	table.insert( options, {
		type = "checkbox",
		name = "Enable TrueCenter(tm)",
		tooltip = "When toggled ON, the Directional Pads will rotate a single item about its actual center point, " ..
			"rather than the often times arbitrary \"center\" point designated by the system.\n\n" ..
			"NOTE: This feature only works when you select a single item in your selection.",
		getFunc = function() return EHT.SavedVars.EnableTrueCenter end,
		setFunc = function(value) EHT.SavedVars.EnableTrueCenter = value end,
		default = EHT.SAVED_VARS_DEFAULTS.EnableTrueCenter,
		disabled = function() return false end,
	} )

	table.insert( options, {
		type = "checkbox",
		name = "Stack Excess Build Materials",
		tooltip = "When toggled ON, any excess items in your selection that are unused by a Build " ..
			"will be stacked off to the side to reduce clutter.",
		getFunc = function() return EHT.SavedVars.AutoStackExcessBuildMaterials end,
		setFunc = function(value) EHT.SavedVars.AutoStackExcessBuildMaterials = value end,
		default = EHT.SAVED_VARS_DEFAULTS.AutoStackExcessBuildMaterials,
		disabled = function() return false end,
	} )

	table.insert( options, {
		type = "slider",
		name = "Edit Speed",
		tooltip = "Throttles how quickly furniture is edited. Decrease this if you are experiencing issues when editing furniture with Essential Housing Tools.",
		autoSelect = true,
		clampInput = true,
		decimals = 0,
		min = 0,
		max = 100,
		getFunc = function() return EHT.SavedVars.EditSpeed end,
		setFunc = function(value) EHT.SavedVars.EditSpeed = value end,
		default = EHT.SAVED_VARS_DEFAULTS.EditSpeed,
		disabled = function() return false end,
	} )

	table.insert( options, {
		type = "slider",
		name = "Furniture Snapping Radius (centimeters)",
		tooltip = "Furniture Snapping can connect two furniture items together easily. Use this setting to control the maximum distance between snapped furnishings. Measured in centimeters.",
		autoSelect = true,
		clampInput = true,
		decimals = 0,
		step = 1,
		min = EHT.CONST.SNAP_FURNITURE_RADIUS_MIN,
		max = EHT.CONST.SNAP_FURNITURE_RADIUS_MAX,
		getFunc = function() return EHT.SavedVars.SnapFurnitureRadius end,
		setFunc = function(value) EHT.SavedVars.SnapFurnitureRadius = value end,
		default = EHT.SAVED_VARS_DEFAULTS.SnapFurnitureRadius,
		disabled = function() return false end,
	} )

	table.insert( options, {
		type = "slider",
		name = "Custom Move Precision (centimeters)",
		tooltip = "Configures your personal \"custom move precision\" setting for use when moving a selected group of furniture. You must still slide the Edit window's Precision slider to \"Custom\" to use this custom precision.",
		autoSelect = true,
		clampInput = true,
		decimals = 0,
		step = 1,
		min = 1,
		max = 5000,
		getFunc = function() return EHT.SavedVars.SelectionPrecisionMoveCustom end,
		setFunc = function(value) EHT.SavedVars.SelectionPrecisionMoveCustom = value end,
		default = EHT.SAVED_VARS_DEFAULTS.SelectionPrecisionMoveCustom,
		disabled = function() return false end,
	} )

	table.insert( options, {
		type = "slider",
		name = "Custom Rotate Precision (degrees)",
		tooltip = "Configures your personal \"custom rotate precision\" setting for use when rotating a selected group of furniture. You must still slide the Edit window's Precision slider to \"Custom\" to use this custom precision.",
		min = 0.01,
		max = 359.99,
		getFunc = function() return EHT.SavedVars.SelectionPrecisionRotateCustom end,
		setFunc = function(value) EHT.SavedVars.SelectionPrecisionRotateCustom = value end,
		default = EHT.SAVED_VARS_DEFAULTS.SelectionPrecisionRotateCustom,
		disabled = function() return false end,
	} )

	table.insert( options, {
		type = "checkbox",
		name = "Directional Controls focus on Position Editor's Item",
		tooltip = "When toggled ON, the Directional Controls (move selected items Forward, North, Up, Down, etc.) will only move the item being edited with the Position Editor pop-up window whenever it is open.",
		getFunc = function() return EHT.SavedVars.DirectionalControlsFocusPositionEditor end,
		setFunc = function(value) EHT.SavedVars.DirectionalControlsFocusPositionEditor = value end,
		default = EHT.SAVED_VARS_DEFAULTS.DirectionalControlsFocusPositionEditor,
		disabled = function() return false end,
	} )

	table.insert( options, {
		type = "custom",
	} )


	table.insert( options, {
		type = "header",
		name = "Change Tracking and Undo/Redo",
	} )

	table.insert( options, {
		type = "checkbox",
		name = "Enable Automatic House Backups",
		tooltip = "When toggled ON, a full snapshot of your house will be backed up when you enter it. This will allow you to restore your entire house to how it was at that point in time, if necessary.",
		getFunc = function() return EHT.SavedVars.AutoBackup end,
		setFunc = function(value) EHT.SavedVars.AutoBackup = value end,
		default = EHT.SAVED_VARS_DEFAULTS.AutoBackup,
		disabled = function() return false end,
	} )

	table.insert( options, {
		type = "checkbox",
		name = "Enable Change Tracking and Undo/Redo",
		tooltip = "When toggled ON, changes made by you and by this add-on are tracked and you will have the option to Undo and Redo those changes.",
		getFunc = function() return EHT.SavedVars.EnableHouseHistory end,
		setFunc = function(value) EHT.SavedVars.EnableHouseHistory = value end,
		default = EHT.SAVED_VARS_DEFAULTS.EnableHouseHistory,
		disabled = function() return false end,
	} )

	table.insert( options, {
		type = "slider",
		name = "Maximum Changes Tracked per House",
		tooltip = "Adjusts how many furniture item changes, placements and removals can be undone and/or redone per house.\n\n" ..
			"NOTE: Higher values for this setting can result in some additional memory usage.",
		autoSelect = true,
		clampInput = true,
		decimals = 0,
		step = 10,
		min = EHT.CONST.MIN_HOUSE_HISTORY,
		max = EHT.CONST.MAX_HOUSE_HISTORY,
		getFunc = function() return EHT.SavedVars.MaxHouseHistory end,
		setFunc = function(value) EHT.SavedVars.MaxHouseHistory = value end,
		default = EHT.SAVED_VARS_DEFAULTS.MaxHouseHistory,
		disabled = function() return not EHT.SavedVars.EnableHouseHistory end,
	} )

	table.insert( options, {
		type = "checkbox",
		name = "Clear Undo History when Logging Out",
		tooltip = "When toggled ON, your Undo/Redo history will be cleared for all of your homes every time that you log out or change characters.\n\nEnable this option to reduce the size of Essential Housing Tools' saved variables file.",
		getFunc = function() return EHT.SavedVars.VolatileHouseHistory end,
		setFunc = function(value) EHT.SavedVars.VolatileHouseHistory = value end,
		default = false,
		disabled = function() return not EHT.SavedVars.EnableHouseHistory end,
	} )

	table.insert( options, {
		type = "custom",
	} )


	table.insert( options, {
		type = "header",
		name = "User Interface",
	} )

	table.insert( options, {
		type = "slider",
		name = "Minimum Opacity",
		tooltip = "Sets the minimum opacity that the Essential Housing Tools window can fade to when not in use.\n\n" ..
			"NOTE: Higher opacity will result in a less transparent window.",
		autoSelect = true,
		clampInput = true,
		decimals = 0,
		min = 50,
		max = 100,
		key = "MinimumWindowOpacity",
		getFunc = function() return EHT.GetSetting( "MinimumWindowOpacity" ) end,
		setFunc = function(value)
			EHT.SavedVars.MinimumWindowOpacity = value
			if EHT.UI and EHT.UI.SetupToolDialog() then
				EHT.UI.ToolDialogAlpha()
			end
		end,
		default = 65,
		disabled = function() return false end,
	} )

	table.insert( options, {
		type = "checkbox",
		name = "    Retain Move/Rotate button visibility",
		tooltip = "When toggled ON, the directional buttons that move and rotate your selected items will remain " ..
			"fully visible when the Essential Housing Tools window dims and fades.",
		key = "RetainEditButtonVisibility",
		getFunc = function() return EHT.GetSetting( "RetainEditButtonVisibility" ) end,
		setFunc = function(value)
			EHT.SavedVars.RetainEditButtonVisibility = value
			if EHT.UI and EHT.UI.SetupToolDialog() then
				EHT.UI.UpdateEditButtonVisibility()
			end
		end,
		default = false,
		disabled = function() return false end,
	} )

	table.insert( options, {
		type = "dropdown",
		name = "Selected Items List Font Size",
		tooltip = "Choose the relative font size of the selected items list.",
		choices = { "Small", "Standard", "Large" },
		key = "SelectionListFontSize",
		getFunc = function() return EHT.GetSetting( "SelectionListFontSize" ) end,
		setFunc = function(value)
			EHT.SavedVars.SelectionListFontSize = value
			if EHT.UI and EHT.UI.SetupToolDialog() then
				EHT.UI.RefreshSelectionListAppearance()
			end
		end,
		default = "Standard",
		disabled = function() return false end,
	} )

	table.insert( options, {
		type = "checkbox",
		name = "Animate EHT button",
		tooltip = "When toggled ON, the EHT button conserves screen space by only revealing " ..
			"submenu options when you place the mouse cursor over it.",
		key = "AnimateEHTButton",
		getFunc = function() return EHT.GetSetting( "AnimateEHTButton" ) end,
		setFunc = function(value)
			EHT.SavedVars.AnimateEHTButton = value
			EHT.UI.ResetEHTButton()
		end,
		default = true,
		disabled = function() return false end,
	} )

	table.insert( options, {
		type = "checkbox",
		name = "Show Item Count and Population",
		tooltip = "When enabled, the current number of traditional items placed, plus the current house population, will be display above the main " .. EHT.ADDON_TITLE .. " window.\n\n" ..
			"Note: These statististics will always be shown below the " .. highlight .. "EHT|r button, regardless of this setting.",
		getFunc = function() return EHT.SavedVars.ShowStatsOnWindow end,
		setFunc = function(value) EHT.SavedVars.ShowStatsOnWindow = value end, -- EHT.UI.SetToolDialogWindowTitle()
		default = EHT.SAVED_VARS_DEFAULTS.ShowStatsOnWindow,
		disabled = function() return false end,
	} )

	table.insert( options, {
		type = "checkbox",
		name = "Show Detailed Trigger List",
		tooltip = "When toggled ON, the Trigger tab's list of Triggers will include a summary of each Trigger's conditions and criteria. " ..
			"When toggled OFF, the list will only display the Description of each Trigger.",
		key = "ShowDetailedTriggerList",
		default = true,
		getFunc = function()
			return EHT.GetSetting( "ShowDetailedTriggerList" )
		end,
		setFunc = function(value)
			EHT.SavedVars.ShowDetailedTriggerList = value
			EHT.UI.QueueRefreshTriggers()
		end,
		disabled = function() return false end,
	} )

	table.insert( options, {
		type = "checkbox",
		name = "Show Trigger Queue",
		tooltip = "Toggle this ON to see a list of queued Trigger Actions whenever one or more Triggers fire.\n\n" ..
			"This feature can be used to troubleshoot complex configurations that involve many different Triggers.",
		key = "ShowTriggerQueue",
		getFunc = function() return EHT.GetSetting( "ShowTriggerQueue" ) end,
		setFunc = function(value)
			EHT.SavedVars.ShowTriggerQueue = value
			if value then
				EHT.UI.UnsuppressDialog()
			end
		end,
		default = true,
		disabled = function() return false end,
	} )

	table.insert( options, {
		type = "checkbox",
		name = "Show Separate Progress Bar",
		tooltip = "" ..
			"This setting controls where the progress bar is displayed for longer-running tasks, such as large group edits, " ..
			"copy/paste operations, backup restores, etc.\n\n" ..
			"Toggle this OFF to display a progress bar that is attached to the primary Essential Housing Tools window.\n\n" ..
			"Toggle this ON to display a separate progress bar that remains visible even when the primary Essential Housing " ..
			"Tools window is hidden.",
		key = "ShowSeparateProgressBar",
		getFunc = function() return EHT.GetSetting( "ShowSeparateProgressBar" ) end,
		setFunc = function(value)
			EHT.SavedVars.ShowSeparateProgressBar = value
		end,
		default = true,
		disabled = function() return false end,
	} )

	table.insert( options, {
		type = "checkbox",
		name = "Hide Essential Housing Tools Keybinds",
		tooltip = "Toggle this ON if your Housing Editor keybind strip at the bottom of the screen is too cluttered.",
		getFunc = function() return EHT.SavedVars.HideKeybinds end,
		setFunc = function(value) EHT.SavedVars.HideKeybinds = value end,
		default = EHT.SAVED_VARS_DEFAULTS.HideKeybinds,
		disabled = function() return false end,
	} )

	table.insert( options, {
		type = "checkbox",
		name = "Hide Housing Editor button",
		tooltip = "Toggle this ON to hide the standard |cdddd22Housing Editor|r and |cdddd22Go to Entrance|r buttons found at the bottom right corner of the screen.",
		getFunc = function() return EHT.SavedVars.HideHousingEditorHUDButton end,
		setFunc = function(value) EHT.SavedVars.HideHousingEditorHUDButton = value EHT.UI.RefreshHousingHUDButton() end,
		default = EHT.SAVED_VARS_DEFAULTS.HideHousingEditorHUDButton,
		disabled = function() return false end,
	} )

	table.insert( options, {
		type = "checkbox",
		name = "Hide Housing Editor undo history",
		tooltip = "Toggle this ON to hide the standard |cdddd22Housing Editor|r's |cdddd22History|r panel located on the far right side of the screen.",
		getFunc = function() return EHT.SavedVars.HideHousingEditorUndoStack end,
		setFunc = function(value) EHT.SavedVars.HideHousingEditorUndoStack = value EHT.UI.SetupHousingEditorUndoStack() end,
		default = EHT.SAVED_VARS_DEFAULTS.HideHousingEditorUndoStack,
		disabled = function() return false end,
	} )
--[[
	table.insert( options, {
		type = "checkbox",
		name = "Enable Remote Scene Sound Effects",
		tooltip = "Toggle this ON to send and receive Scene Sound Effects to and from other players in your group.\n\n" ..
			"NOTE: Enabling this setting will enable the use of \"Map Pings\" in order to communicate with other players' game clients.",
		key = "EnableMapcast",
		default = true,
		getFunc = function()
			return EHT.GetSetting( "EnableMapcast" )
		end,
		setFunc = function(value)
			EHT.SavedVars.EnableMapcast = value
			EHT.Mapcast.OnMapcastStateChanged()
		end,
		disabled = function() return false end,
	} )
]]

	table.insert( options, {
		type = "custom",
	} )


	table.insert( options, {
		type = "header",
		name = "Quality of Life",
	} )

	table.insert( options, {
		type = "checkbox",
		name = "Enable Essential Preview(TM)",
		tooltip = "|cffffffWhen toggled ON, the |c33ffffMeasure|cffffff and |c33ffffPan/Tilt|cffffff controls will " ..
			"be available whenever you preview a furniture item in the bank, housing editor, Crown store, guild store, etc.\n\n" ..
			"|c33ffffMeasure|cffffff toggles ON/OFF the rulers and comparative examples of scale (Tythis the Banker and a single, " ..
			"standard Alinor Bookshelf unit).\n\n" ..
			"|c33ffffPan/Tilt|cffffff allows you to slide the camera left/right and up/down in order to get a more comprehensive " ..
			"view of the Preview Item.",
		key = "EnableEssentialPreview",
		getFunc = function() return EHT.GetSetting( "EnableEssentialPreview" ) end,
		setFunc = function(value) EHT.SavedVars.EnableEssentialPreview = value end,
		default = true,
		disabled = function() return false end,
	} )

	s = function( value )
		EHT.SavedVars.EnableQuickPlacement = value
		if EHT.UI.UIExt.FurniturePlacementInstructions then EHT.UI.UIExt.FurniturePlacementInstructions:SetHidden( not value ) end
	end
	s( EHT.SavedVars.EnableQuickPlacement )

	table.insert( options, {
		type = "checkbox",
		name = "Right-click to place from Editor's \"Place\" Tab",
		tooltip = "When enabled, you can right-click items in the Housing Editor's \"Place\" tab to place them without previewing them first.",
		getFunc = function() return EHT.SavedVars.EnableQuickPlacement end,
		setFunc = s,
		default = EHT.SAVED_VARS_DEFAULTS.EnableQuickPlacement,
		disabled = function() return false end,
	} )

	s = function( value )
		EHT.SavedVars.EnableQuickRetrieval = value
		if EHT.UI.UIExt.FurnitureRetrievalInstructions then EHT.UI.UIExt.FurnitureRetrievalInstructions:SetHidden( not value ) end
	end
	s( EHT.SavedVars.EnableQuickRetrieval )

	table.insert( options, {
		type = "checkbox",
		name = "Right-click to put away from Editor's \"Retrieve\" Tab",
		tooltip = "When enabled, you can right-click items in the Housing Editor's \"Retrieve\" tab to put them away without previewing them first.",
		getFunc = function() return EHT.SavedVars.EnableQuickRetrieval end,
		setFunc = s,
		default = EHT.SAVED_VARS_DEFAULTS.EnableQuickRetrieval,
		disabled = function() return false end,
	} )

	table.insert( options, {
		type = "checkbox",
		name = "Right-click to Fast Travel from Map \"Houses\" tab",
		tooltip = "When toggled ON, you may right-click any house on the World Map |cffffffHouses|r tab to fast travel there.",
		getFunc = function() return EHT.SavedVars.EnableHouseMapJumping end,
		setFunc = function(value) EHT.SavedVars.EnableHouseMapJumping = value end,
		default = EHT.SAVED_VARS_DEFAULTS.EnableHouseMapJumping,
		disabled = function() return false end,
	} )

	table.insert( options, {
		type = "checkbox",
		name = "Summon and dismiss Assistants with Quickslots",
		tooltip = "When toggled ON, activating the Banker, Merchant or Smuggler from your Quickslot radial menu will automatically summon that assistant to your side. Activate again to dismiss the assistant back to wherever he or she was originally.\n\nNote: This feature only works in your own homes and requires that you have previously placed your assistant(s) within the home.",
		getFunc = function() return EHT.SavedVars.SummonAssistants end,
		setFunc = function(value) EHT.SavedVars.SummonAssistants = value EHT.SuppressAssistantSummoningDisabledWarning = false end,
		default = EHT.SAVED_VARS_DEFAULTS.SummonAssistants,
		disabled = function() return false end,
	} )

	table.insert( options, {
		type = "checkbox",
		name = "Automatically Repair Crafting Stations",
		tooltip = "When toggled ON, Crafting Stations will be auto-repaired upon entering any house that you own.",
		getFunc = function() return EHT.SavedVars.AutoRepairStations end,
		setFunc = function(value) EHT.SavedVars.AutoRepairStations = value end,
		default = EHT.SAVED_VARS_DEFAULTS.AutoRepairStations,
		disabled = function() return false end,
	} )

	table.insert( options, {
		type = "custom",
	} )


	table.insert( options, {
		type = "header",
		name = "Notifications and Warnings",
	} )

	table.insert( options, {
		type = "checkbox",
		name = "Only show new Tutorial Tips",
		tooltip = "When toggled ON, only new tutorial tips that explain recently released features will be shown.\n\nNOTE: If you would like to see previously shown tutorial tips, click the RESET TUTORIALS button below.",
		getFunc = function() return not EHT.Tutorials.OnlyShowNewTutorials() end,
		setFunc = function(value) EHT.Tutorials.DisableTutorials( not value ) end,
		default = true,
		disabled = function() return false end,
	} )
--[[
	table.insert( options, {
		type = "checkbox",
		name = "Show large area selection warning",
		tooltip = "Toggle this ON to show a warning when items that are far from each other are selected to avoid accidentally moving or changing the wrong items.",
		getFunc = function() return EHT.SavedVars.EnableProtractedSelectionCheck end,
		setFunc = function(value) EHT.SavedVars.EnableProtractedSelectionCheck = value if not value then EHT.UI.ShowProtractedSelectionDialog( false ) end end,
		default = EHT.SAVED_VARS_DEFAULTS.EnableProtractedSelectionCheck,
		disabled = function() return false end,
	} )
]]
	table.insert( options, {
		type = "checkbox",
		name = "Ignore House Limits",
		tooltip = "Toggle this ON to suppress prevalidation of house item limits before pasting furniture. NOTE: This setting will automatically toggle OFF when you logoff or reload the User Interface.",
		getFunc = function() return EHT.IgnoreHouseLimits end,
		setFunc = function(value) EHT.IgnoreHouseLimits = value end,
		default = false,
		disabled = function() return false end,
		isDangerous = true,
		warning = "Only set this to ON if you are receiving an incorrect error message regarding item limits when pasting furniture.",
	} )

	table.insert( options, {
		type = "checkbox",
		name = "Load Scene Warnings",
		tooltip = "When loading a Scene, displays a warning that all Scene furniture will be moved to their positions in the first frame of the scene.",
		getFunc = function() return EHT.SavedVars.WarnLoadScene end,
		setFunc = function(value) EHT.SavedVars.WarnLoadScene = value end,
		default = EHT.SAVED_VARS_DEFAULTS.WarnLoadScene,
		disabled = function() return false end,
	} )

	table.insert( options, {
		type = "checkbox",
		name = "Backup Notifications",
		tooltip = "When toggled ON, a brief notification will be shown when a new backup is created for your home.\n\n" ..
			"NOTE: A new backup is automatically created upon entering/leaving your home - and only if changes have been made during or since your previous/current visit.",
		getFunc = function() return false ~= EHT.SavedVars.ShowBackupNotifications end,
		setFunc = function(value) EHT.SavedVars.ShowBackupNotifications = value end,
		default = true,
		disabled = function() return false end,
	} )

	table.insert( options, {
		type = "checkbox",
		name = "Log Selection/Deselection to Chat",
		tooltip = "When toggled ON, items that you select / deselect will be displayed in the Chat window.",
		getFunc = function() return EHT.SavedVars.ShowSelectionInChat end,
		setFunc = function(value) EHT.SavedVars.ShowSelectionInChat = value end,
		default = EHT.SAVED_VARS_DEFAULTS.ShowSelectionInChat,
		disabled = function() return false end,
	} )

	table.insert( options, {
		type = "checkbox",
		name = "Display Confirmation of Selection/Deselection",
		tooltip = "When toggled ON, a brief message will be shown in the center of the screen to confirm your selection / deselection of items.",
		key = "ShowSelectionInOSD",
		getFunc = function() return EHT.GetSetting( "ShowSelectionInOSD" ) end,
		setFunc = function(value) EHT.SavedVars.ShowSelectionInOSD = value end,
		default = true,
		disabled = function() return false end,
	} )

	table.insert( options, {
		type = "checkbox",
		name = "Undo / Redo Notifications",
		tooltip = "When toggled ON, changes that you Undo or Redo will be displayed in the Chat window.",
		getFunc = function() return EHT.SavedVars.ShowUndoRedoInChat end,
		setFunc = function(value) EHT.SavedVars.ShowUndoRedoInChat = value end,
		default = EHT.SAVED_VARS_DEFAULTS.ShowUndoRedoInChat,
		disabled = function() return not EHT.SavedVars.EnableHouseHistory end,
	} )

	table.insert( options, {
		type = "checkbox",
		name = "Trigger Notifications",
		tooltip = "When toggled ON, running Triggers will be displayed in the Chat window.",
		getFunc = function() return EHT.SavedVars.ShowTriggersInChat end,
		setFunc = function(value) EHT.SavedVars.ShowTriggersInChat = value end,
		default = EHT.SAVED_VARS_DEFAULTS.ShowTriggersInChat,
		disabled = function() return false end,
	} )


	table.insert( options, {
		type = "custom",
	} )


	table.insert( options, {
		type = "header",
		name = "Transfer / Reset Settings",
	} )

	table.insert( options, {
		type = "button",
		name = "My @Name Changed",
		func = function()
			EHT.UI.ShowTransferDataDialog()
		end,
		tooltip = "Transfer saved data, including backups, FX, history, scenes, selections and triggers, from your previous @player name.\n\n" ..
			"|cff9900This transfer should only be used if you have recently changed your @player name.|r",
		disabled = function() return false end,
	} )

	table.insert( options, {
		type = "button",
		name = "Repair Corrupt Database",
		func = function()
			if not EHT.Interop.EHTSaverRestoreMostRecentArchive() then
				EHT.UI.ShowAlertDialog( "Restore Failed", "Failed to restore most recent save data archive." )
				return false
			end

			return false
		end,
		tooltip = "Restores your save data in the event of total data loss due to a corrupt Saved Variables file.",
		disabled = function() return 1 > EHT.Interop.GetEHTSaverAPI() end,
		isDangerous = true,
		warning = "Are you sure that you want to restore your save data from the most recent archive?\n\n" ..
			"You should only do this if you experience a total loss of your saved data as a result " ..
			"of a corrupt Saved Variables file.\n\n" ..
			"NOTE: This will require a UI reload.",
		requiresReload = false,
	} )

	table.insert( options, {
		type = "button",
		name = "Clear Shared FX Cache",
		func = function()
			EHT.Data.ResetEffectsCache()
			EHT.UI.ShowAlertDialog( "", "All locally cached FX data for OTHER Players' homes has been cleared." )
		end,
		tooltip = "Clears all FX data stored for OTHER Players' homes.",
		disabled = function() return false end,
		isDangerous = true,
		warning = "Clear all FX data stored for OTHER Players' homes?\n\n" ..
			"After doing this, players will have to share their FX with you again, or publish their FX to the Community (if you also have the Community app installed), in order for you to see them.",
	} )

	table.insert( options, {
		type = "button",
		name = "Unlock All Items",
		func = function() EHT.Data.ResetLocks() end,
		tooltip = "Unlocks all items in the current house.",
		disabled = function() return false end,
		isDangerous = true,
		warning = "Unlock all items in the current house?",
	} )

	table.insert( options, {
		type = "button",
		name = "Reset Tutorials",
		func = function() EHT.Tutorials.ResetTutorials() ReloadUI() end,
		tooltip = "Resets all tutorial tips so that they will be shown again.",
		disabled = function() return false end,
		isDangerous = true,
		warning = "** Requires reload of the User Interface **",
		requiresReload = true,
	} )

	table.insert( options, {
		type = "button",
		name = "Reset Windows",
		func = function() EHT.UI.ResetAllDialogSettings() ReloadUI() end,
		tooltip = "Resets all window positions and sizes to their defaults.\n\nNOTE: Requires reload of UI.",
		disabled = function() return false end,
		isDangerous = true,
		warning = "** Requires reload of the User Interface **",
		requiresReload = true,
	} )

	table.insert( options, {
		type = "button",
		name = "Reset All Change History",
		func = function() EHT.CT.ClearAllHistory() ReloadUI() end,
		tooltip = "Resets the change history for all houses. This will make it impossible to Undo any recent changes.\n\nNOTE: Requires reload of UI.",
		disabled = function() return false end,
		isDangerous = true,
		warning = "All change history for all houses will be lost and it will be impossible to Undo any recent changes.\n\n** Requires reload of the User Interface **",
		requiresReload = true,
	} )

	table.insert( options, {
		type = "button",
		name = "Reset All Selections",
		func = function() EHT.Data.ResetAllGroups() ReloadUI() end,
		tooltip = "Resets the clipboard and all houses' saved selections.\n\nNOTE: Requires reload of UI.",
		disabled = function() return false end,
		isDangerous = true,
		warning = "All saved selections for all houses, as well as the clipboard, will be lost.\n\n** Requires reload of the User Interface **",
		requiresReload = true,
	} )

	table.insert( options, {
		type = "button",
		name = "Reset All Scenes",
		func = function() EHT.Data.ResetAllScenes() ReloadUI() end,
		tooltip = "Resets all houses' saved animation scenes.\n\nNOTE: Requires reload of UI.",
		disabled = function() return false end,
		isDangerous = true,
		warning = "All saved animation scenes for all houses will be lost.\n\n** Requires reload of the User Interface **",
		requiresReload = true,
	} )

	table.insert( options, {
		type = "button",
		name = "RESET ALL DATA",
		func = function() EHT.Data.ResetEverything() ReloadUI() end,
		tooltip = "Resets all settings and all saved selections, scenes, triggers and FX.\n\nNOTE: Requires reload of UI.",
		disabled = function() return false end,
		isDangerous = true,
		warning = "Clipboard, window positions and all saved selections and animation scenes for all houses will be lost.\n\n** Requires reload of the User Interface **",
		requiresReload = true,
	} )

	for index, opt in ipairs(options) do
		if opt.key and nil ~= opt.default then
--[[
			local defaultOptions =
			{
				minValue = opt.min,
				maxValue = opt.max,
				percent = opt.percent,
			}
]]
			EHT.SetDefaultSetting(opt.key, opt.default) -- , defaultOptions)
		end
	end

	LAM:RegisterOptionControls(ADDON_ID, options)
end

function EHT.Setup.ShowSettings()
	if EHT.LAMPanel then
		LAM:OpenToPanel( EHT.LAMPanel )
		return true
	else
		return false
	end
end

function EHT.Setup.GetEditDelay()
	local editSpeed = EHT.SavedVars.EditSpeed
	if nil == editSpeed or 1 > editSpeed then
		return EHT.CONST.HOUSING_REQUEST_DELAY_MIN
	else
		return EHT.CONST.HOUSING_REQUEST_DELAY_MIN + ( ( 100 - editSpeed ) * 9 )
	end
end

function EHT.Setup.GetStateDelay()
	return EHT.CONST.HOUSING_STATE_REQUEST_DELAY_MIN
end

function EHT.Setup.GetMaxDeferredEditDelay()
	local enabled = EHT.SavedVars.EnableSmoothMotion
	if nil == enabled then enabled = true end
	if enabled then
		return EHT.CONST.HOUSING_REQUEST_MAX_DEFERRED_DELAY
	end
	return EHT.CONST.HOUSING_REQUEST_DELAY_MIN
end

-- Enable the Keybind Chording (ALT+key or CTRL+key or SHIFT+key) feature.

if not KEYBINDING_MANAGER.IsChordingAlwaysEnabled or not KEYBINDING_MANAGER:IsChordingAlwaysEnabled() then
	function KEYBINDING_MANAGER:IsChordingAlwaysEnabled()
		return true
	end
end

do
	local stringTable = { }

	function EHT.Setup.SetupKeybindStringId( layerName, stringName, stringText, defaultKeycode )
		local stringKey = string.sub( stringName, 17 ) -- Exclude the "SI_BINDING_NAME_" prefix.
		stringTable[ stringKey ] =
		{
			layerName = layerName,
			stringName = stringName,
			text = stringText,
			defaultKeycode = defaultKeycode,
		}
		ZO_CreateStringId( stringName, stringText )
	end
	
	function EHT.Setup.GetKeybindStringIds()
		return stringTable
	end
end

function EHT.Setup.SetupStrings()
	local layers =
	{
		"General",
		"Housing Editor",
		"Housing HUD",
		"Essential Housing Tools (Interaction)", -- "Special Keys:",
	}

	do
		local layerName = layers[1]
		EHT.Setup.SetupKeybindStringId( layerName, "SI_BINDING_NAME_EHT_HOUSING_HUB", "Essential Housing Hub", { KEY_H, KEY_ALT, 0, 0, 0 } )
		EHT.Setup.SetupKeybindStringId( layerName, "SI_BINDING_NAME_EHT_SHOW_HIDE_FX", "Show/Hide All FX" )
		EHT.Setup.SetupKeybindStringId( layerName, "SI_BINDING_NAME_EHT_SHOW_HIDE_EDIT_FX", "Show/Hide FX Paint Cans" )
		EHT.Setup.SetupKeybindStringId( layerName, "SI_BINDING_NAME_EHT_PLACE_ALL_FURNITURE", "Place All Furniture" )
		EHT.Setup.SetupKeybindStringId( layerName, "SI_BINDING_NAME_EHT_HOME", "Jump Home" )
		EHT.Setup.SetupKeybindStringId( layerName, "SI_BINDING_NAME_EHT_FAV_HOUSE_1", "Jump to Favorite House 1" )
		EHT.Setup.SetupKeybindStringId( layerName, "SI_BINDING_NAME_EHT_FAV_HOUSE_2", "Jump to Favorite House 2" )
		EHT.Setup.SetupKeybindStringId( layerName, "SI_BINDING_NAME_EHT_FAV_HOUSE_3", "Jump to Favorite House 3" )
		EHT.Setup.SetupKeybindStringId( layerName, "SI_BINDING_NAME_EHT_FAV_HOUSE_4", "Jump to Favorite House 4" )
		EHT.Setup.SetupKeybindStringId( layerName, "SI_BINDING_NAME_EHT_FAV_HOUSE_5", "Jump to Favorite House 5" )
		EHT.Setup.SetupKeybindStringId( layerName, "SI_BINDING_NAME_EHT_FAV_HOUSE_6", "Jump to Favorite House 6" )
		EHT.Setup.SetupKeybindStringId( layerName, "SI_BINDING_NAME_EHT_FAV_HOUSE_7", "Jump to Favorite House 7" )
		EHT.Setup.SetupKeybindStringId( layerName, "SI_BINDING_NAME_EHT_FAV_HOUSE_8", "Jump to Favorite House 8" )
		EHT.Setup.SetupKeybindStringId( layerName, "SI_BINDING_NAME_EHT_FAV_HOUSE_9", "Jump to Favorite House 9" )
		EHT.Setup.SetupKeybindStringId( layerName, "SI_BINDING_NAME_EHT_FAV_HOUSE_10", "Jump to Favorite House 10" )
	end

	do
		local layerName = layers[2]
		EHT.Setup.SetupKeybindStringId( layerName, "SI_BINDING_NAME_EHT_COPY_SELECTION", "Copy Selection" )
		EHT.Setup.SetupKeybindStringId( layerName, "SI_BINDING_NAME_EHT_CUT_SELECTION", "Cut Selection" )
		EHT.Setup.SetupKeybindStringId( layerName, "SI_BINDING_NAME_EHT_PASTE_CLIPBOARD", "Paste Clipboard" )
		EHT.Setup.SetupKeybindStringId( layerName, "SI_BINDING_NAME_EHT_SNAP_FURNITURE", "Snap Furniture Items", { KEY_Y, 0, 0, 0, 0 } )
		EHT.Setup.SetupKeybindStringId( layerName, "SI_BINDING_NAME_EHT_UNDO", "Undo" )
		EHT.Setup.SetupKeybindStringId( layerName, "SI_BINDING_NAME_EHT_REDO", "Redo" )
		EHT.Setup.SetupKeybindStringId( layerName, "SI_BINDING_NAME_EHT_QUICK_ACTIONS", "Organize", { KEY_O, 0, 0, 0, 0 } )
		EHT.Setup.SetupKeybindStringId( layerName, "SI_BINDING_NAME_EHT_EDIT_POSITION", "Edit Item Details", { KEY_E, KEY_SHIFT, 0, 0, 0 } )
		EHT.Setup.SetupKeybindStringId( layerName, "SI_BINDING_NAME_EHT_SELECT_DESELECT", "Select / Deselect", { KEY_G, 0, 0, 0, 0 } )
		EHT.Setup.SetupKeybindStringId( layerName, "SI_BINDING_NAME_EHT_DESELECT_ALL", "Deselect All Items" )
		EHT.Setup.SetupKeybindStringId( layerName, "SI_BINDING_NAME_EHT_SHOW_SELECTION", "Show Selection Window", { KEY_F1, 0, 0, 0, 0 } )
		EHT.Setup.SetupKeybindStringId( layerName, "SI_BINDING_NAME_EHT_SAVE_FRAME", "Save Frame" )
		EHT.Setup.SetupKeybindStringId( layerName, "SI_BINDING_NAME_EHT_SAVE_FRAME_AND_INSERT", "Save & Insert New Frame" )
		EHT.Setup.SetupKeybindStringId( layerName, "SI_BINDING_NAME_EHT_MOVE_SELECTION_FORWARD", "Move Forward / North" )
		EHT.Setup.SetupKeybindStringId( layerName, "SI_BINDING_NAME_EHT_MOVE_SELECTION_BACKWARD", "Move Backward / South" )
		EHT.Setup.SetupKeybindStringId( layerName, "SI_BINDING_NAME_EHT_MOVE_SELECTION_LEFT", "Move Left / West" )
		EHT.Setup.SetupKeybindStringId( layerName, "SI_BINDING_NAME_EHT_MOVE_SELECTION_RIGHT", "Move Right / East" )
		EHT.Setup.SetupKeybindStringId( layerName, "SI_BINDING_NAME_EHT_MOVE_SELECTION_UP", "Move Up" )
		EHT.Setup.SetupKeybindStringId( layerName, "SI_BINDING_NAME_EHT_MOVE_SELECTION_DOWN", "Move Down" )
		EHT.Setup.SetupKeybindStringId( layerName, "SI_BINDING_NAME_EHT_MOVE_SELECTION_ROTATECW", "Rotate Clockwise" )
		EHT.Setup.SetupKeybindStringId( layerName, "SI_BINDING_NAME_EHT_MOVE_SELECTION_ROTATECCW", "Rotate Counterclockwise" )
		EHT.Setup.SetupKeybindStringId( layerName, "SI_BINDING_NAME_EHT_TOGGLE_MOVE_SPEED", "Toggle Move Speed" )
		EHT.Setup.SetupKeybindStringId( layerName, "SI_BINDING_NAME_EHT_INCREASE_MOVE_SPEED", "Increase Move Speed" )
		EHT.Setup.SetupKeybindStringId( layerName, "SI_BINDING_NAME_EHT_DECREASE_MOVE_SPEED", "Decrease Move Speed" )
	end

	do
		local layerName = layers[3]
		EHT.Setup.SetupKeybindStringId( layerName, "SI_BINDING_NAME_EHT_SUMMON_STORAGE", "Summon Assistants & Storage", { KEY_S, KEY_ALT, 0, 0, 0 } )
		EHT.Setup.SetupKeybindStringId( layerName, "SI_BINDING_NAME_EHT_SUMMON_CRAFTING", "Summon Craft Workshop", { KEY_C, KEY_ALT, 0, 0, 0 } )
		EHT.Setup.SetupKeybindStringId( layerName, "SI_BINDING_NAME_EHT_TOGGLE_BUTTON", "Toggle EHT Button (Temporarily)" )
	end

	do
		local layerName = layers[4]
		EHT.Setup.SetupKeybindStringId( layerName, "SI_BINDING_NAME_EHT_SHOW_GUEST_JOURNAL", "Show Guest Journal", { KEY_MOUSE_LEFT, 0, 0, 0, 0 } )
	end
end

function EHT.Setup.GetKeybind( bindingName )
	local layerIndex, categoryIndex, actionIndex = GetActionIndicesFromName( bindingName )
	return GetActionBindingInfo( layerIndex, categoryIndex, actionIndex )
end

function EHT.Setup.GetSavedKeybinds()
	local keybinds = EHT.SavedVars.SavedKeybinds
	if "table" ~= type( keybinds ) then
		keybinds = { }
		EHT.SavedVars.SavedKeybinds = keybinds
	end
	return keybinds
end

function EHT.Setup.GetSavedKeybind( bindingName, defaultKeycode )
	local keybinds = EHT.Setup.GetSavedKeybinds()
	local keybind = keybinds[bindingName]
	if "table" ~= type( keybind ) then
		keybind = { }
		if "table" == type( defaultKeycode ) then
			EHT.Setup.SetDefaultKeybind( bindingName, keybind, defaultKeycode )
		end
		keybinds[bindingName] = keybind
	end
	return keybind
end

function EHT.Setup.ClearSavedKeybind( bindingName )
	local keybinds = EHT.Setup.GetSavedKeybinds()
	local keybind = { }
	keybinds[bindingName] = keybind
	return keybind
end

function EHT.Setup.SetDefaultKeybind( bindingName, keybind, defaultKeybind )
	if "table" ~= type( keybind ) or "table" ~= type( defaultKeybind ) or defaultKeybind[1] == 0 then
		return
	end
	local defaultKeycode = defaultKeybind[1]

	local keybindStringIds = EHT.Setup.GetKeybindStringIds()
	local keybindStringData = keybindStringIds[bindingName]
	if "table" ~= type( keybindStringData ) or not keybindStringData.layerName then
		return
	end

	local existingBindingName = GetActionNameFromKey( keybindStringData.layerName, defaultKeycode )
	if "" ~= existingBindingName then
		-- The requested 'default' key code is already assigned to an action on this layer.
		local layerIndex, categoryIndex, actionIndex = GetActionIndicesFromName( existingBindingName )
		for keycodeIndex = 1, 4 do
			local keycode, modifier1, modifier2, modifier3, modifier4 = GetActionBindingInfo( layerIndex, categoryIndex, actionIndex, keycodeIndex )
			if keycode == defaultKeycode and modifier1 == defaultKeybind[2] and modifier2 == defaultKeybind[3] and modifier3 == defaultKeybind[4] and modifier4 == defaultKeybind[5] then
				-- The existing keybind matches exactly; do not assign the default keybind.
				return
			end
		end
	end

	keybind[1] = EHT.Util.CloneTable( defaultKeybind )
end

function EHT.Setup.LoadKeybind( bindingName, defaultKeycode )
	local layerIndex, categoryIndex, actionIndex = GetActionIndicesFromName( bindingName )
	if layerIndex and categoryIndex and actionIndex then
		local savedKeybind = EHT.Setup.GetSavedKeybind( bindingName, defaultKeycode )

		-- Clear existing keybinds, if any.
		if IsProtectedFunction( "UnbindAllKeysFromAction" ) then
			CallSecureProtected( "UnbindAllKeysFromAction", layerIndex, categoryIndex, actionIndex )
		else
			UnbindAllKeysFromAction( layerIndex, categoryIndex, actionIndex )
		end

		for keycodeIndex, keycodeData in pairs( savedKeybind ) do
			if IsProtectedFunction( "BindKeyToAction" ) then
				CallSecureProtected( "BindKeyToAction", layerIndex, categoryIndex, actionIndex, keycodeIndex, keycodeData[1], keycodeData[2], keycodeData[3], keycodeData[4], keycodeData[5] )
			else
				BindKeyToAction( layerIndex, categoryIndex, actionIndex, keycodeIndex, keycodeData[1], keycodeData[2], keycodeData[3], keycodeData[4], keycodeData[5] )
			end
		end
	end
end

function EHT.Setup.SaveKeybind( bindingName )
	local layerIndex, categoryIndex, actionIndex = GetActionIndicesFromName( bindingName )
	local savedKeybind = EHT.Setup.ClearSavedKeybind( bindingName )

	if layerIndex and categoryIndex and actionIndex then
		for keycodeIndex = 1, 4 do
			local keycode, modifier1, modifier2, modifier3, modifier4 = GetActionBindingInfo( layerIndex, categoryIndex, actionIndex, keycodeIndex )
			if keycode ~= 0 then
				savedKeybind[keycodeIndex] = { keycode, modifier1, modifier2, modifier3, modifier4 }
			end
		end
	end
end

do
	local initialized = false
	local loadingKeybinds = false
	
	function EHT.Setup.LoadKeybinds()
		if loadingKeybinds then
			return
		end
		loadingKeybinds = true

		local numLoaded = 0
		local keybindStringIds = EHT.Setup.GetKeybindStringIds()
		for stringKey, stringData in pairs( keybindStringIds ) do
			EHT.Setup.LoadKeybind( stringKey, stringData.defaultKeycode )
			numLoaded = numLoaded + 1
		end

		loadingKeybinds = false
		initialized = true
	end

	function EHT.Setup.SaveKeybinds()
		if loadingKeybinds then
			return
		end
		
		local keybindStringIds = EHT.Setup.GetKeybindStringIds()
		if initialized then
			for stringKey in pairs( keybindStringIds ) do
				EHT.Setup.SaveKeybind( stringKey )
			end
		else
			EHT.Setup.LoadKeybinds()
		end
	end
end

function EHT.CleanDefaultSettings()
	local defaults = EHT.DefaultSettings
	local vars = EHT.SavedVars
	if defaults and vars then
		for settingName, setting in pairs(EHT.DefaultSettings) do
			local defaultSetting = setting.value
			if nil ~= defaultSetting and type(defaultSetting) ~= type(vars[settingName]) then
				vars[settingName] = nil
			end
		end
	end
end

function EHT.GetDefaultSetting(name)
	local defaultSetting = EHT.DefaultSettings[name]
	return defaultSetting and defaultSetting.value or nil
end

function EHT.SetDefaultSetting(name, value) -- , options)
	if "string" == type(name) and "" ~= name then
		local setting =
		{
			name = name,
			value = value,
		}

		EHT.DefaultSettings[name] = setting
	end
end

function EHT.ResetDefaultSettings()
	local vars = EHT.SavedVars
	if vars then
		for settingName in pairs(EHT.DefaultSettings) do
			vars[settingName] = nil
		end
	end
end

function EHT.GetSetting(name)
	local defaultSettings = EHT.DefaultSettings
	local defaultSetting = defaultSettings and defaultSettings[name] or nil
	local defaultValue = defaultSetting and defaultSetting.value
	if EHT.SavedVars then
		local value = EHT.SavedVars[name]

		if nil ~= value and nil ~= defaultValue then
			local defaultType = type(defaultValue)
			if defaultType ~= type(value) then
				if "string" == defaultType then
					value = tostring(value)
				elseif "number" == defaultType then
					value = tonumber(value)
				elseif "boolean" == defaultType then
					value = false ~= value
				end
			end
		end

		if nil ~= value then
			return value
		end
	end
	return defaultValue
end

function EHT.GetBooleanSetting(name)
	local value = EHT.GetSetting(name)
	if nil == value and EHT.DefaultSettings then
		local defaultSetting = EHT.DefaultSettings[name]
		value = defaultSetting and defaultSetting.value
	end
	return true == value
end

function EHT.GetNumericSetting(name)
	local value = tonumber(EHT.GetSetting(name))
	if nil == value and EHT.DefaultSettings then
		local defaultSetting = EHT.DefaultSettings[name]
		value = defaultSetting and defaultSetting.value
	end
	return tonumber(value)
end

function EHT.SetSetting(name, value)
	if EHT.SavedVars then
		EHT.SavedVars[name] = value
	end
end

EHT.Modules = ( EHT.Modules or { } ) EHT.Modules.EssentialHousingTools = true