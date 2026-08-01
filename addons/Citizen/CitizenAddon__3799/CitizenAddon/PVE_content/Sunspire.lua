CitizenSS = {
    name = "CitizenSS",
}
local bossFly = {
    [1] = 0,
    [2] = 0,
    [3] = 0,
}
local bossFlying = false
local bossLandTime = 0
local hpLeftToFly = 0
local lokke = {
    beamOsi = false,
    beamIcons = {},
    tillBeam = 0
}
local nahvi = {
    inPortal = false,
    portalMembers = 0,
    portalEntranceTime = 0,
    portalWipeTime = 0
}

--Unregistor
local function Unregistor()
    CitizenNotifier.RemoveAllBanners()

    EVENT_MANAGER:UnregisterForUpdate(CitizenSS.name .."BossHealth")
    EVENT_MANAGER:UnregisterForUpdate(CitizenSS.name .."BossFly")
    EVENT_MANAGER:UnregisterForUpdate(CitizenSS.name .."BossLandTrace")

    EVENT_MANAGER:UnregisterForEvent(CitizenSS.name .."Lokke1stFly", EVENT_COMBAT_EVENT)
    EVENT_MANAGER:UnregisterForEvent(CitizenSS.name .."Lokke2ndFly", EVENT_COMBAT_EVENT)
    EVENT_MANAGER:UnregisterForEvent(CitizenSS.name .."Lokke3rdFly", EVENT_COMBAT_EVENT)

    EVENT_MANAGER:UnregisterForEvent(CitizenSS.name .."Yolna1stFly", EVENT_COMBAT_EVENT)
    EVENT_MANAGER:UnregisterForEvent(CitizenSS.name .."Yolna2ndFly", EVENT_COMBAT_EVENT)
    EVENT_MANAGER:UnregisterForEvent(CitizenSS.name .."Yolna3rdFly", EVENT_COMBAT_EVENT)

    EVENT_MANAGER:UnregisterForEvent(CitizenSS.name .."NahviLands", EVENT_COMBAT_EVENT)
    EVENT_MANAGER:UnregisterForEvent(CitizenSS.name .."NahviPortalOpened", EVENT_COMBAT_EVENT)
    EVENT_MANAGER:UnregisterForUpdate(CitizenSS.name .."PortalEntranceTracker")
    EVENT_MANAGER:UnregisterForUpdate(CitizenSS.name .."PortalWipeTracker")
    EVENT_MANAGER:UnregisterForEvent(CitizenSS.name .."NahviPortalUsed", EVENT_COMBAT_EVENT)
    EVENT_MANAGER:UnregisterForEvent(CitizenSS.name .."NahviPortalFinished", EVENT_COMBAT_EVENT)
    EVENT_MANAGER:UnregisterForEvent(CitizenSS.name .."NahviPortalWiped", EVENT_COMBAT_EVENT)
    EVENT_MANAGER:UnregisterForEvent(CitizenSS.name .."NahviPortalInterrupt", EVENT_COMBAT_EVENT)
    EVENT_MANAGER:UnregisterForEvent(CitizenSS.name .."NahviStatueStoneFist", EVENT_COMBAT_EVENT)

    bossFlying = false
    nahvi = {
        inPortal = false,
        portalMembers = 0,
    }
end

--Portal wipe Timer
---CitizenSS.name .."PortalWipeTracker", 1000
local function PortalWipeTimer()
    local wipeTimer = nahvi.portalWipeTime - (GetGameTimeMilliseconds()/1000)

    CitizenNotifier.SetBanner2("|cff0000Portal Wipe in|r: ".. string.format("%.0f", wipeTimer) .."s")
    if wipeTimer<=0 then
        EVENT_MANAGER:UnregisterForUpdate(CitizenSS.name .."PortalWipeTracker")
        CitizenNotifier.RemoveBanner2()
    end
end
--Portal Entrance Timer
---CitizenSS.name .."PortalEntranceTracker", 200
local function PortalEntranceTimer()
    if nahvi.inPortal then
        EVENT_MANAGER:UnregisterForUpdate(CitizenSS.name .."PortalEntranceTracker")
        CitizenNotifier.RemoveBanner3()
    end
    local entranceTimer = nahvi.portalEntranceTime - (GetGameTimeMilliseconds()/1000)

    CitizenNotifier.SetBanner3("|cff007fPortal Close in|r: ".. string.format("%.1f", entranceTimer) .."s")
    if entranceTimer<=0 then
        EVENT_MANAGER:UnregisterForUpdate(CitizenSS.name .."PortalEntranceTracker")
        CitizenNotifier.RemoveBanner3()
    end
