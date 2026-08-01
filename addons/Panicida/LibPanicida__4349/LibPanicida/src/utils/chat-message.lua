-- Localized Globals
local strlen = string.len
local CHAT_SYSTEM = CHAT_SYSTEM
local ZO_Object = ZO_Object

-- Constants
local MAX_CHAT_MESSAGE_LENGTH = 1500
local MSG_TOO_LONG = "Message was too long to submit"

-- Module Declaration
local ChatMessage = ZO_Object:Subclass()

-- Private Functions

--- Adds a new entry to the message buffer.
--- @param text string The text to add to buffer
function ChatMessage:_AddBufferEntry(text)
    self.bufferIndex = self.bufferIndex + 1
    self.buffer[self.bufferIndex] = text
end

-- Public Functions

--- Creates a new ChatMessage instance.
--- @param prefix string Optional prefix for all messages
--- @return table ChatMessage instance
function ChatMessage:New(prefix)
    local instance = ZO_Object.New(self)
    instance:Initialize(prefix)
    return instance
end

--- Initializes the ChatMessage instance.
--- @param prefix string Optional prefix for all messages
function ChatMessage:Initialize(prefix)
    self.prefix = prefix or ""
    self.maxCharacters = MAX_CHAT_MESSAGE_LENGTH
    self.buffer = {}
    self.bufferIndex = 0

    self:_AddBufferEntry("")
end

--- Adds a message to the buffer, splitting across entries if needed.
--- @param message string The message to add
function ChatMessage:AddMessage(message)
    if not message or message == "" then return end

    local currentIndex = self.bufferIndex
    local currentText = self.buffer[currentIndex]
    local currentLength = strlen(currentText)
    local messageLength = strlen(message)
    local maxChars = self.maxCharacters
    local availableSpace = maxChars - currentLength

    if messageLength <= availableSpace then
        self.buffer[currentIndex] = currentText .. message
    elseif messageLength <= maxChars then
        self:_AddBufferEntry(message)
    else
        self:_AddBufferEntry(MSG_TOO_LONG)
        self:_AddBufferEntry("")
    end
end

--- Submits all buffered messages to chat and resets the buffer.
function ChatMessage:Submit()
    if self.bufferIndex == 0 or (self.bufferIndex == 1 and self.buffer[1] == "") then
        return
    end

    local prefix = self.prefix

    for i = 1, self.bufferIndex do
        local message = self.buffer[i]
        if message and message ~= "" then
            CHAT_SYSTEM:AddMessage(prefix .. message)
        end
    end

    self:Reset()
end

--- Resets the message buffer to initial state.
function ChatMessage:Reset()
    self.buffer = {}
    self.bufferIndex = 0
    self:_AddBufferEntry("")
end

-- Module Registration
LibPanicida.ChatMessage = ChatMessage
