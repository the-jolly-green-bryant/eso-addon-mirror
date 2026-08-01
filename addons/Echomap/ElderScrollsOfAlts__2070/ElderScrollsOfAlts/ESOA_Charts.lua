--[[ ESOA UI Charts ]]-- 
 
----------------------------------------
-- ESOA GUI/UI Charts/Data Lookup Functions
----------------------------------------

-----------
-- VIEWS
ElderScrollsOfAlts.allowedViewEntries = {
  ["Note"] = 1, 
  ["Special"] = 1, 
  ["Alliance"] = 1, 
  ["Class"] = 1, 
  ["Level"] = 1, 
  ["Gender"] = 1, 
  ["Race"] = 1, 
  ["Alchemy"] = 1, 
  ["Smithing"] = 1, 
  ["Blacksmithing"] = 1, 
  ["Clothing"] = 1, 
  ["Enchanting"] = 1, 
  ["Jewelry"] = 1, 
  ["Provisioning"] = 1, 
  ["Woodworking"] = 1,    
  
  ["BagSpace"] = 1,
  ["BagSpaceFree"] = 1,
  ["BackpackUsed"] = 1,
  ["BackpackSize"] = 1,
  ["BackpackFree"] = 1,    
  ["Skillpoints"] = 1, 
  
  ["Head"] = 1, 
  ["Shoulders"] = 1, 
  ["Chest"] = 1, 
  ["Hands"] = 1, 
  ["Waist"] = 1, 
  ["Legs"] = 1, 
  ["Feet"] = 1, 
  ["Neck"] = 1, 
  ["Ring1"] = 1, 
  ["Ring2"] = 1, 
  ["M1"] = 1, 
  ["M2"] = 1, 
  ["Mp"] = 1, 
  ["O1"] = 1, 
  ["O2"] = 1, 
  ["Op"] = 1, 
  ["Heavy"] = 1, 
  ["Medium"] = 1, 
  ["Light"] = 1, 
  
  ["Clothier Research 1"] = 1, 
  ["Clothier Research 2"] = 1, 
  ["Clothier Research 3"] = 1, 
  ["Blacksmithing Research 1"] = 1, 
  ["Blacksmithing Research 2"] = 1, 
  ["Blacksmithing Research 3"] = 1, 
  ["Woodworking Research 1"] = 1, 
  ["Woodworking Research 2"] = 1, 
  ["Woodworking Research 3"] = 1, 
  ["Jewelcrafting Research 1"] = 1, 
  ["Jewelcrafting Research 2"] = 1, 
  ["Jewelcrafting Research 3"] = 1, 

  ["Assault"] = 1, 
  ["Support"] = 1, 
  ["Legerdemain"] = 1, 
  ["Soul Magic"] = 1, 
  ["Werewolf"] = 1, 
  ["Vampire"] = 1, 
  ["Fighters Guild"] = 1, 
  ["Mages Guild"] = 1, 
  ["Undaunted"] = 1, 
  ["Thieves Guild"] = 1, 
  ["Dark Brotherhood"] = 1, 
  ["Psijic Order"] = 1,
  ["Scrying"] = 1,
  ["Excavation"] = 1,
  
  ["Riding Speed"] = 1, 
  ["Riding Stamina"] = 1, 
  ["Riding Inventory"] = 1, 
  ["Riding Timer"] = 1, 
  
  ["SpecialBiteTimer"] = 1, 
  ["SecondsPlayed"] = 1, 
  ["TimePlayed"] = 1, 
  ["lastlogin"] = 1,
  ["lastlogindiff"] = 1,
  
  ["Alliance Name"] = 1,
  ["InCampaign"] = 1,
  ["GuestCampaignId"] = 1,
  ["CurrentCampaignId"] = 1,
  ["AssignedCampaignId"] = 1,
  ["AssignedCampaignEndsAt"] = 1,
  ["AssignedCampaignLastloaded"] = 1,
  
  ["CurrentCampaignName"] = 1,
  ["GuestCampaignName"] = 1,
  ["AssignedCampaignName"] = 1,
  
  ["IsInCampaign"] = 1,  
  ["UnitAlliance"] = 1,
  ["AllianceName"] = 1,
  ["UnitAvARank"] = 1,
  ["UnitAvARankPoints"] = 1,
  ["AvaSubRankStart"] = 1,
  ["AvaNextSubRank"] = 1,
  ["AvaRankStarts"] = 1,
  ["AvaNextRank"] = 1,
  
  ["SubRankStartsAt"] = 1,
  ["NextSubRankAt"] = 1,
  ["RankStartsAt"] = 1,
  ["NextRankAt"] = 1,
  ["AvaRankName"] = 1,
  ["AssignedCampaignRewardEarnedTier"] = 1,
  ["CurrentCampaignRewardEarnedTier"] = 1,
  ["GuestCampaignRewardEarnedTier"] = 1,
  
  ["assignedcampaignrewardprogress"] = 1,
  ["assignedcampaignrewardtotal"] = 1,
  
  ["Currency_Gold"] =1 ,
  ["Currency_Alliance point"] = 1,
  ["Currency_Tel Var Stone"] = 1,
  ["Currency_Writ Vouchers"] = 1,
  ["Currency_Transmute Crystals"] = 1,
  ["Currency_Crown Gems"] = 1,
  ["Currency_Crowns"] = 1,
  ["Currency_Outfit Change Tokens"] = 1,
  
  ["ReducedBounty"] = 1, 
  ["LaundersTotal"] = 1, 
  ["LaundersUsed"] = 1, 
  ["SellsTotal"] = 1, 
  ["SellsUsed"] = 1, 
  ["LaunderReset"] = 1, 
  
  ["zoneName"] = 1, 
  ["subzoneName"] = 1, 
  ["ZoneName"] = 1, 
  ["SubzoneName"] = 1, 
  
  ["achieveearned"] = 1, 
  ["playersorder"] = 1,  -- can be set by player
  ["playerscreenorder"] = 1, -- reset on load to load screen order
  
  ["unitxpmax"] = 1,
  ["unitxp"] = 1,
  ["champion"] = 1,
  
  ["Clothier Writ"] = 1,
  ["Blacksmith Writ"] = 1,
  ["Woodworker Writ"] = 1,
  ["Jewelry Crafting Writ"] = 1,
  ["Alchemist Writ"] = 1,
  ["Provisioner Writ"] = 1,
  ["Enchanter Writ"] = 1,
  
  ["Companion_1_name"] = 1,
  ["Companion_2_name"] = 1,
  ["Companion_3_name"] = 1,
  ["Companion_4_name"] = 1,
  ["Companion_5_name"] = 1,
  ["Companion_6_name"] = 1,
  ["Companion_7_name"] = 1,
  ["Companion_8_name"] = 1,
  ["Companion_9_name"] = 1,
  ["Companion_10_name"] = 1,
  ["Companion_11_name"] = 1,
  ["Companion_12_name"] = 1,
  ["Companion_1_level"] = 1,
  ["Companion_2_level"] = 1,
  ["Companion_3_level"] = 1,
  ["Companion_4_level"] = 1,
  ["Companion_5_level"] = 1,
  ["Companion_6_level"] = 1,
  ["Companion_7_level"] = 1,
  ["Companion_8_level"] = 1,
  ["Companion_9_level"] = 1,
  ["Companion_10_level"] = 1,
  ["Companion_11_level"] = 1,
  ["Companion_12_level"] = 1,
  ["Companion_1_rapport"] = 1,
  ["Companion_2_rapport"] = 1,
  ["Companion_3_rapport"] = 1,
  ["Companion_4_rapport"] = 1,
  ["Companion_5_rapport"] = 1,
  ["Companion_6_rapport"] = 1,
  ["Companion_7_rapport"] = 1,
  ["Companion_8_rapport"] = 1,
  ["Companion_9_rapport"] = 1,
  ["Companion_10_rapport"] = 1,
  ["Companion_11_rapport"] = 1,
  ["Companion_12_rapport"] = 1,
  
  ["stamina"] = 1,
  ["magicka"] = 1,
  ["health"] = 1,
  ["power"] = 1,
  
  ["skillline1"] = 1,
  ["skillline2"] = 1,
  ["skillline3"] = 1,
}

