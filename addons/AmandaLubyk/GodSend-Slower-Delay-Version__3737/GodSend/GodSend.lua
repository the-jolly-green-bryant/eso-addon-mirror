-------------------------------------------------------------------------------
-- GodSend Safe Speed Version
-------------------------------------------------------------------------------
--
-- Copyright (c) 2014 Tim Billington (Focus23), continued by Amy Watts (Calia1120) 
-- through 2018, continued by Amanda Lubyk (AmandaLubyk) starting October 2023.
-- All rights reserved.
--
-- This Add-on is not created by, affiliated with or sponsored by ZeniMax Media
-- Inc. or its affiliates. The Elder Scrolls® and related logos are registered
-- trademarks or trademarks of ZeniMax Media Inc. in the United States and/or
-- other countries.
--
-- You can read the full terms at:
-- https://account.elderscrollsonline.com/add-on-terms
--
-------------------------------------------------------------------------------

-- Local Constants
local ADDON_NAME = "GodSend"
local ADDON_VERSION = "3.0.4"
local SAVEDVARS_NAME = "GodSend_SavedVars"
local SAVEDVARS_VERSION = 1

local GODSEND_DEBUG = false
local GODSEND_ACTIVE = false
local GODSEND_PAUSED = false

local GODSEND_WINDOW = nil
local GODSEND_COMPOSE = nil
local GODSEND_RECIPIENTS = nil


local RECIPIENTS_SORT_KEYS =
{
	["id"] = { isNumeric = true },
	["name"] = { tiebreaker = "id" },
	["rank"] = { tiebreaker = "id" },
	["mail"] = { tiebreaker = "id" },
	["rankIndex"] = { tiebreaker = "id", isNumeric = true }
}

-- Local Variables
local GodSendWindow = ZO_Object:Subclass()
local GodSendCompose = ZO_Object:Subclass()
local GodSendRecipients = ZO_SortFilterList:Subclass()

local Guilds = 
{
	["GuildNames"] = { },
	["GuildRanks"] = { },
	["GuildMembers"] = { }
}

local GuildChoice = {}

local CurrentMail = {}
local PendingMail = {}

local lastKnownRecipient = nil
local mailBoxOpen = false
local progressBarTotal = 0
local progressBarUnit = 0
local sentMailCount = 0
local recipientID = 0
local sendDelay = 5000

local DefaultVars = {}
local SavedVars

-- Menu Buttons
local menuBarButtons =
{
	{
		categoryName = SI_GODSEND_TITLE_COMPOSE,
		descriptor = "GodSendCompose",
		normal = "esoui/art/mail/mail_tabicon_compose_up.dds",
		pressed = "esoui/art/mail/mail_tabicon_compose_down.dds",
		highlight = "esoui/art/mail/mail_tabicon_compose_over.dds",
	},
	{
		categoryName = SI_GODSEND_TITLE_RECIPIENTS,
		descriptor = "GodSendRecipients",
		normal = "esoui/art/contacts/tabicon_friends_up.dds",
		pressed = "esoui/art/contacts/tabicon_friends_down.dds",
		highlight = "esoui/art/contacts/tabicon_friends_over.dds",
	},
}

-------------------------------------------------------------------------------
-- CONTROL WINDOW
-------------------------------------------------------------------------------
function GodSendWindow:New(control)
	local manager = ZO_Object.New(self)
	
	manager.control = control
	manager.menuBar = GetControl(control, "MenuBar")
	manager.menuBarLabel = GetControl(control, "MenuBarLabel")
	manager.body = GetControl(control, "Body")
	manager.visible = false
	manager.activeTab = "GodSendCompose"
	manager.labels = {}
	manager.tabs = {}
	
	for _, buttonData in ipairs(menuBarButtons) do
		buttonData.callback = function() manager:SetTab(buttonData.descriptor) end
		ZO_MenuBar_AddButton(manager.menuBar, buttonData)
		ZO_MenuBar_SetDescriptorEnabled(manager.menuBar, buttonData.descriptor, true)
		manager.labels[buttonData.descriptor] = GetString(buttonData.categoryName)
		manager.tabs[buttonData.descriptor] = CreateControlFromVirtual(buttonData.descriptor, manager.body, buttonData.descriptor)
	end
	
	ZO_MenuBar_SelectDescriptor(manager.menuBar, manager.activeTab)
	
    return manager
