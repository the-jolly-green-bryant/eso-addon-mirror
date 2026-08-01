local LIB_IDENTIFIER = "LibSort"
assert(not LibSort, "\'" .. LIB_IDENTIFIER .. "\' has already been loaded")

local libSort = {}
--Global variable "LibSort"
LibSort = libSort

if not libSort.RegisteredCallbacks then libSort.RegisteredCallbacks = {} end
if not libSort.AddonOrder then libSort.AddonOrder = {} end
if not libSort.DefaultOrdersHigh then libSort.DefaultOrdersHigh = {} end
if not libSort.DefaultOrdersLow then libSort.DefaultOrdersLow = {} end
if not libSort.sortKeys then libSort.sortKeys = ZO_Inventory_GetDefaultHeaderSortKeys() end

-- Lookup Tables ---
local defaultType = {["isNumeric"] = 0, ["isBoolean"] = false, ["isString"] = ""}
local inventoryTypes = 
{
	[INVENTORY_BACKPACK] 	= ZO_PlayerInventoryBackpack,
	[INVENTORY_BANK] 		= ZO_PlayerBankBackpack,
	[INVENTORY_GUILD_BANK] 	= ZO_GuildBankBackpack
}

--- Utility functions ---

local function removeSpaces(name)
	return name:gsub(" ","")
end

local function makePrefix(name)
	return removeSpaces(name) .. "_"
end

function libSort:Debug(msg)
	if libSort.isDebugging then	
		d("[libSort]: "..msg) 	
	end
end

--- Arrow generation ---
function libSort:SetupArrows()	
	libSort.ItemSortBank = WINDOW_MANAGER:CreateControlFromVirtual("ItemSortBank", ZO_PlayerBankSortBy, "ZO_SortHeaderIcon")
	libSort.ItemSortBank:SetDimensions(16, 32)
	libSort.ItemSortBank:SetAnchor(RIGHT, ZO_PlayerBankSortByName, LEFT, -15)
	ZO_SortHeader_SetTooltip(libSort.ItemSortBank, "Sort", BOTTOMRIGHT, 0, 32)
	ZO_SortHeader_InitializeArrowHeader(libSort.ItemSortBank, "age", ZO_SORT_ORDER_DOWN)

	PLAYER_INVENTORY.inventories[INVENTORY_BANK].sortHeaders:AddHeader(ItemSortBank)

	libSort.ItemSortGuild = WINDOW_MANAGER:CreateControlFromVirtual("ItemSortGuild", ZO_GuildBankSortBy, "ZO_SortHeaderIcon")
	libSort.ItemSortGuild:SetDimensions(16, 32)
	libSort.ItemSortGuild:SetAnchor(RIGHT, ZO_GuildBankSortByName, LEFT, -15)
	ZO_SortHeader_SetTooltip(libSort.ItemSortGuild, "Sort", BOTTOMRIGHT, 0, 32)
	ZO_SortHeader_InitializeArrowHeader(libSort.ItemSortGuild, "age", ZO_SORT_ORDER_DOWN)

	PLAYER_INVENTORY.inventories[INVENTORY_GUILD_BANK].sortHeaders:AddHeader(ItemSortGuild)    
end

--- Main functions ---
function libSort:InjectKeys()	
	for addon, callbacks in pairs(self.RegisteredCallbacks) do
		for name, data in pairs(callbacks) do
			if not self.sortKeys[data.key] then 
				self.sortKeys[data.key] = {} 
				self.sortKeys[data.key][data.dataType] = true
			end	
		end
	end	
	self:ReOrderKeys()	
end

