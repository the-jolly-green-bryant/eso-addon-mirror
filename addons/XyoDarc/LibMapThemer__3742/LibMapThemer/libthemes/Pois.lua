local themeName = "LibMapThemer_Pois"

_G[themeName] = {
   maps = { },
}
local theme = _G[themeName]
local maps = theme.maps

----------------------------------------------------------------------------------------------------------------------------------------
---- Tamriel -------- Tamriel -------- Tamriel -------- Tamriel -------- Tamriel -------- Tamriel -------- Tamriel -------- Tamriel ----
----------------------------------------------------------------------------------------------------------------------------------------
---- Tamriel -------- Tamriel -------- Tamriel -------- Tamriel -------- Tamriel -------- Tamriel -------- Tamriel -------- Tamriel ----
----------------------------------------------------------------------------------------------------------------------------------------
maps[27] = { pois = { }, }
local tamriel = maps[27]
local tamrielPois = tamriel.pois


-------------------------------------------------------------------------------------------------------------------------------------------------
---- Daggerfall Covenant -------- Daggerfall Covenant -------- Daggerfall Covenant -------- Daggerfall Covenant -------- Daggerfall Covenant ----
-------------------------------------------------------------------------------------------------------------------------------------------------

-----------------
-- Stros M'kai --
tamrielPois[138] = { majorSettlement = true, guildShrine = true, }  -- Port Hunding Wayshrine 

-------------
-- Betnikh --
tamrielPois[181] = { majorSettlement = true, guildShrine = true }   -- Stonetooth Wayshrine

---------------
-- Glenumbra --
tamrielPois[1]   = { guildShrine = true, }                          -- Wyrd Tree Wayshrine
tamrielPois[2]   = { majorSettlement = true, }                      -- Aldcroft Wayshrine 
tamrielPois[6]   = { guildShrine = true, }                          -- Lionguard Redoubt Wayshrine
tamrielPois[7]   = { majorSettlement = true, }                      -- Crosswyrch Wayshrine 
tamrielPois[62]  = { majorSettlement = true, guildShrine = true }   -- Daggerfall Wayshrine 

----------------
-- Stormhaven --   
tamrielPois[14]  = { majorSettlement = true, guildShrine = true, }  -- Koeglin Village Wayshrine 
tamrielPois[15]  = { majorSettlement = true, }                      -- Alcaire Castle Wayshrine 
tamrielPois[16]  = { guildShrine = true, }                          -- Firebrand Keep Wayshrine 
tamrielPois[22]  = { majorSettlement = true, }                      -- Wind Keep Wayshrine 
tamrielPois[56]  = { majorSettlement = true, guildShrine = true, }  -- Wayrest Wayshrine

----------------
-- Rivenspire --
tamrielPois[9]   = { guildShrine = true }                           -- Oldgate Wayshrine
tamrielPois[10]  = { majorSettlement = true, }                      -- Crestshade Wayshrine
tamrielPois[55]  = { majorSettlement = true, guildShrine = true, }  -- Shornhelm Wayshrine
tamrielPois[82]  = { majorSettlement = true, }                      -- Northpoint Wayshrine
tamrielPois[84]  = { majorSettlement = true, guildShrine = true, }  -- Hoarfrost Downs Wayshrine

----------------
-- The Alik'r --
tamrielPois[42]  = { guildShrine = true, }                          -- Morwha's Bounty Wayshrine
tamrielPois[43]  = { majorSettlement = true, guildShrine = true, }  -- Sentinel Wayshrine
tamrielPois[44]  = { majorSettlement = true, guildShrine = true, }  -- Bergama Wayshrine
tamrielPois[46]  = { majorSettlement = true, }                      -- Satakalaam Wayshrine

