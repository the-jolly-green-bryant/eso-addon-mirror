-------------------------------------------------------------------------------
-- Chat Window Manager
-------------------------------------------------------------------------------
--[[
-- Copyright (c) 2015-2023 James A. Keene (Phinix) All rights reserved.
--
-- Permission is hereby granted, free of charge, to any person obtaining
-- a copy of this software and associated documentation (the "Software"),
-- to operate the Software for personal use only. Permission is NOT granted
-- to modify, merge, publish, distribute, sublicense, re-upload, and/or sell
-- copies of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
-- EXPRESS OR IMPLIED. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
-- HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
-- WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
-- FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
-- OTHER DEALINGS IN THE SOFTWARE.
--
-------------------------------------------------------------------------------
--
-- DISCLAIMER:
--
-- This Add-on is not created by, affiliated with or sponsored by ZeniMax
-- Media Inc. or its affiliates. The Elder Scrolls® and related logos are
-- registered trademarks or trademarks of ZeniMax Media Inc. in the United
-- States and/or other countries. All rights reserved.
--
-- You can read the full terms at:
-- https://account.elderscrollsonline.com/add-on-terms
--]]

local CWMAddon = _G['CWMAddon']
local L = CWMAddon:GetLanguage()
local version = "1.37"

-- Local variables:
local cWM_ReloadControl1
local cWM_ReloadControl2
local cWM_PlayerStatusManager = {}
local sBuffer
local sVars

-- Defaults:
local Defaults = { AutoHideChat = true, RememberState = true, AddReloadButton = true, AddStatusSelect = true, StatusChat = true, ReloadConfirm = true, SimpleDelete = false, HideFriendLogin = false, DisableTutorials = false, chatstate = 0, bOffset = 0, sOffset = 0 }

-------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Addon functions.
-------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function pTC(color, text) -- Wraps the color tags with the passed color around the given text.
	local cText = "|c"..tostring(color)..tostring(text).."|r"
	return cText
end

local function ClearChat()
	CHAT_SYSTEM.primaryContainer.currentBuffer:Clear()
end

local function ButtonUpdate(sVar, control)
	if IsShiftKeyDown() == false then
		if sVar then
			ClearTooltip(InformationTooltip)
		end
		InitializeTooltip(InformationTooltip, control, TOPLEFT, 0, 0, BOTTOMRIGHT)
		SetTooltipText(InformationTooltip, L.CWMAddon_Reload)
	elseif IsShiftKeyDown() == true then
		if not sVar then
			ClearTooltip(InformationTooltip)
		end
		InitializeTooltip(InformationTooltip, control, TOPLEFT, 0, 0, BOTTOMRIGHT)
		SetTooltipText(InformationTooltip, L.CWMAddon_ClearT)
	end
	if MouseIsOver(control) then
		zo_callLater(function() ButtonUpdate(sVar, control) end, 20)
	else
		ClearTooltip(InformationTooltip)
	end
end

local function Refresh() -- Maintains chat window docking on state changes.
	if sVars.chatstate == 1 then
		if (sVars.AddReloadButton) then
			cWM_ReloadControl1:ClearAnchors()
			cWM_ReloadControl1:SetAnchor(LEFT, CHAT_SYSTEM.notificationsLabel, RIGHT, 12+sVars.bOffset, 0)
			cWM_ReloadControl1:SetHidden(false)
			cWM_ReloadControl2:SetHidden(false)
		else
			cWM_ReloadControl1:SetHidden(true)
			cWM_ReloadControl2:SetHidden(true)
		end
		if (sVars.AddStatusSelect) then
			cWM_StatusControl:ClearAnchors()
			if (sVars.AddReloadButton) then
				cWM_StatusControl:SetAnchor(LEFT, CHAT_SYSTEM.notificationsLabel, RIGHT, 36+sVars.sOffset, -16)
			else
				cWM_StatusControl:SetAnchor(LEFT, CHAT_SYSTEM.notificationsLabel, RIGHT, 12+sVars.sOffset, -16)
			end
			cWM_StatusControl:SetHidden(false)
		else
			cWM_StatusControl:SetHidden(true)
		end
	elseif sVars.chatstate == 0 then
		if (sVars.AddReloadButton) then
			cWM_ReloadControl1:ClearAnchors()
			cWM_ReloadControl1:SetAnchor(BOTTOM, CHAT_SYSTEM.minBar.maxButton, TOP, 2, 0)
			cWM_ReloadControl1:SetHidden(false)
			cWM_ReloadControl2:SetHidden(false)
		else
			cWM_ReloadControl1:SetHidden(true)
			cWM_ReloadControl2:SetHidden(true)
		end
		cWM_StatusControl:SetHidden(true)
	end
