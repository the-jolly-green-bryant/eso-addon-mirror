AutoProcessStolenItems 	= AutoProcessStolenItems or {}
local settings 			= AutoProcessStolenItems.savedVars
local APSI 				= AutoProcessStolenItems

local task 				= LibStub("LibAsync"):Create("AutoProcessStolenItems")

local defaults = {

	debugSingle						= false,						
	debugAll						= true,

	["sell"]						= {
		["quality"]					= 1,
		[ITEMTYPE_TREASURE]			= false,
	},
	
	handleLocked					= true,
	
	-- furniture material 
	[ITEMTYPE_FURNISHING_MATERIAL] 	= true,
	
	-- style material and raw material 
	[ITEMTYPE_STYLE_MATERIAL] 		= true,	
	[ITEMTYPE_RAW_MATERIAL] 		= true,	
	
	-- provisioning material
	[ITEMTYPE_INGREDIENT] 			= true,	
	
	-- armor: Vanity clothing
	[ITEMTYPE_ARMOR]				= {
		[SPECIALIZED_ITEMTYPE_MIN_VALUE]									= true,
	},
			
	-- treasures: Crow treasures
	[ITEMTYPE_TREASURE]	 												= {
		[SPECIALIZED_ITEMTYPE_TREASURE]										= false,
		[SPECIALIZED_ITEMTYPE_MIN_VALUE]									= false,
	},
	
	-- trophies: Leniency edicts and treasure maps
	[ITEMTYPE_TROPHY]	= {
		[SPECIALIZED_ITEMTYPE_TROPHY_TREASURE_MAP]							= false,
		[SPECIALIZED_ITEMTYPE_TROPHY_SCROLL]								= false,
	},
	
	-- motifs: Books and chapters
	[ITEMTYPE_RACIAL_STYLE_MOTIF]	= {
		[SPECIALIZED_ITEMTYPE_RACIAL_STYLE_MOTIF_BOOK]						= false,
		[SPECIALIZED_ITEMTYPE_RACIAL_STYLE_MOTIF_CHAPTER] 					= true,
	},
	
	-- furniture recipes and provisioning recipes
	[ITEMTYPE_RECIPE] 				= {
		[SPECIALIZED_ITEMTYPE_RECIPE_ALCHEMY_FORMULA_FURNISHING] 			= true,
		[SPECIALIZED_ITEMTYPE_RECIPE_BLACKSMITHING_DIAGRAM_FURNISHING] 		= true,
		[SPECIALIZED_ITEMTYPE_RECIPE_CLOTHIER_PATTERN_FURNISHING] 			= true,
		[SPECIALIZED_ITEMTYPE_RECIPE_ENCHANTING_SCHEMATIC_FURNISHING] 		= true,
		[SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_DESIGN_FURNISHING] 		= true,
		[SPECIALIZED_ITEMTYPE_RECIPE_WOODWORKING_BLUEPRINT_FURNISHING]		= true,		
		
		[SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_STANDARD_DRINK] 			= true,
		[SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_STANDARD_FOOD] 			= true,
	},
	
	["quality"] = {
		[ITEMTYPE_RACIAL_STYLE_MOTIF]		= {
			SPECIALIZED_ITEMTYPE_RACIAL_STYLE_MOTIF_BOOK	= 3,
		},
		[ITEMTYPE_RECIPE]		= {
			[SPECIALIZED_ITEMTYPE_RECIPE_ALCHEMY_FORMULA_FURNISHING]			= 1,			
			[SPECIALIZED_ITEMTYPE_RECIPE_ALCHEMY_FORMULA_FURNISHING]			= 1,					
			[SPECIALIZED_ITEMTYPE_RECIPE_BLACKSMITHING_DIAGRAM_FURNISHING] 		= 1,			
			[SPECIALIZED_ITEMTYPE_RECIPE_CLOTHIER_PATTERN_FURNISHING] 			= 1,	
			[SPECIALIZED_ITEMTYPE_RECIPE_ENCHANTING_SCHEMATIC_FURNISHING]		= 1, 
			[SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_DESIGN_FURNISHING] 		= 1, 	
			[SPECIALIZED_ITEMTYPE_RECIPE_WOODWORKING_BLUEPRINT_FURNISHING] 		= 1,
			
			[SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_STANDARD_DRINK] 			= 3,
			[SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_STANDARD_FOOD] 			= 3,			
		},	
	},

	
	destroy = {	
	shutit 																	= false,	
		active 																= false,	
		[ITEMTYPE_FURNISHING_MATERIAL] 										= false,
		[ITEMTYPE_STYLE_MATERIAL] 											= false,	
		[ITEMTYPE_RAW_MATERIAL] 											= false,	
			
		[ITEMTYPE_TREASURE] = {
			[SPECIALIZED_ITEMTYPE_TREASURE]									= false,
			[SPECIALIZED_ITEMTYPE_MIN_VALUE]								= false,
		},
		[ITEMTYPE_FOOD]	 													= false,
		[ITEMTYPE_DRINK] 													= false,
		[ITEMTYPE_POTION]	 												= false,
		[ITEMTYPE_POISON]	 												= false,
		
		[ITEMTYPE_TOOL]	= {
			[SPECIALIZED_ITEMTYPE_LOCKPICK]									= false,
		},
			
		[ITEMTYPE_INGREDIENT] 												= false,
		[ITEMTYPE_WEAPON] 													= false,
		
		[ITEMTYPE_ARMOR] = {
			[SPECIALIZED_ITEMTYPE_ARMOR]									= false,
			[EQUIP_TYPE_RING]												= false,
			[EQUIP_TYPE_NECK]												= false,
			[SPECIALIZED_ITEMTYPE_MIN_VALUE]								= false,
		},
		
		[ITEMTYPE_RACIAL_STYLE_MOTIF] = {
			[SPECIALIZED_ITEMTYPE_RACIAL_STYLE_MOTIF_BOOK]					= false,
			[SPECIALIZED_ITEMTYPE_RACIAL_STYLE_MOTIF_CHAPTER]				= false,
		},
		
		[ITEMTYPE_RECIPE] 				= {
			[SPECIALIZED_ITEMTYPE_RECIPE_ALCHEMY_FORMULA_FURNISHING] 		= false,
			[SPECIALIZED_ITEMTYPE_RECIPE_BLACKSMITHING_DIAGRAM_FURNISHING] 	= false,
			[SPECIALIZED_ITEMTYPE_RECIPE_CLOTHIER_PATTERN_FURNISHING] 		= false,
			[SPECIALIZED_ITEMTYPE_RECIPE_ENCHANTING_SCHEMATIC_FURNISHING] 	= false,
			[SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_DESIGN_FURNISHING] 	= false,
			[SPECIALIZED_ITEMTYPE_RECIPE_WOODWORKING_BLUEPRINT_FURNISHING]	= false,		
			
			[SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_STANDARD_DRINK] 		= false,
			[SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_STANDARD_FOOD] 		= false,
		},
		
		["quality"] = {
			[ITEMTYPE_TREASURE]													= 1,
			[ITEMTYPE_RACIAL_STYLE_MOTIF]		= {
				[SPECIALIZED_ITEMTYPE_RACIAL_STYLE_MOTIF_BOOK]					= 2,
			},
			[ITEMTYPE_RECIPE]		= {
				[SPECIALIZED_ITEMTYPE_RECIPE_ALCHEMY_FORMULA_FURNISHING]		= 1,			
				[SPECIALIZED_ITEMTYPE_RECIPE_ALCHEMY_FORMULA_FURNISHING] 		= 1,					
				[SPECIALIZED_ITEMTYPE_RECIPE_BLACKSMITHING_DIAGRAM_FURNISHING] 	= 1,			
				[SPECIALIZED_ITEMTYPE_RECIPE_CLOTHIER_PATTERN_FURNISHING]		= 1,	
				[SPECIALIZED_ITEMTYPE_RECIPE_ENCHANTING_SCHEMATIC_FURNISHING]	= 1, 
				[SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_DESIGN_FURNISHING] 	= 1, 	
				[SPECIALIZED_ITEMTYPE_RECIPE_WOODWORKING_BLUEPRINT_FURNISHING] 	= 1,
				
				[SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_STANDARD_DRINK] 		= 2,
				[SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_STANDARD_FOOD]		= 2,				
			},
		},		
	}
}

