local ADDON_NAME = "NirnsteelUI"
local EVENT_NAMESPACE = ADDON_NAME .. "_ExperienceTracker"

Nirnsteel_UI = Nirnsteel_UI or {}
local Nirnsteel_UI = Nirnsteel_UI
local ExperienceTracker = {}
Nirnsteel_UI.ExperienceTracker = ExperienceTracker

local DEFAULT_SETTINGS =
{
    enabled = true,
    unlocked = false,
    scale = 100,
    opacity = 100,
    width = 460,
    height = 64,
    durationMS = 3600,
    intensity = 100,
    visibilityMode = "fade",
    chunkSoundKey = "PROMOTIONAL_EVENT_REWARD_TO_CLAIM_PROMPT",
    levelUpSoundKey = "BATTLEGROUND_ROUND_RECAP_SCREEN_FINAL_WIN",
    showGainText = true,
    showProgressText = true,
    showChampionIcon = true,
    levelUpAnimationEnabled = true,
    levelUpIntensity = 100,
    hideBackground = false,
    hideStockProgressBar = true,
}

local DEFAULT_POSITION = { x = 30, y = 30 }
local BAR_TEXTURE = "EsoUI/Art/Miscellaneous/progressbar_genericFill_tall.dds"
local BAR_GLOSS_TEXTURE = "EsoUI/Art/Miscellaneous/timerBar_genericFill_gloss.dds"
local BAR_LEADING_EDGE_TEXTURE = "EsoUI/Art/Miscellaneous/progressbar_genericFill_leadingEdge_blunt.dds"
local EDGE_FRAME_TEXTURE = "EsoUI/Art/Miscellaneous/Gamepad/edgeframeGamepadBorder_thin.dds"
local TRACK_TEXTURE = "EsoUI/Art/Miscellaneous/progressbar_genericFill_tall.dds"
local CHAMPION_ICON = "EsoUI/Art/Champion/champion_icon.dds"
local BAR_TEXTURE_COORDS = { 0, 1, 0, 0.8125 }
local SEGMENT_DURATION_MS = 980
local LEVEL_UP_BURST_DURATION_MS = 920
local FADE_IN_MS = 130
local FADE_OUT_MS = 360
local MIN_GAIN_INTERVAL_MS = 80
local STOCK_HOOK_RETRY_MS = 500
local MAX_STOCK_HOOK_ATTEMPTS = 30
local MIN_CHUNKS = 3
local MAX_CHUNKS = 9
local CHUNK_PULSE_COUNT = 10
local CHUNK_PULSE_MS = 380
local IMPACT_FLASH_MS = 260

local CP_ICONS =
{
    [CHAMPION_DISCIPLINE_TYPE_WORLD] = "EsoUI/Art/Champion/champion_points_stamina_icon-HUD-32.dds",
    [CHAMPION_DISCIPLINE_TYPE_COMBAT] = "EsoUI/Art/Champion/champion_points_magicka_icon-HUD-32.dds",
    [CHAMPION_DISCIPLINE_TYPE_CONDITIONING] = "EsoUI/Art/Champion/champion_points_health_icon-HUD-32.dds",
}

local FALLBACK_CP_COLORS =
{
    [CHAMPION_DISCIPLINE_TYPE_WORLD] = {
        start = { 0.15, 0.78, 0.35, 0.98 },
        finish = { 0.70, 1.00, 0.46, 1.00 },
        glow = { 0.35, 1.00, 0.48 },
    },
    [CHAMPION_DISCIPLINE_TYPE_COMBAT] = {
        start = { 0.12, 0.40, 0.95, 0.98 },
        finish = { 0.44, 0.82, 1.00, 1.00 },
        glow = { 0.40, 0.78, 1.00 },
    },
    [CHAMPION_DISCIPLINE_TYPE_CONDITIONING] = {
        start = { 0.82, 0.12, 0.12, 0.98 },
        finish = { 1.00, 0.43, 0.32, 1.00 },
        glow = { 1.00, 0.28, 0.20 },
    },
}

local XP_COLORS =
{
    start = { 0.06, 0.52, 0.68, 0.98 },
    finish = { 0.36, 0.92, 1.00, 1.00 },
    accent = { 1.00, 0.78, 0.28, 1.00 },
    glow = { 0.20, 0.90, 1.00 },
}

local function ClampNumber(value, minValue, maxValue)
    value = tonumber(value) or minValue
    return math.min(math.max(value, minValue), maxValue)
end

local function GetSettings()
    if Nirnsteel_UI.Settings then
        return Nirnsteel_UI.Settings:GetExperienceTracker()
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
    return not Nirnsteel_UI.Settings or Nirnsteel_UI.Settings:IsExperienceTrackerEnabled()
end

local function IsModuleUnlocked()
    return IsModuleEnabled()
        and Nirnsteel_UI.Settings
        and Nirnsteel_UI.Settings:IsExperienceTrackerUnlocked()
end

local function ShouldHideStockProgressBar()
    return IsModuleEnabled()
        and (not Nirnsteel_UI.Settings or Nirnsteel_UI.Settings:ShouldExperienceTrackerHideStockProgressBar())
end

local function GetPosition()
    if Nirnsteel_UI.Settings then
        return Nirnsteel_UI.Settings:GetExperienceTrackerPosition()
    end

    return DEFAULT_POSITION
end

local function GetScale()
    return ClampNumber(GetSettingValue("scale"), 70, 160) / 100
end

local function GetAlpha()
    return ClampNumber(GetSettingValue("opacity"), 20, 100) / 100
end

local function GetConfiguredWidth()
    return ClampNumber(GetSettingValue("width"), 360, 680)
end

local function GetConfiguredHeight()
    return ClampNumber(GetSettingValue("height"), 54, 76)
end

local function GetVisibleDurationMS()
    return ClampNumber(GetSettingValue("durationMS"), 1800, 7000)
end

local function GetIntensity()
    return ClampNumber(GetSettingValue("intensity"), 0, 140) / 100
end

local function GetLevelUpIntensity()
    return ClampNumber(GetSettingValue("levelUpIntensity"), 0, 160) / 100
end

local function ShouldShowGainText()
    return GetSettingValue("showGainText") ~= false
end

local function ShouldShowProgressText()
    return GetSettingValue("showProgressText") ~= false
end

local function ShouldShowChampionIcon()
    return GetSettingValue("showChampionIcon") ~= false
end

local function ShouldPlayLevelUpAnimation()
    return GetSettingValue("levelUpAnimationEnabled") ~= false
end

local function ShouldHideBackground()
    return GetSettingValue("hideBackground") == true
end

local function IsAlwaysVisible()
    return GetSettingValue("visibilityMode") == "always"
end

local SOUND_KEY_ALIASES =
{
    None = "none",
    ["Outfit Weapon Type Rune"] = "OUTFIT_WEAPON_TYPE_RUNE",
    ["Promotional Event Reward To Claim"] = "PROMOTIONAL_EVENT_REWARD_TO_CLAIM_PROMPT",
    ["Endless Dungeon Counter Down"] = "ENDLESS_DUNGEON_COUNTER_DOWN",
    ["Battleground Round Recap Final Win"] = "BATTLEGROUND_ROUND_RECAP_SCREEN_FINAL_WIN",
    ["Battleground Round Recap Win"] = "BATTLEGROUND_ROUND_RECAP_SCREEN_WIN",
}

local function NormalizeSoundKey(key)
    if not key or key == "" then
        return nil
    end

    key = SOUND_KEY_ALIASES[key] or key
    if key == "none" or key == "None" then
        return nil
    end

    return key
end

local function GetSoundBySettingKey(settingKey)
    local key = NormalizeSoundKey(GetSettingValue(settingKey))
    if not key then
        return nil
    end

    if SOUNDS and SOUNDS[key] then
        return SOUNDS[key]
    end

    return key
end

local function GetChunkSound()
    return GetSoundBySettingKey("chunkSoundKey")
end

local function GetLevelUpSound()
    return GetSoundBySettingKey("levelUpSoundKey")
end

local function PlayLevelUpSound()
    local sound = GetLevelUpSound()
    if sound then
        PlaySound(sound)
    end
end

local function IsHudSceneShowing()
    return (HUD_SCENE and HUD_SCENE:IsShowing()) or (HUD_UI_SCENE and HUD_UI_SCENE:IsShowing())
end

local function EaseOutCubic(progress)
    local inverse = 1 - progress
    return 1 - inverse * inverse * inverse
end

local function EaseOutBack(progress)
    local c1 = 1.70158
    local c3 = c1 + 1
    local offset = progress - 1
    return 1 + c3 * offset * offset * offset + c1 * offset * offset
end

local function EaseOutQuart(progress)
    local inverse = 1 - progress
    return 1 - inverse * inverse * inverse * inverse
