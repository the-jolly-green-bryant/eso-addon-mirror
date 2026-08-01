-- First, we create a namespace for our addon by declaring a top-level table that will hold everything else.
CompletionistsLists = {}

 
-- This isn't strictly necessary, but we'll use this string later when registering events.
-- Better to define it in a single place rather than retyping the same string.
CompletionistsLists.name = "CompletionistsLists"
local versionStr = "v0600"

local crResultList = {}
local crResultIds = {}
local currentPage = 1 -- initialize
local totalResultPages = 1 -- initialize
local fullLogTxt = "" -- initialize
local displayOption = 0 -- 0 show in grid, 1 show one per line
local displayOptionAll = 0 -- 1 show all, 0 show only weapon, shield and jewelery
local showFilter = 0 -- 0 all in game, 1 all known motif, all known furniture, all prov, all antiquities
local maxTxtLength = 28000 -- max is 29000 but want to be safe
local maxLinkNr = 5 -- guessing, need to calibrate?
local useLinkNotName = false 
local currentLinkCount = 0
local minLogLevel = 2 -- you can change for more verbose logging
-- to simplify for loops
local idFirstFurnishingRecipyList = 17 
local idLastFurnishingRecipyList = 30 
local idFirstProvisioningRecipyList = 1 
local idLastProvisioningRecipyList = 16 

local LibZone = LibZone
local LibMotif = LibMotif

filterList = {
[0] = "List All In Game",
[1] = "List All Antiquities",
[2] = "List All Furniture Recipes",
[3] = "List All Provisioning Recipes",
[4] = "List All Known Motifs",
[5] = "List All Item Collection",
[6] = "List All Achievements",
[7] = "List All Tradable in Bag",
[8] = "List All Tradable Recipies"
}

-- displayText id is filter*10 + display option
-- [0] = "List All In Game",
-- [1] = "List All Antiquities",
displayText = {
[20] = "Show only names for furniture recipe pages (click box to change)",
[21] = "Show furniture recipe pages with full info (click box to change)",
[30] = "Show only names for provisioning recipe pages (click box to change)",
[31] = "Show provisioning recipe pages with full info (click box to change)",
[40] = "Show motifs one page per line (click box to change)",
[41] = "Show motif pages in one row (click box to change)",
[50] = "Show missing trial weapons and jewelery, one item per line (click box to change)",
[51] = "Show known/unknown in one row per set (click box to change)",
[60] = "Show earned achievements, one per line (click box to change)",
[61] = "Show all achievements in game (click box to change)"
}

-- data mined
local recipyListIdsToCategory = {
  [1] = SI_ITEMTYPEDISPLAYCATEGORY16, -- Meat Dishes
  [2] = SI_ITEMTYPEDISPLAYCATEGORY16, -- Fruit Dishes
  [3] = SI_ITEMTYPEDISPLAYCATEGORY16, -- Vegetable Dishes
  [4] = SI_ITEMTYPEDISPLAYCATEGORY16, -- Savouries
  [5] = SI_ITEMTYPEDISPLAYCATEGORY16, -- Ragout
  [6] = SI_ITEMTYPEDISPLAYCATEGORY16, -- Entremet
  [7] = SI_ITEMTYPEDISPLAYCATEGORY16, -- Gourmet
  [8] = SI_ITEMTYPEDISPLAYCATEGORY16, -- Alcoholic Drinks
  [9] = SI_ITEMTYPEDISPLAYCATEGORY16, -- Tea
  [10] = SI_ITEMTYPEDISPLAYCATEGORY16, -- Tonics
  [11] = SI_ITEMTYPEDISPLAYCATEGORY16, -- Liqueurs
  [12] = SI_ITEMTYPEDISPLAYCATEGORY16, -- Tinctures
  [13] = SI_ITEMTYPEDISPLAYCATEGORY16, -- Cordial Teas
  [14] = SI_ITEMTYPEDISPLAYCATEGORY16, -- Distillates
  [15] = SI_ITEMTYPEDISPLAYCATEGORY16, -- Delicacies
  [16] = SI_ITEMTYPEDISPLAYCATEGORY16, -- Delicacies
  [17] = SI_ITEMTYPEDISPLAYCATEGORY6, -- Conservatory
  [18] = SI_ITEMTYPEDISPLAYCATEGORY6, -- Courtyard
  [19] = SI_ITEMTYPEDISPLAYCATEGORY6, -- Dining
  [20] = SI_ITEMTYPEDISPLAYCATEGORY6, -- Gallery
  [21] = SI_ITEMTYPEDISPLAYCATEGORY6, -- Hearth
  [22] = SI_ITEMTYPEDISPLAYCATEGORY6, -- Library
  [23] = SI_ITEMTYPEDISPLAYCATEGORY6, -- Parlor
  [24] = SI_ITEMTYPEDISPLAYCATEGORY6, -- Lighting
  [25] = SI_ITEMTYPEDISPLAYCATEGORY6, -- Structures
  [26] = SI_ITEMTYPEDISPLAYCATEGORY6, -- Suite
  [27] = SI_ITEMTYPEDISPLAYCATEGORY6, -- Undercroft
  [28] = SI_ITEMTYPEDISPLAYCATEGORY6, -- Workshop
  [29] = SI_ITEMTYPEDISPLAYCATEGORY6, -- Miscellaneous
  [30] = SI_ITEMTYPEDISPLAYCATEGORY6, -- Services
}

-- From MasterRecipy List
local qualityText = {
	[1]= {hex = "ffffff", color = "White"},
	[2]= {hex = "00ff00", color = "Green"},
	[3]= {hex = "3a92ff", color = "Blue"},
	[4]= {hex = "a02ef7", color = "Purple"},
	[5]= {hex = "eeca2a", color = "Gold"},
}

-- From MasterRecipy List
local skillType = {
	[CRAFTING_TYPE_BLACKSMITHING] = SI_ITEMTYPEDISPLAYCATEGORY10,
	[CRAFTING_TYPE_CLOTHIER] = SI_ITEMTYPEDISPLAYCATEGORY11,
	[CRAFTING_TYPE_ENCHANTING] = SI_ITEMTYPEDISPLAYCATEGORY15,
	[CRAFTING_TYPE_ALCHEMY] = SI_ITEMTYPEDISPLAYCATEGORY14,
	[CRAFTING_TYPE_PROVISIONING] = SI_ITEMTYPEDISPLAYCATEGORY16,
	[CRAFTING_TYPE_WOODWORKING] = SI_ITEMTYPEDISPLAYCATEGORY12,
	[CRAFTING_TYPE_JEWELRYCRAFTING] = SI_ITEMTYPEDISPLAYCATEGORY3,
}

-- from LibMotif
local maxMotifPageNumbers = 14
local motifPageText = {
	[1] = SI_ITEMSTYLECHAPTER10, -- Axe
	[2] = SI_ITEMSTYLECHAPTER6, --"Belts",
	[3] = SI_ITEMSTYLECHAPTER3, --"Boots",
	[4] = SI_ITEMSTYLECHAPTER14, --"Bows",
	[5] = SI_ITEMSTYLECHAPTER5, --"Chests",
	[6] = SI_ITEMSTYLECHAPTER11, --"Daggers",
	[7] = SI_ITEMSTYLECHAPTER2, --"Gloves",
	[8] = SI_ITEMSTYLECHAPTER1, --"Helmets",
	[9] = SI_ITEMSTYLECHAPTER4, --"Legs",
	[10] = SI_ITEMSTYLECHAPTER9, --"Maces",
	[11] = SI_ITEMSTYLECHAPTER13, --"Shields",
	[12] = SI_ITEMSTYLECHAPTER7, --"Shoulders",
	[13] = SI_ITEMSTYLECHAPTER12, --"Staves",
	[14] = SI_ITEMSTYLECHAPTER8, --"Swords",
}

-- from running get equipment type on index
local maxItemSetSlots = 22
local itemSetSlot = {
	[1] = SI_EQUIPTYPE1, -- head
	[2] = SI_EQUIPTYPE4, -- shoulder
	[3] = SI_EQUIPTYPE3, -- chest
	[4] = SI_EQUIPTYPE13,-- hand
	[5] = SI_EQUIPTYPE8, -- waist
	[6] = SI_EQUIPTYPE9, -- legs
	[7] = SI_EQUIPTYPE10, -- feet
	[8] = SI_EQUIPTYPE2, -- neck
	[9] = SI_EQUIPTYPE12, -- ring
	[10] = SI_ITEMSTYLECHAPTER11, -- dagger
	[11] = SI_ITEMSTYLECHAPTER10, -- Axe
	[12] = SI_ITEMSTYLECHAPTER9, --"Maces",
	[13] = SI_ITEMSTYLECHAPTER8, --"Swords",
	[14] = SI_ITEMSTYLECHAPTER10, -- Axe
	[15] = SI_ITEMSTYLECHAPTER9, --"Maces",
	[16] = SI_ITEMSTYLECHAPTER8, --"Swords",
	[17] = SI_ITEMSTYLECHAPTER14, --"Bows",
	[18] = SI_WEAPONCONFIGTYPE6, --"Staves",resto
	[19] = SI_WEAPONCONFIGTYPE7, --"Staves",flame
	[20] = SI_WEAPONCONFIGTYPE8, --"Staves",frost
	[21] = SI_WEAPONCONFIGTYPE9, --"Staves",lightning
	[22] = SI_ITEMSTYLECHAPTER13, --"Shields",
}

