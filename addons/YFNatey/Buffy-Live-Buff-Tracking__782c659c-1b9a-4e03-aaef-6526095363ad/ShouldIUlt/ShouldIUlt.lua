local ADDON_NAME = "ShouldIUlt"


ShouldIUlt = {}
ShouldIUlt.savedVars = nil
ShouldIUlt.buffData = {}
ShouldIUlt.isInitialized = false

-- Optimize function calls
ShouldIUlt.lastScanTime = 0
ShouldIUlt.scanThrottle = 250
ShouldIUlt.lastUltCheck = 0
ShouldIUlt.ultCheckThrottle = 500

-- Off Baklance Timers
ShouldIUlt.offBalanceImmunityTimer = nil
ShouldIUlt.offBalanceImmunityEndTime = 0
ShouldIUlt.offBalanceImmunityDuration = 15000

-- Static mode caching
ShouldIUlt.staticSlotsCache = nil
ShouldIUlt.lastStaticSettingsHash = nil
ShouldIUlt.pendingUIUpdate = false
ShouldIUlt.pendingBossUpdate = false
ShouldIUlt.pendingDebuffUpdate = false

-- Buff Caching
ShouldIUlt.buffNameCache = {}
ShouldIUlt.trackedBuffsCache = nil
ShouldIUlt.lastSettingsHash = nil
ShouldIUlt.cachedSimulatedBuffs = nil
ShouldIUlt.simulationCacheTime = 0
---=============================================================================
-- Scan Boss Debuffs and player Buffs
--=============================================================================

function ShouldIUlt:ScanCurrentBuffs()
    self.buffData = {}

    local unitTag = "player"
    local numberOfBuffs = GetNumBuffs(unitTag)

    for i = 0, numberOfBuffs do
        local buffName, timeStarted, timeEnding, buffSlot, stackCount, iconFilename, buffType, effectType, abilityType, statusEffectType, abilityId, canClickOff, castByPlayer =
            GetUnitBuffInfo(unitTag, i)

        if buffName and abilityId and ShouldIUlt:IsTrackedBuff(abilityId) then
            local startTimeMs = timeStarted * 1000
            local endTimeMs = timeEnding * 1000
            local durationMs = endTimeMs - startTimeMs

            local isPermanent = false


            if timeStarted == timeEnding then
                isPermanent = true
            elseif durationMs > 3600000 then
                isPermanent = true
            elseif durationMs <= 0 then
                isPermanent = true
            end

            -- Handle permanent buffs
            if isPermanent then
                durationMs = 0
                endTimeMs = 0
            end

            self.buffData[abilityId] = {
                name = buffName,
                iconName = iconFilename,
                endTime = endTimeMs,
                startTime = startTimeMs,
                stackCount = stackCount or 1,
                duration = durationMs,
                slot = buffSlot,
                isPermanent = isPermanent,
                canClickOff = canClickOff,
                castByPlayer = castByPlayer
            }
        end
    end
end

function ShouldIUlt:ScanBossDebuffs()
    local bossDebuffs = {}
    local bossUnitTags = { "boss1", "boss2", "boss3", "boss4", "boss5", "boss6" }

    for _, unitTag in ipairs(bossUnitTags) do
        if DoesUnitExist(unitTag) and IsUnitAttackable(unitTag) then
            local unitName = GetUnitName(unitTag)
            local numberOfBuffs = GetNumBuffs(unitTag)

            for i = 0, numberOfBuffs do
                local buffName, timeStarted, timeEnding, buffSlot, stackCount, iconFilename, buffType, effectType, abilityType, statusEffectType, abilityId, canClickOff, castByPlayer =
                    GetUnitBuffInfo(unitTag, i)

                if buffName and abilityId and self:IsTrackedBuff(abilityId) then
                    local startTimeMs = timeStarted * 1000
                    local endTimeMs = timeEnding * 1000
                    local durationMs = endTimeMs - startTimeMs

                    local isPermanent = (timeStarted == timeEnding) or (durationMs <= 0)
                    if isPermanent then
                        durationMs = 0
                        endTimeMs = 0
                    end

                    local isOffBalanceImmunity = (abilityId == 134599)

                    bossDebuffs[abilityId] = {
                        name = buffName,
                        iconName = iconFilename,
                        endTime = endTimeMs,
                        startTime = startTimeMs,
                        stackCount = stackCount or 1,
                        duration = durationMs,
                        slot = buffSlot,
                        bossName = unitName,
                        bossTag = unitTag,
                        isBossDebuff = true,
                        isOffBalanceImmunity = isOffBalanceImmunity,
                        isPermanent = isPermanent,
                        canClickOff = canClickOff,
                        castByPlayer = castByPlayer
                    }
                end
            end
        end
    end

    return bossDebuffs
end

function ShouldIUlt:ScanTargetDebuffs()
    local currentTime = GetGameTimeMilliseconds()

    -- Throttle
    if (currentTime - self.lastScanTime) < self.scanThrottle then
        return
    end
    self.lastScanTime = currentTime
    local targetTag = "reticleover"

    if not self.bossDebuffData then
        self.bossDebuffData = {}
    end

    -- Renmove expired Buffs from display
    if not DoesUnitExist(targetTag) then
        self:CleanupExpiredDebuffs(currentTime)
        return
    end

    local targetName = GetUnitName(targetTag)
    if not IsUnitAttackable(targetTag) then
        self:CleanupExpiredDebuffs(currentTime)
        return
    end

    -- Build lookup table for tracked buffs
    local trackedBuffIds = {}
    for _, buffId in ipairs(self:GetTrackedBuffs()) do
        trackedBuffIds[buffId] = true
    end

    -- Track existing debuffs for differential analysis
    local existingDebuffs = {}
    for abilityId in pairs(self.bossDebuffData) do
        existingDebuffs[abilityId] = true
    end

    -- Scan current target for debuffs
    local numberOfBuffs = GetNumBuffs(targetTag)
    local maxBuffsToCheck = math.min(numberOfBuffs, 50)

    for i = 0, maxBuffsToCheck do
        local buffName, timeStarted, timeEnding, buffSlot, stackCount, iconFilename, buffType, effectType, abilityType, statusEffectType, abilityId, canClickOff, castByPlayer =
            GetUnitBuffInfo(targetTag, i)

        if buffName and abilityId and trackedBuffIds[abilityId] then
            -- Remove from cleanup list
            existingDebuffs[abilityId] = nil

            local startTimeMs = timeStarted * 1000
            local endTimeMs = timeEnding * 1000
            local durationMs = endTimeMs - startTimeMs
            local isPermanent = (timeStarted == timeEnding) or (durationMs <= 0)

            if isPermanent then
                durationMs = 0
                endTimeMs = 0
            end

            local isOffBalanceImmunity = (abilityId == 134599)

            -- Update or create debuff entry with enhanced metadata
            self.bossDebuffData[abilityId] = {
                name = buffName,
                iconName = iconFilename,
                endTime = endTimeMs,
                startTime = startTimeMs,
                stackCount = stackCount or 1,
                duration = durationMs,
                slot = buffSlot,
                unitTag = targetTag,
                bossName = targetName,
                isBossDebuff = true,
                isOffBalanceImmunity = isOffBalanceImmunity,
                isPermanent = isPermanent,
                lastSeen = currentTime,
                activelyDetected = true
            }
        end
    end
    for abilityId in pairs(existingDebuffs) do
        local debuffInfo = self.bossDebuffData[abilityId]
        if debuffInfo then
            local shouldRemove = false

            if debuffInfo.isPermanent then
                -- Permanent debuffs
                if currentTime - debuffInfo.lastSeen > 10000 then -- 10 second grace period
                    shouldRemove = true
                end
            else
                -- Timed debuffs
                if (debuffInfo.endTime > 0 and currentTime >= debuffInfo.endTime) or
                    (currentTime - debuffInfo.lastSeen > 5000) then -- 5 second grace period
                    shouldRemove = true
                end
            end

            if shouldRemove then
                self.bossDebuffData[abilityId] = nil
            else
                -- Mark as no longer actively detected but keep in memory
                debuffInfo.activelyDetected = false
            end
        end
    end
