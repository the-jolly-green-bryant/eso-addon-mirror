--[[TODO:
	test: UpdateDailyIconTexture() in EVENT_CURRENCY_UPDATE
	test: daily info not properly updating
	test: event container matching
	
	make settings to allow reset and manual entry of event info
	
]]
--[[- - -
○ 
○ 
]]
--[[- - -4.0.1
○ bug fix. misspelled global

- - -4
○ uses LibSeasonalEventManager
○ check mark is used to show that discovered tickets have been acuired. Green if from all known sources.

]]
--[[- - -3
○ simplified functionality
-- no longer tries to predict what current event is if it does not have a corresponding map location
○ should no longer reset map to Glenumbra.
-- will now reset map to previous map after performing map checks
○ added reset time to HUD frame
○ added reset time to Gamepad menu
]]
--[[- - -2.1.1
○ fixed loop triggered on traveling/door transition that caused the game to stop responding.
]]
--[[- - -2.0.10
○ try fixing icon changing
○ fixed stuck in loop on loading with new event.
]]
--[[- - -2.0.9
○ hid debug data
]]
--[[- - -2.0.8
○ removed fragment from gamepad main menu. it breaks the gamepad options
○ added the info as a header to gamepad main menu
○ changes to Daily info:
	icon: ? unless event is identified, check-mark on all daily tickets acquired, else black
	#/#: updates on tickets discovered.
○ fixed daily info not properly updating ??
○ fixed event container matching ??
]]
--[[- - -2.0.7
○ fixed error: IsJustaEventTicketSaver.lua:336: attempt to index a nil value
]]
--[[- - -2.0.6
○ added option to set transparency
○ [Not tested] added tracking for max tickets discovered per day to use for dynamically updating event data.
- The hope is this will prevent the "need" for future event updates.
]]
--[[- - -2.0.5
○ fixed error: IsJustaEventTicketSaver.lua:517: function expected instead of nil
○ simplified cooldowns
]]
--[[- - -2.0.4
○ added fragmet to gamepad main menu
○ panel is now movable
○ panel now shows daily info as "[icon] Daily    #/#"
]]
--[[- - -2.0.3
○ WIP: unknown events will now be stored at event-end and store accumulated data to be used to identify it if it is used again.
-- data stored: 
	source type tickets were received from.
	maximum tickets received per day.
	list of source names, localized, tickets were received from.
]]
--[[- - -2.0.2
○ preset all eventVars to insure their locals reference the saved variables.
]]
--[[- - -2
○ no longer uses a table of dates, to prevent the need to update for every event.
○ replaced the ticket icon with the gamepad version.
○ added a "?" icon to represent that the availability of event tickets has not yet been determined.
○ if 1 of 4 events, based on visible map pins, are active, the "?" icon will not be used.
Witch's, Jester's, Anniversary, Mayhem, are the only events with map pins that are only visible when active.

Witch's Festival, Jester's Festival, Anniversary Jubilee, Whitestrake's Mayhem Celebration, are the only events with map pins.
]]
--[[- - -1.8.5
○ Whitestrake’s Mayhem update.
]]
--[[- - -1.8.4
○ Fixed error caused by missing variable on event active check.
]]
--[[- - -1.8.3
○ The Zeal of Zenithar
]]
--[[- - -1.8.2
○ set all upcoming events as disabled.
]]
--[[- - -1.8.1
○ rebuilt how seasonal event data is handled
○ acquired tickets should now update properly
○ interaction should now only be disabled if you have not already interacted with the object
]]
--[[- - -1.8
○ added daily ticket monitoring
○ loot tickets are added as soon as the loot window opens the first time with tickets for the current target
	- it will not consider adding tickets for that target again for 5 minutes. this is to prevent tickets adding to daily amount acquired for the same tickets.
○ changed how loot is handled per game mode
○ added icon to ticket stats fragment. the ticket icon means you have tickets to acquire for the day, check mark means all have been acquired.
○ attempting to fix some major issues.
]]
--[[- - -1.7.5
○ fixed error user:/AddOns/IsJustaEventTicketSaver/IsJustaEventTicketSaver.lua:449: function expected instead of nil
○ fixed issue where the cake would become unusable even when it should be.
]]
--[[- - -1.7.4
○ updated Anniversary jubilee dates for 2022.
]]
--[[- - -1.7.3
○ fix incorrect quest reward data for event quests turn-in with event tickets.
○ added delay for keyboard option text in order to ensure it will be red if it should be
]]
--[[- - -1.7.2
○ fix error user:/AddOns/IsJustaEventTicketSaver/Debug.lua:315: attempt to index a nil value
]]
--[[- - -1.7
○ updated for API 101034.
○ fixed OnLoaded.
○ implemented support for LibHaF.
○ changed how fragments are registered and updated.
○ updated Jester's Festival dates for 2022.
○ improved quest turn-in handling for ticket quests.
○ fixed the duplicate complete quest button.
○ improved interaction handling.
○ adjusted panel size to better fit the text.
]]

