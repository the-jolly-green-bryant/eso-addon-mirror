local ADDON_NAME = "InfoPanelLayoutFix"
local APPLY_DELAY_MS = 50
local PLAYER_ACTIVATED_SETTLE_MS = 1250
local WATCHDOG_INTERVAL_MS = 100
local LAYOUT_EPSILON = 0.5
local LEFT_EDGE_TARGET = 0
local MAX_AUTO_TRIM_LEFT = 120
local INFO_FONT = "ZoFontWinT2"
local TEXT_MEASURE_WIDTH = 4096
local PANEL_RIGHT_PADDING = 8
local EXP_TEXT_RIGHT_PADDING = 6
local EXP_ICON_TEXT_GAP = 4
local updateName = ADDON_NAME .. "_Apply"
local settleUpdateName = ADDON_NAME .. "_PlayerActivatedSettle"
local watchdogUpdateName = ADDON_NAME .. "_Watchdog"
local lastDebug = {}
local layoutState = {}

local function GetPanelScale()
    local scale = ZO_PerformanceMeters:GetScale() or 1
    return scale > 0 and scale or 1
end

local function MeasureRenderedTextWidth(control, font)
    local text = control:GetText() or ""
    if text == "" then
        return 0
    end

    local width
    if type(ZO_LabelUtils_GetTextDimensions) == "function" then
        width = ZO_LabelUtils_GetTextDimensions(text, font)
    end

    if type(width) ~= "number" or width <= 0 then
        local originalWidth = control:GetWidth()
        control:SetWidth(TEXT_MEASURE_WIDTH)
        width = control:GetTextWidth()
        control:SetWidth(originalWidth)
    end

    if type(width) ~= "number" then
        width = control:GetStringWidth(text)
    end
    return width or 0
end

local function SizeExperienceMeter()
    local control = UI_InfoPanel_ExpPS
    if not control or control:IsHidden() then
        return 0
    end

    local icon = UI_InfoPanel_ExpPS_Icon
    local label = UI_InfoPanel_ExpPS_Text
    if not label then
        return control:GetWidth()
    end

    local iconWidth = icon and icon:GetWidth() or 0
    local labelWidth = math.ceil(MeasureRenderedTextWidth(label, INFO_FONT)) + EXP_TEXT_RIGHT_PADDING
    label:SetWidth(labelWidth)

    local controlWidth = math.ceil(iconWidth) + EXP_ICON_TEXT_GAP + labelWidth
    control:SetWidth(controlWidth)
    return controlWidth
end

local function GetPerformanceLayout(leadingOffset)
    leadingOffset = leadingOffset or 0
    local framerateOn = GetSetting_Bool(SETTING_TYPE_UI, UI_SETTING_SHOW_FRAMERATE)
    local latencyOn = GetSetting_Bool(SETTING_TYPE_UI, UI_SETTING_SHOW_LATENCY)
    local lastControl

    ZO_PerformanceMetersFramerateMeter:ClearAnchors()
    ZO_PerformanceMetersFramerateMeter:SetAnchor(LEFT, ZO_PerformanceMeters, LEFT, 10 + leadingOffset, 0)
    ZO_PerformanceMetersLatencyMeter:ClearAnchors()

    if framerateOn then
        lastControl = ZO_PerformanceMetersFramerateMeter
    end

    if latencyOn then
        if lastControl then
            ZO_PerformanceMetersLatencyMeter:SetAnchor(LEFT, lastControl, RIGHT, -3, 0)
        else
            ZO_PerformanceMetersLatencyMeter:SetAnchor(LEFT, ZO_PerformanceMeters, LEFT, 20 + leadingOffset, 0)
        end
        lastControl = ZO_PerformanceMetersLatencyMeter
    else
        ZO_PerformanceMetersLatencyMeter:SetAnchor(LEFT, ZO_PerformanceMetersFramerateMeter, RIGHT, -3, 0)
    end

    local baseWidth
    if framerateOn and latencyOn then
        baseWidth = 132
    elseif framerateOn or latencyOn then
        baseWidth = 80
    else
        baseWidth = 25
    end

    return lastControl, baseWidth, framerateOn, latencyOn
