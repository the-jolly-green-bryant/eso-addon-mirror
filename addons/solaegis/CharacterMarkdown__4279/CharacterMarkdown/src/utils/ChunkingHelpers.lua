-- CharacterMarkdown - Chunking Helper Functions
-- Line-type detection and backtrack helpers for Chunking.lua

local CM = CharacterMarkdown

-- =====================================================
-- LINE-TYPE DETECTION
-- =====================================================

---Check if a line is part of a markdown table
local function IsTableLine(line)
    if not line or line == "" then
        return false
    end
    return line:match("^%s*|") ~= nil
end

---Check if a line is a markdown header
local function IsHeaderLine(line)
    if not line or line == "" then
        return false
    end
    return line:match("^#+%s") ~= nil
end

---Check if a line is part of a markdown list
local function IsListLine(line)
    if not line or line == "" then
        return false
    end

    -- Strip all leading characters that aren't list markers or regular printable chars
    -- This handles zero-width spaces and other invisible Unicode characters
    local cleaned = line
    cleaned = cleaned:gsub("^\226\128\139+", "") -- Zero-width space
    cleaned = cleaned:gsub("^\226\128\140+", "") -- Zero-width non-joiner
    cleaned = cleaned:gsub("^\226\128\141+", "") -- Zero-width joiner
    cleaned = cleaned:gsub("^%s+", "")

    -- Check if cleaned line starts with a list marker
    if cleaned:match("^[-*+]%s") or cleaned:match("^%d+[.)]%s") then
        return true
    end

    -- Fallback: check original pattern
    return line:match("^%s*[-*+]%s") ~= nil or line:match("^%s*%d+[.)]%s") ~= nil
end

-- =====================================================
-- HEADER+TABLE DETECTION
-- =====================================================

---Check if a position is at a newline between a header and a table.
---Returns true if: current line is a header AND next non-empty line is a table.
local function IsHeaderBeforeTable(markdown, pos, markdownLength)
    if pos >= markdownLength or string.sub(markdown, pos, pos) ~= "\n" then
        return false
    end

    -- Find the line ending at pos (the header line)
    local lineStart = pos
    for i = pos - 1, math.max(1, pos - 1000), -1 do
        if i == 1 or string.sub(markdown, i - 1, i - 1) == "\n" then
            lineStart = i
            break
        end
    end

    local headerLine = string.sub(markdown, lineStart, pos - 1)
    if not IsHeaderLine(headerLine) then
        return false
    end

    -- Check if the next non-empty line is a table
    local nextLineStart = pos + 1
    while nextLineStart <= markdownLength and string.sub(markdown, nextLineStart, nextLineStart) == "\n" do
        nextLineStart = nextLineStart + 1
    end

    if nextLineStart > markdownLength then
        return false
    end

    local nextLineEnd = nextLineStart
    for i = nextLineStart, math.min(markdownLength, nextLineStart + 500) do
        if string.sub(markdown, i, i) == "\n" then
            nextLineEnd = i
            break
        end
    end

    local nextLine = string.sub(markdown, nextLineStart, nextLineEnd - 1)
    return IsTableLine(nextLine)
end

---Backtrack before a header when the next line is a table to keep header+table together.
---Returns newChunkEnd, prependNewline if backtracking is valid; nil otherwise.
local function BacktrackBeforeHeaderTablePair(markdown, pos, chunkEnd, markdownLength, copyLimit, totalOverhead)
    if chunkEnd >= markdownLength then
        return nil
    end
    if string.sub(markdown, chunkEnd, chunkEnd) ~= "\n" then
        return nil
    end
    if not IsHeaderBeforeTable(markdown, chunkEnd, markdownLength) then
        return nil
    end
    local backtrackHeaderStart = chunkEnd
    for i = chunkEnd - 1, math.max(pos, chunkEnd - 1000), -1 do
        if i == pos or string.sub(markdown, i - 1, i - 1) == "\n" then
            backtrackHeaderStart = (i == pos) and pos or i
            break
        end
    end
    if backtrackHeaderStart <= pos then
        return nil
    end
    local newChunkEnd = backtrackHeaderStart - 1
    local proposedDataChars = newChunkEnd - pos + 1
    if proposedDataChars + totalOverhead <= copyLimit and proposedDataChars >= 100 then
        return newChunkEnd, true
    end
    return nil
end

-- =====================================================
-- EXPORT
-- =====================================================

CM.utils = CM.utils or {}
CM.utils.ChunkingHelpers = {
    IsTableLine = IsTableLine,
    IsHeaderLine = IsHeaderLine,
    IsListLine = IsListLine,
    IsHeaderBeforeTable = IsHeaderBeforeTable,
    BacktrackBeforeHeaderTablePair = BacktrackBeforeHeaderTablePair,
}

return CM.utils.ChunkingHelpers
