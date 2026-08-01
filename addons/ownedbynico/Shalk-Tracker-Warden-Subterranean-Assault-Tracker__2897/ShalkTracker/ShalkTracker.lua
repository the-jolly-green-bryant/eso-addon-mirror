Shalk = Shalk or {}
Shalk.Name = "ShalkTracker"
Shalk.Version = "1.0"

Shalk.Panel = ZO_SimpleSceneFragment:New(ShalkTrackerPanel)

Shalk.SubterraneanAssault = 86019
Shalk.DeepFissure = 86015
Shalk.Scorch = 86015

Shalk.Spells = {
	[86009] = {
		["Icon"] = "/esoui/art/icons/ability_warden_015.dds",
		["Cooldown"] = 3,
	},
	[86015] = {
		["Icon"] = "/esoui/art/icons/ability_warden_015_a.dds",
		["Cooldown"] = 3,
	},
	[86019] = {
		["Icon"] = "/esoui/art/icons/ability_warden_015_b.dds",
		["Cooldown"] = 6,
	},
}

Shalk.Countdown = 0

function Shalk.UpdatePanel()
	ShalkTrackerPanelLabel:SetText(tostring(Shalk.Countdown))
	Shalk.Countdown = Shalk.Countdown - 1
	if Shalk.Countdown < 0 then
		EVENT_MANAGER:UnregisterForUpdate("ShalkTrackerLoop")
	end
end

function Shalk.OnEffectChanged(_, changeType, _, effectName, unitTag, beginTime, endTime, _, _, _, _, _, _, _, unitId, abilityId, sourceType)
	
	if changeType == 2 then return end
	
	if Shalk.Spells[abilityId] ~= nil then
		EVENT_MANAGER:UnregisterForUpdate("ShalkTrackerLoop")
		Shalk.Countdown = Shalk.Spells[abilityId].Cooldown
		Shalk.UpdatePanel()
		EVENT_MANAGER:RegisterForUpdate("ShalkTrackerLoop", 1000, Shalk.UpdatePanel)
	end
end

function Shalk.OnHotbarChange(_, _, _, hotbar)
	ShalkTrackerPanelIcon:SetTexture(Shalk.LastIcon.Icon)
	for i = 1, 5 do
		local actionId = GetSlotBoundId(i, hotbar)
		if Shalk.Spells[actionId] ~= nil and Shalk.Spells[actionId].Icon ~= Shalk.LastIcon.Icon then
			Shalk.LastIcon.Icon = Shalk.Spells[actionId].Icon
			ShalkTrackerPanelIcon:SetTexture(Shalk.Spells[actionId].Icon)
			EVENT_MANAGER:UnregisterForEvent(Shalk.Name, EVENT_ACTION_SLOTS_ACTIVE_HOTBAR_UPDATED)
		end
	end
end

function Shalk.ResetPanelPosition()
	local panelLeft = Shalk.SavedVariables.Panel.Left
	local panelTop = Shalk.SavedVariables.Panel.Top
	if panelTop > -1 and panelLeft > -1 then
		ShalkTrackerPanel:ClearAnchors()
		ShalkTrackerPanel:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, panelLeft, panelTop)
	end
	--if Shalk.savedVariables.lockui == true then
	--	ShalkTrackerPanel:SetMovable(false)
	--end	
end

function Shalk.InitSavedVariables()
	local defaults = {
		Panel = {
			["Top"] = -1,
			["Left"] = -1,
		},
	}
	local lastIcon = {
		["Icon"] = "/esoui/art/icons/ability_warden_015.dds",
	}
	Shalk.SavedVariables = ZO_SavedVars:NewAccountWide("ShalkTrackerSV", 1, nil, defaults)
	Shalk.LastIcon = ZO_SavedVars:NewCharacterNameSettings("ShalkTrackerSV", 1, nil, lastIcon)
end

function Shalk.OnAddOnLoaded(_, addonName)
	if addonName ~= Shalk.Name then return end
	
	if GetUnitClassId("player") ~= 4 then
		EVENT_MANAGER:UnregisterForEvent(Shalk.Name, EVENT_ADD_ON_LOADED)
		return
	end
	
	Shalk.InitSavedVariables()
	Shalk.ResetPanelPosition()
	
	Shalk.OnHotbarChange(_, _, _, GetActiveHotbarCategory())
	
	HUD_SCENE:AddFragment(Shalk.Panel)
	HUD_UI_SCENE:AddFragment(Shalk.Panel)
	ShalkTrackerPanel:SetHidden(false)
	
	EVENT_MANAGER:RegisterForEvent(Shalk.Name, EVENT_ACTION_SLOTS_ACTIVE_HOTBAR_UPDATED, Shalk.OnHotbarChange)
	EVENT_MANAGER:RegisterForEvent(Shalk.Name, EVENT_EFFECT_CHANGED, Shalk.OnEffectChanged)
	EVENT_MANAGER:AddFilterForEvent(Shalk.Name, EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG, "player")
end

EVENT_MANAGER:RegisterForEvent(Shalk.Name, EVENT_ADD_ON_LOADED, Shalk.OnAddOnLoaded)