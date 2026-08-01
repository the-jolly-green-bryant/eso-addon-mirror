NQOL = NQOL or {}
NQOL.Features = NQOL.Features or {}

local PlayerBars = NQOL.Features.PlayerBars
local Shared = PlayerBars.Shared
local C = PlayerBars.Constants
local COMPANION = PlayerBars.Companion
local Shadow = PlayerBars.Shadow
local defaults = Shared.defaults
local Clamp = NQOL.Util.Clamp
local Round = NQOL.Util.Round
local GetCompanionSettings = Shared.GetCompanionSettings
local IsGameplaySceneShowing = Shared.IsGameplaySceneShowing
local CreateRootControl = Shared.CreateRootControl
local CreateClassicResourceWidget = Shared.CreateClassicResourceWidget
local CreateCompanionNameLabel = Shared.CreateCompanionNameLabel
local GetCompanionLabelFont = Shared.GetCompanionLabelFont
local ApplyRootPosition = Shared.ApplyRootPosition
local FormatNumber = Shared.FormatNumber
local FormatCompactNumber = Shared.FormatCompactNumber
local FormatCurrentValue = Shared.FormatCurrentValue
local runtimeActive = false

function COMPANION.ShouldShowForCurrentScene()
    if IsGameplaySceneShowing() then
        return true
    end

    return COMPANION.settingsPanelVisible and GetCompanionSettings().showInSettings == true
end

function COMPANION.IsPreviewVisible()
    return COMPANION.settingsPanelVisible and GetCompanionSettings().showInSettings == true
end

function COMPANION.IsRuntimeActive()
    return runtimeActive
end

function COMPANION.RefreshRuntimeState()
    runtimeActive = GetCompanionSettings().showNqolCompanionFrame == true or COMPANION.IsPreviewVisible()
    if PlayerBars.RefreshEventRegistrations then
        PlayerBars.RefreshEventRegistrations()
    end
    return runtimeActive
end

function COMPANION.DoesExist()
    return DoesUnitExist and DoesUnitExist("companion") == true
end
function COMPANION.EnsureControls()
    if COMPANION.root or not WINDOW_MANAGER or not GuiRoot then
        return COMPANION.root ~= nil
    end

    COMPANION.root = CreateRootControl(COMPANION.ROOT_CONTROL_NAME)
    COMPANION.widget = CreateClassicResourceWidget(COMPANION.root, C.RESOURCE_HEALTH)
    COMPANION.nameLabel = CreateCompanionNameLabel(COMPANION.root, GetCompanionLabelFont())

    return true
end

function COMPANION.HideFrame()
    if COMPANION.root then
        COMPANION.root:SetHidden(true)
    end
end

function COMPANION.UpdateResourceValue(force)
    if not GetUnitPower then
        return false
    end

    local exists = COMPANION.DoesExist()
    local current, maximum, effectiveMaximum
    if exists then
        current, maximum, effectiveMaximum = GetUnitPower("companion", C.RESOURCE_HEALTH)
    else
        current = COMPANION.DEFAULT_WIDTH
        maximum = COMPANION.DEFAULT_WIDTH
        effectiveMaximum = COMPANION.DEFAULT_WIDTH
    end

    current = tonumber(current) or 0
    maximum = tonumber(maximum) or 0
    effectiveMaximum = tonumber(effectiveMaximum) or maximum

    local hidden = not exists and not COMPANION.IsPreviewVisible()
    if not force
        and COMPANION.resourceValue.current == current
        and COMPANION.resourceValue.maximum == maximum
        and COMPANION.resourceValue.effectiveMaximum == effectiveMaximum
        and COMPANION.resourceValue.hidden == hidden
    then
        return false
    end

    COMPANION.resourceValue.current = current
    COMPANION.resourceValue.maximum = maximum
    COMPANION.resourceValue.effectiveMaximum = effectiveMaximum
    COMPANION.resourceValue.hidden = hidden
    return true
end

function COMPANION.GetName()
    if COMPANION.DoesExist() and GetUnitName then
        local name = GetUnitName("companion")
        if name and name ~= "" then
            if zo_strformat and SI_COMPANION_NAME_FORMATTER then
                return zo_strformat(SI_COMPANION_NAME_FORMATTER, name)
            end

            return name
        end
    end

    return NQOL.L("features.companion_bar.companion")
