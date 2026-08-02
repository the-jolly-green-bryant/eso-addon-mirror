local C = Conductor
C.TrackingConfiguration = C.TrackingConfiguration or {}
local Config = C.TrackingConfiguration

local DD_ALWAYS_VISIBLE = {
    MAJOR_SLAYER = true,
    OFF_BALANCE = true,
}

local function EnsureTable(key)
    C.saved[key] = C.saved[key] or {}
    return C.saved[key]
end

local function NormalizeAccount(name)
    if C.NormalizeAccountName then return C:NormalizeAccountName(name or "") end
    local value = string.lower(tostring(name or ""))
    if value ~= "" and string.sub(value, 1, 1) ~= "@" then value = "@" .. value end
    return value
end

local function IsDashboardEffect(effect)
    return effect and (effect.effectType == "BUFF" or effect.effectType == "DEBUFF")
end

local function AddProfileEffects(target, profile)
    if not profile then return end
    for _, list in ipairs({ profile.buffs or {}, profile.debuffs or {} }) do
        for _, entry in ipairs(list) do
            if entry and entry.key then target[entry.key] = true end
        end
    end
end

local function FindLocalPlayer(team)
    local localAccount = NormalizeAccount(GetDisplayName and GetDisplayName() or "")
    for _, player in ipairs((team and team.players) or {}) do
        if player.isLocalPlayer == true or NormalizeAccount(player.accountName) == localAccount then return player end
    end
    if C.Database and localAccount ~= "" then return C.Database:GetPlayer(localAccount) end
    return nil
end

function Config:GetCoreEffectKeys(effectType)
    local output = {}
    if C.ProviderGuidanceEngine then
        for _, effect in ipairs(C.ProviderGuidanceEngine:GetCoreEffects(effectType) or {}) do
            output[#output + 1] = effect.key
        end
    end
    table.sort(output, function(a, b)
        local ae = C.Registry and C.Registry:Get("EFFECTS", a)
        local be = C.Registry and C.Registry:Get("EFFECTS", b)
        return tostring(ae and ae.name or a) < tostring(be and be.name or b)
    end)
    return output
end

function Config:IsEffectEnabled(effectKey)
    local values = EnsureTable("trackedEffects")
    if values[effectKey] == nil then
        local effect = C.Registry and C.Registry:Get("EFFECTS", effectKey)
        return effect and effect.defaultTracked == true or false
    end
    return values[effectKey] == true
end

function Config:SetEffectEnabled(effectKey, enabled)
    EnsureTable("trackedEffects")[effectKey] = enabled == true
    if C.TeamCoverageDashboard then C.TeamCoverageDashboard:Refresh() end
    if C.Display and C.Display.RenderBuffsDebuffs then C.Display:RenderBuffsDebuffs() end
end

function Config:IsAutomaticEffectSelectionEnabled()
    return C.saved.automaticEffectSelectionEnabled == true
end

function Config:SetAutomaticEffectSelectionEnabled(enabled)
    C.saved.automaticEffectSelectionEnabled = enabled == true
    if enabled then self:ApplyAutomaticEffectSelection(nil, "setting_enabled") end
end

function Config:GetAutomaticEffectKeys(team)
    team = team or (C.TeamIntelligenceEngine and C.TeamIntelligenceEngine.currentTeam)
        or (C.TeamIntelligenceEngine and C.TeamIntelligenceEngine:BuildCurrentTeam())
        or { players = {}, effects = {} }

    local selected = {}
    local role = C.saved.displayRole or "lead"

    if role == "lead" then
        for effectKey in pairs(team.effects or {}) do
            local effect = C.Registry and C.Registry:Get("EFFECTS", effectKey)
            if IsDashboardEffect(effect) then selected[effectKey] = true end
        end
    else
        local player = FindLocalPlayer(team)
        local profile = player and (player.raidIntelligence or (player.capabilities and player.capabilities.raidIntelligence)) or nil
        AddProfileEffects(selected, profile)
        if role == "dd" then
            for effectKey in pairs(DD_ALWAYS_VISIBLE) do selected[effectKey] = true end
        end
    end

    return selected
end

function Config:ApplyAutomaticEffectSelection(team, reason)
    if not self:IsAutomaticEffectSelectionEnabled() or self.applyingAutomaticSelection then return false end
    self.applyingAutomaticSelection = true

    local selected = self:GetAutomaticEffectKeys(team)
    local values = EnsureTable("trackedEffects")
    local changed = false
    for _, effect in ipairs(C.Registry and C.Registry:GetAll("EFFECTS") or {}) do
        if IsDashboardEffect(effect) then
            local enabled = selected[effect.key] == true
            if values[effect.key] ~= enabled then
                values[effect.key] = enabled
                changed = true
            end
        end
    end

    C.saved.automaticEffectSelectionLastReason = tostring(reason or "team_refresh")
    C.saved.automaticEffectSelectionLastAt = GetGameTimeMilliseconds and GetGameTimeMilliseconds() or 0
    self.applyingAutomaticSelection = false

    if changed then
        if C.CoverageTracker and C.CoverageTracker.RefreshAll then C.CoverageTracker:RefreshAll() end
        if C.Display and C.Display.RenderBuffsDebuffs then C.Display:RenderBuffsDebuffs() end
    end
    return changed
end

function Config:IsRegistryEntryEnabled(collection, key)
    local root = EnsureTable("trackedProviders")
    root[collection] = root[collection] or {}
    if root[collection][key] == nil then return true end
    return root[collection][key] == true
end

function Config:SetRegistryEntryEnabled(collection, key, enabled)
    local root = EnsureTable("trackedProviders")
    root[collection] = root[collection] or {}
    root[collection][key] = enabled == true
    if C.PlayerScanner and C.PlayerScanner.ScheduleRefresh then C.PlayerScanner:ScheduleRefresh("tracking_configuration") end
end

function Config:Initialize()
    EnsureTable("trackedEffects")
    EnsureTable("trackedProviders")
    if C.saved.automaticEffectSelectionEnabled == nil then C.saved.automaticEffectSelectionEnabled = false end
    C.saved.raidRosterSlots = C.saved.raidRosterSlots or {}
    local roles = {"Tank 1", "Tank 2", "Healer 1", "Healer 2", "DD 1", "DD 2", "DD 3", "DD 4", "DD 5", "DD 6", "DD 7", "DD 8"}
    for index = 1, 12 do
        C.saved.raidRosterSlots[index] = C.saved.raidRosterSlots[index] or {
            role = roles[index], player = "", class = "", set1 = "", set2 = "", monster = "NONE", mythic = "NONE", arena = "NONE", manualPlayer = "", manualSet1 = "", manualSet2 = "", manualMonster = "", manualMythic = "", manualArena = "", manualNotes = "", source = "MANUAL",
        }
        local slot = C.saved.raidRosterSlots[index]
        slot.arena = slot.arena or "NONE"
        slot.manualPlayer = slot.manualPlayer or ""
        slot.manualSet1 = slot.manualSet1 or ""
        slot.manualSet2 = slot.manualSet2 or ""
        slot.manualMonster = slot.manualMonster or ""
        slot.manualMythic = slot.manualMythic or ""
        slot.manualArena = slot.manualArena or ""
        slot.manualNotes = slot.manualNotes or ""
    end
    self.initialized = true
end
