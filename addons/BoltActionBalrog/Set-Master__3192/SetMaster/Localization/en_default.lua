local Localization = {
	Meta = 
	{
		Name = "Set Master"
	},
	Options = 
	{
		Colorblind = 
		{
			Name = "Colorblind Mode",
			Tooltip = "Enable if you are colorblind or have trouble distinguishing colors"
		},
		BankShow = {
			Name = "Bank",
			Tooltip = "Display items stored in your account's bank"
		},
		CharacterBags = {
			NoData = "No data! Login to this character to load bag data.",
			DateScanned = "Date scanned:"
		},
		MegaserverInfo = {
			NoData = "Unknown Megaserver! Login to this character to load the megaserver."
		},
		ShowEquipped = {
			Name = "Equipped",
			Tooltip = "Display items equipped on this character"
		},
		ShowBackpack = {
			Name = "Backpack",
			Tooltip = "Display items in this character's backpack"
		},
		CharacterDataSubmenu = {
			Name = "Character Data",
			Tooltip = "Manage the saved inventory data of each of your characters"
		},
		AccountDataSubmenu = {
			Name = "Account Data",
			Tooltip = "Manage the data of items in your account-wide bags"
		},
		HouseBagHeader = "House Chests",
		Name = "Name",
		HouseBagNameTip = "Create a helpful name for this house chest",
		HouseBagShow = 
		{
			Name = "Show chest",
			Tooltip = "Display items stored in this house chest"
		}
	},
	SetOwnership = 
	{
		UniqueSlots = "Unique Slots:",
		NoItemsOwned = "No items owned"
	},
	OwnerName = 
	{
		Account = "Account",
		House = "House Storage"
	},
	Weight = 
	{
		HeavyAbbreviation = "H",
		MediumAbbreviation = "M",
		LightAbbreviation = "L"
	},
	MeleeWeaponTypes = 
	{
		AxeAbbreviation = "A",
		HammerAbbreviation = "M",
		SwordAbbreviation= "S"
	},
	DestructionStaffWeaponTypes = 
	{
		FireAbbreviation = "F",
		FrostAbbreviation = "I",
		LightningAbbreviation= "L"
	},
	Tooltip = 
	{
		EnableSmartAnchor = "Enable smart anchor",
		DisableSmartAnchor = "Disable smart anchor",
		Close = "Close"
	},
	BagName = {},
	TraitName = {},
	QualityName = {}
}

Localization.BagName[BAG_BACKPACK] = "Backpack"
Localization.BagName[BAG_WORN] = "Equipped"
Localization.BagName[BAG_BANK] = "Bank"
Localization.BagName[BAG_SUBSCRIBER_BANK] = Localization.BagName[BAG_BANK]
Localization.BagName[BAG_GUILDBANK] = "Guild Bank"
Localization.BagName[BAG_HOUSE_BANK_ONE] = "Chest 1"
Localization.BagName[BAG_HOUSE_BANK_TWO] = "Chest 2"
Localization.BagName[BAG_HOUSE_BANK_THREE] = "Chest 3"
Localization.BagName[BAG_HOUSE_BANK_FOUR] = "Chest 4"
Localization.BagName[BAG_HOUSE_BANK_FIVE] = "Chest 5"
Localization.BagName[BAG_HOUSE_BANK_SIX] = "Chest 6"
Localization.BagName[BAG_HOUSE_BANK_SEVEN] = "Chest 7"
Localization.BagName[BAG_HOUSE_BANK_EIGHT] = "Chest 8"
Localization.BagName[BAG_HOUSE_BANK_NINE] = "Chest 9"
Localization.BagName[BAG_HOUSE_BANK_TEN] = "Chest 10"



Localization.TraitName[ITEM_TRAIT_TYPE_NONE] = "No Trait"

Localization.TraitName[ITEM_TRAIT_TYPE_ARMOR_STURDY] = "Sturdy"
Localization.TraitName[ITEM_TRAIT_TYPE_ARMOR_IMPENETRABLE] = "Impenetrable"
Localization.TraitName[ITEM_TRAIT_TYPE_ARMOR_REINFORCED] = "Reinforced"
Localization.TraitName[ITEM_TRAIT_TYPE_ARMOR_WELL_FITTED] = "Well-Fitted"
Localization.TraitName[ITEM_TRAIT_TYPE_ARMOR_TRAINING] = "Training"
Localization.TraitName[ITEM_TRAIT_TYPE_ARMOR_INFUSED] = "Infused"
Localization.TraitName[ITEM_TRAIT_TYPE_ARMOR_PROSPEROUS] = "Invigorating"
Localization.TraitName[ITEM_TRAIT_TYPE_ARMOR_DIVINES] = "Divines"
Localization.TraitName[ITEM_TRAIT_TYPE_ARMOR_NIRNHONED] = "Nirnhoned"

Localization.TraitName[ITEM_TRAIT_TYPE_JEWELRY_ARCANE] = "Arcane"
Localization.TraitName[ITEM_TRAIT_TYPE_JEWELRY_HEALTHY] = "Healthy"
Localization.TraitName[ITEM_TRAIT_TYPE_JEWELRY_ROBUST] = "Robust"
Localization.TraitName[ITEM_TRAIT_TYPE_JEWELRY_TRIUNE] = "Triune"
Localization.TraitName[ITEM_TRAIT_TYPE_JEWELRY_INFUSED] = "Infused"
Localization.TraitName[ITEM_TRAIT_TYPE_JEWELRY_PROTECTIVE] = "Protective"
Localization.TraitName[ITEM_TRAIT_TYPE_JEWELRY_SWIFT] = "Swift"
Localization.TraitName[ITEM_TRAIT_TYPE_JEWELRY_HARMONY] = "Harmony"
Localization.TraitName[ITEM_TRAIT_TYPE_JEWELRY_BLOODTHIRSTY] = "Bloodthirsty"

Localization.TraitName[ITEM_TRAIT_TYPE_WEAPON_POWERED] = "Powered"
Localization.TraitName[ITEM_TRAIT_TYPE_WEAPON_CHARGED] = "Charged"
Localization.TraitName[ITEM_TRAIT_TYPE_WEAPON_PRECISE] = "Precise"
Localization.TraitName[ITEM_TRAIT_TYPE_WEAPON_INFUSED] = "Infused"
Localization.TraitName[ITEM_TRAIT_TYPE_WEAPON_DEFENDING] = "Defending"
Localization.TraitName[ITEM_TRAIT_TYPE_WEAPON_TRAINING] = "Training"
Localization.TraitName[ITEM_TRAIT_TYPE_WEAPON_SHARPENED] = "Sharpened"
Localization.TraitName[ITEM_TRAIT_TYPE_WEAPON_DECISIVE] = "Decisive"
Localization.TraitName[ITEM_TRAIT_TYPE_WEAPON_NIRNHONED] = "Nirnhoned"



Localization.QualityName[ITEM_QUALITY_NORMAL] = "Normal"
Localization.QualityName[ITEM_QUALITY_MAGIC] = "Fine"
Localization.QualityName[ITEM_QUALITY_ARCANE] = "Superior"
Localization.QualityName[ITEM_QUALITY_ARTIFACT] = "Epic"
Localization.QualityName[ITEM_QUALITY_LEGENDARY] = "Legendary"
		
SetMasterGlobal.SetLocalizationTable(Localization)