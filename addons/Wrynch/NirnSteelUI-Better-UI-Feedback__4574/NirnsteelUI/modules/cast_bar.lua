local ADDON_NAME = "NirnsteelUI"
local EVENT_NAMESPACE = ADDON_NAME .. "_CastBar"

Nirnsteel_UI = Nirnsteel_UI or {}
local Nirnsteel_UI = Nirnsteel_UI
local CastBar = {}
Nirnsteel_UI.CastBar = CastBar

local DEFAULT_SETTINGS =
{
    enabled = true,
    unlocked = false,
    scale = 100,
    width = 400,
    height = 20,
    opacity = 100,
    textMode = "nameAndTime",
    showIcon = true,
    showTicks = true,
    animationIntensity = 85,
}

local DEFAULT_POSITION = { x = 0, y = -180 }
local MIN_WIDTH = 220
local MAX_WIDTH = 620
local MIN_HEIGHT = 18
local MAX_HEIGHT = 48
local MIN_DURATION_MS = 120
local COMPLETE_HOLD_MS = 220
local FADE_OUT_MS = 220
local ICON_PAD = 5
local FRAME_PAD = 4
local BAR_TEXTURE = "EsoUI/Art/Miscellaneous/progressbar_genericFill_tall.dds"
local BAR_GLOSS_TEXTURE = "EsoUI/Art/Miscellaneous/timerBar_genericFill_gloss.dds"
local BAR_LEADING_EDGE_TEXTURE = "EsoUI/Art/Miscellaneous/progressbar_genericFill_leadingEdge_blunt.dds"
local EDGE_FRAME_TEXTURE = "EsoUI/Art/Miscellaneous/Gamepad/edgeframeGamepadBorder_thin.dds"
local SHINE_TEXTURE = BAR_GLOSS_TEXTURE
local FALLBACK_ICON = "EsoUI/Art/Icons/icon_missing.dds"
local CHUNK_PULSE_COUNT = 8
local CHUNK_PULSE_MS = 340

local TEXT_MODE_ALIASES =
{
    ["Name + Time"] = "nameAndTime",
    ["Name Only"] = "nameOnly",
    ["Timer Only"] = "timerOnly",
    Off = "off",
    nameAndTime = "nameAndTime",
    nameOnly = "nameOnly",
    timerOnly = "timerOnly",
    off = "off",
}

local function ClampNumber(value, minValue, maxValue)
    value = tonumber(value) or minValue
    return math.min(math.max(value, minValue), maxValue)
end

local function GetSettings()
    if Nirnsteel_UI.Settings then
        return Nirnsteel_UI.Settings:GetCastBar()
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
    return not Nirnsteel_UI.Settings or Nirnsteel_UI.Settings:IsCastBarEnabled()
end

local function IsModuleUnlocked()
    return IsModuleEnabled()
        and Nirnsteel_UI.Settings
        and Nirnsteel_UI.Settings:IsCastBarUnlocked()
end

local function GetPosition()
    if Nirnsteel_UI.Settings then
        return Nirnsteel_UI.Settings:GetCastBarPosition()
    end

    return DEFAULT_POSITION
end

local function GetScale()
    return ClampNumber(GetSettingValue("scale"), 70, 160) / 100
end

local function GetConfiguredWidth()
    return ClampNumber(GetSettingValue("width"), MIN_WIDTH, MAX_WIDTH)
end

local function GetConfiguredHeight()
    return ClampNumber(GetSettingValue("height"), MIN_HEIGHT, MAX_HEIGHT)
end

local function GetAlpha()
    return ClampNumber(GetSettingValue("opacity"), 20, 100) / 100
end

local function GetIntensity()
    return ClampNumber(GetSettingValue("animationIntensity"), 0, 160) / 100
end

local function GetTextMode()
    return TEXT_MODE_ALIASES[GetSettingValue("textMode")] or "nameAndTime"
end

local function BuildTextFont(size, outline)
    return string.format("$(BOLD_FONT)|%d|%s", size, outline or "thick-outline")
end

local function ShouldShowIcon()
    return GetSettingValue("showIcon") ~= false
end

local function ShouldShowTicks()
    return GetSettingValue("showTicks") ~= false
end

local function IsWeaponAttackName(abilityName)
    if not abilityName or abilityName == "" then
        return false
    end

    local normalizedName = string.lower(abilityName)
    return string.find(normalizedName, "heavy attack", 1, true) ~= nil
        or string.find(normalizedName, "light attack", 1, true) ~= nil
        or string.find(normalizedName, "weapon attack", 1, true) ~= nil
end

local function IsHudSceneShowing()
    local hudShowing = HUD_SCENE and HUD_SCENE:IsShowing()
    local hudUiShowing = HUD_UI_SCENE and HUD_UI_SCENE:IsShowing()
    return hudShowing or hudUiShowing
