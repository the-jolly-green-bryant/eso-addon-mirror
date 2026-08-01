DynamicPotions = DynamicPotions or {
    name = "DynamicPotions",
    isStationInteract = false,
}

local DP = DynamicPotions

function DP:Initialize()
    -- Ensure global table is available for other modules
    if not _G["DynamicPotions"] then
        _G["DynamicPotions"] = DP
    end

    DP:InitializeHooks()
    DP:InitializeTooltipHooks()

    EVENT_MANAGER:RegisterForEvent(DP.name, EVENT_CRAFTING_STATION_INTERACT,
        function()
            DP.isStationInteract = true
        end
    )

    EVENT_MANAGER:RegisterForEvent(DP.name, EVENT_END_CRAFTING_STATION_INTERACT,
        function()
            DP.isStationInteract = false
        end
    )
end

function DP.OnAddOnLoaded(_, addonName)
    if addonName == DP.name then
        DP:Initialize()
        EVENT_MANAGER:UnregisterForEvent(DP.name, EVENT_ADD_ON_LOADED)
    end
end

EVENT_MANAGER:RegisterForEvent(DP.name, EVENT_ADD_ON_LOADED, DP.OnAddOnLoaded)