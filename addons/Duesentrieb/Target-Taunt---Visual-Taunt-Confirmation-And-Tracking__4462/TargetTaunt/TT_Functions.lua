local TT = TargetTaunt

---------------------------------------------------------------------------
-- CENTRAL DATA MANAGEMENT
---------------------------------------------------------------------------
function TT.GetOrCreateTargetData(unitId)
    if not TT.targetData[unitId] then
        TT.targetData[unitId] = {
            unitId = unitId,
            name = "",
            endTime = 0,
            tauntState = TT.TAUNT_STATE_NONE,
            isBoss = false,
            isImportant = false,
            isActive = false,
            isDead = false,
            expireTime = 0,
            expireTimeHighlight = 0,
        }
    end
    return TT.targetData[unitId]
end

---------------------------------------------------------------------------
-- WATCHDOG: CLEAN UP EXPIRED TARGETS
---------------------------------------------------------------------------
function TT.RunTrackerWatchdog()
    if TT.activeTargetCount == 0 then return end
    local currentTime = GetFrameTimeSeconds()
    local requiresUpdate = false

    for i = TT.activeTargetCount, 1, -1 do
        local unitId = TT.targetList[i]
        local targetData = TT.targetData[unitId]

        if targetData then
            -- FAILSAFE (OH HELL PLEASE WORK)
            if targetData.tauntState ~= TT.TAUNT_STATE_NONE and targetData.endTime > 0 and currentTime >= targetData.endTime then
                targetData.tauntState = TT.TAUNT_STATE_NONE
                targetData.endTime = 0
                targetData.expireTime = currentTime + (targetData.isImportant and TT.SV.expireTimeImportant or TT.SV.expireTimeHarmless)

                if targetData.isImportant then
                    targetData.expireTimeHighlight = currentTime + TT.SV.expireTimeHighlight
                end

                requiresUpdate = true
            end

            -- ORIGINAL
            if targetData.tauntState == TT.TAUNT_STATE_NONE and targetData.expireTime > 0 then
                if currentTime > targetData.expireTime then
                    TT.RemoveCentralTarget(unitId)
                    requiresUpdate = true
                end
            end
        end
    end

    if requiresUpdate and not TT.isTrackerUnlocked then
        TT.RenderTrackerDisplay()
        TT.ManageTrackerLoop()
    end
end

---------------------------------------------------------------------------
-- UPDATE OR ADD TARGET
---------------------------------------------------------------------------
function TT.UpdateCentralTarget(unitId, name, endTime, tauntState, isBoss, isImportant, expireTime)
    local targetData = TT.GetOrCreateTargetData(unitId)

    -- ZOMBIE PREVENTION
    if targetData.isDead and tauntState == TT.TAUNT_STATE_NONE then return end

    -- DUPLICATE CLEANUP & ORDER
    if name and not string.match(tostring(unitId), "^SCAN_") then
        local pseudoId = "SCAN_" .. name
        if TT.targetData[pseudoId] and TT.targetData[pseudoId].isActive then

            -- POSI OF SCANNED TARGET SO SHIT DONT JUMP
            for i = 1, TT.activeTargetCount do
                if TT.targetList[i] == pseudoId then
                    -- REPLACE SCAN_ WITH REAL
                    TT.targetList[i] = unitId
                    targetData.isActive = true -- KEEP ACTIVE
                    break
                end
            end

            -- DELETE OLD
            TT.targetData[pseudoId] = nil
        end
    end

    if tauntState ~= TT.TAUNT_STATE_NONE then
        targetData.isDead = false
    end

    targetData.name = name or targetData.name
    targetData.endTime = endTime or targetData.endTime
    targetData.tauntState = tauntState or targetData.tauntState

    if isBoss ~= nil then targetData.isBoss = isBoss end
    if isImportant ~= nil then targetData.isImportant = isImportant end

    targetData.expireTime = expireTime or targetData.expireTime or 0

    if not targetData.isActive then
        targetData.isActive = true
        TT.activeTargetCount = TT.activeTargetCount + 1
        TT.targetList[TT.activeTargetCount] = unitId
    end
end

---------------------------------------------------------------------------
-- REMOVE TARGET FROM TRACKER LIST
---------------------------------------------------------------------------
function TT.RemoveCentralTarget(unitId)
    local targetData = TT.targetData[unitId]
    if not targetData or not targetData.isActive then return end

    for i = 1, TT.activeTargetCount do
        if TT.targetList[i] == unitId then
            -- table.remove
            table.remove(TT.targetList, i)
            TT.activeTargetCount = TT.activeTargetCount - 1
            break
        end
    end

    TT.targetData[unitId] = nil
end

---------------------------------------------------------------------------
-- FIND TARGET INDEX IN TRACKER LIST (FOR ANIMATIONS)
---------------------------------------------------------------------------
function TT.GetTrackerIndex(unitId)
    for i = 1, TT.activeTargetCount do
        if TT.targetList[i] == unitId then return i end
    end
    return nil
end

---------------------------------------------------------------------------
-- CHECK IF TARGET IS A BOSS
---------------------------------------------------------------------------
function TT.CheckIfBoss(unitTag, targetName)
    if unitTag and unitTag ~= "" then
        for i = 1, #TT.BOSS_TAGS do
            if AreUnitsEqual(unitTag, TT.BOSS_TAGS[i]) then return true, TT.BOSS_TAGS[i] end
        end
    end
    if targetName and targetName ~= "" then
        local cleanName = TT.GetCleanName(targetName)
        for i = 1, #TT.BOSS_TAGS do
            local bossTag = TT.BOSS_TAGS[i]
            if DoesUnitExist(bossTag) and cleanName == TT.GetCleanName(GetUnitName(bossTag)) then
                return true, bossTag
            end
        end
    end
    return false, nil
end

---------------------------------------------------------------------------
-- TRACKER UPDATE LOOP MANAGEMENT
---------------------------------------------------------------------------
function TT.ManageTrackerLoop()
    if TT.isTrackerUnlocked then return end

    if TT.activeTargetCount > 0 then
        EVENT_MANAGER:RegisterForUpdate(TT.NAME .. "_RENDER_TRACKER_DISPLAY", 200, TT.RenderTrackerDisplay)
    else
        EVENT_MANAGER:UnregisterForUpdate(TT.NAME .. "_RENDER_TRACKER_DISPLAY")
        TT.ResizeTracker(0)
    end
