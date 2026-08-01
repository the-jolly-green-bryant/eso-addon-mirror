--[[ 
A guy gets on a bus and starts threatening everybody: "I'll integrate you! I'll differentiate you!" So everybody gets scared and runs away, only one person stays. The guy comes up to him and says: "Aren't you scared, I'll integrate you, I'll differentiate you!" And the other guy says: "No, I am not scared, I am e^x."
--]]


local ADDON_NAME	= "EmoteIt"
local VERSION_CODE	= 0.9
EmoteIt = {
	emoteData = {},
}

--===================================--
--====== ScrollList Categories ======--
--===================================--
EMOTEIT_CATEGORY_ALL 		= 1
EMOTEIT_CATEGORY_FAVORITES 	= 2
EMOTEIT_CATEGORY_TRIGGERS	= 3
ALL_CHAT_CHANNELS = -1

--===================================--
--====== Utility Functions  ======--
--===================================--
-- Strip leading/trailing white space
local function Trim(s)
	return s:find'^%s*$' and '' or s:match'^%s*(.*%S)'
end

--===================================--
--======= New Object Function =======--
--===================================--
function EmoteIt:New()
	self.name 			= ADDON_NAME
	self.CodeVersion	= VERSION_CODE
	
	-----------------------------
	-- DO NOT EVER CHANGE THIS --
	-----------------------------
	self.SavedVarVersion = 0.5
	-----------------------------
	-----------------------------
	
	-----------------------------------------------------
	-- Bind windows to self
	-- Main Window
	self.mainWin 	= EmoteItWin
	self.menuBar	= EmoteItWinMenuBar
	self.searchBox	= EmoteItWinWinEditBox
	
	-- Triggers Window
	self.triggerWin					= EmoteItTriggerWin
	self.triggerWinTriggersLabel 	= EmoteItTriggerWinTriggersLabel
	self.triggerCurLabel			= EmoteItTriggerWinCurLabel
	self.triggerCurName				= EmoteItTriggerWinCurName
	
	-- AddTrigger Window (small section for adding trigger text)
	self.triggerEb			= EmoteItTriggerWinAddTriggerScriptEditBox
	self.triggerDDL			= EmoteItTriggerWinAddTriggerDDL
	self.addTriggerWin		= EmoteItTriggerWinAddTrigger
	-----------------------------------------------------
end

--===================================================--
--======== Initialize Functions =========--
--===================================================--
function EmoteIt:Initialize()
	local defaultSavedVars = {
		triggers = {
			[ALL_CHAT_CHANNELS] = {},
			[CHAT_CHANNEL_SAY] = {},
			[CHAT_CHANNEL_YELL] = {},
			[CHAT_CHANNEL_PARTY] = {},
			[CHAT_CHANNEL_EMOTE] = {},
		},
		favEmotes = {},
		mainWinSettings = {
			offsetX	= 100,
			offsetY = 100,
			width	= 350,
			height	= 450,
			hidden	= false,
		},
	}
	self.sv = ZO_SavedVars:NewAccountWide("EmoteItSavedVars", self.SavedVarVersion, nil, defaultSavedVars)
	
	ZO_CreateStringId("SI_BINDING_NAME_EMOTEIT_TOGGLE_WIN", "Toggle EmoteIt Window")
	
	self:InitializeUI() -- In CreateUI.lua
	self:InitializeEmoteData()
	self:UpdateMainListByCategory(EMOTEIT_CATEGORY_ALL)
end

-- Used to get the necessary dataTable info about an emote
-- Could be combined with the InitializeEmoteData, but leaving it
-- separate, might want it for something later
function EmoteIt:GetEmoteData(emoteIndex)
	local emoteSlashName, emoteCategory, emoteId = GetEmoteInfo(emoteIndex)
	
	local emoteInfo =   {
		displayText 	= string.sub(emoteSlashName,2),
		emoteCategory 	= emoteCategory,
		emoteId 		= emoteId,
		emoteIndex 		= emoteIndex,
		categories 		= {EMOTEIT_CATEGORY_ALL},
	}
	if self.sv.favEmotes[emoteIndex] then
		emoteInfo.categories = {EMOTEIT_CATEGORY_ALL, EMOTEIT_CATEGORY_FAVORITES}
		emoteInfo.favorite 	 = true
	end
	return emoteInfo
end

