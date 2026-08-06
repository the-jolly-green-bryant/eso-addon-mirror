StonehulkDominationTracker = StonehulkDominationTracker or {}

local SDT = StonehulkDominationTracker

SDT.name = "StonehulkDominationTracker"
SDT.panelId = "StonehulkDominationTrackerOptions"
SDT.savedVarVersion = 1
SDT.version = "1.4.19"

SDT.constants = {
    stonehulkSetId = 827,
    majorVulnerabilityAbilityId = 106754,
    majorVulnerabilityAbilityIds = {
        [106754] = true,
        [106755] = true,
        [106758] = true,
        [106760] = true,
        [106762] = true,
        [122177] = true,
        [122397] = true,
        [122389] = true,
        [132831] = true,
        [148976] = true,
        [163060] = true,
        [167061] = true,
        [176815] = true,
        [192836] = true,
        [195242] = true,
        [226400] = true,
    },
    genericMajorVulnerabilityAbilityIds = {
        [148976] = true,
        [163060] = true,
        [167061] = true,
        [176815] = true,
        [192836] = true,
        [195242] = true,
        [226400] = true,
    },
    timerFontSizeKeyboard = 62,
    timerFontSizeGamepad = 70,
    cooldownFontSizeKeyboard = 24,
    cooldownFontSizeGamepad = 28,
    targetNameFontSizeKeyboard = 18,
    targetNameFontSizeGamepad = 20,
    colossusProcDurationMs = 12000,
    glacialColossusProcDurationMs = 17000,
    stonehulkProcDurationMs = 12000,
    stonehulkCooldownDurationMs = 15000,
    archdruidProcDurationMs = 7000,
    archdruidCooldownDurationMs = 15000,
    ownMajorVulnWindowMs = 1800,
    heavyAttackWindowMs = 3500,
    procDurationToleranceMs = 1800,
    moveModeTimeoutMs = 3000,
    foreignMajorVulnWindowMs = 1500,
    tauntDebuffId = 38254,
    tauntWindowMs = 2500,
    craftedTauntScriptId = 12,
}

SDT.defaults = {
    left = 900,
    top = 340,
    uiScale = 1.00,
    hidden = false,
    moveMode = false,
    showTargetName = true,
    ownProcColor = {
        r = 0.20,
        g = 1.00,
        b = 0.30,
    },
    otherProcColor = {
        r = 0.20,
        g = 1.00,
        b = 0.30,
    },
    cooldownColors = {
        stonehulk = {
            r = 1.00,
            g = 0.20,
            b = 0.20,
        },
        turningtide = {
            r = 0.10,
            g = 0.75,
            b = 1.00,
        },
        archdruid = {
            r = 0.30,
            g = 0.90,
            b = 0.45,
        },
        kynmarcher = {
            r = 0.95,
            g = 0.70,
            b = 0.20,
        },
        coupdegrace = {
            r = 0.95,
            g = 0.45,
            b = 0.85,
        },
        umbraledge = {
            r = 0.70,
            g = 0.60,
            b = 1.00,
        },
    },
}

SDT.cooldownDisplayOrder = {
    "stonehulk",
    "turningtide",
    "archdruid",
    "kynmarcher",
    "coupdegrace",
    "umbraledge",
}

SDT.setDefinitions = {
    stonehulk = {
        displayName = "Stonehulk",
        shortLabel = "Stone",
        requiredPieces = 5,
        setId = 827,
        names = {
            ["stonehulk domination"] = true,
            ["steinkoloss-vorherrschaft"] = true,
            ["steinkoloss vorherrschaft"] = true,
        },
        procDurationMs = 12000,
        cooldownMs = 15000,
    },
    turningtide = {
        displayName = "Turning Tide",
        shortLabel = "Tide",
        requiredPieces = 5,
        names = {
            ["turning tide"] = true,
            ["gezeitenwechsel"] = true,
        },
        procDurationMs = 10000,
        cooldownMs = 15000,
        procAbilityIds = {
            [167350] = true,
        },
    },
    archdruid = {
        displayName = "Erzdruide",
        shortLabel = "Druid",
        requiredPieces = 2,
        names = {
            ["archdruid devyric"] = true,
            ["erzdruide devyric"] = true,
        },
        procDurationMs = 7000,
        cooldownMs = 15000,
        procAbilityIds = {
            [176813] = true,
        },
    },
    kynmarcher = {
        displayName = "Kynmarcher",
        shortLabel = "Kyn",
        requiredPieces = 5,
        names = {
            ["kynmarcher's cruelty"] = true,
            ["kynmarchers cruelty"] = true,
        },
        procDurationMs = 18000,
        cooldownMs = 8000,
        procAbilityIds = {
            [163060] = true,
        },
    },
    coupdegrace = {
        displayName = "Coup",
        shortLabel = "Coup",
        requiredPieces = 5,
        names = {
            ["coup de grâce"] = true,
            ["coup de grace"] = true,
        },
        procDurationMs = 3000,
        cooldownMs = 1000,
    },
    umbraledge = {
        displayName = "Umbral",
        shortLabel = "Umbral",
        requiredPieces = 5,
        names = {
            ["umbral edge"] = true,
        },
        procDurationMs = 5000,
        cooldownMs = 6000,
    },
}

SDT.procAbilityToSetKey = {
    [163060] = "kynmarcher",
    [167350] = "turningtide",
    [176813] = "archdruid",
}

SDT.baseTauntAbilities = {
    [28306] = true,  -- Puncture
    [38250] = true,  -- Pierce Armor
    [38256] = true,  -- Ransack
    [38984] = true,  -- Destructive Clench
    [38985] = true,  -- Flame Clench
    [38989] = true,  -- Frost Clench
    [38993] = true,  -- Shock Clench
    [39114] = true,  -- Deafening Roar
    [39475] = true,  -- Inner Fire
    [42056] = true,  -- Inner Rage
    [42060] = true,  -- Inner Beast
    [183165] = true, -- Runic Jolt
    [183430] = true, -- Runic Sunder
    [186531] = true, -- Runic Embrace
}

SDT.hotbars = {}
SDT.visibleProcUnitTags = {
    "target",
    "reticleover",
}
SDT.dynamicTauntAbilities = {}
SDT.dynamicColossusAbilityDurations = {}
SDT.state = {
    stonehulkEquipped = false,
    archdruidEquipped = false,
    equippedSets = {},
    lastTauntAt = 0,
    lastTauntTargetUnitId = 0,
    lastTauntTargetName = nil,
    lastHeavyAttackAt = 0,
    lastHeavyAttackTargetUnitId = 0,
    lastHeavyAttackTargetName = nil,
    archdruidPendingUntil = 0,
    archdruidPendingTargetName = nil,
    procStartedAt = 0,
    procEndsAt = 0,
    ownProcStates = {},
    stonehulkCooldownEndsAt = 0,
    archdruidCooldownEndsAt = 0,
    cooldownEndsAtBySet = {},
    externalProcEndsAt = 0,
    externalProcTargetUnitId = 0,
    externalProcIsPlayer = false,
    foreignMajorVulnAt = 0,
    foreignMajorVulnTargetUnitId = 0,
    foreignMajorVulnIsPlayer = false,
    ownMajorVulnAt = 0,
    ownMajorVulnTargetUnitId = 0,
    visibleTargetProcEndsAt = 0,
    visibleTargetProcIsOwn = false,
    visibleTargetUnitId = 0,
    visibleTargetName = nil,
    targetName = nil,
    lastConfirmedAt = 0,
    lastConfirmedTargetUnitId = 0,
    lastConfirmedProcType = nil,
}

local function AddHotbarCategory(category)
    if category ~= nil then
        table.insert(SDT.hotbars, category)
    end
end

AddHotbarCategory(HOTBAR_CATEGORY_PRIMARY)
AddHotbarCategory(HOTBAR_CATEGORY_BACKUP)
AddHotbarCategory(HOTBAR_CATEGORY_OVERLOAD)
AddHotbarCategory(HOTBAR_CATEGORY_WEREWOLF)

local function NowMs()
    return GetGameTimeMilliseconds()
end

local function NormalizeString(value)
    if value == nil or value == "" then
        return ""
    end

    local normalized = zo_strformat("<<z:1>>", value)
    normalized = normalized:lower()
    normalized = normalized:gsub("%^%a+", "")
    normalized = normalized:gsub("|c%x%x%x%x%x%x", "")
    normalized = normalized:gsub("|r", "")
    normalized = normalized:gsub("[-_]", " ")
    normalized = normalized:gsub("%s+", " ")
    normalized = normalized:gsub("^%s+", "")
    normalized = normalized:gsub("%s+$", "")
    return normalized
end

local function FormatDisplayName(value)
    if value == nil or value == "" then
        return ""
    end

    return zo_strformat(SI_UNIT_NAME, value)
end

local function SafeNumber(value)
    if type(value) == "number" then
        return value
    end

    return 0
end

local function TargetsMatch(savedUnitId, currentUnitId, savedName, currentName)
    local leftUnitId = SafeNumber(savedUnitId)
    local rightUnitId = SafeNumber(currentUnitId)

    if leftUnitId ~= 0 and rightUnitId ~= 0 then
        return leftUnitId == rightUnitId
    end

    local leftName = NormalizeString(savedName)
    local rightName = NormalizeString(currentName)

    if leftName ~= "" and rightName ~= "" then
        return leftName == rightName
    end

    return leftUnitId == 0 or rightUnitId == 0
end

