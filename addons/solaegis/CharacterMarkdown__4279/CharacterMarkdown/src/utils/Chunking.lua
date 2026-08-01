-- CharacterMarkdown - Chunking Utilities
-- Handles splitting large markdown into chunks for ESO EditBox limits

local CM = CharacterMarkdown

-- Import constants
local CHUNKING = CM.constants.CHUNKING

-- Import helpers (loaded before this file in manifest)
local ChunkingHelpers = CM.utils and CM.utils.ChunkingHelpers
local IsTableLine = ChunkingHelpers and ChunkingHelpers.IsTableLine or function()
    return false
end
-- local IsHeaderLine = ChunkingHelpers and ChunkingHelpers.IsHeaderLine or function() return false end
local IsListLine = ChunkingHelpers and ChunkingHelpers.IsListLine or function()
    return false
end
-- local IsHeaderBeforeTable = ChunkingHelpers and ChunkingHelpers.IsHeaderBeforeTable or function() return false end
local BacktrackBeforeHeaderTablePair = ChunkingHelpers and ChunkingHelpers.BacktrackBeforeHeaderTablePair
    or function()
        return nil
    end

-- Helper function to check if a position is inside an HTML block (like <div>)
local function IsInsideHtmlBlock(markdown, pos)
    local markdownLen = string.len(markdown)

    -- Search backwards for opening <div> tags
    local divStart = nil
    local searchStart = math.max(1, pos - (CHUNKING.BACKTRACK_WINDOW or 5000))

    for i = pos, searchStart, -1 do
        local substr = string.sub(markdown, i, math.min(markdownLen, i + 4))
        if substr:match("^<div") then
            divStart = i
            break
        end
    end

    -- If we found a <div>, check if we're inside it by finding the closing </div>
    if divStart then
        local divEnd = nil
        local divDepth = 0 -- Track nested divs

        -- Start from divStart and track nesting
        for i = divStart, math.min(markdownLen, divStart + 20000) do
            local openSubstr = string.sub(markdown, i, math.min(markdownLen, i + 4))
            local closeSubstr = string.sub(markdown, i, math.min(markdownLen, i + 5))

            if openSubstr:match("^<div") then
                divDepth = divDepth + 1
            elseif closeSubstr:match("^</div>") then
                divDepth = divDepth - 1
                if divDepth == 0 then
                    divEnd = i + 6 -- Position after </div> (6 chars)
                    break
                end
            end
        end

        if divEnd and pos >= divStart and pos <= divEnd then
            return true, divStart, divEnd
        end
    end

    return false, nil, nil
end

-- Helper function to check if a position is in the middle of an HTML tag
-- Returns true if pos is between < and > of an HTML tag
local function IsInsideHtmlTag(markdown, pos)
    local markdownLen = string.len(markdown)

    -- Search backwards for the opening <
    local tagStart = nil
    local searchStart = math.max(1, pos - 100) -- HTML tags are usually short

    for i = pos, searchStart, -1 do
        if string.sub(markdown, i, i) == "<" then
            tagStart = i
            break
        elseif string.sub(markdown, i, i) == ">" then
            -- Found a closing > before an opening <, so we're not in a tag
            return false, nil, nil
        end
    end

    -- If we found a <, check if there's a matching > after it
    if tagStart then
        for i = tagStart + 1, math.min(markdownLen, tagStart + 200) do
            if string.sub(markdown, i, i) == ">" then
                -- Found the closing >, check if pos is between < and >
                if pos >= tagStart and pos <= i then
                    return true, tagStart, i
                else
                    return false, nil, nil
                end
            elseif string.sub(markdown, i, i) == "<" then
                -- Found another < before closing >, this is malformed or nested
                -- But we're still technically "inside" a tag
                return true, tagStart, nil
            end
        end
        -- No closing > found, but we have an opening <, so we're in an incomplete tag
        return true, tagStart, nil
    end

    return false, nil, nil
end

-- Helper: Check if content from nextPos would start the next chunk with </div> or </div><div>
-- Splitting there would break multi-column grid layout (orphans closing tag, breaks HTML structure)
local function WouldNextChunkStartWithGridColumnBoundary(markdown, chunkEnd, markdownLength)
    if chunkEnd >= markdownLength then
        return false
    end
    local nextPos = chunkEnd + 1
    -- Skip leading newlines/whitespace
    while nextPos <= markdownLength and string.sub(markdown, nextPos, nextPos):match("[%s]") do
        nextPos = nextPos + 1
    end
    if nextPos > markdownLength then
        return false
    end
    local substr = string.sub(markdown, nextPos, math.min(markdownLength, nextPos + 10))
    return substr:match("^</div>") ~= nil
end

-- Helper: Search backwards from pos to find the grid container opening <div style="display: grid...
-- Returns position of newline before the grid (safe chunk end) or nil
local function FindGridContainerStartBackward(markdown, pos)
    local searchStart = math.max(1, pos - 15000)
    for i = pos, searchStart, -1 do
        local substr = string.sub(markdown, i, math.min(pos, i + 60))
        if substr:match('<div style="display: grid') or substr:match("<div style='display: grid") then
            -- Found grid container - return the newline that ends the line before it (chunk ends there)
            for j = i - 1, math.max(1, i - 500), -1 do
                if string.sub(markdown, j, j) == "\n" then
                    return j
                end
            end
            return nil -- No newline found, can't safely split
        end
    end
    return nil
end