end

---------------------------------------------------------------------------
-- CLEAR TRACKER (OUT OF COMBAT / WIPE / ZONE CHANGE)
---------------------------------------------------------------------------
function TT.ClearTracker()

    TT.targetData = {}
    TT.targetList = {}
    TT.activeTargetCount = 0

    TT.difficultyCache = {}
    TT.healthCache = {}

    TT.RenderTrackerDisplay()
    TT.ManageTrackerLoop()
end

---------------------------------------------------------------------------
-- FORCE DELETE TARGET (WHEN IT DIES)
---------------------------------------------------------------------------
function TT.DeleteTrackerTarget(unitId)
    if TT.targetData[unitId] then
        TT.targetData[unitId].isDead = true
    end

    TT.RemoveCentralTarget(unitId)

    TT.RenderTrackerDisplay()
    TT.ManageTrackerLoop()
end

---------------------------------------------------------------------------
-- HANDLE UNIT DEATH
---------------------------------------------------------------------------
function TT.OnUnitDeath(_, result, _, _, _, _, _, _, _, _, _, _, _, _, _, targetUnitId, _)
    if result == ACTION_RESULT_DIED or result == ACTION_RESULT_DIED_XP then
        TT.DeleteTrackerTarget(targetUnitId)
    end
end

---------------------------------------------------------------------------
-- HANDLE COMBAT STATE
---------------------------------------------------------------------------
function TT.OnCombatStateChanged(eventCode, inCombat)
    TT.isCombat = inCombat
    if not inCombat then
        TT.ClearTracker()
    end
end

---------------------------------------------------------------------------
-- TEST: CENTER SCREEN ANNOUNCE
---------------------------------------------------------------------------
function TT.TriggerCenterScreenAnnounce(value)
    if not value or value == "" then value = "CENTER_SCREEN_ANNOUNCE" end
    local params = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, SOUNDS.CHAMPION_POINTS_COMMITTED)
    params:SetText(tostring(value))
    CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(params)
end

---------------------------------------------------------------------------
-- GET ACTIVE UI MODE BASED ON ROLE
---------------------------------------------------------------------------
function TT.GetActiveUIMode()
    if not TT.SV.isEnabledAddon then return TT.UI_MODE_OFF end

    local isGrouped = IsUnitGrouped("player")
    if not isGrouped then
        return TT.SV.modeSolo
    else
        local role = GetGroupMemberSelectedRole("player")
        if role == LFG_ROLE_TANK then return TT.SV.modeTank
        elseif role == LFG_ROLE_HEAL then return TT.SV.modeHeal
        elseif role == LFG_ROLE_DPS then return TT.SV.modeDPS
        end
    end
    return TT.UI_MODE_BOTH -- FALLBACK
end

---------------------------------------------------------------------------
-- CHECK IF SPECIFIC UI ELEMENTS ARE ENABLED
---------------------------------------------------------------------------
function TT.IsReticleEnabled()
    if not TT.SV.isEnabledAddon then return false end
    local mode = TT.GetActiveUIMode()
    return mode == TT.UI_MODE_BOTH or mode == TT.UI_MODE_RETICLE
end

function TT.IsTrackerEnabled()
    if not TT.SV.isEnabledAddon then return false end
    local mode = TT.GetActiveUIMode()
    return mode == TT.UI_MODE_BOTH or mode == TT.UI_MODE_TRACKER
end

---------------------------------------------------------------------------
-- CHECK IF ADDON SHOULD BE VISIBLE BASED ON ROLES
---------------------------------------------------------------------------
function TT.CheckVisibility()
    if not TT.SV.isEnabledAddon then return false end
    if TT.isReticleUnlocked then return true end

    return TT.GetActiveUIMode() ~= TT.UI_MODE_OFF
end

---------------------------------------------------------------------------
-- HIDE UI AND UNREGISTER UPDATE LOOP
---------------------------------------------------------------------------
function TT.HideAndStopUpdate()
    EVENT_MANAGER:UnregisterForUpdate(TT.NAME .. "_UPDATE_TAUNT_STATUS")

    -- REMOVE HIGHLIGHT
    if TT.currentReticleName ~= "" then
        TT.currentReticleName = ""
        TT.currentReticleEndTime = 0 -- TEST
        if TT.activeTargetCount > 0 then TT.RenderTrackerDisplay() end
    end

    -- ABORT IF ANIMATION IS LOCKED AND ACTIVE
    if TT.isAnimationActive then return end

    if not TT.isReticleUnlocked and not TT.RETICLE:IsHidden() then
        TT.RETICLE:SetHidden(true)
    end
end

---------------------------------------------------------------------------
-- CLEAN RAW NAME
---------------------------------------------------------------------------
function TT.GetCleanName(rawName)
    if not rawName or rawName == "" then return "" end

    return zo_strformat("<<C:1>>", rawName)

    -- -- ^Fx, ^Mx
    -- local cleanName = string.gsub(rawName, "%^.*", "")

    -- -- REMOVE PREFIXES
    -- for i = 1, #TT.PREFIXES do
    --     cleanName = string.gsub(cleanName, TT.PREFIXES[i], "")
    -- end

    -- -- FIRST CHAR ALWAYS UPPERCASE
    -- if cleanName ~= "" then
    --     cleanName = zo_strformat("<<C:1>>", cleanName)
    -- end

    -- return cleanName
end

---------------------------------------------------------------------------
-- FORMAT NAME FOR UI
---------------------------------------------------------------------------
function TT.GetFormattedName(cleanName, isBoss, maxLength)
    if not cleanName or cleanName == "" then return "" end

    local displayName = cleanName

    if maxLength and maxLength > 0 then
        if zo_strlen(displayName) > maxLength then
            displayName = zo_strsub(displayName, 1, maxLength):gsub("%s+$", "")
        end
    end

    if isBoss and TT.SV.isEnabledBossBrackets then
        -- local fontSize = TT.SV.trackerFontSize
        -- local iconBoss = string.format("|t%i:%i:/esoui/art/icons/mapkey/mapkey_groupboss.dds|t", fontSize, fontSize)
        displayName = "[" .. zo_strupper(displayName) .. "]"
    end

    return displayName
end

