WarCry = WarCry or {}
WarCry.name = "WarCry"

ZO_CreateStringId("SI_BINDING_NAME_WARCRY_AHU_PLAY", "Play AHU Warcry")
ZO_CreateStringId("SI_BINDING_NAME_WARCRY_ROAR_PLAY", "Play ROAR Warcry")

function WarCry.OnAddOnLoaded(event, addonName)
    if addonName == WarCry.name then
        EVENT_MANAGER:UnregisterForEvent(WarCry.name, EVENT_ADD_ON_LOADED)

        for name, IDs in pairs(WarCry.List) do
            LibWarCry:CreateWarCry(name, IDs)
        end
    end
end

EVENT_MANAGER:RegisterForEvent(WarCry.name, EVENT_ADD_ON_LOADED, WarCry.OnAddOnLoaded)