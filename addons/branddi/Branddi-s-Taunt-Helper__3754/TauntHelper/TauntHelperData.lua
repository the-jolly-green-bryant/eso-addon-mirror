TauntHelper.TAUNT_LIST_NAME = 1
TauntHelper.TAUNT_LIST_ENDTIME = 2
TauntHelper.TAUNT_LIST_ENABLE = 3
TauntHelper.TAUNT_LIST_LASTSEENTIME = 4 -- last time we saw the add do something
TauntHelper.TAUNT_LIST_IHAVETAUNT = 5 -- if it's me that has taunt
TauntHelper.TAUNT_LIST_STOLENTAUNTTIME = 6 -- time taunt was taken away from you for a specific mob
TauntHelper.TAUNT_LIST_LASTTIMEWASMINE = 7 -- if it's me that has taunt
TauntHelper.TAUNT_LIST_LASTTAUNTLOSTTIME = 8 -- if it's me that has taunt
TauntHelper.TAUNT_LIST_DIED = 9 -- if the mob died
TauntHelper.TAUNT_LIST_TAUNTIMMUNITYENDTIME = 10 -- time when taunt immunity should fade
TauntHelper.TAUNT_LIST_INTERNATIONAL_NAME = 11 -- time when taunt immunity should fade
TauntHelper.TAUNT_LIST_IGNOREUNTILTIME = 12 -- ignore anything from this add until X time (used for cowering)
TauntHelper.TAUNT_LIST_DIFFICULTY = 13 -- nil until a target's difficulty has been identified





--TauntHelper.tantTrackingAllBosses = true -- check for taunt on anything the game considers a boss
--TauntHelper.tantTrackingAllMobs = false -- check for taunt on everything

TauntHelper.TAUNT_TRACKING_ENABLE = 1
TauntHelper.TAUNT_TRACKING_ZONE_1 = 2
TauntHelper.TAUNT_TRACKING_ZONE_2 = 3
TauntHelper.TAUNT_TRACKING_ZONE_3 = 4
TauntHelper.TAUNT_TRACKING_ZONE_4 = 5


-- START LANGUAGE CONVERSION HERE --
-- "Lokkestiiz" -- listed here for CustomSituations
-- "Yolnahkriin" -- listed here for CustomSituations
-- "Nahviintaas" -- listed here for CustomSituations
-- "Lylanar" -- listed here for CustomSituations
-- "Turlassil" -- listed here for CustomSituations
-- "Lord Warden Dusk" -- listed here for CustomSituations
-- "Lord Falgravn" -- listed here for CustomSituations
-- "Lady Thorn" -- listed here for CustomSituations
-- "Magma Incarnate" -- listed here for CustomSituations
-- "Zaan the Scalecaller" -- listed here for CustomSituations
-- "Assembly General" -- listed here for CustomSituations
-- "Captain Numirril" -- listed here for CustomSituations
-- "Foreman Bradiggan" -- listed here for CustomSituations
-- "Arkasis the Mad Alchemist" -- listed here for CustomSituations
-- "Kovan Giryon"



TauntHelper.bossesThatRemoveTauntList = { -- bosses that sheeed taunt mid-combat ie: fly away

    ["Maarselok"]                      = {true , },                      --  Lair of Maarselok (1123),
    ["Gamyne Bandu"]                   = {true , },                      -- FG2

    ["Lord Warden Dusk"]               = {true , },                      -- ICP
    ["Kovan Giryon"]                   = {true , },                      -- BS
    ["Roksa the Warped"]               = {true , },                      -- BS

    ["Allene Pellingare"]              = {true , },                      -- WS2 last bosses
    ["Varaine Pellingare"]             = {true , },                      -- WS2 last bosses
    ["The Scavenging Maw"]             = {true , },                      -- vDOM
    ["Tarcyr"]                         = {true , },                      -- MoS
    ["Corruption of Root"]             = {true , },                      -- ERE
    ["Lord Falgravn"]                  = {true , },                      -- KA
    ["Blood Twilight"]                 = {true , },                      -- MoS

    ["Sarydil"]                        = {true , },                      -- CA
    ["Xalvakka"]                       = {true , },                      -- RG
    ["Magma Incarnate"]                = {true , },                      -- DC
    ["Turlassil"]                      = {true , },                      -- DSR
    ["Lylanar"]                        = {true , },                      -- DSR
    ["Reef Guardian"]                  = {true , },                      -- DSR
    ["Tideborn Taleria"]               = {true , },                      -- DSR
    ["Foreman Bradiggan"]              = {true , },                      -- DSR
    ["Captain Geminus"]                = {true , },                      -- BDV
    ["Ondagore the Mad"]               = {true , },                      -- UG

    ["Corruption of Stone"]            = {true , },                      -- ERE boss 1
    ["The Euphotic Gatekeeper"]        = {true , },                      -- GD
    ["Zelvraak the Unbreathing"]       = {true , },                      -- GD
    ["Hadolid Hullcleaver"]            = {true , },                      --  Graven Deep (1361),
    ["Lokkestiiz"]                     = {true , },                      -- SS
    ["Yolnahkriin"]                    = {true , },                      -- SS

    ["Kujo Kethba"]                    = {true , },                      -- MGF

    ["Sister Maefyn"]                  = {true , },                      --  Icereach (1152),
    ["Sister Hiti"]                    = {true , },                      --  Icereach (1152),
    ["Sister Bani"]                    = {true , },                      --  Icereach (1152),
    ["Sister Gohlla"]                  = {true , },                      --  Icereach (1152),

    ["Phosphorescent Auroran"]         = {true , },                      --  DoM,
    ["Scintillating Auroran"]          = {true , },                      --  DoM,
    ["Blazing Auroran"]                = {true , },                      --  DoM,



}


