----------------
-- EchosOfLore--
----------------

--The Data!
EchoesOfLore.Zones = {}
EchoesOfLore.SubZones = {}
EchoesOfLore.Dungeons = {}

--
function EchoesOfLore:setupBaseBoss(dungeonName,bossName,bossOrder,order,key,value)
  if(EchoesOfLore.Dungeons[dungeonName].bosses==nil)then
    EchoesOfLore.Dungeons[dungeonName].bosses = {}
  end
  if(EchoesOfLore.Dungeons[dungeonName].bosses[bossName]==nil)then
    EchoesOfLore.Dungeons[dungeonName].bosses[bossName] = {
        bossName = bossName,
        order    = bossOrder,
        metadata = {},
        text     = {}
    }
  end
  EchoesOfLore.Dungeons[dungeonName].bosses[bossName].text[key] = {
      order = order,
      text = value,
  }
end

--
function EchoesOfLore:setupBaseDungeon(dungeonName,description,isVetData,isDLC)
  if(EchoesOfLore.Dungeons[dungeonName]==nil)then
    EchoesOfLore.Dungeons[dungeonName] = {}
  end
  --Initialize Data
  EchoesOfLore.Dungeons[dungeonName].bosses = {}
  EchoesOfLore.Dungeons[dungeonName].vet = {}
  EchoesOfLore.Dungeons[dungeonName].metadata = {}
  --Setup passed in Data
  EchoesOfLore.Dungeons[dungeonName].text = {
    overview = description
  }
  EchoesOfLore.Dungeons[dungeonName].dungeonName = dungeonName
  EchoesOfLore.Dungeons[dungeonName].metadata.dungeonName = dungeonName
    
  --TODO isVetData
  
  --isDLC
  if(isDLC~=nil)then
    EchoesOfLore.Dungeons[dungeonName].isDLC = true
    EchoesOfLore.Dungeons[dungeonName].metadata.isDLC = true
  else
    EchoesOfLore.Dungeons[dungeonName].isDLC = false
    EchoesOfLore.Dungeons[dungeonName].metadata.isDLC = false
  end
end

function EchoesOfLore:setupZoneData(name,orderV,keyV,valueV)
  if(EchoesOfLore.Zones==nil)then
    EchoesOfLore.Zones = {}
  end
  if(EchoesOfLore.Zones[name]==nil)then
    EchoesOfLore.Zones[name] = {}
  end
  if(EchoesOfLore.Zones[name][keyV]==nil)then
    EchoesOfLore.Zones[name][keyV] = {
        name  = keyV,
        order = orderV,
        value = valueV,
    }
  end
end

function EchoesOfLore:setupSubZoneData(subzoneId,nameV,orderV,keyV,valueV)
  if(EchoesOfLore.SubZones==nil)then
    EchoesOfLore.SubZones = {}
  end
  local key = string.format("%s-%d",nameV,subzoneId)
  if(EchoesOfLore.SubZones[key]==nil)then
    EchoesOfLore.SubZones[key] = {}
  end
  if(EchoesOfLore.SubZones[key][keyV]==nil)then
    EchoesOfLore.SubZones[key][keyV] = {
        name  = nameV,
        key   = keyV,
        id    = subzoneId,
        order = orderV,
        value = valueV,
    }
  end
end

--DataFormat: EchoesOfLore.Tips["PVP"]["Golden Vendor"] = "The golden vendor is at..."
function EchoesOfLore:setupTipData(parentV,nameV,shortV,orderV,textV)
  EchoesOfLore:debugMsg("setupTipData: parentV='"..parentV.."' nameV='"..nameV.."'" )  
  if(EchoesOfLore.Tips==nil)then
    EchoesOfLore.Tips = {}
  end
  if(EchoesOfLore.Tips[parentV]==nil)then
    EchoesOfLore.Tips[parentV] = {}
  end
  EchoesOfLore.Tips[parentV][nameV] = {
      parentV=parentV,
      name  = nameV,
      order = orderV,
      text  = textV,
      short = shortV,
  }
end

-- -- --
-- -- -- 
function EchoesOfLore:InitializeData()
  EchoesOfLore:setupZones()
  EchoesOfLore:setupSubZones()
  EchoesOfLore:setupDungeons()
  EchoesOfLore:SetupTips()
end

function EchoesOfLore:SetupTips()
  local parent, name, short = nil
  local order = 0
  ---------
  order = 0
  parent = "PVP"
  name   = "Golden Vendor"  
  short  = "golden vendor"
  order  = order+1
  --parentV,nameV,shortV,orderV,textV)
  EchoesOfLore:setupTipData(parent,name,short,order,"The golden vendor is in one of the two starting bases of your pvp faction in cyrodil")
  ---------
  
  ---------
  order = 0
  parent = "General"
  name   = "Mounts"
  short  = "mount mounts horse ride vehicle"
  order  = order+1
  --parentV,nameV,shortV,orderV,textV)
  EchoesOfLore:setupTipData(parent,name,short,order,"Mounts are found in your collections (U) and are bound to the (H) key.")
  ---------
  parent = "General"
  name   = "Food and Drink"
  short  = "food and drink"
  order  = order+1
  --parentV,nameV,shortV,orderV,textV)
  EchoesOfLore:setupTipData(parent,name,short,order,"You can NOT have a food and drink buff active at the same time. You can use a potion while under the effects of either though.")
  ---------
  
end

function EchoesOfLore:setupSubZones()  
  local name, bName = nil
  local subzoneId, order = 0
  ---------
  name = "Temple of the Eight" 
  subzoneId = 7422
  bName = "Description"
  order = 0
  EchoesOfLore:setupSubZoneData(subzoneId,name,order,bName,"The Temple of the Eight is an old temple in central Grahtwood, northwest of Elden Root. The temple is home to a special crafting site, where you may craft items in the Armor of the Seducer set. It is guarded by the Brackenleaf's Briars, and an Orc named Agstarg resides within the Divine Sanctum.")
  ---------
  name = "Bergama" 
  subzoneId = 7531
  bName = "Description"
  order = 0
  EchoesOfLore:setupSubZoneData(subzoneId,name,order,bName,"Bergama is a city in western Hammerfell, best known for being an enclave of the Alik'r Desert.")
  ---------
  ---------
  name = "Alcaire Castle" 
  subzoneId = 11
  bName = "Description"
  order = order+1
  EchoesOfLore:setupSubZoneData(subzoneId,name,order,bName,"Alcaire Castle is a castle in northwestern Stormhaven. It is ruled over by Duke Nathaniel and is where he and his wife, Duchess Lakana, make their home. Many Knights of the Flame also reside here as the protectors of the Duke and Duchess. The Dukes of Alcaire have been ruling over western Stormhaven since the late First Era.")

  ---------
  ---------
  ---------
  ---------
end
  