end

local function Pulse01(progress)
    if progress < 0.5 then
        return progress * 2
    end

    return (1 - progress) * 2
end

local function UnpackColorTable(color, fallback)
    color = color or fallback
    return color[1], color[2], color[3], color[4] or 1
end

local function ApplyGradientFromColorDefs(statusBar, gradient)
    if statusBar and gradient and gradient[1] and gradient[2] then
        local r, g, b, a = gradient[1]:UnpackRGBA()
        local r2, g2, b2, a2 = gradient[2]:UnpackRGBA()
        statusBar:SetGradientColors(r, g, b, a, r2, g2, b2, a2)
        return true
    end

    return false
end

local function GetNextChampionPool(championPoints)
    local shownRank = tonumber(championPoints) or GetPlayerChampionPointsEarned()
    if GetNumChampionXPInChampionPoint(shownRank) ~= nil then
        shownRank = shownRank + 1
    end
    return GetChampionPointPoolForRank(shownRank)
end

local function GetModeInfo(mode, level)
    if mode == "cp" then
        local pool = GetNextChampionPool(level)
        local fallback = FALLBACK_CP_COLORS[pool] or FALLBACK_CP_COLORS[CHAMPION_DISCIPLINE_TYPE_WORLD]
        return {
            mode = mode,
            pool = pool,
            start = fallback.start,
            finish = fallback.finish,
            glow = fallback.glow,
            gradient = ZO_CP_BAR_GRADIENT_COLORS and ZO_CP_BAR_GRADIENT_COLORS[pool],
            icon = CP_ICONS[pool] or CHAMPION_ICON,
        }
    end

    return {
        mode = mode,
        start = XP_COLORS.start,
        finish = XP_COLORS.finish,
        glow = XP_COLORS.glow,
        gradient = ZO_XP_BAR_GRADIENT_COLORS,
        icon = nil,
    }
end

local function GetLevelSize(mode, level)
    if mode == "cp" then
        return GetNumChampionXPInChampionPoint(level)
    end

    return GetNumExperiencePointsInLevel(level)
end

local function FormatNumber(value)
    if ZO_CommaDelimitNumber then
        return ZO_CommaDelimitNumber(value)
    end

    return tostring(value)
end

local function FormatProgressText(value, maxValue)
    maxValue = math.max(tonumber(maxValue) or 1, 1)
    value = zo_clamp(tonumber(value) or 0, 0, maxValue)
    value = math.floor(value + 0.5)
    local percent = math.floor((value / maxValue) * 100 + 0.5)
    return string.format("%s / %s - %d%%", FormatNumber(value), FormatNumber(maxValue), percent)
end

