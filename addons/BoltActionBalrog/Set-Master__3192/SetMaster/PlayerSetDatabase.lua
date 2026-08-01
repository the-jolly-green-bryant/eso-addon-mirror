PlayerSetDatabase = {}
local This = PlayerSetDatabase

This.ItemDatabase = This.ItemDatabase or {} -- ItemId  => {OwnerString => {BagId => ItemLink}}
This.BagCache = This.BagCache or {} -- BagId => {SlotIndex => ItemLink}
This.SetItemIds = This.SetItemIds or nil -- Reference to LibSet's GetAllSetItemIds()
This.IgnoredAccountBags = This.IgnoredAccountBags or {}
This.SlotChangedEvent = This.SlotChangedEvent or nil

-- {String Id => {Name = String, IgnoredBags = {BagId}, DateScanned = String}}
This.Characters = {}

-- {String SanitizedName => String Id}
local SanitizedCharacterNames = {}

local CharacterBagConsts = {BAG_BACKPACK, BAG_WORN}
local AccountBagConsts = {BAG_BANK, BAG_SUBSCRIBER_BANK}
local HouseBagConsts

function This:GetMegaserverTable()
	return self.ItemDatabase[GetWorldName()]
end

function This:GetMegaserverCharacters()
	return self.Characters[GetWorldName()]
end

function This:IsAccountBag(BagId)
	for _, AccountBagId in ipairs(AccountBagConsts) do
		if AccountBagId == BagId then
			return true
		end
	end
	
	return false
end

function This:IsHouseBag(BagId)
	return BagId >= BAG_HOUSE_BANK_ONE and BagId <= BAG_HOUSE_BANK_TEN
end

function This:IsCharacterBag(BagId)
	for _, CharacterBagId in ipairs(CharacterBagConsts) do
		if CharacterBagId == BagId then
			return true
		end
	end
	
	return false
end

local function SanitizeCharacterName(CharacterName)
	return string.gsub(CharacterName, "%^.*", "") 
end

function This.GetCharacterName(Character)
	return SanitizeCharacterName(Character.Name)
end

local function PopulateBagValues()
	HouseBagConsts = {}
	for HouseBankId in SetMasterGlobal.Range(BAG_HOUSE_BANK_ONE, BAG_HOUSE_BANK_TEN) do
		table.insert(HouseBagConsts, HouseBankId)
	end
end

local function AreItemLinksIdentical(Link1, Link2)
	-- We only compare fields that can be different between two items with the same ItemId.
	-- We don't compare fields that might change over the lifetime of an item like condition or enchant charge.
	-- If we did we wouldn't match selling item X if it took damage after we scanned it to our stored ItemLink.
	return GetItemLinkAppliedEnchantId(Link1) == GetItemLinkAppliedEnchantId(Link2)
		and GetItemLinkBindType(Link1) == GetItemLinkBindType(Link2)
		and GetItemLinkFinalEnchantId(Link1) == GetItemLinkFinalEnchantId(Link2)
		and GetItemLinkDyeIds(Link1) == GetItemLinkDyeIds(Link2)
		and GetItemLinkDyeStampId(Link1) == GetItemLinkDyeStampId(Link2)
		and GetItemLinkItemStyle(Link1) == GetItemLinkItemStyle(Link2)
		and GetItemLinkQuality(Link1) == GetItemLinkQuality(Link2)
		and GetItemLinkRequiredLevel(Link1) == GetItemLinkRequiredLevel(Link2)
		and GetItemLinkTraitType(Link1) == GetItemLinkTraitType(Link2)
end

function This:LoadCharacters()
	self.Characters[GetWorldName()] = {}
	local ServerCharacters = self:GetMegaserverCharacters()
	for CharacterIndex in SetMasterGlobal.Range(1, GetNumCharacters()) do
	local Name, _, _, _, _, _, CharacterId, _ = GetCharacterInfo(CharacterIndex)
		local CharacterData = {Name = Name, IgnoredBags = {}}
		ServerCharacters[CharacterId] = CharacterData
	end
