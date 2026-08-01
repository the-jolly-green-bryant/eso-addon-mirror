------------------------------------------------------------------------------
UnstuffMyBags = UnstuffMyBags or {}
UnstuffMyBags.version = "2.0"
UnstuffMyBags.name = "UnstuffMyBags"

-- Local variables ------------------------------------------------------------
local savedVars = {}
UnstuffMyBags.savedVars = savedVars
-- Here, things are initialized, as in set up. This creates the general structure 
-- of the addon. The values from defaults are accessed through savedVars.value, 
-- defaults only tells them how they are unless altered.

local defaults = {
	-- including style items by default?
	styleitems = true,

	-- including white apparel with a value of 0 gold by default?
	white = true,

	-- including white junk with a value of 0 gold by default?
	junk = true,
   
	-- keeping style items for certain styles? 
	-- this is a dirty and lazy solution. I'm saving the item IDs as strings, so 
	-- over at the Data.lua I can check if the String is set to true. 
	keepStyles = {
		[ITEMSTYLE_RACIAL_HIGH_ELF] = false,	
		[ITEMSTYLE_RACIAL_WOOD_ELF] = false,
		[ITEMSTYLE_RACIAL_DARK_ELF] = true,
		[ITEMSTYLE_RACIAL_NORD] 	= false,
		[ITEMSTYLE_RACIAL_BRETON] 	= false,
		[ITEMSTYLE_RACIAL_ORC] 		= false,
		[ITEMSTYLE_RACIAL_KHAJIIT] 	= false,
		[ITEMSTYLE_RACIAL_ARGONIAN] = false,
		[ITEMSTYLE_RACIAL_IMPERIAL] = false,	
		[ITEMSTYLE_RACIAL_REDGUARD] = false,	
	},
	
	keepHighElf = false, -- altmer   
	keepWoodElf = false, -- bosmer   
	keepDunmer = true, -- dunmer
	keepNord = false, -- nord   
	keepBreton = false, --breton   
	keepRedguard = false, --redguards   
	keepOrc = false, --orcs   
	keepKhajit = false, --khajit
	keepArgonian = false, --argonians
	keepImperial = false, --imperial
	
	keepFurnitureBlueprints	= true,
	keepVanityClothing = false,
	
	stolenStuff = false,
	stolenMaxValue = 25,
	stolenKeepQuality = 1,
	trashRecipes = false,
	stolenKeepRecipeQuality = 4,
	stolenTrashPickups = false,
	stolenTrashIngredients = false,
	stolenTrashTreshold = 2,
 
}

local bagId  = BAG_BACKPACK
local numBagSlots = GetBagSize(bagId)

local icon, stackSize, sellPrice, locked, equipType, itemStyle, quality = nil
local stolen = false 
local itemType, sItemType = nil



local function isItemSaved(bagId, slotId)	

	return
		(IsItemPlayerLocked(bagId, slotId) or 
		(nil ~= ItemSaver and ItemSaver_IsItemSaved(bagId, bagSlot)) or
		(nil ~= FCOIS and FCOIS.callDeconstructionSelectionHandler(BAG_BACKPACK, bagSlot, false, false, false, false, false, true)))
end

local function isRecipe(bagId, slotId)
	return itemType == ITEMTYPE_RECIPE
end

local function isFurnitureBlueprint(bagId, slotId)
	local validSpecializedItemTypes = {
		SPECIALIZED_ITEMTYPE_RECIPE_ALCHEMY_FORMULA_FURNISHING = true, 
		SPECIALIZED_ITEMTYPE_RECIPE_BLACKSMITHING_DIAGRAM_FURNISHING = true, 
		SPECIALIZED_ITEMTYPE_RECIPE_CLOTHIER_PATTERN_FURNISHING = true,
		SPECIALIZED_ITEMTYPE_RECIPE_ENCHANTING_SCHEMATIC_FURNISHING = true, 
		SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_DESIGN_FURNISHING = true, 
		SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_STANDARD_DRINK = true, 
		SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_STANDARD_FOOD = true, 
		SPECIALIZED_ITEMTYPE_RECIPE_WOODWORKING_BLUEPRINT_FURNISHING = true, 
	}
	return (itemType == ITEMTYPE_RECIPE and  validSpecializedItemTypes[sItemType])
end

local function isVanityClothing(bagId, slotId)
	return (itemType == ITEMTYPE_ARMOR and sItemType == 0)
end

local function isUnderValueThreshold(bagId, slotId)
     
	if nil == sellPrice then 
	_, _, sellPrice = GetItemInfo(bagId, slotId)
	sellPrice = sellPrice or 0.001
	end
	local ret = false 
	if sellPrice == 0 then
		ret = ((quality <= 1) and savedVars.white and (equipType ~= 0))
		ret = ret or (savedVars.junk and (quality < 4) and IsItemJunk(bagId, slotId))
	end
	
	
	return ret or (stolen and (not (math.floor(sellPrice/stack) > savedVars.stolenMaxValue)))
	