local function GetLevelTextWidthHint(level)
    local text = tostring(level or "")
    local digits = math.max(#text, 2)
    return digits * 18
end

local function GetLevelFontSize(level, mode)
    local digits = #tostring(level or "")
    if digits >= 5 then
        return mode == "cp" and 26 or 28
    elseif digits >= 4 then
        return mode == "cp" and 30 or 32
    end

    return mode == "cp" and 34 or 36
end

local function ConfigureStatusBar(bar)
    bar:SetTexture(BAR_TEXTURE)
    bar:SetTextureCoords(unpack(BAR_TEXTURE_COORDS))
    bar:EnableLeadingEdge(true)
    bar:SetLeadingEdge(BAR_LEADING_EDGE_TEXTURE, 4, 12)
    bar:SetLeadingEdgeTextureCoords(0, 1, 0, 0.8125)
    bar:SetPixelRoundingEnabled(false)
end

function ExperienceTracker:GetRoot()
    if self.root then
        return self.root
    end

    local wm = WINDOW_MANAGER
    local root = wm:CreateTopLevelWindow("Nirnsteel_UI_ExperienceTrackerRoot")
    root:SetClampedToScreen(true)
    root:SetMouseEnabled(false)
    root:SetDrawTier(DT_HIGH)
    root:SetHidden(true)
    root:SetAlpha(0)

    local outerShadow = wm:CreateControl(nil, root, CT_BACKDROP)
    outerShadow:SetCenterColor(0, 0, 0, 0.16)
    outerShadow:SetEdgeColor(0, 0, 0, 0.82)
    outerShadow:SetEdgeTexture(EDGE_FRAME_TEXTURE, 128, 16, 7, 0)
    outerShadow:SetDrawLayer(DL_BACKGROUND)
    root.outerShadow = outerShadow

    local panel = wm:CreateControl(nil, root, CT_BACKDROP)
    panel:SetCenterColor(0.015, 0.014, 0.012, 0.72)
    panel:SetEdgeColor(0.72, 0.58, 0.32, 0.52)
    panel:SetEdgeTexture(EDGE_FRAME_TEXTURE, 128, 16, 4, 0)
    panel:SetDrawLayer(DL_BACKGROUND)
    root.panel = panel

    local panelInset = wm:CreateControl(nil, root, CT_BACKDROP)
    panelInset:SetCenterColor(0, 0, 0, 0)
    panelInset:SetEdgeColor(0, 0, 0, 0.72)
    panelInset:SetEdgeTexture(EDGE_FRAME_TEXTURE, 128, 16, 3, 0)
    panelInset:SetDrawLayer(DL_OVERLAY)
    root.panelInset = panelInset

    local badgeGlow = wm:CreateControl(nil, root, CT_BACKDROP)
    badgeGlow:SetCenterColor(0.70, 0.54, 0.24, 0.08)
    badgeGlow:SetEdgeColor(0.95, 0.74, 0.28, 0.38)
    badgeGlow:SetEdgeTexture(EDGE_FRAME_TEXTURE, 128, 16, 10, 0)
    badgeGlow:SetDrawLayer(DL_CONTROLS)
    root.badgeGlow = badgeGlow

    local badge = wm:CreateControl(nil, root, CT_BACKDROP)
    badge:SetCenterColor(0.015, 0.014, 0.012, 0.94)
    badge:SetEdgeColor(0.86, 0.70, 0.36, 0.82)
    badge:SetEdgeTexture(EDGE_FRAME_TEXTURE, 128, 16, 8, 0)
    badge:SetDrawLayer(DL_CONTROLS)
    root.badge = badge

    local levelLabel = wm:CreateControl(nil, root, CT_LABEL)
    levelLabel:SetFont("$(BOLD_FONT)|36|thick-outline")
    levelLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    levelLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    levelLabel:SetModifyTextType(MODIFY_TEXT_TYPE_UPPERCASE)
    levelLabel:SetText("45")
    root.levelLabel = levelLabel

    local typeLabel = wm:CreateControl(nil, root, CT_LABEL)
    typeLabel:SetFont("$(BOLD_FONT)|14|soft-shadow-thin")
    typeLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    typeLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    typeLabel:SetModifyTextType(MODIFY_TEXT_TYPE_UPPERCASE)
    typeLabel:SetText("LEVEL")
    root.typeLabel = typeLabel

    local icon = wm:CreateControl(nil, root, CT_TEXTURE)
    icon:SetHidden(true)
    icon:SetDrawLayer(DL_OVERLAY)
    root.icon = icon

    local progressLabel = wm:CreateControl(nil, root, CT_LABEL)
    progressLabel:SetFont("$(MEDIUM_FONT)|13|soft-shadow-thin")
    progressLabel:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    progressLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    progressLabel:SetColor(0.82, 0.78, 0.68, 0.96)
    progressLabel:SetText("")
    root.progressLabel = progressLabel

    local track = wm:CreateControl(nil, root, CT_BACKDROP)
    track:SetCenterColor(0.004, 0.004, 0.004, 0.92)
    track:SetEdgeColor(0, 0, 0, 0.92)
    track:SetEdgeTexture(EDGE_FRAME_TEXTURE, 128, 16, 4, 0)
    root.track = track

    local trackShade = wm:CreateControl(nil, root, CT_TEXTURE)
    trackShade:SetTexture(TRACK_TEXTURE)
    trackShade:SetTextureCoords(unpack(BAR_TEXTURE_COORDS))
    trackShade:SetColor(1, 1, 1, 0.035)
    trackShade:SetDrawLayer(DL_CONTROLS)
    root.trackShade = trackShade

    local trackInnerShadow = wm:CreateControl(nil, root, CT_BACKDROP)
    trackInnerShadow:SetCenterColor(0, 0, 0, 0.10)
    trackInnerShadow:SetEdgeColor(0, 0, 0, 0.86)
    trackInnerShadow:SetEdgeTexture(EDGE_FRAME_TEXTURE, 128, 16, 4, 0)
    trackInnerShadow:SetDrawLayer(DL_OVERLAY)
    root.trackInnerShadow = trackInnerShadow

    local impactFlash = wm:CreateControl(nil, root, CT_BACKDROP)
    impactFlash:SetCenterColor(1, 1, 1, 0)
    impactFlash:SetEdgeTexture(EDGE_FRAME_TEXTURE, 128, 16, 8, 0)
    impactFlash:SetDrawLayer(DL_OVERLAY)
    impactFlash:SetAlpha(0)
    root.impactFlash = impactFlash

    local barShockwave = wm:CreateControl(nil, root, CT_BACKDROP)
    barShockwave:SetCenterColor(1, 1, 1, 0)
    barShockwave:SetEdgeTexture(EDGE_FRAME_TEXTURE, 128, 16, 10, 0)
    barShockwave:SetDrawLayer(DL_OVERLAY)
    barShockwave:SetAlpha(0)
    barShockwave:SetHidden(true)
    root.barShockwave = barShockwave

    local enlightened = wm:CreateControl(nil, root, CT_STATUSBAR)
    ConfigureStatusBar(enlightened)
    enlightened:SetAlpha(0.24)
    enlightened:SetHidden(true)
    enlightened:SetDrawLayer(DL_CONTROLS)
    root.enlightened = enlightened

    local bar = wm:CreateControl(nil, root, CT_STATUSBAR)
    ConfigureStatusBar(bar)
    bar:SetDrawLayer(DL_CONTROLS)
    root.bar = bar

    local bulk = wm:CreateControl(nil, root, CT_STATUSBAR)
    ConfigureStatusBar(bulk)
    bulk:SetDrawLayer(DL_OVERLAY)
    bulk:SetAlpha(0)
    bulk:SetHidden(true)
    root.bulk = bulk

    local gloss = wm:CreateControl(nil, root, CT_STATUSBAR)
    gloss:SetTexture(BAR_GLOSS_TEXTURE)
    gloss:SetTextureCoords(unpack(BAR_TEXTURE_COORDS))
    gloss:EnableLeadingEdge(false)
    gloss:SetColor(1, 1, 1, 0.20)
    gloss:SetDrawLayer(DL_OVERLAY)
    root.gloss = gloss

    local glow = wm:CreateControl(nil, root, CT_BACKDROP)
    glow:SetCenterColor(0, 0, 0, 0)
    glow:SetEdgeTexture(EDGE_FRAME_TEXTURE, 128, 16, 6, 0)
    glow:SetDrawLayer(DL_OVERLAY)
    glow:SetAlpha(0)
    root.glow = glow

    local shine = wm:CreateControl(nil, root, CT_TEXTURE)
    shine:SetTexture("EsoUI/Art/Miscellaneous/progressbar_texture_overlay.dds")
    shine:SetColor(1, 1, 1, 1)
    shine:SetAlpha(0)
    shine:SetDrawLayer(DL_OVERLAY)
    shine:SetHidden(true)
    root.shine = shine

    local rewardShine = wm:CreateControl(nil, root, CT_TEXTURE)
    rewardShine:SetTexture("EsoUI/Art/Miscellaneous/progressbar_texture_overlay.dds")
    rewardShine:SetColor(1, 1, 1, 1)
    rewardShine:SetAlpha(0)
    rewardShine:SetDrawLayer(DL_OVERLAY)
    rewardShine:SetHidden(true)
    root.rewardShine = rewardShine

    local levelBurst = wm:CreateControl(nil, root, CT_TEXTURE)
    levelBurst:SetTexture("EsoUI/Art/Miscellaneous/progressbar_texture_overlay.dds")
    levelBurst:SetColor(1, 1, 1, 1)
    levelBurst:SetAlpha(0)
    levelBurst:SetDrawLayer(DL_OVERLAY)
    levelBurst:SetHidden(true)
    root.levelBurst = levelBurst

    local badgeBurst = wm:CreateControl(nil, root, CT_BACKDROP)
    badgeBurst:SetCenterColor(1, 1, 1, 0)
    badgeBurst:SetEdgeTexture(EDGE_FRAME_TEXTURE, 128, 16, 12, 0)
    badgeBurst:SetDrawLayer(DL_OVERLAY)
    badgeBurst:SetAlpha(0)
    badgeBurst:SetHidden(true)
    root.badgeBurst = badgeBurst

    root.chunkPulses = {}
    for i = 1, CHUNK_PULSE_COUNT do
        local chunkPulse = wm:CreateControl(nil, root, CT_TEXTURE)
        chunkPulse:SetTexture(BAR_LEADING_EDGE_TEXTURE)
        chunkPulse:SetTextureCoords(0, 1, 0, 0.6)
        chunkPulse:SetDrawLayer(DL_OVERLAY)
        chunkPulse:SetAlpha(0)
        chunkPulse:SetHidden(true)
        root.chunkPulses[i] = chunkPulse
    end

    local gainLabel = wm:CreateControl(nil, root, CT_LABEL)
    gainLabel:SetFont("$(BOLD_FONT)|17|thick-outline")
    gainLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    gainLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    gainLabel:SetAlpha(0)
    gainLabel:SetHidden(true)
    root.gainLabel = gainLabel

    self.root = root
    return root
end

function ExperienceTracker:GetMover()
    if self.mover then
        return self.mover
    end

    local mover = WINDOW_MANAGER:CreateTopLevelWindow("Nirnsteel_UI_ExperienceTrackerMover")
    mover:SetClampedToScreen(true)
    mover:SetMouseEnabled(true)
    mover:SetMovable(false)
    mover:SetDrawTier(DT_HIGH)
    mover:SetHidden(true)

    local backdrop = WINDOW_MANAGER:CreateControl(nil, mover, CT_BACKDROP)
    backdrop:SetAnchorFill(mover)
    backdrop:SetCenterColor(0.02, 0.02, 0.02, 0.55)
    backdrop:SetEdgeColor(0.94, 0.78, 0.30, 0.92)
    backdrop:SetEdgeTexture("", 1, 1, 2)

    local label = WINDOW_MANAGER:CreateControl(nil, mover, CT_LABEL)
    label:SetAnchor(CENTER, mover, CENTER, 0, 0)
    label:SetFont("ZoFontGameBold")
    label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    label:SetText("Nirnsteel Experience Tracker")
    label:SetColor(0.95, 0.86, 0.38, 1)

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
        local x = control:GetLeft()
        local y = control:GetTop()
        if Nirnsteel_UI.Settings then
            Nirnsteel_UI.Settings:SetExperienceTrackerPosition(x, y)
        end
        self:ApplyLayout()
    end)

    self.mover = mover
    return mover
end