local numSales, numUsed, numLaunders, numLaundered = 0
local itemLink, itemListLaunder, itemListSell = ""
local stackSize, sellPrice, locked, equipType, itemStyleId, quality, itemType, sItemType	= nil

local outputQueueSell, outputQueueLaunder

local function getQuality(bagId, slotId, destroyIt)	
	local settingsArray = (destroyIt and settings.destroy.quality) or settings.quality
	quality = quality or getItemQuality(bagId, slotId)
	local value = settingsArray[itemType]
	if nil ~= value and nil == tonumber(value) then value = value[sItemType] end
	if nil == value then return true end
	if destroyIt then return quality < value end
	return quality >= value
end

local function getValue(bagId, slotId, destroyIt)
	local settingsArray = (destroyIt and settings.destroy) or settings
	
	local value = settingsArray[itemType]
	if nil ~= value and true ~= value and false ~= value then value = value[sItemType] end
	
	-- d(zo_strformat("getValue(<<1>>) (<<2>>/<<3>>)) -> <<4>>", itemLink, itemType, sItemType, tostring(value)))
	
	return value 
end

local function isQuestItem(bagId, slotId)
	return false
end

local function tryAddOutput(itemLink, isLaundering)
	
	if settings.debugSingle then 
		d(zo_strformat("|cffffff<<1>> <<2>><<3>>|r ", ((isLaundering and "Laundering") or "Selling"), itemLink, ((stackSize > 1 and " x"..stackSize) or "")))
	elseif settings.debugAll then
		targetqueue = (isLaundering and outputQueueLaunder) or outputQueueSell
		table.insert(targetqueue,  string.format("%sx %s", stackSize, itemLink))
	end
	


