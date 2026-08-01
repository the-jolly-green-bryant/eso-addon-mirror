
local addonName = "Nvk3UT"

Nvk3UT = Nvk3UT or {}

local Rows = {}
Rows.__index = Rows

local MODULE_TAG = addonName .. ".EndeavorTrackerRows"
local LOGGER = LibDebugLogger and LibDebugLogger.Create(MODULE_TAG)

local ROW_TEXT_PADDING_Y = 4

local ROWS_HEIGHTS = {
    category = 26,
    entry = 20,
    sub_info = 18,
    sub_counter = 18,
    sub_progress = 20,
    sub_warning = 18,
    spacing_entry_to_first_sub = 2,
    spacing_between_subrows = 1,
    spacing_after_last_sub = 2,
}

local function applyEndeavorLabelDefaults(label)
    if not label then
        return
    end

    if label.SetHorizontalAlignment then
        label:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    end

    if label.SetVerticalAlignment then
        label:SetVerticalAlignment(TEXT_ALIGN_TOP)
    end

    if label.SetWrapMode then
        label:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
    end

    if label.SetMaxLineCount then
        label:SetMaxLineCount(0)
    end
end

local function getAddon()
    return rawget(_G, addonName)
end

local CATEGORY_TOP_PAD = 0
local CATEGORY_BOTTOM_PAD_EXPANDED = 6
local CATEGORY_BOTTOM_PAD_COLLAPSED = 6
local CATEGORY_ENTRY_SPACING = 3

local ENTRY_TOP_PAD = 0
local ENTRY_BOTTOM_PAD = 0
local ENTRY_ROW_SPACING = 3

local resolvedCategoryHeights = {
    expanded = ROWS_HEIGHTS.category,
    collapsed = ROWS_HEIGHTS.category,
}

local resolvedSubrowHeights = {
    sub_info = ROWS_HEIGHTS.sub_info,
    sub_counter = ROWS_HEIGHTS.sub_counter,
    sub_progress = ROWS_HEIGHTS.sub_progress,
    sub_warning = ROWS_HEIGHTS.sub_warning,
}

local function isDebugEnabled()
    local utils = (Nvk3UT and Nvk3UT.Utils) or Nvk3UT_Utils
    if utils and type(utils.IsDebugEnabled) == "function" then
        local ok, enabled = pcall(utils.IsDebugEnabled)
        if ok and enabled ~= nil then
            return enabled == true
        end
    end

    local diagnostics = (Nvk3UT and Nvk3UT.Diagnostics) or Nvk3UT_Diagnostics
    if diagnostics and type(diagnostics.IsDebugEnabled) == "function" then
        local ok, enabled = pcall(function()
            return diagnostics:IsDebugEnabled()
        end)
        if ok and enabled ~= nil then
            return enabled == true
        end
    end

    local addon = rawget(_G, addonName)
    if type(addon) == "table" and type(addon.IsDebugEnabled) == "function" then
        local ok, enabled = pcall(function()
            return addon:IsDebugEnabled()
        end)
        if ok and enabled ~= nil then
            return enabled == true
        end
    end

    return false
end

local DEFAULT_OBJECTIVE_FONT = "ZoFontGameSmall"
local DEFAULT_FONT_OUTLINE = "soft-shadow-thick"
local DEFAULT_OBJECTIVE_COLOR_ROLE = "objectiveText"
local DEFAULT_TRACKER_COLOR_KIND = "endeavorTracker"
local COMPLETED_COLOR_ROLE = "completed"
local ENTRY_COLOR_ROLE = "entryTitle"
local OBJECTIVE_INDENT_X = 60
local SCROLLBAR_WIDTH_RESERVE = 18
local DEFAULT_MOUSEOVER_HIGHLIGHT_COLOR = { 1, 1, 0.6, 1 }

local SUBROW_ICON_SIZE = 16
local SUBROW_ICON_GAP = 4
local SUBROW_RIGHT_COLUMN_GAP = 8

local function resolveObjectiveIndent(options)
    local indent = options and options.objectiveIndent
    local numeric = tonumber(indent)
    if numeric == nil or numeric ~= numeric then
        return OBJECTIVE_INDENT_X
    end
    if numeric < 0 then
        return OBJECTIVE_INDENT_X
    end
    return numeric
end

local SUBROW_KIND_ALIASES = {
    info = "sub_info",
    description = "sub_info",
    detail = "sub_info",
    text = "sub_info",
    counter = "sub_counter",
    value = "sub_counter",
    count = "sub_counter",
    progress = "sub_progress",
    bar = "sub_progress",
    warning = "sub_warning",
    hint = "sub_warning",
    error = "sub_warning",
    alert = "sub_warning",
}

local CATEGORY_CHEVRON_SIZE = 20
local CATEGORY_LABEL_OFFSET_X = 4
local DEFAULT_CATEGORY_COLOR_ROLE_EXPANDED = "activeTitle"
local DEFAULT_CATEGORY_COLOR_ROLE_COLLAPSED = "categoryTitle"

local DEFAULT_CATEGORY_CHEVRON_TEXTURES = {
    expanded = "EsoUI/Art/Buttons/tree_open_up.dds",
    collapsed = "EsoUI/Art/Buttons/tree_closed_up.dds",
}

local MOUSE_BUTTON_LEFT = rawget(_G, "MOUSE_BUTTON_INDEX_LEFT") or 1

local resolvedEntryHeight = ROWS_HEIGHTS.entry

local function getTrackerHostScrollContentWidth()
    local addon = getAddon()
    local host = type(addon) == "table" and addon.TrackerHost or nil
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

local function getEndeavorRowContainerWidth(control)
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

local function computeEndeavorAvailableWidth(control, indent, leftPadding, rightPadding)
    indent = indent or 0
    leftPadding = leftPadding or 0
    rightPadding = rightPadding or 0

    local containerWidth = getEndeavorRowContainerWidth(control)
    local availableWidth = containerWidth - indent - leftPadding - rightPadding - SCROLLBAR_WIDTH_RESERVE
    if availableWidth < 0 then
        availableWidth = 0
    end

    return availableWidth
end

local function applyEndeavorRowMetrics(control, label, availableWidth, minHeight)
    if not (control and label) then
        return nil
    end

    availableWidth = math.max(0, availableWidth or 0)
    if label.SetWidth then
        label:SetWidth(availableWidth)
    end

    local textHeight = (label.GetTextHeight and label:GetTextHeight()) or 0
    local targetHeight = math.max(minHeight or 0, textHeight + ROW_TEXT_PADDING_Y)

    if control.SetHeight then
        control:SetHeight(targetHeight)
    end

    control.__height = targetHeight

    return targetHeight
end

local function isEndeavorWrapDebugEnabled()
    if type(isGoldenColorDebugEnabled) == "function" then
        return isGoldenColorDebugEnabled() == true
    end

    return isDebugEnabled()
end

