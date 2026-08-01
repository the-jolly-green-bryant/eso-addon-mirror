local SRC = SupportRotationCallouts
SRC.EncounterKnowledgeRegistry = SRC.EncounterKnowledgeRegistry or {}
local Knowledge = SRC.EncounterKnowledgeRegistry

local DEFAULT_SUPPORT = {
    priority = "MAINTAIN_ROTATION",
    holdBurn = false,
    defensiveUltimate = false,
    resumeRule = "WHEN_MECHANIC_CLEARS",
}

local MECHANICS = {
    EXECUTE = { label="Execute", category="BURN", trigger="BOSS_HEALTH", support={priority="FULL_BURN", holdBurn=false}, dps="COMMIT_DAMAGE_ULTIMATES", position="STACK_OR_PROFILE", recovery="NONE", confidence="verified_class" },
    PORTAL = { label="Portal", category="SPLIT", trigger="ABILITY_OR_NPC", support={priority="PRESERVE_PORTAL_SUPPORT", holdBurn=true}, dps="HOLD_UNLESS_PROFILE_BURNS", position="GROUP_SPLIT", recovery="WAIT_FOR_PORTAL_RETURN", confidence="community_pending_ids" },
    PORTALS = { label="Portals", category="SPLIT", trigger="ABILITY_OR_NPC", support={priority="PRESERVE_PORTAL_SUPPORT", holdBurn=true}, dps="HOLD_UNLESS_PROFILE_BURNS", position="GROUP_SPLIT", recovery="WAIT_FOR_PORTAL_RETURN", confidence="community_pending_ids" },
    TRANSITION = { label="Transition", category="TRANSITION", trigger="BOSS_AVAILABILITY", support={priority="HOLD_ROTATION", holdBurn=true}, dps="HOLD_ULTIMATES", position="MOVE_TO_NEXT_PHASE", recovery="RESUME_ON_BOSS_RETURN", confidence="verified_class" },
    FLOOR_TRANSITION = { label="Floor Transition", category="TRANSITION", trigger="BOSS_AVAILABILITY", support={priority="HOLD_ROTATION", holdBurn=true}, dps="HOLD_ULTIMATES", position="MOVE_TO_NEXT_FLOOR", recovery="RESUME_ON_BOSS_RETURN", confidence="community_pending_ids" },
    IMMUNITY = { label="Boss Immunity", category="TRANSITION", trigger="COMBAT_EVENT", support={priority="HOLD_ROTATION", holdBurn=true}, dps="STOP_BURN", position="PROFILE", recovery="RESUME_WHEN_DAMAGEABLE", confidence="verified_class" },
    ADDS = { label="Add Wave", category="ADD_WAVE", trigger="NPC_SPAWN", support={priority="DYNAMIC_TRASH_PACKAGE", holdBurn=false}, dps="CLEAVE_PRIORITY", position="STACK_ADDS", recovery="RETURN_TO_BOSS", confidence="verified_class" },
    SPLIT = { label="Group Split", category="SPLIT", trigger="ABILITY_OR_NPC", support={priority="SPLIT_SUPPORT_PACKAGE", holdBurn=true}, dps="FOLLOW_ASSIGNED_SIDE", position="GROUP_SPLIT", recovery="REGROUP", confidence="community_pending_ids" },
    GROUP_SPLIT = { label="Group Split", category="SPLIT", trigger="ABILITY_OR_NPC", support={priority="SPLIT_SUPPORT_PACKAGE", holdBurn=true}, dps="FOLLOW_ASSIGNED_SIDE", position="GROUP_SPLIT", recovery="REGROUP", confidence="community_pending_ids" },
    TANK_SWAP = { label="Tank Swap", category="TANK", trigger="DEBUFF_OR_CAST", support={priority="STABILIZE_TANKS", holdBurn=false}, dps="CONTINUE", position="MAINTAIN_STACK", recovery="CONFIRM_NEW_TANK", confidence="verified_class" },
    INTERRUPT = { label="Interrupt", category="CONTROL", trigger="ABILITY_CAST", support={priority="INTERRUPT_NOW", holdBurn=false}, dps="ASSIGNED_INTERRUPT", position="RANGE_CHECK", recovery="CONTINUE", confidence="verified_class" },
    KITE = { label="Kite", category="POSITION", trigger="TARGETED_EFFECT", support={priority="MAINTAIN_REMOTE_SUPPORT", holdBurn=false}, dps="KITER_LEAVES_STACK", position="KITE", recovery="RETURN_TO_STACK", confidence="verified_class" },
    SPREAD = { label="Spread", category="POSITION", trigger="TARGETED_EFFECT", support={priority="MAINTAIN_COVERAGE", holdBurn=false}, dps="SPREAD", position="SPREAD", recovery="RESTACK", confidence="verified_class" },
    STACK = { label="Stack", category="POSITION", trigger="ABILITY_OR_STATE", support={priority="MAXIMIZE_GROUP_COVERAGE", holdBurn=false}, dps="STACK", position="STACK", recovery="NONE", confidence="verified_class" },
    SHIELD = { label="Shield Phase", category="BURN_CHECK", trigger="EFFECT_OR_HEALTH", support={priority="BURST_PACKAGE", holdBurn=false}, dps="FOCUS_SHIELD", position="STACK_OR_PROFILE", recovery="RESUME_BOSS", confidence="community_pending_ids" },
    CLONE_PHASE = { label="Clone Phase", category="ADD_WAVE", trigger="NPC_SPAWN", support={priority="ADD_BURN_PACKAGE", holdBurn=true}, dps="FOCUS_ASSIGNED_CLONE", position="GROUP_SPLIT", recovery="REGROUP", confidence="community_pending_ids" },
    HEARTS = { label="Heart Phase", category="OBJECTIVE", trigger="NPC_SPAWN", support={priority="OBJECTIVE_BURN_PACKAGE", holdBurn=true}, dps="FOCUS_HEART", position="PROFILE", recovery="RETURN_TO_GUARDIAN", confidence="live_validation" },
    BRIDGES = { label="Bridge Transition", category="TRANSITION", trigger="BOSS_AVAILABILITY", support={priority="HOLD_ROTATION", holdBurn=true}, dps="HOLD_ULTIMATES", position="MOVE_BRIDGE", recovery="RESUME_AT_NEXT_ARENA", confidence="live_validation" },
    CURSE = { label="Curse Cycle", category="TARGETED_MECHANIC", trigger="ABILITY_CAST", support={priority="MAINTAIN_COVERAGE", holdBurn=false}, dps="EXECUTE_ASSIGNMENT", position="PROFILE", recovery="RESTACK", confidence="live_validation" },
    DOME = { label="Dome", category="TRANSITION", trigger="ABILITY_OR_EFFECT", support={priority="HOLD_ROTATION", holdBurn=true}, dps="HOLD_ULTIMATES", position="ENTER_ASSIGNED_DOME", recovery="RESUME_AFTER_DOME", confidence="live_validation" },
    SWAP = { label="Boss Swap", category="TRANSITION", trigger="BOSS_AVAILABILITY", support={priority="HOLD_OR_REDIRECT", holdBurn=true}, dps="SWAP_TARGET", position="CHANGE_SIDE", recovery="RESUME_ON_ACTIVE_BOSS", confidence="live_validation" },
    MAELSTROM = { label="Maelstrom", category="HIGH_DAMAGE", trigger="ABILITY_CAST", support={priority="DEFENSIVE_PACKAGE", holdBurn=true, defensiveUltimate=true}, dps="SURVIVE_AND_HOLD", position="PROFILE", recovery="RESUME_AFTER_DAMAGE", confidence="live_validation" },
    WINTER_STORM = { label="Winter Storm", category="HIGH_DAMAGE", trigger="ABILITY_CAST", support={priority="DEFENSIVE_PACKAGE", holdBurn=true, defensiveUltimate=true}, dps="SURVIVE_AND_HOLD", position="PROFILE", recovery="RESUME_AFTER_STORM", confidence="live_validation" },
}