local itemSetType = {
[1] = SI_WEAPONTYPE0, -- irrelevant
[2] = SI_INSTANCEDISPLAYTYPE2, -- ITEM_SET_TYPE_DUNGEON
[3] = SI_SKILLTYPE4, -- ITEM_SET_TYPE_WORLD | Mythic
[4] = SI_SKILLTYPE2, -- ITEM_SET_TYPE_WEAPON
[5] = SI_SPECIALIZEDITEMTYPE406, -- ITEM_SET_TYPE_MONSTER
-- ITEM_SET_TYPE_NONE
-- ITEM_SET_TYPE_CRAFTED
}

local trialSetIds = {
[136] = "Immortal Warrior",
[137] = "Berserking Warrior",
[138] = "Defending Warrior",
[139] = "Wise Mage",
[140] = "Destructive Mage",
[141] = "Healing Mage",
[142] = "Quick Serpent",
[143] = "Poisonous Serpent",
[144] = "Twice-Fanged Serpent",
[171] = "Eternal Warrior",
[172] = "Infallible Mage",
[173] = "Vicious Serpent",
[229] = "Twilight Remedy",
[230] = "Moondancer",
[231] = "Lunar Bastion",
[232] = "Roar of Alkosh",
[330] = "Automated Defense",
[331] = "War Machine",
[332] = "Master Architect",
[333] = "Inventor's Guard",
[357] = "Perfected Disciplined Slash",
[358] = "Perfected Defensive Position",
[359] = "Perfected Chaotic Whirlwind",
[360] = "Perfected Piercing Spray",
[361] = "Perfected Concentrated Force",
[362] = "Perfected Timeless Blessing",
[363] = "Disciplined Slash",
[364] = "Defensive Position",
[365] = "Chaotic Whirlwind",
[366] = "Piercing Spray",
[367] = "Concentrated Force",
[368] = "Timeless Blessing",
[388] = "Aegis of Galenwe",
[389] = "Arms of Relequen",
[390] = "Mantle of Siroria",
[391] = "Vestment of Olorime",
[392] = "Perfected Aegis of Galenwe",
[393] = "Perfected Arms of Relequen",
[394] = "Perfected Mantle of Siroria",
[395] = "Perfected Vestment of Olorime",
[443] = "Eye of Nahviintaas",
[444] = "False God's Devotion",
[445] = "Tooth of Lokkestiiz",
[446] = "Claw of Yolnahkriin",
[448] = "Perfected Eye of Nahviintaas",
[449] = "Perfected False God's Devotion",
[450] = "Perfected Tooth of Lokkestiiz",
[451] = "Perfected Claw of Yolnahkriin",
[492] = "Kyne's Wind",
[493] = "Perfected Kyne's Wind",
[494] = "Vrol's Command",
[495] = "Perfected Vrol's Command",
[496] = "Roaring Opportunist",
[497] = "Perfected Roaring Opportunist",
[498] = "Yandir's Might",
[499] = "Perfected Yandir's Might",
[585] = "Saxhleel Champion",
[586] = "Sul-Xan's Torment",
[587] = "Bahsei's Mania",
[588] = "Stone-Talker's Oath",
[589] = "Perfected Saxhleel Champion",
[590] = "Perfected Sul-Xan's Torment",
[591] = "Perfected Bahsei's Mania",
[592] = "Perfected Stone-Talker's Oath"
}

local weaponToString = {
  [WEAPONTYPE_HEALING_STAFF] = SI_WEAPONCONFIGTYPE6, -- resto staff
  [WEAPONTYPE_BOW] = SI_ITEMSTYLECHAPTER14,
  [WEAPONTYPE_TWO_HANDED_AXE] = SI_EQUIPTYPE6,
  [WEAPONTYPE_TWO_HANDED_HAMMER] = SI_EQUIPTYPE6,
  [WEAPONTYPE_TWO_HANDED_SWORD] = SI_EQUIPTYPE6,
  [WEAPONTYPE_FIRE_STAFF] = SI_WEAPONCONFIGTYPE5,
  [WEAPONTYPE_FROST_STAFF] = SI_WEAPONCONFIGTYPE5,
  [WEAPONTYPE_LIGHTNING_STAFF] = SI_WEAPONCONFIGTYPE5, -- destro staff
  [WEAPONTYPE_DAGGER] = SI_WEAPONCONFIGTYPE2,
  [WEAPONTYPE_SWORD] = SI_EQUIPTYPE5, -- One-hand and shield
  [WEAPONTYPE_SHIELD] = SI_WEAPONTYPE14,
}

local bagsToCheck = {
	[BAG_WORN] 				= false,
	[BAG_BACKPACK] 			= true,
	[BAG_BANK] 				= true,
	[BAG_SUBSCRIBER_BANK]	= true,
	[BAG_GUILDBANK] 		= true,
	[BAG_VIRTUAL] 			= false,
	[BAG_HOUSE_BANK_ONE] 	= true,
	[BAG_HOUSE_BANK_TWO] 	= true,
	[BAG_HOUSE_BANK_THREE]	= true,
	[BAG_HOUSE_BANK_FOUR] 	= true,
	[BAG_HOUSE_BANK_FIVE] 	= true,
	[BAG_HOUSE_BANK_SIX] 	= true,
	[BAG_HOUSE_BANK_SEVEN] 	= true,
	[BAG_HOUSE_BANK_EIGHT] 	= true,
	[BAG_HOUSE_BANK_NINE] 	= true,
	[BAG_HOUSE_BANK_TEN] 	= true,
	}

------ COMMON FUNCTIONS ------
   
function CompletionistsLists.DebugMsg(logLvl,logInputmsg)
  if (logLvl < minLogLevel) then
    return
  end
  local totalLogMsgLenght = string.len(fullLogTxt)
  if (totalLogMsgLenght > 0) then
    fullLogTxt = fullLogTxt .. "\r\n"
  end
  fullLogTxt = fullLogTxt .. logInputmsg
  if (totalLogMsgLenght > maxTxtLength) then
    fullLogTxt = string.sub(fullLogTxt,totalLogMsgLenght-maxTxtLength)
  end
  CHAT_ROUTER:AddSystemMessage(fullLogTxt)
end 

function CompletionistsLists.Initialize()
  -- change header test
  CompletionistsLists.DebugMsg(0,"Initialize Completionist's Lists")
  CompletionistsLists.savedVariables = ZO_SavedVars:NewAccountWide("CompletionistsListsSavedVariables", 2, nil, {}, GetWorldName())
  CompletionistsLists.RestorePosition(false)
end

-- Then we create an event handler function which will be called when the "addon loaded" event
-- occurs. We'll use this to initialize our addon after all of its resources are fully loaded.
function CompletionistsLists.OnAddOnLoaded(event, addonName)
  -- The event fires each time *any* addon loads - but we only care about when our own addon loads.
  if addonName == CompletionistsLists.name then   
    EVENT_MANAGER:UnregisterForEvent(CompletionistsLists.name, EVENT_ADD_ON_LOADED)
    SCENE_MANAGER:RegisterTopLevel(CompletionistsListsWindow, false)
    SLASH_COMMANDS["/completionistslists"] = CompletionistsLists.SlashCommands
    --SLASH_COMMANDS["/completionistslistsexport"] = CompletionistsLists.ExportToSavedVariables
    SLASH_COMMANDS["/completionistslistsbag"] = CompletionistsLists.ListBags
    
    --EVENT_MANAGER:RegisterForEvent(CompletionistsLists.name, EVENT_LOOT_RECEIVED, CompletionistsLists.meeethooood)
    --( eventCode, receivedBy, itemName, quantity, soundCategory, lootType, self, isPickpocketLoot, questItemIcon, itemId, isStolen )

 
    CompletionistsLists.Initialize()
  end
end