end

function This:LoadAccountBagsIgnored()
	self.IgnoredAccountBags = SetMasterOptions:GetOptions().AccountBagsIgnored
end

function This.IsCharacterBagIgnored(Character, BagId)
	return Character.IgnoredBags[BagId] ~= nil
end

function This.IsAccountBagIgnored(BagId)
	return This.IgnoredAccountBags[BagId] ~= nil
end

function This:IsBagIgnored(BagId, OwnerString)
	local CharacterId = SanitizedCharacterNames[OwnerString]
	if CharacterId ~= nil then
		local CharacterData = self:GetMegaserverCharacters()[CharacterId]
		return self.IsCharacterBagIgnored(CharacterData, BagId)
	else
		return self.IsAccountBagIgnored(BagId)
	end
end

local function AddBagCacheEntry(BagId, SlotIndex, ItemLink)
	local AddOrGet = SetMasterGlobal.AddOrGetTableElement
	local BagCacheBag = AddOrGet(This.BagCache, BagId, {})
	BagCacheBag[SlotIndex] = ItemLink
end

function This:GetBagOwnerString(BagId)
	if self:IsAccountBag(BagId) then
		return SetMasterGlobal.GetAccountOwnerName()
	end
	if self:IsHouseBag(BagId) then
		return SetMasterGlobal.GetHouseOwnerName()
	end
	
	local CurrentCharacterId = GetCurrentCharacterId()
	local CurrentCharacter = self:GetMegaserverCharacters()[CurrentCharacterId]
	return self.GetCharacterName(CurrentCharacter)
end

function This:RemoveItem(BagId, SlotIndex, ItemLink)
	local ItemId = GetItemLinkItemId(ItemLink)
	local OwnerString = self:GetBagOwnerString(BagId)
	
	local bFoundItem = false
	local ServerTable = self:GetMegaserverTable()
	local ItemTable = ServerTable[ItemId]
	local ItemList = ItemTable[OwnerString][BagId]
	for KeyItr, ItemLinkItr in pairs(ItemList) do
		if AreItemLinksIdentical(ItemLinkItr.ItemLink, ItemLink) then
			table.remove(ItemList, KeyItr)
			
			if SetMasterGlobal.IsTableEmpty(ItemList) then
				ItemTable[OwnerString][BagId] = nil
			end
			if SetMasterGlobal.IsTableEmpty(ItemTable[OwnerString]) then
				ServerTable[ItemId][OwnerString] = nil
			end
			if SetMasterGlobal.IsTableEmpty(ItemTable) then
				ServerTable[ItemId] = nil
			end
			
			bFoundItem = true
			break
		end
	end
	if bFoundItem == false then
		d("SetMasterError: Couldn't find item to remove. BagId: " .. BagId .. ", SlotIndex: " .. SlotIndex .. ", " .. ItemLink)
	end
	
	self.BagCache[BagId][SlotIndex] = nil
end

local function StoreItemIfSetItem(ItemLink, BagId, SlotIndex, OwnerString)
	local bSet, SetName, SetId, NumBonuses, NumEquipped, MaxEquipped = LibSets.IsSetByItemLink(ItemLink)
	if bSet == false then
		return
	end
	
	local AddOrGet = SetMasterGlobal.AddOrGetTableElement
	local ItemId = GetItemLinkItemId(ItemLink)
	
	local ItemEntry = AddOrGet(PlayerSetDatabase:GetMegaserverTable(), ItemId, {})
	local OwnerEntry = AddOrGet(ItemEntry, OwnerString, {})
	local BagEntry = AddOrGet(OwnerEntry, BagId, {})
	table.insert(BagEntry, {ItemLink = ItemLink})
	
	AddBagCacheEntry(BagId, SlotIndex, ItemLink)
end

local function LoadBag(BagId, OwnerString)
	local BagSize = GetBagSize(BagId)
	if BagSize == 0 then
		return
	end
	
	for SlotIndex in SetMasterGlobal.Range(0, BagSize) do
		local ItemLink = GetItemLink(BagId, SlotIndex)
		StoreItemIfSetItem(ItemLink, BagId, SlotIndex, OwnerString)
	end
