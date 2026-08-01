CritTracker = {}
local ADDON_NAME = "CritTracker"

CritTracker.savedVars = nil
CritTracker.playerDamage = 0
CritTracker.critCount = 0
CritTracker.normalCount = 0
CritTracker.totalCritDamage = 0
CritTracker.totalNormalDamage = 0
CritTracker.inCombat = false
CritTracker.delay = false
CritTracker.critMultiplier = 0
CritTracker.critDamagePercent = 0
CritTracker.fightCritCount = 0
CritTracker.fightNormalCount = 0
CritTracker.fightTotalCritDamage = 0
CritTracker.fightTotalNormalDamage = 0
CritTracker.fightMaxCrit = nil
CritTracker.lastDisplayUpdate = 0

-- Execute phase tracking
CritTracker.currentBossHealth = 100
CritTracker.inExecutePhase = false
CritTracker.executePhaseCritCount = 0
CritTracker.executePhaseNormalCount = 0
CritTracker.executePhaseTotalCritDamage = 0
CritTracker.executePhaseTotalNormalDamage = 0
CritTracker.discoveredBosses = {}
CritTracker.lastHealthCheck = 0
CritTracker.healthCheckInterval = 500

CritTracker.frontBarCritChance = 0
CritTracker.backBarCritChance = 0
CritTracker.currentActiveBar = 1
CritTracker.lastBarUpdate = 0
CritTracker.barUpdateInterval = 1000


CritTracker.lightAttackCritCount = 0
CritTracker.lightAttackNormalCount = 0
CritTracker.lightAttackTotalCritDamage = 0
CritTracker.lightAttackTotalNormalDamage = 0

CritTracker.abilityAndHeavyCritCount = 0
CritTracker.abilityAndHeavyNormalCount = 0
CritTracker.abilityAndHeavyTotalCritDamage = 0
CritTracker.abilityAndHeavyTotalNormalDamage = 0

-- Per-fight tracking for light attacks
CritTracker.fightLightAttackCritCount = 0
CritTracker.fightLightAttackNormalCount = 0
CritTracker.fightLightAttackTotalCritDamage = 0
CritTracker.fightLightAttackTotalNormalDamage = 0

-- Per-fight tracking for abilities and heavies
CritTracker.fightAbilityAndHeavyCritCount = 0
CritTracker.fightAbilityAndHeavyNormalCount = 0
CritTracker.fightAbilityAndHeavyTotalCritDamage = 0
CritTracker.fightAbilityAndHeavyTotalNormalDamage = 0


--=============================================================================
-- DIAL SYSTEM
--=============================================================================
CritTracker.dialContainer = nil
CritTracker.dial1 = nil
CritTracker.dial2 = nil

function CritTracker:InitializeDials()
    self.dialContainer = CritTracker_DialsContainer

    if not self.dialContainer then
        return
    end


    -- Initialize Dial 1
    self.dial1 = {
        container = CritTracker_DialsContainer_Dial1,
        label = CritTracker_DialsContainer_Dial1_Label,
        background = CritTracker_DialsContainer_Dial1_Background,
        cooldown = CritTracker_DialsContainer_Dial1_Cooldown,
        value = CritTracker_DialsContainer_Dial1_Value
    }

    -- Initialize Dial 2
    self.dial2 = {
        container = CritTracker_DialsContainer_Dial2,
        label = CritTracker_DialsContainer_Dial2_Label,
        background = CritTracker_DialsContainer_Dial2_Background,
        cooldown = CritTracker_DialsContainer_Dial2_Cooldown,
        value = CritTracker_DialsContainer_Dial2_Value
    }

    -- Verify controls exist
    if not self.dial1.container then
        return
    end
    if not self.dial2.container then
        return
    end


    -- Set up the cooldown controls with fill texture
    if self.dial1.cooldown then
        self.dial1.cooldown:SetTexture("/esoui/art/death/death_timer_fill.dds")
    end

    if self.dial2.cooldown then
        self.dial2.cooldown:SetTexture("/esoui/art/death/death_timer_fill.dds")
    end

    -- Set background colors (dark gray for visibility)
    if self.dial1.background then
        self.dial1.background:SetColor(0.2, 0.2, 0.2, 0.8)
    end

    if self.dial2.background then
        self.dial2.background:SetColor(0.2, 0.2, 0.2, 0.8)
    end

    -- Set default text colors
    if self.dial1.label then
        self.dial1.label:SetColor(1, 1, 1, 1)
    end
    if self.dial1.value then
        self.dial1.value:SetColor(1, 1, 1, 1)
    end
    if self.dial2.label then
        self.dial2.label:SetColor(1, 1, 1, 1)
    end
    if self.dial2.value then
        self.dial2.value:SetColor(1, 1, 1, 1)
    end

    -- Position dials based on settings
    self:UpdateDialPositions()
    self:UpdateDialScale()

    self:UpdateDialVisibility()
end

function CritTracker:UpdateDialPositions()
    if not self.dialContainer then return end

    local posX = self.savedVars.dialPosX or 0
    local posY = self.savedVars.dialPosY or 100

    self.dialContainer:ClearAnchors()
    self.dialContainer:SetAnchor(TOP, GuiRoot, TOP, posX, posY)
end

function CritTracker:UpdateDialVisibility()
    if not self.dialContainer then return end

    local showDials = self.savedVars.showDials
    local dial1Type = self.savedVars.dial1Type or "hidden"
    local dial2Type = self.savedVars.dial2Type or "hidden"

    -- Show/hide container
    self.dialContainer:SetHidden(not showDials)

    -- Show/hide individual dials
    if self.dial1 then
        self.dial1.container:SetHidden(dial1Type == "hidden")
    end
    if self.dial2 then
        self.dial2.container:SetHidden(dial2Type == "hidden")
    end

    -- Update dial spacing if only one is visible
    if self.dial1 and self.dial2 then
        if dial1Type == "hidden" and dial2Type ~= "hidden" then
            -- Center dial 2
            self.dial2.container:ClearAnchors()
            self.dial2.container:SetAnchor(CENTER, self.dialContainer, CENTER)
        elseif dial1Type ~= "hidden" and dial2Type == "hidden" then
            -- Center dial 1
            self.dial1.container:ClearAnchors()
            self.dial1.container:SetAnchor(CENTER, self.dialContainer, CENTER)
        else
            -- Both visible, restore default positions
            self.dial1.container:ClearAnchors()
            self.dial1.container:SetAnchor(LEFT, self.dialContainer, LEFT, 0, 0)
            self.dial2.container:ClearAnchors()
            self.dial2.container:SetAnchor(LEFT, self.dial1.container, RIGHT, 20, 0)
        end
    end
end

--=============================================================================
-- DIAL COLOR GRADIENTS
--=============================================================================
function CritTracker:GetDialColorForPercentage(normalizedValue, dialType)
    local color = self.savedVars.dialColor or { 1, 1, 1, 1 }

    if self.savedVars.dialUseGradient then
        -- Different scales for different dial types
        local adjustedValue = normalizedValue

        if dialType == "critDamage" or dialType == "executeCritDamage" then
            -- For crit damage: 125% is "perfect" (green)
            -- Scale: 0-50% = red, 50-125% = yellow to green
            adjustedValue = normalizedValue / 1.25 -- Normalize to 125% = 1.0
        elseif dialType == "critRate" or dialType == "executeCritRate" then
            -- For crit rate: 100% is perfect
            -- Already normalized correctly (0-100% maps to 0-1.0)
            adjustedValue = normalizedValue
        end

        -- Clamp to 0-1 range
        adjustedValue = math.max(0, math.min(1, adjustedValue))

        -- Generate gradient: red -> yellow -> green
        if adjustedValue < 0.5 then
            -- 0-50%: Red to Yellow
            color = { 1, adjustedValue * 2, 0, 1 }
        else
            -- 50-100%: Yellow to Green
            color = { 2 - (adjustedValue * 2), 1, 0, 1 }
        end
    end

    return color
