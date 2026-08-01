CitizenDSR = {
    name = "CitizenDSR",
}
local potionAlert = false

--Unregistor
local function Unregistor()
    EVENT_MANAGER:UnregisterForEvent(CitizenDSR.name .."FireBrand", EVENT_COMBAT_EVENT)
    EVENT_MANAGER:UnregisterForEvent(CitizenDSR.name .."IceBrand", EVENT_COMBAT_EVENT)
    EVENT_MANAGER:UnregisterForEvent(CitizenDSR.name .."ReefGuardianAcidReflux", EVENT_COMBAT_EVENT)
    EVENT_MANAGER:UnregisterForEvent(CitizenDSR.name .."BrewMasterPotion", EVENT_COMBAT_EVENT)
    EVENT_MANAGER:UnregisterForEvent(CitizenDSR.name .."BehemothHack", EVENT_COMBAT_EVENT)
    EVENT_MANAGER:UnregisterForEvent(CitizenDSR.name .."BehemothCrush", EVENT_COMBAT_EVENT)
    EVENT_MANAGER:UnregisterForEvent(CitizenDSR.name .."LureOfTheSea", EVENT_COMBAT_EVENT)

    potionAlert = false
end
local function MechanicIconRemover()
    if CitizenMarker.mechanicIcons then
        for _, IconObject in pairs(CitizenMarker.mechanicIcons) do
            OSI.DiscardPositionIcon(IconObject)
        end
    end
end

--Fire and Ice brand OSI
---CitizenDSR.name .."FireBrand", EVENT_COMBAT_EVENT
    --COMBAT_RESULT, ACTION_RESULT_EFFECT_GAINED_DURATION
    --ABILITY_ID, 166472
---CitizenDSR.name .."IceBrand", EVENT_COMBAT_EVENT
    --COMBAT_RESULT, ACTION_RESULT_EFFECT_GAINED_DURATION
    --ABILITY_ID, 166482
local function FireAndIceBrand(_, _, _, _, _, _, _, _, _, _, _, _, _, _, _, targetUnitId, abilityId, _)
    if abilityId == 166472 then --Fire Brand
        CitizenNotifier.Icon(GetUnitDisplayName(CitizenAddon.group.unitIdToUnitTag[targetUnitId]), CitizenMarker.iconData[13], CitizenAddon.PVEcontent.DSR.lyAndTu.iceAndFireBrandOsiIconSize, {1,0.5,0}, nil, CitizenNotifier.OSI.callback.bounce, {5000})
    elseif abilityId == 166482 then --Ice Brand
        CitizenNotifier.Icon(GetUnitDisplayName(CitizenAddon.group.unitIdToUnitTag[targetUnitId]), CitizenMarker.iconData[13], CitizenAddon.PVEcontent.DSR.lyAndTu.iceAndFireBrandOsiIconSize, {0,1,1}, nil, CitizenNotifier.OSI.callback.bounce, {5000})
    end
end
--BrewMaster Potion Positions OSI
---CitizenDSR.name .."BrewMasterPotion", EVENT_COMBAT_EVENT
    --COMBAT_RESULT, ACTION_RESULT_EFFECT_GAINED
    --ABILITY_ID, 170547
local function BrewMasterPotionOSI(_, _, _, _, _, _, _, _, _, _, _, _, _, _, _, targetUnitId, _, _)
    if not potionAlert then
        CitizenNotifier.Alert("|c8800ffPOTIONS!|r", 1500, SOUNDS.DUEL_START)
        potionAlert = true
    end
    if targetUnitId ~= nil then
        local _, x, y ,z = GetUnitRawWorldPosition(CitizenAddon.group.unitIdToUnitTag[targetUnitId])

        CitizenNotifier.WroldPositionIcon(x, y, z, CitizenMarker.iconData[71], CitizenAddon.PVEcontent.DSR.trash.brewMasterPotionOsiIconSize, {0.5,0,1}, -1, nil, 10000)
    end
end
---CitizenDSR.name .."ReefGuardianAcidReflux", EVENT_COMBAT_EVENT
    --COMBAT_RESULT, ACTION_RESULT_BEGIN
    --COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER
    --ABILITY_ID, 163702
local function ReefAcidReflux(_, _, _, _, _, _, _, _, _, _, hitValue, _, _, _, _, _, abilityId, _)
    CombatAlerts.CastAlertsStart(abilityId, "Acid Reflux", hitValue, nil, nil, nil)
end
---CitizenDSR.name .."BehemothHack", EVENT_COMBAT_EVENT
    --COMBAT_RESULT, ACTION_RESULT_BEGIN
    --COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER
    --ABILITY_ID, 164162
local function BehemothHackAttack(_, _, _, _, _, _, _, _, _, _, hitValue, _, _, _, _, _, abilityId, _)
    PlaySound(SOUNDS.DUEL_START)
    CombatAlerts.CastAlertsStart(abilityId, "Hack!", hitValue, nil, nil, nil)
