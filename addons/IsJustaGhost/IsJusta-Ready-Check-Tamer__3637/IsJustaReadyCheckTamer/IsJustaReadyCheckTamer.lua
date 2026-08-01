--[[

- - - 
? 
? 
? 

- - - 2.1
○ fixed missing instance of resorting sound file if notification has expired

- - - 2
○ updated for API 101038.
○ rewrote it again. 
○ manages the sound file used for the current group vote type. 
○ added a delay to processing the entry to give time for other information to be added. 

- - - 1.2.1
○ removed debug text and cleaned out the code

- - - 1.2
○ rewrote it using a different method that's more inclusive and less invasive.
○ notification sound only is heard on initiate and after the cooldown
○ dialogue only opens after cooldown. no longer opens on initiate

- - - 1.1
○ I've added a way for it to queue up the dialog to open after the cooldown. Here's hoping it does not cause any errors.
-- I was not able to test it in a large group but, worked as expected when preventing it from opening while in chat.
? 
? 

]]

local addonInfo = {
	displayName = "|cFF00FFIsJusta|r |cffffffReady Check Tamer|r",
	name = "IsJustaReadyCheckTamer",
	prefix = "IJA_RCT",
	version = "2.1",
}

--[[
	No dependencies
	
	[COLOR="Lime"][SIZE="3"]Works in Gamepad Mode and Keyboard/Mouse Mode[/SIZE][/COLOR]

	The primary reason for this addon is to stop the spam caused by "Ready Checks" and other group elections. 
	It will also prevent the dialogue from kicking you out of chat while the text entry box is active. In other words, while you are typing.
	
]]

-- jo_callLater is something I created and use in various addons in place of jo_callLater.
-- It allows it to be called continuously without stacking. Only the last one fires.
if not jo_callLater then
	jo_callLater = function(id, func, ms)
		if ms == nil then ms = 0 end
		local name = "JO_CallLater_".. id
		EVENT_MANAGER:UnregisterForUpdate(name)
		
		EVENT_MANAGER:RegisterForUpdate(name, ms,
			function()
				EVENT_MANAGER:UnregisterForUpdate(name)
				func()
			end)
		return id
	end
end

---------------------------------------------------------------------------------------------------------------
-- 
---------------------------------------------------------------------------------------------------------------
local INTERACT_TYPE_AGENT_CHAT_REQUEST = 1
local INTERACT_TYPE_RITUAL_OF_MARA = 2
local INTERACT_TYPE_TRADE_INVITE = 3
local INTERACT_TYPE_GROUP_INVITE = 4
local INTERACT_TYPE_QUEST_SHARE = 5
local INTERACT_TYPE_FRIEND_REQUEST = 6
local INTERACT_TYPE_GUILD_INVITE = 7
local INTERACT_TYPE_CAMPAIGN_QUEUE = 8
local INTERACT_TYPE_WORLD_EVENT_INVITE = 9
local INTERACT_TYPE_LFG_FIND_REPLACEMENT = 10
local INTERACT_TYPE_GROUP_ELECTION = 11
local INTERACT_TYPE_DUEL_INVITE = 12
local INTERACT_TYPE_LFG_READY_CHECK = 13
local INTERACT_TYPE_CLAIM_LEVEL_UP_REWARDS = 14
local INTERACT_TYPE_GIFT_RECEIVED = 15
local INTERACT_TYPE_TRACK_ZONE_STORY = 16
local INTERACT_TYPE_CAMPAIGN_QUEUE_JOINED = 17
local INTERACT_TYPE_CAMPAIGN_LOCK_PENDING = 18
local INTERACT_TYPE_TRAVEL_TO_LEADER = 19
local INTERACT_TYPE_TRIBUTE_INVITE = 20