end

function CritTracker:UpdateDial(dialNum, percentage, label, showLabel, dialType)
    local dial = dialNum == 1 and self.dial1 or self.dial2
    if not dial or not dial.cooldown then return end

    -- Clamp percentage for display text (uncapped — show the real number)
    percentage = math.max(0, percentage)

    -- Determine the fill cap: 155% with Above and Beyond passive, 100% otherwise
    local fillCap = (self.savedVars.aboveAndBeyond) and 155 or 125

    -- Update label
    if showLabel and label then
        dial.label:SetText(label)
        dial.label:SetHidden(false)
    else
        dial.label:SetHidden(true)
    end

    -- Update percentage text (always shows the real value)
    dial.value:SetText(string.format("%.1f%%", percentage))

    -- Normalize against the cap for color gradient and radial fill
    local normalized = math.min(percentage / fillCap, 1)

    -- Update color
    local color = self:GetDialColorForPercentage(normalized, dialType)
    dial.value:SetColor(color[1], color[2], color[3], color[4])
    dial.label:SetColor(color[1], color[2], color[3], color[4])

    -- Use a very long cooldown with the normalized fill as "time remaining"
    -- This creates a static radial fill scaled to the active cap
    local VERY_LONG_TIME = 999999999
    local timeRemaining = VERY_LONG_TIME * (1 - normalized)

    dial.cooldown:StartCooldown(timeRemaining, VERY_LONG_TIME, CD_TYPE_RADIAL, CD_TIME_TYPE_TIME_REMAINING,
        NO_LEADING_EDGE)
end

function CritTracker:UpdateDialColor(dialNum, normalizedValue)
    local dial = dialNum == 1 and self.dial1 or self.dial2
    if not dial or not dial.cooldown then return end

    local color = self.savedVars.dialColor or { 1, 1, 1, 1 }

    -- Optional: gradient color based on percentage
    if self.savedVars.dialUseGradient then
        -- Low = red, medium = yellow, high = green
        if normalizedValue < 0.5 then
            color = { 1, normalizedValue * 2, 0, 1 }
        else
            color = { 2 - (normalizedValue * 2), 1, 0, 1 }
        end
    end

    -- Apply color to the cooldown fill using SetFillColor
    if dial.cooldown.SetFillColor then
        dial.cooldown:SetFillColor(color[1], color[2], color[3], color[4])
    end

    -- Apply color to value text
    dial.value:SetColor(color[1], color[2], color[3], color[4])

    -- Apply color to label
    dial.label:SetColor(color[1], color[2], color[3], color[4])
end

function CritTracker:UpdateDialsDisplay()
    if not self.savedVars.showDials then return end

    local critRate
    local charSheetCritDamage
    local totalHits = self.critCount + self.normalCount

    if self.inCombat then
        critRate = totalHits > 0 and (self.critCount / totalHits) * 100 or 0
        charSheetCritDamage = nil
    elseif not self.inCombat and totalHits == 0 then
        critRate = self:GetCharSheetCritChance()
        charSheetCritDamage = self:GetCharSheetCritDamage()
    else
        -- out of combat but has hit data, keep showing combat results
        critRate = (self.critCount / totalHits) * 100
        charSheetCritDamage = nil
    end

    -- Update Dial 1
    local dial1Type = self.savedVars.dial1Type or "hidden"
    if dial1Type ~= "hidden" then
        local value1, label1 = self:GetDialValue(dial1Type, critRate, self:GetExecutePhaseCritRate(),
            self:GetExecutePhaseCritDamage(), charSheetCritDamage)
        self:UpdateDial(1, value1, label1, self.savedVars.dial1ShowLabel, dial1Type)
    end

    -- Update Dial 2
    local dial2Type = self.savedVars.dial2Type or "hidden"
    if dial2Type ~= "hidden" then
        local value2, label2 = self:GetDialValue(dial2Type, critRate, self:GetExecutePhaseCritRate(),
            self:GetExecutePhaseCritDamage(), charSheetCritDamage)
        self:UpdateDial(2, value2, label2, self.savedVars.dial2ShowLabel, dial2Type)
    end
end

function CritTracker:GetDialValue(dialType, critRate, executeCritRate, executeCritDamage)
    if dialType == "critRate" then
        return critRate, "RATE"
    elseif dialType == "critDamage" then
        return self.critDamagePercent, "DMG"
    elseif dialType == "executeCritRate" then
        if self.inExecutePhase then
            return executeCritRate, "EXE RATE"
        else
            return 0, "EXECUTE RATE"
        end
    elseif dialType == "executeCritDamage" then
        if self.inExecutePhase then
            return executeCritDamage, "EXE DMG"
        else
            return 0, "EXECUTE DMG"
        end
    end
    return 0, ""
end

--Captures base stats
--[[function CritTracker:GetDialValue(dialType, critRate, executeCritRate, executeCritDamage, charSheetCritDamage)
    if dialType == "critRate" then
        return critRate, "CRIT RATE"
    elseif dialType == "critDamage" then
        local value = charSheetCritDamage or self.critDamagePercent
        return value, "CRIT DAMAGE"
    elseif dialType == "executeCritRate" then
        if self.inCombat and self.inExecutePhase then
            return executeCritRate, "EXECUTE RATE"
        else
            return 0, "EXECUTE RATE"
        end
    elseif dialType == "executeCritDamage" then
        if self.inCombat and self.inExecutePhase then
            return executeCritDamage, "EXECUTE DMG"
        else
            return 0, "EXECUTE DMG"
        end
    end
    return 0, ""
end
--]]
function CritTracker:AnimateDials(fadeIn)
    if not self.dialContainer then return end

    -- Cancel existing timeline
    if self.dialFadeTimeline then
        self.dialFadeTimeline:Stop()
        self.dialFadeTimeline = nil
    end

    -- Create new timeline
    self.dialFadeTimeline = ANIMATION_MANAGER:CreateTimeline()

    local animation = self.dialFadeTimeline:InsertAnimation(ANIMATION_ALPHA, self.dialContainer)

    if fadeIn then
        self.dialContainer:SetHidden(false)
        animation:SetAlphaValues(0, 1)
    else
        animation:SetAlphaValues(self.dialContainer:GetAlpha(), 0)
    end

    animation:SetDuration(300)
    animation:SetEasingFunction(ZO_EaseInOutQuadratic)

    if not fadeIn then
        self.dialFadeTimeline:SetHandler("OnStop", function()
            self.dialContainer:SetHidden(true)
        end)
    end

    self.dialFadeTimeline:SetPlaybackType(ANIMATION_PLAYBACK_ONE_SHOT)
    self.dialFadeTimeline:PlayFromStart()
end

