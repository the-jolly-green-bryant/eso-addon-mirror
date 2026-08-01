OpulentOrdealNavigator = OpulentOrdealNavigator or {}

local OON = OpulentOrdealNavigator

OON.COMBAT_IDS = {
    zones = {
        opulentOrdeal = 1565,
        nightMarket = 1559,
        gossamerCrypt = 1562,
        mournfulCatacomb = 1563,
        timelessWallow = 1564,
    },
    strings = {
        u49ModuleName = 4494,
    },
    affinities = {
        [256680] = "red", -- Cobwebs
        [256681] = "orange", -- Drylands
        [256682] = "purple", -- Eclipse
    },
    lampBuffs = {
        [250846] = true, -- Radiant Lamplight
    },
    essences = {
        webEater = {
            color = "red",
            summonId = 256159,
            displayId = 256088,
            stunnedId = 257928,
        },
        aridVarlet = {
            color = "orange",
            summonId = 256413,
            displayId = 256447,
            stunnedId = 257929,
        },
        knightshade = {
            color = "purple",
            summonId = 256495,
            displayId = 256518,
            stunnedId = 257930,
        },
    },
    bombs = {
        skittering = 256383,
        sorrow = 256579,
        parch = 256483,
        smokeStep = 257513,
    },
    soaks = {
        [256383] = { room = "red", name = "Skittering Bomb" },
        [256483] = { room = "orange", name = "Parch Bomb" },
        [256579] = { room = "purple", name = "Sorrow Bomb" },
    },
    dualSoaks = {
        [257681] = { room = "red", name = "Call to the Cobweb" },
        [257676] = { room = "orange", name = "Call to the Drylands" },
        [257686] = { room = "purple", name = "Call to the Eclipse" },
    },
}

OON.ESSENCE_SUMMON_TO_COLOR = {
    [256159] = "red",
    [256413] = "orange",
    [256495] = "purple",
}

-- Base-game center-screen announcement text. These are used because summon
-- combat events identify the essence, but not the room it appeared in.
OON.ESSENCE_ANNOUNCEMENTS = {
    ["Arid Varlet Essence Appeared in the Cobwebs"] = { orbColor = "orange", spawnRoom = "red" },
    ["Arid Varlet Essence Appeared in the Eclipse"] = { orbColor = "orange", spawnRoom = "purple" },
    ["Knightshade Essence Appeared in the Cobwebs"] = { orbColor = "purple", spawnRoom = "red" },
    ["Knightshade Essence Appeared in the Drylands"] = { orbColor = "purple", spawnRoom = "orange" },
    ["Web Eater Essence Appeared in the Drylands"] = { orbColor = "red", spawnRoom = "orange" },
    ["Web Eater Essence Appeared in the Eclipse"] = { orbColor = "red", spawnRoom = "purple" },
}

function OON.GetCurrentZoneId()
    return GetZoneId(GetUnitZoneIndex("player"))
end

function OON.IsInOpulentOrdeal()
    return OON.GetCurrentZoneId() == OON.COMBAT_IDS.zones.opulentOrdeal
end
