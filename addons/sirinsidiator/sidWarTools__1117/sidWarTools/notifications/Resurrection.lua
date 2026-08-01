local L = sidWarTools.Localization
local RegisterForEvent = sidWarTools.RegisterForEvent
local em, cm = EVENT_MANAGER, CALLBACK_MANAGER

local CALLBACK_RESURRECT_AUTO_DECLINE_UPDATED = "sidWarTools_ResurrectAutoDeclineUpdated"
local nextId = 1
local handleName

local function IsAutoDeclineScheduled()
	return handleName ~= nil
end

local function CancelAutoDecline(campaignId, isGroup)
	em:UnregisterForUpdate(handleName)
	handleName = nil
	cm:FireCallbacks(CALLBACK_RESURRECT_AUTO_DECLINE_UPDATED)
end

local function ScheduleAutoDecline(timeout)
	if(IsAutoDeclineScheduled()) then
		CancelAutoDecline()
	end

	local name = "sidWarToolsResurrectionAutoDecline" .. nextId
	nextId = nextId + 1

	em:RegisterForUpdate(name, timeout, function()
		CancelAutoDecline()
		if(IsResurrectPending()) then
			DeclineResurrect()
		end
	end)
	handleName = name

	cm:FireCallbacks(CALLBACK_RESURRECT_AUTO_DECLINE_UPDATED)
end

local RESURRECTION_TIMELIMIT = 60
local function InitializeAutoDecline(saveData)
	local LRES = LibStub("LibResurrection")

	LRES:RegisterCallback("PlayerResurrectionPending", function(characterName, playerName, timeLeftToAcceptMs)
		if(IsResurrectPending() and not IsAutoDeclineScheduled()) then
			local timeLeftToAcceptS = timeLeftToAcceptMs / 1000
			local timeout = timeLeftToAcceptS - RESURRECTION_TIMELIMIT + saveData.resurrectionAutoDeclineTimeout
			ScheduleAutoDecline(timeout * 1000)
		end
	end)
end

local function InitializeChatNotifications(saveData)
	local LRES = LibStub("LibResurrection")

	LRES:RegisterCallback("PlayerResurrectionPending", function(characterName, playerName, timeLeftToAcceptMs)
		df(L["RESURRECT_RECEIVED_NOTIFICATION"], ZO_LinkHandler_CreateCharacterLink(characterName))
	end)
	LRES:RegisterCallback("PlayerResurrectionAccepted", function(characterName, playerName)
		df(L["RESURRECT_ACCEPTED_NOTIFICATION"], ZO_LinkHandler_CreateCharacterLink(characterName))
	end)
	LRES:RegisterCallback("PlayerResurrectionFailed", function(characterName, playerName, reason)
		if(reason == LRES.PLAYER_RESURRECTION_FAILED_REASON_DECLINED) then
			df(L["RESURRECT_DECLINED_NOTIFICATION"], ZO_LinkHandler_CreateCharacterLink(characterName))
		end
	end)

	LRES:RegisterCallback("TargetResurrectionPending", function(characterName, playerName, timeLeftToAccept)
		df(L["TARGET_RESURRECT_RECEIVED_NOTIFICATION"], ZO_LinkHandler_CreateCharacterLink(characterName))
	end)
	LRES:RegisterCallback("TargetResurrectionAccepted", function(characterName, playerName)
		df(L["TARGET_RESURRECT_ACCEPTED_NOTIFICATION"], ZO_LinkHandler_CreateCharacterLink(characterName))
	end)
	LRES:RegisterCallback("TargetResurrectionFailed", function(characterName, playerName, reason)
		if(reason == LRES.PLAYER_RESURRECTION_FAILED_REASON_DECLINED) then
			df(L["TARGET_RESURRECT_DECLINED_NOTIFICATION"], ZO_LinkHandler_CreateCharacterLink(characterName))
		end
	end)
end

local function Accept()
	CancelAutoDecline()
	AcceptResurrect()
end

local function Decline()
	if(IsAutoDeclineScheduled()) then
		CancelAutoDecline()
	else
		DeclineResurrect()
	end
end