end

local function IsItemSaved(bagId, slotId)
	 return locked or (nil ~= FCOIS and FCOIS.IsLocked(bagId, slotId))
end


local function fenceStolenItem(bagId, slotId)	
	
	if IsItemSaved(bagId, slotId) and not settings.handleLocked then return end -- or isQuestItem(bagId, slotId) the
	
	if not getQuality(bagId, slotId, false) then return end
	if settings.sell[itemType] then 
		SellInventoryItem(bagId, slotId, stackSize)
		tryAddOutput(GetItemLink(bagId, slotId))
	elseif getValue(bagId, slotId, false)  then 
		LaunderItem(bagId, slotId, stackSize)
		tryAddOutput(GetItemLink(bagId, slotId), true)
	end	
	
	
end

local function matchesCrowStrings(tag)
	AutoProcessStolenItems.matchesCrowStrings(tag)
end

local function setLocalVarsForItem(bagId, slotId)
	itemLink = GetItemLink(bagId, slotId)
	
	_, stackSize, sellPrice, _, locked, equipType, itemStyleId, quality = GetItemInfo(bagId, slotId)
	-- d(zo_strformat("stackSize <<1>>, sellPrice <<2>>, locked <<3>>, equipType <<4>>, itemStyleId <<5>>, quality <<6>>", stackSize, sellPrice, locked, equipType, itemStyleId, quality))
	itemType, sItemType = GetItemType(bagId, slotId)
	if itemType == ITEMTYPE_ARMOR and (equipType == EQUIP_TYPE_RING or equipType == EQUIP_TYPE_NECK) then 
		sItemType = equipType
	
	elseif itemType == ITEMTYPE_TREASURE and settings[ITEMTYPE_TREASURE][SPECIALIZED_ITEMTYPE_TREASURE] then
		for i=1, GetItemLinkNumItemTags(itemLink) do
			local itemTagDescription, itemTagCategory = GetItemLinkItemTagInfo(itemLink, i)
			if matchesCrowStrings(tag) then sItemType = SPECIALIZED_ITEMTYPE_MIN_VALUE end
		end
	end	
end

local function tryOutputQueues(queue, isSelling)
	
	local outputString = ""
	local didOutputPrefix = false
	
	local function output(aString)
		if not didOutputPrefix then 
			aString = ((isSelling and "Sold ") or "Laundered ") .. aString
			didOutputPrefix = true
		end		
		d("|cffffff" ..aString:sub(0, -3) .. "|r")
	end
	
	local function checkStringOverflow()
		if #outputString > 300 then 
			output(outputString)
			outputString = ""
		end		
	end
	
	local comma = ", "
	if nil ~= queue and #queue > 0 then 
		for index, itemLink in pairs(queue) do
			outputString = string.format("%s%s%s", outputString, itemLink, comma)
			-- outputString = outputString ..  itemLink .. ", "	
			checkStringOverflow()
		end
		if #outputString > 0 then
			output(outputString)
		end
	end	
	queue = {}	
	
