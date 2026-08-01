OsseinAssist = {}

OsseinAssist.name = "OsseinAssist"

OsseinAssist.osseinCageZoneName = "Ossein Cage"
OsseinAssist.testZoneName = "Solstice"
OsseinAssist.jynorahName = "Jynorah"
OsseinAssist.skorkifName = "Skorkhif"
OsseinAssist.skorkifUnitId = 323602
OsseinAssist.blazeforgedValneerName = "Blazeforged Valneer"
OsseinAssist.blazeforgedValneerUnitId = 323604
OsseinAssist.sparkstormMyrinaxName = "Sparkstorm Myrinax"
OsseinAssist.sparkstormMyrinaxUnitId = 323603
OsseinAssist.testAddName = "Hadolid Runt"
OsseinAssist.blazingAspectName = "Blazing Brimstone Aspect"
OsseinAssist.blazingAspectUnitId = 323649
OsseinAssist.sparkingAspectName = "Sparking Cold-Flame Aspect"
OsseinAssist.sparkingAspectUnitId = 323609
OsseinAssist.bashName = "Bash"
OsseinAssist.blazingSmashName = "Blazing Smash"
OsseinAssist.sparkSmashName = "Spark Smash"
OsseinAssist.blazingHeatRayName = "Blazing Heat Ray"
OsseinAssist.blazingHeatRayMainAbilityId = 234150      -- 8000ms, main heat ray effect
OsseinAssist.blazingHeatRayAllAbilityIds = { 234150, 234152, 234158 }
OsseinAssist.blazingHeatRayAbilityIdDurations = {
    [234150] = 8000,   -- main effect, likely the actual heat ray
    [234152] = 900,    -- shorter signal, likely cast start
    [234158] = 500,    -- shorter signal, likely cast start
}
OsseinAssist.sparkingHeatRayName = "Sparking Heat Ray"
OsseinAssist.sparkingHeatRayMainAbilityId = 234076     -- 8000ms, main heat ray effect
OsseinAssist.sparkingHeatRayAllAbilityIds = { 234076, 234079, 234128 }
OsseinAssist.sparkingHeatRayAbilityIdDurations = {
    [234076] = 8000,   -- main effect, likely the actual heat ray
    [234079] = 900,    -- shorter signal, likely cast start
    [234128] = 500,    -- shorter signal, likely cast start
}
OsseinAssist.heatRayAllAbilityIds = { 234150, 234152, 234158, 234076, 234079, 234128 }
OsseinAssist.heatRayAbilityIdDurations = {
    [234150] = 8000, [234152] = 900, [234158] = 500,
    [234076] = 8000, [234079] = 900, [234128] = 500,
}
OsseinAssist.searingSparksName = "Searing Sparks"
OsseinAssist.searingBlazeName = "Searing Blaze"
OsseinAssist.searingSparksAbilityId = 234002
OsseinAssist.searingBlazeAbilityId = 234277
OsseinAssist.titanicClashName = "Titanic Clash"
OsseinAssist.titanicClashLeapKnownAbilityIds = {
    232284,  -- Myr Titanic Clash Leap TRGT (Myrinax leap targeting)
    232287,  -- Val Titanic Clash Leap TRGT (Valneer leap targeting)
    233500,  -- Myr Titanic Clash Leap AL (Myrinax leap land)
    233512,  -- Val Titanic Clash Leap AL (Valneer leap land)
}
OsseinAssist.titanicClashKnownAbilityIds = {
    232375,  -- blue (Sparkstorm Myrinax side)
    232460,  -- blue (Sparkstorm Myrinax side)
    232473,  -- blue (Sparkstorm Myrinax side)
    232376,  -- orange (Blazeforged Valneer side)
    232465,  -- orange (Blazeforged Valneer side)
    232477,  -- orange (Blazeforged Valneer side)
    232449,  -- generic
    232450,  -- generic
    232516,  -- generic
    232517,  -- generic
    239333,  -- Anim (visual)
    239338,  -- Anim (visual)
    239340,  -- Anim Fatigue (visual)
    239341,  -- Anim Fatigue (visual)
}
OsseinAssist.seekingSparkSurgeName = "Seeking Spark Surge"
OsseinAssist.seekingSparkSurgeTitanAbilityId = 248041  -- RAD TITAN: the variant that damages the titan
OsseinAssist.seekingSparkSurgeKnownAbilityIds = {
    234564,  -- stun/debuff
    248035,  -- aoe
    248037,  -- aoe
    248040,  -- RAD PC: damages player
    248041,  -- RAD TITAN: damages titan
    248056,  -- movement deferred
}
OsseinAssist.sparkSurgeInfernoName = "Spark Surge Inferno"
OsseinAssist.sparkSurgeInfernoTitanAbilityId = 248038  -- Fx TITAN: the effect that fires on the titan
OsseinAssist.sparkSurgeInfernoKnownAbilityIds = {
    245891,  -- base
    245893,  -- variant
    245894,  -- REM (removal/end of effect)
    245921,  -- Fx (visual effect)
    248038,  -- Fx TITAN: fires on titan
    248039,  -- variant (likely player-side hit)
}
OsseinAssist.seekingForgeFireName = "Seeking Forge Fire"
OsseinAssist.seekingForgeFireTitanAbilityId = 248054  -- RAD TITAN: the variant that damages the titan
OsseinAssist.seekingForgeFireKnownAbilityIds = {
    234590,  -- stun/debuff
    248044,  -- aoe
    248046,  -- aoe
    248053,  -- RAD PC: damages player
    248054,  -- RAD TITAN: damages titan
    248055,  -- movement deferred
}
OsseinAssist.forgeFireInfernoName = "Forge Fire Inferno"
OsseinAssist.forgeFireInfernoTitanAbilityId = 248047  -- Fx TITAN: the effect that fires on the titan
OsseinAssist.forgeFireInfernoKnownAbilityIds = {
    245892,  -- base
    245895,  -- variant
    245896,  -- REM (removal/end of effect)
    245920,  -- Fx (visual effect)
    248047,  -- Fx TITAN: fires on titan
    248048,  -- variant (likely player-side hit)
}
OsseinAssist.blueColorHex = "2F7BFF"
OsseinAssist.redColorHex = "FF3B3B"
OsseinAssist.titanHealthTrackedAbilityNames = {
    OsseinAssist.blazingHeatRayName,
    OsseinAssist.sparkingHeatRayName,
    OsseinAssist.titanicClashName,
    OsseinAssist.seekingSparkSurgeName,
    OsseinAssist.sparkSurgeInfernoName,
    OsseinAssist.seekingForgeFireName,
    OsseinAssist.forgeFireInfernoName,
}
-- Ability IDs used to register filtered combat event listeners for titan health tracking.
-- For abilities with separate PC/titan variants, only the titan-side ID is included.
OsseinAssist.titanHealthAbilityIds = {}
for _, id in ipairs(OsseinAssist.blazingHeatRayAllAbilityIds) do
    table.insert(OsseinAssist.titanHealthAbilityIds, id)