-----------
-- VIEWS
ElderScrollsOfAlts.view.guiTemplates = {  
  ["Home"] = {
    ["name"] = "Home",
    ["view"] = {
      [1] = "Note",
      [2] = "playersorder",
      [3] = "Special",
      [4] = "Alliance",
      [5] = "Class",
      [6] = "Level",
      [7] = "Gender",
      [8] = "Race",
      [9]  = "Alchemy",
      [10]  = "Blacksmithing",
      [11] = "Clothing",
      [12] = "Enchanting",
      [13] = "Jewelry",
      [14] = "Provisioning",
      [15] = "Woodworking",        
      [16] = "BagSpace",        
      [17] = "BagSpaceFree",        
      [18] = "Skillpoints",
      [19] = "Riding Timer",
      [20] = "Riding Speed",
      [21] = "Riding Stamina",
      [22] = "Riding Inventory",
      [23] = "lastlogindiff",
      [24] = "achieveearned",
      [25] = "ReducedBounty",
	  [26] = "skillline1",
	  [27] = "skillline2",
	  [28] = "skillline3"
    }
  },
  ["Pvp"] = {
    ["name"] = "Pvp",
    ["view"] = {
      [1] = "Note",
      [2] = "playersorder",
      [3] = "Special",
      [4] = "Alliance",
      [5] = "Class",
      [6] = "Level",
      [7] = "Gender",
      [8] = "Race",
      
      [9]  = "Assault",
      [10] = "Support",
      
      [11] = "AssignedCampaignName",
      [12] = "AssignedCampaignRewardEarnedTier",
      [13] = "AssignedCampaignEndsAt",
      
      [14] = "AvaRankName",
      [15] = "UnitAvARank",
    }
  },
  ["Research"] = {
    ["name"] = "Research",
    ["view"] = {
      [1] = "Level",
      [2] = "Note",
      [3] = "playersorder",
      [4] = "Clothing",
      [5] = "Clothier Research 1",
      [6] = "Clothier Research 2",
      [7] = "Clothier Research 3",
      [8] = "Blacksmithing",
      [9] = "Blacksmithing Research 1",
      [10] = "Blacksmithing Research 2",
      [11] = "Blacksmithing Research 3",
      [12] = "Woodworking",
      [13] = "Woodworking Research 1",
      [14] = "Woodworking Research 2",
      [15] = "Woodworking Research 3",
      [16] = "Jewelry",
      [17] = "Jewelcrafting Research 1",
      [18] = "Jewelcrafting Research 2",
      [19] = "Jewelcrafting Research 3",
      [20] = "Clothier Writ",
      [21] = "Blacksmith Writ",
      [22] = "Woodworker Writ",
      [23] = "Jewelry Crafting Writ",
      [24] = "Alchemist Writ",
      [25] = "Provisioner Writ",
      [26] = "Enchanter Writ",
    }
  },
  ["Skills"] = {
    ["name"] = "Skills",
    ["view"] = {
      [1] = "Level",
      [2] = "Note",
      [3] = "playersorder",
      [4] = "Alliance",
      [5] = "Assault",
      [6] = "Support",
      [7] = "Legerdemain",
      [8] = "Soul Magic",
      [9] = "Werewolf",
      [10] = "Vampire",
      
      [11] = "Fighters Guild",
      [12] = "Mages Guild",
      [13] = "Undaunted",
      [14] = "Thieves Guild",
      [15] = "Dark Brotherhood",
      [16] = "Psijic Order",
      [17] = "Scrying",
      [18] = "Excavation",
      
      [19] = "Riding Speed",
      [20] = "Riding Stamina",
      [21] = "Riding Inventory",
      [22] = "Riding Timer",
    }
  },
  ["Crafting"] = {
    ["name"] = "Craft",
    ["view"] = {
      [1] = "Level",
      [2] = "Note",
      [3] = "playersorder",
      [4] = "Alliance",
      [5] = "Clothier Writ",
      [6] = "Blacksmith Writ",
      [7] = "Woodworker Writ",
      [8] = "Jewelry Crafting Writ",
      [9] = "Alchemist Writ",
      [10] = "Provisioner Writ",
      [11] = "Enchanter Writ",
      
      [12] = "Clothing",
      [13] = "Blacksmithing",
      [14] = "Woodworking",     
      [15] = "Jewelry",
      [16] = "Alchemy",
      [17] = "Provisioning",
      [18] = "Enchanting",
    },
  },
  ["Companions"] = {
    ["name"] = "Companions",
    ["view"] = {
      [1] = "Level",
      [2] = "Note",
      [3] = "playersorder",
      [4] = "Alliance",
      
      [5] = "Companion_1_name",
      [6] = "Companion_1_level",
      [7] = "Companion_1_rapport",
      [8] = "Companion_2_name",
      [9] = "Companion_2_level",
      [10] = "Companion_2_rapport",
      [11] = "Companion_3_name",
      [12] = "Companion_3_level",
      [13] = "Companion_3_rapport",
      [14] = "Companion_4_name",
      [15] = "Companion_4_level",
      [16] = "Companion_4_rapport",
      [17] = "Companion_5_name",
      [18] = "Companion_5_level",
      [19] = "Companion_5_rapport",
      [17] = "Companion_6_name",
      [18] = "Companion_6_level",
      [19] = "Companion_6_rapport",
    }
  },
  ["Writs"] = {
    ["name"] = "Writs",
    ["view"] = {
      [1] = "Level",
      [2] = "Note",
      [3] = "playersorder",
      [4] = "Alliance",
      
      [5] = "Clothier Writ",
      [6] = "Blacksmith Writ",
      [7] = "Woodworker Writ",
      [8] = "Jewelry Crafting Writ",
      [9] = "Alchemist Writ",
      [10] = "Provisioner Writ",
      [11] = "Enchanter Writ",
    }
  },
  ["Equip"] = {
    ["name"] = "Equip",
    ["view"] = {
      [1] = "playersorder",
      [2] = "Head",
      [3] = "Shoulders",
      [4] = "Chest",
      [5] = "Hands",
      [6] = "Waist",
      [7] = "Legs",
      [8] = "Feet",
      [9] = "Neck",
      [10] = "Ring1",
      [11] = "Ring2",
      [12] = "M1",
      [13] = "M2",
      [14] = "Mp",
      [15] = "O1",
      [16] = "O2",
      [17] = "Op",
      [18] = "Heavy",
      [19] = "Medium",
      [20] = "Light",
    }
  },
}

