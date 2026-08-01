local ShowPlayerDetailInfoTooltip = SocialIndicators.ShowPlayerDetailInfoTooltip
local HidePlayerDetailInfoTooltip = SocialIndicators.HidePlayerDetailInfoTooltip

local SocialListFragment = ZO_Object:Subclass()
SocialIndicators.SocialListFragment = SocialListFragment

local PLAYER_DATA = 1

function SocialListFragment:New(db)
	local index = ZO_Object.New(self)
	index:Initialize(db)
	return index
end

function SocialListFragment:Initialize(db)
	self.db = db
	self.control = SocialIndicatorsSocialList
	self.fragment = ZO_FadeSceneFragment:New(self.control, nil, 0)

	self.searchBox = GetControl(self.control, "SearchBox")
	self.searchBox:SetHandler("OnTextChanged", function() self:OnSearchTextChanged() end)

	self.list = ZO_SortFilterList:New(self.control)
	self:InitializeSortFilterList(self.list)
end

function SocialListFragment:InitializeSortFilterList(list)
	list.totalCount = 0
	list.onlineCount = 0
	list.filteredTotalCount = nil
	list.filteredOnlineCount = nil

	list:SetAlternateRowBackgrounds(true)
	list:SetEmptyText(GetString(SI_FRIENDS_LIST_PANEL_NO_FRIENDS_MESSAGE))
	list.sortHeaderGroup:SelectHeaderByKey("status")

	ZO_ScrollList_AddDataType(list.list, PLAYER_DATA, "SocialIndicatorsSocialListRow", 30, function(control, data) self:SetupRow(control, data) end)
	ZO_ScrollList_EnableHighlight(list.list, "ZO_ThinListHighlight")

	local db = self.db
	local PLAYER_SEARCH = 1
	local masterList = {}
	function list:BuildMasterList()
		ZO_ClearNumericallyIndexedTable(masterList)

		local uniquesList = {}
		local player, character
		for characterName in pairs(db.characters) do
			player = db:GetPlayerForCharacter(characterName) -- this is necessary in order to get the current character
			player, character = db:GetPlayerAndCharacterFromCharacterOrDisplayName(player.displayName)
			if(player) then
				if(not uniquesList[player.displayName]) then
					masterList[#masterList + 1] = {
						type = PLAYER_SEARCH,
						player = player,
						character = character
					}
					uniquesList[player.displayName] = true
				end
			elseif(not uniquesList[character.characterName]) then
				masterList[#masterList + 1] = {
					type = PLAYER_SEARCH,
					player = player,
					character = character
				}
				uniquesList[character.characterName] =  true
			end
		end
	end

	local stringSearch = ZO_StringSearch:New()
	stringSearch:AddProcessor(PLAYER_SEARCH, function(stringSearch, data, searchTerm, cache)
		local lowerSearchTerm = searchTerm:lower()

		if((data.player and zo_plainstrfind(data.player.displayName:lower(), lowerSearchTerm))
			or (data.character and zo_plainstrfind(data.character.characterName:lower(), lowerSearchTerm))) then
			return true
		end
	end)

	local function ClearCallLater(id)
		EVENT_MANAGER:UnregisterForUpdate("CallLaterFunction"..id)
	end

	function list:AdvancedFilter(data) return true end -- this gets overwritten in the filter fragment TODO: find better solution

	local LTF = LibStub("LibTextFilter")

	local searchBox = self.searchBox
	local haystack = {}
	function list:FilterScrollList()
		local scrollData = ZO_ScrollList_GetDataList(list.list)
		ZO_ClearNumericallyIndexedTable(scrollData)

		local searchTerm = searchBox:GetText()
		local IsMatch
		if(searchTerm ~= "") then
			searchTerm = searchTerm:lower()
			local tokens = LTF:Tokenize(searchTerm)
			local parsedTokens = LTF:Parse(tokens)
			function IsMatch(data)
				haystack[1] = data.player and data.player.displayName:lower() or ""
				haystack[2] = data.character and data.character.characterName:lower() or ""
				local isMatch, result = LTF:Evaluate(table.concat(haystack, " "), ZO_ShallowTableCopy(parsedTokens))
				return isMatch
			end
		end

		local onlineCount, filteredTotalCount, filteredOnlineCount = 0, 0, 0
		local data, isOnline
		for i = 1, #masterList do
			data = masterList[i]
			isOnline = (data.player and data.player.playerStatus == PLAYER_STATUS_ONLINE)
			if(isOnline) then
				onlineCount = onlineCount + 1
			end
			if(self:AdvancedFilter(data) and (not IsMatch or IsMatch(data))) then
				filteredTotalCount = filteredTotalCount + 1
				if(isOnline) then
					filteredOnlineCount = filteredOnlineCount + 1
				end
				table.insert(scrollData, ZO_ScrollList_CreateDataEntry(PLAYER_DATA, data))
			end
		end
		list.totalCount = #masterList
		list.onlineCount = onlineCount
		if(filteredTotalCount < list.totalCount) then
			list.filteredTotalCount = filteredTotalCount
			list.filteredOnlineCount = filteredOnlineCount
		else
			list.filteredTotalCount = nil
			list.filteredOnlineCount = nil
		end

		CALLBACK_MANAGER:FireCallbacks("SocialIndicators_SocialListChanged", list.onlineCount, list.totalCount, list.filteredOnlineCount, list.filteredTotalCount)
	end

	local refreshFilterHandle
	local RefreshFilters = list.RefreshFilters
	local function DoFilter() RefreshFilters(list) end

	function list:RefreshFilters()
		if(refreshFilterHandle) then
			ClearCallLater(refreshFilterHandle)
		end
		refreshFilterHandle = zo_callLater(DoFilter, 250)
	end

	local function GetLastMet(data)
		if(data.player) then
			if(data.player.lastMet > 0) then
				return data.player.lastMet
			end
		elseif(data.character) then
			if(data.character.lastMet > 0) then
				return data.character.lastMet
			end
		end
	end

	local function GetLastSeen(data)
		if(data.player) then
			if(data.player.lastSeen > 0) then
				return data.player.lastSeen
			end
		elseif(data.character) then
			if(data.character.lastSeen > 0) then
				return data.character.lastSeen
			end
		end
	end

	local function SortPlayers(listEntry1, listEntry2)
		local data1, data2 = listEntry1.data, listEntry2.data
		local value1, value2
		if(list.currentSortKey == "status") then
			value1 = GetLastMet(data1)
			value2 = GetLastMet(data2)
			if(not value1 and not value2) then
				value1 = GetLastSeen(data1)
				value2 = GetLastSeen(data2)
			end
			value1 = value1 or 0
			value2 = value2 or 0
		elseif(list.currentSortKey == "alliance") then
			value1 = data1.character and data1.character.alliance or 0
			value2 = data2.character and data2.character.alliance or 0
		elseif(list.currentSortKey == "friend") then
			value1 = (data1.player and data1.player:IsFriend()) and 1 or 0
			value2 = (data2.player and data2.player:IsFriend()) and 1 or 0
		elseif(list.currentSortKey == "guild") then
			value1 = (data1.player and data1.player:IsGuildMate()) and 1 or 0
			value2 = (data2.player and data2.player:IsGuildMate()) and 1 or 0
		elseif(list.currentSortKey == "group") then
			value1 = (data1.character and data1.character:IsGrouped()) and 1 or 0
			value2 = (data2.character and data2.character:IsGrouped()) and 1 or 0
		elseif(list.currentSortKey == "displayName") then
			value1 = data1.player and data1.player.displayName or ""
			value2 = data2.player and data2.player.displayName or ""
		elseif(list.currentSortKey == "characterName") then
			value1 = data1.character and data1.character.characterName or ""
			value2 = data2.character and data2.character.characterName or ""
		elseif(list.currentSortKey == "class") then
			value1 = data1.character and data1.character.class or 0
			value2 = data2.character and data2.character.class or 0
		elseif(list.currentSortKey == "level") then -- TODO: sort like in guild roster and friend list
			value1 = data1.character and data1.character.level + data1.character:GetChampionPoints()
			value2 = data2.character and data2.character.level + data2.character:GetChampionPoints()
		else
			return false
		end
		if(list.currentSortOrder == ZO_SORT_ORDER_DOWN) then
			return value1 < value2
		else
			return value1 > value2
		end
	end

	function list:SortScrollList()
		if(self.currentSortKey ~= nil and self.currentSortOrder ~= nil) then
			local scrollData = ZO_ScrollList_GetDataList(self.list)
			table.sort(scrollData, SortPlayers)
		end

		self:RefreshVisible()
	end

	function list:ColorRow(control, data, mouseIsOver)
		local online = (data.player.playerStatus ~= PLAYER_STATUS_OFFLINE)
		local textColor = online and ZO_SECOND_CONTRAST_TEXT or ZO_DISABLED_TEXT
		local iconColor = online and ZO_DEFAULT_ENABLED_COLOR or ZO_DISABLED_TEXT

		local displayName = GetControl(control, "DisplayName")
		displayName:SetColor(textColor:UnpackRGBA())

		local friend = GetControl(control, "Friend")
		friend:SetColor(iconColor:UnpackRGBA())

		local guild = GetControl(control, "Guild")
		guild:SetColor(iconColor:UnpackRGBA())

		local group = GetControl(control, "Group")
		group:SetColor(iconColor:UnpackRGBA())

		if(data.character) then
			local alliance = GetControl(control, "Alliance")
			alliance:SetColor((online and data.character:GetAllianceColor() or iconColor):UnpackRGBA())

			local characterName = GetControl(control, "CharacterName")
			characterName:SetColor(textColor:UnpackRGBA())

			local champion = GetControl(control, "Champion")
			champion:SetColor(iconColor:UnpackRGBA())

			local level = GetControl(control, "Level")
			level:SetColor(textColor:UnpackRGBA())

			local class = GetControl(control, "Class")
			class:SetColor(iconColor:UnpackRGBA())
		end
	end
