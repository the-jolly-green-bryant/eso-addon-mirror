--[[
This Add-on is not created by, affiliated with or sponsored by ZeniMax Media Inc. or its affiliates. 
The Elder Scrolls® and related logos are registered trademarks or trademarks of ZeniMax Media Inc. in the United States and/or other countries. 
All rights reserved

You can read the full terms at https://account.elderscrollsonline.com/add-on-terms]]

--[[
Acknowledgments

I'd like to thank the following people:
- Baertram

I'd like to thank the following addons:
- Miat's PVP Alerts by dorrino
- pChat by Ayantir
- CyrHUD by Sasky
]]

--[[
Categories:
1) Sieged Keep: like if a keep is under attack (not going to be, is and CyrHUD hasn't (or has) picked up on it yet)
2) Players: players heading to a keep, or player locations around a keep
3) Status of keep: good
4) Status of keep: lost
]]

-- Initialized the addon names
CyroChat = {}
CyroChat.name = "CyroChat"
CyroChat.version = 11.0

-- For the addon settings menu
CyroChat.LAM2 = LibAddonMenu2

CyroChat.playerInPvP = false
CyroChat.playerZoneId = nil
CyroChat.playerZone = ''
CyroChat.currentLayerIndex = 2
CyroChat.playerInCombat = false
CyroChat.playerCampaignId = 0
CyroChat.debugMode = false
CyroChat.lastMessagePrinted = ''

--Variable inside the addon to store the other addon states
CyroChat.otherAddons = {}

-- Saved beyond session variables
CyroChat.accountWideDefaults={
	accountWide=false
}

CyroChat.defaults={
	settings = {
		unlocked=true,
		showFeed=true,
		feedOffsetX=0,
		feedOffsetY=0,
		feedName=1,
		feedTimestamp=false,
		feedLocation=false,
		feedCombat=false,
		chatActiveCombat=true,
		feedAttackStatus=false,
		feedLocationSiege=false,
		notifySiege=false,
		notifyPlayer=false,
		notifyStatus=false,
		feedHeight=120,
		feedWidth=750,
		useCyrHud=true,
		onlyInGroup=false,
		notifyNotCyrHUD=false,
		playersIgnored='',
		listIgnorePlayers={},
		feedLocationBreach=false
	}
}

function CyroChat:Initialize()
	CyroChat.playerInPvP = IsPlayerInAvAWorld()

	CyroChat:CheckOtherAddonsActive("CyrHUD", CyrHUD)

	EVENT_MANAGER:RegisterForEvent(CyroChat.name, EVENT_PLAYER_ACTIVATED, CyroChat.OnPlayerActivated)
	EVENT_MANAGER:RegisterForEvent(CyroChat.name, EVENT_CHAT_MESSAGE_CHANNEL, CyroChat.onChatMessage)
	EVENT_MANAGER:RegisterForEvent(CyroChat.name, EVENT_ZONE_CHANGED, CyroChat.onZoneUpdate)
	EVENT_MANAGER:RegisterForEvent(CyroChat.name, EVENT_ACTION_LAYER_PUSHED, CyroChat.OnActionLayerChange)
	EVENT_MANAGER:RegisterForEvent(CyroChat.name, EVENT_ACTION_LAYER_POPPED, CyroChat.OnActionLayerChange)
	EVENT_MANAGER:RegisterForEvent(CyroChat.name, EVENT_PLAYER_COMBAT_STATE, CyroChat.onCombatState)
end

-- Loads the addon; only hit once
function CyroChat.OnAddOnLoaded(event, addonName)
	-- The event fires each time *any* addon loads; but we only care about when our own addon loads.
	if addonName ~= CyroChat.name then
		return
	end

	CyroChat.DS = ZO_SavedVars:NewAccountWide("CyroChatTrackerSettings", 1.0, "AccountWide", CyroChat.accountWideDefaults)

	if CyroChat.DS.accountWide then
		CyroChat.SV = ZO_SavedVars:NewAccountWide("CyroChatTrackerSettings", 1.0, "Settings", CyroChat.defaults)
	else
		CyroChat.SV = ZO_SavedVars:New("CyroChatTrackerSettings", 1.0, "Settings", CyroChat.defaults)
	end
	
	CyroChat:InitializeAddonMenu()

	EVENT_MANAGER:UnregisterForEvent(CyroChat.name, EVENT_ADD_ON_LOADED)

	CyroChat:Initialize()
	CyroChat:OnOff()

	if CyroChat.debugMode == true then
		CyroChat:SetUpCommands()
	end
end