local function NamesLookRelated(savedName, currentName)
    local leftName = NormalizeString(savedName)
    local rightName = NormalizeString(currentName)

    if leftName == "" or rightName == "" then
        return false
    end

    return leftName == rightName
        or zo_plainstrfind(leftName, rightName)
        or zo_plainstrfind(rightName, leftName)
end

local function GetColossusDurationFromAbilityName(constants, normalizedAbilityName)
    if normalizedAbilityName == "" then
        return nil
    end

    if normalizedAbilityName == "glacial colossus"
        or normalizedAbilityName == "gletscherkoloss" then
        return constants.glacialColossusProcDurationMs
    end

    if normalizedAbilityName == "frozen colossus"
        or normalizedAbilityName == "gefrorener koloss"
        or normalizedAbilityName == "pestilent colossus"
        or normalizedAbilityName == "pestilenzkoloss" then
        return constants.colossusProcDurationMs
    end

    return nil
end

function SDT:IsTrackingEnabled(nowMs)
    nowMs = nowMs or NowMs()
    self:RefreshDisplayedOwnProcState(nowMs)
    return next(self.state.equippedSets) ~= nil
        or self:IsProcActive(nowMs)
        or self:HasExternalProc(nowMs)
        or self:HasVisibleTargetProc(nowMs)
end

function SDT:HasTrackedSetEquipped()
    return next(self.state.equippedSets) ~= nil
end

function SDT:IsSetEquipped(setKey)
    return self.state.equippedSets[setKey] == true
end

function SDT:CanAutoActivateSet(setKey)
    local setDefinition = self:GetSetDefinition(setKey)
    if not setDefinition then
        return false
    end

    if self:IsSetEquipped(setKey) then
        return true
    end

    return setKey == "stonehulk"
        or setKey == "archdruid"
        or setDefinition.procAbilityIds ~= nil
end

function SDT:ActivateTrackedSet(setKey)
    self.state.equippedSets[setKey] = true
    if setKey == "stonehulk" then
        self.state.stonehulkEquipped = true
    elseif setKey == "archdruid" then
        self.state.archdruidEquipped = true
    end
end

function SDT:GetSetDefinition(setKey)
    return self.setDefinitions[setKey]
end

function SDT:GetSetCooldownEnd(setKey)
    return self.state.cooldownEndsAtBySet[setKey] or 0
end

function SDT:SetSetCooldownEnd(setKey, cooldownEndMs)
    self.state.cooldownEndsAtBySet[setKey] = cooldownEndMs
    if setKey == "stonehulk" then
        self.state.stonehulkCooldownEndsAt = cooldownEndMs
    elseif setKey == "archdruid" then
        self.state.archdruidCooldownEndsAt = cooldownEndMs
    end
end

function SDT:IsSetReady(setKey, nowMs)
    return nowMs >= self:GetSetCooldownEnd(setKey)
end

function SDT:IsMajorVulnerabilityAbilityId(abilityId)
    return self.constants.majorVulnerabilityAbilityIds[abilityId] == true
end

function SDT:IsGenericMajorVulnerabilityAbilityId(abilityId)
    return self.constants.genericMajorVulnerabilityAbilityIds[abilityId] == true
end

function SDT:IsStonehulkReady(nowMs)
    return self:IsSetReady("stonehulk", nowMs)
end

function SDT:IsArchdruidReady(nowMs)
    return self:IsSetReady("archdruid", nowMs)
end

function SDT:HasAnyCooldownActive(nowMs)
    for setKey in pairs(self.state.equippedSets) do
        if nowMs < self:GetSetCooldownEnd(setKey) then
            return true
        end
    end

    return false
end

function SDT:IsProcActive(nowMs)
    nowMs = nowMs or NowMs()
    self:RefreshDisplayedOwnProcState(nowMs)
    return nowMs < self.state.procEndsAt
end

function SDT:ResetTimers()
    self.state.lastTauntAt = 0
    self.state.lastTauntTargetUnitId = 0
    self.state.lastTauntTargetName = nil
    self.state.lastHeavyAttackAt = 0
    self.state.lastHeavyAttackTargetUnitId = 0
    self.state.lastHeavyAttackTargetName = nil
    self.state.archdruidPendingUntil = 0
    self.state.archdruidPendingTargetName = nil
    self.state.procStartedAt = 0
    self.state.procEndsAt = 0
    self.state.ownProcStates = {}
    self.state.stonehulkCooldownEndsAt = 0
    self.state.archdruidCooldownEndsAt = 0
    self.state.cooldownEndsAtBySet = {}
    self.state.externalProcEndsAt = 0
    self.state.externalProcTargetUnitId = 0
    self.state.externalProcIsPlayer = false
    self.state.foreignMajorVulnAt = 0
    self.state.foreignMajorVulnTargetUnitId = 0
    self.state.foreignMajorVulnIsPlayer = false
    self.state.ownMajorVulnAt = 0
    self.state.ownMajorVulnTargetUnitId = 0
    self.state.visibleTargetProcEndsAt = 0
    self.state.visibleTargetProcIsOwn = false
    self.state.visibleTargetUnitId = 0
    self.state.visibleTargetName = nil
    self.state.targetName = nil
    self.state.lastConfirmedAt = 0
    self.state.lastConfirmedTargetUnitId = 0
    self.state.lastConfirmedProcType = nil
end

function SDT:HandleCombatState(_, inCombat)
    if inCombat then
        return
    end

    self:ResetTimers()
    self:UpdateUI()
end

function SDT:ApplyLockState()
    if not self.window then
        return
    end

    self.window:SetMouseEnabled(true)
    self.window:SetMovable(true)
end

function SDT:SetShowTargetName(enabled)
    self.sv.showTargetName = enabled and true or false
    self:UpdateUI()
end

function SDT:ResetPosition()
    self.sv.left = self.defaults.left
    self.sv.top = self.defaults.top
    self:RefreshAnchors()
    self:SaveWindowPosition()
end

function SDT:ApplyWindowScale()
    if not self.window or not self.window.SetScale then
        return
    end

    local scale = tonumber(self.sv.uiScale) or self.defaults.uiScale or 1.00
    if scale < 0.50 then
        scale = 0.50
    elseif scale > 2.00 then
        scale = 2.00
    end

    self.window:SetScale(scale)
end

function SDT:SetUIScale(value)
    local scale = tonumber(value) or self.defaults.uiScale or 1.00
    if scale < 0.50 then
        scale = 0.50
    elseif scale > 2.00 then
        scale = 2.00
    end

    self.sv.uiScale = scale
    self:ApplyWindowScale()
    self:RefreshAnchors()
    self:UpdateUI()
end

function SDT:RefreshAnchors()
    if not self.window then
        return
    end

    self.window:ClearAnchors()
    self.window:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, self.sv.left, self.sv.top)
end

function SDT:SaveWindowPosition()
    if not self.window then
        return
    end

    self.sv.left = SafeNumber(self.window:GetLeft())
    self.sv.top = SafeNumber(self.window:GetTop())
end

function SDT:SetHidden(hidden)
    if hidden and self.sv.moveMode then
        self:SetMoveMode(false)
    end

    self.sv.hidden = hidden and true or false
    if self.window then
        self.window:SetHidden(self.sv.hidden)
    end
end

function SDT:SetMoveOverlayHidden(hidden)
    if self.moveOverlay then
        self.moveOverlay:SetHidden(hidden)
    end
end

function SDT:SetMoveMode(enabled)
    enabled = enabled and true or false

    if enabled and self.sv.hidden then
        self:SetHidden(false)
    end

    self.sv.moveMode = enabled

    EVENT_MANAGER:UnregisterForUpdate(self.name .. "MoveMode")
    if enabled then
        self.lastMoveInputAt = NowMs()
        self:SetMoveOverlayHidden(false)
        if SCENE_MANAGER and SCENE_MANAGER.IsInUIMode and SCENE_MANAGER.SetInUIMode then
            self.moveModePreviousInUIMode = SCENE_MANAGER:IsInUIMode()
            if not self.moveModePreviousInUIMode then
                SCENE_MANAGER:SetInUIMode(true)
            end
        end
        if SetGameCameraUIMode then
            self.moveModePreviousCameraUIMode = IsGameCameraUIModeActive and IsGameCameraUIModeActive() or false
            if not self.moveModePreviousCameraUIMode then
                SetGameCameraUIMode(true)
            end
        end
        EVENT_MANAGER:RegisterForUpdate(self.name .. "MoveMode", 16, function()
            self:UpdateMoveMode()
        end)
    else
        self:SetMoveOverlayHidden(true)
        if SCENE_MANAGER and SCENE_MANAGER.SetInUIMode and self.moveModePreviousInUIMode == false then
            SCENE_MANAGER:SetInUIMode(false)
        end
        self.moveModePreviousInUIMode = nil
        if SetGameCameraUIMode and self.moveModePreviousCameraUIMode == false then
            SetGameCameraUIMode(false)
        end
        self.moveModePreviousCameraUIMode = nil
        self.lastMoveInputAt = nil
        self:SaveWindowPosition()
    end
end