end
--Boss land tracker
---CitizenSS.name .."BossLandTrace", 200
local function BossLandCounter()
    local timeLeft = bossLandTime - (GetGameTimeMilliseconds()/1000)

    if nahvi.inPortal then
        CitizenNotifier.RemoveBanner()
        return
    end
    if timeLeft <= 0 then
        CitizenNotifier.RemoveBanner()
        bossFlying = false
        EVENT_MANAGER:UnregisterForUpdate(CitizenSS.name .."BossLandTrace")

    elseif timeLeft <= 10 then
        CitizenNotifier.SetBanner("|cffa500Landing in|r: ".. string.format("%.1f", timeLeft) .."s")
    end
end
--Boss fly tracker
---CitizenSS.name .."BossFly", 200
local function BossFlyTracker()
    if nahvi.inPortal then
        CitizenNotifier.RemoveBanner()
        return
    end

    if GetUnitName('boss1') == "Nahviintaas" then
        if hpLeftToFly < 10 then
            CitizenNotifier.SetBanner("|cffa500Fly in|r: ".. string.format("%.1f", hpLeftToFly) .."%")
        elseif hpLeftToFly < 15 then
            CitizenNotifier.SetBanner("|cff1111Portal in|r: ".. string.format("%.1f", hpLeftToFly-10) .."%")
        end
    else
        CitizenNotifier.SetBanner("|cffa500Fly in|r: ".. string.format("%.1f", hpLeftToFly) .."%")
    end

    if hpLeftToFly <= 0 then
        EVENT_MANAGER:UnregisterForUpdate(CitizenSS.name .."BossFly")
        CitizenNotifier.RemoveBanner()
    end
end
--Boss HP tracker
---CitizenSS.name .."BossHealth", 200
local function BossHpTracker()
    local current, max, _= GetUnitPower('boss1', POWERTYPE_HEALTH)
    local hp = (current/max)*100

    if hp < (bossFly[3]-5) then
        CitizenNotifier.RemoveBanner()
        EVENT_MANAGER:UnregisterForUpdate(CitizenSS.name .."BossHealth")
        EVENT_MANAGER:UnregisterForUpdate(CitizenSS.name .."BossFly")
        EVENT_MANAGER:UnregisterForUpdate(CitizenSS.name .."BossLandTrace")

    elseif hp < (bossFly[2]-5) then
        hpLeftToFly = hp-bossFly[3]

        if hpLeftToFly < 0 then
            return
        elseif hpLeftToFly<=15 and (not bossFlying) then
            bossFlying = true
            EVENT_MANAGER:RegisterForUpdate(CitizenSS.name .."BossFly", 200, BossFlyTracker)
        end

    elseif hp < (bossFly[1]-5) then
        hpLeftToFly = hp-bossFly[2]

        if hpLeftToFly < 0 then
            return
        elseif hpLeftToFly<=15 and (not bossFlying) then
            bossFlying = true
            EVENT_MANAGER:RegisterForUpdate(CitizenSS.name .."BossFly", 200, BossFlyTracker)
        end

    elseif hp < 100 then
        hpLeftToFly = hp-bossFly[1]

        if hpLeftToFly < 0 then
            return
        elseif hpLeftToFly<=15 and (not bossFlying) then
            bossFlying = true
            EVENT_MANAGER:RegisterForUpdate(CitizenSS.name .."BossFly", 200, BossFlyTracker)
        end
    end
