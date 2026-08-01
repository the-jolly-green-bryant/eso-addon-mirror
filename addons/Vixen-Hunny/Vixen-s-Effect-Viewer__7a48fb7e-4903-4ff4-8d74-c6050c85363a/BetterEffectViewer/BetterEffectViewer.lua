BetterEffectViewer = {
    name = "BetterEffectViewer",
    version = "1.2",

    maxCols = 10,
    maxRows = 3,
    minRows = 1,

    iconSize = 32,
    effects = {},
    UI = {},
}

BetterEffectViewer.Auth = {
    "@Mastcrs",
    "@Vixen Hunny",
    "@Bexztar",
    "@blu3topaz",
    "@Kix Flipz",
    "@Xvwly",
    "@ViperMarquis",
}

local BEV = BetterEffectViewer

BEV.lastReticleUnitTag = nil
BEV.reticleLostTime = 0
BEV.reticleHoldDuration = 1.0
BEV.targetSwitchDelay = 0.25
BEV.pendingTarget = nil
BEV.pendingTime = 0

BEV.PERMANENT_DURATION_THRESHOLD = 600

BEV.defaults = {
    autoWhitelist = true,
    autoWhitelistDuration = 5,
    filterMode = "none",
    maxWhitelistSize = 500,

    whitelist = {
        [61747] = true,
        [61745] = true,
    },

    blacklist = {
        [64228] = true,
    },

    offsetX = 0,
    offsetY = -250,
    showBuffs = true,
    showDebuffs = true,
    iconSize = 32,
    lockWindow = false,
    playerEffectBorderColor = { 0.2, 0.8, 1.0, 1.0 },
    showPermanents = true,
    targetSwitchDelay = 0.25,
    reticleHoldDuration = 1.0,

    pveLayout = {
        iconSize = 32,
        fontSize = 18,
        maxCols = 10,
    },

    pvpLayout = {
        iconSize = 36,
        fontSize = 20,
        maxCols = 8,
    },

    fontSize = 18,
    flashThreshold = 5,

    buffBorderColor = { 0.2, 0.8, 0.2, 1.0 },
    debuffBorderColor = { 0.9, 0.2, 0.2, 1.0 },
    permanentBorderColor = { 0.2, 0.6, 1.0, 1.0 },

    buffTimerColor = { 1.0, 1.0, 1.0, 1.0 },
    debuffTimerColor = { 1.0, 0.6, 0.3, 1.0 },
    permanentTimerColor = { 0.8, 0.8, 1.0, 1.0 },

    flashColor = { 1.0, 1.0, 1.0, 1.0 },
    sortMode = "shortest",
    performanceMode = "low",
    fallbackRescanInterval = 1.5,
    autoConsoleTuning = true,
    consoleSlotRowsCap = 5,
    consoleEffectCap = 96,
    consoleMaxColsCap = 8,
}

BEV.PERFORMANCE_PROFILES = {
    balanced = {
        maintenance = 0.25,
        visualFast = 0.1,
        visualNormal = 0.25,
        visualIdle = 0.5,
    },
    low = {
        maintenance = 0.4,
        visualFast = 0.15,
        visualNormal = 0.35,
        visualIdle = 0.75,
    },
    ultra = {
        maintenance = 0.6,
        visualFast = 0.25,
        visualNormal = 0.5,
        visualIdle = 1.0,
    },
}

function BEV:UnpackColor(t)
    return t[1], t[2], t[3], t[4]
end

function BEV:ResolveReticleUnitTag()
    if DoesUnitExist("reticleover") then
        return "reticleover"
    end
    if DoesUnitExist("reticleoverplayer") then
        return "reticleoverplayer"
    end
    return nil
end

function BEV:MakeEffectKey(abilityId, iconName, effectType)
    return string.format("%d|%s|%d", abilityId or 0, iconName or "", effectType or 0)
end

function BEV:IsPermanentEffect(startTime, endTime)
    if not endTime or endTime == 0 then
        return true
    end
    if startTime and endTime and (endTime - startTime) >= self.PERMANENT_DURATION_THRESHOLD then
        return true
    end
    return false
end

function BEV:BuildEffect(effectName, abilityId, iconName, effectType, buffType, startTime, endTime, stackCount, statusEffectType, sourceType)
    return {
        key = self:MakeEffectKey(abilityId, iconName, effectType),
        name = effectName,
        abilityId = abilityId,
        iconName = iconName,
        effectType = effectType,
        buffType = buffType,
        startTime = startTime,
        endTime = endTime,
        stackCount = stackCount,
        statusEffectType = statusEffectType,
        sourceType = sourceType,
        isPermanent = self:IsPermanentEffect(startTime, endTime),
        lastSeen = GetFrameTimeSeconds(),
    }
end

function BEV:TimeRemaining(effect, now)
    if not effect.endTime or effect.endTime == 0 then
        return math.huge
    end
    local t = now or GetFrameTimeSeconds()
    return effect.endTime - t
end

function BEV:FormatTime(remaining, isPermanent)
    if isPermanent then
        return ""
    end

    if remaining == math.huge or remaining <= 0 then
        return ""
    elseif remaining < 10 then
        return string.format("%.1f", remaining)
    elseif remaining < 60 then
        return string.format("%d", remaining)
    end

    local m = math.floor(remaining / 60)
    local s = math.floor(remaining % 60)
    return string.format("%d:%02d", m, s)
end

function BEV:GetPerformanceProfile()
    local mode = self.runtimePerformanceMode or self.sv.performanceMode or self.defaults.performanceMode
    return self.PERFORMANCE_PROFILES[mode] or self.PERFORMANCE_PROFILES.low
end

function BEV:GetSlotPoolSize()
    local rows = self.runtimeSlotRows or 10
    return (self.maxCols or self.defaults.pveLayout.maxCols) * rows
end