--[[
TODO:
	test: UpdateDailyIconTexture() in EVENT_CURRENCY_UPDATE
	test: daily info not properly updating
	test: event container matching
	
	make settings to allow reset and manual entry of event info
	
- - -
○ 
○ 

- - -4
○ uses LibSeasonalEventManager

- - -3
○ simplified functionality
-- no longer tries to predict what current event is if it does not have a corresponding map location
○ should no longer reset map to Glenumbra.
-- will now reset map to previous map after performing map checks
○ added reset time to HUD frame
○ added reset time to Gamepad menu


- - -2.1.1
○ fixed loop triggered on traveling/door transition that caused the game to stop responding.
○ 
○ 


- - -2.0.10
○ try fixing icon changing
○ fixed stuck in loop on loading with new event.


- - -2.0.9
○ hid debug data


- - -2.0.8
○ removed fragment from gamepad main menu. it breaks the gamepad options
○ added the info as a header to gamepad main menu
○ changes to Daily info:
	icon: ? unless event is identified, check-mark on all daily tickets acquired, else black
	#/#: updates on tickets discovered.
○ fixed daily info not properly updating ??
○ fixed event container matching ??

- - -2.0.7
○ fixed error: IsJustaEventTicketSaver.lua:336: attempt to index a nil value

- - -2.0.6
○ added option to set transparency
○ [Not tested] added tracking for max tickets discovered per day to use for dynamically updating event data.
- The hope is this will prevent the "need" for future event updates.
○ 

- - -2.0.5
○ fixed error: IsJustaEventTicketSaver.lua:517: function expected instead of nil
○ simplified cooldowns

- - -2.0.4
○ added fragmet to gamepad main menu
○ panel is now movable
○ panel now shows daily info as "[icon] Daily    #/#"

- - -2.0.3
○ WIP: unknown events will now be stored at event-end and store accumulated data to be used to identify it if it is used again.
-- data stored: 
	source type tickets were received from.
	maximum tickets received per day.
	list of source names, localized, tickets were received from.

- - -2.0.2
○ preset all eventVars to insure their locals reference the saved variables.

- - -2
○ no longer uses a table of dates, to prevent the need to update for every event.
○ replaced the ticket icon with the gamepad version.
○ added a "?" icon to represent that the availability of event tickets has not yet been determined.
○ if 1 of 4 events, based on visible map pins, are active, the "?" icon will not be used.
Witch's, Jester's, Anniversary, Mayhem, are the only events with map pins that are only visible when active.

Witch's Festival, Jester's Festival, Anniversary Jubilee, Whitestrake's Mayhem Celebration, are the only events with map pins.


- - -1.8.5
○ Whitestrake’s Mayhem update.


- - -1.8.4
○ Fixed error caused by missing variable on event active check.


- - -1.8.3
○ The Zeal of Zenithar


- - -1.8.2
○ set all upcoming events as disabled.



- - -1.8.1
○ rebuilt how seasonal event data is handled
○ acquired tickets should now update properly
○ interaction should now only be disabled if you have not already interacted with the object
○ 
○ 
○ 


- - -1.8
○ added daily ticket monitoring
○ loot tickets are added as soon as the loot window opens the first time with tickets for the current target
	- it will not consider adding tickets for that target again for 5 minutes. this is to prevent tickets adding to daily amount acquired for the same tickets.
○ changed how loot is handled per game mode
○ added icon to ticket stats fragment. the ticket icon means you have tickets to acquire for the day, check mark means all have been acquired.
○ attempting to fix some major issues.
○ 


- - -1.7.5
○ fixed error user:/AddOns/IsJustaEventTicketSaver/IsJustaEventTicketSaver.lua:449: function expected instead of nil
○ fixed issue where the cake would become unusable even when it should be.

- - -1.7.4
○ updated Anniversary jubilee dates for 2022.

- - -1.7.3
○ fix incorrect quest reward data for event quests turn-in with event tickets.
○ added delay for keyboard option text in order to ensure it will be red if it should be

- - -1.7.2
○ fix error user:/AddOns/IsJustaEventTicketSaver/Debug.lua:315: attempt to index a nil value

- - -1.7
○ updated for API 101034.
○ fixed OnLoaded.
○ implemented support for LibHaF.
○ changed how fragments are registered and updated.
○ updated Jester's Festival dates for 2022.
○ improved quest turn-in handling for ticket quests.
○ fixed the duplicate complete quest button.
○ improved interaction handling.
○ adjusted panel size to better fit the text.

]]
---------------------------------------------------------------------------------------------------------------
-- 
---------------------------------------------------------------------------------------------------------------
local addonData = {
	displayName = "|cFF00FFIsJusta|r |cffffffEvent Ticket Saver|r",
	name = "IsJustaEventTicketSaver",
	prefix = 'IJA_EventTicketSaver',
	version = "4.0.1",
}
local defaultAnchor = ZO_Anchor:New(TOP, ZO_CompassFrameCenter, BOTTOM, 0, 20)

local svVersion = 4

---------------------------------------------------------------------------------------------------------------
-- locals
---------------------------------------------------------------------------------------------------------------
local ADDON_SHORT_NAME = addonData.prefix

local IS_GAMEPAD = IsInGamepadPreferredMode()

local registerOnTryHandlingInteraction = LibInteractionHook.RegisterOnTryHandlingInteraction
local unregisterOnTryHandlingInteraction = LibInteractionHook.UnregisterOnTryHandlingInteraction
local setAdditionalInfoColor = LibInteractionHook.SetAdditionalInfoColor
local setInteractKeybindButtonColor = LibInteractionHook.SetInteractKeybindButtonColor

--local VAR_TICKETS_CURRENT = 0
VAR_TICKETS_CURRENT = 0

local VAR_TIME_SECONDS_START_MODIFIER = 32400 -------------<
local VAR_TIME_SECONDS_FIVEMINUTES = 300 -------------<
local VAR_ICON_STOLEN = "EsoUI/Art/Inventory/inventory_stolenItem_icon.dds"

local VAR_COLOR_COMPLETE 	= ZO_ColorDef:New(0, 1, 0, 1)
local VAR_COLOR_NOTICE	 	= ZO_ColorDef:New(0.8, 0.9, 0.1, 1)
local VAR_EMPTY_STRING = ''

local libSEM = LibSeasonalEventManager
local VAR_TICKETS_MAX			= libSEM.constants.maxTickets
--local VAR_TICKETS_MAX			= 10 -- for testing

local VAR_EVENT_NONE			= libSEM.constants.currentEventNone
local VAR_EVENT_UNKNOWN			= libSEM.constants.currentEventUnknown

local VAR_EVENT_TYPE_NONE		= libSEM.constants.eventTypeNone
local VAR_EVENT_TYPE_UNKNOWN	= libSEM.constants.eventTypeUnknown
local VAR_EVENT_TYPE_TICKETS	= libSEM.constants.eventTypeTickets

local VAR_CURRENT_TARGET

-- localizing these to make them easier to use
local wouldTicketsExceedMax 			= libSEM.WouldTicketsExcedeMax
local getDailyResetTimeRemainingSeconds = libSEM.GetDailyResetTimeRemainingSeconds

local VAR_ICON_INDEX0 = 0
local VAR_ICON_INDEX1 = 1
local VAR_ICON_INDEX2 = 2
local VAR_ICON_INDEX3 = 3
-- CURT_EVENT_TICKETS = 9
-- REWARD_TYPE_EVENT_TICKETS = 1

local defaults = {
	autoCancel = true,
	eventActive = false,
	secondsToShow = 4,
	occupancy = 70,
	eventInfo = {
	--	['dailyTickets'] = 0,
	--	['dailyMax'] = 0,
	--	['discoveredTickets'] = 0,
	--	['discoveredFrom'] = {},
	}
}

local VAR_TEXTURE_ALL = {
	[VAR_ICON_INDEX0] = "/esoui/art/crafting/crafting_enchanting_glyphslot_empty.dds",
	[VAR_ICON_INDEX1] = "/esoui/art/notifications/notification_help_up.dds",
	[VAR_ICON_INDEX2] = "/esoui/art/currency/gamepad/gp_eventticket.dds",
	[VAR_ICON_INDEX3] = "/esoui/art/miscellaneous/check.dds",
}

local VAR_TEXTURE_DAILY = VAR_TEXTURE_ALL[VAR_ICON_INDEX1]
local VAR_TEXTURE_TICKETS = VAR_TEXTURE_ALL[VAR_ICON_INDEX2]

---------------------------------------------------------------------------------------------------------------
-- Helper functions
---------------------------------------------------------------------------------------------------------------
-- use my custom callLater so it can be called repeatedly, in succession, without stacking.
if not jo_callLater then
	jo_callLater = function(id, func, ms, ...)
		if ms == nil then ms = 0 end
		local params = {...}
		local name = "JO_CallLater_".. id
		EVENT_MANAGER:UnregisterForUpdate(name)
		
		EVENT_MANAGER:RegisterForUpdate(name, ms,
			function()
				EVENT_MANAGER:UnregisterForUpdate(name)
				func(unpack(params))
			end)
		return id
	end
end

local function getDialogTextColor(tooManyTickets)
	if tooManyTickets then
		return ZO_ERROR_COLOR
	else
		return ZO_NORMAL_TEXT
	end	
end

local function getTimeString(totalSeconds)
	local seconds = math.floor(totalSeconds % 60)
	local minutes = math.floor(totalSeconds / 60)
	local hours = math.floor(minutes / 60) % 24
	minutes = minutes % 60
	return string.format("%02d:%02d:%02d", hours, minutes, seconds)  
end

