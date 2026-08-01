-- cChat_History.lua
-- Chat history storage and restoration functionality

cChat.History = {}

local MAX_HISTORY_LINES = 500
local historyData = nil

function cChat.History.Initialize(savedHistory)
    historyData = savedHistory or {}

    if not historyData.messages then
        historyData.messages = {}
    end

    -- Drop legacy field from older saved-var schema
    historyData.messageCount = nil

    return historyData
end

function cChat.History.StoreMessage(messageText, category, targetChannel, fromDisplayName, rawMessageText, narrationText)
    if not historyData then return end
    if not cChat.settings.enableHistory then return end
    if not messageText or messageText == "" then return end

    local messages = historyData.messages
    local maxLines = cChat.settings.maxHistoryLines or MAX_HISTORY_LINES
    local count = #messages

    local entry = {
        text = messageText,
        category = category,
        targetChannel = targetChannel,
        fromDisplayName = fromDisplayName,
        rawMessageText = rawMessageText,
        narrationText = narrationText,
    }

    -- If the user lowered maxHistoryLines since last store, drop the oldest
    -- entries so the new message fits. Without this, #messages stays above
    -- maxLines forever — the append branch only grows and the shift branch
    -- only rewrites the tail slot.
    if count >= maxLines then
        local drop = count - maxLines + 1
        for i = 1, maxLines - 1 do
            messages[i] = messages[i + drop]
        end
        for i = maxLines, count do
            messages[i] = nil
        end
        messages[maxLines] = entry
    else
        messages[count + 1] = entry
    end
end

local restoreRetryCount = 0
local MAX_RESTORE_RETRIES = 10

-- Pre-compute the flat list of (container, window) targets so per-message
-- playback is one ipairs, not a nested walk of the whole chat system.
local function CollectPlaybackTargets(chatSystem)
    local targets = {}
    if chatSystem and chatSystem.containers then
        for _, container in ipairs(chatSystem.containers) do
            for _, window in ipairs(container.windows) do
                targets[#targets + 1] = { container = container, window = window }
            end
        end
    end
    return targets
end

local function PlaybackEntry(entry, targets)
    if not (entry and entry.text and entry.category) then return end
    for _, t in ipairs(targets) do
        t.container:AddEventMessageToWindow(t.window, entry.text, entry.category)
    end
    -- Pass the full payload so the fullscreen gamepad chat menu can rebuild
    -- per-message interactivity (Whisper/Invite/Travel-to). Pre-fix entries
    -- only carry text+category and stay non-interactive — fine, they age out
    -- of the ring buffer.
    if CHAT_MENU_GAMEPAD then
        CHAT_MENU_GAMEPAD:AddMessage(entry.text, entry.category, entry.targetChannel, entry.fromDisplayName, entry.rawMessageText, entry.narrationText)
    end
end

function cChat.History.Restore()
    if not historyData then return end
    if not cChat.settings.enableHistory then return end
    if cChat.data.historyRestored then return end

    local chatSystem = CHAT_SYSTEM or GAMEPAD_CHAT_SYSTEM

    if not chatSystem then
        restoreRetryCount = restoreRetryCount + 1
        if restoreRetryCount >= MAX_RESTORE_RETRIES then
            cChat.data.historyRestored = true
            return
        end
        zo_callLater(function() cChat.History.Restore() end, 1000)
        return
    end

    local messages = historyData.messages
    local messageCount = #messages

    if messageCount == 0 then
        cChat.data.historyRestored = true
        return
    end

    local targets = CollectPlaybackTargets(chatSystem)

    if LibAsync then
        LibAsync:Create("cChatHistoryRestore")
            :For(ipairs(messages))
            :Do(function(_, entry)
                PlaybackEntry(entry, targets)
            end)
            :OnError(function(task)
                d("[cChat] history restore failed: " .. tostring(task.Error))
            end)
            :Finally(function()
                cChat.data.historyRestored = true
            end)
    else
        local BATCH_SIZE = 100
        local currentIndex = 1

        local function RestoreBatch()
            local batchEnd = math.min(currentIndex + BATCH_SIZE - 1, messageCount)
            for i = currentIndex, batchEnd do
                PlaybackEntry(messages[i], targets)
            end
            currentIndex = batchEnd + 1
            if currentIndex <= messageCount then
                zo_callLater(RestoreBatch, 10)
            else
                cChat.data.historyRestored = true
            end
        end

        RestoreBatch()
    end
end

-- Clear all stored history
function cChat.History.Clear()
    if historyData then
        historyData.messages = {}
    end
end

-- Get current history count
function cChat.History.GetCount()
    if not historyData or not historyData.messages then return 0 end
    return #historyData.messages
end
