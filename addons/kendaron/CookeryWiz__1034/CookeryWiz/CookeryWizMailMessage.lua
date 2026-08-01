CookeryWizMailMessage = {}

CookeryWizMailMessage.mailId = nil
CookeryWizMailMessage.senderDisplayName = ""
CookeryWizMailMessage.senderCharacterName = ""
CookeryWizMailMessage.subject = ""
CookeryWizMailMessage.icon = nil
CookeryWizMailMessage.unread = nil
CookeryWizMailMessage.fromSystem = nil
CookeryWizMailMessage.fromCustomerService = nil
CookeryWizMailMessage.returned = nil
CookeryWizMailMessage.numAttachments = nil
CookeryWizMailMessage.attachedMoney = nil
CookeryWizMailMessage.codAmount = nil
CookeryWizMailMessage.expiresInDays = nil
CookeryWizMailMessage.secsSinceReceived = nil

local function trace(msg)
  CookeryWizMailHandler:Trace(msg)
end

---------------------------------------------------------------------
-- Initialisation
---------------------------------------------------------------------

function CookeryWizMailMessage:new (mailId)
  o = {} 
      
  setmetatable(o, self)
  self.__index = self
  
  o.stringMailId = Id64ToString(mailId)
  
  trace("Constructing message "..o.stringMailId)
  o.mailId = mailId
  o.senderDisplayName, o.senderCharacterName, o.subject, o.icon, o.unread, o.fromSystem, o.fromCustomerService, o.returned,
  o.numAttachments, o.attachedMoney, o.codAmount, o.expiresInDays, o.secsSinceReceived = GetMailItemInfo(mailId) 
  
  return o
end

---------------------------------------------------------------------
-- Message routines
---------------------------------------------------------------------

function CookeryWizMailMessage:Dump()
  trace("MailId["..self.mailId.."] - "..self.subject)
end

function CookeryWizMailMessage:GetMailId()
  return self.mailId
end

function CookeryWizMailMessage:GetSenderDisplayName()
  return self.senderDisplayName
end

function CookeryWizMailMessage:GetSenderCharacterName()
  return self.senderCharacterName
end

function CookeryWizMailMessage:GetSubject()
  return self.subject
end