end

local function AnchorTimer(timer, lastControl, leadingOffset)
    timer:ClearAnchors()
    if lastControl then
        timer:SetAnchor(LEFT, lastControl, RIGHT, -10, 0)
    else
        timer:SetAnchor(LEFT, ZO_PerformanceMeters, LEFT, 20 + leadingOffset, 0)
    end
end

local function GetCenteredTextLeft(control, label)
    local controlLeft = control:GetLeft()
    if not controlLeft or not label then
        return controlLeft
    end

    local textWidth = label:GetStringWidth(label:GetText() or "")
    local inset = math.max(0, (control:GetWidth() - textWidth) / 2)
    return controlLeft + inset * GetPanelScale()
end

local function GetFirstVisibleLeft(framerateOn, latencyOn, timer, info)
    if framerateOn then
        return GetCenteredTextLeft(
            ZO_PerformanceMetersFramerateMeter,
            ZO_PerformanceMetersFramerateMeterLabel
        )
    end

    if latencyOn then
        local bars = ZO_PerformanceMetersLatencyMeterBars
        return bars and bars:GetLeft() or ZO_PerformanceMetersLatencyMeter:GetLeft()
    end

    if timer:GetWidth() > 0 and (timer:GetText() or "") ~= "" then
        return GetCenteredTextLeft(timer, timer)
    end

    return info:GetLeft()
end

local function FormatNumber(value)
    return value and string.format("%.2f", value) or "nil"
end

local function DumpDebug()
    local framerateOn = GetSetting_Bool(SETTING_TYPE_UI, UI_SETTING_SHOW_FRAMERATE)
    local latencyOn = GetSetting_Bool(SETTING_TYPE_UI, UI_SETTING_SHOW_LATENCY)
    local timer = UI_InfoPanel_Timer
    local info = UI_InfoPanel_Info
    local fpsLabel = ZO_PerformanceMetersFramerateMeterLabel
    local bars = ZO_PerformanceMetersLatencyMeterBars
    local exp = UI_InfoPanel_ExpPS
    local expText = UI_InfoPanel_ExpPS_Text
    local _, point, _, relativePoint, anchorX, anchorY = ZO_PerformanceMeters:GetAnchor(0)
    local firstNow = timer and info and GetFirstVisibleLeft(framerateOn, latencyOn, timer, info)
    local infoRenderedWidth = info and MeasureRenderedTextWidth(info, INFO_FONT)
    local expRenderedWidth = expText and MeasureRenderedTextWidth(expText, INFO_FONT)

    d(string.format(
        "[IPLF] v1.0.1 F=%s L=%s rootLeft=%s rootW=%s scale=%s before=%s offset=%s now=%s",
        tostring(framerateOn),
        tostring(latencyOn),
        FormatNumber(ZO_PerformanceMeters:GetLeft()),
        FormatNumber(ZO_PerformanceMeters:GetWidth()),
        FormatNumber(GetPanelScale()),
        FormatNumber(lastDebug.firstBefore),
        FormatNumber(lastDebug.leadingOffset),
        FormatNumber(firstNow)
    ))
    d(string.format(
        "[IPLF] fpsLeft=%s fpsTextW=%s latencyLeft=%s barsLeft=%s timerLeft=%s infoLeft=%s anchor=%s/%s x=%s y=%s",
        FormatNumber(ZO_PerformanceMetersFramerateMeter:GetLeft()),
        FormatNumber(fpsLabel and fpsLabel:GetStringWidth(fpsLabel:GetText() or "")),
        FormatNumber(ZO_PerformanceMetersLatencyMeter:GetLeft()),
        FormatNumber(bars and bars:GetLeft()),
        FormatNumber(timer and timer:GetLeft()),
        FormatNumber(info and info:GetLeft()),
        tostring(point),
        tostring(relativePoint),
        FormatNumber(anchorX),
        FormatNumber(anchorY)
    ))
    d(string.format(
        "[IPLF] infoW=%s renderedW=%s infoRight=%s expHidden=%s expW=%s expTextW=%s expRenderedW=%s expRight=%s rootRight=%s screenW=%s",
        FormatNumber(info and info:GetWidth()),
        FormatNumber(infoRenderedWidth),
        FormatNumber(info and info:GetRight()),
        tostring(not exp or exp:IsHidden()),
        FormatNumber(exp and exp:GetWidth()),
        FormatNumber(expText and expText:GetWidth()),
        FormatNumber(expRenderedWidth),
        FormatNumber(exp and exp:GetRight()),
        FormatNumber(ZO_PerformanceMeters:GetRight()),
        FormatNumber(GuiRoot and GuiRoot:GetWidth())
    ))
    d(string.format(
        "[IPLF] expectedInfoW=%s expectedRootW=%s repairs=%s reason=%s",
        FormatNumber(layoutState.infoWidth),
        FormatNumber(layoutState.panelWidth),
        tostring(lastDebug.watchdogRepairs or 0),
        tostring(lastDebug.watchdogReason or "none")
    ))
