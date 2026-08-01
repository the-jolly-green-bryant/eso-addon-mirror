local addonName = "NedsGroupManager"
local selectedDisplayNames = {}
local settings = {
	channels = {},
	message = "",
}	
 

local function CreateDataEntry(displayName, index)
    return { displayName = displayName, index=index}
end

local settings
local function InitSettings()
	settings = ZO_SavedVars:NewAccountWide("NPGMSaved", 1, nil, {
		message = "x",
		autoInviteEnabled = false,
		channels = {
			[CHAT_CHANNEL_GUILD_1] = false,
			[CHAT_CHANNEL_GUILD_2] = false,
			[CHAT_CHANNEL_GUILD_3] = false,
			[CHAT_CHANNEL_GUILD_4] = false,
			[CHAT_CHANNEL_GUILD_5] = false,
			[CHAT_CHANNEL_WHISPER] = false,
			[CHAT_CHANNEL_ZONE] = false,
			[CHAT_CHANNEL_SAY] = false,
		},
	})
end	

local LAMPanel

local function InitLAM()
	local panelData = {
		type = "panel",
		name = "NGM",
		author = "Ned919x & STUDLETON",
		registerForRefresh = true,
	}
	local optionData = {
		{
            type = "divider",
            height = 15,
            alpha = 0,
        },
        {
            type = "header",
            name = "Auto Invite Settings",
        },
		{
			type = "editbox",
			name = "Invite Message",
			tooltip = "Will send an invite to anyone who types this message",
			getFunc = function() return settings.message end,
			setFunc = function(value) settings.message = value end,
		},	
        {
            type = "description",
            text = "Select Channels To Invite From",
        },
	}

	
	local function generateChatEntry(name, chatId)
		return {
			type = "checkbox",
            name = name,
            getFunc = function() return settings.channels[chatId] end,
            setFunc = function(value) settings.channels[chatId] = value end,
            tooltip = name,
		}
	end
	
	table.insert(optionData, generateChatEntry("Whisper", CHAT_CHANNEL_WHISPER))
	for i = 1, 5 do
		local name = GetGuildName(GetGuildId(i))
		if name ~= "" then 
			table.insert(optionData, generateChatEntry(name, 11+i))
		end	
	end
	table.insert(optionData, generateChatEntry("Zone", CHAT_CHANNEL_ZONE))
	table.insert(optionData, generateChatEntry("Say", CHAT_CHANNEL_SAY))
	LAMPanel = LibAddonMenu2:RegisterAddonPanel(addonName, panelData)
	LibAddonMenu2:RegisterOptionControls(addonName, optionData)
end	

local function SetupRow(control, data)
    local label = control:GetNamedChild("Label")
	local CheckBox = control:GetNamedChild("CheckBox")
	local Number = control:GetNamedChild("Number")
    label:SetText(data.displayName)
	Number:SetText(data.index)
    control.data = data
	
	if selectedDisplayNames[data.displayName] then									
		ZO_CheckButton_SetChecked(CheckBox)
	else
		ZO_CheckButton_SetUnchecked(CheckBox)
	end

    ZO_CheckButton_SetToggleFunction(CheckBox, function(buttoncontrol,checked)
		if checked then
			selectedDisplayNames[data.displayName] = true
		else
			selectedDisplayNames[data.displayName] = false
		end	
    end)
end

local dialogAutoInviteCheckBox
local dialogAutoInviteSettingsCheckBoxes = {}