function CompletionistsLists.SlashCommands(cmd)
  CompletionistsLists.DebugMsg(0,"CompletionistsLists.SlashCommands") 
  
  if(minLogLevel == 0) then
    CompletionistsListsWindow_ShowAll:SetEnabled(true)
    CompletionistsListsWindow_ShowItemCollections:SetEnabled(true)
    CompletionistsListsWindow_ShowAntiquities:SetEnabled(true)
    CompletionistsListsWindow_ShowAchievements:SetEnabled(true)
  else
    CompletionistsListsWindow_ShowAll:SetEnabled(false)
    CompletionistsListsWindow_ShowItemCollections:SetEnabled(false)
    CompletionistsListsWindow_ShowAntiquities:SetEnabled(false)
    CompletionistsListsWindow_ShowAchievements:SetEnabled(false)
  end
  
  if (cmd == nil) or (cmd == "") then
    CompletionistsLists.ClearResultPages()
    CompletionistsLists.ToggleWindow()
		return
	end

	if (cmd == "bag") then
    CompletionistsLists.ShowWindow(false)
		CompletionistsLists.ListBags(false)
		return
	end

  if (cmd == "help") then
    local txt = "CompletionistsLists Options: "
    txt = txt .. "\r\n" .. " no command - toggles window on/off"
    txt = txt .. "\r\n" .. " help - lists command options"
    txt = txt .. "\r\n" .. " bag - lists content of bags in window, if guildbank is open then lists chosen guildbank"
    txt = txt .. "\r\n" .. " recipe - lists recipies and motifs in bags in window, if guildbank is open then lists chosen guildbank"
    txt = txt .. "\r\n" .. " reset - resets lists and window position"
    CHAT_ROUTER:AddSystemMessage(txt)
		return
	end
  
	if (cmd == "recipe") then
    CompletionistsLists.ShowWindow(false)
		CompletionistsLists.ListBags(true)
		return
	end

	if (cmd == "reset") then
    CompletionistsLists.ClearResultPages()
    CompletionistsLists.RestorePosition(true)
		return
	end

end

------ COMMON FUNCTIONS: WINDOW POSITION AND VISIBILITY ------

function CompletionistsLists.UpdatePositionVariables(resetOriginal)
  CompletionistsLists.DebugMsg(0,"CompletionistsLists.UpdatePositionVariables")
  local left = CompletionistsListsWindow:GetLeft()
  local top = CompletionistsListsWindow:GetTop()
  if(resetOriginal) then
    left = -20
    top = 0
  end  
  CompletionistsLists.savedVariables.left = left
  CompletionistsLists.savedVariables.top = top
end

function CompletionistsLists.OnWindowMoveStop()
  CompletionistsLists.DebugMsg(0,"CompletionistsLists.OnWindowMoveStop")
  CompletionistsLists.UpdatePositionVariables(false)
end

function CompletionistsLists.RestorePosition(resetOriginal)
  CompletionistsLists.DebugMsg(0,"CompletionistsLists.RestorePosition")
  CompletionistsLists.UpdatePositionVariables(resetOriginal)
  CompletionistsListsWindow:ClearAnchors()
  CompletionistsListsWindow:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, CompletionistsLists.savedVariables.left, CompletionistsLists.savedVariables.top)
end

function CompletionistsLists.ToggleWindow()
	local control = GetControl('CompletionistsListsWindow')
  if(control:IsHidden()) then 
    CompletionistsLists.DebugMsg(0,"CompletionistsLists show...")
	  SCENE_MANAGER:ShowTopLevel(CompletionistsListsWindow)
  else
    CompletionistsLists.DebugMsg(0,"CompletionistsLists hide...")
    SCENE_MANAGER:HideTopLevel(CompletionistsListsWindow)
  end
end

function CompletionistsLists.ShowWindow(reset)
  CompletionistsLists.DebugMsg(0,"CompletionistsLists.ShowWindow")
	local control = GetControl('CompletionistsListsWindow')
  if(reset) then
    CompletionistsLists.ClearResultPages()
  end  
  if(control:IsHidden()) then 
    CompletionistsLists.DebugMsg(0,"show...")
	  SCENE_MANAGER:ShowTopLevel(CompletionistsListsWindow)
  end
end

------ COMMON FUNCTIONS: RESULT DISPLAY ------

function CompletionistsLists.ClearResultPages()
  CompletionistsLists.DebugMsg(0,"CompletionistsLists.ClearResultPages")
  totalResultPages = 1
  currentPage = 1
  crResultList = {}
  CompletionistsLists.UpdateWindowResultList()
end

function CompletionistsLists.ChangePage(pageAdd)
  CompletionistsLists.DebugMsg(0,"CompletionistsLists.ChangePage")
  if(pageAdd ~= nil) then
    currentPage = currentPage + pageAdd
  else
    currentPage = 1
  end
  if (totalResultPages < currentPage or 1 > currentPage) then
    CompletionistsLists.DebugMsg(0,"At the end of list")
    currentPage = currentPage - pageAdd
  else
    CompletionistsLists.DebugMsg(0,"Show page " .. currentPage)
    CompletionistsLists.UpdateWindowResultList()
  end
end

function CompletionistsLists.GetTextToDisplay()
  if(showFilter == 8) then
    crResultList[currentPage] = ""
    local startId = 1 + ((currentPage-1) * maxLinkNr)
    local endId = startId + maxLinkNr - 1
    for currItem = startId, endId do
      if(crResultIds[currItem] ~= nil) then
        crResultList[currentPage] = crResultList[currentPage] .. "\r\n" .. crResultIds[currItem]
      end
    end
  end
  return crResultList[currentPage]
end

function CompletionistsLists.UpdateWindowResultList()
  if (totalResultPages < currentPage) then
    currentPage = totalResultPages
  end
  local txt = CompletionistsLists.GetTextToDisplay()
  CompletionistsListsWindowResultList:SetText(txt)
  CompletionistsLists.setUIPageNumbers()
end

function CompletionistsLists.setUIPageNumbers()
  CompletionistsLists.DebugMsg(0,"CompletionistsLists.setUIPageNumbers")
  if (currentPage == 1) then
    CompletionistsListsWindowPrevPageButton:SetEnabled(false)
  else
    CompletionistsListsWindowPrevPageButton:SetEnabled(true)
  end
  if (currentPage == totalResultPages) then
    CompletionistsListsWindowNextPageButton:SetEnabled(false)
  else
    CompletionistsListsWindowNextPageButton:SetEnabled(true)
  end
  CompletionistsListsWindowPageLabel:SetText("Page: " .. currentPage .. "/" .. totalResultPages)
end

------ COMMON FUNCTIONS: RESULT TEXT HANDLERS ------

function CompletionistsLists.GetUpdatedText(pageIndex, tText, itemText)
  if (string.len(tText) > maxTxtLength) then
    CompletionistsLists.DebugMsg(0,"Increase total pages.. ")
    pageIndex = pageIndex + 1   
    tText = ""
  elseif string.len(tText) > 0 then
    CompletionistsLists.DebugMsg(0,"Add to existing list.. ")
    itemText = "\r\n" .. itemText 
  end
  tText = tText .. itemText
  return pageIndex, tText
end

function CompletionistsLists.GetTextAndNewPageIfNotFit(tText, tAdditionalText, pageIndex)
  if(tAdditionalText == nil or tText == nil or pageIndex == nil) then
    return tText, pageIndex
  end
  local returnText = ""
  local returnPageIndex = pageIndex
  if tText ~= nil then
    if(useLinkNotName) then
      if (currentLinkCount < maxLinkNr) then
        CompletionistsLists.DebugMsg(0,"Add to existing list.. ")
        returnText = tText .. "\r\n"
        currentLinkCount = currentLinkCount + 1
      else
        CompletionistsLists.DebugMsg(0,"Increase total pages.. ")
        returnPageIndex = returnPageIndex + 1
        currentLinkCount = 0
      end    
    else
      local availableSpace = (maxTxtLength - string.len(tText))
      if (string.len(tAdditionalText) > availableSpace) then
        CompletionistsLists.DebugMsg(0,"Increase total pages.. ")
        returnPageIndex = returnPageIndex + 1
      else
        CompletionistsLists.DebugMsg(0,"Add to existing list.. ")
        returnText = tText .. "\r\n"
      end
    end
  else
    CompletionistsLists.DebugMsg(0,"First in list.. ")
  end
  returnText = returnText .. tAdditionalText
  return returnText, returnPageIndex
end

function CompletionistsLists.AddToResultListAndReturnLastEmptyPage(textList, totalPagesInList, firstPageIndex)
  local lastPageIndex = firstPageIndex
  for pageNr = 1, totalPagesInList do
    crResultList[lastPageIndex] = textList[pageNr] .. "\r\n"
    lastPageIndex = lastPageIndex + 1
  end
  totalResultPages = lastPageIndex - 1
  return lastPageIndex
end

------ COMMON FUNCTIONS: CALLED BY UI ------

