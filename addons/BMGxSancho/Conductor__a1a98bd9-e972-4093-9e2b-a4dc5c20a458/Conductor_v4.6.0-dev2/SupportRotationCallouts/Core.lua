SupportRotationCallouts = SupportRotationCallouts or {}
local SRC = SupportRotationCallouts

SRC.name = "SupportRotationCallouts"
SRC.displayName = "Conductor"
SRC.version = "4.6.0-dev1.2"
SRC.updateName = SRC.name .. "Update"
SRC.bossMonitorName = SRC.name .. "BossMonitor"
SRC.modules = SRC.modules or {}

SRC.defaults = {
    enabled = true,
    encounterIntelligenceEnabled = true,
    temporaryEncounterDebugEnabled = false,
    temporaryEncounterDebugPositionSaved = false,
    temporaryEncounterDebugOffsetX = 30,
    temporaryEncounterDebugOffsetY = 0,
    temporaryEncounterDebugWidth = 450,
    temporaryEncounterDebugHeight = 270,
    encounterMinimumBurnWindow = 12,
    encounterDefaultCycleSeconds = 40,
    trashRotationEnabled = true,
    trashAdvanceOnCombatEnd = true,
    trashTeam4Pillager = true,
    trashCurrentTeam = 1,
    trashUltimateTeam1Enabled = true,
    trashUltimateTeam1Count = 1,
    trashUltimateTeam1 = { "", "", "", "", "", "" },
    trashUltimateTeam2Enabled = true,
    trashUltimateTeam2Count = 1,
    trashUltimateTeam2 = { "", "", "", "", "", "" },
    trashUltimateTeam3Enabled = true,
    trashUltimateTeam3Count = 1,
    trashUltimateTeam3 = { "", "", "", "", "", "" },
    trashUltimateTeam4Enabled = true,
    trashUltimateTeam4Count = 1,
    trashUltimateTeam4 = { "", "", "", "", "", "" },
    displayRole = "lead",
    rotationDashboardEnabled = false, -- retired; retained for saved-variable compatibility
    personalDashboardEnabled = false, -- retired; retained for saved-variable compatibility
    damageDealerDashboardEnabled = false, -- consolidated into Timeline

    dashboardVisibility = "combat",
    dashboardBackgroundOpacity = 0.38,
    roleDashboardDefaultsVersion = 0,
    ddCalloutRuntimeFixVersion = 0,
    encounterProfileSchemaVersion = 1,
    teamCoverageDashboardEnabled = false,
    teamCoverageDashboardDefaultsVersion = 0,
    teamCoverageScale = 0.85,
    teamCoverageOffsetX = 0,
    teamCoverageOffsetY = 0,
    teamCoveragePage = 1,
    teamCoverageCategory = "BUFF",
    teamCoveragePages = { BUFF=1, DEBUFF=1, OTHER=1 },
    trackedEffects = {},
    automaticEffectSelectionEnabled = false,
    trackedProviders = {},
    raidRosterSlots = {},
    progTeams = {},
    selectedProgTeamId = "",
    progTeamDraftName = "",
    progTeamComparison = nil,
    dummyMode = true,
    colossusEnabled = true,
    researchCaptureEnabled = false,
    nazarayEnabled = true,
    nazarayRotationCount = 1,
    nazarayRotation = { "@NAZARAY1", "", "", "" },
    pillagerEnabled = true,
    pillagerRotationCount = 1,
    pillagerRotation = { "@PILLAGER1", "", "", "" },
    majorSlayerEnabled = true,
    majorBrittleTrackingEnabled = false,
    minorCourageTrackingEnabled = false,
    majorResolveTrackingEnabled = false,
    powerfulAssaultTrackingEnabled = false,
    buffsDebuffsDashboardEnabled = true,
    buffsDebuffsScale = 0.9,
    buffsDebuffsOffsetX = 430,
    buffsDebuffsOffsetY = -120,
    buffsDebuffsShowTitle = true,
    warMachineEnabled = false,
    warMachineRotationCount = 1,
    warMachineRotation = { "@WM1", "", "", "" },
        masterArchitectEnabled = false,
    masterArchitectRotationCount = 1,
    masterArchitectRotation = { "@MA1", "", "", "" },
        roaringOpportunistEnabled = false,
    roaringOpportunistRotationCount = 1, -- retained for saved-variable compatibility
    roaringOpportunistRotation = { "@ROJO1", "", "", "" },
    roaringOpportunistAutomaticCoverage = true,
    profiles = {},
    activeProfileId = "",
    profileDraftName = "New Raid Setup",
    profileDraftCategory = "trial",
    profileDraftInstance = "",
    profileDraftDifficulty = "veteran",
    profileDraftObjective = "prog",
    profileDraftStrategy = "",
    raidPlanPlanningMode = "RECOMMENDED",
    raidPlanStrategyId = "",
    raidPlanTrashTeamFormat = "RECOMMENDED",
    raidPlanManualResponsibilities = {},
    activeRaidPlan = nil,
    autoLoadProfiles = true,
    diagnostics = false,
    developerDiagnostics = false,
    diagnosticMode = "off",
    diagnosticOverlay = false,
    diagnosticSessionName = "Trial Test",
    diagnosticSessions = {},
    activeDiagnosticSessionId = nil,
    selectedDiagnosticSession = "",
    scale = 1.0,
    offsetX = 0,
    offsetY = -180,
    personalScale = 1.0,
    personalOffsetX = 0,
    personalOffsetY = 60,
    timelineEnabled = true,
    timelineScale = 1.0,
    timelineWidth = 900,
    timelineHeight = 160,
    timelineOffsetX = 0,
    timelineOffsetY = 260,
    timelineBackgroundOpacity = 0.90,
    postPullChatEnabled = true,
    recommendationEnabled = true,
    recommendationChatEnabled = true,
    postPullChatOnlyMigrationVersion = 0,
    timelineConsolidationVersion = 0,
    leadCalloutEnabled = true,
    calloutScale = 1.0,
    calloutOffsetX = 0,
    calloutOffsetY = -80,
    damageDealerScale = 1.0,
    damageDealerOffsetX = 0,
    damageDealerOffsetY = -80,
    calloutColor = "gold",
    calloutLayout = "vertical",
    calloutAlignment = "center",
    calloutOrder = "nameFirst",
    dashboardShowTitle = false,
    confirmationEnabled = true,
    confirmationHoldMs = 900,
    supportQueueMode = "context",
    countdownStart = 3.0,
    dropThreshold = 0.5,
    calloutHoldMs = 1200,
    playSounds = true, -- Legacy setting retained for saved-variable compatibility.
    colossusNowSoundEnabled = false,
    warhornEnabled = true,
    warhornNowSoundEnabled = false,
    warhornRotationCount = 2,
    warhornRotation = { "@HORN1", "@HORN2", "", "" },
    barrierEnabled = true,
    barrierNowSoundEnabled = false,
    barrierRotationCount = 2,
    barrierRotation = { "@BARRIER1", "@BARRIER2", "", "" },
    wipeConfirmMs = 2500,
    rotationCount = 3,
    rotation = {
        "@COLO1",
        "@COLO2",
        "@COLO3",
        "",
    },
}

