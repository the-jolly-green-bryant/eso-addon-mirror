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
local SetFrameVisibilityImmediate = Shared.SetFrameVisibilityImmediate
local SetFrameCombatVisibility = Shared.SetFrameCombatVisibility
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
    COMPANION.nameRow = WINDOW_MANAGER:CreateControl(nil, COMPANION.root, CT_CONTROL)
    COMPANION.nameLabel = CreateCompanionNameLabel(COMPANION.nameRow, GetCompanionLabelFont())
    COMPANION.rapportLabel = CreateCompanionNameLabel(COMPANION.nameRow, GetCompanionLabelFont())
    COMPANION.rapportLabel:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)

    COMPANION.xpTrack = WINDOW_MANAGER:CreateControl(nil, COMPANION.root, CT_BACKDROP)
    COMPANION.xpTrack:SetCenterColor(0, 0, 0, 0)
    COMPANION.xpTrack:SetEdgeColor(0, 0, 0, 0)
    COMPANION.xpTrack:SetEdgeTexture(C.TEXTURE_WHITE, 1, 1, 1)
    COMPANION.xpTrack:SetDrawLevel(C.DRAW_LEVEL)

    COMPANION.xpBar = WINDOW_MANAGER:CreateControl(nil, COMPANION.xpTrack, CT_STATUSBAR)
    COMPANION.xpBar:SetAnchorFill(COMPANION.xpTrack)
    COMPANION.xpBar:SetTexture(C.TEXTURE_FILL)
    COMPANION.xpBar:SetMinMax(0, 1)
    COMPANION.xpBar:SetValue(0)
    COMPANION.xpBar:SetDrawLevel(C.DRAW_LEVEL + 1)
    if GetInterfaceColor and INTERFACE_COLOR_TYPE_PROGRESSION and PROGRESSION_COLOR_XP_START then
        COMPANION.xpBar:SetColor(GetInterfaceColor(INTERFACE_COLOR_TYPE_PROGRESSION, PROGRESSION_COLOR_XP_START))
    else
        COMPANION.xpBar:SetColor(0.20, 0.72, 0.82, 1)
    end

    return true
end

function COMPANION.HideFrame()
    if COMPANION.root then
        SetFrameVisibilityImmediate(COMPANION.root, false)
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

function COMPANION.GetRapportLevelName()
    local hasActiveCompanion = HasActiveCompanion and HasActiveCompanion() == true
    if (hasActiveCompanion or COMPANION.DoesExist()) and GetActiveCompanionRapportLevel and GetString then
        local rapportLevel = GetActiveCompanionRapportLevel()
        if rapportLevel ~= nil then
            return GetString("SI_COMPANIONRAPPORTLEVEL", rapportLevel)
        end
    end

    if COMPANION.IsPreviewVisible() and GetString and RAPPORT_LEVEL_SLIGHT_AFFINITY then
        return GetString("SI_COMPANIONRAPPORTLEVEL", RAPPORT_LEVEL_SLIGHT_AFFINITY)
    end

    return ""
end

function COMPANION.GetRapportDisplayText(settings)
    local rapportLevelName = COMPANION.GetRapportLevelName()
    if rapportLevelName == "" then
        return ""
    end

    local hasActiveCompanion = HasActiveCompanion and HasActiveCompanion() == true
    local rapportPercent
    if (hasActiveCompanion or COMPANION.DoesExist()) and GetActiveCompanionRapport and GetMinimumRapport and GetMaximumRapport then
        local currentRapport = tonumber(GetActiveCompanionRapport()) or 0
        local minimumRapport = tonumber(GetMinimumRapport()) or 0
        local maximumRapport = tonumber(GetMaximumRapport()) or 0
        local rapportRange = maximumRapport - minimumRapport
        if rapportRange > 0 then
            rapportPercent = Round(Clamp((currentRapport - minimumRapport) / rapportRange, 0, 1) * 100)
        end
    elseif COMPANION.IsPreviewVisible() then
        rapportPercent = 65
    end

    if rapportPercent ~= nil then
        rapportLevelName = rapportLevelName .. " " .. tostring(rapportPercent) .. "%"
    end

    if zo_iconFormat then
        local iconSize = math.max(16, math.min(COMPANION.LABEL_HEIGHT, settings.fontSize or COMPANION.LABEL_HEIGHT))
        rapportLevelName = zo_iconFormat(COMPANION.RAPPORT_ICON, iconSize, iconSize) .. " " .. rapportLevelName
    end

    return rapportLevelName