end
---CitizenSS.name .."LokkeBeamTimer", 1000
local function LokkeBeamOSI()
    local timeLeft = lokke.tillBeam - (GetGameTimeMilliseconds()/1000)
    if timeLeft<=0 then
        CitizenNotifier.RemoveBanner2()
        EVENT_MANAGER:UnregisterForUpdate(CitizenSS.name .."LokkeBeamTimer")

    elseif timeLeft<=10 then
        if CitizenAddon.PVEcontent.SS.lokke.beamTimer then
            CitizenNotifier.SetBanner2("|cff0000Lazer Beam in|r: ".. string.format("%.0f", timeLeft) .."s")
        end
        if CitizenAddon.PVEcontent.SS.lokke.beamOsi then
            if not lokke.beamOsi then
                if CitizenAddon.PVEcontent.SS.lokke.soloHeal then
                    for _, iconInfo in pairs(CitizenSS.LokkeBeamPositionsSoloHeal) do
                        if iconInfo then
                            table.insert(lokke.beamIcons, OSI.CreatePositionIcon(iconInfo[1], iconInfo[2], iconInfo[3], CitizenMarker.iconData[iconInfo[4]], CitizenAddon.PVEcontent.SS.lokke.beamOsiIconSize, nil, nil, nil))
                        end
                    end
                else
                    for _, iconInfo in pairs(CitizenSS.LokkeBeamPositions) do
                        if iconInfo then
                            table.insert(lokke.beamIcons, OSI.CreatePositionIcon(iconInfo[1], iconInfo[2], iconInfo[3], CitizenMarker.iconData[iconInfo[4]], CitizenAddon.PVEcontent.SS.lokke.beamOsiIconSize, nil, nil, nil))
                        end
                    end
                end
                lokke.beamOsi = true
                zo_callLater(
                    function()
                        lokke.beamOsi = false
                        if lokke.beamIcons then
                            for _, IconObject in pairs(lokke.beamIcons) do
                                OSI.DiscardPositionIcon(IconObject)
                            end
                        end
                    end,
                    26000
                )
            end
        end
    end
end
--Lokke 1st fly
---CitizenSS.name .."Lokke1stFly", EVENT_COMBAT_EVENT
    --COMBAT_RESULT, ACTION_RESULT_BEGIN
    --ABILITY_ID, 122820
local function LokkeFirstFly(_, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _)
    if CitizenAddon.PVEcontent.SS.bossFlyTracker then
        bossLandTime = (GetGameTimeMilliseconds()/1000) + 52.8
        EVENT_MANAGER:RegisterForUpdate(CitizenSS.name .."BossLandTrace", 200, BossLandCounter)
    end
    if CitizenAddon.PVEcontent.SS.lokke.beamOsi or CitizenAddon.PVEcontent.SS.lokke.beamTimer then
        lokke.tillBeam = (GetGameTimeMilliseconds()/1000) + 42
        EVENT_MANAGER:RegisterForUpdate(CitizenSS.name .."LokkeBeamTimer", 1000, LokkeBeamOSI)
    end
end
--Lokke 2nd fly
---CitizenSS.name .."Lokke2ndFly", EVENT_COMBAT_EVENT
    --COMBAT_RESULT, ACTION_RESULT_BEGIN
    --ABILITY_ID, 122821
local function LokkeSecondFly(_, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _)
    if CitizenAddon.PVEcontent.SS.bossFlyTracker then
        bossLandTime = (GetGameTimeMilliseconds()/1000) + 64.6
        EVENT_MANAGER:RegisterForUpdate(CitizenSS.name .."BossLandTrace", 200, BossLandCounter)
    end
    if CitizenAddon.PVEcontent.SS.lokke.beamOsi or CitizenAddon.PVEcontent.SS.lokke.beamTimer then
        lokke.tillBeam = (GetGameTimeMilliseconds()/1000) + 12
        EVENT_MANAGER:RegisterForUpdate(CitizenSS.name .."LokkeBeamTimer", 1000, LokkeBeamOSI)
    end
end
--Lokke 3rd fly
---CitizenSS.name .."Lokke3rdFly", EVENT_COMBAT_EVENT
    --COMBAT_RESULT, ACTION_RESULT_BEGIN
    --ABILITY_ID, 122822
local function LokkeThirdFly(_, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _)
    if CitizenAddon.PVEcontent.SS.bossFlyTracker then
        bossLandTime = (GetGameTimeMilliseconds()/1000) + 64.1
        EVENT_MANAGER:RegisterForUpdate(CitizenSS.name .."BossLandTrace", 200, BossLandCounter)
    end
    if CitizenAddon.PVEcontent.SS.lokke.beamOsi or CitizenAddon.PVEcontent.SS.lokke.beamTimer then
        lokke.tillBeam = (GetGameTimeMilliseconds()/1000) + 35
        EVENT_MANAGER:RegisterForUpdate(CitizenSS.name .."LokkeBeamTimer", 1000, LokkeBeamOSI)
    end
