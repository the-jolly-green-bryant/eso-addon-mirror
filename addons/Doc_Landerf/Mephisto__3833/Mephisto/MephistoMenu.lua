Mephisto = Mephisto or {}
local MP = Mephisto

MP.menu = {}
local MPM = MP.menu

function MPM.Init()
	MPM.InitSV()
	MPM.InitAM()
end

local addonMenuChoices = {
	names = {
		GetString( MP_MENU_COMPARISON_DEPTH_EASY ),
		GetString( MP_MENU_COMPARISON_DEPTH_DETAILED ),
		GetString( MP_MENU_COMPARISON_DEPTH_THOROUGH ),
		GetString( MP_MENU_COMPARISON_DEPTH_STRICT )
	},
	values = {
		1,
		2,
		3,
		4
	},
	tooltips = {
		GetString( MP_MENU_COMPARISON_DEPTH_EASY_TT ),
		GetString( MP_MENU_COMPARISON_DEPTH_DETAILED_TT ),
		GetString( MP_MENU_COMPARISON_DEPTH_THOROUGH_TT ),
		GetString( MP_MENU_COMPARISON_DEPTH_STRICT_TT )
	}
}
function MPM.InitSV()
	MP.storage = ZO_SavedVars:NewCharacterIdSettings( "MephistoSV", 1, nil, {
		setups = {},
		pages = {},
		prebuffs = {},
		autoEquipSetups = true,
	} )
	MP.setups = MP.storage.setups
	MP.pages = MP.storage.pages
	MP.prebuffs = MP.storage.prebuffs

	MP.settings = ZO_SavedVars:NewAccountWide( "MephistoSV", 1, nil, {
		window = {
			wizard = {
				width = 360,
				height = 665,
				scale = 1,
				locked = false,
			},
		},
		panel = {
			locked = true,
			hidden = false,
			mini = false,
		},
		auto = {
			gear = true,
			skills = true,
			cp = true,
			food = true,
		},
		substitute = {
			overland = false,
			dungeons = false,
		},
		fixes = {
			surfingWeapons = false,
		},
		failedSwapLog = {},
		comparisonDepth = 1,
		changelogs = {},
		printMessages = "chat",
		overwriteWarning = true,
		inventoryMarker = true,
		ignoreTabards = true,
		unequipEmpty = false,
		chargeWeapons = false,
		repairArmor = false,
		fillPoisons = false,
		eatBuffFood = false,
		initialized = false,
		fixGearSwap = false,
		validationDelay = 1500
	} )

	-- migrate printMessage settings
	if MP.settings.printMessages == true then
		MP.settings.printMessages = "chat"
	elseif MP.settings.printMessages == false then
		MP.settings.printMessages = "off"
	end

	-- dont look at this
	MP.settings.autoEquipSetups = MP.storage.autoEquipSetups
end

