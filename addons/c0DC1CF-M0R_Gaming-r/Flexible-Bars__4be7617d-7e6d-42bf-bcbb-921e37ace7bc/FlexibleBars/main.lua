FlexibleBars = FlexibleBars or {}
local FB = FlexibleBars
local LCA = LibCombatAlerts

-- Written by M0R_Gaming

local debugMode = false

FB.name = "FlexibleBars"
FB.varversion = 1

FB.DefaultSettings = {
	--[[
	health = {},
	mag = {},
	stam = {},
	--]]
	snap = 3,
}


-- yoinked from LCA
local ANCHOR_POINTS = {
	L = {
		T = TOPLEFT,
		M = LEFT,
		B = BOTTOMLEFT,
	},
	C = {
		T = TOP,
		M = CENTER,
		B = BOTTOM,
	},
	R = {
		T = TOPRIGHT,
		M = RIGHT,
		B = BOTTOMRIGHT,
	},
}

local POSITION_NAMES = {
	left = { "X", "L" },
	center = { "X", "C" },
	right = { "X", "R" },
	top = { "Y", "T" },
	mid = { "Y", "M" },
	bottom = { "Y", "B" },
}



local settingsDescriptions = {
	[COMBAT_MECHANIC_FLAGS_MAGICKA] = {
		name = "|c0252c7Magicka|r",
		decolouredName = "Magicka",
		colour = "0252c7",
		description = "",
	},
	[COMBAT_MECHANIC_FLAGS_STAMINA] = {
		name = "|c039900Stamina|r",
		decolouredName = "Stamina",
		colour = "039900",
		description = "",
	},
	[COMBAT_MECHANIC_FLAGS_HEALTH] = {
		name = "|c991313Health|r",
		decolouredName = "Health",
		colour = "991313",
		description = "",
	},
}








local frameObject = {}
function frameObject:GetHealthEffects() -- might replace these conditionals with a func to get/check (or just always reassign)
	if self.healthEffects.shield == nil then
		self.healthEffects.shield = self.health:GetNamedChild("PowerShieldLeftOverlay")
	end
	if self.healthEffects.shield ~= nil then
		if self.healthEffects.trauma == nil then
			self.healthEffects.trauma = self.healthEffects.shield:GetNamedChild("Trauma")
		end
		if self.healthEffects.fakeHealth == nil then
			self.healthEffects.fakeHealth = self.healthEffects.shield:GetNamedChild("FakeHealth")
		end
		if self.healthEffects.noHealingInner == nil then
			self.healthEffects.noHealingInner = self.healthEffects.shield:GetNamedChild("NoHealingInner")
		end
		if self.healthEffects.fakeNoHealingInner == nil then
			self.healthEffects.fakeNoHealingInner = self.healthEffects.shield:GetNamedChild("FakeNoHealingInner")
		end
	end
	return self.healthEffects
end



local powerControlLookup = {
	[COMBAT_MECHANIC_FLAGS_MAGICKA] = FlexibleBarsMag,
	[COMBAT_MECHANIC_FLAGS_HEALTH] = FlexibleBarsHealth,
	[COMBAT_MECHANIC_FLAGS_STAMINA] = FlexibleBarsStam,
}

local powerControlBasegame = {
	[COMBAT_MECHANIC_FLAGS_MAGICKA] = ZO_PlayerAttributeMagicka,
	[COMBAT_MECHANIC_FLAGS_HEALTH] = ZO_PlayerAttributeHealth,
	[COMBAT_MECHANIC_FLAGS_STAMINA] = ZO_PlayerAttributeStamina,
}

function FB.PowerUpdateHandlerFunction(unitTag, powerPoolIndex, powerType, value, max)
	local powerControl = powerControlLookup[powerType]
	if powerControl then
		ZO_StatusBar_SmoothTransition(powerControl:GetNamedChild("Resource"),value,max)
		powerControl:GetNamedChild("Value"):SetText(ZO_FormatResourceBarCurrentAndMax(value, max))
	end
