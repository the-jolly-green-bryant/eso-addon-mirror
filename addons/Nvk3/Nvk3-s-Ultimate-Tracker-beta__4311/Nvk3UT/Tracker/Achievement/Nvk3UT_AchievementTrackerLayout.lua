local addonName = "Nvk3UT"

Nvk3UT = Nvk3UT or {}

local Layout = {}
Layout.__index = Layout

local MODULE_TAG = addonName .. ".AchievementTrackerLayout"

local ROW_GAP = 3
local HEADER_TO_ROWS_GAP = 3
local ROW_TEXT_PADDING_Y = 4
local CATEGORY_MIN_HEIGHT = 26
local ACHIEVEMENT_MIN_HEIGHT = 24
local OBJECTIVE_MIN_HEIGHT = 20
local CATEGORY_BOTTOM_PAD_EXPANDED = 6
local CATEGORY_BOTTOM_PAD_COLLAPSED = 6
local BOTTOM_PIXEL_NUDGE = 0

local function logLoaded()
    local root = rawget(_G, addonName)
    if type(root) ~= "table" then
        return
    end

    local diagnostics = root.Diagnostics
    if diagnostics and type(diagnostics.DebugIfEnabled) == "function" then
        diagnostics:DebugIfEnabled(MODULE_TAG, "Loaded achievement tracker layout module")
    end
end

function Layout.GetVerticalPadding()
    return ROW_GAP
end

function Layout.GetRowTextPaddingY()
    return ROW_TEXT_PADDING_Y
end

function Layout.GetRowGap()
    return ROW_GAP
end

function Layout.GetHeaderToRowsGap()
    return HEADER_TO_ROWS_GAP
end

function Layout.GetCategoryMinHeight()
    return CATEGORY_MIN_HEIGHT
end

function Layout.GetAchievementMinHeight()
    return ACHIEVEMENT_MIN_HEIGHT
end

function Layout.GetObjectiveMinHeight()
    return OBJECTIVE_MIN_HEIGHT
end

function Layout.GetCategoryBottomPadding(isExpanded)
    if isExpanded then
        return CATEGORY_BOTTOM_PAD_EXPANDED
    end

    return CATEGORY_BOTTOM_PAD_COLLAPSED
end

function Layout.GetBottomPixelNudge()
    return BOTTOM_PIXEL_NUDGE
end

function Layout.GetRowMinHeight(rowType)
    if rowType == "category" then
        return Layout.GetCategoryMinHeight()
    elseif rowType == "achievement" then
        return Layout.GetAchievementMinHeight()
    elseif rowType == "objective" then
        return Layout.GetObjectiveMinHeight()
    end

    return 0
end

local function normalizeHeight(value)
    local numeric = tonumber(value)
    if not numeric then
        return 0
    end

    if numeric ~= numeric then
        return 0
    end

    if numeric < 0 then
        return 0
    end

    return numeric
end

function Layout.ComputeRowHeight(rowType, textHeight)
    local baseTextHeight = normalizeHeight(textHeight)
    local targetHeight = baseTextHeight + Layout.GetRowTextPaddingY()
    local minHeight = Layout.GetRowMinHeight(rowType)

    if minHeight > 0 then
        targetHeight = math.max(minHeight, targetHeight)
    end

    return targetHeight
end

local function normalizeSubrowCandidate(objective)
    if not objective then
        return nil
    end

    if objective.isVisible == false then
        return nil
    end

    if objective.isComplete then
        return nil
    end

    local maxValue = tonumber(objective.max)
    local currentValue = tonumber(objective.current)

    if maxValue and currentValue and maxValue > 0 and currentValue >= maxValue then
        return nil
    end

    local description = objective.description
    if description == nil or description == "" then
        return nil
    end

    return objective
end

function Layout.ComputeEntrySubrowCount(entry)
    if not entry then
        return 0
    end

    local objectives = entry.objectives
    if type(objectives) ~= "table" then
        return 0
    end

    local count = 0
    for index = 1, #objectives do
        if normalizeSubrowCandidate(objectives[index]) then
            count = count + 1
        end
    end

    return count
end

function Layout.ShouldDisplayObjective(objective)
    return normalizeSubrowCandidate(objective) ~= nil
end

local function getSubrowSpacing()
    return Layout.GetVerticalPadding()
end

local function computeSubrowHeight(rowType, textHeight)
    return Layout.ComputeRowHeight(rowType, textHeight)
end

function Layout.GetSubrowHeight(rowType, textHeight)
    return computeSubrowHeight(rowType, textHeight)
end

function Layout.GetSubrowSpacing()
    return getSubrowSpacing()
end

function Layout.ComputeEntryHeight(entry, baseRowHeight, subrowHeights)
    local totalHeight = normalizeHeight(baseRowHeight)
    local spacing = getSubrowSpacing()

    local objectives = entry and entry.objectives
    local hasObjectives = type(objectives) == "table"

    if hasObjectives and type(subrowHeights) == "table" then
        for index = 1, #subrowHeights do
            local subrowHeight = normalizeHeight(subrowHeights[index])
            if subrowHeight > 0 then
                if totalHeight > 0 then
                    totalHeight = totalHeight + spacing
                end
                totalHeight = totalHeight + subrowHeight
            end
        end
    end

    return totalHeight
end

function Layout.ComputeTotalHeight(rowHeights)
    local totalHeight = 0
    if type(rowHeights) ~= "table" then
        return totalHeight
    end

    local verticalPadding = Layout.GetVerticalPadding() or 0
    for index = 1, #rowHeights do
        local rowHeight = normalizeHeight(rowHeights[index])
        totalHeight = totalHeight + rowHeight

        if index > 1 then
            totalHeight = totalHeight + verticalPadding
        end
    end

    return totalHeight
end

function Layout.ComputeHeight(_, currentHeightFallback)
    if currentHeightFallback ~= nil then
        return currentHeightFallback
    end

    return 0
end

function Layout.Apply(_, _, currentHeightFallback)
    if currentHeightFallback ~= nil then
        return currentHeightFallback
    end

    return 0
end

logLoaded()

Nvk3UT.AchievementTrackerLayout = Layout

return Layout