local defaults = {
    fontSize = 28,
    labelPosX = 560,
    labelPosY = 20,
    showNotifications = false,
    simpleMode = true,
    showCritDmg = true,
    uiVisible = true,
    showOnlyInDungeon = false,
    -- Font
    selectedFont = "ESO_Standard",
    fontScale = 1.0,
    showTextLines = true,

    -- Color
    critRateColor = { 1.0, 1.0, 1.0, 1.0 },
    critDamageColor = { 1.0, 0.8, 0.4, 1.0 },
    textColor = { 1.0, 1.0, 1.0, 1.0 },
    -- Execute phase tracking
    enableExecuteTracking = false,
    executeThreshold = 30.0,
    executePhaseColor = { 1.0, 0.2, 0.2, 1.0 },
    showExecutePhaseOnly = false,
    hideMainLinesInExecute = false,

    -- custom font string
    useCustomFormat = false,
    customFormatString = "<c> • Dmg: <d>",

    -- Dial settings
    aboveAndBeyond = false,
    showDials = false,
    dialPosX = 0,
    dialPosY = 100,
    dial1Type = "critRate",
    dial2Type = "critDamage",
    dial1ShowLabel = true,
    dial2ShowLabel = true,
    dialColor = { 1, 1, 1, 1 },
    dialUseGradient = false,
    dialLabelFontSize = 19, -- ADD
    dialValueFontSize = 26, -- ADD
    dialScale = 1.0,
}

--=============================================================================
-- BOSS HEALTH TRACKING
--=============================================================================
CritTracker.dummyUnitTag = nil

CritTracker.bossSpecificThresholds = {
    ["Jynorah and Skorkhif"] = 6000,
    ["Jynorah"] = 6000,
    ["Skorkhif"] = 6000,
    ["Lylanar and Turlassil"] = 6000,
    ["Lylanar"] = 6000,
    ["Turlassil"] = 6000,

}

-- Add this helper function
function CritTracker:ShouldIgnoreDamage(hitValue, targetName)
    -- Check if target is a discovered boss with a damage threshold
    for bossName, threshold in pairs(self.bossSpecificThresholds) do
        if self.discoveredBosses[bossName] or
            (targetName and string.lower(targetName):find(string.lower(bossName))) then
            if hitValue < threshold then
                return true
            end
        end
    end
    return false
end

function CritTracker:GetBossHealth()
    local bossUnitTags = { "boss1", "boss2", "boss3", "boss4", "boss5", "boss6" }
    local totalMaxHealth = 0
    local totalCurrentHealth = 0
    local lowestHealthPercent = 100
    local dummyFound = false
    local dummyUnitTags = { "reticleover", "boss1", "boss2", "boss3", "boss4", "boss5", "boss6" }

    for _, tag in ipairs(dummyUnitTags) do
        if DoesUnitExist(tag) and IsUnitAttackable(tag) then
            local unitName = GetUnitName(tag)
            if unitName and (
                    string.find(string.lower(unitName), "dummy") or
                    string.find(string.lower(unitName), "target") or
                    string.find(string.lower(unitName), "training") or
                    GetCurrentZoneHouseId() > 0 -- In houses, treat attackable units as dummies
                ) then
                -- Found a dummy, treat it like a boss
                self.dummyUnitTag = tag
                local current, max, effectiveMax = GetUnitPower(tag, COMBAT_MECHANIC_FLAGS_HEALTH)
                if max and max > 0 then
                    local dummyHealthPercent = (current / max) * 100
                    -- Add dummy to discovered "bosses" for consistent tracking
                    self.discoveredBosses[unitName] = {
                        unitTag = tag,
                        discovered = true,
                        maxHealth = max,
                        currentHealth = current
                    }
                    dummyFound = true
                    return dummyHealthPercent, current, max
                end
            end
        end
    end

    -- Find bosses
    if not dummyFound then
        self.dummyUnitTag = nil

        for _, tag in ipairs(bossUnitTags) do
            if DoesUnitExist(tag) and IsUnitAttackable(tag) then
                local bossName = GetUnitName(tag)
                if bossName and bossName ~= '' then
                    if not self.discoveredBosses[bossName] then
                        self.discoveredBosses[bossName] = {
                            unitTag = tag,
                            discovered = true
                        }
                    end
                end
            end
        end

        -- Get health data
        for bossName, bossData in pairs(self.discoveredBosses) do
            local tag = bossData.unitTag
            if tag and DoesUnitExist(tag) and IsUnitAttackable(tag) then
                local current, max, effectiveMax = GetUnitPower(tag, COMBAT_MECHANIC_FLAGS_HEALTH)
                if max and max > 0 then
                    bossData.maxHealth = max
                    bossData.currentHealth = current
                    totalMaxHealth = totalMaxHealth + max
                    totalCurrentHealth = totalCurrentHealth + current
                    local bossHealthPercent = (current / max) * 100
                    lowestHealthPercent = math.min(lowestHealthPercent, bossHealthPercent)
                end
            end
        end
    end
    return lowestHealthPercent, totalCurrentHealth, totalMaxHealth
end

function CritTracker:GetBossHealthPercentage()
    local currentTime = GetGameTimeMilliseconds()
    if currentTime - self.lastHealthCheck >= self.healthCheckInterval then
        local lowestPercent, currentHealth, maxHealth = self:GetBossHealth()
        self.lastHealthCheck = currentTime
        return lowestPercent
    end
    return self.currentBossHealth
end

function CritTracker:UpdateExecutePhaseStatus()
    if not self.savedVars.enableExecuteTracking then
        self.inExecutePhase = false
        return
    end

    if not self.inExecutePhase then
        local bossHealth = self:GetBossHealthPercentage()
        self.currentBossHealth = bossHealth

        if bossHealth <= self.savedVars.executeThreshold then
            self.inExecutePhase = true
            self.executePhaseCritCount = 0
            self.executePhaseNormalCount = 0
            self.executePhaseTotalCritDamage = 0
            self.executePhaseTotalNormalDamage = 0
        end
    end
end

--=============================================================================
-- EXECUTE PHASE TRACKING
--=============================================================================
function CritTracker:GetExecutePhaseText()
    if not self.savedVars.enableExecuteTracking or not self.inExecutePhase then
        return ""
    end
    return ""
end

function CritTracker:GetExecutePhaseCritRate()
    if not self.inExecutePhase then
        return 0
    end
    local totalExecuteHits = self.executePhaseCritCount + self.executePhaseNormalCount
    if totalExecuteHits == 0 then
        return 0
    end
    return (self.executePhaseCritCount / totalExecuteHits) * 100
end

function CritTracker:GetExecutePhaseCritDamage()
    if not self.inExecutePhase or self.executePhaseCritCount == 0 or self.executePhaseNormalCount == 0 then
        return 0
    end
    local avgExecuteCrit = self.executePhaseTotalCritDamage / self.executePhaseCritCount
    local avgExecuteNormal = self.executePhaseTotalNormalDamage / self.executePhaseNormalCount
    local executeMultiplier = avgExecuteNormal > 0 and (avgExecuteCrit / avgExecuteNormal) or 0
    return executeMultiplier > 0 and ((executeMultiplier - 1) * 100) or 0
end