function SRC:Notify(message)
    message = tostring(message or "Conductor updated.")
    if ZO_Alert then pcall(ZO_Alert, UI_ALERT_CATEGORY_ALERT, nil, message)
    elseif CHAT_SYSTEM and CHAT_SYSTEM.AddMessage then CHAT_SYSTEM:AddMessage(message) end
end

function SRC:NormalizeAccountName(name)
    if not name or name == "" then return "" end
    local value = zo_strlower(zo_strtrim(name))
    if string.sub(value, 1, 1) ~= "@" then
        value = "@" .. value
    end
    return value
end


function SRC:PruneAssignmentList(countKey, rotationKey, maximum)
    local count = zo_clamp(tonumber(self.saved[countKey]) or 1, 1, maximum or 4)
    self.saved[countKey] = count
    self.saved[rotationKey] = self.saved[rotationKey] or {}

    local seen = {}
    for index = 1, maximum or 4 do
        local account = self:NormalizeAccountName(self.saved[rotationKey][index] or "")
        if index > count or account == "@" or seen[account] then
            account = ""
        end
        self.saved[rotationKey][index] = account
        if account ~= "" then seen[account] = true end
    end
end

function SRC:PruneInactiveAssignments()
    self:PruneAssignmentList("rotationCount", "rotation", 4)
    self:PruneAssignmentList("warhornRotationCount", "warhornRotation", 4)
    self:PruneAssignmentList("barrierRotationCount", "barrierRotation", 4)
    self:PruneAssignmentList("nazarayRotationCount", "nazarayRotation", 4)
    self:PruneAssignmentList("pillagerRotationCount", "pillagerRotation", 4)
    self:PruneAssignmentList("warMachineRotationCount", "warMachineRotation", 2)
    self:PruneAssignmentList("masterArchitectRotationCount", "masterArchitectRotation", 2)
    self:PruneAssignmentList("trashUltimateTeam1Count", "trashUltimateTeam1", 6)
    self:PruneAssignmentList("trashUltimateTeam2Count", "trashUltimateTeam2", 6)
    self:PruneAssignmentList("trashUltimateTeam3Count", "trashUltimateTeam3", 6)
    self:PruneAssignmentList("trashUltimateTeam4Count", "trashUltimateTeam4", 6)
    self.saved.roaringOpportunistRotationCount = 1
    self.saved.roaringOpportunistRotation = self.saved.roaringOpportunistRotation or {}
    self.saved.roaringOpportunistRotation[1] = self:NormalizeAccountName(self.saved.roaringOpportunistRotation[1] or "")
    for index = 2, 4 do self.saved.roaringOpportunistRotation[index] = "" end
