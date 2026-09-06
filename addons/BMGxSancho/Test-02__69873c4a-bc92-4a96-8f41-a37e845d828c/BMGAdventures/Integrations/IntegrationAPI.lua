local BA = BMGAdventures
BA.IntegrationAPI = BA.IntegrationAPI or {}

function BA.IntegrationAPI:Initialize()
    BMGAdventuresAPI = {
        IsAvailable = function() return BA.initialized == true end,
        HasUnlock = function(_, id) return BA.UnlockEngine:HasUnlock(id) end,
        GetUnlock = function(_, id) return BA.Rewards.unlocks[id] or BA.Rewards.titles[id] or BA.Rewards.badges[id] end,
        GetProfileSummary = function() return BA.SnapshotBuilder:Build() end,
        GetEquippedTitle = function() return BA.account.presentation.equippedTitle end,
        GetFeaturedBadges = function() return BA.account.presentation.featuredBadges end,
        RegisterCallback = function(_, eventName, callback) BA.EventBus:Subscribe(eventName, callback) end,
    }
end