--=============================================================================
-- GET STAT SHEET CRIT CHANCE
--=============================================================================
function CritTracker:OnActiveWeaponPairChanged(eventCode, activeWeaponPair, locked)
    -- Don't update if the weapon pair is locked (during switching animation)
    if locked then
        return
    end

    EVENT_MANAGER:RegisterForUpdate("CritTracker_AutoBarCapture", 250, function()
        EVENT_MANAGER:UnregisterForUpdate("CritTracker_AutoBarCapture")

        local currentBar = GetActiveWeaponPairInfo()
        if currentBar == activeWeaponPair then
            local capturedCrit = self:ForceBarCapture()
        end
    end)
end

function CritTracker:ForceBarCapture()
    local currentBar = GetActiveWeaponPairInfo()
    local currentCritChance = self:GetCharSheetCritChance()

    if currentBar == 1 then
        self.frontBarCritChance = currentCritChance
    elseif currentBar == 2 then
        self.backBarCritChance = currentCritChance
    end

    self.currentActiveBar = currentBar
    self:UpdateDisplay()

    return currentCritChance
end

function CritTracker:GetCharSheetCritDamage()
    local critDamageRating = GetPlayerStat(STAT_CRITICAL_CHANCE)
    return critDamageRating
end

function CritTracker:GetCharSheetCritChance()
    local critRating = GetPlayerStat(STAT_CRITICAL_STRIKE)
    local critChance = (critRating / 219)
    return math.min(critChance, 100)
end

function CritTracker:GetFormattedBarCritChances()
    -- Show current bar indicator if we have both bars captured
    local frontText = self.frontBarCritChance > 0 and string.format("%.1f%%", self.frontBarCritChance) or "-.-%"
    local backText = self.backBarCritChance > 0 and string.format("%.1f%%", self.backBarCritChance) or "-.-%"

    -- Add current bar indicator
    if self.currentActiveBar == 1 and self.frontBarCritChance > 0 then
        frontText = "[" .. frontText .. "]" -- Brackets around active bar
    elseif self.currentActiveBar == 2 and self.backBarCritChance > 0 then
        backText = "[" .. backText .. "]"   -- Brackets around active bar
    end

    return string.format("%s | %s", frontText, backText)
end

function CritTracker:ManualBarCapture()
    local currentBar = GetActiveWeaponPairInfo()
    local currentCritChance = self:GetCharSheetCritChance()

    if currentBar == 1 then
        self.frontBarCritChance = currentCritChance
    elseif currentBar == 2 then
        self.backBarCritChance = currentCritChance
    end

    self.currentActiveBar = currentBar
    self:UpdateDisplay()
end

--=============================================================================
-- PER COMBAT SUMMARY
--=============================================================================
function CritTracker:PrintCombatSummary()
    local totalHits = self.fightCritCount + self.fightNormalCount
    if totalHits > 0 then
        local critRate = (self.fightCritCount / totalHits) * 100

        -- Calculate weighted average crit damage
        local lightAttackAvgCrit = self.fightLightAttackCritCount > 0 and
            (self.fightLightAttackTotalCritDamage / self.fightLightAttackCritCount) or 0
        local lightAttackAvgNormal = self.fightLightAttackNormalCount > 0 and
            (self.fightLightAttackTotalNormalDamage / self.fightLightAttackNormalCount) or 0

        local abilityHeavyAvgCrit = self.fightAbilityAndHeavyCritCount > 0 and
            (self.fightAbilityAndHeavyTotalCritDamage / self.fightAbilityAndHeavyCritCount) or 0
        local abilityHeavyAvgNormal = self.fightAbilityAndHeavyNormalCount > 0 and
            (self.fightAbilityAndHeavyTotalNormalDamage / self.fightAbilityAndHeavyNormalCount) or 0

        -- Weighted average based on hit counts
        local totalCritHits = self.fightLightAttackCritCount + self.fightAbilityAndHeavyCritCount
        local totalNormalHits = self.fightLightAttackNormalCount + self.fightAbilityAndHeavyNormalCount

        local avgCrit = 0
        local avgNormal = 0

        if totalCritHits > 0 then
            avgCrit = ((lightAttackAvgCrit * self.fightLightAttackCritCount) +
                (abilityHeavyAvgCrit * self.fightAbilityAndHeavyCritCount)) / totalCritHits
        end

        if totalNormalHits > 0 then
            avgNormal = ((lightAttackAvgNormal * self.fightLightAttackNormalCount) +
                (abilityHeavyAvgNormal * self.fightAbilityAndHeavyNormalCount)) / totalNormalHits
        end

        local currentMultiplier = avgNormal > 0 and (avgCrit / avgNormal) or 0
        local currentCritDamagePercent = currentMultiplier > 0 and ((currentMultiplier - 1) * 100) or 0

        self:DebugPrint("==Combat Summary==")
        self:DebugPrint(string.format("Total Hits: %d (%d crits, %d normal)", totalHits, self.fightCritCount,
            self.fightNormalCount))

        if self.fightMaxCrit then
            self.fightMaxCrit = math.max(self.fightMaxCrit, critRate)
            self:DebugPrint(string.format("Crit Rate: %.1f%% (Max: %.1f%%)", critRate, self.fightMaxCrit))
        else
            self:DebugPrint(string.format("Crit Rate: %.1f%%", critRate))
        end

        self:DebugPrint(string.format("Avg Crit DMG: %.0f crit, %.0f normal (+%.0f%% / %.2fx)", avgCrit, avgNormal,
            currentCritDamagePercent, currentMultiplier))

        if self.savedVars.enableExecuteTracking then
            local executeHits = self.executePhaseCritCount + self.executePhaseNormalCount
            if executeHits > 0 then
                local executeCritRate = (self.executePhaseCritCount / executeHits) * 100
                local avgExecuteCrit = self.executePhaseCritCount > 0 and
                    (self.executePhaseTotalCritDamage / self.executePhaseCritCount) or 0
                local avgExecuteNormal = self.executePhaseNormalCount > 0 and
                    (self.executePhaseTotalNormalDamage / self.executePhaseNormalCount) or 0
                local executeMultiplier = avgExecuteNormal > 0 and (avgExecuteCrit / avgExecuteNormal) or 0
                local executeCritDamagePercent = executeMultiplier > 0 and ((executeMultiplier - 1) * 100) or 0

                self:DebugPrint(string.format("Execute Phase: %.1f%% crit (%d/%d hits)", executeCritRate,
                    self.executePhaseCritCount, executeHits))
                if executeCritDamagePercent > 0 then
                    self:DebugPrint(string.format("Execute Crit DMG: %.0f crit, %.0f normal (+%.0f%% / %.2fx)",
                        avgExecuteCrit, avgExecuteNormal, executeCritDamagePercent, executeMultiplier))
                end
            end
        end
    end
end

