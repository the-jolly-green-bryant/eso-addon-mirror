
local addonName = "Nvk3UT"

Nvk3UT = Nvk3UT or {}

local Layout = {}
Layout.__index = Layout

local MODULE_TAG = addonName .. ".EndeavorTrackerLayout"

local CATEGORY_HEADER_HEIGHT = 26
local SECTION_ROW_HEIGHT = 24
local HEADER_TO_ROWS_GAP = 3
local ROW_GAP = 3
local SECTION_BOTTOM_GAP = 3
local SECTION_BOTTOM_GAP_COLLAPSED = 3
local BOTTOM_PIXEL_NUDGE = 3 -- Endeavor-only visual match to Quest/Achievement

local lastHeight = 0

local function safeDebug(fmt, ...)
    local root = rawget(_G, addonName)
    if type(root) ~= "table" then
        return
    end

    local diagnostics = root.Diagnostics
    if diagnostics and type(diagnostics.DebugIfEnabled) == "function" then
        diagnostics:DebugIfEnabled("EndeavorTrackerLayout", fmt, ...)
        return
    end

    if fmt == nil then
        return
    end

    local message = string.format(tostring(fmt), ...)
    local prefix = string.format("[%s]", MODULE_TAG)
    if type(root.Debug) == "function" then
        root:Debug("%s %s", prefix, message)
    elseif type(d) == "function" then
        d(prefix, message)
    elseif type(print) == "function" then
        print(prefix, message)
    end
end

local function coerceHeight(value)
    if type(value) == "number" then
        if value ~= value then
            return 0
        end
        return value
    end

    return 0
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

    return fallback or 0
end

local function shouldExpand(entry)
    return type(entry) == "table" and entry.expanded == true
end

function Layout.Init()
    lastHeight = 0
end