end

-- Window Tab Handlers
function GodSendWindow:SetTab(tabName)
	self.menuBarLabel:SetText(self.labels[tabName])
	self.menuBarLabel:SetAnchor(TOPRIGHT, GodSendWindowMenuBar, TOPRIGHT, -82 , 4)
	self.menuBarLabel:SetFont("ZoFontWinH3")
	self.tabs[self.activeTab]:SetHidden(true)
	self.tabs[tabName]:SetHidden(false)
	self.activeTab = tabName
end

function GodSendWindow:ShowTab(tabName, skipSound)
	if (not self.visible) then
		self.visible = true
		self.control:SetHidden(false)
		SCENE_MANAGER:SetInUIMode(true)
		if (not skipSound) then PlaySound(SOUNDS.SYSTEM_WINDOW_OPEN) end
	end
	
	if (self.activeTab ~= tabName) then
		if (not ZO_MenuBar_SelectDescriptor(self.menuBar, tabName, true)) then
			if (GODSEND_DEBUG) then d("MenuBar Error: activeTab ~= tabName. Selected 1st visible tab.") end
			ZO_MenuBar_SelectFirstVisibleButton(self.menuBar, true)
		end
	end
end

function GodSendWindow:Toggle()
    if (self.visible) then
        self:Hide()
    else
        self:ShowTab(self.activeTab)
    end
end

function GodSendWindow:ToggleTab(tabName)
    if (self.visible and self.activeTab == tabName) then
        self:Hide()
    else
        self:ShowTab(tabName)
    end
end

function GodSendWindow:Hide()
	if (self.visible) then
		self.visible = false
		self.control:SetHidden(true)
		SCENE_MANAGER:SetInUIMode(false)
		PlaySound(SOUNDS.SYSTEM_WINDOW_CLOSE)
	end
end

-------------------------------------------------------------------------------
-- CONTROL RECIPIENTS
-------------------------------------------------------------------------------
function GodSendRecipients:New(control)
	local manager = ZO_SortFilterList.New(self, control)
	
	ZO_ScrollList_AddDataType(manager.list, 1, "GodSendRecipientsRow", 30, function(control, data) manager:SetupRow(control, data) end)
	ZO_ScrollList_EnableHighlight(manager.list, "ZO_ThinListHighlight")
	
	manager:SetAlternateRowBackgrounds(true)
	
	manager.control = control
	manager.masterList = {}
	manager.sortHeaderGroup:SelectHeaderByKey("id")
	
	return manager
end

function GodSendRecipients:SetupRow(control, data)
	ZO_SortFilterList.SetupRow(self, control, data)
	
	control:SetHandler("OnMouseUp", function(control, button, upInside, linkText) self:OnRowMouseUp(control, button, upInside, linkText) end)
	
	local playerLink = ("|H0:display:%s|h%s|h"):format(data.name, data.name)
	GetControl(control, "ID"):SetText(data.id)
	GetControl(control, "Name"):SetText(playerLink)
	GetControl(control, "Rank"):SetText(data.rank)
	GetControl(control, "Mail"):SetText(data.mail)
	
	GetControl(control, "ID"):SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
end

function GodSendRecipients:BuildMasterList()
	ZO_ClearNumericallyIndexedTable(self.masterList)
	
	for _, data in ipairs(Guilds.GuildMembers) do
		table.insert(self.masterList, data)
	end
end

function GodSendRecipients:FilterScrollList()
    local scrollData = ZO_ScrollList_GetDataList(self.list)
    ZO_ClearNumericallyIndexedTable(scrollData)

    for i = 1, #self.masterList do
		local data = self.masterList[i]
		if data.mail ~= false then
		table.insert(scrollData, ZO_ScrollList_CreateDataEntry(1, data))
		else end
    end
end

function GodSendRecipients:CompareRows(listEntry1, listEntry2)
	return ZO_TableOrderingFunction(listEntry1.data, listEntry2.data, self.currentSortKey, RECIPIENTS_SORT_KEYS, self.currentSortOrder)
end

