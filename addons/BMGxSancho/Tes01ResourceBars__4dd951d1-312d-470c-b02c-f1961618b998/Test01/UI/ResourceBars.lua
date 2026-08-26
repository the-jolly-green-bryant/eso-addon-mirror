local T = Test01
T.ResourceBars = T.ResourceBars or {}
local RB = T.ResourceBars
local WM = WINDOW_MANAGER
local C = T.Constants

local RESOURCE_KEYS = { "health", "magicka", "stamina", "shield" }

local POWER_HEALTH = COMBAT_MECHANIC_FLAGS_HEALTH or POWERTYPE_HEALTH
local POWER_MAGICKA = COMBAT_MECHANIC_FLAGS_MAGICKA or POWERTYPE_MAGICKA
local POWER_STAMINA = COMBAT_MECHANIC_FLAGS_STAMINA or POWERTYPE_STAMINA

local POWER_TO_KEY = {}
if POWER_HEALTH ~= nil then POWER_TO_KEY[POWER_HEALTH] = "health" end
if POWER_MAGICKA ~= nil then POWER_TO_KEY[POWER_MAGICKA] = "magicka" end
if POWER_STAMINA ~= nil then POWER_TO_KEY[POWER_STAMINA] = "stamina" end

local FALLBACK_COLORS = {
    health = { 0.72, 0.08, 0.09, 1 },
    magicka = { 0.10, 0.40, 0.88, 1 },
    stamina = { 0.13, 0.66, 0.27, 1 },
    shield = { 0.64, 0.88, 1.00, 1 },
}
local LABELS = {
    health = "HEALTH",
    magicka = "MAGICKA",
    stamina = "STAMINA",
    shield = "SHIELD",
}
local POWER_TYPES = {
    health = POWER_HEALTH,
    magicka = POWER_MAGICKA,
    stamina = POWER_STAMINA,
}

-- One transient interpolator is shared by all four bars. It runs only while a
-- displayed resource amount or max-resource-driven length is changing, then
-- unregisters itself immediately. There is no permanent Resource Bars loop.
local SMOOTH_UPDATE_MS = 50
local SMOOTH_RESPONSE = 0.42
local LENGTH_RESPONSE = 0.30
local SMOOTH_EPSILON = 0.0015
local LENGTH_EPSILON = 0.35
local SMOOTH_EVENT = "Test01ResourceBarsSmooth"
-- Shared physical sizing standard. At 100% UI scale, a configured Length of
-- 350 represents 30,000 maximum resource. All auto-sized bars use the same
-- denominator so relative resource pools are immediately visible.
local STANDARD_RESOURCE_AMOUNT = 30000
local STANDARD_RESOURCE_LENGTH = 350
local MIN_AUTO_LENGTH = 100
local MAX_AUTO_LENGTH = 650

-- Footer text is anchored to the straight resource axis rather than the
-- apparent center of the bowed artwork. The correction is mirrored by side.
local function GetFooterCenterCorrection(saved)
    local depth = zo_clamp(tonumber(saved and saved.crescentDepth) or 3, 1, 5)
    local amount = 4 + (depth * 2)
    return (saved and saved.crescentSide == "LEFT") and amount or -amount
end

local function FormatInteger(value)
    value = zo_round(tonumber(value) or 0)
    if ZO_CommaDelimitNumber then return ZO_CommaDelimitNumber(value) end
    return tostring(value)
end

local function Clamp01(value)
    return zo_clamp(tonumber(value) or 0, 0, 1)
end

local function CreateLabel(parent, font)
    local label = WM:CreateControl(nil, parent, CT_LABEL)
    label:SetFont(font)
    label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    label:SetColor(unpack(C.WHITE))
    return label
end

local function CreateBackdrop(parent)
    local bg = WM:CreateControl(nil, parent, CT_BACKDROP)
    bg:SetAnchorFill()
    bg:SetCenterColor(0.012, 0.014, 0.020, 0.76)
    bg:SetEdgeColor(0.13, 0.14, 0.17, 0.96)
    bg:SetEdgeTexture("EsoUI/Art/Tooltips/UI-SliderBackdrop.dds", 1, 1, 2)
    return bg
end