-- Initialize all emote data & save it in the emoteData table
-- So we don't have to gather this info every time they push a button
function EmoteIt:InitializeEmoteData()
	for emoteIndex=1, GetNumEmotes() do
		local emoteInfo = self:GetEmoteData(emoteIndex)
		
		self.emoteData[emoteIndex] = emoteInfo
	end
end

--===================================--
--====== Update Functions  ======--
--===================================--
-- Updates the scroll List in the main window, by
-- passing in a categoryId. No need to worry about
-- calling Clear if there are none, the table would just be empty
-- and Update(..) will clear it for us
function EmoteIt:UpdateMainListByCategory(categoryId)
	local dataTable = {}
	
	if categoryId == EMOTEIT_CATEGORY_ALL then
		dataTable = self.emoteData
		
	elseif categoryId == EMOTEIT_CATEGORY_FAVORITES then
		dataTable = self:GetFavoriteEmotesData()
		
	elseif categoryId == EMOTEIT_CATEGORY_TRIGGERS then
		dataTable = self:GetAllTriggers()
	end
	if not dataTable then return end
	TEMP_TABLE = dataTable
	self.scrollListMain:Update(dataTable)
end

-- Updates the scroll list for the secondary "trigger" window
-- Updates it with either all text that triggers the selected emote
-- or all emotes that are triggered by the selected text
-- Again no need to worry about calling Clear(), if none exist
-- the returned table will be empty & Update(..) will clear it for us
function EmoteIt:UpdateTriggerList(categoryId, conditionValue)
	local dataTable
	
	if categoryId == EMOTEIT_CATEGORY_ALL then
		dataTable = self:GetEmotesForTrigger(conditionValue)
		TEMP_TABLE = dataTable
	elseif categoryId == EMOTEIT_CATEGORY_TRIGGERS then
		dataTable = self:GetTriggersForEmote(conditionValue)
	end
	self.scrollListTriggers:Update(dataTable)
	-- Not needed if the dataTable is empty it will clear it
	--self.scrollListTriggers:Clear()
end

--===================================================--
--======== Get Emote Data Functions =========--
--===================================================--
-- Loops through saved favorite emotes & returns the
-- a table of the favorite emotes data tables
function EmoteIt:GetFavoriteEmotesData()
	local emoteDataTable = {}
	for emoteIndex, emoteData in pairs(self.sv.favEmotes) do
		table.insert(emoteDataTable, EmoteIt.emoteData[emoteIndex])
	end
	return emoteDataTable
end

--[[ We only add the channel here to emoteInfo, because this is the only place it is relevant. The channel is only needed in the trigger scroll list window to add the channel to the text to be displayed. The same emote could also be triggered on another channel so we can't save the channel data for the emote in the self.emoteData table
--]]
-- Gets all emote data for emotes that are triggered by a given trigger text
function EmoteIt:GetEmotesForTrigger(triggerText)
	local triggers = self.sv.triggers
	local triggerEmotes = {}
	
	-- Loop through each channel table, then each 
	-- trigger table, looking for the triggerText
	for channel,triggerTable in pairs(triggers) do
		for text, emoteIndexTable in pairs(triggerTable) do
			if text == triggerText then
				-- If found loop through the EmoteIndexTable
				-- and insert all emoteIndices that it triggers.
				for k, emoteIndex in pairs(emoteIndexTable) do
					-- See note before function:
					-- Copy because were going to add a channel & it must be
					-- temporary & not copied into our self.emoteData table
					local emoteInfo = ZO_DeepTableCopy(self.emoteData[emoteIndex])
					emoteInfo.channel = channel
					
					table.insert(triggerEmotes, emoteInfo)
				end
			end
		end
	end
	return triggerEmotes
end

--===================================================--
--======== Get Trigger Data Functions =========--
--===================================================--
-- Return a scrollData table for all trigger text
-- To be used to update a scrollList (either scrollList)
function EmoteIt:GetAllTriggers()
	local triggers = self.sv.triggers
	
	local allTriggers = {}
	local foundTriggers = {}
	for channel,triggerTable in pairs(triggers) do
		for triggerText, emoteTable in pairs(triggerTable) do
			-- Prevent duplicate trigger text
			if not foundTriggers[triggerText] then
				table.insert(allTriggers, {displayText=triggerText,channel=channel})
				foundTriggers[triggerText] = true
			end
		end
	end
	return allTriggers
end

