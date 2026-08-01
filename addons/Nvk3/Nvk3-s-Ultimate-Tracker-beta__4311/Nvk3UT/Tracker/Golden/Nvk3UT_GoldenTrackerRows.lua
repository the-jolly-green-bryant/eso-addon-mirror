local addonName = "Nvk3UT"

Nvk3UT = Nvk3UT or {}

local Rows = {}
Rows.__index = Rows

local MODULE_TAG = addonName .. ".GoldenTrackerRows"
local GOLDEN_COLOR_DEBUG_TAG = "GoldenColor"

local GOLDEN_COLOR_ROLES = {
    CategoryTitleClosed = "categoryTitleClosed",
    CategoryTitleOpen = "categoryTitleOpen",
    EntryName = "entryTitle",
    Objective = "objectiveText",
    Active = "activeTitle",
    Completed = "completed",
}

local DEFAULT_COLOR_KIND = "goldenTracker"
local DEFAULT_MOUSEOVER_HIGHLIGHT_COLOR = { 1, 1, 0.6, 1 }

local GOLDEN_COLOR_ROLE_LIST = {
    GOLDEN_COLOR_ROLES.CategoryTitleClosed,
    GOLDEN_COLOR_ROLES.CategoryTitleOpen,
    GOLDEN_COLOR_ROLES.EntryName,
    GOLDEN_COLOR_ROLES.Objective,
    GOLDEN_COLOR_ROLES.Active,
    GOLDEN_COLOR_ROLES.Completed,
}

local DEFAULT_GOLDEN_COLOR_VALUES = {
    [GOLDEN_COLOR_ROLES.CategoryTitleClosed] = { r = 0.7725, g = 0.7608, b = 0.6196, a = 1 },
    [GOLDEN_COLOR_ROLES.CategoryTitleOpen] = { r = 1, g = 1, b = 0, a = 1 },
    [GOLDEN_COLOR_ROLES.EntryName] = { r = 1, g = 1, b = 0, a = 1 },
    [GOLDEN_COLOR_ROLES.Objective] = { r = 0.7725, g = 0.7608, b = 0.6196, a = 1 },
    [GOLDEN_COLOR_ROLES.Active] = { r = 1, g = 1, b = 1, a = 1 },
    [GOLDEN_COLOR_ROLES.Completed] = { r = 0.6, g = 0.6, b = 0.6, a = 1 },
}

local DEFAULTS = {
    CATEGORY_HEIGHT = 26,
    ENTRY_HEIGHT = 24,
    OBJECTIVE_HEIGHT = 18,
    CATEGORY_FONT = "$(BOLD_FONT)|20|soft-shadow-thick",
    ENTRY_FONT = "$(BOLD_FONT)|16|soft-shadow-thick",
    OBJECTIVE_FONT = "$(BOLD_FONT)|14|soft-shadow-thick",
    OBJECTIVE_INDENT_X = 60,
    ENTRY_INDENT_X = 60,
    OBJECTIVE_PIN_MARKER_OFFSET_X = 10,
}

local SCROLLBAR_WIDTH_RESERVE = 18

local ROW_TEXT_PADDING_Y = 4
local OBJECTIVE_VERTICAL_PADDING_Y = 2

local GOLDEN_HEADER_TITLE = GetString(SI_NVK3UT_TRACKER_GOLDEN_CATEGORY_MAIN)

local CATEGORY_CHEVRON_SIZE = 20
local CATEGORY_LABEL_OFFSET_X = 4
local ENTRY_ICON_SLOT_X = 20
local ENTRY_INDENT_X = DEFAULTS.ENTRY_INDENT_X

local CATEGORY_CHEVRON_TEXTURES = {
    expanded = "EsoUI/Art/Buttons/tree_open_up.dds",
    collapsed = "EsoUI/Art/Buttons/tree_closed_up.dds",
}

local MOUSE_BUTTON_LEFT = rawget(_G, "MOUSE_BUTTON_INDEX_LEFT") or 1
local MOUSE_BUTTON_RIGHT = rawget(_G, "MOUSE_BUTTON_INDEX_RIGHT") or 2

local DEFAULT_FONT_OUTLINE = "soft-shadow-thick"
local DEFAULT_FONT_FACE = "$(BOLD_FONT)"
local MIN_FONT_SIZE = 12
local MAX_FONT_SIZE = 36

local GOLDEN_FONT_DEFAULTS = {
    Category = { face = DEFAULT_FONT_FACE, size = 20, outline = DEFAULT_FONT_OUTLINE },
    Title = { face = DEFAULT_FONT_FACE, size = 16, outline = DEFAULT_FONT_OUTLINE },
    Objective = { face = DEFAULT_FONT_FACE, size = 14, outline = DEFAULT_FONT_OUTLINE },
}

local ROW_KINDS = {
    category = "category",
    entry = "entry",
    objective = "objective",
}

local controlCounters = {
    category = 0,
    entry = 0,
    objective = 0,
}

local categoryPool = {
    free = {},
    used = {},
    nextId = 1,
}

local entryPool = {
    free = {},
    used = {},
    nextId = 1,
}

local objectivePool = {
    free = {},
    used = {},
    nextId = 1,
}

function Rows.SetObjectiveIndent(indent)
    local numeric = tonumber(indent)
    if numeric == nil or numeric ~= numeric then
        return
    end
    if numeric < 0 then
        return
    end

    DEFAULTS.OBJECTIVE_INDENT_X = numeric
end

function Rows.SetEntryIndent(indent)
    local numeric = tonumber(indent)
    if numeric == nil or numeric ~= numeric then
        return
    end
    if numeric < 0 then
        return
    end

    DEFAULTS.ENTRY_INDENT_X = numeric
    ENTRY_INDENT_X = numeric
end

local function getAddon()
    return rawget(_G, addonName)
end

local function applyBaseColor(label, r, g, b, a)
    if not (label and label.SetColor) then
        return
    end

    local color = label._baseColor
    if type(color) ~= "table" then
        color = {}
        label._baseColor = color
    end

    color[1] = r or 1
    color[2] = g or 1
    color[3] = b or 1
    color[4] = a or 1

    label:SetColor(color[1], color[2], color[3], color[4])
end

local function restoreBaseColorFromLabel(label)
    local color = label and label._baseColor
    if not (label and label.SetColor and type(color) == "table") then
        return
    end

    label:SetColor(color[1] or 1, color[2] or 1, color[3] or 1, color[4] or 1)
end

local function isGoldenColorDebugEnabled()
    local root = getAddon()

    local utils = (root and root.Utils) or rawget(_G, "Nvk3UT_Utils")
    if type(utils) == "table" and type(utils.IsDebugEnabled) == "function" then
        local ok, enabled = pcall(utils.IsDebugEnabled)
        if ok and enabled ~= nil then
            return enabled == true
        end
    end

    local diagnostics = (root and root.Diagnostics) or rawget(_G, "Nvk3UT_Diagnostics")
    if type(diagnostics) == "table" and type(diagnostics.IsDebugEnabled) == "function" then
        local ok, enabled = pcall(function()
            return diagnostics:IsDebugEnabled()
        end)
        if ok and enabled ~= nil then
            return enabled == true
        end
    end

    if type(root) == "table" and type(root.IsDebugEnabled) == "function" then
        local ok, enabled = pcall(function()
            return root:IsDebugEnabled()
        end)
        if ok and enabled ~= nil then
            return enabled == true
        end
    end

    local sv = root and (root.sv or root.SV)
    if type(sv) == "table" then
        local flag = sv.debug
        if flag == nil then
            flag = sv.debugEnabled
        end
        if flag ~= nil then
            return flag == true
        end
    end

    return false
end

local function isGoldenWrapDebugEnabled()
    return isGoldenColorDebugEnabled()
end

local pendingCategoryAlignLog = true
local pendingEntryAlignLog = true
local pendingObjectiveAlignLog = true

local function getHostViewportInfo()
    local host = Nvk3UT and Nvk3UT.TrackerHost
    local align = "left"
    local scrollbarSide = "right"
    local leftInset = 0
    local rightInset = 0
    local viewportWidth

    if host and type(host.GetContentAlignment) == "function" then
        local ok, value = pcall(host.GetContentAlignment, host)
        if ok and type(value) == "string" and value ~= "" then
            align = string.lower(value)
        end
    end

    if host and type(host.GetScrollbarSide) == "function" then
        local ok, value = pcall(host.GetScrollbarSide, host)
        if ok and type(value) == "string" and value ~= "" then
            scrollbarSide = string.lower(value)
        end
    end

    if host and type(host.GetViewportInsets) == "function" then
        local ok, leftValue, rightValue = pcall(host.GetViewportInsets, host)
        if ok then
            leftInset = tonumber(leftValue) or leftInset
            rightInset = tonumber(rightValue) or rightInset
        end
    end

    if host and type(host.GetViewportWidth) == "function" then
        local ok, width = pcall(host.GetViewportWidth, host)
        if ok and type(width) == "number" then
            viewportWidth = width
        end
    end

    return {
        align = align,
        scrollbarSide = scrollbarSide,
        leftInset = leftInset,
        rightInset = rightInset,
        viewportWidth = viewportWidth,
    }
end

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