--=============================================================================
-- RESET VARIABLES
--=============================================================================
function CritTracker:OnCombatStateChanged(inCombat)
    if inCombat then
        self.inCombat = true
        self.fightCritCount = 0
        self.fightNormalCount = 0
        self.fightTotalCritDamage = 0
        self.fightTotalNormalDamage = 0
        self.fightMaxCrit = nil
        self.fightMeanCrit = nil

        -- Reset light attack tracking
        self.fightLightAttackCritCount = 0
        self.fightLightAttackNormalCount = 0
        self.fightLightAttackTotalCritDamage = 0
        self.fightLightAttackTotalNormalDamage = 0

        -- Reset ability/heavy tracking
        self.fightAbilityAndHeavyCritCount = 0
        self.fightAbilityAndHeavyNormalCount = 0
        self.fightAbilityAndHeavyTotalCritDamage = 0
        self.fightAbilityAndHeavyTotalNormalDamage = 0

        -- Reset execute phase stats
        self.executePhaseCritCount = 0
        self.executePhaseNormalCount = 0
        self.executePhaseTotalCritDamage = 0
        self.executePhaseTotalNormalDamage = 0

        -- Reset boss discovery
        self.discoveredBosses = {}
    else
        self.inCombat = false

        -- Show summary only at end
        if self.savedVars.showNotifications then
            self:PrintCombatSummary()
        end

        -- Delay to let buffs expire before reading character sheet
        self.delay = true
        zo_callLater(function()
            self.delay = false
            self:UpdateDisplay()
        end, 7000)
    end
end

--=============================================================================
-- TRACK PLAYER DAMAGE
--=============================================================================
function CritTracker:OnCombatEvent(eventCode, result, isError, abilityName, abilityGraphic,
                                   abilityActionSlotType,
                                   sourceName, sourceType, targetName, targetType,
                                   hitValue, powerType, damageType, combatMechanic,
                                   sourceUnitId, targetUnitId, abilityId, overflow)
    -- Handle dummy detection
    if sourceType == COMBAT_UNIT_TYPE_PLAYER and targetType == COMBAT_UNIT_TYPE_TARGET_DUMMY then
        if not self.dummyUnitTag then
            local dummyTags = { "reticleover", "boss1", "boss2", "boss3", "boss4", "boss5", "boss6" }
            for _, tag in ipairs(dummyTags) do
                if DoesUnitExist(tag) and IsUnitAttackable(tag) and GetUnitName(tag) == targetName then
                    self.dummyUnitTag = tag
                    self.discoveredBosses[targetName] = {
                        unitTag = tag,
                        discovered = true
                    }
                    break
                end
            end
        end
    end

    -- Only track player damage
    if sourceType ~= COMBAT_UNIT_TYPE_PLAYER or hitValue <= 1 then
        return
    end

    -- Ignore shielded damage
    if result == ACTION_RESULT_DAMAGE_SHIELDED then
        return
    end

    -- Determine if this is a light attack or heavy attack
    local isLightAttack = (abilityActionSlotType == ACTION_SLOT_TYPE_LIGHT_ATTACK)
    local isHeavyAttack = (abilityActionSlotType == ACTION_SLOT_TYPE_HEAVY_ATTACK)

    if isLightAttack or isHeavyAttack then
        return
    end

    -- Boss-specific damage filtering
    if self:ShouldIgnoreDamage(hitValue, targetName) then
        return
    end

    -- Track damage
    self.playerDamage = self.playerDamage + hitValue


    if result == ACTION_RESULT_CRITICAL_DAMAGE or result == ACTION_RESULT_DOT_TICK_CRITICAL then
        -- Ability crit tracking
        self.abilityAndHeavyCritCount = self.abilityAndHeavyCritCount + 1
        self.abilityAndHeavyTotalCritDamage = self.abilityAndHeavyTotalCritDamage + hitValue
        self.fightAbilityAndHeavyCritCount = self.fightAbilityAndHeavyCritCount + 1
        self.fightAbilityAndHeavyTotalCritDamage = self.fightAbilityAndHeavyTotalCritDamage + hitValue

        -- Overall tracking
        self.critCount = self.critCount + 1
        self.totalCritDamage = self.totalCritDamage + hitValue
        self.fightCritCount = self.fightCritCount + 1
        self.fightTotalCritDamage = self.fightTotalCritDamage + hitValue

        -- Track execute phase crits
        if self.inExecutePhase then
            self.executePhaseCritCount = self.executePhaseCritCount + 1
            self.executePhaseTotalCritDamage = self.executePhaseTotalCritDamage + hitValue
        end

        -- Process normal hits
    elseif result == ACTION_RESULT_DAMAGE or result == ACTION_RESULT_DOT_TICK then
        -- Ability normal tracking
        self.abilityAndHeavyNormalCount = self.abilityAndHeavyNormalCount + 1
        self.abilityAndHeavyTotalNormalDamage = self.abilityAndHeavyTotalNormalDamage + hitValue
        self.fightAbilityAndHeavyNormalCount = self.fightAbilityAndHeavyNormalCount + 1
        self.fightAbilityAndHeavyTotalNormalDamage = self.fightAbilityAndHeavyTotalNormalDamage + hitValue

        -- Overall tracking
        self.normalCount = self.normalCount + 1
        self.totalNormalDamage = self.totalNormalDamage + hitValue
        self.fightNormalCount = self.fightNormalCount + 1
        self.fightTotalNormalDamage = self.fightTotalNormalDamage + hitValue

        -- Track execute phase normal hits
        if self.inExecutePhase then
            self.executePhaseNormalCount = self.executePhaseNormalCount + 1
            self.executePhaseTotalNormalDamage = self.executePhaseTotalNormalDamage + hitValue
        end
    end

    if self.inCombat and not self.delay then
        self:UpdateExecutePhaseStatus()

        -- Throttle updates to reduce flickering
        local currentTime = GetGameTimeMilliseconds()
        if not self.lastDisplayUpdate or (currentTime - self.lastDisplayUpdate) >= 500 then
            self.lastDisplayUpdate = currentTime
            self:UpdateDisplay()
        end
    end
end

--=============================================================================
-- UPDATE DISPLAY
--=============================================================================
function CritTracker:UpdateTrackerVisibility()
    local labels = self:GetLabels()
    local shouldShow = self.savedVars.uiVisible

    if self.savedVars.showOnlyInDungeon then
        shouldShow = shouldShow and IsUnitInDungeon("player")
    end

    -- Handle text labels
    if self.savedVars.showTextLines then
        if shouldShow then
            for i, label in ipairs(labels) do
                if label then
                    label:SetHidden(false)
                    label:SetAlpha(0)
                end
            end
            self:AnimateLabels(true)
            self:UpdateDisplay()
        else
            self:AnimateLabels(false)
        end
    else
        -- Hide labels if text lines are disabled
        for i, label in ipairs(labels) do
            if label then
                label:SetHidden(true)
            end
        end
    end

    -- Handle dials
    if self.savedVars.showDials then
        if shouldShow then
            self:AnimateDials(true)
            self:UpdateDialsDisplay()
        else
            self:AnimateDials(false)
        end
    end
end

function CritTracker:ParseCustomFormat(formatString, critRate, critDamage)
    if not formatString then
        return ""
    end

    local critRateHex = self:ColorToHex(self.savedVars.critRateColor)
    local critDamageHex = self:ColorToHex(self.savedVars.critDamageColor)
    local textColorHex = self:ColorToHex(self.savedVars.textColor)

    -- Replace <c> with a placeholder to protect it during color wrapping
    local result = string.gsub(formatString, "<c>", "<<<CRIT_RATE>>>")
    result = string.gsub(result, "<d>", "<<<CRIT_DAMAGE>>>")

    -- Wrap entire string in text color
    result = "|c" .. textColorHex .. result .. "|r"

    -- Now replace placeholders with colored values (including % in the same color)
    -- Use string.format directly with the values instead of placeholders
    local critRateText = string.format("|r|c%s%.1f%%%%|r|c%s", critRateHex, critRate, textColorHex)
    local critDamageText = string.format("|r|c%s%.0f%%%%|r|c%s", critDamageHex, critDamage, textColorHex)

    result = string.gsub(result, "<<<CRIT_RATE>>>", critRateText)
    result = string.gsub(result, "<<<CRIT_DAMAGE>>>", critDamageText)

    return result
