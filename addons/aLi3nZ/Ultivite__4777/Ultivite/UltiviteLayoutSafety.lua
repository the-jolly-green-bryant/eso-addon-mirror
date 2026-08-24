local U = Ultivite
if not U then return end

U.LayoutSafety = U.LayoutSafety or {}
local L = U.LayoutSafety

L.sv = nil
L.initialized = false

local DEFAULTS = {
    preset = "4k",
    appliedFactor = 1.00,
    autoRepairOnDisplayChange = true,
    lastRootWidth = 0,
    lastRootHeight = 0,
    dynamicResolutionBaselineVersion = 1,
}

-- Layout values need to shrink more than text and alert icons. Keeping a
-- separate readability factor prevents a 1080p preset from producing tiny
-- warnings while still moving a 4K layout safely into the smaller canvas.
local PRESETS = {
    ["1080p"] = { label = "1080p", layoutFactor = 0.72, readabilityFactor = 0.86 },
    ["1440p"] = { label = "1440p", layoutFactor = 0.86, readabilityFactor = 0.93 },
    ["4k"] = { label = "4K", layoutFactor = 1.00, readabilityFactor = 1.00 },
}

local REFERENCE_VERSION = 2
local SCREEN_MARGIN = 8

local function deepCopy(value)
    if type(value) ~= "table" then return value end
    local copy = {}
    for key, child in pairs(value) do copy[key] = deepCopy(child) end
    return copy
end

local function fillDefaults(target, defaults)
    for key, value in pairs(defaults) do
        if target[key] == nil then target[key] = deepCopy(value) end
    end
end

local function clamp(value, minimum, maximum)
    value = tonumber(value) or 0
    if minimum ~= nil and value < minimum then return minimum end
    if maximum ~= nil and value > maximum then return maximum end
    return value
end

local function positiveFactor(value)
    value = tonumber(value)
    if value and value > 0 then return value end
    return nil
end

local function requestSave()
    if U.RequestSettingsSave then U.RequestSettingsSave(true) end
end

local function spec(key, mode, minimum, maximum, roundValue)
    return {
        key = key,
        mode = mode or "layout",
        minimum = minimum,
        maximum = maximum,
        roundValue = roundValue == true,
    }
end

local FRAME_SCALE_SPECS = {
    spec("healthX"), spec("healthY"),
    spec("magickaX"), spec("magickaY"),
    spec("staminaX"), spec("staminaY"),
    spec("compactGap", "layout", 0, 200, true),
    spec("bottomMargin", "layout", 0, 200, true),
    spec("darkSoulsLeft"), spec("darkSoulsTop"),
    spec("darkSoulsGap", "layout", 0, 100, true),
    spec("dsBottomX"), spec("dsBottomOffset"),
    spec("dsBottomGap", "layout", 0, 100, true),
    spec("dsSelfScale", "layout", 0.50, 2.50),
    spec("barWidth", "layout", 0.50, 5.00),
    spec("barThickness", "layout", 0.50, 5.00),
    spec("textScale", "readability", 0.50, 2.50),
    spec("dsEnemyX"), spec("dsEnemyBottomOffset"),
    spec("dsEnemyWidth", "layout", 320, 1800, true),
    spec("dsEnemyHeight", "layout", 8, 80, true),
    spec("groupFrameX"), spec("groupFrameY"),
    spec("crownDirectionArrowX"), spec("crownDirectionArrowY"),
    spec("crownDirectionArrowSize", "readability", 14, 96, true),
    spec("feetCompassX"), spec("feetCompassY"),
    spec("feetCompassSize", "layout", 140, 650, true),
}