function GodSendRecipients:SortScrollList()
	local scrollData = ZO_ScrollList_GetDataList(self.list)
	
	if self.currentSortKey == "rank" then
		self.currentSortKey = "rankIndex"
	end
	
	table.sort(scrollData, function(listEntry1, listEntry2) return self:CompareRows(listEntry1, listEntry2) end)
end

function GodSendRecipients:ColorRow(control, data, mouseIsOver)

end

function GodSendRecipients:OnRowMouseUp(control, button, upInside, linkText)
	if (button == 2 and linkText) then
		if (not self.unlockSelectionCallback) then self.unlockSelectionCallback = function() self:UnlockSelection() end	end
		SetMenuHiddenCallback(self.unlockSelectionCallback)
		self:LockSelection()
	end
end

-------------------------------------------------------------------------------
-- CONTROL COMPOSE
-------------------------------------------------------------------------------
function GodSendCompose:New(control)
    local manager = ZO_Object.New(self)
	manager.control = control
        
    manager.subject = control:GetNamedChild("SubjectField")
	manager.subject:SetText("(No subject)")
    manager.subject:SetMaxInputChars(MAIL_MAX_SUBJECT_CHARACTERS)
        
    manager.body = control:GetNamedChild("BodyField")
    manager.body:SetMaxInputChars(1024) -- Changed from MAIL_MAX_BODY_CHARACTERS for compatibility with '\r' characters.

-- Guild Dropdown
	manager.guildList = ZO_ComboBox_ObjectFromContainer(GetControl(control, "GuildDropdown"))
	manager.guildList:SetSortsItems(false) -- Don't sort list alphabetically
	manager.guildList:SetSpacing(4)
	manager.guildList:ClearItems()
	
-- Logic Dropdown
	manager.logicList = ZO_ComboBox_ObjectFromContainer(GetControl(control, "LogicDropdown"))
	manager.logicList:SetSortsItems(false)
	manager.logicList:SetSpacing(4)
	manager.logicList:ClearItems()
	
