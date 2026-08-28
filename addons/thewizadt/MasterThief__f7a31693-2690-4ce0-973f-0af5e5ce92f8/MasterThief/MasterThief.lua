MasterThief = MasterThief or {}
MasterThief.name = "MasterThief"

MasterThief.defaultSettings = {
    showHUD = true,
    backgroundAlpha = 75,
    showMotifs = true,
    showPlans = true,
    fontSize = 11,
    posX = 60,
    posY = 100,
    debugMode = true,
    autoDestroyWhiteJunk = false,
    rareDropAlerts = true,
    charStats = {},
}

MasterThief.ZoneMotifMap = {
    -- Base Game Alliances & Zones
    ["stonefalls"] = { name = "Pact Styles (Ebonheart, Redoran, Hlaalu, Telvanni)", trialDungeon = "Zone: Stonefalls" },
    ["deshaan"] = { name = "Pact Styles / Mother's Sorrow", trialDungeon = "Zone: Deshaan" },
    ["shadowfen"] = { name = "Pact Styles / Swamp", trialDungeon = "Zone: Shadowfen" },
    ["eastmarch"] = { name = "Pact Styles / Nord", trialDungeon = "Zone: Eastmarch" },
    ["the rift"] = { name = "Pact Styles / Riften", trialDungeon = "Zone: The Rift" },
    
    ["glenumbra"] = { name = "Covenant Styles (Breton, Daggerfall)", trialDungeon = "Zone: Glenumbra" },
    ["stormhaven"] = { name = "Covenant Styles / Wayrest", trialDungeon = "Zone: Stormhaven" },
    ["rivenspire"] = { name = "Covenant Styles / Shornhelm", trialDungeon = "Zone: Rivenspire" },
    ["alik'r desert"] = { name = "Covenant Styles / Redguard", trialDungeon = "Zone: Alik'r Desert" },
    ["auridon"] = { name = "Dominion Styles (Altmer, Vulkhel Guard)", trialDungeon = "Zone: Auridon" },
    ["grahtwood"] = { name = "Dominion Styles / Bosmer", trialDungeon = "Zone: Grahtwood" },
    ["greenshade"] = { name = "Dominion Styles / Marbruk", trialDungeon = "Zone: Greenshade" },
    ["malabal tor"] = { name = "Dominion Styles / Silvenar", trialDungeon = "Zone: Malabal Tor" },
    ["reaper's march"] = { name = "Dominion Styles / Khajiit", trialDungeon = "Zone: Reaper's March" },

    ["craglorn"] = { name = "Ancient Orc / Yokudan Style", trialDungeon = "Zone: Craglorn" },
    ["coldharbour"] = { name = "Xivkyn / Hollow City Style", trialDungeon = "Zone: Coldharbour" },

    -- Chapters & DLC Zones
    ["wrothgar"] = { name = "Trinimac & Ancient Orc Style", trialDungeon = "DLC: Orsinium (Wrothgar)" },
    ["hew's bane"] = { name = "Abah's Watch Style", trialDungeon = "DLC: Thieves Guild (Hew's Bane)" },
    ["gold coast"] = { name = "Assassins League & Silken Ring", trialDungeon = "DLC: Dark Brotherhood (Gold Coast)" },
    ["vvardenfell"] = { name = "Morag Tong & Ashlander Styles", trialDungeon = "Chapter: Morrowind" },
    ["clockwork city"] = { name = "Apostle & Clockwork Styles", trialDungeon = "DLC: Clockwork City" },
    ["summerset"] = { name = "Psijic & Sapiarch Styles", trialDungeon = "Chapter: Summerset" },
    ["murkmire"] = { name = "Dead-Water & Elder Argonian Styles", trialDungeon = "DLC: Murkmire" },
    ["northern elsweyr"] = { name = "Elsweyr & Pellitine Styles", trialDungeon = "Chapter: Elsweyr" },
    ["southern elsweyr"] = { name = "Dragonguard & Proudspire Styles", trialDungeon = "DLC: Dragonhold (Southern Elsweyr)" },
    ["western skyrim"] = { name = "Skyrim & Greymoor Styles", trialDungeon = "Chapter: Greymoor" },
    ["the reach"] = { name = "Reachmaster & Arkthzand Styles", trialDungeon = "DLC: Markarth (The Reach)" },
    ["blackwood"] = { name = "Waking Flame & Deadlands Styles", trialDungeon = "Chapter: Blackwood" },
    ["fargrave"] = { name = "Fargrave Guardian Style", trialDungeon = "DLC: Deadlands" },
    ["high isle"] = { name = "Systres & Ascendant Order Styles", trialDungeon = "Chapter: High Isle" },
    ["galen"] = { name = "Firesong Style", trialDungeon = "Zone: Galen & Y'ffelon" },
    ["y'ffelon"] = { name = "Firesong Style", trialDungeon = "Zone: Galen & Y'ffelon" },
    ["telvanni peninsula"] = { name = "Morag Tong / Hermaeus Mora Styles", trialDungeon = "Chapter: Necrom" },
    ["apocrypha"] = { name = "Dead-Water / Seeker Styles", trialDungeon = "Chapter: Necrom (Apocrypha)" },
    ["west weald"] = { name = "West Weald / Colovian Styles", trialDungeon = "Chapter: Gold Road" },
    ["solstice"] = { name = "Death-Dancer & Fellowship Styles", trialDungeon = "Zone: Solstice" },

    -- Trials
    ["cloudrest"] = { name = "Welkynar Style", trialDungeon = "Trial: Cloudrest (nCR / vCR+1-3)" },
    ["sunspire"] = { name = "Sunspire Style", trialDungeon = "Trial: Sunspire" },
    ["rockgrove"] = { name = "Sul-Xan Style", trialDungeon = "Trial: Rockgrove" },
    ["dreadsail reef"] = { name = "Dreadsails Style", trialDungeon = "Trial: Dreadsail Reef" },
    ["lucent citadel"] = { name = "Lucent Citadel Style", trialDungeon = "Trial: Lucent Citadel" },
    ["sanity's edge"] = { name = "Ansuul Style", trialDungeon = "Trial: Sanity's Edge" },
    ["halls of fabrication"] = { name = "Refabricated Style", trialDungeon = "Trial: Halls of Fabrication" },
    ["maw of lorkhaj"] = { name = "Dro-m'Athra Style", trialDungeon = "Trial: Maw of Lorkhaj" },
    ["aetherian archive"] = { name = "Craglorn / The Thief", trialDungeon = "Trial: Aetherian Archive" },
    ["hel ra citadel"] = { name = "Craglorn / The Warrior", trialDungeon = "Trial: Hel Ra Citadel" },
    ["sanctum ophidia"] = { name = "Craglorn / The Serpent", trialDungeon = "Trial: Sanctum Ophidia" },
    ["asylum sanctorium"] = { name = "Asylum / Clockwork", trialDungeon = "Trial: Asylum Sanctorium" },

    -- Dungeons & Motifs
    ["cradle of shadows"] = { name = "Motif 44: Silken Ring Style", trialDungeon = "Dungeon: Cradle of Shadows" },
    ["ruins of mazzatun"] = { name = "Motif 45: Mazzatun Style", trialDungeon = "Dungeon: Ruins of Mazzatun" },
    ["bloodroot forge"] = { name = "Motif 54: Bloodforge Style", trialDungeon = "Dungeon: Bloodroot Forge" },
    ["falkreath hold"] = { name = "Motif 55: Dreadhorn Style", trialDungeon = "Dungeon: Falkreath Hold" },
    ["fang lair"] = { name = "Motif 58: Fang Lair Style", trialDungeon = "Dungeon: Fang Lair" },
    ["scalecaller peak"] = { name = "Motif 59: Scalecaller Style", trialDungeon = "Dungeon: Scalecaller Peak" },
    ["march of sacrifices"] = { name = "Motif 65: Huntsman Style", trialDungeon = "Dungeon: March of Sacrifices" },
    ["moon hunter keep"] = { name = "Motif 66: Silver Dawn Style", trialDungeon = "Dungeon: Moon Hunter Keep" },
    ["frostvault"] = { name = "Motif 71: Coldsnap Style", trialDungeon = "Dungeon: Frostvault" },
    ["depths of malatar"] = { name = "Motif 72: Meridian Style", trialDungeon = "Dungeon: Depths of Malatar" },
    ["lair of maarselok"] = { name = "Motif 77: Stags of Z'en Style", trialDungeon = "Dungeon: Lair of Maarselok" },
    ["moongrave fane"] = { name = "Motif 78: Moongrave Fane Style", trialDungeon = "Dungeon: Moongrave Fane" },
    ["cauldron"] = { name = "Motif 99: Waking Flame Style", trialDungeon = "Dungeon: The Cauldron" },
    ["black drake villa"] = { name = "Motif 100: True-Sworn Style", trialDungeon = "Dungeon: Black Drake Villa" },
    ["dread cellar"] = { name = "Motif 105: Crimson Oath Style", trialDungeon = "Dungeon: The Dread Cellar" },
    ["red petal bastion"] = { name = "Motif 106: Silver Rose Style", trialDungeon = "Dungeon: Red Petal Bastion" },
    ["shipwright's regret"] = { name = "Motif 110: Dreadsails Style", trialDungeon = "Dungeon: Shipwright's Regret" },
    ["coral aerie"] = { name = "Motif 111: Ascendant Order Style", trialDungeon = "Dungeon: Coral Aerie" },
    ["earthen root enclave"] = { name = "Motif 115: Y'ffre's Will Style", trialDungeon = "Dungeon: Earthen Root Enclave" },
    ["graven deep"] = { name = "Motif 116: Drowned Mariner Style", trialDungeon = "Dungeon: Graven Deep" },
    ["bal sunn"] = { name = "Motif 119: Blessed Inheritor Style", trialDungeon = "Dungeon: Bal Sunnar" },
    ["scrivener's hall"] = { name = "Motif 120: Scribes of Mora Style", trialDungeon = "Dungeon: Scrivener's Hall" },
    ["oathsworn pit"] = { name = "Motif 124: The Recollection Style", trialDungeon = "Dungeon: Oathsworn Pit" },
    ["white-gold tower"] = { name = "Xivkyn / Planar Inhibitor", trialDungeon = "Dungeon: White-Gold Tower" },
    ["imperial city prison"] = { name = "Lord Warden", trialDungeon = "Dungeon: Imperial City Prison" },
    ["icereach"] = { name = "Icereach Coven", trialDungeon = "Dungeon: Icereach" },
    ["unhallowed grave"] = { name = "Boneshaper", trialDungeon = "Dungeon: Unhallowed Grave" },
    ["stone garden"] = { name = "Arkasis / No Motif", trialDungeon = "Dungeon: Stone Garden" },
    ["castle thorn"] = { name = "Lady Thorn", trialDungeon = "Dungeon: Castle Thorn" },
    ["bedlam veil"] = { name = "Oathsworn Pit / Modern", trialDungeon = "Dungeon: Bedlam Veil" },
}