end

function CritTracker:UpdateDisplay()
    -- Determine which display modes are active
    local updateTextDisplay = self.savedVars.showTextLines and self.savedVars.uiVisible and
        (not self.savedVars.showOnlyInDungeon or (self.savedVars.showOnlyInDungeon and IsUnitInDungeon("player")))
    local updateDialDisplay = self.savedVars.showDials

    -- Clear text labels if text display is disabled
    if not updateTextDisplay then
        self:ClearLabels()
    end

    -- If neither is active, skip update
    if not updateTextDisplay and not updateDialDisplay then
        return
    end

    local totalHits = self.critCount + self.normalCount
    local charSheet = self:GetCharSheetCritChance()

    -- Check to only show during execute phase
    if self.savedVars.showExecutePhaseOnly and not self.inExecutePhase then
        if updateTextDisplay then
            line1_CritInfo:SetText("")
            line2_CritDamage:SetText("")
            line3_ExecutePhase:SetText("")
        end
        if updateDialDisplay then
            self:UpdateDialsDisplay()
        end
        return
    end

    -- Check to hide main lines during execute phase
    if self.savedVars.hideMainLinesInExecute and self.inExecutePhase then
        if updateTextDisplay then
            line1_CritInfo:SetText("")
            line2_CritDamage:SetText("")
            -- Only show execute phase line
            if self.savedVars.enableExecuteTracking then
                local executeHits = self.executePhaseCritCount + self.executePhaseNormalCount
                if executeHits > 0 then
                    local executeCritRate = self:GetExecutePhaseCritRate()
                    local executeCritDamage = self:GetExecutePhaseCritDamage()

                    local executeText = string.format("Execute: %.1f%%", executeCritRate)
                    if self.savedVars.showCritDmg then
                        local executeHex = self:ColorToHex(self.savedVars.executePhaseColor)
                        local critDamageHex = self:ColorToHex(self.savedVars.critDamageColor)

                        executeText = string.format("Exe: |c%s%.1f%%|r • Dmg: %.0f%%|r",
                            executeHex, executeCritRate, executeCritDamage)
                    end
                    line3_ExecutePhase:SetText(executeText)
                else
                    line3_ExecutePhase:SetText("")
                end
            else
                line3_ExecutePhase:SetText("")
            end

            -- Apply execute color to the execute line
            local executeColor = self.savedVars.executePhaseColor
            line3_ExecutePhase:SetColor(executeColor[1], executeColor[2], executeColor[3], executeColor[4])
        end

        if updateDialDisplay then
            self:UpdateDialsDisplay()
        end
        return
    end

    if totalHits == 0 then
        -- Show stat sheet info when no combat data
        if updateTextDisplay then
            if self.savedVars.simpleMode then
                local line1Text = string.format("%.1f%%", charSheet)
                line1_CritInfo:SetText(line1Text)
                line2_CritDamage:SetText("")
                line3_ExecutePhase:SetText("")
            else
                local barCritText = self:GetFormattedBarCritChances()
                local line1Text = string.format("Effective: %.1f%% • Base: %s", charSheet, barCritText)
                line1_CritInfo:SetText(line1Text)
                line2_CritDamage:SetText("")
                line3_ExecutePhase:SetText("")
            end
        end

        if updateDialDisplay then
            self:UpdateDialsDisplay()
        end
        return
    end

    -- Calculate normal combat stats
    local lightAttackAvgCrit = self.lightAttackCritCount > 0 and
        (self.lightAttackTotalCritDamage / self.lightAttackCritCount) or 0
    local lightAttackAvgNormal = self.lightAttackNormalCount > 0 and
        (self.lightAttackTotalNormalDamage / self.lightAttackNormalCount) or 0

    local abilityHeavyAvgCrit = self.abilityAndHeavyCritCount > 0 and
        (self.abilityAndHeavyTotalCritDamage / self.abilityAndHeavyCritCount) or 0
    local abilityHeavyAvgNormal = self.abilityAndHeavyNormalCount > 0 and
        (self.abilityAndHeavyTotalNormalDamage / self.abilityAndHeavyNormalCount) or 0

    -- Weighted average based on hit counts
    local totalCritHits = self.lightAttackCritCount + self.abilityAndHeavyCritCount
    local totalNormalHits = self.lightAttackNormalCount + self.abilityAndHeavyNormalCount

    local avgCritDamage = 0
    local avgNormalDamage = 0

    if totalCritHits > 0 then
        avgCritDamage = ((lightAttackAvgCrit * self.lightAttackCritCount) +
            (abilityHeavyAvgCrit * self.abilityAndHeavyCritCount)) / totalCritHits
    end

    if totalNormalHits > 0 then
        avgNormalDamage = ((lightAttackAvgNormal * self.lightAttackNormalCount) +
            (abilityHeavyAvgNormal * self.abilityAndHeavyNormalCount)) / totalNormalHits
    end

    -- Calculate normal combat stats
    local critRate = (self.critCount / totalHits) * 100
    self.critMultiplier = avgNormalDamage > 0 and (avgCritDamage / avgNormalDamage) or 0
    self.critDamagePercent = self.critMultiplier > 0 and ((self.critMultiplier - 1) * 100) or 0

    -- Calculate execute phase stats
    local executeCritRate = self:GetExecutePhaseCritRate()
    local executeCritDamage = self:GetExecutePhaseCritDamage()

    if totalHits >= 4 then
        if not self.fightMaxCrit or critRate > self.fightMaxCrit then
            self.fightMaxCrit = critRate
        end
    end

    -- Get execute phase text for main display
    local executePhaseText = self:GetExecutePhaseText()

    -- Update text display if active
    if updateTextDisplay then
        -- Simple Mode
        if self.savedVars.simpleMode then
            local line1Text = ""

            if self.savedVars.useCustomFormat then
                -- Use custom format
                line1Text = self:ParseCustomFormat(self.savedVars.customFormatString, critRate, self.critDamagePercent)
            else
                -- Use default format
                line1Text = string.format("%.1f%%", critRate)
                if self.savedVars.showCritDmg then
                    local critRateHex = self:ColorToHex(self.savedVars.critRateColor)
                    local critDamageHex = self:ColorToHex(self.savedVars.critDamageColor)

                    line1Text = string.format("%.1f%% • |c%sDmg: %.0f%%|r",
                        critRate, critDamageHex, self.critDamagePercent)
                end
            end

            line1Text = line1Text .. executePhaseText
            line1_CritInfo:SetText(line1Text)
            line2_CritDamage:SetText("")

            -- Execute phase line
            if self.savedVars.enableExecuteTracking and self.inExecutePhase then
                local executeHits = self.executePhaseCritCount + self.executePhaseNormalCount
                if executeHits > 0 then
                    local executeText = string.format("Exe: %.1f%%", executeCritRate)
                    if self.savedVars.showCritDmg then
                        local executeHex = self:ColorToHex(self.savedVars.executePhaseColor)
                        local critDamageHex = self:ColorToHex(self.savedVars.critDamageColor)

                        executeText = string.format("Exe: |c%s%.1f%%|r • Dmg: %.0f%%|r",
                            executeHex, executeCritRate, executeCritDamage)
                    end
                    line3_ExecutePhase:SetText(executeText)
                end
            else
                line3_ExecutePhase:SetText("")
            end
        else
            local barCritText = self:GetFormattedBarCritChances()
            local line1Text = string.format("Effective: %.1f%% • Base: %s", critRate, barCritText)
            local line2Text = ""
            if self.savedVars.showCritDmg then
                line2Text = string.format("Average Crit Damage: %.0f%%", self.critDamagePercent)
            end
            line1_CritInfo:SetText(line1Text)
            line2_CritDamage:SetText(line2Text)

            -- Verbose execute phase
            if self.savedVars.enableExecuteTracking then
                if self.inExecutePhase then
                    local executeHits = self.executePhaseCritCount + self.executePhaseNormalCount
                    if executeHits > 0 then
                        local executeText = string.format("Execute Phase: %.1f%% crit", executeCritRate)
                        if self.savedVars.showCritDmg and executeCritDamage > 0 then
                            executeText = executeText .. string.format(" • %.0f%% dmg", executeCritDamage)
                        end
                        line3_ExecutePhase:SetText(executeText)
                    else
                        line3_ExecutePhase:SetText("")
                    end
                else
                    line3_ExecutePhase:SetText("")
                end
            else
                line3_ExecutePhase:SetText("")
            end
        end

        -- Apply colors
        self:ApplyColorsToLabels()

        -- Apply execute color only to the execute line (line3) when in execute phase
        if self.inExecutePhase and self.savedVars.enableExecuteTracking then
            local executeColor = self.savedVars.executePhaseColor
            line3_ExecutePhase:SetColor(executeColor[1], executeColor[2], executeColor[3], executeColor[4])
        else
            -- Reset execute line color when not in execute phase
            local defaultColor = self.savedVars.critRateColor
            line3_ExecutePhase:SetColor(defaultColor[1], defaultColor[2], defaultColor[3], defaultColor[4])
        end
    end

    -- Update dial display if active
    if updateDialDisplay then
        self:UpdateDialsDisplay()
    end