end

function SRC:OnAssignmentSettingsChanged(moduleKey)
    self:PruneInactiveAssignments()
    local module = moduleKey and self[moduleKey] or nil
    if module and module.HardReset then
        module:HardReset("assignment settings changed")
    elseif module and module.RefreshDashboard then
        module:RefreshDashboard()
    end
end

local function NormalizeUnitName(name)
    if not name or name == "" then return "" end
    return zo_strlower(zo_strtrim(zo_strformat("<<1>>", name)))
end

function SRC:GetBossUnits(includeDead)
    local bosses = {}
    for index = 1, 12 do
        local tag = "boss" .. tostring(index)
        if DoesUnitExist(tag) and (includeDead or not IsUnitDead(tag)) then
            local name = NormalizeUnitName(GetUnitName(tag))
            if name ~= "" then
                bosses[name] = tag
            end
        end
    end
    return bosses
end

function SRC:IsBossTarget(unitName, unitTag)
    if unitTag and string.sub(unitTag, 1, 4) == "boss" and DoesUnitExist(unitTag) then
        return true
    end

    local normalized = NormalizeUnitName(unitName)
    if normalized == "" then return false end

    if self.knownEncounterBossNames and self.knownEncounterBossNames[normalized] then
        return true
    end

    return self:GetBossUnits(true)[normalized] ~= nil
end

function SRC:IsBossPresent()
    return next(self:GetBossUnits(false)) ~= nil
end

function SRC:RefreshKnownBosses()
    local current = self:GetBossUnits(true)
    for normalizedName, tag in pairs(current) do
        if not self.knownEncounterBossNames[normalizedName] then
            self.Diagnostics:AddFields("ENCOUNTER", "Boss unit observed", {
                unitTag = tag,
                unitName = GetUnitName(tag),
            })
        end
        self.knownEncounterBossNames[normalizedName] = tag
    end
end

function SRC:IsGroupWiped()
    if IsUnitDead("player") == false then return false end

    local groupSize = GetGroupSize()
    if groupSize <= 0 then return false end

    for index = 1, groupSize do
        local unitTag = GetGroupUnitTagByIndex(index)
        if unitTag and DoesUnitExist(unitTag) and not IsUnitDead(unitTag) then
            return false
        end
    end
    return true
end

function SRC:EndBossEncounter(reason)
    if not self.bossEncounterActive then return end
    self.bossEncounterActive = false
    self.bossTemporarilyUnavailable = false
    self.wipeSinceMs = nil
    ZO_ClearTable(self.knownEncounterBossNames)
    self.Diagnostics:Add("Boss encounter ended: " .. tostring(reason))
    self.ColossusRotation:OnBossEncounterEnded(reason)
    if self.WarhornRotation then self.WarhornRotation:OnBossEncounterEnded(reason) end
    if self.BarrierRotation then self.BarrierRotation:OnBossEncounterEnded(reason) end
    if self.EncounterEngine then self.EncounterEngine:ExitBoss(reason)
    elseif self.EncounterIntelligence then self.EncounterIntelligence:OnBossEncounterEnded(reason) end
