local name = "ImprovedGoldenPursuits"
local version = "1.5.1"

IGP = {
	sortOrder = IGP_SORTING_ORDER_DEFAULT, -- Change to desired default sorting type
	controls = {},
	taskRewardsAvailable = false
}

-- Maps the runtime assigned stringIds to fixed numbers
IGP.IDMappings = {
	[IGP_SORTING_ORDER_DEFAULT] = 1,
	[IGP_SORTING_ORDER_ALPHABETICALLY] = 2,
	[IGP_SORTING_ORDER_PROGRESS_ASC] = 3,
	[IGP_SORTING_ORDER_PROGRESS_DESC] = 4,
}

IGP.defaults = {
	hideComplete = false,
	rewardsOnly = false,
	sortOrder = IGP.IDMappings[IGP_SORTING_ORDER_DEFAULT],
}

local IGP_SORTING_TYPES = {
	[1] = IGP_SORTING_ORDER_DEFAULT,
	[2] = IGP_SORTING_ORDER_ALPHABETICALLY,
	[3] = IGP_SORTING_ORDER_PROGRESS_ASC,
	[4] = IGP_SORTING_ORDER_PROGRESS_DESC,
}


local function CheckIfTaskRewardsAreAvailable(self)
	if not self.currentCampaignData then
		self:RefreshCampaignData()
	end
	local activityDataTable = self.currentCampaignData:GetActivities()
	for _, activityData in ipairs(activityDataTable) do
		if activityData.rewardId ~= 0 then
			IGP.taskRewardsAvailable = true
			return
		end
	end
	IGP.taskRewardsAvailable = false
end

