-- Local instances of Global tables
local SK = SwissKnife
local SKH = SK.HelperFunctions
local SKDC = SK.Data.common
local EM, MM = EVENT_MANAGER, MAIL_MANAGER

SK.Mailer = ZO_Object:Subclass()

function SK.Mailer:New()
	local obj = ZO_Object.New(self)
	obj.inbox = MAIL_INBOX
	obj.mailBoxOpen = false
	obj.isManualMode = false
	obj.closeMailBoxAfterSend = false
	obj.mailSendFailureCount = 0
	obj.resourcesOptions = SK.savedVars.sendMailByTypeOptions[SK.ATTACHMENT_TYPES.RESOURCES]
	return obj
end

function SK.Mailer:PrepareOneMail(attachmentsType, attachments)
	self.pendingMail[self.pendingMailCount] = {
		recipient = SK.savedVars.sendMailByTypeOptions[attachmentsType].recipient,
		subject = GetString("SI_SK_AUT_MAIL_SUBJECT", attachmentsType),
		body = SKH.getFormattedText(GetString(SI_SK_AUT_MAIL_BODY), SK.COLORED_SUFFIXES.SKM),
		attachments = attachments
	}
end

function SK.Mailer:NothingMessage()
	SKH.sendMessageToChat(
		SK.COLORED_PREFIXES.SKM,
		SK.COLOR.RED:Colorize(GetString(SI_SK_AUT_MAIL_ATTACHMENT_NO_ITEMS))
	)
	SKH.sendMessageToChat(
		SK.COLORED_PREFIXES.SKM,
		SK.COLOR.YELLOW:Colorize(GetString(SI_SK_AUT_MAIL_ATTACHMENT_NO_ITEMS_HELP))
	)
end

function SK.Mailer:PrepareAllMail()
	self.pendingMail = {}
	self.pendingMailCount = 0
	local maxAttachments = 6
	local attachments = SKH.filterAllBackpackAttachments()
	if attachments and attachments ~= {} then
		local currentAttached = 0
		local currentAttachments = {}
		for attachmentsType, attachmentsData in pairs(attachments) do
			for _, slotIndex in ipairs(attachmentsData) do
				currentAttached = currentAttached + 1
				table.insert(currentAttachments, slotIndex)
				if currentAttached == maxAttachments then
					self.pendingMailCount = self.pendingMailCount + 1
					self:PrepareOneMail(attachmentsType, currentAttachments)
					currentAttached = 0
					currentAttachments = {}
				end
			end
			if currentAttached ~= 0 then
				if not SK.savedVars.sendFullMailOnly then
					self.pendingMailCount = self.pendingMailCount + 1
					self:PrepareOneMail(attachmentsType, currentAttachments)
				end
				currentAttached = 0
				currentAttachments = {}
			end
			if self.pendingMailCount == 0 then self:NothingMessage() end
		end
	else
		self:NothingMessage()
	end
end

function SK.Mailer:SendMailWatcher(pendingMailCount)
	if self.pendingMailCount == pendingMailCount then self:SendMailFailure() end
end

function SK.Mailer:SendAllMail()
	if self.mailBoxOpen then
		if self.pendingMailCount > 0 then
			self:SendMail(self.pendingMail[self.pendingMailCount])
		elseif self.closeMailBoxAfterSend then
			CloseMailbox()
		end
	end
end

function SK.Mailer:FindAttachmentSlot()
	for i = 1, MAIL_MAX_ATTACHED_ITEMS do
		if GetQueuedItemAttachmentInfo(i) == 0 then
			return i
		end
	end
end

function SK.Mailer:SendMail(pendingMail)
	if pendingMail then
		local nextFreeAttachmentSlot, result
		self.onSuccessCallback = function() self:SendAllMail() end
		self:RegisterMailSendEvents()
		ClearQueuedMail()
		for _, slotIndex in pairs(pendingMail.attachments) do
			if not IsItemPlayerLocked(BAG_BACKPACK, slotIndex) then
				nextFreeAttachmentSlot = self:FindAttachmentSlot()
				if nextFreeAttachmentSlot then
					result = QueueItemAttachment(BAG_BACKPACK, slotIndex, nextFreeAttachmentSlot)
					if result == MAIL_ATTACHMENT_RESULT_ALREADY_ATTACHED or itemLink == MAIL_ATTACHMENT_RESULT_BOUND
						or result == MAIL_ATTACHMENT_RESULT_ITEM_NOT_FOUND or result == MAIL_ATTACHMENT_RESULT_LOCKED
					then
						local itemLink = GetItemLink(BAG_BACKPACK, slotIndex)
						SKH.sendMessageToChat(
							SK.COLORED_PREFIXES.SKM,
							SK.COLOR.RED:Colorize(GetString(SI_SK_AUT_MAIL_ATTACHMENT_ERROR)),
							itemLink
						)
					end
				end
			end
		end
		SendMail(pendingMail.recipient, pendingMail.subject, pendingMail.body)
		local pendingMailCount = self.pendingMailCount
		local delay = SK.savedVars.failureSendMailTimeout
		if delay == nil or delay == "" then delay = 10000 end
		zo_callLater(function() self:SendMailWatcher(pendingMailCount) end, delay)
	end
