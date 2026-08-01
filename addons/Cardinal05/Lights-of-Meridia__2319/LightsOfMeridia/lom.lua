LightsOfMeridia = LightsOfMeridia or { }
LOM = LightsOfMeridia
local LAM

if not KEYBINDING_MANAGER.IsChordingAlwaysEnabled or not KEYBINDING_MANAGER:IsChordingAlwaysEnabled() then
	function KEYBINDING_MANAGER:IsChordingAlwaysEnabled()
		return true
	end
end

---[ Constants ]---

LOM.Debug = false

LOM.Const = { }
LOM.Const.AddonVersion = 23
LOM.Const.AddonAuthor = "@Cardinal05 (Geezus Take The Heal)"
LOM.Const.AddonName = "LightsOfMeridia"
LOM.Const.AddonTitle = "Lights of Meridia"
LOM.Const.AddonTitleLong = string.format( "%s, version %s", LOM.Const.AddonTitle, tostring( LOM.Const.AddonVersion ) )
LOM.Const.SavedVarsFile = "LightsOfMeridiaVars"
LOM.Const.SavedVarsDefaults = { }
LOM.Const.SavedVarsVersion = 1
LOM.Const.DialogAlert = "LOMDialogAlert"
LOM.Const.DialogConfirm = "LOMDialogConfirm"
LOM.Const.DefaultSettings = { }

LOM.Attribute = { }
LOM.Attribute.Active = 1
LOM.Attribute.Dead = 2
LOM.Attribute.Resurrecting = 3
LOM.Attribute.Leader = 4
LOM.Attribute.Healer = 5
LOM.Attribute.Tank = 6
LOM.Attribute.Battleground = 7
LOM.Attribute.Cyrodiil = 8
LOM.Attribute.NonPVP = 9

LOM.Color = {
	["Auroran Thunder"] = "",
	["Coral Tower Crimson"] = "", 
	["Colored Room Coral"] = "",
	["Groundskeeper's Green"] = "",
	["Darien's Golden Dawnbreaker"] = "",
	["Dynar's Purple Heart"] = "",
	["Hollowcity Ashen Sky"] = "",
	["Infinite Indigo"] = "",
	["Mauve of Malatar"] = "",
	["Magna-Ge Magenta"] = "",
	["Morningstar Maroon"] = "",
	["Oubliette Orange"] = "",
	["Prismatic Pink (Scented)"] = "",
	["Prismatic Pink (Unscented)"] = "","",
}

LOM.RadiantPlayers = { }
LOM.UnitTags = { }
local function InitUnitTags()
	for index = 1, GROUP_SIZE_MAX + 1 do
		if 1 == index then
			LOM.UnitTags[index] = "player"
		else
			LOM.UnitTags[index] = string.format( "group%d", index - 1 )
		end
	end

	LOM.NumUnitTags = #LOM.UnitTags
end
InitUnitTags()

---[ Initialization ]---

do
	local OldShowPlayerInteractMenu

	function LOM.InitPlayerToPlayer()
		if not PLAYER_TO_PLAYER or not PLAYER_TO_PLAYER.ShowPlayerInteractMenu then
			zo_callLater( LOM.InitPlayerToPlayer, 1000 )
			return
		end

		if not OldShowPlayerInteractMenu then
			OldShowPlayerInteractMenu = PLAYER_TO_PLAYER.ShowPlayerInteractMenu
			PLAYER_TO_PLAYER.ShowPlayerInteractMenu = function( self, ... )
				local result = OldShowPlayerInteractMenu( self, ... )
				local menu = self:GetRadialMenu()

				if menu and menu.entries then
					local numEntries = #menu.entries

					if 1 < numEntries then
						local target = GetUnitDisplayName( "reticleoverplayer" )

						if IsPlayerInGroup( target ) then
							target = string.lower( target )
							local isRadiant = true == LOM.RadiantPlayers[ target ]

							table.insert( menu.entries, numEntries, {
								name = isRadiant and "Dispel Meridia's Blessing" or "Invoke Meridia's Blessing",
								inactiveIcon = LOM.Textures.BLESSING,
								activeIcon = LOM.Textures.BLESSING,
								callback = function()
									local status = nil == LOM.RadiantPlayers[ target ]
									if status then LOM.RadiantPlayers[ target ] = true else LOM.RadiantPlayers[ target ] = nil end
									LOM.UI.DisplayNotification( string.format(
										"You %s Meridia's Blessing %s %s.",
										status and "invoke" or "dispel",
										status and "upon" or "from",
										target ) )
								end,
							} )

							menu:Show()
						end
					end
				end
			end
		end
	end