---------------
-- Bangkorai --
tamrielPois[33]  = { majorSettlement = true, } -- Evermore Wayshrine
tamrielPois[36]  = { guildShrine = true, } -- Bangkorai Pass Wayshrine
tamrielPois[38]  = { majorSettlement = true, guildShrine = true, } -- Hallin's Stand Wayshrine  
tamrielPois[204] = { guildShrine = true, } -- Eastern Evermore Wayshrine

------------------------------------------------------------------------------------------------------------------------------------------------------------
---- Aldmeri Dominion -------- Aldmeri Dominion -------- Aldmeri Dominion -------- Aldmeri Dominion -------- Aldmeri Dominion -------- Aldmeri Dominion ----
------------------------------------------------------------------------------------------------------------------------------------------------------------

-----------------------
-- Khenarthi's Roost --
tamrielPois[142] = { majorSettlement = true, } -- Mistral Wayshrine

-------------
-- Auridon --
tamrielPois[121] = { majorSettlement = true, guildShrine = true, }  -- Skywatch Wayshrine
tamrielPois[175] = { majorSettlement = true, guildShrine = true, }  -- Firsthold Wayshrine  
tamrielPois[176] = { majorSettlement = true, }                      -- Mathiisen Wayshrine
tamrielPois[177] = { majorSettlement = true, guildShrine = true, }  -- Vulkhel Guard Wayshrine

---------------
-- Grahtwood --
tamrielPois[164] = { majorSettlement = true, }                      -- Gilvardale Wayshrine
tamrielPois[165] = { majorSettlement = true, }                      -- Haven Wayshrine
tamrielPois[166] = { majorSettlement = true, }                      -- Redfur Trading Post Wayshrine
tamrielPois[167] = { majorSettlement = true, guildShrine = true, }  -- Southpoint Wayshrine
tamrielPois[168] = { majorSettlement = true, guildShrine = true, }  -- Cormount Wayshrine
tamrielPois[214] = { majorSettlement = true, guildShrine = true, }  -- Elden Root Wayshrine

----------------
-- Greenshade --
tamrielPois[143] = { majorSettlement = true, guildShrine = true, }  -- Marbruk Wayshrine
tamrielPois[147] = { majorSettlement = true, guildShrine = true, }  -- Greenheart Wayshrine
tamrielPois[151] = { majorSettlement = true, guildShrine = true, }  -- Verrant Morass Wayshrine
tamrielPois[152] = { majorSettlement = true, }                      -- Woodhearth Wayshrine

-----------------
-- Malabal Tor --
tamrielPois[100] = { majorSettlement = true, }                      -- Vulkwasten Wayshrine
tamrielPois[101] = { guildShrine = true, }                          -- Dra'bul Wayshrine
tamrielPois[102] = { majorSettlement = true, }                      -- Vely Harbour Wayshrine
tamrielPois[106] = { majorSettlement = true, guildShrine = true, } -- Baandari Trading Post Wayshrine    name = "Baandari Trading Post Wayshrine", 
tamrielPois[107] = { majorSettlement = true, guildShrine = true, }  -- Valeguard Wayshrine

--------------------
-- Reaper's March --
tamrielPois[158] = { majorSettlement = true, }                      -- Arenthia Wayshrine
tamrielPois[144] = { majorSettlement = true, guildShrine = true, }  -- Vinedusk Wayshrine
tamrielPois[159] = { majorSettlement = true, guildShrine = true, }  -- Dune Wayshrine
tamrielPois[162] = { majorSettlement = true, guildShrine = true, }  -- Rawl'kha Wayshrine
tamrielPois[163] = { majorSettlement = true, }                      -- S'ren-ja Wayshrine

------------------------------------------------------------------------------------------------------------------------------------------------
---- Ebonheart Pact -------- Ebonheart Pact -------- Ebonheart Pact -------- Ebonheart Pact -------- Ebonheart Pact -------- Ebonheart Pact ----
------------------------------------------------------------------------------------------------------------------------------------------------