local function getMouseoverHighlightColor()
    local root = getAddon()
    local host = type(root) == "table" and root.TrackerHost or nil
    if type(host) == "table" then
        if type(host.EnsureAppearanceDefaults) == "function" then
            pcall(host.EnsureAppearanceDefaults, host)
        end

        if type(host.GetMouseoverHighlightColor) == "function" then
            local ok, r, g, b, a = pcall(host.GetMouseoverHighlightColor, host, "goldenTracker")
            if ok and r and g and b and a then
                return r, g, b, a
            end
        end
    end

    return unpack(DEFAULT_MOUSEOVER_HIGHLIGHT_COLOR)
end

local function applyMouseoverHighlight(control)
    local label = control and (control.label or control.Label)
    if not (label and label.SetColor) then
        return
    end

    local r, g, b, a = getMouseoverHighlightColor()
    label:SetColor(r, g, b, a)

    safeDebug(
        "Golden hover: applying mouseover highlight color r=%.3f g=%.3f b=%.3f a=%.3f",
        r or 0,
        g or 0,
        b or 0,
        a or 0
    )
end

local function restoreMouseoverHighlight(control)
    local resetFn = control and control.__nvk3RestoreHoverColor
    if type(resetFn) == "function" then
        resetFn(control)
        return
    end

    local label = control and (control.label or control.Label)
    if not label then
        return
    end

    restoreBaseColorFromLabel(label)

    local color = label._baseColor or {}
    safeDebug(
        "Golden hover: restored base color r=%.3f g=%.3f b=%.3f a=%.3f",
        color[1] or 0,
        color[2] or 0,
        color[3] or 0,
        color[4] or 0
    )

    if resetFn ~= nil then
        safeDebug("Golden hover: missing restore callback, applied base color fallback")
    end
end

local function debugGoldenWrap(label, rowKind, availableWidth, minHeight, control, text)
    if not isGoldenWrapDebugEnabled() then
        return
    end

    local width = label.GetWidth and label:GetWidth() or nil
    local textHeight = label.GetTextHeight and label:GetTextHeight() or nil
    local numLines = label.GetNumLines and label:GetNumLines() or nil
    local controlHeight = control and control.GetHeight and control:GetHeight() or nil
    local storedHeight = control and control.__height or nil

    safeDebug(
        "[Wrap] %s: avail=%.1f labelWidth=%.1f textHeight=%.1f lines=%s minHeight=%.1f controlHeight=%.1f storedHeight=%.1f text='%s'",
        tostring(rowKind),
        tonumber(availableWidth) or -1,
        tonumber(width) or -1,
        tonumber(textHeight) or -1,
        numLines ~= nil and tostring(numLines) or "n/a",
        tonumber(minHeight) or -1,
        tonumber(controlHeight) or -1,
        tonumber(storedHeight) or -1,
        tostring(text or "")
    )
end

local function getWindowManager()
    local wm = rawget(_G, "WINDOW_MANAGER")
    if wm == nil then
        safeDebug("WINDOW_MANAGER unavailable; skipping row creation")
    end
    return wm
end

local function resolveParentName(parent)
    if parent and type(parent.GetName) == "function" then
        local ok, name = pcall(parent.GetName, parent)
        if ok and type(name) == "string" and name ~= "" then
            return name
        end
    end

    return "Nvk3UT_Golden"
end

local function nextControlName(parent, kind)
    controlCounters[kind] = (controlCounters[kind] or 0) + 1
    local parentName = resolveParentName(parent)
    return string.format("%s_%sRow%u", parentName, kind, controlCounters[kind])
end

local function applyLabelDefaults(label, font, color)
    if not label then
        return
    end

    if label.SetFont and font then
        label:SetFont(font)
    end

    if label.SetHorizontalAlignment then
        label:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    end

    if label.SetVerticalAlignment then
        label:SetVerticalAlignment(TEXT_ALIGN_TOP)
    end

    if label.SetColor and type(color) == "table" then
        local r = color[1] or color.r or 1
        local g = color[2] or color.g or 1
        local b = color[3] or color.b or 1
        local a = color[4] or color.a or 1
        label:SetColor(r, g, b, a)
    end

    if label.SetWrapMode and rawget(_G, "TEXT_WRAP_MODE_ELLIPSIS") then
        label:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
    end
end

local function formatObjectiveCounter(current, max)
    local currentNum = tonumber(current)
    if currentNum == nil then
        return nil
    end

    currentNum = math.floor(currentNum + 0.5)
    if currentNum < 0 then
        currentNum = 0
    end

    local maxNum = tonumber(max)
    if maxNum ~= nil then
        maxNum = math.floor(maxNum + 0.5)
        if maxNum < 1 then
            maxNum = 1
        end

        if currentNum > maxNum then
            currentNum = maxNum
        end

        return string.format("(%d/%d)", currentNum, maxNum)
    end

    return string.format("(%d)", currentNum)
end

local function clampFontSize(value)
    local numeric = tonumber(value)
    if numeric == nil then
        return nil
    end

    numeric = math.floor(numeric + 0.5)
    if numeric < MIN_FONT_SIZE then
        numeric = MIN_FONT_SIZE
    elseif numeric > MAX_FONT_SIZE then
        numeric = MAX_FONT_SIZE
    end

    return numeric
end

local function buildFontString(face, size, outline)
    if type(face) ~= "string" or face == "" then
        return nil
    end

    local resolvedSize = clampFontSize(size)
    if resolvedSize == nil then
        return nil
    end

    local resolvedOutline = outline
    if type(resolvedOutline) ~= "string" or resolvedOutline == "" then
        resolvedOutline = DEFAULT_FONT_OUTLINE
    end

    return string.format("%s|%d|%s", face, resolvedSize, resolvedOutline)
end

local function getSavedVars()
    local addon = getAddon()
    if type(addon) ~= "table" then
        return nil
    end

    local sv = addon.SV or addon.sv
    if type(sv) ~= "table" then
        return nil
    end

    return sv
end

local function getConfiguredFonts()
    local sv = getSavedVars()
    if type(sv) ~= "table" then
        return nil
    end

    local golden = sv.Golden
    if type(golden) ~= "table" then
        return nil
    end

    local tracker = golden.Tracker
    if type(tracker) ~= "table" then
        return nil
    end

    return tracker.Fonts
end

local function shouldShowGoldenHeaderCounter()
    local sv = getSavedVars()
    if type(sv) ~= "table" then
        return true
    end

    local config = sv.Golden
    if type(config) == "table" then
        local flag = config.ShowCountsInHeaders
        if flag == nil then
            flag = config.showCountsInHeaders
        end
        if flag ~= nil then
            return flag ~= false
        end
    end

    local trackerDefaults = sv.TrackerDefaults
    if type(trackerDefaults) == "table" then
        local goldenDefaults = trackerDefaults.GoldenDefaults
        if type(goldenDefaults) == "table" then
            local flag = goldenDefaults.ShowCountsInHeaders
            if flag == nil then
                flag = goldenDefaults.showCountsInHeaders
            end
            if flag ~= nil then
                return flag ~= false
            end
        end
    end

    return true
end

local function selectFontGroup(fonts, key)
    if type(fonts) ~= "table" then
        return nil
    end

    local group = fonts[key]
    if type(group) ~= "table" then
        local altKey = type(key) == "string" and string.lower(key)
        if altKey and type(fonts[altKey]) == "table" then
            group = fonts[altKey]
        end
    end

    return group
end

local function resolveGoldenFont(key)
    local defaults = GOLDEN_FONT_DEFAULTS[key]
    if type(defaults) ~= "table" then
        defaults = GOLDEN_FONT_DEFAULTS.Objective
    end

    local face = defaults.face
    local size = defaults.size
    local outline = defaults.outline

    local fonts = getConfiguredFonts()
    local group = selectFontGroup(fonts, key)
    if type(group) == "table" then
        local candidateFace = group.Face or group.face
        if type(candidateFace) == "string" and candidateFace ~= "" then
            face = candidateFace
        end

        local candidateSize = clampFontSize(group.Size or group.size)
        if candidateSize ~= nil then
            size = candidateSize
        end

        local candidateOutline = group.Outline or group.outline
        if type(candidateOutline) == "string" and candidateOutline ~= "" then
            outline = candidateOutline
        end
    end

    return buildFontString(face, size, outline)
end

local function getGoldenCategoryFont()
    return resolveGoldenFont("Category") or DEFAULTS.CATEGORY_FONT
end

local function getGoldenTitleFont()
    return resolveGoldenFont("Title") or DEFAULTS.ENTRY_FONT
end

local function getGoldenObjectiveFont()
    return resolveGoldenFont("Objective") or DEFAULTS.OBJECTIVE_FONT
end

Nvk3UT.GetGoldenCategoryFont = getGoldenCategoryFont
Nvk3UT.GetGoldenTitleFont = getGoldenTitleFont
Nvk3UT.GetGoldenRowFont = getGoldenObjectiveFont

local ROW_HEIGHT_METRICS = {
    [ROW_KINDS.category] = {
        fontKey = "Category",
        minHeight = DEFAULTS.CATEGORY_HEIGHT,
        paddingTop = 0,
        paddingBottom = 0,
    },
    [ROW_KINDS.entry] = {
        fontKey = "Title",
        minHeight = DEFAULTS.ENTRY_HEIGHT,
        paddingTop = 0,
        paddingBottom = 0,
    },
    [ROW_KINDS.objective] = {
        fontKey = "Objective",
        minHeight = DEFAULTS.OBJECTIVE_HEIGHT,
        paddingTop = 0,
        paddingBottom = 0,
    },
}