end


FB.movableControlHandlers = {}


function FB.SetBarVisiblity(combatFlag, hidden)
	local control = powerControlLookup[combatFlag]
	local baseGameControl = powerControlBasegame[combatFlag]

	control:SetHidden(hidden)
	baseGameControl:SetHidden(not hidden)
end





-- The following was adapted from https://wiki.esoui.com/Circonians_Stamina_Bar_Tutorial#lua_Structure

-------------------------------------------------------------------------------------------------
--  OnAddOnLoaded  --
-------------------------------------------------------------------------------------------------
function FB.OnAddOnLoaded(event, addonName)

	if addonName ~= FB.name then return end

	FB:Initialize()
end

FB.oldScene = ""
 
-------------------------------------------------------------------------------------------------
--  Initialize Function --
-------------------------------------------------------------------------------------------------
function FB:Initialize()
	FB.startInit = os.rawclock()
	-- Addon Settings Menu
	FB.vars = ZO_SavedVars:NewAccountWide("FlexibleBarsVars", FB.varversion, nil, FB.DefaultSettings)

	if (FB.vars.health == nil) or (FB.vars.stam == nil) or (FB.vars.mag == nil) then
		local preset = FB.presets["Base Game"]
		for i,v in pairs(preset) do
			FB.vars[i] = v
		end
	end


	-- setup fragments

	local flexibleBarsFragment = ZO_HUDFadeSceneFragment:New(FlexibleBarsToplevel, DEFAULT_SCENE_TRANSITION_TIME, 0)
	HUD_SCENE:AddFragment(flexibleBarsFragment)
	HUD_UI_SCENE:AddFragment(flexibleBarsFragment)

	if IsConsoleUI() and LibHarvensAddonSettings then
		SecurePostHook(LibHarvensAddonSettings, "CreateAddonList", function() LibHarvensAddonSettings.scene:AddFragment(flexibleBarsFragment) end)
	end





	FB.recentPowerUpdate = ZO_MostRecentPowerUpdateHandler:New("FlexibleBarsPowerUpdate", FB.PowerUpdateHandlerFunction)
	FB.recentPowerUpdate:AddFilterForEvent(REGISTER_FILTER_UNIT_TAG, "player")


	local powerTypeLookup = {
		[COMBAT_MECHANIC_FLAGS_MAGICKA] = "mag",
		[COMBAT_MECHANIC_FLAGS_STAMINA] = "stam",
		[COMBAT_MECHANIC_FLAGS_HEALTH] = "health",
	}




	local panelName = "FlexibleBarsSettingsPanel"
	local panelData = {
		type = "panel",
		name = "|cFFD700Flexible Bars|r",
		author = "|c0DC1CF@M0R_Gaming|r"
	}

	local optionsTable = {
		{
			type = "description",
			title = "|cFFD700Flexible Bars|r",
			width = "full",
		},
		{
			type = "button",
			name = "[Load a preset]",
			tooltip = "Click this button to load a preset!\n\n|cFF0000This will overwrite the settings you currently have active.|r",
			--warning = "This will overwrite the settings you currently have active.",
			width = "full",
			func = function()
				ZO_Dialogs_ShowPlatformDialog("FlexibleBarsPresetSelect")
			end,
		},
		{
			type = "button",
			name = "|cFF5555[Reload UI]|r",
			tooltip = "Click here to reload your UI! (Will result in a load screen)",
			width = "full",
			func = function() ReloadUI() end,
		}
	}


	if LCA then
		optionsTable[#optionsTable+1] = {
			type = "slider",
			name = "Grid Snap",
			tooltip = "This sets the snapping grid for the movement of the bars",
			min = 1,
			max = 100,
			step = 1,
			getFunc = function()
				return FB.vars.snap
			end,
			setFunc = function(snap)
				FB.vars.snap = snap
				for i,v in pairs(FB.movableControlHandlers) do
					v:SetSnap(snap)
				end
			end,
			width = "half",
		}
	end





	for i,v in pairs(powerControlLookup) do
		local value, max = GetUnitPower('player', i)
		ZO_StatusBar_SmoothTransition(v:GetNamedChild("Resource"),value,max)
		v:GetNamedChild("Value"):SetText(ZO_FormatResourceBarCurrentAndMax(value, max))

		local powerVars = FB.vars[powerTypeLookup[i]]

		v:GetNamedChild("Resource"):SetColor(unpack(powerVars.colour))


		local scaleX = powerVars.desiredX/250
		local scaleY = powerVars.desiredY/25
		local textScale = powerVars.textScale or 1

		v:GetNamedChild("Resource"):SetTransformScaleX(scaleX)
		v:GetNamedChild("Resource"):SetTransformScaleY(scaleY)
		v:GetNamedChild("Value"):SetTransformScale(scaleY * textScale)

		v:GetNamedChild("Value"):SetTransformRotationZ(zo_rad(powerVars.textRotation or 0))
		v:GetNamedChild("Value"):SetHidden(powerVars.textHide)
		v:GetNamedChild("Value"):SetTransformOffsetX(powerVars.textOffsetX)
		v:GetNamedChild("Value"):SetTransformOffsetY(powerVars.textOffsetY)

		v:SetTransformRotationZ(zo_rad(powerVars.rotation))
		--v:SetHidden(powerVars.hide)
		FB.SetBarVisiblity(i, powerVars.hide)

		local resourceColouredName = tostring(settingsDescriptions[i].name)
		local resourceName = tostring(settingsDescriptions[i].decolouredName)

		optionsTable[#optionsTable+1] = {
			type = "divider",
		}


		optionsTable[#optionsTable+1] = {
			type = "description",
			title = resourceColouredName,
			width = "full",
		}


		optionsTable[#optionsTable+1] = {
			type = "checkbox",
			name = "Show "..resourceName.." Bar",
			--tooltip = "",
			tooltip = "Enabling this will hide the base game "..resourceColouredName.." resource bar.",
			width = "half",
			getFunc = function() return not powerVars.hide end,
			setFunc = function(value)
				powerVars.hide = not value
				FB.SetBarVisiblity(i, powerVars.hide)
			end,
		}




		local function getPositions()
			local offsets = { } -- yoinked from LCA
			local positionData = {}
			local anchorData = {}

			for name, data in pairs(POSITION_NAMES) do	
				if (type(powerVars.pos[name]) == "number") then
					positionData[data[1]] = data[2]
					offsets[data[1]] = powerVars.pos[name]
					anchorData[data[1]] = name
				end
			end

			local anchorPoint = ANCHOR_POINTS[positionData.X][positionData.Y]

			return offsets, anchorData, anchorPoint
		end





		if LCA then
			local handler = LCA.MoveableControl:New(v)
			FB.movableControlHandlers[i] = handler

			handler:UpdatePosition(powerVars.pos)

			handler:SetSnap(FB.vars.snap) -- TODO: Move to a var

			handler:RegisterCallback("FlexibleBarsMove"..powerTypeLookup[i], LCA.EVENT_CONTROL_MOVE_STOP, function(newPos)
				FB.vars[powerTypeLookup[i]].pos = newPos
				SCENE_MANAGER:Show(FB.oldScene or "hud")
			end)

			SLASH_COMMANDS["/fb.move"..powerTypeLookup[i]] = function()
				handler:ToggleGamepadMove(true)
			end

			optionsTable[#optionsTable+1] = {
				type = "button",
				name = string.format("|c%s[Move %s Bar]|r", tostring(settingsDescriptions[i].colour), resourceName),
				tooltip = "Click this button to move the "..resourceColouredName.." bar, using your analogue stick.",
				width = "full",
				func = function()
					if SCENE_MANAGER.currentScene then
						FB.oldScene = SCENE_MANAGER.currentScene.name or "hud"
					else
						FB.oldScene = "hud"
					end

					SCENE_MANAGER:Show("hudui")
					handler:ToggleGamepadMove(true)
				end,
			}

		else
			local offsets, _, anchorPoint = getPositions()
			v:ClearAnchors()
			v:SetAnchor(anchorPoint, GuiRoot, anchorPoint, offsets.X or 0, offsets.Y or 0)

			optionsTable[#optionsTable+1] = {
				type = "description",
				title = "",
				text = "To move the "..resourceColouredName.." bar, please download/enable the LibCombatAlerts library!",
				width = "full",
			}
		end


		optionsTable[#optionsTable+1] = {
			type = "slider",
			name = resourceName.." Rotation",
			tooltip = "This sets the rotation of the "..resourceColouredName.." bar, in degrees.",
			min = 0,
			max = 360,
			step = 1,
			getFunc = function()
				return powerVars.rotation
			end,
			setFunc = function(theta)
				powerVars.rotation = theta
				v:SetTransformRotationZ(zo_rad(theta))
			end,
			width = "half",
		}

		optionsTable[#optionsTable+1] = {
			type = "slider",
			name = resourceName.." Width",
			tooltip = "This sets the width of the "..resourceColouredName.." bar.",
			min = 1,
			max = GuiRoot:GetWidth(),
			step = 1,
			getFunc = function()
				return powerVars.desiredX
			end,
			setFunc = function(x)
				powerVars.desiredX = x
				v:GetNamedChild("Resource"):SetTransformScaleX(x/250)
			end,
			width = "half",
		}

		optionsTable[#optionsTable+1] = {
			type = "slider",
			name = resourceName.." Height",
			tooltip = "This sets the height of the "..resourceColouredName.." bar.",
			min = 1,
			max = GuiRoot:GetHeight(),
			step = 1,
			getFunc = function()
				return powerVars.desiredY
			end,
			setFunc = function(y)
				powerVars.desiredY = y
				v:GetNamedChild("Resource"):SetTransformScaleY(y/25)
				v:GetNamedChild("Value"):SetTransformScale(y/25)

				local textScale = powerVars.textScale or 1
				v:GetNamedChild("Value"):SetTransformScale(y/25 * textScale)
			end,
			width = "half",
		}
		


		local healthWarning = ""
		if powerTypeLookup[i] == "health" then
			healthWarning = "|cFF0000After adjusting the health colour, please reload your UI to fully apply the change. This is only required for the health bar.|r"
		end


		optionsTable[#optionsTable+1] = {
			type = "colorpicker",
			name = resourceName.." Colour",
			tooltip = "This sets the colour of the "..resourceColouredName.." bar!\n\n"..healthWarning,
			getFunc = function()
				return unpack(powerVars.colour)
			end,
			--warning = healthWarning,
			setFunc = function(r,g,b)
				powerVars.colour = {r,g,b}
				v:GetNamedChild("Resource"):SetColor(unpack(powerVars.colour))
			end,
			width = "full",
		}



		optionsTable[#optionsTable+1] = {
			type = "checkbox",
			name = "Show "..resourceName.." Text",
			tooltip = "",
			width = "half",
			getFunc = function() return not powerVars.textHide end,
			setFunc = function(value)
				powerVars.textHide = not value
				v:GetNamedChild("Value"):SetHidden(powerVars.textHide)
			end,
		}

		optionsTable[#optionsTable+1] = {
			type = "slider",
			name = resourceName.." Text Scale",
			tooltip = "This sets the scale of the "..resourceColouredName.." text (in percent).",
			min = 10,
			max = 1000,
			step = 10,
			getFunc = function()
				return powerVars.textScale * 100
			end,
			setFunc = function(scale)
				powerVars.textScale = scale/100
				v:GetNamedChild("Value"):SetTransformScale(powerVars.desiredY/25 * scale/100)
			end,
			width = "half",
		}
		optionsTable[#optionsTable+1] = {
			type = "slider",
			name = resourceName.." Text Rotation",
			tooltip = "This sets the rotation of the "..resourceColouredName.." text (in degrees).",
			min = 0,
			max = 360,
			step = 1,
			getFunc = function()
				return powerVars.textRotation
			end,
			setFunc = function(theta)
				powerVars.textRotation = theta
				v:GetNamedChild("Value"):SetTransformRotationZ(zo_rad(theta))
			end,
			width = "half",
		}



		optionsTable[#optionsTable+1] = {
			type = "slider",
			name = resourceName.." Text X Offset",
			tooltip = "This sets the horizontal offset of the "..resourceColouredName.." text, originating from the center of the bar.",
			min = -GuiRoot:GetWidth(),
			max = GuiRoot:GetWidth(),
			step = 1,
			getFunc = function()
				return powerVars.textOffsetX
			end,
			setFunc = function(x)
				powerVars.textOffsetX = x
				v:GetNamedChild("Value"):SetTransformOffsetX(x)
			end,
			width = "half",
		}
		optionsTable[#optionsTable+1] = {
			type = "slider",
			name = resourceName.." Text Y Offset",
			tooltip = "This sets the vertical offset of the "..resourceColouredName.." text, originating from the center of the bar.",
			min = -GuiRoot:GetHeight(),
			max = GuiRoot:GetHeight(),
			step = 1,
			getFunc = function()
				return powerVars.textOffsetY
			end,
			setFunc = function(y)
				powerVars.textOffsetY = y
				v:GetNamedChild("Value"):SetTransformOffsetY(y)
			end,
			width = "half",
		}

	end

	local panel = LibAddonMenu2:RegisterAddonPanel(panelName, panelData)
	LibAddonMenu2:RegisterOptionControls(panelName, optionsTable)


	local grad = ZO_ColorDef:New(unpack(FB.vars.health.colour)) --unpack(rgb)

	local VISUALIZER_POWER_SHIELD_LAYOUT_DATA =
	{
		barLeftOverlayTemplate = "FlexibleBars_ShieldBarTemplate",
		fakeHealthGradientOverride = {grad,grad},
	}


	FlexibleBarsHealthResource.barControls = {FlexibleBarsHealthResource}
	FB.visualizer = ZO_UnitAttributeVisualizer:New('player', nil, FlexibleBarsHealthResource)
	FB.shieldVis = ZO_UnitVisualizer_PowerShieldModule:New(VISUALIZER_POWER_SHIELD_LAYOUT_DATA)
	FB.visualizer:AddModule(FB.shieldVis)

	FB.shieldVis:InitializeBarValues()
	--FB.shieldVis:ShowOverlay(FB.shieldVis.attributeBarControls[ATTRIBUTE_HEALTH], FB.shieldVis.attributeInfo[ATTRIBUTE_HEALTH])






	--ZO_StatusBar_SmoothTransition(FlexibleBarsHealthResource,100,100)
	--ZO_StatusBar_SmoothTransition(FlexibleBarsMagResource,100,100)
	--ZO_StatusBar_SmoothTransition(FlexibleBarsStamResource,100,100)




	EVENT_MANAGER:UnregisterForEvent(FB.name, EVENT_ADD_ON_LOADED)

	FB.endInit = os.rawclock()
	FB.totalTime = FB.endInit - FB.startInit
end
 
-------------------------------------------------------------------------------------------------
--  Register Events --
-------------------------------------------------------------------------------------------------
EVENT_MANAGER:RegisterForEvent(FB.name, EVENT_ADD_ON_LOADED, FB.OnAddOnLoaded)