--------------------
-- Bleakrock Isle --
tamrielPois[172] = { majorSettlement = true, guildShrine = true } -- Bleakrock Isle Wayshrine

---------------
-- Bal Foyen --
tamrielPois[173] = { majorSettlement = true, guildShrine = true, } -- Dhalmora Wayshrine

----------------
-- Stonefalls --
tamrielPois[65] = { majorSettlement = true, guildShrine = true } -- Davon's Watch Wayshrine
tamrielPois[67] = { majorSettlement = true, guildShrine = true } -- Ebonheart Wayshrine
tamrielPois[76] = { majorSettlement = true, guildShrine = true } -- Kragenmoor Wayshrine

-------------
-- Deshaan --
tamrielPois[24] = { majorSettlement = true, }                    -- West Narsis Wayshrine
tamrielPois[25] = { guildShrine = true, }                        -- Muth Gnaar Hills Wayshrine
tamrielPois[28] = { majorSettlement = true, guildShrine = true } -- Mournhold Wayshrine
tamrielPois[29] = { guildShrine = true, }                        -- Tal'Deic Grounds Wayshrine
tamrielPois[79] = { majorSettlement = true, }                    -- Selfora Wayshrine

---------------
-- Shadowfen --
tamrielPois[48] = { majorSettlement = true, guildShrine = true, }   -- Stormhold Wayshrine
tamrielPois[50] = { majorSettlement = true, }                       -- Alten Corimont Wayshrine 
tamrielPois[52] = { guildShrine = true, }                           -- Hissmir Wayshrine 
tamrielPois[78] = { guildShrine = true, }                           -- Venomous Fens Wayshrine 

---------------
-- Eastmarch --
tamrielPois[87] = { majorSettlement = true, guildShrine = true } -- Windhelm Wayshrine
tamrielPois[88] = { majorSettlement = true, }                    -- Fort Morvunskar Wayshrine
tamrielPois[90] = { guildShrine = true, }                        -- Voljar Meadery Wayshrine
tamrielPois[92] = { majorSettlement = true, guildShrine = true } -- Fort Amol Wayshrine

--------------
-- The Rift --
tamrielPois[114] = { majorSettlement = true, guildShrine = true }   -- Fallowstone Hall Wayshrine 
tamrielPois[118] = { majorSettlement = true, guildShrine = true }   -- Nimalten Wayshrine
tamrielPois[116] = { majorSettlement = true, }                      -- Geirmund's Hall Wayshrine 
tamrielPois[109] = { majorSettlement = true, guildShrine = true }   -- Riften Wayshrine
tamrielPois[110] = { guildShrine = true, }                          -- Skald's Retreat Wayshrine


----------------------------------------------------------------------------------------------------------------------------------------------------------
---- guildShrines -------- guildShrines -------- guildShrines -------- guildShrines -------- guildShrines -------- guildShrines -------- guildShrines ----
----------------------------------------------------------------------------------------------------------------------------------------------------------

-----------------
-- Earth Forge --
tamrielPois[221] = { disabled = true, majorSettlement = true, }

------------
-- Eyevea --
tamrielPois[215] = { disabled = true, majorSettlement = true, } -- Eyevea Wayshrine

------------------------------------------------------------------------------------------------------------------------------------------------------------------
---- Craglorn -------- Craglorn -------- Craglorn -------- Craglorn -------- Craglorn -------- Craglorn -------- Craglorn -------- Craglorn -------- Craglorn ----
------------------------------------------------------------------------------------------------------------------------------------------------------------------

--------------
-- Craglorn --
tamrielPois[220] = { majorSettlement = true, guildShrine = true, }  -- Belkarth Wayshrine 
tamrielPois[229] = { majorSettlement = true, }                      -- Elinhir Wayshrine 
tamrielPois[233] = { majorSettlement = true, }                      -- Dragonstar Wayshrine 
tamrielPois[270] = { groupArena = true, }                           -- Dragonstar Arena

