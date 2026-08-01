-------------------------------------------------------------------------------------------------------------------------------------------------
-- Update instructions
-------------------------------------------------------------------------------------------------------------------------------------------------
-- To update this AddOn manually (when a new zone is released) do the following:
-- 1. Add variable <zone_name>TC = 0 to ChestFarmer.Default for defaulting savedVariables
-- 2. Check LibSets' xlsx file to get ParentZoneId and overland setIds for the zone's sets. 
-- 2.1 Check if any delve, public dungeon or house has a different parentZoneId. This can be found in the "ESO Zone constants" tab.
-- 2.2 Add an entry to the table in ChestFarmer.cfReadZone() in the following format:
----- --"Zone-Name" as comment
----- [parentZoneId] = {actual_parentZoneId, ChestFarmer.savedVariables.<zone_name>TC, {setId1, setId2, setId3 etc.}}
--------------------------------------------------------------------------------------- ^ these setIds are the ones for the zone's overland sets.
----- if step 2.1 is true, then add the house/quest area as a separate [parentZoneId] with the actual values
----- To understand this, check Linchal Grand Manor for example, although it is situated in the Gold Coast, it has its own parentZoneId.
----- For our purposes we need to load the parentZoneId for Gold Coast and the associated TC from savedVariables and the correct setIds.
-- 3. Add an entry to ChestFarmer.cfWrite() in the following format:
-- 	  elseif tempParentZoneId == (parentZoneId for the zone you got from libSets) then
--    ChestFarmer.savedVariables.<zone_name>TC = tempTc
--    No need to include houses here (if their parentZoneId is different) as this function is only called after a lockpick success event.
-- 4. Add an entry to statsButtonPressed() in the line for k,v in pairs...
-- add <zone_name>TC to the parameter list of this for loop

-----------------------
-- ChestFarmer
-----------------------

--Variables

ChestFarmer = {}
ChestFarmer.name = "ChestFarmer"
ChestFarmer.versionNum = 1
ChestFarmer.numChests = 0
ChestFarmer.numLockpicks = 0
--Defaults
ChestFarmer.Default = {
guiHidden = false,
top = 614,
left = 1650,
starterTC = 0,
deshaanTC = 0, 
eastmarchTC = 0, 
shadowfenTC = 0, 
stonefallsTC = 0, 
theriftTC = 0, 
alikrdesertTC = 0, 
bangkoraiTC = 0, 
glenumbraTC = 0, 
rivenspireTC = 0, 
stormhavenTC = 0, 
auridonTC = 0, 
grahtwoodTC = 0, 
greenshadeTC = 0, 
malabaltorTC = 0, 
reapersmarchTC = 0, 
summersetTC = 0, 
wSkyrimTC = 0, 
clockworkTC = 0, 
coldharbourTC = 0, 
craglornTC = 0, 
goldcoastTC = 0, 
hewsbaneTC = 0, 
murkmireTC = 0, 
nElsweyrTC = 0, 
sElsweyrTC = 0, 
thereachTC = 0, 
vvardenfellTC = 0, 
wrothgarTC = 0, 
blackwoodTC = 0,
deadlandsTC = 0,
highisleTC = 0,
galenTC = 0,
necromTC = 0,
westwealdTC = 0,
solsticeTC = 0,
cyrodiilTC = 0,
impcityTC = 0,
unknownZoneTC = 0,
masterCount = 0,
advancedCount = 0,
intermediateCount = 0,
simpleCount = 0,
}

--Init functions

function ChestFarmer.onAddonLoaded(event, addonName)
	if addonName == ChestFarmer.name then
		ChestFarmer.Initialize()
		ChestFarmer.SetScene()
		ChestFarmer.AddMenuBind()
		EVENT_MANAGER:UnregisterForEvent(ChestFarmer.name, EVENT_ADD_ON_LOADED)
	end
end

function ChestFarmer.Initialize()
	ChestFarmer.savedVariables = ZO_SavedVars:NewAccountWide("ChestFarmerSavedData", 1, nil, ChestFarmer.Default, GetWorldName())	
	ChestFarmer.RestorePosition()
	ZO_PreHook(SYSTEMS:GetObject("loot"), "UpdateLootWindow", ChestFarmer.hookCheck)
end

function ChestFarmer.SetScene()
	fragment = ZO_HUDFadeSceneFragment:New(ChestFarmerWindow, nil, 0)
	
	if ChestFarmer.savedVariables.guiHidden == false then
		HUD_SCENE:AddFragment(fragment)
		HUD_UI_SCENE:AddFragment(fragment)
	end
end

function ChestFarmer.hookCheck(loot, name, actionName, isOwned)
	local itemIds = {
		178470 -- id for Hidden Treasure Bag
	}
	local itemNames = {}
	for _,itemId in ipairs(itemIds) do
		itemNames[zo_strformat(SI_TOOLTIP_ITEM_NAME, GetItemLinkName(string.format("|H1:item:%d:0:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:1:0:0:0|h|h", itemId)))] = true
	end
	
	if (itemNames[name] == true) and (running == true) then return true
	else return false
	end
