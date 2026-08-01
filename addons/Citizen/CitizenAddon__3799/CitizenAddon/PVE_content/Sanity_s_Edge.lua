CitizenSE = {
    name = "CitizenSE",
}
local ansuul = {
    banishTime = 0,
}

--Unregistor
local function Unregistor()
    CitizenNotifier.RemoveAllBanners()
    EVENT_MANAGER:UnregisterForEvent(CitizenSE.name .."TrueShot", EVENT_COMBAT_EVENT)
    EVENT_MANAGER:UnregisterForUpdate(CitizenSE.name .."AnsuulHp")
    EVENT_MANAGER:UnregisterForEvent(CitizenSE.name .."ExecuteBanish", EVENT_COMBAT_EVENT)
    EVENT_MANAGER:UnregisterForUpdate(CitizenSE.name .."ExecuteBanishTimer")
end
local function MechanicIconRemover()
    if CitizenMarker.mechanicIcons then
        for _, IconObject in pairs(CitizenMarker.mechanicIcons) do
            OSI.DiscardPositionIcon(IconObject)
        end
    end
end


--Execute banish timer
---CitizenSE.name .."ExecuteBanishTimer", 1000
local function ExeBanishTimer()
    local timer = ansuul.banishTime - (GetGameTimeMilliseconds() / 1000)

    if timer > 0 then
        CitizenNotifier.SetBanner("|cb042ffBanish in|r: ".. string.format("%.0f", timer) .."s")
    else
        CitizenNotifier.RemoveBanner()
        EVENT_MANAGER:UnregisterForUpdate(CitizenSE.name .."ExecuteBanishTimer")
    end
end

--If boss casted Banish in execute
---CitizenSE.name .."ExecuteBanish", EVENT_COMBAT_EVENT
    --COMBAT_RESULT, ACTION_RESULT_BEGIN
    --ABILITY_ID, 185117
local function ExeBanish(_, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _)
    ansuul.banishTime = (GetGameTimeMilliseconds() / 1000) + 23

    EVENT_MANAGER:RegisterForUpdate(CitizenSE.name .."ExecuteBanishTimer", 1000, ExeBanishTimer)
end


--Boss HP tracker
---CitizenSE.name .."AnsuulHp", 200
local function AnsuulHealth()
    if DoesUnitExist('boss1') then
        if GetUnitName('boss1') == "Ansuul the Tormentor" then
            local current, max, _= GetUnitPower('boss1', POWERTYPE_HEALTH)
            local hp = (current/max)*100
            local hpLeft = 0

            if hp >= 91 then
                hpLeft = hp-91
                if hpLeft<=5 and hpLeft>0 then
                    CitizenNotifier.SetBanner("|cb042ffBanish in|r: ".. string.format("%.1f", hpLeft) .."%")
                else
                    CitizenNotifier.RemoveBanner()
                end

            elseif hp<91 and hp>=71 then
                hpLeft = hp-71
                if hpLeft<=5 and hpLeft>0 then
                    CitizenNotifier.SetBanner("|cb042ffBanish in|r: ".. string.format("%.1f", hpLeft) .."%")
                else
                    CitizenNotifier.RemoveBanner()
                end

            elseif hp<71 and hp>=51 then
                hpLeft = hp-51
                if hpLeft<=5 and hpLeft>0 then
                    CitizenNotifier.SetBanner("|cb042ffBanish in|r: ".. string.format("%.1f", hpLeft) .."%")
                else
                    CitizenNotifier.RemoveBanner()
                end

            elseif hp<51 and hp>=31 then
                hpLeft = hp-31
                if hpLeft<=5 and hpLeft>0 then
                    CitizenNotifier.SetBanner("|cb042ffBanish in|r: ".. string.format("%.1f", hpLeft) .."%")
                else
                    CitizenNotifier.RemoveBanner()
                end

            elseif hp<31 and hp>22 then
                CitizenNotifier.RemoveBanner()

            elseif hp <= 22 then
                EVENT_MANAGER:RegisterForEvent(CitizenSE.name .."ExecuteBanish", EVENT_COMBAT_EVENT, ExeBanish)--FILTERS
                    EVENT_MANAGER:AddFilterForEvent(CitizenSE.name .."ExecuteBanish", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_BEGIN)
                    EVENT_MANAGER:AddFilterForEvent(CitizenSE.name .."ExecuteBanish", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 185117)
                --
                EVENT_MANAGER:UnregisterForUpdate(CitizenSE.name .."AnsuulHp")
            end
        end
    end
end

--Archers true shot
local function TrueshotTracker(_, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _)
    CitizenNotifier.Alert("|cfa9c1bTrueShot|r", 1500, SOUNDS.DUEL_START)