local function getTargetName()
	local name, targetType, actionName, isOwned = GetLootTargetInfo()
	if name ~= "" then
		if targetType == INTERACT_TARGET_TYPE_ITEM then
			name = zo_strformat(SI_TOOLTIP_ITEM_NAME, name)
		elseif targetType == INTERACT_TARGET_TYPE_OBJECT then
			name = zo_strformat(SI_LOOT_OBJECT_NAME, name)
		elseif targetType == INTERACT_TARGET_TYPE_FIXTURE then
			name = zo_strformat(SI_TOOLTIP_FIXTURE_INSTANCE, name)
		end
	end
	VAR_CURRENT_TARGET = name
	return name
end

local function isQuestRewardTickets(data)
	return data.rewardType == REWARD_TYPE_EVENT_TICKETS
end

local function isLootRewardTickets(data)
	return data.currencyType == CURT_EVENT_TICKETS
end

local function getQuestAmount(data)
	local numTickets = data.amount
	return numTickets
end

local function getLootAmount(data)
	local numTickets = data.currencyAmount
	return numTickets
end

---------------------------------------------------------------------------------------------------------------
-- hook locals
---------------------------------------------------------------------------------------------------------------
local BLANK_DATA = {}
local NUM_VISIBLE_LOOT_SLOTS = 5
local DATA_TYPE_LOOT_BLANK = 2

local PLATFORM_GAMEPAD = 'GP'
local PLATFORM_KEYBOARD = 'KB'

-- Exclude event tickets from "Loot All" when tickets would accede max
local function lootAll()
	local lootData = LOOT_SHARED:GetSortedLootData()
	for _, data in ipairs(lootData) do
		if data.currencyType then
			if data.currencyType ~= CURT_EVENT_TICKETS then
				LootCurrency(data.currencyType)
			end
		else
			LootItemById(data.lootId)
		end
	end
end

local function getPlatformMode(isGamepad)
	return isGamepad and PLATFORM_GAMEPAD or PLATFORM_KEYBOARD
end