local TIMED_PROMPTS = {
	[INTERACT_TYPE_LFG_READY_CHECK] = true,
	[INTERACT_TYPE_CAMPAIGN_QUEUE] = true,
	[INTERACT_TYPE_WORLD_EVENT_INVITE] = true,
	[INTERACT_TYPE_GROUP_ELECTION] = true,
	-- [INTERACT_TYPE_CAMPAIGN_LOCK_PENDING] = true,
	[INTERACT_TYPE_DUEL_INVITE] = true,
	[INTERACT_TYPE_TRIBUTE_INVITE] = true,
	-- Campaign Queue is the only timed prompt without a fixed expiration time; instead it's manually removed when the queue it's a part of pops.
	-- This means it does not define expiresAtS or expirationCallback, and it refreshes every second without necessarily needing to; it doesn't show a timer.
	[INTERACT_TYPE_CAMPAIGN_QUEUE_JOINED] = true,
}

local keybindCooldown = 0

local function getCooldownModifier(modifier)
	modifier = modifier or 1
	local cooldown = GetGroupSize() / 2
	cooldown = cooldown > 1 and cooldown or 2 
	return cooldown * modifier
end

local function getTimeRemaining(timeEnd, timeNow)
	return zo_max(timeEnd - timeNow, 0)
end

local function hasTimeExpired(timeEnd, timeNow)
	timeEnd = timeEnd or 0
	return getTimeRemaining(timeEnd, timeNow) == 0
end

-- local remainingTime = zo_max(incomingEntry.expiresAtS - GetFrameTimeSeconds(), 0)
---------------------------------------------------------------------------------------------------------------
-- 
---------------------------------------------------------------------------------------------------------------
local soundKeys = {
	[INTERACT_TYPE_DUEL_INVITE]			= 'DUEL_INVITE_RECEIVED',
	[INTERACT_TYPE_CAMPAIGN_QUEUE]		= 'CAMPAIGN_READY_CHECK',
	[INTERACT_TYPE_GROUP_ELECTION]		= 'NEW_TIMED_NOTIFICATION',
	[INTERACT_TYPE_TRIBUTE_INVITE]		= 'TRIBUTE_INVITE_RECEIVED',
	[INTERACT_TYPE_LFG_READY_CHECK]		= 'LFG_READY_CHECK',
	[INTERACT_TYPE_WORLD_EVENT_INVITE]	= 'SCRIPTED_WORLD_EVENT_INVITED',
}

local soundsClass = ZO_InitializingObject:Subclass()
function soundsClass:Initialize(key)
	self.key = key
	local sound = SOUNDS[key]
	self.sound = sound
end
function soundsClass:Mute()
	if not self.muted then
		self.muted = true
		SOUNDS[self.key] = nil
	end
end
function soundsClass:Restore()
	if self.muted then
		self.muted = false
		SOUNDS[self.key] = self.sound
	end
end
function soundsClass:Play()
	if not self.muted and SCENE_MANAGER:IsInUIMode() then
		PlaySound(self.sound)
	end
end

local internalSoundManager = ZO_InitializingObject:Subclass()
function internalSoundManager:Initialize()
	self.sounds = {}
	for incomingType, key in pairs(soundKeys) do
		self.sounds[incomingType] = soundsClass:New(key)
	end
end
function internalSoundManager:Mute(incomingType)
	local sound = self.sounds[incomingType]
	if sound then
		sound:Mute()
	end
end
function internalSoundManager:Restore(incomingType)
	local sound = self.sounds[incomingType]
	if sound then
		sound:Restore()
	end
end
function internalSoundManager:Play(incomingType)
	local sound = self.sounds[incomingType]
	if sound then
		sound:Play()
	end
end
local soundManger = internalSoundManager:New()

---------------------------------------------------------------------------------------------------------------
-- 
---------------------------------------------------------------------------------------------------------------
local queueClass = ZO_InitializingObject:Subclass()
function queueClass:Initialize()
	self.cooldown = 0
end

function queueClass:IsOnCooldown(timeNowSeconds)
	local cooldown = self.cooldown
	self:SetCooldown(timeNowSeconds)
	
	if ZO_GetChatSystem():IsTextEntryOpen() then
		return true
	end
	
	return not hasTimeExpired(cooldown, timeNowSeconds)
end

