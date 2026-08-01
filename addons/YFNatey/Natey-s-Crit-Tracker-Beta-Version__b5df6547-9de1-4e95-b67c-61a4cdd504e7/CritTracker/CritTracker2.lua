CritTracker = {}
local ADDON_NAME = "CritTracker2"

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

local defaults = {
    fontSize = 28,
    labelPosX = 560,
    labelPosY = 20,
    showNotifications = false,
    simpleMode = true,
    showCritDmg = true,
    uiVisible = true,
    -- Font
    selectedFont = "ESO_Standard",
    fontScale = 1.0,

    -- Color
    critRateColor = { 1.0, 1.0, 1.0, 1.0 },
    critDamageColor = { 1.0, 0.8, 0.4, 1.0 },

    -- Execute phase tracking
    enableExecuteTracking = false,
    executeThreshold = 30.0,
    executePhaseColor = { 1.0, 0.2, 0.2, 1.0 },
    showExecutePhaseOnly = false,
    hideMainLinesInExecute = false, --
}


--=============================================================================
-- BOSS HEALTH TRACKING
--=============================================================================
CritTracker.dummyUnitTag = nil

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

function CritTracker:GetCharSheetCritChance()
    local critRating = GetPlayerStat(STAT_CRITICAL_STRIKE)
    local critChance = (critRating / 219)
    return math.min(critChance, 100)
end

