local ADDON_NAME = "NirnsteelUI"

Nirnsteel_UI = Nirnsteel_UI or {}
local Nirnsteel_UI = Nirnsteel_UI
local LevelVisuals = {}
Nirnsteel_UI.LevelVisuals = LevelVisuals

LevelVisuals.SHIMMER_CADENCE_MS = 4200

local CHAMPION_ICON_TEXTURE = "EsoUI/Art/Champion/champion_icon_32.dds"

local function GetChampionIconTexture()
    if ZO_GetChampionPointsIconSmall then
        local texture = ZO_GetChampionPointsIconSmall()
        if texture and texture ~= "" then
            return texture
        end
    end
    return CHAMPION_ICON_TEXTURE
end

local TIERS =
{
    { maximum = 0, textColor = { r = 0.68, g = 0.75, b = 0.84 } },
    { maximum = 599, textColor = { r = 0.96, g = 0.66, b = 0.34 } },
    { maximum = 1199, textColor = { r = 0.88, g = 0.93, b = 0.98 } },
    { maximum = 1799, textColor = { r = 1.00, g = 0.82, b = 0.30 } },
    { maximum = 1999, textColor = { r = 0.88, g = 0.68, b = 1.00 } },
    {
        maximum = 2399,
        textStops =
        {
            { r = 0.62, g = 0.28, b = 1.00 },
            { r = 1.00, g = 0.14, b = 0.58 },
            { r = 1.00, g = 0.72, b = 0.14 },
        },
        shimmer = 0.48,
        glowPulse = 0.18,
    },
    {
        maximum = 2999,
        textStops =
        {
            { r = 0.00, g = 0.92, b = 0.62 },
            { r = 0.00, g = 0.96, b = 1.00 },
            { r = 0.70, g = 0.22, b = 1.00 },
        },
        shimmer = 0.56,
        glowPulse = 0.22,
    },
    {
        maximum = 3599,
        textStops =
        {
            { r = 1.00, g = 0.35, b = 0.00 },
            { r = 1.00, g = 1.00, b = 0.66 },
            { r = 1.00, g = 0.12, b = 0.76 },
        },
        shimmer = 0.64,
        glowPulse = 0.26,
    },
    {
        maximum = math.huge,
        textStops =
        {
            { r = 0.00, g = 0.94, b = 1.00 },
            { r = 1.00, g = 0.08, b = 0.68 },
            { r = 1.00, g = 0.84, b = 0.12 },
        },
        shimmer = 0.78,
        glowPulse = 0.34,
    },
}
LevelVisuals.Tiers = TIERS

local function Clamp(value, minimum, maximum)
    value = tonumber(value) or minimum
    return math.min(math.max(value, minimum), maximum)
end

local function InterpolateColor(startColor, endColor, progress)
    progress = Clamp(progress, 0, 1)
    return
    {
        r = startColor.r + ((endColor.r - startColor.r) * progress),
        g = startColor.g + ((endColor.g - startColor.g) * progress),
        b = startColor.b + ((endColor.b - startColor.b) * progress),
    }
end

local function ColorChannelToHex(value)
    return math.floor((Clamp(value, 0, 1) * 255) + 0.5)
end

local function SamplePalette(stops, progress)
    local stopCount = stops and #stops or 0
    if stopCount == 0 then
        return { r = 1, g = 1, b = 1 }
    elseif stopCount == 1 then
        return stops[1]
    end
    local paletteIndex = math.floor((Clamp(progress, 0, 1) * (stopCount - 1)) + 0.5) + 1
    return stops[math.min(paletteIndex, stopCount)]
end

local function GetGlyphColor(tier, progress)
    if tier.textColor then
        return tier.textColor
    elseif tier.textStops then
        return SamplePalette(tier.textStops, progress)
    elseif tier.textMid then
        if progress <= 0.5 then
            return InterpolateColor(tier.textStart, tier.textMid, progress * 2)
        end
        return InterpolateColor(tier.textMid, tier.textEnd, (progress - 0.5) * 2)
    end
    return InterpolateColor(tier.textStart, tier.textEnd, progress)
end