local function UnpackColorDef(colorDef, fallback)
    if colorDef and colorDef.UnpackRGBA then
        local r, g, b, a = colorDef:UnpackRGBA()
        return r, g, b, a
    end
    return fallback[1], fallback[2], fallback[3], fallback[4]
end

function RB:GetSaved()
    return T.saved and T.saved.resourceBars
end

function RB:IsActive()
    local saved = self:GetSaved()
    return saved and saved.enabled == true
end

function RB:GetBarSaved(key)
    local saved = self:GetSaved()
    return saved and saved[key] or nil
end

function RB:GetTexturePath(kind, depth)
    depth = zo_clamp(tonumber(depth) or 3, 1, 5)
    return string.format("Test01/UI/Textures/crescent_%s_%d.dds", kind, depth)
end

function RB:GetNativePaletteColor(key, index)
    local fallback = FALLBACK_COLORS[key] or C.WHITE
    local powerType = POWER_TYPES[key]
    local gradients = ZO_POWER_BAR_GRADIENT_COLORS
    local gradient = powerType and gradients and gradients[powerType] or nil
    local colorDef = gradient and gradient[index or 2] or nil
    return UnpackColorDef(colorDef, fallback)
end

function RB:ApplyResourcePalette(key)
    local bar = self.bars[key]
    if not bar then return end
    local r, g, b = self:GetNativePaletteColor(key, 2)
    local hr, hg, hb = self:GetNativePaletteColor(key, 3)
    bar.fill:SetColor(r, g, b, 1)
    bar.glow:SetColor(r, g, b, 0.38)
    bar.leading:SetColor(hr, hg, hb, 0.90)
    bar.horizontalFill:SetColor(r, g, b, 1)
end

function RB:GetShieldValue()
    if POWER_HEALTH == nil or not GetUnitAttributeVisualizerEffectInfo then return 0 end
    local value = GetUnitAttributeVisualizerEffectInfo("player", ATTRIBUTE_VISUAL_POWER_SHIELDING, STAT_MITIGATION, ATTRIBUTE_HEALTH, POWER_HEALTH)
    return math.max(0, tonumber(value) or 0)
end

function RB:ReadResource(key)
    if key == "shield" then
        local shield = self:GetShieldValue()
        local bar = self.bars and self.bars.shield or nil
        if bar then
            if shield <= 0 then
                bar.shieldCapacity = 0
            elseif not bar.shieldCapacity or bar.shieldCapacity <= 0 or shield > bar.shieldCapacity then
                -- Capture the peak aggregate shield for the current shield
                -- application. The physical bar length represents this capacity
                -- while the fill independently drains as shielding is consumed.
                bar.shieldCapacity = shield
            end
            return shield, math.max(1, tonumber(bar.shieldCapacity) or shield or 1)
        end
        return shield, math.max(1, shield)
    end
    local powerType = POWER_TYPES[key]
    if powerType == nil then return 0, 1 end
    local current, maximum = GetUnitPower("player", powerType)
    return tonumber(current) or 0, math.max(1, tonumber(maximum) or 1)
end

function RB:GetValueText(current, maximum)
    local saved = self:GetSaved()
    local mode = saved and saved.valueDisplay or "PERCENT"
    if mode == "NONE" then return "" end
    if mode == "NUMBERS" then return FormatInteger(current) end
    local pct = maximum > 0 and zo_round((current / maximum) * 100) or 0
    return tostring(zo_clamp(pct, 0, 999)) .. "%"
end