end
for _, id in ipairs(OsseinAssist.sparkingHeatRayAllAbilityIds) do
    table.insert(OsseinAssist.titanHealthAbilityIds, id)
end
for _, id in ipairs(OsseinAssist.titanicClashKnownAbilityIds) do
    table.insert(OsseinAssist.titanHealthAbilityIds, id)
end
table.insert(OsseinAssist.titanHealthAbilityIds, OsseinAssist.seekingSparkSurgeTitanAbilityId)
table.insert(OsseinAssist.titanHealthAbilityIds, OsseinAssist.sparkSurgeInfernoTitanAbilityId)
table.insert(OsseinAssist.titanHealthAbilityIds, OsseinAssist.seekingForgeFireTitanAbilityId)
table.insert(OsseinAssist.titanHealthAbilityIds, OsseinAssist.forgeFireInfernoTitanAbilityId)

OsseinAssist.pendingTrackedCastBegins = {}
OsseinAssist.enableBashVisuals = false
OsseinAssist.playHeavyStartSound = false
OsseinAssist.runStartupBarTest = false
OsseinAssist.devOnly = true
OsseinAssist.devNames = {
    "@ohmygoron",
    "ohmygoron",
    "goron_spice",
}
OsseinAssist.activeBashCast = nil
OsseinAssist.heavySettingsPreviewActive = false
OsseinAssist.heavyTooltipFunctionLookup = {}
OsseinAssist.healthTooltipFunctionLookup = {}
OsseinAssist.learnedDurationMsByProfileKey = {}
OsseinAssist.defaultCastMinDurationMs = 800
OsseinAssist.defaultCastMaxDurationMs = 1000
OsseinAssist.defaultCastDurationMs = 900
OsseinAssist.warnedAboutUnfilteredCombatEvents = false
OsseinAssist.loggedAbilityIdsByProfileKey = {}
OsseinAssist.lastFightTwoDetectionMs = 0
OsseinAssist.fightTwoDetectionGraceMs = 12000
OsseinAssist.wasInOsseinCage = false
OsseinAssist.hasAnnouncedOsseinCageEntry = false
OsseinAssist.verboseDebugLoggingEnabled = false
OsseinAssist.debugHeartbeatIntervalMs = 2000
OsseinAssist.lastAnnouncedFightTwoState = nil
OsseinAssist.titanHealthLoggingEnabled = true
OsseinAssist.titanHealthFakeDataEnabled = false
OsseinAssist.titanHealthStats = {}
OsseinAssist.titanFightLogs = {}
OsseinAssist.maxTitanFightLogs = 20
OsseinAssist.currentTitanFightLog = nil
OsseinAssist.searingCastLoggingEnabled = false
OsseinAssist.searingPairWindowMs = 2000
OsseinAssist.searingCastDebounceMs = 8000
OsseinAssist.lastSearingCastByBoss = {}
OsseinAssist.lastSearingPairAnnounceMs = 0
OsseinAssist.lastSearingPairProcessMs = 0
OsseinAssist.showSearingAssignmentOnPanel = false
OsseinAssist.searingAssignment = "Not Assigned"
OsseinAssist.includeFirstSearingCurse = false
OsseinAssist.searingMechanicCount = 0
OsseinAssist.searingCurrentColor = nil
OsseinAssist.searingCurrentNumber = nil
OsseinAssist.devSettingsPreviewAsNonDev = false
OsseinAssist.healthPanelEnabled = true
OsseinAssist.healthPanelShowTitle = true
OsseinAssist.healthPanelShowBossHealth = true
OsseinAssist.healthPanelShowDragonHealth = true
OsseinAssist.healthPanelFakeModeEnabled = false
OsseinAssist.healthPanelPositionPreviewActive = false
OsseinAssist.healthPanelSearingPreviewActive = false
OsseinAssist.healthPanelOffsetX = 1260
OsseinAssist.healthPanelOffsetY = 810
OsseinAssist.healthPanelTextSize = 24
OsseinAssist.bossHealthChatLoggingEnabled = false
OsseinAssist.titanHealthChatLoggingEnabled = false
OsseinAssist.aspectHeavyChatLoggingEnabled = true
OsseinAssist.searingMechanicChatLoggingEnabled = true
OsseinAssist.heavyIndicatorOffsetX = 0
OsseinAssist.heavyIndicatorOffsetY = 220
OsseinAssist.fakeHealthPercents = {
    jynorah = 36.3,
    skorkif = 33.3,
    valneer = 45.1,
    myrinax = 92.1,
}
OsseinAssist.healthTrackerUpdateIntervalMs = 250
OsseinAssist.savedVariableVersion = 1
OsseinAssist.defaultSettings = {
    healthPanelEnabled = true,
    healthPanelShowTitle = true,
    healthPanelShowBossHealth = true,
    healthPanelShowDragonHealth = true,
    healthPanelFakeModeEnabled = false,
    healthPanelOffsetX = 1260,
    healthPanelOffsetY = 810,
    healthPanelTextSize = 24,
    bossHealthChatLoggingEnabled = false,
    titanHealthChatLoggingEnabled = false,
    aspectHeavyChatLoggingEnabled = true,
    searingMechanicChatLoggingEnabled = true,
    heavyIndicatorOffsetX = 0,
    heavyIndicatorOffsetY = 220,
    titanHealthLoggingEnabled = true,
    titanHealthFakeDataEnabled = false,
    searingCastLoggingEnabled = false,
    showSearingAssignmentOnPanel = false,
    searingAssignment = "Not Assigned",
    includeFirstSearingCurse = false,
    titanFightLogs = {},
    titanHealthSchemaMigrated = false,
    devSettingsPreviewAsNonDev = false,
    enableBashVisuals = false,
    playHeavyStartSound = false,
    runStartupBarTest = false,
}