function CyroChat:OnOff()
	CyroChat:InitControls()

	local GroupSize = 1

	if CyroChat.SV.settings.onlyInGroup == true then
		GroupSize = GetGroupSize()
	end

	if CyroChat.playerInPvP == true and GroupSize > 0 then
		if CyroChat.debugMode == false then
			EVENT_MANAGER:RegisterForEvent(CyroChat.name, EVENT_CHAT_MESSAGE_CHANNEL, CyroChat.onChatMessage)
			EVENT_MANAGER:RegisterForEvent(CyroChat.name, EVENT_ZONE_CHANGED, CyroChat.onZoneUpdate)
			EVENT_MANAGER:RegisterForEvent(CyroChat.name, EVENT_ACTION_LAYER_PUSHED, CyroChat.OnActionLayerChange)
			EVENT_MANAGER:RegisterForEvent(CyroChat.name, EVENT_ACTION_LAYER_POPPED, CyroChat.OnActionLayerChange)
			EVENT_MANAGER:RegisterForEvent(CyroChat.name, EVENT_PLAYER_COMBAT_STATE, CyroChat.onCombatState)
		end
	else
		if CyroChat.debugMode == false then
			EVENT_MANAGER:UnregisterForEvent(CyroChat.name, EVENT_CHAT_MESSAGE_CHANNEL)
			EVENT_MANAGER:UnregisterForEvent(CyroChat.name, EVENT_ZONE_CHANGED)
			EVENT_MANAGER:UnregisterForEvent(CyroChat.name, EVENT_ACTION_LAYER_PUSHED)
			EVENT_MANAGER:UnregisterForEvent(CyroChat.name, EVENT_ACTION_LAYER_POPPED)
			EVENT_MANAGER:UnregisterForEvent(CyroChat.name, EVENT_PLAYER_COMBAT_STATE)
		end

		CyroChatWindow_Text:Clear()
		CyroChatWindow:SetHidden(true)
	end
end

function CyroChat.OnPlayerActivated(eventCode, initial)
	CyroChat.playerInPvP = IsInCyrodiil()

	local currentCampaignId = GetCurrentCampaignId() 

	if CyroChat.playerCampaignId ~= currentCampaignId then
		if CyroChat.playerCampaignId ~= 0 then
			CyroChatWindow_Text:AddMessage('*** Campaign: '..GetCampaignName(currentCampaignId) ..' ***')
		end

		CyroChat.playerCampaignId = currentCampaignId
	end

	CyroChat:OnOff()
end

function CyroChat:InitControls()
	CyroChatWindow:ClearAnchors()
	CyroChatWindow:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, self.SV.settings.feedOffsetX, self.SV.settings.feedOffsetY)
	CyroChatWindow:SetMouseEnabled(self.SV.settings.unlocked)
	CyroChatWindow:SetMovable(self.SV.settings.unlocked)
	CyroChatWindow:SetHidden(not self.SV.settings.showFeed)
	CyroChatWindow:SetHeight(self.SV.settings.feedHeight)
	CyroChatWindow:SetWidth(self.SV.settings.feedWidth)
	CyroChatWindow_Text:SetHeight(self.SV.settings.feedHeight)
	CyroChatWindow_Text:SetWidth(self.SV.settings.feedWidth)
end