function RB:CreateBar(key)
    local control = WM:CreateTopLevelWindow("Test01ResourceBar_" .. key)
    control:SetHidden(true)
    control:SetClampedToScreen(true)
    control:SetMouseEnabled(false)
    control:SetMovable(false)

    local crescentBody = WM:CreateControl(nil, control, CT_CONTROL)
    local glow = WM:CreateControl(nil, crescentBody, CT_TEXTURE)
    local background = WM:CreateControl(nil, crescentBody, CT_TEXTURE)
    local fill = WM:CreateControl(nil, crescentBody, CT_TEXTURE)
    local leading = WM:CreateControl(nil, crescentBody, CT_TEXTURE)
    local frame = WM:CreateControl(nil, crescentBody, CT_TEXTURE)

    local label = CreateLabel(control, "$(BOLD_FONT)|14|soft-shadow-thin")
    local value = CreateLabel(control, "$(BOLD_FONT)|18|thick-outline")

    background:SetColor(0.018, 0.020, 0.028, 0.90)
    frame:SetColor(1, 1, 1, 0.96)
    glow:SetBlendMode(TEX_BLEND_MODE_ADD)
    leading:SetBlendMode(TEX_BLEND_MODE_ADD)

    local horizontalBg = CreateBackdrop(control)
    local horizontalTrack = WM:CreateControl(nil, control, CT_TEXTURE)
    horizontalTrack:SetColor(0.025, 0.030, 0.042, 0.96)
    local horizontalFill = WM:CreateControl(nil, control, CT_TEXTURE)

    local fragment = ZO_HUDFadeSceneFragment:New(control, nil, 0)
    HUD_SCENE:AddFragment(fragment)
    HUD_UI_SCENE:AddFragment(fragment)
    fragment:SetHiddenForReason("Test01ResourceBars", true, 0, 0)

    self.bars[key] = {
        key = key,
        control = control,
        crescentBody = crescentBody,
        glow = glow,
        background = background,
        fill = fill,
        leading = leading,
        frame = frame,
        label = label,
        value = value,
        horizontalBg = horizontalBg,
        horizontalTrack = horizontalTrack,
        horizontalFill = horizontalFill,
        fragment = fragment,
        previewScene = nil,
        current = 0,
        maximum = 1,
        targetPercent = 0,
        displayPercent = 0,
        lastRenderedPercent = -1,
        shieldCapacity = 0,
        targetLength = nil,
        displayLength = nil,
        lastAppliedLength = nil,
    }
    self:ApplyResourcePalette(key)
end

function RB:GetDynamicLengthTarget(key, maximum)
    local saved = self:GetBarSaved(key)
    if not saved then return STANDARD_RESOURCE_LENGTH end
    local configuredLength = zo_clamp(tonumber(saved.length) or STANDARD_RESOURCE_LENGTH, 140, 520)
    if saved.dynamicMaxSize == false then return configuredLength end

    maximum = math.max(0, tonumber(maximum) or 0)
    if maximum <= 0 then return MIN_AUTO_LENGTH end

    -- The Length slider defines how long a 30,000-resource bar should be.
    -- Every resource uses this same scale instead of creating its own login
    -- reference, so 31k Stamina is visibly longer than 26k Health, etc.
    local target = configuredLength * (maximum / STANDARD_RESOURCE_AMOUNT)
    return zo_clamp(target, MIN_AUTO_LENGTH, MAX_AUTO_LENGTH)
end

function RB:ApplyEffectiveLength(key, effectiveLength, forceRender)
    local bar = self.bars[key]
    local saved = self:GetBarSaved(key)
    if not bar or not saved then return end
    effectiveLength = zo_clamp(tonumber(effectiveLength) or tonumber(saved.length) or 320, 110, 650)
    if not forceRender and bar.lastAppliedLength and math.abs(bar.lastAppliedLength - effectiveLength) < 0.25 then return end
    bar.lastAppliedLength = effectiveLength

    local layout = saved.layout or "CRESCENT"
    local thickness = zo_clamp(tonumber(saved.thickness) or 34, 14, 72)
    if layout == "HORIZONTAL" then
        bar.control:SetDimensions(effectiveLength, thickness + 30)
        bar.horizontalBg:SetDimensions(effectiveLength, thickness)
        bar.label:SetDimensions(math.floor(effectiveLength * 0.55), 20)
        bar.value:SetDimensions(math.floor(effectiveLength * 0.42), 20)
    else
        local width = math.max(86, thickness + 70)
        local footerHeight = 44
        bar.control:SetDimensions(width, effectiveLength + footerHeight)
        bar.crescentBody:SetDimensions(width, effectiveLength)
        bar.label:SetDimensions(width, 18)
        bar.value:SetDimensions(width, 22)
    end
    self:RenderPercent(key, bar.displayPercent or bar.targetPercent or 0, true)
end