end

function ChestFarmer.IsItemMirriBox(bagId, slotIndex)
	if bagId ~= BAG_BACKPACK then
		return false
	end
	local itemId = GetItemId(bagId, slotIndex)
	if itemId == 178470 then
		return true
	else
		return false
	end
end

function ChestFarmer.lootContainer()
	lastScene = SCENE_MANAGER:GetCurrentScene():GetName()
	if lastScene == "interact" then
		LootAll()
		lastScene = "hudui"
	end
	LootAll()
	running = false
	EVENT_MANAGER:UnregisterForEvent(ChestFarmer.name, EVENT_LOOT_UPDATED)
end

function ChestFarmer.OpenABox(bag, slot)
	running = true
	EVENT_MANAGER:RegisterForEvent(ChestFarmer.name, EVENT_LOOT_UPDATED, ChestFarmer.lootContainer)
	EVENT_MANAGER:UnregisterForUpdate("openBoxRecursive")
	
	if IsProtectedFunction("UseItem") then
		CallSecureProtected("UseItem", bag, slot)
	else
		UseItem(bag, slot)
	end
			
	EVENT_MANAGER:RegisterForUpdate("openContainersRecursive", remaining+17, ChestFarmer.OpenContainers)
end

function ChestFarmer.OpenContainers()
	
	EVENT_MANAGER:UnregisterForUpdate("openContainersRecursive")
	local inventoryCount = GetBagSize(INVENTORY_BACKPACK)
	for x = 0, inventoryCount do
		if (IsUnitInCombat("player")) or IsUnitDead("player") then
			ZO_CreateStringId("SI_COMBAT_ERROR", "You cannot open boxes while in combat.")
			ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NEGATIVE_CLICK, SI_COMBAT_ERROR)
			break
		end
		if (not CheckInventorySpaceSilently(4)) then
			ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NEGATIVE_CLICK, SI_INVENTORY_ERROR_INVENTORY_FULL)
			break
		end
		local link = GetItemLink(INVENTORY_BACKPACK, x)
		local itemId = GetItemLinkItemId(link)
		if itemId == 178470 then
			remaining = GetItemCooldownInfo(INVENTORY_BACKPACK,x)
			if remaining > 0 then
				EVENT_MANAGER:RegisterForUpdate("openBoxRecursive", remaining+17, function() ChestFarmer.OpenABox(INVENTORY_BACKPACK,x) end)
			else
				ChestFarmer.OpenABox(INVENTORY_BACKPACK,x)
			end
		end
	end
end

function ChestFarmer.AddMenuBind()
	if not LibCustomMenu then return end
	ZO_CreateStringId("SI_BINDING_NAME_OPEN_MIRRI_BOXES", "Open All Mirri Boxes")
	local function AddItem(inventorySlot, slotActions)
		local bagId, slotIndex = ZO_Inventory_GetBagAndIndex(inventorySlot)
		if ChestFarmer.IsItemMirriBox(bagId, slotIndex) and CheckInventorySpaceSilently(4) and (not IsUnitDead("player")) then
			slotActions:AddCustomSlotAction(SI_BINDING_NAME_OPEN_MIRRI_BOXES, function(...)
				return ChestFarmer.OpenContainers(bagId, slotIndex)
			end , "")
		end
	end
	LibCustomMenu:RegisterContextMenu(AddItem, LibCustomMenu.CATEGORY_PRIMARY)
end
 

--UI functions

function ChestFarmer.OnIndicatorMoveStop()
	ChestFarmer.savedVariables.left = ChestFarmerWindow:GetLeft()
	ChestFarmer.savedVariables.top = ChestFarmerWindow:GetTop()
end

function ChestFarmer.RestorePosition()
	local left = ChestFarmer.savedVariables.left
	local top = ChestFarmer.savedVariables.top
	ChestFarmerWindow:ClearAnchors()
	ChestFarmerWindow:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
end

function ChestFarmer.resetButtonPressed()
	ChestFarmer.numChests = 0
	ChestFarmer.cfWrite(ChestFarmer.numChests)
	ChestFarmer.numLockpicks = GetNumLockpicksLeft("player")
	ChestFarmerWindowLockpicksCount:SetText(ChestFarmer.numLockpicks .. " lockpicks remaining")
	ChestFarmerWindowChestsCount:SetText(ChestFarmer.numChests .. " chests opened") 
end

