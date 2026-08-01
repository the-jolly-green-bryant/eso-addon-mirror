--[[
  ==============================================
  Addon header information
  ==============================================
--]]
ImprovedTitleizer = {}
local ImprovedTitleizer = ImprovedTitleizer

ImprovedTitleizer.Name = "ImprovedTitleizer"
ImprovedTitleizer.DisplayName = "Improved Titleizer"
ImprovedTitleizer.Author = "tomstock, Baertram, IsJustaGhost[, Kyoma]"
ImprovedTitleizer.Version = "1.16"

ImprovedTitleizer.titleDropdownRow = nil

local tins = table.insert
local tsort = table.sort
local tgetn = table.getn

local LSM = LibScrollableMenu

local defaultSVs = {
  debug=false,
  sortbyachievecat = true,
  showmissingtitles = false,
  visibleRowsDropdown = 16,
  visibleRowsSubmenu = 16,
  guiDebug={
    lastX = 100,
    lastY = 100,
    width = 650,
    height = 550,
  }
}

ImprovedTitleizer.logger = nil
--[[
  ==============================================
  Setup LibDebugLogger as an optional dependency
  ==============================================
--]]
if LibDebugLogger and ImprovedTitleizer.Debug then
  ImprovedTitleizer.logger = LibDebugLogger.Create(ImprovedTitleizer.Name)
  ImprovedTitleizer.logger:Info("Loaded logger")
end

