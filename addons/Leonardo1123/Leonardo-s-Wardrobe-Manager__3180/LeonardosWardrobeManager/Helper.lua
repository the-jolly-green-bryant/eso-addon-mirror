local LWM = LeonardosWardrobeManager

local NO_OUTFIT             = 0
local OUTFIT_DEFAULT        = -1
local ALLIANCE_DEFAULT      = -2

function LWM.GetAbilityName(rawSlot, bar)
    bar = bar or HOTBAR_CATEGORY_PRIMARY
    local slot = rawSlot + 2

    local id = GetSlotBoundId(slot, bar)
    local name = GetAbilityName(id)

    return name
end

function LWM.CheckForNoDuration(slot, bar)
    bar = bar or HOTBAR_CATEGORY_PRIMARY
    slot = slot + 2

    local id = GetSlotBoundId(slot, bar)
    local duration = GetAbilityDuration(id)

    return duration == 0
end

function LWM.SetStateOutfitChoice(state, index)
    if state == "default" then
        LWM.ChangeOutfit(index)
    end

    LWM.vars.outfitIndices[state] = index
end

function LWM.ChangeOutfit(index)
    if index == NO_OUTFIT then
        UnequipOutfit()
    elseif index == OUTFIT_DEFAULT then
        EquipOutfit(GAMEPLAY_ACTOR_CATEGORY_PLAYER, LWM.vars.outfitIndices.default)
    else
        EquipOutfit(GAMEPLAY_ACTOR_CATEGORY_PLAYER, index)
    end
end

function LWM.ChangeToStateOutfit()
    if LWM.inCombat then
        if LWM.vars.settings.perBarToggle then
            local weaponPair, _ = GetActiveWeaponPairInfo()
            local mainBar = (weaponPair == 1)

            if mainBar then
                LWM.ChangeOutfit(LWM.vars.outfitIndices.mainbar)
            else
                LWM.ChangeOutfit(LWM.vars.outfitIndices.backbar)
            end
        else
            LWM.ChangeOutfit(LWM.vars.outfitIndices.combat)
        end
    elseif LWM.inStealth > 0 then
        LWM.ChangeOutfit(LWM.vars.outfitIndices.stealth)
    else
        LWM.ChangeToLocationOutfit()
    end
end

function LWM.ChangeToZoneOutfit()
    local allZoneIds = LWM.GetAllZoneIds()

    local zoneId = GetZoneId(GetUnitZoneIndex("player"))
    if zoneId ~= GetParentZoneId(zoneId) then
        zoneId = GetParentZoneId(zoneId)
    end

    local zone = allZoneIds[zoneId]
    local outfit = zone.outfit

    if outfit >= 0 then
        LWM.ChangeOutfit(outfit)
    elseif outfit == OUTFIT_DEFAULT then
        LWM.ChangeOutfit(LWM.vars.outfitIndices.default)
    elseif outfit == ALLIANCE_DEFAULT then
        if alliance=="dominion" then
            LWM.ChangeOutfit(LWM.vars.outfitIndices.dominion)
        elseif alliance=="covenant" then
            LWM.ChangeOutfit(LWM.vars.outfitIndices.covenant)
        elseif alliance=="pact" then
            LWM.ChangeOutfit(LWM.vars.outfitIndices.pact)
        end
    end
end

function LWM.ChangeToLocationOutfit()
    if GetCurrentZoneHouseId() ~= 0 then
        LWM.ChangeOutfit(LWM.vars.outfitIndices.house)
    elseif IsActiveWorldBattleground() then
        LWM.ChangeOutfit(LWM.vars.outfitIndices.battleground)
    elseif IsPlayerInAvAWorld() then
        if IsInCyrodiil() then
            LWM.ChangeOutfit(LWM.vars.outfitIndices.cyrodil)
        elseif IsInImperialCity() then
            if GetCurrentMapIndex() then
                LWM.ChangeOutfit(LWM.vars.outfitIndices.imperial)
            else
                LWM.ChangeOutfit(LWM.vars.outfitIndices.sewers)
            end
        else
            LWM.ChangeOutfit(LWM.vars.outfitIndices.cyrodil_d)
        end
    elseif IsUnitInDungeon("player") then
        LWM.ChangeOutfit(LWM.vars.outfitIndices.dungeon)
    else
        LWM.ChangeToZoneOutfit()
    end
end