-- Creates the addon settings menu
function CyroChat:InitializeAddonMenu()
	local panelData = {
		type = "panel",
		name = "CyroChat",
		displayName = "|c66ccffCyroChat",
		author = "|c4779ce@aldericon|r",
		version = string.format("%.2f", CyroChat.version),
		slashCommand = "/cyrochat",
		registerForRefresh = true,
		registerForDefaults = true
	}

	local optionsPanel = self.LAM2:RegisterAddonPanel("Cyro_Chat", panelData)
	local optionsData = {}

	table.insert(optionsData, {
		type = "description",
		text = "CyroChat is crowdsourcing addon that reads chat and presents useful PVP information to you based on what is being chatted about. CyroChat also works with CyrHUD, providing an image representation of the message about a particular location.",
	})
	table.insert(optionsData, {
		type = "header",
		name = "CyroChat Options",
	})
	table.insert(optionsData, {
		type = "checkbox",
		name = "Same settings for all characters",
		tooltip = "ON - Each character has the same set of settings, OFF - Separate settings for each character",
		requiresReload = true,
		default = self.accountWideDefaults.accountWide,
		getFunc = function() return self.DS.accountWide end,
		setFunc = function(newValue) self.DS.accountWide = newValue end,
	})
	table.insert(optionsData, {
		type = "checkbox",
		name = "Turn OFF when satisfied with frame positions",
		tooltip = "ON - various displays can moved on the screen by left clicking and dragging, OFF - all locked in place and cannot be moved",
		default = self.defaults.settings.unlocked,
		getFunc = function() return self.SV.settings.unlocked end,
		setFunc = function(newValue) self.SV.settings.unlocked = newValue self:InitControls() end,
	})
	table.insert(optionsData, {
		type = "checkbox",
		name = "Stop in Combat",
		tooltip = "ON - CyroChat stops looking for relevant chat message while in combat, OFF - CyroChat always scan chat",
		default = self.defaults.settings.chatActiveCombat,
		getFunc = function() return self.SV.settings.chatActiveCombat end,
		setFunc = function(newValue) self.SV.settings.chatActiveCombat = newValue end,
	})
	table.insert(optionsData, {
		type = "checkbox",
		name = "Use with CyrHUD",
		requiresReload = true,
		tooltip = "ON - CyrHUD displays crossed swords to display player activity at a location, a flag to indicate that that location will soon be under attack, a crown to display that a location is considered clear or skull & crossbones if a location is considered lost, OFF - CyrHUD does not display information based on CyroChat",
		default = self.defaults.settings.useCyrHud,
		getFunc = function() return self.SV.settings.useCyrHud end,
		setFunc = function(newValue) self.SV.settings.useCyrHud = newValue end,
	})
	table.insert(optionsData, {
		type = "checkbox",
		name = "Only use when Grouped",
		tooltip = "ON - CyroChat only works while grouped (and in Cyrodiil), OFF - CyroChat only works in Cyrodiil",
		default = self.defaults.settings.onlyInGroup,
		getFunc = function() return self.SV.settings.onlyInGroup end,
		setFunc = function(newValue) self.SV.settings.onlyInGroup = newValue self:OnOff() end,
	})
	table.insert(optionsData, {
		type = "editbox",
		name = "Ignored Players:",
		tooltip = "Add players (either UserID or Character Names) here that you wish CyroChat to not list to. This does not prevent you from seeing their chat messages but merely has CyroChat ignore them. eg. @aldericon",
		isMultiline = true,
		isExtraWide = true,
		getFunc = function() return self.SV.settings.playersIgnored end,
		setFunc = function(newValue)
			self.SV.settings.playersIgnored = newValue
			self:BuildIgnoredList()
		end,
		width = "full",
	})
	table.insert(optionsData, {
		type = "header",
		name = "Chat Feed Options",
	})
	table.insert(optionsData, {
		type = "checkbox",
		name = "Enable Chat Feed",
		tooltip = "ON - adds a moveable chat feed to the screen, OFF - no chat feed on screen",
		default = self.defaults.settings.showFeed,
		getFunc = function() return self.SV.settings.showFeed end,
		setFunc = function(newValue) self.SV.settings.showFeed = newValue self:InitControls() end,
	})
	table.insert(optionsData, {
		type = "dropdown",
		name = "UserID vs. Character Name",
		tooltip = 'Whether to display a name in the feed alongside the message. Can be set to use UserID (ex. @aldericon) or character name. Note that the verification process verified per user, not per character.',
		choices = {"Never", "UserID", "Character Name"},
		disabled = function() return not self.SV.settings.showFeed end,
		getFunc = function() 
			if self.SV.settings.feedName==1 then 
				return "Never"
			elseif self.SV.settings.feedName==2 then 
				return "UserID"
			elseif self.SV.settings.feedName==3 then
				return "Character Name"
			end
		end,
		setFunc = function(newValue)
			if newValue=="Never" then 
				self.SV.settings.feedName=1
			elseif newValue=="UserID" then
				self.SV.settings.feedName=2
			elseif newValue=="Character Name" then
				self.SV.settings.feedName=3
			end
		end,
			default = 2,
	})
	table.insert(optionsData, {
		type = "checkbox",
		name = "Display Timestamp",
		tooltip = "ON - display timestamp (HH:MM:SS) in feed of when chat message was posted, OFF - do not display timestamp",
		default = self.defaults.settings.feedTimestamp,
		disabled = function() return not self.SV.settings.showFeed end,
		getFunc = function() return self.SV.settings.feedTimestamp end,
		setFunc = function(newValue) self.SV.settings.feedTimestamp = newValue end,
	})
	table.insert(optionsData, {
		type = "checkbox",
		name = "Display Location",
		tooltip = "ON - display Cyrodiil Location with message in feed, OFF - do not display location",
		default = self.defaults.settings.feedLocation,
		disabled = function() return not self.SV.settings.showFeed end,
		getFunc = function() return self.SV.settings.feedLocation end,
		setFunc = function(newValue) self.SV.settings.feedLocation = newValue end,
	})
	table.insert(optionsData, {
		type = "checkbox",
		name = "Display Location Status",
		tooltip = "ON - display whether the location is under attack at time of message in feed, OFF - do not display attack status in feed",
		default = self.defaults.settings.feedAttackStatus,
		disabled = function()
			if self.SV.settings.showFeed == false or self.SV.settings.feedLocation == false then
				return true
			end
		end,
		getFunc = function() return self.SV.settings.feedAttackStatus end,
		setFunc = function(newValue) self.SV.settings.feedAttackStatus = newValue end,
	})
	table.insert(optionsData, {
		type = "checkbox",
		name = "Display Location Siege",
		tooltip = "ON - display any siege at location at time of message in feed, OFF - do not display siege in feed",
		default = self.defaults.settings.feedLocationSiege,
		disabled = function()
			if self.SV.settings.showFeed == false or self.SV.settings.feedLocation == false then
				return true
			end
		end,
		getFunc = function() return self.SV.settings.feedLocationSiege end,
		setFunc = function(newValue) self.SV.settings.feedLocationSiege = newValue end,
	})
	--[[table.insert(optionsData, {
		type = "checkbox",
		name = "Display Location Inner / Outer Breached",
		tooltip = "ON - display whether outer or inner is breached at the time of message in feed, OFF - do not display breaches in feed",
		default = self.defaults.settings.feedLocationBreach,
		disabled = function()
			if self.SV.settings.showFeed == false or self.SV.settings.feedLocation == false then
				return true
			end
		end,
		getFunc = function() return self.SV.settings.feedLocationBreach end,
		setFunc = function(newValue) self.SV.settings.feedLocationBreach = newValue end,
	})]]
	table.insert(optionsData, {
		type = "checkbox",
		name = "Hide in Combat",
		tooltip = "ON - chat feed is hidden while in combat, OFF - chat feed always displays",
		default = self.defaults.settings.feedCombat,
		disabled = function() return not self.SV.settings.showFeed end,
		getFunc = function() return self.SV.settings.feedCombat end,
		setFunc = function(newValue) self.SV.settings.feedCombat = newValue end,
	})
	table.insert(optionsData, {
		type = "slider",
		name = "Height of Feed",
		tooltip = "Choose height of the chat feed",
		default = 120,
		disabled = function() return not self.SV.settings.showFeed end,
		min     = 0,
        max     = 300,
        step    = 1,
		getFunc = function() return self.SV.settings.feedHeight end,
		setFunc = function(newValue) self.SV.settings.feedHeight = newValue self:InitControls() end,
	})
	table.insert(optionsData, {
		type = "slider",
		name = "Width of Feed",
		tooltip = "Choose width of the chat feed",
		default = 750,
		disabled = function() return not self.SV.settings.showFeed end,
		min     = 0,
        max     = 1000,
        step    = 1,
		getFunc = function() return self.SV.settings.feedWidth end,
		setFunc = function(newValue) self.SV.settings.feedWidth = newValue self:InitControls() end,
	})
	table.insert(optionsData, {
		type = "header",
		name = "Notification Options",
	})
	table.insert(optionsData, {
		type = "checkbox",
		name = "Notify Siege Activity",
		tooltip = "ON - display an announcement on your screen whenever someone mentions a location getting sieges, OFF - no announcement about siege activity",
		default = self.defaults.settings.notifySiege,
		getFunc = function() return self.SV.settings.notifySiege end,
		setFunc = function(newValue) self.SV.settings.notifySiege = newValue end,
	})
	table.insert(optionsData, {
		type = "checkbox",
		name = "Notify Player Activity",
		tooltip = "ON - display an announcement on your screen whenever someone mentions player activity at a location, OFF - no announcement about player activity",
		default = self.defaults.settings.notifyPlayer,
		getFunc = function() return self.SV.settings.notifyPlayer end,
		setFunc = function(newValue) self.SV.settings.notifyPlayer = newValue end,
	})
	table.insert(optionsData, {
		type = "checkbox",
		name = "Notify Location Status Activity",
		tooltip = "ON - display an announcement on your screen whenever someone mentions a location's status (usually when the location is under attack and it's been defended successfully), OFF - no announcement about location status",
		default = self.defaults.settings.notifyStatus,
		getFunc = function() return self.SV.settings.notifyStatus end,
		setFunc = function(newValue) self.SV.settings.notifyStatus = newValue end,
	})
	table.insert(optionsData, {
		type = "checkbox",
		name = "Notify: Only if not on CyrHUD",
		tooltip = "ON - only show notifications about locations that aren't shown on CyrHUD, OFF - all activity is reported",
		default = self.defaults.settings.notifyNotCyrHUD,
		disabled = function()
			if CyroChat.SV.settings.useCyrHud == false then
				return true
			end
		end,
		getFunc = function() return self.SV.settings.notifyNotCyrHUD end,
		setFunc = function(newValue) self.SV.settings.notifyNotCyrHUD = newValue end,
	})

	self.LAM2:RegisterOptionControls("Cyro_Chat", optionsData)