MasterThief.RoutesByID = {
    ["bal foyen"] = { zone = "Bal Foyen", spot = "Stonefalls", target = "Docks & Campsites", loot = "Pact Styles (Ebonheart, Redoran, Hlaalu, Telvanni)", method = "Overland Theft & Looting", td = "Overland Zone: Bal Foyen" },
    ["auridon"] = { zone = "Auridon", spot = "Auridon", target = "City Hubs & Safeboxes", loot = "Dominion Styles (Altmer, Vulkhel Guard)", method = "Overland Theft & Looting", td = "Overland Zone: Auridon" },
    ["skywatch"] = { zone = "Skywatch", spot = "Auridon", target = "City Hub & Safeboxes", loot = "Dominion Styles (Altmer)", method = "Overland Theft & Looting", td = "City Hub: Skywatch" },
    ["artaeum"] = { zone = "Artaeum", spot = "Summerset Isles", target = "Psijic Order Sanctuary", loot = "Psijic Style & Antiquity Leads", method = "Overland Looting & Pickpocketing", td = "Overland Zone: Artaeum" },
    ["cipher's midden"] = { zone = "Cipher's Midden", spot = "Apocrypha", target = "Hub & Safeboxes", loot = "Dead-Water / Seeker Styles & High-Value Furnishing Plans", method = "Overland Theft & Looting", td = "Overland Hub: Cipher's Midden" },
    ["alik'r desert"] = { zone = "Alik'r Desert", spot = "Alik'r Desert", target = "Overland Delves, World Bosses & Safeboxes", loot = "Redguard Motif, Covenant Styles & Set Pieces", method = "Overland Farming & Theft", td = "Overland Zone: Alik'r Desert" },
    ["ossein cage"] = { zone = "Ossein Cage", spot = "Solstice", target = "Overfiend Kazpian (Final Boss)", loot = "Recovery Convergence / Harmony in Chaos / Kazpian's Cruel Signet / Dolorous Arena", method = "Trial Boss Drops (Normal/Veteran)", td = "Trial: Ossein Cage" },
    ["black gem foundry"] = { zone = "Black Gem Foundry", spot = "Solstice", target = "High Soulbinder Vykand (Final Boss)", loot = "Motif 134: Black Soul Gem & Lustrous Soulwell / Vykand's Soulfury / Black Foundry Steel", method = "Dungeon Boss Drops (Veteran)", td = "Dungeon: Black Gem Foundry" },
    ["naj-caldeesh"] = { zone = "Naj-Caldeesh", spot = "Solstice", target = "Talen-Lah & Bar-Sakka (Final Boss)", loot = "Voskrona Guardian Motif & Xanmeer Spellweaver / Tools of the Trapmaster / Stonehulk Domination", method = "Dungeon Boss Drops (Veteran)", td = "Dungeon: Naj-Caldeesh" },
    ["lep seclusa"] = { zone = "Lep Seclusa", spot = "Hew's Bane", target = "Orpheon the Tactician (Final Boss)", loot = "Motif 131: Militant Monk & Fledgling's Nest / Noxious Boulder / Heroic Unity", method = "Dungeon Boss Drops (Veteran)", td = "Dungeon: Lep Seclusa" },
    ["coral aerie"] = { zone = "Coral Aerie", spot = "Summerset", target = "Varallion (Final Boss)", loot = "Ascendant Order Motif & Glacial Guardian / Gryphon's Reprisal Sets", method = "Dungeon Boss Drops (Veteran)", td = "Dungeon: Coral Aerie" },
    ["wrothgar"] = { zone = "Wrothgar", spot = "Old Orsinium / Rkindaleft", target = "Public Dungeon Bosses & Urns", loot = "Ancient Orc Motifs & Cassiterite", method = "Public Dungeon Farming", td = "DLC: Orsinium (Wrothgar)" },
    ["craglorn"] = { zone = "Craglorn", spot = "Belkarth", target = "Craglorn Dailies & Nodes", loot = "Yokudan Motifs (from Coffers) & Nirncrux", method = "Daily Quests & Harvesting", td = "Zone: Craglorn" },
    ["clockwork city"] = { zone = "Clockwork City", spot = "The Brass Fortress", target = "Clockwork Dailies Quest Givers", loot = "Apostle Motifs (from Slag Town Coffers)", method = "Daily Quests", td = "DLC: Clockwork City" },
    ["galen"] = { zone = "Galen", spot = "Vastyr / Glimmertarn", target = "Volcanic Vents & Daily Quest Givers", loot = "Firesong Motifs & Druidic Furnishing Plans", method = "Volcanic Vents & Dailies", td = "Zone: Galen & Y'ffelon" },
    ["west weald"] = { zone = "West Weald", spot = "Skingrad", target = "Citizens & Nobles", loot = "Colovian Staves & Furnishing Plans", method = "Pickpocket & Thievery", td = "Zone: West Weald" },
    ["solstice"] = { zone = "Solstice", spot = "Solstice Shores", target = "Worm Cult Cultists", loot = "Death-Dancer & Fellowship Styles", method = "Delves & World Bosses", td = "Zone: Solstice" },
    ["telvanni peninsula"] = { zone = "Telvanni Peninsula", spot = "Necrom", target = "Delves, World Bosses & Dailies", loot = "Morag Tong & Apocrypha Motifs", method = "Bosses & Daily Quests", td = "Zone: Necrom" },
    ["high isle"] = { zone = "High Isle", spot = "Gonfalon Bay", target = "Nobles & Merchants", loot = "Systres Furnishing Plans", method = "Pickpocket & Thievery", td = "Zone: High Isle" },
    ["blackwood"] = { zone = "Blackwood", spot = "Leyawiin", target = "The Cauldron Dungeon Boss / Dailies", loot = "Waking Flame Motifs", method = "Dungeon / Daily Quests", td = "Zone: Blackwood" },
    ["western skyrim"] = { zone = "Western Skyrim", spot = "Solitude", target = "Bards & Citizens", loot = "Greymoor Furnishings", method = "Pickpocket & Thievery", td = "Zone: Western Skyrim" },
    ["northern elsweyr"] = { zone = "Northern Elsweyr", spot = "Rimmen", target = "Merchants & Nobles", loot = "Elsweyr Valuables", method = "Pickpocket & Thievery", td = "Zone: Northern Elsweyr" },
    ["summerset"] = { zone = "Summerset", spot = "Alinor", target = "High Elves & Nobles", loot = "Psijic/Sapiarch Valuables", method = "Pickpocket & Thievery", td = "Zone: Summerset" },
    ["vvardenfell"] = { zone = "Vvardenfell", spot = "Vivec City", target = "Dunmer Citizens", loot = "Ashlander Valuables", method = "Pickpocket & Thievery", td = "Zone: Vvardenfell" },
    ["hew's bane"] = { zone = "Hew's Bane", spot = "Abah's Landing", target = "Thieves & Merchants", loot = "Abah's Watch Valuables", method = "Pickpocket & Thievery", td = "Zone: Hew's Bane" },
    ["gold coast"] = { zone = "Gold Coast", spot = "Anvil / Kvatch", target = "Merchants & Citizens", loot = "Assassins League Valuables", method = "Pickpocket & Thievery", td = "Zone: Gold Coast" },
    ["cloudrest"] = { zone = "Cloudrest", spot = "Summerset", target = "Z'Maja & Bosses", loot = "Arms of Relequen, Olorime, Siroria & Welkynar Motifs", method = "Trial Boss Drops", td = "Trial: Cloudrest (nCR/vCR)" },
    ["sunspire"] = { zone = "Sunspire", spot = "Northern Elsweyr", target = "Dragons & Alkosh", loot = "False God, Lokkestiz, Sunspire Motifs", method = "Trial Boss Drops", td = "Trial: Sunspire" },
    ["rockgrove"] = { zone = "Rockgrove", spot = "Blackwood", target = "Sul-Xan Bosses", loot = "Bahsei, Saxhleel, Sul-Xan Motifs", method = "Trial Boss Drops", td = "Trial: Rockgrove" },
    ["coral aerie"] = { zone = "Coral Aerie", spot = "Summerset", target = "Varallion (Final Boss)", loot = "Ascendant Order Motif & Glacial Guardian", method = "Dungeon Boss Drops (Veteran)", td = "Dungeon: Coral Aerie" },
    ["lucent citadel"] = { zone = "Lucent Citadel", spot = "West Weald", target = "Arcane Guardians", loot = "Lucent Citadel Gear & Motifs", method = "Trial Boss Drops", td = "Trial: Lucent Citadel" },
    ["sanity's edge"] = { zone = "Sanity's Edge", spot = "Telvanni Peninsula", target = "Ansuul the Tormentor", loot = "Ansuul's Torment, Transformative Hope, Motif Chapters", method = "Trial Boss Drops", td = "Trial: Sanity's Edge" },
    ["halls of fabrication"] = { zone = "Halls of Fabrication", spot = "Vvardenfell", target = "Assembly General", loot = "Master Architect, War Machine, Refabricated", method = "Trial Boss Drops", td = "Trial: Halls of Fabrication" },
    ["maw of lorkhaj"] = { zone = "Maw of Lorkhaj", spot = "Reaper's March", target = "Rakkhat", loot = "Moondancer, Alkosh, Dro-m'Athra Motifs", method = "Trial Boss Drops", td = "Trial: Maw of Lorkhaj" },
    ["aetherian archive"] = { zone = "Aetherian Archive", spot = "Craglorn", target = "The Mage", loot = "Aetherial Ascendant Gear", method = "Trial Boss Drops", td = "Trial: Aetherian Archive" },
    ["hel ra citadel"] = { zone = "Hel Ra Citadel", spot = "Craglorn", target = "The Warrior", loot = "Yokudan Style & Immortal Warrior Gear", method = "Trial Boss Drops", td = "Trial: Hel Ra Citadel" },
    ["sanctum ophidia"] = { zone = "Sanctum Ophidia", spot = "Craglorn", target = "The Serpent", loot = "Vicious Serpent & Elegant Gear", method = "Trial Boss Drops", td = "Trial: Sanctum Ophidia" },
    ["asylum sanctorium"] = { zone = "Asylum Sanctorium", spot = "Clockwork City", target = "Saint Olms", loot = "Concentrated Force, Asylum Weapons, Clockwork Motifs", method = "Trial Boss Drops", td = "Trial: Asylum Sanctorium" },
    ["cradle of shadows"] = { zone = "Cradle of Shadows", spot = "Shadowfen", target = "Velidreth (Final Boss)", loot = "Silken Ring Motif & Guile Sets", method = "Dungeon Boss Drops (Veteran)", td = "Dungeon: Cradle of Shadows" },
    ["ruins of mazzatun"] = { zone = "Ruins of Mazzatun", spot = "Shadowfen", target = "Xal Nur the Slaver (Final Boss)", loot = "Mazzatun Motif & Amber Plasm Sets", method = "Dungeon Boss Drops (Veteran)", td = "Dungeon: Ruins of Mazzatun" },
    ["bloodroot forge"] = { zone = "Bloodroot Forge", spot = "Craglorn", target = "Garnag / Earthgore (Final Boss)", loot = "Bloodforge Motif & Blooddrinker Sets", method = "Dungeon Boss Drops (Veteran)", td = "Dungeon: Bloodroot Forge" },
    ["falkreath hold"] = { zone = "Falkreath Hold", spot = "Bangkorai", target = "Domihaus the Bloody-Horned", loot = "Dreadhorn Motif & Pillar of Nirn", method = "Dungeon Boss Drops (Veteran)", td = "Dungeon: Falkreath Hold" },
    ["fang lair"] = { zone = "Fang Lair", spot = "Bangkorai", target = "Thane Korthor / Ulfnor", loot = "Fang Lair Motif & Caluurion's Legacy", method = "Dungeon Boss Drops (Veteran)", td = "Dungeon: Fang Lair" },
    ["scalecaller peak"] = { zone = "Scalecaller Peak", spot = "Stormhaven", target = "Zaan the Scalecaller", loot = "Scalecaller Motif & Plaguebreak", method = "Dungeon Boss Drops (Veteran)", td = "Dungeon: Scalecaller Peak" },
    ["march of sacrifices"] = { zone = "March of Sacrifices", spot = "Greenshade", target = "Balorgh (Final Boss)", loot = "Huntsman Motif & Blooddrinker", method = "Dungeon Boss Drops (Veteran)", td = "Dungeon: March of Sacrifices" },
    ["moon hunter keep"] = { zone = "Moon Hunter Keep", spot = "Reaper's March", target = "Vykosa (Final Boss)", loot = "Silver Dawn Motif & Moon Hunter Sets", method = "Dungeon Boss Drops (Veteran)", td = "Dungeon: Moon Hunter Keep" },
    ["frostvault"] = { zone = "Frostvault", spot = "Stormhaven", target = "Stonekeeper (Final Boss)", loot = "Coldsnap Motif & Icy Conjurer", method = "Dungeon Boss Drops (Veteran)", td = "Dungeon: Frostvault" },
    ["depths of malatar"] = { zone = "Depths of Malatar", spot = "Gold Coast", target = "King Narilmor (Final Boss)", loot = "Meridian Motif & Auroran's Thunder", method = "Dungeon Boss Drops (Veteran)", td = "Dungeon: Depths of Malatar" },
    ["lair of maarselok"] = { zone = "Lair of Maarselok", spot = "Grahtwood", target = "Maarselok (Final Boss)", loot = "Stags of Z'en Motif & Dragon Defiler", method = "Dungeon Boss Drops (Veteran)", td = "Dungeon: Lair of Maarselok" },
    ["moongrave fane"] = { zone = "Moongrave Fane", spot = "Southern Elsweyr", target = "Grundwulf (Final Boss)", loot = "Moongrave Fane Motif & Hollowfang", method = "Dungeon Boss Drops (Veteran)", td = "Dungeon: Moongrave Fane" },
    ["cauldron"] = { zone = "The Cauldron", spot = "Deshaan", target = "Baron Zaudrus (Final Boss)", loot = "Waking Flame Motif & Unleashed Terror", method = "Dungeon Boss Drops (Veteran)", td = "Dungeon: The Cauldron" },
    ["black drake villa"] = { zone = "Black Drake Villa", spot = "Gold Coast", target = "Kinras Ironeye (Final Boss)", loot = "True-Sworn Motif & Kinras's Wrath", method = "Dungeon Boss Drops (Veteran)", td = "Dungeon: Black Drake Villa" },
    ["dread cellar"] = { zone = "The Dread Cellar", spot = "Wrothgar", target = "Magus / Cyronin Artoria", loot = "Crimson Oath Motif & Rush of Agony", method = "Dungeon Boss Drops (Veteran)", td = "Dungeon: The Dread Cellar" },
    ["red petal bastion"] = { zone = "Red Petal Bastion", spot = "Rivenspire", target = "Prior Thierric", loot = "Silver Rose Motif & Thunderous Volley", method = "Dungeon Boss Drops (Veteran)", td = "Dungeon: Red Petal Bastion" },
    ["shipwright's regret"] = { zone = "Shipwright's Regret", spot = "Rivenspire", target = "Captain Numirril", loot = "Dreadsails Motif & Turning Tide", method = "Dungeon Boss Drops (Veteran)", td = "Dungeon: Shipwright's Regret" },
    ["coral aerie"] = { zone = "Coral Aerie", spot = "Summerset", target = "Varallion", loot = "Ascendant Order Motif & Glacial Guardian", method = "Dungeon Boss Drops (Veteran)", td = "Dungeon: Coral Aerie" },
    ["earthen root enclave"] = { zone = "Earthen Root Enclave", spot = "High Isle", target = "Corruption of Stone", loot = "Y'ffre's Will Motif & Wretched Vitality", method = "Dungeon Boss Drops (Veteran)", td = "Dungeon: Earthen Root Enclave" },
    ["graven deep"] = { zone = "Graven Deep", spot = "High Isle", target = "Euphotic Gatekeeper", loot = "Drowned Mariner Motif & Pyrebrand", method = "Dungeon Boss Drops (Veteran)", td = "Dungeon: Graven Deep" },
    ["bal sunn"] = { zone = "Bal Sunn", spot = "Telvanni Peninsula", target = "Matriarch Llrys", loot = "Blessed Inheritor Motif & Anesssi's Thirst", method = "Dungeon Boss Drops (Veteran)", td = "Dungeon: Bal Sunn" },
    ["scrivener's hall"] = { zone = "Scrivener's Hall", spot = "Telvanni Peninsula", target = "Valinna (Final Boss)", loot = "Scribes of Mora Motif & Runecarver's Blaze", method = "Dungeon Boss Drops (Veteran)", td = "Dungeon: Scrivener's Hall" },
    ["oathsworn pit"] = { zone = "Oathsworn Pit", spot = "The Reach", target = "Retoh / Anthelmir", loot = "The Recollection Motif & Sets", method = "Dungeon Boss Drops (Veteran)", td = "Dungeon: Oathsworn Pit" },
    ["white-gold tower"] = { zone = "White-Gold Tower", spot = "Imperial City", target = "Planar Inhibitor", loot = "Willpower, Essence Thief, Xivkyn Motif", method = "Dungeon Boss Drops", td = "Dungeon: White-Gold Tower" },
    ["imperial city prison"] = { zone = "Imperial City Prison", spot = "Imperial City", target = "Lord Warden", loot = "Scathing Mage, Leeching Plate, Lord Warden Mask", method = "Dungeon Boss Drops", td = "Dungeon: Imperial City Prison" },
    ["icereach"] = { zone = "Icereach", spot = "Western Skyrim", target = "Mother Coven", loot = "Icereach Broodmother Mask, Titanborn Strength", method = "Dungeon Boss Drops", td = "Dungeon: Icereach" },
    ["unhallowed grave"] = { zone = "Unhallowed Grave", spot = "Western Skyrim", target = "Kjalnar", loot = "Kjalnar's Nightmare Mask, Aegis Caller", method = "Dungeon Boss Drops", td = "Dungeon: Unhallowed Grave" },
    ["stone garden"] = { zone = "Stone Garden", spot = "Blackreach: Greymoor Caverns", target = "Arkasis", loot = "Arkasis's Prodigy, Lady Thorn Mask", method = "Dungeon Boss Drops", td = "Dungeon: Stone Garden" },
    ["castle thorn"] = { zone = "Castle Thorn", spot = "Blackreach: Greymoor Caverns", target = "Lady Thorn", loot = "Thorn Legion Style & Crimson Twilight", method = "Dungeon Boss Drops", td = "Dungeon: Castle Thorn" },
    ["bedlam veil"] = { zone = "Bedlam Veil", spot = "Fargrave", target = "The Blind", loot = "Blind's Mask & Oathsworn Sets", method = "Dungeon Boss Drops", td = "Dungeon: Bedlam Veil" },
}