function EchoesOfLore:setupZones()  
  local name, bName = nil
  local order = 0
  ---------
  name = "Eastmarch"  
  bName = "Description"
  order = order+1
  EchoesOfLore:setupZoneData(name,order,bName,"Eastmarch stretches from the frozen, jagged northern coastline into southern's Skyrim's volcanic tundra. Eastmarch is one of the nine Holds of Skyrim, located along the eastern border. It is one of the four oldest holds in Skyrim, known collectively as Old Holds.")
  bName = "Overland Sets"
  order = order+1
  EchoesOfLore:setupZoneData(name,order,bName,"Akaviri Dragonguard Set, Fiord's Legacy Set, Stendarr's Embrace Set.")
  ---------
  name = "Betnikh"  
  bName = "Description"
  order = 1
  --http://elderscrolls.wikia.com/wiki/Loading_Screens_(Online)
  EchoesOfLore:setupZoneData(name,order,bName,"Nine generations ago, the island of Betony was conquered by the Stonetooth Orcs, who renamed it Betnikh. A proud, self-reliant people, Orcs fiercely protect their new home from incursions by outsiders. This small island was originally under Breton control, however it is now occupied by Orcs.")
  bName = "Overland Sets"
  order = order+1
  EchoesOfLore:setupZoneData(name,order,bName,"Betnikh has the following Overland Sets: Armor of the Trainee Set.")
  ---------
  name = "Stonefalls"  
  bName = "Description"
  order = 1
  EchoesOfLore:setupZoneData(name,order,bName,"Stonefalls is a zone in central Morrowind. This diverse area features landscapes ranging from fungal forests to barren volcanic crags, and is home to the cities of Davon's Watch, Ebonheart and Kragenmoor.")
  bName = "Overland Sets"
  order = order+1
  EchoesOfLore:setupZoneData(name,order,bName,"Stonefalls has the following Overland Sets: Shadow of the Red Mountain Set, Shalk Exoskeleton Set, Silks of the Sun Set.")
  bName = "Lore"
  order = order+1
  EchoesOfLore:setupZoneData(name,order,bName,"In northern Zabamat lies the Ebonheart Pact-controlled Fort Virak, which protects the border with Skyrim from the wild creatures of Stonefalls such as the ferocious Alits and Kagouti. Also in Zabamat is the Fungal Grotto, the base of the Murkwater Goblins and a hidden shrine to Mephala. In Zabamat, the central region of Stonefalls, lies the city of Ebonheart, which is home to a large population of Argonians, who are highly distrustful of the Dunmer living in the city.")
  ---------
  name = "Shadowfen"  
  bName = "Description"
  order = 1
  EchoesOfLore:setupZoneData(name,order,bName,"On the border with Morrowind, the Shadowfen region has had more contact with Tamrielic civilization than most of Black Marsh—due primarily to the activities of the Dunmeri slavers who once operated out of the city of Stormhold. Now the Argonians are back in charge.")
  bName = "Lore"
  order = order+1
  EchoesOfLore:setupZoneData(name,order,bName,"It is a fetid mire, often fought over by the Imperial Legion and Dunmer slavers. The ancient city of Stormhold is located here, the source of the devastating (to non-Argonians) Knahaten Flu. Though the practice of Argonian slavery was abandoned when Black Marsh joined the Ebonheart Pact, rogue Dunmeri slave traders can still be found roaming the marshes. Hist trees and ruined temples can also be found along the winding channels and dank foliage.")
  bName = "Overland Sets"
  order = order+1
  EchoesOfLore:setupZoneData(name,order,bName,"Shadowfen has the following Overland Sets: Hatchling's Shell Set, Robes of the Hist Set, Swamp Raider Set.")
  
  ---------
  name = "Alik'r Desert"  
  bName = "Description"
  order = 1
  EchoesOfLore:setupZoneData(name,order,bName, "An arid wasteland where ancient ruins and deadly creatures lie hidden in the shifting sands. This area has 16 Skyshards and 3 achivements.")
  bName = "Overland Sets"
  order = order+1
  EchoesOfLore:setupZoneData(name,order,bName,"Alik'r Desert has the following Overland Sets: Order of Diagna Set, Robes of the Withered Hand Set, Sword-Singer Set.")
  ---------
  name = "Summerset"  
  bName = "Description"
  order = 1
  EchoesOfLore:setupZoneData(name,order,bName, "Out of the three main islands, Summerset is the largest, and also contains the capital of the Summerset Isles, Alinor. To the east of Summerset is Auridon, which is closer to Tamriel and is the second largest of the three islands. The Isle of Artaeum used to be on Nirn, but has since vanished, though can still be visited..")
  bName = "Overland Sets"
  order = order+1
  EchoesOfLore:setupZoneData(name,order,bName,"Summerset has the following Overland Sets: Wisdom of Vanus , Gryphon’s Ferocity, Grace of Gloom.")
    ---------
  name = "Reaper's Marsh"  
  bName = "Description"
  order = 1
  EchoesOfLore:setupZoneData(name,order,bName, "Once known simply as Northern Valenwood, this region that borders Cyrodiil and Elsweyr has seen so much bloody warfare since the fall of the Second Empire that it's now known as Reaper's March, even to its battle-scarred inhabitants.")
  bName = "Overland Sets"
  order = order+1
  EchoesOfLore:setupZoneData(name,order,bName,"Reaper's March has the following Overland Sets: Senche's Bite Set, Skooma Smuggler Set and Soulshine Set.")
  ---------
  name = "Bleakrock"
  bName = "Description"
  order = 1
  EchoesOfLore:setupZoneData(name,order,bName, "Bleakrock is an island off the coast of Skyrim between Windhelm and Solstheim. The hardy Nords who inhabit Bleakrock are mostly farmers and fisherfolk. A small contingent of Pact soldiers keeps a sharp lookout for pirates and raiders.")
  ---------
  name = "Auridon"
  bName = "Description"
  order = 1
  --http://elderscrolls.wikia.com/wiki/Loading_Screens_(Online)
  EchoesOfLore:setupZoneData(name,order,bName, "The second largest of the Summerset Isles, Auridon has always served the High Elves as a buffer between their serene archipelago and the turmoil of Tamriel. The Altmer of Auridon have been hardened by generations of repelling invaders, pirates and plagues.")
  
  ---------
  
  ---------
  
end

