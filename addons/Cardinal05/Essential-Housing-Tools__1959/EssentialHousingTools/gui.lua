if not EHT then EHT = {} end

local GUI = ZO_InitializingObject:Subclass()

function GUI:Initialize()
	self.guiName = "ingame"
	self.changeStateUpdateHandle = "EHT.GUI.OnChangeState"
	self.guiHiddenStateHandle = "EHT.GUI.OnGUIHiddenState"
	self.refreshStateUpdateHandle = "EHT.GUI.OnRefreshState"
	self.screenshotSavedHandle = "EHT.GUI.OnScreenshotSaved"

	self.forceControlsHiddenIntervalMS = 600
	self.forceControlsHiddenMS = 0
	self.hiddenControls = {}
	self.hiddenCustomControls = {}
	self.isHidden = GetGuiHidden(self.guiName)
	self.isStateChanging = false
	self.refreshIntervalMS = 150
	self.useCustomBehavior = false ~= EHT.SavedVars.EnableCustomUIHiding

	self.exemptTopLevelWindows =
	{
		["ZO_Subtitles"] = true,
		["EHTParticle"] = true,
		["EHTCameraWin"] = true,
		["EHTDeathCounterDialog"] = true,
		["EHTGlobalCrossfadeWindow"] = true,
		["RA_Icon"] = true,	-- Research Assistant
	}

	EHT.Util.ShadowFunction(_G, "ToggleShowIngameGui", function(...) return self:OnToggleShowIngameGui(...) end)
	EHT.Util.ShadowFunction(CHAT_SYSTEM, "StartTextEntry", function(...) return self:OnStartTextEntry(...) end)

	-- Deprecated support for Photographer add-on as this is no longer required after refactoring the GUI class.
	--EVENT_MANAGER:RegisterForEvent(self.screenshotSavedHandle, EVENT_SCREENSHOT_SAVED, function(...) return self:OnScreenshotSaved(...) end)
end

function GUI:OnToggleShowIngameGui(origFunc, ...)
	if not self.useCustomBehavior then
		return origFunc(...)
	end

	self:RequestStateToggle()
	return false
end

function GUI:OnStartTextEntry(origFunc, ...)
	if not self.isStateChanging and not self.isHidden then
		return origFunc(...)
	end
end
-- Deprecated "Photographer" add-on support
--[[
function GUI:OnScreenshotSaved()
	if self.isHidden and Photographer_OnInitialized then
		self.isStateChanging = false
		zo_callLater(function()
			if self.isHidden and not self.isStateChanging then
				ToggleShowIngameGui()
			end
		end, 250)
	end
end
]]
function GUI:OnGUIHidden(event, guiName, hidden)
	if guiName ~= self.guiName then
		return
	end

	if not hidden and next(EHT.Effect:GetAll()) then
		self:SetCustomUIHidingPromptEnabled(false)
		EHT.SetSetting("CustomUIHidingNotificationLastShown", GetTimeStamp())

		EHT.UI.ShowConfirmationDialog("",
			"To see Essential Effects(TM) when the user interface is hidden, please enable:\n" ..
			"\"|cffffffShow Essential Effects(tm) when UI is hidden|r\"\n" ..
			"in Settings || Addons || Essential Housing Tools\n\n" ..
			"Enable this setting now for you?",
			function()
				self:SetCustomUIHidingEnabled(true)
			end)
	end
end

function GUI:SetCustomUIHidingEnabled(enabled)
	EHT.SetSetting("EnableCustomUIHiding", false ~= enabled)
	self.useCustomBehavior = enabled

	if self.useCustomBehavior then
		self:SetCustomUIHidingPromptEnabled(false)
	else
		self:SetCustomUIHidingPromptEnabled(true)
	end
end

function GUI:SetCustomUIHidingPromptEnabled(enabled)
	local lastShownDialog = EHT.GetSetting("CustomUIHidingNotificationLastShown")
	if enabled and not EHT.GetSetting("EnableCustomUIHiding") and (nil == lastShownDialog or (GetTimeStamp() - lastShownDialog) > 604800) then -- 1 week
		EVENT_MANAGER:RegisterForEvent(self.guiHiddenStateHandle, EVENT_GUI_HIDDEN, function(...) return self:OnGUIHidden(...) end)
	else
		EVENT_MANAGER:UnregisterForEvent(self.guiHiddenStateHandle, EVENT_GUI_HIDDEN)
	end
end

function GUI:RequestStateToggle()
	if not self.isStateChanging then
		self.isStateChanging = true
		self.isHidden = not self.isHidden

		EVENT_MANAGER:UnregisterForUpdate(self.changeStateUpdateHandle)
		EVENT_MANAGER:UnregisterForUpdate(self.refreshStateUpdateHandle)
		EVENT_MANAGER:RegisterForUpdate(self.changeStateUpdateHandle, self.refreshIntervalMS, function() self:OnChangeState() end)
	end
end

function GUI:OnChangeState()
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

function GUI:ShowControls()
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

function GUI:HideControls()
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

function GUI:OnRefreshState()
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

EHT.GUI = GUI:New()

EHT.Modules = (EHT.Modules or {}) EHT.Modules.GUI = true