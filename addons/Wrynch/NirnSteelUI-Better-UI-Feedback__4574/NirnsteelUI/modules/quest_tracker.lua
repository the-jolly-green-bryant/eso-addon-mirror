local ADDON_NAME = "NirnsteelUI"
local EVENT_NAMESPACE = ADDON_NAME .. "_QuestTracker"

Nirnsteel_UI = Nirnsteel_UI or {}
local Nirnsteel_UI = Nirnsteel_UI
local QuestTracker = {}
Nirnsteel_UI.QuestTracker = QuestTracker

local DEFAULT_SETTINGS =
{
    enabled = true,
    backgroundOpacity = 62,
}

local CHROME_NAME = "Nirnsteel_UI_QuestTrackerChrome"
local PROMOTIONAL_CHROME_NAME = "Nirnsteel_UI_PromotionalEventTrackerChrome"
local EDGE_FRAME_TEXTURE = "EsoUI/Art/Miscellaneous/Gamepad/edgeframeGamepadBorder_thin.dds"
local APPLY_DELAY_MS = 50
local ROLL_STEP_MS = 45
local ROLL_COOLDOWN_MS = 240
local QUEST_TRACKER_MOUSE_EXIT_STATE = 2
local KEYBOARD_HEADER_WIDTH = 286
local KEYBOARD_LINE_WIDTH = 268
local KEYBOARD_TITLE_BAND_HEIGHT = 30

local function ClampNumber(value, minValue, maxValue)
    value = tonumber(value) or minValue
    return math.min(math.max(value, minValue), maxValue)
end

local function GetSettings()
    local settings = Nirnsteel_UI.Settings
    local accountSettings = settings and settings.account
    local moduleSettings = accountSettings and accountSettings.modules
    if moduleSettings and moduleSettings.questTracker then
        return moduleSettings.questTracker
    end

    return DEFAULT_SETTINGS
end

local function GetSettingValue(key)
    local settings = GetSettings()
    local value = settings and settings[key]
    if value == nil then
        return DEFAULT_SETTINGS[key]
    end

    return value
end

local function IsModuleEnabled()
    return GetSettingValue("enabled") ~= false
end

local function GetBackdropAlpha()
    return ClampNumber(GetSettingValue("backgroundOpacity"), 0, 90) / 100
end

local function GetTracker()
    return FOCUSED_QUEST_TRACKER
end

local function GetPromotionalTracker()
    return PROMOTIONAL_EVENT_TRACKER
end

local function GetTrackerControl(tracker)
    if tracker and tracker.GetContainerControl then
        return tracker:GetContainerControl()
    end
end

local function GetTrackerPanelContainer(tracker)
    local trackerPanel = tracker and tracker.trackerPanel
    return trackerPanel and trackerPanel:GetNamedChild("Container")
end

local function GetActivePoolObjects(pool)
    if pool and pool.GetActiveObjects then
        return pool:GetActiveObjects()
    end
end

local function HasTrackedContent(tracker)
    if tracker and tracker.GetNumTracked then
        return tracker:GetNumTracked() > 0
    end

    local headers = GetActivePoolObjects(tracker and tracker.headerPool)
    return headers and next(headers) ~= nil
end

local function SafeSetFont(label, font)
    if label and label.SetFont then
        label:SetFont(font)
    end
end

local function SafeSetColor(label, r, g, b, a)
    if label and label.SetColor then
        label:SetColor(r, g, b, a)
    end
end

local function SafeSetAlpha(control, alpha)
    if control and control.SetAlpha then
        control:SetAlpha(alpha)
    end
end

local function SafeSetHidden(control, hidden)
    if control and control.SetHidden then
        control:SetHidden(hidden)
    end
end

local function SafeSetHorizontalAlignment(label, alignment)
    if label and label.SetHorizontalAlignment then
        label:SetHorizontalAlignment(alignment)
    end
end

local function SafeSetTreeOffsetY(control, offsetY)
    local treeNode = control and control.m_TreeNode
    if treeNode and treeNode.SetOffsetY then
        treeNode:SetOffsetY(offsetY)
    end
end

local function SafeSetDimensions(control, width, height)
    if control and control.SetDimensions then
        control:SetDimensions(width, height)
    end
end

local function BuildTextFont(size, outline)
    return string.format("$(BOLD_FONT)|%d|%s", size, outline or "thick-outline")
end

local function StyleIconPlate(parent, icon, existingPlate)
    if not parent or not icon then
        SafeSetHidden(existingPlate, true)
        return existingPlate
    end

    local plate = existingPlate
    if not plate then
        plate = WINDOW_MANAGER:CreateControl(nil, parent, CT_BACKDROP)
        plate.nirnsteelOwner = ADDON_NAME
        plate:SetExcludeFromResizeToFitExtents(true)
        plate:SetMouseEnabled(false)
        plate:SetDrawLayer(DL_BACKGROUND)
        plate:SetCenterColor(0.012, 0.010, 0.008, 0.54)
        plate:SetEdgeColor(0.96, 0.68, 0.18, 0.22)
        plate:SetEdgeTexture(EDGE_FRAME_TEXTURE, 128, 16, 3, 0)
    end

    plate:ClearAnchors()
    plate:SetAnchor(TOPLEFT, icon, TOPLEFT, -4, -4)
    plate:SetAnchor(BOTTOMRIGHT, icon, BOTTOMRIGHT, 4, 4)
    plate:SetCenterColor(0.012, 0.010, 0.008, 0.54)
    plate:SetEdgeColor(0.96, 0.68, 0.18, 0.22)
    plate:SetHidden(not IsModuleEnabled() or ((icon.IsHidden and icon:IsHidden()) == true))
    return plate