----------------------------------------------------------------------------------------------------------------------------------------------------------
---- Cyrodiil PvP -------- Cyrodiil PvP -------- Cyrodiil PvP -------- Cyrodiil PvP -------- Cyrodiil PvP -------- Cyrodiil PvP -------- Cyrodiil PvP ----
----------------------------------------------------------------------------------------------------------------------------------------------------------
maps[16] = { pois = { }, }
local cyrodiil = maps[16]
local cyrodiilPois = cyrodiil.pois
--------------
-- Cyrodiil --
cyrodiilPois[201] = { name = "Western Elsweyr Gate Wayshrine",      majorSettlement = true, } -- Western Elsweyr Wayshrine
cyrodiilPois[200] = { name = "Eastern Elsweyr Gate Wayshrine",      majorSettlement = true, } -- Eastern Elsweyr Wayshrine
cyrodiilPois[202] = { name = "Northern Morrowind Gate Wayshrine",   majorSettlement = true, } -- Northern Morrowind Wayshrine
cyrodiilPois[203] = { name = "Southern Morrowind Gate Wayshrine",   majorSettlement = true, } -- Southern Morrowind Wayshrine
cyrodiilPois[170] = { name = "Northern Hammerfell Gate Wayshrine",  majorSettlement = true, } -- Northern Hammerfell Wayshrine
cyrodiilPois[199] = { name = "Southern Hammerfell Gate Wayshrine",  majorSettlement = true, } -- Southern Hammerfell Wayshrine
tamrielPois[200] = cyrodiilPois[200] tamrielPois[201] = cyrodiilPois[201] 
tamrielPois[202] = cyrodiilPois[202] tamrielPois[203] = cyrodiilPois[203] 
tamrielPois[170] = cyrodiilPois[170] tamrielPois[199] = cyrodiilPois[199]


----------------------------------------------------------------------------------------------------------------------------------------------------------
---- Orsinium DLC -------- Orsinium DLC -------- Orsinium DLC -------- Orsinium DLC -------- Orsinium DLC -------- Orsinium DLC -------- Orsinium DLC ----
----------------------------------------------------------------------------------------------------------------------------------------------------------

--------------
-- Wrothgar --
tamrielPois[250] = { soloArena = true, }                            -- Maelstrom Arena
tamrielPois[244] = { majorSettlement = true, guildShrine = true, }  -- Orsinium Wayshrine 
tamrielPois[237] = { majorSettlement = true, guildShrine = true, }  -- Shatul Wayshrine 

------------------------------------------------------------------------------------------------------------------------------------------------------
---- Theives Guild DLC / Dark Brotherhood DLC -------- Theives Guild DLC / Dark Brotherhood DLC -------- Theives Guild DLC / Dark Brotherhood DLC ----
------------------------------------------------------------------------------------------------------------------------------------------------------

----------------
-- Hew's Bane --
tamrielPois[255] = { majorSettlement = true, guildShrine = true, } -- Abah's Landing Wayshrine

----------------
-- Gold Coast --
tamrielPois[251] = { majorSettlement = true, guildShrine = true, }  -- Anvil Wayshrine
tamrielPois[252] = { majorSettlement = true, }                      -- Kvatch Wayshrine

-----------------------------------------------------------------------------------------------------------------------------------------------------------------
---- Morrowind DLC -------- Morrowind DLC -------- Morrowind DLC -------- Morrowind DLC -------- Morrowind DLC -------- Morrowind DLC -------- Morrowind DLC ----
-----------------------------------------------------------------------------------------------------------------------------------------------------------------