function ExperienceTracker:ApplyLayout()
    local root = self:GetRoot()
    local mover = self:GetMover()
    local position = GetPosition()
    local scale = GetScale()
    local width = GetConfiguredWidth()
    local height = GetConfiguredHeight()
    local pad = math.max(5, math.floor(height * 0.10))
    local mode = self.currentMode or "xp"
    local levelText = self.currentLevelText or "45"
    local badgeSize = math.max(42, height - pad * 2)
    local badgeWidth = math.max(badgeSize, GetLevelTextWidthHint(levelText) + 16)
    local contentX = pad + badgeWidth + math.max(12, math.floor(height * 0.20))
    local contentWidth = math.max(150, width - contentX - pad)
    local headerHeight = math.max(15, math.floor(height * 0.26))
    local barHeight = math.max(14, math.floor(height * 0.34))
    local barTop = math.max(pad + headerHeight - 1, math.floor(height * 0.34))
    local footerHeight = math.max(14, height - barTop - barHeight - pad)
    local iconSize = math.max(15, math.floor(badgeSize * 0.34))
    local hideBackground = ShouldHideBackground()

    root:SetDimensions(width, height)
    root:SetScale(scale)
    root:ClearAnchors()
    root:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, position.x, position.y)

    root.outerShadow:ClearAnchors()
    root.outerShadow:SetAnchor(TOPLEFT, root, TOPLEFT, -5, -5)
    root.outerShadow:SetAnchor(BOTTOMRIGHT, root, BOTTOMRIGHT, 5, 5)
    root.outerShadow:SetHidden(hideBackground)

    root.panel:ClearAnchors()
    root.panel:SetAnchorFill(root)
    root.panel:SetHidden(hideBackground)

    root.panelInset:ClearAnchors()
    root.panelInset:SetAnchor(TOPLEFT, root, TOPLEFT, 2, 2)
    root.panelInset:SetAnchor(BOTTOMRIGHT, root, BOTTOMRIGHT, -2, -2)
    root.panelInset:SetHidden(hideBackground)

    root.badgeGlow:ClearAnchors()
    root.badgeGlow:SetDimensions(badgeWidth + 10, badgeSize + 10)
    root.badgeGlow:SetAnchor(LEFT, root, LEFT, pad - 5, 0)

    root.badge:ClearAnchors()
    root.badge:SetDimensions(badgeWidth, badgeSize)
    root.badge:SetAnchor(CENTER, root.badgeGlow, CENTER, 0, 0)

    root.levelLabel:ClearAnchors()
    root.levelLabel:SetDimensions(badgeWidth, math.max(24, badgeSize - iconSize + 1))
    root.levelLabel:SetAnchor(TOP, root.badge, TOP, 0, 1)
    root.levelLabel:SetFont(string.format("$(BOLD_FONT)|%d|thick-outline", GetLevelFontSize(levelText, mode)))

    root.typeLabel:ClearAnchors()
    root.typeLabel:SetDimensions(math.floor(contentWidth * 0.40), headerHeight)
    root.typeLabel:SetAnchor(TOPLEFT, root, TOPLEFT, contentX, pad - 1)

    root.icon:ClearAnchors()
    root.icon:SetDimensions(iconSize, iconSize)
    root.icon:SetAnchor(BOTTOM, root.badge, BOTTOM, 0, -4)

    root.progressLabel:ClearAnchors()
    root.progressLabel:SetDimensions(math.floor(contentWidth * 0.58), headerHeight)
    root.progressLabel:SetAnchor(TOPRIGHT, root, TOPRIGHT, -pad, pad - 1)
    root.progressLabel:SetHidden(not ShouldShowProgressText())

    root.track:ClearAnchors()
    root.track:SetDimensions(contentWidth, barHeight)
    root.track:SetAnchor(TOPLEFT, root, TOPLEFT, contentX, barTop)

    root.trackShade:ClearAnchors()
    root.trackShade:SetAnchorFill(root.track)

    root.trackInnerShadow:ClearAnchors()
    root.trackInnerShadow:SetAnchorFill(root.track)

    root.impactFlash:ClearAnchors()
    root.impactFlash:SetAnchor(TOPLEFT, root.track, TOPLEFT, -8, -8)
    root.impactFlash:SetAnchor(BOTTOMRIGHT, root.track, BOTTOMRIGHT, 8, 8)

    root.barShockwave:ClearAnchors()
    root.barShockwave:SetAnchor(TOPLEFT, root, TOPLEFT, -10, -10)
    root.barShockwave:SetAnchor(BOTTOMRIGHT, root, BOTTOMRIGHT, 10, 10)

    root.enlightened:ClearAnchors()
    root.enlightened:SetAnchorFill(root.track)

    root.bar:ClearAnchors()
    root.bar:SetAnchorFill(root.track)

    root.bulk:ClearAnchors()
    root.bulk:SetAnchorFill(root.track)

    root.gloss:ClearAnchors()
    root.gloss:SetAnchorFill(root.track)

    root.glow:ClearAnchors()
    root.glow:SetAnchor(TOPLEFT, root.track, TOPLEFT, -7, -7)
    root.glow:SetAnchor(BOTTOMRIGHT, root.track, BOTTOMRIGHT, 7, 7)

    root.shine:ClearAnchors()
    root.shine:SetDimensions(math.max(38, contentWidth * 0.18), barHeight + 4)
    root.shine:SetAnchor(LEFT, root.track, LEFT, 0, 0)

    root.rewardShine:ClearAnchors()
    root.rewardShine:SetDimensions(math.max(76, contentWidth * 0.34), barHeight + 18)
    root.rewardShine:SetAnchor(LEFT, root.track, LEFT, -root.rewardShine:GetWidth(), 0)

    root.levelBurst:ClearAnchors()
    root.levelBurst:SetDimensions(contentWidth + badgeWidth + 40, height + 20)
    root.levelBurst:SetAnchor(CENTER, root, CENTER, 0, 0)

    root.badgeBurst:ClearAnchors()
    root.badgeBurst:SetDimensions(badgeWidth + 18, badgeSize + 18)
    root.badgeBurst:SetAnchor(CENTER, root.badge, CENTER, 0, 0)

    for _, chunkPulse in ipairs(root.chunkPulses) do
        chunkPulse:ClearAnchors()
        chunkPulse:SetDimensions(5, barHeight + 8)
        chunkPulse:SetAnchor(CENTER, root.track, LEFT, 0, 0)
    end

    root.gainLabel:ClearAnchors()
    root.gainLabel:SetDimensions(contentWidth, footerHeight)
    root.gainLabel:SetAnchor(TOPLEFT, root.track, BOTTOMLEFT, 0, 1)

    mover:SetDimensions(width * scale, height * scale)
    mover:ClearAnchors()
    mover:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, position.x, position.y)
    mover:SetHidden(not IsModuleUnlocked())
end

function ExperienceTracker:SetVisualMode(mode, level)
    local root = self:GetRoot()
    local info = GetModeInfo(mode, level)
    local startR, startG, startB, startA = UnpackColorTable(info.start, XP_COLORS.start)
    local endR, endG, endB, endA = UnpackColorTable(info.finish, XP_COLORS.finish)
    local glowR, glowG, glowB = UnpackColorTable(info.glow, XP_COLORS.glow)

    if not ApplyGradientFromColorDefs(root.bar, info.gradient) then
        root.bar:SetGradientColors(startR, startG, startB, startA, endR, endG, endB, endA)
    end
    if not ApplyGradientFromColorDefs(root.bulk, info.gradient) then
        root.bulk:SetGradientColors(zo_clamp(endR + 0.12, 0, 1), zo_clamp(endG + 0.12, 0, 1), zo_clamp(endB + 0.12, 0, 1), 1, 1, 1, 1)
    end
    if not ApplyGradientFromColorDefs(root.enlightened, info.gradient) then
        root.enlightened:SetGradientColors(startR, startG, startB, 0.55, endR, endG, endB, 0.55)
    end

    root.panel:SetEdgeColor(glowR, glowG, glowB, 0.30 + 0.16 * GetIntensity())
    root.badge:SetEdgeColor(zo_clamp(endR + 0.08, 0, 1), zo_clamp(endG + 0.08, 0, 1), zo_clamp(endB + 0.08, 0, 1), 0.76)
    root.badgeGlow:SetEdgeColor(glowR, glowG, glowB, 0.34 + 0.12 * GetIntensity())
    root.badgeGlow:SetCenterColor(glowR, glowG, glowB, 0.04 + 0.04 * GetIntensity())
    root.gloss:SetColor(1, 1, 1, 0.14 + (0.05 * GetIntensity()))
    root.glow:SetEdgeColor(glowR, glowG, glowB, 0.66 * GetIntensity())
    root.glow:SetCenterColor(glowR, glowG, glowB, 0.065 * GetIntensity())
    root.impactFlash:SetEdgeColor(glowR, glowG, glowB, 0.9)
    root.impactFlash:SetCenterColor(endR, endG, endB, 0.035)
    root.barShockwave:SetEdgeColor(glowR, glowG, glowB, 0.96)
    root.barShockwave:SetCenterColor(endR, endG, endB, 0.10)
    root.levelBurst:SetColor(zo_clamp(endR + 0.22, 0, 1), zo_clamp(endG + 0.22, 0, 1), zo_clamp(endB + 0.22, 0, 1), 1)
    root.badgeBurst:SetEdgeColor(glowR, glowG, glowB, 0.95)
    root.badgeBurst:SetCenterColor(endR, endG, endB, 0.08)
    root.rewardShine:SetColor(zo_clamp(endR + 0.28, 0, 1), zo_clamp(endG + 0.28, 0, 1), zo_clamp(endB + 0.28, 0, 1), 1)
    root.gainLabel:SetColor(zo_clamp(endR + 0.16, 0, 1), zo_clamp(endG + 0.16, 0, 1), zo_clamp(endB + 0.16, 0, 1), 1)
    root.typeLabel:SetColor(zo_clamp(endR + 0.10, 0, 1), zo_clamp(endG + 0.10, 0, 1), zo_clamp(endB + 0.10, 0, 1), 0.98)
    for _, chunkPulse in ipairs(root.chunkPulses) do
        chunkPulse:SetColor(zo_clamp(endR + 0.20, 0, 1), zo_clamp(endG + 0.20, 0, 1), zo_clamp(endB + 0.20, 0, 1), 1)
    end

    if mode == "cp" then
        local levelText = tostring(level or GetPlayerChampionPointsEarned())
        self.currentMode = mode
        self.currentLevelText = levelText
        root.levelLabel:SetFont(string.format("$(BOLD_FONT)|%d|thick-outline", GetLevelFontSize(levelText, mode)))
        root.levelLabel:SetText(levelText)
        root.typeLabel:SetHidden(false)
        root.typeLabel:SetText("CHAMPION")
        root.icon:SetHidden(not ShouldShowChampionIcon())
        root.icon:SetTexture(info.icon)
        root.levelLabel:SetColor(0.95, 0.92, 0.84, 1)
    else
        local levelText = tostring(level or GetUnitLevel("player"))
        self.currentMode = mode
        self.currentLevelText = levelText
        root.levelLabel:SetFont(string.format("$(BOLD_FONT)|%d|thick-outline", GetLevelFontSize(levelText, mode)))
        root.levelLabel:SetText(levelText)
        root.typeLabel:SetHidden(false)
        root.typeLabel:SetText(GetString(SI_EXPERIENCE_LEVEL_LABEL) or "LEVEL")
        root.icon:SetHidden(true)
        root.levelLabel:SetColor(1, 1, 1, 1)
    end

    self:ApplyLayout()
