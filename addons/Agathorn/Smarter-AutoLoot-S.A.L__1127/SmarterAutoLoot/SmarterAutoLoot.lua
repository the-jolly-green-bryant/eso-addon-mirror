local SmarterAutoLoot = ZO_Object:Subclass()
SmarterAutoLoot.db = nil
SmarterAutoLoot.config = nil
local CBM = CALLBACK_MANAGER
local Config = SmarterAutoLootSettings
SmarterAutoLoot.StartupInfo = false
SmarterAutoLoot.version = "1.8.0"
local defaults = 
{
	version = "1.8.0",
	enabled = true,
	printItems = false,
	closeLootWindow = false,
	minimumQuality = 1,
	minimumValue = 0,
	allowDestroy = false,
	filters = {
		craftingMaterials = "always loot"
	}
}

function SmarterAutoLoot:New( ... )
	local result =  ZO_Object.New( self )
	result:Initialize( ... )
	return result
end

function SmarterAutoLoot:Initialize( control )
	self.control = control
    self.control:RegisterForEvent( EVENT_ADD_ON_LOADED, function( ... ) self:OnLoaded( ... ) end )
    CBM:RegisterCallback( Config.EVENT_TOGGLE_AUTOLOOT, function() self:ToggleAutoLoot()    end )
end

function SmarterAutoLoot:OnLoaded( event, addon )
	if addon ~="SmarterAutoLoot" then 
		return
	end
	self.db = ZO_SavedVars:New( 'SAL_VARS', 1, nil, defaults )
    self.config = Config:New( self.db )

	if (self.db.allowDestroy) then 
		self.buttonDestroyRemaining = CreateControlFromVirtual("buttonDestroyRemaining", ZO_Loot, "BTN_DestroyRemaining")
	end
    self:ToggleAutoLoot()
	d("SmarterAutoLoot version "..self.db.version.." by Agathorn")
end
function SmarterAutoLoot:LoadScreen()
	if (not SmarterAutoLoot.StartupInfo) then
		d("|ceeeeeeSmarterAutoLoot by |c226622Agathorn |ceeeeee v"..SmarterAutoLoot.version.."|r")
	end
	SmarterAutoLoot.StartupInfo = true
end

function SmarterAutoLoot:ToggleAutoLoot()
	if( self.db.enabled ) then
		self.control:RegisterForEvent(EVENT_LOOT_UPDATED, function( _, ... ) self:OnLootUpdated( ... )  end)
	else
		self.control:UnregisterForEvent( EVENT_LOOT_UPDATED )
	end
end


function SmarterAutoLoot:LootItem(link, lootId, quantity)
	LootItemById(lootId)
	if (self.db.printItems) then
		d("You looted "..link)
	end
end

function SmarterAutoLoot:DestroyItems()
	local num = GetNumLootItems()
	self.destroying = true
	self.control:RegisterForEvent(EVENT_INVENTORY_SINGLE_SLOT_UPDATE, function( _, ... ) self:OnInventoryUpdated( ... )  end)
	self.control:RegisterForEvent(EVENT_LOOT_CLOSED, function( _, ... ) self:OnLootClosed( ... )  end)
	for i = 1, num , 1 do
		local lootId,name,icon,quantity,quality,value,isQuest, isStolen = GetLootItemInfo(i)
		-- d("Looting item to destroy..."..name)
		LootItemById(lootId)
	end	
	-- self.destroying = false
	-- EndLooting()
end


function SmarterAutoLoot:OnInventoryUpdated(bagId, slotId, isNewItem, _, _)
	-- d("OnInventoryUpdated")
	if (self.destroying and self.db.allowDestroy) then
		if (isNewItem) then
			local link = GetItemLink(bagId, slotId)
			-- d("Destroying "..link)
			if (self.db.allowDestroy) then 
				-- d("Actually destroying")
				DestroyItem(bagId,slotId)
			end
		end
	end
end

function SmarterAutoLoot:OnLootClosed(eventCode)
	-- d("OnLootClosed")
	self.control:UnregisterForEvent( EVENT_INVENTORY_SINGLE_SLOT_UPDATE )
	self.control:UnregisterForEvent( EVENT_LOOT_CLOSED )
end

