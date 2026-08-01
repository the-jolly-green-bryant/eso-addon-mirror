RotationHelper = {}
RotationHelper.name = "RotationHelper"

-- Console detection (will be set during initialization)
local isConsole = false
local MAX_HISTORY_SIZE = 200

-- Combat tracking data
local lightAttackAttempts = 0
local lightAttackHits = 0
local lightAttackMisses = 0
local lastActionTime = 0
local combatStartTime = 0
local inCombat = false

-- DDR-style action queue (upcoming actions to perform)
local actionQueue = {}
local actionHistory = {}
local currentRotation = {}
local actionTimeline = {}  -- Timeline of all actions with their durations and start times
local currentActionIndex = 1  -- Which action in timeline we're currently on

-- DOT, Buff, and Cooldown tracking
local activeDOTs = {}      -- {skillName, startTime, duration, expiryTime}
local activeBuffs = {}     -- {skillName, startTime, duration, expiryTime}
local skillCooldowns = {}  -- {skillName, startTime, duration, expiryTime}

-- Stack tracking for skills like Merciless Resolve
-- Format: {skillName = {stacks = 0, maxStacks = 5, active = false, expiryTime = 0}}
local skillStacks = {}

-- Action types
local ACTION_TYPES = {
    LIGHT_ATTACK = 1,
    SKILL = 2,
    BAR_SWAP = 3,
    POTION = 4
}

-- DDR timing windows (in milliseconds)
local TIMING = {
    PERFECT = 100,  -- Within 100ms
    GOOD = 250,     -- Within 250ms
    OK = 500,       -- Within 500ms
}

-- Visual feedback colors
local RATING_COLORS = {
    PERFECT = {0, 1, 0, 1},    -- Green
    GOOD = {0.8, 0.8, 0, 1},   -- Yellow
    OK = {1, 0.5, 0, 1},       -- Orange
    MISS = {1, 0, 0, 1}        -- Red
}

-- Helper function to get current character key
function RotationHelper:GetCharacterKey()
    local charName = GetUnitName("player")
    local displayName = GetDisplayName()
    return string.format("%s@%s", charName, displayName)
end

-- Helper function to save rotation for current character
function RotationHelper:SaveRotation()
    local charKey = self:GetCharacterKey()
    if not RotationHelperSavedVars.characters then
        RotationHelperSavedVars.characters = {}
    end
    if not RotationHelperSavedVars.characters[charKey] then
        RotationHelperSavedVars.characters[charKey] = {}
    end
    RotationHelperSavedVars.characters[charKey].rotation = currentRotation
end

-- Initialize saved variables
function RotationHelper:Initialize()
    -- Platform detection disabled for compatibility
    -- Default to PC settings (works on all platforms)
    isConsole = false
    MAX_HISTORY_SIZE = 200

    -- Uncomment below to enable console detection when API is available:
    -- local platformType = GetCVar("PlatformType")
    -- if platformType and platformType ~= "0" then
    --     isConsole = true
    --     MAX_HISTORY_SIZE = 50
    -- end

    -- Detect if using gamepad (good indicator for console)
    local isUsingGamepad = IsInGamepadPreferredMode()

    -- Get character identifier
    local charName = GetUnitName("player")
    local displayName = GetDisplayName()
    local charKey = string.format("%s@%s", charName, displayName)

    -- Initialize global settings (account-wide)
    RotationHelperSavedVars = RotationHelperSavedVars or {
        showDDR = true,
        showTimers = true,
        trackingEnabled = true,
        showCombatSummary = true,  -- Auto-show summary when combat ends
        ddRSpeed = 1.5,  -- Seconds before action should execute
        uiScale = isUsingGamepad and 1.5 or 1.0,  -- Larger scale for gamepad/console
        -- Separate positions for NOW and NEXT
        nowPosX = 0,
        nowPosY = -300,
        nextPosX = 0,
        nextPosY = -210,
        -- Font sizes
        nowFontSize = 42,
        nextFontSize = 32,
        -- Character-specific rotations
        characters = {},
    }

    -- Ensure characters table exists (for upgrading from old versions)
    if not RotationHelperSavedVars.characters then
        RotationHelperSavedVars.characters = {}
    end

    -- Initialize character-specific settings
    if not RotationHelperSavedVars.characters[charKey] then
        RotationHelperSavedVars.characters[charKey] = {
            rotation = {},
        }
    end

    -- IMPORTANT: Load saved rotation for THIS character into memory!
    currentRotation = RotationHelperSavedVars.characters[charKey].rotation or {}

    self:SetupEventHandlers()
    self:InitializeUI()
    self:InitializeRotationBuilder()
    self:CreateSettingsMenu()

    local platformMsg = isConsole and " (Console Optimized)" or ""
    d(string.format("Rotation Helper loaded%s! Character: |cFFD700%s|r", platformMsg, charName))
    d("Type /rh for commands")
end

-- Setup event handlers
function RotationHelper:SetupEventHandlers()
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_COMBAT_EVENT, function(_, result, _, abilityName, _, _, _, _, _, _, _, _, _, _, _, _, abilityId)
        self:OnCombatEvent(result, abilityName, abilityId)
    end)

    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLAYER_COMBAT_STATE, function(_, inCombat)
        self:OnCombatStateChanged(inCombat)
    end)

    -- Console optimization: Slower update frequency for better performance
    local updateInterval = isConsole and 33 or 16  -- 30 FPS for console, 60 FPS for PC
    EVENT_MANAGER:RegisterForUpdate(self.name .. "Update", updateInterval, function()
        self:OnUpdate()
    end)
end

-- Combat event handler
function RotationHelper:OnCombatEvent(result, abilityName, abilityId)
    if not RotationHelperSavedVars.trackingEnabled or not inCombat then
        return
    end

    local currentTime = GetGameTimeMilliseconds()
    local actionType = self:GetActionType(abilityId, abilityName)

    -- Track light attacks specifically
    if actionType == ACTION_TYPES.LIGHT_ATTACK then
        lightAttackAttempts = lightAttackAttempts + 1

        if result == ACTION_RESULT_SUCCESS or result == ACTION_RESULT_DAMAGE or
           result == ACTION_RESULT_CRITICAL_DAMAGE or result == ACTION_RESULT_DOT_TICK then
            lightAttackHits = lightAttackHits + 1

            -- Increment stacks for any active stack-building skills
            self:IncrementSkillStacks(currentTime)
        else
            lightAttackMisses = lightAttackMisses + 1
        end

        -- Debug: Show light attack tracking
        -- d(string.format("LA Tracked: %s (ID: %d) - Result: %s", abilityName or "Unknown", abilityId or 0, tostring(result)))

        self:UpdateLightAttackStats()
    end

    -- Track DOTs, Buffs, and Cooldowns using skill database
    if actionType == ACTION_TYPES.SKILL and abilityName and abilityName ~= "" then
        self:TrackSkillEffects(abilityName, currentTime)
    end

    -- Record action in history (with memory limit)
    table.insert(actionHistory, {
        type = actionType,
        name = abilityName,
        time = currentTime,
        result = result
    })

    -- Console optimization: Limit history size to prevent memory bloat
    if #actionHistory > MAX_HISTORY_SIZE then
        table.remove(actionHistory, 1)
    end

    -- Check timing against expected rotation
    self:CheckRotationTiming(actionType, abilityName, currentTime)

    lastActionTime = currentTime
end

-- Track skill effects (DOTs, Buffs, Cooldowns, Stacks)
function RotationHelper:TrackSkillEffects(skillName, currentTime)
    if not RotationHelper.SkillDB then
        return
    end

    local skillInfo = RotationHelper.SkillDB:GetSkillInfo(skillName)
    if not skillInfo then
        return
    end

    -- Track DOTs
    if skillInfo.isDOT and skillInfo.duration > 0 then
        activeDOTs[skillName] = {
            startTime = currentTime,
            duration = skillInfo.duration,
            expiryTime = currentTime + skillInfo.duration
        }
    end

    -- Track Buffs
    if skillInfo.isBuff and skillInfo.duration > 0 then
        activeBuffs[skillName] = {
            startTime = currentTime,
            duration = skillInfo.duration,
            expiryTime = currentTime + skillInfo.duration
        }
    end

    -- Track Cooldowns
    if skillInfo.cooldown > 0 then
        skillCooldowns[skillName] = {
            startTime = currentTime,
            duration = skillInfo.cooldown,
            expiryTime = currentTime + skillInfo.cooldown
        }
    end

    -- Track stack-based skills (like Merciless Resolve)
    if skillInfo.buildsStacks and skillInfo.requiresStacks then
        -- Check if this is the initial cast (activating the buff) or the proc
        if not skillStacks[skillName] or not skillStacks[skillName].active then
            -- Initial cast - activate stack tracking
            skillStacks[skillName] = {
                stacks = 0,
                maxStacks = skillInfo.maxStacks or skillInfo.requiresStacks,
                requiredStacks = skillInfo.requiresStacks,
                active = true,
                expiryTime = currentTime + skillInfo.duration
            }
        else
            -- This is the proc being used - reset stacks
            skillStacks[skillName] = nil
        end
    end
end

-- Get remaining time for a DOT
function RotationHelper:GetDOTRemainingTime(skillName)
    local dot = activeDOTs[skillName]
    if not dot then
        return 0
    end

    local currentTime = GetGameTimeMilliseconds()
    local remaining = dot.expiryTime - currentTime
    return math.max(0, remaining)
end

-- Get remaining time for a buff
function RotationHelper:GetBuffRemainingTime(skillName)
    local buff = activeBuffs[skillName]
    if not buff then
        return 0
    end

    local currentTime = GetGameTimeMilliseconds()
    local remaining = buff.expiryTime - currentTime
    return math.max(0, remaining)
end

-- Get remaining cooldown for a skill
function RotationHelper:GetCooldownRemainingTime(skillName)
    local cd = skillCooldowns[skillName]
    if not cd then
        return 0
    end

    local currentTime = GetGameTimeMilliseconds()
    local remaining = cd.expiryTime - currentTime
    return math.max(0, remaining)
end

-- Check if skill is on cooldown
function RotationHelper:IsOnCooldown(skillName)
    return self:GetCooldownRemainingTime(skillName) > 0
end

-- Increment stacks for active stack-building skills (called on successful light attacks)
function RotationHelper:IncrementSkillStacks(currentTime)
    for skillName, stackInfo in pairs(skillStacks) do
        if stackInfo.active and currentTime < stackInfo.expiryTime then
            -- Increment stacks up to max
            if stackInfo.stacks < stackInfo.maxStacks then
                stackInfo.stacks = stackInfo.stacks + 1
            end
        end
    end
end

-- Get current stacks for a skill
function RotationHelper:GetSkillStacks(skillName)
    local stackInfo = skillStacks[skillName]
    if not stackInfo or not stackInfo.active then
        return 0
    end
    return stackInfo.stacks or 0
end