-- VIEWS
ElderScrollsOfAlts.SkillsLevelNearMaximum = {
  ["Level"] = 48,
  ["Riding Speed"]     = 55,
  ["Riding Stamina"]   = 55,
  ["Riding Inventory"] = 55,
  ["Dark Brotherhood"] = 10,
  ["Thieves Guild"]    = 10,
  ["Legerdemain"] = 17,
  ["Assault"]  = 8,
  ["Support"]  = 8,
  ["Werewolf"] = 8,
  ["Vampire"]  = 8,
  ["Fighters Guild"] = 8,
  ["Mages Guild"]    = 8,
  ["Undaunted"]      = 8,
  ["Psijic Order"]   = 8,
  ["Scrying"]        = 8,
  ["Excavation"]     = 8,
  ["AssignedCampaignRewardEarnedTier"] = 2,
  ["ReducedBounty"]     = 1,
}

-- VIEWS
ElderScrollsOfAlts.SkillsLevelMaximum = {
  ["Level"] = 50,
  ["Riding Speed"]     = 60,
  ["Riding Stamina"]   = 60,
  ["Riding Inventory"] = 60,
  ["Dark Brotherhood"] = 12,
  ["Thieves Guild"]    = 12,
  ["Legerdemain"] = 20,
  ["Soul Magic"]  = 6,
  ["Assault"]  = 10,
  ["Support"]  = 10,
  ["Werewolf"] = 10,
  ["Vampire"]  = 10,
  ["Fighters Guild"] = 10,
  ["Mages Guild"]    = 10,
  ["Undaunted"]      = 10,
  ["Psijic Order"]   = 10,
  ["Scrying"]        = 10,
  ["Excavation"]     = 10,
  ["AssignedCampaignRewardEarnedTier"] = 3,
  ["ReducedBounty"]     = 10000,
}