end

local function StyleHeader(header, pulseAmount)
    pulseAmount = pulseAmount or 0
    SafeSetFont(header, IsInGamepadPreferredMode() and "ZoFontGamepadBold27" or BuildTextFont(19, "soft-shadow-thick"))
    SafeSetColor(header, 1.00, 0.78 + 0.10 * pulseAmount, 0.18 + 0.18 * pulseAmount, 1)
    SafeSetHorizontalAlignment(header, IsInGamepadPreferredMode() and TEXT_ALIGN_RIGHT or TEXT_ALIGN_LEFT)
    if not IsInGamepadPreferredMode() then
        SafeSetDimensions(header, KEYBOARD_HEADER_WIDTH, 0)
        SafeSetTreeOffsetY(header, 9)
        header.extraWidth = 0
    end
    if header and header.icon then
        header.icon:SetDimensions(IsInGamepadPreferredMode() and 44 or 22, IsInGamepadPreferredMode() and 44 or 22)
        header.icon:SetColor(1, 1, 1, 1)
        header.nirnsteelIconPlate = StyleIconPlate(header, header.icon, header.nirnsteelIconPlate)
    end
end

local function StyleCondition(condition, pulseAmount)
    pulseAmount = pulseAmount or 0
    SafeSetFont(condition, IsInGamepadPreferredMode() and "ZoFontGamepad34" or BuildTextFont(15, "soft-shadow-thin"))
    SafeSetColor(condition, 0.94 + 0.06 * pulseAmount, 0.95 + 0.05 * pulseAmount, 0.98 + 0.02 * pulseAmount, 1)
    SafeSetHorizontalAlignment(condition, IsInGamepadPreferredMode() and TEXT_ALIGN_RIGHT or TEXT_ALIGN_LEFT)
    if not IsInGamepadPreferredMode() then
        SafeSetDimensions(condition, KEYBOARD_LINE_WIDTH, 0)
        SafeSetTreeOffsetY(condition, 0)
    end
end

local function StyleStepDescription(stepDescription, pulseAmount)
    pulseAmount = pulseAmount or 0
    SafeSetFont(stepDescription, IsInGamepadPreferredMode() and "ZoFontGamepadBold22" or BuildTextFont(14, "soft-shadow-thin"))
    SafeSetColor(stepDescription, 0.72 + 0.10 * pulseAmount, 0.82 + 0.08 * pulseAmount, 0.96 + 0.04 * pulseAmount, 1)
    SafeSetHorizontalAlignment(stepDescription, IsInGamepadPreferredMode() and TEXT_ALIGN_RIGHT or TEXT_ALIGN_LEFT)
    if not IsInGamepadPreferredMode() then
        SafeSetDimensions(stepDescription, KEYBOARD_LINE_WIDTH, 0)
        SafeSetTreeOffsetY(stepDescription, 0)
    end
end

