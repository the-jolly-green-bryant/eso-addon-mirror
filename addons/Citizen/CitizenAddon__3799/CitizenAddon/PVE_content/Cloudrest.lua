CitizenCR = {
    name = "CitizenCR",
}

--Unregistor
local function Unregistor()
    EVENT_MANAGER:UnregisterForEvent(CitizenCR.name .."SiroriaFlareOSI", EVENT_COMBAT_EVENT)
    EVENT_MANAGER:UnregisterForEvent(CitizenCR.name .."SiroriaFlareExeOSI", EVENT_COMBAT_EVENT)
    EVENT_MANAGER:UnregisterForEvent(CitizenCR.name .."GalenweHoarfrostOSI", EVENT_COMBAT_EVENT)
    EVENT_MANAGER:UnregisterForEvent(CitizenCR.name .."GalenweHoarfrostExeOSI", EVENT_COMBAT_EVENT)
end

--Siroria Flare OSI
---CitizenCR.name .."SiroriaFlareOSI", EVENT_COMBAT_EVENT
    --COMBAT_RESULT, ACTION_RESULT_BEGIN
    --ABILITY_ID, 103531
---CitizenCR.name .."SiroriaFlareExeOSI", EVENT_COMBAT_EVENT
    --COMBAT_RESULT, ACTION_RESULT_BEGIN
    --ABILITY_ID, 110431
local function SiroriaFlare(_, _, _, _, _, _, _, _, _, _, _, _, _, _, _, targetUnitId, _, _)
    local targetUnitDisplayName = GetUnitDisplayName(CitizenAddon.group.unitIdToUnitTag[targetUnitId])
    CitizenNotifier.Icon(targetUnitDisplayName, CitizenMarker.iconData[13], CitizenAddon.PVEcontent.CR.siroriaFlareOsiIconSize, {1,0.5,0}, nil, nil, {6000,true})
end

--Galenwe Hoarfrost OSI
---CitizenCR.name .."GalenweHoarfrostOSI", EVENT_COMBAT_EVENT
    --ABILITY_ID, 103695
--CitizenCR.name .."GalenweHoarfrostExeOSI", EVENT_COMBAT_EVENT
    --ABILITY_ID, 110516
local function GalenweHoarfrost(_, result, _, _, _, _, _, _, _, _, _, _, _, _, _, targetUnitId, _, _)
    local targetUnitTag = CitizenAddon.group.unitIdToUnitTag[targetUnitId]
    local targetUnitDisplayName = GetUnitDisplayName(targetUnitTag)

    if result == ACTION_RESULT_EFFECT_GAINED then
        CitizenNotifier.Icon(targetUnitDisplayName, CitizenMarker.iconData[13], CitizenAddon.PVEcontent.CR.galenweHoarfrostOsiIconSize, {0,1,1}, nil, nil, {6000,true,false,true})

        EVENT_MANAGER:RegisterForEvent(CitizenCR.name .."DeathStateOf".. targetUnitTag, EVENT_UNIT_DEATH_STATE_CHANGED,
            function ()
                CitizenNotifier.RemoveIcon(targetUnitDisplayName)
                EVENT_MANAGER:UnregisterForEvent(CitizenCR.name .."DeathStateOf".. targetUnitTag, EVENT_UNIT_DEATH_STATE_CHANGED)
            end
        )--FILTERS
            EVENT_MANAGER:AddFilterForEvent(CitizenCR.name .."DeathStateOf".. targetUnitTag, EVENT_UNIT_DEATH_STATE_CHANGED, REGISTER_FILTER_UNIT_TAG, targetUnitTag)
        --
    elseif result == ACTION_RESULT_EFFECT_FADED then
        CitizenNotifier.RemoveIcon(targetUnitDisplayName)
        EVENT_MANAGER:UnregisterForEvent(CitizenCR.name .."DeathStateOf".. targetUnitTag, EVENT_UNIT_DEATH_STATE_CHANGED)
    end
end

--Is player in combat with correct target
---CitizenAddon.name .."InCombatInCR", EVENT_PLAYER_COMBAT_STATE
function CitizenCR.CombatState(_, inCombat)
    if inCombat then
        if CitizenAddon.PVEcontent.CR.siroriaFlareOsi then
            EVENT_MANAGER:RegisterForEvent(CitizenCR.name .."SiroriaFlareOSI", EVENT_COMBAT_EVENT, SiroriaFlare)--FILTERS
                EVENT_MANAGER:AddFilterForEvent(CitizenCR.name .."SiroriaFlareOSI", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_BEGIN)
                EVENT_MANAGER:AddFilterForEvent(CitizenCR.name .."SiroriaFlareOSI", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 103531)
            --
            EVENT_MANAGER:RegisterForEvent(CitizenCR.name .."SiroriaFlareExeOSI", EVENT_COMBAT_EVENT, SiroriaFlare)--FILTERS
                EVENT_MANAGER:AddFilterForEvent(CitizenCR.name .."SiroriaFlareExeOSI", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_BEGIN)
                EVENT_MANAGER:AddFilterForEvent(CitizenCR.name .."SiroriaFlareExeOSI", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 110431)
            --
        end
        if CitizenAddon.PVEcontent.CR.galenweHoarfrostOsi then
            EVENT_MANAGER:RegisterForEvent(CitizenCR.name .."GalenweHoarfrostOSI", EVENT_COMBAT_EVENT, GalenweHoarfrost)--FILTERS
                EVENT_MANAGER:AddFilterForEvent(CitizenCR.name .."GalenweHoarfrostOSI", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 103695)
            --
            EVENT_MANAGER:RegisterForEvent(CitizenCR.name .."GalenweHoarfrostExeOSI", EVENT_COMBAT_EVENT, GalenweHoarfrost)--FILTERS
                EVENT_MANAGER:AddFilterForEvent(CitizenCR.name .."GalenweHoarfrostExeOSI", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 110516)
            --
        end
    else
        Unregistor()
    end
end