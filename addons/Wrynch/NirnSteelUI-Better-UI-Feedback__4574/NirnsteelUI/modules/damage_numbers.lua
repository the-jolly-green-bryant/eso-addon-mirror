local ADDON_NAME = "NirnsteelUI"
local EVENT_NAMESPACE = ADDON_NAME .. "_DamageNumbers"

Nirnsteel_UI = Nirnsteel_UI or {}
local Nirnsteel_UI = Nirnsteel_UI
local DamageNumbers = {}
Nirnsteel_UI.DamageNumbers = DamageNumbers

local DEFAULT_SETTINGS =
{
    enabled = true,
    unlocked = false,
    hideDefaultDamage = true,
    critSoundEnabled = true,
    fontKey = "antique",
    textEffect = "none",
    critSoundKey = "CONSOLE_GAME_ENTER",
    normalFontSize = 56,
    critFontSize = 78,
    durationMS = 820,
    spread = 118,
    drift = 55,
    bigHitThreshold = 25000,
    maxActive = 36,
    soundThrottleMS = 120,
    savedSctSettings = {},
}

local MOVEMENT_MULTIPLIER = 0.38
local BIG_HIT_MOVEMENT_MULTIPLIER = 0.08
local NORMAL_START_SCALE = 2.85
local CRIT_START_SCALE = 3.45
local NORMAL_END_SCALE = 1
local CRIT_END_SCALE = 1.18
local POP_PROGRESS_PORTION = 0.18
local DEFAULT_SPAWN_OFFSET_X = 0
local DEFAULT_SPAWN_OFFSET_Y = -45

local FONT_FACES =
{
    antique = "$(ANTIQUE_FONT)",
    handwritten = "$(HANDWRITTEN_FONT)",
    stoneTablet = "$(STONE_TABLET_FONT)",
    proseAntique = "EsoUI/Common/Fonts/ProseAntiquePSMT.slug",
    trajan = "EsoUI/Common/Fonts/TrajanPro-Regular.slug",
    univers57 = "EsoUI/Common/Fonts/Univers57.slug",
    univers67 = "EsoUI/Common/Fonts/Univers67.slug",
    universCyrillic = "EsoUI/Common/Fonts/Univers57Cyrillic-Condensed.slug",
    universCyrillicBold = "EsoUI/Common/Fonts/Univers67Cyrillic-CondensedBold.slug",
    futuraLight = "EsoUI/Common/Fonts/FTN47.slug",
    futuraMedium = "EsoUI/Common/Fonts/FTN57.slug",
    futuraBold = "EsoUI/Common/Fonts/FTN87.slug",
    esoJapanese = "EsoUI/Common/Fonts/ESO_FWNTLGUDC70-DB.slug",
    esoJapaneseMedium = "EsoUI/Common/Fonts/ESO_FWUDC_70-M.slug",
    chineseMedium = "EsoUI/Common/Fonts/MYingHeiPRC-W5.slug",
    gamepadBold = "$(GAMEPAD_BOLD_FONT)",
    gamepadMedium = "$(GAMEPAD_MEDIUM_FONT)",
    gamepadLight = "$(GAMEPAD_LIGHT_FONT)",
    gamepadNumber = "$(GAMEPAD_MEDIUM_FONT_LATIN)",
    keyboardBold = "$(BOLD_FONT)",
    keyboardMedium = "$(MEDIUM_FONT)",
    chat = "$(CHAT_FONT)",
}

local SOUND_KEYS =
{
    CONSOLE_GAME_ENTER = "CONSOLE_GAME_ENTER",
    RETURNING_PLAYER_OPEN_KEYBOARD = "RETURNING_PLAYER_OPEN_KEYBOARD",
}

local TEXT_EFFECT_ALIASES =
{
    none = "none",
    None = "none",
    shadow = "shadow",
    Shadow = "shadow",
    outline = "outline",
    Outline = "outline",
}