function CompletionistsLists.ApplyFilter(filterType)
  CompletionistsLists.DebugMsg(0,"ApplyFilter")
  local filterCaption = versionStr .. " " .. filterList[filterType]
  local hideDisplayBox = true
  if(filterCaption == nil) then
    filterCaption = "ApplyFilter Unhandled"
  end
  TitleLabel:SetText(filterCaption)
  CompletionistsLists.DebugMsg(1,filterCaption)
  -- Reset variables
  crResultList = {}
  showFilter = filterType -- 0 all in game, 1 all known motif, all known furniture, all prov, all antiquities
  currentPage = 1
  if(filterType == 0) then
    CompletionistsLists.ListAllGameRecipesAndMotifs()
  elseif(filterType == 1) then
    CompletionistsLists.ListAllAntiquities()
  elseif(filterType == 2) then
    CompletionistsLists.ListAllKnownRecipes(idFirstFurnishingRecipyList, idLastFurnishingRecipyList)
    hideDisplayBox = false
  elseif(filterType == 3) then
    CompletionistsLists.ListAllKnownRecipes(idFirstProvisioningRecipyList, idLastProvisioningRecipyList)
    hideDisplayBox = false
  elseif(filterType == 4) then
    hideDisplayBox = false
    CompletionistsLists.ListAllKnownMotifs()
  elseif(filterType == 5) then
    CompletionistsLists.ListAllItemSets()
    hideDisplayBox = false
  elseif(filterType == 6) then
    CompletionistsLists.ExportAchievements()
    hideDisplayBox = false
  elseif(filterType == 7) then
    CompletionistsLists.ListBags(false)
  elseif(filterType == 8) then
    CompletionistsLists.ListBags(true)
  else
    CompletionistsLists.DebugMsg(1,filterCaption .. " " .. filterType)
    return
  end
  local labelId = (showFilter * 10) + displayOption
  local labelText = displayText[labelId]
  if(labelText == nil) then
    labelText = "Unhandled Filter"
  end
  CompletionistsListsWindow_DisplayLabel:SetText(labelText)
  CompletionistsListsWindow_DisplayBox:SetHidden(hideDisplayBox)
  CompletionistsListsWindow_DisplayLabel:SetHidden(hideDisplayBox)
  CompletionistsLists.UpdateWindowResultList()
end

function CompletionistsLists.ChangeDisplay()
  -- reset page number in case of larger to smaller list
  currentPage = 1
  if(showFilter > 1) then
    CompletionistsLists.DebugMsg(0,"Updating filter " .. showFilter)
  else
    CompletionistsLists.DebugMsg(1,labelText .. " " .. showFilter)
    return
  end
  -- reverse option before refreshing lists
  if(displayOption == 0) then
    displayOption = 1
  else
    displayOption = 0
  end
  local labelId = (showFilter * 10) + displayOption
  local labelText = displayText[labelId]
  if(labelText == nil) then
    labelText = "Unhandled Filter"
  end
  -- Which display is changed depends on filter
  if(showFilter == 0) then
    -- not possible to change atm
    CompletionistsLists.DebugMsg(1,labelText .. " " .. showFilter)
  elseif(showFilter == 1) then
    -- not possible to change atm
    CompletionistsLists.DebugMsg(1,labelText .. " " .. showFilter)
  elseif((showFilter == 2) or (showFilter == 3)) then
    -- displayOption 1 is show one page per line
    -- for recipes it means show full
    if(showFilter == 2) then
      CompletionistsLists.ListAllKnownRecipes(idFirstFurnishingRecipyList, idLastFurnishingRecipyList)
    else
      CompletionistsLists.ListAllKnownRecipes(idFirstProvisioningRecipyList, idLastProvisioningRecipyList)
    end
  elseif(showFilter == 4) then
    -- displayOption 1 is show one page per line
    -- for recipes it means show full
    CompletionistsLists.ListAllKnownMotifs()
  elseif(showFilter == 5) then
    CompletionistsLists.ListAllItemSets()
  elseif(showFilter == 6) then
    CompletionistsLists.ExportAchievements()
  else
    CompletionistsLists.DebugMsg(1,labelText .. " " .. showFilter)
  end
  -- update view
  --CompletionistsListsWindow_DisplayBox:ZO_CheckButton_SetCheckState(true)
  CompletionistsListsWindow_DisplayLabel:SetText(labelText)
  CompletionistsLists.UpdateWindowResultList()
end

------ BAG CONTENT FUNCTIONS ------

function CompletionistsLists.ListBags(filterOnlyRecipes) -- list all from bag
  CompletionistsLists.DebugMsg(0,"ShowCompletionistsLists:ListBags")
  CompletionistsLists.ClearResultPages()
  CompletionistsLists.ScanInventoryAndShowResults(filterOnlyRecipes)
end

function CompletionistsLists.ScanInventoryAndShowResults(filterOnlyRecipes)
  CompletionistsLists.DebugMsg(0,"CompletionistsLists.ScanInventoryAndShowResults")
  CompletionistsLists.DebugMsg(0,"starting....")
  local textList, pageIndex = CompletionistsLists.ScanInventoryReturnResult(filterOnlyRecipes)
  for pageNr = 1, pageIndex do
    crResultList[pageNr] = textList[pageNr]
    CompletionistsLists.DebugMsg(0,"Added page to result list: " .. pageNr)
  end
  totalResultPages = pageIndex
  CompletionistsLists.DebugMsg(0,"done, displaying....")
  CompletionistsLists.UpdateWindowResultList()
end

function CompletionistsLists.ScanInventoryReturnResult(filterOnlyRecipes)
  CompletionistsLists.DebugMsg(0,"CompletionistsLists.ScanInventoryReturnResult")
  local pageIndex = 1
  local tText = ""
  local textList = {}
  local itemCnt = 0
  -- reset result id list
  crResultIds = {}
  useLinkNotName = filterOnlyRecipes
  textList[pageIndex] = tText 
  for bag, checkBag in ipairs(bagsToCheck) do
    if(checkBag) then
		  if(bag == BAG_GUILDBANK) then
        local bankName = GetGuildName(GetSelectedGuildBankId())
        CompletionistsLists.DebugMsg(1,"Scan Guild Bank: " .. bankName)
      else
        CompletionistsLists.DebugMsg(1,"Scan Bag Nr: " .. bag)
      end
      local bagCache = SHARED_INVENTORY:GetOrCreateBagCache(bag)
      for _, itemData  in pairs(bagCache) do
        local itemLink
        if(filterOnlyRecipes) then
          itemLink = GetItemLink(itemData.bagId, itemData.slotIndex, LINK_STYLE_BRACKETS)
        else
          itemLink = GetItemLink(itemData.bagId, itemData.slotIndex)
        end
        local itemText, shouldAddTxt = CompletionistsLists.GetItemTxtIfTradeable(itemLink, filterOnlyRecipes)
        if(shouldAddTxt and itemText ~= nil) then
          table.insert(crResultIds, itemLink)
          itemCnt = itemCnt +1
          CompletionistsLists.DebugMsg(0,"Found: " .. itemText)
          tText, pageIndex = CompletionistsLists.GetTextAndNewPageIfNotFit(tText, itemText, pageIndex)
          if(tText ~= nil and pageIndex ~= nil) then
            textList[pageIndex] = tText
          end
        end
      end
    else
        CompletionistsLists.DebugMsg(1,"Skip Bag Nr: " .. bag)
    end
  end
  CompletionistsLists.DebugMsg(1,"Total in list: " .. pageIndex .. " pages, " .. itemCnt .. " items")
  return textList, pageIndex
end

function CompletionistsLists.GetItemTxtIfTradeable(itemLink, onlyTradableRecipes)
  local returnTxt = ""
  local shouldPrint = false
  local donotcheckotherthingsfornow = false
  if(itemLink ~= nil) then 
    if(onlyTradableRecipes) then
    -- make link instead
      local itemType, subType = GetItemLinkItemType(itemLink)
      if (itemType == ITEMTYPE_RECIPE or (itemType == ITEMTYPE_RACIAL_STYLE_MOTIF)) then
      --  returnTxt = GetItemLinkName(GetItemLinkRecipeResultItemLink(itemLink))
      --  shouldPrint = true
      --elseif (itemType == ITEMTYPE_RACIAL_STYLE_MOTIF) then
        returnTxt = itemLink
			  --StartChatInput(returnTxt, CHAT_CHANNEL_PARTY)
        shouldPrint = true
      end
    elseif (donotcheckotherthingsfornow) then
      if (IsItemLinkBound(itemLink) or IsItemLinkReconstructed(itemLink)) then
        CompletionistsLists.DebugMsg(0,itemLink .. " is bound")
      else
        local bindType = GetItemLinkBindType(itemLink)
        if ((bindType == BIND_TYPE_ON_PICKUP_BACKPACK) or (bindType == BIND_TYPE_ON_PICKUP)) then
          CompletionistsLists.DebugMsg(0,itemLink .. " is bound on pickup")
        else
          local itemType, subType = GetItemLinkItemType(itemLink)
          returnTxt = GetItemLinkName(itemLink)
          shouldPrint = true
          if (itemType == ITEMTYPE_TROPHY or itemType == ITEMTYPE_COLLECTIBLE) then
            CompletionistsLists.DebugMsg(0,itemLink .. " is trophy or collectible")
          elseif (itemType == ITEMTYPE_CONTAINER and subType == SPECIALIZED_ITEMTYPE_CONTAINER) then	
            CompletionistsLists.DebugMsg(0,itemLink .. " is container - specialized")
          else
            CompletionistsLists.DebugMsg(0,itemLink .. " is something else")
          end
        end
      end
    else
      local itemType, subType = GetItemLinkItemType(itemLink)
      if (itemType == ITEMTYPE_RECIPE) then
        returnTxt = GetItemLinkName(GetItemLinkRecipeResultItemLink(itemLink))
        shouldPrint = true
      elseif (itemType == ITEMTYPE_RACIAL_STYLE_MOTIF) then
        returnTxt = GetItemLinkName(itemLink)
        shouldPrint = true
      end
    end
  end
  return returnTxt, shouldPrint