end

function CritTracker:UpdateDialScale()
    if not self.dialContainer then return end
    local scale = self.savedVars.dialScale or 1.0
    self.dialContainer:SetScale(scale)
end

--=============================================================================
-- FONTS
--=============================================================================
local fontBook = {
    ["ESO_Standard"] = {
        name = "Standard",
        path = nil,
        description = "Default ESO font"
    },
    ["ESO_Bold"] = {
        name = "Bold",
        path = "$(BOLD_FONT)|%d|soft-shadow-thick",
        description = "Bold ESO font"
    },
    ["Handwritten"] = {
        name = "Handwritten",
        path = "EsoUI/Common/Fonts/ProseAntiquePSMT.slug|%d|soft-shadow-thick",
        description = "Handwritten-style font"
    },
    ["Futura"] = {
        name = "Condensed",
        path = "EsoUI/Common/Fonts/FuturaStd-CondensedLight.slug|%d|soft-shadow-thin",
        description = "Clean, modern font"
    },
    ["Trajan"] = {
        name = "Tablet",
        path = "EsoUI/Common/Fonts/TrajanPro-Regular.slug|%d|soft-shadow-thick",
        description = "Classical, carved stone appearance"
    }
}

function CritTracker:GetFontChoices()
    local choices = {}
    local choicesValues = {}

    for fontId, fontData in pairs(fontBook) do
        table.insert(choices, fontData.name)
        table.insert(choicesValues, fontId)
    end

    return choices, choicesValues
end

function CritTracker:GetCurrentFont()
    local fontData = fontBook[self.savedVars.selectedFont]
    if fontData then
        return fontData.path
    end
    return fontBook["ESO_Standard"].path -- fallback
end

function CritTracker:BuildFontString(sizeOverride)
    local selectedFont = self.savedVars and self.savedVars.selectedFont or "ESO_Standard"
    local fontSize = sizeOverride or (self.savedVars and self.savedVars.fontSize) or 28
    local fontScale = self.savedVars and self.savedVars.fontScale or 1.0

    fontSize = tonumber(fontSize) or 28
    fontScale = tonumber(fontScale) or 1.0

    local finalSize = math.floor(fontSize * fontScale)

    if selectedFont == "ESO_Standard" then
        return string.format("$(CHAT_FONT)|%d|soft-shadow-thick", finalSize)
    else
        local fontData = fontBook[selectedFont]
        if fontData and fontData.path then
            return string.format(fontData.path, finalSize)
        else
            return string.format("$(CHAT_FONT)|%d|soft-shadow-thick", finalSize)
        end
    end
end

function CritTracker:ApplyFontsToLabels()
    local fontString = self:BuildFontString()
    local labels = self:GetLabels()

    for i, label in ipairs(labels) do
        if label then
            label:SetFont(fontString)
        end
    end

    -- Dial labels and values get their own independent sizes
    local labelSize = self.savedVars and self.savedVars.dialLabelFontSize or 14
    local valueSize = self.savedVars and self.savedVars.dialValueFontSize or 24
    local dialLabelFont = self:BuildFontString(labelSize)
    local dialValueFont = self:BuildFontString(valueSize)

    local dialLabels = {
        self.dial1 and self.dial1.label,
        self.dial2 and self.dial2.label,
    }
    local dialValues = {
        self.dial1 and self.dial1.value,
        self.dial2 and self.dial2.value,
    }

    for _, control in ipairs(dialLabels) do
        if control then control:SetFont(dialLabelFont) end
    end
    for _, control in ipairs(dialValues) do
        if control then control:SetFont(dialValueFont) end
    end
end

function CritTracker:UpdateTextSize(size)
    size = math.max(10, math.min(48, tonumber(size) or 28))
    self.savedVars.fontSize = size
    self:ApplyFontsToLabels()
    self:UpdateLabelSettings()
end

--=============================================================================
-- COLOR
--=============================================================================
function CritTracker:ColorToHex(colorTable)
    local r = math.floor(colorTable[1] * 255)
    local g = math.floor(colorTable[2] * 255)
    local b = math.floor(colorTable[3] * 255)
    return string.format("%02X%02X%02X", r, g, b)
end

function CritTracker:ApplyColorsToLabels()
    local labels = self:GetLabels()

    if labels[1] then -- crit rate label
        -- Add safety checks for color array
        local color = (self.savedVars and self.savedVars.critRateColor) or { 1.0, 1.0, 1.0, 1.0 }
        -- Ensure color is a valid array with 4 elements
        if type(color) == "table" and #color >= 4 then
            labels[1]:SetColor(color[1] or 1.0, color[2] or 1.0, color[3] or 1.0, color[4] or 1.0)
        else
            -- Fallback to white if color is invalid
            labels[1]:SetColor(1.0, 1.0, 1.0, 1.0)
        end
    end

    if labels[2] then -- crit damage label
        -- Add safety checks for color array
        local color = (self.savedVars and self.savedVars.critDamageColor) or { 1.0, 0.8, 0.4, 1.0 }
        -- Ensure color is a valid array with 4 elements
        if type(color) == "table" and #color >= 4 then
            labels[2]:SetColor(color[1] or 1.0, color[2] or 0.8, color[3] or 0.4, color[4] or 1.0)
        else
            -- Fallback to orange if color is invalid
            labels[2]:SetColor(1.0, 0.8, 0.4, 1.0)
        end
    end