local FALLBACK_SOUND_KEYS =
{
    "CONSOLE_GAME_ENTER",
    "RETURNING_PLAYER_OPEN_KEYBOARD",
}

local function AddFlag(target, key)
    if key ~= nil then
        target[key] = true
    end
end

local function AddSctSetting(target, key, id)
    if id ~= nil then
        table.insert(target, { key = key, id = id })
    end
end

local DAMAGE_RESULTS = {}
AddFlag(DAMAGE_RESULTS, ACTION_RESULT_DAMAGE)
AddFlag(DAMAGE_RESULTS, ACTION_RESULT_CRITICAL_DAMAGE)
AddFlag(DAMAGE_RESULTS, ACTION_RESULT_DOT_TICK)
AddFlag(DAMAGE_RESULTS, ACTION_RESULT_DOT_TICK_CRITICAL)
AddFlag(DAMAGE_RESULTS, ACTION_RESULT_DAMAGE_SHIELDED)
AddFlag(DAMAGE_RESULTS, ACTION_RESULT_BLOCKED_DAMAGE)
AddFlag(DAMAGE_RESULTS, ACTION_RESULT_FALL_DAMAGE)
AddFlag(DAMAGE_RESULTS, ACTION_RESULT_PRECISE_DAMAGE)
AddFlag(DAMAGE_RESULTS, ACTION_RESULT_WRECKING_DAMAGE)

local CRITICAL_RESULTS = {}
AddFlag(CRITICAL_RESULTS, ACTION_RESULT_CRITICAL_DAMAGE)
AddFlag(CRITICAL_RESULTS, ACTION_RESULT_DOT_TICK_CRITICAL)

local SCT_DAMAGE_SETTINGS = {}
AddSctSetting(SCT_DAMAGE_SETTINGS, "outgoingDamage", COMBAT_SETTING_SCT_OUTGOING_DAMAGE_ENABLED)
AddSctSetting(SCT_DAMAGE_SETTINGS, "outgoingDot", COMBAT_SETTING_SCT_OUTGOING_DOT_ENABLED)
AddSctSetting(SCT_DAMAGE_SETTINGS, "outgoingPetDamage", COMBAT_SETTING_SCT_OUTGOING_PET_DAMAGE_ENABLED)
AddSctSetting(SCT_DAMAGE_SETTINGS, "outgoingPetDot", COMBAT_SETTING_SCT_OUTGOING_PET_DOT_ENABLED)
AddSctSetting(SCT_DAMAGE_SETTINGS, "incomingDamage", COMBAT_SETTING_SCT_INCOMING_DAMAGE_ENABLED)
AddSctSetting(SCT_DAMAGE_SETTINGS, "incomingDot", COMBAT_SETTING_SCT_INCOMING_DOT_ENABLED)
AddSctSetting(SCT_DAMAGE_SETTINGS, "incomingPetDamage", COMBAT_SETTING_SCT_INCOMING_PET_DAMAGE_ENABLED)
AddSctSetting(SCT_DAMAGE_SETTINGS, "incomingPetDot", COMBAT_SETTING_SCT_INCOMING_PET_DOT_ENABLED)

local PLAYER_RELATED_SOURCE_TYPES = {}
AddFlag(PLAYER_RELATED_SOURCE_TYPES, COMBAT_UNIT_TYPE_PLAYER)
AddFlag(PLAYER_RELATED_SOURCE_TYPES, COMBAT_UNIT_TYPE_PLAYER_PET)
AddFlag(PLAYER_RELATED_SOURCE_TYPES, COMBAT_UNIT_TYPE_PLAYER_COMPANION)

local PLAYER_RELATED_TARGET_TYPES = {}
AddFlag(PLAYER_RELATED_TARGET_TYPES, COMBAT_UNIT_TYPE_PLAYER)
AddFlag(PLAYER_RELATED_TARGET_TYPES, COMBAT_UNIT_TYPE_PLAYER_PET)
AddFlag(PLAYER_RELATED_TARGET_TYPES, COMBAT_UNIT_TYPE_PLAYER_COMPANION)

