local C = Conductor
local SRC = SupportRotationCallouts
C.ExecutionPlanCompiler = C.ExecutionPlanCompiler or {}
SRC.ExecutionPlanCompiler = C.ExecutionPlanCompiler
local Compiler = C.ExecutionPlanCompiler

local function Copy(value)
    if type(value) ~= "table" then return value end
    local output = {}
    for key, item in pairs(value) do output[key] = Copy(item) end
    return output
end

local function Key(value)
    return string.upper(tostring(value or "")):gsub("[^A-Z0-9]+", "_")
end

local function Normalize(value)
    if C.NormalizeAccountName then return C:NormalizeAccountName(value or "") end
    return string.lower(tostring(value or ""))
end

local RESPONSIBILITY_ALIASES = {
    HORN="WARHORN", AGGRESSIVE_HORN="WARHORN", MAJOR_FORCE="WARHORN", RESP_MAJOR_FORCE="WARHORN",
    MAJOR_VULNERABILITY="COLOSSUS", RESP_MAJOR_VULNERABILITY="COLOSSUS",
    SLAYER="MAJOR_SLAYER", RESP_MAJOR_SLAYER="MAJOR_SLAYER",
    PILLAGERS_PROFIT="PILLAGER", ULTIMATE_RESTORE="PILLAGER", RESP_ULTIMATE_RESTORE="PILLAGER",
    DEBUFF_EXTENSION="NAZARAY", RESP_DEBUFF_EXTENSION="NAZARAY",
    DEFENSIVE_ULTIMATE="BARRIER", RESP_DEFENSIVE_ULTIMATE="BARRIER",
    POWERFUL_ASSAULT="POWERFUL_ASSAULT", MAJOR_BRITTLE="MAJOR_BRITTLE", MINOR_BRITTLE="MINOR_BRITTLE",
}

local ACTION_META = {
    POWERFUL_ASSAULT={ label="Powerful Assault", phase=10, lane="SUPPORT", confirmationKey="POWERFUL_ASSAULT" },
    MAJOR_BRITTLE={ label="Major Brittle", phase=12, lane="SUPPORT", confirmationKey="MAJOR_BRITTLE" },
    MINOR_BRITTLE={ label="Minor Brittle", phase=14, lane="SUPPORT", confirmationKey="MINOR_BRITTLE" },
    MAJOR_SLAYER={ label="Slayer", phase=20, lane="SUPPORT", confirmationKey="MAJOR_SLAYER" },
    WARHORN={ label="Horn", phase=30, lane="SUPPORT", confirmationKey="WARHORN" },
    COLOSSUS={ label="Vulnerability", phase=40, lane="SUPPORT", confirmationKey="COLOSSUS" },
    DAMAGE_ULTIMATES={ label="DPS ULTIMATES", phase=50, lane="RAID" },
    NAZARAY={ label="Nazaray", phase=60, lane="SUPPORT", confirmationKey="NAZARAY" },
    PILLAGER={ label="Pillager", phase=70, lane="SUPPORT", confirmationKey="PILLAGER" },
    BARRIER={ label="Barrier", phase=80, lane="SUPPORT", confirmationKey="BARRIER" },
}

local function AssignmentBelongs(entry)
    if type(entry) ~= "table" then return nil end
    return entry.accountName or entry.player or entry.assignedAccount or entry.providerAccount or entry.owner
end

function Compiler:CanonicalResponsibility(value)
    local key = Key(value)
    key = key:gsub("^RESP_", "")
    return RESPONSIBILITY_ALIASES[key] or key
end

