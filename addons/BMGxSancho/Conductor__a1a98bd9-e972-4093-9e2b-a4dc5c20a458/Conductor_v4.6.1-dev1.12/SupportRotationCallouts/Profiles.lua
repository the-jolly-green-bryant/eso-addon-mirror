local SRC = SupportRotationCallouts

SRC.Profiles = SRC.Profiles or {}
local Profiles = SRC.Profiles
local WM = WINDOW_MANAGER

Profiles.MAX_PROFILES = 24

local PROFILE_KEYS = {
    "colossusEnabled", "rotationCount", "rotation",
    "warhornEnabled", "warhornRotationCount", "warhornRotation",
    "barrierEnabled", "barrierRotationCount", "barrierRotation",
    "nazarayEnabled", "nazarayRotationCount", "nazarayRotation",
    "pillagerEnabled", "pillagerRotationCount", "pillagerRotation",
    "majorSlayerEnabled", "majorBrittleTrackingEnabled", "minorCourageTrackingEnabled",
    "majorResolveTrackingEnabled", "powerfulAssaultTrackingEnabled", "buffsDebuffsDashboardEnabled", "personalAssignmentsEnabled",
    "buffsDebuffsScale", "buffsDebuffsOffsetX", "buffsDebuffsOffsetY", "buffsDebuffsShowTitle", "warMachineEnabled", "warMachineRotationCount", "warMachineRotation",
    "masterArchitectEnabled", "masterArchitectRotationCount", "masterArchitectRotation",
    "roaringOpportunistEnabled", "roaringOpportunistRotationCount", "roaringOpportunistRotation",
    "roaringOpportunistAutomaticCoverage", "countdownStart", "dropThreshold",
    "confirmationEnabled", "leadCalloutEnabled", "calloutLayout", "calloutAlignment",
    "calloutOrder", "calloutColor", "calloutScale", "calloutOffsetX", "calloutOffsetY", "damageDealerScale", "damageDealerOffsetX", "damageDealerOffsetY", "supportQueueMode", "dashboardBackgroundOpacity", "dummyMode",
    "encounterIntelligenceEnabled", "encounterMinimumBurnWindow", "encounterDefaultCycleSeconds",
    "trashRotationEnabled", "trashAdvanceOnCombatEnd", "trashCurrentTeam",
    "trashUltimateTeam1Enabled", "trashUltimateTeam1Count", "trashUltimateTeam1",
    "trashUltimateTeam2Enabled", "trashUltimateTeam2Count", "trashUltimateTeam2",
    "trashUltimateTeam3Enabled", "trashUltimateTeam3Count", "trashUltimateTeam3",
    "trashUltimateTeam4Enabled", "trashUltimateTeam4Count", "trashUltimateTeam4",
}

local TRIAL_NAMES = {
    "Aetherian Archive", "Hel Ra Citadel", "Sanctum Ophidia", "Maw of Lorkhaj",
    "Halls of Fabrication", "Asylum Sanctorium", "Cloudrest", "Sunspire",
    "Kyne's Aegis", "Rockgrove", "Dreadsail Reef", "Sanity's Edge",
    "Lucent Citadel", "Ossein Cage",
}

local DUNGEON_NAMES = {
    "Arx Corinium", "Banished Cells I", "Banished Cells II", "Blackheart Haven",
    "Blessed Crucible", "City of Ash I", "City of Ash II", "Crypt of Hearts I",
    "Crypt of Hearts II", "Darkshade Caverns I", "Darkshade Caverns II", "Direfrost Keep",
    "Elden Hollow I", "Elden Hollow II", "Fungal Grotto I", "Fungal Grotto II",
    "Spindleclutch I", "Spindleclutch II", "Tempest Island", "Vaults of Madness",
    "Volenfell", "Wayrest Sewers I", "Wayrest Sewers II", "White-Gold Tower",
    "Imperial City Prison", "Cradle of Shadows", "Ruins of Mazzatun", "Bloodroot Forge",
    "Falkreath Hold", "Fang Lair", "Scalecaller Peak", "March of Sacrifices",
    "Moon Hunter Keep", "Depths of Malatar", "Frostvault", "Lair of Maarselok",
    "Moongrave Fane", "Icereach", "Unhallowed Grave", "Castle Thorn", "Stone Garden",
    "Black Drake Villa", "The Cauldron", "Red Petal Bastion", "The Dread Cellar",
    "Coral Aerie", "Shipwright's Regret", "Earthen Root Enclave", "Graven Deep",
    "Bal Sunnar", "Scrivener's Hall", "Oathsworn Pit", "Bedlam Veil",
    "Exiled Redoubt", "Lep Seclusa",
}