local function Copy(source)
    local result = {}
    for key, value in pairs(source or {}) do
        if type(value) == "table" then
            local nested = {}
            for nestedKey, nestedValue in pairs(value) do nested[nestedKey] = nestedValue end
            result[key] = nested
        else
            result[key] = value
        end
    end
    return result
end

local function Humanize(key)
    local text = tostring(key or "MECHANIC")
    text = string.gsub(text, "_", " ")
    text = string.lower(text)
    return (string.gsub(text, "(%a)([%w']*)", function(first, rest)
        return string.upper(first) .. rest
    end))
end

function Knowledge:GetMechanic(key)
    local canonical = string.upper(tostring(key or ""))
    local record = MECHANICS[canonical]
    if record then
        local result = Copy(record)
        result.key = canonical
        result.support = Copy(record.support or DEFAULT_SUPPORT)
        return result
    end
    return {
        key = canonical,
        label = Humanize(canonical),
        category = "ENCOUNTER",
        trigger = "OBSERVATION_PENDING",
        support = Copy(DEFAULT_SUPPORT),
        dps = "FOLLOW_ENCOUNTER_PLAN",
        position = "PROFILE",
        recovery = "RESUME_WHEN_CLEAR",
        confidence = "provisional",
        abilityIds = {},
    }
