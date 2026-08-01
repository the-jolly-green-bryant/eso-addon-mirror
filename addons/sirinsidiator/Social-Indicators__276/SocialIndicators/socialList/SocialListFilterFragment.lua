local SocialListFilterFragment = ZO_Object:Subclass()
SocialIndicators.SocialListFilterFragment = SocialListFilterFragment

local DEFAULT_FILTER_DATA = {
	alliance = {
		[ALLIANCE_EBONHEART_PACT] = true,
		[ALLIANCE_DAGGERFALL_COVENANT] = true,
		[ALLIANCE_ALDMERI_DOMINION] = true,
	},
	status = {
		[PLAYER_STATUS_ONLINE] = true,
		[PLAYER_STATUS_AWAY] = true,
		[PLAYER_STATUS_DO_NOT_DISTURB] = true,
		[PLAYER_STATUS_OFFLINE] = true,
	},
}

function SocialListFilterFragment:New(...)
	local index = ZO_Object.New(self)
	index:Initialize(...)
	return index
end

function SocialListFilterFragment:Initialize(saveData)
	self.filterData = saveData.filters or {}
	saveData.filters = self.filterData

	self.control = WINDOW_MANAGER:CreateTopLevelWindow("SocialIndicatorsSocialListFilterContainer")
	self.control:SetHidden(true)
	self.control:SetAnchor(TOPLEFT, SocialIndicatorsSocialList, TOPLEFT, 360, 12)
	self.fragment = ZO_FadeSceneFragment:New(self.control, nil, 0)

	ZO_KeyboardFriendsListHideOffline:SetHidden(true)
	ZO_GuildRosterHideOffline:SetHidden(true)
    SetSetting(SETTING_TYPE_UI, UI_SETTING_SOCIAL_LIST_HIDE_OFFLINE, tostring(false))

	self.allianceFilterButtonContainer = self.control:CreateControl("$(parent)AllianceFilter", CT_CONTROL)
	self.allianceFilterButtonContainer:SetAnchor(TOPLEFT)
	self.allianceFilterButtonContainer.buttons = {}
	self:CreateAllianceFilterButton("$(parent)EPButton", ALLIANCE_EBONHEART_PACT)
	self:CreateAllianceFilterButton("$(parent)DCButton", ALLIANCE_DAGGERFALL_COVENANT)
	self:CreateAllianceFilterButton("$(parent)ADButton", ALLIANCE_ALDMERI_DOMINION)

	self.statusFilterButtonContainer = self.control:CreateControl("$(parent)StatusFilter", CT_CONTROL)
	self.statusFilterButtonContainer:SetAnchor(TOPLEFT, self.allianceFilterButtonContainer, BOTTOMLEFT, 0, 26)
	self.statusFilterButtonContainer.buttons = {}
	self:CreateStatusFilterButton("$(parent)OnlineButton", PLAYER_STATUS_ONLINE)
	self:CreateStatusFilterButton("$(parent)AfkButton", PLAYER_STATUS_AWAY)
	self:CreateStatusFilterButton("$(parent)DndButton", PLAYER_STATUS_DO_NOT_DISTURB)
	self:CreateStatusFilterButton("$(parent)OfflineButton", PLAYER_STATUS_OFFLINE)
end

function SocialListFilterFragment:InitializeSocialListFiltering(SOCIAL_LIST_SCENE, socialListFragment)
	local socialListManager = socialListFragment.list
	local filterData = self.filterData.socialList or ZO_DeepTableCopy(DEFAULT_FILTER_DATA)
	self.filterData.socialList = filterData
	local isReady = false

	local function RefreshSocialList()
		socialListManager:RefreshFilters()
	end

	local socialListScene = SCENE_MANAGER:GetScene("socialList")
	socialListScene:RegisterCallback("StateChange", function(oldState, newState)
		if(socialListScene:IsShowing()) then
			self.currentRefreshFunction = RefreshSocialList
			self.currentFilterData = filterData
			isReady = true
			self:UpdateFilterButtons()
			RefreshSocialList()
		else
			isReady = false
		end
	end)

	socialListManager.AdvancedFilter = function(self, data) -- TODO: find better solution
		if(not isReady) then return true end
		local status = data.player and data.player.playerStatus or PLAYER_STATUS_OFFLINE
		local alliance = data.character and data.character.alliance or ALLIANCE_NONE
		if(not filterData.status[status] or not filterData.alliance[alliance]) then
			return false
		end
		return true
	end

    SOCIAL_LIST_SCENE:AddFragment(self.fragment)
end

function SocialListFilterFragment:InitializeFriendListFiltering()
	local friendListManager = FRIENDS_LIST_MANAGER
	local friendList = FRIENDS_LIST
	local filterData = self.filterData.friendList or ZO_DeepTableCopy(DEFAULT_FILTER_DATA)
	self.filterData.friendList = filterData
	local isReady = false

	local function RefreshFriendList()
		friendList:RefreshFilters()
	end

	local friendsListScene = SCENE_MANAGER:GetScene("friendsList")
	friendsListScene:RegisterCallback("StateChange", function(oldState, newState)
		if(friendsListScene:IsShowing()) then
			self.currentRefreshFunction = RefreshFriendList
			self.currentFilterData = filterData
			isReady = true
			self:UpdateFilterButtons()
			RefreshFriendList()
		else
			isReady = false
		end
	end)

	local currentSearchTerm, hasActiveAllianceFilter, hasActiveStatusFilter
	local originalGetSearchTerm = friendList.GetSearchTerm
	friendList.GetSearchTerm = function()
		if(not isReady) then return "" end
		hasActiveAllianceFilter = self:HasActiveAllianceFilter()
		hasActiveStatusFilter = self:HasActiveStatusFilter()
		currentSearchTerm = originalGetSearchTerm(friendList)
		return "\1" -- avoid the empty string check in FilterScrollList so IsMatch is called
	end

	local originalIsMatch = friendListManager.IsMatch
	friendListManager.IsMatch = function(self, searchTerm, data)
		if(not isReady) then return true end
		if(hasActiveAllianceFilter) then
			if(not filterData.alliance[data.alliance]) then
				return false
			end
		end

		if(hasActiveStatusFilter) then
			if(not filterData.status[data.status]) then
				return false
			end
		end

		if(currentSearchTerm ~= "") then
			return originalIsMatch(self, currentSearchTerm, data)
		end

		return true
	end

    FRIENDS_LIST_SCENE:AddFragment(self.fragment)
