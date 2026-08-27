local addon = BureauOfPrivateDispatches
local private = addon.private

local FormatLocalizedText = private.FormatLocalizedText
local ChatInfo = private.ChatInfo
local stringformat = string.format

addon.testMessageIndex = 0
local TEST_SENDER_ID = "@BPD_Test_01"

function addon:AddTestNotification(senderIndex)
	self.testMessageIndex = self.testMessageIndex + 1
	local senderId = stringformat("@BPD_Test_%02d", senderIndex)
	local message = FormatLocalizedText(SI_BPD_TEST_MESSAGE, self.testMessageIndex, senderIndex)
	self:AddOrUpdateNotification(senderId, message)
end

function addon:TestFollowUpOverdue()
	if self.notificationsBySender[TEST_SENDER_ID] == nil then
		self:AddTestNotification(1)
	end

	local entry = self.notificationsBySender[TEST_SENDER_ID]
	if entry == nil then
		return
	end

	local now = GetGameTimeMilliseconds()
	entry.pendingSinceMs = now - self:GetFollowUpOverdueMs()
	if type(GetTimeStamp) == "function" then
		entry.pendingSinceStamp = GetTimeStamp() - math.floor(self:GetFollowUpOverdueMs() / 1000)
	end
	entry.followUpState = self.followUpStates.PENDING
	entry.reminderStage = 0
	entry.replyOpenedMs = nil
	self:UpdateFollowUps(now, true)
	self:StartPendingFollowUpReminder()
end

function addon:TestFollowUpReply()
	if self.notificationsBySender[TEST_SENDER_ID] == nil then
		self:AddTestNotification(1)
	end

	self:MarkSenderAnswered(TEST_SENDER_ID)
end

local function ShowDebugHelp()
	ChatInfo(SI_BPD_HELP_DEBUG_TITLE)
	ChatInfo(SI_BPD_HELP_DEBUG_TEST)
	ChatInfo(SI_BPD_HELP_DEBUG_TEST_MANY)
	ChatInfo(SI_BPD_HELP_DEBUG_TEST_OVERDUE)
	ChatInfo(SI_BPD_HELP_DEBUG_TEST_REPLY)
	ChatInfo(SI_BPD_HELP_DEBUG_READ)
	ChatInfo(SI_BPD_HELP_DEBUG_RESTORE)
end

function addon:RegisterSlashCommands()
	SLASH_COMMANDS["/bpd"] = function(arguments)
		local command = zo_strlower(zo_strtrim(arguments or ""))
		local rest = ""
		local spaceIndex = command:find(" ", 1, true)
		if spaceIndex then
			rest = zo_strtrim(command:sub(spaceIndex + 1))
			command = command:sub(1, spaceIndex - 1)
		end
		local debugCommand = command == "debug" and rest or nil

		if command == "clear" then
			self:ClearAllNotifications()
		elseif command == "reset" then
			self:ResetPosition()
		elseif command == "toggle" then
			self:ToggleCollapsed()
		elseif command == "mute" then
			if self:ToggleMuted() then
				ChatInfo(SI_BPD_MUTE_ON)
			else
				ChatInfo(SI_BPD_MUTE_OFF)
			end
		elseif command == "dnd" then
			if self:ToggleManualDnd() then
				ChatInfo(SI_BPD_DND_ON)
			else
				ChatInfo(SI_BPD_DND_OFF)
			end
		elseif command == "scale" then
			if rest == "" then
				ChatInfo(SI_BPD_SCALE_SET, self:GetPanelScale())
			elseif self:SetPanelScale(tonumber(rest)) then
				ChatInfo(SI_BPD_SCALE_SET, self:GetPanelScale())
			else
				ChatInfo(SI_BPD_HELP_SCALE)
			end
		elseif command == "opacity" then
			if rest == "" then
				ChatInfo(SI_BPD_OPACITY_SET, self:GetPanelOpacity())
			elseif self:SetPanelOpacity(tonumber(rest)) then
				ChatInfo(SI_BPD_OPACITY_SET, self:GetPanelOpacity())
			else
				ChatInfo(SI_BPD_HELP_OPACITY)
			end
		elseif command == "autocollapse" then
			if self:ToggleAutoCollapseInCombat() then
				ChatInfo(SI_BPD_AUTOCOLLAPSE_ON)
			else
				ChatInfo(SI_BPD_AUTOCOLLAPSE_OFF)
			end
		elseif command == "settings" then
			self:OpenSettingsPanel()
		elseif command == "debug" then
			if debugCommand == "test" then
				self:AddTestNotification(1)
			elseif debugCommand == "testmany" then
				for senderIndex = 1, 8 do
					self:AddTestNotification(senderIndex)
				end
			elseif debugCommand == "testoverdue" then
				self:TestFollowUpOverdue()
			elseif debugCommand == "testreply" then
				self:TestFollowUpReply()
			elseif debugCommand == "read" then
				self:MarkSenderRead(TEST_SENDER_ID)
			elseif debugCommand == "restore" then
				self:RestoreLastDismissed()
			else
				ShowDebugHelp()
			end
		else
			ChatInfo(SI_BPD_HELP_TITLE)
			ChatInfo(SI_BPD_HELP_CLEAR)
			ChatInfo(SI_BPD_HELP_TOGGLE)
			ChatInfo(SI_BPD_HELP_RESET)
			ChatInfo(SI_BPD_HELP_MUTE)
			ChatInfo(SI_BPD_HELP_DND)
			ChatInfo(SI_BPD_HELP_SCALE)
			ChatInfo(SI_BPD_HELP_OPACITY)
			ChatInfo(SI_BPD_HELP_AUTOCOLLAPSE)
			ChatInfo(SI_BPD_HELP_SETTINGS)
			ChatInfo(SI_BPD_HELP_DEBUG)
		end
	end
