-- My Little Journal — chat output.
--
-- ESO does not let addons send chat messages directly (anti-bot), so we
-- pre-fill the chat input with CHAT_SYSTEM:StartTextEntry() and the user
-- presses Enter. For multi-part notes we detect each send and pre-fill the
-- next part automatically, so sharing is just Enter, Enter, Enter.

MyLittleJournal = MyLittleJournal or {}
local TJ = MyLittleJournal

TJ.Chat = {}
local Chat = TJ.Chat

local MAX_CHAT = (type(MAX_TEXT_CHAT_INPUT_CHARACTERS) == "number" and MAX_TEXT_CHAT_INPUT_CHARACTERS > 50)
    and MAX_TEXT_CHAT_INPUT_CHARACTERS or 350
local MAX_PARTS = 30
local QUEUE_TIMEOUT_SECS = 300

local SV
local hooksInstalled = false
local queue = nil -- { parts, index, channel, target, startedAt }

local hintWin, hintLabel, hintCancel

-- =========================
-- Text normalisation & splitting
-- =========================

-- Chat input is single-line and '|' starts ESO markup, so both must go.
local function normalizeForChat(text)
    local s = tostring(text or "")
    s = s:gsub("|", "/")
    s = s:gsub("\r\n", "\n"):gsub("\r", "\n")
    s = s:gsub("%s*\n+%s*", " • ")
    s = s:gsub("%s%s+", " ")
    return zo_strtrim(s)
end