end

------ ITEM SET FUNCTIONS ------

function CompletionistsLists.GetHeaderFullSets(displayOption)
  CompletionistsLists.DebugMsg(0,"CompletionistsLists.GetHeaderFullSets")
  local returnTxt = ""
  if (displayOption == 0) then
    returnTxt = "ItemSet;SetType;nrSlots"
    for pageNr = 1, maxItemSetSlots do
      if pageNr < 14 or pageNr > 16 then
        returnTxt = returnTxt .. ";" .. GetString(itemSetSlot[pageNr])
      else
        rreturnTxt = returnTxt .. ";" .. GetString(SI_EQUIPTYPE6)  -- two handed
        returnTxt = returnTxt .. " " .. GetString(itemSetSlot[pageNr])
      end
    end
    returnTxt = returnTxt .. "\r\n"
  else
    returnTxt = "MissingSetItems" .. "\r\n"
  end
  return returnTxt
end  
  
function CompletionistsLists.GetHeaderMosterSets(displayOption)
  CompletionistsLists.DebugMsg(0,"CompletionistsLists.GetHeaderMosterSets")
  local returnTxt = ""
  if (displayOption == 0) then
    returnTxt = "ItemSet;SetType;nrSlots" 
    returnTxt = returnTxt .. ";" .. GetString(SI_ARMORTYPE1) .. " " .. GetString(SI_EQUIPTYPE1)
    returnTxt = returnTxt .. ";" .. GetString(SI_ARMORTYPE2) .. " " .. GetString(SI_EQUIPTYPE1)
    returnTxt = returnTxt .. ";" .. GetString(SI_ARMORTYPE3) .. " " .. GetString(SI_EQUIPTYPE1)
    returnTxt = returnTxt .. ";" .. GetString(SI_ARMORTYPE1) .. " " .. GetString(SI_EQUIPTYPE4)
    returnTxt = returnTxt .. ";" .. GetString(SI_ARMORTYPE2) .. " " .. GetString(SI_EQUIPTYPE4)
    returnTxt = returnTxt .. ";" .. GetString(SI_ARMORTYPE3) .. " " .. GetString(SI_EQUIPTYPE4)
    returnTxt = returnTxt .. "\r\n"
  else
    returnTxt = "MissingMonsterItem" .. "\r\n"
  end
  return returnTxt
end  

function CompletionistsLists.GetHeaderMythicItems(displayOption)
  CompletionistsLists.DebugMsg(0,"CompletionistsLists.GetHeaderMythicItems")
  local returnTxt = ""
  if (displayOption == 0) then
    returnTxt = "ItemSet;SetType;nrSlots;ItemCollected" .. "\r\n"
  else
    returnTxt = "MissingMythicItem" .. "\r\n"   
  end
  return returnTxt
end  

function CompletionistsLists.GetHeaderWeaponSets(displayOption)
  CompletionistsLists.DebugMsg(0,"CompletionistsLists.GetHeaderWeaponSets")
  local returnTxt = ""
  if (displayOption == 0) then
    returnTxt = "ItemSet;SetType;nrSlots;.." .. "\r\n"
  else
    returnTxt = "MissingWeaponSetItem" .. "\r\n"
  end
  return returnTxt
end  

function CompletionistsLists.GetHeaderOtherSets(displayOption)
  CompletionistsLists.DebugMsg(0,"CompletionistsLists.GetHeaderOtherSets")
  local returnTxt = ""
  if (displayOption == 0) then
    returnTxt = "ItemSet;SetType;nrSlots;.." .. "\r\n"
  else
    returnTxt = "MissingSetItems" .. "\r\n"
  end
  return returnTxt
end  


function CompletionistsLists.GetItemSetItemInformation(settypeid, setId, displayOption)
  CompletionistsLists.DebugMsg(0,"CompletionistsLists.GetItemSetItemInformation")
  if(setId == nil or settypeid == nil) then
    return -1, ""
  end
  if(displayOption == nil) then
    displayOption = -1
  end
  local returnTotalNewItems = 0
  local returnAdditionalCollected = 0
  local returnItemInfoText = ""
  local preTextSetLine = ""
  local numItemsInSet = GetNumItemSetCollectionPieces(setId)
  
  if(displayOption == 0) then
    local setName = GetItemSetName(setId)
    if (settypeid == 3 and numItemsInSet == 1) then
      preTextSetLine = preTextSetLine .. setName .. ";Mythic"
    elseif (settypeid == 4) then
      preTextSetLine = preTextSetLine .. setName .. ";" -- rest is filled in on first item
    else
      preTextSetLine = preTextSetLine .. setName .. ";" .. GetString(itemSetType[settypeid]) 
    end
  end
  for index = 1, numItemsInSet do
    returnTotalNewItems = returnTotalNewItems + 1
    
    local pieceId, slot = GetItemSetCollectionPieceInfo(setId, index)
    
    local itemLink = GetItemSetCollectionPieceItemLink(pieceId, LINK_STYLE_DEFAULT, ITEM_TRAIT_TYPE_NONE)
    local isShownOnLimited = false
    local itemType = GetItemLinkItemType(itemLink)
    -- dungeon sets should be checked if to show
    if(itemType ~= nil and settypeid == 2) then
      -- jewelery and weapons should be visible
      local armor_type = GetItemLinkArmorType(itemLink)
      if(armor_type == ARMORTYPE_NONE) then
        isShownOnLimited = true
      end
    elseif(settypeid == 4) then
      -- weaponsets should be shown
      isShownOnLimited = true
    elseif (settypeid == 3 or settypeid == 5) then
    -- world, mythic or monster count as armor for limit display purpose
      isShownOnLimited = false
    end
      
    -- if a weaponset
    if (settypeid == 4 and index == 1) then
      local itemTypeString = ""
      local weaponType = GetItemLinkWeaponType(itemLink)
      if weaponType == WEAPONTYPE_NONE then
        itemTypeString = GetString(itemSetType[settypeid])
      else
        if(numItemsInSet == 5) then
          weaponType = WEAPONTYPE_SWORD
        end
        itemTypeString = GetString(weaponToString[weaponType])
      end
      preTextSetLine = preTextSetLine .. itemTypeString 
    elseif (settypeid == 4 and index == 5) then
      -- weaponset with shield
      -- get weapon type for first in slot, if one-handed check if there is a shield
      preTextSetLine = preTextSetLine .. " & " .. GetString(weaponToString[WEAPONTYPE_SHIELD])
    end
      
    if IsItemSetCollectionPieceUnlocked(pieceId) == true then
      returnAdditionalCollected = returnAdditionalCollected + 1
      if(displayOption == 0) then
        returnItemInfoText = returnItemInfoText .. ";1"
      end
    --if not collected will print
    elseif(isShownOnLimited and displayOption == 1) then
      -- if we are limiting and its an armor dont print anything not esp marked as show
      local itemName = GetItemLinkName(itemLink)
      local trialSetName = trialSetIds[setId]
      if(itemName ~= nil and trialSetName ~= nil) then 
        returnItemInfoText = returnItemInfoText .. itemName .. "\r\n" 
      end
    else
      if(displayOption == 0) then
        returnItemInfoText = returnItemInfoText .. ";0"
      end
    end
  end -- end for each item in set
  if(displayOption == 0) then
    returnItemInfoText = preTextSetLine .. ";" .. numItemsInSet .. returnItemInfoText
    -- extra new line for format   
    returnItemInfoText = returnItemInfoText .. "\r\n"
  end
  return returnTotalNewItems, returnAdditionalCollected, returnItemInfoText
end