function LWM.RenameUnnamedOutfits()
    for i=1,GetNumUnlockedOutfits() do
        local name = GetOutfitName(GAMEPLAY_ACTOR_CATEGORY_PLAYER, i)
        if name == "" then
            name = "Outfit " .. tostring(i)

            LWM.allOutfits[i + OUTFIT_OFFSET] = name
            LWM.allOutfitChoices[i + OUTFIT_OFFSET] = i
            LWM.allAlliedOutfits[i + 2*OUTFIT_OFFSET] = name
            LWM.allAlliedOutfitChoices[i + 2*OUTFIT_OFFSET] = i
            RenameOutfit(GAMEPLAY_ACTOR_CATEGORY_PLAYER, i, name)
        end
    end
end

function LWM.CheckState()
    local inCombat = IsUnitInCombat("player")
    local inStealth = GetUnitStealthState("player")

    if inCombat ~= LWM.inCombat then LWM.inCombat = inCombat end
    if inStealth ~= LWM.inStealth then LWM.inStealth = inStealth end
end

function LWM.GetAllZoneIds()
    return {
        [3]     = {outfit=LWM.vars.outfitIndices.glenumbra,     alliance="covenant"},
        [19]    = {outfit=LWM.vars.outfitIndices.stormhaven,    alliance="covenant"},
        [20]    = {outfit=LWM.vars.outfitIndices.rivenspire,    alliance="covenant"},
        [92]    = {outfit=LWM.vars.outfitIndices.bangkorai,     alliance="covenant"},
        [104]   = {outfit=LWM.vars.outfitIndices.alikr,         alliance="covenant"},
        [534]   = {outfit=LWM.vars.outfitIndices.stros,         alliance="covenant"},
        [535]   = {outfit=LWM.vars.outfitIndices.betnikh,       alliance="covenant"},

        [58]    = {outfit=LWM.vars.outfitIndices.malabal,       alliance="dominion"},
        [108]   = {outfit=LWM.vars.outfitIndices.greenshade,    alliance="dominion"},
        [381]   = {outfit=LWM.vars.outfitIndices.auridon,       alliance="dominion"},
        [382]   = {outfit=LWM.vars.outfitIndices.reapers,       alliance="dominion"},
        [383]   = {outfit=LWM.vars.outfitIndices.grahtwood,     alliance="dominion"},
        [537]   = {outfit=LWM.vars.outfitIndices.khenarthi,     alliance="dominion"},

        [41]    = {outfit=LWM.vars.outfitIndices.stonefalls,    alliance="pact"},
        [57]    = {outfit=LWM.vars.outfitIndices.deshaan,       alliance="pact"},
        [101]   = {outfit=LWM.vars.outfitIndices.eastmarch,     alliance="pact"},
        [103]   = {outfit=LWM.vars.outfitIndices.rift,          alliance="pact"},
        [117]   = {outfit=LWM.vars.outfitIndices.shadowfen,     alliance="pact"},
        [280]   = {outfit=LWM.vars.outfitIndices.bleakrock,     alliance="pact"},
        [281]   = {outfit=LWM.vars.outfitIndices.bal,           alliance="pact"},

        [347]   = {outfit=LWM.vars.outfitIndices.coldharbour},
        [684]   = {outfit=LWM.vars.outfitIndices.wrothgar},
        [726]   = {outfit=LWM.vars.outfitIndices.murkmire},
        [816]   = {outfit=LWM.vars.outfitIndices.hew},
        [823]   = {outfit=LWM.vars.outfitIndices.gold},
        [849]   = {outfit=LWM.vars.outfitIndices.vvardenfell},
        [888]   = {outfit=LWM.vars.outfitIndices.craglorn},
        [980]   = {outfit=LWM.vars.outfitIndices.clockwork},
        [1011]  = {outfit=LWM.vars.outfitIndices.summerset},
        [1086]  = {outfit=LWM.vars.outfitIndices.nelsweyr},
        [1133]  = {outfit=LWM.vars.outfitIndices.selsweyr},
        [1160]  = {outfit=LWM.vars.outfitIndices.skyrim},
        [1161]  = {outfit=LWM.vars.outfitIndices.greymoor},
        [1207]  = {outfit=LWM.vars.outfitIndices.reach},
        [1208]  = {outfit=LWM.vars.outfitIndices.arkthzand},
        [1261]  = {outfit=LWM.vars.outfitIndices.blackwood},
    }
end