local Addon = TheSynapticRegistry
local Diagnostics = {}

local RECENT_COMBAT_LIMIT = 6
local RECENT_EFFECT_LIMIT = 8
local RAW_LINE_LIMIT = 132

Diagnostics.root = nil
Diagnostics.label = nil
Diagnostics.backdrop = nil

local function hasMethod(owner, methodName)
    return owner ~= nil and type(owner[methodName]) == "function"
end

local function getNowMs()
    if type(GetFrameTimeMilliseconds) == "function" then
        return GetFrameTimeMilliseconds()
    end

    return 0
end

local function getGroupedText()
    if type(IsUnitGrouped) ~= "function" then
        return "unknown"
    end

    if IsUnitGrouped("player") == true then
        return "yes"
    end

    return "no"
end

local function getPlayerName()
    if type(GetUnitName) ~= "function" then
        return nil
    end

    local name = GetUnitName("player")

    if type(name) == "string" and name ~= "" then
        return name
    end

    return nil
end

local function stripColorCodes(value)
    if type(value) ~= "string" or value == "" then
        return ""
    end

    local stripped = string.gsub(value, "|[cC]%x%x%x%x%x%x", "")

    return string.gsub(stripped, "|[rR]", "")
end

local function displayName(value)
    local stripped = stripColorCodes(value)

    if stripped ~= "" then
        return stripped
    end

    return "unknown"
end

local function normalizeName(value)
    if type(value) ~= "string" or value == "" then
        return ""
    end

    local normalized = stripColorCodes(value)

    normalized = string.gsub(normalized, "%^.*$", "")
    normalized = string.gsub(normalized, "^%s+", "")
    normalized = string.gsub(normalized, "%s+$", "")

    return string.lower(normalized)
end

local function secondsSince(timestampMs)
    if type(timestampMs) ~= "number" then
        return "never"
    end

    return string.format("%.1fs", math.max(0, getNowMs() - timestampMs) / 1000)
end

local function newCounters()
    return {
        synergyEvents = 0,
        offers = 0,
        activation48052 = 0,
        activation55677 = 0,
        marker108799 = 0,
        marker108802 = 0,
        marker108821 = 0,
        marker108924 = 0,
        probeCombat = 0,
        probeEffects = 0,
        broadCombat = 0,
        broadEffects = 0,
        broad26858 = 0,
        broad95957 = 0,
        broad26863 = 0,
        broad48052 = 0,
        broad55677 = 0,
        broad108821 = 0,
        broad108924 = 0,
        lockouts = 0,
        readyCues = 0,
        possibleAllyActivations = 0,
        lastOffer = "none",
        lastActivation = "none",
        lastProbe = "none",
        lastSourceName = "unknown",
        lastTargetName = "unknown",
        lastUnitTag = "unknown",
        lastUnitName = "unknown",
        lastBroad = "none",
        lastBroadCombat = "none",
        lastBroadEffect = "none",
        recentBroadCombat = {},
        recentBroadEffects = {},
        lastSourceNormalized = "",
        playerName = displayName(getPlayerName()),
        playerNormalized = normalizeName(getPlayerName()),
        lastEventMs = nil,
        lastLockoutMs = 0,
    }
end

Diagnostics.counters = newCounters()

local function countBroadAbility(counters, abilityId)
    if abilityId == 26858 then
        counters.broad26858 = counters.broad26858 + 1
    elseif abilityId == 95957 then
        counters.broad95957 = counters.broad95957 + 1
    elseif abilityId == 26863 then
        counters.broad26863 = counters.broad26863 + 1
    elseif abilityId == 48052 then
        counters.broad48052 = counters.broad48052 + 1
    elseif abilityId == 55677 then
        counters.broad55677 = counters.broad55677 + 1
    elseif abilityId == 108821 then
        counters.broad108821 = counters.broad108821 + 1
    elseif abilityId == 108924 then
        counters.broad108924 = counters.broad108924 + 1
    end
end

local function trimLine(value)
    local text = tostring(value or "")

    if string.len(text) > RAW_LINE_LIMIT then
        return string.sub(text, 1, RAW_LINE_LIMIT - 3) .. "..."
    end

    return text
end

local function pushRecent(list, value, limit)
    table.insert(list, 1, trimLine(value))

    while #list > limit do
        table.remove(list)
    end
end

local function getBroadText()
    local settings = Addon.GetSettings()

    if settings.diagnosticBroadEnabled == true then
        return "on"
    end

    return "off"
end

local function isEnabled()
    local settings = Addon.GetSettings()

    return settings.diagnosticsEnabled == true