end

function CyroChat.DisplayOnMoveStop()
	CyroChat.SV.settings.feedOffsetX = CyroChatWindow:GetLeft();
	CyroChat.SV.settings.feedOffsetY = CyroChatWindow:GetTop();
end

function CyroChat.OnActionLayerChange(eventCode, layerIndex, activeLayerIndex)
	if CyroChat.SV.settings.showFeed == false then
		return
	end

	CyroChat.currentLayerIndex = activeLayerIndex

	CyroChatWindow:SetHidden(activeLayerIndex > 2)
end

--[[can't/won't detect messages spread out across messages:
RED ON THE OUTER BM WALL
BY FD

BRK
PUSH
ITS LUM SIDE
]FD
lol farm side

sej is a bust
like 50 ep in it

NIKEL FD UA
80%
]]
-- CHAT_CHANNEL_WHISPER,CHAT_CHANNEL_PARTY too likely to contain information not what we're looking for
function CyroChat.onChatMessage(eventCode, channelType, fromName, text, isCustomerService, fromDisplayName)
	if CyroChat.SV.settings.chatActiveCombat == true and CyroChat.playerInCombat == true then
		return
	end

	if channelType ~= CHAT_CHANNEL_SAY and channelType ~= CHAT_CHANNEL_YELL and channelType ~= CHAT_CHANNEL_ZONE then
		return
	end

	if fromName == nil or fromName == "" then
		return
	end

	fromName = zo_strformat("<<1>>", fromName)

	if CyroChat.SV.settings.listIgnorePlayers[fromName] ~= nil and CyroChat.SV.settings.listIgnorePlayers[fromName] == true then
		return
	end

	fromDisplayName = zo_strformat("<<1>>", fromDisplayName)

	if CyroChat.SV.settings.listIgnorePlayers[fromDisplayName] ~= nil and CyroChat.SV.settings.listIgnorePlayers[fromDisplayName] == true then
		return
	end

	if CyroChat.debugMode == true then
		CyroChat.printMessages = true
	end

	CyroChat.checkMessage(text, channelType, fromName, fromDisplayName, false, nil)

	if CyroChat.debugMode == true then
		CyroChat.printMessages = false
	end