local COMBAT_SCALE_SPECS = {
    spec("x"), spec("y"),
    spec("scale", "layout", 0.35, 1.50),
    spec("frameScale", "layout", 0.35, 1.50),
    spec("targetScreenGap", "layout", 2, 40, true),
    spec("nameFontSize", "readability", 14, 40, true),
    spec("healthFontSize", "readability", 10, 44, true),
    spec("kjalnarFontSize", "readability", 18, 42, true),
    spec("timerFontSize", "readability", 16, 44, true),
    spec("balorghTimerFontSize", "readability", 16, 48, true),
    spec("dragonAppetiteFontSize", "readability", 10, 36, true),
    spec("dragonAppetiteYOffset"),
    spec("wretchedVitalityX"), spec("wretchedVitalityY"),
    spec("wretchedVitalityIconSize", "readability", 36, 80, true),
    spec("ccImmunityX"), spec("ccImmunityY"),
    spec("playerDebuffX"), spec("playerDebuffY"),
    spec("playerAuraIconSize", "readability", 34, 68, true),
    spec("liveDamageX"), spec("liveDamageY"),
    spec("liveFrontResistanceX"), spec("liveFrontResistanceY"),
    spec("liveBackResistanceX"), spec("liveBackResistanceY"),
    spec("liveShieldX"), spec("liveShieldY"),
    spec("liveStatFontSize", "readability", 16, 42, true),
    spec("genericStackX"), spec("genericStackY"),
    spec("genericStackIconSize", "readability", 30, 64, true),
    spec("streakFatigueX"), spec("streakFatigueY"),
    spec("streakFatigueIconSize", "readability", 30, 68, true),
    spec("resourceDangerX"), spec("resourceDangerY"),
    spec("resourceDangerFontSize", "readability", 16, 38, true),
    spec("combatDangerX"), spec("combatDangerY"),
    spec("combatDangerFontSize", "readability", 22, 42, true),
    spec("targetDebuffX"), spec("targetDebuffY"),
    spec("targetDebuffIconSize", "readability", 30, 64, true),
    spec("majorBreachX"), spec("majorBreachY"),
    spec("majorBreachFontSize", "readability", 10, 34, true),
    spec("foodWarningX"), spec("foodWarningY"),
    spec("foodWarningFontSize", "readability", 16, 50, true),
    spec("majorResolveWarningX"), spec("majorResolveWarningY"),
    spec("majorResolveWarningFontSize", "readability", 16, 46, true),
    spec("enemyUltimateAlertIconSize", "readability", 32, 96, true),
    spec("pvpHudX"), spec("pvpHudY"),
    spec("pvpHudFontSize", "readability", 14, 36, true),
}

-- 1.0.134 used one factor and only scaled these fields. This map lets the new
-- reference system reconstruct those profiles without shrinking them twice.
local LEGACY_FRAME_KEYS = {
    healthX = true, healthY = true, magickaX = true, magickaY = true,
    staminaX = true, staminaY = true, compactGap = true, bottomMargin = true,
    darkSoulsLeft = true, darkSoulsTop = true, darkSoulsGap = true,
    dsEnemyX = true, dsEnemyBottomOffset = true, dsEnemyWidth = true, dsEnemyHeight = true,
    dsBottomX = true, dsBottomOffset = true, dsBottomGap = true,
    crownDirectionArrowX = true, crownDirectionArrowY = true,
    crownDirectionArrowSize = true, feetCompassX = true, feetCompassY = true,
    feetCompassSize = true,
}

local LEGACY_COMBAT_KEYS = {
    x = true, y = true, frameScale = true, liveStatFontSize = true,
    pvpHudFontSize = true, ccImmunityX = true, ccImmunityY = true,
    playerDebuffX = true, playerDebuffY = true, targetDebuffX = true,
    targetDebuffY = true, genericStackX = true, genericStackY = true,
    streakFatigueX = true, streakFatigueY = true, wretchedVitalityX = true,
    wretchedVitalityY = true, resourceDangerX = true, resourceDangerY = true,
    combatDangerX = true, combatDangerY = true, majorBreachX = true,
    majorBreachY = true, foodWarningX = true, foodWarningY = true,
    majorResolveWarningX = true, majorResolveWarningY = true,
    enemyUltimateAlertIconSize = true, playerAuraIconSize = true,
    targetDebuffIconSize = true, genericStackIconSize = true,
    streakFatigueIconSize = true, wretchedVitalityIconSize = true,
    resourceDangerFontSize = true, combatDangerFontSize = true,
}

function L.GetRootDimensions()
    if GuiRoot and GuiRoot.GetDimensions then
        local width, height = GuiRoot:GetDimensions()
        return tonumber(width) or 1920, tonumber(height) or 1080
    end
    return 1920, 1080