local lastCritSoundMS = -DEFAULT_SETTINGS.soundThrottleMS

local function RegisterFilteredCombatEvent(namespace, unitFilterType, unitType, result, callback)
    EVENT_MANAGER:RegisterForEvent(namespace, EVENT_COMBAT_EVENT, callback)
    EVENT_MANAGER:AddFilterForEvent(
        namespace,
        EVENT_COMBAT_EVENT,
        REGISTER_FILTER_IS_ERROR, false,
        REGISTER_FILTER_COMBAT_RESULT, result,
        unitFilterType, unitType
    )
end

local function GetSettings()
    if Nirnsteel_UI.Settings then
        return Nirnsteel_UI.Settings:GetDamageNumbers()
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
    return not Nirnsteel_UI.Settings or Nirnsteel_UI.Settings:IsDamageNumbersEnabled()
end

local function IsDamageEvent(result, hitValue)
    return hitValue and hitValue > 0 and DAMAGE_RESULTS[result]
end

local function IsCriticalResult(result)
    return CRITICAL_RESULTS[result] == true
end

local function IsOutgoingDamage(sourceType)
    return PLAYER_RELATED_SOURCE_TYPES[sourceType] == true
end

local function IsIncomingDamage(targetType)
    return PLAYER_RELATED_TARGET_TYPES[targetType] == true
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

local function ClampNumber(value, minValue, maxValue)
    return math.min(math.max(value, minValue), maxValue)
end

local function BuildFont(size)
    local fontFace = FONT_FACES[GetSettingValue("fontKey")] or FONT_FACES.antique
    local textEffect = TEXT_EFFECT_ALIASES[GetSettingValue("textEffect")] or "none"
    if textEffect == "shadow" then
        return string.format("%s|%d|soft-shadow-thick", fontFace, size)
    end
    if textEffect == "outline" then
        return string.format("%s|%d|thick-outline", fontFace, size)
    end

    return string.format("%s|%d", fontFace, size)
end

local function FormatDamageValue(hitValue)
    return tostring(hitValue)
end

local function GetCritSoundThrottleMS()
    return ClampNumber(GetSettingValue("soundThrottleMS"), 0, 800)
end

local function GetCriticalHitSound()
    local configuredKey = GetSettingValue("critSoundKey")
    local soundName = SOUND_KEYS[configuredKey] or configuredKey
    if soundName and SOUNDS[soundName] then
        return SOUNDS[soundName]
    end

    for _, fallbackKey in ipairs(FALLBACK_SOUND_KEYS) do
        if SOUNDS[fallbackKey] then
            return SOUNDS[fallbackKey]
        end
    end
end

local function PlayCriticalSound()
    if Nirnsteel_UI.Settings and not Nirnsteel_UI.Settings:AreDamageNumberCritSoundsEnabled() then
        return
    end

    local nowMS = GetFrameTimeMilliseconds()
    if nowMS - lastCritSoundMS >= GetCritSoundThrottleMS() then
        local sound = GetCriticalHitSound()
        if sound then
            PlaySound(sound)
        end
        lastCritSoundMS = nowMS
    end
end

local function GetSpawnOriginPosition()
    if Nirnsteel_UI.Settings then
        return Nirnsteel_UI.Settings:GetDamageNumbersPosition()
    end

    return { x = DEFAULT_SPAWN_OFFSET_X, y = DEFAULT_SPAWN_OFFSET_Y }
end

local function IsDamageNumbersUnlocked()
    return IsModuleEnabled()
        and Nirnsteel_UI.Settings
        and Nirnsteel_UI.Settings:IsDamageNumbersUnlocked()
end