end

local function FormatCastTime(elapsedMS, durationMS)
    local elapsed = math.max(0, elapsedMS or 0) / 1000
    local duration = math.max(0, durationMS or 0) / 1000
    return string.format("%.1f / %.1f", elapsed, duration)
end

local function StopTimeline(timeline)
    if timeline then
        timeline:Stop()
    end
end

local function PlayAlpha(control, fromAlpha, toAlpha, durationMS, onStop)
    if not control then
        return
    end

    if control.nirnsteelAlphaTimeline then
        control.nirnsteelAlphaTimeline:Stop()
    end

    local animation, timeline = CreateSimpleAnimation(ANIMATION_ALPHA, control)
    animation:SetAlphaValues(fromAlpha, toAlpha)
    animation:SetDuration(durationMS)
    if onStop then
        animation:SetHandler("OnStop", onStop)
    end
    timeline:SetPlaybackType(ANIMATION_PLAYBACK_ONE_SHOT, 0)
    control.nirnsteelAlphaTimeline = timeline
    timeline:PlayFromStart()
end

local function Pulse01(progress)
    return math.sin(zo_clamp(progress, 0, 1) * math.pi)
end

local function ConfigureStatusBar(bar)
    bar:SetTexture(BAR_TEXTURE)
    bar:SetTextureCoords(0, 1, 0, 0.8125)
    bar:SetGradientColors(0.03, 0.48, 0.78, 0.98, 0.38, 0.92, 1.00, 1.00)
    bar:EnableLeadingEdge(false)
    bar:SetPixelRoundingEnabled(false)
    if bar.SetBarAlignment then
        bar:SetBarAlignment(BAR_ALIGNMENT_NORMAL)
    end
end