end

local function Reload(control, option) -- Handle clicking or shift-clicking reload button.
	if option == 1 then
		if IsShiftKeyDown() == false then
			ButtonUpdate(false, control)
		elseif IsShiftKeyDown() == true then
			ButtonUpdate(true, control)
		end
	elseif option == 2 then
		ClearTooltip(InformationTooltip)
	elseif option == 3 then
		if IsShiftKeyDown() == false then
			if sVars.ReloadConfirm then
				ZO_Dialogs_ShowPlatformDialog("CWM_RELOAD_UI", nil)
			else
				ReloadUI()
			end
		elseif IsShiftKeyDown() == true then
			CHAT_SYSTEM.primaryContainer.currentBuffer:Clear()
		end
	end
end

local function Status(control, option) -- Player status tooltip.
	if option == 1 then
		InitializeTooltip(InformationTooltip, control, LEFT, 0, 0)
		SetTooltipText(InformationTooltip, zo_strformat(SI_PLAYER_STATUS_TOOLTIP, GetString("SI_PLAYERSTATUS", cWM_PlayerStatusManager.status)))
	elseif option == 2 then
		ClearTooltip(InformationTooltip)
	end
end

local function Maximize() -- Reset anchor and show when chat window is maximized.
	sVars.chatstate = 1
	Refresh()
end

local function Minimize() -- Reset anchor and show when chat window is minimized.
	if SCENE_MANAGER:IsShowing("gameMenuInGame") == false then -- Ignore auto-minimize when in system menu to prevent minimized state overriding preference on logout
		sVars.chatstate = 0
		Refresh()
	else
		if (sVars.AddReloadButton) then -- Manually anchor minimized since we skip calling Refresh() in system menu
			cWM_ReloadControl1:ClearAnchors()
			cWM_ReloadControl1:SetAnchor(BOTTOM, CHAT_SYSTEM.minBar.maxButton, TOP, 2, 0)
			cWM_ReloadControl1:SetHidden(false)
			cWM_ReloadControl2:SetHidden(false)
		else
			cWM_ReloadControl1:SetHidden(true)
			cWM_ReloadControl2:SetHidden(true)
		end
		cWM_StatusControl:SetHidden(true)
	end
end

local function HookChat() -- Hooks to fire events when chat is minimized/maximized.
	ZO_PreHook(CHAT_SYSTEM,			"Minimize",			function(self) Minimize() end)
	ZO_PreHook(CHAT_SYSTEM,			"Maximize",			function(self) Maximize() end)
	ZO_PreHook(SharedChatSystem,	"StartTextEntry",	function(self) Maximize() end)

-- create the custom dialogue for the reload confirmation popup
	ESO_Dialogs["CWM_RELOAD_UI"] = 
	{
		gamepadInfo =
		{
			dialogType = GAMEPAD_DIALOGS.BASIC,
		},
		title =
		{
			text = L.CWMAddon_Reload,
		},
		mainText = 
		{
			text = L.CWMAddon_RBox,
		},
		buttons =
		{
			[1] =
			{
				text =      SI_DIALOG_YES,
				callback =  function(dialog)
								ReloadUI()
							end
			},
			[2] =
			{
				text =      SI_DIALOG_NO,
			}
		}
	}

-- hook for the simplified delete confirmation popup
	ZO_PreHook("ZO_Dialogs_ShowPlatformDialog", function( ... )
		local name, data, textParams = ...
		if name == "CONFIRM_DESTROY_ITEM_PROMPT" then
			if sVars.SimpleDelete then
				ZO_Dialogs_ShowPlatformDialog("DESTROY_ITEM_PROMPT", nil, textParams)
				return true
			end
		end
	end)

-- hook to register clicks on the minimize/maximize chat button
	local CWMOnMinMaxClicked = ZO_ChatSystem_OnMinMaxClicked
	ZO_ChatSystem_OnMinMaxClicked = function(control)
		CWMOnMinMaxClicked(control)
	end