end

local function ChatInputHasText()
	if CHAT_SYSTEM == nil then
		return false
	end

	local textEntry = CHAT_SYSTEM.textEntry
	if textEntry == nil or type(textEntry.GetText) ~= "function" then
		return false
	end

	local text = textEntry:GetText()
	return type(text) == "string" and zo_strtrim(text) ~= ""
end

function addon:GetFocusedSenderId()
	if self.focusedSenderId ~= nil and self.notificationsBySender[self.focusedSenderId] ~= nil then
		return self.focusedSenderId
	end
	if self.latestNotificationSenderId ~= nil
		and self.notificationsBySender[self.latestNotificationSenderId] ~= nil then
		return self.latestNotificationSenderId
	end
	return self.senderOrder[1]
end

function addon:SetFocusedSender(senderId)
	if senderId ~= nil and self.notificationsBySender[senderId] == nil then
		senderId = nil
	end
	if self.focusedSenderId == senderId then
		return false
	end

	self.focusedSenderId = senderId
	self:RefreshNotifications()
	return true
end

function addon:CycleFocusedSender(direction)
	local order = self.senderOrder
	if self.isInteractionLocked and self.displayOrder ~= nil and #self.displayOrder > 0 then
		order = self.displayOrder
	end
	if order == nil or #order == 0 then
		return false
	end

	local currentId = self:GetFocusedSenderId()
	local currentIndex = 1
	for index = 1, #order do
		if order[index] == currentId then
			currentIndex = index
			break
		end
	end

	local nextIndex = currentIndex + direction
	if nextIndex < 1 then
		nextIndex = #order
	elseif nextIndex > #order then
		nextIndex = 1
	end

	return self:SetFocusedSender(order[nextIndex])
end

function addon:KeybindReply()
	if ChatInputHasText() then
		return
	end

	local senderId = self:GetFocusedSenderId()
	if senderId == nil then
		return
	end
	if type(StartChatInput) == "function" then
		StartChatInput("", CHAT_CHANNEL_WHISPER, senderId)
		self:MarkReplyOpened(senderId)
	end
end

function addon:KeybindFocusNext()
	self:CycleFocusedSender(1)
end

function addon:KeybindFocusPrevious()
	self:CycleFocusedSender(-1)
end

function addon:KeybindMarkRead()
	self:MarkSenderRead(self:GetFocusedSenderId())
end

function addon:KeybindToggleCollapsed()
	self:ToggleCollapsed()
end

function addon:KeybindClearAll()
	if self:IsPanelCollapsed() then
		return
	end
	if type(self.IsPanelSceneActive) == "function" and not self:IsPanelSceneActive() then
		return
	end
	self:ClearAllNotifications()
end

function addon:KeybindMute()
	if self:ToggleMuted() then
		ChatInfo(SI_BPD_MUTE_ON)
	else
		ChatInfo(SI_BPD_MUTE_OFF)
	end
end

function addon:KeybindDnd()
	if self:ToggleManualDnd() then
		ChatInfo(SI_BPD_DND_ON)
	else
		ChatInfo(SI_BPD_DND_OFF)
	end
end

function addon:KeybindRestore()
	self:RestoreLastDismissed()
end

function addon:KeybindLock()
	self:TogglePanelLock()
end