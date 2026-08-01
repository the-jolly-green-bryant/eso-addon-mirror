function OsseinAssist.ApplyHealthPanelAnchor()
    OsseinAssistHealthPanel:ClearAnchors()
    OsseinAssistHealthPanel:SetAnchor(TOP, GuiRoot, TOP, OsseinAssist.healthPanelOffsetX, OsseinAssist.healthPanelOffsetY)
end

function OsseinAssist.PrepareHealthPanelForConsole()
    OsseinAssist.ApplyHealthPanelAnchor()
    OsseinAssist.ApplyHealthPanelTextSize()
    OsseinAssistHealthPanel:SetDrawLayer(DL_OVERLAY)
    OsseinAssistHealthPanel:SetDrawTier(DT_HIGH)
    OsseinAssistHealthPanel:SetDrawLevel(40)
    OsseinAssistHealthPanel:SetMouseEnabled(false)
    OsseinAssistHealthPanel:SetHidden(true)
end

function OsseinAssist.ApplyHealthPanelTextSize()
    local size = zo_clamp(math.floor(tonumber(OsseinAssist.healthPanelTextSize) or 24), 20, 60)
    local fontSpec = string.format("ZoFontGamepadBold|%d|soft-shadow-thick", size)
    local rowHeight = size + 8

    OsseinAssistHealthPanelBosses:SetFont(fontSpec)
    OsseinAssistHealthPanelTitans:SetFont(fontSpec)
    OsseinAssistHealthPanelAssignment:SetFont(fontSpec)

    OsseinAssistHealthPanelBosses:SetHeight(rowHeight)
    OsseinAssistHealthPanelTitans:SetHeight(rowHeight)
    OsseinAssistHealthPanelAssignment:SetHeight(rowHeight)
    OsseinAssistHealthPanel:SetHeight(math.max(160, 36 + (rowHeight * 3)))
end

function OsseinAssist.SetHealthPanelPositionPreviewActive(enabled)
    OsseinAssist.healthPanelPositionPreviewActive = enabled
end

function OsseinAssist.SetHealthPanelSearingPreviewActive(enabled)
    OsseinAssist.healthPanelSearingPreviewActive = enabled
end

function OsseinAssist.StartHealthPanelPositionPreview(includeSearing)
    OsseinAssist.SetHealthPanelPositionPreviewActive(true)
    OsseinAssist.SetHealthPanelSearingPreviewActive(includeSearing and true or false)

    EVENT_MANAGER:UnregisterForUpdate(OsseinAssist.name .. "HealthPanelSettingsPreviewMonitor")
    EVENT_MANAGER:RegisterForUpdate(OsseinAssist.name .. "HealthPanelSettingsPreviewMonitor", 100, function()
        if not OsseinAssist.healthPanelPositionPreviewActive then
            EVENT_MANAGER:UnregisterForUpdate(OsseinAssist.name .. "HealthPanelSettingsPreviewMonitor")
            return
        end
        if not IsConsoleUI() then
            return
        end
        if type(OsseinAssist.IsLibHarvensSettingsSceneShowing) == "function"
            and not OsseinAssist.IsLibHarvensSettingsSceneShowing() then
            OsseinAssist.StopHealthPanelPositionPreview()
            return
        end
        if LibHarvensAddonSettings == nil or LibHarvensAddonSettings.list == nil then
            OsseinAssist.StopHealthPanelPositionPreview()
            return
        end
        local selectedData = LibHarvensAddonSettings.list:GetSelectedData()
        local tooltipFn = selectedData and selectedData.tooltipText or nil
        local isHealthTooltip = type(tooltipFn) == "function"
            and OsseinAssist.healthTooltipFunctionLookup ~= nil
            and OsseinAssist.healthTooltipFunctionLookup[tooltipFn] == true
        if not isHealthTooltip then
            OsseinAssist.StopHealthPanelPositionPreview()
        end
    end)
end

