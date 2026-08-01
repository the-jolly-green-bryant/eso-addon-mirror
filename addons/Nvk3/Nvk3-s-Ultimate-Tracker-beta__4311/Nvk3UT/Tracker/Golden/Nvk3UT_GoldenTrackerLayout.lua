local addonName = "Nvk3UT"

Nvk3UT = Nvk3UT or {}

local Layout = {}
Layout.__index = Layout

local MODULE_TAG = addonName .. ".GoldenTrackerLayout"

local CATEGORY_HEADER_HEIGHT = 26
local ENTRY_ROW_HEIGHT = 24
local OBJECTIVE_ROW_HEIGHT = 18
local HEADER_TO_ROWS_GAP = 3
local ENTRY_ROW_SPACING = 3
local CATEGORY_ENTRY_SPACING = 3
local CATEGORY_BOTTOM_PAD_EXPANDED = 6
local CATEGORY_BOTTOM_PAD_COLLAPSED = 6
local CATEGORY_SPACING_ABOVE = 3
local CATEGORY_SPACING_BELOW = 6
local ENTRY_SPACING_ABOVE = ENTRY_ROW_SPACING
local ENTRY_SPACING_BELOW = ENTRY_ROW_SPACING
local OBJECTIVE_SPACING_ABOVE = 3
local OBJECTIVE_SPACING_BELOW = 3
local OBJECTIVE_SPACING_BETWEEN = 1
local CATEGORY_TEXT_PADDING_Y = 4
local BOTTOM_PIXEL_NUDGE = 3
local Rows = Nvk3UT and Nvk3UT.GoldenTrackerRows

local function safeDebug(message, ...)
    local debugFn = Nvk3UT and Nvk3UT.Debug
    if type(debugFn) ~= "function" then
        return
    end

    local payload = message
    if select("#", ...) > 0 then
        local ok, formatted = pcall(string.format, message, ...)
        if ok then
            payload = formatted
        end
    end

    pcall(debugFn, string.format("%s: %s", MODULE_TAG, tostring(payload)))
end

local function getRowsModule()
    if type(Rows) == "table" then
        return Rows
    end

    Rows = Nvk3UT and Nvk3UT.GoldenTrackerRows
    if type(Rows) == "table" then
        return Rows
    end

    return nil
end

local function getParentWidth(control)
    if not control or type(control.GetWidth) ~= "function" then
        return 0
    end

    local ok, width = pcall(control.GetWidth, control)
    if ok and type(width) == "number" then
        return width
    end

    return 0
end

local function coerceHeight(value)
    local numeric = tonumber(value)
    if numeric == nil or numeric ~= numeric then
        return 0
    end

    if numeric < 0 then
        numeric = 0
    end

    return numeric
end

local function normalizeSpacingValue(value, fallback)
    local numeric = tonumber(value)
    if numeric == nil or numeric ~= numeric then
        return fallback
    end
    if numeric < 0 then
        return fallback
    end
    return numeric
end

local function applyCategorySpacingFromSaved()
    local addon = Nvk3UT
    local sv = addon and addon.SV
    local spacing = sv and sv.spacing
    local goldenSpacing = spacing and spacing.golden
    local category = goldenSpacing and goldenSpacing.category

    CATEGORY_SPACING_ABOVE = normalizeSpacingValue(category and category.spacingAbove, CATEGORY_SPACING_ABOVE)
    CATEGORY_SPACING_BELOW = normalizeSpacingValue(category and category.spacingBelow, CATEGORY_SPACING_BELOW)
end

local function applyEntrySpacingFromSaved()
    local addon = Nvk3UT
    local sv = addon and addon.SV
    local spacing = sv and sv.spacing
    local goldenSpacing = spacing and spacing.golden
    local entry = goldenSpacing and goldenSpacing.entry

    ENTRY_SPACING_ABOVE = normalizeSpacingValue(entry and entry.spacingAbove, ENTRY_SPACING_ABOVE)
    ENTRY_SPACING_BELOW = normalizeSpacingValue(entry and entry.spacingBelow, ENTRY_SPACING_BELOW)
end

local function applyObjectiveSpacingFromSaved()
    local addon = Nvk3UT
    local sv = addon and addon.SV
    local spacing = sv and sv.spacing
    local goldenSpacing = spacing and spacing.golden
    local objective = goldenSpacing and goldenSpacing.objective

    OBJECTIVE_SPACING_ABOVE = normalizeSpacingValue(objective and objective.spacingAbove, OBJECTIVE_SPACING_ABOVE)
    OBJECTIVE_SPACING_BELOW = normalizeSpacingValue(objective and objective.spacingBelow, OBJECTIVE_SPACING_BELOW)
    OBJECTIVE_SPACING_BETWEEN = normalizeSpacingValue(objective and objective.spacingBetween, OBJECTIVE_SPACING_BETWEEN)