end

function SocialListFragment:RefreshData()
	self.list:RefreshData()
end

function SocialListFragment:SetupRow(control, data, selected)
	self.list:SetupRow(control, data)

	local player = data.player
	local displayName = GetControl(control, "DisplayName")
	displayName:SetText(player.displayName)

	local status = GetControl(control, "Status")
	status:SetTexture(player:GetStatusIcon())

	local friend = GetControl(control, "Friend")
	friend:SetHidden(not player:IsFriend())

	local guild = GetControl(control, "Guild")
	guild:SetHidden(not player:IsGuildMate())

	local note = GetControl(control, "Note")
	note:SetHidden(true)

	local group = GetControl(control, "Group")
	local characterName = GetControl(control, "CharacterName")
	local class = GetControl(control, "Class")
	local alliance = GetControl(control, "Alliance")
	local level = GetControl(control, "Level")
	local champion = GetControl(control, "Champion")
	local hideCharacterFields = not data.character

	group:SetHidden(hideCharacterFields)
	characterName:SetHidden(hideCharacterFields)
	class:SetHidden(hideCharacterFields)
	alliance:SetHidden(hideCharacterFields)
	level:SetHidden(hideCharacterFields)
	champion:SetHidden(hideCharacterFields)

	if(data.character) then
		local character = data.character
		group:SetHidden(not character:IsGrouped())

		characterName:SetText(character.characterName)

		if character:IsChampion() then
			level:SetText(character:GetChampionPoints())
			champion:SetTexture(GetChampionPointsIcon())
		else
			level:SetText(character.level)
			champion:SetHidden(true)
		end

		local allianceTexture = character:GetAllianceIcon()
		if(allianceTexture) then
			alliance:SetTexture(allianceTexture)
		else
			alliance:SetHidden(true)
		end

		local classTexture = character:GetClassIcon()
		if(classTexture) then
			class:SetTexture(classTexture)
		else
			class:SetHidden(true)
		end
	end
end

function SocialListFragment:OnSearchTextChanged()
	ZO_EditDefaultText_OnTextChanged(self.searchBox)
	self.list:RefreshFilters()
end

function SocialListFragment:OnRowEnter(control)
	local data = ZO_ScrollList_GetData(control)
	ShowPlayerDetailInfoTooltip(data.player, data.character, control)
	self.list:EnterRow(control)
end

function SocialListFragment:OnRowExit(control)
	HidePlayerDetailInfoTooltip()
	self.list:ExitRow(control)
end