-- Check if skill has enough stacks to proc
function RotationHelper:IsSkillProcReady(skillName)
    local stackInfo = skillStacks[skillName]
    if not stackInfo or not stackInfo.active then
        return false
    end
    return stackInfo.stacks >= stackInfo.requiredStacks
end

-- Check if a skill is ready to cast (dynamic rotation logic)
-- Returns: isReady (bool), reason (string), priority (number)
function RotationHelper:IsSkillReady(skillName, currentTime)
    if not skillName or skillName == "" then
        return true, "no skill name", 0  -- Light attacks are always ready
    end

    local skillInfo = RotationHelper.SkillDB and RotationHelper.SkillDB:GetSkillInfo(skillName)
    if not skillInfo then
        return true, "unknown skill (assume ready)", 0  -- Unknown skills default to ready
    end

    -- Check if skill requires stacks
    if skillInfo.requiresStacks and skillInfo.requiresStacks > 0 then
        local stackInfo = skillStacks[skillName]

        if not stackInfo or not stackInfo.active then
            -- Buff not active - ready to cast (initial activation)
            return true, "activate buff", 10  -- High priority to activate
        end

        if stackInfo.stacks >= stackInfo.requiredStacks then
            -- Stacks are full - PROC READY!
            return true, "PROC READY", 100  -- Highest priority!
        else
            -- Not enough stacks yet - skip this skill
            return false, string.format("waiting for stacks (%d/%d)", stackInfo.stacks, stackInfo.requiredStacks), 0
        end
    end

    -- Check if it's a DOT that's still active
    if skillInfo.isDOT then
        local dotRemaining = self:GetDOTRemainingTime(skillName)
        if dotRemaining > 1000 then
            -- DOT still has > 1 second - skip it
            return false, string.format("DOT active (%.1fs left)", dotRemaining / 1000), 0
        elseif dotRemaining > 0 then
            -- DOT < 1 second - high priority to refresh
            return true, "DOT expiring soon", 50
        else
            -- DOT expired - ready to recast
            return true, "DOT expired", 20
        end
    end

    -- Check if it's a buff that's still active
    if skillInfo.isBuff and not skillInfo.requiresStacks then
        local buffRemaining = self:GetBuffRemainingTime(skillName)
        if buffRemaining > 1000 then
            -- Buff still has > 1 second - skip it
            return false, string.format("buff active (%.1fs left)", buffRemaining / 1000), 0
        elseif buffRemaining > 0 then
            -- Buff < 1 second - high priority to refresh
            return true, "buff expiring soon", 50
        else
            -- Buff expired - ready to recast
            return true, "buff expired", 20
        end
    end

    -- Check cooldown
    if skillInfo.cooldown and skillInfo.cooldown > 0 then
        if self:IsOnCooldown(skillName) then
            local cdRemaining = self:GetCooldownRemainingTime(skillName)
            return false, string.format("on cooldown (%.1fs)", cdRemaining / 1000), 0
        end
    end

    -- Skill is ready (spammable or no restrictions)
    return true, "ready", 5
end