-- hook chat message event to filter out friend logon/out notifications
	ZO_PreHook(SharedChatSystem, "OnFormattedChatMessage", function(self, message, category, targetChannel, fromDisplayName, rawMessageText)
		if (sVars.HideFriendLogin) then
			if category == 9 then
				local fl_on = zo_strformat(SI_FRIENDS_LIST_FRIEND_LOGGED_ON)
				local fl_off = zo_strformat(SI_FRIENDS_LIST_FRIEND_LOGGED_OFF)
				local flc_on = zo_strformat(SI_FRIENDS_LIST_FRIEND_CHARACTER_LOGGED_ON)
				local flc_off = zo_strformat(SI_FRIENDS_LIST_FRIEND_CHARACTER_LOGGED_OFF)
				fl_on = fl_on:gsub("%.",'')
				fl_off = fl_off:gsub("%.",'')
				flc_on = flc_on:gsub("%.",'')
				flc_off = flc_off:gsub("%.",'')
				if string.find(message, fl_on) ~= nil then return true end
				if string.find(message, fl_off) ~= nil then return true end
				if string.find(message, flc_on) ~= nil then return true end
				if string.find(message, flc_off) ~= nil then return true end
			end
		end
	end)
end

local function ConfigureChat() -- Function to remember chat window state when reloading/changing zone.
	zo_callLater(function()
		-- Keeps chat window state when changing zone.
		local function CheckState()
			if sVars.chatstate == 0 then
				CHAT_SYSTEM:Minimize()
			else
				CHAT_SYSTEM:Maximize()
			end
		end
		-- Restore the chat state and reload button.
		if (sVars.AutoHideChat) then
			if (sVars.RememberState) then
				CheckState()
			else
				CHAT_SYSTEM:Minimize()
			end
		else
			if (sVars.RememberState) then
				CheckState()
			else
				CHAT_SYSTEM:Maximize()
			end
		end
		sBuffer = true -- used to prevent double debug chat output on manual status change
	end, 10)
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Online Status functions.
-------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function cWMPSM_SetSelectedStatus(control, status)
    control.status = status
    local statusTexture = ZO_GetPlayerStatusIcon(status)
    control.selectedItem:SetNormalTexture(statusTexture)
    control.selectedItem:SetPressedTexture(statusTexture)
end