function OsseinAssist.StopHealthPanelPositionPreview()
    OsseinAssist.SetHealthPanelPositionPreviewActive(false)
    OsseinAssist.SetHealthPanelSearingPreviewActive(false)
    EVENT_MANAGER:UnregisterForUpdate(OsseinAssist.name .. "HealthPanelSettingsPreviewMonitor")
    if not OsseinAssist.healthPanelEnabled then
        OsseinAssistHealthPanel:SetHidden(true)
    end
end

function OsseinAssist.PokeHealthPanelPositionPreview(includeSearing)
    if not OsseinAssist.healthPanelPositionPreviewActive then
        OsseinAssist.StartHealthPanelPositionPreview(includeSearing)
        return
    end
    if includeSearing then
        OsseinAssist.SetHealthPanelSearingPreviewActive(true)
    end
end

function OsseinAssist.ApplyHealthPanelLayout(showTitle, showBosses, showDragons, showAssignment)
    local previousControl = nil

    local function place(control, visible, offsetY)
        control:SetHidden(not visible)
        if not visible then
            return
        end
        control:ClearAnchors()
        if previousControl == nil then
            control:SetAnchor(TOPLEFT, OsseinAssistHealthPanel, TOPLEFT, 0, 0)
        else
            control:SetAnchor(TOPLEFT, previousControl, BOTTOMLEFT, 0, offsetY)
        end
        previousControl = control
    end

    place(OsseinAssistHealthPanelTitle, showTitle, 0)
    place(OsseinAssistHealthPanelBosses, showBosses, 4)
    place(OsseinAssistHealthPanelTitans, showDragons, 4)
    place(OsseinAssistHealthPanelAssignment, showAssignment, 2)
end

function OsseinAssist.FormatHealthPercent(percent)
    if percent == nil then
        return "--.-%"
    end

    return string.format("%.1f%%", percent)
end

function OsseinAssist.GetNamedUnitHealthPercent(expectedName)
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
            local healthPercent = OsseinAssist.GetUnitTagHealthPercent(unitTag)
            if healthPercent ~= nil then
                return healthPercent
            end
        end
    end

    return nil
end

-- Cache of unitId -> unitTag, populated via EVENT_EFFECT_CHANGED which provides both.
OsseinAssist.titanUnitTagCache = {}

function OsseinAssist.OnTitanEffectChanged(_, _, _, _, unitTag, _, _, _, _, _, _, _, _, _, unitId)
    local numericUnitId = tonumber(unitId)
    if numericUnitId == OsseinAssist.blazeforgedValneerUnitId
        or numericUnitId == OsseinAssist.sparkstormMyrinaxUnitId then
        if unitTag ~= nil and unitTag ~= "" then
            OsseinAssist.titanUnitTagCache[numericUnitId] = unitTag
        end
    end
end

function OsseinAssist.StartTitanUnitTagDiscovery()
    local namespace = OsseinAssist.name .. "TitanTagDiscovery"
    EVENT_MANAGER:UnregisterForEvent(namespace, EVENT_EFFECT_CHANGED)
    EVENT_MANAGER:RegisterForEvent(namespace, EVENT_EFFECT_CHANGED, OsseinAssist.OnTitanEffectChanged)
end

function OsseinAssist.GetTitanHealthPercentByUnitId(unitId)
    local unitTag = OsseinAssist.titanUnitTagCache[tonumber(unitId)]
    if unitTag == nil or unitTag == "" then
        return nil
    end
    return OsseinAssist.GetUnitTagHealthPercent(unitTag)
end