-- Find next ready action in the timeline (dynamic rotation)
-- Scans through timeline starting from currentIndex, finds first ready skill
function RotationHelper:FindNextReadyAction(startIndex, currentTime)
    if #actionTimeline == 0 then
        return nil, nil
    end

    -- Scan through the timeline to find the next ready action
    -- We'll check up to the full rotation length to find something ready
    local bestAction = nil
    local bestIndex = nil
    local highestPriority = -1
    local scannedSkills = {}  -- Track which skills we've checked (to avoid duplicates)

    for offset = 0, #actionTimeline - 1 do
        local checkIndex = ((startIndex - 1 + offset) % #actionTimeline) + 1
        local action = actionTimeline[checkIndex]

        -- Always allow light attacks and bar swaps (they're always ready)
        if action.type == "LA" then
            -- Light attacks are always the immediate next step
            if offset == 0 then
                return action, checkIndex
            end
        elseif action.type == "SKILL" then
            -- Check if we've already evaluated this skill
            if not scannedSkills[action.name] then
                scannedSkills[action.name] = true

                local isReady, reason, priority = self:IsSkillReady(action.name, currentTime)

                if isReady and priority > highestPriority then
                    bestAction = action
                    bestIndex = checkIndex
                    highestPriority = priority
                end
            end
        end
    end

    -- If we found a ready skill, return it
    if bestAction then
        return bestAction, bestIndex
    end

    -- Fallback: just return the next action in sequence (shouldn't happen often)
    local fallbackIndex = ((startIndex - 1) % #actionTimeline) + 1
    return actionTimeline[fallbackIndex], fallbackIndex
end

-- Clean up expired effects
function RotationHelper:CleanupExpiredEffects()
    local currentTime = GetGameTimeMilliseconds()

    -- Clean up expired DOTs
    for skillName, dot in pairs(activeDOTs) do
        if currentTime >= dot.expiryTime then
            activeDOTs[skillName] = nil
        end
    end

    -- Clean up expired buffs
    for skillName, buff in pairs(activeBuffs) do
        if currentTime >= buff.expiryTime then
            activeBuffs[skillName] = nil
        end
    end

    -- Clean up expired cooldowns
    for skillName, cd in pairs(skillCooldowns) do
        if currentTime >= cd.expiryTime then
            skillCooldowns[skillName] = nil
        end
    end

    -- Clean up expired stack buffs
    for skillName, stackInfo in pairs(skillStacks) do
        if currentTime >= stackInfo.expiryTime then
            skillStacks[skillName] = nil
        end
    end
end

-- Determine action type
function RotationHelper:GetActionType(abilityId, abilityName)
    -- Light attack detection - check both ability ID and name
    -- Common light attack IDs: 15279, 16420, 18429, 28692, 28297
    if abilityId == 15279 or abilityId == 16420 or abilityId == 18429 or
       abilityId == 28692 or abilityId == 28297 then
        return ACTION_TYPES.LIGHT_ATTACK
    end

    -- Also check by name (more reliable)
    if abilityName then
        local lowerName = string.lower(abilityName)
        if string.find(lowerName, "light attack") or
           string.find(lowerName, "^attack$") then
            return ACTION_TYPES.LIGHT_ATTACK
        end
    end

    -- Check for bar swap (multiple possible IDs and names)
    -- Note: Bar swaps are better detected via EVENT_ACTIVE_HOTBAR_UPDATED
    if abilityId == 16350 or abilityId == 143339 then
        return ACTION_TYPES.BAR_SWAP
    end
    if abilityName then
        local lowerName = string.lower(abilityName)
        if string.find(lowerName, "weapon swap") or string.find(lowerName, "bar swap") then
            return ACTION_TYPES.BAR_SWAP
        end
    end

    -- Check for potions
    if abilityName and (string.find(abilityName, "Potion") or string.find(abilityName, "Drink")) then
        return ACTION_TYPES.POTION
    end

    return ACTION_TYPES.SKILL
end

-- Combat state handler
function RotationHelper:OnCombatStateChanged(nowInCombat)
    inCombat = nowInCombat

    if inCombat then
        combatStartTime = GetGameTimeMilliseconds()
        self:ResetCombatStats()
        self:StartRotation()
    else
        self:StopRotation()
        self:DisplayCombatSummary()

        -- Hide the rotation display when combat ends
        self:UpdateNextActionsDisplay(GetGameTimeMilliseconds())
    end
end

-- Reset combat statistics
function RotationHelper:ResetCombatStats()
    lightAttackAttempts = 0
    lightAttackHits = 0
    lightAttackMisses = 0
    actionHistory = {}
    actionQueue = {}
    actionTimeline = {}
    currentActionIndex = 1
    activeDOTs = {}
    activeBuffs = {}
    skillCooldowns = {}
    skillStacks = {}
end

-- Start the rotation
function RotationHelper:StartRotation()
    if #currentRotation == 0 then
        return
    end

    -- Build skill queue and action timeline
    actionQueue = {}
    actionTimeline = {}
    currentActionIndex = 1  -- Start at first action

    local LA_TIME = 400  -- Light attack animation time
    local SWAP_TIME = 500  -- Bar swap animation time
    local GCD = 1000  -- Global cooldown base

    local cumulativeTime = 0
    local previousBar = nil

    for i = 1, #currentRotation do
        local skill = currentRotation[i]

        -- Only add skills to queue (rotation should only have skills now)
        if skill.type == ACTION_TYPES.SKILL then
            -- Add skill to queue
            table.insert(actionQueue, {
                name = skill.name,
                bar = skill.bar,
                button = skill.button,  -- Button name (X, Y, B, LB, RB)
                executed = false
            })

            -- Get cast time and channel time from database
            local castTime = 0
            local channelTime = 0
            local isChannel = false
            local effectDuration = 0  -- For DOTs/buffs (tracked separately, not used in timeline)
            local requiresStacks = false
            local requiredStackCount = 0

            if RotationHelper.SkillDB then
                local skillInfo = RotationHelper.SkillDB:GetSkillInfo(skill.name)
                if skillInfo then
                    castTime = skillInfo.castTime or 0
                    channelTime = skillInfo.channelTime or 0
                    isChannel = channelTime > 0
                    effectDuration = skillInfo.duration or 0
                    requiresStacks = skillInfo.requiresStacks and skillInfo.requiresStacks > 0
                    requiredStackCount = skillInfo.requiresStacks or 0
                end
            end

            -- Check if we need bar swap (we'll mark it on the skill instead of separate action)
            local needsBarSwap = false
            if previousBar and previousBar ~= skill.bar then
                needsBarSwap = true
                cumulativeTime = cumulativeTime + SWAP_TIME  -- Account for swap time
            end

            -- Add Light Attack to timeline
            table.insert(actionTimeline, {
                type = "LA",
                name = "Light Attack",
                duration = LA_TIME,
                startTime = cumulativeTime,
                endTime = cumulativeTime + LA_TIME,
                needsBarSwap = needsBarSwap  -- Mark LA if it needs swap before it
            })
            cumulativeTime = cumulativeTime + LA_TIME

            -- Add Cast Time if skill has one (wind-up before skill fires)
            if castTime > 0 then
                table.insert(actionTimeline, {
                    type = "CAST",
                    name = skill.name .. " (Casting)",
                    duration = castTime,
                    startTime = cumulativeTime,
                    endTime = cumulativeTime + castTime,
                    bar = skill.bar,
                    button = skill.button
                })
                cumulativeTime = cumulativeTime + castTime
            end

            -- Add Skill to timeline
            -- ACTION DURATION (how long you're stuck in the skill):
            -- - Channels: use channelTime (you hold the button)
            -- - Regular skills: use GCD (instant cast, then you can do next action)
            -- Note: effectDuration (for buffs/DOTs) is tracked separately, not used here
            local actionDuration = isChannel and channelTime or GCD

            table.insert(actionTimeline, {
                type = "SKILL",
                name = skill.name,
                duration = actionDuration,
                startTime = cumulativeTime,
                endTime = cumulativeTime + actionDuration,
                bar = skill.bar,
                button = skill.button,  -- Button name for display
                isChannel = isChannel,
                requiresStacks = requiresStacks,  -- Does this skill need stacks before casting?
                requiredStackCount = requiredStackCount  -- How many stacks needed
            })
            cumulativeTime = cumulativeTime + actionDuration

            previousBar = skill.bar
        end
    end

    local totalRotationTime = cumulativeTime / 1000
end

-- Stop the rotation
function RotationHelper:StopRotation()
    -- Keep the queue for analysis but mark it as stopped
end

-- Check timing of action against rotation (advances timeline when you perform actions)
function RotationHelper:CheckRotationTiming(actionType, abilityName, currentTime)
    if #actionTimeline == 0 then
        return
    end

    -- Get current action in timeline
    local loopedIndex = ((currentActionIndex - 1) % #actionTimeline) + 1
    local currentAction = actionTimeline[loopedIndex]

    local shouldAdvance = false

    -- Check if this combat event matches the current action in timeline
    if currentAction.type == "LA" and actionType == ACTION_TYPES.LIGHT_ATTACK then
        -- Light attack matches (bar swap is implied if needsBarSwap flag is set)
        shouldAdvance = true

    elseif (currentAction.type == "CAST" or currentAction.type == "SKILL") and actionType == ACTION_TYPES.SKILL then
        -- Skill cast or execution - check name match
        if currentAction.name and abilityName then
            local actionName = string.lower(currentAction.name)
            local eventName = string.lower(abilityName)
            -- Must match exactly or event name contains action name
            local nameMatches = (actionName == eventName) or string.find(eventName, actionName, 1, true)

            if nameMatches then
                shouldAdvance = true
            end
        end
    end

    -- Advance to next action if current was executed
    if shouldAdvance then
        currentActionIndex = currentActionIndex + 1
    end
end

-- Get timing rating based on difference
function RotationHelper:GetTimingRating(timeDiff)
    if timeDiff <= TIMING.PERFECT then
        return "PERFECT"
    elseif timeDiff <= TIMING.GOOD then
        return "GOOD"
    elseif timeDiff <= TIMING.OK then
        return "OK"
    else
        return "MISS"
    end
end

-- Show timing feedback on screen
function RotationHelper:ShowTimingFeedback(rating, action)
    if not RotationHelperFeedback or not RotationHelperSavedVars.showDDR then
        return
    end

    -- Create floating text feedback
    local feedbackLabel = RotationHelperFeedbackText
    if feedbackLabel then
        feedbackLabel:SetText(rating)
        feedbackLabel:SetColor(unpack(RATING_COLORS[rating]))

        -- Animate feedback (fade in/out)
        local timeline = ANIMATION_MANAGER:CreateTimelineFromVirtual("FadeSceneAnimation", feedbackLabel)
        timeline:PlayFromStart()
    end
end

-- Update light attack statistics
function RotationHelper:UpdateLightAttackStats()
    if lightAttackAttempts == 0 then
        return
    end

    local missPercentage = (lightAttackMisses / lightAttackAttempts) * 100
    local hitPercentage = (lightAttackHits / lightAttackAttempts) * 100

    if RotationHelperStatsLA then
        RotationHelperStatsLA:SetText(string.format("LA: %d/%d (%.1f%% miss)",
            lightAttackHits, lightAttackAttempts, missPercentage))

        -- Color code based on performance
        if missPercentage < 5 then
            RotationHelperStatsLA:SetColor(0, 1, 0, 1)  -- Green (excellent)
        elseif missPercentage < 10 then
            RotationHelperStatsLA:SetColor(1, 1, 0, 1)  -- Yellow (good)
        elseif missPercentage < 15 then
            RotationHelperStatsLA:SetColor(1, 0.65, 0, 1)  -- Orange (okay)
        else
            RotationHelperStatsLA:SetColor(1, 0, 0, 1)  -- Red (needs work)
        end
    end
end

-- Display combat summary
function RotationHelper:DisplayCombatSummary()
    -- Don't show if no light attacks or if auto-summary is disabled
    if lightAttackAttempts == 0 then
        d("RotationHelper: No light attacks to summarize")
        return
    end

    if not RotationHelperSavedVars.showCombatSummary then
        d("RotationHelper: Combat summary disabled in settings (use /rh summary to enable)")
        return
    end

    local missPercentage = (lightAttackMisses / lightAttackAttempts) * 100
    local hitPercentage = (lightAttackHits / lightAttackAttempts) * 100
    local combatDuration = (GetGameTimeMilliseconds() - combatStartTime) / 1000

    -- Color-code the miss percentage based on performance
    local missColor = "|cFF0000"  -- Red (bad)
    if missPercentage < 5 then
        missColor = "|c00FF00"  -- Green (excellent)
    elseif missPercentage < 10 then
        missColor = "|cFFFF00"  -- Yellow (good)
    elseif missPercentage < 15 then
        missColor = "|cFFA500"  -- Orange (okay)
    end

    -- Display summary in chat
    d("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    d("|cFFD700⚔ Rotation Helper - Combat Summary ⚔|r")
    d("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    d(string.format("|cFFFFFFLight Attacks:|r %d hits / %d total (%.1f%% accuracy)",
        lightAttackHits, lightAttackAttempts, hitPercentage))
    d(string.format("|cFFFFFFMiss Percentage:|r %s%.1f%%|r", missColor, missPercentage))
    d(string.format("|cFFFFFFCombat Duration:|r %.1f seconds", combatDuration))

    -- Performance rating
    local rating = ""
    if missPercentage < 5 then
        rating = "|c00FF00★★★★★ EXCELLENT!|r"
    elseif missPercentage < 10 then
        rating = "|cFFFF00★★★★☆ GOOD!|r"
    elseif missPercentage < 15 then
        rating = "|cFFA500★★★☆☆ OK|r"
    elseif missPercentage < 20 then
        rating = "|cFF8800★★☆☆☆ Needs Work|r"
    else
        rating = "|cFF0000★☆☆☆☆ Keep Practicing!|r"
    end
    d(string.format("|cFFFFFFRating:|r %s", rating))
    d("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
end

-- Update loop for rotation display
function RotationHelper:OnUpdate()
    local currentTime = GetGameTimeMilliseconds()

    -- Clean up expired effects
    self:CleanupExpiredEffects()

    -- Update potion cooldown
    self:UpdatePotionCooldown()

    -- Update timers UI
    self:UpdateTimersDisplay()

    -- Update Next Actions display only in combat
    if inCombat and RotationHelperSavedVars.showDDR then
        self:UpdateNextActionsDisplay(currentTime)
    elseif inCombat and not RotationHelperSavedVars.showDDR then
        -- Debug: Display is toggled off
        if math.random(1, 300) == 1 then
            d("Display update skipped: showDDR is disabled. Use /rh toggle to enable.")
        end
    end
end

-- Update Next Actions display (Console-Friendly)
-- DYNAMIC APPROACH: Shows current action, finds next READY skill (skips skills with active timers/missing stacks)
function RotationHelper:UpdateNextActionsDisplay(currentTime)
    if not RotationHelperDisplayNow or not RotationHelperDisplayNext then
        return
    end

    -- Check if user has toggled display off
    if not RotationHelperSavedVars.showDDR then
        RotationHelperDisplayNow:SetHidden(true)
        RotationHelperDisplayNext:SetHidden(true)
        return
    end

    -- If no rotation or timeline, show setup message (always visible)
    if #currentRotation == 0 or #actionTimeline == 0 then
        -- Show setup message
        RotationHelperDisplayNow:SetHidden(false)
        RotationHelperDisplayNext:SetHidden(false)

        if RotationHelperDisplayNowLabel then
            RotationHelperDisplayNowLabel:SetText("Use /rh smart to generate rotation")
            RotationHelperDisplayNowLabel:SetColor(1, 0.5, 0, 1)  -- Orange
        end
        if RotationHelperDisplayNextLabel then
            RotationHelperDisplayNextLabel:SetText("")  -- Hide NEXT when no rotation
            RotationHelperDisplayNextLabel:SetColor(1, 0.84, 0, 1)  -- Gold
        end
        return
    end

    -- Rotation exists: Hide display when out of combat
    if not inCombat then
        RotationHelperDisplayNow:SetHidden(true)
        RotationHelperDisplayNext:SetHidden(true)
        return
    end

    -- In combat with rotation: Show the displays
    RotationHelperDisplayNow:SetHidden(false)
    RotationHelperDisplayNext:SetHidden(false)

    -- Get current action based on index (loops automatically)
    local loopedIndex = ((currentActionIndex - 1) % #actionTimeline) + 1
    local currentAction = actionTimeline[loopedIndex]

    -- DYNAMIC: Find next READY action (might skip skills with active timers or missing stacks)
    local nextAction, nextReadyIndex = self:FindNextReadyAction(loopedIndex + 1, currentTime)

    -- Fallback if no ready action found (shouldn't happen)
    if not nextAction then
        nextAction = actionTimeline[(loopedIndex % #actionTimeline) + 1]
    end

    -- Build display text based on action type
    local nowText = ""
    local nowColor = {1, 1, 1, 1}
    local nextText = ""
    local nextColor = {1, 1, 1, 1}

    -- NOW action
    if currentAction.type == "LA" then
        local rtIcon = self:GetButtonIcon("RT", 40)
        if currentAction.needsBarSwap then
            nowText = "NOW: " .. rtIcon .. " (BS)"  -- Bar swap then light attack
        else
            nowText = "NOW: " .. rtIcon  -- Just light attack (RT = Right Trigger)
        end
        nowColor = {1, 0.84, 0, 1}  -- Gold
    elseif currentAction.type == "CAST" then
        local buttonText, slotIndex = currentAction.button, currentAction.slot
        if not slotIndex or not buttonText then
            buttonText, slotIndex = self:GetButtonForSkill(currentAction.name)
        end
        local abilityIcon = self:GetAbilityIcon(currentAction.name, 40)
        local buttonIcon = slotIndex and self:GetButtonIcon(slotIndex, 40) or buttonText
        nowText = "NOW: " .. abilityIcon .. " " .. buttonIcon .. " (Casting)"
        nowColor = {1, 0.65, 0, 1}  -- Orange (casting)
    elseif currentAction.type == "SKILL" then
        local buttonText, slotIndex = currentAction.button, currentAction.slot
        if not slotIndex or not buttonText then
            buttonText, slotIndex = self:GetButtonForSkill(currentAction.name)
        end
        local abilityIcon = self:GetAbilityIcon(currentAction.name, 40)
        local buttonIcon = slotIndex and self:GetButtonIcon(slotIndex, 40) or buttonText
        nowText = "NOW: " .. abilityIcon .. " " .. buttonIcon

        -- Check if this skill requires stacks
        if currentAction.requiresStacks and currentAction.name then
            local currentStacks = self:GetSkillStacks(currentAction.name)
            local requiredStacks = currentAction.requiredStackCount or 5

            if currentStacks >= requiredStacks then
                -- Proc is ready!
                nowText = nowText .. " (PROC READY!)"
                nowColor = {0, 1, 0, 1}  -- Green (ready!)
            elseif currentStacks > 0 then
                -- Building stacks, not ready yet
                nowText = nowText .. string.format(" (Wait %d/%d)", currentStacks, requiredStacks)
                nowColor = {1, 1, 0, 1}  -- Yellow (waiting)
            else
                -- Buff not active yet, cast to activate
                nowText = nowText .. " (Activate)"
                nowColor = {0.5, 0.5, 1, 1}  -- Light blue (initial cast)
            end
        elseif currentAction.isChannel then
            nowText = nowText .. " (Hold)"
            nowColor = {1, 0.39, 0.28, 1}  -- Red/Tomato
        else
            nowColor = {1, 0.39, 0.28, 1}  -- Red/Tomato
        end
    end

    -- NEXT action
    if nextAction.type == "LA" then
        local rtIcon = self:GetButtonIcon("RT", 32)
        if nextAction.needsBarSwap then
            nextText = "NEXT: " .. rtIcon .. " (BS)"
        else
            nextText = "NEXT: " .. rtIcon
        end
        nextColor = {1, 0.84, 0, 1}  -- Gold
    elseif nextAction.type == "CAST" then
        local buttonText, slotIndex = nextAction.button, nextAction.slot
        if not slotIndex or not buttonText then
            buttonText, slotIndex = self:GetButtonForSkill(nextAction.name)
        end
        local abilityIcon = self:GetAbilityIcon(nextAction.name, 32)
        local buttonIcon = slotIndex and self:GetButtonIcon(slotIndex, 32) or buttonText
        nextText = "NEXT: " .. abilityIcon .. " " .. buttonIcon .. " (Casting)"
        nextColor = {1, 0.65, 0, 1}  -- Orange (casting)
    elseif nextAction.type == "SKILL" then
        local buttonText, slotIndex = nextAction.button, nextAction.slot
        if not slotIndex or not buttonText then
            buttonText, slotIndex = self:GetButtonForSkill(nextAction.name)
        end
        local abilityIcon = self:GetAbilityIcon(nextAction.name, 32)
        local buttonIcon = slotIndex and self:GetButtonIcon(slotIndex, 32) or buttonText
        nextText = "NEXT: " .. abilityIcon .. " " .. buttonIcon

        -- Check if next skill requires stacks
        if nextAction.requiresStacks and nextAction.name then
            local currentStacks = self:GetSkillStacks(nextAction.name)
            local requiredStacks = nextAction.requiredStackCount or 5

            if currentStacks >= requiredStacks then
                nextText = nextText .. " (PROC READY!)"
                nextColor = {0, 1, 0, 1}  -- Green
            elseif currentStacks > 0 then
                nextText = nextText .. string.format(" (%d/%d)", currentStacks, requiredStacks)
                nextColor = {1, 1, 0, 1}  -- Yellow
            end
        elseif nextAction.isChannel then
            nextText = nextText .. " (Hold)"
            nextColor = {1, 0.39, 0.28, 1}  -- Red/Tomato
        else
            nextColor = {1, 0.39, 0.28, 1}  -- Red/Tomato
        end
    end

    -- Update NOW label
    if RotationHelperDisplayNowLabel then
        RotationHelperDisplayNowLabel:SetText(nowText)
        RotationHelperDisplayNowLabel:SetColor(unpack(nowColor))
    end

    -- Update NEXT label
    if RotationHelperDisplayNextLabel then
        RotationHelperDisplayNextLabel:SetText(nextText)
        RotationHelperDisplayNextLabel:SetColor(unpack(nextColor))
    end
end

-- Update timers display (DOTs, Buffs, Cooldowns)
function RotationHelper:UpdateTimersDisplay()
    if not RotationHelperTimers then
        return
    end

    -- Hide/show timers based on settings
    RotationHelperTimers:SetHidden(not RotationHelperSavedVars.showTimers)

    if not RotationHelperSavedVars.showTimers then
        return
    end

    local timerText = ""
    local currentTime = GetGameTimeMilliseconds()

    -- Display active DOTs
    local dotCount = 0
    for skillName, dot in pairs(activeDOTs) do
        local remaining = math.ceil((dot.expiryTime - currentTime) / 1000)
        if remaining > 0 then
            if dotCount > 0 then
                timerText = timerText .. "\n"
            end
            timerText = timerText .. string.format("|cFF6347%s: %ds|r", skillName, remaining)
            dotCount = dotCount + 1
        end
    end

    -- Display active buffs
    local buffCount = 0
    for skillName, buff in pairs(activeBuffs) do
        local remaining = math.ceil((buff.expiryTime - currentTime) / 1000)
        if remaining > 0 then
            if dotCount > 0 or buffCount > 0 then
                timerText = timerText .. "\n"
            end

            -- Check if this buff has stacks (like Merciless Resolve)
            local stackInfo = skillStacks[skillName]
            if stackInfo and stackInfo.active then
                local stackText = string.format(" [%d/%d]", stackInfo.stacks, stackInfo.requiredStacks)
                if stackInfo.stacks >= stackInfo.requiredStacks then
                    timerText = timerText .. string.format("|cFFFF00⚡ %s: %ds%s|r", skillName, remaining, stackText)
                else
                    timerText = timerText .. string.format("|c00FF00%s: %ds%s|r", skillName, remaining, stackText)
                end
            else
                timerText = timerText .. string.format("|c00FF00%s: %ds|r", skillName, remaining)
            end

            buffCount = buffCount + 1
        end
    end

    -- Display cooldowns (only show top 3 to avoid clutter)
    local cooldownList = {}
    for skillName, cd in pairs(skillCooldowns) do
        local remaining = math.ceil((cd.expiryTime - currentTime) / 1000)
        if remaining > 0 then
            table.insert(cooldownList, {name = skillName, remaining = remaining})
        end
    end

    -- Sort by remaining time (shortest first)
    table.sort(cooldownList, function(a, b) return a.remaining < b.remaining end)

    -- Show up to 3 cooldowns
    for i = 1, math.min(3, #cooldownList) do
        if dotCount > 0 or buffCount > 0 or i > 1 then
            timerText = timerText .. "\n"
        end
        timerText = timerText .. string.format("|cFFD700CD %s: %ds|r", cooldownList[i].name, cooldownList[i].remaining)
    end

    if RotationHelperTimersText then
        RotationHelperTimersText:SetText(timerText)
    end
end

-- Initialize UI
function RotationHelper:InitializeUI()
    -- UI will be created in XML, this just sets up references

    -- Setup NOW display
    if RotationHelperDisplayNow then
        RotationHelperDisplayNow:SetHidden(not RotationHelperSavedVars.showDDR)

        -- Apply UI scale, font sizes, and position
        self:ApplyUIScale()
        self:ApplyFontSizes()
        self:UpdateDisplayPosition()

        -- Set initial text (only if no rotation exists)
        local nowLabel = RotationHelperDisplayNowLabel
        if nowLabel then
            if #currentRotation == 0 then
                nowLabel:SetText("Use /rh smart to generate rotation")
                nowLabel:SetColor(1, 0.5, 0, 1)  -- Orange
            else
                -- Rotation exists, display will be updated by UpdateNextActionsDisplay
                nowLabel:SetText("Ready")
                nowLabel:SetColor(0, 1, 0, 1)  -- Green
            end
        end

        -- Setup position saving on move
        RotationHelperDisplayNow:SetHandler("OnMoveStop", function()
            self:SaveNowPosition()
        end)
    end

    -- Setup NEXT display
    if RotationHelperDisplayNext then
        RotationHelperDisplayNext:SetHidden(not RotationHelperSavedVars.showDDR)

        -- Set initial text (only if no rotation exists)
        local nextLabel = RotationHelperDisplayNextLabel
        if nextLabel then
            if #currentRotation == 0 then
                nextLabel:SetText("")  -- Hide NEXT when no rotation
            else
                -- Rotation exists, will be updated by UpdateNextActionsDisplay
                nextLabel:SetText("")
            end
        end

        -- Setup position saving on move
        RotationHelperDisplayNext:SetHandler("OnMoveStop", function()
            self:SaveNextPosition()
        end)
    end

    if RotationHelperStats then
        RotationHelperStats:SetHidden(false)
    end

    if RotationHelperTimers then
        RotationHelperTimers:SetHidden(not RotationHelperSavedVars.showTimers)
    end
end

-- Apply UI scale to all displays
function RotationHelper:ApplyUIScale()
    local scale = RotationHelperSavedVars.uiScale or 1.0

    if RotationHelperDisplayNow then
        RotationHelperDisplayNow:SetScale(scale)
    end
    if RotationHelperDisplayNext then
        RotationHelperDisplayNext:SetScale(scale)
    end
    if RotationHelperFeedback then
        RotationHelperFeedback:SetScale(scale)
    end
    if RotationHelperStats then
        RotationHelperStats:SetScale(scale)
    end
    if RotationHelperTimers then
        RotationHelperTimers:SetScale(scale)
    end
end

-- Apply font sizes to NOW and NEXT displays
function RotationHelper:ApplyFontSizes()
    local nowFontSize = RotationHelperSavedVars.nowFontSize or 42
    local nextFontSize = RotationHelperSavedVars.nextFontSize or 32

    -- ESO font format: "path|size|outline"
    -- Using ZoFontGame as base (it's a reliable system font)
    local nowFont = string.format("$(BOLD_FONT)|%d|soft-shadow-thick", nowFontSize)
    local nextFont = string.format("$(BOLD_FONT)|%d|soft-shadow-thick", nextFontSize)

    if RotationHelperDisplayNowLabel then
        RotationHelperDisplayNowLabel:SetFont(nowFont)
    end

    if RotationHelperDisplayNextLabel then
        RotationHelperDisplayNextLabel:SetFont(nextFont)
    end
end

-- Update display positions (console-friendly)
function RotationHelper:UpdateDisplayPosition()
    -- Update NOW position
    if RotationHelperDisplayNow then
        local nowPosX = RotationHelperSavedVars.nowPosX or 0
        local nowPosY = RotationHelperSavedVars.nowPosY or -300

        RotationHelperDisplayNow:ClearAnchors()
        RotationHelperDisplayNow:SetAnchor(BOTTOM, GuiRoot, BOTTOM, nowPosX, nowPosY)
    end

    -- Update NEXT position
    if RotationHelperDisplayNext then
        local nextPosX = RotationHelperSavedVars.nextPosX or 0
        local nextPosY = RotationHelperSavedVars.nextPosY or -210

        RotationHelperDisplayNext:ClearAnchors()
        RotationHelperDisplayNext:SetAnchor(BOTTOM, GuiRoot, BOTTOM, nextPosX, nextPosY)
    end
end

-- Save NOW display position
function RotationHelper:SaveNowPosition()
    if not RotationHelperDisplayNow then
        return
    end

    local _, _, _, _, offsX, offsY = RotationHelperDisplayNow:GetAnchor(0)
    RotationHelperSavedVars.nowPosX = offsX
    RotationHelperSavedVars.nowPosY = offsY
end

-- Save NEXT display position
function RotationHelper:SaveNextPosition()
    if not RotationHelperDisplayNext then
        return
    end

    local _, _, _, _, offsX, offsY = RotationHelperDisplayNext:GetAnchor(0)
    RotationHelperSavedVars.nextPosX = offsX
    RotationHelperSavedVars.nextPosY = offsY
end

-- Slash commands
SLASH_COMMANDS["/rh"] = function(args)
    if args == "toggle" then
        RotationHelperSavedVars.showDDR = not RotationHelperSavedVars.showDDR
        if RotationHelperDisplayNow then
            RotationHelperDisplayNow:SetHidden(not RotationHelperSavedVars.showDDR)
        end
        if RotationHelperDisplayNext then
            RotationHelperDisplayNext:SetHidden(not RotationHelperSavedVars.showDDR)
        end
        d("Rotation display " .. (RotationHelperSavedVars.showDDR and "shown" or "hidden"))
    elseif args == "timers" then
        RotationHelperSavedVars.showTimers = not RotationHelperSavedVars.showTimers
        d("Timers " .. (RotationHelperSavedVars.showTimers and "shown" or "hidden"))
    elseif args == "track" then
        RotationHelperSavedVars.trackingEnabled = not RotationHelperSavedVars.trackingEnabled
        d("Tracking " .. (RotationHelperSavedVars.trackingEnabled and "enabled" or "disabled"))
    elseif args == "reset" then
        RotationHelper:ResetCombatStats()
        d("Combat stats reset")
    elseif args == "stats" then
        RotationHelper:DisplayCombatSummary()
    elseif args == "summary" then
        RotationHelperSavedVars.showCombatSummary = not RotationHelperSavedVars.showCombatSummary
        d("Combat summary in chat " .. (RotationHelperSavedVars.showCombatSummary and "enabled" or "disabled"))
    elseif string.find(args, "^scale") then
        local scale = tonumber(string.match(args, "scale%s+([%d%.]+)"))
        if scale and scale >= 0.5 and scale <= 3.0 then
            RotationHelperSavedVars.uiScale = scale
            RotationHelper:ApplyUIScale()
            d(string.format("UI scale set to %.1fx", scale))
        else
            d("Current UI scale: " .. (RotationHelperSavedVars.uiScale or 1.0) .. "x")
            d("Usage: /rh scale <number>  (0.5 to 3.0)")
            d("Example: /rh scale 1.5  (recommended for console)")
        end
    elseif args == "skills" then
        if RotationHelper.SkillDB then
            d("Available skills in database:")
            local skills = RotationHelper.SkillDB:GetAllSkillNames()
            for i = 1, math.min(10, #skills) do
                d("  " .. skills[i])
            end
            d("  ... and " .. (#skills - 10) .. " more")
            d("See SkillDatabase.lua for full list")
        else
            d("Skill database not loaded")
        end
    elseif args == "rotation" or args == "builder" then
        d("|cFFD700Rotation Builder moved to Settings Menu!|r")
        d("Press ESC > Settings > Add-ons > Rotation Helper > |cFFD700Rotation Builder|r")
        d("(Console-friendly with controller navigation!)")
    elseif args == "rotation clear" then
        RotationHelper:ClearRotation()
    elseif args == "rotation example" then
        RotationHelper:LoadExampleRotation()
    elseif args == "rotation show" then
        d("|cFFD700Current Rotation:|r")
        d("(Advances when you execute actions, loops automatically)")
        d(RotationHelper:GetRotationListText())
    elseif args == "rotation smart" or args == "smart" then
        RotationHelper:GenerateSmartRotation()
    elseif args == "scan" or args == "bars" then
        RotationHelper:ShowBarScan()
    elseif args == "potion" then
        if RotationHelper:IsPotionReady() then
            d("|c00FF00Potion is ready!|r")
        else
            local remaining = RotationHelper:GetPotionCooldownRemaining()
            d(string.format("|cFFFF00Potion ready in %.1f seconds|r", remaining))
        end
    elseif args == "queue" then
        d("|cFFD700=== Skill Queue Status ===|r")
        d("(Queue now ONLY contains skills - LA and bar swaps are auto-inserted)")
        d(string.format("Total skills in queue: %d", #actionQueue))
        d(string.format("Total skills in rotation: %d", #currentRotation))

        -- Count executed vs unexecuted
        local executedCount = 0
        for i, skill in ipairs(actionQueue) do
            if skill.executed then
                executedCount = executedCount + 1
            end
        end
        d(string.format("Executed: %d, Remaining: %d", executedCount, #actionQueue - executedCount))

        d(" ")
        d("|cFFD700All skills in queue:|r")
        for i, skill in ipairs(actionQueue) do
            local status = skill.executed and "|c808080[DONE]|r" or "|c00FF00[TODO]|r"
            local bar = skill.bar or "?"
            d(string.format("  %d. %s %s (Bar: %s)", i, status, skill.name, bar))
        end
    elseif args == "timeline" then
        d("|cFFD700=== Action Timeline (with durations) ===|r")
        if #actionTimeline == 0 then
            d("No timeline built. Generate rotation and enter combat first.")
        else
            local totalTime = actionTimeline[#actionTimeline].endTime / 1000
            d(string.format("Total actions: %d, Total rotation time: %.1f seconds", #actionTimeline, totalTime))
            d(" ")
            d("|cFFD700Timeline breakdown:|r")
            for i, action in ipairs(actionTimeline) do
                local color = "|cFFFFFF"
                if action.type == "LA" then
                    color = "|cFFD700"  -- Gold
                elseif action.type == "CAST" then
                    color = "|cFFA500"  -- Orange
                elseif action.type == "SKILL" then
                    color = "|cFF6347"  -- Red/Tomato
                end

                local displayName = action.name
                if action.isChannel and action.type == "SKILL" then
                    displayName = displayName .. " (CHANNEL)"
                end
                if action.needsBarSwap then
                    displayName = displayName .. " (BS)"
                end

                d(string.format("%s%d. %s - %s (%.1fs @ %.1fs)|r",
                    color, i, action.type, displayName,
                    action.duration / 1000, action.startTime / 1000))
            end
        end
    elseif args == "next" or args == "skip" then
        -- Manual advance for testing/debugging
        if #actionTimeline == 0 then
            d("|cFF0000No timeline loaded. Use /rh smart first.|r")
        else
            currentActionIndex = currentActionIndex + 1
            local loopedIndex = ((currentActionIndex - 1) % #actionTimeline) + 1
            local currentAction = actionTimeline[loopedIndex]
            d(string.format("|c00FF00✓ Manually advanced to action %d: %s|r", loopedIndex, currentAction.name or currentAction.type))
        end
    elseif args == "ready" then
        -- Show which skills are ready to cast (dynamic rotation system)
        d("|cFFD700=== Skill Readiness Check ===|r")
        local currentTime = GetGameTimeMilliseconds()

        if #currentRotation == 0 then
            d("No rotation loaded. Use /rh smart first.")
            return
        end

        d(" ")
        local checkedSkills = {}
        for i, skill in ipairs(currentRotation) do
            if skill.type == ACTION_TYPES.SKILL and not checkedSkills[skill.name] then
                checkedSkills[skill.name] = true
                local isReady, reason, priority = self:IsSkillReady(skill.name, currentTime)
                local statusColor = isReady and "|c00FF00" or "|cFF0000"
                local statusText = isReady and "READY" or "NOT READY"
                d(string.format("%s%s: %s|r - %s (priority: %d)", statusColor, skill.name, statusText, reason, priority))
            end
        end

        d(" ")
        d("|cFFD700Next Ready Skill:|r")
        local nextReady, nextIndex = self:FindNextReadyAction(currentActionIndex, currentTime)
        if nextReady and nextReady.type == "SKILL" then
            d(string.format("  → %s (button: %s)", nextReady.name, nextReady.button or "?"))
        elseif nextReady and nextReady.type == "LA" then
            d("  → Light Attack")
        else
            d("  → None found (keep spamming)")
        end
    elseif args == "chars" or args == "characters" then
        d("|cFFD700=== Characters with Rotations ===|r")
        local currentChar = self:GetCharacterKey()
        local charCount = 0
        if RotationHelperSavedVars.characters then
            for charKey, charData in pairs(RotationHelperSavedVars.characters) do
                local rotationCount = charData.rotation and #charData.rotation or 0
                if rotationCount > 0 then
                    local isCurrent = charKey == currentChar and " |c00FF00(CURRENT)|r" or ""
                    d(string.format("  %s: %d skills%s", charKey, rotationCount, isCurrent))
                    charCount = charCount + 1
                end
            end
        end
        if charCount == 0 then
            d("No characters have rotations saved yet")
        end
    elseif args == "debug" or args == "status" then
        d("|cFFD700=== Rotation Helper Status ===|r")
        d(string.format("ACTION_TYPES.LIGHT_ATTACK = %d", ACTION_TYPES.LIGHT_ATTACK))
        d(string.format("ACTION_TYPES.SKILL = %d", ACTION_TYPES.SKILL))
        d(string.format("ACTION_TYPES.BAR_SWAP = %d", ACTION_TYPES.BAR_SWAP))
        d(string.format("ACTION_TYPES.POTION = %d", ACTION_TYPES.POTION))
        d(" ")
        d(string.format("currentRotation: %d actions", #currentRotation))
        d(string.format("actionQueue: %d actions", #actionQueue))
        d(string.format("inCombat: %s", tostring(inCombat)))
        d(string.format("trackingEnabled: %s", tostring(RotationHelperSavedVars.trackingEnabled)))
        d(string.format("showDDR: %s", tostring(RotationHelperSavedVars.showDDR)))
        d(" ")
        d("|cFFD700UI Controls Status:|r")
        d(string.format("RotationHelperDisplayNow exists: %s", tostring(RotationHelperDisplayNow ~= nil)))
        if RotationHelperDisplayNow then
            d(string.format("  - Hidden: %s", tostring(RotationHelperDisplayNow:IsHidden())))
            d(string.format("  - Alpha: %.2f", RotationHelperDisplayNow:GetAlpha()))
            local _, _, _, _, x, y = RotationHelperDisplayNow:GetAnchor(0)
            d(string.format("  - Position: X=%d, Y=%d", x or 0, y or 0))
        end
        d(string.format("RotationHelperDisplayNext exists: %s", tostring(RotationHelperDisplayNext ~= nil)))
        if RotationHelperDisplayNext then
            d(string.format("  - Hidden: %s", tostring(RotationHelperDisplayNext:IsHidden())))
            d(string.format("  - Alpha: %.2f", RotationHelperDisplayNext:GetAlpha()))
            local _, _, _, _, x, y = RotationHelperDisplayNext:GetAnchor(0)
            d(string.format("  - Position: X=%d, Y=%d", x or 0, y or 0))
        end
        d(" ")
        d("|cFFD700Skill Queue (NEW SYSTEM):|r")
        d("Queue only contains SKILLS now (LA and swaps auto-inserted)")
        if #currentRotation > 0 then
            d("First 3 skills in rotation:")
            for i = 1, math.min(3, #currentRotation) do
                local skill = currentRotation[i]
                d(string.format("  %d. %s (Bar: %s)", i, skill.name or "N/A", skill.bar or "?"))
            end
        else
            d("No skills in rotation - use /rh smart")
        end
    else
        d("|cFFD700Rotation Helper - Console Optimized!|r")
        d(" ")
        d("|c00FF00DYNAMIC ROTATION SYSTEM:|r")
        d("• Shows BUTTON to press (RT, X, Y, B, LB, RB)")
        d("• (BS) = Swap bars first, (Hold) = Channel skill")
        d("• SKIPS skills with active timers (>1s remaining)")
        d("• SKIPS skills waiting for stacks (not ready yet)")
        d("• PRIORITIZES skills about to expire (<1s) or procs ready")
        d("• Merciless Resolve: Shows (Wait X/5) or (PROC READY!)")
        d(" ")
        d("|cFFD700Button Mapping (Xbox/PS):|r")
        d("  RT/R2 = Light Attack")
        d("  X/Square, Y/Triangle, B/Circle, LB/L1, RB/R1 = Skills")
        d("  Back/Select = Bar Swap")
        d(" ")
        d("|cFFD700Display:|r")
        d("  /rh toggle - Show/hide rotation display")
        d("  /rh timers - Toggle timer display")
        d("  /rh summary - Toggle combat summary in chat")
        d("  /rh scale <number> - Set UI scale (console: 1.5-2.0)")
        d(" ")
        d("|cFFD700Smart Rotation (Recommended!):|r")
        d("  /rh scan - Scan your skill bars")
        d("  /rh smart - Generate optimized rotation from your bars")
        d("  /rh potion - Check potion cooldown")
        d(" ")
        d("|cFFD700Manual Rotation:|r")
        d("  /rh rotation show - Show current rotation")
        d("  /rh rotation example - Load example rotation")
        d("  /rh rotation clear - Clear rotation")
        d("  /rh chars - List all characters with rotations")
        d("  /rh queue - Show skill queue status")
        d("  /rh timeline - Show full timeline with durations")
        d(" ")
        d("|c00FF00NOTE:|r Rotations are saved per character!")
        d(" ")
        d("|cFFD700Other:|r")
        d("  /rh track - Toggle tracking")
        d("  /rh reset - Reset stats")
        d("  /rh stats - Show stats manually")
        d("  /rh ready - Check which skills are ready to cast (dynamic)")
        d("  /rh next - Manually advance to next action (for testing)")
        d("  /rh debug - Show rotation status & troubleshooting info")
        d(" ")
        d("|c00FF00TIP:|r Use ESC > Settings > Add-ons > Rotation Helper for all options")
        d("|c00FF00NOTE:|r (BS) means swap bars before doing that action")
    end
end

-- Create settings menu using LibAddonMenu

-- Create settings menu using LibAddonMenu with Rotation Builder submenu
-- This is the replacement code for the CreateSettingsMenu function
-- This version includes a Rotation Builder submenu instead of a separate window
-- CONSOLE-FRIENDLY: Uses LibAddonMenu which works with controller navigation

function RotationHelper:CreateSettingsMenu()
    -- Check if LibAddonMenu is available
    if not LibAddonMenu2 then
        d("Rotation Helper: LibAddonMenu-2.0 not found. Settings menu disabled. Use /rh commands instead.")
        return
    end

    local LAM = LibAddonMenu2

    -- Initialize builder variables
    self.builderActionType = ACTION_TYPES.LIGHT_ATTACK
    self.builderSkillName = ""
    self.builderDuration = 1000

    local panelData = {
        type = "panel",
        name = "Rotation Helper",
        displayName = "Rotation Helper",
        author = "YourName",
        version = "1.0.0",
        registerForRefresh = true,
        registerForDefaults = true,
    }

    LAM:RegisterAddonPanel("RotationHelperSettings", panelData)

    -- Define ADDON_DATA before using it in callbacks
    ADDON_DATA = "RotationHelperSettings"

    local optionsData = {
        -- Header
        {
            type = "header",
            name = "Display Settings",
        },
        -- Show Rotation Display
        {
            type = "checkbox",
            name = "Show Rotation Display",
            tooltip = "Toggle the on-screen rotation helper (shows next actions to perform)",
            getFunc = function() return RotationHelperSavedVars.showDDR end,
            setFunc = function(value)
                RotationHelperSavedVars.showDDR = value
                if RotationHelperDisplayNow then
                    RotationHelperDisplayNow:SetHidden(not value)
                end
                if RotationHelperDisplayNext then
                    RotationHelperDisplayNext:SetHidden(not value)
                end
            end,
            default = true,
        },
        -- Show Timers
        {
            type = "checkbox",
            name = "Show Timers (DOTs/Buffs/Cooldowns)",
            tooltip = "Toggle the display of active DOTs, buffs, and cooldowns",
            getFunc = function() return RotationHelperSavedVars.showTimers end,
            setFunc = function(value)
                RotationHelperSavedVars.showTimers = value
            end,
            default = true,
        },
        -- Show Combat Summary
        {
            type = "checkbox",
            name = "Show Combat Summary in Chat",
            tooltip = "Automatically display light attack statistics in chat when combat ends",
            getFunc = function() return RotationHelperSavedVars.showCombatSummary end,
            setFunc = function(value)
                RotationHelperSavedVars.showCombatSummary = value
            end,
            default = true,
        },
        -- Rotation Advance Warning
        {
            type = "slider",
            name = "Action Advance Warning (seconds)",
            tooltip = "How far ahead to show upcoming actions. Higher values give you more time to prepare for the next action.",
            min = 0.5,
            max = 5.0,
            step = 0.1,
            getFunc = function() return RotationHelperSavedVars.ddRSpeed end,
            setFunc = function(value)
                RotationHelperSavedVars.ddRSpeed = value
            end,
            default = 1.5,
        },
        -- UI Scale Slider
        {
            type = "slider",
            name = "UI Scale",
            tooltip = "Scale the entire window for better visibility. Increase for console/TV, decrease for small monitors. Console default: 1.5x, PC default: 1.0x",
            min = 0.5,
            max = 3.0,
            step = 0.1,
            getFunc = function() return RotationHelperSavedVars.uiScale end,
            setFunc = function(value)
                RotationHelperSavedVars.uiScale = value
                RotationHelper:ApplyUIScale()
            end,
            default = 1.0,
        },

        -- Font Size Header
        {
            type = "header",
            name = "Font Sizes",
        },
        -- NOW Font Size
        {
            type = "slider",
            name = "NOW Font Size",
            tooltip = "Font size for the NOW display. Larger = easier to see during combat. Default: 42",
            min = 20,
            max = 80,
            step = 2,
            getFunc = function() return RotationHelperSavedVars.nowFontSize end,
            setFunc = function(value)
                RotationHelperSavedVars.nowFontSize = value
                RotationHelper:ApplyFontSizes()
            end,
            default = 42,
        },
        -- NEXT Font Size
        {
            type = "slider",
            name = "NEXT Font Size",
            tooltip = "Font size for the NEXT display. Usually smaller than NOW. Default: 32",
            min = 16,
            max = 60,
            step = 2,
            getFunc = function() return RotationHelperSavedVars.nextFontSize end,
            setFunc = function(value)
                RotationHelperSavedVars.nextFontSize = value
                RotationHelper:ApplyFontSizes()
            end,
            default = 32,
        },

        -- NOW Position Header
        {
            type = "header",
            name = "NOW Display Position",
        },
        -- NOW Position X Slider
        {
            type = "slider",
            name = "NOW - Horizontal (X)",
            tooltip = "Move the NOW display left or right. 0 = center, negative = left, positive = right. You can also drag the NOW text directly!",
            min = -1000,
            max = 1000,
            step = 10,
            getFunc = function() return RotationHelperSavedVars.nowPosX end,
            setFunc = function(value)
                RotationHelperSavedVars.nowPosX = value
                RotationHelper:UpdateDisplayPosition()
            end,
            default = 0,
        },
        -- NOW Position Y Slider
        {
            type = "slider",
            name = "NOW - Vertical (Y)",
            tooltip = "Move the NOW display up or down. More negative = higher on screen, less negative = lower. You can also drag the NOW text directly!",
            min = -1000,
            max = 0,
            step = 10,
            getFunc = function() return RotationHelperSavedVars.nowPosY end,
            setFunc = function(value)
                RotationHelperSavedVars.nowPosY = value
                RotationHelper:UpdateDisplayPosition()
            end,
            default = -300,
        },

        -- NEXT Position Header
        {
            type = "header",
            name = "NEXT Display Position",
        },
        -- NEXT Position X Slider
        {
            type = "slider",
            name = "NEXT - Horizontal (X)",
            tooltip = "Move the NEXT display left or right. 0 = center, negative = left, positive = right. You can also drag the NEXT text directly!",
            min = -1000,
            max = 1000,
            step = 10,
            getFunc = function() return RotationHelperSavedVars.nextPosX end,
            setFunc = function(value)
                RotationHelperSavedVars.nextPosX = value
                RotationHelper:UpdateDisplayPosition()
            end,
            default = 0,
        },
        -- NEXT Position Y Slider
        {
            type = "slider",
            name = "NEXT - Vertical (Y)",
            tooltip = "Move the NEXT display up or down. More negative = higher on screen, less negative = lower. You can also drag the NEXT text directly!",
            min = -1000,
            max = 0,
            step = 10,
            getFunc = function() return RotationHelperSavedVars.nextPosY end,
            setFunc = function(value)
                RotationHelperSavedVars.nextPosY = value
                RotationHelper:UpdateDisplayPosition()
            end,
            default = -210,
        },

        -- Header: Tracking Settings
        {
            type = "header",
            name = "Tracking Settings",
        },
        -- Enable Tracking
        {
            type = "checkbox",
            name = "Enable Combat Tracking",
            tooltip = "Track light attacks, skills, and rotation timing in combat",
            getFunc = function() return RotationHelperSavedVars.trackingEnabled end,
            setFunc = function(value)
                RotationHelperSavedVars.trackingEnabled = value
            end,
            default = true,
        },

        -- Header: Rotation Management
        {
            type = "submenu",
            name = "Rotation Management",
            tooltip = "Use slash commands to manage your rotation",
            controls = {
                -- Instructions
                {
                    type = "description",
                    title = "Use Slash Commands",
                    text = "All rotation management is done through slash commands.\n\nType |cFFD700/rh|r in chat to see all available commands.",
                },

                -- Smart Rotation Section
                {
                    type = "header",
                    name = "Smart Rotation (Recommended)",
                },
                {
                    type = "description",
                    text = "|cFFD700/rh scan|r - Scan your current skill bars\n|cFFD700/rh smart|r - Generate optimized rotation from your bars\n\nThis automatically creates a rotation with LA weaving, bar swaps, and proper skill priorities!",
                },

                -- View Rotation Section
                {
                    type = "header",
                    name = "View & Clear Rotation",
                },
                {
                    type = "description",
                    text = "|cFFD700/rh rotation show|r - Show current rotation\n|cFFD700/rh rotation clear|r - Clear all actions\n|cFFD700/rh rotation example|r - Load example rotation",
                },

                -- Additional Commands
                {
                    type = "header",
                    name = "Other Commands",
                },
                {
                    type = "description",
                    text = "|cFFD700/rh queue|r - Show skill queue status\n|cFFD700/rh timeline|r - Show full timeline\n|cFFD700/rh ready|r - Check which skills are ready\n|cFFD700/rh potion|r - Check potion cooldown",
                },
            },
        },

        -- Header: Information
        {
            type = "header",
            name = "Information",
        },
        -- Description
        {
            type = "description",
            text = "Rotation Helper is a DDR-style rotation trainer with light attack tracking, DOT/buff/cooldown timers, and multi-class support.\n\nUse /rh for slash commands.\nUse /rh skills to see available skills in the database.",
        },
        -- Button to reset stats
        {
            type = "button",
            name = "Reset Combat Stats",
            tooltip = "Reset light attack tracking and combat statistics",
            func = function()
                RotationHelper:ResetCombatStats()
                d("Combat stats reset!")
            end,
        },
    }

    LAM:RegisterOptionControls(ADDON_DATA, optionsData)
end

-- Helper function to get rotation list as text
function RotationHelper:GetRotationListText()
    if not currentRotation or #currentRotation == 0 then
        return "No skills in rotation. Use 'Generate Smart Rotation' or add skills manually.\n\nNote: Queue now only contains skills. LA weaving and bar swaps are auto-inserted!"
    end

    local text = "Current Rotation (Skills Only):\n"
    text = text .. "LA weaving and bar swaps are auto-inserted during combat.\n\n"

    for i, skill in ipairs(currentRotation) do
        local bar = skill.bar or "unknown"
        local barColor = bar == "front" and "|c00FF00" or "|c4D9BFF"
        text = text .. string.format("|cFF6347%d. %s|r [%s%s Bar|r]\n", i, skill.name or "Unknown", barColor, bar)
    end

    return text
end

-- Simplified InitializeRotationBuilder (no window needed)
function RotationHelper:InitializeRotationBuilder()
    -- Nothing to initialize - rotation builder is now in LibAddonMenu!
    self.builderSelectedSkill = "-- Select a skill --"
    self.cachedSkillBars = {}  -- Cache for skill bar scan
end

-- Scan and cache skill bars for rotation builder
function RotationHelper:ScanAndCacheSkillBars()
    local frontBar, backBar = self:ScanSkillBars()

    -- Combine both bars into a single list
    self.cachedSkillBars = {}

    for _, skill in ipairs(frontBar) do
        table.insert(self.cachedSkillBars, skill)
    end

    for _, skill in ipairs(backBar) do
        table.insert(self.cachedSkillBars, skill)
    end
end

-- Get cached skill choices for dropdown
function RotationHelper:GetCachedSkillChoices()
    local choices = {"-- Select a skill --"}

    if not self.cachedSkillBars or #self.cachedSkillBars == 0 then
        table.insert(choices, "-- Scan your bars first --")
        return choices
    end

    for _, skill in ipairs(self.cachedSkillBars) do
        local barLabel = skill.bar == "front" and "[Front]" or "[Back]"
        table.insert(choices, string.format("%s %s", barLabel, skill.name))
    end

    return choices
end

-- Get cached skill info by name
function RotationHelper:GetCachedSkillInfo(displayName)
    if not self.cachedSkillBars then
        return nil
    end

    -- Strip the bar label prefix if present
    local skillName = displayName:match("%[.-%] (.+)") or displayName

    for _, skill in ipairs(self.cachedSkillBars) do
        if skill.name == skillName then
            return skill
        end
    end

    return nil
end

-- Add action to rotation
function RotationHelper:AddActionToRotation(actionType, skillName, duration)
    local action = {
        type = actionType,
        name = skillName,
        duration = duration or 1000
    }

    table.insert(currentRotation, action)
    self:SaveRotation()

    d("Action added to rotation for current character")
end

-- Delete action from rotation
function RotationHelper:DeleteRotationAction(index)
    if not currentRotation or index < 1 or index > #currentRotation then
        return
    end

    table.remove(currentRotation, index)
    self:SaveRotation()

    d("Action removed from rotation for current character")
end

-- Clear rotation
function RotationHelper:ClearRotation()
    currentRotation = {}
    self:SaveRotation()
    d("Rotation cleared for current character")
end

-- Load example rotation (skills only - LA and swaps are auto-inserted)
function RotationHelper:LoadExampleRotation()
    currentRotation = {
        {type = ACTION_TYPES.SKILL, name = "Spammable 1", duration = 1000, bar = "front"},
        {type = ACTION_TYPES.SKILL, name = "Spammable 2", duration = 1000, bar = "front"},
        {type = ACTION_TYPES.SKILL, name = "DOT Skill", duration = 1000, bar = "back"},
        {type = ACTION_TYPES.SKILL, name = "Buff Skill", duration = 1000, bar = "back"},
        {type = ACTION_TYPES.SKILL, name = "Spammable 1", duration = 1000, bar = "front"},
        {type = ACTION_TYPES.SKILL, name = "Spammable 2", duration = 1000, bar = "front"},
    }

    self:SaveRotation()
    d("Example rotation loaded (6 skills)")
    d("LA weaving and bar swaps will be auto-inserted during combat")
end

-- Initialize addon when loaded
function RotationHelper.OnAddOnLoaded(event, addonName)
    if addonName == RotationHelper.name then
        RotationHelper:Initialize()
        EVENT_MANAGER:UnregisterForEvent(RotationHelper.name, EVENT_ADD_ON_LOADED)
    end
end

EVENT_MANAGER:RegisterForEvent(RotationHelper.name, EVENT_ADD_ON_LOADED, RotationHelper.OnAddOnLoaded)
-- Smart Rotation System
-- Scans skill bars, auto-generates rotation with LA weaving, potion timing, GCD awareness

-- Constants (use ESO global constants if available, otherwise define them)
local ACTION_BAR_FIRST_NORMAL_SLOT_INDEX = ACTION_BAR_FIRST_NORMAL_SLOT_INDEX or 3
local ACTION_BAR_ULTIMATE_SLOT_INDEX = ACTION_BAR_ULTIMATE_SLOT_INDEX or 8
-- ESO uses 1 and 2 for hotbar categories, but let's make sure we have them
local HOTBAR_PRIMARY = HOTBAR_CATEGORY_PRIMARY or 1
local HOTBAR_BACKUP = HOTBAR_CATEGORY_BACKUP or 2
local POTION_COOLDOWN = 45000  -- 45 seconds
local GCD = 1000  -- Standard Global Cooldown
local ABILITY_QUEUE_WINDOW = 400  -- ESO's ability queue window

-- Track potion cooldown
local lastPotionTime = 0
local potionCooldownRemaining = 0

-- Get button name for slot (console-friendly)
function RotationHelper:GetButtonName(slotIndex)
    -- Xbox button names (PlayStation similar)
    if slotIndex == 3 then
        return "X"  -- Square on PS
    elseif slotIndex == 4 then
        return "Y"  -- Triangle on PS
    elseif slotIndex == 5 then
        return "B"  -- Circle on PS
    elseif slotIndex == 6 then
        return "LB"  -- L1 on PS
    elseif slotIndex == 7 then
        return "RB"  -- R1 on PS
    else
        return tostring(slotIndex)
    end
end

-- Get button icon for slot (uses ESO's gamepad icons)
function RotationHelper:GetButtonIcon(slotIndex, iconSize)
    iconSize = iconSize or 32  -- Default icon size

    -- Map slots to ESO keybind constants
    -- ESO button mapping: BUTTON_1=A, BUTTON_2=B, BUTTON_3=X, BUTTON_4=Y
    local keyCode = nil
    if slotIndex == 3 then
        keyCode = KEY_GAMEPAD_BUTTON_3  -- X / Square
    elseif slotIndex == 4 then
        keyCode = KEY_GAMEPAD_BUTTON_4  -- Y / Triangle
    elseif slotIndex == 5 then
        keyCode = KEY_GAMEPAD_BUTTON_2  -- B / Circle
    elseif slotIndex == 6 then
        keyCode = KEY_GAMEPAD_LEFT_SHOULDER  -- LB / L1
    elseif slotIndex == 7 then
        keyCode = KEY_GAMEPAD_RIGHT_SHOULDER  -- RB / R1
    elseif slotIndex == "RT" or slotIndex == "LA" then
        keyCode = KEY_GAMEPAD_RIGHT_TRIGGER  -- RT / R2
    end

    if keyCode and ZO_Keybindings_GetTexturePathForKey then
        local iconPath = ZO_Keybindings_GetTexturePathForKey(keyCode)
        if iconPath and iconPath ~= "" then
            return zo_iconFormat(iconPath, iconSize, iconSize)
        end
    end

    -- Fallback to text if icons not available
    if slotIndex == "RT" or slotIndex == "LA" then
        return "RT"
    end
    return self:GetButtonName(slotIndex)
end

-- Get button for a skill by scanning skill bars (fallback for missing button data)
-- Returns: buttonText, slotIndex, abilityId
function RotationHelper:GetButtonForSkill(skillName)
    if not skillName or skillName == "" then
        return "?", nil, nil
    end

    -- Scan both bars to find this skill
    for slotIndex = 3, 7 do
        -- Check front bar
        local abilityId = GetSlotBoundId(slotIndex, HOTBAR_CATEGORY_PRIMARY or 1)
        if abilityId and abilityId > 0 then
            local abilityName = GetAbilityName(abilityId)
            if abilityName and abilityName == skillName then
                return self:GetButtonName(slotIndex), slotIndex, abilityId
            end
        end

        -- Check back bar
        abilityId = GetSlotBoundId(slotIndex, HOTBAR_CATEGORY_BACKUP or 2)
        if abilityId and abilityId > 0 then
            local abilityName = GetAbilityName(abilityId)
            if abilityName and abilityName == skillName then
                return self:GetButtonName(slotIndex), slotIndex, abilityId
            end
        end
    end

    return "?", nil, nil  -- Not found
end

-- Get ability icon for a skill
-- Returns: formatted icon string or empty string
function RotationHelper:GetAbilityIcon(skillName, iconSize)
    iconSize = iconSize or 40

    if not skillName or skillName == "" then
        return ""
    end

    -- Scan both bars to find this skill and get its icon
    for slotIndex = 3, 7 do
        -- Check front bar
        local abilityId = GetSlotBoundId(slotIndex, HOTBAR_CATEGORY_PRIMARY or 1)
        if abilityId and abilityId > 0 then
            local abilityName = GetAbilityName(abilityId)
            if abilityName and abilityName == skillName then
                local iconPath = GetSlotTexture(slotIndex, HOTBAR_CATEGORY_PRIMARY or 1)
                if iconPath and iconPath ~= "" then
                    return zo_iconFormat(iconPath, iconSize, iconSize)
                end
            end
        end

        -- Check back bar
        abilityId = GetSlotBoundId(slotIndex, HOTBAR_CATEGORY_BACKUP or 2)
        if abilityId and abilityId > 0 then
            local abilityName = GetAbilityName(abilityId)
            if abilityName and abilityName == skillName then
                local iconPath = GetSlotTexture(slotIndex, HOTBAR_CATEGORY_BACKUP or 2)
                if iconPath and iconPath ~= "" then
                    return zo_iconFormat(iconPath, iconSize, iconSize)
                end
            end
        end
    end

    return ""  -- Not found
end

-- Scan player's skill bars and return skill info
function RotationHelper:ScanSkillBars()
    local frontBar = {}
    local backBar = {}

    -- Scan front bar (primary) - slots 3 through 7
    for slotIndex = 3, 7 do
        local abilityId = GetSlotBoundId(slotIndex, HOTBAR_PRIMARY)
        if abilityId and abilityId > 0 then
            local abilityName = GetAbilityName(abilityId)
            if abilityName and abilityName ~= "" then
                table.insert(frontBar, {
                    slot = slotIndex,
                    abilityId = abilityId,
                    name = abilityName,
                    bar = "front",
                    button = self:GetButtonName(slotIndex)
                })
            end
        end
    end

    -- Scan back bar (backup) - slots 3 through 7
    for slotIndex = 3, 7 do
        local abilityId = GetSlotBoundId(slotIndex, HOTBAR_BACKUP)
        if abilityId and abilityId > 0 then
            local abilityName = GetAbilityName(abilityId)
            if abilityName and abilityName ~= "" then
                table.insert(backBar, {
                    slot = slotIndex,
                    abilityId = abilityId,
                    name = abilityName,
                    bar = "back",
                    button = self:GetButtonName(slotIndex)
                })
            end
        end
    end

    return frontBar, backBar
end

-- Categorize skills using the skill database
function RotationHelper:CategorizeSkills(skills)
    local dots = {}
    local buffs = {}
    local spammables = {}
    local channels = {}

    for _, skill in ipairs(skills) do
        local skillInfo = nil
        if RotationHelper.SkillDB then
            skillInfo = RotationHelper.SkillDB:GetSkillInfo(skill.name)
        end

        if skillInfo then
            skill.duration = skillInfo.duration or GCD
            skill.cooldown = skillInfo.cooldown or 0
            skill.skillType = skillInfo.type

            if skillInfo.isDOT then
                table.insert(dots, skill)
            elseif skillInfo.isBuff then
                table.insert(buffs, skill)
            elseif skillInfo.isChannel then
                skill.isChannel = true
                table.insert(channels, skill)
            else
                table.insert(spammables, skill)
            end
        else
            -- Unknown skill - assume spammable with GCD
            skill.duration = GCD
            skill.cooldown = 0
            table.insert(spammables, skill)
        end
    end

    return {
        dots = dots,
        buffs = buffs,
        spammables = spammables,
        channels = channels
    }
end

-- Generate smart rotation with LA weaving and proper timing
function RotationHelper:GenerateSmartRotation()
    local frontBar, backBar = self:ScanSkillBars()

    if #frontBar == 0 and #backBar == 0 then
        d("|cFF0000No skills found on your bars!|r")
        return false
    end

    d("|cFFD700Scanning skill bars...|r")
    d(string.format("Front bar: %d skills, Back bar: %d skills", #frontBar, #backBar))

    -- Categorize skills
    local frontSkills = self:CategorizeSkills(frontBar)
    local backSkills = self:CategorizeSkills(backBar)

    -- Build rotation
    local rotation = {}
    local totalTime = 0
    local onBackBar = false

    -- Helper to add skill to rotation (LA weaving and bar swaps are handled by display, not queue)
    local function addSkill(skill)
        local skillDuration = skill.duration or GCD
        table.insert(rotation, {
            type = ACTION_TYPES.SKILL,
            duration = skillDuration,
            name = skill.name,
            bar = skill.bar,       -- Track which bar this skill is on (front or back)
            button = skill.button, -- Button name (X, Y, B, LB, RB)
            slot = skill.slot      -- Slot index (3-7)
        })
        totalTime = totalTime + skillDuration
    end

    -- ROTATION LOGIC:
    -- Queue only contains SKILLS (in execution order)
    -- LA weaving and bar swaps are automatically handled by the display
    -- 1. Start on front bar
    -- 2. If have back bar DOTs/buffs, add them to rotation
    -- 3. Add front bar spammables
    -- 4. Repeat

    local skillCount = 0

    -- Apply back bar DOTs and buffs first (if any)
    if #backSkills.dots > 0 or #backSkills.buffs > 0 or #backSkills.channels > 0 then
        -- Apply all DOTs
        for _, dot in ipairs(backSkills.dots) do
            addSkill(dot)
            skillCount = skillCount + 1
        end

        -- Apply all buffs
        for _, buff in ipairs(backSkills.buffs) do
            addSkill(buff)
            skillCount = skillCount + 1
        end

        -- Add channels if any
        for _, channel in ipairs(backSkills.channels) do
            addSkill(channel)
            skillCount = skillCount + 1
        end
    end

    -- Front bar spammable rotation
    local spammableCount = #frontSkills.spammables
    if spammableCount > 0 then
        -- Cast 3-5 spammables
        local spammableCasts = math.min(5, math.max(3, spammableCount))
        for i = 1, spammableCasts do
            local spammable = frontSkills.spammables[((i - 1) % spammableCount) + 1]
            addSkill(spammable)
            skillCount = skillCount + 1
        end
    end

    -- If rotation too short (less than 6 skills), add more spammables
    if skillCount < 6 and #frontSkills.spammables > 0 then
        local additionalCasts = 6 - skillCount
        for i = 1, additionalCasts do
            local spammable = frontSkills.spammables[((i - 1) % #frontSkills.spammables) + 1]
            addSkill(spammable)
            skillCount = skillCount + 1
        end
    end

    -- Save the generated rotation
    currentRotation = rotation
    self:SaveRotation()

    -- Display summary
    d("|c00FF00Smart rotation generated!|r")
    d(string.format("Total skills: %d", #rotation))
    d("|cFFFFFFLA weaving and bar swaps will be auto-inserted during combat|r")
    d(" ")
    d("|cFFD700Skill sequence:|r")
    for i, skill in ipairs(rotation) do
        local barColor = skill.bar == "front" and "|c00FF00" or "|c4D9BFF"
        d(string.format("  %d. %s%s|r [%s%s Bar|r]", i, "|cFF6347", skill.name, barColor, skill.bar))
    end

    return true
end

-- Check if potion is ready
function RotationHelper:IsPotionReady()
    local currentTime = GetGameTimeMilliseconds()
    potionCooldownRemaining = math.max(0, POTION_COOLDOWN - (currentTime - lastPotionTime))
    return potionCooldownRemaining == 0
end

-- Update potion cooldown tracker
function RotationHelper:UpdatePotionCooldown()
    if not inCombat then
        return
    end

    local currentTime = GetGameTimeMilliseconds()
    potionCooldownRemaining = math.max(0, POTION_COOLDOWN - (currentTime - lastPotionTime))
end

-- Track when potion is used
function RotationHelper:OnPotionUsed()
    lastPotionTime = GetGameTimeMilliseconds()
    potionCooldownRemaining = POTION_COOLDOWN
end

-- Get potion cooldown remaining (for display)
function RotationHelper:GetPotionCooldownRemaining()
    return potionCooldownRemaining / 1000  -- Return in seconds
end

-- Enhanced combat event to track potions
local originalOnCombatEvent = RotationHelper.OnCombatEvent
function RotationHelper:OnCombatEvent(result, abilityName, abilityId)
    -- Check if it's a potion
    if abilityName and (string.find(abilityName, "Potion") or string.find(abilityName, "Drink")) then
        self:OnPotionUsed()
    end

    -- Call original function
    originalOnCombatEvent(self, result, abilityName, abilityId)
end

-- Show bar scan results
function RotationHelper:ShowBarScan()
    local frontBar, backBar = self:ScanSkillBars()

    d("|cFFD700=== Skill Bar Scan ===|r")
    d(string.format("Debug: Found %d front bar skills, %d back bar skills", #frontBar, #backBar))
    d(" ")
    d("|cFFD700Front Bar:|r")
    if #frontBar > 0 then
        for i, skill in ipairs(frontBar) do
            local skillInfo = RotationHelper.SkillDB and RotationHelper.SkillDB:GetSkillInfo(skill.name)
            local typeStr = ""
            if skillInfo then
                if skillInfo.isDOT then
                    typeStr = "|cFF6347[DOT]|r "
                elseif skillInfo.isBuff then
                    typeStr = "|c00FF00[BUFF]|r "
                elseif skillInfo.isChannel then
                    typeStr = "|cFFFF00[CHANNEL]|r "
                else
                    typeStr = "|cFFFFFF[SPAMMABLE]|r "
                end
            end
            d(string.format("  Slot %d: %s%s", skill.slot, typeStr, skill.name))
        end
    else
        d("  No skills found")
    end

    d(" ")
    d("|cFFD700Back Bar:|r")
    if #backBar > 0 then
        for i, skill in ipairs(backBar) do
            local skillInfo = RotationHelper.SkillDB and RotationHelper.SkillDB:GetSkillInfo(skill.name)
            local typeStr = ""
            if skillInfo then
                if skillInfo.isDOT then
                    typeStr = "|cFF6347[DOT]|r "
                elseif skillInfo.isBuff then
                    typeStr = "|c00FF00[BUFF]|r "
                elseif skillInfo.isChannel then
                    typeStr = "|cFFFF00[CHANNEL]|r "
                else
                    typeStr = "|cFFFFFF[SPAMMABLE]|r "
                end
            end
            d(string.format("  Slot %d: %s%s", skill.slot, typeStr, skill.name))
        end
    else
        d("  No skills found")
    end

    d(" ")
    d("|cFFD700Tip:|r Use 'Generate Smart Rotation' in settings to create an optimized rotation!")
end