end

function ShouldIUlt:CleanupExpiredDebuffs(currentTime)
    if not self.bossDebuffData then
        return
    end

    local expiredDebuffs = {}

    for abilityId, debuffInfo in pairs(self.bossDebuffData) do
        local shouldRemove = false

        if debuffInfo.isPermanent then
            -- Permanent debuffs
            local timeSinceLastSeen = currentTime - (debuffInfo.lastSeen or 0)
            if timeSinceLastSeen > 15000 then -- 15 second timeout for permanent effects
                shouldRemove = true
            end
        else
            -- Timed debuffs
            local timeSinceLastSeen = currentTime - (debuffInfo.lastSeen or 0)
            local naturallyExpired = debuffInfo.endTime > 0 and currentTime >= debuffInfo.endTime
            local absentTooLong = timeSinceLastSeen > 8000 -- 8 second timeout

            if naturallyExpired or absentTooLong then
                shouldRemove = true
            end
        end

        if shouldRemove then
            table.insert(expiredDebuffs, abilityId)
        end
    end

    for _, abilityId in ipairs(expiredDebuffs) do
        self.bossDebuffData[abilityId] = nil
    end

    -- Trigger UI update if cleanup occurred
    if #expiredDebuffs > 0 then
        if not self.pendingDebuffUpdate then
            self.pendingDebuffUpdate = true
            zo_callLater(function()
                self.pendingDebuffUpdate = false
                self:UpdateUI()
            end, 100)
        end
    end
end

function ShouldIUlt:IsDebuffValid(abilityId, debuffInfo)
    if not debuffInfo then
        return false
    end

    local currentTime = GetGameTimeMilliseconds()


    if not debuffInfo.isPermanent and debuffInfo.endTime > 0 then
        if currentTime >= debuffInfo.endTime then
            return false
        end
    end


    local timeSinceLastSeen = currentTime - (debuffInfo.lastSeen or 0)
    local maxValidTime = debuffInfo.isPermanent and 15000 or 8000

    return timeSinceLastSeen <= maxValidTime
end

function ShouldIUlt:GetDisplayBuffs()
    if ShouldIUlt.savedVars.simulationMode then
        return self:GetSimulatedBuffs()
    else
        local allBuffs = {}

        -- Player buffs
        for abilityId, buffInfo in pairs(self.buffData) do
            if not (ShouldIUlt.savedVars.hidePermanentBuffs and buffInfo.isPermanent) then
                allBuffs[abilityId] = buffInfo
            end
        end

        -- Boss Debuffs
        if self.bossDebuffData then
            local shouldShowBossDebuffs = ShouldIUlt.savedVars.trackAbyssalInk or
                ShouldIUlt.savedVars.trackVulnerability or
                ShouldIUlt.savedVars.trackOffBalance or
                ShouldIUlt.savedVars.trackBrittle or
                ShouldIUlt.savedVars.trackBreach
            if shouldShowBossDebuffs then
                for abilityId, debuffInfo in pairs(self.bossDebuffData) do
                    if not (ShouldIUlt.savedVars.hidePermanentBuffs and debuffInfo.isPermanent) then
                        allBuffs[abilityId] = debuffInfo
                    end
                end
            end
        end

        -- Off-balance immunity timer
        if self:IsOffBalanceImmunityActive() and ShouldIUlt.savedVars.showOffBalanceImmunity and ShouldIUlt.savedVars.trackOffBalance then
            local hasRealOffBalance = false
            for abilityId, buffInfo in pairs(allBuffs) do
                if self:IsOffBalanceBuff(abilityId) then
                    hasRealOffBalance = true
                    break
                end
            end

            if not hasRealOffBalance then
                -- Fake ability ID for the immunity timer
                local immunityId = 999999
                allBuffs[immunityId] = {
                    name = "Off-Balance",
                    iconName = "/esoui/art/icons/ability_debuff_offbalance.dds",
                    endTime = self.offBalanceImmunityEndTime,
                    startTime = self.offBalanceImmunityEndTime - self.offBalanceImmunityDuration,
                    stackCount = 1,
                    duration = self.offBalanceImmunityDuration,
                    slot = 999,
                    isOffBalanceImmunity = true,
                    isPermanent = false,
                    isImmunityTimer = true
                }
            end
        end

        return allBuffs
    end
end

function ShouldIUlt:GetTrackedBuffs()
    local trackedBuffs = {}

    -- Search for all IDs that match target buff names
    for buffType, data in pairs(self.buffTypeMap) do
        if ShouldIUlt.savedVars[data.setting] then
            for category, categoryData in pairs(self.buffDatabase) do
                if category == "bossDebuffs" then
                    for subcat, buffs in pairs(categoryData) do
                        for abilityId, name in pairs(buffs) do
                            if (data.major and name == data.major) or (data.minor and name == data.minor) then
                                table.insert(trackedBuffs, abilityId)
                            end
                        end
                    end
                else
                    -- Handle direct categories
                    for abilityId, name in pairs(categoryData) do
                        if type(abilityId) == "number" then
                            if (data.major and name == data.major) or (data.minor and name == data.minor) then
                                table.insert(trackedBuffs, abilityId)
                            end
                        end
                    end
                end
            end
        end
    end

    return trackedBuffs
end

function ShouldIUlt:IsTrackedBuff(abilityId)
    local trackedBuffs = ShouldIUlt:GetTrackedBuffs()
    for _, trackedId in ipairs(trackedBuffs) do
        if trackedId == abilityId then
            return true
        end
    end
    return false
end

