Effectivedamage = {
	name = 'effectivedamage',
	isLoaded = false
}
local EFFDM = Effectivedamage
local addon_name = EFFDM.name
local hasAPM = false


--sb start
local CRIT_COEFFICIENT = 219.1;
--sb end

EFFDM.defaults_db = {
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
				{ color={1,1,1,1}, level = 2000 },
				{ color={ 0, 128, 0}, level = 5000 },
				{ color={ 0, 0, 255}, level = 7000 },
				{ color={128, 0, 128}, level = 9000 },
				{ color={255, 215, 0}, level = 11000 }
			},
			spell = {
				{ color={1,1,1,1}, level = 2000 },
				{ color={ 0, 128, 0}, level = 5000 },
				{ color={ 0, 0, 255}, level = 7000 },
				{ color={128, 0, 128}, level = 9000 },
				{ color={255, 215, 0}, level = 11000 }
			}
		},
		renderTick = 500
	}
}

local currentPowerLevel = 0


function EFFDM.SaveLocation()
	local effdmgUIControl = EFFDM.UI.control
    EFFDM.db.location.x = effdmgUIControl:GetLeft()
    EFFDM.db.location.y = effdmgUIControl:GetTop()
end

local function legacyRender( inital )
	local settings = EFFDM.db.settings
	local levelSettings = settings.levels

	local color = {1,1,1,1}
	local powerLevel = uespLog.GetEffectiveWeaponPower()--GetPlayerStat(STAT_POWER)
	local powerGroup = levelSettings.weapon

	if settings.powerType.spellPower then
		powerLevel = uespLog.GetEffectiveSpellPower()--GetPlayerStat(STAT_SPELL_POWER)
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
		local effdmgUI = EFFDM.UI
		local powerLabel = effdmgUI.Power

		local r,g,b,a = unpack(color)
		
		--local lastPlayerMG = GetUnitPower("player", POWERTYPE_MAGICKA)
		--local SpellCrit = GetPlayerStat(STAT_SPELL_CRITICAL)
		--local sc = GetPlayerStat(STAT_SPELL_CRITICAL,  STAT_BONUS_OPTION_APPLY_BONUS)	/ CRIT_COEFFICIENT;
			--sc = EFFDM.GetEffectiveSpellPower()

		powerLabel:SetText(powerLevel)
		powerLabel:SetColor(r,g,b,a)
		a = 0.5
		effdmgUI.Border:SetEdgeColor(r, g, b, a)
	end

end

local function hybridRender( inital )
	local settings = EFFDM.db.settings
	local levelSettings = settings.levels
	local effdmgUI = EFFDM.UI
	local statLabelValue = 'EWD'

	local color = {1,1,1,1}
	local powerLevel = uespLog.GetEffectiveWeaponPower()--GetPlayerStat(STAT_POWER)
	local powerGroup = levelSettings.weapon
	local spellPowerLevel = uespLog.GetEffectiveSpellPower()--GetPlayerStat(STAT_SPELL_POWER)

	if spellPowerLevel > powerLevel then
		powerLevel = spellPowerLevel
		powerGroup = levelSettings.spell
		statLabelValue = 'ESD'
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
		local powerLabel = effdmgUI.Power

		effdmgUI.Power:SetText(powerLevel)
		effdmgUI.PowerLabel:SetText(statLabelValue)
		powerLabel:SetColor(r,g,b,a)
		effdmgUI.Border:SetEdgeColor(r, g, b, 0.5)
	end

end

local function render( init )

	if EFFDM.db.settings.hybrid then
		hybridRender( init )
	else
		legacyRender( init )
	end

end

EFFDM.Render = render

function EFFDM.CustomScale(value)

	local effdmgUI = EFFDM.UI

	effdmgUI.Power:SetFont('$(GAMEPAD_BOLD_FONT)|'..tostring( 28 + (28/100*value) )..'|thin-outline')
	effdmgUI.PowerLabel:SetFont('$(BOLD_FONT)|'..tostring( 12 + (12/100*value) )..'|thin-outline')

	local newWidth, newHeight = 80 + (80/100*value), 40 + (40/100*value)
	effdmgUI.BG:SetDimensions( newWidth, newHeight )
	effdmgUI.control:SetDimensions( newWidth, newHeight )
	effdmgUI.Border:SetDimensions( 83 + (83/100*value), 43 + (43/100*value) )