function OsseinAssist.GetUnitTagHealthPercent(unitTag)
    local nowMs = GetFrameTimeMilliseconds()
    OsseinAssist.lastUnitTagHealthDebugMsByTag = OsseinAssist.lastUnitTagHealthDebugMsByTag or {}
    local lastLogMs = OsseinAssist.lastUnitTagHealthDebugMsByTag[unitTag] or 0
    local shouldLog = (nowMs - lastLogMs) >= 1500
    if shouldLog then
        OsseinAssist.lastUnitTagHealthDebugMsByTag[unitTag] = nowMs
    end

    if unitTag == nil or unitTag == "" then
        if shouldLog then
            OsseinAssist.LogBossHealthMessage("Ossein Assist: [UnitTagHP] invalid unitTag")
        end
        return nil
    end
    if type(DoesUnitExist) == "function" and not DoesUnitExist(unitTag) then
        if shouldLog then
            OsseinAssist.LogBossHealthMessage(string.format("Ossein Assist: [UnitTagHP] %s does not exist", tostring(unitTag)))
        end
        return nil
    end

    local healthPowerType = COMBAT_MECHANIC_FLAGS_HEALTH
    if healthPowerType == nil then
        if shouldLog then
            OsseinAssist.LogBossHealthMessage(string.format("Ossein Assist: [UnitTagHP] %s COMBAT_MECHANIC_FLAGS_HEALTH is nil", tostring(unitTag)))
        end
        return nil
    end
    local currentHealth, maxHealth = GetUnitPower(unitTag, healthPowerType)
    if maxHealth == nil or maxHealth <= 0 then
        if shouldLog then
            OsseinAssist.LogBossHealthMessage(string.format(
                "Ossein Assist: [UnitTagHP] %s GetUnitPower(%s) -> %s/%s (invalid max)",
                tostring(unitTag),
                tostring(healthPowerType),
                tostring(currentHealth),
                tostring(maxHealth)
            ))
        end
        return nil
    end
    local percent = (currentHealth / maxHealth) * 100
    if shouldLog then
        OsseinAssist.LogBossHealthMessage(string.format(
            "Ossein Assist: [UnitTagHP] %s GetUnitPower(%s) -> %s/%s => %.1f%%",
            tostring(unitTag),
            tostring(healthPowerType),
            tostring(currentHealth),
            tostring(maxHealth),
            percent
        ))
    end
    return percent
end

function OsseinAssist.GetEncounterBossHealthByUnitTags()
    local healthByEncounterName = {
        jynorah = nil,
        skorkhif = nil,
        valneer = nil,
        myrinax = nil,
    }
    local nowMs = GetFrameTimeMilliseconds()
    local shouldLogScan = OsseinAssist.lastBossHealthScanDebugMs == nil
        or (nowMs - OsseinAssist.lastBossHealthScanDebugMs) >= 2000
    if shouldLogScan then
        OsseinAssist.lastBossHealthScanDebugMs = nowMs
        OsseinAssist.LogBossHealthMessage("Ossein Assist: [HealthScan] scanning boss1..boss6")
    end

    for index = 1, 6 do
        local unitTag = "boss" .. tostring(index)
        local unitExists = true
        if type(DoesUnitExist) == "function" then
            unitExists = DoesUnitExist(unitTag)
        end
        if not unitExists then
            if shouldLogScan then
                OsseinAssist.LogBossHealthMessage(string.format("Ossein Assist: [HealthScan] %s does not exist", unitTag))
            end
        else
            local bossName = GetUnitName(unitTag)
            if bossName ~= nil and bossName ~= "" then
                local healthPercent = OsseinAssist.GetUnitTagHealthPercent(unitTag)
                if shouldLogScan then
                    OsseinAssist.LogBossHealthMessage(string.format(
                        "Ossein Assist: [HealthScan] %s name=%s hp=%s",
                        unitTag,
                        tostring(bossName),
                        healthPercent ~= nil and string.format("%.1f%%", healthPercent) or "nil"
                    ))
                end
                if healthPercent ~= nil then
                    if OsseinAssist.IsSourceNameMatch(bossName, OsseinAssist.jynorahName) then
                        healthByEncounterName.jynorah = healthPercent
                        if shouldLogScan then
                            OsseinAssist.LogBossHealthMessage(string.format("Ossein Assist: [HealthScan] matched %s -> Jynorah", unitTag))
                        end
                    elseif OsseinAssist.IsSourceNameMatch(bossName, OsseinAssist.skorkifName) then
                        healthByEncounterName.skorkhif = healthPercent
                        if shouldLogScan then
                            OsseinAssist.LogBossHealthMessage(string.format("Ossein Assist: [HealthScan] matched %s -> Skorkhif", unitTag))
                        end
                    end
                end
            end
        end
    end

    if shouldLogScan then
        OsseinAssist.LogBossHealthMessage(string.format(
            "Ossein Assist: [HealthScan] resolved j=%.1f s=%.1f v=%.1f m=%.1f",
            tonumber(healthByEncounterName.jynorah) or -1,
            tonumber(healthByEncounterName.skorkhif) or -1,
            tonumber(healthByEncounterName.valneer) or -1,
            tonumber(healthByEncounterName.myrinax) or -1
        ))
    end

    return healthByEncounterName