function TT.IsTargetImportant(difficulty, unitTag, targetName)
    -- BOSS CHECK
    local isBoss = TT.CheckIfBoss(unitTag, targetName)
    if isBoss then return true end

    -- MAX-HEALTH THRESHOLD CHECK
    if TT.SV.thresholdMaxHealth > 0 then
        local maxHealth = 0
        if unitTag and unitTag ~= "" and DoesUnitExist(unitTag) then
            _, maxHealth, _ = GetUnitPower(unitTag, POWERTYPE_HEALTH)
        else
            local cleanName = TT.GetCleanName(targetName)
            if TT.healthCache and TT.healthCache[cleanName] then
                maxHealth = TT.healthCache[cleanName]
            end
        end

        if maxHealth and maxHealth >= TT.SV.thresholdMaxHealth then
            return true
        end
    end

    -- MINIMUM DIFFICULTY FILTER (0 TO 5)
    if TT.SV.thresholdDifficulty == 5 then return false end

    if difficulty and difficulty >= TT.SV.thresholdDifficulty then
        return true
    end

    return false
end

---------------------------------------------------------------------------
-- EVALUATE RETICLE TARGET AND SCAN INTO TRACKER
---------------------------------------------------------------------------
function TT.UpdateReticleTarget()
    if TT.isWarningActive or TT.isReticleUnlocked or TT.isAnimationActive then return end

    if not TT.CheckVisibility() then
        TT.HideAndStopUpdate()
        return
    end

    if DoesUnitExist("reticleover") and IsUnitAttackable("reticleover") and not IsUnitDead("reticleover") then
        local rawName = GetUnitName("reticleover")
        local difficulty = GetUnitDifficulty("reticleover")
        local cleanName = TT.GetCleanName(rawName)

        if TT.currentReticleName ~= cleanName then
            TT.currentReticleName = cleanName
            if TT.activeTargetCount > 0 then TT.RenderTrackerDisplay() end
        end

        local _, maxHealth, _ = GetUnitPower("reticleover", POWERTYPE_HEALTH)

        TT.difficultyCache[cleanName] = difficulty
        if maxHealth then TT.healthCache[cleanName] = maxHealth end

        local isImportant = TT.IsTargetImportant(difficulty, "reticleover", rawName)

        local tauntState, timeRemaining, reticleEndTime = TT.GetReticleTauntState()
        TT.currentReticleEndTime = reticleEndTime or 0

        if not isImportant and TT.SV.isEnabledFlagHarmlessImportant then
            if tauntState ~= TT.TAUNT_STATE_NONE then
                isImportant = true
            end
        end

        local isValidForReticle = isImportant

        if not isImportant and not TT.SV.isEnabledIgnoreHarmless then
            if tauntState == TT.TAUNT_STATE_PLAYER then
                isValidForReticle = true
            end
        end

        if isValidForReticle then
            local isBoss = TT.CheckIfBoss("reticleover", rawName)
            local displayName = TT.GetFormattedName(cleanName, isBoss, TT.SV.reticleMaxLengthName)
            TT.RETICLE_NAME:SetText(displayName)
            TT.RenderReticleDisplay()

            if TT.IsReticleEnabled() and not TT.isHiddenByScene then
                TT.RETICLE:SetHidden(false)
                TT.RETICLE_NAME:SetHidden(not TT.SV.isEnabledReticleName)
                TT.RETICLE_TIME:SetHidden(not TT.SV.isEnabledTimer)
            end
            EVENT_MANAGER:RegisterForUpdate(TT.NAME .. "_UPDATE_TAUNT_STATUS", TT.UPDATE_INTERVAL, TT.RenderReticleDisplay)

            local foundMatch = false

            for i = 1, TT.activeTargetCount do
                local unitId = TT.targetList[i]
                local targetData = TT.targetData[unitId]

                if targetData and targetData.name == cleanName then

                    if tauntState == TT.TAUNT_STATE_NONE and targetData.tauntState ~= TT.TAUNT_STATE_NONE then
                        -- THIS IS A NOTHING TO DO CASE..
                    else
                        foundMatch = true
                        local changed = false

                        if not targetData.isImportant and isImportant then
                            targetData.isImportant = true
                            changed = true
                        end
                        if not targetData.isBoss and isBoss then
                            targetData.isBoss = true
                            changed = true
                        end

                        if tauntState == TT.TAUNT_STATE_NONE then
                            targetData.expireTime = GetFrameTimeSeconds() + TT.SV.expireTimeImportant
                        end

                        if changed then TT.RenderTrackerDisplay() end
                        break
                    end
                end
            end

            if not foundMatch then
                if TT.SV.isEnabledScanning then
                    local expireTime = GetFrameTimeSeconds() + TT.SV.expireTimeImportant
                    local pseudoId = "SCAN_" .. cleanName
                    local endTime = 0

                    -- CALC ENDTIME OF CURRENT TAUNT
                    if timeRemaining and timeRemaining > 0 then
                        endTime = GetFrameTimeSeconds() + timeRemaining
                    end

                    TT.UpdateCentralTarget(pseudoId, cleanName, endTime, tauntState, isBoss, isImportant, expireTime)
                    TT.RenderTrackerDisplay()
                    TT.ManageTrackerLoop()
                end
            end
            return
        end
    end
    TT.HideAndStopUpdate()
end

---------------------------------------------------------------------------
-- CALCULATE DYNAMIC COLOR (3-POINT TRANSITION)
---------------------------------------------------------------------------
function TT.GetTimerColor(percentage, color100, color50, color0)
    color100 = color100 or {0, 1, 0}
    color50 = color50 or {1, 1, 0}
    color0 = color0 or {1, 0, 0}

    local p = math.max(0, math.min(1, percentage))
    local r, g, b

    if p > 0.5 then
        -- 100 TO 50
        local localP = (p - 0.5) * 2
        r = color100[1] * localP + color50[1] * (1 - localP)
        g = color100[2] * localP + color50[2] * (1 - localP)
        b = color100[3] * localP + color50[3] * (1 - localP)
    else
        -- 50 TO 0
        local localP = p * 2
        r = color50[1] * localP + color0[1] * (1 - localP)
        g = color50[2] * localP + color0[2] * (1 - localP)
        b = color50[3] * localP + color0[3] * (1 - localP)
    end

    return r, g, b, 1
end