-----------
-- VIEWS: Lookup CRAFT
function ElderScrollsOfAlts:GetCraftSunkText(craftName,sunkVal) 
  craftName = string.lower(craftName)
  ElderScrollsOfAlts.debugMsg("GetCraftSunkText: craftName=",craftName, " sunkVal=", sunkVal)
  if(craftName=="jc" or craftName=="jewelry" or craftName==string.lower(GetString(ESOA_FULL_JC)) )then
    if(sunkVal == 0) then
      return "Allows the use of |c00FFFFPewter|r Ounces."
    elseif(sunkVal == 1) then
      return"Allows the use of |c00FFFFCopper|r Ounces."
    elseif(sunkVal == 2) then
      return "Allows the use of |c00FFFFSilver|r Ounces. (Create gear up to CP |c00FFFF80|r)."
    elseif(sunkVal == 3) then
      return "Allows the use of |c00FFFFElectrum|r Ounces. (Create gear up to CP |c00FFFF140|r)."
    elseif(sunkVal == 4) then
      return "Allows the use of |c00FFFFPlatinum|r Ounces."
    end
  elseif(craftName=="smithing" or craftName=="blacksmithing" or craftName==string.lower(GetString(ESOA_FULL_SMTH)) )then
    if(sunkVal == 0) then
      return "Allows the use of |c00FFFFIron|r Ingots (Create gear up to Lvl |c00FFFF14|r)."
    elseif(sunkVal == 1) then
      return "Allows the use of |c00FFFFSteel|r Ingots (Create gear up to Lvl |c00FFFF24|r)."
    elseif(sunkVal == 2) then
      return "Allows the use of |c00FFFFOrichalc|r Ingots (Create gear up to Lvl |c00FFFF34|r)."
    elseif(sunkVal == 3) then
      return "Allows the use of |c00FFFFDwarven|r Ingots (Create gear up to Lvl |c00FFFF44|r)."
    elseif(sunkVal == 4) then
      return "Allows the use of |c00FFFFEbony|r Ingots (Create gear up to Lvl |c00FFFF50|r)."
    elseif(sunkVal == 5) then
      return "Allows the use of |c00FFFFCalcinium|r Ingots (Create gear up to CP |c00FFFF30|r)."
    elseif(sunkVal == 6) then
      return "Allows the use of |c00FFFFGalatite|r Ingots (Create gear up to CP |c00FFFF60|r)."
    elseif(sunkVal == 7) then
      return "Allows the use of |c00FFFFQuicksilver|r Ingots (Create gear up to CP |c00FFFF80|r)."
    elseif(sunkVal == 8) then
      return "Allows the use of |c00FFFFVoidstone|r Ingots (Create gear up to CP |c00FFFF140|r)."
    elseif(sunkVal == 9) then  
      return "Allows the use of |c00FFFFRubedite|r Ingots (Create gear up to CP |c00FFFF160|r)."
    end
  elseif(craftName=="alchemy" or craftName==string.lower(GetString(ESOA_FULL_ALC)) )then
    if(sunkVal == 0) then  
      return "Allows the use of |c00FFFFNatural Water and Grease, Clear Water and Ichor|r (Makes a level |c00FFFF3 or 10|r concoction)."
    elseif(sunkVal == 1) then  
      return "Allows the use of |c00FFFFPristine Water and Slime|r (Makes a level |c00FFFF20|r concoction)."
    elseif(sunkVal == 2) then  
      return "Allows the use of |c00FFFFCleansed Water and Gall|r (Makes a level |c00FFFF30|r concoction)."
    elseif(sunkVal == 3) then  
      return "Allows the use of |c00FFFFFiltered Water and Terebinthine|r (Makes a level |c00FFFF40|r concoction)."
    elseif(sunkVal == 4) then  
      return "Allows the use of |c00FFFFPurified Water to Pitch-Blie|r (Makes a level |c00FFFFCP10|r concoction)."
    elseif(sunkVal == 5) then  
      return "Allows the use of |c00FFFFCloud Mist and Tarblack|r (Makes a level |c00FFFFCP50|r concoction)."
    elseif(sunkVal == 6) then  
      return "Allows the use of |c00FFFFStar Dew and Night-Oil|r (Makes a level |c00FFFFCP100|r concoction)."
    elseif(sunkVal == 7) then  
     return "Allows the use of |c00FFFFLorkhan's Tears and Alkhest|r (Makes a level |c00FFFFCP150|r concoction)."
    end
  elseif(craftName=="enchanting" or craftName==string.lower(GetString(ESOA_FULL_ENCH)) )then
    if(sunkVal == 0) then
      return "Allows the use of Common(|c00FFFFwhite|r) and Standard(green) Aspect Runestones."
    elseif(sunkVal == 1) then
      return "Allows the use of Superior(|c00FFFFblue|r) Aspect Runestones."
    elseif(sunkVal == 2) then
      return "Allows the use of Artifact (|cFF00FFpurple|r) Aspect Runestones."
    elseif(sunkVal == 3) then
      return "Allows the use of Legendary (|cFFFF00gold|r) Aspect Runestones."
    end
  elseif(craftName=="enchanting2" or craftName==string.lower(GetString(ESOA_FULL_ENCH)).."2" )then
    if(sunkVal == 0) then
      return "Allows the use of Jora, Porade, Jode and Notade Potency Runestones to make Glyphs of levels 1-15."
    elseif(sunkVal == 1) then
      return "Allows the use of Jera, Jejora, Ode and Tade Potency Runestones to make Glyphs of levels 10-25."   
    elseif(sunkVal == 2) then
      return   "Allows the use of Odra, Pojora, Jayde and Edode Potency Runestones to make Glyphs of levels 20-35."      
    elseif(sunkVal == 3) then
      return "Allows the use of Edora, Jaera, Pojode, and Rekude Potency Runestones to make Glyphs of levels 30-45."
    elseif(sunkVal == 4) then    
      return   "Allows the use of Pora, Denara, Hade and Idode Potency Runestones to make Glyphs from level 40 to Champion 30."
    elseif(sunkVal == 5) then    
      return "Allows the use of Rera and Pode Potency Runestones to make Glyphs of Champion 30-50."
    elseif(sunkVal == 6) then    
      return "Allows the use of Derado and Kedeko Potency Runestones to make Glyphs of Champion 50-70."
    elseif(sunkVal == 7) then    
      return"Allows the use of Rekura and Rede Potency Runestones to make Glyphs of Champion 70-90."
    elseif(sunkVal == 8) then   
      return "Allows the use of Kura and Kude Potency Runestones to make Glyphs of Champion 100-140."
     elseif(sunkVal == 9) then   
      return"Allows the use of Rejera, Repora, Jehade, and Itade Potency Runestones to make Glyphs of Champion 150 and 160."
    end
  elseif(craftName=="woodworking" or craftName==string.lower(GetString(ESOA_FULL_WOOD)) )then
    if(sunkVal == 0) then  
      return "Allows the use of Sanded |c00FFFFMaple|r wood (Create gear up to Lvl |c00FFFF14|r)."
    elseif(sunkVal == 1) then  
      return "Allows the use of Sanded |c00FFFFOak|r wood (Create gear up to Lvl |c00FFFF24|r)."
    elseif(sunkVal == 2) then  
      return "Allows the use of Sanded |c00FFFFBeech|r wood (Create gear up to Lvl |c00FFFF34|r)."
    elseif(sunkVal == 3) then  
      return "Allows the use of Sanded |c00FFFFHickory|r wood (Create gear up to Lvl |c00FFFF44|r)."
    elseif(sunkVal == 4) then  
      return "Allows the use of Sanded |c00FFFFYew|r wood (Create gear up to Lvl |c00FFFF50|r)."
    elseif(sunkVal == 5) then  
      return "Allows the use of Sanded |c00FFFFBirch|r wood (Create gear up to CP |c00FFFF30|r)."
    elseif(sunkVal == 6) then  
      return "Allows the use of Sanded |c00FFFFAsh|r wood (Create gear up to CP |c00FFFF60|r)."
    elseif(sunkVal == 7) then  
      return "Allows the use of Sanded |c00FFFFMahogany|r wood (Create gear up to CP |c00FFFF80|r)."
    elseif(sunkVal == 8) then        
      return "Allows the use of Sanded |c00FFFFNightwood|r (Create gear up to CP |c00FFFF140|r)."
    elseif(sunkVal == 9) then        
      return "Allows the use of Sanded |c00FFFFRuby Ash|r (Create gear up to CP |c00FFFF160|r)."
    end
  elseif(craftName=="clothing" or craftName==string.lower(GetString(ESOA_FULL_CLTH)) )then
    if(sunkVal == 0) then  
      return "Allows the use of |c00FFFFJute and Rawhide|r (Create gear up to Lvl |c00FFFF14|r)."
    elseif(sunkVal == 1) then  
      return "Allows the use of |c00FFFFFlax and Hide|r (Create gear up to Lvl |c00FFFF24|r)."
    elseif(sunkVal == 2) then  
      return "Allows the use of |c00FFFFCotton and Leather|r (Create gear up to Lvl |c00FFFF34|r)."
    elseif(sunkVal == 3) then  
      return "Allows the use of |c00FFFFSpidersilk and Thick Leather|r (Create gear up to Lvl |c00FFFF44|r)."
    elseif(sunkVal == 4) then  
      return "Allows the use of |c00FFFFEbonthread and Topgrain Hide|r (Create gear up to Lvl |c00FFFF50|r)."
    elseif(sunkVal == 5) then  
      return "Allows the use of |c00FFFFFamin and Fell Hide|r (Create gear up to CP |c00FFFF30|r)."
    elseif(sunkVal == 6) then  
      return "Allows the use of |c00FFFFIronthread and Iron Hide|r (Create gear up to CP |c00FFFF60|r)."
    elseif(sunkVal == 7) then  
      return "Allows the use of |c00FFFFSilverweave and Scaled Hide|r (Create gear up to CP |c00FFFF80|r)."
    elseif(sunkVal == 8) then
      return "Allows the use of |c00FFFFVoid Cloth and Daedra Hide|r (Create gear up to CP |c00FFFF140|r)."
    elseif(sunkVal == 9) then
      return "Allows the use of |c00FFFFAncestor Silk and Rubedo Leather|r (Create gear up to CP |c00FFFF160|r)."
    end
  elseif(craftName=="Provisioning" or craftName==string.lower(GetString(ESOA_FULL_PROV)) )then
    if(sunkVal == 0) then  
      return "Allows the use of Standard (|c00FF00green|r) Recipies."
    elseif(sunkVal == 1) then  
      return "Allows the use of Difficult (|c00FFFFblue|r) Recipies."
    elseif(sunkVal == 2) then  
      return "Allows the use of Complex (|cFF00FFpurple|r) Recipies."
    elseif(sunkVal == 3) then  
      return "Allows the use of Legendary (|cFFFF00yellow|r) Recipies."
    end
  elseif(craftName=="Provisioning2" or craftName==string.lower(GetString(ESOA_FULL_PROV)).."2" )then
    if(sunkVal == 0) then  
      return "Allows the making of up to level |c00FFFF19|r Recipes."
    elseif(sunkVal == 1) then  
      return "Allows the making of up to level |c00FFFF29|r Recipes."
    elseif(sunkVal == 2) then  
      return "Allows the making of up to level |c00FFFF39|r Recipes."
    elseif(sunkVal == 3) then  
       return "Allows the making of up to level |c00FFFF49|r Recipes."
    elseif(sunkVal == 4) then  
      return "Allows the making of up to Champion |c00FFFF50|r Recipes."
    elseif(sunkVal == 5) then  
      return "Allows the making of up to Champion |c00FFFF150|r Recipes."
    end
  end  
  return ""