end

function LOM.Initialize()
	LOM.InitVars()
	LOM.InitKeybinds()

	zo_callLater( LOM.InitPlayerToPlayer, 5000 )
	zo_callLater( LOM.InitSlashCommands, 1000 )
	zo_callLater( LOM.InitDefaultKeybinds, 10000 )
end

function LOM.InitVars()
	local savedVars = ZO_SavedVars:NewAccountWide( LOM.Const.SavedVarsFile, LOM.Const.SavedVarsVersion, nil, LOM.Const.SavedVarsDefaults )

	if not savedVars.Data then savedVars.Data = { } end
	if not savedVars.Options then savedVars.Options = { } end

	LOM.Vars = savedVars.Data
	LOM.Options = savedVars.Options
end

function LOM.InitSettings()
	LAM = LibAddonMenu2

	local options, panelData, panelName, s
	local disclaimer = "|cffffffMeridia's Light shines brilliantly in ...|cbbbbbb\n" ..
		"  Battlegrounds, Cyrodiil, Overland, Player Homes\n\n" ..
		"|cffffffbut even Her Light cannot penetrate ...|cbbbbbb\n" ..
		"  Arenas, Dungeons, Trials\n"

	panelName = LOM.Const.AddonName
	panelData = {
		type = "panel",
		name = LOM.Const.AddonTitle,
		displayName = LOM.Const.AddonTitle .. " - Settings",
		author = LOM.Const.AddonAuthor,
		version = tostring( LOM.Const.AddonVersion ),
		slashCommand = "/setlom",
		registerForRefresh = true,
		registerForDefaults = true,
	}

	LOM.SettingsPanel = LAM:RegisterAddonPanel( panelName, panelData )
	options = { }


	table.insert( options, {
		type = "description",
		text = disclaimer,
	} )


	table.insert( options, {
		type = "header",
		name = "Meridia's Divine Radiance",
	} )

	table.insert( options, {
		type = "checkbox",
		name = "Envelop your team in the brilliant Light of Meridia",
		tooltip = "Invoke the Light of Meridia for Her blessings of group support.",
		key = "LightEnabled",
		default = true,
		disabled = function() return false end,
	} )

	table.insert( options, {
		type = "checkbox",
		name = "  Only cast Meridia's Light during battle",
		tooltip = "Meridia's Light will shine only during combat.",
		key = "LightCombatOnly",
		default = false,
		disabled = function() return false end,
	} )

	table.insert( options, {
		type = "slider",
		name = "Her Light's Brilliance",
		tooltip = "Adjust the divine radiance with which Meridia's Light shines.",
		autoSelect = true,
		clampInput = true,
		decimals = 0,
		step = 5,
		min = 10,
		max = 100,
		key = "LightAlpha",
		lomDefault = 0.5,
		default = 50,
		getFunc = function() return 100 * ( LOM.GetSetting( "LightAlpha" ) or 0.5 ) end,
		setFunc = function(value) LOM.SetSetting( "LightAlpha", value / 100 ) end,
		disabled = function() return not LOM.GetSetting( "LightEnabled" ) end
	} )

	table.insert( options, {
		type = "slider",
		name = "Her Light's Focus",
		tooltip = "Adjust the breadth and splendor of Meridia's Light.",
		autoSelect = true,
		clampInput = true,
		decimals = 0,
		step = 5,
		min = 50,
		max = 150,
		key = "LightScale",
		lomDefault = 0.75,
		default = 75,
		getFunc = function() return 100 * ( LOM.GetSetting( "LightScale" ) or 1 ) end,
		setFunc = function(value) LOM.SetSetting( "LightScale", value / 100 ) end,
		disabled = function() return not LOM.GetSetting( "LightEnabled" ) end,
	} )

	table.insert( options, {
		type = "checkbox",
		name = "Obstacle Penetrating Light",
		tooltip = "|cffffff" .. 
			"Gain a divine sense of Her Light allowing you to see Her radiance clearly through any and all obstacles.\n\n" ..
			"Note that you may toggle obstacle penetration at any time by pressing the configurable " ..
			"|c00ffffToggle Obstacle Penetration|cffffff keybind (|c00ffffALT + P|cffffff by default).",
		key = "LightAlwaysIgnoresDepthBuffer",
		onChange = LOM.EffectUI.UpdateObstaclePenetration,
		default = false,
		disabled = function() return false end,
		reference = "LOMLightAlwaysIgnoresDepthBuffer",
	} )


	table.insert( options, {
		type = "custom",
	} )

	table.insert( options, {
		type = "header",
		name = "Meridia's Light of the Fallen...",
	} )

	table.insert( options, {
		type = "checkbox",
		name = "Fallen group members",
		tooltip = "Radiate the brilliant Light of Meridia from fallen group members.",
		key = "LightDead",
		default = true,
		disabled = function() return not LOM.GetSetting( "LightEnabled" ) end,
	} )

	table.insert( options, {
		type = "colorpicker",
		name = "Color",
		width = "full",
		key = "LightDeadColor",
		default = { r = 1, g = 0, b = 0 },
		getFunc = function() local c = LOM.GetColorSetting( "LightDeadColor" ) if c then return c.r, c.g, c.b end end,
		setFunc = function( vr, vg, vb, va ) LOM.SetColorSetting( "LightDeadColor", { r = vr, g = vg, b = vb } ) end,
		disabled = function() return not LOM.GetSetting( "LightEnabled" ) or not LOM.GetSetting( "LightDead" ) end,
	} )

	table.insert( options, {
		type = "checkbox",
		name = "Resurrecting group members",
		tooltip = "Radiate the brilliant Light of Meridia from fallen group members who have received, or are receiving, a resurrection.",
		key = "LightResurrecting",
		default = true,
		disabled = function() return not LOM.GetSetting( "LightEnabled" ) or not LOM.GetSetting( "LightDead" ) end,
	} )

	table.insert( options, {
		type = "colorpicker",
		name = "Color",
		width = "full",
		key = "LightResurrectingColor",
		default = { r = 0.9, g = 1, b = 0 },
		getFunc = function() local c = LOM.GetColorSetting( "LightResurrectingColor" ) if c then return c.r, c.g, c.b end end,
		setFunc = function( vr, vg, vb, va ) LOM.SetColorSetting( "LightResurrectingColor", { r = vr, g = vg, b = vb } ) end,
		disabled = function() return not LOM.GetSetting( "LightEnabled" ) or not LOM.GetSetting( "LightResurrecting" ) end,
	} )


	table.insert( options, {
		type = "custom",
	} )

	table.insert( options, {
		type = "header",
		name = "Meridia's Light of Champions...",
	} )

	table.insert( options, {
		type = "description",
		text = "Invoke Meridia's Blessing upon individual group members from the |cffffbbInteract With Player|r radial menu",
	} )

	table.insert( options, {
		type = "colorpicker",
		name = "Color",
		width = "full",
		key = "HighlightRadiantColor",
		default = { r = 1, g = 0, b = 1 },
		getFunc = function() local c = LOM.GetColorSetting( "HighlightRadiantColor" ) if c then return c.r, c.g, c.b end end,
		setFunc = function( vr, vg, vb, va ) LOM.SetColorSetting( "HighlightRadiantColor", { r = vr, g = vg, b = vb } ) end,
		disabled = function() return not LOM.GetSetting( "LightEnabled" ) end,
	} )

	table.insert( options, {
		type = "checkbox",
		name = "Radiate Light from the Group Leader",
		tooltip = "Color shift the Light of Meridia for the group leader.",
		key = "HighlightLeader",
		default = true,
		disabled = function() return not LOM.GetSetting( "LightEnabled" ) end,
	} )

	table.insert( options, {
		type = "colorpicker",
		name = "Color",
		width = "full",
		key = "HighlightLeaderColor",
		default = { r = 1, g = 1, b = 1 },
		getFunc = function() local c = LOM.GetColorSetting( "HighlightLeaderColor" ) if c then return c.r, c.g, c.b end end,
		setFunc = function( vr, vg, vb, va ) LOM.SetColorSetting( "HighlightLeaderColor", { r = vr, g = vg, b = vb } ) end,
		disabled = function() return not LOM.GetSetting( "LightEnabled" ) or not LOM.GetSetting( "HighlightLeader" ) end,
	} )

	table.insert( options, {
		type = "checkbox",
		name = "Radiate Light from Tanks",
		tooltip = "Color shift the Light of Meridia for tanks.",
		key = "HighlightTanks",
		default = false,
		disabled = function() return not LOM.GetSetting( "LightEnabled" ) end,
	} )

	table.insert( options, {
		type = "colorpicker",
		name = "Color",
		width = "full",
		key = "HighlightTanksColor",
		default = { r = 0, g = 1, b = 0 },
		getFunc = function() local c = LOM.GetColorSetting( "HighlightTanksColor" ) if c then return c.r, c.g, c.b end end,
		setFunc = function( vr, vg, vb, va ) LOM.SetColorSetting( "HighlightTanksColor", { r = vr, g = vg, b = vb } ) end,
		disabled = function() return not LOM.GetSetting( "LightEnabled" ) or not LOM.GetSetting( "HighlightTanks" ) end,
	} )

	table.insert( options, {
		type = "checkbox",
		name = "Radiate Light from Healers",
		tooltip = "Color shift the Light of Meridia for healers.",
		key = "HighlightHealers",
		default = false,
		disabled = function() return not LOM.GetSetting( "LightEnabled" ) end,
	} )

	table.insert( options, {
		type = "colorpicker",
		name = "Color",
		width = "full",
		key = "HighlightHealersColor",
		default = { r = 0, g = 0, b = 1 },
		getFunc = function() local c = LOM.GetColorSetting( "HighlightHealersColor" ) if c then return c.r, c.g, c.b end end,
		setFunc = function( vr, vg, vb, va ) LOM.SetColorSetting( "HighlightHealersColor", { r = vr, g = vg, b = vb } ) end,
		disabled = function() return not LOM.GetSetting( "LightEnabled" ) or not LOM.GetSetting( "HighlightHealers" ) end,
	} )


	table.insert( options, {
		type = "custom",
	} )

	table.insert( options, {
		type = "header",
		name = "Meridia's Light of Unity...",
	} )

	table.insert( options, {
		type = "checkbox",
		name = "Radiate Light from all other group members",
		tooltip = "Radiate the brilliant Light of Meridia from all other group members in the scenario(s) listed below.",
		key = "LightGroupMembers",
		default = true,
		disabled = function() return not LOM.GetSetting( "LightEnabled" ) end,
	} )

	table.insert( options, {
		type = "checkbox",
		name = "Battleground group members",
		tooltip = "Radiate the brilliant Light of Meridia from Battleground group members.",
		key = "LightBattlegroundTeam",
		default = true,
		disabled = function() return not LOM.GetSetting( "LightEnabled" ) or not LOM.GetSetting( "LightGroupMembers" ) end,
	} )

	table.insert( options, {
		type = "colorpicker",
		name = "Color",
		width = "full",
		key = "LightBattlegroundTeamColor",
		default = { r = 0.2, g = 1, b = 1 },
		getFunc = function() local c = LOM.GetColorSetting( "LightBattlegroundTeamColor" ) if c then return c.r, c.g, c.b end end,
		setFunc = function( vr, vg, vb, va ) LOM.SetColorSetting( "LightBattlegroundTeamColor", { r = vr, g = vg, b = vb } ) end,
		disabled = function() return not LOM.GetSetting( "LightEnabled" ) or not LOM.GetSetting( "LightGroupMembers" ) or not LOM.GetSetting( "LightBattlegroundTeam" ) end,
	} )

	table.insert( options, {
		type = "checkbox",
		name = "Cyrodiil group members",
		tooltip = "Radiate the brilliant Light of Meridia from Cyrodiil group members",
		key = "LightCyrodiilTeam",
		default = true,
		disabled = function() return not LOM.GetSetting( "LightEnabled" ) or not LOM.GetSetting( "LightGroupMembers" ) end,
	} )

	table.insert( options, {
		type = "colorpicker",
		name = "Color",
		width = "full",
		key = "LightCyrodiilTeamColor",
		default = { r = 0.2, g = 1, b = 1 },
		getFunc = function() local c = LOM.GetColorSetting( "LightCyrodiilTeamColor" ) if c then return c.r, c.g, c.b end end,
		setFunc = function( vr, vg, vb, va ) LOM.SetColorSetting( "LightCyrodiilTeamColor", { r = vr, g = vg, b = vb } ) end,
		disabled = function() return not LOM.GetSetting( "LightEnabled" ) or not LOM.GetSetting( "LightGroupMembers" ) or not LOM.GetSetting( "LightCyrodiilTeam" ) end,
	} )

	table.insert( options, {
		type = "checkbox",
		name = "World group members",
		tooltip = "Radiate the brilliant Light of Meridia from group members while you are in Overland and Player Housing zones.",
		key = "LightNonPVPTeam",
		default = true,
		disabled = function() return not LOM.GetSetting( "LightEnabled" ) or not LOM.GetSetting( "LightGroupMembers" ) end,
	} )

	table.insert( options, {
		type = "colorpicker",
		name = "Color",
		width = "full",
		key = "LightNonPVPTeamColor",
		default = { r = 0.2, g = 1, b = 1 },
		getFunc = function() local c = LOM.GetColorSetting( "LightNonPVPTeamColor" ) if c then return c.r, c.g, c.b end end,
		setFunc = function( vr, vg, vb, va ) LOM.SetColorSetting( "LightNonPVPTeamColor", { r = vr, g = vg, b = vb } ) end,
		disabled = function() return not LOM.GetSetting( "LightEnabled" ) or not LOM.GetSetting( "LightGroupMembers" ) or not LOM.GetSetting( "LightNonPVPTeam" ) end,
	} )


	for index, opt in ipairs( options ) do
		if "string" == type( opt.key ) then
			if nil ~= opt.default then
				LOM.SetDefaultSetting( opt.key, nil ~= opt.lomDefault and opt.lomDefault or opt.default )
			end

			if not opt.getFunc then
				opt.getFunc = function()
					return LOM.GetSetting( opt.key )
				end
			end

			if not opt.setFunc then
				opt.setFunc = function(value)
					LOM.SetSetting( opt.key, value )

					if opt.onChange then
						opt.onChange(value)
					end
				end
			end
		end
	end

	LAM:RegisterOptionControls( panelName, options )