end

function ExperienceTracker:SetBarValue(value, maxValue)
    local root = self:GetRoot()
    maxValue = math.max(tonumber(maxValue) or 1, 1)
    value = zo_clamp(tonumber(value) or 0, 0, maxValue)
    root.bar:SetMinMax(0, maxValue)
    root.bulk:SetMinMax(0, maxValue)
    root.gloss:SetMinMax(0, maxValue)
    root.enlightened:SetMinMax(0, maxValue)
    root.bar:SetValue(value)
    root.gloss:SetValue(value)
    root.progressLabel:SetText(FormatProgressText(value, maxValue))
    root.progressLabel:SetHidden(not ShouldShowProgressText())
end

function ExperienceTracker:RefreshEnlightened(mode, level, current, maxValue)
    local root = self:GetRoot()
    if mode ~= "cp" or not IsEnlightenedAvailableForCharacter or not IsEnlightenedAvailableForCharacter() then
        root.enlightened:SetHidden(true)
        return
    end

    local pool = GetEnlightenedPool and GetEnlightenedPool() or 0
    local multiplier = GetEnlightenedMultiplier and GetEnlightenedMultiplier() or 0
    local enlightenedPool = pool * (multiplier + 1)
    if enlightenedPool <= 0 then
        root.enlightened:SetHidden(true)
        return
    end

    maxValue = math.max(tonumber(maxValue) or 1, 1)
    root.enlightened:SetMinMax(0, maxValue)
    root.enlightened:SetValue(zo_min(maxValue, (current or 0) + enlightenedPool))
    root.enlightened:SetHidden(false)
end

function ExperienceTracker:ShowRoot()
    local root = self:GetRoot()
    if root:IsHidden() then
        root:SetAlpha(0)
        root:SetHidden(false)
    end
end

function ExperienceTracker:HideRoot()
    local root = self:GetRoot()
    root:SetHandler("OnUpdate", nil)
    root:SetAlpha(0)
    root:SetHidden(true)
    root.glow:SetAlpha(0)
    root.impactFlash:SetAlpha(0)
    root.barShockwave:SetAlpha(0)
    root.barShockwave:SetScale(1)
    root.barShockwave:SetHidden(true)
    root.badgeGlow:SetAlpha(1)
    root.badge:SetScale(1)
    root.levelLabel:SetScale(1)
    root.bulk:SetAlpha(0)
    root.bulk:SetHidden(true)
    root.levelBurst:SetAlpha(0)
    root.levelBurst:SetHidden(true)
    root.badgeBurst:SetAlpha(0)
    root.badgeBurst:SetScale(1)
    root.badgeBurst:SetHidden(true)
    for _, chunkPulse in ipairs(root.chunkPulses) do
        chunkPulse:SetAlpha(0)
        chunkPulse:SetHidden(true)
        chunkPulse.activeMS = nil
    end
    root.shine:SetHidden(true)
    root.rewardShine:SetAlpha(0)
    root.rewardShine:SetHidden(true)
    root.gainLabel:SetAlpha(0)
    root.gainLabel:SetScale(1)
    root.gainLabel:SetHidden(true)
    self.animation = nil
    self.segmentQueue = nil
end

function ExperienceTracker:BuildSegments(mode, level, previousXP, currentXP, maxValue)
    local segments = {}
    previousXP = math.max(tonumber(previousXP) or 0, 0)
    currentXP = math.max(tonumber(currentXP) or 0, 0)
    maxValue = tonumber(maxValue)
    if not maxValue or maxValue <= 0 then
        return segments
    end

    local segmentLevel = tonumber(level) or 0
    local startValue = zo_clamp(previousXP, 0, maxValue)
    local remainingGain = currentXP - previousXP
    if remainingGain <= 0 then
        return segments
    end

    while remainingGain > 0 do
        local room = maxValue - startValue
        if room <= 0 then
            segmentLevel = segmentLevel + 1
            maxValue = GetLevelSize(mode, segmentLevel) or maxValue
            startValue = 0
            room = maxValue
        end

        local delta = math.min(remainingGain, room)
        local stopValue = startValue + delta
        table.insert(segments, {
            mode = mode,
            level = segmentLevel,
            startValue = startValue,
            stopValue = stopValue,
            maxValue = maxValue,
            wraps = stopValue >= maxValue and remainingGain > delta,
        })

        remainingGain = remainingGain - delta
        if remainingGain > 0 then
            segmentLevel = segmentLevel + 1
            maxValue = GetLevelSize(mode, segmentLevel) or maxValue
            startValue = 0
        end
    end

    return segments
end

function ExperienceTracker:QueueSegments(segments, gainAmount, mode)
    if not segments or #segments == 0 then
        return
    end

    self.segmentQueue = segments
    self.totalGainAmount = gainAmount
    self.totalGainMode = mode
    self:ShowRoot()
    self:StartNextSegment()
end

function ExperienceTracker:ComputeChunkCount(segment)
    local maxValue = math.max(tonumber(segment.maxValue) or 1, 1)
    local delta = math.max((tonumber(segment.stopValue) or 0) - (tonumber(segment.startValue) or 0), 1)
    local ratio = zo_clamp(delta / maxValue, 0.04, 1)
    return ClampNumber(math.floor(2 + ratio * 12), MIN_CHUNKS, MAX_CHUNKS)
end

function ExperienceTracker:TriggerChunkPulse(segment, chunkIndex, chunkCount)
    local root = self:GetRoot()
    local pulses = root.chunkPulses
    if not pulses or #pulses == 0 then
        return
    end

    self.nextChunkPulseIndex = (self.nextChunkPulseIndex or 0) + 1
    if self.nextChunkPulseIndex > #pulses then
        self.nextChunkPulseIndex = 1
    end

    local pulse = pulses[self.nextChunkPulseIndex]
    local trackWidth = root.track:GetWidth()
    local chunkRatio = zo_clamp(chunkIndex / math.max(chunkCount, 1), 0, 1)
    local startRatio = segment.maxValue > 0 and segment.startValue / segment.maxValue or 0
    local stopRatio = segment.maxValue > 0 and segment.stopValue / segment.maxValue or 1
    local x = zo_lerp(startRatio, stopRatio, chunkRatio) * trackWidth

    pulse.activeMS = GetFrameTimeMilliseconds()
    pulse.baseX = x
    pulse:SetDimensions(6 + (4 * GetIntensity()), root.track:GetHeight() + 14)
    pulse:ClearAnchors()
    pulse:SetAnchor(CENTER, root.track, LEFT, x, 0)
    pulse:SetAlpha(0.85)
    pulse:SetHidden(false)

    local sound = GetChunkSound()
    if sound then
        PlaySound(sound)
    end
end

function ExperienceTracker:UpdateChunkPulses(nowMS)
    local root = self:GetRoot()
    if not root.chunkPulses then
        return
    end

    for _, pulse in ipairs(root.chunkPulses) do
        if pulse.activeMS then
            local progress = zo_clamp((nowMS - pulse.activeMS) / CHUNK_PULSE_MS, 0, 1)
            if progress >= 1 then
                pulse.activeMS = nil
                pulse:SetAlpha(0)
                pulse:SetHidden(true)
            else
                local alpha = zo_clamp((1 - progress) * (0.82 + 0.18 * GetIntensity()), 0, 1)
                local width = 6 + progress * (16 + 8 * GetIntensity())
                pulse:SetDimensions(width, root.track:GetHeight() + 14 + progress * 12)
                pulse:ClearAnchors()
                pulse:SetAnchor(CENTER, root.track, LEFT, pulse.baseX or 0, 0)
                pulse:SetAlpha(alpha)
            end
        end
    end
end

