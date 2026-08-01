-- Shissu Framework: Chat functions
-- --------------------------------
-- 
-- Desc:        Allgemeine Chatfunktionen, die von den verschiedenen Modulen genutzt werden (können).
-- Filename:    functions/chatsystem.lua
-- Last Update: 17.12.2020
--
-- Written by Christian Flory (@Shissu, EU) - esoui@flory.one
-- Distribution without license is prohibited!

local _chat = {}
_lchat = {}

_lchat.enabled = 0
_lchat.EVENT_CHATS = {}

_lchat.formatEnabled = 0
_lchat.EVENT_CHATS_FORMAT = {}
_lchat.TEXT_FILTER = {}

local _globals = ShissuFramework["globals"]
local white = _globals["white"]
local red = _globals["red"]
local yellow = _globals["yellow"]
local stdColor = _globals["stdColor"]
local colorEnd = "|r"

local ChannelInfo = ZO_ChatSystem_GetChannelInfo()
local messageFormatters = CHAT_ROUTER:GetRegisteredMessageFormatters()

-- Filtern der Chatausgaben nach Inhalten ohne deren Manipulation, um z.B. den Chatkanal zu wechseln
-- Auslagerung, da die Funktion ist der Zukunft noch von anderen Modulen verwendet wird.
function _lchat.EVENT_CHAT_MESSAGE_CHANNEL(eventId, messageType, fromName, text, isFromCustomerService, fromDisplayName)
  if (_lchat.EVENT_CHATS == nil) then return end
  
  for name, func in pairs(_lchat.EVENT_CHATS) do
    func(eventId, messageType, fromName, text, isFromCustomerService, fromDisplayName)
  end
end

-- Start des EVENT-Handler: EVENT_CHAT_MESSAGE_CHANNEL, wird bei der Registrierung eines Moduls ausgelöst, sofern nötig
function _lchat.initializeEventChatMessage()
  if (_lchat.enabled == 0) then
    EVENT_MANAGER:RegisterForEvent("ShissuFramework", EVENT_CHAT_MESSAGE_CHANNEL, _lchat.EVENT_CHAT_MESSAGE_CHANNEL)
    _lchat.enabled =1 
  end
end

-- Erfasst/Registriert die einzelnen Filterungen des Chats, und gibt Sie an den EVENT_HANDLER weiter.
function _chat.registerEventChatMessage(module, func)
  _lchat.EVENT_CHATS[module] = func
  _lchat.initializeEventChatMessage()
end

local meow = 0



function _lchat.FORMAT_EVENT_CHAT_MESSAGE_CHANNEL(messageType, fromName, text, isFromCustomerService, fromDisplayName)
  if (_lchat.EVENT_CHATS_FORMAT == nil) then return end
  
  _lchat.FORMAT_FILTER_CHAT()

  local channelInfo = ChannelInfo[messageType]
  local saveTarget = ""
  local fromDisplayName = fromDisplayName
  local formattedText = text

  for name, func in pairs(_lchat.EVENT_CHATS_FORMAT) do
    formattedText, saveTarget, fromDisplayName, text = func(messageType, fromName, formattedText, isFromCustomerService, fromDisplayName)
  end

  --_lchat.FORMAT_FILTER_CHAT()

  if formattedText ~= "" then
    return formattedText, saveTarget, fromDisplayName, text
  end
end

function _lchat.initializeFormatEventChatMessage()
  if (_lchat.formatEnabled == 0) then
    zo_callLater(function() ZO_ChatSystem_AddEventHandler(EVENT_CHAT_MESSAGE_CHANNEL, _lchat.FORMAT_EVENT_CHAT_MESSAGE_CHANNEL) end, 2000)  
   
    _lchat.formatEnabled =1 
  end
end

local onlyOne = 0
local found = 0
local oldText = ""

-- Chatfilterungen von Texten
function _lchat.FORMAT_FILTER_CHAT()
  local old = messageFormatters[EVENT_CHAT_MESSAGE_CHANNEL]

  messageFormatters[EVENT_CHAT_MESSAGE_CHANNEL] = function(messageType, fromName, text, isFromCustomerService, fromDisplayName)
    local formattedText, saveTarget, fromDisplayName, text = old(messageType, fromName, text, isFromCustomerService, fromDisplayName)

    if oldText ~= text then 
      for name, func in pairs(_lchat.TEXT_FILTER) do
      -- d(name)
        formattedText = func(messageType, fromName, formattedText, isFromCustomerService, fromDisplayName, text)  --, saveTarget, fromDisplayName, text = func(messageType, fromName, formattedText, isFromCustomerService, fromDisplayName)
      end

      if (formattedText ~= nil) then
        oldText = formattedText
        return formattedText, saveTarget, fromDisplayName, text
      end
    end
  end   
end

function _chat.registerTextFilter(module, func)
  _lchat.TEXT_FILTER[module] = func
  _lchat.FORMAT_FILTER_CHAT()
end

function _chat.registerFormatEventChatMessage(module, func)
  _lchat.EVENT_CHATS_FORMAT[module] =  func
  _lchat.initializeFormatEventChatMessage()
end

-- Platzhalter in einzelnen Strings ersetzen; %1, %2, ...
function _chat.replacePlaceholder(text, placeholderList)
  if (placeholderList ~= nil and text ~= nil) then
    for placeId, placeholderText in ipairs(placeholderList) do
      text = text:gsub("%%" .. tostring(placeId), placeholderText)
    end
  end

  return text
end

-- Chatausgabe als Systemnachricht
function _chat.print(message, placeholderList, moduleName, reason, error) 
  local message = white .. message
  local moduleName = moduleName or ""
  local reason = reason or ""
  local reasonColor = yellow

  if (moduleName ~= "") then
    moduleName = white .. "[" .. stdColor .. moduleName .. white .. "] " .. colorEnd
  end

  if (reason ~= "") then
    if (error) then
      reasonColor = red
    end

    reason = reasonColor .. reason .. white .. ": " .. colorEnd 
  end

  message = _chat.replacePlaceholder(message, placeholderList)
  message = moduleName .. reason .. message

  CHAT_ROUTER:AddSystemMessage(white .. message)
end

ShissuFramework["functions"]["chat"] = _chat