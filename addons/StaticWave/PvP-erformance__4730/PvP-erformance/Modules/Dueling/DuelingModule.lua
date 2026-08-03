local PvPerformance = PvPerformance
local Dueling = PvPerformance.Modules.Dueling
local Private = PvPerformance.Private
setfenv(1, setmetatable({
    PvPerformance = PvPerformance,
    Dueling = Dueling,
    Private = Private,
}, {
    __index = function(_, key)
        local value = Private[key]
        if value ~= nil then
            return value
        end
        return _G[key]
    end,
}))

function Dueling:Initialize()
    PvPerformance.activeModule = "dueling"
    self.savedVars.history = self.savedVars.history or {}
    self.savedVars.window = self.savedVars.window or {}
    self.savedVars.werewolfAbilityIds = self.savedVars.werewolfAbilityIds or {}
    self.savedVars.opponentNotes = self.savedVars.opponentNotes or {}
    self:GetSettings()
    self:NormalizeHistoricalForfeits()
    if not self.savedVars.ranking
        or not self.savedVars.ranking.opponentDuels
        or not self.savedVars.ranking.qualifyingOpponents
        or self.savedVars.ranking.qualifyingCount == nil
        or self.savedVars.ranking.rating == nil
        or self.savedVars.ranking.rulesVersion ~= RATING_RULES_VERSION then
        self:RebuildRankingFromHistory()
    end
    if type(self.savedVars.classRankings) ~= "table"
        or self.savedVars.classRankingRulesVersion ~= CLASS_RATING_RULES_VERSION then
        self:RebuildClassRankingsFromHistory()
    end

    -- Build the hidden window now, but create its scene lazily on the first
    -- real open. Registering a custom scene during EVENT_ADD_ON_LOADED can
    -- precede ESO's initial HUD scene synchronization; in that state the
    -- window is visible but the first ESC press is not routed to its scene.
    -- OpenJournal initializes the scene after login has settled.
    self:CreateUI()

    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_DUEL_COUNTDOWN, function(...)
        Dueling:OnDuelCountdown(...)
    end)
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_DUEL_FINISHED, function(...)
        Dueling:OnDuelFinished(...)
    end)
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_PLAYER_DEACTIVATED, function(...)
        Dueling:OnPlayerDeactivated(...)
    end)

    SLASH_COMMANDS["/duelledger"] = function(argument)
        Dueling:OnSlashCommand(argument)
    end
    SLASH_COMMANDS["/dl"] = SLASH_COMMANDS["/duelledger"]
    SLASH_COMMANDS["/metrics"] = SLASH_COMMANDS["/duelledger"]
    SLASH_COMMANDS["/pvp"] = SLASH_COMMANDS["/duelledger"]
    SLASH_COMMANDS["/pvperformance"] = SLASH_COMMANDS["/duelledger"]

    Print("Loaded. Type /metrics help for commands.")
end

function Dueling:SelectModule(moduleName)
    if moduleName ~= "dueling" then
        return
    end
    PvPerformance.activeModule = "dueling"
    local Analytics = PvPerformance.Modules.Analytics
    if Analytics and Analytics.SetVisible then
        Analytics:SetVisible(false)
    end
    if self:IsSceneActive() then
        self:RefreshUI()
    else
        self:OpenJournal()
    end
end
