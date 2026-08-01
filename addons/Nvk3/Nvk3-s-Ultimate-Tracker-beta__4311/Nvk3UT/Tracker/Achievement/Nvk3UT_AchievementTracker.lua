local addonName = "Nvk3UT"

Nvk3UT = Nvk3UT or {}

local AchievementTracker = {}
AchievementTracker.__index = AchievementTracker

local MODULE_NAME = addonName .. "AchievementTracker"

local Utils = Nvk3UT and Nvk3UT.Utils
local AchievementTrackerLayout = Nvk3UT and Nvk3UT.AchievementTrackerLayout

local function GetAchievementState()
    return Nvk3UT and Nvk3UT.AchievementState
end

local function GetRows()
    return Nvk3UT and Nvk3UT.AchievementTrackerRows
end
local FormatCategoryHeaderText =
    (Utils and Utils.FormatCategoryHeaderText)
    or function(baseText, count, showCounts)
        local text = baseText or ""
        if showCounts ~= false and type(count) == "number" and count >= 0 then
            local numericCount = math.floor(count + 0.5)
            return string.format("%s (%d)", text, numericCount)
        end
        return text
    end

local function ShouldShowAchievementCategoryCounts()
    local addon = Nvk3UT
    local sv = addon and addon.SV
    local general = sv and sv.General

    if general and general.showAchievementCategoryCounts ~= nil then
        return general.showAchievementCategoryCounts ~= false
    end

    return true
end

local function FormatDisplayString(text)
    if text == nil then
        return ""
    end

    local value = text
    if type(value) ~= "string" then
        value = tostring(value)
    end

    if value == "" then
        return ""
    end

    if type(ZO_CachedStrFormat) == "function" then
        local ok, formatted = pcall(ZO_CachedStrFormat, "<<1>>", value)
        if ok and formatted ~= nil then
            return formatted
        end
    end

    if type(zo_strformat) == "function" then
        local ok, formatted = pcall(zo_strformat, "<<1>>", value)
        if ok and formatted ~= nil then
            return formatted
        end
    end

    return value
end

local CATEGORY_INDENT_X = 0
local CATEGORY_SPACING_ABOVE = 3
local CATEGORY_SPACING_BELOW = 6
local ACHIEVEMENT_INDENT_X = 18
local ENTRY_INDENT_X = ACHIEVEMENT_INDENT_X
local ENTRY_SPACING_ABOVE = 3
local ENTRY_SPACING_BELOW = 0
local OBJECTIVE_SPACING_ABOVE = 3
local OBJECTIVE_SPACING_BETWEEN = 1
local OBJECTIVE_SPACING_BELOW = 3
local ACHIEVEMENT_ICON_SLOT_WIDTH = 18
local ACHIEVEMENT_ICON_SLOT_HEIGHT = 18
local ACHIEVEMENT_ICON_SLOT_PADDING_X = 6
local ACHIEVEMENT_LABEL_INDENT_X = ACHIEVEMENT_INDENT_X + ACHIEVEMENT_ICON_SLOT_WIDTH + ACHIEVEMENT_ICON_SLOT_PADDING_X
-- keep objective text inset relative to achievement titles after adding the persistent icon slot
local OBJECTIVE_RELATIVE_INDENT = 18
local OBJECTIVE_INDENT_X = ACHIEVEMENT_LABEL_INDENT_X + OBJECTIVE_RELATIVE_INDENT
local OBJECTIVE_INDENT_DEFAULT = 40
local OBJECTIVE_BASE_INDENT = 20

local CATEGORY_KEY = "achievements"
local CATEGORY_ROW_KEY = string.format("cat:%s", CATEGORY_KEY)

local function ScheduleToggleFollowup(reason)
    local rebuild = (Nvk3UT and Nvk3UT.Rebuild) or _G.Nvk3UT_Rebuild
    if rebuild and type(rebuild.ScheduleToggleFollowup) == "function" then
        rebuild.ScheduleToggleFollowup(reason)
    end
end

local TOGGLE_LABEL_PADDING_X = 4
local CATEGORY_TOGGLE_WIDTH = 20

local function GetVerticalPadding()
    if AchievementTrackerLayout and type(AchievementTrackerLayout.GetVerticalPadding) == "function" then
        return AchievementTrackerLayout.GetVerticalPadding()
    end

    return 0
end

local function GetRowGap()
    if AchievementTrackerLayout and type(AchievementTrackerLayout.GetRowGap) == "function" then
        return AchievementTrackerLayout.GetRowGap()
    end

    return GetVerticalPadding()
end

local function GetHeaderToRowsGap()
    if AchievementTrackerLayout and type(AchievementTrackerLayout.GetHeaderToRowsGap) == "function" then
        return AchievementTrackerLayout.GetHeaderToRowsGap()
    end

    return GetRowGap()
end

local function GetSubrowSpacing()
    if AchievementTrackerLayout and type(AchievementTrackerLayout.GetSubrowSpacing) == "function" then
        return AchievementTrackerLayout.GetSubrowSpacing()
    end

    return GetVerticalPadding()
end

local function GetCategoryBottomPadding(isExpanded)
    return CATEGORY_SPACING_BELOW
end

local function GetBottomPixelNudge()
    if AchievementTrackerLayout and type(AchievementTrackerLayout.GetBottomPixelNudge) == "function" then
        return AchievementTrackerLayout.GetBottomPixelNudge()
    end

    return 0
end

local function GetRowHeight(rowType, textHeight)
    if AchievementTrackerLayout and type(AchievementTrackerLayout.ComputeRowHeight) == "function" then
        return AchievementTrackerLayout.ComputeRowHeight(rowType, textHeight)
    end

    return 0
end

local NormalizeMetric

local DEFAULT_FONTS = {
    category = "$(BOLD_FONT)|20|soft-shadow-thick",
    achievement = "$(BOLD_FONT)|16|soft-shadow-thick",
    objective = "$(BOLD_FONT)|14|soft-shadow-thick",
    toggle = "$(BOLD_FONT)|20|soft-shadow-thick",
}

local LEFT_MOUSE_BUTTON = MOUSE_BUTTON_INDEX_LEFT or 1
local RIGHT_MOUSE_BUTTON = MOUSE_BUTTON_INDEX_RIGHT or 2

local DEFAULT_FONT_OUTLINE = "soft-shadow-thick"
local REFRESH_DEBOUNCE_MS = 80

local DEFAULT_MOUSEOVER_HIGHLIGHT_COLOR = { 1, 1, 0.6, 1 }

local function NormalizeSpacingValue(value, fallback)
    local numeric = tonumber(value)
    if numeric == nil or numeric ~= numeric then
        return fallback
    end
    if numeric < 0 then
        return fallback
    end
    return numeric
end

local function ApplyCategorySpacingFromSaved()
    local addon = Nvk3UT
    local sv = addon and addon.SV
    local spacing = sv and sv.spacing
    local achievementSpacing = spacing and spacing.achievement
    local category = achievementSpacing and achievementSpacing.category

    CATEGORY_INDENT_X = NormalizeSpacingValue(category and category.indent, CATEGORY_INDENT_X)
    CATEGORY_SPACING_ABOVE = NormalizeSpacingValue(category and category.spacingAbove, CATEGORY_SPACING_ABOVE)
    CATEGORY_SPACING_BELOW = NormalizeSpacingValue(category and category.spacingBelow, CATEGORY_SPACING_BELOW)
end

local function ApplyEntrySpacingFromSaved()
    local addon = Nvk3UT
    local sv = addon and addon.SV
    local spacing = sv and sv.spacing
    local achievementSpacing = spacing and spacing.achievement
    local entry = achievementSpacing and achievementSpacing.entry

    ENTRY_INDENT_X = NormalizeSpacingValue(entry and entry.indent, ENTRY_INDENT_X)
    ENTRY_SPACING_ABOVE = NormalizeSpacingValue(entry and entry.spacingAbove, ENTRY_SPACING_ABOVE)
    ENTRY_SPACING_BELOW = NormalizeSpacingValue(entry and entry.spacingBelow, ENTRY_SPACING_BELOW)
end