-----------------
-- Vvardenfell --
tamrielPois[272] = { majorSettlement = true, }                      -- Seyda Neen Wayshrine 
tamrielPois[273] = { majorSettlement = true, }                      -- Gnisis Wayshrine
tamrielPois[274] = { majorSettlement = true, }                      -- Ald'ruhn Wayshrine
tamrielPois[275] = { majorSettlement = true, guildShrine = true }   -- Balmora Wayshrine
tamrielPois[276] = { majorSettlement = true, }                      -- Suran Wayshrine
tamrielPois[277] = { majorSettlement = true, }                      -- Molag Mar Wayshrine 
tamrielPois[278] = { majorSettlement = true, }                      -- Tel Branora Wayshrine
tamrielPois[280] = { majorSettlement = true, }                      -- Tel Mora Wayshrine
tamrielPois[281] = { majorSettlement = true, guildShrine = true }   -- Sadrith Mora Wayshrine 
tamrielPois[284] = { majorSettlement = true, guildShrine = true }   -- Vivec City Wayshrine 

-----------------------------------------------------------------------------------------------------------------------------------------------------------------
---- Summerset DLC -------- Summerset DLC -------- Summerset DLC -------- Summerset DLC -------- Summerset DLC -------- Summerset DLC -------- Summerset DLC ----
-----------------------------------------------------------------------------------------------------------------------------------------------------------------

---------------
-- Summerset --
tamrielPois[350] = { majorSettlement = true, guildShrine = true, }  -- Shimmerene Wayshrine 
tamrielPois[354] = { majorSettlement = true, }                      -- Ebon Stadmont Wayshrine
tamrielPois[355] = { majorSettlement = true, guildShrine = true, }  -- Alinor Wayshrine
tamrielPois[356] = { majorSettlement = true, guildShrine = true, }  -- Lilandril Wayshrine
tamrielPois[365] = { majorSettlement = true, }                      -- Sunhold Wayshrine
tamrielPois[373] = { xN = 0.236, yN = 0.862, }                      -- Grand Psijic Villa Wayshrine

--------------
-- Murkmire --
tamrielPois[374] = { majorSettlement = true, guildShrine = true, }  -- Lilmoth Wayshrine
tamrielPois[375] = { majorSettlement = true, }                      -- Bright-Throat Wayshrine 
tamrielPois[376] = { majorSettlement = true, }                      -- Dead-Water Wayshrine 
tamrielPois[378] = { groupArena = true, }                           -- Blackrose Prison

------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---- Elsweyr DLC -------- Elsweyr DLC -------- Elsweyr DLC -------- Elsweyr DLC -------- Elsweyr DLC -------- Elsweyr DLC -------- Elsweyr DLC -------- Elsweyr DLC ----
------------------------------------------------------------------------------------------------------------------------------------------------------------------------

----------------------
-- Northern Elsweyr --                 -- Northern Elsweyr 
tamrielPois[381] = { majorSettlement = true, }                      -- Riverhold Wayshrine Wayshrine
tamrielPois[382] = { majorSettlement = true, guildShrine = true, }  -- Rimmen Wayshrine
tamrielPois[383] = { majorSettlement = true, }                      -- The Stitches Wayshrine 
tamrielPois[387] = { majorSettlement = true, }                      -- Hakoshae Wayshrine

----------------------
-- Southern Elsweyr --
--renames["Southern Elsweyr"] = "Southern \nElsweyr"                   -- Southern Elsweyr 
tamrielPois[402] = { majorSettlement = true, guildShrine = true, }  -- Senchal Wayshrine
tamrielPois[405] = { majorSettlement = true, }                      -- Black Heights Wayshrine

--------------
-- Tideholm --
tamrielPois[407] = { majorSettlement = true, }                      -- Dragonguard Sanctum Wayshrine

----------------------------------------------------------------------------------------------------------------------------------------------------------
---- Greymoor DLC -------- Greymoor DLC -------- Greymoor DLC -------- Greymoor DLC -------- Greymoor DLC -------- Greymoor DLC -------- Greymoor DLC ----
----------------------------------------------------------------------------------------------------------------------------------------------------------