end

function LOM.InitKeybinds()
	ZO_CreateStringId( "SI_BINDING_NAME_LOM_TOGGLE_LIGHTS", "Toggle ON/OFF" )
	ZO_CreateStringId( "SI_BINDING_NAME_LOM_TOGGLE_OBSTACLE_PENETRATION", "Toggle Obstacle Penetration" )
end

function LOM.InitDefaultKeybind( bindingName, keycodeKey, keycodeModifier1, keycodeModifier2, keycodeModifier3, keycodeModifier4 )
	local layerIndex, categoryIndex, actionIndex = GetActionIndicesFromName( bindingName )

	if layerIndex and categoryIndex and actionIndex then
		local isValid = false

		for index = 1, 4 do
			if GetActionBindingInfo( layerIndex, categoryIndex, actionIndex, 1 ) ~= KEY_INVALID then
				isValid = true
				break
			end
		end

		if not isValid then
			if IsProtectedFunction( "UnbindAllKeysFromAction" ) then
				CallSecureProtected( "UnbindAllKeysFromAction", layerIndex, categoryIndex, actionIndex )
			else
				UnbindAllKeysFromAction( layerIndex, categoryIndex, actionIndex )
			end

			if IsProtectedFunction( "BindKeyToAction" ) then
				CallSecureProtected( "BindKeyToAction", layerIndex, categoryIndex, actionIndex, 1, keycodeKey, keycodeModifier1, keycodeModifier2, keycodeModifier3, keycodeModifier4 )
			else
				BindKeyToAction( layerIndex, categoryIndex, actionIndex, 1, keycodeKey, keycodeModifier1, keycodeModifier2, keycodeModifier3, keycodeModifier4 )
			end
		end
	end