end

local function isOutfashionedStyleMaterial(bagId, slotId)
	
	return ((savedVars.styleitems and (itemType == ITEMTYPE_STYLE_MATERIAL)) and
		(not savedVars.keepStyles[itemStyle]))
	
end


------------------------
-- evaluate: Keepsies -- 
------------------------
local function isVanityClothingKeepsie(bagId, slotId)
	return (savedVars.keepVanityClothing and isVanityClothing(bagId, slotId))	
end

local function isFurnitureBlueprintKeepsie(bagId, slotId)
	
	return (savedVars.keepFurnitureBlueprints and isFurnitureBlueprint(bagId, slotId))
	
end

local function isRecipeKeepsie(bagId, slotId)
	
	if (
		(not isRecipe(bagId, slotId))
		or (isFurnitureBlueprintKeepsie(bagId, slotId))
	) then return end 
	
	return (quality < (stolen and tonumber(savedVars.stolenKeepRecipeQuality)) or 4)
	
end

local function isLegallyObtainedKeepsie(bagId, slotId)
	if not stolen then return false end
	return (
			(itemType == ITEMTYPE_TREASURE) or		-- laundered treasure
			(itemType == ITEMTYPE_TOOL)		or		-- lockpicks
			(itemType == ITEMTYPE_SIEGE)	or		-- sieges
			(IsItemBound(bagId, slotId))			-- never touch bound items that aren't stolen
	)
end

------------------------
-- /evaluate: Keepsies -
------------------------

local function IsDeathCandidate(bagId, slotId)

	icon, stackSize, sellPrice, _, locked, equipType, itemStyle, quality = GetItemInfo(bagId, slotId)
	
	if ((nil == icon) or locked) then return false end
	
	stolen 				= IsItemStolen(bagId, slotId)
	itemType, sItemType = GetItemType(bagId, slotId)

	if nil == itemType then return false end	
	
	if (isItemSaved(bagId, slotId) or				-- respect itemSaverings
		isLegallyObtainedKeepsie(bagId, slotId) or	-- some legally obtained stuffs will be kept
		isVanityClothingKeepsie(bagId, slotId)	or 	-- player wants to keep vanity clothing?
		isFurnitureBlueprintKeepsie(bagId, slotId)	-- player wants to keep furniture blueprints?
	) then return false end	
	
	return isUnderValueThreshold(bagId, slotId) or isOutfashionedStyleMaterial(bagId, slotId)		
		
end

local function destroyIt(bagId, slotId)
	DestroyItem(bagId, slotId, true) 
	PlaySound(SOUNDS.INVENTORY_ITEM_JUNKED)
end

local function junkIt(bagId, slotId, junkState)
	
	local sound = SOUNDS.INVENTORY_ITEM_JUNKED 
if not junkState then sound = SOUNDS.INVENTORY_ITEM_UNJUNKED end
	SetItemIsJunk(bagId, slotId, junkState) 
	PlaySound(sound)
	
end

function UnstuffMyBags.HandleBagDetritus(trashIt)
	StowAllVirtualItems() 

	for slotId = 0, numBagSlots do  		
		if IsDeathCandidate(bagId, slotId) then
			if trashIt then 
				destroyIt(bagId, slotId)
			else
				junkIt(bagId, slotId, true)
			end
		end
				
	end	  
end

local function onInventorySlotUpdate(eventCode, bagId, slotId, isNewItem, itemSoundCategory, inventoryUpdateReason, stackCountChange)
	
	if not (isNewItem and stackCountChange > 0)then return end
	if not IsDeathCandidate(bagId, slotId, GetItemType(bagId, slotId)) then return end
	
	StowAllVirtualItems() 
	
	if savedVars.trashOnPickup then
		destroyIt(bagId, slotId)	
	else
		junkIt(bagId, slotId, true)
	end
	
end

-- [ruthlessly stolen from Junkee]
local junkStripDescriptor = UnstuffMyBagsKeyStrip:New("Junk", "UNSTUFF_MY_BAGS_JUNK_ITEM", UnstuffMyBags.JunkIt)
local unjunkStripDescriptor = UnstuffMyBagsKeyStrip:New("Unjunk", "UNSTUFF_MY_BAGS_JUNK_ITEM", UnstuffMyBags.JunkIt)
local deleteStripDescriptor = UnstuffMyBagsKeyStrip:New("Destroy", "UNSTUFF_MY_BAGS_DELETE_ITEM", UnstuffMyBags.DeleteItem)