end

--Chimera crystal numbers OSI
local function ChimeraCrystalNumbersOSI()
    local _, maxBosstHP, _ = GetUnitPower('boss1', POWERTYPE_HEALTH)
    if maxBosstHP > 80000000 then
        for _, iconInfo in pairs(CitizenSE.ChimeraCrystalNumbersOsiListHM) do
            if iconInfo then
                table.insert(CitizenMarker.mechanicIcons, OSI.CreatePositionIcon(iconInfo[1], iconInfo[2], iconInfo[3], CitizenMarker.iconData[iconInfo[4]], iconInfo[5], nil, nil, nil))
            end
        end
    else
        for _, iconInfo in pairs(CitizenSE.ChimeraCrystalNumbersOsiListNonHM) do
            if iconInfo then
                table.insert(CitizenMarker.mechanicIcons, OSI.CreatePositionIcon(iconInfo[1], iconInfo[2], iconInfo[3], CitizenMarker.iconData[iconInfo[4]], iconInfo[5], nil, nil, nil))
            end
        end
    end
end

--Is player in combat with correct target
---CitizenAddon.name .."InCombatInSE", EVENT_PLAYER_COMBAT_STATE
function CitizenSE.CombatState(_, inCombat)
    if inCombat then
        if DoesUnitExist('boss1') then
            if GetUnitName('boss1') == "Exarchanic Yaseyla" then
                if CitizenAddon.PVEcontent.SE.yaseyla.archerTrueShot then
                    EVENT_MANAGER:RegisterForEvent(CitizenSE.name .."TrueShot", EVENT_COMBAT_EVENT, TrueshotTracker)--FILTERS
                        EVENT_MANAGER:AddFilterForEvent(CitizenSE.name .."TrueShot", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_BEGIN)
                        EVENT_MANAGER:AddFilterForEvent(CitizenSE.name .."TrueShot", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 184802)
                    --
                end
            elseif GetUnitName('boss1') == "Ansuul the Tormentor" then
                if CitizenAddon.PVEcontent.SE.ansuul.banishTracker then
                    EVENT_MANAGER:RegisterForUpdate(CitizenSE.name .."AnsuulHp", 200, AnsuulHealth) --90% 70% 50% 30% > 20s
                end
            end
        end
    else
        Unregistor()
    end
end

--Boss changed
---CitizenAddon.name .."BossChangedInSE", EVENT_BOSSES_CHANGED
function CitizenSE.BossChanged(_, _)
    MechanicIconRemover()

    if GetUnitName('boss1')=="Archwizard Twelvane" or GetUnitName('boss1')=="Chimera" then
        if CitizenAddon.PVEcontent.SE.archAndChimera.crystalNumbersOSI then
            ChimeraCrystalNumbersOSI()
        end
    end
end

CitizenDSR.ChimeraCrystalNumbersOsiListHM = {
    [1] = {
        [4] = 1,
        [1] = 171984,
        [2] = 40350,
        [3] = 238116,
        [5] = CitizenAddon.PVEcontent.SE.archAndChimera.crystalNumbersOsiIconSize,
    },
    [2] = {
        [4] = 1,
        [1] = 181899,
        [2] = 40350,
        [3] = 238230,
        [5] = CitizenAddon.PVEcontent.SE.archAndChimera.crystalNumbersOsiIconSize,
    },
    [3] = {
        [4] = 1,
        [1] = 171984,
        [2] = 40350,
        [3] = 238116,
        [5] = CitizenAddon.PVEcontent.SE.archAndChimera.crystalNumbersOsiIconSize,
    },
    [4] = {
        [4] = 2,
        [1] = 172026,
        [2] = 40350,
        [3] = 242013,
        [5] = CitizenAddon.PVEcontent.SE.archAndChimera.crystalNumbersOsiIconSize,
    },
    [5] = {
        [4] = 2,
        [1] = 181903,
        [2] = 40350,
        [3] = 242085,
        [5] = CitizenAddon.PVEcontent.SE.archAndChimera.crystalNumbersOsiIconSize,
    },
    [6] = {
        [4] = 2,
        [1] = 191874,
        [2] = 40350,
        [3] = 242064,
        [5] = CitizenAddon.PVEcontent.SE.archAndChimera.crystalNumbersOsiIconSize,
    },
    [7] = {
        [4] = 3,
        [1] = 170048,
        [2] = 40350,
        [3] = 242200,
        [5] = CitizenAddon.PVEcontent.SE.archAndChimera.crystalNumbersOsiIconSize,
    },
    [8] = {
        [4] = 3,
        [1] = 179948,
        [2] = 40350,
        [3] = 242203,
        [5] = CitizenAddon.PVEcontent.SE.archAndChimera.crystalNumbersOsiIconSize,
    },
    [9] = {
        [4] = 3,
        [1] = 189859,
        [2] = 40350,
        [3] = 242154,
        [5] = CitizenAddon.PVEcontent.SE.archAndChimera.crystalNumbersOsiIconSize,
    },
    [10] = {
        [4] = 4,
        [1] = 168148,
        [2] = 40350,
        [3] = 242050,
        [5] = CitizenAddon.PVEcontent.SE.archAndChimera.crystalNumbersOsiIconSize,
    },
    [11] = {
        [4] = 4,
        [1] = 178072,
        [2] = 40350,
        [3] = 242011,
        [5] = CitizenAddon.PVEcontent.SE.archAndChimera.crystalNumbersOsiIconSize,
    },
    [12] = {
        [4] = 4,
        [1] = 187935,
        [2] = 40350,
        [3] = 242088,
        [5] = CitizenAddon.PVEcontent.SE.archAndChimera.crystalNumbersOsiIconSize,
    },
    [13] = {
        [4] = 5,
        [1] = 168147,
        [2] = 40350,
        [3] = 238168,
        [5] = CitizenAddon.PVEcontent.SE.archAndChimera.crystalNumbersOsiIconSize,
    },
    [14] = {
        [4] = 5,
        [1] = 178065,
        [2] = 40350,
        [3] = 238175,
        [5] = CitizenAddon.PVEcontent.SE.archAndChimera.crystalNumbersOsiIconSize,
    },
    [15] = {
        [4] = 5,
        [1] = 187954,
        [2] = 40350,
        [3] = 238224,
        [5] = CitizenAddon.PVEcontent.SE.archAndChimera.crystalNumbersOsiIconSize,
    },
}