function EchoesOfLore:setupDungeons()  
  EchoesOfLore.Dungeons = {
      ["Fungal Grotto 1"]   = { order=1 } ,
      ["Fungal Grotto 2"]   = { order=2 } ,
      ["Spindleclutch 1"]   = { order=3 } ,
      ["Spindleclutch 2"]   = { order=4 } ,
      ["The Banished Cells 1"]  = { order=5 } ,
      ["The Banished Cells 2"]  = { order=6 } ,
      ["Darkshade Caverns 1"]   = { order=7 } ,
      ["Darkshade Caverns 2"]   = { order=8 } ,
      ["Elden Hollow 1"]    = { order=9 } ,
      ["Elden Hollow 2"]    = { order=10 } ,
      ["Wayrest Sewers 1"]  = { order=11 } ,
      ["Wayrest Sewers 2"]  = { order=12 } ,
      ["Arx Corinium"]      = { order=13 } ,
      ["City of Ash 1"]  = { order=14 } ,
      ["City of Ash 2"]  = { order=15 } ,
      ["Crypt of Hearts 1"]  = { order=16 } ,
      ["Crypt of Hearts 2"]  = { order=17 } ,
      ["Direfrost Keep"]     = { order=18 } ,
      ["Tempest Island"]     = { order=19 } ,
      ["Volenfell"]          = { order=20 } ,
      ["Blackheart Haven"]   = { order=21 } ,
      ["Blessed Crucible"]   = { order=22 } ,
      ["Selene's Web"]       = { order=23 } ,
      ["Vaults of Madness"]  = { order=24 } ,
      --["White-Gold Tower"] = { order=25 } ,
  }
  EchoesOfLore:setupFungalGrotto1()  
  EchoesOfLore:setupFungalGrotto2()  
  EchoesOfLore:setupSpindleclutch1()  
  EchoesOfLore:setupSpindleclutch2()  
  EchoesOfLore:setupTheBanishedCells1()
  EchoesOfLore:setupTheBanishedCells2()
  EchoesOfLore:setupDarkshadeCaverns2()
  EchoesOfLore:setupDarkshadeCaverns2()
  EchoesOfLore:setupEldenHollow1()
  EchoesOfLore:setupEldenHollow2()
  EchoesOfLore:setupWayrestSewers1()  
  EchoesOfLore:setupWayrestSewers2()  
  EchoesOfLore:setupArxCorinium()    
  EchoesOfLore:setupCityOfAsh1()
  EchoesOfLore:setupCityOfAsh2()
  EchoesOfLore:setupCryptOfHearts1()
  EchoesOfLore:setupCryptOfHearts2()
  EchoesOfLore:setupDirefrostKeep()
  EchoesOfLore:setupTempestIsland()
  EchoesOfLore:setupVolenfell()
  EchoesOfLore:setupBlackheartHaven()  
  EchoesOfLore:setupBlessedCrucible()
  EchoesOfLore:setupSelenesWeb()
  EchoesOfLore:setupVaultsOfMadness()
  
  --DLC
  --EchoesOfLore:setupWhiteGoldTower()
end


-------
-------

function EchoesOfLore:setupFungalGrotto1()
  local dungeonName = "Fungal Grotto 1"
  local description = "A dungeon."
  EchoesOfLore:setupBaseDungeon(dungeonName,description)
  local bName, order = nil, 0
  
  ---------
  bName = "Tazkad the Packmaster"
  order = order+1
  --EchoesOfLore:setupBaseBoss(dungeonName,bName,order,1,"TODO","TODO")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,2,"Boss Mechanics","Blood Craze is a physical DOT, applied on the tank, unavoidable. Agony is a high magic damage attack which briefly stuns the target and can be interrupted.")
EchoesOfLore:setupBaseBoss(dungeonName,bName,order,1,"Tank","Blood Craze is a physical DOT, the damage isn’t that high and it can’t be avoided. Agony is a high magic damage attack which briefly stuns the target and can be interrupted.")
  ---------
  bName = "Warchief Ozazai"
  order = order+1
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,1,"Overview","Will leap onto the main target to initiate the fight, focus the two Murkwater War Guards first.")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,2,"Boss Mechanics","Periodicaly he will target players with a red beam, a red indicator circle will appear beneath them. After a delay the explosion will go off, dealing high magic damage to all targets caught in its radius.\nIf you get the red beam on you, you should move away from the rest of the group to not blow them up.\nAt low Health he periodically casts a physical damage AOE shout called Staggering Roar that can be avoided by outranging it, or it will cause a lot of damage.")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,1,"Tank","Block Ozazai’s heavy attack called Haymaker, a very high physical damage attack with a knock down component")  
  ---------
  bName = "Bloodbirther"
  order = order+1
  --EchoesOfLore:setupBaseBoss(dungeonName,bName,order,1,"Overview","TODO")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,2,"Boss Mechanics","Periodically pulls a random targets at range towards it.")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,3,"Tank","After the adds are dealt with avoid the channeled frontal cone AOE ability called Shocking Rake. It deals periodic lightning damage to anyone caught in the area.")
  ---------
  bName = "Clatterclaw"
  order = order+1
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,1,"Overview","A large crab that summons a bunch of little crabs.")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,2,"Boss Mechanics","Periodically summons a large number of mudcrabs, burst them down quickly.")
  ---------
  bName = "Kra’gh the Dreugh King"
  order = order+1
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,1,"Overview","TODO")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,2,"Boss Mechanics","Summons a horde of mudcrabs which need to be bursted down with AOE.\nLightning Field can deals lightning damage, a red circle appears beneath him and it increases rapidly in size.\nPulls players to him, and the lightning field tends to happen right after a pull.")    
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,3,"Tank","Watch out for a cast called Lunging strike, which may knock the tank down, and a channeled lightning attack called Storm Flurry.")
  ---------
end

function EchoesOfLore:setupFungalGrotto2()
  local dungeonName = "Fungal Grotto 2"
  local description = "A dungeon. There are a lot of poisonous attacks and the bosses have a lot of AOE attacks."
  EchoesOfLore:setupBaseDungeon(dungeonName,description)
  local bName, order = nil, 0
  ---------
  bName = "Mephala's Fang"
  order = order+1
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,1,"Overview","Focus on the 2 ads, face the boss away from the group, and don't stand in the AOE circles.")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,2,"Boss Mechanics","There are two healer ads, a poisonous Spray AOE, and areas of poison that do not disappear.")
  ---------
  bName = "Gaymne Bandu"
  order = order+1
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,1,"Overview","TODO")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,2,"Boss Mechanics","If she connects two players, they must run away from each other or take high amounts of damage. If a player is held down by shadow tormentors, kill one to free them or they die.")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,3,"Veteran","TODO")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,5,"Unique Drop","Knife of Shadows")
  ---------
  bName = "Ciirenas the Shepherd"
  order = order+1
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,1,"Overview","Don't kill the spider adds, just pull them from her and kill the boss.")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,2,"Boss Mechanics","Each spider that dies gives the boss a damange reduction, so... foucs the boss. CC the spiderss or tank them away from the boss maybe?")
  ---------
  bName = "Spawn of Mephala"
  order = order+1
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,1,"Overview","TODO")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,2,"Boss Mechanics","If you are portaled to another room, kill the spiders inside to teleport back (may teleport person closest to opening). Get out of the expanding circle from boss. Run from the laser beam.")
  ---------
  bName = "Reggr Dark-Dawn"
  order = order+1
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,1,"Overview","TODO")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,2,"Boss Mechanics","Does a whirling attack in a small circle, magicka Drain, and a heavy attack.")
  ---------
  bName = "Vila Theran"
  order = order+1
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,1,"Overview","TODO")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,2,"Boss Mechanics","Stay grouped to minimize Black Hole AOEs created. To avoid a large DOT go into the shielded shrine, you can then exit to fight.")
  ---------
  --setupFungalGrotto2
end