end

function OsseinAssist.GetSearingAssignmentPanelText(useFakeData)
    if not OsseinAssist.showSearingAssignmentOnPanel and not OsseinAssist.healthPanelSearingPreviewActive then
        return ""
    end

    local color = OsseinAssist.searingCurrentColor
    local number = OsseinAssist.searingCurrentNumber
    local fireCount = OsseinAssist.searingMechanicCount or 0
    if useFakeData then
        local baseColor, baseNumber = OsseinAssist.GetSearingAssignmentParts(OsseinAssist.searingAssignment)
        local fakeFireCount = 3
        color = baseColor
        if color ~= nil then
            local flips = fakeFireCount
            if not OsseinAssist.includeFirstSearingCurse then
                flips = math.max(fakeFireCount - 1, 0)
            end
            for _ = 1, flips do
                color = OsseinAssist.GetOppositeSearingColor(color)
            end
        end
        number = baseNumber
        fireCount = fakeFireCount
    end
    if color == nil or number == nil then
        return string.format("|cE8D9A8Searing:|r |cAAAAAANot Assigned|r")
    end

    local targetBossName = nil
    local targetBossColorHex = "FFFFFF"
    if color == "Blue" then
        targetBossName = OsseinAssist.skorkifName
        targetBossColorHex = OsseinAssist.redColorHex
    elseif color == "Red" then
        targetBossName = OsseinAssist.jynorahName
        targetBossColorHex = OsseinAssist.blueColorHex
    end

    local colorHex = color == "Blue" and OsseinAssist.blueColorHex or OsseinAssist.redColorHex
    return string.format(
        "|cE8D9A8Searing:|r |c%s%s %d|r |cE8D9A8->|r |c%s%s|r |cE8D9A8(Fires: %d)|r",
        colorHex,
        color,
        number,
        targetBossColorHex,
        tostring(targetBossName or "Unknown"),
        fireCount
    )
end

function OsseinAssist.LogReticleHealthDebugTick()
    local unitTag = "reticleover"
    local unitName = GetUnitName(unitTag)
    if unitName == nil or unitName == "" then
        return
    end

    local exists = type(DoesUnitExist) ~= "function" or DoesUnitExist(unitTag)
    if not exists then
        return
    end

    local hpTypeA = COMBAT_MECHANIC_FLAGS_HEALTH
    if hpTypeA == nil then
        return
    end
    local curA, maxA = GetUnitPower(unitTag, hpTypeA)
    local pct = OsseinAssist.GetUnitTagHealthPercent(unitTag)
    local pctText = pct ~= nil and string.format("%.1f%%", pct) or "nil"

    local nowMs = GetFrameTimeMilliseconds()
    local lastName = OsseinAssist.lastReticleHealthDebugName
    local lastPct = OsseinAssist.lastReticleHealthDebugPercent
    local lastMs = OsseinAssist.lastReticleHealthDebugMs or 0
    local nameChanged = lastName ~= unitName
    local pctChanged = (pct == nil and lastPct ~= nil)
        or (pct ~= nil and (lastPct == nil or math.abs(pct - lastPct) >= 0.5))
    local timeElapsed = (nowMs - lastMs) >= 2000

    if nameChanged or pctChanged or timeElapsed then
        OsseinAssist.LogBossHealthMessage(string.format(
            "Ossein Assist: [Reticle HP] name=%s A(%s)=%s/%s pct=%s",
            tostring(unitName),
            tostring(hpTypeA),
            tostring(curA),
            tostring(maxA),
            pctText
        ))
        OsseinAssist.lastReticleHealthDebugName = unitName
        OsseinAssist.lastReticleHealthDebugPercent = pct
        OsseinAssist.lastReticleHealthDebugMs = nowMs
    end
