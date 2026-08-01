local LDM = LibDynamicMail

local MailInbox = MAIL_INBOX
local event_manager = EVENT_MANAGER

if IsConsoleUI() or IsInGamepadPreferredMode() then
 MailInbox = MAIL_GAMEPAD:GetInbox()
end

function LDM:selectRelevantMail(event, mailId, functionName)
  self.savedVars.InboxCallbacks = self.savedVars.InboxCallbacks or {}
  local senderDisplayName, senderCharacterName, subject, firstItemIcon, unread, fromSystem, fromCS, returned, numAttachments, attachedMoney, codAmount, expiresInDays, secsSinceReceived, category = GetMailItemInfo(mailId)
  local callback = self.savedVars.InboxCallbacks[functionName]
        and self.savedVars.InboxCallbacks[functionName]["func"]
  if not callback then return false end
  self.savedVars.InboxCallbacks[functionName]["func"](event, mailId)
  if not self.savedVars.InboxCallbacks[functionName]["preserveReadableEvent"] then
    event_manager:UnregisterForEvent(functionName.."mailboxreadable", EVENT_MAIL_READABLE)
  end
end

function LDM:UnregisterInboxReadEvents(functionName)
  event_manager:UnregisterForEvent(functionName.."mailboxreadable", EVENT_MAIL_READABLE)
end

function LDM:RegisterInboxCallback(functionName, functionCallback, preserveReadableEvent)
  self.savedVars.InboxCallbacks = self.savedVars.InboxCallbacks or {}
  self.savedVars.InboxCallbacks[functionName] = { func = functionCallback, preserveReadableEvent = preserveReadableEvent }
end

function LDM:RegisterInboxEvents(functionName)
  event_manager:RegisterForEvent(functionName.."mailboxreadable", EVENT_MAIL_READABLE, function(event, mailId)
    self:selectRelevantMail(event, mailId, functionName)
   end)
end

function LDM:SafeDeleteMail(mailId, forceBool)
  local requestResult = RequestReadMail(mailId)
  if requestResult ~= nil and requestResult <= REQUEST_READ_MAIL_RESULT_SUCCESS_SERVER_REQUESTED then
    DeleteMail(mailId, forceBool)
  else
    zo_callLater(function()
        self:SafeDeleteMail(mailId, forceBool)

    end, math.max(GetLatency()+10, 100))
  end
end

function LDM:RetrieveActiveMailBody()
  local mailId
  if IsConsoleUI() or IsInGamepadPreferredMode() then
    mailId = MailInbox:GetActiveMailId()
  else
    mailId = MailInbox:GetOpenMailId()
  end
  return ReadMail(mailId)
end

function LDM:RetrieveMailData(mailId)
  local senderDisplayName, senderCharacterName, subject, firstItemIcon, unread, fromSystem, fromCS, returned, numAttachments, attachedMoney, codAmount, expiresInDays, secsSinceReceived, category = GetMailItemInfo(mailId)
  return {
    subject = subject,
    returned = returned,
    senderDisplayName = senderDisplayName,
    senderCharacterName = senderCharacterName,
    expiresInDays = expiresInDays,
    unread = unread,
    numAttachments = numAttachments,
    attachedMoney = attachedMoney,
    codAmount = codAmount,
    secsSinceReceived = secsSinceReceived,
    fromSystem = fromSystem,
    fromCS = fromCS,
    isFromPlayer = isFromPlayer,
    GetFormattedSubject = GetFormattedSubject,
    GetFormattedReplySubject = GetFormattedReplySubject,
    GetExpiresText = GetExpiresText,
    GetReceivedText = GetReceivedText,
    isReadInfoReady = isReadInfoReady,
    IsExpirationImminent = IsExpirationImminent,
    firstItemIcon = firstItemIcon,
    category = category
  }
end

function LDM:CheckMailForFieldValue(mailId, searchValue, fieldKey, operator)
  local senderDisplayName, senderCharacterName, subject, firstItemIcon, unread, fromSystem, fromCS, returned, numAttachments, attachedMoney, codAmount, expiresInDays, secsSinceReceived, category = GetMailItemInfo(nextMailId)

  local mailData = {
    senderDisplayName = senderDisplayName,
    subject = subject
  }
  if not operator or operator == "equals" then
    if searchValue == mailData[fieldKey] then
      return true
    end
  end
  if operator == "contains" then
    if mailData[fieldKey]:find(searchValue, 1, true) ~= nil then
      return true
    end
  end
  return false
end

function LDM:FetchMailIdsForFieldValue(searchValue, fieldKey, operator, mailId, mailIds)
  local nextMailId = GetNextMailId(mailId)
  if not nextMailId then
    return mailIds
  end
  mailIds = mailIds or {}
  local mailData = {}

  local senderDisplayName, senderCharacterName, subject, firstItemIcon, unread, fromSystem, fromCS, returned, numAttachments, attachedMoney, codAmount, expiresInDays, secsSinceReceived, category = GetMailItemInfo(nextMailId)

  local nextMail = {
    senderDisplayName = senderDisplayName,
    subject = subject,
  }

  if not operator or operator == "equals" then
    if searchValue == nextMail[fieldKey] then
      table.insert(mailIds, nextMailId)
    end
  end
  if operator == "contains" then
    if nextMail[fieldKey]:find(searchValue, 1, true) ~= nil then
      table.insert(mailIds, nextMailId)
    end
  end
  return self:FetchMailIdsForFieldValue(searchValue, fieldKey, operator, nextMailId, mailIds)
end

function LDM:CheckMailForSubject(mailId, searchValue, operator)
  return self:CheckMailForFieldValue(mailId, searchValue, "subject", operator)
end

function LDM:FetchMailIdsForSubject(searchValue, operator)
  local mailIds = self:FetchMailIdsForFieldValue(searchValue, "subject", operator)
  return mailIds
end

function LDM:CheckMailForSender(mailId, searchValue, operator)
  return self:CheckMailForFieldValue(mailId, searchValue, "senderDisplayName", operator)
end

function LDM:FetchMailIdsForSender(searchValue, operator)
  return self:FetchMailIdsForFieldValue(searchValue, "senderDisplayName", operator)
end