end

function COMPANION.LayoutInnerShadow(width, height, settings)
    Shadow.Layout(COMPANION.widget, width, height, settings.borderSize, settings.shadow, settings.shadowIntensity)
end

function COMPANION.LayoutFrame()
    local settings = GetCompanionSettings()
    local width = Clamp(settings.width, COMPANION.WIDTH_MIN, COMPANION.WIDTH_MAX)
    local height = Clamp(settings.height, COMPANION.HEIGHT_MIN, COMPANION.HEIGHT_MAX)
    local font = GetCompanionLabelFont()
    if settings.orientation == COMPANION.VERTICAL and width > height then
        width, height = height, width
    end

    local showName = settings.showName == true
    local valueLabelWidth = settings.orientation == COMPANION.VERTICAL and math.max(width * 3, 72) or width
    local nameWidth = showName and math.max(valueLabelWidth, 120) or 0
    local horizontalNameSpace = settings.orientation ~= COMPANION.VERTICAL and showName and (COMPANION.LABEL_HEIGHT + COMPANION.LABEL_GAP) or 0
    local verticalValueSpace = settings.orientation == COMPANION.VERTICAL and (COMPANION.LABEL_HEIGHT + COMPANION.LABEL_GAP) or 0
    local verticalNameSpace = settings.orientation == COMPANION.VERTICAL and showName and (COMPANION.LABEL_HEIGHT + COMPANION.LABEL_GAP) or 0
    local rootWidth = settings.orientation == COMPANION.VERTICAL and math.max(width, valueLabelWidth, nameWidth) or math.max(width, nameWidth)
    local rootHeight = settings.orientation == COMPANION.VERTICAL and height + verticalValueSpace * 2 + verticalNameSpace or height + horizontalNameSpace
    local barX = 0
    local barY = 0

    if settings.orientation == COMPANION.VERTICAL then
        barX = zo_floor((rootWidth - width) * 0.5)
        barY = verticalValueSpace
        if settings.reverse == true then
            barY = barY + verticalNameSpace
        end
    elseif showName then
        barY = horizontalNameSpace
    end

    COMPANION.root:SetDimensions(rootWidth, rootHeight)

    COMPANION.widget:ClearAnchors()
    COMPANION.widget:SetDimensions(width, height)
    COMPANION.widget:SetAnchor(TOPLEFT, COMPANION.root, TOPLEFT, barX, barY)
    COMPANION.widget.leftLabel:SetFont(font)
    COMPANION.widget.rightLabel:SetFont(font)

    COMPANION.LayoutInnerShadow(width, height, settings)

    COMPANION.widget.leftLabel:ClearAnchors()
    COMPANION.widget.rightLabel:ClearAnchors()
    COMPANION.widget.leftLabel:SetHidden(false)
    COMPANION.widget.rightLabel:SetHidden(false)
    if settings.orientation == COMPANION.VERTICAL then
        COMPANION.widget.leftLabel:SetDimensions(valueLabelWidth, COMPANION.LABEL_HEIGHT)
        COMPANION.widget.rightLabel:SetDimensions(valueLabelWidth, COMPANION.LABEL_HEIGHT)
        COMPANION.widget.leftLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        COMPANION.widget.rightLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        if settings.reverse == true then
            COMPANION.widget.leftLabel:SetVerticalAlignment(TEXT_ALIGN_BOTTOM)
            COMPANION.widget.rightLabel:SetVerticalAlignment(TEXT_ALIGN_TOP)
            COMPANION.widget.leftLabel:SetAnchor(BOTTOM, COMPANION.widget, TOP, 0, -COMPANION.LABEL_GAP)
            COMPANION.widget.rightLabel:SetAnchor(TOP, COMPANION.widget, BOTTOM, 0, COMPANION.LABEL_GAP)
        else
            COMPANION.widget.leftLabel:SetVerticalAlignment(TEXT_ALIGN_TOP)
            COMPANION.widget.rightLabel:SetVerticalAlignment(TEXT_ALIGN_BOTTOM)
            COMPANION.widget.leftLabel:SetAnchor(TOP, COMPANION.widget, BOTTOM, 0, COMPANION.LABEL_GAP)
            COMPANION.widget.rightLabel:SetAnchor(BOTTOM, COMPANION.widget, TOP, 0, -COMPANION.LABEL_GAP)
        end
    else
        COMPANION.widget.leftLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        COMPANION.widget.rightLabel:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
        COMPANION.widget.leftLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
        COMPANION.widget.rightLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
        COMPANION.widget.leftLabel:SetAnchor(TOPLEFT, COMPANION.widget, TOPLEFT, C.CLASSIC_LABEL_PADDING, 0)
        COMPANION.widget.leftLabel:SetAnchor(BOTTOMRIGHT, COMPANION.widget, BOTTOMRIGHT, -C.CLASSIC_LABEL_PADDING, 0)
        COMPANION.widget.rightLabel:SetAnchor(TOPLEFT, COMPANION.widget, TOPLEFT, C.CLASSIC_LABEL_PADDING, 0)
        COMPANION.widget.rightLabel:SetAnchor(BOTTOMRIGHT, COMPANION.widget, BOTTOMRIGHT, -C.CLASSIC_LABEL_PADDING, 0)
    end

    COMPANION.nameLabel:ClearAnchors()
    COMPANION.nameLabel:SetFont(font)
    if settings.orientation == COMPANION.VERTICAL then
        COMPANION.nameLabel:SetDimensions(nameWidth, COMPANION.LABEL_HEIGHT)
        COMPANION.nameLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        if settings.reverse == true then
            COMPANION.nameLabel:SetAnchor(BOTTOM, COMPANION.widget, TOP, 0, -(COMPANION.LABEL_HEIGHT + COMPANION.LABEL_GAP * 2))
        else
            COMPANION.nameLabel:SetAnchor(TOP, COMPANION.widget, BOTTOM, 0, COMPANION.LABEL_HEIGHT + COMPANION.LABEL_GAP * 2)
        end
    elseif settings.reverse == true then
        COMPANION.nameLabel:SetDimensions(width, COMPANION.LABEL_HEIGHT)
        COMPANION.nameLabel:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
        COMPANION.nameLabel:SetAnchor(BOTTOMRIGHT, COMPANION.widget, TOPRIGHT, 0, -COMPANION.LABEL_GAP)
    else
        COMPANION.nameLabel:SetDimensions(width, COMPANION.LABEL_HEIGHT)
        COMPANION.nameLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        COMPANION.nameLabel:SetAnchor(BOTTOMLEFT, COMPANION.widget, TOPLEFT, 0, -COMPANION.LABEL_GAP)
    end
    COMPANION.nameLabel:SetHidden(not showName)
    if showName then
        COMPANION.nameLabel:SetText(COMPANION.GetName())
    end

    ApplyRootPosition(COMPANION.root, settings)
