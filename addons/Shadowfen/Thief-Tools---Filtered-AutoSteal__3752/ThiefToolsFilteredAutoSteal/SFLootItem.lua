local SF = LibSFUtils

-- SFInvItem is a cut-down and modified version of my LibSFInventory library 
-- designed for use with Thief Tools, but was never released.

SFInvItem = {}
local LootItem = SFInvItem

function SFInvItem:NewLootIndex(ndx)
	local o = {}
    setmetatable(o, self)
    self.__index = self
	o.lootId, o.name, o.icon, o.quantity, o.quality, o.value, o.isQuest, o.isStolen, o.lootType = GetLootItemInfo(ndx)
	o.link = GetLootItemLink(o.lootId)
	o.itemId = GetItemLinkItemId(o.link)
    o.itemType, o.specializedItemType = GetItemLinkItemType(o.link)
    o.equipType = GetItemLinkEquipType(o.link) 
	o.filterType = GetItemLinkFilterTypeInfo(o.link)
	if o:isGear() then
		o.trait = GetItemLinkTraitInfo(o.link)
		o:GetSetInfo()
		if o.hasSet then
			o.isCollected = IsItemSetCollectionPieceUnlocked(o.itemId)
		end
		o.canBeResearched = CanItemLinkBeTraitResearched(o.link)
		o.isOrnate = ( o.trait == ITEM_TRAIT_TYPE_ARMOR_ORNATE 
					or o.trait == ITEM_TRAIT_TYPE_WEAPON_ORNATE 
					or o.trait == ITEM_TRAIT_TYPE_JEWELRY_ORNATE)
		o.isIntricate = ( o.trait == ITEM_TRAIT_TYPE_ARMOR_INTRICATE 
					   or o.trait == ITEM_TRAIT_TYPE_WEAPON_INTRICATE 
					   or o.trait == ITEM_TRAIT_TYPE_JEWELRY_INTRICATE)
	end
	return o
end

function SFInvItem:NewLink(link)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    
    o.link = link
    o.itemType, o.specializedItemType = GetItemLinkItemType(o.link)
	o.itemId = GetItemLinkItemId(o.link)
    o.equipType = GetItemLinkEquipType(o.link)    
	o.filterType = GetItemLinkFilterTypeInfo(o.link)
	
	o:isGear()
	if o.isknownGear then
		o.trait = GetItemLinkTraitInfo(o.link)
		o:GetSetInfo()
		if o.hasSet then
			o.isCollected = IsItemSetCollectionPieceUnlocked(o.itemId)
		end
		o.canResearch = CanItemLinkBeTraitResearched(o.link)
		o.isOrnate = ( o.trait == ITEM_TRAIT_TYPE_ARMOR_ORNATE 
					or o.trait == ITEM_TRAIT_TYPE_WEAPON_ORNATE 
					or o.trait == ITEM_TRAIT_TYPE_JEWELRY_ORNATE)
		o.isIntricate = ( o.trait == ITEM_TRAIT_TYPE_ARMOR_INTRICATE 
						or o.trait == ITEM_TRAIT_TYPE_WEAPON_INTRICATE 
						or o.trait == ITEM_TRAIT_TYPE_JEWELRY_INTRICATE)
	end
	return o
end


function SFInvItem:PrintDebug()
	d(SF.str("got name: ", SF.ColorText(self.name, SF.hex.blue)))
	d(SF.str("got lootId: ", self.lootId))
	d(SF.str("link: ", self.link))
	d(SF.str("itemType: ", self.itemType))
	d(SF.str("lootType: ", self.lootType))
	d(SF.str("filter_type ", self.filterType))
	d(SF.str("itemId: ", self.itemId))
	d(SF.str("isGear : ", self:isGear()))
	if self.hasSet then
		d(SF.str("is set item: ", self.hasSet))
		d(SF.str("set item unlocked ", IsItemSetCollectionPieceUnlocked(self.itemId)))
		d(SF.str("is collected: ", self.isCollected))
	end
	if self.isknownGear then
		local canResearch = self:canResearch()
		d(SF.str("canResearch : ", canResearch))
		d(SF.str("isJewelry : ", isJewelry))
	end
	if self.itemType == ITEMTYPE_RECIPE then
		d(SF.str("alreadyCollectedRecipe : ", IsItemLinkRecipeKnown(self.link)))
	end
	if self.itemType == ITEMTYPE_RACIAL_STYLE_MOTIF then
		d(SF.str("alreadyCollectedMotif : ", IsItemLinkRecipeKnown(self.link)))
	end
	local suggested, av, mint, maxt = self:getTTCPrice()
	if suggested then
		d(SF.str("  TTC suggested price: ", suggested))
		d(SF.str("  TTC average price: ", av))
	end
end

function SFInvItem:Print()
	d(SF.str("link ", self.link))
	d(SF.str("itemType ", self.itemType))
	d(SF.str("specializedItemType ", self.specializedItemType))
	d(SF.str("itemId ", self.itemId))
	d(SF.str("filterType ", self.filterType))
	d(SF.str("equipType ", self.equipType))
	self:Name()
	d(SF.str("Name ", self.myname))
	d("isGear: "..SF.str(self:isGear()))
end

-- returns the raw name and formatted name of the item (or nil, nil)
function SFInvItem:Name()
    if self.rawName == nil  then
        --  only look it up once
        self.myname = nil
        self.rawName = GetItemLinkName(self.link)
        if self.rawName  then
            self.myname = zo_strformat(SI_TOOLTIP_ITEM_NAME, self.rawName)
        end
    end
    return self.rawName, self.myname
end

function SFInvItem:GetUniqueId()
    return self.uniqueId
end

function SFInvItem:GetItemLink()
    return self.link
end