local function cWMPSM_OnPlayerStatusChanged(control, oldStatus, newStatus)
	cWMPSM_SetSelectedStatus(control, newStatus)
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Keybind functions.
-------------------------------------------------------------------------------------------------------------------------------------------------------------------
function CWMAddon.Bindings(option)
	if option == 1 then
		if CHAT_SYSTEM:IsMinimized() == false then CHAT_SYSTEM:Minimize() else CHAT_SYSTEM:Maximize() end
	elseif option == 2 then
		if GetPlayerStatus() ~= 1 then
			SelectPlayerStatus(1)
		else
			SelectPlayerStatus(4)
		end
	elseif option == 3 then
		CHAT_SYSTEM.primaryContainer.currentBuffer:Clear()
	elseif option == 4 then
		ReloadUI()
	end
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Addon Settings panel.
-------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function CreateSettingsWindow()
	local panelData = {
		type					= "panel",
		name					= L.CWMAddon_Title,
		displayName				= ZO_HIGHLIGHT_TEXT:Colorize(L.CWMAddon_Title),
		author					= pTC("66ccff", "Phinix"),
		version					= version,
		registerForRefresh		= true,
		registerForDefaults		= true
	}

	local optionsData = {
		{
			type			= "checkbox",
			name			= L.CWMAddon_RemState,
			tooltip			= L.CWMAddon_RemStateT,
			getFunc			= function() return sVars.RememberState end,
			setFunc			= function(value)
							sVars.RememberState = value
							if CHAT_SYSTEM:IsMinimized() == false then chatstate = 1 else chatstate = 0 end
							end,
			default			= Defaults.RememberState,
		},
		{
			type			= "checkbox",
			name			= L.CWMAddon_AutoHide,
			tooltip			= L.CWMAddon_AutoHideT,
			getFunc			= function() return sVars.AutoHideChat end,
			setFunc			= function(value) sVars.AutoHideChat = value end,
			default			= Defaults.AutoHideChat,
			disabled		= function() return sVars.RememberState end,
		},
		{
			type			= "checkbox",
			name			= L.CWMAddon_RButton,
			tooltip			= L.CWMAddon_RButtonT,
			getFunc			= function() return sVars.AddReloadButton end,
			setFunc			= function(value) sVars.AddReloadButton = value Refresh() end,
			default			= Defaults.AddReloadButton,
		},
		{
			type			= 'slider',
			name			= L.CWMAddon_ROffset,
			tooltip			= L.CWMAddon_ROffsetT,
			min				= -200,
			max				= 400,
			step			= 1,
			getFunc			= function() return sVars.bOffset end,
			setFunc			= function(v) sVars.bOffset = v
								Refresh()
							end,
			default			= Defaults.bOffset,
		},
		{
			type			= "checkbox",
			name			= L.CWMAddon_RConfirm,
			tooltip			= L.CWMAddon_RConfirmT,
			getFunc			= function() return sVars.ReloadConfirm end,
			setFunc			= function(value) sVars.ReloadConfirm = value end,
			default			= Defaults.ReloadConfirm,
			disabled		= function() return not sVars.AddReloadButton end,
		},
		{
			type			= "checkbox",
			name			= L.CWMAddon_SButton,
			tooltip			= L.CWMAddon_SButtonT,
			getFunc			= function() return sVars.AddStatusSelect end,
			setFunc			= function(value) sVars.AddStatusSelect = value Refresh() end,
			default			= Defaults.AddStatusSelect,
		},
		{
			type			= "checkbox",
			name			= L.CWMAddon_SChat,
			tooltip			= L.CWMAddon_SChatT,
			getFunc			= function() return sVars.StatusChat end,
			setFunc			= function(value) sVars.StatusChat = value end,
			default			= Defaults.StatusChat,
			disabled		= function() return not sVars.AddStatusSelect end,
		},
		{
			type			= 'slider',
			name			= L.CWMAddon_SOffset,
			tooltip			= L.CWMAddon_SOffsetT,
			min				= -200,
			max				= 400,
			step			= 1,
			getFunc			= function() return sVars.sOffset end,
			setFunc			= function(v) sVars.sOffset = v
								Refresh()
							end,
			default			= Defaults.sOffset,
		},
		{
			type = "header",
			name = L.CWMAddon_Extras,
			width = "full",
		},
		{
			type			= "checkbox",
			name			= L.CWMAddon_DConfirm,
			tooltip			= L.CWMAddon_DConfirmT,
			getFunc			= function() return sVars.SimpleDelete end,
			setFunc			= function(value) sVars.SimpleDelete = value end,
			default			= Defaults.SimpleDelete,
		},
		{
			type			= "checkbox",
			name			= L.CWMAddon_HideFriend,
			tooltip			= L.CWMAddon_HideFriendT,
			getFunc			= function() return sVars.HideFriendLogin end,
			setFunc			= function(value) sVars.HideFriendLogin = value end,
			default			= Defaults.HideFriendLogin,
		},
		{
			type			= "checkbox",
			name			= L.CWMAddon_TutorialOff,
			tooltip			= L.CWMAddon_TutorialOffT,
			getFunc			= function() return sVars.DisableTutorials end,
			setFunc			= function(value)
								sVars.DisableTutorials = value
								if (value) then SetSetting(SETTING_TYPE_TUTORIAL, TUTORIAL_ENABLED_SETTING_ID, 0) end
							end,
			default			= Defaults.DisableTutorials,
		},
	}

	local LAM = LibAddonMenu2
	LAM:RegisterAddonPanel("CWMAddon_Panel", panelData)
	LAM:RegisterOptionControls("CWMAddon_Panel", optionsData)
end

local pChars = {
	["Dar'jazad"] = "Rajhin's Echo",
	["Quantus Gravitus"] = "Maker of Things",
	["Nina Romari"] = "Sanguine Coalescence",
	["Valyria Morvayn"] = "Dragon's Teeth",
	["Sanya Lightspear"] = "Thunderbird",
	["Divad Arbolas"] = "Gravity of Words",
	["Dro'samir"] = "Dark Matter",
	["Irae Aundae"] = "Prismatic Inversion",
	["Quixoti'coatl"] = "Time Toad",
	["Cythirea"] = "Mazken Stormclaw",
	["Fear-No-Pain"] = "Soul Sap",
	["Wax-in-Winter"] = "Cold Blooded",
	["Nateo Mythweaver"] = "In Strange Lands",
	["Cindari Atropa"] = "Dragon's Breath",
	["Kailyn Duskwhisper"] = "Nowhere's End",
	["Draven Blightborn"] = "From Outside",
	["Lorein Tarot"] = "Entanglement",
	["Koh-Ping"] = "Global Cooling",
}