end

-----------
-- VIEWS
function ElderScrollsOfAlts:GetGenderFullText(genderId)
  local genderName = GetString(ESOA_GENDER_OTHER)
    if genderId == 0 then
      genderName = GetString(ESOA_GENDER_MALE)
    elseif genderId == 1 then
      genderName = GetString(ESOA_GENDER_FEMALE)
    elseif genderId == 2 then
      genderName = GetString(ESOA_GENDER_MALE)
    end
    return genderName
end

-----------
-- VIEWS
function ElderScrollsOfAlts:GetGenderText(genderId)
  local genderName = GetString(ESOA_GENDER_OTHER_S)
    if genderId == 0 then
      genderName = GetString(ESOA_GENDER_MALE_S)
    elseif genderId == 1 then
      genderName = GetString(ESOA_GENDER_FEMALE_S)
    elseif genderId == 2 then
      genderName = GetString(ESOA_GENDER_MALE_S)
    end
    return genderName
end

-----------
-- VIEWS
function ElderScrollsOfAlts:GetClassText(className)
  local classX = zo_strformat( "<<1>>", className ) -- get rid of links and junk. --GetString(ESOA_CLASS_DEFAULT_ABBREV)
  if className == GetString(ESOA_CLASS_DRAGONKNIGHT) then
    classX = GetString(ESOA_CLASS_DRAGONKNIGHT_ABBREV)
  elseif className == GetString(ESOA_CLASS_SORCERER) then
    classX = GetString(ESOA_CLASS_SORCERER_ABBREV)
  elseif className == GetString(ESOA_CLASS_NIGHTBLADE) then
    classX = GetString(ESOA_CLASS_NIGHTBLADE_ABBREV) 
  elseif className == GetString(ESOA_CLASS_TEMPLAR) then
    classX = GetString(ESOA_CLASS_TEMPLAR_ABBREV)
  elseif className == GetString(ESOA_CLASS_WARDEN) then
    classX = GetString(ESOA_CLASS_WARDEN_ABBREV)
  elseif className == GetString(ESOA_CLASS_NECRO) then
    classX = GetString(ESOA_CLASS_NECRO_ABBREV)
  elseif className == GetString(ESOA_CLASS_ARCANIST) then
    classX = GetString(ESOA_CLASS_ARCANIST_ABBREV)
  end
  return classX