-- Helper function to check if a position is inside a Mermaid code block or subgraph
local function IsInsideMermaidBlock(markdown, pos)
    local markdownLen = string.len(markdown)

    -- First, check if we're inside a ```mermaid code block
    local mermaidStart = nil

    -- Search backwards for code block markers
    for i = pos, 1, -1 do
        local substr = string.sub(markdown, math.max(1, i - 10), i)
        if substr:match("```mermaid") then
            mermaidStart = i - 9 -- Position of start of ```mermaid
            break
        elseif substr:match("```") and not substr:match("```mermaid") then
            -- Found a code block marker, but need to check if it's closing or opening
            -- Look a bit further back to see if there's a newline before it
            local checkPos = math.max(1, i - 11)
            if string.sub(markdown, checkPos, checkPos) == "\n" or checkPos == 1 then
                -- Position of start of ``` (ignored unused variable)
                break
            end
        end
    end

    -- If we found a mermaid code block, check if we're inside it
    if mermaidStart then
        -- Look forwards from mermaidStart to find the closing ```
        local blockEnd = nil
        for i = mermaidStart + 10, markdownLen do
            local substr = string.sub(markdown, i, math.min(markdownLen, i + 2))
            if substr == "```" then
                -- Check if it's at start of line or after newline
                if i == 1 or string.sub(markdown, i - 1, i - 1) == "\n" then
                    blockEnd = i + 2 -- Position of end of closing ```
                    break
                end
            end
        end

        if blockEnd and pos >= mermaidStart and pos <= blockEnd then
            -- We're inside a mermaid code block - now check for subgraphs
            -- Search backwards from pos to find if we're inside a subgraph
            local subgraphStart = nil
            local subgraphEnd = nil

            -- Find the start of the current subgraph (if any) by searching backwards line by line
            -- Look for "subgraph" keyword (may have leading whitespace)
            local lineStart = pos
            -- Find the start of the current line
            for k = pos, math.max(1, pos - 1000), -1 do
                if k == 1 or string.sub(markdown, k - 1, k - 1) == "\n" then
                    lineStart = k
                    break
                end
            end

            -- Search backwards line by line from current position
            local searchPos = lineStart - 1
            while searchPos >= mermaidStart + 10 do
                -- Find the start of this line
                local currentLineStart = searchPos + 1
                for k = searchPos, math.max(1, searchPos - 1000), -1 do
                    if k == 1 or string.sub(markdown, k - 1, k - 1) == "\n" then
                        currentLineStart = k
                        break
                    end
                end

                -- Find the end of this line
                local currentLineEnd = searchPos
                for k = searchPos + 1, math.min(markdownLen, searchPos + 500) do
                    if string.sub(markdown, k, k) == "\n" then
                        currentLineEnd = k
                        break
                    end
                end

                local line = string.sub(markdown, currentLineStart, currentLineEnd - 1)

                -- Check if this line contains "subgraph"
                if line:match("subgraph%s") then
                    subgraphStart = currentLineStart

                    -- Now find the matching "end" for this subgraph
                    -- Count subgraph depth to handle nested subgraphs
                    -- Search more aggressively - up to 50000 chars or end of mermaid block, whichever comes first
                    local depth = 1
                    local searchStart = currentLineEnd + 1
                    local extendedSearchEnd = math.min(markdownLen, math.max(blockEnd, subgraphStart + 50000))

                    -- Search forwards line by line
                    local forwardPos = searchStart
                    while forwardPos < extendedSearchEnd do
                        -- Find the start of this line (for accurate line detection)
                        local forwardLineStart = forwardPos
                        for k = forwardPos, math.max(1, forwardPos - 1000), -1 do
                            if k == 1 or string.sub(markdown, k - 1, k - 1) == "\n" then
                                forwardLineStart = k
                                break
                            end
                        end

                        -- Find the end of this line
                        local forwardLineEnd = forwardPos
                        for k = forwardPos, math.min(markdownLen, forwardPos + 500) do
                            if string.sub(markdown, k, k) == "\n" then
                                forwardLineEnd = k
                                break
                            end
                        end

                        local forwardLine = string.sub(markdown, forwardLineStart, forwardLineEnd - 1)

                        -- Check if line contains "subgraph" or "end" (with optional leading whitespace)
                        if forwardLine:match("subgraph%s") then
                            depth = depth + 1
                        elseif
                            forwardLine:match("%send%s")
                            or forwardLine:match("%send$")
                            or forwardLine:match("%send\n")
                        then
                            depth = depth - 1
                            if depth == 0 then
                                -- Found matching end
                                subgraphEnd = forwardLineEnd
                                break
                            end
                        end

                        -- Move to next line (skip to end of current line + 1)
                        if forwardLineEnd > forwardPos then
                            forwardPos = forwardLineEnd + 1
                        else
                            -- No newline found, move forward by 1 to avoid infinite loop
                            forwardPos = forwardPos + 1
                        end
                    end
                    break
                end

                -- Move to previous line
                searchPos = currentLineStart - 1
            end

            -- If we're inside a subgraph, return subgraph boundaries
            -- Even if we can't find the end yet, if we found a start and pos is after it, we're in a subgraph
            if subgraphStart and pos >= subgraphStart then
                if subgraphEnd then
                    -- We found both start and end - return subgraph boundaries
                    if pos <= subgraphEnd then
                        return true, subgraphStart, subgraphEnd
                    end
                else
                    -- We're in a subgraph but haven't found the end yet
                    -- Search more aggressively for the end (might be beyond blockEnd if subgraph is large)
                    -- Search up to 50000 chars forward to find the matching end
                    local extendedSearchEnd = math.min(markdownLen, subgraphStart + 50000)
                    local depth = 1
                    local searchStart = subgraphStart + 9 -- After "subgraph "

                    local forwardPos = searchStart
                    while forwardPos < extendedSearchEnd do
                        local forwardLineStart = forwardPos
                        for k = forwardPos, math.max(1, forwardPos - 1000), -1 do
                            if k == 1 or string.sub(markdown, k - 1, k - 1) == "\n" then
                                forwardLineStart = k
                                break
                            end
                        end

                        local forwardLineEnd = forwardPos
                        for k = forwardPos, math.min(markdownLen, forwardPos + 500) do
                            if string.sub(markdown, k, k) == "\n" then
                                forwardLineEnd = k
                                break
                            end
                        end

                        local forwardLine = string.sub(markdown, forwardLineStart, forwardLineEnd - 1)

                        if forwardLine:match("subgraph%s") then
                            depth = depth + 1
                        elseif
                            forwardLine:match("%send%s")
                            or forwardLine:match("%send$")
                            or forwardLine:match("%send\n")
                        then
                            depth = depth - 1
                            if depth == 0 then
                                subgraphEnd = forwardLineEnd
                                break
                            end
                        end

                        if forwardLineEnd > forwardPos then
                            forwardPos = forwardLineEnd + 1
                        else
                            forwardPos = forwardPos + 1
                        end
                    end

                    if subgraphEnd then
                        -- Found the end - return subgraph boundaries
                        return true, subgraphStart, subgraphEnd
                    else
                        -- Still can't find end - return subgraph start and code block end
                        -- This tells the chunking logic to extend to the end of the code block
                        return true, subgraphStart, blockEnd
                    end
                end
            end

            -- Not in a subgraph, return code block boundaries
            return true, mermaidStart, blockEnd
        end
    end

    -- Not inside a mermaid block
    return false, nil, nil
end

-- Helper function to find the end of a list starting at a given position
local function FindListEnd(markdown, startPos, maxSearch)
    local markdownLen = string.len(markdown)
    local searchEnd = math.min(startPos + maxSearch, markdownLen)

    local lineStart = startPos
    for i = startPos, math.max(1, startPos - 1000), -1 do
        if i == 1 or string.sub(markdown, i - 1, i - 1) == "\n" then
            lineStart = i
            break
        end
    end

    local line = string.sub(markdown, lineStart, startPos - 1)
    if not IsListLine(line) then
        return nil
    end

    local lastListLineEnd = startPos
    local currentPos = startPos + 1

    while currentPos <= searchEnd do
        local nextNewline = nil
        for i = currentPos, searchEnd do
            if string.sub(markdown, i, i) == "\n" then
                nextNewline = i
                break
            end
        end

        if not nextNewline then
            break
        end

        local lineContent = string.sub(markdown, currentPos, nextNewline - 1)

        if IsListLine(lineContent) then
            lastListLineEnd = nextNewline
            currentPos = nextNewline + 1
        elseif lineContent:match("^%s*$") then
            return lastListLineEnd
        else
            return lastListLineEnd
        end
    end

    if lastListLineEnd <= markdownLen and string.sub(markdown, lastListLineEnd, lastListLineEnd) == "\n" then
        return lastListLineEnd
    else
        return startPos
    end
end

-- Helper function to check if a position is inside a markdown link [text](url)
-- Returns the position of the closing parenthesis if inside a link, nil otherwise
-- Also checks if we're at the end of a line that contains an incomplete link
local function IsInsideMarkdownLink(markdown, pos)
    local markdownLen = string.len(markdown)
    if pos < 1 or pos > markdownLen then
        return nil
    end

    -- If pos is at a newline, check the line ending at that newline for incomplete links
    if string.sub(markdown, pos, pos) == "\n" then
        -- Find the start of the line
        local lineStart = pos
        for i = pos - 1, math.max(1, pos - 500), -1 do
            if string.sub(markdown, i, i) == "\n" then
                lineStart = i + 1
                break
            end
        end
        if lineStart == pos then
            lineStart = 1
        end

        -- Check if the line contains an incomplete markdown link
        -- local lineContent = string.sub(markdown, lineStart, pos - 1)
        -- Look for pattern: [text](url where url is incomplete (no closing paren)
        local openParenPos = nil
        local openBracketPos = nil

        -- Find the last opening parenthesis in the line
        for i = pos - 1, lineStart, -1 do
            if string.sub(markdown, i, i) == "(" then
                openParenPos = i
                break
            end
        end

        if openParenPos then
            -- Check if there's a markdown link pattern [text](url
            -- Look backwards for a closing bracket ] that comes after an opening bracket [
            local bracketDepth = 0
            for i = openParenPos - 1, lineStart, -1 do
                local char = string.sub(markdown, i, i)
                if char == "]" then
                    bracketDepth = bracketDepth + 1
                elseif char == "[" then
                    if bracketDepth == 0 then
                        -- Found opening bracket, this is a markdown link pattern
                        openBracketPos = i
                        break
                    else
                        bracketDepth = bracketDepth - 1
                    end
                end
            end

            if openBracketPos then
                -- Found a markdown link pattern [text](url
                -- Check if the closing paren is after pos (incomplete link)
                for j = pos + 1, math.min(markdownLen, openParenPos + 2000) do
                    if string.sub(markdown, j, j) == ")" then
                        return j -- Return position of closing paren
                    end
                end
                -- No closing paren found - this is an incomplete link
                -- Return a position beyond the line to indicate we need to skip this newline
                return markdownLen + 1 -- Special value indicating incomplete link
            end
        end
    end

    -- Search backwards from pos to find if we're inside parentheses that are part of a markdown link
    -- Pattern: [text](url) - we need to check if pos is between ( and )
    local parenDepth = 0
    local foundOpenParen = nil
    local searchStart = math.max(1, pos - 1000) -- Search up to 1000 chars back

    -- First, find if we're inside parentheses by counting backwards
    for i = pos, searchStart, -1 do
        local char = string.sub(markdown, i, i)
        if char == ")" then
            parenDepth = parenDepth + 1
        elseif char == "(" then
            if parenDepth == 0 then
                -- Found an opening parenthesis - check if it's part of a markdown link
                foundOpenParen = i
                break
            else
                parenDepth = parenDepth - 1
            end
        end
    end

    -- If we found an opening parenthesis, check if it's part of a markdown link [text](url)
    if foundOpenParen then
        -- Look backwards from the opening paren for a closing bracket ]
        local bracketDepth = 0
        for i = foundOpenParen - 1, math.max(1, foundOpenParen - 500), -1 do
            local char = string.sub(markdown, i, i)
            if char == "]" then
                bracketDepth = bracketDepth + 1
            elseif char == "[" then
                if bracketDepth == 0 then
                    -- Found a markdown link pattern [text](url)
                    -- Now find the closing parenthesis
                    for j = foundOpenParen + 1, math.min(markdownLen, foundOpenParen + 2000) do
                        if string.sub(markdown, j, j) == ")" then
                            return j -- Return position of closing paren
                        end
                    end
                    return nil
                else
                    bracketDepth = bracketDepth - 1
                end
            end
        end
    end

    return nil
end

-- Helper function to check if a position is inside a table
-- Returns the position of the newline after the table end if inside a table, nil otherwise
-- This function considers a position "inside" a table if:
-- 1. It's on a table line, OR
-- 2. It's at a newline between table rows (after one table line and before another)
local function IsInsideTable(markdown, pos)
    local markdownLen = string.len(markdown)
    if pos < 1 or pos > markdownLen then
        return nil
    end

    -- Find the start of the line containing pos
    local lineStart = pos
    for i = pos - 1, math.max(1, pos - 1000), -1 do
        if i == 1 or string.sub(markdown, i - 1, i - 1) == "\n" then
            lineStart = i
            break
        end
    end
    if lineStart == pos then
        lineStart = 1
    end

    -- Find the end of the line containing pos
    local lineEnd = pos
    for i = pos, math.min(markdownLen, pos + 500) do
        if string.sub(markdown, i, i) == "\n" then
            lineEnd = i
            break
        end
    end
    if lineEnd == pos then
        lineEnd = markdownLen
    end

    -- Check if this line is a table line
    local lineContent = string.sub(markdown, lineStart, lineEnd - 1)
    local isOnTableLine = IsTableLine(lineContent)

    -- If pos is at a newline, also check if we're between table rows
    local isBetweenTableRows = false
    if string.sub(markdown, pos, pos) == "\n" and not isOnTableLine then
        -- Check if previous line is a table line
        local prevLineStart = lineStart
        if prevLineStart > 1 then
            for i = prevLineStart - 1, math.max(1, prevLineStart - 1000), -1 do
                if i == 1 or string.sub(markdown, i - 1, i - 1) == "\n" then
                    prevLineStart = i
                    break
                end
            end
            local prevLineEnd = lineStart - 1
            local prevLineContent = string.sub(markdown, prevLineStart, prevLineEnd - 1)
            local prevIsTableLine = IsTableLine(prevLineContent)

            -- Check if next line is a table line
            local nextLineStart = lineEnd + 1
            if nextLineStart <= markdownLen then
                -- Skip empty lines
                while nextLineStart <= markdownLen and string.sub(markdown, nextLineStart, nextLineStart) == "\n" do
                    nextLineStart = nextLineStart + 1
                end
                if nextLineStart <= markdownLen then
                    local nextLineEnd = nextLineStart
                    for i = nextLineStart, math.min(markdownLen, nextLineStart + 500) do
                        if string.sub(markdown, i, i) == "\n" then
                            nextLineEnd = i
                            break
                        end
                    end
                    local nextLineContent = string.sub(markdown, nextLineStart, nextLineEnd - 1)
                    local nextIsTableLine = IsTableLine(nextLineContent)

                    -- We're between table rows if both previous and next are table lines
                    isBetweenTableRows = prevIsTableLine and nextIsTableLine
                end
            end
        end
    end

    if not isOnTableLine and not isBetweenTableRows then
        return nil -- Not in a table
    end

    -- We're in a table - find where the table ends
    -- Search forward to find the end of the table (first non-table, non-empty line)
    local tableEnd = lineEnd
    local currentPos = lineEnd + 1
    local maxSearch = math.min(markdownLen, currentPos + 10000) -- Search up to 10k chars ahead

    while currentPos <= maxSearch do
        local nextNewline = nil
        for i = currentPos, maxSearch do
            if string.sub(markdown, i, i) == "\n" then
                nextNewline = i
                break
            end
        end

        if not nextNewline then
            -- Reached end of markdown - table ends here
            return markdownLen
        end

        local nextLineContent = string.sub(markdown, currentPos, nextNewline - 1)

        if IsTableLine(nextLineContent) then
            -- Still in table, continue
            tableEnd = nextNewline
            currentPos = nextNewline + 1
        elseif nextLineContent:match("^%s*$") then
            return tableEnd
        else
            -- Non-table, non-empty line - table ends before this
            return tableEnd
        end
    end

    -- If we reach here, table extends beyond search limit
    return tableEnd
end

-- Helper function to find a safe newline position that's not inside markdown structures
-- Returns the position of a safe newline, or nil if none found
-- Helper function to check if a newline position is right before a header
-- Returns true if the next non-empty line after newlinePos is a header
local function IsNewlineBeforeHeader(markdown, newlinePos, markdownLen)
    if newlinePos >= markdownLen then
        return false
    end

    -- Find the next non-empty line after this newline
    local nextLineStart = newlinePos + 1
    -- Skip empty lines
    while nextLineStart <= markdownLen and string.sub(markdown, nextLineStart, nextLineStart) == "\n" do
        nextLineStart = nextLineStart + 1
    end

    if nextLineStart > markdownLen then
        return false
    end

    -- Find the end of this line
    local nextLineEnd = nextLineStart
    for i = nextLineStart, math.min(markdownLen, nextLineStart + 200) do
        if string.sub(markdown, i, i) == "\n" then
            nextLineEnd = i
            break
        elseif i == markdownLen then
            nextLineEnd = markdownLen
            break
        end
    end

    -- Check if this line is a header (#### or #####)
    local nextLine = string.sub(markdown, nextLineStart, nextLineEnd - 1)
    return nextLine:match("^####%s") ~= nil or nextLine:match("^#####%s") ~= nil
end

-- Helper function to check if a position is inside a code block (```...```)
-- Returns a table with {blockStart, blockEnd} if inside one, nil otherwise
-- blockStart = position of newline BEFORE the opening ```
-- blockEnd = position of newline AFTER the closing ```
local function IsInsideCodeBlock(markdown, pos)
    local markdownLen = string.len(markdown)
    if pos < 1 or pos > markdownLen then
        return nil
    end

    -- OPTIMIZATION: Use pattern matching instead of character-by-character scanning
    -- to avoid O(n²) performance issues that can crash ESO

    -- Search backwards to find if we're inside a code block
    local searchStart = math.max(1, pos - (CHUNKING.BACKTRACK_WINDOW or 5000))
    local beforePos = string.sub(markdown, searchStart, pos - 1)

    -- Find the LAST ``` before pos (opening marker)
    local lastBacktickPos = nil
    local searchPos = 1
    while true do
        local found = string.find(beforePos, "\n```", searchPos, true)
        if not found then
            break
        end
        lastBacktickPos = found
        searchPos = found + 1
    end

    -- Also check if document starts with ```
    local docStartsWithBacktick = false
    if string.sub(markdown, 1, 3) == "```" and pos > 3 then
        docStartsWithBacktick = true
    end

    -- If we found an opening ```, check if there's a closing one after it
    if lastBacktickPos or docStartsWithBacktick then
        local blockStart
        if docStartsWithBacktick and (not lastBacktickPos or searchStart == 1) then
            blockStart = 0 -- Document starts with code block
        else
            blockStart = searchStart + lastBacktickPos - 1 -- Absolute position of newline before ```
        end

        -- Now search forward from pos to find closing ```
        local afterPos = string.sub(markdown, pos, math.min(markdownLen, pos + (CHUNKING.BACKTRACK_WINDOW or 5000)))
        local closingPos = string.find(afterPos, "\n```", 1, true)
        if closingPos then
            -- Found closing ```, return block boundaries
            local blockEnd = pos + closingPos + 3 -- Position after closing ```\n
            return { blockStart, blockEnd }
        else
            -- No closing ``` found - assume we're inside a block that extends beyond search window
            -- Return blockStart so we can split BEFORE the block
            return { blockStart, markdownLen }
        end
    end

    return nil
end
-- Helper function to get the Mermaid header (e.g., "graph TD" or "flowchart LR") from a block
-- This function handles blocks with %%{init:...}%% comments and empty lines before the directive
local function GetMermaidHeader(markdown, blockStart)
    -- blockStart is the newline before ```
    -- So ``` starts at blockStart + 1
    local markdownLen = string.len(markdown)

    -- Find the end of the line containing ```mermaid
    local lineEnd = string.find(markdown, "\n", blockStart + 1)
    if not lineEnd then
        return "flowchart LR" -- Default fallback
    end

    local firstLine = string.sub(markdown, blockStart + 1, lineEnd - 1)
    -- Check if header is on the same line: ```mermaid flowchart LR
    local sameLineHeader = firstLine:match("```mermaid%s+(.+)")
    if sameLineHeader then
        return sameLineHeader
    end

    -- Header is on a subsequent line - search up to 10 lines for a diagram directive
    -- (handles %%{init:...}%% comments and empty lines before the flowchart/graph directive)
    local currentLineStart = lineEnd + 1
    local headerLines = {} -- Collect init comments and directives

    for _ = 1, 10 do -- Search up to 10 lines
        if currentLineStart > markdownLen then
            break
        end

        local currentLineEnd = string.find(markdown, "\n", currentLineStart)
        if not currentLineEnd then
            currentLineEnd = markdownLen + 1
        end

        local line = string.sub(markdown, currentLineStart, currentLineEnd - 1)
        local trimmedLine = line:match("^%s*(.-)%s*$") or ""

        -- Check if this line is a diagram directive (flowchart, graph, sequenceDiagram, etc.)
        if
            trimmedLine:match("^flowchart")
            or trimmedLine:match("^graph%s")
            or trimmedLine:match("^sequenceDiagram")
            or trimmedLine:match("^gantt")
            or trimmedLine:match("^classDiagram")
            or trimmedLine:match("^stateDiagram")
            or trimmedLine:match("^erDiagram")
            or trimmedLine:match("^pie")
            or trimmedLine:match("^journey")
        then
            -- Found the diagram directive - collect everything before it plus the directive
            table.insert(headerLines, line)
            return table.concat(headerLines, "\n")
        elseif trimmedLine:match("^%%") then
            -- This is a mermaid comment (like %%{init:...}%%) - include it
            table.insert(headerLines, line)
        elseif trimmedLine == "" then
            -- Empty line - include it but keep searching
            table.insert(headerLines, line)
        else
            -- Unrecognized line - stop searching and return what we have plus this line
            table.insert(headerLines, line)
            return table.concat(headerLines, "\n")
        end

        currentLineStart = currentLineEnd + 1
    end

    -- Fallback if no directive found
    if #headerLines > 0 then
        return table.concat(headerLines, "\n")
    end
    return "flowchart LR"
