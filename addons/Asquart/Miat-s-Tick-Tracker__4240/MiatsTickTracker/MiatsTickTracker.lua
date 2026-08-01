local LAM = LibAddonMenu2

MTT = MTT or {}
MiatsTickTracker = MTT

MTT.updateName = "MiatsTickTracker"
MTT.version = "1.15"

local addonDefaults = {
	unlocked = true,
	controlOffsetX = 0,
	controlOffsetY = 0,
	controlScale = 1,
	tickAmountScale = 1,
	alwaysShown = false,
	powerType = POWERTYPE_STAMINA,
	controlWidth = 100,
	attachToDefaultBar = false,
	showFatigue = true,
	maxFatigueCount = 5,
	playSound = true,
	tickSoundVolume = 2,
	tickSound = "COUNTDOWN_TICK",
	preTickThreshold1= 75,
	preTickThreshold2= 85,
	barBackgroundColor = {0, 0, 0, 1},
	tickAmountColor = {0, 1, 0, 1},
	minFatigueColor = {1, 1, 0, 1},
	maxFatigueColor = {1, 0.1, 0, 1},
	regenColor = {0, 1, 0, 1},
	preTickColor1 = {1, 1, 0, 1},
	preTickColor2 = {1, 0.6, 0, 1},
	zeroRegenColor = {1, 0, 0, 1},
	showBarPercentage = true,
	playTickAnimation = false,
	showTickAmount = true,
	tickAmountVerticallOffset = -30,
	tickAmountHorizontalOffset = -2,
}

local colorTypes = {
	-- [POWERTYPE_STAMINA] = {0, 0.8, 0, 1},
	-- [POWERTYPE_STAMINA] = {0, 0.6, 0.4, 1},
	[POWERTYPE_STAMINA] = {0, 0.8, 0.52, 1},
	-- [POWERTYPE_MAGICKA] = {0.66, 0.66, 1, 1},
	[POWERTYPE_MAGICKA] = {0.32, 0.84, 1, 1},
	-- [POWERTYPE_HEALTH] = {1, 0.26, 0.26, 1},
	[POWERTYPE_HEALTH] = {0.85, 0.18, 0.18, 1},
}

local fatigueAbilityID = 69143

local gameSounds          = SOUNDS
local sounds              = {}

local function populateSounds()
    for sound, _ in pairs(gameSounds) do
        if sound ~= nil and sound ~= "" then
            table.insert(sounds, sound)
        end
    end

    table.sort(sounds)
end

local fatigueColors = {}

local MiatsTickTracker = {}

local translateOffsetY = 1

local function lerp(a,b,t) return (1-t)*a + t*b end
local function clamp(val, min, max)
	if val < min then
		val = min
	elseif max < val then
		val = max
	end
	return val
end

local function LerpColor(color1, color2, alpha)
	local result =
	{
		lerp(color1[1], color2[1], alpha),
		lerp(color1[2], color2[2], alpha),
		lerp(color1[3], color2[3], alpha),
		lerp(color1[4], color2[4], alpha)
	}
	return result
end

function MTT.GenerateFatugieColors()
	local maxCountMinusOne = MTT.SV.maxFatigueCount - 1
	for i = 0, maxCountMinusOne, 1 do
		fatigueColors[i + 1] = LerpColor(MTT.SV.minFatigueColor, MTT.SV.maxFatigueColor, i / maxCountMinusOne)
	end
end

function MTT.PlayTickSound()
    for i = 0, MTT.SV.tickSoundVolume, 1 do
        PlaySound(SOUNDS[MTT.SV.tickSound])
    end
end

function MTT.Initialize(control)
	MTT.SV = ZO_SavedVars:NewAccountWide("MiatTickTrackerSettings", 1.00, "Settings", addonDefaults)
	
    MTT.control = control
	MTT.defaultStamBar = ZO_PlayerAttributeStamina
	MTT.defaultMagBar = ZO_PlayerAttributeMagicka
	MTT.defaultHpBar = ZO_PlayerAttributeHealth
	if MTT.SV.powerType == POWERTYPE_STAMINA then
		MTT.defaultBar = MTT.defaultStamBar
	elseif MTT.SV.powerType == POWERTYPE_MAGICKA then
		MTT.defaultBar = MTT.defaultMagBar
	elseif MTT.SV.powerType == POWERTYPE_HEALTH then
		MTT.defaultBar = MTT.defaultHpBar
	end
	MTT.defaultTick = MiatsDefaultTick
	-- MTT.arrow = MTT.defaultTick:GetNamedChild('Edge')
	MTT.arrow = MiatEdgeContainer
	MTT.arrowTexture1 = MTT.arrow:GetNamedChild('MiatEdge1')
	-- MTT.arrowTexture2 = MTT.arrow:GetNamedChild('MiatEdge2')
	-- MTT.arrowTexture3 = MTT.arrow:GetNamedChild('MiatEdge3')
	-- MTT.arrowTexture2:SetHidden(true)
	-- MTT.arrowTexture3:SetHidden(true)
	MTT.defaultTickLabel = MiatAmount
    MTT.container = control:GetNamedChild('Container')
    MTT.amountLabel = MTT.container:GetNamedChild('Amount')
    MTT.percentageLabel = MTT.container:GetNamedChild('Percentage')
    MTT.bar = MTT.container:GetNamedChild('Bar')
	MTT.fatigueCount = 0

	MTT.GenerateFatugieColors()
	populateSounds()
	
	-- MTT:CreateAddonMenu()
	MTT.ManageUnlocked()
end