local resolvedRowHeights = {
    [ROW_KINDS.category] = DEFAULTS.CATEGORY_HEIGHT,
    [ROW_KINDS.entry] = DEFAULTS.ENTRY_HEIGHT,
    [ROW_KINDS.objective] = DEFAULTS.OBJECTIVE_HEIGHT,
}

local function getTrackerHostScrollContentWidth()
    local root = getAddon()
    local host = type(root) == "table" and root.TrackerHost or nil
    if type(host) == "table" then
        local getViewportWidth = host.GetViewportWidth
        if type(getViewportWidth) == "function" then
            local ok, measured = pcall(getViewportWidth, host)
            if ok and type(measured) == "number" and measured > 0 then
                return measured
            end
        end

        local getScrollContent = host.GetScrollContent
        if type(getScrollContent) == "function" then
            local ok, scrollContent = pcall(getScrollContent, host)
            if ok and scrollContent and scrollContent.GetWidth then
                local okWidth, measured = pcall(scrollContent.GetWidth, scrollContent)
                if okWidth and type(measured) == "number" and measured > 0 then
                    return measured
                end
            end
        end
    end

    return nil
end

local function getRowContainerWidth(control)
    local width = getTrackerHostScrollContentWidth()
    local parent = control and control.GetParent and control:GetParent()
    if not width or width <= 0 then
        if parent and parent.GetWidth then
            local ok, measured = pcall(parent.GetWidth, parent)
            if ok and type(measured) == "number" then
                width = measured
            end
        end
    end

    if (not width or width <= 0) and control and control.GetWidth then
        local ok, measured = pcall(control.GetWidth, control)
        if ok and type(measured) == "number" then
            width = measured
        end
    end

    if not width or width < 0 then
        width = 0
    end

    return width
end

local function computeAvailableWidth(control, indent, leftPadding, rightPadding)
    indent = indent or 0
    leftPadding = leftPadding or 0
    rightPadding = rightPadding or 0

    local containerWidth = getRowContainerWidth(control)
    local availableWidth = containerWidth - indent - leftPadding - rightPadding - SCROLLBAR_WIDTH_RESERVE
    if availableWidth < 0 then
        availableWidth = 0
    end

    return availableWidth
end

local function applyGoldenRowMetrics(control, label, availableWidth, minHeight, paddingTop, paddingBottom)
    if not (control and label) then
        return nil
    end

    availableWidth = math.max(0, availableWidth or 0)
    if label.SetWidth then
        label:SetWidth(availableWidth)
    end

    local textHeight = (label.GetTextHeight and label:GetTextHeight()) or 0
    local paddingY = (paddingTop or 0) + (paddingBottom or 0)
    local targetHeight = math.max(minHeight or 0, textHeight + ROW_TEXT_PADDING_Y + paddingY)

    if control.SetHeight then
        control:SetHeight(targetHeight)
    end

    control.__height = targetHeight

    return targetHeight
end

local function measureFontHeight(font)
    if type(font) ~= "string" or font == "" then
        return nil
    end

    if type(GetStringHeight) == "function" then
        local ok, measured = pcall(GetStringHeight, font, "X", 1024)
        if ok and type(measured) == "number" and measured > 0 then
            return measured
        end
    end

    return nil
end

local function resolveMetricsFont(fontKey)
    if fontKey == "Category" then
        return getGoldenCategoryFont()
    elseif fontKey == "Title" then
        return getGoldenTitleFont()
    elseif fontKey == "Objective" then
        return getGoldenObjectiveFont()
    end

    return nil
end

local function resolveRowHeight(kind)
    local metrics = ROW_HEIGHT_METRICS[kind] or {}
    local font = resolveMetricsFont(metrics.fontKey)
    local measured = measureFontHeight(font) or 0
    local paddingTop = metrics.paddingTop or 0
    local paddingBottom = metrics.paddingBottom or 0
    local computed = measured + paddingTop + paddingBottom
    local minHeight = metrics.minHeight or 0
    local resolved = minHeight

    if computed > 0 then
        resolved = math.max(minHeight, math.floor(computed + 0.5))
    end

    resolvedRowHeights[kind] = resolved
    return resolved
end

local function getCategoryRowHeight()
    return resolveRowHeight(ROW_KINDS.category)
end

local function getEntryRowHeight()
    return resolveRowHeight(ROW_KINDS.entry)
end

local function getObjectiveRowHeight()
    return resolveRowHeight(ROW_KINDS.objective)
end

local function sanitizeColorNumber(value)
    local numeric = tonumber(value)
    if numeric == nil then
        return nil
    end
    if numeric < 0 then
        numeric = 0
    elseif numeric > 1 then
        numeric = 1
    end
    return numeric
end

local function formatColorForLog(color)
    if type(color) ~= "table" then
        return "n/a"
    end

    local r = sanitizeColorNumber(color.r or color[1]) or 0
    local g = sanitizeColorNumber(color.g or color[2]) or 0
    local b = sanitizeColorNumber(color.b or color[3]) or 0
    local a = sanitizeColorNumber(color.a or color[4]) or 0

    return string.format("%.3f,%.3f,%.3f,%.3f", r, g, b, a)
end

local function logGoldenColorDecision(context, state, source, colorComponents, reason, metadata)
    local root = getAddon()
    local diagnostics = (root and root.Diagnostics) or rawget(_G, "Nvk3UT_Diagnostics")
    local colorText = formatColorForLog(colorComponents)
    local paletteEntry = metadata and metadata.palette
    local paletteText = formatColorForLog(paletteEntry)
    local roleKey = metadata and metadata.role or "?"
    local message = string.format(
        "[%s] ctx=%s state=%s key=%s source=%s raw=%s color=%s reason=%s",
        GOLDEN_COLOR_DEBUG_TAG,
        tostring(context or "?"),
        tostring(state or "?"),
        tostring(roleKey or "?"),
        tostring(source or "?"),
        paletteText,
        colorText,
        tostring(reason or "")
    )

    if diagnostics and type(diagnostics.DebugIfEnabled) == "function" then
        diagnostics:DebugIfEnabled(GOLDEN_COLOR_DEBUG_TAG, message)
        return
    end

    local debugFn = root and root.Debug
    if type(debugFn) == "function" then
        debugFn(message)
    end
end

local function buildColorTable(r, g, b, a, source, sourceReason)
    local color = {
        r = sanitizeColorNumber(r) or 1,
        g = sanitizeColorNumber(g) or 1,
        b = sanitizeColorNumber(b) or 1,
        a = sanitizeColorNumber(a or 1) or 1,
    }
    color[1], color[2], color[3], color[4] = color.r, color.g, color.b, color.a
    color.__source = source
    color.__sourceReason = sourceReason
    return color
end

local function getTrackerHost()
    local addon = getAddon()
    if type(addon) ~= "table" then
        return nil
    end
    local host = addon.TrackerHost
    if type(host) == "table" then
        return host
    end
    return nil
end

local function fetchTrackerColor(host, role)
    local r, g, b, a
    local source
    local sourceReason
    if type(host) == "table" then
        if type(host.EnsureAppearanceDefaults) == "function" then
            pcall(host.EnsureAppearanceDefaults, host)
        end
        if type(host.GetTrackerColor) == "function" then
            local ok, colorR, colorG, colorB, colorA = pcall(host.GetTrackerColor, DEFAULT_COLOR_KIND, role)
            if ok and type(colorR) == "number" then
                r = colorR
                g = colorG or 1
                b = colorB or 1
                a = colorA or 1
                source = string.format("savedvars.%s.%s", DEFAULT_COLOR_KIND, tostring(role))
                sourceReason = "Tracker host returned configured color"
            end
        end
    end

    if r == nil then
        local fallback = DEFAULT_GOLDEN_COLOR_VALUES[role] or DEFAULT_GOLDEN_COLOR_VALUES[GOLDEN_COLOR_ROLES.EntryName]
        if type(fallback) == "table" then
            r = fallback.r or fallback[1] or 1
            g = fallback.g or fallback[2] or 1
            b = fallback.b or fallback[3] or 1
            a = fallback.a or fallback[4] or 1
            source = string.format("defaults.golden.%s", tostring(role))
            sourceReason = "Tracker host missing color; using Golden defaults"
        else
            r, g, b, a = 1, 1, 1, 1
            source = string.format("defaults.golden.%s", tostring(role))
            sourceReason = "No defaults available; using white fallback"
        end
    end

    return buildColorTable(r, g, b, a, source, sourceReason)
end

local function getGoldenTrackerColors()
    local palette = {}
    local host = getTrackerHost()
    for index = 1, #GOLDEN_COLOR_ROLE_LIST do
        local role = GOLDEN_COLOR_ROLE_LIST[index]
        palette[role] = fetchTrackerColor(host, role)
    end
    return palette
end

local function selectFirstNumber(...)
    local argCount = select("#", ...)
    for index = 1, argCount do
        local candidate = select(index, ...)
        local numeric = tonumber(candidate)
        if numeric ~= nil and numeric == numeric then
            return numeric
        end
    end
    return nil
end