end

local function getActiveTables()
    local profile = U.GetActiveProfile and U.GetActiveProfile() or nil
    local frames = U.Frames and U.Frames.saved or (profile and profile.frames)
    local combat = U.Combat and U.Combat.sv or (profile and profile.combat)
    return frames, combat
end

function L.GetStatusText()
    local width, height = L.GetRootDimensions()
    local preset = PRESETS[L.sv and L.sv.preset or "4k"] or PRESETS["4k"]
    local repair = L.sv and L.sv.autoRepairOnDisplayChange == true and "on" or "off"
    return string.format(
        "Current ESO UI canvas: %.0f x %.0f. Preset: %s. Layout %.0f%%, readable text/icons %.0f%%, automatic screen repair %s.",
        width,
        height,
        preset.label,
        preset.layoutFactor * 100,
        preset.readabilityFactor * 100,
        repair
    )
end

local function scaledValue(base, factor, definition)
    local value = (tonumber(base) or 0) * factor
    value = clamp(value, definition.minimum, definition.maximum)
    if definition.roundValue then value = math.floor(value + 0.5) end
    return value
end

local function currentFactor(settings, definition, legacyKeys)
    if definition.mode == "readability" then
        local factor = positiveFactor(settings.ultiviteDisplayReadabilityFactor)
        if factor then return factor end
        if legacyKeys[definition.key] then
            return positiveFactor(settings.ultiviteDisplayScaleFactor) or 1
        end
        return 1
    end
    local factor = positiveFactor(settings.ultiviteDisplayLayoutFactor)
    if factor then return factor end
    if legacyKeys[definition.key] then
        return positiveFactor(settings.ultiviteDisplayScaleFactor) or 1
    end
    return 1
end

local function normalizeSettings(settings, definitions, legacyKeys, preset)
    if type(settings) ~= "table" then return 0 end

    local reference = settings.ultiviteDisplayScaleReference
    if type(reference) ~= "table" or reference.version ~= REFERENCE_VERSION then
        reference = { version = REFERENCE_VERSION, values = {} }
        settings.ultiviteDisplayScaleReference = reference
    end
    reference.values = type(reference.values) == "table" and reference.values or {}

    local changed = 0
    for _, definition in ipairs(definitions) do
        local key = definition.key
        local current = settings[key]
        if type(current) == "number" then
            local oldFactor = currentFactor(settings, definition, legacyKeys)
            local base = tonumber(reference.values[key])
            if base == nil then
                base = current / oldFactor
                reference.values[key] = base
            else
                local expected = scaledValue(base, oldFactor, definition)
                local tolerance = definition.roundValue and 0.1 or 0.01
                if math.abs(current - expected) > tolerance then
                    -- A changed live value is a user edit made under the current
                    -- preset. Promote it back to the unscaled reference before
                    -- applying another preset so the edit is never discarded.
                    base = current / oldFactor
                    reference.values[key] = base
                end
            end

            local targetFactor = definition.mode == "readability"
                and preset.readabilityFactor
                or preset.layoutFactor
            local target = scaledValue(base, targetFactor, definition)
            if target ~= current then
                settings[key] = target
                changed = changed + 1
            end
        end
    end

    settings.ultiviteDisplayLayoutFactor = preset.layoutFactor
    settings.ultiviteDisplayReadabilityFactor = preset.readabilityFactor
    settings.ultiviteDisplayScaleFactor = preset.layoutFactor
    return changed
end

local function tableNeedsPreset(settings, preset)
    if type(settings) ~= "table" then return false end
    local layout = positiveFactor(settings.ultiviteDisplayLayoutFactor)
        or positiveFactor(settings.ultiviteDisplayScaleFactor)
        or 1
    local readable = positiveFactor(settings.ultiviteDisplayReadabilityFactor)
    if not readable then
        -- Missing v2 readability metadata requires one normalization pass even
        -- when the old one-factor marker already matches the layout preset.
        return true
    end
    return math.abs(layout - preset.layoutFactor) > 0.001
        or math.abs(readable - preset.readabilityFactor) > 0.001