function SDT:UpdateMoveMode()
    if not self.window or self.sv.hidden then
        return
    end

    local nowMs = NowMs()

    if SCENE_MANAGER and SCENE_MANAGER.IsInUIMode and SCENE_MANAGER.SetInUIMode and not SCENE_MANAGER:IsInUIMode() then
        SCENE_MANAGER:SetInUIMode(true)
    end
    if SetGameCameraUIMode and IsGameCameraUIModeActive and not IsGameCameraUIModeActive() then
        SetGameCameraUIMode(true)
    end

    if not GetGamepadRightStickX or not GetGamepadRightStickY then
        return
    end

    local stickX = GetGamepadRightStickX(GAMEPAD_INCLUDE_DEADZONE)
    local stickY = GetGamepadRightStickY(GAMEPAD_INCLUDE_DEADZONE)
    if stickX == nil or stickY == nil then
        return
    end

    local absX = math.abs(stickX)
    local absY = math.abs(stickY)
    if absX < 0.05 and absY < 0.05 then
        if self.lastMoveInputAt and (nowMs - self.lastMoveInputAt) >= self.constants.moveModeTimeoutMs then
            self:SetMoveMode(false)
        end
        return
    end

    local moveSpeed = 22
    local offsetX = math.floor((stickX * moveSpeed) + (stickX >= 0 and 0.5 or -0.5))
    local offsetY = math.floor(((-stickY) * moveSpeed) + ((-stickY) >= 0 and 0.5 or -0.5))
    if offsetX == 0 and offsetY == 0 then
        return
    end

    self.sv.left = self.sv.left + offsetX
    self.sv.top = self.sv.top + offsetY
    self.lastMoveInputAt = nowMs
    self:RefreshAnchors()
    self:SaveWindowPosition()
end

function SDT:CreateLabel(parent, font, red, green, blue, anchorTo, anchorPoint, relativePoint, offsetX, offsetY, width, align)
    local label = WINDOW_MANAGER:CreateControl(nil, parent, CT_LABEL)
    label:SetFont(font)
    label:SetColor(red, green, blue, 1)
    label:SetAnchor(anchorPoint, anchorTo, relativePoint, offsetX, offsetY)
    label:SetDimensions(width, 20)
    label:SetHorizontalAlignment(align or TEXT_ALIGN_CENTER)
    if label.SetVerticalAlignment then
        label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    end
    label:SetDrawLayer(DL_OVERLAY)
    label:SetDrawTier(DT_HIGH)
    return label
end

function SDT:CreateValueLabelGroup(parent, font, red, green, blue, anchorTo, anchorPoint, relativePoint, offsetX, offsetY, width, align)
    local shadows = {
        self:CreateLabel(parent, font, 0.02, 0.02, 0.02, anchorTo, anchorPoint, relativePoint, offsetX + 4, offsetY + 3, width, align),
        self:CreateLabel(parent, font, 0.02, 0.02, 0.02, anchorTo, anchorPoint, relativePoint, offsetX + 0, offsetY + 3, width, align),
        self:CreateLabel(parent, font, 0.02, 0.02, 0.02, anchorTo, anchorPoint, relativePoint, offsetX + 4, offsetY - 3, width, align),
        self:CreateLabel(parent, font, 0.02, 0.02, 0.02, anchorTo, anchorPoint, relativePoint, offsetX + 0, offsetY - 3, width, align),
    }
    local label = self:CreateLabel(parent, font, red, green, blue, anchorTo, anchorPoint, relativePoint, offsetX + 2, offsetY, width, align)

    for _, shadow in ipairs(shadows) do
        shadow:SetDimensions(width, 46)
    end
    label:SetDimensions(width, 46)

    return shadows, label
end

function SDT:GetTimerFont()
    if self:IsGamepadMode() then
        return string.format("$(GAMEPAD_BOLD_FONT)|%d|soft-shadow-thick", self.constants.timerFontSizeGamepad)
    end

    return string.format("$(BOLD_FONT)|%d|soft-shadow-thick", self.constants.timerFontSizeKeyboard)
end

function SDT:GetCooldownFont()
    return self:GetTimerFont()
end

function SDT:GetTargetNameFont()
    if self:IsGamepadMode() then
        return string.format("$(GAMEPAD_BOLD_FONT)|%d|soft-shadow-thick", self.constants.targetNameFontSizeGamepad)
    end

    return string.format("$(BOLD_FONT)|%d|soft-shadow-thick", self.constants.targetNameFontSizeKeyboard)
end

function SDT:IsGamepadMode()
    return IsInGamepadPreferredMode and IsInGamepadPreferredMode() or false
end

function SDT:RefreshFonts(force)
    if not self.window then
        return
    end

    local isGamepadMode = self:IsGamepadMode()
    if not force and self.lastFontMode == isGamepadMode then
        return
    end

    self.lastFontMode = isGamepadMode

    local timerFont = self:GetTimerFont()
    local cooldownFont = self:GetCooldownFont()
    local targetNameFont = self:GetTargetNameFont()

    for _, label in ipairs(self.timerShadows or {}) do
        label:SetFont(timerFont)
    end
    if self.timerLabel then
        self.timerLabel:SetFont(timerFont)
    end

    for _, slotData in ipairs(self.cooldownSlots or {}) do
        for _, label in ipairs(slotData.shadows or {}) do
            label:SetFont(cooldownFont)
        end
        if slotData.label then
            slotData.label:SetFont(cooldownFont)
        end
    end

    if self.targetNameShadow then
        self.targetNameShadow:SetFont(targetNameFont)
    end
    if self.targetNameLabel then
        self.targetNameLabel:SetFont(targetNameFont)
    end
end

function SDT:CreateUI()
    local moveOverlay = WINDOW_MANAGER:CreateTopLevelWindow(self.name .. "MoveOverlay")
    moveOverlay:SetAnchorFill(GuiRoot)
    moveOverlay:SetDrawLayer(DL_OVERLAY)
    moveOverlay:SetDrawTier(DT_HIGH)
    moveOverlay:SetMouseEnabled(false)
    moveOverlay:SetHidden(true)

    local dim = WINDOW_MANAGER:CreateControl(nil, moveOverlay, CT_BACKDROP)
    dim:SetAnchorFill(moveOverlay)
    dim:SetCenterColor(0, 0, 0, 0.10)
    dim:SetEdgeColor(0, 0, 0, 0)

    local function CreateOverlayLine(anchorPoint, anchorTo, relativePoint, offsetX, offsetY, width, height, alpha)
        local line = WINDOW_MANAGER:CreateControl(nil, moveOverlay, CT_BACKDROP)
        line:SetAnchor(anchorPoint, anchorTo, relativePoint, offsetX, offsetY)
        line:SetDimensions(width, height)
        line:SetCenterColor(1, 1, 1, alpha or 0.25)
        line:SetEdgeColor(0, 0, 0, 0)
        return line
    end

    CreateOverlayLine(CENTER, moveOverlay, CENTER, 0, 0, GuiRoot:GetWidth(), 2, 0.45)
    CreateOverlayLine(CENTER, moveOverlay, CENTER, 0, 0, 2, GuiRoot:GetHeight(), 0.45)
    CreateOverlayLine(CENTER, moveOverlay, CENTER, 0, -220, GuiRoot:GetWidth(), 1, 0.18)
    CreateOverlayLine(CENTER, moveOverlay, CENTER, 0, 220, GuiRoot:GetWidth(), 1, 0.18)
    CreateOverlayLine(CENTER, moveOverlay, CENTER, -220, 0, 1, GuiRoot:GetHeight(), 0.18)
    CreateOverlayLine(CENTER, moveOverlay, CENTER, 220, 0, 1, GuiRoot:GetHeight(), 0.18)

    local moveOverlayLabel = WINDOW_MANAGER:CreateControl(nil, moveOverlay, CT_LABEL)
    moveOverlayLabel:SetFont("$(GAMEPAD_BOLD_FONT)|28|soft-shadow-thick")
    moveOverlayLabel:SetColor(1, 1, 1, 0.95)
    moveOverlayLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    moveOverlayLabel:SetAnchor(TOP, moveOverlay, TOP, 0, 80)
    moveOverlayLabel:SetText("Move UI aktiv")

    local window = WINDOW_MANAGER:CreateTopLevelWindow(self.name .. "Window")
    window:SetDimensions(196, 250)
    window:SetClampedToScreen(true)
    window:SetDrawLayer(DL_OVERLAY)
    window:SetDrawTier(DT_HIGH)
    window:SetHidden(self.sv.hidden)
    window:SetHandler("OnMouseDown", function(control, button)
        if button == MOUSE_BUTTON_INDEX_LEFT then
            control:StartMoving()
        end
    end)
    window:SetHandler("OnMouseUp", function(control, button)
        if button == MOUSE_BUTTON_INDEX_LEFT then
            control:StopMovingOrResizing()
            self:SaveWindowPosition()
        end
    end)

    local icon = WINDOW_MANAGER:CreateControl(nil, window, CT_TEXTURE)
    icon:SetDimensions(112, 112)
    icon:SetAnchor(CENTER, window, CENTER, 0, -30)
    icon:SetTexture(GetAbilityIcon(self.constants.majorVulnerabilityAbilityId))

    local overlay = WINDOW_MANAGER:CreateControl(nil, window, CT_CONTROL)
    overlay:SetDimensions(112, 112)
    overlay:SetAnchor(CENTER, icon, CENTER, 0, 0)
    overlay:SetMouseEnabled(false)
    overlay:SetDrawLayer(DL_OVERLAY)
    overlay:SetDrawTier(DT_HIGH)

    local timerFont = self:GetTimerFont()
    local timerShadows, timerLabel = self:CreateValueLabelGroup(overlay, timerFont, 0.20, 1.00, 0.30, overlay, CENTER, CENTER, -2, -15, 112, TEXT_ALIGN_CENTER)

    local cooldownFont = self:GetCooldownFont()
    local cooldownSlotConfigs = {
        { anchorPoint = TOPLEFT, relativePoint = BOTTOMLEFT, offsetX = -10, offsetY = -10, align = TEXT_ALIGN_LEFT },
        { anchorPoint = TOPRIGHT, relativePoint = BOTTOMRIGHT, offsetX = 10, offsetY = -10, align = TEXT_ALIGN_RIGHT },
        { anchorPoint = TOPLEFT, relativePoint = BOTTOMLEFT, offsetX = -10, offsetY = 50, align = TEXT_ALIGN_LEFT },
        { anchorPoint = TOPRIGHT, relativePoint = BOTTOMRIGHT, offsetX = 10, offsetY = 50, align = TEXT_ALIGN_RIGHT },
    }
    local cooldownSlots = {}

    for _, slotConfig in ipairs(cooldownSlotConfigs) do
        local slotShadows, slotLabel = self:CreateValueLabelGroup(
            window,
            cooldownFont,
            1.00,
            0.20,
            0.20,
            icon,
            slotConfig.anchorPoint,
            slotConfig.relativePoint,
            slotConfig.offsetX,
            slotConfig.offsetY,
            92,
            slotConfig.align
        )

        for _, shadow in ipairs(slotShadows) do
            shadow:SetDimensions(92, 46)
        end
        slotLabel:SetDimensions(92, 46)

        table.insert(cooldownSlots, {
            shadows = slotShadows,
            label = slotLabel,
        })
    end

    local targetNameFont = self:GetTargetNameFont()
    local targetNameShadow = self:CreateLabel(window, targetNameFont, 0.02, 0.02, 0.02, icon, BOTTOM, TOP, 1, -4, 196)
    local targetNameLabel = self:CreateLabel(window, targetNameFont, 0.95, 0.95, 0.95, icon, BOTTOM, TOP, 0, -6, 196)
    targetNameShadow:SetDimensions(196, 24)
    targetNameLabel:SetDimensions(196, 24)

    self.moveOverlay = moveOverlay
    self.window = window
    self.iconTexture = icon
    self.overlay = overlay
    self.timerShadows = timerShadows
    self.timerLabel = timerLabel
    self.cooldownSlots = cooldownSlots
    self.targetNameShadow = targetNameShadow
    self.targetNameLabel = targetNameLabel

    self:RefreshFonts(true)
    self:ApplyWindowScale()
    self:RefreshAnchors()
    self:ApplyLockState()
    self:SetMoveOverlayHidden(true)