---------------------------------------------------------------------------
-- APPLY FACTOR 0 - 2.0
---------------------------------------------------------------------------
function TT.GetFactoredColor(r, g, b, f)
    if f < 1.0 then
        r = r * f
        g = g * f
        b = b * f
    elseif f > 1.0 then
        r = math.min(1, r + 1.0 * (f - 1.0))
        g = math.min(1, g + 1.0 * (f - 1.0))
        b = math.min(1, b + 1.0 * (f - 1.0))
    end

    return r, g, b
end

---------------------------------------------------------------------------
-- CALC DESATURATED COLORS FROM RGB
---------------------------------------------------------------------------
function TT.GetDesaturatedColor(r, g, b, a, saturation)
    local lightness = (math.max(r, g, b) + math.min(r, g, b)) / 2

    local outR = lightness + (r - lightness) * saturation
    local outG = lightness + (g - lightness) * saturation
    local outB = lightness + (b - lightness) * saturation

    return outR, outG, outB, a
end

function TT.GetDesaturatedColorHSV(r, g, b, a, saturation)
    local outR = 1.0 + (r - 1.0) * saturation
    local outG = 1.0 + (g - 1.0) * saturation
    local outB = 1.0 + (b - 1.0) * saturation

    return outR, outG, outB, a
end

---------------------------------------------------------------------------
-- CALCULATE DYNAMIC ROW COLORS (BACKGROUND & EDGE)
---------------------------------------------------------------------------
function TT.GetTrackerRowColors(r, g, b, a, isCurrentTarget)
    local fR, fG, fB, fA
    local eR, eG, eB, eA
    local cR, cG, cB, cA

    fR, fG, fB, fA = r, g, b, a

    local style = TT.SV.trackerBackgroundStyle or 2
    if style == 0 or style == 1 and not isCurrentTarget then
        r, g, b = 1/3, 1/3, 1/3
    end

    if isCurrentTarget then
        eR, eG, eB = TT.GetFactoredColor(r, g, b, 3/3)
        cR, cG, cB = TT.GetFactoredColor(r, g, b, 2/3)
    else
        eR, eG, eB = TT.GetFactoredColor(r, g, b, 2/3)
        cR, cG, cB = TT.GetFactoredColor(r, g, b, 1/3)
    end

    cA = TT.SV.trackerBackgroundAlpha
    eA = math.min(1, TT.SV.trackerBackgroundAlpha * 1.5)

    if TT.SV.trackerEdgeThickness == 0 then
        eA = 0
    end

    return fR, fG, fB, fA, cR, cG, cB, cA, eR, eG, eB, eA
end

---------------------------------------------------------------------------
-- PLAY SOUND WHEN TAUNTING
---------------------------------------------------------------------------
function TT.PlaySoundTaunt()
    for i = 1, TT.SV.soundTauntVolume do
        PlaySound(TT.SV.soundTauntSelected)
    end
end

---------------------------------------------------------------------------
-- DISABLE MARKERS AND WARN
---------------------------------------------------------------------------
function TT.DisableFloatingMarkers(conflictingAddon)
    if not TT.SV.isEnabledFloatingMarker then return end

    TT.isExternalFloatingMarker = true
    TT.SV.isEnabledFloatingMarker = false

    local conflictName = conflictingAddon and ("[" .. conflictingAddon .. "]") or "another addon"
    d("|cFF7F00[Target Taunt]|r |cFF0000WARNING: 3D Floating Markers automatically disabled! Conflict with " .. conflictName .. " detected.|r")
end

---------------------------------------------------------------------------
-- REGISTER HOOKS
---------------------------------------------------------------------------
function TT.RegisterHooks()
    ZO_PreHook("SetFloatingMarkerInfo", function(markerType, size, primaryTexturePath)
        if TT.isInternalFloatingMarker then return false end

        if markerType == MAP_PIN_TYPE_AGGRO and primaryTexturePath then --and primaryTexturePath ~= "" then
            if primaryTexturePath ~= TT.SV.floatingMarkerTexture then
                TT.DisableFloatingMarkers()
            end
        end
        return false
    end)
end

---------------------------------------------------------------------------
-- HELPER: CHECK FOR KNOWN CONFLICTING ADDONS
---------------------------------------------------------------------------
function TT.GetConflictingAddon()
    local conflictingAddons = {
        { name = "Makos's ContentHelper", check = function() return ContentHelper ~= nil end },
        { name = "Untaunted", check = function() return Untaunted ~= nil and Untaunted.db and Untaunted.db.showmarker == true end },
    }

    for i = 1, #conflictingAddons do
        if conflictingAddons[i].check() then
            return conflictingAddons[i].name
        end
    end

    return nil
end

---------------------------------------------------------------------------
-- TARGET MARKER INIT
---------------------------------------------------------------------------
function TT.SetFloatingMarker()
    if not TT.SV.isEnabledFloatingMarker then return end

    local conflictingAddon = TT.GetConflictingAddon()
    if conflictingAddon or TT.isExternalFloatingMarker then
        TT.DisableFloatingMarkers(conflictingAddon)
        return
    end

    -- SET MY OWN FLOATING MARKERS IF EVERYTHING IS (HOPEFULLY) SAFE
    local primaryTexturePath = TT.SV.floatingMarkerTexture
    local isPulse = TT.SV.isEnabledFloatingMarkerPulse

    -- PREVENT THE HOOK FROM MISFIRING
    TT.isInternalFloatingMarker = true

    -- API DOKU: (by Dan Batson) SetFloatingMarkerInfo(markerType [MapDisplayPinType], size [float], primaryTexturePath [string], secondaryTexturePath [string], primaryPulses [bool], secondaryPulses [bool])
    -- /script SetFloatingMarkerInfo(MAP_PIN_TYPE_QUEST_OFFER, 32, "EsoUI/Art/FloatingMarkers/quest_available_icon.dds", "", true)
    SetFloatingMarkerInfo(MAP_PIN_TYPE_AGGRO, TT.SV.floatingMarkerSize, primaryTexturePath, "", isPulse)
    SetFloatingMarkerGlobalAlpha(1)

    TT.isInternalFloatingMarker = false
end