local platformLootTemplate = {
	[PLATFORM_GAMEPAD] = {
		getList = function(self)
			local list = self.itemList
			self.itemList:Clear()
			return list
		end,
		finalize = function(self, scrollList, tooManyTickets)
			self.itemCount = self.itemList:GetNumEntries()

			if self.intialLootUpdate then
				self.itemList:CommitWithoutReselect()
			else
				self.itemList:Commit()
			end
			
			if tooManyTickets then
				-- set the "loot all" button to one that will not loot tickets 
				zo_callLater(function()
					KEYBIND_STRIP.keybinds["UI_SHORTCUT_SECONDARY"].callback = lootAll
				end, 50)
			end
		end,
		addEntry = function(list, entryData)
			list:AddEntry("ZO_GamepadItemSubEntryTemplate", entryData)
		end,
		new = function(data)
			local entryData
			if data.currencyType then
				local currencyIcon = GetCurrencyLootGamepadIcon(data.currencyType)
				entryData = ZO_GamepadEntryData:New(data.name, currencyIcon)
				entryData.currencyType = data.currencyType
				entryData.currencyAmount = data.currencyAmount
				
				local NO_LOOT_ID = nil
				local NO_DISPLAY_QUALITY = nil
				local NO_VALUE = nil
				local NOT_QUEST_ITEM = nil

				entryData:InitializeLootVisualData(NO_LOOT_ID, data.currencyAmount, NO_DISPLAY_QUALITY, NO_VALUE, NOT_QUEST_ITEM, data.isStolen)
			else
				entryData = ZO_GamepadEntryData:New(data.name, data.icon)
				entryData:InitializeLootVisualData(data.lootId, data.count, data.displayQuality, data.value, data.isQuest, data.isStolen, data.itemType)
			end
			
			if entryData.isStolen then
				entryData:AddIcon(VAR_ICON_STOLEN)
			end
			
			return entryData
		end,
	},
	[PLATFORM_KEYBOARD] = {
		getList = function(self)
			local scrollData = ZO_ScrollList_GetDataList(self.list)
			ZO_ScrollList_Clear(self.list)
			return scrollData
		end,
		finalize = function(self, scrollData, tooManyTickets)
			self.itemCount = #scrollData

			for i = #scrollData + 1, NUM_VISIBLE_LOOT_SLOTS do
				scrollData[#scrollData + 1] = ZO_ScrollList_CreateDataEntry(DATA_TYPE_LOOT_BLANK, BLANK_DATA)
			end

			ZO_ScrollList_Commit(self.list)

			if tooManyTickets then
				-- set the loot "all button" to one that will not loot tickets
				self.buttons[1]:SetCallback(lootAll)
			end
		end,
		addEntry = function(scrollData, entryData)
			local DATA_TYPE_LOOT_ITEM = 1
			local scrollEntryData = ZO_ScrollList_CreateDataEntry(DATA_TYPE_LOOT_ITEM, entryData)
			table.insert(scrollData, scrollEntryData)
		end,
		new = function(entryData)
            if entryData.currencyType then
                entryData.icon = GetCurrencyLootKeyboardIcon(entryData.currencyType)
            end
			return entryData 
		end,
	}
}

local function getPlatformLootTemplate(isGamepad)
	return platformLootTemplate[getPlatformMode(isGamepad)]
end

---------------------------------------------------------------------------------------------------------------
-- Event Ticket Saver
---------------------------------------------------------------------------------------------------------------
local EventTicketSaver = ZO_InitializingObject:Subclass()

function EventTicketSaver:Initialize(control)
	self.control = control
	zo_mixin(self, addonData)
	
	self.registered = {}
	
	local function OnLoaded(_, name)
		if name ~= self.name then return end
		self.control:UnregisterForEvent(EVENT_ADD_ON_LOADED)
		
		self.savedVars = ZO_SavedVars:NewAccountWide(self.prefix .. "_SavedVars", svVersion, nil, defaults, GetWorldName())
		self.savedVars.eventInfo = self.savedVars.eventInfo
		
		self:SetupSettings()

		control:SetHandler("OnMoveStop", function() self:OnMoveStop(control) end)
		control:SetMovable(not self.savedVars.locked)
		self:UpdateFragemnt()

		local function OnGamepadPreferredModeChanged()
			IS_GAMEPAD = IsInGamepadPreferredMode()
		end
		ZO_PlatformStyle:New(OnGamepadPreferredModeChanged)
	end
	control:RegisterForEvent( EVENT_ADD_ON_LOADED, OnLoaded)
	
	local function onPlayerActivated()
		self.control:UnregisterForEvent(EVENT_PLAYER_ACTIVATED)
		VAR_TICKETS_CURRENT = GetCurrencyAmount(CURT_EVENT_TICKETS, CURRENCY_LOCATION_ACCOUNT)
		self:RegisterCallback()
	--	d( self.displayName .. " version: " .. self.version)
	end
	self.control:RegisterForEvent(EVENT_PLAYER_ACTIVATED, onPlayerActivated)

	local function onCommandEntered(arg)
		local num = tonumber(arg)
		if num == nil then
			-- need to make string for instructions
			return
		end
		self.savedVars.eventInfo.dailyTickets = num
	end
	SLASH_COMMANDS["/ija_setdaily"] = onCommandEntered
	
end

function EventTicketSaver:RefreshGamepadMenu()
	if not IsInGamepadPreferredMode() then return end
	if SCENE_MANAGER:IsShowing("mainMenuGamepad") then
		MAIN_MENU_GAMEPAD:RefreshLists()
	end
end

function EventTicketSaver:GetAutoCancel()
	return (self.savedVars.autoCancel or false)
end

function EventTicketSaver:GetEventIndex()
	local eventInfo = self.savedVars.eventInfo or {}
	return eventInfo.eventIndex
end

function EventTicketSaver:RegisterCallback()
	self.currentEvent = {}
	local function onSeasonalEventUpdate(active, eventObject)
		if active then
			if eventObject:GetType() == VAR_EVENT_TYPE_TICKETS then
				self.currentEvent = eventObject
				if not eventObject:IsSameEvent(self:GetEventIndex()) then
					-- start new event
					self:SetupEvent(eventObject)
					self.eventActive = false
				else
					-- reset for dailies?
					self:ResetDailyInfo()
				end
				self:UpdateDailyIconTexture()
			else
				active = false
			end
		end
		
		self:ChangeState(active)
	end
	
	IJA_Seasonal_Event_Manager:RegisterUpdateCallback(onSeasonalEventUpdate)
end

function EventTicketSaver:SetupEvent(eventObject)
	local dailyMax = eventObject:GetMaxDailyRewards()
	self.savedVars.eventInfo = {
		['eventIndex']		= eventObject:GetIndex(),
		['dailyMax']		= dailyMax,
		['dailyTickets']	= dailyMax,
		['rewardType']		= eventObject:GetRewardsBy(),
		['discoveredFrom']	= {},
	}

--	self.currentEvent = eventObject
	self:UpdateResetTime()
end

function EventTicketSaver:RegisterEvents()
	local function onPlayerActivated()
		if self.savedVars.eventActive and self:AreTicketsAvailible() then
			if IJA_EVENTTICKETSAVER_FRAGMENT_HUD then
				HUD_SCENE:AddFragment(IJA_EVENTTICKETSAVER_FRAGMENT_HUD)
			end
		end
	end
	self.control:RegisterForEvent(EVENT_PLAYER_ACTIVATED, onPlayerActivated)
	
	local function onCurrencyUpdate(eventId, currencyType, currencyLocation, newAmount, oldAmount, reason, reasonInfo)
		if currencyType == CURT_EVENT_TICKETS then
			self:AcquiredDiscoveredTicket()
			if newAmount >= oldAmount then
				-- to set the check-mark if all dailies have been acquired
			end
			self:UpdateDailyIconTexture()
			VAR_TICKETS_CURRENT = newAmount
		end
	end
	self.Test_onCurrencyUpdatet = function(self, newAmount, oldAmount)
		onCurrencyUpdate(0, CURT_EVENT_TICKETS, currencyLocation, newAmount, oldAmount, reason, reasonInfo)
	end
	self.control:RegisterForEvent(EVENT_CURRENCY_UPDATE, onCurrencyUpdate)
	self.control:AddFilterForEvent(EVENT_CURRENCY_UPDATE, 0, CURT_EVENT_TICKETS)
	
	if self.currentEvent then
--	if self.savedVars.eventInfo.rewardsBy == VAR_EVENT_TYPE_TARGET then
		if self.currentEvent:GetRewardsBy() == VAR_EVENT_TYPE_TARGET then
			-- set to show cake timer
			-- initialize reticle hook
			self:InitializeForTargetTickets()
			self:InitializeForLootTickets()
		else
			-- initialize hooks
			self:InitializeForQuestTickets()
			self:InitializeForLootTickets()
		
		end
	end
	
	self.eventRegistered = true
end

function EventTicketSaver:UnregisterEvents()
	self.control:UnregisterForEvent(EVENT_CURRENCY_UPDATE)
	self.control:UnregisterForEvent(EVENT_PLAYER_ACTIVATED)
	self.control:UnregisterForEvent(EVENT_QUEST_COMPLETE_DIALOG)
    self.control:UnregisterForEvent(EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
end

function EventTicketSaver:UpdateResetTime()
	self.savedVars.resetTime = GetTimeStamp() + getDailyResetTimeRemainingSeconds()
end

function EventTicketSaver:OnCooldown()
	return self:GetResetTimeRemaining() > 0
end

function EventTicketSaver:GetResetTimeRemaining()
	local resetTime = self.savedVars.resetTime or 0
	return math.floor(resetTime - GetTimeStamp())
end

---------------------------------------------------------------------------------------------------------------
-- 
---------------------------------------------------------------------------------------------------------------
function EventTicketSaver:Activate()
--	d( '---------- EventTicketSaver:Activate()')
	self.savedVars.eventActive = true
		
	if not self.fragments then
		self:InitializeFragments()
		self.fragments = true
	end
	
	GAME_MENU_SCENE:AddFragment(IJA_EVENTTICKETSAVER_MENU_FRAGMENT)
	HUD_SCENE:AddFragment(IJA_EVENTTICKETSAVER_FRAGMENT_HUD)
		
	self:RegisterEvents()
	self:UpdateDailyIconTexture()
end

function EventTicketSaver:ChangeState(eventActive)
	if eventActive then
		if not self.eventActive then
			self:Activate()
		end
	elseif self.eventActive then
		 self:Deactivate()
	end
	
	self.eventActive = self.savedVars.eventActive
	self:RefreshGamepadMenu()
end

function EventTicketSaver:CleanUp()
	self.savedVars.eventInfo = {}
	self.savedVars.resetTime = 0
	self.currentEvent = nil
end

function EventTicketSaver:Deactivate()
--	d( '---------- EventTicketSaver:Deactivate')
	unregisterOnTryHandlingInteraction(self.name, LIB_IF_GAMECAMERAACTION_USE)
--	unregisterOnTryHandlingInteraction(self.name)
	self.savedVars.eventActive = false
	self:CleanUp()

	self:UnregisterEvents()
	GAME_MENU_SCENE:RemoveFragment(IJA_EVENTTICKETSAVER_MENU_FRAGMENT)
	
end

function EventTicketSaver:GetTicketInfo()
	return self.savedVars.eventInfo.discoveredTickets or 0, self.savedVars.eventInfo.dailyTickets or 0, self.savedVars.eventInfo.dailyMax or 0
end

function EventTicketSaver:IsKnownEvent()
	return self.savedVars.eventInfo.rewardsBy ~= VAR_EVENT_TYPE_UNKNOWN
end

function EventTicketSaver:ResetDailyInfo()
	local discoveredTickets, dailyTickets, dailyMax = self:GetTicketInfo()
	if dailyTickets ~= dailyMax then
		self.savedVars.eventInfo.dailyMax = dailyTickets
	end
	
	-- I don't want it to refresh dailies if is on cooldown. This is to prevent it from resetting on load.
	if self:OnCooldown() then return end
	self:UpdateResetTime()
	
	self.savedVars.eventInfo.discoveredTickets = 0
	self.savedVars.eventInfo.discoveredFrom = {}
	self.savedVars.eventInfo.ticketsAcquired = {}
end

function EventTicketSaver:UpdateDailyIconTexture()
	local discoveredTickets, dailyTickets, dailyMax = self:GetTicketInfo()
	
	if self:HasAcquiredTickets() then
		VAR_TEXTURE_DAILY = VAR_TEXTURE_ALL[VAR_ICON_INDEX3]
	else
		if dailyMax > 0 then
			-- on event identified
			VAR_TEXTURE_DAILY = VAR_TEXTURE_ALL[VAR_ICON_INDEX0]
		else
			VAR_TEXTURE_DAILY = VAR_TEXTURE_ALL[VAR_ICON_INDEX1]
		end
	end
	self:RefreshGamepadMenu()
end

function EventTicketSaver:AcquiredDiscoveredTicket()
	if VAR_CURRENT_TARGET and VAR_CURRENT_TARGET ~= '' then
		local ticketsAcquired = self.savedVars.eventInfo.ticketsAcquired or {}
		ticketsAcquired[VAR_CURRENT_TARGET] = true
		self.savedVars.eventInfo.ticketsAcquired = ticketsAcquired
	end
end

function EventTicketSaver:HasAcquiredDiscoveredTicket(targetName)
	local ticketsAcquired = self.savedVars.eventInfo.ticketsAcquired or {}
	
	return ticketsAcquired[targetName] ~= nil
end

function EventTicketSaver:HasAcquiredAllDiscoveredTickets()
	local discoveredFrom = self.savedVars.eventInfo.discoveredFrom or {}
	
	for targetName, v in pairs(discoveredFrom) do
		if not self:HasAcquiredDiscoveredTicket(targetName) then
			return false
		end
	end
	
	return true
end

function EventTicketSaver:HasAcquiredTickets()
	local ticketsAcquired = self.savedVars.eventInfo.ticketsAcquired or {}
	
	return NonContiguousCount(ticketsAcquired) > 0
end



---------------------------------------------------------------------------------------------------------------
-- Handel daily tickets
---------------------------------------------------------------------------------------------------------------
function EventTicketSaver:AreTicketsAvailible()
	local discoveredTickets, dailyTickets, dailyMax = self:GetTicketInfo()
	local ticketsAvaible = dailyTickets - discoveredTickets
	
	-- check the need to update daily tickets
	if ticketsAvaible < 0 then
		if discoveredTickets > dailyTickets then
			self:UpdateDailyIfNeeded()
			return self:AreTicketsAvailible()
		end
	end
	
	return ticketsAvaible > 0
end

function EventTicketSaver:UpdateDailyIfNeeded()
	local discoveredTickets, dailyTickets, dailyMax = self:GetTicketInfo()
	-- if dailyMax has been set previously.
	if discoveredTickets > dailyTickets then
		self.savedVars.eventInfo.dailyTickets = discoveredTickets
	end
end

function EventTicketSaver:IsInteractionBlocked(interactableName, offeredTickets)
	if self:AreTicketsAvailible() then
		if wouldTicketsExceedMax(offeredTickets) then
			if self.savedVars.autoCancel then
				return self.savedVars.eventInfo.discoveredTickets > 0
			end
		end
	end
	return false
end

function EventTicketSaver:OnTicketsDiscovered(discoveredTickets, targetName, currentTime)
	-- we still need to ensure that once tickets are discovered they will not be added again
	-- this is primarily to update dailyTickets and, dailyMax
	if targetName == VAR_EMPTY_STRING then return end
	-- Only discover tickets once per target.
	local discoveredFrom = self.savedVars.eventInfo.discoveredFrom or {}
	
	if not discoveredFrom[targetName] or discoveredFrom[targetName] < currentTime then
		-- reset it after 5 minutes
		discoveredFrom[targetName] = currentTime + 300
		self.savedVars.eventInfo.discoveredFrom = discoveredFrom

		self:AddDiscoveredTickets(discoveredTickets)
	end
end

-- discoveredTickets are not acquired tickets
--	/script IJA_EVENTTICKETSAVER:AddDiscoveredTickets(3)
function EventTicketSaver:AddDiscoveredTickets(discoveredTickets)
	local previousTickets, dailyTickets, dailyMax = self:GetTicketInfo()
	
	self.savedVars.eventInfo.discoveredTickets = previousTickets + discoveredTickets
	
	self:RefreshGamepadMenu()
end

function EventTicketSaver:IsTargetForTickets(targetName)
	local targets = self.currentEvent.targets or {}
	return targets[targetName] ~= nil
end

---------------------------------------------------------------------------------------------------------------
-- Seasonal event handlers
---------------------------------------------------------------------------------------------------------------
function EventTicketSaver:InitializeForLootTickets()
	if self.registered["UpdateList"] then return end

	local function updateDiscoveredTickets(discoveredTickets, targetName)
		self:OnTicketsDiscovered(discoveredTickets, targetName, GetTimeStamp())
	end
	self.Test_updateOfferedTickets_loot = updateDiscoveredTickets

		local function updateList(object, lootTemplate)
			-- lootTemplate is a set of function that handle loot differently for each game mode.
			local scrollList = lootTemplate.getList(object)
			
			object.itemCount = 0
			-- Assume that there's only stolen stuff present in this window until proven otherwise
			object.nonStolenItemsPresent = false

			local lootData = LOOT_SHARED:GetSortedLootData()
			local tooManyTickets
			local numTickets = 0
			

			for _, data in ipairs(lootData) do
				local entryData = lootTemplate.new(data)
				
				if isLootRewardTickets(data) then
					numTickets = getLootAmount(data)
					
					updateDiscoveredTickets(numTickets, getTargetName())
					
					tooManyTickets = wouldTicketsExceedMax(numTickets)
					
					local textColor = getDialogTextColor(tooManyTickets)
					entryData.text = zo_strformat(textColor:Colorize(GetString(SI_IJA_EVENTTICKETSAVER_OPTIONTEXT)), VAR_TICKETS_CURRENT, VAR_TICKETS_MAX, entryData.name)
				end
				
				lootTemplate.addEntry(scrollList, entryData)
			
			--	d( data.lootId)
				if not data.isStolen then
					object.nonStolenItemsPresent = true
				end
			end
			
			lootTemplate.finalize(object, scrollList, tooManyTickets)
			
			if tooManyTickets then
				ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NEGATIVE_CLICK, GetString(SI_IJA_EVENTTICKETSAVER_ALERT))
			end
			-- this text depends on the list itself
			object:UpdateAllControlText()
			return numTickets > 0
		end
		
		ZO_PreHook(LOOT_WINDOW, "UpdateList", function(self)
			return updateList(self, getPlatformLootTemplate(false))
		end)
		
		ZO_PreHook(LOOT_WINDOW_GAMEPAD, "UpdateList", function(self)
			return updateList(self, getPlatformLootTemplate(true))
		end)
	
	self.registered["UpdateList"] = true
end

function EventTicketSaver:InitializeForTargetTickets()
	unregisterOnTryHandlingInteraction(self.name, LIB_IF_GAMECAMERAACTION_USE)
	
	local function getInterationInfo(action, interactableName)
		local discoveredTickets, dailyTickets, dailyMax = self:GetTicketInfo()
	
		local interactKeybindButtonColor = ZO_NORMAL_TEXT
		local additionalInfoLabelColor = ZO_NORMAL_TEXT
		
		-- Use dailyTickets since that will be the number offered on looting.
		local interactionBlocked = self:IsInteractionBlocked(interactableName, dailyTickets)
		local additionalInfoText, interactKeybindButtonText
		
		if self:HasAcquiredDiscoveredTicket(interactableName) then
			additionalInfoText = zo_strformat(SI_IJA_EVENTTICKETSAVER_TARGET_TIMER, getTimeString(getDailyResetTimeRemainingSeconds()))
			interactKeybindButtonText = action
		else
			if wouldTicketsExceedMax(dailyTickets) then
				interactKeybindButtonColor = ZO_ERROR_COLOR
			end
			additionalInfoText = GetString(SI_IJA_EVENTTICKETSAVER_TICKETS_AVAILABLE)
			interactKeybindButtonText = zo_strformat(SI_IJA_EVENTTICKETSAVER_OPTIONTEXT, VAR_TICKETS_CURRENT, VAR_TICKETS_MAX, action)
		end
		
		return additionalInfoText, interactKeybindButtonText, interactionBlocked, interactKeybindButtonColor, additionalInfoLabelColor
	end
	
	local function tryHandlingInteraction(action, interactableName, currentFrameTimeSeconds)
		if action and interactableName then
			if self.savedVars.eventActive and self:IsTargetForTickets(interactableName) then
				local additionalInfoText, interactKeybindButtonText, interactionBlocked, interactKeybindButtonColor, additionalInfoLabelColor = getInterationInfo(action, interactableName)
				
				RETICLE.interactKeybindButton:ShowKeyIcon()
				RETICLE.interact:SetHidden(false)
				
				RETICLE.interactContext:SetText(interactableName) -- "Jubilee Cake" .. currentYear
	------------------------------------additionalInfo----------------------------------------------------
				RETICLE.additionalInfo:SetText(additionalInfoText) -- "Tickets Available" or time remaining
				RETICLE.additionalInfo:SetColor(additionalInfoLabelColor:UnpackRGBA())
				RETICLE.additionalInfo:SetHidden(false)
				
	------------------------------------------------------------------------------------------------------
				RETICLE.interactKeybindButton:SetText(interactKeybindButtonText) -- cur/max Use or Use
				RETICLE.interactKeybindButton:SetNormalTextColor(interactKeybindButtonColor)
				return true
			end
		end
		return false
	end
	
	registerOnTryHandlingInteraction(self.name, LIB_IF_GAMECAMERAACTION_USE, function(action, interactableName, interactionBlocked, isOwned, additionalInteractInfo, context, contextLink, isCriminalInteract, currentFrameTimeSeconds)
		if self:IsTargetForTickets(interactableName) then
			return tryHandlingInteraction(action, interactableName, currentFrameTimeSeconds)
		end
	end)
end

function EventTicketSaver:InitializeForQuestTickets()
	local g_Interact
	
	local function updateDiscoveredTickets(discoveredTickets)
		self:OnTicketsDiscovered(discoveredTickets, getTargetName(), GetTimeStamp())
	end
	self.Test_updateOfferedTickets_quest = updateDiscoveredTickets

	local function closeChatter()
		-- Platform based close interact dialogue.
		g_Interact:CloseChatter()
	end
	
	local function updateOptionText()
		g_Interact:DimOtherImportantOptions(g_Interact.currentMouseLabel)
	end
	
	local function completeQuest()
		CompleteQuest()
		closeChatter()
	end
	
	local function automateTurnIn(ticketData)
		ticketData.isImportant = false
		
		if wouldTicketsExceedMax(getQuestAmount(ticketData)) then
			ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NEGATIVE_CLICK, GetString(SI_IJA_EVENTTICKETSAVER_ALERT))
			if self.savedVars.autoCancel then
				closeChatter()
				return TRADING_HOUSE_RESULT_INVALID_GUILD_ID
			end
			ticketData.isImportant = true
		else
			if self.savedVars.autoComplete then
				completeQuest()
				return true
			end
		end
	end
	
	local function refreshInteraction(ticketData, journalQuestIndex)
		if not automateTurnIn(ticketData) then
			local goalCondition, endDialog, confirmComplete, declineComplete = GetJournalQuestEnding(journalQuestIndex)
				
			if(confirmComplete == "") then  confirmComplete = GetString(SI_DEFAULT_QUEST_COMPLETE_CONFIRM_TEXT) end
			if(declineComplete == "") then  declineComplete = GetString(SI_DEFAULT_QUEST_COMPLETE_DECLINE_TEXT) end
			
			g_Interact:InitializeInteractWindow(endDialog)
		--	g_Interact:InitializeInteractWindow(GetChatterGreeting()) -- used for testing
			
			local confirmError = g_Interact:ShowQuestRewards(journalQuestIndex)
			if confirmError then
				confirmComplete = zo_strformat(SI_QUEST_COMPLETE_FORMAT_STRING, confirmComplete, confirmError)
			end
			
			local confirmComplete = zo_strformat(SI_IJA_EVENTTICKETSAVER_OPTIONTEXT, VAR_TICKETS_CURRENT, VAR_TICKETS_MAX, confirmComplete)
			
			local importantOptions = {}
			g_Interact:PopulateChatterOption(1, completeQuest, confirmComplete, CHATTER_COMPLETE_QUEST, ticketData.optionalArg, ticketData.isImportant, chosenBefore, importantOptions)
			
			g_Interact:PopulateChatterOption(2, closeChatter, declineComplete, CHATTER_GOODBYE)
			g_Interact:FinalizeChatterOptions(2)
			
			g_Interact.importantOptions = importantOptions
			
			jo_callLater(ADDON_SHORT_NAME, updateOptionText, 50)
		end
	end
	
	local function onQuestComplete(_, journalQuestIndex)
		g_Interact = SYSTEMS:GetObject(ZO_INTERACTION_SYSTEM_NAME)
		local rewardDataList = g_Interact:GetRewardData(journalQuestIndex, IS_GAMEPAD)
		
		if #rewardDataList == 0 then return end
		-- We only need to refresh the interaction if event tickets are present.
		for i, data in ipairs(rewardDataList) do
			if isQuestRewardTickets(data) then
				local questName = GetJournalQuestName(journalQuestIndex)

			--	updateDiscoveredTickets(getQuestAmount(data), GetUnitName("interact"))
				updateDiscoveredTickets(getQuestAmount(data))
				return refreshInteraction(data, journalQuestIndex)
			end
		end
	end
	
	self.control:UnregisterForEvent(EVENT_QUEST_COMPLETE_DIALOG)
	self.control:RegisterForEvent(EVENT_QUEST_COMPLETE_DIALOG, onQuestComplete)
	
	-- DimOtherImportantOptions does not exist for gamepad mode so we create a dummy function to prevent errors.
	GAMEPAD_INTERACTION.DimOtherImportantOptions = function() end
