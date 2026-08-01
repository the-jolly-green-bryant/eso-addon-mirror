Greyskull = {
	name = 'greyskull',
	isLoaded = false
}
local GS = Greyskull
local addon_name = GS.name
local hasAPM = false

GS.defaults_db = {
	location = {
		x = 0,
		y = 0
	},
	settings = {
		global = false,
		customScale = 20,
		backgroundColor={0,0,0,0.8},
		powerType = {
			spellPower = false,
			weaponPower = true
		},
		hybrid = false,
		levels = {
			weapon = {
				{ color={1,1,1,1}, level = 0 },
				{ color={1,1,1,1}, level = 0 },
				{ color={1,1,1,1}, level = 0 },
				{ color={1,1,1,1}, level = 0 },
				{ color={1,1,1,1}, level = 0 }
			},
			spell = {
				{ color={1,1,1,1}, level = 0 },
				{ color={1,1,1,1}, level = 0 },
				{ color={1,1,1,1}, level = 0 },
				{ color={1,1,1,1}, level = 0 },
				{ color={1,1,1,1}, level = 0 }
			}
		},
		renderTick = 500
	}
}

local currentPowerLevel = 0
local inspirationalBanter = {
    'You really need to think that you are good at this.',
    'Honestly, if you were any slower, you’d be going backward.',
    'Amassing a 24 man group will increase your survivability.',
    'Impen is kind of important, but so is being good.',
    'Have you tried PVE?',
    'Consider the mongoose, would they have put up a fight like this? Get back in there champ, and keep the claws up.',
    'Wow. We are actually speechless.',
    'Have you tried actually trying?',
    'Have you tried resetting your router?',
    'Next time, stick them with the pointy end.',
    'Impen really really really really helps.',
    'Next time, don’t make insulting yo moma emotes, it just angers them.',
    'Actually having damage.',
    'Lift with your legs, not your back.',
    'If there are two coconuts, and you take one away, the remaining coconut would still last longer than you did.',
    'Equip more Earthgores.',
    'Search for tutorials on YouTube, you may just get a tiny bit better.',
    'If you happened to be streaming on Twitch during this, it is all kind of funny if you think about it.',
    'You should listen to encouraging music when fighting, like Bon Jovi.',
    'Hold block a bit more.',
    'If only you had gotten that other Artifact',
    'Stop trying and join the Greybeards',
    'Maybe Crafting Writs are more your level',
    'The objective is to stay alive',
    'Have you considered doing normal level dungeons instead?',
	'Oops, you died so fast - I didn\'t have time to generate tips',
	'You could make a TikTok out of that and get some feedback'
}

function GS.SaveLocation()
	local greyskullUIControl = GS.UI.control
    GS.db.location.x = greyskullUIControl:GetLeft()
    GS.db.location.y = greyskullUIControl:GetTop()
end

local function legacyRender( inital )
	local settings = GS.db.settings
	local levelSettings = settings.levels

	local color = {1,1,1,1}
	local powerLevel = GetPlayerStat(STAT_POWER)
	local powerGroup = levelSettings.weapon

	if settings.powerType.spellPower then
		powerLevel = GetPlayerStat(STAT_SPELL_POWER)
		powerGroup = levelSettings.spell
	end

	for i in pairs(powerGroup) do

		local alertLevel = tonumber(powerGroup[i].level)
		alertLevel = alertLevel or 0 -- = defaults.settings.levels.weapon/spell.level
		if alertLevel ~= 0 and powerLevel >= alertLevel then
			color = powerGroup[i].color
		end
	
	end

	if currentPowerLevel ~= powerLevel or inital then
		currentPowerLevel = powerLevel
		local greyskullUI = GS.UI
		local powerLabel = greyskullUI.Power

		local r,g,b,a = unpack(color)

		powerLabel:SetText(powerLevel)
		powerLabel:SetColor(r,g,b,a)
		a = 0.5
		greyskullUI.Border:SetEdgeColor(r, g, b, a)
	end

end

local function hybridRender( inital )
	local settings = GS.db.settings
	local levelSettings = settings.levels
	local greyskullUI = GS.UI
	local statLabelValue = 'WD'

	local color = {1,1,1,1}
	local powerLevel = GetPlayerStat(STAT_POWER)
	local powerGroup = levelSettings.weapon
	local spellPowerLevel = GetPlayerStat(STAT_SPELL_POWER)

	if spellPowerLevel > powerLevel then
		powerLevel = spellPowerLevel
		powerGroup = levelSettings.spell
		statLabelValue = 'SD'
	end

	for i in pairs(powerGroup) do

		local alertLevel = tonumber(powerGroup[i].level)
		alertLevel = alertLevel or 0 -- = defaults.settings.levels.weapon/spell.level
		if alertLevel ~= 0 and powerLevel >= alertLevel then
			color = powerGroup[i].color
		end
	
	end

	if currentPowerLevel ~= powerLevel or inital then
		currentPowerLevel = powerLevel
		local r,g,b,a = unpack(color)
		local powerLabel = greyskullUI.Power

		greyskullUI.Power:SetText(powerLevel)
		greyskullUI.PowerLabel:SetText(statLabelValue)
		powerLabel:SetColor(r,g,b,a)
		greyskullUI.Border:SetEdgeColor(r, g, b, 0.5)
	end