UnstuffMyBags.OnMouseEnter = function(control)
	UnstuffMyBags.bagId  = control.dataEntry.data.bagId
	UnstuffMyBags.slotId = control.dataEntry.data.slotIndex
	UnstuffMyBags.isJunk = control.dataEntry.data.isJunk

	UnstuffMyBags.AddJunkAction()
end

UnstuffMyBags.OnMouseExit = function(control)
	UnstuffMyBags.bagId  = nil
	UnstuffMyBags.slotId = nil
	UnstuffMyBags.isJunk = false

	UnstuffMyBags.RemoveJunkAction()
end

UnstuffMyBags.JunkItem = function(control)

	if UnstuffMyBags.bagId == nil then return end
	local isJunk = IsItemJunk(UnstuffMyBags.bagId, UnstuffMyBags.slotId)
	SetItemIsJunk(UnstuffMyBags.bagId, UnstuffMyBags.slotId, not isJunk)
	if isJunk then	
		PlaySound(SOUNDS.INVENTORY_ITEM_UNJUNKED)		
	else
		PlaySound(SOUNDS.INVENTORY_ITEM_JUNKED)		
	end
	
end

UnstuffMyBags.DeleteItem = function()
	if UnstuffMyBags.bagId == nil then return end
	DestroyItem(UnstuffMyBags.bagId, UnstuffMyBags.slotId)
end

UnstuffMyBags.AddJunkAction = function()
	if (UnstuffMyBags.isJunk) then
		unjunkStripDescriptor:Add(true)
	else
		junkStripDescriptor:Add(true)
	end
	deleteStripDescriptor:Add(true)
end

UnstuffMyBags.RemoveJunkAction = function()
	junkStripDescriptor:Remove()
	unjunkStripDescriptor:Remove()
	deleteStripDescriptor:Remove()
end

local function registerInventoryHotkeys()
	
	for _, index in pairs({INVENTORY_BACKPACK, INVENTORY_BANK}) do	
		local listView = PLAYER_INVENTORY.inventories[index].listView
		if listView and listView.dataTypes and listView.dataTypes[1] then
			local originalCallback = listView.dataTypes[1].setupCallback
			listView.dataTypes[1].setupCallback = function(rowControl, slot)
				originalCallback(rowControl, slot)
				ZO_PreHookHandler(rowControl, "OnMouseEnter", UnstuffMyBags.OnMouseEnter)
				ZO_PreHookHandler(rowControl, "OnMouseExit",  UnstuffMyBags.OnMouseExit)
			end
		end
	end

	
	
	
end
local function registerEventHooks()
	EVENT_MANAGER:RegisterForEvent("UnstuffMyBags_OnLoot", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, onInventorySlotUpdate)
end

-- [/ruthlessly stolen from Junkee]

UnstuffMyBags.print = function(string)
	CHAT_SYSTEM:AddMessage(string)
end


local function OnLoad(eventCode, name)
	-- every addon has one of these, but if the onLoad is called with the parameters
	-- for another addon, ours shouldn't handle them and instead pop out right away.
	-- removing this line will likely cause havoc.
	if name ~= "UnstuffMyBags" then return end

	registerInventoryHotkeys()
	registerEventHooks()
	--this will change the default value for your own species, so that
	--you won't automatically junk style items you need for deconstructing.

	local keepTag = "keep" .. string.gsub(GetUnitRace("player"), " ", "")
	defaults[keepTag] = true
	
	--initialize saved variables
	savedVars = ZO_SavedVars:New("UnstuffMyBags_SavedVariables", 1, nil, defaults)
	
	-- this calls the CreateSettingsMenu from UnstuffMyBagsMenu.lua
	UnstuffMyBags.CreateSettingsMenu(savedVars, defaults)

	-- this creates the key bindings in the settings menu. to alter them further,
	-- have a look in the bindings.xml
	ZO_CreateStringId("SI_BINDING_NAME_UNSTUFF_MY_BAGS_JUNK_IT", "Junk all detritus in bag")
	ZO_CreateStringId("SI_BINDING_NAME_UNSTUFF_MY_BAGS_DELETE_IT", "Destroy all detritus in bag")
	ZO_CreateStringId("SI_BINDING_NAME_UNSTUFF_MY_BAGS_JUNK_ITEM", "Junk this item")
	ZO_CreateStringId("SI_BINDING_NAME_UNSTUFF_MY_BAGS_DELETE_ITEM", "Destroy this item")
	
	-- this tells the game that we're done initializing
	EVENT_MANAGER:UnregisterForEvent("UnstuffMyBags", EVENT_ADD_ON_LOADED)
	
end

EVENT_MANAGER:RegisterForEvent("UnstuffMyBags_OnLoad", EVENT_ADD_ON_LOADED, OnLoad)