end

function SDT:GetOwnProcColor()
    local color = self.sv.ownProcColor or self.defaults.ownProcColor
    return color.r or 0.20, color.g or 1.00, color.b or 0.30
end

function SDT:GetOtherProcColor()
    local color = self.sv.otherProcColor or self.defaults.otherProcColor
    return color.r or 0.20, color.g or 1.00, color.b or 0.30
end

function SDT:GetCooldownSetColor(setKey)
    local defaultColor = (self.defaults.cooldownColors and self.defaults.cooldownColors[setKey]) or { r = 1.00, g = 0.20, b = 0.20 }
    local color = (self.sv.cooldownColors and self.sv.cooldownColors[setKey]) or defaultColor
    return color.r or defaultColor.r, color.g or defaultColor.g, color.b or defaultColor.b
end

function SDT:SetCooldownSetColor(setKey, red, green, blue)
    self.sv.cooldownColors = self.sv.cooldownColors or {}
    self.sv.cooldownColors[setKey] = {
        r = red,
        g = green,
        b = blue,
    }
    self:UpdateUI()
end

function SDT:SetOwnProcColor(red, green, blue)
    self.sv.ownProcColor = {
        r = red,
        g = green,
        b = blue,
    }
    self:UpdateUI()
end

function SDT:SetOtherProcColor(red, green, blue)
    self.sv.otherProcColor = {
        r = red,
        g = green,
        b = blue,
    }
    self:UpdateUI()
end

function SDT:RegisterSettings()
    local LAM = LibAddonMenu2 or (LibStub and LibStub("LibAddonMenu-2.0", true))
    if not LAM then
        return
    end

    local panelData = {
        type = "panel",
        name = "Stonehulk Domination Tracker",
        displayName = "Stonehulk Domination Tracker",
        author = "Codex",
        version = self.version,
        registerForRefresh = true,
        registerForDefaults = false,
    }

    local optionsData = {
        {
            type = "description",
            text = "Tracks Major Vulnerability and Major-Vulnerability-Set-Cooldowns wie Stonehulk, Turning Tide, Erzdruide, Kynmarcher, Coup und Umbral Edge.",
            width = "full",
        },
        {
            type = "button",
            name = "Move UI",
            tooltip = "Startet den Move-Mode. Beendet sich nach 3 Sekunden ohne Bewegung automatisch.",
            func = function()
                self:SetMoveMode(true)
            end,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Tracker anzeigen",
            getFunc = function()
                return not self.sv.hidden
            end,
            setFunc = function(value)
                self:SetHidden(not value)
            end,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Zielname anzeigen",
            getFunc = function()
                return self.sv.showTargetName
            end,
            setFunc = function(value)
                self:SetShowTargetName(value)
            end,
            width = "full",
        },
        {
            type = "slider",
            name = "UI-Groesse",
            tooltip = "Skaliert den kompletten Tracker groesser oder kleiner.",
            min = 60,
            max = 160,
            step = 5,
            getFunc = function()
                return zo_round((self.sv.uiScale or self.defaults.uiScale or 1.00) * 100)
            end,
            setFunc = function(value)
                self:SetUIScale((value or 100) / 100)
            end,
            width = "full",
        },
        {
            type = "colorpicker",
            name = "Meine Farbe",
            tooltip = "Farbe fuer deinen eigenen Stonehulk-Proc.",
            getFunc = function()
                return self:GetOwnProcColor()
            end,
            setFunc = function(red, green, blue)
                self:SetOwnProcColor(red, green, blue)
            end,
            width = "full",
        },
        {
            type = "colorpicker",
            name = "Andere Spieler Farbe",
            tooltip = "Farbe fuer externe Major Vulnerability von anderen Spielern.",
            getFunc = function()
                return self:GetOtherProcColor()
            end,
            setFunc = function(red, green, blue)
                self:SetOtherProcColor(red, green, blue)
            end,
            width = "full",
        },
    }

    table.insert(optionsData, {
        type = "description",
        text = "Cooldown-Farben pro Set:",
        width = "full",
    })

    for _, setKey in ipairs(self.cooldownDisplayOrder) do
        local currentSetKey = setKey
        local setDefinition = self:GetSetDefinition(currentSetKey)
        table.insert(optionsData, {
            type = "colorpicker",
            name = string.format("%s Cooldown-Farbe", setDefinition.displayName),
            getFunc = function()
                return self:GetCooldownSetColor(currentSetKey)
            end,
            setFunc = function(red, green, blue)
                self:SetCooldownSetColor(currentSetKey, red, green, blue)
            end,
            width = "full",
        })
    end

    table.insert(optionsData, {
        type = "button",
        name = "Position zuruecksetzen",
        func = function()
            self:ResetPosition()
        end,
        width = "full",
    })

    LAM:RegisterAddonPanel(self.panelId, panelData)
    LAM:RegisterOptionControls(self.panelId, optionsData)
end

function SDT:RefreshSlottedTaunts()
    ZO_ClearTable(self.dynamicTauntAbilities)
    ZO_ClearTable(self.dynamicColossusAbilityDurations)

    for _, hotbarCategory in ipairs(self.hotbars) do
        for slotIndex = 3, 8 do
            local actionType = GetSlotType(slotIndex, hotbarCategory)
            local boundAbilityId = GetSlotBoundId(slotIndex, hotbarCategory)

            if boundAbilityId ~= nil and boundAbilityId ~= 0 then
                local normalizedAbilityName = NormalizeString(GetAbilityName(boundAbilityId))
                local colossusDurationMs = GetColossusDurationFromAbilityName(self.constants, normalizedAbilityName)
                if colossusDurationMs ~= nil then
                    self.dynamicColossusAbilityDurations[boundAbilityId] = colossusDurationMs
                end
            end

            if actionType == ACTION_TYPE_CRAFTED_ABILITY then
                local craftedAbilityId = boundAbilityId
                if craftedAbilityId ~= nil and craftedAbilityId ~= 0 then
                    local scriptId = GetCraftedAbilityActiveScriptIds(craftedAbilityId)
                    if scriptId == self.constants.craftedTauntScriptId then
                        self.dynamicTauntAbilities[craftedAbilityId] = true
                    end
                end
            end
        end
    end
end

function SDT:IsTauntAbility(abilityId)
    return self.baseTauntAbilities[abilityId] or self.dynamicTauntAbilities[abilityId]
end

function SDT:GetColossusDurationForAbilityId(abilityId)
    return self.dynamicColossusAbilityDurations[abilityId]
end

function SDT:IsMatchingSetLink(itemLink, setKey)
    if itemLink == nil or itemLink == "" then
        return false
    end

    local hasSet, setName, _, _, _, setId = GetItemLinkSetInfo(itemLink, true)
    if not hasSet then
        return false
    end

    local setDefinition = self:GetSetDefinition(setKey)
    if not setDefinition then
        return false
    end

    if setDefinition.setId ~= nil and setId == setDefinition.setId then
        return true
    end

    local normalizedSetName = NormalizeString(setName)
    return setDefinition.names[normalizedSetName] == true