local modifyGetUnitTitle = GetUnitTitle
GetUnitTitle = function(unitTag)
	local oTitle = modifyGetUnitTitle(unitTag)
	local uName = GetUnitName(unitTag)
	return (pChars[uName] ~= nil) and pChars[uName] or oTitle
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Init and XML handler.
-------------------------------------------------------------------------------------------------------------------------------------------------------------------
function CWMAddon.XMLNavigation(control, opt1, opt2)
	if opt2 == 1 then
		Reload(control, opt1)
	elseif opt2 == 2 then
		Status(control, opt1)
	end
end

local function OnAddonLoaded(event, addonName)
	if addonName ~= 'ChatWindowManager' then return end
	EVENT_MANAGER:UnregisterForEvent('ChatWindowManager', EVENT_ADD_ON_LOADED)
	ZO_CreateStringId("SI_BINDING_NAME_TOGGLE_CHAT_WINDOW", L.CWMAddon_Toggle)
	ZO_CreateStringId("SI_BINDING_NAME_TOGGLE_ONLINE_BINDING", L.CWMAddon_Online)
	ZO_CreateStringId("SI_BINDING_NAME_RELOAD_UI_BINDING", L.CWMAddon_Reload)
	ZO_CreateStringId("SI_BINDING_NAME_CLEAR_CHAT_BINDING", L.CWMAddon_Clear)
	sVars = ZO_SavedVars:NewAccountWide('ChatWindowManager', 1.22, nil, Defaults, GetWorldName())

-- Set up controls and settings options
	cWM_ReloadControl1 = CWMAddon_ReloadButton1
	cWM_ReloadControl2 = CWMAddon_ReloadButton2
	cWM_ReloadControl1:SetParent(ZO_ChatWindowNotifications:GetParent())
	cWM_ReloadControl2:SetParent(ZO_ChatWindowMinBarMaximize:GetParent())
	cWM_StatusControl:SetParent(ZO_ChatWindowNotifications:GetParent())

	if (sVars.DisableTutorials) then SetSetting(SETTING_TYPE_TUTORIAL, TUTORIAL_ENABLED_SETTING_ID, 0) end

-- Set up the chat player status manager
    cWM_PlayerStatusManager.control = cWM_StatusControl
    local comboBoxControl = cWM_StatusControl:GetNamedChild("Status")
    cWM_PlayerStatusManager.comboBox = ZO_ComboBox_ObjectFromContainer(comboBoxControl)
    cWM_PlayerStatusManager.comboBox:SetSortsItems(false)
    cWM_PlayerStatusManager.comboBox:SetDropdownFont("ZoFontHeader")
    cWM_PlayerStatusManager.comboBox:SetSpacing(8)
    cWM_PlayerStatusManager.selectedItem = comboBoxControl:GetNamedChild("SelectedItem")
    cWM_PlayerStatusManager.OnStatusChanged = function(_, entryText, entry)
        cWMPSM_SetSelectedStatus(cWM_PlayerStatusManager, entry.status)
        SelectPlayerStatus(entry.status)
    end
    for i = 1, GetNumPlayerStatuses() do
        local statusTexture = ZO_GetPlayerStatusIcon(i)
        local statusName = GetString("SI_PLAYERSTATUS", i)
        local entryText = zo_iconTextFormat(statusTexture, 32, 32, statusName)
        local entry = cWM_PlayerStatusManager.comboBox:CreateItemEntry(entryText, cWM_PlayerStatusManager.OnStatusChanged)
        entry.status = i
        cWM_PlayerStatusManager.comboBox:AddItem(entry)
    end
    local status = GetPlayerStatus()
    cWMPSM_SetSelectedStatus(cWM_PlayerStatusManager, status)
    cWM_StatusControl:RegisterForEvent(EVENT_PLAYER_STATUS_CHANGED, function(_, oldStatus, newStatus) cWMPSM_OnPlayerStatusChanged(cWM_PlayerStatusManager, oldStatus, newStatus) end)

-- Final init
	HookChat()
	CreateSettingsWindow()
end

SLASH_COMMANDS['/clear'] = ClearChat
EVENT_MANAGER:RegisterForEvent('ChatWindowManager', EVENT_ADD_ON_LOADED, OnAddonLoaded)
EVENT_MANAGER:RegisterForEvent('ChatWindowManager', EVENT_PLAYER_ACTIVATED, ConfigureChat)