MasterThief.ZoneAlias = {
    ["bal foyen"] = "bal foyen",
    ["skywatch"] = "skywatch",
    ["skywatch"] = "auridon",
    ["artaeum"] = "artaeum",
    ["cipher's midden"] = "cipher's midden",
    ["alik'r desert"] = "alik'r desert",
    ["icereach underkeep"] = "icereach",
    ["castle thorn exterior"] = "castle thorn",
    ["ossein cage"] = "ossein cage",
    ["black gem foundry"] = "black gem foundry",
    ["naj-caldeesh"] = "naj-caldeesh",
    ["lep seclusa"] = "lep seclusa",
    ["palace sewers"] = "white-gold tower",
    ["prison district"] = "imperial city prison",
    ["asylum atrium"] = "asylum sanctorium",
    ["brackish cove"] = "coral aerie",
    ["red petal bastion exterior"] = "red petal bastion", ["red petal bastion"] = "red petal bastion",
    ["decaying vineyards"] = "black drake villa", ["black drake villa"] = "black drake villa",
    ["moongrave fane grounds"] = "moongrave fane", ["moongrave fane"] = "moongrave fane",
    ["murkmire"] = "murkmire", ["northern elsweyr"] = "northern elsweyr", ["rimmen"] = "northern elsweyr", ["southern elsweyr"] = "southern elsweyr", ["western skyrim"] = "western skyrim",
    ["tenmar mountain valley"] = "lair of maarselok", ["lair of maarselok"] = "lair of maarselok",
    ["lair of maarselok"] = "lair of maarselok",
    ["iceflow rift"] = "frostvault", ["frostvault"] = "frostvault",
    ["frostspike caverns"] = "scalecaller peak", ["scalecaller peak"] = "scalecaller peak",
    ["jerall cleft"] = "bloodroot forge", ["bloodroot forge"] = "bloodroot forge",
    ["wrothgar"] = "wrothgar", ["orsinium"] = "wrothgar", ["old orsinium"] = "wrothgar", ["rkindaleft"] = "wrothgar",
    ["craglorn"] = "craglorn", ["belkarth"] = "craglorn", ["dragonstar"] = "craglorn",
    ["clockwork city"] = "clockwork city", ["the brass fortress"] = "clockwork city",
    ["stonefalls"] = "stonefalls", ["deshaan"] = "deshaan", ["shadowfen"] = "shadowfen", ["eastmarch"] = "eastmarch", ["the rift"] = "the rift",
    ["glenumbra"] = "glenumbra", ["stormhaven"] = "stormhaven", ["rivenspire"] = "rivenspire", ["alik'r desert"] = "alik'r desert", ["bangkorai"] = "bangkorai",
    ["auridon"] = "auridon", ["grahtwood"] = "grahtwood", ["greenshade"] = "greenshade", ["malabal tor"] = "malabal tor", ["reaper's march"] = "reaper's march",
    ["coldharbour"] = "coldharbour", ["hew's bane"] = "hew's bane", ["gold coast"] = "gold coast", ["vvardenfell"] = "vvardenfell", ["summerset"] = "summerset",
    ["murkmire"] = "murkmire", ["northern elsweyr"] = "northern elsweyr", ["southern elsweyr"] = "southern elsweyr", ["western skyrim"] = "western skyrim",
    ["the reach"] = "the reach", ["blackwood"] = "blackwood", ["fargrave"] = "fargrave", ["high isle"] = "high isle", ["galen"] = "galen", ["y'ffelon"] = "galen",
    ["vastyr"] = "galen", ["glimmertarn"] = "galen", ["telvanni peninsula"] = "telvanni peninsula", ["apocrypha"] = "telvanni peninsula", ["west weald"] = "west weald",
    ["solstice"] = "solstice", ["tel fyr"] = "halls of fabrication", ["ancient city of rockgrove"] = "rockgrove", ["rockgrove"] = "rockgrove",
    ["cloudrest"] = "cloudrest", ["sunspire"] = "sunspire", ["dreadsail reef"] = "dreadsail reef", ["lucent citadel"] = "lucent citadel",
    ["sanity's edge"] = "sanity's edge", ["halls of fabrication"] = "halls of fabrication", ["maw of lorkhaj"] = "maw of lorkhaj",
    ["aetherian archive"] = "aetherian archive", ["hel ra citadel"] = "hel ra citadel", ["sanctum ophidia"] = "sanctum ophidia", ["asylum sanctorium"] = "asylum sanctorium",
    
    -- Fixed dungeon mappings including "the" prefix variations
    ["the cradle of shadows"] = "cradle of shadows", ["cradle of shadows"] = "cradle of shadows",
    ["the ruins of mazzatun"] = "ruins of mazzatun", ["ruins of mazzatun"] = "ruins of mazzatun",
    ["bloodroot forge"] = "bloodroot forge",
    ["falkreath hold"] = "falkreath hold",
    ["fang lair"] = "fang lair",
    ["scalecaller peak"] = "scalecaller peak",
    ["march of sacrifices"] = "march of sacrifices",
    ["moon hunter keep"] = "moon hunter keep",
    ["frostvault"] = "frostvault",
    ["depths of malatar"] = "depths of malatar",
    ["lair of maarselok"] = "lair of maarselok",
    ["moongrave fane"] = "moongrave fane",
    ["the cauldron"] = "cauldron", ["cauldron"] = "cauldron",
    ["black drake villa"] = "black drake villa",
    ["the dread cellar"] = "dread cellar", ["dread cellar"] = "dread cellar",
    ["red petal bastion"] = "red petal bastion",
    ["shipwright's regret"] = "shipwright's regret",
    ["coral aerie"] = "coral aerie",
    ["earthen root enclave"] = "earthen root enclave",
    ["graven deep"] = "graven deep",
    ["bal sunnar"] = "bal sunn", ["bal sunn"] = "bal sunn",
    ["scrivener's hall"] = "scrivener's hall",
    ["oathsworn pit"] = "oathsworn pit",
    ["white-gold tower"] = "white-gold tower", 
    ["imperial city prison"] = "imperial city prison", 
    ["icereach"] = "icereach",
    ["unhallowed grave"] = "unhallowed grave", 
    ["stone garden"] = "stone garden", 
    ["castle thorn"] = "castle thorn", 
    ["bedlam veil"] = "bedlam veil",
}