function CastBar:GetRoot()
    if self.root then
        return self.root
    end

    local root = WINDOW_MANAGER:CreateTopLevelWindow("Nirnsteel_UI_CastBarRoot")
    root:SetClampedToScreen(true)
    root:SetMouseEnabled(false)
    root:SetMovable(false)
    root:SetDrawTier(DT_HIGH)
    root:SetHidden(true)

    local frame = WINDOW_MANAGER:CreateControl(nil, root, CT_CONTROL)
    frame:SetAnchorFill(root)
    root.frame = frame

    frame.outerGlow = WINDOW_MANAGER:CreateControl(nil, frame, CT_BACKDROP)
    frame.outerGlow:SetAnchor(TOPLEFT, frame, TOPLEFT, -10, -9)
    frame.outerGlow:SetAnchor(BOTTOMRIGHT, frame, BOTTOMRIGHT, 10, 9)
    frame.outerGlow:SetEdgeTexture(EDGE_FRAME_TEXTURE, 128, 16, 8, 0)
    frame.outerGlow:SetCenterColor(0.02, 0.17, 0.22, 0.13)
    frame.outerGlow:SetEdgeColor(0.10, 0.82, 1.00, 0.70)
    frame.outerGlow:SetDrawLayer(DL_BACKGROUND)

    frame.shadow = WINDOW_MANAGER:CreateControl(nil, frame, CT_BACKDROP)
    frame.shadow:SetAnchor(TOPLEFT, frame, TOPLEFT, -6, -6)
    frame.shadow:SetAnchor(BOTTOMRIGHT, frame, BOTTOMRIGHT, 6, 6)
    frame.shadow:SetEdgeTexture(EDGE_FRAME_TEXTURE, 128, 16, 6, 0)
    frame.shadow:SetCenterColor(0, 0, 0, 0.58)
    frame.shadow:SetEdgeColor(0, 0, 0, 1)

    frame.backplate = WINDOW_MANAGER:CreateControl(nil, frame, CT_BACKDROP)
    frame.backplate:SetAnchorFill(frame)
    frame.backplate:SetEdgeTexture(EDGE_FRAME_TEXTURE, 128, 16, 5, 0)
    frame.backplate:SetCenterColor(0.015, 0.012, 0.010, 0.96)
    frame.backplate:SetEdgeColor(0, 0, 0, 1)

    frame.goldRim = WINDOW_MANAGER:CreateControl(nil, frame, CT_BACKDROP)
    frame.goldRim:SetAnchor(TOPLEFT, frame, TOPLEFT, 1, 1)
    frame.goldRim:SetAnchor(BOTTOMRIGHT, frame, BOTTOMRIGHT, -1, -1)
    frame.goldRim:SetEdgeTexture(EDGE_FRAME_TEXTURE, 128, 16, 4, 0)
    frame.goldRim:SetCenterColor(0, 0, 0, 0)
    frame.goldRim:SetEdgeColor(1.00, 0.58, 0.16, 1)

    frame.track = WINDOW_MANAGER:CreateControl(nil, frame, CT_BACKDROP)
    frame.track:SetEdgeTexture(EDGE_FRAME_TEXTURE, 128, 16, 3, 0)
    frame.track:SetCenterColor(0.00, 0.015, 0.022, 0.92)
    frame.track:SetEdgeColor(0.04, 0.04, 0.04, 1)

    frame.fillGlow = WINDOW_MANAGER:CreateControl(nil, frame.track, CT_STATUSBAR)
    frame.fillGlow:SetAnchor(TOPLEFT, frame.track, TOPLEFT, -1, -3)
    frame.fillGlow:SetAnchor(BOTTOMRIGHT, frame.track, BOTTOMRIGHT, 1, 3)
    frame.fillGlow:SetTexture(BAR_TEXTURE)
    frame.fillGlow:SetTextureCoords(0, 1, 0, 0.8125)
    frame.fillGlow:SetGradientColors(0.00, 0.62, 0.88, 0.42, 0.76, 1.00, 1.00, 0.66)
    frame.fillGlow:EnableLeadingEdge(false)
    frame.fillGlow:SetPixelRoundingEnabled(false)
    if frame.fillGlow.SetBarAlignment then
        frame.fillGlow:SetBarAlignment(BAR_ALIGNMENT_NORMAL)
    end

    frame.bar = WINDOW_MANAGER:CreateControl(nil, frame.track, CT_STATUSBAR)
    frame.bar:SetAnchorFill(frame.track)
    ConfigureStatusBar(frame.bar)

    frame.gloss = WINDOW_MANAGER:CreateControl(nil, frame.track, CT_STATUSBAR)
    frame.gloss:SetAnchorFill(frame.track)
    frame.gloss:SetTexture(BAR_GLOSS_TEXTURE)
    frame.gloss:SetTextureCoords(0, 1, 0, 0.8125)
    frame.gloss:SetColor(1, 1, 1, 0.22)
    frame.gloss:EnableLeadingEdge(false)
    frame.gloss:SetPixelRoundingEnabled(false)
    if frame.gloss.SetBarAlignment then
        frame.gloss:SetBarAlignment(BAR_ALIGNMENT_NORMAL)
    end

    frame.flash = WINDOW_MANAGER:CreateControl(nil, frame.track, CT_STATUSBAR)
    frame.flash:SetAnchorFill(frame.track)
    frame.flash:SetTexture(BAR_TEXTURE)
    frame.flash:SetTextureCoords(0, 1, 0, 0.8125)
    frame.flash:SetColor(1.00, 0.67, 0.18, 0)
    frame.flash:SetAlpha(0)
    frame.flash:SetHidden(true)
    frame.flash:EnableLeadingEdge(false)
    if frame.flash.SetBarAlignment then
        frame.flash:SetBarAlignment(BAR_ALIGNMENT_NORMAL)
    end

    frame.shine = WINDOW_MANAGER:CreateControl(nil, frame.track, CT_TEXTURE)
    frame.shine:SetTexture(SHINE_TEXTURE)
    frame.shine:SetColor(0.80, 1.00, 1.00, 0.30)
    frame.shine:SetTextureCoords(0, 1, 0, 1)
    frame.shine:SetHidden(true)
    frame.shine:SetDrawLayer(DL_OVERLAY)

    frame.leadingEdge = WINDOW_MANAGER:CreateControl(nil, frame.track, CT_TEXTURE)
    frame.leadingEdge:SetTexture(BAR_LEADING_EDGE_TEXTURE)
    frame.leadingEdge:SetTextureCoords(0, 1, 0, 0.6)
    frame.leadingEdge:SetColor(1.00, 0.96, 0.46, 0.95)
    frame.leadingEdge:SetDrawLayer(DL_OVERLAY)
    frame.leadingEdge:SetHidden(true)

    frame.impactFlash = WINDOW_MANAGER:CreateControl(nil, frame, CT_BACKDROP)
    frame.impactFlash:SetAnchor(TOPLEFT, frame, TOPLEFT, -8, -8)
    frame.impactFlash:SetAnchor(BOTTOMRIGHT, frame, BOTTOMRIGHT, 8, 8)
    frame.impactFlash:SetEdgeTexture(EDGE_FRAME_TEXTURE, 128, 16, 8, 0)
    frame.impactFlash:SetCenterColor(0.70, 0.94, 1.00, 0.05)
    frame.impactFlash:SetEdgeColor(0.56, 0.96, 1.00, 1)
    frame.impactFlash:SetDrawLayer(DL_OVERLAY)
    frame.impactFlash:SetAlpha(0)

    frame.shockwave = WINDOW_MANAGER:CreateControl(nil, frame, CT_BACKDROP)
    frame.shockwave:SetAnchor(TOPLEFT, frame, TOPLEFT, -12, -11)
    frame.shockwave:SetAnchor(BOTTOMRIGHT, frame, BOTTOMRIGHT, 12, 11)
    frame.shockwave:SetEdgeTexture(EDGE_FRAME_TEXTURE, 128, 16, 10, 0)
    frame.shockwave:SetCenterColor(1.00, 0.70, 0.18, 0.08)
    frame.shockwave:SetEdgeColor(1.00, 0.70, 0.20, 0.95)
    frame.shockwave:SetDrawLayer(DL_OVERLAY)
    frame.shockwave:SetAlpha(0)
    frame.shockwave:SetHidden(true)

    frame.chunkPulses = {}
    for index = 1, CHUNK_PULSE_COUNT do
        local pulse = WINDOW_MANAGER:CreateControl(nil, frame.track, CT_TEXTURE)
        pulse:SetTexture(BAR_LEADING_EDGE_TEXTURE)
        pulse:SetTextureCoords(0, 1, 0, 0.6)
        pulse:SetColor(0.90, 1.00, 1.00, 1)
        pulse:SetDrawLayer(DL_OVERLAY)
        pulse:SetAlpha(0)
        pulse:SetHidden(true)
        frame.chunkPulses[index] = pulse
    end

    frame.iconFrame = WINDOW_MANAGER:CreateControl(nil, frame, CT_BACKDROP)
    frame.iconFrame:SetCenterColor(0.03, 0.02, 0.01, 1)
    frame.iconFrame:SetEdgeColor(1.00, 0.62, 0.18, 1)
    frame.iconFrame:SetEdgeTexture(EDGE_FRAME_TEXTURE, 128, 16, 4, 0)

    frame.iconGlow = WINDOW_MANAGER:CreateControl(nil, frame.iconFrame, CT_BACKDROP)
    frame.iconGlow:SetAnchor(TOPLEFT, frame.iconFrame, TOPLEFT, -5, -5)
    frame.iconGlow:SetAnchor(BOTTOMRIGHT, frame.iconFrame, BOTTOMRIGHT, 5, 5)
    frame.iconGlow:SetCenterColor(1.00, 0.42, 0.06, 0.06)
    frame.iconGlow:SetEdgeColor(1.00, 0.52, 0.10, 0.92)
    frame.iconGlow:SetEdgeTexture(EDGE_FRAME_TEXTURE, 128, 16, 5, 0)

    frame.icon = WINDOW_MANAGER:CreateControl(nil, frame.iconFrame, CT_TEXTURE)
    frame.icon:SetAnchor(TOPLEFT, frame.iconFrame, TOPLEFT, 3, 3)
    frame.icon:SetAnchor(BOTTOMRIGHT, frame.iconFrame, BOTTOMRIGHT, -3, -3)
    frame.icon:SetTexture(FALLBACK_ICON)

    frame.leftLabel = WINDOW_MANAGER:CreateControl(nil, frame, CT_LABEL)
    frame.leftLabel:SetFont("$(BOLD_FONT)|20|thick-outline")
    frame.leftLabel:SetColor(0.94, 0.98, 1.00, 1)
    frame.leftLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    frame.leftLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    frame.leftLabel:SetModifyTextType(MODIFY_TEXT_TYPE_UPPERCASE)

    frame.rightLabel = WINDOW_MANAGER:CreateControl(nil, frame, CT_LABEL)
    frame.rightLabel:SetFont("$(BOLD_FONT)|18|thick-outline")
    frame.rightLabel:SetColor(1.00, 0.86, 0.44, 1)
    frame.rightLabel:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    frame.rightLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    frame.rightLabel:SetModifyTextType(MODIFY_TEXT_TYPE_NONE)

    self.root = root
    return root