end

function SK.Mailer:RegisterMailSendEvents()
	EM:RegisterForEvent("SK_Mailer_Automation", EVENT_MAIL_SEND_SUCCESS, function() self:SendMailSuccess() end)
	EM:RegisterForEvent("SK_Mailer_Automation", EVENT_MAIL_SEND_FAILED, function() self:SendMailFailure() end)
end  

function SK.Mailer:UnregisterMailSendEvents()
	EM:UnregisterForEvent("SK_Mailer_Automation", EVENT_MAIL_SEND_SUCCESS)
	EM:UnregisterForEvent("SK_Mailer_Automation", EVENT_MAIL_SEND_FAILED)
end

function SK.Mailer:SendMailSuccess()
	self:UnregisterMailSendEvents()
	SKH.sendMessageToChat(
		SK.COLORED_PREFIXES.SKM,
		SK.COLOR.GREEN:Colorize(GetString(SI_SK_AUT_SEND_MAIL_SUCCESS)),
		self.pendingMail[self.pendingMailCount].recipient
	)
	self.mailSendFailureCount = 0
	self.pendingMail[self.pendingMailCount] = nil
	self.pendingMailCount = self.pendingMailCount - 1
	local delay = SK.savedVars.sendMailToAnotherAccountDelay
	if self.onSuccessCallback then
		if delay == nil or delay == "" then delay = 200 end
		zo_callLater(self.onSuccessCallback, delay)
	end
end

function SK.Mailer:SendMailFailure()
	self:UnregisterMailSendEvents()
	ClearQueuedMail()
	SKH.sendMessageToChat(
		SK.COLORED_PREFIXES.SKM,
		SK.COLOR.RED:Colorize(GetString(SI_SK_AUT_SEND_MAIL_ERROR)),
		self.pendingMailCount
	)
	self.mailSendFailureCount = self.mailSendFailureCount + 1
	if self.mailSendFailureCount > tonumber(SK.savedVars.maximumMailSendFailureCount) or
		not SK.savedVars.repeatSendMailAfterFailure
	then
		SKH.sendMessageToChat(
			SK.COLORED_PREFIXES.SKM,
			SK.COLOR.RED:Colorize(GetString(SI_SK_AUT_SEND_MAIL_REPEAT_ERROR))
		)
		self.pendingMail = {}
		self.pendingMailCount = 0
		self.mailSendFailureCount = 0
		if self.closeMailBoxAfterSend then
			self.closeMailBoxAfterSend = false
			self.isManualMode = false
			CloseMailbox()
		end
	elseif self.onSuccessCallback then
		SKH.sendMessageToChat(
			SK.COLORED_PREFIXES.SKM,
			SK.COLOR.YELLOW:Colorize(GetString(SI_SK_AUT_SEND_MAIL_REPEAT)),
			self.mailSendFailureCount
		)
		self.onSuccessCallback()
	end
end

function SK.Mailer:ReceiptMailReset()
	if self.RegisteredReceiptAttachedEvent then self:UnregisterMailTakeAttachedEvents() end
	if self.RegisteredReceiptRemoveEvent then self:UnregisterMailRemoveEvents() end
	self.isReceiptPending = false
	self.receiptMails = {}
	self.mailReceiptFailureCount = 0
	self.RegisteredReceiptAttachedEvent = false
	self.RegisteredReceiptRemoveEvent = false
end

function SK.Mailer:MailBoxAvailable()
	local mailId = self.receiptMails[1].mailId
	self.inbox:RequestReadMessage(mailId)
	self.inbox.mailId = mailId
	local mailData = self.inbox:GetMailData(mailId)
	return mailData ~= nil
end

function SK.Mailer:SelectMail(mailId)
	self.inbox:RequestReadMessage(mailId)
	self.inbox.mailId = mailId
	local mailData = self.inbox:GetMailData(mailId)
	if mailData ~= nil then
		ZO_MailInboxShared_PopulateMailData(mailData, mailId)
		if SK.clientAPIVersion < 100034 then
			ZO_ScrollList_RefreshVisible(self.inbox.list, mailData)
		    ZO_ScrollList_AutoSelectData(ZO_MailInboxList)
		--else
		--	d("here")
		--	return false
		end
		return true
	else
		return false
	end