end

function COMPANION.ApplyResourceValue(smoothUpdate)
    local settings = GetCompanionSettings()
    local widget = COMPANION.widget
    local resourceValue = COMPANION.resourceValue
    if not widget or not resourceValue then
        return
    end

    widget:SetHidden(resourceValue.hidden == true)
    if resourceValue.hidden == true then
        PlayerBars.HideLossFill(widget)
        if PlayerBars.Smooth then
            PlayerBars.Smooth.Reset(widget, C.RESOURCE_HEALTH)
        end
        return
    end

    local rangeMaximum = resourceValue.maximum
    if rangeMaximum < 1 then
        rangeMaximum = 1
    end

    local width = widget:GetWidth() or 0
    local height = widget:GetHeight() or 0
    local borderSize = Clamp(settings.borderSize, C.CLASSIC_BORDER_SIZE_MIN, math.max(C.CLASSIC_BORDER_SIZE_MIN, zo_floor((math.min(width, height) - 1) * 0.5)))
    local fillCurrent = resourceValue.current
    if settings.smoothTransitions == true and PlayerBars.Smooth then
        fillCurrent = PlayerBars.Smooth.GetValue(widget, C.RESOURCE_HEALTH, fillCurrent, COMPANION.ApplySmoothResourceValue, rangeMaximum)
    elseif PlayerBars.Smooth then
        PlayerBars.Smooth.Reset(widget, C.RESOURCE_HEALTH)
    end
    local percent = Clamp(fillCurrent / rangeMaximum, 0, 1)
    local innerWidth = math.max(width - borderSize * 2, 0)
    local innerHeight = math.max(height - borderSize * 2, 0)
    local fillWidth = zo_floor(innerWidth * percent)
    local fillHeight = zo_floor(innerHeight * percent)

    if fillCurrent > 0 and fillWidth < 1 then
        fillWidth = 1
    end

    if fillCurrent > 0 and fillHeight < 1 then
        fillHeight = 1
    end

    PlayerBars.ApplyWidgetBarColor(widget, C.RESOURCE_HEALTH, settings)
    PlayerBars.ApplyLossFill(widget, C.RESOURCE_HEALTH, rangeMaximum, innerWidth, innerHeight, borderSize, settings.reverse == true, settings.orientation == COMPANION.VERTICAL, settings.smoothTransitions == true and settings.transitionShadow == true)

    widget.fill:ClearAnchors()
    if settings.orientation == COMPANION.VERTICAL then
        if settings.reverse == true then
            widget.fill:SetAnchor(TOPLEFT, widget, TOPLEFT, borderSize, borderSize)
        else
            widget.fill:SetAnchor(BOTTOMLEFT, widget, BOTTOMLEFT, borderSize, -borderSize)
        end
        widget.fill:SetDimensions(innerWidth, fillHeight)
    else
        if settings.reverse == true then
            widget.fill:SetAnchor(TOPRIGHT, widget, TOPRIGHT, -borderSize, borderSize)
        else
            widget.fill:SetAnchor(TOPLEFT, widget, TOPLEFT, borderSize, borderSize)
        end
        widget.fill:SetDimensions(fillWidth, innerHeight)
    end

    if not smoothUpdate then
        local useCompactValues = settings.orientation == COMPANION.VERTICAL
        local totalText = useCompactValues and FormatCompactNumber(resourceValue.maximum) or FormatNumber(resourceValue.maximum)
        local currentText = FormatCurrentValue(resourceValue, resourceValue.maximum, settings.currentValue, settings.orientation == COMPANION.VERTICAL)
        if settings.orientation == COMPANION.VERTICAL then
            widget.leftLabel:SetText(totalText)
            widget.rightLabel:SetText(currentText)
        elseif settings.reverse == true then
            widget.leftLabel:SetText(currentText)
            widget.rightLabel:SetText(totalText)
        else
            widget.leftLabel:SetText(totalText)
            widget.rightLabel:SetText(currentText)
        end
    end