function EchoesOfLore:setupSpindleclutch1()   
  local dungeonName = "Spindleclutch 1"
  local description = "A spider themed dungeon."
  EchoesOfLore:setupBaseDungeon(dungeonName,description)
  local bName, order = nil, 0
  ---------  
  bName = "Spindlekin"
  order = order+1
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,1,"Overview","Stack up around the boss to maximize area healing & damage output when dealing with adds.")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,2,"Boss Mechanics","Summons spider minions throughout the fight. Will devour dead spider minions to regain health.") 
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,3,"Tank","Focus on boss. Only tank adds when healer is in danger.\nBash the boss to interrupt the self-heal from devouring minion corpses.")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,4,"DPS","Stack and Burn down the boss.")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,5,"Heals","Heal. Run to the tank if adds are becoming a problem for you")
  ---------
  bName = "The Swarm Mother"
  order = order+1
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,1,"Overview","Stack around the boss to maximize area healing & damage output.\nThis also minimizes time lost when the boss leaps to a random target.")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,2,"Boss Mechanics","Spawns adds throughout the fight, Powerful melee heavy attack, Leaps at a random member of the group.") 
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,3,"Tank","Focus on keeping the boss occupied. Only tank adds if healer is in danger or you have extra resources.\nBoss will randomly charge group members, regardless of an active taunt.\nBlock boss's heavy attack. (high damage and a knock-back)")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,4,"DPS","Focus on the adds whenever they are spawned to reduce stress on the healer.")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,5,"Healer","Tank's health can spike if a heavy attack is not blocked\nRandom members of group will be charged for heavy physical damage")
  ---------
  bName = "Cerise the Widow-Maker"
  order = order+1
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,1,"Overview","TODO")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,2,"Boss Mechanics","Pulls with a group of Fight's Guild trash mobs\nSelf buffs to increase damage output, Can immobilize players, Heavy attack")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,3,"Tank","Focus attention on the boss and follow the same strategy as the trash mob pulls.")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,4,"DPS","Focus on the trash mobs using the same burn order that you have been using through previous trash mob pulls (either Healer -> Caster DPS -> Melee or Caster DPS -> Healer -> Melee). Finish with Cerise herself.")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,5,"Healer","Expect heavy damage on the tank due to Cerise's powerful attacks and other mobs.")
  --------
  bName = "Big Rabbu"
  order = order+1
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,1,"Overview","TODO")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,2,"Boss Mechanics","Pulls with a group of Fight's Guild trash mobsCan pull players to him (instant)Directional charge (his path will be shown in red)") 
    EchoesOfLore:setupBaseBoss(dungeonName,bName,order,3,"Tank","Tank Rabbu and any other mobs according to the strategy you used for Cerise and other trash mob pulls.Block Rabbu's charge attack if possible, which will stop it from hitting anyone else.") 
    EchoesOfLore:setupBaseBoss(dungeonName,bName,order,4,"DPS","Focus on the mobs using the same strategy as Cerise and other trash mob pulls. (Either Healer -> Caster DPS -> Melee or Caster DPS -> Healer -> Melee)") 
    EchoesOfLore:setupBaseBoss(dungeonName,bName,order,5,"Healer","Similar to Cerise, expect the tank to take heavy damage. Anyone who gets in the way of Rabbu's charge will need significant healing.") 
  ---------
  bName = "The Whisperer"
  order = order+1
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,1,"Overview","Fires a dodgable madness spell(kills on veteran).\nKnocks back melee.\nUses a maneuver to pull everyone to boss then starts casting a high dps spell that must be walked out of.")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,2,"Boss Mechanics","Avoid the AoE attack after she pulls everyone in.\nIf the boss suddenly turns to face you, dodge roll.")
  --EchoesOfLore:setupBaseBoss(dungeonName,bName,order,3,"Tank","Tank boss.")
  --EchoesOfLore:setupBaseBoss(dungeonName,bName,order,4,"DPS","TODO")
  --EchoesOfLore:setupBaseBoss(dungeonName,bName,order,5,"Healer","TODO")
  ---------  
  --Spindleclutch 1
end

function EchoesOfLore:setupSpindleclutch2()   
  local dungeonName = "Spindleclutch 2"
  local description = "A spider themed dungeon."
  EchoesOfLore:setupBaseDungeon(dungeonName,description)
  local bName, order = nil, 0
  --------- 
  bName = "Mad Mortine"
  order = order+1
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,1,"Overview","TODO")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,2,"Boss Mechanics","TODO") 
  ---------  
  bName = "Blood Spawn"
  order = order+1
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,1,"Overview","TODO")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,2,"Boss Mechanics","TODO")
  ---------
  bName = "Praxin Douare"
  order = order+1
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,1,"Overview","TODO")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,2,"Boss Mechanics","TODO") 
  ---------
  bName = "Flesh Atronach"
  order = order+1
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,1,"Overview","TODO")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,2,"Boss Mechanics","TODO") 
  ---------
  bName = "Urvan Veleth"
  order = order+1
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,1,"Overview","TODO")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,2,"Boss Mechanics","TODO") 
  ---------
  bName = "Vorenor Winterbourne"
  order = order+1
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,1,"Overview","TODO")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,2,"Boss Mechanics","TODO") 
  ---------
  
  --Spindleclutch 2
end

function EchoesOfLore:setupTheBanishedCells1()   
  local dungeonName = "The Banished Cells 1"
  local description = "A dungeon."
  EchoesOfLore:setupBaseDungeon(dungeonName,description)
  local bName, order = nil, 0
  ---------
  bName = "Cell Haunter Strategy"
  order = order+1
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,1,"Overview","TODO")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,2,"Boss Mechanics","TODO")     
  ---------
  bName = "Shadowrend"
  order = order+1
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,1,"Overview","TODO")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,2,"Boss Mechanics","TODO")   
  ---------
  bName = "Angata the Clannfear Handler"
  order = order+1
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,1,"Overview","TODO")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,2,"Boss Mechanics","TODO")   
  ---------
  bName = "Skeletal Destroyer"
  order = order+1
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,1,"Overview","TODO")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,2,"Boss Mechanics","TODO")   
  ---------
  bName = "High Kinlord Rilis"
  order = order+1
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,1,"Overview","TODO")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,2,"Boss Mechanics","TODO")   
  --------- 
  --The Banished Cells 1
end
function EchoesOfLore:setupTheBanishedCells2()   
  local dungeonName = "The Banished Cells 2"
  local description = "A dungeon."
  EchoesOfLore:setupBaseDungeon(dungeonName,description)
  local bName, order = nil, 0
  ---------
  bName = "Maw of the Infernal"
  order = order+1
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,1,"Overview","TODO")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,2,"Boss Mechanics","TODO")   
  ---------
  bName = "Keeper Imiril"
  order = order+1
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,1,"Overview","TODO")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,2,"Boss Mechanics","TODO")   
  ---------
  bName = "Sister Vera and Sister Sihna"
  order = order+1
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,1,"Overview","TODO")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,2,"Boss Mechanics","TODO")   
  ---------
  bName = "High Kinlord Rilis"
  order = order+1
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,1,"Overview","TODO")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,2,"Boss Mechanics","TODO")   
  --------- 
  --The Banished Cells 2
end