local function NPGMUI_Init()
    local scrollList = NPGM_UIScrollList
    if not scrollList then return end

    ZO_ScrollList_Clear(scrollList)
    local scrollData = ZO_ScrollList_GetDataList(scrollList)

    if not scrollList.dataTypes or not scrollList.dataTypes[1] then
        ZO_ScrollList_AddDataType(scrollList, 1, "NPGM_RowTemplate", 40, SetupRow)
    end

    for i = 1, MAX_GROUP_SIZE_THRESHOLD do
        local unitTag = "group" .. i
        if DoesUnitExist(unitTag) then
            local displayName = GetUnitDisplayName(unitTag)
            if displayName and displayName ~= "" and not selectedDisplayNames[displayName] then
				selectedDisplayNames[displayName] = false
            end
        end
    end
	local actualIndex = 1
	for displayName,checked in pairs(selectedDisplayNames) do
		table.insert(scrollData, ZO_ScrollList_CreateDataEntry(1, CreateDataEntry(displayName, actualIndex)))
		actualIndex = actualIndex + 1
	end
    ZO_ScrollList_Commit(scrollList)
	
	if settings.autoInviteEnabled then									
		ZO_CheckButton_SetChecked(NPGM_UIToggleAutoInvite)
	else
		ZO_CheckButton_SetUnchecked(NPGM_UIToggleAutoInvite)
	end

    ZO_CheckButton_SetToggleFunction(NPGM_UIToggleAutoInvite, function(control, state)
		settings.autoInviteEnabled = state
		if dialogAutoInviteCheckBox then
			if state == true then
				ZO_CheckButton_SetChecked(dialogAutoInviteCheckBox.checkBox)
				d("Auto Invite Enabled")
			else
				ZO_CheckButton_SetUnchecked(dialogAutoInviteCheckBox.checkBox)
				d("Auto Invite Disabled")
			end
		end	
	end) 
end

local function KickSelected()
	if NonContiguousCount(selectedDisplayNames) > 0 then
		for name,checked in pairs(selectedDisplayNames) do
			if checked then
				GroupKickByName(name)
				zo_callLater(function() GroupInviteByName(name) end, 1000)
			end
		end	
    else
        d("No member selected.")
    end
end

local function ReinviteSelected()
	if NonContiguousCount(selectedDisplayNames) > 0 then
		for name,checked in pairs(selectedDisplayNames) do
			if checked then
				GroupInviteByName(name)
			end	
		end	
    else
        d("No member selected.")
    end
end

local function RefreshGroup()
	selectedDisplayNames = {}
	NPGMUI_Init()
end	

local function ReformGroup()
	local reinviteList = {}
	local leaderName = GetDisplayName()
	for i = 1, MAX_GROUP_SIZE_THRESHOLD do
        local unitTag = "group" .. i
        if DoesUnitExist(unitTag) then
            local displayName = GetUnitDisplayName(unitTag)
            if displayName and displayName ~= "" and displayName ~= leaderName then
				reinviteList[displayName] = true
            end
        end
    end
	GroupDisband()
	zo_callLater(function()
		for displayName,checked in pairs(reinviteList) do
			GroupInviteByName(displayName)
		end	
	end, 1000)	
end

local crateVisible = false
local function ToggleHideGroup()
  crateVisible = not crateVisible
  SetCrownCrateNPCVisible(crateVisible)
end

local isDialogOpening = false

local function OnReleaseDialog(dialog)
    local targetControl = dialog.entryList:GetTargetControl()
    if targetControl and targetControl.dropdown then targetControl.dropdown:Deactivate() end
    if not isDialogOpening then NPGM_UI:SetHidden(true) end
end