end

function CyroChat.onZoneUpdate(eventCode, zoneName, subZoneName, newSubzone, zoneId, subZoneId)
	CyroChat.playerZoneId = CyroChat.getKeepId(subZoneName)
	CyroChat.playerZone = subZoneName
end

function CyroChat.onCombatState(eventCode, inCombat)
	if CyroChat.SV.settings.feedCombat == false and CyroChat.SV.settings.chatActiveCombat == false then
		return
	end

	CyroChat.playerInCombat = inCombat

	if inCombat == true then
		CyroChatWindow:SetHidden(true)
	else
		CyroChatWindow:SetHidden(false)
	end
end

function CyroChat.ScreenNotification(message)
	local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_SMALL_TEXT, SOUNDS.NONE)
	messageParams:SetText(message)
	messageParams:SetLifespanMS(5000)
	CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
end

function CyroChat.postNotification(message, categoryId, useCyrHUD, keepID)
	if CyroChat.SV.settings.notifyNotCyrHUD == true and useCyrHUD == true then
		if CyrHUD.battles[keepID] ~= nil then
			return
		end
	end

	if categoryId == 1 and CyroChat.SV.settings.notifySiege == true then
		CyroChat.ScreenNotification(message)
	elseif categoryId == 2 and CyroChat.SV.settings.notifyPlayer == true then
		CyroChat.ScreenNotification(message)
	elseif categoryId == 3 and CyroChat.SV.settings.notifyStatus == true then
		CyroChat.ScreenNotification(message)
	elseif categoryId == 4 and CyroChat.SV.settings.notifyStatus == true then
		CyroChat.ScreenNotification(message)
	end
end

function CyroChat.getKeepAlliance(keepId)
	return GetKeepAlliance(keepId, BGQUERY_LOCAL)
end

function CyroChat.isKeepUA(keepId)
	return GetKeepUnderAttack(keepId, BGQUERY_LOCAL)
end

function CyroChat.isOuterBreached(keepId)
	return GetKeepOuterWallBreached(keepId, BGQUERY_LOCAL)
end

function CyroChat.isInnerBreached(keepId)
	return GetKeepInnerWallBreached(keepId, BGQUERY_LOCAL)
end