function ChestFarmer.statsButtonPressed()
	totalTC = 0
	sampleSize = ChestFarmer.savedVariables.masterCount + ChestFarmer.savedVariables.advancedCount + ChestFarmer.savedVariables.intermediateCount + ChestFarmer.savedVariables.simpleCount
		for k,v in pairs{ChestFarmer.savedVariables.starterTC, ChestFarmer.savedVariables.deshaanTC, ChestFarmer.savedVariables.eastmarchTC, ChestFarmer.savedVariables.shadowfenTC, ChestFarmer.savedVariables.stonefallsTC, ChestFarmer.savedVariables.theriftTC, ChestFarmer.savedVariables.alikrdesertTC, ChestFarmer.savedVariables.bangkoraiTC, ChestFarmer.savedVariables.glenumbraTC, ChestFarmer.savedVariables.rivenspireTC, ChestFarmer.savedVariables.stormhavenTC, ChestFarmer.savedVariables.auridonTC, ChestFarmer.savedVariables.grahtwoodTC, ChestFarmer.savedVariables.greenshadeTC, ChestFarmer.savedVariables.malabaltorTC, ChestFarmer.savedVariables.reapersmarchTC, ChestFarmer.savedVariables.summersetTC, ChestFarmer.savedVariables.wSkyrimTC, ChestFarmer.savedVariables.clockworkTC, ChestFarmer.savedVariables.coldharbourTC, ChestFarmer.savedVariables.craglornTC, ChestFarmer.savedVariables.goldcoastTC, ChestFarmer.savedVariables.hewsbaneTC, ChestFarmer.savedVariables.murkmireTC, ChestFarmer.savedVariables.nElsweyrTC, ChestFarmer.savedVariables.sElsweyrTC, ChestFarmer.savedVariables.thereachTC, ChestFarmer.savedVariables.vvardenfellTC, ChestFarmer.savedVariables.wrothgarTC, ChestFarmer.savedVariables.blackwoodTC, ChestFarmer.savedVariables.deadlandsTC, ChestFarmer.savedVariables.highisleTC, ChestFarmer.savedVariables.galenTC, ChestFarmer.savedVariables.necromTC, ChestFarmer.savedVariables.westwealdTC, ChestFarmer.savedVariables.solsticeTC, ChestFarmer.savedVariables.cyrodiilTC, ChestFarmer.savedVariables.impcityTC, ChestFarmer.savedVariables.unknownZoneTC} do
			if v ~= nil then
				totalTC = totalTC + v
			end
		end
		CHAT_ROUTER:AddSystemMessage("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
		CHAT_ROUTER:AddSystemMessage("                 CHESTFARMER STATS")
		CHAT_ROUTER:AddSystemMessage("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
		CHAT_ROUTER:AddSystemMessage("Total chests opened, in all zones: " .. totalTC)
		CHAT_ROUTER:AddSystemMessage("Average chest quality: (Sample size " .. sampleSize .. ")")
		if sampleSize ~= 0 then
			CHAT_ROUTER:AddSystemMessage("Master: " .. string.format("%.2f",(ChestFarmer.savedVariables.masterCount/sampleSize)*100) .. "%")
			CHAT_ROUTER:AddSystemMessage("Advanced: " .. string.format("%.2f",(ChestFarmer.savedVariables.advancedCount/sampleSize)*100) .. "%")
			CHAT_ROUTER:AddSystemMessage("Intermediate: " .. string.format("%.2f",(ChestFarmer.savedVariables.intermediateCount/sampleSize)*100) .. "%")
			CHAT_ROUTER:AddSystemMessage("Simple: " .. string.format("%.2f",(ChestFarmer.savedVariables.simpleCount/sampleSize)*100) .. "%")
		else 
			CHAT_ROUTER:AddSystemMessage("Open more chests to populate the sample size!")
		end
end

function ChestFarmer.openCollections()
	SCENE_MANAGER:Toggle("itemSetsBook")
end

function ChestFarmer.showStats_showTooltip(self)
	InitializeTooltip(InformationTooltip, self, TOPRIGHT, 0, 5, BOTTOMRIGHT)
	SetTooltipText(InformationTooltip, "Print historical stats to chat")
end

function ChestFarmer.chestsReset_showTooltip(self)
	InitializeTooltip(InformationTooltip, self, TOPRIGHT, 0, 5, BOTTOMRIGHT)
	SetTooltipText(InformationTooltip, "Reset chest count in current zone")
end

function ChestFarmer.setsCount_showTooltip(self)
	InitializeTooltip(InformationTooltip, self, TOPRIGHT, 0, 5, BOTTOMRIGHT)
	SetTooltipText(InformationTooltip, "Open Set Collections")
end

function ChestFarmer.closeButtonPressed()
	ChestFarmer.savedVariables.guiHidden = true
	ChestFarmerWindow:SetHidden(ChestFarmer.savedVariables.guiHidden)
	HUD_SCENE:RemoveFragment(fragment)
	HUD_UI_SCENE:RemoveFragment(fragment)
end

function ChestFarmer.closeButton_showTooltip(self)
	InitializeTooltip(InformationTooltip, self, TOPRIGHT, 0, 5, BOTTOMRIGHT)
	SetTooltipText(InformationTooltip, "Close GUI and run in the background.\n(Use command '/chestfarmer' or '/cf' to toggle GUI)")
end

function ChestFarmer.hideTooltip(self)
	ClearTooltip(InformationTooltip)
end

function ChestFarmer.slashHandler(param)
	param = param:lower()
	--toggle GUI
	if param == "" then
		ChestFarmer.savedVariables.guiHidden = not ChestFarmer.savedVariables.guiHidden
		if ChestFarmer.savedVariables.guiHidden == false then
			ChestFarmerWindow:SetHidden(ChestFarmer.savedVariables.guiHidden)
			HUD_SCENE:AddFragment(fragment)
			HUD_UI_SCENE:AddFragment(fragment)
		else
			ChestFarmerWindow:SetHidden(ChestFarmer.savedVariables.guiHidden)
			HUD_SCENE:RemoveFragment(fragment)
			HUD_UI_SCENE:RemoveFragment(fragment)
		end
	--stats
	elseif param == "stats" then
		ChestFarmer.statsButtonPressed()
	--reset
	elseif param == "reset" then
		ChestFarmer.resetButtonPressed()
	end
end

--Data functions

function ChestFarmer.saveQuality()
	ChestFarmer.lockQuality = GetLockQuality()
end

function ChestFarmer.fixCollected()
	if collectedSets == 0 then
		for k,v in pairs(zoneSets) do
			collectedSets = collectedSets + GetNumItemSetCollectionSlotsUnlocked(v)
		end
		if totalSets ~= 0 then
			if collectedSets == totalSets then
				setsPercentage = 100
			else
				setsPercentage = string.format("%.2f",(collectedSets/totalSets)*100)
			end
		else
			setsPercentage = 0
		end
		ChestFarmerWindowSetsCount:SetText(collectedSets .. "/" .. totalSets .. " collected" .. " (" .. setsPercentage .. "%)")
	end
end

function ChestFarmer.cfRead()
	ChestFarmer.cfReadZone = {
	--Starter Zones
	--Bal Foyen 
		[281] = {281, ChestFarmer.savedVariables.starterTC, {281}},
	--Bleakrock Isle 
		[280] = {280, ChestFarmer.savedVariables.starterTC, {281}},
	--Betnikh 
		[535] = {535, ChestFarmer.savedVariables.starterTC, {281}},
	--Stros M'Kai 
		[534] = {534, ChestFarmer.savedVariables.starterTC, {281}},
	--Khenarthi's Roost 
		[537] = {537, ChestFarmer.savedVariables.starterTC, {281}},
	--Ebonheart Pact
	--Deshaan 
		[57] = {57, ChestFarmer.savedVariables.deshaanTC, {292, 34, 293}}, 
	--Eastmarch 
		[101] = {101, ChestFarmer.savedVariables.eastmarchTC, {21, 27, 56}},  
	--Shadowfen 
		[117] = {117, ChestFarmer.savedVariables.shadowfenTC, {62, 66, 187}},
	--Stonefalls 
		[41] = {41, ChestFarmer.savedVariables.stonefallsTC, {49, 291, 31}}, 
	--The Rift 
		[103] = {103, ChestFarmer.savedVariables.theriftTC, {135, 20, 294}},
	--Daggerfall Covenant
	--Alik'r Desert 
		[104] = {104, ChestFarmer.savedVariables.alikrdesertTC, {284, 47, 283}},
	--Bangkorai 
		[92] = {92, ChestFarmer.savedVariables.bangkoraiTC, {285, 286, 70}},
	--Glenumbra
		[3] = {3, ChestFarmer.savedVariables.glenumbraTC, {58, 107, 65}},
	--Rivenspire 
		[20] = {20, ChestFarmer.savedVariables.rivenspireTC, {60, 98, 282}},
	--Stormhaven 
		[19] = {19, ChestFarmer.savedVariables.stormhavenTC, {22, 112, 93}},
	--Aldmeri Dominion
	--Auridon 
		[381] = {381, ChestFarmer.savedVariables.auridonTC, {36, 86, 105}},
	--Grahtwood 
		[383] = {383, ChestFarmer.savedVariables.grahtwoodTC, {287, 69, 57}},
	--Greenshade 
		[108] = {108, ChestFarmer.savedVariables.greenshadeTC, {64, 106, 288}},
	--Malabal Tor 
		[58] = {58, ChestFarmer.savedVariables.malabaltorTC, {289, 30, 99}},
	--Reaper's March 
		[382] = {382, ChestFarmer.savedVariables.reapersmarchTC, {290, 114, 90}},
	--Neutral zones
	--Summerset 
		[1011] = {1011, ChestFarmer.savedVariables.summersetTC, {382, 383, 384}}, 
	--Western Skyrim 
		[1160] = {1160, ChestFarmer.savedVariables.wSkyrimTC, {487, 488, 489}},
	--Blackreach: Greymoor Caverns 
		[1161] = {1161, ChestFarmer.savedVariables.wSkyrimTC, {487, 488, 489}},
	--Clockwork City 
		[980] = {980, ChestFarmer.savedVariables.clockworkTC, {354, 355, 356}},
	--Coldharbour 
		[347] = {347, ChestFarmer.savedVariables.coldharbourTC, {94, 26, 68}}, 
	--Craglorn 
		[888] = {888, ChestFarmer.savedVariables.craglornTC, {145, 146, 147}},
	--Gold Coast 
		[823] = {823, ChestFarmer.savedVariables.goldcoastTC, {243, 244, 245}},
	--Hew's Bane 
		[816] = {816, ChestFarmer.savedVariables.hewsbaneTC, {227, 228}},
	--Murkmire 
		[726] = {726, ChestFarmer.savedVariables.murkmireTC, {405, 406, 407}},
	--Northern Elsweyr 
		[1086] = {1086, ChestFarmer.savedVariables.nElsweyrTC, {440, 441, 442}},
	--Southern Elsweyr 
		[1133] = {1133, ChestFarmer.savedVariables.sElsweyrTC, {465, 466, 467}},
	--The Reach 
		[1207] = {1207, ChestFarmer.savedVariables.thereachTC, {536, 537, 538}},
	--Blackreach: Arkthzand Cavern 
		[1208] = {1208, ChestFarmer.savedVariables.thereachTC, {536, 537, 538}},
	--Vvardenfell	 
		[849] = {849, ChestFarmer.savedVariables.vvardenfellTC, {320, 321, 322}},
	--Wrothgar 
		[684] = {684, ChestFarmer.savedVariables.wrothgarTC, {210, 212, 218}},
	--Blackwood 
		[1261] = {1261, ChestFarmer.savedVariables.blackwoodTC, {579, 580, 581}},
	--Fargrave
		[1282] = {1282, ChestFarmer.savedVariables.deadlandsTC, {613, 614, 615}},
	--Deadlands
		[1286] = {1286, ChestFarmer.savedVariables.deadlandsTC, {613, 614, 615}},
	--High Isle
		[1318] = {1318, ChestFarmer.savedVariables.highisleTC, {643, 644, 645}},
	--Galen
		[1383] = {1383, ChestFarmer.savedVariables.galenTC, {671, 672, 673}},
	--Telvanni Peninsula
		[1414] = {1414, ChestFarmer.savedVariables.necromTC, {698, 699, 700}},
	--West Weald
		[1443] = {1443, ChestFarmer.savedVariables.westwealdTC, {757, 758, 759}},
	--Solstice
		[1502] = {1502, ChestFarmer.savedVariables.solsticeTC, {805, 806, 807, 845}},
	--Cyrodiil	 
		[181] = {181, ChestFarmer.savedVariables.cyrodiilTC, {101, 39, 85, 131, 422, 419, 52, 128, 133, 113, 480, 104, 482, 127, 25, 130, 83, 238, 126, 100, 417, 59, 237, 109, 234, 108, 76, 235, 89, 67, 132, 420, 418, 421, 97, 63, 50, 481, 129, 236, 111, 239, 125}},
	--Imperial City 
		[584] = {584, ChestFarmer.savedVariables.impcityTC, {206, 179, 204, 246, 253, 181, 200, 180, 201, 199, 248, 247, 205}},
	--Exceptions
	--The Harborage 
		[199] = {199, 0, {}}, 
	--The Earth Forge 
		[208] = {208, 0, {}}, 
	--Eyevea 
		[267] = {267, 0, {}}, 
	--Pregame 
		[279] = {279, 0, {}}, 
	--Battlegrounds
	--Arcane University 
		[511] = {511, 0, {326, 327, 328, 329, 334}}, 
	--Deeping Drome 
		[512] = {512, 0, {326, 327, 328, 329, 334}}, 
	--Mor Khazgur 
		[513] = {513, 0, {326, 327, 328, 329, 334}}, 
	--Istirus Outpost 
		[514] = {514, 0, {326, 327, 328, 329, 334}}, 
	--Istirus Outpost Arena 
		[515] = {515, 0, {326, 327, 328, 329, 334}}, 
	--Ald Carac 
		[516] = {516, 0, {326, 327, 328, 329, 334}}, 
	--Eld Angavar 1 
		[517] = {517, 0, {326, 327, 328, 329, 334}}, 
	--Eld Angavar 2 
		[518] = {518, 0, {326, 327, 328, 329, 334}}, 
	--Stirk 
		[572] = {572, 0, {}}, 
	--The Wailing Prison 
		[586] = {347, ChestFarmer.savedVariables.coldharbourTC, {94, 26, 68}},
	--The Earth Forge 
		[642] = {642, 0, {}},
	--The Scholarium
		[1463] = {1463, 0 , {}},
	--Houses
	--Linchal Grand Manor 
		[1005] = {823, ChestFarmer.savedVariables.goldcoastTC, {243, 244, 245}},
	--Lakemire Xanmeer Manor 
		[1108] = {726, ChestFarmer.savedVariables.murkmireTC, {405, 406, 407}},
	--Enchanted Snow Globe Home 
		[1109] = {101, ChestFarmer.savedVariables.eastmarchTC, {21, 27, 56}},  
	--Thieves' Oasis 
		[1200] = {92, ChestFarmer.savedVariables.bangkoraiTC, {285, 286, 70}},
	--Stone Eagle Aerie 
		[1264] = {1207, ChestFarmer.savedVariables.thereachTC, {536, 537, 538}},
	--Moon Gate 
		[1116] = {1086, ChestFarmer.savedVariables.nElsweyrTC, {440, 441, 442}},
	--The Valley of Blades 
		[1142] = {1142, 0, {}}, 
	--Vahlokzin's Lair 
		[1144] = {1133, ChestFarmer.savedVariables.sElsweyrTC, {465, 466, 467}},
	--The Undergrove 
		[1195] = {1161, ChestFarmer.savedVariables.wSkyrimTC, {487, 488, 489}}
		}
	local actualZoneId = 0
	zoneSets = {}
	collectedSets = 0
	totalSets = 0
	setsPercentage = ""
	tempParentZoneId = GetParentZoneId(GetZoneId(GetUnitZoneIndex("player")))
	if ChestFarmer.cfReadZone[tempParentZoneId] == nil then
		actualZoneId, ChestFarmer.numChests, zoneSets = tempParentZoneId, ChestFarmer.savedVariables.unknownZoneTC, {}
	else
		actualZoneId, ChestFarmer.numChests, zoneSets = (ChestFarmer.cfReadZone[tempParentZoneId])[1], (ChestFarmer.cfReadZone[tempParentZoneId])[2], (ChestFarmer.cfReadZone[tempParentZoneId])[3]
	end
	--Process collection data
	for k,v in pairs(zoneSets) do
		collectedSets = collectedSets + GetNumItemSetCollectionSlotsUnlocked(v)
		totalSets = totalSets + GetNumItemSetCollectionPieces(v)
	end
	if totalSets ~= 0 then
		if collectedSets == totalSets then
			setsPercentage = 100
		else
			setsPercentage = string.format("%.2f",(collectedSets/totalSets)*100)
		end
	else
		setsPercentage = 0
	end
	
	--edgecase for addon initialization
	if ChestFarmer.numChests == nil then
		ChestFarmer.numChests = 0
	end
	
	local actualZone = GetZoneNameById(actualZoneId)
	ChestFarmerWindowZoneDisplay:SetText(actualZone)
	ChestFarmer.numLockpicks = GetNumLockpicksLeft("player")
	ChestFarmerWindowLockpicksCount:SetText(ChestFarmer.numLockpicks .. " lockpicks remaining") 
	ChestFarmerWindowChestsCount:SetText(ChestFarmer.numChests .. " chests opened")
	ChestFarmerWindowSetsCount:SetText(collectedSets .. "/" .. totalSets .. " collected" .. " (" .. setsPercentage .. "%)")
end

function ChestFarmer.cfWrite(tempTc)
	local tempParentZoneId = GetParentZoneId(GetZoneId(GetUnitZoneIndex("player")))
	--Starter Zones
	--Bal Foyen
	if tempParentZoneId == 281 then
		ChestFarmer.savedVariables.starterTC = tempTc
	--Bleakrock Isle
	elseif tempParentZoneId == 280 then
		ChestFarmer.savedVariables.starterTC = tempTc
	--Betnikh
	elseif tempParentZoneId == 535 then
		ChestFarmer.savedVariables.starterTC = tempTc
	--Stros M'Kai
	elseif tempParentZoneId == 534 then
		ChestFarmer.savedVariables.starterTC = tempTc
	--Khenarthi's Roost
	elseif tempParentZoneId == 537 then
		ChestFarmer.savedVariables.starterTC = tempTc
	--Ebonheart Pact
	--Deshaan
	elseif tempParentZoneId == 57 then
		ChestFarmer.savedVariables.deshaanTC = tempTc 
	--Eastmarch
	elseif tempParentZoneId == 101 then
		ChestFarmer.savedVariables.eastmarchTC = tempTc 
	--Shadowfen
	elseif tempParentZoneId == 117 then
		ChestFarmer.savedVariables.shadowfenTC = tempTc
	--Stonefalls
	elseif tempParentZoneId == 41 then
		ChestFarmer.savedVariables.stonefallsTC = tempTc 
	--The Rift
	elseif tempParentZoneId == 103 then
		ChestFarmer.savedVariables.theriftTC = tempTc
	--Daggerfall Covenant
	--Alik'r Desert
	elseif tempParentZoneId == 104 then
		ChestFarmer.savedVariables.alikrdesertTC = tempTc
	--Bangkorai
	elseif tempParentZoneId == 92 then
		ChestFarmer.savedVariables.bangkoraiTC = tempTc
	--Glenumbra
	elseif tempParentZoneId == 3 then
		ChestFarmer.savedVariables.glenumbraTC = tempTc
	--Rivenspire
	elseif tempParentZoneId == 20 then
		ChestFarmer.savedVariables.rivenspireTC = tempTc
	--Stormhaven
	elseif tempParentZoneId == 19 then
		ChestFarmer.savedVariables.stormhavenTC = tempTc
	--Aldmeri Dominion
	--Auridon
	elseif tempParentZoneId == 381 then
		ChestFarmer.savedVariables.auridonTC = tempTc
	--Grahtwood
	elseif tempParentZoneId == 383 then
		ChestFarmer.savedVariables.grahtwoodTC = tempTc
	--Greenshade
	elseif tempParentZoneId == 108 then
		ChestFarmer.savedVariables.greenshadeTC = tempTc
	--Malabal Tor
	elseif tempParentZoneId == 58 then
		ChestFarmer.savedVariables.malabaltorTC = tempTc
	--Reaper's March
	elseif tempParentZoneId == 382 then
		ChestFarmer.savedVariables.reapersmarchTC = tempTc
	--Neutral zones
	--Summerset
	elseif tempParentZoneId == 1011 then
		ChestFarmer.savedVariables.summersetTC = tempTc 
	--Western Skyrim
	elseif tempParentZoneId == 1160 then
		ChestFarmer.savedVariables.wSkyrimTC = tempTc
	--Blackreach: Greymoor Caverns
	elseif tempParentZoneId == 1161 then
		ChestFarmer.savedVariables.wSkyrimTC = tempTc
	--Clockwork City
	elseif tempParentZoneId == 980 then
		ChestFarmer.savedVariables.clockworkTC = tempTc
	--Coldharbour
	elseif tempParentZoneId == 347 then
		ChestFarmer.savedVariables.coldharbourTC = tempTc 
	--Craglorn
	elseif tempParentZoneId == 888 then
		ChestFarmer.savedVariables.craglornTC = tempTc
	--Gold Coast
	elseif tempParentZoneId == 823 then
		ChestFarmer.savedVariables.goldcoastTC = tempTc
	--Hew's Bane
	elseif tempParentZoneId == 816 then
		ChestFarmer.savedVariables.hewsbaneTC = tempTc
	--Murkmire
	elseif tempParentZoneId == 726 then
		ChestFarmer.savedVariables.murkmireTC = tempTc 
	--Northern Elsweyr
	elseif tempParentZoneId == 1086 then
		ChestFarmer.savedVariables.nElsweyrTC = tempTc
	--Southern Elsweyr
	elseif tempParentZoneId == 1133 then
		ChestFarmer.savedVariables.sElsweyrTC = tempTc
	--The Reach
	elseif tempParentZoneId == 1207 then
		ChestFarmer.savedVariables.thereachTC = tempTc
	--Blackreach: Arkthzand Cavern
	elseif tempParentZoneId == 1208 then
		ChestFarmer.savedVariables.thereachTC = tempTc
	--Vvardenfell	
	elseif tempParentZoneId == 849 then
		ChestFarmer.savedVariables.vvardenfellTC = tempTc
	--Wrothgar
	elseif tempParentZoneId == 684 then
		ChestFarmer.savedVariables.wrothgarTC = tempTc
	--Blackwood
	elseif tempParentZoneId == 1261 then
		ChestFarmer.savedVariables.blackwoodTC = tempTc
	--Fargrave
	elseif tempParentZoneId == 1282 then
		ChestFarmer.savedVariables.deadlandsTC = tempTc
	--Deadlands
	elseif tempParentZoneId == 1286 then
		ChestFarmer.savedVariables.deadlandsTC = tempTc
	--High Isle
	elseif tempParentZoneId == 1318 then
		ChestFarmer.savedVariables.highisleTC = tempTc
	--Galen
	elseif tempParentZoneId == 1383 then
		ChestFarmer.savedVariables.galenTC = tempTc
	-- Telvanni Peninsula
	elseif tempParentZoneId == 1414 then
		ChestFarmer.savedVariables.necromTC = tempTc
	-- West Weald
	elseif tempParentZoneId == 1443 then
		ChestFarmer.savedVariables.westwealdTC = tempTc
	-- Solstice
	elseif tempParentZoneId == 1502 then
		ChestFarmer.savedVariables.solsticeTC = tempTc
	--Cyrodiil	
	elseif tempParentZoneId == 181 then
		ChestFarmer.savedVariables.cyrodiilTC = tempTc
	--Imperial City
	elseif tempParentZoneId == 584 then
		ChestFarmer.savedVariables.impcityTC = tempTc
	--Exceptions
	--The Wailing Prison
	elseif tempParentZoneId == 586 then
		ChestFarmer.savedVariables.coldharbourTC = tempTc
	--Moon Gate
	elseif tempParentZoneId == 1116 then
		ChestFarmer.savedVariables.nElsweyrTC = tempTc
	--Vahlokzin's Lair
	elseif tempParentZoneId == 1144 then
		ChestFarmer.savedVariables.sElsweyrTC = tempTc
	--The Undergrove
	elseif tempParentZoneId == 1195 then
		ChestFarmer.savedVariables.wSkyrimTC = tempTc
	--Unknown Zone
	else
		ChestFarmer.savedVariables.unknownZoneTC = tempTc
	end
end

function ChestFarmer.interactionLog()
-- Thanks to Shinni for this 'hack' to log last interacted, check out HarvestMap https://www.esoui.com/downloads/info57-HarvestMap.html
	local oldInteract = INTERACTIVE_WHEEL_MANAGER.StartInteraction
	INTERACTIVE_WHEEL_MANAGER.StartInteraction = function(...)
		local action, name, _, isOwned = GetGameCameraInteractableActionInfo()
		ChestFarmer.wasLastInteractableOwned = isOwned
		ChestFarmer.lastInteractableAction = action
		return oldInteract(...)
	end
end

function ChestFarmer.countIncrement()
	if IsUnitInDungeon("player") == true then
		if GetCurrentZoneDungeonDifficulty() == 0 then
			if (not ChestFarmer.wasLastInteractableOwned) and ChestFarmer.lastInteractableAction == GetString(SI_GAMECAMERAACTIONTYPE12) then
				ChestFarmer.numChests = ChestFarmer.numChests + 1
					if ChestFarmer.lockQuality == 4 then
						ChestFarmer.savedVariables.masterCount = ChestFarmer.savedVariables.masterCount + 1
					elseif ChestFarmer.lockQuality == 3 then
						ChestFarmer.savedVariables.advancedCount = ChestFarmer.savedVariables.advancedCount + 1
					elseif ChestFarmer.lockQuality == 2 then
						ChestFarmer.savedVariables.intermediateCount = ChestFarmer.savedVariables.intermediateCount + 1
					elseif ChestFarmer.lockQuality == 1 then
						ChestFarmer.savedVariables.simpleCount = ChestFarmer.savedVariables.simpleCount + 1
					end
			end
		end
	else
		if (not ChestFarmer.wasLastInteractableOwned) and ChestFarmer.lastInteractableAction == GetString(SI_GAMECAMERAACTIONTYPE12) then
			ChestFarmer.numChests = ChestFarmer.numChests + 1
				if ChestFarmer.lockQuality == 4 then
					ChestFarmer.savedVariables.masterCount = ChestFarmer.savedVariables.masterCount + 1
				elseif ChestFarmer.lockQuality == 3 then
					ChestFarmer.savedVariables.advancedCount = ChestFarmer.savedVariables.advancedCount + 1
				elseif ChestFarmer.lockQuality == 2 then
					ChestFarmer.savedVariables.intermediateCount = ChestFarmer.savedVariables.intermediateCount + 1
				elseif ChestFarmer.lockQuality == 1 then
						ChestFarmer.savedVariables.simpleCount = ChestFarmer.savedVariables.simpleCount + 1
				end
		end
	end

	ChestFarmer.cfWrite(ChestFarmer.numChests)
	ChestFarmer.numLockpicks = GetNumLockpicksLeft("player")
	ChestFarmerWindowLockpicksCount:SetText(ChestFarmer.numLockpicks .. " lockpicks remaining")
	ChestFarmerWindowChestsCount:SetText(ChestFarmer.numChests .. " chests opened")
end

--Events

EVENT_MANAGER:RegisterForEvent(ChestFarmer.name, EVENT_ADD_ON_LOADED, ChestFarmer.onAddonLoaded)
EVENT_MANAGER:RegisterForEvent(ChestFarmer.name, EVENT_PLAYER_ACTIVATED, ChestFarmer.cfRead)
EVENT_MANAGER:RegisterForEvent(ChestFarmer.name, EVENT_BEGIN_LOCKPICK, ChestFarmer.saveQuality)
EVENT_MANAGER:RegisterForEvent(ChestFarmer.name, EVENT_LOCKPICK_SUCCESS, ChestFarmer.countIncrement)
EVENT_MANAGER:RegisterForEvent(ChestFarmer.name, EVENT_ITEM_SET_COLLECTION_UPDATED,	ChestFarmer.cfRead)
EVENT_MANAGER:RegisterForUpdate("fixCollected", 3000, ChestFarmer.fixCollected)
EVENT_MANAGER:RegisterForUpdate("ChestFarmer-InteractionLog", 800, ChestFarmer.interactionLog)

--Slash commands
SLASH_COMMANDS["/chestfarmer"] = ChestFarmer.slashHandler
SLASH_COMMANDS["/cf"] = ChestFarmer.slashHandler
--"/chestfarmer" or "/cf" toggles GUI
--"/chestfarmer ststs" or "/cf ststs" prints stats to chat
--"/chestfarmer reset" or "/cf reset" resets chests opened count for current zone