---=============================================================================
-- Off-Balance and Immunity Timer
--=============================================================================
function ShouldIUlt:IsOffBalanceBuff(abilityId)
    local buffName = self:FindBuffNameInDatabase(abilityId)
    return buffName == "Off-Balance"
end

-- Start timer
function ShouldIUlt:StartOBImmunityTimer()
    local currentTime = GetGameTimeMilliseconds()
    self.offBalanceImmunityEndTime = currentTime + self.offBalanceImmunityDuration

    -- Clear any existing timer
    if self.offBalanceImmunityTimer then
        EVENT_MANAGER:UnregisterForUpdate(self.offBalanceImmunityTimer)
        self.offBalanceImmunityTimer = nil
    end

    -- Create a unique timer name
    local timerName = ADDON_NAME .. "OffBalanceImmunity" .. tostring(currentTime)
    self.offBalanceImmunityTimer = timerName

    EVENT_MANAGER:RegisterForUpdate(timerName, 100, function()
        local now = GetGameTimeMilliseconds()
        if now >= self.offBalanceImmunityEndTime then
            self:ClearOffBalanceImmunityTimer()
            self:UpdateUI()
        end
    end)

    -- Immediate UI update when immunity starts
    self:UpdateUI()
end

-- Timer update
function ShouldIUlt:UpdateOBImmunityTimer()
    if not self:IsOffBalanceImmunityActive() then
        return 0
    end
    return self.offBalanceImmunityEndTime - GetGameTimeMilliseconds()
end

-- Clear Timer
function ShouldIUlt:ClearOffBalanceImmunityTimer()
    if self.offBalanceImmunityTimer then
        EVENT_MANAGER:UnregisterForUpdate(self.offBalanceImmunityTimer)
        self.offBalanceImmunityTimer = nil
    end
    self.offBalanceImmunityEndTime = 0
end

-- Check for Immunity
function ShouldIUlt:IsOffBalanceImmunityActive()
    return self.offBalanceImmunityEndTime > 0 and GetGameTimeMilliseconds() < self.offBalanceImmunityEndTime
end

---=============================================================================
-- Ulti Indicator
--=============================================================================
function ShouldIUlt:CheckUltConditions()
    local currentTime = GetGameTimeMilliseconds()
    if (currentTime - self.lastUltCheck) < self.ultCheckThrottle then
        return self.lastUltResult or false
    end
    self.lastUltCheck = currentTime
    if not ShouldIUlt.savedVars.enableUltCheck then
        self.lastUltResult = false
        return false
    end
    local requiredBuffs = {}

    -- Vulnerability
    if ShouldIUlt.savedVars.ultRequiredBuffs.trackMajorVulnerability then
        requiredBuffs["Major Vulnerability"] = false
    end
    if ShouldIUlt.savedVars.ultRequiredBuffs.trackMinorVulnerability then
        requiredBuffs["Minor Vulnerability"] = false
    end

    -- Slayer
    if ShouldIUlt.savedVars.ultRequiredBuffs.trackMajorSlayer then
        requiredBuffs["Major Slayer"] = false
    end
    if ShouldIUlt.savedVars.ultRequiredBuffs.trackMinorSlayer then
        requiredBuffs["Minor Slayer"] = false
    end

    -- Berserk
    if ShouldIUlt.savedVars.ultRequiredBuffs.trackMajorBerserk then
        requiredBuffs["Major Berserk"] = false
    end
    if ShouldIUlt.savedVars.ultRequiredBuffs.trackMinorBerserk then
        requiredBuffs["Minor Berserk"] = false
    end

    -- Force
    if ShouldIUlt.savedVars.ultRequiredBuffs.trackMajorForce then
        requiredBuffs["Major Force"] = false
    end
    if ShouldIUlt.savedVars.ultRequiredBuffs.trackMinorForce then
        requiredBuffs["Minor Force"] = false
    end

    -- Damage buffs
    if ShouldIUlt.savedVars.ultRequiredBuffs.trackMajorBrutality then
        requiredBuffs["Major Brutality"] = false
    end
    if ShouldIUlt.savedVars.ultRequiredBuffs.trackMinorBrutality then
        requiredBuffs["Minor Brutality"] = false
    end
    if ShouldIUlt.savedVars.ultRequiredBuffs.trackMajorSorcery then
        requiredBuffs["Major Sorcery"] = false
    end
    if ShouldIUlt.savedVars.ultRequiredBuffs.trackMinorSorcery then
        requiredBuffs["Minor Sorcery"] = false
    end

    -- Crit buffs
    if ShouldIUlt.savedVars.ultRequiredBuffs.trackMajorProphecy then
        requiredBuffs["Major Prophecy"] = false
    end
    if ShouldIUlt.savedVars.ultRequiredBuffs.trackMinorProphecy then
        requiredBuffs["Minor Prophecy"] = false
    end
    if ShouldIUlt.savedVars.ultRequiredBuffs.trackMajorSavagery then
        requiredBuffs["Major Savagery"] = false
    end
    if ShouldIUlt.savedVars.ultRequiredBuffs.trackMinorSavagery then
        requiredBuffs["Minor Savagery"] = false
    end

    -- Other buffs
    if ShouldIUlt.savedVars.ultRequiredBuffs.trackMajorHeroism then
        requiredBuffs["Major Heroism"] = false
    end
    if ShouldIUlt.savedVars.ultRequiredBuffs.trackMinorHeroism then
        requiredBuffs["Minor Heroism"] = false
    end
    if ShouldIUlt.savedVars.ultRequiredBuffs.trackMajorBrittle then
        requiredBuffs["Major Brittle"] = false
    end
    if ShouldIUlt.savedVars.ultRequiredBuffs.trackMinorBrittle then
        requiredBuffs["Minor Brittle"] = false
    end
    if ShouldIUlt.savedVars.ultRequiredBuffs.trackOffBalance then
        requiredBuffs["Off-Balance"] = false
    end
    if ShouldIUlt.savedVars.ultRequiredBuffs.trackPowerfulAssault then
        requiredBuffs["PowerfulAssault"] = false
    end
    if ShouldIUlt.savedVars.ultRequiredBuffs.trackAbyssalInk then
        requiredBuffs["Abyssal Ink"] = false
    end


    if next(requiredBuffs) == nil then
        self.lastUltResult = false
        return false
    end

    for abilityId, buffInfo in pairs(self.buffData) do
        local buffName = self:FindBuffNameInDatabase(abilityId)
        if buffName and requiredBuffs[buffName] ~= nil then
            requiredBuffs[buffName] = true
        end
    end

    -- Check boss debuffs
    if self.bossDebuffData then
        for abilityId, debuffInfo in pairs(self.bossDebuffData) do
            local buffName = self:FindBuffNameInDatabase(abilityId)
            if buffName and requiredBuffs[buffName] ~= nil then
                requiredBuffs[buffName] = true
            end
        end
    end

    -- Determine if conditions are met
    local result = false
    if ShouldIUlt.savedVars.ultCheckMode == "all" then
        result = true
        for buffName, isActive in pairs(requiredBuffs) do
            if not isActive then
                result = false
                break
            end
        end
    else
        for buffName, isActive in pairs(requiredBuffs) do
            if isActive then
                result = true
                break
            end
        end
    end
    self.lastUltResult = result
    return result
