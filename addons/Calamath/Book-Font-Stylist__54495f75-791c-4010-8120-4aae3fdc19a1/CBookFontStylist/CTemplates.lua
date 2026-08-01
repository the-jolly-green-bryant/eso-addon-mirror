--
-- Calamath's BookFont Stylist [CBFS]
--
-- Copyright (c) 2020 Calamath
--
-- This software is released under the Artistic License 2.0
-- https://opensource.org/licenses/Artistic-2.0
--

if not CBookFontStylist then return end
local CBFS = CBookFontStylist:SetSharedEnvironment()
-- ---------------------------------------------------------------------------------------
local L = GetString
local LHAS = LibHarvensAddonSettings


-- ---------------------------------------------------------------------------------------
-- Add-on SettingPanel Controller Base Class                                     rel.2.0.1
-- ---------------------------------------------------------------------------------------
CT_AddonSettingPanelController = ZO_InitializingObject:Subclass()
function CT_AddonSettingPanelController:Initialize(panelId, panelData, optionsData)
	if type(panelId) ~= "string" or panelId == "" then return end
	self.panelId = panelId
	self.panelInitialized = false
	self.panelOpened = false
	if panelData and optionsData then
		self:InitializeSettingPanel(panelData, optionsData)
	end
end
function CT_AddonSettingPanelController:InitializeSettingPanel(panelData, optionsData)
--  Should be overridden
end
function CT_AddonSettingPanelController:CreateSettingPanel(panelData, optionsData)
--  Should be overridden
end
function CT_AddonSettingPanelController:GetPanelId()
	return self.panelId
end
function CT_AddonSettingPanelController:IsPanelInitialized()
	return self.panelInitialized
end
function CT_AddonSettingPanelController:IsPanelShown()
	return self.panelOpened
end
function CT_AddonSettingPanelController:GetSettingPanel()
	return self.panel
end
function CT_AddonSettingPanelController:OpenSettingPanel()
--  Should be overridden
end
function CT_AddonSettingPanelController:OnPanelControlsCreated(panel)
--  Should be overridden if needed
end
function CT_AddonSettingPanelController:OnPanelOpened(panel)
--  Should be overridden if needed
end
function CT_AddonSettingPanelController:OnPanelClosed(panel)
--  Should be overridden if needed
end


-- ---------------------------------------------------------------------------------------
-- LibHarvensAddonSettings SettingPanel Controller Template Class               rel.1.0.12
-- ---------------------------------------------------------------------------------------
-- This class provides the framework for controlling the LHAS panel in Console UI / XBPA.
--
CT_LHASSettingPanelController = CT_AddonSettingPanelController:Subclass()
function CT_LHASSettingPanelController:Initialize(panelId, panelData, optionsData)
	if not (IsConsoleUI() or IsGameCoreUI()) then return end
	CT_AddonSettingPanelController.Initialize(self, panelId, panelData, optionsData)
	if MAIN_MENU_GAMEPAD_SCENE then
		SCENE_MANAGER:CallWhen(MAIN_MENU_GAMEPAD_SCENE:GetName(), SCENE_SHOWN, function()
			self:PerformDeferredInitialization()
		end)
	end
end
function CT_LHASSettingPanelController:PerformDeferredInitialization()
	local lhasScene = LibHarvensAddonSettings.scene
	if lhasScene then
		CALLBACK_MANAGER:RegisterCallback("LibHarvensAddonSettings_AddonSelected", function(panelId)
			self.selectedPanelId = panelId
		end)
		lhasScene:RegisterCallback("StateChange", function(_, newState)
			if newState == SCENE_SHOWN then
				if self.selectedPanelId == self.panelId then
					if not self.panelOpened then
						self.panelOpened = true
						self:OnPanelOpened(self.panel)
					end
				end
			elseif newState == SCENE_HIDDEN then
				if self.selectedPanelId == self.panelId then
					if self.panelOpened then
						self.panelOpened = false
						self:OnPanelClosed(self.panel)
					end
				end
			end
		end)
	end
end
function CT_LHASSettingPanelController:InitializeSettingPanel(panelData, optionsData)
	if not self.panel then
		local panel = self:CreateSettingPanel(panelData, optionsData)
		self.panel = panel
		self:OnPanelControlsCreated(panel)
		self.panelInitialized = true
	end
end
function CT_LHASSettingPanelController:CreateSettingPanel(panelData, optionsData)
	local panel = LHAS:AddAddon(self.panelId, panelData)
	if panel then
		panel.name = self.panelId
		panel.author = panelData.author
		panel.version = panelData.version
		panel.website = panelData.website
		panel:AddSettings(optionsData)
	end
	return panel
end
do
	local function OpenLHASSettingPanel(panelId)
		MAIN_MENU_GAMEPAD:SelectMenuEntryAndSubEntry("LibHarvensAddonSettings", 1)
		local addonList = MAIN_MENU_GAMEPAD.subList
		local addonIndex = 1
		local activatedCallback
		for i = 1, addonList:GetNumEntries() do
			local entryData = addonList:GetEntryData(i).data
			if entryData then
				if entryData.name == panelId then
					addonIndex = i
					activatedCallback = entryData.activatedCallback
					break
				end
			end
		end
		addonList:SetSelectedIndexWithoutAnimation(addonIndex)
		if type(activatedCallback) == "function" then
			activatedCallback()
		end
	end
	function CT_LHASSettingPanelController:OpenSettingPanel()
		if not (IsConsoleUI() or IsGameCoreUI()) then return end
		local lhasScene = LibHarvensAddonSettings.scene
		if not lhasScene then
			zo_callLater(function() OpenLHASSettingPanel(self.panelId) end, 0)
			SCENE_MANAGER:Show(MAIN_MENU_GAMEPAD_SCENE:GetName())
		else
			OpenLHASSettingPanel(self.panelId)
		end
	end
end
-- A temporary helper function for displaying dialogs from the current LHAS panel.
-- Provides functionality to go back to the current LHAS panel when pressing the dialog's 'back' keybind button.
function CT_LHASSettingPanelController:PushConsoleDialog(dialog)
	if dialog and self.panel and self.panel.selected then
		self.panel.lastSelectedRow = LHAS.list:GetSelectedData()
		SCENE_MANAGER:CallWhen(LHAS.scene:GetName(), SCENE_HIDDEN, function() self:OpenSettingPanel() end)
		if dialog.Show then
			dialog:Show()
		end
	end
end