function SmarterAutoLoot:ShouldLootItem(filterType, lootId, quality, value, isStolen)
	-- "always loot", "never loot", "only stolen", "only legal", "per quality threshold", "per value threshold", "per quality OR value", "per quality AND value"
	local link = GetLootItemLink(lootId)
	local info1 , sellPrice, usable, equipType, style = GetItemLinkInfo( link )
	local isOrnate = GetItemLinkTraitInfo(link) == ITEM_TRAIT_TYPE_ARMOR_ORNATE or GetItemLinkTraitInfo(link) == ITEM_TRAIT_TYPE_WEAPON_ORNATE
	local isIntricate = GetItemLinkTraitInfo(link) == ITEM_TRAIT_TYPE_ARMOR_INTRICATE or GetItemLinkTraitInfo(link) == ITEM_TRAIT_TYPE_WEAPON_INTRICATE
	local shouldBeLooted = false
	
	if (filterType == nil) then
		return false
	end
	
	-- d("checking shouldLootItem for "..filterType)
	
	if (filterType == "always loot") then
		return true
	end
	if (filterType == "never loot") then
		return false
	end

	if (filterType == "only stolen" and isStolen) then
		return true
	end
		
	if (filterType == "only legal" and not isStolen) then
		return true
	end
		
	if (filterType == "per quality threshold" and quality >= self.db.minimumQuality) then
		return true
	end
	if (filterType == "per value threshold" and value >= self.db.minimumValue) then
		return true
	end

	if (filterType == "per quality OR value") then
		if (quality >= self.db.minimumQuality or value >= self.db.minimumValue) then
			return true
		end
	end
	
	if (filterType == "per quality AND value") then
		if (quality >= self.db.minimumQuality and value >= self.db.minimumValue) then
			return true
		end
	end
	
	return false
end