--------------------
-- Western Skyrim --
tamrielPois[421] = { majorSettlement = true, guildShrine = true }   -- Solitude Wayshrine
tamrielPois[416] = { majorSettlement = true, }                      -- Morthal Wayshrine
tamrielPois[417] = { majorSettlement = true, }                      -- Morkazgur Wayshrine
tamrielPois[418] = { majorSettlement = true, }                      -- Dragonbridge Wayshrine
tamrielPois[419] = { majorSettlement = true, }                      -- Southern Watch Wayshrine

---------------
-- The Reach --
tamrielPois[445] = { majorSettlement = true, }                      -- Karthwasten Wayshrine
tamrielPois[449] = { majorSettlement = true, guildShrine = true }   -- Markarth Wayshrine
tamrielPois[457] = { soloArena = true, }                            -- Vateshran Hollows

-----------------------------------------------------------------------------------------------------------------------------------------------------------------
---- Blackwood DLC -------- Blackwood DLC -------- Blackwood DLC -------- Blackwood DLC -------- Blackwood DLC -------- Blackwood DLC -------- Blackwood DLC ----
-----------------------------------------------------------------------------------------------------------------------------------------------------------------

---------------
-- Blackwood --
tamrielPois[483] = { majorSettlement = true, } -- Hutan-Tzel Wayshrine
tamrielPois[459] = { majorSettlement = true, } -- Gideon Wayshrine 
tamrielPois[464] = { majorSettlement = true, } -- Stonewastes Wayshrine
tamrielPois[458] = { majorSettlement = true, guildShrine = true } -- Leyawiin Wayshrine

--------------------------------------------------------------------------------------------------------------------------------------------------------
---- High Isle DLC / Firesong DLC -------- High Isle DLC / Firesong DLC -------- High Isle DLC / Firesong DLC -------- High Isle DLC / Firesong DLC ----
--------------------------------------------------------------------------------------------------------------------------------------------------------

--------------------------
-- High Isle and Amenos --
tamrielPois[513] = { majorSettlement = true, guildShrine = true, } -- Gonfalon Square Wayshrine
tamrielPois[508] = { majorSettlement = true, } -- Amenos Station

------------------------
-- Galen and Y'ffelon --
tamrielPois[529] = { majorSettlement = true, guildShrine = true, } -- Vastyr Wayshrine

----------------------------------------------------------------------------------------------------------------------------------------------------------------
---- Necrom DLC -------- Necrom DLC -------- Necrom DLC -------- Necrom DLC -------- Necrom DLC -------- Necrom DLC -------- Necrom DLC -------- Necrom DLC ----
----------------------------------------------------------------------------------------------------------------------------------------------------------------

------------------------
-- Telvanni Peninsula --
tamrielPois[536] = { majorSettlement = true, guildShrine = true, }  -- Necrom Wayshrine
tamrielPois[538] = { majorSettlement = true, }                      -- Ald Isra Wayshrine
tamrielPois[554] = { majorSettlement = true, }                      -- Alavelis Wayshrine

------------------------------------------------------------------------------------------------------------------------------------------
---- Gold Road DLC -------- Gold Road DLC -------- Gold Road DLC -------- Gold Road DLC -------- Gold Road DLC -------- Gold Road DLC ----
------------------------------------------------------------------------------------------------------------------------------------------

----------------
-- West Weald -- 
tamrielPois[558] = { majorSettlement = true, guildShrine = true, }  -- Skingrad Wayshrine
tamrielPois[560] = { majorSettlement = true, }                      -- Vashabar Wayshrine
tamrielPois[561] = { majorSettlement = true, }                      -- Ontus Wayshrine
--tamrielPois[562] = { majorSettlement = true, }                      -- Sutch Wayshrine
--tamrielPois[578] = { majorSettlement = true, }                      -- Ostumir Wayshrine

-- Grand Psijic Villa
tamrielPois[373] = { disabled = true, }

-- Tower of Unutterable Truths
tamrielPois[567] = { disabled = true, }