function queueClass:GetCooldown()
	return self.cooldown
end

function queueClass:SetCooldown(timeNowSeconds)
	self.cooldown = timeNowSeconds + getCooldownModifier()
end

function queueClass:GetCooldownTimeRemainingMs(timeNowSeconds)
	return zo_max(self.cooldown - timeNowSeconds, 0) * 1000
end

--	/script simulateAddIncomingQueue()
---------------------------------------------------------------------------------------------------------------
local queueManager = ZO_Object:Subclass()
function queueManager:SetOnCooldown(incomingType)
	local incomingEntry = PLAYER_TO_PLAYER:GetFromIncomingQueue(incomingType)
	if incomingEntry == nil then return end
	local timeNowSeconds = GetFrameTimeSeconds()
	incomingEntry.seen = true
	
	local incommingQueue = self:GetIncomingQueue(incomingType)
	
	-- We need to process the following on a delay to give time fro adding addintional info to the incomingEntry.
	-- Otherwise, expiresAtS will be added after this.
	zo_callLater(function()
		if not hasTimeExpired(incomingEntry.expiresAtS, timeNowSeconds) then
			if incommingQueue:IsOnCooldown(timeNowSeconds) or ZO_Dialogs_IsShowing("PTP_TIMED_RESPONSE_PROMPT")  then
				soundManger:Mute(incomingType)
				self:Queue(incomingType, incommingQueue, timeNowSeconds)
			else
				soundManger:Restore(incomingType)
				incomingEntry.seen = false
				soundManger:Play(incomingType)
			end
		else
			soundManger:Restore(incomingType)
		end
	end, 1)
end

function queueManager:Queue(incomingType, incommingQueue, timeNowSeconds)
	-- This is used as a timed callback to to see if the dialogue should be shown after cooldown.
	jo_callLater(addonInfo.prefix .. incomingType, function()
		self:SetOnCooldown(incomingType)
	end, incommingQueue:GetCooldownTimeRemainingMs(timeNowSeconds))
end

function queueManager:GetQueue()
	local queue = self.queue or {}
	self.queue = queue
	
	return queue
end

function queueManager:GetIncomingQueue(incomingType)
	local queue = self:GetQueue()
	
	local incommingQueue = queue[incomingType]
	if not incommingQueue then
		incommingQueue = queueClass:New()
		queue[incomingType] = incommingQueue
	end
	
	return incommingQueue
end

local queue_Manager = queueManager:New()
IJA_RCT_Queue_Manager = queue_Manager

SecurePostHook(PLAYER_TO_PLAYER, 'AddPromptToIncomingQueue', function(self, incomingType)
	if TIMED_PROMPTS[incomingType] then
		queue_Manager:SetOnCooldown(incomingType)
	end
end)

---------------------------------------------------------------------------------------------------------------
-- Simulation for testing outside of a group.
---------------------------------------------------------------------------------------------------------------
local function removeFromIncomingQueue(incomingType)
	for i, incomingEntry in ipairs(PLAYER_TO_PLAYER.incomingQueue) do
		if incomingEntry.incomingType == incomingType then
			table.remove(PLAYER_TO_PLAYER.incomingQueue, i)
		end
	end
	ZO_Dialogs_ReleaseAllDialogsOfName("PTP_TIMED_RESPONSE_PROMPT")
end