function CyroChat.postToFeed(message, fromName, fromDisplayName, foundLocation, categoryId)
	if message == CyroChat.lastMessagePrinted then
		return
	else
		CyroChat.lastMessagePrinted = message
	end

	if CyroChat.SV.settings.showFeed == true then
		local text = message

		if CyroChat.SV.settings.feedName ~= 1 then
			local nameToDisplay = fromName

			if CyroChat.SV.settings.feedName == 2 then
				nameToDisplay = fromDisplayName
			end

			text = "[" .. nameToDisplay .. "]: " .. text
		end

		if CyroChat.SV.settings.feedTimestamp == true then
			local timestampText = "[" .. CyroChat.CreateTimestamp(GetTimeString()) .. "]"

			if CyroChat.SV.settings.feedName ~= 1 then
				timestampText = timestampText .. " "
			else
				timestampText = timestampText .. ": "
			end

			text = timestampText .. text
		end

		if CyroChat.SV.settings.feedLocation == true then
			local displayLocation = CyroChat.keeps[foundLocation]

			if displayLocation ~= nil then
				local textColor = ""
				local currentKeepAlliance = CyroChat.getKeepAlliance(foundLocation)

				if currentKeepAlliance ~= nil then
					if currentKeepAlliance == 1 then -- AD
						textColor = "|cFFFF00"
					elseif currentKeepAlliance == 2 then -- EP
						textColor = "|cFF0000"
					elseif currentKeepAlliance == 3 then -- DC
						textColor = "|c4169E1"
					end
				end

				text = text .. " (" .. textColor .. displayLocation .. "|r)"

				if CyroChat.SV.settings.feedAttackStatus == true then
					if CyroChat.isKeepUA(foundLocation) == true then
						text = text .. " (UA)"
					end
				end
				
				if CyroChat.SV.settings.feedLocationSiege == true then
					local siegeAD = GetNumSieges(foundLocation, BGQUERY_LOCAL, ALLIANCE_ALDMERI_DOMINION)
					local siegeDC = GetNumSieges(foundLocation, BGQUERY_LOCAL, ALLIANCE_DAGGERFALL_COVENANT)
					local siegeEP = GetNumSieges(foundLocation, BGQUERY_LOCAL, ALLIANCE_EBONHEART_PACT)

					if siegeAD > 0 or siegeDC > 0 or siegeEP > 0 then
						local siegeText = ""

						if siegeAD > 0 then
							siegeText = "|cFFFF00" .. siegeAD .. "|r"
						end

						if siegeEP > 0 then
							if siegeAD > 0 then
								siegeText = siegeText .. " "
							end

							siegeText = siegeText .. "|cFF0000" .. siegeEP .. "|r"
						end

						if siegeDC > 0 then
							if siegeAD > 0 or siegeEP > 0 then
								siegeText = siegeText .. " "
							end

							siegeText = siegeText .. "|c4169E1" .. siegeDC .. "|r"
						end

						text = text .. " (" .. siegeText .. ")"
					end
				end

				--[[if CyroChat.SV.settings.feedLocationBreach == true then
					if CyroChat.isOuterBreached(foundLocation) == true then
						text = text .. " (OB)"
					end

					if CyroChat.isInnerBreached(foundLocation) == true then
						text = text .. " (IB)"
					end
				end]]
			end
		end

		if CyroChat.debugMode == true then
			text = text .. " (" .. categoryId .. ")"
		end

		CyroChatWindow_Text:AddMessage(text)
	end

	local useCyrHUD = false

	if CyroChat.SV.settings.useCyrHud == true then
		if CyroChat:GetOtherAddonsActive("CyrHUD") then
			CyroChat.integrateCyrHUD(foundLocation, categoryId, message)
			useCyrHUD = true
		end
	end

	if CyroChat.SV.settings.notifySiege == true or CyroChat.SV.settings.notifyPlayer == true or CyroChat.SV.settings.notifyStatus == true then
		CyroChat.postNotification(message, categoryId, useCyrHUD, foundLocation)
	end
end