local DIFFICULTY_ITEMS = {
    { name = "Normal", data = "normal" },
    { name = "Veteran", data = "veteran" },
    { name = "Hardmode", data = "hardmode" },
}

local OBJECTIVE_ITEMS = {
    { name = "Learning", data = "learning" },
    { name = "Farm", data = "farm" },
    { name = "Prog", data = "prog" },
    { name = "Trifecta", data = "trifecta" },
    { name = "Score Push", data = "scorepush" },
}

local TRIAL_ACRONYMS = {
    ["Aetherian Archive"] = "AA", ["Hel Ra Citadel"] = "HRC", ["Sanctum Ophidia"] = "SO",
    ["Maw of Lorkhaj"] = "MOL", ["Halls of Fabrication"] = "HOF", ["Asylum Sanctorium"] = "AS",
    ["Cloudrest"] = "CR", ["Sunspire"] = "SS", ["Kyne's Aegis"] = "KA", ["Rockgrove"] = "RG",
    ["Dreadsail Reef"] = "DSR", ["Sanity's Edge"] = "SE", ["Lucent Citadel"] = "LC", ["Ossein Cage"] = "OC",
}

local DIFFICULTY_LABELS = { normal = "Normal", veteran = "Veteran", hardmode = "Hardmode" }
local OBJECTIVE_LABELS = { learning = "Learning", farm = "Farm", prog = "Prog", progression = "Prog", trifecta = "Trifecta", scorepush = "Score Push" }

local function DeepCopy(value)
    if type(value) ~= "table" then return value end
    local copy = {}
    for key, entry in pairs(value) do copy[DeepCopy(key)] = DeepCopy(entry) end
    return copy
end

local function TrimOrDefault(value, fallback)
    local text = zo_strtrim(tostring(value or ""))
    if text == "" then return fallback end
    return text
end

local function SafeZoneId()
    if not GetUnitZoneIndex or not GetZoneId then return 0 end
    local index = GetUnitZoneIndex("player")
    if not index or index <= 0 then return 0 end
    return tonumber(GetZoneId(index)) or 0
end

local function SafeZoneName()
    local name = GetUnitZone and GetUnitZone("player") or ""
    return zo_strtrim(zo_strformat("<<1>>", name or ""))
end

local function FindName(list, needle)
    local normalized = zo_strlower(zo_strtrim(tostring(needle or "")))
    for _, value in ipairs(list) do
        if zo_strlower(value) == normalized then return value end
    end
    return nil
end

function Profiles:Initialize()
    SRC.saved.profiles = SRC.saved.profiles or {}
    SRC.saved.activeProfileId = SRC.saved.activeProfileId or ""
    SRC.saved.profileDraftName = SRC.saved.profileDraftName or ""
    SRC.saved.profileDraftCategory = SRC.saved.profileDraftCategory or "trial"
    SRC.saved.profileDraftInstance = SRC.saved.profileDraftInstance or ""
    SRC.saved.profileDraftDifficulty = SRC.saved.profileDraftDifficulty or "veteran"
    SRC.saved.profileDraftObjective = SRC.saved.profileDraftObjective or "prog"
    if SRC.saved.profileDraftObjective == "progression" then SRC.saved.profileDraftObjective = "prog" end
    for _, savedProfile in ipairs(SRC.saved.profiles or {}) do
        if savedProfile.objective == "progression" then savedProfile.objective = "prog" end
    end
    SRC.saved.autoLoadProfiles = SRC.saved.autoLoadProfiles ~= false

    -- Migrate v0.7.0 draft/profile fields without losing saved setups.
    for _, profile in ipairs(SRC.saved.profiles) do
        profile.category = profile.category or "trial"
        profile.instanceName = profile.instanceName or profile.trial or ""
        profile.zoneId = tonumber(profile.zoneId) or 0
        profile.difficulty = profile.difficulty or "veteran"
        profile.objective = profile.objective or "progression"
        profile.trial, profile.sequence, profile.notes = nil, nil, nil
    end

    if SRC.saved.activeProfileId ~= "" and not self:GetById(SRC.saved.activeProfileId) then
        SRC.saved.activeProfileId = ""
    end

    self:BuildInstanceCatalog()
    EVENT_MANAGER:RegisterForEvent(SRC.name .. "ProfileAutoLoad", EVENT_PLAYER_ACTIVATED, function()
        zo_callLater(function() Profiles:OnPlayerActivated() end, 900)
    end)
