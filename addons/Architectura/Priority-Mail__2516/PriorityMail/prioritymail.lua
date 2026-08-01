local PMail = ZO_Object:Subclass()

EVENT_MANAGER:RegisterForEvent("PriorityMail", EVENT_ADD_ON_LOADED, function(event, addOnName)
	if string.lower(addOnName) == "prioritymail" then
		EVENT_MANAGER:UnregisterForEvent("PriorityMail", EVENT_ADD_ON_LOADED)
		PRIORITY_MAIL = PMail:New()
	end
end)

function PMail:New()
	local object = ZO_Object.New(self)
	object:Initialize()
	return object
end

function PMail:Initialize()
	if not self.initialized then
		self.initialized = true
		self.eventHandlers = {}
		self:InitializeStaticData()
		self:InitializeSavedVariables()
		self:InitializeEventHandlers()
		self:InitializeDialogs()
	end
end

function PMail:InitializeStaticData()
	self.AddonVersion = 6
	self.AddonName = "PriorityMail"
	self.AddonDev = "Architectura"
	self.EventDescriptor = "prioritymail"
	self.QueueEventDescriptor = self.EventDescriptor.."Queue"
	self.SavedVarsDefaults = {Data = {}, Config = {}}
	self.SavedVarsFilename = "PriorityMail"
	self.SavedVarsVersion = 1
	self.SendMailTimeoutS = 90
	self.UpdateMailQueueIntervalMS = 90000
	self.UpdateMailQueueRetryIntervalMS = 2000
end

function PMail:InitializeSavedVariables()
	if not self.Vars then
		self.Vars = ZO_SavedVars:NewAccountWide(self.SavedVarsFilename, self.SavedVarsVersion, nil, self.SavedVarsDefaults)
		if not self.Vars.Config then
			self.Vars.Config = {}
		end
		if not self.Vars.Data then
			self.Vars.Data = {}
		end
	end
end

function PMail:InitializeEventHandlers()
	if not self.initializedEventHandlers then
		self.initializedEventHandlers = true
		self.eventHandlers[MAIL_SEND_RESULT_FAIL_MAILBOX_FULL] = self.OnFullRecipientMailbox

		EVENT_MANAGER:RegisterForEvent(self.EventDescriptor, EVENT_PLAYER_ACTIVATED, function(...) self:OnPlayerActivated(...) end)
		EVENT_MANAGER:RegisterForEvent(self.EventDescriptor, EVENT_MAIL_CLOSE_MAILBOX, function(...) self:OnMailboxClosed(...) end)
		EVENT_MANAGER:RegisterForEvent(self.EventDescriptor, EVENT_MAIL_OPEN_MAILBOX, function(...) self:OnMailboxOpened(...) end)
		EVENT_MANAGER:RegisterForEvent(self.EventDescriptor, EVENT_MAIL_SEND_FAILED, function(...) self:OnMailSendFailed(...) end)
		EVENT_MANAGER:RegisterForEvent(self.EventDescriptor, EVENT_MAIL_SEND_SUCCESS, function(...) self:OnMailSendSuccess(...) end)

		local function OnMailSceneStateChanged(oldState, newState)
			if newState == "shown" then
				PriorityMail_MailQueue:SetHidden(false)
			elseif newState == "hidden" then
				PriorityMail_MailQueue:SetHidden(true)
			end
		end
		local mailScene = SCENE_MANAGER:GetScene("mailSend")
		if mailScene then
			mailScene:RegisterCallback("StateChange", OnMailSceneStateChanged)
		end

		local function SendMailPreHook(to, subject, body)
			self:OnQueuedMoneyChanged(GetQueuedMoneyAttachment())
			local mail = {to = to, subject = subject, body = body}
			self:SetLastSendMail(mail)
		end
		ZO_PreHook("SendMail", SendMailPreHook)

		local originalAlert = ZO_Alert
		local function ZO_AlertPreHook(...)
			if self:GetPendingMail() then
				self.queuedAlert = {...}
				zo_callLater(function()
					if self.queuedAlert then
						originalAlert(unpack(self.queuedAlert))
					end
				end, 100)
			else
				originalAlert(...)
			end
		end
		_G["ZO_Alert"] = ZO_AlertPreHook
	end