function RB:ApplyFooterLayout(key)
    local bar = self.bars[key]
    local saved = self:GetBarSaved(key)
    local globalSaved = self:GetSaved()
    if not bar or not saved or not globalSaved then return end
    local showNames = globalSaved.showNames == true
    local layout = saved.layout or "CRESCENT"
    bar.label:SetHidden(not showNames)

    if layout == "HORIZONTAL" then
        if showNames then
            bar.label:ClearAnchors(); bar.label:SetAnchor(BOTTOMLEFT, bar.horizontalBg, TOPLEFT, 4, -1)
            bar.label:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        end
        bar.value:ClearAnchors(); bar.value:SetAnchor(BOTTOMRIGHT, bar.horizontalBg, TOPRIGHT, -4, -1)
        bar.value:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    else
        local centerX = GetFooterCenterCorrection(saved)
        bar.label:ClearAnchors(); bar.label:SetAnchor(TOP, bar.crescentBody, BOTTOM, centerX, 2)
        bar.label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        bar.value:ClearAnchors()
        if showNames then
            bar.value:SetAnchor(TOP, bar.label, BOTTOM, 0, -1)
        else
            bar.value:SetAnchor(TOP, bar.crescentBody, BOTTOM, centerX, 4)
        end
        bar.value:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    end
end

function RB:ApplyBarLayout(key)
    local bar = self.bars[key]
    local saved = self:GetBarSaved(key)
    if not bar or not saved then return end

    local layout = saved.layout or "CRESCENT"
    local scale = tonumber(saved.scale) or 1
    local opacity = zo_clamp(tonumber(saved.opacity) or 0.92, 0.05, 1)
    local baseLength = zo_clamp(tonumber(saved.length) or 320, 140, 520)
    local thickness = zo_clamp(tonumber(saved.thickness) or 34, 14, 72)
    local depth = zo_clamp(tonumber(saved.crescentDepth) or 3, 1, 5)
    local side = saved.crescentSide or "RIGHT"
    local effectiveLength = bar.displayLength or baseLength

    bar.control:ClearAnchors()
    bar.control:SetAnchor(CENTER, GuiRoot, CENTER, saved.offsetX or 0, saved.offsetY or 0)
    bar.control:SetScale(scale)
    bar.control:SetAlpha(opacity)

    if layout == "HORIZONTAL" then
        bar.crescentBody:SetHidden(true)
        bar.glow:SetHidden(true)
        bar.background:SetHidden(true)
        bar.fill:SetHidden(true)
        bar.leading:SetHidden(true)
        bar.frame:SetHidden(true)
        bar.horizontalBg:SetHidden(false)
        bar.horizontalTrack:SetHidden(false)
        bar.horizontalFill:SetHidden(false)

        bar.horizontalBg:ClearAnchors(); bar.horizontalBg:SetAnchor(TOPLEFT, bar.control, TOPLEFT, 0, 18)
        bar.horizontalTrack:ClearAnchors(); bar.horizontalTrack:SetAnchor(TOPLEFT, bar.horizontalBg, TOPLEFT, 2, 2); bar.horizontalTrack:SetAnchor(BOTTOMRIGHT, bar.horizontalBg, BOTTOMRIGHT, -2, -2)
        bar.horizontalFill:ClearAnchors(); bar.horizontalFill:SetAnchor(LEFT, bar.horizontalBg, LEFT, 2, 0)
        bar.horizontalFill:SetHeight(math.max(1, thickness - 4))
    else
        local width = math.max(86, thickness + 70)
        bar.crescentBody:SetHidden(false)
        bar.crescentBody:ClearAnchors(); bar.crescentBody:SetAnchor(TOP, bar.control, TOP, 0, 0)
        bar.glow:SetHidden(false)
        bar.background:SetHidden(false)
        bar.fill:SetHidden(false)
        bar.leading:SetHidden(false)
        bar.frame:SetHidden(false)
        bar.horizontalBg:SetHidden(true)
        bar.horizontalTrack:SetHidden(true)
        bar.horizontalFill:SetHidden(true)

        local fillPath = self:GetTexturePath("fill", depth)
        local glowPath = self:GetTexturePath("glow", depth)
        local framePath = self:GetTexturePath("frame", depth)
        bar.background:SetTexture(fillPath)
        bar.fill:SetTexture(fillPath)
        bar.leading:SetTexture(fillPath)
        bar.glow:SetTexture(glowPath)
        bar.frame:SetTexture(framePath)

        local mirror = side == "LEFT"
        local left, right = mirror and 1 or 0, mirror and 0 or 1
        for _, texture in ipairs({bar.background, bar.glow, bar.frame}) do
            texture:SetTextureCoords(left, right, 0, 1)
            texture:ClearAnchors(); texture:SetAnchorFill(bar.crescentBody)
        end
    end

    bar.label:SetText(LABELS[key])
    self:ApplyEffectiveLength(key, effectiveLength, true)
    self:ApplyFooterLayout(key)
    self:ApplyResourcePalette(key)
    self:UpdateBarVisual(key, true, true)