local function InitializeDeathScreenResurrectionNotification(saveData)
	local DEATH_TYPE_RESURRECT_PENDING = "Resurrect"
	local resurrect = DEATH.types[DEATH_TYPE_RESURRECT_PENDING]

	local button1 = resurrect:GetButton(1)
	button1:SetCallback(Accept)

	local button2 = resurrect:GetButton(2)
	button2:SetCallback(Decline)

	resurrect.UpdateDisplay = function(self)
		local resurrectRequester, timeLeftToAcceptMs = GetPendingResurrectInfo()
		local text
		if(IsAutoDeclineScheduled()) then
			button1:SetText(L["DEATH_PROMPT_RESURRECT_RESPAWN"])
			button2:SetText(L["DEATH_PROMPT_RESURRECT_WAIT"])
			timeLeftToAcceptMs = math.floor(timeLeftToAcceptMs - RESURRECTION_TIMELIMIT * 1000 + saveData.resurrectionAutoDeclineTimeout * 1000)
			text = zo_strformat(L["DEATH_PROMPT_RESURRECT_AUTO_DECLINE_TEXT"], resurrectRequester)
		else
			button1:SetText(GetString(SI_DIALOG_ACCEPT))
			button2:SetText(GetString(SI_DIALOG_DECLINE))
			text = zo_strformat(SI_DEATH_PROMPT_RESURRECT_TEXT, resurrectRequester)
		end
		self.messageLabel:SetText(text)
		self.timerCooldown:Start(timeLeftToAcceptMs)
	end

	cm:RegisterCallback(CALLBACK_RESURRECT_AUTO_DECLINE_UPDATED, function(campaignId, isGroup)
		resurrect:UpdateDisplay()
	end)
end

local function InitializeResurrectionNotification(saveData)
	ZO_CreateStringId("SI_RESURRECT_AUTO_DECLINE_MESSAGE", L["RESURRECT_AUTO_DECLINE_MESSAGE"])

	local nm = NOTIFICATIONS
	local ZO_KeyboardResurrectProviderIndex = 5
	local resurrectProvider = nm.providers[ZO_KeyboardResurrectProviderIndex]

	resurrectProvider.BuildNotificationList = function(self)
		ZO_ClearNumericallyIndexedTable(self.list)

		if(IsResurrectPending()) then
			local resurrectRequester, timeLeftToAcceptMs = GetPendingResurrectInfo()
			local timeLeftToAcceptS = timeLeftToAcceptMs / 1000
			local data = {
				dataType = NOTIFICATIONS_REQUEST_DATA,
				notificationType = NOTIFICATION_TYPE_RESURRECT,
				secsSinceRequest = ZO_NormalizeSecondsUntil(timeLeftToAcceptS),
				messageParams = { resurrectRequester },
				shortDisplayText = resurrectRequester,
			}

			if(IsAutoDeclineScheduled()) then
				data.messageFormat = SI_RESURRECT_AUTO_DECLINE_MESSAGE
				data.expiresAt = GetFrameTimeSeconds() + timeLeftToAcceptS - RESURRECTION_TIMELIMIT + saveData.resurrectionAutoDeclineTimeout
			else
				data.messageFormat = self:GetMessageFormat()
				data.expiresAt = GetFrameTimeSeconds() + timeLeftToAcceptS
			end

			table.insert(self.list, data)
		end
	end

	resurrectProvider.Accept = function(self, data)
		Accept()
	end

	resurrectProvider.Decline = function(self, data, button, openedFromKeybind)
		Decline()
	end

	cm:RegisterCallback(CALLBACK_RESURRECT_AUTO_DECLINE_UPDATED, function()
		resurrectProvider:PushUpdateToNotificationManager()
	end)
end

sidWarTools.InitializeResurrectionNotification = function(saveData)
	if(saveData.resurrectionAutoDecline) then
		InitializeAutoDecline(saveData)
		InitializeDeathScreenResurrectionNotification(saveData)
		InitializeResurrectionNotification(saveData)
	end
	if(saveData.resurrectionNotifications) then
		InitializeChatNotifications(saveData)
	end
end