-- https://github.com/esoui/esoui/blob/31d308725815e450fa56afe2041d67bc69ab06da/esoui/ingame/promotionalevents/promotionalevents_shared.lua#L417
local function RefreshActivityList(self, rebuild)
	if rebuild and self.activityList then
        ZO_ScrollList_Clear(self.activityList)
        local scrollData = ZO_ScrollList_GetDataList(self.activityList)
            
        if self.currentCampaignData then
			local activityDataTable = {}
			-- Copy, as sorting source table is bad :c
			ZO_ShallowTableCopy(self.currentCampaignData:GetActivities(), activityDataTable)
		
			if IGP.sortOrder == IGP_SORTING_ORDER_DEFAULT then -- Default order is the internal activityIndex
				table.sort(activityDataTable,
					function(item1, item2)
						return ZO_TableOrderingFunction(item1, item2, "activityIndex", {["activityIndex"] = { isNumeric = true }}, true)
					end)
			elseif IGP.sortOrder == IGP_SORTING_ORDER_ALPHABETICALLY then
				table.sort(activityDataTable,
					function(item1, item2)
						return ZO_TableOrderingFunction(item1, item2, "displayName", {["displayName"] = {}}, true)
					end)
			elseif IGP.sortOrder == IGP_SORTING_ORDER_PROGRESS_ASC then
				table.sort(activityDataTable,
					function(item1, item2)
						-- Compare percentage completion of 2 tasks
						return (item1:GetProgress() / item1.completionThreshold) < (item2:GetProgress() / item2.completionThreshold)
					end)
			elseif IGP.sortOrder == IGP_SORTING_ORDER_PROGRESS_DESC then
				table.sort(activityDataTable,
					function(item1, item2)
						-- Compare percentage completion of 2 tasks
						return (item1:GetProgress() / item1.completionThreshold) > (item2:GetProgress() / item2.completionThreshold)
					end)
			end
			
			-- Entries for list
			for _, activityData in ipairs(activityDataTable) do
				local hide = false
				
				-- Filter out completed tasks, if requested, but show completed ones with unclaimed rewards.
				if IGP.SV.hideComplete and activityData:IsComplete() then
					hide = true
					if not activityData:IsRewardClaimed() then
						hide = false
					end
				end
				
				-- Filter out tasks without reward, if requested
				if IGP.taskRewardsAvailable and IGP.SV.rewardsOnly and activityData.rewardId == 0 then
					hide = true
				end
			
				-- Don't include any tasks which are hidden due to any of the above filters
				if not hide then
					local entryData = ZO_EntryData:New(activityData) 
					table.insert(scrollData, ZO_ScrollList_CreateDataEntry(self.entryTypeActivity, entryData))
				end
			end
			
			-- Show "No matches" label if list is empty
			if IGP.controls.noMatchLabel then
				IGP.controls.noMatchLabel:SetHidden(#scrollData ~= 0)
			end
        end
        ZO_ScrollList_Commit(self.activityList)
    else
        ZO_ScrollList_RefreshVisible(self.activityList)
    end
end


local function ModifyGamepadKeybindDescriptors()
	local filtersDescriptorEntry = {
		name = GetString(SI_GAMEPAD_CRAFTING_OPTIONS_FILTERS),
		alignment = KEYBIND_STRIP_ALIGN_LEFT,
		keybind = "UI_SHORTCUT_QUINARY",	
		callback = function()
			ZO_Dialogs_ShowGamepadDialog("IGP_FILTERS_GAMEPAD")
		end,
	}

	-- Remove "Claim All" from all keybind descriptors
	PROMOTIONAL_EVENTS_GAMEPAD.overviewFocalArea.keybindDescriptor[1] = filtersDescriptorEntry
	PROMOTIONAL_EVENTS_GAMEPAD.milestonesFocalArea.keybindDescriptor[2] = filtersDescriptorEntry
	PROMOTIONAL_EVENTS_GAMEPAD.capstoneFocalArea.keybindDescriptor[2] = filtersDescriptorEntry
	PROMOTIONAL_EVENTS_GAMEPAD.activitiesFocalArea.keybindDescriptor[2] = filtersDescriptorEntry
end

local function InitializeGamepadDialog()
	local currentSortType = IGP_SORTING_TYPES[IGP.SV.sortOrder] -- Saved value is essentially an index into the sorting types
	local dropdownInstance
	
	local parametricList = {
		{
			template = "ZO_CheckBoxTemplate_WithoutIndent_Gamepad",
			text = GetString(IGP_FILTER_HIDE_COMPLETE),
			templateData = {
				checked = function(data)
					return IGP.SV.hideComplete
				end,
				setup = function(control, data, selected, reselectingDuringRebuild, enabled, active)
					control.checkBox.dialog = data.dialog
					ZO_GamepadCheckBoxTemplate_Setup(control, data, selected, reselectingDuringRebuild, enabled, active)
				end,
				callback = function(dialog)
					local targetControl = dialog.entryList:GetTargetControl()
					ZO_GamepadCheckBoxTemplate_OnClicked(targetControl)
					IGP.SV.hideComplete = ZO_GamepadCheckBoxTemplate_IsChecked(targetControl)
					PROMOTIONAL_EVENTS_GAMEPAD:RefreshActivityList(true)
				end,
			},
		},
		{
			template = "ZO_CheckBoxTemplate_WithoutIndent_Gamepad",
			text = GetString(IGP_FILTER_REWARDS_ONLY),
			templateData = {
				checked = function(data)
					return IGP.SV.rewardsOnly
				end,
				setup = function(control, data, selected, reselectingDuringRebuild, enabled, active)
					control.checkBox.dialog = data.dialog
					ZO_GamepadCheckBoxTemplate_Setup(control, data, selected, reselectingDuringRebuild, enabled, active)
				end,
				callback = function(dialog)
					local targetControl = dialog.entryList:GetTargetControl()
					ZO_GamepadCheckBoxTemplate_OnClicked(targetControl)
					IGP.SV.rewardsOnly = ZO_GamepadCheckBoxTemplate_IsChecked(targetControl)
					PROMOTIONAL_EVENTS_GAMEPAD:RefreshActivityList(true)
				end,
			},
		},
		{
			template = "ZO_GamepadDropdownItem",
			headerTemplate = "ZO_GamepadMenuEntryFullWidthHeaderTemplate",
			header = SI_GAMEPAD_BANK_SORT_ORDER_HEADER,
			templateData = {
				setup = function(control, data, selected, reselectingDuringRebuild, enabled, active)
					local combobox = control.dropdown
					dropdownInstance = combobox
					
					combobox:SetNormalColor(ZO_GAMEPAD_COMPONENT_COLORS.UNSELECTED_INACTIVE:UnpackRGB())
					combobox:SetHighlightedColor(ZO_GAMEPAD_COMPONENT_COLORS.SELECTED_ACTIVE:UnpackRGB())
					combobox:SetSelectedItemTextColor(selected)
					combobox:SetSortsItems(false)
					combobox:ClearItems()
					
					for _, stringId in pairs(IGP_SORTING_TYPES) do
						local entry = combobox:CreateItemEntry(GetString(stringId), function(entry, text, data, selectionChanged, previousData)
							IGP.sortOrder = entry.sortType
							IGP.SV.sortOrder = IGP.IDMappings[entry.sortType]
							PROMOTIONAL_EVENTS_GAMEPAD:RefreshActivityList(true)
						end)
						entry.sortType = stringId
						combobox:AddItem(entry, ZO_COMBOBOX_SUPPRESS_UPDATE)
					end

					combobox:UpdateItems()
					
					local IGNORE_CALLBACK = true
					combobox:SelectItemByIndex(IGP.SV.sortOrder, IGNORE_CALLBACK)
				end,
				callback = function(dialog)
					local targetControl = dialog.entryList:GetTargetControl()
					if targetControl then
						targetControl.dropdown:Activate()
					end
				end,
			},
		},
	}
	
	-- Remove filter option, if current campaign has no tasks with rewards
	if not IGP.taskRewardsAvailable then
		table.remove(parametricList, 1)
	end
	
    ZO_Dialogs_RegisterCustomDialog("IGP_FILTERS_GAMEPAD", {
        gamepadInfo = {
            dialogType = GAMEPAD_DIALOGS.PARAMETRIC,
        },
        setup = function(dialog)
			ZO_GenericGamepadDialog_RefreshText(dialog, GetString(SI_GAMEPAD_ITEM_SETS_BOOK_OPTIONS_FILTERS))
			dialog:setupFunc()
		end,
		parametricList = parametricList,
		blockDialogReleaseOnPress = true,
        buttons = {
            {
                keybind = "DIALOG_PRIMARY",
                text = SI_GAMEPAD_SELECT_OPTION,
                callback = function(dialog)
                    local data = dialog.entryList:GetTargetData()
                    if data.callback then
                        data.callback(dialog)
                    end
                end,
                clickSound = SOUNDS.DIALOG_ACCEPT,
            },
            {
                keybind = "DIALOG_NEGATIVE",
                text = SI_DIALOG_CANCEL,
				callback = function(dialog)
                    ZO_Dialogs_ReleaseDialogOnButtonPress("IGP_FILTERS_GAMEPAD")
                end,
            },
        },
		onHidingCallback = function(dialog)
			dropdownInstance:Deactivate()
		end,
    })
end

local function InitializeKeyboard()
	-- Sorting dropdown
	local comboboxControl = WINDOW_MANAGER:CreateControlFromVirtual(ZO_PromotionalEvents_KeyboardTL:GetName() .. "SortingSelector", ZO_PromotionalEvents_KeyboardTL, "ZO_ComboBox")
	comboboxControl:SetAnchor(BOTTOMRIGHT, ZO_PromotionalEvents_KeyboardTL, TOPRIGHT, 2, -7)
	comboboxControl:SetDimensions(300, 33)
	
	local function OnSortingStyleChange(combobox, entryText, entry)
		IGP.sortOrder = entry.sortingType
		IGP.SV.sortOrder = IGP.IDMappings[entry.sortingType]
		PROMOTIONAL_EVENTS_KEYBOARD:RefreshActivityList(true)
	end
	
	local combobox = ZO_ComboBox_ObjectFromContainer(comboboxControl)

	for _, stringId in ipairs(IGP_SORTING_TYPES) do
        local entry = combobox:CreateItemEntry(GetString(stringId), OnSortingStyleChange)
		entry.sortingType = stringId
        combobox:AddItem(entry, ZO_COMBOBOX_SUPRESS_UPDATE)
    end
	combobox:SelectItemByIndex(IGP.SV.sortOrder)
	IGP.controls.sortingDropdown = combobox
	
	
	-- "Hide Complete" checkbox
	local checkbox = WINDOW_MANAGER:CreateControlFromVirtual(ZO_PromotionalEvents_KeyboardTL:GetName() .. "HideComplete", ZO_PromotionalEvents_KeyboardTL, "ZO_CheckButton")
    checkbox:SetAnchor(RIGHT, ZO_PromotionalEvents_KeyboardTLSortingSelector, LEFT, -150)
    ZO_CheckButton_SetLabelText(checkbox, GetString(IGP_FILTER_HIDE_COMPLETE)) 
    ZO_CheckButton_SetCheckState(checkbox, IGP.SV.hideComplete)
    ZO_CheckButton_SetToggleFunction(checkbox, function()
		local isChecked = ZO_CheckButton_IsChecked(checkbox)
		IGP.SV.hideComplete = isChecked
		PROMOTIONAL_EVENTS_KEYBOARD:RefreshActivityList(true)
    end)
	IGP.controls.hideCompleteCheckbox = checkbox
	
	
	-- "Only with Rewards" checkbox
	local checkbox2 = WINDOW_MANAGER:CreateControlFromVirtual(ZO_PromotionalEvents_KeyboardTL:GetName() .. "RewardsOnly", ZO_PromotionalEvents_KeyboardTL, "ZO_CheckButton")
    checkbox2:SetAnchor(RIGHT, ZO_PromotionalEvents_KeyboardTLHideComplete, LEFT, -150)
    ZO_CheckButton_SetLabelText(checkbox2, GetString(IGP_FILTER_REWARDS_ONLY)) 
    ZO_CheckButton_SetCheckState(checkbox2, IGP.SV.rewardsOnly)
    ZO_CheckButton_SetToggleFunction(checkbox2, function()
		local isChecked = ZO_CheckButton_IsChecked(checkbox2)
		IGP.SV.rewardsOnly = isChecked
		PROMOTIONAL_EVENTS_KEYBOARD:RefreshActivityList(true)
    end)
	-- Remove filter option, if current campaign has no tasks with rewards
	checkbox2:SetHidden(not IGP.taskRewardsAvailable)
	IGP.controls.onlyRewardsCheckbox = checkbox2
	
	-- "All complete" message, if no matches
	local noMatchLabel = WINDOW_MANAGER:CreateControl(ZO_PromotionalEvents_KeyboardTLContents:GetName() .. "NoMatchMessage", ZO_PromotionalEvents_KeyboardTLContents, CT_LABEL)
	noMatchLabel:SetAnchor(TOP, ZO_PromotionalEvents_KeyboardTLContentsActivityList, TOP, 0, 10)
	noMatchLabel:SetText(GetString(IGP_OVERVIEW_NO_MATCH))
	noMatchLabel:SetFont("ZoFontWinH4")
	noMatchLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
	noMatchLabel:SetColor(ZO_SELECTED_TEXT:UnpackRGBA())
	noMatchLabel:SetHidden(true)
	IGP.controls.noMatchLabel = noMatchLabel
	
	PROMOTIONAL_EVENTS_KEYBOARD:RefreshActivityList(true)
end

local function OnAddonLoaded(event, addonName)
    if addonName ~= name then return end
    EVENT_MANAGER:UnregisterForEvent(name, EVENT_ADD_ON_LOADED)
    
	IGP.SV = ZO_SavedVars:NewAccountWide("ImprovedGoldenPursuitsSavedVariables", 1.0, nil, IGP.defaults, GetWorldName())
	
	-- Create controls and such only after the Promotional Events are initialized
    SecurePostHook(PROMOTIONAL_EVENTS_KEYBOARD, "OnDeferredInitialize", function()
		CheckIfTaskRewardsAreAvailable(PROMOTIONAL_EVENTS_KEYBOARD)
		InitializeKeyboard()
	end)
	SecurePostHook(PROMOTIONAL_EVENTS_GAMEPAD, "OnDeferredInitialize", function()
		CheckIfTaskRewardsAreAvailable(PROMOTIONAL_EVENTS_GAMEPAD)
		InitializeGamepadDialog()
		ModifyGamepadKeybindDescriptors()
	end)
	
	-- Override the function to refresh the list with our own one
	IGP.origRefreshActivityList = ZO_PromotionalEvents_Shared.RefreshActivityList
	ZO_PromotionalEvents_Shared.RefreshActivityList = RefreshActivityList
	
	-- Refresh list every time it's shown, as otherwise tasks that get completed wouldn't be filtered out unless checkbox toggle
	PROMOTIONAL_EVENTS_KEYBOARD.fragment:RegisterCallback("StateChange", function(oldState, newState)
		if newState == SCENE_FRAGMENT_SHOWING then
			PROMOTIONAL_EVENTS_KEYBOARD:RefreshActivityList(true)
		end
	end)
	PROMOTIONAL_EVENTS_GAMEPAD.fragment:RegisterCallback("StateChange", function(oldState, newState)
		if newState == SCENE_FRAGMENT_SHOWING then
			PROMOTIONAL_EVENTS_GAMEPAD:RefreshActivityList(true)
		end
	end)
	
	-- Refresh list every time a reward is claimed
	PROMOTIONAL_EVENT_MANAGER:RegisterCallback("RewardsClaimed", function()
		if IsInGamepadPreferredMode() then
			PROMOTIONAL_EVENTS_GAMEPAD:RefreshActivityList(true)
		else
			PROMOTIONAL_EVENTS_KEYBOARD:RefreshActivityList(true)
		end
	end)	
end
EVENT_MANAGER:RegisterForEvent(name, EVENT_ADD_ON_LOADED, OnAddonLoaded)