end

function SDT:IsStonehulkLink(itemLink)
    return self:IsMatchingSetLink(itemLink, "stonehulk")
end

function SDT:IsArchdruidLink(itemLink)
    return self:IsMatchingSetLink(itemLink, "archdruid")
end

function SDT:RefreshTrackedSets()
    local setCounts = {}
    for setKey in pairs(self.setDefinitions) do
        setCounts[setKey] = 0
    end

    for slotIndex = EQUIP_SLOT_ITERATION_BEGIN, EQUIP_SLOT_ITERATION_END do
        local itemLink = GetItemLink(BAG_WORN, slotIndex, LINK_STYLE_DEFAULT)

        for setKey in pairs(self.setDefinitions) do
            if self:IsMatchingSetLink(itemLink, setKey) then
                setCounts[setKey] = setCounts[setKey] + 1
            end
        end
    end

    local equippedSets = {}
    for _, setKey in ipairs(self.cooldownDisplayOrder) do
        local setDefinition = self:GetSetDefinition(setKey)
        if setDefinition and (setCounts[setKey] or 0) >= setDefinition.requiredPieces then
            equippedSets[setKey] = true
        end
    end

    self.state.equippedSets = equippedSets
    self.state.stonehulkEquipped = self:IsSetEquipped("stonehulk")
    self.state.archdruidEquipped = self:IsSetEquipped("archdruid")

    for setKey in pairs(self.state.cooldownEndsAtBySet) do
        if not self:IsSetEquipped(setKey) then
            self.state.cooldownEndsAtBySet[setKey] = nil
        end
    end

    self.state.stonehulkCooldownEndsAt = self:GetSetCooldownEnd("stonehulk")
    self.state.archdruidCooldownEndsAt = self:GetSetCooldownEnd("archdruid")

    if not self:HasTrackedSetEquipped() and not self:IsProcActive(NowMs()) and not self:HasExternalProc(NowMs()) then
        self:ResetTimers()
    end
end

function SDT:RememberTaunt(targetUnitId, targetName)
    self.state.lastTauntAt = NowMs()
    self.state.lastTauntTargetUnitId = SafeNumber(targetUnitId)
    self.state.lastTauntTargetName = targetName
end

function SDT:RememberHeavyAttack(targetUnitId, targetName)
    local nowMs = NowMs()
    self.state.lastHeavyAttackAt = nowMs
    self.state.lastHeavyAttackTargetUnitId = SafeNumber(targetUnitId)
    self.state.lastHeavyAttackTargetName = targetName
    self.state.archdruidPendingUntil = nowMs + self.constants.heavyAttackWindowMs
    self.state.archdruidPendingTargetName = targetName
end

function SDT:HasRecentMatchingTaunt(targetUnitId, targetName)
    local nowMs = NowMs()
    if (nowMs - self.state.lastTauntAt) > self.constants.tauntWindowMs then
        return false
    end

    return TargetsMatch(self.state.lastTauntTargetUnitId, targetUnitId, self.state.lastTauntTargetName, targetName)
end

function SDT:HasRecentMatchingHeavyAttack(targetUnitId, targetName)
    local nowMs = NowMs()
    if (nowMs - self.state.lastHeavyAttackAt) > self.constants.heavyAttackWindowMs then
        return false
    end

    return TargetsMatch(self.state.lastHeavyAttackTargetUnitId, targetUnitId, self.state.lastHeavyAttackTargetName, targetName)
end

function SDT:HasPendingArchdruidProc(nowMs, targetUnitId, targetName)
    if nowMs > self.state.archdruidPendingUntil then
        return false
    end

    return TargetsMatch(self.state.lastHeavyAttackTargetUnitId, targetUnitId, self.state.archdruidPendingTargetName, targetName)
end

function SDT:ConsumePendingArchdruidProc()
    self.state.archdruidPendingUntil = 0
    self.state.archdruidPendingTargetName = nil
end

function SDT:GetRecentProcPreference(targetUnitId, targetName)
    local hasTaunt = self:HasRecentMatchingTaunt(targetUnitId, targetName)
    local hasHeavyAttack = self:HasRecentMatchingHeavyAttack(targetUnitId, targetName)

    if hasTaunt and hasHeavyAttack then
        if self.state.lastHeavyAttackAt >= self.state.lastTauntAt then
            return "archdruid"
        end

        return "stonehulk"
    end

    if hasHeavyAttack then
        return "archdruid"
    end

    if hasTaunt then
        return "stonehulk"
    end

    return nil
end

function SDT:MarkForeignMajorVuln(targetUnitId, isPlayerSource)
    self.state.foreignMajorVulnAt = NowMs()
    self.state.foreignMajorVulnTargetUnitId = SafeNumber(targetUnitId)
    self.state.foreignMajorVulnIsPlayer = isPlayerSource and true or false
end

function SDT:HasRecentForeignMajorVuln(targetUnitId)
    local nowMs = NowMs()
    if (nowMs - self.state.foreignMajorVulnAt) > self.constants.foreignMajorVulnWindowMs then
        return false
    end

    return self.state.foreignMajorVulnTargetUnitId == 0 or targetUnitId == 0 or self.state.foreignMajorVulnTargetUnitId == targetUnitId
end

function SDT:MarkOwnMajorVuln(targetUnitId)
    self.state.ownMajorVulnAt = NowMs()
    self.state.ownMajorVulnTargetUnitId = SafeNumber(targetUnitId)
end

function SDT:HasRecentOwnMajorVuln(targetUnitId)
    local nowMs = NowMs()
    if (nowMs - self.state.ownMajorVulnAt) > self.constants.ownMajorVulnWindowMs then
        return false
    end

    return self.state.ownMajorVulnTargetUnitId == 0 or targetUnitId == 0 or self.state.ownMajorVulnTargetUnitId == targetUnitId
end

function SDT:ClearVisibleTargetProc()
    self.state.visibleTargetProcEndsAt = 0
    self.state.visibleTargetProcIsOwn = false
    self.state.visibleTargetUnitId = 0
    self.state.visibleTargetName = nil
end

function SDT:HasVisibleTargetProc(nowMs)
    nowMs = nowMs or NowMs()
    return nowMs < SafeNumber(self.state.visibleTargetProcEndsAt)
end

function SDT:GetVisibleTargetProcInfoForUnit(unitTag, nowMs)
    if GetNumBuffs == nil or GetUnitBuffInfo == nil then
        return nil
    end

    local buffCount = GetNumBuffs(unitTag)
    if buffCount == nil or buffCount <= 0 then
        return nil
    end

    local bestProcEndMs = 0
    local bestIsOwn = false

    for buffIndex = 1, buffCount do
        local _, _, timeEnding, _, _, _, _, _, _, _, abilityId, _, castByPlayer = GetUnitBuffInfo(unitTag, buffIndex)
        if self:IsMajorVulnerabilityAbilityId(abilityId) then
            local procEndMs = zo_floor(SafeNumber(timeEnding) * 1000)
            if procEndMs > nowMs and procEndMs > bestProcEndMs then
                bestProcEndMs = procEndMs
                bestIsOwn = castByPlayer and true or false
            end
        end
    end

    if bestProcEndMs <= nowMs then
        return nil
    end

    local unitId = 0
    if GetUnitId ~= nil then
        unitId = SafeNumber(GetUnitId(unitTag))
    end

    return bestProcEndMs, bestIsOwn, GetUnitName(unitTag), unitId
end

function SDT:SyncVisibleTargetMajorVulnerability(nowMs)
    nowMs = nowMs or NowMs()

    local bestProcEndMs = 0
    local bestIsOwn = false
    local bestTargetName = nil
    local bestTargetUnitId = 0

    for _, unitTag in ipairs(self.visibleProcUnitTags) do
        local procEndMs, isOwn, targetName, targetUnitId = self:GetVisibleTargetProcInfoForUnit(unitTag, nowMs)
        if procEndMs ~= nil and procEndMs > bestProcEndMs then
            bestProcEndMs = procEndMs
            bestIsOwn = isOwn and true or false
            bestTargetName = targetName
            bestTargetUnitId = SafeNumber(targetUnitId)
        end
    end

    if bestProcEndMs > nowMs then
        self.state.visibleTargetProcEndsAt = bestProcEndMs
        self.state.visibleTargetProcIsOwn = bestIsOwn
        self.state.visibleTargetUnitId = bestTargetUnitId
        self.state.visibleTargetName = bestTargetName
        return
    end

    if not self:HasVisibleTargetProc(nowMs) then
        self:ClearVisibleTargetProc()
    end
end

function SDT:GetProcTypeFromEndTime(procEndMs, nowMs)
    local remainingMs = math.max(0, procEndMs - nowMs)
    local tolerance = self.constants.procDurationToleranceMs
    local bestSetKey = nil
    local bestDiff = nil

    for _, setKey in ipairs(self.cooldownDisplayOrder) do
        if self:IsSetEquipped(setKey) then
            local setDefinition = self:GetSetDefinition(setKey)
            local diff = math.abs(remainingMs - setDefinition.procDurationMs)
            if diff <= tolerance and (bestDiff == nil or diff < bestDiff) then
                bestSetKey = setKey
                bestDiff = diff
            end
        end
    end

    return bestSetKey
end

function SDT:GetTrackedSetKeyForProcAbility(abilityId)
    return self.procAbilityToSetKey[abilityId]
end