-- Auto Invite Settings
local function SetupAutoSettingsDialog()
	local listElements = {
		{
			header = "Invite Message",
			template = "ZO_GamepadMenuEntryHeaderTemplate",
			templateData = {
				setup = function(control)
					control:SetText("Will send invites to this message")
				end,
				callback = function() end,
			},
		},
		{
			template = "ZO_GamepadTextFieldItem",
			templateData = 
			{
				setup = function(control, data, selected, reselectingDuringRebuild, enabled, active)
					control.highlight:SetHidden(not selected)

					control.editBoxControl.textChangedCallback = function(control)
						settings.message = control:GetText()
					end
					data.control = control
					control.editBoxControl:SetDefaultText("Invite Message")
					control.editBoxControl:SetMaxInputChars(20)
					control.editBoxControl:SetText(settings.message)
				end,
				callback = function(dialog)
					local data = dialog.entryList:GetTargetData()
					local edit = data.control.editBoxControl

					edit:TakeFocus()
				end,
			},
		},		
		{
			header = "Channels",
			template = "ZO_GamepadMenuEntryHeaderTemplate",
			templateData = {
				setup = function(control)
					control:SetText("Select channels to invite from")
				end,
				callback = function() end,
			},
		},
	}
	
	local function generateChatEntry(name, chatId)
		return {
			template = "ZO_CheckBoxTemplate_Gamepad",
			templateData =
			{
				text = name,
				setup = ZO_GamepadCheckBoxTemplate_Setup,
				checked = function() return settings.channels[chatId] end,
				callback = function(dialog, data)
					local control = dialog.entryList:GetTargetControl()
					dialogAutoInviteSettingsCheckBoxes[chatId] = control
					settings.channels[chatId] = not settings.channels[chatId]
					if settings.channels[chatId] == true then
						ZO_CheckButton_SetChecked(control.checkBox)
					else
						ZO_CheckButton_SetUnchecked(control.checkBox)
					end
				end,
			},
		}
	end
	
	table.insert(listElements, generateChatEntry("Whisper", CHAT_CHANNEL_WHISPER))
	for i = 1, 5 do
		local name = GetGuildName(GetGuildId(i))
		if name ~= "" then 
			table.insert(listElements, generateChatEntry(name, 11+i))
		end	
	end
	table.insert(listElements, generateChatEntry("Zone", CHAT_CHANNEL_ZONE))
	table.insert(listElements, generateChatEntry("Say", CHAT_CHANNEL_SAY))

	
	
	ZO_Dialogs_RegisterCustomDialog("NedsAutoInviteSettingsDialog",
	{
		gamepadInfo = {
			dialogType = GAMEPAD_DIALOGS.PARAMETRIC,
		},
		setup = function(dialog, data)
			ZO_GenericGamepadDialog_RefreshText(dialog, "Auto Invite Settings")
			dialog:setupFunc(nil, data)
			isDialogOpening = false
		end,

		parametricList = listElements,	

		blockDialogReleaseOnPress = true,

		buttons = {
			{
				keybind = "DIALOG_PRIMARY",
				text = SI_GAMEPAD_SELECT_OPTION,
				callback = function(dialog)
					local targetData = dialog.entryList:GetTargetData()
					if targetData and type(targetData.callback) == "function" then
						targetData.callback(dialog)
					end
				end,
			},
			{
				keybind = "DIALOG_NEGATIVE",
				text = SI_DIALOG_CANCEL,
				callback = function(dialog)
					d("Auto Invite Settings Saved.")
					isDialogOpening = true
					ZO_Dialogs_ReleaseDialog("NedsAutoInviteSettingsDialog")
					zo_callLater(function()
						ZO_Dialogs_ShowPlatformDialog("NedsGroupManagerDialog")
					end, 300)
				end,
			},
		},
		onHidingCallback = OnReleaseDialog,
        noChoiceCallback = OnReleaseDialog,
	})
end

