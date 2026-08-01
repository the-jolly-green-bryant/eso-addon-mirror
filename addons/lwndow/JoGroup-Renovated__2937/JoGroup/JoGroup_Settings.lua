JoGroup = JoGroup or {}
local Jo = JoGroup
local LAM2 = LibAddonMenu2

-------------------------------------------------------------------------------------------------
--  Slash Commands  --
-------------------------------------------------------------------------------------------------
function Jo.Slash(command)
	if command == "unlock" then
		Jo.Unlock(true)
	elseif command == "lock" then
		Jo.Unlock(false)
	else
		d(GetString(SI_JOGROUP_SLASH1))
		d(GetString(SI_JOGROUP_SLASH2))
		d(GetString(SI_JOGROUP_SLASH3))
	end
end
SLASH_COMMANDS["/jogroup"] = Jo.Slash

SLASH_COMMANDS["/rl"] = function() ReloadUI("ingame") end
SLASH_COMMANDS["/rc"] = function() ZO_SendReadyCheck() end
SLASH_COMMANDS["/gl"] = function() GroupLeave() end
SLASH_COMMANDS["/gd"] = function() GroupDisband() end


-------------------------------------------------------------------------------------------------
--  Settings  --
-------------------------------------------------------------------------------------------------
function Jo.CreateSettingsWindow()
	local panelData = {
		type = "panel",
		name = Jo.name,
		displayName = Jo.name,
		author = "@lwndow, @Deandra & JoyceKimberly",
		version = tostring(Jo.version),
		registerForRefresh = true,
		registerForDefaults = true,
		resetFunc = Jo.UpdateUnits,
	}
	local ctrlOptionsPanel = LAM2:RegisterAddonPanel("JoGroupSettings", panelData)

	local optionsData = {
		{
			type = "header",
			name = GetString(SI_JOGROUP_GROUPFRAMES)
		},
		{
			type = "checkbox",
			name = GetString(SI_JOGROUP_UNLOCK),
			tooltip = GetString(SI_JOGROUP_UNLOCKTIP),
			default = Jo.unlocked,
			getFunc = function() return Jo.unlocked end,
			setFunc = function(newValue)
				Jo.Unlock(newValue)
			end,
		},
		{
			type = "slider",
			name = GetString(SI_JOGROUP_OORALPHA),
			min = 10,
			max = 100,
			step = 5,
			default = (Jo.defaults.opacity.oorAlpha*100),
			getFunc = function() return zo_round(Jo.savedVars.opacity.oorAlpha*100) end,
			setFunc = function(newValue)
				Jo.savedVars.opacity.oorAlpha = zo_roundToNearest((newValue/100), .01)
				Jo.UpdateUnits()
			end,
		},
		{
			type = "slider",
			name = GetString(SI_JOGROUP_UNITSPCOL),
			min = 2,
			max = 12,
			step = 2,
			default = Jo.defaults.ordening.unitsPerColumn,
			getFunc = function() return zo_round(Jo.savedVars.ordening.unitsPerColumn) end,
			setFunc = function(newValue)
				Jo.savedVars.ordening.unitsPerColumn = zo_round(newValue)
				Jo.CustomizeUnits()
			end,
		},
		{
			type = "dropdown",
			name = "Sort by",
			choices = {
				"index",
				"role",
			},
			default = Jo.defaults.ordening.sort,
			getFunc = function() return Jo.savedVars.ordening.sort end,
			setFunc = function(newValue)
				Jo.savedVars.ordening.sort = newValue
				Jo.ReAnchor()
			end,
		},
		{
			type = "dropdown",
			name = GetString(SI_JOGROUP_UNITSX),
			choices = {
				"right",
				"left",
			},
			default = Jo.defaults.ordening.directionX,
			getFunc = function() return Jo.savedVars.ordening.directionX end,
			setFunc = function(newValue)
				Jo.savedVars.ordening.directionX = newValue
				Jo.CustomizeUnits()
			end,
		},
		{
			type = "dropdown",
			name = GetString(SI_JOGROUP_UNITSY),
			choices = {
				"up",
				"down",
			},
			default = Jo.defaults.ordening.directionY,
			getFunc = function() return Jo.savedVars.ordening.directionY end,
			setFunc = function(newValue)
				Jo.savedVars.ordening.directionY = newValue
				Jo.CustomizeUnits()
			end,
		},
		{
			type = "slider",
			name = GetString(SI_JOGROUP_PADDING),
			min = 0,
			max = 10,
			step = 1,
			default = Jo.defaults.ordening.padding,
			getFunc = function() return zo_round(Jo.savedVars.ordening.padding) end,
			setFunc = function(newValue)
				Jo.savedVars.ordening.padding = zo_round(newValue)
				Jo.CustomizeUnits()
			end,
		},
		{
			type = "slider",
			name = "Background opacity",
			min = 0,
			max = 100,
			step = 5,
			default = (Jo.defaults.opacity.bgAlpha*100),
			getFunc = function() return zo_round(Jo.savedVars.opacity.bgAlpha*100) end,
			setFunc = function(newValue)
				Jo.savedVars.opacity.bgAlpha = zo_roundToNearest((newValue/100), .01)
				Jo.CustomizeUnits()
			end,
		},
		{
			type = "slider",
			name = GetString(SI_JOGROUP_GLOSSALPHA),
			min = 0,
			max = 100,
			step = 5,
			default = (Jo.defaults.opacity.glossAlpha*100),
			getFunc = function() return zo_round(Jo.savedVars.opacity.glossAlpha*100) end,
			setFunc = function(newValue)
				Jo.savedVars.opacity.glossAlpha = zo_roundToNearest((newValue/100), .01)
				Jo.CustomizeUnits()
			end,
		},
		{
			type = "dropdown",
			name = GetString(SI_JOGROUP_FONTFAM),
			choices = {
				"MEDIUM_FONT",
				"BOLD_FONT",
				"CHAT_FONT",
				"ANTIQUE_FONT",
				"HANDWRITTEN_FONT",
				"STONE_TABLET_FONT",
				"GAMEPAD_MEDIUM_FONT",
				"GAMEPAD_BOLD_FONT",
			},
			default = Jo.defaults.text.fontFam,
			getFunc = function() return Jo.savedVars.text.fontFam end,
			setFunc = function(newValue)
				Jo.savedVars.text.fontFam = newValue
				Jo.CustomizeUnits()
			end,
		},
		{
			type = "slider",
			name = GetString(SI_JOGROUP_FONTSIZE),
			min = 12,
			max = 24,
			step = 1,
			default = Jo.defaults.text.fontSize,
			getFunc = function() return zo_round(Jo.savedVars.text.fontSize) end,
			setFunc = function(newValue)
				Jo.savedVars.text.fontSize = zo_round(newValue)
				Jo.CustomizeUnits()
			end,
		},
		{
			type = "slider",
			name = GetString(SI_JOGROUP_UNITWIDTH),
			min = 125,
			max = 250,
			step = 5,
			default = Jo.defaults.frameWidth,
			getFunc = function() return zo_round(Jo.savedVars.frameWidth) end,
			setFunc = function(newValue)
				Jo.savedVars.frameWidth = zo_round(newValue)
				Jo.CustomizeUnits()
			end,
		},
		{
			type = "colorpicker",
			name = "Shield colour",
			default = function() return unpack(Jo.defaults.colours.shield) end,
			getFunc = function() return unpack(Jo.savedVars.colours.shield) end,
			setFunc = function(r, g, b, a)
				Jo.savedVars.colours.shield = {r, g, b, a}
				Jo.CustomizeUnits()
			end,
		},
		{
			type = "colorpicker",
			name = "War Horn colour",
			default = function() return unpack(Jo.defaults.colours.warHorn) end,
			getFunc = function() return unpack(Jo.savedVars.colours.warHorn) end,
			setFunc = function(r, g, b, a)
				Jo.savedVars.colours.warHorn = {r, g, b, a}
				Jo.CustomizeUnits()
			end,
		},
		{
			type = "colorpicker",
			name = "Cloudrest Shade colour",
			default = function() return unpack(Jo.defaults.colours.crShade) end,
			getFunc = function() return unpack(Jo.savedVars.colours.crShade) end,
			setFunc = function(r, g, b, a)
				Jo.savedVars.colours.crShade = {r, g, b, a}
				Jo.CustomizeUnits()
			end,
		},
		{
			type = "dropdown",
			name = GetString(SI_JOGROUP_TANKCOLOUR),
			choices = {
				"red",
				"green",
				"blue",
				"yellow",
				"orange",
				"brightgreen",
				"silverblue",
			},
			default = Jo.defaults.colours.tankColour,
			disabled = function() return Jo.savedVars.colours.customColour end,
			getFunc = function() return Jo.savedVars.colours.tankColour end,
			setFunc = function(newValue)
				Jo.savedVars.colours.tankColour = newValue
				Jo.UpdateUnits()
			end,
		},
		{
			type = "dropdown",
			name = GetString(SI_JOGROUP_HEALERCOLOUR),
			choices = {
				"red",
				"green",
				"blue",
				"yellow",
				"orange",
				"brightgreen",
				"silverblue",
			},
			default = Jo.defaults.colours.healerColour,
			disabled = function() return Jo.savedVars.colours.customColour end,
			getFunc = function() return Jo.savedVars.colours.healerColour end,
			setFunc = function(newValue)
				Jo.savedVars.colours.healerColour = newValue
				Jo.UpdateUnits()
			end,
		},
		{
			type = "dropdown",
			name = GetString(SI_JOGROUP_DPSCOLOUR),
			choices = {
				"red",
				"green",
				"blue",
				"yellow",
				"orange",
				"brightgreen",
				"silverblue",
			},
			default = Jo.defaults.colours.dpsColour,
			disabled = function() return Jo.savedVars.colours.customColour end,
			getFunc = function() return Jo.savedVars.colours.dpsColour end,
			setFunc = function(newValue)
				Jo.savedVars.colours.dpsColour = newValue
				Jo.UpdateUnits()
			end,
		},
		{
			type = "checkbox",
			name = "Choose custom colours",
			default = Jo.defaults.colours.customColour,
			getFunc = function() return Jo.savedVars.colours.customColour end,
			setFunc = function(newValue)
				Jo.savedVars.colours.customColour = newValue
				Jo.UpdateUnits()
			end,
		},
		{
			type = "colorpicker",
			name = SI_JOGROUP_TANKCOLOUR,
			disabled = function() return not Jo.savedVars.colours.customColour end,
			getFunc = function() return unpack(Jo.savedVars.colours.customTankColour) end,
			setFunc = function(r, g, b, a)
				Jo.savedVars.colours.customTankColour = {r, g, b, a}
				Jo.UpdateUnits()
			end,
		},
		{
			type = "colorpicker",
			name = SI_JOGROUP_HEALERCOLOUR,
			disabled = function() return not Jo.savedVars.colours.customColour end,
			getFunc = function() return unpack(Jo.savedVars.colours.customHealerColour) end,
			setFunc = function(r, g, b, a)
				Jo.savedVars.colours.customHealerColour = {r, g, b, a}
				Jo.UpdateUnits()
			end,
		},
		{
			type = "colorpicker",
			name = SI_JOGROUP_DPSCOLOUR,
			disabled = function() return not Jo.savedVars.colours.customColour end,
			getFunc = function() return unpack(Jo.savedVars.colours.customDpsColour) end,
			setFunc = function(r, g, b, a)
				Jo.savedVars.colours.customDpsColour = {r, g, b, a}
				Jo.UpdateUnits()
			end,
		},
		{
			type = "checkbox",
			name = "Compact Mode",
			default = Jo.defaults.compactMode,
			getFunc = function() return Jo.savedVars.compactMode end,
			setFunc = function(newValue)
				Jo.savedVars.compactMode = newValue
				Jo.CustomizeUnits()
			end,
		},
		{
			type = "header",
			name = SI_JOGROUP_SHOWHIDE
		},		
		{
			type = "checkbox",
			name = GetString(SI_JOGROUP_SHOWACCTNAME),
			default = Jo.defaults.show.acctName,
			getFunc = function() return Jo.savedVars.show.acctName end,
			setFunc = function(newValue)
				Jo.savedVars.show.acctName = newValue
			end,
		},
		{
			type = "checkbox",
			name = GetString(SI_JOGROUP_SHOWVRCROWN),			
			tooltip = GetString(SI_JOGROUP_SHOWVRCROWNTIP),
			default = Jo.defaults.show.diffIndicator,
			getFunc = function() return Jo.savedVars.show.diffIndicator end,
			setFunc = function(newValue)
				Jo.savedVars.show.diffIndicator = newValue
			end,
		},
		{
			type = "checkbox",
			name = GetString(SI_JOGROUP_SHOWDEFAULT),
			default = Jo.defaults.show.defaultFrames,
			getFunc = function() return Jo.savedVars.show.defaultFrames end,
			setFunc = function(newValue)
				Jo.savedVars.show.defaultFrames = newValue
				ZO_UnitFramesGroups:SetHidden(not newValue)
			end,
		},
		{
			type = "checkbox",
			name = GetString(SI_JOGROUP_NOTIFICATIONS),
			default = Jo.defaults.show.notifications,
			getFunc = function() return Jo.savedVars.show.notifications end,
			setFunc = function(newValue)
				Jo.savedVars.show.notifications = newValue
			end,
		},
		{
			type = "checkbox",
			name = GetString(SI_JOGROUP_SHOWHEALTHVALUES),
			default = Jo.defaults.show.healthValues,
			getFunc = function() return Jo.savedVars.show.healthValues end,
			setFunc = function(newValue)
				Jo.savedVars.show.healthValues = newValue
				Jo.CustomizeUnits()
			end,
		},
		{
			type = "checkbox",
			name = GetString(SI_JOGROUP_SHOWFULLHEALTHNUMBER),			
			tooltip = GetString(SI_JOGROUP_SHOWFULLHEALTHNUMBERTIP),
			disabled = function() return not Jo.savedVars.show.healthValues end,
			default = Jo.defaults.show.fullNumberHealth,
			getFunc = function() return Jo.savedVars.show.fullNumberHealth end,
			setFunc = function(newValue)
				Jo.savedVars.show.fullNumberHealth = newValue
				Jo.CustomizeUnits()
			end,
		},
		{
			type = "checkbox",
			name = GetString(SI_JOGROUP_SHOWFOOD),
			default = Jo.defaults.show.foodBuffs,
			getFunc = function() return Jo.savedVars.show.foodBuffs end,
			setFunc = function(newValue)
				Jo.savedVars.show.foodBuffs = newValue
				Jo.UpdateUnits()
			end,
		},
		{
			type = "checkbox",
			name = GetString(SI_JOGROUP_SHOWREGEN),
			default = Jo.defaults.show.regen,
			getFunc = function() return Jo.savedVars.show.regen end,
			setFunc = function(newValue)
				Jo.savedVars.show.regen = newValue
			end,
		},
		{
			type = "checkbox",
			name = GetString(SI_JOGROUP_SHOWHORN),
			default = Jo.defaults.show.warHorn,
			getFunc = function() return Jo.savedVars.show.warHorn end,
			setFunc = function(newValue)
				Jo.savedVars.show.warHorn = newValue
			end,
		},
		{
			type = "checkbox",
			name = "Warn for Cloudrest Shade from Corpse",
			default = Jo.defaults.show.crShade,
			getFunc = function() return Jo.savedVars.show.crShade end,
			setFunc = function(newValue)
				Jo.savedVars.show.crShade = newValue
			end,
		},
	}
	LAM2:RegisterOptionControls("JoGroupSettings", optionsData)
end