end

function SK.Mailer:PrepareReceiptMails()
    for mailId in ZO_GetNextMailIdIter do
	    local _, _, subject = GetMailItemInfo(mailId)
	    subject = zo_strlower(subject)
	    if (subject == zo_strlower(GetString("SI_SK_AUT_MAIL_SUBJECT", SK.ATTACHMENT_TYPES.RESOURCES)) and
					    self.resourcesOptions.isAutomaticReceiptEnabled) or
			    (SKH.isValueInList(SKDC.SYSTEM_CRAFT_MAIL_SUBJECTS, subject) and
					    SK.savedVars.isAutomaticResourcesMailReceiptEnabled)
	    then
            local bagFreeSlots = GetBagSize(BAG_BACKPACK) - GetNumBagUsedSlots(BAG_BACKPACK)
		    if bagFreeSlots < 6 and not IsESOPlusSubscriber() then
				SKH.sendMessageToChat(
					SK.COLORED_PREFIXES.SKM,
					SK.COLOR.RED:Colorize(GetString(SI_SK_AUT_RECEIPT_MAIL_FREE_SPACE_FAILURE))
				)
			    break
			else
			    local receiptMailsCount = 1 + #self.receiptMails
			    self.receiptMails[receiptMailsCount] = {
				    mailId = mailId,
				    takeAttachments = false,
				    isDeleted = false
			    }
		    end
	    end
    end
end

function SK.Mailer:ReceiptAllMails()
	if not SKH.isReceiptMailAllow() then return end
	if not self.mailBoxOpen then return end
	self:ReceiptMailReset()
	self:PrepareReceiptMails()
	if #self.receiptMails > 0 then
		if self:MailBoxAvailable() then
			self.isReceiptPending = true
			self.currentMail = 1
			self:ReceiptNextMail()
		else
			self:ReceiptMailReset()
		end
	--elseif self.closeMailBoxAfterSend then
	--	CloseMailbox()
	--	self.closeMailBoxAfterSend = false
	end
end