-- returns icon, stackCount, sellPrice, meetsUsageRequirement, locked, equipType, itemStyle, quality
-- if it is a link-only item, then stackCount and locked are always nil
function SFInvItem:GetItemInfo()
    -- only look it up once
    if self.meetsUsageRequirement == nil  then
		self.icon, self.sellPrice, self.meetsUsageRequirement, _, self.itemStyle = GetItemLinkInfo(self.link)
		self.quality = GetItemLinkQuality(self.link)
    end
    return self.icon, self.stackCount, self.sellPrice, self.meetsUsageRequirement, self.locked, self.equipType, self.itemStyle, self.quality
end

function SFInvItem:GetQuality()
    if self.quality == nil  then
        self.GetItemInfo()
    end
    return self.quality
end

-- returns itemType, specializedItemType
function SFInvItem:GetItemType()
	 return self.itemType, self.specializedItemType
end

function SFInvItem:GetEquipType()
    return self.equipType
end

function SFInvItem:GetSellPrice()
    if self.sellPrice == nil  then
        self.GetItemInfo()
    end
    return self.sellPrice
end

function SFInvItem:GetFormattedItemLink()
  return zo_strformat("<<t:1>>", self.link)
end

function SFInvItem:GetTraitInfo()
    if not self.isknownGear then return false end
    if self.itemTrait == nil  then
        -- always ignore traitDescription
        self.itemTrait, _ = GetItemLinkTraitInfo(self.link)
    end
    return self.itemTrait
end

function SFInvItem:isUnique()
    if self.unique == nil  then
      self.unique = IsItemLinkUnique(self.link)
    end
    return self.unique
end

function SFInvItem:GetArmorType()
    if not self.isknownGear then return nil end
    if self.armorType == nil  then
        self.armorType = GetItemLinkArmorType(self.link)
    end
    return self.armorType 
end

function SFInvItem:GetWeaponType()
    if not self.isknownGear then return nil end
    if self.weaponType == nil  then
        self.weaponType = GetItemLinkWeaponType(self.link)
    end
    return self.weaponType 
end

function SFInvItem:GetItemStyle()
    if not self.isknownGear then return nil end
    if self.itemStyle == nil  then
        self.itemStyle = GetItemLinkItemStyle(self.link)
    end
    return self.itemStyle 
end

function SFInvItem:GetSetInfo()
    if not self:isGear() then return false end
	
    if self.hasSet == nil then
      local lsetName
      self.hasSet, lsetName, _, self.maxEquip = GetItemLinkSetInfo(self.link)
      if self.hasSet  then
          --fix german language issue
          self.setName = string.gsub( lsetName , "%^.*", "")
      end
    end
    return self.hasSet, self.setName, self.maxEquip
end

function SFInvItem:IsMonsterSet()
    if not self.isknownGear then return false end
    if self.hasSet == nil  then
        self:GetSetInfo()
    end
    if self.hasSet == false then
        return false
    end
    if self.maxEquip > 2 then
        return false
    end
    return true
end

function SFInvItem:isCompanionGear()
	if not self:isGear() then return false end
	if self.isknownCompanionGear == nil then
		local actorCategory = GetItemLinkActorCategory(self.link)
		self.isknownCompanionGear = actorCategory == GAMEPLAY_ACTOR_CATEGORY_COMPANION
	end
	return self.isknownCompanionGear
end

-- only matches against weapons and armor
function SFInvItem:isGear()
	if self.isknownGear == nil then
		self.isknownGear = (self.itemType == ITEMTYPE_WEAPON or self.itemType == ITEMTYPE_ARMOR)
	end
	return self.isknownGear
end

function SFInvItem:isJewelry()
	if self.filterType == ITEMFILTERTYPE_JEWELRY then
		return true
	end
    return false
end

function SFInvItem:isStolen()
	-- value is set by the constructor
	return self.isStolen
end

function SFInvItem:canResearch()
    if not self:isGear() then return false end
	if self.canBeResearched == nil then
		self.canBeResearched = CanItemLinkBeTraitResearched(self.link)
	else
		self.canBeResearched = false
	end
	return self.canBeResearched
end

function SFInvItem:getTTCPrice()
	if TamrielTradeCentre then
		--d(SF.str("Getting TTC price info for ", self.name))
		local priceInfo = TamrielTradeCentrePrice:GetPriceInfo(self.link)
		if priceInfo then 
			--d(SF.str("TTC price info: ", priceInfo.SuggestedPrice, " - ", priceInfo.Avg, " - ", priceInfo.Min, " - ", priceInfo.Max))
			self.TTCSuggested = priceInfo.SuggestedPrice
			self.TTCAvg = priceInfo.Avg
			return priceInfo.SuggestedPrice, priceInfo.Avg, priceInfo.Min, priceInfo.Max
		end
	end
	-- not available
	return  

end

function SFInvItem:isMat()
	if self.filterType == ITEMFILTERTYPE_ALCHEMY then return true end
	if self.filterType == ITEMFILTERTYPE_BLACKSMITHING then return true end
	if self.filterType == ITEMFILTERTYPE_CLOTHING then return true end
	if self.filterType == ITEMFILTERTYPE_CRAFTING then return true end
	if self.filterType == ITEMFILTERTYPE_ENCHANTING then return true end
	if self.filterType == ITEMFILTERTYPE_JEWELRYCRAFTING then return true end
	if self.filterType == ITEMFILTERTYPE_PROVISIONING then return true end
	if self.filterType == ITEMFILTERTYPE_STYLE_MATERIALS then return true end
	if self.filterType == ITEMFILTERTYPE_TRAIT_ITEMS then return true end
	if self.filterType == ITEMFILTERTYPE_WOODWORKING then return true end
	return false
end