function SDT:HasExternalProc(nowMs)
    return nowMs < self.state.externalProcEndsAt
end

function SDT:CanShowExternalProc(nowMs)
    return not self:IsProcActive(nowMs)
end

function SDT:StartExternalProc(targetUnitId, targetName, procEndMs, isPlayerSource)
    local nowMs = NowMs()
    local resolvedProcEndMs = procEndMs and math.max(procEndMs, nowMs) or (nowMs + self.constants.stonehulkProcDurationMs)
    self.state.externalProcEndsAt = math.max(self.state.externalProcEndsAt, resolvedProcEndMs)
    self.state.externalProcTargetUnitId = SafeNumber(targetUnitId)
    self.state.externalProcIsPlayer = isPlayerSource and true or false
    self.state.targetName = targetName or self.state.targetName
end

function SDT:RefreshDisplayedOwnProcState(nowMs)
    nowMs = nowMs or NowMs()

    local strongestSourceKey = nil
    local strongestProcState = nil

    for sourceKey, procState in pairs(self.state.ownProcStates or {}) do
        local procEndMs = SafeNumber(procState.endMs)
        if procEndMs > nowMs then
            if strongestProcState == nil or procEndMs > SafeNumber(strongestProcState.endMs) then
                strongestSourceKey = sourceKey
                strongestProcState = procState
            end
        else
            self.state.ownProcStates[sourceKey] = nil
        end
    end

    if strongestProcState ~= nil then
        self.state.procEndsAt = SafeNumber(strongestProcState.endMs)
        self.state.targetName = strongestProcState.targetName or self.state.targetName
        self.state.lastConfirmedTargetUnitId = SafeNumber(strongestProcState.targetUnitId)
        self.state.lastConfirmedProcType = strongestProcState.procType or strongestSourceKey
        return true
    end

    self.state.procEndsAt = 0
    self.state.lastConfirmedProcType = nil
    self.state.lastConfirmedTargetUnitId = 0
    return false
end

function SDT:StoreOwnProcState(sourceKey, targetUnitId, targetName, procEndMs, fallbackTargetName, isAuthoritative)
    local nowMs = NowMs()
    local resolvedSourceKey = sourceKey or "generic"
    local resolvedEndMs = procEndMs and math.max(procEndMs, nowMs) or nowMs
    local procState = self.state.ownProcStates[resolvedSourceKey] or {}

    procState.endMs = math.max(resolvedEndMs, SafeNumber(procState.endMs))
    if SafeNumber(targetUnitId) ~= 0 then
        procState.targetUnitId = SafeNumber(targetUnitId)
    end
    procState.targetName = targetName or fallbackTargetName or procState.targetName or self.state.targetName
    procState.procType = resolvedSourceKey
    procState.authoritative = isAuthoritative and true or (procState.authoritative and true or false)

    self.state.ownProcStates[resolvedSourceKey] = procState
    self.state.procStartedAt = nowMs
    self.state.lastConfirmedAt = nowMs
    self.state.externalProcEndsAt = 0
    self.state.externalProcTargetUnitId = 0
    self.state.externalProcIsPlayer = false
    self:RefreshDisplayedOwnProcState(nowMs)
end

function SDT:HasAuthoritativeDisplayedOwnProc(targetUnitId, targetName, nowMs)
    nowMs = nowMs or NowMs()
    self:RefreshDisplayedOwnProcState(nowMs)

    local displayedProcType = self.state.lastConfirmedProcType
    if displayedProcType == nil then
        return false
    end

    local procState = self.state.ownProcStates[displayedProcType]
    if procState == nil or not procState.authoritative or SafeNumber(procState.endMs) <= nowMs then
        return false
    end

    return self:IsDisplayedTargetMatchOrAmbiguous(targetUnitId, targetName)
end

function SDT:IsDisplayedTargetMatchOrAmbiguous(targetUnitId, targetName)
    if TargetsMatch(self.state.lastConfirmedTargetUnitId, targetUnitId, self.state.targetName, targetName) then
        return true
    end

    local savedUnitId = SafeNumber(self.state.lastConfirmedTargetUnitId)
    local currentUnitId = SafeNumber(targetUnitId)
    if savedUnitId ~= 0 and currentUnitId ~= 0 then
        return false
    end

    if NamesLookRelated(self.state.targetName, targetName) then
        return true
    end

    return NormalizeString(self.state.targetName) == "" or NormalizeString(targetName) == ""
end

function SDT:ResolveDisplayedProcEndMs(targetUnitId, targetName, procEndMs)
    local nowMs = NowMs()
    local resolvedProcEndMs = procEndMs and math.max(procEndMs, nowMs) or nowMs

    if not self:IsProcActive(nowMs) then
        return resolvedProcEndMs
    end

    if not self:IsDisplayedTargetMatchOrAmbiguous(targetUnitId, targetName) then
        return resolvedProcEndMs
    end

    return math.max(self.state.procEndsAt, resolvedProcEndMs)
end

function SDT:StartGenericMajorVulnerabilityProc(targetUnitId, targetName, procEndMs, fallbackTargetName)
    self:StoreOwnProcState("generic", targetUnitId, targetName, procEndMs, fallbackTargetName)
end

function SDT:ApplyConfirmedSetProc(setKey, targetUnitId, targetName, procEndMs, fallbackTargetName)
    local nowMs = NowMs()
    local setDefinition = self:GetSetDefinition(setKey)
    if not setDefinition then
        return false
    end

    if not self:IsSetEquipped(setKey) then
        if not self:CanAutoActivateSet(setKey) then
            return false
        end
        self:ActivateTrackedSet(setKey)
    end

    if not self:IsSetReady(setKey, nowMs) then
        return false
    end

    if self.state.lastConfirmedProcType == setKey
        and TargetsMatch(self.state.lastConfirmedTargetUnitId, targetUnitId, self.state.targetName, targetName)
        and (nowMs - self.state.lastConfirmedAt) < 200 then
        return false
    end

    self:SetSetCooldownEnd(setKey, nowMs + setDefinition.cooldownMs)
    self:StoreOwnProcState(setKey, targetUnitId, targetName, procEndMs or (nowMs + setDefinition.procDurationMs), fallbackTargetName, true)
    return true
end

function SDT:ConfirmSetProc(setKey, targetUnitId, targetName, procEndMs, fallbackTargetName)
    return self:ApplyConfirmedSetProc(setKey, targetUnitId, targetName, procEndMs, fallbackTargetName)
end

function SDT:ConfirmStonehulkProc(targetUnitId, targetName, procEndMs)
    local recentEnough = self:HasRecentMatchingTaunt(targetUnitId, targetName)

    if not recentEnough then
        return
    end

    self:ApplyConfirmedSetProc("stonehulk", targetUnitId, targetName, procEndMs, self.state.lastTauntTargetName)
end

function SDT:ConfirmArchdruidProc(targetUnitId, targetName, procEndMs)
    local nowMs = NowMs()
    local recentEnough = self:HasRecentOwnMajorVuln(targetUnitId)
        or self:HasRecentMatchingHeavyAttack(targetUnitId, targetName)
        or self:HasPendingArchdruidProc(nowMs, targetUnitId, targetName)

    if not recentEnough then
        return
    end

    if self:ApplyConfirmedSetProc("archdruid", targetUnitId, targetName, procEndMs, self.state.archdruidPendingTargetName or self.state.lastHeavyAttackTargetName) then
        self:ConsumePendingArchdruidProc()
    end
end

function SDT:SyncActiveProc(targetUnitId, targetName, procEndMs)
    local nowMs = NowMs()
    local sameConfirmedTarget = self:IsDisplayedTargetMatchOrAmbiguous(targetUnitId, targetName)
    local sameTauntTarget = TargetsMatch(self.state.lastTauntTargetUnitId, targetUnitId, self.state.lastTauntTargetName, targetName)
    local canSync = self:IsProcActive(nowMs) or self:HasAnyCooldownActive(nowMs)

    if not canSync or (not sameConfirmedTarget and not sameTauntTarget) then
        return false
    end

    local displayedProcType = self.state.lastConfirmedProcType or "generic"
    local displayedProcState = self.state.ownProcStates[displayedProcType]
    self:StoreOwnProcState(displayedProcType, targetUnitId, targetName, procEndMs, self.state.lastTauntTargetName, displayedProcState and displayedProcState.authoritative)
    return true
end

function SDT:HandleConfiguredProcAbilityEvent(setKey, _, result, isError, _, _, _, _, sourceType, targetName, targetType, _, _, _, _, _, targetUnitId)
    if isError then
        return
    end

    if targetType == COMBAT_UNIT_TYPE_PLAYER or targetType == COMBAT_UNIT_TYPE_GROUP or targetType == COMBAT_UNIT_TYPE_PLAYER_PET then
        return
    end

    if result ~= ACTION_RESULT_DAMAGE
        and result ~= ACTION_RESULT_CRITICAL_DAMAGE
        and result ~= ACTION_RESULT_EFFECT_GAINED
        and result ~= ACTION_RESULT_EFFECT_GAINED_DURATION then
        return
    end

    local nowMs = NowMs()
    local setDefinition = self:GetSetDefinition(setKey)
    if not setDefinition then
        return
    end

    if sourceType ~= COMBAT_UNIT_TYPE_PLAYER then
        if self:CanShowExternalProc(nowMs) then
            self:StartExternalProc(targetUnitId, targetName, nowMs + setDefinition.procDurationMs, sourceType == COMBAT_UNIT_TYPE_GROUP)
        else
            self.state.externalProcEndsAt = math.max(self.state.externalProcEndsAt, nowMs + setDefinition.procDurationMs)
        end
        return
    end

    self:MarkOwnMajorVuln(targetUnitId)

    if setKey == "archdruid" then
        self:ConfirmArchdruidProc(targetUnitId, targetName, nowMs + setDefinition.procDurationMs)
    else
        self:ConfirmSetProc(setKey, targetUnitId, targetName, nowMs + setDefinition.procDurationMs, targetName)
    end