function libSort:ReOrderKeys()
	local first 
	local previous
	for i, addonName in ipairs(self.AddonOrder) do		
		if self.DefaultOrdersLow[addonName] then
			for _, name in ipairs(self.DefaultOrdersLow[addonName]) do
				local data = self.RegisteredCallbacks[addonName][name] 
				if data then -- we skip the ones we haven't registered yet
					first, previous = self:SetKeyOrder(first, previous, data)
				end
			end
		end
	end
	for i, addonName in ipairs(self.AddonOrder) do		
		if self.DefaultOrdersHigh[addonName] then
			for _, name in ipairs(self.DefaultOrdersHigh[addonName]) do
				local data = self.RegisteredCallbacks[addonName][name] 
				if data then -- we skip the ones we haven't registered yet
					first, previous = self:SetKeyOrder(first, previous, data)
				end
			end
		end					
	end
	self.sortKeys[previous].tiebreaker = "name"
	PLAYER_INVENTORY:ChangeSort("age", INVENTORY_BACKPACK, true)
	PLAYER_INVENTORY:ChangeSort("age", INVENTORY_BANK, true)
	PLAYER_INVENTORY:ChangeSort("age", INVENTORY_GUILD_BANK, true)
end

function libSort:SetKeyOrder(first, previous, data)
	if not first then 
		first = true 
		self.sortKeys["age"].tiebreaker = data.key
		self.sortKeys["age"].reverseTiebreakerSortOrder = nil
	else
		if previous then
			self.sortKeys[previous].tiebreaker = data.key					
		end
	end	
	return first, data.key
end

function libSort:ProcessInventory(inventoryType)		
	local container = inventoryTypes[inventoryType]
	if not container then return end
	for i, slot in ipairs(container.data) do
		-- slotType no longer exists, slotType determenes BACKPACK=2,PLAYERBANK=9,GUOLDBANK=10 
		-- replaced by bagID BACKPACK=1,PLAYERBANK=2,GUOLDBANK=3 
		-- local slotType, bag, index = slot.data.slotType, slot.data.bagId, slot.data.slotIndex
		local bag, index = slot.data.bagId, slot.data.slotIndex
		for addon, callbacks in pairs(self.RegisteredCallbacks) do
			for name, data in pairs(callbacks) do
				if not slot.data[data.key] then
					slot.data[data.key] = data.func(bag, index) or defaultType[data.dataType]
				end
			end
		end		
	end	
end

function libSort:Loaded(event, name)
   	if name ~= "ZO_Ingame" then return end   
   
	ZO_PreHook(PLAYER_INVENTORY, "ApplySort", function(self, inventoryType) libSort:ProcessInventory(inventoryType) end)
	libSort:SetupArrows()

	EVENT_MANAGER:UnregisterForEvent("libSortLoaded", EVENT_ADD_ON_LOADED)
end

EVENT_MANAGER:RegisterForEvent("libSortLoaded", EVENT_ADD_ON_LOADED, function(...) libSort:Loaded(...) end)

--------- API ---------

function libSort:Unregister(addonName, name)
	if not name then 
		self.RegisteredCallbacks[addonName] = nil
		self.DefaultOrdersHigh[addonName] = nil
		self.DefaultOrdersLow[addonName] = nil
		return
	end

	if self.RegisteredCallbacks[addonName] then
		self.RegisteredCallbacks[addonName][name] = nil
	end
end

function libSort:Register(addonName, name, desc, key, func, dataType)	
	if not dataType then dataType = "isNumeric" end
	


	if not self.RegisteredCallbacks[addonName] then 
		self.RegisteredCallbacks[addonName] = {} 
		table.insert(self.AddonOrder, addonName) 
	end

	self.RegisteredCallbacks[addonName][name] = {key = makePrefix(addonName)..key, func = func, desc = desc, dataType = dataType}

	if not self.DefaultOrdersHigh[addonName] then self.DefaultOrdersHigh[addonName] = {} end

	table.insert(self.DefaultOrdersHigh[addonName], name)
	self:InjectKeys()
end

function libSort:RegisterNumeric(addonName, name, desc, key, func)
	self:Register(addonName, name, desc, key, func, "isNumeric")
end

function libSort:RegisterBoolean(addonName, name, desc, key, func)
	self:Register(addonName, name, desc, key, func, "isBoolean")
end

function libSort:RegisterString(addonName, name, desc, key, func)
	self:Register(addonName, name, desc, key, func, "isString")
end

function libSort:RegisterDefaultOrder(addonName, keyTableLow, keyTableHigh)
	self.DefaultOrdersHigh[addonName] = keyTableHigh
	self.DefaultOrdersLow[addonName] = keyTableLow
	self:ReOrderKeys()
end