end
---CitizenDSR.name .."BehemothCrush", EVENT_COMBAT_EVENT
    --COMBAT_RESULT, ACTION_RESULT_BEGIN
    --COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER
    --ABILITY_ID, 164158
local function BehemothCrushAttack(_, _, _, _, _, _, _, _, _, _, hitValue, _, _, _, _, _, abilityId, _)
    PlaySound(SOUNDS.DUEL_START)
    CombatAlerts.CastAlertsStart(abilityId, "Crush!", hitValue, nil, nil, nil)
end
---CitizenDSR.name .."LureOfTheSea", EVENT_COMBAT_EVENT
    --COMBAT_RESULT, ACTION_RESULT_BEGIN
    --COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER
    --ABILITY_ID, 163952
local function LureOfTheSea(_, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, abilityId, _)
    PlaySound(SOUNDS.DUEL_FORFEIT)
    CombatAlerts.CastAlertsStart(abilityId, "Lure of the Sea!", 4000, nil, {0.5, 0, 0.5, 0.6}, {1000, "Break free!", 1, 0, 1, 1, SOUNDS.DUEL_START})
end
---CitizenDSR.name .."SeaBoilerAspectOfTerror", EVENT_COMBAT_EVENT
    --COMBAT_RESULT, ACTION_RESULT_BEGIN
    --COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER
    --ABILITY_ID, 174697
local function AspectOfTerror(_, _, _, _, _, _, _, _, _, _, hitValue, _, _, _, _, _, abilityId, _)
    PlaySound(SOUNDS.DUEL_FORFEIT)
    CombatAlerts.CastAlertsStart(abilityId, "Aspect of Terror!", hitValue, nil, nil, {1000, "Blodge!", 1, 0, 1, 1, SOUNDS.DUEL_START})
end

--Taleria Clock Numbers OSI
local function TaleriaClockNumbersOSI()
    for _, iconInfo in pairs(CitizenDSR.taleriaClockNumbersOsiList) do
        if iconInfo then
            table.insert(CitizenMarker.mechanicIcons, OSI.CreatePositionIcon(iconInfo[1], iconInfo[2], iconInfo[3], CitizenMarker.iconData[iconInfo[4]], iconInfo[5], nil, nil, nil))
        end
    end
end