end

local function configureControl(control, level, alpha)
    if hasMethod(control, "SetDrawTier") and DT_HIGH ~= nil then
        control:SetDrawTier(DT_HIGH)
    end

    if hasMethod(control, "SetDrawLayer") and DL_OVERLAY ~= nil then
        control:SetDrawLayer(DL_OVERLAY)
    end

    if hasMethod(control, "SetDrawLevel") then
        control:SetDrawLevel(level)
    end

    if hasMethod(control, "SetAlpha") then
        control:SetAlpha(alpha)
    end
end

local function setVisible(visible)
    if hasMethod(Diagnostics.root, "SetHidden") then
        Diagnostics.root:SetHidden(visible ~= true)
    end
end

local function formatLines()
    local counters = Diagnostics.counters

    local lines = {
        string.format("Synaptic Registry %s", Addon.Version or "dev"),
        string.format("grouped: %s", getGroupedText()),
        string.format("player: %s", displayName(getPlayerName())),
        string.format("wide: %s", getBroadText()),
        string.format("source: %s", counters.lastSourceName),
        string.format("last offer: %s", counters.lastOffer),
        string.format("offers: %d  raw: %d", counters.offers, counters.synergyEvents),
        string.format("48052: %d  55677: %d", counters.activation48052, counters.activation55677),
        string.format(
            "108799: %d  108802: %d",
            counters.marker108799,
            counters.marker108802
        ),
        string.format(
            "108821: %d  108924: %d",
            counters.marker108821,
            counters.marker108924
        ),
        string.format("probe c/e: %d/%d", counters.probeCombat, counters.probeEffects),
        string.format("wide c/e: %d/%d", counters.broadCombat, counters.broadEffects),
        string.format(
            "wide ls: 26858=%d 95957=%d 26863=%d",
            counters.broad26858,
            counters.broad95957,
            counters.broad26863
        ),
        string.format(
            "wide act: 48052=%d 55677=%d 108821=%d 108924=%d",
            counters.broad48052,
            counters.broad55677,
            counters.broad108821,
            counters.broad108924
        ),
        string.format("lockouts: %d  ready: %d", counters.lockouts, counters.readyCues),
        string.format("ally seen: %d", counters.possibleAllyActivations),
        string.format("target: %s", counters.lastTargetName),
        string.format("unit: %s %s", counters.lastUnitTag, counters.lastUnitName),
        string.format("last raw: %s", counters.lastProbe),
        string.format("wide raw: %s", counters.lastBroad),
        string.format("last bc: %s", counters.lastBroadCombat),
        string.format("last be: %s", counters.lastBroadEffect),
        string.format("last event: %s", secondsSince(counters.lastEventMs)),
    }

    for index = 1, #counters.recentBroadCombat do
        table.insert(lines, string.format("bc %d: %s", index, counters.recentBroadCombat[index]))
    end

    for index = 1, #counters.recentBroadEffects do
        table.insert(lines, string.format("be %d: %s", index, counters.recentBroadEffects[index]))
    end

    return lines
end

function Diagnostics.Render()
    if not isEnabled() then
        setVisible(false)
        return
    end

    setVisible(true)

    if Diagnostics.label and hasMethod(Diagnostics.label, "SetText") then
        Diagnostics.label:SetText(table.concat(formatLines(), "\n"))
    end
end

function Diagnostics.Initialize(control)
    Diagnostics.root = control

    if hasMethod(control, "GetNamedChild") then
        Diagnostics.label = control:GetNamedChild("Text")
        Diagnostics.backdrop = control:GetNamedChild("Backdrop")
    end

    configureControl(control, 2100, 1)

    if Diagnostics.backdrop then
        configureControl(Diagnostics.backdrop, 2099, 0.84)
    end

    if Diagnostics.label then
        configureControl(Diagnostics.label, 2101, 1)
    end

    Diagnostics.Render()
end

function Diagnostics.SetEnabled(enabled)
    local settings = Addon.GetSettings()

    settings.diagnosticsEnabled = enabled == true
    Diagnostics.Render()
end

function Diagnostics.Reset()
    Diagnostics.counters = newCounters()
    Diagnostics.Render()
end

function Diagnostics.RecordSynergyEvent()
    Diagnostics.counters.synergyEvents = Diagnostics.counters.synergyEvents + 1
    Diagnostics.counters.lastEventMs = getNowMs()
    Diagnostics.Render()
end