end
local numSales, numUsed
local function printFenceLimits()

	numSales, numUsed = GetFenceSellTransactionInfo()
	local numLaunders, numLaundered =  GetFenceLaunderTransactionInfo()
	d(zo_strformat("AutoProcessStolenItems: <<1>> sales / <<2>> launders left", numSales - numUsed, numLaunders - numLaundered))
end


local function onFenceClose()
	EVENT_MANAGER:UnregisterForEvent("AutoProcessStolenItems_OnFenceClose", EVENT_CLOSE_STORE, onFenceClose)
	printFenceLimits()
end


SLASH_COMMANDS["/fencelimits"] = printFenceLimits

local function onFence()
	
	EVENT_MANAGER:RegisterForEvent("AutoProcessStolenItems_OnFenceClose", EVENT_CLOSE_STORE, onFenceClose)
	
	local numSales, numUsed = GetFenceSellTransactionInfo()
	
	task:Call(function()
			
		outputQueueLaunder 	= {}
		outputQueueSell 	= {}
	
		if numUsed < numSales then 
		local slotId = 0
		local bagId = BAG_BACKPACK
		local numBagSlots = GetBagSize(bagId)
	
			for slotId = 0, numBagSlots do 
				if IsItemStolen(bagId, slotId) and getValue(bagId, slotId, false)  then
					setLocalVarsForItem(bagId, slotId)
					fenceStolenItem(bagId, slotId)			
				end
			end
		end
	end)
		
	:Then(function() 
		tryOutputQueues(outputQueueLaunder, false)
	end):Then(function() 
		tryOutputQueues(outputQueueSell, 	true)
	end)
	
end

local function onInventorySlotUpdate(eventCode, bagId, slotId, isNewItem, itemSoundCategory, inventoryUpdateReason, stackCountChange)
	if not IsItemStolen(bagId, slotId) then return end
	if locked or (nil ~= FCOIS and FCOIS.IsLocked(bagId, slotId)) then return end
	setLocalVarsForItem(bagId, slotId)
	local quality = getQuality(bagId, slotId, true)
	local value = getValue(bagId, slotId, true)
	
	if not (getValue(bagId, slotId, true) and getQuality(bagId, slotId, true)) then return end
	
	DestroyItem(bagId, slotId) 
	PlaySound(SOUNDS.INVENTORY_ITEM_JUNKED)
	
	if settings.destroy.shutit then return end
	d(zo_strformat("|cffffffDestroying <<1>>x|r <<2>>", GetSlotStackSize(bagId, slotId), GetItemLink(bagId, slotId)))
	
end

function AutoProcessStolenItems.registerForTrashing(active)
	if active then
		EVENT_MANAGER:RegisterForEvent("AutoProcessStolenItems_OnLoot", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, onInventorySlotUpdate)
	else
		EVENT_MANAGER:UnregisterForEvent("AutoProcessStolenItems_OnLoot", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, onInventorySlotUpdate)
	end
end

local function OnLoad(eventCode, name)

	if name ~= "AutoProcessStolenItems" then return end	
	
	
	AutoProcessStolenItems.savedVars = ZO_SavedVars:New("AutoProcessStolenItems_SavedVariables", 1, nil, defaults)
	settings = AutoProcessStolenItems.savedVars
	AutoProcessStolenItems.CreateSettingsMenu(defaults)
	
	EVENT_MANAGER:RegisterForEvent("AutoProcessStolenItems_OnFence", EVENT_OPEN_FENCE, onFence)
	
	AutoProcessStolenItems.registerForTrashing(AutoProcessStolenItems.savedVars.destroy.active)
	
	EVENT_MANAGER:UnregisterForEvent("AutoProcessStolenItems", EVENT_ADD_ON_LOADED)
	
end

EVENT_MANAGER:RegisterForEvent("AutoProcessStolenItems_OnLoad", EVENT_ADD_ON_LOADED, OnLoad)