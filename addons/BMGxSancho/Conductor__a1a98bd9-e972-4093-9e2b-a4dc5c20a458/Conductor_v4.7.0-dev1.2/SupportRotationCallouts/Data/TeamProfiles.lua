local C = Conductor
local SRC = SupportRotationCallouts
C.TeamProfilesV2 = C.TeamProfilesV2 or {}
local TeamProfiles = C.TeamProfilesV2

TeamProfiles.SCHEMA_VERSION = 1
TeamProfiles.MAX_PROFILES = 12

local function Copy(value)
    if type(value) ~= "table" then return value end
    local output = {}
    for key, item in pairs(value) do output[key] = Copy(item) end
    return output
end

local function Trim(value)
    if zo_strtrim then return zo_strtrim(tostring(value or "")) end
    return tostring(value or ""):match("^%s*(.-)%s*$")
end

local function NowSeconds()
    return GetTimeStamp and GetTimeStamp() or 0
end

local function GenerateId()
    TeamProfiles.idCounter = (TeamProfiles.idCounter or 0) + 1
    local stamp = NowSeconds()
    local random = math.random and math.random(1000, 9999) or TeamProfiles.idCounter
    return string.format("PT-%d-%d-%d", stamp, TeamProfiles.idCounter, random)
end

function TeamProfiles:Initialize()
    SRC.saved.progTeams = SRC.saved.progTeams or {}
    SRC.saved.selectedProgTeamId = SRC.saved.selectedProgTeamId or ""
    SRC.saved.progTeamDraftName = SRC.saved.progTeamDraftName or ""
    SRC.saved.progTeamComparison = SRC.saved.progTeamComparison or nil

    for _, profile in ipairs(SRC.saved.progTeams) do
        profile.schemaVersion = tonumber(profile.schemaVersion) or self.SCHEMA_VERSION
        profile.players = profile.players or {}
        profile.context = profile.context or {}
        profile.createdAt = tonumber(profile.createdAt) or 0
        profile.updatedAt = tonumber(profile.updatedAt) or profile.createdAt
    end

    if SRC.saved.selectedProgTeamId ~= "" and not self:GetById(SRC.saved.selectedProgTeamId) then
        SRC.saved.selectedProgTeamId = ""
    end
    self.initialized = true
end

function TeamProfiles:GetAll()
    return SRC.saved.progTeams or {}
end

function TeamProfiles:GetById(profileId)
    if not profileId or profileId == "" then return nil end
    for _, profile in ipairs(self:GetAll()) do
        if profile.id == profileId then return profile end
    end
    return nil
end

function TeamProfiles:GetSelected()
    return self:GetById(SRC.saved.selectedProgTeamId)
end

function TeamProfiles:SetSelected(profileId)
    if profileId == nil or profileId == "" then
        SRC.saved.selectedProgTeamId = ""
        return false
    end
    if not self:GetById(profileId) then return false end
    SRC.saved.selectedProgTeamId = profileId
    self:ApplyToPlayerSetup(self:GetById(profileId))
    return true
end


function TeamProfiles:ApplyToPlayerSetup(profile)
    profile = profile or self:GetSelected()
    if not profile then return false, "No saved Prog Team selected." end
    if type(profile.players) ~= "table" then return false, "The selected Prog Team has no saved roster." end

    SRC.saved.raidRosterSlots = Copy(profile.players)
    for index = 1, 12 do
        SRC.saved.raidRosterSlots[index] = SRC.saved.raidRosterSlots[index] or {
            role = (index <= 2 and "Tank") or (index <= 4 and "Healer") or "Damage Dealer",
            player = "", class = "", set1 = "NONE", set2 = "NONE",
            monster = "NONE", mythic = "NONE", arena = "NONE",
            manualPlayer = "", manualSet1 = "", manualSet2 = "",
            manualMonster = "", manualMythic = "", manualArena = "",
            manualNotes = "", source = "SAVED PROFILE",
        }
        SRC.saved.raidRosterSlots[index].source = "SAVED PROFILE"
    end

    local context = profile.context or {}
    if context.trial and context.trial ~= "" then SRC.saved.profileDraftInstance = context.trial end
    if context.difficulty and context.difficulty ~= "" then SRC.saved.profileDraftDifficulty = context.difficulty end
    if context.objective and context.objective ~= "" then SRC.saved.profileDraftObjective = context.objective end
    if context.strategy ~= nil then SRC.saved.profileDraftStrategy = context.strategy end
    SRC.saved.progTeamDraftName = profile.name or SRC.saved.progTeamDraftName

    if C.EventBus then
        C.EventBus:Publish("PROG_TEAM_ACTIVATED", { profile = profile, players = Copy(SRC.saved.raidRosterSlots) })
    end
    if SRC.Diagnostics then
        SRC.Diagnostics:AddFields("RAID_SETUP", "Saved team loaded into Team Review", {
            profile = tostring(profile.name or "Unnamed Prog Team"),
            players = #(profile.players or {}),
        })
    end
    return true
