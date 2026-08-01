-----------------------------------------------------------------------------------------
-- Raffle Gold Tally
-----------------------------------------------------------------------------------------
-- Copyright (c) 2016 Calia1120
--
-- ALL RIGHTS RESERVED
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, -- EXPRESS OR IMPLIED, 
-- INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR 
-- PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE 
-- LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT 
-- OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER 
-- DEALINGS IN THE SOFTWARE.
--
-----------------------------------------------------------------------------------------
--Libraries
local LAM = LibStub("LibAddonMenu-2.0")
local LGH = LibStub("LibGuildHistory")

--Local constants
local rgt = {}
local ADDON_NAME = "RaffleGoldTally"
local ADDON_VERSION = "2.0"
local SAVEDVARS_VERSION = 1

local DEPOSITS_SORT_KEYS =
{
	["displayName"] = { },
	["gold"] = { tiebreaker = "displayName", isNumeric = true },
	["guildName"] = { tiebreaker = "displayName" },
	["eventTime"] = { tiebreaker = "displayName" },
}

--Local variables
local DepositsManager = ZO_SortFilterList:Subclass()
local DEPOSITS_MANAGER = nil

local Deposits = {}

local SavedVars
local Defaults =
{
	Cutoff				= false,
	UpdateOnLogin		= true,
	UpdateOnOpen		= true,
}

local initialActivation = true
local weekstartTime = nil
local depositsReady = false

--Deposits Manager class functions
function DepositsManager:New(control)
	local manager = ZO_SortFilterList.New(self, control)
	
	ZO_ScrollList_AddDataType(manager.list, 1, "RaffleGoldTallyDepositRow", 30, function(control, data) manager:SetupRow(control, data) end)
	ZO_ScrollList_EnableHighlight(manager.list, "ZO_ThinListHighlight")
	
	manager:SetAlternateRowBackgrounds(true)
	
	manager.control = control
	manager.cutoffButton = GetControl(control, "CutoffButton")
	manager.resultCount = GetControl(control, "ResultCount")
	manager.guildFilter = ZO_ComboBox_ObjectFromContainer(GetControl(control, "GuildFilter"))
	manager.guildFilter:SetSortsItems(false)
	manager.guildFilter:SetFont("ZoFontWinT1")
	manager.guildFilter:SetSpacing(4)
	manager.amountFilterBox = GetControl(control, "AmountFilterBox")
	manager.amountFilterBox:SetHandler("OnTextChanged", function(control) manager:OnSearchTextChanged(control) end)
	manager.nameFilterBox = GetControl(control, "NameFilterBox")
	manager.nameFilterBox:SetHandler("OnTextChanged", function(control) manager:OnSearchTextChanged(control) end)
	
	manager.masterList = {}
	
	manager:RefreshGuildDropdown()
	manager.sortHeaderGroup:SelectHeaderByKey("displayName")
	
	return manager
end

function DepositsManager:SetupRow(control, data)
	ZO_SortFilterList.SetupRow(self, control, data)

	control:SetHandler("OnMouseUp", function(control, button, upInside, linkText) self:OnRowMouseUp(control, button, upInside, linkText) end)
	
	local playerLink = ("|H0:display:%s|h%s|h"):format(data.displayName, data.displayName)
	GetControl(control, "Name"):SetText(data.sortIndex .. "  " .. playerLink)
	GetControl(control, "Gold"):SetText(data.gold)
	GetControl(control, "Guild"):SetText(data.guildName)
	GetControl(control, "Date"):SetText(GetDateStringFromTimestamp(data.eventTime))
end

function DepositsManager:BuildMasterList()
	ZO_ClearNumericallyIndexedTable(self.masterList)
	
	for _, deposit in ipairs(Deposits) do	
		table.insert(self.masterList, deposit)
	end
end