end

function ShouldIUlt:ShowUltMessage()
    -- Check cooldown
    local currentTime = GetGameTimeMilliseconds()
    if self.lastUltNotification and (currentTime - self.lastUltNotification) < (ShouldIUlt.savedVars.ultCooldown * 1000) then
        return
    end
    self.lastUltNotification = currentTime
    if ShouldIUlt.savedVars.ultMessageSound then
        PlaySound(SOUNDS.SKILL_LINE_LEVELED_UP)
    end
    self:DisplayUltNowMessage()
end

function ShouldIUlt:DisplayUltNowMessage()
    local container = BuffTrackerContainer
    if not container then
        return
    end

    local ultMessage = container:GetNamedChild("UltMessage")
    if not ultMessage then
        for i = 1, container:GetNumChildren() do
            local child = container:GetChild(i)
            if child and child:GetName() then
                local childName = child:GetName()

                if string.find(childName, "UltMessage") then
                    ultMessage = child

                    break
                end
            end
        end
        if not ultMessage then
            return
        end
    end

    local color = ShouldIUlt.savedVars.ultMessageColor or { 1, 0.843, 0, 1 }
    ultMessage:SetColor(color[1], color[2], color[3], color[4])
    ultMessage:SetText("ULT NOW!")
    ultMessage:SetHidden(false)
    ultMessage:SetAlpha(1)
    local scale = ShouldIUlt.savedVars.ultMessageSize or 2
    ultMessage:SetScale(scale)

    zo_callLater(function()
        if ultMessage then
            ultMessage:SetHidden(true)
        end
    end, 6000)
end

function ShouldIUlt:HideUltMessage()
    local container = BuffTrackerContainer
    if not container then return end

    local ultMessage = container:GetNamedChild("UltMessage")
    if ultMessage and not ultMessage:IsHidden() then
        ultMessage:SetHidden(true)
    end
end

function ShouldIUlt:MigrateSettings()
    if not ShouldIUlt.savedVars.showOffBalanceImmunity then
        ShouldIUlt.savedVars.showOffBalanceImmunity = true
    end
end

--=============================================================================
-- Initialize
--=============================================================================
local function Initialize()
    ShouldIUlt.savedVars = ZO_SavedVars:NewAccountWide("ShouldIUltSavedVars", 1, nil, ShouldIUlt.defaults)

    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_EFFECT_CHANGED,
        function(eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName,
                 buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType)
            ShouldIUlt:OnEffectChanged(changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount,
                iconName,
                buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType)
        end)

    -- Filter to only player effects
    EVENT_MANAGER:AddFilterForEvent(ADDON_NAME, EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG, "player")

    local bossUnitTags = { "boss1", "boss2", "boss3", "boss4", "boss5", "boss6" }
    for _, bossTag in ipairs(bossUnitTags) do
        EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "_" .. bossTag, EVENT_EFFECT_CHANGED,
            function(eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName,
                     buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType)
                ShouldIUlt:OnBossEffectChanged(changeType, effectSlot, effectName, unitTag, beginTime, endTime,
                    stackCount,
                    iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId,
                    sourceType)
            end)
        EVENT_MANAGER:AddFilterForEvent(ADDON_NAME .. "_" .. bossTag, EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG,
            bossTag)
    end

    EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "_Target", EVENT_RETICLE_TARGET_CHANGED,
        function() ShouldIUlt:OnTargetChanged() end)

    -- Initialize functions
    ShouldIUlt:ScanCurrentBuffs()
    ShouldIUlt:CreateSettingsMenu()
    ShouldIUlt:UpdateUIPosition()

    ShouldIUlt:UpdateUI()


    ShouldIUlt:StartTimerUpdates()
    ShouldIUlt:MigrateSettings()
end


local function OnAddOnLoaded(event, addonName)
    if addonName == ADDON_NAME then
        EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
        Initialize()
    end
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)


---=============================================================================
-- Events
--=============================================================================
function ShouldIUlt:OnEffectChanged(changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName,
                                    buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId,
                                    sourceType)
    if not ShouldIUlt:IsTrackedBuff(abilityId) then
        return
    end

    local shouldUpdateUI = false

    if changeType == EFFECT_RESULT_GAINED or changeType == EFFECT_RESULT_UPDATED then
        local startTimeMs = beginTime * 1000
        local endTimeMs = endTime * 1000
        local durationMs = endTimeMs - startTimeMs

        local isPermanent = false
        if beginTime == endTime then
            isPermanent = true
        elseif durationMs <= 0 then
            isPermanent = true
        elseif durationMs > 3600000 then
            isPermanent = true
        end

        if isPermanent then
            durationMs = 0
            endTimeMs = 0
        end

        self.buffData[abilityId] = {
            name = effectName,
            iconName = iconName,
            endTime = endTimeMs,
            startTime = startTimeMs,
            stackCount = stackCount or 1,
            duration = durationMs,
            slot = effectSlot,
            isPermanent = isPermanent
        }

        -- Cancel timer if off balance is applied (useful when there are multiple bosses)
        if self:IsOffBalanceBuff(abilityId) then
            self:ClearOffBalanceImmunityTimer()
        end

        shouldUpdateUI = true
    elseif changeType == EFFECT_RESULT_FADED then
        if self:IsOffBalanceBuff(abilityId) and ShouldIUlt.savedVars.showOffBalanceImmunity then
            self:StartOBImmunityTimer()
        end

        self.buffData[abilityId] = nil
        shouldUpdateUI = true
    end

    -- Throttle UI updates to prevent spam
    if shouldUpdateUI then
        if not self.pendingUIUpdate then
            self.pendingUIUpdate = true
            zo_callLater(function()
                self.pendingUIUpdate = false
                self:UpdateUI()
            end, 50)
        end
    end
end

