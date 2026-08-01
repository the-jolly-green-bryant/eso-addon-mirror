local AdvancedSmartAutoLoot = ZO_Object:Subclass()
AdvancedSmartAutoLoot.db = nil
AdvancedSmartAutoLoot.config = nil
local CBM = CALLBACK_MANAGER
local Config = AdvancedSmartAutoLootSettings
AdvancedSmartAutoLoot.StartupInfo = false
local defaults = 
{
	allowDestroy = false,
	closeLootWindow = false,
	enabled = true,
	filters = {	armor = "Always loot",
		collectibles = "Always loot",
		costumes = "Always loot",
		craftingMaterials = "Always loot",
		foodAndDrink = "Always loot",
		fishingBait = "Always loot",
		furnitureCraftingMaterials = "Always loot",
		glyphs = "Always loot",
		ingredients = "Always loot",
		intricate = "Always loot",
		itemTrash = "Always loot",
		itemTreasure = "Always loot",
		ornate = "Always loot",
		poisons = "Always loot",
		potions = "Always loot",
		recipes = "Always loot",
		soulGems = "Always loot",
		styleMaterials = "Always loot",
		tools = "Always loot",
		weapons = "Always loot",
	},
	minimumQuality = 1,
	minimumValue = 0,	
	printItems = false
}

function AdvancedSmartAutoLoot:New( ... )
	local result =  ZO_Object.New( self )
	result:Initialize( ... )
	return result
end

function AdvancedSmartAutoLoot:Initialize( control )
	self.control = control
    self.control:RegisterForEvent( EVENT_ADD_ON_LOADED, function( ... ) self:OnLoaded( ... ) end )
    CBM:RegisterCallback( Config.EVENT_TOGGLE_AUTOLOOT, function() self:ToggleAutoLoot()    end )
end

function AdvancedSmartAutoLoot:OnLoaded( event, addon )
	if addon ~="AdvancedSmartAutoLoot" then 
		return
	end
	self.db = ZO_SavedVars:New( 'AdvancedSmartAutoLootSavedVariables', 1, nil, defaults )
    self.config = Config:New( self.db )

	if (self.db.allowDestroy) then 
		self.buttonDestroyRemaining = CreateControlFromVirtual("buttonDestroyRemaining", ZO_Loot, "BTN_DestroyRemaining")
	end
    self:ToggleAutoLoot()
end
function AdvancedSmartAutoLoot:LoadScreen()
	if (not AdvancedSmartAutoLoot.StartupInfo) then
		d( "|ceeeeeeAdvanced Smart AutoLoot, created by: |c226622" ..Config.originalAuthor.. "\n"
		 .."|ceeeeee       Updated and maintained by: " .."|c0040ff" ..Config.maintainer.. "|r" )
	end
	AdvancedSmartAutoLoot.StartupInfo = true
end

function AdvancedSmartAutoLoot:ToggleAutoLoot()
	if( self.db.enabled ) then
		self.control:RegisterForEvent(EVENT_LOOT_UPDATED, function( _, ... ) 
			self:OnLootUpdated()  
		end)
	else
		self.control:UnregisterForEvent( EVENT_LOOT_UPDATED )
	end
end


function AdvancedSmartAutoLoot:LootItem(link, lootId, quantity)
	LootItemById(lootId)
	if (self.db.printItems) then
		d("You looted "..link)
	end
end

function AdvancedSmartAutoLoot:DestroyItems()
	local count = GetNumLootItems()
	self.destroying = true
	self.control:RegisterForEvent(EVENT_INVENTORY_SINGLE_SLOT_UPDATE, function( _, ... ) self:OnInventoryUpdated( ... )  end)
	self.control:RegisterForEvent(EVENT_LOOT_CLOSED, function( _, ... ) self:OnLootClosed( ... )  end)
	for i = 1, count , 1 do
		local lootId,name,icon,quantity,quality,value,isQuest, isStolen = GetLootItemInfo(i)
		LootItemById(lootId)
	end	
end


function AdvancedSmartAutoLoot:OnInventoryUpdated(bagId, slotId, isNewItem, _, _)
	if (self.destroying and self.db.allowDestroy) then
		if (isNewItem) then
			local link = GetItemLink(bagId, slotId)
			if (self.db.allowDestroy) then 
				DestroyItem(bagId,slotId)
			end
		end
	end
end

function AdvancedSmartAutoLoot:OnLootClosed(eventCode)
	self.control:UnregisterForEvent( EVENT_INVENTORY_SINGLE_SLOT_UPDATE )
	self.control:UnregisterForEvent( EVENT_LOOT_CLOSED )
end