end

function CastBar:GetMover()
    if self.mover then
        return self.mover
    end

    local mover = WINDOW_MANAGER:CreateTopLevelWindow("Nirnsteel_UI_CastBarMover")
    mover:SetClampedToScreen(true)
    mover:SetMouseEnabled(true)
    mover:SetMovable(false)
    mover:SetDrawTier(DT_HIGH)
    mover:SetHidden(true)

    local backdrop = WINDOW_MANAGER:CreateControl(nil, mover, CT_BACKDROP)
    backdrop:SetAnchorFill(mover)
    backdrop:SetCenterColor(0.02, 0.02, 0.02, 0.38)
    backdrop:SetEdgeColor(0.12, 0.88, 1.00, 0.92)
    backdrop:SetEdgeTexture("", 1, 1, 2)

    local label = WINDOW_MANAGER:CreateControl(nil, mover, CT_LABEL)
    label:SetAnchor(CENTER, mover, CENTER, 0, 0)
    label:SetFont("ZoFontGameBold")
    label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    label:SetText("Nirnsteel Cast Bar")
    label:SetColor(0.74, 0.96, 1.00, 1)

    mover:SetHandler("OnMouseDown", function(control, button)
        if button == MOUSE_BUTTON_INDEX_LEFT then
            control:SetMovable(true)
            control:StartMoving()
        else
            control:SetMovable(false)
        end
    end)

    mover:SetHandler("OnMouseUp", function(control, button)
        if button == MOUSE_BUTTON_INDEX_LEFT then
            control:StopMovingOrResizing()
        end
        control:SetMovable(false)
    end)

    mover:SetHandler("OnMoveStop", function(control)
        control:SetMovable(false)
        local x = control:GetLeft() + (control:GetWidth() * 0.5) - (GuiRoot:GetWidth() * 0.5)
        local y = control:GetTop() + (control:GetHeight() * 0.5) - (GuiRoot:GetHeight() * 0.5)
        if Nirnsteel_UI.Settings then
            Nirnsteel_UI.Settings:SetCastBarPosition(x, y)
        end
        self:ApplyLayout()
    end)

    self.mover = mover
    return mover