function DamageNumbers:GetRoot()
    if self.root then
        return self.root
    end

    local root = WINDOW_MANAGER:CreateTopLevelWindow("Nirnsteel_UI_DamageNumbersRoot")
    root:SetAnchorFill(GuiRoot)
    root:SetMouseEnabled(false)
    root:SetDrawTier(DT_HIGH)
    root:SetHidden(true)
    self.root = root
    return root
end

function DamageNumbers:CreateLabel()
    self.nextLabelId = (self.nextLabelId or 0) + 1

    local label = WINDOW_MANAGER:CreateControl("Nirnsteel_UI_DamageNumber" .. self.nextLabelId, self:GetRoot(), CT_LABEL)
    label:SetDimensions(320, 110)
    label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    label:SetMouseEnabled(false)
    label:SetDrawLayer(DL_OVERLAY)
    label:SetHidden(true)

    return label
end

function DamageNumbers:AcquireLabel()
    self.pool = self.pool or {}
    self.active = self.active or {}

    local maxActive = ClampNumber(GetSettingValue("maxActive"), 8, 80)
    if #self.active >= maxActive then
        return table.remove(self.active, 1)
    end

    local label = table.remove(self.pool)
    if not label then
        label = self:CreateLabel()
    end

    return label
end

function DamageNumbers:ReleaseLabel(index)
    local label = table.remove(self.active, index)
    if label then
        label:SetHidden(true)
        label:SetAlpha(0)
        label.activeDamageNumber = nil
        table.insert(self.pool, label)
    end
end

function DamageNumbers:UpdateLabels()
    local active = self.active
    if not active or #active == 0 then
        self:GetRoot():SetHandler("OnUpdate", nil)
        self:GetRoot():SetHidden(true)
        return
    end

    local nowMS = GetFrameTimeMilliseconds()
    for i = #active, 1, -1 do
        local label = active[i]
        local data = label.activeDamageNumber
        if not data then
            self:ReleaseLabel(i)
        else
            local progress = ClampNumber((nowMS - data.startMS) / data.durationMS, 0, 1)
            if progress >= 1 then
                self:ReleaseLabel(i)
            else
                local moveProgress = EaseOutCubic(progress)
                local alpha = progress < 0.62 and 1 or math.max(0, 1 - ((progress - 0.62) / 0.38))
                local popProgress = ClampNumber(progress / POP_PROGRESS_PORTION, 0, 1)
                local scale = data.endScale + (data.startScale - data.endScale) * (1 - EaseOutBack(popProgress))
                local x = data.startX + ((data.endX - data.startX) * moveProgress)
                local y = data.startY + ((data.endY - data.startY) * moveProgress)

                label:ClearAnchors()
                label:SetAnchor(CENTER, self:GetRoot(), TOPLEFT, x, y)
                label:SetAlpha(alpha)
                label:SetScale(scale)
            end
        end
    end
end

function DamageNumbers:StartUpdating()
    local root = self:GetRoot()
    root:SetHidden(false)
    root:SetHandler("OnUpdate", function()
        self:UpdateLabels()
    end)
end

function DamageNumbers:GetSpawnPosition(direction, spread)
    local position = GetSpawnOriginPosition()
    local centerX = GuiRoot:GetWidth() * 0.5 + position.x
    local centerY = GuiRoot:GetHeight() * 0.5 + position.y
    local directionOffsetX = direction == "incoming" and -92 or 92
    local directionOffsetY = direction == "incoming" and 44 or -34
    local spreadFloor = math.floor(spread)
    local randomX = math.random(-spreadFloor, spreadFloor)
    local randomY = math.random(-math.floor(spreadFloor * 0.52), math.floor(spreadFloor * 0.36))

    return centerX + directionOffsetX + randomX, centerY + directionOffsetY + randomY
end