function CompletionistsLists.ListAllItemSets()
  CompletionistsLists.DebugMsg(0,"CompletionistsLists.ListAllItemSets")
  CompletionistsLists.ClearResultPages()
  
  local pageIndex = 1
  local tText = ""
  local totalItemSets = 0
  local totalItems = 0
  local totalCollectedItems = 0
  local completedSets = 0
  
  local resultFullSets = {}
  local resultMonsterSets = {}
  local resultMythicItems = {}
  local resultWeaponSets = {}
  local resultOtherSets =  {}
  local pageCntFullSets = 1
  local pageCntMonsterSets = 1
  local pageCntMythicItems = 1
  local pageCntWeaponSets = 1
  local pageCntOtherSets = 1
    
  -- init headers
  resultFullSets[pageCntFullSets] = CompletionistsLists.GetHeaderFullSets(displayOption)
  resultMonsterSets[pageCntMonsterSets] = CompletionistsLists.GetHeaderMosterSets(displayOption)
  resultMythicItems[pageCntMythicItems] = CompletionistsLists.GetHeaderMythicItems(displayOption)
  resultWeaponSets[pageCntWeaponSets] = CompletionistsLists.GetHeaderWeaponSets(displayOption)
  resultOtherSets[pageCntOtherSets] = CompletionistsLists.GetHeaderOtherSets(displayOption)
  
  local setId = GetNextItemSetCollectionId(nil)
  while setId ~= nil do
    totalItemSets = totalItemSets + 1
    local settypeid = GetItemSetType(setId)
    
    local returnTotalNewItems, returnAdditionalCollected, itemTextSetLine = CompletionistsLists.GetItemSetItemInformation(settypeid, setId, displayOption)
    totalItems = totalItems + returnTotalNewItems
    totalCollectedItems = totalCollectedItems + returnAdditionalCollected
        
    if(itemTextSetLine ~= nil) then
      if (settypeid == 2 or settypeid == 3) and (numItemsInSet == 22) then
        local textForList, pageCntFullSets = CompletionistsLists.GetTextAndNewPageIfNotFit(resultFullSets[pageCntFullSets], itemTextSetLine, pageCntFullSets)
        resultFullSets[pageCntFullSets] = textForList
      elseif (settypeid == 3) and (numItemsInSet == 1)  then
        local textForList, pageCntMythicItems = CompletionistsLists.GetTextAndNewPageIfNotFit(resultMythicItems[pageCntMythicItems], itemTextSetLine, pageCntMythicItems)
        resultMythicItems[pageCntMythicItems] = textForList
      elseif (settypeid == 4) then
        local textForList, pageCntWeaponSets = CompletionistsLists.GetTextAndNewPageIfNotFit(resultWeaponSets[pageCntWeaponSets], itemTextSetLine, pageCntWeaponSets)
        resultWeaponSets[pageCntWeaponSets] = textForList
      elseif (settypeid == 5) then
        local textForList, pageCntMonsterSets = CompletionistsLists.GetTextAndNewPageIfNotFit(resultMonsterSets[pageCntMonsterSets], itemTextSetLine, pageCntMonsterSets)
        resultMonsterSets[pageCntMonsterSets] = textForList
      else
        local textForList, pageCntOtherSets = CompletionistsLists.GetTextAndNewPageIfNotFit(resultOtherSets[pageCntOtherSets], itemTextSetLine, pageCntOtherSets)
        resultOtherSets[pageCntOtherSets] = textForList
      end    
    end
    setId = GetNextItemSetCollectionId(setId)
  end -- end while more sets
  
  pageIndex = CompletionistsLists.AddToResultListAndReturnLastEmptyPage(resultFullSets, pageCntFullSets, pageIndex)
  pageIndex = CompletionistsLists.AddToResultListAndReturnLastEmptyPage(resultOtherSets, pageCntOtherSets, pageIndex)
  pageIndex = CompletionistsLists.AddToResultListAndReturnLastEmptyPage(resultWeaponSets, pageCntWeaponSets, pageIndex)
  if(displayOption == 0) then
    pageIndex = CompletionistsLists.AddToResultListAndReturnLastEmptyPage(resultMonsterSets, pageCntMonsterSets, pageIndex)
    pageIndex = CompletionistsLists.AddToResultListAndReturnLastEmptyPage(resultMythicItems, pageCntMythicItems, pageIndex)
  end
  CompletionistsLists.DebugMsg(1,"Total Items Known: " .. totalCollectedItems .. "/" .. totalItems)
  CompletionistsLists.DebugMsg(0,"Total Item Set Pages " .. totalResultPages)
end

------ KNOWN MOTIF FUNCTIONS ------
function CompletionistsLists.GetMotifHeader(displayOption)
  local tText = ""
  if (displayOption == 0) then
    tText = tText .. "Motif"
    for pageNr = 1, maxMotifPageNumbers do
      tText = tText .. ";" .. GetString(motifPageText[pageNr])
    end
      tText = tText .. ";" .. "KnownPagesInMotif"
  else
    tText = tText .. "Motif;Page"
  end
  return tText
end

function CompletionistsLists.GetMotifSetInfo(motif_id, maxMotifPageNumbers, displayOption)
  local knownPagesInMotif = 0
  local totalMotifs = 0
  local knownMotifs = 0
  local motif_name = GetItemStyleName(motif_id)
  local motifTxt = ""
  if motif_name and motif_name ~= "" then
    CompletionistsLists.DebugMsg(0,"Found motif " .. motif_name)
    for pageNr = 1, maxMotifPageNumbers do
      totalMotifs = totalMotifs + 1
      if (displayOption == 0 and pageNr == 1) then
        motifTxt = motifTxt .. motif_name
      end
      if LibMotif.IsKnown(motif_id, pageNr) then
        knownPagesInMotif = knownPagesInMotif + 1
        knownMotifs = knownMotifs + 1
        CompletionistsLists.DebugMsg(0,"Found " .. motif_name .. ";".. GetString(motifPageText[pageNr]))
        if (displayOption == 1) then
          motifTxt = motifTxt .. motif_name .. ";" .. GetString(motifPageText[pageNr]) .. "\r\n"
        else
          motifTxt = motifTxt .. ";1"
        end
      elseif (displayOption == 0) then
        motifTxt = motifTxt .. ";0"
      end
      if (displayOption == 0 and pageNr == maxMotifPageNumbers) then
        motifTxt = motifTxt .. ";" .. knownPagesInMotif
      end
    end
  end
  return motifTxt, totalMotifs, knownMotifs
end
 
function CompletionistsLists.ListAllKnownMotifs()
  CompletionistsLists.DebugMsg(0,"CompletionistsLists.ListAllKnownMotifs")
  CompletionistsLists.ClearResultPages()
  local resultTxtList = {}
  local pageCntList = 1
  local pageIndex = 1
  local totalMotifs = 0
  local knownMotifs = 0
  resultTxtList[pageCntList] = CompletionistsLists.GetMotifHeader(displayOption)
  local max_motif_id  = GetHighestItemStyleId()
  for motif_id = 1, max_motif_id do
    local motifTxt, additionalTotalMotifs, additionalKnownMotifs = CompletionistsLists.GetMotifSetInfo(motif_id, maxMotifPageNumbers, displayOption)
    totalMotifs = totalMotifs + additionalTotalMotifs
    knownMotifs = knownMotifs + additionalKnownMotifs
    local textForList, pageCntList = CompletionistsLists.GetTextAndNewPageIfNotFit(resultTxtList[pageCntList], motifTxt, pageCntList)
    resultTxtList[pageCntList] = textForList
  end
  pageIndex = CompletionistsLists.AddToResultListAndReturnLastEmptyPage(resultTxtList, pageCntList, pageIndex)
  CompletionistsLists.DebugMsg(1,"Total Known Motif Pages: " .. knownMotifs .. "/" .. totalMotifs)
  CompletionistsLists.DebugMsg(0,"Total Motif Pages " .. totalResultPages)
end

------ KNOWN RECIPE FUNCTIONS ------