end

local function getControlHeight(control, fallback)
    if control and type(control.GetHeight) == "function" then
        local ok, height = pcall(control.GetHeight, control)
        if ok then
            local measured = coerceHeight(height)
            if measured > 0 then
                return measured
            end
        end
    end

    return coerceHeight(fallback)
end

local function getCategoryTextHeight(control, rowData)
    local label = nil
    if type(rowData) == "table" then
        label = rowData.label
    end
    if not label and type(control) == "table" then
        label = control.label
    end

    if label and type(label.GetTextHeight) == "function" then
        local ok, height = pcall(label.GetTextHeight, label)
        if ok then
            local measured = coerceHeight(height)
            if measured > 0 then
                return measured
            end
        end
    end

    return 0
end

local function resolveRowKind(control, rowData)
    if type(rowData) == "table" and rowData.__rowKind then
        return rowData.__rowKind
    end

    if type(rowData) == "table" and rowData.control and rowData.control.__rowKind then
        return rowData.control.__rowKind
    end

    if control and control.__rowKind then
        return control.__rowKind
    end

    return nil
end

local resolveRowHeight

local function resolveCategoryHeight(control, rowData)
    local baseHeight = resolveRowHeight(control, rowData)
    local textHeight = getCategoryTextHeight(control, rowData)
    if textHeight > 0 then
        baseHeight = math.max(baseHeight, textHeight + CATEGORY_TEXT_PADDING_Y)
    end
    return baseHeight
end

resolveRowHeight = function(control, rowData)
    local rowsModule = getRowsModule()
    local kind = resolveRowKind(control, rowData)
    local fallback

    if rowsModule then
        if kind == "category" and type(rowsModule.GetCategoryRowHeight) == "function" then
            fallback = rowsModule.GetCategoryRowHeight()
        elseif kind == "entry" and type(rowsModule.GetEntryRowHeight) == "function" then
            fallback = rowsModule.GetEntryRowHeight()
        elseif kind == "objective" and type(rowsModule.GetObjectiveRowHeight) == "function" then
            fallback = rowsModule.GetObjectiveRowHeight()
        end
    end

    if fallback == nil then
        fallback = (rowData and rowData.__height) or (control and control.__height) or 0
    end

    return getControlHeight(control, fallback)
end

local function applyDimensions(row, parentWidth, resolvedHeight)
    if not row then
        return
    end

    local height = coerceHeight(resolvedHeight or (row and row.__height))

    if row.SetDimensions then
        row:SetDimensions(parentWidth, height)
        return
    end

    if row.SetHeight then
        row:SetHeight(height)
    end
end

local function resolveControl(row)
    if type(row) == "table" and row.control then
        return row.control, row
    end

    return row, row
end