local function isCapstoneComplete(payload)
    if type(payload) ~= "table" then
        return false
    end

    if payload.isComplete == true or payload.isCompleted == true or payload.completed == true then
        return true
    end

    local completed = selectFirstNumber(
        payload.completedObjectives,
        payload.completedActivities,
        payload.countCompleted,
        payload.totalCompleted
    )
    local total = selectFirstNumber(
        payload.maxRewardTier,
        payload.capstoneCompletionThreshold,
        payload.capLimit,
        payload.totalEntries,
        payload.totalCount,
        payload.countTotal
    )

    if total and total > 0 and completed and completed >= total then
        return true
    end

    local remaining = selectFirstNumber(
        payload.remainingObjectivesToNextReward,
        payload.remainingObjectives,
        payload.totalRemaining,
        payload.remaining
    )
    if remaining ~= nil and remaining <= 0 then
        return true
    end

    return false
end

local function isObjectiveCompleted(objectiveData)
    if type(objectiveData) ~= "table" then
        return false
    end

    if objectiveData.isCompleted == true or objectiveData.isComplete == true or objectiveData.completed == true then
        return true
    end

    local progress = selectFirstNumber(objectiveData.progress, objectiveData.current, objectiveData.progressDisplay)
    local maxValue = selectFirstNumber(objectiveData.max, objectiveData.maxDisplay)
    if progress ~= nil and maxValue ~= nil and maxValue > 0 and progress >= maxValue then
        return true
    end

    return false
end

Nvk3UT.GetGoldenTrackerColors = getGoldenTrackerColors

local function extractColorComponents(color)
    if type(color) ~= "table" then
        return nil
    end

    local r = sanitizeColorNumber(color.r or color[1])
    local g = sanitizeColorNumber(color.g or color[2])
    local b = sanitizeColorNumber(color.b or color[3])
    local a = sanitizeColorNumber(color.a or color[4] or 1)

    if r == nil or g == nil or b == nil then
        return nil
    end

    return r, g, b, a or 1
end

local function coerceFunctionColor(entry, context, role, colorKind)
    if type(entry) ~= "function" then
        return nil
    end

    local ok, value1, value2, value3, value4 = pcall(entry, context, role, colorKind)
    if not ok then
        safeDebug("resolveGoldenColor failed for role=%s: %s", tostring(role), tostring(value1))
        return nil
    end

    return extractColorComponents({ value1, value2, value3, value4 })
end

local function resolveGoldenColor(role, overrideColors, colorKind, palette)
    if type(overrideColors) == "table" then
        local overrideEntry = overrideColors[role]
        if type(overrideEntry) == "function" then
            local r, g, b, a = coerceFunctionColor(overrideEntry, overrideColors, role, colorKind)
            if r ~= nil then
                return r, g, b, a, string.format("override.function.%s", tostring(role)), "Override function provided color"
            end
        elseif type(overrideEntry) == "table" then
            local r, g, b, a = extractColorComponents(overrideEntry)
            if r ~= nil then
                return r, g, b, a, string.format("override.table.%s", tostring(role)), "Override table provided color"
            end
        end
    end

    local colors = type(palette) == "table" and palette or getGoldenTrackerColors()
    local entry = colors and colors[role]
    if type(entry) == "table" then
        local r = entry.r or entry[1] or 1
        local g = entry.g or entry[2] or 1
        local b = entry.b or entry[3] or 1
        local a = entry.a or entry[4] or 1
        local source = entry.__source or string.format("palette.%s", tostring(role))
        local sourceReason = entry.__sourceReason or "Palette entry"
        return r, g, b, a, source, sourceReason
    end

    local fallback = DEFAULT_GOLDEN_COLOR_VALUES[role] or DEFAULT_GOLDEN_COLOR_VALUES[GOLDEN_COLOR_ROLES.EntryName]
    local r = fallback.r or fallback[1] or 1
    local g = fallback.g or fallback[2] or 1
    local b = fallback.b or fallback[3] or 1
    local a = fallback.a or fallback[4] or 1
    return r, g, b, a, string.format("fallback.default.%s", tostring(role)), "Palette missing entry; using Golden defaults"
end

local function createControl(parent, kind)
    local wm = getWindowManager()
    if wm == nil then
        return nil
    end

    if parent == nil then
        safeDebug("createControl skipped; parent missing for kind '%s'", tostring(kind))
        return nil
    end

    local controlName = nextControlName(parent, kind)
    local control = wm:CreateControl(controlName, parent, CT_CONTROL)
    if control and control.SetResizeToFitDescendents then
        control:SetResizeToFitDescendents(true)
    end
    if control and control.SetHidden then
        control:SetHidden(false)
    end

    if control and control.SetMouseEnabled then
        control:SetMouseEnabled(true)
    end

    if control then
        control.__rowKind = kind
    end

    return control
end

local function createLabel(parent, suffix)
    local wm = getWindowManager()
    if wm == nil or parent == nil then
        return nil
    end

    local baseName = resolveParentName(parent)
    local labelName = string.format("%s_%sLabel", baseName, suffix)
    local label = wm:CreateControl(labelName, parent, CT_LABEL)
    if label and label.SetHidden then
        label:SetHidden(false)
    end

    return label
end

local function applyLabelColor(label, role, palette, overrideColors, colorKind)
    if not (label and label.SetColor) then
        return nil
    end

    local r, g, b, a, source, sourceReason = resolveGoldenColor(role, overrideColors, colorKind, palette)
    applyBaseColor(label, r or 1, g or 1, b or 1, a or 1)
    if label.SetAlpha then
        label:SetAlpha(1)
    end

    return r, g, b, a, source, sourceReason
end

local function buildCategoryControlName(parent)
    local parentName = resolveParentName(parent)
    local index = categoryPool.nextId or 1
    categoryPool.nextId = index + 1
    return string.format("%s_categoryRow%d", parentName, index)
end

local function detachCategoryFromUsed(row)
    for index = #categoryPool.used, 1, -1 do
        if categoryPool.used[index] == row then
            table.remove(categoryPool.used, index)
            return
        end
    end
end

local function createCategoryRow(parent)
    local wm = getWindowManager()
    if wm == nil or parent == nil then
        return nil
    end

    local controlName = buildCategoryControlName(parent)
    local control = wm:CreateControl(controlName, parent, CT_CONTROL)
    if control.SetResizeToFitDescendents then
        control:SetResizeToFitDescendents(true)
    end
    if control.SetHidden then
        control:SetHidden(false)
    end
    if control.SetMouseEnabled then
        control:SetMouseEnabled(true)
    end
    control.__rowKind = ROW_KINDS.category
    control.__height = getCategoryRowHeight()
    if control.SetHeight then
        control:SetHeight(control.__height)
    end

    local indentName = string.format("%s_CategoryIndent", controlName)
    local indentAnchor = wm:CreateControl(indentName, control, CT_CONTROL)
    if indentAnchor then
        indentAnchor:SetDimensions(1, 1)
        indentAnchor:ClearAnchors()
        indentAnchor:SetAnchor(TOPLEFT, control, TOPLEFT, 0, 0)
    end

    local chevronName = string.format("%s_CategoryChevron", controlName)
    local chevron = wm:CreateControl(chevronName, control, CT_TEXTURE)
    if chevron.SetMouseEnabled then
        chevron:SetMouseEnabled(false)
    end
    if chevron.SetHidden then
        chevron:SetHidden(false)
    end
    if chevron.SetDimensions then
        chevron:SetDimensions(CATEGORY_CHEVRON_SIZE, CATEGORY_CHEVRON_SIZE)
    end
    if chevron.ClearAnchors then
        chevron:ClearAnchors()
        chevron:SetAnchor(TOPLEFT, indentAnchor or control, TOPLEFT, 0, 0)
    end

    local label = createLabel(control, "Category")
    if label then
        label:ClearAnchors()
        if label.SetAnchor then
            label:SetAnchor(TOPLEFT, chevron, TOPRIGHT, CATEGORY_LABEL_OFFSET_X, 0)
            label:SetAnchor(TOPRIGHT, control, TOPRIGHT, 0, 0)
        end
        applyLabelDefaults(label, getGoldenCategoryFont())
    end

    local row = {
        control = control,
        label = label,
        chevron = chevron,
        indentAnchor = indentAnchor,
        name = controlName,
        __height = getCategoryRowHeight(),
        __rowKind = ROW_KINDS.category,
        _poolState = "fresh",
    }

    if control then
        control.label = label
        control.indentAnchor = indentAnchor
    end

    if control and control.SetHandler then
        control:SetHandler("OnMouseUp", function(_, button, upInside)
            if button == MOUSE_BUTTON_LEFT and upInside then
                local callback = row._onToggle
                if type(callback) == "function" then
                    callback()
                end
            end
        end)

        control:SetHandler("OnMouseEnter", function(ctrl)
            applyMouseoverHighlight(ctrl)
        end)

        control:SetHandler("OnMouseExit", function(ctrl)
            restoreMouseoverHighlight(ctrl)
        end)
    end

    safeDebug("[CategoryPool] create %s", tostring(controlName))

    return row
end

