
TauntHelper.combatEventsToClearTauntFromList = {
    -- abilityId, debug, name of mob to put in mech mode, second name if applicable
    --[20930] =  {true, "Target Skeleton, Humanoid"}, -- Testing removing taunt with Engulfing Flames

    -- Sunspire Lokkestiiz fly (they show up)
    [122820] = {false, "Lokkestiiz"}, -- SS Gravechill (first take off)
    [122821] = {false, "Lokkestiiz"}, -- SS Gravechill (second take off)
    [122822] = {false, "Lokkestiiz"}, -- SS Gravechill (third take off)

    [125693] = {false, "Yolnahkriin"}, -- SS Turn off aim (Yolnahkriin)

    -- Sunspire Nahviintaas fly add Spawning
    [120825] = {false, "Nahviintaas"}, -- SS Spawn In (Alkosh's Fate/Alkosh's Will any add phase including portal adds)

    [158658] = {false, "Sarydil"}, -- CA Sarydil - when she ports away ACTION_RESULT_EFFECT_GAINED

    [166909] = {false, "Lylanar"}, -- DSR Lylanar MultiLoc (ID: 166909)
    [166745] = {false, "Turlassil"}, -- DSR Turlassil MultiLoc (ID: 166745)

    -- 163692 -- DSR Heartburn Reef Guardian cast (but we won't know which Reef Guardian to remove from taunt list)

    [158565] = {false, "Maligalig"}, -- CA Maligalig - Voracious Whirlpool
    [57764] =  {false, "Lord Warden Dusk"}, -- ICP Shadow Rift - split into 4 shades

    [182437] = {false, "Lamikhai"}, -- SH Incinerate

    [99869] = {false, "Zaan the Scalecaller"}, -- SCP Winter's Purge

    [167906] = {false, "Captain Numirril"}, -- SWR - Jet
    [163638] = {false, "Foreman Bradiggan"}, -- SWR - Posession

    [155573] = {false, "Magma Incarnate"}, -- DC Magma Incarnate - Symbols 65
    [155574] = {false, "Magma Incarnate"}, -- DC Magma Incarnate - Symbols 35

    [137722] = {false, "Lady Thorn"}, -- CT Lady Thorn - Batdance

    [178075] = {false, "Kovan Giryon"}, -- BS - Recall (first and second phase)
    [181550] = {false, "Kovan Giryon"}, -- BS - Recall (third phase)

    [133786] = {false, "Arkasis the Mad Alchemist"}, -- SG - Smoke Bomb @ 60% & 20%

    [135980] = {false, "Lord Falgravn"}, -- KA Lord Falgravn - Vampire Knights spawn moving to 2nd floor

    [204738] = {false, "Darkshard"}, -- BV Darkshard first boss - port away

    [207422] = {false, "The Blind"}, -- BV The Blind - Final Phase

    [113293] = {false, "Symphony of Blades"}, -- DoM Symphony of Blades - Portal Start

    -- TODO: HoF last boss - immune in middle
    [95135]  = {true, "Assembly General"}, -- HoF Charge to Center

}


-- TODO: SH - valinna despawn in second room SH (cannot find event for this?)
-- TODO: LoM - lurcher boss in vLOM goes immune (could not figure this out)
-- TODO: LoM - maarselok with horvers flies away in LoM (could not figure this out)




TauntHelper.effectChangedToClearTauntFromList = {
    [111729] = {false, "SELF"}, -- Cower - MHK - Cower buff on Ary or Zel

}








function TauntHelper.removeMobDueToMechanicByName(name)
    -- find any mobs with the specified name and mark it as doing mechanic
    for k,v in pairs(TauntHelper.tauntList) do
        if v[TauntHelper.TAUNT_LIST_NAME] == name then
            TauntHelper.removeMobDueToMechanic(k)
        end
    end
end


function TauntHelper.removeMobDueToMechanic(unitId)
    if TauntHelper.tauntList[unitId] ~= nil then
        TauntHelper.tauntList[unitId][TauntHelper.TAUNT_LIST_ENDTIME] = 0 -- set taunt well in the past so it doesn't appear on taunt bars
        TauntHelper.tauntList[unitId][TauntHelper.TAUNT_LIST_LASTSEENTIME] = 0 -- set last seen well into the past
        TauntHelper.tauntList[unitId][TauntHelper.TAUNT_LIST_IHAVETAUNT] = false
        TauntHelper.tauntList[unitId][TauntHelper.TAUNT_LIST_STOLENTAUNTTIME] = 0
        TauntHelper.tauntList[unitId][TauntHelper.TAUNT_LIST_LASTTIMEWASMINE] = false
        TauntHelper.tauntList[unitId][TauntHelper.TAUNT_LIST_LASTTAUNTLOSTTIME] = 0
        TauntHelper.tauntList[unitId][TauntHelper.TAUNT_LIST_IGNOREUNTILTIME] = GetGameTimeMilliseconds() + 5000 -- ignore for 5 seconds incase there's some lingering casts
	end
end

