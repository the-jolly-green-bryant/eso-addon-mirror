-- My Little Journal — sharing notes between players.
--
-- Two transports:
--
-- 1. GROUP BROADCAST (preferred): when both players are in the same group
--    and have LibGroupBroadcast, the whole share — even a full dungeon's
--    worth of notes — is sent silently through the game's group add-on data
--    channel. Nothing appears in chat and no Enter-pressing is needed; the
--    library streams it in the background (~30 bytes per broadcast tick, so
--    large shares take a little while). The receiver gets an import prompt.
--
-- 2. CHAT LINKS (fallback, works cross-zone/whisper): the note travels
--    inside custom chat links (the same technique Wizard's Wardrobe uses
--    for build previews). Each message is one clickable link like
--    [Journal 2/3: Sentinel Aksalaz] with the note data encoded in the
--    invisible link payload. LibChatMessage is required on both ends. Long
--    notes span several link messages; the receiver collects them passively
--    and clicks any link once to import.
--
-- Wire format: the link data is ONE contiguous alphanumeric string with no
-- separators (colon-separated fields get mangled by the chat service's link
-- handling; Wizard's Wardrobe's separator-free payloads survive it).
--   [1]      version               ("3")
--   [2..7]   shareId               (6 digits)
--   [8..9]   part number           (2 digits)
--   [10..11] total parts           (2 digits)
--   part 1 only: [12..14] meta length (3 digits), then meta (base-75)
--   rest: chunk of the base-75 encoded note text
-- where meta = "<d|t|a>#<instance name>#<boss name>".
--
-- Encoding is base-75 (3 bytes -> 4 chars) over SuperStar's link alphabet:
-- no ':' or '|' (clashes with link markup) and no vowels (the chat service
-- censors words inside link payloads with '*').

MyLittleJournal = MyLittleJournal or {}
local TJ = MyLittleJournal

TJ.Share = {}
local Share = TJ.Share

local MODULE = "MyLittleJournal_Share"
local LINK_TYPE = "MLJshare"
local WIRE_VERSION = "3"
-- The chat service mangles messages whose total link string is too long
-- (observed breaking at ~270 chars while ~250 survives; Wizard's Wardrobe
-- ships ~260 total). Budget the WHOLE link — markup, payload and visible
-- text — against this ceiling.
local MAX_LINK_TOTAL = 240
local MAX_PARTS = 30
local BUFFER_TIMEOUT_SECS = 1800 -- links in scrollback stay importable a while

-- Group broadcast transport. The protocol ID must be globally unique across
-- all addons (coordinated at https://wiki.esoui.com/LibGroupBroadcast_IDs —
-- reserve it there before any public release). 471 is clear of everything
-- installed here (0, 10, 11, 20-25, 31, 32, 210).
local GROUP_PROTOCOL_ID = 471
local GROUP_PAYLOAD_VERSION = "1"
local MAX_GROUP_PAYLOAD = 8000
local groupProtocol = nil

local SV

local buffers = {} -- shareId -> { sender, meta, parts, total, received, startedAt }

local CATEGORY_TO_CHAR = { dungeon = "d", trial = "t", arena = "a" }
local CHAR_TO_CATEGORY = { d = "dungeon", t = "trial", a = "arena" }

-- =========================
-- Helpers
-- =========================
local function norm(name)
    return (zo_strlower(tostring(name or "")):gsub("[^%w]+", ""))
end

local function libAvailable()
    return LibChatMessage ~= nil and LibChatMessage.RegisterCustomChatLink ~= nil
end

local function sysMessage(text)
    if CHAT_ROUTER and CHAT_ROUTER.AddSystemMessage then
        CHAT_ROUTER:AddSystemMessage(text)
    else
        d(text)
    end
end

-- =========================
-- Base-75 codec
-- =========================
-- SuperStar's production-proven link alphabet: no vowels (the chat service
-- censors words inside link payloads with '*'), no ':' or '|' (link markup).
local B75_ALPHABET = "0123456789BCDFGHJKLMNPQRSTVWXYZbcdfghjklmnpqrstvwxyz(){}[]<>.!?+-/;~@&$^_=`"
local B75 = 75
local b75Char, b75Val = {}, {}
for i = 1, #B75_ALPHABET do
    local c = B75_ALPHABET:sub(i, i)
    b75Char[i - 1] = c
    b75Val[c] = i - 1
end

local function isPayloadChars(s)
    for i = 1, #s do
        if not b75Val[s:sub(i, i)] then return false end
    end
    return true