local function SetupGamePadDialog()
	ZO_Dialogs_RegisterCustomDialog("NedsGroupManagerDialog",
    {
        gamepadInfo =
        {
            dialogType = GAMEPAD_DIALOGS.PARAMETRIC,
        },
        setup =  function(dialog, data)
            ZO_GenericGamepadDialog_RefreshText(dialog, "Ned's Group Manager")
            dialog:setupFunc(nil, data)
			isDialogOpening = false
        end,
        parametricList =
        {
            {
                header = "Members",
                template = "ZO_GamepadMultiSelectionDropdownItem",
                templateData =
                {
                    setup = function(control, data, selected, reselectingDuringRebuild, enabled, active)
                        local dialog = data.dialog
                        local dialogData = dialog and dialog.data
                        local dropdown = control.dropdown

                        dropdown:SetNormalColor(ZO_GAMEPAD_COMPONENT_COLORS.UNSELECTED_INACTIVE:UnpackRGB())
                        dropdown:SetHighlightedColor(ZO_GAMEPAD_COMPONENT_COLORS.SELECTED_ACTIVE:UnpackRGB())
                        dropdown:SetSelectedItemTextColor(selected)

                        dropdown:SetSortsItems(false)
                        dropdown:SetNoSelectionText("Select Members")
                        dropdown:SetMultiSelectionTextFormatter("<<1[$d Member/$d Members]>>")

                        local dropdownData = ZO_MultiSelection_ComboBox_Data_Gamepad:New()
                        dropdownData:Clear()

						for i = 1, MAX_GROUP_SIZE_THRESHOLD do
							local unitTag = "group" .. i
							if DoesUnitExist(unitTag) then
								local displayName = GetUnitDisplayName(unitTag)
								if displayName and displayName ~= "" and not selectedDisplayNames[displayName] then
									selectedDisplayNames[displayName] = false
								end
							end
						end
						for displayName,checked in pairs(selectedDisplayNames) do
							local newEntry = ZO_ComboBox_Base:CreateItemEntry(displayName)
							newEntry.callback = function(control, name, item, checked)
								if checked then
									selectedDisplayNames[displayName] = true
								else
									selectedDisplayNames[displayName] = false
								end
								NPGMUI_Init()
							end	
							dropdownData:AddItem(newEntry)
							if selectedDisplayNames[displayName] then									
								dropdownData:ToggleItemSelected(newEntry)
							end
						end
                        dropdown:LoadData(dropdownData)
						NPGMUI_Init()
                    end,
                    callback = function(dialog)
                        local targetData = dialog.entryList:GetTargetData()
                        local targetControl = dialog.entryList:GetTargetControl()
                        targetControl.dropdown:Activate()
                    end,
                },
            },
			{
				template = "ZO_GamepadMenuEntryTemplate",
				templateData =
				{
					text = "Kick & Reinvite",
					setup = ZO_SharedGamepadEntry_OnSetup,
					callback = function(dialog)
						KickSelected()
					end,
				},
			},
			{
				template = "ZO_GamepadMenuEntryTemplate",
				templateData =
				{
					text = "Reinvite Missed",
					setup = ZO_SharedGamepadEntry_OnSetup,
					callback = function(dialog)
						ReinviteSelected()
					end,
				},
			},
			{
				template = "ZO_GamepadMenuEntryTemplate",
				templateData = 
				{
					text = "Refresh Group List",
					setup = ZO_SharedGamepadEntry_OnSetup,
					callback = function(dialog)
						RefreshGroup()
					end,
				},
			},
			{
				template = "ZO_GamepadMenuEntryTemplate",
				templateData =
				{
					text = "Reform Group",
					setup = ZO_SharedGamepadEntry_OnSetup,
					callback = function(dialog)
						ReformGroup()
					end,
				},
			},
			{
				template = "ZO_GamepadMenuEntryTemplate",
				templateData =
				{
					text = "Toggle Hide Group",
					setup = ZO_SharedGamepadEntry_OnSetup,
					callback = function(dialog)
						ToggleHideGroup()
					end,
				},
			},
			{
				template = "ZO_GamepadMenuEntryHeaderTemplate",
				templateData = 
				{
					setup = function(control)
						control:SetText("Auto Invite")
					end,	
				},
			},	
			{
				template = "ZO_CheckBoxTemplate_Gamepad",
				templateData =
				{
					text = "Toggle Auto Invite",
					setup = ZO_GamepadCheckBoxTemplate_Setup,
					setChecked = function(control, state)
						dialogAutoInviteCheckBox = control
						settings.autoInviteEnabled = state
						if state == true then
							ZO_CheckButton_SetChecked(control.checkBox)
							ZO_CheckButton_SetChecked(NPGM_UIToggleAutoInvite)
							d("Auto Invite Enabled")
						else
							ZO_CheckButton_SetUnchecked(control.checkBox)
							ZO_CheckButton_SetUnchecked(NPGM_UIToggleAutoInvite)
							d("Auto Invite Disabled")
						end
					end,
					checked = function() return settings.autoInviteEnabled end,
					callback = function(dialog, data)
						data.setChecked(dialog.entryList:GetTargetControl(), not settings.autoInviteEnabled)
					end,
				},
			},
			{
				template = "ZO_GamepadMenuEntryTemplate",
				templateData = {
					text = "Auto Invite Settings",
					setup = ZO_SharedGamepadEntry_OnSetup,
					callback = function(dialog)
						isDialogOpening = true
						ZO_Dialogs_ReleaseDialog("NedsGroupManagerDialog")
						zo_callLater(function()
							ZO_Dialogs_ShowPlatformDialog("NedsAutoInviteSettingsDialog")
						end, 300)
					end,
				},
			},
        },
        blockDialogReleaseOnPress = true,
        buttons =
        {
            {
                keybind = "DIALOG_PRIMARY",
                text = SI_GAMEPAD_SELECT_OPTION,
                callback = function(dialog)
                    local targetData = dialog.entryList:GetTargetData()
                    if targetData and targetData.callback then
                        targetData.callback(dialog, targetData)
                    end
                end,
            },
            {
                keybind = "DIALOG_NEGATIVE",
                text = SI_DIALOG_CANCEL,
                callback =  function(dialog)
                    local dialogData = dialog.data
                    ZO_Dialogs_ReleaseDialogOnButtonPress("NedsGroupManagerDialog")
                end,
            },
        },
        onHidingCallback = OnReleaseDialog,
        noChoiceCallback = OnReleaseDialog,
    })
	
	local menu = GAMEPAD_GROUP_MENU
    local MENU_ENTRY_TYPE_NPGM_TOGGLE = #menu.menuEntries + 1
    local entry = ZO_GamepadEntryData:New("")
    entry.type = MENU_ENTRY_TYPE_NPGM_TOGGLE
    entry:SetHeader("NGM")
	entry:SetText("Open NGM")
    menu.menuEntries[MENU_ENTRY_TYPE_NPGM_TOGGLE] = entry

    local list = GAMEPAD_GROUP_MENU:GetMainList()
    local originalCommit = list.Commit
    list.Commit = function(self, ...)
        list:AddEntryWithHeader("ZO_GamepadMenuEntryTemplate", entry)
        originalCommit(self, ...)
    end
	
	local InitializeKeybindDescriptors = menu.InitializeKeybindDescriptors
    menu.InitializeKeybindDescriptors = function(self)
        InitializeKeybindDescriptors(self)

        local primary = menu.keybindStripDescriptor[1]
        local callback = primary.callback
        primary.callback = function()
            callback()
            local type = list:GetTargetData().type
            if type == MENU_ENTRY_TYPE_NPGM_TOGGLE then
                PlaySound(SOUNDS.DEFAULT_CLICK)
				NPGM_UI:SetHidden(false)
				NPGMUI_Init()
				ZO_Dialogs_ShowPlatformDialog("NedsGroupManagerDialog")
            end
        end
    end