end

local function ApplyFix()
    local info = UI_InfoPanel_Info
    local timer = UI_InfoPanel_Timer
    if not (info and timer and ZO_PerformanceMeters and ZO_PerformanceMetersBg) then
        return
    end

    local lastControl, baseWidth, framerateOn, latencyOn = GetPerformanceLayout(0)
    AnchorTimer(timer, lastControl, 0)

    info:SetWrapMode(TEXT_WRAP_MODE_TRUNCATE)
    info:SetMaxLineCount(1)
    local infoWidth = math.ceil(MeasureRenderedTextWidth(info, INFO_FONT)) + PANEL_RIGHT_PADDING
    info:SetWidth(infoWidth)

    local timerWidth = timer:GetWidth()
    local expWidth = SizeExperienceMeter()

    local panelWidth = baseWidth + timerWidth + infoWidth + expWidth
    ZO_PerformanceMeters:SetWidth(panelWidth)
    ZO_PerformanceMetersBg:SetWidth(panelWidth * 1.5)

    local firstVisibleLeft = GetFirstVisibleLeft(framerateOn, latencyOn, timer, info)
    local leadingOffset = 0
    if firstVisibleLeft and firstVisibleLeft > LEFT_EDGE_TARGET and firstVisibleLeft <= MAX_AUTO_TRIM_LEFT then
        leadingOffset = (LEFT_EDGE_TARGET - firstVisibleLeft) / GetPanelScale()
        lastControl = GetPerformanceLayout(leadingOffset)
        AnchorTimer(timer, lastControl, leadingOffset)
    end

    lastDebug.firstBefore = firstVisibleLeft
    lastDebug.leadingOffset = leadingOffset

    local firstVisibleAfter = GetFirstVisibleLeft(framerateOn, latencyOn, timer, info)
    local rootLeft = ZO_PerformanceMeters:GetLeft()
    layoutState.infoText = info:GetText() or ""
    layoutState.infoWidth = infoWidth
    layoutState.panelWidth = panelWidth
    layoutState.expHidden = not UI_InfoPanel_ExpPS or UI_InfoPanel_ExpPS:IsHidden()
    layoutState.expText = UI_InfoPanel_ExpPS_Text and UI_InfoPanel_ExpPS_Text:GetText() or ""
    layoutState.expWidth = expWidth
    layoutState.leadingInset = firstVisibleAfter and rootLeft
        and (firstVisibleAfter - rootLeft) / GetPanelScale()
        or nil

    PERFORMANCE_METER_FRAGMENT:SetHiddenForReason("AnyOn", false, 0, 0)
end

