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

		local effectEnds = { }
		local effectTotals = { }
		local effectIds = { }

		local UpdatePanel = function( unitTagOrId, remaining, totalTime )
			local unitTag = not altMode and unitTagOrId or nil
			local unitId = altMode and unitTagOrId or nil
			if (totalTime == 0) then
				panel:UpdateUnitData(unitTag, unitId, GBP.GetColor(abilityId, 1, 1))
			elseif (remaining < 0) then
				panel:UpdateUnitData(unitTag, unitId)
			else
				panel:UpdateUnitData(unitTag, unitId, GBP.GetColor(abilityId, remaining, totalTime), LCA.FormatTime(remaining, LCA[(totalTime >= 60000) and "TIME_FORMAT_COMPACT" or "TIME_FORMAT_COUNTDOWN"]))
			end
		end

		if (not altMode) then
			-- Standard tracking
			local callback = function( _, changeType, _, _, unitTag, beginTime, endTime, _, _, _, _, _, _, _, _, abilityId )
				if (changeType == EFFECT_RESULT_FADED) then
					if (effectIds[unitTag] == abilityId) then
						effectEnds[unitTag] = nil
						effectIds[unitTag] = nil
						UpdatePanel(unitTag, -1)
					end
				else
					endTime = endTime * 1000
					local totalTime = endTime - beginTime * 1000
					effectEnds[unitTag] = endTime
					effectTotals[unitTag] = totalTime
					effectIds[unitTag] = abilityId
					UpdatePanel(unitTag, totalTime, totalTime)
				end
			end
			for i = 1, #ids do
				LCA.RegisterForFilteredEvent(name .. i, EVENT_EFFECT_CHANGED, callback, REGISTER_FILTER_ABILITY_ID, ids[i], REGISTER_FILTER_UNIT_TAG_PREFIX, "group")
			end
		else
			-- Alternate tracking for effects that don't trigger EVENT_EFFECT_CHANGED
			local callback = function( _, result, _, _, _, _, _, _, _, _, hitValue, _, _, _, _, targetUnitId, abilityId )
				if (result == ACTION_RESULT_EFFECT_FADED and effectIds[targetUnitId] == abilityId) then
					effectEnds[targetUnitId] = nil
					effectIds[targetUnitId] = nil
					UpdatePanel(targetUnitId, -1)
				elseif (result == ACTION_RESULT_EFFECT_GAINED_DURATION) then
					effectEnds[targetUnitId] = GetGameTimeMilliseconds() + hitValue
					effectTotals[targetUnitId] = hitValue
					effectIds[targetUnitId] = abilityId
					UpdatePanel(targetUnitId, hitValue, hitValue)
				elseif (result == ACTION_RESULT_EFFECT_GAINED and hitValue == 1 and effectIds[targetUnitId] == abilityId) then
					-- If an effect is refreshed before expiration
					effectEnds[targetUnitId] = GetGameTimeMilliseconds() + effectTotals[targetUnitId]
				end
			end
			for i = 1, #ids do
				LCA.RegisterForFilteredEvent(name .. i, EVENT_COMBAT_EVENT, callback, REGISTER_FILTER_ABILITY_ID, ids[i])
			end
		end

		EVENT_MANAGER:RegisterForUpdate(name, POLLING_INTERVAL, function( )
			local currentTime = GetGameTimeMilliseconds()
			for unitTagOrId, endTime in pairs(effectEnds) do
				UpdatePanel(unitTagOrId, endTime - currentTime, effectTotals[unitTagOrId])
			end
		end)
	else
		EVENT_MANAGER:UnregisterForUpdate(name)
		for i = 1, #ids do
			EVENT_MANAGER:UnregisterForEvent(name .. i, not altMode and EVENT_EFFECT_CHANGED or EVENT_COMBAT_EVENT)
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