---------------------------------------------------------------------------
-- CHECK IF UNIT IS TAUNT IMMUNE
---------------------------------------------------------------------------
function TT.IsUnitTauntImmune(unitTag)
    if not unitTag or not DoesUnitExist(unitTag) then return false, 0, 0 end
    for i = 1, GetNumBuffs(unitTag) do
        local _, _, timeEnding, _, _, _, _, _, _, _, abilityId = GetUnitBuffInfo(unitTag, i)
        if abilityId == TT.TAUNT_IMMUNITY_ID then
            local timeRemaining = math.max(0, timeEnding - GetFrameTimeSeconds())
            return true, timeRemaining, timeEnding
        end
    end
    return false, 0, 0
end

---------------------------------------------------------------------------
-- TAUNT ANIMATION (SHORT PULSE)
---------------------------------------------------------------------------
function TT.PlayAnimationReticle()
    if TT.isAnimationActive then return end

    local targetScale = 1
    if TT.SV.isEnabledReticleAnimation then
        targetScale = TT.SV.reticleAnimationScale / 100
    end
    local durationGrow = math.floor(TT.SV.reticleAnimationDuration / 3)
    local durationShrink = TT.SV.reticleAnimationDuration - durationGrow
    local targetControl = (TT.SV.isEnabledReticleName or TT.isWarningActive) and TT.RETICLE_NAME or TT.RETICLE_TIME

    if not TT.ANIMATION_TIMELINE then
        TT.ANIMATION_TIMELINE = ANIMATION_MANAGER:CreateTimeline()

        TT.ANIMATION_SCALEUP = TT.ANIMATION_TIMELINE:InsertAnimation(ANIMATION_SCALE, targetControl, 0)
        TT.ANIMATION_SCALEUP:SetEasingFunction(ZO_EaseInQuadratic)

        TT.ANIMATION_SCALEDOWN = TT.ANIMATION_TIMELINE:InsertAnimation(ANIMATION_SCALE, targetControl, 0)
        TT.ANIMATION_SCALEDOWN:SetEasingFunction(ZO_EaseOutQuadratic)

        TT.ANIMATION_TIMELINE:SetHandler('OnStop', function()
            TT.RETICLE_NAME:SetScale(1.0)
            TT.RETICLE_TIME:SetScale(1.0)
            TT.isAnimationActive = false
            TT.UpdateReticleTarget()
        end)
    else
        TT.ANIMATION_SCALEUP:SetAnimatedControl(targetControl)
        TT.ANIMATION_SCALEDOWN:SetAnimatedControl(targetControl)
    end

    if TT.ANIMATION_TIMELINE:IsPlaying() then TT.ANIMATION_TIMELINE:Stop() end
    TT.isAnimationActive = true

    TT.ANIMATION_SCALEUP:SetScaleValues(1.0, targetScale)
    TT.ANIMATION_SCALEUP:SetDuration(durationGrow)

    TT.ANIMATION_SCALEDOWN:SetScaleValues(targetScale, 1.0)
    TT.ANIMATION_SCALEDOWN:SetDuration(durationShrink)
    TT.ANIMATION_TIMELINE:SetAnimationOffset(TT.ANIMATION_SCALEDOWN, durationGrow)

    TT.ANIMATION_TIMELINE:PlayFromStart()
end

---------------------------------------------------------------------------
-- TAUNT ANIMATION FOR SPECIFIC TRACKER ROW
---------------------------------------------------------------------------
function TT.PlayAnimationTracker(index)
    if not TT.SV.isEnabledTrackerAnimation then return end

    local TRACKER_ROW = TT.TRACKER_ROWS[index]
    if not TRACKER_ROW then return end

    local targetScale = TT.SV.trackerAnimationScale / 100
    local durationGrow = math.floor(TT.SV.trackerAnimationDuration / 3)
    local durationShrink = TT.SV.trackerAnimationDuration - durationGrow

    if TRACKER_ROW.TIMELINE:IsPlaying() then TRACKER_ROW.TIMELINE:Stop() end

    TRACKER_ROW.SCALEUP:SetScaleValues(1.0, targetScale)
    TRACKER_ROW.SCALEUP:SetDuration(durationGrow)

    TRACKER_ROW.SCALEDOWN:SetScaleValues(targetScale, 1.0)
    TRACKER_ROW.SCALEDOWN:SetDuration(durationShrink)
    TRACKER_ROW.TIMELINE:SetAnimationOffset(TRACKER_ROW.SCALEDOWN, durationGrow)

    TRACKER_ROW.TIMELINE:PlayFromStart()
end

---------------------------------------------------------------------------
-- UI FEEDBACK TRIGGERS (ONE-TIME EVENTS: SOUNDS & ANIMATIONS)
---------------------------------------------------------------------------
function TT.TriggerTauntGainedFeedback(isPlayerTaunt, isImportant, unitId, cleanName, isBoss)
    -- TRACKER ANIMATION
    local index = TT.GetTrackerIndex(unitId)
    if index then
        TT.PlayAnimationTracker(index)
    end

    -- RETICLE FEEDBACK
    if not isPlayerTaunt then return end

    -- FRONTEND FORMATTING
    local displayName = TT.GetFormattedName(cleanName, isBoss, TT.SV.reticleMaxLengthName)
    TT.RETICLE_NAME:SetText(displayName)

    local r, g, b, a
    if isImportant then
        r, g, b, a = unpack(TT.SV.colorPlayer100)
    else
        r, g, b, a = unpack(TT.SV.colorHarmless)
    end

    TT.RETICLE_NAME:SetColor(r, g, b, a)
    TT.RETICLE_TIME:SetColor(r, g, b, a)
    TT.RETICLE_TIME:SetText(tostring(TT.DURATION_TAUNT))

    if TT.IsReticleEnabled() and not TT.isHiddenByScene then
        TT.RETICLE:SetHidden(false)
        TT.RETICLE_NAME:SetHidden(not TT.SV.isEnabledReticleName)
        TT.RETICLE_TIME:SetHidden(not TT.SV.isEnabledTimer)
        TT.PlayAnimationReticle()
    end

    -- SOUND
    if TT.SV.isEnabledSoundTauntImportant then
        if isImportant or TT.SV.isEnabledSoundTauntHarmless then
            TT.PlaySoundTaunt()
        end
    end
end