end

function SDT:HandleCombatEvent(_, result, isError, _, _, actionSlotType, _, sourceType, targetName, targetType, _, _, _, _, _, targetUnitId, abilityId)
    if isError or sourceType ~= COMBAT_UNIT_TYPE_PLAYER then
        return
    end

    if not self:HasTrackedSetEquipped() then
        return
    end

    if targetType == COMBAT_UNIT_TYPE_PLAYER or targetType == COMBAT_UNIT_TYPE_GROUP or targetType == COMBAT_UNIT_TYPE_PLAYER_PET then
        return
    end

    if actionSlotType == ACTION_SLOT_TYPE_HEAVY_ATTACK and (result == ACTION_RESULT_DAMAGE or result == ACTION_RESULT_CRITICAL_DAMAGE) then
        self:RememberHeavyAttack(targetUnitId, targetName)
    end

    if not self:IsTauntAbility(abilityId) then
        return
    end

    if result == ACTION_RESULT_BEGIN
        or result == ACTION_RESULT_EFFECT_GAINED
        or result == ACTION_RESULT_EFFECT_GAINED_DURATION
        or result == ACTION_RESULT_DAMAGE
        or result == ACTION_RESULT_CRITICAL_DAMAGE then
        self:RememberTaunt(targetUnitId, targetName)
    end

end

function SDT:HandleProcCombatEvent(_, result, isError, _, _, _, _, sourceType, targetName, targetType, _, _, _, _, _, targetUnitId, abilityId)
    if isError or not self:IsMajorVulnerabilityAbilityId(abilityId) then
        return
    end

    if targetType == COMBAT_UNIT_TYPE_PLAYER or targetType == COMBAT_UNIT_TYPE_GROUP or targetType == COMBAT_UNIT_TYPE_PLAYER_PET then
        return
    end

    local nowMs = NowMs()
    local recentMatchingTaunt = self:HasRecentMatchingTaunt(targetUnitId, targetName)
    local recentHeavyAttack = self:HasRecentMatchingHeavyAttack(targetUnitId, targetName)
    local pendingArchdruid = self:HasPendingArchdruidProc(nowMs, targetUnitId, targetName)
    local ownProcSource = sourceType == COMBAT_UNIT_TYPE_PLAYER

      if result == ACTION_RESULT_EFFECT_GAINED or result == ACTION_RESULT_EFFECT_GAINED_DURATION then
          if ownProcSource then
              self:MarkOwnMajorVuln(targetUnitId)

              if recentMatchingTaunt and self:IsSetEquipped("stonehulk") and not self:IsGenericMajorVulnerabilityAbilityId(abilityId) then
                local fallbackStonehulkEndMs = nowMs + self.constants.stonehulkProcDurationMs
                if self:IsStonehulkReady(nowMs) then
                    self:ConfirmStonehulkProc(targetUnitId, targetName, fallbackStonehulkEndMs)
                else
                    self:SyncActiveProc(targetUnitId, targetName, math.max(self.state.procEndsAt, fallbackStonehulkEndMs))
                  end
                  return
              end

                return
            else
                self:MarkForeignMajorVuln(targetUnitId, sourceType == COMBAT_UNIT_TYPE_GROUP)
              if self:CanShowExternalProc(nowMs) then
                  self:StartExternalProc(targetUnitId, targetName, nowMs + self.constants.stonehulkProcDurationMs, sourceType == COMBAT_UNIT_TYPE_GROUP)
            else
                self.state.externalProcEndsAt = math.max(self.state.externalProcEndsAt, nowMs + self.constants.stonehulkProcDurationMs)
            end
            return
        end
    elseif result == ACTION_RESULT_EFFECT_FADED then
        if self.state.lastConfirmedTargetUnitId == 0 or targetUnitId == 0 or self.state.lastConfirmedTargetUnitId == targetUnitId then
            self.state.procEndsAt = 0
        end
    end
end

function SDT:HandleProcEffectChanged(_, changeType, _, _, unitTag, _, endTimeSec, _, _, _, _, _, _, unitName, unitId, abilityId)
    if not self:IsMajorVulnerabilityAbilityId(abilityId) then
        return
    end

    if unitTag ~= "target" and unitTag ~= "reticleover" and not zo_plainstrfind(unitTag or "", "boss") then
        return
    end

    if changeType == EFFECT_RESULT_GAINED or changeType == EFFECT_RESULT_UPDATED then
        local nowMs = NowMs()
        local procEndMs = zo_floor(endTimeSec * 1000)
        local recentMatchingTaunt = self:HasRecentMatchingTaunt(unitId, unitName)
        local recentForeignMajorVuln = self:HasRecentForeignMajorVuln(unitId)
        local recentOwnMajorVuln = self:HasRecentOwnMajorVuln(unitId)
        local recentHeavyAttack = self:HasRecentMatchingHeavyAttack(unitId, unitName)
        local pendingArchdruid = self:HasPendingArchdruidProc(nowMs, unitId, unitName)
        local genericMajorVuln = self:IsGenericMajorVulnerabilityAbilityId(abilityId)

        if genericMajorVuln then
            if recentOwnMajorVuln then
                self:StartGenericMajorVulnerabilityProc(unitId, unitName, procEndMs, unitName)
            elseif recentForeignMajorVuln then
                if self:CanShowExternalProc(nowMs) then
                    self:StartExternalProc(unitId, unitName, procEndMs, self.state.foreignMajorVulnIsPlayer)
                else
                    self.state.externalProcEndsAt = procEndMs
                end
            elseif self:HasExternalProc(nowMs) and (self.state.externalProcTargetUnitId == 0 or unitId == 0 or self.state.externalProcTargetUnitId == unitId) then
                self.state.externalProcEndsAt = procEndMs
            else
                self:StartExternalProc(unitId, unitName, procEndMs, false)
            end
            return
        end

        local procType = self:GetProcTypeFromEndTime(procEndMs, nowMs)

        if procType == "stonehulk" and recentMatchingTaunt then
            if self:IsStonehulkReady(nowMs) then
                self:ConfirmStonehulkProc(unitId, unitName, procEndMs)
            else
                self:SyncActiveProc(unitId, unitName, procEndMs)
            end
        elseif procType == "archdruid" and (pendingArchdruid or recentOwnMajorVuln or recentHeavyAttack) then
            if self:IsArchdruidReady(nowMs) then
                self:ConfirmArchdruidProc(unitId, unitName, procEndMs)
            else
                self:SyncActiveProc(unitId, unitName, procEndMs)
            end
        elseif procType ~= nil
            and procType ~= "stonehulk"
            and procType ~= "archdruid"
            and self:IsSetEquipped(procType)
            and recentOwnMajorVuln then
            if self:IsSetReady(procType, nowMs) then
                self:ConfirmSetProc(procType, unitId, unitName, procEndMs, unitName)
            else
                self:SyncActiveProc(unitId, unitName, procEndMs)
            end
        elseif recentOwnMajorVuln then
            self:StartGenericMajorVulnerabilityProc(unitId, unitName, procEndMs, unitName)
        elseif recentForeignMajorVuln and not recentMatchingTaunt and not recentOwnMajorVuln and not pendingArchdruid and not recentHeavyAttack then
            if self:CanShowExternalProc(nowMs) then
                self:StartExternalProc(unitId, unitName, procEndMs, self.state.foreignMajorVulnIsPlayer)
            end
            return
        elseif self:HasExternalProc(nowMs) and (self.state.externalProcTargetUnitId == 0 or unitId == 0 or self.state.externalProcTargetUnitId == unitId) then
            self.state.externalProcEndsAt = procEndMs
        else
            self:SyncActiveProc(unitId, unitName, procEndMs)
        end
    elseif changeType == EFFECT_RESULT_FADED then
        if TargetsMatch(self.state.visibleTargetUnitId, unitId, self.state.visibleTargetName, unitName) then
            self:ClearVisibleTargetProc()
        end
        if self.state.lastConfirmedTargetUnitId == 0 or unitId == 0 or self.state.lastConfirmedTargetUnitId == unitId then
            self.state.procEndsAt = 0
        end
        if self.state.externalProcTargetUnitId == 0 or unitId == 0 or self.state.externalProcTargetUnitId == unitId then
            self.state.externalProcEndsAt = 0
            self.state.externalProcTargetUnitId = 0
            self.state.externalProcIsPlayer = false
        end
    end
end

function SDT:GetCooldownEntries(nowMs)
    local entries = {}

    for _, setKey in ipairs(self.cooldownDisplayOrder) do
        if self:IsSetEquipped(setKey) then
            local cooldownEndMs = self:GetSetCooldownEnd(setKey)
            if nowMs < cooldownEndMs then
                local secondsLeft = math.max(0, math.floor((cooldownEndMs - nowMs) / 1000))
                table.insert(entries, {
                    setKey = setKey,
                    text = tostring(secondsLeft),
                })
            end
        end
    end

    return entries
end