end

function This:OnItemAdded(BagId, SlotIndex)
	local NewItemLink = GetItemLink(BagId, SlotIndex)
	local OwnerString = self:GetBagOwnerString(BagId)
	StoreItemIfSetItem(NewItemLink, BagId, SlotIndex, OwnerString)
end

function This:OnItemRemoved(BagId, SlotIndex)
	local BagCacheBag = self.BagCache[BagId]
	if BagCacheBag == nil then
		return
	end
	
	local PreviousItemLink = BagCacheBag[SlotIndex]
	if PreviousItemLink == nil then
		return
	end
	
	self:RemoveItem(BagId, SlotIndex, PreviousItemLink)
end

function This:OnSlotChanged()
	if self.SlotChangedEvent ~= nil then
		self.SlotChangedEvent()
	end
end

function This:UpdateBagSlot(BagId, SlotIndex, StackCountChange)
	if self:IsCharacterBag(BagId) == false 
			and self:IsAccountBag(BagId) == false 
			and self:IsHouseBag(BagId) == false then
		return
	end
	
	if StackCountChange > 0 then
		self:OnItemAdded(BagId, SlotIndex)
	elseif StackCountChange < 0 then
		self:OnItemRemoved(BagId, SlotIndex)
	else
		-- We improved a weapon or equipped an item
		self:OnItemRemoved(BagId, SlotIndex)
		self:OnItemAdded(BagId, SlotIndex)
	end
	
	self:OnSlotChanged()
end

function This:OnInventorySlotUpdate(EventCode, BagId, SlotIndex, bNewItem, ItemSoundCategory, UpdateReason, StackCountChange)
	--d("OnInventorySlotUpdate... BagId: " .. BagId .. ", SlotIndex: " .. SlotIndex .. ", bNewItem: " .. SetMasterGlobal.BoolToString(bNewItem) .. ", StackCountChange: " .. StackCountChange)
	--d(GetItemLink(BagId, SlotIndex))
	self:UpdateBagSlot(BagId, SlotIndex, StackCountChange)
end

function This:ClearOwnerData(OwnerString)
	for _, ItemOwners in pairs(self:GetMegaserverTable()) do
		for ItemOwner, _ in pairs(ItemOwners) do
			if ItemOwner == OwnerString then
				ItemOwners[OwnerString] = nil
			end
		end
	end
end

function This:DeleteCharacter(CharacterName)
	self:ClearOwnerData(CharacterName)
	
	local ServerCharacters = self:GetMegaserverCharacters()
	for CharacterId, CharacterData in pairs(ServerCharacters) do
		if CharacterName == SanitizeCharacterName(CharacterData.Name) then
			d("Set Master deleted character: " .. CharacterName)
			ServerCharacters[CharacterId] = nil
			return
		end
	end
end

function This:LoadAccountBags()
	local AccountOwnerName = SetMasterGlobal.GetAccountOwnerName()
	self:ClearOwnerData(AccountOwnerName)
	
	for _, AccountBagId in ipairs(AccountBagConsts) do
		if self.IsAccountBagIgnored(AccountBagId) == false then
			LoadBag(AccountBagId, AccountOwnerName)
		end
	end
end

function This:LoadHouseBags()
	local HouseOwnerName = SetMasterGlobal.GetHouseOwnerName()
	self:ClearOwnerData(HouseOwnerName)
	
	for _, HouseBagId in ipairs(HouseBagConsts) do
		if self.IsAccountBagIgnored(HouseBagId) == false then
			LoadBag(HouseBagId, HouseOwnerName)
		end
	end
end