end

function TeamProfiles:GetItems()
    local items = { { name = "New Team", data = "" } }
    for _, profile in ipairs(self:GetAll()) do
        local trial = tostring((profile.context or {}).trial or "")
        local suffix = trial ~= "" and (" - " .. trial) or ""
        items[#items + 1] = { name = tostring(profile.name or "Unnamed Prog Team") .. suffix, data = profile.id }
    end
    table.sort(items, function(a, b) return tostring(a.name) < tostring(b.name) end)
    return items
end

function TeamProfiles:SaveFromRoster(name, slots, context)
    local cleanName = Trim(name)
    if cleanName == "" then
        local trial = Trim((context or {}).trial)
        cleanName = trial ~= "" and (trial .. " Team") or "Saved Raid Team"
    end
    if type(slots) ~= "table" then return nil, "Team Review is unavailable." end

    local selected = self:GetSelected()
    local profile = selected
    if not profile then
        if #self:GetAll() >= self.MAX_PROFILES then return nil, "Maximum Prog Team count reached." end
        profile = {
            id = GenerateId(),
            schemaVersion = self.SCHEMA_VERSION,
            createdAt = NowSeconds(),
        }
        table.insert(SRC.saved.progTeams, profile)
    end

    profile.name = cleanName
    profile.updatedAt = NowSeconds()
    profile.players = Copy(slots)
    profile.context = Copy(context or {})
    SRC.saved.selectedProgTeamId = profile.id
    SRC.saved.progTeamDraftName = cleanName

    if C.EventBus then C.EventBus:Publish("PROG_TEAM_SAVED", { profile = profile }) end
    return profile
end

function TeamProfiles:DeleteSelected()
    local selectedId = SRC.saved.selectedProgTeamId
    if selectedId == "" then return false end
    for index, profile in ipairs(self:GetAll()) do
        if profile.id == selectedId then
            table.remove(SRC.saved.progTeams, index)
            SRC.saved.selectedProgTeamId = ""
            SRC.saved.progTeamComparison = nil
            if C.EventBus then C.EventBus:Publish("PROG_TEAM_DELETED", { profile = profile }) end
            return true
        end
    end
    return false
end

function TeamProfiles:CopyRoster(profile)
    profile = profile or self:GetSelected()
    return profile and Copy(profile.players or {}) or nil
end

function TeamProfiles:ImportSharedSession(snapshot, slots)
    if type(snapshot) ~= "table" or type(slots) ~= "table" then return nil end
    SRC.saved.progTeams = SRC.saved.progTeams or {}
    local profile
    for _, existing in ipairs(SRC.saved.progTeams) do
        if tostring(existing.sharedSourceSessionId or "") == tostring(snapshot.sessionId or "") then
            profile = existing
            break
        end
    end
    if not profile then
        if #SRC.saved.progTeams >= self.MAX_PROFILES then return nil end
        profile = { id=GenerateId(), schemaVersion=self.SCHEMA_VERSION, createdAt=NowSeconds() }
        table.insert(SRC.saved.progTeams, profile)
    end
    profile.name = tostring(snapshot.teamName or "Shared Raid Team")
    profile.updatedAt = NowSeconds()
    profile.players = Copy(slots)
    profile.context = {
        trial=snapshot.trial, difficulty=snapshot.difficulty, objective=snapshot.objective,
        strategy=snapshot.strategy, assignments=Copy(snapshot.assignments or {}),
        responsibilities=Copy(snapshot.responsibilities or {}),
    }
    profile.sharedSourceSessionId = tostring(snapshot.sessionId or "")
    profile.sharedFrom = tostring(snapshot.hostAccount or "")
    profile.readOnlySource = "SHARED"
    SRC.saved.selectedProgTeamId = profile.id
    SRC.saved.progTeamDraftName = profile.name
    if C.EventBus then C.EventBus:Publish("PROG_TEAM_IMPORTED", { profile=profile, snapshot=snapshot }) end
    return profile
end