function CyroChat.integrateCyrHUD(keepID, categoryId, message)
	if tonumber(CyrHUD.addonVars.version) < 2.1 then
		return
	end

	if CyrHUD.battles[keepID] == nil then
		return
	end

	local icon = nil

	if categoryId == 1 then
		-- means we're on the list but it hasn't yet been listed as UA!
		if CyroChat.isKeepUA(keepID) == false then
			icon = 'esoui/art/treeicons/tutorial_idexicon_battlegrounds_down.dds'
		--[[elseif string.find(message, 'inner') then
			icon = 'esoui/art/treeicons/tutorial_idexicon_charprogression_down.dds']]
		end
	end

	if categoryId == 1 or categoryId == 2 then
		local participatingAlliances = CyroChat.participatingAlliances(message, nil)
		local atLeastOneAlliance = false

		for alliance, isParticipating in pairs(participatingAlliances) do
			if isParticipating == true then
				atLeastOneAlliance = true
				break
			end
		end

		if atLeastOneAlliance == false and categoryId == 2 then
			icon = 'esoui/art/treeicons/tutorial_idexicon_combat_down.dds'
		elseif atLeastOneAlliance == true then
			local currentKeepAlliance = CyroChat.getKeepAlliance(keepID)

			if currentKeepAlliance == nil or currentKeepAlliance == 0 then
				icon = 'esoui/art/treeicons/tutorial_idexicon_combat_down.dds'
			end

			if participatingAlliances['ad'] == true and participatingAlliances['dc'] == true and participatingAlliances['ep'] == true then
				icon = 'esoui/art/compass/ava_3way.dds'
			else
				if currentKeepAlliance == 1 then -- AD
					if participatingAlliances['dc'] == true and participatingAlliances['ep'] == true then
						icon = 'esoui/art/compass/ava_3way.dds'
					elseif participatingAlliances['dc'] == true then
						icon = 'esoui/art/compass/ava_daggerfallvaldmeri.dds'
					elseif participatingAlliances['ep'] == true then
						icon = 'esoui/art/compass/ava_ebonheartvaldmeri.dds'
					end
				elseif currentKeepAlliance == 2 then -- EP
					if participatingAlliances['ad'] == true and participatingAlliances['dc'] == true then
						icon = 'esoui/art/compass/ava_3way.dds'
					elseif participatingAlliances['ad'] == true then
						icon = 'esoui/art/compass/ava_aldmerivebonheart.dds'
					elseif participatingAlliances['dc'] == true then
						icon = 'esoui/art/compass/ava_daggerfallvebonheart.dds'
					end
				elseif currentKeepAlliance == 3 then -- DC
					if participatingAlliances['ad'] == true and participatingAlliances['ep'] == true then
						icon = 'esoui/art/compass/ava_3way.dds'
					elseif participatingAlliances['ad'] == true then
						icon = 'esoui/art/compass/ava_aldmerivdaggerfall.dds'
					elseif participatingAlliances['ep'] == true then
						icon = 'esoui/art/compass/ava_ebonheartvdaggerfall.dds'
					end
				end
			end
		end
	end

	if categoryId == 3 then
		icon = 'esoui/art/treeicons/tutorial_idexicon_crownstore_down.dds'
	end

	if categoryId == 4 then
		icon = 'esoui/art/treeicons/tutorial_idexicon_death_down.dds'
	end

	CyrHUD.battles[keepID]:addIcon(icon)
	CyrHUD.battles[keepID]:update()
end

-- thanks pChat!
function CyroChat.CreateTimestamp(timeStr)
	formatStr = 'h:m:s'

	-- split up default timestamp
	local hours, minutes, seconds = timeStr:match("([^%:]+):([^%:]+):([^%:]+)")
	local hoursNoLead = tonumber(hours) -- hours without leading zero
	local hours12NoLead = (hoursNoLead - 1)%12 + 1
	local hours12
	if (hours12NoLead < 10) then
		hours12 = "0" .. hours12NoLead
	else
		hours12 = hours12NoLead
	end
	local pUp = "AM"
	local pLow = "am"
	if (hoursNoLead >= 12) then
		pUp = "PM"
		pLow = "pm"
	end
	
	-- create new one
	local timestamp = formatStr
	timestamp = timestamp:gsub("HH", hours)
	timestamp = timestamp:gsub("H", hoursNoLead)
	timestamp = timestamp:gsub("hh", hours12)
	timestamp = timestamp:gsub("h", hours12NoLead)
	timestamp = timestamp:gsub("m", minutes)
	timestamp = timestamp:gsub("s", seconds)
	timestamp = timestamp:gsub("A", pUp)
	timestamp = timestamp:gsub("a", pLow)
	
	return timestamp
end

--Function to check the addon state
--Should be called inside initialization of the addon
function CyroChat:CheckOtherAddonsActive(addonName, addonVariable)
	if addonName ~= nil then
		local addonActive = addonVariable ~= nil
		CyroChat.otherAddons[addonName] = addonActive
	end
end

--Function to get the state of an addon name
function CyroChat:GetOtherAddonsActive(addonName)
	local retVar = false
	if addonName ~= nil then
		if CyroChat.otherAddons[addonName] ~= nil then
			retVar = CyroChat.otherAddons[addonName]
		end
	end

	return retVar
end

