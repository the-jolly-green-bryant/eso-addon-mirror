if IsNewerEssentialHousingHubVersionAvailable() or not IsEssentialHousingHubRootPathValid() then
	return
end

local EHH = EssentialHousingHub
local UIVisibility = ZO_InitializingObject:Subclass()

function UIVisibility:Initialize()
	self.guiName = "ingame"
	self.changeStateUpdateHandle = "EHH.UIVisibility.OnChangeState"
	self.guiHiddenStateHandle = "EHH.UIVisibility.OnGUIHiddenState"
	self.refreshStateUpdateHandle = "EHH.UIVisibility.OnRefreshState"
	self.screenshotSavedHandle = "EHH.UIVisibility.OnScreenshotSaved"

	self.forceControlsHiddenIntervalMS = 600
	self.forceControlsHiddenMS = 0
	self.hiddenControls = {}
	self.hiddenCustomControls = {}
	self.isHidden = GetGuiHidden(self.guiName)
	self.isStateChanging = false
	self.refreshIntervalMS = 150
	self.useCustomBehavior = false

	self.exemptTopLevelWindows =
	{
		["ZO_Subtitles"] = true,
		["EHHParticle"] = true,
		["EHHCameraWin"] = true,
		["EHHDeathCounterDialog"] = true,
		["EHHGlobalCrossfadeWindow"] = true,
	}
end

function UIVisibility:DeferredInitialize()
	if not EHH.IsEHT then
		EHH:ShadowFunction(_G, "ToggleShowIngameGui", function(...) return self:OnToggleShowIngameGui(...) end)
		EHH:ShadowFunction(CHAT_SYSTEM, "StartTextEntry", function(...) return self:OnStartTextEntry(...) end)

		self:SetCustomUIHidingEnabled(self:IsCustomUIHidingEnabled())
	end
end

function UIVisibility:OnToggleShowIngameGui(origFunc, ...)
	if not self.useCustomBehavior then
		return origFunc(...)
	end

	self:RequestStateToggle()
	return false
end

function UIVisibility:OnStartTextEntry(origFunc, ...)
	if not self.isHidden and not self.isStateChanging then
		return origFunc(...)
	end
end

function UIVisibility:OnGUIHidden(event, guiName, hidden)
	if guiName ~= self.guiName then
		return
	end

	if not hidden and next(EHH.Effect:GetAll()) then
		self:SetCustomUIHidingPromptEnabled(false)
		EHH:SetSetting("CustomUIHidingNotificationLastShown", GetTimeStamp())

		EHH:ShowConfirmationDialog("",
			"To see Essential Effects(TM) when the user interface is hidden, please enable:\n" ..
			"\"|cffffffShow Essential Effects(tm) when UI is hidden|r\"\n" ..
			"in Settings || Addons || Essential Housing Tools\n\n" ..
			"Enable this setting now for you?",
			function()
				self:SetCustomUIHidingEnabled(true)
			end)
	end
end

function UIVisibility:IsCustomUIHidingEnabled()
	return EHH:GetSetting("EnableCustomUIHiding")
end

function UIVisibility:SetCustomUIHidingEnabled(enabled)
	EHH:SetSetting("EnableCustomUIHiding", enabled)
	self.useCustomBehavior = enabled
	if enabled then
		self:SetCustomUIHidingPromptEnabled(false)
	else
		self:SetCustomUIHidingPromptEnabled(true)
	end
end

function UIVisibility:SetCustomUIHidingPromptEnabled(enabled)
	local lastShownDialog = EHH:GetSetting("CustomUIHidingNotificationLastShown")
	if enabled and not EHH:GetSetting("EnableCustomUIHiding") and (nil == lastShownDialog or (GetTimeStamp() - lastShownDialog) > 604800) then -- 1 week
		EVENT_MANAGER:RegisterForEvent(self.guiHiddenStateHandle, EVENT_GUI_HIDDEN, function(...) return self:OnGUIHidden(...) end)
	else
		EVENT_MANAGER:UnregisterForEvent(self.guiHiddenStateHandle, EVENT_GUI_HIDDEN)
	end
end