end

function OsseinAssist.LogEncounterBossHealthDebug(jynorahHealthPercent, skorkhifHealthPercent)
    local nowMs = GetFrameTimeMilliseconds()
    local lastMs = OsseinAssist.lastEncounterBossHealthDebugMs or 0
    local lastJ = OsseinAssist.lastEncounterBossHealthDebugJ
    local lastS = OsseinAssist.lastEncounterBossHealthDebugS

    local jChanged = (jynorahHealthPercent == nil and lastJ ~= nil)
        or (jynorahHealthPercent ~= nil and (lastJ == nil or math.abs(jynorahHealthPercent - lastJ) >= 0.5))
    local sChanged = (skorkhifHealthPercent == nil and lastS ~= nil)
        or (skorkhifHealthPercent ~= nil and (lastS == nil or math.abs(skorkhifHealthPercent - lastS) >= 0.5))
    local timed = (nowMs - lastMs) >= 2000
    if not jChanged and not sChanged and not timed then
        return
    end

    OsseinAssist.LogBossHealthMessage(string.format(
        "Ossein Assist: [Boss HP] Jynorah=%s Skorkhif=%s",
        jynorahHealthPercent ~= nil and string.format("%.1f%%", jynorahHealthPercent) or "nil",
        skorkhifHealthPercent ~= nil and string.format("%.1f%%", skorkhifHealthPercent) or "nil"
    ))

    OsseinAssist.lastEncounterBossHealthDebugMs = nowMs
    OsseinAssist.lastEncounterBossHealthDebugJ = jynorahHealthPercent
    OsseinAssist.lastEncounterBossHealthDebugS = skorkhifHealthPercent
end

function OsseinAssist.LogEncounterTitanHealthDebug(valneerHealthPercent, myrinaxHealthPercent)
    local nowMs = GetFrameTimeMilliseconds()
    local lastMs = OsseinAssist.lastEncounterTitanHealthDebugMs or 0
    local lastV = OsseinAssist.lastEncounterTitanHealthDebugV
    local lastM = OsseinAssist.lastEncounterTitanHealthDebugM

    local vChanged = (valneerHealthPercent == nil and lastV ~= nil)
        or (valneerHealthPercent ~= nil and (lastV == nil or math.abs(valneerHealthPercent - lastV) >= 0.5))
    local mChanged = (myrinaxHealthPercent == nil and lastM ~= nil)
        or (myrinaxHealthPercent ~= nil and (lastM == nil or math.abs(myrinaxHealthPercent - lastM) >= 0.5))
    local timed = (nowMs - lastMs) >= 2000
    if not vChanged and not mChanged and not timed then
        return
    end

    OsseinAssist.LogTitanHealthMessage(string.format(
        "Ossein Assist: [Titan HP] Valneer=%s Myrinax=%s",
        valneerHealthPercent ~= nil and string.format("%.1f%%", valneerHealthPercent) or "nil",
        myrinaxHealthPercent ~= nil and string.format("%.1f%%", myrinaxHealthPercent) or "nil"
    ))

    OsseinAssist.lastEncounterTitanHealthDebugMs = nowMs
    OsseinAssist.lastEncounterTitanHealthDebugV = valneerHealthPercent
    OsseinAssist.lastEncounterTitanHealthDebugM = myrinaxHealthPercent
end