local function ApplyObjectiveSpacingFromSaved()
    local addon = Nvk3UT
    local sv = addon and addon.SV
    local spacing = sv and sv.spacing
    local achievementSpacing = spacing and spacing.achievement
    local objective = achievementSpacing and achievementSpacing.objective

    OBJECTIVE_INDENT_X = NormalizeSpacingValue(objective and objective.indent, OBJECTIVE_INDENT_DEFAULT) + OBJECTIVE_BASE_INDENT
    OBJECTIVE_SPACING_ABOVE = NormalizeSpacingValue(objective and objective.spacingAbove, OBJECTIVE_SPACING_ABOVE)
    OBJECTIVE_SPACING_BETWEEN = NormalizeSpacingValue(objective and objective.spacingBetween, OBJECTIVE_SPACING_BETWEEN)
    OBJECTIVE_SPACING_BELOW = NormalizeSpacingValue(objective and objective.spacingBelow, OBJECTIVE_SPACING_BELOW)
end

local function IsDebugLoggingEnabled()
    local utils = (Nvk3UT and Nvk3UT.Utils) or Nvk3UT_Utils
    if utils and type(utils.IsDebugEnabled) == "function" then
        return utils:IsDebugEnabled()
    end
    local diagnostics = (Nvk3UT and Nvk3UT.Diagnostics) or Nvk3UT_Diagnostics
    if diagnostics and type(diagnostics.IsDebugEnabled) == "function" then
        return diagnostics:IsDebugEnabled()
    end
    local addon = Nvk3UT
    if addon and type(addon.IsDebugEnabled) == "function" then
        return addon:IsDebugEnabled()
    end
    return false
end

local function DebugLog(...)
    if not IsDebugLoggingEnabled() then
        return
    end

    if d then
        d(string.format("[%s]", MODULE_NAME), ...)
    elseif print then
        print("[" .. MODULE_NAME .. "]", ...)
    end
end

local function DebugDiagnostics(message)
    local diagnostics = (Nvk3UT and Nvk3UT.Diagnostics) or Nvk3UT_Diagnostics
    if diagnostics and type(diagnostics.DebugIfEnabled) == "function" then
        diagnostics:DebugIfEnabled(MODULE_NAME, message)
    end
end

local FAVORITES_LOOKUP_KEY = "NVK3UT_FAVORITES_ROOT"
local FAVORITES_CATEGORY_ID = "Nvk3UT_Favorites"

local function GetAchievementRowKey(achievementId)
    if achievementId == nil then
        return "entry:unknown"
    end

    return string.format("entry:%s", tostring(achievementId))
end

local function GetObjectiveRowKey(achievementId, objectiveIndex)
    return string.format(
        "obj:%s:%s",
        tostring(achievementId or "unknown"),
        tostring(objectiveIndex or 0)
    )
end

local state = {
    isInitialized = false,
    opts = {},
    fonts = {},
    saved = nil,
    control = nil,
    container = nil,
    orderedControls = {},
    lastAnchoredControl = nil,
    nextCategoryGap = nil,
    nextEntryGap = nil,
    nextObjectiveGap = nil,
    snapshot = nil,
    subscription = nil,
    pendingRefresh = false,
    contentWidth = 0,
    contentHeight = 0,
    lastHeight = 0,
    rowsWarningLogged = false,
}

NormalizeMetric = function(value)
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

local function GetAchievementTrackerColor(role)
    local host = Nvk3UT and Nvk3UT.TrackerHost
    if host then
        if host.EnsureAppearanceDefaults then
            host.EnsureAppearanceDefaults()
        end
        if host.GetTrackerColor then
            return host.GetTrackerColor("achievementTracker", role)
        end
    end
    return 1, 1, 1, 1
end

local function GetMouseoverHighlightColor()
    local host = Nvk3UT and Nvk3UT.TrackerHost
    if host then
        if host.EnsureAppearanceDefaults then
            host.EnsureAppearanceDefaults()
        end
        if host.GetMouseoverHighlightColor then
            local r, g, b, a = host.GetMouseoverHighlightColor("achievementTracker")
            if r and g and b and a then
                return r, g, b, a
            end
        end
    end

    return unpack(DEFAULT_MOUSEOVER_HIGHLIGHT_COLOR)
end

local function ApplyMouseoverHighlight(ctrl)
    if not (ctrl and ctrl.label) then
        return
    end

    local r, g, b, a = GetMouseoverHighlightColor()
    ctrl.label:SetColor(r, g, b, a)

    if IsDebugLoggingEnabled() then
        DebugLog(string.format(
            "Achievement hover: applying mouseover highlight color r=%.3f g=%.3f b=%.3f a=%.3f",
            r or 0,
            g or 0,
            b or 0,
            a or 0
        ))
    end
end

local function RestoreBaseColor(ctrl)
    local resetFn = ctrl and ctrl.__nvk3RestoreHoverColor
    if type(resetFn) == "function" then
        resetFn(ctrl)
        return
    end

    if not (ctrl and ctrl.label and ctrl.baseColor) then
        return
    end

    ctrl.label:SetColor(unpack(ctrl.baseColor))

    if IsDebugLoggingEnabled() then
        local r, g, b, a = unpack(ctrl.baseColor)
        DebugLog(string.format(
            "Achievement hover: restored base color r=%.3f g=%.3f b=%.3f a=%.3f",
            r or 0,
            g or 0,
            b or 0,
            a or 0
        ))

        if resetFn ~= nil then
            DebugLog("Achievement hover: missing restore callback, applied base color fallback")
        end
    end
end

local function GetToggleWidth(toggle, fallback)
    if toggle then
        if toggle.GetWidth then
            local width = toggle:GetWidth()
            if width and width > 0 then
                return width
            end
        end
    end

    return fallback or 0
end

local function GetContainerWidth()
    if not state.container or not state.container.GetWidth then
        return 0
    end

    local width = state.container:GetWidth()
    if not width or width <= 0 then
        return 0
    end

    return width
end

local function GetViewportWidth()
    local host = Nvk3UT and Nvk3UT.TrackerHost
    if host and type(host.GetViewportWidth) == "function" then
        local ok, width = pcall(host.GetViewportWidth, host)
        if ok and type(width) == "number" and width > 0 then
            return width
        end
    end

    return GetContainerWidth()
end

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

local function applyEntryAlignment(control, viewportInfo)
    if not (control and control.label and control.label.ClearAnchors) then
        return
    end

    local align = viewportInfo and viewportInfo.align or "left"
    local iconSlot = control.iconSlot

    if iconSlot and iconSlot.ClearAnchors then
        iconSlot:ClearAnchors()
        if align == "right" then
            iconSlot:SetAnchor(TOPRIGHT, control, TOPRIGHT, 0, 0)
        else
            iconSlot:SetAnchor(TOPLEFT, control, TOPLEFT, 0, 0)
        end
    end

    control.label:ClearAnchors()
    if align == "right" then
        control.label:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
        if iconSlot then
            control.label:SetAnchor(TOPRIGHT, iconSlot, TOPLEFT, -ACHIEVEMENT_ICON_SLOT_PADDING_X, 0)
        else
            control.label:SetAnchor(TOPRIGHT, control, TOPRIGHT, 0, 0)
        end
        control.label:SetAnchor(TOPLEFT, control, TOPLEFT, 0, 0)
    else
        control.label:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        if iconSlot then
            control.label:SetAnchor(TOPLEFT, iconSlot, TOPRIGHT, ACHIEVEMENT_ICON_SLOT_PADDING_X, 0)
        else
            control.label:SetAnchor(TOPLEFT, control, TOPLEFT, 0, 0)
        end
        control.label:SetAnchor(TOPRIGHT, control, TOPRIGHT, 0, 0)
    end
end

local function ApplyRowMetrics(control, rowType, indent, toggleWidth, leftPadding, rightPadding, widthOverride)
    if not control or not control.label then
        return
    end

    indent = indent or 0
    toggleWidth = toggleWidth or 0
    leftPadding = leftPadding or 0
    rightPadding = rightPadding or 0

    local containerWidth = widthOverride
    if type(containerWidth) ~= "number" or containerWidth <= 0 then
        containerWidth = GetContainerWidth()
    end

    local availableWidth = containerWidth - indent - toggleWidth - leftPadding - rightPadding
    if availableWidth < 0 then
        availableWidth = 0
    end

    control.label:SetWidth(availableWidth)

    local textHeight = control.label:GetTextHeight() or 0
    control:SetHeight(GetRowHeight(rowType, textHeight))
end

local function RefreshControlMetrics(control)
    if not control or not control.label then
        return
    end

    local indent = control.currentIndent or 0
    local rowType = control.rowType

    if rowType == "category" then
        ApplyRowMetrics(
            control,
            rowType,
            indent,
            GetToggleWidth(control.toggle, CATEGORY_TOGGLE_WIDTH),
            TOGGLE_LABEL_PADDING_X,
            0,
            GetViewportWidth()
        )
    elseif rowType == "achievement" then
        ApplyRowMetrics(
            control,
            rowType,
            indent,
            ACHIEVEMENT_ICON_SLOT_WIDTH,
            ACHIEVEMENT_ICON_SLOT_PADDING_X,
            0
        )
    elseif rowType == "objective" then
        ApplyRowMetrics(control, rowType, indent, 0, 0, 0)
    end