end

function COMPANION.GetXpProgress()
    local hasActiveCompanion = HasActiveCompanion and HasActiveCompanion() == true
    if (hasActiveCompanion or COMPANION.DoesExist()) and GetActiveCompanionLevelInfo and GetNumExperiencePointsInCompanionLevel then
        local level, currentExperience = GetActiveCompanionLevelInfo()
        local maximumExperience = GetNumExperiencePointsInCompanionLevel((tonumber(level) or 0) + 1) or 0
        if maximumExperience <= 0 then
            return 1, 1
        end

        return tonumber(currentExperience) or 0, maximumExperience
    end

    if COMPANION.IsPreviewVisible() then
        return 65, 100
    end

    return 0, 1
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
    local showRapport = showName and settings.showRapport == true
    local showXpProgress = settings.showXpProgress == true
    local xpBarSpace = showXpProgress and (COMPANION.XP_BAR_HEIGHT + COMPANION.XP_BAR_GAP) or 0
    local valueLabelWidth = settings.orientation == COMPANION.VERTICAL and math.max(width * 3, 72) or width
    local nameWidth = showName and math.max(valueLabelWidth, 120) or 0
    local horizontalNameSpace = settings.orientation ~= COMPANION.VERTICAL and showName and (COMPANION.LABEL_HEIGHT + COMPANION.LABEL_GAP) or 0
    local verticalValueSpace = settings.orientation == COMPANION.VERTICAL and (COMPANION.LABEL_HEIGHT + COMPANION.LABEL_GAP) or 0
    local verticalNameSpace = settings.orientation == COMPANION.VERTICAL and showName and (COMPANION.LABEL_HEIGHT + COMPANION.LABEL_GAP) or 0
    local rootWidth = settings.orientation == COMPANION.VERTICAL and math.max(width, valueLabelWidth, nameWidth) or math.max(width, nameWidth)
    local rootHeight = settings.orientation == COMPANION.VERTICAL and height + verticalValueSpace * 2 + verticalNameSpace + xpBarSpace or height + horizontalNameSpace + xpBarSpace
    local barX = zo_floor((rootWidth - width) * 0.5)
    local barY = 0

    if settings.orientation == COMPANION.VERTICAL then
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

    COMPANION.xpTrack:ClearAnchors()
    COMPANION.xpTrack:SetDimensions(width, COMPANION.XP_BAR_HEIGHT)
    COMPANION.xpTrack:SetAnchor(TOPLEFT, COMPANION.widget, BOTTOMLEFT, 0, COMPANION.XP_BAR_GAP)
    COMPANION.xpTrack:SetHidden(not showXpProgress or COMPANION.resourceValue.hidden == true)
    local lowerAnchorControl = showXpProgress and COMPANION.xpTrack or COMPANION.widget

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
            COMPANION.widget.rightLabel:SetAnchor(TOP, lowerAnchorControl, BOTTOM, 0, COMPANION.LABEL_GAP)
        else
            COMPANION.widget.leftLabel:SetVerticalAlignment(TEXT_ALIGN_TOP)
            COMPANION.widget.rightLabel:SetVerticalAlignment(TEXT_ALIGN_BOTTOM)
            COMPANION.widget.leftLabel:SetAnchor(TOP, lowerAnchorControl, BOTTOM, 0, COMPANION.LABEL_GAP)
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

    COMPANION.nameRow:ClearAnchors()
    COMPANION.nameRow:SetDimensions(nameWidth, COMPANION.LABEL_HEIGHT)
    COMPANION.nameLabel:SetFont(font)
    COMPANION.rapportLabel:SetFont(font)
    if settings.orientation == COMPANION.VERTICAL then
        if settings.reverse == true then
            COMPANION.nameRow:SetAnchor(BOTTOM, COMPANION.widget, TOP, 0, -(COMPANION.LABEL_HEIGHT + COMPANION.LABEL_GAP * 2))
        else
            COMPANION.nameRow:SetAnchor(TOP, lowerAnchorControl, BOTTOM, 0, COMPANION.LABEL_HEIGHT + COMPANION.LABEL_GAP * 2)
        end
    else
        COMPANION.nameRow:SetAnchor(BOTTOM, COMPANION.widget, TOP, 0, -COMPANION.LABEL_GAP)
    end

    local rapportText = showRapport and COMPANION.GetRapportDisplayText(settings) or ""
    COMPANION.rapportLabel:SetDimensions(nameWidth, COMPANION.LABEL_HEIGHT)
    COMPANION.rapportLabel:SetText(rapportText)
    local measuredRapportWidth = showRapport and COMPANION.rapportLabel.GetTextWidth and math.ceil(COMPANION.rapportLabel:GetTextWidth()) or 0
    local rapportWidth = math.min(measuredRapportWidth, math.max(nameWidth - 40, 0))
    local nameGap = rapportWidth > 0 and COMPANION.LABEL_GAP or 0
    COMPANION.nameLabel:ClearAnchors()
    COMPANION.nameLabel:SetDimensions(math.max(nameWidth - rapportWidth - nameGap, 0), COMPANION.LABEL_HEIGHT)
    COMPANION.nameLabel:SetAnchor(TOPLEFT, COMPANION.nameRow, TOPLEFT, 0, 0)
    COMPANION.nameLabel:SetHorizontalAlignment(settings.orientation == COMPANION.VERTICAL and TEXT_ALIGN_CENTER or (settings.reverse == true and TEXT_ALIGN_RIGHT or TEXT_ALIGN_LEFT))
    COMPANION.rapportLabel:ClearAnchors()
    COMPANION.rapportLabel:SetDimensions(rapportWidth, COMPANION.LABEL_HEIGHT)
    COMPANION.rapportLabel:SetAnchor(TOPRIGHT, COMPANION.nameRow, TOPRIGHT, 0, 0)
    COMPANION.rapportLabel:SetHidden(rapportWidth <= 0)
    COMPANION.nameRow:SetHidden(not showName)
    if showName then
        COMPANION.nameLabel:SetText(COMPANION.GetName())
    end

    ApplyRootPosition(COMPANION.root, settings)