end

function PMail:InitializeDialogs()
	if not self.initializedDialogs then
		self.initializedDialogs = true
		local scrollChild = PriorityMail_MailQueue:GetNamedChild("ScrollContainerScrollChild")
		PriorityMail_MailQueue.rowPool = ZO_ControlPool:New("PriorityMail_QueuedRow", scrollChild)
		PriorityMail_MailQueue.ResetRows = function(self)
			self.rowPool:ReleaseAllObjects()
		end
		PriorityMail_MailQueue.AcquireRow = function(self)
			local control, key = self.rowPool:AcquireObject()
			control.key = key
			return control
		end
	end
end

function PMail:OnPlayerActivated(...)
	self:OnMailQueueChanged()
end

function PMail:OnMailboxClosed(...)
	self:SetMailboxOpen(false)
end

function PMail:OnMailboxOpened(...)
	self:SetMailboxOpen(true)
end

function PMail:OnMailSendFailed(event, reason)
	local handler = self.eventHandlers[reason]
	if handler then
		handler(self)
	end
	if self:GetPendingMail() then
		self:ClearPendingMail()
		self:CloseMailbox()
	end
	self:ForceClearLastSendMail()
end

function PMail:OnMailSendSuccess(event)
	if self:IsPendingMailLastSendMail() then
		local mail = self:GetPendingMail()
		mail.delivered = GetTimeStamp()
		local alert = string.format("Delivered |cffffff%s|r to |cffffff%s|r", mail.subject or "(no subject)", mail.to)
		df("Priority Mail %s", alert)
		PlaySound("CrownCrates_Cards_Leave")
		self:ShowAlert(alert)
		self:DequeueMail(mail)
		self:CloseMailbox()
	end
	self:ClearPendingMail()
	self:ForceClearLastSendMail()
end

