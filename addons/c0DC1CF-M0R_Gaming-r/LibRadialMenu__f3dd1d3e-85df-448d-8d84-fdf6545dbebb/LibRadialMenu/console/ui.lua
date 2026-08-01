LibRadialMenu = LibRadialMenu or {}
local registeredEntries = LibRadialMenu.registeredEntries
local addonNames = LibRadialMenu.addonNames






--[[
	
	
		   _        ____     ____   ____   ____   ___      __________      ___   ____
		  dM.      6MMMMb\  6MMMMb\ `MM'  6MMMMb/ `MM\     `M'`MM'`MM\     `M'  6MMMMb/
		 ,MMb     6M'    ` 6M'    `  MM  8P    YM  MMM\     M  MM  MMM\     M  8P    YM
		 d'YM.    MM       MM        MM 6M      Y  M\MM\    M  MM  M\MM\    M 6M      Y
		,P `Mb    YM.      YM.       MM MM         M \MM\   M  MM  M \MM\   M MM
		d'  YM.    YMMMMb   YMMMMb   MM MM         M  \MM\  M  MM  M  \MM\  M MM
	   ,P   `Mb        `Mb      `Mb  MM MM     ___ M   \MM\ M  MM  M   \MM\ M MM     ___
	   d'    YM.        MM       MM  MM MM     `M' M    \MM\M  MM  M    \MM\M MM     `M'
	  ,MMMMMMMMb        MM       MM  MM YM      M  M     \MMM  MM  M     \MMM YM      M
	  d'      YM. L    ,M9 L    ,M9  MM  8b    d9  M      \MM  MM  M      \MM  8b    d9
	_dM_     _dMM_MYMMMM9  MYMMMM9  _MM_  YMMMM9  _M_      \M _MM__M_      \M   YMMMM9
	
	
	
]]





local CHECKED_ICON = "EsoUI/Art/Inventory/Gamepad/gp_inventory_icon_equipped.dds"

local function IsSelected(data)
	return data.isActive
end


local function SetupProfileItem(control, data, ...)
	ZO_SharedGamepadEntry_OnSetup(control, data, ...)
	control.statusIndicator = control:GetNamedChild("StatusIndicator")
	if IsSelected(data) then
		control.statusIndicator:AddIcon(CHECKED_ICON)
		control.statusIndicator:Show()
	end
	control.icon = control:GetNamedChild("Icon")
	control.icon:AddIcon(data.icon)
	control.icon:Show()
end

local function SetupHeader(control, data, ...)
	ZO_SharedGamepadEntry_OnSetup(control, data, ...)
	control:SetText(data.addonName)
end

