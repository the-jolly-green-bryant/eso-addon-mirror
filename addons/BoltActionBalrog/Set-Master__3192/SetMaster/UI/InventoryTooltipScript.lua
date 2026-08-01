InventoryTooltipScript = InventoryTooltipScript or {}
local This = InventoryTooltipScript

This.VanillaTooltip = This.VanillaTooltip or nil
This.VanillaCompareTooltip = This.VanillaCompareTooltip or nil
This.VanillaCompareTooltip2 = This.VanillaCompareTooltip2 or nil
This.MouseOverInstigator = This.MouseOverInstigator or nil -- The most recent control that we moused over to show the tooltip
This.Tooltip = This.Tooltip or nil
This.ItemLink = This.ItemLink or nil
This.ItemLinkSetId = This.ItemLinkSetId or nil
This.bHidden = This.bHidden or true
This.HoverTooltip = This.HoverTooltip or nil

This.SetInfo = This.SetInfo or nil -- {EquipType => Count = #, Traits = {Trait (#) => {Count = #, Items = {}}}}

-- Elements with dynamic information
This.UniqueSetCountElement = This.UniqueSetCountElement or nil

-- Dynamicly created elements
This.SetPieceEntries = This.SetPieceEntryKeys or {} -- Pool key -> UI Element
This.SetPieceEntryPool = This.SetPieceEntryPool or nil
This.TraitEntries = This.TraitEntries or {}
This.TraitEntryPool = This.TraitEntryPool or nil
This.SpacerPool = This.SpacerPool or nil
This.TraitSpacerPool = This.SpacerPool or nil
This.TraitPopupItemEntries = This.TraitPopupItemEntries or {}
This.TraitPopupItemEntryPool = This.TraitPopupItemEntryPool or nil
This.TraitPopupOwnerEntries = This.TraitPopupOwnerEntries or {}
This.TraitPopupOwnerEntryPool = This.TraitPopupOwnerEntryPool or nil
This.TraitPopupBagEntries = This.TraitPopupBagEntries or {}
This.TraitPopupBagEntryPool = This.TraitPopupBagEntryPool or nil
This.TraitPopupQualityEntries = This.TraitPopupQualityEntries or {}
This.TraitPopupQualityEntryPool = This.TraitPopupQualityEntryPool or nil

This.TraitEntryItems = This.TraitEntryItems or {} -- Control -> {Item list}

This.TraitPopup = This.TraitPopup or {}

This.ParentElements = This.ParentElements or {}

-- Consts
This.ArmorSlots = This.ArmorSlots or {EQUIP_TYPE_HEAD, EQUIP_TYPE_CHEST, EQUIP_TYPE_LEGS, EQUIP_TYPE_FEET, EQUIP_TYPE_SHOULDERS, EQUIP_TYPE_HAND, EQUIP_TYPE_WAIST, EQUIP_TYPE_OFF_HAND}
This.JewelrySlots = This.JewelrySlots or {EQUIP_TYPE_NECK, EQUIP_TYPE_RING}

This.WeaponSlots = This.WeaponSlots or {EQUIP_TYPE_ONE_HAND, EQUIP_TYPE_TWO_HAND} -- Not displayed. Instead we use the sub-categories below:
This.OneHandedMeleeSlots = This.OneHandedMeleeSlots or {Slots = {WEAPONTYPE_AXE, WEAPONTYPE_HAMMER, WEAPONTYPE_SWORD}, Icon = "Esoui/Art/Icons/ability_dualwield_001.dds"}
This.TwoHandedMeleeSlots = This.TwoHandedMeleeSlots or {Slots = {WEAPONTYPE_TWO_HANDED_AXE, WEAPONTYPE_TWO_HANDED_HAMMER, WEAPONTYPE_TWO_HANDED_SWORD}, Icon = "Esoui/Art/Icons/ability_2handed_005.dds"}
This.DestructionStaffSlots = This.DestructionStaffSlots or {Slots = {WEAPONTYPE_FIRE_STAFF, WEAPONTYPE_FROST_STAFF, WEAPONTYPE_LIGHTNING_STAFF}, Icon = "Esoui/Art/Icons/ability_destructionstaff_012.dds"}
This.RestorationStaffSlots = This.RestorationStaffSlots or {Slots = {WEAPONTYPE_HEALING_STAFF}, Icon = "Esoui/Art/Icons/ability_restorationstaff_006.dds"}
This.BowSlots = This.BowSlots or {Slots = {WEAPONTYPE_BOW}}
This.DaggerSlots = This.DaggerSlots or {Slots = {WEAPONTYPE_DAGGER}}

This.WeaponTypeTables = This.WeaponTypeTables or {This.OneHandedMeleeSlots, This.TwoHandedMeleeSlots, This.DestructionStaffSlots, This.RestorationStaffSlots,
		This.BowSlots, This.DaggerSlots}
This.WeaponTypeDisplayIndicies = This.WeaponTypeDisplayIndicies or {} -- The internal display index of each weapon type (because we can't use the equip type).

This.WeaponIcons = This.WeaponIcons or {}
This.WeaponAbbreviations = This.WeaponAbbreviations or {}


This.EquipSlotsOrdered = This.EquipSlotsOrdered or {} -- The order to display item types on the tooltip
This.DisplayIndexToWeaponType = This.DisplayIndexToWeaponType or {}

This.IgnoredEquipTypes = {EQUIP_TYPE_INVALID, EQUIP_TYPE_COSTUME, EQUIP_TYPE_MAIN_HAND, EQUIP_TYPE_POISON}

This.ArmorTraitTypes = {ITEM_TRAIT_TYPE_NONE, ITEM_TRAIT_TYPE_ARMOR_STURDY, ITEM_TRAIT_TYPE_ARMOR_IMPENETRABLE, ITEM_TRAIT_TYPE_ARMOR_REINFORCED, ITEM_TRAIT_TYPE_ARMOR_WELL_FITTED, 
	ITEM_TRAIT_TYPE_ARMOR_TRAINING, ITEM_TRAIT_TYPE_ARMOR_INFUSED, ITEM_TRAIT_TYPE_ARMOR_PROSPEROUS, ITEM_TRAIT_TYPE_ARMOR_DIVINES, ITEM_TRAIT_TYPE_ARMOR_NIRNHONED}
This.JewelryTraitTypes = {ITEM_TRAIT_TYPE_NONE, ITEM_TRAIT_TYPE_JEWELRY_ARCANE, ITEM_TRAIT_TYPE_JEWELRY_HEALTHY, ITEM_TRAIT_TYPE_JEWELRY_ROBUST, ITEM_TRAIT_TYPE_JEWELRY_TRIUNE, 
	ITEM_TRAIT_TYPE_JEWELRY_INFUSED, ITEM_TRAIT_TYPE_JEWELRY_PROTECTIVE, ITEM_TRAIT_TYPE_JEWELRY_SWIFT, ITEM_TRAIT_TYPE_JEWELRY_HARMONY, ITEM_TRAIT_TYPE_JEWELRY_BLOODTHIRSTY}
This.WeaponTraitTypes = {ITEM_TRAIT_TYPE_NONE, ITEM_TRAIT_TYPE_WEAPON_POWERED, ITEM_TRAIT_TYPE_WEAPON_CHARGED, ITEM_TRAIT_TYPE_WEAPON_PRECISE, ITEM_TRAIT_TYPE_WEAPON_INFUSED, 
	ITEM_TRAIT_TYPE_WEAPON_DEFENDING, ITEM_TRAIT_TYPE_WEAPON_TRAINING, ITEM_TRAIT_TYPE_WEAPON_SHARPENED, ITEM_TRAIT_TYPE_WEAPON_DECISIVE, ITEM_TRAIT_TYPE_WEAPON_NIRNHONED}
	
							-- Normal, Fine, Superior, Epic, Legendary
This.QualityDisplayOrder = {ITEM_QUALITY_NORMAL, ITEM_QUALITY_MAGIC, ITEM_QUALITY_ARCANE, ITEM_QUALITY_ARTIFACT, ITEM_QUALITY_LEGENDARY}
This.QualityColor = {}
	
--Textures
This.TraitTextures = This.TraitTextures or {}

function This:InitializeTextureConsts()
	local TraitTextures = self.TraitTextures
	TraitTextures[ITEM_TRAIT_TYPE_NONE] = "/esoui/art/dye/gamepad/gp_disabled_x.dds"
	
	TraitTextures[ITEM_TRAIT_TYPE_ARMOR_STURDY] = "/esoui/art/icons/crafting_runecrafter_plug_component_002.dds"
	TraitTextures[ITEM_TRAIT_TYPE_ARMOR_IMPENETRABLE] = "/esoui/art/icons/crafting_jewelry_base_diamond_r3.dds"
	TraitTextures[ITEM_TRAIT_TYPE_ARMOR_REINFORCED] = "/esoui/art/icons/crafting_enchantment_base_sardonyx_r2.dds"
	TraitTextures[ITEM_TRAIT_TYPE_ARMOR_WELL_FITTED] = "/esoui/art/icons/crafting_accessory_sp_names_002.dds"
	TraitTextures[ITEM_TRAIT_TYPE_ARMOR_TRAINING] = "/esoui/art/icons/crafting_jewelry_base_emerald_r2.dds"
	TraitTextures[ITEM_TRAIT_TYPE_ARMOR_INFUSED] = "/esoui/art/icons/crafting_enchantment_baxe_bloodstone_r2.dds"
	TraitTextures[ITEM_TRAIT_TYPE_ARMOR_PROSPEROUS] = "/esoui/art/icons/crafting_jewelry_base_garnet_r3.dds"
	TraitTextures[ITEM_TRAIT_TYPE_ARMOR_DIVINES] = "/esoui/art/icons/crafting_accessory_sp_names_001.dds"
	TraitTextures[ITEM_TRAIT_TYPE_ARMOR_NIRNHONED] = "/esoui/art/icons/crafting_fortified_nirncrux_stone.dds"
	
	TraitTextures[ITEM_TRAIT_TYPE_JEWELRY_ARCANE] = "/esoui/art/icons/jewelrycrafting_trait_refined_cobalt.dds"
	TraitTextures[ITEM_TRAIT_TYPE_JEWELRY_HEALTHY] = "/esoui/art/icons/jewelrycrafting_trait_refined_antimony.dds"
	TraitTextures[ITEM_TRAIT_TYPE_JEWELRY_ROBUST] = "/esoui/art/icons/jewelrycrafting_trait_refined_zinc.dds"
	TraitTextures[ITEM_TRAIT_TYPE_JEWELRY_TRIUNE] = "/esoui/art/icons/jewelrycrafting_trait_refined_dawnprism.dds"
	TraitTextures[ITEM_TRAIT_TYPE_JEWELRY_INFUSED] = "/esoui/art/icons/crafting_enchantment_base_jade_r1.dds"
	TraitTextures[ITEM_TRAIT_TYPE_JEWELRY_PROTECTIVE] = "/esoui/art/icons/crafting_runecrafter_armor_component_006.dds"
	TraitTextures[ITEM_TRAIT_TYPE_JEWELRY_SWIFT] = "/esoui/art/icons/crafting_outfitter_plug_component_002.dds"
	TraitTextures[ITEM_TRAIT_TYPE_JEWELRY_HARMONY] = "/esoui/art/icons/crafting_metals_tin.dds"
	TraitTextures[ITEM_TRAIT_TYPE_JEWELRY_BLOODTHIRSTY] = "/esoui/art/icons/crafting_enchantment_baxe_bloodstone_r2.dds"
	
	TraitTextures[ITEM_TRAIT_TYPE_WEAPON_POWERED] = "/esoui/art/icons/crafting_runecrafter_potion_008.dds"
	TraitTextures[ITEM_TRAIT_TYPE_WEAPON_CHARGED] = "/esoui/art/icons/crafting_jewelry_base_amethyst_r3.dds"
	TraitTextures[ITEM_TRAIT_TYPE_WEAPON_PRECISE] = "/esoui/art/icons/crafting_jewelry_base_ruby_r3.dds"
	TraitTextures[ITEM_TRAIT_TYPE_WEAPON_INFUSED] = "/esoui/art/icons/crafting_enchantment_base_jade_r3.dds"
	TraitTextures[ITEM_TRAIT_TYPE_WEAPON_DEFENDING] = "/esoui/art/icons/crafting_jewelry_base_turquoise_r3.dds"
	TraitTextures[ITEM_TRAIT_TYPE_WEAPON_TRAINING] = "/esoui/art/icons/crafting_runecrafter_armor_component_004.dds"
	TraitTextures[ITEM_TRAIT_TYPE_WEAPON_SHARPENED] = "/esoui/art/icons/crafting_enchantment_base_fire_opal_r3.dds"
	TraitTextures[ITEM_TRAIT_TYPE_WEAPON_DECISIVE] = "/esoui/art/icons/crafting_smith_potion__sp_names_003.dds"
	TraitTextures[ITEM_TRAIT_TYPE_WEAPON_NIRNHONED] = "/esoui/art/icons/crafting_fortified_nirncrux_dust.dds"
end

function This:InitializeQualityColors()
	local ColorTable = self.QualityColor
	ColorTable[ITEM_QUALITY_NORMAL] = {R = 255 / 255, G = 255 / 255, B = 255 / 255}
	ColorTable[ITEM_QUALITY_MAGIC] = {R = 45 / 255, G = 197 / 255, B = 14 / 255}
	ColorTable[ITEM_QUALITY_ARCANE] = {R = 58 / 255, G = 146 / 255, B = 255 / 255}
	ColorTable[ITEM_QUALITY_ARTIFACT] = {R = 160 / 255, G = 46 / 255, B = 247 / 255}
	ColorTable[ITEM_QUALITY_LEGENDARY] = {R = 238 / 255, G = 202 / 255, B = 42 / 255}
end

local function ResetElementSize(Element)
	Element:SetResizeToFitDescendents(false)
	Element:SetResizeToFitDescendents(true)
end

local function SetPieceEntryFactory(Pool)
	local NameConst = "SetMasterSetPieceEntry"
	local TemplateConst = "SetMasterSetPieceEntry"
	local ContainerConst = SetMasterInventoryTooltip_Content_ItemListContainer
	local EntryName = NameConst .. Pool:GetNextControlId()
	return WINDOW_MANAGER:CreateControlFromVirtual(EntryName, ContainerConst, TemplateConst)
end

local function ResetSetPieceEntry(Entry)
	Entry:SetHidden(true)
	Entry:ClearAnchors()
end

function This:AcquireSetPieceEntry()
	local Entry, EntryKey = self.SetPieceEntryPool:AcquireObject()
	self.SetPieceEntries[EntryKey] = Entry
	Entry:SetHidden(false)
	return Entry
end

function This:ReleaseSetPieceEntries()
	self.SetPieceEntryPool:ReleaseAllObjects()
	self.SetPieceEntries = {}
end

local function TraitEntryFactory(Pool)
	local NameConst = "SetMasterTraitEntry"
	local TemplateConst = "SetMasterTraitEntry"
	local ContainerConst = SetMasterInventoryTooltip_Content_ItemListContainer
	local EntryName = NameConst .. Pool:GetNextControlId()
	return WINDOW_MANAGER:CreateControlFromVirtual(EntryName, ContainerConst, TemplateConst)
end

local function ResetTraitEntry(Entry)
	Entry:SetHidden(true)
	Entry:ClearAnchors()
	Entry:SetParent(nil)
end

function This:AcquireTraitEntry()
	local Entry, EntryKey = self.TraitEntryPool:AcquireObject()
	self.TraitEntries[EntryKey] = Entry
	Entry:SetHidden(false)
	return Entry
end

function This:ReleaseTraitEntries()
	self.TraitEntryPool:ReleaseAllObjects()
	self.TraitEntries = {}
end

local function SpacerFactory(Pool)
	local NameConst = "SetMasterSpacer"
	local TemplateConst = "SetMasterSpacer"
	local ContainerConst = SetMasterInventoryTooltip_Content_ItemListContainer
	local EntryName = NameConst .. Pool:GetNextControlId()
	return WINDOW_MANAGER:CreateControlFromVirtual(EntryName, ContainerConst, TemplateConst)
end

local function ResetSpacer(Entry)
	Entry:SetHidden(true)
	Entry:ClearAnchors()
	Entry:SetParent(nil)
end

function This:AcquireSpacer()
	local Entry, EntryKey = self.SpacerPool:AcquireObject()
	Entry:SetHidden(false)
	return Entry
end

function This:ReleaseSpacers()
	self.SpacerPool:ReleaseAllObjects()
end

local function TraitSpacerFactory(Pool)
	local NameConst = "SetMasterTraitSpacer"
	local TemplateConst = "SetMasterSpacer"
	local ContainerConst = SetMasterInventoryTooltip_Content_ItemListContainer
	local EntryName = NameConst .. Pool:GetNextControlId()
	return WINDOW_MANAGER:CreateControlFromVirtual(EntryName, ContainerConst, TemplateConst)
end

local function ResetTraitSpacer(Entry)
	Entry:SetHidden(true)
	Entry:ClearAnchors()
	Entry:SetParent(nil)
end

function This:AcquireTraitSpacer()
	local Entry, EntryKey = self.TraitSpacerPool:AcquireObject()
	Entry:SetHidden(false)
	return Entry
end

function This:ReleaseTraitSpacers()
	self.TraitSpacerPool:ReleaseAllObjects()
end

local function TraitPopupItemEntryFactory(Pool)
	local NameConst = "SetMasterTraitPopupItemEntry"
	local TemplateConst = "SetMasterTraitPopupItemEntry"
	local ContainerConst = SetMasterTraitPopup
	local EntryName = NameConst .. Pool:GetNextControlId()
	return WINDOW_MANAGER:CreateControlFromVirtual(EntryName, ContainerConst, TemplateConst)
end

local function ResetTraitPopupItemEntry(Entry)
	Entry:SetHidden(true)
	Entry:ClearAnchors()
	Entry:SetParent(nil)
end

function This:AcquireTraitPopupItemEntry()
	local Entry, EntryKey = self.TraitPopupItemEntryPool:AcquireObject()
	self.TraitPopupItemEntries[EntryKey] = Entry
	Entry:SetParent(SetMasterTraitPopup_Content_ItemBox)
	Entry:SetHidden(false)
	return Entry
end

function This:ReleaseTraitPopupItemEntries()
	self.TraitPopupItemEntryPool:ReleaseAllObjects()
	self.TraitPopupItemEntries = {}
end

local function TraitPopupOwnerEntryFactory(Pool)
	local NameConst = "SetMasterTraitPopupOwnerEntry"
	local TemplateConst = "SetMasterTraitPopupOwnerEntry"
	local ContainerConst = SetMasterTraitPopup
	local EntryName = NameConst .. Pool:GetNextControlId()
	return WINDOW_MANAGER:CreateControlFromVirtual(EntryName, ContainerConst, TemplateConst)
end

local function ResetTraitPopupOwnerEntry(Entry)
	Entry:SetHidden(true)
	Entry:ClearAnchors()
	Entry:SetParent(nil)
end

function This:AcquireTraitPopupOwnerEntry()
	local Entry, EntryKey = self.TraitPopupOwnerEntryPool:AcquireObject()
	self.TraitPopupOwnerEntries[EntryKey] = Entry
	Entry:SetHidden(false)
	return Entry
end

function This:ReleaseTraitPopupOwnerEntries()
	self.TraitPopupOwnerEntryPool:ReleaseAllObjects()
	self.TraitPopupOwnerEntries = {}
end

local function TraitPopupBagEntryFactory(Pool)
	local NameConst = "SetMasterTraitPopupBagEntry"
	local TemplateConst = "SetMasterTraitPopupBagEntry"
	local ContainerConst = SetMasterTraitPopup
	local EntryName = NameConst .. Pool:GetNextControlId()
	return WINDOW_MANAGER:CreateControlFromVirtual(EntryName, ContainerConst, TemplateConst)
end

local function ResetTraitPopupBagEntry(Entry)
	Entry:SetHidden(true)
	Entry:ClearAnchors()
	Entry:SetParent(nil)
end

function This:AcquireTraitPopupBagEntry()
	local Entry, EntryKey = self.TraitPopupBagEntryPool:AcquireObject()
	self.TraitPopupBagEntries[EntryKey] = Entry
	Entry:SetHidden(false)
	return Entry
end

function This:ReleaseTraitPopupBagEntries()
	self.TraitPopupBagEntryPool:ReleaseAllObjects()
	self.TraitPopupBagEntries = {}
end

local function TraitPopupQualityEntryFactory(Pool)
	local NameConst = "SetMasterTraitPopupQualityEntry"
	local TemplateConst = "SetMasterTraitPopupQualityEntry"
	local ContainerConst = SetMasterTraitPopup
	local EntryName = NameConst .. Pool:GetNextControlId()
	return WINDOW_MANAGER:CreateControlFromVirtual(EntryName, ContainerConst, TemplateConst)
end

local function ResetTraitPopupQualityEntry(Entry)
	Entry:SetHidden(true)
	Entry:ClearAnchors()
	Entry:SetParent(nil)
end

function This:AcquireTraitPopupQualityEntry()
	local Entry, EntryKey = self.TraitPopupQualityEntryPool:AcquireObject()
	self.TraitPopupQualityEntries[EntryKey] = Entry
	Entry:SetHidden(false)
	return Entry
end

function This:ReleaseTraitPopupQualityEntries()
	self.TraitPopupQualityEntryPool:ReleaseAllObjects()
	self.TraitPopupQualityEntries = {}
end

function This:SmartAnchor()
	if SetMasterOptions:GetOptions().bSmartAnchored == false then
		return
	end

	local MouseOverInstigator = self.MouseOverInstigator
	
	local MouseOverOwningWindow = nil
	if MouseOverInstigator ~= nil then
		MouseOverOwningWindow = MouseOverInstigator:GetOwningWindow()
	end
	
	local AnchorTarget = nil
	local AnchorPoint = TOPRIGHT
	local AnchorPointTarget = TOPLEFT
	local AnchorOffsetX = 0
	local AnchorOffsetY = 0
	if self.VanillaCompareTooltip2:IsHidden() == false then
		AnchorTarget=self.VanillaCompareTooltip2
	elseif self.VanillaCompareTooltip:IsHidden() == false then
		AnchorTarget = self.VanillaCompareTooltip
	elseif self.VanillaTooltip:IsHidden() == false then
		AnchorTarget = self.VanillaTooltip
		if MouseOverOwningWindow == ZO_Character then
			-- Don't obstruct the character window
			AnchorPoint = TOPLEFT
			AnchorPointTarget = TOPRIGHT
		end
	else
		-- No active item tooltip. Anchor to the owning window
		if ZO_MailSend:IsHidden() == false then
			AnchorTarget = ZO_MailSend
			AnchorPoint = RIGHT
			AnchorPointTarget = LEFT
			AnchorOffsetX = -20
		elseif MouseOverOwningWindow == ZO_MailInbox then
			AnchorTarget = ZO_MailInbox
			AnchorPoint = RIGHT
			AnchorPointTarget = LEFT
			AnchorOffsetX = -20
		elseif MouseOverOwningWindow == ZO_PlayerInventory
				and ZO_TradingHouse:IsHidden() == false then
			-- In the guild trader *selling* window. The right pane on that screen is the regular inventory pane. 
			AnchorTarget = ZO_TradingHouse
			AnchorPoint = RIGHT
			AnchorPointTarget = LEFT
			AnchorOffsetX = -20
		elseif MouseOverOwningWindow == ZO_Character then
			-- Don't obstruct the character window
			AnchorTarget = ZO_CharacterWindowStats
			AnchorPoint = LEFT
			AnchorPointTarget = RIGHT
		elseif MouseOverOwningWindow == ZO_TradingHouse then
			if ZO_TradingHouseBrowseItemsLeftPane:IsHidden() == false then
				AnchorTarget = ZO_TradingHouseBrowseItemsLeftPane
			elseif ZO_TradingHousePostItemPane:IsHidden() == false then
				AnchorTarget = ZO_TradingHousePostItemPane
			else
				-- In the posted items pane.
				AnchorTarget = MouseOverInstigator
			end
			AnchorPoint = RIGHT
			AnchorPointTarget = LEFT
		elseif MouseOverOwningWindow == ZO_ItemSetsBook_Keyboard_TopLevel then
			AnchorTarget = ZO_ItemSetsBook_Keyboard_TopLevel
			AnchorPoint = RIGHT
			AnchorPointTarget = LEFT
			AnchorOffsetX = -20
		else
			AnchorTarget = self.MouseOverInstigator
			AnchorPoint = RIGHT
			AnchorPointTarget = LEFT
		end
	end
	
	local Tooltip = self.Tooltip
	Tooltip:ClearAnchors()
	Tooltip:SetAnchor(AnchorPoint, AnchorTarget, AnchorPointTarget, AnchorOffsetX, AnchorOffsetY)
end

function This:RefreshMovable()
	local bSmartAnchored = SetMasterOptions:GetOptions().bSmartAnchored
	self.Tooltip:SetMovable(not bSmartAnchored)
end

local function ApplyArmorWeightCount(CountElement, AbbreviationElement, Count)
	local CountToApply = Count or 0
	CountElement:SetText(CountToApply)
	if CountToApply == 0 then
		CountElement:SetColor(0.25, 0.25, 0.25, 1.0)
		AbbreviationElement:SetColor(0.25, 0.25, 0.25, 1.0)
	else
		CountElement:SetColor(1.0, 1.0, 1.0, 1.0)
		AbbreviationElement:SetColor(1.0, 1.0, 1.0, 1.0)
	end
end

local function GetFirstItemIcon(EquipTypeTable)
	-- Grab the first item's icon then bail out of the loop.
	for Trait, TraitTable in next, EquipTypeTable.Traits do 
		for _, ItemLink in pairs(TraitTable.Items) do
			return GetItemLinkIcon(ItemLink)
		end
	end
end

function This:CreateTraitEntry(EntryNumber, PreviousEntries, Container, TraitInfo, Trait)
	local TraitEntry = self:AcquireTraitEntry()
	TraitEntry:SetParent(Container)
	if EntryNumber == 0 then
		-- First entry. Anchor it to the container.
		TraitEntry:SetAnchor(TOPLEFT, Container, TOPLEFT, 0, 0)
	else
		if EntryNumber % 2 == 0 then
			local LeftEntry = PreviousEntries[EntryNumber - 1]
			TraitEntry:SetAnchor(TOPLEFT, LeftEntry, TOPRIGHT, 2, 0)
			TraitEntry:SetAnchor(BOTTOMLEFT, LeftEntry, BOTTOMRIGHT, 2, 0)
		else
			local UpEntry = PreviousEntries[EntryNumber]
			TraitEntry:SetAnchor(TOPLEFT, UpEntry, BOTTOMLEFT, 0, 2)
			TraitEntry:SetAnchor(TOPRIGHT, UpEntry, BOTTOMRIGHT, 0, 2)
		end
	end
	
	local ContentContainer = TraitEntry:GetNamedChild("_ContentContainer")
	local TraitIcon = ContentContainer:GetNamedChild("_Icon")
	local TraitCount = ContentContainer:GetNamedChild("_Count")
	
	TraitIcon:SetTexture(self.TraitTextures[Trait])
	TraitCount:SetText(TraitInfo.Count)
	
	self.TraitEntryItems[TraitEntry] = TraitInfo.Items
	
	return TraitEntry
end

function This:GetWeaponTypesFromDisplayIndex(DisplayIndex)
	return self.DisplayIndexToWeaponType[DisplayIndex]
end

function This:CreateSetPieceEntry(EntryNumber, PreviousEntry, Container, bAnchorToBottom, EquipSlotTable, DisplaySlot, TypeIndicatorIconFile)
	if PreviousEntry == nil then
		d("CreateSetPieceEntry: Invalid PreviousEntry")
		return nil
	end
	
	local Entry = self:AcquireSetPieceEntry()
	local IconWeightContainer = Entry:GetNamedChild("_IconWeightContainer")
	local IconElement = IconWeightContainer:GetNamedChild("_Icon")
	local TypeIcon = IconElement:GetNamedChild("_TypeIndicator")
	local WeightContainerSpacer = IconWeightContainer:GetNamedChild("_WeightContainerSpacer")
	local WeightContainer = IconWeightContainer:GetNamedChild("_WeightContainer")
	local HeavyContainer = WeightContainer:GetNamedChild("_HeavyContainer")
	local HeavyCount = HeavyContainer:GetNamedChild("_Count")
	local HeavyAbbreviation = HeavyContainer:GetNamedChild("_Abbreviation")
	local MediumContainer = WeightContainer:GetNamedChild("_MediumContainer")
	local MediumCount = MediumContainer:GetNamedChild("_Count")
	local MediumAbbreviation = MediumContainer:GetNamedChild("_Abbreviation")
	local LightContainer = WeightContainer:GetNamedChild("_LightContainer")
	local LightCount = LightContainer:GetNamedChild("_Count")
	local LightAbbreviation = LightContainer:GetNamedChild("_Abbreviation")
	local TraitContainer = Entry:GetNamedChild("_TraitContainer")
	
	if bAnchorToBottom then
		Entry:SetAnchor(TOPLEFT, PreviousEntry, BOTTOMLEFT, 0, 0)
		--Entry:SetAnchor(TOPRIGHT, PreviousEntry, BOTTOMRIGHT, 0, 0)
	else
		Entry:SetAnchor(TOPLEFT, PreviousEntry, TOPLEFT, 0, 0)
		--Entry:SetAnchor(TOPRIGHT, PreviousEntry, TOPRIGHT, 0, 0)
	end
	
	local bArmor, bJewelry, bWeapon = false, false, false
	local TraitTypesTable = nil
	if SetMasterGlobal.TableContains(This.ArmorSlots, DisplaySlot) then
		bArmor = true
		TraitTypesTable = This.ArmorTraitTypes
	elseif SetMasterGlobal.TableContains(This.JewelrySlots, DisplaySlot) then
		bJewelry = true
		TraitTypesTable = This.JewelryTraitTypes
	else -- We don't use the weapon's equip type for the weapon's display slot
		bWeapon = true
		TraitTypesTable = This.WeaponTraitTypes
	end
	
	if bArmor and DisplaySlot ~= EQUIP_TYPE_OFF_HAND then
		-- Count the number of light, medium, and heavy items
		local SetPieceTypes = {}
		for Trait, TraitTable in next, EquipSlotTable.Traits do -- pairs makes a pair between the pair key and both the "Count" and "Items" fields.
			for _, ItemLink in pairs(TraitTable.Items) do
				local ItemArmorType = GetItemLinkArmorType(ItemLink)
				SetPieceTypes[ItemArmorType] = (SetPieceTypes[ItemArmorType] or 0) + 1
			end
		end
		
		HeavyAbbreviation:SetText(SetMasterGlobal.Localize("Weight", "HeavyAbbreviation"))
		ApplyArmorWeightCount(HeavyCount, HeavyAbbreviation, SetPieceTypes[ARMORTYPE_HEAVY])
		
		MediumAbbreviation:SetText(SetMasterGlobal.Localize("Weight", "MediumAbbreviation"))
		ApplyArmorWeightCount(MediumCount, MediumAbbreviation, SetPieceTypes[ARMORTYPE_MEDIUM])
		
		LightAbbreviation:SetText(SetMasterGlobal.Localize("Weight", "LightAbbreviation"))
		ApplyArmorWeightCount(LightCount, LightAbbreviation, SetPieceTypes[ARMORTYPE_LIGHT])
		
		WeightContainerSpacer:SetHidden(true)
		WeightContainer:SetHidden(false)
	elseif bWeapon then
		-- Display weapon type counts if applicable
		local SlotTable = nil
		local WeaponTypesForDisplayIndex = self:GetWeaponTypesFromDisplayIndex(DisplaySlot)
		if SetMasterGlobal.TableContains(self.OneHandedMeleeSlots.Slots, WeaponTypesForDisplayIndex[1]) then
			SlotTable = self.OneHandedMeleeSlots
		elseif SetMasterGlobal.TableContains(self.TwoHandedMeleeSlots.Slots, WeaponTypesForDisplayIndex[1]) then
			SlotTable = self.TwoHandedMeleeSlots
		elseif SetMasterGlobal.TableContains(self.DestructionStaffSlots.Slots, WeaponTypesForDisplayIndex[1]) then
			SlotTable = self.DestructionStaffSlots
		end
		
		if SlotTable ~= nil then
			local WeaponTypes = {}
			for Trait, TraitTable in next, EquipSlotTable.Traits do
				for _, ItemLink in pairs(TraitTable.Items) do
					local ItemWeaponType = GetItemLinkWeaponType(ItemLink)
					WeaponTypes[ItemWeaponType] = (WeaponTypes[ItemWeaponType] or 0) + 1
				end
			end
			
			for Index, Slot in ipairs(SlotTable.Slots) do
				local AbbreviationElement
				if Index == 1 then
					AbbreviationElement = HeavyAbbreviation
				elseif Index == 2 then
					AbbreviationElement = MediumAbbreviation
				else
					AbbreviationElement = LightAbbreviation
				end
				AbbreviationElement:SetText(self.WeaponAbbreviations[Slot])
				ApplyArmorWeightCount(AbbreviationElement:GetParent():GetNamedChild("_Count"), AbbreviationElement, WeaponTypes[Slot])
			end
			
			WeightContainerSpacer:SetHidden(true)
			WeightContainer:SetHidden(false)
		else
			WeightContainerSpacer:SetHidden(false)
			WeightContainer:SetHidden(true)
		end
	else
		WeightContainerSpacer:SetHidden(false)
		WeightContainer:SetHidden(true)
	end
	
	local ItemIcon = GetFirstItemIcon(EquipSlotTable)
	if ItemIcon == nil then
		d("Failed to find set piece, no icon used")
	end
	IconElement:SetTexture(ItemIcon)
	if TypeIndicatorIconFile ~= nil then
		TypeIcon:SetTexture(TypeIndicatorIconFile)
		TypeIcon:SetHidden(false)
	else
		TypeIcon:SetHidden(true)
	end
	
	ResetElementSize(TraitContainer)
	
	-- {DisplaySlot => Count = #, Traits = {Trait (#) => {Count = #, Items = {}}}}
	local TraitEntryCount = 0
	local PreviousTraitEntries = {}
	for _, AllTraitsItr in ipairs(TraitTypesTable) do
		local OwnedTraitInfo = EquipSlotTable.Traits[AllTraitsItr]
		if OwnedTraitInfo ~= nil then
			local NewEntry = self:CreateTraitEntry(TraitEntryCount, PreviousTraitEntries, TraitContainer, OwnedTraitInfo, AllTraitsItr)
			table.insert(PreviousTraitEntries, NewEntry)
			TraitEntryCount = TraitEntryCount + 1
		end
	end
	
	return Entry
end

function This:ShowItemTooltip(InVanillaTooltip)
	self.bHidden = false
	self.Tooltip:SetHidden(false)
end

function This:HideTooltip()
	self.bHidden = true
	self.Tooltip:SetHidden(true)
	This.ItemLink = nil
	This.ItemLinkSetId = nil
end

function This:ResetSetInfo()
	self.SetInfo = {}
	for EquipTypeItr in SetMasterGlobal.Range(EQUIP_TYPE_ITERATION_BEGIN, EQUIP_TYPE_ITERATION_END) do
		if SetMasterGlobal.TableContains(self.IgnoredEquipTypes, EquipTypeItr) == false then
			self.SetInfo[EquipTypeItr] = {Count = 0, Traits = {}}
		end
	end
	
	for _, GroupIndex in pairs(self.WeaponTypeDisplayIndicies) do
		self.SetInfo[GroupIndex] = {Count = 0, Traits = {}}
	end
end

function This:GetDisplayCategory(ItemLink)
	local WeaponType = GetItemLinkWeaponType(ItemLink)
	local WeaponTypeDisplayIndex = self.WeaponTypeDisplayIndicies[WeaponType]
	if WeaponTypeDisplayIndex ~= nil then
		return WeaponTypeDisplayIndex
	end
	
	return GetItemLinkEquipType(ItemLink)
end

function This:BuildSetInfo()
	local SetItemIds = PlayerSetDatabase.SetItemIds[self.ItemLinkSetId]
	
	if SetItemIds == nil then
		-- Item was a set item but we don't have the SetId map built.
		-- Means LibSets is out of date.
		self:HideTooltip()
		return false
	end
	
	local Database = PlayerSetDatabase:GetMegaserverTable()
	local IsBagIgnored = PlayerSetDatabase.IsBagIgnored
	self:ResetSetInfo()
	for ItemId, _ in pairs(SetItemIds) do
		local OwnedItemEntry = Database[ItemId]
		if OwnedItemEntry ~= nil then
			for Owner, BagList in pairs(OwnedItemEntry) do
				for BagId, ItemLinks in pairs(BagList) do
					if IsBagIgnored(PlayerSetDatabase, BagId, Owner) == false then
						for _, ItemInfo in pairs(ItemLinks) do
							local EquipCategory, DisplayIcon = self:GetDisplayCategory(ItemInfo.ItemLink)
							local TypeTable = self.SetInfo[EquipCategory]
							TypeTable.Count = TypeTable.Count + 1
							
							local Trait = GetItemLinkTraitType(ItemInfo.ItemLink)
							TypeTable.Traits[Trait] = TypeTable.Traits[Trait] or {Count = 0, Items = {}}
							local TypeTraitTable = TypeTable.Traits[Trait]
							table.insert(TypeTraitTable.Items, ItemInfo.ItemLink)
							TypeTraitTable.Count = TypeTraitTable.Count + 1
						end
					end
				end
			end
		end
	end
	
	return true
end

function This:GetWeaponTypeIcon(ItemLink, WeaponType)
	return self.WeaponIcons[GetItemLinkWeaponType(ItemLink)]
end

function This:SortTraitPopupItemCategories(ItemCategories, WeaponType)

	local ItemIdDisplayOrder = {}
	for ItemId, CategoryData in pairs(ItemCategories) do
		table.insert(ItemIdDisplayOrder, ItemId)
	end
	
	if WeaponType == WEAPONTYPE_NONE then
		return ItemIdDisplayOrder
	end
	
	local WeaponTypeTable = nil
	local TableContains = SetMasterGlobal.TableContains
	
	if TableContains(self.DestructionStaffSlots.Slots, WeaponType) then
		WeaponTypeTable = self.DestructionStaffSlots.Slots
	elseif TableContains(self.OneHandedMeleeSlots.Slots, WeaponType) then
		WeaponTypeTable = self.OneHandedMeleeSlots.Slots
	elseif TableContains(self.TwoHandedMeleeSlots.Slots, WeaponType) then
		WeaponTypeTable = self.TwoHandedMeleeSlots.Slots
	end
	
	
	
	if WeaponTypeTable == nil then
		return ItemIdDisplayOrder
	end
	
	local ArrayFind = SetMasterGlobal.ArrayFind
	table.sort(ItemIdDisplayOrder, 
			function(a, b)
				local WeaponTypeA = GetItemLinkWeaponType(ItemCategories[a].ItemLink)
				local WeaponTypeB = GetItemLinkWeaponType(ItemCategories[b].ItemLink)
				return ArrayFind(WeaponTypeTable, WeaponTypeA) < ArrayFind(WeaponTypeTable, WeaponTypeB)
			end
		)
	return ItemIdDisplayOrder
end

function This:BuildTraitPopup(TraitItemLinks, TargetTraitValue)
	local ItemIdReplacements = {} -- map the unique ItemIds to an equivalent item id.
	-- ESO has unique ItemIds for a reconstructed item, but we want to display them together.
	
								-- {ItemId -> Icon}
	local ItemCategories = {} 	-- All unique item ids represented. Might be representing one-handed axes + swords, for example.
	for _, Link in ipairs(TraitItemLinks) do
		local ItemId = GetItemLinkItemId(Link)
		local ItemIcon = GetItemLinkIcon(Link)
		local bDuplicate = false
		for SearchItemId, CategoryData in pairs(ItemCategories) do
			if CategoryData.Icon == ItemIcon
					and self:GetWeaponTypeIcon(Link) == self:GetWeaponTypeIcon(CategoryData.ItemLink) then
				-- This item is a reconsutrcted varient of one we already added (or vice versa).
				ItemIdReplacements[ItemId] = SearchItemId
				bDuplicate = true
			end
		end
		
		if bDuplicate == false then
			ItemIdReplacements[ItemId] = ItemId
			ItemCategories[ItemId] = ItemCategories[ItemId] or {}
			ItemCategories[ItemId].Icon = ItemIcon
			ItemCategories[ItemId].ItemLink = Link
		end
	end
	
	local OwnerInfo = {}
	local IsBagIgnored = PlayerSetDatabase.IsBagIgnored
	for ItemId, DisplayItemId in pairs(ItemIdReplacements) do
		
		local OwnerList = PlayerSetDatabase:GetMegaserverTable()[ItemId]
		
		-- Replace the ItemId if it's a reconstruced duplicate
		local DisplayItemId = ItemIdReplacements[ItemId] or ItemId
		
		OwnerInfo[DisplayItemId] = OwnerInfo[DisplayItemId] or {}
		local OwnerItemEntry = OwnerInfo[DisplayItemId]
		for OwnerName, BagList in pairs(OwnerList) do
			OwnerItemEntry[OwnerName] = OwnerItemEntry[OwnerName] or {}
			local OwnerTable = OwnerItemEntry[OwnerName]
			for BagId, ItemLinks in pairs(BagList) do
				if IsBagIgnored(PlayerSetDatabase, BagId, OwnerName) == false then
					local DisplayBagId = BagId
					if BagId == BAG_SUBSCRIBER_BANK then
						-- Show subscriber bank items with regular bank items
						DisplayBagId = BAG_BANK
					end
					
					for _, ItemLink in pairs(ItemLinks) do
						if GetItemLinkTraitType(ItemLink.ItemLink) == TargetTraitValue then
							OwnerTable[DisplayBagId] = OwnerTable[DisplayBagId] or {}
							local BagTable = OwnerTable[DisplayBagId]
							local ItemQuality = GetItemLinkQuality(ItemLink.ItemLink)
							BagTable[ItemQuality] = BagTable[ItemQuality] or 0
							BagTable[ItemQuality] = BagTable[ItemQuality] + 1
						end
					end
				end
			end
		end
	end
	
	local ArbitraryItemLink = TraitItemLinks[1]
	local ItemIdDisplayOrder = {}
	if ArbitraryItemLink ~= nil then
		local WeaponType = GetItemLinkWeaponType(ArbitraryItemLink)
		ItemIdDisplayOrder = self:SortTraitPopupItemCategories(ItemCategories, GetItemLinkWeaponType(ArbitraryItemLink))
	end
	
	return ItemCategories, OwnerInfo, ItemIdDisplayOrder
end

function This:BuildTooltip()
	self:ReleaseSetPieceEntries()
	self:ReleaseTraitEntries()
	self:ReleaseSpacers()
	
	self:SmartAnchor()
	
	local ContentContainer = self.Tooltip:GetNamedChild("_Content")
	local TooltipHeader = ContentContainer:GetNamedChild("_Header")
	local HeaderTextContainer = TooltipHeader:GetNamedChild("_TextContainer")
	local ItemListContainer = ContentContainer:GetNamedChild("_ItemListContainer")
	local NoItemText = ItemListContainer:GetNamedChild("_NoItemsText")
	local SetNameText = HeaderTextContainer:GetNamedChild("_SetNameText")
	
	SetNameText:SetText(LibSets.GetSetName(self.ItemLinkSetId)) -- LibSets localizes this string
	
	-- Shrink the window if necessary
	ResetElementSize(ItemListContainer)
	ResetElementSize(ContentContainer)
	
	local bSetInfoBuildSuccess = self:BuildSetInfo()
	if bSetInfoBuildSuccess == false then
		return
	end
	
	local ContainerConst = SetMasterInventoryTooltip_Content_ItemListContainer
	local PreviousEntry = ContainerConst
	local bAnchorToBottom = false -- The first entry needs to anchor to the top of the container
	local EntryCount = 0
	for _, DisplayInfo in ipairs(self.EquipSlotsOrdered) do
		local DisplaySlot = DisplayInfo.Slot
		local EquipSlotTable = self.SetInfo[DisplaySlot]
		if EquipSlotTable.Count ~= 0 then
			local Entry = self:CreateSetPieceEntry(EntryCount, PreviousEntry, ContainerConst, bAnchorToBottom, EquipSlotTable, DisplaySlot, DisplayInfo.Icon)
			EntryCount = EntryCount + 1
			bAnchorToBottom = true
			PreviousEntry = Entry
		end
	end
	
	-- Add a margin to the right and bottom of the tooltip content.
	local Spacer = self:AcquireSpacer()
	Spacer:SetParent(self.Tooltip)
	Spacer:SetWidth(10)
	Spacer:SetHeight(1)
	Spacer:SetAnchor(LEFT, ContentContainer, RIGHT, 0, 0)
	
	Spacer = self:AcquireSpacer()
	Spacer:SetParent(self.Tooltip)
	Spacer:SetWidth(1)
	Spacer:SetHeight(7)
	Spacer:SetAnchor(TOP, ContentContainer, BOTTOM, 0, 0)
	
	NoItemText:SetHidden(EntryCount ~= 0)
	
	self.Tooltip:SetTopmost(true)
end

function This:FillQualityCountText(Label, Quality, Count)
	if SetMasterOptions:GetOptions().bColorBlind then
		Label:SetText(tostring(Count) .. " " .. SetMasterGlobal.Localize("QualityName", Quality))
	else
		Label:SetText(tostring(Count))
	end
	local QualityColor = self.QualityColor[Quality]
	Label:SetColor(QualityColor.R, QualityColor.G, QualityColor.B, 1.0)
end

function This:CreateTraitPopupQualityEntry(OwningBox, PreviousEntry, Quality, Count)
	local Entry = self:AcquireTraitPopupQualityEntry()
	Entry:SetParent(OwningBox)
	
	if PreviousEntry == nil then
		d("Set Master: Invalid PreviousEntry for Popup Quality Entry")
	else
		local AnchorSpacer = PreviousEntry:GetNamedChild("_Content"):GetNamedChild("_MiddleSpacer")
		local HeightOffset = PreviousEntry:GetNamedChild("_Content"):GetNamedChild("_QualityText"):GetHeight() - AnchorSpacer:GetHeight()
		Entry:SetAnchor(TOPLEFT, AnchorSpacer, BOTTOMLEFT, 0, HeightOffset - 4)
	end
	
	local Content = Entry:GetNamedChild("_Content")
	local QualityText = Content:GetNamedChild("_QualityText")
	
	self:FillQualityCountText(QualityText, Quality, Count)
	
	return Entry
end

function This:CreateTraitPopupBagEntry(OwningBox, PreviousEntry, BagName, QualityTable)
	local Entry = self:AcquireTraitPopupBagEntry()
	Entry:SetParent(OwningBox)
	
	if PreviousEntry == nil then
		-- Anchor to the owner's box
		Entry:SetAnchor(TOP, OwningBox, TOP, 0, 0)
	else
		Entry:SetAnchor(TOP, PreviousEntry, BOTTOM, 0, 0)
	end
	
	local Content = Entry:GetNamedChild("_Content")
	local BagNameLabel = Content:GetNamedChild("_BagName")
	local QualityLabel = Content:GetNamedChild("_QualityText")
	
	local PreviousQualityEntry = nil
	for _, Quality in ipairs(self.QualityDisplayOrder) do
		local QualityCount = QualityTable[Quality]
		if QualityCount ~= nil then
			if PreviousQualityEntry == nil then
				-- Put the first quality in the bag entry.
				self:FillQualityCountText(QualityLabel, Quality, QualityCount)
				PreviousQualityEntry = Entry
			else
				PreviousQualityEntry = self:CreateTraitPopupQualityEntry(Entry, PreviousQualityEntry, Quality, QualityCount)
			end
		end
	end
	
	BagNameLabel:SetText(BagName)
	
	return Entry
end

function This:CreateTraitPopupOwnerEntry(OwningBox, PreviousEntry, OwnerName, BagInfo)
	local Entry = self:AcquireTraitPopupOwnerEntry()
	Entry:SetParent(OwningBox)
	
	if PreviousEntry == nil then
		-- Anchor to the owner's box
		Entry:SetAnchor(TOP, OwningBox, TOP, 0, 0)
	else
		Entry:SetAnchor(TOP, PreviousEntry, BOTTOM, 0, 0)
	end
	
	local OwnerNameLabel = Entry:GetNamedChild("_OwnerName")
	OwnerNameLabel:SetText(OwnerName)
	
	local InfoBox = Entry:GetNamedChild("_InfoBox")
	local PreviousEntry = nil
	for BagId, QualityTable in pairs(BagInfo) do
		if not SetMasterGlobal.IsTableEmpty(QualityTable) then
			PreviousEntry = self:CreateTraitPopupBagEntry(InfoBox, PreviousEntry, SetMasterOptions:GetBagDisplayName(BagId), QualityTable)
		end
	end
	
	return Entry
end

function This:CreateTraitPopupItemEntry(TraitControl, PreviousEntry, ItemOwnerInfo, DisplayIcon, ItemLink)
	local Entry = self:AcquireTraitPopupItemEntry()
	
	if PreviousEntry == nil then
		-- Anchor to the parent control
		local ParentContent = TraitControl:GetNamedChild("_Content")
		local ParentItemBox = ParentContent:GetNamedChild("_ItemBox")
		Entry:SetAnchor(TOP, ParentItemBox, TOP, 0, 0)
	else
		Entry:SetAnchor(TOP, PreviousEntry, BOTTOM, 0, 10)
	end
	
	local Content = Entry:GetNamedChild("_Content")
	local Header = Content:GetNamedChild("_Header")
	local Icon = Header:GetNamedChild("_Icon")
	local TypeIcon = Icon:GetNamedChild("_TypeIcon")
	local ArmorWeightIndicator = Icon:GetNamedChild("_ArmorWeightIndicator")
	
	Icon:SetTexture(DisplayIcon)
	
	local TypeIconFile = self:GetWeaponTypeIcon(ItemLink)
	if TypeIconFile ~= nil then
		TypeIcon:SetTexture(TypeIconFile)
		TypeIcon:SetHidden(false)
	else
		TypeIcon:SetHidden(true)
	end
	
	-- If the item is armor, populate the armor weight indicator
	local ArmorType = GetItemLinkArmorType(ItemLink)
	if ArmorType == ARMORTYPE_NONE then
		ArmorWeightIndicator:SetHidden(true)
	else
		local AbbreviationLocKey
		if ArmorType == ARMORTYPE_HEAVY then
			AbbreviationLocKey = "HeavyAbbreviation"
		elseif ArmorType == ARMORTYPE_MEDIUM then
			AbbreviationLocKey = "MediumAbbreviation"
		else
			AbbreviationLocKey = "LightAbbreviation"
		end
		
		local LocalizedAbbreviation = SetMasterGlobal.Localize("Weight", AbbreviationLocKey)
		ArmorWeightIndicator:SetText(LocalizedAbbreviation)
		ArmorWeightIndicator:SetHidden(false)
	end
	
	local OwnerEntryBox = Content:GetNamedChild("_OwnerEntryBox")
	local PreviousOwnerEntry = nil
	
	for OwnerName, BagInfo in pairs(ItemOwnerInfo) do
		if not SetMasterGlobal.IsTableEmpty(BagInfo) then
			PreviousOwnerEntry = self:CreateTraitPopupOwnerEntry(OwnerEntryBox, PreviousOwnerEntry, OwnerName, BagInfo)
		end
	end
	
	return Entry
end

function This:ShowTraitPopup(TraitControl)
	self:ReleaseTraitPopupItemEntries()
	self:ReleaseTraitPopupOwnerEntries()
	self:ReleaseTraitPopupBagEntries()
	self:ReleaseTraitPopupQualityEntries()
	self:ReleaseTraitSpacers()
	
	self.TraitPopup:SetAnchor(BOTTOM, TraitControl, TOP, 0, 0)
	self.TraitPopup:BringWindowToTop()
	self.TraitPopup:SetHidden(false)
	
	local Content = self.TraitPopup:GetNamedChild("_Content")
	local Header = Content:GetNamedChild("_Header")
	local Title = Header:GetNamedChild("_Title")
	
	local TraitItemLinks = self.TraitEntryItems[TraitControl]
	local TraitValue = GetItemLinkTraitType(TraitItemLinks[1])
	local TraitName = SetMasterGlobal.Localize("TraitName", TraitValue)
	Title:SetText(TraitName)
	
	local ItemBox = Content:GetNamedChild("_ItemBox")
	
	ResetElementSize(self.TraitPopup)
	
	local ItemCategories, OwnerInfo, ItemIdDisplayOrder = self:BuildTraitPopup(TraitItemLinks, TraitValue)
	
	local PreviousItemEntry = nil
	for _, ItemId in ipairs(ItemIdDisplayOrder) do
		local ItemInfo = ItemCategories[ItemId]
		local DisplayIcon = ItemInfo.Icon
		local ItemLink = ItemInfo.ItemLink
		PreviousItemEntry = self:CreateTraitPopupItemEntry(self.TraitPopup, PreviousItemEntry, OwnerInfo[ItemId], DisplayIcon, ItemLink)
	end
	
	local BottomSpacer = self:AcquireTraitSpacer()
	BottomSpacer:SetParent(self.TraitPopup)
	BottomSpacer:SetDimensions(2, 10)
	BottomSpacer:SetAnchor(TOP, PreviousItemEntry, BOTTOM, 0, 0)
	
	self.TraitPopup:SetTopmost(true)
end

function This:HideTraitPopup(TraitControl)
	self.TraitPopup:ClearAnchors()
	self.TraitPopup:SetHidden(true)
end

function This:SetItemLink(ItemLink, bEquipped)
	if ItemLink == self.ItemLink and not self.bHidden then
		return
	end
	
	if ItemLink == nil then
		self:HideTooltip()
		return
	end
	
	ResetElementSize(self.Tooltip)
	
	local _, SetName, _, NumEquipped, MaxEquipped, SetId = GetItemLinkSetInfo(ItemLink, bEquipped)
	if SetId == 0 or SetId == nil then
		-- The item doesn't belong to a set or LibSets doesn't have the set (if nil).
		self:HideTooltip()
		return
	end
	
	self.ItemLink = ItemLink
	self.ItemLinkSetId = SetId
	
	if self.bHidden then
		self:ShowItemTooltip(Control)
	end
	
	This:BuildTooltip()
end

function This:OnInventoryChanged()
	if self.bHidden then
		return
	end
	
	if self.HoveredTraitControl ~= nil then
		self:OnMouseExitTrait(HoveredTraitControl)
	end
	This:BuildTooltip()
end

function This:OnItemDataAdded(Control, TooltipEventNumber)
	if TooltipEventNumber ~= 8 then
		-- The tooltip fires multiple events and always ends with event "8".
		-- I don't know why.
		return
	end
	
	if SetMasterGlobal.IsAnyElementVisible(self.ParentElements) == false then
		-- This is a fix for a performance-dependant bug where the UI will close but the tooltip remains open.
		-- The game is firing OnItemDataAdded after the UI element gets closed.
		-- So don't open the tooltip if none of the UI elements that could instigate the tooltip are open.
		return
	end
	
	local MouseOverItemLink, bEquipped = SetMasterGlobal.GetMouseOverItemLink()
	self.MouseOverInstigator = moc()
	This:SetItemLink(MouseOverItemLink, bEquipped)
end

function This:OnCloseButtonPressed()
	self:HideTooltip()
end

function This:ShowHoverTooltip(Control, LocKey)
	local LocalizedText = SetMasterGlobal.LocalizeString(LocKey)
	local HoverTooltip = self.HoverTooltip
	local HoverTooltipText = HoverTooltip:GetNamedChild("_Text")
	
	HoverTooltipText:SetText(LocalizedText)
	ResetElementSize(HoverTooltip)
	HoverTooltip:ClearAnchors()
	HoverTooltip:SetAnchor(BOTTOM, Control, TOP, 0, 0)
	HoverTooltip:BringWindowToTop()
	HoverTooltip:SetHidden(false)
end

function This:HideHoverTooltip(Control)
	self.HoverTooltip:SetHidden(true)
end

function This:OnAnchorButtonPressed()
	local Options = SetMasterOptions:GetOptions()
	Options.bSmartAnchored = not Options.bSmartAnchored
	
	self:RefreshMovable()
	
	if Options.bSmartAnchored then
		self:SmartAnchor()
	else
		self.Tooltip:ClearAnchors()
		self.Tooltip:SetAnchor(CENTER, GUI_ROOT, CENTER, 0, 0)
	end
end

function This:OnMouseEnterTrait(TraitControl)
	self.HoveredTraitControl = TraitControl
	self:ShowTraitPopup(TraitControl)
end

function This:OnMouseExitTrait(TraitControl)
	self:HideTraitPopup(TraitControl)
	self.HoveredTraitControl = nil
end

function This:OnElementHidden(Element)
	self:HideTooltip()
end

function This:SubscribeToElementHidden(Element)
	table.insert(self.ParentElements, Element)

	ZO_PreHookHandler(Element, 'OnHide', function()
		self:OnElementHidden(Element)
	end)
end

function This:SubscribeSmartAnchor(Element)
	ZO_PreHookHandler(Element, 'OnShow', 
		function()
			self:SmartAnchor()
		end)
	ZO_PreHookHandler(Element, 'OnHide', 
		function()
			self:SmartAnchor()
		end)
end

local function GetDisplayIndexFromWweaponType(WeaponType)
	return EQUIP_TYPE_MAX_VALUE + WeaponType
end

function This:Initialize()
	for _, Slot in ipairs(self.ArmorSlots) do
		table.insert(self.EquipSlotsOrdered, {Slot = Slot})
	end
	
	for _, Slot in ipairs(self.JewelrySlots) do
		table.insert(self.EquipSlotsOrdered, {Slot = Slot})
	end
	
	local DisplayIndicies = self.WeaponTypeDisplayIndicies
	local GroupIndex = EQUIP_TYPE_MAX_VALUE
	for _, SlotTable in ipairs(self.WeaponTypeTables) do
		for _, Slot in ipairs(SlotTable.Slots) do
			DisplayIndicies[Slot] = GroupIndex
			self.DisplayIndexToWeaponType[GroupIndex] = self.DisplayIndexToWeaponType[GroupIndex] or {}
			table.insert(self.DisplayIndexToWeaponType[GroupIndex], Slot)
		end
		table.insert(self.EquipSlotsOrdered, {Slot = GroupIndex, Icon = SlotTable.Icon})
		GroupIndex = GroupIndex + 1
	end
	
	PlayerSetDatabase.SlotChangedEvent = function() 
		self:OnInventoryChanged()
	end
	
	self.WeaponIcons[WEAPONTYPE_FIRE_STAFF] = "Esoui/Art/Icons/ability_destructionstaff_007_a.dds"
	self.WeaponIcons[WEAPONTYPE_FROST_STAFF] = "Esoui/Art/Icons/ability_destructionstaff_002b.dds"
	self.WeaponIcons[WEAPONTYPE_LIGHTNING_STAFF] = "Esoui/Art/Icons/ability_destructionstaff_006_b.dds"
	
	self.WeaponAbbreviations[WEAPONTYPE_AXE] = SetMasterGlobal.Localize("MeleeWeaponTypes", "AxeAbbreviation")
	self.WeaponAbbreviations[WEAPONTYPE_TWO_HANDED_AXE] = SetMasterGlobal.Localize("MeleeWeaponTypes", "AxeAbbreviation")
	self.WeaponAbbreviations[WEAPONTYPE_HAMMER] = SetMasterGlobal.Localize("MeleeWeaponTypes", "HammerAbbreviation")
	self.WeaponAbbreviations[WEAPONTYPE_TWO_HANDED_HAMMER] = SetMasterGlobal.Localize("MeleeWeaponTypes", "HammerAbbreviation")
	self.WeaponAbbreviations[WEAPONTYPE_SWORD] = SetMasterGlobal.Localize("MeleeWeaponTypes", "SwordAbbreviation")
	self.WeaponAbbreviations[WEAPONTYPE_TWO_HANDED_SWORD] = SetMasterGlobal.Localize("MeleeWeaponTypes", "SwordAbbreviation")
	self.WeaponAbbreviations[WEAPONTYPE_FIRE_STAFF] = SetMasterGlobal.Localize("DestructionStaffWeaponTypes", "FireAbbreviation")
	self.WeaponAbbreviations[WEAPONTYPE_FROST_STAFF] = SetMasterGlobal.Localize("DestructionStaffWeaponTypes", "FrostAbbreviation")
	self.WeaponAbbreviations[WEAPONTYPE_LIGHTNING_STAFF] = SetMasterGlobal.Localize("DestructionStaffWeaponTypes", "LightningAbbreviation")
	
	self.VanillaCompareTooltip = ComparativeTooltip1
	self.VanillaCompareTooltip2 = ComparativeTooltip2
	self.VanillaTooltip = ItemTooltip
	
	self.Tooltip = SetMasterInventoryTooltip
	self.HoverTooltip = SetMasterTextHoverTooltip
	
	self:RefreshMovable()
	
	self:InitializeTextureConsts()
	self:InitializeQualityColors()
	
	self.SetPieceEntryPool = ZO_ObjectPool:New(SetPieceEntryFactory, ResetSetPieceEntry)
	self.TraitEntryPool = ZO_ObjectPool:New(TraitEntryFactory, ResetTraitEntry)
	self.SpacerPool = ZO_ObjectPool:New(SpacerFactory, ResetSpacer)
	self.TraitSpacerPool = ZO_ObjectPool:New(TraitSpacerFactory, ResetTraitSpacer)
	self.TraitPopupItemEntryPool = ZO_ObjectPool:New(TraitPopupItemEntryFactory, ResetTraitPopupItemEntry)
	self.TraitPopupOwnerEntryPool = ZO_ObjectPool:New(TraitPopupOwnerEntryFactory, ResetTraitPopupOwnerEntry)
	self.TraitPopupBagEntryPool = ZO_ObjectPool:New(TraitPopupBagEntryFactory, ResetTraitPopupBagEntry)
	self.TraitPopupQualityEntryPool = ZO_ObjectPool:New(TraitPopupQualityEntryFactory, ResetTraitPopupQualityEntry)
	
	self.TraitPopup = SetMasterTraitPopup
	
	ZO_PreHookHandler(ItemTooltip, 'OnAddGameData', 
		function(Control, TooltipEventNumber)
			self:OnItemDataAdded(Control, TooltipEventNumber)
		end)
	
	-- Hook into hovering over a set collection item being hovered.
	local OriginalSetLink = self.VanillaTooltip['SetItemSetCollectionPieceLink']
	self.VanillaTooltip['SetItemSetCollectionPieceLink'] = function(VanillaTooltip, ItemLink)
		OriginalSetLink(VanillaTooltip, ItemLink)
		self:SetItemLink(ItemLink, false)
	end
	
	self:SubscribeSmartAnchor(ItemTooltip)
	self:SubscribeSmartAnchor(ComparativeTooltip1)
	self:SubscribeSmartAnchor(ComparativeTooltip2)
	
	-- Windows that can "own" the tooltip should close the tooltip when they close.
	self:SubscribeToElementHidden(ZO_PlayerInventory)
	self:SubscribeToElementHidden(ZO_PlayerBank)
	self:SubscribeToElementHidden(ZO_BuyBack)
	self:SubscribeToElementHidden(ZO_GuildBank)
	self:SubscribeToElementHidden(ZO_HouseBank)
	self:SubscribeToElementHidden(ZO_Loot)
	self:SubscribeToElementHidden(ZO_InteractWindow) -- ZO_InteractWindowRewardArea has quest rewards, but only the top level fires the hidden event
	self:SubscribeToElementHidden(ZO_MailInbox)
	self:SubscribeToElementHidden(ZO_MailSendAttachments)
	self:SubscribeToElementHidden(ZO_SmithingTopLevel)
	self:SubscribeToElementHidden(ZO_TradingHouse)
	self:SubscribeToElementHidden(ZO_ItemSetsBook_Keyboard_TopLevel)
	if MasterMerchantWindow ~= nil then
		self:SubscribeToElementHidden(MasterMerchantWindow)
	end
	
	--ZO_PreHook("ZO_PopupTooltip_SetLink", OnTooltipItemLinkSet)
	
end