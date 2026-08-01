CritWidget = {
	name = 'critwidget',
	isLoaded = false
}
local CW = CritWidget
local addon_name = CW.name
local hasAPM = false

CW.defaults_db = {
	location = {
		x = 0,
		y = 97.4759368896
	},
	settings = {
		global = false,
		customScale = 20,
		backgroundColor={0,0,0,0.8},
		critType = {
			spellCrit = false,
			weaponCrit = true
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

local currentCritLevel = 0

function CW.SaveLocation()
	local critwidgetUIControl = CW.UI.control
    CW.db.location.x = critwidgetUIControl:GetLeft()
    CW.db.location.y = critwidgetUIControl:GetTop()
end

local function legacyRender( inital )
	local settings = CW.db.settings
	local levelSettings = settings.levels

	local color = {1,1,1,1}
	local critLevel = math.floor((GetPlayerStat(STAT_CRITICAL_STRIKE)/219*10) + 0.5)/10
	local critGroup = levelSettings.weapon

	if settings.critType.spellCrit then
		critLevel = math.floor((GetPlayerStat(STAT_SPELL_CRITICAL)/219*10) + 0.5)/10
		critGroup = levelSettings.spell
	end

	for i in pairs(critGroup) do

		local alertLevel = tonumber(critGroup[i].level)
		alertLevel = alertLevel or 0 -- = defaults.settings.levels.weapon/spell.level
		if alertLevel ~= 0 and critLevel >= alertLevel then
			color = critGroup[i].color
		end
	
	end

	if currentCritLevel ~= critLevel or inital then
		currentCritLevel = critLevel
		local critwidgetUI = CW.UI
		local critLabel = critwidgetUI.Crit

		local r,g,b,a = unpack(color)

		critLabel:SetText(tostring(critLevel)..'%')
		critLabel:SetColor(r,g,b,a)
		a = 0.5
		critwidgetUI.Border:SetEdgeColor(r, g, b, a)
	end

end

local function hybridRender( inital )
	local settings = CW.db.settings
	local levelSettings = settings.levels
	local critwidgetUI = CW.UI
	local statLabelValue = 'WC'

	local color = {1,1,1,1}
	local critLevel = math.floor((GetPlayerStat(STAT_CRITICAL_STRIKE)/219*10) + 0.5)/10
	local critGroup = levelSettings.weapon
	local spellCritLevel = math.floor((GetPlayerStat(STAT_SPELL_CRITICAL)/219*10) + 0.5)/10

	if spellCritLevel > critLevel then
		critLevel = spellCritLevel
		critGroup = levelSettings.spell
		statLabelValue = 'SC'
	end

	for i in pairs(critGroup) do

		local alertLevel = tonumber(critGroup[i].level)
		alertLevel = alertLevel or 0 -- = defaults.settings.levels.weapon/spell.level
		if alertLevel ~= 0 and critLevel >= alertLevel then
			color = critGroup[i].color
		end
	
	end

	if currentCritLevel ~= critLevel or inital then
		currentCritLevel = critLevel
		local r,g,b,a = unpack(color)
		local crit = critwidgetUI.Crit
		local critBorder = critwidgetUI.Border
		local critLabel = critwidgetUI.CritLabel

		crit:SetText(tostring(critLevel)..'%')
		critLabel:SetText(statLabelValue)
		critLabel:SetColor(r,g,b,a)
		critBorder:SetEdgeColor(r, g, b, 0.5)
	end

end

local function render( init )

	if CW.db.settings.hybrid then
		hybridRender( init )
	else
		legacyRender( init )
	end

end
CW.Render = render

function CW.CustomScale(value)

	local critwidgetUI = CW.UI

	critwidgetUI.Crit:SetFont('$(GAMEPAD_BOLD_FONT)|'..tostring( 28 + (28/100*value) )..'|thin-outline')
	critwidgetUI.CritLabel:SetFont('$(BOLD_FONT)|'..tostring( 12 + (12/100*value) )..'|thin-outline')

	local newWidth, newHeight = 80 + (80/100*value), 40 + (40/100*value)
	critwidgetUI.BG:SetDimensions( newWidth, newHeight )
	critwidgetUI.control:SetDimensions( newWidth, newHeight )
	critwidgetUI.Border:SetDimensions( 83 + (83/100*value), 43 + (43/100*value) )

end

-- --------------------
-- Addon initialization
-- --------------------
local function GS_Initialize()

	CW.isLoaded = true
	local settings = CW.db.settings

	CW.UI = {
		control 	= CritWidgetUI,
		Crit 		= CritWidgetUICrit,
		BG 			= CritWidgetUIBG,
		CritLabel 	= CritWidgetUICritLabel,
		Border 		= CritWidgetUIBorder
	}
	local critwidgetUI = CW.UI

	if settings.critType.spellCrit then
		currentCritLevel = math.floor((GetPlayerStat(STAT_SPELL_CRITICAL)/219*10) + 0.5)/10
		critwidgetUI.CritLabel:SetText('SC')
	end
	critwidgetUI.Crit:SetText(tostring(currentCritLevel)..'%')

	EVENT_MANAGER:RegisterForUpdate(addon_name..'Render',settings.renderTick,render)
	EVENT_MANAGER:UnregisterForEvent(addon_name, EVENT_ADD_ON_LOADED)

	local critwidgetUIBG = critwidgetUI.BG
	critwidgetUIBG:SetEdgeColor(ZO_ColorDef:New(0,0,0,0):UnpackRGBA())
	critwidgetUI.Border:SetCenterColor(ZO_ColorDef:New(0,0,0,0):UnpackRGBA())
	critwidgetUIBG:SetCenterColor(unpack(CW.db.settings.backgroundColor))

	CW.CustomScale(settings.customScale)

	render(true)

	local dbLocation = CW.db.location
	local critwidgetUIControl = critwidgetUI.control

	critwidgetUIControl:ClearAnchors()
    critwidgetUIControl:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, dbLocation.x, dbLocation.y)

    local fragment = ZO_HUDFadeSceneFragment:New(critwidgetUIControl, nil, 0)
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
			if( CritWidgetSettings and CritWidgetSettings['Default'] and CritWidgetSettings['Default'][GetDisplayName()] and CritWidgetSettings['Default'][GetDisplayName()][GetUnitName("player")] ) then
				
				local mainAccountDataRecord = CritWidgetSettings['Default'][GetDisplayName()]
				local legacyDataRecord = mainAccountDataRecord[GetUnitName("player")]

				mainAccountDataRecord[GetCurrentCharacterId()] = {}
				mainAccountDataRecord[GetCurrentCharacterId()][GetWorldName()] = legacyDataRecord

				CritWidgetSettings['Default'][GetDisplayName()][GetUnitName("player")] = nil
			end

			CW.db = ZO_SavedVars:NewCharacterIdSettings("CritWidgetSettings", 2, GetWorldName(), CW.defaults_db, nil)

			-- if GS.db.settings.global then
			-- 	GS.db = ZO_SavedVars:NewAccountWide('CritMeterSettings', 2, nil, GS.db_defaults)
			-- 	GS.db.settings.global = true
			-- end

			CW.buildSettingsMenu()

			EVENT_MANAGER:RegisterForEvent(addon_name, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
		end
	end
end
-- --------------------
-- Attach Listeners
-- --------------------
EVENT_MANAGER:RegisterForEvent(addon_name, EVENT_ADD_ON_LOADED, GS_OnAddOnLoaded)