function SmarterAutoLoot:OnLootUpdated(numId)
	-- d("SAL StartLooting")
	LootMoney()
	local num = GetNumLootItems()
	for i = 1, num , 1 do
		local lootId,name,icon,quantity,quality,value,isQuest, isStolen = GetLootItemInfo(i)
		-- d("Processing loot item: "..name)
		-- d("Quantity: "..quantity.." Quality: "..quality.." Value: "..value.." isQuest: "..tostring(isQuest).." isStolen: "..tostring(isStolen))
		local link = GetLootItemLink(lootId)
		local info1 , sellPrice, usable, equipType, style = GetItemLinkInfo( link )
		local isOrnate = GetItemLinkTraitInfo(link) == ITEM_TRAIT_TYPE_ARMOR_ORNATE or GetItemLinkTraitInfo(link) == ITEM_TRAIT_TYPE_WEAPON_ORNATE
		local isIntricate = GetItemLinkTraitInfo(link) == ITEM_TRAIT_TYPE_ARMOR_INTRICATE or GetItemLinkTraitInfo(link) == ITEM_TRAIT_TYPE_WEAPON_INTRICATE
		local shouldBeLooted = false
        -- d("got lootId: "..lootId)
        -- d("got link: "..link)
		-- d("got name: "..name)
		-- d("got type: "..tostring(GetItemLinkItemType(link)))
		-- Unfortunately Lua doesn't support a continue statement, or a switch statement, so this logic is uglier than it should be.  Lua sucks.
		if ((not isStolen) or (self.db.lootStolen)) then
			-- If it is a quest item we want it no matter what
			if (isQuest) then
				-- d("Looting quest item")
				self:LootItem(link, lootId, quantity)
			end

			local itemType = GetItemLinkItemType(link)
			-- d("ItemType: "..tostring(itemType))

			if (itemType == ITEMTYPE_INGREDIENT or itemType == ITEMTYPE_FLAVORING or itemType == ITEMTYPE_SPICE) then
				-- d("Link: "..link)
				-- d("ItemType: Ingredient")
				-- d("ItemType: Ingredient - Checking if it is for furniture")
				-- 114889 Regulus (Blacksmithing)
				-- 114890 Bast (Clothier, cloth)
				-- 114891 Clean Pelt (Clothier, leather)
				-- 114892 Mundane Rune (Enchanting)
				-- 114893 Alchemical Resin (Alchemy)
				-- 114894 Decorative Wax (Provisioning)
				-- 114895 Heartwood (Woodworking)
				if (name == "Regulus"
					or name == "Bast"
					or name == "Clean Pelt"
					or name == "Mundane Rune"
					or name == "Alchemical Resin"
					or name == "Decorative Wax"
					or name == "Heartwood") then 
					-- d("ItemType: furnitureCraftingMaterials")
					if (self:ShouldLootItem(self.db.filters.furnitureCraftingMaterials, lootId, quality, value, isStolen)) then
						-- d("Looting Furniture Crafting Material")
						self:LootItem(link, lootId, quantity)
					end
				elseif (self:ShouldLootItem(self.db.filters.ingredients, lootId, quality, value, isStolen)) then
					-- d("Looting Ingredient, Flavoring, or Spice")
					self:LootItem(link, lootId, quantity)
				end
			elseif (itemType == ITEMTYPE_RECIPE) then
				-- d("ItemType: Recipe")
				if (self:ShouldLootItem(self.db.filters.recipes, lootId, quality, value, isStolen)) then
					-- d("Looting Recipe")
					self:LootItem(link, lootId, quantity)
				end
			elseif (itemType == ITEMTYPE_FOOD or itemType == ITEMTYPE_DRINK) then
				-- d("ItemType: Food")
				if (self:ShouldLootItem(self.db.filters.foodAndDrink, lootId, quality, value, isStolen)) then
					-- d("Looting Food or Drink")
					self:LootItem(link, lootId, quantity)
				end
			elseif (itemType == ITEMTYPE_POTION) then
				-- d("ItemType: Potion")
				if (self:ShouldLootItem(self.db.filters.potions, lootId, quality, value, isStolen)) then
					-- d("Looting potion")
					self:LootItem(link, lootId, quantity)
				end
			elseif (itemType == ITEMTYPE_POISON) then
				-- d("ItemType: Poison")
				if (self:ShouldLootItem(self.db.filters.poisons, lootId, quality, value, isStolen)) then
					-- d("Looting potion")
					self:LootItem(link, lootId, quantity)
				end
			elseif (itemType == ITEMTYPE_LURE) then
				-- d("ItemType: Lure")
				if (self:ShouldLootItem(self.db.filters.fishingBait, lootId, quality, value, isStolen)) then
					-- d("Looting Bait")
					self:LootItem(link, lootId, quantity)
				end
			elseif (itemType == ITEMTYPE_BLACKSMITHING_BOOSTER or itemType == ITEMTYPE_BLACKSMITHING_MATERIAL or itemType == ITEMTYPE_BLACKSMITHING_RAW_MATERIAL) then
				-- d("ItemType: Blacksmithing Materials")
				if (self:ShouldLootItem(self.db.filters.craftingMaterials, lootId, quality, value, isStolen)) then
					-- d("Looting Blacksmith mats")
					self:LootItem(link, lootId, quantity)
				end
			elseif (itemType == ITEMTYPE_CLOTHIER_BOOSTER or itemType == ITEMTYPE_CLOTHIER_MATERIAL or itemType == ITEMTYPE_CLOTHIER_RAW_MATERIAL) then
				-- d("ItemType: Outfitter Materials")
				if (self:ShouldLootItem(self.db.filters.craftingMaterials, lootId, quality, value, isStolen)) then
					-- d("Looting Clothier mats")
					self:LootItem(link, lootId, quantity)
				end
			elseif (itemType == ITEMTYPE_POTION_BASE or itemType == ITEM_TYPE_POISON_BASE or itemType == ITEMTYPE_REAGENT) then
				-- d("ItemType: Alchemy Materials")
				if (self:ShouldLootItem(self.db.filters.craftingMaterials, lootId, quality, value, isStolen)) then
					-- d("Looting alchemy mats")
					self:LootItem(link, lootId, quantity)
				end
			elseif (itemType == ITEMTYPE_ENCHANTING_RUNE_ASPECT or itemType == ITEMTYPE_ENCHANTING_RUNE_ESSENCE or itemType == ITEMTYPE_ENCHANTING_RUNE_POTENCY or itemType == ITEMTYPE_ENCHANTMENT_BOOSTER) then
				-- d("ItemType: Enchanting Materials")
				if (self:ShouldLootItem(self.db.filters.craftingMaterials, lootId, quality, value, isStolen)) then
					-- d("Looting enchanting mats")
					self:LootItem(link, lootId, quantity)
				elseif (self:ShouldLootItem(self.db.filters.glyphs, lootId, quality, value, isStolen)) then
					-- d("Looting enchanting mats")
					self:LootItem(link, lootId, quantity)
				end
			elseif (itemType == ITEMTYPE_FISH) then
				-- d("ItemType: Fish")
				if (self:ShouldLootItem(self.db.filters.craftingMaterials, lootId, quality, value, isStolen)) then
					-- d("Looting fishing mats")
					self:LootItem(link, lootId, quantity)
				end
			elseif (itemType == ITEMTYPE_WOODWORKING_BOOSTER or itemType == ITEMTYPE_WOODWORKING_MATERIAL or itemType == ITEMTYPE_WOODWORKING_RAW_MATERIAL) then
				-- d("ItemType: Woodworking Materials")
				if (self:ShouldLootItem(self.db.filters.craftingMaterials, lootId, quality, value, isStolen)) then
					-- d("Looting woodworking mats")
					self:LootItem(link, lootId, quantity)
				end
			elseif (itemType == ITEMTYPE_RACIAL_STYLE_MOTIF or itemType == ITEMTYPE_RAW_MATERIAL or itemType == ITEMTYPE_STYLE_MATERIAL or itemType == ITEMTYPE_ENCHANTMENT_BOOSTER) then
				-- d("ItemType: Style Materials")
				if (self:ShouldLootItem(self.db.filters.styleMaterials, lootId, quality, value, isStolen)) then
					-- d("Looting mats")
					self:LootItem(link, lootId, quantity)
				end
			elseif (itemType == ITEMTYPE_SOUL_GEM) then
				-- d("ItemType: Soul Gems")
				if (self:ShouldLootItem(self.db.filters.soulGems, lootId, quality, value, isStolen)) then
					-- d("Looting soul gem")
					self:LootItem(link, lootId, quantity)
				end
			elseif (itemType == ITEMTYPE_TOOL) then -- ITEMTYPE_LOCKPICK doesn't seem to work here!  Is it flagged wrong in the game?
				-- d("ItemType: Tools")
				-- d("SAL itemType == ITEMTYPE_LOCKPICK")
				-- d("SAL: "..tostring(self.db.alwaysLootLockpicks))
				if (self:ShouldLootItem(self.db.filters.tools, lootId, quality, value, isStolen)) then
					self:LootItem(link, lootId, quantity)
				end
			elseif (itemType == ITEMTYPE_ARMOR) then
				-- d("ItemType: Armor")
				if (self:ShouldLootItem(self.db.filters.armor, lootId, quality, value, isStolen)) then
					self:LootItem(link, lootId, quantity)
				end
			elseif (itemType == ITEMTYPE_WEAPON) then
				-- d("ItemType: Weapon")
				if (self:ShouldLootItem(self.db.filters.weapons, lootId, quality, value, isStolen)) then
					self:LootItem(link, lootId, quantity)
				end
			elseif (itemType == ITEMTYPE_COSTUME or itemType == ITEMTYPE_DISGUISE) then
				-- d("ItemType: Costume")
				if (self:ShouldLootItem(self.db.filters.costumes, lootId, quality, value, isStolen)) then
					self:LootItem(link, lootId, quantity)
				end
			elseif (itemType == ITEMTYPE_COLLECTIBLE) then
				-- d("ItemType: Collectible")
				if (self:ShouldLootItem(self.db.filters.collectibles, lootId, quality, value, isStolen)) then
					self:LootItem(link, lootId, quantity)
				end
			else
				-- d("ItemType: Unknown")
				-- d("ItemType: "..tostring(itemType))
				if (isOrnate) then
					-- d("Item is Ornate")
					if (self:ShouldLootItem(self.db.filters.ornate, lootId, quality, value, isStolen)) then
						-- d("Looting Ornate item")
						self:LootItem(link, lootId, quantity)
					end
				elseif (isIntricate) then
					-- d("Item is Intricate")
					if (self:ShouldLootItem(self.db.filters.intricate, lootId, quality, value, isStolen)) then
						-- d("Looting Intricate item")
						self:LootItem(link, lootId, quantity)
					end
                elseif (value >= self.db.minimumValue) then
					self:LootItem(link, lootId, quantity)
				else
					if (quality >= self.db.minimumQuality) then
						-- d("Looting item with quality level "..quality)
						self:LootItem(link, lootId, quantity)
					end
				end
			end
		end

		if (shouldBeLooted) then
			self:LootItem(link, lootId, quantity)
		end
	end
	if (self.db.closeLootWindow) then
		EndLooting()
	end
end


function SmarterAutoLoot_Startup( self )
    _Instance = SmarterAutoLoot:New( self )
end

function SmarterAutoLoot_Destroy(self)
	-- d("Destroy Contents")
	_Instance:DestroyItems()
end

function SmarterAutoLoot:Reset()
end

EVENT_MANAGER:RegisterForEvent( "SmarterAutoLoot", EVENT_PLAYER_ACTIVATED  , SmarterAutoLoot.LoadScreen)