end

function CastBar:ApplyLayout()
    local root = self:GetRoot()
    local mover = self:GetMover()
    local frame = root.frame
    local width = GetConfiguredWidth()
    local height = GetConfiguredHeight()
    local scale = GetScale()
    local alpha = GetAlpha()
    local position = GetPosition()
    local showIcon = ShouldShowIcon()
    local contentHeight = math.max(height - (FRAME_PAD * 2), 1)
    local iconSize = showIcon and height + 6 or 0
    local barLeft = showIcon and (iconSize + ICON_PAD) or 0
    local labelInset = math.max(6, math.floor(height * 0.22))
    local nameFontSize = zo_clamp(math.floor(contentHeight * 0.64), 12, 24)
    local timerFontSize = zo_clamp(math.floor(contentHeight * 0.56), 11, 22)
    local timerWidth = math.max(86, math.floor(width * 0.22))
    local nameWidth = math.max(width - barLeft - labelInset * 3 - timerWidth, 40)

    root:SetDimensions(width, height)
    root:SetScale(scale)
    root:ClearAnchors()
    root:SetAnchor(CENTER, GuiRoot, CENTER, position.x, position.y)
    root:SetAlpha(alpha)

    mover:SetDimensions(width, height)
    mover:SetScale(scale)
    mover:ClearAnchors()
    mover:SetAnchor(CENTER, GuiRoot, CENTER, position.x, position.y)
    mover:SetHidden(not IsModuleUnlocked())

    frame.track:ClearAnchors()
    frame.track:SetAnchor(TOPLEFT, frame, TOPLEFT, barLeft + FRAME_PAD, FRAME_PAD)
    frame.track:SetAnchor(BOTTOMRIGHT, frame, BOTTOMRIGHT, -FRAME_PAD, -FRAME_PAD)

    frame.iconFrame:ClearAnchors()
    frame.iconFrame:SetDimensions(iconSize, iconSize)
    frame.iconFrame:SetAnchor(LEFT, frame, LEFT, -3, 0)
    frame.iconFrame:SetHidden(not showIcon)
    frame.iconGlow:SetHidden(not showIcon)

    frame.leftLabel:ClearAnchors()
    frame.leftLabel:SetAnchor(LEFT, frame.track, LEFT, labelInset, 0)
    frame.leftLabel:SetDimensions(nameWidth, contentHeight)
    frame.leftLabel:SetFont(BuildTextFont(nameFontSize, "thick-outline"))

    frame.rightLabel:ClearAnchors()
    frame.rightLabel:SetAnchor(RIGHT, frame.track, RIGHT, -labelInset, 0)
    frame.rightLabel:SetDimensions(timerWidth, contentHeight)
    frame.rightLabel:SetFont(BuildTextFont(timerFontSize, "thick-outline"))

    frame.shine:SetDimensions(math.max(48, math.floor((width - barLeft) * 0.26)), contentHeight + 8)
    frame.leadingEdge:SetDimensions(12 + (6 * GetIntensity()), contentHeight + 16)
    local showTicks = ShouldShowTicks()
    for _, pulse in ipairs(frame.chunkPulses) do
        pulse:SetDimensions(8 + (4 * GetIntensity()), contentHeight + 18)
        if not showTicks then
            pulse.activeMS = nil
            pulse:SetAlpha(0)
            pulse:SetHidden(true)
        end
    end

    ConfigureStatusBar(frame.bar)
    ConfigureStatusBar(frame.fillGlow)
    frame.gloss:SetTexture(BAR_GLOSS_TEXTURE)
end