end

---------------------------------------------------------------------------------------------------------------
-- fragments
---------------------------------------------------------------------------------------------------------------
local VAR_ICON_FORMAT0 = 0
local VAR_ICON_FORMAT1 = 1
local VAR_ICON_FORMAT2 = 2

local function updateHeaderFonts(control, fonts) -------------<
	ZO_FontAdjustingWrapLabel_OnInitialized(control, fonts, TEXT_WRAP_MODE_ELLIPSIS)
end

local iconFormatters = {
	[VAR_ICON_FORMAT0] = function(texture, size, color)
		return texture
	end,
	[VAR_ICON_FORMAT1] = function(texture, size, color)
		return zo_iconFormat(texture, size, size)
	end,
	[VAR_ICON_FORMAT2] = function(texture, size, color)
		return color:Colorize(zo_iconFormatInheritColor(texture, size, size))
	end,
}

local function getFormattedIcon(texture, size, color)
	local format = (color ~= nil) and 2 or (size ~= nil) and 1 or 0
	local formatIcon = iconFormatters[format]
	return formatIcon(texture, size, color)
end

local function getFragmentIcon(known, discovered, daily)
	local color = ZO_SELECTED_TEXT
	
	if known then
		if discovered == daily then
			color = VAR_COLOR_COMPLETE
		end
	else
		color = VAR_COLOR_NOTICE
	end

	return getFormattedIcon(VAR_TEXTURE_DAILY), color