end

function RB:RenderPercent(key, percent, force)
    local bar = self.bars[key]
    local saved = self:GetBarSaved(key)
    if not bar or not saved then return end
    percent = Clamp01(percent)
    if not force and math.abs((bar.lastRenderedPercent or -1) - percent) < 0.0005 then return end
    bar.lastRenderedPercent = percent

    local effectiveLength = bar.displayLength or tonumber(saved.length) or 320
    if (saved.layout or "CRESCENT") == "HORIZONTAL" then
        local fillWidth = math.max(1, (effectiveLength - 4) * percent)
        bar.horizontalFill:SetHidden(percent <= 0)
        bar.horizontalFill:SetWidth(fillWidth)
    else
        local thickness = zo_clamp(tonumber(saved.thickness) or 34, 14, 72)
        local width = math.max(86, thickness + 70)
        local visibleHeight = math.max(1, effectiveLength * percent)
        local depth = zo_clamp(tonumber(saved.crescentDepth) or 3, 1, 5)
        local side = saved.crescentSide or "RIGHT"
        local mirror = side == "LEFT"
        local left, right = mirror and 1 or 0, mirror and 0 or 1
        local topV = 1 - percent

        bar.fill:SetHidden(percent <= 0)
        bar.fill:ClearAnchors(); bar.fill:SetAnchor(BOTTOMLEFT, bar.crescentBody, BOTTOMLEFT, 0, 0)
        bar.fill:SetDimensions(width, visibleHeight)
        bar.fill:SetTexture(self:GetTexturePath("fill", depth))
        bar.fill:SetTextureCoords(left, right, topV, 1)

        local capHeight = math.min(8, visibleHeight)
        bar.leading:SetHidden(percent <= 0.01)
        if percent > 0.01 then
            local vSpan = math.min(0.025, capHeight / math.max(1, effectiveLength))
            bar.leading:ClearAnchors()
            -- Anchor the highlight directly to the visible fill instead of
            -- reconstructing its screen position from a bottom-origin offset.
            -- This keeps the cap inside the crescent at every fill percentage
            -- and avoids ESO positive-Y offsets pushing the highlight below
            -- the resource bar.
            bar.leading:SetAnchor(TOPLEFT, bar.fill, TOPLEFT, 0, 0)
            bar.leading:SetDimensions(width, capHeight)
            bar.leading:SetTexture(self:GetTexturePath("fill", depth))
            bar.leading:SetTextureCoords(left, right, topV, math.min(1, topV + vSpan))
        end
    end
end

function RB:UpdateLengthTarget(key, maximum, snap)
    local bar = self.bars[key]
    local saved = self:GetBarSaved(key)
    if not bar or not saved then return end
    local target = self:GetDynamicLengthTarget(key, maximum)
    bar.targetLength = target
    if snap or not bar.displayLength then
        bar.displayLength = target
        self:ApplyEffectiveLength(key, target, true)
    elseif math.abs(target - bar.displayLength) > LENGTH_EPSILON then
        self:EnsureSmoothingLoop()
    end
end

function RB:EnsureSmoothingLoop()
    if self.smoothingActive then return end
    self.smoothingActive = true
    EVENT_MANAGER:RegisterForUpdate(SMOOTH_EVENT, SMOOTH_UPDATE_MS, function() RB:SmoothStep() end)
end

function RB:StopSmoothingLoop()
    if not self.smoothingActive then return end
    self.smoothingActive = false
    EVENT_MANAGER:UnregisterForUpdate(SMOOTH_EVENT)
end