local function SetupProfiles(dialog, activeCriteria, slotIndex)
	dialog.info.parametricList = {}
	local template = "LibRadialMenuAssigningEntry"
	local headerTemplate = "ZO_GamepadOptionsMenuEntryHeaderTemplate"

	local addons = {}
	for i,v in pairs(registeredEntries) do
		addons[#addons+1] = i
	end
	table.sort(addons)


	for i,addon in ipairs(addons) do
		local addonTable = registeredEntries[addon]

		local addonEntries = {}
		for i,v in pairs(addonTable) do
			addonEntries[#addonEntries+1] = i
		end
		table.sort(addonEntries)


		local addonName = addonNames[addon]
		local entryData = ZO_GamepadEntryData:New(addonName)
		entryData.setup = SetupHeader
		entryData.addonName = addonName

		local listItem = {
			template = headerTemplate,
			entryData = entryData,
		}
		table.insert(dialog.info.parametricList, listItem)

		for j,entryId in pairs(addonEntries) do
			local entry = addonTable[entryId]
			local icon = entry.icon or ""
			local name = entry.name or entryData.entry
			local description = entry.description

			local entryData = ZO_GamepadEntryData:New(name)
			entryData:SetFontScaleOnSelection(false)
			entryData:SetIconTintOnSelection(true)
			entryData.setup = SetupProfileItem
			entryData.name = name
			entryData.entryId = entryId
			entryData.addonName = addonName
			entryData.addonId = addon
			entryData.icon = icon
			entryData.description = description
			entryData.isActive = activeCriteria(addon, entryId)

			local listItem = {
				template = template,
				entryData = entryData,
			}
			table.insert(dialog.info.parametricList, listItem)
		end
	end
	dialog:setupFunc()
	dialog.entryList:SetSelectedDataByEval(IsSelected)
end

ESO_Dialogs["LibProfileAssignDialogue"] = {
	canQueue = true,
	gamepadInfo = {
		dialogType = GAMEPAD_DIALOGS.PARAMETRIC,
	},
	setup = function(dialog)
		local entry = LibRadialMenu.libRadialWheelEntries[dialog.data.slotIndex]
		SetupProfiles(dialog, function(addonId, entryId)
			return (entry ~= nil) and (entry.entry == entryId) and (entry.addon == addonId)
		end, dialog.data.slotIndex)
	end,
	title = {
		text = function(dialog) return string.format(GetString(SI_LIBRADIALMENU_ASSIGN_TITLE), dialog.data.slotIndex) end,
	},
	buttons = {
		{
			text = function(dialog)
				local data = dialog.entryList:GetTargetData()
				if data and data.isActive then
					return GetString(SI_DIALOG_REMOVE)
				end
				return GetString(SI_GAMEPAD_ITEM_ACTION_QUICKSLOT_ASSIGN)
			end,
			callback = function(dialog)
				local data = dialog.entryList:GetTargetData()
				if data.addonId and data.entryId then
					if data.isActive then
						LibRadialMenu.libRadialWheelEntries[dialog.data.slotIndex] = { }
					else
						LibRadialMenu.libRadialWheelEntries[dialog.data.slotIndex] = {
							entry = data.entryId,
							addon = data.addonId
						}
					end
					ZO_Dialogs_ReleaseDialogOnButtonPress("LibProfileAssignDialogue")
					if LibHarvensAddonSettings.list then
						LibHarvensAddonSettings.list:RefreshVisible()
					end
				end
			end,
		},
		{
			text = SI_DIALOG_EXIT,
			callback = function()
				ZO_Dialogs_ReleaseDialogOnButtonPress("LibProfileAssignDialogue")
			end
		}
	},
	blockDialogReleaseOnPress = true,
	parametricListOnSelectionChangedCallback = function(dialog)
		local data = dialog.entryList:GetTargetData()
		if data.addonName and data.icon then
			local headerData =
			{
				titleText = data.addonName,
				messageText = string.format("|t27:27:%s|t %s\n\n%s", data.icon, data.name, data.description),
				messageTextAlignment = TEXT_ALIGN_LEFT,
			}
			GAMEPAD_TOOLTIPS:ShowGenericHeader(GAMEPAD_LEFT_DIALOG_TOOLTIP, headerData)
			ZO_GenericGamepadDialog_ShowTooltip(dialog)
		else
			ZO_GenericGamepadDialog_HideTooltip(dialog)
		end
		
	end
}











--[[
	
	
	  ____   __________ __________ __________ _______      ___   ____     ____
	 6MMMMb\ `MMMMMMMMM MMMMMMMMMM MMMMMMMMMM `MM'`MM\     `M'  6MMMMb/  6MMMMb\
	6M'    `  MM      \ /   MM   \ /   MM   \  MM  MMM\     M  8P    YM 6M'    `
	MM        MM            MM         MM      MM  M\MM\    M 6M      Y MM
	YM.       MM    ,       MM         MM      MM  M \MM\   M MM        YM.
	 YMMMMb   MMMMMMM       MM         MM      MM  M  \MM\  M MM         YMMMMb
		 `Mb  MM    `       MM         MM      MM  M   \MM\ M MM     ___     `Mb
		  MM  MM            MM         MM      MM  M    \MM\M MM     `M'      MM
		  MM  MM            MM         MM      MM  M     \MMM YM      M       MM
	L    ,M9  MM      /     MM         MM      MM  M      \MM  8b    d9 L    ,M9
	MYMMMM9  _MMMMMMMMM    _MM_       _MM_    _MM__M_      \M   YMMMM9  MYMMMM9
	
	
	
]]



LibRadialMenu.settings = LibHarvensAddonSettings:AddAddon("Lib Radial Menu")
local settings = LibRadialMenu.settings



local getLabel = function(entryData, index)
	local entryAddon = registeredEntries[entryData.addon]
	if entryAddon and entryAddon[entryData.entry] and addonNames[entryData.addon] then
		local entry = entryAddon[entryData.entry]
		local addonName = addonNames[entryData.addon]
		local slotIcon = entry.icon or ""
		local slotname = entry.name or entryData.entry
		local description = entry.description
		return string.format("%s|t27:27:%s|t %s", string.format(GetString(SI_LIBRADIALMENU_ASSIGN_SLOT), index), slotIcon, slotname)
	else
		return string.format(GetString(SI_LIBRADIALMENU_ASSIGN_SLOT), index)
	end
end

local getTooltip = function(entryData)
	local entryAddon = registeredEntries[entryData.addon]
	if entryAddon and entryAddon[entryData.entry] and addonNames[entryData.addon] then
		local entry = entryAddon[entryData.entry]
		local addonName = addonNames[entryData.addon]
		local slotIcon = entry.icon or ""
		local slotname = entry.name or entryData.entry
		local description = entry.description
		return string.format("%s\n\n|t27:27:%s|t %s\n\n%s", addonName, slotIcon, slotname, description)
	else
		return GetString(SI_LIBRADIALMENU_ASSIGN_NOTHING)
	end
end


function LibRadialMenu.openSettings()
	if (LibHarvensAddonSettings.initialized ~= true) and (LibHarvensAddonSettings.scrollList == nil)  then
		LibHarvensAddonSettings:Initialize()
	end
	settings:Select()
	local headerData = {}
	headerData.titleText = settings.name
	headerData.subtitleText = settings.version
	headerData.messageText = zo_strformat(GetString(SI_ADD_ON_AUTHOR_LINE), "@M0R_Gaming")
	ZO_GamepadGenericHeader_RefreshData(LibHarvensAddonSettings.scrollList.header, headerData)
	SCENE_MANAGER:Push("LibHarvensAddonSettingsScene")
end




function LibRadialMenu.UpdateSettingsMenu()
	settings:Clear()

	if LibRadialMenu.isCN then
		if LibRadialMenu.vars.cntype == "tradcn" then
			LibRadialMenu.loadTradCN()
		else
			LibRadialMenu.loadSimpleCN()
		end
		LibRadialMenu:RegisterEntry("libradialmenu", GetString(SI_LIBRADIALMENU_OPEN_SETTINGS), "opensettings", "esoui/art/skillsadvisor/advisor_tabicon_settings_up.dds",
			LibRadialMenu.openSettings,
			GetString(SI_LIBRADIALMENU_OPEN_SETTINGS_TOOLTIP))
	end




	local settingsTable = {
		{
			type = LibHarvensAddonSettings.ST_SLIDER,
			label = GetString(SI_LIBRADIALMENU_WHEEL_INDEX),
			tooltip = GetString(SI_LIBRADIALMENU_WHEEL_INDEX_TOOLTIP),
			setFunction = function(value)
				LibRadialMenu.vars.wheelIndex = value
				LibRadialMenu.resetTable()
				LibRadialMenu.insertWheelAtIndex(value)
			end,
			getFunction = function()
				return LibRadialMenu.vars.wheelIndex
			end,
			default = 6,
			min = 0,
			max = 6,
			step = 1,
		},
		{
			type = LibHarvensAddonSettings.ST_SLIDER,
			label = GetString(SI_LIBRADIALMENU_NUM_SLOTS),
			tooltip = GetString(SI_LIBRADIALMENU_NUM_SLOTS_TOOLTIP),
			setFunction = function(value)
				LibRadialMenu.vars.numSlots = value
			end,
			getFunction = function()
				return LibRadialMenu.vars.numSlots
			end,
			default = 12,
			min = 2,
			max = 25,
			step = 1,
		},
		{
			type = LibHarvensAddonSettings.ST_BUTTON,
			label = GetString(SI_LIBRADIALMENU_REFRESH_MENU),
			tooltip = GetString(SI_LIBRADIALMENU_REFRESH_MENU_TOOLTIP),
			clickHandler = LibRadialMenu.UpdateSettingsMenu,
		},
		{
			type = LibHarvensAddonSettings.ST_SECTION,
			label = GetString(SI_LIBRADIALMENU_ASSIGN_SLOTS_HEADER),
		},
	}


	for i,v in pairs(LibRadialMenu.vars.slots) do
		if i > LibRadialMenu.vars.numSlots then
			LibRadialMenu.vars.slots[i] = nil
		end
	end

	for i=1,LibRadialMenu.vars.numSlots do
		if (type(LibRadialMenu.vars.slots[i]) ~= "table") then
			LibRadialMenu.vars.slots[i] = {}
		end
	end

	LibRadialMenu.libRadialWheelEntries = LibRadialMenu.vars.slots

	for i=1,#LibRadialMenu.libRadialWheelEntries do
		settingsTable[#settingsTable+1] = {
			type = LibHarvensAddonSettings.ST_BUTTON,
			label = function()
				return getLabel(LibRadialMenu.libRadialWheelEntries[i], i)
			end,
			buttonText = GetString(SI_GAMEPAD_ITEM_ACTION_QUICKSLOT_ASSIGN), 
			tooltip = function()
				return getTooltip(LibRadialMenu.libRadialWheelEntries[i])
			end,
			clickHandler = function() ZO_Dialogs_ShowPlatformDialog("LibProfileAssignDialogue", {slotIndex=i}) end,
		}
	end

	if LibRadialMenu.isCN then
		local lookup = {
			[GetString(SI_LIBRADIALMENU_TRADCN)] = "tradcn",
			[GetString(SI_LIBRADIALMENU_SIMPLECN)] = "simplecn",
			["tradcn"] = GetString(SI_LIBRADIALMENU_TRADCN),
			["simplecn"] = GetString(SI_LIBRADIALMENU_SIMPLECN),
		}

		table.insert(settingsTable, 1, {
			type = LibHarvensAddonSettings.ST_DROPDOWN,
			items = {
				{name = GetString(SI_LIBRADIALMENU_SIMPLECN), data = "simplecn"},
				{name = GetString(SI_LIBRADIALMENU_TRADCN), data = "tradcn"},
			},
			label = GetString(SI_LIBRADIALMENU_TRANSLATEDBY),
			getFunction = function()
				return lookup[LibRadialMenu.vars.cntype] or GetString(SI_LIBRADIALMENU_SIMPLECN)
			end,
			setFunction = function(control, itemName, itemData)
				LibRadialMenu.vars.cntype = itemData.data or "simplecn"
				LibRadialMenu.UpdateSettingsMenu()
			end,
		})
	elseif GetString(SI_LIBRADIALMENU_TRANSLATEDBY) ~= "" then
		table.insert(settingsTable, 1, {
			type = LibHarvensAddonSettings.ST_SECTION,
			label = GetString(SI_LIBRADIALMENU_TRANSLATEDBY),
		})
	end

	settings:AddSettings(settingsTable)
	if LibHarvensAddonSettings.list then
		settings:CreateControls()
	end

end


LibRadialMenu:RegisterEntry("libradialmenu", GetString(SI_LIBRADIALMENU_OPEN_SETTINGS), "opensettings", "esoui/art/skillsadvisor/advisor_tabicon_settings_up.dds",
	LibRadialMenu.openSettings,
	GetString(SI_LIBRADIALMENU_OPEN_SETTINGS_TOOLTIP))