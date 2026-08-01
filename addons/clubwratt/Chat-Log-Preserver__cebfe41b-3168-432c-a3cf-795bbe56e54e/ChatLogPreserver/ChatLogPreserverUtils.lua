-- ChatLogPreserverUtils.lua: Pure helpers

local ChatLogPreserverUtils = {}

---@param history ChatLogPreserverSavedMessage[]|nil
---@param maxLines number|nil
---@param newestFirst boolean|nil
---@return string
function ChatLogPreserverUtils.BuildHistoryText(history, maxLines, newestFirst)
    if not history or #history == 0 then
        return "No saved chat history."
    end

    local totalLines = #history
    local startIndex = 1
    if maxLines and maxLines > 0 and totalLines > maxLines then
        startIndex = totalLines - maxLines + 1
    end

    local lines = {}
    if newestFirst then
        for i = totalLines, startIndex, -1 do
            lines[#lines + 1] = history[i].message
        end
    else
        for i = startIndex, totalLines do
            lines[#lines + 1] = history[i].message
        end
    end

    return table.concat(lines, "\n")
end

---@param history ChatLogPreserverSavedMessage[]|nil
---@param maxEntries number
function ChatLogPreserverUtils.TrimHistory(history, maxEntries)
    if not history or maxEntries == nil or maxEntries <= 0 then
        return
    end

    local extra = #history - maxEntries
    if extra <= 0 then
        return
    end

    for _ = 1, extra do
        table.remove(history, 1)
    end
end

ChatLogPreserver.Utils = ChatLogPreserverUtils