function CritTracker:GetFormattedBarCritChances()
    -- Show current bar indicator if we have both bars captured
    local frontText = self.frontBarCritChance > 0 and string.format("%.1f%%", self.frontBarCritChance) or "-.-%"
    local backText = self.backBarCritChance > 0 and string.format("%.1f%%", self.backBarCritChance) or "-.-%"

    -- Add current bar indicator (optional - remove if you don't want it)
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
        local avgCrit = self.fightCritCount > 0 and (self.fightTotalCritDamage / self.fightCritCount) or 0
        local avgNormal = self.fightNormalCount > 0 and (self.fightTotalNormalDamage / self.fightNormalCount) or 0

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
    -- If we hit a target dummy, find its unit tag for health tracking
    if sourceType == COMBAT_UNIT_TYPE_PLAYER and targetType == COMBAT_UNIT_TYPE_TARGET_DUMMY then
        if not self.dummyUnitTag then
            local dummyTags = { "reticleover", "boss1", "boss2", "boss3", "boss4", "boss5", "boss6" }
            for _, tag in ipairs(dummyTags) do
                if DoesUnitExist(tag) and IsUnitAttackable(tag) and GetUnitName(tag) == targetName then
                    self.dummyUnitTag = tag
                    -- Add dummy to discovered "bosses" for consistent tracking
                    self.discoveredBosses[targetName] = {
                        unitTag = tag,
                        discovered = true
                    }
                    break
                end
            end
        end
    end

    -- Continue with existing damage tracking logic (unchanged)
    if sourceType == COMBAT_UNIT_TYPE_PLAYER and hitValue > 1 then
        self.playerDamage = self.playerDamage + hitValue

        if result == ACTION_RESULT_CRITICAL_DAMAGE or result == ACTION_RESULT_DOT_TICK_CRITICAL then
            self.critCount = self.critCount + 1
            self.totalCritDamage = self.totalCritDamage + hitValue
            self.fightCritCount = self.fightCritCount + 1
            self.fightTotalCritDamage = self.fightTotalCritDamage + hitValue

            -- Track execute phase crits
            if self.inExecutePhase then
                self.executePhaseCritCount = self.executePhaseCritCount + 1
                self.executePhaseTotalCritDamage = self.executePhaseTotalCritDamage + hitValue
            end
        elseif result == ACTION_RESULT_DAMAGE or result == ACTION_RESULT_DOT_TICK then
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
    end

    if self.inCombat and not self.delay then
        self:UpdateExecutePhaseStatus()
        self:UpdateDisplay()
    end
end

--=============================================================================
-- UPDATE DISPLAY
--=============================================================================
function CritTracker:UpdateDisplay()
    local totalHits = self.critCount + self.normalCount
    local charSheet = self:GetCharSheetCritChance()

    -- Check if we should only show during execute phase
    if self.savedVars.showExecutePhaseOnly and not self.inExecutePhase then
        ct2_line1CritInfo:SetText("")
        ct2_line2_CritDamage:SetText("")
        ct2_line3_ExecutePhase:SetText("")
        return
    end

    -- Check if we should hide main lines during execute phase
    if self.savedVars.hideMainLinesInExecute and self.inExecutePhase then
        ct2_line1CritInfo:SetText("")
        ct2_line2_CritDamage:SetText("")
        -- Only show execute phase line
        if self.savedVars.enableExecuteTracking then
            local executeHits = self.executePhaseCritCount + self.executePhaseNormalCount
            if executeHits > 0 then
                local executeCritRate = self:GetExecutePhaseCritRate()
                local executeCritDamage = self:GetExecutePhaseCritDamage()

                local executeText = string.format("Execute: %.1f%%", executeCritRate)
                if self.savedVars.showCritDmg then
                    executeText = string.format("Execute: %.1f%% • Dmg: %.0f%%", executeCritRate, executeCritDamage)
                end
                ct2_line3_ExecutePhase:SetText(executeText)
            else
                ct2_line3_ExecutePhase:SetText("")
            end
        else
            ct2_line3_ExecutePhase:SetText("")
        end

        -- Apply execute color to the execute line
        local executeColor = self.savedVars.executePhaseColor
        ct2_line3_ExecutePhase:SetColor(executeColor[1], executeColor[2], executeColor[3], executeColor[4])
        return
    end

    if totalHits == 0 then
        -- Show stat sheet info when no combat data
        if self.savedVars.simpleMode then
            local line1Text = string.format("%.1f%%", charSheet)
            ct2_line1CritInfo:SetText(line1Text)
            ct2_line2_CritDamage:SetText("")
            ct2_line3_ExecutePhase:SetText("")
        else
            -- MODIFIED: Show dual bar format in verbose mode
            local barCritText = self:GetFormattedBarCritChances()
            local line1Text = string.format("Effective: %.1f%% • Base: %s", charSheet, barCritText)
            ct2_line1CritInfo:SetText(line1Text)
            ct2_line2_CritDamage:SetText("")
            ct2_line3_ExecutePhase:SetText("")
        end
        return
    end

    -- Calculate normal combat stats
    local critRate = (self.critCount / totalHits) * 100
    local avgCritDamage = self.critCount > 0 and (self.totalCritDamage / self.critCount) or 0
    local avgNormalDamage = self.normalCount > 0 and (self.totalNormalDamage / self.normalCount) or 0
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

    -- Simple Mode
    if self.savedVars.simpleMode then
        local line1Text = string.format("%.1f%%", critRate)
        if self.savedVars.showCritDmg then
            local critRateHex = self:ColorToHex(self.savedVars.critRateColor)
            local critDamageHex = self:ColorToHex(self.savedVars.critDamageColor)

            line1Text = string.format("%.1f%% • |c%sDmg: %.0f%%|r",
                critRate, critDamageHex, self.critDamagePercent)
        end
        line1Text = line1Text .. executePhaseText
        ct2_line1CritInfo:SetText(line1Text)
        ct2_line2_CritDamage:SetText("")

        -- Execute phase line (simple mode)
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
                ct2_line3_ExecutePhase:SetText(executeText)
            end
        else
            ct2_line3_ExecutePhase:SetText("")
        end
    else
        -- FIXED: Detailed mode with dual bar display (NOW INCLUDES COMBAT DATA)
        local barCritText = self:GetFormattedBarCritChances()
        local line1Text = string.format("Effective: %.1f%% • Base: %s", critRate, barCritText)
        local line2Text = ""
        if self.savedVars.showCritDmg then
            line2Text = string.format("Average Crit Damage: %.0f%%", self.critDamagePercent)
        end
        ct2_line1CritInfo:SetText(line1Text)
        ct2_line2_CritDamage:SetText(line2Text)

        -- Verbose execute phase
        if self.savedVars.enableExecuteTracking then
            if self.inExecutePhase then
                local executeHits = self.executePhaseCritCount + self.executePhaseNormalCount
                if executeHits > 0 then
                    local executeText = string.format("Execute Phase: %.1f%% crit", executeCritRate)
                    if self.savedVars.showCritDmg and executeCritDamage > 0 then
                        executeText = executeText .. string.format(" • %.0f%% dmg", executeCritDamage)
                    end
                    ct2_line3_ExecutePhase:SetText(executeText)
                else
                    ct2_line3_ExecutePhase:SetText("")
                end
            else
                ct2_line3_ExecutePhase:SetText("")
            end
        else
            ct2_line3_ExecutePhase:SetText("")
        end
    end

    -- Apply colors
    self:ApplyColorsToLabels()

    -- Apply execute color only to the execute line (line3) when in execute phase
    if self.inExecutePhase and self.savedVars.enableExecuteTracking then
        local executeColor = self.savedVars.executePhaseColor
        ct2_line3_ExecutePhase:SetColor(executeColor[1], executeColor[2], executeColor[3], executeColor[4])
    else
        -- Reset execute line color when not in execute phase
        local defaultColor = self.savedVars.critRateColor
        ct2_line3_ExecutePhase:SetColor(defaultColor[1], defaultColor[2], defaultColor[3], defaultColor[4])
    end
end

--=============================================================================
-- FONTS
--=============================================================================
local fontBook = {
    ["ESO_Standard"] = {
        name = "ESO Standard",
        path = nil,
        description = "Default ESO font"
    },
    ["ESO_Bold"] = {
        name = "ESO Bold",
        path = "$(BOLD_FONT)|%d|soft-shadow-thick",
        description = "Bold ESO font"
    },
    ["Handwritten"] = {
        name = "Handwritten",
        path = "EsoUI/Common/Fonts/ProseAntiquePSMT.slug|%d|soft-shadow-thick",
        description = "Handwritten-style font"
    },
    ["Futura"] = {
        name = "Futura Condensed",
        path = "EsoUI/Common/Fonts/FuturaStd-CondensedLight.slug|%d|soft-shadow-thin",
        description = "Clean, modern font"
    },
    ["Trajan"] = {
        name = "Trajan Pro",
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

function CritTracker:BuildFontString()
    local selectedFont = self.savedVars and self.savedVars.selectedFont or "ESO_Standard"
    local fontSize = self.savedVars and self.savedVars.fontSize or 28
    local fontScale = self.savedVars and self.savedVars.fontScale or 1.0

    -- Ensure all values are numbers with fallbacks
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
        _G["ct2_line1CritInfo"],
        _G["ct2_line2_CritDamage"],
        _G["ct2_line3_ExecutePhase"]
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
-- Settings Menu
--=============================================================================
function CritTracker:CreateSettingsMenu()
    local LAM = LibAddonMenu2
    local panelName = "CritTrackerSettings"

    local panelData = {
        type = "panel",
        name = "Crit Tracker v2",
        author = "YFNatey",
        version = "1.1",
        registerForRefresh = true,
        registerForDefaults = true
    }

    local fontChoices, fontChoicesValues = self:GetFontChoices()
    local optionsTable = {
        {
            type = "checkbox",
            name = "Show UI",
            tooltip = "Show or hide the crit tracker display",
            getFunc = function() return self.savedVars.uiVisible end,
            setFunc = function(value)
                self.savedVars.uiVisible = value
                local labels = self:GetLabels()
                for i, label in ipairs(labels) do
                    if label then
                        label:SetHidden(not value)
                    end
                end
                if value then
                    self:UpdateDisplay()
                end
            end,
            default = true,
        },
        {
            type = "button",
            name = "Reset Stats",
            func = function()
                self.critCount = 0
                self.normalCount = 0
                self.totalCritDamage = 0
                self.totalNormalDamage = 0
                self.critDamagePercent = 0
                self.critMultiplier = 0
                self:UpdateDisplay()
                self:DebugPrint("Crit stats reset")
            end
        },
        {
            type = "header",
            name = "Display Options"
        },
        {
            type = "checkbox",
            name = "Simple Display Mode",
            tooltip = "Compact single-line display vs detailed multi-line view",
            getFunc = function() return self.savedVars.simpleMode end,
            setFunc = function(value)
                self.savedVars.simpleMode = value
                self:UpdateDisplay()
            end,
            default = false,
        },
        {
            type = "checkbox",
            name = "Show Average Crit Damage",
            tooltip =
            "Early readings may exceed the 125% cap or seem inaccurate due to small sample sizes - accuracy improves with more combat data.",
            getFunc = function() return self.savedVars.showCritDmg end,
            setFunc = function(value)
                self.savedVars.showCritDmg = value
                self:UpdateDisplay()
            end,
            default = false,
        },
        {
            type = "checkbox",
            name = "Show Combat Stats",
            tooltip = [[Display fight summary in chat after each combat encounter
Example output:
==Combat Summary==
Total Hits: 156 (89 crits, 67 normal)
Crit Rate: 57.1% (Max: 63.2%)
Avg Crit DMG: 8429 crit, 3891 normal (+116% / 2.17x)
Execute Phase: 73.2% crit (19/26 hits)
Execute Crit DMG: 9156 crit, 4102 normal (+123% / 2.23x)]],
            getFunc = function() return self.savedVars.showNotifications end,
            setFunc = function(value) self.savedVars.showNotifications = value end,
            default = false
        },
        {

            type = "header",
            name = "Execute Phase Tracking"
        },

        {
            type = "checkbox",
            name = "Enable",
            tooltip = "Track lucky crits when boss health drops below the threshold",
            getFunc = function() return self.savedVars.enableExecuteTracking end,
            setFunc = function(value)
                self.savedVars.enableExecuteTracking = value
                self:UpdateDisplay()
            end,
            default = false,
        },
        {
            type = "checkbox",
            name = "Execute Focus",
            tooltip = "Hide the main crit rate and damage lines when in execute phase, showing only execute stats",
            getFunc = function() return self.savedVars.hideMainLinesInExecute end,
            setFunc = function(value)
                self.savedVars.hideMainLinesInExecute = value
                self:UpdateDisplay()
            end,
            default = false,
            disabled = function() return not self.savedVars.enableExecuteTracking end,
        },
        {
            type = "checkbox",
            name = "hide until threshold",
            tooltip = "Hide tracker until execute phase",
            getFunc = function() return self.savedVars.showExecutePhaseOnly end,
            setFunc = function(value)
                self.savedVars.showExecutePhaseOnly = value
                self:UpdateDisplay()
            end,
            default = false,
            disabled = function() return not self.savedVars.enableExecuteTracking end,
        },
        {
            type = "slider",
            name = "Threshold (%)",
            tooltip = "Boss health percentage threshold for execute phase tracking",
            min = 10,
            max = 50,
            step = 1,
            getFunc = function() return self.savedVars.executeThreshold end,
            setFunc = function(value)
                self.savedVars.executeThreshold = value
                self:UpdateDisplay()
            end,
            default = 30,
            disabled = function() return not self.savedVars.enableExecuteTracking end,
        },
        {
            type = "colorpicker",
            name = "Color",
            tooltip = "Color used when displaying execute phase statistics",
            getFunc = function()
                local color = self.savedVars.executePhaseColor
                return color[1], color[2], color[3], color[4]
            end,
            setFunc = function(r, g, b, a)
                self.savedVars.executePhaseColor = { r, g, b, a }
                self:UpdateDisplay()
            end,
            default = { 1.0, 0.2, 0.2, 1.0 },
            disabled = function() return not self.savedVars.enableExecuteTracking end,
        },

        {
            type = "header",
            name = "Visual Customization"
        },
        {
            type = "dropdown",
            name = "Font Style",
            choices = fontChoices,
            choicesValues = fontChoicesValues,
            getFunc = function() return self.savedVars.selectedFont end,
            setFunc = function(value)
                self.savedVars.selectedFont = value
                self:ApplyFontsToLabels()
            end,
            default = "ESO_Standard",
        },
        {
            type = "slider",
            name = "Font Size",
            min = 10,
            max = 48,
            step = 1,
            getFunc = function() return self.savedVars.fontSize end,
            setFunc = function(value)
                self.savedVars.fontSize = value
                self:UpdateLabelSettings()
            end,
            default = 24,
        },
        {
            type = "slider",
            name = "X Position",
            min = 0,
            max = 5000,
            step = 10,
            getFunc = function() return self.savedVars.labelPosX end,
            setFunc = function(value)
                self.savedVars.labelPosX = value
                self:UpdateLabelSettings()
            end,
            default = 560,
        },
        {
            type = "slider",
            name = "Y Position",
            min = 0,
            max = 7000,
            step = 10,
            getFunc = function() return self.savedVars.labelPosY end,
            setFunc = function(value)
                self.savedVars.labelPosY = value
                self:UpdateLabelSettings()
            end,
            default = 60,
        },
        {
            type = "colorpicker",
            name = "Crit Rate Color",
            getFunc = function()
                local color = self.savedVars.critRateColor
                return color[1], color[2], color[3], color[4]
            end,
            setFunc = function(r, g, b, a)
                self.savedVars.critRateColor = { r, g, b, a }
                self:ApplyColorsToLabels()
            end,
            default = { 1.0, 1.0, 1.0, 1.0 },
        },
        {
            type = "colorpicker",
            name = "Crit Damage Color",
            getFunc = function()
                local color = self.savedVars.critDamageColor
                return color[1], color[2], color[3], color[4]
            end,
            setFunc = function(r, g, b, a)
                self.savedVars.critDamageColor = { r, g, b, a }
                self:ApplyColorsToLabels()
            end,
            default = { 1.0, 0.8, 0.4, 1.0 },
        },
        {
            type = "header",
            name = "Support"
        },
        {
            type = "description",
            text = "Author: YFNatey, Xbox NA",
            width = "full"
        },
        {
            type = "description",
            text = "If you find this addon useful, consider supporting its development!",
            width = "full"
        },
        {
            type = "button",
            name = "Paypal",
            tooltip = "paypal.me/yfnatey",
            func = function() RequestOpenUnsafeURL("https://paypal.me/yfnatey") end,
            width = "half"
        },
        {
            type = "button",
            name = "Ko-fi",
            tooltip = "Ko-fi.me/yfnatey",
            func = function() RequestOpenUnsafeURL("https://Ko-fi.com/yfnatey") end,
            width = "half"
        },

    }
    LAM:RegisterAddonPanel(panelName, panelData)
    LAM:RegisterOptionControls(panelName, optionsTable)
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
function CritTracker:RegisterAdditionalBarEvents()
    -- Trigger bar capture when combat ends (to refresh display)
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "_CombatEnd", EVENT_PLAYER_COMBAT_STATE,
        function(_, inCombat)
            if not inCombat then
                -- Wait for the delay period to end, then capture current bar
                EVENT_MANAGER:RegisterForUpdate("CritTracker_PostCombat", 7500, function()
                    EVENT_MANAGER:UnregisterForUpdate("CritTracker_PostCombat")
                    local capturedCrit = self:ForceBarCapture()
                end)
            end
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

    -- Start the initialization sequence
    EVENT_MANAGER:RegisterForUpdate("CritTracker_InitialCapture", 500, performInitCapture)
end

local function Initialize()
    CritTracker.savedVars = ZO_SavedVars:NewCharacterIdSettings(
        "CritTracker2_SavedVars",
        1,
        nil,
        defaults
    )

    local labels = CritTracker:GetLabels()
    for i, label in ipairs(labels) do
        if label then
            label:SetHidden(not CritTracker.savedVars.uiVisible)
        end
    end

    CritTracker:UpdateLabelSettings()
    CritTracker:ApplyFontsToLabels()
    CritTracker:ApplyColorsToLabels()

    -- Register combat event
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_COMBAT_EVENT,
        function(...) CritTracker:OnCombatEvent(...) end)

    -- Register weapon pair change event with the new optimized handler
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ACTIVE_WEAPON_PAIR_CHANGED,
        function(eventCode, activeWeaponPair, locked)
            CritTracker:OnActiveWeaponPairChanged(eventCode, activeWeaponPair, locked)
        end)

    -- Register additional bar tracking events
    CritTracker:RegisterAdditionalBarEvents()

    -- Initialize bar tracking with multiple attempts
    InitializeBarTracking()

    CritTracker:CreateSettingsMenu()
    CritTracker:UpdateDisplay()
end

SLASH_COMMANDS["/critbar"] = function()
    CritTracker:ManualBarCapture()
end

--=============================================================================
-- EVENT MANAGERS
--=============================================================================
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
