ShadowImageRange = {}

local NAME = 'ShadowImageRange'
local VERSION = '1.4'

local SIR = ShadowImageRange
local EM = EVENT_MANAGER
local SV
local PI = math.pi
local strformat = string.format

local uiLocked = true
local defaultSettings = {enableDistance = true, enableArrow = true}

local TEXTURE_ACTIVE = 'esoui/art/icons/ability_nightblade_001.dds'
local TEXTURE_INACTIVE = 'esoui/art/icons/ability_nightblade_001_b.dds'

local fragment
local imageShow = false -- control should be shown
local imageActive = false -- shadow is casted, initialized and can be ported to
local imageEnd = 0 -- shadow endTime
local imageTag = '' -- shadow unit tag
local imageId = 0 -- shadow unit id

local debug = false -- debug mode
local function dbg(msg, ...)
	if debug then d(strformat('[SIR] ' .. msg, ...)) end
end

local function Initialize()

	SV = ZO_SavedVars:NewCharacterIdSettings('ShadowImageRangeSV', 1, nil, defaultSettings)

	SIR.BuildMenu(SV, defaultSettings)
	SIR.RestorePosition()

	-- Controls shortcuts.
	local control = ShadowImageRangeControl
	local bg = ShadowImageRangeControl_BG
	local icon = ShadowImageRangeControl_Icon
	local label = ShadowImageRangeControl_Label
	local meters = ShadowImageRangeControl_Meters
	local arrow = ShadowImageRangeControl_Arrow

	-- Create scene fragment.
	fragment = ZO_SimpleSceneFragment:New(control)
	fragment:SetConditional(function() return imageShow or not uiLocked end)
	HUD_SCENE:AddFragment(fragment)
	HUD_UI_SCENE:AddFragment(fragment)

	-- Event names.
	local eventUpdate = NAME .. 'Update'
	local eventCast = NAME .. 'Cast'
	local eventInit = NAME .. 'Init'
	local eventPort = NAME .. 'Port'

	-- Reset controls.
	local function Reset()
		EM:UnregisterForUpdate(eventUpdate)

		imageShow = false
		imageActive = false
		imageEnd = 0
		imageId = 0
		icon:SetTexture(TEXTURE_INACTIVE)

		fragment:Refresh()

		dbg('|cCCCCCCReset controls|r')
	end

	-- Update controls.
	local function Update()

		local remain = zo_ceil(imageEnd - GetFrameTimeSeconds())

		if remain > -4 then
			-- Show control if image is up or expired less than 5 seconds ago.
			imageShow = true

			local r, g, b = 0, 1, 0

			-- Show remaining duration.
			if remain < 1 then
				r, g, b = 1, 0, 0
			elseif remain < 6 then
				r, g, b = 1, 1, 0
			end
			label:SetText(strformat('%d', zo_max(0, remain)))
			label:SetColor(r, g, b)

			-- Calculate distance to image.
			local imageZone, x1, y1, z1 = GetUnitWorldPosition(imageTag)
			if imageZone > 0 then
				local _, x2, y2, z2 = GetUnitWorldPosition('player')
				local distance = zo_distance3D(x1, y1, z1, x2, y2, z2) / 100

				if distance < 28 then
					r, g, b = 0, 1, 0
				else
					r, g, b = 1, 0, 0
				end
				bg:SetColor(r, g, b)

				-- Show distance to image.
				if SV.enableDistance then
					meters:SetText(strformat('%0.1fm', distance))
					meters:SetColor(r, g, b)
					meters:SetHidden(false)
				else
					meters:SetHidden(true)
				end

				-- Change arrow direction.
				if SV.enableArrow then
					arrow:SetTextureRotation(zo_mod(math.atan2(x2 - x1, z2 - z1) - GetPlayerCameraHeading(), PI * 2))
					arrow:SetColor(r, g, b)
					arrow:SetHidden(false)
				else
					arrow:SetHidden(true)
				end
			else
				bg:SetColor(1, 0, 0)
				meters:SetHidden(true)
				arrow:SetHidden(true)
			end

			fragment:Refresh()
		else
			Reset()
		end

	end

	-- Image is casted or faded.
	local function Cast(_, change, _, _, unitTag, _, endTime, _, _, _, _, _, _, _, unitId)
		if change == EFFECT_RESULT_GAINED then
			imageActive = false -- image is casted, but it's not active yet
			icon:SetTexture(TEXTURE_ACTIVE) -- although we change texture to active to avoid confusion
			imageEnd, imageTag, imageId = endTime, unitTag, unitId

			-- Start calculating distance to image.
			EM:UnregisterForUpdate(eventUpdate)
			EM:RegisterForUpdate(eventUpdate, 100, Update)
			Update()

			dbg('|c00FF00Casted image #%s|r', imageTag)
		elseif change == EFFECT_RESULT_FADED and unitId == imageId then
			imageActive = false
			icon:SetTexture(TEXTURE_INACTIVE)
			imageEnd = GetFrameTimeSeconds()
			dbg('|cFF0000Removed image #%d|r', unitId)
		end
	end

	-- Image is initialized (player can port).
	local function Init(_, _, _, _, _, _, _, _, _, _, _, _, _, _, _, targetUnitId)
		if targetUnitId == imageId then
			imageActive = true
			icon:SetTexture(TEXTURE_ACTIVE)
			dbg('|c00FF00Initialized image #%d|r', imageId)
		end
	end

	-- Player ported to image.
	local function Port()
		-- Must check if image is active, because this event can fire for nonexistent image.
		if imageActive then
			dbg('|c00FFFFPorted to image #%d|r', imageId)
			Reset()
		end
	end

	-- Shadow Image cast.
	EM:RegisterForEvent(eventCast, EVENT_EFFECT_CHANGED, Cast)
	EM:AddFilterForEvent(eventCast, EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, 38528)
	EM:AddFilterForEvent(eventCast, EVENT_EFFECT_CHANGED, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)

	-- Shadow initialized.
	EM:RegisterForEvent(eventInit, EVENT_COMBAT_EVENT, Init)
	EM:AddFilterForEvent(eventInit, EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 65269)
	EM:AddFilterForEvent(eventInit, EVENT_COMBAT_EVENT, REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER_PET)
	EM:AddFilterForEvent(eventInit, EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_EFFECT_FADED)

	-- Port to Shadow Image.
	EM:RegisterForEvent(eventPort, EVENT_COMBAT_EVENT, Port)
	EM:AddFilterForEvent(eventPort, EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 35451)
	EM:AddFilterForEvent(eventPort, EVENT_COMBAT_EVENT, REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
	EM:AddFilterForEvent(eventPort, EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_EFFECT_FADED)

	-- Reset controls when player is activated.
	EM:RegisterForEvent(NAME, EVENT_PLAYER_ACTIVATED, Reset)
end

function SIR.GetName()
	return NAME
end

function SIR.GetVersion()
	return VERSION
end

function SIR.Move()
	SV.controlCenterX, SV.controlCenterY = ShadowImageRangeControl:GetCenter()
	ShadowImageRangeControl:ClearAnchors()
	ShadowImageRangeControl:SetAnchor(CENTER, GuiRoot, TOPLEFT, SV.controlCenterX, SV.controlCenterY)
end

function SIR.RestorePosition()
	local controlCenterX = SV.controlCenterX
	local controlCenterY = SV.controlCenterY
	if controlCenterX or controlCenterY then
		ShadowImageRangeControl:ClearAnchors()
		ShadowImageRangeControl:SetAnchor(CENTER, GuiRoot, TOPLEFT, controlCenterX, controlCenterY)
	end
end

function SIR.IsLockedUI()
	return uiLocked
end

function SIR.SetLockedUI(locked)
	assert(type(locked) == 'boolean', 'UI Locked must be boolean.')
	uiLocked = locked
	fragment:Refresh()
end

function SIR.IsDebugMode()
	return debug
end

function SIR.SetDebugMode(mode)
	assert(type(mode) == 'boolean', 'Debug mode must be boolean.')
	debug = mode
end

local function OnAddOnLoaded(event, addonName)
	if addonName == NAME then
		EM:UnregisterForEvent(NAME, EVENT_ADD_ON_LOADED)
		Initialize()
	end
end

if GetUnitClassId('player') == 3 then -- nightblades only!
	EM:RegisterForEvent(NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
end