-----------------------------------------------------------
-- 1. HELPERS and SAFE ZONE CHECKERS
-----------------------------------------------------------
function MasterThief.DebugLog(msg)
    if MasterThief.savedVars and MasterThief.savedVars.debugMode then
        CHAT_ROUTER:AddSystemMessage(string.format("|cFFD700[MasterThief Debug]|r %s", tostring(msg)))
    end
end

function MasterThief.GetCustomFont(size)
    return string.format("$(CHAT_FONT)|%d|soft-shadow-thick", size or 11)
end

function MasterThief.GetCurrentZoneID()
    local name = GetMapName()
    if not name or name == "" or name == "Tamriel" then
        name = GetZoneText()
    end
    if not name or name == "" then return "unknown", "Unknown" end
    
    local cleanName = string.lower(name)
    return MasterThief.ZoneAlias[cleanName] or cleanName, name
end

function MasterThief.GetActiveCharacterStats()
    if not MasterThief.savedVars then return nil end
    MasterThief.savedVars.charStats = MasterThief.savedVars.charStats or {}
    local charName = GetUnitName("player") or "Default"
    
    if not MasterThief.savedVars.charStats[charName] then
        MasterThief.savedVars.charStats[charName] = { zones = {} }
    end
    return MasterThief.savedVars.charStats[charName]