function ShouldIUlt:OnBossEffectChanged(changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount,
                                        iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId,
                                        abilityId, sourceType)
    if not self:IsTrackedBuff(abilityId) then
        return
    end

    local shouldUpdateUI = false

    if changeType == EFFECT_RESULT_GAINED or changeType == EFFECT_RESULT_UPDATED then
        if not self.bossDebuffData then
            self.bossDebuffData = {}
        end

        local startTimeMs = beginTime * 1000
        local endTimeMs = endTime * 1000
        local durationMs = endTimeMs - startTimeMs

        local isPermanent = (beginTime == endTime) or (durationMs <= 0) or (durationMs > 3600000)
        if isPermanent then
            durationMs = 0
            endTimeMs = 0
        end

        local bossName = GetUnitName(unitTag)
        local isOffBalanceImmunity = (abilityId == 134599)

        self.bossDebuffData[abilityId] = {
            name = effectName,
            iconName = iconName,
            endTime = endTimeMs,
            startTime = startTimeMs,
            stackCount = stackCount or 1,
            duration = durationMs,
            slot = effectSlot,
            unitTag = unitTag,
            bossName = bossName,
            isBossDebuff = true,
            isOffBalanceImmunity = isOffBalanceImmunity,
            isPermanent = isPermanent,
            lastSeen = GetGameTimeMilliseconds() -- Track when we last saw this debuff
        }
        if self:IsOffBalanceBuff(abilityId) then
            self:ClearOffBalanceImmunityTimer()
        end

        shouldUpdateUI = true
    elseif changeType == EFFECT_RESULT_FADED then
        if self:IsOffBalanceBuff(abilityId) and ShouldIUlt.savedVars.showOffBalanceImmunity then
            self:StartOBImmunityTimer()
        end

        if self.bossDebuffData and self.bossDebuffData[abilityId] then
            local currentTime = GetGameTimeMilliseconds()

            if self.bossDebuffData[abilityId].endTime > currentTime + 2000 then
                self.bossDebuffData[abilityId].gracePeriod = currentTime + 5000
            else
                self.bossDebuffData[abilityId] = nil
            end
        end
        shouldUpdateUI = true
    end

    -- Throttle UI updates
    if shouldUpdateUI then
        if not self.pendingBossUpdate then
            self.pendingBossUpdate = true
            zo_callLater(function()
                self.pendingBossUpdate = false
                self:UpdateUI()
            end, 50)
        end
    end
end

function ShouldIUlt:OnTargetChanged()
    if not ShouldIUlt.savedVars.enableBossScanning then
        return
    end

    if self.targetChangeTimer then
        zo_callLater(function() end, 0)
    end

    self.targetChangeTimer = zo_callLater(function()
        self.targetChangeTimer = nil

        if ShouldIUlt.savedVars.trackBossDebuffs or ShouldIUlt.savedVars.trackAbyssalInk then
            ShouldIUlt:ScanTargetDebuffs()
        end
    end, 200)
end

function ShouldIUlt:FormatTimerText(remainingTimeMs)
    local remainingSeconds = remainingTimeMs / 1000
    local threshold = ShouldIUlt.savedVars.timerThreshold or 10.0

    if remainingSeconds > 60 then
        -- Always show minutes without decimals
        return string.format("%.0fm", remainingSeconds / 60)
    elseif remainingSeconds > threshold then
        -- Above threshold: show whole seconds only
        return string.format("%.0f", remainingSeconds)
    else
        -- Below threshold: show with decimal precision
        return string.format("%.1f", remainingSeconds)
    end
end

function ShouldIUlt:StartTimerUpdates()
    EVENT_MANAGER:RegisterForUpdate(ADDON_NAME .. "TimerUpdate", 100, function()
        -- Only update timers, not full UI
        if ShouldIUlt.savedVars.showTimer then
            ShouldIUlt:UpdateTimersOnly()
        end

        -- Check ult conditions separately
        if ShouldIUlt:CheckUltConditions() then
            ShouldIUlt:ShowUltMessage()
        end
    end)

    -- Initialize persistent debuff tracking
    self:InitializePersistentDebuffTracking()
end

---=============================================================================
-- UI
--=============================================================================
function ShouldIUlt:ShowTestIcon()
    local container = BuffTrackerContainer
    if container then
        local buffIcon = container:GetNamedChild("BuffIcon1")
        if buffIcon then
            local iconControl = buffIcon:GetNamedChild("Icon")
            if iconControl then
                -- default ESO icon
                iconControl:SetTexture("/esoui/art/icons/ability_weapon_001.dds")
                buffIcon:SetHidden(false)
            end
        end
    end
end

function ShouldIUlt:UpdateUIPosition()
    local container = BuffTrackerContainer
    if container then
        local maxX = math.floor(GuiRoot:GetWidth() / 2)
        local maxY = math.floor(GuiRoot:GetHeight() / 2)

        local clampedX = math.max(-maxX, math.min(maxX, ShouldIUlt.savedVars.positionX))
        local clampedY = math.max(-maxY, math.min(maxY, ShouldIUlt.savedVars.positionY))


        if clampedX ~= ShouldIUlt.savedVars.positionX then
            ShouldIUlt.savedVars.positionX = clampedX
        end
        if clampedY ~= ShouldIUlt.savedVars.positionY then
            ShouldIUlt.savedVars.positionY = clampedY
        end

        container:ClearAnchors()
        container:SetAnchor(CENTER, GuiRoot, CENTER, clampedX, clampedY)
    end
end

function ShouldIUlt:UpdateUI()
    local container = BuffTrackerContainer
    if not container then
        return
    end


    if not ShouldIUlt.savedVars.uiVisible then
        container:SetHidden(true)
        return
    end

    container:SetHidden(false)
    local iconSize = ShouldIUlt.savedVars.iconSize
    local spacing = ShouldIUlt.savedVars.iconSpacing or 5
    local adjustedSpacing = math.max(1, math.floor(iconSize * 0.1))
    local layoutDirection = ShouldIUlt.savedVars.layoutDirection or "horizontal"

    -- Calculate layout dimensions based on direction
    local maxIcons = 14
    local cols, rows

    if layoutDirection == "horizontal" then
        cols = ShouldIUlt.savedVars.maxIconsPerRow or 7
        rows = math.ceil(maxIcons / cols)
    else -- vertical
        rows = ShouldIUlt.savedVars.maxIconsPerColumn or 7
        cols = math.ceil(maxIcons / rows)
    end

    -- Position icons based on layout
    for i = 1, maxIcons do
        local buffIcon = container:GetNamedChild("BuffIcon" .. i)
        if buffIcon then
            buffIcon:SetHidden(true)
            buffIcon:SetDimensions(iconSize, iconSize)

            local row, col
            if layoutDirection == "horizontal" then
                row = math.floor((i - 1) / cols)
                col = (i - 1) % cols
            else -- vertical
                col = math.floor((i - 1) / rows)
                row = (i - 1) % rows
            end

            local x = col * (iconSize + adjustedSpacing)
            local y = row * (iconSize + adjustedSpacing)

            buffIcon:ClearAnchors()
            buffIcon:SetAnchor(TOPLEFT, container, TOPLEFT, x, y)
        end
    end

    -- Update container dimensions
    local containerWidth = (cols * iconSize) + ((cols - 1) * adjustedSpacing)
    local containerHeight = (rows * iconSize) + ((rows - 1) * adjustedSpacing)
    container:SetDimensions(containerWidth, containerHeight)

    -- Get buffs to display
    local displayBuffs = self:GetDisplayBuffs()

    if ShouldIUlt.savedVars.staticContainer then
        self:UpdateStaticContainer(displayBuffs)
    else
        self:UpdateDynamicContainer(displayBuffs)
    end

    if self:CheckUltConditions() then
        self:ShowUltMessage()
    end