end

local function EscapeDebugString(value)
    return tostring(value):gsub('"', '\\"')
end

local function AppendDebugField(parts, key, value, treatAsString)
    if not key or key == "" then
        return
    end

    if value == nil then
        parts[#parts + 1] = string.format("%s=nil", key)
        return
    end

    local valueType = type(value)
    if valueType == "boolean" then
        parts[#parts + 1] = string.format("%s=%s", key, value and "true" or "false")
    elseif valueType == "number" then
        parts[#parts + 1] = string.format("%s=%s", key, tostring(value))
    elseif treatAsString or valueType == "string" then
        parts[#parts + 1] = string.format('%s="%s"', key, EscapeDebugString(value))
    else
        parts[#parts + 1] = string.format("%s=%s", key, tostring(value))
    end
end

local function EmitDebugAction(action, trigger, entityType, fieldList)
    if not IsDebugLoggingEnabled() then
        return
    end

    local parts = { "[NVK]" }
    AppendDebugField(parts, "action", action or "unknown")
    AppendDebugField(parts, "trigger", trigger or "unknown")
    AppendDebugField(parts, "type", entityType or "unknown")

    if type(fieldList) == "table" then
        for index = 1, #fieldList do
            local entry = fieldList[index]
            if entry and entry.key then
                AppendDebugField(parts, entry.key, entry.value, entry.string)
            end
        end
    end

    local message = table.concat(parts, " ")
    if d then
        d(message)
    elseif print then
        print(message)
    end
end

local function LogCategoryExpansion(action, trigger, beforeExpanded, afterExpanded, source)
    if not IsDebugLoggingEnabled() then
        return
    end

    local fields = {
        { key = "id", value = "root" },
        { key = "before.expanded", value = beforeExpanded },
        { key = "after.expanded", value = afterExpanded },
    }

    if source then
        fields[#fields + 1] = { key = "source", value = source, string = true }
    end

    EmitDebugAction(action, trigger, "category", fields)
end

local function NotifyHostContentChanged()
    local host = Nvk3UT and Nvk3UT.TrackerHost
    if not (host and host.NotifyContentChanged) then
        return
    end

    pcall(host.NotifyContentChanged)
end

local function EnsureSavedVars()
    Nvk3UT.sv = Nvk3UT.sv or {}
    local root = Nvk3UT.sv
    root.AchievementTracker = root.AchievementTracker or {}

    local achievementState = GetAchievementState()
    if achievementState and achievementState.Init then
        achievementState.Init(root)
        state.saved = achievementState._saved or root.AchievementTracker
    else
        local saved = root.AchievementTracker
        if saved.categoryExpanded == nil then
            saved.categoryExpanded = true
        end
        saved.entryExpanded = saved.entryExpanded or {}
        state.saved = saved
    end
end

local function ResolveFont(fontId)
    if type(fontId) == "string" and fontId ~= "" then
        return fontId
    end
    return nil
end

local function MergeFonts(opts)
    local fonts = {}
    fonts.category = ResolveFont(opts.category) or DEFAULT_FONTS.category
    fonts.achievement = ResolveFont(opts.achievement) or DEFAULT_FONTS.achievement
    fonts.objective = ResolveFont(opts.objective) or DEFAULT_FONTS.objective
    fonts.toggle = ResolveFont(opts.toggle) or DEFAULT_FONTS.toggle
    return fonts
end

local function BuildFontString(descriptor, fallback)
    if type(descriptor) ~= "table" then
        return ResolveFont(descriptor) or fallback
    end

    local face = descriptor.face or descriptor.path
    local size = descriptor.size
    local outline = descriptor.outline or DEFAULT_FONT_OUTLINE

    if not face or face == "" or not size then
        return fallback
    end

    return string.format("%s|%d|%s", face, size, outline or DEFAULT_FONT_OUTLINE)
end

local function BuildFavoritesScope()
    local sv = Nvk3UT and Nvk3UT.sv and Nvk3UT.sv.General
    return (sv and sv.favScope) or "account"
end

local function IsFavoriteAchievement(achievementId)
    local achievementState = GetAchievementState()
    if achievementState and achievementState.IsFavorited then
        return achievementState.IsFavorited(achievementId)
    end

    if not achievementId then
        return false
    end

    local Fav = Nvk3UT and Nvk3UT.FavoritesData
    if not (Fav and Fav.IsFavorited) then
        return false
    end

    local scope = BuildFavoritesScope()
    if Fav.IsFavorited(achievementId, scope) then
        return true
    end

    if scope ~= "account" and Fav.IsFavorited(achievementId, "account") then
        return true
    end

    if scope ~= "character" and Fav.IsFavorited(achievementId, "character") then
        return true
    end

    return false
end

local function RemoveAchievementFromFavorites(achievementId)
    local numeric = tonumber(achievementId)
    if not numeric or numeric <= 0 then
        return
    end

    local achievementState = GetAchievementState()
    if achievementState and achievementState.SetFavorited then
        achievementState.SetFavorited(numeric, false, "AchievementTracker:RemoveAchievementFromFavorites")
        return
    end

    local Fav = Nvk3UT and Nvk3UT.FavoritesData
    if not (Fav and Fav.SetFavorited) then
        return
    end

    Fav.SetFavorited(
        numeric,
        false,
        "AchievementTracker:RemoveAchievementFromFavorites",
        BuildFavoritesScope()
    )

    if AchievementTracker and AchievementTracker.RequestRefresh then
        AchievementTracker.RequestRefresh()
    end
end

local function ResolveAchievementEntry(achievementsSystem, achievementId)
    if not achievementsSystem or not achievementsSystem.achievementsById then
        return nil
    end

    local candidates = {}
    if achievementId ~= nil then
        candidates[#candidates + 1] = achievementId
    end

    local numericId = tonumber(achievementId)
    if numericId and numericId ~= achievementId then
        candidates[#candidates + 1] = numericId
    end

    local stringId = tostring(achievementId)
    if stringId ~= achievementId then
        candidates[#candidates + 1] = stringId
    end

    for index = 1, #candidates do
        local key = candidates[index]
        if key ~= nil then
            local entry = achievementsSystem.achievementsById[key]
            if entry then
                return entry
            end
        end
    end

    return nil
end

local function FocusAchievementInSystem(achievementsSystem, manager, achievementId, originalId)
    if not achievementsSystem then
        return false
    end

    local numericId = tonumber(achievementId)
    local lookupId = originalId or achievementId

    if numericId and achievementsSystem.FocusAchievement then
        local ok = pcall(achievementsSystem.FocusAchievement, achievementsSystem, numericId)
        if ok then
            return true
        end
    end

    local entry = ResolveAchievementEntry(achievementsSystem, lookupId)
    if entry then
        if entry.Expand then
            entry:Expand()
        end
        if entry.Select then
            entry:Select()
        end
        if entry.GetControl and achievementsSystem.contentList and ZO_Scroll_ScrollControlIntoCentralView then
            local control = entry:GetControl()
            if control then
                ZO_Scroll_ScrollControlIntoCentralView(achievementsSystem.contentList, control)
            end
        end
        return true
    end

    if manager and numericId then
        if manager.SelectAchievement then
            local ok, result = pcall(manager.SelectAchievement, manager, numericId)
            if ok and result ~= false then
                return true
            end
        end

        if manager.ShowAchievement then
            local ok, result = pcall(manager.ShowAchievement, manager, numericId)
            if ok and result ~= false then
                return true
            end
        end
    end

    return false
end

local function GetAchievementsSystem()
    local system
    if SYSTEMS and SYSTEMS.GetObject then
        local ok, result = pcall(SYSTEMS.GetObject, SYSTEMS, "achievements")
        if ok then
            system = result
        end
    end
    return system or ACHIEVEMENTS
end

local function CanOpenAchievement(achievementId)
    local numeric = tonumber(achievementId)
    if not numeric or numeric <= 0 then
        return false
    end

    if type(GetAchievementInfo) ~= "function" then
        return false
    end

    local ok, name = pcall(GetAchievementInfo, numeric)
    if not ok then
        return false
    end

    if type(name) == "string" then
        return name ~= ""
    end

    return true
end

local function OpenAchievementInJournal(achievementId)
    local originalId = achievementId
    local numeric = tonumber(achievementId)
    if not numeric or numeric <= 0 then
        return false
    end

    if type(GetAchievementInfo) == "function" then
        local ok, name = pcall(GetAchievementInfo, numeric)
        if not ok or (type(name) == "string" and name == "") then
            return false
        end
    end

    if SCENE_MANAGER and SCENE_MANAGER.IsShowing and not SCENE_MANAGER:IsShowing("achievements") then
        SCENE_MANAGER:Show("achievements")
    end

    local manager = ACHIEVEMENTS_MANAGER

    if manager and manager.ShowAchievement then
        local ok, result = pcall(manager.ShowAchievement, manager, numeric)
        if ok and result ~= false then
            return true
        end
    end

    local achievementsSystem = GetAchievementsSystem()
    if not achievementsSystem then
        return false
    end

    if achievementsSystem.contentSearchEditBox and achievementsSystem.contentSearchEditBox.GetText then
        if achievementsSystem.contentSearchEditBox:GetText() ~= "" then
            achievementsSystem.contentSearchEditBox:SetText("")
            if manager and manager.ClearSearch then
                manager:ClearSearch(true)
            end
        end
    end

    if type(GetCategoryInfoFromAchievementId) == "function" then
        local ok, categoryIndex, subCategoryIndex = pcall(GetCategoryInfoFromAchievementId, numeric)
        if ok and categoryIndex then
            if achievementsSystem.OpenCategory then
                local openOk, opened = pcall(achievementsSystem.OpenCategory, achievementsSystem, categoryIndex, subCategoryIndex)
                if not openOk then
                    opened = false
                end
                if not opened and achievementsSystem.SelectCategory then
                    pcall(achievementsSystem.SelectCategory, achievementsSystem, categoryIndex, subCategoryIndex)
                end
            elseif achievementsSystem.SelectCategory then
                pcall(achievementsSystem.SelectCategory, achievementsSystem, categoryIndex, subCategoryIndex)
            end
        end
    end

    if FocusAchievementInSystem(achievementsSystem, manager, numeric, originalId) then
        return true
    end

    return false
end

local function SelectFavoritesCategory(achievementsSystem)
    if not achievementsSystem then
        return false
    end

    -- Drive the same favorites node that our UI exposes so manual clicks and
    -- context menu navigation share a single code path.
    local tree = achievementsSystem.categoryTree
    local node = achievementsSystem._nvkFavoritesNode
    if not node then
        local lookup = achievementsSystem.nodeLookupData
        if lookup then
            node = lookup[FAVORITES_LOOKUP_KEY]
        end
    end

    if node and tree and tree.SelectNode then
        local ok, result = pcall(tree.SelectNode, tree, node)
        if ok and result ~= false then
            return true
        end
    end

    local data = achievementsSystem._nvkFavoritesData
    if data and achievementsSystem.SelectCategory then
        local ok, result = pcall(
            achievementsSystem.SelectCategory,
            achievementsSystem,
            data.categoryIndex,
            data.subCategoryIndex
        )
        if ok and result ~= false then
            return true
        end
    end

    if achievementsSystem.SelectCategory then
        local ok, result = pcall(achievementsSystem.SelectCategory, achievementsSystem, FAVORITES_CATEGORY_ID)
        if ok and result ~= false then
            return true
        end
    end

    return false
end

local function CanShowInAchievements(achievementId)
    return CanOpenAchievement(achievementId)
end

local function ShowAchievementInAchievements(achievementId)
    local originalId = achievementId
    local numeric = tonumber(achievementId)
    if not numeric or numeric <= 0 then
        return false
    end

    if not SCENE_MANAGER or type(SCENE_MANAGER.Show) ~= "function" then
        return false
    end

    -- Let the base Achievements scene handle visibility before steering it to
    -- our custom favorites category.
    SCENE_MANAGER:Show("achievements")

    local function focusAchievement()
        local achievementsSystem = GetAchievementsSystem()
        if not achievementsSystem then
            return
        end

        SelectFavoritesCategory(achievementsSystem)

        local manager = ACHIEVEMENTS_MANAGER
        local function attemptFocus()
            FocusAchievementInSystem(achievementsSystem, manager, numeric, originalId)
        end

        if type(zo_callLater) == "function" then
            zo_callLater(attemptFocus, 20)
        else
            attemptFocus()
        end
    end

    if type(zo_callLater) == "function" then
        zo_callLater(focusAchievement, 30)
    else
        focusAchievement()
    end

    return true
end

local function BuildAchievementContextMenuEntries(data)
    local entries = {}

    local achievementId = data and data.achievementId

    entries[#entries + 1] = {
        label = GetString(SI_NVK3UT_TRACKER_ACHIEVEMENT_CONTEXT_LINK_CHAT),
        enabled = function()
            return type(achievementId) == "number"
                and achievementId > 0
                and type(GetAchievementLink) == "function"
                and type(ZO_LinkHandler_InsertLink) == "function"
        end,
        callback = function()
            local hasId = type(achievementId) == "number" and achievementId > 0
            local canGet = type(GetAchievementLink) == "function"
            local canInsert = type(ZO_LinkHandler_InsertLink) == "function"
            if not (hasId and canGet and canInsert) then
                return
            end

            local link
            if LINK_STYLE_BRACKETS ~= nil then
                link = GetAchievementLink(achievementId, LINK_STYLE_BRACKETS)
            else
                link = GetAchievementLink(achievementId)
            end

            if type(link) == "string" and link ~= "" then
                ZO_LinkHandler_InsertLink(link)
            end
        end,
    }

    entries[#entries + 1] = {
        label = GetString(SI_NVK3UT_TRACKER_ACHIEVEMENT_CONTEXT_SHOW_IN_ACHIEVEMENTS),
        enabled = function()
            return CanShowInAchievements(achievementId)
        end,
        callback = function()
            if achievementId and CanShowInAchievements(achievementId) then
                ShowAchievementInAchievements(achievementId)
            end
        end,
    }

    entries[#entries + 1] = {
        label = GetString(SI_NVK3UT_TRACKER_ACHIEVEMENT_CONTEXT_REMOVE_FAVORITE),
        enabled = function()
            return IsFavoriteAchievement(achievementId)
        end,
        callback = function()
            if achievementId and IsFavoriteAchievement(achievementId) then
                RemoveAchievementFromFavorites(achievementId)
            end
        end,
    }

    return entries
end

local function ShowAchievementContextMenu(control, data)
    if not control then
        return
    end

    local entries = BuildAchievementContextMenuEntries(data)
    if #entries == 0 then
        return
    end

    if Utils and Utils.ShowContextMenu and Utils.ShowContextMenu(control, entries) then
        return
    end

    if not (ClearMenu and AddCustomMenuItem and ShowMenu) then
        return
    end

    ClearMenu()

    local added = 0
    local function evaluateGate(gate)
        if gate == nil then
            return true
        end

        local gateType = type(gate)
        if gateType == "function" then
            local ok, result = pcall(gate, control)
            if not ok then
                return false
            end
            return result ~= false
        elseif gateType == "boolean" then
            return gate
        end

        return true
    end

    for index = 1, #entries do
        local entry = entries[index]
        if entry and type(entry.label) == "string" and type(entry.callback) == "function" then
            if evaluateGate(entry.visible) then
                local enabled = evaluateGate(entry.enabled)
                local itemType = (_G and _G.MENU_ADD_OPTION_LABEL) or 1
                local originalCallback = entry.callback
                local callback = originalCallback
                if type(originalCallback) == "function" then
                    callback = function(...)
                        if type(ClearMenu) == "function" then
                            pcall(ClearMenu)
                        end
                        originalCallback(...)
                    end
                end
                local beforeCount
                if type(ZO_Menu_GetNumMenuItems) == "function" then
                    local ok, count = pcall(ZO_Menu_GetNumMenuItems)
                    if ok and type(count) == "number" then
                        beforeCount = count
                    end
                end
                AddCustomMenuItem(entry.label, callback, itemType)
                local afterCount
                if type(ZO_Menu_GetNumMenuItems) == "function" then
                    local ok, count = pcall(ZO_Menu_GetNumMenuItems)
                    if ok and type(count) == "number" then
                        afterCount = count
                    end
                end
                local itemIndex = afterCount or ((type(beforeCount) == "number" and beforeCount + 1) or nil)
                if itemIndex and type(SetMenuItemEnabled) == "function" then
                    pcall(SetMenuItemEnabled, itemIndex, enabled ~= false)
                end
                added = added + 1
            end
        end
    end

    if added > 0 then
        ShowMenu(control)
    else
        ClearMenu()
    end
end

local function HasAnyFavoriteAchievements()
    local Fav = Nvk3UT and Nvk3UT.FavoritesData
    if not (Fav and Fav.GetAllFavorites) then
        return false
    end

    local function scopeHasFavorites(scope)
        if not scope then
            return false
        end

        local iterator, state, key = Fav.GetAllFavorites(scope)
        if type(iterator) ~= "function" then
            return false
        end

        for _, isFavorite in iterator, state, key do
            if isFavorite then
                return true
            end
        end

        return false
    end

    local scope = BuildFavoritesScope()
    if scopeHasFavorites(scope) then
        return true
    end

    if scope ~= "account" and scopeHasFavorites("account") then
        return true
    end

    if scope ~= "character" and scopeHasFavorites("character") then
        return true
    end

    return false
end

local function IsRecentAchievement(achievementId)
    if not achievementId then
        return false
    end

    local recentData = Nvk3UT and Nvk3UT.RecentData
    if not (recentData and recentData.Contains) then
        return false
    end

    local ok, result = pcall(recentData.Contains, achievementId)
    if ok then
        return result and true or false
    end

    return false
end

local function BuildTodoLookup()
    local Todo = Nvk3UT and Nvk3UT.TodoData
    if not (Todo and Todo.ListAllOpen) then
        return nil
    end

    local list = Todo.ListAllOpen(nil, false)
    if type(list) ~= "table" then
        return nil
    end

    local lookup = {}
    for index = 1, #list do
        local id = list[index]
        if id then
            lookup[id] = true
        end
    end

    return lookup
end

local function RequestRefresh()
    if not state.isInitialized then
        return
    end

    if state.pendingRefresh then
        return
    end

    state.pendingRefresh = true

    local function execute()
        state.pendingRefresh = false
        AchievementTracker:Refresh()
    end

    if zo_callLater then
        zo_callLater(execute, REFRESH_DEBOUNCE_MS)
    else
        execute()
    end
end

local function RefreshVisibility()
    if not state.control then
        return
    end

    local hidden = state.opts and state.opts.active == false
    state.control:SetHidden(hidden)
    NotifyHostContentChanged()
end

local function ResetLayoutState()
    state.orderedControls = {}
    state.lastAnchoredControl = nil
    state.lastAnchoredKind = nil
    state.categoryExpanded = nil
    state.nextCategoryGap = nil
    state.nextEntryGap = nil
    state.nextObjectiveGap = nil
    state.categoryAlignLogged = false
    state.entryAlignLogged = false
    state.objectiveAlignLogged = false
    state.anchorHygieneLogged = false
    state.lastAnchorY = 0
end

local function WarnMissingRows()
    if state.rowsWarningLogged then
        return
    end

    state.rowsWarningLogged = true

    local message = string.format("[%s] Achievement tracker rows helper missing; skipping render", MODULE_NAME)
    if d then
        d(message)
    elseif print then
        print(message)
    end
end

local function ComputeTotalHeightLegacy(rowHeights, verticalPadding)
    local totalHeight = 0

    if type(rowHeights) ~= "table" then
        return totalHeight
    end

    for index = 1, #rowHeights do
        totalHeight = totalHeight + (tonumber(rowHeights[index]) or 0)

        if index > 1 then
            totalHeight = totalHeight + (verticalPadding or 0)
        end
    end

    return totalHeight
end

local function ResolveRowKind(control)
    if not control then
        return nil
    end

    if control.rowType == "category" then
        return "header"
    end

    return "row"
end

local function AnchorControl(control, indentX, gapOverride)
    indentX = indentX or 0
    control:ClearAnchors()

    local rowKind = ResolveRowKind(control)
    local rowType = control.rowType
    local viewportInfo = getHostViewportInfo()
    local align = viewportInfo.align
    local verticalPadding = gapOverride
    local pendingEntryGap = nil
    local pendingObjectiveGap = nil
    if state.lastAnchoredControl then
        pendingEntryGap = state.nextEntryGap
        state.nextEntryGap = nil
        pendingObjectiveGap = state.nextObjectiveGap
        state.nextObjectiveGap = nil
    end
    if type(verticalPadding) ~= "number" then
        if type(pendingObjectiveGap) == "number" then
            verticalPadding = pendingObjectiveGap
        elseif rowKind == "header" then
            verticalPadding = CATEGORY_SPACING_ABOVE
        else
            verticalPadding = GetRowGap()
        end
    end
    if type(pendingEntryGap) == "number" then
        verticalPadding = verticalPadding + pendingEntryGap
    end
    if rowType == "achievement" then
        verticalPadding = verticalPadding + ENTRY_SPACING_ABOVE
    end

    local currentY
    if state.lastAnchoredControl then
        local previousHeight = state.lastAnchoredControl.GetHeight and state.lastAnchoredControl:GetHeight() or 0
        currentY = (state.lastAnchorY or 0) + previousHeight + verticalPadding
    else
        local offsetY = 0
        if rowKind == "header" and type(verticalPadding) == "number" then
            offsetY = verticalPadding
        end
        currentY = offsetY
    end

    if rowType == "objective" and align == "right" then
        control:SetAnchor(TOPLEFT, state.container, TOPLEFT, 0, currentY)
        control:SetAnchor(TOPRIGHT, state.container, TOPRIGHT, -indentX, currentY)
    else
        control:SetAnchor(TOPLEFT, state.container, TOPLEFT, indentX, currentY)
        control:SetAnchor(TOPRIGHT, state.container, TOPRIGHT, 0, currentY)
    end

    state.lastAnchoredControl = control
    state.lastAnchoredKind = rowKind
    state.orderedControls[#state.orderedControls + 1] = control
    control.currentIndent = indentX
    state.lastAnchorY = currentY
end

local function UpdateContentSize()
    local maxWidth = 0
    local visibleCount = 0
    local rowCount = 0
    local measuredHeight = 0
    local previousKind
    local pendingCategoryGap = nil
    local pendingEntryGap = nil
    local pendingObjectiveGap = nil
    local previousRowType = nil

    local function peekNextVisibleRow(startIndex)
        for nextIndex = startIndex + 1, #state.orderedControls do
            local nextControl = state.orderedControls[nextIndex]
            if nextControl and not nextControl:IsHidden() then
                return nextControl, nextControl.rowType
            end
        end
        return nil, nil
    end

    for index = 1, #state.orderedControls do
        local control = state.orderedControls[index]
        if control then
            RefreshControlMetrics(control)
        end
        if control and not control:IsHidden() then
            local height = control:GetHeight() or 0
            local rowKind = ResolveRowKind(control)
            local rowType = control.rowType
            local gap = 0
            if previousKind ~= nil then
                if type(pendingCategoryGap) == "number" then
                    gap = pendingCategoryGap
                    pendingCategoryGap = nil
                elseif type(pendingObjectiveGap) == "number" then
                    gap = pendingObjectiveGap
                    pendingObjectiveGap = nil
                elseif rowKind == "header" then
                    gap = CATEGORY_SPACING_ABOVE
                else
                    gap = GetRowGap()
                end
                if type(pendingEntryGap) == "number" then
                    gap = gap + pendingEntryGap
                    pendingEntryGap = nil
                end
                if rowType == "objective" then
                    if previousRowType == "objective" then
                        gap = gap + OBJECTIVE_SPACING_BETWEEN
                    else
                        gap = gap + OBJECTIVE_SPACING_ABOVE
                    end
                end
                if rowType == "achievement" then
                    gap = gap + ENTRY_SPACING_ABOVE
                end
            elseif rowKind == "header" then
                gap = CATEGORY_SPACING_ABOVE
            elseif rowType == "objective" then
                gap = gap + OBJECTIVE_SPACING_ABOVE
            elseif rowType == "achievement" then
                gap = ENTRY_SPACING_ABOVE
            end

            measuredHeight = measuredHeight + gap + height
            visibleCount = visibleCount + 1
            if rowKind ~= "header" then
                rowCount = rowCount + 1
            end

            local width = (control:GetWidth() or 0) + (control.currentIndent or 0)
            if width > maxWidth then
                maxWidth = width
            end

            previousKind = rowKind
            previousRowType = rowType
            pendingCategoryGap = nil
            if rowKind == "header" then
                pendingCategoryGap = CATEGORY_SPACING_BELOW
            end

            local nextControl, nextRowType = peekNextVisibleRow(index)
            if rowType == "achievement" or rowType == "objective" then
                if nextControl == nil or nextRowType ~= "objective" then
                    pendingEntryGap = ENTRY_SPACING_BELOW
                end
            end
            if rowType == "objective" then
                if nextControl == nil or nextRowType ~= "objective" then
                    pendingObjectiveGap = OBJECTIVE_SPACING_BELOW
                end
            end
        end
    end

    if visibleCount > 0 then
        if type(pendingObjectiveGap) == "number" then
            measuredHeight = measuredHeight + pendingObjectiveGap
        end
        if type(pendingEntryGap) == "number" then
            measuredHeight = measuredHeight + pendingEntryGap
        end
        if type(pendingCategoryGap) == "number" then
            measuredHeight = measuredHeight + pendingCategoryGap
        end
        measuredHeight = measuredHeight + GetBottomPixelNudge()
    end

    state.contentWidth = maxWidth
    state.contentHeight = measuredHeight
    state.lastHeight = NormalizeMetric(measuredHeight)

    if not state.anchorHygieneLogged and IsDebugLoggingEnabled() then
        local firstObjective
        for index = 1, #state.orderedControls do
            local control = state.orderedControls[index]
            if control and control.rowType == "objective" then
                firstObjective = control
                break
            end
        end
        DebugLog(string.format(
            "Anchor hygiene rows=%d objectiveLabel=%s",
            #state.orderedControls,
            tostring(firstObjective and firstObjective.label and firstObjective.label.GetName and firstObjective.label:GetName() or "none")
        ))
        state.anchorHygieneLogged = true
    end
end

local function IsCategoryExpanded()
    local achievementState = GetAchievementState()
    if achievementState and achievementState.IsGroupExpanded then
        local expanded = achievementState.IsGroupExpanded(CATEGORY_KEY)
        if expanded ~= nil then
            return expanded ~= false
        end
    end

    if not state.saved then
        return true
    end
    if state.saved.categoryExpanded == nil then
        state.saved.categoryExpanded = true
    end
    return state.saved.categoryExpanded ~= false
end

local function SetCategoryExpanded(expanded, context)
    local beforeExpanded = IsCategoryExpanded()
    local afterExpanded = beforeExpanded
    local source = (context and context.source) or "AchievementTracker:SetCategoryExpanded"
    local achievementState = GetAchievementState()

    if achievementState and achievementState.SetGroupExpanded then
        achievementState.SetGroupExpanded(CATEGORY_KEY, expanded, source)
        if achievementState.IsGroupExpanded then
            afterExpanded = achievementState.IsGroupExpanded(CATEGORY_KEY) ~= false
        end
    elseif state.saved then
        state.saved.categoryExpanded = expanded and true or false
        afterExpanded = IsCategoryExpanded()
    end

    if beforeExpanded ~= afterExpanded then
        LogCategoryExpansion(
            afterExpanded and "expand" or "collapse",
            (context and context.trigger) or "unknown",
            beforeExpanded,
            afterExpanded,
            source
        )
    end
end

local function SetEntryExpanded(achievementId, expanded, source)
    local achievementState = GetAchievementState()
    if achievementState and achievementState.SetGroupExpanded then
        achievementState.SetGroupExpanded(achievementId, expanded, source or "AchievementTracker:SetEntryExpanded")
        return
    end
    if not state.saved or not achievementId then
        return
    end
    state.saved.entryExpanded[achievementId] = expanded and true or false
end

local function IsEntryExpanded(achievementId)
    local achievementState = GetAchievementState()
    if achievementState and achievementState.IsGroupExpanded then
        local expanded = achievementState.IsGroupExpanded(achievementId)
        if expanded ~= nil then
            return expanded ~= false
        end
    end

    if not state.saved or not achievementId then
        return true
    end
    local expanded = state.saved.entryExpanded[achievementId]
    if expanded == nil then
        state.saved.entryExpanded[achievementId] = true
        expanded = true
    end
    return expanded ~= false
end

local function ShouldShowObjectiveCounter(objective)
    if not objective then
        return false
    end

    local maxValue = tonumber(objective.max)
    if not maxValue then
        return false
    end

    if maxValue <= 1 then
        return false
    end

    local current = objective.current
    if current == nil or current == "" then
        return false
    end

    return true
end

local function FormatObjectiveText(objective)
    local description = FormatDisplayString(objective.description)
    if description == "" then
        return ""
    end

    local text = description
    if ShouldShowObjectiveCounter(objective) then
        text = string.format("%s (%s/%s)", description, tostring(objective.current), tostring(objective.max))
    end

    return FormatDisplayString(text)
end

local function ShouldDisplayObjective(objective)
    if AchievementTrackerLayout and type(AchievementTrackerLayout.ShouldDisplayObjective) == "function" then
        return AchievementTrackerLayout.ShouldDisplayObjective(objective)
    end

    if not objective then
        return false
    end

    if objective.isVisible == false then
        return false
    end

    if objective.isComplete then
        return false
    end

    local current = tonumber(objective.current)
    local maxValue = tonumber(objective.max)
    if current and maxValue and maxValue > 0 and current >= maxValue then
        return false
    end

    local text = objective.description
    if not text or text == "" then
        return false
    end

    return true
end

local function CountDisplayableObjectives(achievement)
    if AchievementTrackerLayout and type(AchievementTrackerLayout.ComputeEntrySubrowCount) == "function" then
        return AchievementTrackerLayout.ComputeEntrySubrowCount(achievement)
    end

    local objectives = achievement and achievement.objectives
    if type(objectives) ~= "table" then
        return 0
    end

    local count = 0
    for index = 1, #objectives do
        if ShouldDisplayObjective(objectives[index]) then
            count = count + 1
        end
    end

    return count
end

local function BuildRowsCallbacks()
    return {
        ApplyMouseoverHighlight = ApplyMouseoverHighlight,
        RestoreBaseColor = RestoreBaseColor,
        IsCategoryExpanded = IsCategoryExpanded,
        SetCategoryExpanded = SetCategoryExpanded,
        Refresh = AchievementTracker.Refresh,
        ScheduleToggleFollowup = ScheduleToggleFollowup,
        IsEntryExpanded = IsEntryExpanded,
        SetEntryExpanded = SetEntryExpanded,
        ShowAchievementContextMenu = ShowAchievementContextMenu,
    }
end

local function EnsureRowsHelper()
    local rows = GetRows()
    if not rows then
        WarnMissingRows()
        return nil
    end

    if not state.container then
        return nil
    end

    rows:Init(state.container, { fonts = state.fonts, callbacks = BuildRowsCallbacks() })
    state.rowsWarningLogged = false

    return rows
end

local function ReleaseRows()
    local rows = GetRows()
    if rows then
        rows:ReleaseAll()
    end
end

local function LayoutObjective(rows, achievement, objective, objectiveIndex)
    if not ShouldDisplayObjective(objective) then
        return nil
    end

    local text = FormatObjectiveText(objective)
    if text == "" then
        return nil
    end

    local control = rows:AcquireRow(GetObjectiveRowKey(achievement.id, objectiveIndex), "objective")
    local r, g, b, a = GetAchievementTrackerColor("objectiveText")
    rows:ApplyRow(control, "objective", {
        data = {
            achievementId = achievement.id,
            objective = objective,
        },
        labelText = text,
        color = { r, g, b, a },
    })
    local viewportInfo = getHostViewportInfo()
    if control.label then
        if control.label.ClearAnchors then
            control.label:ClearAnchors()
            control.label:SetAnchor(TOPLEFT, control, TOPLEFT, 0, 0)
            control.label:SetAnchor(TOPRIGHT, control, TOPRIGHT, 0, 0)
        end
        if control.label.SetHorizontalAlignment then
        if viewportInfo.align == "right" then
            control.label:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
        else
            control.label:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        end
        end
    end
    ApplyRowMetrics(control, "objective", OBJECTIVE_INDENT_X, 0, 0, 0)
    control:SetHidden(false)
    AnchorControl(control, OBJECTIVE_INDENT_X, state.nextCategoryGap)
    state.nextCategoryGap = nil

    if not state.objectiveAlignLogged and IsDebugLoggingEnabled() then
        local wrapperWidth
        local host = Nvk3UT and Nvk3UT.TrackerHost
        if host and type(host.GetScrollContent) == "function" then
            local okContent, scrollContent = pcall(host.GetScrollContent, host)
            if okContent and scrollContent and scrollContent.GetWidth then
                local okWidth, measured = pcall(scrollContent.GetWidth, scrollContent)
                if okWidth then
                    wrapperWidth = tonumber(measured)
                end
            end
        end
        if wrapperWidth == nil and control.GetParent then
            local parent = control:GetParent()
            if parent and parent.GetWidth then
                local okWidth, measured = pcall(parent.GetWidth, parent)
                if okWidth then
                    wrapperWidth = tonumber(measured)
                end
            end
        end

        local labelWidth
        if control.label and control.label.GetWidth then
            local okWidth, measured = pcall(control.label.GetWidth, control.label)
            if okWidth then
                labelWidth = tonumber(measured)
            end
        end

        DebugLog(string.format(
            "Objective align=%s wrapperWidth=%s labelWidth=%s baseOffset=%s side=%s",
            tostring(viewportInfo.align),
            tostring(wrapperWidth),
            tostring(labelWidth),
            tostring(OBJECTIVE_BASE_INDENT),
            tostring(viewportInfo.align)
        ))
        state.objectiveAlignLogged = true
    end

    return control:GetHeight()
end

local function LayoutAchievement(rows, achievement)
    local control = rows:AcquireRow(GetAchievementRowKey(achievement.id), "achievement")
    local hasObjectives = achievement.objectives and #achievement.objectives > 0
    local expectedSubrowCount = CountDisplayableObjectives(achievement)
    local objectiveHeights = {}
    local laidOutSubrows = 0
    local isFavorite = IsFavoriteAchievement(achievement.id)
    local r, g, b, a = GetAchievementTrackerColor("entryTitle")
    rows:ApplyRow(control, "achievement", {
        data = {
            achievementId = achievement.id,
            hasObjectives = hasObjectives,
            isFavorite = isFavorite,
        },
        labelText = FormatDisplayString(achievement.name),
        baseColor = { r, g, b, a },
    })

    local expanded = hasObjectives and IsEntryExpanded(achievement.id)
    local viewportInfo = getHostViewportInfo()
    ApplyRowMetrics(
        control,
        "achievement",
        ENTRY_INDENT_X,
        ACHIEVEMENT_ICON_SLOT_WIDTH,
        ACHIEVEMENT_ICON_SLOT_PADDING_X,
        0
    )
    applyEntryAlignment(control, viewportInfo)
    control:SetHidden(false)
    AnchorControl(control, ENTRY_INDENT_X, state.nextCategoryGap)
    state.nextCategoryGap = nil

    if not state.entryAlignLogged and IsDebugLoggingEnabled() then
        local wrapperWidth
        local host = Nvk3UT and Nvk3UT.TrackerHost
        if host and type(host.GetScrollContent) == "function" then
            local okContent, scrollContent = pcall(host.GetScrollContent, host)
            if okContent and scrollContent and scrollContent.GetWidth then
                local okWidth, measured = pcall(scrollContent.GetWidth, scrollContent)
                if okWidth then
                    wrapperWidth = tonumber(measured)
                end
            end
        end
        if wrapperWidth == nil and control.GetParent then
            local parent = control:GetParent()
            if parent and parent.GetWidth then
                local okWidth, measured = pcall(parent.GetWidth, parent)
                if okWidth then
                    wrapperWidth = tonumber(measured)
                end
            end
        end

        local labelWidth
        if control.label and control.label.GetWidth then
            local okWidth, measured = pcall(control.label.GetWidth, control.label)
            if okWidth then
                labelWidth = tonumber(measured)
            end
        end

        local iconUsage = "slot"
        if control.iconSlot then
            local hasTexture = false
            if control.iconSlot.GetTextureFileName then
                local okTexture, texture = pcall(control.iconSlot.GetTextureFileName, control.iconSlot)
                if okTexture and type(texture) == "string" and texture ~= "" then
                    hasTexture = true
                end
            end
            if not hasTexture and control.iconSlot.GetAlpha then
                local okAlpha, alpha = pcall(control.iconSlot.GetAlpha, control.iconSlot)
                if okAlpha and type(alpha) == "number" and alpha > 0 then
                    hasTexture = true
                end
            end
            iconUsage = hasTexture and "real" or "slot"
        end

        DebugLog(string.format(
            "Entry align=%s wrapperWidth=%s labelWidth=%s icon=%s anchors=%s",
            tostring(viewportInfo.align),
            tostring(wrapperWidth),
            tostring(labelWidth),
            tostring(iconUsage),
            tostring(viewportInfo.align)
        ))
        state.entryAlignLogged = true
    end

    if hasObjectives and expanded then
        local visibleObjectives = {}
        for index = 1, #achievement.objectives do
            local objective = achievement.objectives[index]
            if ShouldDisplayObjective(objective) then
                visibleObjectives[#visibleObjectives + 1] = {
                    objective = objective,
                    index = index,
                }
            end
        end

        for index = 1, #visibleObjectives do
            local objectiveData = visibleObjectives[index]
            local isFirst = index == 1
            local isLast = index == #visibleObjectives

            if isFirst then
                state.nextObjectiveGap = OBJECTIVE_SPACING_ABOVE
            else
                state.nextObjectiveGap = OBJECTIVE_SPACING_BETWEEN
            end

            local objectiveHeight = LayoutObjective(rows, achievement, objectiveData.objective, objectiveData.index)
            if objectiveHeight then
                laidOutSubrows = laidOutSubrows + 1
                objectiveHeights[laidOutSubrows] = objectiveHeight
                if isLast then
                    state.nextObjectiveGap = OBJECTIVE_SPACING_BELOW
                end
            end
        end
    end

    state.nextEntryGap = ENTRY_SPACING_BELOW

    if AchievementTrackerLayout and type(AchievementTrackerLayout.ComputeEntryHeight) == "function" then
        local baseRowHeight = control:GetHeight() or 0
        local layoutHeight = AchievementTrackerLayout.ComputeEntryHeight(achievement, baseRowHeight, objectiveHeights)
    end
end

local function LayoutCategory(rows)
    local achievements = (state.snapshot and state.snapshot.achievements) or {}
    local sections = state.opts.sections or {}
    local showCompleted = sections.completed ~= false
    local showFavorites = true
    local showRecent = sections.recent ~= false
    local showTodo = sections.todo ~= false

    local todoLookup = BuildTodoLookup()
    local visibleEntries = {}

    for index = 1, #achievements do
        local achievement = achievements[index]
        local include = true
        local hasTag = false
        local allowed = false

        if achievement and achievement.id then
            local achievementId = achievement.id
            local isCompleted = achievement.flags and achievement.flags.isComplete
            local isFavorite = IsFavoriteAchievement(achievementId)
            local isRecent = IsRecentAchievement(achievementId)
            local isTodo = todoLookup and todoLookup[achievementId] or false

            if isCompleted then
                hasTag = true
                if showCompleted then
                    allowed = true
                end
            end

            if isFavorite then
                hasTag = true
                if showFavorites then
                    allowed = true
                end
            else
                hasTag = true
                include = false
            end

            if isRecent then
                hasTag = true
                if showRecent then
                    allowed = true
                end
            end

            if isTodo then
                hasTag = true
                if showTodo then
                    allowed = true
                end
            end

            if hasTag then
                include = allowed
            end
        end

        if include or not hasTag then
            visibleEntries[#visibleEntries + 1] = achievement
        end
    end

    local total = #visibleEntries

    if not HasAnyFavoriteAchievements() then
        return
    end

    local control = rows:AcquireRow(CATEGORY_ROW_KEY, "category")
    local expanded = IsCategoryExpanded()
    local colorRole = expanded and "activeTitle" or "categoryTitle"
    local r, g, b, a = GetAchievementTrackerColor(colorRole)
    rows:ApplyRow(control, "category", {
        data = { categoryKey = CATEGORY_KEY },
        labelText = FormatCategoryHeaderText(
            GetString(SI_NVK3UT_TRACKER_ACHIEVEMENT_CATEGORY_MAIN),
            total or 0,
            ShouldShowAchievementCategoryCounts()
        ),
        baseColor = { r, g, b, a },
        expanded = expanded,
    })
    state.categoryExpanded = expanded
    local viewportInfo = getHostViewportInfo()
    ApplyRowMetrics(
        control,
        "category",
        CATEGORY_INDENT_X,
        GetToggleWidth(control.toggle, CATEGORY_TOGGLE_WIDTH),
        TOGGLE_LABEL_PADDING_X,
        0,
        viewportInfo.viewportWidth or GetViewportWidth()
    )

    control:SetHidden(false)
    if control.indentAnchor and control.indentAnchor.SetAnchor then
        control.indentAnchor:ClearAnchors()
        if viewportInfo.align == "right" then
            control.indentAnchor:SetAnchor(TOPRIGHT, control, TOPRIGHT, -CATEGORY_INDENT_X, 0)
        else
            control.indentAnchor:SetAnchor(TOPLEFT, control, TOPLEFT, CATEGORY_INDENT_X, 0)
        end
    end
    if control.toggle and control.toggle.SetAnchor then
        control.toggle:ClearAnchors()
        if viewportInfo.align == "right" then
            control.toggle:SetAnchor(TOPRIGHT, control.indentAnchor or control, TOPRIGHT, 0, 0)
        else
            control.toggle:SetAnchor(TOPLEFT, control.indentAnchor or control, TOPLEFT, 0, 0)
        end
    end
    if control.label and control.label.SetAnchor then
        control.label:ClearAnchors()
        if viewportInfo.align == "right" then
            control.label:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
            control.label:SetAnchor(TOPRIGHT, control.toggle, TOPLEFT, -TOGGLE_LABEL_PADDING_X, 0)
            control.label:SetAnchor(TOPLEFT, control, TOPLEFT, 0, 0)
        else
            control.label:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
            control.label:SetAnchor(TOPLEFT, control.toggle, TOPRIGHT, TOGGLE_LABEL_PADDING_X, 0)
            control.label:SetAnchor(TOPRIGHT, control, TOPRIGHT, 0, 0)
        end
    end
    local gapOverride = state.nextCategoryGap
    if type(gapOverride) ~= "number" then
        if type(state.nextEntryGap) ~= "number" and type(state.nextObjectiveGap) ~= "number" then
            gapOverride = CATEGORY_SPACING_ABOVE
        end
    end
    AnchorControl(control, CATEGORY_INDENT_X, gapOverride)
    state.nextCategoryGap = CATEGORY_SPACING_BELOW

    if not state.categoryAlignLogged and IsDebugLoggingEnabled() then
        local width = viewportInfo.viewportWidth or GetViewportWidth()
        DebugLog(string.format(
            "Category align=%s scrollbar=%s insets=(%s,%s) rowWidth=%s",
            tostring(viewportInfo.align),
            tostring(viewportInfo.scrollbarSide),
            tostring(viewportInfo.leftInset),
            tostring(viewportInfo.rightInset),
            tostring(width)
        ))
        state.categoryAlignLogged = true
    end

    if expanded then
        for index = 1, #visibleEntries do
            LayoutAchievement(rows, visibleEntries[index])
        end
    end

end

local function Rebuild()
    if not state.container then
        return
    end

    local rows = EnsureRowsHelper()
    if not rows then
        ResetLayoutState()
        state.contentWidth = 0
        state.contentHeight = 0
        state.lastHeight = 0
        NotifyHostContentChanged()
        return
    end

    rows:BeginRefresh()
    ResetLayoutState()

    LayoutCategory(rows)

    rows:EndRefresh()
    UpdateContentSize()
    NotifyHostContentChanged()
end

local function OnSnapshotUpdated(snapshot)
    state.snapshot = snapshot

    if state.isInitialized then
        AchievementTracker:Refresh(snapshot)
    end
end

local function SubscribeToModel()
    if state.subscription or not Nvk3UT.AchievementModel or not Nvk3UT.AchievementModel.Subscribe then
        return
    end

    state.subscription = function(snapshot)
        OnSnapshotUpdated(snapshot)
    end

    Nvk3UT.AchievementModel.Subscribe(state.subscription)
end

local function UnsubscribeFromModel()
    if not state.subscription or not Nvk3UT.AchievementModel or not Nvk3UT.AchievementModel.Unsubscribe then
        state.subscription = nil
        return
    end

    Nvk3UT.AchievementModel.Unsubscribe(state.subscription)
    state.subscription = nil
end

function AchievementTracker:Init(parentControl, opts)
    local control = parentControl
    local initOpts = opts
    if self ~= AchievementTracker then
        control = self
        initOpts = parentControl
    end

    if not control then
        error("AchievementTracker.Init requires a parent control")
    end

    if state.isInitialized then
        AchievementTracker.Shutdown()
    end

    state.control = control
    state.container = control
    if state.control and state.control.SetResizeToFitDescendents then
        state.control:SetResizeToFitDescendents(true)
    end
    EnsureSavedVars()

    state.opts = {}
    state.fonts = {}

    AchievementTracker.ApplyTheme(state.saved or {})
    AchievementTracker.ApplySettings(state.saved or {})

    if initOpts then
        AchievementTracker.ApplyTheme(initOpts)
        AchievementTracker.ApplySettings(initOpts)
    end

    SubscribeToModel()

    state.snapshot = Nvk3UT.AchievementModel and Nvk3UT.AchievementModel.GetViewData and Nvk3UT.AchievementModel.GetViewData()

    state.isInitialized = true

    RefreshVisibility()
    AchievementTracker:Refresh()

    DebugDiagnostics(string.format("Init complete height=%s", tostring(AchievementTracker:GetHeight())))
end

function AchievementTracker:Refresh(viewModel)
    local data = viewModel
    if self ~= AchievementTracker then
        data = self
    end

    if not state.isInitialized then
        return
    end

    ApplyCategorySpacingFromSaved()
    ApplyEntrySpacingFromSaved()
    ApplyObjectiveSpacingFromSaved()

    if data ~= nil then
        state.snapshot = data
    elseif Nvk3UT.AchievementModel and Nvk3UT.AchievementModel.GetViewData then
        state.snapshot = Nvk3UT.AchievementModel.GetViewData() or state.snapshot
    end

    Rebuild()

    DebugDiagnostics(string.format("Refresh invoked height=%s", tostring(AchievementTracker:GetHeight())))
end

function AchievementTracker.Shutdown()
    UnsubscribeFromModel()

    ReleaseRows()

    state.container = nil
    state.control = nil
    state.snapshot = nil
    state.orderedControls = {}
    state.lastAnchoredControl = nil
    state.fonts = {}
    state.opts = {}
    state.rowsWarningLogged = false

    state.isInitialized = false
    state.pendingRefresh = false
    state.contentWidth = 0
    state.contentHeight = 0
    state.lastHeight = 0
    NotifyHostContentChanged()
end

local function EnsureSections()
    if type(state.opts.sections) ~= "table" then
        state.opts.sections = {}
    end
end

local function ApplySections(sections)
    if type(sections) ~= "table" then
        return
    end

    EnsureSections()
    for key, value in pairs(sections) do
        state.opts.sections[key] = value
    end
end

local function ApplyTooltipsSetting(value)
    state.opts.tooltips = (value ~= false)
end

function AchievementTracker.ApplySettings(settings)
    if type(settings) ~= "table" then
        return
    end

    ApplyCategorySpacingFromSaved()
    ApplyEntrySpacingFromSaved()
    ApplyObjectiveSpacingFromSaved()
    state.opts.active = settings.active ~= false
    ApplySections(settings.sections)
    if settings.tooltips ~= nil then
        ApplyTooltipsSetting(settings.tooltips)
    end

    RefreshVisibility()
    RequestRefresh()
end

function AchievementTracker.ApplyTheme(settings)
    if type(settings) ~= "table" then
        return
    end

    state.opts.fonts = state.opts.fonts or {}

    local fonts = settings.fonts or {}
    state.opts.fonts.category = BuildFontString(fonts.category, state.opts.fonts.category or DEFAULT_FONTS.category)
    state.opts.fonts.achievement = BuildFontString(fonts.title, state.opts.fonts.achievement or DEFAULT_FONTS.achievement)
    state.opts.fonts.objective = BuildFontString(fonts.line, state.opts.fonts.objective or DEFAULT_FONTS.objective)
    state.opts.fonts.toggle = state.opts.fonts.category or DEFAULT_FONTS.toggle

    state.fonts = MergeFonts(state.opts.fonts)

    RequestRefresh()
end

function AchievementTracker.RequestRefresh()
    RequestRefresh()
end

function AchievementTracker.SetActive(active)
    state.opts.active = (active ~= false)
    RefreshVisibility()
end

function AchievementTracker.RefreshVisibility()
    RefreshVisibility()
end

function AchievementTracker:GetHeight()
    if state.isInitialized and state.container then
        UpdateContentSize()
    end

    if state.lastHeight ~= nil then
        return NormalizeMetric(state.lastHeight)
    end

    return NormalizeMetric(state.contentHeight)
end

function AchievementTracker.GetContentSize()
    UpdateContentSize()
    return state.contentWidth or 0, state.contentHeight or 0
end

-- Ensure the container exists before populating entries during init
Nvk3UT.AchievementTracker = AchievementTracker

return AchievementTracker
