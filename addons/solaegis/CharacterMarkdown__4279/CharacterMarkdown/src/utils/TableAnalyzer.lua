-- CharacterMarkdown - Table Analyzer Utility
-- Analyzes markdown table strings to extract metadata for optimal layout calculation

local CM = CharacterMarkdown
CM.utils = CM.utils or {}
CM.utils.TableAnalyzer = CM.utils.TableAnalyzer or {}

-- Localize frequently used functions for performance
local string_match = string.match
local string_gmatch = string.gmatch
local string_len = string.len
local string_gsub = string.gsub
local math_max = math.max
local math_floor = math.floor
local table_insert = table.insert
local table_sort = table.sort

--[[
    Estimate the display width of a markdown table
    Analyzes the longest line to determine approximate rendered width
    @param tableMarkdown string - Complete markdown table (including headers, separators, data)
    @return number - Estimated width in characters
]]
local function EstimateTableWidth(tableMarkdown)
    if not tableMarkdown or tableMarkdown == "" then
        return 0
    end

    local maxWidth = 0

    -- Find longest line in the table
    for line in string_gmatch(tableMarkdown, "[^\r\n]+") do
        -- Skip HTML tags (for VSCode format)
        if not string_match(line, "^%s*<") then
            local lineLength = string_len(line)
            maxWidth = math_max(maxWidth, lineLength)
        end
    end

    return maxWidth
end

CM.utils.TableAnalyzer.EstimateTableWidth = EstimateTableWidth

--[[
    Count data rows in a markdown table (excluding header and separator)
    @param tableMarkdown string - Complete markdown table
    @return number - Number of data rows
]]
local function CountTableRows(tableMarkdown)
    if not tableMarkdown or tableMarkdown == "" then
        return 0
    end

    local rowCount = 0
    local lineNum = 0

    for line in string_gmatch(tableMarkdown, "[^\r\n]+") do
        lineNum = lineNum + 1

        -- Skip empty lines, HTML tags, headers
        if string_match(line, "^%s*|") then
            -- Skip first line (header) and second line (separator)
            if lineNum > 2 then
                -- Check if it's a separator line (contains only |, -, :, and whitespace)
                if not string_match(line, "^[|%s:%-]+$") then
                    rowCount = rowCount + 1
                end
            end
        end
    end

    return rowCount
end

CM.utils.TableAnalyzer.CountTableRows = CountTableRows

--[[
    Extract headers from a markdown table
    @param tableMarkdown string - Complete markdown table
    @return table - Array of header strings
]]
local function ExtractTableHeaders(tableMarkdown)
    if not tableMarkdown or tableMarkdown == "" then
        return {}
    end

    -- Find first line that starts with |
    for line in string_gmatch(tableMarkdown, "[^\r\n]+") do
        if string_match(line, "^%s*|") then
            local headers = {}

            -- Split by | and extract headers
            for header in string_gmatch(line, "|([^|]+)") do
                -- Trim whitespace and remove markdown formatting
                header = string_gsub(header, "^%s*(.-)%s*$", "%1")
                header = string_gsub(header, "%*%*(.-)%*%*", "%1") -- Remove **bold**
                header = string_gsub(header, "%*(.-)%*", "%1") -- Remove *italic*
                header = string_gsub(header, "<strong>(.-)</strong>", "%1") -- Remove HTML bold

                if header ~= "" then
                    table_insert(headers, header)
                end
            end

            return headers
        end
    end

    return {}
end

CM.utils.TableAnalyzer.ExtractTableHeaders = ExtractTableHeaders

--[[
    Analyze a single table to extract comprehensive metadata
    @param tableMarkdown string - Complete markdown table
    @return table - Metadata: { width, rows, headers, hasHeader, isEmpty }
]]
local function AnalyzeTable(tableMarkdown)
    if not tableMarkdown or tableMarkdown == "" then
        return {
            width = 0,
            rows = 0,
            headers = {},
            hasHeader = false,
            isEmpty = true,
        }
    end

    local width = EstimateTableWidth(tableMarkdown)
    local rows = CountTableRows(tableMarkdown)
    local headers = ExtractTableHeaders(tableMarkdown)

    return {
        width = width,
        rows = rows,
        headers = headers,
        hasHeader = #headers > 0,
        isEmpty = width == 0 or rows == 0,
    }
end

CM.utils.TableAnalyzer.AnalyzeTable = AnalyzeTable

--[[
    Batch analyze an array of tables
    Returns metadata for each table plus aggregate statistics
    @param tableArray table - Array of markdown table strings
    @return table - { tables = {...}, stats = { maxWidth, minWidth, medianWidth, totalRows, avgRows } }
]]
local function AnalyzeTables(tableArray)
    if not tableArray or #tableArray == 0 then
        return {
            tables = {},
            stats = {
                maxWidth = 0,
                minWidth = 0,
                medianWidth = 0,
                totalRows = 0,
                avgRows = 0,
                count = 0,
            },
        }
    end

    local tables = {}
    local widths = {}
    local totalRows = 0
    local maxWidth = 0
    local minWidth = 999999

    -- Analyze each table
    for _, tableMarkdown in ipairs(tableArray) do
        local metadata = AnalyzeTable(tableMarkdown)
        table_insert(tables, metadata)

        if not metadata.isEmpty then
            table_insert(widths, metadata.width)
            totalRows = totalRows + metadata.rows
            maxWidth = math_max(maxWidth, metadata.width)
            minWidth = math.min(minWidth, metadata.width)
        end
    end

    -- Calculate median width
    local medianWidth = 0
    if #widths > 0 then
        table_sort(widths)
        local midIndex = math_floor(#widths / 2) + 1
        medianWidth = widths[midIndex] or 0
    end

    -- Calculate average rows
    local avgRows = #tables > 0 and (totalRows / #tables) or 0

    return {
        tables = tables,
        stats = {
            maxWidth = maxWidth,
            minWidth = minWidth == 999999 and 0 or minWidth,
            medianWidth = medianWidth,
            totalRows = totalRows,
            avgRows = avgRows,
            count = #tables,
        },
    }
end

CM.utils.TableAnalyzer.AnalyzeTables = AnalyzeTables

-- =====================================================
-- MODULE INITIALIZATION
-- =====================================================

CM.DebugPrint("UTILS", "TableAnalyzer module loaded with table metadata extraction functions")

-- Functions are already exported to CM.utils.TableAnalyzer above