end

function Knowledge:BuildMechanics(keys)
    local result = {}
    for _, key in ipairs(keys or {}) do result[#result + 1] = self:GetMechanic(key) end
    return result
end

function Knowledge:DecorateEncounter(trial, source, result)
    result.mechanicDefinitions = self:BuildMechanics(source.mechanics or result.mechanics)
    result.positionIntelligence = {}
    result.recoveryPackages = {}
    result.supportResponses = {}
    for _, mechanic in ipairs(result.mechanicDefinitions) do
        result.positionIntelligence[#result.positionIntelligence + 1] = { mechanic=mechanic.key, instruction=mechanic.position }
        result.recoveryPackages[#result.recoveryPackages + 1] = { mechanic=mechanic.key, resume=mechanic.recovery }
        result.supportResponses[#result.supportResponses + 1] = { mechanic=mechanic.key, response=mechanic.support }
    end
    result.difficultyOverlay = {
        difficulty = result.difficulty or "veteran",
        normal = { precision="low", fallbackTimers=true },
        veteran = { precision="standard", fallbackTimers=true },
        hardmode = { precision="high", fallbackTimers=false, preserveRecovery=true },
    }
    result.validation = {
        status = result.researchStatus or trial.researchStatus,
        profileConfidence = source.researchConfidence or result.confidence or "provisional",
        sources = source.researchSources or {},
        abilityIdCoverage = "PARTIAL_PENDING_LIVE_CAPTURE",
    }
    if not next(result.strategyProfiles or {}) then
        result.strategyProfiles = {
            automatic = { label="Automatic", risk="balanced" },
            learning = { label="Learning", risk="safe", preserveRecovery=true },
            farm = { label="Farm", risk="balanced" },
            trifecta = { label="Trifecta", risk="precision", preserveRecovery=true },
            score_push = { label="Score Push", risk="aggressive" },
        }
    end
    return result
end

function Knowledge:GetTrialCoverage()
    local trials = SRC.EncounterProfiles and SRC.EncounterProfiles:GetTrials() or {}
    local summary = { trials=0, encounters=0, mechanics=0, provisionalMechanics=0 }
    local seen = {}
    for _, trial in pairs(trials) do
        summary.trials = summary.trials + 1
        local encounterSeen = {}
        for _, encounter in pairs(trial.encounters or {}) do
            if not encounterSeen[encounter.id] then
                encounterSeen[encounter.id] = true
                summary.encounters = summary.encounters + 1
                for _, key in ipairs(encounter.mechanics or {}) do
                    if not seen[key] then
                        seen[key] = true
                        summary.mechanics = summary.mechanics + 1
                        if not MECHANICS[key] then summary.provisionalMechanics = summary.provisionalMechanics + 1 end
                    end
                end
            end
        end
    end
    return summary
end

function Knowledge:Initialize()
    if self.initialized then return end
    self.initialized = true
    if SRC.Registry and SRC.Registry.Register then
        for key, definition in pairs(MECHANICS) do
            SRC.Registry:Register("ENCOUNTER_MECHANICS", key, definition)
        end
    end
    local coverage = self:GetTrialCoverage()
    if SRC.Diagnostics and SRC.Diagnostics.AddFields then
        SRC.Diagnostics:AddFields("ENCOUNTER_KNOWLEDGE", "Encounter knowledge registry initialized", coverage)
    end
end