---------------------------------------------------------------------------
-- UI FEEDBACK TRIGGERS SOUNDS AND ANIMATIONS
---------------------------------------------------------------------------
function TT.TriggerWarningTaunt(isBoss, cleanName)
    if not isBoss then return end
    if not (TT.SV.isEnabledWarningTauntFaded or TT.SV.isEnabledWarningTauntImmunity) then return end

    local _, activeBossTag = TT.CheckIfBoss(nil, cleanName)
    if not activeBossTag or IsUnitDead(activeBossTag) then return end

    local isImmune, immuneTimeRemaining = TT.IsUnitTauntImmune(activeBossTag)

    local showImmunity = isImmune and TT.SV.isEnabledWarningTauntImmunity
    local showFaded = not isImmune and TT.SV.isEnabledWarningTauntFaded

    local displayName = TT.GetFormattedName(cleanName, isBoss, TT.SV.reticleMaxLengthName)
    if showImmunity then
        local r, g, b, a = unpack(TT.SV.colorImmune)
        TT.RETICLE_NAME:SetText(displayName)
        TT.RETICLE_TIME:SetText(string.format("TAUNT IMMUNE: %.1f", immuneTimeRemaining))
        TT.RETICLE_NAME:SetColor(r, g, b, a)
        TT.RETICLE_TIME:SetColor(r, g, b, a)
    elseif showFaded then
        local r, g, b, a = unpack(TT.SV.colorNone)
        TT.RETICLE_NAME:SetText(displayName)
        TT.RETICLE_TIME:SetText("NO ACTIVE TAUNT")
        TT.RETICLE_NAME:SetColor(r, g, b, a)
        TT.RETICLE_TIME:SetColor(r, g, b, a)
    else
        return
    end

    if TT.IsReticleEnabled() and not TT.isHiddenByScene then
        TT.RETICLE:SetHidden(false)
        TT.RETICLE_NAME:SetHidden(false)
        TT.RETICLE_TIME:SetHidden(false)

        TT.RETICLE_NAME:ClearAnchors()
        TT.RETICLE_NAME:SetAnchor(CENTER, TT.RETICLE, CENTER)
        TT.RETICLE_TIME:ClearAnchors()
        TT.RETICLE_TIME:SetAnchor(TOP, TT.RETICLE_NAME, BOTTOM)

        if TT.SV.isEnabledReticleAnimation then
            TT.PlayAnimationReticle()
        end
    end

    TT.isWarningActive = true
    EVENT_MANAGER:RegisterForUpdate(TT.NAME .. "_TIMER_WARNING", TT.SV.warningTauntDuration, function()
        EVENT_MANAGER:UnregisterForUpdate(TT.NAME .. "_TIMER_WARNING")
        TT.isWarningActive = false
        TT.UpdateReticleAnchors()
        TT.RETICLE_NAME:SetHidden(not TT.SV.isEnabledReticleName)
        TT.RETICLE_TIME:SetHidden(not TT.SV.isEnabledTimer)
        TT.UpdateReticleTarget()
    end)
end

---------------------------------------------------------------------------
-- GET LIVE DATA FROM RETICLE (DATA ONLY)
---------------------------------------------------------------------------
function TT.GetReticleTauntState()
    local tauntState = TT.TAUNT_STATE_NONE
    local timeRemaining = 0
    local reticleEndTime = 0 -- TEST
    local isTauntImmunity, timeImmuneRemaining, immuneEndTime = TT.IsUnitTauntImmune("reticleover")

    if isTauntImmunity then
        return TT.TAUNT_STATE_IMMUNE, timeImmuneRemaining, immuneEndTime
    end

    for i = 1, GetNumBuffs("reticleover") do
        -- FROM HERE: https://esoapi.uesp.net/100020/data/g/e/t/GetUnitBuffInfo.html
        -- local buffName, startTime, endTime, buffSlot, stackCount, iconFile, buffType, effectType, abilityType, statusEffectType = GetUnitBuffInfo("player", i)
        -- local buffName, timeStarted, timeEnding, buffSlot, stackCount, iconFilename, buffType, effectType, abilityType, statusEffectType, abilityId, _, castByPlayer = GetUnitBuffInfo(unitTag, i) 
        local _, _, timeEnding, _, _, _, _, _, _, _, abilityId, _, castByPlayer = GetUnitBuffInfo("reticleover", i)
        if abilityId == TT.TAUNT_ID then
            reticleEndTime = timeEnding
            timeRemaining = reticleEndTime - GetFrameTimeSeconds()
            tauntState = castByPlayer and TT.TAUNT_STATE_PLAYER or TT.TAUNT_STATE_OTHER
            break
        end
    end

    return tauntState, timeRemaining, reticleEndTime
end

---------------------------------------------------------------------------
-- GET COLOR AND TIME STRING
---------------------------------------------------------------------------
function TT.GetTauntStateColorTime(tauntState, timeRemaining, isImportant)
    local r, g, b, a

    -- INITIALIZE DEFAULT COLOR BASED ON IMPORTANCE
    local stringTime = ""

    if tauntState == TT.TAUNT_STATE_IMMUNE then
        r, g, b, a = unpack(TT.SV.colorImmune)
        stringTime = string.format("IMMUNE")
        --stringTime = string.format("%.1f", timeRemaining)
    elseif tauntState == TT.TAUNT_STATE_PLAYER then
        if isImportant then
            local percentage = timeRemaining / TT.DURATION_TAUNT
            r, g, b, a = TT.GetTimerColor(percentage, TT.SV.colorPlayer100, TT.SV.colorPlayer50, TT.SV.colorPlayer0)
        else
            r, g, b, a = unpack(TT.SV.colorHarmless)
        end

        if timeRemaining > 5 then
            stringTime = string.format("%.0f", timeRemaining)
        elseif timeRemaining > 0 then
            stringTime = string.format("%.1f", timeRemaining)
        end
    elseif tauntState == TT.TAUNT_STATE_OTHER then
        r, g, b, a = unpack(TT.SV.colorOther)
        stringTime = string.format("%.1f", timeRemaining) -- OTHER PLAYER
    else
        if isImportant then
            r, g, b, a = unpack(TT.SV.colorNone)
        else
            r, g, b, a = unpack(TT.SV.colorHarmless)
        end
        stringTime = "0.0"
    end

    if tauntState == TT.TAUNT_STATE_NONE then
        stringTime = "0.0"
    end

    return r, g, b, a, stringTime
end