end

function SRC:MonitorBossState()
    if not self.saved.enabled then return end

    local bossPresent = self:IsBossPresent()
    if bossPresent then
        self:RefreshKnownBosses()
        if self.bossTemporarilyUnavailable and self.EncounterEngine then
            self.EncounterEngine:SetBossAvailable(true, "boss unit returned")
        end
        self.bossTemporarilyUnavailable = false
        self.bossUnavailableSinceMs = nil
        self.wipeSinceMs = nil

        if not self.bossEncounterActive then
            self.bossEncounterActive = true
            self.Diagnostics:Add("Boss encounter detected")
            self.ColossusRotation:OnBossEncounterStarted()
            if self.WarhornRotation then self.WarhornRotation:OnBossEncounterStarted() end
            if self.BarrierRotation then self.BarrierRotation:OnBossEncounterStarted() end
            if self.EncounterEngine then self.EncounterEngine:EnterBoss("boss unit detected")
            elseif self.EncounterIntelligence then self.EncounterIntelligence:OnBossEncounterStarted() end
        end
        return
    end

    if not self.bossEncounterActive then return end

    if not self.bossTemporarilyUnavailable then
        self.bossTemporarilyUnavailable = true
        self.bossUnavailableSinceMs = GetGameTimeMilliseconds()
        self.Diagnostics:Add("Boss temporarily unavailable; encounter preserved")
        if self.EncounterEngine then self.EncounterEngine:SetBossAvailable(false, "boss unit unavailable") end
        self.ColossusRotation:OnBossTemporarilyUnavailable()
        if self.WarhornRotation then self.WarhornRotation:OnBossTemporarilyUnavailable() end
        if self.BarrierRotation then self.BarrierRotation:OnBossTemporarilyUnavailable() end
    end

    if self:IsGroupWiped() then
        local nowMs = GetGameTimeMilliseconds()
        if not self.wipeSinceMs then
            self.wipeSinceMs = nowMs
            self.Diagnostics:Add("Possible group wipe detected")
        elseif nowMs - self.wipeSinceMs >= self.saved.wipeConfirmMs then
            self:EndBossEncounter("group wipe")
        end
    else
        self.wipeSinceMs = nil
    end
end

function SRC:OnBossDeath(targetName)
    if not self.bossEncounterActive then return end

    local normalized = NormalizeUnitName(targetName)
    if normalized == "" then return end
    if not self.knownEncounterBossNames[normalized] then return end

    self.Diagnostics:Add("Known boss death detected: " .. tostring(targetName))
    self.knownEncounterBossNames[normalized] = nil

    zo_callLater(function()
        if not SRC.bossEncounterActive then return end
        SRC:RefreshKnownBosses()
        -- Do not end an encounter while combat is still active. Multi-stage bosses
        -- commonly remove every boss unit for several seconds between phases.
        if not SRC:IsBossPresent() and not SRC.inCombat then
            SRC:EndBossEncounter("boss defeated")
        end
    end, 3000)
end

local function OnPlayerCombatState(_, inCombat)
    SRC.inCombat = inCombat
    if inCombat then
        SRC.Roster:Refresh()
        SRC.Diagnostics:Add("COMBAT", "Combat started")
        if SRC.EncounterEngine then SRC.EncounterEngine:OnCombatStateChanged(true)
        elseif SRC.EncounterIntelligence then SRC.EncounterIntelligence:OnCombatStateChanged(true) end
        if SRC.Display and SRC.Display.ApplyMode then SRC.Display:ApplyMode() end
        return
    end

    SRC.Diagnostics:Add("COMBAT", "Combat ended")
    if SRC.EncounterEngine then SRC.EncounterEngine:OnCombatStateChanged(false)
    elseif SRC.EncounterIntelligence then SRC.EncounterIntelligence:OnCombatStateChanged(false) end
    if SRC.Display and SRC.Display.ApplyMode then SRC.Display:ApplyMode() end
    -- Confirm boss completion after a grace period. This prevents brief combat-state
    -- drops during phase transitions from clearing the encounter Timeline.
    zo_callLater(function()
        if SRC.bossEncounterActive and not SRC.inCombat and not SRC:IsBossPresent() then
            SRC:EndBossEncounter("combat ended after boss")
        end
    end, 2500)
    SRC.ColossusRotation:OnPlayerCombatEnded()
    if SRC.WarhornRotation then SRC.WarhornRotation:OnPlayerCombatEnded() end
    if SRC.BarrierRotation then SRC.BarrierRotation:OnPlayerCombatEnded() end