function OsseinAssist.UpdateBossAndTitanHealthPanel()
    if not OsseinAssist.healthPanelEnabled and not OsseinAssist.healthPanelPositionPreviewActive then
        OsseinAssistHealthPanel:SetHidden(true)
        return
    end

    if OsseinAssist.healthPanelPositionPreviewActive then
        local fake = OsseinAssist.fakeHealthPercents
        local bossesText = string.format(
            "|cE8D9A8Jynorah / Skorkhif:|r  |c%s%s|r / |c%s%s|r",
            OsseinAssist.blueColorHex,
            OsseinAssist.FormatHealthPercent(fake.jynorah),
            OsseinAssist.redColorHex,
            OsseinAssist.FormatHealthPercent(fake.skorkif or fake.skorkhif)
        )
        local titansText = string.format(
            "|cE8D9A8Titans:|r  |c%s%s|r / |c%s%s|r",
            OsseinAssist.redColorHex,
            OsseinAssist.FormatHealthPercent(fake.valneer),
            OsseinAssist.blueColorHex,
            OsseinAssist.FormatHealthPercent(fake.myrinax)
        )
        local assignmentText = OsseinAssist.GetSearingAssignmentPanelText(true)
        OsseinAssistHealthPanelBosses:SetText(bossesText)
        OsseinAssistHealthPanelTitans:SetText(titansText)
        OsseinAssistHealthPanelAssignment:SetText(assignmentText)
        OsseinAssist.ApplyHealthPanelLayout(
            OsseinAssist.healthPanelShowTitle,
            OsseinAssist.healthPanelShowBossHealth,
            OsseinAssist.healthPanelShowDragonHealth,
            assignmentText ~= ""
        )
        OsseinAssistHealthPanel:SetHidden(false)
        return
    end

    local isTrialFight = OsseinAssist.IsInOsseinCage() and OsseinAssist.IsJynorahAndSkorkhifFight()
    if not isTrialFight then
        OsseinAssistHealthPanel:SetHidden(true)
        return
    end

    local encounterBossHealth = OsseinAssist.GetEncounterBossHealthByUnitTags()
    local jynorahHealthPercent = encounterBossHealth.jynorah
    local skorkhifHealthPercent = encounterBossHealth.skorkhif
    local valneerHealthPercent = encounterBossHealth.valneer
    local myrinaxHealthPercent = encounterBossHealth.myrinax

    if jynorahHealthPercent == nil then
        jynorahHealthPercent = OsseinAssist.GetNamedUnitHealthPercent(OsseinAssist.jynorahName)
    end
    if skorkhifHealthPercent == nil then
        skorkhifHealthPercent = OsseinAssist.GetNamedUnitHealthPercent(OsseinAssist.skorkifName)
    end
    if valneerHealthPercent == nil then
        valneerHealthPercent = OsseinAssist.GetTitanHealthPercentByUnitId(OsseinAssist.blazeforgedValneerUnitId)
    end
    if myrinaxHealthPercent == nil then
        myrinaxHealthPercent = OsseinAssist.GetTitanHealthPercentByUnitId(OsseinAssist.sparkstormMyrinaxUnitId)
    end
    OsseinAssist.LogEncounterBossHealthDebug(jynorahHealthPercent, skorkhifHealthPercent)
    OsseinAssist.LogEncounterTitanHealthDebug(valneerHealthPercent, myrinaxHealthPercent)

    local bossesText = string.format(
        "|cE8D9A8Bosses:|r  |c%s%s|r / |c%s%s|r",
        OsseinAssist.blueColorHex,
        OsseinAssist.FormatHealthPercent(jynorahHealthPercent),
        OsseinAssist.redColorHex,
        OsseinAssist.FormatHealthPercent(skorkhifHealthPercent)
    )
    local titansText = string.format(
        "|cE8D9A8Titans:|r  |c%s%s|r / |c%s%s|r",
        OsseinAssist.redColorHex,
        OsseinAssist.FormatHealthPercent(valneerHealthPercent),
        OsseinAssist.blueColorHex,
        OsseinAssist.FormatHealthPercent(myrinaxHealthPercent)
    )

    OsseinAssistHealthPanelBosses:SetText(bossesText)
    OsseinAssistHealthPanelTitans:SetText(titansText)
    local assignmentText = OsseinAssist.GetSearingAssignmentPanelText(false)
    OsseinAssistHealthPanelAssignment:SetText(assignmentText)
    OsseinAssist.ApplyHealthPanelLayout(
        OsseinAssist.healthPanelShowTitle,
        OsseinAssist.healthPanelShowBossHealth,
        OsseinAssist.healthPanelShowDragonHealth,
        assignmentText ~= ""
    )
    OsseinAssistHealthPanel:SetHidden(false)
