BMGAdventures = BMGAdventures or {}
local BA = BMGAdventures
BA.name = "BMGAdventures"
BA.displayName = "BMG Adventures"
BA.version = "0.0.01-dev2.5"
BA.author = "@BMGXSANCHO"
BA.initialized = false

local function OnAddOnLoaded(_, addonName)
    if addonName ~= BA.name then return end
    EVENT_MANAGER:UnregisterForEvent(BA.name, EVENT_ADD_ON_LOADED)

    BA.Constants:Initialize()
    BA.SavedVariables:Initialize()
    BA.Migrations:Run()
    BA.Diagnostics:Initialize()

    BA.RegistryValidation:ValidateAll()
    BA.ChallengeIndex:Build()
    BA.Profile:Initialize()
    BA.ProgressionEngine:Initialize()
    BA.UnlockEngine:Initialize()
    BA.Transaction:Initialize()
    BA.CollectionEngine:Initialize()
    BA.ChallengeEngine:Initialize()
    BA.ActivityRouter:Initialize()

    BA.AchievementAdapter:Initialize()
    BA.TrialAdapter:Initialize()
    BA.QuestAdapter:Initialize()
    BA.ExplorationAdapter:Initialize()
    BA.PvPAdapter:Initialize()
    BA.MasteryAdapter:Initialize()
    BA.PlayerStateAdapter:Initialize()

    -- User-facing systems initialize before optional diagnostic adapters.
    -- A diagnostic-only adapter must never prevent the settings menu from registering.
    BA.Journal:Initialize()
    BA.DeveloperTools:Initialize()
    BA.LegacyImport:Initialize()
    BA.Settings:Initialize()
    BA.IntegrationAPI:Initialize()

    -- Dev2 diagnostics: intentionally non-authoritative and initialized last.
    BA.DungeonAdapter:Initialize()
    BA.WorldEventAdapter:Initialize()

    BA.initialized = true
    BA.EventBus:Publish("BMG_INITIALIZED", { version = BA.version })
end

EVENT_MANAGER:RegisterForEvent(BA.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