function CastBar:UpdateText(elapsedMS)
    local root = self:GetRoot()
    local frame = root.frame
    local textMode = GetTextMode()
    local timeText = FormatCastTime(elapsedMS or 0, self.durationMS or 0)
    local name = self.abilityName or ""

    if textMode == "off" then
        frame.leftLabel:SetText("")
        frame.rightLabel:SetText("")
    elseif textMode == "nameOnly" then
        frame.leftLabel:SetText(name)
        frame.rightLabel:SetText("")
    elseif textMode == "timerOnly" then
        frame.leftLabel:SetText("")
        frame.rightLabel:SetText(timeText)
    else
        frame.leftLabel:SetText(name)
        frame.rightLabel:SetText(timeText)
    end
end

function CastBar:PlayStartFeedback()
    local root = self:GetRoot()
    local frame = root.frame
    local intensity = GetIntensity()
    local alpha = GetAlpha()

    StopTimeline(root.nirnsteelAlphaTimeline)
    root:SetHidden(false)
    root:SetAlpha(math.min(1, alpha * (0.78 + intensity * 0.18)))

    frame.outerGlow:SetEdgeColor(0.20, 0.94, 1.00, 0.72 + 0.20 * intensity)
    frame.impactFlash:SetEdgeColor(0.50, 0.95, 1.00, 1)
    frame.impactFlash:SetCenterColor(0.42, 0.92, 1.00, 0.07)
    PlayAlpha(frame.impactFlash, 0.72 * intensity, 0, 380)

    frame.flash:SetHidden(false)
    frame.flash:SetValue(0)
    frame.flash:SetColor(0.54, 0.96, 1.00, 0.78 * intensity)
    PlayAlpha(frame.flash, 0.62 * intensity, 0, 320)
end

function CastBar:PlayCompleteFeedback()
    local root = self:GetRoot()
    local frame = root.frame
    local intensity = GetIntensity()

    frame.outerGlow:SetEdgeColor(1.00, 0.70, 0.18, 0.98)
    frame.impactFlash:SetEdgeColor(1.00, 0.78, 0.20, 1)
    frame.impactFlash:SetCenterColor(1.00, 0.60, 0.12, 0.10)
    PlayAlpha(frame.impactFlash, 1 * intensity, 0, 520)

    frame.shockwave:SetHidden(false)
    frame.shockwave:SetScale(1)
    PlayAlpha(frame.shockwave, 0.95 * intensity, 0, 620, function()
        frame.shockwave:SetHidden(true)
        frame.shockwave:SetScale(1)
    end)

    frame.flash:SetHidden(false)
    frame.flash:SetMinMax(0, 1)
    frame.flash:SetValue(1)
    frame.flash:SetColor(1.00, 0.66, 0.16, 1 * intensity)
    PlayAlpha(frame.flash, 1 * intensity, 0, 480, function()
        frame.flash:SetHidden(true)
    end)
end

function CastBar:TriggerChunkPulse(progress)
    if not ShouldShowTicks() then
        return
    end

    local root = self:GetRoot()
    local frame = root.frame
    local pulses = frame.chunkPulses
    if not pulses or #pulses == 0 then
        return
    end

    self.nextChunkPulseIndex = (self.nextChunkPulseIndex or 0) + 1
    if self.nextChunkPulseIndex > #pulses then
        self.nextChunkPulseIndex = 1
    end

    local pulse = pulses[self.nextChunkPulseIndex]
    pulse.activeMS = GetFrameTimeMilliseconds()
    pulse.baseX = frame.track:GetWidth() * zo_clamp(progress, 0, 1)
    pulse:ClearAnchors()
    pulse:SetAnchor(CENTER, frame.track, LEFT, pulse.baseX, 0)
    pulse:SetAlpha(0.96)
    pulse:SetHidden(false)
end

function CastBar:UpdateChunkPulses(nowMS)
    if not ShouldShowTicks() then
        return
    end

    local root = self:GetRoot()
    local frame = root.frame
    if not frame.chunkPulses then
        return
    end

    for _, pulse in ipairs(frame.chunkPulses) do
        if pulse.activeMS then
            local progress = zo_clamp((nowMS - pulse.activeMS) / CHUNK_PULSE_MS, 0, 1)
            if progress >= 1 then
                pulse.activeMS = nil
                pulse:SetAlpha(0)
                pulse:SetHidden(true)
            else
                local width = 8 + (progress * 18) + (GetIntensity() * 4)
                local height = frame.track:GetHeight() + 16 + (progress * 14)
                pulse:SetDimensions(width, height)
                pulse:ClearAnchors()
                pulse:SetAnchor(CENTER, frame.track, LEFT, pulse.baseX or 0, 0)
                pulse:SetAlpha((1 - progress) * 0.88)
            end
        end
    end