end




-- --------------------
-- Addon initialization
-- --------------------
local function EFFDM_Initialize()

	EFFDM.isLoaded = true
	local settings = EFFDM.db.settings

	EFFDM.UI = {
		control 	= EffectivedamageUI,
		Power 		= EffectivedamageUIPower,
		BG 			= EffectivedamageUIBG,
		PowerLabel 	= EffectivedamageUIPowerLabel,
		Border 		= EffectivedamageUIBorder
	}
	local grayskullUI = EFFDM.UI

	if settings.powerType.spellPower then
		currentPowerLevel = GetPlayerStat(STAT_SPELL_POWER)
		grayskullUI.PowerLabel:SetText('ESD')
	end
	grayskullUI.Power:SetText(currentPowerLevel)

	EVENT_MANAGER:RegisterForUpdate(addon_name..'Render',settings.renderTick,render)
	EVENT_MANAGER:UnregisterForEvent(addon_name, EVENT_ADD_ON_LOADED)

	local grayskullUIBG = grayskullUI.BG
	grayskullUIBG:SetEdgeColor(ZO_ColorDef:New(0,0,0,0):UnpackRGBA())
	grayskullUI.Border:SetCenterColor(ZO_ColorDef:New(0,0,0,0):UnpackRGBA())
	grayskullUIBG:SetCenterColor(unpack(EFFDM.db.settings.backgroundColor))

	EFFDM.CustomScale(settings.customScale)

	render(true)

	local dbLocation = EFFDM.db.location
	local effdmgUIControl = grayskullUI.control

	effdmgUIControl:ClearAnchors()
    effdmgUIControl:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, dbLocation.x, dbLocation.y)

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

    local fragment = ZO_HUDFadeSceneFragment:New(effdmgUIControl, nil, 0)
	HUD_SCENE:AddFragment(fragment)
	HUD_UI_SCENE:AddFragment(fragment)

end
-- local addonInit = EFFDM.Initialize

local function OnPlayerActivated(eventCode)
    EVENT_MANAGER:UnregisterForEvent(addon_name, eventCode)
    EFFDM_Initialize()
end

local function EFFDM_OnAddOnLoaded(event, addOnName)
	--Other addons check
	if addOnName == 'APMeter' then
		hasAPM = true
	else
		if addOnName == addon_name then

			EVENT_MANAGER:UnregisterForEvent(addon_name, EVENT_ADD_ON_LOADED)

			-- Migration script
			if( EffectivedamageSettings and EffectivedamageSettings['Default'] and EffectivedamageSettings['Default'][GetDisplayName()] and EffectivedamageSettings['Default'][GetDisplayName()][GetUnitName("player")] ) then
				
				local mainAccountDataRecord = EffectivedamageSettings['Default'][GetDisplayName()]
				local legacyDataRecord = mainAccountDataRecord[GetUnitName("player")]

				mainAccountDataRecord[GetCurrentCharacterId()] = {}
				mainAccountDataRecord[GetCurrentCharacterId()][GetWorldName()] = legacyDataRecord

				EffectivedamageSettings['Default'][GetDisplayName()][GetUnitName("player")] = nil
			end

			EFFDM.db = ZO_SavedVars:NewCharacterIdSettings("EffectivedamageSettings", 2, GetWorldName(), EFFDM.defaults_db, nil)

			-- if EFFDM.db.settings.global then
			-- 	EFFDM.db = ZO_SavedVars:NewAccountWide('EffectivedamageSettings', 2, nil, EFFDM.db_defaults)
			-- 	EFFDM.db.settings.global = true
			-- end

			EFFDM.buildSettingsMenu()

			EVENT_MANAGER:RegisterForEvent(addon_name, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
		end
	end
end
-- --------------------
-- Attach Listeners
-- --------------------
EVENT_MANAGER:RegisterForEvent(addon_name, EVENT_ADD_ON_LOADED, EFFDM_OnAddOnLoaded)