end
local function ToggleUI()
    if NPGM_UI:IsHidden() then
        NPGM_UI:SetHidden(false)
        NPGMUI_Init()
		ZO_Dialogs_ShowPlatformDialog("NedsGroupManagerDialog")		
    else
        NPGM_UI:SetHidden(true)
    end
end	

local groupLeader = ""
local function SaveGroupLeader()
	local groupLeaderUnitTag = GetGroupLeaderUnitTag()
	if DoesUnitExist(groupLeaderUnitTag) then
		local displayName = GetUnitDisplayName(groupLeaderUnitTag)
		if displayName and displayName ~= "" then
			groupLeader = displayName
		end
	end
end

local function SetupGroupEventHandlers()
    local removedTime = 0
	local whisperReciever = ""
	local whisperTime = 0
	
	EVENT_MANAGER:RegisterForEvent(addonName, EVENT_GROUP_MEMBER_JOINED, function( _, _, _, isLocalPlayer )
		if not NPGM_UI:IsHidden() then NPGMUI_Init() end
		if isLocalPlayer then
			SaveGroupLeader()
		end
    end)

    EVENT_MANAGER:RegisterForEvent(addonName, EVENT_GROUP_MEMBER_LEFT, function( _, _, reason, isLocalPlayer, isLeader, memberDisplayName )
        if (not isLocalPlayer and isLeader and reason == GROUP_LEAVE_REASON_DISBAND) then
            groupLeader = memberDisplayName
            removedTime = GetGameTimeMilliseconds()
			return
        end
		if isLocalPlayer and not isLeader and reason == GROUP_LEAVE_REASON_KICKED then
			removedTime = GetGameTimeMilliseconds()
		end
    end)

    EVENT_MANAGER:RegisterForEvent(addonName, EVENT_GROUP_INVITE_RECEIVED, function( _, _, inviterDisplayName )
        if (inviterDisplayName == groupLeader and GetGameTimeMilliseconds() - removedTime < 5000) 
			or (inviterDisplayName == whisperReciever and GetGameTimeMilliseconds() - whisperTime < 5000) then 
            AcceptGroupInvite()
        end
    end)
	
	EVENT_MANAGER:RegisterForEvent(addonName, EVENT_LEADER_UPDATE, function( _, groupLeaderUnitTag )
		if DoesUnitExist(groupLeaderUnitTag) then
			local displayName = GetUnitDisplayName(groupLeaderUnitTag)
			if displayName and displayName ~= "" then
				groupLeader = displayName
			end
		end
	end)
	EVENT_MANAGER:RegisterForEvent(addonName, EVENT_CHAT_MESSAGE_CHANNEL, function(_, channel, _, text, _, fromDisplayName)
		if channel == CHAT_CHANNEL_WHISPER_SENT then
			whisperReciever = fromDisplayName
			whisperTime = GetGameTimeMilliseconds()
		end
		if settings.autoInviteEnabled and (text == settings.message) and settings.channels[channel] then
			GroupInviteByName(fromDisplayName)
		end
	end)