function EchoesOfLore:setupDarkshadeCaverns1()   
  local dungeonName = "Darkshade Caverns 1"
  local description = "A dungeon."
  EchoesOfLore:setupBaseDungeon(dungeonName,description)
  local bName, order = nil, 0
  ---------
  bName = "Head Shepherd Neloren"
  order = order+1
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,1,"Overview","TODO")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,2,"Boss Mechanics","TODO")   
  ---------
  bName = "Foreman Llothan"
  order = order+1
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,1,"Overview","TODO")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,2,"Boss Mechanics","TODO")   
  ---------
  bName = "The Hive Lord"
  order = order+1
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,1,"Overview","TODO")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,2,"Boss Mechanics","TODO")   
  ---------
  bName = "Cavern Patriarch"
  order = order+1
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,1,"Overview","TODO")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,2,"Boss Mechanics","TODO")   
  ---------
  bName = "Cutting Sphere"
  order = order+1
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,1,"Overview","TODO")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,2,"Boss Mechanics","TODO")   
  --------- 
  --Darkshade Caverns 1
end
function EchoesOfLore:setupDarkshadeCaverns2()   
  local dungeonName = "Darkshade Caverns 2"
  local description = "A dungeon."
  EchoesOfLore:setupBaseDungeon(dungeonName,description)
  local bName, order = nil, 0
  ---------
  bName = "The Fallen Foreman"
  order = order+1
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,1,"Overview","TODO")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,2,"Boss Mechanics","Fire caster boss. Uses ranged magic attacks and AOE. Kill the bunch of Adds.")   
  ---------
  bName = "Transmuted Hive Lord"
  order = order+1
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,1,"Overview","TODO")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,2,"Boss Mechanics","Kill the two adds. All three do knockdowns on the tank. Occassionally the adds burrow, and the Hive Lord does a big AOE. DPS his health shield to stop the effect.  Healing will be heavy during this phase.")   
  ---------
  bName = "Transmuted Alit "
  order = order+1
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,1,"Overview","These are 3 allits are standard allit mechanics, but if they are not all dead within a certain time they rez each other to about 1/8th health.  Get them all very low, and finish them off.")
  ---------
  bName = "Grubull the Transmuted"
  order = order+1
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,1,"Overview","TODO")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,2,"Boss Mechanics","Warps around, summons adds, and places large self centered red circles which are lightning attacks.  Due to this, no tank is really needed, tank may dps. Kill adds, ignore boss, until the boss is knocked to the ground.  Then dps the boss, as it is only vulnerable at this time.  Repeat. ")   
  ---------
  bName = "Waves of Mech Mobs"
  order = order+1
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,1,"Overview","TODO")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,2,"Boss Mechanics","A boss event without a main named boss, with waves of spiders, spheres, and centurions.  The tank should make sure to pick up the centurions, and try to get what else they may.  AOE is your friend here.")   
  ---------
  bName = "The Engine Guardian "
  order = order+1
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,1,"Overview","Generally the group should stack.  Kill adds as a priority.  Then DPS the boss.  DoT effects are very valuable for against the boss, as it constantly moves around the room, and much of the time the group will be either killing adds or avoiding the boss's energy mechanics.  With patience, you will win.")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,2,"Boss Mechanics","Waves of Adds of 3 spheres.  Kill them fast so you can dps the boss.  They use a ground line AOE as most spheres do, and a self centered one.  Avoid both AOEs. This boss has multiple energy phases.  Due to the danger for melee, ranged dps is recommended.  No tank is really needed. Red/Fire phase he throws fire, Yellow/Lightning he shocks those that are close")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,3,"Fire Phase","The boss spins, whirling fire around itself, as well as throwing ranged fire-bombs.")
   EchoesOfLore:setupBaseBoss(dungeonName,bName,order,3,"Lightning Phase","The boss shocks anyone too close, don't get shocked!")
   EchoesOfLore:setupBaseBoss(dungeonName,bName,order,3,"Poison Phase","The boss floods the room with poison, it must be healed through.  Alternatively, you may pull levers in the center of the room to clear the poison.")
   
 --------- 
  --Darkshade Caverns 2
end

function EchoesOfLore:setupEldenHollow1()   
  local dungeonName = "Elden Hollow 1"
  local description = "A dungeon."
  EchoesOfLore:setupBaseDungeon(dungeonName,description)
  local bName, order = nil, 0
  ---------
  bName = "kash gra-Mal"
  order = order+1
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,1,"Overview","TODO")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,2,"Boss Mechanics","TODO")   
  ---------
  bName = "Chokethorn"
  order = order+1
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,1,"Overview","TODO")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,2,"Boss Mechanics","TODO")   
  --------- 
  bName = "Nenesh gro-Mal"
  order = order+1
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,1,"Overview","TODO")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,2,"Boss Mechanics","TODO")   
  --------- 
  bName = "Leafseether"
  order = order+1
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,1,"Overview","TODO")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,2,"Boss Mechanics","TODO")   
  --------- 
  bName = "Canonreeve Oraneth"
  order = order+1
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,1,"Overview","TODO")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,2,"Boss Mechanics","TODO")   
  --------- 
  --Elden Hollow 1
end
function EchoesOfLore:setupEldenHollow2()   
  local dungeonName = "Elden Hollow 2"
  local description = "A dungeon."
  EchoesOfLore:setupBaseDungeon(dungeonName,description)
  local bName, order = nil, 0
  ---------
  bName = "Dubroze the Infestor"
  order = order+1
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,1,"Overview","TODO")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,2,"Boss Mechanics","TODO")      
  ---------
  bName = "Dark Root"
  order = order+1
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,1,"Overview","TODO")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,2,"Boss Mechanics","TODO")   
  ---------
  bName = "Azura the Frightener"
  order = order+1
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,1,"Overview","TODO")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,2,"Boss Mechanics","TODO")   
  ---------
  bName = "Murklight"
  order = order+1
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,1,"Overview","TODO")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,2,"Boss Mechanics","TODO")
  ---------
  bName = "The Shadow Guard"
  order = order+1
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,1,"Overview","TODO")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,2,"Boss Mechanics","TODO")   
  ---------
  bName = "Bogdan the Nightflame"
  order = order+1
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,1,"Overview","TODO")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,2,"Boss Mechanics","TODO")   
  --------- 
  --Elden Hollow 2
end