end

function Profiles:BuildInstanceCatalog()
    self.zoneIdsByName = self.zoneIdsByName or {}
    if GetNumZones and GetZoneId and GetZoneNameById then
        local total = tonumber(GetNumZones()) or 0
        for index = 1, total do
            local zoneId = tonumber(GetZoneId(index)) or 0
            if zoneId > 0 then
                local zoneName = zo_strtrim(zo_strformat("<<1>>", GetZoneNameById(zoneId) or ""))
                if zoneName ~= "" then self.zoneIdsByName[zo_strlower(zoneName)] = zoneId end
            end
        end
    end
    local currentName, currentId = SafeZoneName(), SafeZoneId()
    if currentName ~= "" and currentId > 0 then self.zoneIdsByName[zo_strlower(currentName)] = currentId end
end

function Profiles:GetCategoryItems()
    return { { name = "Trial", data = "trial" }, { name = "Dungeon", data = "dungeon" } }
end

function Profiles:GetDifficultyItems() return DIFFICULTY_ITEMS end
function Profiles:GetObjectiveItems() return OBJECTIVE_ITEMS end
function Profiles:GetDifficultyLabel(value) return DIFFICULTY_LABELS[value] or "Veteran" end
function Profiles:GetObjectiveLabel(value) return OBJECTIVE_LABELS[value] or "Prog" end

function Profiles:GetInstanceCode(profile)
    if not profile then return "" end
    local base = TRIAL_ACRONYMS[profile.instanceName] or tostring(profile.instanceName or "Instance")
    if profile.difficulty == "veteran" then return "v" .. base end
    if profile.difficulty == "hardmode" then return "v" .. base .. "HM" end
    return base
end