end

function COMPANION.ApplySmoothResourceValue()
    COMPANION.ApplyResourceValue(true)
end

function COMPANION.RefreshFrame()
    COMPANION.refreshQueued = false

    local settings = GetCompanionSettings()
    local previewVisible = COMPANION.IsPreviewVisible()
    local shouldShow = (settings.showNqolCompanionFrame == true or previewVisible)
        and COMPANION.ShouldShowForCurrentScene()
        and (previewVisible or settings.showOnlyInCombat ~= true or (IsUnitInCombat and IsUnitInCombat("player") == true))
        and (COMPANION.DoesExist() or previewVisible)

    if not shouldShow then
        COMPANION.HideFrame()
        return
    end

    if not COMPANION.EnsureControls() then
        return
    end

    if not previewVisible then
        Shared.RestoreDrawOrder(COMPANION.root)
    end

    COMPANION.UpdateResourceValue(true)
    COMPANION.LayoutFrame()
    COMPANION.ApplyResourceValue()
    if previewVisible then
        Shared.SetSettingsPreviewDrawOrder(COMPANION.root)
    end
    COMPANION.root:SetHidden(false)
end

function COMPANION.QueueRefresh()
    if not runtimeActive then
        COMPANION.refreshQueued = false
        COMPANION.HideFrame()
        return
    end

    if COMPANION.refreshQueued then
        return
    end

    COMPANION.refreshQueued = true
    if zo_callLater then
        zo_callLater(COMPANION.RefreshFrame, C.APPLY_DELAY_MS)
    else
        COMPANION.RefreshFrame()
    end
end

function COMPANION.OnPowerUpdate(_, unitTag, _, powerType)
    if not runtimeActive or unitTag ~= "companion" or powerType ~= C.RESOURCE_HEALTH then
        return
    end

    if not COMPANION.root or COMPANION.root:IsHidden() then
        COMPANION.QueueRefresh()
        return
    end

    if COMPANION.UpdateResourceValue() then
        COMPANION.ApplyResourceValue()
        COMPANION.LayoutFrame()
    end
end