function Diagnostics.RecordOffer(name)
    Diagnostics.counters.offers = Diagnostics.counters.offers + 1
    Diagnostics.counters.lastOffer = name or "unknown"
    Diagnostics.counters.lastEventMs = getNowMs()
    Diagnostics.Render()
end

function Diagnostics.RecordActivation(abilityId, sourceName, targetName)
    local counters = Diagnostics.counters

    if abilityId == 48052 then
        counters.activation48052 = counters.activation48052 + 1
    elseif abilityId == 55677 then
        counters.activation55677 = counters.activation55677 + 1
    end

    counters.lastActivation = tostring(abilityId)
    counters.lastSourceName = displayName(sourceName)
    counters.lastTargetName = displayName(targetName)
    counters.lastSourceNormalized = normalizeName(sourceName)
    counters.playerName = displayName(getPlayerName())
    counters.playerNormalized = normalizeName(getPlayerName())
    counters.lastEventMs = getNowMs()

    if counters.playerNormalized ~= ""
        and counters.lastSourceNormalized ~= ""
        and counters.lastSourceNormalized ~= counters.playerNormalized then
        counters.possibleAllyActivations = counters.possibleAllyActivations + 1
    end

    Diagnostics.Render()
end

function Diagnostics.RecordCombatProbe(abilityId, abilityName, result, sourceName, targetName, hitValue)
    local counters = Diagnostics.counters

    counters.probeCombat = counters.probeCombat + 1

    if abilityId == 108799 then
        counters.marker108799 = counters.marker108799 + 1
    elseif abilityId == 108802 then
        counters.marker108802 = counters.marker108802 + 1
    elseif abilityId == 108821 then
        counters.marker108821 = counters.marker108821 + 1
    elseif abilityId == 108924 then
        counters.marker108924 = counters.marker108924 + 1
    end

    counters.lastSourceName = displayName(sourceName)
    counters.lastTargetName = displayName(targetName)
    counters.lastSourceNormalized = normalizeName(sourceName)
    counters.playerName = displayName(getPlayerName())
    counters.playerNormalized = normalizeName(getPlayerName())
    counters.lastProbe = string.format(
        "c id=%s r=%s hv=%s %s",
        tostring(abilityId or "nil"),
        tostring(result or "nil"),
        tostring(hitValue or "nil"),
        tostring(abilityName or "")
    )
    counters.lastEventMs = getNowMs()

    if counters.playerNormalized ~= ""
        and counters.lastSourceNormalized ~= ""
        and counters.lastSourceNormalized ~= counters.playerNormalized then
        counters.possibleAllyActivations = counters.possibleAllyActivations + 1
    end

    Diagnostics.Render()
end

function Diagnostics.RecordEffectProbe(
    changeType,
    effectName,
    unitTag,
    beginTime,
    endTime,
    stackCount,
    unitName,
    abilityId,
    sourceType
)
    local counters = Diagnostics.counters

    counters.probeEffects = counters.probeEffects + 1

    if abilityId == 108799 then
        counters.marker108799 = counters.marker108799 + 1
    elseif abilityId == 108802 then
        counters.marker108802 = counters.marker108802 + 1
    elseif abilityId == 108821 then
        counters.marker108821 = counters.marker108821 + 1
    elseif abilityId == 108924 then
        counters.marker108924 = counters.marker108924 + 1
    end

    counters.lastUnitTag = displayName(unitTag)
    counters.lastUnitName = displayName(unitName)
    counters.lastProbe = string.format(
        "e id=%s ch=%s st=%s src=%s %.1f-%.1f %s",
        tostring(abilityId or "nil"),
        tostring(changeType or "nil"),
        tostring(stackCount or "nil"),
        tostring(sourceType or "nil"),
        tonumber(beginTime) or 0,
        tonumber(endTime) or 0,
        tostring(effectName or "")
    )
    counters.lastEventMs = getNowMs()

    Diagnostics.Render()
end

function Diagnostics.RecordBroadCombat(
    result,
    abilityName,
    sourceName,
    sourceType,
    targetName,
    targetType,
    hitValue,
    sourceUnitId,
    targetUnitId,
    abilityId
)
    local counters = Diagnostics.counters

    counters.broadCombat = counters.broadCombat + 1
    countBroadAbility(counters, abilityId)
    counters.lastSourceName = displayName(sourceName)
    counters.lastTargetName = displayName(targetName)
    counters.lastSourceNormalized = normalizeName(sourceName)
    counters.playerName = displayName(getPlayerName())
    counters.playerNormalized = normalizeName(getPlayerName())
    counters.lastBroad = string.format(
        "bc id=%s r=%s st=%s/%s hv=%s su=%s tu=%s %s>%s %s",
        tostring(abilityId or "nil"),
        tostring(result or "nil"),
        tostring(sourceType or "nil"),
        tostring(targetType or "nil"),
        tostring(hitValue or "nil"),
        tostring(sourceUnitId or "nil"),
        tostring(targetUnitId or "nil"),
        displayName(sourceName),
        displayName(targetName),
        tostring(abilityName or "")
    )
    counters.lastBroadCombat = counters.lastBroad
    pushRecent(counters.recentBroadCombat, counters.lastBroad, RECENT_COMBAT_LIMIT)
    counters.lastEventMs = getNowMs()

    Diagnostics.Render()