function EchoesOfLore:setupWayrestSewers1()   
  local dungeonName = "Wayrest Sewers 1"
  local description = "A sewer themed dungeon."
  EchoesOfLore:setupBaseDungeon(dungeonName,description)
  local bName, order = nil, 0
  ---------  
  bName = "Slimecraw"
  order = order+1
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,1,"Overview","Slimecraw has a frontal cone tailswipe. It deals high physical damage and does a pretty big knockback.")
  ---------  
  bName = "Investigator Garron"
  order = order+1
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,1,"Overview","The boss will teleport around the room, avoid the green orb chasing a player, careful not to drag it into the group. Kill the ranged adds. He also has a ranged knockback.")
    EchoesOfLore:setupBaseBoss(dungeonName,bName,order,1,"Boss Mechanics","Keep track of the boss as he teleports around the room.\nThe person that the green orb follows should run from it, careful to keep it away from other people.\nThe Boss periodically summons two Restless Soul ghosts on the opposite sides of the room, they have ranged attacks and should be taken down quickly.")
  ---------  
  bName = "Uulgarg the Hungry"
  order = order+1
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,1,"Overview","Uulgarg has a AOE fear ability.\n\nUulgarg has a nasty heavy melee attack, which deals a lot of damage unless blocked.\n\nHe likes to do it right after he has feared everyone. This could potentially kill the tank unless he has enough Stamina to break out of the fear and block the attack.\n\nHe sometimes stops and does a whirlwind attack around him, dealing physical damage.")
  ---------  
  bName = "The Rat Whisperer"
  order = order+1
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,1,"Overview","He periodically casts a magic AOE damage spell at the tank, indicated with a red circle.\n\nThe boss shouts “Come to me my minions” as he summons a bunch of low Health skeevers to aid him.\n\nThe Rat Whisperer sometimes casts a cold damage root spell on the tank.")
  ---------  
  bName = "Varaine Pellingare"
  order = order+1
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,1,"Overview","The Boss periodically casts a quickly expanding AOE spell around him that deals a lot of damage and briefly stuns anyone caught in it.\n\nHe has a frontal cone attack, seemingly to a random direction with a jump animation associated with the ability thatis tricky to avoid. Getting hit by the frontal cone attack will knock you down and deal medium physical damage.")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,1,"Tank","The tank needs to look out for Varaine’s heavy melee attack, and block it.")
  ---------  
  bName = "Allene Pellingare"
  order = order+1
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,1,"Overview","Boss uses a Teleport Strike to random targets, to damange and snare the target.\n\nEvery 25% of her Health the boss will summon Fiendish Hallucinations. They are large bats with 562 Health. Boss will deal a bit more damage in the last 25% phase.")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,1,"Tank","The tank needs to block Allene’s heavy melee attack.")
  
  --Wayrest Sewers 1
end

function EchoesOfLore:setupWayrestSewers2()  
  local dungeonName = "Wayrest Sewers 2"
  local description = "A sewer themed dungeon."
  EchoesOfLore:setupBaseDungeon(dungeonName,description)
  local bName, order = nil, 0
  ---------
  bName = "Malubeth the Scourger"
  order = order+1
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,1,"Overview","TODO")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,2,"Boss Mechanics","TODO")  
  ---------
  bName = "Uulgarg the Risen"
  order = order+1
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,1,"Overview","TODO")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,2,"Boss Mechanics","TODO")  
  ---------
  bName = "Skull Reaper"
  order = order+1
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,1,"Overview","TODO")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,2,"Boss Mechanics","TODO")  
  ---------
  bName = "Garron the Returned"
  order = order+1
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,1,"Overview","TODO")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,2,"Boss Mechanics","TODO")  
  ---------
  bName = "The Lost One"
  order = order+1
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,1,"Overview","TODO")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,2,"Boss Mechanics","TODO")  
  ---------
  bName = "Varaine and Allene Pellingare"
  order = order+1
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,1,"Overview","TODO")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,2,"Boss Mechanics","TODO")   
  --------- 
  --Wayrest Sewers 2
end


--
function EchoesOfLore:setupArxCorinium()   
  local dungeonName = "Arx Corinium"
  local description = "A dungeon."
  EchoesOfLore:setupBaseDungeon(dungeonName,description)
  local bName, order = nil, 0
  ---------
  bName = "Fanged Menace"
  order = order+1
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,1,"Overview","The first boss in Arx Corinium. He’s a snake miniboss, and isn’t very difficult as long as you stay away from his health leech ability.\nFanged Menace is surrounded by some adds which you should take care of before focusing on him.")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,2,"Boss Mechanics","Frontal cone attack that causes knockback and damages severely any player caught in it.\nAOE Poison attack that absorbs health from those hit by it to the Boss. The red circle made underneath him while he curls up can damage heavily and also heal the boss.\n*Other ads surrounding the boss\n*Heavy melee attacks.")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,3,"Strategy","Deal with the ads first.\nThe tank should block the heavy Melee attack and keep the boss focused away from the group.\nAvoid the large AOE red circle as it can instantly wipeout any player within its reach.\n");
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,4,"Tank","The tank needs to look out for the heavy melee attack – block it.\n");
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,5,"DPS","Stay out of the AOE poison damage ability\n");
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,6,"Healer","Stay out of the AOE poison damage ability\n");
  ---------
  bName = "Ganakton the Tempest"
  order = order+1
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,1,"Overview","The second boss in Arx Corinium. He can be quite lethal. Spreading apart is beneficial. Do not stack.")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,2,"Boss Mechanics","The Boss has is a frontal cone lightning breath which should be easy to avoid.\nPeriodically electrifies himself and deals a moderate amount of damage to everyone in a few shock pulses, unavoidable\nHas a lightning wave attack that will target a random player and send a wave of lightning towards them. The wave will deal a high amount of Shock damage and stun anyone caught in it. You can get out of the stun with your interrupt / break free ability.\nFollowing the Lightning wave, he electrifies his tail and sends a bolt of lightning at the same player, dealing a lot of Shock damage and again stunning them on the ground.")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,3,"Tank","Tank\n")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,4,"DPS","Avoid frontal cone, do not stack, avoid the lightning wave and stun, as he follows up with more damage.\n")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,5,"Healer","Periodically electrifies himself and deals a moderate amount of unavoidable damage to everyone\n")
  ---------
  bName = "Sliklenia the Songstress"
  order = order+1
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,1,"Overview","The third boss in Arx Corinium. Do not kill the add, pet as it has an essential role in this fight, and you should NOT kill it.")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,2,"Boss Mechanics","Sliklenia has a heavy melee attack which the tank should block.\nWhen she becomes stationary and starts singing, she'll start dealing tons of damage in pulses around the room. The Songstress’ Pet creates a sonic shield at a random location in the room. The pet will retreat to the shield – you should follow.")
  ---------
  bName = "Matron Ixniaa"
  order = order+1
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,1,"Overview","The fourth boss in Arx Corinium. She’s a miniboss and doesn’t have much health. She only has one ability to look out for, which can be lethal.\nIxniaa is surrounded by a bunch of adds, you should take them down first.\n")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,2,"Boss Mechanics","She periodically targets a random player, places a red circle beneath the player, and follows up with another circle, which will cover an even bigger area. The inner circle is the one you must avoid – it deals tons of damage and can be lethal if you’re not topped up. The outer circle also deals damage, but is much more manageable.")
  ---------
  bName = "Ancient Lurcher"
  order = order+1
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,1,"Overview","The fifth boss in Arx Corinium. Just like the previous miniboss, Ancient Lurcher also has a bunch of adds around him. Kill them before you focus on him.")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,2,"Boss Mechanics","Ancient Lurcher casts a red circle beneath him, dealing damage to anyone caught in it. It should be easy to avoid.\nAncient Lurcher sometimes targets a random player with a green beam, which deals heavy poison damage.\nOnce Ancient Lurcher drops below 50% Health or so, he enrages and charges himself with Lightning, empowering his AOE ability.")
  ---------
  bName = "Sellistrix the Lamia Queen"
  order = order+1
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,1,"Overview","The sixth and final boss in Arx Corinium.\nThe room is filled with water, but there are a couple of small islands which are safe to stand on. Staying in the water is bad.")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,2,"Boss Mechanics","Sellistrix has a frontal cone scream which deals a lot of damage.\nThe tank should face Sellistrix away from the rest of the group.\nSellistrix periodically charges at random players, dealing a low amount of damage in the process.\nShe will start channeling lightning and target the small islands in the room, marked with red circles. Sometimes you have a safe island to go to, sometimes not.\nIt’s very important that Sellistrix isn’t standing in water when this ability goes off, or the water will become electrified and hurt everyone in it.\nThe lightning attack on the islands does deal a bit of damage, but less than in the water.\n")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,3,"Tank","Face away from players as usual, she charges players randomly, electricity is worse in water, if she's in it then everyone else should not be!\ n")
  ---------
  --Arx Corinium