end

function LOM.InitDefaultKeybinds()
	LOM.InitDefaultKeybind( "LOM_TOGGLE_LIGHTS", KEY_L, KEY_ALT, 0, 0, 0 )
	LOM.InitDefaultKeybind( "LOM_TOGGLE_OBSTACLE_PENETRATION", KEY_P, KEY_ALT, 0, 0, 0 )
end

function LOM.GetSettingsTable()
	local settings = LOM.Vars.Settings
	if "table" ~= type( settings ) then
		settings = { }
		LOM.Vars.Settings = settings
	end

	return settings
end

function LOM.SetDefaultSetting( settingName, value )
	if "string" == type( settingName ) and "" ~= settingName then
		LOM.Const.DefaultSettings[ settingName ] = value
	end
end

function LOM.GetSetting( settingName, suppressDefault )
	local settings = LOM.GetSettingsTable()
	local value = settings[ settingName ]

	if nil == value and not suppressDefault then value = LOM.Const.DefaultSettings[ settingName ] end
	return value
end

function LOM.SetSetting( settingName, value )
	local settings = LOM.GetSettingsTable()
	settings[ settingName ] = value

	LOM.ResetAllLights()
	return value
end

function LOM.GetColorSetting( settingName, suppressDefault )
	local value = LOM.GetSetting( settingName, suppressDefault )
	if not value or "table" ~= type( value ) then value = { r = 1, g = 1, b = 1 } end
	value.a = 0.7 + 0.3 * zo_clamp( LOM.GetSetting( "LightAlpha" ) or 1, 0.1, 1 )

	return value