end

-- Static Container Mode
function ShouldIUlt:GetCachedStaticSlots()
    local settingsHash = ""
    for buffType, data in pairs(self.buffTypeMap) do
        if ShouldIUlt.savedVars[data.setting] then
            settingsHash = settingsHash .. buffType
        end
    end

    -- Add combined settings to hash
    if ShouldIUlt.savedVars.trackWeaponSpellDamage then
        settingsHash = settingsHash .. "weaponSpellDamage"
    end
    if ShouldIUlt.savedVars.trackWeaponSpellCrit then
        settingsHash = settingsHash .. "weaponSpellCrit"
    end

    -- Only regenerate if settings changed
    if not self.staticSlotsCache or self.lastStaticSettingsHash ~= settingsHash then
        self.staticSlotsCache = self:GetStaticBuffSlots()
        self.lastStaticSettingsHash = settingsHash
    end

    return self.staticSlotsCache
end

function ShouldIUlt:UpdateStaticContainer(activeBuffs)
    local container = BuffTrackerContainer
    if not container then return end

    -- Use cached slots instead of regenerating
    local staticSlots = self:GetCachedStaticSlots()
    local inactiveOpacity = ShouldIUlt.savedVars.inactiveBuffOpacity or 0.3

    -- Create optimized lookup tables for both regular buffs and immunity
    local activeBuffLookup = {}
    local hasOffBalanceImmunity = false

    for abilityId, buffInfo in pairs(activeBuffs) do
        if abilityId == 999999 and buffInfo.isImmunityTimer then
            -- Special handling for immunity timer
            hasOffBalanceImmunity = true
            activeBuffLookup["Off-Balance"] = buffInfo
        else
            local buffName = self:FindBuffNameInDatabase(abilityId)
            if buffName then
                activeBuffLookup[buffName] = buffInfo
            end
        end
    end

    local index = 1
    for _, slotInfo in ipairs(staticSlots) do
        local buffIcon = container:GetNamedChild("BuffIcon" .. index)
        if buffIcon then
            local iconControl = buffIcon:GetNamedChild("Icon")
            local timerLabel = buffIcon:GetNamedChild("Timer")
            local stackLabel = buffIcon:GetNamedChild("Stack")

            if iconControl then
                -- Only set icon texture if it changed (avoid redundant texture loads)
                local currentTexture = iconControl:GetTextureFileName()
                if currentTexture ~= slotInfo.iconPath then
                    iconControl:SetTexture(slotInfo.iconPath)
                end

                buffIcon:SetHidden(false)

                -- Determine if this buff is currently active
                local activeBuffInfo = activeBuffLookup[slotInfo.buffName]
                local isActive = (activeBuffInfo ~= nil)

                if isActive then
                    -- Buff is active - full opacity and special coloring
                    buffIcon:SetAlpha(1.0)

                    -- Color logic with immunity timer support
                    if activeBuffInfo.isOffBalanceImmunity or activeBuffInfo.isImmunityTimer then
                        iconControl:SetColor(1, 0.02, 0, 1)  -- Red for immunity
                    elseif activeBuffInfo.name == "Off-Balance" and not activeBuffInfo.isImmunityTimer then
                        iconControl:SetColor(0, 0.7, 0.5, 1) -- Green for active off-balance
                    else
                        iconControl:SetColor(1, 1, 1, 1)     -- Normal color
                    end

                    -- Timer display
                    if timerLabel and ShouldIUlt.savedVars.showTimer then
                        if activeBuffInfo.isPermanent then
                            timerLabel:SetText("")
                        else
                            local remainingTime = activeBuffInfo.endTime - GetGameTimeMilliseconds()
                            if remainingTime > 0 then
                                timerLabel:SetText(self:FormatTimerText(remainingTime))
                            else
                                timerLabel:SetText("")
                            end
                        end
                        timerLabel:SetHidden(false)
                    else
                        if timerLabel then timerLabel:SetHidden(true) end
                    end

                    -- Stack count display
                    if stackLabel and ShouldIUlt.savedVars.showStacks and activeBuffInfo.stackCount > 1 then
                        stackLabel:SetText(tostring(activeBuffInfo.stackCount))
                        stackLabel:SetHidden(false)
                    else
                        if stackLabel then stackLabel:SetHidden(true) end
                    end
                else
                    -- Buff is inactive - semi-transparent
                    buffIcon:SetAlpha(inactiveOpacity)
                    iconControl:SetColor(0.6, 0.6, 0.6, 1) -- Dimmed

                    -- Hide timer and stack for inactive buffs
                    if timerLabel then timerLabel:SetHidden(true) end
                    if stackLabel then stackLabel:SetHidden(true) end
                end

                index = index + 1
                if index > 14 then break end
            end
        end
    end

    -- Hide any remaining unused icons
    for i = index, 14 do
        local buffIcon = container:GetNamedChild("BuffIcon" .. i)
        if buffIcon then
            buffIcon:SetHidden(true)
        end
    end
end