end

function EchoesOfLore:setupCityOfAsh1()   
  local dungeonName = "City of Ash 1"
  local description = "A  dungeon."  
  EchoesOfLore:setupBaseDungeon(dungeonName,description)
  local bName, order = nil, 0
  ---------
  bName = "Infernal Guardian"
  order = order+1
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,1,"Overview","TODO")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,2,"Boss Mechanics","TODO")  
  ---------
  bName = "Warden of the Shrine"
  order = order+1
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,1,"Overview","TODO")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,2,"Boss Mechanics","TODO")  
  ---------
  bName = "Razor Master Erthas"
  order = order+1
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,1,"Overview","TODO")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,2,"Boss Mechanics","TODO")   
  --------- 
  --setupCityOfAsh1
end

function EchoesOfLore:setupCityOfAsh2()  
  local dungeonName = "City of Ash 2"
  local description = "A dungeon."
  EchoesOfLore:setupBaseDungeon(dungeonName,description)
  local bName, order = nil, 0
  ---------
  bName = "Xivilai Rukhan"
  order = order+1
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,1,"Overview","TODO")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,2,"Boss Mechanics","TODO")  
  ---------
  bName = "Urata the Legion"
  order = order+1
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,1,"Overview","TODO")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,2,"Boss Mechanics","TODO")  
  ---------
  bName = "Xivilai Boltaic & Xivilai Fulminator"
  order = order+1
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,1,"Overview","TODO")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,2,"Boss Mechanics","TODO")  
  ---------
  bName = "Horvantud the Fire Maw"
  order = order+1
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,1,"Overview","TODO")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,2,"Boss Mechanics","TODO")    
  ---------
  bName = "Ash Titan"
  order = order+1
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,1,"Overview","TODO")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,2,"Boss Mechanics","TODO")    
  ---------
  bName = "Valkyn Skoria"
  order = order+1
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,1,"Overview","TODO")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,2,"Boss Mechanics","TODO")   
  --------- 
  --setupCityOfAsh2
end

function EchoesOfLore:setupCryptOfHearts1()
  local dungeonName = "Crypt Of Hearts 1"
  local description = "A dungeon."
  EchoesOfLore:setupBaseDungeon(dungeonName,description)
  local bName, order = nil, 0
  ---------
  bName = "The Mage Master"
  order = order+1
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,1,"Overview","TODO")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,2,"Boss Mechanics","TODO") 
  ---------
  bName = "Archmaster Siniel"
  order = order+1
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,1,"Overview","TODO")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,2,"Boss Mechanics","TODO") 
  ---------
  bName = "Death’s Leviathan"
  order = order+1
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,1,"Overview","TODO")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,2,"Boss Mechanics","TODO") 
  ---------
  bName = "Uulkar Bonehand"
  order = order+1
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,1,"Overview","TODO")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,2,"Boss Mechanics","TODO") 
  ---------
  bName = "Dogas the Berserker"
  order = order+1
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,1,"Overview","TODO")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,2,"Boss Mechanics","TODO") 
  ---------
  bName = "Ilambris-Zaven & Ilambris-Athor"
  order = order+1
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,1,"Overview","TODO")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,2,"Boss Mechanics","TODO")   
  --------- 
  --setupCryptOfHearts1
end

function EchoesOfLore:setupCryptOfHearts2()
  local dungeonName = "Crypt Of Hearts 2"
  local description = "A dungeon."
  EchoesOfLore:setupBaseDungeon(dungeonName,description)
  local bName, order = nil, 0
  ---------
  bName = "Ibelgast"
  order = order+1
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,1,"Overview","TODO")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,2,"Boss Mechanics","TODO") 
  ---------
  bName = "Ruzozuzalpamaz"
  order = order+1
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,1,"Overview","TODO")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,2,"Boss Mechanics","TODO") 
  ---------
  bName = "Chamber Guardian"
  order = order+1
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,1,"Overview","TODO")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,2,"Boss Mechanics","TODO") 
  ---------
  bName = "Illambris Amalgam"
  order = order+1
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,1,"Overview","TODO")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,2,"Boss Mechanics","TODO") 
  ---------
  bName = "Mezeluth"
  order = order+1
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,1,"Overview","TODO")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,2,"Boss Mechanics","TODO") 
  ---------
  bName = "Nerien'eth"
  order = order+1
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,1,"Overview","TODO")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,2,"Boss Mechanics","TODO")   
  --------- 
  --setupCryptOfHearts2
end

function EchoesOfLore:setupDirefrostKeep()
  local dungeonName = "Direfrost Keep"
  local description = "A dungeon."
  EchoesOfLore:setupBaseDungeon(dungeonName,description)
  local bName, order = nil, 0
  ---------
  bName = "Teethnasher the Frostbound"
  order = order+1
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,1,"Overview","TODO")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,2,"Boss Mechanics","TODO")   
  ---------
  bName = "Guardian of the Flame"
  order = order+1
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,1,"Overview","TODO")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,2,"Boss Mechanics","TODO")   
  ---------
  bName = "Drodda's Apprentice"
  order = order+1
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,1,"Overview","TODO")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,2,"Boss Mechanics","TODO")   
  ---------
  bName = "Drodda's Dreadlord"
  order = order+1
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,1,"Overview","TODO")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,2,"Boss Mechanics","TODO")   
  ---------
  bName = "Iceheart"
  order = order+1
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,1,"Overview","TODO")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,2,"Boss Mechanics","TODO")   
  ---------
  bName = "Ancient Lurcher"
  order = order+1
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,1,"Overview","TODO")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,2,"Boss Mechanics","TODO")   
  ---------
  bName = "Drodda of Icereach"
  order = order+1
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,1,"Overview","TODO")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,2,"Boss Mechanics","TODO")     
  --------- 
  --DirefrostKeep
end

function EchoesOfLore:setupTempestIsland()
  local dungeonName = "Tempest Island"
  local description = "A dungeon."
  EchoesOfLore:setupBaseDungeon(dungeonName,description)
  local bName, order = nil, 0
  ---------
  bName = "Sonolia the Matriarch"
  order = order+1
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,1,"Overview","TODO")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,2,"Boss Mechanics","TODO")  
  ---------
  bName = "Valaran Stormcaller"
  order = order+1
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,1,"Overview","TODO")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,2,"Boss Mechanics","TODO")  
  ---------
  bName = "Yalorasse the Speaker "
  order = order+1
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,1,"Overview","TODO")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,2,"Boss Mechanics","TODO")  
  ---------
  bName = "Stormfist"
  order = order+1
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,1,"Overview","TODO")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,2,"Boss Mechanics","TODO")  
  ---------
  bName = "Commodore Ohmanil"
  order = order+1
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,1,"Overview","TODO")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,2,"Boss Mechanics","TODO")  
  ---------
  bName = "Stormreeve Neidir"
  order = order+1
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,1,"Overview","TODO")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,2,"Boss Mechanics","TODO")   
  --------- 
  --setupTempestIsland