end

local function refreshLayout()
    local frames = U.Frames
    local combat = U.Combat
    if frames then
        if frames.ApplyPositions then frames.ApplyPositions() end
        if frames.ApplyBarGeometry then frames.ApplyBarGeometry() end
        if frames.ApplyTextStyle then frames.ApplyTextStyle() end
        if frames.ApplyGroupFrameState then frames.ApplyGroupFrameState() end
        if frames.RefreshNavigationHelpers then frames.RefreshNavigationHelpers(true) end
        if frames.RefreshDSSelfHealthRuntime then frames.RefreshDSSelfHealthRuntime() end
        if frames.RefreshDSEnemyHealthRuntime then frames.RefreshDSEnemyHealthRuntime() end
    end
    if combat then
        if combat.ApplyPosition then combat.ApplyPosition() end
        if combat.ApplyTimerAnchor then combat.ApplyTimerAnchor() end
        if combat.ApplyAllLayouts then combat.ApplyAllLayouts() end
        if combat.ApplyPvpHudAppearance then combat.ApplyPvpHudAppearance() end
        if combat.RefreshDisplay then combat.RefreshDisplay() end
        if combat.UpdateLiveStatWidgets then combat.UpdateLiveStatWidgets(true) end
        if combat.UpdateCombatDangerWarnings then combat.UpdateCombatDangerWarnings(true) end
    end
    if U.EnemyUltimateAlerts and U.EnemyUltimateAlerts.ApplyLayout then U.EnemyUltimateAlerts.ApplyLayout() end
    if U.FancyActionBar and U.FancyActionBar.RefreshRuntime then U.FancyActionBar.RefreshRuntime() end
end

function L.ApplyPreset(presetId, silent, repairBounds)
    local preset = PRESETS[presetId]
    if not preset or not L.sv then return false end
    local frames, combat = getActiveTables()

    normalizeSettings(frames, FRAME_SCALE_SPECS, LEGACY_FRAME_KEYS, preset)
    normalizeSettings(combat, COMBAT_SCALE_SPECS, LEGACY_COMBAT_KEYS, preset)

    L.sv.preset = presetId
    L.sv.appliedFactor = preset.layoutFactor
    if repairBounds ~= false then
        L.KeepHudOnScreen(true)
    else
        refreshLayout()
    end
    requestSave()
    if not silent and d then
        d("[Ultivite] Applied " .. preset.label .. " HUD scale preset and repaired off-screen elements.")
    end
    return true
end

function L.NormalizeActiveProfile(silent, repairBounds)
    if not L.sv then return false end
    local preset = PRESETS[L.sv.preset or "4k"] or PRESETS["4k"]
    local frames, combat = getActiveTables()
    if not tableNeedsPreset(frames, preset) and not tableNeedsPreset(combat, preset) then return false end
    return L.ApplyPreset(L.sv.preset or "4k", silent ~= false, repairBounds)
end

local function setNumber(settings, key, value)
    if type(settings) ~= "table" or type(settings[key]) ~= "number" then return 0 end
    if math.abs(settings[key] - value) <= 0.001 then return 0 end
    settings[key] = value
    return 1
end

local function clampCenteredPair(settings, xKey, yKey, width, height, halfWidth, halfHeight)
    if type(settings) ~= "table" then return 0 end
    local repaired = 0
    halfWidth = math.max(0, tonumber(halfWidth) or 0)
    halfHeight = math.max(0, tonumber(halfHeight) or 0)
    local maxX = math.max(0, (width / 2) - halfWidth - SCREEN_MARGIN)
    local maxY = math.max(0, (height / 2) - halfHeight - SCREEN_MARGIN)
    if type(settings[xKey]) == "number" then
        repaired = repaired + setNumber(settings, xKey, clamp(settings[xKey], -maxX, maxX))
    end
    if type(settings[yKey]) == "number" then
        repaired = repaired + setNumber(settings, yKey, clamp(settings[yKey], -maxY, maxY))
    end
    return repaired
end