local function LayoutNeedsRepair()
    local info = UI_InfoPanel_Info
    local timer = UI_InfoPanel_Timer
    if not (info and timer and ZO_PerformanceMeters) then
        return false
    end

    if not layoutState.infoWidth then
        return true, "uninitialized"
    end
    if (info:GetText() or "") ~= layoutState.infoText then
        return true, "info-text"
    end
    if math.abs(info:GetWidth() - layoutState.infoWidth) > LAYOUT_EPSILON then
        return true, "info-width"
    end
    if math.abs(ZO_PerformanceMeters:GetWidth() - layoutState.panelWidth) > LAYOUT_EPSILON then
        return true, "panel-width"
    end

    local exp = UI_InfoPanel_ExpPS
    local expHidden = not exp or exp:IsHidden()
    if expHidden ~= layoutState.expHidden then
        return true, "exp-visibility"
    end
    if not expHidden then
        local expText = UI_InfoPanel_ExpPS_Text
        if (expText and expText:GetText() or "") ~= layoutState.expText then
            return true, "exp-text"
        end
        if math.abs(exp:GetWidth() - layoutState.expWidth) > LAYOUT_EPSILON then
            return true, "exp-width"
        end
    end

    local framerateOn = GetSetting_Bool(SETTING_TYPE_UI, UI_SETTING_SHOW_FRAMERATE)
    local latencyOn = GetSetting_Bool(SETTING_TYPE_UI, UI_SETTING_SHOW_LATENCY)
    local firstVisibleLeft = GetFirstVisibleLeft(framerateOn, latencyOn, timer, info)
    local rootLeft = ZO_PerformanceMeters:GetLeft()
    if layoutState.leadingInset and firstVisibleLeft and rootLeft then
        local leadingInset = (firstVisibleLeft - rootLeft) / GetPanelScale()
        if math.abs(leadingInset - layoutState.leadingInset) > LAYOUT_EPSILON then
            return true, "leading-inset"
        end
    end

    return false
end

local function WatchLayout()
    local needsRepair, reason = LayoutNeedsRepair()
    if not needsRepair then
        return
    end

    lastDebug.watchdogReason = reason
    lastDebug.watchdogRepairs = (lastDebug.watchdogRepairs or 0) + 1
    ApplyFix()
end

local function QueueApply()
    EVENT_MANAGER:UnregisterForUpdate(updateName)
    EVENT_MANAGER:RegisterForUpdate(updateName, APPLY_DELAY_MS, function()
        EVENT_MANAGER:UnregisterForUpdate(updateName)
        ApplyFix()
    end)
end

local function OnPlayerActivated()
    QueueApply()

    -- InfoPanel reanchors the meters 1000 ms after this event.
    EVENT_MANAGER:UnregisterForUpdate(settleUpdateName)
    EVENT_MANAGER:RegisterForUpdate(settleUpdateName, PLAYER_ACTIVATED_SETTLE_MS, function()
        EVENT_MANAGER:UnregisterForUpdate(settleUpdateName)
        ApplyFix()
    end)
end

local function OnInterfaceSettingChanged(_, settingType, settingId)
    if settingType ~= SETTING_TYPE_UI then
        return
    end
    if settingId == UI_SETTING_SHOW_FRAMERATE or settingId == UI_SETTING_SHOW_LATENCY then
        QueueApply()
    end
end

local function OnAddOnLoaded(_, addonName)
    if addonName ~= ADDON_NAME then
        return
    end

    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
    if not (InfoPanel and type(InfoPanel.Update) == "function") then
        return
    end

    ZO_PostHook(InfoPanel, "Update", QueueApply)
    SLASH_COMMANDS["/iplfdebug"] = DumpDebug
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_INTERFACE_SETTING_CHANGED, OnInterfaceSettingChanged)
    EVENT_MANAGER:AddFilterForEvent(ADDON_NAME, EVENT_INTERFACE_SETTING_CHANGED, REGISTER_FILTER_SETTING_SYSTEM_TYPE, SETTING_TYPE_UI)
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_EXPERIENCE_UPDATE, QueueApply)
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ALLIANCE_POINT_UPDATE, QueueApply)
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_TELVAR_STONE_UPDATE, QueueApply)
    EVENT_MANAGER:RegisterForUpdate(watchdogUpdateName, WATCHDOG_INTERVAL_MS, WatchLayout)
    QueueApply()
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