function ExperienceTracker:TriggerLevelUpTicks()
    local root = self:GetRoot()
    local pulses = root.chunkPulses
    if not pulses or #pulses == 0 then
        return
    end

    local intensity = GetIntensity() * GetLevelUpIntensity()
    if intensity <= 0 then
        return
    end

    local trackWidth = root.track:GetWidth()
    local pulseCount = math.min(3, #pulses)
    for index = 1, pulseCount do
        self.nextChunkPulseIndex = (self.nextChunkPulseIndex or 0) + 1
        if self.nextChunkPulseIndex > #pulses then
            self.nextChunkPulseIndex = 1
        end

        local pulse = pulses[self.nextChunkPulseIndex]
        pulse.activeMS = GetFrameTimeMilliseconds()
        pulse.baseX = trackWidth * zo_clamp(0.82 + index * 0.055, 0, 1)
        pulse:SetDimensions(10 + (6 * intensity), root.track:GetHeight() + 20)
        pulse:ClearAnchors()
        pulse:SetAnchor(CENTER, root.track, LEFT, pulse.baseX, 0)
        pulse:SetAlpha(1)
        pulse:SetHidden(false)
    end
end

function ExperienceTracker:StartNextSegment()
    local segment = self.segmentQueue and table.remove(self.segmentQueue, 1)
    if not segment then
        self:BeginHoldAndFade()
        return
    end

    local root = self:GetRoot()
    self:SetVisualMode(segment.mode, segment.level)
    self:SetBarValue(segment.startValue, segment.maxValue)
    self:RefreshEnlightened(segment.mode, segment.level, segment.startValue, segment.maxValue)

    local gainLabelText = self.totalGainMode == "cp"
        and string.format("+%s CP XP", FormatNumber(self.totalGainAmount or 0))
        or string.format("+%s XP", FormatNumber(self.totalGainAmount or 0))

    root.gainLabel:SetText(gainLabelText)
    root.gainLabel:SetHidden(not ShouldShowGainText())

    root.bulk:SetHidden(false)
    root.bulk:SetValue(segment.startValue)
    root.shine:SetHidden(false)
    root.impactFlash:SetAlpha(0.82 * GetIntensity())
    root.levelBurst:SetHidden(true)
    root.levelBurst:SetAlpha(0)

    local chunkCount = self:ComputeChunkCount(segment)

    self.animation =
    {
        type = "segment",
        segment = segment,
        chunkCount = chunkCount,
        lastChunkIndex = 0,
        startMS = GetFrameTimeMilliseconds(),
        durationMS = math.floor(SEGMENT_DURATION_MS * zo_lerp(1.12, 0.90, zo_clamp(GetIntensity(), 0, 1))),
    }

    root:SetHandler("OnUpdate", function()
        self:OnUpdate()
    end)
end

function ExperienceTracker:BeginHoldAndFade()
    local root = self:GetRoot()
    self.animation =
    {
        type = "hold",
        startMS = GetFrameTimeMilliseconds(),
        durationMS = math.max(GetVisibleDurationMS() - FADE_IN_MS - FADE_OUT_MS, 300),
    }
    root:SetHandler("OnUpdate", function()
        self:OnUpdate()
    end)
end

function ExperienceTracker:BeginLevelUpBurst(segment)
    local root = self:GetRoot()
    local intensity = GetIntensity() * GetLevelUpIntensity()
    root.bulk:SetHidden(false)
    if segment and segment.maxValue then
        root.bulk:SetValue(segment.maxValue)
        root.bar:SetValue(segment.maxValue)
        root.gloss:SetValue(segment.maxValue)
        root.progressLabel:SetText(FormatProgressText(segment.maxValue, segment.maxValue))
    end

    root.shine:SetHidden(false)
    root.rewardShine:SetHidden(false)
    root.levelBurst:SetHidden(false)
    root.badgeBurst:SetHidden(false)
    root.barShockwave:SetHidden(false)
    root.impactFlash:SetAlpha(1 * intensity)
    root.barShockwave:SetAlpha(0.90 * intensity)
    root.badgeGlow:SetAlpha(1)
    root.badge:SetScale(1)
    root.levelLabel:SetScale(1)
    self:TriggerLevelUpTicks()
    PlayLevelUpSound()

    self.animation =
    {
        type = "levelUpBurst",
        startMS = GetFrameTimeMilliseconds(),
        durationMS = math.floor(LEVEL_UP_BURST_DURATION_MS * zo_lerp(1.08, 0.92, zo_clamp(GetLevelUpIntensity(), 0, 1))),
        segment = segment,
    }
    root:SetHandler("OnUpdate", function()
        self:OnUpdate()
    end)
end

function ExperienceTracker:SettleToCurrent()
    local root = self:GetRoot()
    root:SetHandler("OnUpdate", nil)
    root.glow:SetAlpha(0)
    root.impactFlash:SetAlpha(0)
    root.barShockwave:SetAlpha(0)
    root.barShockwave:SetScale(1)
    root.barShockwave:SetHidden(true)
    root.badge:SetScale(1)
    root.levelLabel:SetScale(1)
    root.bulk:SetAlpha(0)
    root.bulk:SetHidden(true)
    root.shine:SetAlpha(0)
    root.shine:SetHidden(true)
    root.rewardShine:SetAlpha(0)
    root.rewardShine:SetHidden(true)
    root.levelBurst:SetAlpha(0)
    root.levelBurst:SetScale(1)
    root.levelBurst:SetHidden(true)
    root.badgeBurst:SetAlpha(0)
    root.badgeBurst:SetScale(1)
    root.badgeBurst:SetHidden(true)
    root.gainLabel:SetAlpha(0)
    root.gainLabel:SetScale(1)
    root.gainLabel:SetHidden(true)
    self.animation = nil
    self:UpdateVisibility()
end

function ExperienceTracker:OnUpdate()
    local animation = self.animation
    if not animation then
        return
    end

    local root = self:GetRoot()
    local nowMS = GetFrameTimeMilliseconds()
    local progress = zo_clamp((nowMS - animation.startMS) / animation.durationMS, 0, 1)
    local alpha = GetAlpha()
    self:UpdateChunkPulses(nowMS)

    if animation.type == "segment" then
        local segment = animation.segment
        local chunkCount = animation.chunkCount or MIN_CHUNKS
        local rawChunkPosition = progress * chunkCount
        local chunkIndex = math.floor(rawChunkPosition)
        local chunkLocalProgress = rawChunkPosition - chunkIndex
        if progress >= 1 then
            chunkIndex = chunkCount
            chunkLocalProgress = 1
        end
        local easedLocal = EaseOutBack(zo_clamp(chunkLocalProgress, 0, 1))
        local chunkedProgress = zo_clamp((chunkIndex + easedLocal) / chunkCount, 0, 1)
        local eased = EaseOutQuart(chunkedProgress)
        local value = zo_lerp(segment.startValue, segment.stopValue, eased)
        local pop = EaseOutBack(zo_clamp(progress / 0.24, 0, 1))
        local chunkPulse = Pulse01(zo_clamp(chunkLocalProgress, 0, 1))
        local glowAlpha = zo_clamp((0.24 + (1 - progress) * 0.48 + chunkPulse * 0.38) * GetIntensity(), 0, 1)
        local bulkAlpha = zo_clamp((0.42 + chunkPulse * 0.38 - progress * 0.18) * GetIntensity(), 0, 0.92)
        local impactAlpha = zo_clamp((1 - zo_clamp((nowMS - animation.startMS) / IMPACT_FLASH_MS, 0, 1)) * 0.74 * GetIntensity(), 0, 0.74)
        local shineX = zo_lerp(0, root.track:GetWidth(), eased)

        if chunkIndex > (animation.lastChunkIndex or 0) and chunkIndex <= chunkCount then
            for index = (animation.lastChunkIndex or 0) + 1, chunkIndex do
                self:TriggerChunkPulse(segment, index, chunkCount)
            end
            animation.lastChunkIndex = chunkIndex
            root.impactFlash:SetAlpha(math.max(root.impactFlash:GetAlpha(), 0.42 * GetIntensity()))
        end

        root:SetAlpha(zo_min(alpha, progress < 0.16 and alpha * (progress / 0.16) or alpha))
        root.glow:SetAlpha(glowAlpha)
        root.badgeGlow:SetAlpha(zo_clamp(0.78 + glowAlpha * 0.38 + chunkPulse * 0.18, 0, 1))
        root.impactFlash:SetAlpha(math.max(root.impactFlash:GetAlpha() * 0.78, impactAlpha))
        root.bulk:SetAlpha(bulkAlpha)
        root.bulk:SetValue(value)
        root.bar:SetValue(value)
        root.gloss:SetValue(value)
        root.progressLabel:SetText(FormatProgressText(value, segment.maxValue))
        root.gainLabel:SetAlpha(ShouldShowGainText() and zo_clamp(pop, 0, 1) or 0)
        root.gainLabel:SetScale(zo_lerp(1.28, 1, zo_clamp(progress / 0.34, 0, 1)) + (chunkPulse * 0.06 * GetIntensity()))
        root.shine:ClearAnchors()
        root.shine:SetAnchor(LEFT, root.track, LEFT, shineX - (root.shine:GetWidth() * 0.5), 0)
        root.shine:SetAlpha(zo_clamp((0.14 + chunkPulse * 0.42 + (1 - math.abs(progress - 0.52) / 0.36) * 0.36) * GetIntensity(), 0, 0.82))

        if progress >= 1 then
            if segment.wraps then
                if ShouldPlayLevelUpAnimation() then
                    self:BeginLevelUpBurst(segment)
                else
                    PlayLevelUpSound()
                    self:StartNextSegment()
                end
            else
                self:StartNextSegment()
            end
        end
    elseif animation.type == "levelUpBurst" then
        local intensity = GetIntensity() * GetLevelUpIntensity()
        local impact = 1 - zo_clamp(progress / 0.18, 0, 1)
        local sweep = Pulse01(zo_clamp((progress - 0.10) / 0.48, 0, 1))
        local burst = Pulse01(zo_clamp((progress - 0.18) / 0.56, 0, 1))
        local afterglow = 1 - zo_clamp((progress - 0.58) / 0.42, 0, 1)
        local shineTravel = zo_clamp((progress - 0.08) / 0.62, 0, 1)
        local trackWidth = root.track:GetWidth()
        local rewardX = zo_lerp(-root.rewardShine:GetWidth(), trackWidth + root.rewardShine:GetWidth() * 0.35, EaseOutCubic(shineTravel))

        root:SetAlpha(alpha)
        root.glow:SetAlpha(zo_clamp((impact * 0.95 + sweep * 0.80 + afterglow * 0.35) * intensity, 0, 1))
        root.badgeGlow:SetAlpha(zo_clamp((0.88 + impact * 0.30 + burst * 0.24) * intensity, 0, 1))
        root.impactFlash:SetAlpha(zo_clamp(impact * 1.15 * intensity, 0, 1))
        root.barShockwave:SetHidden(false)
        root.barShockwave:SetAlpha(zo_clamp((impact * 0.86 + burst * 0.42) * intensity, 0, 0.92))
        root.barShockwave:SetScale(1 + progress * 0.22)
        root.bulk:SetAlpha(zo_clamp((0.74 + sweep * 0.22) * afterglow * intensity, 0, 1))
        root.gainLabel:SetAlpha(ShouldShowGainText() and zo_clamp((0.92 + impact * 0.30) * intensity, 0, 1) or 0)
        root.gainLabel:SetScale(1 + (impact * 0.34 + burst * 0.18) * intensity)
        root.badge:SetScale(1 + (impact * 0.18 + burst * 0.10) * intensity)
        root.levelLabel:SetScale(1 + (impact * 0.14 + burst * 0.08) * intensity)
        root.levelBurst:SetHidden(false)
        root.levelBurst:SetAlpha(zo_clamp((burst * 0.92 + impact * 0.18) * intensity, 0, 0.92))
        root.levelBurst:SetScale(1 + progress * 0.42)
        root.badgeBurst:SetHidden(false)
        root.badgeBurst:SetAlpha(zo_clamp((burst * 0.95 + impact * 0.35) * intensity, 0, 0.95))
        root.badgeBurst:SetScale(1 + progress * 0.78)
        root.shine:SetAlpha(zo_clamp((impact * 0.45 + sweep * 0.42) * intensity, 0, 0.85))
        root.rewardShine:SetHidden(false)
        root.rewardShine:ClearAnchors()
        root.rewardShine:SetAnchor(LEFT, root.track, LEFT, rewardX, 0)
        root.rewardShine:SetAlpha(zo_clamp((sweep * 0.95 + impact * 0.20) * intensity, 0, 1))
        if progress >= 1 then
            root.barShockwave:SetAlpha(0)
            root.barShockwave:SetScale(1)
            root.barShockwave:SetHidden(true)
            root.levelBurst:SetHidden(true)
            root.levelBurst:SetScale(1)
            root.badgeBurst:SetAlpha(0)
            root.badgeBurst:SetScale(1)
            root.badgeBurst:SetHidden(true)
            root.rewardShine:SetAlpha(0)
            root.rewardShine:SetHidden(true)
            root.badge:SetScale(1)
            root.levelLabel:SetScale(1)
            self:StartNextSegment()
        end
    elseif animation.type == "hold" then
        root:SetAlpha(alpha)
        root.glow:SetAlpha(zo_clamp((1 - progress) * 0.28 * GetIntensity(), 0, 0.28))
        root.badgeGlow:SetAlpha(1)
        root.impactFlash:SetAlpha(0)
        root.bulk:SetAlpha(0)
        root.shine:SetAlpha(0)
        root.gainLabel:SetAlpha(ShouldShowGainText() and zo_clamp(1 - progress * 1.35, 0, 1) or 0)
        if progress >= 1 then
            if IsAlwaysVisible() then
                self:SettleToCurrent()
            else
                self.animation = {
                    type = "fadeOut",
                    startMS = nowMS,
                    durationMS = FADE_OUT_MS,
                }
            end
        end
    elseif animation.type == "fadeOut" then
        root:SetAlpha(alpha * (1 - progress))
        root.glow:SetAlpha(0)
        root.gainLabel:SetAlpha(0)
        if progress >= 1 then
            self:HideRoot()
            self:UpdateVisibility()
        end
    end
end

function ExperienceTracker:ShowExperienceGain(mode, level, previousXP, currentXP, championPoints, forceShow)
    if not IsModuleEnabled() or (not forceShow and not IsHudSceneShowing()) then
        return
    end

    local nowMS = GetFrameTimeMilliseconds()
    if self.lastGainMS and nowMS - self.lastGainMS < MIN_GAIN_INTERVAL_MS then
        return
    end
    self.lastGainMS = nowMS

    local maxValue
    if mode == "cp" then
        level = championPoints or level or GetPlayerChampionPointsEarned()
        maxValue = GetNumChampionXPInChampionPoint(level)
    else
        level = level or GetUnitLevel("player")
        maxValue = GetNumExperiencePointsInLevel(level)
    end

    if not maxValue or maxValue <= 0 or not previousXP or not currentXP or currentXP <= previousXP then
        return
    end

    local segments = self:BuildSegments(mode, level, previousXP, currentXP, maxValue)
    self:QueueSegments(segments, currentXP - previousXP, mode)
end

function ExperienceTracker:OnExperienceGain(reason, level, previousExperience, currentExperience, championPoints)
    local mode = "xp"
    if CanUnitGainChampionPoints("player") and GetNumChampionXPInChampionPoint(championPoints) ~= nil then
        mode = "cp"
    end
    self:ShowExperienceGain(mode, level, previousExperience, currentExperience, championPoints, false)
end

function ExperienceTracker:OnDiscoveryExperience(_areaName, level, previousExperience, currentExperience, championPoints)
    self:OnExperienceGain(nil, level, previousExperience, currentExperience, championPoints)
end

function ExperienceTracker:OnExperienceUpdate(unitTag, currentExp, maxExp)
    if unitTag ~= "player" or not IsModuleEnabled() then
        return
    end
    self.lastKnownXP = currentExp
    self.lastKnownXPMax = maxExp
    if IsAlwaysVisible() and not self.animation then
        self:UpdateVisibility()
    end
end

function ExperienceTracker:OnChampionPointGained(pointDelta)
    if not IsModuleEnabled() or not IsHudSceneShowing() or (tonumber(pointDelta) or 0) <= 0 then
        return
    end

    local endingPoints = GetPlayerChampionPointsEarned()
    if not self.animation then
        self:PreviewCPFlash(endingPoints, pointDelta)
    end
end

function ExperienceTracker:PreviewCPFlash(level, pointDelta)
    local root = self:GetRoot()
    self:ShowRoot()
    self:SetVisualMode("cp", level or GetPlayerChampionPointsEarned())
    self:SetBarValue(1, 1)
    root.gainLabel:SetText(string.format("+%s Champion Point", FormatNumber(pointDelta or 1)))
    root.gainLabel:SetHidden(not ShouldShowGainText())
    root.gainLabel:SetAlpha(1)
    if not ShouldPlayLevelUpAnimation() then
        PlayLevelUpSound()
        self.animation =
        {
            type = "hold",
            startMS = GetFrameTimeMilliseconds(),
            durationMS = math.max(GetVisibleDurationMS() - FADE_OUT_MS, 600),
        }
        root:SetHandler("OnUpdate", function()
            self:OnUpdate()
        end)
        return
    end

    self:BeginLevelUpBurst({
        mode = "cp",
        level = level or GetPlayerChampionPointsEarned(),
        startValue = 0,
        stopValue = 1,
        maxValue = 1,
    })
end

function ExperienceTracker:GetCurrentSnapshot()
    if CanUnitGainChampionPoints("player") then
        local level = GetPlayerChampionPointsEarned()
        local current = GetPlayerChampionXP()
        local maxValue = GetNumChampionXPInChampionPoint(level)
        if maxValue then
            return "cp", level, current, maxValue
        end
    end

    local level = GetUnitLevel("player")
    local current = GetUnitXP("player")
    local maxValue = GetNumExperiencePointsInLevel(level) or GetUnitXPMax("player")
    return "xp", level, current, maxValue
end

function ExperienceTracker:PreviewGain()
    local mode, level, current, maxValue = self:GetCurrentSnapshot()
    maxValue = math.max(tonumber(maxValue) or 1, 1)
    local previous = zo_clamp(current or math.floor(maxValue * 0.28), 0, maxValue - 1)
    local gain = math.max(math.floor(maxValue * 0.18), 1)
    local currentPreview = previous + gain
    self:ShowExperienceGain(mode, level, previous, currentPreview, mode == "cp" and level or nil, true)
end

function ExperienceTracker:PreviewBigGain()
    local mode, level, current, maxValue = self:GetCurrentSnapshot()
    maxValue = math.max(tonumber(maxValue) or 1, 1)
    local previous = math.floor(maxValue * 0.78)
    local currentPreview = previous + math.floor(maxValue * 0.62)
    self:ShowExperienceGain(mode, level, previous, currentPreview, mode == "cp" and level or nil, true)
end

function ExperienceTracker:PreviewCPGain()
    local level = GetPlayerChampionPointsEarned and GetPlayerChampionPointsEarned() or 120
    local maxValue = GetNumChampionXPInChampionPoint(level) or 400000
    local previous = math.floor(maxValue * 0.36)
    local current = previous + math.floor(maxValue * 0.22)
    self:ShowExperienceGain("cp", level, previous, current, level, true)
end

function ExperienceTracker:PreviewChunkSound()
    local sound = GetChunkSound()
    if sound then
        PlaySound(sound)
    end
end

function ExperienceTracker:PreviewLevelUpSound()
    local sound = GetLevelUpSound()
    if sound then
        PlaySound(sound)
    end
end

function ExperienceTracker:UpdateVisibility()
    if not IsModuleEnabled() then
        self:HideRoot()
        self:GetMover():SetHidden(true)
        return
    end

    self:ApplyLayout()
    if IsModuleUnlocked() or (IsAlwaysVisible() and IsHudSceneShowing()) then
        local mode, level, current, maxValue = self:GetCurrentSnapshot()
        self:SetVisualMode(mode, level)
        self:SetBarValue(current or 0, maxValue or 1)
        self:RefreshEnlightened(mode, level, current or 0, maxValue or 1)
        self:GetRoot():SetAlpha(GetAlpha())
        self:GetRoot():SetHidden(false)
    elseif IsAlwaysVisible() and not IsHudSceneShowing() and not self.animation then
        self:GetRoot():SetHidden(true)
    elseif not self.animation then
        self:GetRoot():SetHidden(true)
    end
end

function ExperienceTracker:CanSuppressStockProgressBar()
    return ShouldHideStockProgressBar() and IsHudSceneShowing()
end

function ExperienceTracker:HideStockProgressBar()
    if ZO_PlayerProgress and self:CanSuppressStockProgressBar() then
        ZO_PlayerProgress:SetHidden(true)
        ZO_PlayerProgress:SetAlpha(0)
    end
end

function ExperienceTracker:CallPlayerProgressOriginal(originalMethod, progressBar, ...)
    local result1, result2, result3 = originalMethod(progressBar, ...)
    if self:CanSuppressStockProgressBar() then
        self:HideStockProgressBar()
    end
    return result1, result2, result3
end

function ExperienceTracker:InstallStockHooks()
    if self.stockHooksInstalled then
        return true
    end
    if not PLAYER_PROGRESS_BAR then
        return false
    end

    self.originalPlayerProgressShow = PLAYER_PROGRESS_BAR.Show
    self.originalPlayerProgressShowIncrease = PLAYER_PROGRESS_BAR.ShowIncrease
    self.originalPlayerProgressShowCurrent = PLAYER_PROGRESS_BAR.ShowCurrent
    self.originalPlayerProgressRefreshCurrentBar = PLAYER_PROGRESS_BAR.RefreshCurrentBar

    PLAYER_PROGRESS_BAR.Show = function(progressBar, ...)
        return ExperienceTracker:CallPlayerProgressOriginal(ExperienceTracker.originalPlayerProgressShow, progressBar, ...)
    end

    PLAYER_PROGRESS_BAR.ShowIncrease = function(progressBar, ...)
        return ExperienceTracker:CallPlayerProgressOriginal(ExperienceTracker.originalPlayerProgressShowIncrease, progressBar, ...)
    end

    PLAYER_PROGRESS_BAR.ShowCurrent = function(progressBar, ...)
        return ExperienceTracker:CallPlayerProgressOriginal(ExperienceTracker.originalPlayerProgressShowCurrent, progressBar, ...)
    end

    PLAYER_PROGRESS_BAR.RefreshCurrentBar = function(progressBar, ...)
        return ExperienceTracker:CallPlayerProgressOriginal(ExperienceTracker.originalPlayerProgressRefreshCurrentBar, progressBar, ...)
    end

    self.stockHooksInstalled = true
    return true
end

function ExperienceTracker:StartStockHookWhenReady()
    if self:InstallStockHooks() then
        return
    end

    local attempts = 0
    EVENT_MANAGER:RegisterForUpdate(EVENT_NAMESPACE .. "_StockHook", STOCK_HOOK_RETRY_MS, function()
        attempts = attempts + 1
        if self:InstallStockHooks() or attempts >= MAX_STOCK_HOOK_ATTEMPTS then
            EVENT_MANAGER:UnregisterForUpdate(EVENT_NAMESPACE .. "_StockHook")
        end
    end)
end

function ExperienceTracker:RegisterEvents()
    if self.eventsRegistered then
        return
    end

    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_EXPERIENCE_GAIN, function(_, ...)
        self:OnExperienceGain(...)
    end)
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE .. "_Discovery", EVENT_DISCOVERY_EXPERIENCE, function(_, ...)
        self:OnDiscoveryExperience(...)
    end)
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE .. "_Update", EVENT_EXPERIENCE_UPDATE, function(_, ...)
        self:OnExperienceUpdate(...)
    end)
    EVENT_MANAGER:AddFilterForEvent(EVENT_NAMESPACE .. "_Update", EVENT_EXPERIENCE_UPDATE, REGISTER_FILTER_UNIT_TAG, "player")
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE .. "_CPGained", EVENT_CHAMPION_POINT_GAINED, function(_, ...)
        self:OnChampionPointGained(...)
    end)
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE .. "_Activated", EVENT_PLAYER_ACTIVATED, function()
        self:RefreshSettings()
    end)
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE .. "_ScreenResized", EVENT_SCREEN_RESIZED, function()
        self:ApplyLayout()
    end)
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE .. "_Gamepad", EVENT_GAMEPAD_PREFERRED_MODE_CHANGED, function()
        self:ApplyLayout()
    end)

    if HUD_SCENE then
        HUD_SCENE:RegisterCallback("StateChange", function()
            self:HideStockProgressBar()
            self:UpdateVisibility()
        end)
    end

    if HUD_UI_SCENE then
        HUD_UI_SCENE:RegisterCallback("StateChange", function()
            self:HideStockProgressBar()
            self:UpdateVisibility()
        end)
    end

    self.eventsRegistered = true
end

function ExperienceTracker:RefreshSettings()
    self:GetRoot()
    self:GetMover()
    self:ApplyLayout()
    self:StartStockHookWhenReady()
    self:HideStockProgressBar()
    self:UpdateVisibility()
end

local DEBUG_COMMANDS =
{
    ["/nsxp"] = function()
        ExperienceTracker:PreviewGain()
    end,
    ["/nsxpbig"] = function()
        ExperienceTracker:PreviewBigGain()
    end,
    ["/nsxpcp"] = function()
        ExperienceTracker:PreviewCPGain()
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

function ExperienceTracker:RefreshDebugCommands()
    RegisterDebugCommands()
end

local function OnAddOnLoaded(_, addonName)
    if addonName ~= ADDON_NAME then
        return
    end

    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE .. "_Loaded", EVENT_ADD_ON_LOADED)
    ExperienceTracker:RegisterEvents()
    ExperienceTracker:RefreshSettings()
    RegisterDebugCommands()
    zo_callLater(function() ExperienceTracker:RefreshSettings() end, 1000)
end

EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE .. "_Loaded", EVENT_ADD_ON_LOADED, OnAddOnLoaded)
