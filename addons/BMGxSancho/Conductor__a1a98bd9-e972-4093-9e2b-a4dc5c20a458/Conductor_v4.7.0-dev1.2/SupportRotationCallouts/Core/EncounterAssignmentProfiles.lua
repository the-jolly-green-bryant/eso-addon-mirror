local C = Conductor
C.EncounterAssignmentProfiles = C.EncounterAssignmentProfiles or {}
local Profiles = C.EncounterAssignmentProfiles

local ASSIGNMENT_KEYS = {
    "trashRotationEnabled", "trashAdvanceOnCombatEnd", "trashCurrentTeam",
    "trashUltimateTeam1Enabled", "trashUltimateTeam1Count", "trashUltimateTeam1",
    "trashUltimateTeam2Enabled", "trashUltimateTeam2Count", "trashUltimateTeam2",
    "trashUltimateTeam3Enabled", "trashUltimateTeam3Count", "trashUltimateTeam3",
    "trashUltimateTeam4Enabled", "trashUltimateTeam4Count", "trashUltimateTeam4",
    "colossusEnabled", "rotationCount", "rotation",
    "warhornEnabled", "warhornCount", "warhornRotation",
    "barrierEnabled", "barrierCount", "barrierRotation",
}

local function Copy(value)
    if type(value) ~= "table" then return value end
    local output = {}
    for key, entry in pairs(value) do output[Copy(key)] = Copy(entry) end
    return output
end

local function NormalizeKey(value)
    local key = tostring(value or ""):upper():gsub("[^A-Z0-9]+", "_"):gsub("^_+", ""):gsub("_+$", "")
    return key ~= "" and key or "DEFAULT"
end

function Profiles:GetDraftKey()
    local trial = NormalizeKey(C.saved.profileDraftInstance or "TRIAL")
    local encounter = NormalizeKey(C.saved.encounterAssignmentName or "DEFAULT")
    return trial .. "::" .. encounter
end

function Profiles:SaveCurrent()
    C.saved.encounterAssignmentProfiles = C.saved.encounterAssignmentProfiles or {}
    local key = self:GetDraftKey()
    local snapshot = { name=C.saved.encounterAssignmentName or "Default", trial=C.saved.profileDraftInstance or "", updatedAt=GetTimeStamp and GetTimeStamp() or 0 }
    for _, savedKey in ipairs(ASSIGNMENT_KEYS) do snapshot[savedKey] = Copy(C.saved[savedKey]) end
    C.saved.encounterAssignmentProfiles[key] = snapshot
    C.saved.activeEncounterAssignmentKey = key
    if C.Notify then C:Notify("Encounter assignments saved.") end
    return true
end

function Profiles:Load(key, silent)
    C.saved.encounterAssignmentProfiles = C.saved.encounterAssignmentProfiles or {}
    key = key or C.saved.activeEncounterAssignmentKey or self:GetDraftKey()
    local snapshot = C.saved.encounterAssignmentProfiles[key]
    if not snapshot then
        if not silent and C.Notify then C:Notify("No saved assignments were found for this encounter.") end
        return false
    end
    for _, savedKey in ipairs(ASSIGNMENT_KEYS) do
        if snapshot[savedKey] ~= nil then C.saved[savedKey] = Copy(snapshot[savedKey]) end
    end
    C.saved.activeEncounterAssignmentKey = key
    if C.TrashRotation and C.TrashRotation.SetCurrentTeam then C.TrashRotation:SetCurrentTeam(C.saved.trashCurrentTeam or 1) end
    if C.OnAssignmentSettingsChanged then
        C:OnAssignmentSettingsChanged("ColossusRotation")
        C:OnAssignmentSettingsChanged("WarhornRotation")
        C:OnAssignmentSettingsChanged("BarrierRotation")
    end
    if not silent and C.Notify then C:Notify("Encounter assignments loaded.") end
    return true
end

function Profiles:GetItems()
    local items = {}
    for key, profile in pairs(C.saved.encounterAssignmentProfiles or {}) do
        items[#items+1] = { name=profile.name or key, data=key }
    end
    table.sort(items, function(a,b) return tostring(a.name) < tostring(b.name) end)
    if #items == 0 then items[1] = { name="No saved encounter assignments", data="" } end
    return items
end

function Profiles:DeleteSelected()
    local key = C.saved.activeEncounterAssignmentKey
    if not key or key == "" or not C.saved.encounterAssignmentProfiles then return false end
    C.saved.encounterAssignmentProfiles[key] = nil
    C.saved.activeEncounterAssignmentKey = ""
    if C.Notify then C:Notify("Encounter assignments deleted.") end
    return true
end

function Profiles:Initialize()
    C.saved.encounterAssignmentProfiles = C.saved.encounterAssignmentProfiles or {}
    if C.EventBus then
        C.EventBus:Subscribe("ENCOUNTER_MODE_CHANGED", self, function(payload)
            local profile = payload and payload.profile
            local name = profile and (profile.bossName or profile.name or profile.id)
            if not name then return end
            local trial = NormalizeKey(C.saved.profileDraftInstance or "TRIAL")
            local key = trial .. "::" .. NormalizeKey(name)
            if C.saved.encounterAssignmentProfiles[key] then Profiles:Load(key, true) end
        end)
    end
    self.initialized = true
end