function AdvancedSmartAutoLoot:ShouldLootItem(filterTypeTreshold, quality, value, isStolen)

	if (filterTypeTreshold == nil) then
		return false
	elseif (filterTypeTreshold == "Always loot" or filterTypeTreshold == "default") then
		return true
	elseif (filterTypeTreshold == "Never loot") then
		return false
	elseif (filterTypeTreshold == "Only stolen" and isStolen) then
		return true
	elseif (filterTypeTreshold == "Only legal" and not isStolen) then
		return true
	elseif (filterTypeTreshold == "Per quality threshold" and quality >= self.db.minimumQuality) then
		return true
	elseif (filterTypeTreshold == "Per value threshold" and value >= self.db.minimumValue) then
		return true
	elseif (filterTypeTreshold == "Per quality or value") then
		if (quality >= self.db.minimumQuality or value >= self.db.minimumValue) then
			return true
		end
	elseif (filterTypeTreshold == "Per quality and value") then
		if (quality >= self.db.minimumQuality and value >= self.db.minimumValue) then
			return true
		end
	end
	
	return false

end

function AdvancedSmartAutoLoot:OnLootUpdated(numId)

	LootMoney()
	local count = GetNumLootItems()
	local itemLink = GetItemLink(bagId, slotIndex)

	for i = 1, count , 1 do
		local lootId, name, icon, quantity, quality, value, isQuest, isStolen = GetLootItemInfo(i)
		local link = GetLootItemLink(lootId)
		local itemType = GetItemLinkItemType(link)
		local itemTraitType = GetItemLinkTraitInfo(link)

		if ((not isStolen) or (self.db.lootStolen)) then
			-- If it is a quest item we want it no matter what
			if (isQuest) then
				self:LootItem(link, lootId, quantity)
			end

			if (itemTraitType == ITEM_TRAIT_TYPE_ARMOR_ORNATE or itemTraitType == ITEM_TRAIT_TYPE_JEWELRY_ORNATE or itemTraitType == ITEM_TRAIT_TYPE_WEAPON_ORNATE) then
				if (self:ShouldLootItem(self.db.filters.ornate, quality, value, isStolen)) then
					self:LootItem(link, lootId, quantity)
				end
			elseif (itemTraitType == ITEM_TRAIT_TYPE_ARMOR_INTRICATE or itemTraitType == ITEM_TRAIT_TYPE_JEWELRY_INTRICATE or itemTraitType == ITEM_TRAIT_TYPE_WEAPON_INTRICATE) then
				if (self:ShouldLootItem(self.db.filters.intricate, quality, value, isStolen)) then
					self:LootItem(link, lootId, quantity)
				end
			elseif (itemType == ITEMTYPE_TRASH) then
				if (self:ShouldLootItem(self.db.filters.itemTrash, quality, value, isStolen)) then
					self:LootItem(link, lootId, quantity)
				end
			elseif (itemType == ITEMTYPE_TREASURE) then
				if (self:ShouldLootItem(self.db.filters.itemTreasure, quality, value, isStolen)) then
					self:LootItem(link, lootId, quantity)
				end	
			elseif (itemType == ITEMTYPE_INGREDIENT or itemType == ITEMTYPE_FLAVORING or itemType == ITEMTYPE_SPICE) then
				if (self:ShouldLootItem(self.db.filters.ingredients, quality, value, isStolen)) then
					self:LootItem(link, lootId, quantity)
				end
			elseif (itemType == ITEMTYPE_FURNISHING_MATERIAL) then
				if (self:ShouldLootItem(self.db.filters.furnitureCraftingMaterials, quality, value, isStolen)) then
					self:LootItem(link, lootId, quantity)
				end
			elseif (itemType == ITEMTYPE_RECIPE) then
				if (self:ShouldLootItem(self.db.filters.recipes, quality, value, isStolen)) then
					self:LootItem(link, lootId, quantity)
				end
			elseif (itemType == ITEMTYPE_FOOD or itemType == ITEMTYPE_DRINK) then
				if (self:ShouldLootItem(self.db.filters.foodAndDrink, quality, value, isStolen)) then
					self:LootItem(link, lootId, quantity)
				end
			elseif (itemType == ITEMTYPE_POTION) then
				if (self:ShouldLootItem(self.db.filters.potions, quality, value, isStolen)) then
					self:LootItem(link, lootId, quantity)
				end
			elseif (itemType == ITEMTYPE_POISON) then
				if (self:ShouldLootItem(self.db.filters.poisons, quality, value, isStolen)) then
					self:LootItem(link, lootId, quantity)
				end
			elseif (itemType == ITEMTYPE_LURE) then
				if (self:ShouldLootItem(self.db.filters.fishingBait, quality, value, isStolen)) then
					self:LootItem(link, lootId, quantity)
				end
			elseif (itemType == ITEMTYPE_BLACKSMITHING_BOOSTER or itemType == ITEMTYPE_BLACKSMITHING_MATERIAL or itemType == ITEMTYPE_BLACKSMITHING_RAW_MATERIAL) then
				if (self:ShouldLootItem(self.db.filters.craftingMaterials, quality, value, isStolen)) then
					self:LootItem(link, lootId, quantity)
				end
			elseif (itemType == ITEMTYPE_CLOTHIER_BOOSTER or itemType == ITEMTYPE_CLOTHIER_MATERIAL or itemType == ITEMTYPE_CLOTHIER_RAW_MATERIAL) then
				if (self:ShouldLootItem(self.db.filters.craftingMaterials, quality, value, isStolen)) then
					self:LootItem(link, lootId, quantity)
				end
			elseif (itemType == ITEMTYPE_POTION_BASE or itemType == ITEM_TYPE_POISON_BASE or itemType == ITEMTYPE_REAGENT) then
				if (self:ShouldLootItem(self.db.filters.craftingMaterials, quality, value, isStolen)) then
					self:LootItem(link, lootId, quantity)
				end
			elseif (itemType == ITEMTYPE_ENCHANTING_RUNE_ASPECT or itemType == ITEMTYPE_ENCHANTING_RUNE_ESSENCE or itemType == ITEMTYPE_ENCHANTING_RUNE_POTENCY or itemType == ITEMTYPE_ENCHANTMENT_BOOSTER) then
				if (self:ShouldLootItem(self.db.filters.craftingMaterials, quality, value, isStolen)) then
					self:LootItem(link, lootId, quantity)
				end
			elseif (ItemType == ITEMTYPE_GLYPH_ARMOR or itemType == ITEMTYPE_GLYPH_JEWELRY or ItemType == ITEMTYPE_GLYPH_WEAPON or string.find(name, "Glyph")) then
				if(self:ShouldLootItem(self.db.filters.glyphs, quality, value, isStolen)) then
					self:LootItem(link, lootId, quantity)
				end
			elseif (itemType == ITEMTYPE_FISH) then
				if (self:ShouldLootItem(self.db.filters.craftingMaterials, quality, value, isStolen)) then
					self:LootItem(link, lootId, quantity)
				end
			elseif (itemType == ITEMTYPE_WOODWORKING_BOOSTER or itemType == ITEMTYPE_WOODWORKING_MATERIAL or itemType == ITEMTYPE_WOODWORKING_RAW_MATERIAL) then
				if (self:ShouldLootItem(self.db.filters.craftingMaterials, quality, value, isStolen)) then
					self:LootItem(link, lootId, quantity)
				end
			elseif (itemType == ITEMTYPE_RACIAL_STYLE_MOTIF or itemType == ITEMTYPE_RAW_MATERIAL or itemType == ITEMTYPE_STYLE_MATERIAL) then -- or itemType == ITEMTYPE_ENCHANTMENT_BOOSTER) then
				if (self:ShouldLootItem(self.db.filters.styleMaterials, quality, value, isStolen)) then
					self:LootItem(link, lootId, quantity)
				end
			elseif (itemType == ITEMTYPE_SOUL_GEM) then
				if (self:ShouldLootItem(self.db.filters.soulGems, quality, value, isStolen)) then
					self:LootItem(link, lootId, quantity)
				end
			elseif (itemType == ITEMTYPE_TOOL) then -- ITEMTYPE_LOCKPICK doesn't seem to work here!  Is it flagged wrong in the game?
				if (self:ShouldLootItem(self.db.filters.tools, quality, value, isStolen)) then
					self:LootItem(link, lootId, quantity)
				end
			elseif (itemType == ITEMTYPE_ARMOR) then
				if (self:ShouldLootItem(self.db.filters.armor, quality, value, isStolen)) then
					self:LootItem(link, lootId, quantity)
				end
			elseif (itemType == ITEMTYPE_WEAPON) then
				if (self:ShouldLootItem(self.db.filters.weapons, quality, value, isStolen)) then
					self:LootItem(link, lootId, quantity)
				end
			elseif (itemType == ITEMTYPE_COSTUME or itemType == ITEMTYPE_DISGUISE) then
				if (self:ShouldLootItem(self.db.filters.costumes, quality, value, isStolen)) then
					self:LootItem(link, lootId, quantity)
				end
			elseif (itemType == ITEMTYPE_COLLECTIBLE) then
				if (self:ShouldLootItem(self.db.filters.collectibles, quality, value, isStolen)) then
					self:LootItem(link, lootId, quantity)
				end
            else
				--d("Uncategorized item: "..link.. " looted")
				--d("itemType: " ..itemType)
				self:LootItem(link, lootId, quantity)
			end
		end
	end
	if (self.db.closeLootWindow) then
		EndLooting()
	end
end

function AdvancedSmartAutoLoot_Startup( self )
    _Instance = AdvancedSmartAutoLoot:New( self )
end

function AdvancedSmartAutoLoot_Destroy(self)
	_Instance:DestroyItems()
end

function AdvancedSmartAutoLoot:Reset()
end

EVENT_MANAGER:RegisterForEvent( "AdvancedSmartAutoLoot", EVENT_PLAYER_ACTIVATED  , AdvancedSmartAutoLoot.LoadScreen)