end

function MasterThief.GetZoneStats(zoneID)
    local charStats = MasterThief.GetActiveCharacterStats()
    if not charStats.zones[zoneID] then
        charStats.zones[zoneID] = { whiteDestroyed = 0, greenLoot = 0, blueLoot = 0, purpleLoot = 0, isCompleted = false }
    end
    return charStats.zones[zoneID]
end

-----------------------------------------------------------
-- 2. EVENT TRACKERS
-----------------------------------------------------------
function MasterThief.OnInventorySlotUpdate(eventCode, bagId, slotIndex, isNew, _, _, stackCountChange)
    if not MasterThief.savedVars or bagId ~= BAG_BACKPACK or not isNew then return end

    local link = GetItemLink(bagId, slotIndex)
    local isStolen = IsItemStolen and IsItemStolen(bagId, slotIndex) or false
    local quality = GetItemLinkDisplayQuality(link) or 1
    local zoneID, _ = MasterThief.GetCurrentZoneID()
    local zoneStats = MasterThief.GetZoneStats(zoneID)
    local delta = (type(stackCountChange) == "number" and stackCountChange > 0) and stackCountChange or 1

    if isStolen then
        if quality <= 1 and link then
            if string.find(link, "a335ee") then quality = 4
            elseif string.find(link, "3a92ff") then quality = 3
            elseif string.find(link, "2dc800") then quality = 2 end
        end

        if quality == 1 then
            if MasterThief.savedVars.autoDestroyWhiteJunk then
                zoneStats.whiteDestroyed = zoneStats.whiteDestroyed + delta
            end
        elseif quality == 2 then 
            zoneStats.greenLoot = zoneStats.greenLoot + delta
        elseif quality == 3 then 
            zoneStats.blueLoot = zoneStats.blueLoot + delta
        elseif quality >= 4 then 
            zoneStats.purpleLoot = zoneStats.purpleLoot + delta 
        end

        MasterThief.UpdateHUDContent()
    end