end

function EchoesOfLore:setupVolenfell()
  local dungeonName = "Volenfell"
  local description = "A dungeon."
  EchoesOfLore:setupBaseDungeon(dungeonName,description)
  local bName, order = nil, 0
  ---------
  bName = "Desert Lion"
  order = order+1
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,1,"Overview","TODO")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,2,"Boss Mechanics","TODO")   
  ---------
  bName = "Quintus Verres"
  order = order+1
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,1,"Overview","TODO")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,2,"Boss Mechanics","TODO")   
  ---------
  bName = "Monstrous Gargoyle"
  order = order+1
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,1,"Overview","TODO")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,2,"Boss Mechanics","TODO")   
  ---------
  bName = "Boilbite"
  order = order+1
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,1,"Overview","TODO")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,2,"Boss Mechanics","TODO")   
  ---------
  bName = "Tremorscale"
  order = order+1
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,1,"Overview","TODO")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,2,"Boss Mechanics","TODO")   
  ---------
  bName = "Unstable Construct"
  order = order+1
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,1,"Overview","TODO")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,2,"Boss Mechanics","TODO")   
  ---------
  bName = "Guardian Constructs"
  order = order+1
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,1,"Overview","TODO")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,2,"Boss Mechanics","TODO")     
  --------- 
  --Volenfell
end

function EchoesOfLore:setupBlackheartHaven()  
  local dungeonName = "Blackheart Haven"
  local description = "A pirate themed dungeon."
  EchoesOfLore:setupBaseDungeon(dungeonName,description)
  local bName, order = nil, 0
  ---------
  bName = "Iron-Heel"
  order = order+1
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,1,"Overview","TODO")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,2,"Boss Mechanics","TODO")   
  ---------
  bName = "Atarus"
  order = order+1
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,1,"Overview","TODO")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,2,"Boss Mechanics","TODO")   
  ---------
  bName = "First Mate Wavecutter"
  order = order+1
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,1,"Overview","TODO")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,2,"Boss Mechanics","TODO")   
    ---------
  bName = "Roost Mother"
  order = order+1
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,1,"Overview","TODO")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,2,"Boss Mechanics","TODO")   
  ---------
  bName = "Hollow Heart"
  order = order+1
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,1,"Overview","TODO")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,2,"Boss Mechanics","TODO")   
  ---------
  bName = "Captain Blackheart"
  order = order+1
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,1,"Overview","TODO")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,2,"Boss Mechanics","TODO")     
  --------- 
  --Blackheart Haven
end

function EchoesOfLore:setupBlessedCrucible()
  local dungeonName = "Blessed Crucible"
  local description = "A dungeon."
  EchoesOfLore:setupBaseDungeon(dungeonName,description)
  local bName, order = nil, 0
  ---------
  bName = "Grunt the Clever"
  order = order+1
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,1,"Overview","TODO")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,2,"Boss Mechanics","TODO")   
  ---------
  bName = "The Pack"
  order = order+1
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,1,"Overview","TODO")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,2,"Boss Mechanics","TODO")   
  ---------
  bName = "Teranya the Faceless"
  order = order+1
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,1,"Overview","TODO")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,2,"Boss Mechanics","TODO")     
  ---------
  bName = "The Stinger & The Troll King"
  order = order+1
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,1,"Overview","TODO")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,2,"Boss Mechanics","TODO")   
  ---------
  bName = "Captain Thoran"
  order = order+1
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,1,"Overview","TODO")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,2,"Boss Mechanics","TODO")     
  ---------
  bName = "Lava Queen"
  order = order+1
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,1,"Overview","TODO")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,2,"Boss Mechanics","TODO")   
  --------- 
  --setupBlessedCrucible
end

function EchoesOfLore:setupSelenesWeb()
  local dungeonName = "Selene's Web"
  local description = "A dungeon."
  EchoesOfLore:setupBaseDungeon(dungeonName,description)
  local bName, order = nil, 0
  ---------
  bName = "Treethane Keminn"
  order = order+1
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,1,"Overview","TODO")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,2,"Boss Mechanics","TODO")   
  ---------
  bName = "Longclaw"
  order = order+1
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,1,"Overview","TODO")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,2,"Boss Mechanics","TODO")   
  ---------
  bName = "Queen Aklayah"
  order = order+1
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,1,"Overview","TODO")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,2,"Boss Mechanics","TODO")   
  ---------
  bName = "Foulhide"
  order = order+1
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,1,"Overview","TODO")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,2,"Boss Mechanics","TODO")   
  ---------
  bName = "Mennir Many-Legs"
  order = order+1
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,1,"Overview","TODO")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,2,"Boss Mechanics","TODO")   
  ---------
  bName = "Selene"
  order = order+1
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,1,"Overview","TODO")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,2,"Boss Mechanics","TODO")   
  --------- 
  --setupSelenesWeb
end

function EchoesOfLore:setupVaultsOfMadness()
  local dungeonName = "Vaults Of Madness"
  local description = "A dungeon."
  EchoesOfLore:setupBaseDungeon(dungeonName,description)  
  local bName, order = nil, 0
  --------- 
  bName = "Cursed One"
  order = order+1
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,1,"Overview","TODO")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,2,"Boss Mechanics","TODO")   
  --------- 
  bName = "Ulguna Soul-Reaver"
  order = order+1
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,1,"Overview","TODO")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,2,"Boss Mechanics","TODO")   
  ---------
  bName = "Death's Head"
  order = order+1
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,1,"Overview","TODO")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,2,"Boss Mechanics","TODO")   
  ---------
  bName = "Grothdarr"
  order = order+1
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,1,"Overview","TODO")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,2,"Boss Mechanics","TODO")   
  --------- 
  bName = "Archaeraizur"
  order = order+1
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,1,"Overview","TODO")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,2,"Boss Mechanics","TODO")   
  --------- 
  bName = "Ancient One"
  order = order+1
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,1,"Overview","TODO")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,2,"Boss Mechanics","TODO")   
  --------- 
  bName = "Iskra the Omen"
  order = order+1
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,1,"Overview","TODO")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,2,"Boss Mechanics","TODO")   
   --------- 
  bName = "Mad Architect"
  order = order+1
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,1,"Overview","TODO")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,2,"Boss Mechanics","TODO")   
  --------- 
  --setupVaultsOfMadness
end

function EchoesOfLore:setupWhiteGoldTower()  
  local dungeonName = "White Gold Tower"
  local description = "A DLC dungeon."
  EchoesOfLore:setupBaseDungeon(dungeonName,description,false,true)  
  local bName, order = nil, 0
  ---------
  bName = "TODO"
  order = order+1
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,1,"Overview","TODO")
  EchoesOfLore:setupBaseBoss(dungeonName,bName,order,2,"Boss Mechanics","TODO")   
  --------- 
  --White-Gold Tower
end