function UIVisibility:RequestStateToggle()
	if not self.isStateChanging then
		self.isStateChanging = true
		self.isHidden = not self.isHidden

		EVENT_MANAGER:UnregisterForUpdate(self.changeStateUpdateHandle)
		EVENT_MANAGER:UnregisterForUpdate(self.refreshStateUpdateHandle)
		EVENT_MANAGER:RegisterForUpdate(self.changeStateUpdateHandle, self.refreshIntervalMS, function() self:OnChangeState() end)
	end
end

function UIVisibility:OnChangeState()
	EVENT_MANAGER:UnregisterForUpdate(self.changeStateUpdateHandle)
	EVENT_MANAGER:UnregisterForUpdate(self.refreshStateUpdateHandle)

	self.isStateChanging = false
	if self.isHidden then
		self.forceControlsHiddenMS = GetFrameTimeMilliseconds() + self.forceControlsHiddenIntervalMS
		self:HideControls()
		EVENT_MANAGER:RegisterForUpdate(self.refreshStateUpdateHandle, self.refreshIntervalMS, function() self:OnRefreshState() end)
	else
		self:ShowControls()
	end
end

function UIVisibility:ShowControls()
	local sceneName = SCENE_MANAGER:GetCurrentScene().name
	if sceneName ~= "hud" and sceneName ~= "hudui" then
		SCENE_MANAGER:ShowBaseScene()
	end

	for control in pairs(self.hiddenControls) do
		if "userdata" == type(control) and "function" == type(control.IsHidden) then
			control:SetHidden(false)
		end
	end

	self.hiddenControls = {}
	SetGameCameraUIMode(false)
	RETICLE:RequestHidden(false)
end

function UIVisibility:HideControls()
	local currentScene = SCENE_MANAGER:GetCurrentScene()
	if currentScene then
		local sceneName = currentScene.name
		local sceneState = currentScene.state
		if sceneState ~= "shown" or (sceneName ~= "hud" and sceneName ~= "hudui") then
			SCENE_MANAGER:ShowBaseScene()

			if 0 == self.forceControlsHiddenMS then
				self.forceControlsHiddenMS = GetFrameTimeMilliseconds() + self.forceControlsHiddenIntervalMS
				return
			end

			if GetFrameTimeMilliseconds() < self.forceControlsHiddenMS then
				return
			end
		else
			self.forceControlsHiddenMS = 0
		end
	end

	for index = 1, GuiRoot:GetNumChildren() do
		local control = GuiRoot:GetChild(index)
		if "userdata" == type(control) and "function" == type(control.IsHidden) and not control:IsHidden() then
			if "function" == type(control.GetName) then
				local name = control:GetName()
				if not self.exemptTopLevelWindows[name] then
					self.hiddenControls[control] = true
					control:SetHidden(true)
				end
			end
		end
	end
end

function UIVisibility:OnRefreshState()
	if not self.isHidden then
		EVENT_MANAGER:UnregisterForUpdate(self.refreshStateUpdateHandle)
		return
	end

	local currentScene = SCENE_MANAGER:GetCurrentScene()
	if currentScene then
		local sceneName = currentScene.name
		local sceneState = currentScene.state
		if sceneState ~= "shown" or (sceneName ~= "hud" and sceneName ~= "hudui") then
			SCENE_MANAGER:ShowBaseScene()

			if 0 == self.forceControlsHiddenMS then
				self.forceControlsHiddenMS = GetFrameTimeMilliseconds() + self.forceControlsHiddenIntervalMS
				return
			end

			if GetFrameTimeMilliseconds() < self.forceControlsHiddenMS then
				return
			end
		else
			self.forceControlsHiddenMS = 0
		end
	end

	for index = 1, GuiRoot:GetNumChildren() do
		local control = GuiRoot:GetChild(index)
		if "userdata" == type(control) and "function" == type(control.IsHidden) and not control:IsHidden() then
			if "function" == type(control.GetName) then
				local name = control:GetName()
				if not self.exemptTopLevelWindows[name] then
					self.hiddenControls[control] = true
					control:SetHidden(true)
				end
			end
		end
	end
end

EHH.UIVisibility = UIVisibility:New()

EssentialHousingHub.Modules.UserInterfaceVisibility = true