end

-----------------------------------------------------------
-- 3. HUD and DISPLAY LOGIC
-----------------------------------------------------------
function MasterThief.ApplyPosition()
    if not MasterThief.hudFrame then return end
    MasterThief.hudFrame:ClearAnchors()
    MasterThief.hudFrame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, MasterThief.savedVars.posX or 60, MasterThief.savedVars.posY or 100)
end

function MasterThief.UpdateBackgroundState()
    if not MasterThief.hudBackground then return end
    local alphaVal = MasterThief.savedVars.backgroundAlpha or 75
    local alphaDecimal = alphaVal / 100.0
    
    MasterThief.hudBackground:SetHidden(alphaVal <= 0)
    MasterThief.hudBackground:SetAlpha(alphaDecimal)
    
    if MasterThief.hudBackground.SetCenterColor then
        MasterThief.hudBackground:SetCenterColor(0, 0, 0, alphaDecimal)
    end
    if MasterThief.hudBackground.SetEdgeColor then
        MasterThief.hudBackground:SetEdgeColor(0, 0, 0, alphaDecimal)
    end
end

function MasterThief.CreateHUD()
    if MasterThief.hudFrame then return end

    local wm = WINDOW_MANAGER
    local mainFrame = wm:CreateTopLevelWindow("MasterThiefHUD")
    mainFrame:SetMovable(true)
    mainFrame:SetMouseEnabled(true)
    mainFrame:SetClampedToScreen(true)
    mainFrame:SetDimensions(464, 260)
    MasterThief.hudFrame = mainFrame

    local bg = wm:CreateControlFromVirtual("$(parent)BG", mainFrame, "ZO_DefaultBackdrop")
    bg:SetAnchor(TOPLEFT, mainFrame, TOPLEFT, 0, 0)
    bg:SetAnchor(BOTTOMRIGHT, mainFrame, BOTTOMRIGHT, 0, 0)
    MasterThief.hudBackground = bg

    mainFrame:SetHandler("OnMoveStop", function(self)
        MasterThief.savedVars.posX = self:GetLeft()
        MasterThief.savedVars.posY = self:GetTop()
        if LibAddonMenu2 and MasterThief.optionsPanel then
            CALLBACK_MANAGER:FireCallbacks("LAM-RefreshPanel", MasterThief.optionsPanel)
        end
    end)

    local content = wm:CreateControl("$(parent)Content", mainFrame, CT_LABEL)
    content:SetAnchor(TOPLEFT, mainFrame, TOPLEFT, 12, 12)
    content:SetDrawLayer(DL_CONTROLS)
    MasterThief.contentLabel = content

    MasterThief.UpdateBackgroundState()
    MasterThief.UpdateHUDContent()
    MasterThief.ApplyPosition()
    MasterThief.hudFrame:SetHidden(not MasterThief.savedVars.showHUD)