end

-----------
-- VIEWS
function ElderScrollsOfAlts:GetRaceText1(raceName)
  local raceX = zo_strformat( "<<1>>", raceName ) -- get rid of links and junk.
  if raceName == GetString(ESOA_RACE_HIGHELF) then
    raceX = GetString(ESOA_RACE_HIGHELF_ABBREV) 
  elseif raceName == GetString(ESOA_RACE_WOODELF) then
    raceX = GetString(ESOA_RACE_WOODELF_ABBREV)
  elseif raceName == GetString(ESOA_RACE_KHAJIIT) then
    raceX = GetString(ESOA_RACE_KHAJIIT_ABBREV)
  elseif raceName == GetString(ESOA_RACE_ARGONIAN) then
    raceX = GetString(ESOA_RACE_ARGONIAN_ABBREV)
  elseif raceName == GetString(ESOA_RACE_DARKELF) then
    raceX = GetString(ESOA_RACE_DARKELF_ABBREV)
  end
  return raceX
end

-----------
-- VIEWS
function ElderScrollsOfAlts:GetRaceText2(raceName)
  local raceX = zo_strformat( "<<1>>", raceName ) -- get rid of links and junk. --GetString(ESOA_RACE_UNKNOWN)
  if raceName == GetString(ESOA_RACE_HIGHELF) then
    raceX = GetString(ESOA_RACE_HIGHELF_ABBREV2)
  elseif raceName == GetString(ESOA_RACE_WOODELF) then
    raceX = GetString(ESOA_RACE_WOODELF_ABBREV2)
  elseif raceName == GetString(ESOA_RACE_KHAJIIT) then
    raceX = GetString(ESOA_RACE_KHAJIIT_ABBREV2)
  elseif raceName == GetString(ESOA_RACE_ARGONIAN) then
    raceX = GetString(ESOA_RACE_ARGONIAN_ABBREV2)
  elseif raceName == GetString(ESOA_RACE_NORD) then
    raceX = GetString(ESOA_RACE_NORD_ABBREV)
  elseif raceName == GetString(ESOA_RACE_DARKELF) then
    raceX = GetString(ESOA_RACE_DARKELF_ABBREV2)
  elseif raceName == GetString(ESOA_RACE_BRETON) then
    raceX = GetString(ESOA_RACE_BRETON_ABBREV)
  elseif raceName == GetString(ESOA_RACE_ORC) then
    raceX = GetString(ESOA_RACE_ORC_ABBREV)
  elseif raceName == GetString(ESOA_RACE_REDGUARD) then
    raceX = GetString(ESOA_RACE_REDGUARD_ABBREV)   
  end
  return raceX