local function addDungeonFinder()
	local activityType = 2

	local promptData = PLAYER_TO_PLAYER:GetFromIncomingQueue(INTERACT_TYPE_LFG_READY_CHECK)
	if not promptData then
		local function DeferDecisionCallback()
			removeFromIncomingQueue(INTERACT_TYPE_LFG_READY_CHECK)
		end

		local messageFormat, messageParams
		local activityTypeText = GetString("SI_LFGACTIVITY", activityType)
		local generalActivityText = ZO_ACTIVITY_FINDER_GENERALIZED_ACTIVITY_DESCRIPTORS[activityType]
		
		local function DeclineReadyCheckConfirmation()
			local readyCheckData = PLAYER_TO_PLAYER:GetFromIncomingQueue(INTERACT_TYPE_LFG_READY_CHECK)
			if readyCheckData and readyCheckData.dontRemoveOnDecline then
				ZO_Dialogs_ShowPlatformDialog("LFG_DECLINE_READY_CHECK_CONFIRMATION")
			end
		end

		local DONT_REMOVE_ON_DECLINE = true
		promptData = PLAYER_TO_PLAYER:AddPromptToIncomingQueue(INTERACT_TYPE_LFG_READY_CHECK, nil, nil, nil, AcceptLFGReadyCheckNotification, DeclineReadyCheckConfirmation, DeferDecisionCallback, DONT_REMOVE_ON_DECLINE)
		promptData.acceptText = GetString(SI_LFG_READY_CHECK_ACCEPT)
		promptData.expiresAtS = GetFrameTimeSeconds() + 60
		promptData.messageFormat = SI_LFG_READY_CHECK_NO_ROLE_TEXT
		promptData.messageParams = { activityTypeText, generalActivityText }
		promptData.expirationCallback = DeferDecisionCallback
		promptData.dialogTitle = GetString("SI_NOTIFICATIONTYPE", NOTIFICATION_TYPE_LFG)

		PlaySound(SOUNDS.LFG_READY_CHECK)
	else
		promptData.dontRemoveOnDecline = true
	end
end

local function addReadyCheck()
	local electionType = GROUP_ELECTION_TYPE_GENERIC_UNANIMOUS
	local descriptor = ZO_GROUP_ELECTION_DESCRIPTORS.READY_CHECK

	local function AcceptCallback()
		CastGroupVote(GROUP_VOTE_CHOICE_FOR)
	end
	local function DeclineCallback()
		CastGroupVote(GROUP_VOTE_CHOICE_AGAINST)
	end
	local function DeferDecisionCallback()
		removeFromIncomingQueue(INTERACT_TYPE_GROUP_ELECTION)
	end

	local messageFormat, messageParams
	if ZO_IsGroupElectionTypeCustom(electionType) then
		if descriptor == ZO_GROUP_ELECTION_DESCRIPTORS.READY_CHECK then
			messageFormat = GetString(SI_GROUP_ELECTION_READY_CHECK_MESSAGE)
		else
			messageFormat = descriptor
		end
		messageParams = {}
	else
		if electionType == GROUP_ELECTION_TYPE_KICK_MEMBER then
			messageFormat = SI_GROUP_ELECTION_KICK_MESSAGE
		elseif electionType == GROUP_ELECTION_TYPE_NEW_LEADER then
			messageFormat = SI_GROUP_ELECTION_PROMOTE_MESSAGE
		end
		local primaryName = ZO_GetPrimaryPlayerNameFromUnitTag(targetUnitTag)
		local secondaryName = ZO_GetSecondaryPlayerNameFromUnitTag(targetUnitTag)
		messageParams = { primaryName, secondaryName }
	end

	PlaySound(SOUNDS.NEW_TIMED_NOTIFICATION)
	removeFromIncomingQueue(INTERACT_TYPE_GROUP_ELECTION)

	local promptData = PLAYER_TO_PLAYER:AddPromptToIncomingQueue(INTERACT_TYPE_GROUP_ELECTION, nil, nil, nil, AcceptCallback, DeclineCallback, DeferDecisionCallback)
	promptData.acceptText = GetString(SI_YES)
	promptData.declineText = GetString(SI_NO)

	promptData.expiresAtS = GetFrameTimeSeconds() + 30
	promptData.messageFormat = messageFormat
	promptData.messageParams = messageParams
	promptData.expirationCallback = DeferDecisionCallback
	promptData.dialogTitle = GetString("SI_NOTIFICATIONTYPE", NOTIFICATION_TYPE_GROUP_ELECTION)
	promptData.uniqueSounds = {
		accept = SOUNDS.GROUP_ELECTION_VOTE_SUBMITTED,
		decline = SOUNDS.GROUP_ELECTION_VOTE_SUBMITTED,
	}