--[[
  ==============================================
  Utility Functions
    spairs - For sorting keys in an array
  ==============================================
--]]
local function spairs(t, order)
    -- collect the keys
    local keys = {}
    for k in pairs(t) do keys[#keys+1] = k end

    -- if order function given, sort by it by passing the table and keys a, b,
    -- otherwise just sort the keys
    if order then
        tsort(keys, function(a,b) return order(t, a, b) end)
    else
        tsort(keys)
    end

    -- return the iterator function
    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
end

--[[
  ==============================================
  Manual Categorization
    --ID = Achievement ID
    --Rank = Sort override
  ==============================================
--]]
ImprovedTitleizer.AchievmentIdsCategories =
{
  {
    Name=GetString(SI_AVA_MENU_ALLIANCE_WAR_GROUP), --Alliance War
    Entries=
    {
      --! Emperor tied to achievement 935.  No way for me to test how it works.
      {ID=92,Rank=1}, --Volunteer --Alliance War Volunteer
      {ID=93,Rank=2}, --Recruit --Alliance War Recruit
      {ID=94,Rank=3}, --Tyro --Alliance War Tyro
      {ID=95,Rank=4}, --Legionary --Alliance War Legionary
      {ID=96,Rank=5}, --Veteran --Alliance War Veteran
      {ID=97,Rank=6}, --Corporal --Alliance War Corporal
      {ID=98,Rank=7}, --Sergeant --Alliance War Sergeant
      {ID=706,Rank=8}, --First Sergeant --Alliance War First Sergeant
      {ID=99,Rank=9}, --Lieutenant --Alliance War Lieutenant
      {ID=100,Rank=10}, --Captain --Alliance War Captain
      {ID=101,Rank=11}, --Major --Alliance War Major
      {ID=102,Rank=12}, --Centurion --Alliance War Centurion
      {ID=103,Rank=13}, --Colonel --Alliance War Colonel
      {ID=104,Rank=14}, --Tribune --Alliance War Tribune
      {ID=105,Rank=15}, --Brigadier --Alliance War Brigadier
      {ID=106,Rank=16}, --Prefect --Alliance War Prefect
      {ID=107,Rank=17}, --Praetorian --Alliance War Praetorian
      {ID=108,Rank=18}, --Palatine --Alliance War Palatine
      {ID=109,Rank=19}, --August Palatine --Alliance War August Palatine
      {ID=110,Rank=20}, --Legate --Alliance War Legate
      {ID=111,Rank=21}, --General --Alliance War General
      {ID=112,Rank=22}, --Warlord --Alliance War Warlord
      {ID=113,Rank=23}, --Grand Warlord --Alliance War Grand Warlord
      {ID=114,Rank=24}, --Overlord --Alliance War Overlord
      {ID=705,Rank=25}, --Grand Overlord --Alliance War Grand Overlord
    },
  },
  {
    Name=GetString(SI_GROUPFINDERCATEGORY3), --Infinite Archive
    Entries=
    {
      {ID=3759}, --Infinite Archive Conqueror-Inkslayer
      {ID=3755}, --No Book Left Unread-The Well-Versed
      {ID=3751}, --Infinite Archive Challenger-The Unending
      {ID=4152}, --Triumphant Curator-Lexiluminous
    },
  },
  {
    Name="Housing", --Housing
    Entries=
    {
      {ID=1727}, --Clan Father --Clan <<player{Father/Mother}>>
      {ID=1728}, --Lord --<<player{Lord/Lady}>>
      {ID=1729}, --Councilor --Councilor
      {ID=1730}, --Count --<<player{Count/Countess}>>
    },
  },
  {
    Name="Arena",
    Entries=
    {
      {ID=992}, --Dragonstar Arena Champion --Dragonstar Arena Champion
      {ID=1140}, --Boethiah's Scythe --Dragonstar Arena Conqueror
      {ID=1304}, --Maelstrom Arena Champion --Maelstrom Arena Champion
      {ID=1305}, --Stormproof --Maelstrom Arena Conqueror
      {ID=1330}, --The Flawless Conqueror --Maelstrom Arena: Perfect Run
      {ID=2362}, --Blackrose Condemner --Blackrose Prison Vanquisher
      {ID=2363}, --Blackrose Executioner --Blackrose Prison Conqueror
      {ID=2368}, --The Unchained --God of the Gauntlet
      {ID=2908}, --Spiritblood Champion --Vateshran Hollows Conqueror
      {ID=2912}, --Spirit Slayer --The Vateshran's Chosen
      {ID=2913}, --of the Undying Song --Hero of the Unending Song
    }
  },
  {
    Name=GetString(SI_ACTIVITY_FINDER_CATEGORY_BATTLEGROUNDS), --Battlegrounds
    Entries=
    {
      {ID=1895}, --Bloodletter --Pit Hero
      {ID=1898}, --Relic Hunter --Grand Relic Hunter
      {ID=1901}, --Relic Guardian --Grand Relic Guardian
      {ID=1904}, --Standard-Bearer --Grand Standard-Bearer
      {ID=1910}, --Conquering Hero --Conquering Hero
      {ID=1913}, --Grand Champion --Grand Champion
      {ID=1919}, --Relic Runner --Triple Threat
      {ID=1954}, --Chaos Guardian --Chaos Guardian
      {ID=1955}, --Chaos Champion --Chaos Champion
      {ID=1907}, --Standard-Guardian --Grand Standard-Guardian
      {ID=1915}, --Battleground Butcher --Battleground Butcher
      {ID=1916}, --Tactician --Tactician
      {ID=1918}, --Paragon --Paragon
      {ID=1921}, --The Merciless --Quadruple Kill
      {ID=1956}, --Chaos Keeper --Walk It Off
    }
  },
  {
    Name=GetString(SI_DUNGEON_FINDER_GENERAL_ACTIVITY_DESCRIPTOR), --Dungeon
    Entries=
    {
      {ID=1159}, --Deadlands Adept --Deadlands Savvy
      {ID=1538}, --Hist-Shadow --Shadows of the Hist Delver
      {ID=1691}, --Bane of Beastmen --Bloodroot Forge Conqueror
      {ID=1696}, --Forge Breaker --Tempered Tantrum
      {ID=1699}, --Jarl Maker --Falkreath Hold Conqueror
      {ID=1704}, --Thane of Falkreath --Taking the Bull by the Horns
      {ID=1960}, --Blackmarrow's Bane --Fang Lair Conqueror
      {ID=1965}, --Dovahkriid --Let Bygones Be Bygones
      {ID=1976}, --Peak Scaler --Scalecaller Peak Conqueror
      {ID=1981}, --Plague of Peryite --Breaker of Spells
      {ID=2153}, --Silver Knight --Moon Hunter Keep Conqueror
      {ID=2154}, --Alpha Predator --The Alpha Predator
      {ID=2163}, --Huntmaster --March of Sacrifices Conqueror
      {ID=2164}, --Hircine's Champion --Hircine's Champion
      {ID=2266}, --Frozen Treasure Seeker --Frostvault Challenger
      {ID=2275}, --Purified Devastator --Depths of Malatar Challenger
      {ID=2417}, --Hollowfang Exsanguinator --Drunk on Power
      {ID=2421}, --Chevalier --Moongrave Fane Challenger
      {ID=2427}, --Z'en's Redeemer --Selene's Savior
      {ID=2430}, --Guardian of the Green --Lair of Maarselok Challenger
      {ID=2541}, --Witch Hunter --Cold-Blooded Killer
      {ID=2546}, --Storm Foe --No Rest for the Wicked
      {ID=2551}, --Sanctifier --Skull Smasher
      {ID=2555}, --Bonecaller's Bane --In Defiance of Death
      {ID=2701}, --True Genius --True Genius
      {ID=2706}, --The Inedible --Thorn Remover
      {ID=2710}, --Bane of Thorns --Bane of Thorns
      {ID=2755}, --Pinnacle of Evolution --Triple Checked
      {ID=2833}, --Flamechaser --Snuffed Out
      {ID=2838}, --Ardent Bibliophile --Ardent Bibliophile
      {ID=2843}, --Spark of Vengeance --Schemes Disrupted
      {ID=2847}, --Subterranean Smasher --Subterranean Smasher
      {ID=3018}, --Seeker of Artifacts --Prior Offenses
      {ID=3023}, --of the Silver Rose --Bastion Breaker
      {ID=3028}, --Incarnate --Unshaken
      {ID=3032}, --The Dreaded --Battlespire's Best
      {ID=3111}, --Coral Caretaker --Land, Air, and Sea Supremacy
      {ID=3120}, --Privateer --Zero Regrets
      {ID=3153}, --Gryphon Handler --Superior Pedigree
      {ID=3154}, --Tide Turner --Shove Off
      {ID=3224}, --Shipwright --Sans Spirit Support
      {ID=3226}, --Aerie Ascender --Tentacless Triumph
      {ID=3377}, --Earthen Root Avenger -- Earthen Root Avenger
      {ID=3381}, --Invaders' Bane -- Invaders' Bane
      {ID=3396}, --Breathless -- Breathless
      {ID=3400}, --Fist of Tava -- Fist of Tava
      {ID=3470}, --Telvanni Tormentor --Scourge of Sunnar
      {ID=3474}, --Temporal Tempes --Temporal Tempest
      {ID=3525}, --Earthen Root Champion --Earthen Root Enclave Champion
      {ID=3526}, --Graven Deep Champion --Graven Deep Champion
      {ID=3531}, --Inflammable --Weaver's Bane
      {ID=3535}, --Magnastylus in the Making --Curator's Champion
      {ID=3617}, --Bal Sunnar Champion --Shadow Blessed
      {ID=3618}, --Scrivener's Hall Champion --Scribe Savior
      {ID=3812}, --Scorched but Surviving --Pitmaster
      {ID=3816}, --Lighting the Embers --Oathsworn
      {ID=3853}, --Lithe and Clever --the Self-governing
      {ID=3857}, --Unshakeable Fervor --Bedlam's Disciple
      {ID=4009}, --Oathsworn Pit Champion --the Vengeful
      {ID=4010}, --Bedlam Veil Champion --the Intervener
      {ID=4111}, --Squall Silencer-Peacemaker
      {ID=4115}, --Revenge Breaker-The Just
      {ID=4130}, --Dethroned Once More-The Unconquerable
      {ID=4134}, --Sic Semper-Moth Trusted
      {ID=4295}, --Exiled Redoubt Champion-Master Exorcist
      {ID=4296}, --Lep Seclusa Champion-The Unflinching
      {ID=4313}, --Facing Mortality-Key Master
      {ID=4317}, --Key to the Stone-Deathbringer
      {ID=4328}, --Naj-Caldeesh Champion-The Crypt Singer
      {ID=4336}, --Dispersive Defeat-Illustrious
      {ID=4340}, --Cut Above the Rest-The Brilliant
      {ID=4351}, --Black Gem Foundry Champion-Foundry's Foil
    }
  },
  {
    Name=GetString(SI_QUESTTYPE12), --Holiday Event
    Entries={
      {ID=1546}, --Sun's Dusk Reaper --An Unsparing Harvest
      {ID=1677}, --Magnanimous --Glory of Magnus
      {ID=1716}, --Lord of Misrule --<<player{Lord/Lady}>> of Misrule
      {ID=1723}, --Royal Jester --Royal Jester
      {ID=1892}, --Star-Made Knight --Star-Made Knight
      {ID=2453}, --Tin Soldier --The Upper Crust
      {ID=2458}, --Empieror --Messy Business
      {ID=2587}, --Witch --Wicked Writ Witch
      {ID=4031}, --Cake Devourer-Cake Connoisseur
    }
  },
  {
    Name=GetString(SI_QUESTTYPE17), --Tales of Tribute
    Entries={
      {ID=3349,Rank=1}, --Roister's Club Initiate --Roister's Club Initiate
      {ID=3350,Rank=2}, --Roister's Club Trainee --Roister's Club Trainee
      {ID=3351,Rank=3}, --Roister's Club Novice --Roister's Club Novice
      {ID=3352,Rank=4}, --Roister's Club Regular --Roister's Club Regular
      {ID=3353,Rank=5}, --Roister's Club Adept --Roister's Club Adept
      {ID=3354,Rank=6}, --Roister's Club Expert --Roister's Club Expert
      {ID=3355,Rank=7}, --Roister's Club Veteran --Roister's Club Veteran
      {ID=3356,Rank=8}, --Roister's Club Master --Roister's Club Master
      {ID=3342,Rank=9}, --Cardsharp --Ebony Roister
      {ID=3340,Rank=10}, --Club Contender --Quicksilver Roister
      {ID=3339,Rank=11}, --High-Stakes Gambler --Voidsteel Roister
      {ID=3338,Rank=12}, --Game-Baron --Rubedite Roister
      {ID=3325,Rank=13}, --Club Virtuoso --Tribute Tactician
    }
  },
  {
    Name=GetString(SI_GUILDACTIVITYATTRIBUTEVALUE6), --Questing
    Entries={
      {ID=1248}, --Hero of Wrothgar --Hero of Wrothgar
      {ID=1260}, --Kingmaker --Kingmaker
      {ID=1434}, --Bane of the Gold Coast-Bane of the Gold Coast
      {ID=1444}, --Silencer-Silencer
      {ID=1852}, --Champion of Vivec-Champion of Vivec
      {ID=1868}, --Savior of Morrowind --Savior of Morrowind
      {ID=1879}, --Clanfriend-Clanfriend
      {ID=2049}, --Hero of Clockwork City --Hero of Clockwork City
      {ID=2099}, --Relics of Summerset-Finder of Lost Relics
      {ID=2193}, --Savior of Summerset --Savior of Summerset
      {ID=2194}, --The Good of the Many-Emissary
      {ID=2210}, --Mystic --Psijic Sage
      {ID=2325}, --Murkmire Prepper --Cyrodilic Collections Champion
      {ID=2331}, --Hero of Murkmire --Hero of Murkmire
      {ID=2449}, --Elsweyr Defense Force Champion-Elsweyr Strategist
      {ID=2509}, --Savior of Elsweyr --Savior of Elsweyr
      {ID=2522}, --Champion of Anequina-Champion of Anequina
      {ID=2604}, --Guardian of Elsweyr --Bright Moons Over Elsweyr
      {ID=2623}, --Hero of the Dragonguard --Hero of the Dragonguard
      {ID=2658}, --A Hero's Song-Lunar Champion
      {ID=2712}, --Savior of Western Skyrim --Savior of Western Skyrim
      {ID=2716}, --Champion of Solitude-Thane of Solitude
      {ID=2751}, --Dark Delver --Companion of Lyris Titanborn
      {ID=2760}, --Shieldthane of Morthal-Shieldthane of Morthal
      {ID=2935}, --Champion of Markarth --Protector of Markarth
      {ID=2939}, --Hero of Skyrim --A Bridge Between Kingdoms
      {ID=2941}, --Guardian of the Reach --Savior of the Reach
      {ID=3047}, --Savior of Blackwood --Savior of Blackwood
      {ID=3055}, --Champion of Blackwood-Champion of Blackwood
      {ID=3145}, --Hero of Fargrave --Hero of Fargrave
      {ID=3214}, --Cataclyst Breaker --Hopeful Rescuer
      {ID=3217}, --Champion of the Deadlands --Eternal Optimist
      {ID=3218}, --Hope's Hero --Friend to the Kalmur
      {ID=3219}, --The Wretched --Spire Sleuth
      {ID=3271}, --Savior of High Isle --Savior of High Isle
      {ID=3300}, --Champion of High Isle-Three Thrones' Defender
      {ID=3462}, --Flower of Chivalry-Knight Errant
      {ID=3497}, --Volcanic Vanquisher-Mighty in Magma
      {ID=3501}, --Guardian of Galen --Savior of Galen
      {ID=3512}, --Sower's Savior --Firesong Extinguisher
      {ID=3556}, --Eye of the Queen --Buried Bequest
      {ID=3671}, --Champion of Apocrypha -- Fate's Chosen
      {ID=3674}, --Hero of Necrom --Hero of Necrom
      {ID=3950}, --Hero of the Gold Road-Hero of the Gold Road
      {ID=3985}, --Inheritor of the Scholarium-Inheritor
      {ID=4043}, --Champion of the Gold Road-Pathfinder
      {ID=4406}, --Hero of Western Solstice-Champion of the Stirk Fellowship
      {ID=61}, --Covenant Hero --Hero of the Daggerfall Covenant
      {ID=617}, --Pact Hero --Hero of the Ebonheart Pact
      {ID=618}, --Dominion Hero --Hero of the Aldmeri Dominion
      {ID=628}, --Tamriel Hero --Tamriel Expert Adventurer
      {ID=587}, --Anchors Away-Savior of Nirn
      {ID=318}, --General Executioner-Daedric Lord Slayer
      {ID=621}, --Anchor Devastator-Enemy of Coldharbour
      {ID=627}, --Tamriel Master Cave Delver-Explorer
    }
  },
  {
    Name=GetString(SI_SKILLS_SUBCLASSING_ENTRY_NAME), --Sub Classing
    Entries={
      {ID=4353}, --Dragonknight Class Mastery-Dragon Master-at-Arms
      {ID=4356}, --Sorcerer Class Mastery-Grand Sorcerer
      {ID=4359}, --Arcanist Class Mastery-Archmage of Apocrypha
      {ID=4357}, --Warden Class Mastery-Champion of the Green
      {ID=4355}, --Nightblade Class Mastery-Dark Executioner
      {ID=4354}, --Templar Class Mastery-Light's Champion
      {ID=4358}, --Necromancer Class Mastery-Grand Necromancer
      {ID=4352}, --Class Master of the Second Era-of the Second Era
    }
  },
  {
    Name=GetString(SI_GAMEPAD_SKILLS_SKY_SHARDS), --Skyshards
    Entries={
      {ID=2516}, --Craglorn Skyshard Hunter
      {ID=2513}, --Dominion Skyshard Hunter
      {ID=2514}, --Covenant Skyshard Hunter
      {ID=2515}, --Pact Skyshard Hunter
      {ID=2517}, --Cyrodiil Skyshard Hunter
    }
  },
  {
    Name=GetString(SI_BINDING_NAME_TOGGLE_SKILLS), --Skills
    Entries={
      {ID=494}, --Master Angler --Master Fisher
      {ID=702}, --Master Wizard --Arch-Mage
      {ID=703}, --Fighters Guild Victor --Fighters Guild Veteran
      {ID=1383}, --Master Thief --A Cutpurse Above
      {ID=2043}, --Undaunted --Truly Undaunted
      {ID=2227}, --Grand Master Crafter --Grand Master Crafter
      {ID=2230}, --Style Master --True Style Master
      {ID=2523}, --Scoundrel --Thieves Guild Skill Master
      {ID=2524}, --Assassin --Dark Brotherhood Skill Master
      {ID=2588}, --Locksmith --Legerdemain Skill Master
      {ID=2589}, --Siegemaster --Alliance War Skill Master
      {ID=2638}, --Soul Mage Maven --Soul Magic Skill Master
      {ID=2786}, --Sagacious Seer --Master of the Eye
      {ID=2792}, --Expert Excavator --Master of the Spade
      {ID=2805}, --Master Historian --Master Antiquarian
    }
  },
  {
    Name=GetString(SI_RAIDCATEGORY0), --Trials
    Entries={
      {ID=1391}, --Dro-m'Athra Destroyer --Maw of Lorkhaj: Moons' Champion
      {ID=1462}, --Ophidian Overlord --Sanctum Ophidia Conqueror
      {ID=1474}, --Shehai Shatterer --Hel Ra Citadel Conqueror
      {ID=1503}, --Mageslayer --Aetherian Archive Conqueror
      {ID=1808}, --Clockwork Confounder --Halls of Fabrication Completed
      {ID=1810}, --Divayth Fyr's Coadjutor --Halls of Fabrication Conqueror
      {ID=1836}, --The Dynamo --Dynamo
      {ID=1837}, --Disassembly General --Stress Tested
      {ID=1838}, --Tick-Tock Tormentor --Like Clockwork
      {ID=2075}, --Immortal Redeemer --Asylum Sanctorium Redeemer
      {ID=2076}, --Orderly --Asylum Sanctorium Completed
      {ID=2077}, --Assistant Alienist --Asylum Sanctorium Conqueror
      {ID=2079}, --Voice of Reason --Asylum Sanctorium Vanquisher
      {ID=2087}, --Saintly Savior --Perfect Purification
      {ID=2131}, --Cloudrest Hero --Cloudrest Completed
      {ID=2133}, --Shadow Breaker --Cloudrest Conqueror
      {ID=2136}, --Bringer of Light --Cloudrest Vanquisher
      {ID=2139}, --Gryphon Heart --The Path to Alaxon
      {ID=2140}, --Welkynar Liberator --Cloudrest Savior
      {ID=2433}, --Sunspire Ascendant --Sunspire Completed
      {ID=2435}, --Sunspire Saint --Sunspire Conqueror
      {ID=2466}, --Extinguisher of Flames --Sunspire Vanquisher
      {ID=2467}, --Godslayer --Godslayer of Sunspire
      {ID=2468}, --Hand of Alkosh --Sunspire Dragonbreak
      {ID=2732}, --Kyne's Chosen --Kyne's Aegis Completed
      {ID=2734}, --Kyne's Will --Kyne's Aegis Conqueror
      {ID=2739}, --Shield of the North --Kyne's Aegis Vanquisher
      {ID=2740}, --Kyne's Wrath --Stainless Siege-breaker
      {ID=2746}, --Dawnbringer --Kyne's Deliverance
      {ID=2985}, --Defender of Rockgrove --Rockgrove Completed
      {ID=2987}, --Ca-Uxith Warrior --Rockgrove Conqueror
      {ID=3003}, --Planesbreaker --Soul Savior
      {ID=3004}, --Daedric Bane --Xalvakka's Bane
      {ID=3007}, --Xalvakka's Scourge --Rockgrove Vanquisher
      {ID=3242}, --Dreadsails' Scourge --Dreadsail Reef Vanquisher
      {ID=3244}, --Seaborne Slayer --Dreadsail Reef Conqueror
      {ID=3248}, --Soul of the Squall --Fleet Queen's Foil
      {ID=3249}, --Swashbuckler Supreme --Swashbuckler Supreme
      {ID=3252}, --Hurricane Herald --Master Marine
      {ID=3558}, --Sanity's Edge Vanquisher -- Sanity's Scourge
      {ID=3560}, --Sanity's Edge Conqueror -- Sanity's Warrior
      {ID=3564}, --Master of the Mind -- Dream Master
      {ID=3565}, --Sane and Clearheaded -- Mindmender
      {ID=3568}, --Tenacious Dreamer -- Tenacious Dreamer
      {ID=4019}, --Arcane Stabilizer --the Unstoppable
      {ID=4023}, --Retrieval Specialist --the Unshattered
      {ID=4015}, --Lucent Citadel Conqueror --Crystal Sharp
      {ID=4013}, --Lucent Citadel Vanquisher --Luminous
      {ID=4020}, --Knot Worthy --Arcane Stabilizer
      {ID=4272}, --Lord of Suffering-Misery's Master
      {ID=4276}, --Served Suffering-Indomitable
      {ID=4273}, --Worth the Pain-Cista Breaker
      {ID=4266}, --Ossein Cage Vanquisher-Carnage Incarnate
      {ID=4268}, --Ossein Cage Conqueror-The Agonizer
    }
  }
}

--[[
  ==============================================
  Used function documentation
  ==============================================
--]]
ImprovedTitleizer.AllTitles={}

--{TitleID=id, CategoryID=categoryId, CategoryName=categoryName,SubCategoryID=subCategory,SubCategoryName=subCategoryName,HasTitle=hasTitle}

local TitleMenu = {}
local TitleCategories = {}
ImprovedTitleizer.TitleMenu = TitleMenu
ImprovedTitleizer.TitleCategories = TitleCategories


local GetNumAchievementCategories        = GetNumAchievementCategories
--Usage: local numAchieveCategory = GetNumAchievementCategories()
local GetAchievementCategoryInfo         = GetAchievementCategoryInfo
--Usage: local categoryName, numSubCategories, numAchievements, earnedPoints, totalPoints = GetAchievementCategoryInfo(categoryIndex)
local GetFirstAchievementInLine          = GetFirstAchievementInLine
--Usage: local firstAchievementId = GetFirstAchievementInLine(achievementID)
local GetAchievementRewardTitle          = GetAchievementRewardTitle
--Usage: local hasRewardTitle, titleName = GetAchievementRewardTitle(achievementId)
local GetNextAchievementInLine           = GetNextAchievementInLine
--Usage: nextAchievementId = GetNextAchievementInLine(achievementId)
local GetAchievementSubCategoryInfo      = GetAchievementSubCategoryInfo
--Usage: local subCategoryName, subNumAchievements = GetAchievementSubCategoryInfo(categoryIndex, subCategoryIndex)
local GetAchievementId                   = GetAchievementId
--Usage: local achievementId = GetAchievementId(categoryIndex, subcategoryIndex, achievementIndex)
local GetAchievementInfo                 = GetAchievementInfo
--Usage local name, description, points, icon, completed, date, time = GetAchievementInfo(achievementId)

-- ADDED: Titles could also be saved an an SV with a hold time for new status. That way they will remain in the Dropdown
-- as new for up to the hold time. Then, any added by the event will remain as new until mouse-over even after reload.
local newTitles = {}
local achievmentIdMap = {}

local GetTitle                           = GetTitle -- I want original titles
--Usage: local strTitle GetTitle(achievementId)

--[[
  ==============================================
  [Re-]Creates the title array for use in the addon

  Goes through each achievement to get title details
  ==============================================
--]]
local function InitializeTitles()

  ImprovedTitleizer.AllTitles = {}
  --[[
    ==============================================
    Gets title details for the specified achievement and adds to the array
    ==============================================
  --]]
  local function CheckAchievementsInLine(id, categoryId, categoryName, subCategory, subCategoryName)
    --Go through every achievement looking for if a title exists for it.
    local firstId = GetFirstAchievementInLine(id)
    id = firstId > 0 and firstId or id
    while id > 0 do
      local hasTitle, title = GetAchievementRewardTitle(id)

      if hasTitle then
        -- ADDED: to create a map of all achievement Ids that are titles, to use as reference for the EVENT_ACHIEVEMENT_AWARDED
        -- May also need to use more detail in finding titles based on achievements in the EVENT_ACHIEVEMENT_AWARDED and use
        -- that info as the map
        achievmentIdMap[id] = true

        local achieveName = GetAchievementNameFromLink(GetAchievementLink(id))
        --Baetrram: If achieveName contains a "player" placeholder it needs to be replaced via zo_strformat with GetUnitRawName("player"). Else the achieveName will look like this in the end:
        --[4]AchievementName: <<player{Königsmacher/Königsmacherin}>>
        if zo_plainstrfind(achieveName, "<<player{") ~= nil then
          achieveName = zo_strformat(achieveName, GetRawUnitName("player"))
        end
        local name, description, points, icon, completed, date, time = GetAchievementInfo(id)
        -- Just used to test the new icon in LibScrollableMenu
        --  if newTitles[name] == nil then newTitles[name] = true end
        local playerHasTitle = false
        local playerTitleIndex = -1
        for j=1,GetNumTitles() do
          if title == GetTitle(j) then
            playerHasTitle = true
            playerTitleIndex = j
            break
          end
        end
        tins(ImprovedTitleizer.AllTitles,1,{AchievementID=id,TitleID=playerTitleIndex,Title=title,CategoryID=categoryId, CategoryName=categoryName,SubCategoryID=subCategory,SubCategoryName=subCategoryName,HasTitle=playerHasTitle,AchievementName=achieveName,AchievementDescription=description},1);
      end
      id = GetNextAchievementInLine(id)
    end
  end
  for i=1,GetNumAchievementCategories() do
    local categoryName, numSubCategories, numAchievements, earnedPoints, totalPoints = GetAchievementCategoryInfo(i)
    for j=1,numAchievements do
      CheckAchievementsInLine(GetAchievementId(i,nil,j), i, categoryName)
    end

    for j=1,numSubCategories do
      local subCategoryName, subNumAchievements = GetAchievementSubCategoryInfo(i, j)
      for k=1,subNumAchievements do
        CheckAchievementsInLine(GetAchievementId(i,j,k), i, categoryName, j,subCategoryName)
      end
    end
  end
  for i,sub in pairs(ImprovedTitleizer.AchievmentIdsCategories) do
    if (sub.Name==GetString(SI_AVA_MENU_ALLIANCE_WAR_GROUP)) then
      for j,rank in pairs(sub.Entries) do
        rank.Icon=GetAvARankIcon(j*2)
      end
    end
  end

  for i = 1, GetNumTitles() do
      local found = false
      for _, entry in ipairs(ImprovedTitleizer.AllTitles) do
          if entry.TitleID == i then
              found = true
              break
          end
      end
      if not found then
          local titleName = GetTitle(i)
          table.insert(ImprovedTitleizer.AllTitles, {
              AchievementID = -1, -- or set as appropriate
              TitleID = i,
              Title = titleName,
              CategoryID = -1,
              CategoryName = "No Achievement",
              SubCategoryID = -1,
              SubCategoryName = "",
              HasTitle = true,
              AchievementName = "No Achievement",
              AchievementDescription = "No Achievement",
          })
      end
  end
  ImprovedTitleizer.savedVariables.numTitles = GetNumTitles()
  ImprovedTitleizer.savedVariables.titleDetails = ImprovedTitleizer.AllTitles
end
--[[
  ==============================================
  Contstruct the Title Menu array
  ==============================================
--]]
local function ConstructTitleMenu()
--d("[ImprovedTitleizer]ConstructTitleMenu")

  local doDebug = ImprovedTitleizer.Debug
  local showmissingtitles = ImprovedTitleizer.savedVariables.showmissingtitles
  local sv = ImprovedTitleizer.savedVariables
  local sortByAchievementCategory = sv.sortbyachievecat

  TitleMenu = {}
  TitleCategories ={}
  local subMenus={}

  for i,sub in pairs(ImprovedTitleizer.AchievmentIdsCategories) do
    subMenus[sub.Name]={Entries={},Categories={}}
  end
  for i,vTitle in pairs(ImprovedTitleizer.AllTitles) do

    local titlePlaced = false
    local isEnabled = true
    local title = vTitle.Title
    local hasTitle = vTitle.HasTitle
    local catTitle =vTitle.CategoryName
    local toolTip = GetString(SI_GAMEPAD_ACHIEVEMENTS_CHARACTER_PERSISTENT)..":\n"..vTitle.AchievementName

    if(not vTitle.HasTitle and (doDebug or showmissingtitles)) then
      toolTip = GetString(SI_INPUT_LANGUAGE_UNKNOWN) .. "\n" .. toolTip
      isEnabled = true; --enable it to show tooltip
    else isEnabled = true;
    end;

    if doDebug then
      catTitle=catTitle.." #"..vTitle.CategoryID
      title = title.."  #"..vTitle.TitleID.."  HasTitle:".. tostring(vTitle.HasTitle).."  CategoryID:"..tostring(vTitle.CategoryID)
    end

    for k, vCategory in pairs(ImprovedTitleizer.AchievmentIdsCategories) do
      for j,q in pairs(vCategory.Entries) do
        if vTitle.AchievementID==q.ID and titlePlaced==false then
          if newTitles[vTitle.Title] then
            vCategory.hasNew = true
          end
          if(titlePlaced==false) then
            titlePlaced=true
            if (hasTitle or doDebug or showmissingtitles) then
              local newEntry = {
                sortName = title,
                name=(hasTitle and title) or ((doDebug or showmissingtitles) and "|cFF0000" .. title .. "|r"),
                categoryId=vTitle.CategoryID,
                isHeader=false,
                rank=q.Rank or 0,
                icon = q.Icon,
                enabled = function() return isEnabled end,
                callback= (hasTitle and function() SelectTitle(vTitle.TitleID) end) or nil,
                tooltip=toolTip,
                isNew = newTitles[vTitle.Title] or nil
              }
              tins(subMenus[vCategory.Name].Entries, newEntry)
              if(subMenus[vCategory.Name].Categories[vTitle.CategoryName]==nil) then
                subMenus[vCategory.Name].Categories[vTitle.CategoryName] ={
                  name=catTitle,
                  categoryId=vTitle.CategoryID,
                  isHeader=true,
              }
              end
            end
          end
        end
      end
    end
    if titlePlaced == false and (hasTitle or doDebug or showmissingtitles) then
      if TitleCategories[vTitle.CategoryName]==nil then
        TitleCategories[vTitle.CategoryName] ={
          name=catTitle,
          categoryId=vTitle.CategoryID,
          isHeader=true,
        }
      end
      tins(
        TitleMenu,
        {
          sortName = title,
          name=(hasTitle and title) or ((doDebug or showmissingtitles) and "|cFF0000" .. title .. "|r"),
          categoryId=vTitle.CategoryID,
          isHeader=false, rank = 0,
          callback=(hasTitle and function() SelectTitle(vTitle.TitleID) end) or nil,
          tooltip=toolTip,enabled = function() return isEnabled end
        })
    end
  end

  --add headers
  if sortByAchievementCategory then
    for header, menu in spairs(subMenus) do
      for _, cat in pairs(menu.Categories) do
        tins(menu.Entries, cat)
      end
    end

    for _, cat in pairs(TitleCategories) do
      tins(TitleMenu, cat)
    end
  end

  --sort uncategorized titles
  if sortByAchievementCategory then
    tsort(TitleMenu, function(item1, item2) return ZO_TableOrderingFunction(item1, item2, "categoryId",{["categoryId"]={tiebreaker = "isHeader",isNumeric=true,tieBreakerSortOrder=ZO_SORT_ORDER_DOWN},["isHeader"]={tiebreaker = "sortName",tieBreakerSortOrder = ZO_SORT_ORDER_UP},["sortName"]={caseInsensitive=true}}, ZO_SORT_ORDER_UP) end)
  else
    tsort(TitleMenu, function(item1, item2) return ZO_TableOrderingFunction(item1, item2, "sortName",{["sortName"]={caseInsensitive=true}}, ZO_SORT_ORDER_UP) end)
  end

  --sort sub-categories
  local i = 1
  for header, titles in spairs(subMenus) do
    if(tgetn(titles.Entries) > 0) then
      if header==GetString(SI_AVA_MENU_ALLIANCE_WAR_GROUP) then --Alliance War
        tsort(titles.Entries, function(item1, item2) return ZO_TableOrderingFunction(item1, item2, "isHeader", {["isHeader"]={tiebreaker = "rank",tieBreakerSortOrder=ZO_SORT_ORDER_UP},["rank"] = {isNumeric = true}} , ZO_SORT_ORDER_DOWN) end)
      elseif header==GetString(SI_QUESTTYPE17) then  --Tribute
        tsort(titles.Entries, function(item1, item2) return ZO_TableOrderingFunction(item1, item2, "isHeader", {["isHeader"]={tiebreaker = "rank",tieBreakerSortOrder=ZO_SORT_ORDER_UP},["rank"] = {isNumeric = true}} , ZO_SORT_ORDER_DOWN) end)
      else
        if sortByAchievementCategory then
          tsort(titles.Entries, function(item1, item2) return ZO_TableOrderingFunction(item1, item2, "categoryId",{["categoryId"]={tiebreaker = "isHeader",isNumeric=true,tieBreakerSortOrder=ZO_SORT_ORDER_DOWN},["isHeader"]={tiebreaker = "sortName",tieBreakerSortOrder = ZO_SORT_ORDER_UP},["sortName"]={caseInsensitive=true}}, ZO_SORT_ORDER_UP) end)
        else
          tsort(titles.Entries, function(item1, item2) return ZO_TableOrderingFunction(item1, item2, "sortName",{["sortName"]={caseInsensitive=true}}, ZO_SORT_ORDER_UP) end)
        end
      end
      tins(TitleMenu, i, {name=header, entries=titles.Entries, isNew = titles.hasNew})
      i = i + 1
    end
  end
  -- add divider below "No Title" if there is more
  if #TitleMenu > 0 then
    tins(TitleMenu, 1, {name=LSM.DIVIDER})
    i = i + 1
  end
  -- add divider below last submenu if there is more
  if i <= #TitleMenu then
    tins(TitleMenu, i, {name=LSM.DIVIDER})
  end

  ImprovedTitleizer.TitleMenu = TitleMenu
  ImprovedTitleizer.TitleCategories = TitleCategories
  ImprovedTitleizer.TitleSubMenus = subMenus
end
--[[
  ==============================================
  Adjust the UI
  ==============================================
--]]
local wasAlreadyReplacingZO_StatsFuncs = false

local function updateStatsTitleDropdownOptions()
  if STATS.titleDropdownRow ~= nil then
    local sv = ImprovedTitleizer.savedVariables
    SetCustomScrollableMenuOptions(
            {visibleRowsDropdown=sv.visibleRowsDropdown, visibleRowsSubmenu=sv.visibleRowsSubmenu, sortEntries=false},
            STATS.titleDropdownRow.combobox
    )
  end
end

local origDropdownClearItems

local function UpdateTitleDropdownTitles(self, dropdown)
  --d("[ImprovedTitleizer]UpdateTitleDropdownTitles - dropdown: " ..tostring(dropdown))
  if dropdown == nil then return end
  if origDropdownClearItems == nil then
    origDropdownClearItems = dropdown.ClearItems
    dropdown.ClearItems = function(selfCtrl)
--d("[ImprovedTitleizer]dropdown.ClearItems called - dropdown: " ..tostring(selfCtrl))
      origDropdownClearItems(selfCtrl)
    end
  end

  dropdown:ClearItems()
  dropdown:AddItem(ZO_ComboBox:CreateItemEntry(GetString(SI_STATS_NO_TITLE), function() SelectTitle(nil) end), ZO_COMBOBOX_SUPRESS_UPDATE)

  ConstructTitleMenu()

  dropdown:AddItems(TitleMenu)

  self:UpdateTitleDropdownSelection(dropdown)
end

local updateTitleWasDone = false

local function SetupTitleEventManagement()
  if wasAlreadyReplacingZO_StatsFuncs then return end

  local orgAddDropdownRow = STATS.AddDropdownRow
  STATS.AddDropdownRow = function(self, rowName)
    local isTitleRow = (rowName == GetString(SI_STATS_TITLE) and true) or false
    --d("[ImprovedTitleizer]STATS.AddDropdownRow - rowName: " ..tostring(rowName) .. ", isTitle: " ..tostring(isTitleRow))

    local control = orgAddDropdownRow(self, rowName)
    local comboBox = control:GetNamedChild("Dropdown")
    control.combobox = comboBox

    --Are we creating the title dropdown box?
    if isTitleRow == true then
      local sv = ImprovedTitleizer.savedVariables

      --control.scrollHelper = LSM.ScrollableDropdownHelper:New(self.control, control, 16) --use the API function instead
      --Prevent duplicate LibScrollableMenu init
      if control.scrollHelper == nil then
        control.scrollHelper = AddCustomScrollableComboBoxDropdownMenu(
                self.control, --STATS.titleDropdownRow
                comboBox,
                {visibleRowsDropdown=sv.visibleRowsDropdown, visibleRowsSubmenu=sv.visibleRowsSubmenu, sortEntries=false,
                 enableFilter=true, headerCollapsible=true, headerCollapsed=true, --show search editbox at header, but automatically collapse the header by default
                  headerCollapsedIcon = function() return {
                      iconTexture="/esoui/art/miscellaneous/search_icon.dds",
                      width=20,
                      height=20,
                      --iconTint=CUSTOM_HIGHLIGHT_TEXT_COLOR,
                      align = LEFT,
                      offsetX = 20,
                      offSetY = 0,
                  } end,
                 --[[ Custom tooltip e.g. 'Click to expand and show the search', which would need translation though.. So disabled for now, icon shoudl be enough
                  headerToggleTooltip = function(state)
                      if state == BSTATE_PRESSED then
                          return GetString(SI_ITEM_SETS_BOOK_HEADER_EXPAND)
                      else
                          return GetString(SI_ITEM_SETS_BOOK_HEADER_COLLAPSE)
                      end
                  end,
                  ]]
                }

        )
      end
      control.scrollHelper.OnShow = function() end --don't change parenting

      ImprovedTitleizer.titleDropdownRow = control
      updateTitleWasDone = true
    end

    return control
  end

  -- Old function from before 8.2.5
  -- New function gets the selected item by string value, new function selects by index (which is scambled due to the sorting)
  function UpdateTitleDropdownSelection(self, dropdown)
    local currentTitleIndex = GetCurrentTitleIndex()
    if currentTitleIndex then
      dropdown:SetSelectedItemText(zo_strformat(GetTitle(currentTitleIndex), GetRawUnitName("player")))
    else
      dropdown:SetSelectedItemText(GetString(SI_STATS_NO_TITLE))
    end
  end

  if STATS and STATS.UpdateTitleDropdownTitles then
--d("[ImprovedTitleizer]STATS.UpdateTitleDropdownTitles hooked")
    STATS.UpdateTitleDropdownTitles = UpdateTitleDropdownTitles
    STATS.UpdateTitleDropdownSelection = UpdateTitleDropdownSelection
  end

  SecurePostHook(STATS, "OnShowing", function()
    local isInitialized = STATS.initialized
--d("[ImprovedTitleizer]STATS.OnShowing - initialized: " .. tostring(isInitialized))
    if isInitialized and updateTitleWasDone and ImprovedTitleizer.titleDropdownRow ~= nil then
      STATS:UpdateTitleDropdownTitles(ImprovedTitleizer.titleDropdownRow.dropdown)
    end
  end)
  wasAlreadyReplacingZO_StatsFuncs = true
end


local function SetupDebug()

  if ImprovedTitleizer.savedVariables.debug == true then
    ImprovedTitleizer.logger = LibDebugLogger.Create(ImprovedTitleizer.Name)
    ImprovedTitleizer.logger:Info("Loaded logger")
    SLASH_COMMANDS["/refreshtitles"] = function()
      InitializeTitles()
    end
    SLASH_COMMANDS["/debugtitles"] = function()
      ImprovedTitleizer.Imp_DebugToggle()
    end
  else
    ImprovedTitleizer.logger = nil
    SLASH_COMMANDS["/refreshtitles"] = nil
    SLASH_COMMANDS["/debugtitles"] = nil
  end
end
--[[
  ==============================================
  Plugin Initialization - cache titles where possible, recreate when necessary
  ==============================================
--]]
local function OnLoad(eventCode, name)

  if name ~= ImprovedTitleizer.Name then return end
  EVENT_MANAGER:UnregisterForEvent(ImprovedTitleizer.Name, EVENT_ADD_ON_LOADED)

  ImprovedTitleizer.savedVariables = ZO_SavedVars:NewAccountWide("ImprovedTitleizerSavedVariables", 1, GetWorldName(), defaultSVs)

  if ImprovedTitleizer.savedVariables.lastversion == nil or ImprovedTitleizer.savedVariables.lastversion ~= ImprovedTitleizer.Version then
    if ImprovedTitleizer.logger ~= nil then ImprovedTitleizer.logger:Info("New version of addon installed, recreating.") end
    InitializeTitles()
  elseif ImprovedTitleizer.savedVariables.lastESOversion == nil or ImprovedTitleizer.savedVariables.lastversion ~= GetESOVersionString() then
    if ImprovedTitleizer.logger ~= nil then ImprovedTitleizer.logger:Info("New version of ESO installed, recreating.") end
    InitializeTitles()
  elseif ImprovedTitleizer.savedVariables.numTitles == nil or ImprovedTitleizer.savedVariables.titleDetails == nil then
    if ImprovedTitleizer.logger ~= nil then ImprovedTitleizer.logger:Info("New or corrupt saved variables, recreating.") end
    InitializeTitles()
  elseif ImprovedTitleizer.savedVariables.numTitles ~= GetNumTitles() then
    if ImprovedTitleizer.logger ~= nil then ImprovedTitleizer.logger:Info("New titles exist, recreating.") end
    InitializeTitles()
  else
    if ImprovedTitleizer.logger ~= nil then ImprovedTitleizer.logger:Info("Loading titles from saved variables.") end
    ImprovedTitleizer.AllTitles=ImprovedTitleizer.savedVariables.titleDetails
  end

  ImprovedTitleizer.savedVariables.lastversion = ImprovedTitleizer.Version
  ImprovedTitleizer.savedVariables.lastESOversion = GetESOVersionString()

  SetupTitleEventManagement()

  --LibScrollableMenu
  LSM:RegisterCallback('NewStatusUpdated', function(entry, data)
      -- This callback is fired on mouse-over of entries that were flagged as new.
      if newTitles[data.name] then
          newTitles[data.name] = nil
      end
  end)

--[[
  ==============================================
  On new achievement, recreate the title list and update "new" flags for LSM
  ==============================================
--]]
  local function OnAchievementsAwarded(eventCode, name, points, id)
    if ImprovedTitleizer.logger ~= nil then ImprovedTitleizer.logger:Info("New achievement awarded: " .. tostring(name) .. ", ID: " ..tostring(id)) end
    InitializeTitles()

      -- This seams to work to update LibScrollableMenu needed information for "new" flags
      if achievmentIdMap[id] then
        newTitles[name] = true
        -- I don't think we need to force any refresh here since the menu is not going to be open at the time
      end
  end

  EVENT_MANAGER:RegisterForEvent(ImprovedTitleizer.Name, EVENT_ACHIEVEMENT_AWARDED, OnAchievementsAwarded)

  local menuOptions = {
    type                = "panel",
    name                = ImprovedTitleizer.DisplayName,
    displayName         = ImprovedTitleizer.DisplayName,
    author              = ImprovedTitleizer.Author,
    version             = ImprovedTitleizer.Version,
    registerForRefresh  = true,
    registerForDefaults = true,
  }

	local dataTable = {
		{
			type = "description",
			text = "Sorts titles in the Character title dropdown.",
		},
		{
			type = "divider",
		},
		{
			type    = "checkbox",
			name    = "Debug",
			getFunc = function() return ImprovedTitleizer.savedVariables.debug end,
			setFunc = function( newValue ) ImprovedTitleizer.savedVariables.debug = newValue; SetupDebug(); end,
		},
		{
			type = "divider",
		},
		{
			type    = "checkbox",
			name    = "Sort by Achievement Category",
			getFunc = function() return ImprovedTitleizer.savedVariables.sortbyachievecat end,
			setFunc = function( newValue ) ImprovedTitleizer.savedVariables.sortbyachievecat = newValue; ConstructTitleMenu() end,
      warning = "Sorts the achievements by it'S category and not by name",	--(optional)
      requiresReload = true,
		},
		{
			type    = "checkbox",
			name    = "Show missing titles",
			getFunc = function() return ImprovedTitleizer.savedVariables.showmissingtitles end,
			setFunc = function( newValue ) ImprovedTitleizer.savedVariables.showmissingtitles = newValue; ConstructTitleMenu() end,
      warning = "Shows unknown titles i the list (disabled, non-seleactable)",	--(optional)
      requiresReload = true,
		},
		{
			type    = "slider",
			name    = "Shown entries in dropdown",
      min = 3,
      max = 30,
			getFunc = function() return ImprovedTitleizer.savedVariables.visibleRowsDropdown end,
			setFunc = function( newValue )
              ImprovedTitleizer.savedVariables.visibleRowsDropdown = newValue
              updateStatsTitleDropdownOptions()
            end,
		},
		{
			type    = "slider",
			name    = "Shown entries in submenus",
      min = 3,
      max = 30,
			getFunc = function() return ImprovedTitleizer.savedVariables.visibleRowsSubmenu end,
			setFunc = function( newValue )
              ImprovedTitleizer.savedVariables.visibleRowsSubmenu = newValue
              updateStatsTitleDropdownOptions()
            end,
		},
	}
	local LAM = LibAddonMenu2
	LAM:RegisterAddonPanel(ImprovedTitleizer.Name .. "Options", menuOptions )
	LAM:RegisterOptionControls(ImprovedTitleizer.Name .. "Options", dataTable )

  ImprovedTitleizer.InitDebugGui()

  SetupDebug()
end

--[[
  ==============================================
  AddOn global and loading
  ==============================================
--]]
IMPROVEDTITLEIZER = ImprovedTitleizer
EVENT_MANAGER:RegisterForEvent(ImprovedTitleizer.Name, EVENT_ADD_ON_LOADED, OnLoad)