local function resetCategoryRowVisuals(row, parent)
    if not row then
        return
    end

    local control = row.control
    if control then
        if control.SetParent then
            control:SetParent(parent)
        end
        if control.SetHidden then
            control:SetHidden(false)
        end
        if control.SetAlpha then
            control:SetAlpha(1)
        end
        if control.ClearAnchors then
            control:ClearAnchors()
        end
        if control.SetResizeToFitDescendents then
            control:SetResizeToFitDescendents(true)
        end
        if control.SetHeight then
            control:SetHeight(getCategoryRowHeight())
        end
        control.__rowKind = ROW_KINDS.category
        control.__height = getCategoryRowHeight()
    end

    row.__height = getCategoryRowHeight()

    local palette = getGoldenTrackerColors()
    local label = row.label
    if label then
        if label.SetHidden then
            label:SetHidden(false)
        end
        if label.SetText then
            label:SetText("")
        end
        applyLabelDefaults(label, getGoldenCategoryFont())
        applyLabelColor(label, GOLDEN_COLOR_ROLES.CategoryTitleOpen, palette, nil, DEFAULT_COLOR_KIND)
    end

    local chevron = row.chevron
    if chevron then
        if chevron.SetHidden then
            chevron:SetHidden(false)
        end
        if chevron.SetTexture then
            chevron:SetTexture(CATEGORY_CHEVRON_TEXTURES.collapsed)
        end
        if chevron.SetDimensions then
            chevron:SetDimensions(CATEGORY_CHEVRON_SIZE, CATEGORY_CHEVRON_SIZE)
        end
        if chevron.ClearAnchors then
            chevron:ClearAnchors()
            chevron:SetAnchor(TOPLEFT, control, TOPLEFT, 0, 0)
        end
    end

    row._poolParent = parent
    row._poolState = "used"
    row._onToggle = nil

    categoryPool.used[#categoryPool.used + 1] = row

    safeDebug(
        "[CategoryPool] acquire %s (used=%d free=%d)",
        tostring(row.name),
        #categoryPool.used,
        #categoryPool.free
    )
end

local function acquireCategoryRow(parent)
    local row
    if #categoryPool.free > 0 then
        row = table.remove(categoryPool.free)
    end

    if not row then
        row = createCategoryRow(parent)
    end

    if not row then
        return nil
    end

    resetCategoryRowVisuals(row, parent)

    return row
end

local function releaseCategoryRow(row)
    if not row then
        return
    end

    detachCategoryFromUsed(row)

    local control = row.control
    if control then
        if control.SetHidden then
            control:SetHidden(true)
        end
        if control.ClearAnchors then
            control:ClearAnchors()
        end
    end

    local label = row.label
    if label then
        if label.SetText then
            label:SetText("")
        end
        if label.SetHidden then
            label:SetHidden(true)
        end
    end

    local chevron = row.chevron
    if chevron then
        if chevron.SetTexture then
            chevron:SetTexture(nil)
        end
        if chevron.SetHidden then
            chevron:SetHidden(true)
        end
    end

    row._poolParent = nil
    row._poolState = "free"
    row._onToggle = nil

    categoryPool.free[#categoryPool.free + 1] = row

    safeDebug(
        "[CategoryPool] release %s (used=%d free=%d)",
        tostring(row.name),
        #categoryPool.used,
        #categoryPool.free
    )
end

local function releaseAllCategoryRows()
    for index = #categoryPool.used, 1, -1 do
        local row = categoryPool.used[index]
        categoryPool.used[index] = nil
        releaseCategoryRow(row)
    end

    safeDebug("[CategoryPool] reset (used=%d free=%d)", #categoryPool.used, #categoryPool.free)
end

local function applyCategoryRow(row, categoryData)
    local targetRow = row and row.control or row
    local label = row and row.label
    local chevron = row and row.chevron
    if not (targetRow and label and chevron) then
        return nil
    end

    if targetRow.SetHidden then
        targetRow:SetHidden(false)
    end

    applyLabelDefaults(label, getGoldenCategoryFont())

    local palette = getGoldenTrackerColors()

    local expanded = true
    if type(categoryData) == "table" then
        if categoryData.isExpanded ~= nil then
            expanded = categoryData.isExpanded ~= false
        elseif categoryData.expanded ~= nil then
            expanded = categoryData.expanded ~= false
        end
    end

    local categoryComplete = isCapstoneComplete(categoryData)
    local role
    if expanded then
        role = GOLDEN_COLOR_ROLES.Active
    elseif categoryComplete then
        role = GOLDEN_COLOR_ROLES.CategoryTitleClosed
    else
        role = GOLDEN_COLOR_ROLES.CategoryTitleOpen
    end
    local colorR, colorG, colorB, colorA, colorSource, colorSourceReason =
        applyLabelColor(label, role, palette, nil, DEFAULT_COLOR_KIND)
    if colorR ~= nil and isGoldenColorDebugEnabled() then
        local stateTokens = {
            expanded and "active" or "inactive",
            categoryComplete and "capstoneComplete" or "capstoneOpen",
        }
        local reason
        if expanded then
            reason = "Category active; using focused color"
        elseif categoryComplete then
            reason = "Capstone reached; using completed category color"
        else
            reason = "Capstone open; using open category color"
        end
        if colorSourceReason and colorSourceReason ~= "" then
            reason = string.format("%s (%s)", reason, colorSourceReason)
        end

        logGoldenColorDecision(
            "golden.categoryHeader",
            table.concat(stateTokens, "+"),
            colorSource or string.format("role.%s", tostring(role)),
            { colorR, colorG, colorB, colorA },
            reason,
            { role = role, palette = palette and palette[role] }
        )
    end

    local text = GOLDEN_HEADER_TITLE
    local showCounter = shouldShowGoldenHeaderCounter()
    local remaining = nil
    local generalMode = type(categoryData) == "table" and categoryData.generalCompletedMode
    local capstoneReached = categoryData and categoryData.capstoneReached == true
    if type(categoryData) == "table" then
        if showCounter and capstoneReached and generalMode == "showOpen" then
            remaining = tonumber(categoryData.remainingAllObjectives) or 0
        else
            remaining = tonumber(categoryData.remainingObjectivesToNextReward) or 0
        end
    end

    if showCounter and remaining ~= nil then
        text = string.format("%s (%d)", GOLDEN_HEADER_TITLE, remaining)
    end

    if not showCounter then
        text = GOLDEN_HEADER_TITLE
    end

    if isGoldenColorDebugEnabled() then
        safeDebug(
            "[GoldenHeader] title='%s' count=%s showCounter=%s",
            text,
            tostring(remaining),
            tostring(showCounter)
        )
    end

    local indentValue = tonumber(categoryData and categoryData.categoryIndent) or 0
    if indentValue < 0 then
        indentValue = 0
    end
    local viewportInfo = getHostViewportInfo()
    if isGoldenColorDebugEnabled() then
        safeDebug(
            "[GoldenIndent] ApplyCategoryRow categoryIndent=%s indentValue=%s",
            tostring(categoryData and categoryData.categoryIndent),
            tostring(indentValue)
        )
    end
    if row.indentAnchor and row.indentAnchor.SetAnchor then
        row.indentAnchor:ClearAnchors()
        if viewportInfo.align == "right" then
            row.indentAnchor:SetAnchor(TOPRIGHT, targetRow, TOPRIGHT, -indentValue, 0)
        else
            row.indentAnchor:SetAnchor(TOPLEFT, targetRow, TOPLEFT, indentValue, 0)
        end
    end
    if chevron and chevron.ClearAnchors and row.indentAnchor and row.indentAnchor.SetAnchor then
        chevron:ClearAnchors()
        if viewportInfo.align == "right" then
            chevron:SetAnchor(TOPRIGHT, row.indentAnchor, TOPRIGHT, 0, 0)
        else
            chevron:SetAnchor(TOPLEFT, row.indentAnchor, TOPLEFT, 0, 0)
        end
    end

    if label and label.ClearAnchors then
        label:ClearAnchors()
        if label.SetAnchor then
            if viewportInfo.align == "right" then
                label:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
                label:SetAnchor(TOPRIGHT, chevron, TOPLEFT, -CATEGORY_LABEL_OFFSET_X, 0)
                label:SetAnchor(TOPLEFT, targetRow, TOPLEFT, 0, 0)
            else
                label:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
                label:SetAnchor(TOPLEFT, chevron, TOPRIGHT, CATEGORY_LABEL_OFFSET_X, 0)
                label:SetAnchor(TOPRIGHT, targetRow, TOPRIGHT, 0, 0)
            end
        end
    end
    if isGoldenColorDebugEnabled() then
        local function formatAnchor(control, index)
            if not (control and control.GetAnchor) then
                return "<anchor read failed>"
            end
            local ok, point, relativeTo, relativePoint, offsetX, offsetY =
                pcall(control.GetAnchor, control, index or 0)
            if not ok then
                return "<anchor read failed>"
            end
            local relativeName = tostring(relativeTo)
            if type(relativeTo) == "userdata" and relativeTo.GetName then
                local nameOk, name = pcall(relativeTo.GetName, relativeTo)
                if nameOk and name ~= nil then
                    relativeName = tostring(name)
                end
            end
            return string.format("%s→%s (%s, %s)", tostring(point), tostring(relativeName), tostring(offsetX), tostring(offsetY))
        end

        safeDebug(
            "[GoldenIndent] anchors indent=%s chevron=%s label=%s",
            formatAnchor(row.indentAnchor, 0),
            formatAnchor(chevron, 0),
            formatAnchor(label, 0)
        )
    end

    local availableWidth = computeAvailableWidth(
        targetRow,
        indentValue + CATEGORY_CHEVRON_SIZE + CATEGORY_LABEL_OFFSET_X,
        0,
        0
    )
    if label.SetWidth then
        label:SetWidth(availableWidth)
    end
    if label.SetText then
        label:SetText(text)
    end

    local targetHeight = applyGoldenRowMetrics(targetRow, label, availableWidth, getCategoryRowHeight())
    if targetHeight then
        row.__height = targetHeight
    end

    targetRow._nvk3utCategoryExpanded = expanded
    row.__categoryExpanded = expanded

    if chevron and chevron.SetTexture then
        local textures = categoryData and categoryData.textures or CATEGORY_CHEVRON_TEXTURES
        local fallback = expanded and CATEGORY_CHEVRON_TEXTURES.expanded or CATEGORY_CHEVRON_TEXTURES.collapsed
        chevron:SetTexture(
            (expanded and textures.expanded) or (not expanded and textures.collapsed) or fallback
        )
    end

    local rotation = 0
    local texturePath = nil
    if chevron and chevron.SetTextureRotation then
        if viewportInfo.align == "right" and expanded then
            local host = Nvk3UT and Nvk3UT.TrackerHost
            if host and type(host.ApplyChevronVisualTopRightExpanded) == "function" then
                texturePath, rotation = host.ApplyChevronVisualTopRightExpanded(chevron)
            end
        else
            if viewportInfo.align == "right" and not expanded then
                rotation = math.pi
            end
            chevron:SetTextureRotation(rotation, 0.5, 0.5)
        end
    end

    if pendingCategoryAlignLog and isGoldenColorDebugEnabled() then
        local width = viewportInfo.viewportWidth
        if width == nil and targetRow.GetWidth then
            local okWidth, measured = pcall(targetRow.GetWidth, targetRow)
            if okWidth then
                width = tonumber(measured)
            end
        end
        safeDebug(
            "[CategoryAlign] align=%s scrollbar=%s insets=(%s,%s) rowWidth=%s chevronSide=%s rotation=%s",
            tostring(viewportInfo.align),
            tostring(viewportInfo.scrollbarSide),
            tostring(viewportInfo.leftInset),
            tostring(viewportInfo.rightInset),
            tostring(width),
            viewportInfo.align == "right" and "right" or "left",
            tostring(rotation)
        )
        pendingCategoryAlignLog = false
    end

    if isGoldenColorDebugEnabled() then
        local lastExpanded = row.__lastChevronExpanded
        if lastExpanded ~= expanded then
            if texturePath == nil and chevron and chevron.GetTextureFileName then
                local okTexture, texture = pcall(chevron.GetTextureFileName, chevron)
                if okTexture then
                    texturePath = texture
                end
            end
            safeDebug(
                "[CategoryChevron] align=%s expanded=%s texture=%s rotation=%s",
                tostring(viewportInfo.align),
                tostring(expanded),
                tostring(texturePath),
                tostring(rotation)
            )
            row.__lastChevronExpanded = expanded
        end
    end

    row._onToggle = function()
        local controller = rawget(Nvk3UT, "GoldenTrackerController")
        if controller and type(controller.ToggleHeaderExpanded) == "function" then
            controller:ToggleHeaderExpanded()
        end
    end

    return targetRow
end

local function buildEntryControlName(parent)
    local parentName = resolveParentName(parent)
    local index = entryPool.nextId or 1
    entryPool.nextId = index + 1
    return string.format("%s_entryRow%d", parentName, index)
end

local function detachEntryFromUsed(row)
    for index = #entryPool.used, 1, -1 do
        if entryPool.used[index] == row then
            table.remove(entryPool.used, index)
            return
        end
    end
end

local function openGoldenPromotionalEvent(control)
    local context = control and control._goldenContext
    local manager = rawget(_G, "PROMOTIONAL_EVENT_MANAGER") or PROMOTIONAL_EVENT_MANAGER

    if type(manager) == "table" and type(manager.ShowPromotionalEventScene) == "function" then
        local campaignData = nil
        if type(context) == "table" and context.kind == "campaign" then
            campaignData = context.campaignData
        end

        manager:ShowPromotionalEventScene(false, campaignData)
    end

    local campaignLabel = "root"
    if type(context) == "table" and context.kind == "campaign" then
        campaignLabel = context.campaign or context.id or "root"
    end

    safeDebug("[GoldenTracker.UI] Context: open golden promotional event base UI (campaign=%s)", campaignLabel)
end

local function showGoldenEntryContextMenu(control)
    local context = control and control._goldenContext
    if type(context) ~= "table" or context.kind ~= "campaign" then
        return
    end

    if not (ClearMenu and AddCustomMenuItem and ShowMenu) then
        return
    end

    ClearMenu()

    local optionType = (_G and _G.MENU_ADD_OPTION_LABEL) or MENU_ADD_OPTION_LABEL or 1
    AddCustomMenuItem(
        GetString(SI_NVK3UT_TRACKER_GOLDEN_CONTEXT_OPEN_SOURCE_WINDOW),
        function()
            openGoldenPromotionalEvent(control)
        end,
        optionType
    )

    ShowMenu(control)
end

local function createEntryRow(parent)
    local wm = getWindowManager()
    if wm == nil or parent == nil then
        return nil
    end

    local controlName = buildEntryControlName(parent)
    local control = wm:CreateControl(controlName, parent, CT_CONTROL)
    if control.SetResizeToFitDescendents then
        control:SetResizeToFitDescendents(true)
    end
    if control.SetHidden then
        control:SetHidden(false)
    end
    if control.SetMouseEnabled then
        control:SetMouseEnabled(true)
    end
    if control.SetAlpha then
        control:SetAlpha(1)
    end
    if control.SetScale then
        control:SetScale(1)
    end
    control.__rowKind = ROW_KINDS.entry
    control.__height = getEntryRowHeight()
    if control.SetHeight then
        control:SetHeight(control.__height)
    end

    local label = createLabel(control, "EntryTitle")
    if label then
        label:ClearAnchors()
        if label.SetAnchor then
            label:SetAnchor(TOPLEFT, control, TOPLEFT, ENTRY_ICON_SLOT_X + ENTRY_INDENT_X, 0)
        end
        applyLabelDefaults(label, getGoldenTitleFont())
        if label.SetAlpha then
            label:SetAlpha(1)
        end
        if label.SetHidden then
            label:SetHidden(false)
        end
        if label.SetText then
            label:SetText("")
        end
    end

    local row = {
        control = control,
        label = label,
        name = controlName,
        __height = getEntryRowHeight(),
        __rowKind = ROW_KINDS.entry,
        _poolState = "fresh",
    }

    if control then
        control.label = label
    end

    if control and control.SetHandler then
        control:SetHandler("OnMouseUp", function(self, button, upInside)
            if not upInside then
                return
            end

            if button == MOUSE_BUTTON_LEFT then
                local controller = rawget(Nvk3UT, "GoldenTrackerController")
                if controller and type(controller.ToggleEntryExpanded) == "function" then
                    controller:ToggleEntryExpanded()
                end
            elseif button == MOUSE_BUTTON_RIGHT then
                showGoldenEntryContextMenu(self)
            end
        end)

        control:SetHandler("OnMouseEnter", function(ctrl)
            applyMouseoverHighlight(ctrl)
        end)

        control:SetHandler("OnMouseExit", function(ctrl)
            restoreMouseoverHighlight(ctrl)
        end)
    end

    safeDebug("[GoldenEntryPool] create %s", tostring(controlName))

    return row
end

local function resetEntryRowVisuals(row, parent)
    if not row then
        return
    end

    local control = row.control
    if control then
        if control.SetParent then
            control:SetParent(parent)
        end
        if control.ClearAnchors then
            control:ClearAnchors()
        end
        if control.SetHidden then
            control:SetHidden(false)
        end
        if control.SetResizeToFitDescendents then
            control:SetResizeToFitDescendents(true)
        end
        if control.SetMouseEnabled then
            control:SetMouseEnabled(true)
        end
        if control.SetAlpha then
            control:SetAlpha(1)
        end
        if control.SetScale then
            control:SetScale(1)
        end
        control._goldenContext = nil
        control.__rowKind = ROW_KINDS.entry
        control.__height = getEntryRowHeight()
        if control.SetHeight then
            control:SetHeight(control.__height)
        end
    end

    local label = row.label
    if label then
        label:ClearAnchors()
        if label.SetAnchor and control then
            label:SetAnchor(TOPLEFT, control, TOPLEFT, ENTRY_ICON_SLOT_X + ENTRY_INDENT_X, 0)
        end
        applyLabelDefaults(label, getGoldenTitleFont())
        applyLabelColor(label, GOLDEN_COLOR_ROLES.EntryName, getGoldenTrackerColors())
        if label.SetAlpha then
            label:SetAlpha(1)
        end
        if label.SetHidden then
            label:SetHidden(false)
        end
        if label.SetText then
            label:SetText("")
        end
    end

    row.__height = getEntryRowHeight()
    row._poolParent = parent
    row._poolState = "used"

    entryPool.used[#entryPool.used + 1] = row
end

local function acquireEntryRow(parent)
    local row
    if #entryPool.free > 0 then
        row = table.remove(entryPool.free)
        safeDebug(
            "[GoldenEntryPool] reuse %s (used=%d free=%d)",
            tostring(row and row.name),
            #entryPool.used,
            #entryPool.free
        )
    end

    if not row then
        row = createEntryRow(parent)
    end

    if not row then
        return nil
    end

    resetEntryRowVisuals(row, parent)

    return row
end

local function releaseEntryRow(row)
    if not row then
        return
    end

    detachEntryFromUsed(row)

    local control = row.control
    if control then
        if control.SetHidden then
            control:SetHidden(true)
        end
        if control.ClearAnchors then
            control:ClearAnchors()
        end
    end

    local label = row.label
    if label then
        if label.SetText then
            label:SetText("")
        end
        if label.SetHidden then
            label:SetHidden(true)
        end
    end

    row._goldenContext = nil

    row._poolParent = nil
    row._poolState = "free"

    entryPool.free[#entryPool.free + 1] = row

    safeDebug(
        "[GoldenEntryPool] release %s (used=%d free=%d)",
        tostring(row.name),
        #entryPool.used,
        #entryPool.free
    )
end

local function releaseAllEntryRows()
    for index = #entryPool.used, 1, -1 do
        local row = entryPool.used[index]
        entryPool.used[index] = nil
        releaseEntryRow(row)
    end

    safeDebug("[GoldenEntryPool] reset (used=%d free=%d)", #entryPool.used, #entryPool.free)
end

local function buildObjectiveControlName(parent)
    local parentName = resolveParentName(parent)
    local index = objectivePool.nextId or 1
    objectivePool.nextId = index + 1
    return string.format("%s_objectiveRow%d", parentName, index)
end

local function detachObjectiveFromUsed(row)
    for index = #objectivePool.used, 1, -1 do
        if objectivePool.used[index] == row then
            table.remove(objectivePool.used, index)
            return
        end
    end
end

local function createObjectiveRow(parent)
    local wm = getWindowManager()
    if wm == nil or parent == nil then
        return nil
    end

    local controlName = buildObjectiveControlName(parent)
    local control = wm:CreateControl(controlName, parent, CT_CONTROL)
    if control.SetHidden then
        control:SetHidden(false)
    end
    if control.SetMouseEnabled then
        control:SetMouseEnabled(true)
    end
    control.__rowKind = ROW_KINDS.objective

    local label = createLabel(control, "Objective")
    if label then
        label:ClearAnchors()
        if label.SetAnchor then
            label:SetAnchor(TOPLEFT, control, TOPLEFT, DEFAULTS.OBJECTIVE_INDENT_X, 0)
        end
    end

    local pinLabel = createLabel(control, "ObjectivePin")
    if pinLabel then
        pinLabel:ClearAnchors()
        if pinLabel.SetAnchor then
            pinLabel:SetAnchor(
                LEFT,
                control,
                LEFT,
                DEFAULTS.OBJECTIVE_INDENT_X - DEFAULTS.OBJECTIVE_PIN_MARKER_OFFSET_X,
                0
            )
        end
        applyLabelDefaults(pinLabel, getGoldenObjectiveFont())
        if pinLabel.SetText then
            pinLabel:SetText("*")
        end
    end

    local row = {
        control = control,
        label = label,
        pinLabel = pinLabel,
        name = controlName,
        __height = getObjectiveRowHeight(),
        __rowKind = ROW_KINDS.objective,
        _poolState = "fresh",
    }

    return row
end

local function resetObjectiveRowVisuals(row, parent)
    if not row then
        return
    end

    local control = row.control
    if control then
        if control.SetParent then
            control:SetParent(parent)
        end
        if control.SetHidden then
            control:SetHidden(false)
        end
        if control.ClearAnchors then
            control:ClearAnchors()
        end

        local objectiveHeight = getObjectiveRowHeight()
        control.__height = objectiveHeight
        if control.SetHeight then
            control:SetHeight(objectiveHeight)
        end
    end

    local label = row.label
    if label then
        if label.SetHidden then
            label:SetHidden(false)
        end
        label:ClearAnchors()
        if label.SetAnchor then
            label:SetAnchor(TOPLEFT, control, TOPLEFT, DEFAULTS.OBJECTIVE_INDENT_X, 0)
        end
        if label.SetText then
            label:SetText("")
        end
    end

    local pinLabel = row.pinLabel
    if pinLabel then
        if pinLabel.SetHidden then
            pinLabel:SetHidden(true)
        end
        pinLabel:ClearAnchors()
        if pinLabel.SetAnchor then
            pinLabel:SetAnchor(
                LEFT,
                control,
                LEFT,
                DEFAULTS.OBJECTIVE_INDENT_X - DEFAULTS.OBJECTIVE_PIN_MARKER_OFFSET_X,
                0
            )
        end
    end

    row._poolParent = parent
    row._poolState = "used"

    objectivePool.used[#objectivePool.used + 1] = row

    safeDebug(
        "[GoldenObjectivePool] acquire %s (used=%d free=%d)",
        tostring(row.name),
        #objectivePool.used,
        #objectivePool.free
    )
end

local function acquireObjectiveRow(parent)
    local row
    if #objectivePool.free > 0 then
        row = table.remove(objectivePool.free)
    end

    if not row then
        row = createObjectiveRow(parent)
    end

    if not row then
        return nil
    end

    resetObjectiveRowVisuals(row, parent)

    return row
end

local function releaseObjectiveRow(row)
    if not row then
        return
    end

    detachObjectiveFromUsed(row)

    local control = row.control
    if control then
        if control.SetHidden then
            control:SetHidden(true)
        end
        if control.ClearAnchors then
            control:ClearAnchors()
        end
    end

    local label = row.label
    if label then
        if label.SetText then
            label:SetText("")
        end
        if label.SetHidden then
            label:SetHidden(true)
        end
    end

    local pinLabel = row.pinLabel
    if pinLabel then
        if pinLabel.SetHidden then
            pinLabel:SetHidden(true)
        end
        if pinLabel.ClearAnchors then
            pinLabel:ClearAnchors()
        end
    end

    row._poolParent = nil
    row._poolState = "free"

    objectivePool.free[#objectivePool.free + 1] = row

    safeDebug(
        "[GoldenObjectivePool] release %s (used=%d free=%d)",
        tostring(row.name),
        #objectivePool.used,
        #objectivePool.free
    )
end

local function releaseAllObjectiveRows()
    for index = #objectivePool.used, 1, -1 do
        local row = objectivePool.used[index]
        objectivePool.used[index] = nil
        releaseObjectiveRow(row)
    end

    safeDebug("[GoldenObjectivePool] reset (used=%d free=%d)", #objectivePool.used, #objectivePool.free)
end

local function applyEntryRow(row, entryData)
    local targetRow = row and row.control or row
    local label = row and row.label
    if not (targetRow and label) then
        return nil
    end

    if targetRow.SetHidden then
        targetRow:SetHidden(false)
    end

    applyLabelDefaults(label, getGoldenTitleFont())

    if type(entryData) == "table" then
        targetRow._goldenContext = {
            kind = "campaign",
            campaign = entryData.campaignId or entryData.campaignKey or entryData.campaignName,
            id = entryData.entryId or entryData.id,
        }
    else
        targetRow._goldenContext = nil
    end

    local palette = getGoldenTrackerColors()
    local entryExpanded = true
    if type(entryData) == "table" then
        if entryData.isExpanded ~= nil then
            entryExpanded = entryData.isExpanded ~= false
        elseif entryData.expanded ~= nil then
            entryExpanded = entryData.expanded ~= false
        end
    end
    local entryComplete = isCapstoneComplete(entryData)
    local generalMode = type(entryData) == "table" and entryData.generalCompletedMode
    local useCompletedColor = entryComplete and generalMode == "recolor"
    local entryRole = useCompletedColor and GOLDEN_COLOR_ROLES.Completed or GOLDEN_COLOR_ROLES.EntryName
    local colorR, colorG, colorB, colorA, colorSource, colorSourceReason = applyLabelColor(label, entryRole, palette)
    if colorR ~= nil and isGoldenColorDebugEnabled() then
        local stateTokens = {
            entryExpanded and "active" or "inactive",
            entryComplete and "capstoneComplete" or "capstoneOpen",
            generalMode,
        }
        local reason
        if useCompletedColor then
            reason = "Capstone reached with general recolor; using completed color"
        else
            reason = "Campaign entry always uses entry title color"
            if entryExpanded or entryComplete then
                reason = string.format("%s (active/completed state ignored for color)", reason)
            end
        end
        if colorSourceReason and colorSourceReason ~= "" then
            reason = string.format("%s (%s)", reason, colorSourceReason)
        end

        logGoldenColorDecision(
            "golden.campaignEntry",
            table.concat(stateTokens, "+"),
            colorSource or string.format("role.%s", tostring(entryRole)),
            { colorR, colorG, colorB, colorA },
            reason,
            { role = entryRole, palette = palette and palette[entryRole] }
        )
    end

    local text = ""
    if type(entryData) == "table" then
        local display = entryData.campaignName or entryData.displayName or entryData.title or entryData.name
        local completed = tonumber(entryData.completedObjectives or entryData.countCompleted)
        local total = tonumber(entryData.maxRewardTier or entryData.countTotal)
        if completed == nil then
            completed = tonumber(entryData.count) or tonumber(entryData.progressDisplay)
        end
        if total == nil then
            total = tonumber(entryData.max) or tonumber(entryData.maxDisplay)
        end

        local overallCompleted = tonumber(entryData.totalCompletedOverall)
        local capstoneGoal = tonumber(entryData.capstoneGoal or entryData.maxRewardTier or entryData.countTotal)
        if entryComplete and generalMode == "showOpen" then
            if overallCompleted ~= nil then
                completed = overallCompleted
            end
            if capstoneGoal ~= nil then
                total = capstoneGoal
            end
        end

        if completed ~= nil and total ~= nil then
            text = string.format("%s (%d/%d)", tostring(display or ""), completed, total)
        else
            text = tostring(display or "")
        end
    end

    local viewportInfo = getHostViewportInfo()
    if label.ClearAnchors then
        label:ClearAnchors()
    end
    if viewportInfo.align == "right" then
        if label.SetHorizontalAlignment then
            label:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
        end
        if label.SetAnchor then
            label:SetAnchor(TOPRIGHT, targetRow, TOPRIGHT, -(ENTRY_ICON_SLOT_X + ENTRY_INDENT_X), 0)
        end
    else
        if label.SetHorizontalAlignment then
            label:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        end
        if label.SetAnchor then
            label:SetAnchor(TOPLEFT, targetRow, TOPLEFT, ENTRY_ICON_SLOT_X + ENTRY_INDENT_X, 0)
        end
    end

    local availableWidth = computeAvailableWidth(targetRow, ENTRY_ICON_SLOT_X + ENTRY_INDENT_X, 0, 0)
    if label.SetWidth then
        label:SetWidth(availableWidth)
    end
    if label.SetText then
        label:SetText(text)
    end

    local targetHeight = applyGoldenRowMetrics(targetRow, label, availableWidth, getEntryRowHeight())
    if targetHeight then
        row.__height = targetHeight
    end

    debugGoldenWrap(label, "entry", availableWidth, getEntryRowHeight(), targetRow, text)

    if pendingEntryAlignLog and isGoldenColorDebugEnabled() then
        local wrapperWidth = getRowContainerWidth(targetRow)
        local labelWidth
        if label.GetWidth then
            local okWidth, measured = pcall(label.GetWidth, label)
            if okWidth then
                labelWidth = tonumber(measured)
            end
        end
        safeDebug(
            "[EntryAlign] align=%s wrapperWidth=%s labelWidth=%s icon=%s anchors=%s",
            tostring(viewportInfo.align),
            tostring(wrapperWidth),
            tostring(labelWidth),
            "slot",
            tostring(viewportInfo.align)
        )
        pendingEntryAlignLog = false
    end

    return targetRow
end

local function applyObjectiveRow(row, objectiveData)
    local control = row and row.control or row
    local label = row and row.label
    local pinLabel = row and row.pinLabel
    if not (control and label) then
        return nil
    end

    if control.SetHidden then
        control:SetHidden(false)
    end

    local palette = getGoldenTrackerColors()
    local role = isObjectiveCompleted(objectiveData) and GOLDEN_COLOR_ROLES.Completed or GOLDEN_COLOR_ROLES.Objective

    applyLabelDefaults(label, getGoldenObjectiveFont())
    local colorR, colorG, colorB, colorA, colorSource, colorSourceReason = applyLabelColor(label, role, palette)
    if colorR ~= nil and isGoldenColorDebugEnabled() then
        local isCompleted = role == GOLDEN_COLOR_ROLES.Completed
        local stateTokens = {
            isCompleted and "completed" or "open",
        }
        local reason
        if isCompleted then
            reason = "Objective complete; using completed color"
        else
            reason = "Objective in progress; using target color"
        end
        if colorSourceReason and colorSourceReason ~= "" then
            reason = string.format("%s (%s)", reason, colorSourceReason)
        end

        logGoldenColorDecision(
            "golden.objectiveText",
            table.concat(stateTokens, "+"),
            colorSource or string.format("role.%s", tostring(role)),
            { colorR, colorG, colorB, colorA },
            reason,
            { role = role, palette = palette and palette[role] }
        )
    end

    local text = ""
    if type(objectiveData) == "table" then
        local display = objectiveData.displayName or objectiveData.title or objectiveData.name or objectiveData.text
        if display == nil or display == "" then
            display = "Objective"
        end

        local baseText = tostring(display or "")
        local counterText = formatObjectiveCounter(
            objectiveData.progressDisplay or objectiveData.progress or objectiveData.current,
            objectiveData.maxDisplay or objectiveData.max
        )
        if counterText == nil then
            local fallbackCounter = objectiveData.counterText
            if type(fallbackCounter) == "string" and fallbackCounter ~= "" then
                counterText = string.format("(%s)", fallbackCounter)
            end
        end

        text = baseText
        if counterText and counterText ~= "" then
            text = string.format("%s %s", baseText, counterText)
        end

        text = text:gsub("%s+", " "):gsub("%s+%)", ")")
    end

    local viewportInfo = getHostViewportInfo()
    if label.ClearAnchors then
        label:ClearAnchors()
    end
    if viewportInfo.align == "right" then
        if label.SetHorizontalAlignment then
            label:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
        end
        if label.SetAnchor then
            label:SetAnchor(TOPRIGHT, control, TOPRIGHT, -DEFAULTS.OBJECTIVE_INDENT_X, 0)
        end
    else
        if label.SetHorizontalAlignment then
            label:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        end
        if label.SetAnchor then
            label:SetAnchor(TOPLEFT, control, TOPLEFT, DEFAULTS.OBJECTIVE_INDENT_X, 0)
        end
    end
    if pinLabel then
        if pinLabel.ClearAnchors then
            pinLabel:ClearAnchors()
        end
        if viewportInfo.align == "right" then
            if pinLabel.SetAnchor then
                pinLabel:SetAnchor(
                    RIGHT,
                    control,
                    RIGHT,
                    -(DEFAULTS.OBJECTIVE_INDENT_X - DEFAULTS.OBJECTIVE_PIN_MARKER_OFFSET_X),
                    0
                )
            end
        else
            if pinLabel.SetAnchor then
                pinLabel:SetAnchor(
                    LEFT,
                    control,
                    LEFT,
                    DEFAULTS.OBJECTIVE_INDENT_X - DEFAULTS.OBJECTIVE_PIN_MARKER_OFFSET_X,
                    0
                )
            end
        end
    end

    local availableWidth = computeAvailableWidth(control, DEFAULTS.OBJECTIVE_INDENT_X, 0, 0)
    if label.SetWidth then
        label:SetWidth(availableWidth)
    end
    if label.SetText then
        label:SetText(text)
    end

    local targetHeight = applyGoldenRowMetrics(control, label, availableWidth, getObjectiveRowHeight())
    if targetHeight then
        row.__height = targetHeight
    end

    debugGoldenWrap(label, "objective", availableWidth, getObjectiveRowHeight(), control, text)

    if pendingObjectiveAlignLog and isGoldenColorDebugEnabled() then
        local wrapperWidth = getRowContainerWidth(control)
        local labelWidth
        if label.GetWidth then
            local okWidth, measured = pcall(label.GetWidth, label)
            if okWidth then
                labelWidth = tonumber(measured)
            end
        end
        safeDebug(
            "[ObjectiveAlign] align=%s wrapperWidth=%s labelWidth=%s baseOffset=%s side=%s",
            tostring(viewportInfo.align),
            tostring(wrapperWidth),
            tostring(labelWidth),
            tostring(DEFAULTS.OBJECTIVE_INDENT_X),
            tostring(viewportInfo.align)
        )
        pendingObjectiveAlignLog = false
    end

    local isPinned = type(objectiveData) == "table" and objectiveData.isPinned == true
    if pinLabel then
        applyLabelDefaults(pinLabel, getGoldenObjectiveFont())
        if pinLabel.SetHidden then
            pinLabel:SetHidden(not isPinned)
        end
    end

    return control
end

function Rows.AcquireCategoryRow(parent)
    return acquireCategoryRow(parent)
end

function Rows.ReleaseAllCategoryRows()
    releaseAllCategoryRows()
end

function Rows.ApplyCategoryRow(row, categoryData)
    return applyCategoryRow(row, categoryData)
end

function Rows.AcquireEntryRow(parent)
    return acquireEntryRow(parent)
end

function Rows.ReleaseAllEntryRows()
    releaseAllEntryRows()
end

function Rows.ApplyEntryRow(row, entryData)
    return applyEntryRow(row, entryData)
end

function Rows.AcquireObjectiveRow(parent)
    return acquireObjectiveRow(parent)
end

function Rows.ReleaseAllObjectiveRows()
    releaseAllObjectiveRows()
end

function Rows.ApplyObjectiveRow(row, objectiveData)
    return applyObjectiveRow(row, objectiveData)
end

function Rows.ResetAlignmentLog()
    pendingCategoryAlignLog = true
    pendingEntryAlignLog = true
    pendingObjectiveAlignLog = true
end

function Rows.GetCategoryRowHeight()
    return getCategoryRowHeight()
end

function Rows.GetEntryRowHeight()
    return getEntryRowHeight()
end

function Rows.GetObjectiveRowHeight()
    return getObjectiveRowHeight()
end

Nvk3UT.GoldenTrackerRows = Rows

return Rows