local function clampTopLeftPair(settings, xKey, yKey, width, height, controlWidth, controlHeight)
    if type(settings) ~= "table" then return 0 end
    local repaired = 0
    local maxX = math.max(SCREEN_MARGIN, width - math.max(0, controlWidth or 0) - SCREEN_MARGIN)
    local maxY = math.max(SCREEN_MARGIN, height - math.max(0, controlHeight or 0) - SCREEN_MARGIN)
    if type(settings[xKey]) == "number" then
        repaired = repaired + setNumber(settings, xKey, clamp(settings[xKey], SCREEN_MARGIN, maxX))
    end
    if type(settings[yKey]) == "number" then
        repaired = repaired + setNumber(settings, yKey, clamp(settings[yKey], SCREEN_MARGIN, maxY))
    end
    return repaired
end

local function clampBottomPair(settings, xKey, yKey, width, height, controlWidth, controlHeight)
    if type(settings) ~= "table" then return 0 end
    local repaired = 0
    local halfWidth = math.max(0, (tonumber(controlWidth) or 0) / 2)
    local maxX = math.max(0, (width / 2) - halfWidth - SCREEN_MARGIN)
    local minY = math.min(-SCREEN_MARGIN, (tonumber(controlHeight) or 0) + SCREEN_MARGIN - height)
    if type(settings[xKey]) == "number" then
        repaired = repaired + setNumber(settings, xKey, clamp(settings[xKey], -maxX, maxX))
    end
    if type(settings[yKey]) == "number" then
        repaired = repaired + setNumber(settings, yKey, clamp(settings[yKey], minY, -SCREEN_MARGIN))
    end
    return repaired
end

