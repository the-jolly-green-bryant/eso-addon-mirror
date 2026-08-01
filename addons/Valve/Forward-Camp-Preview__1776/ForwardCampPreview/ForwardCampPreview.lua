local addon = {
	name = "ForwardCampPreview",
	title = "Forward Camp Preview",
	version = "1.1.3",
	author = "Valve",
	defaults = {
		previewEnabled = true,
		updateRate = 100,
		timerAlwaysVisible = true,
	},
	forwardCampSlotted = false,
	updateActive = false,
	previewPlaced = false
}

local forwardCampTexture = {
	[ALLIANCE_ALDMERI_DOMINION]    = "/esoui/art/icons/ava_siege_ui_006.dds",	-- AD = 1
	[ALLIANCE_EBONHEART_PACT]      = "/esoui/art/icons/ava_siege_ui_008.dds",	-- EP = 2
	[ALLIANCE_DAGGERFALL_COVENANT] = "/esoui/art/icons/ava_siege_ui_007.dds",	-- DC = 3
}

local LMP = LibMapPins
local LAM2 = LibAddonMenu2

local org_ZO_WorldMap_RefreshRespawnTimer = ZO_WorldMap_RefreshRespawnTimer
local alliance = GetUnitAlliance("player")

local pinData =
{
	level = 110,
	texture = nil,
	size = 0,
	--tint = nil
	grayscale = false,
	insetX = 0,
	insetY = 0,
	minSize = 0,
	--minAreaSize = 
	showsPinAndArea = true,
	isAnimated = false
}

local function OnAddonLoaded(event, name)
	if name ~= addon.name then return end
	EVENT_MANAGER:UnregisterForEvent(addon.name, EVENT_ADD_ON_LOADED)
	addon.sv = ZO_SavedVars:NewAccountWide(addon.name .. "_dat", 1, nil, addon.defaults)
	addon:Initialise()
end

function addon:CanPreviewCamp()
	if not IsInCyrodiil() then return false end					--forward camps can be placed in Cyrodiil only	
	if not self.forwardCampSlotted then return false end				--is a forward camp slotted?
	if not self.sv.previewEnabled then return false end			--is the preview option enabled?
	return true
end

function addon.addForwardCampRadiusPreview()
	local normalizedX, normalizedY, _ = GetMapPlayerPosition("player")
	LMP:CreatePin("PreviewForwardCamp", "PreviewForwardCamp", normalizedX, normalizedY, 0.026000000536442)
	addon.previewPlaced = true
end

function addon.removeForwardCampRadiusPreview()
	LMP:RemoveCustomPin("PreviewForwardCamp", "PreviewForwardCamp")
	addon.previewPlaced = false
end

function addon.UpdateCampPreview()
	if addon.previewPlaced then
		addon.removeForwardCampRadiusPreview()
	end
	if not addon:CanPreviewCamp() then
		EVENT_MANAGER:UnregisterForUpdate(addon.name)
		addon.updateActive = false
	else
		if not (GetMapType() == MAPTYPE_ZONE) then return end							--none of the subzones support forward camps
		if not (GetMapFilterType() == MAP_FILTER_TYPE_AVA_CYRODIIL) then return end		--even in Cyrodiil, players can view other zones... let's try not place the camp preview there but keep placing it when they return to the Cyrodiil map
		addon.addForwardCampRadiusPreview()
	end
end

function addon.QuickSlotChanged(event, slotId)
	local texture = GetSlotTexture(slotId, HOTBAR_CATEGORY_QUICKSLOT_WHEEL)
	addon.forwardCampSlotted = forwardCampTexture[alliance] == texture
	if not addon:CanPreviewCamp() then return end
	if not addon.updateActive then
		addon.updateActive = true
		EVENT_MANAGER:RegisterForUpdate(addon.name, addon.sv.updateRate, addon.UpdateCampPreview)
	end
end