end

-----------
-- VIEWS
function ElderScrollsOfAlts:GetAllianceIcon(alliance)
  return ZO_GetAllianceIcon(alliance)
end

-----------
-- VIEWS
function ElderScrollsOfAlts:getInfamyLevelText(infamyLevel)
  if(infamyLevel==nil) then
    return GetString(ESOA_INFAMY_UPSTANDING)
  end
  if(infamyLevel==INFAMY_THRESHOLD_DISREPUTABLE) then
    return GetString(ESOA_INFAMY_DISREPUTABLE)
  elseif(infamyLevel==INFAMY_THRESHOLD_FUGITIVE) then
    return GetString(ESOA_INFAMY_FUGITIVE)
  elseif(infamyLevel==INFAMY_THRESHOLD_NOTORIOUS) then
    return GetString(ESOA_INFAMY_NOTORIOUS)
  elseif(infamyLevel==INFAMY_THRESHOLD_UPSTANDING) then
	return GetString(ESOA_INFAMY_UPSTANDING)
  end  
  return GetString(ESOA_INFAMY_UPSTANDING)
end

-----------
-- VIEWS
function ElderScrollsOfAlts:ListAllAllowedViewEntries()
  local printEntries = "" 
  for kName, kVal in pairs(ElderScrollsOfAlts.allowedViewEntries) do
    printEntries = zo_strformat("<<1>> {<<2>>},", printEntries, kName )
  end
  printEntries = "Allowable entry names: " .. printEntries
  ElderScrollsOfAlts.outputMsg(printEntries)