-- Rank Dropdown
	manager.rankList = ZO_ComboBox_ObjectFromContainer(GetControl(control, "RankDropdown"))
	manager.rankList:SetSortsItems(false)
	manager.rankList:SetSpacing(4)
	manager.rankList:ClearItems()
	
	local entry
	local guildId
	local guildName
	local rankName
	
	local guildChoice
	local rankChoice
	local logicChoice
	local guildChoiceID
	local rankChoiceID
	
	local function OnRankSelected(_, rankName, choice)
	
		GodSendComposeSendButton:SetHidden(false)
		rankChoice = manager.rankList:GetSelectedItem()
		logicChoice = manager.logicList:GetSelectedItem()
		
		GodSendRecipientsLastRecipient:SetText("")
		GodSendRecipientsProgressBar:SetDimensions(0, 24)
		GodSendRecipientsCancelProgressBar:SetDimensions(0, 24)
		
		Guilds.GuildMembers = {}
		CurrentMail["recipients"] = {}
		
		progressBarTotal = 0
		progressBarUnit = 0
		sentMailCount = 0
		recipientID = 1

		for numGuildMembers = 1, GetNumGuildMembers(guildChoiceID) do
			local name, note, rankIndex, playerStatus, secsSinceLogoff = GetGuildMemberInfo(guildChoiceID, numGuildMembers)
			local memberRank = GetFinalGuildRankName(guildChoiceID, rankIndex)
			local hasCharacter, characterName, zoneName, classId, alliance, level, veteranRank = GetGuildMemberCharacterInfo(guildChoiceID, numGuildMembers)
			table.insert(Guilds.GuildMembers, { id = 0, name = name, rankIndex = rankIndex, rank = memberRank, mail = false }) -- Populate guild members table
		end
		
		for k, v in ipairs(Guilds.GuildRanks) do
			if rankChoice == v then rankChoiceID = k else end -- Set rank ID for selected rank
		end
		
		for k, v in ipairs(Guilds.GuildMembers) do
			
			if (v["rankIndex"] == rankChoiceID or rankChoice == "All Members") then v["mail"] = true
			elseif logicChoice == ">=" then
				if v["rankIndex"] < rankChoiceID then v["mail"] = true
				else v["mail"] = false end
			elseif logicChoice == "<=" then
				if v["rankIndex"] > rankChoiceID then v["mail"] = true
				else v["mail"] = false end
			else v["mail"] = false end
		end
			
		for i, d in ipairs(Guilds.GuildRanks) do
			for k, v in ipairs(Guilds.GuildMembers) do
				if v["rank"] == d then
					if v["mail"] == true then
						v["mail"] = "|c3A92FFPending"
						v["id"] = recipientID
						recipientID = recipientID + 1
						table.insert(CurrentMail["recipients"], v["name"]) -- Populate recipients table
					else end
				else end
			end
		end
		
		recipientID = 1
		GODSEND_RECIPIENTS:RefreshData() -- Refresh scroll list
		GodSendRecipientsProgressBG:SetHidden(false)
		--GodSendRecipientsTotalRecipients:SetColor(hex2rgb("#3A92FF"))
		GodSendRecipientsTotalRecipients:SetText("0/" .. #CurrentMail["recipients"])
		if (GODSEND_DEBUG) then d(guildChoice .. " (" .. #CurrentMail["recipients"] .. ")") end
		
		progressBarUnit = (500 / #CurrentMail["recipients"])
		if (GODSEND_DEBUG) then d("Progress Bar Unit = " .. progressBarUnit) end
	end
	
	local function OnGuildSelected(_, guildName, choice)

		Guilds.GuildRanks = {}
		manager.logicList:ClearItems()
		manager.rankList:ClearItems()
	
		entry = manager.logicList:CreateItemEntry("==", OnRankSelected)
		manager.logicList:AddItem(entry)
		entry = manager.logicList:CreateItemEntry(">=", OnRankSelected)
		manager.logicList:AddItem(entry)
		entry = manager.logicList:CreateItemEntry("<=", OnRankSelected)
		manager.logicList:AddItem(entry)
		manager.logicList:SetSelectedItem("==")
	
		entry = manager.rankList:CreateItemEntry("All Members", OnRankSelected)
		manager.rankList:AddItem(entry)
		manager.rankList:SetSelectedItem("All Members") -- Set default rank selection
		
		guildChoice = guildName -- Set selected guild name (for debug)
		guildChoiceID = GuildChoice[guildName] -- Set selected guild ID
			
		for numGuildRanks = 1, GetNumGuildRanks(guildChoiceID) do
			rankName = GetFinalGuildRankName(guildChoiceID, numGuildRanks)
			
			entry = manager.rankList:CreateItemEntry(rankName, OnRankSelected) -- Populate rank dropdown box
			manager.rankList:AddItem(entry)
			
			table.insert(Guilds.GuildRanks, rankName) -- Populate guild ranks table
		end
		OnRankSelected()
	end

	for guildIndex = 1, GetNumGuilds() do
		guildId = GetGuildId(guildIndex)
		guildName = GetGuildName(guildId)
		GuildChoice[guildName] = guildId
		
		entry = manager.guildList:CreateItemEntry(guildName, OnGuildSelected) -- Populate guild dropdown box
		manager.guildList:AddItem(entry)
		
		table.insert(Guilds.GuildNames, guildName) -- Populate guild names table
	end
end

-------------------------------------------------------------------------------
-- HANDLERS
-------------------------------------------------------------------------------

-- Mail
local function SaveMailAsPending()
	PendingMail["recipients"] = CurrentMail["recipients"]
	PendingMail["subject"] = CurrentMail["subject"]
	PendingMail["body"] = CurrentMail["body"]
end

local function SendNextRecipient()
	local recipient = nil
	local subject = PendingMail["subject"]
	local body = PendingMail["body"]
	
	GODSEND_ACTIVE = true
	recipient = PendingMail["recipients"][recipientID]
		
	if not (mailBoxOpen) then RequestOpenMailbox() end
		
	if (mailBoxOpen) then
		SendMail(recipient, subject, body)
		lastKnownRecipient = recipient
	elseif not (mailBoxOpen) then
		if not (GODSEND_PAUSED) then
		zo_callLater(SendNextRecipient, sendDelay)
		else GODSEND_ACTIVE = false 
			CloseMailbox() 
		end
	end
end

local function GodSendCancel()

	if (GODSEND_ACTIVE) then
	zo_callLater(GodSendCancel, 200)
	else GODSEND_PAUSED = false
	
		for k, v in ipairs(Guilds.GuildMembers) do
			if v["mail"] == "|c3A92FFPending" then
				v["mail"] = "|cC80F14Canceled"
			else end
		end
		
		local progressBarCancelSize = (500 - progressBarTotal)
		GodSendRecipientsCancelProgressBar:SetDimensions(progressBarCancelSize, 24)
		--GodSendRecipientsTotalRecipients:SetColor(hex2rgb("#AFAFAF"))
		GodSendRecipientsLastRecipient:SetText("")
		GODSEND_RECIPIENTS:RefreshData() -- Refresh scroll list
	end
end

local function UpdateProgressBar()
	progressBarTotal = progressBarTotal + progressBarUnit
	GodSendRecipientsProgressBar:SetDimensions(progressBarTotal, 24)
	GodSendRecipientsTotalRecipients:SetText(recipientID .. "/" .. #PendingMail["recipients"])
	GodSendRecipientsLastRecipient:SetText(lastKnownRecipient)
end

-- Events
local function OnMailSendSuccess()
	if (GODSEND_ACTIVE) then
		sentMailCount = sentMailCount + 1
		
		for k, v in ipairs(Guilds.GuildMembers) do
			if v["name"] == lastKnownRecipient then
				v["mail"] = "|c2DC50ESent"
			else end
		end
		
		--GodSendRecipientsLastRecipient:SetColor(hex2rgb("#2DC50E"))
		UpdateProgressBar()
		GODSEND_RECIPIENTS:RefreshData() -- Refresh scroll list
		if (GODSEND_DEBUG) then d("|c2DC50E" .. lastKnownRecipient .. " " .. recipientID .. "/" .. #PendingMail["recipients"]) end
	
		if recipientID < #PendingMail["recipients"] then
			recipientID = recipientID + 1
			
			if not (GODSEND_PAUSED) then
			zo_callLater(SendNextRecipient, sendDelay)
			else GODSEND_ACTIVE = false 
				CloseMailbox() 
			end
			
		else d("GodSend Completed")
			GODSEND_ACTIVE = false
			CloseMailbox()
			GodSendHideButtons()
			--GodSendRecipientsTotalRecipients:SetColor(hex2rgb("#FFFFFF"))
			--GodSendRecipientsLastRecipient:SetColor(hex2rgb("#EECA2A"))
			GodSendRecipientsLastRecipient:SetText("GodSend Completed")
		end
		
	else end
end

local function OnMailSendFailed(eventCode, reason)
	if (GODSEND_ACTIVE) then
		sentMailCount = sentMailCount + 1
		
		for k, v in ipairs(Guilds.GuildMembers) do
			if v["name"] == lastKnownRecipient then
			
				if reason == 8		then v["mail"] = "|cC80F14COD Error"
				elseif reason == 11 then v["mail"] = "|cC80F14Self"
				elseif reason == 7  then v["mail"] = "|cC80F14Blank Mail"
				elseif reason == 1  then v["mail"] = "|cC80F14DB Error"
				elseif reason == 4  then v["mail"] = "|cC80F14Ignored"
				elseif reason == 10 then v["mail"] = "|cC80F14In Progress"
				elseif reason == 2  then v["mail"] = "|cC80F14Invalid Name"
				elseif reason == 3  then v["mail"] = "|cC80F14Full Inbox"
				elseif reason == 6  then v["mail"] = "|cC80F14Invalid Item"
				elseif reason == 12 then v["mail"] = "|cC80F14Mail Disabled"
				elseif reason == 13 then v["mail"] = "|cC80F14Mailbox Closed"
				elseif reason == 9  then v["mail"] = "|cC80F14COD Error"
				elseif reason == 5  then v["mail"] = "|cC80F14Gold Error"
				elseif reason == 15 then v["mail"] = "|cC80F14User Not Found"
				elseif reason == 0  then v["mail"] = "|cC80F14Success"
				elseif reason == 14 then v["mail"] = "|cC80F14Attachment Error"
				else v["mail"] = "|cC80F14Unknown Error"
				end
				
			else end
		end

		--GodSendRecipientsLastRecipient:SetColor(hex2rgb("#C80F14"))
		UpdateProgressBar()
		GODSEND_RECIPIENTS:RefreshData() -- Refresh scroll list
		if (GODSEND_DEBUG) then d("|cC80F14" .. lastKnownRecipient .. " " .. recipientID .. "/" .. #PendingMail["recipients"]) end
	
		if recipientID < #PendingMail["recipients"] then
			recipientID = recipientID + 1
			
			if not (GODSEND_PAUSED) then
			zo_callLater(SendNextRecipient, sendDelay)
			else GODSEND_ACTIVE = false 
				CloseMailbox()
			end
			
		else d("GodSend Completed")
			GODSEND_ACTIVE = false
			CloseMailbox()
			GodSendHideButtons()
			--GodSendRecipientsTotalRecipients:SetColor(hex2rgb("#FFFFFF"))
			--GodSendRecipientsLastRecipient:SetColor(hex2rgb("#EECA2A"))
			GodSendRecipientsLastRecipient:SetText("GodSend Completed")
		end
		
	else end
end

local function OnMailOpenMailBox()
	mailBoxOpen = true
	if (GODSEND_DEBUG) then d("|c2DC50EMail Box Opened!") end
end

local function OnMailCloseMailBox()
	mailBoxOpen = false
	if (GODSEND_DEBUG) then d("|cC80F14Mail Box Closed!") end
end

-- Char Counter
local function CharCounter(str)
    if not str then return 0 end
    local count = 0 
    for i = 1, #str do
        if string.byte(str, i) then
            count = count + 1 
        end
    end 
    return count
end

-- Convert Color
local function hex2rgb(hex)
    hex = hex:gsub("#","")
    return tonumber("0x"..hex:sub(1,2),16)/255, tonumber("0x"..hex:sub(3,4),16)/255, tonumber("0x"..hex:sub(5,6),16)/255
end

-- Tooltips

local function SetToolTip(ctrl, text, placement)
    ctrl:SetHandler("OnMouseEnter", function(self)
        ZO_Tooltips_ShowTextTooltip(self, placement, text)
    end)
    ctrl:SetHandler("OnMouseExit", function(self)
        ZO_Tooltips_HideTextTooltip()
    end)
end

-- Keybinds
function GodSendWindow_Toggle()
	GODSEND_WINDOW:Toggle()
end
	
-------------------------------------------------------------------------------
-- GLOBAL XML
-------------------------------------------------------------------------------
-- Buttons

function GodSendHideButtons()
	GodSendComposeSendButton:SetHidden(true)
	GodSendComposeCancelButton:SetHidden(true)
	GodSendComposePauseButton:SetHidden(true)
	GodSendComposeContinueButton:SetHidden(true)
end

function GodSendWindowCloseButton_OnClicked()
	GODSEND_WINDOW.visible = false
	GODSEND_WINDOW.control:SetHidden(true)
end

function GodSendComposeSendButton_OnClicked()
	SaveMailAsPending()
	SendNextRecipient()

	--GodSendRecipientsTotalRecipients:SetColor(hex2rgb("#2DC50E"))
	GodSendComposeSendButton:SetHidden(true)
	GodSendComposeCancelButton:SetHidden(false)
	GodSendComposePauseButton:SetHidden(false)
	if (GODSEND_DEBUG) then d("GodSend Started") end
end

function GodSendComposeCancelButton_OnClicked()
	GODSEND_PAUSED = true
	GodSendCancel()
	
	GodSendComposeSendButton:SetHidden(true)
	GodSendComposeCancelButton:SetHidden(true)
	GodSendComposePauseButton:SetHidden(true)
	GodSendComposeContinueButton:SetHidden(true)
	if (GODSEND_DEBUG) then d("GodSend Canceled") end
end

function GodSendComposePauseButton_OnClicked()
	GODSEND_PAUSED = true
	
	--GodSendRecipientsTotalRecipients:SetColor(hex2rgb("#3A92FF"))
	GodSendComposePauseButton:SetHidden(true)
	GodSendComposeContinueButton:SetHidden(false)
	if (GODSEND_DEBUG) then d("GodSend Paused") end
end

function GodSendComposeContinueButton_OnClicked()
	GODSEND_PAUSED = false
	SendNextRecipient()
	
	--GodSendRecipientsTotalRecipients:SetColor(hex2rgb("#2DC50E"))
	GodSendComposePauseButton:SetHidden(false)
	GodSendComposeContinueButton:SetHidden(true)
	if (GODSEND_DEBUG) then d("GodSend Continued") end
end

-- Subject Field
function GodSendComposeSubjectField_OnInitialized(self)
	GodSendComposeSubjectField:SetColor(hex2rgb("#AFAFAF"))
end

function GodSendComposeSubjectField_OnTextChanged(self)
	CurrentMail["subject"] = GodSendComposeSubjectField:GetText()
end

function GodSendComposeSubjectField_OnFocusGained(self)
	if CurrentMail["subject"] == "(No subject)" then
		GodSendComposeSubjectField:SetText("")
	end
	GodSendComposeSubjectField:SetColor(hex2rgb("#FFFFFF"))
end

function GodSendComposeSubjectField_OnFocusLost(self)
	if CurrentMail["subject"] == "" then
		GodSendComposeSubjectField:SetText("(No subject)")
		GodSendComposeSubjectField:SetColor(hex2rgb("#AFAFAF"))
	end
end

-- Body Field
function GodSendComposeBodyField_OnTextChanged(self)
	local unix_terminated = string.gsub(GodSendComposeBodyField:GetText(), "\r", "")  -- Converts from windows to unix line endings.
	if string.len(unix_terminated) > 700 then
        CurrentMail["body"] = string.sub(unix_terminated, 1, 700) -- Forces the contents of the mail to be truncated to 700 chars.
        GodSendComposeBodyField:SetText(string.sub(unix_terminated, 1, 700))
    else
        CurrentMail["body"] = unix_terminated
    end
    local CharCountBody = CharCounter(CurrentMail["body"])
	GodSendComposeCharacterLimit:SetText(CharCountBody .. "/700")
end

-- Scroll List
function GodSendRecipientsRow_OnMouseEnter(control)	
	GODSEND_RECIPIENTS:EnterRow(control)
end

function GodSendRecipientsRow_OnMouseExit(control)
	GODSEND_RECIPIENTS:ExitRow(control)
end

-- Labels
function GodSendLabelField_OnMouseEnter(control)
	if (control:WasTruncated()) then
		InitializeTooltip(InformationTooltip, control, BOTTOM, 0, 0)
		SetTooltipText(InformationTooltip, control:GetText())
	end
	
	local row = control:GetParent()
	zo_callHandler(row, "OnMouseEnter")
end

function GodSendLabelField_OnMouseExit(control)
	ClearTooltip(InformationTooltip)
	
	local row = control:GetParent()
	zo_callHandler(row, "OnMouseExit")
end

function GodSendLabelField_OnLinkMouseUp(control, button, linkText)
	ZO_LinkHandler_OnLinkMouseUp(linkText, button, control)
	
	local row = control:GetParent()
	zo_callHandler(row, "OnMouseUp", button, true, linkText)
end

-- Initialize
function GodSendWindow_OnInitialized(self)
	GODSEND_WINDOW = GodSendWindow:New(self)
end

function GodSendCompose_OnInitialized(self)
    GODSEND_COMPOSE = GodSendCompose:New(self)
end

function GodSendRecipients_OnInitialized(self)
    GODSEND_RECIPIENTS = GodSendRecipients:New(self)
end

-------------------------------------------------------------------------------
-- ADDON LOADED
-------------------------------------------------------------------------------
local function OnAddonLoaded(eventCode, addonName)
	if addonName ~= (ADDON_NAME) then return end
	
	EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_MAIL_OPEN_MAILBOX, OnMailOpenMailBox)
	EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_MAIL_CLOSE_MAILBOX, OnMailCloseMailBox)
	EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_MAIL_SEND_SUCCESS, OnMailSendSuccess)
	EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_MAIL_SEND_FAILED, OnMailSendFailed)
	
	SLASH_COMMANDS["/godsend"] = GodSendWindow_Toggle
	
	SavedVars = ZO_SavedVars:NewAccountWide(SAVEDVARS_NAME, SAVEDVARS_VERSION, nil, DefaultVars)
	
	EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
end

-- Execute
EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddonLoaded)

-- SCENE_MANAGER:GetScene("inventory"):RemoveFragmentGroup(FRAGMENT_GROUP.MOUSE_DRIVEN_UI_WINDOW)