local function debugEndeavorWrap(label, rowKind, availableWidth, minHeight, control, text)
    if not (label and control) then
        return
    end

    if type(isEndeavorWrapDebugEnabled) ~= "function" or not isEndeavorWrapDebugEnabled() then
        return
    end

    if type(safeDebug) ~= "function" then
        return
    end

    local width = label.GetWidth and label:GetWidth() or nil
    local textHeight = label.GetTextHeight and label:GetTextHeight() or nil
    local numLines = label.GetNumLines and label:GetNumLines() or nil
    local controlHeight = control.GetHeight and control:GetHeight() or nil
    local storedHeight = control.__height

    safeDebug(
        "[EndeavorWrap] %s: avail=%.1f labelWidth=%.1f textHeight=%.1f lines=%s minHeight=%.1f controlHeight=%.1f storedHeight=%.1f text='%s'",
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

local function getCategoryHeight(expanded)
    if expanded and type(ROWS_HEIGHTS.categoryExpanded) == "number" then
        return ROWS_HEIGHTS.categoryExpanded
    end

    return ROWS_HEIGHTS.category
end

local function resolveEntryHeight(options)
    local height = ROWS_HEIGHTS.entry
    if type(options) == "table" then
        local override = tonumber(options.rowHeight)
        if override and override > 0 then
            height = override
        end
    end

    resolvedEntryHeight = height
    return height
end

local function FormatParensCount(a, b)
    local aNum = tonumber(a) or 0
    if aNum < 0 then
        aNum = 0
    end

    local bNum = tonumber(b) or 1
    if bNum < 1 then
        bNum = 1
    end

    if aNum > bNum then
        aNum = bNum
    end

    return string.format("(%d/%d)", math.floor(aNum + 0.5), math.floor(bNum + 0.5))
end

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

local loggedSubrowsOnce = false
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

local function safeDebug(fmt, ...)
    if not isDebugEnabled() then
        return
    end

    local root = rawget(_G, addonName)
    if type(root) ~= "table" then
        return
    end

    local diagnostics = root.Diagnostics
    if diagnostics and type(diagnostics.DebugIfEnabled) == "function" then
        diagnostics:DebugIfEnabled("EndeavorTrackerRows", fmt, ...)
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

local function onEntryMouseUp(control, button, upInside)
    if control == nil or upInside ~= true then
        return
    end

    if button == MOUSE_BUTTON_LEFT then
        local onLeftClick = control._entryOnLeftClick
        if type(onLeftClick) == "function" then
            onLeftClick(control)
        end
    end
end

local function normalizeSubrowKind(kind)
    local key = kind
    if type(key) ~= "string" then
        key = tostring(key or "")
    end
    key = key or ""
    if key ~= "" then
        local lowered = string.lower(key)
        if SUBROW_KIND_ALIASES[lowered] then
            return SUBROW_KIND_ALIASES[lowered]
        end
        if ROWS_HEIGHTS[lowered] then
            return lowered
        end
        if ROWS_HEIGHTS[key] then
            return key
        end
    end

    return "sub_info"
end

local function resolveSubrowSpacing(key)
    local value = ROWS_HEIGHTS[key]
    if type(value) ~= "number" then
        return 0
    end
    if value ~= value then
        return 0
    end
    if value < 0 then
        return 0
    end
    return value
end

local function sanitizeSubrows(source)
    local sanitized = {}
    local visibleCount = 0

    if type(source) == "table" then
        for _, entry in ipairs(source) do
            if type(entry) == "table" then
                local normalizedKind = normalizeSubrowKind(entry.kind or entry.type or entry[1])
                local visible
                if entry.visible ~= nil then
                    visible = entry.visible ~= false
                elseif entry.hidden ~= nil then
                    visible = entry.hidden ~= true
                else
                    visible = true
                end

                local sanitizedEntry = {
                    kind = normalizedKind,
                    source = entry,
                    visible = visible,
                    hidden = not visible,
                }

                if visible then
                    visibleCount = visibleCount + 1
                end

                sanitized[#sanitized + 1] = sanitizedEntry
            end
        end
    end

    return sanitized, visibleCount
end

local function acquireSubrowControl(row, container, index)
    if row == nil or container == nil then
        return nil
    end

    local wm = WINDOW_MANAGER
    if wm == nil then
        return nil
    end

    local prefix = row._subrowPrefix
    if type(prefix) ~= "string" or prefix == "" then
        local rowName = type(row.GetName) == "function" and row:GetName() or "Nvk3UT_Endeavor_Row"
        prefix = string.format("%s_Subrow", tostring(rowName))
        row._subrowPrefix = prefix
    end

    row._subrowControls = row._subrowControls or {}

    local existing = row._subrowControls[index]
    if existing then
        if existing.SetParent then
            existing:SetParent(container)
        end
        if existing.SetMouseEnabled then
            existing:SetMouseEnabled(true)
        end
        if existing.SetHidden then
            existing:SetHidden(true)
        end
        if existing.SetHandler then
            existing:SetHandler("OnMouseUp", ignoreObjectiveMouseUp)
        end
        return existing
    end

    local controlName = string.format("%s%d", prefix, index)
    local control = GetControl(controlName)
    if not control then
        control = wm:CreateControl(controlName, container, CT_CONTROL)
    else
        control:SetParent(container)
    end

    control:SetResizeToFitDescendents(false)
    control:SetMouseEnabled(true)
    control:SetHidden(true)
    if control.SetHandler then
        control:SetHandler("OnMouseUp", ignoreObjectiveMouseUp)
    end
    control._subrowOwner = row

    row._subrowControls[index] = control

    return control
end

local function hideUnusedSubrows(row, startIndex)
    if row == nil then
        return
    end

    local controls = row._subrowControls
    if type(controls) ~= "table" then
        return
    end

    for index = startIndex, #controls do
        local control = controls[index]
        if control then
            if control.SetHidden then
                control:SetHidden(true)
            end
            if control.ClearAnchors then
                control:ClearAnchors()
            end
        end
    end
end

local function ignoreObjectiveMouseUp()
    -- Intentionally ignore clicks on Endeavor objective subrows; only entry rows should react.
end

local function ensureSubrowLeftLabel(control)
    if control == nil then
        return nil
    end

    local wm = WINDOW_MANAGER
    if wm == nil then
        return nil
    end

    local label = control.Label
    if label then
        label:SetParent(control)
    else
        local controlName = type(control.GetName) == "function" and control:GetName() or ""
        local labelName = controlName ~= "" and (controlName .. "Label") or nil
        if labelName then
            label = GetControl(labelName)
        end
        if not label then
            local fallbackBase = controlName ~= "" and controlName or string.gsub(tostring(control or "subrow"), "[^%w_]", "_")
            label = wm:CreateControl((labelName or (fallbackBase .. "Label")), control, CT_LABEL)
        else
            label:SetParent(control)
        end
    end

    label:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    if label.SetWrapMode then
        label:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
    end

    control.Label = label

    return label
end

local function ensureSubrowRightLabel(control)
    if control == nil then
        return nil
    end

    local wm = WINDOW_MANAGER
    if wm == nil then
        return nil
    end

    local label = control.RightLabel
    if label then
        label:SetParent(control)
    else
        local controlName = type(control.GetName) == "function" and control:GetName() or ""
        local labelName = controlName ~= "" and (controlName .. "Right") or nil
        if labelName then
            label = GetControl(labelName)
        end
        if not label then
            local fallbackBase = controlName ~= "" and controlName or string.gsub(tostring(control or "subrow"), "[^%w_]", "_")
            label = wm:CreateControl((labelName or (fallbackBase .. "Right")), control, CT_LABEL)
        else
            label:SetParent(control)
        end
    end

    label:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    if label.SetWrapMode then
        label:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
    end

    control.RightLabel = label

    return label
end

local function ensureSubrowIcon(control)
    if control == nil then
        return nil
    end

    local wm = WINDOW_MANAGER
    if wm == nil then
        return nil
    end

    local icon = control.Icon
    if icon then
        icon:SetParent(control)
    else
        local controlName = type(control.GetName) == "function" and control:GetName() or ""
        local iconName = controlName ~= "" and (controlName .. "Icon") or nil
        if iconName then
            icon = GetControl(iconName)
        end
        if not icon then
            local fallbackBase = controlName ~= "" and controlName or string.gsub(tostring(control or "subrow"), "[^%w_]", "_")
            icon = wm:CreateControl((iconName or (fallbackBase .. "Icon")), control, CT_TEXTURE)
        else
            icon:SetParent(control)
        end
    end

    if icon.SetMouseEnabled then
        icon:SetMouseEnabled(false)
    end
    if icon.SetHidden then
        icon:SetHidden(true)
    end
    if icon.SetDimensions then
        icon:SetDimensions(SUBROW_ICON_SIZE, SUBROW_ICON_SIZE)
    end

    control.Icon = icon

    return icon
end

function Rows.ApplySubrow(control, kind, data, options)
    if control == nil then
        return
    end

    local resolvedKind = normalizeSubrowKind(kind)
    local source = type(data) == "table" and data or {}
    local viewportInfo = getHostViewportInfo()
    local align = viewportInfo.align

    local icon = ensureSubrowIcon(control)
    local iconTexture = type(source.icon) == "string" and source.icon or nil
    if icon then
        if iconTexture and iconTexture ~= "" then
            icon:SetHidden(false)
            if icon.SetTexture then
                icon:SetTexture(iconTexture)
            end
            if icon.ClearAnchors then
                icon:ClearAnchors()
            end
            local indentX = resolveObjectiveIndent(options)
            if align == "right" then
                icon:SetAnchor(RIGHT, control, RIGHT, -(indentX - SUBROW_ICON_SIZE - SUBROW_ICON_GAP), 0)
            else
                icon:SetAnchor(LEFT, control, LEFT, indentX - SUBROW_ICON_SIZE - SUBROW_ICON_GAP, 0)
            end
        else
            if icon.SetTexture then
                icon:SetTexture(nil)
            end
            icon:SetHidden(true)
        end
    end

    local leftLabel = ensureSubrowLeftLabel(control)
    local rightLabel = ensureSubrowRightLabel(control)

    if leftLabel then
        leftLabel:ClearAnchors()
        if icon and icon.IsHidden and not icon:IsHidden() then
            if align == "right" then
                leftLabel:SetAnchor(TOPRIGHT, icon, TOPLEFT, -SUBROW_ICON_GAP, 0)
            else
                leftLabel:SetAnchor(TOPLEFT, icon, TOPRIGHT, SUBROW_ICON_GAP, 0)
            end
        else
            if align == "right" then
                leftLabel:SetAnchor(TOPRIGHT, control, TOPRIGHT, -resolveObjectiveIndent(options), 0)
            else
                leftLabel:SetAnchor(TOPLEFT, control, TOPLEFT, resolveObjectiveIndent(options), 0)
            end
        end
    end

    local rightText = ""
    if type(source) == "table" then
        rightText = source.rightText or source.value or source.counterText or ""
    end
    rightText = tostring(rightText or "")

    if rightLabel then
        rightLabel:ClearAnchors()
        if rightText ~= "" then
            if rightLabel.SetHidden then
                rightLabel:SetHidden(false)
            end
            if rightLabel.SetText then
                rightLabel:SetText(rightText)
            end
            if align == "right" then
                rightLabel:SetAnchor(TOPLEFT, control, TOPLEFT, 0, 0)
            else
                rightLabel:SetAnchor(TOPRIGHT, control, TOPRIGHT, 0, 0)
            end
        else
            if rightLabel.SetHidden then
                rightLabel:SetHidden(true)
            end
            if rightLabel.SetText then
                rightLabel:SetText("")
            end
        end
    end

    local text = ""
    if type(source) == "table" then
        text = source.text or source.label or source.description or ""
    end
    text = tostring(text or "")
    if leftLabel and leftLabel.SetText then
        leftLabel:SetText(text)
    end

    local font = type(source) == "table" and source.font or nil
    local fallbackFont = options and options.font or DEFAULT_OBJECTIVE_FONT
    local resolvedFont = font or fallbackFont
    if leftLabel then
        applyEndeavorLabelDefaults(leftLabel)
        applyFontString(leftLabel, resolvedFont, nil)
        if leftLabel.SetHorizontalAlignment then
            if align == "right" then
                leftLabel:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
            else
                leftLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
            end
        end
    end

    if rightLabel then
        local rightFont = type(source) == "table" and (source.rightFont or source.font) or nil
        applyEndeavorLabelDefaults(rightLabel)
        applyFontString(rightLabel, rightFont or fallbackFont, nil)
        if rightLabel.SetHorizontalAlignment then
            if align == "right" then
                rightLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
            else
                rightLabel:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
            end
        end
    end

    local r, g, b, a
    if type(source) == "table" then
        r, g, b, a = extractColorComponents(source.color)
    end
    if r == nil then
        local colorRole
        if type(source) == "table" and type(source.colorRole) == "string" then
            colorRole = source.colorRole
        else
            colorRole = DEFAULT_OBJECTIVE_COLOR_ROLE
        end
        r, g, b, a = getTrackerColor(colorRole, options and options.colorKind)
    end
    r, g, b, a = r or 1, g or 1, b or 1, a or 1

    if leftLabel and leftLabel.SetColor then
        leftLabel:SetColor(r, g, b, a)
    end
    if rightLabel and rightLabel.SetColor then
        rightLabel:SetColor(r, g, b, a)
    end

    if pendingObjectiveAlignLog and isDebugEnabled() then
        local wrapperWidth = getEndeavorRowContainerWidth(control)
        local labelWidth
        if leftLabel and leftLabel.GetWidth then
            local okWidth, measured = pcall(leftLabel.GetWidth, leftLabel)
            if okWidth then
                labelWidth = tonumber(measured)
            end
        end
        local baseOffset = resolveObjectiveIndent(options)
        safeDebug(
            "[ObjectiveAlign] align=%s wrapperWidth=%s labelWidth=%s baseOffset=%s side=%s",
            tostring(align),
            tostring(wrapperWidth),
            tostring(labelWidth),
            tostring(baseOffset),
            tostring(align)
        )
        pendingObjectiveAlignLog = false
    end

    local availableWidth = computeEndeavorAvailableWidth(control, resolveObjectiveIndent(options), 0, 0)
    if leftLabel and leftLabel.SetWidth then
        leftLabel:SetWidth(availableWidth)
    end

    local minHeight = ROWS_HEIGHTS[resolvedKind] or 0
    local targetHeight = applyEndeavorRowMetrics(control, leftLabel, availableWidth, minHeight)
    if targetHeight then
        resolvedSubrowHeights[resolvedKind] = targetHeight
    end

    if leftLabel then
        debugEndeavorWrap(leftLabel, resolvedKind, availableWidth, minHeight, control, text)
    end

    if control.SetAlpha then
        control:SetAlpha(1)
    end
    if control.SetHidden then
        control:SetHidden(false)
    end

    control._subrowKind = resolvedKind
    control._subrowSource = source

    return control
end

local function getTrackerColor(role, colorKind)
    local addon = getAddon()
    if type(addon) ~= "table" then
        return 1, 1, 1, 1
    end

    local host = rawget(addon, "TrackerHost")
    if type(host) ~= "table" then
        return 1, 1, 1, 1
    end

    if type(host.EnsureAppearanceDefaults) == "function" then
        pcall(host.EnsureAppearanceDefaults, host)
    end

    local getColor = host.GetTrackerColor
    if type(getColor) ~= "function" then
        return 1, 1, 1, 1
    end

    local ok, r, g, b, a = pcall(getColor, host, colorKind or DEFAULT_TRACKER_COLOR_KIND, role)
    if ok and type(r) == "number" then
        return r, g or 1, b or 1, a or 1
    end

    return 1, 1, 1, 1
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

local function getMouseoverHighlightColor()
    local addon = getAddon()
    local host = type(addon) == "table" and addon.TrackerHost or nil
    if type(host) == "table" then
        if type(host.EnsureAppearanceDefaults) == "function" then
            pcall(host.EnsureAppearanceDefaults, host)
        end

        if type(host.GetMouseoverHighlightColor) == "function" then
            local ok, r, g, b, a = pcall(host.GetMouseoverHighlightColor, host, "endeavorTracker")
            if ok and r and g and b and a then
                return r, g, b, a
            end
        end
    end

    return unpack(DEFAULT_MOUSEOVER_HIGHLIGHT_COLOR)
end

local function applyMouseoverHighlight(control)
    if control ~= nil and control._subrowOwner ~= nil then
        -- Subrows/objectives should not receive hover highlight; only header entry rows are eligible.
        return
    end

    local label = control and (control.label or control.Label)
    if not (label and label.SetColor) then
        return
    end

    local r, g, b, a = getMouseoverHighlightColor()
    label:SetColor(r, g, b, a)

    safeDebug(
        "Endeavor hover: applying mouseover highlight color r=%.3f g=%.3f b=%.3f a=%.3f",
        r or 0,
        g or 0,
        b or 0,
        a or 0
    )
end

local function restoreMouseoverHighlight(control)
    if control ~= nil and control._subrowOwner ~= nil then
        return
    end

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
        "Endeavor hover: restored base color r=%.3f g=%.3f b=%.3f a=%.3f",
        color[1] or 0,
        color[2] or 0,
        color[3] or 0,
        color[4] or 0
    )

    if resetFn ~= nil then
        safeDebug("Endeavor hover: missing restore callback, applied base color fallback")
    end
end

local function applyFontString(label, font, fallback)
    if not (label and label.SetFont) then
        return
    end

    local resolved = font
    if resolved == nil or resolved == "" then
        resolved = fallback
    end

    if resolved and resolved ~= "" then
        label:SetFont(resolved)
    end
end

local function clampFontSize(value)
    local numeric = tonumber(value)
    if numeric == nil then
        return nil
    end

    numeric = math.floor(numeric + 0.5)
    if numeric < 12 then
        numeric = 12
    elseif numeric > 36 then
        numeric = 36
    end

    return numeric
end

local function BuildFontString(face, size, outline)
    return string.format("%s|%d|%s", face, size, outline)
end

local function extractColorComponents(color)
    if type(color) ~= "table" then
        return nil
    end

    local r = tonumber(color.r or color[1])
    local g = tonumber(color.g or color[2])
    local b = tonumber(color.b or color[3])
    local a = tonumber(color.a or color[4] or 1)

    if r == nil or g == nil or b == nil then
        return nil
    end

    if r < 0 then
        r = 0
    elseif r > 1 then
        r = 1
    end

    if g < 0 then
        g = 0
    elseif g > 1 then
        g = 1
    end

    if b < 0 then
        b = 0
    elseif b > 1 then
        b = 1
    end

    if a < 0 then
        a = 0
    elseif a > 1 then
        a = 1
    end

    return r, g, b, a
end

local function ApplyFont(control, cfg)
    if not (control and control.SetFont) then
        return false
    end

    if type(cfg) ~= "table" then
        return false
    end

    local face = cfg.Face or cfg.face
    if type(face) ~= "string" or face == "" then
        return false
    end

    local size = clampFontSize(cfg.Size or cfg.size)
    if size == nil then
        return false
    end

    local outline = cfg.Outline or cfg.outline or DEFAULT_FONT_OUTLINE
    if type(outline) ~= "string" or outline == "" then
        outline = DEFAULT_FONT_OUTLINE
    end

    control:SetFont(BuildFontString(face, size, outline))
    return true
end

local function getContainerName(parent)
    if parent and type(parent.GetName) == "function" then
        local ok, name = pcall(parent.GetName, parent)
        if ok and type(name) == "string" and name ~= "" then
            return name
        end
    end

    return "Nvk3UT_Endeavor"
end

local function buildEntryControlName(parent, index)
    local containerName = getContainerName(parent)
    local controlName = string.format("%s_Entry", containerName)

    if type(index) == "number" and index > 1 then
        controlName = string.format("%s%d", controlName, index)
    end

    return controlName
end

local function buildCategoryControlName(parent, index)
    local containerName = getContainerName(parent)
    local controlName = string.format("%s_Category", containerName)

    if type(index) == "number" and index > 1 then
        controlName = string.format("%s%d", controlName, index)
    end

    return controlName
end

local function ensureCategoryChild(control, childName, childType)
    local wm = WINDOW_MANAGER
    if wm == nil or control == nil then
        return nil
    end

    local child = GetControl(childName)
    if not child then
        child = wm:CreateControl(childName, control, childType)
    else
        child:SetParent(control)
    end

    return child
end

local function ensureEntryChild(control, childName, childType)
    local wm = WINDOW_MANAGER
    if wm == nil or control == nil then
        return nil
    end

    local child = GetControl(childName)
    if not child then
        child = wm:CreateControl(childName, control, childType)
    else
        child:SetParent(control)
    end

    return child
end

local function createEntryRow(parent)
    local wm = WINDOW_MANAGER
    if wm == nil then
        return nil
    end

    local index = entryPool.nextId or 1
    local controlName = buildEntryControlName(parent, index)
    entryPool.nextId = index + 1

    local control = GetControl(controlName)
    if not control then
        control = wm:CreateControl(controlName, parent, CT_CONTROL)
    else
        control:SetParent(parent)
    end

    control:SetResizeToFitDescendents(false)
    control:SetMouseEnabled(false)
    control:SetHidden(false)
    control._poolState = "fresh"
    control._poolParent = parent
    control._subrowPrefix = controlName .. "Subrow"

    safeDebug("[EntryPool] create %s", controlName)

    return control
end

local function popFreeEntryRow()
    while #entryPool.free > 0 do
        local row = table.remove(entryPool.free)
        if row then
            local isValid = true
            if type(row.GetName) == "function" then
                local name = row:GetName()
                if type(name) == "string" and name ~= "" then
                    if GetControl(name) ~= row then
                        isValid = false
                    end
                end
            end

            if isValid then
                return row
            end
        end
    end

    return nil
end

local function markEntryUsed(row, parent)
    if not row then
        return
    end

    row._poolState = "used"
    row._poolParent = parent
    entryPool.used[#entryPool.used + 1] = row
end

local function detachEntryFromUsed(row)
    if not row then
        return
    end

    for index = #entryPool.used, 1, -1 do
        if entryPool.used[index] == row then
            table.remove(entryPool.used, index)
            break
        end
    end
end

local function acquireEntryRow(parent)
    if parent == nil then
        return nil
    end

    local row = popFreeEntryRow()
    if row then
        if row.SetParent then
            row:SetParent(parent)
        end
        if row.SetHidden then
            row:SetHidden(false)
        end
    else
        row = createEntryRow(parent)
    end

    if not row then
        return nil
    end

    if row.ClearAnchors then
        row:ClearAnchors()
    end
    if row.SetResizeToFitDescendents then
        row:SetResizeToFitDescendents(false)
    end
    if row.SetMouseEnabled then
        row:SetMouseEnabled(true)
    end

    markEntryUsed(row, parent)

    local controlName = type(row.GetName) == "function" and row:GetName() or "<unnamed>"
    safeDebug("[EntryPool] acquire %s free=%d used=%d", tostring(controlName), #entryPool.free, #entryPool.used)

    return row
end

local function resetEntryRowContent(row)
    if row == nil then
        return
    end

    local rowName = type(row.GetName) == "function" and row:GetName() or nil

    local label = row.Label
    if not label and rowName then
        label = GetControl(rowName .. "Title")
    end
    if label then
        if label.SetText then
            label:SetText("")
        end
        if label.SetHidden then
            label:SetHidden(false)
        end
    end
    row.Label = nil

    local progress = row.Progress
    if not progress and rowName then
        progress = GetControl(rowName .. "Progress")
    end
    if progress then
        if progress.SetText then
            progress:SetText("")
        end
        if progress.SetHidden then
            progress:SetHidden(true)
        end
    end
    row.Progress = nil

    if row.GetNamedChild then
        local bullet = row:GetNamedChild("Bullet")
        if bullet and bullet.SetHidden then
            bullet:SetHidden(true)
        end
        local icon = row:GetNamedChild("Icon")
        if icon and icon.SetHidden then
            icon:SetHidden(true)
        end
        local dot = row:GetNamedChild("Dot")
        if dot and dot.SetHidden then
            dot:SetHidden(true)
        end
        local check = row:GetNamedChild("Check")
        if check and check.SetHidden then
            check:SetHidden(true)
        end
    end

    if type(row._subrowControls) == "table" then
        for index = 1, #row._subrowControls do
            local control = row._subrowControls[index]
            if control then
                if control.SetHidden then
                    control:SetHidden(true)
                end
                if control.ClearAnchors then
                    control:ClearAnchors()
                end
            end
        end
    end

    row._subrows = nil
    row._subrowCount = 0
    row._subrowsVisibleCount = 0
    row._entryOnLeftClick = nil
    row._entryContext = nil
end

local function releaseEntryRow(row)
    if not row then
        return
    end

    resetEntryRowContent(row)

    if row.ClearAnchors then
        row:ClearAnchors()
    end
    if row.SetHidden then
        row:SetHidden(true)
    end

    detachEntryFromUsed(row)

    row._poolParent = nil
    row._poolState = "free"

    entryPool.free[#entryPool.free + 1] = row

    local controlName = type(row.GetName) == "function" and row:GetName() or "<unnamed>"
    safeDebug("[EntryPool] release %s free=%d used=%d", tostring(controlName), #entryPool.free, #entryPool.used)
end

local function resetEntryPool(targetParent)
    if targetParent == nil then
        for index = #entryPool.used, 1, -1 do
            releaseEntryRow(entryPool.used[index])
        end
    else
        for index = #entryPool.used, 1, -1 do
            local row = entryPool.used[index]
            if row and (row._poolParent == targetParent or (row.GetParent and row:GetParent() == targetParent)) then
                releaseEntryRow(row)
            end
        end
    end

    safeDebug("[EntryPool] reset target=%s free=%d used=%d", tostring(targetParent), #entryPool.free, #entryPool.used)
end

local function createCategoryRow(parent)
    local wm = WINDOW_MANAGER
    if wm == nil then
        return nil
    end

    local index = categoryPool.nextId or 1
    local controlName = buildCategoryControlName(parent, index)
    categoryPool.nextId = index + 1

    local control = GetControl(controlName)
    if not control then
        control = wm:CreateControl(controlName, parent, CT_CONTROL)
    else
        control:SetParent(parent)
    end

    control:SetResizeToFitDescendents(false)
    control:SetHeight(getCategoryHeight(false))
    control:SetMouseEnabled(true)
    control:SetHidden(false)

    local indentName = controlName .. "IndentAnchor"
    local indentAnchor = ensureCategoryChild(control, indentName, CT_CONTROL)
    if not indentAnchor then
        return nil
    end

    indentAnchor:SetHidden(false)
    indentAnchor:SetDimensions(1, 1)
    if indentAnchor.ClearAnchors then
        indentAnchor:ClearAnchors()
    end
    indentAnchor:SetAnchor(TOPLEFT, control, TOPLEFT, 0, 0)

    local chevronName = controlName .. "Chevron"
    local chevron = ensureCategoryChild(control, chevronName, CT_TEXTURE)
    if chevron then
        if indentAnchor and chevron.SetParent then
            chevron:SetParent(indentAnchor)
        end
        chevron:SetMouseEnabled(false)
        chevron:SetHidden(false)
        chevron:SetDimensions(CATEGORY_CHEVRON_SIZE, CATEGORY_CHEVRON_SIZE)
        if chevron.ClearAnchors then
            chevron:ClearAnchors()
        end
        chevron:SetAnchor(TOPLEFT, indentAnchor, TOPLEFT, 0, 0)
        if chevron.SetTexture then
            chevron:SetTexture(DEFAULT_CATEGORY_CHEVRON_TEXTURES.collapsed)
        end
    end

    local labelName = controlName .. "Label"
    local label = ensureCategoryChild(control, labelName, CT_LABEL)
    if label then
        if indentAnchor and label.SetParent then
            label:SetParent(indentAnchor)
        end
        label:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        label:SetVerticalAlignment(TEXT_ALIGN_TOP)
        if label.SetWrapMode then
            label:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
        end
        if label.ClearAnchors then
            label:ClearAnchors()
        end
        label:SetAnchor(TOPLEFT, chevron, TOPRIGHT, CATEGORY_LABEL_OFFSET_X, 0)
        if label.SetHidden then
            label:SetHidden(false)
        end
    end

    local row = {
        control = control,
        label = label,
        chevron = chevron,
        indentAnchor = indentAnchor,
        name = controlName,
        _poolState = "fresh",
    }

    if control then
        control.label = label
        control.indentAnchor = indentAnchor
    end

    if control and control.SetHandler then
        local function onMouseUp(_, button, upInside)
            if button == MOUSE_BUTTON_LEFT and upInside then
                local callback = row._onToggle
                if type(callback) == "function" then
                    callback()
                end
            end
        end
        control:SetHandler("OnMouseUp", onMouseUp)
        row._mouseHandler = onMouseUp

        control:SetHandler("OnMouseEnter", function(ctrl)
            applyMouseoverHighlight(ctrl)
        end)

        control:SetHandler("OnMouseExit", function(ctrl)
            restoreMouseoverHighlight(ctrl)
        end)

    end

    safeDebug("[CategoryPool] create %s", controlName)

    return row
end

local function markRowUsed(row)
    if not row then
        return
    end

    row._poolState = "used"
    categoryPool.used[#categoryPool.used + 1] = row
end

local function detachFromUsed(row)
    if not row then
        return
    end

    for index = #categoryPool.used, 1, -1 do
        if categoryPool.used[index] == row then
            table.remove(categoryPool.used, index)
            break
        end
    end
end

local function clampColorComponent(value, defaultValue)
    local numeric = tonumber(value)
    if numeric == nil then
        return defaultValue
    end

    if numeric < 0 then
        numeric = 0
    elseif numeric > 1 then
        numeric = 1
    end

    return numeric
end

local function sanitizeNumericColor(r, g, b, a)
    if r == nil or g == nil or b == nil then
        return nil
    end

    return clampColorComponent(r, 1), clampColorComponent(g, 1), clampColorComponent(b, 1), clampColorComponent(a, 1)
end

local function sanitizeColorResult(value1, value2, value3, value4)
    if type(value1) == "table" and value2 == nil and value3 == nil and value4 == nil then
        local colorTable = value1
        if type(colorTable.UnpackRGBA) == "function" then
            local ok, r, g, b, a = pcall(colorTable.UnpackRGBA, colorTable)
            if ok then
                local sr, sg, sb, sa = sanitizeNumericColor(r, g, b, a)
                if sr ~= nil then
                    return sr, sg, sb, sa
                end
            end
        end

        local r, g, b, a = extractColorComponents(colorTable)
        if r ~= nil then
            return r, g, b, a
        end
    end

    return sanitizeNumericColor(value1, value2, value3, value4)
end

local function coerceFunctionColor(entry, context, role, colorKind)
    if type(entry) ~= "function" then
        return nil
    end

    local ok, value1, value2, value3, value4 = pcall(entry, context, role, colorKind)
    if not ok then
        safeDebug("[CategoryRow] color function failed for role=%s: %s", tostring(role), tostring(value1))
        return nil
    end

    return sanitizeColorResult(value1, value2, value3, value4)
end

local function resolvePaletteEntry(palette, role, colorKind)
    if type(palette) ~= "table" then
        return nil
    end

    local entry = palette[role]
    if type(entry) == "function" then
        return coerceFunctionColor(entry, palette, role, colorKind)
    elseif type(entry) == "table" then
        local r, g, b, a = extractColorComponents(entry)
        if r ~= nil then
            return r, g, b, a
        end
    end

    return nil
end

local function resolveColor(role, overrideColors, colorKind)
    local resolvedKind = colorKind
    if type(resolvedKind) ~= "string" or resolvedKind == "" then
        resolvedKind = DEFAULT_TRACKER_COLOR_KIND
    end

    if type(overrideColors) == "table" then
        local overrideEntry = overrideColors[role]
        if type(overrideEntry) == "function" then
            local r, g, b, a = coerceFunctionColor(overrideEntry, overrideColors, role, resolvedKind)
            if r ~= nil then
                return r, g, b, a
            end
        elseif type(overrideEntry) == "table" then
            local r, g, b, a = extractColorComponents(overrideEntry)
            if r ~= nil then
                return r, g, b, a
            end
        end
    end

    local addon = getAddon()
    local colors = addon and addon.Colors
    if type(colors) == "table" then
        local r, g, b, a = resolvePaletteEntry(colors[resolvedKind], role, resolvedKind)
        if r ~= nil then
            return r, g, b, a
        end

        r, g, b, a = resolvePaletteEntry(colors.default, role, resolvedKind)
        if r ~= nil then
            return r, g, b, a
        end
    end

    return 1, 1, 1, 1
end

local function applyCategoryColor(label, role, overrideColors, colorKind)
    if not (label and label.SetColor) then
        return
    end

    local r, g, b, a = resolveColor(role, overrideColors, colorKind)
    applyBaseColor(label, r, g, b, a)

    if label.SetAlpha then
        label:SetAlpha(1)
    end
end

local function acquireCategoryRow(parent)
    local row = table.remove(categoryPool.free)
    if not row then
        row = createCategoryRow(parent)
    end

    if not row then
        return nil
    end

    local control = row.control
    if control then
        if parent and control.GetParent and control:GetParent() ~= parent then
            control:SetParent(parent)
        elseif parent then
            control:SetParent(parent)
        end

        if control.ClearAnchors then
            control:ClearAnchors()
        end
        if control.SetHidden then
            control:SetHidden(false)
        end
        if control.SetResizeToFitDescendents then
            control:SetResizeToFitDescendents(false)
        end
        if control.SetHeight then
            control:SetHeight(getCategoryHeight(false))
        end
        if control.SetMouseEnabled then
            control:SetMouseEnabled(true)
        end
    end

    local label = row.label
    if label then
        if label.SetHidden then
            label:SetHidden(false)
        end
    end

    local chevron = row.chevron
    if chevron then
        if chevron.SetHidden then
            chevron:SetHidden(false)
        end
        if chevron.SetDimensions then
            chevron:SetDimensions(CATEGORY_CHEVRON_SIZE, CATEGORY_CHEVRON_SIZE)
        end
        if chevron.ClearAnchors then
            chevron:ClearAnchors()
            chevron:SetAnchor(TOPLEFT, row.indentAnchor or control, TOPLEFT, 0, 0)
        end
    end

    markRowUsed(row)

    safeDebug("[CategoryPool] acquire %s (used=%d free=%d)", tostring(row.name), #categoryPool.used, #categoryPool.free)

    return row
end

local function releaseCategoryRow(row)
    if not row or row._poolState == "free" then
        return
    end

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

    row._onToggle = nil
    row._poolState = "free"

    categoryPool.free[#categoryPool.free + 1] = row

    safeDebug("[CategoryPool] release %s (used=%d free=%d)", tostring(row.name), #categoryPool.used, #categoryPool.free)
end

local function resetCategoryPool()
    for index = #categoryPool.used, 1, -1 do
        local row = categoryPool.used[index]
        categoryPool.used[index] = nil
        releaseCategoryRow(row)
    end

    safeDebug("[CategoryPool] reset (used=%d free=%d)", #categoryPool.used, #categoryPool.free)
end

local function applyCategoryRow(row, data)
    if type(row) ~= "table" then
        return
    end

    local control = row.control
    local label = row.label
    local chevron = row.chevron
    if not (control and label and chevron) then
        return
    end

    local info = type(data) == "table" and data or {}
    local title = tostring(info.title or GetString(SI_NVK3UT_TRACKER_ENDEAVOR_CATEGORY_ROOT))
    if title == "" then
        title = GetString(SI_NVK3UT_TRACKER_ENDEAVOR_CATEGORY_ROOT)
    end

    local remaining = tonumber(info.remaining)
    if remaining == nil then
        remaining = 0
    end
    remaining = math.max(0, math.floor(remaining + 0.5))

    local showCounts = info.showCounts == true
    local formattedText

    local formatHeader = info.formatHeader
    if type(formatHeader) == "function" then
        local result = formatHeader(title, remaining, showCounts)
        if result ~= nil and result ~= "" then
            formattedText = tostring(result)
        end
    end

    if formattedText == nil then
        if showCounts then
            formattedText = string.format("%s (%d)", title, remaining)
        else
            formattedText = title
        end
    end

    if label.SetText then
        label:SetText(formattedText)
    end
    applyEndeavorLabelDefaults(label)

    local colorRoles = type(info.colorRoles) == "table" and info.colorRoles or {}
    local expanded = info.expanded == true
    local role
    if expanded then
        role = colorRoles.expanded or DEFAULT_CATEGORY_COLOR_ROLE_EXPANDED
    else
        role = colorRoles.collapsed or DEFAULT_CATEGORY_COLOR_ROLE_COLLAPSED
    end

    local rowsOptions = type(info.rowsOptions) == "table" and info.rowsOptions or nil
    if rowsOptions == nil then
        rowsOptions = {}
        info.rowsOptions = rowsOptions
    end

    local colorKind = rowsOptions.colorKind
    if type(colorKind) ~= "string" or colorKind == "" then
        if type(info.colorKind) == "string" and info.colorKind ~= "" then
            colorKind = info.colorKind
        else
            colorKind = DEFAULT_TRACKER_COLOR_KIND
        end
        rowsOptions.colorKind = colorKind
    end

    local ok, err = pcall(applyCategoryColor, label, role, info.overrideColors, colorKind)
    if not ok then
        safeDebug("[CategoryRow] applyCategoryColor failed for role=%s: %s", tostring(role), tostring(err))
        label:SetColor(1, 1, 1, 1)
        if label.SetAlpha then
            label:SetAlpha(1)
        end
    end

    local textures = type(info.textures) == "table" and info.textures or DEFAULT_CATEGORY_CHEVRON_TEXTURES
    local texturePath = expanded and textures.expanded or textures.collapsed
    if chevron.SetTexture then
        if type(texturePath) == "string" and texturePath ~= "" then
            chevron:SetTexture(texturePath)
        else
            local fallback = expanded and DEFAULT_CATEGORY_CHEVRON_TEXTURES.expanded or DEFAULT_CATEGORY_CHEVRON_TEXTURES.collapsed
            chevron:SetTexture(fallback)
        end
    end

    local indentValue = tonumber(info.categoryIndent) or 0
    local hasIndentAnchor = row.indentAnchor ~= nil
    if indentValue < 0 then
        indentValue = 0
    end
    local viewportInfo = getHostViewportInfo()
    if row.indentAnchor and row.indentAnchor.SetAnchor then
        row.indentAnchor:ClearAnchors()
        if viewportInfo.align == "right" then
            row.indentAnchor:SetAnchor(TOPRIGHT, control, TOPRIGHT, -indentValue, 0)
        else
            row.indentAnchor:SetAnchor(TOPLEFT, control, TOPLEFT, indentValue, 0)
        end
    end
    if chevron and chevron.SetAnchor then
        chevron:ClearAnchors()
        if viewportInfo.align == "right" then
            chevron:SetAnchor(TOPRIGHT, row.indentAnchor or control, TOPRIGHT, 0, 0)
        else
            chevron:SetAnchor(TOPLEFT, row.indentAnchor or control, TOPLEFT, 0, 0)
        end
    end
    if label and label.SetAnchor then
        label:ClearAnchors()
        if viewportInfo.align == "right" then
            label:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
            label:SetAnchor(TOPRIGHT, chevron, TOPLEFT, -CATEGORY_LABEL_OFFSET_X, 0)
            label:SetAnchor(TOPLEFT, control, TOPLEFT, 0, 0)
        else
            label:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
            label:SetAnchor(TOPLEFT, chevron, TOPRIGHT, CATEGORY_LABEL_OFFSET_X, 0)
            label:SetAnchor(TOPRIGHT, control, TOPRIGHT, 0, 0)
        end
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

    local availableWidth = computeEndeavorAvailableWidth(
        control,
        indentValue + CATEGORY_CHEVRON_SIZE + CATEGORY_LABEL_OFFSET_X,
        0,
        0
    )
    if label.SetWidth then
        label:SetWidth(availableWidth)
    end

    local minHeight = getCategoryHeight(expanded)
    local targetHeight = applyEndeavorRowMetrics(control, label, availableWidth, minHeight)
    if targetHeight then
        resolvedCategoryHeights[expanded and "expanded" or "collapsed"] = targetHeight
    end

    debugEndeavorWrap(label, "category", availableWidth, minHeight, control, formattedText)

    if control.SetMouseEnabled then
        control:SetMouseEnabled(true)
    end

    row._onToggle = info.onToggle

    if pendingCategoryAlignLog and isDebugEnabled() then
        local width = viewportInfo.viewportWidth
        if width == nil and control.GetWidth then
            local okWidth, measured = pcall(control.GetWidth, control)
            if okWidth then
                width = tonumber(measured)
            end
        end
        safeDebug(
            "[CategoryAlign] align=%s scrollbar=%s insets=(%s,%s) rowWidth=%s",
            tostring(viewportInfo.align),
            tostring(viewportInfo.scrollbarSide),
            tostring(viewportInfo.leftInset),
            tostring(viewportInfo.rightInset),
            tostring(width)
        )
        pendingCategoryAlignLog = false
    end

    local lastExpanded = row.__lastChevronExpanded
    if viewportInfo.align == "right" and expanded and lastExpanded ~= expanded and isDebugEnabled() then
        if texturePath == nil and chevron and chevron.GetTextureFileName then
            local okTexture, resolved = pcall(chevron.GetTextureFileName, chevron)
            if okTexture then
                texturePath = resolved
            end
        end
        safeDebug(
            "[CategoryChevron] Endeavor align=%s expanded=%s texture=%s rotation=%s",
            tostring(viewportInfo.align),
            tostring(expanded),
            tostring(texturePath),
            tostring(rotation)
        )
    end
    row.__lastChevronExpanded = expanded

    if LOGGER and type(LOGGER.Info) == "function" then
        LOGGER:Info(
            "[CategoryRow] apply title=%s expanded=%s remaining=%d counts=%s categoryIndent=%s hasIndentAnchor=%s",
            tostring(formattedText),
            tostring(expanded),
            remaining,
            tostring(showCounts),
            tostring(tonumber(info.categoryIndent)),
            tostring(hasIndentAnchor)
        )
    end
end

function Rows.AcquireCategoryRow(parent)
    return acquireCategoryRow(parent)
end

function Rows.ReleaseCategoryRow(row)
    detachFromUsed(row)
    releaseCategoryRow(row)
end

function Rows.ResetCategoryPool()
    resetCategoryPool()
end

function Rows.ApplyCategoryRow(row, data)
    applyCategoryRow(row, data)
end

function Rows.AcquireEntryRow(parent)
    return acquireEntryRow(parent)
end

function Rows.ReleaseEntryRow(row)
    releaseEntryRow(row)
end

function Rows.ResetEntryPool(targetParent)
    resetEntryPool(targetParent)
end

function Rows.ResetPools()
    Rows.ResetCategoryPool()
    Rows.ResetEntryPool()
end

function Rows.ResetAlignmentLog()
    pendingCategoryAlignLog = true
    pendingEntryAlignLog = true
    pendingObjectiveAlignLog = true
end

local function getConfiguredFonts(options)
    if type(options) == "table" and type(options.fontConfig) == "table" then
        return options.fontConfig
    end

    local addon = getAddon()
    if type(addon) ~= "table" then
        return nil
    end

    local sv = addon.SV or addon.sv
    if type(sv) ~= "table" then
        return nil
    end

    local endeavor = sv.Endeavor
    if type(endeavor) ~= "table" then
        return nil
    end

    local tracker = endeavor.Tracker
    if type(tracker) ~= "table" then
        return nil
    end

    return tracker.Fonts
end

local function selectFontGroup(fonts, key)
    if type(fonts) ~= "table" then
        return nil
    end

    local group = fonts[key]
    if type(group) ~= "table" then
        local altKey = type(key) == "string" and string.lower(key) or nil
        if altKey and type(fonts[altKey]) == "table" then
            group = fonts[altKey]
        end
    end

    return group
end

local function applyConfiguredFontForKind(control, kind, options)
    local fonts = getConfiguredFonts(options)
    if type(fonts) ~= "table" then
        return false
    end

    local targetKey
    if kind == "endeavorCategoryHeader" then
        targetKey = "Category"
    elseif kind == "dailyHeader" or kind == "weeklyHeader" then
        targetKey = "Title"
    else
        targetKey = "Objective"
    end

    local group = selectFontGroup(fonts, targetKey)
    if type(group) ~= "table" then
        return false
    end

    return ApplyFont(control, group)
end

local function applyObjectiveColor(label, options, objective)
    if not label or not label.SetColor then
        return
    end

    local opts = type(options) == "table" and options or {}
    local colors = type(opts.colors) == "table" and opts.colors or nil
    local role = opts.defaultRole or DEFAULT_OBJECTIVE_COLOR_ROLE

    if opts.completedHandling == "recolor" and objective and objective.completed then
        role = opts.completedRole or COMPLETED_COLOR_ROLE
    end

    local r, g, b, a
    if colors then
        r, g, b, a = extractColorComponents(colors[role])
    end

    if r == nil then
        r, g, b, a = getTrackerColor(role, opts.colorKind or DEFAULT_TRACKER_COLOR_KIND)
    end

    applyBaseColor(label, r or 1, g or 1, b or 1, a or 1)

    if label and label.SetAlpha then
        label:SetAlpha(1)
    end
end

local function applyGroupLabelColor(label, options, useCompletedStyle)
    if not label or not label.SetColor then
        return false
    end

    local opts = type(options) == "table" and options or {}
    local colors = type(opts.colors) == "table" and opts.colors or nil

    local role
    if useCompletedStyle then
        role = opts.completedRole or COMPLETED_COLOR_ROLE
    else
        role = opts.entryRole or ENTRY_COLOR_ROLE
    end

    local r, g, b, a
    if colors then
        r, g, b, a = extractColorComponents(colors[role])
    end

    if r == nil then
        r, g, b, a = getTrackerColor(role, opts.colorKind or DEFAULT_TRACKER_COLOR_KIND)
    end

    applyBaseColor(label, r or 1, g or 1, b or 1, a or 1)
    if label.SetAlpha then
        label:SetAlpha(1)
    end

    return true
end

local function applyEntryRow(row, objective, options)
    if row == nil then
        return
    end

    local wm = WINDOW_MANAGER
    if wm == nil then
        return
    end

    local data = type(objective) == "table" and objective or {}
    local baseText = tostring(data.text or "")
    if baseText == "" then
        baseText = "Objective"
    end

    local combinedText = baseText
    if data.progress ~= nil and data.max ~= nil then
        combinedText = string.format("%s %s", combinedText, FormatParensCount(data.progress, data.max))
    end

    combinedText = combinedText:gsub("%s+", " "):gsub("%s+%)", ")")

    local rowName = type(row.GetName) == "function" and row:GetName() or ""
    local titleName = rowName .. "Title"
    local progressName = rowName .. "Progress"

    if row.GetNamedChild then
        local bullet = row:GetNamedChild("Bullet")
        if bullet and bullet.SetHidden then
            bullet:SetHidden(true)
        end
        local icon = row:GetNamedChild("Icon")
        if icon and icon.SetHidden then
            icon:SetHidden(true)
        end
        local dot = row:GetNamedChild("Dot")
        if dot and dot.SetHidden then
            dot:SetHidden(true)
        end
    end

    local title = ensureEntryChild(row, titleName, CT_LABEL)
    title:SetParent(row)
    local rowKind = type(objective) == "table" and objective.kind or nil
    local appliedConfiguredFont = applyConfiguredFontForKind and applyConfiguredFontForKind(title, rowKind, options)
    local resolvedFont = nil
    if not appliedConfiguredFont then
        resolvedFont = options and options.font or DEFAULT_OBJECTIVE_FONT
    end
    applyEndeavorLabelDefaults(title)
    if not appliedConfiguredFont then
        applyFontString(title, resolvedFont, DEFAULT_OBJECTIVE_FONT)
    end
    title:ClearAnchors()
    local viewportInfo = getHostViewportInfo()
    if viewportInfo.align == "right" then
        title:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
        title:SetAnchor(TOPRIGHT, row, TOPRIGHT, -resolveObjectiveIndent(options), ENTRY_TOP_PAD)
    else
        title:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        title:SetAnchor(TOPLEFT, row, TOPLEFT, resolveObjectiveIndent(options), ENTRY_TOP_PAD)
    end
    title:SetText(combinedText)
    row.Label = title
    row.label = title

    local leftClickHandler = type(objective) == "table" and objective.onLeftClick or nil
    row._entryOnLeftClick = type(leftClickHandler) == "function" and leftClickHandler or nil

    if row.SetMouseEnabled then
        row:SetMouseEnabled(true)
    end

    if row.SetHandler then
        row:SetHandler("OnMouseUp", onEntryMouseUp)

    end

    local progress = ensureEntryChild(row, progressName, CT_LABEL)
    progress:SetParent(row)
    if progress.SetHidden then
        progress:SetHidden(true)
    end
    if progress.SetText then
        progress:SetText("")
    end
    row.Progress = progress

    applyObjectiveColor(title, options, data)

    local availableWidth = computeEndeavorAvailableWidth(row, resolveObjectiveIndent(options), 0, 0)
    if title.SetWidth then
        title:SetWidth(availableWidth)
    end

    local minHeight = resolveEntryHeight(options)
    local targetHeight = applyEndeavorRowMetrics(row, title, availableWidth, minHeight)
    if targetHeight then
        resolvedEntryHeight = targetHeight
    end

    debugEndeavorWrap(title, "entry", availableWidth, minHeight, row, combinedText)

    local subrowsSource = type(data) == "table" and data.subrows or nil
    local sanitizedSubrows, visibleSubrows = sanitizeSubrows(subrowsSource)
    row._subrows = sanitizedSubrows
    row._subrowCount = #sanitizedSubrows
    row._subrowsVisibleCount = visibleSubrows

    if not loggedSubrowsOnce and visibleSubrows > 0 then
        local blockHeight = Rows.GetSubrowsBlockHeight(sanitizedSubrows)
        safeDebug("[Endeavor] subrows: n=%d blockHeight=%s", visibleSubrows, tostring(blockHeight))
        loggedSubrowsOnce = true
    end

    local container = row._poolParent or (row.GetParent and row:GetParent()) or nil
    if container then
        for index, entry in ipairs(sanitizedSubrows) do
            local control = acquireSubrowControl(row, container, index)
            entry.control = control
            if control then
                if entry.visible then
                    Rows.ApplySubrow(control, entry.kind, entry.source, options)
                else
                    if control.SetHidden then
                        control:SetHidden(true)
                    end
                    if control.ClearAnchors then
                        control:ClearAnchors()
                    end
                end
            end
        end
        hideUnusedSubrows(row, #sanitizedSubrows + 1)
    else
        hideUnusedSubrows(row, 1)
    end

    if row.SetAlpha then
        row:SetAlpha(1)
    end

    if pendingEntryAlignLog and isDebugEnabled() then
        local wrapperWidth = getEndeavorRowContainerWidth(row)
        local labelWidth
        if title.GetWidth then
            local okWidth, measured = pcall(title.GetWidth, title)
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

    safeDebug("[EndeavorRows] objective inline: \"%s\"", combinedText)
end

function Rows.ApplyEntryRow(row, objective, options)
    applyEntryRow(row, objective, options)
end

function Rows.ApplyGroupLabelColor(label, options, useCompletedStyle)
    return applyGroupLabelColor(label, options, useCompletedStyle == true)
end

function Rows.Init()
    categoryPool.free = categoryPool.free or {}
    categoryPool.used = categoryPool.used or {}
    if type(categoryPool.nextId) ~= "number" or categoryPool.nextId < 1 then
        categoryPool.nextId = (#categoryPool.free or 0) + 1
    end
    entryPool.free = entryPool.free or {}
    entryPool.used = entryPool.used or {}
    if type(entryPool.nextId) ~= "number" or entryPool.nextId < 1 then
        entryPool.nextId = (#entryPool.free or 0) + 1
    end
    Rows.ResetCategoryPool()
    Rows.ResetEntryPool()
    loggedSubrowsOnce = false
end

function Rows.GetSubrowHeight(kind)
    local resolvedKind = normalizeSubrowKind(kind)
    local height = resolvedSubrowHeights[resolvedKind] or ROWS_HEIGHTS[resolvedKind] or ROWS_HEIGHTS[kind]
    if type(height) ~= "number" then
        return 0
    end
    if height ~= height then
        return 0
    end
    if height < 0 then
        return 0
    end
    return height
end

function Rows.GetSubrowsBlockHeight(subrows)
    if type(subrows) ~= "table" then
        return 0
    end

    local total = 0
    local visibleCount = 0

    local firstSpacing = resolveSubrowSpacing("spacing_entry_to_first_sub")
    local betweenSpacing = resolveSubrowSpacing("spacing_between_subrows")
    local trailingSpacing = resolveSubrowSpacing("spacing_after_last_sub")

    for index = 1, #subrows do
        local entry = subrows[index]
        if type(entry) == "table" then
            local visible
            if entry.visible ~= nil then
                visible = entry.visible ~= false
            elseif entry.hidden ~= nil then
                visible = entry.hidden ~= true
            elseif type(entry.source) == "table" then
                local source = entry.source
                if source.visible ~= nil then
                    visible = source.visible ~= false
                elseif source.hidden ~= nil then
                    visible = source.hidden ~= true
                end
            end

            if visible == nil then
                visible = true
            end

            if visible then
                visibleCount = visibleCount + 1
                if visibleCount == 1 then
                    total = total + firstSpacing
                else
                    total = total + betweenSpacing
                end
                total = total + Rows.GetSubrowHeight(entry.kind or (entry.source and entry.source.kind))
            end
        end
    end

    if visibleCount > 0 then
        total = total + trailingSpacing
    end

    return total
end

function Rows.GetCategoryRowHeight(expanded)
    local key = expanded and "expanded" or "collapsed"
    return resolvedCategoryHeights[key] or getCategoryHeight(expanded)
end

function Rows.GetEntryRowHeight()
    return resolvedEntryHeight
end

Nvk3UT.EndeavorTrackerRows = Rows

return Rows
