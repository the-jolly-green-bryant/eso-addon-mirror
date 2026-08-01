local ADDON_NAME = "AdvancedGuildRosterFilters"

local nextEventHandleIndex = 1

local function RegisterForEvent(event, callback)
	local eventHandleName = ADDON_NAME .. nextEventHandleIndex
	EVENT_MANAGER:RegisterForEvent(eventHandleName, event, callback)
	nextEventHandleIndex = nextEventHandleIndex + 1
	return eventHandleName
end

local function UnregisterForEvent(event, name)
	EVENT_MANAGER:UnregisterForEvent(name, event)
end

local function OnAddonLoaded(callback)
	local eventHandle = ""
	eventHandle = RegisterForEvent(EVENT_ADD_ON_LOADED, function(event, name)
		if(name ~= ADDON_NAME) then return end
		callback()
		UnregisterForEvent(event, name)
	end)
end

-----------------------------------------------------------------------------------------
local GUILD_MEMBER_DATA = 1
local CONTROL_NAME_PREFIX = "ZO_GuildRosterFilter"
local manager, roster

local defaultData = {
	version = 1,
	allianceFilter = {
		[ALLIANCE_EBONHEART_PACT] = true,
		[ALLIANCE_DAGGERFALL_COVENANT] = true,
		[ALLIANCE_ALDMERI_DOMINION] = true,
	},
	statusFilter = {
		[PLAYER_STATUS_ONLINE] = true,
		[PLAYER_STATUS_AWAY] = true,
		[PLAYER_STATUS_DO_NOT_DISTURB] = true,
		[PLAYER_STATUS_OFFLINE] = true,
	},
}
local saveData
local allianceFilterButtons = {}
local statusFilterButtons = {}

local function RefreshFilters()
	roster:RefreshFilters()
end

local function CreateCheckButton(name, texture, offsetX, offsetY, checked, toggleFunction)
	local button = CreateControlFromVirtual(CONTROL_NAME_PREFIX .. name, ZO_GuildRoster, "ZO_CheckButton")
	button:SetAnchor(TOPLEFT, ZO_GuildRoster, TOPLEFT, offsetX, offsetY)
	if(checked) then ZO_CheckButton_SetChecked(button) end
	ZO_CheckButton_SetToggleFunction(button, toggleFunction)
	ZO_CheckButton_SetLabelText(button, zo_iconFormat(texture, 32, 32))
	return button
end

local function CreateAllianceFilterButton(name, alliance, offsetX, offsetY)
	local button = CreateCheckButton(name, GetAllianceSymbolIcon(alliance), offsetX, offsetY, saveData.allianceFilter[alliance], function(control, checked)
		saveData.allianceFilter[alliance] = checked
		RefreshFilters()
	end)
	return button
end

local function CreateStatusFilterButton(name, status, offsetX, offsetY)
	local button = CreateCheckButton(name, GetPlayerStatusIcon(status), offsetX, offsetY, saveData.statusFilter[status], function(control, checked)
		saveData.statusFilter[status] = checked
		RefreshFilters()
	end)
	return button
end

local function CreateFilterCheckboxes()
	allianceFilterButtons[ALLIANCE_EBONHEART_PACT] = CreateAllianceFilterButton("EPButton", ALLIANCE_EBONHEART_PACT, 350, 8)
	allianceFilterButtons[ALLIANCE_DAGGERFALL_COVENANT] = CreateAllianceFilterButton("DCButton", ALLIANCE_DAGGERFALL_COVENANT, 420, 8)
	allianceFilterButtons[ALLIANCE_ALDMERI_DOMINION] = CreateAllianceFilterButton("ADButton", ALLIANCE_ALDMERI_DOMINION, 490, 8)

	statusFilterButtons[PLAYER_STATUS_ONLINE] = CreateStatusFilterButton("OnlineButton", PLAYER_STATUS_ONLINE, 350, 34)
	statusFilterButtons[PLAYER_STATUS_AWAY] = CreateStatusFilterButton("AfkButton", PLAYER_STATUS_AWAY, 420, 34)
	statusFilterButtons[PLAYER_STATUS_DO_NOT_DISTURB] = CreateStatusFilterButton("DndButton", PLAYER_STATUS_DO_NOT_DISTURB, 490, 34)
	statusFilterButtons[PLAYER_STATUS_OFFLINE] = CreateStatusFilterButton("OfflineButton", PLAYER_STATUS_OFFLINE, 560, 34)
end

local function AdvancedFilterScrollList(self)
	local scrollData = ZO_ScrollList_GetDataList(self.list)
	ZO_ClearNumericallyIndexedTable(scrollData)

	local searchTerm = self.searchBox:GetText()

	local masterList = manager:GetMasterList()
	for i = 1, #masterList do
		local data = masterList[i]

		if(not saveData.statusFilter[data.status]) then
		elseif(not saveData.allianceFilter[data.alliance]) then
		-- ignore entry
		elseif(searchTerm == "" or manager:IsMatch(searchTerm, data)) then
			table.insert(scrollData, ZO_ScrollList_CreateDataEntry(GUILD_MEMBER_DATA, data))
		end
	end
end

OnAddonLoaded(function()
	if(not GUILD_ROSTER_MANAGER) then
		manager = GUILD_ROSTER
		roster = GUILD_ROSTER
		manager.IsMatch = function(self, searchTerm, data) return self.search:IsMatch(searchTerm, data) end
		manager.GetMasterList = function(self) return self.masterList end
	else
		manager = GUILD_ROSTER_MANAGER
		roster = GUILD_ROSTER_KEYBOARD
	end

	local characterName = GetUnitName("player")
	AdvancedGuildRosterFilters_Data = AdvancedGuildRosterFilters_Data or {}
	saveData = AdvancedGuildRosterFilters_Data[characterName] or ZO_DeepTableCopy(defaultData)
	AdvancedGuildRosterFilters_Data[characterName] = saveData

	CreateFilterCheckboxes()
	zo_callLater(RefreshFilters, 1000)
	roster.FilterScrollList = AdvancedFilterScrollList

	RegisterForEvent(EVENT_GUILD_MEMBER_ADDED, RefreshFilters)
	RegisterForEvent(EVENT_GUILD_MEMBER_REMOVED, RefreshFilters)
	RegisterForEvent(EVENT_GUILD_MEMBER_PLAYER_STATUS_CHANGED, RefreshFilters)
end)