function LevelVisuals:GetTier(data)
    if not data or not data.champion then
        return 1, TIERS[1]
    end
    local championPoints = tonumber(data.championPoints) or 0
    for index = 2, #TIERS do
        if championPoints <= TIERS[index].maximum then
            return index, TIERS[index]
        end
    end
    return #TIERS, TIERS[#TIERS]
end

function LevelVisuals:BuildGradientText(plainText, tier, shimmer)
    plainText = tostring(plainText or "")
    local glyphCount = #plainText
    local coloredGlyphs = {}
    for index = 1, glyphCount do
        local progress = glyphCount > 1 and ((index - 1) / (glyphCount - 1)) or 0.5
        local color = GetGlyphColor(tier, progress)
        if shimmer then
            color = InterpolateColor(color, { r = 1, g = 1, b = 1 }, 0.78)
        end
        coloredGlyphs[index] = string.format(
            "|c%02X%02X%02X%s|r",
            ColorChannelToHex(color.r),
            ColorChannelToHex(color.g),
            ColorChannelToHex(color.b),
            string.sub(plainText, index, index))
    end
    return table.concat(coloredGlyphs)
end

function LevelVisuals:Create(parent, options)
    options = options or {}
    local badge = {}
    local font = options.font or "$(BOLD_FONT)|13|outline"
    badge.height = tonumber(options.height) or 18
    badge.minimumWidth = tonumber(options.minimumWidth) or 34
    badge.maximumWidth = tonumber(options.maximumWidth) or 64
    badge.horizontalPadding = tonumber(options.horizontalPadding) or 10
    badge.showChampionIcon = options.showChampionIcon == true
    badge.championIconSize = tonumber(options.championIconSize) or 14
    badge.championIconGap = tonumber(options.championIconGap) or 2
    badge.fontSize = tonumber(options.fontSize) or tonumber(string.match(font, "|(%d+)|")) or 13

    badge.control = WINDOW_MANAGER:CreateControl(options.name, parent, CT_CONTROL)
    badge.control:SetDimensions(42, badge.height)

    badge.championIcon = WINDOW_MANAGER:CreateControl(nil, badge.control, CT_TEXTURE)
    badge.championIcon:SetDimensions(badge.championIconSize, badge.championIconSize)
    badge.championIcon:SetTexture(options.championIconTexture or GetChampionIconTexture())
    badge.championIcon:SetColor(1, 1, 1, 1)
    badge.championIcon:SetDrawLayer(DL_OVERLAY)
    badge.championIcon:SetDrawLevel(6)
    badge.championIcon:SetHidden(true)

    badge.label = WINDOW_MANAGER:CreateControl(nil, badge.control, CT_LABEL)
    badge.label:SetAnchorFill(badge.control)
    badge.label:SetFont(font)
    badge.label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    badge.label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    badge.label:SetModifyTextType(MODIFY_TEXT_TYPE_NONE)
    badge.label:SetColor(1, 1, 1, 1)
    badge.label:SetDrawLayer(DL_OVERLAY)
    badge.label:SetDrawLevel(5)

    badge.clip = WINDOW_MANAGER:CreateControl(nil, badge.control, CT_CONTROL)
    badge.clip:SetDimensions(10, badge.height)
    badge.clip:SetAutoRectClipChildren(true)
    badge.clip:SetDrawLayer(DL_OVERLAY)
    badge.clip:SetDrawLevel(6)
    badge.clip:SetAlpha(0)
    badge.clip:SetHidden(true)

    badge.content = WINDOW_MANAGER:CreateControl(nil, badge.clip, CT_CONTROL)
    badge.content:SetDimensions(42, badge.height)
    badge.content:SetAnchor(TOPLEFT, badge.clip, TOPLEFT, 0, 0)

    badge.glow = WINDOW_MANAGER:CreateControl(nil, badge.content, CT_LABEL)
    badge.glow:SetAnchorFill(badge.content)
    badge.glow:SetFont(options.glowFont or "$(BOLD_FONT)|14|soft-shadow-thick")
    badge.glow:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    badge.glow:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    badge.glow:SetModifyTextType(MODIFY_TEXT_TYPE_NONE)
    badge.glow:SetColor(1, 1, 1, 1)
    badge.glow:SetDrawLayer(DL_OVERLAY)
    badge.glow:SetDrawLevel(5)
    badge.glow:SetAlpha(0)

    badge.shimmer = WINDOW_MANAGER:CreateControl(nil, badge.content, CT_LABEL)
    badge.shimmer:SetAnchorFill(badge.content)
    badge.shimmer:SetFont(font)
    badge.shimmer:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    badge.shimmer:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    badge.shimmer:SetModifyTextType(MODIFY_TEXT_TYPE_NONE)
    badge.shimmer:SetColor(1, 1, 1, 1)
    badge.shimmer:SetDrawLayer(DL_OVERLAY)
    badge.shimmer:SetDrawLevel(6)
    badge.shimmer:SetAlpha(1)
    return badge