-- Splits normalized text into prefixed chunks that each fit in one chat
-- message. prefixFn(partIndex, totalParts) returns that part's prefix.
-- Total part count changes prefix length, so iterate until it stabilises.
local function splitIntoParts(text, prefixFn)
    local total = 1
    for _ = 1, 5 do
        local parts = {}
        local remaining = text
        local index = 1
        while remaining ~= "" and index <= MAX_PARTS do
            local prefix = prefixFn(index, total)
            local room = MAX_CHAT - #prefix
            if room < 20 then room = 20 end

            if #remaining <= room then
                parts[#parts + 1] = prefix .. remaining
                remaining = ""
            else
                -- Break on the last space inside the window when possible.
                local breakPos
                for pos = room, math.max(1, room - 80), -1 do
                    if remaining:sub(pos, pos) == " " then
                        breakPos = pos
                        break
                    end
                end
                breakPos = breakPos or room
                parts[#parts + 1] = prefix .. zo_strtrim(remaining:sub(1, breakPos))
                remaining = zo_strtrim(remaining:sub(breakPos + 1))
            end
            index = index + 1
        end
        if #parts == total then
            return parts
        end
        total = #parts
    end
    return nil
end

-- Public: how many chat messages would this note take? (0 = empty)
function Chat.CountParts(prefixFn, noteText)
    local text = normalizeForChat(noteText)
    if text == "" then return 0 end
    local parts = splitIntoParts(text, prefixFn)
    return parts and #parts or MAX_PARTS
end

-- =========================
-- Channel choices
-- =========================

-- Rebuilt on demand so guild names stay current.
-- Each entry: { key, label, channel, isWhisper }
function Chat.GetChannelChoices()
    local choices = {
        { key = "party",   label = "Group",   channel = CHAT_CHANNEL_PARTY },
        { key = "say",     label = "Say",     channel = CHAT_CHANNEL_SAY },
        { key = "zone",    label = "Zone",    channel = CHAT_CHANNEL_ZONE },
        { key = "whisper", label = "Whisper", channel = CHAT_CHANNEL_WHISPER, isWhisper = true },
    }
    local guildChannels = {
        CHAT_CHANNEL_GUILD_1, CHAT_CHANNEL_GUILD_2, CHAT_CHANNEL_GUILD_3,
        CHAT_CHANNEL_GUILD_4, CHAT_CHANNEL_GUILD_5,
    }
    for i = 1, GetNumGuilds() do
        local guildId = GetGuildId(i)
        local name = GetGuildName(guildId)
        if name and name ~= "" and guildChannels[i] then
            choices[#choices + 1] = {
                key = "guild" .. i,
                label = "Guild: " .. name,
                channel = guildChannels[i],
            }
        end
    end
    return choices
end

function Chat.FindChannelChoice(key)
    local choices = Chat.GetChannelChoices()
    for _, choice in ipairs(choices) do
        if choice.key == key then return choice end
    end
    return choices[1]
end

-- =========================
-- Hint window (shows queue progress next to chat)
-- =========================
local function ensureHintWindow()
    if hintWin then return end

    hintWin = WINDOW_MANAGER:CreateControl("MyLittleJournalChatHint", GuiRoot, CT_TOPLEVELCONTROL)
    hintWin:SetDimensions(420, 30)
    hintWin:SetDrawLayer(DL_OVERLAY)
    hintWin:SetDrawTier(DT_HIGH)
    hintWin:SetHidden(true)
    if ZO_ChatWindow then
        hintWin:SetAnchor(BOTTOMLEFT, ZO_ChatWindow, TOPLEFT, 0, -2)
    else
        hintWin:SetAnchor(BOTTOMLEFT, GuiRoot, BOTTOMLEFT, 30, -320)
    end

    local bg = WINDOW_MANAGER:CreateControl(nil, hintWin, CT_BACKDROP)
    bg:SetAnchorFill()
    bg:SetCenterColor(0.05, 0.04, 0.03, 0.9)
    bg:SetEdgeColor(0.55, 0.45, 0.25, 1)
    bg:SetEdgeTexture("", 128, 2)

    hintLabel = WINDOW_MANAGER:CreateControl(nil, hintWin, CT_LABEL)
    hintLabel:SetFont("ZoFontGameBold")
    hintLabel:SetColor(0.95, 0.88, 0.65, 1)
    hintLabel:SetAnchor(LEFT, hintWin, LEFT, 10, 0)
    hintLabel:SetAnchor(RIGHT, hintWin, RIGHT, -30, 0)
    hintLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    hintLabel:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
    hintLabel:SetMouseEnabled(true)
    hintLabel:SetHandler("OnMouseUp", function(_, button, upInside)
        if upInside and button == MOUSE_BUTTON_INDEX_LEFT then
            Chat.RefillCurrentPart()
        end
    end)

    hintCancel = WINDOW_MANAGER:CreateControl(nil, hintWin, CT_BUTTON)
    hintCancel:SetDimensions(18, 18)
    hintCancel:SetAnchor(RIGHT, hintWin, RIGHT, -6, 0)
    hintCancel:SetNormalTexture("/esoui/art/buttons/decline_up.dds")
    hintCancel:SetPressedTexture("/esoui/art/buttons/decline_down.dds")
    hintCancel:SetMouseOverTexture("/esoui/art/buttons/decline_over.dds")
    hintCancel:SetHandler("OnClicked", function()
        Chat.CancelQueue()
    end)
end

local function updateHint()
    if not queue then
        if hintWin then hintWin:SetHidden(true) end
        return
    end
    ensureHintWindow()
    hintLabel:SetText(string.format(
        "Journal: part %d/%d in chat box — press Enter to send (click here to refill)",
        queue.index, #queue.parts))
    hintWin:SetHidden(false)
end

-- =========================
-- Queue handling
-- =========================
local function prefillCurrentPart()
    if not queue then return end
    local part = queue.parts[queue.index]
    if not part then return end
    if CHAT_SYSTEM and CHAT_SYSTEM.StartTextEntry then
        CHAT_SYSTEM:StartTextEntry(part, queue.channel, queue.target)
    elseif StartChatInput then
        StartChatInput(part, queue.channel, queue.target)
    end
    updateHint()
end

function Chat.RefillCurrentPart()
    prefillCurrentPart()
end

function Chat.CancelQueue(silent)
    if queue and not silent then
        d("|c88CCFF[Journal]|r Send cancelled.")
    end
    queue = nil
    updateHint()
end

function Chat.IsQueueActive()
    return queue ~= nil
end

local function queueExpired()
    return queue and (GetTimeStamp() - queue.startedAt) > QUEUE_TIMEOUT_SECS
end

-- Called (pre-hook) when the player submits the chat entry. If they sent
-- our current part, advance the queue and pre-fill the next part.
local function onChatSubmit()
    if not queue then return end
    if queueExpired() then
        Chat.CancelQueue(true)
        return
    end

    local ok, sentText = pcall(function()
        return CHAT_SYSTEM.textEntry:GetText()
    end)
    if not ok or type(sentText) ~= "string" then return end

    if zo_strtrim(sentText) ~= zo_strtrim(queue.parts[queue.index]) then
        return -- user sent something else; keep the queue, they can click the hint
    end

    queue.index = queue.index + 1
    if queue.index > #queue.parts then
        local total = #queue.parts
        queue = nil
        updateHint()
        if total > 1 then
            d(string.format("|c88CCFF[Journal]|r All %d parts sent.", total))
        end
    else
        -- Let the submit finish and the chat entry close before refilling.
        zo_callLater(prefillCurrentPart, 300)
    end
end

local function installHooks()
    if hooksInstalled then return end
    hooksInstalled = true
    if CHAT_SYSTEM and type(CHAT_SYSTEM.SubmitTextEntry) == "function" then
        ZO_PreHook(CHAT_SYSTEM, "SubmitTextEntry", onChatSubmit)
    end
end

-- =========================
-- Public send entry points
-- =========================
-- Validates the channel/whisper target and starts the chained pre-fill
-- queue for an array of ready-made messages. Returns ok, errMsg.
local function startQueue(parts, channelChoice, whisperTarget)
    if not channelChoice then
        return false, "Pick a chat channel first."
    end

    local target = nil
    if channelChoice.isWhisper then
        target = zo_strtrim(tostring(whisperTarget or ""))
        if target == "" then
            return false, "Enter an @name to whisper."
        end
        if target:sub(1, 1) ~= "@" then
            target = "@" .. target
        end
    end

    queue = {
        parts = parts,
        index = 1,
        channel = channelChoice.channel,
        target = target,
        startedAt = GetTimeStamp(),
    }
    prefillCurrentPart()
    return true
end

-- prefixFn(i, n) -> string; channelChoice from GetChannelChoices();
-- whisperTarget only used for whisper. Returns ok, errMsg.
function Chat.SendNote(prefixFn, noteText, channelChoice, whisperTarget)
    local text = normalizeForChat(noteText)
    if text == "" then
        return false, "This entry has no notes to send yet."
    end

    local parts = splitIntoParts(text, prefixFn)
    if not parts or #parts < 1 then
        return false, "Could not split this note for chat."
    end
    if #parts >= MAX_PARTS then
        return false, string.format("Note is too long to send (over %d chat messages).", MAX_PARTS)
    end

    local ok, err = startQueue(parts, channelChoice, whisperTarget)
    if not ok then return false, err end

    if #parts > 1 then
        d(string.format(
            "|c88CCFF[Journal]|r Note split into %d parts. Press Enter to send each part — the next one is filled in automatically.",
            #parts))
    end
    return true
end

-- Queues ready-made messages (used by the share module for link messages).
-- Each entry must already fit within one chat message. Returns ok, errMsg.
function Chat.SendRawParts(parts, channelChoice, whisperTarget)
    if type(parts) ~= "table" or #parts < 1 then
        return false, "Nothing to send."
    end
    return startQueue(parts, channelChoice, whisperTarget)
end

function Chat.Init(savedVars)
    SV = savedVars
    installHooks()
end