function ShouldIUlt:GetStaticBuffSlots()
    local slots = {}
    local excludedBuffs = {}

    if ShouldIUlt.savedVars.hidePermanentBuffs then
        excludedBuffs["Minor Force"] = true
        excludedBuffs["Minor Slayer"] = true
    end

    -- Create slots for each enabled buff type with validation
    for buffType, data in pairs(self.buffTypeMap) do
        if ShouldIUlt.savedVars[data.setting] then
            -- Add major buff slot if it exists AND has valid icon AND is not excluded
            if data.major and not excludedBuffs[data.major] then
                local iconPath = self:GetBuffIcon(data.major, true) -- Suppress fallback
                if iconPath then                                    -- Only add slot if valid icon exists
                    table.insert(slots, {
                        buffName = data.major,
                        iconPath = iconPath,
                        buffType = buffType,
                        isMajor = true
                    })
                end
            end

            if data.minor and not excludedBuffs[data.minor] then
                local iconPath = self:GetBuffIcon(data.minor, true)
                if iconPath then
                    table.insert(slots, {
                        buffName = data.minor,
                        iconPath = iconPath,
                        buffType = buffType,
                        isMajor = false
                    })
                end
            end
        end
    end

    if ShouldIUlt.savedVars.trackWeaponSpellDamage then
        if not ShouldIUlt.savedVars.trackBrutality then
            if not excludedBuffs["Major Brutality"] then
                local majorIcon = self:GetBuffIcon("Major Brutality", true)
                if majorIcon then
                    table.insert(slots, {
                        buffName = "Major Brutality",
                        iconPath = majorIcon,
                        buffType = "brutality",
                        isMajor = true
                    })
                end
            end

            if not excludedBuffs["Minor Brutality"] then
                local minorIcon = self:GetBuffIcon("Minor Brutality", true)
                if minorIcon then
                    table.insert(slots, {
                        buffName = "Minor Brutality",
                        iconPath = minorIcon,
                        buffType = "brutality",
                        isMajor = false
                    })
                end
            end
        end

        if not ShouldIUlt.savedVars.trackSorcery then
            if not excludedBuffs["Major Sorcery"] then
                local majorIcon = self:GetBuffIcon("Major Sorcery", true)
                if majorIcon then
                    table.insert(slots, {
                        buffName = "Major Sorcery",
                        iconPath = majorIcon,
                        buffType = "sorcery",
                        isMajor = true
                    })
                end
            end

            if not excludedBuffs["Minor Sorcery"] then
                local minorIcon = self:GetBuffIcon("Minor Sorcery", true)
                if minorIcon then
                    table.insert(slots, {
                        buffName = "Minor Sorcery",
                        iconPath = minorIcon,
                        buffType = "sorcery",
                        isMajor = false
                    })
                end
            end
        end
    end

    if ShouldIUlt.savedVars.trackWeaponSpellCrit then
        if not ShouldIUlt.savedVars.trackProphecy then
            if not excludedBuffs["Major Prophecy"] then
                local majorIcon = self:GetBuffIcon("Major Prophecy", true)
                if majorIcon then
                    table.insert(slots, {
                        buffName = "Major Prophecy",
                        iconPath = majorIcon,
                        buffType = "prophecy",
                        isMajor = true
                    })
                end
            end

            if not excludedBuffs["Minor Prophecy"] then
                local minorIcon = self:GetBuffIcon("Minor Prophecy", true)
                if minorIcon then
                    table.insert(slots, {
                        buffName = "Minor Prophecy",
                        iconPath = minorIcon,
                        buffType = "prophecy",
                        isMajor = false
                    })
                end
            end
        end

        if not ShouldIUlt.savedVars.trackSavagery then
            if not excludedBuffs["Major Savagery"] then
                local majorIcon = self:GetBuffIcon("Major Savagery", true)
                if majorIcon then
                    table.insert(slots, {
                        buffName = "Major Savagery",
                        iconPath = majorIcon,
                        buffType = "savagery",
                        isMajor = true
                    })
                end
            end

            if not excludedBuffs["Minor Savagery"] then
                local minorIcon = self:GetBuffIcon("Minor Savagery", true)
                if minorIcon then
                    table.insert(slots, {
                        buffName = "Minor Savagery",
                        iconPath = minorIcon,
                        buffType = "savagery",
                        isMajor = false
                    })
                end
            end
        end
    end

    return slots
end

function ShouldIUlt:UpdateStaticTimersOnly()
    local container = BuffTrackerContainer
    local staticSlots = self:GetCachedStaticSlots()
    local displayBuffs = self:GetDisplayBuffs()

    -- Create lookup table for active buffs with immunity timer support
    local activeBuffLookup = {}
    for abilityId, buffInfo in pairs(displayBuffs) do
        if abilityId == 999999 and buffInfo.isImmunityTimer then
            -- Special handling for immunity timer
            activeBuffLookup["Off-Balance"] = buffInfo
        else
            local buffName = self:FindBuffNameInDatabase(abilityId)
            if buffName then
                activeBuffLookup[buffName] = buffInfo
            end
        end
    end

    for i, slotInfo in ipairs(staticSlots) do
        if i > 14 then break end

        local buffIcon = container:GetNamedChild("BuffIcon" .. i)
        if buffIcon and not buffIcon:IsHidden() then
            local timerLabel = buffIcon:GetNamedChild("Timer")

            if timerLabel and ShouldIUlt.savedVars.showTimer then
                local activeBuffInfo = activeBuffLookup[slotInfo.buffName]

                if activeBuffInfo and not activeBuffInfo.isPermanent then
                    local remainingTime = activeBuffInfo.endTime - GetGameTimeMilliseconds()
                    if remainingTime > 0 then
                        timerLabel:SetText(self:FormatTimerText(remainingTime))
                        timerLabel:SetHidden(false)
                    else
                        timerLabel:SetText("")
                        timerLabel:SetHidden(true)
                    end
                else
                    timerLabel:SetText("")
                    timerLabel:SetHidden(true)
                end
            end
        end
    end
end

-- Dynamic Conatiner Mode
function ShouldIUlt:UpdateDynamicContainer(displayBuffs)
    local container = BuffTrackerContainer
    if not container then return end

    -- Show active buffs
    local index = 1
    for abilityId, buffInfo in pairs(displayBuffs) do
        local buffIcon = container:GetNamedChild("BuffIcon" .. index)
        if buffIcon then
            local iconControl = buffIcon:GetNamedChild("Icon")
            local timerLabel = buffIcon:GetNamedChild("Timer")
            local stackLabel = buffIcon:GetNamedChild("Stack")

            if iconControl and buffInfo.iconName then
                iconControl:SetTexture(buffInfo.iconName)
                buffIcon:SetHidden(false)
                buffIcon:SetAlpha(1.0) -- Always full opacity in dynamic mode

                -- Color the icon based on buff type
                if buffInfo.isOffBalanceImmunity or buffInfo.isImmunityTimer then
                    iconControl:SetColor(1, 0.02, 0, 1)  -- Red for immunity
                elseif buffInfo.name == "Off-Balance" and not buffInfo.isImmunityTimer then
                    iconControl:SetColor(0, 0.7, 0.5, 1) -- Green for active off-balance
                else
                    iconControl:SetColor(1, 1, 1, 1)     -- Normal color
                end

                -- Timer display
                if timerLabel and ShouldIUlt.savedVars.showTimer then
                    if buffInfo.isPermanent then
                        timerLabel:SetText("")
                    else
                        local remainingTime = buffInfo.endTime - GetGameTimeMilliseconds()
                        if remainingTime > 0 then
                            timerLabel:SetText(self:FormatTimerText(remainingTime))
                        else
                            timerLabel:SetText("")
                        end
                    end
                    timerLabel:SetHidden(false)
                else
                    if timerLabel then timerLabel:SetHidden(true) end
                end

                -- Stack count display
                if stackLabel and ShouldIUlt.savedVars.showStacks and buffInfo.stackCount > 1 then
                    stackLabel:SetText(tostring(buffInfo.stackCount))
                    stackLabel:SetHidden(false)
                else
                    if stackLabel then stackLabel:SetHidden(true) end
                end

                index = index + 1
                if index > 14 then break end
            end
        end
    end

    -- Hide any remaining unused icons
    for i = index, 14 do
        local buffIcon = container:GetNamedChild("BuffIcon" .. i)
        if buffIcon then
            buffIcon:SetHidden(true)
        end
    end
end