function DamageNumbers:GetMover()
    if self.mover then
        return self.mover
    end

    local mover = WINDOW_MANAGER:CreateTopLevelWindow("Nirnsteel_UI_DamageNumbersMover")
    mover:SetDimensions(280, 74)
    mover:SetClampedToScreen(true)
    mover:SetMouseEnabled(true)
    mover:SetMovable(false)
    mover:SetDrawTier(DT_HIGH)
    mover:SetHidden(true)

    local backdrop = WINDOW_MANAGER:CreateControl(nil, mover, CT_BACKDROP)
    backdrop:SetAnchorFill(mover)
    backdrop:SetCenterColor(0.02, 0.02, 0.02, 0.58)
    backdrop:SetEdgeColor(1.0, 0.88, 0.1, 0.9)
    backdrop:SetEdgeTexture("", 1, 1, 2)

    local label = WINDOW_MANAGER:CreateControl(nil, mover, CT_LABEL)
    label:SetAnchor(CENTER, mover, CENTER, 0, -8)
    label:SetFont("$(ANTIQUE_FONT)|26")
    label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    label:SetText("680")
    label:SetColor(1.0, 0.91, 0.0, 1)
    mover.previewLabel = label

    local sublabel = WINDOW_MANAGER:CreateControl(nil, mover, CT_LABEL)
    sublabel:SetAnchor(TOP, label, BOTTOM, 0, 2)
    sublabel:SetFont("ZoFontGameSmall")
    sublabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    sublabel:SetText("Damage Number Origin")
    sublabel:SetColor(0.95, 0.86, 0.35, 1)

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
            Nirnsteel_UI.Settings:SetDamageNumbersPosition(x, y)
        end
        self:ApplyMoverState()
    end)

    self.mover = mover
    return mover
end

function DamageNumbers:ApplyMoverState()
    local mover = self:GetMover()
    local position = GetSpawnOriginPosition()

    mover:ClearAnchors()
    mover:SetAnchor(CENTER, GuiRoot, CENTER, position.x, position.y)
    if mover.previewLabel then
        mover.previewLabel:SetFont(BuildFont(26))
    end
    mover:SetHidden(not IsDamageNumbersUnlocked())
end

function DamageNumbers:GetColor(direction, isCrit)
    if isCrit then
        return 1.0, 0.95, 0.02, 1
    end

    if direction == "incoming" then
        return 1.0, 0.57, 0.14, 1
    end

    return 1.0, 0.91, 0.0, 1
end

function DamageNumbers:ShowDamage(hitValue, isCrit, direction)
    if not IsModuleEnabled() or not hitValue or hitValue <= 0 then
        return
    end

    local label = self:AcquireLabel()
    local fontSize = isCrit and GetSettingValue("critFontSize") or GetSettingValue("normalFontSize")
    local durationMS = ClampNumber(GetSettingValue("durationMS"), 450, 1800)
    local spread = ClampNumber(GetSettingValue("spread"), 40, 280)
    local drift = ClampNumber(GetSettingValue("drift"), 0, 160)
    local driftFloor = math.floor(drift * MOVEMENT_MULTIPLIER)
    local bigHitThreshold = GetSettingValue("bigHitThreshold")
    local isBigHit = hitValue >= bigHitThreshold
    local driftScale = isBigHit and BIG_HIT_MOVEMENT_MULTIPLIER or 1
    local startX, startY = self:GetSpawnPosition(direction, spread)
    local driftXDirection = direction == "incoming" and -1 or 1
    local driftX = 0
    local driftY = 0
    local r, g, b, a = self:GetColor(direction, isCrit)

    if driftFloor > 0 then
        driftX = driftXDirection * math.random(math.floor(driftFloor * 0.25), driftFloor) * driftScale
        driftY = -math.random(math.floor(driftFloor * 0.35), math.max(1, math.floor(driftFloor * 0.85))) * driftScale
    end

    label:SetFont(BuildFont(fontSize))
    label:SetText(FormatDamageValue(hitValue))
    label:SetColor(r, g, b, a)
    label:SetDimensions(math.max(320, fontSize * 7), math.max(110, fontSize * 2))
    label:SetHidden(false)
    label:ClearAnchors()
    label:SetAnchor(CENTER, self:GetRoot(), TOPLEFT, startX, startY)
    label:SetScale(isCrit and CRIT_START_SCALE or NORMAL_START_SCALE)
    label:SetAlpha(1)

    label.activeDamageNumber =
    {
        startMS = GetFrameTimeMilliseconds(),
        durationMS = durationMS,
        startX = startX,
        startY = startY,
        endX = startX + driftX,
        endY = startY + driftY,
        startScale = isCrit and CRIT_START_SCALE or NORMAL_START_SCALE,
        endScale = isCrit and CRIT_END_SCALE or NORMAL_END_SCALE,
    }

    table.insert(self.active, label)
    self:StartUpdating()

    if isCrit then
        PlayCriticalSound()
    end