end

function OsseinAssist.StartHealthPanelTracking()
    EVENT_MANAGER:RegisterForUpdate(OsseinAssist.name .. "HealthPanelUpdate", OsseinAssist.healthTrackerUpdateIntervalMs, OsseinAssist.UpdateBossAndTitanHealthPanel)
    EVENT_MANAGER:RegisterForUpdate(OsseinAssist.name .. "ReticleHealthDebug", 250, OsseinAssist.LogReticleHealthDebugTick)
end

function OsseinAssist.SetHealthPanelEnabled(enabled)
    OsseinAssist.healthPanelEnabled = enabled
    if OsseinAssist.savedVariables ~= nil then
        OsseinAssist.savedVariables.healthPanelEnabled = enabled
    end
    if not enabled then
        OsseinAssistHealthPanel:SetHidden(true)
    end
    d(string.format("Ossein Assist: health panel %s.", enabled and "enabled" or "disabled"))
end

function OsseinAssist.SetHealthPanelShowTitleEnabled(enabled)
    OsseinAssist.healthPanelShowTitle = enabled and true or false
    if OsseinAssist.savedVariables ~= nil then
        OsseinAssist.savedVariables.healthPanelShowTitle = OsseinAssist.healthPanelShowTitle
    end
end

function OsseinAssist.SetHealthPanelShowBossHealthEnabled(enabled)
    OsseinAssist.healthPanelShowBossHealth = enabled and true or false
    if OsseinAssist.savedVariables ~= nil then
        OsseinAssist.savedVariables.healthPanelShowBossHealth = OsseinAssist.healthPanelShowBossHealth
    end
end

function OsseinAssist.SetHealthPanelShowDragonHealthEnabled(enabled)
    OsseinAssist.healthPanelShowDragonHealth = enabled and true or false
    if OsseinAssist.savedVariables ~= nil then
        OsseinAssist.savedVariables.healthPanelShowDragonHealth = OsseinAssist.healthPanelShowDragonHealth
    end
end

function OsseinAssist.SetHealthPanelFakeModeEnabled(enabled)
    OsseinAssist.healthPanelFakeModeEnabled = enabled
    if OsseinAssist.savedVariables ~= nil then
        OsseinAssist.savedVariables.healthPanelFakeModeEnabled = enabled
    end
    d(string.format("Ossein Assist: health panel fake mode %s.", enabled and "enabled" or "disabled"))
end

function OsseinAssist.SetHealthPanelOffsetX(value)
    local offsetX = math.floor(tonumber(value) or 0)
    OsseinAssist.healthPanelOffsetX = offsetX
    if OsseinAssist.savedVariables ~= nil then
        OsseinAssist.savedVariables.healthPanelOffsetX = offsetX
    end
    OsseinAssist.ApplyHealthPanelAnchor()
end

function OsseinAssist.SetHealthPanelOffsetY(value)
    local offsetY = math.floor(tonumber(value) or 0)
    OsseinAssist.healthPanelOffsetY = offsetY
    if OsseinAssist.savedVariables ~= nil then
        OsseinAssist.savedVariables.healthPanelOffsetY = offsetY
    end
    OsseinAssist.ApplyHealthPanelAnchor()
end

function OsseinAssist.SetHealthPanelTextSize(value)
    local textSize = zo_clamp(math.floor(tonumber(value) or 24), 20, 60)
    OsseinAssist.healthPanelTextSize = textSize
    if OsseinAssist.savedVariables ~= nil then
        OsseinAssist.savedVariables.healthPanelTextSize = textSize
    end
    OsseinAssist.ApplyHealthPanelTextSize()
end