end

local function ApplyContentLayout(badge, championIconVisible, width, textWidth)
    badge.championIcon:SetHidden(not championIconVisible)
    badge.championIcon:ClearAnchors()
    badge.label:ClearAnchors()
    badge.glow:ClearAnchors()
    badge.shimmer:ClearAnchors()
    badge.content:SetDimensions(width, badge.height)

    if not championIconVisible then
        badge.label:SetAnchorFill(badge.control)
        badge.glow:SetAnchorFill(badge.content)
        badge.shimmer:SetAnchorFill(badge.content)
        return
    end

    local iconSize = badge.championIconSize
    local gap = badge.championIconGap
    local availableTextWidth = math.max(width - iconSize - gap - 2, 1)
    local renderedTextWidth = math.min(math.max(math.ceil(textWidth) + 2, 1), availableTextWidth)
    local contentWidth = iconSize + gap + renderedTextWidth
    local startX = math.max((width - contentWidth) * 0.5, 0)
    local textX = startX + iconSize + gap

    badge.championIcon:SetAnchor(LEFT, badge.control, LEFT, startX, 0)
    badge.label:SetAnchor(LEFT, badge.control, LEFT, textX, 2)
    badge.label:SetDimensions(renderedTextWidth, badge.height)
    badge.glow:SetAnchor(LEFT, badge.content, LEFT, textX, 2)
    badge.glow:SetDimensions(renderedTextWidth, badge.height)
    badge.shimmer:SetAnchor(LEFT, badge.content, LEFT, textX, 2)
    badge.shimmer:SetDimensions(renderedTextWidth, badge.height)
end

function LevelVisuals:Stop(badge)
    if not badge then
        return
    end
    if badge.timeline then
        badge.timeline:Stop()
    end
    badge.clip:SetAlpha(0)
    badge.clip:SetHidden(true)
    badge.glow:SetAlpha(0)
    badge.glow:SetHidden(true)
end