function RB:SmoothStep()
    local anyMoving = false
    for _, key in ipairs(RESOURCE_KEYS) do
        local bar = self.bars[key]
        local saved = self:GetBarSaved(key)
        if bar and saved then
            if (saved.layout or "CRESCENT") == "CRESCENT" then
                local target = Clamp01(bar.targetPercent or 0)
                local display = Clamp01(bar.displayPercent or target)
                local delta = target - display
                if math.abs(delta) > SMOOTH_EPSILON then
                    display = display + delta * SMOOTH_RESPONSE
                    bar.displayPercent = display
                    self:RenderPercent(key, display, false)
                    anyMoving = true
                else
                    bar.displayPercent = target
                    self:RenderPercent(key, target, false)
                end
            end

            local lengthTarget = bar.targetLength
            local lengthDisplay = bar.displayLength
            if lengthTarget and lengthDisplay then
                local lengthDelta = lengthTarget - lengthDisplay
                if math.abs(lengthDelta) > LENGTH_EPSILON then
                    lengthDisplay = lengthDisplay + lengthDelta * LENGTH_RESPONSE
                    bar.displayLength = lengthDisplay
                    self:ApplyEffectiveLength(key, lengthDisplay, false)
                    anyMoving = true
                else
                    bar.displayLength = lengthTarget
                    self:ApplyEffectiveLength(key, lengthTarget, false)
                end
            end
        end
    end
    if not anyMoving then self:StopSmoothingLoop() end
end

function RB:UpdateBarVisual(key, force, snap)
    local bar = self.bars[key]
    local saved = self:GetBarSaved(key)
    if not bar or not saved then return end

    local current, maximum = bar.current, bar.maximum
    local percent = Clamp01(maximum > 0 and current / maximum or 0)
    bar.targetPercent = percent
    self:UpdateLengthTarget(key, maximum, snap == true)

    if (saved.layout or "CRESCENT") == "HORIZONTAL" or force or snap then
        bar.displayPercent = percent
        self:RenderPercent(key, percent, true)
    else
        if bar.displayPercent == nil then bar.displayPercent = percent end
        self:EnsureSmoothingLoop()
    end

    local text = self:GetValueText(current, maximum)
    if force or bar.lastValueText ~= text then
        bar.lastValueText = text
        bar.value:SetText(text)
        bar.value:SetHidden(text == "")
    end
end

function RB:RefreshBar(key, snap)
    local bar = self.bars[key]
    if not bar then return end
    local current, maximum = self:ReadResource(key)
    bar.current = current
    bar.maximum = maximum
    self:UpdateBarVisual(key, false, snap == true)
    self:RefreshVisibility(key)
end

function RB:RefreshAll(snap)
    for _, key in ipairs(RESOURCE_KEYS) do self:RefreshBar(key, snap) end
end

function RB:RefreshVisibility(key)
    local bar = self.bars[key]
    local saved = self:GetBarSaved(key)
    if not bar or not saved then return end
    local currentScene = SCENE_MANAGER and SCENE_MANAGER:GetCurrentScene() or nil
    local previewVisible = bar.previewScene ~= nil and bar.previewScene == currentScene
    local sceneVisible = (T.IsGameplayHUDSceneActive and T:IsGameplayHUDSceneActive()) or previewVisible
    local visible = self:IsActive() and saved.enabled == true and sceneVisible
    if key == "shield" and saved.hideWhenEmpty ~= false and (bar.current or 0) <= 0 and not self.previewActive then visible = false end
    bar.fragment:SetHiddenForReason("Test01ResourceBars", not visible, 0, 0)
    bar.control:SetHidden(not visible)
end

function RB:RefreshVisibilityAll()
    for _, key in ipairs(RESOURCE_KEYS) do self:RefreshVisibility(key) end
end

function RB:InstallNativeSuppressionHooks()
    if self.nativeHooksInstalled then return end
    self.nativeHooksInstalled = true
    self.nativeControls = {
        ZO_PlayerAttributeHealth,
        ZO_PlayerAttributeMagicka,
        ZO_PlayerAttributeStamina,
    }
    for _, control in ipairs(self.nativeControls) do
        if control and ZO_PreHook then
            ZO_PreHook(control, "SetHidden", function(_, hidden)
                if RB:IsActive() and hidden == false then return true end
            end)
        end
    end
end

function RB:SetNativeSuppressed(suppressed)
    self:InstallNativeSuppressionHooks()
    for _, control in ipairs(self.nativeControls or {}) do
        if control then
            if suppressed then
                control:SetHidden(true)
            else
                control:SetHidden(false)
            end
        end
    end
end