function Layout.ApplyLayout(parentControl, rows)
    if not parentControl then
        safeDebug("ApplyLayout abort: parent missing")
        return 0
    end

    applyCategorySpacingFromSaved()
    applyEntrySpacingFromSaved()
    applyObjectiveSpacingFromSaved()

    if type(rows) ~= "table" then
        rows = {}
    end

    safeDebug(
        "ApplyLayout parent=%s parentParent=%s rows=%d",
        parentControl.GetName and parentControl:GetName() or "<nil>",
        parentControl.GetParent and parentControl:GetParent() and parentControl:GetParent():GetName() or "<nil>",
        #rows
    )

    local totalHeight = 0
    local parentWidth = getParentWidth(parentControl)
    local previousRow = nil
    local previousKind = nil
    local visibleCount = 0
    local categoryHasHeader = false
    local categoryRowCount = 0
    local categoryExpanded = nil
    local pendingCategoryGap = 0
    local entryChildEndGap = 0
    local inEntryChildBlock = false
    local sawChildObjective = false
    local deferredPreGap = 0

    local function resolveCategoryExpanded(rowData)
        if type(rowData) == "table" then
            if rowData.__categoryExpanded ~= nil then
                return rowData.__categoryExpanded == true
            end

            if rowData._nvk3utCategoryExpanded ~= nil then
                return rowData._nvk3utCategoryExpanded == true
            end

            if rowData.categoryExpanded ~= nil then
                return rowData.categoryExpanded == true
            end

            if rowData.expanded ~= nil then
                return rowData.expanded == true
            end
        end

        return true
    end

    local function finalizeCategory()
        if not categoryHasHeader then
            return
        end

        pendingCategoryGap = CATEGORY_SPACING_BELOW
        categoryHasHeader = false
        categoryRowCount = 0
        categoryExpanded = nil
    end

    local function resolveFallbackHeight(kind)
        if kind == "category" then
            return CATEGORY_HEADER_HEIGHT
        elseif kind == "entry" then
            return ENTRY_ROW_HEIGHT
        elseif kind == "objective" then
            return OBJECTIVE_ROW_HEIGHT
        end

        return 0
    end

    local function addControl(control, rowData, kind)
        if not control then
            return
        end

        if type(control.SetParent) == "function" then
            control:SetParent(parentControl)
        end

        if type(control.SetHidden) == "function" then
            control:SetHidden(false)
        end

        if type(control.ClearAnchors) == "function" then
            control:ClearAnchors()
        end

        local gap = 0
        if kind == "category" then
            gap = CATEGORY_SPACING_ABOVE
        elseif kind == "entry" then
            if visibleCount > 0 then
                gap = ENTRY_SPACING_ABOVE
            end
        elseif kind == "objective" then
            if visibleCount > 0 then
                if previousKind == "objective" then
                    gap = OBJECTIVE_SPACING_BETWEEN
                else
                    gap = OBJECTIVE_SPACING_ABOVE
                end
            end
        elseif visibleCount > 0 then
            gap = ENTRY_ROW_SPACING
        end

        if pendingCategoryGap and pendingCategoryGap > 0 and visibleCount > 0 then
            gap = gap + pendingCategoryGap
            pendingCategoryGap = 0
        end

        if deferredPreGap > 0 and visibleCount > 0 then
            gap = gap + deferredPreGap
            deferredPreGap = 0
        end

        if visibleCount > 0 or gap > 0 then
            totalHeight = totalHeight + gap
        end

        if type(control.SetAnchor) == "function" then
            if previousRow then
                control:SetAnchor(TOPLEFT, previousRow, BOTTOMLEFT, 0, gap)
                control:SetAnchor(TOPRIGHT, previousRow, BOTTOMRIGHT, 0, gap)
            else
                control:SetAnchor(TOPLEFT, parentControl, TOPLEFT, 0, gap)
                control:SetAnchor(TOPRIGHT, parentControl, TOPRIGHT, 0, gap)
            end
        end

        local height = resolveRowHeight(control, rowData)
        if kind == "category" then
            height = resolveCategoryHeight(control, rowData)
        end
        if height <= 0 then
            height = resolveFallbackHeight(kind)
        end

        if control then
            if kind == "category" and control.SetResizeToFitDescendents then
                control:SetResizeToFitDescendents(false)
            end
            control.__height = height
        end

        applyDimensions(control, parentWidth, height)

        totalHeight = totalHeight + height
        visibleCount = visibleCount + 1
        previousRow = control
        previousKind = kind

        if kind ~= "header" and categoryHasHeader then
            categoryRowCount = categoryRowCount + 1
        end
    end

    for index = 1, #rows do
        local row = rows[index]
        local control, rowData = resolveControl(row)
        local kind = resolveRowKind(control, rowData)

        if inEntryChildBlock then
            if kind == "objective" then
                sawChildObjective = true
            else
                if sawChildObjective then
                    deferredPreGap = OBJECTIVE_SPACING_BELOW + entryChildEndGap
                elseif entryChildEndGap > 0 then
                    deferredPreGap = entryChildEndGap
                end
                entryChildEndGap = 0
                inEntryChildBlock = false
                sawChildObjective = false
            end
        end

        if kind == "category" then
            finalizeCategory()
            categoryHasHeader = true
            categoryRowCount = 0
            categoryExpanded = resolveCategoryExpanded(rowData)
        end

        if control and (type(control) == "userdata" or type(control) == "table") then
            addControl(control, rowData, kind or "row")
        end

        if kind == "entry" then
            inEntryChildBlock = true
            sawChildObjective = false
            entryChildEndGap = ENTRY_SPACING_BELOW
        end
    end

    finalizeCategory()

    if visibleCount > 0 then
        if pendingCategoryGap and pendingCategoryGap > 0 then
            totalHeight = totalHeight + pendingCategoryGap
            pendingCategoryGap = 0
        end
        if inEntryChildBlock and (sawChildObjective or entryChildEndGap > 0) then
            if sawChildObjective then
                totalHeight = totalHeight + OBJECTIVE_SPACING_BELOW + entryChildEndGap
            elseif entryChildEndGap > 0 then
                totalHeight = totalHeight + entryChildEndGap
            end
            entryChildEndGap = 0
            inEntryChildBlock = false
            sawChildObjective = false
        end
        totalHeight = totalHeight + BOTTOM_PIXEL_NUDGE
    end

    safeDebug("ApplyLayout rows=%d height=%d", #rows, totalHeight)

    return totalHeight
end

Nvk3UT.GoldenTrackerLayout = Layout

return Layout
