RaidToolsModules_History = {}

local DATA = 1;

RaidToolsRaidHistory = {}
ZO_CreateStringId("SI_RTH_TITLE" , "RaidTools History")

RT_History = ZO_SortFilterList:Subclass()
RT_History.defaults = {}
RT_History.sortKeys =  {
	["raid_name"] = {caseInsensitive = true},
	["char_name"] = {caseInsensitive = true},
	["time"] = { isNumeric = true},
	["score"] = { isNumeric = true},
	["hardmode"] = { isNumeric = true},
	["speedrun"] = { isNumeric = true},
	["date"] = { isNumeric = true},
	["deaths"] = { isNumeric = true},
}

local ToolTipWindow

function RaidToolsModules_History.Init() 
	RaidToolsModules_History.ui = RT_History:New(RTHistoryFrame)
	CreateTooltipWindow()
end

function RaidToolsModules_History.Toggle()
	if (RTHistoryFrame:IsControlHidden()) then
		RT_History:RefreshData()
		SCENE_MANAGER:Show("RTHistoryScene")
	else
		SCENE_MANAGER:Hide("RTHistoryScene")
	end
end

function RT_History:New(control)
	--control = ZO_SortFilterList.New(self, RTHistoryFrame)
	ZO_SortFilterList.InitializeSortFilterList(self, control)
	self.masterList = {}

	ZO_ScrollList_AddDataType(self.list, 1, "RTHistoryRow", 30, function(control, data) self:SetupItemRow(control, data) end)
	ZO_ScrollList_EnableHighlight(self.list, "ZO_ThinListHighlight")
	self:SetAlternateRowBackgrounds(true)

	self.currentSortKey = "raid_name"
	self.currentSortOrder = ZO_SORT_ORDER_UP
	self.sortHeaderGroup:SelectAndResetSortForKey(self.currentSortKey)
	self.sortFunction = function( listEntry1, listEntry2 )
		return(ZO_TableOrderingFunction(listEntry1.data, listEntry2.data, self.currentSortKey, self.sortKeys, self.currentSortOrder))
	end

	self.searchBox = RTHistoryFrame:GetNamedChild("SearchBox")
	self.searchBox:SetHandler("OnTextChanged", function() self:RefreshFilters() end)
	self.search = ZO_StringSearch:New()
	self.search:AddProcessor(1, function(stringSearch, data, searchTerm, cache) return(self:ProcessItemEntry(stringSearch, data, searchTerm, cache)) end)

	self.scene = ZO_Scene:New("RTHistoryScene", SCENE_MANAGER)
	self.scene:AddFragment(ZO_SetTitleFragment:New(SI_RTH_TITLE))
	self.scene:AddFragment(ZO_FadeSceneFragment:New(RTHistoryFrame))
	self.scene:AddFragment(TITLE_FRAGMENT)
	self.scene:AddFragment(RIGHT_BG_FRAGMENT)
	self.scene:AddFragment(FRAME_EMOTE_FRAGMENT_JOURNAL)
	self.scene:AddFragment(CODEX_WINDOW_SOUNDS)
	self.scene:AddFragmentGroup(FRAGMENT_GROUP.MOUSE_DRIVEN_UI_WINDOW)
	self.scene:AddFragmentGroup(FRAGMENT_GROUP.FRAME_TARGET_STANDARD_RIGHT_PANEL)
	self:RefreshData()
	return self
end

local function SetupMasterListRow(t, data)
	t.raid_id = data.raid_id
	t.raid_name = data.raid_name
	t.char_name = data.char_name
	t.time = data.time
	t.score = data.score
	t.speedrun = (data.speed_run_failed == false)
	t.hardmode = data.hard_mode
	t.hard_mode_param = data.hard_mode_param
	t.date = data.timestamp
	t.deaths = data.deaths
	t.players = data.players
end