function ShouldIUlt:UpdateDynamicTimersOnly()
    local container = BuffTrackerContainer
    local displayBuffs = self:GetDisplayBuffs()

    local index = 1
    for abilityId, buffInfo in pairs(displayBuffs) do
        if index > 14 then break end

        local buffIcon = container:GetNamedChild("BuffIcon" .. index)
        if buffIcon and not buffIcon:IsHidden() then
            local timerLabel = buffIcon:GetNamedChild("Timer")

            if timerLabel and ShouldIUlt.savedVars.showTimer then
                if buffInfo.isPermanent then
                    timerLabel:SetText("")
                    timerLabel:SetHidden(true)
                else
                    local remainingTime = buffInfo.endTime - GetGameTimeMilliseconds()
                    if remainingTime > 0 then
                        timerLabel:SetText(self:FormatTimerText(remainingTime))
                        timerLabel:SetHidden(false)
                    else
                        timerLabel:SetText("")
                        timerLabel:SetHidden(true)
                    end
                end
            end
        end
        index = index + 1
    end
end

function ShouldIUlt:OnUpdate()
    ShouldIUlt:UpdateUI()
end

function ShouldIUlt:UpdateTimersOnly()
    local container = BuffTrackerContainer
    if not container then return end

    if ShouldIUlt.savedVars.staticContainer then
        self:UpdateStaticTimersOnly()
    else
        self:UpdateDynamicTimersOnly()
    end
end

function ShouldIUlt:InitializePersistentDebuffTracking()
    -- Initialize persistent tracking timer that runs independently of target changes
    EVENT_MANAGER:RegisterForUpdate(ADDON_NAME .. "DebuffPersistence", 1000, function()
        self:UpdatePersistentDebuffs()
    end)
end

function ShouldIUlt:UpdatePersistentDebuffs()
    if not self.bossDebuffData then
        return
    end

    local currentTime = GetGameTimeMilliseconds()
    local expiredDebuffs = {}

    -- Check for expired debuffs
    for abilityId, debuffInfo in pairs(self.bossDebuffData) do
        if not debuffInfo.isPermanent and debuffInfo.endTime > 0 then
            if currentTime >= debuffInfo.endTime then
                table.insert(expiredDebuffs, abilityId)
            end
        end
    end

    -- Remove expired debuffs and trigger UI update if needed
    local needsUpdate = false
    for _, abilityId in ipairs(expiredDebuffs) do
        self.bossDebuffData[abilityId] = nil
        needsUpdate = true
    end

    if needsUpdate then
        -- Throttle UI updates
        if not self.pendingDebuffUpdate then
            self.pendingDebuffUpdate = true
            zo_callLater(function()
                self.pendingDebuffUpdate = false
                self:UpdateUI()
            end, 100)
        end
    end
end

function ShouldIUlt:Cleanup()
    EVENT_MANAGER:UnregisterForUpdate(ADDON_NAME .. "TimerUpdate")
    self:ClearOffBalanceImmunityTimer()
    self.buffData = {}
    if self.bossDebuffData then
        self.bossDebuffData = {}
    end
end

---=============================================================================
-- Debug Simulation
--=============================================================================
ShouldIUlt.lastUltNotification = nil
function ShouldIUlt:GetSimulatedBuffs()
    local currentTime = GetGameTimeMilliseconds()

    if not self.cachedSimulatedBuffs or (currentTime - self.simulationCacheTime) > 5000 then
        local simulatedBuffs = {}
        local buffsToSimulate = {}

        -- Simulate all buffs in the database
        if ShouldIUlt.savedVars.simulateAllTracked then
            for category, categoryData in pairs(self.buffDatabase) do
                if category == "bossDebuffs" then
                    for subcat, buffs in pairs(categoryData) do
                        for abilityId, name in pairs(buffs) do
                            if not buffsToSimulate[name] then
                                buffsToSimulate[name] = abilityId
                            end
                        end
                    end
                else
                    for abilityId, name in pairs(categoryData) do
                        if type(abilityId) == "number" and not buffsToSimulate[name] then
                            buffsToSimulate[name] = abilityId
                        end
                    end
                end
            end
        else
            -- Only simulate enabled buffs
            for buffType, data in pairs(self.buffTypeMap) do
                if ShouldIUlt.savedVars[data.setting] then
                    if data.major then buffsToSimulate[data.major] = true end
                    if data.minor then buffsToSimulate[data.minor] = true end
                end
            end

            -- Find IDs for enabled buffs
            local tempSimulate = {}
            for category, categoryData in pairs(self.buffDatabase) do
                if category == "bossDebuffs" then
                    for subcat, buffs in pairs(categoryData) do
                        for abilityId, name in pairs(buffs) do
                            if buffsToSimulate[name] and not tempSimulate[name] then
                                tempSimulate[name] = abilityId
                            end
                        end
                    end
                else
                    for abilityId, name in pairs(categoryData) do
                        if type(abilityId) == "number" and buffsToSimulate[name] and not tempSimulate[name] then
                            tempSimulate[name] = abilityId
                        end
                    end
                end
            end
            buffsToSimulate = tempSimulate
        end

        local index = 1
        for buffName, abilityId in pairs(buffsToSimulate) do
            local baseDuration
            if index <= 3 then
                baseDuration = 5000
            elseif index <= 6 then
                baseDuration = 1500
            else
                baseDuration = 6000
            end

            local isOffBalanceImmunity = (abilityId == 134599)
            local isPermanent = (index % 7 == 0)

            simulatedBuffs[abilityId] = {
                name = buffName,
                iconName = self:GetBuffIcon(buffName),
                endTime = isPermanent and currentTime or (currentTime + baseDuration),
                startTime = currentTime - 1000,
                stackCount = (buffName == "Major Slayer") and 5 or 1,
                duration = isPermanent and 0 or baseDuration,
                slot = index,
                simulated = true,
                isOffBalanceImmunity = isOffBalanceImmunity,
                isPermanent = isPermanent
            }
            index = index + 1
        end
        -- Cache the results
        self.cachedSimulatedBuffs = simulatedBuffs
        self.simulationCacheTime = currentTime
    else
        -- Update timestamps on cached buffs to keep timers working
        for abilityId, buffInfo in pairs(self.cachedSimulatedBuffs) do
            if not buffInfo.isPermanent then
                local originalDuration = buffInfo.duration
                buffInfo.startTime = currentTime - 1000
                buffInfo.endTime = currentTime + originalDuration - 1000
            end
        end
    end
    return self.cachedSimulatedBuffs
end

function ShouldIUlt:SetSimulationMode(value)
    ShouldIUlt.savedVars.simulationMode = value

    -- Clear cache when disabling simulation mode
    if not value then
        self.cachedSimulatedBuffs = nil
        self.simulationCacheTime = 0
    end

    ShouldIUlt:ScanCurrentBuffs()
    ShouldIUlt:UpdateUI()
end
