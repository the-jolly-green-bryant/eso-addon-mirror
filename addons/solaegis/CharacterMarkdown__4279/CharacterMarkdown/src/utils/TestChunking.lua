-- CharacterMarkdown - Chunking Tests
-- Unit tests for the Chunking module to verify splitting logic

local CM = CharacterMarkdown
CM.tests = CM.tests or {}
CM.tests.chunking = {}

local string_format = string.format
local string_rep = string.rep
local StripPadding = CM.utils.Chunking and CM.utils.Chunking.StripPadding

local function StripChunkForCompare(content, isLastChunk)
    if StripPadding then
        return StripPadding(content, isLastChunk)
    end
    return content
end

local function CountMermaidFences(content)
    local count = 0
    local searchPos = 1
    while true do
        local startPos, endPos = content:find("```", searchPos, true)
        if not startPos then
            break
        end
        count = count + 1
        searchPos = endPos + 1
    end
    return count
end

-- =====================================================
-- TEST HELPERS
-- =====================================================

local function CreateLongString(char, length)
    return string_rep(char, length)
end

-- =====================================================
-- TESTS
-- =====================================================

local function TestBasicSplitting()
    -- Create a string slightly larger than the limit (assuming limit is around 6000)
    -- We'll use a smaller limit for testing if possible, but we can't easily change the constant
    -- So we'll construct a string that MUST be split

    local limit = CM.constants.CHUNKING.COPY_LIMIT or 5700
    local part1 = CreateLongString("A", limit - 100)
    local part2 = CreateLongString("B", 200)
    local input = part1 .. "\n\n" .. part2

    local chunks = CM.utils.Chunking.SplitMarkdownIntoChunks(input)

    if #chunks < 2 then
        return false, string_format("Expected at least 2 chunks, got %d", #chunks)
    end

    -- Verify total content matches (strip padding/marker overhead before compare)
    local reassembled = ""
    for i, chunk in ipairs(chunks) do
        reassembled = reassembled .. StripChunkForCompare(chunk.content, i == #chunks)
    end

    if reassembled ~= input then
        return false, "Reassembled content does not match input"
    end

    return true, "Split correctly"
end

local function TestHtmlBlockIntegrity()
    -- Create a large HTML block that shouldn't be split
    -- Note: If the block is larger than the ABSOLUTE limit, it MUST be split,
    -- but the chunking logic tries to avoid it if possible.
    -- We'll create a scenario where a split point falls inside an HTML block

    local limit = CM.constants.CHUNKING.COPY_LIMIT or 5700
    local padding = CreateLongString("P", limit - 100) -- Fill up most of the first chunk

    local htmlBlock = "<div>\n" .. CreateLongString("H", 200) .. "\n</div>"
    local input = padding .. "\n" .. htmlBlock

    local chunks = CM.utils.Chunking.SplitMarkdownIntoChunks(input)

    -- We expect the HTML block to be pushed to the second chunk to avoid splitting it
    -- Or if it fits, it might be in the first chunk.
    -- The key is that the HTML block string should appear intact in one of the chunks

    local foundIntact = false
    for _, chunk in ipairs(chunks) do
        if chunk.content:find(htmlBlock, 1, true) then
            foundIntact = true
            break
        end
    end

    if not foundIntact then
        return false, "HTML block was split across chunks"
    end

    return true, "HTML block preserved"
end

local function TestMermaidBlockIntegrity()
    local limit = CM.constants.CHUNKING.COPY_LIMIT or 5700
    local padding = CreateLongString("P", limit - 100)

    local mermaidBlock = "```mermaid\ngraph TD;\nA-->B;\n" .. CreateLongString("C", 200) .. "\n```"
    local input = padding .. "\n" .. mermaidBlock

    local chunks = CM.utils.Chunking.SplitMarkdownIntoChunks(input)

    local foundIntact = false
    for _, chunk in ipairs(chunks) do
        if chunk.content:find(mermaidBlock, 1, true) then
            foundIntact = true
            break
        end
    end

    if not foundIntact then
        return false, "Mermaid block was split across chunks"
    end

    for i, chunk in ipairs(chunks) do
        local fenceCount = CountMermaidFences(chunk.content)
        if fenceCount % 2 ~= 0 then
            return false, string_format("Chunk %d has unclosed mermaid fence (count: %d)", i, fenceCount)
        end
        local openFence = chunk.content:find("```mermaid", 1, true)
        local closeFence = chunk.content:find("\n```", openFence and (openFence + 1) or 1, true)
        if openFence and not closeFence then
            return false, string_format("Chunk %d opens mermaid block without closing fence", i)
        end
    end

    return true, "Mermaid block preserved"
end

local function TestPaddingConsistency()
    local limit = CM.constants.CHUNKING.COPY_LIMIT or 5700
    local expectedPadding = CM.constants.CHUNKING.SPACE_PADDING_SIZE or CM.constants.CHUNKING.PADDING_FALLBACK or 550

    if CM.constants.CHUNKING.DISABLE_PADDING then
        return true, "Padding disabled - skip"
    end

    -- Create markdown that must be split into multiple chunks
    local part1 = CreateLongString("A", limit - 100)
    local part2 = CreateLongString("B", limit - 100)
    local part3 = CreateLongString("C", 500)
    local input = part1 .. "\n\n" .. part2 .. "\n\n" .. part3

    local chunks = CM.utils.Chunking.SplitMarkdownIntoChunks(input)

    if #chunks < 2 then
        return false, string_format("Expected at least 2 chunks for padding test, got %d", #chunks)
    end

    -- Each non-last chunk must end with exactly expectedPadding newlines
    for i = 1, #chunks - 1 do
        local content = chunks[i].content
        local trailing = content:match("\n+$")
        local count = trailing and #trailing or 0
        if count ~= expectedPadding then
            return false, string_format("Chunk %d: expected %d trailing newlines, got %d", i, expectedPadding, count)
        end
    end

    return true, string_format("All %d non-last chunks have %d trailing newlines", #chunks - 1, expectedPadding)
end

local function TestChunkSizeLimits()
    local limit = CM.constants.CHUNKING.COPY_LIMIT or 5700
    local part1 = CreateLongString("A", limit - 100)
    local part2 = CreateLongString("B", limit - 100)
    local input = part1 .. "\n\n" .. part2

    local chunks = CM.utils.Chunking.SplitMarkdownIntoChunks(input)
    for i, chunk in ipairs(chunks) do
        if string.len(chunk.content) > limit then
            return false, string_format("Chunk %d exceeds COPY_LIMIT (%d > %d)", i, string.len(chunk.content), limit)
        end
    end

    return true, "All chunks within COPY_LIMIT"
end

local function TestChunkMarkersAndPadding()
    local limit = CM.constants.CHUNKING.COPY_LIMIT or 5700
    local expectedPadding = CM.constants.CHUNKING.SPACE_PADDING_SIZE or 550
    local input = CreateLongString("X", limit - 50) .. "\n\n" .. CreateLongString("Y", limit - 50)

    local chunks = CM.utils.Chunking.SplitMarkdownIntoChunks(input)
    if #chunks < 2 then
        return false, "Expected multiple chunks for marker/padding test"
    end

    for i = 1, #chunks - 1 do
        if not chunks[i].content:match("<!%-%- Chunk %d+") then
            return false, string_format("Chunk %d missing HTML chunk marker", i)
        end
        local trailing = chunks[i].content:match("\n+$")
        local count = trailing and #trailing or 0
        if count ~= expectedPadding then
            return false, string_format("Chunk %d: expected %d trailing newlines, got %d", i, expectedPadding, count)
        end
    end

    return true, "Chunk markers and padding present on non-final chunks"
end

local function TestMarkdownLinkIntegrity()
    local limit = CM.constants.CHUNKING.COPY_LIMIT or 5700
    local padding = CreateLongString("P", limit - 100)
    local linkBlock = "See [UESP link](https://en.uesp.net/wiki/Online:Ability) for details.\n"
    local input = padding .. "\n" .. linkBlock

    local chunks = CM.utils.Chunking.SplitMarkdownIntoChunks(input)
    local foundIntact = false
    for _, chunk in ipairs(chunks) do
        if chunk.content:find(linkBlock, 1, true) then
            foundIntact = true
            break
        end
    end

    if not foundIntact then
        return false, "Markdown link was split across chunks"
    end

    return true, "Markdown link preserved"
end

local function TestListIntegrity()
    local limit = CM.constants.CHUNKING.COPY_LIMIT or 5700
    local padding = CreateLongString("P", limit - 100)
    local listBlock = "- Item one\n- Item two\n- Item three\n- Item four\n"
    local input = padding .. "\n" .. listBlock

    local chunks = CM.utils.Chunking.SplitMarkdownIntoChunks(input)
    local foundIntact = false
    for _, chunk in ipairs(chunks) do
        if chunk.content:find(listBlock, 1, true) then
            foundIntact = true
            break
        end
    end

    if not foundIntact then
        return false, "List was split across chunks"
    end

    return true, "List preserved"
end

local function TestResponsiveGridIntegrity()
    local limit = CM.constants.CHUNKING.COPY_LIMIT or 5700
    local padding = CreateLongString("P", limit - 100)
    local gridBlock = '<div style="display: grid; grid-template-columns: 1fr 1fr;">\n'
        .. "<div>Column A</div>\n<div>Column B</div>\n</div>\n"
    local input = padding .. "\n" .. gridBlock

    local chunks = CM.utils.Chunking.SplitMarkdownIntoChunks(input)
    local foundIntact = false
    for _, chunk in ipairs(chunks) do
        if chunk.content:find(gridBlock, 1, true) then
            foundIntact = true
            break
        end
    end

    if not foundIntact then
        return false, "Responsive grid HTML was split across chunks"
    end

    return true, "Responsive grid preserved"
end

local function TestTableIntegrity()
    local limit = CM.constants.CHUNKING.COPY_LIMIT or 5700
    local padding = CreateLongString("P", limit - 100)

    local tableBlock = "| Header 1 | Header 2 |\n| --- | --- |\n"
    for i = 1, 10 do
        tableBlock = tableBlock .. "| Row " .. i .. " | Data " .. i .. " |\n"
    end

    local input = padding .. "\n" .. tableBlock

    local chunks = CM.utils.Chunking.SplitMarkdownIntoChunks(input)

    local foundIntact = false
    for _, chunk in ipairs(chunks) do
        if chunk.content:find(tableBlock, 1, true) then
            foundIntact = true
            break
        end
    end

    if not foundIntact then
        return false, "Table was split across chunks"
    end

    return true, "Table preserved"
end

local function TestAdjacentMermaidFenceBoundary()
    local limit = CM.constants.CHUNKING.COPY_LIMIT or 5700
    local block1 = "```mermaid\nflowchart LR\n" .. CreateLongString("A", 400) .. "\n```"
    local block2 = "```mermaid\nflowchart LR\n  subgraph subLEGEND\n    LEG1\n  end\n```"
    -- Force a split near the boundary between two fenced mermaid blocks
    local padding = CreateLongString("P", limit - 150)
    local input = padding .. "\n\n" .. block1 .. "\n\n" .. block2

    local chunks = CM.utils.Chunking.SplitMarkdownIntoChunks(input)
    if #chunks < 2 then
        return false, "Expected multiple chunks for adjacent mermaid fence test"
    end

    for i, chunk in ipairs(chunks) do
        local content = StripChunkForCompare(chunk.content, i == #chunks)
        if content:match("\nmermaid\n") or content:match("^mermaid\n") then
            return false, string_format("Chunk %d contains bare 'mermaid' line (corrupted fence)", i)
        end
        if content:find("mermaid", 1, true) and not content:find("```mermaid", 1, true) then
            return false, string_format("Chunk %d has mermaid text without ```mermaid opener", i)
        end
    end

    return true, "Adjacent mermaid fences not corrupted at chunk boundaries"
end

local function TestSingleMermaidWithLegendSubgraph()
    local limit = CM.constants.CHUNKING.COPY_LIMIT or 5700
    local diagram = "```mermaid\nflowchart LR\n"
        .. "  subgraph subCRAFT\n    C1\n  end\n"
        .. "  subgraph subLEGEND\n    LEG1\n  end\n"
        .. "```"
    local padding = CreateLongString("P", limit - 100)
    local input = padding .. "\n\n" .. diagram

    local chunks = CM.utils.Chunking.SplitMarkdownIntoChunks(input)

    for i, chunk in ipairs(chunks) do
        local content = StripChunkForCompare(chunk.content, i == #chunks)
        if content:match("\nmermaid\n") or content:match("^mermaid\n") then
            return false, string_format("Chunk %d contains bare 'mermaid' line", i)
        end
    end

    local reassembled = ""
    for i, chunk in ipairs(chunks) do
        reassembled = reassembled .. StripChunkForCompare(chunk.content, i == #chunks)
    end

    if not reassembled:find("subLEGEND", 1, true) then
        return false, "Legend subgraph lost after chunk reassembly"
    end

    return true, "Single mermaid block with legend subgraph preserved"
end

-- =====================================================
-- RUNNER
-- =====================================================

function CM.tests.chunking.RunTests()
    CM.Info("|cFFFF00=== CHUNKING TESTS ===|r")

    local tests = {
        { name = "Basic Splitting", func = TestBasicSplitting },
        { name = "Chunk Size Limits", func = TestChunkSizeLimits },
        { name = "Chunk Markers And Padding", func = TestChunkMarkersAndPadding },
        { name = "HTML Block Integrity", func = TestHtmlBlockIntegrity },
        { name = "Mermaid Block Integrity", func = TestMermaidBlockIntegrity },
        { name = "Adjacent Mermaid Fence Boundary", func = TestAdjacentMermaidFenceBoundary },
        { name = "Single Mermaid With Legend Subgraph", func = TestSingleMermaidWithLegendSubgraph },
        { name = "Table Integrity", func = TestTableIntegrity },
        { name = "List Integrity", func = TestListIntegrity },
        { name = "Markdown Link Integrity", func = TestMarkdownLinkIntegrity },
        { name = "Responsive Grid Integrity", func = TestResponsiveGridIntegrity },
        { name = "Padding Consistency", func = TestPaddingConsistency },
    }

    local passed = 0
    local failed = 0

    for _, test in ipairs(tests) do
        local success, msg = test.func()
        if success then
            CM.Info(string_format("|c00FF00✅ %s: %s|r", test.name, msg))
            passed = passed + 1
        else
            CM.Info(string_format("|cFF0000❌ %s: %s|r", test.name, msg))
            failed = failed + 1
        end
    end

    CM.Info(string_format("Chunking Tests: %d passed, %d failed", passed, failed))

    return { passed = passed, failed = failed }
end

CM.DebugPrint("TESTS", "Chunking tests loaded")
