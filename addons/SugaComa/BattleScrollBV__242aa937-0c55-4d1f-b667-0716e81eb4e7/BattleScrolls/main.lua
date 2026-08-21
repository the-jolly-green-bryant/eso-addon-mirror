BattleScrolls = BattleScrolls or {}
BattleScrolls.addonName = "BattleScrolls"

function BattleScrolls.OnAddOnLoaded(_, addonName)
    if addonName ~= BattleScrolls.addonName then return end

    -- Intentionally limited to live build capture and Character-screen UI.
    -- No combat, effect, encounter, storage, network or meter module exists in
    -- the load manifest for this fork.
    BattleScrolls.characterStats:Initialize()

    EVENT_MANAGER:UnregisterForEvent("BattleScrollsBuildViewer_Main", EVENT_ADD_ON_LOADED)
end

EVENT_MANAGER:RegisterForEvent(
    "BattleScrollsBuildViewer_Main",
    EVENT_ADD_ON_LOADED,
    BattleScrolls.OnAddOnLoaded)