end

function DamageNumbers:ClearLabels()
    if self.active then
        for i = #self.active, 1, -1 do
            self:ReleaseLabel(i)
        end
    end

    if self.root then
        self.root:SetHandler("OnUpdate", nil)
        self.root:SetHidden(true)
    end
end

function DamageNumbers:SuppressDefaultDamageNumbers()
    local settings = GetSettings()
    settings.savedSctSettings = settings.savedSctSettings or {}
    local changedSettings = false

    for _, settingData in ipairs(SCT_DAMAGE_SETTINGS) do
        if settings.savedSctSettings[settingData.key] == nil then
            settings.savedSctSettings[settingData.key] = GetSetting(SETTING_TYPE_COMBAT, settingData.id)
        end
        if GetSetting(SETTING_TYPE_COMBAT, settingData.id) ~= "0" then
            SetSetting(SETTING_TYPE_COMBAT, settingData.id, "0")
            changedSettings = true
        end
    end

    if changedSettings and ApplySettings then
        ApplySettings()
    end
end

function DamageNumbers:RestoreDefaultDamageNumbers()
    local settings = GetSettings()
    local savedSettings = settings.savedSctSettings
    if not savedSettings then
        return
    end

    local changedSettings = false
    for _, settingData in ipairs(SCT_DAMAGE_SETTINGS) do
        local savedValue = savedSettings[settingData.key]
        if savedValue ~= nil then
            if GetSetting(SETTING_TYPE_COMBAT, settingData.id) ~= savedValue then
                SetSetting(SETTING_TYPE_COMBAT, settingData.id, savedValue)
                changedSettings = true
            end
            savedSettings[settingData.key] = nil
        end
    end

    if changedSettings and ApplySettings then
        ApplySettings()
    end
end

function DamageNumbers:ApplySctSettings()
    if IsModuleEnabled() and GetSettingValue("hideDefaultDamage") then
        self:SuppressDefaultDamageNumbers()
    else
        self:RestoreDefaultDamageNumbers()
    end
end

function DamageNumbers:RegisterCombatEvents()
    if self.eventsRegistered then
        return
    end

    local callback = function(_, ...)
        self:OnCombatEvent(...)
    end

    self.eventNamespaces = {}
    for result in pairs(DAMAGE_RESULTS) do
        for unitType in pairs(PLAYER_RELATED_SOURCE_TYPES) do
            local namespace = string.format("%s_Source_%s_%s", EVENT_NAMESPACE, tostring(unitType), tostring(result))
            RegisterFilteredCombatEvent(namespace, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, unitType, result, callback)
            table.insert(self.eventNamespaces, namespace)
        end

        for unitType in pairs(PLAYER_RELATED_TARGET_TYPES) do
            local namespace = string.format("%s_Target_%s_%s", EVENT_NAMESPACE, tostring(unitType), tostring(result))
            RegisterFilteredCombatEvent(namespace, REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, unitType, result, callback)
            table.insert(self.eventNamespaces, namespace)
        end
    end

    self.eventsRegistered = true
end