function SDT:GetCooldownSlotValues(nowMs)
    local entries = self:GetCooldownEntries(nowMs)
    local slotValues = {
        { setKey = nil, text = "" },
        { setKey = nil, text = "" },
        { setKey = nil, text = "" },
        { setKey = nil, text = "" },
    }

    for index = 1, math.min(#entries, #slotValues) do
        slotValues[index] = entries[index]
    end

    return slotValues, #entries > 0
end

function SDT:UpdateUI()
    if not self.window then
        return
    end

    self:RefreshFonts()

    local nowMs = NowMs()
    self:SyncVisibleTargetMajorVulnerability(nowMs)

    local visibleTargetProcActive = self:HasVisibleTargetProc(nowMs)
    local trackingEnabled = self:IsTrackingEnabled(nowMs)
    local procActive = not visibleTargetProcActive and self:IsProcActive(nowMs)
    local externalProcActive = not visibleTargetProcActive and self:HasExternalProc(nowMs) and self:CanShowExternalProc(nowMs)
    local ownRed, ownGreen, ownBlue = self:GetOwnProcColor()
    local otherRed, otherGreen, otherBlue = self:GetOtherProcColor()
    local timerText = ""
    local cooldownSlotValues, hasCooldownText = self:GetCooldownSlotValues(nowMs)
    local targetNameText = ""

    if not trackingEnabled then
        self.iconTexture:SetColor(0.45, 0.45, 0.45, 0.90)
        self.timerLabel:SetColor(0.80, 0.80, 0.80, 1)
        for _, shadow in ipairs(self.timerShadows) do
            shadow:SetText("")
        end
        self.timerLabel:SetText("")
        for _, slotData in ipairs(self.cooldownSlots or {}) do
            for _, shadow in ipairs(slotData.shadows or {}) do
                shadow:SetText("")
            end
            if slotData.label then
                slotData.label:SetText("")
            end
        end
        self.targetNameShadow:SetText("")
        self.targetNameLabel:SetText("")
        return
    end

    self.iconTexture:SetColor(1, 1, 1, 1)

    if visibleTargetProcActive then
        if self.state.visibleTargetProcIsOwn then
            self.timerLabel:SetColor(ownRed, ownGreen, ownBlue, 1)
        else
            self.timerLabel:SetColor(otherRed, otherGreen, otherBlue, 1)
        end
        for _, shadow in ipairs(self.timerShadows) do
            shadow:SetColor(0.02, 0.02, 0.02, 1)
        end
        timerText = tostring(math.max(0, math.floor((self.state.visibleTargetProcEndsAt - nowMs) / 1000)))
    elseif procActive then
        self.timerLabel:SetColor(ownRed, ownGreen, ownBlue, 1)
        for _, shadow in ipairs(self.timerShadows) do
            shadow:SetColor(0.02, 0.02, 0.02, 1)
        end
        timerText = tostring(math.max(0, math.floor((self.state.procEndsAt - nowMs) / 1000)))
    elseif externalProcActive then
        if self.state.externalProcIsPlayer then
            self.timerLabel:SetColor(ownRed, ownGreen, ownBlue, 1)
        else
            self.timerLabel:SetColor(otherRed, otherGreen, otherBlue, 1)
        end
        for _, shadow in ipairs(self.timerShadows) do
            shadow:SetColor(0.02, 0.02, 0.02, 1)
        end
        timerText = tostring(math.max(0, math.floor((self.state.externalProcEndsAt - nowMs) / 1000)))
    else
        self.timerLabel:SetColor(ownRed, ownGreen, ownBlue, 1)
        for _, shadow in ipairs(self.timerShadows) do
            shadow:SetColor(0.02, 0.02, 0.02, 1)
        end
    end

    if self.sv.showTargetName and (visibleTargetProcActive or procActive or externalProcActive or hasCooldownText) then
        if visibleTargetProcActive then
            targetNameText = FormatDisplayName(self.state.visibleTargetName)
        else
            targetNameText = FormatDisplayName(self.state.targetName)
        end
    end

    for _, shadow in ipairs(self.timerShadows) do
        shadow:SetText(timerText)
    end
    self.timerLabel:SetText(timerText)
    for slotIndex, slotData in ipairs(self.cooldownSlots or {}) do
        local slotValue = cooldownSlotValues[slotIndex] or { setKey = nil, text = "" }
        local slotText = slotValue.text or ""
        local red, green, blue = self:GetCooldownSetColor(slotValue.setKey)
        for _, shadow in ipairs(slotData.shadows or {}) do
            shadow:SetText(slotText)
            shadow:SetColor(0.02, 0.02, 0.02, 1)
        end
        if slotData.label then
            slotData.label:SetText(slotText)
            slotData.label:SetColor(red, green, blue, 1)
        end
    end
    self.targetNameShadow:SetText(targetNameText)
    self.targetNameLabel:SetText(targetNameText)
end

function SDT:RegisterProcEffectEvent(namespace, unitTag, usePrefix, abilityId)
    local eventName = string.format("%s%s%d", self.name, namespace, abilityId)
    EVENT_MANAGER:RegisterForEvent(eventName, EVENT_EFFECT_CHANGED, function(...)
        self:HandleProcEffectChanged(...)
    end)
    EVENT_MANAGER:AddFilterForEvent(eventName, EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, abilityId)

    if usePrefix then
        EVENT_MANAGER:AddFilterForEvent(eventName, EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, unitTag)
    else
        EVENT_MANAGER:AddFilterForEvent(eventName, EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG, unitTag)
    end
end

function SDT:RegisterEvents()
    EVENT_MANAGER:RegisterForUpdate(self.name .. "Update", 100, function()
        self:UpdateUI()
    end)

    EVENT_MANAGER:RegisterForEvent(self.name .. "TauntCombatEvent", EVENT_COMBAT_EVENT, function(...)
        self:HandleCombatEvent(...)
    end)
    EVENT_MANAGER:AddFilterForEvent(self.name .. "TauntCombatEvent", EVENT_COMBAT_EVENT, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)

    for abilityId in pairs(self.constants.majorVulnerabilityAbilityIds) do
        local trackedAbilityId = abilityId
        local eventName = string.format("%sProcCombatEvent%d", self.name, trackedAbilityId)
        EVENT_MANAGER:RegisterForEvent(eventName, EVENT_COMBAT_EVENT, function(...)
            self:HandleProcCombatEvent(...)
        end)
        EVENT_MANAGER:AddFilterForEvent(eventName, EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, trackedAbilityId)
    end

    for abilityId, setKey in pairs(self.procAbilityToSetKey) do
        local trackedAbilityId = abilityId
        local trackedSetKey = setKey
        local eventName = string.format("%sSetProc%d", self.name, trackedAbilityId)
        EVENT_MANAGER:RegisterForEvent(eventName, EVENT_COMBAT_EVENT, function(...)
            self:HandleConfiguredProcAbilityEvent(trackedSetKey, ...)
        end)
        EVENT_MANAGER:AddFilterForEvent(eventName, EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, trackedAbilityId)
    end

    for abilityId in pairs(self.constants.majorVulnerabilityAbilityIds) do
        self:RegisterProcEffectEvent("BossProc", "boss", true, abilityId)
        self:RegisterProcEffectEvent("TargetProc", "target", false, abilityId)
        self:RegisterProcEffectEvent("ReticleProc", "reticleover", false, abilityId)
    end

    EVENT_MANAGER:RegisterForEvent(self.name .. "Activated", EVENT_PLAYER_ACTIVATED, function()
        self:RefreshTrackedSets()
        self:RefreshSlottedTaunts()
        if not IsUnitInCombat("player") then
            self:ResetTimers()
        end
        self:UpdateUI()
    end)

    EVENT_MANAGER:RegisterForEvent(self.name .. "CombatState", EVENT_PLAYER_COMBAT_STATE, function(...)
        self:HandleCombatState(...)
    end)

    EVENT_MANAGER:RegisterForEvent(self.name .. "WornUpdate", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, function()
        self:RefreshTrackedSets()
        self:UpdateUI()
    end)
    EVENT_MANAGER:AddFilterForEvent(self.name .. "WornUpdate", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, BAG_WORN)

    EVENT_MANAGER:RegisterForEvent(self.name .. "HotbarsUpdated", EVENT_ACTION_SLOTS_ALL_HOTBARS_UPDATED, function()
        self:RefreshSlottedTaunts()
    end)
    EVENT_MANAGER:RegisterForEvent(self.name .. "SlotUpdated", EVENT_ACTION_SLOT_UPDATED, function()
        self:RefreshSlottedTaunts()
    end)
    EVENT_MANAGER:RegisterForEvent(self.name .. "BarSwap", EVENT_ACTION_SLOTS_ACTIVE_HOTBAR_UPDATED, function()
        self:RefreshSlottedTaunts()
    end)
end

function SDT:Initialize()
    self.sv = ZO_SavedVars:NewAccountWide("StonehulkDominationTrackerSavedVariables", self.savedVarVersion, nil, self.defaults)
    self.sv.moveMode = false
    self:CreateUI()
    self:RegisterSettings()
    self:RefreshTrackedSets()
    self:RefreshSlottedTaunts()
    self:RegisterEvents()
    self:UpdateUI()
end

local function OnAddonLoaded(_, addonName)
    if addonName ~= SDT.name then
        return
    end

    EVENT_MANAGER:UnregisterForEvent(SDT.name, EVENT_ADD_ON_LOADED)
    SDT:Initialize()
end

EVENT_MANAGER:RegisterForEvent(SDT.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)