end
--Yolna 1st fly
---CitizenSS.name .."Yolna1stFly", EVENT_COMBAT_EVENT
    --COMBAT_RESULT, ACTION_RESULT_BEGIN
    --ABILITY_ID, 124910
local function YolnaFirstFly(_, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _)
    bossLandTime = (GetGameTimeMilliseconds()/1000) + 22.6
    EVENT_MANAGER:RegisterForUpdate(CitizenSS.name .."BossLandTrace", 200, BossLandCounter)
end
--Yolna 2nd fly
---CitizenSS.name .."Yolna2ndFly", EVENT_COMBAT_EVENT
    --COMBAT_RESULT, ACTION_RESULT_BEGIN
    --ABILITY_ID, 124915
local function YolnaSecondFly(_, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _)
    bossLandTime = (GetGameTimeMilliseconds()/1000) + 23.5
    EVENT_MANAGER:RegisterForUpdate(CitizenSS.name .."BossLandTrace", 200, BossLandCounter)
end
--Yolna 3rd fly
---CitizenSS.name .."Yolna3rdFly", EVENT_COMBAT_EVENT
    --COMBAT_RESULT, ACTION_RESULT_BEGIN
    --ABILITY_ID, 124916
local function YolnaThirdFly(_, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _)
    bossLandTime = (GetGameTimeMilliseconds()/1000) + 23.7
    EVENT_MANAGER:RegisterForUpdate(CitizenSS.name .."BossLandTrace", 200, BossLandCounter)
end
--Nahvi land
---CitizenSS.name .."NahviLands", EVENT_COMBAT_EVENT
    --COMBAT_RESULT, ACTION_RESULT_BEGIN
    --ABILITY_ID, 118884
local function NahviLand(_, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _)
    bossLandTime = (GetGameTimeMilliseconds()/1000) + 20.3
    EVENT_MANAGER:RegisterForUpdate(CitizenSS.name .."BossLandTrace", 200, BossLandCounter)
end
--Nahvi portal used
---CitizenSS.name .."NahviPortalUsed", EVENT_COMBAT_EVENT
    --ABILITY_ID, 121213
local function NahviPortal(_, result, _, _, _, _, _, _, _, targetType, _, _, _, _, _, _, _, _)
    if targetType == COMBAT_UNIT_TYPE_GROUP then
        nahvi.portalMembers = nahvi.portalMembers + 1
    elseif targetType ~= COMBAT_UNIT_TYPE_PLAYER then
        return
    end
    if result==ACTION_RESULT_EFFECT_GAINED_DURATION or nahvi.portalMembers==3 then
        nahvi.inPortal = true
        if CitizenAddon.PVEcontent.SS.nahvi.portalEntranceTimer then
            EVENT_MANAGER:UnregisterForUpdate(CitizenSS.name .."PortalEntranceTracker")
        end
    end
end
--Nahvi portal ended
---CitizenSS.name .."NahviPortalFinished", EVENT_COMBAT_EVENT
    --COMBAT_RESULT, ACTION_RESULT_EFFECT_GAINED_DURATION
    --TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER
    --ABILITY_ID, 121254
---CitizenSS.name .."NahviPortalWiped", EVENT_COMBAT_EVENT
    --COMBAT_RESULT, ACTION_RESULT_EFFECT_FADED
    --ABILITY_ID, 121216
local function NahviPortalEnd(_, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _)
    nahvi.inPortal = false
    nahvi.portalMembers = 0
    if CitizenAddon.PVEcontent.SS.nahvi.portalWipeTimer then
        CitizenNotifier.RemoveBanner2()
        EVENT_MANAGER:UnregisterForUpdate(CitizenSS.name .."PortalWipeTracker")
    end
end
--Etenral servent interrupt
---CitizenSS.name .."NahviPortalInterrupt", EVENT_COMBAT_EVENT
    --COMBAT_RESULT, ACTION_RESULT_EFFECT_GAINED_DURATION
    --ABILITY_ID, 121436
local function EternalServentInterrupt(_, _, _, _, _, _, _, _, _, _, hitValue, _, _, _, _, _, abilityId, _)
    PlaySound(SOUNDS.DUEL_START)
    CombatAlerts.CastAlertsStart(abilityId, "Translation Apocalypse", hitValue, nil, nil, {1000, "Interrupt!", 1, 0, 1, 1, SOUNDS.DUEL_FORFEIT})