-- Retruns a scrollData table containing itemData tables for each
-- trigger text that activates the given emoteIndex
-- Used to update either scroll list
function EmoteIt:GetTriggersForEmote(emoteIndex)
	local triggers = self.sv.triggers
	local emoteTriggers = {}
	
	-- Loop through each channel table, then each trigger
	-- text table, then each emoteIndexTable
	for channel,triggerTable in pairs(triggers) do
		for triggerText, emoteIndexTable in pairs(triggerTable) do
			for k,emoteId in pairs(emoteIndexTable) do
				if emoteId == emoteIndex then
					table.insert(emoteTriggers, {displayText=triggerText,channel=channel})
				end
			end
		end
	end
	return emoteTriggers
end

--===================================--
--====== XML Code Functions ======--
--===================================--
local function DoesEmoteChannelTriggerExist(channel, triggerText, selectedEmoteIndex)
	local triggeredEmotes = EmoteIt.sv.triggers[channel][triggerText]
	
	for k, emoteIndex in pairs(triggeredEmotes) do
		if emoteIndex == selectedEmoteIndex then
			return true
		end
	end
	return false
end
-- Adds trigger text to the appropriate channel
-- and updates the trigger scroll list
function EmoteIt_AddTrigger(self, button, upInside)
	if not upInside then return end
	
	local triggerText = Trim(EmoteIt.triggerEb:GetText())
	local selectedChannelData = EmoteIt.triggerDDL.m_comboBox:GetSelectedItemData()
	local channel = selectedChannelData.channel
	
	if triggerText and triggerText ~= "" and channel then
		local emoteIndex = EmoteIt.addTriggerWin.selectedEmoteIndex
		
		if not EmoteIt.sv.triggers[channel][triggerText] then
			EmoteIt.sv.triggers[channel][triggerText] = {}
		end
		local doesTriggerExist = DoesEmoteChannelTriggerExist(channel, triggerText, emoteIndex)
		
		if doesTriggerExist then
			local colorDrkOrange = "|cFFA500"	-- Dark Orange
			ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NEGATIVE_CLICK, colorDrkOrange.."EmoteIt: |r Emote trigger already exists.")
		else
			--EmoteIt.sv.triggers[channel][triggerText][emoteIndex] = emoteIndex
			table.insert(EmoteIt.sv.triggers[channel][triggerText], emoteIndex)
			EmoteIt:UpdateTriggerList(EMOTEIT_CATEGORY_TRIGGERS, emoteIndex)
		end
	end
end

--===================================================--
--======== Chat Handler Functions =========--
--===================================================--
-- Called from chat handler to determine if any trigger
-- text is found in the given chat message for a given
-- chat channel
local function FindEmoteFromText(msgText, messageType)
	local triggers = EmoteIt.sv.triggers[messageType]
	local lowerMsgText = string.lower(msgText)
	
	for keyText, emoteTable in pairs(triggers) do
		if lowerMsgText:find(string.lower(keyText)) then
			local seed = math.random(#emoteTable)
			return emoteTable[seed]
		end
	end
end

-- Chat handler: Checks if the msg came from the player
-- and makes sure the player is not moving or in combat 
-- (or else they could not play the emote) then checks text
-- for trigger text & if found plays emote
local function OnChatMsg(eventCode, messageType, fromName, text, isCustomerService)
	if not EmoteIt.sv.triggers[messageType] then return end
	if zo_strformat(SI_UNIT_NAME, fromName) ~= GetUnitName("player") then return end
	if IsPlayerMoving()	or IsUnitInCombat("player") then return end
	
	local lowerText = string.lower(text)
	
	local emoteIndex = FindEmoteFromText(lowerText, ALL_CHAT_CHANNELS)	
	
	if not emoteIndex then
		emoteIndex = FindEmoteFromText(lowerText, messageType)
	end
	if emoteIndex then
		PlayEmoteByIndex(emoteIndex)
	end
end

-------------------------------------------------------------------
--  OnAddOnLoaded  --
-------------------------------------------------------------------
local function OnAddOnLoaded(event, addonName)
	if addonName == ADDON_NAME then
		EmoteIt:New()
		EmoteIt:Initialize()
		EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_CHAT_MESSAGE_CHANNEL, OnChatMsg)
		EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
	end
end
---------------------------------------------------------------------
--  Register Events --
---------------------------------------------------------------------
EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)