function This:LoadCurrentCharacterSetItems()
	local CurrentCharacterId = GetCurrentCharacterId()
	local CurrentCharacter = self:GetMegaserverCharacters()[CurrentCharacterId]
	if CurrentCharacter == nil then
		d("SetMaster Error: Unloaded character id: '" .. CurrentCharacterId .. "'")
		return
	end
	
	local SanitizedCharacterName = self.GetCharacterName(CurrentCharacter)
	
	self:ClearOwnerData(SanitizedCharacterName)
	
	for _, CharacterBagId in ipairs(CharacterBagConsts) do
		LoadBag(CharacterBagId, SanitizedCharacterName)
	end
	
	CurrentCharacter.DateScanned = SetMasterGlobal.GetDateDisplayString()
end

function This:Initialize()
	self.ItemDatabase = SetMasterOptions:GetOptions().ItemDatabase
	
	if self:GetMegaserverTable() == nil then
		self.ItemDatabase[GetWorldName()] = {}
	end
	
	local OldCharacters = SetMasterOptions:GetOptions().Characters
	if OldCharacters[GetWorldName()] == nil then
		OldCharacters[GetWorldName()] = {}
	end
	
	PopulateBagValues()
	
	self:LoadCharacters()
	
	local CurrentCharacterId = GetCurrentCharacterId()
	local CurrentMegaserver = GetWorldName()
	local CurrentCharacters = self:GetMegaserverCharacters()
	for CharacterId, CharacterData in pairs(OldCharacters[CurrentMegaserver]) do
		local NewCharacterEntry = CurrentCharacters[CharacterId]
		if NewCharacterEntry == nil then
			-- Delete any deleted character's data on our megaserver.
			self:ClearOwnerData(self.GetCharacterName(CharacterData))
		else
			if CharacterData.Name ~= NewCharacterEntry.Name then
				-- Character was renamed. Delete the old name's data.
				self:ClearOwnerData(self.GetCharacterName(CharacterData))
				
			elseif CharacterId ~= CurrentCharacterId then
				-- Copy the data from the old character entry that isn't rebuilt upon loading a different character
				NewCharacterEntry.DateScanned = CharacterData.DateScanned
				NewCharacterEntry.Megaserver = CharacterData.Megaserver
			end
			
			NewCharacterEntry.IgnoredBags = CharacterData.IgnoredBags
		end
	end
	
	-- Save characters from other megaservers
	for MegaserverName, ServerCharacters in pairs(OldCharacters) do
		if MegaserverName ~= CurrentMegaserver then
			self.Characters[MegaserverName] = ServerCharacters
		end
	end
	
	SetMasterOptions:GetOptions().Characters = self.Characters -- Save the new character list
	
	-- Save a lookup table from character name to character id.
	for CharacterId, CharacterData in pairs(CurrentCharacters) do
		local SanitizedName = self.GetCharacterName(CharacterData)
		SanitizedCharacterNames[SanitizedName] = CharacterId
	end
	
	self:LoadAccountBagsIgnored()
	
	self:LoadCurrentCharacterSetItems()
	self:LoadAccountBags()
	self.SetItemIds = LibSets.GetAllSetItemIds()
	
	-- House bags are only available inside of a house. Would be nice TODO: figure out how to register for entering a house.
	local OpenHouseStoreEventName = "OnOpenHouseStore"
	EVENT_MANAGER:RegisterForEvent( OpenHouseStoreEventName, EVENT_OPEN_BANK, function(EventCode, BagId)
		-- Check if the bank is a house storage chest. If it is, we must be in a house so the house banks are accessible.
		if SetMasterGlobal.TableContains(HouseBagConsts, BagId) then
			EVENT_MANAGER:UnregisterForEvent(OpenHouseStoreEventName, EVENT_OPEN_BANK)
			self:LoadHouseBags()
		end
	end)
	
	EVENT_MANAGER:RegisterForEvent( "OnInventorySlotUpdate", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, function(EventCode, BagId, SlotIndex, bNewItem, ItemSoundCategory, UpdateReason, StackCountChange)
		self:OnInventorySlotUpdate(EventCode, BagId, SlotIndex, bNewItem, ItemSoundCategory, UpdateReason, StackCountChange)
	end)
end


