function DepositsManager:FilterScrollList()
	local scrollData = ZO_ScrollList_GetDataList(self.list)
	ZO_ClearNumericallyIndexedTable(scrollData)
	
	local guildFilter = self.guildFilter:GetSelectedItemData().guildName
	local amountFilter = self.amountFilterBox:GetText()
	local nameFilter = self.nameFilterBox:GetText():lower()
	local count = 0
	local total = 0
	
	for i = 1, #self.masterList do
		local data = self.masterList[i]
		if ((not guildFilter or data.guildName == guildFilter) and (amountFilter == "" or data.gold == tonumber(amountFilter)) and (nameFilter == "" or zo_plainstrfind(data.displayName:lower(), nameFilter)) and (not SavedVars.Cutoff or data.eventTime > weekstartTime)) then
			count = count + 1
			total = total + data.gold
			table.insert(scrollData, ZO_ScrollList_CreateDataEntry(1, data))
		end
	end
	
	self.resultCount:SetText(count .. " DEPOSITS (" .. total .. "|t16:16:EsoUI/Art/currency/currency_gold.dds|t)")
end

function DepositsManager:CompareRows(listEntry1, listEntry2)
	return ZO_TableOrderingFunction(listEntry1.data, listEntry2.data, self.currentSortKey, DEPOSITS_SORT_KEYS, self.currentSortOrder)
end