end

-- ESOA_ChampionAssignableActionBar
function ElderScrollsOfAlts:XlateChampionNameToShort(cpid)
  local txt = ""
  txt = ElderScrollsOfAlts.ChampionPointActiveSimpleNameLookup[cpid]
  --[[
  --d("ID: ".. tostring(cpid) )
  if(cpid==nil) then
    txt  = ""
    
  elseif(cpid==2) then
    txt  = "VIT"
  elseif(cpid==3) then
    txt  = "ARC"
  elseif(cpid==5) then
    txt  = "END"
  elseif(cpid==25) then
    txt  = "DA"
  elseif(cpid==27) then
    txt  = "DOT"
  elseif(cpid==30) then
    txt  = "REAV"
  elseif(cpid==32) then
    txt  = "OCC"
  elseif(cpid==35) then
    txt  = "REJ"
    
  elseif(cpid==51) then
    txt  = "EVA"
  elseif(cpid==52) then
    txt  = "SLI"
  elseif(cpid==57) then
    txt  = "SI"
  elseif(cpid==65) then
    txt  = "SHA"
  elseif(cpid==66) then
    txt  = "MOV"
  elseif(cpid==79) then
    txt  = "TREA"
    
  elseif(cpid==85) then
    txt  = "RAT"
  elseif(cpid==86) then
    txt  = "LIQ"
  elseif(cpid==134) then
    txt  = "DR"
  end
  --]]
  return txt
end


-- VIEWS
ElderScrollsOfAlts.ChampionPointActiveSimpleNameLookup = {
  [2]   = "VIT",
  [3]   = "ARC",
  [4]   = "??",
  [5]   = "END",
  [8]   = "WRA",
  [11]   = "SLIP",
  [25]  = "DA",
  [26]  = "??",
  [27]  = "DOT",
  [28]  = "??",
  [29]  = "??",
  [30]  = "REAV",
  [31]  = "??",
  [32]  = "OCC",
  [33]  = "??",
  [34]  = "IRON",
  [35]  = "REJ",
  [47]  = "SIPH",
  [51]  = "EVA",
  [52]  = "SLI",
  [57]  = "SI",
  [65]  = "SHA",
  [66]  = "MOV",
  [76]  = "LOW",
  [77]  = "INF",
  [78]  = "GATH",
  [79]  = "TREA",
  [80]  = "??",
  [81]  = "HARV",
  [82]  = "??",
  [83]  = "DIS",
  [84]  = "FADE",
  [85]  = "RAT",
  [86]  = "LIQ",
  [91]  = "HOM",
  [133]  = "AOEDR",
  [134]  = "DR",
  [136]  = "ER",
}

-----------
-- EOF   --