OsseinAssist.searingAssignmentOptions = {
    "Not Assigned",
    "Blue 1",
    "Blue 2",
    "Red 1",
    "Red 2",
}
OsseinAssist.searingAssignmentDropdownItems = {
    { name = "Not Assigned", data = "Not Assigned" },
    { name = "Blue 1", data = "Blue 1" },
    { name = "Blue 2", data = "Blue 2" },
    { name = "Red 1", data = "Red 1" },
    { name = "Red 2", data = "Red 2" },
}

OsseinAssist.bashBarMaxWidth = 260
OsseinAssist.rollWarningStartProgress = 0.75

OsseinAssist.trackedCastProfiles = {
    {
        key = "hadolid_runt_bash",
        zone = "test",
        sourceName = OsseinAssist.testAddName,
        abilityName = OsseinAssist.bashName,
        abilityId = nil,
        label = "Hadolid Runt: Bash",
        -- Optional per-add override example:
        -- minDurationMs = 780,
        -- maxDurationMs = 980,
        -- defaultDurationMs = 900,
    },
    {
        key = "blazing_aspect_smash",
        zone = "trial",
        sourceName = OsseinAssist.blazingAspectName,
        abilityName = OsseinAssist.blazingSmashName,
        abilityId = 233606,
        knownAbilityIds = {
            233606,  -- 3000ms (main smash)
            233607,  -- 1900ms (stun)
            233610,  -- 0ms
            239373,  -- 3000ms
            239375,  -- 0ms
            245157,  -- 3000ms
            245159,  -- 1900ms (stun)
            245161,  -- 0ms
        },
        durationAbilityId = 233606,
        minDurationMs = 3000,
        maxDurationMs = 3000,
        defaultDurationMs = 3000,
        label = "Blazing Aspect: Blazing Smash",
    },
    {
        key = "sparking_aspect_smash",
        zone = "trial",
        sourceName = OsseinAssist.sparkingAspectName,
        abilityName = OsseinAssist.sparkSmashName,
        abilityId = 233596,
        knownAbilityIds = {
            233596,  -- 3000ms (main smash)
            233597,  -- 1900ms (stun)
            233598,  -- 0ms
            239364,  -- 3000ms
            239370,  -- 0ms
            245149,  -- 3000ms
            245151,  -- 1900ms (stun)
            245154,  -- 0ms
        },
        durationAbilityId = 233596,
        minDurationMs = 3000,
        maxDurationMs = 3000,
        defaultDurationMs = 3000,
        label = "Sparking Aspect: Spark Smash",
    },
}

function OsseinAssist.IsHadolidRuntSource(sourceName)
    return OsseinAssist.IsSourceNameMatch(sourceName, OsseinAssist.testAddName)
end

function OsseinAssist.IsDevUser()
    local function normalizeName(value)
        if value == nil or value == "" then
            return nil
        end
        local lowered = string.lower(tostring(value))
        if string.sub(lowered, 1, 1) == "@" then
            lowered = string.sub(lowered, 2)
        end
        return lowered
    end

    local namesToCheck = {}
    local hasDisplayName = false
    if type(GetDisplayName) == "function" then
        local displayName = GetDisplayName()
        if displayName ~= nil and displayName ~= "" then
            table.insert(namesToCheck, displayName)
            hasDisplayName = true
        end
    end
    if not hasDisplayName then
        table.insert(namesToCheck, GetUnitName("player"))
    end

    for _, candidateName in ipairs(namesToCheck) do
        if candidateName ~= nil and candidateName ~= "" then
            local loweredCandidate = normalizeName(candidateName)
            for _, devName in ipairs(OsseinAssist.devNames) do
                if loweredCandidate ~= nil and loweredCandidate == normalizeName(devName) then
                    return true
                end
            end
        end
    end

    return false
end

function OsseinAssist.CanMonitorTestAdd()
    return not OsseinAssist.devOnly or OsseinAssist.IsDevUser()
end

function OsseinAssist.ShouldShowDevOnlySettings()
    return OsseinAssist.IsDevUser() and not OsseinAssist.devSettingsPreviewAsNonDev
end

function OsseinAssist.IsValidSearingAssignment(assignment)
    for _, option in ipairs(OsseinAssist.searingAssignmentOptions) do
        if assignment == option then
            return true
        end
    end
    return false
end

function OsseinAssist.IsSearingAssignmentActive()
    return OsseinAssist.searingAssignment ~= nil and OsseinAssist.searingAssignment ~= "Not Assigned"
end

function OsseinAssist.GetSearingAssignmentParts(assignment)
    local choice = assignment or OsseinAssist.searingAssignment
    if choice == nil or choice == "Not Assigned" then
        return nil, nil
    end
    local color = string.match(choice, "^(%a+)")
    local number = tonumber(string.match(choice, "(%d+)"))
    return color, number
end

function OsseinAssist.GetOppositeSearingColor(color)
    if color == "Blue" then
        return "Red"
    end
    if color == "Red" then
        return "Blue"
    end
    return nil
end

function OsseinAssist.ResetSearingAssignmentState()
    local baseColor, number = OsseinAssist.GetSearingAssignmentParts(OsseinAssist.searingAssignment)
    OsseinAssist.searingMechanicCount = 0
    OsseinAssist.searingCurrentColor = baseColor
    OsseinAssist.searingCurrentNumber = number
    OsseinAssist.lastSearingCastByBoss = {}
    OsseinAssist.lastSearingPairAnnounceMs = 0
    OsseinAssist.lastSearingPairProcessMs = 0
end