end
--Statue Stone Fist
---CitizenSS.name .."NahviStatueStoneFist", EVENT_COMBAT_EVENT
    --COMBAT_RESULT, ACTION_RESULT_BEGIN
    --TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER
    --ABILITY_ID, 120567
local function StatueStoneFist(_, _, _, _, _, _, _, _, _, _, hitValue, _, _, _, _, _, abilityId, _)
    CombatAlerts.CastAlertsStart(abilityId, "StoneFist", hitValue, nil, nil, nil)
end
--Nahvi portal spawned
---CitizenSS.name .."NahviPortalInterrupt", EVENT_COMBAT_EVENT
    --COMBAT_RESULT, ACTION_RESULT_BEGIN
    --ABILITY_ID, 121676
local function NahviPortalSpawned(_, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _)
    if CitizenAddon.PVEcontent.SS.nahvi.portalEntranceTimer then
        nahvi.portalEntranceTime = (GetGameTimeMilliseconds() / 1000) + 14
        EVENT_MANAGER:RegisterForUpdate(CitizenSS.name .."PortalEntranceTracker", 200, PortalEntranceTimer)
    end
    if CitizenAddon.PVEcontent.SS.nahvi.portalWipeTimer then
        nahvi.portalWipeTime = (GetGameTimeMilliseconds() / 1000) + 98
        EVENT_MANAGER:RegisterForUpdate(CitizenSS.name .."PortalWipeTracker", 1000, PortalWipeTimer)
    end
end

