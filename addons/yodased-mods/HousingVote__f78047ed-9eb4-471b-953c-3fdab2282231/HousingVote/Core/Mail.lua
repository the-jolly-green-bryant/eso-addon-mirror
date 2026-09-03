local HV = HousingVote

-- ============================================================
-- string helpers
-- ============================================================

-- Escapes a literal single character for safe use inside a Lua pattern.
-- Needed because our delimiters ("|", "~", "^") include "^", which is a
-- pattern anchor/magic character, not a literal, if passed to gsub as-is.
local function EscapeForPattern(char)
    return char:gsub("(%W)", "%%%1")
end

local function Sanitize(text)
    text = tostring(text or "")
    text = text:gsub(EscapeForPattern(HV.FIELD_SEP), " ")
        :gsub(EscapeForPattern(HV.LIST_SEP), " ")
        :gsub(EscapeForPattern(HV.SUB_SEP), " ")
        :gsub("[\r\n]", " ")
    return text
end
HV.Sanitize = Sanitize

local function SplitString(str, sep)
    local parts = {}
    local escapedSep = EscapeForPattern(sep)
    local pattern = string.format("([^%s]*)%s", escapedSep, escapedSep)
    local lastEnd = 1
    local s, e, cap = str:find(pattern, 1)
    while s do
        table.insert(parts, cap)
        lastEnd = e + 1
        s, e, cap = str:find(pattern, lastEnd)
    end
    table.insert(parts, str:sub(lastEnd))
    return parts
end

local function EncodeList(list)
    local out = {}
    for i, v in ipairs(list) do
        out[i] = Sanitize(v)
    end
    return table.concat(out, HV.LIST_SEP)
end
HV.EncodeList = EncodeList

local function DecodeList(str)
    if str == nil or str == "" then
        return {}
    end
    return SplitString(str, HV.LIST_SEP)
end
HV.DecodeList = DecodeList

-- ============================================================
-- message encode / decode
-- ============================================================

-- fields is an ordered array of already-string-safe values (use Sanitize /
-- EncodeList on anything that came from free text before passing it in).
function HV.BuildMessageBody(msgType, contestId, fields)
    local parts = { HV.PROTOCOL_VERSION, msgType, contestId }
    for _, f in ipairs(fields or {}) do
        table.insert(parts, tostring(f))
    end
    return table.concat(parts, HV.FIELD_SEP)
end

-- Returns a table { msgType=, contestId=, fields={...} } or nil if this
-- isn't (or isn't a well-formed) HousingVote protocol message.
function HV.ParseMessageBody(body)
    if not body or body == "" then return nil end
    local parts = SplitString(body, HV.FIELD_SEP)
    if #parts < 3 or parts[1] ~= HV.PROTOCOL_VERSION then
        return nil
    end
    local fields = {}
    for i = 4, #parts do
        table.insert(fields, parts[i])
    end
    return { msgType = parts[2], contestId = parts[3], fields = fields }
end

-- ============================================================
-- outbound queue (throttled so a burst of requests can never turn into a
-- mail-spam spike -- see Constants.lua OUTBOUND_SEND_INTERVAL_MS)
-- ============================================================

local outboundQueue = {}
local sendTimerRunning = false

local function PumpQueue()
    local next_ = table.remove(outboundQueue, 1)
    if not next_ then
        sendTimerRunning = false
        return
    end

    local subject = HV.PROTOCOL_TAG
    if MAIL_MAX_SUBJECT_CHARACTERS and #subject > MAIL_MAX_SUBJECT_CHARACTERS then
        subject = subject:sub(1, MAIL_MAX_SUBJECT_CHARACTERS)
    end

    local body = next_.body
    if MAIL_MAX_BODY_CHARACTERS and #body > MAIL_MAX_BODY_CHARACTERS then
        body = body:sub(1, MAIL_MAX_BODY_CHARACTERS)
        HV.Print(string.format("|cFF6600Warning: message to %s was truncated to fit the mail body limit.|r", next_.recipient))
    end

    local ok = pcall(SendMail, next_.recipient, subject, body)
    if not ok then
        HV.Print(string.format("|cFF0000Failed to queue mail to %s.|r", next_.recipient))
    end

    zo_callLater(PumpQueue, HV.OUTBOUND_SEND_INTERVAL_MS)
end

function HV.QueueOutbound(recipient, msgType, contestId, fields)
    table.insert(outboundQueue, {
        recipient = recipient,
        body = HV.BuildMessageBody(msgType, contestId, fields),
    })
    if not sendTimerRunning then
        sendTimerRunning = true
        PumpQueue()
    end
end

-- ============================================================
-- inbound: scan the mailbox for our tagged, unread mail
-- ============================================================

local pendingRead = {} -- mailId -> senderDisplayName

local function HandleParsedMessage(senderDisplayName, parsed)
    if HV.OnProtocolMessage then
        HV.OnProtocolMessage(senderDisplayName, parsed)
    end
end

local function TryReadMail(mailId, senderDisplayName)
    if not IsReadMailInfoReady(mailId) then
        pendingRead[mailId] = senderDisplayName
        return
    end
    local ok, body = pcall(ReadMail, mailId)
    if ok and body then
        local parsed = HV.ParseMessageBody(body)
        if parsed then
            HandleParsedMessage(senderDisplayName, parsed)
        end
    end
    HV.sv.seenMailIds[mailId] = true
    pendingRead[mailId] = nil
end

local function ScanInbox()
    pcall(RequestOpenMailbox)

    local mailId = GetNextMailId(nil)
    while mailId do
        if not HV.sv.seenMailIds[mailId] then
            local senderDisplayName, _, subject, _, unread = GetMailItemInfo(mailId)
            if unread and subject and subject:find(HV.PROTOCOL_TAG, 1, true) then
                TryReadMail(mailId, senderDisplayName)
            end
        end
        mailId = GetNextMailId(mailId)
    end
end

function HV.InitMail()
    EVENT_MANAGER:RegisterForEvent(HV.name, EVENT_MAIL_INBOX_UPDATE, ScanInbox)
    EVENT_MANAGER:RegisterForEvent(HV.name, EVENT_MAIL_READABLE, function(eventCode, mailId)
        local senderDisplayName = pendingRead[mailId]
        if senderDisplayName then
            TryReadMail(mailId, senderDisplayName)
        end
    end)
end