end

function MasterThief.UpdateHUDContent()
    if not MasterThief.contentLabel or not MasterThief.hudFrame then return end

    local fontSize = MasterThief.savedVars.fontSize or 11
    MasterThief.contentLabel:SetFont(MasterThief.GetCustomFont(fontSize))
    MasterThief.contentLabel:SetWidth(440)

    local zoneID, rawZoneName = MasterThief.GetCurrentZoneID()
    local route = MasterThief.RoutesByID[zoneID]
    local zoneStats = MasterThief.GetZoneStats(zoneID)
    local motifMapping = MasterThief.ZoneMotifMap[zoneID]

    local buffer = { "|cFFD700[ MASTER THIEF: INSTANCE and PVE GUIDE ]|r" }

    if route then
        local statusTag = zoneStats.isCompleted and " |c00FF00[COMPLETED]|r" or ""
        table.insert(buffer, string.format("\n|c00BFFF%s|r |cAAAAAA(%s)|r%s", route.zone, route.spot, statusTag))
        table.insert(buffer, string.format("  |cFFD700Target:|r |cFFFFFF%s|r", route.target))
        table.insert(buffer, string.format("  |cFFD700Loot:|r |c2DC800%s|r", route.loot))
        table.insert(buffer, string.format("  |cFFD700Method:|r |cAAAAAA%s|r", route.method))
        table.insert(buffer, string.format("  |cFF9900Activity:|r |cFFFFFF%s|r", route.td))
    else
        table.insert(buffer, string.format("\n|c888888Instance Route Missing: %s|r", rawZoneName))
    end

    if motifMapping then
        table.insert(buffer, string.format("|cFFD700Zone Set Mapping:|r |cFFFFFF%s|r", motifMapping.name))
    end

    table.insert(buffer, "\n|cFFD700--- TRIAL COOLDOWN and RESET ---|r")
    table.insert(buffer, "Weekly Coffers: |cFF4500Resets Tuesdays (6AM EST)|r")

    local charStats = MasterThief.GetActiveCharacterStats()
    local totalWhiteDestroyed, totalGreen, totalBlue, totalPurple = 0, 0, 0, 0
    if charStats and charStats.zones then
        for _, zData in pairs(charStats.zones) do
            totalWhiteDestroyed = totalWhiteDestroyed + (zData.whiteDestroyed or 0)
            totalGreen = totalGreen + (zData.greenLoot or 0)
            totalBlue = totalBlue + (zData.blueLoot or 0)
            totalPurple = totalPurple + (zData.purpleLoot or 0)
        end
    end

    table.insert(buffer, "\n|cFFD700--- SESSION LOOT & DELETIONS ---|r")
    table.insert(buffer, string.format("Junk Destroyed: |c888888%d Whites|r", totalWhiteDestroyed))
    table.insert(buffer, string.format("Stolen Drops: |c2DC800%d Greens|r |c3A92FF%d Blues|r |cA335EE%d Purples|r", totalGreen, totalBlue, totalPurple))

    MasterThief.contentLabel:SetText(table.concat(buffer, "\n"))
    
    local textHeight = MasterThief.contentLabel:GetHeight()
    if textHeight > 0 then
        MasterThief.hudFrame:SetDimensions(464, textHeight + 28)
    end