end

local function FindSafeNewline(markdown, startPos, endPos)
    local markdownLen = string.len(markdown)
    endPos = math.min(endPos, markdownLen)

    -- Search backwards from endPos to startPos
    local i = endPos
    while i >= startPos do
        if string.sub(markdown, i, i) == "\n" then
            -- Check if this newline is inside a code block (CRITICAL: must check this first!)
            local codeBlock = IsInsideCodeBlock(markdown, i)
            if codeBlock then
                -- This newline is inside a code block
                local blockStart = codeBlock[1]

                -- Check if it's a Mermaid block
                local isMermaid, mStart, _ = IsInsideMermaidBlock(markdown, i)

                if isMermaid then
                    -- It is a Mermaid block. Check if we are inside a subgraph.
                    -- IsInsideMermaidBlock returns the innermost structure boundaries.
                    -- If mStart points to "subgraph", we are inside a subgraph.
                    -- If mStart points to "```mermaid", we are at top level.

                    -- Check the line at mStart
                    local checkLen = 20
                    local checkStr = string.sub(markdown, math.max(1, mStart), math.min(markdownLen, mStart + checkLen))

                    if checkStr:match("subgraph") then
                        -- Inside subgraph - NOT safe to split here.
                        -- Jump to before the subgraph starts
                        i = mStart - 1
                    else
                        -- Top level Mermaid block - SAFE to split here!
                        -- Return this position
                        return i
                    end
                else
                    -- Not a Mermaid block (or logic failed) - standard behavior
                    -- CRITICAL: Search BACKWARDS to split BEFORE the code block, not after
                    -- (Code blocks can be huge - 474+ lines - can't keep them in one chunk)

                    -- Jump to before the code block and continue searching
                    i = blockStart - 1
                end

                if i < startPos then
                    -- Can't split before the block within our search range
                    break
                end
            else
                -- Check if this newline is inside a table
                local tableEnd = IsInsideTable(markdown, i)
                if tableEnd then
                    -- This newline is inside a table, skip to after the table
                    if tableEnd < endPos then
                        -- Try to find a newline after the table
                        for j = tableEnd + 1, math.min(markdownLen, tableEnd + 200) do
                            if string.sub(markdown, j, j) == "\n" then
                                -- Check if this newline is before a header
                                if not IsNewlineBeforeHeader(markdown, j, markdownLen) then
                                    return j
                                end
                            end
                        end
                    end
                    -- If we can't find a newline after the table, skip past the table
                    -- and continue searching backwards from before the table
                    i = tableEnd - 1
                    if i < startPos then
                        break
                    end
                else
                    -- Check if this newline is inside a markdown link
                    local linkEnd = IsInsideMarkdownLink(markdown, i)
                    if linkEnd then
                        -- This newline is inside a link, skip to after the link
                        if linkEnd < endPos then
                            -- Try to find a newline after the link
                            for j = linkEnd + 1, math.min(markdownLen, linkEnd + 200) do
                                if string.sub(markdown, j, j) == "\n" then
                                    -- Check if this newline is before a header
                                    if not IsNewlineBeforeHeader(markdown, j, markdownLen) then
                                        return j
                                    end
                                end
                            end
                        end
                        -- If we can't find a newline after the link, continue searching backwards
                        i = i - 1
                    else
                        -- Check if this newline is right before a header
                        if not IsNewlineBeforeHeader(markdown, i, markdownLen) then
                            -- This newline is safe to use (not before a header, not in table/link)
                            return i
                        else
                            -- This newline is before a header, skip it and continue searching
                            i = i - 1
                        end
                    end
                end
            end -- Close the code block else block
        else
            i = i - 1
        end
    end

    return nil
end

-- Helper function to find the end of a table starting at a given position
local function FindTableEnd(markdown, startPos, maxSearch)
    local markdownLen = string.len(markdown)
    local searchEnd = math.min(startPos + maxSearch, markdownLen)

    local lineStart = startPos
    for i = startPos, math.max(1, startPos - 1000), -1 do
        if i == 1 or string.sub(markdown, i - 1, i - 1) == "\n" then
            lineStart = i
            break
        end
    end

    local line = string.sub(markdown, lineStart, startPos - 1)
    if not IsTableLine(line) then
        return nil
    end

    local lastTableLineEnd = startPos
    local currentPos = startPos + 1

    while currentPos <= searchEnd do
        local nextNewline = nil
        for i = currentPos, searchEnd do
            if string.sub(markdown, i, i) == "\n" then
                nextNewline = i
                break
            end
        end

        if not nextNewline then
            break
        end

        local lineContent = string.sub(markdown, currentPos, nextNewline - 1)

        if IsTableLine(lineContent) then
            lastTableLineEnd = nextNewline
            currentPos = nextNewline + 1
        elseif lineContent:match("^%s*$") then
            return lastTableLineEnd
        else
            return lastTableLineEnd
        end
    end

    if lastTableLineEnd <= markdownLen and string.sub(markdown, lastTableLineEnd, lastTableLineEnd) == "\n" then
        return lastTableLineEnd
    else
        return startPos
    end
end

-- =====================================================
-- PADDING UTILITIES
-- =====================================================

-- Strip padding from chunk content for paste/copy operations
-- Padding format: content + SPACE_PADDING_SIZE newlines (550 by default)
-- This function removes chunk markers and normalizes trailing newlines for copy/paste
local function StripPadding(content, isLastChunk)
    if not content or content == "" then
        return content
    end

    local stripped = content

    -- Strip chunk marker at the beginning (e.g., "<!-- Chunk 1 (20448 bytes before padding) -->\n\n")
    -- Pattern matches: <!-- Chunk N (optional text) --> followed by optional whitespace/newlines
    stripped = stripped:gsub("^%s*<!%-%-%s*Chunk%s+%d+%s*%([^%)]*%)%s*-%->%s*\n*\n*", "")

    -- Early return if padding is disabled - only chunk marker was stripped
    if CHUNKING.DISABLE_PADDING then
        CM.DebugPrint(
            "CHUNKING",
            string.format(
                "StripPadding: removed chunk marker (original: %d bytes, stripped: %d bytes)",
                string.len(content),
                string.len(stripped)
            )
        )
        return stripped
    end

    -- For newline padding: just normalize excessive trailing newlines to 1-2
    -- We can't reliably detect "padding newlines" vs "content newlines", so just normalize
    -- Markdown renderers ignore excessive newlines anyway, but this keeps output clean
    stripped = stripped:gsub("\n\n+$", "\n\n") -- Collapse 3+ trailing newlines to 2

    CM.DebugPrint(
        "CHUNKING",
        string.format(
            "StripPadding: removed chunk marker and normalized trailing newlines (original: %d bytes, stripped: %d bytes)",
            string.len(content),
            string.len(stripped)
        )
    )

    return stripped
end

-- Detect chunk boundaries that would split a ```mermaid opener into bare "mermaid"
local function WouldSplitPartialMermaidFence(markdown, chunkEnd, markdownLen)
    if chunkEnd >= markdownLen then
        return false
    end

    local nextStart = chunkEnd + 1
    local afterSplit = string.sub(markdown, nextStart, math.min(markdownLen, nextStart + 12))
    if afterSplit:match("^%s*mermaid") then
        return true
    end

    -- Split inside "```mermaid" (after opening backticks, before the word)
    for i = math.max(1, chunkEnd - 9), chunkEnd do
        if string.sub(markdown, i, i + 9) == "```mermaid" and chunkEnd < i + 10 then
            return true
        end
    end

    return false
end

-- Backtrack before a partial ```mermaid fence so the next chunk keeps the full opener
local function BacktrackFromPartialMermaidFence(markdown, chunkEnd, pos, isLast, backtrackBefore)
    local nextStart = chunkEnd + 1
    local markdownLen = string.len(markdown)
    if nextStart > markdownLen then
        return nil
    end

    local afterSplit = string.sub(markdown, nextStart, math.min(markdownLen, nextStart + 12))
    if not afterSplit:match("^%s*mermaid") and not afterSplit:match("^%s*``") then
        return nil
    end

    for i = math.min(chunkEnd, nextStart - 1), pos, -1 do
        if string.sub(markdown, i, i + 2) == "```" then
            local newEnd = backtrackBefore(i, isLast)
            if newEnd then
                return newEnd
            end
        end
    end

    return nil
end


-- Split markdown into chunks with conservative padding to prevent truncation
-- This is the consolidated, best implementation that handles:
-- 1. Tables and lists properly (doesn't split in the middle)
-- 2. Padding to prevent truncation
-- 3. Extensive safety checks

-- =====================================================
-- MAIN CHUNKING FUNCTION (consolidated)
-- =====================================================

local string_sub = string.sub
local string_len = string.len
local string_rep = string.rep
local string_format = string.format
local math_min = math.min
local math_max = math.max

---Split markdown into EditBox-safe chunks with markers and padding.
---@param markdown string
---@return table
local function SplitMarkdownIntoChunks(markdown)
    local chunks = {}
    local markdownLength = string_len(markdown)
    local maxDataChars = CHUNKING.MAX_DATA_CHARS
    local copyLimit = CHUNKING.COPY_LIMIT or CHUNKING.EDITBOX_LIMIT or 21500

    local markerSize = CHUNKING.CHUNK_MARKER_SIZE or 60
    local mermaidHeaderReserve = CHUNKING.MERMAID_HEADER_RESERVE or 350
    local spacePaddingSize = 0
    if not CHUNKING.DISABLE_PADDING then
        spacePaddingSize = CHUNKING.SPACE_PADDING_SIZE or CHUNKING.PADDING_FALLBACK or 550
    end
    local paddingSize = spacePaddingSize
    local totalOverhead = markerSize + paddingSize + mermaidHeaderReserve

    if markdownLength <= maxDataChars then
        return { { content = markdown } }
    end

    local chunkNum = 1
    local pos = 1
    local prependNewlineToChunk = false
    local prependMermaidHeader = nil

    local function ValidateChunkSizeAfterBacktrack(newEnd, isLast)
        if newEnd < pos then
            return false
        end
        local dataSize = newEnd - pos + 1
        local totalSize = dataSize + totalOverhead
        if isLast then
            return dataSize > 0 and totalSize <= copyLimit
        end
        return totalSize <= copyLimit and dataSize >= 100
    end

    local function BacktrackBefore(fromPos, isLast, window)
        window = window or 1000
        for i = fromPos - 1, math_max(pos, fromPos - window), -1 do
            if i == pos or string_sub(markdown, i, i) == "\n" then
                local newEnd = (i == pos) and pos or i
                if ValidateChunkSizeAfterBacktrack(newEnd, isLast) then
                    return newEnd
                end
            end
        end
        return nil
    end

    local function TryExtendStructure(endPos, structureEnd, isLast)
        if not structureEnd or structureEnd <= endPos then
            return endPos
        end
        if ValidateChunkSizeAfterBacktrack(structureEnd, isLast) then
            return structureEnd
        end
        return endPos
    end

    local function ResolveChunkEnd(potentialEnd, isLast)
        local chunkEnd = potentialEnd
        local foundNewline = false

        if potentialEnd >= markdownLength then
            return chunkEnd, isLast
        end

        -- Look-ahead: stop before headers/tables/lists that will not fit
        local lookAheadEnd = math_min(potentialEnd + 500, markdownLength)
        local checkPos = potentialEnd + 1
        local structureStartPos = nil

        while checkPos <= lookAheadEnd do
            if string_sub(markdown, checkPos, checkPos) == "\n" then
                checkPos = checkPos + 1
            else
                local lineEnd = checkPos
                for i = checkPos, math_min(lookAheadEnd, checkPos + 500) do
                    if string_sub(markdown, i, i) == "\n" then
                        lineEnd = i
                        break
                    end
                end
                local line = string_sub(markdown, checkPos, lineEnd - 1)
                local maxSafeDataSize = copyLimit - totalOverhead

                if line:match("^####%s") or line:match("^#####%s") then
                    structureStartPos = checkPos
                    break
                elseif IsTableLine(line) then
                    local tableEnd = FindTableEnd(markdown, lineEnd, 10000)
                    if tableEnd then
                        local chunkWithStructure = (checkPos - pos) + (tableEnd - checkPos + 1)
                        if chunkWithStructure > maxSafeDataSize then
                            structureStartPos = checkPos
                            break
                        end
                    end
                elseif IsListLine(line) then
                    local listEnd = FindListEnd(markdown, lineEnd, 10000)
                    if listEnd then
                        local chunkWithStructure = (checkPos - pos) + (listEnd - checkPos + 1)
                        if chunkWithStructure > maxSafeDataSize then
                            structureStartPos = checkPos
                            break
                        end
                    end
                end
                checkPos = lineEnd + 1
            end
        end

        if structureStartPos then
            local newEnd = BacktrackBefore(structureStartPos, isLast)
            if newEnd then
                chunkEnd = newEnd
                foundNewline = true
            end
        end

        -- Never split multi-column grid at </div> boundary
        if
            chunkEnd < markdownLength
            and WouldNextChunkStartWithGridColumnBoundary(markdown, chunkEnd, markdownLength)
        then
            local gridStart = FindGridContainerStartBackward(markdown, chunkEnd)
            if gridStart and gridStart >= pos and ValidateChunkSizeAfterBacktrack(gridStart, isLast) then
                chunkEnd = gridStart
                foundNewline = true
            end
        end

        -- Safe newline search (avoid links and header splits)
        if not foundNewline then
            local searchStart = math_max(pos, potentialEnd - 1000)
            local safeNewline = FindSafeNewline(markdown, searchStart, potentialEnd)
            if safeNewline then
                chunkEnd = safeNewline
                foundNewline = true
            else
                for i = potentialEnd, searchStart, -1 do
                    if string_sub(markdown, i, i) == "\n" then
                        if not IsNewlineBeforeHeader(markdown, i, markdownLength) and not IsInsideMarkdownLink(markdown, i) then
                            chunkEnd = i
                            foundNewline = true
                            break
                        end
                    end
                end
            end
        end

        if not foundNewline and potentialEnd > pos then
            local extendedStart = math_max(pos, potentialEnd - (CHUNKING.BACKTRACK_WINDOW or 5000))
            local safeNewline = FindSafeNewline(markdown, extendedStart, potentialEnd)
            if safeNewline then
                chunkEnd = safeNewline
            else
                for i = potentialEnd, extendedStart, -1 do
                    if string_sub(markdown, i, i) == "\n" then
                        if not IsNewlineBeforeHeader(markdown, i, markdownLength) and not IsInsideMarkdownLink(markdown, i) then
                            chunkEnd = i
                            break
                        end
                    end
                end
            end
        end

        -- Keep mermaid blocks intact when possible; otherwise backtrack before block
        local inMermaid, mStart, mEnd = IsInsideMermaidBlock(markdown, chunkEnd)
        if inMermaid and mStart and mEnd and chunkEnd < mEnd then
            if ValidateChunkSizeAfterBacktrack(mEnd, isLast) then
                chunkEnd = mEnd
            elseif mStart > pos then
                local newEnd = BacktrackBefore(mStart, isLast, 2000)
                if newEnd then
                    chunkEnd = newEnd
                end
            end
        end

        -- Keep HTML blocks intact when possible
        local isInsideHtml, htmlStart, htmlEnd = IsInsideHtmlBlock(markdown, chunkEnd)
        if isInsideHtml and htmlStart and htmlEnd and chunkEnd < htmlEnd then
            if ValidateChunkSizeAfterBacktrack(htmlEnd, isLast) then
                chunkEnd = htmlEnd
            elseif htmlStart > pos then
                local newEnd = BacktrackBefore(htmlStart, isLast, 2000)
                if newEnd then
                    chunkEnd = newEnd
                end
            end
        end

        -- Keep tables intact when split point lands inside a table
        if IsInsideTable(markdown, chunkEnd) then
            local tableEnd = FindTableEnd(markdown, chunkEnd, 10000)
            if tableEnd then
                chunkEnd = TryExtendStructure(chunkEnd, tableEnd, isLast)
            end
        end

        -- Keep code blocks intact
        if IsInsideCodeBlock(markdown, chunkEnd) then
            for i = chunkEnd + 1, math_min(markdownLength, chunkEnd + 20000) do
                if i >= 3 and string_sub(markdown, i - 2, i) == "```" then
                    if ValidateChunkSizeAfterBacktrack(i, isLast) then
                        chunkEnd = i
                    end
                    break
                end
            end
        end

        -- Avoid splitting inside markdown links
        local linkAtEnd = IsInsideMarkdownLink(markdown, chunkEnd)
        if linkAtEnd and linkAtEnd > chunkEnd then
            local safeNewline = FindSafeNewline(markdown, chunkEnd, math_min(markdownLength, linkAtEnd + 200))
            if safeNewline and ValidateChunkSizeAfterBacktrack(safeNewline, isLast) then
                chunkEnd = safeNewline
            else
                local newEnd = BacktrackBefore(chunkEnd, isLast)
                if newEnd then
                    chunkEnd = newEnd
                end
            end
        end

        -- Avoid splitting inside HTML tags
        local isInsideHtmlTag, htmlTagStart = IsInsideHtmlTag(markdown, chunkEnd)
        if isInsideHtmlTag and htmlTagStart and htmlTagStart > pos then
            local newEnd = BacktrackBefore(htmlTagStart, isLast)
            if newEnd then
                chunkEnd = newEnd
            end
        end

        -- Never split inside a ```mermaid opener (prevents bare "mermaid" at chunk start)
        if WouldSplitPartialMermaidFence(markdown, chunkEnd, markdownLength) then
            local newEnd = BacktrackFromPartialMermaidFence(markdown, chunkEnd, pos, isLast, BacktrackBefore)
            if newEnd then
                chunkEnd = newEnd
            end
        end

        return chunkEnd, (chunkEnd >= markdownLength)
    end

    while pos <= markdownLength do
        local maxSafeDataSize = copyLimit - totalOverhead
        local effectiveMaxData = math_min(maxDataChars, maxSafeDataSize)
        local potentialEnd = math_min(pos + effectiveMaxData - 1, markdownLength)
        local isLastChunk = (potentialEnd >= markdownLength)

        local chunkEnd = ResolveChunkEnd(potentialEnd, isLastChunk)
        isLastChunk = (chunkEnd >= markdownLength)

        -- Last chunk: include remainder only if it fits
        if isLastChunk and chunkEnd < markdownLength then
            local remainingLength = markdownLength - pos + 1
            if remainingLength + totalOverhead <= copyLimit then
                chunkEnd = markdownLength
                isLastChunk = true
            else
                isLastChunk = false
            end
        end

        local savedMermaidHeader = prependMermaidHeader
        local pendingMermaidHeader = savedMermaidHeader
        local chunkReady = false
        local nextMermaidHeader
        local chunkContent
        local chunkData

        repeat
            local strippedFence = false
            local skipMermaidClose = false
            chunkData = string_sub(markdown, pos, chunkEnd)
            chunkContent = chunkData

            if string_len(chunkContent) + totalOverhead > copyLimit then
                isLastChunk = false
                local maxDataForFinal = copyLimit - totalOverhead
                local safeEndPos = pos + maxDataForFinal - 1
                local lastNewlinePos = FindSafeNewline(markdown, pos, math_min(safeEndPos, chunkEnd, markdownLength))
                if not lastNewlinePos then
                    for i = math_min(safeEndPos, chunkEnd, markdownLength), pos, -1 do
                        if string_sub(markdown, i, i) == "\n" then
                            lastNewlinePos = i
                            break
                        end
                    end
                end
                if lastNewlinePos and lastNewlinePos >= pos then
                    chunkEnd = lastNewlinePos
                else
                    chunkEnd = safeEndPos
                end
                chunkData = string_sub(markdown, pos, chunkEnd)
                chunkContent = chunkData
            end

            if (not isLastChunk or chunkEnd < markdownLength) and string_sub(chunkContent, -1, -1) ~= "\n" then
                chunkContent = chunkContent .. "\n"
            end

            local newChunkEnd, shouldPrepend =
                BacktrackBeforeHeaderTablePair(markdown, pos, chunkEnd, markdownLength, copyLimit, totalOverhead)
            if newChunkEnd then
                chunkEnd = newChunkEnd
                chunkData = string_sub(markdown, pos, chunkEnd)
                chunkContent = chunkData
                prependNewlineToChunk = shouldPrepend
            end

            if prependNewlineToChunk then
                chunkContent = "\n" .. chunkContent
                prependNewlineToChunk = false
            end

            if pendingMermaidHeader then
                local startsWithMermaidFence = chunkContent:match("^%s*```mermaid")
                local startsWithInit = chunkContent:match("^%s*%%%%{init:")
                local startsWithFlowchart = chunkContent:match("^%s*flowchart")
                    or chunkContent:match("^%s*graph%s")
                    or chunkContent:match("^%s*sequenceDiagram")
                    or chunkContent:match("^%s*gantt")
                    or chunkContent:match("^%s*classDiagram")
                    or chunkContent:match("^%s*stateDiagram")
                    or chunkContent:match("^%s*erDiagram")
                    or chunkContent:match("^%s*pie")
                    or chunkContent:match("^%s*journey")

                if startsWithMermaidFence then
                    skipMermaidClose = true
                elseif chunkContent:match("^%s*mermaid") then
                    chunkContent = "```" .. chunkContent
                    skipMermaidClose = true
                elseif chunkContent:match("^%s*```") then
                    chunkContent = chunkContent:gsub("^%s*```%s*", "", 1)
                    strippedFence = true
                elseif startsWithInit or startsWithFlowchart then
                    skipMermaidClose = true
                    chunkContent = "```mermaid\n" .. chunkContent
                else
                    chunkContent = pendingMermaidHeader .. chunkContent
                end
                pendingMermaidHeader = nil
            end

            local contentSizeBeforePadding = string_len(chunkContent)
            local chunkMarker =
                string_format("<!-- Chunk %d (%d bytes before padding) -->\n\n", chunkNum, contentSizeBeforePadding)
            chunkContent = chunkMarker .. chunkContent

            nextMermaidHeader = nil
            local inMermaid, mStart, mEnd = IsInsideMermaidBlock(markdown, chunkEnd)
            if inMermaid and chunkEnd < mEnd and not strippedFence and not skipMermaidClose then
                local distanceFromStart = chunkEnd - mStart
                if distanceFromStart >= 500 then
                    chunkContent = chunkContent .. "\n```\n"
                    local blockStart = mStart
                    if not string_sub(markdown, mStart, mStart + 10):match("```mermaid") then
                        for k = mStart, math_max(1, mStart - 50000), -1 do
                            if string_sub(markdown, k, k + 9) == "```mermaid" then
                                blockStart = k
                                break
                            end
                        end
                    end
                    local header = GetMermaidHeader(markdown, blockStart)
                    nextMermaidHeader = "```mermaid\n" .. header .. "\n"
                end
            end

            if not isLastChunk and string_sub(chunkContent, -1, -1) ~= "\n" then
                local lastNewline = string.find(chunkContent, "\n[^\n]*$")
                if lastNewline then
                    chunkContent = string_sub(chunkContent, 1, lastNewline)
                end
            end

            if not CHUNKING.DISABLE_PADDING then
                chunkContent = chunkContent:gsub("\n+$", "\n") .. string_rep("\n", spacePaddingSize)
            else
                chunkContent = chunkContent:gsub("\n+$", "\n")
            end

            local finalChunkSize = string_len(chunkContent)
            if finalChunkSize > copyLimit then
                CM.DebugPrint(
                    "CHUNKING",
                    string_format(
                        "Chunk %d post-assembly size %d exceeds copyLimit %d; backtracking from end %d",
                        chunkNum,
                        finalChunkSize,
                        copyLimit,
                        chunkEnd
                    )
                )
                local reducedEnd = BacktrackBefore(chunkEnd, isLastChunk, 2000)
                if not reducedEnd or reducedEnd >= chunkEnd then
                    reducedEnd = chunkEnd - 1
                end
                if reducedEnd < pos then
                    CM.Warn(
                        string_format(
                            "Chunk %d could not fit within copyLimit %d (size %d); using best effort",
                            chunkNum,
                            copyLimit,
                            finalChunkSize
                        )
                    )
                    chunkReady = true
                else
                    chunkEnd = reducedEnd
                    isLastChunk = (chunkEnd >= markdownLength)
                    pendingMermaidHeader = savedMermaidHeader
                end
            else
                CM.DebugPrint(
                    "CHUNKING",
                    string_format("Chunk %d final size %d (limit %d)", chunkNum, finalChunkSize, copyLimit)
                )
                chunkReady = true
            end
        until chunkReady

        prependMermaidHeader = nextMermaidHeader

        if not isLastChunk and not CHUNKING.DISABLE_PADDING then
            local trailing = chunkContent:match("\n+$")
            local trailingCount = trailing and #trailing or 0
            if trailingCount < 500 then
                CM.Warn(
                    string_format(
                        "Chunk %d: padding check - expected >=500 trailing newlines, got %d (may indicate truncation)",
                        chunkNum,
                        trailingCount
                    )
                )
            end
        end

        table.insert(chunks, { content = chunkContent })

        if chunkEnd < markdownLength then
            pos = chunkEnd + 1
            chunkNum = chunkNum + 1
        elseif not isLastChunk then
            pos = chunkEnd + 1
            chunkNum = chunkNum + 1
        else
            break
        end
    end

    CM.DebugPrint("CHUNKING", string_format("Split into %d chunks (total: %d chars)", #chunks, markdownLength))
    return chunks
end

-- =====================================================
-- EXPORTS
-- =====================================================

CM.utils.Chunking = {
    SplitMarkdownIntoChunks = SplitMarkdownIntoChunks,
    StripPadding = StripPadding,
}

CM.DebugPrint("UTILS", "Chunking module loaded")