end

local function getInfoForTickets()
	local color = VAR_TICKETS_CURRENT == VAR_TICKETS_MAX and ZO_ERROR_COLOR
	return VAR_TICKETS_CURRENT, VAR_TICKETS_MAX, color
end

local function getInfoForDailies(known)
	local discoveredTickets, dailyTickets = IJA_EVENTTICKETSAVER:GetTicketInfo()
	dailyTickets = known and dailyTickets or '?'
	return discoveredTickets, dailyTickets
end

---------------------------------------------------------------------------------------------------------------
local Fragment_Row = ZO_InitializingObject:Subclass()

function Fragment_Row:Initialize(control)
	self.control = control
	self.name = control:GetNamedChild("Name")
	self.values = control:GetNamedChild("Values")
	self.icon = control:GetNamedChild("Icon")
end

function Fragment_Row:UpdateLabel(label, low, max, color)
	color = color or ZO_SELECTED_TEXT
	
	self.name:SetText(label)
	self.values:SetText(zo_strformat(SI_UNIT_FRAME_BARVALUE, low, max))
	self.values:SetColor(color:UnpackRGB())
end

function Fragment_Row:UpdateIcon(texture, color)
	self.icon:SetTexture(texture)
	self.icon:SetColor(color:UnpackRGB())
	self.icon:SetHidden(texture == '')