function OsseinAssist.SetSearingAssignment(assignment, maybeAssignmentName)
    local nextAssignment = assignment
    if type(nextAssignment) == "table" then
        if type(nextAssignment.name) == "string" then
            nextAssignment = nextAssignment.name
        elseif type(nextAssignment.data) == "table" and type(nextAssignment.data.name) == "string" then
            nextAssignment = nextAssignment.data.name
        else
            nextAssignment = nil
        end
    end
    if type(nextAssignment) == "number" then
        local indexed = OsseinAssist.searingAssignmentOptions[nextAssignment]
        if type(indexed) == "string" then
            nextAssignment = indexed
        else
            nextAssignment = nil
        end
    end
    if type(nextAssignment) ~= "string" and type(maybeAssignmentName) == "string" then
        nextAssignment = maybeAssignmentName
    end
    if type(nextAssignment) ~= "string" and type(maybeAssignmentName) == "table" then
        if type(maybeAssignmentName.name) == "string" then
            nextAssignment = maybeAssignmentName.name
        elseif type(maybeAssignmentName.data) == "table" and type(maybeAssignmentName.data.name) == "string" then
            nextAssignment = maybeAssignmentName.data.name
        end
    end
    if type(nextAssignment) ~= "string" then
        nextAssignment = "Not Assigned"
    end
    if not OsseinAssist.IsValidSearingAssignment(nextAssignment) then
        nextAssignment = "Not Assigned"
    end
    OsseinAssist.searingAssignment = nextAssignment
    if OsseinAssist.savedVariables ~= nil then
        OsseinAssist.savedVariables.searingAssignment = nextAssignment
    end
    OsseinAssist.ResetSearingAssignmentState()
    if type(OsseinAssist.RefreshSearingCastTrackingRegistration) == "function" then
        OsseinAssist.RefreshSearingCastTrackingRegistration()
    end
end

function OsseinAssist.SetShowSearingAssignmentOnPanel(enabled)
    OsseinAssist.showSearingAssignmentOnPanel = enabled
    if OsseinAssist.savedVariables ~= nil then
        OsseinAssist.savedVariables.showSearingAssignmentOnPanel = enabled
    end
    if not enabled then
        if type(OsseinAssist.SetHealthPanelSearingPreviewActive) == "function" then
            OsseinAssist.SetHealthPanelSearingPreviewActive(false)
        end
        if OsseinAssistHealthPanelAssignment ~= nil then
            OsseinAssistHealthPanelAssignment:SetText("")
        end
        if type(OsseinAssist.ApplyHealthPanelLayout) == "function" then
            OsseinAssist.ApplyHealthPanelLayout(
                OsseinAssist.healthPanelShowTitle,
                OsseinAssist.healthPanelShowBossHealth,
                OsseinAssist.healthPanelShowDragonHealth,
                false
            )
        end
    end
end

function OsseinAssist.SetIncludeFirstSearingCurse(enabled)
    local value = enabled and true or false
    OsseinAssist.includeFirstSearingCurse = value
    if OsseinAssist.savedVariables ~= nil then
        OsseinAssist.savedVariables.includeFirstSearingCurse = value
    end
end

function OsseinAssist.AdvanceSearingMechanicState()
    if not OsseinAssist.IsSearingAssignmentActive() then
        return
    end
    if OsseinAssist.searingCurrentColor == nil or OsseinAssist.searingCurrentNumber == nil then
        OsseinAssist.ResetSearingAssignmentState()
    end

    OsseinAssist.searingMechanicCount = (OsseinAssist.searingMechanicCount or 0) + 1
    if OsseinAssist.searingMechanicCount == 1 and not OsseinAssist.includeFirstSearingCurse then
        return
    end
    OsseinAssist.searingCurrentColor = OsseinAssist.GetOppositeSearingColor(OsseinAssist.searingCurrentColor)
end

function OsseinAssist.GetBlazeforgedValneerNameVariants()
    return {
        OsseinAssist.blazeforgedValneerName,
    }
end

function OsseinAssist.GetSparkstormMyrinaxNameVariants()
    return {
        OsseinAssist.sparkstormMyrinaxName,
    }
end

function OsseinAssist.GetBlazingAspectNameVariants()
    return {
        OsseinAssist.blazingAspectName,
    }
end

function OsseinAssist.GetSparkingAspectNameVariants()
    return {
        OsseinAssist.sparkingAspectName,
    }
end

function OsseinAssist.ResolveTitanEncounterName(unitName, unitId)
    local numericUnitId = tonumber(unitId)
    if numericUnitId ~= nil and numericUnitId == OsseinAssist.blazeforgedValneerUnitId then
        return OsseinAssist.blazeforgedValneerName
    end
    if numericUnitId ~= nil and numericUnitId == OsseinAssist.sparkstormMyrinaxUnitId then
        return OsseinAssist.sparkstormMyrinaxName
    end

    if OsseinAssist.IsSourceNameMatch(unitName, OsseinAssist.GetBlazeforgedValneerNameVariants()) then
        return OsseinAssist.blazeforgedValneerName
    end
    if OsseinAssist.IsSourceNameMatch(unitName, OsseinAssist.GetSparkstormMyrinaxNameVariants()) then
        return OsseinAssist.sparkstormMyrinaxName
    end
    return nil
end

function OsseinAssist.ResolveAspectEncounterName(unitName, unitId)
    local numericUnitId = tonumber(unitId)
    if numericUnitId ~= nil and numericUnitId == OsseinAssist.blazingAspectUnitId then
        return OsseinAssist.blazingAspectName
    end
    if numericUnitId ~= nil and numericUnitId == OsseinAssist.sparkingAspectUnitId then
        return OsseinAssist.sparkingAspectName
    end

    if OsseinAssist.IsSourceNameMatch(unitName, OsseinAssist.GetBlazingAspectNameVariants()) then
        return OsseinAssist.blazingAspectName
    end
    if OsseinAssist.IsSourceNameMatch(unitName, OsseinAssist.GetSparkingAspectNameVariants()) then
        return OsseinAssist.sparkingAspectName
    end
    return nil
end

function OsseinAssist.CanEmitDevCategoryLog(enabledFlag)
    return enabledFlag == true and OsseinAssist.IsDevUser()
end

function OsseinAssist.LogBossHealthMessage(text)
    if OsseinAssist.CanEmitDevCategoryLog(OsseinAssist.bossHealthChatLoggingEnabled) then
        d(tostring(text))
    end
end

function OsseinAssist.LogTitanHealthMessage(text)
    if OsseinAssist.CanEmitDevCategoryLog(OsseinAssist.titanHealthChatLoggingEnabled) then
        d(tostring(text))
    end
end

function OsseinAssist.LogAspectHeavyMessage(text)
    if OsseinAssist.CanEmitDevCategoryLog(OsseinAssist.aspectHeavyChatLoggingEnabled) then
        d(tostring(text))
    end
