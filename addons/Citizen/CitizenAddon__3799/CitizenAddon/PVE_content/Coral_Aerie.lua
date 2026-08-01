CitizenCA = {
    name = "CitizenCA",
}
local varallion = {
    link1 = "",
}

--Unregistor
local function Unregistor()
    CitizenNotifier.RemoveAllBanners()
    EVENT_MANAGER:UnregisterForEvent(CitizenCR.name .."SiroriaFlareOSI", EVENT_COMBAT_EVENT)
    EVENT_MANAGER:UnregisterForEvent(CitizenCR.name .."SiroriaFlareExeOSI", EVENT_COMBAT_EVENT)
end

--Mind Link OSI
---CitizenCR.name .."MindLink1", EVENT_COMBAT_EVENT
    --COMBAT_RESULT, ACTION_RESULT_EFFECT_GAINED
    --ABILITY_ID, 149225
---CitizenCR.name .."MindLink2", EVENT_COMBAT_EVENT
    --COMBAT_RESULT, ACTION_RESULT_EFFECT_GAINED
    --ABILITY_ID, 149227
local function MindLinkOSI(_, _, _, _, _, _, _, _, _, _, _, _, _, _, _, targetUnitId, abilityId, _)
    if abilityId == 149225 then
            varallion.link1 = GetUnitDisplayName(CitizenAddon.group.unitIdToUnitTag[targetUnitId])

    elseif abilityId == 149227 then
        local targetUnitDisplayName = GetUnitDisplayName(CitizenAddon.group.unitIdToUnitTag[targetUnitId])

        CitizenNotifier.Icon(varallion.link1, CitizenMarker.iconData[13], CitizenAddon.PVEcontent.CA.varallion.mindLinkOsiIconSize+28, {1,0,0}, nil, CitizenNotifier.OSI.callback.bounce, {3700,true})
        CitizenNotifier.Icon(targetUnitDisplayName, CitizenMarker.iconData[13], CitizenAddon.PVEcontent.CA.varallion.mindLinkOsiIconSize+28, {1,0,0}, nil, CitizenNotifier.OSI.callback.bounce, {3700,true})

        zo_callLater(
            function()
                CitizenNotifier.Icon(varallion.link1, CitizenMarker.iconData[71], CitizenAddon.PVEcontent.CA.varallion.mindLinkOsiIconSize-28, {0.5,0,1}, nil, nil, {25000,true})
                CitizenNotifier.Icon(targetUnitDisplayName, CitizenMarker.iconData[71], CitizenAddon.PVEcontent.CA.varallion.mindLinkOsiIconSize-28, {0.5,0,1}, nil, nil, {25000,true})
            end,
            4000
        )
    end
end

--Is player in combat with correct target
---CitizenAddon.name .."InCombatInCA", EVENT_PLAYER_COMBAT_STATE
function CitizenCA.CombatState(_, inCombat)
    if inCombat then
        if DoesUnitExist('boss1') then
            if GetUnitName('boss1') == "Varallion" then
                if CitizenAddon.PVEcontent.CA.varallion.mindLinkOsi then
                    EVENT_MANAGER:RegisterForEvent(CitizenCR.name .."MindLink1", EVENT_COMBAT_EVENT, MindLinkOSI)--FILTERS
                        EVENT_MANAGER:AddFilterForEvent(CitizenCR.name .."MindLink1", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_EFFECT_GAINED)
                        EVENT_MANAGER:AddFilterForEvent(CitizenCR.name .."MindLink1", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 149225)
                    --
                    EVENT_MANAGER:RegisterForEvent(CitizenCR.name .."MindLink2", EVENT_COMBAT_EVENT, MindLinkOSI)--FILTERS
                        EVENT_MANAGER:AddFilterForEvent(CitizenCR.name .."MindLink2", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_EFFECT_GAINED)
                        EVENT_MANAGER:AddFilterForEvent(CitizenCR.name .."MindLink2", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 149227)
                    --
                end
            end
        end
    else
        Unregistor()
    end
end