end

local function OnPlayerActivated()
    if not SRC.saved then return end
    SRC.bossEncounterActive = false
    SRC.bossTemporarilyUnavailable = false
    SRC.wipeSinceMs = nil
    ZO_ClearTable(SRC.knownEncounterBossNames)
    SRC.ColossusRotation:HardReset("player activated / zone load")
    if SRC.WarhornRotation then SRC.WarhornRotation:HardReset("player activated / zone load") end
    if SRC.BarrierRotation then SRC.BarrierRotation:HardReset("player activated / zone load") end
    SRC.Roster:Refresh()
    if SRC.PlayerScanner then SRC.PlayerScanner:ScanGroup() end
    if SRC.EncounterEngine then SRC.EncounterEngine:RefreshZone("player activated")
    elseif SRC.EncounterIntelligence then SRC.EncounterIntelligence:RefreshZone() end
end

function SRC:SetEnabled(enabled)
    self.saved.enabled = enabled
    if not enabled then
        self.bossEncounterActive = false
        self.bossTemporarilyUnavailable = false
        self.wipeSinceMs = nil
        ZO_ClearTable(self.knownEncounterBossNames)
        self.ColossusRotation:HardReset("addon disabled")
        if self.WarhornRotation then self.WarhornRotation:HardReset("addon disabled") end
        if self.BarrierRotation then self.BarrierRotation:HardReset("addon disabled") end
    else
        self.Roster:Refresh()
        self:MonitorBossState()
    end
end