end

function CastBar:Hide(immediate)
    self.active = false
    self.castId = (self.castId or 0) + 1

    local root = self:GetRoot()
    local frame = root.frame
    root:SetHandler("OnUpdate", nil)
    frame.shine:SetHidden(true)
    frame.leadingEdge:SetHidden(true)
    frame.shockwave:SetHidden(true)
    frame.shockwave:SetAlpha(0)
    frame.shockwave:SetScale(1)
    frame.impactFlash:SetAlpha(0)
    if frame.chunkPulses then
        for _, pulse in ipairs(frame.chunkPulses) do
            pulse.activeMS = nil
            pulse:SetAlpha(0)
            pulse:SetHidden(true)
        end
    end

    if immediate then
        StopTimeline(root.nirnsteelAlphaTimeline)
        root:SetHidden(true)
        return
    end

    local startAlpha = root:GetAlpha()
    PlayAlpha(root, startAlpha, 0, FADE_OUT_MS, function(_, completedPlaying)
        if completedPlaying and not self.active then
            root:SetHidden(true)
        end
    end)
end

function CastBar:Complete(castId)
    if castId and castId ~= self.castId then
        return
    end

    local root = self:GetRoot()
    local frame = root.frame
    self.active = false
    root:SetHandler("OnUpdate", nil)
    frame.bar:SetValue(self.durationMS or 1)
    frame.fillGlow:SetValue(self.durationMS or 1)
    frame.gloss:SetValue(self.durationMS or 1)
    frame.shine:SetHidden(true)
    frame.leadingEdge:SetHidden(true)
    self:UpdateText(self.durationMS or 0)
    self:PlayCompleteFeedback()

    zo_callLater(function()
        if self.castId == castId and not self.active then
            self:Hide(false)
        end
    end, COMPLETE_HOLD_MS)
end

function CastBar:StartCast(abilityId, abilityName, iconTexture, durationMS)
    durationMS = tonumber(durationMS) or 0
    if durationMS < MIN_DURATION_MS then
        return
    end

    self.castId = (self.castId or 0) + 1
    local castId = self.castId
    local root = self:GetRoot()
    local frame = root.frame
    local now = GetFrameTimeMilliseconds()

    self.active = true
    self.abilityId = abilityId
    self.abilityName = abilityName and abilityName ~= "" and abilityName or "Unknown Ability"
    self.iconTexture = iconTexture and iconTexture ~= "" and iconTexture or FALLBACK_ICON
    self.durationMS = durationMS
    self.startMS = now
    self.endMS = now + durationMS

    self:ApplyLayout()
    frame.icon:SetTexture(self.iconTexture)
    frame.bar:SetMinMax(0, durationMS)
    frame.bar:SetValue(0)
    frame.fillGlow:SetMinMax(0, durationMS)
    frame.fillGlow:SetValue(0)
    frame.gloss:SetMinMax(0, durationMS)
    frame.gloss:SetValue(0)
    frame.flash:SetHidden(true)
    frame.shine:SetHidden(false)
    frame.leadingEdge:SetHidden(false)
    frame.shockwave:SetHidden(true)
    frame.shockwave:SetAlpha(0)
    frame.impactFlash:SetAlpha(0)
    self.lastChunkIndex = 0
    self.nextChunkPulseIndex = 0
    self:UpdateText(0)
    self:PlayStartFeedback()

    root:SetHandler("OnUpdate", function()
        if not self.active or self.castId ~= castId or not IsModuleEnabled() or not IsHudSceneShowing() then
            self:Hide(false)
            return
        end

        local nowMS = GetFrameTimeMilliseconds()
        local elapsed = nowMS - self.startMS
        if elapsed >= durationMS then
            self:Complete(castId)
            return
        end

        local value = math.max(0, elapsed)
        local progress = zo_clamp(value / durationMS, 0, 1)
        local pulse = Pulse01((progress * 5) % 1)
        local intensity = GetIntensity()
        frame.bar:SetValue(value)
        frame.fillGlow:SetValue(value)
        frame.gloss:SetValue(value)
        frame.outerGlow:SetAlpha(zo_clamp(0.76 + pulse * 0.18 * intensity, 0, 1))
        frame.fillGlow:SetAlpha(zo_clamp(0.40 + pulse * 0.34 * intensity, 0, 0.92))
        frame.leadingEdge:SetAlpha(zo_clamp(0.70 + pulse * 0.30 * intensity, 0, 1))
        frame.iconGlow:SetAlpha(zo_clamp(0.64 + pulse * 0.30 * intensity, 0, 1))
        self:UpdateText(value)
        self:UpdateChunkPulses(nowMS)

        local chunkIndex = math.floor(progress * 10)
        if chunkIndex > (self.lastChunkIndex or 0) then
            self.lastChunkIndex = chunkIndex
            self:TriggerChunkPulse(progress)
        end

        local trackWidth = frame.track:GetWidth()
        if trackWidth and trackWidth > 0 then
            local shineWidth = frame.shine:GetWidth()
            local x = -shineWidth + ((trackWidth + shineWidth * 2) * progress)
            frame.shine:ClearAnchors()
            frame.shine:SetAnchor(LEFT, frame.track, LEFT, x, 0)
            frame.shine:SetAlpha(zo_clamp(0.26 + pulse * 0.18 * intensity, 0, 0.72))

            frame.leadingEdge:ClearAnchors()
            frame.leadingEdge:SetAnchor(CENTER, frame.track, LEFT, trackWidth * progress, 0)

            frame.shockwave:SetScale(1 + progress * 0.08)
        end
    end)