function SharedChatSystem:ShowPlayerContextMenu(playerName, rawName)
    ClearMenu()

    local otherPlayerIsDecoratedName = IsDecoratedDisplayName(playerName)
    local localPlayerIsGrouped = IsUnitGrouped("player")
    local localPlayerIsGroupLeader = IsUnitGroupLeader("player")
    local otherPlayerIsInPlayersGroup = IsPlayerInGroup(rawName)

    if IsGroupModificationAvailable() then
        if not localPlayerIsGrouped or (localPlayerIsGroupLeader and not otherPlayerIsInPlayersGroup) then
            AddMenuItem(GetString(SI_CHAT_PLAYER_CONTEXT_ADD_GROUP), function() 
            local SENT_FROM_CHAT = false
            local DISPLAY_INVITED_MESSAGE = true
            TryGroupInviteByName(playerName, SENT_FROM_CHAT, DISPLAY_INVITED_MESSAGE) end)
        elseif otherPlayerIsInPlayersGroup and localPlayerIsGroupLeader then
            AddMenuItem(GetString(SI_CHAT_PLAYER_CONTEXT_REMOVE_GROUP), function() GroupKickByName(rawName) end)
        end
    end

    local function IgnoreSelectedPlayer()
        if not IsIgnored(rawName) then
            AddIgnore(playerName)
        end
    end

    AddMenuItem(GetString(SI_CHAT_PLAYER_CONTEXT_WHISPER), function() self:StartTextEntry(nil, CHAT_CHANNEL_WHISPER, playerName) end)

    if(not IsIgnored(rawName)) then
        AddMenuItem(GetString(SI_CHAT_PLAYER_CONTEXT_ADD_IGNORE), IgnoreSelectedPlayer)
    end

    if(not IsFriend(rawName)) then
        AddMenuItem(GetString(SI_CHAT_PLAYER_CONTEXT_ADD_FRIEND), function() ZO_Dialogs_ShowDialog("REQUEST_FRIEND", {name = rawName}) end)
    end

    AddMenuItem(zo_strformat(SI_CHAT_PLAYER_CONTEXT_REPORT, rawName), function()
        ZO_HELP_GENERIC_TICKET_SUBMISSION_MANAGER:OpenReportPlayerTicketScene(playerName, IgnoreSelectedPlayer)
    end)

	if CyroChat.SV.settings.listIgnorePlayers[rawName] ~= nil and CyroChat.SV.settings.listIgnorePlayers[rawName] == true then
		AddMenuItem('CyroChat Unignore Player', function() CyroChat:unignorePlayer(rawName) end)
	else
		AddMenuItem('CyroChat Ignore Player', function() CyroChat:ignorePlayer(rawName) end)
	end

    if(ZO_Menu_GetNumMenuItems() > 0) then
        ShowMenu()
    end
end

function CyroChat:ignorePlayer(displayName)
	CyroChat.SV.settings.playersIgnored = CyroChat.SV.settings.playersIgnored .. '\n' .. displayName
	CyroChat:BuildIgnoredList()
end

function CyroChat:unignorePlayer(displayName)
	local lines = CyroChat.Explode("\n", CyroChat.SV.settings.playersIgnored)

	for lineIndex=#lines, 1, -1 do
		local player = lines[lineIndex]

		if not (player) or player == displayName then
			table.remove(lines, lineIndex)
			CyroChat.SV.settings.listIgnorePlayers[player] = false
		else
			CyroChat.SV.settings.listIgnorePlayers[player] = true
		end
	end

	CyroChat.SV.settings.playersIgnored = table.concat(lines, "\n")
end

function CyroChat:BuildIgnoredList()
	CyroChat.SV.settings.listIgnorePlayers = {}

	if CyroChat.SV.settings.playersIgnored ~= "" then
		local lines = CyroChat.Explode("\n", CyroChat.SV.settings.playersIgnored)

		for lineIndex=#lines, 1, -1 do
			local player = lines[lineIndex]

			if not (player) then
				table.remove(lines, lineIndex)
			else
				CyroChat.SV.settings.listIgnorePlayers[player] = true
			end
		end

		CyroChat.SV.settings.playersIgnored = table.concat(lines, "\n")
	end
end

function CyroChat.Explode(div, str)
	if (div=='') then return false end
	local pos,arr = 0,{}
	for st,sp in function() return string.find(str,div,pos,true) end do
		table.insert(arr,string.sub(str,pos,st-1))
		pos = sp + 1
	end
	table.insert(arr,string.sub(str,pos))
	return arr
end

-- so that ESO can register the addon
EVENT_MANAGER:RegisterForEvent(CyroChat.name, EVENT_ADD_ON_LOADED, CyroChat.OnAddOnLoaded)