function SRC:RegisterSupportEffectDefinitions()
    local manager = self.SupportEffectManager
    if not manager then return end

    local definitions = {
        {
            key = "COLOSSUS",
            family = "ultimate",
            mode = "coordination",
            isEnabled = function() return SRC.saved.colossusEnabled end,
            refresh = function() if SRC.ColossusRotation and SRC.ColossusRotation.RefreshDashboard then SRC.ColossusRotation:RefreshDashboard() end end,
            onDisabled = function() SRC.Display:ClearModuleState("COLOSSUS") end,
        },
        {
            key = "WARHORN",
            family = "ultimate",
            mode = "coordination",
            abilityIds = { 38564, 40224 },
            isEnabled = function() return SRC.saved.warhornEnabled end,
            refresh = function() if SRC.WarhornRotation and SRC.WarhornRotation.RefreshDashboard then SRC.WarhornRotation:RefreshDashboard() end end,
            onDisabled = function() SRC.Display:ClearModuleState("WARHORN") end,
        },
        {
            key = "BARRIER",
            family = "ultimate",
            mode = "coordination",
            isEnabled = function() return SRC.saved.barrierEnabled end,
            refresh = function() if SRC.BarrierRotation and SRC.BarrierRotation.RefreshDashboard then SRC.BarrierRotation:RefreshDashboard() end end,
            onDisabled = function() SRC.Display:ClearModuleState("BARRIER") end,
        },
        {
            key = "NAZARAY",
            family = "monster_set",
            mode = "coordination",
            abilityIds = { SRC.Nazaray and SRC.Nazaray.EFFECT_ID, SRC.Nazaray and SRC.Nazaray.MAJOR_VULNERABILITY_ID },
            isEnabled = function() return SRC.saved.nazarayEnabled end,
            refresh = function() if SRC.NazarayModule then SRC.NazarayModule:UpdateDashboard(nil, false) end end,
            onDisabled = function() SRC.Display:ClearModuleState("NAZARAY") end,
        },
        {
            key = "PILLAGER",
            family = "support_set",
            mode = "coordination",
            abilityIds = { SRC.Pillager and SRC.Pillager.PROC_ABILITY_ID },
            isEnabled = function() return SRC.saved.pillagerEnabled end,
            refresh = function() if SRC.PillagerModule then SRC.PillagerModule:UpdateDashboard() end end,
            onDisabled = function() SRC.Display:ClearModuleState("PILLAGER") end,
        },
        {
            key = "BRITTLE",
            family = "coverage",
            mode = "monitor",
            effectNames = { "Major Brittle" },
            isEnabled = function() return SRC.saved.majorBrittleTrackingEnabled == true end,
            refresh = function() if SRC.CoverageTracker then SRC.CoverageTracker:RefreshEffect("BRITTLE") end end,
            onDisabled = function() SRC.Display:ClearModuleState("BRITTLE") end,
        },
        {
            key = "MINOR_COURAGE",
            family = "coverage",
            mode = "monitor",
            effectNames = { "Minor Courage" },
            isEnabled = function() return SRC.saved.minorCourageTrackingEnabled == true end,
            refresh = function() if SRC.CoverageTracker then SRC.CoverageTracker:RefreshEffect("MINOR_COURAGE") end end,
            onDisabled = function() SRC.Display:ClearModuleState("MINOR_COURAGE") end,
        },
        {
            key = "MAJOR_RESOLVE",
            family = "coverage",
            mode = "monitor",
            effectNames = { "Major Resolve" },
            isEnabled = function() return SRC.saved.majorResolveTrackingEnabled == true end,
            refresh = function() if SRC.CoverageTracker then SRC.CoverageTracker:RefreshEffect("MAJOR_RESOLVE") end end,
            onDisabled = function() SRC.Display:ClearModuleState("MAJOR_RESOLVE") end,
        },
        {
            key = "POWERFUL_ASSAULT",
            family = "coverage",
            mode = "monitor",
            effectNames = { "Powerful Assault" },
            isEnabled = function() return SRC.saved.powerfulAssaultTrackingEnabled == true end,
            refresh = function() if SRC.CoverageTracker then SRC.CoverageTracker:RefreshEffect("POWERFUL_ASSAULT") end end,
            onDisabled = function() SRC.Display:ClearModuleState("POWERFUL_ASSAULT") end,
        },
        {
            key = "SLAYER",
            family = "support_set",
            mode = "coordination",
            abilityIds = { SRC.MajorSlayer and SRC.MajorSlayer.EFFECT_ID },
            isEnabled = function() return SRC.saved.majorSlayerEnabled end,
            refresh = function() if SRC.MajorSlayerModule then SRC.MajorSlayerModule:RefreshDashboard() end end,
            onDisabled = function() SRC.Display:ClearModuleState("SLAYER") end,
        },
    }

    for _, definition in ipairs(definitions) do manager:Register(definition) end
    self.Diagnostics:AddFields("EFFECT_ENGINE", "Registered support effect definitions", { count = #definitions })
end

function SRC:Initialize()
    self.saved = ZO_SavedVars:NewAccountWide("SupportRotationCalloutsSavedVariables", 1, nil, self.defaults)
    if self.saved.temporaryEncounterDebugDefaultCorrectionVersion ~= 1 then
        self.saved.temporaryEncounterDebugEnabled = false
        self.saved.temporaryEncounterDebugDefaultCorrectionVersion = 1
    end
    if (self.saved.postPullChatOnlyMigrationVersion or 0) < 1 then
        self.saved.postPullChatEnabled = true
        self.saved.raidHealthWindowEnabled = nil
        self.saved.raidHealthPositionSaved = nil
        self.saved.raidHealthOffsetX = nil
        self.saved.raidHealthOffsetY = nil
        self.saved.raidHealthWidth = nil
        self.saved.raidHealthHeight = nil
        self.saved.postPullChatOnlyMigrationVersion = 1
    end
    if self.saved.temporaryEncounterDebugCompactVersion ~= 1 then
        self.saved.temporaryEncounterDebugWidth = 450
        self.saved.temporaryEncounterDebugHeight = 270
        self.saved.temporaryEncounterDebugCompactVersion = 1
    end
    if (self.saved.manualEffectSelectionMigrationVersion or 0) < 1 then
        self.saved.automaticEffectSelectionEnabled = false
        self.saved.manualEffectSelectionMigrationVersion = 1
    end
    if self.saved.calloutsEnabled == nil then self.saved.calloutsEnabled = true end
    if self.saved.teamSharingEnabled == nil then self.saved.teamSharingEnabled = false end
    self.EventBus:Initialize()
    self.Registry:Initialize()
    self.Database:Initialize()
    self.KnowledgeBase:Initialize()
    self.ProviderIndex:Rebuild()
    if self.KnowledgeValidation then self.KnowledgeValidation:Initialize() end
    if self.ResponsibilityEngine then self.ResponsibilityEngine:Initialize() end
    self.AssignmentEngine:Initialize()
    if self.EncounterAssignmentProfiles then self.EncounterAssignmentProfiles:Initialize() end
    self.RecommendationEngine:Initialize()
    if self.RaidIntelligenceEngine then self.RaidIntelligenceEngine:Initialize() end
    if self.PostPullAnalytics then self.PostPullAnalytics:Initialize() end
    if self.ProviderGuidanceEngine then self.ProviderGuidanceEngine:Initialize() end
    if self.TrackingConfiguration then self.TrackingConfiguration:Initialize() end
    if self.TeamIntelligenceEngine then self.TeamIntelligenceEngine:Initialize() end
    self.PlayerScanner:Initialize()
    self.Network:Initialize()
    if self.saved.displayRole == "both" then
        self.saved.displayRole = "lead"
    end
    -- v3.3.0-dev2.2 consolidates combat coordination into the Timeline.
    -- Legacy dashboard settings remain only so older profiles and SavedVariables load safely.
    if (self.saved.timelineConsolidationVersion or 0) < 1 then
        self.saved.rotationDashboardEnabled = false
        self.saved.personalDashboardEnabled = false
        self.saved.damageDealerDashboardEnabled = false
        self.saved.timelineEnabled = true
        self.saved.timelineWidth = zo_clamp(tonumber(self.saved.timelineWidth) or 900, 600, 900)
        self.saved.timelineHeight = zo_clamp(tonumber(self.saved.timelineHeight) or 160, 110, 160)
        self.saved.timelineScale = zo_clamp(tonumber(self.saved.timelineScale) or 1, 0.80, 1.00)
        self.saved.timelineBackgroundOpacity = zo_clamp(tonumber(self.saved.timelineBackgroundOpacity) or 0.90, 0.70, 0.95)
        self.saved.timelineConsolidationVersion = 1
    end
    if (self.saved.roleDashboardDefaultsVersion or 0) < 2 then
        local role = self.saved.displayRole or "lead"
        if role == "support" then
            self.saved.rotationDashboardEnabled = false
            self.saved.personalDashboardEnabled = false
            self.saved.buffsDebuffsDashboardEnabled = true
            self.saved.damageDealerDashboardEnabled = false
        elseif role == "dd" then
            self.saved.rotationDashboardEnabled = false
            self.saved.personalDashboardEnabled = false
            self.saved.buffsDebuffsDashboardEnabled = true
            self.saved.damageDealerDashboardEnabled = false
        else
            self.saved.displayRole = "lead"
            self.saved.rotationDashboardEnabled = false
            self.saved.personalDashboardEnabled = false
            self.saved.buffsDebuffsDashboardEnabled = true
            self.saved.damageDealerDashboardEnabled = false
        end
        self.saved.roleDashboardDefaultsVersion = 2
    end
    -- dev4: Raid Setup profiles in earlier builds could restore an old DD dashboard
    -- toggle after the user selected Trial Lead. Reassert the role contract once:
    -- Trial Leads and Damage Dealers receive shared encounter guidance by default.
    if (self.saved.ddCalloutRuntimeFixVersion or 0) < 1 then
        local role = self.saved.displayRole or "lead"
        if role == "lead" or role == "dd" then
            self.saved.damageDealerDashboardEnabled = false
        end
        self.saved.ddCalloutRuntimeFixVersion = 1
    end

    if (self.saved.teamCoverageDashboardDefaultsVersion or 0) < 2 then
        -- Group Coverage is an on-demand reference panel. It never follows role defaults
        -- or persistent dashboard visibility rules.
        self.saved.teamCoverageDashboardEnabled = false
        self.saved.teamCoverageDashboardDefaultsVersion = 2
    end
    self:PruneInactiveAssignments()
    self.inCombat = IsUnitInCombat("player")
    self.bossEncounterActive = false
    self.bossTemporarilyUnavailable = false
    self.wipeSinceMs = nil
    self.knownEncounterBossNames = {}

    if self.RaidSession then self.RaidSession:Initialize() end
    if self.PublicRaidContext then self.PublicRaidContext:Initialize() end
    if self.SessionSharing then self.SessionSharing:Initialize() end
    if self.PersonalSession then self.PersonalSession:Initialize() end
    if self.SessionLifecycle then self.SessionLifecycle:Initialize() end
    -- Display must exist before LiveSession refresh invalidates module runtime;
    -- module hard resets may hide active callouts during that refresh.
    self.Display:Initialize()
    if self.LiveSession then self.LiveSession:Initialize() end
    if self.RuntimeContext then self.RuntimeContext:Initialize() end
    if self.ResponsibilityRuntime then self.ResponsibilityRuntime:Initialize() end
    if self.SequenceRuntime then self.SequenceRuntime:Initialize() end
    if self.TeamProfilesV2 then self.TeamProfilesV2:Initialize() end
    if self.TimelineEngine then self.TimelineEngine:Initialize() end
    if self.CombatContextEngine then self.CombatContextEngine:Initialize() end
    self.Diagnostics:Initialize()
    if self.KnowledgeDiagnostics then self.KnowledgeDiagnostics:Initialize() end
    self.SupportEffectEngine:Initialize()
    self.Roster:Initialize()
    self.Profiles:Initialize()
    self.GroupStats:Initialize()
    if self.TimelineDisplay then self.TimelineDisplay:Initialize() end
    if self.TeamCoverageDashboard then self.TeamCoverageDashboard:Initialize() end
    self.ColossusRotation:Initialize()
    self.ColossusEventAdapter:Initialize()
    self.WarhornRotation:Initialize()
    self.WarhornEventAdapter:Initialize()
    self.BarrierRotation:Initialize()
    self.BarrierEventAdapter:Initialize()
    if self.CoverageTracker then self.CoverageTracker:Initialize() end
    if self.ResearchCapture then self.ResearchCapture:Initialize() end
    if self.NazarayModule then self.NazarayModule:Initialize() end
    if self.PillagerModule then self.PillagerModule:Initialize() end
    if self.MajorSlayerModule then self.MajorSlayerModule:Initialize() end
    if self.TrashRotation then self.TrashRotation:Initialize() end
    if self.EncounterIntelligence then self.EncounterIntelligence:Initialize() end
    if self.EncounterKnowledgeRegistry then self.EncounterKnowledgeRegistry:Initialize() end
    if self.BurnWindowGuide then self.BurnWindowGuide:Initialize() end
    if self.ExecutionPlanCompiler then self.ExecutionPlanCompiler:Initialize() end
    if self.EncounterSequenceEngine then self.EncounterSequenceEngine:Initialize() end
    if self.EncounterExecutionRuntime then self.EncounterExecutionRuntime:Initialize() end
    if self.EncounterObservationEngine then self.EncounterObservationEngine:Initialize() end
    if self.EncounterEngine then self.EncounterEngine:Initialize() end
    if self.TemporaryEncounterDebug then self.TemporaryEncounterDebug:Initialize() end
    self:RegisterSupportEffectDefinitions()

    EVENT_MANAGER:RegisterForEvent(self.name .. "Combat", EVENT_PLAYER_COMBAT_STATE, OnPlayerCombatState)
    EVENT_MANAGER:RegisterForEvent(self.name .. "Activated", EVENT_PLAYER_ACTIVATED, OnPlayerActivated)

    local settingsEventName = self.name .. "SettingsPanel"
    EVENT_MANAGER:RegisterForEvent(settingsEventName, EVENT_PLAYER_ACTIVATED, function()
        EVENT_MANAGER:UnregisterForEvent(settingsEventName, EVENT_PLAYER_ACTIVATED)
        zo_callLater(function()
            if SRC.Settings and SRC.Settings.RegisterPanel then
                SRC.Settings:RegisterPanel()
            end
        end, 500)
    end)

    EVENT_MANAGER:RegisterForUpdate(self.bossMonitorName, 500, function() self:MonitorBossState() end)

    self.Roster:Refresh()
    self.Diagnostics:Add("Initialized v" .. self.version)
end

local function OnAddOnLoaded(_, addonName)
    if addonName ~= SRC.name then return end
    EVENT_MANAGER:UnregisterForEvent(SRC.name, EVENT_ADD_ON_LOADED)
    SRC:Initialize()
end

EVENT_MANAGER:RegisterForEvent(SRC.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