function SK.Mailer:ReceiptNextMail()
	local currentMail = self.currentMail
	if self.currentMail <= #self.receiptMails then
		local bagFreeSlots = GetBagSize(BAG_BACKPACK) - GetNumBagUsedSlots(BAG_BACKPACK)
		if bagFreeSlots >= 6 then
			local mailId = self.receiptMails[currentMail].mailId
			if self:SelectMail(mailId) then
				local numAttachments, attachedMoney = GetMailAttachmentInfo(mailId)
				if (numAttachments and numAttachments > 0) or (attachedMoney and attachedMoney > 0) then
					self:RegisterMailTakeAttachedEvents()
					ZO_MailInboxShared_TakeAll(mailId)
					zo_callLater(function()
						self:MailReceiptWatcher(currentMail, function() self:ReceiptNextMail() end,
							SI_SK_AUT_RECEIPT_MAIL_ERROR)
					end, SK.savedVars.failureReceiptMailTimeout)
				else
					self:ReceiptMailAttachSuccess(mailId)
				end
			else
				SKH.sendMessageToChat(
					SK.COLORED_PREFIXES.SKM,
					SK.COLOR.RED:Colorize(GetString(SI_SK_AUT_RECEIPT_MAIL_ERROR)),
					tostring(#self.receiptMails)
				)
				self:ReceiptMailReset()
			end
		else
			SKH.sendMessageToChat(
				SK.COLORED_PREFIXES.SKM,
				SK.COLOR.RED:Colorize(GetString(SI_SK_AUT_RECEIPT_MAIL_FREE_SPACE_FAILURE))
			)
			self:DeleteEmptyMailAfterFailure()
		end
	else
		self.currentMail = 1
		self.mailReceiptFailureCount = 0
		self:DeleteNextMail()
	end
end

function SK.Mailer:DeleteEmptyMailAfterFailure()
	self.currentMail = 1
	self.mailReceiptFailureCount = 0
	self:DeleteNextMail()
end

function SK.Mailer:DeleteNextMail()
	local deleteOnClaim = MM:ShouldDeleteOnClaim()
    if self.currentMail <= #self.receiptMails then
		local currentMail = self.currentMail
		local mail = self.receiptMails[currentMail]
		if mail.takeAttachments then
			if not mail.isDeleted then
				self:RegisterMailRemoveEvents()
				if deleteOnClaim and not self:SelectMail(mail.mailId) then
					self:ReceiptMailRemoveSuccess(mail.mailId)
				elseif self:SelectMail(mail.mailId) then
					DeleteMail(mail.mailId)
					zo_callLater(function()
						self:MailReceiptWatcher(currentMail, function() self:DeleteNextMail() end,
								SI_SK_AUT_DELETE_MAIL_REPEAT_ERROR)
					end, SK.savedVars.failureReceiptMailTimeout)
				else
					SKH.sendMessageToChat(
						SK.COLORED_PREFIXES.SKM,
						SK.COLOR.RED:Colorize(GetString(SI_SK_AUT_RECEIPT_MAIL_ERROR)),
						tostring(#self.receiptMails)
					)
					self:ReceiptMailReset()
				end
			else
				self:ReceiptMailRemoveSuccess(mail.mailId)
			end
		end
    else
		SKH.sendMessageToChat(SK.COLORED_PREFIXES.SKM, SI_SK_AUT_RECEIPT_MAIL_SUCCESS, #self.receiptMails)
        self:ReceiptMailReset()
		--if self.closeMailBoxAfterSend then
		--	CloseMailbox()
		--	self.closeMailBoxAfterSend = false
		--end
    end
end

function SK.Mailer:MailReceiptWatcher(currentMail, callback, errorMessage)
	if currentMail == self.currentMail then
		if SK.savedVars.repeatReceiptMailAfterFailure then
			if self.RegisteredReceiptAttachedEvent then self:UnregisterMailTakeAttachedEvents() end
			if self.RegisteredReceiptRemoveEvent then self:UnregisterMailRemoveEvents() end
			self.mailReceiptFailureCount = self.mailReceiptFailureCount + 1
			if self.mailReceiptFailureCount > SK.savedVars.maximumMailReceiptFailureCount then
				self.currentMail = self.currentMail + 1
				self.mailReceiptFailureCount = 0
			end
			callback()
		else
			SKH.sendMessageToChat(
				SK.COLORED_PREFIXES.SKM,
				SK.COLOR.RED:Colorize(GetString(errorMessage)),
				tostring(#self.receiptMails)
			)
			self:ReceiptMailReset()
			--if self.closeMailBoxAfterSend then
			--	CloseMailbox()
			--	self.closeMailBoxAfterSend = false
			--end
		end
	end
end

function SK.Mailer:ReceiptMailAttachSuccess(mailId)
	local mail = self.receiptMails[self.currentMail]
	if AreId64sEqual(mail.mailId, mailId) then
		local numAttachments, attachedMoney = GetMailAttachmentInfo(mailId)
		if numAttachments == 0 and attachedMoney == 0 then
			self.mailReceiptFailureCount = 0
			mail.takeAttachments = true
			if self.RegisteredReceiptAttachedEvent then self:UnregisterMailTakeAttachedEvents() end
			self.currentMail = self.currentMail + 1
			self:ReceiptNextMail()
		end
	end
end

function SK.Mailer:ReceiptMailRemoveSuccess(mailId)
	local mail = self.receiptMails[self.currentMail]
	if AreId64sEqual(mail.mailId, mailId) then
		if self.RegisteredReceiptRemoveEvent then self:UnregisterMailRemoveEvents() end
	    PlaySound(SOUNDS.MAIL_ITEM_DELETED)
	    mail.isDeleted = true
		self.mailReceiptFailureCount = 0
		self.currentMail = self.currentMail + 1
	    self:DeleteNextMail()
	end
end

function SK.Mailer:RegisterMailTakeAttachedEvents()
	EM:RegisterForEvent("SK_Mailer_Automation", EVENT_MAIL_TAKE_ATTACHED_ITEM_SUCCESS, function(_, mailId)
		self:ReceiptMailAttachSuccess(mailId)
	end)
	EM:RegisterForEvent("SK_Mailer_Automation", EVENT_MAIL_TAKE_ATTACHED_MONEY_SUCCESS, function(_, mailId)
		self:ReceiptMailAttachSuccess(mailId)
	end)
	self.RegisteredReceiptAttachedEvent = true
end

function SK.Mailer:UnregisterMailTakeAttachedEvents()
	EM:UnregisterForEvent("SK_Mailer_Automation", EVENT_MAIL_TAKE_ATTACHED_ITEM_SUCCESS)
	EM:UnregisterForEvent("SK_Mailer_Automation", EVENT_MAIL_TAKE_ATTACHED_MONEY_SUCCESS)
	self.RegisteredReceiptAttachedEvent = false
end

function SK.Mailer:RegisterMailRemoveEvents()
	EM:RegisterForEvent("SK_Mailer_Automation", EVENT_MAIL_REMOVED, function(_, mailId)
		self:ReceiptMailRemoveSuccess(mailId)
	end)
	self.RegisteredReceiptRemoveEvent = true
end

function SK.Mailer:UnregisterMailRemoveEvents()
	EM:UnregisterForEvent("SK_Mailer_Automation", EVENT_MAIL_REMOVED)
	self.RegisteredReceiptRemoveEvent = false
end