--Is player in combat with correct target
---CitizenAddon.name .."InCombatInSS", EVENT_PLAYER_COMBAT_STATE
function CitizenSS.CombatState(_, inCombat)
    if inCombat then
        if DoesUnitExist('boss1') then
            if GetUnitName('boss1') == "Lokkestiiz" then --80 50 20
                if CitizenAddon.PVEcontent.SS.bossFlyTracker then
                    bossFly[1] = 81
                    bossFly[2] = 51
                    bossFly[3] = 21
                    EVENT_MANAGER:RegisterForUpdate(CitizenSS.name .."BossHealth", 200, BossHpTracker)
                end
                if CitizenAddon.PVEcontent.SS.bossFlyTracker or CitizenAddon.PVEcontent.SS.lokke.beamOsi or CitizenAddon.PVEcontent.SS.lokke.beamTimer then
                    EVENT_MANAGER:RegisterForEvent(CitizenSS.name .."Lokke1stFly", EVENT_COMBAT_EVENT, LokkeFirstFly)--FILTERS --Lokke 1st fly
                        EVENT_MANAGER:AddFilterForEvent(CitizenSS.name .."Lokke1stFly", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_BEGIN)
                        EVENT_MANAGER:AddFilterForEvent(CitizenSS.name .."Lokke1stFly", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 122820)
                    --
                    EVENT_MANAGER:RegisterForEvent(CitizenSS.name .."Lokke2ndFly", EVENT_COMBAT_EVENT, LokkeSecondFly)--FILTERS --Lokke 2nd fly
                        EVENT_MANAGER:AddFilterForEvent(CitizenSS.name .."Lokke2ndFly", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_BEGIN)
                        EVENT_MANAGER:AddFilterForEvent(CitizenSS.name .."Lokke2ndFly", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 122821)
                    --
                    EVENT_MANAGER:RegisterForEvent(CitizenSS.name .."Lokke3rdFly", EVENT_COMBAT_EVENT, LokkeThirdFly)--FILTERS --Lokke 3rd fly
                        EVENT_MANAGER:AddFilterForEvent(CitizenSS.name .."Lokke3rdFly", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_BEGIN)
                        EVENT_MANAGER:AddFilterForEvent(CitizenSS.name .."Lokke3rdFly", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 122822)
                    --
                end
            elseif GetUnitName('boss1') == "Yolnahkriin" then --75 50 25
                if CitizenAddon.PVEcontent.SS.bossFlyTracker then
                    bossFly[1] = 76
                    bossFly[2] = 51
                    bossFly[3] = 26
                    EVENT_MANAGER:RegisterForUpdate(CitizenSS.name .."BossHealth", 200, BossHpTracker)
                    EVENT_MANAGER:RegisterForEvent(CitizenSS.name .."Yolna1stFly", EVENT_COMBAT_EVENT, YolnaFirstFly)--FILTERS --Yolna 1st fly
                        EVENT_MANAGER:AddFilterForEvent(CitizenSS.name .."Yolna1stFly", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_BEGIN)
                        EVENT_MANAGER:AddFilterForEvent(CitizenSS.name .."Yolna1stFly", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 124910)
                    --
                    EVENT_MANAGER:RegisterForEvent(CitizenSS.name .."Yolna2ndFly", EVENT_COMBAT_EVENT, YolnaSecondFly)--FILTERS --Yolna 2nd fly
                        EVENT_MANAGER:AddFilterForEvent(CitizenSS.name .."Yolna2ndFly", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_BEGIN)
                        EVENT_MANAGER:AddFilterForEvent(CitizenSS.name .."Yolna2ndFly", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 124915)
                    --
                    EVENT_MANAGER:RegisterForEvent(CitizenSS.name .."Yolna3rdFly", EVENT_COMBAT_EVENT, YolnaThirdFly)--FILTERS --Yolna 3rd fly
                        EVENT_MANAGER:AddFilterForEvent(CitizenSS.name .."Yolna3rdFly", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_BEGIN)
                        EVENT_MANAGER:AddFilterForEvent(CitizenSS.name .."Yolna3rdFly", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 124916)
                    --
                end
            elseif GetUnitName('boss1') == "Nahviintaas" then --80 60 40
                if CitizenAddon.PVEcontent.SS.bossFlyTracker then
                    bossFly[1] = 81
                    bossFly[2] = 61
                    bossFly[3] = 41
                    EVENT_MANAGER:RegisterForUpdate(CitizenSS.name .."BossHealth", 200, BossHpTracker)
                    EVENT_MANAGER:RegisterForEvent(CitizenSS.name .."NahviLands", EVENT_COMBAT_EVENT, NahviLand)--FILTERS --Nahvi land
                        EVENT_MANAGER:AddFilterForEvent(CitizenSS.name .."NahviLands", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_BEGIN)
                        EVENT_MANAGER:AddFilterForEvent(CitizenSS.name .."NahviLands", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 118884)
                    --
                end
                if CitizenAddon.PVEcontent.SS.nahvi.portalEntranceTimer or CitizenAddon.PVEcontent.SS.nahvi.portalWipeTimer then
                    EVENT_MANAGER:RegisterForEvent(CitizenSS.name .."NahviPortalOpened", EVENT_COMBAT_EVENT, NahviPortalSpawned)--FILTERS --Nahvi land
                        EVENT_MANAGER:AddFilterForEvent(CitizenSS.name .."NahviPortalOpened", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_BEGIN)
                        EVENT_MANAGER:AddFilterForEvent(CitizenSS.name .."NahviPortalOpened", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 121676)
                    --
                end
                if CitizenAddon.PVEcontent.SS.bossFlyTracker or CitizenAddon.PVEcontent.SS.nahvi.portalEntranceTimer or CitizenAddon.PVEcontent.SS.nahvi.portalWipeTimer then
                    EVENT_MANAGER:RegisterForEvent(CitizenSS.name .."NahviPortalUsed", EVENT_COMBAT_EVENT, NahviPortal)--FILTERS --Nahvi land
                        EVENT_MANAGER:AddFilterForEvent(CitizenSS.name .."NahviPortalUsed", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 121213)
                    --
                    EVENT_MANAGER:RegisterForEvent(CitizenSS.name .."NahviPortalFinished", EVENT_COMBAT_EVENT, NahviPortalEnd)--FILTERS --Nahvi land
                        EVENT_MANAGER:AddFilterForEvent(CitizenSS.name .."NahviPortalFinished", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_EFFECT_GAINED_DURATION)
                        EVENT_MANAGER:AddFilterForEvent(CitizenSS.name .."NahviPortalFinished", EVENT_COMBAT_EVENT, REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
                        EVENT_MANAGER:AddFilterForEvent(CitizenSS.name .."NahviPortalFinished", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 121254)
                    --
                    EVENT_MANAGER:RegisterForEvent(CitizenSS.name .."NahviPortalWiped", EVENT_COMBAT_EVENT, NahviPortalEnd)--FILTERS --Nahvi land
                        EVENT_MANAGER:AddFilterForEvent(CitizenSS.name .."NahviPortalWiped", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_EFFECT_FADED)
                        EVENT_MANAGER:AddFilterForEvent(CitizenSS.name .."NahviPortalWiped", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 121216)
                    --
                end
                if CitizenAddon.PVEcontent.SS.nahvi.portalInterrupt then
                    EVENT_MANAGER:RegisterForEvent(CitizenSS.name .."NahviPortalInterrupt", EVENT_COMBAT_EVENT, EternalServentInterrupt)--FILTERS --Nahvi land
                        EVENT_MANAGER:AddFilterForEvent(CitizenSS.name .."NahviPortalInterrupt", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_EFFECT_GAINED_DURATION)
                        EVENT_MANAGER:AddFilterForEvent(CitizenSS.name .."NahviPortalInterrupt", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 121436)
                    --
                end
                if CitizenAddon.PVEcontent.SS.nahvi.statueStoneFist then
                    EVENT_MANAGER:RegisterForEvent(CitizenSS.name .."NahviStatueStoneFist", EVENT_COMBAT_EVENT, StatueStoneFist)--FILTERS --Nahvi land
                        EVENT_MANAGER:AddFilterForEvent(CitizenSS.name .."NahviStatueStoneFist", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_BEGIN)
                        EVENT_MANAGER:AddFilterForEvent(CitizenSS.name .."NahviStatueStoneFist", EVENT_COMBAT_EVENT, REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
                        EVENT_MANAGER:AddFilterForEvent(CitizenSS.name .."NahviStatueStoneFist", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 120567)
                    --
                end
            end
        end
    else
        Unregistor()
    end
end

------------------------------
--Lokke Beam phase positions--
------------------------------
CitizenSS.LokkeBeamPositions = {
    [1] = {
        [1] = 115110,
        [2] = 56100,
        [3] = 107060,
        [4] = 40,
    },
    [2] = {
        [1] = 114320,
        [2] = 56100,
        [3] = 107060,
        [4] = 41,
    },
    [3] = {
        [1] = 114320,
        [2] = 56100,
        [3] = 106390,
        [4] = 42,
    },
    [4] = {
        [1] = 115110,
        [2] = 56100,
        [3] = 106390,
        [4] = 43,
    },
    [5] = {
        [1] = 115110,
        [2] = 56100,
        [3] = 105760,
        [4] = 108,
    },
    [6] = {
        [1] = 114320,
        [2] = 56100,
        [3] = 105760,
        [4] = 109,
    },
    [7] = {
        [1] = 114320,
        [2] = 56100,
        [3] = 105090,
        [4] = 110,
    },
    [8] = {
        [1] = 115110,
        [2] = 56100,
        [3] = 105090,
        [4] = 111,
    },
    [9] = {
        [1] = 115500,
        [2] = 56100,
        [3] = 106725,
        [4] = 84,
    },
    [10] = {
        [1] = 115500,
        [2] = 56100,
        [3] = 105425,
        [4] = 85,
    },
}
CitizenSS.LokkeBeamPositionsSoloHeal = {
    [1] = {
        [1] = 113880,
        [2] = 56100,
        [3] = 106880,
        [4] = 40,
    },
    [2] = {
        [1] = 114080,
        [2] = 56100,
        [3] = 106360,
        [4] = 41,
    },
    [3] = {
        [1] = 114080,
        [2] = 56100,
        [3] = 105640,
        [4] = 42,
    },
    [4] = {
        [1] = 113880,
        [2] = 56100,
        [3] = 105120,
        [4] = 43,
    },
    [5] = {
        [1] = 114480,
        [2] = 56100,
        [3] = 107200,
        [4] = 108,
    },
    [6] = {
        [1] = 114650,
        [2] = 56100,
        [3] = 106570,
        [4] = 109,
    },
    [7] = {
        [1] = 114650,
        [2] = 56100,
        [3] = 105460,
        [4] = 110,
    },
    [8] = {
        [1] = 114480,
        [2] = 56100,
        [3] = 104880,
        [4] = 111,
    },
    [9] = {
        [1] = 114730,
        [2] = 56100,
        [3] = 106050,
        [4] = 112,
    },
    [10] = {
        [1] = 116400,
        [2] = 56100,
        [3] = 106050,
        [4] = 22,
    },
}