function Profiles:GetInstanceItems(category)
    local list = category == "dungeon" and DUNGEON_NAMES or TRIAL_NAMES
    local items = {}
    local currentName, currentId = SafeZoneName(), SafeZoneId()
    if currentName ~= "" and currentId > 0 and not FindName(list, currentName) then
        items[#items + 1] = { name = "Current instance: " .. currentName, data = currentName }
    end
    for _, name in ipairs(list) do items[#items + 1] = { name = name, data = name } end
    return items
end

function Profiles:GenerateId()
    local timestamp = GetTimeStamp and GetTimeStamp() or math.floor(GetGameTimeMilliseconds() / 1000)
    self.idCounter = (self.idCounter or 0) + 1
    return tostring(timestamp) .. "-" .. tostring(self.idCounter) .. "-" .. tostring(math.random(1000, 9999))
end

function Profiles:GetById(profileId)
    if not profileId or profileId == "" then return nil end
    for _, profile in ipairs(SRC.saved.profiles or {}) do if profile.id == profileId then return profile end end
    return nil
end

function Profiles:GetActive() return self:GetById(SRC.saved.activeProfileId) end

function Profiles:GetItems()
    local items = {}
    for _, profile in ipairs(SRC.saved.profiles or {}) do
        local code = self:GetInstanceCode(profile)
        local objective = self:GetObjectiveLabel(profile.objective)
        items[#items + 1] = { name = string.format("%s - %s - %s", code, objective, tostring(profile.name or "Unnamed Raid Setup")), data = profile.id }
    end
    if #items == 0 then items[1] = { name = "No saved profiles", data = "" } end
    return items
end

function Profiles:CaptureConfiguration()
    if SRC.Display and SRC.Display.CaptureWindowPositions then SRC.Display:CaptureWindowPositions() end
    local configuration = {}
    for _, key in ipairs(PROFILE_KEYS) do configuration[key] = DeepCopy(SRC.saved[key]) end
    return configuration
end

function Profiles:ApplyConfiguration(configuration)
    if type(configuration) ~= "table" then return false end
    for _, key in ipairs(PROFILE_KEYS) do if configuration[key] ~= nil then SRC.saved[key] = DeepCopy(configuration[key]) end end
    if SRC.PruneInactiveAssignments then SRC:PruneInactiveAssignments() end

    local modules = { "ColossusRotation", "WarhornRotation", "BarrierRotation", "NazarayModule", "PillagerModule", "MajorSlayerModule", "CoverageTracker" }
    for _, moduleKey in ipairs(modules) do
        local module = SRC[moduleKey]
        if module and module.HardReset then module:HardReset("profile loaded")
        elseif module and module.RefreshDashboard then module:RefreshDashboard() end
    end
    if SRC.Display then
        SRC.Display:ClearDisabledModuleStates()
        if SRC.Display.ApplyMode then SRC.Display:ApplyMode() end
        if SRC.Display.ApplySettings then SRC.Display:ApplySettings() end
        if SRC.Display.RebuildEnabledModuleStates then SRC.Display:RebuildEnabledModuleStates()
        elseif SRC.Display.RenderDashboard then SRC.Display:RenderDashboard() end
    end
    if SRC.Diagnostics then SRC.Diagnostics:Add("PROFILE", "Loaded raid setup configuration") end
    return true
end

function Profiles:ResolveSelectedZoneId(instanceName)
    self:BuildInstanceCatalog()
    local selected = zo_strlower(zo_strtrim(instanceName or ""))
    local currentName, currentId = SafeZoneName(), SafeZoneId()
    if selected ~= "" and zo_strlower(currentName) == selected and currentId > 0 then return currentId end
    return tonumber(self.zoneIdsByName[selected]) or 0
end

function Profiles:CreateFromCurrent()
    SRC.saved.profiles = SRC.saved.profiles or {}
    if #SRC.saved.profiles >= self.MAX_PROFILES then return nil end
    local instanceName = TrimOrDefault(SRC.saved.profileDraftInstance, SafeZoneName())
    local profile = {
        id = self:GenerateId(),
        name = TrimOrDefault(SRC.saved.profileDraftName, "New Raid Setup"),
        category = SRC.saved.profileDraftCategory == "dungeon" and "dungeon" or "trial",
        instanceName = instanceName,
        difficulty = SRC.saved.profileDraftDifficulty or "veteran",
        objective = SRC.saved.profileDraftObjective or "prog",
        zoneId = self:ResolveSelectedZoneId(instanceName),
        createdAt = GetTimeStamp and GetTimeStamp() or 0,
        updatedAt = GetTimeStamp and GetTimeStamp() or 0,
        configuration = self:CaptureConfiguration(),
    }
    table.insert(SRC.saved.profiles, profile)
    SRC.saved.activeProfileId = profile.id
    SRC.saved.profileDraftName = ""
    self:ApplyConfiguration(profile.configuration)
    if SRC.Diagnostics then SRC.Diagnostics:Add("PROFILE", "Created raid setup: " .. profile.name) end
    return profile
end

function Profiles:SaveActive()
    local profile = self:GetActive(); if not profile then return false end
    profile.configuration = self:CaptureConfiguration()
    profile.updatedAt = GetTimeStamp and GetTimeStamp() or 0
    if profile.zoneId == 0 and zo_strlower(profile.instanceName or "") == zo_strlower(SafeZoneName()) then profile.zoneId = SafeZoneId() end
    if SRC.Diagnostics then SRC.Diagnostics:Add("PROFILE", "Saved active raid setup: " .. tostring(profile.name)) end
    return true
end

function Profiles:LoadActive()
    local profile = self:GetActive(); if not profile then return false end
    return self:ApplyConfiguration(profile.configuration)
end

function Profiles:SetActive(profileId, loadNow)
    if not profileId or profileId == "" then SRC.saved.activeProfileId = ""; return false end
    local profile = self:GetById(profileId); if not profile then return false end
    SRC.saved.activeProfileId = profileId
    if loadNow ~= false then self:LoadActive() end
    return true
end

function Profiles:FindForCurrentZone()
    local zoneId, zoneName = SafeZoneId(), zo_strlower(SafeZoneName())
    local matches = {}
    for _, profile in ipairs(SRC.saved.profiles or {}) do
        if (zoneId > 0 and tonumber(profile.zoneId) == zoneId) or (profile.instanceName and zo_strlower(profile.instanceName) == zoneName) then
            matches[#matches + 1] = profile
        end
    end
    return matches
end

function Profiles:OnPlayerActivated()
    if SRC.saved.autoLoadProfiles == false then return end
    local matches = self:FindForCurrentZone()
    if #matches == 1 then
        self:SetActive(matches[1].id, true)
        if SRC.Diagnostics then SRC.Diagnostics:Add("PROFILE", "Auto-loaded: " .. tostring(matches[1].name)) end
    elseif #matches > 1 then
        -- Preserve the user's last choice for this instance when several team setups exist.
        local active = self:GetActive()
        for _, profile in ipairs(matches) do if active and profile.id == active.id then return end end
        if SRC.Diagnostics then SRC.Diagnostics:Add("PROFILE", "Multiple raid setups match this instance; manual selection required") end
    end
end

function Profiles:DeleteActive()
    local activeId = SRC.saved.activeProfileId; if not activeId or activeId == "" then return false end
    for index, profile in ipairs(SRC.saved.profiles or {}) do
        if profile.id == activeId then
            table.remove(SRC.saved.profiles, index)
            SRC.saved.activeProfileId = ""
            if SRC.Display and SRC.Display.RebuildEnabledModuleStates then SRC.Display:RebuildEnabledModuleStates() end
            return true
        end
    end
    return false
end

local function EnabledText(value) return value and "On" or "Off" end
function Profiles:GetActiveSummary()
    local profile = self:GetActive()
    if not profile then return "No active raid setup selected." end
    local c = profile.configuration or {}
    local slayer = "Off"
    if c.majorSlayerEnabled then
        local methods = {}
        if c.roaringOpportunistEnabled then methods[#methods + 1] = "Roaring Opportunist" end
        if c.masterArchitectEnabled then methods[#methods + 1] = "Master's Architect" end
        if c.warMachineEnabled then methods[#methods + 1] = "War Machine" end
        slayer = #methods > 0 and table.concat(methods, " + ") or "Monitor only"
    end
    return string.format("%s\n%s | %s\n%s\n\nColossus: %s\nWarhorn: %s\nBarrier: %s\nNazaray: %s\nPillager: %s\nSlayer: %s",
        tostring(profile.name or "Unnamed Raid Setup"),
        self:GetInstanceCode(profile), self:GetObjectiveLabel(profile.objective),
        tostring(profile.instanceName or "Unassigned"),
        EnabledText(c.colossusEnabled), EnabledText(c.warhornEnabled), EnabledText(c.barrierEnabled),
        EnabledText(c.nazarayEnabled), EnabledText(c.pillagerEnabled), slayer)
end

function Profiles:ShowActiveSummary()
    if not self.summaryWindow then
        local window = WM:CreateTopLevelWindow("SupportRotationCalloutsProfileSummary")
        window:SetDimensions(620, 440); window:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0); window:SetClampedToScreen(true); window:SetHidden(true)
        local bg = WM:CreateControl(nil, window, CT_BACKDROP); bg:SetAnchorFill(); bg:SetCenterColor(0,0,0,0.92); bg:SetEdgeColor(1,0.82,0.1,0.8); bg:SetEdgeTexture(nil,2,2,2)
        local title = WM:CreateControl(nil, window, CT_LABEL); title:SetFont("$(BOLD_FONT)|26|outline"); title:SetAnchor(TOPLEFT,window,TOPLEFT,20,16); title:SetAnchor(TOPRIGHT,window,TOPRIGHT,-20,16); title:SetHeight(40); title:SetHorizontalAlignment(TEXT_ALIGN_CENTER); title:SetText("ACTIVE RAID SETUP")
        local body = WM:CreateControl(nil, window, CT_LABEL); body:SetFont("$(BOLD_FONT)|21|outline"); body:SetAnchor(TOPLEFT,title,BOTTOMLEFT,0,12); body:SetAnchor(BOTTOMRIGHT,window,BOTTOMRIGHT,-20,-20); body:SetVerticalAlignment(TEXT_ALIGN_TOP); body:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        self.summaryWindow, self.summaryBody = window, body
    end
    self.summaryBody:SetText(self:GetActiveSummary())
    if SRC.Diagnostics then SRC.Diagnostics:AcquireSettingsPanel("profileSummary") end
    self.summaryWindow:SetHidden(false)
    zo_callLater(function()
        if Profiles.summaryWindow then Profiles.summaryWindow:SetHidden(true) end
        if SRC.Diagnostics then SRC.Diagnostics:ReleaseSettingsPanel("profileSummary") end
    end, 12000)
end
