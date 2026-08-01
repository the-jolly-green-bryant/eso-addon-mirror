-- Mode 2 Data    N, V, VH

-- Not all dungeons have second mode

Dat["Group 2N"] = {}
Dat["Group 2N"].name="Group 2N"
Dat["Group 2N"].dat=
{
1562,		-- "Fungal Grotto II Vanquisher"
1587,		-- "Darkshade Caverns II Vanquisher"
--[272]= {L=3, C=1},		-- "Arx Corinium Vanquisher"
--[357]= {L=4, C=1},		-- "Direfrost Keep Vanquisher"
-- [393]= {L=5, C=1},		-- "Blessed Crucible Vanquisher"

1571,		-- "Spindleclutch II Vanquisher"
1595,		-- "Wayrest Sewers II Vanquisher"
1616,		-- "Crypt of Hearts II Vanquisher"
-- [391]= {L=4, C=2},		-- "Volenfell Vanquisher"
-- [410]= {L=5, C=2},		-- "Blackheart Haven Vanquisher"

1555,		-- "Banished Cells II Vanquisher"
1579,		-- "Elden Hollow II Vanquisher"
1603,		-- "City of Ash II Vanquisher"
-- [81]= {L=4, C=3},		-- "Tempest Island Vanquisher"
-- [417]= {L=5, C=3},		-- "Selene's Web Vanquisher"

-- [570]= {L=5, C=4},		-- "Vaults of Madness Vanquisher"
}



Dat["Group 2V"] = {}
Dat["Group 2V"].name="Group 2V"
Dat["Group 2V"].dat= 
{
343,		-- "Fungal Grotto II Conqueror"
464,		-- "Darkshade Caverns II Conqueror"
--[272]= {L=3, C=1},		-- "Arx Corinium Vanquisher"
--[357]= {L=4, C=1},		-- "Direfrost Keep Vanquisher"
-- [393]= {L=5, C=1},		-- "Blessed Crucible Vanquisher"

421,		-- "Spindleclutch II Conqueror"
678,		-- "Wayrest Sewers II Conqueror"
876,		-- "Crypt of Hearts II Conqueror"
-- [391]= {L=4, C=2},		-- "Volenfell Vanquisher"
-- [410]= {L=5, C=2},		-- "Blackheart Haven Vanquisher"

545,		-- "Banished Cells II Conqueror"
459,		-- "Elden Hollow II Conqueror"
878,		-- "City of Ash II Conqueror"
-- [81]= {L=4, C=3},		-- "Tempest Island Vanquisher"
-- [417]= {L=5, C=3},		-- "Selene's Web Vanquisher"

-- [570]= {L=5, C=4},		-- "Vaults of Madness Vanquisher"
}


-- Hard Mode Activated

Dat["Group 2VH"] = {}
Dat["Group 2VH"].name="Group 2VH"
Dat["Group 2VH"].dat=
{
342,		-- "Fearless Assaulter"
467,		-- "Deadly Engineer"
-- 272]= {L=3, C=1},		-- "Arx Corinium Vanquisher"
-- [357]= {L=4, C=1},		-- "Direfrost Keep Vanquisher"
-- [393]= {L=5, C=1},		-- Blessed Crucible

448,		-- "Compassionate Hero"
681,		-- "Pellingare Ghoul Slayer"
1084,		-- "The Blade's Edge"
-- [391]= {L=4, C=2},		-- "Volenfell Vanquisher"
-- [410]= {L=5, C=2},		-- "Blackheart Haven Vanquisher"

451,		-- "Cursed Hero"
463,		-- "Closing the Book"
1114,		-- "A World On Fire"
-- [81]= {L=4, C=3},		-- "Tempest Island Vanquisher"
-- [417]= {L=5, C=3},		-- "Selene's Web Vanquisher"

-- [570]= {L=5, C=4},		-- "Vaults of Madness Vanquisher"
}


sanity_check(Dat["Group 2N"])
sanity_check(Dat["Group 2V"])
sanity_check(Dat["Group 2VH"])
