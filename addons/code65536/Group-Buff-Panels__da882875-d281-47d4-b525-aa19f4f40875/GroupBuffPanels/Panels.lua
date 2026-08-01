local LCA = LibCombatAlerts
local GBP = GroupBuffPanels


--------------------------------------------------------------------------------
-- Constants
--------------------------------------------------------------------------------

local POLLING_INTERVAL = 100


--------------------------------------------------------------------------------
-- Core panel logic
--------------------------------------------------------------------------------

local ActivePanels = { }
local InactivePanels = { }
local PlacementPreviewPanes = 0

local function TogglePanel( panel, abilityId, enable )
	local name = "GBP_Panel_" .. abilityId
	local altMode = GBP.ALTMODE[abilityId]
	local ids = GBP.MULTIID[abilityId] or { abilityId }

	if (enable) then
		panel:Enable({
			headerIcon = GBP.GetAbilityIcon(abilityId),
			headerText = LCA.GetAbilityName(abilityId),
			headerHide = GBP.GetPanelSetting("hideHeader", abilityId),
			columns = GBP.GetPanelSetting("columns", abilityId),
			paneWidth = GBP.GetPanelSetting("columnWidth", abilityId),
			scale = GBP.GetPanelSetting("scale", abilityId),
			showRoles = GBP.GetPanelSetting("filter", abilityId),
			strikeDead = GBP.GetPanelSetting("strikeDead", abilityId),
			useRange = GBP.GetPanelSetting("dimDistant", abilityId),
			colorStat = GBP.GetPanelSetting("colorTimer", abilityId),
			pos = GBP.GetPanelPosition(abilityId),
			minimumPaneCount = PlacementPreviewPanes,
			useUnitId = altMode,
			highlightSelf = false,
		})
		panel:SetRepositionCallback(function(pos) GBP.SavePanelPosition(abilityId, pos) end)
		panel:ToggleLock(GBP.GetPanelSetting("lock", abilityId))
		panel:SetPositionSnap(GBP.GetPanelSetting("snap", abilityId) * GBP.GetPanelSetting("scale", abilityId))

		local effects = { }

		local UpdatePanel = function( unitTag, remaining, totalTime )
			if (totalTime == 0) then
				panel:UpdateUnitData(unitTag, nil, GBP.GetColor(abilityId, 1, 1))
			elseif (remaining < 0) then
				panel:UpdateUnitData(unitTag)
			else
				panel:UpdateUnitData(unitTag, nil, GBP.GetColor(abilityId, remaining, totalTime), LCA.FormatTime(remaining, LCA[(totalTime >= 60000) and "TIME_FORMAT_COMPACT" or "TIME_FORMAT_COUNTDOWN"]))
			end
		end

		if (not altMode) then
			-- Standard tracking
			local callback = function( _, changeType, _, _, unitTag, beginTime, endTime )
				if (changeType == EFFECT_RESULT_FADED) then
					effects[unitTag] = nil
					UpdatePanel(unitTag, -1)
				else
					endTime = endTime * 1000
					local totalTime = endTime - beginTime * 1000
					effects[unitTag] = { endTime, totalTime }
					UpdatePanel(unitTag, totalTime, totalTime)
				end
			end
			for i = 1, #ids do
				local name2 = name .. i
				EVENT_MANAGER:RegisterForEvent(name2, EVENT_EFFECT_CHANGED, callback)
				EVENT_MANAGER:AddFilterForEvent(name2, EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, ids[i])
				EVENT_MANAGER:AddFilterForEvent(name2, EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, "group")
			end
		else
			-- Special tracking for effects that don't trigger EVENT_EFFECT_CHANGED
			local callback = function( _, result, _, _, _, _, _, _, _, _, hitValue, _, _, _, _, targetUnitId )
				local unitTag = LCA.IdentifyGroupUnitId(targetUnitId)
				if (unitTag and result == ACTION_RESULT_EFFECT_FADED) then
					effects[unitTag] = nil
					UpdatePanel(unitTag, -1)
				elseif (unitTag and result == ACTION_RESULT_EFFECT_GAINED_DURATION) then
					effects[unitTag] = { GetGameTimeMilliseconds() + hitValue, hitValue }
					UpdatePanel(unitTag, hitValue, hitValue)
				end
			end
			for i = 1, #ids do
				local name2 = name .. i
				EVENT_MANAGER:RegisterForEvent(name2, EVENT_COMBAT_EVENT, callback)
				EVENT_MANAGER:AddFilterForEvent(name2, EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, ids[i])
			end
		end

		EVENT_MANAGER:RegisterForUpdate(name, POLLING_INTERVAL, function( )
			local currentTime = GetGameTimeMilliseconds()
			for unitTag, times in pairs(effects) do
				UpdatePanel(unitTag, times[1] - currentTime, times[2])
			end
		end)
	else
		EVENT_MANAGER:UnregisterForUpdate(name)
		for i = 1, #ids do
			local name2 = name .. i
			if (not altMode) then
				EVENT_MANAGER:UnregisterForEvent(name2, EVENT_EFFECT_CHANGED)
			else
				EVENT_MANAGER:UnregisterForEvent(name2, EVENT_COMBAT_EVENT)
			end
		end
		panel:SetRepositionCallback(nil)
		panel:Disable()
	end