function MPM.InitAM()
	local panelData = {
		type = "panel",
		name = MP.simpleName,
		displayName = MP.displayName:upper(),
		author = "|c66CCFF@Kloox|r, |cFF66CC@Killgt|r, |cFFCC66@Doc_Landerf|r",
		version = MP.version,
		registerForRefresh = true,
	}

	local optionData = {
		{
			type = "description",
			text = "|ca5cd84M|caca665E|cae7A49P|ca91922H|cc2704DI|cd8b080S|ce1c895T|ce4d09dO|, A fork of Wizards wardrobes.",
		},
		{
			type = "header",
			name = GetString( MP_MENU_GENERAL ),
		},

		{
			type = "dropdown",
			name = GetString( MP_MENU_PRINTCHAT ),
			choices = {
				GetString( MP_MENU_PRINTCHAT_OFF ),
				GetString( MP_MENU_PRINTCHAT_CHAT ),
				GetString( MP_MENU_PRINTCHAT_ALERT ),
				GetString( MP_MENU_PRINTCHAT_ANNOUNCEMENT )
			},
			choicesValues = { "off", "chat", "alert", "announcement" },
			getFunc = function() return MP.settings.printMessages end,
			setFunc = function( value ) MP.settings.printMessages = value end,
			tooltip = GetString( MP_MENU_PRINTCHAT_TT ),
		},
		{
			type = "checkbox",
			name = GetString( MP_MENU_OVERWRITEWARNING ),
			getFunc = function() return MP.settings.overwriteWarning end,
			setFunc = function( value ) MP.settings.overwriteWarning = value end,
			tooltip = GetString( MP_MENU_OVERWRITEWARNING_TT ),
		},
		{
			type = "checkbox",
			name = GetString( MP_MENU_INVENTORYMARKER ),
			getFunc = function() return MP.settings.inventoryMarker end,
			setFunc = function( value ) MP.settings.inventoryMarker = value end,
			tooltip = GetString( MP_MENU_INVENTORYMARKER_TT ),
			requiresReload = true,
		},
		{
			type = "checkbox",
			name = GetString( MP_MENU_UNEQUIPEMPTY ),
			getFunc = function() return MP.settings.unequipEmpty end,
			setFunc = function( value ) MP.settings.unequipEmpty = value end,
			tooltip = GetString( MP_MENU_UNEQUIPEMPTY_TT ),
		},
		{
			type = "checkbox",
			name = GetString( MP_MENU_IGNORE_TABARDS ),
			getFunc = function() return MP.settings.ignoreTabards end,
			setFunc = function( value ) MP.settings.ignoreTabards = value end,
			tooltip = GetString( MP_MENU_IGNORE_TABARDS_TT ),
			disabled = function() return not MP.settings.unequipEmpty end, -- only enabled if unequip empty is true

		},
		{
			type = "header",
			name = "Setup Validation",

		},
		{
			type            = "dropdown",
			name            = GetString( MP_MENU_COMPARISON_DEPTH ),
			choices         = addonMenuChoices.names,
			choicesValues   = addonMenuChoices.values,
			choicesTooltips = addonMenuChoices.tooltips,
			disabled        = function() return false end,
			scrollable      = true,
			getFunc         = function() return MP.settings.comparisonDepth end,
			setFunc         = function( var ) MP.settings.comparisonDepth = var end,
			width           = "full",
		},
		{
			type = "checkbox",
			name = GetString( MP_MENU_WEAPON_GEAR_FIX ),
			getFunc = function() return MP.settings.fixGearSwap end,
			setFunc = function( value ) MP.settings.fixGearSwap = value end,
			tooltip = GetString( MP_MENU_WEAPON_GEAR_FIX_TT )

		},
		{
			type = "slider",
			name = GetString( MP_MENU_VALIDATION_DELAY ),
			tooltip = GetString( MP_MENU_VALIDATION_DELAY_TT ),
			warning = GetString( MP_MENU_VALIDATION_DELAY_WARN ),
			getFunc = function() return MP.settings.validationDelay end,
			setFunc = function( value )
				MP.settings.validationDelay = value
			end,
			step = 10,
			min = 1500,
			max = 4500,
			clampInput = true,
			width = "full",
		},
		{
			type = "divider",
			height = 15,
			alpha = 0,
		},
		{
			type = "button",
			name = GetString( MP_MENU_RESETUI ),
			func = MP.gui.ResetUI,
			warning = GetString( MP_MENU_RESETUI_TT ),
		},
		{
			type = "divider",
			height = 15,
			alpha = 0,
		},
		{
			type = "header",
			name = GetString( MP_MENU_AUTOEQUIP ),
		},
		{
			type = "description",
			text = GetString( MP_MENU_AUTOEQUIP_DESC ),
		},
		{
			type = "checkbox",
			name = GetString( MP_MENU_AUTOEQUIP_GEAR ),
			getFunc = function() return MP.settings.auto.gear end,
			setFunc = function( value ) MP.settings.auto.gear = value end,
			width = "half",
		},
		{
			type = "checkbox",
			name = GetString( MP_MENU_AUTOEQUIP_SKILLS ),
			getFunc = function() return MP.settings.auto.skills end,
			setFunc = function( value ) MP.settings.auto.skills = value end,
			width = "half",
		},
		{
			type = "checkbox",
			name = GetString( MP_MENU_AUTOEQUIP_CP ),
			getFunc = function() return MP.settings.auto.cp end,
			setFunc = function( value ) MP.settings.auto.cp = value end,
			width = "half",
		},
		{
			type = "checkbox",
			name = GetString( MP_MENU_AUTOEQUIP_BUFFFOOD ),
			getFunc = function() return MP.settings.auto.food end,
			setFunc = function( value ) MP.settings.auto.food = value end,
			width = "half",
		},
		{
			type = "divider",
			height = 15,
			alpha = 0,
		},
		--[[{
			type = "header",
			name = GetString( MP_MENU_SUBSTITUTE ),
		},
		{
			type = "description",
			text = GetString( MP_MENU_SUBSTITUTE_WARNING ),
		},
		{
			type = "checkbox",
			name = GetString( MP_MENU_SUBSTITUTE_OVERLAND ),
			getFunc = function() return MP.settings.substitute.overland end,
			setFunc = function( value ) MP.settings.substitute.overland = value end,
			tooltip = GetString( MP_MENU_SUBSTITUTE_OVERLAND_TT ),
		},
		{
			type = "checkbox",
			name = GetString( MP_MENU_SUBSTITUTE_DUNGEONS ),
			getFunc = function() return MP.settings.substitute.dungeons end,
			setFunc = function( value ) MP.settings.substitute.dungeons = value end,
		},
		{
			type = "divider",
			height = 15,
			alpha = 0,
		},]]
		{
			type = "header",
			name = GetString( MP_MENU_PANEL ),
		},
		{
			type = "checkbox",
			name = GetString( MP_MENU_PANEL_ENABLE ),
			getFunc = function() return not MP.settings.panel.hidden end,
			setFunc = function( value )
				MP.settings.panel.hidden = not value
				MephistoPanel.fragment:Refresh()
			end,
			tooltip = GetString( MP_MENU_PANEL_ENABLE_TT ),
		},
		{
			type = "checkbox",
			name = GetString( MP_MENU_PANEL_MINI ),
			getFunc = function() return MP.settings.panel.mini end,
			setFunc = function( value )
				MP.settings.panel.mini = value
			end,
			disabled = function() return MP.settings.panel.hidden end,
			tooltip = GetString( MP_MENU_PANEL_MINI_TT ),
			requiresReload = true,
		},
		{
			type = "checkbox",
			name = GetString( MP_MENU_PANEL_LOCK ),
			getFunc = function() return MP.settings.panel.locked end,
			setFunc = function( value )
				MP.settings.panel.locked = value
				MephistoPanel:SetMovable( not value )
			end,
			disabled = function() return MP.settings.panel.hidden end,
		},
		{
			type = "divider",
			height = 15,
			alpha = 0,
		},
		{
			type = "header",
			name = GetString( MP_MENU_MODULES ),
		},
		{
			type = "checkbox",
			name = GetString( MP_MENU_CHARGEWEAPONS ),
			getFunc = function() return MP.settings.chargeWeapons end,
			setFunc = function( value )
				MP.settings.chargeWeapons = value
				MP.repair.RegisterChargeEvents()
			end,
		},
		{
			type = "checkbox",
			name = GetString( MP_MENU_REPAIRARMOR ),
			getFunc = function() return MP.settings.repairArmor end,
			setFunc = function( value )
				MP.settings.repairArmor = value
				MP.repair.RegisterRepairEvents()
			end,
			tooltip = GetString( MP_MENU_REPAIRARMOR_TT ),
		},
		{
			type = "checkbox",
			name = GetString( MP_MENU_FILLPOISONS ),
			getFunc = function() return MP.settings.fillPoisons end,
			setFunc = function( value )
				MP.settings.fillPoisons = value
				MP.poison.RegisterEvents()
			end,
			tooltip = GetString( MP_MENU_FILLPOISONS_TT ),
		},
		{
			type = "checkbox",
			name = GetString( MP_MENU_BUFFFOOD ),
			getFunc = function() return MP.settings.eatBuffFood end,
			setFunc = function( value )
				MP.settings.eatBuffFood = value
				MP.food.RegisterEvents()
			end,
			tooltip = GetString( MP_MENU_BUFFFOOD_TT ),
		},
		{
			type = "checkbox",
			name = GetString( MP_MENU_FIXES_FIXSURFINGWEAPONS ),
			getFunc = function() return MP.settings.fixes.surfingWeapons end,
			setFunc = function( value )
				MP.settings.fixes.surfingWeapons = value
			end,
			tooltip = GetString( MP_MENU_FIXES_FIXSURFINGWEAPONS_TT ),
		},
		{
			type = "header",
			name = "Delete log",
		},
		{
			type = "button",
			name = "Delete",
			danger = true,
			func = function() MP.settings.failedSwapLog = {} end,
			width = "full",
		},
	}


	MPM.panel = LibAddonMenu2:RegisterAddonPanel( "MephistoMenu", panelData )
	LibAddonMenu2:RegisterOptionControls( "MephistoMenu", optionData )
end