end
-----------------------------------------------------------
-- 4. SETTINGS PANEL (LibAddonMenu2)
-----------------------------------------------------------
function MasterThief.CreateSettingsPanel()
    local LAM = LibAddonMenu2
    if not LAM then return end

    local panelName = "MasterThief_OptionsPanel"
    local panelData = {
        type = "panel",
        name = "Master Thief Elite",
        displayName = "|cFFD700Master Thief Elite Settings|r",
        author = "Thief",
        version = "1.0",
        slashCommand = "thiefsettings",
        registerForRefresh = true,
        registerForDefaults = true,
    }

    MasterThief.optionsPanel = LAM:RegisterAddonPanel(panelName, panelData)

    local optionsData = {
        { type = "header", name = "Display and Behavior" },
        {
            type = "checkbox",
            name = "Show Guide HUD",
            getFunc = function() return MasterThief.savedVars.showHUD end,
            setFunc = function(value)
                MasterThief.savedVars.showHUD = value
                if MasterThief.hudFrame then MasterThief.hudFrame:SetHidden(not value) end
            end,
            default = MasterThief.defaultSettings.showHUD,
        },
        {
            type = "checkbox",
            name = "Auto-Destroy White Junk",
            getFunc = function() return MasterThief.savedVars.autoDestroyWhiteJunk end,
            setFunc = function(value) MasterThief.savedVars.autoDestroyWhiteJunk = value end,
            default = MasterThief.defaultSettings.autoDestroyWhiteJunk,
        },
        {
            type = "header",
            name = "Appearance & Layout",
        },
        {
            type = "slider",
            name = "Background Opacity (%)",
            min = 0,
            max = 100,
            step = 4,
            getFunc = function() return MasterThief.savedVars.backgroundAlpha or 75 end,
            setFunc = function(value)
                MasterThief.savedVars.backgroundAlpha = value
                MasterThief.UpdateBackgroundState()
            end,
            default = MasterThief.defaultSettings.backgroundAlpha,
        },
        {
            type = "slider",
            name = "Font Size",
            min = 9,
            max = 50,
            step = 2,
            getFunc = function() return MasterThief.savedVars.fontSize or 11 end,
            setFunc = function(value)
                MasterThief.savedVars.fontSize = value
                MasterThief.UpdateHUDContent()
            end,
            default = MasterThief.defaultSettings.fontSize,
        },
        {
            type = "header",
            name = "HUD Position Controls",
        },
        {
            type = "slider",
            name = "X Position",
            min = 0,
            max = 3840,
            step = 5,
            getFunc = function() return MasterThief.savedVars.posX or 60 end,
            setFunc = function(value)
                MasterThief.savedVars.posX = value
                MasterThief.ApplyPosition()
            end,
            default = MasterThief.defaultSettings.posX,
        },
        {
            type = "slider",
            name = "Y Position",
            min = 0,
            max = 2160,
            step = 5,
            getFunc = function() return MasterThief.savedVars.posY or 100 end,
            setFunc = function(value)
                MasterThief.savedVars.posY = value
                MasterThief.ApplyPosition()
            end,
            default = MasterThief.defaultSettings.posY,
        },
    }

    LAM:RegisterOptionControls(panelName, optionsData)
end
-----------------------------------------------------------
-- 5. INITIALIZATION & ERROR SAFETY
-----------------------------------------------------------
function MasterThief.Initialize()
    local success, err = pcall(function()
        MasterThief.savedVars = ZO_SavedVars:NewAccountWide("MasterThief_SavedVars", 1, nil, MasterThief.defaultSettings)
        
        MasterThief.CreateHUD()
        MasterThief.CreateSettingsPanel()
        MasterThief.UpdateBackgroundState()

        EVENT_MANAGER:RegisterForEvent(MasterThief.name, EVENT_PLAYER_ACTIVATED, function() zo_callLater(MasterThief.UpdateHUDContent, 500) end)
        EVENT_MANAGER:RegisterForEvent(MasterThief.name, EVENT_ZONE_CHANGED, function() zo_callLater(MasterThief.UpdateHUDContent, 500) end)
        EVENT_MANAGER:RegisterForEvent(MasterThief.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, MasterThief.OnInventorySlotUpdate)

        SLASH_COMMANDS["thief"] = function()
            if MasterThief.hudFrame then
                local newState = not MasterThief.savedVars.showHUD
                MasterThief.savedVars.showHUD = newState
                MasterThief.hudFrame:SetHidden(not newState)
            end
        end
    end)

    if not success then
        CHAT_ROUTER:AddSystemMessage("|cFF0000[MasterThief ERROR]|r An error occurred during startup!")
        CHAT_ROUTER:AddSystemMessage("|cFFFFFF[WARNING]: Please delete your 'MasterThief_SavedVars' file from your Add-Ons folder or reset settings to fix this!|r")
        if MasterThief.DebugLog then
            MasterThief.DebugLog("Initialization Error: " .. tostring(err))
        end
    end
end

EVENT_MANAGER:RegisterForEvent(MasterThief.name, EVENT_ADD_ON_LOADED, function(_, addonName)
    if addonName ~= MasterThief.name then return end
    MasterThief.Initialize()
    EVENT_MANAGER:UnregisterForEvent(MasterThief.name, EVENT_ADD_ON_LOADED)
end)