---------------------------------------------------------------------------
-- CATCH TAUNTS VIA EFFECT CHANGED EVENT
-- https://wiki.esoui.com/Constant_Values#REGISTER_FILTER_COMBAT_RESULT
---------------------------------------------------------------------------
function TT.OnEffectChanged(_, changeType, _, _, unitTag, _, endTime, _, _, _, _, _, _, targetName, unitId, abilityId, sourceType)
    if abilityId ~= TT.TAUNT_ID then return end
    if not TT.CheckVisibility() then return end

    local cleanName = TT.GetCleanName(targetName)
    local targetData = TT.targetData[unitId]

    local isPlayerTaunt = (sourceType == COMBAT_UNIT_TYPE_PLAYER)

    if not isPlayerTaunt then
        if sourceType ~= COMBAT_UNIT_TYPE_GROUP then return end

        if not TT.SV.isEnabledOtherTaunts then
            local isActiveReal = targetData and targetData.isActive
            local scanData = TT.targetData["SCAN_" .. cleanName]
            local isActiveScanned = scanData and scanData.isActive

            if not isActiveReal and not isActiveScanned then
                return -- NEW TARGET
            end
        end
    end

    local difficulty = nil

    if unitTag and unitTag ~= "" then
        difficulty = GetUnitDifficulty(unitTag)

    -- elseif targetName == GetUnitName("reticleover") then
    --     difficulty = GetUnitDifficulty("reticleover")
    --     unitTag = "reticleover"

    elseif cleanName == TT.currentReticleName and TT.currentReticleName ~= "" then
        difficulty = GetUnitDifficulty("reticleover")
        unitTag = "reticleover"

    end

    -- CHECK FOR BOSS
    local isBoss, activeBossTag = TT.CheckIfBoss(unitTag, targetName)
    if isBoss then
        unitTag = activeBossTag
        if not difficulty then difficulty = GetUnitDifficulty(activeBossTag) end
    end

    -- CACHE FALLBCAK
    if not difficulty and TT.difficultyCache and TT.difficultyCache[cleanName] then -- CACHENAME
        difficulty = TT.difficultyCache[cleanName] -- CACHENAME
    end

    -- EVALUATE IMPORTANCE
    local isImportant = false
    if difficulty then
        isImportant = TT.IsTargetImportant(difficulty, unitTag, targetName)
    end

    if targetData and targetData.isActive and targetData.isImportant then
        isImportant = true
    end

    -- EVALUATE TAUNT STATE
    local tauntState = TT.TAUNT_STATE_NONE

    -- NOT IMPORTANT TARGETS (TRASH?)
    if not isImportant then
        if not isPlayerTaunt then return end

        if TT.SV.isEnabledIgnoreHarmless then return end

        if TT.SV.isEnabledFlagHarmlessImportant and (changeType == EFFECT_RESULT_GAINED or changeType == EFFECT_RESULT_UPDATED) then
            isImportant = true
        end
    end

    if changeType == EFFECT_RESULT_GAINED or changeType == EFFECT_RESULT_UPDATED then
        if TT.isWarningActive then
            TT.isWarningActive = false
            EVENT_MANAGER:UnregisterForUpdate(TT.NAME .. "_TIMER_WARNING")
        end

        tauntState = isPlayerTaunt and TT.TAUNT_STATE_PLAYER or TT.TAUNT_STATE_OTHER

        -- SEND EVRYTHING TO DATA MANAGER
        TT.UpdateCentralTarget(unitId, cleanName, endTime, tauntState, isBoss, isImportant)

        -- HATE TO DO.. REFRESH REFERENCE FOR SOME EDGE CASES (NEW TARGET)
        targetData = TT.targetData[unitId]
        if targetData then targetData.expireTimeHighlight = 0 end

        -- CURRENT TARTGET WAS TAUNTED?
        if DoesUnitExist("reticleover") and cleanName == TT.GetCleanName(GetUnitName("reticleover")) then
            TT.currentReticleName = cleanName
            TT.reticleExpireTimeHighlight = 0
            TT.currentReticleEndTime = endTime
            TT.UpdateReticleTarget()
        end

        -- TRIGGER VISUAL FEEDBACK
        TT.TriggerTauntGainedFeedback(isPlayerTaunt, isImportant, unitId, cleanName, isBoss)

    elseif changeType == EFFECT_RESULT_FADED then
        if targetData and targetData.tauntState == TT.TAUNT_STATE_IMMUNE then
            return
        end

        local currentTime = GetFrameTimeSeconds()
        local expireTime = currentTime + (isImportant and TT.SV.expireTimeImportant or TT.SV.expireTimeHarmless)
        TT.UpdateCentralTarget(unitId, cleanName, 0, TT.TAUNT_STATE_NONE, isBoss, isImportant, expireTime)

        -- REFRESH REFERENCE FOR SOME EDGE CASES (NEW TARGET)
        targetData = TT.targetData[unitId]
        if targetData and isImportant then
            targetData.expireTimeHighlight = currentTime + TT.SV.expireTimeHighlight
        end

        if cleanName == TT.currentReticleName and isImportant then
            TT.reticleExpireTimeHighlight = currentTime + TT.SV.expireTimeHighlight
            TT.currentReticleEndTime = 0
        end

        -- REFRESH TO PRVENT GHOSTING
        if isBoss then
            zo_callLater(function()
                local data = TT.targetData[unitId]
                if data and data.tauntState == TT.TAUNT_STATE_NONE and not data.isDead then
                    TT.TriggerWarningTaunt(isBoss, cleanName)
                end
            end, 100)
        end
    end

    -- WAKE UP THE TRACKER UI (AGAIN)
    TT.RenderTrackerDisplay()
    TT.ManageTrackerLoop()
end

---------------------------------------------------------------------------
-- CATCH TAUNT IMMUNITY EFFECTS
---------------------------------------------------------------------------
function TT.OnImmunityChanged(_, changeType, _, _, unitTag, _, endTime, _, _, _, _, _, _, targetName, unitId, abilityId, _)
    if abilityId ~= TT.TAUNT_IMMUNITY_ID then return end
    if not TT.CheckVisibility() then return end

    local cleanName = TT.GetCleanName(targetName)
    if cleanName == "" then return end

    local isBoss, activeBossTag = TT.CheckIfBoss(unitTag, targetName)
    if isBoss then unitTag = activeBossTag end

    if changeType == EFFECT_RESULT_GAINED or changeType == EFFECT_RESULT_UPDATED then
        TT.UpdateCentralTarget(unitId, cleanName, endTime, TT.TAUNT_STATE_IMMUNE, isBoss, true)

        if isBoss then
            TT.TriggerWarningTaunt(true, cleanName)
        end
    elseif changeType == EFFECT_RESULT_FADED then
        local expireTime = GetFrameTimeSeconds() + TT.SV.expireTimeImportant
        TT.UpdateCentralTarget(unitId, cleanName, 0, TT.TAUNT_STATE_NONE, isBoss, true, expireTime)
    end

    TT.RenderTrackerDisplay()
    TT.ManageTrackerLoop()