function MTT.SetupEvents()
	EVENT_MANAGER:RegisterForUpdate(MTT.updateName .. "OnTickUpdate", 10, MTT.OnTickUpdate)

	EVENT_MANAGER:RegisterForEvent(MTT.updateName .. "OnPowerUpdate", EVENT_POWER_UPDATE, MTT.OnPowerUpdate)
	EVENT_MANAGER:RegisterForEvent(MTT.updateName .. "OnCombatEvent", EVENT_COMBAT_EVENT, MTT.OnCombatEvent)
	EVENT_MANAGER:RegisterForEvent(MTT.updateName .. "OnWeaponPairLockChanged", EVENT_WEAPON_PAIR_LOCK_CHANGED, MTT.OnWeaponPairLockChanged)

	EVENT_MANAGER:AddFilterForEvent(MTT.updateName .. "OnCombatEvent", EVENT_COMBAT_EVENT,
	REGISTER_FILTER_ABILITY_ID, fatigueAbilityID,
	REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
	EVENT_MANAGER:AddFilterForEvent(MTT.updateName .. "OnPowerUpdate", EVENT_POWER_UPDATE,
	REGISTER_FILTER_UNIT_TAG, "player")
end

function MTT.UnregisterEvents()
	EVENT_MANAGER:UnregisterForUpdate(MTT.updateName .. "OnTickUpdate")
	EVENT_MANAGER:UnregisterForEvent(MTT.updateName .. "OnPowerUpdate", EVENT_POWER_UPDATE)
	EVENT_MANAGER:UnregisterForEvent(MTT.updateName .. "OnCombatEvent", EVENT_COMBAT_EVENT)
	EVENT_MANAGER:UnregisterForEvent(MTT.updateName .. "OnWeaponPairLockChanged", EVENT_WEAPON_PAIR_LOCK_CHANGED)
end

function MTT.GetTranslateDistance()
	local distance = MTT.defaultBar:GetWidth() - MTT.arrow:GetWidth() - MTT.arrow.anchorOffsetX
	if MTT.SV.powerType == POWERTYPE_MAGICKA then
		distance = -distance
	end
	return distance
end

function MTT.SetupControls()
	MTT.control:SetScale(MTT.SV.controlScale)
	MTT.container:SetWidth(MTT.SV.controlWidth/MTT.SV.controlScale)
	MTT.container:SetCenterColor(unpack(MTT.SV.barBackgroundColor))
	MTT.control:ClearAnchors()
	MTT.control:SetAnchor(CENTER, GuiRoot, CENTER, MTT.SV.controlOffsetX, MTT.SV.controlOffsetY)
	local barScaleX = MTT.container:GetWidth()/MTT.SV.controlScale-4
	local barScaleY = MTT.container:GetHeight()/MTT.SV.controlScale-2
	MTT.bar:SetDimensions(barScaleX, barScaleY)
	local side
	local anchorOffsetX
	if MTT.SV.powerType == POWERTYPE_STAMINA then
		MTT.defaultBar = MTT.defaultStamBar
		MTT.arrowTexture1:SetTextureCoords(1, 0, 0, 1)
		-- MTT.arrowTexture2:SetTextureCoords(1, 0, 0, 1)
		-- MTT.arrowTexture3:SetTextureCoords(1, 0, 0, 1)
		side = LEFT
		anchorOffsetX = 0
	elseif MTT.SV.powerType == POWERTYPE_MAGICKA then
		MTT.defaultBar = MTT.defaultMagBar
		MTT.arrowTexture1:SetTextureCoords(0, 1, 0, 1)
		-- MTT.arrowTexture2:SetTextureCoords(0, 1, 0, 1)
		-- MTT.arrowTexture3:SetTextureCoords(0, 1, 0, 1)
		side = RIGHT
		anchorOffsetX = 5
	elseif MTT.SV.powerType == POWERTYPE_HEALTH then
		MTT.defaultBar = MTT.defaultHpBar
		MTT.arrowTexture1:SetTextureCoords(0, 1, 0, 1)
		-- MTT.arrowTexture2:SetTextureCoords(0, 1, 0, 1)
		-- MTT.arrowTexture3:SetTextureCoords(0, 1, 0, 1)
		side = LEFT
		anchorOffsetX = 0
	end

	MTT.defaultTickLabel:ClearAnchors()
	MTT.defaultTickLabel:SetParent(MTT.defaultBar)
	MTT.defaultTickLabel:SetAnchor(RIGHT, MTT.defawultBar, CENTER, MTT.SV.tickAmountHorizontalOffset + 2, -MTT.SV.tickAmountVerticallOffset)
	MTT.defaultTickLabel:SetHidden(true)
	MTT.defaultTickLabel:SetColor(unpack(MTT.SV.tickAmountColor))
	MTT.defaultTickLabel:SetScale(MTT.SV.tickAmountScale / MTT.defaultBar:GetScale())
	

	MTT.amountLabel:ClearAnchors()
	MTT.amountLabel:SetAnchor(CENTER, MTT.container, CENTER, MTT.SV.tickAmountHorizontalOffset / MTT.bar:GetScale(), -MTT.SV.tickAmountVerticallOffset / MTT.bar:GetScale())
	MTT.amountLabel:SetHidden(not MTT.SV.unlocked)
	MTT.amountLabel:SetHidden(not MTT.SV.showTickAmount)
	MTT.amountLabel:SetColor(unpack(MTT.SV.tickAmountColor))
	MTT.amountLabel:SetScale(MTT.SV.tickAmountScale / MTT.bar:GetScale())

	MTT.percentageLabel:SetHidden(not MTT.SV.showBarPercentage)
	
	if MTT.arrow.animDataTick and MTT.arrow.animDataTick:IsPlaying() then MTT.arrow.animDataTick:Stop() end
	local w,h = MTT.defaultBar:GetDimensions()
	-- MTT.arrow:SetHeight(0.8*h)
	MTT.arrow:SetParent(MTT.defaultBar)
	MTT.arrow:ClearAnchors()
	MTT.arrow:SetAnchor(side, MTT.defaultBar, side, anchorOffsetX, translateOffsetY)
	MTT.arrow.offsetX = w - MTT.arrow:GetWidth() - anchorOffsetX
	MTT.arrow.anchorOffsetX = anchorOffsetX
	if side == RIGHT then MTT.arrow.offsetX = - MTT.arrow.offsetX end
	MTT.arrow:SetHidden(true)
	
	ZO_StatusBar_SetGradientColor(MTT.defaultBar:GetNamedChild('Bar'), ZO_POWER_BAR_GRADIENT_COLORS[MTT.SV.powerType])

	if MTT.SV.showFatigue then
		EVENT_MANAGER:RegisterForEvent(MTT.updateName .. "OnCombatEvent", EVENT_COMBAT_EVENT, MTT.OnCombatEvent)
		EVENT_MANAGER:AddFilterForEvent(MTT.updateName .. "OnCombatEvent", EVENT_COMBAT_EVENT,
		REGISTER_FILTER_ABILITY_ID, fatigueAbilityID,
		REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER
	)
	else
		EVENT_MANAGER:UnregisterForEvent(MTT.updateName .. "OnCombatEvent", EVENT_COMBAT_EVENT)
	end
end

function MTT.ManageUnlocked()
	if MTT.SV.unlocked then
		GAME_MENU_SCENE:AddFragment(TICK_TRACKER_FRAGMENT)
		MTT.UnregisterEvents()
		if MTT.control.animDataTick and MTT.control.animDataTick:IsPlaying() then MTT.control.animDataTick:Stop() end
		if MTT.defaultBar.animDataTick and MTT.defaultBar.animDataTick:IsPlaying() then MTT.defaultBar.animDataTick:Stop() end
		MTT.control:SetMovable(true)
		MTT.control:SetHidden(false)
		MTT.percentageLabel:SetText('Unlocked!')
		MTT.amountLabel:SetText('+tick')
		MTT.amountLabel:SetHidden(false)
		MTT.amountLabel:SetColor(1,1,1,1)
		MTT.bar:SetCenterColor(unpack(MTT.SV.barBackgroundColor))
	else
		GAME_MENU_SCENE:RemoveFragment(TICK_TRACKER_FRAGMENT)
		MTT.SetupEvents()
		MTT.control:SetMovable(false)
		MTT.control:SetHidden(not MTT.SV.alwaysShown)
		local barText = {
			[POWERTYPE_STAMINA] = 'Stamina',
			[POWERTYPE_MAGICKA] = 'Magicka',
			[POWERTYPE_HEALTH] = 'Health',
		}
		MTT.percentageLabel:SetText(barText[MTT.SV.powerType])
		MTT.bar:SetCenterColor(unpack(MTT.SV.barBackgroundColor))
		MTT.amountLabel:SetHidden(true)
	end
	MTT.SetupControls()
end

function MTT.CreateAddonMenu()
	local panelData = {
		type = "panel",
		name = "Miat's Tick Tracker",
		displayName = "Miat's Tick Tracker",
		author = "Dorrino, update by Asquart",
		version = MTT.version,
		registerForRefresh = true,
		registerForDefaults = false,
	}
	
	local optionsPanel = LAM:RegisterAddonPanel("MiatsTickTrackerPanel", panelData)
		
	local optionsData = {}
	
	
	table.insert(optionsData, {
		type = "header",
		name = "Tick Tracker Options",
	})
	table.insert(optionsData, {
		type = "checkbox",
		name = "Turn OFF when satisfied with tracker position",
		tooltip = "ON - icon can me moved on the screen by left clicking and dragging, OFF - icon is locked in place and can not be moved",
		default = addonDefaults.unlocked,
		-- disabled = function() return not MTT.SV.enabled end,
		getFunc = function() return MTT.SV.unlocked end,
		setFunc = function(newValue) MTT.SV.unlocked = newValue MTT:ManageUnlocked() end,
	})
	table.insert(optionsData, {
		type = "checkbox",
		name = "Apply the tracker to default bars",
		tooltip = "ON - the tracker is shown on the default resource bars instead of the separate frame, OFF - the tracker is shown only in its own frame",
		default = addonDefaults.attachToDefaultBar,
		-- disabled = function() return not MTT.SV.enabled end,
		getFunc = function() return MTT.SV.attachToDefaultBar end,
		setFunc = function(newValue) MTT.SV.attachToDefaultBar = newValue MTT.SetupControls() end,
	})
	table.insert(optionsData, {
		type = "dropdown",
		name = "Choose resource type to track:",
		tooltip = 'Default is "Stamina"',
		choices = {"Stamina", "Magicka", "Health"},
		getFunc = function() 
			if MTT.SV.powerType == POWERTYPE_STAMINA then 
				return "Stamina"
			elseif MTT.SV.powerType == POWERTYPE_MAGICKA then
				return "Magicka"				
			elseif MTT.SV.powerType == POWERTYPE_HEALTH then
				return "Health"
			end
		end,
		setFunc = function(newValue)
			if newValue == "Stamina" then 
				MTT.SV.powerType = POWERTYPE_STAMINA
			elseif newValue=="Magicka" then
				MTT.SV.powerType = POWERTYPE_MAGICKA
			elseif newValue=="Health" then
				MTT.SV.powerType = POWERTYPE_HEALTH
			end
			MTT.SetupControls()
		end,
		default = "Stamina",
		-- disabled = function() return not MTT.SV.enabled or not MTT.SV.showTargetNameFrame end,
	})
	table.insert(optionsData, {
		type = "checkbox",
		name = "Play tick animation",
		tooltip = "ON - play bouncy bar animation when regeneration tick occurs",
		default = addonDefaults.playTickAnimation,
		getFunc = function() return MTT.SV.playTickAnimation end,
		setFunc = function(newValue) MTT.SV.playTickAnimation = newValue end,
	})
	table.insert(optionsData, {
		type = "submenu",
        name = "Sound",
        controls = {
            {
				type = "checkbox",
				name = "Play sound on resource ticks",
				tooltip = "ON - play the sound, OFF - don't play the sound",
				default = addonDefaults.playSound,
				-- disabled = function() return not MTT.SV.enabled end,
				getFunc = function() return MTT.SV.playSound end,
				setFunc = function(newValue) MTT.SV.playSound = newValue MTT.SetupControls() end,
			},
			{
				type = "dropdown",
				name = "Tick sound",
				tooltip = "Sound to play on resource ticks",
				choices = sounds,
				default = addonDefaults.tickSound,
				getFunc = function()
					return MTT.SV.tickSound
				end,
				setFunc = function(soundName)
					MTT.SV.tickSound = soundName
				end,
				width = "half",
				-- sort = "name-up",
				scrollable = true,
				disabled = function()
					return not MTT.SV.playSound
				end,
			},
			{
				type = "slider",
				name = "Tick sound volume",
				tooltip = "A volume to play sound at. Default is 2",
				min = 1,
				max = 20,
				step = 1,
				default = addonDefaults.tickSoundVolume,
				disabled = function() return not MTT.SV.playSound end,
				getFunc = function() return MTT.SV.tickSoundVolume end,
				setFunc = function(newValue) MTT.SV.tickSoundVolume = newValue end,
			}
        },
	})
	table.insert(optionsData, {
		type = "submenu",
        name = "Progress bar",
        controls = {
			{
				type = "checkbox",
				name = "Show the tracker at all times",
				tooltip = "ON - the tracker will never disappear, OFF - the tracker will be hidden if stam is full",
				default = addonDefaults.alwaysShown,
				-- disabled = function() return MTT.SV.attachToDefaultBar and not MTT.SV.unlocked end,
				getFunc = function() return MTT.SV.alwaysShown end,
				setFunc = function(newValue) MTT.SV.alwaysShown = newValue MTT.SetupControls() end,
			},
			{
				type = "checkbox",
				name = "Show bar percentage",
				tooltip = "ON - shows bar's fill percentage",
				default = addonDefaults.showBarPercentage,
				getFunc = function() return MTT.SV.showBarPercentage end,
				setFunc = function(newValue) MTT.SV.showBarPercentage = newValue MTT.SetupControls() end,
			},
            {
				type = "slider",
				name = "Set tracker Scale (%)",
				tooltip = "Tracker Scale goes from 50% to 200% of original scale",
				default = tonumber(string.format("%.0f", 100*addonDefaults.controlScale)),
				disabled = function() return MTT.SV.attachToDefaultBar and not MTT.SV.unlocked end,
				min     = 10,
				max     = 200,
				step    = 1,
				getFunc = function() return tonumber(string.format("%.0f", 100*MTT.SV.controlScale)) end,
				setFunc = function(newValue) MTT.SV.controlScale = newValue/100 MTT.SetupControls() end,
			},
			{
				type = "slider",
				name = "Set tracker bar width (%)",
				tooltip = "Tracker bar width goes from 50% to 400% of original width",
				default = tonumber(string.format("%.0f", addonDefaults.controlWidth)),
				disabled = function() return MTT.SV.attachToDefaultBar and not MTT.SV.unlocked end,
				min     = 50,
				max     = 400,
				step    = 1,
				getFunc = function() return tonumber(string.format("%.0f", MTT.SV.controlWidth)) end,
				setFunc = function(newValue) MTT.SV.controlWidth = newValue MTT.SetupControls() end,
			},
			{
				type = "colorpicker",
				name = "Bar background color",
				tooltip = "Pick color for bar background (default - black)",
				default = ZO_ColorDef:New(unpack(addonDefaults.barBackgroundColor)),
				getFunc = function() return unpack(MTT.SV.barBackgroundColor) end,
				setFunc = function(r,g,b,a)
					MTT.SV.barBackgroundColor = {r,g,b,a}
					MTT.SetupControls()
				end,
			}
        },
	})
	table.insert(optionsData, {
		type = "submenu",
        name = "Tick amount pup-up",
        controls = {
            {
				type = "checkbox",
				name = "Show regeneration ticks amount",
				tooltip = "ON - pop-up numbers will appear each time regeneration tick happens, OFF - pop-up numbers will be disabled",
				default = addonDefaults.showTickAmount,
				getFunc = function() return MTT.SV.showTickAmount end,
				setFunc = function(newValue) MTT.SV.showTickAmount = newValue MTT.SetupControls() end,
			},
			{
				type = "colorpicker",
				name = "Tick amount pop-up color",
				tooltip = "Pick color for tick amount popup text (default - green)",
				default = ZO_ColorDef:New(unpack(addonDefaults.tickAmountColor)),
				getFunc = function() return unpack(MTT.SV.tickAmountColor) end,
				setFunc = function(r,g,b,a)
					MTT.SV.tickAmountColor = {r,g,b,a}
					MTT.SetupControls()
				end,
			},
			{
				type = "slider",
				name = "Set Tick Amount pop-up scale (%)",
				tooltip = "Tick Amount Scale goes from 50% to 200% of original scale",
				default = tonumber(string.format("%.0f", 100*addonDefaults.controlScale)),
				min     = 50,
				max     = 200,
				step    = 1,
				getFunc = function() return tonumber(string.format("%.0f", 100*MTT.SV.tickAmountScale)) end,
				setFunc = function(newValue) MTT.SV.tickAmountScale = newValue/100 MTT.SetupControls() end,
			},
			{
				type = "slider",
				name = "Tick amount vertical offset",
				tooltip = "The vertical position of the tick amount text",
				min = -500,
				max = 500,
				step = 1,
				default = addonDefaults.tickAmountVerticallOffset,
				getFunc = function() return MTT.SV.tickAmountVerticallOffset end,
				setFunc = function(newValue) MTT.SV.tickAmountVerticallOffset = newValue MTT.SetupControls() end,
			},
			{
				type = "slider",
				name = "Tick amount horizontal offset",
				tooltip = "The horizontal position of the tick amount text",
				min = -500,
				max = 500,
				step = 1,
				default = addonDefaults.tickAmountHorizontalOffset,
				getFunc = function() return MTT.SV.tickAmountHorizontalOffset end,
				setFunc = function(newValue) MTT.SV.tickAmountHorizontalOffset = newValue MTT.SetupControls() end,
			}
        },
	})
	table.insert(optionsData,
	{
		type = "submenu",
		name = "Indicator colors",
		controls = {
			{
				type = "colorpicker",
				name = "Pick color for regenerating state",
				tooltip = "Pick color for regenerating state (default - bright green)",
				default = ZO_ColorDef:New(unpack(addonDefaults.regenColor)),
				getFunc = function() return unpack(MTT.SV.regenColor) end,
				setFunc = function(r,g,b,a)
					MTT.SV.regenColor = {r,g,b,a}
				end,
			},
			{
				type = "colorpicker",
				name = "Pick color for zero regen",
				tooltip = "Pick color for zero regen (default - bright red)",
				default = ZO_ColorDef:New(unpack(addonDefaults.zeroRegenColor)),
				getFunc = function() return unpack(MTT.SV.zeroRegenColor) end,
				setFunc = function(r,g,b,a)
					MTT.SV.zeroRegenColor = {r,g,b,a}
				end,
			},
			{
				type = "slider",
				name = "Pre-tick threshold 1",
				tooltip = "Defines at what percentage to switch to pre-tick color 1 when at zero regen(default in 75)",
				min = 50,
				max = 100,
				step = 1,
				default = addonDefaults.preTickThreshold1,
				getFunc = function() return MTT.SV.preTickThreshold1 end,
				setFunc = function(newValue) MTT.SV.preTickThreshold1 = clamp(newValue, 1, MTT.SV.preTickThreshold2) end,
			},
			{
				type = "colorpicker",
				name = "Pick color 1 for pre-tick state",
				tooltip = "Pick color 1 for pre-tick. Kicks in at the first warning threshold (default - yellow)",
				default = ZO_ColorDef:New(unpack(addonDefaults.preTickColor1)),
				getFunc = function() return unpack(MTT.SV.preTickColor1) end,
				setFunc = function(r,g,b,a)
					MTT.SV.preTickColor1 = {r,g,b,a}
				end,
			},
			{
				type = "slider",
				name = "Pre-tick threshold 2",
				tooltip = "Defines at what percentage to switch to pre-tick color 2 when at zero regen(default in 85)",
				min = 50,
				max = 100,
				step = 1,
				default = addonDefaults.preTickThreshold2,
				getFunc = function() return MTT.SV.preTickThreshold2 end,
				setFunc = function(newValue) MTT.SV.preTickThreshold2 = newValue MTT.SV.preTickThreshold1 = clamp(newValue, 1, MTT.SV.preTickThreshold2) end,
			},
			{
				type = "colorpicker",
				name = "Pick color 2 for pre-tick state",
				tooltip = "Pick color 2 for pre-tick. Kicks in at the second warning threshold (default - orange)",
				default = ZO_ColorDef:New(unpack(addonDefaults.preTickColor2)),
				getFunc = function() return unpack(MTT.SV.preTickColor2) end,
				setFunc = function(r,g,b,a)
					MTT.SV.preTickColor2 = {r,g,b,a}
				end,
			}
		},
	})
	table.insert(optionsData, {
		type = "submenu",
        name = "Dodge fatigue tracking",
        controls = {
            {
				type = "checkbox",
				name = "Show dodge fatigue on tracker bars",
				tooltip = "ON - the bars color will change proportional to the current dodge fatigue, OFF - the bars won't show dodge fatigue",
				default = addonDefaults.showFatigue,
				-- disabled = function() return not MTT.SV.enabled end,
				getFunc = function() return MTT.SV.showFatigue end,
				setFunc = function(newValue) MTT.SV.showFatigue = newValue MTT.SetupControls() end,
			},
			{
				type = "slider",
				name = "Max tracked fatigue count",
				tooltip = "Determines maximum amount of dodge fatigue stacks to take into consideration when applying colors. Lower count means that Maximum Fatigue color will be reached faster",
				min = 1,
				max = 16,
				step = 1,
				default = addonDefaults.maxFatigueCount,
				disabled = function() return not MTT.SV.showFatigue end,
				getFunc = function() return MTT.SV.maxFatigueCount end,
				setFunc = function(newValue) MTT.SV.maxFatigueCount = newValue MTT:GenerateFatugieColors() end,
			},
			{
				type = "colorpicker",
				name = "Min Fatigue color",
				tooltip = "The color to apply when having one fatigue stack (default - yellow)",
				default = ZO_ColorDef:New(unpack(addonDefaults.minFatigueColor)),
				disabled = function() return not MTT.SV.showFatigue end,
				getFunc = function() return unpack(MTT.SV.minFatigueColor) end,
				setFunc = function(r,g,b,a)
					MTT.SV.minFatigueColor = {r,g,b,a}
					MTT:GenerateFatugieColors()
				end,
			},
			{
				type = "colorpicker",
				name = "Max Fatigue color",
				tooltip = "The color to transition to when getting to maximum fatigue stacks (default - fiery orange)",
				default = ZO_ColorDef:New(unpack(addonDefaults.maxFatigueColor)),
				disabled = function() return not MTT.SV.showFatigue end,
				getFunc = function() return unpack(MTT.SV.maxFatigueColor) end,
				setFunc = function(r,g,b,a)
					MTT.SV.maxFatigueColor = {r,g,b,a}
					MTT:GenerateFatugieColors()
				end,
			}
        },
	})
	
	LAM:RegisterOptionControls("MiatsTickTrackerPanel", optionsData)	
end

function MTT.SavePosition(control)
	local coordX, coordY = control:GetCenter()
	MTT.SV.controlOffsetX = coordX-(GuiRoot:GetWidth()/2)
	MTT.SV.controlOffsetY = coordY-(GuiRoot:GetHeight()/2)
	control:ClearAnchors()
	control:SetAnchor(CENTER, GuiRoot, CENTER, MTT.SV.controlOffsetX, MTT.SV.controlOffsetY)
end

function MTT.OnMouseWheel(control, delta)
	if not MTT.SV.unlocked then return end
	
	local scale = MTT.SV.controlScale + delta*0.01
	if scale < 0.5 or scale > 2 then return end
	
	control:SetScale(scale)
	MTT.SV.controlScale = scale
end

function Miats_TickTracker_SavePosition(...)
	MTT.SavePosition(...)
end

function Miats_TickTracker_OnMouseWheel(...)
	MTT.OnMouseWheel(...)
end

function MTT.OnTickUpdate(fromPower)
	local currentTime = GetFrameTimeMilliseconds()
	
	local function ProcessBar(difference)
		local currentPower, maxPower = MTT.GetCurrentPower()
		local powerRegen = MTT.GetPowerRegen()
		local percentage = 100 * difference / 2000
		local control = MTT.container
		local bar = MTT.bar
		local label = MTT.percentageLabel
		local defaultBar = MTT.defaultBar:GetNamedChild('Bar')
		local stamBar = MTT.defaultStamBar:GetNamedChild('Bar')
		if not MTT.SV.attachToDefaultBar then
			bar:SetDimensions((control:GetWidth()/MTT.SV.controlScale-4)*percentage/100, (control:GetHeight()/MTT.SV.controlScale-2))
			label:SetText(tostring(math.floor(percentage))..'%')
		end
        if powerRegen == 0 then
			if percentage > MTT.SV.preTickThreshold1 then
				local color = MTT.SV.preTickColor1
				if percentage > MTT.SV.preTickThreshold2 then
					color = MTT.SV.preTickColor2
				end
				if MTT.SV.attachToDefaultBar then
					defaultBar:SetColor(unpack(color))
				else
					bar:SetCenterColor(unpack(color))
				end
			else
				-- Keep existing behavior for zero powerRegen
				if MTT.SV.attachToDefaultBar then
					defaultBar:SetColor(unpack(MTT.SV.zeroRegenColor))
				else
					bar:SetCenterColor(unpack(MTT.SV.zeroRegenColor))
				end
			end
		elseif MTT.SV.showFatigue and (MTT.SV.powerType == POWERTYPE_STAMINA or MTT.SV.attachToDefaultBar) and MTT.fatigueCount > 0 then

			local fatigueCountClamped = clamp(MTT.fatigueCount, 1, MTT.SV.maxFatigueCount)
			if MTT.SV.attachToDefaultBar then
				stamBar:SetColor(unpack(fatigueColors[fatigueCountClamped]))
			else
				bar:SetCenterColor(unpack(fatigueColors[fatigueCountClamped]))
			end
		else
			if MTT.SV.attachToDefaultBar then
				ZO_StatusBar_SetGradientColor(defaultBar, ZO_POWER_BAR_GRADIENT_COLORS[MTT.SV.powerType])
				if (MTT.SV.showFatigue and MTT.fatigueCount == 0) then
					ZO_StatusBar_SetGradientColor(stamBar, ZO_POWER_BAR_GRADIENT_COLORS[POWERTYPE_STAMINA])
				end	
			else
				bar:SetCenterColor(unpack(MTT.SV.regenColor))
			end
		end

		local isValidScene = SCENE_MANAGER:GetCurrentScene() == HUD_SCENE or SCENE_MANAGER:GetCurrentScene() == HUD_UI_SCENE or SCENE_MANAGER:GetCurrentScene() == LOOT_SCENE or (MTT.SV.unlocked and SCENE_MANAGER:GetCurrentScene() == GAME_MENU_SCENE)
		local shownForAnimation = MTT.control.animDataTick and MTT.control.animDataTick:IsPlaying()
		local hidingCondition = maxPower == currentPower
		local shouldHideControl = MTT.SV.attachToDefaultBar or not isValidScene or (not MTT.SV.alwaysShown and not shownForAnimation and hidingCondition)
		
		MTT.control:SetHidden(shouldHideControl)
		if MTT.SV.attachToDefaultBar and not MTT.SV.alwaysShown and hidingCondition then
			MTT.arrow:SetHidden(true)
		end
	end

	if MTT.trustedTickTime then
		local difference = currentTime - MTT.trustedTickTime
		ProcessBar(difference)
		if difference >= 2010 then
			MTT.trustedTickTime = currentTime
			MTT.wasTickTimeTrusted = false
			if MTT.SV.attachToDefaultBar then
				MTT.arrow.animDataTick = MTT.StartAnimation(MTT.arrow, 'arrow')
			end
		end
	end
end

function MTT.GetCurrentPower()
	return GetUnitPower('player', MTT.SV.powerType)
end

function MTT.OnCombatEvent(result, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _)
	if result == 2240 then
		MTT.fatigueCount = MTT.fatigueCount + 1
	elseif result == 2250 then
		MTT.fatigueCount = 0
	end
end

function MTT.OnWeaponPairLockChanged(locked)
	MTT.weaponPairLocked = locked
end

function MTT.OnPowerUpdate(_, _, _, powerType, powerValue, _, _)
	local function ApplyTick(powerDelta)
		if MTT.SV.playTickAnimation then
			MTT.control.animDataTick = MTT.StartAnimation(MTT.control, 'tick')
			if MTT.SV.attachToDefaultBar then
				MTT.defaultBar.animDataTick = MTT.StartAnimation(MTT.defaultBar, 'tick')
				MTT.arrow.animDataTick = MTT.StartAnimation(MTT.arrow, 'arrow')
			end
		end

		if MTT.SV.playSound then
			MTT.PlayTickSound()
		end
		if MTT.SV.showTickAmount then
			MTT.amountLabel:SetText("+"..tostring(powerDelta))
			MTT.amountLabel:SetColor(unpack(MTT.SV.tickAmountColor))
			MTT.amountLabel:SetHidden(false)
			if MTT.SV.attachToDefaultBar then
				MTT.defaultTickLabel:SetText("+"..tostring(powerDelta))
				MTT.defaultTickLabel:SetColor(unpack(MTT.SV.tickAmountColor))
				MTT.defaultTickLabel:SetHidden(false)
			end
			zo_callLater(function() 
				MTT.amountLabel:SetHidden(true) 
				MTT.defaultTickLabel:SetHidden(true) 
			end, 1500)
		end

	end

	-- d(MTT.weaponPairLocked)
	if powerType == MTT.SV.powerType then
		local currentTime = GetFrameTimeMilliseconds()
		local currentPower = MTT.GetCurrentPower()
		
		if MTT.previousPower then
			local powerDelta = powerValue - MTT.previousPower
			if powerDelta > 0 and powerDelta == MTT.GetPowerRegen() then
				-- if MTT.weaponPairLocked and not MTT.ignoreFirstLockedTick and MTT.trustedTickTime and (currentTime - MTT.trustedTickTime) < 1950 then
					-- MTT.ignoreFirstLockedTick = true
					-- MTT.previousPower = currentPower
					-- return
				-- end
				-- MTT.ignoreFirstLockedTick = nil
				local validSecondDeltaTick
				if MTT.trustedTickTime then
					local timeDelta = currentTime - MTT.trustedTickTime
					if MTT.partialTimeDelta then
						local savedTimeDelta
						savedTimeDelta = currentTime - MTT.partialTimeDelta.currentTime
						local deltaSum = MTT.partialTimeDelta.timeDelta + savedTimeDelta
						validSecondDeltaTick = (deltaSum > 1900) and (deltaSum < 2100)
						MTT.partialTimeDelta = nil
					end
					
					if MTT.wasTickTimeTrusted and timeDelta < 1750 and not validSecondDeltaTick then 
						MTT.previousPower = currentPower 
						if validSecondDeltaTick == nil then
							MTT.partialTimeDelta = {timeDelta = timeDelta, currentTime = currentTime}
						end
						return 
					end
				end
				
				-- if validSecondDeltaTick then d('valid second tick!') end
				
				-- if MTT.weaponPairLocked and MTT.trustedTickTime and ((currentTime - MTT.trustedTickTime) < 1800) then return end
				MTT.trustedTickTime = currentTime
				MTT.wasTickTimeTrusted = true
				if not ((MTT.SV.attachToDefaultBar and MTT.defaultBar.animDataTick and MTT.defaultBar.animDataTick:IsPlaying()) or (not MTT.SV.attachToDefaultBar and MTT.control.animDataTick and MTT.control.animDataTick:IsPlaying())) then
					ApplyTick(powerDelta)
					MTT.OnTickUpdate(true)
				end
			end
		end
		MTT.previousPower = currentPower
	end
end

function MTT.ProcessPower()
	local function ApplyTick(powerDelta)
		MTT.control.animDataTick = MTT.StartAnimation(MTT.control, 'tick')
		if MTT.SV.attachToDefaultBar then
			MTT.defaultBar.animDataTick = MTT.StartAnimation(MTT.defaultBar, 'tick')
			MTT.arrow.animDataTick = MTT.StartAnimation(MTT.arrow, 'arrow')
		end
		if MTT.SV.playSound then
			MTT.PlayTickSound()
		end
		MTT.amountLabel:SetText("+"..tostring(powerDelta))
		MTT.amountLabel:SetColor(unpack(unpack(MTT.SV.tickAmountColor)))
		MTT.amountLabel:SetHidden(false)
		if MTT.SV.attachToDefaultBar then
			MTT.defaultTickLabel:SetText("+"..tostring(powerDelta))
			MTT.defaultTickLabel:SetColor(unpack(unpack(MTT.SV.tickAmountColor)))
			MTT.defaultTickLabel:SetHidden(false)
		end
		zo_callLater(function() 
			MTT.amountLabel:SetHidden(true) 
			MTT.defaultTickLabel:SetHidden(true) 
		end, 1500)
	end
	
	if not MTT.weaponPairLocked then
	
		local currentPower = MTT.GetCurrentPower()
		-- local wasTakeback
		if MTT.previousPower then
			local currentTime = GetFrameTimeMilliseconds()
			local powerDelta = currentPower - MTT.previousPower
			
			if powerDelta<0 and MTT:GetPowerRegen() == -powerDelta then
				-- wasTakeback = true
			end
			
			if powerDelta > 0 and powerDelta == MTT:GetPowerRegen() then

				MTT.trustedTickTime = currentTime
				MTT.wasTickTimeTrusted = true
				ApplyTick(powerDelta)

				
			end
		end
		-- if not wasTakeback then
			MTT.previousPower = currentPower
		-- end
	end
end

function MTT.GetPowerRegen()
	local statTypeCombat, statTypeIdle
	
	if MTT.SV.powerType == POWERTYPE_STAMINA then
		statTypeCombat = STAT_STAMINA_REGEN_COMBAT
		statTypeIdle = STAT_STAMINA_REGEN_IDLE
	elseif MTT.SV.powerType == POWERTYPE_MAGICKA then
		statTypeCombat = STAT_MAGICKA_REGEN_COMBAT
		statTypeIdle = STAT_MAGICKA_REGEN_IDLE	
	elseif MTT.SV.powerType == POWERTYPE_HEALTH then
		statTypeCombat = STAT_HEALTH_REGEN_COMBAT
		statTypeIdle = STAT_HEALTH_REGEN_IDLE	
	end
	
	if IsUnitInCombat('player') then
		return GetPlayerStat(statTypeCombat, STAT_BONUS_OPTION_APPLY_BONUS)
	else
		return GetPlayerStat(statTypeIdle, STAT_BONUS_OPTION_APPLY_BONUS)
	end
end

function MTT.InsertAnimationType(animHandler, animType, control, animDuration, animDelay, animEasing, ...)
	if not animHandler then return end
	if animType==ANIMATION_SCALE then
		local animationScale, startScale, endScale = animHandler:InsertAnimation(ANIMATION_SCALE, control, animDelay), ...
		animationScale:SetScaleValues(startScale, endScale)
		animationScale:SetDuration(animDuration)
		animationScale:SetEasingFunction(animEasing)  
	elseif animType==ANIMATION_ALPHA then
		local animationAlpha, startAlpha, endAlpha = animHandler:InsertAnimation(ANIMATION_ALPHA, control, animDelay), ...
		animationAlpha:SetAlphaValues(startAlpha, endAlpha)
		animationAlpha:SetDuration(animDuration)
		animationAlpha:SetEasingFunction(animEasing) 	
	elseif animType==ANIMATION_TRANSLATE then
		local animationTranslate, startX, startY, offsetX, offsetY = animHandler:InsertAnimation(ANIMATION_TRANSLATE, control, animDelay), ...
   		animationTranslate:SetTranslateOffsets(startX, startY, offsetX, offsetY)
		animationTranslate:SetDuration(animDuration)
		animationTranslate:SetEasingFunction(animEasing)
	elseif animType==ANIMATION_ROTATE3D then
		local animationRotate3D, startPitchRadians, startYawRadians, startRollRadians, endPitchRadians, endYawRadians, endRollRadians = animHandler:InsertAnimation(ANIMATION_ROTATE3D, control, animDelay), ...
		animationRotate3D:SetRotationValues(startPitchRadians, startYawRadians, startRollRadians, endPitchRadians, endYawRadians, endRollRadians)
		animationRotate3D:SetDuration(animDuration)
		animationRotate3D:SetEasingFunction(animEasing)
	elseif animType==ANIMATION_COLOR then
		local animationColor, startPitchRadians, startYawRadians, startRollRadians, endPitchRadians, endYawRadians, endRollRadians = animHandler:InsertAnimation(ANIMATION_COLOR, control, animDelay), ...
		animationRotate3D:SetRotationValues(startPitchRadians, startYawRadians, startRollRadians, endPitchRadians, endYawRadians, endRollRadians)
		animationRotate3D:SetDuration(animDuration)
		animationRotate3D:SetEasingFunction(animEasing)
	end
end



function MTT.StartAnimation(control, animationType, targetParameter)
	if MTT.control.animDataTick then MTT.control.animDataTick:Stop() end
	
	local _, point, relativeTo, relativePoint, offsetX, offsetY = control:GetAnchor()

	control:ClearAnchors()
	control:SetAnchor(point, relativeTo, relativePoint, offsetX, offsetY)
	local scale
	if animationType == 'tick' then
		scale = control:GetScale()
		control:SetScale(scale)
	end
	if animationType == 'arrow' then
		local currentPower, maxPower = MTT.GetCurrentPower()
		control:SetHidden(not MTT.SV.attachToDefaultBar or (not MTT.SV.alwaysShown and (currentPower == maxPower)))

		-- if MTT.SV.powerType == POWERTYPE_STAMINA then
			-- MTT.arrowTexture1:SetTextureCoords(1, 0, 0, 1)
			-- MTT.arrowTexture2:SetTextureCoords(1, 0, 0, 1)
			-- MTT.arrowTexture3:SetTextureCoords(1, 0, 0, 1)
		-- else
		if MTT.SV.powerType == POWERTYPE_HEALTH then
			MTT.arrowTexture1:SetTextureCoords(0, 1, 0, 1)
		end
			-- MTT.arrowTexture2:SetTextureCoords(0, 1, 0, 1)
			-- MTT.arrowTexture3:SetTextureCoords(0, 1, 0, 1)
		-- end
	end
	
    local timeline = ANIMATION_MANAGER:CreateTimeline()
		
	if animationType == 'tick' then
		MTT.InsertAnimationType(timeline, ANIMATION_SCALE, control, 100,   0, 						ZO_EaseOutQuadratic,   	scale, 				1.4*scale)
		MTT.InsertAnimationType(timeline, ANIMATION_SCALE, control, 100, 	150, 					ZO_EaseInQuadratic, 	1.4*scale,   			scale)
	elseif animationType == 'arrow' then
		-- MTT:InsertAnimationType(timeline, ANIMATION_TRANSLATE, control, 2010,   0, ZO_LinearEase,  0, 2, control.offsetX, 2)
		MTT.InsertAnimationType(timeline, ANIMATION_TRANSLATE, control, 1990,   0, ZO_LinearEase,  0, translateOffsetY, MTT.GetTranslateDistance(), translateOffsetY)
	end

	if animationType == 'arrow' and MTT.SV.powerType == POWERTYPE_HEALTH then
		timeline:InsertCallback(function()
			MTT.arrowTexture1:SetTextureCoords(1, 0, 0, 1)
			-- d('flip')
			-- MTT.arrowTexture2:SetTextureCoords(1, 0, 0, 1)
			-- MTT.arrowTexture3:SetTextureCoords(1, 0, 0, 1)
		end, 0.5*timeline:GetDuration())
	end

    timeline:SetHandler('OnStop', function()
		control:ClearAnchors()
		control:SetAnchor(point, relativeTo, relativePoint, offsetX, offsetY)
		if animationType == 'tick' then
			control:SetScale(scale)
		end
		-- if animationType == 'arrow' then
			-- control:SetHidden(true)
		-- end
	end)
	
    timeline:PlayFromStart()
	return timeline
end

function MTT.OnPlayerActivated()
	MTT.Initialize(MiatsTickTrackerFrame)
	HUD_SCENE:AddFragment(TICK_TRACKER_FRAGMENT)
	HUD_UI_SCENE:AddFragment(TICK_TRACKER_FRAGMENT)
	LOOT_SCENE:AddFragment(TICK_TRACKER_FRAGMENT)
end

function MTT.OnAddonLoaded(_, addonName)
	if addonName ~= MTT.updateName then
		return
	end
	EVENT_MANAGER:UnregisterForEvent(MTT.updateName .. "OnAddonLoaded", EVENT_ADD_ON_LOADED)
	TICK_TRACKER_FRAGMENT = ZO_FadeSceneFragment:New(MiatsTickTrackerFrame, nil, 0)
	-- MiatsTickTracker:Initialize(MiatsTickTrackerFrame)
	-- HUD_SCENE:AddFragment(TICK_TRACKER_FRAGMENT)
	-- HUD_UI_SCENE:AddFragment(TICK_TRACKER_FRAGMENT)
	-- LOOT_SCENE:AddFragment(TICK_TRACKER_FRAGMENT)
	MTT.CreateAddonMenu()
	EVENT_MANAGER:RegisterForEvent(MTT.updateName .. "OnPlayerActivated", EVENT_PLAYER_ACTIVATED, MTT.OnPlayerActivated)
end

EVENT_MANAGER:RegisterForEvent(MTT.updateName, EVENT_ADD_ON_LOADED, MTT.OnAddonLoaded)