
CookeryWizMailHandler = {}
CookeryWizMailHandler.name = ""
CookeryWizMailHandler.inbox = nil
CookeryWizMailHandler.inboxFilter = nil
CookeryWizMailHandler.filteredInbox = {}

CookeryWizMailHandler.traceEnabled = false

local function trace(msg)
  CookeryWizMailHandler:Trace(msg)
end

---------------------------------------------------------------------
-- Initialisation
---------------------------------------------------------------------
function CookeryWizMailHandler:Trace(msg)
  if self.traceEnabled then
    d(GetTimeString()..":"..msg)
  end
end

function CookeryWizMailHandler:new()
    local o = {}
    setmetatable(o, self)
    self.__index = self
    -- create random name
    o.name = self:Random(32)
    o:RegisterEvents()
    -- trigger mail scan
    --RequestOpenMailbox()
    return o
end

function CookeryWizMailHandler:RegisterEvents()
  
  EVENT_MANAGER:RegisterForEvent(self.name, EVENT_MAIL_REMOVED, function(...)
    self:OnMailRemoved(...)
  end)

  EVENT_MANAGER:RegisterForEvent(self.name, EVENT_MAIL_OPEN_MAILBOX, function(...)
    self:OnOpenMailBox(...)
  end)

  EVENT_MANAGER:RegisterForEvent(self.name, EVENT_MAIL_CLOSE_MAILBOX, function(...)
    self:OnCloseMailBox(...)
  end)
  
  EVENT_MANAGER:RegisterForEvent(self.name, EVENT_MAIL_SEND_FAILED, function(...)
    self:OnMailSendFailed(...)
  end)
 
  EVENT_MANAGER:RegisterForEvent(self.name, EVENT_MAIL_SEND_SUCCESS, function(...)
    self:OnMailSendSuccess(...)
  end)
  
  EVENT_MANAGER:RegisterForEvent(self.name, EVENT_MAIL_READABLE, function(...)
    self:OnMailReadable(...)
  end)
  
  EVENT_MANAGER:RegisterForEvent(self.name, EVENT_MAIL_INBOX_UPDATE, function(...)
    self:OnMailInboxUpdate(...)
  end)
 
  EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLAYER_ACTIVATED, function (eventCode)
        self:OnPlayerActivated(eventCode)
      end)   
end

function CookeryWizMailHandler:Random(length)
	local str = "";
	for i = 1, length do
		str = str..string.char(math.random(97, 122));
	end
	return str;
end

---------------------------------------------------------------------
-- Mail events
---------------------------------------------------------------------

function CookeryWizMailHandler:OnOpenMailBox(eventCode)
  trace("OnOpenMailBox["..eventCode.."]")
end

function CookeryWizMailHandler:OnCloseMailBox(eventCode)
  trace("OnCloseMailBox["..eventCode.."]")
end

function CookeryWizMailHandler:OnMailRemoved(eventCode, mailId)
  trace("OnMailRemoved["..eventCode.."], ["..mailId.."]")
  -- remove message
  self:DeleteInboxMessage(mailId)
end

function CookeryWizMailHandler:OnMailSendFailed(eventCode, reason)
  trace("OnMailSendFailed["..eventCode.."], reason "..reason)
end

function CookeryWizMailHandler:OnMailSendSuccess(eventCode)
  trace("OnMailSendSuccess["..eventCode.."]")   
end

function CookeryWizMailHandler:OnMailReadable(eventCode, mailId)
  trace("OnMailReadable["..eventCode.."], ["..mailId.."]")
end

function CookeryWizMailHandler:OnMailInboxUpdate(eventCode)
  trace("OnMailInboxUpdate["..eventCode.."]")
  local firstTime = false
  if not self.inbox then
    firstTime = true
    self.inbox = {}
  end
  if #self.inbox ~= GetNumMailItems() then
    self:ScanInbox()
  end
  if firstTime then
    CloseMailbox() 
  end
end

function CookeryWizMailHandler:OnPlayerActivated(eventCode)
  RequestOpenMailbox()
end


---------------------------------------------------------------------
-- General routines
---------------------------------------------------------------------

function CookeryWizMailHandler:EnableUIMode(enable)
  if enable then
    if not SCENE_MANAGER:IsInUIMode() then
      SCENE_MANAGER:SetInUIMode(true)
    end
  else
    if SCENE_MANAGER:IsInUIMode() then
      SCENE_MANAGER:SetInUIMode(false)
    end      
  end
end

---------------------------------------------------------------------
-- Inbox Mail routines
---------------------------------------------------------------------

function CookeryWizMailHandler:ClearFilteredInbox()
  for k in next, self.filteredInbox do self.filteredInbox[k] = nil end
end

function CookeryWizMailHandler:FilterInboxMessage(message)
  local filteredMessage = message
  if self.inboxFilter then
    filteredMessage = self.inboxFilter(message)
  end
  return filteredMessage
end

function CookeryWizMailHandler:FilterInboxMessages()
  
  self:ClearFilteredInbox()
  
  for i = 1, #self.inbox do
    local message = self.inbox[i]
    self:AddFilteredInboxMessage(message)
  end
end

function CookeryWizMailHandler:GetInboxMessages()
  return self.inbox
end

function CookeryWizMailHandler:GetFilteredInboxMessages()
  return self.filteredInbox
end

function CookeryWizMailHandler:GetInboxMessage(mailId)
  if not mailId then
    d("Invalid mailId passed to GetInboxMessage")
    return
  end
  
  for i = 1, #self.inbox do
    local message = self.inbox[i]
    if message:GetMailId() == mailId then
      return message
    end
  end
end

function CookeryWizMailHandler:DeleteInboxMessage(mailId)
  if not mailId then
    d("Invalid mailId passed to DeleteInboxMessage")
    return
  end
  
  for i = 1, #self.filteredInbox do
    local message = self.filteredInbox[i]
    if message.GetMailId() == mailId then
      self.filteredInbox:remove(i)
      break
    end
  end
  
  for i = 1, #self.inbox do
    local message = self.inbox[i]
    if message.GetMailId() == mailId then
      self.inbox:remove(i)
      return message
    end
  end
end

function CookeryWizMailHandler:AddInboxMessage(mailId)
  local message = CookeryWizMailMessage:new(mailId)
  self.inbox[#self.inbox + 1] = message
  self:AddFilteredInboxMessage(message)
end

function CookeryWizMailHandler:AddFilteredInboxMessage(message)
  local filteredMessage = self:FilterInboxMessage(message)
  if filteredMessage then
    self.filteredInbox[#self.filteredInbox + 1] = message
  end
end

function CookeryWizMailHandler:ScanInbox()  
  local mailId = GetNextMailId(nil)
  while mailId do
    local existingMessage = self:GetInboxMessage(mailId)
    if not existingMessage then
      self:AddInboxMessage(mailId)
    end
    -- get the next mail entry id
    mailId = GetNextMailId(mailId)
  end

end

function CookeryWizMailHandler:EnumerateInboxMessages()
  for i = 1, #self.inbox do
    local message = self.inbox[i]
    message:Dump()
  end
end

function CookeryWizMailHandler:PushInboxFilter(filter)
  self.inboxFilter = filter
  self:FilterInboxMessages()
end

function CookeryWizMailHandler:PopInboxFilter()
  self.inboxFilter = nil
  self:FilterInboxMessages()
end