TauntHelper.bossesThatCastWhenImmuneFromTauntList = { -- add bosses here that would otherwise appear to be loose while unable to be taunted
    ["Maarselok"]                      = {true , },                      --  Lair of Maarselok (1123),
    ["Valinna"]                        = {true , },                      --  SH last boss
    ["Lord Warden Dusk"]               = {true , },                      -- ICP
    ["Roksa the Warped"]               = {true , },                      -- BS
    ["Lizabet Charnis"]                = {true , },                      -- FL first arena boss
    ["Riftmaster Naqri"]               = {true , },                      -- SH boss one seems to attack from multiple IDs
    ["The Scavenging Maw"]             = {true , },                      -- vDOM
    ["Butcher's Fire Shaman"]          = {true , },                      -- vKA seems he isn't taunted after he respawns at exit
    ["Tarcyr"]                         = {true , },                      -- MoS
    ["Balorgh"]                        = {true , },                      -- MoS
    ["Dagrund the Bulky"]              = {true , },                      -- MoS
    ["Blood Twilight"]                 = {true , },                      -- MoS
    ["Lady Thorn"]                     = {true , },                      -- CT
    ["Longclaw"]                       = {true , },                      -- SW
    ["Maligalig"]                      = {true , },                      -- CA boss 1
    ["Sarydil"]                        = {true , },                      -- CA
    ["Magma Incarnate"]                = {true , },                      -- DC
    ["Scorion Collector"]              = {true , },                      -- DC
    ["Turlassil"]                      = {true , },                      -- DSR
    ["Lylanar"]                        = {true , },                      -- DSR
    ["Reef Guardian"]                  = {true , },                      -- DSR
    ["Tideborn Taleria"]               = {true , },                      -- DSR
    ["Foreman Bradiggan"]              = {true , },                      -- DSR
    ["Drowned Hulk"]                   = {true , },                      -- SWR
    ["Deathlord Bjarfrud Skjoralmor"]  = {true , },                      -- FH
    ["Captain Geminus"]                = {true , },                      -- BDV
    ["Ondagore the Mad"]               = {true , },                      -- UG
    ["The Euphotic Gatekeeper"]        = {true , },                      -- GD
    ["Lokkestiiz"]                     = {true , },                      -- SS
    ["Vigil Statue"]                   = {true , },                      -- SS
    ["Kovan Giryon"]                   = {true , },                      -- BS
    ["Rakkhat"]                        = {true , },                      -- vMoL
    ["Kujo Kethba"]                    = {true , },                      -- MGF

    ["Grundwulf"]                      = {true , },                      -- MGF (he doesn't actually die so his taunt will show as expiring when it isn't, this doesn't fix that)


    ["Sister Maefyn"]                  = {true , },                      --  Icereach (1152),
    ["Sister Hiti"]                    = {true , },                      --  Icereach (1152),
    ["Sister Bani"]                    = {true , },                      --  Icereach (1152),
    ["Sister Gohlla"]                  = {true , },                      --  Icereach (1152),
    ["Nahviintaas"]                    = {true , },                      --  SS
    ["Zatzu"]                          = {true , },                      --  RoM
    ["Xit-Xaht Stoneshaper"]           = {true, },                       --  vRoM add appears to send rocks from alternate id
    ["Archwizard Twelvane"]            = {true , },                      --  SE
    --["Daedroth"]                       = {true , },                      --  Monster helm
    ["Flame-Herald Bahsei"]            = {true , },                      --  rg
    ["Khephidaen"]                     = {true , },                      --  CoS
    ["Velidreth"]                      = {true , },                      --  CoS
    ["Kargaeda"]                       = {true , },                      --  CA
    ["Z'Baza"]                         = {true , },                      --  CA last secret
    ["Shade of Belanaril"]             = {true , },                      --  CR
    ["Z'Maja"]                         = {true , },                      --  CR

    ["Tuecille"]                       = {true , },                      --  FH
    ["Erbogar"]                        = {true , },                      --  FH
    ["Mochveda"]                       = {true , },                      --  FH
    ["Rinaerus the Rancid"]            = {true , },                      --  SCP
    ["Ary"]                            = {true , },                      --  Moon Hunter Keep (1052),
    ["Zel"]                            = {true , },                      --  Moon Hunter Keep (1052),
    ["Yokeda Rok'dun"]                 = {true , },                      --  HRC
    ["Gravelight Sentry"]              = {true , },                      --  ICP
    ["Kinras Ironeye"]                 = {true , },                      --  BDV
    ["Arkasis the Mad Alchemist"]      = {true , },                      --  SG
    ["Symphony of Blades"]             = {true , },                      --  DoM

    ["Tho'at Replicanum"]              = {true , },                      --  IA
    ["Tho'at Shard"]                   = {true , },                      --  IA
    ["The Stonekeeper"]                = {true , },                      --  FV


}



-- add to no loose add thing
TauntHelper.tauntNoTrackingList = { -- list of mobs (bosses) to ignore taunt on
["Familiar"]                        = {true, },  -- Added to avoid sorc pets from appearing
["Clannfear"]                       = {true, },                       -- Added to avoid sorc pets from appearing
["Volatile Familiar"]               = {true, },                       -- Added to avoid sorc pets from appearing
["Twilight Tormentor"]              = {true, },                       -- Added to avoid sorc pets from appearing
["Winged Twilight"]                 = {true, },                       -- Added to avoid sorc pets from appearing
["Twilight Matriarch"]              = {true, },                       -- Added to avoid sorc pets from appearing


["Dark Orb"]                       = {true, },                       -- vDoM orb boss
["Cadaverous Senche-Tiger"]        = {true, },                       -- FL untauntable add second boss
["Butcher's Fire Shaman"]          = {true, },                      --  Kyne's Aegis (1196), this does not get taunted first boss vKA
["Sharpened Conduit"]              = {true, },                      --  Kyne's Aegis (1196),
["Daedric Shield"]                 = {true, },                      --  TC arena boss
["Reclaimer"]                      = {true, },                      --  HoF Triplets
["Liramindrel"]                    = {true, },                      --  RPB archer

["Skeletal Spellbinder"]           = {true, },                      --  This appeared in Lokkestiiz not sure where it comes from
["Azureblight Cancroid"]           = {true, },                      --  LoM Tree boss doesn't need to be taunted
["Defense Prism"]                  = {true, },                      --  LC crystals

}



-- add which we do not care about for specific boss fights
TauntHelper.tauntNoTrackingBossFightList = { -- list of mobs to ignore but at least one boss must be listed
["Auroran"]                       = {true, "Symphony of Blades",nil,nil,nil},                       -- vDoM last boss, don't taunt walls
["Radiant Auroran"]                       = {true, "Symphony of Blades",nil,nil,nil},                       -- vDoM last boss, don't taunt walls

["Blazing Salamander"]            = {true, "Kinras Ironeye",nil,nil,nil},                           -- vBDV second boss, don't taunt Salamanders
["Stone Atronach"]                = {true, "Corruption of Stone","Stormfist",nil,nil},              -- vERE first boss, don't taunt Stone Atros                   -- vERE first boss, don't taunt Stone Atros
["Storm Atronach"]                = {true, "Lokkestiiz",nil,nil,nil},                               -- vSS first boss
["Stone Husk"]                    = {true, "Stone Behemoth","Arkasis the Mad Alchemist",nil,nil},   -- vSG second boss
["Haj Mota"]                      = {true, "Mighty Chudan",nil,nil,nil},                            -- vSG second boss
["Bone Colossus"]                 = {true, "Kjalnar Tombskald",nil,nil,nil},                        -- vUG
["Watcher"]                       = {true, "Spawn of Mephala",nil,nil,nil},                         -- vFG2 this appears to be the mob that pulls you into the cave
["Accursed Werewolf"]             = {true, "Vykosa the Ascendant",nil,nil,nil},                     -- Moon Hunter Keep last boss, typically DPS need to kill WWs, but another method is to frost clench them as tank - leaving off taunt list for this reason
["Magma Daedroth"]                = {true, "Baron Zaudrus",nil,nil,nil},                            -- vTC last boss don't taunt adds
["Crystal Atronach"]              = {true, "Orphic Shattered Shard",nil,nil,nil},                   -- vLC



--[18:51] [41584] = {Azureblight Cancroid exp:--.-s enable:true lastSeen:9.7s myTaunt:false stolenTaunt:--.-s }

}

-- mobs for which checking for loose is not good - sisters in icereach for example can be attacked in their shields and therefore listing them as loose is counter productive
TauntHelper.neverCheckForLoose = {
["Sister Maefyn"]                             = {true , },                      --  Icereach (1152),
["Sister Hiti"]                               = {true , },                      --  Icereach (1152),
["Sister Bani"]                               = {true , },                      --  Icereach (1152),
["Sister Gohlla"]                             = {true , },                      --  Icereach (1152),
["Tho'at Shard"]                              = {true , },                      --  AI,
}


TauntHelper.tauntTrackingEverythingInZones = { -- Zones that have not been completed, therefore show tracking of all adds
   --[1478]                              = {true , },                      --  LC (Lucent Citadel)
}

TauntHelper.tauntTrackingList = { -- list of mobs aside from bosses to track taunt on
--["Target Skeleton, Khajiit"] = {true, },  -- testing in house
--["Target Skeleton, Humanoid"] = {true, },  -- testing in house
--["Target Iron Atronach, Trial"] = {true, }, -- testing in house

["Cadaverous Guar"]                = {true , },                      --  Fang Lair (1009),
-- TRASH
["Darkcaster Firestorm"]                      = {true , },                      --  Lucent Citadel (1478),
["Darkcaster Skirmisher"]                     = {true , },                      --  Lucent Citadel (1478),
["Darkcaster Slasher"]                        = {true , },                      --  Lucent Citadel (1478),
["Lightbringer Acolyte"]                      = {true , },                      --  Lucent Citadel (1478),
["Lightbringer Iridescent"]                   = {true , },                      --  Lucent Citadel (1478),
["Lightbringer Radiant"]                      = {true , },                      --  Lucent Citadel (1478),
["Crystal Atronach"]                          = {true , },                      --  Lucent Citadel (1478),

-- RYELAZ
["Count Ryelaz"]                              = {true , },                      --  Lucent Citadel (1478),
["Zilyesset"]                                 = {true , },                      --  Lucent Citadel (1478),
["Gloomy Blackguard"]                         = {true , },                      --  Lucent Citadel (1478),
["Shardborn Lightweaver"]                     = {true , },                      --  Lucent Citadel (1478),
["Mirrormoor Bone Flayer"]                    = {true , },                      --  Lucent Citadel (1478),
["Gloomy Infernium"]                          = {true , },                      --  Lucent Citadel (1478),

-- CAVOT
["Cavot Agnan"]                               = {true , },                      --  Lucent Citadel (1478),

-- ORPHIC
["Orphic Shattered Shard"]                    = {true , },                      --  Lucent Citadel (1478),
["Xoryn"]                                     = {true , },                      --  Lucent Citadel (1478),
["Crystal Hollow Sentinel"]                   = {true , },                      --  Lucent Citadel (1478),
["Ruinach"]                                   = {true , },                      --  Lucent Citadel (1478),

-- KNOT
["Mirrormoor Mantikora"]                      = {true , },                      --  Lucent Citadel (1478),
["Dariel Lemonds"]                            = {true , },                      --  Lucent Citadel (1478),
["Baron Rize"]                                = {true , },                      --  Lucent Citadel (1478),
["Jresazzel"]                                 = {true , },                      --  Lucent Citadel (1478),
["Xynizata"]                                  = {true , },                      --  Lucent Citadel (1478),




["Target Skeleton, Humanoid"]                 = {true , 943},                      --  testing in house Daggerfall Overlook (943),
["Target Skeleton, Robust Khajiit"]           = {true,  943},                       --  testing in house Daggerfall Overlook (943),



["Avalanche"]                                 = {true, },                       --  vFV second to last boss
["Dwarven Centurion"]                         = {true, },                       --  vFV last boss adds
["Coldsnap Ogre"]                             = {true , },                      --  FV
["Coldsnap Toothbreaker"]                     = {true , },                      --  FV
["Thurvokun"]                                 = {true , },                      --  FV
["Rizzuk Bonechill"]                          = {true , },                      --  FV,
["Frost Atronach"]                            = {true , },                      --  FV, vSS, vDSR


["Blood Guardian"]                            = {true, },                       --  vCT last boss add

["Ofallo"]                                    = {true, },                       --  vCA HM last boss bird
["Iliata"]                                    = {true, },                       --  vCA HM last boss bird
["Mafremare"]                                 = {true, },                       --  vCA HM last boss bird
["Kargaeda"]                                  = {true, },                       --  vCA HM last boss bird

["Stone Watcher"]                             = {true, },                       --  vDoM
["Radiant Auroran"]                           = {true, },                       --  vDoM
["Haj Mota"]                                  = {true, },                       --  vRoM/BRP
["Xit-Xaht Stoneshaper"]                      = {true, },                       --  vRoM
["Xit-Xaht Overseer"]                         = {true, },                       --  vRoM
["Swamp Troll"]                               = {true, },                       --  vRoM
["Phantom of Mighty Chudan"]                  = {true, },                       --  vRoM
["Phantom of Xal-Nur"]                        = {true, },                       --  vRoM


["Imperial Dread Knight"]                     = {true , },                      --  Blackrose Prison (1082),
["Imperial Cleaver"]                          = {true , },                      --  Blackrose Prison (1082),

["Dreadhorn Firehide"]                        = {true, },                       --  BRF

["Dreadhorn Earthgorer"]                      = {true, },                       --  BRF

["Nirnblooded Bear"]                          = {true, },                       --  BRF

--["Dreadhorn Harpy"]                           = {true, },                       --  BRF
--["Dreadhorn Harpy"]                           = {true, },                       --  FH

["Dreadhorn Blade-Bearer"]                    = {true, },                       --  BRF



["Dreadhorn Wallbreaker"]                     = {true, },                       --  FH

["Stone Atronach"]                            = {true, },                       --  FH
["Tuecille"]                                  = {true, },                       --  FH
["Mochveda"]                                  = {true, },                       --  FH
["Storm Atronach"]                            = {true, },                       --  FH, vSS
["Dreadhorn Trampler"]                        = {true, },                       --  FH
["Dreadhorn Earthbinder"]                     = {true, },                       --  FH


["Hoarvor"]                                   = {true, 1390},                   --  SH(1390)
["Magma Bear"]                                = {true, },                       --  SH
["Havocrel"]                                  = {true, },                       --  SH
["Iron Atronach"]                             = {true, },                       --  SH, vRG last boss, vDSR
--["Ensnaring Spider"]                          = {true, },                       --  SH
["Flesh Atronach"]                            = {true, },                       --  SH
["Hollow Armor Sentinel"]                     = {true, },                       --  SH
["Cartoklept"]                                = {true, },                       --  SH
["Hollow Armor Duelist"]                      = {true, },                       --  SH


["The Forgotten One"]                         = {true, },                       --  WS2
["Fiendish Nightmare"]                        = {true, },                       --  WS2
["Bone Colossus"]                             = {true, },                       --  WS2
["Uulgarg the Risen"]                         = {true, },                       --  WS2
["Garron the Returned"]                       = {true, },                       --  WS2
-- need to add side boss from WS2


["Wildbriar Bear"]                            = {true, },                       --  MHK

["Blazing Salamander"]                        = {true, },                       --  BDV

["Flame Ogrim"]                               = {true, },                       --  Fang Lair,
["Blackmarrow Revivifier"]                    = {true, },                       --  Fang Lair,
["Blackmarrow Reanimator"]                    = {true, },                       --  Fang Lair,
["Blackmarrow Deathmonger"]                   = {true , },                      --  Fang Lair (1009),


["Bristleback"]                               = {true , },                      --  Endless Archive (1436),
["Fabled Infuser"]                            = {true , },                      --  Endless Archive (1436),
["Ogrim"]                                     = {true , },                      --  Endless Archive (1436),
--["Dremora Ironclad"]                          = {true , },                      --  Endless Archive (1436),
["Marauder Ulmor"]                            = {true , },                      --  Endless Archive (1436),
--["Dremora Blademaster"]                       = {true , },                      --  Endless Archive (1436),
["Daedroth"]                                  = {true , },                      --  Endless Archive (1436), vRG last boss
["Lurcher"]                                   = {true , },                      --  Endless Archive (1436),
["Aramril"]                                   = {true , },                      --  Endless Archive (1436),

["Cadaverous Senche-Tiger"]                   = {true , },                      --  Fang Lair (1009), second boss


["Azureblight Frostmage"]                     = {true , },                      --  Lair of Maarselok (1123),
["Azureblight Corruptor"]                     = {true , },                      --  Lair of Maarselok (1123),
["Azureblight Vitiate"]                       = {true , },                      --  Lair of Maarselok (1123),
["Azureblight Lurcher"]                       = {true , },                      --  Lair of Maarselok (1123),
["Skeletal Bear"]                             = {true , },                      --  Lair of Maarselok (1123),
["Azureblight Infestor"]                      = {true , },                      --  Lair of Maarselok (1123),
["Tenmar Mountain Bear"]                      = {true , },                      --  Lair of Maarselok (1123),


["Hulking Werewolf"]                          = {true , },                      --  Moon Hunter Keep (1052),
["Ary"]                                       = {true , },                      --  Moon Hunter Keep (1052),
["Zel"]                                       = {true , },                      --  Moon Hunter Keep (1052),

["Auroran"]                                   = {true , },                      --  Depths of Malatar (1081), (these are also the names of the walls, cludge implemented to avoid these from appearing during last boss fight)

["Fabled Spellthief"]                         = {true , },                      --  Endless Archive (1436),
["Fabled Flameshaper"]                        = {true , },                      --  Endless Archive (1436),
["Silver Rose Realmshaper"]                   = {true , },                      --  Endless Archive (1436),
["Fabled Sun-Eater"]                          = {true , },                      --  Endless Archive (1436),
["Fabled Totem Master"]                       = {true , },                      --  Endless Archive (1436),
--["Glass Leviathan"]                           = {true , },                      --  Endless Archive (1436),

["Hive Golem"]                                = {true , 919 },                  --  Forgotten Wastes PD (919), -Testing Only

["Scorion Collector"]                         = {true , },                      --  The Dread Cellar (1268),
["Xivilai Ravager"]                           = {true , },                      --  The Dread Cellar (1268),
["Armored Daedroth"]                          = {true , },                      --  The Dread Cellar (1268),
["Marauder Hilkarax"]                         = {true , },                      --  Endless Archive (1436),
["Xivilai Shockslayer"]                       = {true , },                      --  The Dread Cellar (1268),
--["Crimson Oath Toxicator"]                    = {true , },                    --  The Dread Cellar (1268),

["Erbogar"]                                   = {true , },                      --  Falkreath Hold (974),



["Xivkyn Berserker"]                          = {true , },                      --  Imperial City Prison (678),
["Harvester"]                                 = {true , },                      --  Imperial City Prison (678),
["Xivkyn Necromancer"]                        = {true , },                      --  Imperial City Prison (678),
["Vigilant Watcher"]                          = {true , },                      --  Imperial City Prison (678),
["Shade"]                                     = {true , 678},                   --  Imperial City Prison (678),


["Argonian Behemoth"]                         = {true , },                      --  Bal Sunnar (1389),
["Telvanni Sun Mage"]                         = {true , },                      --  Bal Sunnar (1389),
["Primitive Nix-Ox"]                          = {true , },                      --  Bal Sunnar (1389),
["Nix-Ox"]                                    = {true , },                      --  Bal Sunnar (1389),
["Peryite's Glory"]                           = {true , },                      --  Bal Sunnar (1389),


["Thorn Legion Senche-raht"]                  = {true , },                      --  Castle Thorn (1201),


["Sea Adder"]                                 = {true , 1196},                  --  Kyne's Aegis (1196),
["Butcher's Fire Shaman"]                     = {true , },                      --  Kyne's Aegis (1196),
["Half-Giant Raider"]                         = {true , },                      --  Kyne's Aegis (1196),
["Half-Giant Tidebreaker"]                    = {true , },                      --  Kyne's Aegis (1196),
["Half-Giant Sea Shaman"]                     = {true , },                      --  Kyne's Aegis (1196),
["Half-Giant Harpooner"]                      = {true , },                      --  Kyne's Aegis (1196),
["Half-Giant Bulwark"]                        = {true , },                      --  Kyne's Aegis (1196),
["Half-Giant Apothecary"]                     = {true , },                      --  Kyne's Aegis (1196),
["Crimson Knight"]                            = {true , },                      --  Kyne's Aegis (1196),
["Vampire Infuser"]                           = {true , },                      --  Kyne's Aegis (1196),
["Bitter Knight"]                             = {true , },                      --  Kyne's Aegis (1196),
["Lieutenant Njordal"]                        = {true , },                      --  Kyne's Aegis (1196),
["Blood Knight"]                              = {true , },                      --  Kyne's Aegis (1196),
["Torturer"]                                  = {true , },                      --  Kyne's Aegis (1196),
-- i think there's a spot when you go from floor 1 to floor 2 where the taunts drop on Falgraven and might need to be fixed
-- also Lieutenant Njordal appaers untaunted during that phase????





["Bloodscent Guardian"]                       = {true , },                      --  March of Sacrifices (1055),
["Frost Lurcher"]                             = {true , },                      --  March of Sacrifices (1055),
["Bloodscent Thundermaul"]                    = {true , },                      --  March of Sacrifices (1055),
["Blaze Lurcher"]                             = {true , },                      --  March of Sacrifices (1055),
["Bloodscent Assassin"]                       = {true , },                      --  March of Sacrifices (1055),
["Autumn Lurcher"]                            = {true , },                      --  March of Sacrifices (1055),
["Werewolf Brute"]                            = {true , },                      --  March of Sacrifices (1055),
["Budding Lurcher"]                           = {true , },                      --  March of Sacrifices (1055),
["Bear"]                                      = {true , },                      --  March of Sacrifices (1055),
["Sea Lurcher"]                               = {true , },                      --  March of Sacrifices (1055),
["Bloodscent Archer"]                         = {true , },                      --  March of Sacrifices (1055),
["Bloodscent Butcher"]                        = {true , },                      --  March of Sacrifices (1055),




["Distributary"]                              = {true , },                      --  Earthen Root Enclave (1360),
["Trellis Sentinel"]                          = {true , },                      --  Earthen Root Enclave (1360),
["Graft-Root Bear"]                           = {true , },                      --  Earthen Root Enclave (1360),
["Monstrous Bear"]                            = {true , },                      --  Earthen Root Enclave (1360),
["Reanimated Vampire"]                        = {true , },                      --  Castle Thorn (1201),




["Seething Gargoyle"]                         = {true , },                      --  Castle Thorn (1201),
["River Troll"]                               = {true , },                      --  Black Drake Villa (1228),
["Fire Behemoth"]                             = {true , },                      --  Black Drake Villa (1228), RG





["Wraith"]                                    = {true , 1361},                      --  Graven Deep (1361), not the ones from vRG
["Drowned Captain"]                           = {true , },                      --  Graven Deep (1361),
["Flesh Abomination"]                         = {true , },                      --  Graven Deep (1361), vRG


["Coral Crab Broodmother"]                    = {true , },                      --  Coral Aerie (1301),

["Ascendant Defender"]                        = {true , },                      --  Coral Aerie (1301),
["Yaghra Strider"]                            = {true , },                      --  Coral Aerie (1301),
["Gryphon"]                                   = {true , },                      --  Coral Aerie (1301),
["Ascendant Bulwark"]                         = {true , },                      --  Coral Aerie (1301),
["Coral Crab Broodfather"]                    = {true , },                      --  Coral Aerie (1301),



["Xivilai Thresher"]                          = {true , },                      --  The Cauldron (1229),
["Flame Titan"]                               = {true , },                      --  The Cauldron (1229),
["Magma Daedroth"]                            = {true , },                      --  The Cauldron (1229),
["Flame Colossus"]                            = {true , },                      --  The Cauldron (1229),
["Scorching Ogrim"]                           = {true , },                      --  The Cauldron (1229),
["Watcher"]                                   = {true , },                      --  The Cauldron (1229),

["Yaghra Monstrosity"]                        = {true , },                      --  vCR,Coral Aerie (1301),



["Alkosh's Fate"]                             = {true , },                      --  vSS,
["Ruin of Alkosh"]                            = {true , },                      --  vSS,
["Fury of Alkosh"]                            = {true , },                      --  vSS,
["Alkosh's Will"]                             = {true , },                      --  vSS,
["Vigil Statue"]                              = {true , },                      --  vSS,

["Iron Servant"]                              = {true , },                      --  vSS,
["Alkosh's Roar"]                             = {true , },                      --  vSS,

["Havocrel Annihilator"]                      = {true , },                      --  vRG boss 1 add
["Havocrel Barbarian"]                        = {true , },                      --  vRG Ash titan fight
["Havocrel Torchcaster"]                      = {true , },                      --  vRG Ash titan fight
["Havocrel Butcher"]                          = {true , },                      --  vRG trash
["Havocrel Goliath"]                          = {true , },                      --  vRG last boss


["Sul-Xan Soulweaver"]                        = {true , },                      --  vRG trash
["Refabricated Centurion"]                    = {true , },                      --  vHoF second boss add




["Dissector"]                                 = {true , },                      --  vHoF spider boss adds
["Calefactor"]                                = {true , },                      --  vHoF spider boss adds
["Capacitor"]                                 = {true , },                      --  vHoF last boss adds?
["Tactical Facsimile"]                        = {true , },                      --  vHoF last boss adds?




["Coral Drift Senche"]                        = {true , 1344},                      --  vDSR Reef, not the ones in vCA

["Coral Drift Bear"]                          = {true , },                      --  vDSR Reef
["Dreadsail Incendiary"]                      = {true , },                      --  vDSR Reef (healer bring to OT)
["Sea Behemoth"]                              = {true , },                      --  vDSR last boss add

["Contramagis Wamasu"]                        = {true , },                      --  vSE boss 1



["Ascendant Gryphon"]                         = {true , },                      --  vSE boss 1
["Archwizard Twelvane"]                       = {true , },                      --  vSE boss 2
["Ascendant Lion"]                            = {true , },                      --  vSE boss 2
["Ascendant Wamasu"]                          = {true , },                      --  vSE boss 2
["Essence Manifestation"]                     = {true , },                      --  vSE boss 3

["Warlock Vanton"]                            = {true , },                      --  vSE boss 3


["Dro-m'Athra Hulk"]                          = {true , },                      --  vMoL last boss

["Gargoyle"]                                  = {true , },                      --  vHRC last boss
["Conjured Axe"]                              = {true , },                      --  vAA last boss
["S'zarzo the Bulwark"]                       = {true , },                      --  Coral Aerie (1301),

["Sul-Xan Reaver"]                            = {true , },                      --  Rockgrove (1263),
["Sul-Xan Bloodseeker"]                       = {true , },                      --  Rockgrove (1263),
["Spider Matriarch"]                          = {true , },                      --  The Dread Cellar (1268),


["Shade of Z'Maja"]                           = {true , },                      --  Cloudrest (1051),


["Firstmage Overcharger"]                     = {true , },                      --  Aetherian Archive (638),
["Firstmage Nullifier"]                       = {true , },                      --  Aetherian Archive (638),
["Firstmage Chainspinner"]                    = {true , },                      --  Aetherian Archive (638),


["Dreadsail Swashbuckler"]                    = {true , },                      --  Dreadsail Reef (1344),
["Dreadsail Keelcutter"]                      = {true , },                      --  Dreadsail Reef (1344),
["Dreadsail Serpent-Tongue"]                  = {true , },                      --  Dreadsail Reef (1344),
["Dreadsail Ranger"]                          = {true , },                      --  Dreadsail Reef (1344),
["Coral Drift Haj Mota"]                      = {true , },                      --  Dreadsail Reef (1344),
["Dreadsail Brewmaster"]                      = {true , },                      --  Dreadsail Reef (1344),
["Spirit Crab Broodmother"]                   = {true , },                      --  Dreadsail Reef (1344),
["Dreadsail Overseer"]                        = {true , },                      --  Dreadsail Reef (1344),
["Dreadsail Sharpshooter"]                    = {true , },                      --  Dreadsail Reef (1344),
["Gorra"]                                     = {true , },                      --  Shipwright's Regret (1302),
["Swamp Rot"]                                 = {true , },                      --  Shipwright's Regret (1302),

["Drowned Hulk"]                              = {true , },                      --  Shipwright's Regret (1302),
["The Iron-Swathed Glutton"]                  = {true , },                      --  White-Gold Tower (688),
["Xivkyn Bulwark"]                            = {true , },                      --  White-Gold Tower (688),
["Crematorial Guard"]                         = {true , },                      --  White-Gold Tower (688),
["Grievous Twilight"]                         = {true , },                      --  White-Gold Tower (688),
["The Scion of Wroth"]                        = {true , },                      --  White-Gold Tower (688),
["Dremora Kynval"]                            = {true , 176},                      --  City of Ash I (),


["Ironeye Marauder"]                          = {true , },                      --  Black Drake Villa (1228),
["Air Atronach"]                              = {true , },                      --  Black Drake Villa (1228),
["Ironeye Firebrand"]                         = {true , },                      --  Black Drake Villa (1228),

["Draugrkin Brigand"]                         = {true , },                      --  Unhallowed Grave (1153),
["Skeletal Werewolf"]                         = {true , },                      --  Unhallowed Grave (1153),

["Grave Guardian Blademaster"]                = {true , },                      --  Unhallowed Grave (1153),

["Ogre Brute"]                                = {true , },                      --  Scalecaller Peak (1010),
["Corrupted Leimenid"]                        = {true , },                      --  Scalecaller Peak (1010),
["Mortieu's Guard"]                           = {true , },                      --  Scalecaller Peak (1010),
["Ogre Elder"]                                = {true , },                      --  Scalecaller Peak (1010),
["Giant"]                                     = {true , },                      --  Scalecaller Peak (1010),



["Fighters Guild Gladiator"]                  = {true , },                      --  Dragonstar Arena (635),
["Troll"]                                     = {true , },                      --  Dragonstar Arena (635),
["Fighters Guild Swordmaster"]                = {true , },                      --  Dragonstar Arena (635),
["Sovngarde Icemage"]                         = {true , },                      --  Dragonstar Arena (635),
["Sovngarde Slayer"]                          = {true , },                      --  Dragonstar Arena (635),

["Wamasu"]                                    = {true , },                      --  Dragonstar Arena (635),



["House Dres Enslaver"]                       = {true , },                      --  Dragonstar Arena (635),
["Anka-Ra Shadowcaster"]                      = {true , },                      --  Dragonstar Arena (635),
["Anka-Ra Blademaster"]                       = {true , },                      --  Dragonstar Arena (635),


["Spider Daedra"]                             = {true , },                      --  Dragonstar Arena (635),
["Summoned Titan"]                            = {true , },                      --  Dragonstar Arena (635),
["Summoned Harvester"]                        = {true , },                      --  Dragonstar Arena (635),

["Charged Centurion"]                         = {true , },                      --  Dragonstar Arena (635),
["Dwarven Ice Centurion"]                     = {true , },                      --  Dragonstar Arena (635),
["Dwarven Fire Centurion"]                    = {true , },                      --  Dragonstar Arena (635),

["Champion Marcauld"]                         = {true , },                      --  Dragonstar Arena (635),
["Zackael Jonnicent"]                         = {true , },                      --  Dragonstar Arena (635),
["Mavus Talnarith"]                           = {true , },                      --  Dragonstar Arena (635),

["Sea Viper Strongarm"]                       = {true , },                      --  TI
["Hadolid Hullcleaver"]                       = {true , },                      --  Graven Deep (1361),
["Jone's Gale-Claw"]                          = {true , },                      --  Sunspire (1121),
["Jode's Fire-Fang"]                          = {true , },                      --  Sunspire (1121),


["Draining Scrib"]                            = {true , },                      --  Darkshade Caverns II (930),

["Liramindrel"]                               = {true , },                      --  Red Petal Bastion (1267),
["Chaos Spider"]                              = {true , },                      --  Red Petal Bastion (1267),
["Ihudir"]                                    = {true , },                      --  Red Petal Bastion (1267),
["Engine Garrison's Centurion"]               = {true , },                      --  Darkshade Caverns II (930),



["Will of Vashai"]                            = {true , },                      --  Maw of Lorkhaj (725), boss 2 adds
["Rage of S'Kinrai"]                          = {true , },                      --  Maw of Lorkhaj (725), boss 2 adds



["Hollowfang Dire-Maw"]                       = {true , },                      --  Moongrave Fane (1122),
["Moongrave Sentinel"]                        = {true , },                      --  Moongrave Fane (1122),
--["Hemonculous"]                               = {true , },                      --  Moongrave Fane (1122), shield bat things not sure if its best to be on here or not

["Strangler"]                                 = {true , 1152 },                 --  Icereach (1152),
["Sister Maefyn"]                             = {true , },                      --  Icereach (1152),
["Sister Hiti"]                               = {true , },                      --  Icereach (1152),
["Sister Bani"]                               = {true , },                      --  Icereach (1152),
["Sister Gohlla"]                             = {true , },                      --  Icereach (1152),

["Alchemized Werewolf"]                       = {true , },                      --  Stone Garden (1197),
["Werewolf"]                                  = {true , },                      --  Stone Garden (1197),
["Bloodknight"]                               = {true , },                      --  Stone Garden (1197),
["Werewolf Packleader"]                       = {true , },                      --  Stone Garden (1197),
["Stone Husk"]                                = {true , },                      --  Stone Garden (1197),

["Alchemized Bristleback"]                    = {true , },                      --  Stone Garden (1197),
["Alchemized Chaurus"]                        = {true , },                      --  Stone Garden (1197),
["Alchemized Durzog"]                         = {true , },                      --  Stone Garden (1197),

["Accursed Werewolf"]                         = {true , },                      --  Moon Hunter Keep (1052),
["Werewolf Bloodcaller"]                      = {true , },                      --  Moon Hunter Keep (1052),
["Vicious Dire Wolf"]                         = {true , },                      --  Moon Hunter Keep (1052),
["Werewolf Behemoth"]                         = {true , },                      --  Moon Hunter Keep (1052),
["Werewolf Berserker"]                        = {true , },                      --  Moon Hunter Keep (1052),

["Senche-Raht"]                               = {true , },                      --  Sunspire (1121),

["Hollow One"]                                = {true , },                      --  Sanity's Edge (1427),
["Ansuul's Disruptor"]                        = {true , },                      --  Sanity's Edge (1427),
["Ansuul's Voidmaster"]                       = {true , },                      --  Sanity's Edge (1427),
["Ansuul's Wamasu"]                           = {true , },                      --  Sanity's Edge (1427),
["Ansuul's Enforcer"]                         = {true , },                      --  Sanity's Edge (1427),
["Contramagis Militia Infantry"]              = {true , },                      --  Sanity's Edge (1427),
["Contramagis Militia Butcher"]               = {true , },                      --  Sanity's Edge (1427),
["Ansuul's Summoner"]                         = {true , },                      --  Sanity's Edge (1427),
["Ansuul's Butcher"]                          = {true , },                      --  Sanity's Edge (1427),
["Ansuul's Gryphon"]                          = {true , },                      --  Sanity's Edge (1427),
["Dynamagis Voidmaster"]                      = {true , },                      --  Sanity's Edge (1427),
["Paranoxia"]                                 = {true , },                      --  Sanity's Edge (1427),
["Spiral Incarnate"]                          = {true , },                      --  Sanity's Edge (1427),
["Contramagis Militia Enforcer"]              = {true , },                      --  Sanity's Edge (1427),
["Dynamagis Disruptor"]                       = {true , },                      --  Sanity's Edge (1427),

["Serpent War-Priest"]                        = {true , },                      --  Sanctum Ophidia (639),
["Mantikora"]                                 = {true , },                      --  Sanctum Ophidia (639),
["Serpent Fang"]                              = {true , },                      --  Sanctum Ophidia (639),
["Rockheaver Troll"]                          = {true , },                      --  Sanctum Ophidia (639),
["Scaled Court Overcharger"]                  = {true , },                      --  Sanctum Ophidia (639),

["Daedric Lurcher"]                           = {true , },                      --  Elden Hollow II (931),

["Allene Pellingare"]                         = {true , },                      --  Wayrest Sewers I (146), last boss didn't appear as boss for some reason

["Soul of Void"]                              = {true , },                      --  Blackrose Prison (1082),
["Vengeful Revenant"]                         = {true , },                      --  Blackrose Prison (1082),
["Resurrected Prisoner"]                      = {true , },                      --  Blackrose Prison (1082),

["Shade of Galenwe"]                          = {true , },                      --  Cloudrest (1051),
["Shade of Siroria"]                          = {true , },                      --  Cloudrest (1051),
["Shade of Relequen"]                         = {true , },                      --  Cloudrest (1051),

["Crocodile"]                                 = {true , 1082 },                 --  Blackrose Prison (1082),
["Cold Mage"]                                 = {true ,  },                     --  Blackrose Prison (1082),
["Infuser"]                                   = {true ,  },                     --  Blackrose Prison (1082),
["Beastmaster Handler"]                       = {true ,  },                     --  Blackrose Prison (1082),


["Swarm Mother Nightmare"]                    = {true , },                      --  Spindleclutch II (936),
["The Whisperer Nightmare"]                   = {true , },                      --  Spindleclutch II (936),

["Dro-m'Athra Sun-Eater"]                     = {true , },                      --  Maw of Lorkhaj (725),
["Dro-m'Athra Dreadstalker"]                  = {true , },                      --  Maw of Lorkhaj (725),
["Ogre Flesh-Render"]                         = {true , },                      --  Maw of Lorkhaj (725),
["Dro-m'Athra Savage"]                        = {true , },                      --  Maw of Lorkhaj (725),
["Ogre Shaman"]                               = {true , },                      --  Maw of Lorkhaj (725),
["Dro-m'Athra Shadowguard"]                   = {true , },                      --  Maw of Lorkhaj (725),

["Chamber Guardian"]                          = {true , },                      --  Crypt of Hearts II (932),
["Nerien'eth"]                                = {true , },                      --  Crypt of Hearts II (932),

["Frost Troll"]                               = {true , },                      --  Direfrost Keep (449),


["Anka-Ra War-Priest"]                        = {true , },                      --  Hel Ra Citadel (636),
["Anka-Ra Flame-Shaper"]                      = {true , },                      --  Hel Ra Citadel (636),
["Armored Welwa"]                             = {true , },                      --  Hel Ra Citadel (636),
["Enraging Welwa"]                            = {true , },                      --  Hel Ra Citadel (636),
["Anka-Ra Destroyer"]                         = {true , },                      --  Hel Ra Citadel (636),

["Ascendant Thundermaul"]                     = {true , },                      --  Coral Aerie (1301),



["Spirit Reef Viper"]                         = {true , },                      --  Dreadsail Reef (1344),
["Reef Viper"]                                = {true , },                      --  Dreadsail Reef (1344),
["Dreadsail Venom Evoker"]                    = {true , },                      --  Dreadsail Reef (1344),
["Coral Crab Broodlord"]                      = {true , },                      --  Dreadsail Reef (1344),
["Alit"]                                      = {true , },                      --  Elden Hollow I (126),

--["Songstress' Snake"]                         = {true , },                      --  Arx Corinium (148), (do you taunt baby snake?)

["Malubeth the Scourger"]                     = {true , },                      --  Wayrest Sewers II (933),
["Skull Reaper"]                              = {true , },                      --  Wayrest Sewers II (933),


["Lamia Howler"]                              = {true , },                      --  Sanctum Ophidia (639), vso last boss do we taunt these?
["Flame Atronach"]                            = {true , 638, 1121},                      --  Aetherian Archive (638), + Sunspire




["Skeletal Spellbinder"]                      = {true , },                      --  Unhallowed Grave (1153),
["Maiden's Fear"]                             = {true , },                      --  Shipwright's Regret (1302),
["Maiden's Fury"]                             = {true , },                      --  Shipwright's Regret (1302),
["Maiden's Wrath"]                            = {true , },                      --  Shipwright's Regret (1302),
["Flesh Colossus"]                            = {true , },                      --  Shipwright's Regret (1302),


["Phosphorescent Auroran"]                    = {true , },                      --  Depths of Malatar (1081),
["Blazing Auroran"]                           = {true , },                      --  Depths of Malatar (1081),

["Blind Path Hollow Sentinel"]                = {true , },                      --  Bedlam Veil (1471),
["Great Bear"]                                = {true , },                      --  Oathsworn Pit (1470),
["Troll Breaker"]                             = {true , },                      --  Bedlam Veil (1471),


["Champion of Atrocity"]                      = {true , },                      --  Bedlam Veil (1471),
["Maxus the Many"]                            = {true , },                      --  Bedlam Veil (1471),
["Void Lurcher"]                              = {true , },                      --  Bedlam Veil Boss 2 (1471),



["Nilborwen"]                                 = {true , },                      --  Oathsworn Pit (1470),
["Faenalir"]                                  = {true , },                      --  Oathsworn Pit (1470),
["Maerolor"]                                  = {true , },                      --  Oathsworn Pit (1470),

["Golden Indrik"]                             = {true , },                      --  March of Sacrifices (1055), - side bosses

["Icereach Warrior"]                          = {true , },                      --  Icereach (1152),
["Gohlla's Giant"]                            = {true , },                      --  Icereach (1152),


} --- END TO TauntHelper.tauntTrackingList = {


-- END LANGUAGE CONVERSION HERE --



TauntHelper.reticleOverUnitId = 0




TauntHelper.tauntList = {}
-- [unitId] = {"Name", endTime, TrackMob?, lastSeenTime, iHaveTaunt, tauntStolenTime}


function TauntHelper.isMobLoosableForCurrentZone (mobName, mobAttackedPlayer, internationalName)
    -- mobAttackedPlayer is boolean and determines if the detection was casued by the mob casting against a player
    -- when false the detection was made because a player attacked the mob


    -- if disabled we will not do any loose mob detection
    if TauntHelper.savedVars.detectSpawnedAdds == false and TauntHelper.auditMode == false then
        return false
    end

    -- any mob in this list will not be reported as loose if it attacks a player (as it might be immune from taunt or in a long animation which does not require taunt)
    if TauntHelper.bossesThatCastWhenImmuneFromTauntList[mobName] and TauntHelper.bossesThatCastWhenImmuneFromTauntList[mobName][1] and mobAttackedPlayer then
        return false
    end

    -- if mob is not trackable, it is not looseable
    if TauntHelper.isMobTrackableForCurrentZone (mobName, internationalName) == false then
        return false
    end

    return true
end



function TauntHelper.isMobTrackableForCurrentZone (mobName, internationalName)

    local zone, wX, wY, wZ = GetUnitRawWorldPosition( "player" )
    if TauntHelper.tauntTrackingEverythingInZones[zone]~=nil and TauntHelper.tauntTrackingEverythingInZones[zone][1]==true then
        return true -- for zones that have not been completed
    end

    -- do not return certain mobs ever
    if TauntHelper.tauntNoTrackingList[mobName] and TauntHelper.tauntNoTrackingList[mobName][1] then
        if TauntHelper.tauntNoTrackingList[mobName][2]==nil or TauntHelper.tauntNoTrackingList[mobName][2]==zone then
            return false
        elseif TauntHelper.tauntNoTrackingList[mobName][3]==zone then
            return false
        elseif TauntHelper.tauntNoTrackingList[mobName][4]==zone then
            return false
        elseif TauntHelper.tauntNoTrackingList[mobName][5]==zone then
            return false
        end
    end


    -- do not return certain mobs for specific boss fights
    if TauntHelper.tauntNoTrackingBossFightList[mobName] and TauntHelper.tauntNoTrackingBossFightList[mobName][1] then
        if TauntHelper.tauntNoTrackingBossFightList[mobName][2]==TauntHelper.getEnglishNameForInternationalName(zo_strformat("<<1>>",GetUnitName("boss1"))) then
            return false
        elseif TauntHelper.tauntNoTrackingBossFightList[mobName][3]==TauntHelper.getEnglishNameForInternationalName(zo_strformat("<<1>>",GetUnitName("boss1"))) then
            return false
        elseif TauntHelper.tauntNoTrackingBossFightList[mobName][4]==TauntHelper.getEnglishNameForInternationalName(zo_strformat("<<1>>",GetUnitName("boss1"))) then
            return false
        elseif TauntHelper.tauntNoTrackingBossFightList[mobName][5]==TauntHelper.getEnglishNameForInternationalName(zo_strformat("<<1>>",GetUnitName("boss1"))) then
            return false
        end
    end


    -- returning all mobs
    if TauntHelper.savedVars.tantTrackingAllMobs then
        return true
    end


    -- check for important adds specific zones
    if TauntHelper.tauntTrackingList[mobName] and TauntHelper.tauntTrackingList[mobName][1] then
        if TauntHelper.tauntTrackingList[mobName][2]==nil or TauntHelper.tauntTrackingList[mobName][2]==zone then
            return true
        elseif TauntHelper.tauntTrackingList[mobName][3]==zone then
            return true
        elseif TauntHelper.tauntTrackingList[mobName][4]==zone then
            return true
        elseif TauntHelper.tauntTrackingList[mobName][5]==zone then
            return true
        end
    end

    -- check if boss
    if TauntHelper.savedVars.tantTrackingAllBosses then
        if internationalName==zo_strformat("<<1>>",GetUnitName("boss1")) then
            return true
        elseif internationalName==zo_strformat("<<1>>",GetUnitName("boss2")) then
            return true
        elseif internationalName==zo_strformat("<<1>>",GetUnitName("boss3")) then
            return true
        elseif internationalName==zo_strformat("<<1>>",GetUnitName("boss4")) then
            return true
        elseif internationalName==zo_strformat("<<1>>",GetUnitName("boss5")) then
            return true
        end
    end


    -- if none of the above, just return false
    return false
end


function TauntHelper.createOrGetTauntListEntry(unitId, name, internationalName)
    if name == nil then
        name = ""
    end
    if TauntHelper.tauntList[unitId]==nil then
        TauntHelper.tauntList[unitId]={name,0,false,0,false,0,false,0, false, 0, internationalName, 0, nil}
    else
        if name~="" then
            TauntHelper.tauntList[unitId][TauntHelper.TAUNT_LIST_NAME]=name
        end
        if internationalName ~= "" then
            TauntHelper.tauntList[unitId][TauntHelper.TAUNT_LIST_INTERNATIONAL_NAME]=internationalName
        end
    end
    return TauntHelper.tauntList[unitId]
end



function TauntHelper.loadCustomLists()
    for name, data in pairs(TauntHelper.savedVars.customTrackingList) do
        local enable = data[TauntHelper.TAUNT_TRACKING_ENABLE]
        local zone1 = data[TauntHelper.TAUNT_TRACKING_ZONE_1]
        local zone2 = data[TauntHelper.TAUNT_TRACKING_ZONE_2]
        local zone3 = data[TauntHelper.TAUNT_TRACKING_ZONE_3]
        local zone4 = data[TauntHelper.TAUNT_TRACKING_ZONE_4]


        if TauntHelper.tauntTrackingList[name]==nil then
            TauntHelper.tauntTrackingList[name]={}
        end
        TauntHelper.tauntTrackingList[name][TauntHelper.TAUNT_TRACKING_ENABLE]=enable

        if TauntHelper.tauntTrackingList[name][TauntHelper.TAUNT_TRACKING_ZONE_1]==nil then
            -- if this is true then its valid in all zones so leave it this way
        elseif TauntHelper.tauntTrackingList[name][TauntHelper.TAUNT_TRACKING_ZONE_2]==nil then
            TauntHelper.tauntTrackingList[name][TauntHelper.TAUNT_TRACKING_ZONE_2]=zone1
            TauntHelper.tauntTrackingList[name][TauntHelper.TAUNT_TRACKING_ZONE_3]=zone2
            TauntHelper.tauntTrackingList[name][TauntHelper.TAUNT_TRACKING_ZONE_4]=zone3
        elseif TauntHelper.tauntTrackingList[name][TauntHelper.TAUNT_TRACKING_ZONE_3]==nil then
            TauntHelper.tauntTrackingList[name][TauntHelper.TAUNT_TRACKING_ZONE_3]=zone1
            TauntHelper.tauntTrackingList[name][TauntHelper.TAUNT_TRACKING_ZONE_4]=zone2
        elseif TauntHelper.tauntTrackingList[name][TauntHelper.TAUNT_TRACKING_ZONE_4]==nil then
            TauntHelper.tauntTrackingList[name][TauntHelper.TAUNT_TRACKING_ZONE_4]=zone1
        end
	end
end



function TauntHelper.GetNameForZone(zone)
    if not zone then return end

    local zoneName = ""
    local libZone = LibZone
    if libZone ~= nil then
        zoneName = libZone:GetZoneName(zone, "en")
    else
        if TauntHelper.savedVars.debugToChat then d("TauntHelper: LibZone Missing") end
    end
    if zoneName == "" then
        zoneName = "Unknown"
    end
    return zoneName
end



function TauntHelper.addCurrentTargetToTrackedMobLists()
    if TauntHelper.currentLanguage ~= "en" then
        return
    end

    local name = zo_strformat("<<1>>",GetUnitName("reticleover"))

    if name == "" then return end


    if TauntHelper.savedVars.seenMobsTrackingList[name]==nil then

        local difficulty = GetUnitDifficulty("reticleover")
        --MONSTER_DIFFICULTY_NONE    0
        --MONSTER_DIFFICULTY_EASY    1
        --MONSTER_DIFFICULTY_NORMAL  2
        --MONSTER_DIFFICULTY_HARD    3
        --MONSTER_DIFFICULTY_DEADLY  4

        local zone, wX, wY, wZ = GetUnitRawWorldPosition( "player" )

        TauntHelper.savedVars.seenMobsTrackingList[name]={}
        TauntHelper.savedVars.seenMobsTrackingList[name][1] = difficulty
        TauntHelper.savedVars.seenMobsTrackingList[name][2] = zone
    end

end


function TauntHelper.addCurrentTargetToCustomLists()

    if TauntHelper.currentLanguage ~= "en" then
        d("TauntHelper.addCurrentTargetToCustomLists() is a development tool which in English")
        return
    end

    local name = zo_strformat("<<1>>",GetUnitName("reticleover"))
    --d("GetUnitDifficulty():", GetUnitDifficulty("reticleover"))


    --local zid = GetCurrentMapZoneIndex()
    local zone, wX, wY, wZ = GetUnitRawWorldPosition( "player" )
    if name ~= "" then

        --if TauntHelper.ValidForTrackingEntryAndZone(TauntHelper.tauntTrackingList[name], zone) == false then -- only proceed if the mob is not valid for the current zone
        if TauntHelper.isMobTrackableForCurrentZone(name,name) == false then -- only proceed if the mob is not valid for the current zone
            if TauntHelper.savedVars.customTrackingList[name] == nil then
                TauntHelper.savedVars.customTrackingList[name]={}
                TauntHelper.savedVars.customTrackingList[name][TauntHelper.TAUNT_TRACKING_ENABLE] = true
                TauntHelper.savedVars.customTrackingList[name][TauntHelper.TAUNT_TRACKING_ZONE_1]=zone
                d("TauntTracker: Added mob: " .. name )
                TauntHelper.loadCustomLists()
                for unitId, tauntDetails in pairs(TauntHelper.tauntList) do -- update existing taunts
                    if TauntHelper.tauntList[TauntHelper.TAUNT_LIST_NAME]==name and TauntHelper.tauntList[TauntHelper.TAUNT_LIST_ENDTIME]>GetGameTimeMilliseconds() then
                        TauntHelper.tauntList[TauntHelper.TAUNT_LIST_ENABLE]=true
                    end
                end
            else
                if TauntHelper.savedVars.customTrackingList[name][TauntHelper.TAUNT_TRACKING_ZONE_1]~=nil and TauntHelper.savedVars.customTrackingList[name][TauntHelper.TAUNT_TRACKING_ZONE_1]~= zone and TauntHelper.savedVars.customTrackingList[name][TauntHelper.TAUNT_TRACKING_ZONE_2]~= zone and TauntHelper.savedVars.customTrackingList[name][TauntHelper.TAUNT_TRACKING_ZONE_3]~= zone and TauntHelper.savedVars.customTrackingList[name][TauntHelper.TAUNT_TRACKING_ZONE_4]~= zone then
                    if TauntHelper.savedVars.customTrackingList[name][TauntHelper.TAUNT_TRACKING_ZONE_1]==nil  then
                        TauntHelper.savedVars.customTrackingList[name][TauntHelper.TAUNT_TRACKING_ZONE_1]=zone
                        d("TauntTracker: Added mob zone1: " .. name )
                    elseif TauntHelper.savedVars.customTrackingList[name][TauntHelper.TAUNT_TRACKING_ZONE_2]==nil then
                        TauntHelper.savedVars.customTrackingList[name][TauntHelper.TAUNT_TRACKING_ZONE_2]=zone
                        d("TauntTracker: Added mob zone2: " .. name )
                    elseif TauntHelper.savedVars.customTrackingList[name][TauntHelper.TAUNT_TRACKING_ZONE_3]==nil then
                        TauntHelper.savedVars.customTrackingList[name][TauntHelper.TAUNT_TRACKING_ZONE_3]=zone
                        d("TauntTracker: Added mob zone3: " .. name )
                    elseif TauntHelper.savedVars.customTrackingList[name][TauntHelper.TAUNT_TRACKING_ZONE_4]==nil then
                        TauntHelper.savedVars.customTrackingList[name][TauntHelper.TAUNT_TRACKING_ZONE_4]=zone
                        d("TauntTracker: Added mob zone4: " .. name )
                    end
                else
                    d("TauntTracker: Did not add mob already in personal list and valid for zone: " .. name )
                end
            end
        end
    end
end


-- /thprint
function TauntHelper.printToCustomLists()
    d("----------- START TauntHelper.printToCustomLists() -----------")

    for name, data in pairs(TauntHelper.savedVars.customTrackingList) do
        local value = "true "
        if data[TauntHelper.TAUNT_TRACKING_ENABLE] == false then
            value = "false"
        end
        local zone1 = data[TauntHelper.TAUNT_TRACKING_ZONE_1]
        local zone2 = data[TauntHelper.TAUNT_TRACKING_ZONE_2]
        local zone3 = data[TauntHelper.TAUNT_TRACKING_ZONE_3]
        local zone4 = data[TauntHelper.TAUNT_TRACKING_ZONE_4]
        local zoneNumbers = ""
        local zoneNames = ""


        if zone1 ~= nil then
            zoneNumbers = string.format('%s %i,',  zoneNumbers,zone1 )
            zoneNames =  string.format('%s %s (%i),',  zoneNames,TauntHelper.GetNameForZone(zone1),zone1)
        end
        if zone2 ~= nil then
            zoneNumbers = string.format('%s %i,',  zoneNumbers,zone2 )
            zoneNames =  string.format('%s %s (%i),',  zoneNames,TauntHelper.GetNameForZone(zone2),zone2)
        end
        if zone3 ~= nil then
            zoneNumbers = string.format('%s %i,',  zoneNumbers,zone3 )
            zoneNames =  string.format('%s %s (%i),',  zoneNames,TauntHelper.GetNameForZone(zone3),zone3)
        end
        if zone4 ~= nil then
            zoneNumbers = string.format('%s %i,',  zoneNumbers,zone4 )
            zoneNames =  string.format('%s %s (%i),',  zoneNames,TauntHelper.GetNameForZone(zone4),zone4)
        end
        zoneNumbers = "" -- clearing zone numbers we won't use them for now, just text descriptions

        local addSpaces = ""
        for i=string.len(name), 40 do
            addSpaces = string.format('%s ',  addSpaces)
        end

        local addSpaces2 = ""
        for i=string.len(zoneNumbers), 20 do
            addSpaces2 = string.format('%s ',  addSpaces2)
        end



        d(string.format('["%s"]%s = {%s, %s}, %s-- %s', name, addSpaces, value, zoneNumbers, addSpaces2, zoneNames))
	end
	d("----------- END TauntHelper.printToCustomLists() -----------")
end







-- /thclear
function TauntHelper.clearCustomLists()
    d("TauntHelper.clearCustomLists()")
    TauntHelper.savedVars.customTrackingList={}
    --d("TauntHelper: personal tracking List was cleared")
end


-- /thdump
function TauntHelper.dumpTauntLists()
    if TauntHelper.currentLanguage ~= "en" then
        d("TauntHelper.addCurrentTargetToCustomLists() is a development tool which in English")
        return
    end
    d("TauntHelper.dumpTauntLists()")
    for unitId, tauntDetails in pairs(TauntHelper.tauntList) do
        local name = tauntDetails[TauntHelper.TAUNT_LIST_NAME]
        local expiresInS = (tauntDetails[TauntHelper.TAUNT_LIST_ENDTIME]-GetGameTimeMilliseconds())/1000
        if expiresInS<-60 then
            expiresInS="--.-"
        else
            expiresInS = string.format('%.1f', expiresInS)
        end


        local enabled = "false"
        if tauntDetails[TauntHelper.TAUNT_LIST_ENABLE] then
            enabled="true"
        end

        local lastSeenAgo = (GetGameTimeMilliseconds()-tauntDetails[TauntHelper.TAUNT_LIST_LASTSEENTIME])/1000
        if lastSeenAgo>60 then
            lastSeenAgo = "--.-"
        else
            lastSeenAgo = string.format('%.1f', lastSeenAgo)
        end

        local iHaveTaunt = "false"
        if tauntDetails[TauntHelper.TAUNT_LIST_IHAVETAUNT] then
            iHaveTaunt="true"
        end


        local stolenTauntAgo = (GetGameTimeMilliseconds()-tauntDetails[TauntHelper.TAUNT_LIST_STOLENTAUNTTIME])/1000
        if stolenTauntAgo>15 then
            stolenTauntAgo = "--.-"
        else
            stolenTauntAgo = string.format('%.1f', stolenTauntAgo)
        end


        d("["..unitId .."] = {"..name .. " exp:"..expiresInS .."s enable:"..enabled  .. " lastSeen:"..lastSeenAgo.."s myTaunt:"..iHaveTaunt.." stolenTaunt:"..stolenTauntAgo.."s }")

    end
end

function TauntHelper.getEnglishNameForInternationalName(name)
    local convertedName = ""
    if TauntHelper.currentLanguage == "en" then
        return name
    elseif TauntHelper.currentLanguage == "fr" then
        convertedName = TauntHelper.langs.fr[name]
    elseif TauntHelper.currentLanguage == "es" then
        convertedName = TauntHelper.langs.es[name]
    elseif TauntHelper.currentLanguage == "jp" then
        convertedName = TauntHelper.langs.jp[name]
    elseif TauntHelper.currentLanguage == "de" then
        convertedName = TauntHelper.langs.de[name]
    elseif TauntHelper.currentLanguage == "zh" then
        convertedName = TauntHelper.langs.zh[name]
    end
    if convertedName == nil then
        return name
    else
        return convertedName
    end

end