function RB:RegisterRuntimeEvents()
    if self.eventsRegistered then return end
    self.eventsRegistered = true
    EVENT_MANAGER:RegisterForEvent("Test01ResourceBarsPower", EVENT_POWER_UPDATE, function(_, unitTag, _, powerType, powerValue, powerMax)
        local key = POWER_TO_KEY[powerType]
        if not key or not RB:IsActive() then return end
        local bar = RB.bars[key]
        if not bar then return end
        bar.current = tonumber(powerValue) or 0
        bar.maximum = math.max(1, tonumber(powerMax) or 1)
        -- EVENT_POWER_UPDATE carries the maximum as well as the current value,
        -- so food, gear, and other max-resource changes resize the bar without
        -- a separate food tracker or polling pass.
        RB:UpdateBarVisual(key, false, false)
    end)
    EVENT_MANAGER:AddFilterForEvent("Test01ResourceBarsPower", EVENT_POWER_UPDATE, REGISTER_FILTER_UNIT_TAG, "player")

    local function ShieldChanged()
        if RB:IsActive() then RB:RefreshBar("shield", false) end
    end
    EVENT_MANAGER:RegisterForEvent("Test01ResourceBarsShieldAdd", EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED, function(_, unitTag, visual, _, attributeType)
        if unitTag == "player" and visual == ATTRIBUTE_VISUAL_POWER_SHIELDING and attributeType == ATTRIBUTE_HEALTH then ShieldChanged() end
    end)
    EVENT_MANAGER:RegisterForEvent("Test01ResourceBarsShieldUpdate", EVENT_UNIT_ATTRIBUTE_VISUAL_UPDATED, function(_, unitTag, visual, _, attributeType)
        if unitTag == "player" and visual == ATTRIBUTE_VISUAL_POWER_SHIELDING and attributeType == ATTRIBUTE_HEALTH then ShieldChanged() end
    end)
    EVENT_MANAGER:RegisterForEvent("Test01ResourceBarsShieldRemove", EVENT_UNIT_ATTRIBUTE_VISUAL_REMOVED, function(_, unitTag, visual, _, attributeType)
        if unitTag == "player" and visual == ATTRIBUTE_VISUAL_POWER_SHIELDING and attributeType == ATTRIBUTE_HEALTH then ShieldChanged() end
    end)
    EVENT_MANAGER:AddFilterForEvent("Test01ResourceBarsShieldAdd", EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED, REGISTER_FILTER_UNIT_TAG, "player")
    EVENT_MANAGER:AddFilterForEvent("Test01ResourceBarsShieldUpdate", EVENT_UNIT_ATTRIBUTE_VISUAL_UPDATED, REGISTER_FILTER_UNIT_TAG, "player")
    EVENT_MANAGER:AddFilterForEvent("Test01ResourceBarsShieldRemove", EVENT_UNIT_ATTRIBUTE_VISUAL_REMOVED, REGISTER_FILTER_UNIT_TAG, "player")
end

function RB:UnregisterRuntimeEvents()
    if not self.eventsRegistered then return end
    self.eventsRegistered = false
    EVENT_MANAGER:UnregisterForEvent("Test01ResourceBarsPower", EVENT_POWER_UPDATE)
    EVENT_MANAGER:UnregisterForEvent("Test01ResourceBarsShieldAdd", EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED)
    EVENT_MANAGER:UnregisterForEvent("Test01ResourceBarsShieldUpdate", EVENT_UNIT_ATTRIBUTE_VISUAL_UPDATED)
    EVENT_MANAGER:UnregisterForEvent("Test01ResourceBarsShieldRemove", EVENT_UNIT_ATTRIBUTE_VISUAL_REMOVED)
    self:StopSmoothingLoop()
end

function RB:ApplyActiveState()
    local active = self:IsActive()
    self:SetNativeSuppressed(active)
    if active then
        self:RegisterRuntimeEvents()
        self:RefreshAll(true)
    else
        self:UnregisterRuntimeEvents()
        self:RefreshVisibilityAll()
    end
end

function RB:SetEnabled(value)
    local saved = self:GetSaved()
    if not saved then return end
    saved.enabled = value == true
    self:ApplyActiveState()
end

function RB:SetBarEnabled(key, value)
    local saved = self:GetBarSaved(key)
    if not saved then return end
    saved.enabled = value == true
    self:RefreshBar(key, true)
end