end

function OsseinAssist.LogSearingMechanicMessage(text)
    if OsseinAssist.CanEmitDevCategoryLog(OsseinAssist.searingMechanicChatLoggingEnabled) then
        d(tostring(text))
    end
end

function OsseinAssist.SetBossHealthChatLoggingEnabled(enabled)
    local value = enabled and true or false
    OsseinAssist.bossHealthChatLoggingEnabled = value
    if OsseinAssist.savedVariables ~= nil then
        OsseinAssist.savedVariables.bossHealthChatLoggingEnabled = value
    end
    d(string.format("Ossein Assist: boss health chat logging %s.", value and "enabled" or "disabled"))
end

function OsseinAssist.SetTitanHealthChatLoggingEnabled(enabled)
    local value = enabled and true or false
    OsseinAssist.titanHealthChatLoggingEnabled = value
    if OsseinAssist.savedVariables ~= nil then
        OsseinAssist.savedVariables.titanHealthChatLoggingEnabled = value
    end
    d(string.format("Ossein Assist: titan health chat logging %s.", value and "enabled" or "disabled"))
end

function OsseinAssist.SetAspectHeavyChatLoggingEnabled(enabled)
    local value = enabled and true or false
    OsseinAssist.aspectHeavyChatLoggingEnabled = value
    if OsseinAssist.savedVariables ~= nil then
        OsseinAssist.savedVariables.aspectHeavyChatLoggingEnabled = value
    end
    if type(OsseinAssist.RefreshHeatRaySignalTrackingRegistration) == "function" then
        OsseinAssist.RefreshHeatRaySignalTrackingRegistration()
    end
    d(string.format("Ossein Assist: aspect heavy chat logging %s.", value and "enabled" or "disabled"))
end

function OsseinAssist.SetSearingMechanicChatLoggingEnabled(enabled)
    local value = enabled and true or false
    OsseinAssist.searingMechanicChatLoggingEnabled = value
    if OsseinAssist.savedVariables ~= nil then
        OsseinAssist.savedVariables.searingMechanicChatLoggingEnabled = value
    end
    d(string.format("Ossein Assist: searing mechanic chat logging %s.", value and "enabled" or "disabled"))
end

function OsseinAssist.IsSourceNameMatch(sourceName, expectedName)
    if sourceName == nil or expectedName == nil then
        return false
    end
    if type(sourceName) ~= "string" then
        return false
    end
    if sourceName == "" then
        return false
    end

    if type(expectedName) == "table" then
        for _, expected in ipairs(expectedName) do
            if OsseinAssist.IsSourceNameMatch(sourceName, expected) then
                return true
            end
        end
        return false
    end
    if type(expectedName) ~= "string" or expectedName == "" then
        return false
    end

    local normalizedSourceName = sourceName
    if type(zo_strformat) == "function" then
        normalizedSourceName = zo_strformat(SI_UNIT_NAME, sourceName)
    end
    if type(normalizedSourceName) ~= "string" then
        return false
    end

    local normalizedExpectedName = expectedName
    if type(zo_strformat) == "function" then
        normalizedExpectedName = zo_strformat(SI_UNIT_NAME, expectedName)
    end
    if type(normalizedExpectedName) ~= "string" or normalizedExpectedName == "" then
        return false
    end

    return string.find(string.lower(normalizedSourceName), string.lower(normalizedExpectedName), 1, true) ~= nil
end

function OsseinAssist.DebugLog(text)
    if not OsseinAssist.verboseDebugLoggingEnabled then
        return
    end
    d("Ossein Assist [Debug]: " .. tostring(text))
end

function OsseinAssist.GetFightTwoDebugUnitSnapshot()
    local unitTags = { "target", "reticleover", "boss1", "boss2", "boss3", "boss4", "boss5", "boss6" }
    local parts = {}
    for _, unitTag in ipairs(unitTags) do
        local unitName = GetUnitName(unitTag)
        if unitName ~= nil and unitName ~= "" then
            table.insert(parts, string.format("%s=%s", unitTag, tostring(unitName)))
        end
    end
    if #parts == 0 then
        return "no tracked unit names"
    end
    return table.concat(parts, "; ")
end

function OsseinAssist.LogFightTwoState(reason, isFightTwo)
    if OsseinAssist.lastAnnouncedFightTwoState ~= isFightTwo then
        if isFightTwo then
            d(string.format("Ossein Assist: IN SECOND FIGHT (%s).", tostring(reason)))
        else
            d(string.format("Ossein Assist: NOT in second fight (%s).", tostring(reason)))
        end
        OsseinAssist.lastAnnouncedFightTwoState = isFightTwo
        return
    end
    OsseinAssist.DebugLog(string.format("fight2=%s (%s).", tostring(isFightTwo), tostring(reason)))
end

function OsseinAssist.IsInOsseinCage()
    local zoneIndex = GetUnitZoneIndex("player")
    if zoneIndex == nil then
        d("Ossein Assist: Unable to determine player's zone index.")
        return false
    end

    local zoneName = GetZoneNameByIndex(zoneIndex)
    return zoneName == OsseinAssist.osseinCageZoneName
end

function OsseinAssist.IsInTestZone()
    local zoneIndex = GetUnitZoneIndex("player")
    if zoneIndex == nil then
        d("Ossein Assist: Unable to determine player's zone index.")
        return false
    end

    local zoneName = GetZoneNameByIndex(zoneIndex)
    return zoneName == OsseinAssist.testZoneName
end

function OsseinAssist.IsLibHarvensSettingsSceneShowing()
    if not IsConsoleUI() then
        return true
    end
    if SCENE_MANAGER == nil or type(SCENE_MANAGER.GetScene) ~= "function" then
        return false
    end

    local scene = SCENE_MANAGER:GetScene("LibHarvensAddonSettingsScene")
    if scene == nil or type(scene.IsShowing) ~= "function" then
        return false
    end
    return scene:IsShowing()
end

