--format: { globalX, globalY, setIndex, zoneMapIndex, zoneId, poiIndex, hideOnWorldmap, achievementId }, -- "set name"
-- use /csinfo to gather all necessary data
CraftingStations.Data = {
    ----Alik'r Desert (Daggerfall Covenant)
    { 0.195318, 0.405529, 10, 5, 104, 59 }, -- "Vampire's Kiss"
    { 0.199241, 0.382559, 11, 5, 104, 54 }, -- "Song of Lamae"
    { 0.160435, 0.412478, 12, 5, 104, 55 }, -- "Alessia's Bulwark"

    ----Auridon (Aldmeri Dominion)
    { 0.248853, 0.732033, 2, 15, 381, 56 }, -- "Death's Wind"
    { 0.252670, 0.674239, 3, 15, 381, 50 }, -- "Night's Silence"
    { 0.212228, 0.618415, 1, 15, 381, 55 }, -- "Ashen Grip"

    ----Bangkorai (Daggerfall Covenant)
    { 0.306511, 0.302869, 13, 6, 92, 49 }, -- "Night Mother's Gaze"
    { 0.323481, 0.317263, 14, 6, 92, 55 }, -- "Willow's Path"
    { 0.306896, 0.349664, 15, 6, 92, 57 }, -- "Hunding's Rage"

    ----Blackwood
    { 0.683455, 0.719234, 63, 42, 1261, 52 }, -- "Hist Whisperer"
    { 0.640398, 0.633053, 64, 42, 1261, 50 }, -- "Diamond's Victory"
    { 0.672351, 0.656508, 65, 42, 1261, 51 }, -- "Heartland Conqueror"

    ----Clockwork City (DLC)
    { 0.257219, 1.100020, 39, 31, 980, 20 }, -- "Mechanical Acuity"
    { 0.291726, 1.067383, 40, 31, 980, 19 }, -- "Innate Axiom"
    { 0.241780, 1.032656, 50, 31, 981, 3 }, -- "Fortified Brass"

    ----Coldharbor
    { -0.119159, 0.286308, 16, 23, 347, 56 }, -- "Oblivion's Foe"
    { -0.075684, 0.258644, 17, 23, 347, 47 }, -- "Spectre's Eye"

    ----Craglorn
    { 0.408300, 0.354142, 22, 25, 888, 43 }, -- "Way of the Arena"
    { 0.393518, 0.345460, 23, 25, 888, 12 }, -- "Twice-Born Star"

    ----Cyrodiil (Imperial City)
    { 0.553609, 0.481525, 24, 14, 584, 22 }, -- "Redistributor"
    { 0.543634, 0.479679, 25, 14, 584, 23 }, -- "Noble's Conquest"
    { 0.548721, 0.471108, 26, 14, 584, 24 }, -- "Armor Master"

    ----Cyrodiil (Towns)
    { 0.580925, 0.515334, 54, 14, 181, 107 }, -- "Dauntless Combatant"
    { 0.514313, 0.519862, 55, 14, 181, 108 }, -- "Critical Riposte"
    { 0.546823, 0.433190, 56, 14, 181, 109 }, -- "Unchained Aggressor"

    ----Deadlands
    { 1.154996, 0.746438, 66, 44, 1286, 19, true }, -- "Wretched Vitality"
    { 0.878745, 0.986088, 67, 43, 1283, 1, true }, -- "Iron Flask"
    { 1.083630, 0.795462, 68, 44, 1286, 20, true }, -- "Deadlands Demolisher"

    ----Deshaan (Ebonheart Pact)
    { 0.721673, 0.506028, 4, 10, 57, 52 }, -- "Torug's Pact"
    { 0.799078, 0.492982, 5, 10, 57, 51 }, -- "Twilight's Embrace"
    { 0.756475, 0.492118, 6, 10, 57, 53 }, -- "Armor of the Seducer"

    ----Eastmarch (Ebonheart Pact)
    { 0.609571, 0.311760, 10, 13, 101, 55 }, -- "Vampire's Kiss"
    { 0.630846, 0.298529, 11, 13, 101, 54 }, -- "Song of Lamae"
    { 0.672569, 0.328319, 12, 13, 101, 52 }, -- "Alessia's Bulwark"

    ----Eyevea
    { 0.057310, 0.611720, 20, 1, 267, -7, false, 702 }, -- "Eyes of Mara"
    { 0.063728, 0.618065, 21, 1, 267, -6, false, 702 }, -- "Shalidor's Curse"

    ----Galen and Y'ffelon
    { 0.053731, 0.571077, 72, 47, 1383, 8 }, -- "Old Growth Brewer"
    { 0.054328, 0.560537, 73, 47, 1383, 10 }, -- "Claw of the Forest Wraith"
    { 0.045916, 0.560568, 74, 47, 1383, 9 }, -- "Chimera's Rebuke"

    ----Glenumbra (Daggerfall Covenant)
    { 0.121432, 0.292176, 1, 2, 3, 61 }, -- "Ashen Grip"
    { 0.073620, 0.363201, 2, 2, 3, 60 }, -- "Death's Wind"
    { 0.137157, 0.332575, 3, 2, 3, 56 }, -- "Night's Silence"

    ----Grahtwood (Aldmeri Dominion)
    { 0.474290, 0.767840, 4, 7, 383, 55 }, -- "Torug's Pact"
    { 0.451303, 0.748470, 5, 7, 383, 49 }, -- "Twilight's Embrace"
    { 0.418387, 0.717673, 6, 7, 383, 52 }, -- "Armor of the Seducer"

    ----Greenshade (Aldmeri Dominion)
    { 0.338443, 0.718542, 7, 16, 108, 52 }, -- "Magnus' Gift"
    { 0.314127, 0.696812, 8, 16, 108, 55 }, -- "Hist Bark"
    { 0.319405, 0.666510, 9, 16, 108, 50 }, -- "Whitestrake's Retribution"

    ----Gold Coast
    { 0.362116, 0.545747, 33, 29, 823, 18 }, -- "Kvatch Gladiator"
    { 0.340392, 0.590074, 34, 29, 823, 19 }, -- "Varen's Legacy"
    { 0.318909, 0.535808, 35, 29, 823, 20 }, -- "Pelinal's Aptitude"

    --- Hew's Bane
    { 0.224781, 0.528709, 30, 28, 816, 21 }, -- "Tava's Favor"
    { 0.248035, 0.533278, 31, 28, 816, 24 }, -- "Clever Alchemist"
    { 0.227424, 0.504435, 32, 28, 816, 19 }, -- "Eternal Hunt"

    --- High Isle and Amenos
    { 0.060298, 0.601418, 69, 45, 1318, 37 }, -- "Order's Wrath"
    { 0.064215, 0.588176, 70, 45, 1318, 36 }, -- "Serpent's Disdain"
    { 0.074840, 0.580736, 71, 45, 1318, 38 }, -- "Druid's Braid"

    ----Malabal Tor (Aldmeri Dominion)
    { 0.335706, 0.636976, 10, 8, 58, 58 }, -- "Vampire's Kiss"
    { 0.389581, 0.643106, 11, 8, 58, 53 }, -- "Song of Lamae"
    { 0.379511, 0.613354, 12, 8, 58, 56 }, -- "Alessia's Bulwark"

    --- Markarth
    { 0.381351, 0.280207, 60, 41, 1207, 17 }, -- "Red Eagle's Fury"
    { 0.360820, 0.250262, 61, 41, 1207, 4 }, -- "Legacy of Karth"
    { 0.591357, 1.582965, 62, 40, 1208, 11 }, -- "Aetherial Ascension"
    { 0.404846, 0.270929, 62, 41, 1207 }, -- "Aetherial Ascension" -- The Reach so it is visible on the Tamriel Map

    ---Murkmire
    { 0.704428, 0.764325, 44, 34, 726, 18 }, -- "Naga Shaman"
    { 0.744498, 0.783985, 45, 34, 726, 17 }, -- "Might of the Lost Legion"
    { 0.762189, 0.764657, 46, 34, 726, 19 }, -- "Grave-Stake Collector"

    --- Northern Elsweyr
    { 0.556164, 0.625811, 47, 35, 1086, 28 }, -- "Vastarie's Tutelage"
    { 0.509192, 0.621588, 48, 35, 1086, 26 }, -- "Senche-raht's Grit"
    { 0.480021, 0.682758, 49, 35, 1086, 27 }, -- "Coldharbour's Favorite"

    ----Reaper’s March (Aldmeri Dominion)
    { 0.438213, 0.560987, 13, 17, 382, 48 }, -- "Night Mother's Gaze"
    { 0.434994, 0.589913, 14, 17, 382, 52 }, -- "Willow's Path"
    { 0.434499, 0.640293, 15, 17, 382, 51 }, -- "Hunding's Rage"

    ----Rivenspire (Daggerfall Covenant)
    { 0.178112, 0.214450, 7, 3, 20, 52 }, -- "Magnus' Gift"
    { 0.182168, 0.263019, 8, 3, 20, 57 }, -- "Hist Bark"
    { 0.191766, 0.201104, 9, 3, 20, 53 }, -- "Whitestrake's Retribution"

    ----Shadowfen (Ebonheart Pact)
    { 0.764136, 0.541058, 7, 9, 117, 50 }, -- "Magnus' Gift"
    { 0.766800, 0.611687, 8, 9, 117, 57 }, -- "Hist Bark"
    { 0.727738, 0.573407, 9, 9, 117, 59 }, -- "Whitestrake's Retribution"

    ----Solstice
    { 0.703068, 0.905428, 81, 52, 1502, 74 }, -- "Shared Burden"
    { 0.666029, 0.909148, 82, 52, 1502, 51 }, -- "Tide-Born Wildstalker"
    { 0.705678, 0.931677, 83, 52, 1502, 75 }, -- "Fellowship's Fortitude"

    --- Southern Elsweyr
    { 0.584032, 0.778134, 51, 36, 1133, 12 }, -- "Daring Corsair"
    { 0.616740, 0.785241, 52, 36, 732, 2, false, 2611 }, -- "Ancient Dragonguard"
    { 0.547324, 0.741082, 53, 36, 1133, 11 }, -- "New Moon Acolyte"

    ----Stonefalls (Ebonheart Pact)
    { 0.707924, 0.474787, 1, 11, 41, 59 }, -- "Ashen Grip"
    { 0.733888, 0.468414, 2, 11, 41, 54 }, -- "Death's Wind"
    { 0.770101, 0.438897, 3, 11, 41, 56 }, -- "Night's Silence"

    ----Stormhaven (Daggerfall Covenant)
    { 0.202562, 0.317744, 4, 4, 19, 56 }, -- "Torug's Pact"
    { 0.179523, 0.296797, 5, 4, 19, 59 }, -- "Twilight's Embrace"
    { 0.234490, 0.335854, 6, 4, 19, 57 }, -- "Armor of the Seducer"

    ----Summerset
    { 0.155547, 0.708969, 41, 32, 1011, 33 }, -- "Adept Rider"
    { 0.856364, -0.025311, 42, 33, 1027, 1 }, -- "Sload's Semblance"
    { 0.064461, 0.700770, 43, 32, 1011, 34 }, -- "Nocturnal's Favor"

    ----Telvanni Peninsula
    { 0.913087, 0.410908, 75, 48, 1414, 15 }, -- "Telvanni Efficiency"
    { 0.172444, -0.010369, 76, 49, 1413, 19 }, -- "Shattered Fate"
    { 0.112879, -0.014908, 77, 49, 1413, 18 }, -- "Seeker Synthesis"

    ----The Earth Forge
    { 0.333199, 0.274923, 18, 24, 642, nil, false, 703 }, -- "Kagrenac's Hope"
    { 0.333755, 0.275408, 19, 24, 642, nil, true, 703 }, -- "Orgnum's Scales" -- entrance
    { 0.332478, 0.275851, 19, 1, 0, nil, false, 703 }, -- "Orgnum's Scales"

    ----The Rift (Ebonheart Pact)
    { 0.581143, 0.351956, 13, 12, 103, 57 }, -- "Night Mother's Gaze"
    { 0.654175, 0.407761, 14, 12, 103, 53 }, -- "Willow's Path"
    { 0.610180, 0.391604, 15, 12, 103, 59 }, -- "Hunding's Rage"

    ---VVardenfell
    { 0.735418, 0.298616, 36, 30, 849, 45 }, -- "Daedric Trickery"
    { 0.782981, 0.271244, 37, 30, 849, 46 }, -- "Shacklebreaker"
    { 0.777514, 0.341866, 38, 30, 849, 44 }, -- "Assassin's Guile"

    ----West Weald
    { 0.383357, 0.558560, 78, 50, 1443, 4 }, -- "Tharriker's Strike"
    { 0.371242, 0.513750, 79, 50, 1443, 3 }, -- "Highland Sentinel"
    { 0.425848, 0.457452, 80, 50, 1443, 5 }, -- "Threads of War"

    ----Western Skyrim
    { 0.631686, 1.537321, 57, 38, 1161, 22 }, -- "Spell Parasite"
    { 0.451287, 0.182738, 57, 37, 1160 }, -- "Spell Parasite" -- Western Skyrim so it is visible on the Tamriel Map
    { 0.416856, 0.245695, 58, 37, 1160, 48 }, -- "Stuhn's Favor"
    { 0.381679, 0.224519, 59, 37, 1160, 49 }, -- "Dragon's Appetite"

    ----Wrothgar
    { 0.231477, 0.282490, 27, 27, 684, 52 }, -- "Law of Julianos"
    { 0.312030, 0.246388, 28, 27, 684, 51 }, -- "Trial by Fire"
    { 0.287922, 0.231830, 29, 27, 684, 53 }, -- "Morkuldin"
}
--format: [setIndex] = { itemId, numTraitsRequired }, -- "set name"
--/csinfo will automatically print a second line on set locations that have a new set
local itemSets = {
    [1]  = { 43871, 2 }, --"Ashen Grip"
    [2]  = { 43803, 2 }, --"Death's Wind"
    [3]  = { 43815, 2 }, --"Night's Silence"
    [4]  = { 43977, 3 }, --"Torug's Pact"
    [5]  = { 43807, 3 }, --"Twilight's Embrace"
    [6]  = { 43827, 3 }, --"Armor of the Seducer"
    [7]  = { 43847, 4 }, --"Magnus' Gift"
    [8]  = { 43995, 4 }, --"Hist Bark"
    [9]  = { 43819, 4 }, --"Whitestrake's Retribution"
    [10] = { 43831, 5 }, --"Vampire's Kiss"
    [11] = { 44013, 5 }, --"Song of Lamae"
    [12] = { 44019, 5 }, --"Alessia's Bulwark"
    [13] = { 43859, 6 }, --"Night Mother's Gaze"
    [14] = { 44001, 6 }, --"Willow's Path"
    [15] = { 44007, 6 }, --"Hunding's Rage"
    [16] = { 43965, 8 }, --"Oblivion's Foe"
    [17] = { 43971, 8 }, --"Spectre's Eye"
    [18] = { 44079, 8 }, --"Kagrenac's Hope" -- finished fighters guild questline -- can be accessed via the portal in the fighters guild in your own alliance's last zone
    [19] = { 44031, 8 }, --"Orgnum's Scales" -- finished fighters guild questline
    [20] = { 44049, 8 }, --"Eyes of Mara" -- finished mages guild questline -- can be accessed via the portals in your own alliance's mages guilds
    [21] = { 40259, 8 }, --"Shalidor's Curse" -- finished mages guild questline
    [22] = { 54787, 8 }, --"Way of the Arena"
    [23] = { 58153, 9 }, --"Twice-Born Star"
    [24] = { 60618, 7 }, --"Redistributor"
    [25] = { 60280, 5 }, --"Noble's Conquest"
    [26] = { 60973, 9 }, --"Armor Master"
    [27] = { 69606, 6 }, --"Law of Julianos"
    [28] = { 69949, 3 }, --"Trial by Fire"
    [29] = { 70642, 9 }, --"Morkuldin" -- finished quest line in Morkul Fortress
    [30] = { 71795, 5 }, --"Tava's Favor"
    [31] = { 72145, 7 }, --"Clever Alchemist"
    [32] = { 72502, 9 }, --"Eternal Hunt"
    [33] = { 75397, 5 }, --"Kvatch Gladiator"
    [34] = { 75747, 7 }, --"Varen's Legacy"
    [35] = { 76120, 9 }, --"Pelinal's Aptitude"
    [36] = { 121912, 8 }, --"Daedric Trickery"
    [37] = { 122285, 6 }, --"Shacklebreaker"
    [38] = { 121585, 3 }, --"Assassin's Guile"
    [39] = { 131104, 6 }, --"Mechanical Acuity"
    [40] = { 130381, 2 }, --"Innate Axiom"
    [41] = { 135736, 3 }, --"Adept Rider"
    [42] = { 136101, 6 }, --"Sload's Semblance"
    [43] = { 136436, 9 }, --"Nocturnal's Favor"
    [44] = { 143180, 2 }, --"Naga Shaman"
    [45] = { 143565, 4 }, --"Might of the Lost Legion"
    [46] = { 142825, 7 }, --"Grave-Stake Collector"
    [47] = { 148722, 3 }, --"Vastarie's Tutelage"
    [48] = { 148352, 5 }, --"Senche-raht's Grit"
    [49] = { 147967, 8 }, --"Coldharbour's Favorite"
    [50] = { 130739, 4 }, --"Fortified Brass"
    [51] = { 155415, 3 }, --"Daring Corsair"
    [52] = { 155789, 6 }, --"Ancient Dragonguard" -- "Restoring the Order" achievement (12 Dragonguard Quests)
    [53] = { 156187, 9 }, --"New Moon Acolyte"
    [54] = { 159083, 3 }, --"Dauntless Combatant"
    [55] = { 158327, 3 }, --"Critical Riposte"
    [56] = { 158724, 3 }, --"Unchained Aggressor"
    [57] = { 163076, 3 }, --"Spell Parasite"
    [58] = { 161232, 5 }, --"Stuhn's Favor"
    [59] = { 161630, 7 }, --"Dragon's Appetite"
    [60] = { 168034, 3 }, --"Red Eagle's Fury"
    [61] = { 168408, 6 }, --"Legacy of Karth"
    [62] = { 168782, 9 }, --"Aetherial Ascension"
    [63] = { 172474, 3 }, --"Hist Whisperer"
    [64] = { 173214, 5 }, --"Diamond's Victory"
    [65] = { 172848, 7 }, --"Heartland Conqueror"
    [66] = { 178840, 3 }, --"Wretched Vitality"
    [67] = { 179573, 5 }, --"Iron Flask"
    [68] = { 179191, 7 }, --"Deadlands Demolisher"
    [69] = { 184805, 3 }, --"Order's Wrath"
    [70] = { 185170, 5 }, --"Serpent's Disdain"
    [71] = { 185565, 7 }, --"Druid's Braid"
    [72] = { 191631, 3 }, --"Old Growth Brewer"
    [73] = { 192027, 5 }, --"Claw of the Forest Wraith"
    [74] = { 191267, 7 }, --"Chimera's Rebuke"
    [75] = { 194961, 3 }, --"Telvanni Efficiency"
    [76] = { 194581, 5 }, --"Shattered Fate"
    [77] = { 195333, 7 }, --"Seeker Synthesis"
    [78] = { 205428, 3 }, --"Tharriker's Strike"
    [79] = { 205807, 5 }, --"Highland Sentinel"
    [80] = { 206188, 7 }, --"Threads of War"
    [81] = { 215118, 3 }, --"Shared Burden"
    [82] = { 215498, 5 }, --"Tide-Born Wildstalker"
    [83] = { 215894, 7 }, --"Fellowship's Fortitude"
}