function LevelVisuals:Play(badge)
    if not badge or badge.shimmerIntensity <= 0 or badge.control:IsHidden() then
        return
    end
    if not badge.timeline then
        local timeline = ANIMATION_MANAGER:CreateTimeline()
        badge.sweep = timeline:InsertAnimation(ANIMATION_TRANSLATE, badge.clip, 0)
        badge.sweep:SetDuration(720)
        badge.counterSweep = timeline:InsertAnimation(ANIMATION_TRANSLATE, badge.content, 0)
        badge.counterSweep:SetDuration(720)
        badge.sweepFadeIn = timeline:InsertAnimation(ANIMATION_ALPHA, badge.clip, 0)
        badge.sweepFadeIn:SetDuration(100)
        badge.sweepFadeIn:SetAlphaValues(0, 1)
        if ZO_EaseOutQuadratic then
            badge.sweepFadeIn:SetEasingFunction(ZO_EaseOutQuadratic)
        end
        badge.sweepFadeOut = timeline:InsertAnimation(ANIMATION_ALPHA, badge.clip, 560)
        badge.sweepFadeOut:SetDuration(160)
        badge.sweepFadeOut:SetAlphaValues(1, 0)
        if ZO_EaseInOutQuadratic then
            badge.sweepFadeOut:SetEasingFunction(ZO_EaseInOutQuadratic)
        end
        badge.glowBrighten = timeline:InsertAnimation(ANIMATION_ALPHA, badge.glow, 0)
        badge.glowBrighten:SetDuration(240)
        badge.glowBrighten:SetAlphaValues(0, 1)
        if ZO_EaseOutQuadratic then
            badge.glowBrighten:SetEasingFunction(ZO_EaseOutQuadratic)
        end
        badge.glowFade = timeline:InsertAnimation(ANIMATION_ALPHA, badge.glow, 240)
        badge.glowFade:SetDuration(680)
        badge.glowFade:SetAlphaValues(1, 0)
        if ZO_EaseInOutQuadratic then
            badge.glowFade:SetEasingFunction(ZO_EaseInOutQuadratic)
        end
        timeline:SetHandler("OnStop", function()
            badge.clip:SetAlpha(0)
            badge.clip:SetHidden(true)
            badge.glow:SetAlpha(0)
            badge.glow:SetHidden(true)
        end)
        badge.timeline = timeline
    end

    local width = badge.control:GetWidth()
    local bandWidth = Clamp(width * 0.24, 7, 11)
    badge.clip:ClearAnchors()
    badge.clip:SetAnchor(TOPLEFT, badge.control, TOPLEFT, 0, 0)
    badge.clip:SetDimensions(bandWidth, badge.height)
    badge.clip:SetHidden(false)
    badge.clip:SetAlpha(0)
    badge.content:ClearAnchors()
    badge.content:SetAnchor(TOPLEFT, badge.clip, TOPLEFT, 0, 0)
    badge.content:SetDimensions(width, badge.height)
    badge.shimmer:SetAlpha(badge.shimmerIntensity)
    badge.glow:SetHidden(false)
    badge.glow:SetAlpha(0)
    badge.sweep:SetTranslateOffsets(-bandWidth, 0, width, 0)
    badge.counterSweep:SetTranslateOffsets(bandWidth, 0, -width, 0)
    badge.glowBrighten:SetAlphaValues(0, badge.glowIntensity or 0)
    badge.glowFade:SetAlphaValues(badge.glowIntensity or 0, 0)
    badge.timeline:SetPlaybackType(ANIMATION_PLAYBACK_ONE_SHOT, 0)
    badge.timeline:PlayFromStart()
end

function LevelVisuals:Apply(badge, data, options)
    options = options or {}
    local shown = options.shown ~= false
    badge.control:SetHidden(not shown)
    if not shown then
        badge.championIcon:SetHidden(true)
        badge.shimmerIntensity = 0
        badge.glowIntensity = 0
        self:Stop(badge)
        return 0, nil
    end

    data = data or {}
    local tierIndex, tier = self:GetTier(data)
    local text = data.champion and tostring(tonumber(data.championPoints) or 0)
        or string.format("L%d", tonumber(data.level) or 0)
    badge.label:SetColor(1, 1, 1, 1)
    badge.label:SetText(text)
    local textWidth = badge.label.GetStringWidth and tonumber(badge.label:GetStringWidth(text)) or 0
    if textWidth <= 0 then
        textWidth = math.max(math.ceil(#text * badge.fontSize * 0.58), 12)
    end
    local championIconVisible = data.champion == true and badge.showChampionIcon == true
    local iconWidth = championIconVisible and (badge.championIconSize + badge.championIconGap) or 0
    local width = math.max(badge.minimumWidth,
        math.min(textWidth + badge.horizontalPadding + iconWidth, badge.maximumWidth))
    badge.control:SetDimensions(width, badge.height)
    ApplyContentLayout(badge, championIconVisible, width, textWidth)

    if options.styled ~= false then
        badge.label:SetText(self:BuildGradientText(text, tier, false))
        local effectEligible = data.champion and (tonumber(data.championPoints) or 0) >= 2000
        local effectText = effectEligible and self:BuildGradientText(text, tier, true) or ""
        badge.shimmer:SetText(effectText)
        badge.glow:SetText(effectText)
        badge.shimmerIntensity = effectEligible and (tier.shimmer or 0) or 0
        badge.glowIntensity = effectEligible and (tier.glowPulse or 0) or 0
    else
        badge.label:SetText(text)
        badge.shimmer:SetText("")
        badge.glow:SetText("")
        badge.shimmerIntensity = 0
        badge.glowIntensity = 0
    end

    local hasEffects = badge.shimmerIntensity > 0 or badge.glowIntensity > 0
    if not hasEffects then
        self:Stop(badge)
    end
    if options.styled ~= false and options.playOnTierUpgrade and options.previousTier
        and tierIndex > options.previousTier and hasEffects then
        self:Play(badge)
    end
    return width, tierIndex
end