function OsseinAssist.IsNamedUnitPresent(expectedName, expectedUnitId)
    local numericExpectedUnitId = tonumber(expectedUnitId)
    if numericExpectedUnitId ~= nil then
        local cachedTag = OsseinAssist.titanUnitTagCache[numericExpectedUnitId]
        if cachedTag ~= nil and cachedTag ~= "" then
            if type(DoesUnitExist) ~= "function" or DoesUnitExist(cachedTag) then
                return true
            end
        end
    end

    local trackedUnitTags = { "target", "reticleover" }
    for index = 1, 6 do
        table.insert(trackedUnitTags, "boss" .. tostring(index))
    end
    for index = 1, 24 do
        table.insert(trackedUnitTags, "group" .. tostring(index))
    end

    for _, unitTag in ipairs(trackedUnitTags) do
        local unitName = GetUnitName(unitTag)
        if unitName ~= nil and unitName ~= "" and OsseinAssist.IsSourceNameMatch(unitName, expectedName) then
            return true
        end
    end

    return false
end

function OsseinAssist.MarkFightTwoDetected()
    OsseinAssist.lastFightTwoDetectionMs = GetFrameTimeMilliseconds()
end

function OsseinAssist.IsFightTwoSourceName(sourceName)
    return OsseinAssist.IsSourceNameMatch(sourceName, OsseinAssist.jynorahName)
        or OsseinAssist.IsSourceNameMatch(sourceName, OsseinAssist.skorkifName)
        or OsseinAssist.ResolveAspectEncounterName(sourceName) ~= nil
        or OsseinAssist.ResolveTitanEncounterName(sourceName) ~= nil
end

function OsseinAssist.IsJynorahAndSkorkhifFight()
    if not OsseinAssist.IsInOsseinCage() then
        OsseinAssist.LogFightTwoState("not_in_ossein_cage", false)
        return false
    end

    local hasJynorah = OsseinAssist.IsNamedUnitPresent(OsseinAssist.jynorahName)
    local hasSkorkif = OsseinAssist.IsNamedUnitPresent(OsseinAssist.skorkifName, OsseinAssist.skorkifUnitId)
    local hasValneer = OsseinAssist.IsNamedUnitPresent(OsseinAssist.GetBlazeforgedValneerNameVariants(), OsseinAssist.blazeforgedValneerUnitId)
    local hasMyrinax = OsseinAssist.IsNamedUnitPresent(OsseinAssist.GetSparkstormMyrinaxNameVariants(), OsseinAssist.sparkstormMyrinaxUnitId)
    local hasEncounterUnits = hasJynorah or hasSkorkif or hasValneer or hasMyrinax
    if hasEncounterUnits then
        OsseinAssist.MarkFightTwoDetected()
        OsseinAssist.LogFightTwoState(
            string.format(
                "unit_presence(j=%s,s=%s,v=%s,m=%s) %s",
                tostring(hasJynorah),
                tostring(hasSkorkif),
                tostring(hasValneer),
                tostring(hasMyrinax),
                OsseinAssist.GetFightTwoDebugUnitSnapshot()
            ),
            true
        )
        return true
    end

    if IsUnitInCombat("player") then
        local elapsedMs = GetFrameTimeMilliseconds() - (OsseinAssist.lastFightTwoDetectionMs or 0)
        if elapsedMs <= OsseinAssist.fightTwoDetectionGraceMs then
            OsseinAssist.LogFightTwoState(string.format("combat_grace_window elapsedMs=%d", elapsedMs), true)
            return true
        end
    end

    OsseinAssist.LogFightTwoState("no_units_and_no_grace " .. OsseinAssist.GetFightTwoDebugUnitSnapshot(), false)
    return false
end

function OsseinAssist.UpdateOsseinCageEntryAnnouncement()
    local isInOsseinCage = OsseinAssist.IsInOsseinCage()
    if isInOsseinCage and not OsseinAssist.wasInOsseinCage then
        OsseinAssist.hasAnnouncedOsseinCageEntry = false
    end

    if isInOsseinCage and not OsseinAssist.hasAnnouncedOsseinCageEntry then
        d("Ossein Assist: Player in Ossein Cage.")
        OsseinAssist.hasAnnouncedOsseinCageEntry = true
    elseif not isInOsseinCage then
        OsseinAssist.hasAnnouncedOsseinCageEntry = false
    end

    OsseinAssist.wasInOsseinCage = isInOsseinCage
    return isInOsseinCage
end

function OsseinAssist.OnPlayerActivated(event)
    OsseinAssist.UpdateOsseinCageEntryAnnouncement()
end

function OsseinAssist.IsTestingOnAdd()
    local trackedUnitTags = { "target", "reticleover" }
    for _, unitTag in ipairs(trackedUnitTags) do
        local unitName = GetUnitName(unitTag)
        if unitName ~= "" and string.find(unitName, OsseinAssist.testAddName) then
            return true
        end
    end

    return false
end

function OsseinAssist.OnPlayerCombatState(event, inCombat)
    local isInOsseinCage = OsseinAssist.UpdateOsseinCageEntryAnnouncement()
    local isInTestZone = OsseinAssist.IsInTestZone() and OsseinAssist.CanMonitorTestAdd()
    OsseinAssist.DebugLog(string.format("combat_state event inCombat=%s ossein=%s testZone=%s", tostring(inCombat), tostring(isInOsseinCage), tostring(isInTestZone)))
    if not isInOsseinCage and not isInTestZone then
        OsseinAssist.DebugLog("combat_state ignored: not in tracked zone.")
        return
    end

    local isTrialFight = isInOsseinCage and OsseinAssist.IsJynorahAndSkorkhifFight()
    local isTestAddTargeted = isInTestZone and OsseinAssist.IsTestingOnAdd()
    OsseinAssist.DebugLog(string.format("combat_state gating trialFight=%s testAddTargeted=%s", tostring(isTrialFight), tostring(isTestAddTargeted)))
    if not isTrialFight and not isTestAddTargeted then
        if not inCombat and OsseinAssist.titanHealthLoggingEnabled then
            OsseinAssist.FinalizeTitanFightLog("fight_lost")
        end
        OsseinAssist.DebugLog("combat_state early return: no recognized tracked fight.")
        return
    end

    if inCombat then
        if isTrialFight then
            OsseinAssist.ResetSearingAssignmentState()
            if OsseinAssist.titanHealthLoggingEnabled then
                OsseinAssist.StartTitanFightLog()
            end
            d("Ossein Assist: Player entering combat with Jynorah And Skorkhif.")
        else
            d("Ossein Assist: Player entering combat with Hadolid Runt.")
        end
    else
        if isTrialFight then
            if OsseinAssist.titanHealthLoggingEnabled then
                OsseinAssist.FinalizeTitanFightLog("combat_end")
            end
            d("Ossein Assist: Player exiting combat with Jynorah And Skorkhif.")
        else
            d("Ossein Assist: Player exiting combat with Hadolid Runt.")
        end
    end
