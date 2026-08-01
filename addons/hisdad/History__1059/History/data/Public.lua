
--Must have a group event to be a public dungeon



--For char Mode
Pub_Dat_Char= {}
Pub_Dat_Char.dat= {}	-- this is an array
Pub_Dat_Char.name="Pub_Dat_Char"

Pub_Dat_Char.dat=
{

1068,	-- --EP Conqueror
1069,	-- --AD Conqueror
1070,	-- --DC Conqueror

368,	-- Crows Wood
379,	-- "Crow\'s Wood Group Event",

370,	-- Forgotten Crypts Conqueror",
388,	-- "Forgotten Crypts Group Event",

300,	-- Sanguine\'s Demesne Conqueror",
372,	-- "Sanguine\'s Group Event",

376,	-- Hall of the Dead Conqueror
381,	-- "Hall of the Dead Group Event",

374,	-- Lion's Den Conqueror
371,	-- "Lion\'s Den Group Event"

1053,	-- Bad Man's Hallows Conqueror"
380,	-- "Bad Man\'s Group Event",


1054,	-- Bonesnap Ruins Conqueror"
714,	-- "Bonesnap Ruins Group Event",


378,	-- Obsidian Scar Conqueror
713,	-- "Obsidian Scar Group Event",

396,	-- Lost City Conqueror
707,	-- "Na-Totambu Group Event",

1055,	-- Razak's Wheel Conqueror"
708,	-- "Razak\'s Wheel Group Event",

390,	-- Toothmaul Gully Conqueror"
468, 	-- "Toothmaul Gully Group Event",

1049,	-- Root Sunder Conqueror"
470,	-- "Root Sunder Group Event",


1050,	-- Rulanyil's Fall Conqueror"
445,	-- "Rulanyil\'s Fall Group Event",

1051,	-- Crimson Cove Conqueror"
460, 	-- "Crimson Cove Group Event",

1052,	-- The Vile Manse Conqueror"
469,	-- "Vile Manse Group Event",


1056,	-- Village of the Lost Conqueror
874,	-- "Village of the Lost Group Event",

--Summerset

2094,	-- "Karnwasten Conqueror" "Defeat all of the champions in Karnwasten.",
2096,	-- "Karnwasten Group Event" "Defeat the Sea Sload K'Garza in Karnwasten.",

2093,	-- "Sunhold Conqueror"  "Defeat all of the champions in Sunhold.",
2095,	-- "Sunhold Group Event",

--Orsinium
1236,	-- "Rkindaleft Conqueror",  "Defeat all of Rkindaleft\'s champions.",
1235,	-- "Rkindaleft Group Event",

1239,	-- "Old Orsinium Conqueror",
1238,	-- "Old Orsinium Group Event",

--Elswer
2442,	-- (Exploration) Orcrest Conqueror,  Defeat all of the champions in Orcrest.
2445,	-- (Exploration) Orcrest Group Event,  Defeat the Plague of Crows in Orcrest.

2440,	-- (Exploration) Rimmen Necropolis Conqueror,  Defeat all of the champions in Rimmen Necropolis.
2444,	-- (Exploration) Rimmen Necropolis Group Event,  Defeat Aspect of Darloc Brae and Champion of Mehrunnez in the Rimmen Necropolis.

--Greymoor
2717,	-- (Exploration) Labyrinthian Conqueror,  Defeat all of the champions in Western Skyrim's Labyrinthian.
2714,	-- (Exploration) Labyrinthian Group Event,  Defeat Garneld the Hollow and his band of undead and draugr in Labyrinthian.

2718,	-- (Exploration) Nchuthnkarst Conqueror,  Defeat all of the champions in Nchuthnkarst, located in Blackreach: Dusktown Cavern.
2715,	-- (Exploration) Nchuthnkarst Group Event,  Defeat the Clockwork Criterion and its Mechanical Minions in Nchuthnkarst.

--Stonethorn   None
--Markath  None
--Shadows of the Hist None
--Horns of the Reach   None
--Dragon Bones   None

--Morrowind
1846,	-- Nchuleftingth Group Event,  Defeat Nchulaeon the Eternal in Nchuleftingth.
1854,	-- Nchuleftingth Conqueror,  Defeat all of the champions in Nchuleftingth.

1855,	-- Forgotten Wastes Group Event,  Defeat Stone-Boiler Omalas, Brander Releth, and Mountain-Caller Hlaren in the Forgotten Wastes.
1857,	-- Forgotten Wastes Conqueror,  Defeat all of the champions in the Forgotten Wastes.

--Blackwood


--High Isle
3282,	-- (Exploration) Ghost Haven Bay Conqueror,  Defeat all of the champions in Ghost Haven Bay.

--lost Depths None
--Necrom
3657,	-- (Exploration) The Underweave Group Event,  Defeat All-Seeing Ky'zuu in the Underweave.
3659,	-- (Exploration) The Underweave Conqueror,  Defeat all of the champions in the Underweave.
3658,	-- (Exploration) Gorne Group Event,  Defeat Gatekeeper Gruzo on the island of Gorne.
3660,	-- (Exploration) Gorne Conqueror,  Defeat all of the champions on the island of Gorne.

--  Worm Cult
4265,	-- (Exploration) Deetra Grotto Conqueror,  Defeat all of the champions in Deetra Grotto.
}

--For char Mode
Dat["Public"] = {}
Dat["Public"].dat= Pub_Dat_Char.dat	-- this is an array
Dat["Public"].name="Public"

sanity_check(Dat["Public"])