function RT_History:BuildMasterList()
	self.masterList = {}

	for i = 1, #RaidTools.storage.raid_history do
		local data = {}
		SetupMasterListRow(data, RaidTools.storage.raid_history[i])
		table.insert(self.masterList, data)
	end
end

function RT_History:FilterScrollList()
	local scrollData = ZO_ScrollList_GetDataList(self.list)
	ZO_ClearNumericallyIndexedTable(scrollData)

	local searchInput = self.searchBox:GetText() or ''

	for i = 1, #self.masterList do
		local data = self.masterList[i]
		if searchInput == '' or self:CheckForMatch(data, searchInput) then
			table.insert(scrollData, ZO_ScrollList_CreateDataEntry(1, data))
		end
	end

	if (#scrollData ~= #self.masterList) then
		RTHistoryFrame:GetNamedChild("Counter"):SetText(string.format("%d / %d", #scrollData, #self.masterList))
	else
		RTHistoryFrame:GetNamedChild("Counter"):SetText("")
	end
end

function RT_History:SortScrollList()
	if (self.currentSortKey ~= nil and self.currentSortOrder ~= nil and self.list ~= nil) then
		local scrollData = ZO_ScrollList_GetDataList(self.list);
		table.sort(scrollData, self.sortFunction);
	end
end

local white = ZO_ColorDef:New('ffffff')

function RT_History:SetupItemRow(control, data)
	control.data = data
 	data.raid_name = data.raid_name:gsub('%((.*)%)', '')
	control:GetNamedChild("RaidName").normalColor = white
	control:GetNamedChild("RaidName"):SetText(data.raid_name)

	control:GetNamedChild("CharName").normalColor = white
	control:GetNamedChild("CharName"):SetText(data.char_name)

	control:GetNamedChild("Time").normalColor = white
	control:GetNamedChild("Time"):SetText(ZO_FormatTime(data.time/1000))

	control:GetNamedChild("Score").normalColor = white
	control:GetNamedChild("Score"):SetText(ZO_CommaDelimitNumber(data.score))

	control:GetNamedChild("Deaths").normalColor = white
	control:GetNamedChild("Deaths"):SetText(ZO_CommaDelimitNumber(data.deaths))

	control:GetNamedChild("Speedrun").normalColor = white
	control:GetNamedChild("Speedrun"):SetText(bool2yesno(data.speedrun))

	control:GetNamedChild("Hardmode").normalColor = white
	if RaidTools.IsNoTrashRaid(data.raid_id) then
		local hm_diff_indicator = -1
		if data.raid_id == TRIAL_CLOUDREST then
			hm_diff_indicator = 3-data.hard_mode_param
		elseif data.raid_id == TRIAL_ASYLUM_SANCTORIUM then
			hm_diff_indicator = 2-data.hard_mode_param
		end
		control:GetNamedChild("Hardmode"):SetText('+'..hm_diff_indicator)
	else
		control:GetNamedChild("Hardmode"):SetText(bool2yesno(data.hardmode))
	end

	control:GetNamedChild("Date").normalColor = white
	data.date_string = GetDateStringFromTimestamp(data.date).. ' ' .. FormatTimeSeconds(data.date, TIME_FORMAT_STYLE_CLOCK_TIME, TIME_FORMAT_PRECISION_TWENTY_FOUR_HOUR, TIME_FORMAT_DIRECTION_ASCENDING)
	control:GetNamedChild("Date"):SetText(data.date_string)

	ZO_SortFilterList.SetupRow(self, control, data)
end

function RT_History:CheckForMatch(data, searchInput)
	return (zo_plainstrfind(data.raid_name:lower(), searchInput) or zo_plainstrfind(data.char_name:lower(), searchInput))
end

local function tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

function RTHistoryRow_OnMouseEnter(control)
	RaidToolsModules_History.ui:Row_OnMouseEnter(control)
	local data = control.data

	if data.players and type(data.players) == 'table' and tablelength(data.players) > 0 then
		local text = ''
		for player, deaths in pairs(data.players) do 
			if deaths == -1 or not deaths then
				deaths = '0'
			end
			text = text..'- '..player..' || Deaths: '..deaths..'\n'
		end
		ToolTipWindow.players:SetText(text)
	else
		ToolTipWindow.players:SetText('- No player information available')
	end
	ToolTipWindow:SetHidden(false)
	--ToolTipWindow.fragment:SetHiddenForReason("HideRaidToolsRTHistory", false)
end

function RTHistoryRow_OnMouseExit(control)
	RaidToolsModules_History.ui:Row_OnMouseExit(control)
	--ToolTipWindow.fragment:SetHiddenForReason("HideRaidToolsRTHistory", true)
	ToolTipWindow:SetHidden(true)
end

function RTHistoryRow_OnMouseUp(control)
	local data = control.data
	local message = string.format('<RaidTools> %s || Score: %s (Hardmode: %s), Time: %s (Speedrun: %s), Deaths: %s || %s', data.raid_name, ZO_CommaDelimitNumber(data.score), control:GetNamedChild("Hardmode"):GetText(),ZO_FormatTime(data.time/1000), bool2yesno(data.speedrun), ZO_CommaDelimitNumber(data.deaths), data.date_string)
	CHAT_SYSTEM.textEntry:SetText( message )
	CHAT_SYSTEM:Maximize()
	CHAT_SYSTEM.textEntry:Open()
	CHAT_SYSTEM.textEntry:FadeIn()
end

function CreateTooltipWindow()
	ToolTipWindow = RaidTools.WM:CreateTopLevelWindow("RaidToolsRTHistory")
	ToolTipWindow:SetDimensions(400, 400)
	ToolTipWindow:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, 500, 250)
	ToolTipWindow:SetClampedToScreen(true)
	ToolTipWindow:SetMouseEnabled(false)
	ToolTipWindow:SetMovable(false)
	ToolTipWindow:SetHidden(true)
	ToolTipWindow:SetAlpha(1)
	
	ToolTipWindow.background = RaidTools.WM:CreateControl(nil, ToolTipWindow, CT_BACKDROP)
	ToolTipWindow.background:SetAnchorFill(ToolTipWindow)
	ToolTipWindow.background:SetEdgeTexture(nil, 1, 1, 1.0, 1.0)
	ToolTipWindow.background:SetCenterColor(0.0, 0.0, 0.0, 0.6)
	ToolTipWindow.background:SetEdgeColor(255, 255, 255, 0.8)

	ToolTipWindow.label = RaidTools.WM:CreateControl(nil, ToolTipWindow, CT_LABEL)
	ToolTipWindow.label:SetDimensions(300, 25)
	ToolTipWindow.label:SetAnchor(TOPLEFT, ToolTipWindow, TOPLEFT, 5, 0)
	ToolTipWindow.label:SetFont('ZoFontConversationOption')
	ToolTipWindow.label:SetText('Players:')

	ToolTipWindow.players = RaidTools.WM:CreateControl(nil, ToolTipWindow, CT_LABEL)
	ToolTipWindow.players:SetDimensions(400, 400)
	ToolTipWindow.players:SetAnchor(TOPLEFT, ToolTipWindow, TOPLEFT, 10, 25)
	ToolTipWindow.players:SetFont('ZoFontConversationOption')
	ToolTipWindow.players:SetText('- No player information available')

	--ToolTipWindow.fragment = ZO_HUDFadeSceneFragment:New(RaidToolsModules_History.ui)
	--HUD_SCENE:AddFragment(ToolTipWindow.fragment)
    --HUD_UI_SCENE:AddFragment(ToolTipWindow.fragment)
    --ToolTipWindow.fragment:SetHiddenForReason("HideRaidToolsRTHistory", true)
    ToolTipWindow:SetHidden(true)
end