local function AppendPoolText(parts, pool)
    local activeObjects = GetActivePoolObjects(pool)
    if activeObjects then
        for _, control in pairs(activeObjects) do
            if control.GetText then
                parts[#parts + 1] = control:GetText() or ""
            end
        end
    end
end

local function BuildTrackerSignature(tracker)
    local parts = {}
    AppendPoolText(parts, tracker and tracker.headerPool)
    AppendPoolText(parts, tracker and tracker.conditionPool)
    AppendPoolText(parts, tracker and tracker.stepDescriptionPool)
    table.sort(parts)
    return table.concat(parts, "\031")
end

function QuestTracker:GetOrCreateChrome(tracker)
    local panelContainer = GetTrackerPanelContainer(tracker)
    local trackerControl = GetTrackerControl(tracker)
    if not panelContainer or not trackerControl then
        return
    end

    if self.chrome and self.chrome:GetParent() == panelContainer then
        return self.chrome
    end

    local chrome = WINDOW_MANAGER:CreateControl(CHROME_NAME, panelContainer, CT_CONTROL)
    chrome.nirnsteelOwner = ADDON_NAME
    chrome:SetExcludeFromResizeToFitExtents(true)
    chrome:SetAnchor(TOPLEFT, trackerControl, TOPLEFT, -24, -9)
    chrome:SetAnchor(BOTTOMRIGHT, trackerControl, BOTTOMRIGHT, 10, 9)
    chrome:SetDrawLayer(DL_BACKGROUND)
    chrome:SetMouseEnabled(false)
    chrome:SetHidden(true)

    chrome.shadow = WINDOW_MANAGER:CreateControl(nil, chrome, CT_BACKDROP)
    chrome.shadow:SetMouseEnabled(false)
    chrome.shadow:SetAnchor(TOPLEFT, chrome, TOPLEFT, -3, -3)
    chrome.shadow:SetAnchor(BOTTOMRIGHT, chrome, BOTTOMRIGHT, 3, 4)
    chrome.shadow:SetCenterColor(0, 0, 0, 0.30)
    chrome.shadow:SetEdgeColor(0, 0, 0, 0.46)
    chrome.shadow:SetEdgeTexture(EDGE_FRAME_TEXTURE, 128, 16, 5, 0)

    chrome.panel = WINDOW_MANAGER:CreateControl(nil, chrome, CT_BACKDROP)
    chrome.panel:SetMouseEnabled(false)
    chrome.panel:SetAnchorFill(chrome)
    chrome.panel:SetCenterColor(0.014, 0.012, 0.010, GetBackdropAlpha())
    chrome.panel:SetEdgeColor(0.86, 0.64, 0.28, 0.16)
    chrome.panel:SetEdgeTexture(EDGE_FRAME_TEXTURE, 128, 16, 3, 0)

    chrome.glow = WINDOW_MANAGER:CreateControl(nil, chrome, CT_BACKDROP)
    chrome.glow:SetMouseEnabled(false)
    chrome.glow:SetAnchor(TOPLEFT, chrome, TOPLEFT, 3, 3)
    chrome.glow:SetAnchor(BOTTOMRIGHT, chrome, BOTTOMRIGHT, -3, -3)
    chrome.glow:SetCenterColor(0.96, 0.66, 0.16, 0)
    chrome.glow:SetEdgeColor(0.38, 0.88, 1.00, 0)
    chrome.glow:SetEdgeTexture(EDGE_FRAME_TEXTURE, 128, 16, 4, 0)
    chrome.glow:SetAlpha(0)

    chrome.titleBand = WINDOW_MANAGER:CreateControl(nil, chrome, CT_BACKDROP)
    chrome.titleBand:SetMouseEnabled(false)
    chrome.titleBand:SetAnchor(TOPLEFT, chrome, TOPLEFT, 4, 4)
    chrome.titleBand:SetAnchor(TOPRIGHT, chrome, TOPRIGHT, -4, 4)
    chrome.titleBand:SetDimensions(1, KEYBOARD_TITLE_BAND_HEIGHT)
    chrome.titleBand:SetCenterColor(0.085, 0.052, 0.014, 0.36)
    chrome.titleBand:SetEdgeColor(0.98, 0.66, 0.20, 0)
    chrome.titleBand:SetEdgeTexture("", 1, 1, 1, 0)

    chrome.accent = WINDOW_MANAGER:CreateControl(nil, chrome, CT_BACKDROP)
    chrome.accent:SetMouseEnabled(false)
    chrome.accent:SetAnchor(TOPLEFT, chrome, TOPLEFT, 4, 7)
    chrome.accent:SetAnchor(BOTTOMLEFT, chrome, BOTTOMLEFT, 4, -7)
    chrome.accent:SetDimensions(2, 1)
    chrome.accent:SetCenterColor(1.00, 0.70, 0.16, 0.72)
    chrome.accent:SetEdgeColor(1.00, 0.70, 0.16, 0)
    chrome.accent:SetEdgeTexture("", 1, 1, 1, 0)

    chrome.divider = WINDOW_MANAGER:CreateControl(nil, chrome, CT_BACKDROP)
    chrome.divider:SetMouseEnabled(false)
    chrome.divider:SetAnchor(TOPLEFT, chrome.titleBand, BOTTOMLEFT, 7, 0)
    chrome.divider:SetAnchor(TOPRIGHT, chrome.titleBand, BOTTOMRIGHT, -5, 0)
    chrome.divider:SetDimensions(1, 1)
    chrome.divider:SetCenterColor(1.00, 0.70, 0.18, 0.24)
    chrome.divider:SetEdgeColor(1.00, 0.70, 0.18, 0)
    chrome.divider:SetEdgeTexture("", 1, 1, 1, 0)

    chrome.sweep = WINDOW_MANAGER:CreateControl(nil, chrome, CT_BACKDROP)
    chrome.sweep:SetMouseEnabled(false)
    chrome.sweep:SetDimensions(1, 3)
    chrome.sweep:SetCenterColor(1.00, 0.84, 0.28, 0.0)
    chrome.sweep:SetEdgeColor(1.00, 0.84, 0.28, 0)
    chrome.sweep:SetEdgeTexture("", 1, 1, 1, 0)
    chrome.sweep:SetAlpha(0)

    chrome.rollFill = WINDOW_MANAGER:CreateControl(nil, chrome, CT_BACKDROP)
    chrome.rollFill:SetMouseEnabled(false)
    chrome.rollFill:SetDimensions(1, 14)
    chrome.rollFill:SetCenterColor(0.10, 0.065, 0.018, 0)
    chrome.rollFill:SetEdgeColor(0.62, 0.94, 1.00, 0)
    chrome.rollFill:SetEdgeTexture("", 1, 1, 1, 0)
    chrome.rollFill:SetAlpha(0)

    self.chrome = chrome
    return chrome
end

function QuestTracker:ApplyChrome(tracker)
    local chrome = self:GetOrCreateChrome(tracker)
    if not chrome then
        return
    end

    local alpha = GetBackdropAlpha()
    chrome.panel:SetCenterColor(0.014, 0.012, 0.010, alpha)
    chrome.panel:SetEdgeColor(0.86, 0.64, 0.28, math.min(0.18, alpha * 0.28))
    chrome.titleBand:SetDimensions(1, IsInGamepadPreferredMode() and 50 or KEYBOARD_TITLE_BAND_HEIGHT)
    chrome.titleBand:SetCenterColor(0.085, 0.052, 0.014, math.min(0.46, alpha * 0.60))
    chrome.accent:SetCenterColor(1.00, 0.70, 0.16, math.min(0.78, alpha + 0.12))
    chrome:SetHidden(not IsModuleEnabled() or not HasTrackedContent(tracker))
end

function QuestTracker:ApplyRollVisuals(tracker, rollAmount, rollProgress)
    local chrome = self.chrome
    if not chrome or not IsModuleEnabled() or chrome:IsHidden() then
        return
    end

    rollAmount = rollAmount or 0
    SafeSetAlpha(chrome.glow, rollAmount * 0.58)
    SafeSetAlpha(chrome.sweep, rollAmount)
    SafeSetAlpha(chrome.rollFill, rollAmount)

    chrome.glow:SetCenterColor(1.00, 0.68, 0.16, rollAmount * 0.10)
    chrome.glow:SetEdgeColor(0.42, 0.92, 1.00, rollAmount * 0.25)
    chrome.accent:SetCenterColor(1.00, 0.72 + 0.14 * rollAmount, 0.18 + 0.16 * rollAmount, math.min(0.86, 0.56 + rollAmount * 0.24))
    chrome.divider:SetCenterColor(1.00, 0.72 + 0.18 * rollAmount, 0.18 + 0.18 * rollAmount, 0.22 + rollAmount * 0.32)

    local height = chrome.GetHeight and chrome:GetHeight() or 54
    local rollY = -8 + (height + 16) * (rollProgress or 0)
    chrome.sweep:ClearAnchors()
    chrome.sweep:SetAnchor(TOPLEFT, chrome, TOPLEFT, 5, rollY)
    chrome.sweep:SetAnchor(TOPRIGHT, chrome, TOPRIGHT, -5, rollY)
    chrome.sweep:SetCenterColor(1.00, 0.84, 0.28, rollAmount * 0.42)

    chrome.rollFill:ClearAnchors()
    chrome.rollFill:SetAnchor(TOPLEFT, chrome, TOPLEFT, 5, rollY - 10)
    chrome.rollFill:SetAnchor(TOPRIGHT, chrome, TOPRIGHT, -5, rollY - 10)
    chrome.rollFill:SetCenterColor(0.10, 0.065, 0.018, rollAmount * 0.18)

    self:ApplyTextStyle(tracker, rollAmount)
end

function QuestTracker:PlayUpdateRoll(tracker)
    local chrome = self.chrome
    if not chrome or chrome:IsHidden() then
        return
    end

    local nowMS = GetFrameTimeMilliseconds()
    if self.lastRollMS and nowMS - self.lastRollMS < ROLL_COOLDOWN_MS then
        return
    end
    self.lastRollMS = nowMS
    self.rollToken = (self.rollToken or 0) + 1
    local rollToken = self.rollToken

    local steps =
    {
        { 0.00, 0.00 },
        { 1.00, 0.18 },
        { 0.72, 0.38 },
        { 0.42, 0.62 },
        { 0.18, 0.84 },
        { 0.00, 1.00 },
    }

    for stepIndex, step in ipairs(steps) do
        zo_callLater(function()
            if self.rollToken == rollToken then
                self:ApplyRollVisuals(tracker, step[1], step[2])
            end
        end, (stepIndex - 1) * ROLL_STEP_MS)
    end
end

function QuestTracker:AdjustChromeForContent(tracker)
    local chrome = self.chrome
    if not chrome or not chrome.titleBand then
        return
    end

    local titleBandHeight = IsInGamepadPreferredMode() and 50 or KEYBOARD_TITLE_BAND_HEIGHT
    local headers = GetActivePoolObjects(tracker and tracker.headerPool)
    if headers then
        for _, header in pairs(headers) do
            if header.GetTextDimensions then
                local _, headerHeight = header:GetTextDimensions()
                titleBandHeight = math.max(titleBandHeight, (tonumber(headerHeight) or 0) + 14)
                break
            end
        end
    end

    chrome.titleBand:SetDimensions(1, titleBandHeight)
end

function QuestTracker:ApplyTextStyle(tracker, pulseAmount)
    local headers = GetActivePoolObjects(tracker and tracker.headerPool)
    if headers then
        for _, header in pairs(headers) do
            StyleHeader(header, pulseAmount)
        end
    end

    local conditions = GetActivePoolObjects(tracker and tracker.conditionPool)
    if conditions then
        for _, condition in pairs(conditions) do
            StyleCondition(condition, pulseAmount)
        end
    end

    local stepDescriptions = GetActivePoolObjects(tracker and tracker.stepDescriptionPool)
    if stepDescriptions then
        for _, stepDescription in pairs(stepDescriptions) do
            StyleStepDescription(stepDescription, pulseAmount)
        end
    end

    self:AdjustChromeForContent(tracker)
end

function QuestTracker:HideHeaderIconPlates(tracker)
    local headers = GetActivePoolObjects(tracker and tracker.headerPool)
    if headers then
        for _, header in pairs(headers) do
            SafeSetHidden(header.nirnsteelIconPlate, true)
        end
    end
end

function QuestTracker:RestoreStockStyle(tracker)
    if not tracker or self.restoringStockStyle then
        return
    end

    self.rollToken = (self.rollToken or 0) + 1
    self:HideHeaderIconPlates(tracker)
    self.restoringStockStyle = true
    if tracker.ApplyPlatformStyle then
        tracker:ApplyPlatformStyle()
    elseif tracker.RefreshHeaderConColors then
        tracker:RefreshHeaderConColors()
    end
    self.restoringStockStyle = nil
end

function QuestTracker:Apply(tracker)
    tracker = tracker or GetTracker()
    if not tracker then
        return
    end

    local enabled = IsModuleEnabled()
    self:ApplyChrome(tracker)
    if enabled then
        self.wasEnabled = true
        self:ApplyTextStyle(tracker)
        local signature = BuildTrackerSignature(tracker)
        if signature ~= "" and signature ~= self.lastTrackerSignature then
            self.lastTrackerSignature = signature
            self:PlayUpdateRoll(tracker)
        end
    elseif self.wasEnabled ~= false then
        self.wasEnabled = false
        self.lastTrackerSignature = nil
        self:RestoreStockStyle(tracker)
    end
end

function QuestTracker:GetOrCreatePromotionalChrome(tracker)
    local control = tracker and tracker.control
    local container = tracker and tracker.container
    if not control or not container then
        return
    end

    if self.promotionalChrome and self.promotionalChrome:GetParent() == control then
        return self.promotionalChrome
    end

    local chrome = WINDOW_MANAGER:CreateControl(PROMOTIONAL_CHROME_NAME, control, CT_CONTROL)
    chrome.nirnsteelOwner = ADDON_NAME
    chrome:SetExcludeFromResizeToFitExtents(true)
    chrome:SetAnchor(TOPLEFT, container, TOPLEFT, -24, -8)
    chrome:SetAnchor(BOTTOMRIGHT, container, BOTTOMRIGHT, 10, 9)
    chrome:SetDrawLayer(DL_BACKGROUND)
    chrome:SetMouseEnabled(false)
    chrome:SetHidden(true)

    chrome.shadow = WINDOW_MANAGER:CreateControl(nil, chrome, CT_BACKDROP)
    chrome.shadow:SetMouseEnabled(false)
    chrome.shadow:SetAnchor(TOPLEFT, chrome, TOPLEFT, -3, -3)
    chrome.shadow:SetAnchor(BOTTOMRIGHT, chrome, BOTTOMRIGHT, 3, 4)
    chrome.shadow:SetCenterColor(0, 0, 0, 0.30)
    chrome.shadow:SetEdgeColor(0, 0, 0, 0.46)
    chrome.shadow:SetEdgeTexture(EDGE_FRAME_TEXTURE, 128, 16, 5, 0)

    chrome.panel = WINDOW_MANAGER:CreateControl(nil, chrome, CT_BACKDROP)
    chrome.panel:SetMouseEnabled(false)
    chrome.panel:SetAnchorFill(chrome)
    chrome.panel:SetCenterColor(0.014, 0.012, 0.010, GetBackdropAlpha())
    chrome.panel:SetEdgeColor(0.86, 0.64, 0.28, 0.16)
    chrome.panel:SetEdgeTexture(EDGE_FRAME_TEXTURE, 128, 16, 3, 0)

    chrome.glow = WINDOW_MANAGER:CreateControl(nil, chrome, CT_BACKDROP)
    chrome.glow:SetMouseEnabled(false)
    chrome.glow:SetAnchor(TOPLEFT, chrome, TOPLEFT, 3, 3)
    chrome.glow:SetAnchor(BOTTOMRIGHT, chrome, BOTTOMRIGHT, -3, -3)
    chrome.glow:SetCenterColor(0.96, 0.66, 0.16, 0)
    chrome.glow:SetEdgeColor(0.38, 0.88, 1.00, 0)
    chrome.glow:SetEdgeTexture(EDGE_FRAME_TEXTURE, 128, 16, 4, 0)
    chrome.glow:SetAlpha(0)

    chrome.titleBand = WINDOW_MANAGER:CreateControl(nil, chrome, CT_BACKDROP)
    chrome.titleBand:SetMouseEnabled(false)
    chrome.titleBand:SetAnchor(TOPLEFT, chrome, TOPLEFT, 4, 4)
    chrome.titleBand:SetAnchor(TOPRIGHT, chrome, TOPRIGHT, -4, 4)
    chrome.titleBand:SetDimensions(1, KEYBOARD_TITLE_BAND_HEIGHT)
    chrome.titleBand:SetCenterColor(0.085, 0.052, 0.014, 0.36)
    chrome.titleBand:SetEdgeColor(0.98, 0.66, 0.20, 0)
    chrome.titleBand:SetEdgeTexture("", 1, 1, 1, 0)

    chrome.accent = WINDOW_MANAGER:CreateControl(nil, chrome, CT_BACKDROP)
    chrome.accent:SetMouseEnabled(false)
    chrome.accent:SetAnchor(TOPLEFT, chrome, TOPLEFT, 4, 7)
    chrome.accent:SetAnchor(BOTTOMLEFT, chrome, BOTTOMLEFT, 4, -7)
    chrome.accent:SetDimensions(2, 1)
    chrome.accent:SetCenterColor(1.00, 0.70, 0.16, 0.64)
    chrome.accent:SetEdgeColor(1.00, 0.70, 0.16, 0)
    chrome.accent:SetEdgeTexture("", 1, 1, 1, 0)

    chrome.divider = WINDOW_MANAGER:CreateControl(nil, chrome, CT_BACKDROP)
    chrome.divider:SetMouseEnabled(false)
    chrome.divider:SetAnchor(TOPLEFT, chrome.titleBand, BOTTOMLEFT, 7, 0)
    chrome.divider:SetAnchor(TOPRIGHT, chrome.titleBand, BOTTOMRIGHT, -5, 0)
    chrome.divider:SetDimensions(1, 1)
    chrome.divider:SetCenterColor(1.00, 0.70, 0.18, 0.24)
    chrome.divider:SetEdgeColor(1.00, 0.70, 0.18, 0)
    chrome.divider:SetEdgeTexture("", 1, 1, 1, 0)

    chrome.sweep = WINDOW_MANAGER:CreateControl(nil, chrome, CT_BACKDROP)
    chrome.sweep:SetMouseEnabled(false)
    chrome.sweep:SetDimensions(1, 3)
    chrome.sweep:SetCenterColor(1.00, 0.84, 0.28, 0)
    chrome.sweep:SetEdgeColor(1.00, 0.84, 0.28, 0)
    chrome.sweep:SetEdgeTexture("", 1, 1, 1, 0)
    chrome.sweep:SetAlpha(0)

    chrome.rollFill = WINDOW_MANAGER:CreateControl(nil, chrome, CT_BACKDROP)
    chrome.rollFill:SetMouseEnabled(false)
    chrome.rollFill:SetDimensions(1, 14)
    chrome.rollFill:SetCenterColor(0.10, 0.065, 0.018, 0)
    chrome.rollFill:SetEdgeColor(0.62, 0.94, 1.00, 0)
    chrome.rollFill:SetEdgeTexture("", 1, 1, 1, 0)
    chrome.rollFill:SetAlpha(0)

    self.promotionalChrome = chrome
    return chrome
end

function QuestTracker:ApplyPromotionalChrome(tracker)
    local chrome = self:GetOrCreatePromotionalChrome(tracker)
    if not chrome then
        return
    end

    local alpha = GetBackdropAlpha()
    chrome.panel:SetCenterColor(0.014, 0.012, 0.010, alpha)
    chrome.panel:SetEdgeColor(0.86, 0.64, 0.28, math.min(0.18, alpha * 0.28))
    chrome.titleBand:SetDimensions(1, IsInGamepadPreferredMode() and 50 or KEYBOARD_TITLE_BAND_HEIGHT)
    chrome.titleBand:SetCenterColor(0.085, 0.052, 0.014, math.min(0.46, alpha * 0.60))
    chrome.accent:SetCenterColor(1.00, 0.70, 0.16, math.min(0.72, alpha + 0.06))
    chrome:SetHidden(not IsModuleEnabled() or not tracker.container or tracker.container:IsHidden())
end

function QuestTracker:ApplyPromotionalTextStyle(tracker, rollAmount)
    rollAmount = rollAmount or 0
    SafeSetFont(tracker.headerLabel, IsInGamepadPreferredMode() and "ZoFontGamepadBold27" or BuildTextFont(18, "soft-shadow-thick"))
    SafeSetFont(tracker.subLabel, IsInGamepadPreferredMode() and "ZoFontGamepad34" or BuildTextFont(15, "soft-shadow-thin"))
    SafeSetFont(tracker.progressLabel, IsInGamepadPreferredMode() and "ZoFontGamepad34" or BuildTextFont(14, "soft-shadow-thin"))
    SafeSetColor(tracker.headerLabel, 1.00, 0.78 + 0.10 * rollAmount, 0.18 + 0.18 * rollAmount, 1)
    SafeSetColor(tracker.subLabel, 0.94 + 0.06 * rollAmount, 0.95 + 0.05 * rollAmount, 0.98 + 0.02 * rollAmount, 1)
    SafeSetColor(tracker.progressLabel, 0.72 + 0.10 * rollAmount, 0.82 + 0.08 * rollAmount, 0.96 + 0.04 * rollAmount, 1)
    SafeSetHorizontalAlignment(tracker.headerLabel, IsInGamepadPreferredMode() and TEXT_ALIGN_RIGHT or TEXT_ALIGN_LEFT)
    SafeSetHorizontalAlignment(tracker.subLabel, IsInGamepadPreferredMode() and TEXT_ALIGN_RIGHT or TEXT_ALIGN_LEFT)
    SafeSetHorizontalAlignment(tracker.progressLabel, IsInGamepadPreferredMode() and TEXT_ALIGN_RIGHT or TEXT_ALIGN_LEFT)

    if tracker.headerIcon then
        tracker.headerIcon:SetDimensions(IsInGamepadPreferredMode() and 44 or 22, IsInGamepadPreferredMode() and 44 or 22)
        tracker.headerIcon:SetColor(1, 1, 1, 1)
        tracker.nirnsteelIconPlate = StyleIconPlate(tracker.headerLabel, tracker.headerIcon, tracker.nirnsteelIconPlate)
    end
end

function QuestTracker:ApplyPromotionalRollVisuals(tracker, rollAmount, rollProgress)
    local chrome = self.promotionalChrome
    if not chrome or not IsModuleEnabled() or chrome:IsHidden() then
        return
    end

    rollAmount = rollAmount or 0
    SafeSetAlpha(chrome.glow, rollAmount * 0.58)
    SafeSetAlpha(chrome.sweep, rollAmount)
    SafeSetAlpha(chrome.rollFill, rollAmount)

    chrome.glow:SetCenterColor(1.00, 0.68, 0.16, rollAmount * 0.10)
    chrome.glow:SetEdgeColor(0.42, 0.92, 1.00, rollAmount * 0.25)
    chrome.accent:SetCenterColor(1.00, 0.72 + 0.14 * rollAmount, 0.18 + 0.16 * rollAmount, math.min(0.86, 0.56 + rollAmount * 0.24))
    chrome.divider:SetCenterColor(1.00, 0.72 + 0.18 * rollAmount, 0.18 + 0.18 * rollAmount, 0.22 + rollAmount * 0.32)

    local height = chrome.GetHeight and chrome:GetHeight() or 54
    local rollY = -8 + (height + 16) * (rollProgress or 0)
    chrome.sweep:ClearAnchors()
    chrome.sweep:SetAnchor(TOPLEFT, chrome, TOPLEFT, 5, rollY)
    chrome.sweep:SetAnchor(TOPRIGHT, chrome, TOPRIGHT, -5, rollY)
    chrome.sweep:SetCenterColor(1.00, 0.84, 0.28, rollAmount * 0.42)

    chrome.rollFill:ClearAnchors()
    chrome.rollFill:SetAnchor(TOPLEFT, chrome, TOPLEFT, 5, rollY - 10)
    chrome.rollFill:SetAnchor(TOPRIGHT, chrome, TOPRIGHT, -5, rollY - 10)
    chrome.rollFill:SetCenterColor(0.10, 0.065, 0.018, rollAmount * 0.18)

    self:ApplyPromotionalTextStyle(tracker, rollAmount)
end

function QuestTracker:BuildPromotionalSignature(tracker)
    if not tracker then
        return ""
    end

    local parts =
    {
        tracker.headerLabel and tracker.headerLabel.GetText and tracker.headerLabel:GetText() or "",
        tracker.subLabel and tracker.subLabel.GetText and tracker.subLabel:GetText() or "",
        tracker.progressLabel and tracker.progressLabel.GetText and tracker.progressLabel:GetText() or "",
    }
    return table.concat(parts, "\031")
end

function QuestTracker:PlayPromotionalUpdateRoll(tracker)
    local chrome = self.promotionalChrome
    if not chrome or chrome:IsHidden() then
        return
    end

    local nowMS = GetFrameTimeMilliseconds()
    if self.lastPromotionalRollMS and nowMS - self.lastPromotionalRollMS < ROLL_COOLDOWN_MS then
        return
    end
    self.lastPromotionalRollMS = nowMS
    self.promotionalRollToken = (self.promotionalRollToken or 0) + 1
    local rollToken = self.promotionalRollToken

    local steps =
    {
        { 0.00, 0.00 },
        { 1.00, 0.18 },
        { 0.72, 0.38 },
        { 0.42, 0.62 },
        { 0.18, 0.84 },
        { 0.00, 1.00 },
    }

    for stepIndex, step in ipairs(steps) do
        zo_callLater(function()
            if self.promotionalRollToken == rollToken then
                self:ApplyPromotionalRollVisuals(tracker, step[1], step[2])
            end
        end, (stepIndex - 1) * ROLL_STEP_MS)
    end
end

function QuestTracker:RestorePromotionalStockStyle(tracker)
    if not tracker or self.restoringPromotionalStockStyle then
        return
    end

    self.promotionalRollToken = (self.promotionalRollToken or 0) + 1
    SafeSetHidden(tracker.nirnsteelIconPlate, true)
    self.restoringPromotionalStockStyle = true
    if tracker.ApplyPlatformStyle and tracker.currentStyle then
        tracker:ApplyPlatformStyle(tracker.currentStyle)
    end
    self.restoringPromotionalStockStyle = nil
end

function QuestTracker:ApplyPromotionalTracker(tracker)
    tracker = tracker or GetPromotionalTracker()
    if not tracker then
        return
    end

    local enabled = IsModuleEnabled()
    self:ApplyPromotionalChrome(tracker)
    if enabled then
        self.wasPromotionalEnabled = true
        self:ApplyPromotionalTextStyle(tracker)
        local signature = self:BuildPromotionalSignature(tracker)
        if signature ~= "" and signature ~= self.lastPromotionalSignature then
            self.lastPromotionalSignature = signature
            self:PlayPromotionalUpdateRoll(tracker)
        end
    elseif self.wasPromotionalEnabled ~= false then
        self.wasPromotionalEnabled = false
        self.lastPromotionalSignature = nil
        self:RestorePromotionalStockStyle(tracker)
    end
end

function QuestTracker:QueueApply(tracker)
    self.pendingTracker = tracker or GetTracker()
    if self.applyQueued then
        return
    end

    self.applyQueued = true
    zo_callLater(function()
        self.applyQueued = nil
        self:Apply(self.pendingTracker)
        self.pendingTracker = nil
    end, APPLY_DELAY_MS)
end

function QuestTracker:QueuePromotionalApply(tracker)
    self.pendingPromotionalTracker = tracker or GetPromotionalTracker()
    if self.promotionalApplyQueued then
        return
    end

    self.promotionalApplyQueued = true
    zo_callLater(function()
        self.promotionalApplyQueued = nil
        self:ApplyPromotionalTracker(self.pendingPromotionalTracker)
        self.pendingPromotionalTracker = nil
    end, APPLY_DELAY_MS)
end

function QuestTracker:InstallHooks()
    if not SecurePostHook then
        return
    end

    local function QueueForTracker(tracker)
        QuestTracker:QueueApply(tracker)
    end

    if not self.trackerHooksInstalled and ZO_Tracker then
        SecurePostHook(ZO_Tracker, "ApplyPlatformStyle", QueueForTracker)
        SecurePostHook(ZO_Tracker, "UpdateTreeView", QueueForTracker)
        SecurePostHook(ZO_Tracker, "RebuildConditions", QueueForTracker)
        SecurePostHook(ZO_Tracker, "BeginTracking", QueueForTracker)
        SecurePostHook(ZO_Tracker, "StopTracking", QueueForTracker)
        SecurePostHook(ZO_Tracker, "ClearTracker", QueueForTracker)
        SecurePostHook(ZO_Tracker, "InitializeQuestHeader", QueueForTracker)
        SecurePostHook(ZO_Tracker, "InitializeQuestCondition", QueueForTracker)
        SecurePostHook(ZO_Tracker, "DoHeaderNameHighlight", function(tracker, label, state)
            if IsModuleEnabled() and state == QUEST_TRACKER_MOUSE_EXIT_STATE then
                StyleHeader(label)
            end
        end)
        self.trackerHooksInstalled = true
    end

    if not self.promotionalHooksInstalled and ZO_PromotionalEventTracker then
        SecurePostHook(ZO_PromotionalEventTracker, "ApplyPlatformStyle", function(tracker)
            if not QuestTracker.restoringPromotionalStockStyle then
                QuestTracker:QueuePromotionalApply(tracker)
            end
        end)
        SecurePostHook(ZO_PromotionalEventTracker, "RefreshAnchors", function(tracker)
            QuestTracker:QueuePromotionalApply(tracker)
        end)
        SecurePostHook(ZO_PromotionalEventTracker, "Update", function(tracker)
            QuestTracker:QueuePromotionalApply(tracker)
        end)
        self.promotionalHooksInstalled = true
    end
end

function QuestTracker:RegisterCallbacks()
    local tracker = GetTracker()
    if self.callbacksRegistered or not tracker or not tracker.RegisterCallback then
        return
    end

    local function Queue()
        self:QueueApply(tracker)
    end

    tracker:RegisterCallback("QuestTrackerInitialUpdate", Queue)
    tracker:RegisterCallback("QuestTrackerTrackingStateChanged", Queue)
    tracker:RegisterCallback("QuestTrackerAssistStateChanged", Queue)
    tracker:RegisterCallback("QuestTrackerFragmentStateChange", Queue)

    self.callbacksRegistered = true
end

function QuestTracker:RegisterEvents()
    if self.eventsRegistered then
        return
    end

    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_PLAYER_ACTIVATED, function()
        self:InstallHooks()
        self:RegisterCallbacks()
        self:QueueApply()
    end)
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE .. "_Gamepad", EVENT_GAMEPAD_PREFERRED_MODE_CHANGED, function()
        self:QueueApply()
        self:QueuePromotionalApply()
    end)
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE .. "_TimedActivity", EVENT_TIMED_ACTIVITY_TRACKING_UPDATED, function()
        self:QueuePromotionalApply()
    end)
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE .. "_PromotionalEvent", EVENT_PROMOTIONAL_EVENTS_ACTIVITY_TRACKING_UPDATED, function()
        self:QueuePromotionalApply()
    end)

    self.eventsRegistered = true
end

function QuestTracker:RefreshSettings()
    self:RegisterEvents()
    self:InstallHooks()
    self:RegisterCallbacks()
    self:QueueApply()
    self:QueuePromotionalApply()
end

local function OnAddOnLoaded(_, addonName)
    if addonName ~= ADDON_NAME then
        return
    end

    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE .. "_Loaded", EVENT_ADD_ON_LOADED)
    QuestTracker:RefreshSettings()
    zo_callLater(function() QuestTracker:RefreshSettings() end, 1000)
end

EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE .. "_Loaded", EVENT_ADD_ON_LOADED, OnAddOnLoaded)