end

---------------------------------------------------------------------------
-- TOGGLE BOTH PREVIEWS (SLASH COMMAND)
---------------------------------------------------------------------------
function TT.ToggleBothPreviews()
    if TT.isReticleUnlocked or TT.isTrackerUnlocked then
        TT.isReticleUnlocked = false
        TT.isTrackerUnlocked = false

        d(TT.CHAT .. " |cFF0000UI Locked|r")
    else
        TT.isReticleUnlocked = true
        TT.isTrackerUnlocked = true

        d(TT.CHAT .. " |c00FF00UI Unlocked|r")
    end

    TT.UpdatePreview()

    if TT.MENU_PANEL then
        CALLBACK_MANAGER:FireCallbacks("LAM-RefreshPanel", TT.MENU_PANEL)
    end
end

---------------------------------------------------------------------------
-- ON PLAYER ACTIVATED
---------------------------------------------------------------------------
function TT.OnPlayerActivated()
    if TT.SV.isEnabledFloatingMarker then
        zo_callLater(function() TT.SetFloatingMarker() end, 5000)
    end
    TT.UpdateNameplates()
end

---------------------------------------------------------------------------
-- ENABLE ADDON
---------------------------------------------------------------------------
function TT.Enable()
    if TT.isLoaded then return end

    SCENE_MANAGER:GetScene("hud"):RegisterCallback("StateChange", TT.OnStateChange)
    SCENE_MANAGER:GetScene("hudui"):RegisterCallback("StateChange", TT.OnStateChange)

    EVENT_MANAGER:RegisterForEvent(TT.NAME .. "_EVENT_RETICLE_TARGET_CHANGED", EVENT_RETICLE_TARGET_CHANGED, TT.UpdateReticleTarget)
    EVENT_MANAGER:RegisterForEvent(TT.NAME .. "_EVENT_EFFECT_CHANGED", EVENT_EFFECT_CHANGED, TT.OnEffectChanged)
    EVENT_MANAGER:AddFilterForEvent(TT.NAME .. "_EVENT_EFFECT_CHANGED", EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, TT.TAUNT_ID)

    EVENT_MANAGER:RegisterForEvent(TT.NAME .. "_EVENT_IMMUNITY_CHANGED", EVENT_EFFECT_CHANGED, TT.OnImmunityChanged)
    EVENT_MANAGER:AddFilterForEvent(TT.NAME .. "_EVENT_IMMUNITY_CHANGED", EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, TT.TAUNT_IMMUNITY_ID)

    EVENT_MANAGER:RegisterForEvent(TT.NAME .. "_EVENT_PLAYER_ACTIVATED", EVENT_PLAYER_ACTIVATED, TT.OnPlayerActivated)
    EVENT_MANAGER:RegisterForEvent(TT.NAME .. "_EVENT_PLAYER_COMBAT_STATE", EVENT_PLAYER_COMBAT_STATE, TT.OnCombatStateChanged)

    EVENT_MANAGER:RegisterForEvent(TT.NAME .. "_EVENT_COMBAT_DEATH", EVENT_COMBAT_EVENT, TT.OnUnitDeath)
    EVENT_MANAGER:AddFilterForEvent(TT.NAME .. "_EVENT_COMBAT_DEATH", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_DIED)

    EVENT_MANAGER:RegisterForEvent(TT.NAME .. "_EVENT_COMBAT_DEATH_XP", EVENT_COMBAT_EVENT, TT.OnUnitDeath)
    EVENT_MANAGER:AddFilterForEvent(TT.NAME .. "_EVENT_COMBAT_DEATH_XP", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_DIED_XP)

    EVENT_MANAGER:RegisterForUpdate(TT.NAME .. "_WATCHDOG", 1000, TT.RunTrackerWatchdog)

    TT.UpdateReticleTarget()
    TT.isLoaded = true
end

---------------------------------------------------------------------------
-- DISABLE ADDON
---------------------------------------------------------------------------
function TT.Disable()
     EVENT_MANAGER:UnregisterForEvent(TT.NAME .. "_EVENT_RETICLE_TARGET_CHANGED", EVENT_RETICLE_TARGET_CHANGED)
     EVENT_MANAGER:UnregisterForEvent(TT.NAME .. "_EVENT_EFFECT_CHANGED", EVENT_EFFECT_CHANGED)
     EVENT_MANAGER:UnregisterForEvent(TT.NAME .. "_EVENT_IMMUNITY_CHANGED", EVENT_EFFECT_CHANGED)
     EVENT_MANAGER:UnregisterForEvent(TT.NAME .. "_EVENT_PLAYER_ACTIVATED", EVENT_PLAYER_ACTIVATED)

     EVENT_MANAGER:UnregisterForEvent(TT.NAME .. "_EVENT_PLAYER_COMBAT_STATE", EVENT_PLAYER_COMBAT_STATE)

     EVENT_MANAGER:UnregisterForEvent(TT.NAME .. "_EVENT_COMBAT_DEATH", EVENT_COMBAT_EVENT)
     EVENT_MANAGER:UnregisterForEvent(TT.NAME .. "_EVENT_COMBAT_DEATH_XP", EVENT_COMBAT_EVENT)

     EVENT_MANAGER:UnregisterForUpdate(TT.NAME .. "_WATCHDOG")

     -- FORCE STOP PREVIEW
     if TT.MARKER_PREVIEW then TT.MARKER_PREVIEW:SetHidden(true) end

     -- FORCE STOP ANIMATION TO ALLOW HIDING
     if TT.ANIMATION_TIMELINE and TT.ANIMATION_TIMELINE:IsPlaying() then
         TT.ANIMATION_TIMELINE:Stop()
     end
     TT.isAnimationActive = false

     TT.ClearTracker()

     TT.HideAndStopUpdate()
     TT.isLoaded = false
end