do
	local sortedQueue = {}

	local function MailComparer(mailA, mailB)
		return (mailA.sent or 0) > (mailB.sent or 0)
	end

	function PMail:RefreshMailQueue()
		local queue = self:GetQueuedMail()
		local dialog = PriorityMail_MailQueue
		local scrollChild = dialog:GetNamedChild("ScrollContainerScrollChild")
		dialog:ResetRows()
		if #queue > 0 then
			ZO_ClearNumericallyIndexedTable(sortedQueue)
			for _, mail in pairs(queue) do
				table.insert(sortedQueue, mail)
			end
			table.sort(sortedQueue, MailComparer)
			local rowHeight = 64
			local verticalOffset = 10
			for rowIndex = 1, #sortedQueue do
				local mail = sortedQueue[rowIndex]
				local row = dialog:AcquireRow()
				row:ClearAnchors()
				row:SetMail(mail)
				row:SetAnchor(TOP, scrollChild, TOP, 0, verticalOffset + (rowIndex - 1) * rowHeight)
				row:SetHidden(false)
			end
			PriorityMail_Spacer:SetParent(scrollChild)
			PriorityMail_Spacer:ClearAnchors()
			PriorityMail_Spacer:SetAnchor(TOP, scrollChild, TOP, 0, verticalOffset + #sortedQueue * rowHeight)
			dialog.badge:SetText(tostring(#sortedQueue))
			dialog.badge:SetHidden(false)
			dialog:SetEmpty(false)
		else
			dialog.badge:SetHidden(true)
			dialog:SetEmpty(true)
		end
	end
end

function PMail:OnMailQueueChanged()
	if not PriorityMail_MailQueue:IsHidden() and PriorityMail_MailQueue.expanded then
		self:RefreshMailQueue()
	end
	self:RegisterUpdateMailQueue()
end

function PMail:OnQueuedMail(mail)
	if mail then
		local alert = string.format("Queued delivery of |cffffff%s|r to |cffffff%s|r", mail.subject or "(no subject)", mail.to or "")
		df("Priority Mail %s", alert)
		self:ShowAlert(alert)
		PlaySound("CrownCrates_Card_Flipping")
		self:OnMailQueueChanged()
	end
end

function PMail:ShowAlert(message)
	PriorityMail_MailQueue:ShowAlert(message)
end

function PMail:SetQueuedGold(gold)
	self.queuedGold = gold
end

function PMail:GetQueuedGold()
	return self.queuedGold or 0
end

function PMail:OnQueuedMoneyChanged(gold)
	self:SetQueuedGold(gold)
end

function PMail:GetVersion()
	return self.AddonVersion
end

function PMail:GetConfig()
	return self.Vars.Config
end

function PMail:GetData()
	return self.Vars.Data
end

function PMail:GetMailboxControl()
	return ZO_MailSend
end

function PMail:SuppressAlert()
	self.queuedAlert = nil
end

function PMail:GetQueuedMail()
	local data = self:GetData()
	if "table" ~= type(data.QueuedMail) then
		data.QueuedMail = {}
	end
	return data.QueuedMail
end

function PMail:ForceClearLastSendMail()
	self.lastSendMail = nil
end

function PMail:ClearLastSendMail(mail)
	if self:AreMailsEqual(self.lastSendMail, mail) then
		self.lastSendMail = nil
	end
end

function PMail:SetLastSendMail(mail)
	if not self.lastSendMail then
		self.lastSendMail = mail
	end
end

function PMail:IsLastSendMail(mail)
	return self:AreMailsEqual(self.lastSendMail, mail)
end

function PMail:ClearPendingMail()
	self.pendingMail = nil
end

function PMail:GetPendingMail()
	return self.pendingMail
end

function PMail:SetPendingMail(mail)
	self.pendingMail = mail
end

function PMail:IsPendingMailLastSendMail()
	return self:IsLastSendMail(self:GetPendingMail())
end

do
	local function QueueComparer(mailA, mailB)
		return (mailA.attempted or 0) < (mailB.attempted or 0) or (mailA.attempted == mailB.attempted and (mailA.sent or 0) < (mailB.sent or 0))
	end

	function PMail:GetNextQueuedMail()
		local queue = self:GetQueuedMail()
		local mail
		if #queue > 0 then
			table.sort(queue, QueueComparer)
			mail = queue[1]
			mail.attempted = GetTimeStamp()
		end
		return mail
	end
end

function PMail:SetMailboxOpen(isOpen)
	self.mailboxOpen = false ~= isOpen
	local mail = self:GetPendingMail()
	if mail then
		SendMail(mail.to, mail.subject, mail.body)
	end
end

function PMail:IsMailboxOpen()
	return true == self.mailboxOpen
end

function PMail:IsComposingMail()
	local scene = SCENE_MANAGER:GetCurrentScene()
	return self:IsMailboxOpen() and scene and scene.name == "mailSend"
end

function PMail:ClearComposedMail()
	ZO_MailSendToField:SetText("")
	ZO_MailSendSubjectField:SetText("")
	ZO_MailSendBodyField:SetText("")
end

function PMail:GetComposedMail()
	local to, subject, body, attachedGold, numAttachedItems
	if self:IsComposingMail() then
		to = ZO_MailSendToField:GetText()
		subject = ZO_MailSendSubjectField:GetText()
		body = ZO_MailSendBodyField:GetText()
		attachedGold = GetQueuedMoneyAttachment()
		numAttachedItems = 0
		for attachmentIndex = 1, 6 do
			local bag = GetQueuedItemAttachmentInfo(attachmentIndex)
			if bag ~= 0 then
				numAttachedItems = numAttachedItems + 1
			end
		end
	end
	return to, subject, body, attachedGold, numAttachedItems
end

function PMail:QueueMail(to, subject, body, gold)
	if to and subject and body then
		gold = tonumber(gold) or 0
		local mail = {
			sent = GetTimeStamp(),
			attempted = 0,
			attempts = 0,
			delivered = 0,
			to = to,
			subject = subject,
			body = body,
			gold = gold,
		}
		table.insert(self:GetQueuedMail(), mail)
		self:OnQueuedMail(mail)
		self:ClearComposedMail()
		return true
	end
end

function PMail:DequeueMail(mail)
	local queue = self:GetQueuedMail()
	for index = 1, #queue do
		if queue[index] == mail then
			table.remove(queue, index)
			self:OnMailQueueChanged()
			break
		end
	end
end

function PMail:ClearQueuedMail()
	local queue = self:GetQueuedMail()
	ZO_ClearTable(queue)
	self:OnMailQueueChanged()
end

function PMail:OpenMailbox()
	RequestOpenMailbox()
end

function PMail:CloseMailbox()
	if self:IsMailboxOpen() then
		CloseMailbox()
		EVENT_MANAGER:RegisterForUpdate(self.EventDescriptor.."CloseMailbox", 250, function() self:CloseMailbox() end)
	else
		EVENT_MANAGER:UnregisterForUpdate(self.EventDescriptor.."CloseMailbox")
	end
end

function PMail:SendMail(mail)
	if mail then
		self:SetPendingMail(mail)
		mail.attempted = GetTimeStamp()
		mail.attempts = (mail.attempts or 0) + 1
		--if mail.gold ~= 0 then QueueMoneyAttachment(mail.gold) end
		self:OpenMailbox()
	end
end

function PMail:OnFullRecipientMailbox()
	if self:GetPendingMail() then
		self:SuppressAlert()
	elseif self:IsComposingMail() then
		local to, subject, body, _, numAttachedItems = self:GetComposedMail()
		local attachedGold = self:GetQueuedGold()
		if to then
			if (attachedGold and attachedGold > 0) or numAttachedItems > 0 then
				self:ShowAlert("Mail with attachments or gold cannot be queued")
			else
				self:QueueMail(to, subject, body, attachedGold)
			end
		end
	end
end

function PMail:ReadyToSendMail()
	if self:IsComposingMail() then
		return false
	end
	if self:GetPendingMail() then
		local attemptDurationS = GetTimeStamp() - (self:GetPendingMail().attempted or 0)
		if attemptDurationS > self.SendMailTimeoutS then
			return false
		end
	end
	if IsUnderArrest() then
		return false
	end
	if IsInteractionCameraActive() then
		return false
	end
	if IsUnitActivelyEngaged("player") then
		return false
	end
	if IsUnitInCombat("player") then
		return false
	end
	if IsUnitInDungeon("player") then
		return false
	end
	if IsUnitDeadOrReincarnating("player") then
		return false
	end
	if IsUnitPvPFlagged("player") then
		return false
	end
	return true
end

function PMail:UnregisterUpdateMailQueue()
	EVENT_MANAGER:UnregisterForUpdate(self.QueueEventDescriptor)
end

function PMail:RegisterUpdateMailQueue(interval)
	interval = interval or self.UpdateMailQueueIntervalMS
	self:UnregisterUpdateMailQueue()
	EVENT_MANAGER:RegisterForUpdate(self.QueueEventDescriptor, interval, function() PRIORITY_MAIL:OnUpdateMailQueue() end)
end

function PMail:OnUpdateMailQueue()
	if not self:ReadyToSendMail() then
		self:RegisterUpdateMailQueue(self.UpdateMailQueueRetryIntervalMS)
	else
		local mail = self:GetNextQueuedMail()
		if mail then
			self:SendMail(mail)
			self:OnMailQueueChanged()
			self:RegisterUpdateMailQueue()
		else
			self:UnregisterUpdateMailQueue()
		end
	end
end

function PMail:AreMailsEqual(mailA, mailB)
	if not mailA or not mailB then
		return false
	end
	return mailA.to == mailB.to and mailA.subject == mailB.subject and mailA.body == mailB.body
end