function Compiler:CollectAssignments(source, output, path)
    if type(source) ~= "table" then return end
    local account = AssignmentBelongs(source)
    local responsibility = source.responsibilityKey or source.effectKey or source.key or source.timelineKey
    if account and responsibility then
        local canonical = self:CanonicalResponsibility(responsibility)
        output[canonical] = output[canonical] or {}
        local item = Copy(source)
        item.accountName = Normalize(account)
        item.assignmentPath = path
        output[canonical][#output[canonical] + 1] = item
        return
    end
    for key, value in pairs(source) do
        if type(value) == "table" then
            self:CollectAssignments(value, output, path == "" and tostring(key) or (path .. "." .. tostring(key)))
        elseif type(value) == "string" and value:sub(1,1) == "@" then
            local canonical = self:CanonicalResponsibility(key)
            output[canonical] = output[canonical] or {}
            output[canonical][#output[canonical] + 1] = { accountName=Normalize(value), responsibilityKey=canonical, assignmentPath=path }
        end
    end
end

function Compiler:GetSessionAssignments()
    local session = C.RaidSession and C.RaidSession:GetActive() or nil
    local output = {}
    if session then
        self:CollectAssignments(session.responsibilities or {}, output, "responsibilities")
        self:CollectAssignments(session.assignments or {}, output, "assignments")
    end
    return output, session
end

function Compiler:ResolveOwner(responsibilityKey)
    local assignments = self:GetSessionAssignments()
    local list = assignments[self:CanonicalResponsibility(responsibilityKey)] or {}
    return list[1] and Normalize(list[1].accountName) or ""
end

function Compiler:IsResponsibilityAvailable(key, session, assignments)
    key = self:CanonicalResponsibility(key)
    if assignments[key] and #assignments[key] > 0 then return true end
    for _, player in ipairs(session and session.players or {}) do
        local capabilities = player.capabilities or {}
        local responsibilities = capabilities.responsibilities or player.responsibilities or {}
        for candidate, value in pairs(responsibilities) do
            local candidateKey = type(value) == "table" and (value.key or value.responsibilityKey) or candidate
            if self:CanonicalResponsibility(candidateKey) == key then return true end
        end
        for _, value in ipairs(capabilities.normalized or {}) do
            for _, responsibilityKey in ipairs(value.responsibilityKeys or {}) do
                if self:CanonicalResponsibility(responsibilityKey) == key then return true end
            end
        end
    end
    return false
end

function Compiler:GetAvailableBurnActions()
    local assignments, session = self:GetSessionAssignments()
    local actions = {}
    for key, metadata in pairs(ACTION_META) do
        if key == "DAMAGE_ULTIMATES" or self:IsResponsibilityAvailable(key, session, assignments) then
            local owner = assignments[key] and assignments[key][1] and assignments[key][1].accountName or ""
            actions[#actions + 1] = {
                key=key, label=metadata.label, phase=metadata.phase, lane=metadata.lane,
                assignedAccount=owner, responsibilityKey=key, confirmationKey=metadata.confirmationKey,
                audiences=key == "DAMAGE_ULTIMATES" and {"trial_lead","dd","raid_aware"} or {"trial_lead","assigned"},
            }
        end
    end
    table.sort(actions, function(a,b) return a.phase < b.phase end)
    return actions
end

function Compiler:CompileWindow(profile, window, sequenceIndex)
    local steps = {}
    local prefix = tostring(window.id or (profile.id .. "_WINDOW_" .. sequenceIndex))
    local instructionKey = window.type
    local instructionLabel = window.label
    local instruction = {
        id=prefix .. "_INSTRUCTION", key=instructionKey, label=instructionLabel,
        trigger=Copy(window.trigger), lane="MECHANIC", audiences={"all","raid_aware"},
        priority=window.priority, leadTimeSeconds=window.prewarnSeconds,
        windowId=window.id, windowType=window.type, confidence=window.confidence,
        persistentInstruction=true,
        autoComplete=true,
        fallbackSeconds=window.prewarnSeconds,
    }
    steps[#steps + 1] = instruction

    if window.type == "FULL_BURN" or window.type == "EXECUTE" then
        local previousId = instruction.id
        for actionIndex, action in ipairs(self:GetAvailableBurnActions()) do
            local step = Copy(action)
            step.id = prefix .. "_ACTION_" .. tostring(actionIndex)
            step.trigger = { type="AFTER_STEP", stepId=previousId }
            step.fallbackSeconds = action.key == "DAMAGE_ULTIMATES" and 1.0 or 2.5
            step.leadTimeSeconds = action.key == "DAMAGE_ULTIMATES" and 1 or 3
            step.windowId = window.id
            step.windowType = window.type
            step.priority = action.key == "DAMAGE_ULTIMATES" and "ENCOUNTER" or "ROTATION"
            steps[#steps + 1] = step
            previousId = step.id
        end
    elseif window.type == "RECOVERY" then
        for _, key in ipairs({"PILLAGER","BARRIER"}) do
            if self:ResolveOwner(key) ~= "" then
                local meta = ACTION_META[key]
                steps[#steps + 1] = {
                    id=prefix .. "_" .. key, key=key, label=meta.label,
                    trigger={type="AFTER_STEP",stepId=instruction.id}, lane="SUPPORT",
                    audiences={"trial_lead","assigned"}, assignedAccount=self:ResolveOwner(key),
                    responsibilityKey=key, fallbackSeconds=3, windowId=window.id,
                }
            end
        end
    end
    return steps
end

function Compiler:Compile(profile)
    if type(profile) ~= "table" or not C.BurnWindowGuide then return {} end
    local session = C.RaidSession and C.RaidSession:GetActive() or nil
    local strategy = session and session.strategy or "AUTOMATIC"
    local output = {}
    for index, window in ipairs(C.BurnWindowGuide:GetWindows(profile, strategy)) do
        for _, step in ipairs(self:CompileWindow(profile, window, index)) do output[#output + 1] = step end
    end
    return output
end

function Compiler:Initialize()
    self.initialized = true
end