--Is player in combat with correct target
---CitizenAddon.name .."InCombatInDSR", EVENT_PLAYER_COMBAT_STATE
function CitizenDSR.CombatState(_, inCombat)
    if inCombat then
        if DoesUnitExist('boss1') then
            if GetUnitName('boss1')=="Lylanar" or GetUnitName('boss2')=="Lylanar" then
                if CitizenAddon.PVEcontent.DSR.lyAndTu.iceAndFireBrandOsi then
                    EVENT_MANAGER:RegisterForEvent(CitizenDSR.name .."FireBrand", EVENT_COMBAT_EVENT, FireAndIceBrand)--FILTERS
                        EVENT_MANAGER:AddFilterForEvent(CitizenDSR.name .."FireBrand", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_EFFECT_GAINED_DURATION)
                        EVENT_MANAGER:AddFilterForEvent(CitizenDSR.name .."FireBrand", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 166472)
                    --
                    EVENT_MANAGER:RegisterForEvent(CitizenDSR.name .."IceBrand", EVENT_COMBAT_EVENT, FireAndIceBrand)--FILTERS
                        EVENT_MANAGER:AddFilterForEvent(CitizenDSR.name .."IceBrand", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_EFFECT_GAINED_DURATION)
                        EVENT_MANAGER:AddFilterForEvent(CitizenDSR.name .."IceBrand", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 166482)
                    --
                end
            elseif GetUnitName('boss1')=="Reef Guardian"then
                if CitizenAddon.PVEcontent.DSR.reef.acidReflux then
                    EVENT_MANAGER:RegisterForEvent(CitizenDSR.name .."ReefGuardianAcidReflux", EVENT_COMBAT_EVENT, ReefAcidReflux)--FILTERS
                        EVENT_MANAGER:AddFilterForEvent(CitizenDSR.name .."ReefGuardianAcidReflux", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_BEGIN)
                        EVENT_MANAGER:AddFilterForEvent(CitizenDSR.name .."ReefGuardianAcidReflux", EVENT_COMBAT_EVENT, REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
                        EVENT_MANAGER:AddFilterForEvent(CitizenDSR.name .."ReefGuardianAcidReflux", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 163702)
                    --
                end
            elseif GetUnitName('boss1')=="Tideborn Taleria" then
                if CitizenAddon.PVEcontent.DSR.taleria.behemothHack then
                    EVENT_MANAGER:RegisterForEvent(CitizenDSR.name .."BehemothHack", EVENT_COMBAT_EVENT, BehemothHackAttack)--FILTERS
                        EVENT_MANAGER:AddFilterForEvent(CitizenDSR.name .."BehemothHack", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_BEGIN)
                        EVENT_MANAGER:AddFilterForEvent(CitizenDSR.name .."BehemothHack", EVENT_COMBAT_EVENT, REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
                        EVENT_MANAGER:AddFilterForEvent(CitizenDSR.name .."BehemothHack", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 164162)
                    --
                end
                if CitizenAddon.PVEcontent.DSR.taleria.behemothCrush then
                    EVENT_MANAGER:RegisterForEvent(CitizenDSR.name .."BehemothCrush", EVENT_COMBAT_EVENT, BehemothCrushAttack)--FILTERS
                        EVENT_MANAGER:AddFilterForEvent(CitizenDSR.name .."BehemothCrush", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_BEGIN)
                        EVENT_MANAGER:AddFilterForEvent(CitizenDSR.name .."BehemothCrush", EVENT_COMBAT_EVENT, REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
                        EVENT_MANAGER:AddFilterForEvent(CitizenDSR.name .."BehemothCrush", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 164158)
                    --
                end
                if CitizenAddon.PVEcontent.DSR.taleria.sirenLureOfTheSea then
                    EVENT_MANAGER:RegisterForEvent(CitizenDSR.name .."LureOfTheSea", EVENT_COMBAT_EVENT, LureOfTheSea)--FILTERS
                        EVENT_MANAGER:AddFilterForEvent(CitizenDSR.name .."LureOfTheSea", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_BEGIN)
                        EVENT_MANAGER:AddFilterForEvent(CitizenDSR.name .."LureOfTheSea", EVENT_COMBAT_EVENT, REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
                        EVENT_MANAGER:AddFilterForEvent(CitizenDSR.name .."LureOfTheSea", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 163952)
                    --
                end
                if CitizenAddon.PVEcontent.DSR.taleria.seaBoilerAspectOfTerror then
                    EVENT_MANAGER:RegisterForEvent(CitizenDSR.name .."SeaBoilerAspectOfTerror", EVENT_COMBAT_EVENT, AspectOfTerror)--FILTERS
                        EVENT_MANAGER:AddFilterForEvent(CitizenDSR.name .."SeaBoilerAspectOfTerror", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_BEGIN)
                        EVENT_MANAGER:AddFilterForEvent(CitizenDSR.name .."SeaBoilerAspectOfTerror", EVENT_COMBAT_EVENT, REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
                        EVENT_MANAGER:AddFilterForEvent(CitizenDSR.name .."SeaBoilerAspectOfTerror", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 174697)
                    --
                end
            end
        else
            if CitizenAddon.PVEcontent.DSR.trash.brewMasterPotionOsi then
                EVENT_MANAGER:RegisterForEvent(CitizenDSR.name .."BrewMasterPotion", EVENT_COMBAT_EVENT, BrewMasterPotionOSI)--FILTERS
                    EVENT_MANAGER:AddFilterForEvent(CitizenDSR.name .."BrewMasterPotion", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_EFFECT_GAINED)
                    EVENT_MANAGER:AddFilterForEvent(CitizenDSR.name .."BrewMasterPotion", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 170547)
                --
            end
        end
    else
        Unregistor()
    end
end
--Boss changed
---CitizenAddon.name .."BossChangedInDSR", EVENT_BOSSES_CHANGED
function CitizenDSR.BossChanged(_, _)
    MechanicIconRemover()

    if GetUnitName('boss1')=="Tideborn Taleria" then
        if CitizenAddon.PVEcontent.DSR.taleria.clockNumbersOsi then
            TaleriaClockNumbersOSI()
        end
    end
end


------------------------------------
--Taleria clock numbers Data Table--
------------------------------------
CitizenDSR.taleriaClockNumbersOsiList = {
    [1] = 
    {
        [4] = 84,
        [1] = 171298,
        [2] = 36110,
        [3] = 30965,
        [5] = CitizenAddon.PVEcontent.DSR.taleria.clockNumbersOsiIconSize+32,
    },
    [2] = 
    {
        [4] = 84,
        [1] = 172712,
        [2] = 36098,
        [3] = 31771,
        [5] = CitizenAddon.PVEcontent.DSR.taleria.clockNumbersOsiIconSize+32,
    },
    [3] = 
    {
        [4] = 2,
        [1] = 170640,
        [2] = 36109,
        [3] = 31648,
        [5] = CitizenAddon.PVEcontent.DSR.taleria.clockNumbersOsiIconSize,
    },
    [4] = 
    {
        [4] = 2,
        [1] = 171274,
        [2] = 36101,
        [3] = 33145,
        [5] = CitizenAddon.PVEcontent.DSR.taleria.clockNumbersOsiIconSize,
    },
    [5] = 
    {
        [4] = 3,
        [1] = 169573,
        [2] = 36109,
        [3] = 31836,
        [5] = CitizenAddon.PVEcontent.DSR.taleria.clockNumbersOsiIconSize,
    },
    [6] = 
    {
        [4] = 3,
        [1] = 169349,
        [2] = 36108,
        [3] = 33277,
        [5] = CitizenAddon.PVEcontent.DSR.taleria.clockNumbersOsiIconSize,
    },
    [7] = 
    {
        [4] = 99,
        [1] = 167653,
        [2] = 36100,
        [3] = 32626,
        [5] = CitizenAddon.PVEcontent.DSR.taleria.clockNumbersOsiIconSize+32,
    },
    [8] = 
    {
        [4] = 99,
        [1] = 168695,
        [2] = 36103,
        [3] = 31412,
        [5] = CitizenAddon.PVEcontent.DSR.taleria.clockNumbersOsiIconSize+32,
    },
    [9] = 
    {
        [4] = 5,
        [1] = 168214,
        [2] = 36105,
        [3] = 30702,
        [5] = CitizenAddon.PVEcontent.DSR.taleria.clockNumbersOsiIconSize,
    },
    [10] = 
    {
        [4] = 5,
        [1] = 166557,
        [2] = 36109,
        [3] = 31283,
        [5] = CitizenAddon.PVEcontent.DSR.taleria.clockNumbersOsiIconSize,
    },
    [11] = 
    {
        [4] = 6,
        [1] = 166276,
        [2] = 36133,
        [3] = 29775,
        [5] = CitizenAddon.PVEcontent.DSR.taleria.clockNumbersOsiIconSize,
    },
    [12] = 
    {
        [4] = 6,
        [1] = 168005,
        [2] = 36108,
        [3] = 29851,
        [5] = CitizenAddon.PVEcontent.DSR.taleria.clockNumbersOsiIconSize,
    },
    [13] = 
    {
        [4] = 7,
        [1] = 166857,
        [2] = 36096,
        [3] = 27988,
        [5] = CitizenAddon.PVEcontent.DSR.taleria.clockNumbersOsiIconSize,
    },
    [14] = 
    {
        [4] = 7,
        [1] = 168339,
        [2] = 36107,
        [3] = 28984,
        [5] = CitizenAddon.PVEcontent.DSR.taleria.clockNumbersOsiIconSize,
    },
    [15] = 
    {
        [4] = 8,
        [1] = 169071,
        [2] = 36105,
        [3] = 28389,
        [5] = CitizenAddon.PVEcontent.DSR.taleria.clockNumbersOsiIconSize,
    },
    [16] = 
    {
        [4] = 8,
        [1] = 168318,
        [2] = 36106,
        [3] = 26754,
        [5] = CitizenAddon.PVEcontent.DSR.taleria.clockNumbersOsiIconSize,
    },
    [17] = 
    {
        [4] = 80,
        [1] = 169907,
        [2] = 36108,
        [3] = 28228,
        [5] = CitizenAddon.PVEcontent.DSR.taleria.clockNumbersOsiIconSize+32,
    },
    [18] = 
    {
        [4] = 80,
        [1] = 170090,
        [2] = 36105,
        [3] = 26550,
        [5] = CitizenAddon.PVEcontent.DSR.taleria.clockNumbersOsiIconSize+32,
    },
    [19] = 
    {
        [4] = 10,
        [1] = 170744,
        [2] = 36106,
        [3] = 28621,
        [5] = CitizenAddon.PVEcontent.DSR.taleria.clockNumbersOsiIconSize,
    },
    [20] = 
    {
        [4] = 10,
        [1] = 171733,
        [2] = 36104,
        [3] = 27238,
        [5] = CitizenAddon.PVEcontent.DSR.taleria.clockNumbersOsiIconSize,
    },
    [21] = 
    {
        [4] = 11,
        [1] = 171281,
        [2] = 36103,
        [3] = 29279,
        [5] = CitizenAddon.PVEcontent.DSR.taleria.clockNumbersOsiIconSize,
    },
    [22] = 
    {
        [4] = 11,
        [1] = 172807,
        [2] = 36102,
        [3] = 28607,
        [5] = CitizenAddon.PVEcontent.DSR.taleria.clockNumbersOsiIconSize,
    },
    [23] = 
    {
        [4] = 12,
        [1] = 171569,
        [2] = 36108,
        [3] = 30066,
        [5] = CitizenAddon.PVEcontent.DSR.taleria.clockNumbersOsiIconSize,
    },
    [24] = 
    {
        [4] = 12,
        [1] = 173169,
        [2] = 36097,
        [3] = 30171,
        [5] = CitizenAddon.PVEcontent.DSR.taleria.clockNumbersOsiIconSize,
    },
}