local function RefreshRespawnTimer(currentTime)
	org_ZO_WorldMap_RefreshRespawnTimer(currentTime)
	local isTimerHidden = true
	local g_nextRespawnTimeMS = GetNextForwardCampRespawnTime()
	local currentTimeMS = currentTime * 1000
	if (currentTimeMS > g_nextRespawnTimeMS) then
		 isTimerHidden = true
	else
		local secondsRemaining = (g_nextRespawnTimeMS - currentTimeMS) / 1000
		formattedTimeRemaining = ZO_FormatTimeAsDecimalWhenBelowThreshold(secondsRemaining)
		isTimerHidden = false
	end
	if IsInGamepadPreferredMode() then
		local timerText = isTimerHidden and "" or GetString(SI_MAP_FORWARD_CAMP_RESPAWN_COOLDOWN)
		local data =
		{
			data1HeaderText = timerText,
			data1Text = formattedTimeRemaining
		}
		GAMEPAD_GENERIC_FOOTER:Refresh(data)
	else
		ZO_WorldMapRespawnTimerValue:SetText(formattedTimeRemaining)
		WORLD_MAP_RESPAWN_TIMER_FRAGMENT_KEYBOARD:SetHiddenForReason("TimerInactive", isTimerHidden)
	end
end

function addon:updateCooldownDisplay()
	if self.sv.timerAlwaysVisible then
		ZO_WorldMap_RefreshRespawnTimer = RefreshRespawnTimer
	else
		ZO_WorldMap_RefreshRespawnTimer = org_ZO_WorldMap_RefreshRespawnTimer
	end
end

function addon:Initialise()

	local panelData = {
		type = "panel",
		name = addon.name,
		displayName = addon.title,
		author = addon.author,
		version = addon.version,
		registerForRefresh = true,
		registerForDefaults = true,
		website = "http://www.esoui.com/downloads/info1776-ForwardCampPreview.html",
	}
	LAM2:RegisterAddonPanel(addon.name, panelData)
	
	local optionsTable = {}
	optionsTable[#optionsTable+1] =
		{
			type = "header",
			name = GetString(SI_FCP_DESC_HEADER),
		}
	optionsTable[#optionsTable+1] =
		{
			type = "description",
			text = GetString(SI_FCP_ADDON_DESC),
		}
	optionsTable[#optionsTable+1] =
		{
			type = "header",
			name = GetString(SI_FCP_OPTIONS_HEADER),
		}

	optionsTable[#optionsTable+1] =
		{
			type = "description",
			text = GetString(SI_FCP_RADIUS_DESC),
		}
	optionsTable[#optionsTable+1] =
		{
			type = "checkbox",
			name = GetString(SI_FCP_RADIUS_OPT),
			tooltip = GetString(SI_FCP_RADIUS_OPT_TOOLTIP),
			getFunc = function() return self.sv.previewEnabled end,
			setFunc = function(value) 
					self.sv.previewEnabled = value
					if addon:CanPreviewCamp() then
						addon.QuickSlotChanged(nil, GetCurrentQuickslot())
					end
				end,
		}
		
	optionsTable[#optionsTable+1] =
		{
			type = "description",
			text = GetString(SI_FCP_UPDATE_DESC),
		}
	optionsTable[#optionsTable+1] =
		{
			type = "slider",
			name = GetString(SI_FCP_UPDATE_OPT),
			tooltip = GetString(SI_FCP_UPDATE_OPT_TOOLTIP),
			min = 0,
			max = 1000,
			getFunc = function() return self.sv.updateRate end,
			setFunc = function(value) 
					self.sv.updateRate = value
					if self.updateActive then
						EVENT_MANAGER:UnregisterForUpdate(addon.name)
						EVENT_MANAGER:RegisterForUpdate(addon.name, addon.sv.updateRate, addon.UpdateCampPreview)
					end
				end,
		}
		
	optionsTable[#optionsTable+1] =
		{
			type = "description",
			text = GetString(SI_FCP_TIMER_DESC),
		}
	optionsTable[#optionsTable+1] = {
			type = "checkbox",
			name = GetString(SI_FCP_TIMER_OPT),
			tooltip = GetString(SI_FCP_TIMER_OPT_TOOLTIP),
			getFunc = function() return self.sv.timerAlwaysVisible end,
			setFunc = function(value) self.sv.timerAlwaysVisible = value; addon:updateCooldownDisplay() end,
		}
		
	LAM2:RegisterOptionControls(addon.name, optionsTable)
	LMP:AddPinType("PreviewForwardCamp", function() end, function() end, pinData, nil)
	
	addon.QuickSlotChanged(nil, GetCurrentQuickslot())
	addon:updateCooldownDisplay()
	EVENT_MANAGER:RegisterForEvent(addon.name, EVENT_ACTIVE_QUICKSLOT_CHANGED, addon.QuickSlotChanged)	
end

EVENT_MANAGER:RegisterForEvent(addon.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)

FORWARD_CAMP_PREVIEW = addon