end

--=============================================================================
-- UI MANAGEMENT
--=============================================================================
function CritTracker:GetLabels()
    return {
        _G["line1_CritInfo"],
        _G["line2_CritDamage"],
        _G["line3_ExecutePhase"]
    }
end

function CritTracker:UpdateLabelSettings()
    -- Add safety checks for nil values
    local fontSize = (self.savedVars and tonumber(self.savedVars.fontSize)) or 24
    local fontScale = (self.savedVars and tonumber(self.savedVars.fontScale)) or 1.0
    local posX = (self.savedVars and tonumber(self.savedVars.labelPosX)) or 560
    local posY = (self.savedVars and tonumber(self.savedVars.labelPosY)) or 60
    local labels = self:GetLabels()

    local finalFontSize = math.floor(fontSize * fontScale)
    local proportionalSpacing = math.max(finalFontSize * 0.8, 5)

    for i, label in ipairs(labels) do
        if label then
            local fontString = self:BuildFontString()
            label:SetFont(fontString)
            label:ClearAnchors()
            local yOffset = posY + (i - 1) * proportionalSpacing
            label:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, posX, yOffset)
        end
    end

    self:ApplyColorsToLabels()
end

function CritTracker:ClearLabels()
    local labels = self:GetLabels()
    for i, label in ipairs(labels) do
        if label then
            label:SetText("")
        end
    end
end

--=============================================================================
-- FADE ANIMATION
--=============================================================================
function CritTracker:ShouldShowTracker()
    local setting = self.savedVars.showOnlyInCombat

    if setting == "always" then
        return true
    elseif setting == "combat" then
        return self.inCombat
    elseif setting == "dungeon" then
        return IsUnitInDungeon("player")
    end

    return true -- Default to visible
end

function CritTracker:AnimateLabels(fadeIn)
    local labels = self:GetLabels()

    -- Cancel any existing timeline
    if self.fadeTimeline then
        self.fadeTimeline:Stop()
        self.fadeTimeline = nil
    end

    -- Create new timeline
    self.fadeTimeline = ANIMATION_MANAGER:CreateTimeline()

    for i, label in ipairs(labels) do
        if label and not label:IsHidden() then
            local animation = self.fadeTimeline:InsertAnimation(ANIMATION_ALPHA, label)

            if fadeIn then
                animation:SetAlphaValues(0, 1)
            else
                animation:SetAlphaValues(label:GetAlpha(), 0)
            end

            animation:SetDuration(300) -- 300ms fade
            animation:SetEasingFunction(ZO_EaseInOutQuadratic)
        end
    end

    -- If fading out, hide labels after animation completes
    if not fadeIn then
        self.fadeTimeline:SetHandler("OnStop", function()
            for i, label in ipairs(labels) do
                if label then
                    label:SetHidden(true)
                end
            end
        end)
    end

    self.fadeTimeline:SetPlaybackType(ANIMATION_PLAYBACK_ONE_SHOT)
    self.fadeTimeline:PlayFromStart()
end

--=============================================================================
-- DEBUG HELPER
--=============================================================================
function CritTracker:DebugPrint(message)
    if self.savedVars and self.savedVars.showNotifications then
        d(message)
    end
end

--=============================================================================
-- INITIALIZE
--=============================================================================
function CritTracker:RegisterCombatEvents()
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "_CombatEnd", EVENT_PLAYER_COMBAT_STATE,
        function(_, inCombat)
            if not inCombat then
                EVENT_MANAGER:RegisterForUpdate("CritTracker_PostCombat", 7500, function()
                    EVENT_MANAGER:UnregisterForUpdate("CritTracker_PostCombat")
                    local capturedCrit = self:ForceBarCapture()
                end)
            end
        end)

    --[[
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "_ZoneChange", EVENT_ZONE_CHANGED,
        function(eventCode, zoneName, subZoneName, newSubzone, zoneId, subZoneId)
            self:OnZoneChanged()
        end)
        ]]
end

--[[
function CritTracker:OnZoneChanged()
    if self.savedVars.showOnlyInCombat == "dungeon" then
        local inDungeon = IsUnitInDungeon("player")
    end
end
--]]
function CritTracker:RegisterZoneEvents()
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "_ZoneChange", EVENT_PLAYER_ACTIVATED, function()
        zo_callLater(function()
            self:UpdateTrackerVisibility()
        end, 1000)
    end)
end

local function InitializeBarTracking()
    local currentBar = GetActiveWeaponPairInfo()
    CritTracker.currentActiveBar = currentBar
    local initAttempts = 0
    local maxInitAttempts = 3

    local function performInitCapture()
        initAttempts = initAttempts + 1
        local capturedCrit = CritTracker:ForceBarCapture()

        if initAttempts < maxInitAttempts then
            EVENT_MANAGER:RegisterForUpdate("CritTracker_InitRetry", 1000, performInitCapture)
        end
    end
    EVENT_MANAGER:RegisterForUpdate("CritTracker_InitialCapture", 500, performInitCapture)
end

local function Initialize()
    CritTracker.savedVars = ZO_SavedVars:NewCharacterIdSettings(
        "CritTracker_SavedVars",
        1,
        nil,
        defaults
    )
    zo_callLater(function()
        CritTracker:InitializeDials()
    end, 100)
    local labels = CritTracker:GetLabels()
    for i, label in ipairs(labels) do
        if label then
            label:SetHidden(not CritTracker.savedVars.uiVisible)
        end
    end



    --  combat event
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_COMBAT_EVENT,
        function(...) CritTracker:OnCombatEvent(...) end)

    --  weapon pair change event
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ACTIVE_WEAPON_PAIR_CHANGED,
        function(eventCode, activeWeaponPair, locked)
            CritTracker:OnActiveWeaponPairChanged(eventCode, activeWeaponPair, locked)
        end)

    zo_callLater(function()
        CritTracker:UpdateLabelSettings()
        CritTracker:ApplyFontsToLabels()
        CritTracker:ApplyColorsToLabels()
        -- Register additional bar tracking events
        CritTracker:RegisterCombatEvents()
        CritTracker:RegisterUIHideEvent()
        CritTracker:RegisterZoneEvents()
        -- Initialize bar
        InitializeBarTracking()
        CritTracker:CreateSettingsMenu()
        CritTracker:UpdateDisplay()
    end, 1000)
end



--=============================================================================
-- EVENT MANAGERS
--=============================================================================
function CritTracker:RegisterUIHideEvent()
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "_ReticleUpdate", EVENT_RETICLE_HIDDEN_UPDATE,
        function(eventCode, hidden)
            if hidden then
                -- Reticle hidden, player entered menus/settings
                -- Fade out text and dials
                self:AnimateLabels(false)
                if self.savedVars.showDials then
                    self:AnimateDials(false)
                end
            else
                -- Reticle visible, player exited menus
                zo_callLater(function()
                    self:UpdateTrackerVisibility()
                end, 200)
            end
        end)
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_PLAYER_COMBAT_STATE,
    function(_, inCombat)
        CritTracker:OnCombatStateChanged(inCombat)
    end)

local function OnAddOnLoaded(event, addonName)
    if addonName == ADDON_NAME then
        EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
        Initialize()
    end
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