end

local simulation = {}
for i=1, 10 do
	table.insert(simulation, true)
end

function simulateAddIncomingQueue(lastCount, repeating)
	local counter = next(simulation, lastCount)

	if counter then
		zo_callLater(function()
			d( 'Simulate Add Incoming Queue')
			addReadyCheck()
			simulateAddIncomingQueue(counter)
		end, zo_random(100, 1000))
	elseif repeating then
		zo_callLater(function()
			d( 'RESTARTING')
			simulateAddIncomingQueue()
		end, 5000)
	end
end

--	/script simulateAddIncomingQueue()
--	/script simulateAddIncomingQueue(nil, true)
-- In simulation, if you use the buttons in the dialogue it may cause an error.
--[[
	on first
		ZO_GetChatSystem():IsTextEntryOpen()
			queue
		
	on recurring
		was last called on cooldown
			queue
			11
PLAYER_TO_PLAYER:GetFromIncomingQueue(11)
	jo_callLater(name, function() 
		self:OnCooldown(incomingType)
	end, cooldownTime)
	
	soundManger:Mute(incomingType)
	soundManger:Restore(incomingType)
	soundManger:Play(incomingType)
	
	
	center screen announcment
	
	sound, message, combinedMessage, icon, iconBg, expiringCallback, barParams, lifespan, suppressFrame, queueImmediately, showImmediately, reinsertStompedMessage
	
	
	
	CENTER_SCREEN_ANNOUNCE:AddMessage(eventId, category, ...)
	
	
	local sound = 
	local message = 
	local combinedMessage = 
	local lifespan = 
	local showImmediately = true
	CENTER_SCREEN_ANNOUNCE:AddMessage(0, CSA_CATEGORY_COUNTDOWN_TEXT, sound, message, combinedMessage, icon, iconBg, expiringCallback, barParams, lifespan, suppressFrame, queueImmediately, showImmediately, reinsertStompedMessage)
	
	
	
	[CSA_CATEGORY_COUNTDOWN_TEXT] = function(self, messageParams)
		-- Nothing can show while countdowns are showing
		self:RemoveAllActiveLines()

		local announcementCountdownLine, poolKey = self.countdownLinePool:AcquireObject()
		announcementCountdownLine:SetKey(poolKey)
		local lineControl = announcementCountdownLine:GetControl()

		announcementCountdownLine:SetEndImageTexture(messageParams:GetIconData())
		announcementCountdownLine:SetAndPlayStartingAnimation(messageParams:GetLifespanMS())

		lineControl:SetAnchor(TOP, self.countdownLineContainer)

		return announcementCountdownLine
	end,

local params = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, SOUNDS.ACHIEVEMENT_AWARDED)
			params:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_POI_DISCOVERED)
			params:SetText(GetString(HARVENS_THIEVES_TROVE_DISCOVERED))
			CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(params)

			
			
			local params = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, sound)
		--	params:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_SYSTEM_BROADCAST)
			params:SetText(incomingEntry.messageFormat)
			params:SetLifespanMS(lifespan)
			CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(params)
			
	local message = incomingEntry.messageFormat
	local combinedMessage = incomingEntry.messageFormat
	
	local lifespan = incomingEntry.expiresAtS or GetFrameTimeSeconds() + 30
	lifespan = (lifespan - GetFrameTimeSeconds()) * 1000
	local showImmediately = true
--	CENTER_SCREEN_ANNOUNCE:AddMessage(0, CSA_CATEGORY_LARGE_TEXT, sound, message, combinedMessage, icon, iconBg, expiringCallback, barParams, lifespan, suppressFrame, queueImmediately, showImmediately, reinsertStompedMessage)
--	CENTER_SCREEN_ANNOUNCE:AddMessage(0, CSA_CATEGORY_COUNTDOWN_TEXT, sound, message, combinedMessage, icon, iconBg, expiringCallback, barParams, lifespan, suppressFrame, queueImmediately, showImmediately, reinsertStompedMessage)

]]