end

function CastBar:OnActionSlotAbilityUsed(actionSlotIndex)
    if not IsModuleEnabled() or not IsHudSceneShowing() or not actionSlotIndex then
        return
    end

    local slotType = GetSlotType(actionSlotIndex)
    if slotType ~= ACTION_TYPE_ABILITY and slotType ~= ACTION_TYPE_CRAFTED_ABILITY then
        return
    end

    local abilityId = GetSlotBoundId(actionSlotIndex)
    if not abilityId or abilityId == 0 then
        return
    end

    local abilityName = GetSlotName(actionSlotIndex)
    if IsWeaponAttackName(abilityName) then
        return
    end

    local channeled, durationMS = GetAbilityCastInfo(abilityId, nil, "player")
    if channeled == nil or not durationMS or durationMS <= 0 then
        return
    end

    local iconTexture = GetSlotTexture(actionSlotIndex)
    self:StartCast(abilityId, abilityName, iconTexture, durationMS)
end

function CastBar:SetSettingsPreviewActive(active)
    if active then
        self.previewActive = true
        self:StartCast(0, "Nirnsteel Power", FALLBACK_ICON, 3200)
    else
        self.previewActive = nil
        self:Hide(true)
    end
end

function CastBar:Preview()
    self:StartCast(0, "Nirnsteel Power", FALLBACK_ICON, 3200)
end

function CastBar:UpdateVisibility()
    local root = self:GetRoot()
    if not IsModuleEnabled() or (not self.active and not self.previewActive) or not IsHudSceneShowing() then
        if self.active or not root:IsHidden() then
            self:Hide(not IsModuleEnabled())
        end
    end
end

function CastBar:RegisterEvents()
    if self.eventsRegistered then
        return
    end

    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_ACTION_SLOT_ABILITY_USED, function(_, actionSlotIndex)
        self:OnActionSlotAbilityUsed(actionSlotIndex)
    end)
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE .. "_Activated", EVENT_PLAYER_ACTIVATED, function()
        self:ApplyLayout()
        self:UpdateVisibility()
    end)
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE .. "_ScreenResized", EVENT_SCREEN_RESIZED, function()
        self:ApplyLayout()
    end)
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE .. "_Gamepad", EVENT_GAMEPAD_PREFERRED_MODE_CHANGED, function()
        self:ApplyLayout()
    end)

    if HUD_SCENE then
        HUD_SCENE:RegisterCallback("StateChange", function()
            self:UpdateVisibility()
        end)
    end

    if HUD_UI_SCENE then
        HUD_UI_SCENE:RegisterCallback("StateChange", function()
            self:UpdateVisibility()
        end)
    end

    self.eventsRegistered = true
end

function CastBar:RefreshSettings()
    self:RegisterEvents()
    self:ApplyLayout()

    if not IsModuleEnabled() then
        self:Hide(true)
        self:GetMover():SetHidden(true)
    else
        self:GetMover():SetHidden(not IsModuleUnlocked())
    end
end

local DEBUG_COMMANDS =
{
    ["/nscastbar"] = function()
        CastBar:Preview()
    end,
}

local function IsDebugModeEnabled()
    return Nirnsteel_UI.Settings and Nirnsteel_UI.Settings:IsDebugModeEnabled()
end

local function RegisterDebugCommands()
    for command, handler in pairs(DEBUG_COMMANDS) do
        SLASH_COMMANDS[command] = IsDebugModeEnabled() and handler or nil
    end
end

function CastBar:RefreshDebugCommands()
    RegisterDebugCommands()
end

local function OnAddOnLoaded(_, addonName)
    if addonName ~= ADDON_NAME then
        return
    end

    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE .. "_Loaded", EVENT_ADD_ON_LOADED)
    CastBar:RefreshSettings()
    RegisterDebugCommands()
end

EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE .. "_Loaded", EVENT_ADD_ON_LOADED, OnAddOnLoaded)