end

function OsseinAssist.DebugHeartbeatUpdate()
    if not OsseinAssist.verboseDebugLoggingEnabled then
        return
    end

    local isInOsseinCage = OsseinAssist.IsInOsseinCage()
    local isInCombat = IsUnitInCombat("player")
    local isFightTwo = isInOsseinCage and OsseinAssist.IsJynorahAndSkorkhifFight()
    OsseinAssist.DebugLog(string.format(
        "heartbeat: zone=%s combat=%s fight2=%s detectedAgoMs=%d units=[%s]",
        tostring(isInOsseinCage),
        tostring(isInCombat),
        tostring(isFightTwo),
        GetFrameTimeMilliseconds() - (OsseinAssist.lastFightTwoDetectionMs or 0),
        OsseinAssist.GetFightTwoDebugUnitSnapshot()
    ))
end

function OsseinAssist.InitializeSavedVariables()
    OsseinAssist.savedVariables = ZO_SavedVars:NewAccountWide("OsseinAssistSavedVariables", OsseinAssist.savedVariableVersion, nil, OsseinAssist.defaultSettings)
    local saved = OsseinAssist.savedVariables

    if not saved.titanHealthSchemaMigrated then
        if saved.heatRayMeasurementEnabled ~= nil then
            saved.titanHealthLoggingEnabled = saved.heatRayMeasurementEnabled
        end
        if saved.heatRayFakeDataEnabled ~= nil then
            saved.titanHealthFakeDataEnabled = saved.heatRayFakeDataEnabled
        end
        if saved.heatRayFightLogs ~= nil then
            saved.titanFightLogs = saved.heatRayFightLogs
        end
        saved.titanHealthSchemaMigrated = true
    end

    OsseinAssist.healthPanelEnabled = saved.healthPanelEnabled
    OsseinAssist.healthPanelShowTitle = saved.healthPanelShowTitle
    OsseinAssist.healthPanelShowBossHealth = saved.healthPanelShowBossHealth
    OsseinAssist.healthPanelShowDragonHealth = saved.healthPanelShowDragonHealth
    OsseinAssist.healthPanelFakeModeEnabled = saved.healthPanelFakeModeEnabled
    OsseinAssist.healthPanelOffsetX = saved.healthPanelOffsetX
    OsseinAssist.healthPanelOffsetY = saved.healthPanelOffsetY
    OsseinAssist.healthPanelTextSize = saved.healthPanelTextSize
    OsseinAssist.bossHealthChatLoggingEnabled = saved.bossHealthChatLoggingEnabled
    OsseinAssist.titanHealthChatLoggingEnabled = saved.titanHealthChatLoggingEnabled
    OsseinAssist.aspectHeavyChatLoggingEnabled = saved.aspectHeavyChatLoggingEnabled
    OsseinAssist.searingMechanicChatLoggingEnabled = saved.searingMechanicChatLoggingEnabled
    OsseinAssist.heavyIndicatorOffsetX = saved.heavyIndicatorOffsetX
    OsseinAssist.heavyIndicatorOffsetY = saved.heavyIndicatorOffsetY
    OsseinAssist.titanHealthLoggingEnabled = saved.titanHealthLoggingEnabled
    OsseinAssist.titanHealthFakeDataEnabled = saved.titanHealthFakeDataEnabled
    OsseinAssist.searingCastLoggingEnabled = saved.searingCastLoggingEnabled
    OsseinAssist.showSearingAssignmentOnPanel = saved.showSearingAssignmentOnPanel
    OsseinAssist.searingAssignment = saved.searingAssignment
    OsseinAssist.includeFirstSearingCurse = saved.includeFirstSearingCurse
    if type(OsseinAssist.searingAssignment) == "table" then
        OsseinAssist.searingAssignment = OsseinAssist.searingAssignment.name
    end
    if type(OsseinAssist.searingAssignment) ~= "string" then
        OsseinAssist.searingAssignment = "Not Assigned"
        saved.searingAssignment = OsseinAssist.searingAssignment
    end
    OsseinAssist.devSettingsPreviewAsNonDev = saved.devSettingsPreviewAsNonDev or false
    if OsseinAssist.titanHealthFakeDataEnabled and not OsseinAssist.IsDevUser() then
        OsseinAssist.titanHealthFakeDataEnabled = false
        saved.titanHealthFakeDataEnabled = false
    end
    if not OsseinAssist.IsDevUser() then
        OsseinAssist.searingCastLoggingEnabled = false
        saved.searingCastLoggingEnabled = false
        OsseinAssist.devSettingsPreviewAsNonDev = false
        saved.devSettingsPreviewAsNonDev = false
    end
    OsseinAssist.titanFightLogs = saved.titanFightLogs or {}
    while #OsseinAssist.titanFightLogs > OsseinAssist.maxTitanFightLogs do
        table.remove(OsseinAssist.titanFightLogs)
    end
    saved.titanFightLogs = OsseinAssist.titanFightLogs
    OsseinAssist.enableBashVisuals = saved.enableBashVisuals
    OsseinAssist.playHeavyStartSound = saved.playHeavyStartSound
    OsseinAssist.runStartupBarTest = saved.runStartupBarTest
    if OsseinAssist.runStartupBarTest and not OsseinAssist.IsDevUser() then
        OsseinAssist.runStartupBarTest = false
        saved.runStartupBarTest = false
    end
    if not OsseinAssist.IsValidSearingAssignment(OsseinAssist.searingAssignment) then
        OsseinAssist.searingAssignment = "Not Assigned"
        saved.searingAssignment = OsseinAssist.searingAssignment
    end
    if OsseinAssist.showSearingAssignmentOnPanel == nil then
        OsseinAssist.showSearingAssignmentOnPanel = false
        saved.showSearingAssignmentOnPanel = false
    end
    if OsseinAssist.healthPanelShowTitle == nil then
        OsseinAssist.healthPanelShowTitle = OsseinAssist.defaultSettings.healthPanelShowTitle
        saved.healthPanelShowTitle = OsseinAssist.healthPanelShowTitle
    end
    if OsseinAssist.healthPanelShowBossHealth == nil then
        OsseinAssist.healthPanelShowBossHealth = OsseinAssist.defaultSettings.healthPanelShowBossHealth
        saved.healthPanelShowBossHealth = OsseinAssist.healthPanelShowBossHealth
    end
    if OsseinAssist.healthPanelShowDragonHealth == nil then
        OsseinAssist.healthPanelShowDragonHealth = OsseinAssist.defaultSettings.healthPanelShowDragonHealth
        saved.healthPanelShowDragonHealth = OsseinAssist.healthPanelShowDragonHealth
    end
    if OsseinAssist.includeFirstSearingCurse == nil then
        OsseinAssist.includeFirstSearingCurse = OsseinAssist.defaultSettings.includeFirstSearingCurse
        saved.includeFirstSearingCurse = OsseinAssist.includeFirstSearingCurse
    end
    if OsseinAssist.heavyIndicatorOffsetX == nil then
        OsseinAssist.heavyIndicatorOffsetX = OsseinAssist.defaultSettings.heavyIndicatorOffsetX
        saved.heavyIndicatorOffsetX = OsseinAssist.heavyIndicatorOffsetX
    end
    if OsseinAssist.heavyIndicatorOffsetY == nil then
        OsseinAssist.heavyIndicatorOffsetY = OsseinAssist.defaultSettings.heavyIndicatorOffsetY
        saved.heavyIndicatorOffsetY = OsseinAssist.heavyIndicatorOffsetY
    end
    if OsseinAssist.healthPanelTextSize == nil then
        OsseinAssist.healthPanelTextSize = OsseinAssist.defaultSettings.healthPanelTextSize
        saved.healthPanelTextSize = OsseinAssist.healthPanelTextSize
    end
    if OsseinAssist.bossHealthChatLoggingEnabled == nil then
        OsseinAssist.bossHealthChatLoggingEnabled = OsseinAssist.defaultSettings.bossHealthChatLoggingEnabled
        saved.bossHealthChatLoggingEnabled = OsseinAssist.bossHealthChatLoggingEnabled
    end
    if OsseinAssist.titanHealthChatLoggingEnabled == nil then
        OsseinAssist.titanHealthChatLoggingEnabled = OsseinAssist.defaultSettings.titanHealthChatLoggingEnabled
        saved.titanHealthChatLoggingEnabled = OsseinAssist.titanHealthChatLoggingEnabled
    end
    if OsseinAssist.aspectHeavyChatLoggingEnabled == nil then
        OsseinAssist.aspectHeavyChatLoggingEnabled = OsseinAssist.defaultSettings.aspectHeavyChatLoggingEnabled
        saved.aspectHeavyChatLoggingEnabled = OsseinAssist.aspectHeavyChatLoggingEnabled
    end
    if OsseinAssist.searingMechanicChatLoggingEnabled == nil then
        OsseinAssist.searingMechanicChatLoggingEnabled = OsseinAssist.defaultSettings.searingMechanicChatLoggingEnabled
        saved.searingMechanicChatLoggingEnabled = OsseinAssist.searingMechanicChatLoggingEnabled
    end
    OsseinAssist.ResetSearingAssignmentState()
