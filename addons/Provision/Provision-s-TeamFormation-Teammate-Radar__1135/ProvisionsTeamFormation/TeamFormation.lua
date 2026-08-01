function TeamFormation_Keypress()
	TeamFormation_SetHidden(ProvTF.vars.enabled)
	ProvTF.vars.enabled = not ProvTF.vars.enabled

	if ProvTF.vars.enabled then
		d(GetString(SI_TF_ENABLED))
	else
		d(GetString(SI_TF_DISABLED))
	end
end

function TeamFormation_SetHidden(bool)
	ProvTF.UI:SetHidden(GetGroupSize() == 0 or bool)
	CALLBACK_MANAGER:FireCallbacks("TEAMFORMATION_SetHiddenCalled", bool)
end

function TeamFormation_ResetRefreshRate()
	EVENT_MANAGER:UnregisterForEvent(ProvTF.name .. "Update")
	EVENT_MANAGER:RegisterForUpdate(ProvTF.name .. "Update", ProvTF.vars.refreshRate, function() TeamFormation_OnUpdate() end)
end

local function TeamFormation_OnAddOnLoad(eventCode, addOnName)
	if (ProvTF.name ~= addOnName) then return end

	ProvTF.vars = ZO_SavedVars:NewAccountWide("ProvTFSV", 1, nil, ProvTF.defaults)

	SLASH_COMMANDS["/tf"] = function()
		LAM2:OpenToPanel(ProvTF.CPL)
	end

	ProvTF.UI = WINDOW_MANAGER:CreateControl(nil, GuiRoot, CT_TOPLEVELCONTROL)
	ProvTF.UI:SetMouseEnabled(false)
	ProvTF.UI:SetClampedToScreen(true)
	ProvTF.UI:SetDimensions(ProvTF.vars.width, ProvTF.vars.height)
	ProvTF.UI:SetDrawLevel(0)
	ProvTF.UI:SetDrawLayer(0)
	ProvTF.UI:SetDrawTier(0)

	ProvTF.UI:SetHidden(not ProvTF.vars.enabled)
	ProvTF.UI:ClearAnchors()
	ProvTF.UI:SetAnchor(CENTER, GuiRoot, CENTER, ProvTF.vars.posx, ProvTF.vars.posy)

	ProvTF.UI.Cardinal = {}
	for i = 1, 4 do
		ProvTF.UI.Cardinal[i] = WINDOW_MANAGER:CreateControl(nil, ProvTF.UI, CT_LABEL)
		ProvTF.UI.Cardinal[i]:SetAnchor(CENTER, ProvTF.UI, CENTER, 0, 0)
		ProvTF.UI.Cardinal[i]:SetFont("ZoFontHeader4")
		ProvTF.UI.Cardinal[i]:SetDrawLevel(0)
		ProvTF.UI.Cardinal[i]:SetAlpha(ProvTF.vars.cardinal)
	end

	ProvTF.UI.Cardinal[1]:SetText(GetString(SI_COMPASS_NORTH_ABBREVIATION))
	ProvTF.UI.Cardinal[2]:SetText(GetString(SI_COMPASS_EAST_ABBREVIATION))
	ProvTF.UI.Cardinal[3]:SetText(GetString(SI_COMPASS_SOUTH_ABBREVIATION))
	ProvTF.UI.Cardinal[4]:SetText(GetString(SI_COMPASS_WEST_ABBREVIATION))


	ProvTF.UI.Player = {}

	local fragment = ZO_SimpleSceneFragment:New(ProvTF.UI)
	SCENE_MANAGER:GetScene('hud'):AddFragment(fragment)
	SCENE_MANAGER:GetScene('hudui'):AddFragment(fragment)

	EVENT_MANAGER:UnregisterForEvent(ProvTF.name, EVENT_ADD_ON_LOADED)

	TeamFormation_createLAM2Panel()
	EVENT_MANAGER:RegisterForUpdate(ProvTF.name .. "Update", ProvTF.vars.refreshRate, function() TeamFormation_OnUpdate() end)

	EVENT_MANAGER:RegisterForEvent(ProvTF.name, EVENT_BEGIN_SIEGE_CONTROL, function()
		if ProvTF.vars.enabled then
			TeamFormation_SetHidden(not ProvTF.vars.siege)
		end
	end)
end

EVENT_MANAGER:RegisterForEvent(ProvTF.name, EVENT_ADD_ON_LOADED, function(...) TeamFormation_OnAddOnLoad(...) end)