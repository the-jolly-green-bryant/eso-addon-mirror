DoItAll = DoItAll or {}

DoItAll.Mailer = ZO_Object:Subclass()

function DoItAll.Mailer:New()
  local obj = ZO_Object.New(self)
  obj.storedSubject = nil
  obj.storedRecipient = nil
  obj.onSuccessCallback = nil
  return obj
end

function DoItAll.Mailer:SendMail(onSuccessCallback)
  self.onSuccessCallback = nil
  self.onSuccessCallback = onSuccessCallback
  self:StoreOrRestoreRecipient()
  self:RegisterMailSendEvents()
  MAIL_SEND:Send()
end

function DoItAll.Mailer:RestoreRecipient()
  if self.storedRecipient then
    MAIL_SEND.to:SetText(self.storedRecipient)
  end
  if self.storedSubject then
    MAIL_SEND.subject:SetText(self.storedSubject)
  end
end

function DoItAll.Mailer:StoreOrRestoreRecipient()
  if not self:TryStoreEnteredRecipient() then
    self:RestoreRecipient()
  end
end

function DoItAll.Mailer:TryStoreEnteredRecipient()
  local enteredRecipient = MAIL_SEND.to:GetText()
  local enteredSubject   = MAIL_SEND.subject:GetText()

  if enteredRecipient and enteredRecipient ~= "" then
    self.storedRecipient = enteredRecipient
  end
  if enteredSubject and enteredSubject ~= "" then
    self.storedSubject = enteredSubject
  end

  return ((enteredRecipient ~= nil and enteredRecipient ~= ""
          and enteredSubject ~= nil and enteredSubject ~= "") and true) or false
end

function DoItAll.Mailer:RegisterMailSendEvents()
  EVENT_MANAGER:RegisterForEvent("DoItAll.AttachAll", EVENT_MAIL_SEND_SUCCESS, function() self:SendMailSuccess() end)
  EVENT_MANAGER:RegisterForEvent("DoItAll.AttachAll", EVENT_MAIL_SEND_FAILED, function() self:SendMailFailure() end)
end  

function DoItAll.Mailer:UnregisterMailSendEvents()
  EVENT_MANAGER:UnregisterForEvent("DoItAll.Mailer", EVENT_MAIL_SEND_SUCCESS)
  EVENT_MANAGER:UnregisterForEvent("DoItAll.Mailer", EVENT_MAIL_SEND_FAILED)
end

function DoItAll.Mailer:SendMailSuccess()
  self:UnregisterMailSendEvents()
  if self.onSuccessCallback then zo_callLater(self.onSuccessCallback, 200) end
end

function DoItAll.Mailer:SendMailFailure()
  self:UnregisterMailSendEvents()
end