function CompletionistsLists.ListAllKnownRecipes(startIndex, endIndex)
  CompletionistsLists.DebugMsg(0,"ListAllKnownRecipes")
  local pageIndex = 1
  local tText = ""
  local totalRecipes = 0
  local knownRecipes = 0
  if crResultList[pageIndex] == nil then 
    CompletionistsLists.DebugMsg(0,"init list with no text")
    crResultList[pageIndex] = tText 
  elseif string.len(tText) > 0 then
    tText = tText .. "\r\n"
  end
  tText = tText .. "Recipe Name;Category;Quality"
  for recipeListIndex = startIndex, endIndex do -- populate the recipe list index
    local recipeListName, numRecipes = GetRecipeListInfo(recipeListIndex)
    totalRecipes = totalRecipes + numRecipes
    CompletionistsLists.DebugMsg(0,"There are " .. numRecipes .. " recipes in list " .. recipeListName)
    local knownListRecipies = 0
    for recipeIndex = 1, numRecipes do
      local known, recipeName = GetRecipeInfo(recipeListIndex, recipeIndex) -- this returns the name even if you don't know the recipe
      if recipeName ~= "" and known then -- only process known recipes
				local itemText = recipeName
        knownRecipes = knownRecipes + 1
        knownListRecipies = knownListRecipies + 1
				
        if (displayOption == 0) then
          local itemLink = GetRecipeResultItemLink(recipeListIndex, recipeIndex) -- NOTE: this returns "" for recipes you don't know!
          local itemLinkQuality = GetItemLinkQuality(itemLink)
          local recipyQuality = (qualityText[itemLinkQuality] ~= nil) and qualityText[itemLinkQuality].color or ""
          itemText = itemText .. ";" .. recipeListName .. ";" .. recipyQuality
          local craftingSkillName = "Station Unknown"
		      local linkStationType = GetItemLinkRecipeCraftingSkillType(itemLink)
          if (linkStationType ~= CRAFTING_TYPE_INVALID) then
              craftingSkillName = GetCraftingSkillName(linkStationType)
              itemText = itemText .. ";" .. craftingSkillName
          end    
        end
        CompletionistsLists.DebugMsg(0,"Found " .. itemText)

        if string.len(tText) > maxTxtLength then
          CompletionistsLists.DebugMsg(0,"Increase total pages.. ")
          pageIndex = pageIndex + 1   
          tText = ""
        elseif string.len(tText) >0 then
          CompletionistsLists.DebugMsg(0,"Add to existing list.. ")
          itemText = "\r\n" .. itemText 
        end
        tText = tText .. itemText
        crResultList[pageIndex] = tText  
      end
    end
    CompletionistsLists.DebugMsg(1,recipeListName .. ": " .. knownListRecipies .. "/" .. numRecipes)
  end
  totalResultPages = pageIndex
  CompletionistsLists.DebugMsg(1,"Total Recipies: " .. knownRecipes .. "/" .. totalRecipes)
  CompletionistsLists.DebugMsg(0,"Total Recipies Pages " .. totalResultPages)
end -- Function

------ LIST ALL IN GAME STUFF FUNCTIONS ------

function CompletionistsLists.ListAllGameRecipesAndMotifs()
  CompletionistsLists.DebugMsg(0,"ListAllGameRecipesAndMotifs")
  local pageIndex = 1
  local tText = ""
  local totalRecipes = 0
  if crResultList[pageIndex] == nil then 
    CompletionistsLists.DebugMsg(0,"init list with no text")
    crResultList[pageIndex] = tText 
  elseif string.len(tText) > 0 then
    tText = tText .. "\r\n"
  end
  tText = tText .. "Type;Name;Category"
  for recipeListIndex = 1, GetNumRecipeLists() do -- populate the recipe list index
    local recipeListName, numRecipes = GetRecipeListInfo(recipeListIndex)
    totalRecipes = totalRecipes + numRecipes
    CompletionistsLists.DebugMsg(0,"There are " .. numRecipes .. " recipes in list " .. recipeListName)
    for recipeIndex = 1, numRecipes do
      local known, recipeName = GetRecipeInfo(recipeListIndex, recipeIndex) -- this returns the name even if you don't know the recipe
      if recipeName ~= "" then
        local itemText = GetString(recipyListIdsToCategory[recipeListIndex]) .. ";" .. recipeName .. ";" .. recipeListName
        CompletionistsLists.DebugMsg(0,"Found " .. itemText)
        if string.len(tText) > maxTxtLength then
          CompletionistsLists.DebugMsg(0,"Increase total pages.. ")
          pageIndex = pageIndex + 1   
          tText = ""
        elseif string.len(tText) >0 then
          CompletionistsLists.DebugMsg(0,"Add to existing list.. ")
          itemText = "\r\n" .. itemText 
        end
        tText = tText .. itemText
        crResultList[pageIndex] = tText  
      end
    end
  end
  local totalMotifs = 0
  local max_motif_id  = GetHighestItemStyleId()
  for motif_id = 1, max_motif_id do
    local motif_name = GetItemStyleName(motif_id)
    if motif_name and motif_name ~= "" then
      totalMotifs = totalMotifs + 1
      local itemText = "Motif;" .. motif_name
      CompletionistsLists.DebugMsg(0,"Found motif " .. itemText)
      if string.len(tText) > maxTxtLength then
        CompletionistsLists.DebugMsg(0,"Increase total pages.. ")
        pageIndex = pageIndex + 1   
        tText = ""
      elseif string.len(tText) > 0 then
        CompletionistsLists.DebugMsg(0,"Add to existing list.. ")
        itemText = "\r\n" .. itemText 
      end
      tText = tText .. itemText
      crResultList[pageIndex] = tText  
    end
  end
  totalResultPages = pageIndex
  CompletionistsLists.DebugMsg(1,"Total Recipies: " .. totalRecipes)
  CompletionistsLists.DebugMsg(1,"Total Motifs: " .. totalMotifs)
  CompletionistsLists.DebugMsg(0,"Total Result Pages " .. totalResultPages)
end -- Function

------ LIST ANTIQUITIES FUNCTIONS ------

function CompletionistsLists.ListAllAntiquities()
  local pageIndex = 1
  local tText = ""
  local totalAntiquities = 0
  local foundAntiquities = 0
  --local discoveredCodex = 0
  if crResultList[pageIndex] == nil then 
    CompletionistsLists.DebugMsg(0,"init list with no text")
    crResultList[pageIndex] = tText 
  elseif string.len(tText) > 0 then
    tText = tText .. "\r\n"
  end
  tText = tText .. "AntiquityName;ZoneName;Set"
  tText = tText .. ";IsRepeatable"
  tText = tText .. ";Difficulty;antiquityQuality"
  tText = tText .. ";totalLoreEntries;unlockedLoreEntries;NumRecovered;HaveLead"
  local antiquityDataId = GetNextAntiquityId()
  while antiquityDataId do
    totalAntiquities = totalAntiquities + 1
    local itemText = ""
    local antiquityName = GetAntiquityName(antiquityDataId)
    local zoneName = LibZone:GetZoneName(GetAntiquityZoneId(antiquityDataId))
    local setId = GetAntiquitySetId(antiquityDataId)
    local setName = ZO_CachedStrFormat("<<C:1>>", GetAntiquitySetName(setId))
    local rewardId = GetAntiquityRewardId(antiquityDataId)
    if (setName == "" and rewardId > 0)  then
      setName = REWARDS_MANAGER:GetRewardContextualTypeString(rewardId)
    end
    itemText = itemText .. antiquityName .. ";" .. zoneName  .. ";" .. setName 
    local isRepeatableString = "0"
    if IsAntiquityRepeatable(antiquityDataId) then
      isRepeatableString = "1"
    end
    itemText = itemText .. ";" .. isRepeatableString
    local antiquityDifficulty = GetAntiquityDifficulty(antiquityDataId)
    local antiquityQuality = GetAntiquityQuality(antiquityDataId)
    itemText = itemText .. ";" .. antiquityDifficulty .. ";" .. antiquityQuality 
    local totalLoreEntries = GetNumAntiquityLoreEntries(antiquityDataId)
    local unlockedLoreEntries = GetNumAntiquityLoreEntriesAcquired(antiquityDataId) 
    itemText = itemText .. ";" .. totalLoreEntries .. ";" .. unlockedLoreEntries
    local numRecovered = GetNumAntiquitiesRecovered(antiquityDataId)
    if (numRecovered > 0) then
      foundAntiquities = foundAntiquities + 1
    end
    local antiquityHasLead = "0"
    if DoesAntiquityHaveLead(antiquityDataId) then
      antiquityHasLead = "1"
    end
    itemText = itemText .. ";" .. numRecovered .. ";" .. antiquityHasLead  
  
    if string.len(tText) > maxTxtLength then
      CompletionistsLists.DebugMsg(0,"Increase total pages.. ")
      pageIndex = pageIndex + 1   
      tText = ""
    elseif string.len(tText) > 0 then
      CompletionistsLists.DebugMsg(0,"Add to existing list.. ")
      itemText = "\r\n" .. itemText 
    end
    tText = tText .. itemText
    crResultList[pageIndex] = tText  
    antiquityDataId = GetNextAntiquityId(antiquityDataId)
  end
  totalResultPages = pageIndex
  CompletionistsLists.DebugMsg(1,"Total Found Antiquities: " .. foundAntiquities .. "/" .. totalAntiquities)
  CompletionistsLists.DebugMsg(0,"Total Antiquities Pages " .. totalResultPages)
end

------ WIP - ACHIEVEMENTS FUNCTIONS ------

function CompletionistsLists.ListAllAchievements()
  if IsAchievementComplete(achievementId) and GetNextAchievementInLine(achievementId) ~= 0 then
      -- AchievementLine is present and everything is done.
  elseif IsAchievementComplete(achievementId) and GetNextAchievementInLine(achievementId) ~= 0 and not IsAchievementComplete(GetNextAchievementInLine(achievementId)) then
      -- Achievement is done but next is not.
  elseif not IsAchievementComplete(achievementId) and GetNextAchievementInLine(achievementId) ~= 0 and IsAchievementComplete(GetNextAchievementInLine(achievementId)) then
      -- Achievement is not done but previous is.
  else
      -- Standard
  end
