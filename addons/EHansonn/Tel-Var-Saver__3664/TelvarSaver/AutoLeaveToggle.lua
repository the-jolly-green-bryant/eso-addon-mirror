TelVarSaver = TelVarSaver or {}
local TVS = TelVarSaver

TVS.autoLeaveToggleMoved = false

function TVS.UpdateAutoLeaveTogglePosition()
	local control = TVSAutoLeaveToggle
	if control == nil then return end
	control:ClearAnchors()
	control:SetAnchor(TOPRIGHT, GuiRoot, TOPRIGHT, TVS.SV.AutoLeaveToggleX, TVS.SV.AutoLeaveToggleY)
	control:SetMovable(TVS.SV.AutoLeaveToggleDragable)
end

function TVS.SaveAutoLeaveTogglePosition()
	local control = TVSAutoLeaveToggle
	if control == nil then return end
	TVS.SV.AutoLeaveToggleX = control:GetRight() - GuiRoot:GetRight()
	TVS.SV.AutoLeaveToggleY = control:GetTop() - GuiRoot:GetTop()
end

-- The widget is parented to the gameplay scenes via a HUD scene fragment (the same
-- approach Combat Metrics uses). The engine then shows/hides it with the scene -
-- no per-event work - so it disappears in menus/inventory/map and returns in play.
TVS.AUTO_LEAVE_SCENES = { "hud", "hudui", "siegeBar" }

function TVS.RefreshAutoLeaveToggleVisibility()
	local control = TVSAutoLeaveToggle
	if control == nil or TVS.autoLeaveToggleFragment == nil or SCENE_MANAGER == nil then return end

	local available = (TVS.SV.AutoLeaveToggleShow == true) and (IsInImperialCity() == true)

	if available then
		for _, sceneName in ipairs(TVS.AUTO_LEAVE_SCENES) do
			SCENE_MANAGER:GetScene(sceneName):AddFragment(TVS.autoLeaveToggleFragment)
		end
		-- Match the current scene immediately (AddFragment only acts on transitions).
		local currentScene = SCENE_MANAGER.currentScene and SCENE_MANAGER.currentScene.name or ""
		local shownForScene = false
		for _, sceneName in ipairs(TVS.AUTO_LEAVE_SCENES) do
			if currentScene == sceneName then shownForScene = true end
		end
		control:SetHidden(not shownForScene)
	else
		for _, sceneName in ipairs(TVS.AUTO_LEAVE_SCENES) do
			SCENE_MANAGER:GetScene(sceneName):RemoveFragment(TVS.autoLeaveToggleFragment)
		end
		control:SetHidden(true)
	end
end

function TVS.UpdateAutoLeaveToggleVisual()
	if TVSAutoLeaveToggleStatus == nil then return end
	local cap = tostring(TVS.SV.TelvarCap)
	local carried = GetCarriedCurrencyAmount(CURT_TELVAR_STONES)
	local queueLimit = GetTelVarQueueThreshold()

	if carried > queueLimit then
		TVSAutoLeaveToggleStatus:SetText("|cffff00" .. cap .. "|r")
		TVSAutoLeaveToggleIcon:SetColor(1, 1, 1, 1)
	elseif TVS.SV.AutoQueueOut == true then
		TVSAutoLeaveToggleStatus:SetText("|c00ff00" .. cap .. "|r")
		TVSAutoLeaveToggleIcon:SetColor(1, 1, 1, 1)
	else
		TVSAutoLeaveToggleStatus:SetText("|cff4040" .. cap .. "|r")
		TVSAutoLeaveToggleIcon:SetColor(1, 1, 1, 0.35)
	end

	if TVS.SV.AutoQueueOut == true then
		TVSAutoLeaveToggleBG:SetEdgeColor(0, 1, 0, 1)
	else
		TVSAutoLeaveToggleBG:SetEdgeColor(1, 0.25, 0.25, 1)
	end
end

function TVS.ToggleAutoLeave()
	TVS.SV.AutoQueueOut = not TVS.SV.AutoQueueOut
	TVS.UpdateAutoLeaveToggleVisual()
	if TVS.SV.AutoQueueOut == true then
		TVS.dtvs("Auto leave when Tel Var limit reached: |c00ff00ON|r", "notifyAutoLeave")
	else
		TVS.dtvs("Auto leave when Tel Var limit reached: |cff4040OFF|r", "notifyAutoLeave")
	end
end

function TVS.SetupAutoLeaveToggle()
	if TVS.autoLeaveToggleFragment == nil then
		TVS.autoLeaveToggleFragment = ZO_HUDFadeSceneFragment:New(TVSAutoLeaveToggle)
	end
	TVS.UpdateAutoLeaveTogglePosition()
	TVS.UpdateAutoLeaveToggleVisual()
	TVS.RefreshAutoLeaveToggleVisibility()
end

function TVS.OnAutoLeaveToggleMoveStart() TVS.autoLeaveToggleMoved = true end

function TVS.OnAutoLeaveToggleMoveStop() TVS.SaveAutoLeaveTogglePosition() end

-- Open the addon settings panel (right-click shortcut).
function TVS.OpenSettings()
	if LibAddonMenu2 ~= nil and TVS.settingsPanel ~= nil then LibAddonMenu2:OpenToPanel(TVS.settingsPanel) end
end

-- Left click toggles, right click opens settings - but not at the end of a drag.
function TVS.OnAutoLeaveToggleMouseUp(button, upInside)
	if upInside == false then return end
	if TVS.autoLeaveToggleMoved == true then
		TVS.autoLeaveToggleMoved = false
		return
	end
	if button == MOUSE_BUTTON_INDEX_LEFT then
		TVS.ToggleAutoLeave()
	elseif button == MOUSE_BUTTON_INDEX_RIGHT then
		TVS.OpenSettings()
	end
end

function TVS.OnAutoLeaveToggleEnter()
	InitializeTooltip(InformationTooltip, TVSAutoLeaveToggle, BOTTOM, 0, -5)
	SetTooltipText(InformationTooltip, "TelVarSaver")
	SetTooltipText(InformationTooltip, "Left click to toggle 'Auto leave when Tel Var limit reached'.")
	SetTooltipText(InformationTooltip, "Right click to open settings.")
	SetTooltipText(InformationTooltip, "Unlock drag to move in settings. Lock or hide it in the addon settings.")
end

function TVS.OnAutoLeaveToggleExit() ClearTooltip(InformationTooltip) end