local L = CraftingStations.Localization

local dummyLabel = WINDOW_MANAGER:CreateControl(nil, GuiRoot, CT_LABEL)
dummyLabel:SetFont("ZoFontGame")
local function splitDescription(desc)
    local r = {}
    for _, line in ipairs({zo_strsplit("\n", desc)}) do
        local last = ""
        local cur = ""
        for _, w in ipairs({zo_strsplit(" ", line)}) do
            if cur == "" then cur = w
            else cur = cur.." "..w
            end
            dummyLabel:SetText(cur)
            if dummyLabel:GetTextWidth() > 300 then  --350 maxX - 2*25 padding
                table.insert(r, last)
                cur = w
            end
            last = cur
        end
        if last ~= "" then table.insert(r, last) end
    end
    return r
end

CraftingStations.ItemSets = {}
for i, data in pairs(itemSets) do
    local itemLink = ("|H1:item:%d:370:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h"):format(data[1])
    local hasSet, setName, numBonuses = GetItemLinkSetInfo(itemLink)
    local desc = {}
    for j = 1, numBonuses do
        local bonusDescription = splitDescription(select(2, GetItemLinkSetBonusInfo(itemLink, false, j)))
        for _, k in ipairs(bonusDescription) do
            table.insert(desc, k)
        end
    end
    CraftingStations.ItemSets[i] = {
        name = zo_strformat("<<1>>", setName),
        traits = zo_strformat(L["TOOLTIP_TRAITS_RESEARCHED"], data[2]),
        info = desc,
    }
end
dummyLabel = nil