end

function OsseinAssist.Initialize()
    OsseinAssist.InitializeSavedVariables()
    OsseinAssist.PrepareIndicatorForConsole()
    OsseinAssist.PrepareHealthPanelForConsole()
    OsseinAssist.ConfigureBarZones()
    OsseinAssist.SetBashBarProgress(0)

    EVENT_MANAGER:RegisterForEvent(OsseinAssist.name, EVENT_PLAYER_COMBAT_STATE, OsseinAssist.OnPlayerCombatState)
    EVENT_MANAGER:RegisterForEvent(OsseinAssist.name, EVENT_PLAYER_ACTIVATED, OsseinAssist.OnPlayerActivated)
    EVENT_MANAGER:UnregisterForUpdate(OsseinAssist.name .. "DebugHeartbeat")
    if OsseinAssist.verboseDebugLoggingEnabled then
        EVENT_MANAGER:RegisterForUpdate(OsseinAssist.name .. "DebugHeartbeat", OsseinAssist.debugHeartbeatIntervalMs, OsseinAssist.DebugHeartbeatUpdate)
    end
    EVENT_MANAGER:UnregisterForEvent(OsseinAssist.name, EVENT_COMBAT_EVENT)
    OsseinAssist.RegisterFilteredCombatEvents()
    if OsseinAssist.HasAnyTrackedCastAbilityIds() then
        d("Ossein Assist: Using filtered combat events for tracked ability IDs.")
    else
        EVENT_MANAGER:RegisterForEvent(OsseinAssist.name, EVENT_COMBAT_EVENT, OsseinAssist.OnCombatEvent)
        if not OsseinAssist.warnedAboutUnfilteredCombatEvents then
            d("Ossein Assist: No tracked ability IDs configured; falling back to unfiltered combat events. Populate abilityId per profile to enable AddFilterForEvent.")
            OsseinAssist.warnedAboutUnfilteredCombatEvents = true
        end
    end
    OsseinAssist.StartTitanUnitTagDiscovery()
    OsseinAssist.StartHealthPanelTracking()
    OsseinAssist.StartTitanHealthTracking()
    OsseinAssist.StartHeatRaySignalTracking()
    OsseinAssist.StartSearingCastTracking()
    OsseinAssist.StartStartupBarTest()
    SLASH_COMMANDS["/ossein"] = OsseinAssist.OnSlashCommand
    OsseinAssist.RegisterSettingsPanel()
    OsseinAssist.UpdateOsseinCageEntryAnnouncement()
end

function OsseinAssist.OnAddOnLoaded(event, addonName)
    if addonName ~= OsseinAssist.name then
        return
    end

    EVENT_MANAGER:UnregisterForEvent(OsseinAssist.name, EVENT_ADD_ON_LOADED)
    OsseinAssist.Initialize()
end

EVENT_MANAGER:RegisterForEvent(OsseinAssist.name, EVENT_ADD_ON_LOADED, OsseinAssist.OnAddOnLoaded)