function RB:SetValueDisplay(mode)
    local saved = self:GetSaved()
    if not saved then return end
    if mode ~= "NUMBERS" and mode ~= "PERCENT" and mode ~= "NONE" then return end
    saved.valueDisplay = mode
    for _, key in ipairs(RESOURCE_KEYS) do self:UpdateBarVisual(key, true, true) end
end

function RB:SetShowNames(value)
    local saved = self:GetSaved()
    if not saved then return end
    saved.showNames = value == true
    for _, key in ipairs(RESOURCE_KEYS) do self:ApplyFooterLayout(key) end
end

function RB:SetBarOption(key, option, value)
    local saved = self:GetBarSaved(key)
    if not saved then return end
    saved[option] = value
    if option == "length" then
        local bar = self.bars[key]
        if bar then
            bar.targetLength = self:GetDynamicLengthTarget(key, bar.maximum)
            bar.displayLength = bar.targetLength
        end
    end
    self:ApplyBarLayout(key)
    self:ShowPreview()
end

function RB:Nudge(key, dx, dy)
    local saved = self:GetBarSaved(key)
    if not saved then return end
    saved.offsetX = zo_clamp((saved.offsetX or 0) + dx, -1600, 1600)
    saved.offsetY = zo_clamp((saved.offsetY or 0) + dy, -900, 900)
    self:ApplyBarLayout(key)
    self:ShowPreview()
end

function RB:ResetPosition(key)
    local defaults = {
        health = {-240, -20},
        magicka = {-155, -20},
        stamina = {155, -20},
        shield = {240, -20},
    }
    local saved = self:GetBarSaved(key)
    if not saved then return end
    saved.offsetX, saved.offsetY = defaults[key][1], defaults[key][2]
    self:ApplyBarLayout(key)
    self:ShowPreview()
end

function RB:AttachPreview(bar)
    local currentScene = SCENE_MANAGER and SCENE_MANAGER:GetCurrentScene() or nil
    local previous = bar.previewScene
    if previous and previous ~= currentScene and previous ~= HUD_SCENE and previous ~= HUD_UI_SCENE then
        previous:RemoveFragment(bar.fragment)
        bar.previewScene = nil
    end
    if currentScene and currentScene ~= HUD_SCENE and currentScene ~= HUD_UI_SCENE and bar.previewScene ~= currentScene then
        currentScene:AddFragment(bar.fragment)
        bar.previewScene = currentScene
    end
end

function RB:ShowPreview()
    self.previewActive = true
    for _, key in ipairs(RESOURCE_KEYS) do
        local bar = self.bars[key]
        local saved = self:GetBarSaved(key)
        if bar and saved then
            self:AttachPreview(bar)
            local current, maximum = self:ReadResource(key)
            if key == "shield" and current <= 0 then current = maximum * 0.35 end
            bar.current, bar.maximum = current, maximum
            self:UpdateBarVisual(key, true, true)
            local visible = saved.enabled == true
            bar.fragment:SetHiddenForReason("Test01ResourceBars", not visible, 0, 0)
            bar.control:SetHidden(not visible)
        end
    end
end

function RB:HidePreview()
    self.previewActive = false
    for _, key in ipairs(RESOURCE_KEYS) do
        local bar = self.bars[key]
        if bar then
            local scene = bar.previewScene
            bar.previewScene = nil
            if scene and scene ~= HUD_SCENE and scene ~= HUD_UI_SCENE then scene:RemoveFragment(bar.fragment) end
        end
    end
    self:RefreshAll(true)
end

function RB:Initialize()
    self.bars = {}
    self.previewActive = false
    self.smoothingActive = false
    for _, key in ipairs(RESOURCE_KEYS) do self:CreateBar(key) end
    for _, key in ipairs(RESOURCE_KEYS) do self:ApplyBarLayout(key) end
    self:InstallNativeSuppressionHooks()
    self:ApplyActiveState()
    EVENT_MANAGER:RegisterForEvent("Test01ResourceBarsActivated", EVENT_PLAYER_ACTIVATED, function()
        RB:SetNativeSuppressed(RB:IsActive())
        if RB:IsActive() then
            -- Re-read absolute resource maxima after zoning/login. Physical
            -- bar length is derived from the shared 30k resource standard.
            RB:RefreshAll(true)
        end
    end)
end