end

function GBP.ActivatePanel( abilityId )
	if (not ActivePanels[abilityId]) then
		-- Acquire panel, reusing an inactive one if available
		local panelId, panel = next(InactivePanels)
		if (panelId) then
			InactivePanels[panelId] = nil
		else
			panel = LCA.GroupPanel:New()
		end
		ActivePanels[abilityId] = panel
		TogglePanel(panel, abilityId, true)
	end
end

function GBP.DeactivatePanel( abilityId )
	local panel = ActivePanels[abilityId]
	if (panel) then
		TogglePanel(panel, abilityId, false)
		ActivePanels[abilityId] = nil
		InactivePanels[panel:GetId()] = panel
	end
end


--------------------------------------------------------------------------------
-- Placement Preview
--------------------------------------------------------------------------------

function GBP.SetPlacementPreview( enabled, smallGroup )
	if (not enabled) then
		PlacementPreviewPanes = 0
	elseif (smallGroup) then
		PlacementPreviewPanes = 4
	else
		PlacementPreviewPanes = 12
	end
	GBP.RefreshEnablementStates()
	for _, panel in pairs(ActivePanels) do
		panel:SetMinimumPaneCount(PlacementPreviewPanes)
	end
end

function GBP.GetPlacementPreview( )
	return PlacementPreviewPanes > 0, PlacementPreviewPanes == 4
end


--------------------------------------------------------------------------------
-- Interface
--------------------------------------------------------------------------------

function GBP.RefreshEnablementStates( )
	if (GBP.GetPlacementPreview()) then
		local enabled = not GBP.IsDisabled()
		for _, abilityId in ipairs(GBP.EFFECTS) do
			if (enabled and GBP.GetPanelEnablement(abilityId, "ANY")) then
				GBP.ActivatePanel(abilityId)
			else
				GBP.DeactivatePanel(abilityId)
			end
		end
	else
		local enabled = IsUnitGrouped("player") and not GBP.IsDisabled()
		local e, p, o = GBP.GetLocationType()
		for _, abilityId in ipairs(GBP.EFFECTS) do
			if (enabled and ((e and GBP.GetPanelEnablement(abilityId, "E")) or (p and GBP.GetPanelEnablement(abilityId, "P")) or (o and GBP.GetPanelEnablement(abilityId, "O"))) and GBP.CheckConditionalEnablement(abilityId)) then
				GBP.ActivatePanel(abilityId)
			else
				GBP.DeactivatePanel(abilityId)
			end
		end
	end
end

function GBP.RefreshLockStates( )
	for abilityId, panel in pairs(ActivePanels) do
		panel:ToggleLock(GBP.GetPanelSetting("lock", abilityId))
	end
end

function GBP.RefreshSnapStates( )
	for abilityId, panel in pairs(ActivePanels) do
		panel:SetPositionSnap(GBP.GetPanelSetting("snap", abilityId) * GBP.GetPanelSetting("scale", abilityId))
	end
end

function GBP.ReloadPanels( abilityId )
	if (abilityId) then
		GBP.DeactivatePanel(abilityId)
	else
		for abilityId in pairs(ActivePanels) do
			GBP.DeactivatePanel(abilityId)
		end
	end
	GBP.RefreshEnablementStates()
end

function GBP.GetActivePanels( )
	return ActivePanels
end
