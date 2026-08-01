local _maxAttempts = 7 -- (Integer) Number of attempts before the routine stops. The first attempt will be called immediately.
local _updateFrequency = 250 -- (Integer) Frequency of attempts in milliseconds. The higher the number, the slower the routine tries to empty/delete mails.

----------

local _name = "MailCompanion"

local _isReady = false
local _isEnabled = false
local _activeMailId
local _updateDataDict = {}
local _maxIdleTimeMilliseconds = (_maxAttempts - 1) * _updateFrequency
local _idleStartTime = _maxIdleTimeMilliseconds * -1

local _attachmentsFailMessage = "Could not take attachments. Try again."
local _deleteFailMessage = "Could not delete. Try again."

local function ThrowAlert(text, playSound)
	local sound = nil
	if playSound then sound = SOUNDS.GENERAL_ALERT_ERROR end

	ZO_Alert(UI_ALERT_CATEGORY_ALERT, sound, zo_strformat("[<<1>>] <<2>>", _name, text))
end

local function GetUpdateName(mailId)
	return zo_strformat("<<1>>_<<2>>", _name, mailId)
end

local function HasTimeToContinue()
	return GetGameTimeMilliseconds() - _idleStartTime < _maxIdleTimeMilliseconds
end

local function IsMailValid(mailId)
	local unread, returned, fromSystem, fromCustomerService = GetMailFlags(mailId)
	return fromSystem == true and fromCustomerService == false
end

local function HasMailAttachments(mailId)
	local numAttachments, attachedMoney, codAmount = GetMailAttachmentInfo(mailId)
	return attachedMoney > 0 or numAttachments > 0, numAttachments
end

local function StopUpdate(mailId)
	EVENT_MANAGER:UnregisterForUpdate(GetUpdateName(mailId))
	_updateDataDict[mailId] = nil

	if _activeMailId == mailId then
		_idleStartTime = GetGameTimeMilliseconds()
	end
end

local function StopRoutine()
	_isEnabled = false

	for mailId in pairs(_updateDataDict) do
		StopUpdate(mailId)
	end
end

local function HasAttemptsLeft(mailId, failMessage)
	local data = _updateDataDict[mailId]
	data.Attempts = data.Attempts + 1

	if data.Attempts > _maxAttempts then
		StopRoutine()
		ThrowAlert(failMessage, true)

		return false
	end

	return true
end

local function ProcessMail(mailId)
	if HasMailAttachments(mailId) == true then
		if HasAttemptsLeft(mailId, _attachmentsFailMessage) == true then ZO_MailInboxShared_TakeAll(mailId) end
		return
	end

	if HasAttemptsLeft(mailId, _deleteFailMessage) == true then DeleteMail(mailId, false) end
end

local function StartUpdate(mailId)
	_idleStartTime = GetGameTimeMilliseconds() - _maxIdleTimeMilliseconds
	_updateDataDict[mailId] = { Attempts = 0, }

	ProcessMail(mailId)
	EVENT_MANAGER:RegisterForUpdate(GetUpdateName(mailId), _updateFrequency, function() ProcessMail(mailId) end)
end

local function OnMailTakeAttachmentSuccess(eventCode, mailId)
	if mailId ~= _activeMailId then
		StopUpdate(mailId)
		return
	end

	if IsMailValid(mailId) == false or HasMailAttachments(mailId) == true then return end

	StartUpdate(mailId)
end

local function OnMailRemoved(eventCode, mailId)
	if mailId == _activeMailId then
		_isEnabled = GetNumMailItems() > 0
	end

	StopUpdate(mailId)
end

local function OnMailReadable(eventCode, mailId)
	_activeMailId = mailId

	if _isEnabled == true then
		if HasTimeToContinue() == false then
			StopRoutine()
			return
		end
	else
		return
	end

	if IsMailValid(mailId) == false then
		StopRoutine()
		return
	end

	StartUpdate(mailId)
end

local function OnInventoryIsFull(eventCode, numSlotsRequested, numSlotsFree)
	StopRoutine()
end

local _temporaryEvents = {
	[EVENT_MAIL_READABLE] = OnMailReadable,
	[EVENT_MAIL_TAKE_ATTACHED_ITEM_SUCCESS] = OnMailTakeAttachmentSuccess,
	[EVENT_MAIL_TAKE_ATTACHED_MONEY_SUCCESS] = OnMailTakeAttachmentSuccess,
	[EVENT_MAIL_REMOVED] = OnMailRemoved,
	[EVENT_INVENTORY_IS_FULL] = OnInventoryIsFull,
}

EVENT_MANAGER:RegisterForEvent(_name, EVENT_MAIL_OPEN_MAILBOX, function(eventCode)
	if _isReady == true then return end
	_isReady = true

	for eventCode, eventFunction in pairs(_temporaryEvents) do
		EVENT_MANAGER:RegisterForEvent(_name, eventCode, eventFunction)
	end
end)

EVENT_MANAGER:RegisterForEvent(_name, EVENT_MAIL_CLOSE_MAILBOX, function(eventCode)
	if _isReady == false then return end
	_isReady = false

	for eventCode in pairs(_temporaryEvents) do
		EVENT_MANAGER:UnregisterForEvent(_name, eventCode)
	end

	StopRoutine()
end)