end

---------------------------------------------------------------------------------------------------------------
-- 
---------------------------------------------------------------------------------------------------------------
local Fragmet_Class = {}

function Fragmet_Class:DeferedInitialize(control, savedVars)
	self.savedVars = savedVars
	self.tickets = Fragment_Row:New(control.tickets)
	self.daily = Fragment_Row:New(control.daily)
	
	self:Update()
end

function Fragmet_Class:OnShown()
	if self.savedVars.eventActive then
		if(self.state == SCENE_FRAGMENT_SHOWING) then
			ZO_SceneFragment.OnShown(self)
		end
		
		self:Update()
		self:Callback()
	else
		self:Hide()
	end
end

function Fragmet_Class:Update()
	local IS_UPPER = false
	local IS_PLURAL = true
	local known = self:IsKnownEvent()

	local current, max, color = getInfoForTickets()
	self.tickets:UpdateLabel(GetCurrencyName(CURT_EVENT_TICKETS, IS_PLURAL, IS_UPPER), current, max, color)

	local discovered, daily = getInfoForDailies(known)
	self.daily:UpdateLabel(GetString(SI_TIMEDACTIVITYTYPE0), discovered, daily)

	local texture, textureColor = getFragmentIcon(known, discovered, daily)
	self.daily:UpdateIcon(texture, textureColor)
end

function Fragmet_Class:IsKnownEvent()
	return IJA_EVENTTICKETSAVER:IsKnownEvent()
end

function Fragmet_Class:Callback()
end

---------------------------------------------------------------------------------------------------------------
local FadeSceneFragment = ZO_Object:MultiSubclass(Fragmet_Class, ZO_AnimatedSceneFragment)

function FadeSceneFragment:New(control, savedVars)
	local newFragment = ZO_AnimatedSceneFragment.New(self, "FadeSceneAnimation", control, true, duration)
	newFragment:DeferedInitialize(control, savedVars)
	return newFragment
end

---------------------------------------------------------------------------------------------------------------
local HUDFadeSceneFragment = ZO_Object:MultiSubclass(Fragmet_Class, ZO_HUDFadeSceneFragment)

function HUDFadeSceneFragment:New(control, savedVars)
	local newFragment = ZO_HUDFadeSceneFragment.New(self, control)
	newFragment:DeferedInitialize(control, savedVars)
	return newFragment
end

function HUDFadeSceneFragment:Callback()
	local function removeFragment()
		HUD_SCENE:RemoveFragment(self)
	end
	
	local delayInTicks = self.savedVars.secondsToShow * 1000
	zo_callLater(removeFragment, delayInTicks)
end

---------------------------------------------------------------------------------------------------------------
-- 
---------------------------------------------------------------------------------------------------------------
function EventTicketSaver:InitializeFragments()
	IJA_EVENTTICKETSAVER_MENU_FRAGMENT = FadeSceneFragment:New(IJA_EventTicketSaver, self.savedVars)
	IJA_EVENTTICKETSAVER_FRAGMENT_HUD = HUDFadeSceneFragment:New(IJA_EventTicketSaver, self.savedVars)
	
	self:UpdateFragemnt()
	self:GamepadMainMenuHeaderSetup()
end

do
	local _known, _discovered, _daily

	local function ticketsHeader()
		local texture = getFormattedIcon(VAR_TEXTURE_TICKETS, 48)
		return zo_strformat(SI_STATS_RACE_CLASS, texture, GetCurrencyName(CURT_EVENT_TICKETS, IS_PLURAL, IS_UPPER))
	end
	
	local function dailyHeader()
		local color
		
		if _known then
			if _discovered == _daily then
				color = VAR_COLOR_COMPLETE
			end
		else
			color = VAR_COLOR_NOTICE
		end
		
		local texture = getFormattedIcon(VAR_TEXTURE_DAILY, 48, color)
		return zo_strformat(SI_STATS_RACE_CLASS, texture, GetString(SI_TIMEDACTIVITYTYPE0))
	end

	local function resetHeader()
		return zo_strformat(SI_DAILY_LOGIN_REWARDS_CHANGES_IN, '' )
	end

	local function ticketsValues()
		local current, max, color = getInfoForTickets()
		color = color or ZO_SELECTED_TEXT
		return color:Colorize(zo_strformat(SI_UNIT_FRAME_BARVALUE, current, max))
	end

	local function dailyValues()
		return zo_strformat(SI_UNIT_FRAME_BARVALUE, _discovered, _daily)
	end

	local function resetTime(control)
		control:SetHandler('OnUpdate', function()
			control:SetText(ZO_FormatTime(getDailyResetTimeRemainingSeconds(), TIME_FORMAT_STYLE_COLONS, TIME_FORMAT_PRECISION_TWELVE_HOUR))
		end)
		-- must return something or control will be hidden
		return ''
	end

	function EventTicketSaver:GamepadMainMenuHeaderSetup()
		local MODE_MAIN_LIST = 1

		local main_menu_gamepad = MAIN_MENU_GAMEPAD
		local header = main_menu_gamepad.header
		local headerContainer = main_menu_gamepad.headerContainer
		
		local headerData =
		{
			titleText = self.displayName,
			
			data1HeaderText = ticketsHeader,
			data1Text = ticketsValues,

			data2HeaderText = dailyHeader,
			data2Text = dailyValues,
			
			data3HeaderText = resetHeader,
			data3Text = resetTime,
		}

		local HEADER_STATE_HIDDEN = 0
		local HEADER_STATE_VISIBLE = 1
		local function getHeaderState(mode)
			if self.eventActive and mode == MODE_MAIN_LIST then
				return HEADER_STATE_VISIBLE
			end
			return HEADER_STATE_HIDDEN
		end

		local oldState = 0
		local function hasHeaderStateChanged(newState)
			if oldState ~= newState then
				oldState = newState
				return true
			end
			return false
		end
		
		local function reanchorList(list, headerState)
			-- If event is active, anchor the category list below the header to prevent 
			-- entries from scrolling under the header.

			local control = list:GetControl()
			local container = control:GetParent()
			control:ClearAnchors()
			if headerState == HEADER_STATE_HIDDEN then
				control:SetAnchorFill(container)
			else
				control:SetAnchor(TOPLEFT, headerContainer, BOTTOMLEFT, 0, 20)
				control:SetAnchor(BOTTOMRIGHT, nil, BOTTOMRIGHT)
			end
		end

		local function updateHeaderVisibility(headerState)
			if hasHeaderStateChanged(headerState) then
				header:SetHidden(headerState == HEADER_STATE_HIDDEN)
				reanchorList(main_menu_gamepad.mainList, headerState)
			end
		end

		ZO_PostHook(main_menu_gamepad, 'RefreshLists', function(self)
			local headerState = getHeaderState(self.mode)
			updateHeaderVisibility(headerState)

			if headerState == HEADER_STATE_VISIBLE then
				_known = IJA_EVENTTICKETSAVER:IsKnownEvent()
				
				_discovered, _daily = getInfoForDailies(_known)
				ZO_GamepadGenericHeader_Refresh(header, headerData)
			end
		end)

		self.header = header
		self.headerData = headerData
	end