end

function LOM.GetColorSettingValues( settingName, suppressDefault )
	local color = LOM.GetColorSetting( settingName, suppressDefault )
	return color.r, color.g, color.b, color.a
end

function LOM.SetColorSetting( settingName, value )
	local settings = LOM.GetSettingsTable()

	if "table" ~= type( value ) then value = { r = 1, g = 1, b = 1 } end
	value.r, value.g, value.b = value.r or 1, value.g or 1, value.b or 1
	settings[ settingName ] = value

	LOM.ResetAllLights()

	return value
end

function LOM.InitSlashCommands()
	if "@Cardinal05" == GetDisplayName() then
		SLASH_COMMANDS["/re"] = ReloadUI
		SLASH_COMMANDS[ "/sc" ] = SLASH_COMMANDS[ "/script" ]
	end

	SLASH_COMMANDS["/lom"] = LOM.SlashLOM
	SLASH_COMMANDS["/lomver"] = LOM.SlashLOMVersion
	SLASH_COMMANDS["/lomdebug"] = LOM.ToggleDebug
end

function LOM.SlashLOM()
	LOM.EffectUI.ShowHideEffects()
end

function LOM.SlashLOMVersion()
	d( LOM.Const.AddonTitleLong )
end

function LOM.ToggleDebug()
	LOM.Debug = not LOM.Debug
	df( "%s debug mode is %s", LOM.Const.AddonTitle, LOM.Debug and "ON" or "OFF" )
	LOM.ResetAllLights()