end

local function OnAddOnLoaded(event, name)
    if name ~= addonName then return end
    EVENT_MANAGER:UnregisterForEvent(addonName, EVENT_ADD_ON_LOADED)
	InitSettings()
	InitLAM()

    SLASH_COMMANDS["/ned"] = ToggleUI


    -- Set button functionality
    NPGM_UIKickButton:SetHandler("OnClicked", KickSelected)
    NPGM_UIReinviteButton:SetHandler("OnClicked", ReinviteSelected)
	NPGM_UIRefreshGroup:SetHandler("OnClicked", RefreshGroup)
	NPGM_UIReformGroup:SetHandler("OnClicked", ReformGroup)
	NPGM_UIHideGroup:SetHandler("OnClicked", ToggleHideGroup)
	NPGM_UIAutoSettings:SetHandler("OnClicked", function() LibAddonMenu2:OpenToPanel(LAMPanel) end)
	NPGM_UIHide:SetHandler("OnClicked", function() NPGM_UI:SetHidden(true) end)
	SetupAutoSettingsDialog()
	SetupGamePadDialog()
	SaveGroupLeader()
	SetupGroupEventHandlers()
end

EVENT_MANAGER:RegisterForEvent(addonName, EVENT_ADD_ON_LOADED, OnAddOnLoaded)