end

local function render( init )

	if GS.db.settings.hybrid then
		hybridRender( init )
	else
		legacyRender( init )
	end

end
GS.Render = render

function GS.CustomScale(value)

	local greyskullUI = GS.UI

	greyskullUI.Power:SetFont('$(GAMEPAD_BOLD_FONT)|'..tostring( 28 + (28/100*value) )..'|thin-outline')
	greyskullUI.PowerLabel:SetFont('$(BOLD_FONT)|'..tostring( 12 + (12/100*value) )..'|thin-outline')

	local newWidth, newHeight = 80 + (80/100*value), 40 + (40/100*value)
	greyskullUI.BG:SetDimensions( newWidth, newHeight )
	greyskullUI.control:SetDimensions( newWidth, newHeight )
	greyskullUI.Border:SetDimensions( 83 + (83/100*value), 43 + (43/100*value) )

end

-- --------------------
-- Addon initialization
-- --------------------
local function GS_Initialize()

	GS.isLoaded = true
	local settings = GS.db.settings

	GS.UI = {
		control 	= GreyskullUI,
		Power 		= GreyskullUIPower,
		BG 			= GreyskullUIBG,
		PowerLabel 	= GreyskullUIPowerLabel,
		Border 		= GreyskullUIBorder
	}
	local grayskullUI = GS.UI

	if settings.powerType.spellPower then
		currentPowerLevel = GetPlayerStat(STAT_SPELL_POWER)
		grayskullUI.PowerLabel:SetText('SD')
	end
	grayskullUI.Power:SetText(currentPowerLevel)

	EVENT_MANAGER:RegisterForUpdate(addon_name..'Render',settings.renderTick,render)
	EVENT_MANAGER:UnregisterForEvent(addon_name, EVENT_ADD_ON_LOADED)

	local grayskullUIBG = grayskullUI.BG
	grayskullUIBG:SetEdgeColor(ZO_ColorDef:New(0,0,0,0):UnpackRGBA())
	grayskullUI.Border:SetCenterColor(ZO_ColorDef:New(0,0,0,0):UnpackRGBA())
	grayskullUIBG:SetCenterColor(unpack(GS.db.settings.backgroundColor))

	GS.CustomScale(settings.customScale)

	render(true)

	local dbLocation = GS.db.location
	local greyskullUIControl = grayskullUI.control

	greyskullUIControl:ClearAnchors()
    greyskullUIControl:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, dbLocation.x, dbLocation.y)

    if not hasAPM then
	    EVENT_MANAGER:RegisterForEvent(addon_name, EVENT_PLAYER_DEAD, function()
	        if IsInCampaign() or IsActiveWorldBattleground() then
	            zo_callLater(function()
	                local text = inspirationalBanter[math.random(#inspirationalBanter)]
	                ZO_DeathRecapScrollContainerScrollChildHintsContainerHints1Text:SetText(text)
	            end,3000)
	        end

	    end)
    end

    local fragment = ZO_HUDFadeSceneFragment:New(greyskullUIControl, nil, 0)
	HUD_SCENE:AddFragment(fragment)
	HUD_UI_SCENE:AddFragment(fragment)

end
-- local addonInit = GS.Initialize

local function OnPlayerActivated(eventCode)
    EVENT_MANAGER:UnregisterForEvent(addon_name, eventCode)
    GS_Initialize()
end

local function GS_OnAddOnLoaded(event, addOnName)
	--Other addons check
	if addOnName == 'APMeter' then
		hasAPM = true
	else
		if addOnName == addon_name then

			EVENT_MANAGER:UnregisterForEvent(addon_name, EVENT_ADD_ON_LOADED)

			-- Migration script
			if( GreyskullSettings and GreyskullSettings['Default'] and GreyskullSettings['Default'][GetDisplayName()] and GreyskullSettings['Default'][GetDisplayName()][GetUnitName("player")] ) then
				
				local mainAccountDataRecord = GreyskullSettings['Default'][GetDisplayName()]
				local legacyDataRecord = mainAccountDataRecord[GetUnitName("player")]

				mainAccountDataRecord[GetCurrentCharacterId()] = {}
				mainAccountDataRecord[GetCurrentCharacterId()][GetWorldName()] = legacyDataRecord

				GreyskullSettings['Default'][GetDisplayName()][GetUnitName("player")] = nil
			end

			GS.db = ZO_SavedVars:NewCharacterIdSettings("GreyskullSettings", 2, GetWorldName(), GS.defaults_db, nil)

			-- if GS.db.settings.global then
			-- 	GS.db = ZO_SavedVars:NewAccountWide('GreyskullSettings', 2, nil, GS.db_defaults)
			-- 	GS.db.settings.global = true
			-- end

			GS.buildSettingsMenu()

			EVENT_MANAGER:RegisterForEvent(addon_name, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
		end
	end
end
-- --------------------
-- Attach Listeners
-- --------------------
EVENT_MANAGER:RegisterForEvent(addon_name, EVENT_ADD_ON_LOADED, GS_OnAddOnLoaded)