end


function CompletionistsLists.GetAchievementRewards(achievementId)
  local tText = ""
  -- CollectibleId;
  local hasCollectableReward, collectibleId = GetAchievementRewardCollectible(achievementId)
  if(hasCollectableReward) then
    local collectibleData = ZO_COLLECTIBLE_DATA_MANAGER:GetCollectibleDataById(collectibleId)
    tText = tText .. ";" .. collectibleData:GetFormattedName()
  else
    tText = tText .. ";0"
  end
  -- dyeId;
  local hasDyeReward, dyeId = GetAchievementRewardDye(achievementId)
  if(hasDyeReward) then
    local dyeName, known, rarity, hueCategory, dyeAchievementId, r, g, b = GetDyeInfoById(dyeId)
    tText = tText .. ";" .. dyeName
  else
    tText = tText .. ";0"
  end
  -- itemName;
  local hasItemReward, itemName, iconTextureName, displayQuality = GetAchievementRewardItem(achievementId)
  if(hasItemReward) then
    tText = tText .. ";" .. itemName
  else
    tText = tText .. ";0"
  end
  -- titleName;
  local hasTitleReward, addText = GetAchievementRewardTitle(achievementId)
  if(hasTitleReward) then
    tText = tText .. ";" .. addText
  else
    tText = tText .. ";0"
  end  
  return tText
end

function CompletionistsLists.GetAchievementString(categoryIndex, subCategoryIndex, achievementId)
  local itemText = ""
  local name, description, points, icon, completed, date, time = GetAchievementInfo(achievementId)
  if(displayOption == 0) then
  -- full string
    itemText = itemText .. categoryIndex .. ";" .. subCategoryIndex .. ";" .. achievementId .. ";" .. name .. ";" .. description 
    if(GetAchievementNumRewards(achievementId) > 1) then
      local achievementText = CompletionistsLists.GetAchievementRewards(achievementId)
      itemText = itemText .. ";hasReward" .. achievementText
    else
      itemText = itemText .. ";noReward"
    end
  else
  -- List earned
    if completed then
      itemText = name
    end
  end
  return itemText
end

function CompletionistsLists.ExportAchievements()
  local pageIndex = 1
  local tText = ""
  --local discoveredCodex = 0
  if crResultList[pageIndex] == nil then 
    CompletionistsLists.DebugMsg(0,"init list with no text")
    crResultList[pageIndex] = tText 
  elseif string.len(tText) > 0 then
    tText = tText .. "\r\n"
  end
  -- displayOption 1 only the earned achievements are listed
  if(displayOption == 0) then
    tText = tText .. "categoryIndex;subCategoryIndex;achievementId;name;description;reward;CollectibleId;dyeId;itemName;titleName" .. "\r\n"
  else
    tText = tText .. "name"
  end
  for categoryIndex = 1, GetNumAchievementCategories() do
    local _, numSubCategories, numAchievements = GetAchievementCategoryInfo(categoryIndex)
    for i = 1, numAchievements do
      local achievementId = GetAchievementId(categoryIndex, nil, i)
      local itemText = CompletionistsLists.GetAchievementString(categoryIndex, 0, achievementId)
      if (itemText ~= "") then
        pageIndex, tText = CompletionistsLists.GetUpdatedText(pageIndex, tText, itemText)  
      end
      crResultList[pageIndex] = tText
    end
    for subCategoryIndex = 1, numSubCategories do
      local _, subNumAchievements = GetAchievementSubCategoryInfo(categoryIndex, subCategoryIndex)
      for i = 1, subNumAchievements do
        local achievementId = GetAchievementId(categoryIndex, subCategoryIndex, i)
        local itemText = CompletionistsLists.GetAchievementString(categoryIndex, subCategoryIndex, achievementId)
        if (itemText ~= "") then
          pageIndex, tText = CompletionistsLists.GetUpdatedText(pageIndex, tText, itemText)
        end
        crResultList[pageIndex] = tText  
      end
    end
  end
  totalResultPages = pageIndex
  CompletionistsLists.DebugMsg(0,"Total Achievement Pages " .. totalResultPages)
end

------ WIP - OTHER FUNCTIONS ------

function CompletionistsLists.ExportToSavedVariables(exportMode) -- Show the data export GUI.
  CompletionistsLists.DebugMsg(0,"ExportToSavedVariables")

  if (exportMode == nil) then
    exportMode = "character"
  end
  
  if (exportMode == "full") then 
    CompletionistsLists.DebugMsg(1,"Export all recipies in game")
    CompletionistsLists.exportedToSaved = ZO_SavedVars:NewAccountWide("CompletionistsListsExport", 2, "Export", {}, GetWorldName())
    CompletionistsLists.ListAllGameRecipesAndMotifs()
    if (crResultList[1] == nil) then
      CompletionistsLists.DebugMsg(1,"Nothing to export")
    else
      local exportText = ""      
      for currPage = 1, totalResultPages do
        exportText = exportText .. crResultList[currPage]
      end
      CompletionistsLists.exportedToSaved.onehugelist = exportText
    end
    --CompletionistsLists.exportedToSaved.motifsingame = "these are 1"
    --CompletionistsLists.exportedToSaved.provisioningingame = "these are 1"
    --CompletionistsLists.exportedToSaved.furnitureingame = "these are 1"
  else
    CompletionistsLists.DebugMsg(1,"Export all known recipes and motifs")
    CompletionistsLists.exportedToSaved = ZO_SavedVars:NewCharacterNameSettings("CompletionistsListsExport", 2, "Export", {}, GetWorldName())
    CompletionistsLists.ListAllKnownMotifs()
    if (crResultList[1] == nil) then
      CompletionistsLists.DebugMsg(1,"Nothing to export")
    else
      local exportText = ""      
      for currPage = 1, totalResultPages do
        exportText = exportText .. crResultList[currPage]
      end
      CompletionistsLists.exportedToSaved.knownmotifs = exportText
    end
    CompletionistsLists.ListAllKnownRecipes(idFirstProvisioningRecipyList, idLastProvisioningRecipyList)
    if (crResultList[1] == nil) then
      CompletionistsLists.DebugMsg(1,"Nothing to export")
    else
      local exportText = ""      
      for currPage = 1, totalResultPages do
        exportText = exportText .. crResultList[currPage]
      end
      CompletionistsLists.exportedToSaved.knownprovisioning = exportText
    end
    CompletionistsLists.ListAllKnownRecipes(idFirstFurnishingRecipyList, idLastFurnishingRecipyList)
    if (crResultList[1] == nil) then
      CompletionistsLists.DebugMsg(1,"Nothing to export")
    else
      local exportText = ""      
      for currPage = 1, totalResultPages do
        exportText = exportText .. crResultList[currPage]
      end
      CompletionistsLists.exportedToSaved.knownfurniture = exportText
    end
  end
  
  GetAddOnManager():RequestAddOnSavedVariablesPrioritySave(CompletionistsLists.name)
end


function CompletionistsLists.SpaceOnCurrentPage(requiredSpace)
  local returnValue = maxTxtLength
  local latestPage = totalResultPages
  CHAT_ROUTER:AddSystemMessage("Total Result Pages before check " .. totalResultPages)
  if crResultList[latestPage] ~= nil then
    if(maxTxtLength-string.len(crResultList[latestPage]) > requiredSpace) then
      returnValue = maxTxtLength-string.len(crResultList[latestPage])
      CHAT_ROUTER:AddSystemMessage("Total Result Pages, space so no add " .. latestPage)
    else
      -- if there is no space on current page, advance by one
      latestPage = latestPage + 1
      crResultList[latestPage] = ""
      CHAT_ROUTER:AddSystemMessage("Total Result Pages, after add " .. latestPage)
    end
  else
    crResultList[latestPage] = ""
    CHAT_ROUTER:AddSystemMessage("Total Result Pages, empty so no add " .. latestPage)
  end
  totalResultPages = latestPage
  return latestPage, crResultList[latestPage], returnValue
end -- Function

function CompletionistsLists.AddTextToResultPageAndReturnLeftover(tText)
  if tText == nil then
    return
  elseif(string.len(tText) == 0) then
    return
  end
  local availableSpace = 999 --CompletionistsLists.SpaceOnCurrentPage(string.len(tText))
  if (string.len(tText) > availableSpace) then
    crResultList[totalResultPages] = crResultList[totalResultPages] .. string.sub(tText, 1, availableSpace)
    return string.sub(tText,availableSpace+1,string.len(tText))
  else
    crResultList[totalResultPages] = crResultList[totalResultPages] .. tText 
  end
  return ""
end -- Function


------ ALWAYS AT THE END FUNCTIONS ------

-- Finally, we'll register our event handler function to be called when the proper event occurs.
EVENT_MANAGER:RegisterForEvent(CompletionistsLists.name, EVENT_ADD_ON_LOADED, CompletionistsLists.OnAddOnLoaded)