end

do
	local DisplayName = GetDisplayName()
	local A = LOM.Attribute
	local Active, Dead, Rez, Lead, Heal, Tank, BG, Cyro, NonPVP = A.Active, A.Dead, A.Resurrecting, A.Leader, A.Healer, A.Tank, A.Battleground, A.Cyrodiil, A.NonPVP
	local WasInGroup = false

	function LOM.OnRefreshLights()
		local effects = LOM.Effect:GetAll()
		if not effects then
			return
		end
		
		if IsPlayerInGroup(DisplayName) then
			WasInGroup = true

			local D = true == LOM.Debug
			local LIGHT_ENABLED = LOM.GetSetting( "LightEnabled" )
			local isBG, isCyro = IsActiveWorldBattleground(), IsInCyrodiil()
			local isNonPVP = not isBG and not isCyro
			local leaderUnitTag = GetGroupLeaderUnitTag()

			for index, effect in ipairs( effects ) do
				if effect and effect.Attributes and not effect.Deleted then
					local attr = effect.Attributes
					local unitTag = effect.UnitTag
					local isPlayer = AreUnitsEqual( "player", unitTag )

					if	( D and isPlayer ) or
						(
							not isPlayer and
							DoesUnitExist( unitTag ) and
							IsUnitOnline( unitTag ) and
							IsGroupMemberInSameWorldAsPlayer( unitTag ) and
							not IsGroupMemberInRemoteRegion( unitTag )
						) then
						local role = GetGroupMemberSelectedRole( unitTag )
						local displayName = string.lower( GetUnitDisplayName( unitTag ) )
						local isRadiant = true == LOM.RadiantPlayers[ displayName ]

						attr[ Active ] = true
						attr[ Dead ] = IsUnitDead( unitTag ) and 1 >= GetUnitPower( unitTag, POWERTYPE_HEALTH )
						attr[ Rez ] = IsUnitBeingResurrected( unitTag ) or DoesUnitHaveResurrectPending( unitTag )
						attr[ Lead ] = leaderUnitTag == unitTag
						attr[ Heal ] = role == LFG_ROLE_HEAL
						attr[ Tank ] = role == LFG_ROLE_TANK
						attr[ BG ] = isBG
						attr[ Cyro ] = isCyro
						attr[ NonPVP ] = isNonPVP
					else
						attr[ Active ] = false
					end

					effect.IsRadiant = false

					if not attr[ Active ] or not LIGHT_ENABLED then
						effect:SetColor( nil, nil, nil, 0 )
					else
						if attr[ Dead ] and LOM.GetSetting( "LightDead" ) then
							if attr[ Rez ] and LOM.GetSetting( "LightResurrecting" ) then
								effect:SetColor( LOM.GetColorSettingValues( "LightResurrectingColor" ) )
							else
								effect:SetColor( LOM.GetColorSettingValues( "LightDeadColor" ) )
							end
						elseif isRadiant then
							effect:SetColor( LOM.GetColorSettingValues( "HighlightRadiantColor" ) )
							effect.IsRadiant = true
						elseif not IsUnitInCombat( "player" ) and LOM.GetSetting( "LightCombatOnly" ) then
							effect:SetColor( nil, nil, nil, 0 )
						elseif attr[ Lead ] and LOM.GetSetting( "HighlightLeader" ) then
							effect:SetColor( LOM.GetColorSettingValues( "HighlightLeaderColor" ) )
						elseif attr[ Heal ] and LOM.GetSetting( "HighlightHealers" ) then
							effect:SetColor( LOM.GetColorSettingValues( "HighlightHealersColor" ) )
						elseif attr[ Tank ] and LOM.GetSetting( "HighlightTanks" ) then
							effect:SetColor( LOM.GetColorSettingValues( "HighlightTanksColor" ) )
						elseif LOM.GetSetting( "LightGroupMembers" ) then
							if attr[ BG ] and LOM.GetSetting( "LightBattlegroundTeam" ) then
								effect:SetColor( LOM.GetColorSettingValues( "LightBattlegroundTeamColor" ) )
							elseif attr[ Cyro ] and LOM.GetSetting( "LightCyrodiilTeam" ) then
								effect:SetColor( LOM.GetColorSettingValues( "LightCyrodiilTeamColor" ) )
							elseif attr[ NonPVP ] and LOM.GetSetting( "LightNonPVPTeam" ) then
								effect:SetColor( LOM.GetColorSettingValues( "LightNonPVPTeamColor" ) )
							end
						else
							effect:SetColor( nil, nil, nil, 0 )
						end
					end
				end
			end
		elseif WasInGroup then
			WasInGroup = false

			for index, effect in ipairs( effects ) do
				effect.Attributes[ Active ] = false
			end
		end
	end
end

function LOM.UnregisterOnUpdate()
	EVENT_MANAGER:UnregisterForUpdate( LOM.Const.AddonName .. "UnregisterOnUpdate" )
end

function LOM.ResetAllLights()
	LOM.Effect:DeleteAll()

	local effect
	for index = 1, LOM.NumUnitTags do
		effect = LOM.Effect:New( "Light of Meridia" )
		effect.Attributes, effect.UnitTag = { }, LOM.UnitTags[index]
	end

	LOM.OnRefreshLights()
end