end

function COMPANION.ApplyXpProgress()
    local settings = GetCompanionSettings()
    local visible = settings.showXpProgress == true and COMPANION.resourceValue.hidden ~= true
    COMPANION.xpTrack:SetHidden(not visible)
    if not visible then
        return
    end

    local currentExperience, maximumExperience = COMPANION.GetXpProgress()
    maximumExperience = math.max(tonumber(maximumExperience) or 0, 1)
    local color = settings.xpColor
    COMPANION.xpBar:SetColor(color.r, color.g, color.b, color.a or 1)
    COMPANION.xpBar:SetMinMax(0, maximumExperience)
    COMPANION.xpBar:SetValue(Clamp(tonumber(currentExperience) or 0, 0, maximumExperience))
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
    local shouldShowFrame = (settings.showNqolCompanionFrame == true or previewVisible)
        and COMPANION.ShouldShowForCurrentScene()
        and (COMPANION.DoesExist() or previewVisible)
    local combatOnly = not previewVisible and settings.showOnlyInCombat == true

    if not shouldShowFrame then
        COMPANION.HideFrame()
        return
    end

    if combatOnly and not (IsUnitInCombat and IsUnitInCombat("player") == true) then
        SetFrameCombatVisibility(COMPANION.root, false)
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
    COMPANION.ApplyXpProgress()
    if previewVisible then
        Shared.SetSettingsPreviewDrawOrder(COMPANION.root)
    end
    if combatOnly then
        SetFrameCombatVisibility(COMPANION.root, true)
    else
        SetFrameVisibilityImmediate(COMPANION.root, true)
    end
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