function Layout.Apply(container, context)
    local measured = 0
    if container == nil then
        lastHeight = 0
        return 0
    end

    if container.SetResizeToFitDescendents then
        container:SetResizeToFitDescendents(false)
    end
    if container.SetInsets then
        container:SetInsets(0, 0, 0, 0)
    end

    local previous
    local previousKind
    local visibleCount = 0
    local rowCount = 0

    local function anchor(control, offsetY)
        if not control then
            return
        end

        if control.ClearAnchors then
            control:ClearAnchors()
        end

        if previous then
            local gap = offsetY or ROW_GAP
            control:SetAnchor(TOPLEFT, previous, BOTTOMLEFT, 0, gap)
            control:SetAnchor(TOPRIGHT, previous, BOTTOMRIGHT, 0, gap)
        else
            control:SetAnchor(TOPLEFT, container, TOPLEFT, 0, 0)
            control:SetAnchor(TOPRIGHT, container, TOPRIGHT, 0, 0)
        end

        previous = control
    end

    local function addControl(control, fallbackHeight, kind)
        if not control then
            return
        end

        if control.SetHidden then
            control:SetHidden(false)
        end

        local gap = 0
        if visibleCount > 0 then
            if previousKind == "header" then
                gap = HEADER_TO_ROWS_GAP
            else
                gap = ROW_GAP
            end
            measured = measured + gap
        end

        anchor(control, gap)

        measured = measured + getControlHeight(control, fallbackHeight)
        visibleCount = visibleCount + 1
        previousKind = kind

        if kind ~= "header" then
            rowCount = rowCount + 1
        end
    end

    local data = type(context) == "table" and context or {}

    local sectionEntry = type(data.section) == "table" and data.section or {}
    local hideEntireSection = sectionEntry.hideEntireSection == true

    if hideEntireSection then
        if container then
            if container.SetHidden then
                container:SetHidden(true)
            end
            container._nvk3utAutoHidden = true
            if container.SetHeight then
                container:SetHeight(0)
            end
            if container.SetDimensions then
                local width
                if container.GetWidth then
                    local ok, currentWidth = pcall(container.GetWidth, container)
                    if ok and type(currentWidth) == "number" then
                        width = currentWidth
                    end
                end
                if type(width) == "number" and width > 0 then
                    container:SetDimensions(width, 0)
                end
            end
        end

        lastHeight = 0
        safeDebug("EndeavorTrackerLayout.Apply: hidden section (height=0)")
        return 0
    end

    if container then
        container._nvk3utAutoHidden = nil
    end

    local categoryEntry = type(data.category) == "table" and data.category or {}
    local categoryControl = categoryEntry.control
    if categoryControl then
        addControl(categoryControl, CATEGORY_HEADER_HEIGHT, "header")
    end

    local categoryExpanded = data.categoryExpanded == true

    local dailyEntry = type(data.daily) == "table" and data.daily or {}
    local dailyControl = dailyEntry.control
    local dailyHidden = dailyEntry.hideRow == true
    local dailyObjectivesHidden = dailyEntry.hideObjectives == true
    local dailyObjectivesEntry = type(data.dailyObjectives) == "table" and data.dailyObjectives or {}
    local dailyObjectivesControl = dailyObjectivesEntry.control

    local weeklyEntry = type(data.weekly) == "table" and data.weekly or {}
    local weeklyControl = weeklyEntry.control
    local weeklyHidden = weeklyEntry.hideRow == true
    local weeklyObjectivesHidden = weeklyEntry.hideObjectives == true
    local weeklyObjectivesEntry = type(data.weeklyObjectives) == "table" and data.weeklyObjectives or {}
    local weeklyObjectivesControl = weeklyObjectivesEntry.control

    if categoryExpanded then
        if dailyControl and not dailyHidden then
            addControl(dailyControl, SECTION_ROW_HEIGHT, "row")
        end

        if dailyObjectivesControl and not dailyHidden and not dailyObjectivesHidden then
            if shouldExpand(dailyObjectivesEntry) then
                addControl(dailyObjectivesControl, 0, "row")
            elseif dailyObjectivesControl.SetHidden then
                dailyObjectivesControl:SetHidden(true)
            end
        elseif dailyObjectivesControl and dailyObjectivesControl.SetHidden then
            dailyObjectivesControl:SetHidden(true)
        end

        if weeklyControl and not weeklyHidden then
            addControl(weeklyControl, SECTION_ROW_HEIGHT, "row")
        end

        if weeklyObjectivesControl and not weeklyHidden and not weeklyObjectivesHidden then
            if shouldExpand(weeklyObjectivesEntry) then
                addControl(weeklyObjectivesControl, 0, "row")
            elseif weeklyObjectivesControl.SetHidden then
                weeklyObjectivesControl:SetHidden(true)
            end
        elseif weeklyObjectivesControl and weeklyObjectivesControl.SetHidden then
            weeklyObjectivesControl:SetHidden(true)
        end
    else
        if dailyControl and dailyControl.SetHidden then
            dailyControl:SetHidden(true)
        end
        if dailyObjectivesControl and dailyObjectivesControl.SetHidden then
            dailyObjectivesControl:SetHidden(true)
        end
        if weeklyControl and weeklyControl.SetHidden then
            weeklyControl:SetHidden(true)
        end
        if weeklyObjectivesControl and weeklyObjectivesControl.SetHidden then
            weeklyObjectivesControl:SetHidden(true)
        end
    end

    if categoryExpanded and rowCount > 0 then
        measured = measured + SECTION_BOTTOM_GAP
    elseif visibleCount > 0 then
        measured = measured + SECTION_BOTTOM_GAP_COLLAPSED
    end

    if visibleCount > 0 then
        measured = measured + BOTTOM_PIXEL_NUDGE
    end

    if container then
        if container.SetHeight then
            container:SetHeight(measured)
        end
        if container.SetDimensions then
            local width
            if container.GetWidth then
                local ok, w = pcall(container.GetWidth, container)
                if ok and type(w) == "number" then
                    width = w
                end
            end
            local resolvedWidth = width
            if type(resolvedWidth) ~= "number" or resolvedWidth <= 0 then
                if container.GetWidth then
                    local ok, currentWidth = pcall(container.GetWidth, container)
                    if ok and type(currentWidth) == "number" then
                        resolvedWidth = currentWidth
                    end
                end
            end
            if type(resolvedWidth) == "number" and resolvedWidth > 0 then
                container:SetDimensions(resolvedWidth, measured)
            end
        end
    end

    lastHeight = measured

    safeDebug("EndeavorTrackerLayout.Apply: height=%d", measured)

    return measured
end

function Layout.GetLastHeight()
    return coerceHeight(lastHeight)
end

Nvk3UT.EndeavorTrackerLayout = Layout

return Layout
