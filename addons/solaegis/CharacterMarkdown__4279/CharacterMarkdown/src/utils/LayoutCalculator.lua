-- CharacterMarkdown - Layout Calculator Utility
-- Calculates optimal CSS Grid parameters for responsive column layouts

local CM = CharacterMarkdown
CM.utils = CM.utils or {}
CM.utils.LayoutCalculator = CM.utils.LayoutCalculator or {}

-- Localize frequently used functions for performance
local math_max = math.max
local math_min = math.min
local math_floor = math.floor

-- Constants for layout calculation
local MIN_WIDTH_PX = 250 -- Minimum column width for readability
local MAX_WIDTH_PX = 450 -- Maximum column width to prevent overly wide columns
local DEFAULT_GAP = "20px"
local CHARS_PER_PX = 0.15 -- Approximate conversion factor (characters to pixels)

--[[
    Calculate optimal layout parameters for a set of tables

    Algorithm:
    1. Analyze all tables to get width/row estimates
    2. Calculate widest table (sets baseline minWidth)
    3. Calculate median table width (balance target)
    4. Determine optimal column count based on item count and balance
    5. Adjust minWidth to ensure visual balance (prevent one wide + many narrow)
    6. Apply constraints (min/max for readability)

    @param tableArray table - Array of markdown table strings (already generated)
    @param options table - Optional configuration:
        - minItems: number - Minimum items to trigger multi-column (default: 2)
        - maxColumns: number - Maximum columns to use (default: 4)
        - targetWidth: number - Target width in pixels (default: auto-calculate)
        - balanceThreshold: number - Ratio threshold for balance (default: 0.7)
        - gap: string - Gap between columns (default: "20px")

    @return table - { minWidth = "XXXpx", gap = "XXpx", columnCount = N, metadata = {...} }
]]
local function CalculateOptimalLayout(tableArray, options)
    -- Validate input
    if not tableArray or #tableArray == 0 then
        return {
            minWidth = MIN_WIDTH_PX .. "px",
            gap = DEFAULT_GAP,
            columnCount = 1,
            metadata = { reason = "empty_input" },
        }
    end

    -- Parse options with defaults
    options = options or {}
    local minItems = options.minItems or 2
    local maxColumns = options.maxColumns or 4
    local balanceThreshold = options.balanceThreshold or 0.7
    local gap = options.gap or DEFAULT_GAP

    -- Single table - no need for complex calculation
    if #tableArray < minItems then
        return {
            minWidth = MIN_WIDTH_PX .. "px",
            gap = gap,
            columnCount = 1,
            metadata = { reason = "below_min_items", count = #tableArray },
        }
    end

    -- Analyze tables using TableAnalyzer
    local TableAnalyzer = CM.utils.TableAnalyzer
    if not TableAnalyzer or not TableAnalyzer.AnalyzeTables then
        -- Fallback to simple heuristic if analyzer not available
        local simpleMinWidth = #tableArray > 6 and 350 or 300
        return {
            minWidth = simpleMinWidth .. "px",
            gap = gap,
            columnCount = math_min(#tableArray, maxColumns),
            metadata = { reason = "no_analyzer", fallback = true },
        }
    end

    local analysis = TableAnalyzer.AnalyzeTables(tableArray)
    local stats = analysis.stats

    -- If all tables are empty, use default
    if stats.maxWidth == 0 then
        return {
            minWidth = MIN_WIDTH_PX .. "px",
            gap = gap,
            columnCount = 1,
            metadata = { reason = "empty_tables" },
        }
    end

    -- STEP 1: Calculate baseline minWidth from widest table
    local widestCharWidth = stats.maxWidth
    local baselineWidth = math_floor(widestCharWidth * CHARS_PER_PX)

    -- STEP 2: Calculate median width for balance target
    local medianCharWidth = stats.medianWidth
    local medianWidth = math_floor(medianCharWidth * CHARS_PER_PX)

    -- STEP 3: Determine optimal column count
    -- Start with item count divided by a reasonable factor
    local itemCount = #tableArray
    local idealColumns = 1

    if itemCount >= 12 then
        idealColumns = 4
    elseif itemCount >= 6 then
        idealColumns = 3
    elseif itemCount >= 2 then
        idealColumns = 2
    end

    -- Cap at maxColumns
    idealColumns = math_min(idealColumns, maxColumns)

    -- STEP 4: Adjust minWidth for visual balance
    -- If there's high width variance, increase minWidth to prevent extreme differences
    local widthRatio = stats.minWidth > 0 and (stats.minWidth / stats.maxWidth) or 0

    local adjustedWidth

    if widthRatio < balanceThreshold then
        -- High variance detected - use median to balance
        -- Blend between median and max to prevent too-narrow columns
        adjustedWidth = math_floor((medianWidth * 0.6) + (baselineWidth * 0.4))
    else
        -- Low variance - tables are similar sizes
        -- Use median as it represents most tables better
        adjustedWidth = medianWidth
    end

    -- STEP 5: Apply constraints
    adjustedWidth = math_max(MIN_WIDTH_PX, adjustedWidth)
    adjustedWidth = math_min(MAX_WIDTH_PX, adjustedWidth)

    -- STEP 6: Smart column count adjustment based on final width
    -- If adjusted width is large, reduce columns to avoid forcing too many
    local finalColumns = idealColumns
    if adjustedWidth > 380 and itemCount < 8 then
        finalColumns = math_min(finalColumns, 2)
    end

    return {
        minWidth = adjustedWidth .. "px",
        gap = gap,
        columnCount = finalColumns,
        metadata = {
            reason = "calculated",
            itemCount = itemCount,
            widthRatio = widthRatio,
            baselineWidth = baselineWidth,
            medianWidth = medianWidth,
            adjustedWidth = adjustedWidth,
            stats = stats,
        },
    }
end

CM.utils.LayoutCalculator.CalculateOptimalLayout = CalculateOptimalLayout

--[[
    Convenience wrapper that calculates layout and formats for CreateResponsiveColumns
    @param tableArray table - Array of markdown table strings
    @param options table - Optional configuration (same as CalculateOptimalLayout)
    @return minWidth string, gap string - Ready to pass to CreateResponsiveColumns
]]
local function GetLayoutParams(tableArray, options)
    local layout = CalculateOptimalLayout(tableArray, options)
    return layout.minWidth, layout.gap
end

CM.utils.LayoutCalculator.GetLayoutParams = GetLayoutParams

--[[
    Get layout parameters with fallback
    Returns calculated values or provided fallback values if calculation fails
    @param tableArray table - Array of markdown table strings
    @param fallbackMinWidth string - Fallback minWidth (default: "300px")
    @param fallbackGap string - Fallback gap (default: "20px")
    @param options table - Optional configuration
    @return minWidth string, gap string
]]
local function GetLayoutParamsWithFallback(tableArray, fallbackMinWidth, fallbackGap, options)
    fallbackMinWidth = fallbackMinWidth or "300px"
    fallbackGap = fallbackGap or "20px"

    -- Try to calculate
    local success, layout = pcall(CalculateOptimalLayout, tableArray, options)

    if success and layout and layout.minWidth then
        return layout.minWidth, layout.gap
    else
        -- Return fallback on error
        if not success then
            CM.DebugPrint("LAYOUT", "Layout calculation failed, using fallback: " .. tostring(layout))
        end
        return fallbackMinWidth, fallbackGap
    end
end

CM.utils.LayoutCalculator.GetLayoutParamsWithFallback = GetLayoutParamsWithFallback

-- =====================================================
-- MODULE INITIALIZATION
-- =====================================================

CM.DebugPrint("UTILS", "LayoutCalculator module loaded with smart column layout calculation")

-- Functions are already exported to CM.utils.LayoutCalculator above