function L.KeepHudOnScreen(silent)
    local width, height = L.GetRootDimensions()
    local frames, combat = getActiveTables()
    local repaired = 0

    if frames then
        local barWidth = 237 * clamp(frames.barWidth or 1, 0.50, 5.00)
        local barHeight = 23 * clamp(frames.barThickness or 1, 0.50, 5.00)
        for _, prefix in ipairs({ "health", "magicka", "stamina" }) do
            repaired = repaired + clampCenteredPair(
                frames, prefix .. "X", prefix .. "Y", width, height, barWidth / 2, barHeight / 2
            )
        end

        local darkStackHeight = (barHeight * 3) + (math.max(0, tonumber(frames.darkSoulsGap) or 0) * 2) + 70
        repaired = repaired + clampTopLeftPair(
            frames, "darkSoulsLeft", "darkSoulsTop", width, height, barWidth + 80, darkStackHeight
        )

        local enemyWidth = clamp(frames.dsEnemyWidth or 988, 320, 1800)
        local enemyHeight = clamp(frames.dsEnemyHeight or 18, 8, 80)
        repaired = repaired + clampBottomPair(
            frames, "dsEnemyX", "dsEnemyBottomOffset", width, height, enemyWidth, enemyHeight
        )

        local selfScale = clamp(frames.dsSelfScale or 1, 0.50, 2.50)
        local selfWidth = 988 * selfScale
        local selfGap = math.max(0, tonumber(frames.dsBottomGap) or 0)
        local selfHeight = (18 * selfScale * 3) + (selfGap * 2)
        repaired = repaired + clampBottomPair(
            frames, "dsBottomX", "dsBottomOffset", width, height, selfWidth, selfHeight
        )

        local crownSize = math.max(46, clamp(frames.crownDirectionArrowSize or 40, 14, 96) * 2.55)
        repaired = repaired + clampCenteredPair(
            frames, "crownDirectionArrowX", "crownDirectionArrowY", width, height, crownSize / 2, crownSize / 2
        )

        local compassWidth = clamp(frames.feetCompassSize or 330, 140, 650)
        local compassHeight = math.max(112, compassWidth * 0.70)
        repaired = repaired + clampCenteredPair(
            frames, "feetCompassX", "feetCompassY", width, height, compassWidth / 2, compassHeight / 2
        )

        if type(frames.groupFrameX) == "number" and type(frames.groupFrameY) == "number" then
            local groupWidth, groupHeight = 360, 600
            local control = U.Frames and U.Frames.GetGroupFrameControl and U.Frames.GetGroupFrameControl() or nil
            if control then
                if control.GetWidth then groupWidth = tonumber(control:GetWidth()) or groupWidth end
                if control.GetHeight then groupHeight = tonumber(control:GetHeight()) or groupHeight end
            end
            repaired = repaired + clampTopLeftPair(
                frames, "groupFrameX", "groupFrameY", width, height, groupWidth, groupHeight
            )
        end
    end

    if combat then
        local frameScale = clamp(combat.frameScale or combat.scale or 0.9, 0.35, 1.50)
        repaired = repaired + clampCenteredPair(combat, "x", "y", width, height, 220 * frameScale, 145 * frameScale)

        local auraSize = clamp(combat.playerAuraIconSize or 48, 34, 68)
        repaired = repaired + clampCenteredPair(combat, "ccImmunityX", "ccImmunityY", width, height, auraSize / 2, auraSize / 2)
        local playerDebuffWidth = (auraSize * clamp(combat.playerDebuffMaxIcons or 8, 3, 12)) + 55
        repaired = repaired + clampCenteredPair(combat, "playerDebuffX", "playerDebuffY", width, height, playerDebuffWidth / 2, auraSize / 2)

        local targetSize = clamp(combat.targetDebuffIconSize or 42, 30, 64)
        local targetWidth = (targetSize * clamp(combat.targetDebuffMaxIcons or 8, 3, 12)) + 55
        repaired = repaired + clampCenteredPair(combat, "targetDebuffX", "targetDebuffY", width, height, targetWidth / 2, targetSize / 2)

        local genericSize = clamp(combat.genericStackIconSize or 44, 30, 64)
        repaired = repaired + clampCenteredPair(combat, "genericStackX", "genericStackY", width, height, ((genericSize * 6) + 30) / 2, genericSize / 2)
        local streakSize = clamp(combat.streakFatigueIconSize or 48, 30, 68)
        repaired = repaired + clampCenteredPair(combat, "streakFatigueX", "streakFatigueY", width, height, streakSize / 2, streakSize / 2)

        local wretchedSize = clamp(combat.wretchedVitalityIconSize or 54, 36, 80)
        repaired = repaired + clampCenteredPair(combat, "wretchedVitalityX", "wretchedVitalityY", width, height, wretchedSize + 6, wretchedSize / 2)
        repaired = repaired + clampCenteredPair(combat, "resourceDangerX", "resourceDangerY", width, height, 165, 24)
        repaired = repaired + clampCenteredPair(combat, "combatDangerX", "combatDangerY", width, height, 310, 66)
        repaired = repaired + clampCenteredPair(combat, "majorBreachX", "majorBreachY", width, height, 18, 18)
        repaired = repaired + clampCenteredPair(combat, "foodWarningX", "foodWarningY", width, height, 260, 24)
        repaired = repaired + clampCenteredPair(combat, "majorResolveWarningX", "majorResolveWarningY", width, height, 260, 22)

        for _, pair in ipairs({
            { "liveDamageX", "liveDamageY" },
            { "liveFrontResistanceX", "liveFrontResistanceY" },
            { "liveBackResistanceX", "liveBackResistanceY" },
            { "liveShieldX", "liveShieldY" },
        }) do
            repaired = repaired + clampCenteredPair(combat, pair[1], pair[2], width, height, 78, 28)
        end

        if type(combat.pvpHudX) == "number" and type(combat.pvpHudY) == "number" then
            local pvpFont = clamp(combat.pvpHudFontSize or 20, 14, 36)
            local pvpScale = pvpFont / 20
            local pvpWidth = math.max(300, 420 * pvpScale)
            local pvpHeight = math.max(30, 34 * pvpScale)
            repaired = repaired + clampTopLeftPair(
                combat, "pvpHudX", "pvpHudY", width, height, pvpWidth, pvpHeight
            )
        end
    end

    refreshLayout()

    local fab = U.FancyActionBar
    if fab and fab.GetWholeActionBarVisualBounds and fab.GetWholeActionBarPosition and fab.SetWholeActionBarPosition then
        local left, top, right, bottom = fab.GetWholeActionBarVisualBounds()
        local x, y = fab.GetWholeActionBarPosition()
        if left and top and right and bottom and x and y then
            local dx, dy = 0, 0
            if left < SCREEN_MARGIN then
                dx = SCREEN_MARGIN - left
            elseif right > width - SCREEN_MARGIN then
                dx = (width - SCREEN_MARGIN) - right
            end
            if top < SCREEN_MARGIN then
                dy = SCREEN_MARGIN - top
            elseif bottom > height - SCREEN_MARGIN then
                dy = (height - SCREEN_MARGIN) - bottom
            end
            if dx ~= 0 or dy ~= 0 then
                fab.SetWholeActionBarPosition(x + dx, y + dy)
                repaired = repaired + 1
            end
        end
    end

    requestSave()
    if not silent and d then
        d(string.format("[Ultivite] HUD screen repair complete. %d saved coordinates adjusted.", repaired))
    end
    return repaired
