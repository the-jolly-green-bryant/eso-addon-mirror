DrakesRush = DrakesRush or {}
local DR = DrakesRush

DR.Name = "DrakesRush"
DR.Version = "1.2"

DR.PANEL = ZO_SimpleSceneFragment:New(DrakesRushPanel)
DR.PanelShown = false

DR.SET = "|H1:item:170584:364:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:10000:0|h|h"
DR.BUFFID = 61709
DR.BASHID = 21970

DR.Cooldown = 0

DR.SetNum = {
	[0] = 0,
	[1] = 0,
}

function DR.PrintCooldown()
	
	local color = "|cFFFFFF"
	if DR.Cooldown == 0 then
		color = "|cFF0000"
	elseif DR.Cooldown > 6 then
		color = "|cFFFF00"
	end
	
	DrakesRushPanelTime:SetText(string.format("%s%d|r", color, DR.Cooldown))
end

function DR.UpdateCooldown()

	if DR.Cooldown > 0 then
		DR.Cooldown = DR.Cooldown - 1
		DR.PrintCooldown()
		return
	end
	
	DR.Cooldown = 0
	DR.PrintCooldown()
	EVENT_MANAGER:UnregisterForUpdate(DR.Name .. "Timer")
end

function DR.UpdateRange()
	
	local inRange = 0
	
	local _, x1, y1, z1 = GetUnitWorldPosition("player")
	for i = 1, GetGroupSize() do
		local target = GetGroupUnitTagByIndex(i)
		if AreUnitsEqual("player", target) == false and IsUnitInGroupSupportRange(target) == true then
			local _, x2, y2, z2 = GetUnitWorldPosition(target)
			local distance = zo_sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2 + (z2 - z1) ^ 2) / 100
			if distance < 15 then
				inRange = inRange + 1
				if inRange >= 3 then
					break
				end
			end
		end
	end
	
	if inRange < 3 then
		DrakesRushPanelOuterBorder:SetEdgeColor(1, 0, 0)
		DrakesRushPanelInnerBorder:SetColor(1, 0, 0)
	else
		DrakesRushPanelOuterBorder:SetEdgeColor(0, 1, 0)
		DrakesRushPanelInnerBorder:SetColor(0, 1, 0)
	end
end

function DR.OnBash(_, result, _, abilityName, _, _, _, _, targetName, _, _, _, _, _, _, _, abilityId, _)

	if DR.Cooldown > 0 then return end
	
	for i = 0, GetNumBuffs("player") do
		local buffName, _, _, _, _, _, _, _, _, _, abilityId = GetUnitBuffInfo("player", i)
		if abilityId == DR.BUFFID then
			DR.Cooldown = 18
			DR.PrintCooldown()
			EVENT_MANAGER:RegisterForUpdate(DR.Name .. "Timer", 1000, DR.UpdateCooldown)
		end
	end
end

function DR.DoesWearSet()
	return (DR.SetNum[0] >= 5 or DR.SetNum[1] >= 5)
end

function DR.OnSetChange()
	local hotbar = GetActiveHotbarCategory()
	local _, _, _, numEquipped = GetItemLinkSetInfo(DR.SET, true)
	DR.SetNum[hotbar] = numEquipped
	DR.ShowPanel(DR.DoesWearSet())
end

function DR.ResetPanelPosition()
	local trackerLeft = DR.SavedVariables.trackerLeft
	local trackerTop = DR.SavedVariables.trackerTop
	if trackerLeft > -1 and trackerTop > -1 then
		DrakesRushPanel:ClearAnchors()
		DrakesRushPanel:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, trackerLeft, trackerTop)
	end
	if DR.SavedVariables.lockui == true then
		DrakesRushPanel:SetMovable(false)
	end	
end

function DR.ShowPanel(show)
	
	if DR.PanelShown == show then return end
	DR.PanelShown = show
	
	if show == true then
		HUD_SCENE:AddFragment(DR.PANEL)
		HUD_UI_SCENE:AddFragment(DR.PANEL)
		EVENT_MANAGER:RegisterForUpdate(DR.Name .. "Range", 200, DR.UpdateRange)
	else
		EVENT_MANAGER:UnregisterForUpdate(DR.Name .. "Range")
		HUD_SCENE:RemoveFragment(DR.PANEL)
		HUD_UI_SCENE:RemoveFragment(DR.PANEL)
	end
end

function DR.InitSavedVariables()
	local defaults = {
		lockui = false,
		trackerLeft = -1,
		trackerTop = -1,
	}
	DR.SavedVariables = ZO_SavedVars:NewAccountWide("DrakesRushSV", 1, nil, defaults)
end

function DR.OnAddOnLoaded(_, addonName)
	if addonName ~= DR.Name then return end
	
	DR.InitSavedVariables()
	DR.ResetPanelPosition()
	DR.OnSetChange()
	
	EVENT_MANAGER:RegisterForEvent(DR.Name, EVENT_COMBAT_EVENT, DR.OnBash)
	EVENT_MANAGER:AddFilterForEvent(DR.Name, EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, DR.BASHID)
	
	EVENT_MANAGER:RegisterForEvent(DR.Name, EVENT_ACTION_SLOTS_FULL_UPDATE, DR.OnSetChange)
	
	EVENT_MANAGER:RegisterForEvent(DR.Name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, DR.OnSetChange)
	EVENT_MANAGER:AddFilterForEvent(DR.Name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, BAG_WORN)
	EVENT_MANAGER:AddFilterForEvent(DR.Name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_INVENTORY_UPDATE_REASON, INVENTORY_UPDATE_REASON_DEFAULT)
end

EVENT_MANAGER:RegisterForEvent(DR.Name, EVENT_ADD_ON_LOADED, DR.OnAddOnLoaded)