end

function EventTicketSaver:UpdateFragemnt()
	local alpha = self.savedVars.occupancy or 70
	IJA_EventTicketSaverBackground:SetAlpha(alpha * 0.01)
	self:SetAnchor()
end

function EventTicketSaver:OnMoveStop(control)
	local anchor = ZO_Anchor:New()
	anchor:SetFromControlAnchor(control, 0)
	self.savedVars.anchor = anchor
	self.savedVars.isMoved = true
end

function EventTicketSaver:SetAnchor()
	if self.savedVars.isMoved then
		local anchor = ZO_Anchor:New(self.savedVars.anchor)
		anchor:SetTarget(GuiRoot)
		anchor:Set(IJA_EventTicketSaver)
	else
		defaultAnchor:Set(IJA_EventTicketSaver)
	end
end

---------------------------------------------------------------------------------------------------------------
-- Settings menu
---------------------------------------------------------------------------------------------------------------
function EventTicketSaver:SetupSettings()
	local LAM2 = LibAddonMenu2
	if not LAM2 then
		return
	end

	local panelData = {
		type = "panel",
		name = self.displayName,
		displayName = self.displayName,
		author = "IsJustaGhost",
		version = self.version,
		registerForRefresh = true,
		registerForDefaults = true
	}
	LAM2:RegisterAddonPanel(self.prefix .. '_LAM', panelData)

	local optionsTable = {
		{
			type = "header",
			name = "",
			width = "full",
		},
		{
			type = "checkbox",
			name = GetString(SI_IJA_EVENTTICKETSAVER_AUTOCOMPLETE),
			tooltip = GetString(SI_IJA_EVENTTICKETSAVER_AUTOCOMPLETE_TOOLTIP),
			getFunc = function() return self.savedVars.autoComplete end,
			setFunc = function(value) self.savedVars.autoComplete = value end,
			width = "full"
		},
		{
			type = "checkbox",
			name = GetString(SI_IJA_EVENTTICKETSAVER_AUTOCLOSE),
			tooltip = GetString(SI_IJA_EVENTTICKETSAVER_AUTOCLOSE_TOOLTIP),
			getFunc = function() return self.savedVars.autoCancel end,
			setFunc = function(value) self.savedVars.autoCancel = value end,
			width = "full"
		},
		{ type = "divider",
			height = 10,
		},
		{ type = "slider",		-- dislplay time
			name = GetString(SI_IJA_EVENTTICKETSAVER_SHOWTIME),
			tooltip = GetString(SI_IJA_EVENTTICKETSAVER_SHOWTIME_TOOLTIP),
			min = 0.5,
			max = 10,
			step = 0.5,
			getFunc = function() return self.savedVars.secondsToShow end,
			setFunc = function(value) self.savedVars.secondsToShow = value
			end,
			width = "full",
		},
		{ type = "slider",		-- transparency
            name = GetString(SI_WORLD_MAP_OPTION_TRANSPARENCY),
			min = 0,
			max = 100,
			step = 10,
			getFunc = function() return self.savedVars.occupancy end,
			setFunc = function(value)
				self.savedVars.occupancy = value
				IJA_EventTicketSaverBackground:SetAlpha(value * 0.01)
			end,
			width = "full",
		},
		{ type = "submenu",
			name = 'Current event',
			controls = {
				{ type = "slider",		-- transparency
					name = 'Tickets per day',
					min = 1,
					max = 4,
					step = 1,
					getFunc = function() return self.savedVars.eventInfo.dailyTickets end,
					setFunc = function(value)
						self.savedVars.eventInfo.dailyTickets = value
						self.savedVars.eventInfo.dailyMax = value
					end,
					width = "full",
					disabled = disabled,
				},
			}
		},
		{ type = "checkbox",
            name = zo_iconFormat("/esoui/art/miscellaneous/gamepad/gp_icon_locked32.dds", "32", "32"), -- lock
            getFunc = function() return self.savedVars.locked end,
            setFunc = function(value)
				self.savedVars.locked = value
				IJA_EventTicketSaver:SetMovable(not value)
            end,
            width = "half",
        },
		{ type = "button",
			name = GetString(SI_INTERFACE_OPTIONS_FRAMERATE_LATENCY_POSITION_RESET),
			func = function()
				self.savedVars.isMoved = false
				self:UpdateFragemnt()
			end,
            width = "half",
		},
	}
	LAM2:RegisterOptionControls(self.prefix .. '_LAM', optionsTable)
end

-------------------------------------
function IJA_EventTicketSaver_Initialize( ... )
	IJA_EVENTTICKETSAVER = EventTicketSaver:New( ... )
end


--[[

/script IJA_EVENTTICKETSAVER:Test_onCurrencyUpdatet(2, 2)
/script IJA_EVENTTICKETSAVER:Test_updateOfferedTickets_quest(2)
"Sorinne Gaerard"

	/script IJA_EVENTTICKETSAVER.savedVars.eventInfo.ticketsAcquired = {}
	/script IJA_EVENTTICKETSAVER.savedVars.eventInfo.ticketsAcquired = {["Vyctoria Girien"] = true}
/script IJA_EVENTTICKETSAVER:OnTicketsDiscovered(2 , GetUnitName("interact"), GetFrameTimeSeconds())
/script IJA_EVENTTICKETSAVER:OnTicketsDiscovered(2 , GetUnitName("interact"), GetTimeStamp())
/script IJA_EVENTTICKETSAVER:AddDiscoveredTickets(2)
/script IJA_EVENTTICKETSAVER:InitializeForTargetTickets()
			self:InitializeForTargetTickets()
			
			
			ZO_ACTIVITY_FINDER_ROOT_MANAGER:SetLocationSelected(location, selected)
			
			
			
    EVENT_MANAGER:RegisterForEvent("ActivityFinderRoot_Manager", EVENT_HOLIDAYS_CHANGED, OnHolidaysChanged)

]]