end

function Diagnostics.RecordBroadEffect(
    changeType,
    effectName,
    unitTag,
    beginTime,
    endTime,
    stackCount,
    unitName,
    abilityId,
    sourceType,
    unitId,
    buffType,
    effectType,
    abilityType,
    statusEffectType
)
    local counters = Diagnostics.counters

    counters.broadEffects = counters.broadEffects + 1
    countBroadAbility(counters, abilityId)
    counters.lastUnitTag = displayName(unitTag)
    counters.lastUnitName = displayName(unitName)
    counters.lastBroad = string.format(
        "be id=%s ch=%s st=%s src=%s ui=%s bt=%s et=%s at=%s se=%s %s %s %.1f-%.1f",
        tostring(abilityId or "nil"),
        tostring(changeType or "nil"),
        tostring(stackCount or "nil"),
        tostring(sourceType or "nil"),
        tostring(unitId or "nil"),
        tostring(buffType or "nil"),
        tostring(effectType or "nil"),
        tostring(abilityType or "nil"),
        tostring(statusEffectType or "nil"),
        displayName(unitTag),
        tostring(effectName or ""),
        tonumber(beginTime) or 0,
        tonumber(endTime) or 0
    )
    counters.lastBroadEffect = counters.lastBroad
    pushRecent(counters.recentBroadEffects, counters.lastBroad, RECENT_EFFECT_LIMIT)
    counters.lastEventMs = getNowMs()

    Diagnostics.Render()
end

function Diagnostics.RecordLockout(durationMs)
    Diagnostics.counters.lockouts = Diagnostics.counters.lockouts + 1
    Diagnostics.counters.lastLockoutMs = durationMs or 0
    Diagnostics.counters.lastEventMs = getNowMs()
    Diagnostics.Render()
end

function Diagnostics.RecordReadyCue()
    Diagnostics.counters.readyCues = Diagnostics.counters.readyCues + 1
    Diagnostics.counters.lastEventMs = getNowMs()
    Diagnostics.Render()
end

function Diagnostics.BuildReportLine()
    local counters = Diagnostics.counters
    local format = "SynReg %s grouped=%s player=%s wide=%s source=%s target=%s offer=%s offers=%d raw=%d"
        .. " 48052=%d 55677=%d 108799=%d 108802=%d 108821=%d 108924=%d"
        .. " probeC=%d probeE=%d wideC=%d wideE=%d"
        .. " w26858=%d w95957=%d w26863=%d w48052=%d w55677=%d w108821=%d w108924=%d"
        .. " lockouts=%d ready=%d allySeen=%d"
        .. " lastRaw=%s wideRaw=%s lastBc=%s lastBe=%s last=%s"

    return string.format(
        format,
        Addon.Version or "dev",
        getGroupedText(),
        displayName(getPlayerName()),
        getBroadText(),
        counters.lastSourceName,
        counters.lastTargetName,
        counters.lastOffer,
        counters.offers,
        counters.synergyEvents,
        counters.activation48052,
        counters.activation55677,
        counters.marker108799,
        counters.marker108802,
        counters.marker108821,
        counters.marker108924,
        counters.probeCombat,
        counters.probeEffects,
        counters.broadCombat,
        counters.broadEffects,
        counters.broad26858,
        counters.broad95957,
        counters.broad26863,
        counters.broad48052,
        counters.broad55677,
        counters.broad108821,
        counters.broad108924,
        counters.lockouts,
        counters.readyCues,
        counters.possibleAllyActivations,
        counters.lastProbe,
        counters.lastBroad,
        counters.lastBroadCombat,
        counters.lastBroadEffect,
        secondsSince(counters.lastEventMs)
    )
end

function Diagnostics.Report()
    Diagnostics.Render()

    if Addon.Log and Addon.Log.Info then
        Addon.Log.Info(Diagnostics.BuildReportLine())
    end
end

Addon.Diagnostics = Diagnostics