end

-- Three bytes become four digits (little-endian base 75); a trailing pair
-- becomes three digits and a lone trailing byte two. The encoded string can
-- be sliced anywhere for transport, as decoding only happens on the
-- reassembled whole.
local function b75Encode(s)
    local out = {}
    local len = #s
    local i = 1
    while i + 2 <= len do
        local n = s:byte(i) * 65536 + s:byte(i + 1) * 256 + s:byte(i + 2)
        out[#out + 1] = b75Char[n % B75]
            .. b75Char[math.floor(n / B75) % B75]
            .. b75Char[math.floor(n / (B75 * B75)) % B75]
            .. b75Char[math.floor(n / (B75 * B75 * B75))]
        i = i + 3
    end
    local rem = len - i + 1
    if rem == 2 then
        local n = s:byte(i) * 256 + s:byte(i + 1)
        out[#out + 1] = b75Char[n % B75]
            .. b75Char[math.floor(n / B75) % B75]
            .. b75Char[math.floor(n / (B75 * B75))]
    elseif rem == 1 then
        local b = s:byte(i)
        out[#out + 1] = b75Char[b % B75] .. b75Char[math.floor(b / B75)]
    end
    return table.concat(out)
end

-- Returns the decoded string, or nil if the input is not valid base-75.
local function b75Decode(s)
    if type(s) ~= "string" then return nil end
    if s == "" then return "" end
    local rem = #s % 4
    if rem == 1 then return nil end
    local out = {}
    local limit = #s - rem
    for i = 1, limit, 4 do
        local v1 = b75Val[s:sub(i, i)]
        local v2 = b75Val[s:sub(i + 1, i + 1)]
        local v3 = b75Val[s:sub(i + 2, i + 2)]
        local v4 = b75Val[s:sub(i + 3, i + 3)]
        if not (v1 and v2 and v3 and v4) then return nil end
        local n = v1 + v2 * B75 + v3 * B75 * B75 + v4 * B75 * B75 * B75
        if n > 16777215 then return nil end
        out[#out + 1] = string.char(math.floor(n / 65536), math.floor(n / 256) % 256, n % 256)
    end
    if rem == 3 then
        local v1 = b75Val[s:sub(limit + 1, limit + 1)]
        local v2 = b75Val[s:sub(limit + 2, limit + 2)]
        local v3 = b75Val[s:sub(limit + 3, limit + 3)]
        if not (v1 and v2 and v3) then return nil end
        local n = v1 + v2 * B75 + v3 * B75 * B75
        if n > 65535 then return nil end
        out[#out + 1] = string.char(math.floor(n / 256), n % 256)
    elseif rem == 2 then
        local v1 = b75Val[s:sub(limit + 1, limit + 1)]
        local v2 = b75Val[s:sub(limit + 2, limit + 2)]
        if not (v1 and v2) then return nil end
        local b = v1 + v2 * B75
        if b > 255 then return nil end
        out[#out + 1] = string.char(b)
    end
    return table.concat(out)
end

-- =========================
-- Wire format
-- =========================
local BASE_HEADER_LEN = 1 + 6 + 2 + 2

local function buildData(shareId, part, total, metaEnc, chunk)
    local head = WIRE_VERSION .. shareId .. string.format("%02d%02d", part, total)
    if part == 1 then
        head = head .. string.format("%03d", #metaEnc) .. metaEnc
    end
    return head .. chunk
end

-- Returns shareId, part, total, metaEnc (part 1 only), chunk — or nil if the
-- data string is not a valid payload of our current wire version.
local function parseData(data)
    if type(data) ~= "string" or #data < BASE_HEADER_LEN then return nil end
    if data:sub(1, 1) ~= WIRE_VERSION then return nil end
    local shareId = data:sub(2, 7)
    local part = tonumber(data:sub(8, 9))
    local total = tonumber(data:sub(10, 11))
    if shareId:find("%D") or not (part and total) then return nil end
    if part < 1 or part > total or total > MAX_PARTS then return nil end

    local metaEnc, chunk
    if part == 1 then
        local metaLen = tonumber(data:sub(12, 14))
        if not metaLen then return nil end
        metaEnc = data:sub(15, 14 + metaLen)
        if #metaEnc ~= metaLen then return nil end
        chunk = data:sub(15 + metaLen)
    else
        chunk = data:sub(BASE_HEADER_LEN + 1)
    end
    -- Payloads mangled in transit are rejected here, so the buffer stays
    -- visibly incomplete rather than producing a garbled import.
    if not isPayloadChars(chunk) or (metaEnc and not isPayloadChars(metaEnc)) then return nil end
    return shareId, part, total, metaEnc, chunk
end

-- =========================
-- Sending
-- =========================
-- inst = instance table, entryName = boss display name (or nil for
-- Overview), choice/whisperTarget as in Chat.SendNote. Returns ok, errMsg.
function Share.Send(inst, entryName, noteText, choice, whisperTarget)
    if not libAvailable() then
        return false, "Sharing needs the LibChatMessage addon (you and the receiver both)."
    end

    local raw = zo_strtrim(tostring(noteText or ""))
    if raw == "" then
        return false, "This entry has no notes to share yet."
    end
    raw = raw:gsub("\r\n", "\n"):gsub("\r", "\n")

    local catChar = CATEGORY_TO_CHAR[inst.category] or "d"
    local instName = tostring(inst.name):gsub("#", ""):sub(1, 40)
    local bossName = tostring(entryName or TJ.Data.OVERVIEW_NAME):gsub("#", ""):sub(1, 40)
    local metaEnc = b75Encode(catChar .. "#" .. instName .. "#" .. bossName)
    local textEnc = b75Encode(raw)
    local shareId = string.format("%06d", math.random(0, 999999))

    local displayBoss = bossName:gsub("|", ""):sub(1, 25)

    -- Budget the whole link string against MAX_LINK_TOTAL, sizing against
    -- the worst-case visible text ("Journal 30/30: ..."). Slice positions in
    -- the encoded text are arbitrary: the receiver reassembles all chunks
    -- before decoding.
    local markupOverhead = #("|H1:" .. LINK_TYPE .. ":") + #"|h[" + #"]|h"
    local worstDisplay = string.format("Journal %d/%d: %s", MAX_PARTS, MAX_PARTS, displayBoss)
    local dataBudget = MAX_LINK_TOTAL - markupOverhead - #worstDisplay

    local chunks = {}
    local remaining = textEnc
    local isFirst = true
    while remaining ~= "" or isFirst do
        local headerLen = BASE_HEADER_LEN
        if isFirst then
            headerLen = headerLen + 3 + #metaEnc
        end
        local room = dataBudget - headerLen
        if room < 0 then room = 0 end
        if room == 0 and not isFirst then
            return false, "Could not fit this note into share links."
        end
        chunks[#chunks + 1] = remaining:sub(1, room)
        remaining = remaining:sub(room + 1)
        isFirst = false
    end

    local total = #chunks
    if total > MAX_PARTS then
        return false, string.format("Note is too long to share (over %d chat messages).", MAX_PARTS)
    end

    local parts = {}
    for i, chunk in ipairs(chunks) do
        local display
        if total == 1 then
            display = "Journal: " .. displayBoss
        else
            display = string.format("Journal %d/%d: %s", i, total, displayBoss)
        end
        parts[i] = ZO_LinkHandler_CreateLink(display, nil, LINK_TYPE,
            buildData(shareId, i, total, metaEnc, chunk))
    end

    local ok, err = TJ.Chat.SendRawParts(parts, choice, whisperTarget)
    if ok then
        if total > 1 then
            d(string.format(
                "|c88CCFF[Journal]|r Share prepared as %d link messages. Press Enter to send each — the next is filled in automatically.",
                total))
        else
            d("|c88CCFF[Journal]|r Share link is in the chat box — press Enter to send it.")
        end
    end
    return ok, err
end

-- =========================
-- Importing
-- =========================
local function findOrCreateInstance(instName, catChar)
    local target = norm(instName)
    for _, inst in ipairs(TJ.Data.INSTANCES) do
        if norm(inst.name) == target then return inst.id end
    end
    if SV.customInstances then
        for _, inst in ipairs(SV.customInstances) do
            if norm(inst.name) == target then return inst.id end
        end
    end
    if not SV.customInstances then SV.customInstances = {} end
    local id = "ci_" .. GetTimeStamp() .. "_" .. math.random(1000, 9999)
    table.insert(SV.customInstances, {
        id = id, name = instName,
        category = CHAR_TO_CATEGORY[catChar] or "dungeon",
    })
    return id
end

local function findOrCreateBossKey(instanceId, bossName)
    if norm(bossName) == norm(TJ.Data.OVERVIEW_NAME) then
        return TJ.Data.OVERVIEW_KEY
    end
    for _, entry in ipairs(TJ.Data.GetBossEntries(SV, instanceId)) do
        if norm(entry.name) == norm(bossName) then return entry.key end
    end
    if not SV.customBosses then SV.customBosses = {} end
    if not SV.customBosses[instanceId] then SV.customBosses[instanceId] = {} end
    local key = "cb_" .. GetTimeStamp() .. "_" .. math.random(1000, 9999)
    table.insert(SV.customBosses[instanceId], { key = key, name = bossName })
    return key
end

-- Writes one shared entry into the journal: as-is when the local entry is
-- empty, appended below the user's own text otherwise.
local function importEntry(sender, instanceId, bossName, noteText)
    local bossKey = findOrCreateBossKey(instanceId, bossName)

    SV.notes = SV.notes or {}
    SV.notes[instanceId] = SV.notes[instanceId] or {}

    local existing = SV.notes[instanceId][bossKey]
    if existing and existing ~= "" then
        SV.notes[instanceId][bossKey] = existing
            .. "\n\n— From " .. sender .. ":\n" .. noteText
    else
        SV.notes[instanceId][bossKey] = noteText
    end
end

-- pending = { sender, cat, instName, entries = { { name, note }, ... } }
local function doImport(pending)
    local instanceId = findOrCreateInstance(pending.instName, pending.cat)
    for _, entry in ipairs(pending.entries) do
        importEntry(pending.sender, instanceId, entry.name, entry.note)
    end

    if #pending.entries == 1 then
        sysMessage(string.format(
            "|c88CCFF[Journal]|r Imported %s's notes for |cFFDD88%s — %s|r.",
            pending.sender, pending.instName, pending.entries[1].name))
    else
        sysMessage(string.format(
            "|c88CCFF[Journal]|r Imported %d entries from %s for |cFFDD88%s|r.",
            #pending.entries, pending.sender, pending.instName))
    end

    if TJ.UI then
        if TJ.UI.NotifyDataChanged then TJ.UI.NotifyDataChanged() end
        if TJ.UI.RefreshCurrentEntry then TJ.UI.RefreshCurrentEntry() end
    end
end

local function registerImportDialog()
    if ESO_Dialogs["MLJ_IMPORT_SHARED"] then return end
    ESO_Dialogs["MLJ_IMPORT_SHARED"] = {
        canQueue = true,
        gamepadInfo = { dialogType = GAMEPAD_DIALOGS.BASIC },
        title = { text = "Import shared notes?" },
        mainText = { text = "<<1>> shared notes for <<2>>. Import them into your journal? If you already have notes there, the shared text is added below your own." },
        buttons = {
            {
                text = "Import",
                callback = function(dialog)
                    local pending = dialog.data and dialog.data.pending
                    if pending then doImport(pending) end
                end,
            },
            { text = SI_DIALOG_CANCEL },
        },
    }
end

-- Shows the confirm dialog for a received share.
local function promptImportEntries(sender, catChar, instName, entries)
    registerImportDialog()
    local what
    if #entries == 1 then
        what = instName .. " — " .. entries[1].name
    else
        what = string.format("%s (%d entries)", instName, #entries)
    end
    ZO_Dialogs_ShowPlatformDialog("MLJ_IMPORT_SHARED",
        { pending = { sender = sender, cat = catChar, instName = instName, entries = entries } },
        { mainTextParams = { sender, what } })
end

-- Decodes a complete link-share buffer and shows the import dialog.
-- Returns false if the payload cannot be decoded.
local function promptImport(buf)
    local meta = b75Decode(buf.meta)
    local catChar, instName, bossName = nil, nil, nil
    if meta then
        catChar, instName, bossName = meta:match("^(%a)#([^#]+)#(.+)$")
    end
    local noteText = b75Decode(table.concat(buf.parts, "", 1, buf.total))
    if not (catChar and instName and bossName and noteText) or zo_strtrim(noteText) == "" then
        return false
    end

    promptImportEntries(buf.sender, catChar, instName, { { name = bossName, note = noteText } })
    return true
end

-- =========================
-- Receiving link payloads from chat
-- =========================
local function pruneBuffers()
    local now = GetTimeStamp()
    for shareId, buf in pairs(buffers) do
        if now - buf.startedAt > BUFFER_TIMEOUT_SECS then
            buffers[shareId] = nil
        end
    end
end

-- Returns the shareId when the piece was valid (even if already stored).
local function storePiece(sender, data)
    local shareId, part, total, metaEnc, chunk = parseData(data)
    if not shareId then return nil end

    pruneBuffers()

    local buf = buffers[shareId]
    if not buf or buf.total ~= total then
        buf = { sender = sender or "Someone", parts = {}, total = total, received = 0, startedAt = GetTimeStamp() }
        buffers[shareId] = buf
    end
    if sender and buf.sender == "Someone" then
        buf.sender = sender
    end

    if metaEnc and metaEnc ~= "" then buf.meta = metaEnc end
    if buf.parts[part] == nil then
        buf.parts[part] = chunk
        buf.received = buf.received + 1
    end
    return shareId
end

-- Raw incoming chat text carries the link with escaped pipes:
-- ||H1:MLJshare:<data>||h[display]||h
local function onChatMessage(_, channelType, fromName, text, _, fromDisplayName)
    if type(text) ~= "string" then return end
    local sender = (fromDisplayName and fromDisplayName ~= "") and fromDisplayName
        or zo_strformat("<<1>>", fromName)
    -- The payload alphabet never contains '|', so capture up to the closing
    -- markup with [^|]+.
    for data in text:gmatch("||H%d+:" .. LINK_TYPE .. ":([^|]+)||h") do
        storePiece(sender, data)
    end
    -- Some paths (e.g. own outgoing echo) may not escape the pipes.
    if not text:find("||H", 1, true) then
        for data in text:gmatch("|H%d+:" .. LINK_TYPE .. ":([^|]+)|h") do
            storePiece(sender, data)
        end
    end
end

local function onLinkClicked(rawLink, mouseButton, linkText, linkStyle, linkType)
    if linkType ~= LINK_TYPE then return end

    -- Read the payload straight from the raw link text instead of trusting
    -- how the click event split it into arguments.
    local data = type(rawLink) == "string"
        and rawLink:match("|H[^:]*:" .. LINK_TYPE .. ":([^|]+)|h")
    -- Feed the clicked link into the buffer too: a 1-message share is then
    -- importable even if the chat event was missed (e.g. after a reload).
    local shareId = data and storePiece(nil, data)

    if not shareId then
        sysMessage("|c88CCFF[Journal]|r Could not read this share — it may be from a different addon version.")
        return true
    end

    local buf = buffers[shareId]
    if buf.received < buf.total or not buf.meta then
        sysMessage(string.format(
            "|c88CCFF[Journal]|r Journal share incomplete — %d of %d parts received. Ask the sender to share it again.",
            buf.received, buf.total))
        return true
    end

    if not promptImport(buf) then
        sysMessage("|c88CCFF[Journal]|r Could not read this share — it may be from a different addon version.")
    end
    return true
end

-- =========================
-- Group broadcast transport
-- =========================
-- Payload: fields joined by "\1" —
--   version, category char, instance name, then (boss name, note) pairs.
-- LibGroupBroadcast streams one Send silently to all group members and
-- reassembles it on their end, so no chunking is needed here.
local function cleanField(s)
    return (tostring(s or ""):gsub("\1", ""))
end

-- Returns true when sending to the group is possible right now;
-- otherwise false and a reason.
function Share.CanUseGroup()
    if not groupProtocol then
        return false, "Group sharing needs the LibGroupBroadcast addon (you and the receiver both)."
    end
    if not IsUnitGrouped("player") then
        return false, "You are not in a group."
    end
    if groupProtocol.IsEnabled and not groupProtocol:IsEnabled() then
        return false, "Group sharing is disabled in the LibGroupBroadcast settings."
    end
    return true
end

-- entries = { { name = bossDisplayName (nil = Overview), note = text }, ... }
-- Sends everything silently to the group. Returns ok, errMsg.
function Share.SendToGroup(inst, entries)
    local can, why = Share.CanUseGroup()
    if not can then return false, why end

    local fields = { GROUP_PAYLOAD_VERSION, CATEGORY_TO_CHAR[inst.category] or "d", cleanField(inst.name) }
    local count = 0
    for _, entry in ipairs(entries) do
        local note = zo_strtrim(tostring(entry.note or ""))
        if note ~= "" then
            count = count + 1
            fields[#fields + 1] = cleanField(entry.name or TJ.Data.OVERVIEW_NAME)
            fields[#fields + 1] = cleanField(note:gsub("\r\n", "\n"):gsub("\r", "\n"))
        end
    end
    if count == 0 then
        return false, "There are no notes to share yet."
    end

    local payload = table.concat(fields, "\1")
    if #payload > MAX_GROUP_PAYLOAD then
        return false, "Too much text to send in one share — share single pages instead."
    end
    if not groupProtocol:Send({ payload = payload }) then
        return false, "Could not queue the group share — try again in a moment."
    end

    d(string.format(
        "|c88CCFF[Journal]|r Sending %d %s for %s to your group in the background — nothing shows in chat. Group members with the addon get an import prompt when it arrives%s.",
        count, count == 1 and "entry" or "entries", inst.name,
        #payload > 500 and " (large shares take a minute or two)" or ""))
    return true
end

-- Collects every non-empty entry of an instance and sends them all at once.
function Share.SendInstanceToGroup(inst)
    local entries = {}
    local notes = SV.notes and SV.notes[inst.id]
    if notes then
        for _, entry in ipairs(TJ.Data.GetBossEntries(SV, inst.id)) do
            local note = notes[entry.key]
            if note and zo_strtrim(note) ~= "" then
                entries[#entries + 1] = { name = entry.name, note = note }
            end
        end
    end
    if #entries == 0 then
        return false, "No notes written for this instance yet."
    end
    return Share.SendToGroup(inst, entries)
end

local function onGroupData(unitTag, values)
    local payload = values and values.payload
    if type(payload) ~= "string" or payload == "" then return end

    local sender = GetUnitDisplayName(unitTag)
    if sender == nil or sender == "" then sender = zo_strformat("<<1>>", GetUnitName(unitTag)) end
    if sender == GetDisplayName() then return end

    local fields = {}
    for piece in (payload .. "\1"):gmatch("(.-)\1") do
        fields[#fields + 1] = piece
    end
    if fields[1] ~= GROUP_PAYLOAD_VERSION then return end

    local catChar, instName = fields[2], fields[3]
    local entries = {}
    local i = 4
    while i + 1 <= #fields do
        if fields[i] ~= "" and zo_strtrim(fields[i + 1]) ~= "" then
            entries[#entries + 1] = { name = fields[i], note = fields[i + 1] }
        end
        i = i + 2
    end
    if not (catChar and catChar:match("^%a$") and instName and instName ~= "" and #entries > 0) then return end

    promptImportEntries(sender, catChar, instName, entries)
end

local function initGroupTransport()
    if not (LibGroupBroadcast and LibGroupBroadcast.RegisterHandler) then return end
    local ok = pcall(function()
        local handler = LibGroupBroadcast:RegisterHandler("MyLittleJournal")
        if not handler then error("handler registration failed") end
        handler:SetDisplayName("My Little Journal")
        handler:SetDescription("Shares journal notes with your group.")
        groupProtocol = handler:DeclareProtocol(GROUP_PROTOCOL_ID, "MyLittleJournalShare")
        groupProtocol:AddField(LibGroupBroadcast.CreateStringField("payload", { maxLength = MAX_GROUP_PAYLOAD }))
        groupProtocol:OnData(onGroupData)
        if not groupProtocol:Finalize({ replaceQueuedMessages = false }) then
            error("protocol finalize failed")
        end
    end)
    if not ok then groupProtocol = nil end
end

-- =========================
-- Init
-- =========================
function Share.Init(savedVars)
    SV = savedVars

    initGroupTransport()

    if libAvailable() then
        -- Keeps our link type clickable when it arrives from the chat
        -- service instead of being stripped to an "unknown link".
        LibChatMessage:RegisterCustomChatLink(LINK_TYPE, function(linkStyle, linkType, data, displayText)
            return ZO_LinkHandler_CreateLinkWithoutBrackets(displayText, nil, LINK_TYPE, data)
        end)
    end

    EVENT_MANAGER:RegisterForEvent(MODULE, EVENT_CHAT_MESSAGE_CHANNEL, onChatMessage)

    -- Only one of the two click events is registered: with both, a single
    -- click fires the handler twice (double dialogs/messages).
    if LINK_HANDLER then
        if LINK_HANDLER.LINK_MOUSE_UP_EVENT then
            LINK_HANDLER:RegisterCallback(LINK_HANDLER.LINK_MOUSE_UP_EVENT, onLinkClicked)
        elseif LINK_HANDLER.LINK_CLICKED_EVENT then
            LINK_HANDLER:RegisterCallback(LINK_HANDLER.LINK_CLICKED_EVENT, onLinkClicked)
        end
    end
end