function DamageNumbers:UnregisterCombatEvents()
    if not self.eventsRegistered then
        return
    end

    for _, namespace in ipairs(self.eventNamespaces or {}) do
        EVENT_MANAGER:UnregisterForEvent(namespace, EVENT_COMBAT_EVENT)
    end
    self.eventNamespaces = nil
    self.eventsRegistered = nil
end

function DamageNumbers:RegisterLifecycleEvents()
    if self.lifecycleEventsRegistered then
        return
    end

    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE .. "_Deactivated", EVENT_PLAYER_DEACTIVATED, function()
        self:RestoreDefaultDamageNumbers()
    end)
    self.lifecycleEventsRegistered = true
end

function DamageNumbers:OnCombatEvent(result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)
    if isError or not IsDamageEvent(result, hitValue) then
        return
    end

    if PLAYER_RELATED_SOURCE_TYPES[sourceType] and PLAYER_RELATED_TARGET_TYPES[targetType] then
        local nowMS = GetFrameTimeMilliseconds()
        if self.lastCombatEventMS == nowMS
            and self.lastCombatResult == result
            and self.lastCombatHitValue == hitValue
            and self.lastCombatSourceUnitId == sourceUnitId
            and self.lastCombatTargetUnitId == targetUnitId
            and self.lastCombatAbilityId == abilityId then
            return
        end
        self.lastCombatEventMS = nowMS
        self.lastCombatResult = result
        self.lastCombatHitValue = hitValue
        self.lastCombatSourceUnitId = sourceUnitId
        self.lastCombatTargetUnitId = targetUnitId
        self.lastCombatAbilityId = abilityId
    end

    local direction
    if IsOutgoingDamage(sourceType) then
        direction = "outgoing"
    elseif IsIncomingDamage(targetType) then
        direction = "incoming"
    else
        return
    end

    self:ShowDamage(hitValue, IsCriticalResult(result), direction)
end

function DamageNumbers:RefreshSettings()
    self:RegisterLifecycleEvents()

    if IsModuleEnabled() then
        self:RegisterCombatEvents()
    else
        self:UnregisterCombatEvents()
        self:ClearLabels()
    end

    self:ApplySctSettings()
    self:ApplyMoverState()
end

function DamageNumbers:DebugNormal()
    self:ShowDamage(math.random(4200, 11800), false, "outgoing")
end

function DamageNumbers:DebugCrit()
    self:ShowDamage(math.random(26000, 88000), true, "outgoing")
end

function DamageNumbers:PreviewCriticalSound()
    lastCritSoundMS = -GetCritSoundThrottleMS()
    PlayCriticalSound()
end

function DamageNumbers:DebugSound()
    self:PreviewCriticalSound()
end

function DamageNumbers:DebugStorm()
    for i = 1, 18 do
        zo_callLater(function()
            local isCrit = math.random(1, 100) <= 28
            local direction = math.random(1, 100) <= 72 and "outgoing" or "incoming"
            local value = isCrit and math.random(18000, 95000) or math.random(1200, 22000)
            self:ShowDamage(value, isCrit, direction)
        end, i * 55)
    end
end

local DEBUG_COMMANDS =
{
    ["/nsdmg"] = function()
        DamageNumbers:DebugNormal()
    end,
    ["/nsdmgcrit"] = function()
        DamageNumbers:DebugCrit()
    end,
    ["/nsdmgsound"] = function()
        DamageNumbers:DebugSound()
    end,
    ["/nsdmgstorm"] = function()
        DamageNumbers:DebugStorm()
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

function DamageNumbers:RefreshDebugCommands()
    RegisterDebugCommands()
end

local function OnAddOnLoaded(_, addonName)
    if addonName ~= ADDON_NAME then
        return
    end

    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE .. "_Loaded", EVENT_ADD_ON_LOADED)
    DamageNumbers:RefreshSettings()
    RegisterDebugCommands()
end

EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE .. "_Loaded", EVENT_ADD_ON_LOADED, OnAddOnLoaded)