end

function SocialListFilterFragment:InitializeGuildRosterFiltering()
	local guildRosterManager = GUILD_ROSTER_MANAGER
	local guildRoster = GUILD_ROSTER_KEYBOARD
	local filterData = self.filterData.guildRoster or ZO_DeepTableCopy(DEFAULT_FILTER_DATA)
	self.filterData.guildRoster = filterData
	local isReady = false

	local function RefreshGuildRoster()
		guildRoster:RefreshFilters()
	end

	local guildRosterScene = SCENE_MANAGER:GetScene("guildRoster")
	guildRosterScene:RegisterCallback("StateChange", function(oldState, newState)
		if(guildRosterScene:IsShowing()) then
			self.currentRefreshFunction = RefreshGuildRoster
			self.currentFilterData = filterData
			isReady = true
			self:UpdateFilterButtons()
			RefreshGuildRoster()
		else
			isReady = false
		end
	end)

	local currentSearchTerm, hasActiveAllianceFilter, hasActiveStatusFilter
	local originalGetSearchTerm = guildRoster.searchBox.GetText
	guildRoster.searchBox.GetText = function(control)
		if(not isReady) then return "" end
		hasActiveAllianceFilter = self:HasActiveAllianceFilter()
		hasActiveStatusFilter = self:HasActiveStatusFilter()
		currentSearchTerm = originalGetSearchTerm(control)
		return "\1" -- avoid the empty string check in FilterScrollList so IsMatch is called
	end

	local originalIsMatch = guildRosterManager.IsMatch
	guildRosterManager.IsMatch = function(self, searchTerm, data)
		if(not isReady) then return true end
		if(hasActiveAllianceFilter) then
			if(not filterData.alliance[data.alliance]) then
				return false
			end
		end

		if(hasActiveStatusFilter) then
			if(not filterData.status[data.status]) then
				return false
			end
		end

		if(currentSearchTerm ~= "") then
			return originalIsMatch(self, currentSearchTerm, data)
		end

		return true
	end

    GUILD_ROSTER_SCENE:AddFragment(self.fragment)
end

function SocialListFilterFragment:CreateFilterButton(name, container)
	local buttons = container.buttons
	local button = CreateControlFromVirtual(name, container, "ZO_CheckButton")
	if(#buttons == 0) then
		button:SetAnchor(TOPLEFT, container, TOPLEFT, 0, 0)
	else
		button:SetAnchor(LEFT, buttons[#buttons], RIGHT, 50, 0)
	end
	buttons[#buttons + 1] = button
	return button
end

function SocialListFilterFragment:CreateAllianceFilterButton(name, alliance)
	local button = self:CreateFilterButton(name, self.allianceFilterButtonContainer)
	button.alliance = alliance
	ZO_CheckButton_SetToggleFunction(button, function(control, checked)
		self:SetAllianceFilter(alliance, checked)
	end)
	ZO_CheckButton_SetLabelText(button, zo_iconFormat(GetAllianceSymbolIcon(alliance), 32, 32))
end

function SocialListFilterFragment:SetAllianceFilter(alliance, checked)
	self.currentFilterData.alliance[alliance] = checked
	self.currentRefreshFunction()
end

function SocialListFilterFragment:CreateStatusFilterButton(name, status)
	local button = self:CreateFilterButton(name, self.statusFilterButtonContainer)
	button.playerStatus = status
	ZO_CheckButton_SetToggleFunction(button, function(control, checked)
		self:SetStatusFilter(status, checked)
	end)
	ZO_CheckButton_SetLabelText(button, zo_iconFormat(GetPlayerStatusIcon(status), 32, 32))
end

function SocialListFilterFragment:SetStatusFilter(status, checked)
	self.currentFilterData.status[status] = checked
	self.currentRefreshFunction()
end

local function HasActiveFilter(buttons, states, fieldName)
	local button
	for i = 1, #buttons do
		button = buttons[i]
		if(not states[buttons[i][fieldName]]) then return true end
	end
	return false
end

function SocialListFilterFragment:HasActiveAllianceFilter()
	return HasActiveFilter(self.allianceFilterButtonContainer.buttons, self.currentFilterData.alliance, "alliance")
end

function SocialListFilterFragment:HasActiveStatusFilter()
	return HasActiveFilter(self.statusFilterButtonContainer.buttons, self.currentFilterData.status, "playerStatus")
end

local function DoUpdateFilterButtons(buttons, states, fieldName)
	local button
	for i = 1, #buttons do
		button = buttons[i]
		if(states[button[fieldName]]) then
			ZO_CheckButton_SetChecked(button)
		else
			ZO_CheckButton_SetUnchecked(button)
		end
	end
end

function SocialListFilterFragment:UpdateFilterButtons()
	DoUpdateFilterButtons(self.allianceFilterButtonContainer.buttons, self.currentFilterData.alliance, "alliance")
	DoUpdateFilterButtons(self.statusFilterButtonContainer.buttons, self.currentFilterData.status, "playerStatus")
end