function DepositsManager:SortScrollList()
    if (self.currentSortKey ~= nil and self.currentSortOrder ~= nil) then
        local scrollData = ZO_ScrollList_GetDataList(self.list)
        if (#scrollData > 1) then table.sort(scrollData, function(listEntry1, listEntry2) return self:CompareRows(listEntry1, listEntry2) end) end
    end
end

function DepositsManager:ColorRow(control, data, mouseIsOver)

end

function DepositsManager:OnSearchTextChanged(control)
    ZO_EditDefaultText_OnTextChanged(control)
    self:RefreshFilters()
end

function DepositsManager:OnRowMouseUp(control, button, upInside, linkText)
	if (button == 2 and linkText) then
		if (not self.unlockSelectionCallback) then self.unlockSelectionCallback = function() self:UnlockSelection() end	end
		SetMenuHiddenCallback(self.unlockSelectionCallback)
		self:LockSelection()
	end
end

function DepositsManager:RefreshGuildDropdown()
	self.guildFilter:ClearItems()
	
	local entry = self.guildFilter:CreateItemEntry("ALL GUILDS", function() self:RefreshFilters() end)
	entry.guildName = nil
	self.guildFilter:AddItem(entry)
	
	for guildIndex = 1, GetNumGuilds() do
		local guildId = GetGuildId(guildIndex)
		local guildName = GetGuildName(guildId)
		local entry = self.guildFilter:CreateItemEntry(guildName, function() self:RefreshFilters() end)
		entry.guildName = guildName
		self.guildFilter:AddItem(entry)
	end
	
	self.guildFilter:SelectFirstItem()
end

function DepositsManager:PerformRaffle()
	local scrollData = ZO_ScrollList_GetDataList(self.list)
	local entries = #scrollData
	local winner = zo_random(1, entries)
	local displayName = scrollData[winner].data.displayName
	local playerLink = ("|H0:display:%s|h%s|h"):format(displayName, displayName)
	d(entries .. " entries. Raffle result is " .. winner .. ". The winner is [" .. playerLink .. "].")
	local ChatEditControl = CHAT_SYSTEM.textEntry.editControl
	if (not ChatEditControl:HasFocus()) then StartChatInput() end
	ChatEditControl:InsertText("Raffle Gold Tally has randomly chosen one of the " .. entries .. " entries, and the winner is #" .. winner .. ", ".. displayName .. ". Congratulations!")
end

--Functions
local function ProcessDeposits(guildId)
	local guildName = GetGuildName(guildId)
	local count = 0
	
	for i = 1, GetNumGuildEvents(guildId, GUILD_HISTORY_BANK) do
		local eventType, secsSinceEvent, displayName, gold = GetGuildEventInfo(guildId, GUILD_HISTORY_BANK, i)

		if (eventType == GUILD_EVENT_BANKGOLD_ADDED) then
			count = count + 1
			local eventTime = GetTimeStamp() - secsSinceEvent
			table.insert(Deposits, {guildName = guildName, displayName = displayName, gold = gold, eventTime = eventTime})	
		end
	end
	
	d("Processed " .. count .. " deposits in " .. guildName)
end

local function OnGuildHistoryBankComplete(guildId)
	ProcessDeposits(guildId)
	depositsReady = true
	DEPOSITS_MANAGER:RefreshData()
end

local function InitSettingsMenu()

	local panelData =
	{
		type = "panel",
		name = "Raffle Gold Tally",
		displayName = "Raffle Gold Tally",
		author = "Calia1120",
		version = ADDON_VERSION,
		slashCommand = "/raffle",
		registerForRefresh = true,
		registerForDefaults = true,
	}
	
	local optionsTable =
	{
		{
		type = "description",
		-- title = "Description",	--(optional)
		title = nil,	--(optional)
		text =  "Allows for easy tracking of guild gold deposits. Deposits can easily be sorted by guild, member, amount or date. \n \nHas the ability to filter by guild, member or amount, and will automatically calculate the total of the results. Also has a simple RNG draw function which will paste the results to the chatbox. \n \nAddon can be accessed by typing |c4EFFF6/raffle|r or setting a keybind.",
		width = "full",	--or "half" (optional)
		},
		{
		type = "header",
		name = "Update Deposits",
		width = "full",
		},		
		--UpdateOnLogin
		{
			type = "checkbox",
			name = "On Login",
			tooltip = "Update data automatically on player login",
			width = "half",
			getFunc = function() return SavedVars.UpdateOnLogin end,
			setFunc = function(state) SavedVars.UpdateOnLogin = state end,
			default = Defaults.UpdateOnLogin,
		},
		--UpdateOnOpen
		{
			type = "checkbox",
			name = "On Open",
			tooltip = "Update data automatically when opening Raffle Gold Tally",
			width = "half",
			getFunc = function() return SavedVars.UpdateOnOpen end,
			setFunc = function(state) SavedVars.UpdateOnOpen = state end,
			default = Defaults.UpdateOnOpen,
		},
		
	}	
	
	LAM:RegisterAddonPanel(ADDON_NAME, panelData)
	LAM:RegisterOptionControls(ADDON_NAME, optionsTable)
end

local function OnPlayerActivated(eventCode)	
	if (SavedVars.UpdateOnLogin and initialActivation) then RaffleGoldTallyUpdate() end
	initialActivation = false
end

local function onAddOnLoaded(eventCode, addonName)
	if (addonName ~= ADDON_NAME) then return end
	
	-- check if libAddonMenu is loaded, otherwise exit as settings menu will not work properly.
	if not LAM then d("Unable to load libAddonMenu for " .. ADDON_NAME); return; end
		
	SavedVars = ZO_SavedVars:New("RaffleGoldTally_SavedVariables", SAVEDVARS_VERSION, nil, Defaults)
	
	if (SavedVars.Cutoff) then ZO_CheckButton_SetCheckState(DEPOSITS_MANAGER.cutoffButton, true) end
	
	InitSettingsMenu()
	
	--slash commands
	SLASH_COMMANDS["/raffle"] = RaffleGoldTallyToggle
	
	--strings
	ZO_CreateStringId("SI_BINDING_NAME_RAFFLEGOLDTALLY_UPDATE", "Force data update")
	ZO_CreateStringId("SI_BINDING_NAME_RAFFLEGOLDTALLY_TOGGLE", "Show/Hide Raffle Gold Tally")
	
	--events		
	EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
	EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
end

--Keybinding Handlers
--weekstartTime values: 
--1410782400 --8AM EST on Monday Sep 15th 2014, DST in effect
--still need to determine how to handle settings for fall when DST not in effect. ? something in settings menu or secondary checkbox on UI.
function RaffleGoldTallyUpdate()
	depositsReady = false
	weekstartTime = 1410782400 --8AM EST on Monday Sep 15th 2014, DST in effect
	while weekstartTime + 604800 < GetTimeStamp() do weekstartTime = weekstartTime + 604800 end
	Deposits = {}
	DEPOSITS_MANAGER:RefreshData()
	DEPOSITS_MANAGER:RefreshGuildDropdown()
	LGH:RequestHistory(GUILD_HISTORY_BANK, OnGuildHistoryBankComplete)
end

function RaffleGoldTallyToggle()
	if (DEPOSITS_MANAGER.control:IsHidden()) then
		if (SavedVars.UpdateOnOpen) then RaffleGoldTallyUpdate() end
		DEPOSITS_MANAGER.control:SetHidden(false)
		DEPOSITS_MANAGER.control:BringWindowToTop()
	else
		DEPOSITS_MANAGER.control:SetHidden(true)
	end
end

--Global XML
function RaffleGoldTallyRowLabelField_OnMouseEnter(control)
	if (control:WasTruncated()) then
		InitializeTooltip(InformationTooltip, control, BOTTOM, 0, 0)
		SetTooltipText(InformationTooltip, control:GetText())
	end
	
	local row = control:GetParent()
	zo_callHandler(row, "OnMouseEnter")
end

function RaffleGoldTallyRowLabelField_OnMouseExit(control)
	ClearTooltip(InformationTooltip)
	
	local row = control:GetParent()
	zo_callHandler(row, "OnMouseExit")
end

function RaffleGoldTallyRowLabelField_OnLinkMouseUp(control, button, linkText)
	ZO_LinkHandler_OnLinkMouseUp(linkText, button, control)
	
	local row = control:GetParent()
	zo_callHandler(row, "OnMouseUp", button, true, linkText)
end

function RaffleGoldTallyRow_OnMouseEnter(control)	
	DEPOSITS_MANAGER:EnterRow(control)
end

function RaffleGoldTallyRow_OnMouseExit(control)
	DEPOSITS_MANAGER:ExitRow(control)
end

function RaffleGoldTallyResetFilters_OnMouseEnter(control)
	InitializeTooltip(InformationTooltip, control, BOTTOMRIGHT, 0, 0, TOPLEFT)
	SetTooltipText(InformationTooltip, "Reset Filters")
end

function RaffleGoldTallyResetFilters_OnMouseExit(control)
	ClearTooltip(InformationTooltip)
end

function RaffleGoldTallyResetFilters_OnClicked(self)
	DEPOSITS_MANAGER.guildFilter:SelectFirstItem()
	DEPOSITS_MANAGER.amountFilterBox:Clear()
	DEPOSITS_MANAGER.nameFilterBox:Clear()
end

function RaffleGoldTallyUpdate_OnMouseEnter(control)
	InitializeTooltip(InformationTooltip, control, BOTTOMLEFT, 0, 0, TOPRIGHT)
	SetTooltipText(InformationTooltip, "Update Deposits")
end

function RaffleGoldTallyUpdate_OnMouseExit(control)
	ClearTooltip(InformationTooltip)
end

function RaffleGoldTallyUpdate_OnClicked(self)
	RaffleGoldTallyUpdate()
end

function RaffleGoldTallyPerform_OnMouseEnter(control)
	InitializeTooltip(InformationTooltip, control, BOTTOMLEFT, 0, 0, TOPRIGHT)
	SetTooltipText(InformationTooltip, "Perform Raffle")
end

function RaffleGoldTallyPerform_OnMouseExit(control)
	ClearTooltip(InformationTooltip)
end

function RaffleGoldTallyPerform_OnClicked(self)
	DEPOSITS_MANAGER:PerformRaffle()
end

function RaffleGoldTallyDeposits_OnInitialized(self)
	DEPOSITS_MANAGER = DepositsManager:New(self)
end

function RaffleGoldTallyDepositsCloseButton_OnClicked(self)
	DEPOSITS_MANAGER.control:SetHidden(true)
end

function RaffleGoldTallyToggleCutoff(buttonControl, checked)
	SavedVars.Cutoff = checked
	DEPOSITS_MANAGER:RefreshFilters()
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, onAddOnLoaded)