CitizenDSR.ChimeraCrystalNumbersOsiListNonHM = {
    [1] = {
        [4] = 1,
        [1] = 189899,
        [2] = 40350,
        [3] = 237901,
        [5] = CitizenAddon.PVEcontent.SE.archAndChimera.crystalNumbersOsiIconSize,
    },
    [2] = {
        [4] = 1,
        [1] = 180032,
        [2] = 40350,
        [3] = 237903,
        [5] = CitizenAddon.PVEcontent.SE.archAndChimera.crystalNumbersOsiIconSize,
    },
    [3] = {
        [4] = 1,
        [1] = 170064,
        [2] = 40350,
        [3] = 237906,
        [5] = CitizenAddon.PVEcontent.SE.archAndChimera.crystalNumbersOsiIconSize,
    },
    [4] = {
        [4] = 2,
        [1] = 192097,
        [2] = 40350,
        [3] = 240155,
        [5] = CitizenAddon.PVEcontent.SE.archAndChimera.crystalNumbersOsiIconSize,
    },
    [5] = {
        [4] = 2,
        [1] = 172287,
        [2] = 40350,
        [3] = 240129,
        [5] = CitizenAddon.PVEcontent.SE.archAndChimera.crystalNumbersOsiIconSize,
    },
    [6] = {
        [4] = 2,
        [1] = 182226,
        [2] = 40350,
        [3] = 240121,
        [5] = CitizenAddon.PVEcontent.SE.archAndChimera.crystalNumbersOsiIconSize,
    },
    [7] = {
        [4] = 3,
        [1] = 170048,
        [2] = 40350,
        [3] = 242200,
        [5] = CitizenAddon.PVEcontent.SE.archAndChimera.crystalNumbersOsiIconSize,
    },
    [8] = {
        [4] = 3,
        [1] = 179948,
        [2] = 40350,
        [3] = 242203,
        [5] = CitizenAddon.PVEcontent.SE.archAndChimera.crystalNumbersOsiIconSize,
    },
    [9] = {
        [4] = 3,
        [1] = 189859,
        [2] = 40350,
        [3] = 242154,
        [5] = CitizenAddon.PVEcontent.SE.archAndChimera.crystalNumbersOsiIconSize,
    },
    [10] = {
        [4] = 4,
        [1] = 187675,
        [2] = 40350,
        [3] = 240085,
        [5] = CitizenAddon.PVEcontent.SE.archAndChimera.crystalNumbersOsiIconSize,
    },
    [11] = {
        [4] = 4,
        [1] = 167838,
        [2] = 40350,
        [3] = 240080,
        [5] = CitizenAddon.PVEcontent.SE.archAndChimera.crystalNumbersOsiIconSize,
    },
    [12] = {
        [4] = 4,
        [1] = 177789,
        [2] = 40350,
        [3] = 240095,
        [5] = CitizenAddon.PVEcontent.SE.archAndChimera.crystalNumbersOsiIconSize,
    },
}