end

function L.Initialize(accountSV)
    if L.initialized or not accountSV then return end
    L.initialized = true
    local isNewDisplaySafety = type(accountSV.displaySafety) ~= "table"
    accountSV.displaySafety = accountSV.displaySafety or {}
    fillDefaults(accountSV.displaySafety, DEFAULTS)
    L.sv = accountSV.displaySafety

    local width, height = L.GetRootDimensions()
    if isNewDisplaySafety then
        -- Built-in layouts now scale directly from the live logical GuiRoot, so a
        -- second automatic 1080p/1440p multiplier would shrink them twice. Keep
        -- the manual scale preset neutral on new installs. Existing users retain
        -- their chosen preset and current saved coordinates without migration.
        L.sv.preset = "4k"
        L.sv.appliedFactor = PRESETS["4k"].layoutFactor
    end
    L.sv.dynamicResolutionBaselineVersion = 1
    local previousWidth = tonumber(L.sv.lastRootWidth) or 0
    local previousHeight = tonumber(L.sv.lastRootHeight) or 0
    local changed = previousWidth > 0
        and (math.abs(previousWidth - width) > 1 or math.abs(previousHeight - height) > 1)
    L.sv.lastRootWidth, L.sv.lastRootHeight = width, height

    local function finishDisplaySafety()
        local shouldRepair = isNewDisplaySafety
            or (changed and L.sv.autoRepairOnDisplayChange == true)
        local normalized = L.NormalizeActiveProfile(true, shouldRepair)
        if not normalized and changed and L.sv.autoRepairOnDisplayChange == true then
            L.KeepHudOnScreen(true)
        end
    end
    if zo_callLater then zo_callLater(finishDisplaySafety, 900) else finishDisplaySafety() end
end

function L.GetMenuOptions()
    return {
        { type = "description", title = "Resolution & UI Scale Safety", text = function() return L.GetStatusText() end },
        { type = "dropdown", name = "HUD scale preset", choices = { "1080p", "1440p", "4K" }, choicesValues = { "1080p", "1440p", "4k" },
            tooltip = "Optional additional HUD scaling. Built-in Ultivite layouts already adapt automatically to the live ESO UI canvas using the 4K layout reference. Switching this manual preset is reversible and does not change ESO's own UI scale setting.",
            getFunc = function() return L.sv and L.sv.preset or "4k" end,
            setFunc = function(value) L.ApplyPreset(value, false) end, default = "4k", width = "full" },
        { type = "checkbox", name = "Repair HUD after resolution or UI scale changes",
            tooltip = "When ESO's logical UI canvas changes between loading screens, Ultivite repairs saved coordinates using each control's complete visible bounds. Built-in layout presets calculate their own resolution-aware positions automatically.",
            getFunc = function() return L.sv and L.sv.autoRepairOnDisplayChange == true end,
            setFunc = function(value) if L.sv then L.sv.autoRepairOnDisplayChange = value == true; requestSave() end end,
            default = true, width = "full" },
        { type = "button", name = "Keep HUD Elements On Screen",
            tooltip = "Repairs player bars, Dark Souls bars, trackers, warnings, live stats, navigation helpers, PvP HUD, group frame and Fancy Action Bar position while preserving the layout as closely as possible.",
            func = function() L.KeepHudOnScreen(false) end, width = "full" },
    }
end
